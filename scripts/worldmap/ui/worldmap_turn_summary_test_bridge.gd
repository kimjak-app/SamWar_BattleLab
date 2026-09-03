extends Node

const TURN_SUMMARY_SCENE: PackedScene = preload("res://WorldMapTurnSummaryPopup.tscn")
const TURN_END_BUTTON_PATH := "WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/WildArmyEditButtonPlaceholder"
const LEFT_CONTENT_PATH := "WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content"
const TURN_LABEL_PATH := "WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/TurnLabel"
const CALENDAR_LABEL_PATH := "WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/CalendarLabel"
const TURN_WAIT_TIMEOUT_MSEC := 10000
const TURN_POLL_INTERVAL_SEC := 0.05
const SUMMARY_LOG_MARKERS := [
	"내정 적용",
	"무역 수입",
	"무역 수출",
	"시세:",
	"이번 턴",
	"적 전략 행동",
	"도시 충성도",
	"민심 변동",
	"반란 경고",
]

@onready var production_world_map: Node = get_node_or_null("../ProductionWorldMap")

var _popup: Control = null
var _watch_active := false
var _pre_turn_token := ""
var _pre_turn_market_prices: Dictionary = {}
var _last_market_prices: Dictionary = {}


func _ready() -> void:
	# W2-A14: the stable presentation coordinator owns final legacy-node hiding.
	# Do not recursively scan the HUD in an independent _process loop.
	set_process(false)
	call_deferred("_install")


func _install() -> void:
	if production_world_map == null:
		push_warning("WorldMap Turn Summary Test: ProductionWorldMap is missing.")
		return

	_popup = _ensure_popup()
	_last_market_prices = _parse_market_prices(_collect_post_turn_log_text())
	_hide_post_turn_log_nodes()

	var turn_end_button := production_world_map.get_node_or_null(TURN_END_BUTTON_PATH) as Button
	if turn_end_button == null:
		push_warning("WorldMap Turn Summary Test: turn-end button is missing.")
		return

	var callback := Callable(self, "_on_turn_end_button_down")
	if not turn_end_button.button_down.is_connected(callback):
		turn_end_button.button_down.connect(callback)


func _on_turn_end_button_down() -> void:
	if _watch_active or production_world_map == null:
		return

	var turn_end_button := production_world_map.get_node_or_null(TURN_END_BUTTON_PATH) as Button
	if turn_end_button == null or turn_end_button.disabled:
		return

	var button_text := turn_end_button.text.strip_edges()
	if not button_text.contains("턴 종료") or button_text.contains("편집"):
		return

	_pre_turn_token = _get_turn_token()
	_pre_turn_market_prices = _parse_market_prices(_collect_post_turn_log_text())
	if _pre_turn_market_prices.is_empty():
		_pre_turn_market_prices = _last_market_prices.duplicate(true)

	_watch_active = true
	_await_turn_completion_and_show()


func _await_turn_completion_and_show() -> void:
	var tree := get_tree()
	if tree == null:
		_watch_active = false
		return

	var deadline := Time.get_ticks_msec() + TURN_WAIT_TIMEOUT_MSEC
	while Time.get_ticks_msec() < deadline:
		# Polling at 20Hz is more than enough for a turn-completion popup and avoids
		# a full HUD traversal on every rendered frame while the compass is spinning.
		await tree.create_timer(TURN_POLL_INTERVAL_SEC).timeout
		var turn_end_button := production_world_map.get_node_or_null(TURN_END_BUTTON_PATH) as Button
		if turn_end_button == null:
			break

		var current_token := _get_turn_token()
		var turn_changed := not current_token.is_empty() and current_token != _pre_turn_token
		var button_text := turn_end_button.text.strip_edges()
		var turn_ready := (
			not turn_end_button.disabled
			and button_text.contains("턴 종료")
			and not button_text.contains("편집")
		)
		if turn_changed and turn_ready:
			# One final frame lets production finish its data writes. The pre-draw
			# coordinator keeps all legacy presentation suppressed during that frame.
			await tree.process_frame
			_hide_post_turn_log_nodes()
			_show_current_turn_summary()
			_watch_active = false
			return

	_watch_active = false
	push_warning("WorldMap Turn Summary Test: timed out waiting for completed turn state.")


