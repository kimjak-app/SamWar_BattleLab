extends SceneTree
# HUD block 6a test 4-1 (two holes found in the block 4-6d sweep test): on the same sweep as that test (scenario shell,
# 1920 x 1080, zoom 42 / 30 / 20 x three allies in turn, the camera moved 1.2 m a step so the ally crosses the screen
# from right to left), at every step where step 3 or 3b (around the unit and its marker) placed the panel:
#   (a) the panel overlaps not the selected unit's body box (1 m either side along the camera's right, 0 to 2.4 m up,
#       projected here from the lab camera);
#   (b) the panel keeps ANCHOR_GAP from each marker part (read here from the marker nodes);
#   - at least 30 such steps (the checks are not empty).
# Steps 1-2 (the 2D rule and the near candidates, block 4-6c) may cover the body box: counted and printed, not a
# failure (김작 10-27). The command panel code is not changed by block 6a; this test only reads it.
# In these scenes the marker parts' bounding box already holds the body box and step 3's candidates already stand clear
# of it, so two set-up cases are added (values handed straight to the marker script and the panel, no engine):
#   - a probe marker under a steep view (body point 100 px above the ground point, cell 77 px; the 2.4 m box then
#     reaches above the chip): the marker's reach_rect holds the body box this test computes from the same points;
#   - the panel with only the left candidate around reach_rect clear of the HUD, and that one (kept on screen at the
#     left edge) over the marker: step 3 does not place the panel over the marker.
const MIN_THIRD := 30
const STEEP := {"foot":Vector2(400, 600), "body":Vector2(400, 500), "disc_bottom":Vector2(400, 620), "cell_px":77.0}
const CameraCenter = preload("res://scripts/battle3d/battle3d_camera_center.gd")
const STEP := 1.2
var h

func _initialize() -> void:
	run.call_deferred()

func marker_parts(m: Control) -> Array:
	if not m.visible: return []
	var top: Rect2 = (m.get_node("Chip") as Control).get_global_rect()
	for badge in m.get_node("Badges").get_children():
		if badge.visible: top = top.merge(badge.get_global_rect())
	return [top, (m.get_node("BarBack") as Control).get_global_rect().merge(m.get_node("Troops").get_global_rect())]

func unit_box(lab, ground: Vector3) -> Rect2:
	# 1 m either side along the camera's right, 0 to 2.4 m up (the block 4-6b tests' unit box).
	var right := Vector3(lab.camera.global_basis.x.x, 0, lab.camera.global_basis.x.z).normalized()
	var box := Rect2(lab.camera.unproject_position(ground - right), Vector2.ZERO)
	for p in [ground + right, ground - right + Vector3(0, 2.4, 0), ground + right + Vector3(0, 2.4, 0)]: box = box.expand(lab.camera.unproject_position(p))
	return box

