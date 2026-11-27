extends SceneTree

# Queue 36 STOCK-AUTHORITY-P0 (+ reply 1): one city ledger. Each city's resource_stock is the only stock; the national
# stock is the sum of the owned cities and is never stored or changed on its own. Runs on the real WorldMap.tscn from a
# new game (player / hanseong) plus one neighbouring city handed to the player.
#  1. two owned cities, rice 40 + 60 -> national 100 (live sum and both national caches)
#  2. internal transfer 10 -> 30 / 70, national still 100
#  3. chancellor auto-trade and a manual external trade: national = city sum, the trade gold shows in the national sum
#  4. resources gained from production let a city tech start; the cost comes out of that city's resource_stock
#  5. a national tech cost comes out of the cities and stays out after re-aggregation
#  6. save -> load: city and national values equal, nothing applied twice
#  7. old-format save (storage differs from resource_stock): only resource_stock survives, saving/loading again keeps it
#  8. a city changing owner changes what the national sum covers
#  9. cheat Ctrl+Shift+G: national = city sum (capacity x owned cities), the warehouse rows show it (not 0 / capacity)
# 10. a saved game has no storage key
# 11. old save: a city with resource_stock 0 and value only in storage stays 0 after loading
# 12. a multi-item cost with one item short is refused with no item taken (diplomacy, spy, recruitment, national tech)
# 13. a national cost (diplomacy, spy, recruitment) lowers the city sum by exactly the cost and does not come back

const WORLDMAP_SCENE_PATH := "res://WorldMap.tscn"
const CONTROLLER_NODE := "WorldMapDebugCheatsController"
const DiplomacyService := preload("res://scripts/worldmap/actions/diplomacy_action_service.gd")
const OWN_CITY := "hanseong"
const FOOD := ["rice", "barley", "seafood"]

var _checks := 0
var _failures: Array[String] = []
var _main: Node
var _second := ""
var _player := ""


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.size = Vector2i(1920, 1080)
	_expect(bool(root.get_node("/root/GameSession").call("request_new_game", "player")), "new game requested (player / hanseong)")
	_expect(change_scene_to_file(WORLDMAP_SCENE_PATH) == OK, "WorldMap scene transition starts")
	for i in 6:
		await process_frame
	_main = current_scene
	_expect(_main != null and _main.scene_file_path == WORLDMAP_SCENE_PATH, "WorldMap scene loaded")
	if _main == null:
		_finish()
		return
	_player = str(_main.call("_get_current_player_faction_id"))
	var marker = (_main.get("_city_markers_by_id") as Dictionary).get(OWN_CITY)
	_second = str(marker.neighbors[0]) if marker != null and not marker.neighbors.is_empty() else ""
	_expect(not _second.is_empty(), "hanseong has a neighbour to hand to the player (%s)" % _second)
	if _second.is_empty():
		_finish()
		return
	_set_owner(_second, _player)
	_expect(_payment_cities() == [OWN_CITY, _second], "the player owns exactly %s and %s, capital first (%s)" % [OWN_CITY, _second, str(_payment_cities())])

	_check_sum_and_transfer()
	_check_trade()
	_check_city_research_from_production()
	_check_national_research()
	_check_save_load()
	_check_legacy_save()
	_check_national_costs()
	_check_refused_costs()
	_check_ownership_change()
	_check_cheat()
	_finish()


# ---- 1, 2 ----

