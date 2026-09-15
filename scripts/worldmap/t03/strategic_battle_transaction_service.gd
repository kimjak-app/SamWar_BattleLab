class_name StrategicBattleTransactionService
extends RefCounted

const ExpeditionSupplyCalculatorScript := preload("res://scripts/t02/expedition_supply_calculator.gd")

var _query: Callable
var _mutation: Callable
var _resolver: Callable
var _config: Dictionary = {}


func configure(query: Callable, mutation: Callable, resolver: Callable, config: Dictionary = {}) -> void:
	_query = query
	_mutation = mutation
	_resolver = resolver
	_config = config.duplicate(true)


func make_transaction_id(attacker_city_id: String, defender_city_id: String) -> String:
	return "t03-%d-%s-%s" % [maxi(1, int(_q("turn_number", [], 1))), attacker_city_id, defender_city_id]


func build_expedition_cargo_plan(city_id: String, troops: int) -> Dictionary:
	var stock := _food_stock(city_id)
	var target_food := ExpeditionSupplyCalculatorScript.food_per_turn(troops, false) * ExpeditionSupplyCalculatorScript.BATTLE_MAX_TURNS
	var food_stock := {"rice": 0, "barley": 0, "seafood": 0}
	var load_target := mini(target_food, sum_food_stock(stock))
	var food_left := load_target
	while food_left > 0:
		var selected_type := select_food_type(stock)
		var selected_amount := maxi(0, int(stock.get(selected_type, 0)))
		if selected_amount <= 0:
			break
		var loaded := mini(selected_amount, food_left)
		food_stock[selected_type] = int(food_stock.get(selected_type, 0)) + loaded
		stock[selected_type] = selected_amount - loaded
		food_left -= loaded
	var gold := ExpeditionSupplyCalculatorScript.minimum_gold(troops)
	var salt := mini(
		maxi(0, int(_q("city_resource_amount", [city_id, "salt"], 0))),
		ExpeditionSupplyCalculatorScript.salt_per_turn(troops) * ExpeditionSupplyCalculatorScript.BATTLE_MAX_TURNS
	)
	var food_total := load_target - food_left
	return {
		"gold": gold,
		"food_stock": food_stock,
		"food_total": food_total,
		"salt": salt,
		"ok": int(_q("city_resource_amount", [city_id, "gold"], 0)) >= gold \
			and food_total >= ExpeditionSupplyCalculatorScript.minimum_food(troops),
	}


func filter_context_heroes(raw_heroes: Variant, hero_ids: Array[String], allocation: Dictionary) -> Array[Dictionary]:
	var filtered: Array[Dictionary] = []
	if not raw_heroes is Array:
		return filtered
	for hero_variant in raw_heroes:
		if not hero_variant is Dictionary:
			continue
		var hero := (hero_variant as Dictionary).duplicate(true)
		var hero_id := str(hero.get("hero_id", hero.get("id", "")))
		if not hero_ids.has(hero_id):
			continue
		var troops := maxi(0, int(allocation.get(hero_id, 0)))
		if troops <= 0:
			continue
		hero["troops"] = troops
		hero["troop_count"] = troops
		hero["allocated_troops"] = troops
		filtered.append(hero)
	return filtered


func select_food_type(food_stock: Dictionary) -> String:
	var selected := "rice"
	var selected_amount := -1
	for food_type in ExpeditionSupplyCalculatorScript.FOOD_TYPES:
		var amount := maxi(0, int(food_stock.get(food_type, 0)))
		if amount > selected_amount:
			selected = food_type
			selected_amount = amount
	return selected


func sum_food_stock(food_stock: Dictionary) -> int:
	var total := 0
	for food_type in ExpeditionSupplyCalculatorScript.FOOD_TYPES:
		total += maxi(0, int(food_stock.get(food_type, 0)))
	return total


func get_city_food_stock(city_id: String) -> Dictionary:
	return _food_stock(city_id)


