extends SceneTree

# Queue 37 SPY-INTEL-P3: an exact spy report shows the enemy city's real resource_stock (P0 ledger), its hero roster and
# the observed turn; the estimated (political aptitude 1) report is unchanged. Runs on the real WorldMap.tscn new game.
#  1. rice 40 in the enemy city -> exact report resources.rice == 40
#  2. gold 0 -> resources.gold == 0, not unknown; a non-numeric item -> unknown_fields has resources.<id>
#  3. a stock change before spying shows (not the seed value)
#  4. heroes: same faction normal + wounded, captured / dead / other faction left out, no duplicates
#  5. a city with no stationed hero -> heroes == [], the panel text says "0명"
#  6. observed_turn == the turn spied; the next turn keeps the recorded turn
#  7. aptitude 1 -> troops_estimated only, no resources / heroes (regression)
#  8. aptitude 2 -> troops only (regression); aptitude 3 -> troops, resources, heroes
#  9. save -> load keeps city_intel[A] (deep compare)
# 10. a paid spy action is paid out of the cities (P0) and the national sum = city sum
# 11. a failed spy report leaves city_intel unchanged
# 12. (addendum) the record stays as observed after the city's stock / roster change, a turn and save -> load; only a
#     new successful report replaces it

const WORLDMAP_SCENE_PATH := "res://WorldMap.tscn"
const PanelBase := preload("res://scripts/worldmap_city_info_panel_base.gd")

var _checks := 0
var _failures: Array[String] = []
var _main: Node
var _spy: RefCounted
var _service: RefCounted
var _target := ""
var _owner := ""
var _player := ""


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.size = Vector2i(1920, 1080)
	_expect(bool(root.get_node("/root/GameSession").call("request_new_game", "player")), "new game requested")
	_expect(change_scene_to_file(WORLDMAP_SCENE_PATH) == OK, "WorldMap scene transition starts")
	for i in 6:
		await process_frame
	_main = current_scene
	_expect(_main != null and _main.scene_file_path == WORLDMAP_SCENE_PATH, "WorldMap scene loaded")
	if _main == null:
		_finish()
		return
	_player = str(_main.call("_get_current_player_faction_id"))
	_spy = _main.call("_ensure_spy_controller")
	_service = _spy.get("_service")
	var state: Dictionary = _main.get("_player_state")
	state["chancellor_id"] = "jeong_do_jeon"
	state["spy_cooldown"] = 0
	state["city_intel"] = {}
	_target = _find_spy_target()
	_expect(not _target.is_empty(), "an enemy city that gather_info accepts exists")
	if _target.is_empty():
		_finish()
		return
	_owner = str(_main.call("_get_city_owner_faction_id_for_trade_display", _target))

	_check_stock()
	_check_heroes()
	_check_tiers()
	_check_record_turn_and_save()
	_check_snapshot_stays()
	_check_bonus_ladder()
	_check_owner_at_observation()
	_check_failure_keeps_intel()
	_check_p0_cost()
	_finish()


# ---- 1, 2, 3 ----

func _check_stock() -> void:
	_set_stock(_target, {"rice": 40, "gold": 0, "salt": 12})
	var payload := _exact_payload(5)
	var resources: Dictionary = payload.get("resources", {}) if payload.get("resources") is Dictionary else {}
	_expect(resources.size() == 9 and int(resources.get("rice", -1)) == 40, "1. exact report shows the real rice 40 (%s)" % str(payload.get("resources")))
	var unknown: Array = payload.get("unknown_fields", [])
	_expect(resources.has("gold") and int(resources.get("gold", -1)) == 0 and not unknown.has("resources.gold"), "2. gold 0 is a confirmed 0 (%s)" % str(unknown))
	var city: Dictionary = _main.call("_get_mutable_city_runtime_state", _target)
	var raw_stock: Dictionary = (city.get("resource_stock", {}) as Dictionary).duplicate(true)
	raw_stock["iron"] = "bad"
	city["resource_stock"] = raw_stock
	(_main.get("_city_runtime_states") as Dictionary)[_target] = city
	payload = _exact_payload(5)
	unknown = payload.get("unknown_fields", [])
	_expect(unknown.has("resources.iron") and not (payload.get("resources", {}) as Dictionary).has("iron"), "2. a non-numeric item is unknown (%s)" % str(unknown))
	var panel_text := _panel_hint(payload, _service.call("_get_spy_info_visibility_level", 5).get("fields", []))
	_expect(panel_text.contains("금 0") and panel_text.contains("철 ?") and panel_text.contains("쌀 40"), "2. panel shows 0 as 0 and unknown as ? (%s)" % panel_text.replace("\n", " | "))
	_set_stock(_target, {"rice": 777, "gold": 55})
	var seed: Variant = _city(_target).get("resource_seed", {})
	payload = _exact_payload(5)
	_expect(int((payload.get("resources", {}) as Dictionary).get("rice", -1)) == 777 and payload.get("resources") != seed, "3. a stock change shows, not the seed value (%s)" % str(payload.get("resources")))


