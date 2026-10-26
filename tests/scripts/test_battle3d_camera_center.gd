extends SceneTree
# HUD block 4-3 item 2: the camera centres the acting ally in the screen area the HUD leaves free. Checks (1920x1080
# and 1280x800):
#   - the free rectangle the shell uses lies inside the view and overlaps no HUD rectangle (rosters, current actor,
#     log, top frame, top buttons);
#   - about 0.35 s after an ally turn starts, that unit's screen point is inside the free rectangle and at its centre
#     (2 px), unless the focus is clamped at the board edge: then the focus is on the edge and the unit is as close as
#     the clamp allows (the unclamped focus lies outside the board);
#   - the player's own camera key stops it for that turn; the next ally turn is centred again;
#   - the focus does not move during the enemy turn and its replay.
var h

func _initialize() -> void:
	run.call_deferred()

func settle(lab, b) -> void:
	for i in range(8000):
		await process_frame
		if b.is_demo_animating or lab._enemy_presentation_busy() or lab._presentation_busy(): continue
		if b.current_phase == "ally_turn" or not lab.battle_result.is_empty(): break
	for i in range(3): await process_frame

func wait_seconds(seconds: float) -> void:
	var start := Time.get_ticks_msec()
	while Time.get_ticks_msec() - start < seconds * 1000.0: await process_frame

func hud_rects() -> Array:
	var s = h.shell
	var out := [s.ally_roster.roster_rect(), s.enemy_roster.roster_rect(), s.actor_hud.panel_rect(), s.log_hud.get_node("ProductionHudRoot/BattleLogHud").get_global_rect(), s.top_hud.frame_rect()]
	for i in range(5): out.append(s.top_commands.slot_rect(i))
	return out

func unclamped_focus(lab, point: Vector3, target: Vector2) -> Vector3:
	# Independent of the shell: the camera keeps its offset from the focus, so search the ground focus whose projection
	# puts `point` on `target` by moving a copy of the camera (no clamp).
	var cam := Camera3D.new()
	cam.projection = lab.camera.projection
	cam.size = lab.camera.size
	cam.keep_aspect = lab.camera.keep_aspect
	root.add_child(cam)
	var offset: Vector3 = lab.camera.global_position - lab.focus
	var f: Vector3 = lab.focus
	for i in range(40):
		cam.global_position = f + offset
		cam.look_at(f)
		var s: Vector2 = cam.unproject_position(point)
		cam.global_position = f + Vector3(0.01, 0, 0) + offset
		cam.look_at(f + Vector3(0.01, 0, 0))
		var sx: Vector2 = (cam.unproject_position(point) - s) / 0.01
		cam.global_position = f + Vector3(0, 0, 0.01) + offset
		cam.look_at(f + Vector3(0, 0, 0.01))
		var sz: Vector2 = (cam.unproject_position(point) - s) / 0.01
		var det := sx.x * sz.y - sx.y * sz.x
		var need := target - s
		f += Vector3((need.x * sz.y - need.y * sz.x) / det, 0, (sx.x * need.y - sx.y * need.x) / det)
	cam.free()
	return f

