class_name WorldMapTurnCompass
extends TextureRect

const COMPASS_BASE_TEXTURE: Texture2D = preload("res://assets/worldmap/ui/worldmap_turn_compass_base.png")
const COMPASS_NEEDLE_TEXTURE: Texture2D = preload("res://assets/worldmap/ui/worldmap_turn_compass_needle.png")
const COMPASS_CAP_TEXTURE: Texture2D = preload("res://assets/worldmap/ui/worldmap_turn_compass_cap.png")
const TURN_END_PLAQUE_TEXTURE: Texture2D = preload("res://assets/worldmap/ui/worldmap_turn_end_plaque.png")
const COMPASS_SIZE := Vector2(240.0, 240.0)
const PLAQUE_SIZE := Vector2(180.0, 60.0)
const PLAQUE_NORMAL_ALPHA := 0.80
const PLAQUE_HOVER_ALPHA := 1.00
const PLAQUE_FADE_DURATION := 0.18
const RIGHT_MARGIN_RATIO := 0.052083
const MIN_RIGHT_MARGIN := 48.0
const BOTTOM_MARGIN := 34.0
const SPIN_DURATION_SEC := 1.60
const TURN_END_BUTTON_PATH := "WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/WildArmyEditButtonPlaceholder"
const MAX_INSTALL_ATTEMPTS := 6

var _world_scene: Node = null
var _turn_end_button: Button = null
var _spin_tween: Tween = null
var _plaque_tween: Tween = null
var _base_layer: TextureRect = null
var _needle_layer: TextureRect = null
var _cap_layer: TextureRect = null
var _plaque_layer: TextureRect = null
var _plaque_button: Button = null
var _original_pressed_callbacks: Array[Callable] = []
var _pressed_wrapper_installed := false
var _install_attempts = 0
var _serializing_turn_end := false
var _plaque_hovered := false


func _ready() -> void:
	# This node is a fixed 240x240 container. The three compass source PNGs all
	# share the same 1024x1024 canvas, so identical child rects preserve alignment.
	texture = null
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = COMPASS_SIZE
	size = COMPASS_SIZE
	pivot_offset = COMPASS_SIZE * 0.5
	rotation = 0.0
	z_index = 20
	set_process(true)

	_build_compass_layers()
	_build_turn_end_plaque()

	var viewport := get_viewport()
	if viewport != null and not viewport.size_changed.is_connected(_layout_compass):
		viewport.size_changed.connect(_layout_compass)
	call_deferred("_layout_compass")


func _process(_delta: float) -> void:
	# Keep the legacy left-panel button alive as the gameplay/signal source but
	# never render it. The compass plaque is now the only turn-end presentation.
	_hide_legacy_turn_end_button()
	_refresh_plaque_availability()


func _build_compass_layers() -> void:
	_base_layer = _create_layer("Base", COMPASS_BASE_TEXTURE)
	add_child(_base_layer)

	_needle_layer = _create_layer("Needle", COMPASS_NEEDLE_TEXTURE)
	_needle_layer.pivot_offset = COMPASS_SIZE * 0.5
	_needle_layer.rotation = 0.0
	add_child(_needle_layer)

	_cap_layer = _create_layer("Cap", COMPASS_CAP_TEXTURE)
	add_child(_cap_layer)


func _build_turn_end_plaque() -> void:
	_plaque_layer = TextureRect.new()
	_plaque_layer.name = "TurnEndPlaque"
	_plaque_layer.texture = TURN_END_PLAQUE_TEXTURE
	_plaque_layer.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_plaque_layer.stretch_mode = TextureRect.STRETCH_SCALE
	_plaque_layer.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_plaque_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_plaque_layer.position = (COMPASS_SIZE - PLAQUE_SIZE) * 0.5
	_plaque_layer.size = PLAQUE_SIZE
	_plaque_layer.custom_minimum_size = Vector2.ZERO
	_plaque_layer.visible = false
	_apply_plaque_alpha(0.0)
	add_child(_plaque_layer)

	_plaque_button = Button.new()
	_plaque_button.name = "TurnEndPlaqueButton"
	_plaque_button.text = ""
	_plaque_button.flat = true
	_plaque_button.focus_mode = Control.FOCUS_NONE
	_plaque_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_plaque_button.position = _plaque_layer.position
	_plaque_button.size = PLAQUE_SIZE
	_plaque_button.custom_minimum_size = Vector2.ZERO
	_plaque_button.visible = false
	_plaque_button.mouse_entered.connect(_on_plaque_mouse_entered)
	_plaque_button.mouse_exited.connect(_on_plaque_mouse_exited)
	_plaque_button.pressed.connect(_on_plaque_pressed)
	add_child(_plaque_button)


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

	_hide_legacy_turn_end_button()

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