# ---- 4, 5 ----

func _check_heroes() -> void:
	var ids := _hero_ids(5)
	_expect(ids.size() == 5, "4. five hero ids to place (%s)" % str(ids))
	if ids.size() < 5:
		return
	var states: Dictionary = _main.get("_hero_runtime_states")
	var plan := [[ids[0], "normal", _owner], [ids[1], "wounded", _owner], [ids[2], "captured", _owner], [ids[3], "dead", _owner], [ids[4], "normal", _player]]
	for row in plan:
		var hero_state: Dictionary = _main.call("_normalize_hero_runtime_state", row[0], {})
		hero_state["status"] = row[1]
		for key in ["wounded", "captured", "dead"]:
			hero_state[key] = row[1] == key
		for key in ["side", "nation", "faction_id", "force_id"]:
			hero_state[key] = row[2]
		hero_state["current_city_id"] = _target
		states[row[0]] = hero_state
	var city: Dictionary = _main.call("_get_mutable_city_runtime_state", _target)
	city["stationed_hero_ids"] = [ids[0], ids[1], ids[2], ids[3], ids[4], ids[0]]
	(_main.get("_city_runtime_states") as Dictionary)[_target] = city
	var payload := _exact_payload(5)
	var got := []
	for hero in payload.get("heroes", []):
		got.append([str(hero.get("hero_id", "")), str(hero.get("status", ""))])
	_expect(got == [[ids[0], "normal"], [ids[1], "wounded"]], "4. roster = same-faction normal + wounded, no captured / dead / foreign / duplicate (%s)" % str(got))

	city = _main.call("_get_mutable_city_runtime_state", _target)
	city["stationed_hero_ids"] = []
	(_main.get("_city_runtime_states") as Dictionary)[_target] = city
	payload = _exact_payload(5)
	_expect(payload.get("heroes") is Array and (payload.get("heroes") as Array).is_empty(), "5. no stationed hero -> heroes == [] (%s)" % str(payload.get("heroes")))
	var text := _panel_hint(payload, _service.call("_get_spy_info_visibility_level", 5).get("fields", []))
	_expect(text.contains("소속 장수 0명"), "5. panel says 0명 (%s)" % text.replace("\n", " | "))


# ---- 7, 8 ----

func _check_tiers() -> void:
	var tier1: Dictionary = _service.call("_get_spy_info_visibility_level", 1)
	var p1: Dictionary = _service.call("_build_spy_info_payload", _target, tier1.get("fields", []), bool(tier1.get("estimated", false)))
	_expect(p1.has("troops_estimated") and not p1.has("troops") and not p1.has("resources") and not p1.has("heroes") and not p1.has("unknown_fields") and not p1.has("observed_turn"), "7. aptitude 1: troops_estimated only (%s)" % str(p1.keys()))
	var tier2: Dictionary = _service.call("_get_spy_info_visibility_level", 2)
	var p2: Dictionary = _service.call("_build_spy_info_payload", _target, tier2.get("fields", []), bool(tier2.get("estimated", false)))
	_expect(tier2.get("fields") == ["troops"] and p2.has("troops") and not p2.has("resources") and not p2.has("heroes"), "8. aptitude 2: troops only (%s)" % str(tier2.get("fields")))
	var tier3: Dictionary = _service.call("_get_spy_info_visibility_level", 3)
	var p3: Dictionary = _service.call("_build_spy_info_payload", _target, tier3.get("fields", []), bool(tier3.get("estimated", false)))
	_expect(tier3.get("fields") == ["troops", "resources", "heroes"] and p3.has("troops") and p3.get("resources") is Dictionary and p3.get("heroes") is Array, "8. aptitude 3: troops, resources, heroes (%s)" % str(tier3.get("fields")))
	_expect(_service.call("_get_spy_info_visibility_level", 4).get("fields") == ["troops", "resources", "publicSupport", "loyalty", "heroes"] and _service.call("_get_spy_info_visibility_level", 5).get("fields") == ["troops", "resources", "publicSupport", "loyalty", "governor", "tech", "heroes"], "8. aptitude 4 and 5 add heroes at the end")


