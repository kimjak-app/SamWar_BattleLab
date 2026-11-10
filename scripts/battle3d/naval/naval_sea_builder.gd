extends Node3D
# Queue 35: the sea board for a naval 3D battle, in place of terrain_board_builder.gd (the lab's `field_script`).
# Everything comes from the lab's board (lab_heightfield.gd, already reading the naval scenario's files): sea is height 0,
# islands rise inside their own cells. Built once in _ready:
# - "Terrain": the heightfield mesh. The lab gives it the ground collision (clicks, like the land board); only its
#   islands are drawn (the sea part is discarded by its shader).
# - "Sea": one flat water surface at height 0 over the board and far past it, drawn with the land board's river shader
#   (eastwar_terrain_20x20_water.gdshader: ripples, shore foam, the play area's border line, the haze outside).
# - light trees on the islands (one MultiMesh) and a few far island silhouettes outside the board.
# No gameplay rule lives here: the cells no ship may enter are the board's "island" cells (the lab hands them to the engine).
const WaterShader = preload("res://scripts/battle3d/eastwar_terrain_20x20_water.gdshader")
const SEA_APRON_MIN := -156.0 # = the land builder's vista apron
const SEA_APRON_MAX := 210.0
const VISTA_MARGIN := 45.0
const SHORE_REACH := 2.4 # m of shallow water (foam, lighter colour) around an island
const TREE_SEED := 20261110
const TREES_PER_CELL := 2
const TREE_MIN_HEIGHT := 0.7 # m of island height a tree needs under it
const TREE_MAX_OUTSIDE := 14.0 # m past the play area: farther islands are bare (they fade into the haze)
const FAR_ISLANDS := [ # [x, z, radius, height] outside the board (m)
	[-24.0, 6.0, 9.0, 4.5], [-18.0, 30.0, 6.0, 3.0], [30.0, -22.0, 11.0, 5.5], [58.0, -16.0, 7.0, 3.5],
	[82.0, 12.0, 10.0, 5.0], [78.0, 44.0, 8.0, 4.0], [-22.0, 62.0, 10.0, 5.0], [36.0, 84.0, 14.0, 6.0]]
const ISLAND_SHADER := """shader_type spatial;
render_mode cull_disabled, diffuse_burley, specular_disabled;
uniform vec4 play_rect = vec4(0.0, 0.0, 54.0, 30.0);
uniform vec3 haze_color : source_color = vec3(0.5529, 0.5373, 0.4784);
uniform float vista_max_distance = 45.0;
uniform float sea_cut = 0.015;
varying vec3 world_pos;
void vertex() { world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; }
void fragment() {
	if (world_pos.y < sea_cut) { discard; }
	vec2 lo = max(play_rect.xy - world_pos.xz, vec2(0.0));
	vec2 hi = max(world_pos.xz - play_rect.zw, vec2(0.0));
	float haze = smoothstep(2.5, max(3.0, vista_max_distance), length(lo + hi));
	ALBEDO = pow(COLOR.rgb, vec3(2.2)) * (1.0 - haze); // vertex colours are written as sRGB
	ROUGHNESS = 1.0;
	EMISSION = haze_color * haze;
}
"""

# The lab sets these two on its ground builder (lab_presentation.gd); the sea has no painted outer ground.
var outer_ground_texture: Texture2D
var play_cells := Vector2i(18, 10)
var haze_color := Color("8d897a") # = the lab's sky colour
var water_shallow_color := Color(0.25, 0.40, 0.46)
var water_deep_color := Color(0.10, 0.21, 0.30)
var board_ref = null
var terrain_mesh_instance: MeshInstance3D
var sea_mesh_instance: MeshInstance3D
var tree_multimesh: MultiMeshInstance3D
var tree_transforms: Array[Transform3D] = [] # kept for checks (a headless renderer does not keep them)
var far_islands := Node3D.new()

func setup_from_board(p_board) -> void:
	board_ref = p_board

func _ready() -> void:
	if board_ref == null: return
	_build_terrain()
	_build_sea()
	_build_trees()
	_build_far_islands()

func play_rect() -> Vector4:
	return Vector4(0, 0, play_cells.x * board_ref.CELL, play_cells.y * board_ref.CELL)

func _island_color(h: float, x: float, z: float) -> Color:
	var grain := 0.5 + 0.5 * sin(x * 2.3 + z * 1.7) * sin(x * 0.7 - z * 3.1)
	var sand := Color(0.66, 0.60, 0.44).lerp(Color(0.58, 0.52, 0.40), grain)
	var grass := Color(0.30, 0.40, 0.23).lerp(Color(0.37, 0.45, 0.26), grain)
	var rock := Color(0.42, 0.40, 0.36).lerp(Color(0.50, 0.47, 0.41), grain)
	if h < 0.22: return sand
	if h < 0.55: return sand.lerp(grass, (h - 0.22) / 0.33)
	if h < 2.6: return grass
	return grass.lerp(rock, clampf((h - 2.6) / 1.2, 0.0, 1.0))

