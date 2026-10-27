extends SceneTree
# HUD spike: the 2D top HUD copy (momentum diamonds, "round / 30") on the
# scenario shell. Expected values are built here from the engine: filled slots =
# the engine's momentum, label = "%d / 30" % battle_round. Default battle: start
# 3/3 1/30, three waits to round 2 (round-end gain), the HUD applies only on a
# value change and adds no engine write. HUD block 4-6: the lab's round/momentum text labels are debug text, hidden by
# default (checked first); with F3 on (a real key press, kept on for the rest) they are shown, moved by the shell to two
# lines right under the HUD frame, each
# as wide as its text and centred on the HUD (game window 1920x1080): never on
# the HUD and never on another visible lab or shell UI. Win practice played with [자동] to the result: every frame the HUD
# shows the lab's values and the labels stay clear; once the battle has a
# result the HUD is hidden like the 2D one and the labels still show.
var h
var hud

func _initialize() -> void:
	run.call_deferred()

func expect_engine_values(label: String) -> void:
	var b: Node = h.lab.engine
	for side in ["Ally", "Enemy"]:
		var value: int = b.battle_momentum.get_value(side.to_lower())
		var wrong := []
		for index in range(10):
			var slot: Panel = hud.slot_row(side).get_child(index).get_node("Slot%02d" % (index + 1))
			var kind := "Filled" if index < value else "Empty"
			var style = slot.get_meta("_diamond_%s_style" % kind.to_lower())
			if slot.theme_type_variation != StringName("MomentumSlot%s%s" % [side, kind]) or slot.get_theme_stylebox(&"panel") != style: wrong.append(index)
		h.expect(wrong.is_empty() and hud.slot_row(side).get_child_count() == 10, "%s: %s %d of 10 filled (wrong slots %s)" % [label, side, value, str(wrong)])
	var want := "%d / 30" % b.battle_round
	h.expect(hud.turn_label().text == want, "%s: turn '%s' == '%s'" % [label, hud.turn_label().text, want])

func other_ui_rects() -> Array:
	# Top-level visible controls of the lab's and the shell's canvas layers, except
	# the two moved labels and the lab's full-window result text. HUD block 4-6: the unit markers' layer is left out too:
	# the markers follow the units over the battlefield (like the 3D units under the labels), they are not UI panels.
	var out := []
	var layers: Array = h.lab.get_children().filter(func(n): return n is CanvasLayer and n != h.lab.unit_markers)
	layers.append(h.shell.layer)
	for layer in layers:
		for c in layer.get_children():
			if c is Control and c.is_visible_in_tree() and not [h.lab.turn_label, h.lab.momentum_label, h.lab.result_overlay].has(c):
				out.append([c.name if c.name != "" else c.get_class(), c.get_global_rect()])
	return out

var shifted_frames := 0

func info_panel_rect() -> Rect2:
	var c: Control = h.lab.info
	while not c.get_parent() is CanvasLayer: c = c.get_parent()
	return c.get_global_rect()

func label_problems() -> Array:
	var problems := []
	var frame: Rect2 = hud.frame_rect()
	var others := other_ui_rects()
	for label in [h.lab.turn_label, h.lab.momentum_label]:
		var r: Rect2 = label.get_global_rect()
		if not label.is_visible_in_tree(): problems.append("hidden")
		if r.intersects(frame): problems.append("on the HUD %s" % r)
		var info_right: float = info_panel_rect().end.x
		var centred: bool = is_equal_approx(r.get_center().x, frame.get_center().x)
		var shifted: bool = r.position.x >= info_right + 6.0 - 0.01 and r.get_center().x > frame.get_center().x # right of the panel (a shrink shows one frame later)
		if not (centred or shifted): problems.append("neither centred on the HUD nor right of the info panel %s" % r)
		if shifted: shifted_frames += 1
		for o in others:
			if r.intersects(o[1]): problems.append("%s overlaps %s %s" % [r, o[0], o[1]])
	return problems