# ---- 6, 9 ----

func _check_record_turn_and_save() -> void:
	var state: Dictionary = _main.get("_player_state")
	state["city_intel"] = {}
	state["spy_cooldown"] = 0
	_set_stock(_target, {"rice": 40, "gold": 0})
	var turn := maxi(1, int(state.get("turn_number", 1)))
	_spy.call("validate_spy_action", "gather_info", _target)
	var result: Dictionary = _service.call("_gather_spy_info", _target, 1, 100)
	_expect(bool(result.get("success", false)) and (result.get("fields", []) as Array).has("resources"), "6. forced gather_info succeeds with resources (%s / %s)" % [str(result.get("reason", "")), str(result.get("fields"))])
	var entry: Dictionary = (state.get("city_intel", {}) as Dictionary).get(_target, {})
	var payload: Dictionary = entry.get("payload", {})
	_expect(int(payload.get("observed_turn", -1)) == turn and int(entry.get("turn", -1)) == turn, "6. observed_turn == spied turn %d (%s / %s)" % [turn, str(payload.get("observed_turn")), str(entry.get("turn"))])
	_expect((entry.get("fields", []) as Array).has("heroes") == (result.get("fields", []) as Array).has("heroes"), "9. the heroes field survives the intel normalization")
	state["turn_number"] = turn + 1
	var later: Dictionary = _spy.call("normalize_city_intel_registry", state.get("city_intel", {}))
	_expect(int((later.get(_target, {}) as Dictionary).get("turn", -1)) == turn, "6. next turn keeps the recorded turn %d" % turn)
	state["turn_number"] = turn

	var before: Dictionary = ((_main.get("_player_state") as Dictionary).get("city_intel", {}) as Dictionary).get(_target, {}).duplicate(true)
	var parsed: Variant = JSON.parse_string(JSON.stringify(_main.call("_serialize_worldmap_state")))
	_expect(parsed is Dictionary and bool(_main.call("_apply_worldmap_state", parsed)), "9. save -> load")
	var after: Dictionary = ((_main.get("_player_state") as Dictionary).get("city_intel", {}) as Dictionary).get(_target, {})
	_expect(_deep_equal(before, after), "9. city_intel[%s] equal after load (%s / %s)" % [_target, str(before), str(after)])


# ---- 12 (addendum 16:31) ----

