extends SceneTree

# Queue 41: the hidden 2D-era windows are reachable from the 3D world map's top menu and city clicks. Real WorldMap.tscn,
# new game (player / hanseong). Visibility is checked with is_visible_in_tree() (a hidden parent must fail it).
#  1. top menu diplomacy / trade / intel / system: press -> its window shows, again -> hidden, another -> switches; an
#     open window stops the mouse (the 3D map only takes unhandled input)
#  2. diplomacy: envoy submitted from the window -> the cost leaves the city stock + one pending line -> turn end ->
#     the result line
#  3. intel: public support disrupt -> gold 300 out, the national stock shown at once; gather info -> the report card
#     (P3 stock, heroes for a political chancellor) is visible
#  4. trade: order -> submitted -> turn end -> settled, both city stocks move as in the P2 test
#  5. system: save -> change -> load -> 65 cities owner / troops / stock and the pending requests as saved (+3D if on)
#  6. city window: hanseong's 9 stock numbers = resource_stock; a cost paid -> the shown numbers are the new ones
#  7. military: recruit in hanseong -> troops up, cost paid, numbers shown at once
#  8. city action menu: next to the city (3D screen position when 3D is on, else the 2D marker); in 3D, a city behind
#     the camera closes it
#  9. unclaimed city click -> no actions, menu closed, "주인 없음(빈 성)" in the city window
# (10. P0 / P3 / P1 / CITIES65 / P2 / HUD / 3D host / production tests stay on C-track and WorldMap3D)

const WORLDMAP_SCENE_PATH := "res://WorldMap.tscn"
const CityActionController := preload("res://scripts/worldmap/ui/worldmap_city_action_controller.gd")
const Strategy := preload("res://scripts/worldmap/actions/strategy_request_service.gd")
const OWN_CITY := "hanseong"
const ENEMY_CITY := "pyeongyang"
const EMPTY_CITY := "sangju"  # queue 46: 개성 is the player's under 배치 A; 상주 stays unclaimed
const RESOURCES := ["gold", "rice", "barley", "seafood", "wood", "iron", "horses", "silk", "salt"]
const DISTINCT := {"gold": 4321, "rice": 1101, "barley": 1203, "seafood": 1307, "wood": 1409, "iron": 1511, "horses": 1613, "silk": 1717, "salt": 1819}

var _checks := 0
var _failures: Array[String] = []
var _main: Node
var _nav: Node
var _router: Node
var _detail: Control


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.size = Vector2i(1920, 1080)
	_expect(bool(root.get_node("/root/GameSession").call("request_new_game", "player")), "new game requested")
	_expect(change_scene_to_file(WORLDMAP_SCENE_PATH) == OK, "WorldMap scene transition starts")
	for i in 8:
		await process_frame
	_main = current_scene
	_expect(_main != null and _main.scene_file_path == WORLDMAP_SCENE_PATH, "WorldMap scene loaded")
	if _main == null:
		_finish()
		return
	_nav = _main.get_node_or_null("TopNavCanvas/TopNav")
	_router = _nav.get("menu_router") if _nav != null else null
	_detail = _main.get_node_or_null("WorldMapUI/CityDetailPanel") as Control
	_expect(_router != null and _detail != null, "top menu router and CityDetailPanel exist")
	if _router == null or _detail == null:
		_finish()
		return
	print("[HUD_CONNECT_3D] 3D view active: %s" % str(_is_3d()))
	await _check_menus()
	await _check_city_window_and_recruit()
	await _check_diplomacy()
	await _check_intel()
	await _check_trade()
	await _check_save_load()
	await _check_action_menu()
	await _check_unclaimed()
	_finish()


