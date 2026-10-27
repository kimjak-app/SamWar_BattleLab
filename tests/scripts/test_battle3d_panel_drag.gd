extends SceneTree
# HUD block 4-3 item 4: dragging the command panel by its background. Real mouse events only. Checks: the panel
# follows a drag by its background (the margin left of the buttons), stays inside the screen (clamped with the 2D
# 12 px margin), no engine write while dragging, the buttons still work after it, a cell click outside the moved
# panel reaches the world, and the next ally turn puts the panel back to its automatic place.
var h

func _initialize() -> void:
	run.call_deferred()

func settle(lab, b) -> void:
	for i in range(8000):
		await process_frame
		if b.is_demo_animating or lab._enemy_presentation_busy() or lab._presentation_busy(): continue
		if b.current_phase in ["ally_turn", "facing_select", "attack_select"] or not lab.battle_result.is_empty(): break
	for i in range(3): await process_frame

func push(at: Vector2, kind: String, button := MOUSE_BUTTON_LEFT) -> void:
	var e: InputEvent
	if kind == "move":
		e = InputEventMouseMotion.new()
		e.button_mask = MOUSE_BUTTON_MASK_LEFT
	else:
		e = InputEventMouseButton.new()
		e.button_index = button
		e.pressed = kind == "down"
		e.button_mask = MOUSE_BUTTON_MASK_LEFT if kind == "down" else 0
	e.position = at
	e.global_position = at
	root.push_input(e)
	await process_frame

func drag(from: Vector2, to: Vector2, steps := 6) -> void:
	await push(from, "move")
	await push(from, "down")
	for i in range(1, steps + 1): await push(from.lerp(to, float(i) / steps), "move")
	await push(to, "up")

func click_at(at: Vector2, button := MOUSE_BUTTON_LEFT) -> void:
	var e := InputEventMouseMotion.new()
	e.position = at
	e.global_position = at
	root.push_input(e)
	await process_frame
	await push(at, "down", button)
	await push(at, "up", button)

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_scenario_harness.gd").new()
	await h.open_shell(self)
	root.size = Vector2i(1920, 1080)
	await h.press_scenario(self, "default")
	var lab = h.lab
	var b: Node = lab.engine
	await settle(lab, b)
	var settle_start := Time.get_ticks_msec()
	while Time.get_ticks_msec() - settle_start < 600: await process_frame # the 0.35 s camera centring ends
	var panel = h.shell.command_panel
	h.expect(panel.panel.visible, "panel open at the start")
	var start: Rect2 = panel.panel_rect()
	var grip := start.position + Vector2(5, 100) # the 12 px margin left of the buttons
	var writes: Array = b.writes.duplicate()
	var delta := Vector2(-250, 120)
	await drag(grip, grip + delta)
	for i in range(2): await process_frame
	var moved: Rect2 = panel.panel_rect()
	h.expect(moved.position.is_equal_approx(start.position + delta) and b.writes.size() == writes.size(), "a background drag by %s moves the panel %s -> %s; no engine write" % [delta, start.position, moved.position])
	# Clamp: far past the bottom-right corner.
	await drag(moved.position + Vector2(5, 100), moved.position + Vector2(5, 100) + Vector2(3000, 3000))
	for i in range(2): await process_frame
	var view := root.get_visible_rect().size
	var clamped: Vector2 = panel.panel_rect().position
	h.expect(clamped.is_equal_approx(view - panel.PANEL_SIZE - Vector2(12, 12)) and b.writes.size() == writes.size(), "dragged off screen: clamped to %s (view %s, 12 px margin); no engine write" % [clamped, view])
	# The dragged position holds during this turn while the state changes (a move-range selection).
	var u = b.active_unit_state
	await click_at(lab.camera.unproject_position(lab.board.world(u.grid_cell)))
	for i in range(3): await process_frame
	h.expect(panel.panel_rect().position.is_equal_approx(clamped), "after a selection in the same turn the panel stays where it was dragged (%s)" % panel.panel_rect().position)
	# Buttons still work: [기본공격] by a real click, then cancel.
	writes = b.writes.duplicate()
	await click_at(panel.button_at(0).get_global_rect().get_center())
	h.expect(b.writes.slice(writes.size()).slice(0, 1) == ["try_basic_attack"] and b.current_phase == "attack_select", "after dragging, a real click on [기본공격] still sends try_basic_attack (%s)" % b.writes.slice(writes.size()))
	await click_at(Vector2(960, 540), MOUSE_BUTTON_RIGHT)
	for i in range(3): await process_frame
	# A cell click outside the moved panel reaches the world (a move).
	var target = null
	for c in lab.queries.query(u.unit_id, u.grid_cell).get("reachable", {}).keys():
		var p: Vector2 = lab.camera.unproject_position(lab.board.world(c))
		if c != u.grid_cell and b.all_battle_unit_states.all(func(x): return x.grid_cell != c) and not panel.panel_rect().grow(4).has_point(p) and root.get_visible_rect().has_point(p):
			target = c
			break
	await click_at(lab.camera.unproject_position(lab.board.world(u.grid_cell)))
	await click_at(lab.camera.unproject_position(lab.board.world(target)))
	var waited := 0
	while b.current_phase != "facing_select" and waited < 3000:
		await process_frame
		waited += 1
	h.expect(b.current_phase == "facing_select", "a real click on a cell outside the dragged panel moves the unit (%s)" % b.current_phase)
	while not panel.arrows.visible and waited < 3000:
		await process_frame
		waited += 1
	var arrow_dir: String = ["right", "left", "up", "down"].filter(func(d): return panel.arrow_for(d).visible)[0]
	var arrow: Button = panel.arrow_for(arrow_dir)
	await click_at(arrow.position + (arrow.corners[0] + arrow.corners[1] + arrow.corners[2] + arrow.corners[3]) * 0.25)
	for i in range(3): await process_frame
	h.expect(b.current_phase == "ally_turn" and panel.panel.visible and panel.panel_rect().position.is_equal_approx(clamped),
		"facing confirmed by the %s arrow; the panel is back where it was dragged in this turn (%s, %s)" % [arrow_dir, b.current_phase, panel.panel_rect().position])
	# Next ally turn: automatic placement again.
	await click_at(panel.button_at(4).get_global_rect().get_center()) # [대기]
	await settle(lab, b)
	settle_start = Time.get_ticks_msec()
	while Time.get_ticks_msec() - settle_start < 600: await process_frame
	h.expect(b.active_unit_state != u and panel.panel.visible and not panel.panel_rect().position.is_equal_approx(clamped) and panel.drag_position == Vector2.INF,
		"the next ally turn (%s) places the panel automatically again (%s)" % [b.active_unit_state.unit_id, panel.panel_rect().position])
	await h.close_shell(self)
	print("[DRAG] checks=", h.checks, " failures=", h.failures)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