# The record is the picture taken when spying, not a live window: changing the city's stock and roster, passing a turn
# and saving / loading keep the recorded stock, roster and observed_turn; only a new successful report replaces them.
func _check_snapshot_stays() -> void:
	var all_ids := _hero_ids(5)
	var ids: Array[String] = [all_ids[0]]
	var elsewhere := _other_city()
	for hero_id in all_ids.slice(1):
		_main.call("_apply_battle_settlement_move_hero", hero_id, elsewhere)
	_main.call("_apply_battle_settlement_move_hero", ids[0], _target)
	var state: Dictionary = _main.get("_player_state")
	state["city_intel"] = {}
	state["spy_cooldown"] = 0
	_set_stock(_target, {"rice": 40, "gold": 0})
	var turn := maxi(1, int(state.get("turn_number", 1)))
	_spy.call("validate_spy_action", "gather_info", _target)
	var first: Dictionary = _service.call("_gather_spy_info", _target, 1, 100)
	var recorded := _recorded_payload()
	_expect(bool(first.get("success", false)) and int((recorded.get("resources", {}) as Dictionary).get("rice", -1)) == 40 and _roster_ids(recorded) == ids, "12. first report records rice 40 and roster %s (%s)" % [str(ids), str(_roster_ids(recorded))])

	_set_stock(_target, {"rice": 90, "gold": 0})
	_main.call("_apply_battle_settlement_move_hero", ids[0], elsewhere)   # the one hero moves away
	(_main.get("_player_state") as Dictionary)["turn_number"] = turn + 1
	var parsed: Variant = JSON.parse_string(JSON.stringify(_main.call("_serialize_worldmap_state")))
	_expect(parsed is Dictionary and bool(_main.call("_apply_worldmap_state", parsed)), "12. save -> load after the change")
	recorded = _recorded_payload()
	_expect(int((recorded.get("resources", {}) as Dictionary).get("rice", -1)) == 40 and _roster_ids(recorded) == ids and int(recorded.get("observed_turn", -1)) == turn, "12. after stock 40->90, hero moved, turn +1, save/load: record keeps rice 40, roster %s, turn %d (%s)" % [str(ids), turn, str(recorded)])
	var hint := _panel_hint(recorded, ((_main.get("_player_state") as Dictionary).get("city_intel", {}) as Dictionary).get(_target, {}).get("fields", []))
	_expect(hint.contains("쌀 40") and not hint.contains("쌀 90") and not hint.contains("소속 장수 0명"), "12. the panel shows the record, not the live city (%s)" % hint.replace("\n", " | "))

	state = _main.get("_player_state")
	state["spy_cooldown"] = 0
	_spy.call("validate_spy_action", "gather_info", _target)
	var second: Dictionary = _service.call("_gather_spy_info", _target, 1, 100)
	recorded = _recorded_payload()
	_expect(bool(second.get("success", false)) and int((recorded.get("resources", {}) as Dictionary).get("rice", -1)) == 90 and _roster_ids(recorded).is_empty() and int(recorded.get("observed_turn", -1)) == turn + 1, "12. a new report replaces it: rice 90, roster [], turn %d (%s)" % [turn + 1, str(recorded)])
	(_main.get("_player_state") as Dictionary)["turn_number"] = turn


# ---- 13 (addendum 2, 16:45) ----

