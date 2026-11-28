extends SceneTree

# Queue 43: 3D HUD window layout (WorldMap.tscn; 3D map when the 3D track is built, else the 2D map view).
# At 1920x1080, 1600x900 and 1280x720, with 한성 (own city) selected and its city interior picture open:
#  1. every top menu (8) pressed one by one: the windows on screen (left status, right city, the centre menu window,
#     the trade order window, the picture when shown) overlap nowhere (intersection area 0) and are inside the screen;
#     a scrolled window keeps its content at least as wide as the content needs (no cut text)
#  2. (addendum 7) trade for an own city: the order window takes the trade tab's place (CityDetailPanel hidden, the
#     order window where it was); cancel brings 한성's trade tab back; the trade tab's internal / manual button opens the
#     internal transfer window under the same rule; the city action "교역" (order window without the top menu) turns
#     into the trade menu with the same layout
#  3. (addendum 7) in every state above: a map click outside the windows reaches the map, the turn button is not covered
#  4. one centre menu window at a time; the same menu again closes it (queue 41 rule)
#  6. the picture: shown -> no overlap with the menu window; overlapping -> folded (open city kept); menu closed ->
#     shown again; width = max(screen width x 0.20, 320)
#  7. draw order: top bar >= menu windows / popups > left / right panels > the picture > the 3D map; the tech tree
#     overlay above all
#  8. (addendum 8) a city click does not open the picture; the "성 내부 보기" button in the right city panel does;
#     another city click closes it
#  plus: tech tree menu opens the full-screen overlay above every window

const WORLDMAP_SCENE_PATH := "res://WorldMap.tscn"
const OWN_CITY := "hanseong"
const RESOLUTIONS := [Vector2i(1920, 1080), Vector2i(1600, 900), Vector2i(1280, 720)]
const MENUS := [&"techtree", &"military", &"personnel", &"diplomacy", &"trade", &"intel", &"info", &"system"]
const PANEL_GAP := 12.0
const MANUAL_MODE := "manual"   # TradeController.TRADE_CONTROL_MODE_MANUAL
const TechTreePresentation := preload("res://scripts/worldmap/domestic_tech/domestic_tech_tree_presentation_controller.gd")

var _checks := 0
var _failures: Array[String] = []
var _probe: MapClickProbe = null


