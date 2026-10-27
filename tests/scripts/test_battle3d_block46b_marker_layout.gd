extends SceneTree
# HUD block 4-6b tests 1-2: the unit markers' size and place on the scenario shell, against values this test measures
# itself from the lab camera's projection, for zoom 42 / 30 / 20 at the start yaw and after a 90 degree turn:
#   cell_px = the on-screen distance between a unit's ground point and the point one 3 m cell along the camera's right;
#   1. chip side = clamp(0.55 x cell_px, 34, 80), bar = clamp(0.90 x cell_px, 60, 150) x max(7, round(0.09 x width)),
#      number font = clamp(round(0.17 x cell_px), 13, 22) (badges the same); the chip at zoom 20 bigger than at zoom 42;
#   2. the chip's centre is right of and above the body point (1 m up); the chip overlaps the unit's screen box (1 m either
#      side along the camera's right, 0 to 2.4 m up); the bar's top is under the ground disc's lower screen edge (1.27 m
#      toward the camera); the bar's centre is on the unit's screen x (within 1 px).
const CELL := 3.0
var h

func _initialize() -> void:
	run.call_deferred()

func project(lab, p: Vector3) -> Vector2:
	return lab.camera.unproject_position(p)

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
	var cell_seen := {}
	var chips := {} # [zoom, yaw] -> {id: chip side}
	var checked := 0
	for turn in [0.0, PI * 0.5]:
		for zoom in [42.0, 30.0, 20.0]:
			if is_instance_valid(h.shell.camera_tween): h.shell.camera_tween.kill()
			lab.yaw = 0.32 + turn
			lab.zoom = zoom
			lab.focus = Vector3(27, 0, 15)
			for i in range(3): await process_frame
			var key := "%d/%d" % [int(zoom), int(rad_to_deg(turn))]
			chips[key] = {}
			var right := Vector3(lab.camera.global_basis.x.x, 0, lab.camera.global_basis.x.z).normalized()
			var toward := Vector3(lab.camera.global_basis.z.x, 0, lab.camera.global_basis.z.z).normalized()
			for unit in b.all_battle_unit_states:
				var m: Control = lab.unit_markers.markers.get(unit.unit_id)
				if m == null or not m.visible: continue
				checked += 1
				var ground: Vector3 = lab.views[unit.unit_id].position
				var foot := project(lab, ground)
				var cell := foot.distance_to(project(lab, ground + right * CELL))
				cell_seen[key] = cell
				var chip_side := clampf(0.55 * cell, 34.0, 80.0)
				var bar_w := clampf(0.90 * cell, 60.0, 150.0)
				var bar_h := maxf(7.0, roundf(0.09 * bar_w))
				var font := clampi(roundi(0.17 * cell), 13, 22)
				var chip: Rect2 = (m.get_node("Chip") as Control).get_global_rect()
				var bar: Rect2 = (m.get_node("BarBack") as Control).get_global_rect()
				var number: Label = m.get_node("Troops")
				chips[key][unit.unit_id] = chip.size.x
				var badge_fonts: Array = m.get_node("Badges").get_children().filter(func(l): return l.visible).map(func(l): return l.get_theme_font_size("font_size"))
				if absf(chip.size.x - chip_side) > 1.0 or absf(chip.size.y - chip_side) > 1.0 or absf(bar.size.x - bar_w) > 1.0 or absf(bar.size.y - bar_h) > 1.0 \
						or number.get_theme_font_size("font_size") != font or badge_fonts.any(func(f): return f != font):
					size_bad.append([key, unit.unit_id, cell, chip.size, chip_side, bar.size, Vector2(bar_w, bar_h), number.get_theme_font_size("font_size"), font])
				var body := project(lab, ground + Vector3(0, 1.0, 0))
				var box := Rect2(project(lab, ground - right), Vector2.ZERO)
				for p in [ground + right, ground - right + Vector3(0, 2.4, 0), ground + right + Vector3(0, 2.4, 0)]: box = box.expand(project(lab, p))
				var disc_bottom := project(lab, ground + toward * 1.27)
				var problems := []
				if not (chip.get_center().x > body.x and chip.get_center().y < body.y): problems.append("chip not upper right of the body %s / %s" % [chip.get_center(), body])
				if not chip.intersects(box): problems.append("chip off the unit box %s / %s" % [chip, box])
				if bar.position.y < disc_bottom.y: problems.append("bar top %.1f above the disc edge %.1f" % [bar.position.y, disc_bottom.y])
				if absf(bar.get_center().x - foot.x) > 1.0: problems.append("bar centre %.1f vs unit x %.1f" % [bar.get_center().x, foot.x])
				if not problems.is_empty(): place_bad.append([key, unit.unit_id, problems])
	h.expect(checked >= 30 and size_bad.is_empty(), "%d marker views: chip / bar / font = the formulas from the measured cell_px (wrong %s)" % [checked, str(size_bad.slice(0, 4))])
	h.expect(place_bad.is_empty(), "chip upper right on the unit, bar under the disc and centred (wrong %s)" % str(place_bad.slice(0, 4)))
	var grown := []
	for id in chips.get("42/0", {}):
		if chips.get("20/0", {}).has(id) and chips["20/0"][id] <= chips["42/0"][id]: grown.append(id)
	h.expect(not chips.get("42/0", {}).is_empty() and grown.is_empty(), "zoom 20 chips bigger than zoom 42 ones (not bigger %s)" % str(grown))
	lab.edge_scroll_enabled = true
	await h.close_shell(self)
	print("[BLOCK46B_LAYOUT] checks=", h.checks, " failures=", h.failures, " marker views ", checked, " cell_px by zoom/turn ", cell_seen)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
