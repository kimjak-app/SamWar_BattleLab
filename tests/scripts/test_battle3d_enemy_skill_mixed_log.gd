extends SceneTree
# M4-c2 (file 2 of 2, part B): (A) untouched default battle, every ally waits through 3D until round
# 3 (enemies use their skills in round 2): final state == the same waits sent
# straight to an engine; every enemy skill_* event shown once from the events.
# (B) mixed log: an ally skill through 3D, the enemy actor's own skill in its
# slot, status ticks, reinforcements, and a synthetic enemy-cast strategy_cast
# written into the tactic log while that enemy's completion still waits in the
# replay queue: each shown once at its own point (the strategy only with the
# replayed enemy_action_completed), the four cursors independent.
var h
var injected := {}

func _initialize() -> void:
	run.call_deferred()

func sides_names(battle: Node) -> Array:
	var sides := {}
	var names := {}
	for u in battle.all_battle_unit_states:
		sides[u.unit_id] = u.side
		if not u.unique_skill_definition.is_empty(): names[u.unique_skill_definition.skill_id] = u.unique_skill_definition.display_name
	return [sides, names]

func stop_now(battle: Node, max_round: int) -> bool:
	# Same rule on both paths: stop at the first ally turn after an enemy unique skill, or at max_round.
	var enemy_cast: bool = battle.get("enemy_action_event_log").export().any(func(e): return e.kind == "enemy_skill_used")
	return enemy_cast or battle.get("battle_round") >= max_round or battle.call("_get_battle_result_state") != ""

func direct_waits(rounds: int) -> Dictionary:
	var host = await h.open_bare(self)
	var battle: Node = host.battle
	for step in range(20):
		if stop_now(battle, rounds): break
		battle.call("_select_ally_unit", battle.get("active_unit_state"), false, false, false)
		battle.call("_end_ally_turn_by_wait")
		await h.settle_bare(self, battle, "direct step %d" % step)
	var result: Dictionary = h.final_state(battle)
	result["tactic"] = battle.get("tactic_event_log").export()
	await h.close_bare(self, host)
	return result

func inject_probe(tree: SceneTree) -> void:
	await h.enemy_skill_probe(tree)
	var lab = h.lab
	var battle: Node = lab.engine
	var actor: BattleUnitState = battle.all_battle_unit_states[5]
	if not injected.has("event") and lab._enemy_completion_pending(actor.unit_id):
		battle.tactic_event_log.record_strategy_cast(actor, battle.all_battle_unit_states[0], 0.5, true, "shake", 1)
		injected["event"] = battle.tactic_event_log.export()[-1]
	if injected.has("event") and lab._enemy_completion_pending(actor.unit_id):
		lab._consume_tactic_events()
		if lab.tactic_presentations.has(injected.event): h.expect(false, "enemy strategy_cast shown before its replayed enemy_action_completed")
		injected["held_seen"] = lab.pending_enemy_strategies.has(actor.unit_id)

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_enemy_skill_harness.gd").new()
	# (B) Mixed log.
	h.enemy_label_seen.clear()
	injected.clear()
	await h.open_lab(self)
	var lab = h.lab
	var battle: Node = lab.engine
	var s: Dictionary = h.skill_setup(battle, "X_enemy_skill_in_slot")
	s.units[0].apply_status_effect("burn", 2, 12) # the caster ticks after its own action
	lab._sync_views()
	await process_frame
	h.click(s.caster.grid_cell)
	h.press_skill()
	h.click(h.chosen_target(battle, s.caster).grid_cell)
	await h.settle_lab(self, "mixed", inject_probe)
	lab._process(0.0)
	var events: Array = battle.tactic_event_log.export()
	var sn: Array = sides_names(battle)
	h.expect(injected.has("event") and injected.get("held_seen", false), "synthetic enemy strategy_cast held while the enemy completion waited")
	h.expect(lab.tactic_presentations.filter(func(e): return e == injected.get("event")).size() == 1, "synthetic enemy strategy_cast shown exactly once (after the replayed completion)")
	h.expect(lab.tactic_presentations == events.filter(func(e): return e.kind in ["strategy_cast", "status_tick"]), "strategy_cast / status_tick each once, in log order")
	h.expect(lab.skill_presentations == h.ally_skill_events(events, sn[0]) and not lab.skill_presentations.is_empty(), "ally skill shown as M4-c1")
	h.expect(lab.enemy_skill_presentations == h.enemy_skill_events(events, sn[0]) and not lab.enemy_skill_presentations.is_empty(), "enemy skill shown at its replay")
	h.expect(lab.arrival_presentations == events.filter(func(e): return e.kind == "reinforcement_arrived"), "reinforcements once each")
	h.expect(lab.pending_enemy_skills.is_empty() and lab.pending_enemy_strategies.is_empty() and lab.enemy_skill_leftovers.is_empty(), "nothing left waiting")
	h.expect(lab.tactic_cursor == events.size() and [lab.event_cursor, lab.action_cursor, lab.enemy_cursor] == [battle.ally_move_event_log.export().size(), battle.battle_action_event_log.export().size(), battle.enemy_action_event_log.export().size()], "four cursors at their own log ends")
	print("[M4C2_MIXED] kinds=", events.map(func(e): return e.kind))
	await h.close_lab(self)
	print("[M4C2_MIXED_LOG] checks=", h.checks, " order_failures=", h.order_failures, " failures=", h.failures)
	quit(0 if h.failures.is_empty() else 1)
