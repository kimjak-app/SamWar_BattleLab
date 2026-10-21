extends "res://tests/scripts/support/battle_enemy_turn_oracle_harness.gd"
# S4-1 tactic oracle. Same rules as the S3-1 oracle: fixture writes prepare
# the board, every observed action runs through the production entry point
# (strategy/skill buttons and target selection, the ally auto action, the
# enemy turn, the ally wait), and no Tween/timer is skipped. The global RNG is
# seeded right before each action so BASE and the new engine draw the same
# numbers. Works on code with or without `tactic_event_log` (BASE has none).
const Resolver = preload("res://scripts/battle/battle_skill_resolver.gd")
const SKILLS_PATH := "res://data/heroes/generated/hero_unique_skills.json"
const ACTION_SEED := 4242
# One skill per effect_type (first in data order), sorted by effect_type.
const SKILL_EFFECT_TYPES := [
	"adjacent_aoe", "ally_focus_buff", "aoe_damage_debuff", "aoe_debuff", "charge_aoe", "charge_damage", "charge_line",
	"command_debuff", "control_field", "encirclement_debuff", "fear_aoe", "fire_aoe", "flank_debuff_attack", "guard_aura",
	"gunner_volley", "line_damage", "mounted_team_buff", "naval_team_buff", "prediction_debuff", "rally_restore",
	"retreat_counter", "single_burst", "single_debuff", "single_ranged_damage", "skill_cost_debuff", "splash_charge",
	"stance_team_buff", "team_action_buff", "team_buff", "team_command", "team_guard", "team_logistics", "team_morale",
	"team_mobility_buff", "team_support", "trap_aoe",
]
const STRATEGY_CASES := [
	"S1_basic_success", "S2_basic_fail", "S3_advanced_success_pool0", "S4_advanced_success_pool1", "S5_advanced_fail",
	"S6_master_success_pool0", "S7_master_success_pool1", "S8_master_fail",
]
# Test-only dice hook installed on the new engine only (BASE has no such member).
var roll_override: Callable = Callable()
const OTHER_CASES := ["T1_burn_shake_tick", "K_ally_auto_skill", "K_enemy_auto_skill", "K_advance_on_kill", "K_commit_failure", "R1_default_reinforcements_round3"]

static func all_cases() -> Array:
	var cases: Array = STRATEGY_CASES.duplicate()
	for effect_type in SKILL_EFFECT_TYPES: cases.append("K_" + effect_type)
	cases.append_array(OTHER_CASES)
	return cases

func skill_for_effect(effect_type: String) -> Dictionary:
	for skill in JSON.parse_string(FileAccess.get_file_as_string(SKILLS_PATH)).skills:
		if skill.effect_type == effect_type: return skill
	return {}

func skill_by_id(skill_id: String) -> Dictionary:
	for skill in JSON.parse_string(FileAccess.get_file_as_string(SKILLS_PATH)).skills:
		if skill.skill_id == skill_id: return skill
	return {}

static func strategy_spec(label: String) -> Dictionary:
	# tier intelligence, wanted success, wanted pool index (target intelligence 70).
	return {
		"S1_basic_success":{"intel":80, "success":true, "pool":0}, "S2_basic_fail":{"intel":80, "success":false, "pool":0},
		"S3_advanced_success_pool0":{"intel":90, "success":true, "pool":0}, "S4_advanced_success_pool1":{"intel":90, "success":true, "pool":1},
		"S5_advanced_fail":{"intel":90, "success":false, "pool":0}, "S6_master_success_pool0":{"intel":95, "success":true, "pool":0},
		"S7_master_success_pool1":{"intel":95, "success":true, "pool":1}, "S8_master_fail":{"intel":95, "success":false, "pool":0},
	}[label]

static func find_strategy_seed(rate: float, success: bool, pool_index: int, pool_size: int) -> int:
	# Pure RNG search: the first seed whose randf()/randi() draws give the wanted outcome.
	for n in range(1, 100000):
		seed(n)
		var hit := randf() <= rate
		if hit != success: continue
		if not success or randi() % pool_size == pool_index: return n
	return -1

