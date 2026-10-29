class_name TerrainBoard20x20Generator
extends Node3D
## EASTWAR FIELD LAB — 20x20 (3.0m cell = 60m x 60m) 3D Terrain & Vista Builder (Godot 4.6)
## - Heightfield unified with res://assets/battle3d/heightfield.json (step=0.5m, 121x121 vertices)
## - Terrain types unified with res://assets/battle3d/terrain_types.json (preserves 18x10 region 100%)
## - Three Kingdoms 8 Remake style:
##   * Flat dark slate-blue water plane (no wave displacement or depth gradient)
##   * Ford cell (row 5) shown as shallow sand/gravel bar by default; wooden log bridges off by default (show_bridges = false)
##   * Low interior mountain ridges by default (mountain_height_scale = 0.5); tall silhouette ridges in out-of-bounds vista
##   * Symbolic trees only: 0 trees on playable cells; 2 symbolic clusters (38 trees each = 76 trees, 156 tris/tree = 11,856 tris <= 16,000) just outside board boundary; distant background uses low-poly ridge silhouette + texture

const HeightfieldScript = preload("res://scripts/battle3d/lab_heightfield.gd")
const DefaultTerrainShader = preload("res://scripts/battle3d/eastwar_terrain_20x20.gdshader")

enum TerrainType { PLAIN = 0, FOREST = 1, HILL = 2, MOUNTAIN = 3, WATER = 4, FORT = 5, FORD = 6 }
enum OverlayType { NONE = 0, SNOW = 1, MUD = 2, CHARRED = 3 }

const GRID_W: int = 20
const GRID_H: int = 20
const TILE_SIZE: float = 3.0          # 1 cell = 3.0m x 3.0m (playable board = 60.0m x 60.0m)
const SUBDIV: int = 6                 # 6x6 subdiv per cell -> 0.5m step (120x120 Quads = 28,800 tris)
const WATER_SURFACE_Y: float = -0.12  # Flat water surface level (below ford 0.14m, above riverbed -0.32m)
const VISTA_MARGIN: float = 24.0      # Out-of-bounds vista extension (8 cells = 24.0m on each side)
const VISTA_STEP: float = 1.5         # Low-poly step for out-of-bounds vista & silhouette mountain ring

@export var terrain_shader: Shader = DefaultTerrainShader
@export var texture_folder_path: String = "res://assets/terrain_textures_pack"
@export var use_pbr_textures: bool = true

## 0: Regional mix (West=Style1, NE=Style2, SE=Style3), 1: Green Ridge+Crag, 2: Mossy Forest Peak, 3: Ochre Earth Rock
@export_enum("0_Regional_Mix:0", "1_Green_Ridge_Crag:1", "2_Mossy_Forest_Peak:2", "3_Ochre_Boulder:3")
var mountain_visual_style: int = 0

## Scale factor for interior mountain ridges (default 0.5 for Three Kingdoms 8R low ridges)
@export_range(0.1, 1.5, 0.05) var mountain_height_scale: float = 0.5

## Toggle 3D wooden log bridges (default false: ford row 5 shows shallow sand/gravel bar)
@export var show_bridges: bool = false

## Toggle inner playable board trees (default false: 0 trees on unit cells, forest uses 02_forest_floor texture)
@export var scatter_inner_trees: bool = false

## Toggle symbolic boundary pine clusters outside playable board (default true: 2 clusters x 38 trees = 76 trees)
@export var scatter_boundary_trees: bool = true

@export var tree_mesh: Mesh

var board_ref = null
var _built: bool = false

var terrain_grid: Array = []          # [y][x] -> TerrainType
var overlay_grid: Array = []          # [y][x] -> OverlayType

var terrain_mesh_instance: MeshInstance3D
var ford_mesh_instance: MeshInstance3D
var vista_mesh_instance: MeshInstance3D
var water_mesh_instance: MeshInstance3D
var forest_multimesh: MultiMeshInstance3D
var bridges_root: Node3D

var control_image: Image
var control_texture: ImageTexture
var highlight_image: Image
var highlight_texture: ImageTexture
var shader_material: ShaderMaterial

var _noise_macro: FastNoiseLite


func setup_from_board(p_board) -> void:
	board_ref = p_board
	_ensure_built()


func _ready() -> void:
	_ensure_built()


func _ensure_built() -> void:
	if _built:
		return
	_built = true
	if board_ref == null:
		board_ref = HeightfieldScript.new()
	_init_noises()
	_load_terrain_grids_from_json()
	rebuild_entire_battlefield()


func _init_noises() -> void:
	_noise_macro = FastNoiseLite.new()
	_noise_macro.seed = 20261025
	_noise_macro.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	_noise_macro.frequency = 0.032
	_noise_macro.fractal_octaves = 3


