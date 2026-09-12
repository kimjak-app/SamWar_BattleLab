class_name WorldMapTradeActionService
extends RefCounted


func execute(
	host: Object,
	_action_id: String,
	_target_city_id: String,
	source_city_id: String = ""
) -> Dictionary:
	if host == null or not host.has_method("_execute_external_manual_trade_order"):
		return _failure("executor_unavailable", "교역 행동 실행기를 찾을 수 없습니다.")
	if source_city_id.is_empty():
		return _failure("missing_source", "교역 출발 도시를 확인할 수 없습니다.")

	var raw_orders: Variant = host.get("_manual_trade_orders")
	var orders: Dictionary = raw_orders if raw_orders is Dictionary else {}
	var order_variant: Variant = orders.get(source_city_id, {})
	var order: Dictionary = order_variant if order_variant is Dictionary else {}
	var raw_result: Variant = host.call("_execute_external_manual_trade_order", order)
	if not raw_result is Dictionary:
		return _failure("invalid_result", "교역 행동 결과를 처리할 수 없습니다.")
	var result := raw_result as Dictionary

	var raw_player_state: Variant = host.get("_player_state")
	if raw_player_state is Dictionary:
		var player_state := raw_player_state as Dictionary
		player_state["last_external_manual_trade_execution_result"] = result.duplicate(true)
		host.set("_player_state", player_state)
	if bool(result.get("ok", false)):
		orders.erase(source_city_id)
		host.set("_manual_trade_orders", orders)
	return result


func _failure(reason: String, message: String) -> Dictionary:
	return {
		"ok": false,
		"success": false,
		"reason": reason,
		"message": message,
	}
