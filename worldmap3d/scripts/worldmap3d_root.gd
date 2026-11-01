## EASTWAR WorldMap3D v3 — map root. Everything map-specific comes from ONE config file (map_config_path):
## geometry/height grid, textures, region map + region table, marker positions, rivers, camera limits.
## Game state (factions, owners, troops, road links) comes from the rule data file.
## Public API: set_city_owner, set_city_troops, focus_city, set_marker_position, set_fill_preset, region_of_city.
class_name WorldMap3DRoot
extends Node3D

signal map_built(stats: Dictionary)
signal city_selected(city_id: String, region_index: int)   # v2.2: left click (camera.select_requested) -> nearest city / region

@export_file("*.json") var map_config_path := "res://worldmap3d/maps/eastasia/map_config.json"
@export_file("*.json") var rule_data_path := ""            # empty = use the config's rule_data
@export var fill_preset := ""                               # empty = config default ("strong"/"medium"/"light")
@export var marker_scene_default: PackedScene               # null = procedural castle placeholder
@export var banner_screen_scale := 0.13                     # banner height ≈ this × camera distance
@export var banner_min_km := 1.2
@export var banner_max_km := 100.0
@export var show_markers := true
@export var castle_screen_scale := 0.0                       # v2.4: >0 = castle scale ≈ this × camera distance (km), clamped below
@export var castle_min_scale := 1.0
@export var castle_max_scale := 14.0
@export var show_region_labels := true                       # v2.4: map_config "region_labels" (painterly region names)
@export var show_rivers := true
@export var show_roads := true

const SHADERS := "res://worldmap3d/shaders/"
const TEX := "res://worldmap3d/textures/"
var cfg := WorldMapConfig.new()
var geo := WorldMapGeo.new()
var regions := WorldMapRegions.new()
var rules: Dictionary
var faction_color := {}       # faction_id -> Color
var cities := {}              # city_id -> Dictionary (live copy of rule data)
var marker_xz := {}           # city_id -> Vector2 (display position, symbolic; independent of regions)
var marker_def := {}          # city_id -> Dictionary from markers.json
var banners := {}             # city_id -> WorldMapCityBanner
var markers := {}             # city_id -> Node3D (castle placeholder or custom scene)
var glows := {}               # city_id -> Sprite3D
var region_labels: Node3D    # v2.4 region name labels (worldmap_region_labels.gd, no class_name); null if the map has none
const REGION_LABELS_SCRIPT := preload("res://worldmap3d/scripts/worldmap_region_labels.gd")
var terrain_mat: ShaderMaterial
var sea_mat: ShaderMaterial
var road_mat: ShaderMaterial
var river_mat: ShaderMaterial
var road_node: MeshInstance3D
var river_node: MeshInstance3D
var camera: WorldMap3DCamera
var env: Environment
var sun: DirectionalLight3D
var roads := WorldMapRoads.new()
var stats := {}
var _preset := {}

