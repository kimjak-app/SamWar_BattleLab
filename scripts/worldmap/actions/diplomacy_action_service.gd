class_name WorldMapDiplomacyActionService
extends RefCounted

const RELATION_STATUS_NEUTRAL := "neutral"
const RELATION_STATUS_ALLIED := "allied"
const RELATION_STATUS_HOSTILE := "hostile"
const RELATION_STATUS_SUSPENDED := "suspended"
const DEFAULT_RELATION_SCORE := 50
const RELATION_SCORE_MIN := 0
const RELATION_SCORE_MAX := 100
const ACTION_ENVOY := "envoy"
const ACTION_TRIBUTE := "tribute"
const ACTION_TRADE_AGREEMENT := "trade_agreement"
const ACTION_RESTORE_RELATIONS := "restore_relations"
const ACTION_ALLIANCE_PROPOSAL := "alliance_proposal"
const TRADE_AGREEMENT_MULTIPLIER_BONUS := 0.15
const ACTION_TRADE_AGREEMENT_TURNS := 6
const ACTION_ALLIANCE_TURNS := 8
const ACTION_ALLIANCE_COST := {"gold": 200, "silk": 50}
const ALLIANCE_ACCEPTANCE_THRESHOLD := 70
const LEGACY_TRADE_AGREEMENT_SCORE_REQUIREMENT := 50
const LEGACY_TRADE_AGREEMENT_TURNS := 20
const LEGACY_TRADE_AGREEMENT_COST := {"gold": 200, "silk": 50}


func execute(
	host: Object,
	action_id: String,
	target_city_id: String,
	_source_city_id: String = ""
) -> Dictionary:
	if host == null:
		return _failure("executor_unavailable", "외교 행동 실행기를 찾을 수 없습니다.")
	for method_name in [
		"_get_current_player_faction_id",
		"_build_diplomacy_action_validation_context",
		"_make_faction_relation_key",
		"_ensure_faction_relation_entry",
		"_normalize_faction_relation_status",
		"_sync_diplomacy_action_mirror_state_from_relations",
	]:
		if not host.has_method(method_name):
			return _failure("executor_unavailable", "외교 행동 처리기를 찾을 수 없습니다: %s" % method_name)

	var context_variant: Variant = host.call("_build_diplomacy_action_validation_context", action_id, target_city_id)
	if not context_variant is Dictionary:
		return _failure("invalid_validation", "외교 행동 조건을 확인할 수 없습니다.")
	var validation := validate_action(action_id, context_variant as Dictionary)
	if not bool(validation.get("ok", false)):
		var current_turn := maxi(1, int(_get_player_state(host).get("turn_number", 1)))
		var failure_result := build_failure_result(current_turn, action_id, validation)
		_store_last_result(host, failure_result)
		_set_status(host, failure_result)
		return failure_result

	var player_faction_id := str(host.call("_get_current_player_faction_id"))
	var definition_variant: Variant = validation.get("definition", {})
	var definition: Dictionary = definition_variant if definition_variant is Dictionary else {}
	var target_faction_id := str(validation.get("target_faction_id", ""))
	var cost_variant: Variant = validation.get("cost", {})
	var cost: Dictionary = cost_variant if cost_variant is Dictionary else {}
	var payment_result := apply_diplomacy_resource_cost(host, cost)
	if action_id == ACTION_ALLIANCE_PROPOSAL:
		var prepaid_validation := validation.duplicate(true)
		prepaid_validation["payment"] = payment_result
		var alliance_result := apply_alliance_action(host, prepaid_validation)
		_set_status(host, alliance_result)
		return alliance_result
	var before_score := int(validation.get("before_score", DEFAULT_RELATION_SCORE))
	var before_status := str(validation.get("before_status", RELATION_STATUS_NEUTRAL))
	var relation_delta := int(validation.get("relation_delta", 0))
	var relation_result := apply_diplomacy_relation_delta(
		host,
		player_faction_id,
		target_faction_id,
		relation_delta,
		"diplomacy_action_%s" % action_id
	)
	var after_score := int(relation_result.get("after_score", before_score))
	set_diplomacy_action_cooldown(host, target_faction_id, int(validation.get("cooldown", 0)), false)
	var agreement_payload := {}
	if action_id == ACTION_TRADE_AGREEMENT:
		var agreement_turns := maxi(1, int(definition.get("agreement_turns", 1)))
		agreement_payload = apply_trade_agreement_state(host, target_faction_id, agreement_turns, cost, payment_result, after_score)
	var player_state := _get_player_state(host)
	var relation_entry := _get_relation_entry(host, player_faction_id, target_faction_id)
	var after_status_variant: Variant = host.call(
		"_normalize_faction_relation_status",
		str(relation_entry.get("status", RELATION_STATUS_NEUTRAL))
	)
	var result := {
		"turn": maxi(1, int(player_state.get("turn_number", 1))),
		"action_id": action_id,
		"action_label": str(validation.get("action_label", action_id)),
		"target_city_id": str(validation.get("target_city_id", "")),
		"target_faction_id": target_faction_id,
		"cost": cost,
		"payment": payment_result,
		"relation_delta": after_score - before_score,
		"before_score": before_score,
		"after_score": after_score,
		"before_status": before_status,
		"after_status": str(after_status_variant),
		"cooldown": int(validation.get("cooldown", 0)),
		"success": true,
		"message": str(validation.get("message", "외교 행동을 실행했습니다.")),
	}
	if not agreement_payload.is_empty():
		result["agreement"] = agreement_payload
	host.call("_sync_diplomacy_action_mirror_state_from_relations")
	_store_last_result(host, result)
	_set_status(host, result)
	return result


