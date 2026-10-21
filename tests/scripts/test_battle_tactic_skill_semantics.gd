extends SceneTree
# S4-1 unique-skill event semantics (one case per effect_type plus ally auto,
# enemy auto and advance on kill): skill_cast only at the commit (momentum
# spent), skill_effect values equal the applied state changes in command
# order, skill_finished after the cooldown, cast -> effects -> finished in a row.
var h

func case_labels() -> Array:
	var labels: Array = []
	for effect_type in load("res://tests/scripts/support/battle_tactic_oracle_harness.gd").SKILL_EFFECT_TYPES: labels.append("K_" + effect_type)
	labels.append_array(["K_ally_auto_skill", "K_enemy_auto_skill", "K_advance_on_kill"])
	return labels

func _initialize() -> void:
	_run.call_deferred()

func post(battle: Node, _unit) -> Dictionary:
	return {"samples":battle.samples.duplicate(true)}

func is_subsequence(part: Array, whole: Array) -> bool:
	var i := 0
	for item in whole:
		if i < part.size() and part[i] == item: i += 1
	return i == part.size()

func check_skill(label: String, result: Dictionary) -> void:
	var samples: Array = result._post.samples
	var begins: Array = samples.filter(func(s): return s.kind == "skill_begin")
	var applies: Array = samples.filter(func(s): return s.kind == "skill_apply")
	var finals: Array = samples.filter(func(s): return s.kind == "skill_finalize")
	var events: Array = result._tactic_events
	var casts: Array = events.filter(func(e): return e.kind == "skill_cast")
	h.expect(begins.size() >= 1 and applies.size() == 1 and finals.size() == 1, label + " one committed skill " + str([begins.size(), applies.size(), finals.size()]))
	for begin in begins:
		var new_casts: Array = begin.new_events.filter(func(e): return e.kind == "skill_cast")
		if begin.committed:
			var spent: int = begin.momentum_before[begin.side] - begin.momentum_after[begin.side]
			h.expect(new_casts.size() == 1 and new_casts[0].caster_id == begin.caster_id and new_casts[0].side == begin.side and new_casts[0].momentum_cost == spent and new_casts[0].skill_id == begin.plan_skill_id,
				label + " skill_cast at commit, momentum_cost == spent " + str(new_casts) + " spent=" + str(spent))
		else:
			h.expect(new_casts.is_empty(), label + " no skill_cast without commit")
	if applies.size() != 1 or casts.size() != 1: return
	var apply: Dictionary = applies[0]
	var effects: Array = apply.new_events
	h.expect(effects.all(func(e): return e.kind == "skill_effect" and e.caster_id == apply.caster_id), label + " only skill_effect from the caster while applying")
	h.expect(is_subsequence(effects.map(func(e): return e.effect_kind), apply.command_types), label + " effects follow command order " + str(effects.map(func(e): return e.effect_kind)) + " in " + str(apply.command_types))
	var before: Dictionary = apply.before
	var after: Dictionary = apply.after
	var hp_change := {}
	var momentum_change := {"ally":0, "enemy":0}
	var max_turns := {}
	for e in effects:
		match e.effect_kind:
			"damage":
				hp_change[e.target_id] = hp_change.get(e.target_id, 0) - e.amount
				h.expect(e.amount > 0 and e.from_cell == before[e.caster_id].cell and e.to_cell == after[e.caster_id].cell, label + " damage amount and caster cells " + str(e))
			"heal":
				hp_change[e.target_id] = hp_change.get(e.target_id, 0) + e.amount
				h.expect(e.amount > 0, label + " heal amount > 0")
			"status":
				var key := "%s/%s" % [e.target_id, e.status_id]
				max_turns[key] = maxi(max_turns.get(key, 0), e.turns_after)
				h.expect(e.turns > 0 and e.turns_after >= e.turns, label + " status turns " + str(e))
			"cleanse":
				h.expect(before[e.target_id].turns.has(e.status_id) and not after[e.target_id].turns.has(e.status_id), label + " cleanse removed " + e.status_id)
			"momentum":
				momentum_change[e.target_id] += e.amount
			"move":
				h.expect(e.from_cell == before[e.target_id].cell and e.to_cell == after[e.target_id].cell and e.from_cell != e.to_cell, label + " move cells " + str(e))
	for id in before:
		h.expect(after[id].hp - before[id].hp == hp_change.get(id, 0), label + " hp change of %s == recorded damage/heal (%d vs %d)" % [id, after[id].hp - before[id].hp, hp_change.get(id, 0)])
	for e in effects.filter(func(x): return x.effect_kind == "damage"):
		var last: Array = effects.filter(func(x): return x.effect_kind == "damage" and x.target_id == e.target_id)
		if last[-1].sequence == e.sequence: h.expect(e.killed == not after[e.target_id].alive, label + " killed flag " + e.target_id)
	for key in max_turns:
		var parts: PackedStringArray = key.split("/")
		h.expect(after[parts[0]].turns.get(parts[1], 0) == max_turns[key], label + " status turns_after matches state " + key)
	for side in ["ally", "enemy"]:
		h.expect(apply.momentum_after[side] - apply.momentum_before[side] == momentum_change[side], label + " momentum change %s == recorded" % side)
	# cast -> effects -> finished in a row.
	var start: int = events.find(casts[0])
	var finished: Array = events.filter(func(e): return e.kind == "skill_finished")
	h.expect(finished.size() == 1 and finished[0].caster_id == casts[0].caster_id, label + " one skill_finished")
	if finished.size() == 1:
		var block: Array = events.slice(start, events.find(finished[0]) + 1)
		h.expect(block.size() == effects.size() + 2 and block.slice(1, -1) == effects, label + " cast -> effects -> finished contiguous")
		h.expect(finished[0].cooldown_turns == finals[0].cooldown, label + " cooldown_turns == cooldown set " + str(finished[0]))
		h.expect(not finals[0].new_events.is_empty() and finals[0].new_events[0].kind == "skill_finished", label + " skill_finished recorded inside finalize")