func _ready() -> void:
	var t0 := Time.get_ticks_usec()
	if not cfg.load_file(map_config_path):
		return
	if not geo.load_data(cfg):
		return
	var rp := rule_data_path if rule_data_path != "" else cfg.rule_data_path
	rules = JSON.parse_string(FileAccess.get_file_as_string(rp))
	# v2.2: colours = map palette (map_config territory.faction_palette) unless palette_source == "rules"
	var pal: Dictionary = {}
	if String(cfg.territory.get("palette_source", "map")) == "map":
		pal = cfg.territory.get("faction_palette", {})
	for f in rules.factions:
		faction_color[f.id] = Color(pal.get(f.id, f.get("color", "#808080")))
	for c in rules.cities:
		cities[c.id] = c.duplicate()
	var md = JSON.parse_string(FileAccess.get_file_as_string(cfg.markers_path))
	for cid in md.markers:
		marker_def[cid] = md.markers[cid]
		marker_xz[cid] = Vector2(float(md.markers[cid].x_km), float(md.markers[cid].z_km))
	regions.load_tables(cfg.regions_path, rules.factions, String(cfg.territory.get("border_group", "owner")), pal)
	var owners := {}
	for cid in cities:
		owners[cid] = cities[cid].get("owner", "")
	regions.set_all_owners(owners)
	stats.t_data_ms = (Time.get_ticks_usec() - t0) / 1000.0
	_build_environment()
	var t1 := Time.get_ticks_usec()
	_build_terrain()
	_build_sea()
	stats.t_terrain_ms = (Time.get_ticks_usec() - t1) / 1000.0
	t1 = Time.get_ticks_usec()
	if show_rivers:
		_build_rivers()
	if show_roads:
		_build_roads()
	stats.t_ribbons_ms = (Time.get_ticks_usec() - t1) / 1000.0
	if show_markers:
		_build_cities()
	if show_region_labels:
		_build_region_labels()
	_build_camera()
	set_fill_preset(fill_preset)
	stats.build_ms = (Time.get_ticks_usec() - t0) / 1000.0
	stats.map_id = cfg.map_id
	stats.region_count = regions.regions.size()
	print("[WorldMap3D] map '%s' built in %.0f ms (data %.0f, terrain %.0f, ribbons %.0f) terrain tris %d, road tris %d, river tris %d, regions %d" % [
		cfg.map_id, stats.build_ms, stats.t_data_ms, stats.t_terrain_ms, stats.t_ribbons_ms, stats.terrain_tris,
		stats.get("road_tris", 0), stats.get("river_tris", 0), stats.region_count])
	map_built.emit(stats)

# ------------------------------------------------------------------ build
func _build_environment() -> void:
	# Pinned explicitly (v3): every value that differs between Forward+ and Compatibility defaults is set here.
	env = Environment.new()
	var sky := Sky.new()
	var sm := ProceduralSkyMaterial.new()
	sm.sky_top_color = Color(0.20, 0.40, 0.70)
	sm.sky_horizon_color = Color(0.72, 0.80, 0.88)   # v3.1: v2 values (brighter sea reflection/ambient)
	sm.ground_horizon_color = Color(0.72, 0.80, 0.88)
	sm.ground_bottom_color = Color(0.25, 0.35, 0.45)
	sm.sun_angle_max = 20.0
	sky.sky_material = sm
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.5
	env.ambient_light_sky_contribution = 1.0
	env.reflected_light_source = Environment.REFLECTION_SOURCE_SKY
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.tonemap_exposure = 0.95
	env.tonemap_white = 6.0
	env.glow_enabled = true
	env.glow_normalized = false
	env.glow_intensity = 0.45
	env.glow_strength = 1.0
	env.glow_bloom = 0.03
	env.glow_blend_mode = Environment.GLOW_BLEND_MODE_SOFTLIGHT
	env.glow_hdr_threshold = 0.9
	env.glow_hdr_scale = 2.0
	for i in 7:
		env.set_glow_level(i, 1.0 if i in [1, 2, 3, 4] else 0.0)
	env.fog_enabled = true
	env.fog_mode = Environment.FOG_MODE_DEPTH
	env.fog_light_color = Color(0.62, 0.70, 0.80)
	env.fog_light_energy = 1.0
	env.fog_sun_scatter = 0.0
	env.fog_density = 0.0
	env.fog_sky_affect = 0.35
	env.fog_aerial_perspective = 0.15
	env.fog_height_density = 0.0
	env.volumetric_fog_enabled = false
	env.ssao_enabled = false
	env.ssil_enabled = false
	env.ssr_enabled = false
	env.sdfgi_enabled = false
	env.adjustment_enabled = true
	env.adjustment_brightness = 1.0
	env.adjustment_saturation = 1.06
	env.adjustment_contrast = 1.10
	var we := WorldEnvironment.new()
	we.environment = env
	we.name = "WorldEnvironment"
	add_child(we)
	sun = DirectionalLight3D.new()
	sun.name = "Sun"
	sun.light_color = Color(1.0, 0.95, 0.86)
	sun.light_energy = 1.55
	sun.rotation_degrees = Vector3(-36.0, -62.0, 0.0)
	sun.shadow_enabled = true
	sun.shadow_bias = 0.05
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS
	sun.directional_shadow_max_distance = 600.0
	add_child(sun)

