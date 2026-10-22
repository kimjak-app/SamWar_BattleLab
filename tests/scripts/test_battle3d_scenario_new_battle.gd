extends SceneTree
# M5-b: [다시 시작] starts the same scenario as a new battle with nothing left
# from the previous one: engine start print == a fresh engine start of that
# scenario, empty logs, 3D cursors / replay queue / pending lists at zero, auto
# off, hold false, Engine.time_scale 1.0 and the speed button at 1x, no setup
# meta. Three restarts: the first after a real result (win practice, 3D auto at
# 4x), the next two after a partly played battle (auto at 4x for a few steps).
var h

func _initialize() -> void:
	run.call_deferred()

func fresh_checks(tag: String, fresh: Dictionary) -> void:
	var lab = h.lab
	var b: Node = lab.engine
	var s: Dictionary = h.start_print(b)
	h.expect(h.fingerprint.diff(fresh.units, s.units).is_empty() and h.fingerprint.diff(fresh.controller, s.controller).is_empty() and s.logs == fresh.logs and s.momentum == fresh.momentum, tag + " start == fresh engine start")
	h.expect([lab.event_cursor, lab.action_cursor, lab.enemy_cursor, lab.tactic_cursor] == [0, 0, 0, 0] and lab.enemy_queue.is_empty() and lab.playback.is_empty() and lab.battle_result.is_empty(), tag + " 3D cursors and queues empty")
	h.expect(lab.pending_enemy_skills.is_empty() and lab.pending_enemy_strategies.is_empty() and lab.pending_enemy_ticks.is_empty() and lab.pending_arrivals.is_empty() and lab.auto_texts.is_empty(), tag + " pending lists empty")
	h.expect(not b.is_full_auto_battle_enabled and not b.auto_presentation_hold and not lab.auto_hold_sent and b.writes == fresh.writes and b.hold_calls.is_empty(), tag + " auto off, hold false, no write beyond the engine's own start")
	h.expect(Engine.time_scale == 1.0 and lab.speed_button.text == "속도 1x" and lab.auto_button.text == "자동 ▶", tag + " speed 1x, auto button ready")
	h.expect(not Engine.has_meta(h.SETUP_KEY) and not h.shell.result_panel.visible and not h.lab.result_overlay.visible, tag + " no meta, no overlay")

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_scenario_harness.gd").new()
	var fresh: Dictionary = await h.bare_start(self, h.ShellScript.scenario_setup("win_practice"))
	var before_nodes := Performance.get_monitor(Performance.OBJECT_NODE_COUNT)
	await h.open_shell(self)
	await h.press_scenario(self, "win_practice")
	fresh_checks("first start", fresh)
	for round_index in range(3):
		var old_lab = h.lab
		for i in range(2): h.lab.speed_button.pressed.emit()
		seed(round_index + 1)
		h.press_auto()
		if round_index == 0:
			for i in range(80000):
				await process_frame
				if h.shell.result_panel.visible: break
			h.expect(h.shell.result_panel.visible and h.shell.result_label.text.begins_with("승리"), "first battle ended: " + h.shell.result_label.text)
		else:
			for i in range(400): await process_frame
			h.expect(h.lab.engine.writes.size() >= 2 and h.lab.engine.auto_battle_step_count >= 2, "restart %d after a partly played battle (%d steps)" % [round_index + 1, h.lab.engine.auto_battle_step_count])
		await h.press_restart(self)
		h.expect(not is_instance_valid(old_lab) and h.shell.lab != old_lab and h.shell.scenario == "win_practice", "restart %d: old lab freed, same scenario" % (round_index + 1))
		fresh_checks("restart %d" % (round_index + 1), fresh)
	await h.close_shell(self)
	for i in range(3): await process_frame
	var leaked := Performance.get_monitor(Performance.OBJECT_NODE_COUNT) - before_nodes
	h.expect(leaked <= 0, "no node left after four battles and closing the shell (%d)" % leaked)
	print("[SCENARIO_NEW_BATTLE] nodes_delta=", leaked, " checks=", h.checks, " failures=", h.failures)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
