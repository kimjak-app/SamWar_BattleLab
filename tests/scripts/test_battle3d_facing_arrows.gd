extends SceneTree
# HUD block 4-3 item 3: the facing arrows under any camera turn. Expected values come from the lab camera's
# projection here, not from the shell. At yaw 0, 0.32, pi/2, pi, 3pi/2 (near):
#   (a) each arrow's tile centre is within 3 px of its neighbour cell's projected centre;
#   (b) the arrow's direction is within 5 degrees of the projected vector unit cell -> neighbour cell;
#   (c) a real mouse click on each arrow passes that arrow's direction (recorded instead of the lab's
#       confirm_facing, so all four can be clicked in one facing phase), a click inside the tile's bounding box but
#       outside its diamond is not that arrow's; one real click per yaw goes to the lab and the engine's facing is it.
const DIRS := ["up", "down", "left", "right"]
const OFFSETS := {"up":Vector2i(0, -1), "down":Vector2i(0, 1), "left":Vector2i(-1, 0), "right":Vector2i(1, 0)}
const YAWS := [0.0, 0.32, PI / 2, PI, 3 * PI / 2]
var h

func _initialize() -> void:
	run.call_deferred()

func settle(lab, b) -> void:
	for i in range(8000):
		await process_frame
		if b.is_demo_animating or lab._enemy_presentation_busy() or lab._presentation_busy(): continue
		if b.current_phase in ["ally_turn", "facing_select"] or not lab.battle_result.is_empty(): break
	for i in range(3): await process_frame

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

func project(lab, cell: Vector2i) -> Vector2:
	return lab.camera.unproject_position(lab.board.world(cell))

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_scenario_harness.gd").new()
	await h.open_shell(self)
	root.size = Vector2i(1920, 1080)
	var panel = h.shell.command_panel
	var original_on_facing: Callable = panel.on_facing
	var report := []
	for yaw_index in range(YAWS.size()):
		await h.press_scenario(self, "default")
		var lab = h.lab
		var b: Node = lab.engine
		await settle(lab, b)
		var unit = b.active_unit_state
		# Move to a cell whose four neighbours are on the board and empty-or-not (only on-board matters for the arrows).
		await click_at(project(lab, unit.grid_cell))
		var target = null
		for c in lab.queries.query(unit.unit_id, unit.grid_cell).get("reachable", {}).keys():
			if c != unit.grid_cell and b.all_battle_unit_states.all(func(x): return x.grid_cell != c) and DIRS.all(func(d): return lab.board.valid(c + OFFSETS[d])):
				target = c
				break
		await click_at(project(lab, target))
		var waited := 0
		while not (b.current_phase == "facing_select" and panel.arrows.visible) and waited < 3000:
			await process_frame
			waited += 1
		lab.yaw = YAWS[yaw_index]
		lab.zoom = 45.0
		for i in range(3): await process_frame
		var cell: Vector2i = unit.grid_cell
		var bad := []
		var clicks := {}
		var recorded := []
		panel.on_facing = func(d: String): recorded.append(d)
		for d in DIRS:
			var arrow: Button = panel.arrow_for(d)
			var neighbour: Vector2i = cell + OFFSETS[d]
			var want_centre := project(lab, neighbour)
			var want_dir := (want_centre - project(lab, cell)).normalized()
			var corners: PackedVector2Array = arrow.corners
			var centre: Vector2 = arrow.position + (corners[0] + corners[1] + corners[2] + corners[3]) * 0.25
			var angle := rad_to_deg(absf(arrow.direction.angle_to(want_dir)))
			if not arrow.visible or centre.distance_to(want_centre) > 3.0 or angle > 5.0: bad.append([d, centre, want_centre, "%.1f deg" % angle])
			recorded.clear()
			await click_at(centre)
			clicks[d] = recorded.duplicate()
			# A point in the bounding box but outside the diamond: the box corner nearest to the box origin.
			recorded.clear()
			await click_at(arrow.position + Vector2(1, 1))
			if recorded.has(d) and not Geometry2D.is_point_in_polygon(Vector2(1, 1), corners): bad.append([d, "box corner outside the diamond still clicks it"])
		panel.on_facing = original_on_facing
		h.expect(bad.is_empty(), "yaw %.2f: arrows on the projected neighbour centres (3 px), pointing along unit -> neighbour (5 deg), diamond hit area %s" % [YAWS[yaw_index], bad])
		h.expect(DIRS.all(func(d): return clicks[d] == [d]), "yaw %.2f: a real click on each arrow passes its own direction %s" % [YAWS[yaw_index], clicks])
		# One real click through to the lab and the engine.
		var d_real: String = DIRS[yaw_index % 4]
		var arrow: Button = panel.arrow_for(d_real)
		var corners: PackedVector2Array = arrow.corners
		var writes: Array = b.writes.duplicate()
		await click_at(arrow.position + (corners[0] + corners[1] + corners[2] + corners[3]) * 0.25)
		h.expect(unit.facing == d_real and b.writes.slice(writes.size()) == ["_select_post_move_facing"] and b.current_phase == "ally_turn",
			"yaw %.2f: a real click on the %s arrow confirms facing %s in the engine (facing %s, writes %s)" % [YAWS[yaw_index], d_real, d_real, unit.facing, b.writes.slice(writes.size())])
		report.append(["yaw %.2f" % YAWS[yaw_index], bad.size(), clicks])
		h.shell.choose_button.pressed.emit()
		await process_frame
	print("[ARROWS] ", report)
	await h.close_shell(self)
	print("[ARROWS] checks=", h.checks, " failures=", h.failures)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