func _check_sum_and_transfer() -> void:
	_seed({OWN_CITY: {"rice": 40}, _second: {"rice": 60}})
	_expect(int(_national().get("rice", -1)) == 100, "1. rice 40 + 60 -> national 100 (%s)" % str(_national().get("rice")))
	_expect_caches("1.")
	var amounts := {"rice": 10}
	var validation: Dictionary = _main.call("_validate_internal_trade_transfer", OWN_CITY, _second, amounts)
	_expect(bool(validation.get("ok", false)), "2. internal transfer validates (%s)" % str(validation.get("reason", "")))
	_main.call("_apply_internal_trade_transfer", OWN_CITY, _second, amounts)
	_expect(_amount(OWN_CITY, "rice") == 30 and _amount(_second, "rice") == 70, "2. transfer 10 -> %d / %d" % [_amount(OWN_CITY, "rice"), _amount(_second, "rice")])
	_expect(int(_national().get("rice", -1)) == 100, "2. national rice still 100 (%s)" % str(_national().get("rice")))
	_expect_caches("2.")


# ---- 3 ----

func _check_trade() -> void:
	var state: Dictionary = _main.get("_player_state")
	if str(state.get("chancellor_id", "")).is_empty():
		var candidates: Array[String] = _main.call("_get_player_chancellor_candidate_hero_ids")
		if not candidates.is_empty():
			state["chancellor_id"] = candidates[0]
	_expect(not str(state.get("chancellor_id", "")).is_empty(), "3. a chancellor is appointed")
	state["last_chancellor_auto_trade_turn"] = 0
	state["chancellor_policy_id"] = "balanced"
	var trade_modes_before: Variant = _main.get("_trade_control_modes")
	_main.set("_trade_control_modes", {"internal_trade": "chancellor", "external_trade": "manual"})
	_seed({OWN_CITY: {"gold": 500, "rice": 400, "barley": 300, "seafood": 200, "wood": 200, "iron": 200, "horses": 200, "silk": 200, "salt": 200}, _second: {}})
	var auto: Dictionary = _main.call("_apply_chancellor_auto_trade_for_world_turn", 902)
	_expect(bool(auto.get("ok", false)) and not (auto.get("internal", {}).get("applied", []) as Array).is_empty(), "3. chancellor auto-trade moved stock (%s)" % str(auto.get("reason", "")))
	_expect_sum_is_cities("3. after chancellor auto-trade")
	_main.set("_trade_control_modes", trade_modes_before)

	var target := ""
	for city_id in _main.get("_city_markers_by_id"):
		if str(_main.call("_find_contextual_trade_source_city_id", str(city_id))) == OWN_CITY:
			target = str(city_id)
			break
	_expect(not target.is_empty(), "3. a foreign trade partner of %s exists" % OWN_CITY)
	if target.is_empty():
		return
	var target_faction := str(_main.call("_get_city_owner_faction_id_for_trade_display", target))
	var relation: Dictionary = _main.call("_ensure_faction_relation_entry", _player, target_faction)
	relation["status"] = "neutral"
	relation["score"] = 50
	_seed({OWN_CITY: {"gold": 1000, "rice": 100, "salt": 100}, _second: {"gold": 5}})
	var order := {"source_city_id": OWN_CITY, "target_city_id": target, "trade_type": "external", "mode": "manual", "orders": {"rice": {"action": "export", "amount": 10}}}
	order["preview"] = _main.call("_ensure_trade_controller").call("build_external_manual_trade_execution_preview", order)
	order["efficiency"] = _main.call("_get_trade_efficiency_for_cities", OWN_CITY, target)
	var gold_before := int(_national().get("gold", 0))
	var result: Dictionary = _main.call("_execute_external_manual_trade_order", order)
	var gained := int((result.get("applied", {}) as Dictionary).get("gold", 0))
	_expect(bool(result.get("ok", false)) and gained > 0, "3. manual export earns gold (%s, +%d)" % [str(result.get("reason", "")), gained])
	_expect(int(_national().get("gold", 0)) == gold_before + gained, "3. the trade gold shows in the national sum (%d -> %d, +%d)" % [gold_before, int(_national().get("gold", 0)), gained])
	_expect_sum_is_cities("3. after manual trade")


# ---- 4 ----

