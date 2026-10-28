extends "res://tests/scripts/support/battle3d_auto_harness.gd"
# S4-3 harness: the M5-a auto harness (bare engine host with the write spy and
# round-start snapshots) plus the start setup meta, digests for the BASE parity
# golden and small readers for the setup / level / hold tests.
const SETUP_KEY := "samwar_battle_setup"
const ENEMY_IDS := ["guan_yu", "zhang_fei", "xiahou_dun", "enemy_reinforce_01_demo", "enemy_reinforce_02_test_unit"]
const TROOP_FIELDS := ["current_troops", "max_troops", "allocated_troops", "initial_allocated_troops", "current_hp", "max_hp"]

func digest(value: Variant) -> String:
	return JSON.stringify(canonical(value), "", true).sha256_text()

func canonical(value: Variant) -> Variant:
	# Floats as their exact IEEE-754 bits: the text form of a float is rounded by the
	# platform's float-to-text code, which differs between builds (Windows wrote
	# 0.0413429625332356 for 0.04134296253323554992..., Linux 0.0413429625332355).
	match typeof(value):
		TYPE_FLOAT:
			return "f64:" + PackedFloat64Array([value]).to_byte_array().hex_encode()
		TYPE_VECTOR2, TYPE_VECTOR3:
			var parts: Array = []
			for i in range(3 if typeof(value) == TYPE_VECTOR3 else 2): parts.append(canonical(float(value[i])))
			return parts
		TYPE_DICTIONARY:
			var out := {}
			for key in value: out[key] = canonical(value[key])
			return out
		TYPE_ARRAY:
			return value.map(func(item): return canonical(item))
	return value

func open_bare(tree: SceneTree, spy := true) -> Node:
	# T1: the S4-3 tests are engine-only (the BASE golden was recorded without blocked cells) and are not compared with
	# the 3D lab, so the engine opens without the lab's blocked cells: the auto harness's open_bare minus its T1 line.
	var host = AutoHost.new() if spy else Host.new()
	tree.root.add_child(host)
	await host.initialized
	await tree.process_frame
	return host

func open_with_setup(tree: SceneTree, setup: Variant) -> Node:
	# setup == null: no key at all.
	if Engine.has_meta(SETUP_KEY): Engine.remove_meta(SETUP_KEY)
	if setup != null: Engine.set_meta(SETUP_KEY, setup)
	return await open_bare(tree)

func unit_by_id(battle: Node, unit_id: String) -> BattleUnitState:
	for u in battle.get("all_battle_unit_states"):
		if u.unit_id == unit_id: return u
	return null

func troop_fields(unit: BattleUnitState) -> Dictionary:
	var out := {}
	for f in TROOP_FIELDS: out[f] = unit.get(f)
	return out

func start_state(battle: Node) -> Dictionary:
	return {"units":fingerprint.fingerprint_units(battle.get("all_battle_unit_states")), "controller":oracle.controller_state(battle), "logs":logs4(battle),
		"flags":flags(battle), "momentum":[battle.battle_momentum.get_value("ally"), battle.battle_momentum.get_value("enemy")]}

func flags(battle: Node) -> Array:
	return [battle.get("enemy_strategy_enabled"), battle.get("enemy_skill_spread_enabled"), battle.get("enemy_skill_cap_enabled")]

func battle_digest(result: Dictionary) -> Dictionary:
	# Full auto battle digest (no-key BASE parity): every section hashed, plus readable headline values.
	var out := {"units":digest(result.units), "controller":digest(result.controller), "tactic":digest(result.tactic), "round_snaps":digest(result.round_snaps),
		"writes":digest(result.writes), "result":result.controller.battle_result_state, "round":result.controller.battle_round}
	for name in result.logs: out[name] = digest(result.logs[name])
	return out