# ---------------------------------------------------------------- 1
func _check_menus() -> void:
	var popup: Control = _router.call("get_popup")
	await _press(&"diplomacy")
	_expect(_detail.is_visible_in_tree() and str(_main.get("_unified_primary_tab")) == "diplomacy-spy" and str(_main.get("_selected_diplomacy_spy_tab")) == "diplomacy", "1. diplomacy -> CityDetailPanel on the diplomacy tab")
	_expect(_detail.mouse_filter == Control.MOUSE_FILTER_STOP, "1. the open window stops the mouse (no click through to the 3D map)")
	await _press(&"diplomacy")
	_expect(not _detail.is_visible_in_tree(), "1. diplomacy again -> closed")
	await _press(&"intel")
	_expect(_detail.is_visible_in_tree() and str(_main.get("_selected_diplomacy_spy_tab")) == "spy", "1. intel -> spy tab")
	await _press(&"trade")
	# Queue 43 (addendum 7): for an own city the order window takes the trade tab's place, so either one is on screen.
	var order_window: Control = _main.get("_manual_trade_order_panel")
	_expect((_detail.is_visible_in_tree() or (order_window != null and order_window.is_visible_in_tree())) and str(_main.get("_unified_primary_tab")) == "trade", "1. intel -> trade switches the tab")
	await _press(&"system")
	_expect(not _detail.is_visible_in_tree() and popup.is_visible_in_tree(), "1. trade -> system: CityDetailPanel hidden, system window shown")
	_expect(popup.get_node_or_null("VBoxContainer/Buttons/SaveButton") != null or _find(popup, "SaveButton") != null, "1. system window has save / load")
	await _press(&"system")
	_expect(not popup.is_visible_in_tree(), "1. system again -> closed")
	await _press(&"info")
	_expect(popup.is_visible_in_tree() and str((_find(popup, "Body") as Label).text).contains("준비 중"), "1. info -> 준비 중")
	await _press(&"info")


# ---------------------------------------------------------------- 6 + 7
func _check_city_window_and_recruit() -> void:
	_set_stock(OWN_CITY, DISTINCT)
	await _select(OWN_CITY)
	_expect(_detail.is_visible_in_tree(), "6. city click -> CityDetailPanel shown")
	var text := _storage_text()
	var missing := []
	for resource_id in RESOURCES:
		if not text.contains(str(DISTINCT[resource_id])):
			missing.append(resource_id)
	_expect(missing.is_empty(), "6. hanseong shows all 9 stock numbers (missing %s)" % str(missing))
	# 7. recruit from the military window: troops up, cost out, the numbers shown at once.
	var before_stock := _stock(OWN_CITY)
	var troops_before := int(_main.call("_get_city_troops_for_battle_context", OWN_CITY))
	await _press(&"military")
	var popup: Control = _router.call("get_popup")
	var recruit := _find(popup, "RecruitButton") as Button
	_expect(recruit != null and not recruit.disabled, "7. recruit button enabled for hanseong")
	if recruit != null:
		recruit.emit_signal("pressed")
	await process_frame
	var troops_after := int(_main.call("_get_city_troops_for_battle_context", OWN_CITY))
	var after_stock := _stock(OWN_CITY)
	_expect(troops_after > troops_before, "7. troops %d -> %d" % [troops_before, troops_after])
	var paid := []
	for resource_id in RESOURCES:
		if int(after_stock[resource_id]) < int(before_stock[resource_id]):
			paid.append(resource_id)
	_expect(not paid.is_empty(), "7. the recruitment cost left the city stock (%s)" % str(paid))
	var shown := _storage_text()
	var stale := []
	for resource_id in paid:
		if not shown.contains(str(after_stock[resource_id])):
			stale.append(resource_id)
	_expect(stale.is_empty(), "6/7. the shown stock is the new one at once (stale %s)" % str(stale))
	await _press(&"military")


