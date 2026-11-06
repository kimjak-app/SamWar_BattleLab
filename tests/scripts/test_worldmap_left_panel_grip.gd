extends SceneTree

# CITY-HUD CH-2c: the left world status panel grip (scripts/worldmap/ui/worldmap_left_panel_grip_controller.gd),
# attached to WorldMap.tscn as a root child outside worldmap_main.gd. Runs on the real WorldMap.tscn at 1920x1080.
# a. the grip exists, is the first child of the panel's Content VBox, 14 px high, visible, move cursor
# b. dragging the grip (gui_input press + viewport mouse motion / release) moves the panel; it never leaves the screen
# c. the existing label handle (CalendarLabel) still drags the panel
# d. one grip and one controller per main, even with a second controller added
# e. the CH-2b city interior window follows the panel moved through the grip
# f. the same drag result in the 2D and the 3D map view (when the 3D view can be turned on here)

const WORLDMAP_SCENE_PATH := "res://WorldMap.tscn"
const CONTROLLER_NODE := "WorldMapLeftPanelGripController"
const CONTROLLER_SCRIPT := "res://scripts/worldmap/ui/worldmap_left_panel_grip_controller.gd"
const INTERIOR_NODE := "WorldMapCityInteriorController"
const OWN_CITY := "hanseong"
const VIEWPORT_SIZE := Vector2i(1920, 1080)

var _checks := 0
var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.size = VIEWPORT_SIZE
	_expect(change_scene_to_file(WORLDMAP_SCENE_PATH) == OK, "WorldMap scene transition starts")
	for i in 6:
		await process_frame
	var worldmap := current_scene
	_expect(worldmap != null and worldmap.scene_file_path == WORLDMAP_SCENE_PATH, "WorldMap scene loaded")
	if worldmap == null:
		_finish()
		return
	var host := worldmap.get_node_or_null("WorldMap3DHost")
	if host != null and bool(host.get("active")):
		host.call("set_map_view_3d", false)   # 2D first (does not write the settings file)
		await _settle()
	var ctl := worldmap.get_node_or_null(CONTROLLER_NODE)
	_expect(ctl != null and ctl.get("main") == worldmap, "controller node exists and found main")
	if ctl == null:
		_finish()
		return
	var panel = worldmap.get("left_world_status_panel")
	_expect(panel is PanelContainer and ctl.call("get_panel") == panel, "main's left_world_status_panel is the grip's panel")
	if not panel is PanelContainer:
		_finish()
		return

	# a. the strip
	var grip: Control = ctl.call("get_grip")
	var content := (panel as Control).get_node_or_null("MarginContainer/Content") as VBoxContainer
	_expect(grip != null and content != null and grip.get_parent() == content and grip.get_index() == 0, "grip is the first child of MarginContainer/Content")
	if grip == null:
		_finish()
		return
	_expect(grip.name == "LeftPanelGrip" and is_equal_approx(grip.custom_minimum_size.y, 14.0) and absf(grip.size.y - 14.0) <= 0.5,
		"grip named LeftPanelGrip, 14 px high (%s)" % str(grip.size))
	_expect(grip.is_visible_in_tree() and grip.mouse_filter == Control.MOUSE_FILTER_STOP and grip.mouse_default_cursor_shape == Control.CURSOR_MOVE,
		"grip visible, takes the mouse, move cursor")
	_expect(absf(grip.size.x - content.size.x) <= 0.5, "grip spans the content width (%.1f / %.1f)" % [grip.size.x, content.size.x])
	var grip_rect := grip.get_global_rect()
	var panel_rect := (panel as Control).get_global_rect()
	_expect(panel_rect.encloses(grip_rect) and grip_rect.position.y - panel_rect.position.y <= 24.0, "grip sits at the top inside the panel")

	# d. one grip, one controller
	var second: Node = load(CONTROLLER_SCRIPT).new()
	worldmap.add_child(second)
	await _settle()
	_expect(second.get("main") == null and second.call("get_grip") == null, "a second controller does not attach")
	_expect(_count_named(content, "LeftPanelGrip") == 1, "exactly one grip in the panel")
	worldmap.remove_child(second)
	second.free()
	_expect(worldmap.get_meta("wm_left_panel_grip_controller", null) == ctl, "the first controller keeps the main claim")

	# b. drag by the grip, c. drag by the existing label handle (2D)
	await _drag_checks(worldmap, panel, grip, "2d")

	# e. the open city interior window follows the panel dragged by the grip
	var interior := worldmap.get_node_or_null(INTERIOR_NODE)
	_expect(interior != null, "city interior controller exists")
	if interior != null:
		_expect(bool(interior.call("try_open", OWN_CITY)), "%s window opens" % OWN_CITY)
		await _settle()
		var start: Vector2 = (panel as Control).global_position
		await _drag(worldmap, grip, Vector2(60, 40))
		await _settle()
		var window: Control = interior.call("get_window_panel")
		var left_rect := (panel as Control).get_global_rect()
		var want := Vector2(left_rect.end.x + float(interior.DOCK_GAP), left_rect.position.y)
		_expect(not (panel as Control).global_position.is_equal_approx(start) and window.global_position.distance_to(want) <= 1.0,
			"window follows the grip drag (window %s, want %s)" % [str(window.global_position), str(want)])
		interior.call("close")

	# f. the 3D map view, when it can be turned on here
	if host != null and host.has_method("set_map_view_3d"):
		host.call("set_map_view_3d", true)
		for i in 10:
			await process_frame
		if bool(host.get("active")):
			_expect(ctl.call("get_grip") == grip and _count_named(content, "LeftPanelGrip") == 1, "3d: the same single grip")
			await _drag_checks(worldmap, panel, grip, "3d")
			host.call("set_map_view_3d", false)
			await _settle()
		else:
			print("[LEFT_PANEL_GRIP] 3d map view not available here; 2d only")
	_finish()


