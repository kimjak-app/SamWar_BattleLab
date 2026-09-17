class_name WorldMapCameraController
extends Node


const CAMERA_SPEED := 900.0
const CAMERA_DRAG_SPEED := 1.0
const MIN_ZOOM := 0.35
const MAX_ZOOM := 1.6
const CLAMP_PADDING := 24.0
const ZOOM_STEP := 0.1
const BATTLE_ENTRY_PAN_SEC := 0.55
const BATTLE_ENTRY_ZOOM_SEC := 0.45
const BATTLE_ENTRY_HOLD_SEC := 0.15
const BATTLE_ENTRY_TARGET_ZOOM := Vector2(1.35, 1.35)

var _camera: Camera2D = null
var _debug_label: Label = null
var _viewport_owner: Node = null
var _world_rect := Rect2()
var _is_dragging := false
var _battle_entry_handoff_in_progress := false
var _battle_entry_handoff_completed := false
var _battle_entry_handoff_continue_callable := Callable()
var _battle_entry_handoff_tween: Tween = null
var _battle_entry_handoff_target_position := Vector2.ZERO
var _battle_entry_handoff_target_zoom := Vector2.ZERO


func configure(camera: Camera2D, debug_label: Label, viewport_owner: Node, world_tiles: Array[Sprite2D]) -> void:
	_camera = camera
	_debug_label = debug_label
	_viewport_owner = viewport_owner
	_refresh_world_rect(world_tiles)
	if _camera == null:
		return
	_camera.enabled = true
	_camera.make_current()
	_camera.zoom = Vector2(0.7, 0.7)
	_camera.position = _world_rect.get_center()
	clamp_to_world()
	update_debug_label()


func process_camera(delta: float) -> void:
	if _battle_entry_handoff_in_progress:
		update_debug_label()
		return
	_handle_keyboard_pan(delta)
	update_debug_label()


func handle_unhandled_input(event: InputEvent) -> bool:
	if _battle_entry_handoff_in_progress:
		if is_battle_entry_handoff_skip_event(event):
			skip_battle_entry_handoff()
		return true
	if _camera == null:
		return false
	if event is InputEventMouseButton:
		var mouse_button_event := event as InputEventMouseButton
		if mouse_button_event.button_index == MOUSE_BUTTON_MIDDLE or mouse_button_event.button_index == MOUSE_BUTTON_RIGHT:
			_is_dragging = mouse_button_event.pressed
			return true
		if mouse_button_event.pressed and mouse_button_event.button_index == MOUSE_BUTTON_WHEEL_UP:
			apply_zoom(ZOOM_STEP)
			return true
		if mouse_button_event.pressed and mouse_button_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			apply_zoom(-ZOOM_STEP)
			return true
	elif event is InputEventMouseMotion and _is_dragging:
		var mouse_motion_event := event as InputEventMouseMotion
		_camera.position -= mouse_motion_event.relative / _camera.zoom * CAMERA_DRAG_SPEED
		clamp_to_world()
		return true
	return false


func start_battle_entry_handoff(focus_position: Vector2, continue_callable: Callable) -> bool:
	if _battle_entry_handoff_in_progress or not continue_callable.is_valid():
		return false
	if _camera == null:
		continue_callable.call()
		return false
	_battle_entry_handoff_in_progress = true
	_battle_entry_handoff_completed = false
	_battle_entry_handoff_continue_callable = continue_callable
	var target_zoom_value := clampf(maxf(_camera.zoom.x, BATTLE_ENTRY_TARGET_ZOOM.x), MIN_ZOOM, MAX_ZOOM)
	_battle_entry_handoff_target_zoom = Vector2(target_zoom_value, target_zoom_value)
	_battle_entry_handoff_target_position = get_clamped_position_for_zoom(focus_position, _battle_entry_handoff_target_zoom)
	_battle_entry_handoff_tween = create_tween()
	_battle_entry_handoff_tween.set_parallel(true)
	_battle_entry_handoff_tween.tween_property(_camera, "position", _battle_entry_handoff_target_position, BATTLE_ENTRY_PAN_SEC).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_battle_entry_handoff_tween.tween_property(_camera, "zoom", _battle_entry_handoff_target_zoom, BATTLE_ENTRY_ZOOM_SEC).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_battle_entry_handoff_tween.set_parallel(false)
	_battle_entry_handoff_tween.tween_interval(BATTLE_ENTRY_HOLD_SEC)
	_battle_entry_handoff_tween.tween_callback(_complete_battle_entry_handoff)
	return true


func skip_battle_entry_handoff() -> void:
	if not _battle_entry_handoff_in_progress:
		return
	if _battle_entry_handoff_tween != null:
		_battle_entry_handoff_tween.kill()
		_battle_entry_handoff_tween = null
	if _camera != null:
		_camera.position = _battle_entry_handoff_target_position
		if _battle_entry_handoff_target_zoom != Vector2.ZERO:
			_camera.zoom = _battle_entry_handoff_target_zoom
		clamp_to_world()
	_complete_battle_entry_handoff()


