class_name TroopRebalanceService
extends RefCounted

var _query: Callable
var _mutation: Callable
var _config: Dictionary = {}


func configure(query: Callable, mutation: Callable, config: Dictionary = {}) -> void:
	_query = query
	_mutation = mutation
	_config = config.duplicate(true)


func calculate_suggestions() -> Array[Dictionary]:
	var suggestions: Array[Dictionary] = []
	var supply_states := _dictionary(_q("supply_states", [], {}))
	var city_states := _dictionary(supply_states.get("city_states", {}))
	var owned_city_ids: Variant = _q("owned_city_ids", [], [])
	if city_states.is_empty() or not owned_city_ids is Array:
		return suggestions
	var ratios := _dictionary(_config.get("role_target_garrison_ratio", {}))
	var suppliers: Array[Dictionary] = []
	var demands: Array[Dictionary] = []
	for city_id_variant in owned_city_ids:
		var city_id := str(city_id_variant)
		var city_state := _dictionary(city_states.get(city_id, {}))
		if city_state.is_empty() or not bool(_q("has_city", [city_id], false)):
			continue
		var role := str(city_state.get("role", "rear"))
		var target_ratio := float(ratios.get(role, ratios.get("rear", 0.0)))
		var target := maxi(0, int(floor(float(maxi(0, int(_q("city_population", [city_id], 0)))) * target_ratio)))
		var troops := maxi(0, int(_q("city_troops", [city_id], 0)))
		var surplus := maxi(0, troops - target)
		var shortage := maxi(0, target - troops)
		if role != "frontline" and surplus > 0:
			suppliers.append({"city_id": city_id, "role": role, "surplus": surplus})
		elif role == "frontline" and shortage > 0:
			demands.append({"city_id": city_id, "role": role, "shortage": shortage})
	demands.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a.get("shortage", 0)) > int(b.get("shortage", 0)))
	suppliers.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a.get("surplus", 0)) > int(b.get("surplus", 0)))
	for demand in demands:
		var to_id := str(demand.get("city_id", ""))
		var shortage_left := int(demand.get("shortage", 0))
		for index in range(suppliers.size()):
			if shortage_left <= 0:
				break
			var supplier: Dictionary = suppliers[index]
			var from_id := str(supplier.get("city_id", ""))
			var surplus := int(supplier.get("surplus", 0))
			var amount := mini(surplus, shortage_left)
			if amount <= 0 or not bool(_dictionary(_q("can_move_troops", [from_id, to_id, amount], {})).get("ok", false)):
				continue
			suggestions.append({"from": from_id, "to": to_id, "amount": amount, "from_role": str(supplier.get("role", "rear")), "to_role": str(demand.get("role", "frontline")), "from_surplus_before": surplus, "to_shortage_before": shortage_left})
			supplier["surplus"] = surplus - amount
			suppliers[index] = supplier
			shortage_left -= amount
	return suggestions


func apply_suggestion(suggestion: Dictionary) -> Dictionary:
	var result := {"ok": false, "from": str(suggestion.get("from", "")), "to": str(suggestion.get("to", "")), "amount": int(suggestion.get("amount", 0)), "error_code": ""}
	if str(result.from).is_empty() or str(result.to).is_empty() or int(result.amount) <= 0:
		result["error_code"] = "malformed_suggestion"
		return result
	var validation := _dictionary(_q("can_move_troops", [result.from, result.to, result.amount], {}))
	if not bool(validation.get("ok", false)):
		result["error_code"] = "move_not_allowed"
		return result
	result["ok"] = bool(_m("move_troops", [result.from, result.to, result.amount], false))
	if not bool(result.ok):
		result["error_code"] = "move_failed"
	return result


func _dictionary(value: Variant) -> Dictionary:
	return value if value is Dictionary else {}


func _q(query_id: String, args: Array = [], fallback: Variant = null) -> Variant:
	if not _query.is_valid(): return fallback
	var value: Variant = _query.call(query_id, args)
	return fallback if value == null else value


func _m(mutation_id: String, args: Array = [], fallback: Variant = null) -> Variant:
	if not _mutation.is_valid(): return fallback
	var value: Variant = _mutation.call(mutation_id, args)
	return fallback if value == null else value
