extends CanvasLayer
# HUD block 1: the 2D top command buttons (auto, end turn, retreat) on the 3D
# shell, plus the 3D-only option and speed as buttons of the same shape. Size,
# row and hover/press scales follow the 2D top actions
# (battle_roster_presentation_controller.gd TOP_ACTION_*); auto, end turn and
# retreat use the textures the 2D actually shows. The buttons only call the
# shell's callables (the lab's own functions); this node reads nothing from the
# engine and writes nothing. Retreat is a picture only: disabled, no handler,
# until the world-map link (M7).
const AUTO_TEXTURE := preload("res://assets/ui/battle/top_actions/auto_battle_button.png")
const END_TURN_TEXTURE := preload("res://assets/ui/battle/top_actions/end_turn_button.png")
const RETREAT_TEXTURE := preload("res://assets/ui/battle/top_actions/retreat_button.png")
const BUTTON_SIZE := Vector2(68.0, 68.0)
const BUTTON_GAP := 18.0
const ROW_Y := 27.0
const FIRST_X := 1435.0 # option, speed, auto, end turn, retreat (the 2D auto sits at 1607)
const HOVER_SCALE := Vector2(1.07, 1.07)
const PRESS_SCALE := Vector2(0.94, 0.94)
const TWEEN_DURATION := 0.11
const RETREAT_TOOLTIP := "월드맵 연결 후 사용"
# Temporary art for the 3D-only buttons (no 2D picture exists): a plain frame and text.
const TEMP_FILL := Color(0.10, 0.09, 0.07, 0.92)
const TEMP_BORDER := Color(0.78, 0.64, 0.36, 1.0)
var option_button: Button
var speed_button: Button
var auto_button: TextureButton
var end_turn_button: TextureButton
var retreat_button: TextureButton
var on_option := Callable()
var on_speed := Callable()
var on_auto := Callable()
var on_end_turn := Callable()
var _tweens := {}

func _ready() -> void:
	option_button = _temp_button("옵션", 0)
	option_button.pressed.connect(func(): if on_option.is_valid(): on_option.call())
	speed_button = _temp_button("속도\n×1", 1)
	speed_button.pressed.connect(func(): if on_speed.is_valid(): on_speed.call())
	auto_button = _texture_button(AUTO_TEXTURE, 2)
	auto_button.pressed.connect(func(): if on_auto.is_valid(): on_auto.call())
	end_turn_button = _texture_button(END_TURN_TEXTURE, 3)
	end_turn_button.pressed.connect(func(): if on_end_turn.is_valid(): on_end_turn.call())
	retreat_button = _texture_button(RETREAT_TEXTURE, 4)
	retreat_button.disabled = true
	retreat_button.tooltip_text = RETREAT_TOOLTIP

func slot_rect(index: int) -> Rect2:
	return Rect2(Vector2(FIRST_X + index * (BUTTON_SIZE.x + BUTTON_GAP), ROW_Y), BUTTON_SIZE)

func _place(button: BaseButton, index: int) -> void:
	button.position = slot_rect(index).position
	button.size = BUTTON_SIZE
	button.pivot_offset = BUTTON_SIZE * 0.5
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.mouse_entered.connect(func(): if not button.disabled: _scale(button, HOVER_SCALE))
	button.mouse_exited.connect(func(): _scale(button, Vector2.ONE))
	button.button_down.connect(func(): if not button.disabled: _scale(button, PRESS_SCALE, 0.07))
	button.button_up.connect(func(): if not button.disabled: _scale(button, HOVER_SCALE if button.is_hovered() else Vector2.ONE, 0.09))
	add_child(button)

func _texture_button(texture: Texture2D, index: int) -> TextureButton:
	# Like the 2D: every state shows the same texture (a disabled button looks the same).
	var button := TextureButton.new()
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_SCALE
	button.texture_normal = texture
	button.texture_hover = texture
	button.texture_pressed = texture
	button.texture_disabled = texture
	_place(button, index)
	return button

func _temp_button(text: String, index: int) -> Button:
	var button := Button.new()
	button.text = text
	button.add_theme_font_size_override("font_size", 16)
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		var style := StyleBoxFlat.new()
		style.bg_color = TEMP_FILL.lightened(0.08) if state == "hover" else TEMP_FILL
		style.border_color = TEMP_BORDER
		style.set_border_width_all(2)
		style.set_corner_radius_all(10)
		button.add_theme_stylebox_override(state, style)
	button.custom_minimum_size = BUTTON_SIZE
	_place(button, index)
	return button

func _scale(button: Control, target: Vector2, duration := TWEEN_DURATION) -> void:
	var previous = _tweens.get(button.get_instance_id())
	if previous != null and previous.is_valid(): previous.kill()
	var tween := create_tween()
	_tweens[button.get_instance_id()] = tween
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", target, duration)

func show_state(auto_on: bool, auto_disabled: bool, end_turn_disabled: bool, end_turn_tooltip: String, speed: int) -> void:
	# The 2D shows auto on/off only in the tooltip and enables it while on (_refresh_auto_battle_button_state).
	auto_button.disabled = auto_disabled
	auto_button.tooltip_text = "자동중지" if auto_on else "자동전투"
	end_turn_button.disabled = end_turn_disabled
	end_turn_button.tooltip_text = end_turn_tooltip
	speed_button.text = "속도\n×%d" % speed
