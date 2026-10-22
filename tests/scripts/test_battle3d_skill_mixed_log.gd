extends SceneTree
# M4-c1: the fourth cursor reads the whole tactic log. Round 1 puts a strategy
# (sent straight to the engine by the test), an enemy unique skill (the enemy
# actor's own, in its slot), status ticks and the round-2 reinforcements in the
# log; round 2 the ally uses its skill through 3D input. Only allied skill_*
# events are shown as skills, the other kinds keep their own presentation, and
# the four cursors stay independent.
var h

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_skill_harness.gd").new()
	await h.open_lab(self)
	var lab = h.lab
	var battle: Node = lab.engine
	var s: Dictionary = h.skill_setup(battle, "X_enemy_skill_in_slot")
	var caster: BattleUnitState = s.caster
	caster.intelligence = 95
	s.units[6].intelligence = 70
	battle.strategy_roll_override = h.forced_roll(true, 0)
	lab._sync_views()
	await process_frame
	# Round 1: a strategy sent straight to the engine (test-only engine calls).
	battle._select_ally_unit(caster, false, false, false)
	battle._on_strategy_button_pressed()
	battle._try_use_strategy_on_target(s.units[6])
	await h.settle_lab(self, "strategy round", h.skill_display_probe)
	var before: Array = battle.tactic_event_log.export()
	var kinds_before: Array = before.map(func(e): return e.kind)
	h.expect(kinds_before.has("strategy_cast") and kinds_before.has("reinforcement_arrived") and before.any(func(e): return e.kind == "skill_cast" and e.side == "enemy"), "log holds strategy, enemy skill and reinforcement events before the 3D skill " + str(kinds_before))
	h.expect(lab.skill_presentations.is_empty() and lab.skill_texts.is_empty(), "enemy-cast skill_* events skipped (no skill shown)")
	h.expect(lab.tactic_cursor == before.size(), "cursor at the end after round 1")
	h.expect(battle.battle_round == 2, "round 2 after the strategy round")
	# Round 2: unique skill through 3D input.
	h.label_seen.clear()
	h.click(caster.grid_cell)
	lab._sync_views()
	h.expect(not lab.skill_button.disabled, "skill available in round 2 " + lab.skill_button.tooltip_text)
	var target: BattleUnitState = h.chosen_target(battle, caster)
	h.press_skill()
	h.click(target.grid_cell)
	await h.settle_lab(self, "skill round", h.skill_display_probe)
	lab._process(0.0)
	var events: Array = battle.tactic_event_log.export()
	var sides := {}
	var skill_names := {}
	for u in battle.all_battle_unit_states:
		sides[u.unit_id] = u.side
		if not u.unique_skill_definition.is_empty(): skill_names[u.unique_skill_definition.skill_id] = u.unique_skill_definition.display_name
	var ally_events: Array = h.ally_skill_events(events, sides)
	h.expect(lab.tactic_cursor == events.size(), "fourth cursor at the end of the mixed log")
	h.expect(lab.skill_presentations == ally_events and ally_events.size() >= 3, "only allied skill events presented as skills, in order")
	h.expect(lab.tactic_presentations == events.filter(func(e): return e.kind in ["strategy_cast", "status_tick"]), "strategy_cast/status_tick keep their own presentation")
	h.expect(lab.arrival_presentations == events.filter(func(e): return e.kind == "reinforcement_arrived"), "reinforcement_arrived keeps its own presentation")
	var expected: Dictionary = h.expected_display(ally_events, skill_names)
	h.expect(lab.skill_texts == expected.lines, "skill lines from the allied events only " + str(lab.skill_texts))
	h.expect(h.sorted_pairs(h.label_seen.values()) == h.sorted_pairs(expected.labels), "round-2 Label3D texts from the allied events")
	h.expect([lab.event_cursor, lab.action_cursor, lab.enemy_cursor] == [battle.ally_move_event_log.export().size(), battle.battle_action_event_log.export().size(), battle.enemy_action_event_log.export().size()], "other three cursors at their own log ends")
	h.expect(battle.writes.count("_on_unique_skill_button_pressed") == 1 and battle.writes.count("_try_use_unique_skill_on_target") == 1, "one skill command pair from 3D")
	print("[M4C1_MIXED_LOG] kinds=", events.map(func(e): return e.kind + ("" if not e.has("side") else ":" + e.side)))
	await h.close_lab(self)
	print("[M4C1_MIXED_LOG] checks=", h.checks, " failures=", h.failures)
	quit(0 if h.failures.is_empty() else 1)