func _load_terrain_grids_from_json() -> void:
	terrain_grid.resize(GRID_H)
	overlay_grid.resize(GRID_H)

	var cells_data: Array = []
	var overlays_data: Array = []
	if board_ref != null and board_ref.get("terrain_data") is Dictionary and not board_ref.terrain_data.is_empty():
		cells_data = board_ref.terrain_data.get("cells", [])
		overlays_data = board_ref.terrain_data.get("overlays", [])
	elif FileAccess.file_exists("res://assets/battle3d/terrain_types.json"):
		var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://assets/battle3d/terrain_types.json"))
		if parsed is Dictionary:
			cells_data = parsed.get("cells", [])
			overlays_data = parsed.get("overlays", [])

	for y in range(GRID_H):
		terrain_grid[y] = []
		overlay_grid[y] = []
		for x in range(GRID_W):
			var t_str: String = "plain"
			if y < cells_data.size() and x < cells_data[y].size():
				t_str = String(cells_data[y][x])
			elif board_ref != null:
				t_str = board_ref.terrain(Vector2i(x, y))

			var o_str: String = "none"
			if y < overlays_data.size() and x < overlays_data[y].size():
				o_str = String(overlays_data[y][x])

			terrain_grid[y].append(_string_to_terrain_enum(t_str))
			overlay_grid[y].append(_string_to_overlay_enum(o_str))


func _string_to_terrain_enum(s: String) -> int:
	match s:
		"forest":   return TerrainType.FOREST
		"hill":     return TerrainType.HILL
		"mountain": return TerrainType.MOUNTAIN
		"river":    return TerrainType.WATER
		"ford":     return TerrainType.FORD
		"fort":     return TerrainType.FORT
		_:          return TerrainType.PLAIN


func _string_to_overlay_enum(s: String) -> int:
	match s:
		"snow":    return OverlayType.SNOW
		"mud":     return OverlayType.MUD
		"charred": return OverlayType.CHARRED
		_:         return OverlayType.NONE


func _smoothstep_f(edge0: float, edge1: float, x: float) -> float:
	var t: float = clampf((x - edge0) / (edge1 - edge0), 0.0, 1.0)
	return t * t * (3.0 - 2.0 * t)


## Unified height formula used to bake heightfield.json and extend seamlessly into out-of-bounds vista
func sample_smooth_height_at_world(wx: float, wz: float) -> float:
	var board_w: float = float(GRID_W) * TILE_SIZE
	var board_h: float = float(GRID_H) * TILE_SIZE

	# Inside the playable 20x20 grid (0..60m x 0..60m), read directly from heightfield.json grid when at default scale
	if board_ref != null and wx >= 0.0 and wx <= board_w and wz >= 0.0 and wz <= board_h and absf(mountain_height_scale - 0.5) <= 0.0001:
		var step_s: float = float(board_ref.data.step)
		var ix: int = clampi(int(round(wx / step_s)), 0, int(board_ref.data.nx) - 1)
		var iz: int = clampi(int(round(wz / step_s)), 0, int(board_ref.data.nz) - 1)
		if absf(wx - float(ix) * step_s) < 0.0001 and absf(wz - float(iz) * step_s) < 0.0001:
			return float(board_ref.data.heights[iz][ix])

	var rc: float = 28.0 + 1.4 * sin(wz * 0.25)
	var base: float = 0.55 + 0.15 * sin(wx * 0.4) * cos(wz * 0.35)
	var h1: float = 3.8 * exp(-(pow(wx - 9.0, 2.0) / 44.0 + pow(wz - 5.0, 2.0) / 24.0))
	var h2: float = 2.4 * exp(-(pow(wx - 44.0, 2.0) / 32.0 + pow(wz - 25.0, 2.0) / 30.0))

	var wz_south: float = _smoothstep_f(30.0, 35.0, wz)
	var wx_east: float = _smoothstep_f(54.0, 56.5, wx)

	var sw_ridge: float = 2.6 * mountain_height_scale * exp(-(pow(wx - 10.5, 2.0) / 38.0 + pow(wz - 49.5, 2.0) / 34.0)) * wz_south
	var se_ridge: float = 2.8 * mountain_height_scale * exp(-(pow(wx - 49.5, 2.0) / 40.0 + pow(wz - 48.0, 2.0) / 36.0)) * wz_south
	var ne_ridge: float = 2.2 * mountain_height_scale * exp(-(pow(wx - 57.5, 2.0) / 18.0 + pow(wz - 12.0, 2.0) / 28.0)) * wx_east

	var land: float = base + h1 + h2 + sw_ridge + se_ridge + ne_ridge

	# Out-of-bounds background vista silhouette mountain ring (0 inside 0..60m, rises smoothly in outer ring)
	var dx_out: float = maxf(0.0, maxf(-wx, wx - board_w))
	var dz_out: float = maxf(0.0, maxf(-wz, wz - board_h))
	var d_out: float = sqrt(dx_out * dx_out + dz_out * dz_out)
	if d_out > 0.0:
		var ring_rise: float = _smoothstep_f(4.5, 21.0, d_out)
		var angle: float = atan2(wz - board_h * 0.5, wx - board_w * 0.5)
		var silhouette_wave: float = 1.0 + 0.38 * sin(angle * 5.0 + 0.6) + 0.24 * cos(angle * 9.0 - 0.4)
		# Keep river valley open where river flows out at North (z < 0) and South (z > 60)
		var river_corridor: float = _smoothstep_f(3.2, 10.5, absf(wx - rc))
		land += ring_rise * 3.85 * silhouette_wave * river_corridor

	var d_river: float = absf(wx - rc)
	var s_river: float = _smoothstep_f(1.15, 3.45, d_river)
	return -0.32 + (land + 0.32) * s_river


