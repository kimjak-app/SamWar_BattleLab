class_name TerrainBoard20x20Generator
extends Node3D
## EASTWAR FIELD LAB — 20x20 (3.0m cell = 60m x 60m) 3D Terrain & Vista Builder (Godot 4.6)
## - Heightfield unified with res://assets/battle3d/heightfield.json (step=0.5m, 121x121 vertices)
## - Terrain types unified with res://assets/battle3d/terrain_types.json (preserves 18x10 region 100%)
## - Visual Pass 1 (Out-of-Bounds + Compatibility Water):
##   * Seamless same-height OutOfBoundsVista (0.0m seam step via 0.5m-to-1.5m edge stitching, 9,920 tris <= 12,000)
##   * Gentle 4~8m outer rolling ridges, 1-cell (3.0m) soft desaturation/darkening, 100% haze lock at 45m
##   * Pale yellow border line along play_rect (play_cells read in one place: _get_play_rect_world())
##   * Flat RiverWaterPlane ribbon mesh (y = -0.12, 4,120 tris) with baked shoreline/ford vertex colors & UVs
## - Visual Pass 2 (Forest Cell Trees + Out-of-Bounds Painted Ground):
##   * Boundary tree clusters off by default (scatter_boundary_trees = false)
##   * Forest cell trees (2~4 per cell, seed-deterministic, >= 0.4m inside border, non-overlapping, height <= 4.0m)
##   * Unit occupation semi-transparency via set_forest_cell_fade(cell, fade) (alpha ~0.35; 100% opaque when unfaded)
##   * Out-of-bounds world-UV painted ground texture (outer_ground_texture + procedural cartographic fallback)
##   * Greyish-yellow default haze color (#8d897a)

const HeightfieldScript = preload("res://scripts/battle3d/lab_heightfield.gd")
const DefaultTerrainShader = preload("res://scripts/battle3d/eastwar_terrain_20x20.gdshader")
const DefaultWaterShader = preload("res://scripts/battle3d/eastwar_terrain_20x20_water.gdshader")

enum TerrainType { PLAIN = 0, FOREST = 1, HILL = 2, MOUNTAIN = 3, WATER = 4, FORT = 5, FORD = 6 }
enum OverlayType { NONE = 0, SNOW = 1, MUD = 2, CHARRED = 3 }

const GRID_W: int = 20
const GRID_H: int = 20
const TILE_SIZE: float = 3.0          # 1 cell = 3.0m x 3.0m (20x20 data board = 60.0m x 60.0m)
const SUBDIV: int = 6                 # 6x6 subdiv per cell -> 0.5m step (120x120 Quads = 28,800 tris)
const WATER_SURFACE_Y: float = -0.12  # Flat water surface level (below ford 0.14m, above riverbed -0.32m)
const VISTA_MARGIN: float = 45.0      # Out-of-bounds distance where haze reaches 100% (45.0m)
const VISTA_APRON_MIN: float = -156.0 # Far fog-locked apron min xz (covers ortho zoom 20..85 at any yaw)
const VISTA_APRON_MAX: float = 210.0  # Far fog-locked apron max xz (covers ortho zoom 20..85 at any yaw)
const FOREST_OCCUPIED_ALPHA: float = 0.35
const FOREST_LAYOUT_SEED: int = 20261031

@export var terrain_shader: Shader = DefaultTerrainShader
@export var water_shader: Shader = DefaultWaterShader
@export var texture_folder_path: String = "res://assets/terrain_textures_pack"
@export var use_pbr_textures: bool = true

## Playable grid dimensions in cells (read ONLY in _get_play_rect_world())
@export var play_cells: Vector2i = Vector2i(18, 10)

## Out-of-bounds distance fog color (default #8d897a greyish-yellow)
@export var haze_color: Color = Color("8d897a")

## Playable zone border line controls (thin pale-yellow boundary line along play_rect)
@export var show_border_line: bool = true
@export var border_line_color: Color = Color(0.92, 0.84, 0.58, 1.0)
@export_range(0.05, 0.30, 0.01) var border_line_width: float = 0.12
@export_range(0.0, 2.0, 0.05) var border_line_strength: float = 0.85

## Out-of-bounds "painted ground" controls (top-down omnidirectional cartographic texture in world UV)
@export var outer_ground_texture: Texture2D
@export var use_procedural_outer_ground: bool = true
@export var outer_ground_world_size: float = 220.0
@export_range(0.0, 1.0, 0.05) var outer_ground_strength: float = 1.0

## River water shader controls (Three Kingdoms 8R tone + 2-layer flow, sun glint, baked shore foam)
@export_range(0.0, 1.0, 0.01) var water_flow_speed: float = 0.08
@export_range(0.05, 1.0, 0.01) var water_ripple_scale: float = 0.22
@export_range(0.0, 0.5, 0.01) var water_foam_width: float = 0.16
@export var water_shallow_color: Color = Color(0.27, 0.36, 0.40, 1.0)
@export var water_deep_color: Color = Color(0.14, 0.21, 0.26, 1.0)

## 0: Regional mix (West=Style1, NE=Style2, SE=Style3), 1: Green Ridge+Crag, 2: Mossy Forest Peak, 3: Ochre Earth Rock
@export_enum("0_Regional_Mix:0", "1_Green_Ridge_Crag:1", "2_Mossy_Forest_Peak:2", "3_Ochre_Boulder:3")
var mountain_visual_style: int = 0

## Scale factor for interior mountain ridges (default 0.5 for Three Kingdoms 8R low ridges)
@export_range(0.1, 1.5, 0.05) var mountain_height_scale: float = 0.5

## Toggle 3D wooden log bridges (block 4-4: default true = the row 5 bridge over the ford only)
@export var show_bridges: bool = true
## The second bridge (row 14, scenery outside the play area): default false; on = both bridges as before
@export var show_far_bridge: bool = false

## Forest cell trees (default true: places 2~4 trees per forest cell inside playable area)
@export var scatter_inner_trees: bool = true

## Place trees on forest cells outside playable area (default false: no trees outside 18x10 playable board)
@export var forest_trees_outside_play: bool = false

## Trees per forest cell (1~3, fixed deterministic seed, >= 0.4m inside cell border, non-overlapping)
@export_range(1, 6, 1) var forest_trees_per_cell_min: int = 1
@export_range(1, 6, 1) var forest_trees_per_cell_max: int = 3

## Fade forest cell trees to alpha ~0.35 when occupied via set_forest_cell_fade(cell, fade)
@export var forest_fade_when_occupied: bool = true

