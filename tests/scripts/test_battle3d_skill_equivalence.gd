extends "res://tests/scripts/test_battle3d_enemy_turn_equivalence.gd"
# M4-c1: an ally slot ended by the engine's unique skill command, 3D input
# (button -> target click, or button only for the three self-resolving modes)
# vs engine direct (`_on_unique_skill_button_pressed` ->
# `_try_use_unique_skill_on_target`). One case per effect_type (36, all eight
# target modes) plus an enemy slot where the enemy uses its own skill. Reuses
# the M3 per-case checks (40 fields, 12 controller values, three logs, playback,
# hits, summaries) and adds the tactic log, the twelve-command contract and the
# event-driven skill display (log lines, status line, Label3D texts, momentum HUD).
# Run in shards (CI 120 s per file).

func case_labels() -> Array:
	return load("res://tests/scripts/support/battle3d_skill_harness.gd").skill_cases()

func without_new_commands(state: Dictionary) -> Dictionary:
	var copy := state.duplicate(true)
	copy.writes = copy.writes.filter(func(call): return not call in h.NEW_COMMANDS)
	return copy

func check_skill(label: String, direct: Dictionary, td: Dictionary, sides: Dictionary, skill_names: Dictionary) -> void:
	h.expect(direct.writes == td.writes, label + " same write sequence " + str(td.writes))
	h.expect(td.writes.count("_on_unique_skill_button_pressed") == 1, label + " one skill button call")
	h.expect(td.writes.count("_try_use_unique_skill_on_target") == (0 if td.auto else 1), label + " target calls: 0 for self-resolving modes, 1 otherwise")
	for call in td.writes: h.expect(h.TWELVE.has(call), label + " write within the twelve commands " + call)
	h.expect(direct.tactic == td.tactic, label + " tactic_event_log equal")
	h.expect(direct.target == td.target, label + " same target")
	check_case(label, without_new_commands(direct), without_new_commands(td))
	var lab: Dictionary = td.lab
	h.expect(lab.tactic_cursor == td.tactic.size(), label + " fourth cursor at the tactic log end")
	h.expect(lab.presentations == td.tactic.filter(func(e): return e.kind in ["strategy_cast", "status_tick"]), label + " strategy/tick presentations untouched")
	h.expect(lab.pending_ticks.is_empty(), label + " no tick left waiting")
	var ally_events: Array = h.ally_skill_events(td.tactic, sides)
	h.expect(lab.skill_presentations == ally_events, label + " every allied skill_* event presented once, in log order, nothing else")
	h.expect(ally_events.size() >= 2 and ally_events[0].kind == "skill_cast" and ally_events[-1].kind == "skill_finished", label + " allied cast ... finished present")
	var expected: Dictionary = h.expected_display(ally_events, skill_names)
	h.expect(lab.skill_texts == expected.lines, label + " status/log lines from the events " + str(lab.skill_texts) + " vs " + str(expected.lines))
	var at := 0
	for line in lab.combat_lines:
		if at < expected.lines.size() and line == expected.lines[at]: at += 1
	h.expect(at == expected.lines.size(), label + " combat log holds every skill line in order")
	h.expect(h.sorted_pairs(lab.labels) == h.sorted_pairs(expected.labels), label + " Label3D texts from the events " + str(h.sorted_pairs(lab.labels)) + " vs " + str(h.sorted_pairs(expected.labels)))
	var m: Dictionary = td.controller
	h.expect(lab.momentum_text == "기세 아군 %d / 적 %d%s" % [m.ally_momentum, m.enemy_momentum, "" if expected.note == "" else " · " + expected.note], label + " momentum HUD " + lab.momentum_text)

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_skill_harness.gd").new()
	var labels: Array = case_labels()
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--case="): labels = [arg.trim_prefix("--case=")]
	var kinds_seen := {}
	var modes_seen := {}
	for label in labels:
		var t0 := Time.get_ticks_msec()
		var direct: Dictionary = await h.run_skill_direct(self, label)
		var td: Dictionary = await h.run_skill_3d(self, label)
		var battle: Node = h.lab.engine
		var sides := {}
		var skill_names := {}
		for u in battle.all_battle_unit_states:
			sides[u.unit_id] = u.side
			if not u.unique_skill_definition.is_empty(): skill_names[u.unique_skill_definition.skill_id] = u.unique_skill_definition.display_name
		var caster: BattleUnitState = h.roles(battle).ally
		td["auto"] = h.is_auto(battle, caster)
		var mode: String = battle.call("_get_unique_skill_for_unit", caster).target_mode
		h.roles_ids = {"enemy":h.roles(battle).enemy.unit_id}
		await h.close_lab(self)
		check_skill(label, direct, td, sides, skill_names)
		modes_seen[mode] = true
		var effects: Array = h.ally_skill_events(td.tactic, sides).filter(func(e): return e.kind == "skill_effect").map(func(e): return e.effect_kind)
		for k in effects: kinds_seen[k] = true
		if label == "X_enemy_skill_in_slot":
			var enemy_casts: Array = td.tactic.filter(func(e): return e.kind == "skill_cast" and e.side == "enemy")
			h.expect(not enemy_casts.is_empty() and td.logs.enemy_action_event_log.any(func(e): return e.kind == "enemy_skill_used"), label + " the enemy used its skill in the replayed slot")
			h.expect(not td.lab.skill_presentations.any(func(e): return e.caster_id == enemy_casts[0].caster_id), label + " enemy-cast skill_* events skipped")
		print("[M4C1_SKILL_CASE] ", label, " mode=", mode, " effects=", effects, " tactic=", td.tactic.map(func(e): return e.kind), " writes=", td.writes, " ms=", Time.get_ticks_msec() - t0, " failures=", h.failures.size())
		if not h.failures.is_empty(): break
	print("[M4C1_SKILL_EQUIVALENCE] modes=", modes_seen.keys(), " effect_kinds=", kinds_seen.keys(), " checks=", h.checks, " display_checks=", h.display_checks, " momentum_checks=", h.momentum_checks, " failures=", h.failures)
	quit(0 if h.failures.is_empty() else 1)