func _drag_checks(worldmap: Node, panel: Control, grip: Control, view: String) -> void:
	var viewport_rect := Rect2(Vector2.ZERO, Vector2(VIEWPORT_SIZE))
	var start := panel.global_position
	await _drag(worldmap, grip, Vector2(120, 80))
	_expect(panel.global_position.distance_to(start + Vector2(120, 80)) <= 1.0,
		"%s: grip drag moves the panel by (120, 80) (%s -> %s)" % [view, str(start), str(panel.global_position)])
	await _drag(worldmap, grip, Vector2(-5000, -5000))
	_expect(viewport_rect.encloses(panel.get_global_rect()), "%s: dragged far up-left, the panel stays on screen %s" % [view, str(panel.get_global_rect())])
	await _drag(worldmap, grip, Vector2(5000, 5000))
	_expect(viewport_rect.encloses(panel.get_global_rect()), "%s: dragged far down-right, the panel stays on screen %s" % [view, str(panel.get_global_rect())])
	# c. the existing label handle is still registered and drags
	var calendar = worldmap.get("calendar_label")
	var shared_ui: Node = worldmap.call("_ensure_shared_ui_controller")
	_expect(calendar is Control and _has_drag_connection(calendar, shared_ui), "%s: CalendarLabel handle still registered" % view)
	if calendar is Control:
		var before := panel.global_position
		await _drag(worldmap, calendar, Vector2(-200, -100), panel.global_position + Vector2(20, 20))
		_expect(panel.global_position.distance_to(before + Vector2(-200, -100)) <= 1.0,
			"%s: CalendarLabel drag still moves the panel (%s -> %s)" % [view, str(before), str(panel.global_position)])
	# back to the start
	await _drag(worldmap, grip, start - panel.global_position)
	_expect(panel.global_position.distance_to(start) <= 1.0, "%s: dragged back to the start" % view)


## Press on the handle (its gui_input, as the GUI would deliver it), move through the viewport, release.
func _drag(worldmap: Node, handle: Control, delta: Vector2, press_at: Vector2 = Vector2.INF) -> void:
	var from := press_at if press_at != Vector2.INF else handle.get_global_rect().get_center()
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = from
	press.global_position = from
	handle.gui_input.emit(press)
	for step in [0.5, 1.0]:
		var motion := InputEventMouseMotion.new()
		motion.position = from + delta * step
		motion.global_position = from + delta * step
		motion.relative = delta * 0.5
		root.push_input(motion)
		await process_frame
	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.pressed = false
	release.position = from + delta
	release.global_position = from + delta
	root.push_input(release)
	await process_frame


func _has_drag_connection(handle: Control, shared_ui: Node) -> bool:
	for connection in handle.get_signal_connection_list("gui_input"):
		if (connection["callable"] as Callable).get_object() == shared_ui:
			return true
	return false


func _count_named(parent: Node, node_name: String) -> int:
	var count := 0
	for child in parent.get_children():
		if str(child.name).begins_with(node_name):
			count += 1
	return count


## Two frames: the SceneTree process_frame signal fires before the nodes' _process of that frame.
func _settle() -> void:
	await process_frame
	await process_frame


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(label)
		push_error("[LEFT_PANEL_GRIP_FAIL] %s" % label)


func _finish() -> void:
	print("[LEFT_PANEL_GRIP] checks=%d failures=%s" % [_checks, str(_failures)])
	quit(0 if _failures.is_empty() else 1)
