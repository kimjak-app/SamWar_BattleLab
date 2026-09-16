class_name WorldMapDomesticTechResearchService
extends RefCounted

const SCOPE_CITY := "city"
const SCOPE_NATIONAL := "national"
const RESEARCH_KEY := "research"
const ACTIVE_KEY := "active"
const FOOD_GROUP_KEYS := ["rice", "barley", "seafood"]

var _catalog: RefCounted
var _rules: RefCounted
var _query: Callable
var _mutation: Callable


func configure(catalog: RefCounted, rules: RefCounted, query: Callable, mutation: Callable) -> void:
	_catalog = catalog
	_rules = rules
	_query = query
	_mutation = mutation


func normalize_state() -> Dictionary:
	var default_city_id := str(_query_value("player_value", ["selected_city_id", ""], ""))
	var city_completed := normalize_city_state_map(_query_value("player_value", ["city_domestic_tech_completed", {}], {}), default_city_id)
	var city_unlocked := normalize_city_state_map(_query_value("player_value", ["city_domestic_tech_unlocked", {}], {}), default_city_id)
	var national_completed := normalize_national_state_map(_query_value("player_value", ["national_domestic_tech_completed", {}], {}))
	var national_unlocked := normalize_national_state_map(_query_value("player_value", ["national_domestic_tech_unlocked", {}], {}))
	var current_turn := get_current_turn()

	var national_result := _normalize_research_container_result(
		_query_value("player_value", ["national_tech_research", {}], {}),
		SCOPE_NATIONAL,
		"",
		{},
		national_completed,
		current_turn
	)
	var national_completed_id := str(national_result.get("completed_tech_id", ""))
	if not national_completed_id.is_empty():
		national_completed[national_completed_id] = true

	var normalized_city_states := {}
	for city_id in _get_all_city_ids():
		var city_data := _get_city_state(city_id)
		if city_data.is_empty():
			continue
		var city_tech: Dictionary = city_data.get("city_tech", {}) if city_data.get("city_tech", {}) is Dictionary else {}
		var completed_for_city: Dictionary = city_completed.get(city_id, {}) if city_completed.get(city_id, {}) is Dictionary else {}
		var city_result := _normalize_research_container_result(
			city_tech.get(RESEARCH_KEY, {}),
			SCOPE_CITY,
			city_id,
			completed_for_city,
			national_completed,
			current_turn
		)
		var city_completed_id := str(city_result.get("completed_tech_id", ""))
		if not city_completed_id.is_empty():
			completed_for_city[city_completed_id] = true
			city_completed[city_id] = completed_for_city
		city_tech[RESEARCH_KEY] = city_result.get("container", {ACTIVE_KEY: {}})
		city_tech["completed"] = _build_city_completed_mirror(city_tech.get("completed", {}), completed_for_city)
		city_data["city_tech"] = city_tech
		normalized_city_states[city_id] = city_data

	_mutate("set_player_value", ["city_domestic_tech_completed", city_completed])
	_mutate("set_player_value", ["city_domestic_tech_unlocked", city_unlocked])
	_mutate("set_player_value", ["national_domestic_tech_completed", national_completed])
	_mutate("set_player_value", ["national_domestic_tech_unlocked", national_unlocked])
	_mutate("set_player_value", ["national_tech_research", national_result.get("container", {ACTIVE_KEY: {}})])
	for city_id_variant in normalized_city_states.keys():
		_mutate("set_city_state", [str(city_id_variant), normalized_city_states.get(city_id_variant)])
	return {
		"city_completed": city_completed.duplicate(true),
		"city_unlocked": city_unlocked.duplicate(true),
		"national_completed": national_completed.duplicate(true),
		"national_unlocked": national_unlocked.duplicate(true),
	}


