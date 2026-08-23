class_name WorldMapTurnCompass
extends TextureRect

const COMPASS_TEXTURE: Texture2D = preload("res://assets/worldmap/ui/worldmap_turn_compass.png")
const COMPASS_SIZE := Vector2(190.0, 190.0)
const RIGHT_PANEL_SAFE_WIDTH := 330.0
const RIGHT_MARGIN := 24.0
const BOTTOM_MARGIN := 42.0
const SPIN_DURATION_SEC := 1.60
const TURN_END_BUTTON_PATH := "WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/WildArmyEditButtonPlaceholder"
const MAX_INSTALL_ATTEMPTS := 6

var _world_scene: Node = null
var _turn_end_button: Button = null
var _spin_tween: Tween = null
var _original_pressed_callbacks: Array[Callable] = []
var _pressed_wrapper_installed := false
var _install_attempts := 0
var _serializing_turn_end := false


func _ready() -> void:
	texture = COMPASS_TEXTURE
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = COMPASS_SIZE
	size = COMPASS_SIZE
	pivot_offset = COMPASS_SIZE * 0.5
	rotation = 0.0
	z_index = 20

	var viewport := get_viewport()
	if viewport != null and not viewport.size_changed.is_connected(_layout_compass):
		viewport.size_changed.connect(_layout_compass)
	call_deferred("_layout_compass")


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

	# Critical ordering contract:
	# 1) render one uninterrupted compass revolution,
	# 2) only then run the existing turn-end / enemy-turn processing.
	# The old order ran both at once, so blocking turn calculations froze rendering
	# in the middle of the tween and visually produced 180deg -> pause -> 180deg.
	await _play_one_revolution_async()

	if _turn_end_button != null and is_instance_valid(_turn_end_button):
		_turn_end_button.disabled = false
	_serializing_turn_end = false
	_invoke_original_pressed_callbacks()


func _play_one_revolution_async() -> void:
	if _spin_tween != null and _spin_tween.is_valid():
		_spin_tween.kill()

	rotation = 0.0
	pivot_offset = size * 0.5

	var tween := create_tween()
	_spin_tween = tween
	tween.set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	tween.tween_method(_apply_spin_progress, 0.0, 1.0, SPIN_DURATION_SEC) \
		.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	await tween.finished

	if _spin_tween == tween:
		rotation = 0.0
		_spin_tween = null


func _apply_spin_progress(progress: float) -> void:
	rotation = TAU * clampf(progress, 0.0, 1.0)


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

	var right_reserved := RIGHT_PANEL_SAFE_WIDTH
	if _world_scene != null:
		var right_panel := _world_scene.get_node_or_null("WorldMapUI/CityInfoPanel") as Control
		if right_panel != null and right_panel.visible and right_panel.size.x > 0.0:
			right_reserved = maxf(right_reserved, right_panel.size.x + RIGHT_MARGIN)

	size = COMPASS_SIZE
	pivot_offset = COMPASS_SIZE * 0.5
	position = Vector2(
		maxf(RIGHT_MARGIN, viewport_size.x - right_reserved - COMPASS_SIZE.x - RIGHT_MARGIN),
		maxf(RIGHT_MARGIN, viewport_size.y - COMPASS_SIZE.y - BOTTOM_MARGIN)
	)
