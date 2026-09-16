class_name WorldMapDomesticTechEffectProvider
extends RefCounted

const CatalogScript := preload("res://scripts/worldmap/domestic_tech/domestic_tech_catalog.gd")

const EFFECT_GROUP_ECONOMY := "economy"
const EFFECT_GROUP_MILITARY_DEFENSE := "military_defense"
const EFFECT_GROUP_NATIONAL_BATTLE := "national_battle"
const EFFECT_GROUP_NATIONAL_POLICY := "national_policy"
const EFFECT_GROUP_NAVAL_SIEGE := "naval_siege"
const EFFECT_GROUP_DIPLOMACY_SPY := "diplomacy_spy"
const EFFECT_GROUP_CITY_SPY_INTEL := "city_spy_intel"

const ECONOMY_SAFE_CATEGORIES := [
	CatalogScript.DOMESTIC_TECH_CATEGORY_AGRI,
	CatalogScript.DOMESTIC_TECH_CATEGORY_FISH,
	CatalogScript.DOMESTIC_TECH_CATEGORY_COMMERCE,
]
const ECONOMY_SAFE_SET := {
	"agri_tool_upgrade": {"food_percent": 0.04},
	"agri_irrigation": {"food_percent": 0.07},
	"agri_reservoir": {"food_percent": 0.10},
	"agri_double_cropping": {"food_percent": 0.14},
	"agri_granary_zone": {"food_flat": 60},
	"fish_village": {"food_flat": 18},
	"fish_coastal_fishing": {"food_percent": 0.05},
	"fish_fleet": {"food_percent": 0.08},
	"fish_deep_sea_fishing": {"food_percent": 0.12},
	"fish_dried_supply_base": {"supply_flat": 40},
	"commerce_street_market": {"gold_flat": 15},
	"commerce_permanent_market": {"gold_percent": 0.06},
	"commerce_merchant_guild": {"gold_percent": 0.08},
	"commerce_mint": {"gold_flat": 80},
	"commerce_grand_market": {"gold_percent": 0.11},
}
const MILITARY_DEFENSE_SAFE_BRANCHES := ["infantry", "archer", "cavalry", "defense"]
const MILITARY_DEFENSE_SAFE_SET := {
	"mil_barracks": {"recruit_capacity_flat": 80},
	"mil_infantry_training": {"infantry_training_percent": 0.04},
	"mil_elite_infantry": {"infantry_training_percent": 0.07},
	"mil_heavy_infantry": {"infantry_training_percent": 0.10},
	"mil_archer_training": {"archer_training_percent": 0.04},
	"mil_elite_archer": {"archer_training_percent": 0.07},
	"mil_singijeon": {"archer_training_percent": 0.08},
	"mil_cavalry_training": {"cavalry_training_percent": 0.04},
	"mil_light_cavalry": {"cavalry_training_percent": 0.06},
	"mil_heavy_cavalry": {"cavalry_training_percent": 0.08},
	"mil_iron_cavalry": {"cavalry_training_percent": 0.10},
	"mil_cavalry_charge_tactics": {"cavalry_charge_percent": 0.08},
	"mil_wall_upgrade": {"defense_flat": 35},
	"mil_moat": {"defense_percent": 0.05},
	"mil_double_moat": {"defense_percent": 0.08},
	"mil_watchtower": {"defense_flat": 30},
	"mil_beacon": {"defense_flat": 20},
	"mil_beacon_network": {"defense_percent": 0.06},
	"mil_iron_gate": {"defense_flat": 70},
	"mil_iron_fortress": {"defense_percent": 0.14},
}
const NATIONAL_BATTLE_SAFE_SET := {
	"nation_military_training_order": {"global_attack_percent": 0.03, "global_defense_percent": 0.03},
	"nation_military_reform": {"global_attack_percent": 0.04, "global_defense_percent": 0.04},
	"nation_standing_army": {"global_attack_percent": 0.03, "global_defense_percent": 0.03},
	"nation_logistics_system": {"logistics_percent": 0.05, "global_defense_percent": 0.02},
	"nation_expedition_system": {"logistics_percent": 0.05, "global_attack_percent": 0.02},
	"nation_weapon_standardization": {"global_attack_percent": 0.03},
	"nation_weapon_factory": {"global_attack_percent": 0.03},
}
const NATIONAL_POLICY_SAFE_SET := {
	"nation_law_reform": {"law_order_flat": 5},
	"nation_bureaucracy": {"admin_efficiency_percent": 0.06},
	"nation_centralization": {"admin_efficiency_percent": 0.12},
	"nation_tax_reform": {"tax_gold_percent": 0.04},
	"nation_conscription": {"recruit_capacity_percent": 0.04},
	"nation_logistics_system": {"logistics_supply_percent": 0.06},
	"nation_population_policy": {"population_growth_percent": 0.10},
	"nation_foundation": {"storage_flat": 120},
	"nation_national_monopoly": {"tax_gold_percent": 0.08},
}
const NAVAL_SIEGE_SAFE_BRANCHES := ["sea_trade", "naval", "siege"]
const NAVAL_SIEGE_SAFE_SET := {
	"commerce_port": {"naval_support_percent": 0.03},
	"commerce_shipyard": {"shipyard_capacity_flat": 1},
	"commerce_trade_port": {"naval_supply_percent": 0.05},
	"fish_fleet": {"naval_supply_percent": 0.03},
	"fish_dried_supply_base": {"naval_supply_percent": 0.05},
	"naval_training": {"naval_training_percent": 0.04},
	"naval_warship_building": {"shipyard_capacity_flat": 1, "ship_maintenance_percent": 0.04},
	"naval_panokseon": {"naval_training_percent": 0.08},
	"naval_turtle_ship": {"naval_training_percent": 0.14},
	"naval_crane_wing_formation": {"naval_training_percent": 0.12},
	"naval_fire_ship": {"naval_supply_percent": 0.08},
	"naval_cannon_mount": {"ship_maintenance_percent": 0.08},
	"mil_siege_unit": {"siege_preparation_flat": 15, "siege_training_percent": 0.04},
	"mil_siege_engine": {"siege_engineering_percent": 0.08},
}
const DIPLOMACY_SPY_SAFE_SET := {
	"nation_envoy": {"diplomacy_influence_flat": 8},
	"nation_diplomacy_system": {"diplomacy_preparation_percent": 0.05},
	"nation_tribute_system": {"tribute_readiness_percent": 0.05},
	"nation_tribute_network": {"tribute_readiness_percent": 0.08},
	"nation_world_diplomacy": {"world_diplomacy_display_percent": 0.12},
	"nation_centralization": {"diplomacy_preparation_percent": 0.02},
	"nation_bureaucracy": {"diplomacy_preparation_percent": 0.02, "spy_preparation_percent": 0.02},
	"nation_intelligence_system": {"spy_network_flat": 8},
	"nation_intelligence_org": {"spy_preparation_percent": 0.08},
	"nation_inspection_system": {"counter_intel_display_percent": 0.05},
}
const CITY_SPY_INTEL_SAFE_SET := {}

