extends SceneTree

# Queue 40 P2: manual external trade submitted once on T, settled at the turn end of T (T+1 result), both city stocks.
# Real WorldMap.tscn, new game (player / hanseong). Prices / efficiency formulas are today's.
#  1. buy + sell: submit takes only the player side once, not done; prices / relation change before the turn end ->
#     only the fixed amounts move, the source and partner cities mirror each other exactly, one result
#  2. barter: no existing barter path -> an order with any other action is refused (not implemented)
#  3. partner exactly enough -> done; 1 short -> nothing moves, the whole reservation back once; two orders sharing
#     one partner stock -> the first settles, the second is refused and refunded
#  4. diplomacy first: trade no longer allowed after the diplomacy resolution of the turn -> invalid + refund; the
#     real turn end settles a trade after the diplomacy step; the domestic result of the turn is not touched
#  5. ownership: source city lost -> refund to the player's capital only (occupier gets nothing); partner city taken
#     by another faction / becomes unclaimed -> invalid + refund to the source city
#  6. auto-trade cannot spend the reservation; own-city transfer stays immediate
#  7. re-click, save/load after submit, after settlement, at T+1 -> no second reservation / payment / refund; an old
#     save's stored manual order is never executed by itself
#  8. refund held (shared with P1): no city of the requester left -> `unrefunded` kept, status held, no city gets it;
#     a P1 diplomacy request takes the same path
#  (9. P0 / P3 / P1 / CITIES65 regressions stay on C-track)

const WORLDMAP_SCENE_PATH := "res://WorldMap.tscn"
const Strategy := preload("res://scripts/worldmap/actions/strategy_request_service.gd")
const OWN_CITY := "hanseong"
const RESOURCES := ["gold", "rice", "barley", "seafood", "wood", "iron", "horses", "silk", "salt"]

var _checks := 0
var _failures: Array[String] = []
var _main: Node
var _trade: Object
var _player := ""
var _partner := ""
var _partner_faction := ""
var _txn := 0


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
	_trade = _main.call("_ensure_trade_controller")
	_player = str(_main.call("_get_current_player_faction_id"))
	# Queue 46 (배치 A): 개성 (also the player's) sorts before 한성 as the contextual source of every partner, so the
	# partner is the first of 한성's own external trade candidates (the orders below name 한성 as the source).
	var own_candidates: Array = _main.call("_get_external_trade_candidate_city_ids", OWN_CITY)
	own_candidates.sort()
	_partner = str(own_candidates[0]) if not own_candidates.is_empty() else ""
	_expect(not _partner.is_empty(), "a foreign trade partner of %s exists" % OWN_CITY)
	if _partner.is_empty():
		_finish()
		return
	_partner_faction = str(_main.call("_get_city_owner_faction_id_for_trade_display", _partner))
	_check_buy_sell()
	_check_barter()
	_check_shortage_and_contention()
	_check_diplomacy_order()
	_check_auto_trade_and_transfer()
	_check_duplicates_and_load()
	_check_ownership()
	_check_refund_held()
	_finish()