# Transparent observer (each override calls super once): ignored setup log lines,
# resume persist attempts, enemy turn starts with the flags before/after the
# pending level is applied, auto ticks, and an optional level set at the start of
# the next enemy action (to change the level while an enemy action runs).
class S43Battle extends AutoSpyBattle:
	var ignored_logs: Array = []
	var persist_calls := 0
	var enemy_turns: Array = [] # [round, pending_before, flags_before, flags_after]
	var actions_done: Array = [] # [unit_id, flags at the end of that enemy action]
	var tick_calls := 0
	var set_level_on_enemy_action := ""
	func _log_battle_setup_ignored(reason: String) -> void:
		ignored_logs.append(reason)
		super._log_battle_setup_ignored(reason)
	func _persist_battle_resume_snapshot() -> void:
		persist_calls += 1
		super._persist_battle_resume_snapshot()
	func _play_enemy_ai_turn() -> void:
		var before := [enemy_strategy_enabled, enemy_skill_spread_enabled, enemy_skill_cap_enabled]
		var pending := _pending_enemy_ai_level
		var index := enemy_turns.size()
		enemy_turns.append([battle_round, pending, before, []])
		super._play_enemy_ai_turn()
		enemy_turns[index][3] = [enemy_strategy_enabled, enemy_skill_spread_enabled, enemy_skill_cap_enabled]
	func _play_enemy_ai_for_actor(enemy_actor_state: BattleUnitState) -> void:
		if not set_level_on_enemy_action.is_empty():
			set_enemy_ai_level(set_level_on_enemy_action)
			set_level_on_enemy_action = ""
		super._play_enemy_ai_for_actor(enemy_actor_state)
	func _advance_enemy_turn_or_return_to_ally() -> void:
		actions_done.append([current_enemy_ai_actor_state.unit_id if current_enemy_ai_actor_state != null else "", [enemy_strategy_enabled, enemy_skill_spread_enabled, enemy_skill_cap_enabled]])
		super._advance_enemy_turn_or_return_to_ally()
	func _tick_full_auto_battle_if_needed() -> void:
		tick_calls += 1
		super._tick_full_auto_battle_if_needed()

class S43Host extends Host:
	func create_battle() -> Node:
		var node := super.create_battle()
		node.set_script(S43Battle)
		return node

func open_s43(tree: SceneTree, setup: Variant) -> Node:
	if Engine.has_meta(SETUP_KEY): Engine.remove_meta(SETUP_KEY)
	if setup != null: Engine.set_meta(SETUP_KEY, setup)
	var host = S43Host.new()
	tree.root.add_child(host)
	await host.initialized
	await tree.process_frame
	return host

func settle(tree: SceneTree, battle: Node, max_frames := 3000) -> void:
	for i in range(max_frames):
		await tree.process_frame
		if not battle.get("is_demo_animating") and (battle.get("current_phase") == "ally_turn" or battle.call("_get_battle_result_state") != ""): return

func ally_wait(tree: SceneTree, battle: Node) -> void:
	# One manual ally action (wait): the first available ally waits, then one enemy slot plays.
	var ally: BattleUnitState = battle.call("_get_first_available_ally_unit")
	battle.call("_select_ally_unit", ally, false, false, false)
	await tree.process_frame
	battle.call("_end_ally_turn_by_wait")
	await settle(tree, battle)

func run_auto_with(tree: SceneTree, seed_value: int, setup: Variant, direct_flags: Array, speed := 4.0) -> Dictionary:
	# Full engine auto until the end, with an optional start setup or flags written by the test before the toggle.
	var host = await open_s43(tree, setup)
	var battle: Node = host.battle
	if not direct_flags.is_empty():
		battle.set("enemy_strategy_enabled", direct_flags[0])
		battle.set("enemy_skill_spread_enabled", direct_flags[1])
		battle.set("enemy_skill_cap_enabled", direct_flags[2])
	Engine.time_scale = speed
	seed(seed_value)
	battle.call("_toggle_full_auto_battle")
	for i in range(60000):
		await tree.process_frame
		if battle.call("_get_battle_result_state") != "": break
	for i in range(60): await tree.process_frame
	Engine.time_scale = 1.0
	var result := auto_final(battle)
	result["level"] = [battle.call("get_enemy_ai_level"), battle.call("get_pending_enemy_ai_level")]
	result["flags"] = flags(battle)
	result["enemy_skills"] = battle.get("enemy_action_event_log").export().filter(func(e): return e.kind == "enemy_skill_used").map(func(e): return e.unit_id)
	await close_bare(tree, host)
	return result