func prepare(event: Dictionary, base_context: Dictionary, resolution_mode: String) -> Dictionary:
	var report := _transaction_report(event)
	var attacker_city_id := str(event.get("attacker_city_id", ""))
	var defender_city_id := str(event.get("defender_city_id", ""))
	if attacker_city_id.is_empty() or defender_city_id.is_empty():
		return _reject(report, "missing_city_id")
	if not bool(_q("invasion_pair_eligible", [attacker_city_id, defender_city_id], false)):
		return _reject(report, "ineligible_invasion_pair")
	var context := base_context.duplicate(true)
	var attacker_hero_ids := _hero_ids(context.get("attacker_main_hero_ids", context.get("attacker_hero_ids", [])))
	var defender_hero_ids := _hero_ids(context.get("selected_defender_hero_ids", []))
	if defender_hero_ids.is_empty():
		defender_hero_ids = _hero_ids(context.get("defender_main_hero_ids", context.get("defender_hero_ids", [])))
	if attacker_hero_ids.is_empty() or defender_hero_ids.is_empty():
		return _reject(report, "missing_eligible_heroes")
	var minimum_garrison := maxi(0, int(_config.get("minimum_source_troops", 1)))
	var attacker_available := maxi(0, int(_q("city_troops", [attacker_city_id], 0)) - minimum_garrison)
	var defender_available := maxi(0, int(_q("city_troops", [defender_city_id], 0)) )
	var attacker_allocation := _allocation(attacker_hero_ids, attacker_available, attacker_city_id)
	var defender_allocation: Dictionary = _dictionary(context.get("defender_troop_allocation", {})).duplicate(true)
	if resolution_mode == "automatic" or defender_allocation.is_empty():
		defender_allocation = _allocation(defender_hero_ids, defender_available, defender_city_id)
	var attacker_total := _sum_allocation(attacker_allocation)
	var defender_total := _sum_allocation(defender_allocation)
	if attacker_total <= 0 or defender_total <= 0:
		return _reject(report, "empty_troop_allocation")
	var cargo := build_expedition_cargo_plan(attacker_city_id, attacker_total)
	report["cargo_plan"] = cargo.duplicate(true)
	if not bool(cargo.get("ok", false)):
		return _reject(report, "insufficient_cargo")
	var rollback_state: Dictionary = _dictionary(_q("serialize_state", [], {})).duplicate(true)
	if rollback_state.is_empty():
		return _reject(report, "missing_rollback_snapshot")
	var rollback_player := _dictionary(rollback_state.get("player_state", {})).duplicate(true)
	rollback_player["pending_invasion_event"] = event.duplicate(true)
	rollback_state["player_state"] = rollback_player
	var attacker_food_stock := _dictionary(cargo.get("food_stock", {})).duplicate(true)
	var defender_food_stock := _food_stock(defender_city_id)
	context["type"] = "defense"
	context["source"] = "enemy_invasion"
	context["transaction_id"] = str(event.get("transaction_id", make_transaction_id(attacker_city_id, defender_city_id)))
	context["scenario_id"] = str(_q("scenario_id", [], "korea_mvp_four_cities"))
	context["resolution_mode"] = resolution_mode
	context["mode"] = "auto" if resolution_mode == "automatic" else "manual"
	context["player_side"] = "defender" if str(_q("city_owner", [defender_city_id], "")) == str(_q("player_faction", [], "")) else ""
	context["attacker_faction_id"] = str(_q("city_owner", [attacker_city_id], ""))
	context["defender_faction_id"] = str(_q("city_owner", [defender_city_id], ""))
	context["attacker_general_ids"] = attacker_hero_ids
	context["defender_general_ids"] = defender_hero_ids
	context["attacker_troop_allocation"] = attacker_allocation
	context["defender_troop_allocation"] = defender_allocation
	context["attacker_total_allocated_troops"] = attacker_total
	context["defender_total_allocated_troops"] = defender_total
	context["attacker_heroes"] = filter_context_heroes(context.get("attacker_heroes", []), attacker_hero_ids, attacker_allocation)
	context["defender_heroes"] = filter_context_heroes(context.get("defender_heroes", []), defender_hero_ids, defender_allocation)
	context["attacker_food_stock"] = attacker_food_stock
	context["attacker_food_type"] = select_food_type(attacker_food_stock)
	context["attacker_food_amount"] = int(cargo.get("food_total", 0))
	context["attacker_carried_gold"] = int(cargo.get("gold", 0))
	context["attacker_salt_amount"] = int(cargo.get("salt", 0))
	context["defender_food_stock"] = defender_food_stock
	context["defender_food_type"] = select_food_type(defender_food_stock)
	context["defender_food_amount"] = sum_food_stock(defender_food_stock)
	context["defender_carried_gold"] = maxi(0, int(_q("city_resource_amount", [defender_city_id, "gold"], 0)))
	context["defender_salt_amount"] = maxi(0, int(_q("city_resource_amount", [defender_city_id, "salt"], 0)))
	var defense := float(_q("city_defense", [defender_city_id], 0.0))
	var technology_bonus := float(_q("player_defense_bonus", [defender_city_id], 0.0)) if bool(_q("city_owned_by_player", [defender_city_id], false)) else 0.0
	context["defender_auto_defense_bonus"] = clampf(defense * 0.01 + technology_bonus, 0.0, 0.15)
	context["rollback_worldmap_state"] = rollback_state
	var payment := pay_expedition_cargo(attacker_city_id, cargo)
	report["cargo_paid"] = payment
	if not bool(payment.get("ok", false)):
		rollback(context)
		report["cargo_rolled_back"] = true
		return _reject(report, "cargo_payment_failed")
	context = _pre_decrement(context, "attacker", "attacker_troop_deployed_from_city")
	context = _pre_decrement(context, "defender", "defender_troop_deployed_from_city")
	if not bool(_m("move_pending_generals", [attacker_city_id, attacker_hero_ids], false)) \
		or not bool(_m("move_pending_generals", [defender_city_id, defender_hero_ids], false)):
		rollback(context)
		report["cargo_rolled_back"] = true
		return _reject(report, "hero_preparation_failed")
	var next_event := event.duplicate(true)
	next_event["stage"] = "battle_handoff" if resolution_mode == "direct" else "automatic_settlement"
	_m("set_pending_invasion_event", [{} if str(context.get("player_side", "")).is_empty() else next_event], null)
	report["ok"] = true
	report["transaction_id"] = str(context.get("transaction_id", ""))
	report["context"] = context
	return report


