extends SceneTree

# Queue 39 CITIES65 0.7: 65 cities, the 52 new ones unclaimed (빈 성, owner ""). Real WorldMap.tscn, new game.
#  1. 65 cities in the HUD data, the 3D rules, the 3D markers and the game markers; no duplicate id; the 13 legacy ids kept
#     with their owner / troops / population / grade
#  2. every city centre lies on its own region index in region_ids.png (65/65)
#  3. 100 land roads + 20 sea routes; 건업–강동, 오사카–히로시마, 큐슈–가고시마 are land and need no naval research
#     (control: the legacy sea route 큐슈–오사카 still does)
#  4. 상도 (karakorum): name, 0.7 position, region label 내몽골, none of the old direct roads
#  5. five turns with the unclaimed cities: no owner change, AI production / invasion candidates only legacy cities
#  6. save -> load keeps all 65 city states; an old 13-city save loads, the 52 new cities stay at their defaults
#  7. (P0 / P3 / P1 regressions: test_worldmap_stock_authority_p0 / spy_intel_p3 / strategy_p1 stay on C-track)
#  8. menu on an enemy city, then an unclaimed city: the menu closes, no action of the previous city runs; back -> normal
#  9. after a turn + a save/load copy: no unclaimed city in AI production / invasion candidates, diplomacy / trade / spy
#     targets, the victory city list, player sortie targets, the owned city list (also in the save) or the national stock
# Queue 46 (PLACEMENT_A, 0.7 game links): a new game now fills 26 of the 52 new cities (배치 A). The unclaimed-city checks
# (1, 5, 6, 8, 9) run on the 26 that stay unclaimed; the 26 placed ones are checked against the placement (owner, marker).
# 큐슈–오사카 is not a 0.7 link any more: the naval control in 3 is the 0.7 sea route 큐슈–히젠.

const WORLDMAP_SCENE_PATH := "res://WorldMap.tscn"
const RULES := "res://worldmap3d/maps/eastasia/rule_data_eastasia.json"
const MARKERS := "res://worldmap3d/maps/eastasia/markers.json"
const REGIONS := "res://worldmap3d/maps/eastasia/regions.json"
const REGION_IDS := "res://worldmap3d/maps/eastasia/textures/region_ids.png"
const MAP_CONFIG := "res://worldmap3d/maps/eastasia/map_config.json"
const CityActionController := preload("res://scripts/worldmap/ui/worldmap_city_action_controller.gd")
const LEGACY := {
	"hanseong": ["player", 300, 50000, 2], "pyeongyang": ["goguryeo", 280, 42000, 2], "sabi": ["baekje_faction", 300, 44000, 2],
	"gyeongju": ["silla", 280, 48000, 2], "edo": ["tokugawa", 380, 46000, 2], "kyoto": ["oda", 240, 45000, 2],
	"osaka": ["toyotomi", 260, 50000, 2], "kyushu": ["kyushu_faction", 270, 42000, 2], "yecheng": ["wei", 450, 55000, 2],
	"luoyang": ["chu", 420, 80000, 2], "jianye": ["wu", 300, 52000, 2], "chengdu": ["shu", 350, 60000, 2],
	"karakorum": ["mongol_faction", 460, 36000, 2],
}
const OLD_DIRECT_ROADS := [["karakorum", "pyeongyang"], ["karakorum", "yecheng"], ["hanseong", "pyeongyang"], ["chengdu", "jianye"]]
const PROMOTED_LAND := [["jianye", "jiangdong"], ["osaka", "hiroshima"], ["kyushu", "kagoshima"]]
const SEA_CONTROL := ["kyushu", "hizen"]
const EMPTY_CITY := "sangju"  # unclaimed under 배치 A, next to 한성
const Placement := preload("res://scripts/worldmap/worldmap_placement_a.gd")

