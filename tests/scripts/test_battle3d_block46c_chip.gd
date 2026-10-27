extends SceneTree
# HUD block 4-6c test 2: the smaller face chip, on the scenario shell, against values this test measures from the lab
# camera's projection, for zoom 42 / 30 / 20 at the start yaw and after a 90 degree turn (cell_px: the on-screen width of
# one 3 m cell along the camera's right at the unit):
#   - chip side = clamp(0.42 x cell_px, 30, 64) within 1 px;
#   - the chip's centre is right of and above the body point (1 m up); the chip overlaps the unit's screen box (1 m either
#     side along the camera's right, 0 to 2.4 m up); the chip's lower edge is above the body point (not lower);
#   - recorded, not judged: whether the chip covers any of the unit's four facing arrow centres (1.0 m out on the ground).
const CELL := 3.0
const DIRS := {"up":Vector3(0, 0, -1), "right":Vector3(1, 0, 0), "down":Vector3(0, 0, 1), "left":Vector3(-1, 0, 0)}
var h

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_scenario_harness.gd").new()
	await h.open_shell(self)
	root.size = Vector2i(1920, 1080)
	await h.press_scenario(self, "default")
	var lab = h.lab
	var b: Node = lab.engine
	for i in range(120): await process_frame
	lab.edge_scroll_enabled = false
	var size_bad := []
	var place_bad := []
	var covers_arrow := []
	var sides := {}
	var checked := 0
	var arrows := 0
	for turn in [0.0, PI * 0.5]:
		for zoom in [42.0, 30.0, 20.0]:
			if is_instance_valid(h.shell.camera_tween): h.shell.camera_tween.kill()
			lab.yaw = 0.32 + turn
			lab.zoom = zoom
			lab.focus = Vector3(27, 0, 15)
			for i in range(3): await process_frame
			var key := "%d/%d" % [int(zoom), int(rad_to_deg(turn))]
			var right := Vector3(lab.camera.global_basis.x.x, 0, lab.camera.global_basis.x.z).normalized()
			for unit in b.all_battle_unit_states:
				var m: Control = lab.unit_markers.markers.get(unit.unit_id)
				if m == null or not m.visible: continue
				checked += 1
				var ground: Vector3 = lab.views[unit.unit_id].position
				var foot: Vector2 = lab.camera.unproject_position(ground)
				var cell := foot.distance_to(lab.camera.unproject_position(ground + right * CELL))
				var want := clampf(0.42 * cell, 30.0, 64.0)
				var chip: Rect2 = (m.get_node("Chip") as Control).get_global_rect()
				sides[key] = [snappedf(cell, 0.1), chip.size.x]
				if absf(chip.size.x - want) > 1.0 or absf(chip.size.y - want) > 1.0: size_bad.append([key, unit.unit_id, cell, chip.size, want])
				var body: Vector2 = lab.camera.unproject_position(ground + Vector3(0, 1.0, 0))
				var box := Rect2(lab.camera.unproject_position(ground - right), Vector2.ZERO)
				for p in [ground + right, ground - right + Vector3(0, 2.4, 0), ground + right + Vector3(0, 2.4, 0)]: box = box.expand(lab.camera.unproject_position(p))
				var problems := []
				if not (chip.get_center().x > body.x and chip.get_center().y < body.y): problems.append("not upper right of the body")
				if not chip.intersects(box): problems.append("off the unit box")
				if chip.end.y >= body.y: problems.append("lower edge %.1f not above the body point %.1f" % [chip.end.y, body.y])
				if not problems.is_empty(): place_bad.append([key, unit.unit_id, problems])
				for d in DIRS:
					var p: Vector3 = ground + DIRS[d]
					p.y = lab.board.height(p.x, p.z) + 0.08
					arrows += 1
					if chip.has_point(lab.camera.unproject_position(p)): covers_arrow.append([key, unit.unit_id, d])
	h.expect(checked >= 24 and size_bad.is_empty(), "%d chips (at least 4 units in each of the 6 views): side = clamp(0.42 x cell_px, 30, 64) (wrong %s)" % [checked, str(size_bad.slice(0, 4))])
	h.expect(place_bad.is_empty(), "chips upper right of the body point, on the unit, lower edge above the body point (wrong %s)" % str(place_bad.slice(0, 4)))
	lab.edge_scroll_enabled = true
	await h.close_shell(self)
	print("[BLOCK46C_CHIP] checks=", h.checks, " failures=", h.failures, " chips ", checked, " [cell_px, chip side] by zoom/turn ", sides, " arrow centres covered ", covers_arrow.size(), " of ", arrows, " ", covers_arrow)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
