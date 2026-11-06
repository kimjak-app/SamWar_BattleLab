extends SceneTree

# CITY-HUD CH-4: the castle picture follows the open city's completed city techs
# (scripts/worldmap/ui/worldmap_city_interior_controller.gd) on the real WorldMap.tscn in the 2D map view.
# Completed techs are made through main's own research service (complete_city_research, the turn-end completion path);
# the test keeps the original completed map and city states and puts them back at the end.
# 1. nothing completed: background + life buildings + houses only
# 2. one building completed: only that building is added
# 3. market slot: none / street / +permanent / +grand -> 0 / 1 / 1 / 1 market picture, same foot point
# 4. kyoto port slot: port -> port picture, +trade port -> trade port only; compare_only port never; shipyard on its own
# 5. inland hanseong: coastal techs completed, no coastal building drawn
# 6. per city: hanseong's techs do not show in pyeongyang
# 7. while open: completing a tech redraws once; an unchanged snapshot never redraws (draw counter); cost per frame
# 8. debug_show_all (and Ctrl+Shift+K): CH-3 counts; back to the rules when off
# 9. items left out are not in get_drawn_items()

const WORLDMAP_SCENE_PATH := "res://WorldMap.tscn"
const CONTROLLER_NODE := "WorldMapCityInteriorController"
const LAYOUTS := preload("res://scripts/worldmap/ui/worldmap_city_interior_layouts.gd")
const CASTLES := ["hanseong", "pyeongyang", "jianye", "edo", "kyoto"]
const CH3_DRAWN := {"hanseong": 30, "pyeongyang": 28, "jianye": 29, "edo": 29, "kyoto": 30}
const HANSEONG_BASE := 16   # 11 houses + 5 life buildings (layout counts)
const MARKET_KEYS := ["commerce_grand_market", "commerce_permanent_market", "commerce_street_market"]
const PORT_KEYS := ["commerce_trade_port", "commerce_port"]
const COASTAL_TECHS := ["fish_village", "fish_salt_field", "fish_salt_warehouse", "fish_dried_supply_base", "commerce_port", "commerce_shipyard", "commerce_trade_port"]
const COMPLETED_KEY := "city_domestic_tech_completed"
const COST_SAMPLES := 1000

var _checks := 0
var _failures: Array[String] = []
var _worldmap: Node = null
var _ctl: Node = null
var _service: Object = null
var _markers: Dictionary = {}
var _player_faction := ""


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_expect(change_scene_to_file(WORLDMAP_SCENE_PATH) == OK, "WorldMap scene transition starts")
	for i in 4:
		await process_frame
	_worldmap = current_scene
	_expect(_worldmap != null and _worldmap.scene_file_path == WORLDMAP_SCENE_PATH, "WorldMap scene loaded")
	if _worldmap == null:
		_finish()
		return
	var host := _worldmap.get_node_or_null("WorldMap3DHost")
	if host != null and bool(host.get("active")):
		host.call("set_map_view_3d", false)
		await process_frame
	_ctl = _worldmap.get_node_or_null(CONTROLLER_NODE)
	_expect(_ctl != null and _ctl.has_method("get_draw_count") and "debug_show_all" in _ctl, "controller has the CH-4 API")
	if _ctl == null or not _ctl.has_method("get_draw_count"):
		_finish()
		return
	_service = _worldmap.call("_ensure_domestic_tech_research_service")
	_markers = _worldmap.get("_city_markers_by_id")
	_player_faction = str(_worldmap.call("_get_current_player_faction_id"))

	# the state at game start (CH-4 1절 [미확인] 2), recorded before anything is changed
	var player_state: Dictionary = _worldmap.get("_player_state")
	var original_completed: Variant = player_state.get(COMPLETED_KEY, {})
	original_completed = (original_completed as Dictionary).duplicate(true) if original_completed is Dictionary else original_completed
	var original_city_states := {}
	var original_owners := {}
	var runtime_states: Dictionary = _worldmap.get("_city_runtime_states")
	for city_id in CASTLES:
		var snapshot: Dictionary = _worldmap.call("_get_completed_city_domestic_tech_snapshot_mvp", city_id)
		print("[CITY_INTERIOR_TECH_LINK] start completed %s = %s" % [city_id, str(snapshot)])
		original_city_states[city_id] = (runtime_states.get(city_id, {}) as Dictionary).duplicate(true)
		original_owners[city_id] = str(_markers[city_id].get("owner_faction_id"))
		_markers[city_id].set("owner_faction_id", _player_faction)

	await _check_hanseong_rules()
	await _check_kyoto_port_slot()
	await _check_per_city()
	await _check_live_redraw()
	await _check_debug_show_all()

	_ctl.call("close")
	player_state[COMPLETED_KEY] = original_completed
	for city_id in CASTLES:
		runtime_states[city_id] = original_city_states[city_id]
		_markers[city_id].set("owner_faction_id", original_owners[city_id])
	_finish()