func update_control_textures() -> void:
	if control_image == null:
		control_image = Image.create(GRID_W, GRID_H, false, Image.FORMAT_RGBA8)
	if highlight_image == null:
		highlight_image = Image.create(GRID_W, GRID_H, false, Image.FORMAT_RGBA8)

	for y in range(GRID_H):
		for x in range(GRID_W):
			var t_type: int = terrain_grid[y][x]
			var o_type: int = overlay_grid[y][x]
			var r_forest: float = 1.0 if t_type == TerrainType.FOREST else 0.0
			var g_snow: float   = 1.0 if o_type == OverlayType.SNOW else 0.0
			var b_mud: float    = 1.0 if o_type == OverlayType.MUD else 0.0
			var a_char: float   = 1.0 if o_type == OverlayType.CHARRED else 0.0
			control_image.set_pixel(x, y, Color(r_forest, g_snow, b_mud, a_char))
			highlight_image.set_pixel(x, y, Color(0.0, 0.0, 0.0, 0.0))

	if control_texture == null:
		control_texture = ImageTexture.create_from_image(control_image)
	else:
		control_texture.update(control_image)

	if highlight_texture == null:
		highlight_texture = ImageTexture.create_from_image(highlight_image)
	else:
		highlight_texture.update(highlight_image)


func rebuild_entire_battlefield() -> void:
	update_control_textures()
	_apply_terrain_shader_material()
	_build_playable_terrain_mesh()
	_build_ford_sandbar_mesh()
	_build_out_of_bounds_vista_mesh()
	_build_water_plane()
	_rebuild_all_wooden_log_bridges()
	_scatter_symbolic_boundary_trees()


## 1) Playable 20x20 Terrain Mesh ("Terrain", 121x121 vertices = 28,800 triangles)
## Uses exact heights from heightfield.json and exact (p00, p10, p01) / (p10, p11, p01) diagonal split
func _build_playable_terrain_mesh() -> void:
	var verts_x: int = GRID_W * SUBDIV + 1
	var verts_z: int = GRID_H * SUBDIV + 1
	var step_size: float = TILE_SIZE / float(SUBDIV)

	# If mountain_height_scale was modified in Inspector from 0.5, sync board_ref.data.heights in extended zone
	if board_ref != null and absf(mountain_height_scale - 0.5) > 0.0001:
		for vz in range(verts_z):
			var wz: float = float(vz) * step_size
			for vx in range(verts_x):
				if vz > 60 or vx > 108:
					var wx: float = float(vx) * step_size
					board_ref.data.heights[vz][vx] = sample_smooth_height_at_world(wx, wz)

	var height_map: Array = []
	height_map.resize(verts_z)
	for vz in range(verts_z):
		height_map[vz] = []
		var wz: float = float(vz) * step_size
		for vx in range(verts_x):
			var wx: float = float(vx) * step_size
			if board_ref != null and vz < board_ref.data.heights.size() and vx < board_ref.data.heights[vz].size():
				height_map[vz].append(float(board_ref.data.heights[vz][vx]))
			else:
				height_map[vz].append(sample_smooth_height_at_world(wx, wz))

	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for vz in range(verts_z - 1):
		for vx in range(verts_x - 1):
			var p00 := Vector3(vx * step_size, height_map[vz][vx], vz * step_size)
			var p10 := Vector3((vx + 1) * step_size, height_map[vz][vx + 1], vz * step_size)
			var p01 := Vector3(vx * step_size, height_map[vz + 1][vx], (vz + 1) * step_size)
			var p11 := Vector3((vx + 1) * step_size, height_map[vz + 1][vx + 1], (vz + 1) * step_size)

			# Triangle 1 (u + v <= 1.0): p00 -> p10 -> p01
			st.set_color(Color(1.0, 1.0, 1.0, 1.0))
			st.set_uv(Vector2(float(vx) / float(verts_x - 1), float(vz) / float(verts_z - 1)))
			st.add_vertex(p00)
			st.set_uv(Vector2(float(vx + 1) / float(verts_x - 1), float(vz) / float(verts_z - 1)))
			st.add_vertex(p10)
			st.set_uv(Vector2(float(vx) / float(verts_x - 1), float(vz + 1) / float(verts_z - 1)))
			st.add_vertex(p01)

			# Triangle 2 (u + v > 1.0): p10 -> p11 -> p01
			st.set_uv(Vector2(float(vx + 1) / float(verts_x - 1), float(vz) / float(verts_z - 1)))
			st.add_vertex(p10)
			st.set_uv(Vector2(float(vx + 1) / float(verts_x - 1), float(vz + 1) / float(verts_z - 1)))
			st.add_vertex(p11)
			st.set_uv(Vector2(float(vx) / float(verts_x - 1), float(vz + 1) / float(verts_z - 1)))
			st.add_vertex(p01)

	st.generate_normals()
	st.generate_tangents()
	var array_mesh: ArrayMesh = st.commit()

	if terrain_mesh_instance == null:
		terrain_mesh_instance = MeshInstance3D.new()
		terrain_mesh_instance.name = "Terrain"
		add_child(terrain_mesh_instance)

	terrain_mesh_instance.mesh = array_mesh
	terrain_mesh_instance.material_override = shader_material


