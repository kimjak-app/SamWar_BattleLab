extends SceneTree
# M4-e: an enemy strategy (level "mid" set through the engine function, enemy
# intelligence fixture) replayed in 3D in the enemy action order: selected ->
# "적 책략 사용: caster → target" -> completion, with the cast outcome (success
# with the status and turns, or failure) and its status label shown with the
# slot's completion and before a later status tick of the caster, one
# completion per slot, no battle end, the "적 " prefix like the M4-c2 enemy
# skill lines. An unknown enemy event kind does not stall the replay. Every
# expected string is built here from the engine events.
var h
const STATUS := {"shake":"동요", "confusion":"혼란"}

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_enemy_strategy_harness.gd").new()
	for spec in [{"label":"success", "success":true}, {"label":"failure", "success":false}, {"label":"burning_caster", "success":true, "burning":true}]:
		var tag: String = spec.label
		await h.open_lab(self)
		h.strategy_fixture(spec)
		var b: Node = h.lab.engine
		var writes_before: int = b.writes.size()
		await process_frame
		h.lab.wait_button.pressed.emit()
		await h.wait_idle(self)
		var lab = h.lab
		var enemy: Array = b.enemy_action_event_log.export()
		var kinds: Array = enemy.map(func(e): return e.kind)
		var used: Array = enemy.filter(func(e): return e.kind == "enemy_strategy_used")
		var casts: Array = b.tactic_event_log.export().filter(func(e): return e.kind == "strategy_cast")
		h.expect(used.size() == 1 and casts.size() == 1 and casts[0].caster_id == used[0].unit_id and casts[0].success == spec.success, tag + " the engine used one enemy strategy " + str(kinds))
		if used.is_empty() or casts.is_empty():
			await h.close_lab(self)
			continue
		var caster: String = used[0].unit_id
		var target: String = used[0].target_id
		h.expect(kinds.slice(0, 4) == ["enemy_turn_started", "enemy_actor_selected", "enemy_strategy_used", "enemy_action_completed"], tag + " engine order " + str(kinds))
		h.expect(enemy.filter(func(e): return e.kind == "enemy_action_completed" and e.unit_id == caster).size() == 1, tag + " one completion for the slot")
		# Replay order of the enemy lines.
		var i: int = lab.enemy_texts.find("적 행동 중 · " + caster)
		h.expect(i >= 0 and i + 1 < lab.enemy_texts.size() and lab.enemy_texts[i + 1] == "적 책략 사용: %s → %s" % [caster, target], tag + " selected -> strategy line " + str(lab.enemy_texts))
		# Outcome with the completion.
		var cast: Dictionary = casts[0]
		var outcome: String = ("%s %d턴" % [STATUS.get(cast.status_id, cast.status_id), cast.turns_after]) if cast.success else "실패"
		var want_tactic := "적 책략 %s · %s" % ["성공" if cast.success else "실패", outcome]
		var want_combat := "적 책략 · %s → %s · %s · %s (성공률 %d%%)" % [caster, target, "성공" if cast.success else "실패", outcome, roundi(cast.success_rate * 100.0)]
		h.expect(lab.tactic_texts.size() >= 1 and lab.tactic_texts[0] == want_tactic, tag + " outcome line '%s' == '%s'" % [str(lab.tactic_texts.slice(0, 1)), want_tactic])
		h.expect(lab.combat_lines.has(want_combat), tag + " combat line " + want_combat)
		h.expect(lab.tactic_presentations.size() >= 1 and lab.tactic_presentations[0] == cast, tag + " the cast event itself is presented")
		var texts: Array = h.tactic_labels_seen.values().map(func(v): return v[0])
		h.expect(texts.has(outcome), tag + " status label '%s' over the target shown %s" % [outcome, str(texts)])
		var summary_index: int = lab.combat_lines.find(lab.combat_lines.filter(func(x): return x.begins_with("적 행동 결과"))[0]) if lab.combat_lines.any(func(x): return x.begins_with("적 행동 결과")) else -1
		h.expect(summary_index >= 0 and summary_index < lab.combat_lines.find(want_combat), tag + " the outcome comes with the slot's completion (after its summary)")
		if spec.get("burning", false):
			var ticks: Array = b.tactic_event_log.export().filter(func(e): return e.kind == "status_tick" and e.unit_id == caster)
			var tick_line := "화상 · %s −%d" % [caster, ticks[0].burn_damage] if not ticks.is_empty() else ""
			h.expect(not ticks.is_empty() and lab.combat_lines.find(want_combat) < lab.combat_lines.find(tick_line), tag + " the caster's burn tick after the cast outcome")
		h.expect(lab.battle_result.is_empty() and b.call("_get_battle_result_state") == "" and not lab.result_overlay.visible, tag + " a strategy does not end the battle")
		h.expect(b.writes.slice(writes_before) == ["_end_ally_turn_by_wait"] or b.writes.slice(writes_before).all(func(w): return w in ["_end_ally_turn_by_wait", "_select_ally_unit"]), tag + " 3D sent only the wait " + str(b.writes.slice(writes_before)))
		# An unknown kind in the replay queue is skipped, not stuck.
		if tag == "success":
			lab.enemy_queue.append({"kind":"future_enemy_kind", "unit_id":caster})
			for f in range(30): await process_frame
			h.expect(lab.enemy_queue.is_empty() and not lab._enemy_presentation_busy(), tag + " unknown kind skipped")
		await h.close_lab(self)
	print("[ENEMY_STRATEGY_REPLAY] checks=", h.checks, " failures=", h.failures)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