func is_battle_entry_handoff_in_progress() -> bool:
	return _battle_entry_handoff_in_progress


func is_battle_entry_handoff_skip_event(event: InputEvent) -> bool:
	if event is InputEventKey:
		var key_event := event as InputEventKey
		return key_event.pressed and not key_event.echo and [KEY_SPACE, KEY_ENTER, KEY_KP_ENTER, KEY_ESCAPE].has(key_event.keycode)
	if event is InputEventMouseButton:
		var mouse_button_event := event as InputEventMouseButton
		return mouse_button_event.pressed and mouse_button_event.button_index == MOUSE_BUTTON_LEFT
	return false


func apply_zoom(zoom_delta: float) -> void:
	if _camera == null:
		return
	var next_zoom_value := clampf(_camera.zoom.x + zoom_delta, MIN_ZOOM, MAX_ZOOM)
	_camera.zoom = Vector2(next_zoom_value, next_zoom_value)
	clamp_to_world()


func clamp_to_world() -> void:
	if _camera == null:
		return
	_camera.position = get_clamped_position_for_zoom(_camera.position, _camera.zoom)


func get_clamped_position_for_zoom(target_position: Vector2, zoom: Vector2) -> Vector2:
	if _world_rect.size == Vector2.ZERO:
		return target_position
	var viewport_size := _get_viewport_size()
	var safe_zoom := Vector2(maxf(zoom.x, 0.001), maxf(zoom.y, 0.001))
	var half_visible_size := viewport_size / (safe_zoom * 2.0)
	var min_center := _world_rect.position + half_visible_size - Vector2.ONE * CLAMP_PADDING
	var max_center := _world_rect.end - half_visible_size + Vector2.ONE * CLAMP_PADDING
	var clamped_x := target_position.x
	var clamped_y := target_position.y
	if min_center.x > max_center.x:
		clamped_x = _world_rect.get_center().x
	else:
		clamped_x = clampf(target_position.x, min_center.x, max_center.x)
	if min_center.y > max_center.y:
		clamped_y = _world_rect.get_center().y
	else:
		clamped_y = clampf(target_position.y, min_center.y, max_center.y)
	return Vector2(clamped_x, clamped_y)


func update_debug_label() -> void:
	if _camera == null or _debug_label == null:
		return
	_debug_label.text = "Camera: (%.1f, %.1f)  Zoom: %.2f" % [_camera.position.x, _camera.position.y, _camera.zoom.x]


func get_world_rect() -> Rect2:
	return _world_rect


func _handle_keyboard_pan(delta: float) -> void:
	if _camera == null:
		return
	var input_vector := Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		input_vector.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		input_vector.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		input_vector.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		input_vector.y += 1.0
	if input_vector == Vector2.ZERO:
		return
	_camera.position += input_vector.normalized() * CAMERA_SPEED * delta / _camera.zoom.x
	clamp_to_world()


func _refresh_world_rect(world_tiles: Array[Sprite2D]) -> void:
	var tile_rects: Array[Rect2] = []
	for tile in world_tiles:
		var tile_rect := _get_tile_world_rect(tile)
		if tile_rect.size != Vector2.ZERO:
			tile_rects.append(tile_rect)
	if tile_rects.is_empty():
		push_warning("WorldMap tile rects are unavailable; using fallback camera clamp rect.")
		_world_rect = Rect2(Vector2.ZERO, Vector2(1024.0, 1024.0))
		return
	_world_rect = tile_rects[0]
	for tile_rect_index in range(1, tile_rects.size()):
		_world_rect = _world_rect.merge(tile_rects[tile_rect_index])


func _get_tile_world_rect(tile: Sprite2D) -> Rect2:
	if tile == null or tile.texture == null:
		return Rect2()
	var texture_size := tile.texture.get_size()
	var local_top_left := Vector2.ZERO
	if tile.centered:
		local_top_left = -texture_size * 0.5
	var local_corners: Array[Vector2] = [
		local_top_left,
		local_top_left + Vector2(texture_size.x, 0.0),
		local_top_left + Vector2(0.0, texture_size.y),
		local_top_left + texture_size,
	]
	var world_points: Array[Vector2] = []
	for local_corner in local_corners:
		world_points.append(tile.to_global(local_corner))
	var min_point := world_points[0]
	var max_point := world_points[0]
	for point_index in range(1, world_points.size()):
		min_point = min_point.min(world_points[point_index])
		max_point = max_point.max(world_points[point_index])
	return Rect2(min_point, max_point - min_point)


func _get_viewport_size() -> Vector2:
	if _viewport_owner != null:
		return _viewport_owner.get_viewport().get_visible_rect().size
	return get_viewport().get_visible_rect().size


func _complete_battle_entry_handoff() -> void:
	if _battle_entry_handoff_completed:
		return
	_battle_entry_handoff_completed = true
	var continue_callable := _battle_entry_handoff_continue_callable
	_battle_entry_handoff_in_progress = false
	_battle_entry_handoff_continue_callable = Callable()
	_battle_entry_handoff_tween = null
	if continue_callable.is_valid():
		continue_callable.call()
