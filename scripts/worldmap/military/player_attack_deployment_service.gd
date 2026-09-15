class_name PlayerAttackDeploymentService
extends RefCounted

const ExpeditionSupplyCalculatorScript := preload("res://scripts/t02/expedition_supply_calculator.gd")

var _query: Callable
var _mutation: Callable
var _config: Dictionary = {}
var _paid_transaction_ids: Dictionary = {}
var _applied_transaction_ids: Dictionary = {}
var _rolled_back_transaction_ids: Dictionary = {}


func configure(query: Callable, mutation: Callable, config: Dictionary = {}) -> void:
	_query = query
	_mutation = mutation
	_config = config.duplicate(true)


func build_payload(source_city_id: String, target_city_id: String, mode: String = "manual") -> Dictionary:
	if source_city_id.is_empty() or target_city_id.is_empty() or not bool(_q("has_city", [source_city_id], false)) or not bool(_q("has_city", [target_city_id], false)):
		return {}
	var source_troops := maxi(0, int(_q("city_troops", [source_city_id], 0)))
	var max_deployable := maxi(0, source_troops - int(_config.get("minimum_source_garrison", 1)))
	var heroes := get_deployable_heroes(source_city_id)
	if heroes.is_empty() or max_deployable <= 0:
		return {}
	var naval_unlock := _dictionary(_q("naval_unlock", [source_city_id], {}))
	var siege_unlock := _dictionary(_q("siege_unlock", [source_city_id], {}))
	return {
		"mode": "auto" if mode == "auto" else "manual",
		"source_city_id": source_city_id,
		"target_city_id": target_city_id,
		"source_troops": source_troops,
		"max_deployable_troops": max_deployable,
		"food_available": _resource(source_city_id, "rice"),
		"rice_available": _resource(source_city_id, "rice"),
		"barley_available": _resource(source_city_id, "barley"),
		"seafood_available": _resource(source_city_id, "seafood"),
		"gold_available": _resource(source_city_id, str(_config.get("gold_resource_id", "gold"))),
		"salt_available": _resource(source_city_id, str(_config.get("salt_resource_id", "salt"))),
		"naval_route_required": bool(_q("naval_route_required", [source_city_id, target_city_id], false)),
		"siege_required": bool(_q("siege_target", [target_city_id], false)),
		"domestic_tech_naval_unlock": naval_unlock,
		"domestic_tech_siege_unlock": siege_unlock,
		"heroes": heroes,
	}


func get_deployable_heroes(city_id: String) -> Array[Dictionary]:
	var heroes: Array[Dictionary] = []
	if city_id.is_empty() or not bool(_q("city_owned_by_player", [city_id], false)):
		return heroes
	for hero_id_variant in _q("city_stationed_hero_ids", [city_id], []):
		var hero_id := str(hero_id_variant)
		if hero_id.is_empty() or not bool(_q("has_hero", [hero_id], false)) or bool(_q("hero_excluded", [hero_id], true)):
			continue
		var hero_entry := _dictionary(_q("hero_data", [hero_id], {}))
		if hero_entry.is_empty():
			continue
		var command_summary := _dictionary(_q("hero_command_summary", [hero_id, city_id], {}))
		heroes.append({
			"hero_id": hero_id,
			"display_name": str(hero_entry.get("display_name", hero_entry.get("name", hero_id))),
			"state_badge": str(_q("hero_state_badge", [hero_id], "")),
			"current_city_id": str(hero_entry.get("current_city_id", hero_entry.get("city_id", city_id))),
			"war": int(hero_entry.get("war", hero_entry.get("attack", 0))),
			"intelligence": int(hero_entry.get("intelligence", 0)),
			"leadership": int(hero_entry.get("leadership", hero_entry.get("command", hero_entry.get("war", 0)))),
			"command_rank": str(command_summary.get("command_rank", _config.get("default_command_rank", "officer"))),
			"command_label": str(command_summary.get("command_label", _config.get("default_command_label", ""))),
			"command_limit": maxi(0, int(command_summary.get("command_limit", 0))),
		})
	return heroes


