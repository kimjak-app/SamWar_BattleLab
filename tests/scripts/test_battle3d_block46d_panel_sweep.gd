extends SceneTree
# HUD block 4-6d test: the command panel follows the selected ally across the screen without jumping to a far corner, on
# the scenario shell at 1920 x 1080. For zoom 42 / 30 / 20 and three allies in turn (each waits for real to hand the turn
# to the next), the camera is pushed (the shell's camera-centre helper) so the ally stands at the screen's right, then
# moved 1.2 m along the camera's right per step until the ally leaves the screen or the camera stops at the play area.
# At each step, with the HUD rects read here from the HUD nodes and the marker parts from the marker nodes:
#   - the live panel overlaps none of them; a step is left out (and printed with its reason) when the panel is hidden
#     (the ally off screen) or when no candidate at all (the eight near the unit, the eight around the unit and its marker
#     as this test builds them from its own projection, the four corners) is clear;
#   - between two steps the panel moves 400 px or less (the largest move is printed);
#   - the panel never sits on a screen corner at a step where a candidate that is not a corner was clear;
#   - placed by the new step (around the unit and its marker), the panel keeps ANCHOR_GAP from the marker parts;
#   - control: with the new candidates off (the block 4-6c rule, placed again at each step) the zoom 30 sweep has a jump of
#     1000 px or more (printed, with the step).
const CameraCenter = preload("res://scripts/battle3d/battle3d_camera_center.gd")
const STEP := 1.2
const MAX_JUMP := 400.0
var h

func _initialize() -> void:
	run.call_deferred()

func hud(shell) -> Array:
	var rects := [shell.ally_roster.roster_rect(), shell.enemy_roster.roster_rect(), shell.actor_hud.panel_rect(),
		shell.log_hud.get_node("ProductionHudRoot/BattleLogHud").get_global_rect(), shell.top_hud.frame_rect()]
	for i in range(5): rects.append(shell.top_commands.slot_rect(i))
	return rects

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

func around(area: Rect2, size: Vector2, gap: float) -> Array:
	# Right, left, above, below and the four diagonals, gap off the area's outer edge.
	var c := area.get_center()
	var xs := {"r":area.end.x + gap, "l":area.position.x - size.x - gap, "m":c.x - size.x * 0.5}
	var ys := {"a":area.position.y - size.y - gap, "b":area.end.y + gap, "m":c.y - size.y * 0.5}
	return [Vector2(xs.r, ys.m), Vector2(xs.l, ys.m), Vector2(xs.m, ys.a), Vector2(xs.m, ys.b), Vector2(xs.r, ys.a), Vector2(xs.l, ys.a), Vector2(xs.r, ys.b), Vector2(xs.l, ys.b)]

func separation(a: Rect2, b: Rect2) -> float:
	# The gap between two rects (0 when they touch or overlap).
	return maxf(maxf(b.position.x - a.end.x, a.position.x - b.end.x), maxf(b.position.y - a.end.y, a.position.y - b.end.y))