## Slot for future Tripo forest tree mesh (if null, falls back to tree_mesh or built-in 156-tri oriental pine)
@export var forest_tree_mesh: Mesh
## Experiment pine500 (2026-10-27): the Tripo pine (495 tris, one material) taken from its imported GLB when no forest
## mesh is set; empty string = the old fallbacks.
const FOREST_TREE_GLB := "res://assets/battle3d/pine/pine_typeA_500tris_slim050.glb"
## T2 (2026-10-28): trees in the play area's forest groves (a grove = 4-neighbour forest cells), shared evenly between
## the groves: 32 = two groves of 16 (2-3 per cell, 32 x 495 = 15,840 triangles <= 16,000).
@export var forest_tree_count: int = 32
const GROVE_SEED := 20261028
const GROVE_MIN_SPACING := 1.2 # m between trees of one grove
const GROVE_MAX_OVERHANG := 0.5 # m a crown may reach past the grove's edge

## Toggle symbolic boundary pine clusters outside playable board (default false per Visual Pass 2)
@export var scatter_boundary_trees: bool = false

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
var procedural_outer_ground_tex: ImageTexture
var shader_material: ShaderMaterial
var water_shader_material: ShaderMaterial

var _noise_macro: FastNoiseLite
var _noise_water: FastNoiseLite
var _noise_outer_map: FastNoiseLite
var _noise_outer_detail: FastNoiseLite

var _tree_bark_mat: StandardMaterial3D
var _tree_foliage_mat: StandardMaterial3D
var _forest_cell_to_instances: Dictionary = {} # Vector2i(x, y) -> PackedInt32Array
var _faded_forest_cells: Dictionary = {}       # Vector2i(x, y) -> bool
var forest_tree_transforms: Array[Transform3D] = [] # T2: the transforms last given to the forest MultiMesh (a headless renderer does not keep them)


## Single point of truth reading `play_cells` to compute world xz play_rect (min_x, min_z, max_x, max_z)
func _get_play_rect_world() -> Vector4:
	return Vector4(0.0, 0.0, float(play_cells.x) * TILE_SIZE, float(play_cells.y) * TILE_SIZE)


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

	_noise_water = FastNoiseLite.new()
	_noise_water.seed = 20261026
	_noise_water.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	_noise_water.frequency = 0.045
	_noise_water.fractal_octaves = 2

	_noise_outer_map = FastNoiseLite.new()
	_noise_outer_map.seed = 20261027
	_noise_outer_map.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	_noise_outer_map.frequency = 0.018
	_noise_outer_map.fractal_octaves = 3

	_noise_outer_detail = FastNoiseLite.new()
	_noise_outer_detail.seed = 20261028
	_noise_outer_detail.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	_noise_outer_detail.frequency = 0.055
	_noise_outer_detail.fractal_octaves = 2

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


## Unified height formula:
## - Inside 0..60m x 0..60m: 100% identical to heightfield.json (zero change inside playable or 20x20 board)
## - Outside 0..60m x 0..60m: C1-continuous transition (d_out 0..3m flat gradient match) into gentle, broad
##   outer ridges (height difference ~4.4m to 7.5m, max slope ~13 deg so camera view is never blocked),
##   while keeping the North (z < 0) and South (z > 60) river channel and valley corridor smoothly open.
func sample_smooth_height_at_world(wx: float, wz: float) -> float:
	var board_w: float = float(GRID_W) * TILE_SIZE
	var board_h: float = float(GRID_H) * TILE_SIZE

	# Inside the 20x20 grid (0..60m x 0..60m), read directly from heightfield.json grid when at default scale
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

	# Out-of-bounds gentle, broad outer ridges (0 inside 0..60m, rises smoothly over 3..34m outside)
	var dx_out: float = maxf(0.0, maxf(-wx, wx - board_w))
	var dz_out: float = maxf(0.0, maxf(-wz, wz - board_h))
	var d_out: float = sqrt(dx_out * dx_out + dz_out * dz_out)
	if d_out > 0.0:
		var ring_rise: float = _smoothstep_f(3.0, 34.0, d_out)
		var far_settle: float = 1.0 - 0.35 * _smoothstep_f(48.0, 95.0, d_out)
		var angle: float = atan2(wz - board_h * 0.5, wx - board_w * 0.5)
		var broad_wave: float = 1.0 + 0.25 * sin(angle * 3.0 + 0.5) + 0.12 * cos(angle * 5.0 - 0.3)
		var radial_undulation: float = 0.45 * sin(d_out * 0.14 + angle * 2.0)
		var ridge_h: float = (5.4 * broad_wave + radial_undulation) * ring_rise * far_settle
		# Keep river valley corridor open where river continues North (z < 0) and South (z > 60)
		var river_corridor: float = _smoothstep_f(3.6, 15.0, absf(wx - rc))
		land += ridge_h * river_corridor

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


## Builds non-uniform 1D coordinate array for OutOfBoundsVista (coarser further out, 0 T-junctions)
func _build_vista_axis_coords(board_span: float) -> PackedFloat32Array:
	var coords := PackedFloat32Array()
	# 1) Far negative fog-locked apron (1 interval: -156.0 -> -45.0)
	coords.append(VISTA_APRON_MIN)
	# 2) Mid negative fog zone (-45.0 -> -12.0 at 3.0m step: 11 intervals)
	for i in range(11):
		coords.append(-45.0 + float(i) * 3.0)
	# 3) Near negative transition (-12.0 -> 0.0 at 1.5m step: 8 intervals)
	for i in range(8):
		coords.append(-12.0 + float(i) * 1.5)
	# 4) Board span (0.0 -> 60.0 at 1.5m step: 40 intervals)
	var board_steps: int = int(round(board_span / 1.5))
	for i in range(board_steps + 1):
		coords.append(float(i) * 1.5)
	# 5) Near positive transition (60.0 -> 72.0 at 1.5m step: 8 intervals)
	for i in range(1, 9):
		coords.append(board_span + float(i) * 1.5)
	# 6) Mid positive fog zone (72.0 -> 105.0 at 3.0m step: 11 intervals)
	for i in range(1, 12):
		coords.append(board_span + 12.0 + float(i) * 3.0)
	# 7) Far positive fog-locked apron (1 interval: 105.0 -> 210.0)
	coords.append(VISTA_APRON_MAX)
	return coords


func _emit_vista_tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, board_w: float, board_h: float) -> void:
	st.set_uv(Vector2(a.x / board_w, a.z / board_h))
	st.add_vertex(a)
	st.set_uv(Vector2(b.x / board_w, b.z / board_h))
	st.add_vertex(b)
	st.set_uv(Vector2(c.x / board_w, c.z / board_h))
	st.add_vertex(c)