# ---------------------------------------------------------------- 2
func _check_diplomacy() -> void:
	_reset_stocks()
	await _select(ENEMY_CITY)
	await _press(&"diplomacy")
	var envoy := _find(_detail, "DiplomacyEnvoyButton") as Button
	_expect(envoy != null and envoy.is_visible_in_tree(), "2. envoy button visible in the diplomacy window")
	var national_before := _national_gold()
	if envoy != null:
		envoy.emit_signal("pressed")
	await process_frame
	_expect(national_before - _national_gold() == 30, "2. envoy cost 30 left the city stock (%d -> %d)" % [national_before, _national_gold()])
	var rating: Label = _main.get("city_detail_rating_label")
	_expect(rating.is_visible_in_tree() and rating.text.contains("접수됨"), "2. one pending line: %s" % rating.text.replace("\n", " / "))
	_end_turn()
	_main.call("_refresh_unified_panel_content")
	await process_frame
	_expect(rating.text.contains("결과"), "2. after the turn end the result line shows: %s" % rating.text.replace("\n", " / "))
	await _press(&"diplomacy")


# ---------------------------------------------------------------- 3
func _check_intel() -> void:
	_reset_stocks()
	var state: Dictionary = _main.get("_player_state")
	state["chancellor_id"] = "jeong_do_jeon"
	state["spy_cooldown"] = 0
	var target: Dictionary = _main.call("_get_mutable_city_runtime_state", ENEMY_CITY)
	target["publicSupport"] = 40
	await _select(ENEMY_CITY)
	await _press(&"intel")
	var disrupt := _find(_detail, "SpyPublicSupportButton") as Button
	_expect(disrupt != null and disrupt.is_visible_in_tree(), "3. public support disrupt button visible")
	var national_before := _national_gold()
	if disrupt != null:
		disrupt.emit_signal("pressed")
	await process_frame
	var national_after := _national_gold()
	_expect(national_before - national_after == 300, "3. disrupt cost 300 (%d -> %d) %s" % [national_before, national_after, str(state.get("last_spy_result", {}).get("reason", ""))])
	_expect(_left_panel_text().contains(str(national_after)) or _left_panel_text().contains(_thousands(national_after)), "3. the national gold shown at once (%d)" % national_after)
	# gather info with the success roll fixed (order 8-2), then the window shows the report card
	state["spy_cooldown"] = 0
	var spy: Object = _main.call("_ensure_spy_controller")
	spy.call("validate_spy_action", "gather_info", ENEMY_CITY)
	var gathered: Dictionary = spy.get("_service").call("_gather_spy_info", ENEMY_CITY, 1, 100)
	_expect(bool(gathered.get("success", false)), "3. fixed-roll gather info succeeds")
	_main.call("_refresh_city_hud_data_bindings")
	_main.call("_refresh_unified_panel_content")
	await process_frame
	var card: Label = _main.get("city_detail_rating_label")
	_expect(card.is_visible_in_tree() and card.text.contains("정탐 결과") and card.text.contains("재고"), "3. spy report card visible with the stock: %s" % card.text.replace("\n", " / "))
	var aptitude := int(_main.call("_get_current_chancellor_political_aptitude"))
	_expect(aptitude < 3 or card.text.contains("소속 장수"), "3. chancellor political aptitude %d >= 3 -> the heroes are shown" % aptitude)
	await _press(&"intel")
	_check_spy_costs()


