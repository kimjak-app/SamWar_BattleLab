extends SceneTree

var _checks := 0
var _failures := 0
var _selects := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var cam := WorldMap3DCamera.new()
	root.add_child(cam)
	await process_frame
	cam.select_requested.connect(func(_pos: Vector2) -> void: _selects += 1)

	# 1. defaults
	_expect(cam.external_input == false, "external_input defaults to false")
	_expect(cam.input_scheme == "A", "input_scheme defaults to A")

	# 2. normal mode: own wheel event still zooms
	cam.zoom_goal = 0.0
	cam._unhandled_input(_wheel_up())
	_expect(is_equal_approx(cam.zoom_goal, cam.zoom_step), "normal mode: wheel event zooms by zoom_step")

	# 3. external mode: own events ignored, apply_wheel drives zoom (clamped at 0)
	cam.external_input = true
	cam.zoom_goal = 0.0
	cam._unhandled_input(_wheel_up())
	_expect(is_equal_approx(cam.zoom_goal, 0.0), "external mode: wheel event ignored")
	cam.apply_wheel(1)
	_expect(is_equal_approx(cam.zoom_goal, cam.zoom_step), "apply_wheel(1) zooms in by zoom_step")
	cam.apply_wheel(-1)
	_expect(is_equal_approx(cam.zoom_goal, 0.0), "apply_wheel(-1) zooms back out")
	cam.apply_wheel(-1)
	_expect(is_equal_approx(cam.zoom_goal, 0.0), "apply_wheel(-1) clamps at 0.0")

	# 4. scheme A: right drag rotates, release ends the drag
	cam.set_input_scheme("A")
	var yaw0 := cam.yaw_goal
	cam.apply_drag_button(MOUSE_BUTTON_RIGHT, true)
	cam.apply_drag_motion(Vector2(100, 0))
	_expect(absf(cam.yaw_goal - (yaw0 - 0.5)) < 1e-4, "scheme A: right drag 100 px rotates yaw_goal by -0.5")
	cam.apply_drag_button(MOUSE_BUTTON_RIGHT, false)
	var yaw1 := cam.yaw_goal
	cam.apply_drag_motion(Vector2(100, 0))
	_expect(is_equal_approx(cam.yaw_goal, yaw1), "scheme A: motion after right release does nothing")

	# 5. scheme B: right drag pans; middle drag pans in both schemes
	cam.set_input_scheme("B")
	var yaw2 := cam.yaw_goal
	var goal0 := cam._target_goal
	cam.apply_drag_button(MOUSE_BUTTON_RIGHT, true)
	cam.apply_drag_motion(Vector2(100, 0))
	cam.apply_drag_button(MOUSE_BUTTON_RIGHT, false)
	_expect(is_equal_approx(cam.yaw_goal, yaw2), "scheme B: right drag does not rotate")
	_expect(cam._target_goal != goal0, "scheme B: right drag pans")
	for scheme in ["A", "B"]:
		cam.set_input_scheme(scheme)
		var goal1 := cam._target_goal
		cam.apply_drag_button(MOUSE_BUTTON_MIDDLE, true)
		cam.apply_drag_motion(Vector2(100, 0))
		cam.apply_drag_button(MOUSE_BUTTON_MIDDLE, false)
		_expect(cam._target_goal != goal1, "scheme %s: middle drag pans" % scheme)
	cam.set_input_scheme("A")

	# 6. left click selects only when the pointer moved < 6 px
	_selects = 0
	cam.apply_left_button(Vector2(100, 100), true)
	cam.apply_left_button(Vector2(103, 100), false)
	_expect(_selects == 1, "left click within 6 px emits select_requested once")
	_selects = 0
	cam.apply_left_button(Vector2(100, 100), true)
	cam.apply_left_button(Vector2(120, 100), false)
	_expect(_selects == 0, "left drag of 20 px does not select")

	# 7. external axes drive pan / yaw in _process; ignored once external_input is off
	cam.set_external_axes(Vector2(1, 0), 0.0)
	var goal2 := cam._target_goal
	cam._process(0.1)
	_expect(cam._target_goal != goal2, "external pan axis moves _target_goal")
	cam.set_external_axes(Vector2.ZERO, 1.0)
	var yaw3 := cam.yaw_goal
	cam._process(0.1)
	_expect(absf(cam.yaw_goal - (yaw3 + 0.12)) < 1e-4, "external yaw axis rotates yaw_goal by +0.12 over 0.1 s")
	cam.external_input = false
	cam.set_external_axes(Vector2(1, 0), 1.0)
	var goal3 := cam._target_goal
	var yaw4 := cam.yaw_goal
	cam._process(0.1)
	_expect(cam._target_goal == goal3, "normal mode ignores external pan axis")
	_expect(is_equal_approx(cam.yaw_goal, yaw4), "normal mode ignores external yaw axis")
	cam.set_external_axes(Vector2.ZERO, 0.0)

	# 8. manual freezes own input even outside external mode
	cam.manual = true
	cam.zoom_goal = 0.0
	cam._unhandled_input(_wheel_up())
	_expect(is_equal_approx(cam.zoom_goal, 0.0), "manual mode: wheel event ignored")
	cam.manual = false

	_finish()


func _wheel_up() -> InputEventMouseButton:
	var ev := InputEventMouseButton.new()
	ev.button_index = MOUSE_BUTTON_WHEEL_UP
	ev.pressed = true
	return ev


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("[WORLDMAP3D_CAMERA_EXTERNAL_INPUT_FAIL] %s" % label)


func _finish() -> void:
	print("[WORLDMAP3D_CAMERA_EXTERNAL_INPUT] %s: %d checks, %d failures" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	quit(0 if _failures == 0 else 1)
