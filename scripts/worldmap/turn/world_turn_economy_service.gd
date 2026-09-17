class_name WorldTurnEconomyService
extends RefCounted


const INCOME_RULES := {
	"seafood_per_rating_per_turn": 2,
	"barley_per_rating_in_spring": 5,
	"rice_per_rating_in_autumn": 5,
}
const POPULATION_TAX_POINT_PER_RATING := 3
const COMMERCE_TAX_POINT_PER_RATING := 3
const TAX_POINT_TO_GOLD := 1
const CHANCELLOR_PRIMARY_RATE := 0.03
const CHANCELLOR_SECONDARY_RATE := 0.015
const SUPPLY_INCOME_BONUS := 1.10
const SUPPLY_INCOME_PENALTY := 0.80
const SUPPLY_UPKEEP_DISCOUNT_PER_CITY := 0.03
const SUPPLY_UPKEEP_DISCOUNT_FLOOR := 0.85


func empty_income_totals() -> Dictionary:
	return {"rice": 0, "barley": 0, "seafood": 0, "gold": 0}


func normalize_tax_level(value: Variant) -> int:
	return clampi(int(round(float(value))), 0, 100)


func get_tax_gold_multiplier(tax_level: int) -> float:
	var normalized_tax := normalize_tax_level(tax_level)
	if normalized_tax <= 30:
		return 0.5 + (float(normalized_tax) / 30.0) * 0.5
	return 1.0 + (float(normalized_tax - 30) / 70.0)


func calculate_city_income(city_data: Dictionary, calendar: Dictionary, tax_level: int, city_effects: Dictionary = {}) -> Dictionary:
	var resource_seed: Dictionary = city_data.get("resource_seed", {})
	var income := empty_income_totals()
	income["seafood"] = _get_rating(resource_seed, "seafood") * int(INCOME_RULES.get("seafood_per_rating_per_turn", 2))
	if str(calendar.get("season", "")) == "spring":
		income["barley"] = _get_rating(resource_seed, "barley") * int(INCOME_RULES.get("barley_per_rating_in_spring", 5))
	if str(calendar.get("season", "")) == "autumn":
		income["rice"] = _get_rating(resource_seed, "rice") * int(INCOME_RULES.get("rice_per_rating_in_autumn", 5))
	income["gold"] = calculate_city_gold_tax_income(city_data, tax_level)
	return apply_income_multipliers(income, city_effects)


func calculate_city_gold_tax_income(city_data: Dictionary, tax_level: int) -> int:
	var population_tax_points := _get_city_numeric_rating(city_data, "population_rating", 3) * POPULATION_TAX_POINT_PER_RATING
	var commerce_tax_points := _get_city_numeric_rating(city_data, "commerce_rating", 0) * COMMERCE_TAX_POINT_PER_RATING
	var taxable_value := (population_tax_points + commerce_tax_points) * TAX_POINT_TO_GOLD
	return maxi(0, int(round(float(taxable_value) * get_tax_gold_multiplier(tax_level))))


func apply_chancellor_policy(totals: Dictionary, policy_data: Dictionary) -> Dictionary:
	var income_multiplier := float(policy_data.get("income_multiplier", 1.0))
	return {
		"rice": maxi(0, int(round(float(totals.get("rice", 0)) * income_multiplier * float(policy_data.get("rice_multiplier", 1.0))))),
		"barley": maxi(0, int(round(float(totals.get("barley", 0)) * income_multiplier * float(policy_data.get("barley_multiplier", 1.0))))),
		"seafood": maxi(0, int(round(float(totals.get("seafood", 0)) * income_multiplier * float(policy_data.get("seafood_multiplier", 1.0))))),
		"gold": maxi(0, int(round(float(totals.get("gold", 0)) * income_multiplier * float(policy_data.get("gold_multiplier", 1.0))))),
	}


func apply_income_multipliers(totals: Dictionary, effect: Dictionary) -> Dictionary:
	return {
		"rice": maxi(0, int(round(float(totals.get("rice", 0)) * float(effect.get("rice_multiplier", 1.0))))),
		"barley": maxi(0, int(round(float(totals.get("barley", 0)) * float(effect.get("barley_multiplier", 1.0))))),
		"seafood": maxi(0, int(round(float(totals.get("seafood", 0)) * float(effect.get("seafood_multiplier", 1.0))))),
		"gold": maxi(0, int(round(float(totals.get("gold", 0)) * float(effect.get("gold_multiplier", 1.0))))),
	}


