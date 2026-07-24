class_name T03AutoBattleResolver
extends RefCounted

const BattleSupplyRuntimeScript := preload("res://scripts/t02/battle_supply_runtime.gd")
const ExpeditionSupplyCalculatorScript := preload("res://scripts/t02/expedition_supply_calculator.gd")

const MAX_ROUNDS := 30
const BASE_DAMAGE_RATE := 0.10
const DAMAGE_RATIO_MIN := 0.55
const DAMAGE_RATIO_MAX := 1.45
const HERO_MODIFIER_MIN := 0.90
const HERO_MODIFIER_MAX := 1.10
const MATCHUP_CAP := 0.05
const SKILL_CAP := 0.05
const RANDOM_CAP := 0.05


static func build_force_allocation(heroes: Array, healthy_troops: int, leave_garrison: int = 1) -> Dictionary:
	var deployable := maxi(0, healthy_troops - maxi(0, leave_garrison))
	var allocation := {}
	if deployable <= 0:
		return allocation
	for hero_variant in heroes:
		if not hero_variant is Dictionary:
			continue
		var hero := hero_variant as Dictionary
		var hero_id := str(hero.get("hero_id", hero.get("id", "")))
		if hero_id.is_empty() or allocation.has(hero_id):
			continue
		var command_limit := maxi(0, int(hero.get("command_limit", hero.get("max_troops", 5000))))
		var assigned := mini(command_limit, deployable)
		if assigned <= 0:
			continue
		allocation[hero_id] = assigned
		deployable -= assigned
		if deployable <= 0:
			break
	return allocation