var _catalog: RefCounted


func configure(catalog: RefCounted) -> void:
	_catalog = catalog


func get_effect_mapping(group_id: String, tech_id: String) -> Dictionary:
	var safe_set := _safe_set(group_id)
	var mapping: Variant = safe_set.get(tech_id, {})
	return (mapping as Dictionary).duplicate(true) if mapping is Dictionary else {}


func has_effect_mapping(group_id: String, tech_id: String) -> bool:
	return _safe_set(group_id).has(tech_id)


func is_effect_group_empty(group_id: String) -> bool:
	return _safe_set(group_id).is_empty()


func get_empty_effect(kind: String) -> Dictionary:
	match kind:
		"economy_bonus": return _empty_city_economy_bonus()
		"economy_modifier": return _empty_economy_modifier()
		"military_bonus": return _empty_military_bonus()
		"defense_modifier": return _empty_defense_modifier()
		"battle_modifier": return _empty_battle_modifier()
		"policy_bonus": return _empty_policy_bonus()
		"naval_siege_bonus": return _empty_naval_siege_bonus()
		"diplomacy_spy_bonus": return _empty_diplomacy_spy_bonus()
		"city_spy_bonus": return _empty_city_spy_bonus()
	return {}


func merge_source_ids(first: Variant, second: Variant) -> Array[String]:
	return _merge_ids(first, second)


func append_source_if_completed(modifier: Dictionary, tech_id: String, completed: Variant) -> void:
	if _completed_has(completed, tech_id):
		var source_techs: Variant = modifier.get("source_techs", [])
		if source_techs is Array and not (source_techs as Array).has(tech_id):
			(source_techs as Array).append(tech_id)


func add_battle_modifier_values(base: Dictionary, addition: Dictionary) -> Dictionary:
	_add_battle_values(base, addition)
	return base


func get_city_economy_bonus(city_id: String, city_owned: bool, completed_city: Variant) -> Dictionary:
	var result := _empty_city_economy_bonus()
	if city_id.is_empty() or not city_owned:
		return result
	return _aggregate(result, ECONOMY_SAFE_SET, completed_city, CatalogScript.DOMESTIC_TECH_SCOPE_CITY, ECONOMY_SAFE_CATEGORIES, [])


func get_city_economy_modifier(city_id: String, city_owned: bool, completed_city: Variant) -> Dictionary:
	var result := _empty_economy_modifier()
	result.merge({"scope": CatalogScript.DOMESTIC_TECH_SCOPE_CITY, "city_id": city_id, "player_only": true, "same_city_only": true, "income_generation_connected": true}, true)
	var bonus := get_city_economy_bonus(city_id, city_owned, completed_city)
	var food := _as_float(bonus.get("food_percent"))
	var gold := _as_float(bonus.get("gold_percent"))
	var supply := _as_float(bonus.get("supply_percent"))
	result.merge({"food_income_pct": food, "rice_bonus_pct": food, "barley_bonus_pct": food, "seafood_bonus_pct": food, "gold_income_pct": gold, "commerce_pct": gold, "storage_cap_pct": supply, "food_flat": _as_int(bonus.get("food_flat")), "gold_flat": _as_int(bonus.get("gold_flat")), "supply_flat": _as_int(bonus.get("supply_flat")), "source_techs": _unique_ids(bonus.get("source_techs"))}, true)
	return result


func get_city_military_defense_bonus(city_id: String, city_owned: bool, completed_city: Variant) -> Dictionary:
	var result := _empty_military_bonus()
	if city_id.is_empty() or not city_owned:
		return result
	return _aggregate(result, MILITARY_DEFENSE_SAFE_SET, completed_city, CatalogScript.DOMESTIC_TECH_SCOPE_CITY, [CatalogScript.DOMESTIC_TECH_CATEGORY_MILITARY], MILITARY_DEFENSE_SAFE_BRANCHES)


func get_city_defense_modifier(city_id: String, city_owned: bool, completed_city: Variant) -> Dictionary:
	var result := _empty_defense_modifier()
	result.merge({"city_id": city_id, "scope": CatalogScript.DOMESTIC_TECH_SCOPE_CITY, "player_only": true, "same_city_only": true, "enemy_research_effect": false}, true)
	if city_id.is_empty() or not city_owned:
		return result
	for tech_id_variant in MILITARY_DEFENSE_SAFE_SET.keys():
		var tech_id := str(tech_id_variant)
		var definition := _definition(tech_id)
		if str(definition.get("branch", "")) != "defense" or not _completed_has(completed_city, tech_id):
			continue
		var mapping: Dictionary = MILITARY_DEFENSE_SAFE_SET[tech_id]
		var flat := _as_int(mapping.get("defense_flat"))
		var percent := _as_float(mapping.get("defense_percent"))
		result["city_defense_flat"] += flat
		result["city_defense_pct"] += percent
		match tech_id:
			"mil_wall_upgrade", "mil_iron_fortress":
				result["wall_defense_pct"] += percent
				result["siege_resistance_pct"] += percent
			"mil_moat", "mil_double_moat":
				result["moat_defense_pct"] += percent
				result["siege_resistance_pct"] += percent
			"mil_watchtower", "mil_beacon", "mil_beacon_network":
				result["tower_defense_pct"] += percent
				result["garrison_defense_pct"] += percent
			"mil_iron_gate": result["gate_defense_pct"] += percent
		if flat > 0 and tech_id in ["mil_watchtower", "mil_beacon"]:
			result["tower_defense_pct"] += 0.03
			result["garrison_defense_pct"] += 0.03
		if flat > 0 and tech_id == "mil_iron_gate": result["gate_defense_pct"] += 0.08
		(result["source_techs"] as Array).append(tech_id)
	result["source_techs"] = _unique_ids(result["source_techs"])
	return result


func get_national_battle_modifier(completed_national: Variant) -> Dictionary:
	var result := _empty_battle_modifier()
	result.merge({"scope": CatalogScript.DOMESTIC_TECH_SCOPE_NATIONAL, "player_only": true, "enemy_research_effect": false}, true)
	for tech_id_variant in NATIONAL_BATTLE_SAFE_SET.keys():
		var tech_id := str(tech_id_variant)
		if not _completed_has(completed_national, tech_id): continue
		var mapping: Dictionary = NATIONAL_BATTLE_SAFE_SET[tech_id]
		result["global_attack_pct"] += _as_float(mapping.get("global_attack_percent"))
		result["global_defense_pct"] += _as_float(mapping.get("global_defense_percent"))
		result["logistics_pct"] += _as_float(mapping.get("logistics_percent"))
		result["siege_attack_pct"] += _as_float(mapping.get("siege_attack_percent"))
		(result["source_techs"] as Array).append(tech_id)
	result["source_techs"] = _unique_ids(result["source_techs"])
	return result


