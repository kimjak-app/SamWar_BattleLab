class_name WorldMapTradeAutomationService
extends RefCounted

const RESOURCE_ORDER := ["rice", "barley", "seafood", "wood", "iron", "horses", "silk", "salt"]
const STORAGE_TARGETS := {
	"gold": 100,
	"rice": 120,
	"barley": 100,
	"seafood": 50,
	"wood": 40,
	"iron": 30,
	"horses": 20,
	"silk": 20,
	"salt": 40,
}
const INTERNAL_TOTAL_CAP := 200
const INTERNAL_BASE_CAP := 20
const INTERNAL_APTITUDE_CAP := 30
const EXTERNAL_BASE_CAP := 20
const EXTERNAL_APTITUDE_CAP := 30
const EXTERNAL_TRADE_POLICY_CAP := 35
const GOLD_CAP := 100
const DEFAULT_BUFFER := 20
const GOLD_BUFFER := 50


func run_chancellor_auto_trade(adapter: Object, turn_number: int) -> Dictionary:
	var safe_turn := maxi(1, turn_number)
	var state: Dictionary = adapter.call("get_player_state")
	if int(state.get("last_chancellor_auto_trade_turn", 0)) == safe_turn:
		var previous_result: Variant = state.get("last_chancellor_auto_trade_result", {})
		if previous_result is Dictionary and not (previous_result as Dictionary).is_empty():
			return (previous_result as Dictionary).duplicate(true)
		return {"ok": false, "reason": "already_applied", "turn": safe_turn, "message": "이번 턴 재상 자동무역은 이미 처리되었습니다."}
	var chancellor_id := str(state.get("chancellor_id", ""))
	if chancellor_id.is_empty():
		return _record(adapter, {"turn": safe_turn, "ok": false, "reason": "no_chancellor", "message": "재상이 없어 자동무역을 실행하지 않았습니다."})
	var chancellor_data: Dictionary = adapter.call("get_hero_entry", chancellor_id)
	if chancellor_data.is_empty() or str(chancellor_data.get("side", "")) != str(adapter.call("get_current_player_faction_id")):
		return _record(adapter, {"turn": safe_turn, "ok": false, "reason": "invalid_chancellor", "chancellor_id": chancellor_id, "message": "재상 정보를 확인할 수 없어 자동무역을 실행하지 않았습니다."})
	var owned_city_ids: Array[String] = adapter.call("get_player_owned_city_ids_for_trade")
	if owned_city_ids.is_empty():
		return _record(adapter, {"turn": safe_turn, "ok": false, "reason": "no_player_city", "chancellor_id": chancellor_id, "message": "플레이어 소유 성이 없어 자동무역을 실행하지 않았습니다."})
	var policy_id := str(adapter.call("normalize_chancellor_policy_id", str(state.get("chancellor_policy_id", "balanced"))))
	var internal_enabled := bool(adapter.call("is_chancellor_trade_mode_enabled", "internal_trade"))
	var external_enabled := bool(adapter.call("is_chancellor_trade_mode_enabled", "external_trade"))
	if not internal_enabled and not external_enabled:
		return _record(adapter, {"turn": safe_turn, "ok": false, "reason": "disabled", "chancellor_id": chancellor_id, "policy_id": policy_id, "message": "재상 일임 무역 모드가 없어 자동무역을 실행하지 않았습니다."})
	var internal_result := {"enabled": internal_enabled, "applied": []}
	var external_result := {"enabled": external_enabled, "applied": []}
	if internal_enabled:
		internal_result = _apply_internal(adapter, owned_city_ids, policy_id, chancellor_data)
	if external_enabled:
		external_result = _apply_external(adapter, owned_city_ids, policy_id, chancellor_data)
	var applied_count := int((internal_result.get("applied", []) as Array).size()) + int((external_result.get("applied", []) as Array).size())
	var result := {"turn": safe_turn, "ok": applied_count > 0, "chancellor_id": chancellor_id, "policy_id": policy_id, "internal": internal_result, "external": external_result, "message": "재상 자동무역 적용" if applied_count > 0 else "이번 턴 적용된 자동무역 없음"}
	if applied_count <= 0:
		result["reason"] = "no_actionable_trade"
	return _record(adapter, result)


func _record(adapter: Object, result: Dictionary) -> Dictionary:
	adapter.call("record_chancellor_auto_trade_result", result)
	return result


func _resource_priority(policy_id: String, trade_type: String) -> Array[String]:
	var priority: Array[String] = []
	match policy_id:
		"agriculture": priority = ["rice", "barley", "seafood", "salt", "gold", "wood", "iron", "horses", "silk"]
		"commerce": priority = ["gold", "silk", "salt", "seafood", "wood", "rice", "barley", "iron", "horses"]
		"trade": priority = ["seafood", "salt", "silk", "gold", "rice", "barley", "wood", "iron", "horses"]
		"military": priority = ["iron", "horses", "wood", "rice", "barley", "gold", "salt", "seafood", "silk"]
		_: priority = ["gold", "rice", "barley", "seafood", "wood", "iron", "horses", "salt", "silk"]
	if trade_type == "external":
		var external_priority: Array[String] = []
		for resource_id in priority:
			if resource_id != "gold":
				external_priority.append(resource_id)
		return external_priority
	return priority