var _checks := 0
var _failures: Array[String] = []
var _main: Node
var _rules: Dictionary
var _new_ids: Array[String] = []
var _unclaimed_ids: Array[String] = []
var _placed: Dictionary = {}


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.size = Vector2i(1920, 1080)
	_rules = _json(RULES)
	for city in _rules.get("cities", []):
		if not LEGACY.has(str(city.id)):
			_new_ids.append(str(city.id))
	_expect(bool(root.get_node("/root/GameSession").call("request_new_game", "player")), "new game requested")
	_expect(change_scene_to_file(WORLDMAP_SCENE_PATH) == OK, "WorldMap scene transition starts")
	for i in 6:
		await process_frame
	_main = current_scene
	_expect(_main != null and _main.scene_file_path == WORLDMAP_SCENE_PATH, "WorldMap scene loaded")
	if _main == null:
		_finish()
		return
	var placement := Placement.load_placement(HeroDefinitionRegistry.HERO_DATA, _main.get("CITY_HUD_DATA"))
	for city_id in placement.cities:
		_placed[city_id] = str(placement.cities[city_id].faction_id)
	for city_id in _new_ids:
		if not _placed.has(city_id):
			_unclaimed_ids.append(city_id)
	_expect(_unclaimed_ids.size() == 26, "26 of the 52 new cities stay unclaimed under 배치 A (%d)" % _unclaimed_ids.size())
	_check_roster()
	_check_regions()
	_check_roads()
	_check_shangdu()
	await _check_menu_switch()
	_check_turns()
	_check_save_load()
	_check_exclusions("9. after turns")
	_round_trip()
	_check_exclusions("9. after save/load")
	_finish()


# ---------------------------------------------------------------- 1
func _check_roster() -> void:
	var hud: Dictionary = _main.get_script().get_script_constant_map().get("CITY_HUD_DATA", {})
	var markers: Dictionary = _main.get("_city_markers_by_id")
	var marker_km: Dictionary = _json(MARKERS).get("markers", {})
	var ids := {}
	for city in _rules.cities:
		_expect(not ids.has(city.id), "1. no duplicate id %s" % city.id)
		ids[city.id] = true
	_expect(ids.size() == 65 and _new_ids.size() == 52, "1. 65 cities in the 3D rules, 52 new (%d / %d)" % [ids.size(), _new_ids.size()])
	_expect(hud.size() == 65, "1. 65 cities in CITY_HUD_DATA (%d)" % hud.size())
	_expect(markers.size() == 65, "1. 65 game markers (%d)" % markers.size())
	_expect(marker_km.size() == 65, "1. 65 3D marker positions (%d)" % marker_km.size())
	for city_id in ids:
		_expect(hud.has(city_id) and markers.has(city_id) and marker_km.has(city_id), "1. %s everywhere" % city_id)
	for city_id in LEGACY:
		var want: Array = LEGACY[city_id]
		var entry: Dictionary = _main.call("_get_city_hud_entry", city_id)
		var rule := _rule_city(city_id)
		_expect(str(entry.get("owner", "")) == want[0] and int(entry.get("troops", -1)) == want[1] and int(entry.get("population", -1)) == want[2],
			"1. legacy %s keeps owner / troops / population %s" % [city_id, str([entry.get("owner"), entry.get("troops"), entry.get("population")])])
		_expect(str(rule.get("owner", "")) == want[0] and int(rule.get("troops", -1)) == want[1] and int(rule.get("grade", -1)) == want[3], "1. legacy %s 3D rules unchanged" % city_id)
	for city_id in _new_ids:
		var entry: Dictionary = _main.call("_get_city_hud_entry", city_id)
		var want_owner := str(_placed.get(city_id, ""))
		if want_owner.is_empty():
			_expect(str(entry.get("owner", "x")) == "" and int(entry.get("troops", -1)) == 0, "1. new %s: owner \"\" and 0 troops" % city_id)
		else:
			_expect(str(entry.get("owner", "")) == want_owner and int(entry.get("troops", 0)) > 0, "1. new %s: placed for %s with troops" % [city_id, want_owner])
		_expect(str(markers[city_id].owner_faction_id) == want_owner and not (markers[city_id].neighbors as Array).is_empty(), "1. new %s marker: owner %s, with 0.7 links" % [city_id, want_owner])
	_expect(str(_main.call("_format_faction_label", "")) == WorldMapUnclaimedCityRules.OWNER_LABEL, "1. owner label of an unclaimed city = 주인 없음(빈 성)")


