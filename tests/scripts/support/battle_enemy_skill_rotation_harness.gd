extends "res://tests/scripts/support/battle_enemy_strategy_oracle_harness.gd"
# S4-2c rotation scenarios (flags on only; the S4-2 spread golden keeps its
# seven flag-off scenarios unchanged). Same board as the S4-2 spread scenarios:
# guan_yu (units[5], order 0, cost 3), zhang_fei (units[6], order 1, cost 3),
# xiahou_dun (units[7], order 2, cost 2). Layout A: raw 268 / 240 / 341.
# Layout B (wider): raw 268 / 75 / 341 (zhang_fei below the 130 threshold).
const ROTATION_SCENARIOS := [
	"RT01_last_use_tie_raw_decides", "RT02_three_candidates_one_momentum", "RT03_acted_enemy_not_a_candidate",
	"RT04_low_score_not_a_candidate", "RT05_ally_auto_untouched",
]

static func rotation_spec(label: String) -> Dictionary:
	var spec := {"layout":"A", "unacted":[5, 6], "momentum":5, "round":3, "history":{}, "blocked":-1}
	match label:
		"RT01_last_use_tie_raw_decides": spec.history = {5:2, 6:2} # same last use: raw 268 > 240, guan_yu first
		"RT02_three_candidates_one_momentum": spec.merge({"unacted":[5, 6, 7], "momentum":3, "history":{5:2, 7:2}}, true) # zhang_fei never used
		"RT03_acted_enemy_not_a_candidate": spec.merge({"unacted":[5], "momentum":3, "history":{5:2}}, true) # xiahou_dun (never used, 341) has acted
		"RT04_low_score_not_a_candidate": spec.merge({"layout":"B", "momentum":3, "history":{5:2}}, true) # zhang_fei never used but raw 75
	return spec

func run_rotation_scenario(tree: SceneTree, label: String) -> Dictionary:
	var battle: Node = await _new_battle(tree)
	var units: Array[BattleUnitState] = battle.get("all_battle_unit_states")
	var spec := rotation_spec(label)
	var skills := {}
	for i in [0, 5, 6, 7]: skills[i] = units[i].unique_skill_definition.duplicate(true)
	var cells := {0:Vector2i(8,4), 1:Vector2i(8,5), 2:Vector2i(8,3), 3:Vector2i(0,9), 4:Vector2i(1,9), 5:Vector2i(9,4), 6:Vector2i(9,5), 7:Vector2i(9,3), 8:Vector2i(17,0), 9:Vector2i(16,0)}
	if spec.layout == "B": cells.merge({1:Vector2i(8,6), 2:Vector2i(8,2), 5:Vector2i(10,4), 6:Vector2i(9,6), 7:Vector2i(9,2)}, true)
	for i in cells: _setup_unit(units[i], "infantry", cells[i])
	for i in [5, 6, 7]: units[i].unique_skill_definition = skills[i]
	var momentum = battle.get("battle_momentum")
	var lock = battle.get("action_lock_state_service")
	if label == "RT05_ally_auto_untouched":
		# The ally caster (yi_sunsin, enemy_area, cost 4) acts by the engine's own auto action. Every
		# enemy is unacted and never used, and the enemy momentum (2) cannot pay all.
		units[0].unique_skill_definition = skills[0]
		momentum.gain("ally", 10, "fixture")
		momentum.spend("enemy", momentum.get_value("enemy"), "fixture")
		momentum.gain("enemy", 2, "fixture")
		for i in range(1, 5): lock.register_unit_acted(units[i], "ally")
		for i in [8, 9]: lock.register_unit_acted(units[i], "enemy")
		# A fixture last use for the ally: ignored by the enemy-only rule; if the rule leaked to
		# allies, never-used xiahou_dun would rank first and the ally would yield.
		battle.set("enemy_skill_last_use_round", {units[0].unit_id:1})
		_sync(battle, units)
		battle.call("_select_ally_unit", units[0], false, false, false)
		await tree.process_frame
		var samples: Array = [snapshot(battle, "start")]
		seed(ACTION_SEED)
		battle.call("_run_auto_action_for_active_ally_once")
		await settle_enemy(tree, battle, label)
		samples.append(snapshot(battle, "settled"))
		var result := {"case":label, "checkpoints":samples, "logs_end":logs4(battle)}
		result["_ids"] = {"ally":units[0].unit_id, "guan":units[5].unit_id, "zhang":units[6].unit_id, "xiahou":units[7].unit_id}
		if post_hook.is_valid(): result["_post"] = post_hook.call(battle, null)
		await _teardown(tree, battle)
		return result
	momentum.spend("enemy", momentum.get_value("enemy"), "fixture")
	momentum.gain("enemy", spec.momentum, "fixture")
	battle.set("battle_round", spec.round)
	var history := {}
	for i in spec.history: history[units[i].unit_id] = spec.history[i]
	battle.set("enemy_skill_last_use_round", history)
	for i in range(5, 10):
		if not spec.unacted.has(i): lock.register_unit_acted(units[i], "enemy")
	for i in range(0, 5): lock.register_unit_acted(units[i], "ally")
	_sync(battle, units)
	await tree.process_frame
	var samples: Array = [snapshot(battle, "start")]
	seed(ACTION_SEED)
	battle.call("_set_phase", "enemy_turn")
	battle.call("_play_enemy_turn_demo")
	await settle_enemy(tree, battle, label)
	samples.append(snapshot(battle, "settled"))
	var result := {"case":label, "checkpoints":samples, "logs_end":logs4(battle)}
	result["_ids"] = {"guan":units[5].unit_id, "zhang":units[6].unit_id, "xiahou":units[7].unit_id}
	if post_hook.is_valid(): result["_post"] = post_hook.call(battle, null)
	await _teardown(tree, battle)
	return result