## Order 8-1: exact ledger values (never the validation's own numbers).
func _check_spy_costs() -> void:
	var cases := [
		["public_support_disrupt", {"gold": 300}, {}],
		["loyalty_disrupt", {"gold": 500, "silk": 50}, {"loyalty": 40}],
		["revolt_instigate", {"gold": 800, "silk": 100}, {"publicSupport": 40, "loyalty": 40}],
	]
	for case in cases:
		var action_id: String = case[0]
		var cost: Dictionary = case[1]
		for short in [false, true]:
			_prepare_spy_target(case[2])
			var stock := {}
			for resource_id in RESOURCES:
				stock[resource_id] = int(cost.get(resource_id, 0))
			if short:
				stock["gold"] = int(cost.gold) - 1
			_set_stock(OWN_CITY, stock)
			var before := _stock(OWN_CITY)
			_main.call("_apply_spy_action", action_id, ENEMY_CITY)
			var spent := _diff(before, _stock(OWN_CITY))
			var cooldown := int((_main.get("_player_state") as Dictionary).get("spy_cooldown", 0))
			if short:
				_expect(spent.is_empty() and cooldown == 0, "8-1. %s with 1 gold short: nothing taken, no cooldown (%s, cd %d)" % [action_id, str(spent), cooldown])
			else:
				_expect(spent == cost, "8-1. %s takes exactly %s once (%s)" % [action_id, str(cost), str(spent)])
				_expect(_national_gold() == int(_stock(OWN_CITY).gold), "8-1. %s: national gold = the city sum" % action_id)
				var again_before := _stock(OWN_CITY)
				_main.call("_apply_spy_action", action_id, ENEMY_CITY)  # on cooldown now
				_expect(_diff(again_before, _stock(OWN_CITY)).is_empty(), "8-1. %s again on cooldown: nothing taken" % action_id)
	_prepare_spy_target({})
	_set_stock(OWN_CITY, {"gold": 300})
	var own_before := _stock(OWN_CITY)
	_main.call("_apply_spy_action", "public_support_disrupt", OWN_CITY)
	_expect(_diff(own_before, _stock(OWN_CITY)).is_empty(), "8-1. own city target: nothing taken")


func _prepare_spy_target(values: Dictionary) -> void:
	var state: Dictionary = _main.get("_player_state")
	state["chancellor_id"] = "jeong_do_jeon"
	state["spy_cooldown"] = 0
	var target: Dictionary = _main.call("_get_mutable_city_runtime_state", ENEMY_CITY)
	target["publicSupport"] = int(values.get("publicSupport", 60))
	target["loyalty"] = int(values.get("loyalty", 70))
	(_main.get("_city_runtime_states") as Dictionary)[ENEMY_CITY] = target


func _diff(before: Dictionary, after: Dictionary) -> Dictionary:
	var result := {}
	for resource_id in RESOURCES:
		var delta := int(before.get(resource_id, 0)) - int(after.get(resource_id, 0))
		if delta != 0:
			result[resource_id] = delta
	return result


# ---------------------------------------------------------------- 4
func _check_trade() -> void:
	_reset_stocks()
	var partner := ""
	# Queue 46 (배치 A): 개성 (also the player's) sorts before 한성 as the contextual source of every partner, so the
	# partner is the first of 한성's own external trade candidates (the orders below name 한성 as the source).
	var own_candidates: Array = _main.call("_get_external_trade_candidate_city_ids", OWN_CITY)
	own_candidates.sort()
	partner = str(own_candidates[0]) if not own_candidates.is_empty() else ""
	_expect(not partner.is_empty(), "4. a trade partner exists")
	if partner.is_empty():
		return
	await _select(OWN_CITY)
	await _press(&"trade")
	var order_panel := _main.get("_manual_trade_order_panel") as Control
	_expect(order_panel != null and order_panel.is_visible_in_tree(), "4. trade menu on an own city opens the order window")
	var trade: Object = _main.call("_ensure_trade_controller")
	var order := {"source_city_id": OWN_CITY, "target_city_id": partner, "trade_type": "external", "mode": "manual", "orders": {"rice": {"action": "export", "amount": 100}}}
	order["preview"] = trade.call("build_external_manual_trade_execution_preview", order)
	order["efficiency"] = trade.call("get_trade_efficiency_for_cities", OWN_CITY, partner)
	trade.call("store_manual_trade_order", order)  # what the order window's confirm stores
	_main.call("_close_manual_trade_order_panel")
	_main.call("_refresh_unified_panel_content")
	await process_frame
	var execute := _main.get("_manual_trade_execution_button") as Button
	_expect(execute != null and execute.is_visible_in_tree(), "4. the execute button shows for the stored order")
	var source_before := _stock(OWN_CITY)
	var partner_before := _stock(partner)
	if execute != null:
		execute.emit_signal("pressed")
	await process_frame
	var status: Label = _main.get("city_detail_status_label")
	_expect(status.text.contains("접수됨"), "4. submitted line: %s" % status.text.replace("\n", " / "))
	_end_turn()
	_main.call("_refresh_unified_panel_content")
	await process_frame
	_expect(status.text.contains("결과"), "4. the settled result line: %s" % status.text.replace("\n", " / "))
	var gain := int((order["preview"] as Dictionary).get("gold", 0))
	var source_rice := int(_stock(OWN_CITY).rice) - int(source_before.rice)
	var partner_rice := int(_stock(partner).rice) - int(partner_before.rice)
	_expect(partner_rice == 100 and source_rice <= -100, "4. rice 100 hanseong -> partner (source %d, partner %+d)" % [source_rice, partner_rice])
	_expect(gain > 0, "4. the export earns gold (+%d)" % gain)
	await _press(&"trade")