## 3) Out-of-Bounds Continuous Ground & Gentle Outer Ridges ("OutOfBoundsVista")
## - Stitches 0.5m Terrain boundary vertices directly to 1.5m Vista ring (0.000000m seam step, 0 T-junctions)
## - No vertical cliff skirt and no bottom cap
## - Total triangles = 9,920 (<= 12,000 budget), no collision, cast_shadow = OFF
func _build_out_of_bounds_vista_mesh() -> void:
	var board_w: float = float(GRID_W) * TILE_SIZE
	var board_h: float = float(GRID_H) * TILE_SIZE

	var xs: PackedFloat32Array = _build_vista_axis_coords(board_w)
	var zs: PackedFloat32Array = _build_vista_axis_coords(board_h)
	var count_x: int = xs.size()
	var count_z: int = zs.size()

	var vista_h: Array = []
	vista_h.resize(count_z)
	for vz in range(count_z):
		var row_h := PackedFloat32Array()
		row_h.resize(count_x)
		var wz: float = zs[vz]
		for vx in range(count_x):
			row_h[vx] = sample_smooth_height_at_world(xs[vx], wz)
		vista_h[vz] = row_h

	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_color(Color(1.0, 1.0, 1.0, 1.0))

	for vz in range(count_z - 1):
		var z0: float = zs[vz]
		var z1: float = zs[vz + 1]
		var row0: PackedFloat32Array = vista_h[vz]
		var row1: PackedFloat32Array = vista_h[vz + 1]

		for vx in range(count_x - 1):
			var x0: float = xs[vx]
			var x1: float = xs[vx + 1]

			# Skip interior 0..60m x 0..60m cells (already covered by 28,800-tri "Terrain" mesh)
			if x0 >= -0.001 and x1 <= board_w + 0.001 and z0 >= -0.001 and z1 <= board_h + 0.001:
				continue

			var p00 := Vector3(x0, row0[vx], z0)
			var p10 := Vector3(x1, row0[vx + 1], z0)
			var p01 := Vector3(x0, row1[vx], z1)
			var p11 := Vector3(x1, row1[vx + 1], z1)

			# Stitch 0.5m Terrain perimeter vertices on the 4 inner boundary edges (zero T-junctions, 0.0m step)
			if absf(z1 - 0.0) < 0.001 and x0 >= -0.001 and x1 <= board_w + 0.001:
				# North seam (z1 == 0.0, x0..x1 = 1.5m subdivided into 3 x 0.5m segments on Terrain edge)
				var xm1: float = x0 + 0.5
				var xm2: float = x0 + 1.0
				var s1 := Vector3(xm1, sample_smooth_height_at_world(xm1, 0.0), 0.0)
				var s2 := Vector3(xm2, sample_smooth_height_at_world(xm2, 0.0), 0.0)
				_emit_vista_tri(st, p00, s1, p01, board_w, board_h)
				_emit_vista_tri(st, p00, p10, s1, board_w, board_h)
				_emit_vista_tri(st, p10, s2, s1, board_w, board_h)
				_emit_vista_tri(st, p10, p11, s2, board_w, board_h)
			elif absf(z0 - board_h) < 0.001 and x0 >= -0.001 and x1 <= board_w + 0.001:
				# South seam (z0 == 60.0, x0..x1 = 1.5m subdivided into 3 x 0.5m segments on Terrain edge)
				var xm1: float = x0 + 0.5
				var xm2: float = x0 + 1.0
				var n1 := Vector3(xm1, sample_smooth_height_at_world(xm1, board_h), board_h)
				var n2 := Vector3(xm2, sample_smooth_height_at_world(xm2, board_h), board_h)
				_emit_vista_tri(st, p00, n1, p01, board_w, board_h)
				_emit_vista_tri(st, n1, n2, p01, board_w, board_h)
				_emit_vista_tri(st, n2, p11, p01, board_w, board_h)
				_emit_vista_tri(st, n2, p10, p11, board_w, board_h)
			elif absf(x1 - 0.0) < 0.001 and z0 >= -0.001 and z1 <= board_h + 0.001:
				# West seam (x1 == 0.0, z0..z1 = 1.5m subdivided into 3 x 0.5m segments on Terrain edge)
				var zm1: float = z0 + 0.5
				var zm2: float = z0 + 1.0
				var e1 := Vector3(0.0, sample_smooth_height_at_world(0.0, zm1), zm1)
				var e2 := Vector3(0.0, sample_smooth_height_at_world(0.0, zm2), zm2)
				_emit_vista_tri(st, p00, p10, e1, board_w, board_h)
				_emit_vista_tri(st, p00, e1, p01, board_w, board_h)
				_emit_vista_tri(st, p01, e1, e2, board_w, board_h)
				_emit_vista_tri(st, p01, e2, p11, board_w, board_h)
			elif absf(x0 - board_w) < 0.001 and z0 >= -0.001 and z1 <= board_h + 0.001:
				# East seam (x0 == 60.0, z0..z1 = 1.5m subdivided into 3 x 0.5m segments on Terrain edge)
				var zm1: float = z0 + 0.5
				var zm2: float = z0 + 1.0
				var w1 := Vector3(board_w, sample_smooth_height_at_world(board_w, zm1), zm1)
				var w2 := Vector3(board_w, sample_smooth_height_at_world(board_w, zm2), zm2)
				_emit_vista_tri(st, p00, p10, w1, board_w, board_h)
				_emit_vista_tri(st, w1, p10, w2, board_w, board_h)
				_emit_vista_tri(st, w2, p10, p11, board_w, board_h)
				_emit_vista_tri(st, w2, p11, p01, board_w, board_h)
			else:
				# Standard outer quad (2 triangles)
				_emit_vista_tri(st, p00, p10, p01, board_w, board_h)
				_emit_vista_tri(st, p10, p11, p01, board_w, board_h)

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

func _sample_tileable_noise(noise: FastNoiseLite, u: float, v: float, period: float) -> float:
	var x0: float = u * period
	var y0: float = v * period
	var n00: float = noise.get_noise_2d(x0, y0)
	var n10: float = noise.get_noise_2d(x0 - period, y0)
	var n01: float = noise.get_noise_2d(x0, y0 - period)
	var n11: float = noise.get_noise_2d(x0 - period, y0 - period)
	var wx: float = _smoothstep_f(0.0, 1.0, u)
	var wy: float = _smoothstep_f(0.0, 1.0, v)
	return lerpf(lerpf(n00, n10, wx), lerpf(n01, n11, wx), wy)