# 1, 2, 3, 5, 9
func _check_hanseong_rules() -> void:
	_set_completed({})
	await _open("hanseong")
	var drawn: Array = _ctl.call("get_drawn_items")
	var base := drawn.duplicate()
	_expect(drawn.size() == HANSEONG_BASE and drawn.all(func(i): return str(i.kind) == "decoration" or str(i.tech_id).is_empty()),
		"1. hanseong, nothing completed: %d items = houses + life buildings (got %d %s)" % [HANSEONG_BASE, drawn.size(), str(_keys())])
	_expect(drawn.filter(func(i): return str(i.kind) == "building").size() == 5 and (_ctl.call("get_canvas") as Control).get_child(0).name == "Background",
		"1. hanseong: 5 life buildings + background")
	_check_drawn_matches_rules("hanseong", {})

	_set_completed({"hanseong": ["mil_barracks"]})
	await _redraw("hanseong")
	drawn = _ctl.call("get_drawn_items")
	var added := drawn.filter(func(i): return not base.has(i))
	_expect(drawn.size() == HANSEONG_BASE + 1 and added.size() == 1 and str(added[0].building_key) == "mil_barracks" and base.all(func(i): return drawn.has(i)),
		"2. +mil_barracks adds only the barracks (%s)" % str(_keys()))

	var market_item: Dictionary = LAYOUTS.get_layout("hanseong").items.filter(func(i): return i.get("slot_candidates", []) == MARKET_KEYS)[0]
	var stages := [[[], ""], [["commerce_street_market"], "commerce_street_market"],
		[["commerce_street_market", "commerce_permanent_market"], "commerce_permanent_market"],
		[["commerce_street_market", "commerce_permanent_market", "commerce_grand_market"], "commerce_grand_market"]]
	for stage in stages:
		_set_completed({"hanseong": stage[0]})
		await _redraw("hanseong")
		var markets := _nodes().filter(func(n): return MARKET_KEYS.has(str(n.get_meta("drawn_key"))))
		if str(stage[1]).is_empty():
			_expect(markets.is_empty() and not (_ctl.call("get_drawn_items") as Array).has(market_item), "3. market: nothing completed -> slot empty")
			continue
		_expect(markets.size() == 1 and str(markets[0].get_meta("drawn_key")) == stage[1] and markets[0].get_meta("layout_item") == market_item,
			"3. market %s -> one picture %s (got %s)" % [str(stage[0]), stage[1], str(markets.map(func(n): return n.get_meta("drawn_key")))])
		if markets.size() == 1:
			var node: TextureRect = markets[0]
			var foot := node.position + Vector2(node.size.x * 0.5, node.size.y)
			var want_size: Vector2 = node.texture.get_size() * float(market_item.scale)
			_expect(foot.is_equal_approx(Vector2(float(market_item.ax), float(market_item.ay))) and node.size.is_equal_approx(want_size)
				and node.texture.resource_path.contains(str(stage[1])),
				"3. %s on the slot foot %s at its own size %s (got foot %s size %s)" % [stage[1], str(Vector2(market_item.ax, market_item.ay)), str(want_size), str(foot), str(node.size)])
		_check_drawn_matches_rules("hanseong", {"hanseong": stage[0]})

	_set_completed({"hanseong": COASTAL_TECHS})
	await _redraw("hanseong")
	drawn = _ctl.call("get_drawn_items")
	_expect(not bool(_worldmap.call("_is_city_coastal_for_city_tech", "hanseong")) and drawn.size() == HANSEONG_BASE
		and not drawn.any(func(i): return bool(i.get("coastal_only", false))) and not _keys().any(func(k): return COASTAL_TECHS.has(k)),
		"5. inland hanseong with coastal techs completed draws no coastal building (%s)" % str(_keys()))


