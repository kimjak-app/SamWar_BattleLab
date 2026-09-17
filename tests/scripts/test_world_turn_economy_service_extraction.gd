extends SceneTree

const EconomyScript := preload("res://scripts/worldmap/turn/world_turn_economy_service.gd")

var _checks := 0
var _failures := 0


func _initialize() -> void:
	var economy := EconomyScript.new()
	var city := {
		"resource_seed": {"rice": 4, "barley": 3, "seafood": 2},
		"population_rating": 4,
		"commerce_rating": 2,
	}
	_expect(economy.calculate_city_income(city, {"season": "spring"}, 30) == {"rice": 0, "barley": 15, "seafood": 4, "gold": 18}, "spring income and tax parity")
	_expect(economy.calculate_city_income(city, {"season": "autumn"}, 30) == {"rice": 20, "barley": 0, "seafood": 4, "gold": 18}, "autumn income parity")
	_expect(economy.calculate_city_income(city, {"season": "winter"}, 30).get("seafood") == 4, "seafood every-turn income")
	_expect(economy.calculate_city_gold_tax_income(city, 0) == 9 and economy.calculate_city_gold_tax_income(city, 100) == 36, "tax multiplier bounds")
	var supplied_effect := {}
	economy.apply_supply_income_effect(supplied_effect, {"income_multiplier": EconomyScript.SUPPLY_INCOME_BONUS})
	_expect(is_equal_approx(float(supplied_effect.get("gold_multiplier", 0.0)), 1.10), "supply income bonus")
	var isolated_effect := {"rice_multiplier": 1.2}
	economy.apply_supply_income_effect(isolated_effect, {"income_multiplier": EconomyScript.SUPPLY_INCOME_PENALTY})
	_expect(is_equal_approx(float(isolated_effect.get("rice_multiplier", 0.0)), 0.96), "supply income penalty composition")
	var upkeep := economy.calculate_hero_upkeep_delta(2, {"rice": 8, "seafood": 3, "silk": 1}, {"hero_upkeep_multiplier": 1.0}, {"hero_upkeep_multiplier": 1.0}, {"supplied_frontline_count": 2})
	_expect(upkeep == {"rice": -15, "seafood": -5, "silk": -1}, "upkeep supplied-frontline discount and floor rounding")
	var capped_upkeep := economy.calculate_hero_upkeep_delta(10, {"rice": 8}, {"hero_upkeep_multiplier": 1.0}, {"hero_upkeep_multiplier": 1.0}, {"supplied_frontline_count": 20})
	_expect(capped_upkeep == {"rice": -68}, "upkeep discount floor")
	_expect(economy.apply_chancellor_policy({"rice": 100, "barley": 100, "seafood": 100, "gold": 100}, {"rice_multiplier": 1.15, "gold_multiplier": 0.95}) == {"rice": 115, "barley": 100, "seafood": 100, "gold": 95}, "chancellor policy multiplier")
	_expect(economy.calculate_chancellor_national_effects({"chancellor_primary_type": "economic", "chancellor_primary_aptitude": 4}).get("gold_multiplier") == 1.12, "chancellor aptitude effect")
	print("[WORLD_TURN_ECONOMY_SERVICE] %s: %d checks, %d failures" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	quit(0 if _failures == 0 else 1)


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("[WORLD_TURN_ECONOMY_SERVICE_FAIL] %s" % label)
