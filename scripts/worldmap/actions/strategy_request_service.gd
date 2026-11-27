class_name WorldMapStrategyRequestService
extends RefCounted

## Queue 38 (PC v0.2 P1): the strategy request ledger shared by diplomacy (now) and trade (P2).
## A request is submitted on world turn T (its cost is reserved at once, out of the cities, P0 ledger), and the
## turn-end resolution of T settles it exactly once, so its result shows at the start of T+1.
## The host is the diplomacy controller: every existing number and judgement (cost, relation, cooldown, alliance 70,
## agreement / alliance turns) comes from WorldMapDiplomacyActionService unchanged.

const DiplomacyActionServiceScript := preload("res://scripts/worldmap/actions/diplomacy_action_service.gd")

const LEDGER_KEY := "strategy_pending_requests"
const SEQUENCE_KEY := "strategy_request_sequence"
const LAST_RESULTS_KEY := "last_strategy_request_results"
const DOMAIN_DIPLOMACY := "diplomacy"
## Queue 40 (P2): manual external trade goes through the same ledger (one request per stored order).
const DOMAIN_TRADE := "trade"
const TRADE_ACTION_ID := "manual_external_trade"
const STATUS_PENDING := "pending"
const STATUS_RESOLVED := "resolved"
const STATUS_INVALID := "invalid"
const STATUS_CANCELLED := "cancelled"
## Queue 40: an invalid request whose reservation has no city of the source faction left to go back to keeps it as
## `unrefunded` (per city) instead of dropping it; how a held reservation is paid back later is not decided yet.
const STATUS_HELD := "held"

# ---- Queue 38 §0-2 rule defaults (Kim 11-27 20:44: "rules can change later") — change them here only. ----
## Cost is reserved (taken out of the cities, atomically) when the request is submitted.
const RESERVE_COST_ON_SUBMIT := true
## A request submitted on turn T resolves at the turn-end of T (result visible at T+1); same for player and AI.
const RESOLVE_DELAY_TURNS := 0
## Pending requests allowed per (source faction, target faction, domain) pair.
const MAX_PENDING_PER_PAIR_AND_DOMAIN := 1
## A request that is no longer valid at resolution gets its reserved cost back, once.
const REFUND_ON_INVALID := true
## A normal rejection (alliance acceptance below 70) keeps the cost spent, as today.
const KEEP_COST_ON_REJECTION := true
## Player diplomacy actions that go through the ledger.
const PLAYER_DIPLOMACY_ACTIONS := ["envoy", "tribute", "trade_agreement", "restore_relations", "alliance_proposal"]
## AI-source actions the ledger can settle today: a relation change plus a cooldown on that faction pair. Trade
## agreements and alliances are bound to the player faction in the diplomacy service (AI diplomacy judgement is P5).
const AI_SOURCE_ACTIONS := ["envoy", "tribute", "restore_relations"]
const RESOURCE_IDS := ["gold", "rice", "barley", "seafood", "wood", "iron", "horses", "silk", "salt"]


# ---- submit -----------------------------------------------------------------------------------------------------