static func get_action_definition(action_id: String) -> Dictionary:
	match action_id:
		ACTION_ENVOY:
			return {"action_id": action_id, "label": "사절 파견", "cost": {"gold": 30}, "relation_delta": 5, "cooldown": 1, "message": "사절을 파견했습니다."}
		ACTION_TRIBUTE:
			return {"action_id": action_id, "label": "조공", "cost": {"gold": 100}, "relation_delta": 12, "cooldown": 2, "message": "조공을 보냈습니다."}
		ACTION_TRADE_AGREEMENT:
			return {"action_id": action_id, "label": "교역 협정", "cost": {"gold": 80}, "relation_delta": 4, "cooldown": 2, "agreement_turns": ACTION_TRADE_AGREEMENT_TURNS, "message": "교역 협정을 체결했습니다."}
		ACTION_RESTORE_RELATIONS:
			return {"action_id": action_id, "label": "관계 회복", "cost": {"gold": 120}, "relation_delta": 18, "cooldown": 3, "message": "관계 회복 협의를 진행했습니다."}
		ACTION_ALLIANCE_PROPOSAL:
			return {"action_id": action_id, "label": "동맹 제안", "cost": ACTION_ALLIANCE_COST.duplicate(true), "relation_delta": 0, "cooldown": 4, "alliance_turns": ACTION_ALLIANCE_TURNS, "message": "동맹을 제안했습니다."}
	return {}


static func validate_action(action_id: String, context: Dictionary) -> Dictionary:
	var definition_variant: Variant = context.get("definition", {})
	var definition: Dictionary = definition_variant if definition_variant is Dictionary else {}
	if definition.is_empty():
		return {"ok": false, "reason": "invalid_action", "message": "외교 행동을 확인할 수 없습니다."}
	var target_error_variant: Variant = context.get("target_error", {})
	if target_error_variant is Dictionary and not (target_error_variant as Dictionary).is_empty():
		var target_error := target_error_variant as Dictionary
		return {"ok": false, "reason": str(target_error.get("reason", "invalid_target")), "message": str(target_error.get("message", "외교 대상을 선택해야 합니다.")), "action_id": action_id}
	var resolved_city_id := str(context.get("target_city_id", ""))
	var target_faction_id := str(context.get("target_faction_id", ""))
	if resolved_city_id.is_empty() or target_faction_id.is_empty():
		return {"ok": false, "reason": "invalid_target", "message": "외교 대상을 확인할 수 없습니다.", "action_id": action_id, "target_city_id": resolved_city_id}
	if target_faction_id == str(context.get("player_faction_id", "")):
		return {"ok": false, "reason": "player_faction", "message": "자국 도시는 외교 대상이 아닙니다.", "action_id": action_id, "target_city_id": resolved_city_id, "target_faction_id": target_faction_id}
	var status := str(context.get("status", RELATION_STATUS_NEUTRAL))
	var score := int(context.get("score", DEFAULT_RELATION_SCORE))
	var action_cooldown := maxi(0, int(context.get("cooldown", 0)))
	if action_cooldown > 0:
		return {"ok": false, "reason": "cooldown", "message": "외교 사절단이 아직 복귀하지 않았습니다.", "cooldown": action_cooldown, "action_id": action_id, "target_city_id": resolved_city_id, "target_faction_id": target_faction_id}
	if action_id == ACTION_TRADE_AGREEMENT:
		if status == RELATION_STATUS_HOSTILE or status == RELATION_STATUS_SUSPENDED:
			return {"ok": false, "reason": "blocked_relation", "message": "적대 또는 교역 중단 상태에서는 교역 협정을 체결할 수 없습니다.", "status": status, "action_id": action_id, "target_city_id": resolved_city_id, "target_faction_id": target_faction_id}
		if score < 45:
			return {"ok": false, "reason": "relation_score", "message": "관계 점수 45 이상이 필요합니다.", "score": score, "required_score": 45, "action_id": action_id, "target_city_id": resolved_city_id, "target_faction_id": target_faction_id}
	if action_id == ACTION_RESTORE_RELATIONS and status != RELATION_STATUS_HOSTILE and status != RELATION_STATUS_SUSPENDED:
		return {"ok": false, "reason": "not_needed", "message": "관계 회복은 적대 또는 교역 중단 상태에서만 진행할 수 있습니다.", "status": status, "action_id": action_id, "target_city_id": resolved_city_id, "target_faction_id": target_faction_id}
	if action_id == ACTION_ALLIANCE_PROPOSAL:
		if status == RELATION_STATUS_HOSTILE or status == RELATION_STATUS_SUSPENDED:
			return {"ok": false, "reason": "blocked_relation", "message": "적대 또는 교역 중단 상태에서는 동맹을 제안할 수 없습니다.", "status": status, "action_id": action_id, "target_city_id": resolved_city_id, "target_faction_id": target_faction_id}
		var active_alliance_turns := maxi(0, int(context.get("active_alliance_turns", 0)))
		if status == RELATION_STATUS_ALLIED and active_alliance_turns > 0:
			return {"ok": false, "reason": "already_allied", "message": "이미 동맹 관계입니다.", "status": status, "alliance_turns": active_alliance_turns, "action_id": action_id, "target_city_id": resolved_city_id, "target_faction_id": target_faction_id}
	var cost_variant: Variant = context.get("cost", {})
	var cost: Dictionary = cost_variant if cost_variant is Dictionary else {}
	var payment_check_variant: Variant = context.get("payment_check", {})
	var payment_check: Dictionary = payment_check_variant if payment_check_variant is Dictionary else {}
	if not bool(payment_check.get("ok", false)):
		return {"ok": false, "reason": "resources", "message": "자원이 부족합니다.", "cost": cost, "missing": payment_check.get("missing", {}), "action_id": action_id, "target_city_id": resolved_city_id, "target_faction_id": target_faction_id}
	var result := {
		"ok": true,
		"action_id": action_id,
		"action_label": str(definition.get("label", action_id)),
		"definition": definition,
		"target_city_id": resolved_city_id,
		"target_faction_id": target_faction_id,
		"cost": cost,
		"relation_delta": int(context.get("relation_delta", definition.get("relation_delta", 0))),
		"cooldown": maxi(0, int(definition.get("cooldown", 0))),
		"before_score": score,
		"before_status": status,
		"message": str(definition.get("message", "")),
	}
	if action_id == ACTION_ALLIANCE_PROPOSAL:
		result["alliance_turns"] = maxi(1, int(context.get("alliance_turns", definition.get("alliance_turns", ACTION_ALLIANCE_TURNS))))
		result["acceptance_score"] = int(context.get("acceptance_score", 0))
		result["required_score"] = ALLIANCE_ACCEPTANCE_THRESHOLD
	return result


