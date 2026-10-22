extends SceneTree
# M5-c: [중] on the 3D option panel, then the 3D [자동] (4x, hold) until the end,
# equals the engine with set_enemy_ai_level("mid") called at the same point
# (before the auto toggle) and its own auto without 3D: final units,
# controller, four logs, round 2/3 snapshots, write sequence. Seed 1.
var h

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_option_harness.gd").new()
	# Engine alone.
	var host = await h.open_option_bare(self)
	var b: Node = host.battle
	Engine.time_scale = 4.0
	seed(1)
	b.call("set_enemy_ai_level", "mid")
	b.call("_toggle_full_auto_battle")
	for i in range(60000):
		await process_frame
		if b.call("_get_battle_result_state") != "": break
	for i in range(60): await process_frame
	Engine.time_scale = 1.0
	var direct: Dictionary = h.auto_final(b)
	await h.close_bare(self, host)
	# 3D.
	await h.open_lab(self)
	b = h.lab.engine
	for i in range(2): h.lab.speed_button.pressed.emit()
	seed(1)
	await h.push_click(self, h.lab.ai_level_buttons.mid)
	h.press_auto()
	for i in range(80000):
		await process_frame
		if b.call("_get_battle_result_state") != "" and not h.lab._enemy_presentation_busy(): break
	for i in range(60): await process_frame
	var td: Dictionary = h.auto_final(b)
	h.expect(b.get_enemy_ai_level() == "mid" and h.lab.ai_level_label.text == h.expected_level_text("mid", ""), "3D shows 중 applied")
	await h.close_lab(self)
	h.expect(direct.writes == td.writes, "same write sequence (%d)" % td.writes.size())
	h.expect(h.fingerprint.diff(direct.units, td.units).is_empty() and h.fingerprint.diff(direct.controller, td.controller).is_empty(), "final units and controller equal")
	for name in direct.logs: h.expect(direct.logs[name] == td.logs[name], name + " equal")
	h.expect(direct.tactic == td.tactic, "tactic log equal")
	for r in [2, 3]: h.expect(direct.round_snaps.has(r) and td.round_snaps.has(r) and h.fingerprint.diff(direct.round_snaps[r], td.round_snaps[r]).is_empty(), "round %d snapshot equal" % r)
	var skills: Array = td.logs.enemy_action_event_log.filter(func(e): return e.kind == "enemy_skill_used").map(func(e): return e.unit_id)
	print("[OPTION_AI_LEVEL_AUTO] result=", td.controller.battle_result_state, " round=", td.controller.battle_round, " enemy_skills=", skills)
	print("[OPTION_AI_LEVEL_AUTO] checks=", h.checks, " failures=", h.failures)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
