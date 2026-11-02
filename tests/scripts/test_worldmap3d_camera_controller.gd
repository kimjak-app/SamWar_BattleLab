extends SceneTree

var _checks := 0
var _failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var cam := WorldMap3DCamera.new()
	root.add_child(cam)
	var ctl := WorldMap3DCameraController.new()
	root.add_child(ctl)
	var label := Label.new()
	root.add_child(label)
	ctl.configure_3d(cam, label, root)
	await process_frame
	var selects := [0]
	cam.select_requested.connect(func(_pos: Vector2) -> void: selects[0] += 1)

	# 1. configure_3d switches the camera to external input; the controller is a WorldMapCameraController
	_expect(cam.external_input == true, "configure_3d sets external_input")
	_expect(ctl is WorldMapCameraController, "controller extends WorldMapCameraController")

	# 2. wheel
	cam.zoom_goal = 0.0
	_expect(ctl.handle_unhandled_input(_mouse_button(MOUSE_BUTTON_WHEEL_UP, true)), "wheel up is consumed")
	_expect(is_equal_approx(cam.zoom_goal, cam.zoom_step), "wheel up zooms in by zoom_step")
	_expect(ctl.handle_unhandled_input(_mouse_button(MOUSE_BUTTON_WHEEL_DOWN, true)), "wheel down is consumed")
	_expect(is_equal_approx(cam.zoom_goal, 0.0), "wheel down zooms back out")
	_expect(not ctl.handle_unhandled_input(_mouse_button(MOUSE_BUTTON_WHEEL_UP, false)), "wheel release is not consumed")
	_expect(is_equal_approx(cam.zoom_goal, 0.0), "wheel release does not zoom")

	# 3. middle drag pans
	var goal0 := cam._target_goal
	_expect(ctl.handle_unhandled_input(_mouse_button(MOUSE_BUTTON_MIDDLE, true)), "middle press is consumed")
	_expect(ctl.handle_unhandled_input(_motion(Vector2(100, 0))), "motion while middle drag is consumed")
	_expect(cam._target_goal != goal0, "middle drag moves _target_goal")
	_expect(ctl.handle_unhandled_input(_mouse_button(MOUSE_BUTTON_MIDDLE, false)), "middle release is consumed")
	var goal1 := cam._target_goal
	_expect(not ctl.handle_unhandled_input(_motion(Vector2(100, 0))), "motion after middle release is not consumed")
	_expect(cam._target_goal == goal1, "motion after middle release does not pan")

	# 4. right drag: scheme A rotates, scheme B pans
	cam.set_input_scheme("A")
	var yaw0 := cam.yaw_goal
	_expect(ctl.handle_unhandled_input(_mouse_button(MOUSE_BUTTON_RIGHT, true)), "scheme A: right press is consumed")
	ctl.handle_unhandled_input(_motion(Vector2(100, 0)))
	_expect(absf(cam.yaw_goal - (yaw0 - 0.5)) < 1e-4, "scheme A: right drag 100 px rotates yaw_goal by -0.5")
	ctl.handle_unhandled_input(_mouse_button(MOUSE_BUTTON_RIGHT, false))
	_expect(not ctl.handle_unhandled_input(_motion(Vector2(100, 0))), "scheme A: motion after right release is not consumed")
	cam.set_input_scheme("B")
	var yaw1 := cam.yaw_goal
	var goal2 := cam._target_goal
	ctl.handle_unhandled_input(_mouse_button(MOUSE_BUTTON_RIGHT, true))
	ctl.handle_unhandled_input(_motion(Vector2(100, 0)))
	ctl.handle_unhandled_input(_mouse_button(MOUSE_BUTTON_RIGHT, false))
	_expect(is_equal_approx(cam.yaw_goal, yaw1), "scheme B: right drag does not rotate")
	_expect(cam._target_goal != goal2, "scheme B: right drag pans")
	cam.set_input_scheme("A")

	# 5. left click is forwarded but never consumed
	selects[0] = 0
	_expect(not ctl.handle_unhandled_input(_mouse_button(MOUSE_BUTTON_LEFT, true, Vector2(100, 100))), "left press is not consumed")
	_expect(not ctl.handle_unhandled_input(_mouse_button(MOUSE_BUTTON_LEFT, false, Vector2(103, 100))), "left release is not consumed")
	_expect(selects[0] == 1, "left click within 6 px selects once")
	selects[0] = 0
	ctl.handle_unhandled_input(_mouse_button(MOUSE_BUTTON_LEFT, true, Vector2(100, 100)))
	ctl.handle_unhandled_input(_mouse_button(MOUSE_BUTTON_LEFT, false, Vector2(120, 100)))
	_expect(selects[0] == 0, "left drag of 20 px does not select")

	# 6. apply_zoom
	cam.zoom_goal = 0.5
	ctl.apply_zoom(0.1)
	_expect(cam.zoom_goal > 0.5, "apply_zoom(+) zooms in")
	var z1 := cam.zoom_goal
	ctl.apply_zoom(-0.1)
	_expect(cam.zoom_goal < z1, "apply_zoom(-) zooms out")

	# 7. world rect; an unconfigured controller is inert
	_expect(ctl.get_world_rect().size.is_equal_approx(cam.map_half * 2.0), "get_world_rect size = map_half * 2")
	var bare := WorldMap3DCameraController.new()
	_expect(bare.get_world_rect() == Rect2(), "unconfigured controller: empty world rect")
	_expect(not bare.handle_unhandled_input(_mouse_button(MOUSE_BUTTON_WHEEL_UP, true)), "unconfigured controller: wheel not consumed")

	# 8. input_blocked path (headless: no real key is held, so this only proves the path runs)
	ctl.input_blocked = true
	ctl.process_camera(0.1)
	_expect(cam._ext_pan == Vector2.ZERO, "input_blocked: external pan stays zero")
	ctl.input_blocked = false
	ctl.process_camera(0.1)
	_expect(cam._ext_pan == Vector2.ZERO, "unblocked process_camera runs (no key held)")

	# 9. focused LineEdit blocks the keyboard axes
	var line_edit := LineEdit.new()
	root.add_child(line_edit)
	line_edit.grab_focus()
	_expect(ctl._is_keyboard_camera_blocked(), "focused LineEdit blocks")
	line_edit.release_focus()
	_expect(not ctl._is_keyboard_camera_blocked(), "released LineEdit does not block")

	# 10. battle entry handoff + skip
	var calls := [0]
	var cb := func() -> void: calls[0] += 1
	_expect(ctl.start_battle_entry_handoff(Vector2(100, 0), cb), "handoff starts")
	_expect(ctl.is_battle_entry_handoff_in_progress(), "handoff in progress")
	_expect(cam.zoom_goal >= 0.85 - 1e-4, "handoff zooms to at least 0.85")
	_expect(cam._target_goal.is_equal_approx(Vector2(100, 0)), "handoff targets the focus position")
	var z2 := cam.zoom_goal
	_expect(ctl.handle_unhandled_input(_mouse_button(MOUSE_BUTTON_WHEEL_UP, true)), "wheel during handoff is consumed")
	_expect(is_equal_approx(cam.zoom_goal, z2), "wheel during handoff does not zoom")
	_expect(not ctl.start_battle_entry_handoff(Vector2(100, 0), cb), "second handoff while running is refused")
	var space := InputEventKey.new()
	space.keycode = KEY_SPACE
	space.pressed = true
	space.echo = false
	ctl.handle_unhandled_input(space)
	_expect(calls[0] == 1, "skip calls the continue callable once")
	_expect(not ctl.is_battle_entry_handoff_in_progress(), "skip ends the handoff")
	_expect(cam.target.is_equal_approx(Vector2(100, 0)), "skip moves the camera immediately")

	# 11. natural end
	var calls2 := [0]
	var cb2 := func() -> void: calls2[0] += 1
	ctl.start_battle_entry_handoff(Vector2(50, 20), cb2)
	await create_timer(1.0).timeout
	_expect(calls2[0] == 1, "natural end calls the continue callable once")
	_expect(not ctl.is_battle_entry_handoff_in_progress(), "natural end clears in_progress")

	# 11b. skip_battle_entry_camera (03-4 host: no 3D handoff until T-WM3D-07)
	var calls_skip := [0]
	var cb_skip := func() -> void: calls_skip[0] += 1
	ctl.skip_battle_entry_camera = true
	var skip_started := ctl.start_battle_entry_handoff(Vector2(30, 10), cb_skip)
	_expect(not skip_started and calls_skip[0] == 1 and not ctl.is_battle_entry_handoff_in_progress(), "skip_battle_entry_camera: returns false, continue called once at once, not in progress")
	ctl.skip_battle_entry_camera = false
	_expect(ctl.start_battle_entry_handoff(Vector2(30, 10), cb_skip), "skip_battle_entry_camera back to false: handoff starts again")
	ctl.skip_battle_entry_handoff()

	# 12. controller without a 3D camera behaves like the 2D parent for the handoff
	var calls3 := [0]
	var cb3 := func() -> void: calls3[0] += 1
	_expect(not bare.start_battle_entry_handoff(Vector2.ZERO, cb3), "no camera: handoff returns false")
	_expect(calls3[0] == 1, "no camera: continue callable called immediately")
	bare.process_camera(0.1)
	bare.update_debug_label()
	_expect(true, "no camera: process_camera / update_debug_label run")
	bare.free()

	# 13. debug label
	ctl.update_debug_label()
	_expect(label.text.begins_with("Camera3D:"), "debug label starts with Camera3D:")

	_finish()


func _mouse_button(button: MouseButton, pressed: bool, pos := Vector2.ZERO) -> InputEventMouseButton:
	var ev := InputEventMouseButton.new()
	ev.button_index = button
	ev.pressed = pressed
	ev.position = pos
	return ev


func _motion(rel: Vector2) -> InputEventMouseMotion:
	var ev := InputEventMouseMotion.new()
	ev.relative = rel
	return ev


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("[WORLDMAP3D_CAMERA_CONTROLLER_FAIL] %s" % label)


func _finish() -> void:
	print("[WORLDMAP3D_CAMERA_CONTROLLER] %s: %d checks, %d failures" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	quit(0 if _failures == 0 else 1)
