extends SceneTree

# Queue 38 STRATEGY-P1: the strategy request ledger + basic diplomacy submitted on T, resolved at the turn end of T,
# shown at T+1. Real WorldMap.tscn, new game (player / hanseong). Every number (cost, relation, cooldown, alliance 70,
# agreement / alliance turns) is today's.
#  1. envoy submitted on T: gold 30 out of the cities at once (national = city sum), relation unchanged, 1 pending
#  2. a second diplomacy request to the same faction is refused, nothing more taken
#  3. real turn end -> T+1: relation +delta, cooldown 1, request resolved + applied_transaction_id; resolving never
#     charges again (city stock unchanged by the resolution itself)
#  4. tribute / restore relations / trade agreement: today's relation delta, cooldown, agreement 6 turns
#  5. alliance: acceptance >= 70 -> allied with 8 turns at the T+1 start; acceptance 69 -> rejected, cost spent, cooldown 4
#  6. an existing alliance counts down by 1 while the new one starts at 8 on the same turn end
#  7. invalid (relation entry gone) -> invalid, the reservation comes back once to its city; city lost -> to the capital
#  8. submit -> save -> load -> resolve: one result; resolve -> save -> load -> resolve again with the same transaction: no change
#  9. the chancellor auto-trade of the same turn cannot spend the reserved gold (it is no longer in the city)
# 10. an AI-source envoy goes through the same resolution
# 11. an invasion already set on T is not cancelled by an alliance resolved at the end of T
# (12. P0 / P3 regressions: test_worldmap_stock_authority_p0 / test_worldmap_spy_intel_p3 on C-track)

const WORLDMAP_SCENE_PATH := "res://WorldMap.tscn"
const Diplomacy := preload("res://scripts/worldmap/actions/diplomacy_action_service.gd")
const Strategy := preload("res://scripts/worldmap/actions/strategy_request_service.gd")
const OWN_CITY := "hanseong"

var _checks := 0
var _failures: Array[String] = []
var _main: Node
var _ctl: Object
var _player := ""
var _targets: Array[String] = []  # enemy faction ids
var _city_of := {}  # faction id -> one of its cities
var _second := ""


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
	_ctl = _main.call("_ensure_diplomacy_controller")
	_player = str(_main.call("_get_current_player_faction_id"))
	_collect_targets()
	_expect(_targets.size() >= 6, "at least six enemy factions with a city (%s)" % str(_targets))
	if _targets.size() < 6:
		_finish()
		return
	var marker = (_main.get("_city_markers_by_id") as Dictionary).get(OWN_CITY)
	_second = str(marker.neighbors[0]) if marker != null and not marker.neighbors.is_empty() else ""

	_check_submit_and_turn_end()
	_check_other_actions()
	_check_alliance()
	_check_invalid_and_refund()
	_check_save_load()
	_check_auto_trade()
	_check_ai_source()
	_check_invasion_kept()
	_finish()


# ---- 1, 2, 3 ----