## Counts left presses that no GUI control took (what the 3D / 2D map receives). Added last under the root, so its
## _unhandled_input runs before the map's own (Godot walks unhandled input from the last child).
class MapClickProbe extends Node:
	var presses := 0

	func _unhandled_input(event: InputEvent) -> void:
		var button := event as InputEventMouseButton
		if button != null and button.button_index == MOUSE_BUTTON_LEFT and button.pressed:
			presses += 1


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.size = RESOLUTIONS[0]
	root.get_node("/root/GameSession").call("request_new_game", "player")
	change_scene_to_file(WORLDMAP_SCENE_PATH)
	for i in 8:
		await process_frame
	var main := current_scene
	_expect(main != null and main.scene_file_path == WORLDMAP_SCENE_PATH, "WorldMap scene loaded")
	if main == null:
		_finish()
		return
	var host := main.get_node_or_null("WorldMap3DHost")
	var map_3d := host != null and bool(host.get("active"))
	print("[HUD_LAYOUT_3D] map view: %s" % ("3d" if map_3d else "2d"))
	var nav := main.get_node_or_null("TopNavCanvas/TopNav")
	var router = nav.get("menu_router") if nav != null else null
	var ctl := main.get_node_or_null("WorldMapCityInteriorController")
	var markers: Dictionary = main.get("_city_markers_by_id")
	_expect(router != null and ctl != null and markers.has(OWN_CITY), "top menu router, interior controller and 한성 marker exist")
	if router == null or ctl == null or not markers.has(OWN_CITY):
		_finish()
		return
	var left: Control = main.get("left_world_status_panel")
	var right: Control = main.get("city_info_panel_control")
	_probe = MapClickProbe.new()
	root.add_child(_probe)

	for resolution in RESOLUTIONS:
		root.size = resolution
		await _settle(4)
		var tag := "%dx%d" % [resolution.x, resolution.y]
		var marker: Node = markers[OWN_CITY]
		marker.emit_signal("city_selected", marker)
		await _settle(4)
		# 8 (addendum 8): the click only selects; the "성 내부 보기" button in the right city panel opens the picture
		_expect(not bool(ctl.call("is_open")), "%s: 한성 click does not open the picture" % tag)
		var view_button: Button = ctl.call("get_view_button")
		_expect(view_button != null and view_button.is_visible_in_tree() and not view_button.disabled and right.is_ancestor_of(view_button), "%s: '성 내부 보기' shown in the right city panel" % tag)
		if view_button != null:
			var at := view_button.get_global_rect().get_center()
			await _mouse(at, true)
			await _mouse(at, false)
			await _settle(2)
		_expect(bool(ctl.call("is_open")) and str(ctl.call("get_open_city_id")) == OWN_CITY, "%s: '성 내부 보기' opens the picture on 한성" % tag)
		var picture: Control = ctl.call("get_window_panel")
		var want_width := maxf(resolution.x * 0.20, 320.0)
		_expect(picture != null and absf(picture.size.x - want_width) <= 1.0, "%s: picture width %.1f = max(W x 0.20, 320) = %.1f" % [tag, picture.size.x if picture != null else -1.0, want_width])
		_check_screen(tag + " city click", router, ctl, left, right)
		await _check_clicks(tag + " city click", main, router, ctl)
		for menu in MENUS:
			var label := "%s %s" % [tag, menu]
			nav.call("_on_menu_pressed", menu)
			await _settle(4)
			if menu == &"techtree":
				_check_tech_tree(label, main, ctl, router)
				main.call("_close_domestic_tech_tree_overlay_mvp")
				await _settle(2)
				continue
			# 4. one centre window at a time (in the trade menu the order window has replaced the trade tab)
			var windows: Array = router.call("get_center_windows")
			_expect(StringName(router.get("open_menu")) == menu and windows.size() == 1, "%s: one centre window (open %s, %d windows)" % [label, str(router.get("open_menu")), windows.size()])
			_expect(bool(ctl.call("is_open")) and str(ctl.call("get_open_city_id")) == OWN_CITY, "%s: the picture keeps 한성 while the menu is open" % label)
			_check_screen(label, router, ctl, left, right)
			await _check_clicks(label, main, router, ctl)
			if menu == &"trade":
				await _check_trade(label, main, main.get("_manual_trade_order_panel"), router, "_on_manual_trade_order_cancel_pressed")
				_check_screen(label + " back to the trade tab", router, ctl, left, right)
				# the trade tab's own buttons: internal trade, manual mode -> main's internal transfer window instead.
				# 한성 starts with no road-linked own city: a neighbouring trade candidate is lent to the player meanwhile.
				var neighbour: Node = markers.get(str((main.call("_get_external_trade_candidate_city_ids", OWN_CITY) as Array).front()))
				var neighbour_owner := str(neighbour.get("owner_faction_id"))
				neighbour.set("owner_faction_id", str(main.call("_get_current_player_faction_id")))
				main.set("_selected_city_detail_tab", "internal-trade")
				main.call("_on_trade_control_mode_button_pressed", MANUAL_MODE)
				await _settle(4)
				var transfer: Control = main.get("_internal_trade_transfer_panel")
				var order: Control = main.get("_manual_trade_order_panel")
				_expect(transfer != null and transfer.is_visible_in_tree() and not order.is_visible_in_tree(), "%s internal manual: the transfer window opens (not the order window)" % label)
				_check_screen(label + " internal manual", router, ctl, left, right)
				await _check_trade(label + " internal manual", main, transfer, router, "_on_internal_trade_transfer_cancel_pressed")
				neighbour.set("owner_faction_id", neighbour_owner)
			# 4. the same menu again closes it; 6. the picture comes back
			nav.call("_on_menu_pressed", menu)
			await _settle(4)
			_expect(StringName(router.get("open_menu")) == &"" and (router.call("get_center_windows") as Array).is_empty(), "%s again: closed" % label)
			_expect(bool(ctl.call("is_open")) and not bool(ctl.call("is_folded")) and picture.is_visible_in_tree(), "%s closed: the picture is shown again" % label)
			if menu == &"trade":
				_expect(not (main.get("_internal_trade_transfer_panel") as Control).is_visible_in_tree() and not (main.get("_manual_trade_order_panel") as Control).is_visible_in_tree(), "%s closed: both trade sub-windows closed" % label)
		# 2-2: the city action "교역" opens the order window without the top menu -> it becomes the trade menu
		var candidates: Array = main.call("_get_external_trade_candidate_city_ids", OWN_CITY)
		_expect(not candidates.is_empty(), "%s: 한성 has a foreign trade candidate" % tag)
		if not candidates.is_empty():
			var result: Dictionary = main.call("open_contextual_worldmap_action", "trade", str(candidates[0]))
			await _settle(4)
			_expect(bool(result.get("ok", false)) and StringName(router.get("open_menu")) == &"trade", "%s city action trade: the trade menu is open (%s, %s)" % [tag, str(result.get("message", "")), str(router.get("open_menu"))])
			_check_screen(tag + " city action trade", router, ctl, left, right)
			_check_replaced(tag + " city action trade", main.get("_manual_trade_order_panel"), router)
			nav.call("_on_menu_pressed", &"trade")
			await _settle(4)
			_expect((router.call("get_center_windows") as Array).is_empty(), "%s city action trade, trade again: closed" % tag)
			# back to 한성 for the next resolution
			marker.emit_signal("city_selected", marker)
			await _settle(4)
			router.call("close_all")
			await _settle(2)
		_check_draw_order(tag, main, router, ctl, left, right, host if map_3d else null)
		# 8: another city click closes the picture (it is not retargeted)
		var other: Node = markers.get(str(candidates[0])) if not candidates.is_empty() else null
		if other != null:
			ctl.call("try_open", OWN_CITY)
			other.emit_signal("city_selected", other)
			await _settle(3)
			_expect(not bool(ctl.call("is_open")), "%s: another city click closes the picture" % tag)
			router.call("close_all")
		ctl.call("close")
		await _settle(2)
	_finish()


