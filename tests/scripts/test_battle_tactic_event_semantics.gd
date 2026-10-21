extends SceneTree
# S4-1 event semantics: each recorded tactic event agrees with the state it
# describes, sampled by a transparent observer at the moment of recording.
var h

func _initialize() -> void:
	_run.call_deferred()

func post(battle: Node, _unit) -> Dictionary:
	return {"samples":battle.samples.duplicate(true)}

func check_strategy(label: String, result: Dictionary) -> void:
	var casts: Array = result._tactic_events.filter(func(e): return e.kind == "strategy_cast")
	h.expect(casts.size() == 1, label + " exactly one strategy_cast")
	if casts.size() != 1: return
	var e: Dictionary = casts[0]
	var spec: Dictionary = result.spec
	h.expect(e.caster_id == result._unit_ids[0] and e.target_id == result._unit_ids[5], label + " caster/target ids")
	h.expect(is_equal_approx(e.success_rate, spec.rate), label + " success_rate == engine rate")
	h.expect(e.success == spec.want_success, label + " success matches the seeded roll")
	var sample: Array = result._post.samples.filter(func(s): return s.kind == "strategy")
	h.expect(sample.size() == 1, label + " target sampled when the caster is marked acted")
	if sample.size() == 1:
		var turns: Dictionary = sample[0].target_turns
		if e.success:
			h.expect(turns.has(e.status_id) and turns[e.status_id] == e.turns_after and e.turns_after >= e.turns and e.turns > 0, label + " success: target has status " + str(turns) + " " + str(e))
		else:
			h.expect(turns.is_empty() and e.status_id == "" and e.turns == 0, label + " failure: target untouched " + str(turns))
	# Order: the sample above is taken only when strategy_cast is still the last
	# tactic event as the caster is marked acted (nothing in between); a target
	# tick comes only from the target's own action.
	for tick in result._post.samples.filter(func(s): return s.kind == "tick" and s.unit_id == e.target_id):
		h.expect(tick.acted, label + " target ticks only after its own action")

func check_ticks(label: String, result: Dictionary) -> int:
	var count := 0
	for sample in result._post.samples.filter(func(s): return s.kind == "tick"):
		var events: Array = sample.new_events.filter(func(x): return x.kind == "status_tick")
		if sample.before.turns.is_empty():
			h.expect(events.is_empty(), label + " no status_tick without statuses " + sample.unit_id)
			continue
		count += 1
		h.expect(sample.acted, label + " tick happens right after the unit's action " + sample.unit_id)
		h.expect(events.size() == 1, label + " one status_tick per tick " + sample.unit_id)
		if events.size() != 1: continue
		var e: Dictionary = events[0]
		h.expect(e.unit_id == sample.unit_id, label + " tick unit id")
		h.expect(e.burn_damage == sample.before.hp - sample.after.hp, label + " burn_damage == hp drop " + str(e))
		h.expect(sample.before.troops - sample.after.troops == e.burn_damage, label + " troops drop == burn_damage (hp == troops fixture)")
		h.expect(e.remaining == sample.after.turns, label + " remaining == statuses after tick")
		var expired: Array = sample.before.turns.keys().filter(func(k): return not sample.after.turns.has(k))
		expired.sort()
		h.expect(e.expired == expired, label + " expired list " + str(e.expired) + " vs " + str(expired))
	return count

func check_reinforcements(label: String, result: Dictionary) -> void:
	var arrivals: Array = result._tactic_events.filter(func(x): return x.kind == "reinforcement_arrived")
	var sampled := 0
	for sample in result._post.samples.filter(func(s): return s.kind == "reinforcement"):
		for item in sample.arrived:
			sampled += 1
			var e: Dictionary = item.event
			h.expect(e.kind == "reinforcement_arrived" and e.source == sample.source and e.round == sample.round, label + " arrival source/round " + str(e))
			h.expect(e.cell == item.cell and item.deployed and not item.has_acted, label + " arrival cell == unit cell, deployed, not acted " + str(item))
			h.expect(not sample.round_started_before.has(sample.round), label + " arrival recorded before round_started %d" % sample.round)
	h.expect(sampled == arrivals.size(), label + " every arrival recorded inside a deploy call")
	var expected := [["reinforce_01", 2, "ally"], ["reinforce_01", 2, "enemy"], ["city_reinforce_02", 3, "ally"], ["city_reinforce_02", 3, "enemy"]]
	h.expect(arrivals.map(func(e): return [e.source, e.round, e.side]) == expected, label + " reinforce_01 at round 2, city reinforce_02 at round 3 " + str(arrivals))
	var rounds: Array = result.logs_end.enemy_action_event_log.filter(func(e): return e.kind == "round_started").map(func(e): return e.round)
	h.expect(rounds == [2, 3], label + " round_started 2 and 3 still in the enemy log " + str(rounds))

func _run() -> void:
	h = load("res://tests/scripts/support/battle_tactic_oracle_harness.gd").new()
	h.tag = "[TACTIC_SEMANTICS]"
	h.battle_script = load("res://tests/scripts/support/battle_tactic_observer_battle.gd")
	h.post_hook = post
	for label in h.STRATEGY_CASES + ["T1_burn_shake_tick", "K_commit_failure", "R1_default_reinforcements_round3"]:
		var result: Dictionary = await h.run_case(self, label)
		if label.begins_with("S"):
			check_strategy(label, result)
			h.expect(not result._tactic_events.any(func(x): return x.kind.begins_with("skill_")), label + " strategy records no skill events")
		if label == "K_commit_failure":
			var begins: Array = result._post.samples.filter(func(s): return s.kind == "skill_begin")
			h.expect(begins.size() == 1 and not begins[0].committed, label + " the sequence started and did not commit")
			h.expect(not result._tactic_events.any(func(x): return x.kind.begins_with("skill_")), label + " no skill_cast/effect/finished on commit failure " + str(result._tactic_events))
		if label == "R1_default_reinforcements_round3": check_reinforcements(label, result)
		var ticks := check_ticks(label, result)
		if label == "T1_burn_shake_tick":
			var events: Array = result._tactic_events.filter(func(x): return x.kind == "status_tick")
			h.expect(ticks >= 2 and events.size() >= 2, label + " ally and enemy ticks recorded")
			var ally_tick: Array = events.filter(func(x): return x.unit_id == result._unit_ids[0])
			h.expect(not ally_tick.is_empty() and ally_tick[0].burn_damage == 6 and ally_tick[0].expired == ["shake"] and ally_tick[0].remaining == {"burn":1}, label + " ally burn 12 -> 6 damage, shake expires " + str(ally_tick))
			var enemy_tick: Array = events.filter(func(x): return x.unit_id == result._unit_ids[5])
			h.expect(not enemy_tick.is_empty() and enemy_tick[0].burn_damage == 4 and enemy_tick[0].expired == ["burn"], label + " enemy burn minimum 4, expires " + str(enemy_tick))
		print("[TACTIC_SEMANTICS_CASE] ", label, " tactic=", result._tactic_events.map(func(x): return x.kind), " failures=", h.failures.size())
	print("[TACTIC_SEMANTICS] checks=", h.checks, " failures=", h.failures)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