# ---------------------------------------------------------------- 2
func _check_regions() -> void:
	var image := Image.load_from_file(ProjectSettings.globalize_path(REGION_IDS))
	var size_km: Array = _json(MAP_CONFIG).get("size_km", [1.0, 1.0])
	var marker_km: Dictionary = _json(MARKERS).get("markers", {})
	var index_by_city := {}
	for region in _json(REGIONS).get("regions", []):
		index_by_city[str(region.city_id)] = int(region.index)
	_expect(index_by_city.size() == 65, "2. 65 regions (%d)" % index_by_city.size())
	var on_own := 0
	var wrong := []
	for city_id in marker_km:
		var km: Dictionary = marker_km[city_id]
		var uv := Vector2(float(km.x_km) / float(size_km[0]) + 0.5, float(km.z_km) / float(size_km[1]) + 0.5)
		var px := Vector2i(clampi(int(uv.x * image.get_width()), 0, image.get_width() - 1), clampi(int(uv.y * image.get_height()), 0, image.get_height() - 1))
		var index := int(round(image.get_pixelv(px).r * 255.0))
		if index == int(index_by_city.get(city_id, -1)):
			on_own += 1
		else:
			wrong.append([city_id, index, index_by_city.get(city_id, -1)])
	_expect(on_own == 65, "2. every city centre on its own region pixel (%d/65, wrong %s)" % [on_own, str(wrong)])


# ---------------------------------------------------------------- 3
func _check_roads() -> void:
	var land := {}
	var sea := {}
	for pair in _rules.roads:
		land[_key(pair[0], pair[1])] = true
	for pair in _rules.sea_routes:
		sea[_key(pair[0], pair[1])] = true
	_expect(land.size() == 100 and sea.size() == 20, "3. 100 land roads + 20 sea routes (%d / %d)" % [land.size(), sea.size()])
	# A new game has no warship research: a pair that is not a naval route is open to a non-naval sortie.
	for pair in PROMOTED_LAND:
		var k := _key(pair[0], pair[1])
		_expect(land.has(k) and not sea.has(k), "3. %s is a land road in the map data" % k)
		_expect(str(_main.call("_get_city_route_type_between_mvp", pair[0], pair[1])) == "land", "3. %s route type land in the game" % k)
		_expect(not bool(_main.call("_is_naval_attack_route_mvp", pair[0], pair[1])), "3. %s needs no naval research" % k)
	_expect(sea.has(_key(SEA_CONTROL[0], SEA_CONTROL[1])) and bool(_main.call("_is_naval_attack_route_mvp", SEA_CONTROL[0], SEA_CONTROL[1])), "3. control: the 0.7 sea route 큐슈–히젠 needs naval research")


# ---------------------------------------------------------------- 4
func _check_shangdu() -> void:
	var entry: Dictionary = _main.call("_get_city_hud_entry", "karakorum")
	_expect(str(entry.get("name", "")) == "상도" and str(_rule_city("karakorum").get("name_ko", "")) == "상도", "4. karakorum shown as 상도")
	var marker = (_main.get("_city_markers_by_id") as Dictionary).get("karakorum")
	_expect(marker != null and str(marker.display_name) == "상도", "4. 2D marker name 상도")
	var km: Dictionary = _json(MARKERS).markers.karakorum
	_expect(absf(float(km.lonlat[0]) - 116.185) < 0.001 and absf(float(km.lonlat[1]) - 42.358) < 0.001, "4. 상도 at 116.185E 42.358N (%s)" % str(km.lonlat))
	var label := ""
	for region in _json(REGIONS).regions:
		if str(region.city_id) == "karakorum":
			label = str(region.get("label_ko", ""))
	_expect(label == "내몽골", "4. 상도 region label 내몽골 (%s)" % label)
	var all_links := {}
	for pair in _rules.roads + _rules.sea_routes:
		all_links[_key(pair[0], pair[1])] = true
	for pair in OLD_DIRECT_ROADS:
		_expect(not all_links.has(_key(pair[0], pair[1])), "4. old direct road %s-%s is gone" % pair)