func normalize_city_state_map(raw_state: Variant, default_city_id: String = "") -> Dictionary:
	var normalized := {}
	var definitions: Dictionary = _catalog.get_city_definitions()
	if raw_state is Array:
		if default_city_id.is_empty():
			return normalized
		var completed_from_array := _normalize_completed_list(raw_state, definitions)
		if not completed_from_array.is_empty():
			normalized[default_city_id] = completed_from_array
		return normalized
	if not raw_state is Dictionary:
		return normalized
	for city_id_variant in (raw_state as Dictionary).keys():
		var city_id := str(city_id_variant)
		var city_value: Variant = (raw_state as Dictionary).get(city_id_variant, {})
		if city_id.is_empty():
			continue
		if city_value is Array:
			normalized[city_id] = _normalize_completed_list(city_value, definitions)
		elif city_value is Dictionary:
			normalized[city_id] = _normalize_completed_map(city_value, definitions)
	return normalized


func normalize_national_state_map(raw_state: Variant) -> Dictionary:
	var definitions: Dictionary = _catalog.get_national_definitions()
	if raw_state is Array:
		return _normalize_completed_list(raw_state, definitions)
	if raw_state is Dictionary:
		return _normalize_completed_map(raw_state, definitions)
	return {}


func normalize_research_container(raw_state: Variant, scope: String, city_id: String = "") -> Dictionary:
	return _normalize_research_container_result(
		raw_state,
		scope,
		city_id,
		get_city_completed_snapshot(city_id),
		get_national_completed_snapshot(),
		get_current_turn()
	).get("container", {ACTIVE_KEY: {}})


func normalize_research_turn_value(raw_value: Variant, fallback_value: int, minimum_value: int) -> int:
	var value := fallback_value
	if raw_value is int or raw_value is float:
		value = int(raw_value)
	elif raw_value is String and str(raw_value).strip_edges().is_valid_int():
		value = int(str(raw_value).strip_edges())
	return clampi(value, minimum_value, maxi(minimum_value, fallback_value))


func normalize_research_duration_value(raw_value: Variant, fallback_value: int, raw_remaining_value: Variant = 0) -> int:
	var has_value := raw_value is int or raw_value is float or (raw_value is String and str(raw_value).strip_edges().is_valid_int())
	var value := int(raw_value) if has_value else fallback_value
	if has_value and value > 0:
		return value
	return maxi(maxi(1, fallback_value), parse_positive_research_turn_value(raw_remaining_value))


func parse_positive_research_turn_value(raw_value: Variant) -> int:
	if raw_value is int or raw_value is float:
		return maxi(0, int(raw_value))
	var value_text := str(raw_value).strip_edges()
	return maxi(0, int(value_text)) if value_text.is_valid_int() else 0


func get_national_completed_snapshot() -> Dictionary:
	return normalize_national_state_map(_query_value("player_value", ["national_domestic_tech_completed", {}], {}))


func get_city_completed_snapshot(city_id: String) -> Dictionary:
	var default_city_id := str(_query_value("player_value", ["selected_city_id", ""], ""))
	var completed_by_city := normalize_city_state_map(_query_value("player_value", ["city_domestic_tech_completed", {}], {}), default_city_id)
	var completed: Variant = completed_by_city.get(city_id, {})
	return (completed as Dictionary).duplicate(true) if completed is Dictionary else {}


func is_national_completed(tech_id: String) -> bool:
	return _catalog.is_national_tech(tech_id) and bool(get_national_completed_snapshot().get(tech_id, false))


func is_city_completed(city_id: String, tech_id: String) -> bool:
	return not city_id.is_empty() and _catalog.is_city_tech(tech_id) and bool(get_city_completed_snapshot(city_id).get(tech_id, false))


func get_national_active_research() -> Dictionary:
	normalize_state()
	var state: Variant = _query_value("player_value", ["national_tech_research", {}], {})
	return _get_active_from_container(state)


func get_city_active_research(city_id: String) -> Dictionary:
	var city_data := _get_city_state(city_id)
	if city_data.is_empty():
		return {}
	var city_tech: Variant = city_data.get("city_tech", {})
	if not city_tech is Dictionary:
		return {}
	return _get_active_from_container(normalize_research_container((city_tech as Dictionary).get(RESEARCH_KEY, {}), SCOPE_CITY, city_id))