func _check_city_research_from_production() -> void:
	var service = _main.call("_ensure_domestic_tech_research_service")
	_seed({OWN_CITY: {}, _second: {}})
	var tech := _find_cost_tech("city", OWN_CITY)
	_expect(not tech.is_empty(), "4. a city tech fails on cost with an empty city (%s)" % tech)
	if tech.is_empty():
		return
	var costs: Dictionary = service.build_actual_charge_plan(tech, "city", OWN_CITY).get("implemented_costs", {})
	var state: Dictionary = _main.get("_player_state")
	var tax := int(_main.call("_normalize_tax_level", state.get("tax_level", 30)))
	var policy := str(_main.call("_normalize_chancellor_policy_id", str(state.get("chancellor_policy_id", "balanced"))))
	var effects: Dictionary = _main.call("_calculate_active_chancellor_national_effects")
	var turns := 0
	while turns < 60 and not bool(service.validate_start(tech, OWN_CITY).get("ok", false)):
		turns += 1
		_main.call("_apply_player_city_production_for_world_turn_mvp", 500 + turns, tax, policy, effects, {})
	_expect(bool(service.validate_start(tech, OWN_CITY).get("ok", false)), "4. production income lets %s start after %d turns (%s)" % [tech, turns, str(service.validate_start(tech, OWN_CITY).get("reason", ""))])
	var city_before := _stock(OWN_CITY)
	var second_before := _stock(_second)
	var national_before := _national()
	var started: Dictionary = service.start_research(tech, OWN_CITY)
	_expect(bool(started.get("ok", false)), "4. city research %s starts (%s)" % [tech, str(started.get("reason", ""))])
	var gold_cost := int(costs.get("gold", 0))
	var food_cost := int(costs.get("food_group", 0))
	_expect(int(city_before.gold) - _amount(OWN_CITY, "gold") == gold_cost and _food(city_before) - _food(_stock(OWN_CITY)) == food_cost, "4. the cost (gold %d, food %d) comes out of %s resource_stock" % [gold_cost, food_cost, OWN_CITY])
	_expect(_stock(_second) == second_before, "4. the other city is untouched")
	_expect(int(national_before.get("gold", 0)) - int(_national().get("gold", 0)) == gold_cost, "4. the national sum shows the city charge")
	_expect_caches("4.")


# ---- 5 ----

func _check_national_research() -> void:
	var service = _main.call("_ensure_domestic_tech_research_service")
	(_main.get("_player_state") as Dictionary)["national_tech_research"] = {"active": {}}
	_seed({OWN_CITY: {}, _second: {}})
	var tech := _find_cost_tech("national", "")
	_expect(not tech.is_empty(), "5. a national tech fails on cost with empty cities (%s)" % tech)
	if tech.is_empty():
		return
	var costs: Dictionary = service.build_actual_charge_plan(tech, "national", "").get("implemented_costs", {})
	_seed({OWN_CITY: {"gold": 5000, "rice": 2000, "barley": 2000, "seafood": 2000}, _second: {"gold": 300, "rice": 300}})
	var national_before := _national()
	var capital_before := _stock(OWN_CITY)
	var started: Dictionary = service.start_research(tech)
	_expect(bool(started.get("ok", false)), "5. national research %s starts (%s)" % [tech, str(started.get("reason", ""))])
	var gold_cost := int(costs.get("gold", 0))
	var food_cost := int(costs.get("food_group", 0))
	_expect(int(capital_before.gold) - _amount(OWN_CITY, "gold") == gold_cost and _food(capital_before) - _food(_stock(OWN_CITY)) == food_cost, "5. the national cost (gold %d, food %d) comes out of the capital" % [gold_cost, food_cost])
	_main.call("_rebuild_occupation_runtime_indexes_mvp")
	_main.call("_sync_player_resource_compatibility_from_city_stock_mvp")
	_expect(int(national_before.get("gold", 0)) - int(_national().get("gold", 0)) == gold_cost and _food(national_before) - _food(_national()) == food_cost, "5. still paid after re-aggregation (gold %d -> %d)" % [int(national_before.get("gold", 0)), int(_national().get("gold", 0))])
	_expect_caches("5.")


