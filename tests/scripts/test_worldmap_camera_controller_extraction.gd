extends SceneTree

const ControllerScript := preload("res://scripts/worldmap/camera/worldmap_camera_controller.gd")

var _checks := 0
var _failures := 0
var _continued := false


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
	tile.position = Vector2(512.0, 512.0)
	host.add_child(tile)
	var controller := ControllerScript.new()
	host.add_child(controller)
	controller.configure(camera, debug_label, host, [tile])
	_expect(camera.enabled and camera.zoom == Vector2(0.7, 0.7), "camera configured with parity zoom")
	controller.apply_zoom(10.0)
	_expect(camera.zoom == Vector2(ControllerScript.MAX_ZOOM, ControllerScript.MAX_ZOOM), "maximum zoom clamp")
	controller.apply_zoom(-10.0)
	_expect(camera.zoom == Vector2(ControllerScript.MIN_ZOOM, ControllerScript.MIN_ZOOM), "minimum zoom clamp")
	var skip_event := InputEventKey.new()
	skip_event.keycode = KEY_ESCAPE
	skip_event.pressed = true
	_expect(controller.is_battle_entry_handoff_skip_event(skip_event), "battle handoff skip input")
	_expect(controller.start_battle_entry_handoff(Vector2(512.0, 512.0), Callable(self, "_on_continued")), "battle handoff starts")
	_expect(controller.is_battle_entry_handoff_in_progress(), "battle handoff owns transition state")
	controller.skip_battle_entry_handoff()
	_expect(_continued and not controller.is_battle_entry_handoff_in_progress(), "battle handoff skip completes callback")
	_expect(debug_label.text.begins_with("Camera:"), "camera debug presentation updated")
	_finish()


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("[WORLDMAP_CAMERA_CONTROLLER_FAIL] %s" % label)


func _on_continued() -> void:
	_continued = true


func _finish() -> void:
	print("[WORLDMAP_CAMERA_CONTROLLER] %s: %d checks, %d failures" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	quit(0 if _failures == 0 else 1)