func validate(deployment: Dictionary) -> Dictionary:
	var result := _result("validate")
	var source_city_id := str(deployment.get("source_city_id", ""))
	var target_city_id := str(deployment.get("target_city_id", ""))
	result["source_city_id"] = source_city_id
	result["target_city_id"] = target_city_id
	if source_city_id.is_empty() or target_city_id.is_empty():
		return _reject(result, "malformed_deployment")
	var block_reason := str(_q("attack_block_reason", [target_city_id], ""))
	if not block_reason.is_empty():
		result["detail"] = block_reason
		return _reject(result, "attack_blocked")
	if source_city_id != str(_q("expected_attack_source", [target_city_id], "")):
		return _reject(result, "source_mismatch")
	var unlock_reason := str(_q("naval_siege_unlock_block_reason", [source_city_id, target_city_id], ""))
	if not unlock_reason.is_empty():
		result["detail"] = unlock_reason
		return _reject(result, "route_locked")
	var selected_hero_ids := _normalize_ids(deployment.get("selected_hero_ids", []))
	if selected_hero_ids.is_empty():
		return _reject(result, "no_hero")
	var available_ids: Array[String] = []
	for hero in get_deployable_heroes(source_city_id):
		available_ids.append(str(hero.get("hero_id", "")))
	var troop_allocation := _dictionary(deployment.get("attacker_troop_allocation", {}))
	var clamped_allocation := {}
	var total_troops := 0
	var remaining_garrison := maxi(0, int(_q("city_troops", [source_city_id], 0)) - int(_config.get("minimum_source_garrison", 1)))
	for hero_id in selected_hero_ids:
		if not available_ids.has(hero_id):
			result["hero_id"] = hero_id
			return _reject(result, "hero_unavailable")
		var command_limit := maxi(0, int(_dictionary(_q("hero_command_summary", [hero_id, source_city_id], {})).get("command_limit", 0)))
		if command_limit <= 0:
			result["hero_id"] = hero_id
			return _reject(result, "missing_command_limit")
		var requested := maxi(0, int(troop_allocation.get(hero_id, 0)))
		var troops := mini(mini(requested, command_limit), remaining_garrison)
		if troops <= 0:
			result["hero_id"] = hero_id
			return _reject(result, "zero_hero_troops")
		clamped_allocation[hero_id] = troops
		total_troops += troops
		remaining_garrison = maxi(0, remaining_garrison - troops)
	var max_deployable := maxi(0, int(_q("city_troops", [source_city_id], 0)) - int(_config.get("minimum_source_garrison", 1)))
	if total_troops <= 0 or total_troops > max_deployable:
		return _reject(result, "invalid_total_troops")
	var supplied_cost := _dictionary(deployment.get("supply_cost", {}))
	var food_type := str(deployment.get("attacker_food_type", "rice"))
	var carried_food := maxi(0, int(deployment.get("attacker_food_amount", supplied_cost.get("food", 0))))
	var carried_gold := maxi(0, int(deployment.get("attacker_carried_gold", supplied_cost.get("gold", 0))))
	var carried_salt := maxi(0, int(deployment.get("attacker_salt_amount", supplied_cost.get("salt", 0))))
	if not ExpeditionSupplyCalculatorScript.FOOD_TYPES.has(food_type):
		return _reject(result, "invalid_food_type")
	if carried_gold < ExpeditionSupplyCalculatorScript.minimum_gold(total_troops):
		return _reject(result, "insufficient_minimum_gold")
	if carried_food < ExpeditionSupplyCalculatorScript.minimum_food(total_troops):
		return _reject(result, "insufficient_minimum_food")
	var actual_cargo := {"food_type": food_type, "food": carried_food, "gold": carried_gold, "salt": carried_salt, food_type: carried_food}
	var affordability := check_affordability(source_city_id, actual_cargo)
	if not bool(affordability.get("ok", false)):
		result["resource_id"] = str(affordability.get("resource_id", ""))
		return _reject(result, str(affordability.get("error_code", "insufficient_resources")))
	result["ok"] = true
	result["selected_hero_ids"] = selected_hero_ids
	result["attacker_troop_allocation"] = clamped_allocation
	result["total_troops"] = total_troops
	result["supply_cost"] = actual_cargo
	result["food_type"] = food_type
	return result