# ---- 6, 10 ----

func _check_save_load() -> void:
	_seed({OWN_CITY: {"gold": 321, "rice": 45, "salt": 7}, _second: {"gold": 12, "silk": 3}})
	var cities_before := {OWN_CITY: _stock(OWN_CITY), _second: _stock(_second)}
	var national_before := _national()
	var saved := _round_trip(_main.call("_serialize_worldmap_state"))
	_expect(str(saved.get("stock_ledger", "")) == "resource_stock_v1", "6. the save carries stock_ledger resource_stock_v1")
	_expect(not _has_storage_key(saved), "10. the save has no storage key")
	_expect(bool(_main.call("_apply_worldmap_state", saved)), "6. the save loads")
	_expect(_stock(OWN_CITY) == cities_before[OWN_CITY] and _stock(_second) == cities_before[_second], "6. city stock equal after load (%s / %s)" % [str(_stock(OWN_CITY)), str(_stock(_second))])
	_expect(_same_amounts(_national(), national_before), "6. national stock equal after load, no double count (%s)" % str(_national()))
	_expect_caches("6.")


# ---- 7, 11 ----

func _check_legacy_save() -> void:
	_seed({OWN_CITY: {"gold": 400, "rice": 50}, _second: {}})
	var legacy := _round_trip(_main.call("_serialize_worldmap_state"))
	legacy.erase("stock_ledger")
	var city_states: Dictionary = legacy.get("worldmap_city_state", {})
	(city_states[OWN_CITY] as Dictionary)["storage"] = {"gold": 7777, "rice": 9, "silk": 55}
	(city_states[_second] as Dictionary)["resource_stock"] = {"gold": 0, "rice": 0, "barley": 0, "seafood": 0, "salt": 0}
	(city_states[_second] as Dictionary)["storage"] = {"gold": 500, "rice": 500}
	_expect(bool(_main.call("_apply_worldmap_state", legacy)), "7. the old-format save loads")
	_expect(_amount(OWN_CITY, "gold") == 400 and _amount(OWN_CITY, "rice") == 50 and _amount(OWN_CITY, "silk") == 0, "7. only resource_stock survives, storage is dropped, not added (%s)" % str(_stock(OWN_CITY)))
	_expect(_amount(_second, "gold") == 0 and _amount(_second, "rice") == 0, "11. resource_stock 0 + storage only -> still 0 (%s)" % str(_stock(_second)))
	_expect(not _city(OWN_CITY).has("storage") and not _city(_second).has("storage"), "7. no storage ledger at run time")
	var again := _round_trip(_main.call("_serialize_worldmap_state"))
	_expect(str(again.get("stock_ledger", "")) == "resource_stock_v1" and not _has_storage_key(again), "7. saving again writes the marker and no storage")
	_expect(bool(_main.call("_apply_worldmap_state", again)), "7. the re-saved game loads")
	_expect(_amount(OWN_CITY, "gold") == 400 and _amount(OWN_CITY, "rice") == 50 and _amount(_second, "gold") == 0, "7. values unchanged after a second save/load")


# ---- 13 ----

