extends SceneTree
# M5-b: win practice played to the end with the 3D [자동] (4x, M5-a + the M5-a2
# hold) per seed. The engine ends the battle with a victory; the result overlay
# shows it with the round and alive allied units; the final engine state equals
# the engine's own auto with the same start setup and no 3D (units, controller,
# four logs, round 2/3 snapshots, write sequence). Run per seed (CI 120 s per file).
var h

func _initialize() -> void:
	run.call_deferred()

func seeds() -> Array:
	return [1, 2, 3]

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_scenario_harness.gd").new()
	for seed_value in seeds():
		var t0 := Time.get_ticks_msec()
		var setup: Dictionary = h.ShellScript.scenario_setup("win_practice")
		var direct: Dictionary = await h.engine_auto(self, seed_value, setup, 4.0)
		await h.open_shell(self)
		await h.press_scenario(self, "win_practice")
		var b: Node = h.lab.engine
		for i in range(2): h.lab.speed_button.pressed.emit()
		h.lab._sync_views()
		seed(seed_value)
		h.press_auto()
		for i in range(80000):
			await process_frame
			if h.shell.result_panel.visible: break
		var td: Dictionary = h.auto_final(b)
		var tag := "seed %d" % seed_value
		h.expect(direct.controller.battle_result_state == "victory", tag + " engine alone wins win practice: " + direct.controller.battle_result_state)
		h.expect(td.controller.battle_result_state == "victory" and not td.auto_on, tag + " 3D auto run ends in victory")
		h.expect(h.fingerprint.diff(direct.units, td.units).is_empty() and h.fingerprint.diff(direct.controller, td.controller).is_empty(), tag + " final units and controller == engine alone")
		for name in direct.logs: h.expect(direct.logs[name] == td.logs[name], tag + " " + name + " == engine alone")
		h.expect(direct.tactic == td.tactic and direct.writes == td.writes, tag + " tactic log and writes == engine alone")
		for r in [2, 3]:
			if direct.round_snaps.has(r): h.expect(td.round_snaps.has(r) and h.fingerprint.diff(direct.round_snaps[r], td.round_snaps[r]).is_empty(), tag + " round %d snapshot equal" % r)
		var want: String = h.expected_overlay(b, "victory")
		h.expect(h.shell.result_panel.visible and h.shell.result_label.text == want, tag + " overlay '%s' == '%s'" % [h.shell.result_label.text, want])
		h.expect(h.lab.result_overlay.text == "승리" and b.hold_calls.size() >= 2 and b.hold_calls[-1][0] == false, tag + " lab 승리, hold released")
		print("[SCENARIO_VICTORY] ", tag, " ", h.shell.result_label.text, " ms=", Time.get_ticks_msec() - t0)
		await h.close_shell(self)
		h.expect(Engine.time_scale == 1.0, tag + " speed restored")
	print("[SCENARIO_VICTORY] checks=", h.checks, " failures=", h.failures)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