func calculate_supply_cost(total_troops: int) -> Dictionary:
	var troops := maxi(0, total_troops)
	return {"food": ExpeditionSupplyCalculatorScript.minimum_food(troops), "gold": ExpeditionSupplyCalculatorScript.minimum_gold(troops), "salt": 0}


func check_affordability(source_city_id: String, supply_cost: Dictionary) -> Dictionary:
	var result := _result("check_supply", source_city_id)
	if source_city_id.is_empty() or not bool(_q("has_city", [source_city_id], false)):
		return _reject(result, "missing_city")
	var food_type := str(supply_cost.get("food_type", "rice"))
	if not ExpeditionSupplyCalculatorScript.FOOD_TYPES.has(food_type):
		return _reject(result, "invalid_food_type")
	for resource_id in [food_type, str(_config.get("gold_resource_id", "gold")), str(_config.get("salt_resource_id", "salt"))]:
		var cost_key: String = "food" if resource_id == food_type else resource_id
		if _resource(source_city_id, resource_id) < maxi(0, int(supply_cost.get(cost_key, 0))):
			result["resource_id"] = resource_id
			return _reject(result, "insufficient_%s" % resource_id)
	result["ok"] = true
	return result


func can_pay_supply(source_city_id: String, supply_cost: Dictionary) -> bool:
	return bool(check_affordability(source_city_id, supply_cost).get("ok", false))


func pay_supply(source_city_id: String, supply_cost: Dictionary, transaction_id: String = "legacy") -> Dictionary:
	if transaction_id != "legacy" and not transaction_id.is_empty() and _paid_transaction_ids.has(transaction_id):
		var duplicate_result := _result("pay_supply", source_city_id)
		duplicate_result["ok"] = true
		duplicate_result["duplicate"] = true
		duplicate_result["transaction_id"] = transaction_id
		return duplicate_result
	var result := check_affordability(source_city_id, supply_cost)
	result["action"] = "pay_supply"
	result["transaction_id"] = transaction_id
	if not bool(result.get("ok", false)):
		return result
	var before := _dictionary(_q("city_resource_stock", [source_city_id], {})).duplicate(true)
	var after := before.duplicate(true)
	var food_type := str(supply_cost.get("food_type", "rice"))
	after[food_type] = maxi(0, int(after.get(food_type, 0)) - maxi(0, int(supply_cost.get("food", 0))))
	for resource_id in [str(_config.get("gold_resource_id", "gold")), str(_config.get("salt_resource_id", "salt"))]:
		after[resource_id] = maxi(0, int(after.get(resource_id, 0)) - maxi(0, int(supply_cost.get(resource_id, 0))))
	if not bool(_m("set_city_resource_stock", [source_city_id, after], false)):
		return _reject(result, "resource_write_failed")
	if transaction_id != "legacy" and not transaction_id.is_empty():
		_paid_transaction_ids[transaction_id] = true
	result["resource_changes"] = {"before": before, "after": after}
	return result


func select_city_battle_supply(city_id: String) -> Dictionary:
	var selected_type := "rice"
	var selected_amount := -1
	for food_type in ExpeditionSupplyCalculatorScript.FOOD_TYPES:
		var amount := _resource(city_id, food_type)
		if amount > selected_amount:
			selected_type = food_type
			selected_amount = amount
	return {"food_type": selected_type, "food_amount": maxi(0, selected_amount), "salt_amount": _resource(city_id, str(_config.get("salt_resource_id", "salt")))}


