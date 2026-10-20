extends "res://tests/scripts/test_battle3d_enemy_turn_equivalence.gd"
# M3-b: an ally slot ended by the engine's wait command, 3D input vs engine
# direct. Reuses every M3 per-case check (40 fields, 12 controller values,
# three logs, playback, hits, summaries) and adds the seven-command contract.
const SEVEN := ["_select_ally_unit", "_try_direct_move_to_cell", "_select_post_move_facing", "_handle_right_click_cancel", "try_basic_attack", "_try_attack_enemy_target_from_attack_select", "_end_ally_turn_by_wait"]

func case_labels() -> Array:
	return load("res://tests/scripts/support/battle3d_wait_harness.gd").WAIT_CASES

func without_wait(state: Dictionary) -> Dictionary:
	var copy := state.duplicate(true)
	copy.writes = copy.writes.filter(func(call): return call != "_end_ally_turn_by_wait")
	return copy

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_wait_harness.gd").new()
	var labels: Array = case_labels()
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--case="): labels = [arg.trim_prefix("--case=")]
	for label in labels:
		var t0 := Time.get_ticks_msec()
		var direct: Dictionary = await h.run_wait_direct(self, label)
		var td: Dictionary = await h.run_wait_3d(self, label)
		h.roles_ids = {"enemy":h.roles(h.lab.engine).enemy.unit_id}
		var defend: int = h.lab.engine.defend_calls
		await h.close_lab(self)
		h.expect(direct.writes == td.writes, label + " same seven-command write sequence " + str(td.writes))
		h.expect(td.writes.count("_end_ally_turn_by_wait") == 1, label + " exactly one wait call (engine-internal reselects are recorded too)")
		for call in td.writes: h.expect(SEVEN.has(call), label + " write within the seven commands " + call)
		h.expect(defend == 0 and not td.writes.has("_on_defend_button_pressed"), label + " defend never called")
		var ally_id: String = td.units[0].unit_id
		h.expect(td.lab.combat_lines.has("대기 · " + ally_id), label + " wait shown in combat log")
		# Wait itself records nothing in the ally logs; only the ally's own move
		# events and the shared death event of an enemy kill may appear.
		var killed_ids := []
		for event in td.logs.enemy_action_event_log:
			if event.kind == "enemy_attack_resolved" and event.killed: killed_ids.append(event.target_id)
		for event in td.logs.ally_move_event_log:
			h.expect(event.kind in ["unit_moved", "facing_changed", "move_confirmed"], label + " wait adds no ally_move event (" + event.kind + ")")
		for event in td.logs.battle_action_event_log:
			h.expect(event.kind == "unit_defeated" and killed_ids.has(event.unit_id), label + " wait adds no battle_action event (" + event.kind + ")")
		check_case(label, without_wait(direct), without_wait(td))
		var kinds := []
		for event in td.logs.enemy_action_event_log: kinds.append(event.kind)
		print("[M3B_WAIT_CASE] ", label, " writes=", td.writes, " enemy_events=", kinds, " round=", td.lab.round, " ms=", Time.get_ticks_msec() - t0, " failures=", h.failures.size())
		if not h.failures.is_empty(): break
	print("[M3B_WAIT_EQUIVALENCE] checks=", h.checks, " failures=", h.failures)
	quit(0 if h.failures.is_empty() else 1)