func _tex(key: String) -> Texture2D:
	return load(cfg.textures[key]) as Texture2D

func _build_terrain() -> void:
	# EA v2: big grids -> chunked tiles with mesh LODs (config "terrain" block); small maps keep the v3 single mesh
	var tcfg: Dictionary = cfg.raw.get("terrain", {})
	var tiled: bool = bool(tcfg.get("tiled", geo.gw * geo.gh > 300000))
	var tiles := []
	var mesh: ArrayMesh = null
	if tiled:
		var lod_err := {}
		var lp: String = cfg._res(String(tcfg.get("lod_errors", "terrain/tile_lod.json")))
		if FileAccess.file_exists(lp):
			lod_err = JSON.parse_string(FileAccess.get_file_as_string(lp)).get("errors", {})
		tiles = geo.build_terrain_tiles(int(tcfg.get("tile_cells", 128)), tcfg.get("lod_strides", [2, 4, 8]),
				float(tcfg.get("skirt_km", 6.0)), lod_err)
		stats.terrain_tris = geo.tile_stats.tris_lod0
		stats.terrain_tiles = geo.tile_stats.tiles
		get_viewport().mesh_lod_threshold = float(tcfg.get("lod_threshold_px", 1.0))
	else:
		mesh = geo.build_terrain_mesh()
		stats.terrain_tris = mesh.surface_get_array_index_len(0) / 3
	terrain_mat = ShaderMaterial.new()
	terrain_mat.shader = load(SHADERS + "worldmap_terrain.gdshader")
	if cfg.textures.has("albedo_tiles"):
		# v2.2: 2x2 tiles terrain_*_tile_<x>_<y> (x east, y south; order 0_0, 1_0, 0_1, 1_1), sampled seamlessly by the shader
		var at: Array = cfg.textures.albedo_tiles
		var nt: Array = cfg.textures.normal_tiles
		var keys := ["t00", "t10", "t01", "t11"]
		var full := Vector2.ZERO
		for k in 4:
			var a := load(at[k]) as Texture2D
			terrain_mat.set_shader_parameter("albedo_" + keys[k], a)
			terrain_mat.set_shader_parameter("normal_" + keys[k], load(nt[k]) as Texture2D)
			if k == 0:
				full = Vector2(a.get_width() * 2, a.get_height() * 2)
		var tt: Dictionary = cfg.raw.get("texture_tiles", {})
		if tt.has("full_px"):
			full = Vector2(float(tt.full_px[0]), float(tt.full_px[1]))
		terrain_mat.set_shader_parameter("tex_full_px", full)
		terrain_mat.set_shader_parameter("tex_tiled", 1)
		stats.texture_tiles = 4
	else:
		terrain_mat.set_shader_parameter("albedo_tex", _tex("albedo"))
		terrain_mat.set_shader_parameter("normal_tex", _tex("normal"))
		terrain_mat.set_shader_parameter("tex_tiled", 0)
	terrain_mat.set_shader_parameter("coast_tex", _tex("coast"))
	terrain_mat.set_shader_parameter("depth_tex", _tex("depth"))
	terrain_mat.set_shader_parameter("mask_tex", _tex("mask"))
	var rid := _tex("region_ids")
	terrain_mat.set_shader_parameter("region_ids_tex", rid)
	terrain_mat.set_shader_parameter("region_dist_tex", _tex("region_dist"))
	terrain_mat.set_shader_parameter("owner_lut", regions.lut_texture)
	terrain_mat.set_shader_parameter("region_dist_max_km", cfg.region_dist_max_km)
	terrain_mat.set_shader_parameter("region_texel_km", cfg.size_km.x / float(rid.get_width()))
	terrain_mat.set_shader_parameter("warp_tex", load(TEX + "warp_noise_256.png"))
	terrain_mat.set_shader_parameter("wave_tex", load(TEX + "wave_normal_512.png"))
	for dname in ["field", "forest", "rock"]:
		var fn: String = "fields" if dname == "field" else dname
		terrain_mat.set_shader_parameter("det_%s_a" % dname, load(TEX + "detail/%s_albedo.png" % fn))
		terrain_mat.set_shader_parameter("det_%s_n" % dname, load(TEX + "detail/%s_normal.png" % fn))
	var ib: Dictionary = cfg.territory.get("inner_border", {})
	terrain_mat.set_shader_parameter("inner_width_ratio", float(ib.get("width_ratio", 0.4)))
	terrain_mat.set_shader_parameter("inner_min_px", float(ib.get("min_px", 1.6)))
	terrain_mat.set_shader_parameter("inner_dark", float(ib.get("dark", 0.42)))
	terrain_mat.set_shader_parameter("inner_halo", float(ib.get("halo", 0.45)))
	terrain_mat.set_shader_parameter("inner_halo_px", float(ib.get("halo_px", 0.8)))
	# v2.2: per-region fill brightness alternation is ON HOLD -> only with inner_border.fill_alternation = true (default false)
	terrain_mat.set_shader_parameter("shade_amount", float(ib.get("shade_amount", 0.0)) if bool(ib.get("fill_alternation", false)) else 0.0)
	_set_common(terrain_mat)
	terrain_mat.set_shader_parameter("detail_tile_km", float(cfg.look.get("detail_tile_km", 4.0)))
	if tiled:
		var tn := Node3D.new()
		tn.name = "Terrain"
		add_child(tn)
		for t in tiles:
			var tmi := MeshInstance3D.new()
			tmi.name = "T_%d_%d" % [t.tile.x, t.tile.y]
			tmi.mesh = t.mesh
			tmi.material_override = terrain_mat
			tn.add_child(tmi)
	else:
		var mi := MeshInstance3D.new()
		mi.name = "Terrain"
		mi.mesh = mesh
		mi.material_override = terrain_mat
		add_child(mi)