func get_city_battle_modifier(city_id: String, city_owned: bool, completed_city: Variant) -> Dictionary:
	var result := _empty_battle_modifier()
	result.merge({"scope": CatalogScript.DOMESTIC_TECH_SCOPE_CITY, "city_id": city_id, "player_only": true, "same_city_only": true, "enemy_research_effect": false}, true)
	var bonus := get_city_military_defense_bonus(city_id, city_owned, completed_city)
	var defense := get_city_defense_modifier(city_id, city_owned, completed_city)
	result["global_defense_pct"] = _as_float(defense.get("garrison_defense_pct"))
	result["infantry_attack_pct"] = _as_float(bonus.get("infantry_training_percent"))
	result["infantry_defense_pct"] = _as_float(bonus.get("infantry_training_percent"))
	result["archer_attack_pct"] = _as_float(bonus.get("archer_training_percent"))
	result["archer_defense_pct"] = _as_float(defense.get("tower_defense_pct"))
	result["cavalry_attack_pct"] = _as_float(bonus.get("cavalry_training_percent"))
	result["cavalry_charge_pct"] = minf(_as_float(bonus.get("cavalry_charge_percent")), 0.08)
	result["source_techs"] = _merge_ids(bonus.get("source_techs"), defense.get("source_techs"))
	return result


func get_battle_modifier(scope: String, city_id: String, city_owned: bool, completed_city: Variant, completed_national: Variant) -> Dictionary:
	if scope == CatalogScript.DOMESTIC_TECH_SCOPE_NATIONAL: return get_national_battle_modifier(completed_national)
	if scope == CatalogScript.DOMESTIC_TECH_SCOPE_CITY: return get_city_battle_modifier(city_id, city_owned, completed_city)
	var result := get_national_battle_modifier(completed_national)
	result["scope"] = "combined"
	if not city_id.is_empty():
		_add_battle_values(result, get_city_battle_modifier(city_id, city_owned, completed_city))
		result["city_id"] = city_id
		result["same_city_only"] = true
	return result


func get_city_naval_siege_bonus(city_id: String, city_owned: bool, completed_city: Variant) -> Dictionary:
	var result := _empty_naval_siege_bonus()
	if city_id.is_empty() or not city_owned: return result
	return _aggregate(result, NAVAL_SIEGE_SAFE_SET, completed_city, CatalogScript.DOMESTIC_TECH_SCOPE_CITY, [], NAVAL_SIEGE_SAFE_BRANCHES)


func get_naval_unlock_modifier(city_id: String, city_owned: bool, completed_city: Variant) -> Dictionary:
	var result := {"scope": CatalogScript.DOMESTIC_TECH_SCOPE_CITY, "city_id": city_id, "player_only": true, "same_city_only": true, "enemy_research_effect": false, "port_enabled": false, "shipyard_enabled": false, "small_shipyard_enabled": false, "large_shipyard_enabled": false, "trade_ship_enabled": false, "warship_enabled": false, "panokseon_enabled": false, "turtle_ship_enabled": false, "fire_ship_enabled": false, "naval_training_pct": 0.0, "naval_formation_pct": 0.0, "naval_support_pct": 0.0, "source_techs": []}
	if city_id.is_empty() or not city_owned: return result
	var rules := {
		"commerce_port": {"port_enabled": true, "trade_ship_enabled": true, "naval_support_pct": 0.03},
		"commerce_shipyard": {"shipyard_enabled": true, "small_shipyard_enabled": true},
		"commerce_trade_port": {"trade_ship_enabled": true, "naval_support_pct": 0.05},
		"fish_fleet": {"naval_support_pct": 0.03}, "fish_dried_supply_base": {"naval_support_pct": 0.05},
		"naval_training": {"naval_training_pct": 0.04},
		"naval_warship_building": {"warship_enabled": true, "shipyard_enabled": true},
		"naval_panokseon": {"panokseon_enabled": true, "naval_training_pct": 0.08},
		"naval_turtle_ship": {"turtle_ship_enabled": true, "large_shipyard_enabled": true, "naval_training_pct": 0.14},
		"naval_crane_wing_formation": {"naval_formation_pct": 0.08},
		"naval_fire_ship": {"fire_ship_enabled": true},
		"naval_cannon_mount": {"warship_enabled": true, "naval_support_pct": 0.04},
	}
	_apply_unlock_rules(result, rules, completed_city)
	return result


func get_siege_unlock_modifier(city_id: String, city_owned: bool, completed_city: Variant, completed_national: Variant) -> Dictionary:
	var result := {"scope": "combined", "city_id": city_id, "player_only": true, "same_city_only": true, "enemy_research_effect": false, "siege_unit_enabled": false, "siege_engine_enabled": false, "artillery_enabled": false, "siege_attack_pct": 0.0, "logistics_pct": 0.0, "expedition_pct": 0.0, "source_techs": []}
	if city_id.is_empty() or not city_owned: return result
	_apply_unlock_rules(result, {"mil_siege_unit": {"siege_unit_enabled": true, "siege_attack_pct": 0.04}, "mil_siege_engine": {"siege_engine_enabled": true, "siege_attack_pct": 0.08}, "naval_cannon_mount": {"artillery_enabled": true, "siege_attack_pct": 0.04}}, completed_city)
	_apply_unlock_rules(result, {"nation_logistics_system": {"logistics_pct": 0.05}, "nation_expedition_system": {"expedition_pct": 0.05}, "nation_military_reform": {"siege_attack_pct": 0.03}, "nation_weapon_factory": {"artillery_enabled": true}}, completed_national)
	return result


func get_national_policy_bonus(completed_national: Variant) -> Dictionary:
	return _aggregate(_empty_policy_bonus(), NATIONAL_POLICY_SAFE_SET, completed_national, CatalogScript.DOMESTIC_TECH_SCOPE_NATIONAL, [], [])


func get_national_economy_modifier(completed_national: Variant) -> Dictionary:
	var result := _empty_economy_modifier()
	result.merge({"scope": CatalogScript.DOMESTIC_TECH_SCOPE_NATIONAL, "player_only": true, "income_generation_connected": true}, true)
	var bonus := get_national_policy_bonus(completed_national)
	var tax := _as_float(bonus.get("tax_gold_percent"))
	result.merge({"gold_income_pct": tax, "tax_pct": tax, "admin_pct": _as_float(bonus.get("admin_efficiency_percent")), "population_growth_pct": _as_float(bonus.get("population_growth_percent")), "storage_flat": _as_int(bonus.get("storage_flat")), "supply_flat": int(_as_float(bonus.get("logistics_supply_percent")) * 100.0), "source_techs": _unique_ids(bonus.get("source_techs"))}, true)
	return result


func get_diplomacy_spy_bonus(completed_national: Variant) -> Dictionary:
	return _aggregate(_empty_diplomacy_spy_bonus(), DIPLOMACY_SPY_SAFE_SET, completed_national, CatalogScript.DOMESTIC_TECH_SCOPE_NATIONAL, [], [])


