extends SceneTree

# CITY-HUD CH-2: the city interior window frame (scripts/worldmap/ui/worldmap_city_interior_controller.gd), attached
# to WorldMap.tscn as a root child outside worldmap_main.gd. Runs on the real WorldMap.tscn in the 2D map view.
# 1. open-condition table (own / enemy / Karakorum no_art / every busy guard / battle-entry handoff / modals)
# 2. main state unchanged by the controller   3. close() + Esc (Esc consumed only while open)
# 4. CH-2b: not modal - no InputBlocker, the 3D camera input_blocked is never set (open, close, _exit_tree)
# 5. the main member names the controller relies on still exist   6. one connection per marker, one window, retarget
# 7. CH-2b dock: right of the left status panel, top aligned (1 px); width = ratio / minimum rule; follows the moved
#    left panel; shrinks to clear the right city panel but never below the minimum; an enemy city click closes it
# 8. HUDFIX: the window is the picture only (no TitleLabel / CloseButton, empty panel style, window = InteriorArea);
#    real mouse events through the viewport: an empty-map click (< 6 px) closes; a drag of 6 px or more keeps it; a map
#    click that picks an own city keeps it / retargets, an enemy city closes; presses on the window, the left panel grip,
#    the left panel, the right panel, a top menu button and the turn button keep it open

const WORLDMAP_SCENE_PATH := "res://WorldMap.tscn"
const CONTROLLER_NODE := "WorldMapCityInteriorController"
const CAMERA_3D_CONTROLLER_PATH := "res://scripts/worldmap/map3d/worldmap_3d_camera_controller.gd"
const OWN_CITY := "hanseong"
const SECOND_CITY := "gyeongju"
const ENEMY_CITY := "pyeongyang"
const NO_ART_CITY := "karakorum"
const TEST_VIEWPORT_SIZE := Vector2i(1920, 1080)
const EMPTY_MAP_POINT := Vector2(1000, 760)   # 2D map at 1920x1080: no HUD control, no city marker

