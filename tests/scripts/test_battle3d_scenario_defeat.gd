extends SceneTree
# M5-b: default scenario, every ally turn ended with the 3D [대기] button until
# the engine ends the battle (seed 1; defeat at round 6 measured before). The
# result overlay shows the engine result, round and alive allied units; every
# input stays locked and battle command clicks after the result send no engine
# write; the final engine state equals the engine alone (wait every turn).
var h

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_scenario_harness.gd").new()
	var direct: Dictionary = await h.engine_all_wait(self, 1)
	await h.open_shell(self)
	await h.press_scenario(self, "default")
	var b: Node = h.lab.engine
	Engine.time_scale = 4.0 # test speed; the lab's speed button is not used here
	seed(1)
	for i in range(60000):
		await process_frame
		if not h.lab.battle_result.is_empty(): break
		if b.current_phase == "ally_turn" and not b.is_demo_animating and not h.lab._enemy_presentation_busy() and not h.lab.wait_button.disabled:
			h.lab.wait_button.pressed.emit()
	for i in range(2400):
		await process_frame
		if h.shell.result_panel.visible and not b.is_demo_animating: break
	await h.settle_engine(self, b)
	Engine.time_scale = 1.0
	var td: Dictionary = h.auto_final(b)
	h.expect(td.controller.battle_result_state == "defeat" and b.battle_round == 6, "defeat at round %d" % b.battle_round)
	h.expect(direct.controller.battle_result_state == "defeat", "engine alone: defeat")
	h.expect(h.fingerprint.diff(direct.units, td.units).is_empty() and h.fingerprint.diff(direct.controller, td.controller).is_empty(), "final units and controller == engine alone")
	for name in direct.logs: h.expect(direct.logs[name] == td.logs[name], name + " == engine alone")
	h.expect(direct.tactic == td.tactic and direct.writes == td.writes, "tactic log and write sequence == engine alone (%d writes)" % td.writes.size())
	h.expect(td.writes.all(func(w): return w in ["_end_ally_turn_by_wait", "_select_ally_unit"]) and td.writes.count("_end_ally_turn_by_wait") == td.writes.count("_select_ally_unit"), "only waits (plus the engine's own ally selection before each)")
	# Overlay.
	var want: String = h.expected_overlay(b, "defeat")
	h.expect(h.shell.result_panel.visible and h.shell.result_label.text == want and h.shell.result_text == want, "overlay '%s' == '%s'" % [h.shell.result_label.text, want])
	h.expect(h.lab.result_overlay.visible and h.lab.result_overlay.text == "패배", "lab result label 패배")
	h.expect(h.shell.restart_button.text == "다시 시작" and h.shell.choose_button.text == "시나리오 선택" and h.shell.restart_button.visible and h.shell.choose_button.visible, "two buttons")
	# Locked: battle commands after the result send nothing.
	var writes_before: int = b.writes.size()
	for button in [h.lab.attack_button, h.lab.wait_button, h.lab.defend_button, h.lab.strategy_button, h.lab.skill_button, h.lab.auto_button]: button.pressed.emit()
	h.lab.request_wait()
	h.lab.request_attack()
	h.lab.request_auto()
	h.click(h.roles(b).ally.grid_cell)
	await process_frame
	h.expect(b.writes.size() == writes_before and b.hold_calls.is_empty(), "after the result: no engine write (%d -> %d)" % [writes_before, b.writes.size()])
	h.expect(h.lab._input_locked(), "inputs locked")
	await h.close_shell(self)
	print("[SCENARIO_DEFEAT] checks=", h.checks, " failures=", h.failures)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