func _build_terrain() -> void:
	# The heightfield's own triangles (lab_heightfield.height splits each 0.5 m square the same way), so the collision the
	# lab adds is the surface the units stand on.
	var heights: Array = board_ref.data.heights
	var step := float(board_ref.data.step)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for j in range(heights.size() - 1):
		for i in range((heights[j] as Array).size() - 1):
			var corners := [Vector2i(i, j), Vector2i(i + 1, j), Vector2i(i, j + 1), Vector2i(i + 1, j), Vector2i(i + 1, j + 1), Vector2i(i, j + 1)]
			for corner in corners:
				var h := float(heights[corner.y][corner.x])
				st.set_color(_island_color(h, corner.x * step, corner.y * step))
				st.add_vertex(Vector3(corner.x * step, h, corner.y * step))
	st.generate_normals()
	terrain_mesh_instance = MeshInstance3D.new()
	terrain_mesh_instance.name = "Terrain" # the lab's ground collision goes to the mesh with this name
	terrain_mesh_instance.mesh = st.commit()
	var shader := Shader.new()
	shader.code = ISLAND_SHADER
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("play_rect", play_rect())
	material.set_shader_parameter("haze_color", Vector3(haze_color.r, haze_color.g, haze_color.b))
	material.set_shader_parameter("vista_max_distance", VISTA_MARGIN)
	terrain_mesh_instance.material_override = material
	add_child(terrain_mesh_instance)

func shore_distance(x: float, z: float) -> float:
	# Distance (m, up to SHORE_REACH) from a sea point to the nearest island ground, on the heightfield's own samples.
	var heights: Array = board_ref.data.heights
	var step := float(board_ref.data.step)
	var ci := roundi(x / step)
	var cj := roundi(z / step)
	var reach := int(ceil(SHORE_REACH / step))
	var best := SHORE_REACH
	for j in range(maxi(cj - reach, 0), mini(cj + reach, heights.size() - 1) + 1):
		var row: Array = heights[j]
		for i in range(maxi(ci - reach, 0), mini(ci + reach, row.size() - 1) + 1):
			if float(row[i]) > 0.02: best = minf(best, Vector2(i * step - x, j * step - z).length())
	return best

func _sea_vertex(st: SurfaceTool, x: float, z: float, shore: float) -> void:
	# The river shader's baked colour: R shore distance (0 at the shore), G ford (none), B depth, A visible.
	var near := clampf(shore / SHORE_REACH, 0.0, 1.0)
	st.set_color(Color(near, 0.0, near, 1.0))
	st.set_uv(Vector2(x / 6.0, z * 0.8)) # the river shader scales U by 2.2 and V by 0.55: even ripples about 3 m across
	st.set_normal(Vector3.UP)
	st.add_vertex(Vector3(x, 0.0, z))

func _build_sea() -> void:
	var extent_x: float = float(board_ref.SIZE.x) * board_ref.CELL
	var extent_z: float = float(board_ref.SIZE.y) * board_ref.CELL
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	# Over the board: 1 m squares with the shore distance baked in (foam around the islands).
	var nx := int(extent_x)
	var nz := int(extent_z)
	var shore := []
	for j in range(nz + 1):
		var row := PackedFloat32Array()
		for i in range(nx + 1): row.append(shore_distance(float(i), float(j)))
		shore.append(row)
	for j in range(nz):
		for i in range(nx):
			for corner in [Vector2i(i, j), Vector2i(i + 1, j), Vector2i(i, j + 1), Vector2i(i + 1, j), Vector2i(i + 1, j + 1), Vector2i(i, j + 1)]:
				_sea_vertex(st, float(corner.x), float(corner.y), shore[corner.y][corner.x])
	# Past the board: open water out to the haze (8 large pieces around the board).
	var xs := [SEA_APRON_MIN, 0.0, extent_x, SEA_APRON_MAX]
	var zs := [SEA_APRON_MIN, 0.0, extent_z, SEA_APRON_MAX]
	for j in range(3):
		for i in range(3):
			if i == 1 and j == 1: continue
			var pieces := 12 # 12 x 12 squares a piece, so the ripples' UVs stay even
			for b in range(pieces):
				for a in range(pieces):
					var x0: float = lerpf(xs[i], xs[i + 1], float(a) / pieces)
					var x1: float = lerpf(xs[i], xs[i + 1], float(a + 1) / pieces)
					var z0: float = lerpf(zs[j], zs[j + 1], float(b) / pieces)
					var z1: float = lerpf(zs[j], zs[j + 1], float(b + 1) / pieces)
					for corner in [Vector2(x0, z0), Vector2(x1, z0), Vector2(x0, z1), Vector2(x1, z0), Vector2(x1, z1), Vector2(x0, z1)]:
						_sea_vertex(st, corner.x, corner.y, SHORE_REACH)
	sea_mesh_instance = MeshInstance3D.new()
	sea_mesh_instance.name = "Sea"
	sea_mesh_instance.mesh = st.commit()
	sea_mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var material := ShaderMaterial.new()
	material.shader = WaterShader
	material.set_shader_parameter("play_rect", play_rect())
	material.set_shader_parameter("vista_max_distance", VISTA_MARGIN)
	material.set_shader_parameter("haze_color", Vector3(haze_color.r, haze_color.g, haze_color.b))
	material.set_shader_parameter("show_border_line", true)
	material.set_shader_parameter("water_flow_speed", 0.035)
	material.set_shader_parameter("water_ripple_scale", 0.22)
	material.set_shader_parameter("water_foam_width", 0.16)
	material.set_shader_parameter("water_shallow_color", water_shallow_color)
	material.set_shader_parameter("water_deep_color", water_deep_color)
	var noise := FastNoiseLite.new()
	noise.seed = TREE_SEED
	noise.frequency = 0.02
	var ripple := NoiseTexture2D.new()
	ripple.width = 256
	ripple.height = 256
	ripple.seamless = true
	ripple.noise = noise
	material.set_shader_parameter("ripple_noise_tex", ripple)
	sea_mesh_instance.material_override = material
	add_child(sea_mesh_instance)

