extends SceneTree
# M5-a: untouched default 18x10 battle, the 3D [자동] button (4x speed) vs the
# engine's own `_toggle_full_auto_battle` called directly (4x), same seed, until
# the engine ends the battle. Compared: engine snapshots at the start of rounds
# 2 and 3 (units, momentum, four logs, next random value), the final units /
# controller / four logs, the write sequence (one toggle), and the 3D replay of
# every ally move, ally attack, ally skill, enemy move and enemy hit plus the
# result overlay. Run per seed (CI 120 s per file).
var h

func _initialize() -> void:
	run.call_deferred()

func seeds() -> Array:
	return [1, 2, 3]

func ally_ids(battle: Node) -> Array:
	return battle.get("all_battle_unit_states").filter(func(u): return u.side == "ally").map(func(u): return u.unit_id)

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_auto_harness.gd").new()
	for seed_value in seeds():
		var t0 := Time.get_ticks_msec()
		var direct: Dictionary = await h.run_auto_direct(self, seed_value, 4.0)
		var td: Dictionary = await h.run_auto_3d(self, seed_value, 2)
		var battle: Node = h.lab.engine
		var sides := {}
		var names := {}
		for u in battle.all_battle_unit_states:
			sides[u.unit_id] = u.side
			if not u.unique_skill_definition.is_empty(): names[u.unique_skill_definition.skill_id] = u.unique_skill_definition.display_name
		var allies: Array = ally_ids(battle)
		await h.close_lab(self)
		var tag := "seed %d" % seed_value
		h.expect(Engine.time_scale == 1.0 and td.lab.time_scale == 4.0, tag + " lab ran at 4x and restored 1x on close")
		h.expect(td.writes == ["_select_ally_unit", "_toggle_full_auto_battle"] + td.writes.slice(2) and td.writes.count("_toggle_full_auto_battle") == 1, tag + " one toggle from 3D " + str(td.writes.slice(0, 3)))
		h.expect(direct.writes == td.writes, tag + " same engine write sequence (" + str(td.writes.size()) + " calls)")
		for call in td.writes: h.expect(h.THIRTEEN.has(call), tag + " write within the thirteen commands " + call)
		for r in [2, 3]:
			h.expect(direct.round_snaps.has(r) and td.round_snaps.has(r) and h.fingerprint.diff(direct.round_snaps[r], td.round_snaps[r]).is_empty(), tag + " round %d start snapshot equal (units, momentum, four logs, next random)" % r)
		h.expect(h.fingerprint.diff(direct.units, td.units).is_empty(), tag + " final 40-field units equal")
		h.expect(h.fingerprint.diff(direct.controller, td.controller).is_empty(), tag + " final controller equal " + str(h.fingerprint.diff(direct.controller, td.controller)))
		for name in direct.logs: h.expect(direct.logs[name] == td.logs[name], tag + " " + name + " equal")
		h.expect(direct.tactic == td.tactic, tag + " tactic_event_log equal")
		h.expect(not td.auto_on and td.controller.battle_result_state != "", tag + " the engine ended the battle and turned auto off: " + td.controller.battle_result_state)
		# Replay == events.
		var lab: Dictionary = td.lab
		h.expect(lab.played_paths == td.logs.ally_move_event_log.filter(func(e): return e.kind == "unit_moved").map(func(e): return e.path), tag + " every ally auto move replayed")
		h.expect(lab.damage == td.logs.battle_action_event_log.filter(func(e): return e.kind == "attack_resolved"), tag + " every ally auto attack shown")
		var events: Array = td.logs.enemy_action_event_log
		h.expect(lab.enemy_played_paths == events.filter(func(e): return e.kind == "enemy_moved").map(func(e): return e.path), tag + " every enemy move replayed")
		h.expect(lab.hits == events.filter(func(e): return e.kind == "enemy_attack_resolved"), tag + " every enemy hit shown")
		h.expect(lab.skill_presentations == h.ally_skill_events(td.tactic, sides), tag + " ally auto skills shown from the events")
		h.expect(lab.skill_texts == h.expected_display(h.ally_skill_events(td.tactic, sides), names).lines, tag + " ally auto skill lines")
		h.expect(lab.tactic_cursor == td.tactic.size() and lab.cursors == [td.logs.ally_move_event_log.size(), td.logs.battle_action_event_log.size(), events.size()], tag + " four cursors at their log ends")
		h.expect(lab.overlay[0] and lab.overlay[1] == {"victory":"승리","defeat":"패배"}[td.controller.battle_result_state], tag + " result overlay " + str(lab.overlay))
		h.expect(lab.auto_texts[-1].begins_with("자동 종료 · 엔진이 자동전투를 껐습니다"), tag + " auto end shown " + str(lab.auto_texts.slice(-1)))
		var quiet: Array = lab.auto_texts.filter(func(x): return x.begins_with("자동 · "))
		h.expect(quiet.all(func(x): return allies.any(func(id): return x == "자동 · %s 행동 완료 (대기 또는 혼란: 엔진 이벤트 없음)" % id)), tag + " quiet auto actions name allies only")
		h.expect(not quiet.is_empty(), tag + " the default auto battle has event-less ally actions (auto waits) and 3D shows them")
		print("[M5A_AUTO_CASE] ", tag, " result=", td.controller.battle_result_state, " round=", td.controller.battle_round, " writes=", td.writes.size(), " quiet=", quiet.size(), " ms=", Time.get_ticks_msec() - t0, " failures=", h.failures.size())
		if not h.failures.is_empty(): break
	print("[M5A_AUTO_EQUIVALENCE] checks=", h.checks, " display_checks=", h.display_checks, " failures=", h.failures)
	quit(0 if h.failures.is_empty() else 1)
