extends SceneTree
# M4-b: the fourth cursor reads the whole tactic log but handles only
# strategy_cast / status_tick. A real unique skill (sent to the engine by the
# test, not by 3D) and the round-2 reinforcements put skill_* and
# reinforcement_arrived events in the log before the 3D strategy; they are
# skipped without error and the other three cursors are untouched.
var h

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_strategy_harness.gd").new()
	await h.open_lab(self)
	var lab = h.lab
	var battle: Node = lab.engine
	h.setup(battle, "M6_infantry_attack")
	var r: Dictionary = h.roles(battle)
	r.ally.intelligence = 95
	r.enemy.intelligence = 70
	r.ally.unique_skill_definition = _skill("xiahou_dun_unique")
	battle.battle_momentum.gain("ally", 10, "fixture")
	battle.strategy_roll_override = h.forced_roll(true, 1)
	lab._sync_views()
	await process_frame
	# Round 1: a unique skill sent straight to the engine (test-only engine calls).
	battle._select_ally_unit(r.ally, false, false, false)
	battle._on_unique_skill_button_pressed()
	battle._try_use_unique_skill_on_target(r.enemy)
	await h.settle_lab(self, "skill round")
	var kinds_before: Array = battle.tactic_event_log.export().map(func(e): return e.kind)
	h.expect(kinds_before.has("skill_cast") and kinds_before.has("skill_effect") and kinds_before.has("skill_finished") and kinds_before.has("reinforcement_arrived"), "log holds skill and reinforcement events before the strategy " + str(kinds_before))
	h.expect(lab.tactic_cursor == kinds_before.size() and lab.tactic_presentations.all(func(e): return e.kind in ["strategy_cast", "status_tick"]), "skill/reinforcement events read and skipped")
	h.expect(battle.battle_round == 2, "round 2 after the skill round")
	# Round 2: strategy through 3D input on the same caster.
	h.click(r.ally.grid_cell)
	lab._sync_views()
	h.expect(not lab.strategy_button.disabled, "strategy available in round 2")
	h.press_strategy()
	h.click(r.enemy.grid_cell)
	await h.settle_lab(self, "strategy round")
	lab._process(0.0)
	var events: Array = battle.tactic_event_log.export()
	h.expect(lab.tactic_cursor == events.size(), "fourth cursor at the end of the mixed log")
	h.expect(lab.tactic_presentations == events.filter(func(e): return e.kind in ["strategy_cast", "status_tick"]), "only strategy_cast/status_tick presented, in order")
	h.expect(lab.tactic_texts.any(func(x): return x.begins_with("책략 성공")), "strategy shown after the mixed events")
	h.expect([lab.event_cursor, lab.action_cursor, lab.enemy_cursor] == [battle.ally_move_event_log.export().size(), battle.battle_action_event_log.export().size(), battle.enemy_action_event_log.export().size()], "other three cursors at their own log ends")
	h.expect(battle.writes.count("_on_strategy_button_pressed") == 1 and battle.writes.count("_try_use_strategy_on_target") == 1, "one strategy command pair from 3D")
	print("[M4B_MIXED_LOG] kinds=", events.map(func(e): return e.kind))
	await h.close_lab(self)
	print("[M4B_MIXED_LOG] checks=", h.checks, " failures=", h.failures)
	quit(0 if h.failures.is_empty() else 1)

func _skill(skill_id: String) -> Dictionary:
	for skill in JSON.parse_string(FileAccess.get_file_as_string("res://data/heroes/generated/hero_unique_skills.json")).skills:
		if skill.skill_id == skill_id: return skill
	return {}