## Generates a seamless 256x256 top-down omnidirectional cartographic painted terrain texture with mipmaps
func _get_or_create_procedural_outer_ground_texture() -> ImageTexture:
	if procedural_outer_ground_tex != null:
		return procedural_outer_ground_tex

	var sz: int = 256
	var period: float = 128.0
	var img := Image.create(sz, sz, false, Image.FORMAT_RGBA8)

	var col_valley := Color(0.39, 0.41, 0.33, 1.0)
	var col_plain  := Color(0.49, 0.47, 0.39, 1.0)
	var col_ochre  := Color(0.57, 0.52, 0.42, 1.0)
	var col_ridge  := Color(0.64, 0.59, 0.49, 1.0)

	for py in range(sz):
		var v: float = float(py) / float(sz)
		for px in range(sz):
			var u: float = float(px) / float(sz)
			var n_macro: float = 0.5 + 0.5 * _sample_tileable_noise(_noise_outer_map, u, v, period)
			var n_det: float = 0.5 + 0.5 * _sample_tileable_noise(_noise_outer_detail, u, v, period)
			var elev: float = clampf(n_macro * 0.74 + n_det * 0.26, 0.0, 1.0)

			# Omnidirectional (directionless) ambient occlusion / curvature shading + subtle contour rings
			var eps: float = 1.0 / float(sz)
			var e_r: float = 0.5 + 0.5 * _sample_tileable_noise(_noise_outer_map, fposmod(u + eps, 1.0), v, period)
			var e_l: float = 0.5 + 0.5 * _sample_tileable_noise(_noise_outer_map, fposmod(u - eps, 1.0), v, period)
			var e_d: float = 0.5 + 0.5 * _sample_tileable_noise(_noise_outer_map, u, fposmod(v + eps, 1.0), period)
			var e_u: float = 0.5 + 0.5 * _sample_tileable_noise(_noise_outer_map, u, fposmod(v - eps, 1.0), period)
			var slope_mag: float = sqrt(pow(e_r - e_l, 2.0) + pow(e_d - e_u, 2.0)) * 9.5
			var laplacian: float = (e_r + e_l + e_d + e_u - 4.0 * n_macro) * 14.0

			var c: Color = col_valley.lerp(col_plain, _smoothstep_f(0.20, 0.48, elev))
			c = c.lerp(col_ochre, _smoothstep_f(0.45, 0.72, elev))
			c = c.lerp(col_ridge, _smoothstep_f(0.68, 0.92, elev))

			var contour_wave: float = absf(fposmod(elev * 7.5, 1.0) - 0.5) * 2.0
			var contour_line: float = 1.0 - _smoothstep_f(0.0, 0.14, contour_wave)
			var omni_shade: float = clampf(1.0 - slope_mag * 0.14 - clampf(laplacian, -0.12, 0.12) - contour_line * 0.07, 0.78, 1.14)
			img.set_pixel(px, py, Color(clampf(c.r * omni_shade, 0.0, 1.0), clampf(c.g * omni_shade, 0.0, 1.0), clampf(c.b * omni_shade, 0.0, 1.0), 1.0))

	img.generate_mipmaps()
	procedural_outer_ground_tex = ImageTexture.create_from_image(img)
	return procedural_outer_ground_tex


func _update_outer_ground_shader_params() -> void:
	if shader_material == null:
		return
	var active_outer_tex: Texture2D = outer_ground_texture
	var enable_outer: bool = false
	if active_outer_tex != null:
		enable_outer = true
	elif use_procedural_outer_ground:
		active_outer_tex = _get_or_create_procedural_outer_ground_texture()
		enable_outer = true

	shader_material.set_shader_parameter("use_outer_ground_tex", enable_outer)
	shader_material.set_shader_parameter("outer_ground_world_size", outer_ground_world_size)
	shader_material.set_shader_parameter("outer_ground_strength", outer_ground_strength)
	if active_outer_tex != null:
		shader_material.set_shader_parameter("outer_ground_tex", active_outer_tex)


func set_outer_ground_enabled(enabled: bool) -> void:
	use_procedural_outer_ground = enabled
	if shader_material != null:
		var has_tex: bool = enabled and (outer_ground_texture != null or _get_or_create_procedural_outer_ground_texture() != null)
		shader_material.set_shader_parameter("use_outer_ground_tex", has_tex)


func _apply_terrain_shader_material() -> void:
	var play_rect_world: Vector4 = _get_play_rect_world()

	shader_material = ShaderMaterial.new()
	if terrain_shader == null:
		terrain_shader = DefaultTerrainShader
	shader_material.shader = terrain_shader
	shader_material.set_shader_parameter("grid_dimensions", Vector2(GRID_W, GRID_H))
	shader_material.set_shader_parameter("tile_world_size", TILE_SIZE)
	shader_material.set_shader_parameter("water_level_y", WATER_SURFACE_Y)
	shader_material.set_shader_parameter("vista_max_distance", VISTA_MARGIN)
	shader_material.set_shader_parameter("play_rect", play_rect_world)
	shader_material.set_shader_parameter("haze_color", Vector3(haze_color.r, haze_color.g, haze_color.b))
	shader_material.set_shader_parameter("show_border_line", show_border_line)
	shader_material.set_shader_parameter("border_line_color", border_line_color)
	shader_material.set_shader_parameter("border_line_width", border_line_width)
	shader_material.set_shader_parameter("border_line_strength", border_line_strength)
	shader_material.set_shader_parameter("terrain_control_map", control_texture)
	shader_material.set_shader_parameter("tactical_highlight_map", highlight_texture)
	shader_material.set_shader_parameter("use_pbr_textures", use_pbr_textures)
	shader_material.set_shader_parameter("mountain_visual_style", mountain_visual_style)
	_update_outer_ground_shader_params()

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

## Finds exact world X where terrain height crosses WATER_SURFACE_Y (-0.12) on West (side=-1) or East (side=+1) bank
func _find_river_shore_x(wz: float, side: float) -> float:
	var rc: float = 28.0 + 1.4 * sin(wz * 0.25)
	var x_in: float = rc + side * 1.15
	var x_out: float = rc + side * 3.45
	for _iter in range(10):
		var x_mid: float = 0.5 * (x_in + x_out)
		var h_mid: float = sample_smooth_height_at_world(x_mid, wz)
		if h_mid < WATER_SURFACE_Y:
			x_in = x_mid
		else:
			x_out = x_mid
	return 0.5 * (x_in + x_out)


