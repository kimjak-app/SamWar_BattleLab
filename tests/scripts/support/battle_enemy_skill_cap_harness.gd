extends "res://tests/scripts/support/battle_enemy_skill_rotation_harness.gd"
# S4-2c addendum (use cap) scenarios, flags on only. Board layout A of the S4-2
# spread scenarios: guan_yu (units[5]), zhang_fei (units[6]), xiahou_dun
# (units[7]) next to three allies; every raw score is high value. Counts and the
# side's last use are fixture writes on the new members.
const CAP_SCENARIOS := [
	"CP01_gap_two_capped", "CP02_others_caught_up", "CP03_safety_release", "CP03b_safety_boundary_still_capped",
	"CP04_reinforcement_arrival_caps", "CP05_capped_not_a_rotation_candidate", "CP06_dead_holder_ignored", "CP07_ally_auto_untouched",
	"CP08_flag_off_no_cap",
]

static func cap_spec(label: String) -> Dictionary:
	# actor = the only unacted enemy unless stated; counts by index; last_any relative to the round (3).
	var spec := {"unacted":[7], "counts":{7:2}, "last_any_ago":1, "momentum":10, "spread":false, "dead":[], "deploy_reinforce":false, "cap":true}
	match label:
		"CP02_others_caught_up": spec.counts = {7:2, 5:1, 6:1}
		"CP03_safety_release": spec.last_any_ago = 3
		"CP03b_safety_boundary_still_capped": spec.last_any_ago = 2
		"CP04_reinforcement_arrival_caps": spec.merge({"unacted":[5], "counts":{5:2, 6:2, 7:2}, "deploy_reinforce":true}, true)
		"CP05_capped_not_a_rotation_candidate": spec.merge({"unacted":[5, 7], "counts":{5:1, 7:3}, "momentum":4, "spread":true}, true)
		"CP06_dead_holder_ignored": spec.merge({"counts":{7:2, 5:2}, "dead":[6]}, true)
		"CP08_flag_off_no_cap": spec.cap = false # CP01 counts with the cap flag left false
	return spec

func run_cap_scenario(tree: SceneTree, label: String) -> Dictionary:
	var battle: Node = await _new_battle(tree)
	var units: Array[BattleUnitState] = battle.get("all_battle_unit_states")
	var spec := cap_spec(label)
	battle.set("enemy_skill_cap_enabled", spec.cap)
	battle.set("enemy_skill_spread_enabled", spec.spread)
	var skills := {}
	for i in [0, 5, 6, 7]: skills[i] = units[i].unique_skill_definition.duplicate(true)
	var cells := {0:Vector2i(8,4), 1:Vector2i(8,5), 2:Vector2i(8,3), 3:Vector2i(0,9), 4:Vector2i(1,9), 5:Vector2i(9,4), 6:Vector2i(9,5), 7:Vector2i(9,3), 8:Vector2i(17,0), 9:Vector2i(16,0)}
	for i in cells: _setup_unit(units[i], "infantry", cells[i])
	for i in [5, 6, 7]: units[i].unique_skill_definition = skills[i]
	var momentum = battle.get("battle_momentum")
	var lock = battle.get("action_lock_state_service")
	battle.set("battle_round", 3)
	if label == "CP07_ally_auto_untouched":
		# The ally auto action with a large fixture use count for the ally and zero for the enemies:
		# the enemy-only cap must leave the ally's skill alone.
		units[0].unique_skill_definition = skills[0]
		momentum.gain("ally", 10, "fixture")
		battle.set("enemy_skill_use_count", {units[0].unit_id:5})
		battle.set("enemy_skill_last_any_use_round", 2)
		for i in range(1, 5): lock.register_unit_acted(units[i], "ally")
		for i in [8, 9]: lock.register_unit_acted(units[i], "enemy")
		_sync(battle, units)
		battle.call("_select_ally_unit", units[0], false, false, false)
		await tree.process_frame
		var samples: Array = [snapshot(battle, "start")]
		seed(ACTION_SEED)
		battle.call("_run_auto_action_for_active_ally_once")
		await settle_enemy(tree, battle, label)
		samples.append(snapshot(battle, "settled"))
		var r := {"case":label, "checkpoints":samples, "logs_end":logs4(battle)}
		r["_ids"] = {"ally":units[0].unit_id, "guan":units[5].unit_id, "zhang":units[6].unit_id, "xiahou":units[7].unit_id}
		if post_hook.is_valid(): r["_post"] = post_hook.call(battle, null)
		await _teardown(tree, battle)
		return r
	momentum.spend("enemy", momentum.get_value("enemy"), "fixture")
	momentum.gain("enemy", spec.momentum, "fixture")
	var counts := {}
	for i in spec.counts: counts[units[i].unit_id] = spec.counts[i]
	battle.set("enemy_skill_use_count", counts)
	battle.set("enemy_skill_last_any_use_round", 3 - spec.last_any_ago)
	if spec.spread:
		# Rotation history: xiahou_dun used longer ago than guan_yu (so it would rank first if it were a candidate).
		battle.set("enemy_skill_last_use_round", {units[5].unit_id:2, units[7].unit_id:1})
	for i in spec.dead: _kill_for_fixture(units[i])
	if spec.deploy_reinforce:
		var enemy_reinforce: BattleUnitState = battle.get("enemy_reinforce_01_unit_state")
		enemy_reinforce.unique_skill_definition = skills[6] # a skill holder that arrives with zero uses
		battle.call("_try_deploy_reinforce_01_pair")
	for i in range(5, 10):
		if not spec.unacted.has(i) and units[i].is_alive(): lock.register_unit_acted(units[i], "enemy")
	if spec.deploy_reinforce:
		lock.register_unit_acted(battle.get("enemy_reinforce_01_unit_state"), "enemy")
		lock.register_unit_acted(battle.get("ally_reinforce_01_unit_state"), "ally")
	for i in range(0, 5): lock.register_unit_acted(units[i], "ally")
	_sync(battle, units)
	if not spec.dead.is_empty(): battle.call("_cleanup_dead_units")
	await tree.process_frame
	var samples: Array = [snapshot(battle, "start")]
	seed(ACTION_SEED)
	battle.call("_set_phase", "enemy_turn")
	battle.call("_play_enemy_turn_demo")
	await settle_enemy(tree, battle, label)
	samples.append(snapshot(battle, "settled"))
	var result := {"case":label, "checkpoints":samples, "logs_end":logs4(battle)}
	result["_ids"] = {"guan":units[5].unit_id, "zhang":units[6].unit_id, "xiahou":units[7].unit_id, "reinforce":battle.get("enemy_reinforce_01_unit_state").unit_id}
	if post_hook.is_valid(): result["_post"] = post_hook.call(battle, null)
	await _teardown(tree, battle)
	return result