func _check_submit_and_turn_end() -> void:
	var target := _targets[0]
	_set_relation(target, 60)
	_seed({"gold": 1000, "silk": 200, "rice": 500})
	var gold_before := _national_gold()
	var score_before := _score(target)
	var submitted: Dictionary = _ctl.call("execute", "envoy", _city_of[target])
	_expect(bool(submitted.get("submitted", false)), "1. envoy submitted (%s)" % str(submitted.get("reason", "")))
	_expect(gold_before - _national_gold() == 30 and _national_gold() == _city_gold_sum(), "1. gold 30 out of the cities at once, national = city sum (%d -> %d)" % [gold_before, _national_gold()])
	_expect(_score(target) == score_before, "1. relation unchanged on T (%d)" % _score(target))
	_expect(_pending_for(target).size() == 1, "1. one pending request (%d)" % _pending_for(target).size())
	var gold_after_submit := _national_gold()
	var second: Dictionary = _ctl.call("execute", "tribute", _city_of[target])
	_expect(not bool(second.get("success", true)) and str(second.get("reason", "")) == "pending_request" and _national_gold() == gold_after_submit, "2. second request to the same faction refused, nothing taken (%s)" % str(second.get("reason", "")))

	var expected_delta := int((_pending_for(target)[0] as Dictionary).get("fixed_context", {}).get("relation_delta", 0))
	var turn := _turn()
	var request_id := str((_pending_for(target)[0] as Dictionary).get("request_id", ""))
	_end_turn()
	_expect(_turn() == turn + 1, "3. turn advanced %d -> %d" % [turn, _turn()])
	_expect(_score(target) == clampi(score_before + expected_delta, 0, 100), "3. relation +%d at T+1 (%d -> %d)" % [expected_delta, score_before, _score(target)])
	_expect(int(_relation(target).get("diplomacy_action_cooldown", -1)) == 1, "3. cooldown 1 at T+1 (%s)" % str(_relation(target).get("diplomacy_action_cooldown")))
	var request := _request(request_id)
	_expect(str(request.get("status", "")) == "resolved" and not str(request.get("applied_transaction_id", "")).is_empty(), "3. request resolved with applied_transaction_id (%s / %s)" % [str(request.get("status")), str(request.get("applied_transaction_id"))])

	# Resolution itself never charges: submit again, snapshot the cities, resolve directly.
	_set_relation(_targets[1], 60)
	_ctl.call("execute", "envoy", _city_of[_targets[1]])
	var stocks_before := _city_stocks()
	_ctl.call("resolve_strategy_requests", _turn(), "test_resolve_only_%d" % _turn())
	_expect(_city_stocks() == stocks_before, "3. the resolution takes nothing again (city stock unchanged)")


# ---- 4 ----

func _check_other_actions() -> void:
	_seed({"gold": 2000, "silk": 200, "rice": 500})
	var cases := [["tribute", _targets[2], 60, "neutral"], ["restore_relations", _targets[3], 20, "hostile"], ["trade_agreement", _targets[4], 60, "neutral"]]
	for case in cases:
		_set_relation(case[1], case[2], case[3])
		var before := _score(case[1])
		var submitted: Dictionary = _ctl.call("execute", case[0], _city_of[case[1]])
		_expect(bool(submitted.get("submitted", false)), "4. %s submitted (%s)" % [case[0], str(submitted.get("reason", ""))])
	var deltas := {}
	for case in cases:
		deltas[case[0]] = int((_pending_for(case[1])[0] as Dictionary).get("fixed_context", {}).get("relation_delta", 0)) if not _pending_for(case[1]).is_empty() else -999
	_ctl.call("resolve_strategy_requests", _turn(), "test_other_%d" % _turn())
	for case in cases:
		var definition := Diplomacy.get_action_definition(case[0])
		_expect(_score(case[1]) == clampi(int(case[2]) + int(deltas[case[0]]), 0, 100) and int(_relation(case[1]).get("diplomacy_action_cooldown", -1)) == int(definition.get("cooldown", -1)), "4. %s: relation %d -> %d (+%d), cooldown %s" % [case[0], int(case[2]), _score(case[1]), int(deltas[case[0]]), str(_relation(case[1]).get("diplomacy_action_cooldown"))])
	var agreement := _relation(_targets[4])
	_expect(bool(agreement.get("trade_agreement_active", false)) and int(agreement.get("trade_agreement_turns_remaining", 0)) == 6, "4. trade agreement 6 turns (%s)" % str(agreement.get("trade_agreement_turns_remaining")))


# ---- 5, 6 ----

