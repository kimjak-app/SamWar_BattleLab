extends SceneTree
# S4-2c: enemy unique skill rotation with `enemy_skill_spread_enabled = true`
# (test-only). When the deciding enemy and the other unacted enemies with a
# high-value skill cannot all be paid by the shared momentum, only the one whose
# last use is the oldest (never used first; then raw score; then actor order)
# uses it; the others go on with their plan. Scenarios where nobody yields equal
# the BASE golden exactly. Also: an acted enemy and a below-threshold enemy are
# never candidates, the ally auto action is untouched, history is recorded,
# and no decision draws a random number.
const GOLDEN := "res://tests/golden/battle_enemy_skill_spread_base_v0.json"
const HARNESS := "res://tests/scripts/support/battle_enemy_skill_rotation_harness.gd"
const SAME_AS_BASE := ["SP01_single_candidate", "SP03_both_affordable", "SP05_no_history"]
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

func first_slot_kinds(events: Array, unit_id: String) -> Array:
	# Only the actor's first slot (the round under test; a later round may start in the same run).
	var kinds := []
	var inside := false
	for e in events:
		if e.kind == "enemy_actor_selected":
			if inside: break
			inside = e.unit_id == unit_id
		elif inside:
			kinds.append(e.kind)
			if e.kind == "enemy_action_completed": break
	return kinds

func check(label: String, r: Dictionary, by_case: Dictionary) -> void:
	var ids: Dictionary = r._ids
	var enemy: Array = r.logs_end.enemy_action_event_log
	var skills: Array = enemy.filter(func(e): return e.kind == "enemy_skill_used").map(func(e): return e.unit_id)
	var decisions: Array = r._post.decisions
	var yields: Array = decisions.filter(func(d): return d[1]).map(func(d): return d[0])
	h.expect(r._post.flag, label + " flag on")
	h.expect(decisions.all(func(d): return d[2]), label + " yield decisions draw no random number " + str(decisions))
	if label in SAME_AS_BASE:
		var view := {}
		for key in r:
			if not String(key).begins_with("_"): view[key] = r[key]
		var diff: Array = h.fingerprint.diff(JSON.parse_string(JSON.stringify(view)), by_case[label])
		h.expect(diff.is_empty(), label + " nobody yields: equals BASE " + str(diff.slice(0, 5)))
		h.expect(yields.is_empty(), label + " no yield " + str(decisions))
	match label:
		"SP01_single_candidate":
			h.expect(skills == [ids.guan], label + " single candidate keeps the old behavior " + str(skills))
		"SP02_yield_one_momentum":
			h.expect(yields == [ids.guan], label + " both never used: higher raw (xiahou_dun 341) first, guan_yu yields " + str(decisions))
			h.expect(skills == [ids.xiahou], label + " xiahou_dun uses its skill in its own slot " + str(skills))
			h.expect(slot_kinds(enemy, ids.guan).has("enemy_attack_resolved"), label + " the yielding actor goes on with its plan " + str(slot_kinds(enemy, ids.guan)))
		"SP03_both_affordable":
			h.expect(skills == [ids.guan, ids.xiahou], label + " momentum for all: no yield, both use " + str(skills))
			h.expect(r._post.history == {ids.guan:1, ids.xiahou:1}, label + " last-use history recorded " + str(r._post.history))
		"SP04_penalty_one_round":
			# Round 3 is under test; in round 4 never-used xiahou_dun joins the candidates again.
			h.expect(decisions[0][0] == ids.guan and decisions[0][1], label + " guan_yu (used last round) yields to never-used zhang_fei " + str(decisions))
			h.expect(not skills.is_empty() and skills[0] == ids.zhang, label + " zhang_fei uses its skill first " + str(skills))
			h.expect(first_slot_kinds(enemy, ids.guan).has("enemy_attack_resolved"), label + " the yielding actor goes on with its plan")
		"SP05_no_history":
			h.expect(skills.size() >= 1 and skills[0] == ids.guan, label + " both never used: higher raw (guan_yu 268 > 240) first " + str(skills))
		"SP06_penalty_two_rounds":
			# Changed by S4-2c: under the old penalty (-20 at d=2) guan_yu stayed first; now any older
			# last use ranks first, and zhang_fei has never used its skill.
			h.expect(yields.size() >= 1 and yields[0] == ids.guan, label + " guan_yu (used two rounds ago) yields to never-used zhang_fei " + str(decisions))
			h.expect(not skills.is_empty() and skills[0] == ids.zhang, label + " zhang_fei first " + str(skills))
		"SP07_yield_then_blocked":
			h.expect(yields == [ids.guan], label + " guan_yu yields " + str(decisions))
			h.expect(skills.is_empty(), label + " the follower could not use its skill " + str(skills))
			h.expect(r.checkpoints[-1].controller.enemy_momentum >= r.checkpoints[0].controller.enemy_momentum, label + " momentum stays for the next round")
		"RT01_last_use_tie_raw_decides":
			h.expect(yields.is_empty() and not skills.is_empty() and skills[0] == ids.guan, label + " same last use: raw decides (guan_yu 268 first) " + str(decisions) + str(skills))
		"RT02_three_candidates_one_momentum":
			h.expect(yields.size() >= 1 and yields[0] == ids.guan, label + " guan_yu yields " + str(decisions))
			h.expect(not skills.is_empty() and skills[0] == ids.zhang, label + " of three candidates the never-used one (zhang_fei) uses it " + str(skills))
		"RT03_acted_enemy_not_a_candidate":
			h.expect(yields.is_empty() and skills == [ids.guan], label + " an acted enemy (xiahou_dun, never used, raw 341) is no candidate: guan_yu uses " + str(decisions) + str(skills))
		"RT04_low_score_not_a_candidate":
			h.expect(yields.is_empty() and not skills.is_empty() and skills[0] == ids.guan, label + " zhang_fei (raw 75 < 130, never used) is no candidate: guan_yu uses " + str(decisions) + str(skills))
		"RT05_ally_auto_untouched":
			var ally_casts: Array = r.logs_end.tactic_event_log.filter(func(e): return e.kind == "skill_cast" and e.caster_id == ids.ally)
			h.expect(not ally_casts.is_empty(), label + " the ally auto action still uses its skill (the rule is enemy-only) " + str(r.logs_end.tactic_event_log.map(func(e): return e.kind)))
			h.expect(not decisions.any(func(d): return d[0] == ids.ally and d[1]), label + " no yield decision for the ally " + str(decisions))

