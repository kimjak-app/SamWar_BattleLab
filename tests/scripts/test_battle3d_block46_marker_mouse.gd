extends SceneTree
# HUD block 4-6 test 6: the unit markers let the mouse through, on the scenario shell.
#   - every Control under the markers' layer ignores the mouse;
#   - the mouse on each shown marker (its face chip and its bar): no hovered control, and the edge scroll gate is open
#     (it is closed only over a HUD control);
#   - a real click on a marker does what the same click does with the markers hidden (same engine writes, same lab
#     rejections and status): the marker never takes the click;
#   - the markers are drawn under the lab's UI and the HUD (layer 0).
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
	for i in range(3): await process_frame

func settle(lab, b) -> void:
	for i in range(8000):
		await process_frame
		if b.is_demo_animating or lab._enemy_presentation_busy() or lab._presentation_busy(): continue
		if b.current_phase in ["ally_turn", "facing_select", "attack_select"] or not lab.battle_result.is_empty(): break
	for i in range(30): await process_frame

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_scenario_harness.gd").new()
	await h.open_shell(self)
	root.size = Vector2i(1920, 1080)
	await h.press_scenario(self, "default")
	var lab = h.lab
	var b: Node = lab.engine
	await settle(lab, b)
	if is_instance_valid(h.shell.camera_tween): h.shell.camera_tween.kill()
	lab.edge_scroll_enabled = false # keep the camera still while the mouse moves over markers
	var markers = lab.unit_markers
	var all_controls: Array = markers.find_children("*", "Control", true, false)
	h.expect(not all_controls.is_empty() and all_controls.all(func(c): return c.mouse_filter == Control.MOUSE_FILTER_IGNORE), "%d marker controls, all MOUSE_FILTER_IGNORE" % all_controls.size())
	h.expect(markers.layer == 0 and markers.layer < h.shell.command_panel.layer and markers.layer < h.shell.ally_roster.layer, "markers on layer 0, under the HUD (panel %d, roster %d)" % [h.shell.command_panel.layer, h.shell.ally_roster.layer])
	lab.edge_scroll_enabled = true
	var hovered := []
	var gate := []
	var shown: Array = markers.markers.keys().filter(func(id): return markers.markers[id].visible)
	for id in shown:
		var m: Control = markers.markers[id]
		for part in ["Chip", "BarBack"]:
			var at: Vector2 = (m.get_node(part) as Control).get_global_rect().get_center()
			await push(at, "move")
			var over = root.gui_get_hovered_control()
			if over != null and markers.is_ancestor_of(over): hovered.append([id, part, over.name])
			if not lab._edge_scroll_allowed() and over == null: gate.append([id, part])
	lab.edge_scroll_enabled = false
	h.expect(shown.size() >= 4 and hovered.is_empty(), "%d shown markers: the mouse on a chip or bar hovers no marker control (%s)" % [shown.size(), str(hovered)])
	h.expect(gate.is_empty(), "the edge scroll gate stays open over markers (%s)" % str(gate))
	# A real click on an enemy marker, with and without the markers.
	var enemy := ""
	for id in shown:
		if b.all_battle_unit_states.any(func(u): return u.unit_id == id and u.side == "enemy"): enemy = id
	var at: Vector2 = (markers.markers[enemy].get_node("Chip") as Control).get_global_rect().get_center()
	var focus: Vector3 = lab.focus
	markers.visible = false
	var w0: int = b.writes.size()
	var r0: int = lab.rejected
	await click_at(at)
	var without := [b.writes.slice(w0), lab.rejected - r0, lab.status.text, b.current_phase]
	markers.visible = true
	lab.focus = focus
	for i in range(3): await process_frame
	w0 = b.writes.size()
	r0 = lab.rejected
	await click_at(at)
	var with := [b.writes.slice(w0), lab.rejected - r0, lab.status.text, b.current_phase]
	h.expect(not enemy.is_empty() and with == without, "a click on %s's marker = the same click without markers (%s / %s)" % [enemy, str(with), str(without)])
	lab.edge_scroll_enabled = true
	await h.close_shell(self)
	print("[BLOCK46_MOUSE] checks=", h.checks, " failures=", h.failures)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