## 2) Shallow Sand/Gravel Ford Mesh ("Ford", row 5 river crossing, 12 triangles)
## Matches lab_heightfield.gd lines 48-49: absf(z-ford_z) <= 1.05 and absf(x-ford_cx) <= 2.2 -> y = maxf(y, 0.14)
func _build_ford_sandbar_mesh() -> void:
	if ford_mesh_instance == null:
		ford_mesh_instance = MeshInstance3D.new()
		ford_mesh_instance.name = "Ford"
		add_child(ford_mesh_instance)

	var ford_row_idx: int = 5
	var river_c: float = 28.0
	if board_ref != null:
		ford_row_idx = board_ref.ford_row
		river_c = board_ref.river_center

	var ford_z_world: float = (float(ford_row_idx) + 0.5) * TILE_SIZE
	var ford_cx_world: float = river_c + 1.4 * sin(ford_z_world * 0.25)

	var box := BoxMesh.new()
	box.size = Vector3(4.4, 0.14, 2.1)
	ford_mesh_instance.mesh = box
	ford_mesh_instance.position = Vector3(ford_cx_world, 0.07, ford_z_world)

	var ford_mat := StandardMaterial3D.new()
	ford_mat.albedo_color = Color(0.62, 0.54, 0.38)
	ford_mat.roughness = 0.88
	var sand_alb: String = texture_folder_path.path_join("05_riverbank_sand_albedo.png")
	var sand_nrm: String = texture_folder_path.path_join("05_riverbank_sand_normal.png")
	if ResourceLoader.exists(sand_alb):
		ford_mat.albedo_texture = load(sand_alb)
		ford_mat.uv1_scale = Vector3(1.5, 1.0, 1.0)
	if ResourceLoader.exists(sand_nrm):
		ford_mat.normal_enabled = true
		ford_mat.normal_texture = load(sand_nrm)
		ford_mat.normal_scale = 0.95
	ford_mesh_instance.material_override = ford_mat


## 3) Out-of-Bounds Background Vista & Low-Poly Silhouette Mountain Ring ("OutOfBoundsVista")
## Surrounds the 60m x 60m playable board with continuous ground and distant silhouette ridges (no vertical cliff cutaway)
func _build_out_of_bounds_vista_mesh() -> void:
	var board_w: float = float(GRID_W) * TILE_SIZE
	var board_h: float = float(GRID_H) * TILE_SIZE
	var min_x: float = -VISTA_MARGIN
	var max_x: float = board_w + VISTA_MARGIN
	var min_z: float = -VISTA_MARGIN
	var max_z: float = board_h + VISTA_MARGIN

	var count_x: int = int(round((max_x - min_x) / VISTA_STEP)) + 1
	var count_z: int = int(round((max_z - min_z) / VISTA_STEP)) + 1

	var vista_h: Array = []
	vista_h.resize(count_z)
	for vz in range(count_z):
		vista_h[vz] = []
		var wz: float = min_z + float(vz) * VISTA_STEP
		for vx in range(count_x):
			var wx: float = min_x + float(vx) * VISTA_STEP
			vista_h[vz].append(sample_smooth_height_at_world(wx, wz))

	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_color(Color(1.0, 1.0, 1.0, 1.0))

	for vz in range(count_z - 1):
		var z0: float = min_z + float(vz) * VISTA_STEP
		var z1: float = z0 + VISTA_STEP
		for vx in range(count_x - 1):
			var x0: float = min_x + float(vx) * VISTA_STEP
			var x1: float = x0 + VISTA_STEP

			# Skip quads strictly inside the 60m x 60m playable board (already covered by "Terrain")
			if x0 >= -0.001 and x1 <= board_w + 0.001 and z0 >= -0.001 and z1 <= board_h + 0.001:
				continue

			var p00 := Vector3(x0, vista_h[vz][vx], z0)
			var p10 := Vector3(x1, vista_h[vz][vx + 1], z0)
			var p01 := Vector3(x0, vista_h[vz + 1][vx], z1)
			var p11 := Vector3(x1, vista_h[vz + 1][vx + 1], z1)

			st.set_uv(Vector2(x0 / board_w, z0 / board_h))
			st.add_vertex(p00)
			st.set_uv(Vector2(x1 / board_w, z0 / board_h))
			st.add_vertex(p10)
			st.set_uv(Vector2(x0 / board_w, z1 / board_h))
			st.add_vertex(p01)

			st.set_uv(Vector2(x1 / board_w, z0 / board_h))
			st.add_vertex(p10)
			st.set_uv(Vector2(x1 / board_w, z1 / board_h))
			st.add_vertex(p11)
			st.set_uv(Vector2(x0 / board_w, z1 / board_h))
			st.add_vertex(p01)

			# Add thin 0.18m inner lip along the 0..60m seam to prevent any sub-step T-junction pinhole
			if absf(z1 - 0.0) < 0.001 and x0 >= 0.0 and x1 <= board_w:
				_add_quad(st, p01, p11, p01 - Vector3(0.0, 0.18, 0.0), p11 - Vector3(0.0, 0.18, 0.0))
			elif absf(z0 - board_h) < 0.001 and x0 >= 0.0 and x1 <= board_w:
				_add_quad(st, p10, p00, p10 - Vector3(0.0, 0.18, 0.0), p00 - Vector3(0.0, 0.18, 0.0))
			if absf(x1 - 0.0) < 0.001 and z0 >= 0.0 and z1 <= board_h:
				_add_quad(st, p11, p10, p11 - Vector3(0.0, 0.18, 0.0), p10 - Vector3(0.0, 0.18, 0.0))
			elif absf(x0 - board_w) < 0.001 and z0 >= 0.0 and z1 <= board_h:
				_add_quad(st, p00, p01, p00 - Vector3(0.0, 0.18, 0.0), p01 - Vector3(0.0, 0.18, 0.0))

	st.generate_normals()
	st.generate_tangents()
	var vista_mesh: ArrayMesh = st.commit()

	if vista_mesh_instance == null:
		vista_mesh_instance = MeshInstance3D.new()
		vista_mesh_instance.name = "OutOfBoundsVista"
		vista_mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(vista_mesh_instance)

	vista_mesh_instance.mesh = vista_mesh
	vista_mesh_instance.material_override = shader_material


