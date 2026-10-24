extends SceneTree
# HUD block 2: the 2D battle log panel on the scenario shell (game window
# 1920x1080). Expected text is built here from the engine's own array:
# "\n".join(engine.battle_log_lines) (the 2D join). Checks:
#   - start: the panel at the 2D rect, its text = the engine's lines;
#   - four-line limit: five lines through the engine's own _append_battle_log ->
#     the engine keeps the last four and the panel shows exactly those (the
#     oldest one gone), and a new line changes the panel text;
#   - the read is read-only: engine state (units, controller, four logs,
#     momentum, writes) is the same before and after many reads, and changing
#     the returned copy does not change the engine's array;
#   - every frame of an ally wait and the enemy slots after it: panel = the
#     engine lines of this frame or a state the engine passed through since
#     the previous check (the engine appends in tween/timer callbacks, which
#     run after the panel's _process: that one-frame lag is counted; any other
#     text is wrong); how far the panel runs ahead of
#     the 3D enemy replay is measured (frames), not judged;
#   - the panel clear of the lab's visible UI; hidden with the HUD after the
#     battle result (like the 2D) and on the start screen.
var h
var log_hud

func _initialize() -> void:
	run.call_deferred()

func want(b: Node) -> String:
	return "\n".join(b.battle_log_lines)

func between(shown_text: String, prev: Array, cur: Array) -> bool:
	# The panel shows an engine state from between two checks: a window of at most
	# four lines of the append sequence from `prev` to `cur` (lines only append, oldest dropped).
	var shown: Array = [] if shown_text == "" else Array(shown_text.split("\n"))
	var k := mini(prev.size(), cur.size())
	while k > 0 and prev.slice(prev.size() - k) != cur.slice(0, k): k -= 1
	var sequence: Array = prev + cur.slice(k)
	for end in range(prev.size(), sequence.size() + 1):
		if sequence.slice(maxi(0, end - 4), end) == shown: return true
	return false