func apply_context_side_pre_decrement(context_source: Dictionary, side_prefix: String, deployed_key: String) -> Dictionary:
	var context := context_source.duplicate(true)
	if bool(context.get(deployed_key, false)):
		return context
	var source_city_id := str(context.get("%s_source_city_id" % side_prefix, context.get("%s_city_id" % side_prefix, "")))
	var total_key := "%s_total_allocated_troops" % side_prefix
	var requested_total := maxi(0, int(context.get(total_key, 0)))
	if source_city_id.is_empty() or requested_total <= 0:
		return context
	var before := maxi(0, int(_q("city_troops", [source_city_id], 0)))
	var deployed := mini(requested_total, before)
	var after := maxi(0, before - deployed)
	context[total_key] = deployed
	context["%s_source_city_id" % side_prefix] = source_city_id
	context["%s_source_city_troops_before" % side_prefix] = before
	context["%s_source_city_troops_after" % side_prefix] = after
	context[deployed_key] = deployed > 0
	_m("set_city_troops", [source_city_id, after], null)
	return context


func move_generals_for_expedition(source_city_id: String, hero_ids_source: Array[String]) -> Dictionary:
	var result := _result("move_generals", source_city_id)
	if source_city_id.is_empty() or not bool(_q("has_city", [source_city_id], false)):
		return _reject(result, "missing_city")
	var stationed := _normalize_ids(_q("city_stationed_hero_ids", [source_city_id], []))
	var moved: Array[String] = []
	for hero_id in _normalize_ids(hero_ids_source):
		if not stationed.has(hero_id) or not bool(_q("has_hero", [hero_id], false)):
			continue
		stationed.erase(hero_id)
		var hero_state := _dictionary(_q("hero_state", [hero_id], {})).duplicate(true)
		hero_state["current_city_id"] = ""
		hero_state["city_id"] = ""
		hero_state["location_city_id"] = ""
		hero_state["status"] = "deployed"
		_m("set_hero_state", [hero_id, hero_state], null)
		moved.append(hero_id)
	_m("set_city_stationed_hero_ids", [source_city_id, stationed], null)
	result["ok"] = true
	result["hero_ids"] = moved
	return result


func apply_departure(context_source: Dictionary, hero_ids: Array[String], supply_cost: Dictionary) -> Dictionary:
	var result := _result("apply_departure")
	var transaction_id := str(context_source.get("transaction_id", ""))
	result["transaction_id"] = transaction_id
	if context_source.is_empty() or transaction_id.is_empty():
		return _reject(result, "missing_transaction_id")
	if _applied_transaction_ids.has(transaction_id):
		result["ok"] = true
		result["duplicate"] = true
		result["context"] = context_source.duplicate(true)
		return result
	_rolled_back_transaction_ids.erase(transaction_id)
	var source_city_id := str(context_source.get("attacker_source_city_id", context_source.get("attacker_city_id", "")))
	var affordability := check_affordability(source_city_id, supply_cost)
	if not bool(affordability.get("ok", false)):
		return affordability
	var context := apply_context_side_pre_decrement(context_source, "attacker", "troop_deployed_from_city")
	context = apply_context_side_pre_decrement(context, "defender", "defender_troop_deployed_from_city")
	var payment := pay_supply(source_city_id, supply_cost, transaction_id)
	if not bool(payment.get("ok", false)):
		rollback_departure(context)
		return payment
	move_generals_for_expedition(source_city_id, hero_ids)
	_applied_transaction_ids[transaction_id] = true
	result["ok"] = true
	result["context"] = context
	result["resource_changes"] = payment.get("resource_changes", {})
	result["hero_ids"] = _normalize_ids(hero_ids)
	return result


