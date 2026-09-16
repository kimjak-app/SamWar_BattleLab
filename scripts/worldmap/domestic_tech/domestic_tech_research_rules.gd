class_name WorldMapDomesticTechResearchRules
extends RefCounted

const DomesticTechHelperLib := preload("res://scripts/worldmap/domestic_tech/domestic_tech_helpers.gd")

const SCOPE_CITY := "city"
const SCOPE_NATIONAL := "national"


func are_prerequisites_met(definition: Dictionary, completed_city_techs: Dictionary, completed_national_techs: Dictionary) -> bool:
	if definition.is_empty():
		return false
	var completed := completed_city_techs if str(definition.get("tree_scope", "")) == SCOPE_CITY else completed_national_techs
	for required_id_variant in definition.get("prerequisites", []):
		if not bool(completed.get(str(required_id_variant), false)):
			return false
	return true


func are_national_requirements_met(definition: Dictionary, completed_national_techs: Dictionary) -> bool:
	if definition.is_empty():
		return false
	for required_id_variant in definition.get("required_national_techs", []):
		if not bool(completed_national_techs.get(str(required_id_variant), false)):
			return false
	return true


func are_city_requirements_met(definition: Dictionary, city_id: String, world_fact_query: Callable = Callable()) -> bool:
	if definition.is_empty():
		return true
	var special_requirements: Dictionary = definition.get("special_requirements", {}) if definition.get("special_requirements", {}) is Dictionary else {}
	var city_requirements: Dictionary = special_requirements.get("city_requirements", {}) if special_requirements.get("city_requirements", {}) is Dictionary else {}
	if bool(city_requirements.get("coastal", false)):
		return bool(_query_world_fact(world_fact_query, "is_city_coastal", [city_id], false))
	return true


func get_research_duration_turns(tech_definition: Dictionary) -> int:
	if tech_definition.has("duration_turns"):
		var explicit_duration := _parse_positive_turn_value(tech_definition.get("duration_turns", 0))
		if explicit_duration > 0:
			return explicit_duration
	var duration_hint: Variant = tech_definition.get("duration_turns_hint", {})
	if duration_hint is Dictionary:
		var min_turns := int((duration_hint as Dictionary).get("min", 0))
		if min_turns > 0:
			return min_turns
	return DomesticTechHelperLib.get_tier_duration_turns_mvp(int(tech_definition.get("tier", 1)))


func get_research_cost_balance_adjustment(tech_definition: Dictionary, base_gold_cost: int, base_food_cost: int) -> Dictionary:
	var category_id := str(tech_definition.get("category", ""))
	var branch_id := str(tech_definition.get("branch", ""))
	var tier := clampi(int(tech_definition.get("tier", 1)), 1, 5)
	var gold_delta := 0
	var food_delta := 0
	if category_id in ["agri", "fish"]:
		if tier <= 2:
			gold_delta -= 20
			food_delta -= 5
		elif tier >= 4:
			gold_delta -= 40
			food_delta -= 10
	elif category_id == "commerce":
		if branch_id == "sea_trade":
			gold_delta += 20
			food_delta += 5
		elif tier <= 2:
			gold_delta -= 10
	elif category_id == "military":
		gold_delta += 30
		food_delta += 10
		if branch_id in ["naval", "siege", "defense"]:
			gold_delta += 30
			food_delta += 10
		if tier >= 4:
			gold_delta += 80
			food_delta += 20
	return {
		"gold": maxi(0, base_gold_cost + gold_delta),
		"food": maxi(0, base_food_cost + food_delta),
	}