func _show_current_turn_summary() -> void:
	_popup = _ensure_popup()
	if _popup == null:
		return

	var log_text := _collect_post_turn_log_text()
	var current_market_prices := _parse_market_prices(log_text)
	var market_delta := _build_market_delta(_pre_turn_market_prices, current_market_prices)
	var summary := {
		"meta": _get_turn_meta_text(),
		"domestic": _parse_domestic_changes(log_text),
		"trade": _parse_trade_changes(log_text),
		"market": market_delta,
	}

	_hide_post_turn_log_nodes()
	if _popup.has_method("show_summary"):
		_popup.call("show_summary", summary)

	if not current_market_prices.is_empty():
		_last_market_prices = current_market_prices.duplicate(true)


func _ensure_popup() -> Control:
	if production_world_map == null:
		return null
	var world_ui := production_world_map.get_node_or_null("WorldMapUI") as CanvasLayer
	if world_ui == null:
		return null

	var existing := world_ui.get_node_or_null("TurnSummaryPopup") as Control
	if existing != null:
		return existing

	var popup := TURN_SUMMARY_SCENE.instantiate() as Control
	if popup == null:
		push_warning("WorldMap Turn Summary Test: failed to instantiate popup scene.")
		return null
	popup.name = "TurnSummaryPopup"
	world_ui.add_child(popup)
	return popup


func _hide_post_turn_log_nodes() -> void:
	if production_world_map == null:
		return
	var content := production_world_map.get_node_or_null(LEFT_CONTENT_PATH) as VBoxContainer
	if content == null:
		return
	var turn_end_button := production_world_map.get_node_or_null(TURN_END_BUTTON_PATH) as Button
	if turn_end_button == null or turn_end_button.get_parent() != content:
		return

	var turn_end_index := turn_end_button.get_index()
	for child in content.get_children():
		if child == turn_end_button:
			continue
		var should_hide := child.get_index() > turn_end_index
		if not should_hide:
			should_hide = _subtree_contains_summary_log(child)
		if should_hide and child is CanvasItem:
			(child as CanvasItem).visible = false


func _subtree_contains_summary_log(node: Node) -> bool:
	var node_text := ""
	if node is Label:
		node_text = (node as Label).text.strip_edges()
	elif node is RichTextLabel:
		node_text = (node as RichTextLabel).get_parsed_text().strip_edges()

	if not node_text.is_empty():
		for marker in SUMMARY_LOG_MARKERS:
			if node_text.contains(str(marker)):
				return true

	for child in node.get_children():
		if _subtree_contains_summary_log(child):
			return true
	return false


func _collect_post_turn_log_text() -> String:
	if production_world_map == null:
		return ""
	var content := production_world_map.get_node_or_null(LEFT_CONTENT_PATH) as VBoxContainer
	if content == null:
		return ""

	var pieces: Array[String] = []
	_collect_text_recursive(content, pieces)
	return "\n".join(pieces)


func _collect_text_recursive(node: Node, pieces: Array[String]) -> void:
	if node is Label:
		var label_text := (node as Label).text.strip_edges()
		if not label_text.is_empty():
			pieces.append(label_text)
	elif node is RichTextLabel:
		var rich_text := (node as RichTextLabel).get_parsed_text().strip_edges()
		if not rich_text.is_empty():
			pieces.append(rich_text)

	for child in node.get_children():
		_collect_text_recursive(child, pieces)


func _get_turn_token() -> String:
	if production_world_map == null:
		return ""
	var turn_label := production_world_map.get_node_or_null(TURN_LABEL_PATH) as Label
	var calendar_label := production_world_map.get_node_or_null(CALENDAR_LABEL_PATH) as Label
	var turn_text := turn_label.text.strip_edges() if turn_label != null else ""
	var calendar_text := calendar_label.text.strip_edges() if calendar_label != null else ""
	return "%s|%s" % [turn_text, calendar_text]


func _get_turn_meta_text() -> String:
	if production_world_map == null:
		return ""
	var turn_label := production_world_map.get_node_or_null(TURN_LABEL_PATH) as Label
	var calendar_label := production_world_map.get_node_or_null(CALENDAR_LABEL_PATH) as Label
	var pieces: Array[String] = []
	if turn_label != null:
		var turn_text := _strip_phase_text(turn_label.text)
		if not turn_text.is_empty():
			pieces.append(turn_text)
	if calendar_label != null:
		var calendar_text := _strip_phase_text(calendar_label.text)
		if not calendar_text.is_empty() and not pieces.has(calendar_text):
			pieces.append(calendar_text)
	return " · ".join(pieces)


