extends Node2D

const WORLD_MAP_CAMERA_SPEED := 900.0
const WORLD_MAP_CAMERA_DRAG_SPEED := 1.0
const WORLD_MAP_MIN_ZOOM := 0.35
const WORLD_MAP_MAX_ZOOM := 1.6
const WORLD_MAP_CLAMP_PADDING := 24.0
const WORLD_MAP_ZOOM_STEP := 0.1

@onready var tile_a1_top_left: Sprite2D = $WorldMapRoot/WorldMapTileLayer/Tile_A1_TopLeft
@onready var tile_a2_top_right: Sprite2D = $WorldMapRoot/WorldMapTileLayer/Tile_A2_TopRight
@onready var tile_b1_bottom_left: Sprite2D = $WorldMapRoot/WorldMapTileLayer/Tile_B1_BottomLeft
@onready var tile_b2_bottom_right: Sprite2D = $WorldMapRoot/WorldMapTileLayer/Tile_B2_BottomRight
@onready var world_map_camera: Camera2D = $WorldMapCamera
@onready var camera_debug_label: Label = $WorldMapUI/CameraDebugLabel

var _world_rect := Rect2()
var _is_dragging := false


func _ready() -> void:
	_configure_tiles()
	_configure_camera()
	_update_camera_debug_label()


func _process(delta: float) -> void:
	_handle_keyboard_pan(delta)
	_update_camera_debug_label()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_button_event := event as InputEventMouseButton
		if mouse_button_event.button_index == MOUSE_BUTTON_MIDDLE or mouse_button_event.button_index == MOUSE_BUTTON_RIGHT:
			_is_dragging = mouse_button_event.pressed
			get_viewport().set_input_as_handled()
		elif mouse_button_event.pressed and mouse_button_event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_apply_zoom(WORLD_MAP_ZOOM_STEP)
			get_viewport().set_input_as_handled()
		elif mouse_button_event.pressed and mouse_button_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_apply_zoom(-WORLD_MAP_ZOOM_STEP)
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and _is_dragging:
		var mouse_motion_event := event as InputEventMouseMotion
		world_map_camera.position -= mouse_motion_event.relative / world_map_camera.zoom * WORLD_MAP_CAMERA_DRAG_SPEED
		_clamp_camera_to_world()
		get_viewport().set_input_as_handled()


func _configure_tiles() -> void:
	var tile_size := _get_primary_tile_size()
	tile_a1_top_left.centered = false
	tile_a2_top_right.centered = false
	tile_b1_bottom_left.centered = false
	tile_b2_bottom_right.centered = false
	tile_a1_top_left.position = Vector2.ZERO
	tile_a2_top_right.position = Vector2(tile_size.x, 0.0)
	tile_b1_bottom_left.position = Vector2(0.0, tile_size.y)
	tile_b2_bottom_right.position = tile_size
	_world_rect = Rect2(Vector2.ZERO, tile_size * 2.0)


func _configure_camera() -> void:
	world_map_camera.enabled = true
	world_map_camera.make_current()
	world_map_camera.zoom = Vector2(0.7, 0.7)
	world_map_camera.position = _world_rect.get_center()
	_clamp_camera_to_world()


func _handle_keyboard_pan(delta: float) -> void:
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

	world_map_camera.position += input_vector.normalized() * WORLD_MAP_CAMERA_SPEED * delta / world_map_camera.zoom.x
	_clamp_camera_to_world()


func _apply_zoom(zoom_delta: float) -> void:
	var next_zoom_value := clampf(world_map_camera.zoom.x + zoom_delta, WORLD_MAP_MIN_ZOOM, WORLD_MAP_MAX_ZOOM)
	world_map_camera.zoom = Vector2(next_zoom_value, next_zoom_value)
	_clamp_camera_to_world()


func _clamp_camera_to_world() -> void:
	if _world_rect.size == Vector2.ZERO:
		return

	var viewport_size := get_viewport_rect().size
	var half_visible_size := viewport_size / (world_map_camera.zoom * 2.0)
	var min_center := _world_rect.position + half_visible_size - Vector2.ONE * WORLD_MAP_CLAMP_PADDING
	var max_center := _world_rect.end - half_visible_size + Vector2.ONE * WORLD_MAP_CLAMP_PADDING

	var clamped_x := world_map_camera.position.x
	var clamped_y := world_map_camera.position.y
	if min_center.x > max_center.x:
		clamped_x = _world_rect.get_center().x
	else:
		clamped_x = clampf(world_map_camera.position.x, min_center.x, max_center.x)

	if min_center.y > max_center.y:
		clamped_y = _world_rect.get_center().y
	else:
		clamped_y = clampf(world_map_camera.position.y, min_center.y, max_center.y)

	world_map_camera.position = Vector2(clamped_x, clamped_y)


func _get_primary_tile_size() -> Vector2:
	if tile_a1_top_left.texture == null:
		push_warning("WorldMap tile A1 texture is missing; using fallback layout size.")
		return Vector2(1024.0, 1024.0)
	return tile_a1_top_left.texture.get_size()


func _update_camera_debug_label() -> void:
	camera_debug_label.text = "Camera: %s  Zoom: %.2f" % [
		_format_vector2(world_map_camera.position),
		world_map_camera.zoom.x,
	]


func _format_vector2(value: Vector2) -> String:
	return "(%.0f, %.0f)" % [value.x, value.y]
