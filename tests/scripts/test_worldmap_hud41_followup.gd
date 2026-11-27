extends SceneTree

# Queue 42 (queue 41 follow-up, 채비서 53). Real WorldMap.tscn, new game (player / hanseong). Ledger values only.
#  1. public support disrupt tried but failed / detected (not a refusal): gold 300 out exactly once, the existing
#     cooldown starts, public support unchanged; detected -> the existing relation penalty (-10)
#  2. refusal when only silk is 1 short: loyalty disrupt (gold 500 + silk 49), revolt (gold 800 + silk 99) -> nothing
#     taken, no cooldown, no effect
#  3. trade lines = ledger amounts: submitted (reserved), settled "성사 — 받은 것 / 보낸 것" (result.received / paid),
#     "무효 · 예약분 반환" only with a real refund (+ a refund-less invalid shows plain "무효"), held -> "반환 보류"
#  4. result lines say "교역 결과" / "외교 결과", not the internal "N턴 결과"

const WORLDMAP_SCENE_PATH := "res://WorldMap.tscn"
const Strategy := preload("res://scripts/worldmap/actions/strategy_request_service.gd")
const OWN_CITY := "hanseong"
const ENEMY_CITY := "pyeongyang"
const RESOURCES := ["gold", "rice", "barley", "seafood", "wood", "iron", "horses", "silk", "salt"]

var _checks := 0
var _failures: Array[String] = []
var _main: Node
var _service: Object
var _player := ""
var _txn := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.size = Vector2i(1920, 1080)
	root.get_node("/root/GameSession").call("request_new_game", "player")
	_expect(change_scene_to_file(WORLDMAP_SCENE_PATH) == OK, "WorldMap scene transition starts")
	for i in 8:
		await process_frame
	_main = current_scene
	_expect(_main != null and _main.scene_file_path == WORLDMAP_SCENE_PATH, "WorldMap scene loaded")
	if _main == null:
		_finish()
		return
	_player = str(_main.call("_get_current_player_faction_id"))
	var spy: Object = _main.call("_ensure_spy_controller")
	_service = spy.get("_service")
	spy.call("validate_spy_action", "gather_info", ENEMY_CITY)  # binds the service to the world map
	_check_disrupt_tried()
	_check_silk_short()
	_check_trade_lines()
	_check_diplomacy_line()
	_finish()


# ---------------------------------------------------------------- 1
func _check_disrupt_tried() -> void:
	var faction := str(_main.call("_get_city_owner_faction_id_for_trade_display", ENEMY_CITY))
	for detected in [false, true]:
		_prepare_spy({"gold": 300})
		var check: Dictionary = _main.call("_validate_spy_action", "public_support_disrupt", ENEMY_CITY)
		_expect(bool(check.get("ok", false)) and int(check.get("success_chance", 100)) < 100, "1. disrupt allowed, success below 100 (%s)" % str(check.get("reason", "")))
		if detected:
			_expect(int(check.get("detection_chance", 0)) >= 1, "1. detection possible (%d)" % int(check.get("detection_chance", 0)))
		var support_before := int(_main.call("_get_city_public_support", ENEMY_CITY))
		var score_before := int(_main.call("_get_faction_relation_score", _player, faction))
		var before := _stock(OWN_CITY)
		# roll 100 = the attempt fails; detection roll 1 = detected, 100 = not detected
		var result: Dictionary = _service.call("_disrupt_city_public_support", ENEMY_CITY, 100, 1 if detected else 100)
		var tag := "detected" if detected else "failed"
		_expect(not bool(result.get("success", true)) and bool(result.get("detected", false)) == detected, "1. %s: the attempt is a failure%s" % [tag, " and detected" if detected else ""])
		_expect(_diff(before, _stock(OWN_CITY)) == {"gold": 300}, "1. %s: gold 300 out exactly once (%s)" % [tag, str(_diff(before, _stock(OWN_CITY)))])
		var cooldown := int((_main.get("_player_state") as Dictionary).get("spy_cooldown", 0))
		_expect(cooldown == int(_service.call("_get_spy_public_support_disrupt_cooldown_turns")) and cooldown > 0, "1. %s: the existing cooldown starts (%d)" % [tag, cooldown])
		_expect(int(_main.call("_get_city_public_support", ENEMY_CITY)) == support_before, "1. %s: public support unchanged (%d)" % [tag, support_before])
		var score_after := int(_main.call("_get_faction_relation_score", _player, faction))
		var want := clampi(score_before + (_service.get("SPY_DETECTED_RELATION_PENALTY_PUBLIC_SUPPORT") if _service.get("SPY_DETECTED_RELATION_PENALTY_PUBLIC_SUPPORT") != null else -10), 0, 100) if detected else score_before
		_expect(score_after == want, "1. %s: relation %d -> %d (want %d)" % [tag, score_before, score_after, want])