func is_researching(tech_id: String, city_id: String = "") -> bool:
	var definition: Dictionary = _catalog.get_definition(tech_id)
	if definition.is_empty():
		return false
	var active := get_national_active_research() if str(definition.get("tree_scope", "")) == SCOPE_NATIONAL else get_city_active_research(city_id)
	return str(active.get("tech_id", "")) == tech_id


func build_actual_charge_plan(tech_id: String, scope: String, city_id: String = "") -> Dictionary:
	var definition: Dictionary = _catalog.get_definition(tech_id)
	var cost_plan: Dictionary = _rules.get_research_cost_plan(definition, scope) if not definition.is_empty() else {}
	var implemented_costs := {}
	var skipped_costs := {}
	var planned_gold_cost := maxi(0, int(cost_plan.get("planned_gold_cost", 0)))
	var planned_food_cost := maxi(0, int(cost_plan.get("planned_food_cost", 0)))
	var planned_labor_cost := maxi(0, int(cost_plan.get("planned_labor_cost", 0)))
	var planned_policy_cost := maxi(0, int(cost_plan.get("planned_policy_cost", 0)))
	if planned_gold_cost > 0:
		implemented_costs["gold"] = planned_gold_cost
	if planned_food_cost > 0:
		if scope == SCOPE_CITY or (scope == SCOPE_NATIONAL and has_national_food_group_scope()):
			implemented_costs["food_group"] = planned_food_cost
		else:
			skipped_costs["food_group"] = {"amount": planned_food_cost, "reason": "unsupported_or_unavailable_scope"}
	if planned_labor_cost > 0:
		skipped_costs["labor"] = {"amount": planned_labor_cost, "reason": "unsupported_persistent_state_key"}
	if planned_policy_cost > 0:
		skipped_costs["policy"] = {"amount": planned_policy_cost, "reason": "unsupported_persistent_state_key"}
	return {
		"tech_id": tech_id,
		"scope": scope,
		"city_id": city_id,
		"cost_plan": cost_plan,
		"implemented_costs": implemented_costs,
		"skipped_costs": skipped_costs,
		"food_group_keys": FOOD_GROUP_KEYS.duplicate(),
		"food_group_deduction_order": FOOD_GROUP_KEYS.duplicate(),
		"charge_timing": "on_research_start_once",
	}


func has_national_food_group_scope() -> bool:
	var stock: Variant = _query_value("player_value", ["resource_stock", {}], {})
	if not stock is Dictionary:
		return false
	for resource_id in FOOD_GROUP_KEYS:
		if not (stock as Dictionary).has(resource_id):
			return false
	return true


func validate_actual_charge(charge_plan: Dictionary) -> Dictionary:
	var scope := str(charge_plan.get("scope", ""))
	var city_id := str(charge_plan.get("city_id", ""))
	var costs: Dictionary = charge_plan.get("implemented_costs", {}) if charge_plan.get("implemented_costs", {}) is Dictionary else {}
	var stock := _get_charge_stock(scope, city_id)
	var missing := {}
	var available := {}
	if costs.has("gold"):
		var required_gold := maxi(0, int(costs.get("gold", 0)))
		var available_gold := maxi(0, int(stock.get("gold", 0)))
		available["gold"] = available_gold
		if available_gold < required_gold:
			missing["gold"] = required_gold - available_gold
	if costs.has("food_group"):
		var required_food := maxi(0, int(costs.get("food_group", 0)))
		var available_food := _get_food_group_total(stock)
		available["food_group"] = available_food
		if available_food < required_food:
			missing["food_group"] = required_food - available_food
	return {"ok": missing.is_empty(), "missing": missing, "available": available, "charge_plan": charge_plan.duplicate(true), "message": ""}


