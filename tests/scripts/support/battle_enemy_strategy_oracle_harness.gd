extends "res://tests/scripts/support/battle_tactic_oracle_harness.gd"
# S4-2 oracle. Same rules as S3-1/S4-1: fixture writes prepare the board, every
# observed action runs through the production entry point (the enemy turn the
# controller itself starts, or the ally auto action), no Tween/timer is skipped,
# and the global RNG is seeded right before each action. Works on BASE (no
# S4-2 flags: setting them is a no-op there) and on the new engine.
#
# Enemy strategy scenarios: actor = enemy units[5], target = ally units[0]; the
# other units are far and acted unless the scenario says otherwise.
const STRATEGY_SCENARIOS := [
	"ES01_basic_in_range", "ES02_advanced_in_range", "ES03_master_in_range", "ES04_int79", "ES05_out_of_range",
	"ES06_confused", "ES07_action_lock", "ES08_target_already_shaken", "ES09_plan_attack", "ES10_lethal_first",
	"ES11_skill_first", "ES12_blocked_plan_target_fallback", "ES13_second_actor_skips_afflicted", "ES14_burning_caster_tick",
	"ES15_burn_tick_ends_battle", "ES16_round_complete", "ES17_basic_fail",
]
# S4-2b skill spread scenarios: production enemies guan_yu (units[5], cost 3),
# zhang_fei (units[6], cost 3), xiahou_dun (units[7], cost 2) next to three
# allies; every raw score is high value (268 / 240 / 341 on this board). All
# allies have acted, so the enemy side keeps acting until the round ends.
const SPREAD_SCENARIOS := [
	"SP01_single_candidate", "SP02_yield_one_momentum", "SP03_both_affordable", "SP04_penalty_one_round",
	"SP05_no_history", "SP06_penalty_two_rounds", "SP07_yield_then_blocked",
]
const BATTLE_SEEDS := [1, 2, 3, 4, 5, 6]
const BATTLE_ALLY_ACTIONS := 10
var flags := {} # property -> value, set right after the battle node gets its script

static func strategy_spec(label: String) -> Dictionary:
	# intelligence, actor cell, target cell, forced roll (success, pool index), unit type
	var spec := {"int":86, "actor":Vector2i(12,4), "target":Vector2i(9,4), "success":true, "pool":0, "type":"infantry"}
	match label:
		"ES02_advanced_in_range": spec.merge({"int":92, "target":Vector2i(8,4), "pool":1}, true)
		"ES03_master_in_range": spec.merge({"int":96, "target":Vector2i(7,4), "pool":1}, true) # shake: the ally keeps its turn
		"ES12_blocked_plan_target_fallback": spec.int = 96
		"ES04_int79": spec.int = 79
		"ES05_out_of_range": spec.target = Vector2i(8,4)
		"ES06_confused", "ES07_action_lock": spec.int = 96
		"ES09_plan_attack": spec.merge({"int":96, "actor":Vector2i(9,4), "target":Vector2i(8,4)}, true)
		"ES10_lethal_first": spec.merge({"int":96, "actor":Vector2i(9,4), "target":Vector2i(8,4)}, true)
		"ES11_skill_first": spec.merge({"int":96, "type":"cavalry", "actor":Vector2i(9,4), "target":Vector2i(8,4)}, true)
		"ES13_second_actor_skips_afflicted": spec.merge({"int":96, "pool":1}, true)
		"ES17_basic_fail": spec.success = false
	return spec

func _new_battle(tree: SceneTree) -> Node:
	var battle = load("res://scenes/battle/Battle_Main.tscn").instantiate()
	battle.set_script(battle_script if battle_script != null else SeamBattle)
	for key in flags: battle.set(key, flags[key])
	tree.root.add_child(battle)
	await tree.process_frame
	battle.call("_skip_battle_intro_camera_zoom")
	return battle

func logs4(battle: Node) -> Dictionary:
	return {"ally_move_event_log":export_log(battle, "ally_move_event_log"), "battle_action_event_log":export_log(battle, "battle_action_event_log"),
		"enemy_action_event_log":export_log(battle, "enemy_action_event_log"), "tactic_event_log":export_log(battle, "tactic_event_log"),
		"battle_log_lines":battle.get("battle_log_lines").duplicate()}