# 4
func _check_kyoto_port_slot() -> void:
	var items: Array = LAYOUTS.get_layout("kyoto").items
	var port_slot: Dictionary = items.filter(func(i): return i.get("slot_candidates", []) == PORT_KEYS)[0]
	var compare_port: Dictionary = items.filter(func(i): return bool(i.get("compare_only", false)))[0]
	var cases := [
		[[], "", false],
		[["commerce_port"], "commerce_port", false],
		[["commerce_port", "commerce_shipyard"], "commerce_port", true],
		[["commerce_port", "commerce_shipyard", "commerce_trade_port"], "commerce_trade_port", true],
		[["commerce_trade_port"], "commerce_trade_port", false],
	]
	await _open("kyoto")
	for case in cases:
		_set_completed({"kyoto": case[0]})
		await _redraw("kyoto")
		var drawn: Array = _ctl.call("get_drawn_items")
		var ports := _nodes().filter(func(n): return PORT_KEYS.has(str(n.get_meta("drawn_key"))))
		var shipyard := _keys().count("commerce_shipyard")
		var port_ok: bool = ports.is_empty() if str(case[1]).is_empty() else (ports.size() == 1 and str(ports[0].get_meta("drawn_key")) == case[1] and ports[0].get_meta("layout_item") == port_slot)
		_expect(port_ok and not drawn.has(compare_port) and shipyard == (1 if case[2] else 0),
			"4. kyoto %s -> port slot %s, shipyard %d, compare_only port never (got %s)" % [str(case[0]), case[1] if not str(case[1]).is_empty() else "empty", shipyard, str(_keys())])
		if ports.size() == 1:
			var node: TextureRect = ports[0]
			var foot := node.position + Vector2(node.size.x * 0.5, node.size.y)
			_expect(foot.is_equal_approx(Vector2(float(port_slot.ax), float(port_slot.ay))) and node.size.is_equal_approx(node.texture.get_size() * float(port_slot.scale)),
				"4. %s on the trade port foot at its own size (foot %s size %s)" % [case[1], str(foot), str(node.size)])
		_check_drawn_matches_rules("kyoto", {"kyoto": case[0]})


# 6
func _check_per_city() -> void:
	_set_completed({"hanseong": ["mil_barracks", "commerce_street_market", "agri_irrigation"]})
	await _open("hanseong")
	var hanseong_keys := _keys()
	await _open("pyeongyang")
	var drawn: Array = _ctl.call("get_drawn_items")
	_expect(hanseong_keys.has("mil_barracks") and str(_ctl.call("get_open_city_id")) == "pyeongyang"
		and drawn.all(func(i): return str(i.kind) == "decoration" or str(i.tech_id).is_empty()),
		"6. hanseong's techs do not show in pyeongyang (pyeongyang %s)" % str(_keys()))
	_check_drawn_matches_rules("pyeongyang", {})


# 7
func _check_live_redraw() -> void:
	_set_completed({})
	await _open("hanseong")
	var count_open := int(_ctl.call("get_draw_count"))
	for i in 5:
		await process_frame
	_expect(int(_ctl.call("get_draw_count")) == count_open, "7. unchanged snapshot: no redraw over 5 frames (%d -> %d)" % [count_open, int(_ctl.call("get_draw_count"))])
	_service.call("complete_city_research", "hanseong", {"tech_id": "mil_barracks"})
	for i in 3:
		await process_frame
	_expect(_keys().has("mil_barracks") and int(_ctl.call("get_draw_count")) == count_open + 1,
		"7. completing mil_barracks while open redraws once and shows it (draws %d -> %d)" % [count_open, int(_ctl.call("get_draw_count"))])
	for i in 5:
		await process_frame
	_expect(int(_ctl.call("get_draw_count")) == count_open + 1, "7. no further redraw while the snapshot stays the same")
	var started := Time.get_ticks_usec()
	var same := 0
	for i in COST_SAMPLES:
		if _ctl.call("_completed_snapshot", "hanseong") == _ctl.get("_drawn_completed"):
			same += 1
	var per_frame_us := float(Time.get_ticks_usec() - started) / COST_SAMPLES
	print("[CITY_INTERIOR_TECH_LINK] per-frame check (snapshot copy + Dictionary compare, open city only) = %.1f us avg over %d" % [per_frame_us, COST_SAMPLES])
	_expect(same == COST_SAMPLES, "7. the per-frame check sees the same snapshot")
	# reopen keeps it
	_ctl.call("close")
	await _open("hanseong")
	_expect(_keys().has("mil_barracks"), "7. closed and reopened: the completed building stays")


