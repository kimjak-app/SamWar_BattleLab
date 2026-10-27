extends SceneTree
# HUD block 4-6b test 4: the command panel keeps clear of the selected unit's marker, on the scenario shell. For zoom 42,
# 30 and 20 and each of the default battle's three allies selected by a click on its cell (the harness hands it to the
# lab, so the open panel cannot take it): the panel's screen rect overlaps neither part of the selected marker (face chip
# + badges, bar + number, read from the nodes here). Control: with the avoidance off (the panel's avoid rects cleared
# before each placement) at least one case overlaps.
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

func marker_parts(m: Control) -> Array:
	var top: Rect2 = (m.get_node("Chip") as Control).get_global_rect()
	for badge in m.get_node("Badges").get_children():
		if badge.visible: top = top.merge(badge.get_global_rect())
	return [top, (m.get_node("BarBack") as Control).get_global_rect().merge(m.get_node("Troops").get_global_rect())]

func overlaps(r: Rect2, parts: Array) -> bool:
	return parts.any(func(p): return r.intersects(p))

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_scenario_harness.gd").new()
	await h.open_shell(self)
	root.size = Vector2i(1920, 1080)
	await h.press_scenario(self, "default")
	var lab = h.lab
	var b: Node = lab.engine
	for i in range(240): await process_frame
	lab.edge_scroll_enabled = false
	var panel = h.shell.command_panel
	var allies: Array = b.all_battle_unit_states.filter(func(u): return u.side == "ally" and lab.views[u.unit_id].visible).map(func(u): return u.unit_id)
	var cases := []
	for zoom in [42.0, 30.0, 20.0]:
		for id in allies:
			if is_instance_valid(h.shell.camera_tween): h.shell.camera_tween.kill()
			lab.zoom = zoom
			lab.focus = lab.views[id].position * Vector3(1, 0, 1)
			for i in range(3): await process_frame
			h.click(lab.display_values[id].grid_cell)
			for i in range(4): await process_frame
			if is_instance_valid(h.shell.camera_tween): h.shell.camera_tween.kill()
			lab.focus = lab.views[id].position * Vector3(1, 0, 1)
			for i in range(3): await process_frame
			var m: Control = lab.unit_markers.markers[id]
			var parts := marker_parts(m)
			var pr: Rect2 = panel.panel_rect()
			cases.append([zoom, id, b.active_unit_state.unit_id == id, panel.panel.visible, overlaps(pr, parts), panel.avoid_rects.size() == 2 and panel.avoid_rects[0].is_equal_approx(parts[0]) and panel.avoid_rects[1].is_equal_approx(parts[1])])
	var bad := cases.filter(func(c): return not (c[2] and c[3] and not c[4]))
	h.expect(cases.size() == 9 and bad.is_empty(), "zoom 42/30/20 x %s selected: panel clear of the selected marker [zoom, id, selected, panel open, overlaps, panel's avoid rect = marker rect] %s" % [str(allies), str(bad)])
	h.expect(cases.all(func(c): return c[5]), "the panel's avoid rects are the selected marker's own two parts %s" % str(cases.filter(func(c): return not c[5])))
	# Control: the same placements without the avoidance.
	var without := 0
	for c in cases:
		var id: String = c[1]
		lab.zoom = c[0]
		lab.focus = lab.views[id].position * Vector3(1, 0, 1)
		for i in range(3): await process_frame
		var keep: Array = panel.avoid_rects
		panel.avoid_rects = []
		var state: Dictionary = h.shell.command_state()
		var plain: Vector2 = panel.choose_position(state.get("anchor", Vector2.ZERO), panel.PANEL_SIZE, state.get("range_rects", []))
		panel.avoid_rects = keep
		if overlaps(Rect2(plain, panel.PANEL_SIZE), marker_parts(lab.unit_markers.markers[b.active_unit_state.unit_id])): without += 1
	h.expect(without > 0, "control: without the avoidance the panel covers the selected marker in %d of the cases" % without)
	lab.edge_scroll_enabled = true
	await h.close_shell(self)
	print("[BLOCK46B_PANEL] checks=", h.checks, " failures=", h.failures, " cases ", cases, " overlaps without avoidance ", without)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