func _check_national_costs() -> void:
	# Recruitment: {gold 100, food 50}.
	_seed({OWN_CITY: {"gold": 1000, "rice": 1000}, _second: {"gold": 50}})
	_main.call("_set_city_loyalty_value", OWN_CITY, 90)
	var cost: Dictionary = _main.call("_calculate_recruitment_cost", 100)
	var before := _national()
	_expect(bool(_main.call("_recruit_troops", OWN_CITY, 100)), "13. recruitment of 100 succeeds")
	_expect_charge("13. recruitment", before, int(cost.get("gold", 0)), int(cost.get("food", 0)))

	# Diplomacy: envoy.
	var enemy := _find_enemy_city()
	_expect(not enemy.is_empty(), "13. an enemy city exists (%s)" % enemy)
	if not enemy.is_empty():
		_prepare_relation(enemy, 60)
		_seed({OWN_CITY: {"gold": 1000, "silk": 100, "rice": 100}, _second: {"gold": 40}})
		var envoy_cost: Dictionary = DiplomacyService.get_action_definition("envoy").get("cost", {})
		before = _national()
		var envoy: Dictionary = _main.call("_ensure_diplomacy_controller").execute("envoy", enemy)
		_expect(not envoy.get("payment", {}).is_empty(), "13. envoy is paid (%s)" % str(envoy.get("reason", "")))
		_expect_charge("13. diplomacy envoy", before, int(envoy_cost.get("gold", 0)), 0)

	# Spy: gather_info.
	var spy = _main.call("_ensure_spy_controller")
	_prepare_spy()
	_seed({OWN_CITY: {"gold": 2000, "silk": 500, "rice": 100}, _second: {"gold": 40}})
	var spy_target := _valid_spy_target(spy, "gather_info")
	_expect(not spy_target.is_empty(), "13. a gather_info target exists (%s)" % _spy_reasons(spy, "gather_info"))
	if not spy_target.is_empty():
		var spy_cost: Dictionary = spy.call("validate_spy_action", "gather_info", spy_target).get("cost", {})
		before = _national()
		var spied: Dictionary = spy.call("execute", "gather_info", spy_target)
		_expect(str(spied.get("reason", "")) != "resources", "13. gather_info is not refused on cost (%s)" % str(spied.get("reason", "")))
		_expect_charge("13. spy gather_info", before, int(spy_cost.get("gold", 0)), 0)


# ---- 12 ----

func _check_refused_costs() -> void:
	var direct_before := _city_snapshot()
	var direct: Dictionary = _main.call("_apply_generic_resource_cost", {"gold": 10, "silk": 999999})
	_expect(_city_snapshot() == direct_before and int((direct.get("paid", {}) as Dictionary).get("gold", -1)) == 0, "12. generic cost with silk short takes nothing (%s)" % str(direct.get("paid", {})))

	# Reply 1 §4: city stock, national sum and result message are all as before the attempt (the message the
	# pre-check gives is the message the refused attempt returns).
	var enemy := _find_enemy_city()
	if not enemy.is_empty():
		_prepare_relation(enemy, 80)
		_seed({OWN_CITY: {"gold": 10000, "rice": 100}, _second: {}})
		var snap := _refusal_snapshot()
		var check: Dictionary = _main.call("_ensure_diplomacy_controller")._validate_diplomacy_action("alliance_proposal", enemy)
		var refused: Dictionary = _main.call("_ensure_diplomacy_controller").execute("alliance_proposal", enemy)
		_expect_refused("12. diplomacy alliance (gold ok, silk 0)", "resources", check, refused, snap)

	var spy = _main.call("_ensure_spy_controller")
	_prepare_spy()
	_seed({OWN_CITY: {"gold": 10000, "silk": 1000, "rice": 100}, _second: {}})
	var wedge_target := _valid_spy_target(spy, "wedge")
	_expect(not wedge_target.is_empty(), "12. a wedge target exists (%s)" % _spy_reasons(spy, "wedge"))
	if not wedge_target.is_empty():
		_seed({OWN_CITY: {"gold": 10000, "rice": 100}, _second: {}})
		var snap := _refusal_snapshot()
		var check: Dictionary = spy.call("validate_spy_action", "wedge", wedge_target)
		var wedge: Dictionary = spy.call("execute", "wedge", wedge_target)
		_expect_refused("12. spy wedge (gold ok, silk 0)", "resources", check, wedge, snap)

	_seed({OWN_CITY: {"gold": 1000}, _second: {}})
	_main.call("_set_city_loyalty_value", OWN_CITY, 90)
	var recruit_snap := _refusal_snapshot()
	var recruit_check: Dictionary = _main.call("_can_recruit_troops", OWN_CITY, 100)
	var recruited: bool = _main.call("_recruit_troops", OWN_CITY, 100)
	var recruit_after: Dictionary = _main.call("_can_recruit_troops", OWN_CITY, 100)
	_expect(not recruited, "12. recruitment (gold ok, food 0) refused")
	_expect_refused("12. recruitment (gold ok, food 0)", "", recruit_check, recruit_after, recruit_snap)

	var service = _main.call("_ensure_domestic_tech_research_service")
	(_main.get("_player_state") as Dictionary)["national_tech_research"] = {"active": {}}
	_seed({OWN_CITY: {}, _second: {}})
	var tech := _find_cost_tech("national", "")
	if not tech.is_empty():
		# Every national tech in the catalog costs gold only, so the national case is gold short by 1 (food plenty).
		var tech_gold := int(service.build_actual_charge_plan(tech, "national", "").get("implemented_costs", {}).get("gold", 0))
		_seed({OWN_CITY: {"gold": tech_gold - 1, "rice": 5000, "barley": 5000, "seafood": 5000}, _second: {}})
		var tech_snap := _refusal_snapshot()
		var tech_check: Dictionary = service.validate_start(tech)
		var started: Dictionary = service.start_research(tech)
		_expect_refused("12. national tech %s (gold short by 1)" % tech, "insufficient_cost", tech_check, started, tech_snap)