func _set_common(m: ShaderMaterial) -> void:
	m.set_shader_parameter("map_size_km", cfg.size_km)
	m.set_shader_parameter("coast_sdf_km", cfg.coast_sdf_km)
	m.set_shader_parameter("depth_max_m", cfg.depth_max_m)
	m.set_shader_parameter("edge_mist_km", float(cfg.look.get("edge_mist_km", 130.0)))

func _build_sea() -> void:
	sea_mat = ShaderMaterial.new()
	sea_mat.shader = load(SHADERS + "worldmap_sea_plane.gdshader")
	sea_mat.set_shader_parameter("coast_tex", _tex("coast"))
	sea_mat.set_shader_parameter("depth_tex", _tex("depth"))
	sea_mat.set_shader_parameter("wave_tex", load(TEX + "wave_normal_512.png"))
	sea_mat.set_shader_parameter("warp_tex", load(TEX + "warp_noise_256.png"))
	_set_common(sea_mat)
	var pm := PlaneMesh.new()
	pm.size = Vector2(14000, 14000)
	var mi := MeshInstance3D.new()
	mi.name = "OuterSea"
	mi.mesh = pm
	mi.material_override = sea_mat
	mi.position.y = -0.15
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)

func _ribbon_node(nm: String, mesh: ArrayMesh, mat: ShaderMaterial) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = nm
	mi.mesh = mesh
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)
	return mi

