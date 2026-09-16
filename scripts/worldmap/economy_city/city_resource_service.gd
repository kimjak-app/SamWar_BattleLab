class_name WorldMapCityResourceService
extends RefCounted


const RESOURCE_DISPLAY_ORDER := ["rice", "barley", "seafood", "wood", "iron", "horses", "silk", "salt", "gold"]
const FOOD_RESOURCE_IDS := ["rice", "barley", "seafood"]
const INITIAL_SALT_PER_RESOURCE_RATING := 20

var _query: Callable
var _mutation: Callable


func configure(query: Callable, mutation: Callable) -> void:
	_query = query
	_mutation = mutation


func normalize_city_storage(raw_storage: Variant) -> Dictionary:
	var storage := {}
	if not raw_storage is Dictionary:
		return storage
	for resource_id in RESOURCE_DISPLAY_ORDER:
		storage[resource_id] = maxi(0, int((raw_storage as Dictionary).get(resource_id, 0)))
	return storage


func ensure_city_storage_keys(storage: Dictionary) -> Dictionary:
	var normalized := {}
	for resource_id in RESOURCE_DISPLAY_ORDER:
		normalized[resource_id] = maxi(0, int(storage.get(resource_id, 0)))
	return normalized


func build_default_city_storage(city_id: String, player_resource_stock: Dictionary) -> Dictionary:
	var storage := ensure_city_storage_keys({})
	if city_id == "hanseong":
		for resource_id in RESOURCE_DISPLAY_ORDER:
			storage[resource_id] = maxi(0, int(player_resource_stock.get(resource_id, 0)))
	return storage


func get_city_storage(city_id: String, city_data: Dictionary, player_resource_stock: Dictionary = {}) -> Dictionary:
	if city_data.get("storage") is Dictionary:
		return ensure_city_storage_keys(normalize_city_storage(city_data.get("storage")))
	return build_default_city_storage(city_id, player_resource_stock)


func get_city_storage_group_total(storage: Dictionary, resource_ids: Array) -> int:
	var total := 0
	for resource_id in resource_ids:
		total += get_city_storage_amount(storage, str(resource_id))
	return total


func get_city_storage_amount(storage: Dictionary, resource_id: String) -> int:
	return maxi(0, int(storage.get(resource_id, 0)))


func build_supply_resource_defaults(city_data: Dictionary) -> Dictionary:
	var updated := city_data.duplicate(true)
	var resource_stock: Dictionary = {}
	if city_data.get("resource_stock", {}) is Dictionary:
		resource_stock = (city_data.get("resource_stock", {}) as Dictionary).duplicate(true)
	var food_total := maxi(0, int(city_data.get("food", 0)))
	var resource_seed: Dictionary = city_data.get("resource_seed", {}) if city_data.get("resource_seed", {}) is Dictionary else {}
	var food_weight := maxi(1, int(resource_seed.get("rice", 0)) + int(resource_seed.get("barley", 0)) + int(resource_seed.get("seafood", 0)))
	var rice_default := int(floor(float(food_total) * float(int(resource_seed.get("rice", 0))) / float(food_weight)))
	var barley_default := int(floor(float(food_total) * float(int(resource_seed.get("barley", 0))) / float(food_weight)))
	var defaults := {
		"rice": rice_default,
		"barley": barley_default,
		"seafood": maxi(0, food_total - rice_default - barley_default),
		"gold": maxi(0, int(city_data.get("gold", 0))),
		"salt": maxi(0, int(resource_seed.get("salt", 0)) * INITIAL_SALT_PER_RESOURCE_RATING),
	}
	var changed := false
	for resource_id in defaults:
		if not resource_stock.has(resource_id):
			resource_stock[resource_id] = int(defaults[resource_id])
			changed = true
	if changed:
		updated["resource_stock"] = resource_stock
	return {"changed": changed, "city_state": updated, "resource_stock": resource_stock}


func get_city_supply_resource_amount(city_data: Dictionary, resource_id: String) -> int:
	var normalized := build_supply_resource_defaults(city_data)
	return maxi(0, int((normalized.resource_stock as Dictionary).get(resource_id, 0)))


