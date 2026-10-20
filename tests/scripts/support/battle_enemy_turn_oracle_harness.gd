extends RefCounted
# S3-1 enemy-turn oracle. Fixture preparation writes state; every observed
# enemy action runs through the production entry point the controller itself
# uses after an ally slot (`_play_enemy_turn_demo`) or, for the enemy-wipe case,
# through the real ally attack request. No Tween/timer is skipped or completed
# by the harness. Works on code with or without `enemy_action_event_log`.
const Fingerprint = preload("res://scripts/battle/services/battle_state_fingerprint_service.gd")
const UnitTypeContractScript = preload("res://scripts/battle/unit_type_contract.gd")
const CASES := [
	"E1_infantry_attack", "E2_infantry_approach", "E3_cavalry_attack", "E4_cavalry_approach",
	"E5_archer_attack", "E6_archer_approach", "E7_gunner_attack", "E8_gunner_approach",
	"E9_mounted_archer_attack", "E10_mounted_archer_approach", "E11_lethal_target", "E12_wait",
	"E13_confused", "E14_no_path", "E15_round_complete", "E16_ally_wipe_defeat", "E17_enemy_wipe_victory",
	"E18_path_blocked", "E19_no_target", "E20_enemy_unique_skill",
]
# Test-only seams for defensive controller branches that the current movement
# rules do not reach on their own (the AI plans with the same path search the
# mover uses). Each seam replaces one query result; the branch body, the
# logs, the action lock and the turn advance all run as production code.
class SeamBattle extends "res://scripts/battle/presentation/iso/battle_iso_production_controller.gd":
	var seam := ""
	var seam_unit_id := ""
	func _find_enemy_move_path_for_actor(enemy_actor_state: BattleUnitState, start_cell: Vector2i, target_cell: Vector2i) -> Array[Vector2i]:
		if seam == "no_path" and enemy_actor_state != null and enemy_actor_state.unit_id == seam_unit_id:
			var empty: Array[Vector2i] = []
			return empty
		return super._find_enemy_move_path_for_actor(enemy_actor_state, start_cell, target_cell)
	func _is_path_clear_for_unit(path: Array[Vector2i], mover_state: BattleUnitState, should_log: bool = false) -> bool:
		if seam == "path_blocked" and should_log and mover_state != null and mover_state.unit_id == seam_unit_id:
			return false
		return super._is_path_clear_for_unit(path, mover_state, should_log)
	func _get_enemy_ai_decision_plan_for_actor(enemy_actor_state: BattleUnitState, preferred_target_override: BattleUnitState = null) -> Dictionary:
		var plan := super._get_enemy_ai_decision_plan_for_actor(enemy_actor_state, preferred_target_override)
		if seam == "no_target" and enemy_actor_state != null and enemy_actor_state.unit_id == seam_unit_id:
			plan["final_target_state"] = null
		return plan

# Optional observer hooks for the event-semantics test; the oracle leaves them unset.
var battle_script: Script = null
var post_hook: Callable = Callable()
var fingerprint := Fingerprint.new()
var failures: Array[String] = []
var checks := 0
var tag := "[ENEMY_TURN_ORACLE]"