# ---------------------------------------------------------------- 5
func _check_save_load() -> void:
	_reset_stocks()
	await _press(&"system")
	var popup: Control = _router.call("get_popup")
	var envoy: Dictionary = _main.call("_ensure_diplomacy_controller").call("execute", "envoy", ENEMY_CITY)
	_expect(bool(envoy.get("submitted", false)) or not envoy.is_empty(), "5. a pending request to save")
	var saved_cities := _cities_snapshot()
	var saved_pending := _pending_ids()
	(_find(popup, "SaveButton") as Button).emit_signal("pressed")
	await process_frame
	_set_stock(OWN_CITY, {"gold": 1})
	_end_turn()
	_expect(_cities_snapshot() != saved_cities, "5. something changed after the save")
	(_find(popup, "LoadButton") as Button).emit_signal("pressed")
	for i in 3:
		await process_frame
	_expect(_cities_snapshot() == saved_cities, "5. load: 65 cities owner / troops / stock as saved")
	_expect(_pending_ids() == saved_pending, "5. load: pending requests as saved %s" % str(_pending_ids()))
	if _is_3d():
		var host: Node = _main.get_node("WorldMap3DHost")
		host.get("adapter").call("sync_all")
		var bad := []
		var adapter = host.get("adapter")
		var root3d = adapter.get("root3d")
		# Queue 46: the 21 new placement-A factions have no 3D faction colour yet (a pending decision), so the 3D map
		# refuses them as owners and the adapter records the pair in unmapped_owners - those cities are checked to be
		# exactly the ones whose owner has no 3D colour; every other city must match the save.
		var unmapped := {}
		for key in adapter.get("unmapped_owners"):
			unmapped[str(key).split(":")[0]] = str(key).split(":")[1]
		var colour_missing := []
		for city_id in saved_cities:
			var owner := str(saved_cities[city_id][0])
			if unmapped.get(city_id, "") == owner and not owner.is_empty():
				colour_missing.append(city_id)
				continue
			var c: Dictionary = (root3d.get("cities") as Dictionary).get(city_id, {})
			if str(c.get("owner", "")) != owner or int(c.get("troops", -1)) != int(saved_cities[city_id][1]):
				bad.append(city_id)
		_expect(bad.is_empty(), "5. load: 3D owner / troops as saved %s" % str(bad))
		var no_colour := colour_missing.filter(func(c): return not (_main.get("FACTION_LABELS") as Dictionary).has(str(saved_cities[c][0])))
		_expect(no_colour.size() == colour_missing.size(), "5. load: only owners without a 3D colour (new factions) are left unmapped %s" % str(colour_missing))
	await _press(&"system")


