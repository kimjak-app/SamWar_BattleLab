extends SceneTree
# S4-2a: enemy strategy with `enemy_strategy_enabled = true` (test-only). The
# dice is forced by the S4-1 hook. Scenarios where the rule must NOT fire equal
# the BASE golden exactly; scenarios where it fires are checked event by event:
# enemy_actor_selected -> enemy_strategy_used -> strategy_cast -> (status_tick)
# -> enemy_action_completed, no momentum spent, no move/attack, one completion
# per slot, the round keeps going.
const GOLDEN := "res://tests/golden/battle_enemy_strategy_base_v0.json"
const HARNESS := "res://tests/scripts/support/battle_enemy_strategy_oracle_harness.gd"
const NO_STRATEGY := ["ES04_int79", "ES05_out_of_range", "ES06_confused", "ES07_action_lock", "ES08_target_already_shaken",
	"ES09_plan_attack", "ES10_lethal_first", "ES11_skill_first"]
var h

func _initialize() -> void:
	_run.call_deferred()

func case_labels() -> Array:
	return load(HARNESS).STRATEGY_SCENARIOS

func post(battle: Node, _actor) -> Dictionary:
	return {"choices":battle.strategy_choices.duplicate(true), "enemy_flag":battle.enemy_strategy_enabled, "momentum":battle.strategy_momentum.duplicate(true)}

func slots(events: Array) -> Array:
	var result := []
	var cur := []
	for e in events:
		if e.kind == "enemy_actor_selected": cur = [e]
		elif not cur.is_empty():
			cur.append(e)
			if e.kind == "enemy_action_completed":
				result.append(cur)
				cur = []
	return result

func check_fired(label: String, r: Dictionary, spec: Dictionary) -> void:
	var enemy: Array = r.logs_end.enemy_action_event_log
	var tactic: Array = r.logs_end.tactic_event_log
	var used: Array = enemy.filter(func(e): return e.kind == "enemy_strategy_used")
	var casts: Array = tactic.filter(func(e): return e.kind == "strategy_cast")
	h.expect(used.size() == 1 and casts.size() == 1, label + " one enemy strategy " + str(enemy.map(func(e): return e.kind)))
	if used.is_empty() or casts.is_empty(): return
	h.expect(used[0].keys().size() == 5 and used[0].has("unit_id") and used[0].has("target_id") and used[0].schema_version == 0, label + " enemy_strategy_used fields " + str(used[0]))
	h.expect(used[0].unit_id == r._ids.actor and casts[0].caster_id == r._ids.actor and used[0].target_id == casts[0].target_id, label + " attempt and effect agree")
	h.expect(casts[0].success == spec.success, label + " forced outcome")
	if spec.success:
		var pool: Array = {86:[["shake", 1]], 92:[["confusion", 1], ["shake", 2]], 96:[["confusion", 2], ["shake", 3]]}[spec.int]
		h.expect([casts[0].status_id, casts[0].turns] == pool[spec.pool], label + " outcome from the pool " + str([casts[0].status_id, casts[0].turns]))
	else:
		h.expect(casts[0].status_id == "" and casts[0].turns == 0, label + " failure applies nothing")
	var slot: Array = slots(enemy).filter(func(s): return s[0].unit_id == r._ids.actor)[0] if slots(enemy).any(func(s): return s[0].unit_id == r._ids.actor) else []
	h.expect(slot.map(func(e): return e.kind) == ["enemy_actor_selected", "enemy_strategy_used", "enemy_action_completed"], label + " slot closes once, no move/attack " + str(slot.map(func(e): return e.kind)))
	var start: Dictionary = r.checkpoints[0].controller
	var end: Dictionary = r.checkpoints[-1].controller
	var spent: Array = r._post.momentum.filter(func(m): return m[0] == r._ids.actor)
	h.expect(not spent.is_empty() and spent[0][1] == spent[0][2], label + " strategy costs no momentum " + str(spent))
	if end.battle_result_state == "":
		h.expect(end.current_phase == "ally_turn" and not end.is_demo_animating, label + " turn handed back (not stuck)")
	var selected: int = enemy.filter(func(e): return e.kind == "enemy_actor_selected").size()
	var completed: int = enemy.filter(func(e): return e.kind == "enemy_action_completed").size()
	h.expect(selected == completed, label + " every slot completed exactly once")
	# Effect order: the attempt is recorded before its strategy_cast, the caster's tick after it.
	for e in tactic.filter(func(x): return x.kind == "status_tick" and x.unit_id == r._ids.actor):
		h.expect(tactic.find(e) > tactic.find(casts[0]), label + " caster tick after its strategy_cast")