var _checks := 0
var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_expect(change_scene_to_file(WORLDMAP_SCENE_PATH) == OK, "WorldMap scene transition starts")
	for i in 4:
		await process_frame
	var worldmap := current_scene
	_expect(worldmap != null and worldmap.scene_file_path == WORLDMAP_SCENE_PATH, "WorldMap scene loaded")
	if worldmap == null:
		_finish()
		return
	var host := worldmap.get_node_or_null("WorldMap3DHost")
	if host != null and bool(host.get("active")):
		host.call("set_map_view_3d", false)   # 2D map view baseline (does not write the settings file)
		await process_frame
	print("[CITY_INTERIOR] map view: %s" % ("3d" if host != null and bool(host.get("active")) else "2d"))
	var ctl := worldmap.get_node_or_null(CONTROLLER_NODE)
	_expect(ctl != null, "controller node exists in WorldMap.tscn")
	if ctl == null:
		_finish()
		return
	_expect(ctl.get("main") == worldmap, "controller found main")

	# 5. main members the controller reads still exist
	var members: Array = []
	for guard in ctl.BUSY_GUARDS + ctl.MODAL_GUARDS:
		members.append(guard[1])
	members.append_array(ctl.MAIN_MEMBERS)
	for member in members:
		_expect((member in worldmap) or worldmap.has_method(member), "main member exists: %s" % member)

	# 6. exactly one deferred connection per marker
	var markers: Dictionary = worldmap.get("_city_markers_by_id")
	var bad_connections: Array[String] = []
	for city_id in markers:
		var count := 0
		for connection in (markers[city_id] as Node).get_signal_connection_list("city_selected"):
			var callable: Callable = connection["callable"]
			if callable.get_object() == ctl:
				count += 1
				if (int(connection["flags"]) & CONNECT_DEFERRED) == 0:
					bad_connections.append("%s not deferred" % city_id)
		if count != 1:
			bad_connections.append("%s x%d" % [city_id, count])
	_expect(not markers.is_empty() and bad_connections.is_empty(), "one deferred connection per marker %s" % str(bad_connections))
	_expect(int(ctl.call("get_connected_marker_count")) == markers.size(), "controller connected every marker")
	for city_id in [OWN_CITY, SECOND_CITY, ENEMY_CITY, NO_ART_CITY]:
		_expect(markers.has(city_id), "marker exists: %s" % city_id)
	if not (markers.has(OWN_CITY) and markers.has(SECOND_CITY) and markers.has(ENEMY_CITY) and markers.has(NO_ART_CITY)):
		_finish()
		return
	var player_faction := str(worldmap.call("_get_current_player_faction_id"))
	_expect(bool(worldmap.call("_is_city_owned_by_player_mvp", OWN_CITY)), "%s starts player-owned" % OWN_CITY)

	# 1a. own city click (real signal path, main handles first)
	await _click(markers[OWN_CITY])
	_expect(bool(ctl.call("is_open")) and str(ctl.call("get_open_city_id")) == OWN_CITY, "own city click opens the window")
	_expect(str(ctl.get("last_reject_reason")) == "", "own city: no reject reason")
	_expect(str(worldmap.get("selected_city_id")) == OWN_CITY, "main processed the click (selected_city_id)")
	_expect_picture_only(ctl, OWN_CITY, "own city click")
	await process_frame
	await _check_dock(ctl, worldmap)
	await _check_outside_click(ctl, worldmap, markers, player_faction)
	ctl.call("try_open", OWN_CITY)   # back to the state before section 8 (open on the own city)

	# 6. same city again: still one window, not reopened
	await _click(markers[OWN_CITY])
	_expect(bool(ctl.call("is_open")) and str(ctl.get("last_reject_reason")) == "already_open", "same city again -> already_open")
	_expect(_count_layers(ctl) == 1, "one window layer")
	ctl.call("close")

	# 1b. enemy city click (real signal path)
	await _click(markers[ENEMY_CITY])
	_expect(not bool(ctl.call("is_open")) and str(ctl.get("last_reject_reason")) == "not_own_city", "enemy city click -> not_own_city")
	# 7. CH-2b: an enemy city click closes the open window
	ctl.call("try_open", OWN_CITY)
	await _click(markers[ENEMY_CITY])
	_expect(not bool(ctl.call("is_open")) and str(ctl.get("last_reject_reason")) == "not_own_city", "enemy city click closes the open window")
	_expect((ctl.call("get_canvas") as Control).get_child_count() == 0, "closed by an enemy click: textures released")

	# 2. main state snapshot after main's own click handling; no more clicks below, only controller operations
	var player_state: Dictionary = worldmap.get("_player_state")
	var snapshot := [str(worldmap.get("selected_city_id")), str(player_state.get("selected_city_id", "")), str(player_state.get("origin_city_id", ""))]

	# 6. another own city: content retargets
	ctl.call("try_open", OWN_CITY)
	var second_owner := str(markers[SECOND_CITY].get("owner_faction_id"))
	markers[SECOND_CITY].set("owner_faction_id", player_faction)
	_expect(bool(ctl.call("try_open", SECOND_CITY)) and str(ctl.call("get_open_city_id")) == SECOND_CITY, "another own city retargets the open window")
	_expect_picture_only(ctl, SECOND_CITY, "retarget")
	_expect(_count_layers(ctl) == 1, "still one window layer after retarget")
	markers[SECOND_CITY].set("owner_faction_id", second_owner)

	# 3. close()
	ctl.call("close")
	_expect(not bool(ctl.call("is_open")), "close() closes")
	# 3. Esc while open closes (through the viewport input pipeline)
	ctl.call("try_open", OWN_CITY)
	root.push_input(_esc())
	await process_frame
	_expect(not bool(ctl.call("is_open")), "Esc closes the open window")
	# Esc while closed: not consumed by the controller -> main's own Esc handler (help modal) still gets it
	var help_modal: Control = worldmap.call("_ensure_shared_ui_controller").call("ensure_help_modal")
	_expect(help_modal != null, "help modal available")
	if help_modal != null:
		help_modal.visible = true
		root.push_input(_esc())
		await process_frame
		_expect(not help_modal.visible, "Esc while closed reaches main (help modal closed by main)")
	_expect(not bool(ctl.call("is_open")), "Esc while closed keeps it closed")

	# 4. CH-2b: the 3D camera input is never blocked (fake 3D camera controller swapped in, no camera attached)
	var original_camera_controller = worldmap.get("_camera_controller")
	if "input_blocked" in original_camera_controller:
		ctl.call("try_open", OWN_CITY)
		_expect(not bool(original_camera_controller.get("input_blocked")), "real 3D camera controller not blocked while open")
		ctl.call("close")
		_expect(not bool(original_camera_controller.get("input_blocked")), "real 3D camera controller not blocked after close")
	var fake_3d: Node = load(CAMERA_3D_CONTROLLER_PATH).new()
	worldmap.set("_camera_controller", fake_3d)
	ctl.call("try_open", OWN_CITY)
	_expect(not bool(fake_3d.get("input_blocked")), "3D camera input not blocked while open")
	ctl.call("close")
	_expect(not bool(fake_3d.get("input_blocked")), "3D camera input not blocked after close")
	fake_3d.set("_battle_entry_handoff_in_progress", true)
	_expect_reject(ctl, OWN_CITY, "battle_entry_handoff", "battle-entry handoff")
	fake_3d.set("_battle_entry_handoff_in_progress", false)
	worldmap.set("_camera_controller", original_camera_controller)

	# 1c. reject table
	var karakorum_owner := str(markers[NO_ART_CITY].get("owner_faction_id"))
	markers[NO_ART_CITY].set("owner_faction_id", player_faction)
	_expect_reject(ctl, NO_ART_CITY, "no_art", "Karakorum as own city")
	markers[NO_ART_CITY].set("owner_faction_id", karakorum_owner)

	for setting in [
		["_contextual_worldmap_action_pending", true], ["_pending_diplomacy_action_id", "test"],
		["_pending_spy_action_id", "test"], ["_pending_trade_action_id", "test"],
		["_enemy_turn_mvp_pending", true], ["_domestic_turn_apply_pending", true],
	]:
		var before = worldmap.get(setting[0])
		worldmap.set(setting[0], setting[1])
		_expect_reject(ctl, OWN_CITY, "busy:%s" % setting[0], setting[0])
		worldmap.set(setting[0], before)
	for state_case in [
		["pending_invasion_event", {"event_id": "test"}, "busy:_has_pending_invasion_event_mvp"],
		["pending_battle_context", {"transaction_id": "test"}, "busy:_get_pending_battle_context_mvp"],
		["turn_phase", "enemy", "busy:_player_state"],
		["game_outcome", {"status": "victory"}, "modal:_has_terminal_korea_outcome_mvp"],
	]:
		var had := player_state.has(state_case[0])
		var before = player_state.get(state_case[0])
		player_state[state_case[0]] = state_case[1]
		_expect_reject(ctl, OWN_CITY, state_case[2], "_player_state.%s" % state_case[0])
		if had:
			player_state[state_case[0]] = before
		else:
			player_state.erase(state_case[0])
	for panel_member in ["_player_attack_deployment_panel", "_manual_trade_order_panel", "_internal_trade_transfer_panel", "_t05_outcome_presentation_root"]:
		var before = worldmap.get(panel_member)
		var fake_panel: Control = PanelContainer.new() if panel_member != "_t05_outcome_presentation_root" else Control.new()
		fake_panel.visible = true
		worldmap.set(panel_member, fake_panel)
		var prefix := "busy:" if panel_member == "_player_attack_deployment_panel" else "modal:"
		_expect_reject(ctl, OWN_CITY, prefix + panel_member, "%s visible" % panel_member)
		worldmap.set(panel_member, before)
		fake_panel.free()
	worldmap.call("_open_domestic_tech_tree_overlay_mvp")
	await process_frame
	_expect_reject(ctl, OWN_CITY, "modal:_is_domestic_tech_tree_overlay_open_mvp", "tech tree overlay open")
	worldmap.call("_close_domestic_tech_tree_overlay_mvp")
	await process_frame
	if help_modal != null:
		help_modal.visible = true
		_expect_reject(ctl, OWN_CITY, "modal:_ensure_shared_ui_controller", "help modal visible")
		help_modal.visible = false
	_expect(bool(ctl.call("try_open", OWN_CITY)), "opens again once every guard is cleared")
	ctl.call("close")

	# 2. main unchanged by all controller operations
	player_state = worldmap.get("_player_state")
	var after := [str(worldmap.get("selected_city_id")), str(player_state.get("selected_city_id", "")), str(player_state.get("origin_city_id", ""))]
	_expect(after == snapshot, "main selection state unchanged by the controller %s -> %s" % [str(snapshot), str(after)])

	# 4. _exit_tree while open: the 3D camera input stays unblocked
	worldmap.set("_camera_controller", fake_3d)
	ctl.call("try_open", OWN_CITY)
	_expect(not bool(fake_3d.get("input_blocked")), "not blocked before scene removal")
	worldmap.remove_child(ctl)
	_expect(not bool(fake_3d.get("input_blocked")), "_exit_tree leaves the 3D camera input unblocked")
	_expect(not worldmap.has_meta("wm_city_interior_controller"), "_exit_tree releases the main claim")
	worldmap.set("_camera_controller", original_camera_controller)
	ctl.free()
	fake_3d.free()
	_finish()