# ---------------------------------------------------------------- 1
func _check_buy_sell() -> void:
	_reset()
	var source_before := _stock(OWN_CITY)
	var partner_before := _stock(_partner)
	var result := _submit({"rice": {"action": "export", "amount": 10}, "salt": {"action": "import", "amount": 4}})
	var preview: Dictionary = result.get("preview", {})
	var pay: Dictionary = result.get("reserved", {})
	_expect(bool(result.get("ok", false)) and bool(result.get("submitted", false)) and not bool(result.get("completed", true)), "1. submitted, not completed (%s)" % str(result.get("reason", "")))
	_expect(int(pay.get("rice", 0)) == 10 and int(pay.get("gold", 0)) > 0 and not pay.has("salt"), "1. player side = export rice 10 + import gold %s" % str(pay))
	_expect(_diff(source_before, _stock(OWN_CITY)) == _neg(pay), "1. only the player side left the source city once")
	_expect(_stock(_partner) == partner_before, "1. partner unchanged until the turn end")
	var request := _request(str(result.get("request_id", "")))
	_expect(str(request.get("domain", "")) == Strategy.DOMAIN_TRADE and str(request.get("status", "")) == Strategy.STATUS_PENDING, "1. pending trade request in the strategy ledger")
	# Prices and relation change before the turn end: the fixed amounts must not be re-priced.
	# (the order: market prices change in the domestic step of T) — move this turn's stored salt / rice multipliers to the
	# other end of today's 0.80..1.20 band (the price is rebuilt from the multiplier).
	_main.call("_ensure_trade_market_for_current_turn")
	var market: Dictionary = (_main.get("_player_state") as Dictionary).get("last_trade_market_result", {})
	for resource_id in ["salt", "rice"]:
		if market.get("prices", {}) is Dictionary and (market.prices as Dictionary).get(resource_id, {}) is Dictionary:
			var entry: Dictionary = market.prices[resource_id]
			var moved := 0.80 if float(entry.get("multiplier", 1.0)) >= 1.0 else 1.20
			entry["multiplier"] = moved
			entry["price"] = maxi(1, int(round(float(entry.get("base_price", entry.get("base", 1))) * moved)))
	var repriced: Dictionary = _trade.call("build_external_manual_trade_execution_preview", _order({"rice": {"action": "export", "amount": 10}, "salt": {"action": "import", "amount": 4}}))
	_expect(int(repriced.get("gold", 0)) != int(preview.get("gold", 0)), "1. price changed before the turn end (a new quote would differ: %d vs %d, eff %s -> %s, salt price %s)" % [int(repriced.get("gold", 0)), int(preview.get("gold", 0)), str(result.get("efficiency")), str(_trade.call("get_trade_efficiency_for_cities", OWN_CITY, _partner)), str(_main.call("_get_trade_market_price", "salt"))])
	var settled := _resolve()
	_expect(int(settled.get("count", 0)) == 1, "1. one result (%d)" % int(settled.get("count", 0)))
	var source_delta := _diff(source_before, _stock(OWN_CITY))
	var partner_delta := _diff(partner_before, _stock(_partner))
	_expect(source_delta == _only_nonzero(preview), "1. source moved by exactly the submitted preview %s vs %s" % [str(source_delta), str(_only_nonzero(preview))])
	_expect(partner_delta == _neg(source_delta), "1. partner mirrors the source %s" % str(partner_delta))
	_expect(str(_request(str(result.get("request_id", ""))).get("status", "")) == Strategy.STATUS_RESOLVED, "1. request resolved")
	var after := [_stock(OWN_CITY), _stock(_partner)]
	_resolve("trade_p2_test_%d" % _txn)
	_resolve()
	_expect([_stock(OWN_CITY), _stock(_partner)] == after, "1. resolving again (same or new transaction) changes nothing")
	_set_relation("neutral")


# ---------------------------------------------------------------- 2
func _check_barter() -> void:
	_reset()
	var check: Dictionary = _trade.call("validate_external_manual_trade_execution", _order({"rice": {"action": "barter", "amount": 5}}))
	_expect(not bool(check.get("ok", true)) and str(check.get("reason", "")) == "action", "2. barter not implemented: only import / export exist (%s)" % str(check.get("reason", "")))


# ---------------------------------------------------------------- 3
func _check_shortage_and_contention() -> void:
	_reset()
	_set_stock(_partner, {"gold": 5000, "salt": 6})
	var exact := _submit({"salt": {"action": "import", "amount": 6}})
	_resolve()
	_expect(str(_request(str(exact.get("request_id", ""))).get("status", "")) == Strategy.STATUS_RESOLVED and int(_stock(_partner).get("salt", -1)) == 0, "3. partner exactly enough -> done")
	_reset()
	_set_stock(_partner, {"gold": 5000, "salt": 6})
	var source_before := _stock(OWN_CITY)
	var partner_before := _stock(_partner)
	var short := _submit({"salt": {"action": "import", "amount": 7}})
	_resolve()
	var request := _request(str(short.get("request_id", "")))
	_expect(str(request.get("status", "")) == Strategy.STATUS_INVALID and str(request.get("result", {}).get("reason", "")) == "partner_shortage", "3. one short -> invalid partner_shortage")
	_expect(_stock(OWN_CITY) == source_before and _stock(_partner) == partner_before, "3. nothing moved, reservation back once")
	_resolve()
	_expect(_stock(OWN_CITY) == source_before, "3. no second refund")
	# Two orders sharing one partner stock (salt 6): 4 then 4.
	_reset()
	_set_stock(_partner, {"gold": 5000, "salt": 6})
	var gold_before := int(_stock(OWN_CITY).get("gold", 0))
	var first := _submit({"salt": {"action": "import", "amount": 4}})
	var second := _submit({"salt": {"action": "import", "amount": 4}})
	_expect(bool(first.get("ok", false)) and bool(second.get("ok", false)), "3. two orders submitted (no new concurrency limit)")
	_resolve()
	_expect(str(_request(str(first.get("request_id", ""))).get("status", "")) == Strategy.STATUS_RESOLVED, "3. first order settles")
	_expect(str(_request(str(second.get("request_id", ""))).get("status", "")) == Strategy.STATUS_INVALID, "3. second order refused (partner salt left 2)")
	_expect(int(_stock(OWN_CITY).get("gold", 0)) == gold_before - int((first.get("reserved", {}) as Dictionary).get("gold", 0)) and int(_stock(_partner).get("salt", -1)) == 2, "3. only the first order's gold left, partner salt 6 -> 2")


