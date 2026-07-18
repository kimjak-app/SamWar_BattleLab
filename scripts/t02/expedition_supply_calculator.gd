class_name ExpeditionSupplyCalculator
extends RefCounted

const FOOD_TYPES: Array[String] = ["rice", "barley", "seafood"]
const FOOD_PER_100_TROOPS_PER_BATTLE_TURN := 1
const SALT_PER_500_TROOPS_PER_BATTLE_TURN := 1
const FOOD_ZERO_DESERTION_RATE := 0.10
const NO_SALT_FOOD_CONSUMPTION_MULTIPLIER := 1.10
const GOLD_PER_100_TROOPS := 20
const BATTLE_MAX_TURNS := 30
const COMBAT_CASUALTY_WOUNDED_RATE := 0.50
const COMBAT_CASUALTY_DEAD_RATE := 0.50
const NORMAL_WOUNDED_RECOVERY_MONTHS := 3
const FAST_WOUNDED_RECOVERY_MONTHS := 1
const SALT_PER_100_WOUNDED_FOR_FAST_RECOVERY := 1


static func food_per_turn(living_troops: int, has_sufficient_salt: bool = true) -> int:
	var base := int(ceil(float(maxi(0, living_troops)) / 100.0)) * FOOD_PER_100_TROOPS_PER_BATTLE_TURN
	if base <= 0 or has_sufficient_salt:
		return base
	return int(ceil(float(base) * NO_SALT_FOOD_CONSUMPTION_MULTIPLIER))


static func salt_per_turn(living_troops: int) -> int:
	return int(ceil(float(maxi(0, living_troops)) / 500.0)) * SALT_PER_500_TROOPS_PER_BATTLE_TURN


static func minimum_gold(troops: int) -> int:
	return int(ceil(float(maxi(0, troops)) / 100.0)) * GOLD_PER_100_TROOPS


static func minimum_food(troops: int) -> int:
	return food_per_turn(troops, false)


static func max_troops_by_gold(gold: int) -> int:
	return maxi(0, int(floor(float(maxi(0, gold)) / float(GOLD_PER_100_TROOPS))) * 100)


static func max_troops_by_one_turn_food(food: int) -> int:
	# The no-salt path is the worst legal first-turn case.
	var safe_food := maxi(0, food)
	var supported_hundreds := int(floor(float(safe_food) / NO_SALT_FOOD_CONSUMPTION_MULTIPLIER))
	return maxi(0, supported_hundreds * 100)


static func deployment_limits(healthy_troops: int, gold: int, food: int, other_limit: int = 2147483647) -> Dictionary:
	var by_garrison := maxi(0, healthy_troops)
	var by_gold := max_troops_by_gold(gold)
	var by_food := max_troops_by_one_turn_food(food)
	return {
		"garrison": by_garrison,
		"gold": by_gold,
		"food": by_food,
		"maximum": mini(mini(by_garrison, by_gold), mini(by_food, maxi(0, other_limit))),
	}


static func predict_supply(troops: int, food: int, salt: int, max_turns: int = BATTLE_MAX_TURNS) -> Dictionary:
	var food_left := maxi(0, food)
	var salt_left := maxi(0, salt)
	var sustained_turns := 0
	var per_turn: Array[Dictionary] = []
	for battle_turn in range(1, mini(BATTLE_MAX_TURNS, maxi(0, max_turns)) + 1):
		var salt_need := salt_per_turn(troops)
		var has_salt := salt_need <= 0 or salt_left >= salt_need
		var food_need := food_per_turn(troops, has_salt)
		if food_left < food_need:
			break
		if has_salt:
			salt_left -= salt_need
		food_left -= food_need
		sustained_turns = battle_turn
		per_turn.append({"turn": battle_turn, "food_used": food_need, "salt_used": salt_need if has_salt else 0})
	return {
		"sustained_turns": sustained_turns,
		"food_remaining": food_left,
		"salt_remaining": salt_left,
		"reaches_turn_limit": sustained_turns >= mini(BATTLE_MAX_TURNS, maxi(0, max_turns)),
		"turns": per_turn,
	}


static func split_combat_losses(initial_troops: int, healthy_survivors: int, deserters: int = 0) -> Dictionary:
	var initial := maxi(0, initial_troops)
	var healthy := clampi(healthy_survivors, 0, initial)
	var deserted := clampi(deserters, 0, initial - healthy)
	var combat_losses := maxi(0, initial - healthy - deserted)
	var wounded := int(floor(float(combat_losses) * COMBAT_CASUALTY_WOUNDED_RATE))
	var dead := combat_losses - wounded
	return {"healthy": healthy, "wounded": wounded, "dead": dead, "deserters": deserted}


static func fast_recovery_salt(wounded: int) -> int:
	return int(ceil(float(maxi(0, wounded)) / 100.0)) * SALT_PER_100_WOUNDED_FOR_FAST_RECOVERY