static func build_failure_result(current_turn: int, action_id: String, validation: Dictionary) -> Dictionary:
	var result := {
		"turn": maxi(1, current_turn),
		"action_id": action_id,
		"action_label": str(get_action_definition(action_id).get("label", action_id)),
		"target_city_id": str(validation.get("target_city_id", "")),
		"target_faction_id": str(validation.get("target_faction_id", "")),
		"success": false,
		"reason": str(validation.get("reason", "unknown")),
		"message": str(validation.get("message", "외교 행동을 실행하지 못했습니다.")),
	}
	if validation.has("cost"):
		result["cost"] = validation.get("cost", {})
	if validation.has("missing"):
		result["missing"] = validation.get("missing", {})
	if validation.has("cooldown"):
		result["cooldown"] = int(validation.get("cooldown", 0))
	return result


static func normalize_resource_package(resource_package: Dictionary) -> Dictionary:
	var normalized := {}
	for resource_id_variant in resource_package.keys():
		var resource_id := str(resource_id_variant)
		var amount := maxi(0, int(resource_package.get(resource_id_variant, 0)))
		if amount > 0:
			normalized[resource_id] = amount
	return normalized


static func normalize_diplomacy_relation_entry(source_entry: Dictionary) -> Dictionary:
	var entry := source_entry.duplicate(true)
	entry["tribute_cooldown"] = maxi(0, int(entry.get("tribute_cooldown", 0)))
	entry["diplomacy_action_cooldown"] = maxi(0, int(entry.get("diplomacy_action_cooldown", 0)))
	entry["alliance_turns_remaining"] = maxi(0, int(entry.get("alliance_turns_remaining", 0)))
	if str(entry.get("status", RELATION_STATUS_NEUTRAL)) == RELATION_STATUS_ALLIED and int(entry.get("alliance_turns_remaining", 0)) <= 0:
		entry["status"] = RELATION_STATUS_NEUTRAL
		entry.erase("alliance_created_turn")
		entry.erase("alliance_resource_package")
		entry.erase("alliance_acceptance_score")
	entry["trade_agreement_turns_remaining"] = maxi(0, int(entry.get("trade_agreement_turns_remaining", 0)))
	entry["trade_agreement_active"] = bool(entry.get("trade_agreement_active", false)) and int(entry.get("trade_agreement_turns_remaining", 0)) > 0
	entry["trade_agreement_bonus"] = TRADE_AGREEMENT_MULTIPLIER_BONUS if bool(entry.get("trade_agreement_active", false)) else 0.0
	if bool(entry.get("trade_agreement_active", false)):
		entry["trade_agreement_source"] = str(entry.get("trade_agreement_source", "legacy"))
	else:
		entry.erase("trade_agreement_source")
	return entry


func calculate_alliance_acceptance_chance(host: Object, target_faction_id: String, resource_package: Dictionary, duration_turns: int) -> int:
	var player_faction_id := str(host.call("_get_current_player_faction_id"))
	if target_faction_id.is_empty() or target_faction_id == player_faction_id:
		return 0
	var relation := _get_relation_entry(host, player_faction_id, target_faction_id)
	var score := clampi(int(relation.get("score", DEFAULT_RELATION_SCORE)), RELATION_SCORE_MIN, RELATION_SCORE_MAX)
	var package := normalize_resource_package(resource_package)
	var package_bonus := int(floor(float(package.get("gold", 0)) / 20.0)) + int(floor(float(package.get("silk", 0)) / 10.0))
	var duration_penalty := maxi(0, duration_turns - LEGACY_TRADE_AGREEMENT_TURNS)
	var base_chance := score + package_bonus - duration_penalty
	return int(host.call("_get_modified_diplomacy_success_chance_mvp", base_chance, ACTION_ALLIANCE_PROPOSAL, target_faction_id))