## Player button path (diplomacy controller execute): validate as today, refuse a second pending request for the same
## faction pair, reserve the cost out of the cities, store the request. Nothing else changes until the turn end.
static func submit_player_diplomacy(host: Object, action_id: String, target_city_id: String) -> Dictionary:
	var service = host.get("_service")
	var player_state := _player_state(host)
	var turn := maxi(1, int(player_state.get("turn_number", 1)))
	var context_variant: Variant = host.call("_build_diplomacy_action_validation_context", action_id, target_city_id)
	var context: Dictionary = context_variant if context_variant is Dictionary else {}
	var validation := DiplomacyActionServiceScript.validate_action(action_id, context)
	if not bool(validation.get("ok", false)):
		return _store_submit_failure(host, DiplomacyActionServiceScript.build_failure_result(turn, action_id, validation))
	var source_faction_id := str(host.call("_get_current_player_faction_id"))
	var target_faction_id := str(validation.get("target_faction_id", ""))
	if not PLAYER_DIPLOMACY_ACTIONS.has(action_id):
		return _store_submit_failure(host, _failure(turn, action_id, validation, "invalid_action", "외교 행동을 확인할 수 없습니다."))
	if _pending_count(host, source_faction_id, target_faction_id, DOMAIN_DIPLOMACY) >= MAX_PENDING_PER_PAIR_AND_DOMAIN:
		return _store_submit_failure(host, _failure(turn, action_id, validation, "pending_request", "이 세력에 대한 외교 요청이 이미 접수되어 있습니다. 다음 턴 결과를 기다리십시오."))
	var cost: Dictionary = validation.get("cost", {}) if validation.get("cost", {}) is Dictionary else {}
	var before_stocks := _player_payment_city_stocks(host)
	var payment: Dictionary = service.apply_diplomacy_resource_cost(host, cost) if RESERVE_COST_ON_SUBMIT else {}
	var reserved := _stock_decrease(before_stocks, _player_payment_city_stocks(host))
	if not _covers(reserved, cost):
		# The P0 payment is all or nothing; anything short here means nothing was taken.
		_refund(host, reserved, source_faction_id)
		return _store_submit_failure(host, _failure(turn, action_id, validation, "resources", "자원이 부족합니다."))
	var request := _new_request(host, turn, DOMAIN_DIPLOMACY, action_id, source_faction_id, target_faction_id, str(validation.get("target_city_id", "")))
	request["reserved_assets"] = reserved
	request["payment"] = payment.duplicate(true)
	request["fixed_context"] = {
		"cost": cost.duplicate(true),
		"before_score": int(validation.get("before_score", 0)),
		"before_status": str(validation.get("before_status", "")),
		"relation_delta": int(validation.get("relation_delta", 0)),
		"cooldown": int(validation.get("cooldown", 0)),
		"alliance_turns": int(validation.get("alliance_turns", 0)),
		"acceptance_score": int(validation.get("acceptance_score", 0)),
	}
	_store_request(host, request)
	var result := {
		"turn": turn,
		"action_id": action_id,
		"action_label": str(validation.get("action_label", action_id)),
		"target_city_id": str(validation.get("target_city_id", "")),
		"target_faction_id": target_faction_id,
		"cost": cost.duplicate(true),
		"payment": payment.duplicate(true),
		"before_score": int(validation.get("before_score", 0)),
		"after_score": int(validation.get("before_score", 0)),
		"success": true,
		"submitted": true,
		"request_id": str(request.get("request_id", "")),
		"resolve_turn": int(request.get("resolve_turn", turn)),
		"message": "%s 요청을 접수했습니다. 결과는 다음 턴에 나옵니다." % str(validation.get("action_label", action_id)),
	}
	_set_last_result(host, result)
	return result


## AI path (decision of when to use it is P5): same ledger, same turn-end resolution. The cost is reserved out of the
## source faction's own cities.
static func submit_strategy_request(host: Object, source_faction_id: String, action_id: String, target_faction_id: String, target_city_id: String = "") -> Dictionary:
	var player_state := _player_state(host)
	var turn := maxi(1, int(player_state.get("turn_number", 1)))
	var base := {"action_id": action_id, "target_city_id": target_city_id, "target_faction_id": target_faction_id}
	if source_faction_id == str(host.call("_get_current_player_faction_id")):
		return submit_player_diplomacy(host, action_id, target_city_id)
	if not AI_SOURCE_ACTIONS.has(action_id):
		return _failure(turn, action_id, base, "unsupported_source_action", "이 행동은 아직 AI 출처로 접수할 수 없습니다.")
	if source_faction_id.is_empty() or target_faction_id.is_empty() or source_faction_id == target_faction_id:
		return _failure(turn, action_id, base, "invalid_target", "외교 대상을 확인할 수 없습니다.")
	if _pending_count(host, source_faction_id, target_faction_id, DOMAIN_DIPLOMACY) >= MAX_PENDING_PER_PAIR_AND_DOMAIN:
		return _failure(turn, action_id, base, "pending_request", "이 세력에 대한 외교 요청이 이미 접수되어 있습니다.")
	var relation: Dictionary = host.call("_ensure_faction_relation_entry", source_faction_id, target_faction_id)
	if maxi(0, int(relation.get("diplomacy_action_cooldown", 0))) > 0:
		return _failure(turn, action_id, base, "cooldown", "외교 사절단이 아직 복귀하지 않았습니다.")
	var definition := DiplomacyActionServiceScript.get_action_definition(action_id)
	var cost: Dictionary = (definition.get("cost", {}) as Dictionary).duplicate(true)
	var reserved := _reserve_from_faction_cities(host, source_faction_id, cost)
	if reserved.is_empty() and not cost.is_empty():
		return _failure(turn, action_id, base, "resources", "자원이 부족합니다.")
	var request := _new_request(host, turn, DOMAIN_DIPLOMACY, action_id, source_faction_id, target_faction_id, target_city_id)
	request["reserved_assets"] = reserved
	request["fixed_context"] = {"cost": cost, "relation_delta": int(definition.get("relation_delta", 0)), "cooldown": int(definition.get("cooldown", 0))}
	_store_request(host, request)
	return {"success": true, "submitted": true, "request_id": str(request.get("request_id", "")), "action_id": action_id, "source_faction_id": source_faction_id, "target_faction_id": target_faction_id}


