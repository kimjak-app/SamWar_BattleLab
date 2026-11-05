## EASTWAR WorldMap3D -> game layer: 3D replacement for WorldMapCameraController (same public API, so
## worldmap_main.gd can use it unchanged). Drives a WorldMap3DCamera (worldmap3d/scripts/worldmap_camera.gd) that runs
## in external_input mode: main forwards its input here and this class translates it into the camera's apply_* calls.
## The 3D camera is held in an UNTYPED var on purpose: this file lives under scripts/ (2D game, C-track CI, mobile
## export) and must not name classes from worldmap3d/, which those builds exclude.
class_name WorldMap3DCameraController
extends WorldMapCameraController

const BATTLE_ENTRY_ZOOM_3D := 0.85

var _cam3d = null                 # WorldMap3DCamera (untyped, see header)
var input_blocked := false        # main sets true while a modal / the tech tree is open (blocks keyboard axes)
var skip_battle_entry_camera := false   # true = no battle-entry camera move (tests / emergency); the battle still starts
## T-WM3D-07: main's battle-entry focus (2D world position) -> 3D ground coordinate (km). The host connects the
## adapter here. Not valid, or returning a non-finite point (Vector2.INF) = no camera move, continue at once.
var focus_converter := Callable()


func configure_3d(camera3d, debug_label: Label, viewport_owner: Node) -> void:
	_cam3d = camera3d
	_debug_label = debug_label
	_viewport_owner = viewport_owner
	if _cam3d != null:
		_cam3d.external_input = true
	update_debug_label()


func process_camera(_delta: float) -> void:
	if _cam3d != null:
		var pan := Vector2.ZERO
		var yaw_dir := 0.0
		if not _battle_entry_handoff_in_progress and not _is_keyboard_camera_blocked():
			pan = Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down"))
			if Input.is_physical_key_pressed(KEY_A): pan.x -= 1
			if Input.is_physical_key_pressed(KEY_D): pan.x += 1
			if Input.is_physical_key_pressed(KEY_W): pan.y -= 1
			if Input.is_physical_key_pressed(KEY_S): pan.y += 1
			if Input.is_physical_key_pressed(KEY_Q): yaw_dir += 1.0
			if Input.is_physical_key_pressed(KEY_E): yaw_dir -= 1.0
		_cam3d.set_external_axes(pan, yaw_dir)
	update_debug_label()


func handle_unhandled_input(event: InputEvent) -> bool:
	if _battle_entry_handoff_in_progress:
		if is_battle_entry_handoff_skip_event(event):
			skip_battle_entry_handoff()
		return true
	if _cam3d == null:
		return false
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_WHEEL_UP and mb.pressed:
			_cam3d.apply_wheel(1)
			return true
		if mb.button_index == MOUSE_BUTTON_WHEEL_DOWN and mb.pressed:
			_cam3d.apply_wheel(-1)
			return true
		if mb.button_index == MOUSE_BUTTON_LEFT:
			_cam3d.apply_left_button(mb.position, mb.pressed)
			return false
		if mb.button_index == MOUSE_BUTTON_MIDDLE or mb.button_index == MOUSE_BUTTON_RIGHT:
			_is_dragging = mb.pressed
			_cam3d.apply_drag_button(mb.button_index, mb.pressed)
			return true
	elif event is InputEventMouseMotion and _is_dragging:
		_cam3d.apply_drag_motion((event as InputEventMouseMotion).relative)
		return true
	return false


func start_battle_entry_handoff(focus_position: Vector2, continue_callable: Callable) -> bool:
	if _battle_entry_handoff_in_progress or not continue_callable.is_valid():
		return false
	if _cam3d == null or skip_battle_entry_camera or not focus_converter.is_valid():
		continue_callable.call()
		return false
	var converted = focus_converter.call(focus_position)
	if not (converted is Vector2) or not (converted as Vector2).is_finite():
		continue_callable.call()
		return false
	var focus3d: Vector2 = converted
	_battle_entry_handoff_in_progress = true
	_battle_entry_handoff_completed = false
	_battle_entry_handoff_continue_callable = continue_callable
	_is_dragging = false
	_cam3d.set_external_axes(Vector2.ZERO, 0.0)
	_cam3d.apply_drag_button(MOUSE_BUTTON_MIDDLE, false)
	_cam3d.apply_drag_button(MOUSE_BUTTON_RIGHT, false)
	var target_zoom := maxf(float(_cam3d.zoom_goal), BATTLE_ENTRY_ZOOM_3D)
	_battle_entry_handoff_target_position = focus3d   # skip_battle_entry_handoff() jumps here (3D coordinate)
	_battle_entry_handoff_target_zoom = Vector2(target_zoom, target_zoom)
	_cam3d.set_view(focus3d, target_zoom, rad_to_deg(_cam3d.yaw_goal), false)
	_battle_entry_handoff_tween = create_tween()
	_battle_entry_handoff_tween.tween_interval(BATTLE_ENTRY_PAN_SEC + BATTLE_ENTRY_HOLD_SEC)
	_battle_entry_handoff_tween.tween_callback(_complete_battle_entry_handoff)
	return true


func skip_battle_entry_handoff() -> void:
	if not _battle_entry_handoff_in_progress:
		return
	if _battle_entry_handoff_tween != null:
		_battle_entry_handoff_tween.kill()
		_battle_entry_handoff_tween = null
	if _cam3d != null:
		_cam3d.set_view(_battle_entry_handoff_target_position, _battle_entry_handoff_target_zoom.x, rad_to_deg(_cam3d.yaw_goal), true)
	_complete_battle_entry_handoff()


func apply_zoom(zoom_delta: float) -> void:
	if _cam3d == null:
		return
	_cam3d.apply_wheel(1 if zoom_delta > 0.0 else -1)


func clamp_to_world() -> void:
	pass   # the 3D camera's fill_clamp keeps the screen inside the map on every frame


func get_clamped_position_for_zoom(target_position: Vector2, _zoom: Vector2) -> Vector2:
	return target_position


func update_debug_label() -> void:
	if _cam3d == null or _debug_label == null:
		return
	_debug_label.text = "Camera3D: (%.0f, %.0f) km  Zoom: %.2f  Yaw: %.0f°  [입력 %s]" % [
		_cam3d.target.x, _cam3d.target.y, _cam3d.zoom, rad_to_deg(_cam3d.yaw), _cam3d.input_scheme]


func get_world_rect() -> Rect2:
	if _cam3d == null:
		return Rect2()
	return Rect2(-_cam3d.map_half, _cam3d.map_half * 2.0)


func _is_keyboard_camera_blocked() -> bool:
	return input_blocked or super()