func execute(event: Dictionary, base_context: Dictionary) -> Dictionary:
	var report := _transaction_report(event)
	if event.is_empty():
		return _reject(report, "empty_event")
	var transaction_id := str(event.get("transaction_id", make_transaction_id(str(event.get("attacker_city_id", "")), str(event.get("defender_city_id", "")))))
	report["transaction_id"] = transaction_id
	if bool(_q("result_applied", ["%s-result" % transaction_id], false)):
		report["duplicate"] = true
		return _reject(report, "duplicate_transaction")
	var prepared := prepare(event, base_context, "automatic")
	if not bool(prepared.get("ok", false)):
		return prepared
	var context: Dictionary = prepared.get("context", {})
	_m("set_pending_battle_context", [{"transaction_id": str(context.get("transaction_id", "")), "stage": "automatic_settlement"}], null)
	if not _resolver.is_valid():
		rollback(context)
		prepared["cargo_rolled_back"] = true
		return _reject(prepared, "resolver_unavailable")
	var resolved: Variant = _resolver.call(context)
	if not resolved is Dictionary:
		rollback(context)
		prepared["cargo_rolled_back"] = true
		return _reject(prepared, "resolver_invalid_result")
	var battle_result := (resolved as Dictionary).duplicate(true)
	if not _valid_result_identity(battle_result, context):
		rollback(context)
		prepared["cargo_rolled_back"] = true
		return _reject(prepared, "resolver_malformed_result")
	var settlement := apply_result(battle_result, false, context)
	prepared["battle_result"] = battle_result
	prepared["settlement"] = settlement
	if not bool(settlement.get("ok", false)):
		prepared["cargo_rolled_back"] = bool(settlement.get("cargo_rolled_back", false))
		return _reject(prepared, "settlement_failed")
	prepared["ok"] = true
	_copy_settlement_summary(prepared, settlement)
	return prepared