# ---------------------------------------------------------------- 4
func _check_diplomacy_order() -> void:
	_reset()
	var source_before := _stock(OWN_CITY)
	var result := _submit({"salt": {"action": "import", "amount": 4}})
	_set_relation("hostile")  # as a diplomacy resolution of this turn would leave it
	var domestic_before: Variant = (_main.get("_player_state") as Dictionary).get("last_domestic_apply_result", {}).duplicate(true)
	_resolve()
	var request := _request(str(result.get("request_id", "")))
	_expect(str(request.get("status", "")) == Strategy.STATUS_INVALID and str(request.get("result", {}).get("reason", "")) == "relation", "4. no longer allowed to trade -> invalid relation")
	_expect(_stock(OWN_CITY) == source_before, "4. reservation back")
	_expect((_main.get("_player_state") as Dictionary).get("last_domestic_apply_result", {}) == domestic_before, "4. the domestic result of the turn is not touched")
	_set_relation("neutral")
	# Agreement expiry alone is not an invalid condition (채비서 48): re-checked with today's rule at settlement.
	for blocked in [false, true]:
		_reset()
		_set_agreement(true, 1)
		var before := _stock(OWN_CITY)
		var with_agreement := _submit({"salt": {"action": "import", "amount": 2}})
		_set_agreement(false, 0)  # the agreement ran out in this turn's domestic step
		if blocked:
			_set_relation("suspended")  # ...and under the existing rule trade is now blocked
		_resolve()
		var r := _request(str(with_agreement.get("request_id", "")))
		if blocked:
			_expect(str(r.get("status", "")) == Strategy.STATUS_INVALID and _stock(OWN_CITY) == before, "4. agreement expired and trade now blocked -> invalid, refunded once")
		else:
			_expect(str(r.get("status", "")) == Strategy.STATUS_RESOLVED and int(_stock(OWN_CITY).get("salt", 0)) == int(before.get("salt", 0)) + 2, "4. agreement expired but trade still allowed -> settles normally (%s)" % str(r.get("result", {}).get("reason", "")))
		_set_relation("neutral")
	# The real turn end: domestic -> diplomacy -> trade -> turn advance.
	_reset()
	var submitted := _submit({"salt": {"action": "import", "amount": 2}})
	var turn := _turn()
	_end_turn()
	var turn_result: Dictionary = (_main.get("_player_state") as Dictionary).get("last_turn_resolution_result", {})
	var ids := []
	for entry in turn_result.get("strategy_request_results", []):
		ids.append(str(entry.get("request_id", "")))
	_expect(_turn() == turn + 1 and ids.has(str(submitted.get("request_id", ""))), "4. the real turn end settles the trade (%s)" % str(ids))
	_expect(str(_request(str(submitted.get("request_id", ""))).get("status", "")) == Strategy.STATUS_RESOLVED, "4. settled at the turn end, result at T+1")


