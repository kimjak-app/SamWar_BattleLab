extends SceneTree
# S3-1 event meaning: order, counts and values of `enemy_action_event_log`
# against the engine state the same run produced (and the BASE golden).
const GOLDEN := "res://tests/golden/battle_enemy_turn_baseline_v0.json"
const ENEMY_KINDS := ["enemy_turn_started", "enemy_actor_selected", "enemy_moved", "enemy_attack_resolved", "enemy_waited", "enemy_action_completed", "enemy_skill_used", "round_started", "battle_ended"]
const ATTACK := ["enemy_turn_started", "enemy_actor_selected", "enemy_attack_resolved", "enemy_action_completed"]
const APPROACH := ["enemy_turn_started", "enemy_actor_selected", "enemy_moved", "enemy_attack_resolved", "enemy_action_completed"]
const WAITED := ["enemy_turn_started", "enemy_actor_selected", "enemy_waited", "enemy_action_completed"]
const EXPECTED := {
	"E1_infantry_attack":ATTACK, "E2_infantry_approach":APPROACH, "E3_cavalry_attack":ATTACK, "E4_cavalry_approach":APPROACH,
	"E5_archer_attack":ATTACK, "E6_archer_approach":APPROACH, "E7_gunner_attack":ATTACK, "E8_gunner_approach":APPROACH,
	"E9_mounted_archer_attack":ATTACK, "E10_mounted_archer_approach":APPROACH, "E11_lethal_target":ATTACK,
	"E12_wait":WAITED, "E13_confused":WAITED, "E14_no_path":WAITED, "E18_path_blocked":WAITED, "E19_no_target":WAITED,
	"E15_round_complete":["enemy_turn_started", "enemy_actor_selected", "enemy_attack_resolved", "enemy_action_completed", "round_started"],
	# The end guard returns before `_mark_enemy_unit_acted`: no completion event.
	"E16_ally_wipe_defeat":["enemy_turn_started", "enemy_actor_selected", "enemy_attack_resolved", "battle_ended"],
	"E17_enemy_wipe_victory":["battle_ended"],
	"E20_enemy_unique_skill":["enemy_turn_started", "enemy_actor_selected", "enemy_skill_used", "enemy_action_completed"],
}
const WAIT_REASON := {"E12_wait":"wait", "E13_confused":"confused", "E14_no_path":"no_path", "E18_path_blocked":"path_blocked", "E19_no_target":"no_target"}

func _initialize() -> void:
	_run.call_deferred()

func unit(point: Dictionary, unit_id: String) -> Dictionary:
	for item in point.units:
		if item.unit_id == unit_id: return item
	return {}

func cell(value: Variant) -> Array:
	return [int(value[0]), int(value[1])]

func _post(battle: Node, actor: BattleUnitState) -> Dictionary:
	var log = battle.get("enemy_action_event_log")
	var before: Array = log.export()
	# Mutating an export must not reach the log.
	var exported: Array = log.export()
	if not exported.is_empty():
		exported[0]["kind"] = "tampered"
		exported[0]["injected"] = 1
		exported.append({"kind":"forged"})
	var unchanged: bool = log.export() == before
	# A repeated mark for an already-acted enemy records nothing new (only
	# meaningful while the actor still holds its lock in this round).
	var repeat_mark_added := -1
	if battle.call("_has_enemy_unit_acted", actor):
		battle.call("_mark_enemy_unit_acted", actor)
		repeat_mark_added = log.export().size() - before.size()
	return {"export_isolated":unchanged, "repeat_mark_added":repeat_mark_added, "hit_samples":battle.get("hit_samples").duplicate(true),
		"move_range":battle.call("_get_effective_move_range", actor)}

