class_name WorldMapTurnCompass
extends TextureRect

const COMPASS_BASE_TEXTURE: Texture2D = preload("res://assets/worldmap/ui/worldmap_turn_compass_base.png")
const COMPASS_NEEDLE_TEXTURE: Texture2D = preload("res://assets/worldmap/ui/worldmap_turn_compass_needle.png")
const COMPASS_CAP_TEXTURE: Texture2D = preload("res://assets/worldmap/ui/worldmap_turn_compass_cap.png")
const COMPASS_SIZE := Vector2(240.0, 240.0)
const RIGHT_MARGIN_RATIO := 0.0625
const BOTTOM_MARGIN_RATIO := 0.111111
const MIN_EDGE_MARGIN := 48.0
const SPIN_DURATION_SEC := 1.60
const TURN_END_BUTTON_PATH := "WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/WildArmyEditButtonPlaceholder"
const MAX_INSTALL_ATTEMPTS := 6

var _world_scene: Node = null
var _turn_end_button: Button = null
var _spin_tween: Tween = null
var _base_layer: TextureRect = null
var _needle_layer: TextureRect = null
var _cap_layer: TextureRect = null
var _original_pressed_callbacks: Array[Callable] = []
var _pressed_wrapper_installed := false
var _install_attempts := 0
var _serializing_turn_end := false


func _ready() -> void:
	# This node is a fixed 240x240 container. The three source PNGs all share the
	# same 1024x1024 canvas, so identical child rects preserve perfect alignment.
	texture = null
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = COMPASS_SIZE
	size = COMPASS_SIZE
	pivot_offset = COMPASS_SIZE * 0.5
	rotation = 0.0
	z_index = 20

	_build_compass_layers()

	var viewport := get_viewport()
	if viewport != null and not viewport.size_changed.is_connected(_layout_compass):
		viewport.size_changed.connect(_layout_compass)
	call_deferred("_layout_compass")


func _build_compass_layers() -> void:
	_base_layer = _create_layer("Base", COMPASS_BASE_TEXTURE)
	add_child(_base_layer)

	_needle_layer = _create_layer("Needle", COMPASS_NEEDLE_TEXTURE)
	_needle_layer.pivot_offset = COMPASS_SIZE * 0.5
	_needle_layer.rotation = 0.0
	add_child(_needle_layer)

	_cap_layer = _create_layer("Cap", COMPASS_CAP_TEXTURE)
	add_child(_cap_layer)


func _create_layer(layer_name: String, layer_texture: Texture2D) -> TextureRect:
	var layer := TextureRect.new()
	layer.name = layer_name
	layer.texture = layer_texture
	layer.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	layer.stretch_mode = TextureRect.STRETCH_SCALE
	layer.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.position = Vector2.ZERO
	layer.size = COMPASS_SIZE
	layer.custom_minimum_size = Vector2.ZERO
	return layer


func bind_world_scene(world_scene: Node) -> void:
	_world_scene = world_scene
	if _world_scene == null:
		return

	var button := _world_scene.get_node_or_null(TURN_END_BUTTON_PATH) as Button
	if button == null:
		return

	if _turn_end_button != button:
		_turn_end_button = button
		_pressed_wrapper_installed = false
		_original_pressed_callbacks.clear()
		_install_attempts = 0

	# City markers can ask the background helper to bind before the WorldMap root
	# finishes _ready(). Install on deferred idle so the original turn-end pressed
	# callback already exists, then wrap that callback instead of racing it.
	if not _pressed_wrapper_installed:
		call_deferred("_install_pressed_wrapper")
	call_deferred("_layout_compass")


func _install_pressed_wrapper() -> void:
	if _pressed_wrapper_installed:
		return
	if _turn_end_button == null or not is_instance_valid(_turn_end_button):
		return

	var wrapper := Callable(self, "_on_turn_button_pressed_serialized")
	var connections := _turn_end_button.pressed.get_connections()
	var captured: Array[Callable] = []

	for connection in connections:
		var callback: Callable = connection.get("callable", Callable())
		if not callback.is_valid() or callback == wrapper:
			continue
		captured.append(callback)

	# If the parent WorldMap script has not connected its handler yet, wait a little
	# longer rather than installing an empty wrapper that the real callback bypasses.
	if captured.is_empty() and _install_attempts < MAX_INSTALL_ATTEMPTS:
		_install_attempts += 1
		call_deferred("_install_pressed_wrapper")
		return

	_original_pressed_callbacks = captured
	for callback in _original_pressed_callbacks:
		if callback.is_valid() and _turn_end_button.pressed.is_connected(callback):
			_turn_end_button.pressed.disconnect(callback)

	if not _turn_end_button.pressed.is_connected(wrapper):
		_turn_end_button.pressed.connect(wrapper)
	_pressed_wrapper_installed = true