## 4) Flat River Water Ribbon Mesh ("RiverWaterPlane", y = -0.12, Compatibility water shader)
## - Extends along the river channel from North out-of-bounds (-156m) through playable board to South (+210m)
## - Bakes exact riverbank shoreline distance (COLOR.r), Ford sandbar proximity (COLOR.g), and depth gradient (COLOR.b)
## - Total triangles = 4,120 (206 Z-rows x 10 X-cols x 2 tris), no depth texture required
func _build_water_plane() -> void:
	if water_mesh_instance == null:
		water_mesh_instance = MeshInstance3D.new()
		water_mesh_instance.name = "RiverWaterPlane"
		water_mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(water_mesh_instance)

	var ford_row_idx: int = 5
	if board_ref != null:
		ford_row_idx = board_ref.ford_row
	var ford_z_world: float = (float(ford_row_idx) + 0.5) * TILE_SIZE

	# Build Z slices along river: coarse in far fog apron, 1.5m in outer fog fade, 0.5m across board & near vista
	var z_slices := PackedFloat32Array()
	z_slices.append(VISTA_APRON_MIN)
	for i in range(22):
		z_slices.append(-45.0 + float(i) * 1.5)
	for i in range(157):
		z_slices.append(-12.0 + float(i) * 0.5)
	for i in range(1, 27):
		z_slices.append(66.0 + float(i) * 1.5)
	z_slices.append(VISTA_APRON_MAX)

	var nz: int = z_slices.size()
	var nx: int = 11 # col 0: under West bank, col 1: West shore, cols 2..8: open water, col 9: East shore, col 10: under East bank

	var verts: Array = []
	var uvs: Array = []
	var cols: Array = []
	verts.resize(nz)
	uvs.resize(nz)
	cols.resize(nz)

	for iz in range(nz):
		var wz: float = z_slices[iz]
		var x_west: float = _find_river_shore_x(wz, -1.0)
		var x_east: float = _find_river_shore_x(wz, 1.0)

		var d_ford_z: float = maxf(0.0, absf(wz - ford_z_world) - 1.00)
		var ford_prox_z: float = 1.0 - _smoothstep_f(0.0, 0.85, d_ford_z)

		var row_v: Array[Vector3] = []
		var row_uv: Array[Vector2] = []
		var row_c: Array[Color] = []

		for ix in range(nx):
			var wx: float = 0.0
			var u_open: float = 0.0
			var shore_dist: float = 0.0
			var vis_mask: float = 1.0

			if ix == 0:
				wx = x_west - 0.45
				u_open = 0.0
				shore_dist = 0.0
				vis_mask = 0.0
			elif ix == nx - 1:
				wx = x_east + 0.45
				u_open = 1.0
				shore_dist = 0.0
				vis_mask = 0.0
			else:
				u_open = float(ix - 1) / float(nx - 3) # 0.0 at ix=1 (West shore) .. 1.0 at ix=9 (East shore)
				wx = lerpf(x_west, x_east, u_open)
				shore_dist = 1.0 - absf(u_open * 2.0 - 1.0)
				vis_mask = 1.0

			var depth_grad: float = _smoothstep_f(0.0, 0.85, shore_dist) * (1.0 - ford_prox_z * 0.60)
			row_v.append(Vector3(wx, WATER_SURFACE_Y, wz))
			row_uv.append(Vector2(u_open, wz / TILE_SIZE))
			row_c.append(Color(shore_dist, ford_prox_z, depth_grad, vis_mask))

		verts[iz] = row_v
		uvs[iz] = row_uv
		cols[iz] = row_c

	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_normal(Vector3(0.0, 1.0, 0.0))

	for iz in range(nz - 1):
		var rv0: Array = verts[iz]
		var rv1: Array = verts[iz + 1]
		var ruv0: Array = uvs[iz]
		var ruv1: Array = uvs[iz + 1]
		var rc0: Array = cols[iz]
		var rc1: Array = cols[iz + 1]

		for ix in range(nx - 1):
			st.set_color(rc0[ix]);     st.set_uv(ruv0[ix]);     st.add_vertex(rv0[ix])
			st.set_color(rc0[ix + 1]); st.set_uv(ruv0[ix + 1]); st.add_vertex(rv0[ix + 1])
			st.set_color(rc1[ix]);     st.set_uv(ruv1[ix]);     st.add_vertex(rv1[ix])

			st.set_color(rc0[ix + 1]); st.set_uv(ruv0[ix + 1]); st.add_vertex(rv0[ix + 1])
			st.set_color(rc1[ix + 1]); st.set_uv(ruv1[ix + 1]); st.add_vertex(rv1[ix + 1])
			st.set_color(rc1[ix]);     st.set_uv(ruv1[ix]);     st.add_vertex(rv1[ix])

	var water_mesh: ArrayMesh = st.commit()
	water_mesh_instance.mesh = water_mesh
	water_mesh_instance.position = Vector3.ZERO

	var play_rect_world: Vector4 = _get_play_rect_world()
	water_shader_material = ShaderMaterial.new()
	if water_shader == null:
		water_shader = DefaultWaterShader
	water_shader_material.shader = water_shader
	water_shader_material.set_shader_parameter("play_rect", play_rect_world)
	water_shader_material.set_shader_parameter("vista_max_distance", VISTA_MARGIN)
	water_shader_material.set_shader_parameter("haze_color", Vector3(haze_color.r, haze_color.g, haze_color.b))
	water_shader_material.set_shader_parameter("show_border_line", show_border_line)
	water_shader_material.set_shader_parameter("border_line_color", border_line_color)
	water_shader_material.set_shader_parameter("border_line_width", border_line_width)
	water_shader_material.set_shader_parameter("border_line_strength", border_line_strength)
	water_shader_material.set_shader_parameter("water_flow_speed", water_flow_speed)
	water_shader_material.set_shader_parameter("water_ripple_scale", water_ripple_scale)
	water_shader_material.set_shader_parameter("water_foam_width", water_foam_width)
	water_shader_material.set_shader_parameter("water_shallow_color", water_shallow_color)
	water_shader_material.set_shader_parameter("water_deep_color", water_deep_color)

	var ripple_tex := NoiseTexture2D.new()
	ripple_tex.seamless = true
	ripple_tex.noise = _noise_water
	water_shader_material.set_shader_parameter("ripple_noise_tex", ripple_tex)

	water_mesh_instance.material_override = water_shader_material


## 5) Optional 3D Wooden Log Bridges (block 4-4: default the row 5 bridge; show_far_bridge adds row 14)
func _rebuild_all_wooden_log_bridges() -> void:
	if bridges_root != null:
		bridges_root.queue_free()
	bridges_root = Node3D.new()
	bridges_root.name = "WoodenLogBridges"
	add_child(bridges_root)

	if not show_bridges:
		return

	for bridge_row in ([5.5, 14.5] if show_far_bridge else [5.5]):
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

func _lcg_next(state: int) -> int:
	return (state * 1103515245 + 12345) & 0x7fffffff