func _run() -> void:
	h = load("res://tests/scripts/support/battle_tactic_oracle_harness.gd").new()
	h.tag = "[TACTIC_SKILL_SEMANTICS]"
	h.battle_script = load("res://tests/scripts/support/battle_tactic_observer_battle.gd")
	h.post_hook = post
	var kinds_seen := {}
	var labels: Array = case_labels()
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--case="): labels = [arg.trim_prefix("--case=")]
	for label in labels:
		var result: Dictionary = await h.run_case(self, label)
		check_skill(label, result)
		for e in result._tactic_events.filter(func(x): return x.kind == "skill_effect"): kinds_seen[e.effect_kind] = true
		var cast: Array = result._tactic_events.filter(func(x): return x.kind == "skill_cast")
		if label == "K_enemy_auto_skill":
			h.expect(not cast.is_empty() and cast[0].side == "enemy", label + " enemy skill_cast")
			h.expect(result.logs_end.enemy_action_event_log.any(func(e): return e.kind == "enemy_skill_used"), label + " enemy_skill_used kept")
		if label == "K_advance_on_kill":
			var kill: Array = result._tactic_events.filter(func(x): return x.kind == "skill_effect" and x.killed and x.status_id == "advance_on_kill")
			h.expect(kill.size() == 1 and kill[0].from_cell != kill[0].to_cell, label + " kill then caster advance " + str(kill))
		print("[TACTIC_SKILL_SEMANTICS_CASE] ", label, " tactic=", result._tactic_events.map(func(x): return x.kind if x.kind != "skill_effect" else x.effect_kind), " failures=", h.failures.size())
	print("[TACTIC_SKILL_SEMANTICS] effect kinds seen=", kinds_seen.keys(), " checks=", h.checks, " failures=", h.failures)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
