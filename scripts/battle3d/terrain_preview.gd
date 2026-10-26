extends Node3D
## EASTWAR 20x20 지형 이식 확인용 단독 미리보기 장면 (Godot 4.6, F6 실행용)
## - 전투 엔진, HUD, 시나리오 셸을 전혀 사용하지 않는 순수 시각 확인용 스크립트입니다.
## - 기존 파일은 한 줄도 수정하지 않고 terrain_board_builder.gd 와 lab_heightfield.gd 만 불러옵니다.

const Board = preload("res://scripts/battle3d/lab_heightfield.gd")
const TerrainBuilder = preload("res://scripts/battle3d/terrain_board_builder.gd")

const PREVIEW_UNITS: Array[Dictionary] = [
	{"unit_id": "lab_ally_01", "side": "ally", "unit_type": "infantry", "current_troops": 3200, "grid_cell": Vector2i(3, 5)},
	{"unit_id": "lab_ally_02", "side": "ally", "unit_type": "cavalry", "current_troops": 1800, "grid_cell": Vector2i(4, 2)},
	{"unit_id": "lab_enemy_01", "side": "enemy", "unit_type": "infantry", "current_troops": 2800, "grid_cell": Vector2i(14, 6)},
	{"unit_id": "lab_enemy_02", "side": "enemy", "unit_type": "cavalry", "current_troops": 1600, "grid_cell": Vector2i(15, 2)}
]

var board = Board.new()
var field: Node3D
var camera := Camera3D.new()
var focus := Vector3.ZERO
var yaw := 0.32
var zoom := 60.0
var views: Dictionary = {}
var soldiers: Dictionary = {}
var status_label: Label
var captures := 0
var trees_enabled := true


func _ready() -> void:
	DisplayServer.window_set_title("EASTWAR | 20x20 Terrain Preview (F6 Standalone)")
	focus = Vector3(board.SIZE.x * board.CELL * 0.5, 0.0, board.SIZE.y * board.CELL * 0.5)

	# 1. 3D 지형 생성 (terrain_board_builder.gd)
	field = TerrainBuilder.new()
	field.name = "Battlefield"
	field.setup_from_board(board)
	add_child(field)
	trees_enabled = bool(field.scatter_boundary_trees) or bool(field.scatter_inner_trees)

	# 2. 조명·환경·그림자 설정 (lab_presentation.gd와 동일한 값)
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color("18232e")
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color("c7d8e4")
	env.environment.ambient_light_energy = 0.35
	env.environment.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	add_child(env)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55, -30, 0)
	sun.light_energy = 0.8
	sun.shadow_enabled = true
	sun.shadow_bias = 0.08
	sun.shadow_normal_bias = 1.2
	sun.directional_shadow_max_distance = 100
	add_child(sun)

	# 3. 직교 카메라 설정 (lab_presentation.gd와 동일한 투영/거리)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.far = 200
	camera.current = true
	add_child(camera)
	_update_camera()

	# 4. 기존 랩 유닛 4개 배치 (lab_presentation.gd와 동일한 대형 및 접지)
	for u in PREVIEW_UNITS:
		_spawn_unit(u)

	# 5. 좌상단 소형 상태 표시 UI
	_build_overlay_ui()
	_refresh_overlay_text()


func _material(color: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.85
	return m


func _disc(radius: float, color: Color, depth: float) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = depth
	mesh.radial_segments = 48
	n.mesh = mesh
	n.material_override = _material(color)
	return n


func _spawn_unit(u: Dictionary) -> void:
	var root := Node3D.new()
	root.name = u.unit_id
	root.position = board.world(u.grid_cell)
	add_child(root)
	views[u.unit_id] = root
	soldiers[u.unit_id] = []

	var cavalry: bool = u.unit_type == "cavalry"
	var model: PackedScene = load("res://assets/battle3d/%s_%s.glb" % [u.side, u.unit_type])
	for row in range(2):
		for col in range(3):
			var soldier = model.instantiate()
			root.add_child(soldier)
			soldier.position = Vector3((col - 1) * 0.65, 0.0, (row - 0.5) * (0.95 if cavalry else 0.7))
			soldiers[u.unit_id].append(soldier)

	var base := _disc(1.05, Color("286496") if u.side == "ally" else Color("a3402a"), 0.04)
	root.add_child(base)
	base.position.y = 0.035

	var label := Label3D.new()
	label.text = "%s  |  %s\n%s" % [u.unit_id, u.unit_type, u.current_troops]
	label.font_size = 48
	label.pixel_size = 0.009
	label.position = Vector3(0.0, 2.5, 0.0)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	root.add_child(label)

	_ground_soldiers(u.unit_id)


func _ground_soldiers(id: String) -> void:
	for s in soldiers[id]:
		var p: Vector3 = s.global_position
		s.global_position.y = board.height(p.x, p.z) + 0.035


func _build_overlay_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	var panel := PanelContainer.new()
	panel.position = Vector2(16, 16)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.035, 0.065, 0.09, 0.88)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	style.border_width_left = 3
	style.border_color = Color("e4b862")
	panel.add_theme_stylebox_override("panel", style)
	layer.add_child(panel)

	status_label = Label.new()
	status_label.add_theme_font_size_override("font_size", 14)
	status_label.modulate = Color("e8eff5")
	panel.add_child(status_label)