func engine_print(b: Node) -> Dictionary:
	var p: Dictionary = h.start_print(b)
	p["writes"] = b.writes.duplicate()
	p["log"] = b.battle_log_lines.duplicate()
	p["phase"] = b.current_phase
	return p

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_scenario_harness.gd").new()
	await h.open_shell(self)
	root.size = Vector2i(1920, 1080)
	log_hud = h.shell.log_hud
	h.expect(not log_hud.visible, "start screen: log panel hidden")
	await h.press_scenario(self, "default")
	for i in range(5): await process_frame
	var lab = h.lab
	var b: Node = lab.engine
	h.expect(log_hud.visible and log_hud.panel_rect() == Rect2(39, 793, 262, 262), "panel at the 2D rect 39..301 x 793..1055: %s" % log_hud.panel_rect())
	h.expect(log_hud.log_label().text == want(b), "start: panel = engine lines '%s'" % want(b).replace("\n", " / "))
	# Clear of the lab's visible top-level UI.
	var hits := []
	for layer in lab.get_children().filter(func(n): return n is CanvasLayer):
		for c in layer.get_children():
			if c is Control and c.is_visible_in_tree() and c != lab.result_overlay and c.get_global_rect().intersects(log_hud.panel_rect()): hits.append([str(c.name), c.get_global_rect()])
	h.expect(hits.is_empty(), "panel clear of the lab UI %s" % str(hits))
	# Read only.
	var before := engine_print(b)
	var copy: Array = []
	for i in range(100): copy = lab.read_battle_log_lines()
	copy.append("바뀐 줄")
	if copy.size() > 0: copy[0] = "덮어쓴 줄"
	h.expect(engine_print(b) == before, "100 reads + a changed copy: engine state unchanged")
	h.expect(b.battle_log_lines.size() <= 4 and not b.battle_log_lines.has("바뀐 줄") and not b.battle_log_lines.has("덮어쓴 줄"), "the engine array is not the returned copy")
	# Four-line limit through the engine's own append.
	for n in range(1, 6):
		b.call("_append_battle_log", "시험 줄 %d" % n)
		await process_frame
		await process_frame
		h.expect(log_hud.log_label().text == want(b), "after line %d: panel = engine '%s'" % [n, want(b).replace("\n", " / ")])
	h.expect(Array(b.battle_log_lines) == ["시험 줄 2", "시험 줄 3", "시험 줄 4", "시험 줄 5"] and log_hud.log_label().text == "시험 줄 2\n시험 줄 3\n시험 줄 4\n시험 줄 5", "five lines: the oldest dropped, the panel shows the last four")
	var applies: int = log_hud.apply_count
	for i in range(20): await process_frame
	h.expect(log_hud.apply_count == applies, "no change: no re-apply")
	# Every frame of an ally wait and the enemy slots: panel = engine; measure the lead over the replay.
	var active: BattleUnitState = b.active_unit_state
	h.click(active.grid_cell)
	lab._sync_views()
	var frame := 0
	var mismatched := 0
	var lagged := 0
	var first_enemy_line_frame := -1
	var first_replay_frame := -1
	var replay_done_frame := -1
	var lines_before: Array = b.battle_log_lines.duplicate()
	var replays_before: int = lab.enemy_texts.size()
	var log_changes := []
	var last: Array = b.battle_log_lines.duplicate()
	h.press_wait()
	for i in range(6000):
		await process_frame
		frame += 1
		var shown_text: String = log_hud.log_label().text
		var now: Array = b.battle_log_lines.duplicate()
		if shown_text != want(b):
			if between(shown_text, last, now): lagged += 1
			else: mismatched += 1
		if now != last:
			log_changes.append([frame, now.back()])
			last = now
		if first_enemy_line_frame < 0 and b.enemy_action_event_log.export().size() > 0 and now != lines_before and (b.current_phase == "enemy_turn" or lab._enemy_presentation_busy()): first_enemy_line_frame = frame
		if first_replay_frame < 0 and lab.enemy_texts.size() > replays_before: first_replay_frame = frame
		if first_replay_frame >= 0 and replay_done_frame < 0 and not lab._enemy_presentation_busy() and b.current_phase == "ally_turn" and not b.is_demo_animating: replay_done_frame = frame
		if replay_done_frame >= 0 and frame > replay_done_frame + 30: break
	h.expect(mismatched == 0, "every frame of the wait and enemy slots: panel = engine lines of this or the previous frame (wrong %d, one-frame lag %d)" % [mismatched, lagged])
	print("[LOG_HUD] timing frames: first log change after wait=", log_changes[0][0] if not log_changes.is_empty() else -1, " first enemy-phase log line=", first_enemy_line_frame,
		" first 3D enemy replay text=", first_replay_frame, " replay done=", replay_done_frame, " log changes=", log_changes.size(), " one-frame lag frames=", lagged)
	print("[LOG_HUD] log changes (frame, newest line): ", log_changes)
	h.expect(not log_changes.is_empty(), "the wait and enemy slots wrote log lines")
	# After the result: hidden with the HUD (like the 2D).
	h.shell.choose_button.pressed.emit()
	await process_frame
	await h.press_scenario(self, "win_practice")
	b = h.lab.engine
	for i in range(2): h.lab.speed_button.pressed.emit()
	h.lab._sync_views()
	seed(1)
	var auto_prev: Array = b.battle_log_lines.duplicate() # before the press: the engine appends "자동전투 시작" inside it
	h.press_auto()
	var auto_mismatched := 0
	var auto_lagged := 0
	var auto_frames := 0
	for i in range(80000):
		await process_frame
		var cur: Array = b.battle_log_lines.duplicate()
		if log_hud.visible:
			auto_frames += 1
			var t: String = log_hud.log_label().text
			if t != want(b):
				if between(t, auto_prev, cur): auto_lagged += 1
				else:
					auto_mismatched += 1
					print("[LOG_HUD] auto wrong frame ", auto_frames, " shown=", JSON.stringify(t), " prev=", auto_prev, " cur=", cur, " phase=", b.current_phase, " result=", h.lab.battle_result)
		auto_prev = cur
		if h.shell.result_panel.visible: break
	h.expect(h.shell.result_panel.visible and auto_mismatched == 0 and not log_hud.visible, "win practice [자동]: panel = engine (this or previous frame) on every shown frame (wrong %d, one-frame lag %d of %d), hidden after the result" % [auto_mismatched, auto_lagged, auto_frames])
	print("[LOG_HUD] auto: shown frames=", auto_frames, " one-frame lag frames=", auto_lagged, " wrong=", auto_mismatched)
	await h.close_shell(self)
	print("[LOG_HUD] checks=", h.checks, " failures=", h.failures)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	log_hud = null
	await process_frame
	quit(code)
