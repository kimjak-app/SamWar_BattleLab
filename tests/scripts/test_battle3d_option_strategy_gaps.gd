extends SceneTree
# NIGHT3 test gaps (M5-c option panel, M4-e enemy strategy replay).
# G8: a level request before the lab is ready sends no engine write.
# G9: while a level is pending, the pressed button is the pending one.
# G10: the "적 책략 사용" line holds the replay (enemy_hold) before the next line.
# G11 (no-move form): the strategy outcome is shown with the slot's completion,
# in a later frame than the strategy line. The engine has no "move then
# strategy" path (strategy only from the current cell, before moving), so the
# literal after-move fixture cannot be built without a product change.
var h
var hs

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_option_harness.gd").new()
	# G8: request before ready.
	root.size = Vector2i(1280,800)
	var lab = load("res://scenes/battle3d/Battle3D_EnginePlayLab.tscn").instantiate()
	lab.host.free()
	lab.host = h.OptionHost.new()
	root.add_child(lab)
	var early_ready: bool = lab.ready_for_input
	var writes_before: int = lab.engine.writes.size()
	lab.request_ai_level("mid")
	h.expect(not early_ready and lab.engine.writes.size() == writes_before and lab.engine.get_pending_enemy_ai_level() == "", "G8 before ready: no engine write, nothing pending")
	while not lab.ready_for_input: await process_frame
	await physics_frame
	h.lab = lab
	# G9: pending shown.
	await h.push_click(self, lab.ai_level_buttons.mid)
	lab._sync_views()
	h.expect(lab.engine.get_enemy_ai_level() == "low" and lab.engine.get_pending_enemy_ai_level() == "mid", "G9 fixture: current low, pending mid")
	h.expect(lab.ai_level_buttons.mid.button_pressed and not lab.ai_level_buttons.low.button_pressed and not lab.ai_level_buttons.high.button_pressed, "G9 the pending level's button is the pressed one")
	await h.close_lab(self)

	# G10 / G11: enemy strategy replay frames.
	hs = load("res://tests/scripts/support/battle3d_enemy_strategy_harness.gd").new()
	await hs.open_lab(self)
	hs.strategy_fixture({"success":true})
	await process_frame
	var slab = hs.lab
	slab.wait_button.pressed.emit()
	var line_frame := -1
	var line_is_last := false
	var hold_at_line := 0.0
	var outcome_frame := -1
	for f in range(4000):
		await process_frame
		var strategy_index: int = slab.enemy_texts.find(slab.enemy_texts.filter(func(x): return x.begins_with("적 책략 사용"))[0]) if slab.enemy_texts.any(func(x): return x.begins_with("적 책략 사용")) else -1
		if line_frame < 0 and strategy_index >= 0:
			line_frame = f
			line_is_last = strategy_index == slab.enemy_texts.size() - 1
			hold_at_line = slab.enemy_hold
		if outcome_frame < 0 and slab.tactic_texts.any(func(x): return x.begins_with("적 책략")): outcome_frame = f
		if slab.engine.current_phase == "ally_turn" and not slab._presentation_busy() and outcome_frame >= 0: break
	hs.expect(line_frame >= 0 and line_is_last and hold_at_line > 0.0, "G10 the strategy line holds the replay (last line in its frame, enemy_hold %.2f)" % hold_at_line)
	hs.expect(outcome_frame > line_frame and line_frame >= 0, "G11 the outcome appears after the strategy line (frames %d -> %d), with the slot's completion" % [line_frame, outcome_frame])
	await hs.close_lab(self)

	print("[OPTION_STRATEGY_GAPS] checks=", h.checks + hs.checks, " failures=", h.failures + hs.failures)
	var code := 0 if (h.failures + hs.failures).is_empty() else 1
	h = null
	hs = null
	await process_frame
	quit(code)