## Queue 40 (P2) player manual external trade: validate the stored order exactly as today, fix both sides with
## today's formulas (import ceil(price*amount/eff), export floor(price*amount*eff)), take only the player's side out of
## the source city once (import gold, export items) and store the request. Nothing moves to the partner until the
## turn end. host = the world map (city stock / ownership / relation bridges), trade = the trade controller.
static func submit_player_trade(host: Object, trade: Object, order: Dictionary) -> Dictionary:
	var turn := maxi(1, int(_player_state(host).get("turn_number", 1)))
	var action_service = trade.get("_action_service")
	var context: Dictionary = trade.call("_build_external_manual_trade_execution_context", order)
	var validation: Dictionary = action_service.validate_order(order, context)
	var source_city_id := str(order.get("source_city_id", ""))
	var target_city_id := str(order.get("target_city_id", ""))
	if not bool(validation.get("ok", false)):
		validation["source_city_id"] = source_city_id
		validation["target_city_id"] = target_city_id
		return validation
	var efficiency := float(context.get("efficiency", 0.0))
	var prices: Dictionary = context.get("market_prices", {})
	var lines: Array = []
	var pay := {}  # player side, reserved now: import gold + export items
	var receive := {}  # partner side, paid at the turn end: import items + export gold
	var orders: Dictionary = order.get("orders", {})
	for resource_id in action_service.TRADE_RESOURCE_ORDER:
		var item: Variant = orders.get(resource_id, {})
		if not item is Dictionary:
			continue
		var action := str((item as Dictionary).get("action", "none"))
		var amount := maxi(0, int((item as Dictionary).get("amount", 0)))
		var price := int(prices.get(resource_id, 0))
		if amount <= 0:
			continue
		if action == action_service.ACTION_IMPORT:
			var cost: int = action_service.calculate_import_cost(price, amount, efficiency)
			lines.append({"resource_id": resource_id, "action": action, "amount": amount, "price": price, "gold": cost})
			pay["gold"] = int(pay.get("gold", 0)) + cost
			receive[resource_id] = int(receive.get(resource_id, 0)) + amount
		elif action == action_service.ACTION_EXPORT:
			var gain: int = action_service.calculate_export_gain(price, amount, efficiency)
			lines.append({"resource_id": resource_id, "action": action, "amount": amount, "price": price, "gold": gain})
			pay[resource_id] = int(pay.get(resource_id, 0)) + amount
			receive["gold"] = int(receive.get("gold", 0)) + gain
	_drop_zero(pay)
	_drop_zero(receive)
	var stock: Dictionary = (host.call("_get_city_storage", source_city_id) as Dictionary).duplicate(true)
	for resource_id in pay:
		if int(stock.get(resource_id, 0)) < int(pay[resource_id]):
			return {"ok": false, "success": false, "reason": "resources", "message": "자원이 부족합니다.", "source_city_id": source_city_id, "target_city_id": target_city_id}
	for resource_id in pay:
		stock[resource_id] = int(stock.get(resource_id, 0)) - int(pay[resource_id])
	host.call("_set_city_storage", source_city_id, stock)
	var source_faction_id := str(context.get("source_faction_id", ""))
	var target_faction_id := str(context.get("target_faction_id", ""))
	var request := _new_request(host, turn, DOMAIN_TRADE, TRADE_ACTION_ID, source_faction_id, target_faction_id, target_city_id)
	request["reserved_assets"] = {source_city_id: pay.duplicate(true)} if not pay.is_empty() else {}
	request["fixed_context"] = {
		"source_city_id": source_city_id,
		"target_city_id": target_city_id,
		"source_faction_id": source_faction_id,
		"target_faction_id": target_faction_id,
		"lines": lines,
		"pay": pay.duplicate(true),
		"receive": receive.duplicate(true),
		"efficiency": efficiency,
		"market_turn": int(context.get("market_turn", 0)),
		"market_prices": prices.duplicate(true),
	}
	_store_request(host, request)
	return {
		"ok": true,
		"success": true,
		"submitted": true,
		"completed": false,
		"status": STATUS_PENDING,
		"request_id": str(request.get("request_id", "")),
		"resolve_turn": int(request.get("resolve_turn", turn)),
		"source_city_id": source_city_id,
		"target_city_id": target_city_id,
		"target_faction_id": target_faction_id,
		"reserved": pay.duplicate(true),
		"expected_receive": receive.duplicate(true),
		# The source city's net change once the trade settles (today's preview, never re-priced).
		"preview": action_service.build_preview(order, context),
		"efficiency": efficiency,
		"market_turn": int(context.get("market_turn", 0)),
		"market_prices": prices.duplicate(true),
		"message": "수동 무역을 접수했습니다. 결과는 다음 턴에 나옵니다.",
	}