func _resource_cap(policy_id: String, trade_type: String, resource_id: String, chancellor_data: Dictionary) -> int:
	var cap := INTERNAL_BASE_CAP if trade_type == "internal" else EXTERNAL_BASE_CAP
	if _has_cap_aptitude(chancellor_data):
		cap = INTERNAL_APTITUDE_CAP if trade_type == "internal" else EXTERNAL_APTITUDE_CAP
	if trade_type == "external" and policy_id == "trade":
		cap = EXTERNAL_TRADE_POLICY_CAP
	if resource_id == "gold":
		cap = mini(cap, GOLD_CAP)
	return cap


func _has_cap_aptitude(chancellor_data: Dictionary) -> bool:
	for type_id in [str(chancellor_data.get("chancellor_primary_type", "")), str(chancellor_data.get("chancellor_secondary_type", ""))]:
		if ["diplomatic", "economic", "administrative"].has(type_id):
			return true
	return false


func _target_min(resource_id: String) -> int:
	return maxi(0, int(STORAGE_TARGETS.get(resource_id, 0)))


func _surplus_buffer(resource_id: String) -> int:
	return GOLD_BUFFER if resource_id == "gold" else DEFAULT_BUFFER


func _storage_amount(storage: Dictionary, resource_id: String) -> int:
	return maxi(0, int(storage.get(resource_id, 0)))


func _apply_internal(adapter: Object, owned_city_ids: Array[String], policy_id: String, chancellor_data: Dictionary) -> Dictionary:
	var applied: Array = []
	var total_moved := 0
	for resource_id in _resource_priority(policy_id, "internal"):
		if total_moved >= INTERNAL_TOTAL_CAP:
			break
		var target_min := _target_min(resource_id)
		var buffer := _surplus_buffer(resource_id)
		for demand in _target_demands(adapter, owned_city_ids, resource_id, target_min):
			if total_moved >= INTERNAL_TOTAL_CAP:
				break
			var target_city_id := str(demand.get("city_id", ""))
			var connected_city_ids: Array[String] = adapter.call("get_internal_trade_connected_player_city_ids", target_city_id)
			if connected_city_ids.is_empty():
				continue
			var target_storage: Dictionary = adapter.call("get_city_storage", target_city_id)
			var deficit := target_min - _storage_amount(target_storage, resource_id)
			if deficit <= 0:
				continue
			var source_city_id := _select_internal_source(adapter, connected_city_ids, resource_id, target_min, buffer)
			if source_city_id.is_empty():
				continue
			var source_storage: Dictionary = adapter.call("get_city_storage", source_city_id)
			var surplus := _storage_amount(source_storage, resource_id) - target_min - buffer
			var cap := _resource_cap(policy_id, "internal", resource_id, chancellor_data)
			var move_amount := mini(deficit, mini(surplus, mini(cap, INTERNAL_TOTAL_CAP - total_moved)))
			if move_amount <= 0:
				continue
			source_storage[resource_id] = _storage_amount(source_storage, resource_id) - move_amount
			target_storage[resource_id] = _storage_amount(target_storage, resource_id) + move_amount
			adapter.call("set_city_storage", source_city_id, source_storage)
			adapter.call("set_city_storage", target_city_id, target_storage)
			applied.append({"source_city_id": source_city_id, "target_city_id": target_city_id, "amounts": {resource_id: move_amount}})
			total_moved += move_amount
	return {"enabled": true, "applied": applied, "total_moved": total_moved}


func _target_demands(adapter: Object, owned_city_ids: Array[String], resource_id: String, target_min: int) -> Array:
	var demands: Array = []
	for city_id in owned_city_ids:
		var storage: Dictionary = adapter.call("get_city_storage", city_id)
		var deficit := target_min - _storage_amount(storage, resource_id)
		if deficit > 0:
			demands.append({"city_id": city_id, "deficit": deficit})
	demands.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a.get("deficit", 0)) > int(b.get("deficit", 0)))
	return demands


func _select_internal_source(adapter: Object, candidate_city_ids: Array[String], resource_id: String, target_min: int, buffer: int) -> String:
	var selected_source_city_id := ""
	var selected_surplus := 0
	for candidate_city_id in candidate_city_ids:
		var storage: Dictionary = adapter.call("get_city_storage", candidate_city_id)
		var surplus := _storage_amount(storage, resource_id) - target_min - buffer
		if surplus > selected_surplus:
			selected_surplus = surplus
			selected_source_city_id = candidate_city_id
	return selected_source_city_id