## 1 / 6: the windows on screen overlap nowhere and are inside the screen; the picture folds exactly when it would overlap.
func _check_screen(label: String, router, ctl: Node, left: Control, right: Control) -> void:
	var screen := Rect2(Vector2.ZERO, Vector2(root.size))
	var picture: Control = ctl.call("get_window_panel")
	var menu_windows: Array = router.call("get_center_windows")
	var shown: Array = []
	for item in [["left", left], ["right", right]]:
		shown.append(item)
	for window in menu_windows:
		shown.append([str((window as Control).name), window])
	var overlaps_menu := false
	for window in menu_windows:
		if picture.get_global_rect().intersects((window as Control).get_global_rect()):
			overlaps_menu = true
	if bool(ctl.call("is_folded")):
		_expect(overlaps_menu and not picture.is_visible_in_tree(), "%s: the picture is folded only because a menu window overlaps it" % label)
	else:
		_expect(picture.is_visible_in_tree() and not overlaps_menu, "%s: the picture is shown and overlaps no menu window" % label)
		shown.append(["picture", picture])
	var clashes: Array[String] = []
	for i in shown.size():
		var a: Control = shown[i][1]
		_expect(a.is_visible_in_tree(), "%s: %s visible" % [label, shown[i][0]])
		var rect := a.get_global_rect()
		_expect(screen.encloses(rect), "%s: %s inside the screen (%s)" % [label, shown[i][0], str(rect)])
		for j in range(i + 1, shown.size()):
			var other: Control = shown[j][1]
			var cross := rect.intersection(other.get_global_rect())
			if cross.get_area() > 0.0:
				clashes.append("%s x %s %s" % [shown[i][0], shown[j][0], str(cross)])
	_expect(clashes.is_empty(), "%s: no overlap %s" % [label, str(clashes)])
	for window in menu_windows:
		var scroll := (window as Control).get_node_or_null("HudScroll") as ScrollContainer
		if scroll != null and scroll.get_child_count() > 0:
			var content := scroll.get_child(0) as Control
			_expect(content.size.x + 0.5 >= content.get_combined_minimum_size().x, "%s: %s content not cut (%.0f >= %.0f)" % [label, window.name, content.size.x, content.get_combined_minimum_size().x])