# Four cases: base 1 = troops_estimated; bonus 1 = troops_estimated + resources (the old seed value, NOT the real
# stock); bonus 2 = troops + resources (real); base 3 = troops + resources (real) + heroes. Seed rice 500, real rice 40.
func _check_bonus_ladder() -> void:
	# A city whose intel resistance does not cancel the tech bonus (net bonus >= 0.05 is what adds a field). Setup like
	# the spy controller test: security / public order 50 -> resistance 0.02.
	var guarded: Dictionary = _main.call("_get_mutable_city_runtime_state", _target)
	guarded["security"] = 50
	guarded["public_order"] = 50
	(_main.get("_city_runtime_states") as Dictionary)[_target] = guarded
	(_main.get("_player_state") as Dictionary)["spy_cooldown"] = 0
	var target := _low_resistance_target()
	_expect(not target.is_empty(), "13. a spy target with intel resistance <= 0.03 exists (%s: security %s, baseline %s)" % [_target, str(_spy.call("get_city_security_score", _target)), str(_main.call("_get_enemy_city_intel_resistance_baseline_mvp", _city(_target)))])
	if target.is_empty():
		return
	var city: Dictionary = _main.call("_get_mutable_city_runtime_state", target)
	city["resource_seed"] = {"rice": 500, "barley": 500, "seafood": 500, "salt": 500}
	(_main.get("_city_runtime_states") as Dictionary)[target] = city
	_set_stock(target, {"rice": 40, "gold": 0})
	_spy.call("validate_spy_action", "gather_info", target)
	var state: Dictionary = _main.get("_player_state")
	var completed_before: Variant = (state.get("national_domestic_tech_completed", {}) as Dictionary).duplicate(true)
	var all_national := {}
	for tech_id in (_main.call("_ensure_domestic_tech_catalog").get_national_definitions() as Dictionary).keys():
		all_national[str(tech_id)] = true
	state["national_domestic_tech_completed"] = all_national
	var modifier: Dictionary = _spy.call("get_player_spy_tech_modifier", target)
	var bonus1: Dictionary = _service.call("_get_modified_spy_visibility_level_mvp", target, 1)
	var bonus2: Dictionary = _service.call("_get_modified_spy_visibility_level_mvp", target, 2)
	state["national_domestic_tech_completed"] = completed_before
	var base1: Dictionary = _service.call("_get_modified_spy_visibility_level_mvp", target, 1)
	var base3: Dictionary = _service.call("_get_spy_info_visibility_level", 3)
	_expect(base1.get("fields") == ["troops_estimated"] and bool(base1.get("estimated", false)), "13. base 1 (no tech): troops_estimated, estimated (%s)" % str(base1))
	_expect(bonus1.get("fields") == ["troops_estimated", "resources"] and bool(bonus1.get("estimated", false)), "13. bonus 1 (all national techs, intel_visibility_pct %s): troops_estimated + resources, still estimated (%s)" % [str(modifier.get("intel_visibility_pct")), str(bonus1)])
	_expect(bonus2.get("fields") == ["troops", "resources"] and not bool(bonus2.get("estimated", true)), "13. bonus 2: troops + resources, exact (%s)" % str(bonus2))
	_expect(base3.get("fields") == ["troops", "resources", "heroes"], "13. base 3: troops + resources + heroes (%s)" % str(base3))
	var p_base1: Dictionary = _service.call("_build_spy_info_payload", target, ["troops_estimated"], true)
	var p_bonus1: Dictionary = _service.call("_build_spy_info_payload", target, ["troops_estimated", "resources"], true)
	var p_bonus2: Dictionary = _service.call("_build_spy_info_payload", target, ["troops", "resources"], false)
	var p_base3: Dictionary = _service.call("_build_spy_info_payload", target, ["troops", "resources", "heroes"], false)
	_expect(not p_base1.has("resources"), "13. base 1 payload has no resources")
	_expect(p_bonus1.get("resources") == city.get("resource_seed") and not p_bonus1.has("unknown_fields") and not p_bonus1.has("observed_turn"), "13. bonus 1 payload keeps the old value (seed rice 500), not the real stock (%s)" % str(p_bonus1.get("resources")))
	_expect(int((p_bonus2.get("resources", {}) as Dictionary).get("rice", -1)) == 40 and not p_bonus2.has("heroes"), "13. bonus 2 payload: real rice 40, no heroes (%s)" % str(p_bonus2.get("resources")))
	_expect(int((p_base3.get("resources", {}) as Dictionary).get("rice", -1)) == 40 and p_base3.get("heroes") is Array, "13. base 3 payload: real rice 40 + heroes")


func _low_resistance_target() -> String:
	var ids: Array = (_main.get("_city_markers_by_id") as Dictionary).keys()
	ids.sort()
	for city_id in ids:
		if not bool(_spy.call("validate_spy_action", "gather_info", str(city_id)).get("ok", false)):
			continue
		var baseline: Dictionary = _main.call("_get_enemy_city_intel_resistance_baseline_mvp", _city(str(city_id)))
		if bool(baseline.get("masked", true)) or float(baseline.get("intel_visibility_resistance_pct", 0.0)) <= 0.03:
			return str(city_id)
	return ""


# ---- 14, 15 (addendum 2) ----