func get_ordered_player_city_ids(capital_city_id: String, owned_city_ids: Array, ownership: Dictionary, player_faction_id: String) -> Array[String]:
	var result: Array[String] = []
	if not capital_city_id.is_empty() and str(ownership.get(capital_city_id, "")) == player_faction_id:
		result.append(capital_city_id)
	var remaining: Array[String] = []
	for raw_city_id in owned_city_ids:
		var city_id := str(raw_city_id)
		if city_id.is_empty() or city_id == capital_city_id or str(ownership.get(city_id, "")) != player_faction_id:
			continue
		if not remaining.has(city_id):
			remaining.append(city_id)
	remaining.sort()
	result.append_array(remaining)
	return result


func calculate_resource_delta(city_state: Dictionary, delta: Dictionary) -> Dictionary:
	var updated := city_state.duplicate(true)
	var stock: Dictionary = city_state.get("resource_stock", {}).duplicate(true) if city_state.get("resource_stock", {}) is Dictionary else {}
	var applied := {}
	for resource_id in RESOURCE_DISPLAY_ORDER:
		var before := maxi(0, int(stock.get(resource_id, 0)))
		var after := maxi(0, before + int(delta.get(resource_id, 0)))
		stock[resource_id] = after
		applied[resource_id] = after - before
	updated["resource_stock"] = stock
	return {"city_state": updated, "applied": applied}


func apply_resource_delta_to_city_stock(city_id: String, delta: Dictionary) -> Dictionary:
	var city_state: Dictionary = _query_value("city_state", [city_id], {})
	if city_state.is_empty():
		return {}
	var result := calculate_resource_delta(city_state, delta)
	_mutate("set_city_state", [city_id, result.city_state])
	return result.applied


func apply_player_resource_delta_capital_first(resource_id: String, requested_delta: int) -> int:
	if requested_delta == 0:
		return 0
	var city_ids: Array[String] = _string_array(_query_value("ordered_player_city_ids", [], []))
	if city_ids.is_empty():
		return 0
	if requested_delta > 0:
		var applied := apply_resource_delta_to_city_stock(city_ids[0], {resource_id: requested_delta})
		return int(applied.get(resource_id, 0))
	var remaining_cost := absi(requested_delta)
	var paid := 0
	for city_id in city_ids:
		if remaining_cost <= 0:
			break
		var city_state: Dictionary = _query_value("city_state", [city_id], {})
		var available := maxi(0, int((city_state.get("resource_stock", {}) as Dictionary).get(resource_id, 0))) if city_state.get("resource_stock", {}) is Dictionary else 0
		var deduction := mini(available, remaining_cost)
		if deduction <= 0:
			continue
		apply_resource_delta_to_city_stock(city_id, {resource_id: -deduction})
		remaining_cost -= deduction
		paid += deduction
	return -paid


func aggregate_city_stocks(city_ids: Array[String], city_states: Dictionary) -> Dictionary:
	var aggregate := ensure_city_storage_keys({})
	for city_id in city_ids:
		var city_state: Dictionary = city_states.get(city_id, {}) if city_states.get(city_id, {}) is Dictionary else {}
		var stock: Variant = city_state.get("resource_stock", {})
		if not stock is Dictionary:
			continue
		for resource_id in RESOURCE_DISPLAY_ORDER:
			aggregate[resource_id] = int(aggregate.get(resource_id, 0)) + maxi(0, int((stock as Dictionary).get(resource_id, 0)))
	return aggregate


func sync_player_resource_compatibility() -> Dictionary:
	var city_ids: Array[String] = _string_array(_query_value("ordered_player_city_ids", [], []))
	var states := {}
	for city_id in city_ids:
		states[city_id] = _query_value("city_state", [city_id], {})
	var aggregate := aggregate_city_stocks(city_ids, states)
	_mutate("set_player_resource_compatibility", [aggregate])
	return aggregate


func plan_city_stock_payment(city_id: String, cost: Dictionary, stock: Dictionary) -> Dictionary:
	if city_id.is_empty():
		return {"ok": false, "cost": cost.duplicate(true), "missing": {"city": 1}, "plan": {}}
	return _plan_payment([city_id], {city_id: stock}, cost)


