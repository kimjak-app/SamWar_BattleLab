extends SceneTree
# S4-2c addendum: enemy unique skill use cap with `enemy_skill_cap_enabled =
# true` (test-only). A deciding enemy whose count is 2+ above the lowest count
# of the other live enemies holding a skill does not use it (it goes on with its
# plan, momentum kept), unless the whole enemy side has used no skill for two
# rounds. A late reinforcement holding a skill counts as 0; a dead holder is
# ignored; a capped enemy is never a rotation candidate; the ally auto action is
# untouched; no cap decision draws a random number.
const HARNESS := "res://tests/scripts/support/battle_enemy_skill_cap_harness.gd"
var h

func _initialize() -> void:
	_run.call_deferred()

func post(battle: Node, _unit) -> Dictionary:
	return {"caps":battle.cap_decisions.duplicate(true), "uses":battle.use_records.duplicate(true), "counts":battle.enemy_skill_use_count.duplicate(true),
		"last_any":battle.enemy_skill_last_any_use_round, "decisions":battle.spread_decisions.duplicate(true)}

func first_slot(events: Array, unit_id: String) -> Array:
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

func check(label: String, r: Dictionary) -> void:
	var ids: Dictionary = r._ids
	var enemy: Array = r.logs_end.enemy_action_event_log
	var skills: Array = enemy.filter(func(e): return e.kind == "enemy_skill_used").map(func(e): return e.unit_id)
	var caps: Array = r._post.caps
	var capped_ids: Array = caps.filter(func(c): return c[1]).map(func(c): return c[0])
	h.expect(caps.all(func(c): return c[2]), label + " cap decisions draw no random number " + str(caps))
	var start: Dictionary = r.checkpoints[0].controller
	match label:
		"CP01_gap_two_capped", "CP03b_safety_boundary_still_capped":
			h.expect(capped_ids.has(ids.xiahou) and not skills.has(ids.xiahou), label + " xiahou_dun (2 uses, others 0) is capped " + str(caps) + str(skills))
			var slot := first_slot(enemy, ids.xiahou)
			h.expect(slot.has("enemy_attack_resolved") and not slot.has("enemy_skill_used"), label + " it goes on with its plan " + str(slot))
			h.expect(r.checkpoints[-1].controller.enemy_momentum >= start.enemy_momentum, label + " momentum kept")
		"CP02_others_caught_up":
			h.expect(not capped_ids.has(ids.xiahou) and skills.has(ids.xiahou), label + " others used once each: gap 1, xiahou_dun uses " + str(caps) + str(skills))
			h.expect(r._post.counts.get(ids.xiahou, 0) == 3 and r._post.last_any == 3, label + " use counted once, side's last use updated " + str(r._post.counts))
		"CP03_safety_release":
			h.expect(not capped_ids.has(ids.xiahou) and skills.has(ids.xiahou), label + " no use for two rounds (3 - 0 >= 3): released " + str(caps) + str(skills))
		"CP04_reinforcement_arrival_caps":
			h.expect(capped_ids.has(ids.guan) and not skills.has(ids.guan), label + " a reinforcement holding a skill arrives with 0 uses: guan_yu (2) is capped " + str(caps) + str(skills))
		"CP05_capped_not_a_rotation_candidate":
			var yields: Array = r._post.decisions.filter(func(d): return d[1]).map(func(d): return d[0])
			h.expect(not yields.has(ids.guan) and skills.size() >= 1 and skills[0] == ids.guan, label + " capped xiahou_dun is no rotation candidate: guan_yu does not yield " + str(r._post.decisions) + str(skills))
			h.expect(not skills.has(ids.xiahou), label + " xiahou_dun stays capped " + str(skills))
		"CP06_dead_holder_ignored":
			h.expect(not capped_ids.has(ids.xiahou) and skills.has(ids.xiahou), label + " dead zhang_fei (0) is ignored: min of guan_yu (2) -> gap 0 " + str(caps) + str(skills))
		"CP08_flag_off_no_cap":
			h.expect(capped_ids.is_empty() and skills.has(ids.xiahou), label + " flag false: the same counts lock nothing " + str(caps) + str(skills))
			h.expect(r._post.counts.get(ids.xiahou, 0) == 2 and r._post.last_any == 2, label + " flag false: nothing recorded " + str(r._post.counts))
		"CP07_ally_auto_untouched":
			var ally_casts: Array = r.logs_end.tactic_event_log.filter(func(e): return e.kind == "skill_cast" and e.caster_id == ids.ally)
			h.expect(not ally_casts.is_empty() and not caps.any(func(c): return c[0] == ids.ally and c[1]), label + " the ally auto action still uses its skill (cap is enemy-only) " + str(caps))
	# Invariant on every confirmed use with the cap on: a gap of 2+ needs the safety release (round - last any >= 3).
	for u in (r._post.uses if label != "CP08_flag_off_no_cap" else []):
		if u[3] >= 0 and u[2] - u[3] >= 2:
			h.expect(u[4] >= 0 and u[1] - u[4] >= 3, label + " invariant: capped use only after two idle rounds " + str(u))

func _run() -> void:
	h = load(HARNESS).new()
	h.tag = "[ENEMY_SKILL_CAP_BEHAVIOR]"
	h.battle_script = load("res://tests/scripts/support/battle_enemy_skill_cap_observer_battle.gd")
	h.post_hook = post
	var labels: Array = h.CAP_SCENARIOS
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--case="): labels = [arg.trim_prefix("--case=")]
	for label in labels:
		var t0 := Time.get_ticks_msec()
		var r: Dictionary = await h.run_cap_scenario(self, label)
		check(label, r)
		var skills: Array = r.logs_end.enemy_action_event_log.filter(func(e): return e.kind == "enemy_skill_used").map(func(e): return e.unit_id)
		print("[ENEMY_SKILL_CAP_CASE] ", label, " skills=", skills, " caps=", r._post.caps, " counts=", r._post.counts, " ms=", Time.get_ticks_msec() - t0, " failures=", h.failures.size())
	print("[ENEMY_SKILL_CAP_BEHAVIOR] checks=", h.checks, " failures=", h.failures)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