# ---- resolve ----------------------------------------------------------------------------------------------------

## Turn-end of world turn source_turn (after the domestic step, before the turn advances). Every pending request due on
## or before source_turn is settled once, in request_id order. A request already stamped with transaction_id is skipped,
## so a re-entered resolution (load in the middle of the turn end) changes nothing twice.
## Queue 40: one domain per call (the turn end runs diplomacy first, then trade); a request without a domain is diplomacy.
static func resolve_turn(host: Object, source_turn: int, transaction_id: String, domain: String = DOMAIN_DIPLOMACY) -> Dictionary:
	var ledger := _ledger(host)
	var ids := ledger.keys()
	ids.sort()
	var results: Array = []
	for request_id_variant in ids:
		var request: Dictionary = (ledger.get(request_id_variant, {}) as Dictionary).duplicate(true)
		if str(request.get("status", "")) != STATUS_PENDING:
			continue
		if str(request.get("domain", DOMAIN_DIPLOMACY)) != domain:
			continue
		if int(request.get("resolve_turn", source_turn + 1)) > source_turn:
			continue
		if str(request.get("applied_transaction_id", "")) == transaction_id:
			continue
		var outcome := _resolve_request(host, request, source_turn)
		request["status"] = str(outcome.get("status", STATUS_RESOLVED))
		request["result"] = (outcome.get("result", {}) as Dictionary).duplicate(true)
		if outcome.has("unrefunded"):
			request["unrefunded"] = (outcome.get("unrefunded", {}) as Dictionary).duplicate(true)
		request["applied_transaction_id"] = transaction_id
		request["resolved_turn"] = source_turn
		ledger = _ledger(host)
		ledger[str(request_id_variant)] = request
		_set_ledger(host, ledger)
		results.append({"request_id": str(request_id_variant), "status": request["status"], "action_id": str(request.get("action_id", "")), "source_faction_id": str(request.get("source_faction_id", "")), "target_faction_id": str(request.get("target_faction_id", "")), "message": str(request["result"].get("message", ""))})
	if not results.is_empty():
		var player_state := _player_state(host)
		var previous: Dictionary = player_state.get(LAST_RESULTS_KEY, {}) if player_state.get(LAST_RESULTS_KEY, {}) is Dictionary else {}
		var all_results: Array = (previous.get("results", []) as Array).duplicate(true) if str(previous.get("transaction_id", "")) == transaction_id else []
		all_results.append_array(results.duplicate(true))
		player_state[LAST_RESULTS_KEY] = {"source_turn": source_turn, "transaction_id": transaction_id, "results": all_results}
		host.set("_player_state", player_state)
	return {"source_turn": source_turn, "transaction_id": transaction_id, "count": results.size(), "results": results}