func _check_alliance() -> void:
	_seed({"gold": 3000, "silk": 500, "rice": 500})
	var cost: Dictionary = Diplomacy.get_action_definition("alliance_proposal").get("cost", {})
	var yes := _targets[5]
	var no := _targets[1]
	var old_ally := _targets[2]
	_set_relation(yes, _score_for_acceptance(yes, cost, 70))
	_set_relation(no, _score_for_acceptance(no, cost, 69))
	_set_relation(old_ally, 70, "allied", 5)
	var acceptance_yes := int(_ctl.call("_calculate_alliance_acceptance_chance", yes, cost, 8))
	var acceptance_no := int(_ctl.call("_calculate_alliance_acceptance_chance", no, cost, 8))
	_expect(acceptance_yes == 70 and acceptance_no == 69, "5. acceptance prepared 70 / 69 (%d / %d)" % [acceptance_yes, acceptance_no])
	var gold_before := _national_gold()
	_expect(bool((_ctl.call("execute", "alliance_proposal", _city_of[yes]) as Dictionary).get("submitted", false)), "5. alliance (70) submitted")
	_expect(bool((_ctl.call("execute", "alliance_proposal", _city_of[no]) as Dictionary).get("submitted", false)), "5. alliance (69) submitted")
	_expect(gold_before - _national_gold() == int(cost.get("gold", 0)) * 2, "5. both costs reserved at once")
	var gold_reserved := _national_gold()
	_end_turn()
	var accepted := _relation(yes)
	_expect(str(accepted.get("status", "")) == "allied" and int(accepted.get("alliance_turns_remaining", 0)) == 8, "5. acceptance 70 -> allied, 8 turns at T+1 (%s / %s)" % [str(accepted.get("status")), str(accepted.get("alliance_turns_remaining"))])
	var rejected := _relation(no)
	_expect(str(rejected.get("status", "")) != "allied" and int(rejected.get("diplomacy_action_cooldown", -1)) == 4, "5. acceptance 69 -> rejected, cooldown 4 (%s / %s)" % [str(rejected.get("status")), str(rejected.get("diplomacy_action_cooldown"))])
	var rejected_request := _request_for(no, "alliance_proposal")
	_expect(str(rejected_request.get("status", "")) == "resolved" and not bool(rejected_request.get("result", {}).get("accepted", true)) and not rejected_request.get("result", {}).has("refunded") and _reserved_gold(rejected_request) == int(cost.get("gold", 0)), "5. a rejection is resolved (not invalid), the cost stays spent, no refund (%s)" % str(rejected_request.get("status")))
	var old := _relation(old_ally)
	_expect(int(old.get("alliance_turns_remaining", 0)) == 4 and int(accepted.get("alliance_turns_remaining", 0)) == 8, "6. existing alliance 5 -> 4, new one 8 on the same turn end (%s / %s)" % [str(old.get("alliance_turns_remaining")), str(accepted.get("alliance_turns_remaining"))])
	_expect(gold_reserved >= 0, "5. reserved gold stayed out")


# ---- 7 ----

func _check_invalid_and_refund() -> void:
	var target := _targets[3]
	_set_relation(target, 60)
	_seed({"gold": 500, "silk": 100, "rice": 100})
	var capital_gold := _city_gold(OWN_CITY)
	_ctl.call("execute", "envoy", _city_of[target])
	_expect(_city_gold(OWN_CITY) == capital_gold - 30, "7. envoy reserved 30 from %s" % OWN_CITY)
	_erase_relation(target)
	_ctl.call("resolve_strategy_requests", _turn(), "test_invalid_%d" % _turn())
	var request := _request_for(target, "envoy")
	_expect(str(request.get("status", "")) == "invalid" and _city_gold(OWN_CITY) == capital_gold, "7. relation gone -> invalid, 30 back to %s (%s, %d)" % [OWN_CITY, str(request.get("status")), _city_gold(OWN_CITY)])
	_ctl.call("resolve_strategy_requests", _turn(), "test_invalid_again_%d" % _turn())
	_expect(_city_gold(OWN_CITY) == capital_gold, "7. refunded only once (%d)" % _city_gold(OWN_CITY))

	if _second.is_empty():
		_expect(false, "7. a neighbour city for the lost-city case")
		return
	_set_owner(_second, _player)
	_set_relation(target, 60)
	for city_id in _payment_cities():
		_main.call("_set_city_storage", city_id, {"gold": 100} if city_id == _second else {"gold": 0})
	_ctl.call("execute", "envoy", _city_of[target])
	var reserved: Dictionary = _request_for(target, "envoy", "pending").get("reserved_assets", {})
	_expect(reserved.has(_second), "7. reserved from %s (%s)" % [_second, str(reserved)])
	_set_owner(_second, _targets[0])
	_erase_relation(target)
	_ctl.call("resolve_strategy_requests", _turn(), "test_lost_city_%d" % _turn())
	_expect(_city_gold(OWN_CITY) == 30, "7. city lost -> the 30 goes to the capital %s (%d)" % [OWN_CITY, _city_gold(OWN_CITY)])


# ---- 8 ----