func expect(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures.append(label)
		printerr(tag, " FAIL ", label)

func controller_state(battle: Node) -> Dictionary:
	var active = battle.get("active_unit_state")
	var lock = battle.get("action_lock_state_service")
	return {
		"current_phase":battle.get("current_phase"), "is_demo_animating":battle.get("is_demo_animating"),
		"ally_has_moved":battle.get("ally_has_moved"), "has_pending_move_snapshot":battle.get("has_pending_move_snapshot"),
		"active_unit_id":active.unit_id if active != null else "", "battle_round":battle.get("battle_round"),
		"ally_momentum":battle.get("battle_momentum").get_value("ally"), "enemy_momentum":battle.get("battle_momentum").get_value("enemy"),
		"acted_ally_ids":lock.export_acted_ids("ally"), "acted_enemy_ids":lock.export_acted_ids("enemy"),
		"dead_unit_ids":battle.get("dead_unit_ids").duplicate(true),
		"battle_result_state":battle.call("_get_battle_result_state"),
	}

func snapshot(battle: Node, label: String) -> Dictionary:
	return {"stage":label, "units":fingerprint.fingerprint_units(battle.get("all_battle_unit_states")), "controller":controller_state(battle)}

func export_log(battle: Node, property: String) -> Array:
	var log = battle.get(property)
	return [] if log == null else log.export()

func _setup_unit(u: BattleUnitState, unit_type: String, cell: Vector2i) -> void:
	u.set_grid_cell(cell)
	u.reset_action_flags()
	u.unit_type = unit_type
	u.move_range = UnitTypeContractScript.get_move_range(unit_type)
	u.current_hp = 300
	u.max_hp = 300
	u.current_troops = 300
	u.max_troops = 300
	u.allocated_troops = 300
	u.initial_allocated_troops = 300
	u.unique_skill_definition = {}
	u.status_effects = {}
	u.is_defending = false

func _kill_for_fixture(u: BattleUnitState) -> void:
	u.current_hp = 0
	u.current_troops = 0

func case_spec(label: String) -> Dictionary:
	# actor = enemy units[5], target = ally units[0]
	var spec := {"type":"infantry", "actor":Vector2i(9,4), "target":Vector2i(8,4)}
	match label:
		"E2_infantry_approach": spec.actor = Vector2i(12,4)
		"E3_cavalry_attack": spec.type = "cavalry"
		"E4_cavalry_approach": spec = {"type":"cavalry", "actor":Vector2i(13,4), "target":Vector2i(8,4)}
		"E5_archer_attack": spec = {"type":"archer", "actor":Vector2i(11,4), "target":Vector2i(8,4)}
		"E6_archer_approach": spec = {"type":"archer", "actor":Vector2i(14,4), "target":Vector2i(8,4)}
		"E7_gunner_attack": spec = {"type":"gunner", "actor":Vector2i(11,4), "target":Vector2i(8,4)}
		"E8_gunner_approach": spec = {"type":"gunner", "actor":Vector2i(13,4), "target":Vector2i(8,4)}
		"E9_mounted_archer_attack": spec = {"type":"mounted_archer", "actor":Vector2i(10,4), "target":Vector2i(8,4)}
		"E10_mounted_archer_approach": spec = {"type":"mounted_archer", "actor":Vector2i(14,4), "target":Vector2i(8,4)}
		"E12_wait": spec = {"type":"infantry", "actor":Vector2i(12,4), "target":Vector2i(6,4)}
		"E14_no_path", "E18_path_blocked", "E19_no_target": spec.actor = Vector2i(12,4)
		"E20_enemy_unique_skill": spec.type = "cavalry"
	return spec

func run_case(tree: SceneTree, label: String) -> Dictionary:
	var packed = load("res://scenes/battle/Battle_Main.tscn")
	var battle = packed.instantiate()
	battle.set_script(battle_script if battle_script != null else SeamBattle)
	tree.root.add_child(battle)
	await tree.process_frame
	battle.call("_skip_battle_intro_camera_zoom")
	var units: Array[BattleUnitState] = battle.get("all_battle_unit_states")
	expect(units.size() == 10, label + " ten production units")
	var spec := case_spec(label)
	var far_allies := [Vector2i(0,9), Vector2i(1,9), Vector2i(2,9), Vector2i(3,9)]
	var far_enemies := [Vector2i(17,0), Vector2i(16,0), Vector2i(15,0), Vector2i(14,0)]
	for i in range(1,5): _setup_unit(units[i], "infantry", far_allies[i-1])
	for i in range(6,10): _setup_unit(units[i], "infantry", far_enemies[i-6])
	var target := units[0]
	var actor := units[5]
	var actor_skill: Dictionary = actor.unique_skill_definition.duplicate(true)
	_setup_unit(target, "infantry", spec.target)
	_setup_unit(actor, spec.type, spec.actor)
	if label == "E20_enemy_unique_skill":
		# The production enemy keeps its own unique skill with enough momentum.
		actor.unique_skill_definition = actor_skill
		battle.get("battle_momentum").gain("enemy", 5, "fixture")
	if label == "E12_wait":
		# Effective move range 0 (movement_down on a 1-move fixture): no
		# reachable engagement cell, so the AI plan keeps the current cell.
		actor.move_range = 1
		actor.apply_status_effect("movement_down", 2, 0)
	if label in ["E14_no_path", "E18_path_blocked", "E19_no_target"]:
		battle.seam = label.split("_", true, 1)[1]
		battle.seam_unit_id = actor.unit_id
	var lock = battle.get("action_lock_state_service")
	if label == "E11_lethal_target":
		target.current_hp = 5
		target.current_troops = 5
	if label == "E13_confused":
		actor.apply_status_effect("confusion", 2, 0)
	if label == "E16_ally_wipe_defeat":
		target.current_hp = 5
		target.current_troops = 5
		for i in range(1,5): _kill_for_fixture(units[i])
	if label == "E17_enemy_wipe_victory":
		actor.current_hp = 5
		actor.current_troops = 5
		for i in range(6,10): _kill_for_fixture(units[i])
	# Only the actor is unacted on the enemy side; one ally stays unacted so the
	# slot returns to the ally turn, except for the round-complete case.
	for i in range(6,10):
		if units[i].is_alive(): lock.register_unit_acted(units[i], "enemy")
	for i in range(1,5):
		# E11 keeps one far ally unacted: a lethal hit alone must not complete the round.
		if units[i].is_alive() and not (label == "E11_lethal_target" and i == 1): lock.register_unit_acted(units[i], "ally")
	if label == "E15_round_complete":
		lock.register_unit_acted(target, "ally")
	for u in units: battle.call("_sync_resumed_unit_markers_to_grid", u)
	battle.call("_sync_demo_positions")
	if label in ["E16_ally_wipe_defeat", "E17_enemy_wipe_victory"]:
		battle.call("_cleanup_dead_units")
	if label != "E15_round_complete":
		battle.call("_select_ally_unit", target, false, false, false)
	await tree.process_frame
	var samples: Array = [snapshot(battle, "start")]
	var start_ally_logs := {"battle_action_event_log":export_log(battle,"battle_action_event_log"), "ally_move_event_log":export_log(battle,"ally_move_event_log")}
	if label == "E17_enemy_wipe_victory":
		# Real ally attack kills the last enemy; the engine then runs its normal
		# post-attack flow (end guard instead of an enemy slot).
		actor.set_grid_cell(Vector2i(9,4))
		battle.call("_sync_resumed_unit_markers_to_grid", actor)
		battle.call("_sync_demo_positions")
		battle.call("try_basic_attack")
		battle.call("_try_attack_enemy_target_from_attack_select", actor)
	else:
		battle.call("_set_phase", "enemy_turn")
		battle.call("_play_enemy_turn_demo")
	samples.append(snapshot(battle, "enemy_turn_requested"))
	var settled := false
	var stable_frames := 0
	for frame in range(2400):
		await tree.process_frame
		var phase: String = battle.get("current_phase")
		var animating: bool = battle.get("is_demo_animating")
		var ended: bool = battle.call("_get_battle_result_state") != ""
		if not animating and (phase == "ally_turn" or ended):
			stable_frames += 1
			if stable_frames >= 30:
				settled = true
				break
		else:
			stable_frames = 0
	expect(settled, label + " enemy slot settled within 2400 frames")
	samples.append(snapshot(battle, "settled"))
	var result := {"case":label, "spec":{"type":spec.type, "actor":[spec.actor.x, spec.actor.y], "target":[spec.target.x, spec.target.y]},
		"checkpoints":samples,
		"ally_logs_start":start_ally_logs,
		"ally_logs_end":{"battle_action_event_log":export_log(battle,"battle_action_event_log"), "ally_move_event_log":export_log(battle,"ally_move_event_log")}}
	var enemy_events := export_log(battle, "enemy_action_event_log")
	# Not part of the golden: absent on the pre-recording BASE.
	result["_enemy_events"] = enemy_events
	result["_actor_id"] = actor.unit_id
	result["_target_id"] = target.unit_id
	if post_hook.is_valid(): result["_post"] = post_hook.call(battle, actor)
	await _teardown(tree, battle)
	return result

func _teardown(tree: SceneTree, battle: Node) -> void:
	for i in range(10): await tree.process_frame
	await tree.create_timer(.1).timeout
	var projection = battle.get("_iso_grid_controller")
	battle.seam = ""
	battle.free()
	if is_instance_valid(projection) and projection.get_parent() == null: projection.free()
	var audio = tree.root.get_node_or_null("GameAudio")
	if audio:
		for voice in audio.get_children():
			if voice is AudioStreamPlayer:
				voice.stop()
				voice.stream = null
