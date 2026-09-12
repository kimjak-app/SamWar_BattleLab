class_name WorldMapDiplomacyActionService
extends RefCounted

const PLAYER_FACTION_ID := "player"
const RELATION_STATUS_NEUTRAL := "neutral"
const DEFAULT_RELATION_SCORE := 50
const ACTION_TRADE_AGREEMENT := "trade_agreement"
const ACTION_ALLIANCE_PROPOSAL := "alliance_proposal"
const TRADE_AGREEMENT_MULTIPLIER_BONUS := 0.15


func execute(
	host: Object,
	action_id: String,
	target_city_id: String,
	_source_city_id: String = ""
) -> Dictionary:
	if host == null:
		return _failure("executor_unavailable", "외교 행동 실행기를 찾을 수 없습니다.")
	for method_name in [
		"_validate_diplomacy_action",
		"_build_diplomacy_action_failure_result",
		"_apply_generic_resource_cost",
		"_adjust_faction_relation_score",
		"_make_faction_relation_key",
		"_ensure_faction_relation_entry",
		"_normalize_faction_relation_status",
		"_sync_diplomacy_action_mirror_state_from_relations",
	]:
		if not host.has_method(method_name):
			return _failure("executor_unavailable", "외교 행동 처리기를 찾을 수 없습니다: %s" % method_name)

	var validation_variant: Variant = host.call("_validate_diplomacy_action", action_id, target_city_id)
	if not validation_variant is Dictionary:
		return _failure("invalid_validation", "외교 행동 조건을 확인할 수 없습니다.")
	var validation := validation_variant as Dictionary
	if not bool(validation.get("ok", false)):
		var failure_result := _call_result(host, "_build_diplomacy_action_failure_result", [action_id, validation])
		_store_last_result(host, failure_result)
		_set_status(host, failure_result)
		return failure_result

	if action_id == ACTION_ALLIANCE_PROPOSAL:
		var alliance_result := _call_result(host, "_apply_alliance_diplomacy_action", [validation])
		_set_status(host, alliance_result)
		return alliance_result

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
		[PLAYER_FACTION_ID, target_faction_id, relation_delta, "diplomacy_action_%s" % action_id]
	)
	var after_score := int(relation_result.get("after_score", before_score))
	var relation_key_variant: Variant = host.call("_make_faction_relation_key", PLAYER_FACTION_ID, target_faction_id)
	var relation_key := str(relation_key_variant)
	var player_state := _get_player_state(host)
	var relations_variant: Variant = player_state.get("faction_relations", {})
	var relations: Dictionary = relations_variant if relations_variant is Dictionary else {}
	var ensured_variant: Variant = host.call("_ensure_faction_relation_entry", PLAYER_FACTION_ID, target_faction_id)
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
