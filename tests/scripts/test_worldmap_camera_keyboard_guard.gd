extends SceneTree

const ControllerScript := preload("res://scripts/worldmap/camera/worldmap_camera_controller.gd")

var _checks := 0
var _failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var host := Node2D.new()
	root.add_child(host)
	var camera := Camera2D.new()
	host.add_child(camera)
	var debug_label := Label.new()
	host.add_child(debug_label)
	var tile := Sprite2D.new()
	tile.texture = ImageTexture.create_from_image(Image.create(1024, 1024, false, Image.FORMAT_RGBA8))
	# Scaled so the clamped camera has room to pan inside the 1920x1080 viewport.
	tile.scale = Vector2(4.0, 4.0)
	tile.position = Vector2(2048.0, 2048.0)
	host.add_child(tile)
	var controller := ControllerScript.new()
	host.add_child(controller)
	controller.configure(camera, debug_label, host, [tile])
	var configured_position := camera.position

	_expect(not controller._is_keyboard_camera_blocked(), "no text field focus does not block")
	var line_edit := LineEdit.new()
	host.add_child(line_edit)
	line_edit.grab_focus()
	_expect(controller._is_keyboard_camera_blocked(), "focused LineEdit blocks")
	line_edit.release_focus()
	_expect(not controller._is_keyboard_camera_blocked(), "released LineEdit does not block")
	var text_edit := TextEdit.new()
	host.add_child(text_edit)
	text_edit.grab_focus()
	_expect(controller._is_keyboard_camera_blocked(), "focused TextEdit blocks")
	text_edit.release_focus()
	_expect(not controller._is_keyboard_camera_blocked(), "released TextEdit does not block")

	_press_key(KEY_D, true)
	await process_frame
	if Input.is_key_pressed(KEY_D):
		line_edit.grab_focus()
		controller.process_camera(0.1)
		_expect(camera.position == configured_position, "focused LineEdit keeps camera still")
		line_edit.release_focus()
		controller.process_camera(0.1)
		_expect(camera.position.x > configured_position.x, "unfocused key D pans camera right")
	else:
		print("[WORLDMAP_CAMERA_KEYBOARD_GUARD] key simulation unavailable; movement checks skipped")
	_press_key(KEY_D, false)
	await process_frame
	_finish()


func _press_key(keycode: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = keycode
	event.physical_keycode = keycode
	event.pressed = pressed
	Input.parse_input_event(event)
	Input.flush_buffered_events()


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("[WORLDMAP_CAMERA_KEYBOARD_GUARD_FAIL] %s" % label)


func _finish() -> void:
	print("[WORLDMAP_CAMERA_KEYBOARD_GUARD] %s: %d checks, %d failures" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	quit(0 if _failures == 0 else 1)