# ---------------------------------------------------------------- 2
func _check_silk_short() -> void:
	for case in [["loyalty_disrupt", {"gold": 500, "silk": 49}, {"loyalty": 40}], ["revolt_instigate", {"gold": 800, "silk": 99}, {"publicSupport": 40, "loyalty": 40}]]:
		_prepare_spy(case[1], case[2])
		var before := _stock(OWN_CITY)
		var support_before := int(_main.call("_get_city_public_support", ENEMY_CITY))
		var check: Dictionary = _main.call("_validate_spy_action", case[0], ENEMY_CITY)
		_main.call("_apply_spy_action", case[0], ENEMY_CITY)
		var cooldown := int((_main.get("_player_state") as Dictionary).get("spy_cooldown", 0))
		_expect(str(check.get("reason", "")) == "resources", "2. %s with silk 1 short: refused for resources (%s)" % [case[0], str(check.get("reason", ""))])
		_expect(_diff(before, _stock(OWN_CITY)).is_empty() and cooldown == 0 and int(_main.call("_get_city_public_support", ENEMY_CITY)) == support_before, "2. %s: nothing taken, no cooldown, no effect" % case[0])


# ---------------------------------------------------------------- 3
func _check_trade_lines() -> void:
	var trade: Object = _main.call("_ensure_trade_controller")
	var partner := ""
	for city_id in _main.get("_city_markers_by_id"):
		if str(_main.call("_find_contextual_trade_source_city_id", str(city_id))) == OWN_CITY:
			partner = str(city_id)
			break
	_expect(not partner.is_empty(), "3. trade partner exists")
	if partner.is_empty():
		return
	var partner_faction := str(_main.call("_get_city_owner_faction_id_for_trade_display", partner))
	# submitted
	var submitted := _submit(trade, partner)
	var request := _request(str(submitted.get("request_id", "")))
	var reserved: Dictionary = (request.get("reserved_assets", {}) as Dictionary).get(OWN_CITY, {})
	var text := _trade_text()
	_expect(text.contains("접수됨") and text.contains("예약 %s" % _amounts(reserved)), "3. submitted line carries the reserved %s: %s" % [_amounts(reserved), text.replace("\n", " / ")])
	_expect(int(reserved.get("rice", 0)) == 100, "3. ledger reserved rice 100")
	# settled
	_resolve(trade)
	request = _request(str(submitted.get("request_id", "")))
	var outcome: Dictionary = request.get("result", {})
	text = _trade_text()
	var want := "받은 것 %s · 보낸 것 %s" % [_amounts(outcome.get("received", {})), _amounts(outcome.get("paid", {}))]
	_expect(str(request.get("status", "")) == Strategy.STATUS_RESOLVED and text.contains("교역 결과 성사") and text.contains(want), "3. settled line = ledger received / paid (%s): %s" % [want, text.replace("\n", " / ")])
	_expect(int((outcome.get("paid", {}) as Dictionary).get("rice", 0)) == 100 and int((outcome.get("received", {}) as Dictionary).get("gold", 0)) > 0, "3. ledger paid rice 100, received gold %s" % str(outcome.get("received", {})))
	# invalid with a real refund
	var invalid := _submit(trade, partner)
	_set_relation(partner_faction, "hostile")
	_resolve(trade)
	request = _request(str(invalid.get("request_id", "")))
	var refunded: Dictionary = {}
	for city_id in (request.get("result", {}) as Dictionary).get("refunded", {}):
		refunded = request.result.refunded[city_id]
	text = _trade_text()
	_expect(str(request.get("status", "")) == Strategy.STATUS_INVALID and not refunded.is_empty() and text.contains("무효 · 예약분 반환 (%s)" % _amounts(refunded)), "3. invalid line shows the refunded %s: %s" % [_amounts(refunded), text.replace("\n", " / ")])
	_set_relation(partner_faction, "neutral")
	# an invalid result without any refund shows plain "무효" (no "예약분 반환")
	var state: Dictionary = _main.get("_player_state")
	var ledger: Dictionary = state[Strategy.LEDGER_KEY]
	var bare := (ledger[str(invalid.get("request_id", ""))] as Dictionary).duplicate(true)
	bare["request_id"] = "sr_99999_999999"
	bare["result"] = {"invalid": true, "reason": "target_changed", "refunded": {}, "message": "무효"}
	ledger[bare.request_id] = bare
	state[Strategy.LAST_RESULTS_KEY] = {"source_turn": 1, "transaction_id": "bare", "results": [{"request_id": bare.request_id, "status": Strategy.STATUS_INVALID, "message": "무효"}]}
	text = _trade_text()
	_expect(text.contains("교역 결과 무효") and not text.contains("예약분 반환"), "3. invalid with nothing refunded -> plain 무효: %s" % text.replace("\n", " / "))
	ledger.erase(bare.request_id)
	# held
	var held := _submit(trade, partner)
	var owned: Array = _main.call("_get_national_payment_city_ids_mvp")
	for city_id in owned:
		_set_owner(str(city_id), "goguryeo")
	_resolve(trade)
	request = _request(str(held.get("request_id", "")))
	var unrefunded: Dictionary = (request.get("unrefunded", {}) as Dictionary).get(OWN_CITY, {})
	text = _trade_text()
	_expect(str(request.get("status", "")) == Strategy.STATUS_HELD and text.contains("돌려줄 도시가 없어 반환 보류 (%s)" % _amounts(unrefunded)) and not text.contains("예약분 반환"), "3. held line shows the unrefunded %s: %s" % [_amounts(unrefunded), text.replace("\n", " / ")])
	for city_id in owned:
		_set_owner(str(city_id), _player)