func clear(p: Vector2, size: Vector2, blocked: Array) -> bool:
	var r := Rect2(p, size)
	return not blocked.any(func(x): return r.intersects(x))

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
	var size: Vector2 = panel.PANEL_SIZE
	var view := Vector2(root.size)
	var gap: float = panel.ANCHOR_GAP
	var board_size := Vector2(lab.board.PLAY_SIZE.x * lab.board.CELL, lab.board.PLAY_SIZE.y * lab.board.CELL)
	var corners := [Vector2(view.x - size.x - 12, view.y - size.y - 12), Vector2(12, view.y - size.y - 12), Vector2(view.x - size.x - 12, 12), Vector2(12, 12)]
	var covering := []
	var left_out := []
	var jumps := []
	var corner_bad := []
	var tight := [] # step 3 placements closer than ANCHOR_GAP to the marker
	var steps_by := {} # "zoom unit" -> {step used ("3b": step 3 round a HUD panel): count}
	var control := {} # "zoom unit" -> [largest jump, where]
	var largest := [0.0, ""]
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
			var last := Vector2.INF
			var last_control := Vector2.INF
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
				var parts := marker_parts(lab.unit_markers.markers[id])
				var blocked: Array = hud(shell) + parts
				var near: Array = panel.candidate_positions(anchor, size, view).slice(0, 8)
				var reach := unit_box(lab, lab.views[id].position)
				for part in parts: reach = reach.merge(part)
				var not_corner: Array = (near + around(reach, size, gap)).map(func(p): return panel.clamp_position(p, size, view)).filter(func(p): return clear(p, size, blocked))
				var any_clear := not not_corner.is_empty() or corners.any(func(p): return clear(p, size, blocked))
				if not any_clear:
					left_out.append([key, step, "no candidate clear (anchor %s)" % anchor])
				else:
					checked += 1
					if not clear(pr.position, size, blocked): covering.append([key, step, anchor, pr, used])
					if used.begins_with("3"):
						var apart: float = parts.map(func(r): return separation(pr, r)).min()
						if apart < gap - 1.0: tight.append([key, step, used, apart])
					if corners.has(pr.position) and not not_corner.is_empty(): corner_bad.append([key, step, anchor, pr.position, not_corner[0]])
				if last != Vector2.INF:
					var move := pr.position.distance_to(last)
					if move > largest[0]: largest = [move, "%s step %d anchor %s" % [key, step, anchor]]
					if move > MAX_JUMP: jumps.append([key, step, anchor, last, pr.position])
				last = pr.position
				last_anchor = anchor
				# Control: the block 4-6c rule at the same step.
				var keep_reach: bool = panel.reach_enabled
				panel.reach_enabled = false
				var plain: Vector2 = panel.choose_position(anchor, size, state.get("range_rects", []))
				panel.reach_enabled = keep_reach
				panel.choose_position(anchor, size, state.get("range_rects", [])) # chosen_step back to the live placement
				if last_control != Vector2.INF:
					var cm := plain.distance_to(last_control)
					if cm > control.get(key, [0.0])[0]: control[key] = [cm, "step %d anchor %s: %s -> %s" % [step, anchor, last_control, plain]]
				last_control = plain
				lab.focus += right * STEP
		if turn < 2:
			# The wait is refused while the lab is still busy (then asked again), until the next ally has the panel.
			for i in range(1200):
				if i % 120 == 0 and b.active_unit_state != null and String(b.active_unit_state.unit_id) == id and not b.active_unit_state.has_acted: lab.request_wait()
				await process_frame
				if b.active_unit_state != null and b.active_unit_state.side == "ally" and not actors.has(String(b.active_unit_state.unit_id)) and shell.command_state().get("open", false): break
			for i in range(180): await process_frame # the shell's camera move to the new actor ends
	h.expect(actors.size() == 3 and actors.duplicate().filter(func(a): return actors.count(a) == 1).size() == 3 and checked >= 60 and covering.is_empty(), "%s x zoom 42 / 30 / 20, %d steps: the panel clear of the HUD and the marker (wrong %s)" % [str(actors), checked, str(covering.slice(0, 4))])
	h.expect(jumps.is_empty(), "between steps the panel moves %d px or less (largest %.0f px at %s; over %s)" % [MAX_JUMP, largest[0], largest[1], str(jumps.slice(0, 4))])
	h.expect(tight.is_empty(), "placed by the new step: at least ANCHOR_GAP (%d px) from the marker (closer %s)" % [gap, str(tight.slice(0, 4))])
	h.expect(corner_bad.is_empty(), "the panel on a corner while a candidate that is not a corner was clear: none (wrong %s)" % str(corner_bad.slice(0, 4)))
	h.expect(control.get("30 " + actors[0], [0.0])[0] >= 1000.0, "control: the block 4-6c rule jumps at zoom 30 (%s)" % str(control))
	lab.edge_scroll_enabled = true
	await h.close_shell(self)
	print("[BLOCK46D_PANEL_SWEEP] checks=", h.checks, " failures=", h.failures, " steps ", checked, " largest move %.0f px at %s" % largest, " steps used ", steps_by, " left out ", left_out, " control (block 4-6c rule) largest jump by zoom ", control)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