func _run() -> void:
	h = load(HARNESS).new()
	h.tag = "[ENEMY_STRATEGY_BEHAVIOR]"
	h.battle_script = load("res://tests/scripts/support/battle_enemy_strategy_observer_battle.gd")
	h.flags = {"enemy_strategy_enabled":true}
	h.post_hook = post
	var golden: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(GOLDEN))
	var by_case := {}
	for item in golden.scenarios: by_case[item.case] = item
	var labels: Array = case_labels()
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--case="): labels = [arg.trim_prefix("--case=")]
	for label in labels:
		var t0 := Time.get_ticks_msec()
		var r: Dictionary = await h.run_strategy_scenario(self, label)
		var spec: Dictionary = h.strategy_spec(label)
		h.expect(r._post.enemy_flag, label + " flag on")
		var view := {}
		for key in r:
			if not String(key).begins_with("_"): view[key] = r[key]
		var enemy: Array = r.logs_end.enemy_action_event_log
		if label in NO_STRATEGY:
			h.expect(h.fingerprint.diff(JSON.parse_string(JSON.stringify(view)), by_case[label]).is_empty(), label + " rule does not fire: equals BASE " + str(h.fingerprint.diff(JSON.parse_string(JSON.stringify(view)), by_case[label]).slice(0, 5)))
			h.expect(not enemy.any(func(e): return e.kind == "enemy_strategy_used"), label + " no enemy strategy")
		else:
			check_fired(label, r, spec)
		match label:
			"ES01_basic_in_range", "ES02_advanced_in_range", "ES03_master_in_range":
				h.expect(r._post.choices.size() == 1 and r._post.choices[0][1] == r._ids.target and r._post.choices[0][2] == r._ids.target, label + " plan target kept " + str(r._post.choices))
			"ES05_out_of_range":
				h.expect(r._post.choices.size() == 1 and r._post.choices[0][2] == "", label + " searched, nothing in range")
			"ES08_target_already_shaken":
				h.expect(r._post.choices.size() == 1 and r._post.choices[0][2] == "", label + " shaken target excluded (basic pool = shake)")
			"ES04_int79", "ES06_confused", "ES07_action_lock", "ES09_plan_attack", "ES10_lethal_first", "ES11_skill_first":
				h.expect(r._post.choices.is_empty(), label + " the strategy target search never ran " + str(r._post.choices))
			"ES11_skill_first":
				pass
			"ES12_blocked_plan_target_fallback":
				h.expect(r._post.choices.size() == 1 and r._post.choices[0][1] == r._ids.target and r._post.choices[0][2] == r._ids.ally2, label + " blocked plan target -> existing selection picks the other ally " + str(r._post.choices))
			"ES13_second_actor_skips_afflicted":
				var actors: Array = slots(enemy).map(func(s): return s[0].unit_id)
				h.expect(actors == [r._ids.actor, r._ids.second], label + " both enemies act " + str(actors))
				h.expect(r._post.choices.size() == 2 and r._post.choices[1] == [r._ids.second, r._ids.target, ""], label + " second actor: the shaken target is excluded " + str(r._post.choices))
				var second: Array = slots(enemy)[1].map(func(e): return e.kind) if slots(enemy).size() > 1 else []
				h.expect(not second.has("enemy_strategy_used") and second.size() >= 3, label + " second actor follows its plan " + str(second))
			"ES14_burning_caster_tick":
				h.expect(r.logs_end.tactic_event_log.any(func(e): return e.kind == "status_tick" and e.unit_id == r._ids.actor and e.burn_damage > 0), label + " caster burn tick after strategy")
			"ES15_burn_tick_ends_battle":
				h.expect(r.checkpoints[-1].controller.battle_result_state == "victory" and enemy.any(func(e): return e.kind == "battle_ended" and e.result_state == "victory"), label + " burn tick after the strategy ends the battle " + str(enemy.map(func(e): return e.kind)))
			"ES16_round_complete":
				var kinds: Array = enemy.map(func(e): return e.kind)
				h.expect(kinds.find("round_started") > kinds.find("enemy_strategy_used") and r.checkpoints[-1].controller.battle_round == 2, label + " round completes after the strategy " + str(kinds))
		if label == "ES11_skill_first":
			h.expect(enemy.any(func(e): return e.kind == "enemy_skill_used"), label + " the unique skill comes first")
		print("[ENEMY_STRATEGY_BEHAVIOR_CASE] ", label, " enemy=", enemy.map(func(e): return e.kind), " choices=", r._post.choices, " ms=", Time.get_ticks_msec() - t0, " failures=", h.failures.size())
	print("[ENEMY_STRATEGY_BEHAVIOR] checks=", h.checks, " failures=", h.failures)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