# ---------------------------------------------------------------- 4
func _check_diplomacy_line() -> void:
	_set_stock(OWN_CITY, {"gold": 1000})
	var state: Dictionary = _main.get("_player_state")
	state["diplomacy_action_cooldown"] = 0
	var faction := str(_main.call("_get_city_owner_faction_id_for_trade_display", ENEMY_CITY))
	(_main.call("_ensure_faction_relation_entry", _player, faction) as Dictionary)["diplomacy_action_cooldown"] = 0
	var envoy: Dictionary = _main.call("_ensure_diplomacy_controller").call("execute", "envoy", ENEMY_CITY)
	_expect(bool(envoy.get("submitted", false)), "4. envoy submitted (%s)" % str(envoy.get("reason", "")))
	_main.call("_ensure_diplomacy_controller").call("resolve_strategy_requests", _turn(), _next_txn())
	var text := WorldMapHudConnectPresenter.format_strategy_requests(_main, Strategy.DOMAIN_DIPLOMACY)
	_expect(text.contains("외교 결과 처리") and not text.contains("턴 결과"), "4. diplomacy result line: %s" % text.replace("\n", " / "))
	var trade_text := _trade_text()
	_expect(not trade_text.contains("턴 결과"), "4. no internal turn number in the trade lines")


# ---------------------------------------------------------------- helpers
func _submit(trade: Object, partner: String) -> Dictionary:
	_set_stock(OWN_CITY, {"gold": 5000, "rice": 500})
	var full := {}
	for resource_id in RESOURCES:
		full[resource_id] = 5000
	_set_stock(partner, full)
	var order := {"source_city_id": OWN_CITY, "target_city_id": partner, "trade_type": "external", "mode": "manual", "orders": {"rice": {"action": "export", "amount": 100}}}
	order["preview"] = trade.call("build_external_manual_trade_execution_preview", order)
	order["efficiency"] = trade.call("get_trade_efficiency_for_cities", OWN_CITY, partner)
	trade.call("store_manual_trade_order", order)
	var result: Dictionary = _main.call("_execute_external_manual_trade_order", order)
	_expect(bool(result.get("submitted", false)), "3. trade submitted (%s)" % str(result.get("reason", "")))
	return result


