extends "res://tests/scripts/test_battle3d_enemy_turn_equivalence.gd"
# M4-b: an ally slot ended by the engine's strategy command, 3D input (button
# -> target click) vs engine direct (`_on_strategy_button_pressed` ->
# `_try_use_strategy_on_target`). The dice is forced by the S4-1 test hook on
# both paths. Reuses every M3 per-case check (40 fields, 12 controller values,
# three logs, playback, hits, summaries) and adds the tactic log, the ten-command
# contract, the event-driven strategy/tick display and the fourth cursor.

func case_labels() -> Array:
	return load("res://tests/scripts/support/battle3d_strategy_harness.gd").STRATEGY_CASES

func without_new_commands(state: Dictionary) -> Dictionary:
	var copy := state.duplicate(true)
	copy.writes = copy.writes.filter(func(call): return not call in ["_end_ally_turn_by_wait", "_on_defend_button_pressed", "_on_strategy_button_pressed", "_try_use_strategy_on_target"])
	return copy

func check_strategy(label: String, direct: Dictionary, td: Dictionary) -> void:
	h.expect(direct.writes == td.writes, label + " same write sequence " + str(td.writes))
	h.expect(td.writes.count("_on_strategy_button_pressed") == 1 and td.writes.count("_try_use_strategy_on_target") == 1, label + " one button and one target call")
	for call in td.writes: h.expect(h.TEN.has(call), label + " write within the ten commands " + call)
	h.expect(direct.tactic == td.tactic, label + " tactic_event_log equal")
	check_case(label, without_new_commands(direct), without_new_commands(td))
	var lab: Dictionary = td.lab
	h.expect(lab.tactic_cursor == td.tactic.size(), label + " fourth cursor at the tactic log end, independent of the other three")
	var handled: Array = td.tactic.filter(func(e): return e.kind in ["strategy_cast", "status_tick"])
	h.expect(lab.presentations == handled, label + " every strategy_cast/status_tick presented once, in log order, nothing else")
	h.expect(lab.pending_ticks.is_empty(), label + " no tick left waiting after the replay")
	var casts: Array = td.tactic.filter(func(e): return e.kind == "strategy_cast")
	h.expect(casts.size() == 1, label + " one strategy_cast")
	if casts.size() != 1: return
	var cast: Dictionary = casts[0]
	var outcome: String = ("%s %d턴" % [{"shake":"동요","confusion":"혼란"}.get(cast.status_id, cast.status_id), cast.turns_after]) if cast.success else "실패"
	h.expect(lab.tactic_texts.has("책략 %s · %s" % ["성공" if cast.success else "실패", outcome]), label + " outcome text from the event " + str(lab.tactic_texts))
	h.expect(lab.combat_lines.has("책략 · %s → %s · %s · %s (성공률 %d%%)" % [cast.caster_id, cast.target_id, "성공" if cast.success else "실패", outcome, roundi(cast.success_rate * 100.0)]), label + " combat line from the event")
	for tick in td.tactic.filter(func(e): return e.kind == "status_tick"):
		if tick.burn_damage > 0: h.expect(lab.tactic_texts.has("화상 · %s −%d" % [tick.unit_id, tick.burn_damage]), label + " burn text from the event")
		for status_id in tick.expired:
			h.expect(lab.tactic_texts.has("%s 해제 · %s" % [{"shake":"동요","confusion":"혼란","burn":"화상"}.get(status_id, status_id), tick.unit_id]), label + " expiry text " + status_id)

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_strategy_harness.gd").new()
	var labels: Array = case_labels()
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--case="): labels = [arg.trim_prefix("--case=")]
	for label in labels:
		var t0 := Time.get_ticks_msec()
		var direct: Dictionary = await h.run_strategy_direct(self, label)
		var td: Dictionary = await h.run_strategy_3d(self, label)
		h.roles_ids = {"enemy":h.roles(h.lab.engine).enemy.unit_id}
		await h.close_lab(self)
		check_strategy(label, direct, td)
		var spec: Array = h.SPEC[label]
		var cast: Array = td.tactic.filter(func(e): return e.kind == "strategy_cast")
		h.expect(not cast.is_empty() and cast[0].success == spec[1], label + " forced outcome reached the engine")
		if label == "G9_shaken_enemy_acts_in_slot":
			var acted: Array = td.logs.enemy_action_event_log.filter(func(e): return e.kind == "enemy_actor_selected" and e.unit_id == cast[0].target_id)
			h.expect(not acted.is_empty() and td.tactic.any(func(e): return e.kind == "status_tick" and e.unit_id == cast[0].target_id), label + " shaken enemy acted and ticked in its replayed slot")
		if label == "G10_burning_caster_ticks":
			h.expect(td.tactic.any(func(e): return e.kind == "status_tick" and e.unit_id == cast[0].caster_id and e.burn_damage > 0), label + " caster burn tick right after its own action")
		print("[M4B_STRATEGY_CASE] ", label, " tactic=", td.tactic.map(func(e): return e.kind), " writes=", td.writes, " ms=", Time.get_ticks_msec() - t0, " failures=", h.failures.size())
		if not h.failures.is_empty(): break
	print("[M4B_STRATEGY_EQUIVALENCE] checks=", h.checks, " display_checks=", h.display_checks, " failures=", h.failures)
	quit(0 if h.failures.is_empty() else 1)