## Deterministic 2~4 tree layout inside a single 3.0m x 3.0m forest cell:
## - Every tree is at least 0.48m (>= 0.40m requirement) inside the cell border
## - Minimum inter-tree distance >= 0.85m (non-overlapping, airy B-style spacing)
## - Scale 0.85..1.15 (±15% around 3.45m base height -> 2.93m..3.97m <= 4.0m max height)
func _generate_cell_tree_placements(cell_x: int, cell_y: int) -> Array[Dictionary]:
	var min_t: int = mini(forest_trees_per_cell_min, forest_trees_per_cell_max)
	var max_t: int = maxi(forest_trees_per_cell_min, forest_trees_per_cell_max)
	var span: int = maxi(1, max_t - min_t + 1)

	var st: int = ((cell_x * 73856093) ^ (cell_y * 19349663) ^ FOREST_LAYOUT_SEED) & 0x7fffffff
	st = _lcg_next(st)
	var count: int = min_t + ((st >> 11) % span)

	var margin: float = 0.48
	var min_dist: float = 0.85
	var placed: Array[Dictionary] = []

	for i in range(count):
		var chosen_ok: bool = false
		var chosen_lx: float = 1.5
		var chosen_lz: float = 1.5
		for _attempt in range(32):
			st = _lcg_next(st)
			var rx: float = float(st) / float(0x7fffffff)
			st = _lcg_next(st)
			var rz: float = float(st) / float(0x7fffffff)
			var lx: float = margin + rx * (TILE_SIZE - 2.0 * margin)
			var lz: float = margin + rz * (TILE_SIZE - 2.0 * margin)
			var ok: bool = true
			for prev in placed:
				if Vector2(lx - float(prev["lx"]), lz - float(prev["lz"])).length() < min_dist:
					ok = false
					break
			if ok:
				chosen_lx = lx
				chosen_lz = lz
				chosen_ok = true
				break

		if not chosen_ok:
			placed.clear()
			st = _lcg_next(st)
			var base_ang: float = (float(st) / float(0x7fffffff)) * TAU
			for j in range(count):
				st = _lcg_next(st)
				var r_jit: float = float(st) / float(0x7fffffff)
				st = _lcg_next(st)
				var a_jit: float = float(st) / float(0x7fffffff)
				var ang: float = base_ang + float(j) * (TAU / float(count)) + (a_jit - 0.5) * 0.35
				var rad: float = 0.68 + r_jit * 0.22
				var lx_f: float = 1.5 + cos(ang) * rad
				var lz_f: float = 1.5 + sin(ang) * rad
				st = _lcg_next(st)
				var sc_f: float = 0.85 + (float(st) / float(0x7fffffff)) * 0.30
				st = _lcg_next(st)
				var yaw_f: float = (float(st) / float(0x7fffffff)) * TAU
				placed.append({"lx": lx_f, "lz": lz_f, "scale": sc_f, "yaw": yaw_f})
			break

		st = _lcg_next(st)
		var sc: float = 0.85 + (float(st) / float(0x7fffffff)) * 0.30
		st = _lcg_next(st)
		var yaw: float = (float(st) / float(0x7fffffff)) * TAU
		placed.append({"lx": chosen_lx, "lz": chosen_lz, "scale": sc, "yaw": yaw})

	return placed


## 6) Forest Cell Trees & Optional Symbolic Boundary Trees ("SymbolicBoundaryTrees")
## - scatter_boundary_trees defaults to FALSE (no trees outside board)
## - forest_trees_outside_play defaults to FALSE (only places trees on the 24 forest cells inside 18x10 play zone)
## - Single MultiMeshInstance3D with cast_shadow = ON, no collision, per-instance COLOR alpha for occupation fade
func _scatter_symbolic_boundary_trees() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 20261026
	var tree_transforms: Array[Transform3D] = []
	var tree_colors: Array[Color] = []
	_forest_cell_to_instances.clear()

	var board_w: float = float(GRID_W) * TILE_SIZE
	var play_rect_world: Vector4 = _get_play_rect_world()

	# 1) Optional boundary clusters outside the board (default OFF: scatter_boundary_trees = false)
	if scatter_boundary_trees:
		var cluster_1_count: int = 38
		for i in range(cluster_1_count):
			var row_f: float = float(i) / float(cluster_1_count - 1)
			var wx: float = -1.4 - rng.randf_range(0.4, 7.8)
			var wz: float = lerpf(12.0, 33.0, row_f) + rng.randf_range(-0.9, 0.9)
			var wy: float = sample_smooth_height_at_world(wx, wz)
			var sc: float = rng.randf_range(0.85, 1.15)
			var tree_basis := Basis.from_euler(Vector3(0.0, rng.randf_range(0.0, TAU), 0.0)).scaled(Vector3(sc, sc, sc))
			tree_transforms.append(Transform3D(tree_basis, Vector3(wx, wy, wz)))
			tree_colors.append(Color(1.0, 1.0, 1.0, 1.0))

		var cluster_2_count: int = 38
		for i in range(cluster_2_count):
			var row_f: float = float(i) / float(cluster_2_count - 1)
			var wx: float = board_w + 1.4 + rng.randf_range(0.4, 7.8)
			var wz: float = lerpf(1.0, 14.5, row_f) + rng.randf_range(-0.8, 0.8)
			var wy: float = sample_smooth_height_at_world(wx, wz)
			var sc: float = rng.randf_range(0.85, 1.15)
			var tree_basis := Basis.from_euler(Vector3(0.0, rng.randf_range(0.0, TAU), 0.0)).scaled(Vector3(sc, sc, sc))
			tree_transforms.append(Transform3D(tree_basis, Vector3(wx, wy, wz)))
			tree_colors.append(Color(1.0, 1.0, 1.0, 1.0))

	if forest_tree_mesh == null and not FOREST_TREE_GLB.is_empty():
		forest_tree_mesh = _mesh_from_glb(FOREST_TREE_GLB)
	var chosen_mesh: Mesh = forest_tree_mesh
	if chosen_mesh == null:
		chosen_mesh = tree_mesh
	if chosen_mesh == null:
		chosen_mesh = _create_oriental_pine_cluster_mesh()

	# 2) Forest trees (default ON: scatter_inner_trees = true). T2: the play area's forest cells are planted as groves
	# (_grove_tree_placements); forest cells outside the play area keep the per-cell placement, only with
	# forest_trees_outside_play.
	if scatter_inner_trees:
		var play_forest: Array[Vector2i] = []
		for y in range(GRID_H):
			for x in range(GRID_W):
				if terrain_grid[y][x] == TerrainType.FOREST and overlay_grid[y][x] != OverlayType.CHARRED and _cell_in_play(x, y, play_rect_world):
					play_forest.append(Vector2i(x, y))
		var groves := _forest_groves(play_forest)
		var grove_placements: Dictionary = {}
		for g in range(groves.size()):
			var share: int = forest_tree_count / groves.size() + (1 if g < forest_tree_count % groves.size() else 0)
			grove_placements.merge(_grove_tree_placements(groves[g], share, mesh_crown_radius(chosen_mesh)))
		for y in range(GRID_H):
			for x in range(GRID_W):
				if terrain_grid[y][x] != TerrainType.FOREST or overlay_grid[y][x] == OverlayType.CHARRED:
					continue
				var in_play: bool = _cell_in_play(x, y, play_rect_world)
				if not in_play and not forest_trees_outside_play:
					continue

				var cell_coord := Vector2i(x, y)
				var is_faded: bool = forest_fade_when_occupied and _faded_forest_cells.get(cell_coord, false)
				var alpha_val: float = FOREST_OCCUPIED_ALPHA if is_faded else 1.0
				var inst_indices := PackedInt32Array()

				var placements: Array = grove_placements.get(cell_coord, []) if in_play else _generate_cell_tree_placements(x, y)
				for item in placements:
					var wx: float = float(x) * TILE_SIZE + float(item["lx"])
					var wz: float = float(y) * TILE_SIZE + float(item["lz"])
					var wy: float = board_ref.height(wx, wz) if board_ref != null else sample_smooth_height_at_world(wx, wz)
					var sc: float = float(item["scale"])
					var yaw: float = float(item["yaw"])
					var tree_basis := Basis.from_euler(Vector3(0.0, yaw, 0.0)).scaled(Vector3(sc, sc, sc))
					var idx: int = tree_transforms.size()
					inst_indices.append(idx)
					tree_transforms.append(Transform3D(tree_basis, Vector3(wx, wy, wz)))
					tree_colors.append(Color(1.0, 1.0, 1.0, alpha_val))

				_forest_cell_to_instances[cell_coord] = inst_indices

	if forest_multimesh == null:
		forest_multimesh = MultiMeshInstance3D.new()
		forest_multimesh.name = "SymbolicBoundaryTrees"
		add_child(forest_multimesh)
	forest_multimesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON

	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	mm.mesh = chosen_mesh
	mm.instance_count = tree_transforms.size()
	for idx in range(tree_transforms.size()):
		mm.set_instance_transform(idx, tree_transforms[idx])
		mm.set_instance_color(idx, tree_colors[idx])
	forest_multimesh.multimesh = mm
	forest_tree_transforms = tree_transforms.duplicate()
	_sync_tree_material_transparency_mode()


