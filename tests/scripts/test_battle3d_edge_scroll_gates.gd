extends SceneTree
# HUD block 4-4 test 3: when the edge scroll does not run, each with its control (released -> it runs again), on the
# scenario shell with real mouse motion:
#   - a HUD control under the mouse: the command panel (a real HUD control, mouse STOP) dragged to the left edge (its
#     12 px margin is inside the 16 px band); the same band beside the panel scrolls;
#   - the option off: the option window's new check box clicked for real (and the window then closed); on again scrolls;
#   - input locked: the shell's option window open; the engine's full auto on (the lab's auto command); each released
#     scrolls again;
#   - the shell counts an edge scroll as the player's own camera input (this turn's centring stops: manual_camera_turn).
# "Scrolls" = the focus moves within 10 frames.
var h

func _initialize() -> void:
	run.call_deferred()

func push(at: Vector2, kind: String) -> void:
	var e: InputEvent
	if kind == "move":
		e = InputEventMouseMotion.new()
	else:
		e = InputEventMouseButton.new()
		e.button_index = MOUSE_BUTTON_LEFT
		e.pressed = kind == "down"
	e.position = at
	e.global_position = at
	root.push_input(e)
	await process_frame

func click_at(at: Vector2) -> void:
	await push(at, "move")
	await push(at, "down")
	await push(at, "up")

func scrolls(lab, at: Vector2) -> bool:
	lab.focus = Vector3(27, 0, 15) # the play area's middle: room to move every way
	await push(at, "move")
	var before: Vector3 = lab.focus
	for i in range(10): await process_frame
	return lab.focus != before

func settle(lab, b) -> void:
	for i in range(8000):
		await process_frame
		if b.is_demo_animating or lab._enemy_presentation_busy() or lab._presentation_busy(): continue
		if b.current_phase in ["ally_turn", "facing_select", "attack_select"] or not lab.battle_result.is_empty(): break
	for i in range(60): await process_frame

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_scenario_harness.gd").new()
	await h.open_shell(self)
	root.size = Vector2i(1920, 1080) # the game's window (project.godot), no stretch
	await h.press_scenario(self, "default")
	var lab = h.lab
	var b: Node = lab.engine
	await settle(lab, b)
	var size := Vector2(root.size)
	var left := Vector2(13, size.y * 0.5)
	h.expect(await scrolls(lab, left), "control: the left band scrolls with nothing over it")
	h.expect(h.shell.manual_camera_turn == h.shell.camera_turn_key() and not h.shell.camera_turn_key().is_empty(), "the edge scroll counts as manual camera input for this turn (%s)" % h.shell.manual_camera_turn)
	# A HUD control under the mouse: the command panel at the left edge.
	var panel = h.shell.command_panel
	h.expect(panel.panel.visible, "the command panel is open on the ally turn")
	panel.drag_key = str(h.shell.command_state().get("turn_key", ""))
	panel.drag_position = panel.clamp_position(Vector2(0, size.y * 0.5 - 100), panel.PANEL_SIZE, size)
	for i in range(3): await process_frame
	var rect: Rect2 = panel.panel_rect()
	var over := Vector2(13, rect.get_center().y)
	var beside := Vector2(13, rect.end.y + 40 if rect.end.y + 40 < size.y - 20 else rect.position.y - 40)
	h.expect(rect.position.x <= 13 and rect.has_point(over), "the panel reaches into the band (%s, mouse %s)" % [rect, over])
	var stays := not await scrolls(lab, over)
	h.expect(stays and root.gui_get_hovered_control() != null, "over the panel (a HUD control, hovered %s): no scroll" % root.gui_get_hovered_control())
	h.expect(await scrolls(lab, beside), "control: the band beside the panel (%s) scrolls" % beside)
	panel.drag_position = Vector2.INF
	# The option window: open = an input lock; its check box clicked off = the option off.
	h.shell.toggle_option_box()
	for i in range(3): await process_frame
	var check: CheckBox = lab.edge_scroll_check
	h.expect(check != null and check.is_visible_in_tree() and check.text == "화면 가장자리 스크롤" and check.button_pressed, "the option window shows the check box, on by default")
	h.expect(not await scrolls(lab, left), "input lock: the option window open, no scroll")
	await click_at(check.get_global_rect().get_center())
	h.expect(not check.button_pressed and not lab.edge_scroll_enabled, "the check box clicked off")
	h.shell.toggle_option_box()
	for i in range(3): await process_frame
	h.expect(not lab.option_toggle.get_parent().visible, "the option window closed")
	h.expect(not await scrolls(lab, left), "the option off: no scroll")
	lab.edge_scroll_enabled = true
	h.expect(await scrolls(lab, left), "control: the option on again scrolls")
	# Input locked by the engine's full auto.
	lab.request_auto()
	for i in range(3): await process_frame
	var auto_on: bool = b.is_full_auto_battle_enabled
	var auto_stays := not await scrolls(lab, left)
	h.expect(auto_on and auto_stays, "input lock: full auto on, no scroll (auto %s)" % auto_on)
	lab.request_auto()
	await settle(lab, b)
	var phase: String = b.current_phase
	h.expect(not b.is_full_auto_battle_enabled and phase in ["ally_turn", "facing_select", "attack_select"] and await scrolls(lab, left), "control: auto off, back on an ally turn, scrolls (phase %s)" % phase)
	lab.edge_scroll_enabled = true
	await h.close_shell(self)
	print("[EDGE_GATES] checks=", h.checks, " failures=", h.failures)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