func _strip_phase_text(value: String) -> String:
	var result := value.replace("아군 턴", "").replace("적군 턴", "")
	result = result.replace("  ", " ").strip_edges()
	while result.ends_with("·"):
		result = result.left(result.length() - 1).strip_edges()
	return result


func _parse_domestic_changes(raw_text: String) -> Dictionary:
	var result := {"rice": 0, "barley": 0, "fish": 0, "gold": 0}
	var text := _normalize_log_text(raw_text)
	var start := text.find("내정 적용")
	if start < 0:
		return result
	var end := text.find("무역 수입", start)
	if end < 0:
		end = text.length()
	var segment := text.substr(start, end - start)
	result["rice"] = _extract_signed_value(segment, "쌀")
	result["barley"] = _extract_signed_value(segment, "보리")
	result["fish"] = _extract_signed_value(segment, "수산물")
	result["gold"] = _extract_signed_value(segment, "금전")
	return result


func _parse_trade_changes(raw_text: String) -> Dictionary:
	var result := {"gold": 0, "rice": 0, "barley": 0, "fish": 0, "salt": 0}
	var text := _normalize_log_text(raw_text)
	var start := text.find("무역 수입")
	if start < 0:
		return result
	var end := _find_earliest_marker(text, start, ["보급", "도시 충성도", "민심 변동", "반란", "시세:", "이번 턴"])
	if end < 0:
		end = text.length()
	var segment := text.substr(start, end - start)
	result["gold"] = _extract_signed_value(segment, "금전")
	result["rice"] = _extract_signed_value(segment, "쌀")
	result["barley"] = _extract_signed_value(segment, "보리")
	result["fish"] = _extract_signed_value(segment, "수산물")
	result["salt"] = _extract_signed_value(segment, "소금")
	return result


func _parse_market_prices(raw_text: String) -> Dictionary:
	var text := _normalize_log_text(raw_text)
	var start := text.find("시세:")
	if start < 0:
		return {}
	var end := text.find("이번 턴", start)
	if end < 0:
		end = text.length()
	var segment := text.substr(start, end - start)
	return {
		"rice": _extract_market_price(segment, "쌀"),
		"salt": _extract_market_price(segment, "소금"),
		"silk": _extract_market_price(segment, "비단"),
	}


func _build_market_delta(previous: Dictionary, current: Dictionary) -> Dictionary:
	var rice_to := int(current.get("rice", previous.get("rice", 0)))
	var salt_to := int(current.get("salt", previous.get("salt", 0)))
	var silk_to := int(current.get("silk", previous.get("silk", 0)))
	return {
		"rice_from": int(previous.get("rice", rice_to)),
		"rice_to": rice_to,
		"salt_from": int(previous.get("salt", salt_to)),
		"salt_to": salt_to,
		"silk_from": int(previous.get("silk", silk_to)),
		"silk_to": silk_to,
	}


func _extract_signed_value(segment: String, label: String) -> int:
	var regex := RegEx.new()
	if regex.compile("%s\\s*([+-]?\\d+)" % label) != OK:
		return 0
	var matched := regex.search(segment)
	if matched == null:
		return 0
	return int(matched.get_string(1))


func _extract_market_price(segment: String, label: String) -> int:
	var regex := RegEx.new()
	if regex.compile("%s\\s*([0-9]+)\\s*G" % label) != OK:
		return 0
	var matched := regex.search(segment)
	if matched == null:
		return 0
	return int(matched.get_string(1))


func _find_earliest_marker(text: String, start: int, markers: Array[String]) -> int:
	var earliest := -1
	for marker in markers:
		var found := text.find(marker, start + 1)
		if found < 0:
			continue
		if earliest < 0 or found < earliest:
			earliest = found
	return earliest


func _normalize_log_text(value: String) -> String:
	var normalized := value.replace("\r", " ").replace("\n", " ").replace("\t", " ")
	while normalized.contains("  "):
		normalized = normalized.replace("  ", " ")
	return normalized.strip_edges()