func _refresh_overlay_text(extra_msg: String = "") -> void:
	if status_label == null or field == null:
		return
	var text := "EASTWAR 20x20 지형 미리보기 (F6)\n"
	text += "mountain_height_scale: %.2f  |  show_bridges: %s  |  scatter_inner_trees: %s  |  나무 켜짐: %s\n" % [
		float(field.mountain_height_scale),
		"ON" if field.show_bridges else "OFF",
		"ON" if field.scatter_inner_trees else "OFF",
		"ON" if trees_enabled else "OFF"
	]
	text += "[WASD/방향키] 이동   [Q/E] 90° 회전   [휠] 확대/축소   [1] 정면  [2] 90°  [3] 강·여울   [T] 나무 켜기/끄기   [B] 다리 켜기/끄기   [F12] 화면 저장"
	if not extra_msg.is_empty():
		text += "\n" + extra_msg
	status_label.text = text


func _update_camera() -> void:
	camera.size = zoom
	camera.position = focus + Vector3(sin(yaw) * 43.0, 40.0, cos(yaw) * 43.0)
	camera.look_at(focus)


func _process(delta: float) -> void:
	var pan := Vector2(
		float(Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT)) - float(Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT)),
		float(Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN)) - float(Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP))
	)
	if pan.length() > 0.0:
		focus += Vector3(pan.x * cos(yaw) + pan.y * sin(yaw), 0.0, -pan.x * sin(yaw) + pan.y * cos(yaw)) * delta * zoom * 0.45
		focus.x = clampf(focus.x, -12.0, board.SIZE.x * board.CELL + 12.0)
		focus.z = clampf(focus.z, -12.0, board.SIZE.y * board.CELL + 12.0)
		_update_camera()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom = clampf(zoom + (-3.0 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 3.0), 18.0, 85.0)
			_update_camera()
	elif event is InputEventMouseMotion:
		if event.button_mask & MOUSE_BUTTON_MASK_MIDDLE:
			yaw -= event.relative.x * 0.008
			_update_camera()
	elif event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_Q:
				yaw += PI * 0.5
				_update_camera()
			KEY_E:
				yaw -= PI * 0.5
				_update_camera()
			KEY_1, KEY_KP_1:
				# 1번: 정면 기본 시점
				focus = Vector3(board.SIZE.x * board.CELL * 0.5, 0.0, board.SIZE.y * board.CELL * 0.5)
				yaw = 0.32
				zoom = 60.0
				_update_camera()
			KEY_2, KEY_KP_2:
				# 2번: 90도 회전 시점
				focus = Vector3(board.SIZE.x * board.CELL * 0.5, 0.0, board.SIZE.y * board.CELL * 0.5)
				yaw = 0.32 + PI * 0.5
				zoom = 60.0
				_update_camera()
			KEY_3, KEY_KP_3:
				# 3번: 강·여울 및 능선 근처 클로즈업 시점
				focus = Vector3(board.river_center, 0.0, (board.ford_row + 0.5) * board.CELL)
				yaw = 0.32
				zoom = 32.0
				_update_camera()
			KEY_T:
				# T: 나무 켜기/끄기
				trees_enabled = not trees_enabled
				field.scatter_boundary_trees = trees_enabled
				field._scatter_symbolic_boundary_trees()
				if field.forest_multimesh != null:
					field.forest_multimesh.visible = trees_enabled
				_refresh_overlay_text()
			KEY_B:
				# B: 통나무 다리 켜기/끄기
				field.show_bridges = not field.show_bridges
				field._rebuild_all_wooden_log_bridges()
				_refresh_overlay_text()
			KEY_F12:
				_capture()


func _capture() -> void:
	await RenderingServer.frame_post_draw
	captures += 1
	var dir_path := ProjectSettings.globalize_path("res://").path_join("../EASTWAR_C0C3_Evidence").simplify_path()
	DirAccess.make_dir_recursive_absolute(dir_path)
	var path := dir_path.path_join("godot_preview_%d_%02d.png" % [OS.get_process_id(), captures])
	get_viewport().get_texture().get_image().save_png(path)
	print(JSON.stringify({"event": "screenshot", "path": path}))
	_refresh_overlay_text("Saved: " + path)
