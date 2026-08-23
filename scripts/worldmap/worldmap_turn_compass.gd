class_name WorldMapTurnCompass
extends TextureRect

const COMPASS_TEXTURE: Texture2D = preload("res://assets/worldmap/ui/worldmap_turn_compass.png")
const COMPASS_SIZE := Vector2(190.0, 190.0)
const RIGHT_PANEL_SAFE_WIDTH := 330.0
const RIGHT_MARGIN := 24.0
const BOTTOM_MARGIN := 42.0
const TURN_END_BUTTON_PATH := "WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/WildArmyEditButtonPlaceholder"

var _world_scene: Node = null
var _turn_end_button: Button = null
var _spin_tween: Tween = null


func _ready() -> void:
	texture = COMPASS_TEXTURE
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = COMPASS_SIZE
	size = COMPASS_SIZE
	pivot_offset = COMPASS_SIZE * 0.5
	rotation_degrees = 0.0
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

	if _turn_end_button != null and _turn_end_button != button:
		if _turn_end_button.button_down.is_connected(_on_turn_button_down):
			_turn_end_button.button_down.disconnect(_on_turn_button_down)

	_turn_end_button = button
	if not _turn_end_button.button_down.is_connected(_on_turn_button_down):
		_turn_end_button.button_down.connect(_on_turn_button_down)
	call_deferred("_layout_compass")


func _on_turn_button_down() -> void:
	if _turn_end_button == null or _turn_end_button.disabled:
		return

	var button_text := _turn_end_button.text.strip_edges()
	# Read the state before the button's main pressed handler changes turn/UI state.
	if not button_text.contains("턴 종료") or button_text.contains("편집"):
		return

	play_turn_end_spin()


func play_turn_end_spin() -> void:
	if _spin_tween != null and _spin_tween.is_valid():
		_spin_tween.kill()

	rotation_degrees = 0.0
	pivot_offset = size * 0.5

	# One visual revolution is intentionally split into four phases.
	# The previous two-turn animation moved too many degrees per rendered frame
	# on a 30 fps capture and looked stepped even though the tween updated normally.
	_spin_tween = create_tween()
	_spin_tween.set_process_mode(Tween.TWEEN_PROCESS_IDLE)

	# Gentle pickup: 0 -> 40 degrees.
	_spin_tween.tween_property(self, "rotation_degrees", 40.0, 0.28) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	# Main rotation: constant angular motion keeps adjacent frames visually even.
	_spin_tween.tween_property(self, "rotation_degrees", 300.0, 1.20) \
		.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

	# Slow into a tiny overshoot beyond north.
	_spin_tween.tween_property(self, "rotation_degrees", 368.0, 0.55) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# Mechanical-looking settle back to exact north.
	_spin_tween.tween_property(self, "rotation_degrees", 360.0, 0.18) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_spin_tween.tween_callback(_finish_spin)


func _finish_spin() -> void:
	# 360 and 0 are visually identical; normalize for the next turn.
	rotation_degrees = 0.0
	_spin_tween = null


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