func apply_actual_charge(charge_plan: Dictionary) -> Dictionary:
	var validation := validate_actual_charge(charge_plan)
	if not bool(validation.get("ok", false)):
		return {"ok": false, "reason": "insufficient_resources", "validation": validation}
	var scope := str(charge_plan.get("scope", ""))
	var city_id := str(charge_plan.get("city_id", ""))
	var costs: Dictionary = charge_plan.get("implemented_costs", {}) if charge_plan.get("implemented_costs", {}) is Dictionary else {}
	var stock := _get_charge_stock(scope, city_id)
	var before := stock.duplicate(true)
	var paid := {}
	if costs.has("gold"):
		var gold_cost := maxi(0, int(costs.get("gold", 0)))
		stock["gold"] = maxi(0, int(stock.get("gold", 0))) - gold_cost
		paid["gold"] = gold_cost
	if costs.has("food_group"):
		var remaining_food := maxi(0, int(costs.get("food_group", 0)))
		var paid_food := {}
		for resource_id in FOOD_GROUP_KEYS:
			var before_food := maxi(0, int(stock.get(resource_id, 0)))
			var pay_food := mini(before_food, remaining_food)
			stock[resource_id] = before_food - pay_food
			remaining_food -= pay_food
			paid_food[resource_id] = pay_food
		paid["food_group"] = paid_food
	if scope == SCOPE_CITY:
		_mutate("set_city_storage", [city_id, stock])
		return {"ok": true, "scope": scope, "city_id": city_id, "before": before, "after": stock.duplicate(true), "paid": paid}
	if scope == SCOPE_NATIONAL:
		_mutate("set_player_value", ["resource_stock", stock])
		return {"ok": true, "scope": scope, "before": before, "after": stock.duplicate(true), "paid": paid}
	return {"ok": false, "reason": "invalid_scope"}


func validate_start(tech_id: String, city_id: String = "") -> Dictionary:
	normalize_state()
	if tech_id.is_empty():
		return {"ok": false, "reason": "no_selection"}
	var definition: Dictionary = _catalog.get_definition(tech_id)
	if definition.is_empty():
		return {"ok": false, "reason": "missing_definition"}
	var scope := str(definition.get("tree_scope", ""))
	if scope == SCOPE_CITY and (city_id.is_empty() or not bool(_query_value("is_city_owned", [city_id], false))):
		return {"ok": false, "reason": "city_scope"}
	if scope != SCOPE_CITY and scope != SCOPE_NATIONAL:
		return {"ok": false, "reason": "invalid_scope"}
	var city_completed := get_city_completed_snapshot(city_id)
	var national_completed := get_national_completed_snapshot()
	var active := get_national_active_research() if scope == SCOPE_NATIONAL else get_city_active_research(city_id)
	var is_completed := bool(national_completed.get(tech_id, false)) if scope == SCOPE_NATIONAL else bool(city_completed.get(tech_id, false))
	var is_same_active := str(active.get("tech_id", "")) == tech_id
	var eligibility: Dictionary = _rules.evaluate_eligibility(
		definition,
		city_id,
		city_completed,
		national_completed,
		is_completed,
		is_same_active,
		bool(_query_value("city_exists", [city_id], false)),
		_has_only_supported_city_requirements(definition),
		Callable(self, "_query_world_fact")
	)
	var state := str(eligibility.get("state", "locked"))
	if state == "researching":
		return {"ok": false, "reason": "already_researching", "active_research": active, "eligibility": eligibility}
	if state != "available":
		return {"ok": false, "reason": state, "eligibility": eligibility}
	if not active.is_empty():
		return {"ok": false, "reason": "national_active" if scope == SCOPE_NATIONAL else "city_active", "active_research": active, "eligibility": eligibility}
	var charge_plan := build_actual_charge_plan(tech_id, scope, city_id)
	var charge_validation := validate_actual_charge(charge_plan)
	if not bool(charge_validation.get("ok", false)):
		return {"ok": false, "reason": "insufficient_cost", "eligibility": eligibility, "charge_plan": charge_plan, "charge_validation": charge_validation}
	return {"ok": true, "reason": "ready", "eligibility": eligibility, "charge_plan": charge_plan, "charge_validation": charge_validation}