func apply_result(result: Dictionary, from_direct_battle: bool, rollback_context: Dictionary = {}) -> Dictionary:
	var report := _settlement_report(result)
	var transaction_id := str(result.get("transaction_id", ""))
	var result_id := str(result.get("result_id", ""))
	if transaction_id.is_empty() or result_id.is_empty():
		return _rollback_reject(report, "incomplete_result_identity", rollback_context if not rollback_context.is_empty() else result)
	if bool(_q("result_applied", [result_id], false)):
		report["duplicate"] = true
		return _reject(report, "duplicate_result")
	if from_direct_battle and str(_q("pending_invasion_transaction_id", [], "")) != transaction_id:
		return _rollback_reject(report, "transaction_mismatch", rollback_context if not rollback_context.is_empty() else result)
	var attacker_city_id := str(result.get("attacker_source_city_id", result.get("attacker_city_id", "")))
	var defender_city_id := str(result.get("defender_city_id", ""))
	if attacker_city_id.is_empty() or defender_city_id.is_empty():
		return _rollback_reject(report, "missing_city_id", rollback_context if not rollback_context.is_empty() else result)
	if not bool(_q("has_city", [attacker_city_id], false)) or not bool(_q("has_city", [defender_city_id], false)):
		return _rollback_reject(report, "missing_city", rollback_context if not rollback_context.is_empty() else result)
	var attacker_owner := str(result.get("attacker_owner", _q("city_owner", [attacker_city_id], "")))
	var defender_owner := str(result.get("defender_owner", _q("city_owner", [defender_city_id], "")))
	var attacker_won := str(result.get("winner_side", result.get("winner", "defender"))) == "attacker"
	var attacker_healthy := maxi(0, int(result.get("attacker_healthy_survivors", 0)))
	var defender_healthy := maxi(0, int(result.get("defender_healthy_survivors", 0)))
	var attacker_wounded := maxi(0, int(result.get("attacker_wounded", 0)))
	var defender_wounded := maxi(0, int(result.get("defender_wounded", 0)))
	var attacker_generals := _hero_ids(result.get("attacker_general_ids", []))
	var defender_generals := _hero_ids(result.get("defender_general_ids", []))
	var attacker_survivors := _hero_ids(result.get("attacker_surviving_general_ids", attacker_generals))
	var defender_survivors := _hero_ids(result.get("defender_surviving_general_ids", defender_generals))
	var defender_supply := apply_defender_supply(defender_city_id, result)
	report["supply_changes"] = [defender_supply]
	if not bool(defender_supply.get("ok", false)):
		return _rollback_reject(report, "defender_supply_failed", rollback_context if not rollback_context.is_empty() else result)
	var normal_turns := maxi(1, int(_config.get("normal_wounded_turns", 3)))
	if attacker_won:
		_m("set_city_owner", [defender_city_id, attacker_owner], null)
		report["ownership_changed"] = attacker_owner != defender_owner
		report["old_owner"] = defender_owner
		report["new_owner"] = attacker_owner
		var disposition: Variant = _m("settle_defender_generals", [defender_city_id, defender_owner, attacker_owner, defender_generals, defender_survivors, transaction_id, result_id], {})
		if not disposition is Dictionary:
			return _rollback_reject(report, "defender_disposition_failed", rollback_context if not rollback_context.is_empty() else result)
		report["defender_disposition"] = (disposition as Dictionary).duplicate(true)
		var retreat_city_id := str((disposition as Dictionary).get("primary_escape_city_id", ""))
		if not retreat_city_id.is_empty():
			_set_troops(retreat_city_id, int(_q("city_troops", [retreat_city_id], 0)) + defender_healthy, report)
			_add_wounded(retreat_city_id, defender_wounded, normal_turns, transaction_id, report)
		_set_troops(defender_city_id, attacker_healthy, report)
		_m("clear_wounded", [defender_city_id], null)
		_add_wounded(defender_city_id, attacker_wounded, normal_turns, transaction_id, report)
		var cargo_change := add_attacker_cargo(defender_city_id, result)
		if not bool(cargo_change.get("ok", false)):
			return _rollback_reject(report, "attacker_cargo_settlement_failed", rollback_context if not rollback_context.is_empty() else result)
		report["supply_changes"].append(cargo_change)
		for hero_id in attacker_survivors:
			_m("move_hero", [hero_id, defender_city_id], null)
			report["hero_changes"].append({"hero_id": hero_id, "city_id": defender_city_id})
	else:
		_set_troops(attacker_city_id, int(_q("city_troops", [attacker_city_id], 0)) + attacker_healthy, report)
		_set_troops(defender_city_id, int(_q("city_troops", [defender_city_id], 0)) + defender_healthy, report)
		_add_wounded(attacker_city_id, attacker_wounded, normal_turns, transaction_id, report)
		_add_wounded(defender_city_id, defender_wounded, normal_turns, transaction_id, report)
		for hero_id in attacker_survivors:
			_m("move_hero", [hero_id, attacker_city_id], null)
			report["hero_changes"].append({"hero_id": hero_id, "city_id": attacker_city_id})
		for hero_id in defender_survivors:
			_m("move_hero", [hero_id, defender_city_id], null)
			report["hero_changes"].append({"hero_id": hero_id, "city_id": defender_city_id})
	_m("mark_result_applied", [result_id], null)
	_m("clear_transaction_state", [], null)
	report["ok"] = true
	return report


