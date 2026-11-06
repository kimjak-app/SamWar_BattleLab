extends SceneTree

# INTEGRATE F6 smoke: the three HUD pieces merged into one branch live together on the real WorldMap.tscn (1920x1080).
# a. TurnEndCompass (day/night turn button) has the new sky layer SkyA
# b. the LeftPanelGrip strip is the first child of the left status panel's Content
# c. exactly one city interior controller; opening hanseong docks the window right of the left panel
# d. with all three present, one click on the turn button sends turn_end_requested once
#    (a second click during the turn presentation sends nothing)

const WORLDMAP_SCENE_PATH := "res://WorldMap.tscn"
const INTERIOR_SCRIPT_SUFFIX := "worldmap_city_interior_controller.gd"
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
	for i in 10:
		await process_frame
	var worldmap := current_scene
	_expect(worldmap != null and worldmap.scene_file_path == WORLDMAP_SCENE_PATH, "WorldMap scene loaded")
	if worldmap == null:
		_finish()
		return
	var host := worldmap.get_node_or_null("WorldMap3DHost")
	print("[INTEGRATED_HUD_SMOKE] map view: %s" % ("3d" if host != null and bool(host.get("active")) else "2d"))

	# a. the day/night turn button
	var compass := worldmap.get_node_or_null("WorldMapUI/TurnEndCompass") as Control
	_expect(compass != null and compass.has_signal("turn_end_requested"), "TurnEndCompass exists with turn_end_requested")
	_expect(compass != null and compass.get_node_or_null("SkyA") is TextureRect and compass.get_node_or_null("TurnEndHitArea") != null,
		"TurnEndCompass has the sky layer SkyA and the TurnEndHitArea")

	# b. the left panel grip
	var panel = worldmap.get("left_world_status_panel")
	var content := (panel as Control).get_node_or_null("MarginContainer/Content") if panel is Control else null
	var first: Node = content.get_child(0) if content != null and content.get_child_count() > 0 else null
	_expect(first != null and first.name == "LeftPanelGrip" and (first as Control).is_visible_in_tree(), "LeftPanelGrip is the first visible child of the left panel's Content")

	# c. one city interior controller, hanseong docks right of the left panel
	var interiors := _find_by_script(worldmap, INTERIOR_SCRIPT_SUFFIX)
	_expect(interiors.size() == 1, "exactly one city interior controller (%d)" % interiors.size())
	var interior := worldmap.get_node_or_null(INTERIOR_NODE)
	if interior != null and panel is Control:
		_expect(bool(interior.call("try_open", OWN_CITY)), "%s window opens" % OWN_CITY)
		await _settle()
		var window: Control = interior.call("get_window_panel")
		var left_rect := (panel as Control).get_global_rect()
		var want := Vector2(left_rect.end.x + float(interior.DOCK_GAP), left_rect.position.y)
		_expect(window != null and window.is_visible_in_tree() and window.global_position.distance_to(want) <= 1.0,
			"window docks right of the left panel (window %s, want %s)" % [str(window.global_position) if window != null else "null", str(want)])
	else:
		_expect(false, "city interior controller node and left panel exist")

	# d. all three present: one click -> one turn_end_requested
	if compass != null and compass.get_node_or_null("TurnEndHitArea") != null:
		var calls := [0]
		compass.connect("turn_end_requested", func(): calls[0] += 1)
		var hit := compass.get_node("TurnEndHitArea") as Control
		var deadline := Time.get_ticks_msec() + 5000
		while not hit.is_visible_in_tree() and Time.get_ticks_msec() < deadline:
			await process_frame
		_expect(hit.is_visible_in_tree(), "turn button click area is available")
		var circle: Dictionary = compass.call("get_window_circle")
		var at: Vector2 = compass.get_global_rect().position + (circle.get("center", Vector2(120, 120)) as Vector2)
		await _click(at)
		_expect(calls[0] == 1, "one click -> one turn_end_requested (%d)" % calls[0])
		await _click(at)
		_expect(calls[0] == 1, "a second click during the turn presentation sends nothing (%d)" % calls[0])
		deadline = Time.get_ticks_msec() + 15000
		while bool(compass.get("_serializing_turn_end")) and Time.get_ticks_msec() < deadline:
			await process_frame
		print("[INTEGRATED_HUD_SMOKE] turn presentation finished: %s" % str(not bool(compass.get("_serializing_turn_end"))))
		_expect(calls[0] == 1, "still exactly one turn_end_requested after the turn (%d)" % calls[0])
	if interior != null:
		interior.call("close")
	_finish()


func _find_by_script(node: Node, suffix: String) -> Array:
	var found := []
	var script = node.get_script()
	if script != null and str(script.resource_path).ends_with(suffix):
		found.append(node)
	for child in node.get_children():
		found += _find_by_script(child, suffix)
	return found


func _click(at: Vector2) -> void:
	var motion := InputEventMouseMotion.new()
	motion.position = at
	motion.global_position = at
	root.push_input(motion)
	await process_frame
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.position = at
		event.global_position = at
		root.push_input(event)
		await process_frame


func _settle() -> void:
	await process_frame
	await process_frame


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if condition:
		print("[PASS] %s" % label)
	else:
		_failures.append(label)
		push_error("[FAIL] %s" % label)


func _finish() -> void:
	print("[INTEGRATED_HUD_SMOKE] checks=%d failures=%d" % [_checks, _failures.size()])
	for failure in _failures:
		print("  FAIL: %s" % failure)
	quit(0 if _failures.is_empty() and _checks > 0 else 1)
