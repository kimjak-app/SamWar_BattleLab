extends SceneTree

# CITY-HUD CH-3: the five castle layouts (assets/worldmap/city_buildings/city_layouts.json) drawn in the city interior
# window (scripts/worldmap/ui/worldmap_city_interior_controller.gd + worldmap_city_interior_layouts.gd) on the real
# WorldMap.tscn in the 2D map view.
# 1-3. layout data: 5 castles, counts, keys and paths, ay order, rect rules
# 4-5. drawn nodes per castle and their canvas rect at k = 1 and at other window sizes (1 px)
# 6. no-layout cities: gyeongju opens with the CH-2 placeholder, karakorum stays no_art
# 7. coastal_only only for a coastal city (main's coastal check, read only); compare_only never drawn
# 8. close button / Esc close the window and drop the drawn nodes

const WORLDMAP_SCENE_PATH := "res://WorldMap.tscn"
const CONTROLLER_NODE := "WorldMapCityInteriorController"
const LAYOUTS := preload("res://scripts/worldmap/ui/worldmap_city_interior_layouts.gd")
const ASSETS := preload("res://scripts/worldmap/ui/worldmap_city_building_assets.gd")
const EXPECTED_COUNTS := {"hanseong": [19, 11], "pyeongyang": [19, 9], "jianye": [20, 9], "edo": [21, 8], "kyoto": [26, 5]}
const EXPECTED_DRAWN := {"hanseong": 30, "pyeongyang": 28, "jianye": 29, "edo": 29, "kyoto": 30}
const KYOTO_COASTAL_KINDS := 7   # coastal_only items in the layout, the port among them
const KYOTO_COASTAL_DRAWN := 6   # the port item is also compare_only (D4): the port stays a slot candidate of the trade port
const NO_LAYOUT_CITY := "gyeongju"
const NO_ART_CITY := "karakorum"
const SCALE := 1.25

var _checks := 0
var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_check_layout_data()
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
		host.call("set_map_view_3d", false)
		await process_frame
	var ctl := worldmap.get_node_or_null(CONTROLLER_NODE)
	_expect(ctl != null, "controller node exists")
	if ctl == null:
		_finish()
		return
	_expect(ctl.has_method("get_canvas") and ctl.has_method("apply_canvas_transform"), "controller draws castle layouts (CH-3 API)")
	if not ctl.has_method("get_canvas"):
		_finish()
		return
	var markers: Dictionary = worldmap.get("_city_markers_by_id")
	var player_faction := str(worldmap.call("_get_current_player_faction_id"))

	# 4-5, 7. each castle drawn from its layout
	for city_id in EXPECTED_DRAWN:
		_expect(markers.has(city_id), "marker exists: %s" % city_id)
		if not markers.has(city_id):
			continue
		var owner_before := str(markers[city_id].get("owner_faction_id"))
		markers[city_id].set("owner_faction_id", player_faction)
		var opened := bool(ctl.call("try_open", city_id))
		_expect(opened, "%s opens (reason %s)" % [city_id, str(ctl.get("last_reject_reason"))])
		if opened:
			await process_frame
			_check_drawn_city(ctl, worldmap, city_id)
		ctl.call("close")
		markers[city_id].set("owner_faction_id", owner_before)

	# retarget: an open castle switched to another one is redrawn for the new one only
	var owners_before := {}
	for city_id in ["hanseong", "edo"]:
		owners_before[city_id] = str(markers[city_id].get("owner_faction_id"))
		markers[city_id].set("owner_faction_id", player_faction)
	ctl.call("try_open", "hanseong")
	ctl.call("try_open", "edo")
	var drawn: Array = ctl.call("get_drawn_items")
	var canvas: Control = ctl.call("get_canvas")
	_expect(str(ctl.call("get_open_city_id")) == "edo" and drawn.size() == EXPECTED_DRAWN.edo and canvas.get_child_count() == EXPECTED_DRAWN.edo + 1,
		"retarget hanseong -> edo redraws edo only (%d items, %d nodes)" % [drawn.size(), canvas.get_child_count()])

	# 8. close button and Esc drop the drawn nodes
	(ctl.call("get_close_button") as Button).emit_signal("pressed")
	_expect(not bool(ctl.call("is_open")) and canvas.get_child_count() == 0 and (ctl.call("get_drawn_items") as Array).is_empty(), "close button closes and frees the drawn nodes")
	ctl.call("try_open", "edo")
	await process_frame
	root.push_input(_esc())
	await process_frame
	_expect(not bool(ctl.call("is_open")) and canvas.get_child_count() == 0, "Esc closes and frees the drawn nodes")
	for city_id in owners_before:
		markers[city_id].set("owner_faction_id", owners_before[city_id])

	# 6. cities without a layout
	_expect(not LAYOUTS.has_layout(NO_LAYOUT_CITY) and LAYOUTS.get_layout(NO_LAYOUT_CITY).is_empty(), "%s has no layout" % NO_LAYOUT_CITY)
	var no_layout_owner := str(markers[NO_LAYOUT_CITY].get("owner_faction_id"))
	markers[NO_LAYOUT_CITY].set("owner_faction_id", player_faction)
	_expect(bool(ctl.call("try_open", NO_LAYOUT_CITY)), "%s opens" % NO_LAYOUT_CITY)
	var placeholder: Label = ctl.call("get_placeholder")
	_expect(placeholder.visible and not canvas.visible and canvas.get_child_count() == 0, "%s shows the CH-2 placeholder, no canvas" % NO_LAYOUT_CITY)
	ctl.call("close")
	markers[NO_LAYOUT_CITY].set("owner_faction_id", no_layout_owner)
	var karakorum_owner := str(markers[NO_ART_CITY].get("owner_faction_id"))
	markers[NO_ART_CITY].set("owner_faction_id", player_faction)
	_expect(not bool(ctl.call("try_open", NO_ART_CITY)) and str(ctl.get("last_reject_reason")) == "no_art", "%s stays closed (no_art)" % NO_ART_CITY)
	markers[NO_ART_CITY].set("owner_faction_id", karakorum_owner)
	_finish()