func propose_alliance(host: Object, target_faction_id: String, resource_package: Dictionary, duration_turns: int, prepaid_payment: Dictionary = {}) -> bool:
	var player_state := _get_player_state(host)
	var turn_number := maxi(1, int(player_state.get("turn_number", 1)))
	var player_faction_id := str(host.call("_get_current_player_faction_id"))
	var package := normalize_resource_package(resource_package)
	if target_faction_id.is_empty() or target_faction_id == player_faction_id:
		player_state["last_alliance_proposal_result"] = {"turn": turn_number, "target_faction_id": target_faction_id, "success": false, "accepted": false, "reason": "invalid_target", "resource_package": package, "message": "동맹 대상을 확인할 수 없습니다."}
		host.set("_player_state", player_state)
		return false
	var relation := _get_relation_entry(host, player_faction_id, target_faction_id)
	var status := str(host.call("_normalize_faction_relation_status", str(relation.get("status", RELATION_STATUS_NEUTRAL))))
	var before_score := clampi(int(relation.get("score", DEFAULT_RELATION_SCORE)), RELATION_SCORE_MIN, RELATION_SCORE_MAX)
	if status == RELATION_STATUS_HOSTILE or status == RELATION_STATUS_SUSPENDED:
		player_state["last_alliance_proposal_result"] = {"turn": turn_number, "target_faction_id": target_faction_id, "success": false, "accepted": false, "reason": status, "status": status, "before_status": status, "after_status": status, "before_score": before_score, "after_score": before_score, "resource_package": package, "message": "적대 또는 교역 중단 상태에서는 동맹을 제안할 수 없습니다."}
		host.set("_player_state", player_state)
		return false
	if duration_turns <= 0:
		player_state["last_alliance_proposal_result"] = {"turn": turn_number, "target_faction_id": target_faction_id, "success": false, "accepted": false, "reason": "duration", "status": status, "before_status": status, "after_status": status, "before_score": before_score, "after_score": before_score, "resource_package": package, "message": "동맹 기간을 확인할 수 없습니다."}
		host.set("_player_state", player_state)
		return false
	var payment_check := can_pay_diplomacy_resource_cost(host, package)
	if prepaid_payment.is_empty() and not bool(payment_check.get("ok", false)):
		player_state["last_alliance_proposal_result"] = {"turn": turn_number, "target_faction_id": target_faction_id, "success": false, "accepted": false, "reason": "resources", "status": status, "before_status": status, "after_status": status, "before_score": before_score, "after_score": before_score, "resource_package": package, "missing": payment_check.get("missing", {}), "message": "자원이 부족합니다."}
		host.set("_player_state", player_state)
		return false
	var payment_result := prepaid_payment if not prepaid_payment.is_empty() else apply_diplomacy_resource_cost(host, package)
	var acceptance_chance := calculate_alliance_acceptance_chance(host, target_faction_id, package, duration_turns)
	var accepted := acceptance_chance >= ALLIANCE_ACCEPTANCE_THRESHOLD
	if accepted:
		var updated_relation := _get_relation_entry(host, player_faction_id, target_faction_id)
		updated_relation["status"] = RELATION_STATUS_ALLIED
		updated_relation["alliance_turns_remaining"] = duration_turns
		updated_relation["alliance_created_turn"] = turn_number
		updated_relation["alliance_resource_package"] = package.duplicate(true)
		updated_relation["alliance_acceptance_score"] = acceptance_chance
		updated_relation["military_support_rejection_count"] = 0
		_store_relation_entry(host, player_faction_id, target_faction_id, updated_relation)
	var after_status := RELATION_STATUS_ALLIED if accepted else status
	player_state = _get_player_state(host)
	player_state["last_alliance_proposal_result"] = {
		"turn": turn_number,
		"target_faction_id": target_faction_id,
		"resource_package": package,
		"cost": package,
		"payment": payment_result,
		"acceptance_chance": acceptance_chance,
		"acceptance_score": acceptance_chance,
		"acceptance_threshold": ALLIANCE_ACCEPTANCE_THRESHOLD,
		"required_score": ALLIANCE_ACCEPTANCE_THRESHOLD,
		"accepted": accepted,
		"success": accepted,
		"reason": "" if accepted else "rejected",
		"status": after_status,
		"before_status": status,
		"after_status": after_status,
		"before_score": before_score,
		"after_score": before_score,
		"duration_turns": duration_turns if accepted else 0,
		"alliance_turns_remaining": duration_turns if accepted else 0,
		"created_turn": turn_number if accepted else 0,
		"message": "동맹을 체결했습니다." if accepted else "동맹 제안이 거절되었습니다.",
	}
	host.set("_player_state", player_state)
	return accepted


func apply_alliance_action(host: Object, validation: Dictionary) -> Dictionary:
	var target_faction_id := str(validation.get("target_faction_id", ""))
	var package_variant: Variant = validation.get("cost", {})
	var package: Dictionary = package_variant if package_variant is Dictionary else {}
	var alliance_turns := maxi(1, int(validation.get("alliance_turns", ACTION_ALLIANCE_TURNS)))
	var payment_variant: Variant = validation.get("payment", {})
	var payment: Dictionary = payment_variant if payment_variant is Dictionary else {}
	propose_alliance(host, target_faction_id, package, alliance_turns, payment)
	set_diplomacy_action_cooldown(host, target_faction_id, maxi(0, int(validation.get("cooldown", 0))), false)
	var result_variant: Variant = _get_player_state(host).get("last_alliance_proposal_result", {})
	var result := (result_variant as Dictionary).duplicate(true) if result_variant is Dictionary else {}
	if result.is_empty():
		result = build_failure_result(maxi(1, int(_get_player_state(host).get("turn_number", 1))), ACTION_ALLIANCE_PROPOSAL, {"reason": "unknown", "message": "동맹 제안 결과를 확인할 수 없습니다.", "target_faction_id": target_faction_id, "cost": package})
	result["action_id"] = ACTION_ALLIANCE_PROPOSAL
	result["action_label"] = str(validation.get("action_label", "동맹 제안"))
	result["target_city_id"] = str(validation.get("target_city_id", ""))
	result["cooldown"] = maxi(0, int(validation.get("cooldown", 0)))
	result["before_score"] = int(validation.get("before_score", result.get("before_score", DEFAULT_RELATION_SCORE)))
	result["before_status"] = str(validation.get("before_status", result.get("before_status", RELATION_STATUS_NEUTRAL)))
	result["after_score"] = int(result.get("after_score", result.get("before_score", DEFAULT_RELATION_SCORE)))
	result["after_status"] = str(result.get("after_status", result.get("status", validation.get("before_status", RELATION_STATUS_NEUTRAL))))
	if bool(result.get("accepted", false)):
		result["message"] = "동맹을 체결했습니다."
	else:
		result["message"] = "동맹 제안이 거절되었습니다." if str(result.get("reason", "")) == "rejected" else str(result.get("message", "동맹 제안을 실행하지 못했습니다."))
	sync_diplomacy_mirror_state(host)
	sync_alliance_mirror_state(host)
	_store_last_result(host, result)
	return result


func get_diplomacy_action_cooldown(host: Object, target_faction_id: String) -> int:
	var player_faction_id := str(host.call("_get_current_player_faction_id"))
	if target_faction_id.is_empty() or target_faction_id == player_faction_id:
		return 0
	var relation_entry := _get_relation_entry(host, player_faction_id, target_faction_id)
	var relation_cooldown := maxi(0, int(relation_entry.get("diplomacy_action_cooldown", 0)))
	var player_state := _get_player_state(host)
	var cooldowns_variant: Variant = player_state.get("diplomacy_action_cooldowns", {})
	if cooldowns_variant is Dictionary:
		relation_cooldown = maxi(relation_cooldown, maxi(0, int((cooldowns_variant as Dictionary).get(target_faction_id, 0))))
	return relation_cooldown


