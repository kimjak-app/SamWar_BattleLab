extends "res://tests/scripts/test_battle3d_enemy_turn_equivalence.gd"
# M4-c2: an ally waits; the enemy actor uses its unique skill in the replayed
# slot (line, single, area, self-area, after a move, killing the last ally, a
# charge that advances). 3D (wait button) vs engine direct: units, controller,
# three logs + tactic log, writes (M3 check_case). The enemy skill_* events are
# shown in log order, only after the replay reached that caster's
# enemy_skill_used, with "적 " lines / labels from the event values, the hold
# queue empty and no leftover, the ally lists and the momentum note untouched.

func case_labels() -> Array:
	return load("res://tests/scripts/support/battle3d_enemy_skill_harness.gd").ENEMY_CASES

func without_new_commands(state: Dictionary) -> Dictionary:
	var copy := state.duplicate(true)
	copy.writes = copy.writes.filter(func(call): return not call in h.NEW_COMMANDS)
	return copy

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_enemy_skill_harness.gd").new()
	var labels: Array = case_labels()
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--case="): labels = [arg.trim_prefix("--case=")]
	var kinds_seen := {}
	for label in labels:
		var t0 := Time.get_ticks_msec()
		var direct: Dictionary = await h.run_enemy_direct(self, label)
		var td: Dictionary = await h.run_enemy_3d(self, label)
		var battle: Node = h.lab.engine
		var sides := {}
		var names := {}
		for u in battle.all_battle_unit_states:
			sides[u.unit_id] = u.side
			if not u.unique_skill_definition.is_empty(): names[u.unique_skill_definition.skill_id] = u.unique_skill_definition.display_name
		h.roles_ids = {"enemy":h.roles(battle).enemy.unit_id}
		await h.close_lab(self)
		h.expect(direct.writes == td.writes, label + " same write sequence")
		for call in td.writes: h.expect(h.TWELVE.has(call), label + " write within the twelve commands " + call)
		h.expect(direct.tactic == td.tactic, label + " tactic_event_log equal")
		check_case(label, without_new_commands(direct), without_new_commands(td))
		var lab: Dictionary = td.lab
		var enemy_events: Array = h.enemy_skill_events(td.tactic, sides)
		h.expect(not enemy_events.is_empty() and td.logs.enemy_action_event_log.any(func(e): return e.kind == "enemy_skill_used"), label + " the enemy used its skill")
		h.expect(lab.enemy_presentations == enemy_events, label + " every enemy skill_* event shown once, in log order")
		var expected: Dictionary = h.enemy_expected(enemy_events, names)
		h.expect(lab.enemy_texts_skill == expected.lines, label + " enemy skill lines from the events " + str(lab.enemy_texts_skill) + " vs " + str(expected.lines))
		h.expect(h.sorted_pairs(lab.enemy_labels) == h.sorted_pairs(expected.labels), label + " enemy Label3D texts from the events " + str(h.sorted_pairs(lab.enemy_labels)))
		h.expect(lab.pending.is_empty() and lab.leftovers.is_empty() and lab.open.is_empty(), label + " hold queue empty after the replay, no leftover " + str(lab.leftovers))
		h.expect(lab.skill_presentations.is_empty() and lab.skill_texts.is_empty() and lab.labels.is_empty(), label + " ally skill lists untouched")
		h.expect(not lab.momentum_text.contains(" · "), label + " momentum note untouched by the enemy skill " + lab.momentum_text)
		var at := 0
		for line in lab.combat_lines:
			if at < expected.lines.size() and line == expected.lines[at]: at += 1
		h.expect(at == expected.lines.size() or lab.combat_lines.size() >= 5, label + " combat log keeps the enemy skill lines in order")
		for e in enemy_events.filter(func(x): return x.kind == "skill_effect"): kinds_seen[e.effect_kind] = true
		if label == "C6_lethal_defeat":
			h.expect(td.controller.battle_result_state == "defeat" and lab.result == "defeat" and lab.overlay[0], label + " the enemy skill ends the battle; 3D locks with the result")
		if label == "C5_after_move":
			var kinds: Array = td.logs.enemy_action_event_log.map(func(e): return e.kind)
			h.expect(kinds.find("enemy_moved") >= 0 and kinds.find("enemy_moved") < kinds.find("enemy_skill_used"), label + " move replayed before the skill " + str(kinds))
		print("[M4C2_CASE] ", label, " enemy=", td.logs.enemy_action_event_log.map(func(e): return e.kind), " effects=", enemy_events.filter(func(x): return x.kind == "skill_effect").map(func(x): return x.effect_kind), " ms=", Time.get_ticks_msec() - t0, " failures=", h.failures.size())
		if not h.failures.is_empty(): break
	print("[M4C2_ENEMY_SKILL_EQUIVALENCE] effect_kinds=", kinds_seen.keys(), " checks=", h.checks, " order_failures=", h.order_failures, " failures=", h.failures)
	quit(0 if h.failures.is_empty() else 1)