# ---------------------------------------------------------------- 6
func _check_auto_trade_and_transfer() -> void:
	_reset()
	_set_stock(OWN_CITY, {"gold": 5000, "rice": 10, "salt": 50})
	var result := _submit({"rice": {"action": "export", "amount": 10}})
	_expect(int(_stock(OWN_CITY).get("rice", -1)) == 0, "6. reserved rice no longer in the city")
	var modes_before: Variant = _main.get("_trade_control_modes")
	_trade.call("run_chancellor_auto_trade", _turn() + 100)
	_main.set("_trade_control_modes", modes_before)
	var request := _request(str(result.get("request_id", "")))
	_expect(int((request.get("reserved_assets", {}).get(OWN_CITY, {}) as Dictionary).get("rice", 0)) == 10, "6. the reservation is untouched by auto-trade")
	var partner_rice := int(_stock(_partner).get("rice", 0))
	_resolve()
	_expect(int(_stock(_partner).get("rice", 0)) == partner_rice + 10, "6. the partner gets the whole reservation")
	# Own-city transfer stays immediate.
	_set_owner("sabi", _player)
	var connected: Array = _trade.call("get_internal_trade_connected_player_city_ids", OWN_CITY)
	if connected.is_empty():
		_expect(true, "6. no connected own city for a transfer (skipped)")
	else:
		var to_city := str(connected[0])
		var before := int(_stock(to_city).get("gold", 0))
		var transfer: Dictionary = _trade.call("execute_internal_transfer", OWN_CITY, to_city, {"gold": 5})
		_expect(not bool(transfer.get("ok", false)) or int(_stock(to_city).get("gold", 0)) == before + 5, "6. own-city transfer is immediate (%s)" % str(transfer.get("reason", "ok")))
	_set_owner("sabi", "baekje_faction")


# ---------------------------------------------------------------- 7
func _check_duplicates_and_load() -> void:
	_reset()
	var order := _order({"salt": {"action": "import", "amount": 3}})
	_trade.call("store_manual_trade_order", order)
	var first: Dictionary = _trade.call("execute", "trade", _partner, OWN_CITY)
	var after_submit := _stock(OWN_CITY)
	var again: Dictionary = _trade.call("execute", "trade", _partner, OWN_CITY)
	_expect(bool(first.get("ok", false)) and not bool(again.get("ok", false)) and _stock(OWN_CITY) == after_submit, "7. re-click: the order is used up, no second reservation (%s)" % str(again.get("reason", "")))
	_round_trip()
	_expect(_stock(OWN_CITY) == after_submit and _pending_trade().size() == 1, "7. save/load after submit: same stock, one pending request")
	var txn := _next_txn()
	_resolve(txn)
	var settled := [_stock(OWN_CITY), _stock(_partner)]
	_round_trip()
	_resolve(txn)
	_resolve()
	_expect([_stock(OWN_CITY), _stock(_partner)] == settled, "7. save/load after settlement + resolve again: no second payment")
	_end_turn()
	var t1 := [_stock(OWN_CITY).get("salt"), _request(str(first.get("request_id", ""))).get("status")]
	_round_trip()
	_expect([_stock(OWN_CITY).get("salt"), _request(str(first.get("request_id", ""))).get("status")] == t1, "7. T+1 load: nothing again")
	# An old save with a stored manual order: it stays a draft, nothing runs by itself.
	_reset()
	var saved: Dictionary = JSON.parse_string(JSON.stringify(_main.call("_serialize_worldmap_state")))
	var state: Dictionary = saved.get("player_state", {})
	state["manual_trade_orders"] = {OWN_CITY: _order({"salt": {"action": "import", "amount": 2}})}
	_expect(bool(_main.call("_apply_worldmap_state", saved)), "7. old save with a stored manual order loads")
	var ledger_before: Dictionary = (_main.get("_player_state") as Dictionary).get(Strategy.LEDGER_KEY, {}).duplicate(true)
	var last_before: Variant = (_main.get("_player_state") as Dictionary).get("last_external_manual_trade_execution_result", {}).duplicate(true)
	_end_turn()
	var ledger_after: Dictionary = (_main.get("_player_state") as Dictionary).get(Strategy.LEDGER_KEY, {})
	_expect(ledger_after.keys() == ledger_before.keys(), "7. the old stored order is not submitted by itself (no new request)")
	_expect(not (_trade.call("get_manual_trade_order", OWN_CITY) as Dictionary).is_empty(), "7. the old stored order stays a draft")
	_expect((_main.get("_player_state") as Dictionary).get("last_external_manual_trade_execution_result", {}) == last_before, "7. the old stored order is not executed by itself")
	_trade.call("store_manual_trade_order", {})
	_main.set("_manual_trade_orders", {})