func _check_layout_data() -> void:
	var file_text := FileAccess.get_file_as_string(LAYOUTS.LAYOUTS_PATH)
	var parsed: Variant = JSON.parse_string(file_text)
	_expect(parsed is Dictionary and (parsed as Dictionary).get("layouts") is Dictionary, "city_layouts.json parses")
	if not (parsed is Dictionary):
		return
	var layouts: Dictionary = parsed["layouts"]
	_expect(layouts.size() == 5 and EXPECTED_COUNTS.keys().all(func(c): return layouts.has(c)), "exactly the 5 castles %s" % str(layouts.keys()))
	var keys := ASSETS.all_building_keys()
	for city_id in EXPECTED_COUNTS:
		var layout: Dictionary = LAYOUTS.get_layout(city_id)
		var items: Array = layout.get("items", [])
		var buildings := items.filter(func(i): return str(i.get("kind")) == "building").size()
		var decorations := items.filter(func(i): return str(i.get("kind")) == "decoration").size()
		_expect([buildings, decorations] == EXPECTED_COUNTS[city_id] and buildings + decorations == items.size(),
			"%s counts %d+%d" % [city_id, buildings, decorations])
		_expect(ResourceLoader.exists(str(layout.get("background", ""))), "%s background exists" % city_id)
		var style := str(layout.get("region_style", ""))
		var bad: Array[String] = []
		var previous_ay := -INF
		for item in items:
			var key := str(item.get("building_key", ""))
			if str(item.get("kind")) == "building":
				if not keys.has(key):
					bad.append("key %s" % key)
				elif not ResourceLoader.exists(ASSETS.texture_path(key, style)):
					bad.append("art %s_%s" % [key, style])
			elif not ResourceLoader.exists(str(item.get("texture", ""))):
				bad.append("deco %s" % str(item.get("texture", "")))
			var ax := float(item.ax)
			var ay := float(item.ay)
			if ay < previous_ay:
				bad.append("ay order z%d" % int(item.z))
			previous_ay = ay
			if ax != float(item.x) + float(item.w) * 0.5 or ay != float(item.y) + float(item.h):
				bad.append("anchor z%d" % int(item.z))
			if int(item.w) != roundi(float(item.src_w) * SCALE) or int(item.h) != roundi(float(item.src_h) * SCALE):
				bad.append("size z%d" % int(item.z))
		_expect(bad.is_empty(), "%s keys, paths, ay order and rect rules %s" % [city_id, str(bad)])
	# items_for_city filters
	var kyoto_all: Array = LAYOUTS.get_layout("kyoto").get("items", [])
	var compare_only := kyoto_all.filter(func(i): return bool(i.get("compare_only", false))).size()
	var coastal_only := kyoto_all.filter(func(i): return bool(i.get("coastal_only", false))).size()
	_expect(compare_only == 1 and coastal_only == KYOTO_COASTAL_KINDS, "kyoto has 1 compare_only and %d coastal_only items" % KYOTO_COASTAL_KINDS)
	var inland_kept := kyoto_all.filter(func(i): return not bool(i.get("compare_only", false)) and not bool(i.get("coastal_only", false))).size()
	_expect(LAYOUTS.items_for_city("kyoto", true).size() == kyoto_all.size() - 1 and LAYOUTS.items_for_city("kyoto", false).size() == inland_kept,
		"items_for_city drops compare_only always and coastal_only inland")
	var t: Dictionary = LAYOUTS.canvas_transform(Vector2(960, 576))
	_expect(is_equal_approx(float(t.k), 0.75) and (t.off as Vector2).is_equal_approx(Vector2.ZERO), "canvas_transform 960x576 -> k 0.75")