# ---------------------------------------------------------------- 8
func _check_action_menu() -> void:
	var controller := _find_by_script(_main, CityActionController)
	_expect(controller != null, "8. city action controller")
	if controller == null:
		return
	await _select(ENEMY_CITY)
	await process_frame
	var panel: Control = controller.get("_panel")
	_expect(panel != null and panel.is_visible_in_tree(), "8. action menu open on 평양")
	if panel == null or not panel.visible:
		return
	var anchor: Variant = _city_screen(ENEMY_CITY)
	var centre := panel.position + panel.size * 0.5
	_expect(anchor != null and centre.distance_to(anchor) < 160.0, "8. menu centre %s near the city %s" % [str(centre), str(anchor)])
	if _is_3d():
		var camera: Camera3D = _main.get_node("WorldMap3DHost").get("adapter").call("get_camera")
		var saved := camera.global_transform
		camera.global_transform = Transform3D(Basis.IDENTITY, Vector3(0, 50, 0)).looking_at(Vector3(0, 50, -100000), Vector3.UP)
		camera.global_position += Vector3(0, 0, -5000)
		await process_frame
		await process_frame
		if _city_screen(ENEMY_CITY) == null:
			_expect(not panel.visible, "8. city behind the camera -> menu closed")
		camera.global_transform = saved
	controller.call("_hide_menu")


# ---------------------------------------------------------------- 9
func _check_unclaimed() -> void:
	var controller := _find_by_script(_main, CityActionController)
	# (order 8-2) plain, with the intel window (a popup) open, and after a save/load copy.
	for variant in ["plain", "intel window open", "after save/load"]:
		if variant == "after save/load":
			var parsed: Variant = JSON.parse_string(JSON.stringify(_main.call("_serialize_worldmap_state")))
			_main.call("_apply_worldmap_state", parsed)
		await _select(ENEMY_CITY)
		if variant == "intel window open":
			await _press(&"intel")
		await _select(EMPTY_CITY)
		if variant != "intel window open":
			_expect(_detail.is_visible_in_tree() and _storage_text().contains(WorldMapUnclaimedCityRules.OWNER_LABEL), "9. %s: city window %s" % [variant, _storage_text().replace("\n", " / ")])
		var panel: Control = controller.get("_panel") if controller != null else null
		_expect(panel == null or not panel.visible, "9. %s: unclaimed city -> action menu closed" % variant)
		var before := _stock(OWN_CITY)
		controller.call("_on_contextual_action_pressed", "spy")
		_main.call("_on_spy_action_pressed", "public_support_disrupt")
		_expect(_diff(before, _stock(OWN_CITY)).is_empty(), "9. %s: no action of 평양 runs on the unclaimed city" % variant)
		var spy_check: Dictionary = _main.call("_validate_spy_action", "gather_info", EMPTY_CITY)
		_expect(not bool(spy_check.get("ok", true)), "9. %s: 상주 is not a spy target" % variant)
		if variant == "intel window open":
			await _press(&"intel")
			await _select(EMPTY_CITY)
			_expect(_detail.is_visible_in_tree() and _storage_text().contains(WorldMapUnclaimedCityRules.OWNER_LABEL), "9. %s: city window %s" % [variant, _storage_text().replace("\n", " / ")])


# ---------------------------------------------------------------- helpers
func _press(menu_id: StringName) -> void:
	_nav.call("_on_menu_pressed", menu_id)
	await process_frame


func _select(city_id: String) -> void:
	var marker = (_main.get("_city_markers_by_id") as Dictionary).get(city_id)
	if marker != null:
		marker.city_selected.emit(marker)
	await process_frame
	await process_frame


func _is_3d() -> bool:
	var host := _main.get_node_or_null("WorldMap3DHost")
	return host != null and bool(host.get("active")) and host.get("adapter") != null and bool(host.get("adapter").call("can_project_cities"))


func _city_screen(city_id: String) -> Variant:
	if _is_3d():
		return _main.get_node("WorldMap3DHost").get("adapter").call("city_screen_position", city_id)
	var marker = (_main.get("_city_markers_by_id") as Dictionary).get(city_id)
	return (marker as Node2D).get_global_transform_with_canvas().origin if marker != null else null


func _storage_text() -> String:
	var label: Label = _main.get("city_detail_status_label")
	return label.text if label != null else ""


func _left_panel_text() -> String:
	var texts: Array[String] = []
	_collect_texts(_main.get_node("WorldMapUI/LeftWorldStatusPanel"), texts)
	return " | ".join(texts)