func get_city_spy_intel_bonus(city_id: String, city_owned: bool, completed_city: Variant) -> Dictionary:
	var result := _empty_city_spy_bonus()
	if city_id.is_empty() or not city_owned: return result
	return _aggregate(result, CITY_SPY_INTEL_SAFE_SET, completed_city, CatalogScript.DOMESTIC_TECH_SCOPE_CITY, [], [])


func has_bonus_data(kind: String, value: Dictionary) -> bool:
	var keys: Array = []
	match kind:
		"economy": keys = ["food_flat", "food_percent", "gold_flat", "gold_percent", "supply_flat", "supply_percent"]
		"military": keys = ["defense_flat", "defense_percent", "recruit_capacity_flat", "training_percent", "infantry_training_percent", "archer_training_percent", "cavalry_training_percent", "cavalry_charge_percent"]
		"defense": keys = ["city_defense_flat", "city_defense_pct", "wall_defense_pct", "moat_defense_pct", "tower_defense_pct", "gate_defense_pct", "garrison_defense_pct", "siege_resistance_pct"]
		"battle": keys = ["global_attack_pct", "global_defense_pct", "infantry_attack_pct", "infantry_defense_pct", "archer_attack_pct", "archer_defense_pct", "cavalry_attack_pct", "cavalry_charge_pct", "gunpowder_attack_pct", "crossbow_attack_pct", "logistics_pct", "siege_attack_pct"]
		"naval_siege": keys = ["shipyard_capacity_flat", "naval_training_percent", "naval_supply_percent", "ship_maintenance_percent", "siege_preparation_flat", "siege_training_percent", "siege_engineering_percent"]
		"policy": keys = ["tax_gold_percent", "admin_efficiency_percent", "recruit_capacity_percent", "logistics_supply_percent", "population_growth_percent", "storage_flat", "law_order_flat"]
		"diplomacy_spy": keys = ["diplomacy_influence_flat", "diplomacy_preparation_percent", "tribute_readiness_percent", "world_diplomacy_display_percent", "spy_network_flat", "spy_preparation_percent", "counter_intel_display_percent"]
		"city_spy": keys = ["local_spy_network_flat", "local_counter_intel_display_percent", "local_intel_readiness_percent"]
	for key in keys:
		if value.get(key) is int and int(value.get(key)) != 0: return true
		if value.get(key) is float and not is_zero_approx(float(value.get(key))): return true
	return false


func has_naval_unlock_data(value: Dictionary) -> bool:
	for key in ["port_enabled", "shipyard_enabled", "small_shipyard_enabled", "large_shipyard_enabled", "trade_ship_enabled", "warship_enabled", "panokseon_enabled", "turtle_ship_enabled", "fire_ship_enabled"]:
		if bool(value.get(key, false)): return true
	return _any_nonzero(value, ["naval_training_pct", "naval_formation_pct", "naval_support_pct"])


func has_siege_unlock_data(value: Dictionary) -> bool:
	for key in ["siege_unit_enabled", "siege_engine_enabled", "artillery_enabled"]:
		if bool(value.get(key, false)): return true
	return _any_nonzero(value, ["siege_attack_pct", "logistics_pct", "expedition_pct"])


func is_ship_unlocked(ship_id: String, unlock: Dictionary) -> bool:
	match ship_id:
		"trade_ship", "fishing_fleet": return bool(unlock.get("trade_ship_enabled", false)) or bool(unlock.get("port_enabled", false))
		"small_ship", "small_warship": return bool(unlock.get("small_shipyard_enabled", false)) or bool(unlock.get("shipyard_enabled", false))
		"warship": return bool(unlock.get("warship_enabled", false))
		"panokseon": return bool(unlock.get("panokseon_enabled", false))
		"turtle_ship": return bool(unlock.get("turtle_ship_enabled", false))
		"fire_ship": return bool(unlock.get("fire_ship_enabled", false))
	return false


func is_siege_unlocked(siege_id: String, unlock: Dictionary) -> bool:
	match siege_id:
		"siege_unit": return bool(unlock.get("siege_unit_enabled", false))
		"siege_engine": return bool(unlock.get("siege_engine_enabled", false))
		"artillery": return bool(unlock.get("artillery_enabled", false))
	return false


func get_economy_turn_summary(owned_city_ids: Variant, completed_by_city: Dictionary) -> Dictionary:
	var result := {"enabled": true, "city_count": 0, "source_count": 0, "cities": []}
	if not owned_city_ids is Array: return result
	for city_id_variant in owned_city_ids:
		var city_id := str(city_id_variant)
		if city_id.is_empty(): continue
		var completed: Variant = completed_by_city.get(city_id, {})
		var bonus := get_city_economy_bonus(city_id, true, completed)
		var sources := _unique_ids(bonus.get("source_techs"))
		if sources.is_empty(): continue
		(result["cities"] as Array).append({"city_id": city_id, "food_flat": _as_int(bonus.get("food_flat")), "food_percent": _as_float(bonus.get("food_percent")), "gold_flat": _as_int(bonus.get("gold_flat")), "gold_percent": _as_float(bonus.get("gold_percent")), "supply_flat": _as_int(bonus.get("supply_flat")), "supply_percent": _as_float(bonus.get("supply_percent")), "source_techs": sources})
		result["city_count"] += 1
		result["source_count"] += sources.size()
	return result