func check_centred(lab, label: String) -> Dictionary:
	var id: String = lab.hud_ally_actor_id()
	var free: Rect2 = h.shell.camera_free_rect()
	var view := root.get_visible_rect()
	var point: Vector2 = lab.camera.unproject_position(lab.views[id].position)
	var size := Vector2(lab.board.SIZE.x * lab.board.CELL, lab.board.SIZE.y * lab.board.CELL)
	var focus: Vector3 = lab.focus
	var clamped := is_equal_approx(focus.x, 0.0) or is_equal_approx(focus.x, size.x) or is_equal_approx(focus.z, 0.0) or is_equal_approx(focus.z, size.y)
	var free_ok: bool = view.encloses(free) and free.has_area() and hud_rects().all(func(r): return not (r as Rect2).intersection(view).intersects(free))
	var centred := point.distance_to(free.get_center()) <= 2.0
	h.expect(free_ok and view.has_point(point) and (centred or clamped),
		"%s: free rect %s inside the view and clear of the HUD; %s at %s, centre %s (%.1f px), clamped %s" % [label, free, id, point, free.get_center(), point.distance_to(free.get_center()), clamped])
	if not centred:
		# Clamped: an unclamped focus would leave the board on the clamped axis.
		var unclamped := unclamped_focus(lab, lab.views[id].position, free.get_center())
		var outside := unclamped.x < 0.0 or unclamped.x > size.x or unclamped.z < 0.0 or unclamped.z > size.y
		h.expect(clamped and outside, "%s: off centre only because the focus is clamped (unclamped focus %s, board %s)" % [label, unclamped, size])
	return {"label":label, "unit":id, "point":point, "free":free, "distance":point.distance_to(free.get_center()), "clamped":clamped, "focus":focus}

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_scenario_harness.gd").new()
	await h.open_shell(self)
	var results := []
	for size in [Vector2i(1920, 1080), Vector2i(1280, 800)]:
		root.size = size
		await h.press_scenario(self, "default")
		var lab = h.lab
		var b: Node = lab.engine
		await settle(lab, b)
		await wait_seconds(0.5)
		results.append(check_centred(lab, "%dx%d first ally" % [size.x, size.y]))
		# Each ally turn of round 1 and round 2 (the bottom-left reinforcement arrives in round 2).
		for turn in range(6 if size.x == 1920 else 3): # 1920x1080 reaches the bottom-left reinforcement; 1280x800 three turns (CI 120 s per test)
			var key: String = h.shell.camera_turn_key()
			var enemy_focus_moves := 0
			lab.request_wait()
			var focus_at_enemy := Vector3.INF
			for i in range(8000):
				await process_frame
				if b.current_phase == "enemy_turn" or lab._enemy_presentation_busy():
					if focus_at_enemy == Vector3.INF: focus_at_enemy = lab.focus
					elif lab.focus != focus_at_enemy and h.shell.centred_turn == key: enemy_focus_moves += 1
				elif b.current_phase == "ally_turn" and not lab._presentation_busy(): break
			h.expect(enemy_focus_moves == 0, "%dx%d turn %d: the focus does not move while the enemy acts (%d frames moved)" % [size.x, size.y, turn, enemy_focus_moves])
			await wait_seconds(0.5)
			if not lab.battle_result.is_empty(): break
			results.append(check_centred(lab, "%dx%d turn %d" % [size.x, size.y, turn + 1]))
		h.shell.choose_button.pressed.emit()
		await process_frame
	print("[CAMERA] centred: ", results.map(func(r): return [r.label, r.unit, "%.1f px" % r.distance, r.clamped]))
	# Manual camera input stops it for that turn; the next ally turn is centred again.
	root.size = Vector2i(1920, 1080)
	await h.press_scenario(self, "default")
	var lab = h.lab
	var b: Node = lab.engine
	await settle(lab, b)
	await wait_seconds(0.5)
	lab.request_wait()
	for i in range(8000):
		await process_frame
		# The first frame of the next ally turn the shell would centre (idle, not centred yet): the key goes in now.
		if b.current_phase == "ally_turn" and not lab._presentation_busy() and h.shell.camera_turn_key() != "" and h.shell.camera_turn_key() != h.shell.centred_turn: break
	var key := InputEventKey.new()
	key.keycode = KEY_D
	key.physical_keycode = KEY_D
	key.pressed = true
	root.push_input(key)
	await process_frame
	var turn: String = h.shell.camera_turn_key()
	var focus_after_key: Vector3 = lab.focus
	await wait_seconds(0.6)
	h.expect(h.shell.manual_camera_turn == turn and lab.focus.distance_to(focus_after_key) < 0.001, "a camera key in turn %s stops the centring for it (focus %s -> %s)" % [turn, focus_after_key, lab.focus])
	key.pressed = false
	root.push_input(key)
	lab.request_wait()
	await settle(lab, b)
	await wait_seconds(0.5)
	h.expect(h.shell.camera_turn_key() != turn and h.shell.centred_turn == h.shell.camera_turn_key(), "the next ally turn (%s) is centred again" % h.shell.camera_turn_key())
	results.append(check_centred(lab, "after manual, next turn"))
	await h.close_shell(self)
	print("[CAMERA] checks=", h.checks, " failures=", h.failures)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