## 7. CH-2b dock rule on the open window (the real left / right panels of main, moved and restored here).
func _check_dock(ctl: Node, worldmap: Node) -> void:
	var window: Control = ctl.call("get_window_panel")
	_expect(window != null and window.get_parent() is CanvasLayer, "the window is a direct child of the window layer")
	if window == null:
		return
	var layer := window.get_parent()
	_expect(layer.get_node_or_null("InputBlocker") == null and layer.get_child_count() == 1, "no InputBlocker: only the window on the layer")
	_expect(window.mouse_filter == Control.MOUSE_FILTER_STOP, "the window itself takes clicks on it")
	var left = worldmap.get("left_world_status_panel")
	var right = worldmap.get("city_info_panel_control")
	_expect(left is Control and right is Control, "main panels readable (left_world_status_panel, city_info_panel_control)")
	if not (left is Control and right is Control):
		return
	var viewport_size_before := root.size
	root.size = TEST_VIEWPORT_SIZE   # headless starts with a small window; the dock rule is checked at 1920x1080
	var right_visible_before: bool = right.visible
	right.visible = false   # the dock rule without the right panel first
	await _settle()
	var viewport_width := window.get_viewport().get_visible_rect().size.x
	var want_width := maxf(viewport_width * 0.307, 400.0)
	_expect(is_equal_approx(ctl.WINDOW_WIDTH_RATIO, 0.307) and is_equal_approx(ctl.MIN_WINDOW_WIDTH, 400.0) and is_equal_approx(ctl.DOCK_GAP, 12.0),
		"dock constants 0.307 / 400 / 12")
	_expect(is_equal_approx(viewport_width, TEST_VIEWPORT_SIZE.x) and absf(want_width - 589.44) <= 0.01, "viewport %d -> width %.2f" % [int(viewport_width), want_width])
	_expect_dock(ctl, window, left, want_width, "docked right of the left panel")
	# the body keeps 1280:768 and the canvas k follows the body width
	var area: Control = ctl.call("get_interior_area")
	_expect(absf(area.size.y - area.size.x * 768.0 / 1280.0) <= 1.0, "body ratio 1280:768 (%s)" % str(area.size))
	var canvas: Control = ctl.call("get_canvas")
	if canvas.visible:
		_expect(absf(canvas.scale.x - area.size.x / 1280.0) <= 0.001, "canvas k = body width / 1280 (%.4f)" % canvas.scale.x)
	# follows the moved left panel
	var left_before: Vector2 = left.position
	left.position = left_before + Vector2(40, 30)
	await _settle()
	_expect(left.position.is_equal_approx(left_before + Vector2(40, 30)), "the left panel stays where it was moved (%s)" % str(left.position))
	_expect_dock(ctl, window, left, want_width, "follows the moved left panel")
	left.position = left_before
	await _settle()
	_expect_dock(ctl, window, left, want_width, "follows the left panel back")
	# the right panel overlapping: shrink to clear it, never below the minimum
	var right_before: Vector2 = right.global_position
	right.visible = true
	var dock_x: float = left.get_global_rect().end.x + ctl.DOCK_GAP
	right.global_position = Vector2(dock_x + 450.0 + ctl.DOCK_GAP, right_before.y)   # room for 450 px
	await _settle()
	_expect(absf(window.size.x - 450.0) <= 1.0 and absf(window.global_position.x - dock_x) <= 1.0, "shrinks to clear the right panel (%.1f, want 450)" % window.size.x)
	right.global_position = Vector2(dock_x + 200.0 + ctl.DOCK_GAP, right_before.y)   # room for 200 px only
	await _settle()
	_expect(absf(window.size.x - ctl.MIN_WINDOW_WIDTH) <= 1.0, "never below the minimum width (%.1f)" % window.size.x)
	right.global_position = right_before
	# the left panel hidden: the fallback corner
	right.visible = false
	left.visible = false
	await _settle()
	_expect(window.global_position.distance_to(ctl.FALLBACK_POSITION) <= 1.0, "left panel hidden: window at the fallback corner (%s)" % str(window.global_position))
	left.visible = true
	# a narrow viewport: 1000 x 0.307 < 400 -> the minimum width
	root.size = Vector2i(1000, 700)
	await _settle()
	_expect_dock(ctl, window, left, 400.0, "narrow viewport -> minimum width")
	right.visible = right_visible_before
	root.size = viewport_size_before
	await _settle()