func _on_plaque_pressed() -> void:
	if not _is_actual_turn_end_available():
		return
	if _turn_end_button == null or not is_instance_valid(_turn_end_button):
		return

	# TurnSummaryBridge intentionally watches button_down. Preserve that one signal,
	# but do NOT re-emit pressed here: late pressed listeners can otherwise execute
	# in parallel with the compass wrapper and mutate HUD state during the spin.
	_turn_end_button.button_down.emit()
	_on_turn_button_pressed_serialized()


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
	_hide_plaque_immediately()

	# Preserve the proven ordering contract: one uninterrupted visual revolution
	# finishes first, then the existing turn-end / enemy-turn processing begins.
	await _play_one_revolution_async()

	if _turn_end_button != null and is_instance_valid(_turn_end_button):
		_turn_end_button.disabled = false

	# Keep the compass busy flag set while gameplay callbacks run. That prevents the
	# plaque from reappearing in the tiny gap before production publishes its new
	# turn phase and keeps the presentation sequence strictly serialized.
	_invoke_original_pressed_callbacks()
	_serializing_turn_end = false


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


func _hide_legacy_turn_end_button() -> void:
	if _turn_end_button != null and is_instance_valid(_turn_end_button):
		_turn_end_button.visible = false


func _is_actual_turn_end_available() -> bool:
	if _serializing_turn_end:
		return false
	if _turn_end_button == null or not is_instance_valid(_turn_end_button):
		return false
	if _turn_end_button.disabled:
		return false
	var text := _turn_end_button.text.strip_edges()
	return text.contains("턴 종료") and not text.contains("편집")


func _refresh_plaque_availability() -> void:
	if _plaque_layer == null or _plaque_button == null:
		return
	var should_show := _is_actual_turn_end_available()
	if should_show:
		if not _plaque_layer.visible:
			_fade_plaque_in()
	else:
		_hide_plaque_immediately()


func _fade_plaque_in() -> void:
	if _plaque_layer == null or _plaque_button == null:
		return
	if _plaque_tween != null and _plaque_tween.is_valid():
		_plaque_tween.kill()
	_plaque_layer.visible = true
	_plaque_button.visible = true
	_apply_plaque_alpha(0.0)
	var target := PLAQUE_HOVER_ALPHA if _plaque_hovered else PLAQUE_NORMAL_ALPHA
	var tween := create_tween()
	_plaque_tween = tween
	tween.tween_method(_apply_plaque_alpha, 0.0, target, PLAQUE_FADE_DURATION) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _hide_plaque_immediately() -> void:
	if _plaque_tween != null and _plaque_tween.is_valid():
		_plaque_tween.kill()
	_plaque_tween = null
	if _plaque_layer != null:
		_plaque_layer.visible = false
		_apply_plaque_alpha(0.0)
	if _plaque_button != null:
		_plaque_button.visible = false


func _on_plaque_mouse_entered() -> void:
	_plaque_hovered = true
	_tween_plaque_alpha(PLAQUE_HOVER_ALPHA)


func _on_plaque_mouse_exited() -> void:
	_plaque_hovered = false
	_tween_plaque_alpha(PLAQUE_NORMAL_ALPHA)


func _tween_plaque_alpha(target_alpha: float) -> void:
	if _plaque_layer == null or not _plaque_layer.visible:
		return
	if _plaque_tween != null and _plaque_tween.is_valid():
		_plaque_tween.kill()
	var current := _plaque_layer.modulate.a
	var tween := create_tween()
	_plaque_tween = tween
	tween.tween_method(_apply_plaque_alpha, current, target_alpha, 0.10) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _apply_plaque_alpha(alpha: float) -> void:
	if _plaque_layer == null:
		return
	var color := _plaque_layer.modulate
	color.a = clampf(alpha, 0.0, 1.0)
	_plaque_layer.modulate = color


func _layout_compass() -> void:
	var viewport := get_viewport()
	if viewport == null:
		return
	var viewport_size := viewport.get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return

	# Keep the compass as a lower-right ornament independent of the upper-right
	# city panel. At 1920x1080 it keeps ~100px on the right and 34px at the bottom.
	var right_margin := maxf(MIN_RIGHT_MARGIN, viewport_size.x * RIGHT_MARGIN_RATIO)

	size = COMPASS_SIZE
	pivot_offset = COMPASS_SIZE * 0.5
	rotation = 0.0
	position = Vector2(
		maxf(MIN_RIGHT_MARGIN, viewport_size.x - COMPASS_SIZE.x - right_margin),
		maxf(0.0, viewport_size.y - COMPASS_SIZE.y - BOTTOM_MARGIN)
	)

	# Keep all layers perfectly registered even if the root is laid out again.
	for layer in [_base_layer, _needle_layer, _cap_layer]:
		if layer != null and is_instance_valid(layer):
			layer.position = Vector2.ZERO
			layer.size = COMPASS_SIZE
	if _needle_layer != null and is_instance_valid(_needle_layer):
		_needle_layer.pivot_offset = COMPASS_SIZE * 0.5
	if _plaque_layer != null and is_instance_valid(_plaque_layer):
		_plaque_layer.position = (COMPASS_SIZE - PLAQUE_SIZE) * 0.5
		_plaque_layer.size = PLAQUE_SIZE
	if _plaque_button != null and is_instance_valid(_plaque_button):
		_plaque_button.position = (COMPASS_SIZE - PLAQUE_SIZE) * 0.5
		_plaque_button.size = PLAQUE_SIZE
