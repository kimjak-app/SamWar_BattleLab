extends CanvasLayer
# HUD block 1: the top command buttons (option, speed, auto, end turn, retreat)
# on the 3D shell. Size, row and hover/press scales follow the 2D top actions
# (battle_roster_presentation_controller.gd TOP_ACTION_*). All five use one
# plain text-button style (a dark frame with a gold border; temporary, to be
# finished in the final polish): Kim's decision (10-25) over the 2D round icons,
# which this row no longer uses. Auto shows on/off by a brighter gold border and
# text (its text never changes); a disabled button is dimmed. The buttons only
# call the shell's callables (the lab's own functions); this node reads nothing
# from the engine and writes nothing. Retreat is disabled with no handler until
# the world-map link (M7).
const BUTTON_SIZE := Vector2(68.0, 68.0)
const BUTTON_GAP := 18.0
const ROW_Y := 27.0
const FIRST_X := 1435.0 # option, speed, auto, end turn, retreat (the 2D auto sits at 1607)
const HOVER_SCALE := Vector2(1.07, 1.07)
const PRESS_SCALE := Vector2(0.94, 0.94)
const TWEEN_DURATION := 0.11
const RETREAT_TOOLTIP := "월드맵 연결 후 사용"
const FONT_SIZE := 16
# Temporary style (no art yet): a plain frame and text.
const TEMP_FILL := Color(0.10, 0.09, 0.07, 0.92)
const TEMP_BORDER := Color(0.78, 0.64, 0.36, 1.0)
const TEXT_COLOR := Color(0.93, 0.90, 0.84, 1.0)
const LIT_BORDER := Color(1.0, 0.86, 0.46, 1.0) # auto on
const LIT_TEXT := Color(1.0, 0.86, 0.46, 1.0)
const DIM_FILL := Color(0.07, 0.06, 0.05, 0.70) # disabled
const DIM_BORDER := Color(0.42, 0.36, 0.24, 0.55)
const DIM_TEXT := Color(0.55, 0.52, 0.46, 0.55)
var option_button: Button
var speed_button: Button
var auto_button: Button
var end_turn_button: Button
var retreat_button: Button
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
	auto_button = _temp_button("자동\n전투", 2)
	auto_button.pressed.connect(func(): if on_auto.is_valid(): on_auto.call())
	end_turn_button = _temp_button("턴 종료", 3)
	end_turn_button.pressed.connect(func(): if on_end_turn.is_valid(): on_end_turn.call())
	retreat_button = _temp_button("후퇴", 4)
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

func _style(fill: Color, border: Color, width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(10)
	return style

func _temp_button(text: String, index: int) -> Button:
	var button := Button.new()
	button.text = text
	button.add_theme_font_size_override("font_size", FONT_SIZE)
	button.add_theme_stylebox_override("disabled", _style(DIM_FILL, DIM_BORDER, 2))
	button.add_theme_color_override("font_disabled_color", DIM_TEXT)
	_set_lit(button, false)
	button.custom_minimum_size = BUTTON_SIZE
	_place(button, index)
	return button

func _set_lit(button: Button, lit: bool) -> void:
	# Enabled states: the normal gold border, or a brighter gold border and text when lit (auto on).
	var border := LIT_BORDER if lit else TEMP_BORDER
	var width := 3 if lit else 2
	for state in ["normal", "hover", "pressed", "focus"]:
		button.add_theme_stylebox_override(state, _style(TEMP_FILL.lightened(0.08) if state == "hover" else TEMP_FILL, border, width))
	for color_name in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		button.add_theme_color_override(color_name, LIT_TEXT if lit else TEXT_COLOR)

func _scale(button: Control, target: Vector2, duration := TWEEN_DURATION) -> void:
	var previous = _tweens.get(button.get_instance_id())
	if previous != null and previous.is_valid(): previous.kill()
	var tween := create_tween()
	_tweens[button.get_instance_id()] = tween
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", target, duration)

func show_state(auto_on: bool, auto_disabled: bool, end_turn_disabled: bool, end_turn_tooltip: String, speed: int) -> void:
	# Auto on/off: the tooltip like the 2D (_refresh_auto_battle_button_state) and the lit border/text.
	auto_button.disabled = auto_disabled
	auto_button.tooltip_text = "자동중지" if auto_on else "자동전투"
	if auto_button.has_meta("lit") == false or bool(auto_button.get_meta("lit")) != auto_on:
		auto_button.set_meta("lit", auto_on)
		_set_lit(auto_button, auto_on)
	end_turn_button.disabled = end_turn_disabled
	end_turn_button.tooltip_text = end_turn_tooltip
	speed_button.text = "속도\n×%d" % speed