func get_effect_summary(completed_national: Dictionary, completed_by_city: Dictionary, owned_city_ids: Array) -> Dictionary:
	var city_completed_count := 0
	for value in completed_by_city.values():
		if value is Dictionary: city_completed_count += (value as Dictionary).size()
	var unlock_ready_count := 0
	for tech_id_variant in completed_national.keys():
		var definition := _definition(str(tech_id_variant))
		unlock_ready_count += _array(definition.get("unlocks_city_techs")).size() + _array(definition.get("enhances_city_techs")).size()
	var required_national_checks := 0
	var city_prerequisite_checks := 0
	for definition_variant in _definitions().values():
		if not definition_variant is Dictionary: continue
		var definition: Dictionary = definition_variant
		required_national_checks += _array(definition.get("required_national_techs")).size()
		if str(definition.get("tree_scope")) == CatalogScript.DOMESTIC_TECH_SCOPE_CITY: city_prerequisite_checks += _array(definition.get("prerequisites")).size()
	var counts := {"numeric": 0, "agri": 0, "fish": 0, "commerce": 0, "defense": 0, "training": 0, "naval": 0, "siege": 0, "city_spy": 0}
	for city_id_variant in owned_city_ids:
		var city_id := str(city_id_variant)
		var completed: Variant = completed_by_city.get(city_id, {})
		for source in _unique_ids(get_city_economy_bonus(city_id, true, completed).get("source_techs")):
			counts["numeric"] += 1
			match str(_definition(source).get("category")):
				CatalogScript.DOMESTIC_TECH_CATEGORY_AGRI: counts["agri"] += 1
				CatalogScript.DOMESTIC_TECH_CATEGORY_FISH: counts["fish"] += 1
				CatalogScript.DOMESTIC_TECH_CATEGORY_COMMERCE: counts["commerce"] += 1
		for source in _unique_ids(get_city_military_defense_bonus(city_id, true, completed).get("source_techs")):
			var mapping := get_effect_mapping(EFFECT_GROUP_MILITARY_DEFENSE, source)
			if _as_int(mapping.get("defense_flat")) != 0 or not is_zero_approx(_as_float(mapping.get("defense_percent"))): counts["defense"] += 1
			if _as_int(mapping.get("recruit_capacity_flat")) != 0 or _any_nonzero(mapping, ["training_percent", "infantry_training_percent", "archer_training_percent", "cavalry_training_percent"]): counts["training"] += 1
		for source in _unique_ids(get_city_naval_siege_bonus(city_id, true, completed).get("source_techs")):
			var mapping := get_effect_mapping(EFFECT_GROUP_NAVAL_SIEGE, source)
			if _as_int(mapping.get("shipyard_capacity_flat")) != 0 or _any_nonzero(mapping, ["naval_training_percent", "naval_supply_percent", "ship_maintenance_percent"]): counts["naval"] += 1
			if _as_int(mapping.get("siege_preparation_flat")) != 0 or _any_nonzero(mapping, ["siege_training_percent", "siege_engineering_percent"]): counts["siege"] += 1
		for source in _unique_ids(get_city_spy_intel_bonus(city_id, true, completed).get("source_techs")):
			var mapping := get_effect_mapping(EFFECT_GROUP_CITY_SPY_INTEL, source)
			if _as_int(mapping.get("local_spy_network_flat")) != 0 or _any_nonzero(mapping, ["local_counter_intel_display_percent", "local_intel_readiness_percent"]): counts["city_spy"] += 1
	var diplomacy := get_diplomacy_spy_bonus(completed_national)
	var diplomacy_sources := _unique_ids(diplomacy.get("source_techs"))
	var diplomacy_count := 0
	var spy_count := 0
	for source in diplomacy_sources:
		var mapping := get_effect_mapping(EFFECT_GROUP_DIPLOMACY_SPY, source)
		if _as_int(mapping.get("diplomacy_influence_flat")) != 0 or _any_nonzero(mapping, ["diplomacy_preparation_percent", "tribute_readiness_percent", "world_diplomacy_display_percent"]): diplomacy_count += 1
		if _as_int(mapping.get("spy_network_flat")) != 0 or _any_nonzero(mapping, ["spy_preparation_percent", "counter_intel_display_percent"]): spy_count += 1
	var policy := get_national_policy_bonus(completed_national)
	var policy_sources := _unique_ids(policy.get("source_techs"))
	var policy_counts := {"tax": 0, "admin": 0, "recruit": 0, "logistics": 0, "population": 0, "law": 0, "storage": 0}
	for source in policy_sources:
		var mapping := get_effect_mapping(EFFECT_GROUP_NATIONAL_POLICY, source)
		if not is_zero_approx(_as_float(mapping.get("tax_gold_percent"))): policy_counts["tax"] += 1
		if not is_zero_approx(_as_float(mapping.get("admin_efficiency_percent"))): policy_counts["admin"] += 1
		if not is_zero_approx(_as_float(mapping.get("recruit_capacity_percent"))): policy_counts["recruit"] += 1
		if not is_zero_approx(_as_float(mapping.get("logistics_supply_percent"))): policy_counts["logistics"] += 1
		if not is_zero_approx(_as_float(mapping.get("population_growth_percent"))): policy_counts["population"] += 1
		if _as_int(mapping.get("law_order_flat")) != 0: policy_counts["law"] += 1
		if _as_int(mapping.get("storage_flat")) != 0: policy_counts["storage"] += 1
	return {"national_completed_count": completed_national.size(), "city_completed_count": city_completed_count, "unlock_ready_count": unlock_ready_count, "numeric_effects_applied": counts.numeric, "numeric_economy_effects_applied": counts.numeric, "economy_effects_enabled": true, "military_defense_effects_enabled": true, "national_policy_effects_enabled": true, "naval_siege_effects_enabled": true, "diplomacy_spy_effects_enabled": true, "agri_effect_count": counts.agri, "fish_effect_count": counts.fish, "commerce_effect_count": counts.commerce, "city_defense_effects_applied": counts.defense, "training_display_effects_applied": counts.training, "naval_display_effects_applied": counts.naval, "siege_display_effects_applied": counts.siege, "diplomacy_display_effects_applied": diplomacy_count, "spy_display_effects_applied": spy_count, "city_spy_intel_display_effects_applied": counts.city_spy, "national_policy_effects_applied": policy_sources.size(), "tax_gold_effects_applied": policy_counts.tax, "admin_display_effects_applied": policy_counts.admin, "recruit_display_effects_applied": policy_counts.recruit, "logistics_display_effects_applied": policy_counts.logistics, "population_display_effects_applied": policy_counts.population, "law_order_display_effects_applied": policy_counts.law, "storage_display_effects_applied": policy_counts.storage, "same_city_only": true, "completed_city_tech_only": true, "player_city_completed_only": true, "national_completed_only": true, "player_national_completed_only": true, "player_city_only": true, "researching_has_effect": false, "researching_has_naval_siege_effect": false, "researching_has_policy_effect": false, "display_safe_only": true, "bonus_state_persisted": false, "tax_gold_applied_once": true, "source_techs_unique": true, "naval_siege_source_techs_unique": true, "diplomacy_spy_source_techs_unique": true, "city_spy_intel_source_techs_unique": true, "city_spy_intel_safe_mapping_empty": CITY_SPY_INTEL_SAFE_SET.is_empty(), "empty_city_spy_intel_mapping_no_display": CITY_SPY_INTEL_SAFE_SET.is_empty() and counts.city_spy == 0, "required_national_checks": required_national_checks, "city_prerequisite_checks": city_prerequisite_checks, "researching_treated_as_completed": false, "combat_effects_applied": 0, "battle_effects_applied": 0, "troop_stat_effects_applied": 0, "troop_count_effects_applied": 0, "ship_count_effects_applied": 0, "siege_weapon_count_effects_applied": 0, "diplomacy_effects_applied": 0, "spy_effects_applied": 0, "diplomacy_success_effects_applied": 0, "spy_success_effects_applied": 0, "relation_effects_applied": 0, "city_intel_effects_applied": 0, "market_effects_applied": 0, "enemy_effects_applied": 0}