func _build_rivers() -> void:
	if cfg.rivers_path == "" or not FileAccess.file_exists(cfg.rivers_path):
		return
	var rd = JSON.parse_string(FileAccess.get_file_as_string(cfg.rivers_path))
	var lines := []
	var widths := []
	for r in rd.rivers:
		var p: Array = r.p
		var pts := PackedVector2Array()
		for k in range(0, p.size() - 1, 2):
			pts.append(Vector2(p[k], p[k + 1]))
		var ws := PackedFloat32Array()
		var n := pts.size()
		for k in n:   # polylines run source -> mouth: widen downstream
			ws.append(float(r.w) * (0.3 + 0.7 * sqrt(float(k) / maxf(n - 1, 1))))
		lines.append(pts)
		widths.append(ws)
	var mesh := WorldMapRibbons.build(geo, lines, widths, 1.2)
	stats.river_tris = mesh.surface_get_array_index_len(0) / 3 if mesh.get_surface_count() > 0 else 0
	river_mat = ShaderMaterial.new()
	river_mat.shader = load(SHADERS + "worldmap_ribbon.gdshader")
	river_mat.set_shader_parameter("width_km", 0.9)
	river_mat.set_shader_parameter("min_px", 1.0)
	river_mat.set_shader_parameter("fade_px_lo", 0.12)
	river_mat.set_shader_parameter("fade_px_hi", 0.6)
	river_mat.set_shader_parameter("core_color", Color(0.34, 0.62, 0.80))
	river_mat.set_shader_parameter("edge_color", Color(0.16, 0.34, 0.48))
	river_mat.set_shader_parameter("edge_from", 0.55)
	river_mat.set_shader_parameter("opacity", 0.9)
	river_mat.set_shader_parameter("emission_k", 0.12)
	river_mat.render_priority = 0
	river_node = _ribbon_node("Rivers", mesh, river_mat)

func _build_roads() -> void:
	var t := Time.get_ticks_usec()
	roads.build_paths(geo, marker_xz, rules.roads)
	var mesh := WorldMapRibbons.build(geo, roads.paths, [], 0.8)
	stats.road_build_ms = (Time.get_ticks_usec() - t) / 1000.0
	stats.road_tris = mesh.surface_get_array_index_len(0) / 3 if mesh.get_surface_count() > 0 else 0
	if road_mat == null:
		road_mat = ShaderMaterial.new()
		road_mat.shader = load(SHADERS + "worldmap_ribbon.gdshader")
		road_mat.set_shader_parameter("width_km", 0.55)
		road_mat.set_shader_parameter("min_px", 2.0)
		road_mat.set_shader_parameter("core_color", Color(0.95, 0.91, 0.78))
		road_mat.set_shader_parameter("edge_color", Color(0.42, 0.33, 0.22))
		road_mat.set_shader_parameter("edge_from", 0.6)
		road_mat.set_shader_parameter("opacity", 0.92)
		road_mat.render_priority = 1
	if road_node:
		road_node.mesh = mesh
	else:
		road_node = _ribbon_node("Roads", mesh, road_mat)

func _make_marker(cid: String, c: Dictionary, col: Color) -> Node3D:
	var path: String = marker_def.get(cid, {}).get("marker_scene", "")
	var node: Node3D
	if path != "" and ResourceLoader.exists(path):
		node = (load(path) as PackedScene).instantiate()
	elif marker_scene_default:
		node = marker_scene_default.instantiate()
	else:
		var cm := WorldMapCastleMarker.new()
		cm.build(int(c.get("grade", 2)), col)
		node = cm
	if node.has_method("set_faction_color"):
		node.set_faction_color(col)
	var sc = marker_def.get(cid, {}).get("marker_scale", 1.0)
	node.scale = Vector3.ONE * float(sc)
	return node

func _build_cities() -> void:
	var font: Font = load("res://worldmap3d/fonts/NotoSerifKR-Bold-subset.otf")
	var glow_tex: Texture2D = load(TEX + "ui/ground_glow.png")
	for cid in cities:
		if not marker_xz.has(cid):
			continue
		var c: Dictionary = cities[cid]
		var col: Color = faction_color.get(c.owner, Color.GRAY)
		var m := _make_marker(cid, c, col)
		m.name = "Marker_" + cid
		add_child(m)
		markers[cid] = m
		var g := Sprite3D.new()
		g.texture = glow_tex
		g.pixel_size = 9.0 / glow_tex.get_width()
		g.axis = Vector3.AXIS_Y
		g.shaded = false
		g.modulate = Color(col.r, col.g, col.b, 0.55)
		g.name = "Glow_" + cid
		add_child(g)
		glows[cid] = g
		var b := WorldMapCityBanner.new()
		b.name = "Banner_" + cid
		b.build(c, col, font)
		var bdx := float(marker_def.get(cid, {}).get("banner_dx", 0.0))
		if bdx != 0.0:
			b.set_offset_x(bdx)
		add_child(b)
		banners[cid] = b
		_place_city(cid)