func expect_labels_placed(tag: String) -> void:
	var frame: Rect2 = hud.frame_rect()
	var t: Rect2 = h.lab.turn_label.get_global_rect()
	var m: Rect2 = h.lab.momentum_label.get_global_rect()
	h.expect(is_equal_approx(t.position.y, frame.end.y + 6.0) and is_equal_approx(t.get_center().x, frame.get_center().x) and is_equal_approx(m.get_center().x, frame.get_center().x) and is_equal_approx(m.position.y, t.end.y + 2.0),
		"%s: labels centred right under the HUD frame %s (turn %s, momentum %s)" % [tag, frame, t, m])
	var problems := label_problems()
	h.expect(problems.is_empty(), "%s: labels visible, off the HUD and off other UI %s" % [tag, str(problems)])

func key(code: Key) -> void:
	var e := InputEventKey.new()
	e.keycode = code
	e.physical_keycode = code
	e.pressed = true
	root.push_input(e)
	await process_frame
	var up := e.duplicate()
	up.pressed = false
	root.push_input(up)
	for i in range(3): await process_frame

func settle(label: String) -> void:
	var stable := 0
	for i in range(6000):
		await process_frame
		var b: Node = h.lab.engine
		stable = stable + 1 if b.current_phase == "ally_turn" and not b.is_demo_animating and not h.lab._enemy_presentation_busy() else 0
		if stable >= 30: return
		if b.call("_get_battle_result_state") != "": break
	h.expect(false, label + " settled (back to an ally turn, battle not over)")

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_scenario_harness.gd").new()
	var plain: Dictionary = await h.bare_start(self, {})
	await h.open_shell(self)
	root.size = Vector2i(1920, 1080) # the game window (project.godot); the lab lays out its UI from it
	hud = h.shell.top_hud
	h.expect(hud.layer == 5 and h.shell.layer.layer == 10 and not hud.visible, "start screen: HUD (layer 5, under the shell's 10) hidden")
	await h.press_scenario(self, "default")
	for i in range(5): await process_frame
	var b: Node = h.lab.engine
	h.expect(hud.visible and b.battle_momentum.get_value("ally") == 3 and b.battle_momentum.get_value("enemy") == 3 and b.battle_round == 1, "default started: HUD shown, engine 3/3 round 1")
	expect_engine_values("start")
	h.expect(b.writes == plain.writes, "before any input: writes == an engine started alone %s" % str(b.writes))
	# HUD block 4-6: hidden by default (the HUD shows the same); F3 shows them, and the placement checks below run with F3 on.
	h.expect(not h.lab.debug_text_visible and not h.lab.turn_label.is_visible_in_tree() and not h.lab.momentum_label.is_visible_in_tree() and not h.lab.turn_label.text.is_empty() and not h.lab.momentum_label.text.is_empty(),
		"default: the turn / momentum lines hidden, texts kept ('%s' / '%s')" % [h.lab.turn_label.text, h.lab.momentum_label.text])
	await key(KEY_F3)
	h.expect(h.lab.debug_text_visible and h.lab.turn_label.is_visible_in_tree() and h.lab.momentum_label.is_visible_in_tree(), "F3: the turn / momentum lines shown")
	expect_labels_placed("start")
	# Only a value change re-applies; idle frames add no engine write.
	var applies: int = hud.apply_count
	var writes: Array = b.writes.duplicate()
	for i in range(30): await process_frame
	h.expect(hud.apply_count == applies and b.writes == writes, "30 idle frames: no re-apply (%d), no engine write" % hud.apply_count)
	# A wide info panel (as with a long status list): the labels move right of it.
	# Test-only: the lab rewrites the info text every frame, so the width is forced instead, then restored.
	var info_min: Vector2 = h.lab.info.custom_minimum_size
	h.shell._lab_info_box().visible = true # block 4-2 hides the box; shown for this check only (a hidden container keeps its old size)
	h.lab.info.custom_minimum_size.x = 820.0
	for i in range(3): await process_frame
	var wide_right: float = info_panel_rect().end.x
	var wide_problems := label_problems()
	h.expect(wide_right > h.lab.turn_label.get_global_rect().get_center().x - 400.0 and wide_problems.is_empty() and h.lab.turn_label.get_global_rect().position.x >= wide_right + 6.0 - 0.01,
		"wide info panel (right edge %s): labels shifted right of it %s %s" % [wide_right, h.lab.turn_label.get_global_rect(), str(wide_problems)])
	h.lab.info.custom_minimum_size = info_min
	for i in range(3): await process_frame
	h.shell._lab_info_box().visible = false # hidden again once it is back to its normal size
	await process_frame
	h.expect(is_equal_approx(h.lab.turn_label.get_global_rect().get_center().x, hud.frame_rect().get_center().x), "info panel back to normal: labels centred again")
	# The lab's original place (centre top) is under the HUD: the shell moved them.
	h.expect(not hud.frame_rect().intersects(h.lab.turn_label.get_global_rect()) and h.lab.turn_label.text.begins_with("라운드 1 · 아군 턴"), "turn label moved off the HUD, text unchanged '%s'" % h.lab.turn_label.text)
	# Three waits: the round ends, both sides gain, the HUD follows after the enemy replay.
	for step in range(3):
		var active = b.active_unit_state
		if active == null or active.side != "ally":
			h.expect(false, "wait %d: the engine offers an ally" % step)
			await finish()
			return
		h.click(active.grid_cell)
		h.lab._sync_views()
		h.press_wait()
		await settle("wait %d" % step)
	h.expect(b.battle_round == 2 and h.lab.current_round == 2, "round 2 reached")
	h.expect(b.battle_momentum.get_value("ally") > 3, "ally momentum rose at the round end: %d" % b.battle_momentum.get_value("ally"))
	expect_engine_values("round 2")
	var three_waits: Array = b.writes.duplicate()
	h.expect(three_waits.count("_end_ally_turn_by_wait") == 3, "writes are the lab's own commands only " + str(three_waits))
	# Win practice with [자동] to the result.
	h.shell.choose_button.pressed.emit()
	await process_frame
	h.expect(not hud.visible, "[시나리오 선택]: HUD hidden")
	await h.press_scenario(self, "win_practice")
	b = h.lab.engine
	for i in range(2): h.lab.speed_button.pressed.emit()
	h.lab._sync_views()
	seed(1)
	h.press_auto()
	expect_labels_placed("win practice start (a new lab)")
	var mismatched := 0
	var label_bad := 0
	var label_first := []
	var min_left := 99999.0
	var max_info_right := 0.0
	var enemy_frames := 0
	var ally_rises := 0
	var last_ally := 3
	for i in range(80000):
		await process_frame
		if hud.visible:
			var want := {"Ally":h.lab.momentum_display.ally, "Enemy":h.lab.momentum_display.enemy, "round":h.lab.current_round}
			if hud.shown != want or hud.filled_count("Ally") != mini(want.Ally, 10) or hud.filled_count("Enemy") != mini(want.Enemy, 10): mismatched += 1
			if want.Ally > last_ally: ally_rises += 1
			last_ally = want.Ally
		var problems := label_problems()
		if not problems.is_empty():
			label_bad += 1
			if label_first.is_empty(): label_first = problems
		if h.lab.turn_label.text.contains("적 턴"): enemy_frames += 1
		min_left = minf(min_left, minf(h.lab.turn_label.get_global_rect().position.x, h.lab.momentum_label.get_global_rect().position.x))
		max_info_right = maxf(max_info_right, info_panel_rect().end.x)
		if h.shell.result_panel.visible: break
	h.expect(h.shell.result_panel.visible and b.call("_get_battle_result_state") == "victory", "win practice ends in victory")
	h.expect(mismatched == 0 and ally_rises > 0, "every shown frame matched the lab's values (mismatches %d, ally rises %d)" % [mismatched, ally_rises])
	h.expect(label_bad == 0 and enemy_frames > 0, "every frame of the battle: labels clear (bad frames %d, first %s, enemy-turn frames %d)" % [label_bad, str(label_first), enemy_frames])
	h.expect(not hud.visible and h.lab.turn_label.text.contains("전투 종료") and label_problems().is_empty(), "battle result: HUD hidden (like 2D), '%s' shown clear of the result panel" % h.lab.turn_label.text)
	print("[TOP_HUD] labels min_left=", min_left, " info_panel max_right=", max_info_right, " shifted label-frames=", shifted_frames)
	print("[TOP_HUD] applies=", hud.apply_count, " writes_default=", three_waits.size(), " ally_rises=", ally_rises)
	await finish()

func finish() -> void:
	h.lab.debug_text_visible = false # the F3 state is per session; back to the default for the next test
	await h.close_shell(self)
	print("[TOP_HUD] checks=", h.checks, " failures=", h.failures)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	hud = null
	await process_frame
	quit(code)