func pay_expedition_cargo(city_id: String, cargo: Dictionary) -> Dictionary:
	var before := _resource_stock(city_id)
	var after := before.duplicate(true)
	var food_stock := _dictionary(cargo.get("food_stock", {}))
	for food_type in ExpeditionSupplyCalculatorScript.FOOD_TYPES:
		var amount := maxi(0, int(food_stock.get(food_type, 0)))
		if int(after.get(food_type, 0)) < amount:
			return {"ok": false, "city_id": city_id, "before": before, "after": before.duplicate(true)}
		after[food_type] = int(after.get(food_type, 0)) - amount
	for resource_id in ["gold", "salt"]:
		var amount := maxi(0, int(cargo.get(resource_id, 0)))
		if int(after.get(resource_id, 0)) < amount:
			return {"ok": false, "city_id": city_id, "before": before, "after": before.duplicate(true)}
		after[resource_id] = int(after.get(resource_id, 0)) - amount
	var ok := bool(_m("set_resource_stock", [city_id, after], false))
	return {"ok": ok, "city_id": city_id, "before": before, "after": after, "paid": cargo.duplicate(true)}


func apply_defender_supply(city_id: String, result: Dictionary) -> Dictionary:
	var before := _resource_stock(city_id)
	var after := before.duplicate(true)
	var remaining: Variant = result.get("defender_remaining_food_stock", {})
	if remaining is Dictionary:
		for food_type in ExpeditionSupplyCalculatorScript.FOOD_TYPES:
			after[food_type] = maxi(0, int((remaining as Dictionary).get(food_type, 0)))
	else:
		after[str(result.get("defender_remaining_food_type", "rice"))] = maxi(0, int(result.get("defender_remaining_food", 0)))
	after["gold"] = maxi(0, int(result.get("defender_remaining_gold", after.get("gold", 0))))
	after["salt"] = maxi(0, int(result.get("defender_remaining_salt", after.get("salt", 0))))
	var ok := bool(_m("set_resource_stock", [city_id, after], false))
	return {"ok": ok, "kind": "defender_supply", "city_id": city_id, "before": before, "after": after}


func add_attacker_cargo(city_id: String, result: Dictionary) -> Dictionary:
	var before := _resource_stock(city_id)
	var after := before.duplicate(true)
	var remaining: Variant = result.get("attacker_remaining_food_stock", {})
	if remaining is Dictionary:
		for food_type in ExpeditionSupplyCalculatorScript.FOOD_TYPES:
			after[food_type] = maxi(0, int(after.get(food_type, 0))) + maxi(0, int((remaining as Dictionary).get(food_type, 0)))
	after["gold"] = maxi(0, int(after.get("gold", 0))) + maxi(0, int(result.get("attacker_remaining_gold", 0)))
	after["salt"] = maxi(0, int(after.get("salt", 0))) + maxi(0, int(result.get("attacker_remaining_salt", 0)))
	var ok := bool(_m("set_resource_stock", [city_id, after], false))
	return {"ok": ok, "kind": "attacker_cargo", "city_id": city_id, "before": before, "after": after}


func rollback(context: Dictionary) -> Dictionary:
	var snapshot: Variant = context.get("rollback_worldmap_state", {})
	if not snapshot is Dictionary or (snapshot as Dictionary).is_empty():
		return {"ok": false, "cargo_rolled_back": false, "warnings": ["missing_rollback_snapshot"]}
	var ok := bool(_m("apply_state", [(snapshot as Dictionary).duplicate(true)], false))
	return {"ok": ok, "cargo_rolled_back": ok, "warnings": [] if ok else ["rollback_apply_failed"]}


func _pre_decrement(context: Dictionary, side: String, deployed_key: String) -> Dictionary:
	var next := context.duplicate(true)
	if bool(next.get(deployed_key, false)):
		return next
	var city_id := str(next.get("%s_source_city_id" % side, next.get("%s_city_id" % side, "")))
	var total_key := "%s_total_allocated_troops" % side
	var requested := maxi(0, int(next.get(total_key, 0)))
	if city_id.is_empty() or requested <= 0:
		return next
	var before := maxi(0, int(_q("city_troops", [city_id], 0)))
	var deployed := mini(requested, before)
	var after := before - deployed
	next[total_key] = deployed
	next["%s_source_city_id" % side] = city_id
	next["%s_source_city_troops_before" % side] = before
	next["%s_source_city_troops_after" % side] = after
	next[deployed_key] = deployed > 0
	_m("set_city_troops", [city_id, after], null)
	return next