func payment_resource_ids(resource_id: String) -> Array[String]:
	var result: Array[String] = []
	if resource_id == "food":
		result.append_array(FOOD_RESOURCE_IDS)
	else:
		result.append(resource_id)
	return result


func plan_national_city_stock_payment(city_ids: Array[String], stocks: Dictionary, cost: Dictionary) -> Dictionary:
	return _plan_payment(city_ids, stocks, cost)


func commit_city_stock_payment_plan(payment: Dictionary) -> Dictionary:
	if not bool(payment.get("ok", false)):
		return payment
	var plan: Dictionary = payment.get("plan", {})
	for raw_city_id in plan:
		var city_id := str(raw_city_id)
		var city_state: Dictionary = _query_value("city_state", [city_id], {})
		var delta := {}
		for raw_resource_id in (plan[raw_city_id] as Dictionary):
			delta[str(raw_resource_id)] = -int((plan[raw_city_id] as Dictionary).get(raw_resource_id, 0))
		var calculated := calculate_resource_delta(city_state, delta)
		_mutate("set_city_state", [city_id, calculated.city_state])
	payment["paid"] = plan.duplicate(true)
	return payment


func apply_city_production(turn_number: int, tax_level: int, policy_id: String, national_effects: Dictionary, supply_states: Dictionary) -> Dictionary:
	var totals := {"rice": 0, "barley": 0, "seafood": 0, "gold": 0}
	var city_results: Array[Dictionary] = []
	var city_ids: Array[String] = _string_array(_query_value("ordered_player_city_ids", [], []))
	for city_id in city_ids:
		var income: Dictionary = _query_value("city_production_income", [city_id, turn_number, tax_level, policy_id, national_effects, supply_states], {})
		if income.is_empty():
			continue
		var applied := apply_resource_delta_to_city_stock(city_id, income)
		for resource_id in totals:
			totals[resource_id] = int(totals.get(resource_id, 0)) + int(applied.get(resource_id, 0))
		city_results.append({"city_id": city_id, "resource_delta": applied})
	sync_player_resource_compatibility()
	return {"turn": maxi(1, turn_number), "city_count": city_results.size(), "cities": city_results, "totals": totals}


func _plan_payment(city_ids: Array[String], stocks: Dictionary, cost: Dictionary) -> Dictionary:
	var plan := {}
	var missing := {}
	for raw_resource_id in cost:
		var resource_id := str(raw_resource_id)
		var remaining := maxi(0, int(cost.get(raw_resource_id, 0)))
		for actual_id in payment_resource_ids(resource_id):
			for city_id in city_ids:
				var stock: Dictionary = stocks.get(city_id, {}) if stocks.get(city_id, {}) is Dictionary else {}
				var already_planned := int((plan.get(city_id, {}) as Dictionary).get(actual_id, 0)) if plan.get(city_id, {}) is Dictionary else 0
				var paid := mini(maxi(0, int(stock.get(actual_id, 0)) - already_planned), remaining)
				if paid > 0:
					if not plan.has(city_id):
						plan[city_id] = {}
					(plan[city_id] as Dictionary)[actual_id] = already_planned + paid
					remaining -= paid
				if remaining <= 0:
					break
			if remaining <= 0:
				break
		if remaining > 0:
			missing[resource_id] = remaining
	return {"ok": missing.is_empty(), "cost": cost.duplicate(true), "missing": missing, "plan": plan}


func _query_value(query_id: String, args: Array, fallback: Variant) -> Variant:
	if not _query.is_valid():
		return fallback
	var value: Variant = _query.call(query_id, args)
	return fallback if value == null else value


func _mutate(mutation_id: String, args: Array) -> Variant:
	if not _mutation.is_valid():
		return false
	return _mutation.call(mutation_id, args)


func _string_array(raw_values: Variant) -> Array[String]:
	var result: Array[String] = []
	if raw_values is Array:
		for raw_value in raw_values:
			var value := str(raw_value)
			if not value.is_empty() and not result.has(value):
				result.append(value)
	return result
