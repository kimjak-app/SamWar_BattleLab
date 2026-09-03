class_name WorldMapTurnSummaryPopup
extends Control

signal dismissed

const FADE_IN_DURATION := 0.24
const FADE_OUT_DURATION := 0.15

@onready var title_label: Label = $PopupRoot/TitleLabel
@onready var turn_meta_label: Label = $PopupRoot/TurnMetaLabel
@onready var domestic_body_label: Label = $PopupRoot/DomesticBodyLabel
@onready var trade_body_label: Label = $PopupRoot/TradeBodyLabel
@onready var market_body_label: Label = $PopupRoot/MarketBodyLabel

var _fade_tween: Tween = null
var _is_dismissing := false


func _ready() -> void:
	visible = false
	modulate.a = 0.0
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_process_input(true)


func show_summary(summary: Dictionary) -> void:
	title_label.text = "턴 결산"
	turn_meta_label.text = str(summary.get("meta", ""))

	var domestic: Dictionary = summary.get("domestic", {})
	domestic_body_label.text = (
		"쌀  %s    보리  %s\n수산물  %s    금전  %s"
		% [
			_format_signed(domestic.get("rice", 0)),
			_format_signed(domestic.get("barley", 0)),
			_format_signed(domestic.get("fish", 0)),
			_format_signed(domestic.get("gold", 0)),
		]
	)

	var trade: Dictionary = summary.get("trade", {})
	trade_body_label.text = (
		"금전  %s    쌀  %s\n보리  %s    수산물  %s\n소금  %s"
		% [
			_format_signed(trade.get("gold", 0)),
			_format_signed(trade.get("rice", 0)),
			_format_signed(trade.get("barley", 0)),
			_format_signed(trade.get("fish", 0)),
			_format_signed(trade.get("salt", 0)),
		]
	)

	var market: Dictionary = summary.get("market", {})
	market_body_label.text = (
		"쌀  %dG → %dG\n소금  %dG → %dG\n비단  %dG → %dG"
		% [
			int(market.get("rice_from", 0)),
			int(market.get("rice_to", 0)),
			int(market.get("salt_from", 0)),
			int(market.get("salt_to", 0)),
			int(market.get("silk_from", 0)),
			int(market.get("silk_to", 0)),
		]
	)

	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()
	_is_dismissing = false
	modulate.a = 0.0
	visible = true
	if get_parent() != null:
		get_parent().move_child(self, get_parent().get_child_count() - 1)

	_fade_tween = create_tween()
	_fade_tween.set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	_fade_tween.tween_property(self, "modulate:a", 1.0, FADE_IN_DURATION) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func hide_summary() -> void:
	if not visible or _is_dismissing:
		return
	_is_dismissing = true
	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()
	_fade_tween = create_tween()
	_fade_tween.set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	_fade_tween.tween_property(self, "modulate:a", 0.0, FADE_OUT_DURATION) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_fade_tween.tween_callback(Callable(self, "_finish_hide"))


func _finish_hide() -> void:
	visible = false
	modulate.a = 0.0
	_is_dismissing = false
	_fade_tween = null
	dismissed.emit()


func _input(event: InputEvent) -> void:
	if not visible:
		return

	var should_close := false
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		should_close = mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT
	elif event is InputEventKey:
		var key_event := event as InputEventKey
		should_close = (
			key_event.pressed
			and not key_event.echo
			and key_event.keycode in [KEY_ENTER, KEY_ESCAPE, KEY_SPACE]
		)

	if should_close:
		hide_summary()
		var viewport := get_viewport()
		if viewport != null:
			viewport.set_input_as_handled()


func _format_signed(value: Variant) -> String:
	var number := int(value)
	if number > 0:
		return "+%d" % number
	return str(number)