func get_research_cost_plan(tech_definition: Dictionary, scope: String = "") -> Dictionary:
	var resolved_scope := scope if not scope.is_empty() else str(tech_definition.get("tree_scope", ""))
	var tier := clampi(int(tech_definition.get("tier", 1)), 1, 5)
	var planned_gold_cost := 0
	var planned_food_cost := 0
	if resolved_scope == SCOPE_NATIONAL:
		planned_gold_cost = [140, 320, 560, 900, 1200][tier - 1]
	elif resolved_scope == SCOPE_CITY:
		planned_gold_cost = [90, 230, 430, 760, 980][tier - 1]
		planned_food_cost = [20, 45, 90, 150, 210][tier - 1]
		var adjusted_cost := get_research_cost_balance_adjustment(tech_definition, planned_gold_cost, planned_food_cost)
		planned_gold_cost = int(adjusted_cost.get("gold", planned_gold_cost))
		planned_food_cost = int(adjusted_cost.get("food", planned_food_cost))
	return {
		"planned_gold_cost": planned_gold_cost,
		"planned_food_cost": planned_food_cost,
		"planned_labor_cost": 0,
		"planned_policy_cost": 0,
		"display_only": false,
		"cost_charged": true,
		"cost_charged_on_start": true,
		"cost_charged_per_turn": false,
		"cost_charged_on_completion": false,
		"cost_blocks_research_start": true,
		"paid_cost_state_persisted": false,
		"cost_affordability_checked": true,
	}


func evaluate_eligibility(definition: Dictionary, city_id: String, completed_city_techs: Dictionary, completed_national_techs: Dictionary, is_completed: bool, is_researching: bool, city_exists: bool, special_requirements_met: bool, world_fact_query: Callable = Callable()) -> Dictionary:
	if definition.is_empty():
		return _eligibility_result(false, "locked", ["missing_definition"], [], [])
	if is_completed:
		return _eligibility_result(false, "completed", [], [], [])
	if is_researching:
		return _eligibility_result(false, "researching", [], [], [])
	var reason_codes: Array[String] = []
	var missing_tech_ids: Array[String] = []
	var missing_national_tech_ids: Array[String] = []
	var scope := str(definition.get("tree_scope", ""))
	if scope == SCOPE_CITY and (city_id.is_empty() or not city_exists):
		reason_codes.append("missing_city_context")
	var prerequisite_completed := completed_city_techs if scope == SCOPE_CITY else completed_national_techs
	for required_id_variant in definition.get("prerequisites", []):
		var required_id := str(required_id_variant)
		if not bool(prerequisite_completed.get(required_id, false)):
			missing_tech_ids.append(required_id)
	if not missing_tech_ids.is_empty():
		reason_codes.append("missing_prerequisite")
	for required_id_variant in definition.get("required_national_techs", []):
		var required_id := str(required_id_variant)
		if not bool(completed_national_techs.get(required_id, false)):
			missing_national_tech_ids.append(required_id)
	if not missing_national_tech_ids.is_empty():
		reason_codes.append("missing_national_tech")
	if scope == SCOPE_CITY and not are_city_requirements_met(definition, city_id, world_fact_query):
		reason_codes.append("missing_city_requirement")
	if not reason_codes.is_empty():
		return _eligibility_result(false, "locked", reason_codes, missing_tech_ids, missing_national_tech_ids)
	if not special_requirements_met:
		return _eligibility_result(false, "special_locked", ["missing_special_requirement"], [], [])
	return _eligibility_result(true, "available", [], [], [])


func _eligibility_result(ok: bool, state: String, reason_codes: Array[String], missing_tech_ids: Array[String], missing_national_tech_ids: Array[String]) -> Dictionary:
	return {
		"ok": ok,
		"state": state,
		"reason_codes": reason_codes.duplicate(),
		"missing_tech_ids": missing_tech_ids.duplicate(),
		"missing_national_tech_ids": missing_national_tech_ids.duplicate(),
	}


func _query_world_fact(query: Callable, query_id: String, args: Array, fallback: Variant) -> Variant:
	if not query.is_valid():
		return fallback
	return query.call(query_id, args)


func _parse_positive_turn_value(raw_value: Variant) -> int:
	if raw_value is int or raw_value is float:
		return maxi(0, int(raw_value))
	var text := str(raw_value).strip_edges()
	if text.is_valid_int():
		return maxi(0, int(text))
	return 0