func apply_supply_income_effect(effect: Dictionary, supply_state: Dictionary) -> void:
	var income_multiplier := float(supply_state.get("income_multiplier", 1.0))
	if is_equal_approx(income_multiplier, 1.0):
		return
	effect["rice_multiplier"] = float(effect.get("rice_multiplier", 1.0)) * income_multiplier
	effect["barley_multiplier"] = float(effect.get("barley_multiplier", 1.0)) * income_multiplier
	effect["seafood_multiplier"] = float(effect.get("seafood_multiplier", 1.0)) * income_multiplier
	effect["gold_multiplier"] = float(effect.get("gold_multiplier", 1.0)) * income_multiplier


func default_chancellor_national_effects() -> Dictionary:
	return {
		"rice_multiplier": 1.0,
		"barley_multiplier": 1.0,
		"seafood_multiplier": 1.0,
		"gold_multiplier": 1.0,
		"hero_upkeep_multiplier": 1.0,
		"soldier_upkeep_preview_multiplier": 1.0,
		"salt_preservation_multiplier": 1.0,
		"national_loyalty_loss_multiplier": 1.0,
	}


func calculate_chancellor_national_effects(hero_data: Dictionary) -> Dictionary:
	var effect := default_chancellor_national_effects()
	if hero_data.is_empty():
		return effect
	apply_chancellor_type_effect(effect, str(hero_data.get("chancellor_primary_type", "")), float(hero_data.get("chancellor_primary_aptitude", 0)), CHANCELLOR_PRIMARY_RATE)
	apply_chancellor_type_effect(effect, str(hero_data.get("chancellor_secondary_type", "")), float(hero_data.get("chancellor_secondary_aptitude", 0)), CHANCELLOR_SECONDARY_RATE)
	return effect


func apply_chancellor_type_effect(effect: Dictionary, type_id: String, aptitude: float, rate: float) -> void:
	var strength := maxf(0.0, aptitude) * rate
	if type_id.is_empty() or strength <= 0.0:
		return
	match type_id:
		"political":
			effect["national_loyalty_loss_multiplier"] = clampf(float(effect.get("national_loyalty_loss_multiplier", 1.0)) * (1.0 - strength), 0.7, 1.0)
		"economic":
			effect["gold_multiplier"] = clampf(float(effect.get("gold_multiplier", 1.0)) * (1.0 + strength), 1.0, 1.22)
		"administrative":
			effect["hero_upkeep_multiplier"] = clampf(float(effect.get("hero_upkeep_multiplier", 1.0)) * (1.0 - (strength * 0.45)), 0.82, 1.0)
			effect["salt_preservation_multiplier"] = clampf(float(effect.get("salt_preservation_multiplier", 1.0)) * (1.0 - (strength * 0.45)), 0.82, 1.0)
		"diplomatic":
			effect["gold_multiplier"] = clampf(float(effect.get("gold_multiplier", 1.0)) * (1.0 + (strength * 0.55)), 1.0, 1.12)
		"militaryAdmin":
			effect["soldier_upkeep_preview_multiplier"] = clampf(float(effect.get("soldier_upkeep_preview_multiplier", 1.0)) * (1.0 - (strength * 0.55)), 0.82, 1.0)


func calculate_hero_upkeep_delta(active_count: int, upkeep_rules: Dictionary, policy_data: Dictionary, national_effects: Dictionary, supply_states: Dictionary = {}) -> Dictionary:
	var supplied_frontline_count := maxi(0, int(supply_states.get("supplied_frontline_count", 0)))
	var supply_upkeep_multiplier := maxf(SUPPLY_UPKEEP_DISCOUNT_FLOOR, 1.0 - (SUPPLY_UPKEEP_DISCOUNT_PER_CITY * float(supplied_frontline_count)))
	var upkeep_multiplier := float(policy_data.get("hero_upkeep_multiplier", 1.0)) * float(national_effects.get("hero_upkeep_multiplier", 1.0)) * supply_upkeep_multiplier
	var delta := {}
	for resource_id in upkeep_rules.keys():
		var base_cost := maxi(0, active_count) * int(upkeep_rules.get(resource_id, 0))
		var adjusted_cost := round_discounted_amount(base_cost, upkeep_multiplier)
		if adjusted_cost > 0:
			delta[str(resource_id)] = -adjusted_cost
	return delta


func round_discounted_amount(amount: int, multiplier: float) -> int:
	var adjusted_amount := float(amount) * multiplier
	if multiplier < 1.0 and adjusted_amount < float(amount):
		return maxi(0, int(floor(adjusted_amount)))
	return maxi(0, int(round(adjusted_amount)))


func _get_rating(source: Dictionary, key: String) -> int:
	return maxi(0, int(source.get(key, 0)))


func _get_city_numeric_rating(city_data: Dictionary, key: String, fallback: int) -> int:
	return clampi(int(city_data.get(key, fallback)), 1, 5)