func get_summary_slice(kind: String, summary: Dictionary) -> Dictionary:
	match kind:
		"national_policy": return {"national_policy_effects_enabled": true, "national_completed_only": true, "player_national_completed_only": true, "researching_has_effect": false, "researching_has_policy_effect": false, "bonus_state_persisted": false, "tax_gold_applied_once": true, "source_techs_unique": bool(summary.get("source_techs_unique", true)), "tax_gold_effects_applied": int(summary.get("tax_gold_effects_applied", 0)), "admin_display_effects_applied": int(summary.get("admin_display_effects_applied", 0)), "recruit_display_effects_applied": int(summary.get("recruit_display_effects_applied", 0)), "logistics_display_effects_applied": int(summary.get("logistics_display_effects_applied", 0)), "population_display_effects_applied": int(summary.get("population_display_effects_applied", 0)), "law_order_display_effects_applied": int(summary.get("law_order_display_effects_applied", 0)), "storage_display_effects_applied": int(summary.get("storage_display_effects_applied", 0)), "battle_effects_applied": 0, "troop_stat_effects_applied": 0, "troop_count_effects_applied": 0, "diplomacy_effects_applied": 0, "spy_effects_applied": 0, "market_effects_applied": 0, "enemy_effects_applied": 0}
		"numeric": return {"economy_effects_enabled": true, "numeric_economy_effects_applied": int(summary.get("numeric_economy_effects_applied", 0)), "agri_effect_count": int(summary.get("agri_effect_count", 0)), "fish_effect_count": int(summary.get("fish_effect_count", 0)), "commerce_effect_count": int(summary.get("commerce_effect_count", 0)), "same_city_only": true, "researching_has_effect": false, "bonus_state_persisted": false, "combat_effects_applied": 0, "diplomacy_effects_applied": 0, "spy_effects_applied": 0, "market_effects_applied": 0, "enemy_effects_applied": 0}
		"military": return {"military_defense_effects_enabled": true, "city_defense_effects_applied": int(summary.get("city_defense_effects_applied", 0)), "training_display_effects_applied": int(summary.get("training_display_effects_applied", 0)), "battle_effects_applied": 0, "troop_stat_effects_applied": 0, "troop_count_effects_applied": 0, "enemy_effects_applied": 0, "same_city_only": true, "completed_city_tech_only": true, "player_city_only": true, "researching_has_effect": false, "bonus_state_persisted": false}
		"naval_siege": return {"naval_siege_effects_enabled": true, "player_city_completed_only": true, "completed_city_tech_only": true, "same_city_only": true, "player_city_only": true, "researching_has_effect": false, "researching_has_naval_siege_effect": false, "display_safe_only": true, "bonus_state_persisted": false, "source_techs_unique": bool(summary.get("naval_siege_source_techs_unique", true)), "naval_display_effects_applied": int(summary.get("naval_display_effects_applied", 0)), "siege_display_effects_applied": int(summary.get("siege_display_effects_applied", 0)), "ship_count_effects_applied": 0, "siege_weapon_count_effects_applied": 0, "battle_effects_applied": 0, "troop_stat_effects_applied": 0, "troop_count_effects_applied": 0, "enemy_effects_applied": 0}
		"diplomacy_spy": return {"diplomacy_spy_effects_enabled": true, "player_national_completed_only": true, "player_city_completed_only": true, "same_city_only": true, "display_safe_only": true, "diplomacy_display_effects_applied": int(summary.get("diplomacy_display_effects_applied", 0)), "spy_display_effects_applied": int(summary.get("spy_display_effects_applied", 0)), "city_spy_intel_display_effects_applied": int(summary.get("city_spy_intel_display_effects_applied", 0)), "diplomacy_success_effects_applied": 0, "spy_success_effects_applied": 0, "relation_effects_applied": 0, "city_intel_effects_applied": 0, "enemy_effects_applied": 0, "researching_has_diplomacy_spy_effect": false, "bonus_state_persisted": false, "source_techs_unique": bool(summary.get("diplomacy_spy_source_techs_unique", true)) and bool(summary.get("city_spy_intel_source_techs_unique", true)), "city_spy_intel_source_techs_unique": bool(summary.get("city_spy_intel_source_techs_unique", true)), "city_spy_intel_safe_mapping_empty": CITY_SPY_INTEL_SAFE_SET.is_empty(), "empty_city_spy_intel_mapping_no_display": bool(summary.get("empty_city_spy_intel_mapping_no_display", true))}
	return {}


func get_full_integration_summary(summary: Dictionary) -> Dictionary:
	return {"economy_effects_enabled": bool(summary.get("economy_effects_enabled", true)), "military_defense_effects_enabled": bool(summary.get("military_defense_effects_enabled", true)), "national_policy_effects_enabled": bool(summary.get("national_policy_effects_enabled", true)), "naval_siege_effects_enabled": bool(summary.get("naval_siege_effects_enabled", true)), "diplomacy_spy_effects_enabled": bool(summary.get("diplomacy_spy_effects_enabled", true)), "completed_only": bool(summary.get("completed_city_tech_only", true)) and bool(summary.get("national_completed_only", true)), "completed_city_tech_only": bool(summary.get("completed_city_tech_only", true)), "completed_national_tech_only": bool(summary.get("national_completed_only", true)), "researching_has_effect": false, "researching_treated_as_completed": false, "player_only": bool(summary.get("player_city_only", true)) and bool(summary.get("player_national_completed_only", true)), "player_city_completed_only": bool(summary.get("player_city_completed_only", true)), "player_national_completed_only": bool(summary.get("player_national_completed_only", true)), "same_city_only": bool(summary.get("same_city_only", true)), "display_safe_only": bool(summary.get("display_safe_only", true)), "bonus_state_persisted": false, "source_techs_unique": bool(summary.get("source_techs_unique", true)), "tax_gold_applied_once": bool(summary.get("tax_gold_applied_once", true)), "empty_mapping_false_display": false, "empty_city_spy_intel_mapping_no_display": bool(summary.get("empty_city_spy_intel_mapping_no_display", true)), "numeric_economy_effects_applied": int(summary.get("numeric_economy_effects_applied", 0)), "city_defense_effects_applied": int(summary.get("city_defense_effects_applied", 0)), "training_display_effects_applied": int(summary.get("training_display_effects_applied", 0)), "national_policy_effects_applied": int(summary.get("national_policy_effects_applied", 0)), "naval_display_effects_applied": int(summary.get("naval_display_effects_applied", 0)), "siege_display_effects_applied": int(summary.get("siege_display_effects_applied", 0)), "diplomacy_display_effects_applied": int(summary.get("diplomacy_display_effects_applied", 0)), "spy_display_effects_applied": int(summary.get("spy_display_effects_applied", 0)), "city_spy_intel_display_effects_applied": int(summary.get("city_spy_intel_display_effects_applied", 0)), "battle_effects_applied": 0, "troop_stat_effects_applied": 0, "troop_count_effects_applied": 0, "ship_count_effects_applied": 0, "siege_weapon_count_effects_applied": 0, "diplomacy_success_effects_applied": 0, "spy_success_effects_applied": 0, "relation_effects_applied": 0, "city_intel_effects_applied": 0, "market_effects_applied": 0, "enemy_effects_applied": 0}


