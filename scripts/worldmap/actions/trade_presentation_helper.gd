class_name WorldMapTradePresentationHelper
extends RefCounted

const UIFormatterHelpers := preload("res://scripts/worldmap/ui_formatter/ui_formatter_helpers.gd")
const TRADE_RESOURCES := ["rice", "barley", "seafood", "wood", "iron", "horses", "silk", "salt"]
const RESOURCE_LABELS := {
	"rice": "쌀", "barley": "보리", "seafood": "수산물", "wood": "목재",
	"iron": "철", "horses": "말", "silk": "비단", "salt": "소금", "gold": "금전",
}

var _host: Node
var _controller: RefCounted


func configure(host: Node, controller: RefCounted) -> void:
	_host = host
	_controller = controller


func get_trade_control_mode_label(mode: String) -> String:
	return UIFormatterHelpers.get_trade_control_mode_label(mode, "manual")


func get_trade_control_hint(tab_id: String, mode: String, has_manual_targets: bool) -> String:
	return UIFormatterHelpers.get_trade_control_hint(tab_id, mode, has_manual_targets, "internal_trade", "manual")


func format_manual_trade_preview_summary(preview: Dictionary) -> String:
	var parts: Array[String] = ["금전 %s" % _signed(int(preview.get("gold", 0)))]
	for resource_id in TRADE_RESOURCES:
		parts.append("%s %s" % [RESOURCE_LABELS.get(resource_id, resource_id), _signed(int(preview.get(resource_id, 0)))])
	var summary := " / ".join(parts)
	var market_text := format_trade_market_prices_for_external_trade_ui()
	if float(preview.get("efficiency", 0.0)) > 0.0:
		return "효율 x%.2f 적용 · %s%s" % [float(preview["efficiency"]), summary, "\n%s" % market_text if not market_text.is_empty() else ""]
	return "%s\n%s" % [summary, market_text] if not market_text.is_empty() else summary


func format_manual_trade_nonzero_preview_summary(preview: Dictionary) -> String:
	var parts: Array[String] = []
	if int(preview.get("gold", 0)) != 0:
		parts.append("금전 %s" % _signed(int(preview["gold"])))
	for resource_id in TRADE_RESOURCES:
		var delta := int(preview.get(resource_id, 0))
		if delta != 0:
			parts.append("%s %s" % [RESOURCE_LABELS.get(resource_id, resource_id), _signed(delta)])
	if parts.is_empty():
		return "금전 0"
	var summary := " / ".join(parts)
	return "효율 x%.2f 적용 · %s" % [float(preview["efficiency"]), summary] if float(preview.get("efficiency", 0.0)) > 0.0 else summary


func format_external_manual_trade_execution_result_summary(source_city_id: String) -> String:
	var result_variant: Variant = (_host.get("_player_state") as Dictionary).get("last_external_manual_trade_execution_result", {})
	if not result_variant is Dictionary:
		return ""
	var result := result_variant as Dictionary
	if result.is_empty() or str(result.get("source_city_id", "")) != source_city_id:
		return ""
	if not bool(result.get("ok", false)):
		return "수동 무역 실행 실패\n%s" % str(result.get("message", "실행할 수 없습니다."))
	var applied: Dictionary = (result.get("applied", {}) as Dictionary).duplicate(true)
	if result.has("efficiency"):
		applied["efficiency"] = float(result["efficiency"])
	return "최근 수동 무역 실행\n%s ↔ %s\n%s\n선택 성 창고에 반영되었습니다." % [
		_city_name(source_city_id), _city_name(str(result.get("target_city_id", ""))),
		format_manual_trade_nonzero_preview_summary(applied),
	]


func format_external_trade_manual_order_summary(source_city_id: String, candidate_city_ids: Array[String]) -> String:
	var chancellor_text := str(_host.call("_format_chancellor_external_auto_trade_result_summary", source_city_id))
	if candidate_city_ids.is_empty():
		return chancellor_text
	var order := _controller.call("get_manual_trade_order", source_city_id) as Dictionary
	var recent_text := format_external_manual_trade_execution_result_summary(source_city_id)
	var modes: Dictionary = _host.get("_trade_control_modes")
	if str(modes.get("external_trade", "chancellor")) == "chancellor" and order.is_empty() and not chancellor_text.is_empty():
		return chancellor_text
	if order.is_empty():
		if not recent_text.is_empty():
			return recent_text
		return chancellor_text if not chancellor_text.is_empty() else "수동 무역 명령\n저장된 명령 없음\n수동 조정에서 수입/수출 계획을 입력합니다."
	var preview_text := "예상 없음"
	if order.get("preview") is Dictionary:
		preview_text = format_manual_trade_nonzero_preview_summary(order["preview"])
	var lines := ["수동 무역 명령", "상대: %s" % _city_name(str(order.get("target_city_id", ""))), "예상: %s" % preview_text, "상태: 실행 대기"]
	if not recent_text.is_empty():
		lines.append("")
		lines.append(recent_text)
	return "\n".join(lines)


func format_trade_market_prices_for_external_trade_ui() -> String:
	var result: Dictionary = _host.call("_ensure_trade_market_for_current_turn")
	var prices: Variant = result.get("prices", {})
	if not prices is Dictionary:
		return ""
	var parts: Array[String] = []
	for resource_id in ["rice", "barley", "seafood", "salt", "silk"]:
		var entry: Variant = (prices as Dictionary).get(resource_id, {})
		if not entry is Dictionary:
			continue
		var percent_delta := int(round((float((entry as Dictionary).get("multiplier", 1.0)) - 1.0) * 100.0))
		var percent_text := " (%s%%)" % _signed(percent_delta) if percent_delta != 0 else ""
		parts.append("%s %d%s" % [(entry as Dictionary).get("name", resource_id), int((entry as Dictionary).get("price", 0)), percent_text])
	return "" if parts.is_empty() else "시장가: %s" % " / ".join(parts)


func _signed(value: int) -> String:
	return "+%d" % value if value > 0 else str(value)


func _city_name(city_id: String) -> String:
	return str(_host.call("_format_city_name_by_id", city_id, city_id))