func _cell_in_play(x: int, y: int, play_rect_world: Vector4) -> bool:
	var cx: float = (float(x) + 0.5) * TILE_SIZE
	var cz: float = (float(y) + 0.5) * TILE_SIZE
	return cx >= play_rect_world.x and cx <= play_rect_world.z and cz >= play_rect_world.y and cz <= play_rect_world.w


## T2: the furthest any vertex of `mesh` reaches from its vertical axis (the crown radius at scale 1, any yaw).
static func mesh_crown_radius(mesh: Mesh) -> float:
	var r := 0.0
	for s in range(mesh.get_surface_count()):
		for v in (mesh.surface_get_arrays(s)[Mesh.ARRAY_VERTEX] as PackedVector3Array):
			r = maxf(r, Vector2(v.x, v.z).length())
	return r


## T2: `cells` split into groves (4-neighbour groups), each sorted by row then column; groves in the order of their
## first cell.
static func _forest_groves(cells: Array[Vector2i]) -> Array:
	var left := {}
	for c in cells:
		left[c] = true
	var order := cells.duplicate()
	order.sort_custom(func(a, b): return a.y < b.y or (a.y == b.y and a.x < b.x))
	var groves := []
	for start in order:
		if not left.has(start):
			continue
		var grove: Array[Vector2i] = []
		var todo: Array[Vector2i] = [start]
		left.erase(start)
		while not todo.is_empty():
			var c: Vector2i = todo.pop_back()
			grove.append(c)
			for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				if left.has(c + d):
					left.erase(c + d)
					todo.append(c + d)
		grove.sort_custom(func(a, b): return a.y < b.y or (a.y == b.y and a.x < b.x))
		groves.append(grove)
	return groves