func start_research(tech_id: String, city_id: String = "") -> Dictionary:
	var validation := validate_start(tech_id, city_id)
	if not bool(validation.get("ok", false)):
		return validation
	var definition: Dictionary = _catalog.get_definition(tech_id)
	var scope := str(definition.get("tree_scope", ""))
	var charge_plan: Dictionary = validation.get("charge_plan", {})
	var charge_result := apply_actual_charge(charge_plan)
	if not bool(charge_result.get("ok", false)):
		return {"ok": false, "reason": str(charge_result.get("reason", "charge_failed")), "charge_result": charge_result}
	var duration_turns := int(_rules.get_research_duration_turns(definition))
	var active := {"tech_id": tech_id, "started_turn": get_current_turn(), "remaining_turns": duration_turns, "duration_turns": duration_turns}
	if scope == SCOPE_NATIONAL:
		_mutate("set_player_value", ["national_tech_research", {ACTIVE_KEY: active}])
	elif scope == SCOPE_CITY:
		var city_data := _get_city_state(city_id)
		if city_data.is_empty():
			return {"ok": false, "reason": "missing_city_after_charge", "charge_result": charge_result}
		var city_tech: Dictionary = city_data.get("city_tech", {}) if city_data.get("city_tech", {}) is Dictionary else {}
		for key in ["completed", "in_progress", "available_cache"]:
			if not city_tech.get(key, {}) is Dictionary:
				city_tech[key] = {}
		city_tech[RESEARCH_KEY] = {ACTIVE_KEY: active}
		city_data["city_tech"] = city_tech
		_mutate("set_city_state", [city_id, city_data])
	else:
		return {"ok": false, "reason": "invalid_scope"}
	return {"ok": true, "reason": "ready", "scope": scope, "city_id": city_id, "tech_id": tech_id, "active_research": active.duplicate(true), "charge_plan": charge_plan, "charge_result": charge_result}


func advance_world_turn() -> Dictionary:
	normalize_state()
	var turn_number := get_current_turn()
	var national_events := advance_national_research()
	var city_events := advance_city_research()
	var advanced: Array = []
	var completed: Array = []
	for event in national_events + city_events:
		advanced.append(event)
		if bool(event.get("completed", false)):
			completed.append(event)
	return {"turn": turn_number, "national": national_events, "city": city_events, "advanced": advanced, "completed": completed}


func advance_national_research() -> Array[Dictionary]:
	normalize_state()
	var result: Array[Dictionary] = []
	var active := _get_active_from_container(_query_value("player_value", ["national_tech_research", {}], {}))
	if active.is_empty():
		return result
	var tech_id := str(active.get("tech_id", ""))
	if tech_id.is_empty() or not _catalog.is_national_tech(tech_id):
		_mutate("set_player_value", ["national_tech_research", {ACTIVE_KEY: {}}])
		return result
	var before_remaining := maxi(0, int(active.get("remaining_turns", active.get("duration_turns", 1))))
	var after_remaining := maxi(0, before_remaining - 1)
	if after_remaining <= 0:
		result.append(complete_national_research(active))
	else:
		active["remaining_turns"] = after_remaining
		_mutate("set_player_value", ["national_tech_research", {ACTIVE_KEY: active}])
		result.append({"type": SCOPE_NATIONAL, "tech_id": tech_id, "before_remaining": before_remaining, "after_remaining": after_remaining, "completed": false})
	return result