func separation(a: Rect2, b: Rect2) -> float:
	# The gap between two rects (0 when they touch or overlap).
	return maxf(maxf(b.position.x - a.end.x, a.position.x - b.end.x), maxf(b.position.y - a.end.y, a.position.y - b.end.y))

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_scenario_harness.gd").new()
	await h.open_shell(self)
	root.size = Vector2i(1920, 1080)
	await h.press_scenario(self, "default")
	var lab = h.lab
	var b: Node = lab.engine
	for i in range(120): await process_frame
	lab.edge_scroll_enabled = false
	var shell = h.shell
	var panel = shell.command_panel
	var gap: float = panel.ANCHOR_GAP
	var board_size := Vector2(lab.board.PLAY_SIZE.x * lab.board.CELL, lab.board.PLAY_SIZE.y * lab.board.CELL)
	var over_body := [] # steps 3 / 3b over the body box
	var near_cover := {} # zoom -> [steps 1-2 over the body box, largest overlap (px), where]
	var third := 0
	var tight := []
	var left_out := []
	var steps_by := {} # "zoom unit" -> {step used ("3b": step 3 round a HUD panel): count}
	var actors := []
	var checked := 0
	for turn in range(3):
		var id: String = b.active_unit_state.unit_id
		actors.append(id)
		for zoom in [42.0, 30.0, 20.0]:
			for i in range(900): # until the lab opens the commands (a turn-start cut-in may hold them)
				if lab.hud_command_panel_open(): break
				await process_frame
			if is_instance_valid(shell.camera_tween): shell.camera_tween.kill()
			lab.zoom = zoom
			for i in range(2): await process_frame
			lab.focus = CameraCenter.focus_for(lab.camera, lab.focus, lab.views[id].position, Vector2(1700, 480), board_size)
			var right := Vector3(lab.camera.global_basis.x.x, 0, lab.camera.global_basis.x.z).normalized()
			var last_anchor := Vector2.INF
			var key := "%d %s" % [zoom, id]
			steps_by[key] = {}
			for step in range(80):
				for i in range(3): await process_frame
				var state: Dictionary = shell.command_state()
				var anchor: Vector2 = state.get("anchor", Vector2.INF)
				if not panel.panel.visible or not state.get("open", false):
					left_out.append([key, step, "panel hidden (the ally off screen)"])
					break
				if last_anchor != Vector2.INF and anchor.distance_to(last_anchor) < 1.0: break # the camera stopped at the play area
				var used: String = str(panel.chosen_step) + ("b" if panel.chosen_step == 3 and panel.round_hud else "")
				steps_by[key][used] = steps_by[key].get(used, 0) + 1
				var pr: Rect2 = panel.panel_rect()
				var body := unit_box(lab, lab.views[id].position)
				checked += 1
				if pr.intersects(body) and not used.begins_with("3"):
					var cover := pr.intersection(body).size
					var zoom_key := str(int(zoom))
					if not near_cover.has(zoom_key): near_cover[zoom_key] = [0, Vector2.ZERO, ""]
					near_cover[zoom_key][0] += 1
					if cover.x * cover.y > near_cover[zoom_key][1].x * near_cover[zoom_key][1].y: near_cover[zoom_key] = [near_cover[zoom_key][0], cover, "%s step %d anchor %s" % [key, step, anchor]]
				if used.begins_with("3"):
					third += 1
					if pr.intersects(body): over_body.append([key, step, used, pr, body])
					var parts := marker_parts(lab.unit_markers.markers[id])
					var apart: float = parts.map(func(r): return separation(pr, r)).min() if not parts.is_empty() else INF
					if apart < gap - 1.0: tight.append([key, step, used, apart])
				lab.focus += right * STEP
		if turn < 2:
			# The wait is refused while the lab is still busy (then asked again), until the next ally has the panel.
			for i in range(1200):
				if i % 120 == 0 and b.active_unit_state != null and String(b.active_unit_state.unit_id) == id and not b.active_unit_state.has_acted: lab.request_wait()
				await process_frame
				if b.active_unit_state != null and b.active_unit_state.side == "ally" and not actors.has(String(b.active_unit_state.unit_id)) and shell.command_state().get("open", false): break
			for i in range(180): await process_frame # the shell's camera move to the new actor ends
	h.expect(actors.size() == 3 and actors.duplicate().filter(func(a): return actors.count(a) == 1).size() == 3 and third >= MIN_THIRD, "%s x zoom 42 / 30 / 20, %d steps: %d placed by step 3 / 3b (at least %d)" % [str(actors), checked, third, MIN_THIRD])
	h.expect(over_body.is_empty(), "step 3 / 3b: the panel clear of the selected unit's body box (wrong %s)" % str(over_body.slice(0, 4)))
	# Set-up case 1: the body box sticks out of the marker parts.
	var markers = lab.unit_markers
	markers.show_unit("zz_probe", {"side":"ally", "current_troops":5, "max_troops":10}, null, false, [], STEEP, true)
	var foot: Vector2 = STEEP.foot
	var half: float = STEEP.cell_px / 3.0
	var steep_body := Rect2(Vector2(foot.x - half, foot.y - (foot.y - STEEP.body.y) * 2.4), Vector2(half * 2.0, (foot.y - STEEP.body.y) * 2.4))
	var probe_parts: Array = markers.rects_of("zz_probe")
	var parts_box: Rect2 = probe_parts[0].merge(probe_parts[1])
	var steep_reach: Rect2 = markers.reach_rect("zz_probe")
	h.expect(not parts_box.encloses(steep_body) and steep_reach.encloses(steep_body), "steep view: the body box %s sticks out of the marker parts %s and reach_rect %s holds it" % [steep_body, parts_box, steep_reach])
	markers.markers["zz_probe"].queue_free()
	markers.markers.erase("zz_probe")
	# Set-up case 2: only the left candidate is clear of the HUD, and on screen it lies over the marker.
	var keep := [panel.avoid_rects, panel.hud_rects, panel.reach_rect]
	panel.avoid_rects = [Rect2(0, 300, 40, 40), Rect2(0, 420, 80, 40)]
	panel.reach_rect = Rect2(0, 300, 80, 160)
	panel.hud_rects = [Rect2(200, 0, 1720, 1080), Rect2(0, 0, 200, 272), Rect2(0, 490, 200, 590)]
	var placed: Vector2 = panel.choose_position(Vector2(40, 380), panel.PANEL_SIZE, [])
	var placed_step: int = panel.chosen_step
	var over_marker: bool = panel.covers(Rect2(placed, panel.PANEL_SIZE), panel.avoid_rects)
	panel.avoid_rects = keep[0]
	panel.hud_rects = keep[1]
	panel.reach_rect = keep[2]
	h.expect(not (placed_step == 3 and over_marker), "left edge set-up: step 3 does not put the panel over the marker (step %d at %s, over the marker %s)" % [placed_step, placed, over_marker])
	h.expect(tight.is_empty(), "%d placements by step 3 / 3b: each at least ANCHOR_GAP (%d px) from the marker parts (closer %s)" % [third, gap, str(tight.slice(0, 4))])
	lab.edge_scroll_enabled = true
	await h.close_shell(self)
	print("[BLOCK6A_PANEL_BODY_GAP] checks=", h.checks, " failures=", h.failures, " steps ", checked, " placed by step 3 / 3b ", third, " steps used ", steps_by, " left out ", left_out, " steps 1-2 over the body box by zoom [steps, largest overlap px, where] ", near_cover)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