static func _resolve_request(host: Object, request: Dictionary, source_turn: int) -> Dictionary:
	if str(request.get("domain", DOMAIN_DIPLOMACY)) == DOMAIN_TRADE:
		return _resolve_trade_request(host, request, source_turn)
	var source_faction_id := str(request.get("source_faction_id", ""))
	var target_faction_id := str(request.get("target_faction_id", ""))
	var action_id := str(request.get("action_id", ""))
	var invalid_reason := _invalid_reason(host, request)
	if not invalid_reason.is_empty():
		return _invalidate(host, request, invalid_reason)
	if source_faction_id != str(host.call("_get_current_player_faction_id")):
		return _resolve_ai_request(host, request)
	var service = host.get("_service")
	# This request's own reservation is the prepaid payment: execute must not charge again.
	var prepaid: Dictionary = (request.get("payment", {}) as Dictionary).duplicate(true) if request.get("payment", {}) is Dictionary else {}
	if prepaid.is_empty():
		prepaid = {"reserved_assets": (request.get("reserved_assets", {}) as Dictionary).duplicate(true)}
	prepaid["request_id"] = str(request.get("request_id", ""))
	var result: Dictionary = service.execute(host, action_id, str(request.get("target_city_id", "")), "", prepaid)
	var processed := bool(result.get("success", false)) or result.has("accepted")
	if not processed:
		return _invalidate(host, request, str(result.get("reason", "validation_failed")), result)
	result["request_id"] = str(request.get("request_id", ""))
	result["resolved_turn"] = source_turn
	return {"status": STATUS_RESOLVED, "result": result}


static func _resolve_ai_request(host: Object, request: Dictionary) -> Dictionary:
	var service = host.get("_service")
	var source_faction_id := str(request.get("source_faction_id", ""))
	var target_faction_id := str(request.get("target_faction_id", ""))
	var fixed: Dictionary = request.get("fixed_context", {}) if request.get("fixed_context", {}) is Dictionary else {}
	var relation_result: Dictionary = service.apply_diplomacy_relation_delta(host, source_faction_id, target_faction_id, int(fixed.get("relation_delta", 0)), "strategy_request_%s" % str(request.get("action_id", "")))
	var relation: Dictionary = host.call("_ensure_faction_relation_entry", source_faction_id, target_faction_id)
	relation["diplomacy_action_cooldown"] = maxi(0, int(fixed.get("cooldown", 0)))
	var key := str(host.call("_make_faction_relation_key", source_faction_id, target_faction_id))
	var player_state := _player_state(host)
	var relations: Dictionary = player_state.get("faction_relations", {}) if player_state.get("faction_relations", {}) is Dictionary else {}
	relations[key] = relation
	player_state["faction_relations"] = relations
	host.set("_player_state", player_state)
	host.call("_sync_diplomacy_action_mirror_state_from_relations")
	return {"status": STATUS_RESOLVED, "result": {"success": true, "action_id": str(request.get("action_id", "")), "source_faction_id": source_faction_id, "target_faction_id": target_faction_id, "before_score": int(relation_result.get("before_score", 0)), "after_score": int(relation_result.get("after_score", 0)), "cooldown": int(fixed.get("cooldown", 0)), "message": "AI 외교 요청을 처리했습니다."}}


static func _invalid_reason(host: Object, request: Dictionary) -> String:
	var target_faction_id := str(request.get("target_faction_id", ""))
	var source_faction_id := str(request.get("source_faction_id", ""))
	var player_state := _player_state(host)
	var defeated: Dictionary = player_state.get("defeated_factions", {}) if player_state.get("defeated_factions", {}) is Dictionary else {}
	if defeated.has(target_faction_id) or defeated.has(source_faction_id):
		return "target_gone"
	var key := str(host.call("_make_faction_relation_key", source_faction_id, target_faction_id))
	var relations: Dictionary = player_state.get("faction_relations", {}) if player_state.get("faction_relations", {}) is Dictionary else {}
	if not relations.has(key):
		return "relation_missing"
	var target_city_id := str(request.get("target_city_id", ""))
	if not target_city_id.is_empty() and str(host.call("_get_city_owner_faction_id_for_trade_display", target_city_id)) != target_faction_id:
		return "target_changed"
	return ""