func set_diplomacy_action_cooldown(host: Object, target_faction_id: String, turns: int, sync_mirror: bool = true) -> void:
	var player_faction_id := str(host.call("_get_current_player_faction_id"))
	if target_faction_id.is_empty() or target_faction_id == player_faction_id:
		return
	var relation_entry := _get_relation_entry(host, player_faction_id, target_faction_id)
	relation_entry["diplomacy_action_cooldown"] = maxi(0, turns)
	_store_relation_entry(host, player_faction_id, target_faction_id, relation_entry)
	if sync_mirror:
		sync_diplomacy_mirror_state(host)


func apply_trade_agreement_state(
	host: Object,
	target_faction_id: String,
	agreement_turns: int,
	cost: Dictionary,
	payment_result: Dictionary,
	after_score: int
) -> Dictionary:
	var player_faction_id := str(host.call("_get_current_player_faction_id"))
	var current_turn := maxi(1, int(_get_player_state(host).get("turn_number", 1)))
	var relation_entry := _get_relation_entry(host, player_faction_id, target_faction_id)
	relation_entry["trade_agreement_active"] = true
	relation_entry["trade_agreement_turns_remaining"] = maxi(1, agreement_turns)
	relation_entry["trade_agreement_bonus"] = TRADE_AGREEMENT_MULTIPLIER_BONUS
	relation_entry["trade_agreement_source"] = "diplomacy_action"
	relation_entry["trade_agreement_created_turn"] = current_turn
	_store_relation_entry(host, player_faction_id, target_faction_id, relation_entry)
	var status := str(host.call("_normalize_faction_relation_status", str(relation_entry.get("status", RELATION_STATUS_NEUTRAL))))
	var player_state := _get_player_state(host)
	player_state["last_trade_agreement_result"] = {
		"turn": current_turn,
		"target_faction_id": target_faction_id,
		"success": true,
		"score": after_score,
		"status": status,
		"cost": cost,
		"payment": payment_result,
		"duration_turns": maxi(1, agreement_turns),
		"trade_multiplier_bonus": TRADE_AGREEMENT_MULTIPLIER_BONUS,
		"source": "diplomacy_action",
	}
	host.set("_player_state", player_state)
	return {
		"turns_remaining": maxi(1, agreement_turns),
		"source": "diplomacy_action",
		"created_turn": current_turn,
		"bonus": TRADE_AGREEMENT_MULTIPLIER_BONUS,
	}


static func advance_diplomacy_state_entry(relation_key: String, source_entry: Dictionary) -> Dictionary:
	var entry := source_entry.duplicate(true)
	var changed: Array = []
	var before_tribute_cooldown := maxi(0, int(entry.get("tribute_cooldown", 0)))
	if before_tribute_cooldown > 0:
		var after_tribute_cooldown := maxi(0, before_tribute_cooldown - 1)
		entry["tribute_cooldown"] = after_tribute_cooldown
		changed.append({"relation_key": relation_key, "type": "tribute_cooldown", "before": before_tribute_cooldown, "after": after_tribute_cooldown})
	var before_action_cooldown := maxi(0, int(entry.get("diplomacy_action_cooldown", 0)))
	if before_action_cooldown > 0:
		var after_action_cooldown := maxi(0, before_action_cooldown - 1)
		entry["diplomacy_action_cooldown"] = after_action_cooldown
		changed.append({"relation_key": relation_key, "type": "diplomacy_action_cooldown", "before": before_action_cooldown, "after": after_action_cooldown})
	var before_agreement_turns := maxi(0, int(entry.get("trade_agreement_turns_remaining", 0)))
	if bool(entry.get("trade_agreement_active", false)) and before_agreement_turns > 0:
		var after_agreement_turns := maxi(0, before_agreement_turns - 1)
		entry["trade_agreement_turns_remaining"] = after_agreement_turns
		if after_agreement_turns <= 0:
			entry["trade_agreement_active"] = false
			entry["trade_agreement_bonus"] = 0.0
			entry.erase("trade_agreement_source")
			entry.erase("trade_agreement_created_turn")
		changed.append({"relation_key": relation_key, "type": "trade_agreement", "before": before_agreement_turns, "after": after_agreement_turns})
	return {"entry": entry, "changed": changed}


static func advance_alliance_state_entry(relation_key: String, source_entry: Dictionary) -> Dictionary:
	var entry := source_entry.duplicate(true)
	var changed: Array = []
	var before_alliance_turns := maxi(0, int(entry.get("alliance_turns_remaining", 0)))
	var status := str(entry.get("status", RELATION_STATUS_NEUTRAL))
	if (status == RELATION_STATUS_ALLIED or status == "trade") and before_alliance_turns > 0:
		var after_alliance_turns := maxi(0, before_alliance_turns - 1)
		entry["alliance_turns_remaining"] = after_alliance_turns
		if after_alliance_turns <= 0:
			entry["status"] = RELATION_STATUS_NEUTRAL
			entry.erase("alliance_created_turn")
			entry.erase("alliance_resource_package")
			entry.erase("alliance_acceptance_score")
		changed.append({"relation_key": relation_key, "type": "alliance", "before": before_alliance_turns, "after": after_alliance_turns})
	return {"entry": entry, "changed": changed}


