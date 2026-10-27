extends SceneTree
# HUD block 4-4 test 4: the lab's zoom range by real mouse wheel on the scenario shell. The limits are written here:
# zoom-out 42, zoom-in 20 (unchanged), the wheel step 3. The battle starts at the limit; 20 wheel-downs stay at 42;
# wheel-ups go down by 3 to 20 and stay; one wheel-down from 20 is 23; the camera's orthographic size follows the zoom.
const OUT := 42.0
const IN := 20.0
var h

func _initialize() -> void:
	run.call_deferred()

func wheel(down: bool) -> void:
	var e := InputEventMouseButton.new()
	e.button_index = MOUSE_BUTTON_WHEEL_DOWN if down else MOUSE_BUTTON_WHEEL_UP
	e.pressed = true
	e.position = Vector2(960, 540)
	e.global_position = e.position
	root.push_input(e)
	await process_frame

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_scenario_harness.gd").new()
	await h.open_shell(self)
	root.size = Vector2i(1920, 1080) # the game's window (project.godot), no stretch
	await h.press_scenario(self, "default")
	var lab = h.lab
	for i in range(5): await process_frame
	h.expect(lab.ZOOM_MAX == OUT and lab.ZOOM_MIN == IN, "constants ZOOM_MAX %s, ZOOM_MIN %s" % [lab.ZOOM_MAX, lab.ZOOM_MIN])
	h.expect(lab.zoom == OUT and is_equal_approx(lab.camera.size, OUT), "the battle starts at the zoom-out limit (zoom %s, camera size %s)" % [lab.zoom, lab.camera.size])
	var seen := []
	for i in range(20):
		await wheel(true)
		seen.append(lab.zoom)
	h.expect(seen.all(func(z): return z == OUT), "20 wheel-downs never pass 42 (%s)" % str(seen))
	seen.clear()
	for i in range(12):
		await wheel(false)
		seen.append(lab.zoom)
	h.expect(seen == [39.0, 36.0, 33.0, 30.0, 27.0, 24.0, 21.0, 20.0, 20.0, 20.0, 20.0, 20.0], "wheel-ups: 3 per step down to 20, then stay (%s)" % str(seen))
	await wheel(true)
	h.expect(lab.zoom == 23.0 and is_equal_approx(lab.camera.size, 23.0), "one wheel-down from 20: 23 (zoom %s, camera size %s)" % [lab.zoom, lab.camera.size])
	await h.close_shell(self)
	print("[ZOOM_LIMIT] checks=", h.checks, " failures=", h.failures)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