## 8. HUDFIX: no title bar or close button; the window is exactly the picture area; the right city is open.
func _expect_picture_only(ctl: Node, city_id: String, label: String) -> void:
	var window: Control = ctl.call("get_window_panel")
	var area: Control = ctl.call("get_interior_area")
	_expect(window != null and window.find_child("TitleLabel", true, false) == null and window.find_child("CloseButton", true, false) == null
		and not ctl.has_method("get_title_text") and not ctl.has_method("get_close_button"), "%s: no title bar, no close button" % label)
	_expect(bool(ctl.call("is_open")) and str(ctl.call("get_open_city_id")) == city_id, "%s: open on %s (%s)" % [label, city_id, str(ctl.call("get_open_city_id"))])
	if window == null or area == null:
		return
	var style := window.get_theme_stylebox("panel")
	_expect(style is StyleBoxEmpty and style.get_minimum_size() == Vector2.ZERO and window.get_child_count() == 1 and area.get_parent() == window,
		"%s: empty panel style, the picture area is the window's only child" % label)


## 8. HUDFIX: closing by a click on the empty map (real mouse events pushed through the viewport, 2D map view).
func _check_outside_click(ctl: Node, worldmap: Node, markers: Dictionary, player_faction: String) -> void:
	var viewport_size_before := root.size
	root.size = TEST_VIEWPORT_SIZE
	await _settle()
	var window: Control = ctl.call("get_window_panel")
	var area: Control = ctl.call("get_interior_area")
	_expect(window.size.is_equal_approx(area.size) and window.global_position.is_equal_approx(area.global_position) and area.size.x > 300.0,
		"window rect = picture rect, zero padding (window %s %s, picture %s %s)" % [str(window.global_position), str(window.size), str(area.global_position), str(area.size)])
	_expect(is_equal_approx(ctl.CLICK_MOVE_LIMIT, 6.0) and ctl.OUTSIDE_CLICK_SETTLE_FRAMES == 2, "click limit 6 px, 2 settle frames")
	var empty := EMPTY_MAP_POINT
	# empty map click (< 6 px): closes
	await _mouse_press(empty, true)
	_expect(bool(ctl.get("_outside_press")), "an empty-map press reaches the controller (no HUD control took it)")
	await _mouse_press(empty + Vector2(3, 2), false)
	await _settle()
	await process_frame
	_expect(not bool(ctl.call("is_open")), "empty-map click (3.6 px move) closes the window")
	# drag of 6 px or more, then release: stays open
	ctl.call("try_open", OWN_CITY)
	await _settle()
	await _mouse_press(empty, true)
	await _mouse_motion(empty + Vector2(30, 10))
	await _mouse_press(empty + Vector2(30, 10), false)
	await _settle()
	await process_frame
	_expect(bool(ctl.call("is_open")), "map drag (31.6 px) then release keeps the window open")
	await _mouse_press(empty, true)
	await _mouse_press(empty + Vector2(6, 0), false)
	await _settle()
	await process_frame
	_expect(bool(ctl.call("is_open")), "exactly 6 px between press and release is a drag: stays open")
	# a map click that picks a city (the pick lands between the press and the release, as a 2D marker / 3D region pick)
	var second_owner := str(markers[SECOND_CITY].get("owner_faction_id"))
	markers[SECOND_CITY].set("owner_faction_id", player_faction)
	for case in [[OWN_CITY, true, OWN_CITY, "same own city"], [SECOND_CITY, true, SECOND_CITY, "another own city retargets"], [ENEMY_CITY, false, "", "enemy city closes"]]:
		ctl.call("try_open", OWN_CITY)
		await _settle()
		await _mouse_press(empty, true)
		markers[case[0]].emit_signal("city_selected", markers[case[0]])
		await process_frame
		await _mouse_press(empty, false)
		await _settle()
		await process_frame
		_expect(bool(ctl.call("is_open")) == case[1] and str(ctl.call("get_open_city_id")) == case[2],
			"map click picking %s: %s (open %s, city %s)" % [case[0], case[3], str(ctl.call("is_open")), str(ctl.call("get_open_city_id"))])
	markers[SECOND_CITY].set("owner_faction_id", second_owner)
	# presses on HUD controls never close: press there, release elsewhere on the map (no button fires)
	var targets: Array = [["the window", window]]
	var grip_ctl := worldmap.get_node_or_null("WorldMapLeftPanelGripController")
	targets.append(["the left panel grip", grip_ctl.call("get_grip") if grip_ctl != null else null])
	targets.append(["the left panel", worldmap.get("left_world_status_panel")])
	targets.append(["the right panel", worldmap.get("city_info_panel_control")])
	targets.append(["a top menu button", _first_visible_button(worldmap.get_node_or_null("TopNavCanvas"))])
	var compass := worldmap.find_child("TurnEndCompass", true, false)
	targets.append(["the turn button", compass.get_node_or_null("TurnEndHitArea") if compass != null else null])
	for target in targets:
		ctl.call("try_open", OWN_CITY)
		await _settle()
		var node := target[1] as Control
		_expect(node != null and node.is_visible_in_tree(), "%s exists and is visible" % target[0])
		if node == null or not node.is_visible_in_tree():
			continue
		var at := _hud_point(node, window)
		await _mouse_motion(at)
		await _mouse_press(at, true)
		_expect(not bool(ctl.get("_outside_press")), "a press on %s does not reach the map (%s)" % [target[0], str(at)])
		await _mouse_motion(empty)
		await _mouse_press(empty, false)
		await _settle()
		await process_frame
		_expect(bool(ctl.call("is_open")) and str(ctl.call("get_open_city_id")) == OWN_CITY, "a press on %s keeps the window open" % target[0])
	# Esc still closes
	root.push_input(_esc())
	await process_frame
	_expect(not bool(ctl.call("is_open")), "Esc closes (picture-only window)")
	root.size = viewport_size_before
	await _settle()