# ---- 8 ----

func _check_ownership_change() -> void:
	_seed({OWN_CITY: {"gold": 70}, _second: {"gold": 30}})
	_expect(int(_national().get("gold", 0)) == 100, "8. two cities -> national gold 100")
	var enemy_faction := str(_main.call("_get_city_owner_faction_id_for_trade_display", _find_enemy_city()))
	_set_owner(_second, enemy_faction)
	_expect(int(_national().get("gold", 0)) == 70 and not _payment_cities().has(_second), "8. %s lost -> national gold 70 (%s)" % [_second, str(_national().get("gold"))])
	_expect_caches("8.")
	_set_owner(_second, _player)
	_expect(int(_national().get("gold", 0)) == 100, "8. %s back -> national gold 100" % _second)


# ---- 9 ----

func _check_cheat() -> void:
	var ctl := _main.get_node_or_null(CONTROLLER_NODE)
	_expect(ctl != null and bool(ctl.call("is_active")), "9. the cheat controller is active in this debug build")
	if ctl == null:
		return
	_seed({OWN_CITY: {}, _second: {}})
	ctl.call("fill_resources")
	var capacity: Dictionary = _main.get_script().get_script_constant_map()["WAREHOUSE_CAPACITY"]
	var owned := _payment_cities().size()
	var bad := []
	for resource_id in capacity:
		if int(_national().get(resource_id, -1)) != int(capacity[resource_id]) * owned:
			bad.append("%s %s" % [resource_id, str(_national().get(resource_id))])
	_expect(bad.is_empty(), "9. national = capacity x %d owned cities (%s)" % [owned, str(bad)])
	_expect_caches("9.")
	var rows: Array = _main.call("_build_warehouse_hud_rows")
	var bad_rows := []
	for row in rows:
		var resource_id := str(row.get("resource_id", ""))
		var shown := int(str(row.get("amount", "0 / 0")).split(" / ")[0])
		if capacity.has(resource_id) and shown != int(capacity[resource_id]) * owned:
			bad_rows.append("%s %s" % [resource_id, str(row.get("amount"))])
	_expect(not rows.is_empty() and bad_rows.is_empty(), "9. warehouse rows show the city sum, not 0 (%s)" % str(bad_rows))


# ---- helpers ----

