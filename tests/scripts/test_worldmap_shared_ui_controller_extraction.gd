extends SceneTree

const ControllerScript := preload("res://scripts/worldmap/ui/worldmap_shared_ui_controller.gd")

var _checks := 0
var _failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var owner := Node.new()
	root.add_child(owner)
	var ui_root := CanvasLayer.new()
	owner.add_child(ui_root)
	var controller := ControllerScript.new()
	owner.add_child(controller)
	controller.configure(owner, ui_root)
	controller.show_help_modal({"title": "국가충성도", "body": "설명"})
	var modal := controller.get_help_modal()
	_expect(modal != null and modal.visible, "generic help modal opens")
	_expect((modal.get_node("Content/TitleLabel") as Label).text == "국가충성도", "modal content applied")
	controller.hide_help_modal()
	_expect(not controller.is_help_modal_visible(), "generic help modal closes")
	var panel := PanelContainer.new()
	panel.size = Vector2(200.0, 100.0)
	ui_root.add_child(panel)
	controller.move_panel_to_screen_position(panel, Vector2(-1000.0, -1000.0))
	_expect(panel.global_position.x >= -128.0 and panel.global_position.y >= 0.0, "shared viewport clamp")
	controller.set_panel_click_enabled(panel, true)
	_expect(not controller.handle_input(InputEventMouseMotion.new()), "idle input is not intercepted")
	_finish()


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("[WORLDMAP_SHARED_UI_CONTROLLER_FAIL] %s" % label)


func _finish() -> void:
	print("[WORLDMAP_SHARED_UI_CONTROLLER] %s: %d checks, %d failures" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	for child in root.get_children():
		child.queue_free()
	await process_frame
	quit(0 if _failures == 0 else 1)
