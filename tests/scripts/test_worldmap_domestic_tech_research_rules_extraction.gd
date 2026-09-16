extends SceneTree

const CatalogScript := preload("res://scripts/worldmap/domestic_tech/domestic_tech_catalog.gd")
const RulesScript := preload("res://scripts/worldmap/domestic_tech/domestic_tech_research_rules.gd")

var _checks := 0
var _failures := 0
var _coastal_city_ids := {"busan": true}


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var catalog := CatalogScript.new()
	var rules := RulesScript.new()
	_expect(not rules.has_method("get_node"), "rules are RefCounted without scene-node API")
	var irrigation: Dictionary = catalog.get_definition("agri_irrigation")
	var city_completed := {}
	var national_completed := {}
	var city_before := city_completed.duplicate(true)
	var national_before := national_completed.duplicate(true)
	_expect(not rules.are_prerequisites_met(irrigation, city_completed, national_completed), "missing prerequisite is rejected")
	city_completed["agri_tool_upgrade"] = true
	_expect(rules.are_prerequisites_met(irrigation, city_completed, national_completed), "completed prerequisite is accepted")
	_expect(not rules.are_prerequisites_met(irrigation, {}, {"agri_tool_upgrade": true}), "city prerequisite only uses same-city completed snapshot")

	var mint: Dictionary = catalog.get_definition("commerce_mint")
	_expect(not rules.are_national_requirements_met(mint, {}), "missing national requirement is rejected")
	_expect(rules.are_national_requirements_met(mint, {"nation_currency_unification": true}), "completed national requirement is accepted")
	var port: Dictionary = catalog.get_definition("commerce_port")
	_expect(rules.are_city_requirements_met(port, "busan", Callable(self, "_query")), "coastal city requirement is accepted")
	_expect(not rules.are_city_requirements_met(port, "seoul", Callable(self, "_query")), "non-coastal city requirement is rejected")
	_expect(rules.are_city_requirements_met({}, "seoul", Callable(self, "_query")), "empty definition preserves no-city-requirement behavior")

	_expect(rules.get_research_duration_turns(irrigation) == 3, "duration matches scope duration metadata")
	_expect(rules.get_research_duration_turns({"duration_turns": 9, "tier": 1}) == 9, "explicit duration takes precedence")
	_expect(rules.get_research_cost_balance_adjustment(irrigation, 230, 45) == {"gold": 210, "food": 40}, "cost balance adjustment matches existing rule")
	_expect(rules.get_research_cost_plan(irrigation) == {"planned_gold_cost": 210, "planned_food_cost": 40, "planned_labor_cost": 0, "planned_policy_cost": 0, "display_only": false, "cost_charged": true, "cost_charged_on_start": true, "cost_charged_per_turn": false, "cost_charged_on_completion": false, "cost_blocks_research_start": true, "paid_cost_state_persisted": false, "cost_affordability_checked": true}, "cost plan matches existing rule")

	var locked: Dictionary = rules.evaluate_eligibility(mint, "seoul", {}, {}, false, false, true, true, Callable(self, "_query"))
	_expect(not bool(locked.get("ok")) and (locked.get("reason_codes") as Array).has("missing_prerequisite") and (locked.get("reason_codes") as Array).has("missing_national_tech"), "eligibility returns pure reason codes")
	_expect((locked.get("missing_tech_ids") as Array).has("commerce_grand_market") and (locked.get("missing_national_tech_ids") as Array).has("nation_currency_unification"), "eligibility returns missing ids")
	var available: Dictionary = rules.evaluate_eligibility(mint, "seoul", {"commerce_grand_market": true}, {"nation_currency_unification": true}, false, false, true, true, Callable(self, "_query"))
	_expect(bool(available.get("ok")) and available.get("state") == "available", "eligible snapshot is available")
	_expect(city_before.is_empty() and national_before.is_empty() and city_completed == {"agri_tool_upgrade": true} and national_completed.is_empty(), "input snapshots are not mutated")
	_finish()


func _query(query_id: String, args: Array) -> Variant:
	if query_id == "is_city_coastal":
		return bool(_coastal_city_ids.get(str(args[0]), false))
	return null


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("[DOMESTIC_TECH_RULES_FAIL] %s" % label)


func _finish() -> void:
	print("[DOMESTIC_TECH_RULES] %s: %d checks, %d failures" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	quit(0 if _failures == 0 else 1)
