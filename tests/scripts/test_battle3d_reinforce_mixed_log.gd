extends SceneTree
# M4-d: the fourth cursor reads the whole tactic log but handles only
# reinforcement_arrived. A unique skill and a strategy (dice forced by the S4-1
# test hook) sent straight to the engine by the test put skill_*,
# strategy_cast and status_tick events in the log before the round-2
# arrivals; they are skipped without error and the other three cursors are
# untouched.
var h

func _initialize() -> void:
	run.call_deferred()

func skill(skill_id: String) -> Dictionary:
	for s in JSON.parse_string(FileAccess.get_file_as_string("res://data/heroes/generated/hero_unique_skills.json")).skills:
		if s.skill_id == skill_id: return s
	return {}

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_reinforce_harness.gd").new()
	await h.open_lab(self)
	var lab = h.lab
	var battle: Node = lab.engine
	h.setup(battle, "M7_enemy_lethal_hit") # units[1] stays unacted: two ally actions in round 1
	var r: Dictionary = h.roles(battle)
	r.ally.current_hp = 300
	r.ally.current_troops = 300
	r.ally.unique_skill_definition = skill("xiahou_dun_unique")
	battle.battle_momentum.gain("ally", 10, "fixture")
	var second: BattleUnitState = r.units[1]
	h.oracle._setup_unit(second, "infantry", Vector2i(8,5))
	second.intelligence = 95
	battle._sync_resumed_unit_markers_to_grid(second)
	battle._sync_demo_positions()
	battle.strategy_roll_override = func(kind, _v): return true if kind == "success" else 1
	lab._sync_views()
	await process_frame
	# Test-only engine calls: a unique skill, then a strategy.
	battle._select_ally_unit(r.ally, false, false, false)
	battle._on_unique_skill_button_pressed()
	battle._try_use_unique_skill_on_target(r.enemy)
	await h.settle_lab(self, "skill")
	battle._select_ally_unit(second, false, false, false)
	battle._on_strategy_button_pressed()
	battle._try_use_strategy_on_target(battle._get_strategy_targets(second)[0])
	await h.settle_lab(self, "strategy", h.arrival_probe)
	lab._process(0.0)
	var events: Array = battle.tactic_event_log.export()
	var kinds: Array = events.map(func(e): return e.kind)
	h.expect(kinds.has("skill_cast") and kinds.has("strategy_cast") and kinds.has("reinforcement_arrived"), "mixed log " + str(kinds))
	h.expect(kinds.find("strategy_cast") < kinds.find("reinforcement_arrived") and kinds.find("skill_cast") < kinds.find("reinforcement_arrived"), "other kinds come before the arrivals")
	h.expect(lab.tactic_cursor == events.size(), "fourth cursor at the end of the mixed log")
	h.expect(lab.arrival_presentations == events.filter(func(e): return e.kind == "reinforcement_arrived"), "only arrivals presented, in order")
	h.expect([lab.event_cursor, lab.action_cursor, lab.enemy_cursor] == [battle.ally_move_event_log.export().size(), battle.battle_action_event_log.export().size(), battle.enemy_action_event_log.export().size()], "other three cursors at their own log ends")
	h.expect(battle.battle_round == 2 and lab.views["ally_reinforce_01_demo"].visible and lab.views["enemy_reinforce_01_demo"].visible, "round-2 arrivals shown")
	h.expect(battle.writes.all(func(c): return h.EIGHT.has(c)), "3D sent nothing beyond the eight commands")
	print("[M4D_MIXED_LOG] kinds=", kinds)
	await h.close_lab(self)
	print("[M4D_MIXED_LOG] checks=", h.checks, " failures=", h.failures)
	quit(0 if h.failures.is_empty() else 1)