static func resolve(context: Dictionary) -> Dictionary:
	var transaction_id := str(context.get("transaction_id", "t03-unidentified"))
	var attacker_initial := maxi(0, int(context.get("attacker_total_allocated_troops", context.get("attacker_troops", 0))))
	var defender_initial := maxi(0, int(context.get("defender_total_allocated_troops", context.get("defender_troops", 0))))
	var healthy := {"attacker": attacker_initial, "defender": defender_initial}
	var supply := BattleSupplyRuntimeScript.new()
	supply.configure(context)
	var completed_round := 0
	var winner := "defender"
	var result_reason := "turn_limit"
	var damage_rate := clampf(float(context.get("automatic_damage_rate", BASE_DAMAGE_RATE)), 0.0, 0.25)
	var round_log: Array[Dictionary] = []
	for battle_round in range(1, MAX_ROUNDS + 1):
		completed_round = battle_round
		var before := healthy.duplicate(true)
		var supply_result: Dictionary = supply.settle_turn(battle_round, before, before)
		for side in ["attacker", "defender"]:
			var side_supply: Dictionary = (supply_result.get("sides", {}) as Dictionary).get(side, {})
			healthy[side] = maxi(0, int(healthy.get(side, 0)) - maxi(0, int(side_supply.get("deserters", 0))))
		if int(healthy.get("attacker", 0)) <= 0 or int(healthy.get("defender", 0)) <= 0:
			winner = "attacker" if int(healthy.get("defender", 0)) <= 0 and int(healthy.get("attacker", 0)) > 0 else "defender"
			result_reason = "supply_elimination"
			round_log.append(_round_entry(battle_round, before, healthy, supply_result, 0, 0))
			break
		var attacker_power := _combat_power(context, "attacker", int(healthy.get("attacker", 0)), battle_round, transaction_id)
		var defender_power := _combat_power(context, "defender", int(healthy.get("defender", 0)), battle_round, transaction_id)
		var attacker_damage := _damage(int(healthy.get("attacker", 0)), attacker_power, defender_power, damage_rate)
		var defender_damage := _damage(int(healthy.get("defender", 0)), defender_power, attacker_power, damage_rate)
		healthy["defender"] = maxi(0, int(healthy.get("defender", 0)) - attacker_damage)
		healthy["attacker"] = maxi(0, int(healthy.get("attacker", 0)) - defender_damage)
		round_log.append(_round_entry(battle_round, before, healthy, supply_result, attacker_damage, defender_damage))
		if int(healthy.get("attacker", 0)) <= 0 or int(healthy.get("defender", 0)) <= 0:
			winner = "attacker" if int(healthy.get("defender", 0)) <= 0 and int(healthy.get("attacker", 0)) > 0 else "defender"
			result_reason = "combat_elimination"
			break
		if battle_round == MAX_ROUNDS:
			winner = "defender"
			result_reason = "turn_limit"

	var supply_state: Dictionary = supply.snapshot()
	var attacker_supply: Dictionary = supply_state.get("attacker", {})
	var defender_supply: Dictionary = supply_state.get("defender", {})
	var attacker_split := ExpeditionSupplyCalculatorScript.split_combat_losses(attacker_initial, int(healthy.get("attacker", 0)), int(attacker_supply.get("deserters", 0)))
	var defender_split := ExpeditionSupplyCalculatorScript.split_combat_losses(defender_initial, int(healthy.get("defender", 0)), int(defender_supply.get("deserters", 0)))
	var attacker_generals := _hero_ids(context.get("attacker_general_ids", context.get("attacker_hero_ids", [])))
	var defender_generals := _hero_ids(context.get("defender_general_ids", context.get("defender_hero_ids", [])))
	return {
		"source": "enemy_invasion",
		"type": "defense_result",
		"resolution_mode": "automatic",
		"transaction_id": transaction_id,
		"result_id": "%s-result" % transaction_id,
		"winner": winner,
		"winner_side": winner,
		"result": "victory" if winner == "defender" else "defeat",
		"result_reason": result_reason,
		"completed_turn": completed_round,
		"attacker_city_id": str(context.get("attacker_city_id", "")),
		"attacker_source_city_id": str(context.get("attacker_source_city_id", context.get("attacker_city_id", ""))),
		"defender_city_id": str(context.get("defender_city_id", "")),
		"defender_source_city_id": str(context.get("defender_source_city_id", context.get("defender_city_id", ""))),
		"attacker_owner": str(context.get("attacker_owner", context.get("attacker_faction_id", ""))),
		"defender_owner": str(context.get("defender_owner", context.get("defender_faction_id", ""))),
		"player_side": str(context.get("player_side", "")),
		"attacker_total_allocated_troops": attacker_initial,
		"defender_total_allocated_troops": defender_initial,
		"attacker_healthy_survivors": int(attacker_split.get("healthy", 0)),
		"attacker_wounded": int(attacker_split.get("wounded", 0)),
		"attacker_dead": int(attacker_split.get("dead", 0)),
		"attacker_deserters": int(attacker_split.get("deserters", 0)),
		"defender_healthy_survivors": int(defender_split.get("healthy", 0)),
		"defender_wounded": int(defender_split.get("wounded", 0)),
		"defender_dead": int(defender_split.get("dead", 0)),
		"defender_deserters": int(defender_split.get("deserters", 0)),
		"attacker_remaining_gold": maxi(0, int(attacker_supply.get("gold", 0))),
		"attacker_remaining_food_type": str(attacker_supply.get("food_type", "rice")),
		"attacker_remaining_food": maxi(0, int(attacker_supply.get("food", 0))),
		"attacker_remaining_food_stock": (attacker_supply.get("food_stock", {}) as Dictionary).duplicate(true),
		"attacker_remaining_salt": maxi(0, int(attacker_supply.get("salt", 0))),
		"defender_remaining_gold": maxi(0, int(defender_supply.get("gold", 0))),
		"defender_remaining_food_type": str(defender_supply.get("food_type", "rice")),
		"defender_remaining_food": maxi(0, int(defender_supply.get("food", 0))),
		"defender_remaining_food_stock": (defender_supply.get("food_stock", {}) as Dictionary).duplicate(true),
		"defender_remaining_salt": maxi(0, int(defender_supply.get("salt", 0))),
		"attacker_general_ids": attacker_generals,
		"defender_general_ids": defender_generals,
		"attacker_surviving_general_ids": attacker_generals if int(attacker_split.get("healthy", 0)) > 0 else [],
		"defender_surviving_general_ids": defender_generals if int(defender_split.get("healthy", 0)) > 0 else [],
		"round_log": round_log,
	}


static func _combat_power(context: Dictionary, side: String, troops: int, battle_round: int, transaction_id: String) -> float:
	var heroes: Array = context.get("%s_heroes" % side, [])
	var hero_modifier := _hero_modifier(heroes, side)
	var matchup := _matchup_modifier(context, side)
	var skill := _skill_modifier(heroes)
	var random_swing := _stable_random_swing(transaction_id, side, battle_round)
	var defense_bonus := clampf(float(context.get("defender_auto_defense_bonus", 0.0)), 0.0, 0.15) if side == "defender" else 0.0
	return float(maxi(0, troops)) * maxf(0.10, hero_modifier + matchup + skill + random_swing + defense_bonus)