## v2.4: region name labels from the existing region table (regions.json label_ko / label_xz_km, fallback name_ko +
## centroid from region_ids.png) with the style in map_config "region_labels". Maps without that block get no labels.
func _build_region_labels() -> void:
	var st = cfg.raw.get("region_labels", null)
	if not (st is Dictionary) or not bool(st.get("enabled", true)):
		return
	region_labels = REGION_LABELS_SCRIPT.new()
	region_labels.name = "RegionLabels"
	add_child(region_labels)
	var img: Image = null
	for r in regions.regions:
		if not r.has("label_xz_km"):
			var t := _tex("region_ids")
			img = t.get_image() if t else null
			break
	stats.region_labels = region_labels.build(regions.regions, st, load("res://worldmap3d/fonts/NotoSerifKR-Bold-subset.otf"), img, geo.uv_to_xz, geo.height_at)

func _place_city(cid: String) -> void:
	var xz: Vector2 = marker_xz[cid]
	var y := geo.height_at(xz)
	if markers.has(cid):
		markers[cid].position = Vector3(xz.x, y, xz.y)
	if glows.has(cid):
		glows[cid].position = Vector3(xz.x, y + 0.08, xz.y)
	if banners.has(cid):
		banners[cid].position = Vector3(xz.x, y + 0.3, xz.y)

func _build_camera() -> void:
	camera = WorldMap3DCamera.new()
	camera.name = "WorldMap3DCamera"
	camera.configure(cfg)
	camera.ground_height = geo.height_at
	camera.env_ref = env
	camera.sun = sun
	add_child(camera)
	camera.current = true
	camera.select_requested.connect(_on_select)
	var st = cfg.cam("start_km", [0, 0])
	camera.set_view(Vector2(st[0], st[1]), float(cfg.cam("start_zoom", 0.0)))
	var layer := CanvasLayer.new()
	layer.name = "Vignette"
	add_child(layer)
	vignette = ColorRect.new()
	vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var vm := ShaderMaterial.new()
	vm.shader = load(SHADERS + "worldmap_vignette.gdshader")
	vignette.material = vm
	layer.add_child(vignette)

var vignette: ColorRect

func _process(_dt: float) -> void:
	if camera == null:
		return
	update_zoom_params()
	var cb := camera.global_transform.basis
	for id in banners:
		var b: Node3D = banners[id]
		var d := camera.global_position.distance_to(b.global_position)
		var s := clampf(d * banner_screen_scale, banner_min_km, banner_max_km)
		b.global_transform = Transform3D(cb.scaled(Vector3(s, s, s)), b.global_position)
	if castle_screen_scale > 0.0:
		for id in markers:
			var m: Node3D = markers[id]
			var d := camera.global_position.distance_to(m.global_position)
			var k := clampf(d * castle_screen_scale, castle_min_scale, castle_max_scale) * float(marker_def.get(id, {}).get("marker_scale", 1.0))
			m.scale = Vector3(k, k, k)
			if glows.has(id):
				var kg := minf(k, 3.0)          # ground glow: do not let it wash over the castle at far zoom
				glows[id].scale = Vector3(kg, kg, kg)
	if region_labels:
		region_labels.update_for_camera(camera)

func update_zoom_params() -> void:
	var t := smoothstep(0.2, 1.0, camera.zoom)
	terrain_mat.set_shader_parameter("territory_fill", lerpf(float(_preset.fill_far), float(_preset.fill_near), t))
	terrain_mat.set_shader_parameter("territory_band", float(_preset.band))
	terrain_mat.set_shader_parameter("territory_edge_km", lerpf(20.0, 13.0, t))
	if vignette:
		(vignette.material as ShaderMaterial).set_shader_parameter("strength", lerpf(0.85, 0.35, smoothstep(0.0, 0.5, camera.zoom)))

