class_name WorldMapTradeActionService
extends RefCounted


func execute(
	host: Object,
	_action_id: String,
	_target_city_id: String,
	source_city_id: String = ""
) -> Dictionary:
	if host == null:
		return _failure("executor_unavailable", "교역 행동 실행기를 찾을 수 없습니다.")
	if source_city_id.is_empty():
		return _failure("missing_source", "교역 출발 도시를 확인할 수 없습니다.")
	for method_name in [
		"_validate_external_manual_trade_execution",
		"_build_external_manual_trade_execution_preview",
		"_get_city_owner_faction_id_for_trade_display",
		"_get_city_storage",
		"_get_city_hud_entry",
		"_set_city_storage",
	]:
		if not host.has_method(method_name):
			return _failure("executor_unavailable", "교역 행동 처리기를 찾을 수 없습니다: %s" % method_name)

	var raw_orders: Variant = host.get("_manual_trade_orders")
	var orders: Dictionary = raw_orders if raw_orders is Dictionary else {}
	var order_variant: Variant = orders.get(source_city_id, {})
	var order: Dictionary = order_variant if order_variant is Dictionary else {}
	var result := _execute_order(host, order)

	var raw_player_state: Variant = host.get("_player_state")
	if raw_player_state is Dictionary:
		var player_state := raw_player_state as Dictionary
		player_state["last_external_manual_trade_execution_result"] = result.duplicate(true)
		host.set("_player_state", player_state)
	if bool(result.get("ok", false)):
		orders.erase(source_city_id)
		host.set("_manual_trade_orders", orders)
	return result


func _execute_order(host: Object, order: Dictionary) -> Dictionary:
	var validation_variant: Variant = host.call("_validate_external_manual_trade_execution", order)
	if not validation_variant is Dictionary:
		return _failure("invalid_validation", "교역 행동 조건을 확인할 수 없습니다.")
	var validation := validation_variant as Dictionary
	if not bool(validation.get("ok", false)):
		if not order.is_empty():
			validation["source_city_id"] = str(order.get("source_city_id", ""))
			validation["target_city_id"] = str(order.get("target_city_id", ""))
		return validation

	var source_city_id := str(order.get("source_city_id", ""))
	var target_city_id := str(order.get("target_city_id", ""))
	var target_faction_id := str(host.call("_get_city_owner_faction_id_for_trade_display", target_city_id))
	var applied_variant: Variant = host.call("_build_external_manual_trade_execution_preview", order)
	if not applied_variant is Dictionary:
		return _failure("invalid_preview", "교역 적용값을 계산할 수 없습니다.")
	var applied := applied_variant as Dictionary
	var hud_entry: Variant = host.call("_get_city_hud_entry", source_city_id)
	var storage_variant: Variant = host.call("_get_city_storage", source_city_id, hud_entry)
	if not storage_variant is Dictionary:
		return _failure("invalid_storage", "교역 출발 도시의 창고를 확인할 수 없습니다.")
	var source_storage := storage_variant as Dictionary
	for resource_id_variant in applied.keys():
		var resource_id := str(resource_id_variant)
		var delta := int(applied.get(resource_id_variant, 0))
		if delta == 0:
			continue
		source_storage[resource_id] = maxi(0, int(source_storage.get(resource_id, 0)) + delta)
	host.call("_set_city_storage", source_city_id, source_storage)
	return {
		"ok": true,
		"source_city_id": source_city_id,
		"target_city_id": target_city_id,
		"target_faction_id": target_faction_id,
		"applied": applied,
		"message": "수동 무역 실행 완료",
	}


func _failure(reason: String, message: String) -> Dictionary:
	return {
		"ok": false,
		"success": false,
		"reason": reason,
		"message": message,
	}