func _run() -> void:
	h = load(HARNESS).new()
	h.tag = "[ENEMY_SKILL_ROTATION_BEHAVIOR]"
	h.battle_script = load("res://tests/scripts/support/battle_enemy_skill_spread_observer_battle.gd")
	h.flags = {"enemy_skill_spread_enabled":true}
	h.post_hook = post
	var golden: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(GOLDEN))
	var by_case := {}
	for item in golden.scenarios: by_case[item.case] = item
	var labels: Array = h.SPREAD_SCENARIOS + h.ROTATION_SCENARIOS
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--case="): labels = [arg.trim_prefix("--case=")]
	for label in labels:
		var t0 := Time.get_ticks_msec()
		var r: Dictionary
		if label.begins_with("SP"): r = await h.run_spread_scenario(self, label)
		else: r = await h.run_rotation_scenario(self, label)
		check(label, r, by_case)
		var skills: Array = r.logs_end.enemy_action_event_log.filter(func(e): return e.kind == "enemy_skill_used").map(func(e): return e.unit_id)
		print("[ENEMY_SKILL_ROTATION_CASE] ", label, " skills=", skills, " decisions=", r._post.decisions, " history=", r._post.history, " ms=", Time.get_ticks_msec() - t0, " failures=", h.failures.size())
	print("[ENEMY_SKILL_ROTATION_BEHAVIOR] checks=", h.checks, " failures=", h.failures)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