func settle_enemy(tree: SceneTree, battle: Node, label: String) -> void:
	var stable := 0
	for frame in range(3000):
		await tree.process_frame
		var ended: bool = battle.call("_get_battle_result_state") != ""
		# An ended battle counts as settled even if the engine leaves its animation flag on (BASE behavior).
		stable = stable + 1 if ended or (not battle.get("is_demo_animating") and not battle.get("is_unique_skill_presenting") and battle.get("current_phase") == "ally_turn") else 0
		if stable >= 30: return
	expect(false, label + " settled within 3000 frames")

func run_strategy_scenario(tree: SceneTree, label: String) -> Dictionary:
	var battle: Node = await _new_battle(tree)
	var units: Array[BattleUnitState] = battle.get("all_battle_unit_states")
	expect(units.size() == 10, label + " ten production units")
	var spec := strategy_spec(label)
	var far_allies := [Vector2i(0,9), Vector2i(1,9), Vector2i(2,9), Vector2i(3,9)]
	var far_enemies := [Vector2i(17,0), Vector2i(16,0), Vector2i(15,0), Vector2i(14,0)]
	for i in range(1,5): _setup_unit(units[i], "infantry", far_allies[i-1])
	for i in range(6,10): _setup_unit(units[i], "infantry", far_enemies[i-6])
	var target := units[0]
	var actor := units[5]
	var actor_skill: Dictionary = actor.unique_skill_definition.duplicate(true)
	_setup_unit(target, "infantry", spec.target)
	_setup_unit(actor, spec.type, spec.actor)
	actor.intelligence = spec.int
	target.intelligence = 70
	var lock = battle.get("action_lock_state_service")
	var momentum = battle.get("battle_momentum")
	match label:
		"ES06_confused": actor.apply_status_effect("confusion", 2, 0)
		"ES07_action_lock": actor.apply_status_effect("action_lock", 1, 1)
		"ES08_target_already_shaken": target.apply_status_effect("shake", 2, 0)
		"ES10_lethal_first":
			target.current_hp = 5
			target.current_troops = 5
		"ES11_skill_first":
			actor.unique_skill_definition = actor_skill
			momentum.gain("enemy", 5, "fixture")
		"ES12_blocked_plan_target_fallback":
			# The plan's own target (nearest) already carries a pool status; a second
			# ally is in strategy range: the existing target selection picks it.
			target.apply_status_effect("shake", 2, 0)
			_setup_unit(units[1], "infantry", Vector2i(11,7))
		"ES13_second_actor_skips_afflicted":
			_setup_unit(units[6], "infantry", Vector2i(12,6))
			units[6].intelligence = 86
		"ES14_burning_caster_tick": actor.apply_status_effect("burn", 2, 12)
		"ES15_burn_tick_ends_battle":
			actor.apply_status_effect("burn", 2, 12)
			actor.current_hp = 3
			actor.current_troops = 3
			for i in range(6,10): _kill_for_fixture(units[i])
	for i in range(6,10):
		if units[i].is_alive() and not (label == "ES13_second_actor_skips_afflicted" and i == 6): lock.register_unit_acted(units[i], "enemy")
	for i in range(1,5):
		if units[i].is_alive(): lock.register_unit_acted(units[i], "ally")
	if label in ["ES13_second_actor_skips_afflicted", "ES16_round_complete"]: lock.register_unit_acted(target, "ally") # allies exhausted: the enemy side keeps acting
	_sync(battle, units)
	if label == "ES15_burn_tick_ends_battle": battle.call("_cleanup_dead_units")
	if not label in ["ES13_second_actor_skips_afflicted", "ES16_round_complete"]: battle.call("_select_ally_unit", target, false, false, false)
	battle.set("strategy_roll_override", forced_roll(spec.success, spec.pool))
	await tree.process_frame
	var samples: Array = [snapshot(battle, "start")]
	seed(ACTION_SEED)
	battle.call("_set_phase", "enemy_turn")
	battle.call("_play_enemy_turn_demo")
	samples.append(snapshot(battle, "enemy_turn_requested"))
	await settle_enemy(tree, battle, label)
	samples.append(snapshot(battle, "settled"))
	var result := {"case":label, "checkpoints":samples, "logs_end":logs4(battle)}
	result["_ids"] = {"actor":actor.unit_id, "target":target.unit_id, "second":units[6].unit_id, "ally2":units[1].unit_id}
	if post_hook.is_valid(): result["_post"] = post_hook.call(battle, actor)
	await _teardown(tree, battle)
	return result