## Queue 40 (P2): settle one manual external trade at the turn end with the latest stocks. Both cities must still
## belong to the factions of the submission, the partner must not be unclaimed, the two factions must still be able to
## trade (relation after this turn's diplomacy resolution), and the partner city must hold its whole side. Then, at
## once: the reservation -> partner city, the partner side -> source city. The fixed amounts are never re-priced.
## Anything missing -> nothing moves, the whole reservation goes back once.
static func _resolve_trade_request(host: Object, request: Dictionary, source_turn: int) -> Dictionary:
	var fixed: Dictionary = request.get("fixed_context", {}) if request.get("fixed_context", {}) is Dictionary else {}
	var source_city_id := str(fixed.get("source_city_id", ""))
	var target_city_id := str(fixed.get("target_city_id", request.get("target_city_id", "")))
	var source_faction_id := str(request.get("source_faction_id", ""))
	var target_faction_id := str(request.get("target_faction_id", ""))
	var reason := ""
	var target_owner := str(host.call("_get_city_owner_faction_id_for_trade_display", target_city_id))
	var defeated: Dictionary = _player_state(host).get("defeated_factions", {}) if _player_state(host).get("defeated_factions", {}) is Dictionary else {}
	if str(host.call("_get_city_owner_faction_id_for_trade_display", source_city_id)) != source_faction_id:
		reason = "source_changed"
	elif WorldMapUnclaimedCityRules.is_unclaimed_owner(target_owner):
		reason = WorldMapUnclaimedCityRules.REJECT_REASON
	elif target_owner != target_faction_id:
		reason = "target_changed"
	elif defeated.has(target_faction_id) or defeated.has(source_faction_id):
		reason = "target_gone"
	elif not bool(host.call("_can_trade_between_factions", source_faction_id, target_faction_id)):
		reason = "relation"
	var pay: Dictionary = fixed.get("pay", {})
	var receive: Dictionary = fixed.get("receive", {})
	var partner: Dictionary = (host.call("_get_city_storage", target_city_id) as Dictionary).duplicate(true) if reason.is_empty() else {}
	if reason.is_empty():
		for resource_id in receive:
			if int(partner.get(resource_id, 0)) < int(receive[resource_id]):
				reason = "partner_shortage"
				break
	if not reason.is_empty():
		return _invalidate(host, request, reason)
	for resource_id in receive:
		partner[resource_id] = int(partner.get(resource_id, 0)) - int(receive[resource_id])
	for resource_id in pay:
		partner[resource_id] = int(partner.get(resource_id, 0)) + int(pay[resource_id])
	host.call("_set_city_storage", target_city_id, partner)
	var source: Dictionary = (host.call("_get_city_storage", source_city_id) as Dictionary).duplicate(true)
	for resource_id in receive:
		source[resource_id] = int(source.get(resource_id, 0)) + int(receive[resource_id])
	host.call("_set_city_storage", source_city_id, source)
	return {"status": STATUS_RESOLVED, "result": {
		"success": true,
		"completed": true,
		"request_id": str(request.get("request_id", "")),
		"action_id": TRADE_ACTION_ID,
		"source_city_id": source_city_id,
		"target_city_id": target_city_id,
		"target_faction_id": target_faction_id,
		"paid": pay.duplicate(true),
		"received": receive.duplicate(true),
		"resolved_turn": source_turn,
		"message": "수동 무역이 성사되었습니다.",
	}}


static func _invalidate(host: Object, request: Dictionary, reason: String, detail: Dictionary = {}) -> Dictionary:
	var refunded := {}
	var unrefunded := {}
	if REFUND_ON_INVALID:
		refunded = _refund(host, request.get("reserved_assets", {}), str(request.get("source_faction_id", "")), unrefunded)
	var is_trade := str(request.get("domain", DOMAIN_DIPLOMACY)) == DOMAIN_TRADE
	var label := "수동 무역" if is_trade else str(DiplomacyActionServiceScript.get_action_definition(str(request.get("action_id", ""))).get("label", request.get("action_id", "")))
	var result := {
		"success": false,
		"invalid": true,
		"reason": reason,
		"action_id": str(request.get("action_id", "")),
		"target_faction_id": str(request.get("target_faction_id", "")),
		"refunded": refunded,
		"message": "%s 요청이 무효가 되어 예약한 비용을 돌려받았습니다." % label,
	}
	if not detail.is_empty():
		result["detail"] = detail.duplicate(true)
	if not unrefunded.is_empty():
		result["unrefunded"] = unrefunded.duplicate(true)
		result["message"] = "%s 요청이 무효가 되었고, 돌려받을 도시가 없어 예약한 비용을 보류했습니다." % label
		print("[STRATEGY_REFUND_HELD] request=%s source=%s unrefunded=%s" % [str(request.get("request_id", "")), str(request.get("source_faction_id", "")), str(unrefunded)])
		return {"status": STATUS_HELD, "result": result, "unrefunded": unrefunded}
	return {"status": STATUS_INVALID, "result": result}