func _set_owner(city_id: String, faction_id: String) -> void:
	var state: Dictionary = _main.call("_get_mutable_city_runtime_state", city_id)
	for key in ["owner", "nation", "owner_faction_id", "faction"]:
		state[key] = faction_id
	(_main.get("_city_runtime_states") as Dictionary)[city_id] = state
	var marker = (_main.get("_city_markers_by_id") as Dictionary).get(city_id)
	if marker != null:
		marker.owner_faction_id = faction_id
	_main.call("_rebuild_occupation_runtime_indexes_mvp")


func _seed(stocks: Dictionary) -> void:
	for city_id in _payment_cities():
		_main.call("_set_city_storage", city_id, stocks.get(city_id, {}))


func _payment_cities() -> Array:
	return Array(_main.call("_get_national_payment_city_ids_mvp"))


func _national() -> Dictionary:
	return (_main.call("_get_player_national_resource_stock_mvp") as Dictionary).duplicate(true)


func _stock(city_id: String) -> Dictionary:
	return (_main.call("_get_city_storage", city_id) as Dictionary).duplicate(true)


func _amount(city_id: String, resource_id: String) -> int:
	return int(_stock(city_id).get(resource_id, 0))


func _city(city_id: String) -> Dictionary:
	return _main.call("_get_city_hud_entry", city_id)


func _food(stock: Dictionary) -> int:
	var total := 0
	for resource_id in FOOD:
		total += int(stock.get(resource_id, 0))
	return total


func _city_snapshot() -> Dictionary:
	var snap := {}
	for city_id in _payment_cities():
		snap[city_id] = _stock(city_id)
	return snap


func _refusal_snapshot() -> Dictionary:
	var state: Dictionary = _main.get("_player_state")
	return {"cities": _city_snapshot(), "national": _national(), "cache": (state.get("resource_stock", {}) as Dictionary).duplicate(true)}


func _expect_refused(label: String, reason: String, check: Dictionary, result: Dictionary, snap: Dictionary) -> void:
	_expect(not bool(check.get("ok", true)) and (reason.is_empty() or str(result.get("reason", "")) == reason), "%s: refused (%s)" % [label, str(result.get("reason", ""))])
	_expect(_city_snapshot() == snap.cities, "%s: city stock unchanged" % label)
	_expect(_same_amounts(_national(), snap.national) and _same_amounts((_main.get("_player_state") as Dictionary).get("resource_stock", {}), snap.cache), "%s: national sum unchanged" % label)
	var message_before := str(check.get("message", check.get("reason", "")))
	var message_after := str(result.get("message", result.get("reason", "")))
	_expect(message_after == message_before, "%s: result message as the pre-check (%s / %s)" % [label, message_before, message_after])


func _same_amounts(a: Dictionary, b: Dictionary) -> bool:
	for key in a.keys() + b.keys():
		if int(a.get(key, 0)) != int(b.get(key, 0)):
			return false
	return true


func _expect_caches(label: String) -> void:
	var live := _national()
	var state: Dictionary = _main.get("_player_state")
	var cache: Dictionary = state.get("resource_stock", {})
	var aggregation: Dictionary = (state.get("national_aggregation", {}) as Dictionary).get("resources", {})
	_expect(_same_amounts(live, cache) and _same_amounts(live, aggregation), "%s national caches equal the live city sum (live %s / cache %s / aggregation %s)" % [label, str(live), str(cache), str(aggregation)])


func _expect_sum_is_cities(label: String) -> void:
	var sum := {}
	for city_id in _payment_cities():
		var stock := _stock(city_id)
		for resource_id in stock:
			sum[resource_id] = int(sum.get(resource_id, 0)) + int(stock[resource_id])
	_expect(_same_amounts(_national(), sum), "%s: national = city sum (%s / %s)" % [label, str(_national()), str(sum)])
	_expect_caches(label)