func _apply_external(adapter: Object, owned_city_ids: Array[String], policy_id: String, chancellor_data: Dictionary) -> Dictionary:
	var applied: Array = []
	var priority := _resource_priority(policy_id, "external")
	for source_city_id in owned_city_ids:
		var candidate_city_ids := _external_candidates(adapter, source_city_id)
		if candidate_city_ids.is_empty():
			continue
		var target_city_id := candidate_city_ids[0]
		var efficiency := float(adapter.call("get_trade_efficiency_for_cities", source_city_id, target_city_id))
		if efficiency <= 0.0:
			continue
		var source_storage: Dictionary = adapter.call("get_city_storage", source_city_id)
		var applied_delta := _empty_external_delta()
		if _storage_amount(source_storage, "gold") < _target_min("gold") or ["commerce", "trade"].has(policy_id):
			_apply_external_export(adapter, source_storage, applied_delta, priority, policy_id, chancellor_data, efficiency)
		_apply_external_import(adapter, source_storage, applied_delta, priority, policy_id, chancellor_data, efficiency)
		if _external_delta_empty(applied_delta):
			continue
		adapter.call("set_city_storage", source_city_id, source_storage)
		applied.append({"source_city_id": source_city_id, "target_city_id": target_city_id, "target_faction_id": str(adapter.call("get_city_owner_faction_id", target_city_id)), "applied": applied_delta, "efficiency": efficiency, "market_turn": int(adapter.call("get_trade_market_turn")), "market_prices": adapter.call("get_trade_market_price_snapshot_for_delta", applied_delta)})
	return {"enabled": true, "applied": applied}


func _external_candidates(adapter: Object, source_city_id: String) -> Array[String]:
	var result: Array[String] = []
	var source_faction_id := str(adapter.call("get_city_owner_faction_id", source_city_id))
	for candidate_city_id in adapter.call("get_external_trade_candidate_city_ids", source_city_id):
		var target_faction_id := str(adapter.call("get_city_owner_faction_id", candidate_city_id))
		if adapter.call("can_trade_between_factions", source_faction_id, target_faction_id):
			result.append(candidate_city_id)
	result.sort_custom(func(a: String, b: String) -> bool: return float(adapter.call("get_trade_efficiency_for_cities", source_city_id, a)) > float(adapter.call("get_trade_efficiency_for_cities", source_city_id, b)))
	return result


func _empty_external_delta() -> Dictionary:
	var delta := {"gold": 0}
	for resource_id in RESOURCE_ORDER:
		delta[resource_id] = 0
	return delta


func _external_delta_empty(delta: Dictionary) -> bool:
	for resource_id in ["gold"] + RESOURCE_ORDER:
		if int(delta.get(resource_id, 0)) != 0:
			return false
	return true


func _apply_external_export(adapter: Object, source_storage: Dictionary, applied_delta: Dictionary, priority: Array[String], policy_id: String, chancellor_data: Dictionary, efficiency: float) -> void:
	for resource_id in priority:
		var surplus := _storage_amount(source_storage, resource_id) - _target_min(resource_id) - _surplus_buffer(resource_id)
		if surplus <= 0:
			continue
		var amount := mini(surplus, _resource_cap(policy_id, "external", resource_id, chancellor_data))
		var gold_gain := mini(int(adapter.call("calculate_trade_export_gain", resource_id, amount, efficiency)), GOLD_CAP)
		if amount <= 0 or gold_gain <= 0:
			continue
		source_storage[resource_id] = _storage_amount(source_storage, resource_id) - amount
		source_storage["gold"] = _storage_amount(source_storage, "gold") + gold_gain
		applied_delta[resource_id] = int(applied_delta.get(resource_id, 0)) - amount
		applied_delta["gold"] = int(applied_delta.get("gold", 0)) + gold_gain
		return


func _apply_external_import(adapter: Object, source_storage: Dictionary, applied_delta: Dictionary, priority: Array[String], policy_id: String, chancellor_data: Dictionary, efficiency: float) -> void:
	for resource_id in priority:
		var deficit := _target_min(resource_id) - _storage_amount(source_storage, resource_id)
		if deficit <= 0:
			continue
		var amount := mini(deficit, _resource_cap(policy_id, "external", resource_id, chancellor_data))
		while amount > 0 and int(adapter.call("calculate_trade_import_cost", resource_id, amount, efficiency)) > _storage_amount(source_storage, "gold"):
			amount -= 1
		if amount <= 0:
			continue
		var gold_cost := int(adapter.call("calculate_trade_import_cost", resource_id, amount, efficiency))
		if gold_cost <= 0:
			continue
		source_storage["gold"] = _storage_amount(source_storage, "gold") - gold_cost
		source_storage[resource_id] = _storage_amount(source_storage, resource_id) + amount
		applied_delta["gold"] = int(applied_delta.get("gold", 0)) - gold_cost
		applied_delta[resource_id] = int(applied_delta.get(resource_id, 0)) + amount
		return