# ---------------------------------------------------------------- 8
func _check_menu_switch() -> void:
	var controller := _find_city_action_controller(_main)
	_expect(controller != null, "8. city action controller found")
	if controller == null:
		return
	var markers: Dictionary = _main.get("_city_markers_by_id")
	markers.pyeongyang.city_selected.emit(markers.pyeongyang)
	await process_frame
	var panel: Control = controller.get("_panel")
	_expect(panel != null and panel.visible and controller.get("_selected_marker") == markers.pyeongyang, "8. enemy city 평양: menu open")
	var empty_id := EMPTY_CITY
	markers[empty_id].city_selected.emit(markers[empty_id])
	await process_frame
	_expect(str(_main.get("selected_city_id")) == empty_id, "8. selection switched to the unclaimed city")
	_expect(not panel.visible and controller.get("_selected_marker") == null, "8. menu closed on the unclaimed city")
	var before := JSON.stringify(_main.call("_serialize_worldmap_state"))
	controller.call("_on_contextual_action_pressed", "spy")
	controller.call("_on_battle_pressed")
	_expect(JSON.stringify(_main.call("_serialize_worldmap_state")) == before, "8. no action of the previous city runs")
	_expect(not str(_main.call("_get_player_attack_block_reason", empty_id)).is_empty(), "8. the unclaimed city cannot be attacked")
	markers.pyeongyang.city_selected.emit(markers.pyeongyang)
	await process_frame
	_expect(panel.visible and controller.get("_selected_marker") == markers.pyeongyang and str(_main.get("selected_city_id")) == "pyeongyang", "8. back on 평양: menu normal")
	controller.call("_hide_menu")


# ---------------------------------------------------------------- 5
func _check_turns() -> void:
	var owners_before := _owners()
	for i in 5:
		_end_turn()
	var owners_after := _owners()
	var changed := []
	for city_id in _unclaimed_ids:
		if owners_after.get(city_id, "") != "":
			changed.append(city_id)
	_expect(changed.is_empty(), "5. five turns: no unclaimed city got an owner %s" % str(changed))
	for city_id in LEGACY:
		_expect(not str(owners_after.get(city_id, "")).is_empty(), "5. legacy %s still owned (%s -> %s)" % [city_id, owners_before.get(city_id), owners_after.get(city_id)])
	_expect(int((_main.get("_player_state") as Dictionary).get("turn_number", 1)) >= 6, "5. five turns advanced")


# ---------------------------------------------------------------- 6
func _check_save_load() -> void:
	var saved: Dictionary = JSON.parse_string(JSON.stringify(_main.call("_serialize_worldmap_state")))
	var before := _city_snapshot()
	_expect(bool(_main.call("_apply_worldmap_state", saved)), "6. save -> load")
	_expect(_city_snapshot() == before, "6. all 65 city states equal after load")
	# An old save: only the 13 legacy cities in the city state.
	var old_save: Dictionary = saved.duplicate(true)
	(old_save.get("player_state", {}) as Dictionary).erase("world_placement_id")  # an old save has no placement marker
	var city_state: Variant = old_save.get("worldmap_city_state", {})
	if city_state is Dictionary:
		for city_id in (city_state as Dictionary).keys():
			if not LEGACY.has(str(city_id)):
				(city_state as Dictionary).erase(city_id)
	_expect(bool(_main.call("_apply_worldmap_state", old_save)), "6. old 13-city save loads")
	var snapshot := _city_snapshot()
	var bad := []
	for city_id in _new_ids:
		if snapshot[city_id] != [""	, 0]:
			bad.append(city_id)
	for city_id in LEGACY:
		if snapshot[city_id] != before[city_id]:
			bad.append(city_id)
	_expect(bad.is_empty(), "6. old save: new cities at defaults, legacy values kept %s" % str(bad))