## A point on the control that no other HUD control covers: its centre, or for a control under the window a point
## beside the window (the left panel's top part sits left of the window).
func _hud_point(node: Control, window: Control) -> Vector2:
	var rect := node.get_global_rect()
	var point := rect.get_center()
	if node != window and window.get_global_rect().has_point(point):
		point = Vector2(rect.position.x + minf(20.0, rect.size.x * 0.5), rect.get_center().y)
	return point


func _first_visible_button(node: Node) -> Control:
	if node == null:
		return null
	if node is BaseButton and (node as Control).is_visible_in_tree() and (node as Control).mouse_filter == Control.MOUSE_FILTER_STOP:
		return node
	for child in node.get_children():
		var found := _first_visible_button(child)
		if found != null:
			return found
	return null


func _mouse_press(at: Vector2, pressed: bool) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	event.position = at
	event.global_position = at
	root.push_input(event)
	await process_frame


func _mouse_motion(at: Vector2) -> void:
	var event := InputEventMouseMotion.new()
	event.position = at
	event.global_position = at
	root.push_input(event)
	await process_frame


## Two frames: the SceneTree process_frame signal fires before the nodes' _process of that frame.
func _settle() -> void:
	await process_frame
	await process_frame


func _expect_dock(ctl: Node, window: Control, left: Control, want_width: float, label: String) -> void:
	var left_rect := left.get_global_rect()
	var want_position := Vector2(left_rect.end.x + ctl.DOCK_GAP, left_rect.position.y)
	_expect(window.global_position.distance_to(want_position) <= 1.0 and absf(window.size.x - want_width) <= 1.0,
		"%s: window %s size %s, want %s width %.1f" % [label, str(window.global_position), str(window.size), str(want_position), want_width])


func _click(marker: Node) -> void:
	marker.emit_signal("city_selected", marker)
	await process_frame
	await process_frame


func _esc() -> InputEventKey:
	var event := InputEventKey.new()
	event.pressed = true
	event.keycode = KEY_ESCAPE
	return event


func _count_layers(ctl: Node) -> int:
	var count := 0
	for child in ctl.get_children():
		if child is CanvasLayer:
			count += 1
	return count


func _expect_reject(ctl: Node, city_id: String, reason: String, label: String) -> void:
	var opened := bool(ctl.call("try_open", city_id))
	_expect(not opened and not bool(ctl.call("is_open")) and str(ctl.get("last_reject_reason")) == reason,
		"%s -> %s (got %s)" % [label, reason, str(ctl.get("last_reject_reason"))])
	if opened:
		ctl.call("close")


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(label)
		push_error("[CITY_INTERIOR_FAIL] %s" % label)


func _finish() -> void:
	print("[CITY_INTERIOR] checks=%d failures=%s" % [_checks, str(_failures)])
	quit(0 if _failures.is_empty() else 1)