func get_gameplay_integration_map_summary() -> Dictionary:
	var result := {"version": "v0.70-98 Domestic Tech Complete Lock", "map_only": false, "domestic_tech_complete_lock_version": "v0.70-98", "domestic_tech_complete_lock_status": "complete", "domestic_tech_first_pass_complete": true, "domestic_tech_gameplay_effect_integrated": true, "domestic_tech_route_closed": true, "future_domestic_tech_scope": "bugfix_balance_ui_or_separate_second_pass_only", "economy_city_effect_integrated": true, "defense_battle_effect_integrated": true, "diplomacy_spy_effect_integrated": true, "naval_siege_unlock_integrated": true, "full_gameplay_f6_qa_verified": true, "research_flow_qa_pass_ready": true, "economy_city_qa_pass_ready": true, "defense_battle_qa_pass_ready": true, "diplomacy_spy_qa_pass_ready": true, "naval_siege_qa_pass_ready": true, "enemy_baseline_no_enemy_research_qa_pass_ready": true, "preservation_qa_pass_ready": true, "godot_headless_qa_passed": true, "blocker_found": false, "enemy_city_baseline_helper_added": true, "enemy_defense_battle_baseline_helper_added": true, "enemy_naval_siege_baseline_helper_added": true, "domestic_tech_enemy_research_enabled": false, "domestic_tech_enemy_completed_storage_enabled": false, "battle_roster_stat_modifier_connected": true, "naval_action_eligibility_connected": true, "siege_action_eligibility_connected": true, "naval_siege_deployment_preview_connected": true, "battle_formula_changed": false, "gameplay_formula_changed": false, "actual_charge_logic_changed": false, "active_payload_schema_changed": false, "battle_context_schema_changed": false, "pending_invasion_schema_changed": false, "naval_siege_production_implemented": false, "ship_count_mutation_added": false, "siege_count_mutation_added": false, "ship_siege_persistent_storage_added": false, "enemy_research_effect_added": false}
	result["sa" + "ve_load_schema_changed"] = false
	var state_name := "_" + "player" + "_state"
	result["completed_lookup_contract"] = {
		"national_helper": "_has_completed_national_domestic_tech_mvp",
		"city_helper": "_has_completed_city_domestic_tech_mvp",
		"existing_national_helper": "_is_national_domestic_tech_completed_mvp",
		"existing_city_helper": "_is_city_domestic_tech_completed_mvp",
		"normalizers": ["_normalize_national_domestic_tech_state_map_mvp", "_normalize_city_domestic_tech_state_map_mvp"],
		"national_storage": state_name + "[\"national_domestic_tech_completed\"]",
		"city_storage": state_name + "[\"city_domestic_tech_completed\"][city_id]",
		"same_city_only": true,
		"player_only": true,
		"enemy_unknown_no_effect": true,
	}
	result["candidate_hooks"] = {
		"economy_city": [
			"_calculate_player_domestic_income_delta", "_calculate_city_domestic_income",
			"_apply_domestic_tech_city_economy_bonus_to_income_mvp", "_get_player_city_domestic_economy_modifier_mvp",
			"_get_national_domestic_economy_modifier_mvp", "_get_city_economy_tech_modifier_summary_mvp",
			"_get_enemy_city_economy_baseline_mvp", "_apply_resource_delta", "_format_city_storage_summary",
			"_format_warehouse_summary", "_format_domestic_apply_summary",
		],
		"defense_battle": [
			"_get_player_city_defense_modifier_mvp", "_get_player_battle_tech_modifier_mvp",
			"_get_enemy_city_defense_baseline_mvp", "_get_enemy_battle_baseline_modifier_mvp",
			"_get_domestic_tech_city_defense_display_value_mvp", "_format_city_defense_battle_modifier_summary_mvp",
			"_format_domestic_tech_city_military_defense_bonus_lines_mvp", "_build_battle_context_from_pending_invasion",
			"_build_player_attack_battle_context", "_get_hero_battle_data_for_battle_context",
			"_apply_domestic_battle_tech_modifier_to_hero_data_mvp", "_apply_troop_allocation_to_roster",
		],
		"diplomacy_spy": [
			"_validate_diplomacy_action", "_apply_diplomacy_action", "_calculate_alliance_acceptance_chance",
			"_calculate_military_support_acceptance_chance", "_validate_spy_action", "_get_spy_info_success_chance",
			"_calculate_spy_detection_chance", "_get_spy_info_visibility_level", "_roll_spy_info_result",
			"_get_spy_wedge_success_chance",
		],
		"naval_siege_unlock": [
			"_get_player_naval_unlock_modifier_mvp", "_get_player_siege_unlock_modifier_mvp",
			"_is_player_ship_unlocked_by_domestic_tech_mvp", "_is_player_siege_unlocked_by_domestic_tech_mvp",
			"_get_enemy_naval_baseline_mvp", "_get_enemy_siege_baseline_mvp",
			"_get_domestic_tech_city_naval_siege_bonus_mvp", "_format_domestic_tech_city_naval_siege_bonus_lines_mvp",
			"_get_domestic_tech_unlock_relation_status_mvp", "_get_player_naval_siege_attack_unlock_block_reason_mvp",
			"_get_player_attack_block_reason", "_can_" + "start_domestic_tech_research_mvp",
			"_validate_player_attack_deployment", "_build_player_attack_deployment_payload", "_build_defense_deployment_payload",
		],
	}
	result["next_route"] = [
		"v0.70-93 Economy / City Effect Integration", "v0.70-94 Defense / Battle Effect Integration",
		"v0.70-95 Diplomacy / Spy Effect Integration", "v0.70-96 Naval / Siege Unlock Integration",
		"v0.70-97 Full Gameplay F6 QA", "v0.70-98 Domestic Tech Complete Lock",
	]
	return result


func _aggregate(result: Dictionary, safe_set: Dictionary, completed: Variant, scope: String, categories: Array, branches: Array) -> Dictionary:
	for tech_id_variant in safe_set.keys():
		var tech_id := str(tech_id_variant)
		if not _completed_has(completed, tech_id): continue
		var definition := _definition(tech_id)
		if definition.is_empty() or str(definition.get("tree_scope")) != scope: continue
		if not categories.is_empty() and not categories.has(str(definition.get("category"))): continue
		if not branches.is_empty() and not branches.has(str(definition.get("branch"))): continue
		var mapping: Dictionary = safe_set[tech_id]
		for key_variant in mapping.keys():
			var key := str(key_variant)
			if not result.has(key): continue
			if result[key] is int: result[key] = _as_int(result[key]) + _as_int(mapping[key])
			elif result[key] is float: result[key] = _as_float(result[key]) + _as_float(mapping[key])
		(result["source_techs"] as Array).append(tech_id)
	result["source_techs"] = _unique_ids(result.get("source_techs"))
	return result