## T2: `count` trees for one grove, cell -> [{lx, lz, scale, yaw}] in cell-local metres (fixed seed from the grove's
## first cell: the same grove always gets the same trees). Every cell gets count / cells trees, the first
## count % cells cells of a seeded shuffle one more. A tree stands inside its cell; where the cell's side is the grove's
## edge its crown (crown_radius x scale) reaches at most GROVE_MAX_OVERHANG past it. Trees of the grove are
## GROVE_MIN_SPACING apart (the best of 64 tries when no try fits).
static func _grove_tree_placements(grove: Array[Vector2i], count: int, crown_radius: float) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = GROVE_SEED ^ (grove[0].x * 73856093) ^ (grove[0].y * 19349663)
	var in_grove := {}
	for c in grove:
		in_grove[c] = true
	var order: Array = range(grove.size())
	for i in range(order.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var t: int = order[i]
		order[i] = order[j]
		order[j] = t
	var per_cell := {}
	for k in range(order.size()):
		per_cell[grove[order[k]]] = count / grove.size() + (1 if k < count % grove.size() else 0)
	var out := {}
	var placed: Array[Vector2] = []
	for c in grove:
		var items: Array[Dictionary] = []
		for n in range(per_cell[c]):
			var sc := rng.randf_range(0.85, 1.15)
			var yaw := rng.randf_range(0.0, TAU)
			var edge := maxf(0.05, crown_radius * sc - GROVE_MAX_OVERHANG)
			var lo := Vector2(0.05 if in_grove.has(c + Vector2i(-1, 0)) else edge, 0.05 if in_grove.has(c + Vector2i(0, -1)) else edge)
			var hi := Vector2(TILE_SIZE - (0.05 if in_grove.has(c + Vector2i(1, 0)) else edge), TILE_SIZE - (0.05 if in_grove.has(c + Vector2i(0, 1)) else edge))
			var best := Vector2.ZERO
			var best_gap := -1.0
			for attempt in range(64):
				var local := Vector2(rng.randf_range(lo.x, hi.x), rng.randf_range(lo.y, hi.y))
				var world := Vector2(c) * TILE_SIZE + local
				var gap := INF
				for p in placed:
					gap = minf(gap, world.distance_to(p))
				if gap > best_gap:
					best = local
					best_gap = gap
				if gap >= GROVE_MIN_SPACING:
					break
			placed.append(Vector2(c) * TILE_SIZE + best)
			items.append({"lx": best.x, "lz": best.y, "scale": sc, "yaw": yaw})
		out[c] = items
	return out


## Experiment pine500: the first MeshInstance3D's mesh of an imported GLB scene (its own surface material kept).
static func _mesh_from_glb(path: String) -> Mesh:
	var scene := load(path) as PackedScene
	if scene == null:
		return null
	var root := scene.instantiate()
	var found := root.find_children("*", "MeshInstance3D", true, false)
	var mesh: Mesh = (found[0] as MeshInstance3D).mesh if not found.is_empty() else null
	root.free()
	return mesh


## Sets or clears semi-transparency (alpha ~0.35) on all trees belonging to `cell`.
## When no cells are faded (alpha == 1.0 everywhere), tree materials stay in TRANSPARENCY_DISABLED
## so they render 100% identically to standard opaque trees.
func set_forest_cell_fade(cell: Vector2i, fade: bool) -> void:
	if fade:
		_faded_forest_cells[cell] = true
	else:
		_faded_forest_cells.erase(cell)

	_sync_tree_material_transparency_mode()

	if forest_multimesh == null or forest_multimesh.multimesh == null:
		return
	if not _forest_cell_to_instances.has(cell):
		return

	var effective_fade: bool = fade and forest_fade_when_occupied
	var target_alpha: float = FOREST_OCCUPIED_ALPHA if effective_fade else 1.0
	var indices: PackedInt32Array = _forest_cell_to_instances[cell]
	for idx in indices:
		if idx >= 0 and idx < forest_multimesh.multimesh.instance_count:
			forest_multimesh.multimesh.set_instance_color(idx, Color(1.0, 1.0, 1.0, target_alpha))


## Helper for preview testing (F key): toggles fade on all active forest cells at once
func set_all_forest_cells_fade(fade: bool) -> void:
	if not fade:
		_faded_forest_cells.clear()
	else:
		for cell_key in _forest_cell_to_instances.keys():
			_faded_forest_cells[cell_key] = true

	_sync_tree_material_transparency_mode()

	if forest_multimesh == null or forest_multimesh.multimesh == null:
		return
	var effective_fade: bool = fade and forest_fade_when_occupied
	var target_alpha: float = FOREST_OCCUPIED_ALPHA if effective_fade else 1.0
	for cell_key in _forest_cell_to_instances.keys():
		var indices: PackedInt32Array = _forest_cell_to_instances[cell_key]
		for idx in indices:
			if idx >= 0 and idx < forest_multimesh.multimesh.instance_count:
				forest_multimesh.multimesh.set_instance_color(idx, Color(1.0, 1.0, 1.0, target_alpha))


func _sync_tree_material_transparency_mode() -> void:
	var any_faded: bool = forest_fade_when_occupied and not _faded_forest_cells.is_empty()
	var mode: BaseMaterial3D.Transparency = (
		BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS if any_faded else BaseMaterial3D.TRANSPARENCY_DISABLED
	)
	if _tree_bark_mat != null:
		_tree_bark_mat.transparency = mode
	if _tree_foliage_mat != null:
		_tree_foliage_mat.transparency = mode


## Low-poly Oriental Pine Mesh:
## - Base height = 3.45m (~3.5m); with ±15% instance scale (0.85..1.15), height is 2.93m..3.97m (strictly <= 4.0m)
## - Compact canopy radius (<= 0.68m) so trees never overhang into adjacent cells or block adjacent units
## - 156 triangles per tree (<= 200 budget): Surface 0 trunk (12 tris) + Surface 1 3-tier canopy (144 tris)
func _create_oriental_pine_cluster_mesh() -> ArrayMesh:
	_tree_bark_mat = StandardMaterial3D.new()
	_tree_bark_mat.albedo_color = Color(0.45, 0.31, 0.22, 1.0)
	_tree_bark_mat.roughness = 0.90
	_tree_bark_mat.vertex_color_use_as_albedo = true
	_tree_bark_mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	var bark_alb: String = texture_folder_path.path_join("11_tree_bark_trunk_albedo.png")
	var bark_nrm: String = texture_folder_path.path_join("11_tree_bark_trunk_normal.png")
	if ResourceLoader.exists(bark_alb):
		_tree_bark_mat.albedo_texture = load(bark_alb)
	if ResourceLoader.exists(bark_nrm):
		_tree_bark_mat.normal_enabled = true
		_tree_bark_mat.normal_texture = load(bark_nrm)

	_tree_foliage_mat = StandardMaterial3D.new()
	_tree_foliage_mat.albedo_color = Color(0.36, 0.50, 0.29, 1.0)
	_tree_foliage_mat.roughness = 0.86
	_tree_foliage_mat.vertex_color_use_as_albedo = true
	_tree_foliage_mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	var fol_alb: String = texture_folder_path.path_join("10_pine_foliage_canopy_albedo.png")
	var fol_nrm: String = texture_folder_path.path_join("10_pine_foliage_canopy_normal.png")
	if ResourceLoader.exists(fol_alb):
		_tree_foliage_mat.albedo_texture = load(fol_alb)
	if ResourceLoader.exists(fol_nrm):
		_tree_foliage_mat.normal_enabled = true
		_tree_foliage_mat.normal_texture = load(fol_nrm)

	var final_mesh := ArrayMesh.new()

	# Surface 0: 6-sided tapered trunk (6 quads = 12 triangles, height 1.65m)
	var st_trunk := SurfaceTool.new()
	st_trunk.begin(Mesh.PRIMITIVE_TRIANGLES)
	st_trunk.set_material(_tree_bark_mat)
	st_trunk.set_color(Color(1.0, 1.0, 1.0, 1.0))
	var trunk_seg: int = 6
	var r_bot: float = 0.15
	var r_top: float = 0.08
	var h_trunk: float = 1.65
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
	# Top crown reaches 2.91 + 0.54 = 3.45m (~3.5m base height; max scaled = 3.45 * 1.15 = 3.9675m <= 4.0m)
	var st_canopy := SurfaceTool.new()
	st_canopy.begin(Mesh.PRIMITIVE_TRIANGLES)
	st_canopy.set_material(_tree_foliage_mat)
	st_canopy.set_color(Color(1.0, 1.0, 1.0, 1.0))

	_append_octagonal_canopy_pad(st_canopy, Vector3(-0.16, 1.72, 0.10), 0.66, 0.46)
	_append_octagonal_canopy_pad(st_canopy, Vector3(0.18, 2.28, -0.08), 0.58, 0.44)
	_append_octagonal_canopy_pad(st_canopy, Vector3(0.0, 2.91, 0.0), 0.64, 0.54)

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