func _add_quad(st: SurfaceTool, tl: Vector3, tr: Vector3, bl: Vector3, br: Vector3) -> void:
	st.set_uv(Vector2(0.0, 0.0))
	st.add_vertex(tl)
	st.set_uv(Vector2(1.0, 0.0))
	st.add_vertex(tr)
	st.set_uv(Vector2(0.0, 1.0))
	st.add_vertex(bl)
	st.set_uv(Vector2(1.0, 0.0))
	st.add_vertex(tr)
	st.set_uv(Vector2(1.0, 1.0))
	st.add_vertex(br)
	st.set_uv(Vector2(0.0, 1.0))
	st.add_vertex(bl)


func _apply_terrain_shader_material() -> void:
	shader_material = ShaderMaterial.new()
	if terrain_shader == null:
		terrain_shader = DefaultTerrainShader
	shader_material.shader = terrain_shader
	shader_material.set_shader_parameter("grid_dimensions", Vector2(GRID_W, GRID_H))
	shader_material.set_shader_parameter("tile_world_size", TILE_SIZE)
	shader_material.set_shader_parameter("water_level_y", WATER_SURFACE_Y)
	shader_material.set_shader_parameter("vista_max_distance", VISTA_MARGIN)
	shader_material.set_shader_parameter("terrain_control_map", control_texture)
	shader_material.set_shader_parameter("tactical_highlight_map", highlight_texture)
	shader_material.set_shader_parameter("use_pbr_textures", use_pbr_textures)
	shader_material.set_shader_parameter("mountain_visual_style", mountain_visual_style)

	var noise_tex := NoiseTexture2D.new()
	noise_tex.seamless = true
	noise_tex.noise = _noise_macro
	shader_material.set_shader_parameter("detail_noise_tex", noise_tex)

	var tex_map := {
		"tex_01_grass_albedo":       "01_plain_grass_albedo.png",
		"tex_01_grass_normal":       "01_plain_grass_normal.png",
		"tex_02_forest_albedo":      "02_forest_floor_albedo.png",
		"tex_02_forest_normal":      "02_forest_floor_normal.png",
		"tex_03_dirt_albedo":        "03_hill_ochre_dirt_albedo.png",
		"tex_03_dirt_normal":        "03_hill_ochre_dirt_normal.png",
		"tex_04_cliff_albedo":       "04_mountain_cliff_rock_albedo.png",
		"tex_04_cliff_normal":       "04_mountain_cliff_rock_normal.png",
		"tex_04a_mtn_style1_albedo": "04a_mountain_style1_green_ridge_rock_albedo.png",
		"tex_04a_mtn_style1_normal": "04a_mountain_style1_green_ridge_rock_normal.png",
		"tex_04b_mtn_style2_albedo": "04b_mountain_style2_mossy_verdigris_rock_albedo.png",
		"tex_04b_mtn_style2_normal": "04b_mountain_style2_mossy_verdigris_rock_normal.png",
		"tex_04c_mtn_style3_albedo": "04c_mountain_style3_ochre_earth_rock_albedo.png",
		"tex_04c_mtn_style3_normal": "04c_mountain_style3_ochre_earth_rock_normal.png",
		"tex_05_sand_albedo":        "05_riverbank_sand_albedo.png",
		"tex_05_sand_normal":        "05_riverbank_sand_normal.png",
		"tex_06_snow_albedo":        "06_overlay_snow_albedo.png",
		"tex_06_snow_normal":        "06_overlay_snow_normal.png",
		"tex_07_mud_albedo":         "07_overlay_mud_albedo.png",
		"tex_07_mud_normal":         "07_overlay_mud_normal.png",
		"tex_08_char_albedo":        "08_overlay_charred_ash_albedo.png",
		"tex_08_char_normal":        "08_overlay_charred_ash_normal.png",
	}
	for param_name in tex_map.keys():
		var full_path: String = texture_folder_path.path_join(tex_map[param_name])
		if ResourceLoader.exists(full_path):
			shader_material.set_shader_parameter(param_name, load(full_path))


## 4) Flat Dark Slate-Blue Water Plane ("RiverWaterPlane", Three Kingdoms 8R style: 2 triangles)
func _build_water_plane() -> void:
	if water_mesh_instance == null:
		water_mesh_instance = MeshInstance3D.new()
		water_mesh_instance.name = "RiverWaterPlane"
		water_mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(water_mesh_instance)

	var board_w: float = float(GRID_W) * TILE_SIZE
	var board_h: float = float(GRID_H) * TILE_SIZE
	var plane := PlaneMesh.new()
	plane.size = Vector2(board_w + VISTA_MARGIN * 2.0, board_h + VISTA_MARGIN * 2.0)
	plane.subdivide_width = 0
	plane.subdivide_depth = 0
	water_mesh_instance.mesh = plane
	water_mesh_instance.position = Vector3(board_w * 0.5, WATER_SURFACE_Y, board_h * 0.5)

	var w_mat := StandardMaterial3D.new()
	# Three Kingdoms 8 Remake style: flat, dark muted slate-blue (low saturation), no wave displacement
	w_mat.albedo_color = Color(0.18, 0.25, 0.30, 1.0)
	w_mat.roughness = 0.42
	w_mat.metallic = 0.05
	water_mesh_instance.material_override = w_mat