func advance_city_research() -> Array[Dictionary]:
	normalize_state()
	var result: Array[Dictionary] = []
	for city_id in get_player_city_ids():
		var city_data := _get_city_state(city_id)
		if city_data.is_empty():
			continue
		var city_tech: Dictionary = city_data.get("city_tech", {}) if city_data.get("city_tech", {}) is Dictionary else {}
		var active := _get_active_from_container(normalize_research_container(city_tech.get(RESEARCH_KEY, {}), SCOPE_CITY, city_id))
		if active.is_empty():
			continue
		var tech_id := str(active.get("tech_id", ""))
		if tech_id.is_empty() or not _catalog.is_city_tech(tech_id):
			city_tech[RESEARCH_KEY] = {ACTIVE_KEY: {}}
			city_data["city_tech"] = city_tech
			_mutate("set_city_state", [city_id, city_data])
			continue
		var before_remaining := maxi(0, int(active.get("remaining_turns", active.get("duration_turns", 1))))
		var after_remaining := maxi(0, before_remaining - 1)
		if after_remaining <= 0:
			result.append(complete_city_research(city_id, active))
		else:
			active["remaining_turns"] = after_remaining
			city_tech[RESEARCH_KEY] = {ACTIVE_KEY: active}
			city_data["city_tech"] = city_tech
			_mutate("set_city_state", [city_id, city_data])
			result.append({"type": SCOPE_CITY, "city_id": city_id, "tech_id": tech_id, "before_remaining": before_remaining, "after_remaining": after_remaining, "completed": false})
	return result


func complete_national_research(active: Dictionary) -> Dictionary:
	var tech_id := str(active.get("tech_id", ""))
	var completed := get_national_completed_snapshot()
	var event := _make_completion_event(SCOPE_NATIONAL, "", tech_id, active)
	_mutate("set_player_value", ["national_tech_research", {ACTIVE_KEY: {}}])
	if bool(completed.get(tech_id, false)):
		event["completed"] = false
		event["already_completed"] = true
		return event
	if _catalog.is_national_tech(tech_id):
		completed[tech_id] = true
	_mutate("set_player_value", ["national_domestic_tech_completed", completed])
	return event


func complete_city_research(city_id: String, active: Dictionary) -> Dictionary:
	var tech_id := str(active.get("tech_id", ""))
	var completed_by_city := normalize_city_state_map(_query_value("player_value", ["city_domestic_tech_completed", {}], {}), str(_query_value("player_value", ["selected_city_id", ""], "")))
	var city_completed: Dictionary = completed_by_city.get(city_id, {}) if completed_by_city.get(city_id, {}) is Dictionary else {}
	var event := _make_completion_event(SCOPE_CITY, city_id, tech_id, active)
	var already_completed := bool(city_completed.get(tech_id, false))
	if not already_completed and _catalog.is_city_tech(tech_id):
		city_completed[tech_id] = true
		completed_by_city[city_id] = city_completed
		_mutate("set_player_value", ["city_domestic_tech_completed", completed_by_city])
	var city_data := _get_city_state(city_id)
	if not city_data.is_empty():
		var city_tech: Dictionary = city_data.get("city_tech", {}) if city_data.get("city_tech", {}) is Dictionary else {}
		city_tech["completed"] = _build_city_completed_mirror(city_tech.get("completed", {}), city_completed)
		city_tech[RESEARCH_KEY] = {ACTIVE_KEY: {}}
		city_data["city_tech"] = city_tech
		_mutate("set_city_state", [city_id, city_data])
	if already_completed:
		event["completed"] = false
		event["already_completed"] = true
	return event


func mark_completed_from_normalize(scope: String, city_id: String, tech_id: String) -> void:
	if tech_id.is_empty():
		return
	if scope == SCOPE_NATIONAL and _catalog.is_national_tech(tech_id):
		var completed := get_national_completed_snapshot()
		completed[tech_id] = true
		_mutate("set_player_value", ["national_domestic_tech_completed", completed])
	elif scope == SCOPE_CITY and not city_id.is_empty() and _catalog.is_city_tech(tech_id):
		var all_completed := normalize_city_state_map(_query_value("player_value", ["city_domestic_tech_completed", {}], {}), "")
		var city_completed: Dictionary = all_completed.get(city_id, {}) if all_completed.get(city_id, {}) is Dictionary else {}
		city_completed[tech_id] = true
		all_completed[city_id] = city_completed
		_mutate("set_player_value", ["city_domestic_tech_completed", all_completed])