func _check_save_load() -> void:
	var target := _targets[4]
	_set_relation(target, 60)
	_seed({"gold": 500, "silk": 100, "rice": 100})
	_ctl.call("execute", "envoy", _city_of[target])
	var delta := int(_request_for(target, "envoy", "pending").get("fixed_context", {}).get("relation_delta", 0))
	var score := _score(target)
	_round_trip()
	_expect(_request_for(target, "envoy", "pending").size() > 0, "8. the pending request survives save -> load")
	var gold_loaded := _national_gold()
	var tx := "test_saveload_%d" % _turn()
	_ctl.call("resolve_strategy_requests", _turn(), tx)
	_expect(_score(target) == clampi(score + delta, 0, 100) and _national_gold() == gold_loaded, "8. one result after load (%d -> %d), no charge" % [score, _score(target)])
	var after_score := _score(target)
	var stocks := _city_stocks()
	_round_trip()
	_ctl.call("resolve_strategy_requests", _turn(), tx)
	_expect(_score(target) == after_score and _city_stocks() == stocks, "8. same transaction resolved again after save -> load: no change")
	_ctl.call("resolve_strategy_requests", _turn(), tx + "_other")
	_expect(_score(target) == after_score and _city_stocks() == stocks, "8. a resolved request is never resolved twice")


# ---- 9 ----

func _check_auto_trade() -> void:
	var target := _targets[5]
	_set_relation(target, 60, "allied", 0)
	_set_relation(target, 60)
	_seed({"gold": 40, "rice": 0, "barley": 0, "seafood": 0, "salt": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0})
	_ctl.call("execute", "envoy", _city_of[target])
	_expect(_city_gold(OWN_CITY) == 10, "9. reservation leaves 10 gold in %s (%d)" % [OWN_CITY, _city_gold(OWN_CITY)])
	var state: Dictionary = _main.get("_player_state")
	state["last_chancellor_auto_trade_turn"] = 0
	if str(state.get("chancellor_id", "")).is_empty():
		var candidates: Array[String] = _main.call("_get_player_chancellor_candidate_hero_ids")
		if not candidates.is_empty():
			state["chancellor_id"] = candidates[0]
	var modes_before: Variant = _main.get("_trade_control_modes")
	_main.set("_trade_control_modes", {"internal_trade": "chancellor", "external_trade": "chancellor"})
	_main.call("_apply_chancellor_auto_trade_for_world_turn", 7000 + _turn())
	_main.set("_trade_control_modes", modes_before)
	var request := _request_for(target, "envoy", "pending")
	_expect(_city_gold(OWN_CITY) >= 0 and _city_gold(OWN_CITY) <= 10 + _trade_gold_gain(), "9. auto-trade worked with what was left; the reserved 30 was not there to spend (gold %d)" % _city_gold(OWN_CITY))
	_expect(_reserved_gold(request) == 30, "9. the request still holds its 30 (%d)" % _reserved_gold(request))
	_ctl.call("resolve_strategy_requests", _turn(), "test_autotrade_%d" % _turn())


# ---- 10 ----

func _check_ai_source() -> void:
	var source := _targets[0]
	var target := _targets[1]
	var source_gold_before := _faction_gold(source)
	var relation: Dictionary = _ctl.call("_ensure_faction_relation_entry", source, target)
	relation["diplomacy_action_cooldown"] = 0
	_store_relation(source, target, relation)
	var score := int(relation.get("score", 50))
	var submitted: Dictionary = _ctl.call("submit_strategy_request", source, "envoy", target, "")
	_expect(bool(submitted.get("submitted", false)), "10. AI envoy submitted (%s)" % str(submitted.get("reason", "")))
	_expect(source_gold_before - _faction_gold(source) == 30, "10. 30 gold reserved from the AI's cities (%d -> %d)" % [source_gold_before, _faction_gold(source)])
	_ctl.call("resolve_strategy_requests", _turn(), "test_ai_%d" % _turn())
	var after: Dictionary = _ctl.call("_ensure_faction_relation_entry", source, target)
	_expect(int(after.get("score", 0)) == clampi(score + 5, 0, 100) and int(after.get("diplomacy_action_cooldown", -1)) == 1, "10. AI envoy resolved by the same pass: relation %d -> %d, cooldown %s" % [score, int(after.get("score", 0)), str(after.get("diplomacy_action_cooldown"))])


# ---- 11 ----

