class_name WorldMapTradeActionService
extends RefCounted

const TRADE_RESOURCE_ORDER := ["rice", "barley", "seafood", "wood", "iron", "horses", "silk", "salt"]
const ACTION_NONE := "none"
const ACTION_IMPORT := "import"
const ACTION_EXPORT := "export"
const EFFICIENCY_MIN := 0.25
const EFFICIENCY_MAX := 2.0


func execute_order(adapter: Object, order: Dictionary, context: Dictionary) -> Dictionary:
	if adapter == null or not adapter.has_method("set_city_storage"):
		return _failure("missing_adapter", "교역 실행 API가 준비되지 않았습니다.")
	var validation := validate_order(order, context)
	if not bool(validation.get("ok", false)):
		if not order.is_empty():
			validation["source_city_id"] = str(order.get("source_city_id", ""))
			validation["target_city_id"] = str(order.get("target_city_id", ""))
		return validation
	var source_city_id := str(order.get("source_city_id", ""))
	var target_city_id := str(order.get("target_city_id", ""))
	var applied := build_preview(order, context)
	var storage_variant: Variant = context.get("source_storage", {})
	if not storage_variant is Dictionary or (storage_variant as Dictionary).is_empty():
		return _failure("invalid_storage", "교역 출발 도시의 창고를 확인할 수 없습니다.")
	var source_storage := (storage_variant as Dictionary).duplicate(true)
	for resource_id in ["gold"] + TRADE_RESOURCE_ORDER:
		var delta := int(applied.get(resource_id, 0))
		if delta != 0:
			source_storage[resource_id] = maxi(0, int(source_storage.get(resource_id, 0)) + delta)
	adapter.call("set_city_storage", source_city_id, source_storage)
	return {
		"ok": true,
		"source_city_id": source_city_id,
		"target_city_id": target_city_id,
		"target_faction_id": str(context.get("target_faction_id", "")),
		"applied": applied,
		"efficiency": float(applied.get("efficiency", context.get("efficiency", 0.0))),
		"market_turn": int(applied.get("market_turn", context.get("market_turn", 0))),
		"market_prices": (context.get("market_prices", {}) as Dictionary).duplicate(true),
		"message": "수동 무역 실행 완료",
	}


func validate_order(order: Dictionary, context: Dictionary) -> Dictionary:
	if order.is_empty():
		return _failure("missing_order", "실행할 수동 무역 명령이 없습니다.")
	var source_city_id := str(order.get("source_city_id", ""))
	var target_city_id := str(order.get("target_city_id", ""))
	if source_city_id.is_empty():
		return _failure("source", "출발 성을 확인할 수 없습니다.")
	if not bool(context.get("source_owned", false)):
		return _failure("source_owner", "플레이어 소유 성에서만 실행할 수 있습니다.")
	if target_city_id.is_empty():
		return _failure("target", "교역 대상을 확인할 수 없습니다.")
	if not bool(context.get("target_candidate", false)):
		return _failure("target_invalid", "교역 대상이 더 이상 유효하지 않습니다.")
	var source_faction_id := str(context.get("source_faction_id", ""))
	var target_faction_id := str(context.get("target_faction_id", ""))
	if source_faction_id.is_empty() or target_faction_id.is_empty() or source_faction_id == target_faction_id:
		return _failure("faction", "교역 대상 세력을 확인할 수 없습니다.")
	if not bool(context.get("can_trade", false)):
		return _failure("relation", "현재 관계에서는 교역할 수 없습니다.")
	var efficiency := float(context.get("efficiency", 0.0))
	if efficiency <= 0.0:
		return _failure("efficiency", "교역 효율을 확인할 수 없습니다.")
	var orders_variant: Variant = order.get("orders", {})
	if not orders_variant is Dictionary:
		return _failure("orders", "실행할 수동 무역 명령이 없습니다.")
	var prices: Dictionary = context.get("market_prices", {})
	var source_storage: Dictionary = context.get("source_storage", {})
	var total_import_gold_cost := 0
	var has_actionable_item := false
	for resource_id_variant in (orders_variant as Dictionary).keys():
		var resource_id := str(resource_id_variant)
		if not TRADE_RESOURCE_ORDER.has(resource_id):
			return _failure("resource", "허용되지 않은 자원입니다.")
		var item_variant: Variant = (orders_variant as Dictionary).get(resource_id, {})
		if not item_variant is Dictionary:
			return _failure("order_item", "수동 무역 명령 형식이 올바르지 않습니다.")
		var action := str((item_variant as Dictionary).get("action", ACTION_NONE))
		var amount := int((item_variant as Dictionary).get("amount", 0))
		if amount < 0:
			return _failure("amount", "수량은 0 이상이어야 합니다.")
		if action == ACTION_NONE or amount <= 0:
			continue
		if not [ACTION_IMPORT, ACTION_EXPORT].has(action):
			return _failure("action", "수동 무역 행동이 올바르지 않습니다.")
		has_actionable_item = true
		if action == ACTION_IMPORT:
			total_import_gold_cost += calculate_import_cost(int(prices.get(resource_id, 0)), amount, efficiency)
		elif amount > int(source_storage.get(resource_id, 0)):
			return _failure("resource_shortage", "수출할 자원이 부족합니다.")
	if not has_actionable_item:
		return _failure("empty", "실행 가능한 자원 항목이 없습니다.")
	if total_import_gold_cost > int(source_storage.get("gold", 0)):
		return _failure("gold", "금전이 부족합니다.")
	return {"ok": true}


func build_preview(order: Dictionary, context: Dictionary) -> Dictionary:
	var delta := {"gold": 0}
	for resource_id in TRADE_RESOURCE_ORDER:
		delta[resource_id] = 0
	var efficiency := float(context.get("efficiency", 0.0))
	delta["efficiency"] = efficiency
	delta["market_turn"] = maxi(0, int(context.get("market_turn", 0)))
	var orders_variant: Variant = order.get("orders", {})
	if not orders_variant is Dictionary or efficiency <= 0.0:
		return delta
	var prices: Dictionary = context.get("market_prices", {})
	for resource_id in TRADE_RESOURCE_ORDER:
		var item_variant: Variant = (orders_variant as Dictionary).get(resource_id, {})
		if not item_variant is Dictionary:
			continue
		var action := str((item_variant as Dictionary).get("action", ACTION_NONE))
		var amount := maxi(0, int((item_variant as Dictionary).get("amount", 0)))
		var price := int(prices.get(resource_id, 0))
		if action == ACTION_IMPORT and amount > 0:
			delta[resource_id] = amount
			delta["gold"] = int(delta["gold"]) - calculate_import_cost(price, amount, efficiency)
		elif action == ACTION_EXPORT and amount > 0:
			delta[resource_id] = -amount
			delta["gold"] = int(delta["gold"]) + calculate_export_gain(price, amount, efficiency)
	return delta


func calculate_import_cost(base_price: int, amount: int, efficiency: float) -> int:
	if amount <= 0 or efficiency <= 0.0:
		return 0
	return maxi(0, ceili(float(maxi(0, base_price) * amount) / normalize_efficiency(efficiency)))


func calculate_export_gain(base_price: int, amount: int, efficiency: float) -> int:
	if amount <= 0 or efficiency <= 0.0:
		return 0
	return maxi(0, floori(float(maxi(0, base_price) * amount) * normalize_efficiency(efficiency)))


func normalize_efficiency(efficiency: float) -> float:
	return clampf(efficiency, EFFICIENCY_MIN, EFFICIENCY_MAX)


func _failure(reason: String, message: String) -> Dictionary:
	return {"ok": false, "success": false, "reason": reason, "message": message}