func sync_diplomacy_mirror_state(host: Object) -> void:
	var player_state := _get_player_state(host)
	var player_faction_id := str(host.call("_get_current_player_faction_id"))
	var cooldowns := {}
	var agreements := {}
	var relations_variant: Variant = player_state.get("faction_relations", {})
	if relations_variant is Dictionary:
		for relation_key_variant in (relations_variant as Dictionary).keys():
			var relation_key := str(relation_key_variant)
			var target_faction_id := _get_target_faction_from_relation_key(player_faction_id, relation_key)
			if target_faction_id.is_empty():
				continue
			var entry_variant: Variant = (relations_variant as Dictionary).get(relation_key_variant, {})
			if not entry_variant is Dictionary:
				continue
			var entry := entry_variant as Dictionary
			var cooldown_turns := maxi(0, int(entry.get("diplomacy_action_cooldown", 0)))
			if cooldown_turns > 0:
				cooldowns[target_faction_id] = cooldown_turns
			var agreement_turns := maxi(0, int(entry.get("trade_agreement_turns_remaining", 0)))
			if bool(entry.get("trade_agreement_active", false)) and agreement_turns > 0:
				agreements[target_faction_id] = {
					"turns_remaining": agreement_turns,
					"source": str(entry.get("trade_agreement_source", "diplomacy_action")),
					"created_turn": maxi(1, int(entry.get("trade_agreement_created_turn", player_state.get("turn_number", 1)))),
					"bonus": float(entry.get("trade_agreement_bonus", TRADE_AGREEMENT_MULTIPLIER_BONUS)),
				}
	player_state["diplomacy_action_cooldowns"] = cooldowns
	player_state["trade_agreements"] = agreements
	host.set("_player_state", player_state)


func sync_alliance_mirror_state(host: Object) -> void:
	var player_state := _get_player_state(host)
	var player_faction_id := str(host.call("_get_current_player_faction_id"))
	var alliances := {}
	var relations_variant: Variant = player_state.get("faction_relations", {})
	if relations_variant is Dictionary:
		for relation_key_variant in (relations_variant as Dictionary).keys():
			var relation_key := str(relation_key_variant)
			var target_faction_id := _get_target_faction_from_relation_key(player_faction_id, relation_key)
			if target_faction_id.is_empty():
				continue
			var entry_variant: Variant = (relations_variant as Dictionary).get(relation_key_variant, {})
			if not entry_variant is Dictionary:
				continue
			var entry := entry_variant as Dictionary
			var alliance_turns := maxi(0, int(entry.get("alliance_turns_remaining", 0)))
			var status := str(host.call("_normalize_faction_relation_status", str(entry.get("status", RELATION_STATUS_NEUTRAL))))
			if status == RELATION_STATUS_ALLIED and alliance_turns > 0:
				var package_payload := {}
				var package_payload_variant: Variant = entry.get("alliance_resource_package", {})
				if package_payload_variant is Dictionary:
					package_payload = normalize_resource_package(package_payload_variant as Dictionary)
				alliances[target_faction_id] = {
					"turns_remaining": alliance_turns,
					"created_turn": maxi(1, int(entry.get("alliance_created_turn", player_state.get("turn_number", 1)))),
					"resource_package": package_payload,
					"acceptance_score": maxi(0, int(entry.get("alliance_acceptance_score", 0))),
				}
	player_state["alliances"] = alliances
	host.set("_player_state", player_state)


func restore_diplomacy_state_from_mirrors(host: Object) -> void:
	var player_state := _get_player_state(host)
	var player_faction_id := str(host.call("_get_current_player_faction_id"))
	var raw_cooldowns: Variant = player_state.get("diplomacy_action_cooldowns", {})
	if raw_cooldowns is Dictionary:
		for target_faction_variant in (raw_cooldowns as Dictionary).keys():
			var target_faction_id := str(target_faction_variant)
			if target_faction_id.is_empty() or target_faction_id == player_faction_id:
				continue
			var turns_remaining := maxi(0, int((raw_cooldowns as Dictionary).get(target_faction_variant, 0)))
			if turns_remaining <= 0:
				continue
			var relation_entry := _get_relation_entry(host, player_faction_id, target_faction_id)
			relation_entry["diplomacy_action_cooldown"] = maxi(int(relation_entry.get("diplomacy_action_cooldown", 0)), turns_remaining)
			_store_relation_entry(host, player_faction_id, target_faction_id, relation_entry)
	var raw_agreements: Variant = player_state.get("trade_agreements", {})
	if raw_agreements is Dictionary:
		for target_faction_variant in (raw_agreements as Dictionary).keys():
			var target_faction_id := str(target_faction_variant)
			if target_faction_id.is_empty() or target_faction_id == player_faction_id:
				continue
			var raw_agreement: Variant = (raw_agreements as Dictionary).get(target_faction_variant, {})
			var turns_remaining := 0
			var agreement_source := "diplomacy_action"
			var created_turn := maxi(1, int(player_state.get("turn_number", 1)))
			if raw_agreement is Dictionary:
				turns_remaining = maxi(0, int((raw_agreement as Dictionary).get("turns_remaining", 0)))
				agreement_source = str((raw_agreement as Dictionary).get("source", agreement_source))
				created_turn = maxi(1, int((raw_agreement as Dictionary).get("created_turn", created_turn)))
			else:
				turns_remaining = maxi(0, int(raw_agreement))
			if turns_remaining <= 0:
				continue
			var relation_entry := _get_relation_entry(host, player_faction_id, target_faction_id)
			relation_entry["trade_agreement_active"] = true
			relation_entry["trade_agreement_turns_remaining"] = maxi(int(relation_entry.get("trade_agreement_turns_remaining", 0)), turns_remaining)
			relation_entry["trade_agreement_bonus"] = TRADE_AGREEMENT_MULTIPLIER_BONUS
			relation_entry["trade_agreement_source"] = agreement_source
			relation_entry["trade_agreement_created_turn"] = created_turn
			_store_relation_entry(host, player_faction_id, target_faction_id, relation_entry)


