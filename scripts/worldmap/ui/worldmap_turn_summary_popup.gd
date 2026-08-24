class_name WorldMapTurnSummaryPopup
extends Control

signal dismissed

@onready var title_label: Label = $PopupRoot/TitleLabel
@onready var turn_meta_label: Label = $PopupRoot/TurnMetaLabel
@onready var domestic_body_label: Label = $PopupRoot/DomesticBodyLabel
@onready var trade_body_label: Label = $PopupRoot/TradeBodyLabel
@onready var market_body_label: Label = $PopupRoot/MarketBodyLabel


func _ready() -> void:
	visible = false
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

	visible = true
	if get_parent() != null:
		get_parent().move_child(self, get_parent().get_child_count() - 1)


func hide_summary() -> void:
	if not visible:
		return
	visible = false
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