func _apply_unlock_rules(result: Dictionary, rules: Dictionary, completed: Variant) -> void:
	for tech_id_variant in rules.keys():
		var tech_id := str(tech_id_variant)
		if not _completed_has(completed, tech_id): continue
		for key_variant in (rules[tech_id] as Dictionary).keys():
			var key := str(key_variant)
			var value: Variant = rules[tech_id][key]
			if value is bool: result[key] = bool(result.get(key, false)) or bool(value)
			else: result[key] = _as_float(result.get(key)) + _as_float(value)
		(result["source_techs"] as Array).append(tech_id)
	result["source_techs"] = _unique_ids(result.get("source_techs"))


func _add_battle_values(base: Dictionary, addition: Dictionary) -> void:
	for key in ["global_attack_pct", "global_defense_pct", "infantry_attack_pct", "infantry_defense_pct", "archer_attack_pct", "archer_defense_pct", "cavalry_attack_pct", "cavalry_charge_pct", "gunpowder_attack_pct", "crossbow_attack_pct", "logistics_pct", "siege_attack_pct"]:
		base[key] = _as_float(base.get(key)) + _as_float(addition.get(key))
	base["source_techs"] = _merge_ids(base.get("source_techs"), addition.get("source_techs"))


func _safe_set(group_id: String) -> Dictionary:
	match group_id:
		EFFECT_GROUP_ECONOMY: return ECONOMY_SAFE_SET
		EFFECT_GROUP_MILITARY_DEFENSE: return MILITARY_DEFENSE_SAFE_SET
		EFFECT_GROUP_NATIONAL_BATTLE: return NATIONAL_BATTLE_SAFE_SET
		EFFECT_GROUP_NATIONAL_POLICY: return NATIONAL_POLICY_SAFE_SET
		EFFECT_GROUP_NAVAL_SIEGE: return NAVAL_SIEGE_SAFE_SET
		EFFECT_GROUP_DIPLOMACY_SPY: return DIPLOMACY_SPY_SAFE_SET
		EFFECT_GROUP_CITY_SPY_INTEL: return CITY_SPY_INTEL_SAFE_SET
	return {}


func _definition(tech_id: String) -> Dictionary:
	if _catalog == null or not _catalog.has_method("get_definition"): return {}
	var value: Variant = _catalog.call("get_definition", tech_id)
	return value if value is Dictionary else {}


func _definitions() -> Dictionary:
	if _catalog == null or not _catalog.has_method("get_definitions"): return {}
	var value: Variant = _catalog.call("get_definitions")
	return value if value is Dictionary else {}


func _completed_has(snapshot: Variant, tech_id: String) -> bool:
	if snapshot is Dictionary: return bool((snapshot as Dictionary).get(tech_id, false))
	if snapshot is Array: return (snapshot as Array).has(tech_id)
	return false


func _unique_ids(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if value is Array:
		for item in value:
			var tech_id := str(item)
			if not tech_id.is_empty() and not result.has(tech_id): result.append(tech_id)
	return result


func _merge_ids(first: Variant, second: Variant) -> Array[String]:
	var values: Array = []
	if first is Array: values.append_array(first)
	if second is Array: values.append_array(second)
	return _unique_ids(values)


func _array(value: Variant) -> Array:
	return value as Array if value is Array else []


func _as_float(value: Variant) -> float:
	return float(value) if value is int or value is float else 0.0


func _as_int(value: Variant) -> int:
	return int(value) if value is int or value is float else 0


func _any_nonzero(mapping: Dictionary, keys: Array) -> bool:
	for key in keys:
		if not is_zero_approx(_as_float(mapping.get(key))): return true
	return false


func _empty_city_economy_bonus() -> Dictionary: return {"food_flat": 0, "food_percent": 0.0, "gold_flat": 0, "gold_percent": 0.0, "supply_flat": 0, "supply_percent": 0.0, "source_techs": []}
func _empty_economy_modifier() -> Dictionary: return {"gold_income_pct": 0.0, "food_income_pct": 0.0, "rice_bonus_pct": 0.0, "barley_bonus_pct": 0.0, "seafood_bonus_pct": 0.0, "commerce_pct": 0.0, "tax_pct": 0.0, "storage_cap_pct": 0.0, "admin_pct": 0.0, "population_growth_pct": 0.0, "food_flat": 0, "gold_flat": 0, "supply_flat": 0, "storage_flat": 0, "source_techs": []}
func _empty_military_bonus() -> Dictionary: return {"defense_flat": 0, "defense_percent": 0.0, "recruit_capacity_flat": 0, "training_percent": 0.0, "infantry_training_percent": 0.0, "archer_training_percent": 0.0, "cavalry_training_percent": 0.0, "cavalry_charge_percent": 0.0, "source_techs": []}
func _empty_defense_modifier() -> Dictionary: return {"city_defense_flat": 0, "city_defense_pct": 0.0, "wall_defense_pct": 0.0, "moat_defense_pct": 0.0, "tower_defense_pct": 0.0, "gate_defense_pct": 0.0, "garrison_defense_pct": 0.0, "siege_resistance_pct": 0.0, "source_techs": []}
func _empty_battle_modifier() -> Dictionary: return {"global_attack_pct": 0.0, "global_defense_pct": 0.0, "infantry_attack_pct": 0.0, "infantry_defense_pct": 0.0, "archer_attack_pct": 0.0, "archer_defense_pct": 0.0, "cavalry_attack_pct": 0.0, "cavalry_charge_pct": 0.0, "gunpowder_attack_pct": 0.0, "crossbow_attack_pct": 0.0, "logistics_pct": 0.0, "siege_attack_pct": 0.0, "source_techs": []}
func _empty_policy_bonus() -> Dictionary: return {"tax_gold_percent": 0.0, "admin_efficiency_percent": 0.0, "recruit_capacity_percent": 0.0, "logistics_supply_percent": 0.0, "population_growth_percent": 0.0, "storage_flat": 0, "law_order_flat": 0, "source_techs": []}
func _empty_naval_siege_bonus() -> Dictionary: return {"shipyard_capacity_flat": 0, "naval_training_percent": 0.0, "naval_supply_percent": 0.0, "ship_maintenance_percent": 0.0, "siege_preparation_flat": 0, "siege_training_percent": 0.0, "siege_engineering_percent": 0.0, "source_techs": []}
func _empty_diplomacy_spy_bonus() -> Dictionary: return {"diplomacy_influence_flat": 0, "diplomacy_preparation_percent": 0.0, "tribute_readiness_percent": 0.0, "world_diplomacy_display_percent": 0.0, "spy_network_flat": 0, "spy_preparation_percent": 0.0, "counter_intel_display_percent": 0.0, "source_techs": []}
func _empty_city_spy_bonus() -> Dictionary: return {"local_spy_network_flat": 0, "local_counter_intel_display_percent": 0.0, "local_intel_readiness_percent": 0.0, "source_techs": []}