func restore_alliance_state_from_mirror(host: Object) -> void:
	var player_state := _get_player_state(host)
	var player_faction_id := str(host.call("_get_current_player_faction_id"))
	var raw_alliances: Variant = player_state.get("alliances", {})
	if not raw_alliances is Dictionary:
		return
	for target_faction_variant in (raw_alliances as Dictionary).keys():
		var target_faction_id := str(target_faction_variant)
		if target_faction_id.is_empty() or target_faction_id == player_faction_id:
			continue
		var raw_alliance: Variant = (raw_alliances as Dictionary).get(target_faction_variant, {})
		var turns_remaining := 0
		var created_turn := maxi(1, int(player_state.get("turn_number", 1)))
		var resource_package := {}
		var acceptance_score := 0
		if raw_alliance is Dictionary:
			turns_remaining = maxi(0, int((raw_alliance as Dictionary).get("turns_remaining", 0)))
			created_turn = maxi(1, int((raw_alliance as Dictionary).get("created_turn", created_turn)))
			var package_variant: Variant = (raw_alliance as Dictionary).get("resource_package", {})
			if package_variant is Dictionary:
				resource_package = normalize_resource_package(package_variant as Dictionary)
			acceptance_score = maxi(0, int((raw_alliance as Dictionary).get("acceptance_score", 0)))
		else:
			turns_remaining = maxi(0, int(raw_alliance))
		if turns_remaining <= 0:
			continue
		var relation_entry := _get_relation_entry(host, player_faction_id, target_faction_id)
		relation_entry["status"] = RELATION_STATUS_ALLIED
		relation_entry["alliance_turns_remaining"] = maxi(int(relation_entry.get("alliance_turns_remaining", 0)), turns_remaining)
		relation_entry["alliance_created_turn"] = created_turn
		relation_entry["alliance_resource_package"] = resource_package
		relation_entry["alliance_acceptance_score"] = acceptance_score
		_store_relation_entry(host, player_faction_id, target_faction_id, relation_entry)


func get_active_alliance_turns(host: Object, target_faction_id: String) -> int:
	var player_faction_id := str(host.call("_get_current_player_faction_id"))
	if target_faction_id.is_empty() or target_faction_id == player_faction_id:
		return 0
	var relation := _get_relation_entry(host, player_faction_id, target_faction_id)
	var status := str(host.call("_normalize_faction_relation_status", str(relation.get("status", RELATION_STATUS_NEUTRAL))))
	if status != RELATION_STATUS_ALLIED:
		return 0
	return maxi(0, int(relation.get("alliance_turns_remaining", 0)))


func get_trade_agreement_bonus_multiplier(host: Object, faction_a: String, faction_b: String) -> float:
	if faction_a.is_empty() or faction_b.is_empty() or faction_a == faction_b:
		return 0.0
	var relation := _get_relation_entry(host, faction_a, faction_b)
	if bool(relation.get("trade_agreement_active", false)) and int(relation.get("trade_agreement_turns_remaining", 0)) > 0:
		return float(relation.get("trade_agreement_bonus", TRADE_AGREEMENT_MULTIPLIER_BONUS))
	return 0.0


func get_active_trade_agreement_turns(host: Object, target_faction_id: String) -> int:
	var player_faction_id := str(host.call("_get_current_player_faction_id"))
	if target_faction_id.is_empty() or target_faction_id == player_faction_id:
		return 0
	var relation := _get_relation_entry(host, player_faction_id, target_faction_id)
	if not bool(relation.get("trade_agreement_active", false)):
		return 0
	return maxi(0, int(relation.get("trade_agreement_turns_remaining", 0)))


func propose_trade_agreement(host: Object, target_faction_id: String) -> bool:
	var player_state := _get_player_state(host)
	var turn_number := maxi(1, int(player_state.get("turn_number", 1)))
	var player_faction_id := str(host.call("_get_current_player_faction_id"))
	if target_faction_id.is_empty() or target_faction_id == player_faction_id:
		player_state["last_trade_agreement_result"] = {"turn": turn_number, "target_faction_id": target_faction_id, "success": false, "reason": "invalid_target"}
		host.set("_player_state", player_state)
		return false
	var relation := _get_relation_entry(host, player_faction_id, target_faction_id)
	var status := str(host.call("_normalize_faction_relation_status", str(relation.get("status", RELATION_STATUS_NEUTRAL))))
	if status == RELATION_STATUS_HOSTILE or status == RELATION_STATUS_SUSPENDED:
		player_state["last_trade_agreement_result"] = {"turn": turn_number, "target_faction_id": target_faction_id, "success": false, "reason": status, "status": status}
		host.set("_player_state", player_state)
		return false
	var score := clampi(int(relation.get("score", DEFAULT_RELATION_SCORE)), RELATION_SCORE_MIN, RELATION_SCORE_MAX)
	if score < LEGACY_TRADE_AGREEMENT_SCORE_REQUIREMENT:
		player_state["last_trade_agreement_result"] = {"turn": turn_number, "target_faction_id": target_faction_id, "success": false, "reason": "relation_score", "score": score, "required_score": LEGACY_TRADE_AGREEMENT_SCORE_REQUIREMENT, "status": status}
		host.set("_player_state", player_state)
		return false
	var cost := LEGACY_TRADE_AGREEMENT_COST.duplicate(true)
	var payment_check := can_pay_diplomacy_resource_cost(host, cost)
	if not bool(payment_check.get("ok", false)):
		player_state["last_trade_agreement_result"] = {"turn": turn_number, "target_faction_id": target_faction_id, "success": false, "reason": "resources", "score": score, "cost": cost, "missing": payment_check.get("missing", {}), "status": status}
		host.set("_player_state", player_state)
		return false
	var payment_result := apply_diplomacy_resource_cost(host, cost)
	relation = _get_relation_entry(host, player_faction_id, target_faction_id)
	relation["trade_agreement_active"] = true
	relation["trade_agreement_turns_remaining"] = LEGACY_TRADE_AGREEMENT_TURNS
	relation["trade_agreement_bonus"] = TRADE_AGREEMENT_MULTIPLIER_BONUS
	_store_relation_entry(host, player_faction_id, target_faction_id, relation)
	player_state = _get_player_state(host)
	player_state["last_trade_agreement_result"] = {"turn": turn_number, "target_faction_id": target_faction_id, "success": true, "score": score, "status": status, "cost": cost, "payment": payment_result, "duration_turns": LEGACY_TRADE_AGREEMENT_TURNS, "trade_multiplier_bonus": TRADE_AGREEMENT_MULTIPLIER_BONUS}
	host.set("_player_state", player_state)
	return true