## 5) Optional 3D Wooden Log Bridges (default OFF: show_bridges = false)
func _rebuild_all_wooden_log_bridges() -> void:
	if bridges_root != null:
		bridges_root.queue_free()
	bridges_root = Node3D.new()
	bridges_root.name = "WoodenLogBridges"
	add_child(bridges_root)

	if not show_bridges:
		return

	for bridge_row in [5.5, 14.5]:
		var wz: float = bridge_row * TILE_SIZE
		var wx: float = 28.0 + 1.4 * sin(wz * 0.25)
		var world_pos := Vector3(wx, WATER_SURFACE_Y + 0.22, wz)
		var bridge_node := _build_wooden_log_bridge(world_pos, 6.4, 2.2, 12)
		bridges_root.add_child(bridge_node)


func _build_wooden_log_bridge(center_pos: Vector3, span_length: float = 6.4, deck_width: float = 2.2, num_logs: int = 12) -> Node3D:
	var root := Node3D.new()
	root.name = "WoodenLogBridge_NoRailing"
	root.position = center_pos

	var bridge_mat := StandardMaterial3D.new()
	bridge_mat.albedo_color = Color(0.72, 0.52, 0.34)
	bridge_mat.roughness = 0.85

	var alb_path: String = texture_folder_path.path_join("09_wooden_log_bridge_albedo.png")
	var nrm_path: String = texture_folder_path.path_join("09_wooden_log_bridge_normal.png")
	if ResourceLoader.exists(alb_path):
		bridge_mat.albedo_texture = load(alb_path)
	if ResourceLoader.exists(nrm_path):
		bridge_mat.normal_enabled = true
		bridge_mat.normal_texture = load(nrm_path)
		bridge_mat.normal_scale = 1.15

	for side_z in [-deck_width * 0.36, deck_width * 0.36]:
		var beam_inst := MeshInstance3D.new()
		var beam_cyl := CylinderMesh.new()
		beam_cyl.top_radius = 0.12
		beam_cyl.bottom_radius = 0.12
		beam_cyl.height = span_length * 0.96
		beam_cyl.radial_segments = 8
		beam_cyl.rings = 1
		beam_inst.mesh = beam_cyl
		beam_inst.rotation_degrees = Vector3(0.0, 0.0, 90.0)
		beam_inst.position = Vector3(0.0, -0.10, side_z)
		beam_inst.material_override = bridge_mat
		root.add_child(beam_inst)

	var step_x: float = span_length / float(num_logs)
	var log_radius: float = step_x * 0.48
	for i in range(num_logs):
		var t: float = (float(i) + 0.5) / float(num_logs)
		var local_x: float = -span_length * 0.5 + (float(i) + 0.5) * step_x
		var arch_y: float = sin(t * PI) * 0.16

		var log_inst := MeshInstance3D.new()
		var log_cyl := CylinderMesh.new()
		log_cyl.top_radius = log_radius
		log_cyl.bottom_radius = log_radius
		log_cyl.height = deck_width
		log_cyl.radial_segments = 10
		log_cyl.rings = 1
		log_inst.mesh = log_cyl
		log_inst.rotation_degrees = Vector3(90.0, 0.0, 0.0)
		log_inst.position = Vector3(local_x, arch_y, 0.0)
		log_inst.material_override = bridge_mat
		root.add_child(log_inst)

	return root