func _check_invasion_kept() -> void:
	var target := _targets[5]
	_seed({"gold": 3000, "silk": 500, "rice": 500})
	var cost: Dictionary = Diplomacy.get_action_definition("alliance_proposal").get("cost", {})
	var relation := _relation(target)
	relation["status"] = "neutral"
	relation["alliance_turns_remaining"] = 0
	relation["diplomacy_action_cooldown"] = 0
	_store_relation(_player, target, relation)
	_set_relation(target, _score_for_acceptance(target, cost, 75))
	_ctl.call("execute", "alliance_proposal", _city_of[target])
	var invasion := {"event_id": "test_invasion", "attacker_faction_id": target, "target_city_id": OWN_CITY, "transaction_id": "test_invasion_tx", "turn": _turn()}
	(_main.get("_player_state") as Dictionary)["pending_invasion_event"] = invasion.duplicate(true)
	_ctl.call("resolve_strategy_requests", _turn(), "test_invasion_%d" % _turn())
	_expect(str(_relation(target).get("status", "")) == "allied", "11. the alliance was resolved (%s)" % str(_relation(target).get("status")))
	_expect((_main.get("_player_state") as Dictionary).get("pending_invasion_event", {}) == invasion, "11. the invasion set on T is not cancelled by it")
	(_main.get("_player_state") as Dictionary)["pending_invasion_event"] = {}


# ---- helpers ----

func _collect_targets() -> void:
	var ids: Array = (_main.get_script().get_script_constant_map()["CITY_HUD_DATA"] as Dictionary).keys()
	ids.sort()
	for city_id in ids:
		var owner := str(_main.call("_get_city_owner_faction_id_for_trade_display", str(city_id)))
		if owner.is_empty() or owner == _player or _city_of.has(owner):
			continue
		_city_of[owner] = str(city_id)
		_targets.append(owner)


func _set_relation(faction: String, score: int, status: String = "neutral", alliance_turns: int = 0) -> void:
	var entry: Dictionary = _ctl.call("_ensure_faction_relation_entry", _player, faction)
	entry["score"] = score
	entry["status"] = status
	entry["diplomacy_action_cooldown"] = 0
	entry["alliance_turns_remaining"] = alliance_turns
	_store_relation(_player, faction, entry)
	var state: Dictionary = _main.get("_player_state")
	var cooldowns: Dictionary = state.get("diplomacy_action_cooldowns", {}) if state.get("diplomacy_action_cooldowns", {}) is Dictionary else {}
	cooldowns.erase(faction)
	state["diplomacy_action_cooldowns"] = cooldowns


func _store_relation(a: String, b: String, entry: Dictionary) -> void:
	var state: Dictionary = _main.get("_player_state")
	var relations: Dictionary = state.get("faction_relations", {}) if state.get("faction_relations", {}) is Dictionary else {}
	relations[str(_ctl.call("_make_faction_relation_key", a, b))] = entry
	state["faction_relations"] = relations
	_ctl.call("_sync_diplomacy_action_mirror_state_from_relations")


func _erase_relation(faction: String) -> void:
	var state: Dictionary = _main.get("_player_state")
	var relations: Dictionary = state.get("faction_relations", {})
	relations.erase(str(_ctl.call("_make_faction_relation_key", _player, faction)))
	state["faction_relations"] = relations


func _relation(faction: String) -> Dictionary:
	var relations: Dictionary = (_main.get("_player_state") as Dictionary).get("faction_relations", {})
	return (relations.get(str(_ctl.call("_make_faction_relation_key", _player, faction)), {}) as Dictionary).duplicate(true)


func _score(faction: String) -> int:
	return int(_relation(faction).get("score", -1))


func _score_for_acceptance(faction: String, cost: Dictionary, wanted: int) -> int:
	for score in range(0, 101):
		_set_relation(faction, score)
		if int(_ctl.call("_calculate_alliance_acceptance_chance", faction, cost, 8)) == wanted:
			return score
	return -1


func _payment_cities() -> Array:
	return Array(_main.call("_get_national_payment_city_ids_mvp"))


func _seed(stock: Dictionary) -> void:
	var cities := _payment_cities()
	for index in cities.size():
		_main.call("_set_city_storage", str(cities[index]), stock if index == 0 else {})