func _expect_charge(label: String, before: Dictionary, gold: int, food: int) -> void:
	_expect(int(before.get("gold", 0)) - int(_national().get("gold", 0)) == gold and _food(before) - _food(_national()) == food, "%s: city sum lowered by gold %d / food %d (gold %d -> %d)" % [label, gold, food, int(before.get("gold", 0)), int(_national().get("gold", 0))])
	_main.call("_rebuild_occupation_runtime_indexes_mvp")
	_main.call("_sync_player_resource_compatibility_from_city_stock_mvp")
	_expect(int(before.get("gold", 0)) - int(_national().get("gold", 0)) == gold and _food(before) - _food(_national()) == food, "%s: still paid after re-aggregation" % label)
	_expect_caches(label)


func _prepare_relation(enemy_city: String, score: int) -> void:
	var faction := str(_main.call("_get_city_owner_faction_id_for_trade_display", enemy_city))
	var relation: Dictionary = _main.call("_ensure_faction_relation_entry", _player, faction)
	relation["score"] = score
	relation["status"] = "neutral"
	relation["diplomacy_action_cooldown"] = 0
	relation["alliance_turns_remaining"] = 0
	var state: Dictionary = _main.get("_player_state")
	state["diplomacy_action_cooldowns"] = {}
	_main.call("_sync_diplomacy_action_mirror_state_from_relations")


func _find_enemy_city() -> String:
	var ids: Array = (_main.get_script().get_script_constant_map()["CITY_HUD_DATA"] as Dictionary).keys()
	ids.sort()
	for city_id_variant in ids:
		var city_id := str(city_id_variant)
		var owner := str(_main.call("_get_city_owner_faction_id_for_trade_display", city_id))
		if city_id != _second and not owner.is_empty() and owner != _player:
			return city_id
	return ""


# Same setup as the spy controller test: the chancellor runs the spy network.
func _prepare_spy() -> void:
	var state: Dictionary = _main.get("_player_state")
	state["chancellor_id"] = "jeong_do_jeon"
	state["spy_cooldown"] = 0
	state["city_intel"] = {}


func _valid_spy_target(spy, action: String) -> String:
	var ids: Array = (_main.get("_city_markers_by_id") as Dictionary).keys()
	ids.sort()
	for city_id in ids:
		if bool(spy.call("validate_spy_action", action, str(city_id)).get("ok", false)):
			return str(city_id)
	return ""


func _spy_reasons(spy, action: String) -> String:
	var reasons := {}
	for city_id in _main.get("_city_markers_by_id"):
		var reason := str(spy.call("validate_spy_action", action, str(city_id)).get("reason", ""))
		reasons[reason] = int(reasons.get(reason, 0)) + 1
	return str(reasons)


func _find_cost_tech(scope: String, city_id: String) -> String:
	var catalog = _main.call("_ensure_domestic_tech_catalog")
	var service = _main.call("_ensure_domestic_tech_research_service")
	var definitions: Dictionary = catalog.get_city_definitions() if scope == "city" else catalog.get_national_definitions()
	var ids := definitions.keys()
	ids.sort()
	for tech_id_variant in ids:
		if str(service.validate_start(str(tech_id_variant), city_id).get("reason", "")) == "insufficient_cost":
			return str(tech_id_variant)
	return ""


func _round_trip(data: Dictionary) -> Dictionary:
	var parsed: Variant = JSON.parse_string(JSON.stringify(data))
	return parsed if parsed is Dictionary else {}


func _has_storage_key(value: Variant) -> bool:
	if value is Dictionary:
		for key in (value as Dictionary):
			if str(key) == "storage" or _has_storage_key((value as Dictionary)[key]):
				return true
	elif value is Array:
		for item in value:
			if _has_storage_key(item):
				return true
	return false


func _expect(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(message)
		push_error("[STOCK_AUTHORITY_P0] FAIL: %s" % message)


func _finish() -> void:
	print("[STOCK_AUTHORITY_P0] checks=%d failures=%s" % [_checks, str(_failures)])
	quit(0 if _failures.is_empty() else 1)