static func forced_roll(success: bool, pool: int) -> Callable:
	return func(kind: String, _value): return success if kind == "success" else pool

func _ally_idle(battle: Node) -> bool:
	return battle.get("current_phase") == "ally_turn" and not battle.get("is_demo_animating") and not battle.get("is_unique_skill_presenting")

func run_battle(tree: SceneTree, seed_value: int) -> Dictionary:
	# Untouched default battle; BATTLE_ALLY_ACTIONS ally actions through the
	# engine's own auto action (wait when it cannot act), each followed by the
	# enemy slots the engine runs.
	var battle: Node = await _new_battle(tree)
	var label := "BATTLE_seed_%d" % seed_value
	for i in range(600):
		if _ally_idle(battle): break
		await tree.process_frame
	var samples: Array = [snapshot(battle, "start")]
	seed(seed_value)
	var actions := 0
	while actions < BATTLE_ALLY_ACTIONS and battle.call("_get_battle_result_state") == "":
		var active = battle.get("active_unit_state")
		if active == null or active.side != "ally": break
		battle.call("_select_ally_unit", active, false, false, false)
		var before: int = export_log(battle, "ally_move_event_log").size() + export_log(battle, "battle_action_event_log").size() + export_log(battle, "tactic_event_log").size()
		battle.call("_run_auto_action_for_active_ally_once")
		var after: int = export_log(battle, "ally_move_event_log").size() + export_log(battle, "battle_action_event_log").size() + export_log(battle, "tactic_event_log").size()
		if _ally_idle(battle) and after == before and not battle.call("_has_ally_unit_acted", active):
			battle.call("_end_ally_turn_by_wait")
		actions += 1
		await settle_enemy(tree, battle, label + " action " + str(actions))
		samples.append(snapshot(battle, "action_%d" % actions))
	var result := {"case":label, "checkpoints":samples, "logs_end":logs4(battle)}
	if post_hook.is_valid(): result["_post"] = post_hook.call(battle, null)
	await _teardown(tree, battle)
	return result

static func spread_spec(label: String) -> Dictionary:
	# unacted enemy indices, enemy momentum, battle round, last-use history {index: round}, blocked index
	var spec := {"unacted":[5, 7], "momentum":4, "round":1, "history":{}, "blocked":-1}
	match label:
		"SP01_single_candidate": spec.merge({"unacted":[5], "momentum":3}, true)
		"SP03_both_affordable": spec.momentum = 5
		"SP04_penalty_one_round": spec.merge({"unacted":[5, 6], "momentum":5, "round":3, "history":{5:2}}, true)
		"SP05_no_history": spec.merge({"unacted":[5, 6], "momentum":5, "round":3}, true)
		"SP06_penalty_two_rounds": spec.merge({"unacted":[5, 6], "momentum":5, "round":3, "history":{5:1}}, true)
		"SP07_yield_then_blocked": spec.blocked = 7
	return spec

func run_spread_scenario(tree: SceneTree, label: String) -> Dictionary:
	var battle: Node = await _new_battle(tree)
	var units: Array[BattleUnitState] = battle.get("all_battle_unit_states")
	expect(units.size() == 10, label + " ten production units")
	var spec := spread_spec(label)
	var skills := {}
	for i in [5, 6, 7]: skills[i] = units[i].unique_skill_definition.duplicate(true)
	var cells := {0:Vector2i(8,4), 1:Vector2i(8,5), 2:Vector2i(8,3), 3:Vector2i(0,9), 4:Vector2i(1,9), 5:Vector2i(9,4), 6:Vector2i(9,5), 7:Vector2i(9,3), 8:Vector2i(17,0), 9:Vector2i(16,0)}
	for i in cells: _setup_unit(units[i], "infantry", cells[i])
	for i in [5, 6, 7]: units[i].unique_skill_definition = skills[i]
	var momentum = battle.get("battle_momentum")
	momentum.spend("enemy", momentum.get_value("enemy"), "fixture")
	momentum.gain("enemy", spec.momentum, "fixture")
	battle.set("battle_round", spec.round)
	var history := {}
	for i in spec.history: history[units[i].unit_id] = spec.history[i]
	battle.set("enemy_skill_last_use_round", history) # S4-2b fixture; no-op on BASE
	if spec.blocked >= 0: battle.set("skill_block_unit_id", units[spec.blocked].unit_id)
	var lock = battle.get("action_lock_state_service")
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