## 6) Symbolic Boundary Pine Clusters ("SymbolicBoundaryTrees")
## - 0 trees inside the 20x20 playable board (0..60m x 0..60m) by default (scatter_inner_trees = false)
## - Exactly 2 symbolic clusters just outside the board boundary (Cluster 1: West edge, Cluster 2: Northeast edge)
## - 38 trees per cluster = 76 trees total (<= 40 trees/cluster)
## - 156 triangles per tree (<= 200 tris/tree) -> 76 * 156 = 11,856 total triangles (<= 16,000 budget)
func _scatter_symbolic_boundary_trees() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 20261026
	var tree_transforms: Array[Transform3D] = []
	var board_w: float = float(GRID_W) * TILE_SIZE
	var board_h: float = float(GRID_H) * TILE_SIZE

	if scatter_boundary_trees:
		# Cluster 1 (West boundary grove outside West forest cells, x in [-9.5, -1.2], z in [12.0, 32.0]): 38 trees
		var cluster_1_count: int = 38
		for i in range(cluster_1_count):
			var row_f: float = float(i) / float(cluster_1_count - 1)
			var wx: float = -1.4 - rng.randf_range(0.4, 7.8)
			var wz: float = lerpf(12.0, 33.0, row_f) + rng.randf_range(-0.9, 0.9)
			var wy: float = sample_smooth_height_at_world(wx, wz)
			var sc: float = rng.randf_range(0.88, 1.28)
			var basis := Basis.from_euler(Vector3(0.0, rng.randf_range(0.0, TAU), 0.0)).scaled(Vector3(sc, sc, sc))
			tree_transforms.append(Transform3D(basis, Vector3(wx, wy, wz)))

		# Cluster 2 (Northeast boundary grove outside NE forest cells, x in [61.2, 69.5], z in [1.0, 14.0]): 38 trees
		var cluster_2_count: int = 38
		for i in range(cluster_2_count):
			var row_f: float = float(i) / float(cluster_2_count - 1)
			var wx: float = board_w + 1.4 + rng.randf_range(0.4, 7.8)
			var wz: float = lerpf(1.0, 14.5, row_f) + rng.randf_range(-0.8, 0.8)
			var wy: float = sample_smooth_height_at_world(wx, wz)
			var sc: float = rng.randf_range(0.88, 1.28)
			var basis := Basis.from_euler(Vector3(0.0, rng.randf_range(0.0, TAU), 0.0)).scaled(Vector3(sc, sc, sc))
			tree_transforms.append(Transform3D(basis, Vector3(wx, wy, wz)))

	# Optional inner board donut placement (disabled by default: scatter_inner_trees = false)
	if scatter_inner_trees:
		for y in range(GRID_H):
			for x in range(GRID_W):
				if terrain_grid[y][x] == TerrainType.FOREST and overlay_grid[y][x] != OverlayType.CHARRED:
					for i in range(4):
						var angle: float = float(i) * (TAU / 4.0) + rng.randf_range(-0.2, 0.2)
						var radius: float = rng.randf_range(0.35, 0.44) * TILE_SIZE
						var wx: float = (float(x) + 0.5) * TILE_SIZE + cos(angle) * radius
						var wz: float = (float(y) + 0.5) * TILE_SIZE + sin(angle) * radius
						var wy: float = board_ref.height(wx, wz) if board_ref != null else sample_smooth_height_at_world(wx, wz)
						var sc: float = rng.randf_range(0.80, 1.15)
						var basis := Basis.from_euler(Vector3(0.0, rng.randf_range(0.0, TAU), 0.0)).scaled(Vector3(sc, sc, sc))
						tree_transforms.append(Transform3D(basis, Vector3(wx, wy, wz)))

	if forest_multimesh == null:
		forest_multimesh = MultiMeshInstance3D.new()
		forest_multimesh.name = "SymbolicBoundaryTrees"
		add_child(forest_multimesh)

	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = tree_mesh if tree_mesh != null else _create_oriental_pine_cluster_mesh()
	mm.instance_count = tree_transforms.size()
	for idx in range(tree_transforms.size()):
		mm.set_instance_transform(idx, tree_transforms[idx])
	forest_multimesh.multimesh = mm


## Low-poly Oriental Pine Mesh: exactly 156 triangles per tree (<= 200 budget)
## - Surface 0 (Trunk): 6-sided tapered prism = 12 triangles
## - Surface 1 (3-tier canopy): 3 octagonal canopy domes x 48 triangles = 144 triangles
## Total = 12 + 144 = 156 triangles
func _create_oriental_pine_cluster_mesh() -> ArrayMesh:
	var bark_mat := StandardMaterial3D.new()
	bark_mat.albedo_color = Color(0.52, 0.34, 0.22)
	bark_mat.roughness = 0.90
	var bark_alb: String = texture_folder_path.path_join("11_tree_bark_trunk_albedo.png")
	var bark_nrm: String = texture_folder_path.path_join("11_tree_bark_trunk_normal.png")
	if ResourceLoader.exists(bark_alb):
		bark_mat.albedo_texture = load(bark_alb)
	if ResourceLoader.exists(bark_nrm):
		bark_mat.normal_enabled = true
		bark_mat.normal_texture = load(bark_nrm)

	var foliage_mat := StandardMaterial3D.new()
	foliage_mat.albedo_color = Color(0.42, 0.64, 0.32)
	foliage_mat.roughness = 0.84
	var fol_alb: String = texture_folder_path.path_join("10_pine_foliage_canopy_albedo.png")
	var fol_nrm: String = texture_folder_path.path_join("10_pine_foliage_canopy_normal.png")
	if ResourceLoader.exists(fol_alb):
		foliage_mat.albedo_texture = load(fol_alb)
	if ResourceLoader.exists(fol_nrm):
		foliage_mat.normal_enabled = true
		foliage_mat.normal_texture = load(fol_nrm)

	var final_mesh := ArrayMesh.new()

	# Surface 0: 6-sided tapered trunk (6 quads = 12 triangles)
	var st_trunk := SurfaceTool.new()
	st_trunk.begin(Mesh.PRIMITIVE_TRIANGLES)
	st_trunk.set_material(bark_mat)
	var trunk_seg: int = 6
	var r_bot: float = 0.18
	var r_top: float = 0.10
	var h_trunk: float = 1.35
	for i in range(trunk_seg):
		var a0: float = float(i) * TAU / float(trunk_seg)
		var a1: float = float(i + 1) * TAU / float(trunk_seg)
		var u0: float = float(i) / float(trunk_seg)
		var u1: float = float(i + 1) / float(trunk_seg)

		var b0 := Vector3(cos(a0) * r_bot, 0.0, sin(a0) * r_bot)
		var b1 := Vector3(cos(a1) * r_bot, 0.0, sin(a1) * r_bot)
		var t0 := Vector3(cos(a0) * r_top, h_trunk, sin(a0) * r_top)
		var t1 := Vector3(cos(a1) * r_top, h_trunk, sin(a1) * r_top)

		st_trunk.set_uv(Vector2(u0, 1.0)); st_trunk.add_vertex(b0)
		st_trunk.set_uv(Vector2(u1, 1.0)); st_trunk.add_vertex(b1)
		st_trunk.set_uv(Vector2(u0, 0.0)); st_trunk.add_vertex(t0)

		st_trunk.set_uv(Vector2(u1, 1.0)); st_trunk.add_vertex(b1)
		st_trunk.set_uv(Vector2(u1, 0.0)); st_trunk.add_vertex(t1)
		st_trunk.set_uv(Vector2(u0, 0.0)); st_trunk.add_vertex(t0)

	st_trunk.generate_normals()
	st_trunk.commit(final_mesh)

	# Surface 1: 3-tier octagonal pine canopy (3 tiers x 48 triangles = 144 triangles)
	var st_canopy := SurfaceTool.new()
	st_canopy.begin(Mesh.PRIMITIVE_TRIANGLES)
	st_canopy.set_material(foliage_mat)

	_append_octagonal_canopy_pad(st_canopy, Vector3(-0.22, 1.25, 0.12), 0.82, 0.42)
	_append_octagonal_canopy_pad(st_canopy, Vector3(0.24, 1.55, -0.10), 0.74, 0.38)
	_append_octagonal_canopy_pad(st_canopy, Vector3(0.0, 1.92, 0.0), 0.86, 0.46)

	st_canopy.generate_normals()
	st_canopy.commit(final_mesh)

	return final_mesh