# ---------------------------------------------------------------- 9
func _check_exclusions(tag: String) -> void:
	var hits := []
	var production: Dictionary = (_main.get("_player_state") as Dictionary).get("last_ai_domestic_apply_result", {})
	for entry in production.get("city_results", []):
		if _unclaimed_ids.has(str(entry.get("city_id", ""))):
			hits.append(["ai_production", entry.city_id])
	var warfare: Object = _main.call("_ensure_enemy_warfare_service")
	for pair in warfare.call("get_invasion_pairs"):
		for key in ["attacker_city_id", "defender_city_id"]:
			if _unclaimed_ids.has(str(pair.get(key, ""))):
				hits.append(["invasion", pair.get(key)])
	for candidate in warfare.call("build_pressure_plan_candidates"):
		for value in (candidate as Dictionary).values():
			if value is String and _unclaimed_ids.has(value):
				hits.append(["pressure_plan", value])
	var player := str(_main.call("_get_current_player_faction_id"))
	var state: Dictionary = _main.get("_player_state")
	state["chancellor_id"] = "jeong_do_jeon"
	state["spy_cooldown"] = 0
	for faction_id in _main.call("_get_known_faction_ids_for_diplomacy"):
		if WorldMapUnclaimedCityRules.is_unclaimed_owner(faction_id):
			hits.append(["diplomacy_faction", faction_id])
	for city_id in _unclaimed_ids:
		for action_id in ["envoy", "tribute", "trade_agreement", "restore_relations", "alliance_proposal"]:
			if bool((_main.call("_validate_diplomacy_action", action_id, city_id) as Dictionary).get("ok", false)):
				hits.append(["diplomacy", action_id, city_id])
		for action_id in ["gather_info", "public_support_disrupt", "loyalty_disrupt", "revolt_instigate", "wedge"]:
			if bool((_main.call("_validate_spy_action", action_id, city_id) as Dictionary).get("ok", false)):
				hits.append(["spy", action_id, city_id])
		if str(_main.call("_get_player_attack_block_reason", city_id)).is_empty():
			hits.append(["sortie", city_id])
	var gather: Dictionary = _main.call("_validate_spy_action", "gather_info", EMPTY_CITY)
	_expect(str(gather.get("reason", "")) == WorldMapUnclaimedCityRules.REJECT_REASON, "%s: spy on 상주 refused as unclaimed (%s)" % [tag, str(gather.get("reason", ""))])
	for city_id in _main.call("_get_player_city_ids_for_national_stock_mvp"):
		if _unclaimed_ids.has(str(city_id)):
			hits.append(["national_stock", city_id])
		for target in _main.call("_get_external_trade_candidate_city_ids", str(city_id)):
			if _unclaimed_ids.has(str(target)):
				hits.append(["trade", city_id, target])
	var victory: Array = _main.get_script().get_script_constant_map().get("T03_KOREA_CITY_IDS", [])
	for city_id in victory:
		if _unclaimed_ids.has(str(city_id)):
			hits.append(["victory", city_id])
	for city_id in state.get("owned_city_ids", []):
		if _unclaimed_ids.has(str(city_id)):
			hits.append(["owned", city_id])
	var saved_text := JSON.stringify(JSON.parse_string(JSON.stringify(_main.call("_serialize_worldmap_state"))).get("player_state", {}).get("owned_city_ids", []))
	for city_id in _unclaimed_ids:
		if saved_text.contains("\"%s\"" % city_id):
			hits.append(["owned_in_save", city_id])
	_expect(hits.is_empty(), "%s: no unclaimed city in any exclusion list %s" % [tag, str(hits)])
	_expect(not player.is_empty(), "%s: player faction known" % tag)


# ---------------------------------------------------------------- helpers
func _find_city_action_controller(node: Node) -> Node:
	if node.get_script() == CityActionController:
		return node
	for child in node.get_children():
		var found := _find_city_action_controller(child)
		if found != null:
			return found
	return null


func _owners() -> Dictionary:
	var result := {}
	for city_id in (_main.get("_city_markers_by_id") as Dictionary):
		result[str(city_id)] = str(_main.call("_get_city_owner_id_for_battle_context", str(city_id)))
	return result


func _city_snapshot() -> Dictionary:
	var result := {}
	for city_id in (_main.get("_city_markers_by_id") as Dictionary):
		var entry: Dictionary = _main.call("_get_city_hud_entry", str(city_id))
		result[str(city_id)] = [str(entry.get("owner", "")), int(entry.get("troops", 0))]
	return result


func _rule_city(city_id: String) -> Dictionary:
	for city in _rules.get("cities", []):
		if str(city.id) == city_id:
			return city
	return {}


func _end_turn() -> void:
	var turn_controller = _main.call("_ensure_turn_controller")
	(_main.get("_player_state") as Dictionary)["pending_invasion_event"] = {}
	turn_controller.call("request_end_turn")
	turn_controller.call("finish_enemy_turn")
	(_main.get("_player_state") as Dictionary)["pending_invasion_event"] = {}
	_main.call("_clear_pending_invasion_event_mvp")


func _round_trip() -> void:
	var parsed: Variant = JSON.parse_string(JSON.stringify(_main.call("_serialize_worldmap_state")))
	_expect(parsed is Dictionary and bool(_main.call("_apply_worldmap_state", parsed)), "9. save -> load copy")


func _json(path: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed if parsed is Dictionary else {}


func _key(a: String, b: String) -> String:
	return a + "|" + b if a < b else b + "|" + a


func _expect(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(message)
		push_error("[CITIES65_PREVIEW] FAIL: %s" % message)


func _finish() -> void:
	print("[CITIES65_PREVIEW] checks=%d failures=%s" % [_checks, str(_failures)])
	quit(0 if _failures.is_empty() else 1)