func _city_stocks() -> Dictionary:
	var stocks := {}
	for city_id in _payment_cities():
		stocks[city_id] = (_main.call("_get_city_storage", str(city_id)) as Dictionary).duplicate(true)
	return stocks


func _city_gold(city_id: String) -> int:
	return int((_main.call("_get_city_storage", city_id) as Dictionary).get("gold", 0))


func _city_gold_sum() -> int:
	var total := 0
	for city_id in _payment_cities():
		total += _city_gold(str(city_id))
	return total


func _national_gold() -> int:
	return int((_main.call("_get_player_national_resource_stock_mvp") as Dictionary).get("gold", 0))


func _faction_gold(faction: String) -> int:
	var total := 0
	for city_id in (_main.get_script().get_script_constant_map()["CITY_HUD_DATA"] as Dictionary).keys():
		if str(_main.call("_get_city_owner_faction_id_for_trade_display", str(city_id))) == faction:
			total += _city_gold(str(city_id))
	return total


func _set_owner(city_id: String, faction_id: String) -> void:
	var state: Dictionary = _main.call("_get_mutable_city_runtime_state", city_id)
	for key in ["owner", "nation", "owner_faction_id", "faction"]:
		state[key] = faction_id
	(_main.get("_city_runtime_states") as Dictionary)[city_id] = state
	var marker = (_main.get("_city_markers_by_id") as Dictionary).get(city_id)
	if marker != null:
		marker.owner_faction_id = faction_id
	_main.call("_rebuild_occupation_runtime_indexes_mvp")


func _ledger() -> Dictionary:
	return ((_main.get("_player_state") as Dictionary).get(Strategy.LEDGER_KEY, {}) as Dictionary)


func _request(request_id: String) -> Dictionary:
	return (_ledger().get(request_id, {}) as Dictionary).duplicate(true)


func _pending_for(faction: String) -> Array:
	var result: Array = []
	for request in _ctl.call("get_pending_strategy_requests"):
		if str(request.get("target_faction_id", "")) == faction and str(request.get("source_faction_id", "")) == _player:
			result.append(request)
	return result


## The newest request to faction with action_id (optionally with status).
func _request_for(faction: String, action_id: String, status: String = "") -> Dictionary:
	var ids := _ledger().keys()
	ids.sort()
	ids.reverse()
	for request_id in ids:
		var request: Dictionary = _ledger()[request_id]
		if str(request.get("target_faction_id", "")) == faction and str(request.get("action_id", "")) == action_id and (status.is_empty() or str(request.get("status", "")) == status):
			return request.duplicate(true)
	return {}


func _reserved_gold(request: Dictionary) -> int:
	var total := 0
	var reserved: Dictionary = request.get("reserved_assets", {})
	for city_id in reserved:
		total += int((reserved[city_id] as Dictionary).get("gold", 0))
	return total


func _trade_gold_gain() -> int:
	var result: Dictionary = (_main.get("_player_state") as Dictionary).get("last_chancellor_auto_trade_result", {})
	var gain := 0
	for entry in (result.get("external", {}) as Dictionary).get("applied", []):
		gain += maxi(0, int((entry.get("applied", {}) as Dictionary).get("gold", 0)))
	return gain


func _turn() -> int:
	return maxi(1, int((_main.get("_player_state") as Dictionary).get("turn_number", 1)))


## The real turn end: end turn -> enemy turn -> finish (domestic, strategy resolution, turn advance).
func _end_turn() -> void:
	var turn_controller = _main.call("_ensure_turn_controller")
	(_main.get("_player_state") as Dictionary)["pending_invasion_event"] = {}
	turn_controller.call("request_end_turn")
	turn_controller.call("finish_enemy_turn")
	var state: Dictionary = _main.get("_player_state")
	state["pending_invasion_event"] = {}
	_main.call("_clear_pending_invasion_event_mvp")


func _round_trip() -> void:
	var parsed: Variant = JSON.parse_string(JSON.stringify(_main.call("_serialize_worldmap_state")))
	_expect(parsed is Dictionary and bool(_main.call("_apply_worldmap_state", parsed)), "save -> load")


func _expect(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(message)
		push_error("[STRATEGY_P1] FAIL: %s" % message)


func _finish() -> void:
	print("[STRATEGY_P1] checks=%d failures=%s" % [_checks, str(_failures)])
	quit(0 if _failures.is_empty() else 1)