func _resolve(trade: Object) -> void:
	trade.call("resolve_trade_requests", _turn(), _next_txn())


func _trade_text() -> String:
	return WorldMapHudConnectPresenter.format_strategy_requests(_main, Strategy.DOMAIN_TRADE)


func _amounts(amounts: Variant) -> String:
	return WorldMapHudConnectPresenter._format_amounts({"_": amounts})


func _prepare_spy(stock: Dictionary, target_values: Dictionary = {}) -> void:
	var state: Dictionary = _main.get("_player_state")
	state["chancellor_id"] = "jeong_do_jeon"
	state["spy_cooldown"] = 0
	var target: Dictionary = _main.call("_get_mutable_city_runtime_state", ENEMY_CITY)
	target["publicSupport"] = int(target_values.get("publicSupport", 60))
	target["loyalty"] = int(target_values.get("loyalty", 70))
	(_main.get("_city_runtime_states") as Dictionary)[ENEMY_CITY] = target
	_set_stock(OWN_CITY, stock)


func _set_relation(faction: String, status: String) -> void:
	var relation: Dictionary = _main.call("_ensure_faction_relation_entry", _player, faction)
	relation["status"] = status
	relation["score"] = 10 if status == "hostile" else 50
	((_main.get("_player_state") as Dictionary)["faction_relations"] as Dictionary)[_main.call("_make_faction_relation_key", _player, faction)] = relation


func _set_owner(city_id: String, faction_id: String) -> void:
	var state: Dictionary = _main.call("_get_mutable_city_runtime_state", city_id)
	for key in ["owner", "nation", "owner_faction_id", "faction"]:
		state[key] = faction_id
	(_main.get("_city_runtime_states") as Dictionary)[city_id] = state
	var marker = (_main.get("_city_markers_by_id") as Dictionary).get(city_id)
	if marker != null:
		marker.owner_faction_id = faction_id
	_main.call("_rebuild_occupation_runtime_indexes_mvp")


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


func _diff(before: Dictionary, after: Dictionary) -> Dictionary:
	var result := {}
	for resource_id in RESOURCES:
		var delta := int(before.get(resource_id, 0)) - int(after.get(resource_id, 0))
		if delta != 0:
			result[resource_id] = delta
	return result


func _request(request_id: String) -> Dictionary:
	var ledger: Dictionary = (_main.get("_player_state") as Dictionary).get(Strategy.LEDGER_KEY, {})
	return (ledger.get(request_id, {}) as Dictionary).duplicate(true)


func _turn() -> int:
	return maxi(1, int((_main.get("_player_state") as Dictionary).get("turn_number", 1)))


func _next_txn() -> String:
	_txn += 1
	return "hud41_followup_%d" % _txn


func _expect(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(message)
		push_error("[HUD41_FOLLOWUP] FAIL: %s" % message)


func _finish() -> void:
	print("[HUD41_FOLLOWUP] checks=%d failures=%s" % [_checks, str(_failures)])
	quit(0 if _failures.is_empty() else 1)
