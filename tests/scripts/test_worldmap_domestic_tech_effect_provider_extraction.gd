extends SceneTree

const CatalogScript := preload("res://scripts/worldmap/domestic_tech/domestic_tech_catalog.gd")
const ProviderScript := preload("res://scripts/worldmap/domestic_tech/domestic_tech_effect_provider.gd")

var _checks := 0
var _failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var provider := ProviderScript.new()
	var catalog := CatalogScript.new()
	provider.configure(catalog)
	var empty := provider.get_city_economy_bonus("seoul", true, {})
	_expect(not provider.has_bonus_data("economy", empty), "no completed tech returns zero/default")
	_expect(provider.get_city_economy_bonus("seoul", true, {"unknown": true}) == empty, "unknown tech is ignored")
	_expect(not provider.has_effect_mapping("economy", "unknown"), "unknown effect key is ignored")

	var single := provider.get_city_economy_bonus("seoul", true, {"agri_tool_upgrade": true})
	_expect(is_equal_approx(float(single.food_percent), 0.04), "single city economy bonus")
	var multi := provider.get_city_economy_bonus("seoul", true, {"agri_tool_upgrade": true, "agri_irrigation": true})
	_expect(is_equal_approx(float(multi.food_percent), 0.11), "city economy bonuses stack additively")
	var policy := provider.get_national_policy_bonus({"nation_tax_reform": true})
	_expect(is_equal_approx(float(policy.tax_gold_percent), 0.04), "national economy effect applies")
	var city_modifier := provider.get_city_economy_modifier("seoul", true, {"commerce_permanent_market": true})
	var nation_modifier := provider.get_national_economy_modifier({"nation_tax_reform": true})
	_expect(is_equal_approx(float(city_modifier.gold_income_pct) + float(nation_modifier.gold_income_pct), 0.10), "city and national economy aggregate at consumer boundary")

	var military := provider.get_city_military_defense_bonus("seoul", true, {"mil_moat": true})
	_expect(is_equal_approx(float(military.defense_percent), 0.05), "military defense bonus")
	var naval := provider.get_naval_unlock_modifier("busan", true, {"commerce_port": true})
	_expect(bool(naval.port_enabled) and bool(naval.trade_ship_enabled), "naval boolean unlock")
	var siege := provider.get_siege_unlock_modifier("seoul", true, {"mil_siege_unit": true}, {})
	_expect(bool(siege.siege_unit_enabled), "siege boolean unlock")
	var naval_numeric := provider.get_city_naval_siege_bonus("busan", true, {"naval_panokseon": true, "mil_siege_engine": true})
	_expect(is_equal_approx(float(naval_numeric.naval_training_percent), 0.08) and is_equal_approx(float(naval_numeric.siege_engineering_percent), 0.08), "naval and siege numeric bonuses")
	_expect(provider.has_bonus_data("policy", policy), "national policy bonus predicate")

	var diplomacy := provider.get_diplomacy_spy_bonus({"nation_envoy": true})
	_expect(int(diplomacy.diplomacy_influence_flat) == 8, "diplomacy bonus")
	var spy := provider.get_diplomacy_spy_bonus({"nation_intelligence_org": true})
	_expect(is_equal_approx(float(spy.spy_preparation_percent), 0.08), "spy bonus")
	var city_spy := provider.get_city_spy_intel_bonus("seoul", true, {"unknown": true})
	_expect(not provider.has_bonus_data("city_spy", city_spy), "empty city spy/intel safe set remains zero")
	_expect(not provider.has_bonus_data("economy", provider.get_city_economy_bonus("busan", true, {"agri_tool_upgrade": false})), "city scope isolation")
	_expect(provider.get_national_policy_bonus({"nation_tax_reform": true}) == provider.get_national_policy_bonus({"nation_tax_reform": true}), "national scope is city-independent")
	_expect(not provider.has_bonus_data("economy", {"food_percent": "malformed"}), "malformed numeric value is safe")
	var duplicate := provider.get_city_economy_bonus("seoul", true, ["agri_tool_upgrade", "agri_tool_upgrade"])
	_expect(is_equal_approx(float(duplicate.food_percent), 0.04) and (duplicate.source_techs as Array).size() == 1, "duplicate completed id applies once")
	_expect(provider.has_naval_unlock_data(naval), "boolean unlock aggregation is detectable")
	_expect(provider.get_effect_mapping("economy", "agri_tool_upgrade") == {"food_percent": 0.04}, "safe-set enforcement exposes exact mapping")

	var national_snapshot := {"nation_tax_reform": true, "nation_envoy": true}
	var city_snapshot := {"seoul": {"agri_tool_upgrade": true, "mil_moat": true}}
	var national_before := national_snapshot.duplicate(true)
	var city_before := city_snapshot.duplicate(true)
	var summary := provider.get_effect_summary(national_snapshot, city_snapshot, ["seoul"])
	_expect(summary.has("economy_effects_enabled") and summary.has("national_policy_effects_applied"), "summary map shape")
	_expect(int(summary.numeric_economy_effects_applied) == 1 and int(summary.city_defense_effects_applied) == 1, "summary counts completed effects")
	var full := provider.get_full_integration_summary(summary)
	_expect(bool(full.completed_only) and bool(full.player_only), "full integration summary")
	var integration_map := provider.get_gameplay_integration_map_summary()
	_expect(integration_map.has("completed_lookup_contract") and integration_map.has("candidate_hooks"), "integration map shape is preserved")
	_expect(str(integration_map.completed_lookup_contract.national_storage) == "_player_state[\"national_domestic_tech_completed\"]", "integration storage contract is preserved")
	_expect(national_snapshot == national_before and city_snapshot == city_before, "input snapshots are not mutated")
	_expect(provider.get_effect_mapping("economy", "agri_tool_upgrade").food_percent == 0.04 and not catalog.get_definition("agri_tool_upgrade").is_empty(), "provider reuses catalog identity")
	_expect(not provider.has_method("start_research") and not provider.has_method("complete_research"), "no ResearchService mutation dependency")
	_expect(not provider.has_method("get_node"), "provider is RefCounted without Node dependency")
	_expect(provider.get_city_economy_bonus("", true, {"agri_tool_upgrade": true}).source_techs.is_empty(), "empty city id is safely rejected")
	_expect(provider.get_city_economy_bonus("seoul", false, {"agri_tool_upgrade": true}).source_techs.is_empty(), "non-player city receives no player effect")
	_expect(provider.is_ship_unlocked("trade_ship", naval), "ship unlock query uses structured result")
	_expect(provider.is_siege_unlocked("siege_unit", siege), "siege unlock query uses structured result")
	_finish()


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("[DOMESTIC_TECH_EFFECT_PROVIDER_FAIL] %s" % label)


func _finish() -> void:
	print("[DOMESTIC_TECH_EFFECT_PROVIDER] %s: %d checks, %d failures" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	quit(0 if _failures == 0 else 1)