# ---------------------------------------------------------------- 5
func _check_ownership() -> void:
	# Source city lost: refund to the player's capital (another own city), the occupier gets nothing.
	# Queue 46: under 배치 A the player already owns 개성, the first own city after 한성 (capital first, then by id).
	_reset()
	var refund_city := "gaeseong"
	_expect(bool(_main.call("_is_city_owned_by_player_mvp", refund_city)), "5. 개성 is the player's second city")
	var result := _submit({"salt": {"action": "import", "amount": 4}})
	var pay: Dictionary = result.get("reserved", {})
	_set_owner(OWN_CITY, "goguryeo")
	var occupied_before := _stock(OWN_CITY)
	var capital_before := _stock(refund_city)
	var partner_before := _stock(_partner)
	_resolve()
	var request := _request(str(result.get("request_id", "")))
	_expect(str(request.get("status", "")) == Strategy.STATUS_INVALID and str(request.get("result", {}).get("reason", "")) == "source_changed", "5. source city lost -> invalid source_changed")
	_expect(_stock(OWN_CITY) == occupied_before and _stock(_partner) == partner_before, "5. occupier and partner get nothing")
	_expect(_diff(capital_before, _stock(refund_city)) == _only_nonzero(pay), "5. the whole reservation goes to the player's capital once")
	_set_owner(OWN_CITY, _player)
	# Partner taken by a third faction / becomes unclaimed.
	for new_owner in ["wei", ""]:
		_reset()
		var source_before := _stock(OWN_CITY)
		var submitted := _submit({"salt": {"action": "import", "amount": 4}})
		_set_owner(_partner, new_owner)
		_resolve()
		var r := _request(str(submitted.get("request_id", "")))
		var want := "target_changed" if new_owner != "" else WorldMapUnclaimedCityRules.REJECT_REASON
		_expect(str(r.get("status", "")) == Strategy.STATUS_INVALID and str(r.get("result", {}).get("reason", "")) == want, "5. partner now '%s' -> invalid %s (%s)" % [new_owner, want, str(r.get("result", {}).get("reason", ""))])
		_expect(_stock(OWN_CITY) == source_before, "5. partner now '%s': reservation back to the source city" % new_owner)
		_set_owner(_partner, _partner_faction)


# ---------------------------------------------------------------- 8
func _check_refund_held() -> void:
	_reset()
	var result := _submit({"salt": {"action": "import", "amount": 4}})
	var pay: Dictionary = result.get("reserved", {})
	var owned: Array = _main.call("_get_national_payment_city_ids_mvp")
	for city_id in owned:
		_set_owner(str(city_id), "goguryeo")
	var stocks_before := _all_stocks()
	_resolve()
	var request := _request(str(result.get("request_id", "")))
	_expect(str(request.get("status", "")) == Strategy.STATUS_HELD, "8. trade: no city of the player left -> held (%s)" % str(request.get("status", "")))
	_expect((request.get("unrefunded", {}) as Dictionary) == {OWN_CITY: pay}, "8. trade: unrefunded kept per city %s" % str(request.get("unrefunded", {})))
	_expect(_all_stocks() == stocks_before, "8. trade: the held amount went into no city")
	for city_id in owned:
		_set_owner(str(city_id), _player)
	# P1 diplomacy request through the same refund path.
	_reset()
	var state: Dictionary = _main.get("_player_state")
	var envoy: Dictionary = _main.call("_ensure_diplomacy_controller").call("execute", "envoy", _partner)
	_expect(bool(envoy.get("submitted", false)), "8. diplomacy envoy submitted (%s)" % str(envoy.get("reason", "")))
	var diplomacy_request := _request(str(envoy.get("request_id", "")))
	for city_id in _main.call("_get_national_payment_city_ids_mvp"):
		_set_owner(str(city_id), "goguryeo")
	_set_owner(_partner, "wei")
	var before := _all_stocks()
	_main.call("_ensure_diplomacy_controller").call("resolve_strategy_requests", _turn(), _next_txn())
	var after_request := _request(str(envoy.get("request_id", "")))
	_expect(str(after_request.get("status", "")) == Strategy.STATUS_HELD and (after_request.get("unrefunded", {}) as Dictionary) == (diplomacy_request.get("reserved_assets", {}) as Dictionary), "8. diplomacy: held with unrefunded %s" % str(after_request.get("unrefunded", {})))
	_expect(_all_stocks() == before, "8. diplomacy: the held amount went into no city")
	_expect(state != null, "8. player state kept")


# ---------------------------------------------------------------- helpers
func _reset() -> void:
	_main.set("_manual_trade_orders", {})
	_set_relation("neutral")
	var full := {}
	for resource_id in RESOURCES:
		full[resource_id] = 200
	full["gold"] = 5000
	_set_stock(OWN_CITY, full)
	_set_stock(_partner, full)
	(_main.get("_player_state") as Dictionary)["diplomacy_action_cooldown"] = 0
	var relation: Dictionary = _main.call("_ensure_faction_relation_entry", _player, _partner_faction)
	relation["diplomacy_action_cooldown"] = 0