# ---- ledger helpers ---------------------------------------------------------------------------------------------

static func get_pending_requests(host: Object) -> Array:
	var pending: Array = []
	var ledger := _ledger(host)
	var ids := ledger.keys()
	ids.sort()
	for request_id in ids:
		var request: Dictionary = ledger[request_id]
		if str(request.get("status", "")) == STATUS_PENDING:
			pending.append(request.duplicate(true))
	return pending


static func _pending_count(host: Object, source_faction_id: String, target_faction_id: String, domain: String) -> int:
	var count := 0
	for request in get_pending_requests(host):
		if str(request.get("domain", "")) == domain and str(request.get("source_faction_id", "")) == source_faction_id and str(request.get("target_faction_id", "")) == target_faction_id:
			count += 1
	return count


static func _new_request(host: Object, turn: int, domain: String, action_id: String, source_faction_id: String, target_faction_id: String, target_city_id: String) -> Dictionary:
	var player_state := _player_state(host)
	var sequence := maxi(0, int(player_state.get(SEQUENCE_KEY, 0))) + 1
	player_state[SEQUENCE_KEY] = sequence
	host.set("_player_state", player_state)
	return {
		"request_id": "sr_%05d_%06d" % [turn, sequence],
		"domain": domain,
		"action_id": action_id,
		"source_faction_id": source_faction_id,
		"target_faction_id": target_faction_id,
		"target_city_id": target_city_id,
		"submitted_turn": turn,
		"resolve_turn": turn + RESOLVE_DELAY_TURNS,
		"status": STATUS_PENDING,
		"reserved_assets": {},
		"fixed_context": {},
		"applied_transaction_id": "",
		"result": {},
	}


static func _store_request(host: Object, request: Dictionary) -> void:
	var ledger := _ledger(host)
	ledger[str(request.get("request_id", ""))] = request.duplicate(true)
	_set_ledger(host, ledger)


static func _ledger(host: Object) -> Dictionary:
	var raw: Variant = _player_state(host).get(LEDGER_KEY, {})
	return (raw as Dictionary).duplicate(true) if raw is Dictionary else {}


static func _set_ledger(host: Object, ledger: Dictionary) -> void:
	var player_state := _player_state(host)
	player_state[LEDGER_KEY] = ledger.duplicate(true)
	host.set("_player_state", player_state)


static func _player_state(host: Object) -> Dictionary:
	var raw: Variant = host.get("_player_state")
	return raw if raw is Dictionary else {}


static func _set_last_result(host: Object, result: Dictionary) -> void:
	var player_state := _player_state(host)
	player_state["last_diplomacy_action_result"] = result.duplicate(true)
	host.set("_player_state", player_state)
	host.set("_save_management_status", str(result.get("message", "")))


static func _store_submit_failure(host: Object, result: Dictionary) -> Dictionary:
	_set_last_result(host, result)
	return result


static func _failure(turn: int, action_id: String, validation: Dictionary, reason: String, message: String) -> Dictionary:
	return {
		"turn": turn,
		"action_id": action_id,
		"action_label": str(DiplomacyActionServiceScript.get_action_definition(action_id).get("label", action_id)),
		"target_city_id": str(validation.get("target_city_id", "")),
		"target_faction_id": str(validation.get("target_faction_id", "")),
		"success": false,
		"reason": reason,
		"message": message,
	}


# ---- stock helpers (P0 ledger: cities only) ---------------------------------------------------------------------

static func _player_payment_city_stocks(host: Object) -> Dictionary:
	var stocks := {}
	for city_id in host.call("_get_national_payment_city_ids_mvp"):
		stocks[str(city_id)] = (host.call("_get_city_storage", str(city_id)) as Dictionary).duplicate(true)
	return stocks


static func _stock_decrease(before: Dictionary, after: Dictionary) -> Dictionary:
	var taken := {}
	for city_id in before:
		var city_taken := {}
		for resource_id in RESOURCE_IDS:
			var amount := int((before[city_id] as Dictionary).get(resource_id, 0)) - int((after.get(city_id, {}) as Dictionary).get(resource_id, 0))
			if amount > 0:
				city_taken[resource_id] = amount
		if not city_taken.is_empty():
			taken[city_id] = city_taken
	return taken