# 14: heroes survive save -> load in city_intel and in the panel. 15: after the city changes owner, the record keeps
# owner_faction_id and the roster from the observation, and the panel names the owner at observation time.
func _check_owner_at_observation() -> void:
	var ids := _hero_ids(1)
	_main.call("_apply_battle_settlement_move_hero", ids[0], _target)
	var state: Dictionary = _main.get("_player_state")
	state["city_intel"] = {}
	state["spy_cooldown"] = 0
	_spy.call("validate_spy_action", "gather_info", _target)
	var result: Dictionary = _service.call("_gather_spy_info", _target, 1, 100)
	var parsed: Variant = JSON.parse_string(JSON.stringify(_main.call("_serialize_worldmap_state")))
	_expect(bool(result.get("success", false)) and parsed is Dictionary and bool(_main.call("_apply_worldmap_state", parsed)), "14. spy then save -> load")
	var entry: Dictionary = ((_main.get("_player_state") as Dictionary).get("city_intel", {}) as Dictionary).get(_target, {})
	var payload: Dictionary = entry.get("payload", {})
	var hint := _panel_hint(payload, entry.get("fields", []))
	_expect((entry.get("fields", []) as Array).has("heroes") and _roster_ids(payload) == ids and hint.contains("소속 장수 1명"), "14. heroes kept in city_intel and the panel after load (%s)" % hint.replace("\n", " | "))
	_expect(str(payload.get("owner_faction_id", "")) == _owner, "15. record owner_faction_id = owner at observation %s (%s)" % [_owner, str(payload.get("owner_faction_id"))])

	var new_owner := _player if _owner != _player else "silla"
	var city: Dictionary = _main.call("_get_mutable_city_runtime_state", _target)
	for key in ["owner", "nation", "owner_faction_id", "faction"]:
		city[key] = new_owner
	(_main.get("_city_runtime_states") as Dictionary)[_target] = city
	_main.call("_rebuild_occupation_runtime_indexes_mvp")
	entry = ((_main.get("_player_state") as Dictionary).get("city_intel", {}) as Dictionary).get(_target, {})
	payload = entry.get("payload", {})
	hint = _panel_hint(payload, entry.get("fields", []))
	var observed_label := str(PanelBase.FACTION_LABELS.get(_owner, _owner))
	_expect(str(payload.get("owner_faction_id", "")) == _owner and _roster_ids(payload) == ids, "15. after the owner change the record keeps owner %s and the roster (%s)" % [_owner, str(payload.get("owner_faction_id"))])
	_expect(hint.contains("관측 당시 %s 소속" % observed_label), "15. the panel names the owner at observation (%s)" % hint.replace("\n", " | "))
	for key in ["owner", "nation", "owner_faction_id", "faction"]:
		city[key] = _owner
	(_main.get("_city_runtime_states") as Dictionary)[_target] = city
	_main.call("_rebuild_occupation_runtime_indexes_mvp")

	# Addendum 16:55: an old record without owner_faction_id is not back-filled with the current owner, and it shows
	# as before (no ownership text).
	var legacy_entry := {"turn": 3, "fields": ["troops", "resources"], "estimated": false, "payload": {"city_id": _target, "troops": 1200, "resources": {"rice": 500, "salt": 20}}}
	var legacy_hint_before := _panel_hint(legacy_entry.payload, legacy_entry.fields)
	(_main.get("_player_state") as Dictionary)["city_intel"] = {_target: legacy_entry.duplicate(true)}
	parsed = JSON.parse_string(JSON.stringify(_main.call("_serialize_worldmap_state")))
	_expect(parsed is Dictionary and bool(_main.call("_apply_worldmap_state", parsed)), "15. old record saved and loaded")
	entry = ((_main.get("_player_state") as Dictionary).get("city_intel", {}) as Dictionary).get(_target, {})
	payload = entry.get("payload", {})
	var legacy_hint_after := _panel_hint(payload, entry.get("fields", []))
	_expect(not payload.has("owner_faction_id") and legacy_hint_after == legacy_hint_before and not legacy_hint_after.contains("관측 당시"), "15. old record: no owner_faction_id added, display as before (%s)" % legacy_hint_after.replace("\n", " | "))


func _recorded_payload() -> Dictionary:
	var entry: Variant = ((_main.get("_player_state") as Dictionary).get("city_intel", {}) as Dictionary).get(_target, {})
	return ((entry as Dictionary).get("payload", {}) as Dictionary).duplicate(true) if entry is Dictionary else {}


func _roster_ids(payload: Dictionary) -> Array[String]:
	var result: Array[String] = []
	for hero in payload.get("heroes", []):
		if hero is Dictionary:
			result.append(str(hero.get("hero_id", "")))
	return result


func _other_city() -> String:
	var ids: Array = (_main.get_script().get_script_constant_map()["CITY_HUD_DATA"] as Dictionary).keys()
	ids.sort()
	for city_id in ids:
		if str(city_id) != _target:
			return str(city_id)
	return ""


# ---- 11 ----

func _check_failure_keeps_intel() -> void:
	var state: Dictionary = _main.get("_player_state")
	state["spy_cooldown"] = 0
	var before: Dictionary = (state.get("city_intel", {}) as Dictionary).duplicate(true)
	_spy.call("validate_spy_action", "gather_info", _target)
	var result: Dictionary = _service.call("_gather_spy_info", _target, 100, 100)
	_expect(not bool(result.get("success", true)), "11. forced roll 100 fails (chance %s)" % str(result.get("success_chance")))
	_expect(_deep_equal((_main.get("_player_state") as Dictionary).get("city_intel", {}), before), "11. a failed report leaves city_intel unchanged")