func can_pay_diplomacy_resource_cost(host: Object, cost: Dictionary) -> Dictionary:
	var missing := {}
	var resource_stock_variant: Variant = _get_player_state(host).get("resource_stock", {})
	var resource_stock: Dictionary = resource_stock_variant if resource_stock_variant is Dictionary else {}
	for resource_id_variant in cost.keys():
		var resource_id := str(resource_id_variant)
		var required_amount := maxi(0, int(cost.get(resource_id_variant, 0)))
		var available_amount := maxi(0, int(resource_stock.get(resource_id, 0)))
		if resource_id == "food" and host.has_method("_get_total_recruitment_food_stock"):
			available_amount = maxi(0, int(host.call("_get_total_recruitment_food_stock")))
		if available_amount < required_amount:
			missing[resource_id] = required_amount - available_amount
	return {"ok": missing.is_empty(), "cost": cost.duplicate(true), "missing": missing}


func apply_diplomacy_resource_cost(host: Object, cost: Dictionary) -> Dictionary:
	var player_state := _get_player_state(host)
	var resource_stock_variant: Variant = player_state.get("resource_stock", {})
	var resource_stock: Dictionary = resource_stock_variant.duplicate(true) if resource_stock_variant is Dictionary else {}
	var before_stock := resource_stock.duplicate(true)
	var paid := {}
	for resource_id_variant in cost.keys():
		var resource_id := str(resource_id_variant)
		var required_amount := maxi(0, int(cost.get(resource_id_variant, 0)))
		if resource_id == "food":
			var remaining_food := required_amount
			var food_paid := {}
			for food_resource_id in ["rice", "barley", "seafood"]:
				var food_before_amount := maxi(0, int(resource_stock.get(food_resource_id, 0)))
				var food_paid_amount := mini(food_before_amount, remaining_food)
				resource_stock[food_resource_id] = food_before_amount - food_paid_amount
				remaining_food -= food_paid_amount
				food_paid[food_resource_id] = food_paid_amount
			paid["food"] = food_paid
			continue
		var before_amount := maxi(0, int(resource_stock.get(resource_id, 0)))
		var paid_amount := mini(before_amount, required_amount)
		resource_stock[resource_id] = before_amount - paid_amount
		paid[resource_id] = paid_amount
	player_state["resource_stock"] = resource_stock
	host.set("_player_state", player_state)
	return {
		"before": before_stock,
		"after": resource_stock.duplicate(true),
		"cost": cost.duplicate(true),
		"paid": paid,
	}


func apply_diplomacy_relation_delta(
	host: Object,
	faction_a: String,
	faction_b: String,
	delta: int,
	reason: String = ""
) -> Dictionary:
	var entry_variant: Variant = host.call("_ensure_faction_relation_entry", faction_a, faction_b)
	var entry: Dictionary = entry_variant if entry_variant is Dictionary else {}
	var before_score := clampi(int(entry.get("score", DEFAULT_RELATION_SCORE)), RELATION_SCORE_MIN, RELATION_SCORE_MAX)
	var after_score := clampi(before_score + delta, RELATION_SCORE_MIN, RELATION_SCORE_MAX)
	entry["score"] = after_score
	var relation_key := str(host.call("_make_faction_relation_key", faction_a, faction_b))
	var player_state := _get_player_state(host)
	var relations_variant: Variant = player_state.get("faction_relations", {})
	var relations: Dictionary = relations_variant if relations_variant is Dictionary else {}
	relations[relation_key] = entry
	player_state["faction_relations"] = relations
	var result := {
		"faction_a": faction_a,
		"faction_b": faction_b,
		"before_score": before_score,
		"after_score": after_score,
		"delta": after_score - before_score,
		"status": str(entry.get("status", RELATION_STATUS_NEUTRAL)),
		"band": _get_relation_band(after_score),
		"reason": reason,
		"turn": maxi(1, int(player_state.get("turn_number", 1))),
	}
	player_state["last_diplomacy_relation_result"] = result
	host.set("_player_state", player_state)
	return result


func _get_relation_band(score: int) -> String:
	var normalized_score := clampi(score, RELATION_SCORE_MIN, RELATION_SCORE_MAX)
	if normalized_score >= 70:
		return "friendly"
	if normalized_score <= 30:
		return "hostile"
	return "neutral"


func _get_relation_entry(host: Object, faction_a: String, faction_b: String) -> Dictionary:
	var entry_variant: Variant = host.call("_ensure_faction_relation_entry", faction_a, faction_b)
	return entry_variant if entry_variant is Dictionary else {}


func _store_relation_entry(host: Object, faction_a: String, faction_b: String, entry: Dictionary) -> void:
	var relation_key := str(host.call("_make_faction_relation_key", faction_a, faction_b))
	var player_state := _get_player_state(host)
	var relations_variant: Variant = player_state.get("faction_relations", {})
	var relations: Dictionary = relations_variant if relations_variant is Dictionary else {}
	relations[relation_key] = entry
	player_state["faction_relations"] = relations
	host.set("_player_state", player_state)


func _get_target_faction_from_relation_key(player_faction_id: String, relation_key: String) -> String:
	var parts := relation_key.split("|", false)
	if parts.size() != 2:
		return ""
	if str(parts[0]) == player_faction_id:
		return str(parts[1])
	if str(parts[1]) == player_faction_id:
		return str(parts[0])
	return ""


func _get_player_state(host: Object) -> Dictionary:
	var raw_player_state: Variant = host.get("_player_state")
	return raw_player_state if raw_player_state is Dictionary else {}


func _store_last_result(host: Object, result: Dictionary) -> void:
	var player_state := _get_player_state(host)
	player_state["last_diplomacy_action_result"] = result
	host.set("_player_state", player_state)


func _set_status(host: Object, result: Dictionary) -> void:
	host.set("_save_management_status", str(result.get("message", "외교 행동 처리")))


func _failure(reason: String, message: String) -> Dictionary:
	return {
		"ok": false,
		"success": false,
		"reason": reason,
		"message": message,
	}