# 8
func _check_debug_show_all() -> void:
	_set_completed({})
	for city_id in CASTLES:
		_ctl.set("debug_show_all", true)
		await _open(city_id)
		var coastal := bool(_worldmap.call("_is_city_coastal_for_city_tech", city_id))
		var drawn: Array = _ctl.call("get_drawn_items")
		_expect(drawn.size() == CH3_DRAWN[city_id] and drawn == LAYOUTS.items_for_city(city_id, coastal),
			"8. debug_show_all: %s draws the CH-3 layout (%d, got %d)" % [city_id, CH3_DRAWN[city_id], drawn.size()])
		_ctl.set("debug_show_all", false)
		await process_frame
		drawn = _ctl.call("get_drawn_items")
		_expect(drawn.all(func(i): return str(i.kind) == "decoration" or str(i.tech_id).is_empty()) and drawn.size() < CH3_DRAWN[city_id],
			"8. debug_show_all off: %s back to the rules (%d items)" % [city_id, drawn.size()])
	await _open("hanseong")
	root.push_input(_key(KEY_K, true, true))
	await process_frame
	_expect(bool(_ctl.get("debug_show_all")) == OS.is_debug_build() and (_ctl.call("get_drawn_items") as Array).size() == (CH3_DRAWN.hanseong if OS.is_debug_build() else HANSEONG_BASE),
		"8. Ctrl+Shift+K toggles debug_show_all on in a debug build (%s)" % str(_ctl.get("debug_show_all")))
	root.push_input(_key(KEY_K, false, false))   # plain K: nothing
	await process_frame
	_expect(bool(_ctl.get("debug_show_all")) == OS.is_debug_build(), "8. K without Ctrl+Shift does nothing")
	root.push_input(_key(KEY_K, true, true))
	await process_frame
	_expect(not bool(_ctl.get("debug_show_all")) and (_ctl.call("get_drawn_items") as Array).size() == HANSEONG_BASE, "8. Ctrl+Shift+K again turns it off")


## 9: every drawn item is one the rule draws, every item the rule draws is drawn (missing art aside: none in the pack).
func _check_drawn_matches_rules(city_id: String, completed_by_city: Dictionary) -> void:
	var completed := {}
	for tech_id in completed_by_city.get(city_id, []):
		completed[tech_id] = true
	var coastal := bool(_worldmap.call("_is_city_coastal_for_city_tech", city_id))
	var want := LAYOUTS.items_for_city(city_id, coastal).filter(func(i): return not str(_ctl.call("building_key_to_draw", i, completed, false)).is_empty())
	_expect(want == _ctl.call("get_drawn_items") and _nodes().size() == want.size(), "9. %s %s: drawn items == the rule's items (%d)" % [city_id, str(completed.keys()), want.size()])


## Replaces every city's completed techs: {} for all, then the given ones through complete_city_research.
func _set_completed(completed_by_city: Dictionary) -> void:
	(_worldmap.get("_player_state") as Dictionary)[COMPLETED_KEY] = {}
	for city_id in completed_by_city:
		for tech_id in completed_by_city[city_id]:
			_service.call("complete_city_research", city_id, {"tech_id": tech_id})


func _open(city_id: String) -> void:
	var opened := bool(_ctl.call("try_open", city_id)) or str(_ctl.call("get_open_city_id")) == city_id
	_expect(opened, "%s opens (reason %s)" % [city_id, str(_ctl.get("last_reject_reason"))])
	await process_frame


func _redraw(city_id: String) -> void:
	await process_frame   # the controller's own _process sees the new snapshot
	_expect(str(_ctl.call("get_open_city_id")) == city_id, "%s still open" % city_id)


func _nodes() -> Array:
	var canvas: Control = _ctl.call("get_canvas")
	return canvas.get_children().filter(func(n): return n.has_meta("drawn_key"))


func _keys() -> Array:
	return _nodes().map(func(n): return str(n.get_meta("drawn_key")))


func _key(keycode: Key, ctrl: bool, shift: bool) -> InputEventKey:
	var event := InputEventKey.new()
	event.pressed = true
	event.keycode = keycode
	event.ctrl_pressed = ctrl
	event.shift_pressed = shift
	return event


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(label)
		push_error("[CITY_INTERIOR_TECH_LINK_FAIL] %s" % label)


func _finish() -> void:
	print("[CITY_INTERIOR_TECH_LINK] checks=%d failures=%s" % [_checks, str(_failures)])
	quit(0 if _failures.is_empty() else 1)