static func _covers(reserved: Dictionary, cost: Dictionary) -> bool:
	var totals := {}
	for city_id in reserved:
		for resource_id in reserved[city_id]:
			totals[resource_id] = int(totals.get(resource_id, 0)) + int(reserved[city_id][resource_id])
	for resource_id in cost:
		if str(resource_id) == "food":
			var food := int(totals.get("rice", 0)) + int(totals.get("barley", 0)) + int(totals.get("seafood", 0))
			if food < int(cost[resource_id]):
				return false
		elif int(totals.get(str(resource_id), 0)) < int(cost[resource_id]):
			return false
	return true


## Gives a reservation back once: to the city it came from, or, when that city no longer belongs to the source
## faction, to the source faction's first payment city (the player's capital). Queue 40: when neither exists the amount
## goes into `held` (per original city) instead of being skipped — never to the occupier, partner or a national pool.
static func _refund(host: Object, reserved_variant: Variant, source_faction_id: String, held: Dictionary = {}) -> Dictionary:
	var refunded := {}
	if not reserved_variant is Dictionary:
		return refunded
	var reserved: Dictionary = reserved_variant
	var player_faction_id := str(host.call("_get_current_player_faction_id"))
	var fallback := ""
	if source_faction_id == player_faction_id:
		var payment_ids: Array = host.call("_get_national_payment_city_ids_mvp")
		fallback = str(payment_ids[0]) if not payment_ids.is_empty() else ""
	else:
		var own := _faction_city_ids(host, source_faction_id)
		fallback = str(own[0]) if not own.is_empty() else ""
	for city_id_variant in reserved:
		var city_id := str(city_id_variant)
		var destination := city_id if str(host.call("_get_city_owner_faction_id_for_trade_display", city_id)) == source_faction_id else fallback
		if destination.is_empty():
			held[city_id] = (reserved[city_id_variant] as Dictionary).duplicate(true)
			continue
		var stock: Dictionary = (host.call("_get_city_storage", destination) as Dictionary).duplicate(true)
		for resource_id in reserved[city_id_variant]:
			stock[str(resource_id)] = int(stock.get(str(resource_id), 0)) + int(reserved[city_id_variant][resource_id])
		host.call("_set_city_storage", destination, stock)
		var into: Dictionary = refunded.get(destination, {})
		for resource_id in reserved[city_id_variant]:
			into[str(resource_id)] = int(into.get(str(resource_id), 0)) + int(reserved[city_id_variant][resource_id])
		refunded[destination] = into
	return refunded


static func _drop_zero(amounts: Dictionary) -> void:
	for resource_id in amounts.keys():
		if int(amounts[resource_id]) <= 0:
			amounts.erase(resource_id)


static func _faction_city_ids(host: Object, faction_id: String) -> Array[String]:
	var ids: Array[String] = []
	var cities: Dictionary = host.get("CITY_HUD_DATA")
	for city_id in cities.keys():
		if str(host.call("_get_city_owner_faction_id_for_trade_display", str(city_id))) == faction_id:
			ids.append(str(city_id))
	ids.sort()
	return ids


## All or nothing, out of the faction's cities in city id order.
static func _reserve_from_faction_cities(host: Object, faction_id: String, cost: Dictionary) -> Dictionary:
	var city_ids := _faction_city_ids(host, faction_id)
	var stocks := {}
	for city_id in city_ids:
		stocks[city_id] = (host.call("_get_city_storage", city_id) as Dictionary).duplicate(true)
	var plan := {}
	for resource_id_variant in cost:
		var resource_id := str(resource_id_variant)
		var remaining := maxi(0, int(cost[resource_id_variant]))
		for city_id in city_ids:
			var available := int((stocks[city_id] as Dictionary).get(resource_id, 0)) - int((plan.get(city_id, {}) as Dictionary).get(resource_id, 0))
			var take := mini(maxi(0, available), remaining)
			if take > 0:
				var city_plan: Dictionary = plan.get(city_id, {})
				city_plan[resource_id] = int(city_plan.get(resource_id, 0)) + take
				plan[city_id] = city_plan
				remaining -= take
			if remaining <= 0:
				break
		if remaining > 0:
			return {}
	for city_id in plan:
		var stock: Dictionary = stocks[city_id]
		for resource_id in plan[city_id]:
			stock[resource_id] = int(stock.get(resource_id, 0)) - int(plan[city_id][resource_id])
		host.call("_set_city_storage", city_id, stock)
	return plan