func _check_drawn_city(ctl: Node, worldmap: Node, city_id: String) -> void:
	var coastal := bool(worldmap.call("_is_city_coastal_for_city_tech", city_id))
	_expect(coastal == (city_id == "kyoto"), "%s coastal (main) = %s" % [city_id, str(coastal)])
	var canvas: Control = ctl.call("get_canvas")
	var drawn: Array = ctl.call("get_drawn_items")
	_expect(canvas.visible and not (ctl.call("get_placeholder") as Label).visible, "%s draws the canvas" % city_id)
	_expect(drawn.size() == EXPECTED_DRAWN[city_id] and canvas.get_child_count() == drawn.size() + 1, "%s draws %d items (+ background), got %d / %d nodes" % [city_id, EXPECTED_DRAWN[city_id], drawn.size(), canvas.get_child_count()])
	_expect(LAYOUTS.items_for_city(city_id, coastal) == drawn, "%s drawn in layout order" % city_id)
	_expect(not drawn.any(func(i): return bool(i.get("compare_only", false))), "%s draws no compare_only item" % city_id)
	var coastal_drawn := drawn.filter(func(i): return bool(i.get("coastal_only", false))).size()
	_expect(coastal_drawn == (KYOTO_COASTAL_DRAWN if city_id == "kyoto" else 0), "%s draws %d coastal_only items" % [city_id, coastal_drawn])
	if city_id == "kyoto":
		# the 7 coastal kinds: 6 drawn items + the port as a slot candidate of the drawn trade port
		var coastal_keys := {}
		for item in drawn:
			if bool(item.get("coastal_only", false)):
				coastal_keys[str(item.building_key)] = true
				for candidate in item.get("slot_candidates", []):
					coastal_keys[str(candidate)] = true
		_expect(coastal_keys.size() == KYOTO_COASTAL_KINDS and coastal_keys.has("commerce_port"), "kyoto: the %d coastal kinds are drawn or slotted %s" % [KYOTO_COASTAL_KINDS, str(coastal_keys.keys())])
		_expect(drawn.filter(func(i): return str(i.get("kind")) == "building").size() == 25 and drawn.filter(func(i): return str(i.get("kind")) == "decoration").size() == 5, "kyoto: 25 buildings + 5 houses")
	var background := canvas.get_child(0) as TextureRect
	_expect(background != null and background.texture != null and background.size.is_equal_approx(Vector2(1280, 768)), "%s background 1280x768 at the bottom" % city_id)
	for area in [Vector2(1280, 768), Vector2(960, 576), Vector2(1000, 768)]:
		ctl.call("apply_canvas_transform", area)
		var t: Dictionary = LAYOUTS.canvas_transform(area)
		var k := float(t.k)
		var off: Vector2 = t.off
		var bad: Array[String] = []
		for index in drawn.size():
			var node := canvas.get_child(index + 1) as TextureRect
			var item: Dictionary = drawn[index]
			if node == null or node.get_meta("layout_item", {}) != item or node.texture == null or node.mouse_filter != Control.MOUSE_FILTER_IGNORE:
				bad.append("node %d" % index)
				continue
			var want_top_left := off + Vector2(float(item.ax) - float(item.w) * 0.5, float(item.ay) - float(item.h)) * k
			var want_size := Vector2(float(item.w), float(item.h)) * k
			var got_top_left := canvas.position + node.position * canvas.scale
			var got_size := node.size * canvas.scale
			if got_top_left.distance_to(want_top_left) > 1.0 or (got_size - want_size).abs().x > 1.0 or (got_size - want_size).abs().y > 1.0:
				bad.append("z%d %s vs %s" % [int(item.z), str(got_top_left), str(want_top_left)])
		_expect(bad.is_empty(), "%s rects within 1 px at area %s (k %.4f) %s" % [city_id, str(area), k, str(bad.slice(0, 3))])


func _esc() -> InputEventKey:
	var event := InputEventKey.new()
	event.pressed = true
	event.keycode = KEY_ESCAPE
	return event


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(label)
		push_error("[CITY_INTERIOR_LAYOUT_FAIL] %s" % label)


func _finish() -> void:
	print("[CITY_INTERIOR_LAYOUT] checks=%d failures=%s" % [_checks, str(_failures)])
	quit(0 if _failures.is_empty() else 1)
