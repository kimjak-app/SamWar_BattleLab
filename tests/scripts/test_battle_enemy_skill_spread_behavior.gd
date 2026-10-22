extends SceneTree
# S4-2b: enemy unique skill spread with `enemy_skill_spread_enabled = true`
# (test-only). Scenarios where nobody should yield equal the BASE golden
# exactly; the others check who yields, that the yielding actor goes on with its
# plan (no wasted action), who then uses its skill, that momentum stays when the
# follower can no longer use its skill, the last-use history, and that the
# decision draws no random number.
const GOLDEN := "res://tests/golden/battle_enemy_skill_spread_base_v0.json"
const HARNESS := "res://tests/scripts/support/battle_enemy_strategy_oracle_harness.gd"
const SAME_AS_BASE := ["SP01_single_candidate", "SP03_both_affordable", "SP05_no_history", "SP06_penalty_two_rounds"]
var h

func _initialize() -> void:
	_run.call_deferred()

func post(battle: Node, _unit) -> Dictionary:
	return {"decisions":battle.spread_decisions.duplicate(true), "history":battle.enemy_skill_last_use_round.duplicate(true), "flag":battle.enemy_skill_spread_enabled}

func slot_kinds(events: Array, unit_id: String) -> Array:
	var kinds := []
	var inside := false
	for e in events:
		if e.kind == "enemy_actor_selected": inside = e.unit_id == unit_id
		elif inside:
			kinds.append(e.kind)
			if e.kind == "enemy_action_completed": inside = false
	return kinds

func _run() -> void:
	h = load(HARNESS).new()
	h.tag = "[ENEMY_SKILL_SPREAD_BEHAVIOR]"
	h.battle_script = load("res://tests/scripts/support/battle_enemy_skill_spread_observer_battle.gd")
	h.flags = {"enemy_skill_spread_enabled":true}
	h.post_hook = post
	var golden: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(GOLDEN))
	var by_case := {}
	for item in golden.scenarios: by_case[item.case] = item
	var labels: Array = h.SPREAD_SCENARIOS
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--case="): labels = [arg.trim_prefix("--case=")]
	for label in labels:
		var t0 := Time.get_ticks_msec()
		var r: Dictionary = await h.run_spread_scenario(self, label)
		var ids: Dictionary = r._ids
		var enemy: Array = r.logs_end.enemy_action_event_log
		var skills: Array = enemy.filter(func(e): return e.kind == "enemy_skill_used").map(func(e): return e.unit_id)
		var decisions: Array = r._post.decisions
		var yields: Array = decisions.filter(func(d): return d[1]).map(func(d): return d[0])
		h.expect(r._post.flag, label + " flag on")
		h.expect(not decisions.is_empty() and decisions.all(func(d): return d[2]), label + " yield decisions draw no random number " + str(decisions))
		var view := {}
		for key in r:
			if not String(key).begins_with("_"): view[key] = r[key]
		if label in SAME_AS_BASE:
			var diff: Array = h.fingerprint.diff(JSON.parse_string(JSON.stringify(view)), by_case[label])
			h.expect(diff.is_empty(), label + " nobody yields: equals BASE " + str(diff.slice(0, 5)))
			h.expect(yields.is_empty(), label + " no yield " + str(decisions))
		match label:
			"SP01_single_candidate":
				h.expect(skills == [ids.guan], label + " single candidate keeps the old behavior " + str(skills))
			"SP02_yield_one_momentum":
				h.expect(yields == [ids.guan], label + " guan_yu yields to the higher-ranked xiahou_dun " + str(decisions))
				h.expect(skills == [ids.xiahou], label + " xiahou_dun uses its skill in its own slot " + str(skills))
				h.expect(slot_kinds(enemy, ids.guan).has("enemy_attack_resolved"), label + " the yielding actor goes on with its plan " + str(slot_kinds(enemy, ids.guan)))
			"SP03_both_affordable":
				h.expect(skills == [ids.guan, ids.xiahou], label + " momentum for both: both use " + str(skills))
				h.expect(r._post.history == {ids.guan:1, ids.xiahou:1}, label + " last-use history recorded " + str(r._post.history))
			"SP04_penalty_one_round":
				h.expect(yields == [ids.guan], label + " recent use (d=1, -40) makes guan_yu yield to zhang_fei " + str(decisions))
				# Round 3: zhang_fei uses its skill. The next round may start with guan_yu again
				# (zhang_fei then carries the d=1 penalty), which is the intended rotation.
				h.expect(not skills.is_empty() and skills[0] == ids.zhang, label + " zhang_fei uses its skill first " + str(skills))
				h.expect(slot_kinds(enemy, ids.guan).has("enemy_attack_resolved"), label + " the yielding actor goes on with its plan")
			"SP05_no_history":
				h.expect(skills.size() >= 1 and skills[0] == ids.guan, label + " without history guan_yu ranks first " + str(skills))
			"SP06_penalty_two_rounds":
				h.expect(skills.size() >= 1 and skills[0] == ids.guan, label + " d=2 (-20) still ranks guan_yu first " + str(skills))
			"SP07_yield_then_blocked":
				h.expect(yields == [ids.guan], label + " guan_yu yields " + str(decisions))
				h.expect(skills.is_empty(), label + " the follower could not use its skill " + str(skills))
				var start: Dictionary = r.checkpoints[0].controller
				var end: Dictionary = r.checkpoints[-1].controller
				h.expect(end.enemy_momentum >= start.enemy_momentum, label + " momentum stays for the next round %d -> %d" % [start.enemy_momentum, end.enemy_momentum])
		print("[ENEMY_SKILL_SPREAD_CASE] ", label, " skills=", skills, " decisions=", decisions, " history=", r._post.history, " ms=", Time.get_ticks_msec() - t0, " failures=", h.failures.size())
	print("[ENEMY_SKILL_SPREAD_BEHAVIOR] checks=", h.checks, " failures=", h.failures)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