func _board(battle: Node, units: Array[BattleUnitState], caster_cell := Vector2i(8,4)) -> void:
	# caster = ally units[0]; ally units[1] adjacent; enemies units[5..7] near; the rest far.
	var far := {2:Vector2i(0,9), 3:Vector2i(1,9), 4:Vector2i(2,9), 8:Vector2i(17,0), 9:Vector2i(16,0)}
	for i in far: _setup_unit(units[i], "infantry", far[i])
	_setup_unit(units[0], "infantry", caster_cell)
	_setup_unit(units[1], "infantry", Vector2i(7,4))
	_setup_unit(units[5], "infantry", Vector2i(9,4))
	_setup_unit(units[6], "infantry", Vector2i(10,4))
	_setup_unit(units[7], "infantry", Vector2i(9,5))
	var lock = battle.get("action_lock_state_service")
	# Only the caster (ally) and enemy units[5] are unacted.
	for i in [6, 7, 8, 9]:
		if units[i].is_alive(): lock.register_unit_acted(units[i], "enemy")
	for i in [1, 2, 3, 4]:
		if units[i].is_alive(): lock.register_unit_acted(units[i], "ally")

func _sync(battle: Node, units: Array[BattleUnitState]) -> void:
	for u in units: battle.call("_sync_resumed_unit_markers_to_grid", u)
	battle.call("_sync_demo_positions")

func settled_now(battle: Node) -> bool:
	if battle.get("is_demo_animating") or battle.get("is_unique_skill_presenting"): return false
	return battle.get("current_phase") == "ally_turn" or battle.call("_get_battle_result_state") != ""

func settle(tree: SceneTree, battle: Node, label: String, seconds := 30.0) -> bool:
	var stable := 0
	var deadline := Time.get_ticks_msec() + int(seconds * 1000.0)
	while Time.get_ticks_msec() < deadline:
		await tree.process_frame
		stable = stable + 1 if settled_now(battle) else 0
		if stable >= 30: return true
	expect(false, label + " settled within %ds" % int(seconds))
	return false

func run_case(tree: SceneTree, label: String) -> Dictionary:
	var battle = load("res://scenes/battle/Battle_Main.tscn").instantiate()
	battle.set_script(battle_script if battle_script != null else SeamBattle)
	tree.root.add_child(battle)
	if roll_override.is_valid(): battle.set("strategy_roll_override", roll_override)
	await tree.process_frame
	battle.call("_skip_battle_intro_camera_zoom")
	var units: Array[BattleUnitState] = battle.get("all_battle_unit_states")
	expect(units.size() == 10, label + " ten production units")
	var spec := {"case_seed":ACTION_SEED}
	var momentum = battle.get("battle_momentum")
	if label.begins_with("S"):
		_board(battle, units, Vector2i(8,4))
		_setup_unit(units[5], "infantry", Vector2i(10,4))
		var s := strategy_spec(label)
		units[0].intelligence = s.intel
		units[5].intelligence = 70
		var pool_size: int = battle.call("_get_strategy_outcome_pool", units[0]).size()
		var rate: float = battle.call("_get_strategy_success_rate", units[0], units[5])
		spec = {"intel":s.intel, "rate":rate, "pool_size":pool_size, "want_success":s.success, "want_pool":s.pool,
			"case_seed":find_strategy_seed(rate, s.success, s.pool, pool_size)}
		expect(spec.case_seed > 0, label + " seed found")
	elif label == "T1_burn_shake_tick":
		_board(battle, units, Vector2i(4,4))
		_setup_unit(units[5], "infantry", Vector2i(14,4))
		_setup_unit(units[6], "infantry", Vector2i(15,6))
		_setup_unit(units[7], "infantry", Vector2i(15,7))
		units[0].apply_status_effect("burn", 2, 12)
		units[0].apply_status_effect("shake", 1, 0)
		units[5].apply_status_effect("burn", 1, 0)
	elif label.begins_with("K_"):
		_board(battle, units)
		momentum.gain("ally", 10, "fixture")
		momentum.gain("enemy", 3, "fixture")
		var skill := {}
		match label:
			"K_ally_auto_skill": skill = skill_for_effect("aoe_damage_debuff")
			"K_advance_on_kill":
				skill = skill_by_id("cheok_jun_gyeong_unique")
				units[5].current_hp = 5
				units[5].current_troops = 5
			"K_commit_failure": skill = skill_for_effect("charge_damage")
			"K_enemy_auto_skill": pass
			_: skill = skill_for_effect(label.trim_prefix("K_"))
		if label == "K_retreat_counter":
			_setup_unit(units[1], "infantry", Vector2i(7,5)) # free the retreat cell behind the caster
		if label == "K_rally_restore":
			units[0].apply_status_effect("burn", 2, 8)
			units[1].apply_status_effect("defense_down", 2, 10)
		if label == "K_enemy_auto_skill":
			# Production enemy keeps its own skill (guan_yu line_damage); the ally side has acted.
			battle.get("action_lock_state_service").register_unit_acted(units[0], "ally")
			momentum.gain("enemy", 5, "fixture")
			units[5].unique_skill_definition = skill_by_id("guan_yu_unique")
		else:
			expect(not skill.is_empty(), label + " skill found")
			units[0].unique_skill_definition = skill
			spec["skill_id"] = skill.get("skill_id", "")
	_sync(battle, units)
	if label not in ["K_enemy_auto_skill", "R1_default_reinforcements_round3"]:
		battle.call("_select_ally_unit", units[0], false, false, false)
	await tree.process_frame
	var samples: Array = [snapshot(battle, "start")]
	seed(spec.case_seed)
	await _act(tree, battle, units, label)
	samples.append(snapshot(battle, "acted"))
	if label != "R1_default_reinforcements_round3": await settle(tree, battle, label)
	samples.append(snapshot(battle, "settled"))
	var result := {"case":label, "spec":spec, "checkpoints":samples,
		"logs_end":{"battle_action_event_log":export_log(battle, "battle_action_event_log"), "ally_move_event_log":export_log(battle, "ally_move_event_log"),
			"enemy_action_event_log":export_log(battle, "enemy_action_event_log")}}
	# Not part of the golden: absent on the pre-recording BASE.
	result["_tactic_events"] = export_log(battle, "tactic_event_log")
	result["_unit_ids"] = units.map(func(u): return u.unit_id)
	if post_hook.is_valid(): result["_post"] = post_hook.call(battle, units[0])
	await _teardown(tree, battle)
	return result