func _on_turn_button_pressed_serialized() -> void:
	if _serializing_turn_end:
		return
	if _turn_end_button == null or not is_instance_valid(_turn_end_button):
		return

	var button_text := _turn_end_button.text.strip_edges()
	var is_actual_turn_end := (
		not _turn_end_button.disabled
		and button_text.contains("턴 종료")
		and not button_text.contains("편집")
	)

	# The same scene button is reused for non-turn-end modes. Preserve those modes
	# exactly by forwarding their original pressed callbacks immediately.
	if not is_actual_turn_end:
		_invoke_original_pressed_callbacks()
		return

	_serializing_turn_end = true
	_turn_end_button.disabled = true

	# Preserve the proven ordering contract: one uninterrupted visual revolution
	# finishes first, then the existing turn-end / enemy-turn processing begins.
	await _play_one_revolution_async()

	if _turn_end_button != null and is_instance_valid(_turn_end_button):
		_turn_end_button.disabled = false
	_serializing_turn_end = false
	_invoke_original_pressed_callbacks()


func _play_one_revolution_async() -> void:
	if _spin_tween != null and _spin_tween.is_valid():
		_spin_tween.kill()

	if _needle_layer == null or not is_instance_valid(_needle_layer):
		return

	# Base and cap stay fixed. Only the middle needle layer rotates around the exact
	# center shared by all three 1024x1024 source canvases.
	_needle_layer.rotation = 0.0
	_needle_layer.pivot_offset = _needle_layer.size * 0.5

	var tween := create_tween()
	_spin_tween = tween
	tween.set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	tween.tween_method(_apply_spin_progress, 0.0, 1.0, SPIN_DURATION_SEC) \
		.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	await tween.finished

	if _spin_tween == tween:
		_needle_layer.rotation = 0.0
		_spin_tween = null


func _apply_spin_progress(progress: float) -> void:
	if _needle_layer != null and is_instance_valid(_needle_layer):
		_needle_layer.rotation = TAU * clampf(progress, 0.0, 1.0)


func _invoke_original_pressed_callbacks() -> void:
	for callback in _original_pressed_callbacks:
		if callback.is_valid():
			callback.call()


func _layout_compass() -> void:
	var viewport := get_viewport()
	if viewport == null:
		return
	var viewport_size := viewport.get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return

	# The compact city panel occupies only the upper-right region. Keep the compass
	# as an independent lower-right ornament instead of reserving the full panel
	# width horizontally. At 1920x1080 this yields ~120px edge margins and a center
	# around (1680, 840), matching the approved mockup composition.
	var right_margin := maxf(MIN_EDGE_MARGIN, viewport_size.x * RIGHT_MARGIN_RATIO)
	var bottom_margin := maxf(MIN_EDGE_MARGIN, viewport_size.y * BOTTOM_MARGIN_RATIO)

	size = COMPASS_SIZE
	pivot_offset = COMPASS_SIZE * 0.5
	rotation = 0.0
	position = Vector2(
		maxf(MIN_EDGE_MARGIN, viewport_size.x - COMPASS_SIZE.x - right_margin),
		maxf(MIN_EDGE_MARGIN, viewport_size.y - COMPASS_SIZE.y - bottom_margin)
	)

	# Keep all layers perfectly registered even if the root is laid out again.
	for layer in [_base_layer, _needle_layer, _cap_layer]:
		if layer != null and is_instance_valid(layer):
			layer.position = Vector2.ZERO
			layer.size = COMPASS_SIZE
	if _needle_layer != null and is_instance_valid(_needle_layer):
		_needle_layer.pivot_offset = COMPASS_SIZE * 0.5