## Appends 1 octagonal canopy dome with exactly 48 triangles (8 segments x 6 triangles)
func _append_octagonal_canopy_pad(st: SurfaceTool, center: Vector3, radius_xz: float, half_h: float) -> void:
	var segs: int = 8
	var top_pt := center + Vector3(0.0, half_h, 0.0)
	var bot_pt := center + Vector3(0.0, -half_h * 0.65, 0.0)

	for i in range(segs):
		var a0: float = float(i) * TAU / float(segs)
		var a1: float = float(i + 1) * TAU / float(segs)
		var c0: float = cos(a0); var s0: float = sin(a0)
		var c1: float = cos(a1); var s1: float = sin(a1)

		var r_upper := radius_xz * 0.58
		var r_mid   := radius_xz * 1.00
		var r_lower := radius_xz * 0.76

		var u0 := center + Vector3(c0 * r_upper, half_h * 0.42, s0 * r_upper)
		var u1 := center + Vector3(c1 * r_upper, half_h * 0.42, s1 * r_upper)
		var m0 := center + Vector3(c0 * r_mid, -half_h * 0.08, s0 * r_mid)
		var m1 := center + Vector3(c1 * r_mid, -half_h * 0.08, s1 * r_mid)
		var l0 := center + Vector3(c0 * r_lower, -half_h * 0.48, s0 * r_lower)
		var l1 := center + Vector3(c1 * r_lower, -half_h * 0.48, s1 * r_lower)

		# 1) Crown triangle (1 tri)
		st.set_uv(Vector2(0.5, 0.5)); st.add_vertex(top_pt)
		st.set_uv(Vector2(0.5 + c1 * 0.25, 0.5 + s1 * 0.25)); st.add_vertex(u1)
		st.set_uv(Vector2(0.5 + c0 * 0.25, 0.5 + s0 * 0.25)); st.add_vertex(u0)

		# 2) Upper skirt quad (2 tris)
		st.set_uv(Vector2(0.5 + c0 * 0.25, 0.5 + s0 * 0.25)); st.add_vertex(u0)
		st.set_uv(Vector2(0.5 + c1 * 0.25, 0.5 + s1 * 0.25)); st.add_vertex(u1)
		st.set_uv(Vector2(0.5 + c0 * 0.48, 0.5 + s0 * 0.48)); st.add_vertex(m0)

		st.set_uv(Vector2(0.5 + c1 * 0.25, 0.5 + s1 * 0.25)); st.add_vertex(u1)
		st.set_uv(Vector2(0.5 + c1 * 0.48, 0.5 + s1 * 0.48)); st.add_vertex(m1)
		st.set_uv(Vector2(0.5 + c0 * 0.48, 0.5 + s0 * 0.48)); st.add_vertex(m0)

		# 3) Lower rim quad (2 tris)
		st.set_uv(Vector2(0.5 + c0 * 0.48, 0.5 + s0 * 0.48)); st.add_vertex(m0)
		st.set_uv(Vector2(0.5 + c1 * 0.48, 0.5 + s1 * 0.48)); st.add_vertex(m1)
		st.set_uv(Vector2(0.5 + c0 * 0.35, 0.5 + s0 * 0.35)); st.add_vertex(l0)

		st.set_uv(Vector2(0.5 + c1 * 0.48, 0.5 + s1 * 0.48)); st.add_vertex(m1)
		st.set_uv(Vector2(0.5 + c1 * 0.35, 0.5 + s1 * 0.35)); st.add_vertex(l1)
		st.set_uv(Vector2(0.5 + c0 * 0.35, 0.5 + s0 * 0.35)); st.add_vertex(l0)

		# 4) Underside closure triangle (1 tri)
		st.set_uv(Vector2(0.5 + c0 * 0.35, 0.5 + s0 * 0.35)); st.add_vertex(l0)
		st.set_uv(Vector2(0.5 + c1 * 0.35, 0.5 + s1 * 0.35)); st.add_vertex(l1)
		st.set_uv(Vector2(0.5, 0.5)); st.add_vertex(bot_pt)