# ---- 10 ----

func _check_p0_cost() -> void:
	var state: Dictionary = _main.get("_player_state")
	state["spy_cooldown"] = 0
	state["chancellor_id"] = "jeong_do_jeon"
	var payment_cities: Array = _main.call("_get_national_payment_city_ids_mvp")
	for index in payment_cities.size():
		_main.call("_set_city_storage", str(payment_cities[index]), {"gold": 5000, "silk": 500, "rice": 100} if index == 0 else {})
	var action := "public_support_disrupt"
	var cost: Dictionary = _spy.call("validate_spy_action", action, _target).get("cost", {})
	var gold_before := int((_main.call("_get_player_national_resource_stock_mvp") as Dictionary).get("gold", 0))
	var done: Dictionary = _spy.call("execute", action, _target)
	var national: Dictionary = _main.call("_get_player_national_resource_stock_mvp")
	var city_gold := 0
	for city_id in payment_cities:
		city_gold += int((_main.call("_get_city_storage", str(city_id)) as Dictionary).get("gold", 0))
	_expect(str(done.get("reason", "")) != "resources" and gold_before - int(national.get("gold", 0)) == int(cost.get("gold", 0)), "10. %s cost (gold %s) paid out of the cities (%d -> %d, %s)" % [action, str(cost.get("gold")), gold_before, int(national.get("gold", 0)), str(done.get("reason", ""))])
	_expect(int(national.get("gold", 0)) == city_gold and int(((state.get("resource_stock", {}) as Dictionary).get("gold", -1))) == city_gold, "10. national gold = city sum = cache (%d)" % city_gold)


# ---- helpers ----

func _exact_payload(aptitude: int) -> Dictionary:
	var visibility: Dictionary = _service.call("_get_spy_info_visibility_level", aptitude)
	_spy.call("validate_spy_action", "gather_info", _target)
	return _service.call("_build_spy_info_payload", _target, visibility.get("fields", []), bool(visibility.get("estimated", false)))


func _panel_hint(payload: Dictionary, raw_fields: Array) -> String:
	var panel = PanelBase.new()
	var fields: Array[String] = []
	for field in raw_fields:
		fields.append(str(field))
	var text := str(panel.call("_format_enemy_intel_hint", {"turn": 1}, fields, payload))
	panel.free()
	return text


func _set_stock(city_id: String, stock: Dictionary) -> void:
	_main.call("_set_city_storage", city_id, stock)


func _city(city_id: String) -> Dictionary:
	return _main.call("_get_city_hud_entry", city_id)


func _find_spy_target() -> String:
	var ids: Array = (_main.get("_city_markers_by_id") as Dictionary).keys()
	ids.sort()
	for city_id in ids:
		if bool(_spy.call("validate_spy_action", "gather_info", str(city_id)).get("ok", false)):
			return str(city_id)
	return ""


func _hero_ids(count: int) -> Array[String]:
	var result: Array[String] = []
	var heroes: Dictionary = _main.call("_get_hero_data_for_ui")
	var ids := heroes.keys()
	ids.sort()
	for hero_id in ids:
		if result.size() >= count:
			break
		result.append(str(hero_id))
	return result


func _deep_equal(a: Variant, b: Variant) -> bool:
	return JSON.stringify(_canonical(a), "", true) == JSON.stringify(_canonical(b), "", true)


func _canonical(value: Variant) -> Variant:
	# JSON keeps numbers as floats; compare by value, not by int/float type.
	if value is Dictionary:
		var out := {}
		for key in (value as Dictionary):
			out[str(key)] = _canonical((value as Dictionary)[key])
		return out
	if value is Array:
		var items := []
		for item in value:
			items.append(_canonical(item))
		return items
	if value is int or value is float:
		return float(value)
	return value


func _expect(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(message)
		push_error("[SPY_INTEL_P3] FAIL: %s" % message)


func _finish() -> void:
	print("[SPY_INTEL_P3] checks=%d failures=%s" % [_checks, str(_failures)])
	quit(0 if _failures.is_empty() else 1)
