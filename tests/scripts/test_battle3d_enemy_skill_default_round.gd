extends SceneTree
# M4-c2 (file 1 of 2): (A) untouched default battle, every ally waits through 3D until round
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
	# (A) Default battle, all waits until round 3.
	var direct: Dictionary = await direct_waits(6)
	h.enemy_label_seen.clear()
	await h.open_lab(self)
	var lab = h.lab
	var battle: Node = lab.engine
	for step in range(20):
		if stop_now(battle, 6): break
		h.click(battle.active_unit_state.grid_cell)
		lab._sync_views()
		h.press_wait()
		await h.settle_lab(self, "default step %d" % step, h.enemy_skill_probe)
	lab._process(0.0)
	var td: Dictionary = h.final_state(battle)
	td["tactic"] = battle.get("tactic_event_log").export()
	var sn: Array = sides_names(battle)
	var enemy_events: Array = h.enemy_skill_events(td.tactic, sn[0])
	h.expect(not enemy_events.is_empty(), "default battle: an enemy used its skill by round 6")
	h.expect(direct.writes == td.writes and h.fingerprint.diff(direct.units, td.units).is_empty() and h.fingerprint.diff(direct.controller, td.controller).is_empty(), "default battle: 3D waits == engine direct")
	for name in direct.logs: h.expect(direct.logs[name] == td.logs[name], "default battle: " + name + " equal")
	h.expect(direct.tactic == td.tactic, "default battle: tactic log equal")
	h.expect(lab.enemy_skill_presentations == enemy_events, "default battle: every enemy skill event shown once, in order")
	h.expect(lab.enemy_skill_texts == h.enemy_expected(enemy_events, sn[1]).lines, "default battle: enemy skill lines from the events")
	h.expect(h.sorted_pairs(h.enemy_label_seen.values()) == h.sorted_pairs(h.enemy_expected(enemy_events, sn[1]).labels), "default battle: enemy labels from the events")
	h.expect(lab.pending_enemy_skills.is_empty() and lab.enemy_skill_leftovers.is_empty() and lab.enemy_skill_open.is_empty(), "default battle: hold queue empty, no leftover")
	h.expect(lab.enemy_summaries.size() == td.logs.enemy_action_event_log.filter(func(e): return e.kind == "enemy_actor_selected").size(), "default battle: one summary per enemy slot")
	print("[M4C2_DEFAULT] round=", battle.battle_round, " enemy_casts=", enemy_events.filter(func(e): return e.kind == "skill_cast").map(func(e): return e.caster_id))
	await h.close_lab(self)
	print("[M4C2_DEFAULT_ROUND] checks=", h.checks, " order_failures=", h.order_failures, " failures=", h.failures)
	quit(0 if h.failures.is_empty() else 1)