func _act(tree: SceneTree, battle: Node, units: Array[BattleUnitState], label: String) -> void:
	if label.begins_with("S"):
		battle.call("_on_strategy_button_pressed")
		expect(battle.get("current_phase") == "strategy", label + " strategy target select")
		battle.call("_try_use_strategy_on_target", units[5])
		return
	match label:
		"T1_burn_shake_tick":
			battle.call("_end_ally_turn_by_wait")
		"R1_default_reinforcements_round3":
			for step in range(12):
				if battle.get("battle_round") >= 3 or battle.call("_get_battle_result_state") != "": break
				var active = battle.get("active_unit_state")
				if active == null or active.side != "ally": break
				battle.call("_select_ally_unit", active, false, false, false)
				battle.call("_end_ally_turn_by_wait")
				await settle(tree, battle, label + " step " + str(step))
			expect(battle.get("battle_round") == 3, label + " reached round 3")
		"K_ally_auto_skill":
			battle.call("_run_auto_action_for_active_ally_once")
		"K_enemy_auto_skill":
			battle.call("_set_phase", "enemy_turn")
			battle.call("_play_enemy_turn_demo")
		"K_commit_failure":
			battle.call("_on_unique_skill_button_pressed")
			var momentum = battle.get("battle_momentum")
			momentum.spend("ally", momentum.get_value("ally"), "fixture_drain") # fixture: commit-time spend fails
			battle.call("_try_use_unique_skill_on_target", units[5])
		_:
			battle.call("_on_unique_skill_button_pressed")
			expect(battle.get("current_phase") == "unique_skill_target_select", label + " skill target select")
			var skill: Dictionary = battle.call("_get_unique_skill_for_unit", units[0])
			if not battle.call("_should_unique_skill_resolve_without_manual_target", skill):
				var target = battle.call("_get_best_unique_skill_target_for_actor", units[0], skill)
				expect(target != null, label + " a valid manual target")
				battle.call("_try_use_unique_skill_on_target", target)
