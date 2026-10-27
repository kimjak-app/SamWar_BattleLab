extends SceneTree
# HUD block 4-6c test 1: the command panel keeps clear of the HUD and of the selected unit's marker, on the scenario shell
# at 1920 x 1080. The camera is pushed (the shell's own camera-centre helper) so the selected ally sits at the screen's
# left edge, right edge (x 1500 and 1580; the play-area camera clamp may stop it short at zoom 42), top, bottom and
# centre, at zoom 42 and 20; the HUD rects are read here from the HUD nodes
# (rosters, current-actor panel, log, top HUD frame, the five top command slots), the marker parts from the marker nodes.
#   - every case: the live panel overlaps none of them;
#   - fallback: with the HUD covering the whole screen (the panel's HUD list replaced for one placement) no candidate is
#     clear, and the panel falls back to the block 4-6b choice (clear of the marker alone);
#   - control: with the HUD avoidance off (the panel's HUD list cleared for one placement) a left edge case covers the
#     ally roster; at the right edge the block 4-6b marker avoidance alone already moves the panel left, so the right
#     edge control turns both off (the block 4-6 rule) and then covers the enemy roster.
const CameraCenter = preload("res://scripts/battle3d/battle3d_camera_center.gd")
const TARGETS := {"left":Vector2(420, 560), "right":Vector2(1500, 480), "far right":Vector2(1580, 480), "top":Vector2(960, 200), "bottom":Vector2(960, 760), "centre":Vector2(960, 470)}
var h

func _initialize() -> void:
	run.call_deferred()

func hud(shell) -> Array:
	var rects := [shell.ally_roster.roster_rect(), shell.enemy_roster.roster_rect(), shell.actor_hud.panel_rect(),
		shell.log_hud.get_node("ProductionHudRoot/BattleLogHud").get_global_rect(), shell.top_hud.frame_rect()]
	for i in range(5): rects.append(shell.top_commands.slot_rect(i))
	return rects

func marker_parts(m: Control) -> Array:
	var top: Rect2 = (m.get_node("Chip") as Control).get_global_rect()
	for badge in m.get_node("Badges").get_children():
		if badge.visible: top = top.merge(badge.get_global_rect())
	return [top, (m.get_node("BarBack") as Control).get_global_rect().merge(m.get_node("Troops").get_global_rect())]

func hits(r: Rect2, rects: Array) -> Array:
	return rects.filter(func(x): return r.intersects(x))

func push_to(lab, shell, id: String, zoom: float, target: Vector2) -> void:
	if is_instance_valid(shell.camera_tween): shell.camera_tween.kill()
	lab.zoom = zoom
	for i in range(2): await process_frame
	var board_size := Vector2(lab.board.PLAY_SIZE.x * lab.board.CELL, lab.board.PLAY_SIZE.y * lab.board.CELL)
	lab.focus = CameraCenter.focus_for(lab.camera, lab.focus, lab.views[id].position, target, board_size)
	for i in range(4): await process_frame

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_scenario_harness.gd").new()
	await h.open_shell(self)
	root.size = Vector2i(1920, 1080)
	await h.press_scenario(self, "default")
	var lab = h.lab
	var b: Node = lab.engine
	for i in range(240): await process_frame
	lab.edge_scroll_enabled = false
	var shell = h.shell
	var panel = shell.command_panel
	var id: String = b.active_unit_state.unit_id
	var bad := []
	var cases := 0
	var without := {}
	for zoom in [42.0, 20.0]:
		for where in TARGETS:
			await push_to(lab, shell, id, zoom, TARGETS[where])
			var pr: Rect2 = panel.panel_rect()
			var avoid: Array = hud(shell) + marker_parts(lab.unit_markers.markers[id])
			cases += 1
			if not panel.panel.visible or not hits(pr, avoid).is_empty(): bad.append([zoom, where, panel.panel.visible, pr, hits(pr, avoid)])
			# Control: the same placement without the HUD list.
			var state: Dictionary = shell.command_state()
			var keep: Array = panel.hud_rects
			var keep_marker: Array = panel.avoid_rects
			panel.hud_rects = []
			var plain: Vector2 = panel.choose_position(state.get("anchor", Vector2.ZERO), panel.PANEL_SIZE, state.get("range_rects", []))
			panel.avoid_rects = []
			var plain_46: Vector2 = panel.choose_position(state.get("anchor", Vector2.ZERO), panel.PANEL_SIZE, state.get("range_rects", []))
			panel.hud_rects = keep
			panel.avoid_rects = keep_marker
			without["%d %s" % [zoom, where]] = not hits(Rect2(plain, panel.PANEL_SIZE), [shell.ally_roster.roster_rect()]).is_empty()
			without["%d %s 4-6 rule" % [zoom, where]] = not hits(Rect2(plain_46, panel.PANEL_SIZE), [shell.enemy_roster.roster_rect()]).is_empty()
	h.expect(cases == 12 and bad.is_empty(), "zoom 42 / 20 x left, right, far right, top, bottom, centre: the panel clear of the HUD and the marker (wrong %s)" % str(bad))
	h.expect(without.get("42 left", false) or without.get("20 left", false), "control: without the HUD avoidance a left-edge case covers the ally roster %s" % str(without))
	h.expect(["42 right 4-6 rule", "20 right 4-6 rule", "42 far right 4-6 rule", "20 far right 4-6 rule"].any(func(k): return without.get(k, false)), "control: with the block 4-6 rule (no HUD, no marker avoidance) a right-edge case covers the enemy roster %s" % str(without))
	# Fallback: no candidate clear of the HUD.
	await push_to(lab, shell, id, 42.0, TARGETS.centre)
	var state: Dictionary = shell.command_state()
	var keep: Array = panel.hud_rects
	panel.hud_rects = [Rect2(Vector2.ZERO, Vector2(root.size))]
	var fallback: Vector2 = panel.choose_position(state.get("anchor", Vector2.ZERO), panel.PANEL_SIZE, state.get("range_rects", []))
	panel.hud_rects = []
	var marker_only: Vector2 = panel.choose_position(state.get("anchor", Vector2.ZERO), panel.PANEL_SIZE, state.get("range_rects", []))
	panel.hud_rects = keep
	h.expect(fallback == marker_only and hits(Rect2(fallback, panel.PANEL_SIZE), marker_parts(lab.unit_markers.markers[id])).is_empty(),
		"fallback: the HUD everywhere -> the block 4-6b choice clear of the marker (%s vs %s)" % [fallback, marker_only])
	lab.edge_scroll_enabled = true
	await h.close_shell(self)
	print("[BLOCK46C_PANEL_HUD] checks=", h.checks, " failures=", h.failures, " cases ", cases, " covering a roster without the HUD avoidance ", without)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