func _valid_result_identity(result: Dictionary, context: Dictionary) -> bool:
	return not str(result.get("transaction_id", "")).is_empty() \
		and str(result.get("transaction_id", "")) == str(context.get("transaction_id", "")) \
		and not str(result.get("result_id", "")).is_empty() \
		and not str(result.get("attacker_source_city_id", result.get("attacker_city_id", ""))).is_empty() \
		and not str(result.get("defender_city_id", "")).is_empty()


func _food_stock(city_id: String) -> Dictionary:
	var raw := _resource_stock(city_id)
	var stock := {"rice": 0, "barley": 0, "seafood": 0}
	for food_type in ExpeditionSupplyCalculatorScript.FOOD_TYPES:
		stock[food_type] = maxi(0, int(raw.get(food_type, 0)))
	return stock


func _resource_stock(city_id: String) -> Dictionary:
	return _dictionary(_q("city_resource_stock", [city_id], {})).duplicate(true)


func _allocation(hero_ids: Array[String], troops: int, city_id: String) -> Dictionary:
	return _dictionary(_q("build_troop_allocation", [hero_ids, troops, city_id], {})).duplicate(true)


func _sum_allocation(allocation: Dictionary) -> int:
	var total := 0
	for amount in allocation.values():
		total += maxi(0, int(amount))
	return total


func _hero_ids(raw_ids: Variant) -> Array[String]:
	var ids: Array[String] = []
	if raw_ids is Array:
		for raw_id in raw_ids:
			var hero_id := str(raw_id)
			if not hero_id.is_empty() and not ids.has(hero_id):
				ids.append(hero_id)
	return ids


func _set_troops(city_id: String, after: int, report: Dictionary) -> void:
	var before := maxi(0, int(_q("city_troops", [city_id], 0)))
	_m("set_city_troops", [city_id, maxi(0, after)], null)
	report["troop_changes"].append({"city_id": city_id, "before": before, "after": maxi(0, after)})


func _add_wounded(city_id: String, troops: int, turns: int, transaction_id: String, report: Dictionary) -> void:
	if troops <= 0 or city_id.is_empty():
		return
	_m("add_wounded", [city_id, troops, turns, "normal", transaction_id], null)
	report["troop_changes"].append({"city_id": city_id, "wounded_added": troops})


func _transaction_report(event: Dictionary) -> Dictionary:
	return {
		"ok": false,
		"transaction_id": str(event.get("transaction_id", "")),
		"attacker_city_id": str(event.get("attacker_city_id", "")),
		"defender_city_id": str(event.get("defender_city_id", "")),
		"cargo_plan": {}, "cargo_paid": {}, "cargo_rolled_back": false,
		"battle_result": {}, "settlement": {}, "duplicate": false,
		"ownership_changed": false, "old_owner": "", "new_owner": "",
		"troop_changes": [], "supply_changes": [], "hero_changes": [],
		"error_code": "", "warnings": [],
	}


func _settlement_report(result: Dictionary) -> Dictionary:
	var report := _transaction_report(result)
	report["result_id"] = str(result.get("result_id", ""))
	return report


func _reject(report: Dictionary, error_code: String) -> Dictionary:
	report["ok"] = false
	report["error_code"] = error_code
	if not (report["warnings"] as Array).has(error_code):
		(report["warnings"] as Array).append(error_code)
	return report


func _rollback_reject(report: Dictionary, error_code: String, context: Dictionary) -> Dictionary:
	var rolled_back := rollback(context)
	report["cargo_rolled_back"] = bool(rolled_back.get("cargo_rolled_back", false))
	for warning in rolled_back.get("warnings", []):
		(report["warnings"] as Array).append(warning)
	return _reject(report, error_code)


func _copy_settlement_summary(target: Dictionary, settlement: Dictionary) -> void:
	for key in ["ownership_changed", "old_owner", "new_owner", "troop_changes", "supply_changes", "hero_changes"]:
		target[key] = settlement.get(key, target.get(key))


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


func _dictionary(value: Variant) -> Dictionary:
	return value if value is Dictionary else {}
