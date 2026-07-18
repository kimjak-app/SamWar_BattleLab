class_name BattleSupplyRuntime
extends RefCounted

var sides: Dictionary = {}
var settled_turns: Dictionary = {}


func configure(context: Dictionary) -> void:
	sides = {
		"attacker": _build_side(context, "attacker"),
		"defender": _build_side(context, "defender"),
	}
	settled_turns.clear()


func _build_side(context: Dictionary, side: String) -> Dictionary:
	return {
		"food_type": str(context.get("%s_food_type" % side, "rice")),
		"food": maxi(0, int(context.get("%s_food_amount" % side, 0))),
		"salt": maxi(0, int(context.get("%s_salt_amount" % side, 0))),
		"gold": maxi(0, int(context.get("%s_carried_gold" % side, 0))),
		"deserters": 0,
	}


func settle_turn(battle_turn: int, living_by_side: Dictionary, healthy_by_side: Dictionary) -> Dictionary:
	var safe_turn := clampi(battle_turn, 1, ExpeditionSupplyCalculator.BATTLE_MAX_TURNS)
	if settled_turns.has(safe_turn):
		return {"applied": false, "turn": safe_turn, "sides": {}}
	settled_turns[safe_turn] = true
	var result := {"applied": true, "turn": safe_turn, "sides": {}}
	for side in ["attacker", "defender"]:
		var state: Dictionary = sides.get(side, {}).duplicate(true)
		var living := maxi(0, int(living_by_side.get(side, 0)))
		var healthy := maxi(0, int(healthy_by_side.get(side, living)))
		var salt_need := ExpeditionSupplyCalculator.salt_per_turn(living)
		var has_salt := salt_need <= 0 or int(state.get("salt", 0)) >= salt_need
		var salt_used := salt_need if has_salt else 0
		state["salt"] = maxi(0, int(state.get("salt", 0)) - salt_used)
		var food_need := ExpeditionSupplyCalculator.food_per_turn(living, has_salt)
		var food_used := mini(int(state.get("food", 0)), food_need)
		state["food"] = maxi(0, int(state.get("food", 0)) - food_used)
		var deserters := 0
		if food_used < food_need:
			deserters = int(ceil(float(healthy) * ExpeditionSupplyCalculator.FOOD_ZERO_DESERTION_RATE))
		state["deserters"] = int(state.get("deserters", 0)) + deserters
		sides[side] = state
		(result["sides"] as Dictionary)[side] = {
			"food_used": food_used,
			"food_needed": food_need,
			"salt_used": salt_used,
			"salt_needed": salt_need,
			"salt_shortage": not has_salt,
			"deserters": deserters,
			"food_remaining": int(state.get("food", 0)),
			"salt_remaining": int(state.get("salt", 0)),
		}
	return result


func snapshot() -> Dictionary:
	return sides.duplicate(true)