func rollback_departure(context: Dictionary) -> Dictionary:
	var result := _result("rollback")
	var transaction_id := str(context.get("transaction_id", ""))
	result["transaction_id"] = transaction_id
	if not transaction_id.is_empty() and _rolled_back_transaction_ids.has(transaction_id):
		result["ok"] = true
		result["duplicate"] = true
		return result
	var source_city_id := str(context.get("attacker_source_city_id", context.get("attacker_city_id", "")))
	if bool(context.get("troop_deployed_from_city", false)) or context.has("attacker_source_city_troops_before"):
		_m("set_city_troops", [source_city_id, maxi(0, int(context.get("attacker_source_city_troops_before", _q("city_troops", [source_city_id], 0))))], null)
	var defender_city_id := str(context.get("defender_source_city_id", context.get("defender_city_id", "")))
	if bool(context.get("defender_troop_deployed_from_city", false)):
		_m("set_city_troops", [defender_city_id, maxi(0, int(context.get("defender_source_city_troops_before", _q("city_troops", [defender_city_id], 0))))], null)
	if _paid_transaction_ids.has(transaction_id) or transaction_id.is_empty() or transaction_id == "legacy":
		var stock := _dictionary(_q("city_resource_stock", [source_city_id], {})).duplicate(true)
		var food_type := str(context.get("attacker_food_type", "rice"))
		stock[food_type] = maxi(0, int(stock.get(food_type, 0))) + maxi(0, int(context.get("attacker_food_amount", 0)))
		stock[str(_config.get("gold_resource_id", "gold"))] = maxi(0, int(stock.get(str(_config.get("gold_resource_id", "gold")), 0))) + maxi(0, int(context.get("attacker_carried_gold", 0)))
		stock[str(_config.get("salt_resource_id", "salt"))] = maxi(0, int(stock.get(str(_config.get("salt_resource_id", "salt")), 0))) + maxi(0, int(context.get("attacker_salt_amount", 0)))
		_m("set_city_resource_stock", [source_city_id, stock], null)
	for hero_id in _normalize_ids(context.get("attacker_general_ids", [])):
		_m("restore_hero_to_city", [hero_id, source_city_id], null)
	_paid_transaction_ids.erase(transaction_id)
	_applied_transaction_ids.erase(transaction_id)
	if not transaction_id.is_empty():
		_rolled_back_transaction_ids[transaction_id] = true
	result["ok"] = true
	result["rolled_back"] = true
	return result


func _resource(city_id: String, resource_id: String) -> int:
	return maxi(0, int(_q("city_resource_amount", [city_id, resource_id], 0)))


func _normalize_ids(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if value is Array:
		for raw_id in value:
			var id := str(raw_id)
			if not id.is_empty() and not result.has(id):
				result.append(id)
	return result


func _result(action: String, city_id: String = "") -> Dictionary:
	return {"ok": false, "action": action, "source_city_id": city_id, "target_city_id": "", "transaction_id": "", "hero_id": "", "hero_ids": [], "selected_hero_ids": [], "attacker_troop_allocation": {}, "total_troops": 0, "supply_cost": {}, "resource_changes": {}, "context": {}, "duplicate": false, "rolled_back": false, "resource_id": "", "detail": "", "error_code": "", "warnings": []}


func _reject(result: Dictionary, error_code: String) -> Dictionary:
	result["ok"] = false
	result["error_code"] = error_code
	(result["warnings"] as Array).append(error_code)
	return result


func _dictionary(value: Variant) -> Dictionary:
	return value if value is Dictionary else {}


func _q(query_id: String, args: Array = [], fallback: Variant = null) -> Variant:
	if not _query.is_valid():
		return fallback
	var value: Variant = _query.call(query_id, args)
	return fallback if value == null else value


func _m(mutation_id: String, args: Array = [], fallback: Variant = null) -> Variant:
	if not _mutation.is_valid():
		return fallback
	var value: Variant = _mutation.call(mutation_id, args)
	return fallback if value == null else value