func _collect_texts(node: Node, texts: Array[String]) -> void:
	if node is Label and (node as Label).is_visible_in_tree():
		texts.append((node as Label).text)
	for child in node.get_children():
		_collect_texts(child, texts)


func _thousands(value: int) -> String:
	var digits := str(value)
	var out := ""
	for i in digits.length():
		if i > 0 and (digits.length() - i) % 3 == 0:
			out += ","
		out += digits[i]
	return out


func _find(node: Node, node_name: String) -> Node:
	if node == null:
		return null
	return node.find_child(node_name, true, false)


func _find_by_script(node: Node, script: Script) -> Node:
	if node.get_script() == script:
		return node
	for child in node.get_children():
		var found := _find_by_script(child, script)
		if found != null:
			return found
	return null


func _stock(city_id: String) -> Dictionary:
	var raw: Dictionary = _main.call("_get_city_storage", city_id)
	var result := {}
	for resource_id in RESOURCES:
		result[resource_id] = int(raw.get(resource_id, 0))
	return result


func _set_stock(city_id: String, values: Dictionary) -> void:
	var stock: Dictionary = (_main.call("_get_city_storage", city_id) as Dictionary).duplicate(true)
	for resource_id in RESOURCES:
		stock[resource_id] = int(values.get(resource_id, 0))
	_main.call("_set_city_storage", city_id, stock)


func _reset_stocks() -> void:
	_set_stock(OWN_CITY, DISTINCT)
	var partner_stock := {}
	for resource_id in RESOURCES:
		partner_stock[resource_id] = 5000
	for city_id in _main.get("_city_markers_by_id"):
		var owner := str(_main.call("_get_city_owner_faction_id_for_trade_display", str(city_id)))
		if not owner.is_empty() and str(city_id) != OWN_CITY:
			# Queue 46: under 배치 A the player also owns 개성; its stock is emptied so the national sum is 한성's alone.
			_set_stock(str(city_id), {} if bool(_main.call("_is_city_owned_by_player_mvp", str(city_id))) else partner_stock)
	var state: Dictionary = _main.get("_player_state")
	state["diplomacy_action_cooldown"] = 0
	state["spy_cooldown"] = 0
	for faction_id in ["goguryeo", "baekje_faction", "silla"]:
		var relation: Dictionary = _main.call("_ensure_faction_relation_entry", str(_main.call("_get_current_player_faction_id")), faction_id)
		relation["diplomacy_action_cooldown"] = 0


func _national_gold() -> int:
	var total := 0
	for city_id in _main.call("_get_national_payment_city_ids_mvp"):
		total += int(_stock(str(city_id)).gold)
	return total


func _cities_snapshot() -> Dictionary:
	var result := {}
	for city_id in (_main.get("_city_markers_by_id") as Dictionary):
		var id := str(city_id)
		var entry: Dictionary = _main.call("_get_city_hud_entry", id)
		result[id] = [str(_main.call("_get_city_owner_faction_id_for_trade_display", id)), int(entry.get("troops", 0)), _stock(id)]
	return result


func _pending_ids() -> Array:
	var ids: Array = []
	for request in Strategy.get_pending_requests(_main.call("_ensure_diplomacy_controller")):
		ids.append(str(request.get("request_id", "")))
	ids.sort()
	return ids


func _end_turn() -> void:
	var turn_controller = _main.call("_ensure_turn_controller")
	(_main.get("_player_state") as Dictionary)["pending_invasion_event"] = {}
	turn_controller.call("request_end_turn")
	turn_controller.call("finish_enemy_turn")
	(_main.get("_player_state") as Dictionary)["pending_invasion_event"] = {}
	_main.call("_clear_pending_invasion_event_mvp")


func _expect(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(message)
		push_error("[HUD_CONNECT_3D] FAIL: %s" % message)


func _finish() -> void:
	print("[HUD_CONNECT_3D] checks=%d failures=%s" % [_checks, str(_failures)])
	quit(0 if _failures.is_empty() else 1)