func _order(items: Dictionary, source: String = OWN_CITY) -> Dictionary:
	var order := {"source_city_id": source, "target_city_id": _partner, "trade_type": "external", "mode": "manual", "orders": items}
	order["preview"] = _trade.call("build_external_manual_trade_execution_preview", order)
	order["efficiency"] = _trade.call("get_trade_efficiency_for_cities", source, _partner)
	return order


func _submit(items: Dictionary) -> Dictionary:
	var order := _order(items)
	_trade.call("store_manual_trade_order", order)
	return _main.call("_execute_external_manual_trade_order", order)


func _resolve(txn: String = "") -> Dictionary:
	return _trade.call("resolve_trade_requests", _turn(), txn if not txn.is_empty() else _next_txn())


func _next_txn() -> String:
	_txn += 1
	return "trade_p2_test_%d" % _txn


func _set_relation(status: String) -> void:
	var relation: Dictionary = _main.call("_ensure_faction_relation_entry", _player, _partner_faction)
	relation["status"] = status
	relation["score"] = 80 if status == "allied" else (10 if status == "hostile" else 50)
	var state: Dictionary = _main.get("_player_state")
	(state["faction_relations"] as Dictionary)[_main.call("_make_faction_relation_key", _player, _partner_faction)] = relation


func _set_agreement(active: bool, turns: int) -> void:
	var relation: Dictionary = _main.call("_ensure_faction_relation_entry", _player, _partner_faction)
	relation["trade_agreement_active"] = active
	relation["trade_agreement_turns_remaining"] = turns
	var state: Dictionary = _main.get("_player_state")
	(state["faction_relations"] as Dictionary)[_main.call("_make_faction_relation_key", _player, _partner_faction)] = relation


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


func _all_stocks() -> Dictionary:
	var result := {}
	for city_id in (_main.get("_city_markers_by_id") as Dictionary):
		result[str(city_id)] = _stock(str(city_id))
	return result


## after - before, non-zero entries only.
func _diff(before: Dictionary, after: Dictionary) -> Dictionary:
	var result := {}
	for resource_id in RESOURCES:
		var delta := int(after.get(resource_id, 0)) - int(before.get(resource_id, 0))
		if delta != 0:
			result[resource_id] = delta
	return result


func _neg(amounts: Dictionary) -> Dictionary:
	var result := {}
	for resource_id in amounts:
		if int(amounts[resource_id]) != 0:
			result[resource_id] = -int(amounts[resource_id])
	return result


func _only_nonzero(amounts: Dictionary) -> Dictionary:
	var result := {}
	for resource_id in RESOURCES:
		if int(amounts.get(resource_id, 0)) != 0:
			result[resource_id] = int(amounts[resource_id])
	return result


func _request(request_id: String) -> Dictionary:
	var ledger: Dictionary = (_main.get("_player_state") as Dictionary).get(Strategy.LEDGER_KEY, {})
	return (ledger.get(request_id, {}) as Dictionary).duplicate(true)


func _pending_trade() -> Array:
	var result: Array = []
	var ledger: Dictionary = (_main.get("_player_state") as Dictionary).get(Strategy.LEDGER_KEY, {})
	for request in ledger.values():
		if str(request.get("domain", "")) == Strategy.DOMAIN_TRADE and str(request.get("status", "")) == Strategy.STATUS_PENDING:
			result.append(request)
	return result


func _turn() -> int:
	return maxi(1, int((_main.get("_player_state") as Dictionary).get("turn_number", 1)))


func _end_turn() -> void:
	var turn_controller = _main.call("_ensure_turn_controller")
	(_main.get("_player_state") as Dictionary)["pending_invasion_event"] = {}
	turn_controller.call("request_end_turn")
	turn_controller.call("finish_enemy_turn")
	(_main.get("_player_state") as Dictionary)["pending_invasion_event"] = {}
	_main.call("_clear_pending_invasion_event_mvp")


func _round_trip() -> void:
	var parsed: Variant = JSON.parse_string(JSON.stringify(_main.call("_serialize_worldmap_state")))
	_expect(parsed is Dictionary and bool(_main.call("_apply_worldmap_state", parsed)), "save -> load")


func _expect(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(message)
		push_error("[TRADE_P2] FAIL: %s" % message)


func _finish() -> void:
	print("[TRADE_P2] checks=%d failures=%s" % [_checks, str(_failures)])
	quit(0 if _failures.is_empty() else 1)
