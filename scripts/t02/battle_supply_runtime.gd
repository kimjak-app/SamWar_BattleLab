class_name BattleSupplyRuntime
extends RefCounted

const FOOD_TYPES: Array[String] = ["rice", "barley", "seafood"]

var sides: Dictionary = {}
var settled_turns: Dictionary = {}


func configure(context: Dictionary) -> void:
	sides = {
		"attacker": _build_side(context, "attacker"),
		"defender": _build_side(context, "defender"),
	}
	settled_turns.clear()


func _build_side(context: Dictionary, side: String) -> Dictionary:
	var legacy_food_type := str(context.get("%s_food_type" % side, "rice"))
	if not FOOD_TYPES.has(legacy_food_type):
		legacy_food_type = "rice"
	var food_stock := _normalize_food_stock(context.get("%s_food_stock" % side, {}))
	if _food_total(food_stock) <= 0:
		food_stock[legacy_food_type] = maxi(0, int(context.get("%s_food_amount" % side, 0)))
	var selected_food_type := _select_food_type(food_stock)
	return {
		"food_type": selected_food_type,
		"food": _food_total(food_stock),
		"food_stock": food_stock,
		"salt": maxi(0, int(context.get("%s_salt_amount" % side, 0))),
		"gold": maxi(0, int(context.get("%s_carried_gold" % side, 0))),
		"deserters": 0,
	}


func _normalize_food_stock(raw_stock: Variant) -> Dictionary:
	var stock := {"rice": 0, "barley": 0, "seafood": 0}
	if raw_stock is Dictionary:
		for food_type in FOOD_TYPES:
			stock[food_type] = maxi(0, int((raw_stock as Dictionary).get(food_type, 0)))
	return stock


func _food_total(food_stock: Dictionary) -> int:
	var total := 0
	for food_type in FOOD_TYPES:
		total += maxi(0, int(food_stock.get(food_type, 0)))
	return total


func _select_food_type(food_stock: Dictionary) -> String:
	var selected := FOOD_TYPES[0]
	var selected_amount := -1
	for food_type in FOOD_TYPES:
		var amount := maxi(0, int(food_stock.get(food_type, 0)))
		if amount > selected_amount:
			selected = food_type
			selected_amount = amount
	return selected


func _consume_food(food_stock: Dictionary, requested: int) -> Dictionary:
	var stock := _normalize_food_stock(food_stock)
	var need_left := maxi(0, requested)
	var used_by_type := {"rice": 0, "barley": 0, "seafood": 0}
	while need_left > 0 and _food_total(stock) > 0:
		var food_type := _select_food_type(stock)
		var available := maxi(0, int(stock.get(food_type, 0)))
		if available <= 0:
			break
		var used := mini(available, need_left)
		stock[food_type] = available - used
		used_by_type[food_type] = int(used_by_type.get(food_type, 0)) + used
		need_left -= used
	return {
		"food_stock": stock,
		"food_used": maxi(0, requested) - need_left,
		"food_used_by_type": used_by_type,
		"food_type": _select_food_type(stock),
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
		var consumption := _consume_food(state.get("food_stock", {}), food_need)
		var food_used := int(consumption.get("food_used", 0))
		state["food_stock"] = (consumption.get("food_stock", {}) as Dictionary).duplicate(true)
		state["food_type"] = str(consumption.get("food_type", "rice"))
		state["food"] = _food_total(state.get("food_stock", {}))
		var deserters := 0
		if food_used < food_need:
			deserters = int(ceil(float(healthy) * ExpeditionSupplyCalculator.FOOD_ZERO_DESERTION_RATE))
		state["deserters"] = int(state.get("deserters", 0)) + deserters
		sides[side] = state
		(result["sides"] as Dictionary)[side] = {
			"food_used": food_used,
			"food_used_by_type": (consumption.get("food_used_by_type", {}) as Dictionary).duplicate(true),
			"food_needed": food_need,
			"salt_used": salt_used,
			"salt_needed": salt_need,
			"salt_shortage": not has_salt,
			"deserters": deserters,
			"food_remaining": int(state.get("food", 0)),
			"food_stock_remaining": (state.get("food_stock", {}) as Dictionary).duplicate(true),
			"selected_food_type": str(state.get("food_type", "rice")),
			"salt_remaining": int(state.get("salt", 0)),
		}
	return result


func snapshot() -> Dictionary:
	return sides.duplicate(true)