## 2 (addendum 7): the trade sub-window (order or internal transfer) takes the trade tab's place - CityDetailPanel is
## hidden, the sub-window is at the top right of the centre slot; its cancel brings the same city's trade tab back.
func _check_trade(label: String, main: Node, sub: Control, router, cancel_method: String) -> void:
	_check_replaced(label, sub, router)
	main.call(cancel_method)
	await _settle(3)
	var detail: Control = router.call("get_city_detail_panel")
	_expect(not sub.is_visible_in_tree() and detail.is_visible_in_tree() and str(main.get("_unified_primary_tab")) == "trade" and str(main.get("selected_city_id")) == OWN_CITY,
		"%s cancel: the trade tab of 한성 is back (tab %s, city %s)" % [label, str(main.get("_unified_primary_tab")), str(main.get("selected_city_id"))])


func _check_replaced(label: String, sub: Control, router) -> void:
	var detail: Control = router.call("get_city_detail_panel")
	var slot: Rect2 = router.call("get_center_slot")
	_expect(sub != null and sub.is_visible_in_tree() and detail != null and not detail.is_visible_in_tree(), "%s: the sub-window replaces CityDetailPanel (not on top of it)" % label)
	if sub == null or not sub.is_visible_in_tree():
		return
	var rect := sub.get_global_rect()
	_expect(absf(rect.position.y - slot.position.y) <= 1.0 and absf(rect.end.x - slot.end.x) <= 1.0, "%s: sub-window in the menu window's place %s (slot %s)" % [label, str(rect), str(slot)])


## Addendum 7: a map click outside every window still reaches the map (unhandled input), and the turn button is the
## control under its own centre (nothing covers it). The map press is a drag (>= 6 px) so the picture rules stay out.
func _check_clicks(label: String, main: Node, router, ctl: Node) -> void:
	var blockers: Array[Rect2] = []
	for node in [main.get("left_world_status_panel"), main.get("city_info_panel_control"), ctl.call("get_window_panel"), main.find_child("TopMenuBar", true, false), main.find_child("TurnEndCompass", true, false)]:
		if node is Control and (node as Control).is_visible_in_tree():
			blockers.append((node as Control).get_global_rect().grow(8.0))
	for window in router.call("get_center_windows"):
		blockers.append((window as Control).get_global_rect().grow(8.0))
	var point := Vector2(-1, -1)
	var size := Vector2(root.size)
	for y in range(int(size.y) - 20, 60, -20):   # bottom up; at 1280x720 + trade only the strip under the top bar is map
		for x in range(20, int(size.x) - 20, 20):
			var candidate := Vector2(x, y)
			if blockers.all(func(r): return not r.has_point(candidate)) and blockers.all(func(r): return not r.has_point(candidate + Vector2(12, 0))):
				point = candidate
				break
		if point.x >= 0.0:
			break
	_expect(point.x >= 0.0, "%s: an empty map point exists" % label)
	if point.x >= 0.0:
		_probe.presses = 0
		await _mouse(point, true)
		await _mouse(point + Vector2(12, 0), false)
		_expect(_probe.presses == 1, "%s: a map click at %s reaches the map" % [label, str(point)])
	var compass := main.find_child("TurnEndCompass", true, false) as Control
	var hit := compass.get_node_or_null("TurnEndHitArea") as Control if compass != null else null
	_expect(hit != null and hit.is_visible_in_tree(), "%s: the turn button is shown" % label)
	if hit != null:
		var centre := hit.get_global_rect().get_center()
		var motion := InputEventMouseMotion.new()
		motion.position = centre
		motion.global_position = centre
		root.push_input(motion)
		await process_frame
		var hovered := root.gui_get_hovered_control()
		_expect(hovered == hit or (hovered != null and hit.is_ancestor_of(hovered)), "%s: the turn button takes its own click (under the mouse: %s)" % [label, str(hovered.name) if hovered != null else "none"])