static func _hero_modifier(heroes: Array, side: String) -> float:
	if heroes.is_empty():
		return 1.0
	var total := 0.0
	var count := 0
	for hero_variant in heroes:
		if not hero_variant is Dictionary:
			continue
		var hero := hero_variant as Dictionary
		var leadership := clampf(float(hero.get("leadership", hero.get("command", 60))), 0.0, 100.0)
		var war := clampf(float(hero.get("war", 60)), 0.0, 100.0)
		var combat_stat := clampf(float(hero.get("attack" if side == "attacker" else "defense", 60)), 0.0, 100.0)
		total += (leadership + war + combat_stat) / 3.0
		count += 1
	if count <= 0:
		return 1.0
	var average := total / float(count)
	return clampf(0.90 + average * 0.002, HERO_MODIFIER_MIN, HERO_MODIFIER_MAX)


static func _skill_modifier(heroes: Array) -> float:
	var skilled := 0
	for hero_variant in heroes:
		if not hero_variant is Dictionary:
			continue
		var hero := hero_variant as Dictionary
		if not str(hero.get("skill_id", hero.get("unique_skill_id", ""))).is_empty():
			skilled += 1
	return minf(SKILL_CAP, float(skilled) * 0.01)


static func _matchup_modifier(context: Dictionary, side: String) -> float:
	var other_side := "defender" if side == "attacker" else "attacker"
	var own_type := _dominant_unit_type(context.get("%s_heroes" % side, []))
	var other_type := _dominant_unit_type(context.get("%s_heroes" % other_side, []))
	if own_type.is_empty() or other_type.is_empty() or own_type == other_type:
		return 0.0
	var wins := {
		"infantry": "cavalry",
		"cavalry": "archer",
		"archer": "infantry",
		"gunpowder": "infantry",
	}
	if str(wins.get(own_type, "")) == other_type:
		return MATCHUP_CAP
	if str(wins.get(other_type, "")) == own_type:
		return -MATCHUP_CAP
	return 0.0


static func _dominant_unit_type(heroes: Array) -> String:
	var totals := {}
	for hero_variant in heroes:
		if not hero_variant is Dictionary:
			continue
		var hero := hero_variant as Dictionary
		var unit_type := str(hero.get("unit_type", "infantry")).to_lower()
		if unit_type == "melee":
			unit_type = "infantry"
		elif unit_type == "ranged":
			unit_type = "archer"
		totals[unit_type] = int(totals.get(unit_type, 0)) + maxi(1, int(hero.get("allocated_troops", hero.get("troops", 1))))
	var selected := ""
	var amount := -1
	for unit_type in totals.keys():
		if int(totals.get(unit_type, 0)) > amount:
			selected = str(unit_type)
			amount = int(totals.get(unit_type, 0))
	return selected


static func _stable_random_swing(transaction_id: String, side: String, battle_round: int) -> float:
	var token := "%s|%s|%d" % [transaction_id, side, battle_round]
	var bucket := absi(token.hash()) % 10001
	return clampf((float(bucket) / 10000.0 - 0.5) * 2.0 * RANDOM_CAP, -RANDOM_CAP, RANDOM_CAP)


static func _damage(source_troops: int, source_power: float, target_power: float, damage_rate: float) -> int:
	if source_troops <= 0 or damage_rate <= 0.0:
		return 0
	var ratio := clampf(source_power / maxf(1.0, target_power), DAMAGE_RATIO_MIN, DAMAGE_RATIO_MAX)
	return maxi(1, int(round(float(source_troops) * damage_rate * ratio)))


static func _round_entry(battle_round: int, before: Dictionary, after: Dictionary, supply_result: Dictionary, attacker_damage: int, defender_damage: int) -> Dictionary:
	return {
		"round": battle_round,
		"before": before.duplicate(true),
		"after": after.duplicate(true),
		"supply": supply_result.duplicate(true),
		"attacker_damage": attacker_damage,
		"defender_damage": defender_damage,
	}


static func _hero_ids(raw_ids: Variant) -> Array[String]:
	var result: Array[String] = []
	if raw_ids is Array:
		for raw_id in raw_ids:
			var hero_id := str(raw_id)
			if not hero_id.is_empty() and not result.has(hero_id):
				result.append(hero_id)
	return result