func sync_city_completed_mirror(city_id: String) -> void:
	var city_data := _get_city_state(city_id)
	if city_data.is_empty():
		return
	var city_tech: Dictionary = city_data.get("city_tech", {}) if city_data.get("city_tech", {}) is Dictionary else {}
	city_tech["completed"] = _build_city_completed_mirror(city_tech.get("completed", {}), get_city_completed_snapshot(city_id))
	city_data["city_tech"] = city_tech
	_mutate("set_city_state", [city_id, city_data])


func get_player_city_ids() -> Array[String]:
	var ids: Array[String] = []
	var owned_ids: Variant = _query_value("player_value", ["owned_city_ids", []], [])
	if owned_ids is Array:
		for id_variant in owned_ids:
			var city_id := str(id_variant)
			if not city_id.is_empty() and not ids.has(city_id):
				ids.append(city_id)
	for city_id in _get_all_city_ids():
		if not ids.has(city_id):
			ids.append(city_id)
	var result: Array[String] = []
	for city_id in ids:
		if bool(_query_value("is_city_owned", [city_id], false)):
			result.append(city_id)
	result.sort()
	return result


func get_actual_charge_summary() -> Dictionary:
	return {"actual_charge_implemented": true, "charge_timing": "on_research_start_once", "start_time_charge": true, "per_turn_charge": false, "completion_charge": false, "implemented_resource_keys": ["gold", "food_group"], "food_group_keys": FOOD_GROUP_KEYS.duplicate(), "food_group_deduction_order": FOOD_GROUP_KEYS.duplicate(), "city_food_group_order": FOOD_GROUP_KEYS.duplicate(), "national_gold_charge": true, "city_gold_charge": true, "city_food_group_charge": true, "labor_policy_actual_charge": "skipped_unsupported", "labor_policy_skipped": true, "paid_cost_state": false, "active_payload_schema_changed": false, "retroactive_charge": false, "cancel_refund_implemented": false, "partial_deduction_allowed": false, "enemy_research_cost_scope": "none", "battle_context_changed": false, "pending_invasion_schema_changed": false, "available_cost_wording_actual_charge": true, "display_only_wording_removed_after_actual_charge": true, "shortage_wording_enabled": true, "researching_cost_hidden_or_deprioritized": true, "completed_cost_hidden_or_deprioritized": true, "locked_prerequisite_first": true}


func get_current_turn() -> int:
	return maxi(1, int(_query_value("current_turn", [], 1)))


func _normalize_research_container_result(raw_state: Variant, scope: String, city_id: String, city_completed: Dictionary, national_completed: Dictionary, current_turn: int) -> Dictionary:
	var empty := {ACTIVE_KEY: {}}
	if not raw_state is Dictionary:
		return {"container": empty}
	var active: Variant = (raw_state as Dictionary).get(ACTIVE_KEY, {})
	if not active is Dictionary:
		return {"container": empty}
	var tech_id := str((active as Dictionary).get("tech_id", ""))
	if tech_id.is_empty():
		return {"container": empty}
	var definition: Dictionary = _catalog.get_definition(tech_id)
	if definition.is_empty() or str(definition.get("tree_scope", "")) != scope:
		return {"container": empty}
	if (scope == SCOPE_NATIONAL and bool(national_completed.get(tech_id, false))) or (scope == SCOPE_CITY and bool(city_completed.get(tech_id, false))):
		return {"container": empty}
	var fallback_duration := int(_rules.get_research_duration_turns(definition))
	var duration := normalize_research_duration_value((active as Dictionary).get("duration_turns", fallback_duration), fallback_duration, (active as Dictionary).get("remaining_turns", 0))
	var remaining := normalize_research_turn_value((active as Dictionary).get("remaining_turns", duration), duration, 0)
	if remaining <= 0:
		return {"container": empty, "completed_tech_id": tech_id}
	return {"container": {ACTIVE_KEY: {"tech_id": tech_id, "started_turn": maxi(1, int((active as Dictionary).get("started_turn", current_turn))), "remaining_turns": remaining, "duration_turns": duration}}}