func _cone(st: SurfaceTool, base: Vector3, radius: float, height: float, color: Color, sides := 6) -> void:
	for k in range(sides):
		var a0 := TAU * k / sides
		var a1 := TAU * (k + 1) / sides
		st.set_color(color)
		st.add_vertex(base + Vector3(0, height, 0))
		st.set_color(color.darkened(0.25))
		st.add_vertex(base + Vector3(cos(a1) * radius, 0, sin(a1) * radius))
		st.set_color(color.darkened(0.25))
		st.add_vertex(base + Vector3(cos(a0) * radius, 0, sin(a0) * radius))

func _tree_mesh() -> ArrayMesh:
	# A light pine: a trunk and two crown cones, 18 triangles.
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	_cone(st, Vector3.ZERO, 0.07, 0.6, Color(0.30, 0.22, 0.15))
	_cone(st, Vector3(0, 0.3, 0), 0.34, 0.6, Color(0.18, 0.30, 0.18))
	_cone(st, Vector3(0, 0.62, 0), 0.24, 0.55, Color(0.21, 0.34, 0.20))
	st.generate_normals()
	return st.commit()

func _build_trees() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = TREE_SEED
	tree_transforms.clear()
	var rect := play_rect()
	for y in range(board_ref.SIZE.y):
		for x in range(board_ref.SIZE.x):
			if board_ref.terrain(Vector2i(x, y)) != "island": continue
			for n in range(TREES_PER_CELL):
				var px: float = (x + rng.randf_range(0.2, 0.8)) * board_ref.CELL
				var pz: float = (y + rng.randf_range(0.2, 0.8)) * board_ref.CELL
				var h: float = board_ref.height(px, pz)
				var size := rng.randf_range(0.8, 1.25)
				var turn := rng.randf() * TAU
				if h < TREE_MIN_HEIGHT or pz > rect.w + TREE_MAX_OUTSIDE or px > rect.z + TREE_MAX_OUTSIDE: continue # none in the haze
				tree_transforms.append(Transform3D(Basis(Vector3.UP, turn).scaled(Vector3.ONE * size), Vector3(px, h - 0.05, pz)))
	var multimesh := MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = _tree_mesh()
	multimesh.instance_count = tree_transforms.size()
	for index in range(tree_transforms.size()): multimesh.set_instance_transform(index, tree_transforms[index])
	tree_multimesh = MultiMeshInstance3D.new()
	tree_multimesh.name = "IslandTrees"
	tree_multimesh.multimesh = multimesh
	var material := StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	material.vertex_color_is_srgb = true
	material.roughness = 1.0
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	tree_multimesh.material_override = material
	add_child(tree_multimesh)

func _build_far_islands() -> void:
	# Silhouettes in the haze: low cones in a colour already mixed toward the haze by their distance from the play area.
	far_islands.name = "FarIslands"
	add_child(far_islands)
	var rect := play_rect()
	for entry in FAR_ISLANDS:
		var center := Vector3(entry[0], 0, entry[1])
		var outside := Vector2(maxf(maxf(rect.x - center.x, center.x - rect.z), 0.0), maxf(maxf(rect.y - center.z, center.z - rect.w), 0.0)).length()
		var haze := smoothstep(2.5, VISTA_MARGIN, outside)
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		_cone(st, Vector3.ZERO, float(entry[2]), float(entry[3]), Color(0.27, 0.34, 0.24).lerp(haze_color, haze), 10)
		_cone(st, Vector3(float(entry[2]) * 0.55, 0, float(entry[2]) * 0.2), float(entry[2]) * 0.6, float(entry[3]) * 0.6, Color(0.30, 0.36, 0.26).lerp(haze_color, haze), 8)
		st.generate_normals()
		var island := MeshInstance3D.new()
		island.mesh = st.commit()
		island.position = center
		island.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var material := StandardMaterial3D.new()
		material.vertex_color_use_as_albedo = true
		material.vertex_color_is_srgb = true
		material.roughness = 1.0
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
		material.emission_enabled = haze > 0.0
		material.emission = haze_color * haze * 0.5
		island.material_override = material
		far_islands.add_child(island)