func _run() -> void:
	var harness = load("res://tests/scripts/support/battle_enemy_turn_oracle_harness.gd").new()
	harness.tag = "[ENEMY_EVENTS]"
	harness.battle_script = load("res://tests/scripts/support/battle_enemy_event_observer_battle.gd")
	harness.post_hook = _post
	var golden: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(GOLDEN))
	var labels: Array = harness.CASES
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--case="): labels = [arg.trim_prefix("--case=")]
	harness.expect(EXPECTED.size() == harness.CASES.size(), "every oracle case has an expected event order")
	for label in labels:
		harness.expect(EXPECTED.has(label), "known case " + str(label))
		if not EXPECTED.has(label): break
		var r: Dictionary = await harness.run_case(self, label)
		var expected_case: Dictionary = {}
		for item in golden.scenarios:
			if item.case == label: expected_case = item
		var view := {}
		for key in r:
			if not String(key).begins_with("_"): view[key] = r[key]
		harness.expect(harness.fingerprint.diff(view, expected_case).is_empty(), label + " state and ally logs equal BASE golden")
		var events: Array = r._enemy_events
		var kinds := []
		for i in range(events.size()):
			kinds.append(events[i].kind)
			harness.expect(events[i].sequence == i and events[i].schema_version == 0, label + " own sequence " + str(i))
		harness.expect(kinds == EXPECTED[label], label + " event order " + str(kinds))
		var start: Dictionary = r.checkpoints[0]
		var settled: Dictionary = r.checkpoints[-1]
		var actor_id: String = r._actor_id
		var target_id: String = r._target_id
		var a0 := unit(start, actor_id)
		var a1 := unit(settled, actor_id)
		var t0 := unit(start, target_id)
		var t1 := unit(settled, target_id)
		var selected := 0
		var completed := 0
		for event in events:
			match event.kind:
				"enemy_turn_started":
					harness.expect(event.round == start.controller.battle_round, label + " turn round")
				"enemy_actor_selected":
					selected += 1
					harness.expect(event.unit_id == actor_id, label + " selected actor")
				"enemy_action_completed":
					completed += 1
					harness.expect(event.unit_id == actor_id, label + " completed actor")
				"enemy_moved":
					harness.expect(event.unit_id == actor_id, label + " moved actor")
					harness.expect(cell(event.path[0]) == cell(a0.grid_cell) and cell(event.from) == cell(a0.grid_cell), label + " path starts at pre-move cell")
					harness.expect(cell(event.path[-1]) == cell(a1.grid_cell) and cell(event.to) == cell(a1.grid_cell), label + " path ends at final grid_cell")
					harness.expect(event.path.size() >= 2 and event.path.size() <= int(r._post.move_range) + 1, label + " path length <= move_range+1")
					for i in range(1, event.path.size()):
						harness.expect(absi(event.path[i][0] - event.path[i-1][0]) + absi(event.path[i][1] - event.path[i-1][1]) == 1, label + " orthogonal step " + str(i))
				"enemy_attack_resolved":
					harness.expect(event.attacker_id == actor_id and event.target_id == target_id, label + " attack ids")
					harness.expect(int(t0.current_troops) - int(event.target_troops_after) == int(event.damage_applied), label + " damage_applied equals troop loss")
					harness.expect(int(event.target_troops_after) == int(t1.current_troops), label + " troops after equals engine")
					harness.expect(int(event.raw_damage) >= int(event.damage_applied) and int(event.damage_applied) > 0, label + " raw >= applied > 0")
					harness.expect(event.angle_type == "front", label + " front angle in fixture layout")
					var dead: bool = int(t1.current_hp) <= 0 or int(t1.current_troops) <= 0
					harness.expect(event.killed == dead and event.killed == settled.controller.dead_unit_ids.has(target_id), label + " killed matches engine death")
				"enemy_waited":
					harness.expect(event.unit_id == actor_id and event.reason == WAIT_REASON.get(label, ""), label + " wait reason")
				"enemy_skill_used":
					harness.expect(event.unit_id == actor_id and event.skill_id == "guan_yu_unique" and event.target_id == target_id, label + " skill fields")
				"round_started":
					harness.expect(event.round == settled.controller.battle_round and event.round == start.controller.battle_round + 1, label + " new round number")
				"battle_ended":
					harness.expect(event.result_state == settled.controller.battle_result_state, label + " result state")
		var terminal: bool = label in ["E16_ally_wipe_defeat", "E17_enemy_wipe_victory"]
		harness.expect(selected == (0 if label == "E17_enemy_wipe_victory" else 1), label + " one actor selection")
		harness.expect(completed == (0 if terminal else 1), label + " one completion per action")
		harness.expect(kinds.count("battle_ended") == (1 if terminal else 0), label + " battle end recorded once")
		# Same tick: the defeat event from the shared cleanup exists when the hit callback returns.
		var defeated_end := []
		for event in r.ally_logs_end.battle_action_event_log:
			if event.kind == "unit_defeated": defeated_end.append(event.unit_id)
		var defeated_start := []
		for event in r.ally_logs_start.battle_action_event_log:
			if event.kind == "unit_defeated": defeated_start.append(event.unit_id)
		if kinds.has("enemy_attack_resolved"):
			var samples: Array = r._post.hit_samples
			harness.expect(samples.size() == 1, label + " one enemy hit callback")
			var killed: bool = events[kinds.find("enemy_attack_resolved")].killed
			if samples.size() == 1:
				harness.expect(samples[0].attacks.size() == 1, label + " attack event recorded inside the hit callback")
				harness.expect(samples[0].unit_defeated.count(target_id) - defeated_start.count(target_id) == (1 if killed else 0), label + " unit_defeated in the same tick iff killed")
			harness.expect(defeated_end.count(target_id) == (1 if killed else 0), label + " no duplicate unit_defeated")
		harness.expect(r._post.export_isolated, label + " export is a deep copy")
		if not terminal and label != "E15_round_complete":
			harness.expect(r._post.repeat_mark_added == 0, label + " repeated mark adds no event")
		# Independence: enemy kinds never enter the ally logs.
		for name in ["battle_action_event_log", "ally_move_event_log"]:
			for event in r.ally_logs_end[name]:
				harness.expect(not ENEMY_KINDS.has(event.kind), label + " " + name + " free of enemy kinds")
		print("[ENEMY_EVENT_CASE] ", label, " events=", kinds.size(), " failures=", harness.failures.size())
	print("[ENEMY_EVENTS] checks=", harness.checks, " failures=", harness.failures)
	var code := 0 if harness.failures.is_empty() else 1
	harness = null
	await process_frame
	quit(code)