# ------------------------------------------------------------------ public API
## Owner change: ONE texel of the owner lookup texture -> the whole region recolours next frame. O(1).
func set_city_owner(city_id: String, faction_id: String) -> bool:
	if not cities.has(city_id) or not faction_color.has(faction_id):
		return false
	cities[city_id].owner = faction_id
	regions.set_city_owner(city_id, faction_id)
	var col: Color = faction_color[faction_id]
	if banners.has(city_id):
		banners[city_id].set_faction_color(col)
	if markers.has(city_id) and markers[city_id].has_method("set_faction_color"):
		markers[city_id].set_faction_color(col)
	if glows.has(city_id):
		glows[city_id].modulate = Color(col.r, col.g, col.b, 0.55)
	return true

## v2.2: palette override from the game (recolours regions, banners, markers of that faction).
func set_faction_color(faction_id: String, col: Color) -> void:
	faction_color[faction_id] = col
	regions.set_faction_color(faction_id, col)
	for cid in cities:
		if cities[cid].get("owner", "") == faction_id:
			if banners.has(cid):
				banners[cid].set_faction_color(col)
			if markers.has(cid) and markers[cid].has_method("set_faction_color"):
				markers[cid].set_faction_color(col)
			if glows.has(cid):
				glows[cid].modulate = Color(col.r, col.g, col.b, 0.55)

func set_city_troops(city_id: String, n: int) -> void:
	if banners.has(city_id):
		cities[city_id].troops = n
		banners[city_id].set_troops(n)

func focus_city(city_id: String, zoom := 0.85) -> void:
	if marker_xz.has(city_id):
		camera.set_view(marker_xz[city_id] + Vector2(0, -20), zoom, rad_to_deg(camera.yaw_goal), false)

## Moves ONLY the marker/banner (display position). Region borders are a separate texture and do not change.
## rebuild_roads: re-route the road ribbons to the new position (default true).
func set_marker_position(city_id: String, xz: Vector2, rebuild_roads := true) -> void:
	if not marker_xz.has(city_id):
		return
	marker_xz[city_id] = xz
	_place_city(city_id)
	if rebuild_roads and show_roads:
		_build_roads()

func set_fill_preset(name: String) -> void:
	_preset = cfg.fill_preset(name)
	if camera:
		update_zoom_params()

func region_of_city(city_id: String) -> int:
	return regions.index_by_city.get(city_id, 0)

## v2.2: left click -> ground point (ray vs terrain, 2 refinement steps) -> region under it + nearest city marker.
func screen_to_ground(sp: Vector2) -> Vector2:
	var o := camera.project_ray_origin(sp)
	var d := camera.project_ray_normal(sp)
	var y := 0.0
	var p := Vector2(o.x, o.z)
	for i in 4:
		if absf(d.y) < 1e-5:
			break
		var t := (y - o.y) / d.y
		p = Vector2(o.x + d.x * t, o.z + d.z * t)
		y = geo.mesh_height_at(p)
	return p

func region_at(xz: Vector2) -> int:
	var rid := terrain_mat.get_shader_parameter("region_ids_tex") as Texture2D
	if rid == null:
		return 0
	if _rid_img == null:
		_rid_img = rid.get_image()
	var uv: Vector2 = geo.xz_to_uv(xz)
	var px := Vector2i(clampi(int(uv.x * _rid_img.get_width()), 0, _rid_img.get_width() - 1), clampi(int(uv.y * _rid_img.get_height()), 0, _rid_img.get_height() - 1))
	return int(round(_rid_img.get_pixelv(px).r * 255.0))

var _rid_img: Image
var selected_city := ""

func _on_select(sp: Vector2) -> void:
	var xz := screen_to_ground(sp)
	var r := region_at(xz)
	var cid: String = regions.city_by_index.get(r, "")
	selected_city = cid
	city_selected.emit(cid, r)