func _mouse(at: Vector2, pressed: bool) -> void:
	if not pressed:
		var motion := InputEventMouseMotion.new()
		motion.position = at
		motion.global_position = at
		motion.button_mask = MOUSE_BUTTON_MASK_LEFT
		root.push_input(motion)
		await process_frame
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	event.position = at
	event.global_position = at
	root.push_input(event)
	await process_frame


func _check_tech_tree(label: String, main: Node, ctl: Node, router) -> void:
	_expect(bool(main.call("_is_domestic_tech_tree_overlay_open_mvp")), "%s: the tech tree overlay opens" % label)
	_expect((router.call("get_center_windows") as Array).is_empty(), "%s: no centre menu window under the tech tree" % label)
	var overlay_layer: int = TechTreePresentation.DOMESTIC_TECH_TREE_OVERLAY_LAYER
	_expect(overlay_layer > _layer_of(ctl.call("get_window_panel")) and overlay_layer > _layer_of(router.call("get_popup")), "%s: overlay layer %d above the picture and the popups" % [label, overlay_layer])


## 7: top bar >= popups, menu windows > fixed panels? (same layer, never overlapping) > picture > 3D map.
func _check_draw_order(tag: String, main: Node, router, ctl: Node, left: Control, right: Control, host) -> void:
	var picture_layer := _layer_of(ctl.call("get_window_panel"))
	var bar := main.find_child("TopMenuBar", true, false) as Control
	var popup: Control = router.call("get_popup")
	var detail: Control = router.call("get_city_detail_panel")
	var order: Control = main.get("_manual_trade_order_panel")
	var panels_layer := mini(_layer_of(left), _layer_of(right))
	_expect(picture_layer < panels_layer, "%s: picture layer %d under the left / right panels (%d)" % [tag, picture_layer, panels_layer])
	for item in [["CityDetailPanel", detail], ["popup", popup], ["order window", order]]:
		if item[1] != null:
			_expect(_layer_of(item[1]) > picture_layer and _layer_of(item[1]) >= panels_layer, "%s: %s layer %d above the picture (%d)" % [tag, item[0], _layer_of(item[1]), picture_layer])
	_expect(bar != null and _layer_of(bar) >= _layer_of(popup) and _layer_of(bar) > _layer_of(detail), "%s: top bar layer %d on top" % [tag, _layer_of(bar) if bar != null else -1])
	if host != null:
		var layer_3d := main.find_child("WorldMap3DLayer", true, false) as CanvasLayer
		_expect(layer_3d != null and layer_3d.layer < picture_layer, "%s: 3D map layer %d under the picture (%d)" % [tag, layer_3d.layer if layer_3d != null else 999, picture_layer])


## The CanvasLayer index a control is drawn on (0 = the viewport's own canvas).
func _layer_of(node: Node) -> int:
	var current := node
	while current != null:
		if current is CanvasLayer:
			return (current as CanvasLayer).layer
		current = current.get_parent()
	return 0


func _settle(frames: int) -> void:
	for i in frames:
		await process_frame


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(label)
		push_error("[HUD_LAYOUT_3D_FAIL] %s" % label)


func _finish() -> void:
	print("[HUD_LAYOUT_3D] checks=%d failures=%s" % [_checks, str(_failures)])
	quit(0 if _failures.is_empty() else 1)
