class_name WorldMapDiplomacyActionService
extends RefCounted

const RELATION_STATUS_NEUTRAL := "neutral"
const RELATION_STATUS_ALLIED := "allied"
const RELATION_STATUS_HOSTILE := "hostile"
const RELATION_STATUS_SUSPENDED := "suspended"
const DEFAULT_RELATION_SCORE := 50
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
		"_apply_generic_resource_cost",
		"_adjust_faction_relation_score",
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

	if action_id == ACTION_ALLIANCE_PROPOSAL:
		var alliance_result := _call_result(host, "_apply_alliance_diplomacy_action", [validation])
		_set_status(host, alliance_result)
		return alliance_result

	var player_faction_id := str(host.call("_get_current_player_faction_id"))
	var definition_variant: Variant = validation.get("definition", {})
	var definition: Dictionary = definition_variant if definition_variant is Dictionary else {}
	var target_faction_id := str(validation.get("target_faction_id", ""))
	var cost_variant: Variant = validation.get("cost", {})
	var cost: Dictionary = cost_variant if cost_variant is Dictionary else {}
	var payment_result := _call_result(host, "_apply_generic_resource_cost", [cost])
	var before_score := int(validation.get("before_score", DEFAULT_RELATION_SCORE))
	var before_status := str(validation.get("before_status", RELATION_STATUS_NEUTRAL))
	var relation_delta := int(validation.get("relation_delta", 0))
	var relation_result := _call_result(
		host,
		"_adjust_faction_relation_score",
		[player_faction_id, target_faction_id, relation_delta, "diplomacy_action_%s" % action_id]
	)
	var after_score := int(relation_result.get("after_score", before_score))
	var relation_key_variant: Variant = host.call("_make_faction_relation_key", player_faction_id, target_faction_id)
	var relation_key := str(relation_key_variant)
	var player_state := _get_player_state(host)
	var relations_variant: Variant = player_state.get("faction_relations", {})
	var relations: Dictionary = relations_variant if relations_variant is Dictionary else {}
	var ensured_variant: Variant = host.call("_ensure_faction_relation_entry", player_faction_id, target_faction_id)
	var ensured: Dictionary = ensured_variant if ensured_variant is Dictionary else {}
	var relation_entry_variant: Variant = relations.get(relation_key, ensured)
	var relation_entry: Dictionary = relation_entry_variant if relation_entry_variant is Dictionary else ensured
	relation_entry["diplomacy_action_cooldown"] = maxi(0, int(validation.get("cooldown", 0)))

	var agreement_payload := {}
	if action_id == ACTION_TRADE_AGREEMENT:
		var agreement_turns := maxi(1, int(definition.get("agreement_turns", 1)))
		var current_turn := maxi(1, int(player_state.get("turn_number", 1)))
		relation_entry["trade_agreement_active"] = true
		relation_entry["trade_agreement_turns_remaining"] = agreement_turns
		relation_entry["trade_agreement_bonus"] = TRADE_AGREEMENT_MULTIPLIER_BONUS
		relation_entry["trade_agreement_source"] = "diplomacy_action"
		relation_entry["trade_agreement_created_turn"] = current_turn
		agreement_payload = {
			"turns_remaining": agreement_turns,
			"source": "diplomacy_action",
			"created_turn": current_turn,
			"bonus": TRADE_AGREEMENT_MULTIPLIER_BONUS,
		}
		var agreement_status_variant: Variant = host.call(
			"_normalize_faction_relation_status",
			str(relation_entry.get("status", RELATION_STATUS_NEUTRAL))
		)
		player_state["last_trade_agreement_result"] = {
			"turn": current_turn,
			"target_faction_id": target_faction_id,
			"success": true,
			"score": after_score,
			"status": str(agreement_status_variant),
			"cost": cost,
			"payment": payment_result,
			"duration_turns": agreement_turns,
			"trade_multiplier_bonus": TRADE_AGREEMENT_MULTIPLIER_BONUS,
			"source": "diplomacy_action",
		}

	relations[relation_key] = relation_entry
	player_state["faction_relations"] = relations
	host.set("_player_state", player_state)
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


func _get_player_state(host: Object) -> Dictionary:
	var raw_player_state: Variant = host.get("_player_state")
	return raw_player_state if raw_player_state is Dictionary else {}


func _store_last_result(host: Object, result: Dictionary) -> void:
	var player_state := _get_player_state(host)
	player_state["last_diplomacy_action_result"] = result
	host.set("_player_state", player_state)


func _set_status(host: Object, result: Dictionary) -> void:
	host.set("_save_management_status", str(result.get("message", "외교 행동 처리")))


func _call_result(host: Object, method_name: String, args: Array) -> Dictionary:
	if not host.has_method(method_name):
		return _failure("executor_unavailable", "외교 행동 처리기를 찾을 수 없습니다: %s" % method_name)
	var raw_result: Variant = host.callv(method_name, args)
	if raw_result is Dictionary:
		return raw_result as Dictionary
	return _failure("invalid_result", "외교 행동 결과를 처리할 수 없습니다.")


func _failure(reason: String, message: String) -> Dictionary:
	return {
		"ok": false,
		"success": false,
		"reason": reason,
		"message": message,
	}