func _normalize_completed_list(raw_list: Array, definitions: Dictionary) -> Dictionary:
	var result := {}
	for tech_id_variant in raw_list:
		var tech_id := str(tech_id_variant)
		if definitions.has(tech_id):
			result[tech_id] = true
	return result


func _normalize_completed_map(raw_map: Dictionary, definitions: Dictionary) -> Dictionary:
	var result := {}
	for tech_id_variant in raw_map.keys():
		var tech_id := str(tech_id_variant)
		if definitions.has(tech_id) and bool(raw_map.get(tech_id_variant, false)):
			result[tech_id] = true
	return result


func _build_city_completed_mirror(raw_mirror: Variant, domestic_completed: Dictionary) -> Dictionary:
	var mirror: Dictionary = (raw_mirror as Dictionary).duplicate(true) if raw_mirror is Dictionary else {}
	for tech_id_variant in _catalog.get_city_definitions().keys():
		var tech_id := str(tech_id_variant)
		if bool(domestic_completed.get(tech_id, false)):
			mirror[tech_id] = true
		else:
			mirror.erase(tech_id)
	return mirror


func _make_completion_event(scope: String, city_id: String, tech_id: String, active: Dictionary) -> Dictionary:
	var event := {"type": scope, "tech_id": tech_id, "before_remaining": maxi(0, int(active.get("remaining_turns", active.get("duration_turns", 1)))), "after_remaining": 0, "completed": true, "completed_turn": get_current_turn()}
	if scope == SCOPE_CITY:
		event["city_id"] = city_id
	return event


func _get_active_from_container(raw_container: Variant) -> Dictionary:
	if raw_container is Dictionary:
		var active: Variant = (raw_container as Dictionary).get(ACTIVE_KEY, {})
		if active is Dictionary:
			return (active as Dictionary).duplicate(true)
	return {}


func _get_charge_stock(scope: String, city_id: String) -> Dictionary:
	if scope == SCOPE_CITY:
		var stock: Variant = _query_value("city_storage", [city_id], {})
		return (stock as Dictionary).duplicate(true) if stock is Dictionary else {}
	if scope == SCOPE_NATIONAL:
		var stock: Variant = _query_value("player_value", ["resource_stock", {}], {})
		return (stock as Dictionary).duplicate(true) if stock is Dictionary else {}
	return {}


func _get_food_group_total(stock: Dictionary) -> int:
	var total := 0
	for resource_id in FOOD_GROUP_KEYS:
		total += maxi(0, int(stock.get(resource_id, 0)))
	return total


func _has_only_supported_city_requirements(definition: Dictionary) -> bool:
	var requirements: Variant = definition.get("special_requirements", {})
	if not requirements is Dictionary:
		return true
	for key_variant in (requirements as Dictionary).keys():
		if str(key_variant) != "city_requirements":
			return false
	return true


func _query_world_fact(query_id: String, args: Array) -> Variant:
	return _query_value(query_id, args, false)


func _get_city_state(city_id: String) -> Dictionary:
	var state: Variant = _query_value("city_state", [city_id], {})
	return (state as Dictionary).duplicate(true) if state is Dictionary else {}


func _get_all_city_ids() -> Array[String]:
	var result: Array[String] = []
	var raw_ids: Variant = _query_value("city_ids", [], [])
	if raw_ids is Array:
		for id_variant in raw_ids:
			var city_id := str(id_variant)
			if not city_id.is_empty() and not result.has(city_id):
				result.append(city_id)
	return result


func _query_value(query_id: String, args: Array, fallback: Variant) -> Variant:
	if not _query.is_valid():
		return fallback
	var value: Variant = _query.call(query_id, args)
	return fallback if value == null else value


func _mutate(mutation_id: String, args: Array) -> Variant:
	if not _mutation.is_valid():
		return null
	return _mutation.call(mutation_id, args)
