class_name WorldMapTurnCompass
extends TextureRect

signal turn_end_requested

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
const TURN_WAIT_TIMEOUT_MSEC := 10000
const TURN_END_BUTTON_PATH := "WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/WildArmyEditButtonPlaceholder"
const TURN_LABEL_PATH := "WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/TurnLabel"
const CALENDAR_LABEL_PATH := "WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/CalendarLabel"
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
var _install_attempts := 0
var _serializing_turn_end := false
var _plaque_hovered := false


func _ready() -> void:
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
	_hide_legacy_turn_end_button()
	_refresh_plaque_availability()


func _build_compass_layers() -> void:
	_base_layer = _create_layer("Base", COMPASS_BASE_TEXTURE)
	add_child(_base_layer)
	_needle_layer = _create_layer("Needle", COMPASS_NEEDLE_TEXTURE)
	_needle_layer.pivot_offset = COMPASS_SIZE * 0.5
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
	# W2-A15: do not re-emit any legacy button signal. Presentation bridges listen
	# to this dedicated compass signal, so no legacy listener can mutate HUD state
	# during the visual pre-roll.
	turn_end_requested.emit()
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
	if not is_actual_turn_end:
		_invoke_original_pressed_callbacks()
		return

	_serializing_turn_end = true
	var pre_turn_token := _get_turn_token()
	_turn_end_button.disabled = true
	_hide_plaque_immediately()

	# Start an uninterrupted looping spin. The first full revolution remains the
	# visual pre-roll contract, but the needle no longer stops before gameplay work.
	_start_continuous_spin()
	await get_tree().create_timer(SPIN_DURATION_SEC).timeout

	if _turn_end_button != null and is_instance_valid(_turn_end_button):
		_turn_end_button.disabled = false
	_invoke_original_pressed_callbacks()

	# Keep spinning through ally/enemy turn resolution. Stable HUD mirrors prevent
	# temporary production text from reaching the screen during this period.
	await _wait_for_completed_turn(pre_turn_token)
	await _finish_spin_cleanly()
	_serializing_turn_end = false


func _start_continuous_spin() -> void:
	if _spin_tween != null and _spin_tween.is_valid():
		_spin_tween.kill()
	if _needle_layer == null or not is_instance_valid(_needle_layer):
		return
	_needle_layer.rotation = 0.0
	_needle_layer.pivot_offset = _needle_layer.size * 0.5
	var tween := create_tween()
	_spin_tween = tween
	tween.set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	tween.set_loops()
	tween.tween_method(_apply_spin_progress, 0.0, 1.0, SPIN_DURATION_SEC) \
		.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)


func _wait_for_completed_turn(pre_turn_token: String) -> void:
	var tree := get_tree()
	if tree == null:
		return
	var deadline := Time.get_ticks_msec() + TURN_WAIT_TIMEOUT_MSEC
	var saw_turn_change := false
	while Time.get_ticks_msec() < deadline:
		await tree.process_frame
		var current_token := _get_turn_token()
		if not current_token.is_empty() and current_token != pre_turn_token:
			saw_turn_change = true
		if not saw_turn_change:
			continue
		if _turn_end_button == null or not is_instance_valid(_turn_end_button):
			return
		var text := _turn_end_button.text.strip_edges()
		var turn_ready := (
			not _turn_end_button.disabled
			and text.contains("턴 종료")
			and not text.contains("편집")
		)
		if turn_ready:
			return


func _finish_spin_cleanly() -> void:
	if _needle_layer == null or not is_instance_valid(_needle_layer):
		return
	if _spin_tween != null and _spin_tween.is_valid():
		_spin_tween.kill()
	_spin_tween = null
	var angle := fposmod(_needle_layer.rotation, TAU)
	if angle <= 0.03 or TAU - angle <= 0.03:
		_needle_layer.rotation = 0.0
		return
	var remaining := TAU - angle
	var duration := maxf(0.08, SPIN_DURATION_SEC * remaining / TAU)
	var tween := create_tween()
	_spin_tween = tween
	tween.set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	tween.tween_property(_needle_layer, "rotation", TAU, duration) \
		.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	if _spin_tween == tween:
		_needle_layer.rotation = 0.0
		_spin_tween = null


func _apply_spin_progress(progress: float) -> void:
	if _needle_layer != null and is_instance_valid(_needle_layer):
		_needle_layer.rotation = TAU * clampf(progress, 0.0, 1.0)


func _get_turn_token() -> String:
	if _world_scene == null:
		return ""
	var turn_label := _world_scene.get_node_or_null(TURN_LABEL_PATH) as Label
	var calendar_label := _world_scene.get_node_or_null(CALENDAR_LABEL_PATH) as Label
	var turn_text := turn_label.text.strip_edges() if turn_label != null else ""
	var calendar_text := calendar_label.text.strip_edges() if calendar_label != null else ""
	return "%s|%s" % [turn_text, calendar_text]


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
	var right_margin := maxf(MIN_RIGHT_MARGIN, viewport_size.x * RIGHT_MARGIN_RATIO)
	size = COMPASS_SIZE
	pivot_offset = COMPASS_SIZE * 0.5
	rotation = 0.0
	position = Vector2(
		maxf(MIN_RIGHT_MARGIN, viewport_size.x - COMPASS_SIZE.x - right_margin),
		maxf(0.0, viewport_size.y - COMPASS_SIZE.y - BOTTOM_MARGIN)
	)
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