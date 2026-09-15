class_name WorldMapBattleResultService
extends RefCounted

const RESULT_DEFENDER_WIN := "defender_win"
const RESULT_ATTACKER_WIN := "attacker_win"
const RESULT_RETREAT := "retreat"
const RESULT_UNKNOWN := "unknown"

var _query: Callable
var _config: Dictionary = {}


func configure(query: Callable, config: Dictionary) -> void:
	_query = query
	_config = config.duplicate(true)


func build_settlement_plan(raw_result: Dictionary) -> Dictionary:
	var result := raw_result.duplicate(true)
	var is_player_attack := _is_player_attack_battle_result(result)
	var is_enemy_invasion := _is_enemy_invasion_battle_result(result)
	var battle_kind := "player_attack" if is_player_attack else ("enemy_invasion" if is_enemy_invasion else "unknown")
	var result_kind := _normalize_player_attack_battle_result_kind(result) if is_player_attack else _normalize_invasion_battle_result_kind(result)
	var attacker_city_id := _get_invasion_result_city_id(result, ["attacker_source_city_id", "attacker_city_id", "source_city_id", "origin_city_id"])
	var defender_city_id := _get_invasion_result_city_id(result, ["defender_city_id", "target_city_id", "city_id"])
	var winner_side := ""
	var loser_side := ""
	if result_kind == RESULT_ATTACKER_WIN:
		winner_side = "attacker"
		loser_side = "defender"
	elif result_kind == RESULT_DEFENDER_WIN:
		winner_side = "defender"
		loser_side = "attacker"
	var player_outcome := _get_player_troop_outcome_from_result(result)
	var enemy_outcome := _get_enemy_troop_outcome_from_result(result)
	var casualty_plan := _calculate_invasion_casualty_result(result_kind, defender_city_id, attacker_city_id, result)
	var old_owner := _city_owner(defender_city_id)
	var new_owner := old_owner
	if result_kind == RESULT_ATTACKER_WIN:
		new_owner = str(result.get("attacker_owner", ""))
		if new_owner.is_empty():
			new_owner = str(_q("player_faction", [], "")) if is_player_attack else _city_owner(attacker_city_id)
	var transfer_required := result_kind == RESULT_ATTACKER_WIN and not defender_city_id.is_empty() and not old_owner.is_empty() and not new_owner.is_empty() and old_owner != new_owner
	var attacker_hero_outcomes := _normalize_battle_hero_outcomes(result.get("attacker_hero_outcomes", {}))
	var defender_hero_outcomes := _normalize_battle_hero_outcomes(result.get("defender_hero_outcomes", {}))
	var transaction_id := str(result.get("transaction_id", ""))
	var settlement_profile := "t02_return" if battle_kind == "player_attack" and not transaction_id.is_empty() else "standard"
	var attacker_healthy := maxi(0, int(result.get("attacker_healthy_survivors", casualty_plan.get("attacker_remaining_troops", 0))))
	var defender_healthy := maxi(0, int(result.get("defender_healthy_survivors", casualty_plan.get("defender_remaining_troops", 0))))
	var hero_status_plan := _build_hero_status_plan(result_kind, attacker_city_id, defender_city_id, attacker_hero_outcomes, defender_hero_outcomes, transaction_id)
	if settlement_profile == "t02_return" and hero_status_plan.is_empty():
		hero_status_plan = _build_t02_hero_status_plan(result)
	var defender_disposition := {}
	var hero_movements: Array[Dictionary] = []
	if settlement_profile == "t02_return" and result_kind == RESULT_ATTACKER_WIN:
		defender_disposition = _build_defender_disposition_plan(
			defender_city_id,
			old_owner,
			new_owner,
			_normalize_battle_result_hero_ids(result.get("defender_general_ids", [])),
			_normalize_battle_result_hero_ids(result.get("defender_surviving_general_ids", [])),
			transaction_id,
			str(result.get("result_id", ""))
		)
	if settlement_profile == "t02_return":
		var attacker_ids := _normalize_battle_result_hero_ids(result.get("attacker_general_ids", []))
		if attacker_ids.is_empty():
			for hero_id_variant in attacker_hero_outcomes.keys():
				attacker_ids.append(str(hero_id_variant))
		var destination_city_id := defender_city_id if result_kind == RESULT_ATTACKER_WIN else attacker_city_id
		for hero_id in attacker_ids:
			hero_movements.append({"hero_id": hero_id, "city_id": destination_city_id})
	return {
		"battle_kind": battle_kind,
		"result_kind": result_kind,
		"winner_side": winner_side,
		"loser_side": loser_side,
		"attacker_city_id": attacker_city_id,
		"defender_city_id": defender_city_id,
		"target_city_id": defender_city_id,
		"player_troop_outcome": player_outcome,
		"enemy_troop_outcome": enemy_outcome,
		"casualty_plan": casualty_plan,
		"attacker_remaining_troops": attacker_healthy if settlement_profile == "t02_return" else int(casualty_plan.get("attacker_remaining_troops", 0)),
		"defender_remaining_troops": defender_healthy if settlement_profile == "t02_return" else int(casualty_plan.get("defender_remaining_troops", 0)),
		"occupation_troops": attacker_healthy if settlement_profile == "t02_return" and result_kind == RESULT_ATTACKER_WIN else int(casualty_plan.get("occupied_city_troops", 0)),
		"hero_outcomes": {"attacker": attacker_hero_outcomes, "defender": defender_hero_outcomes},
		"hero_status_plan": hero_status_plan,
		"defender_disposition": defender_disposition,
		"hero_movements": hero_movements,
		"settlement_profile": settlement_profile,
		"troop_settlement": {
			"attacker_healthy": attacker_healthy,
			"attacker_wounded": maxi(0, int(result.get("attacker_wounded", 0))),
			"defender_healthy": defender_healthy,
			"defender_wounded": maxi(0, int(result.get("defender_wounded", 0))),
		},
		"faction_transfer": {
			"required": transfer_required,
			"city_id": defender_city_id,
			"old_owner": old_owner,
			"new_owner": new_owner,
		},
		"supply_settlement": {
			"defender": {
				"city_id": defender_city_id,
				"food_type": str(result.get("defender_remaining_food_type", "rice")),
				"remaining_food": maxi(0, int(result.get("defender_remaining_food", 0))),
				"remaining_salt": maxi(0, int(result.get("defender_remaining_salt", 0))),
			},
			"attacker_cargo": {
				"destination_city_id": defender_city_id if result_kind == RESULT_ATTACKER_WIN else attacker_city_id,
				"food_type": str(result.get("attacker_remaining_food_type", "rice")),
				"food": maxi(0, int(result.get("attacker_remaining_food", 0))),
				"salt": maxi(0, int(result.get("attacker_remaining_salt", 0))),
				"gold": maxi(0, int(result.get("attacker_remaining_gold", 0))),
			},
		},
		"apply_supply_settlement": settlement_profile == "t02_return",
		"transaction_id": transaction_id,
		"result_id": str(result.get("result_id", "")),
		"raw_result": result,
	}


func _build_hero_status_plan(result_kind: String, attacker_city_id: String, defender_city_id: String, attacker_outcomes: Dictionary, defender_outcomes: Dictionary, transaction_id: String) -> Array[Dictionary]:
	var status_plan: Array[Dictionary] = []
	for outcomes in [attacker_outcomes, defender_outcomes]:
		for hero_id_variant in outcomes.keys():
			var hero_id := str(hero_id_variant)
			var outcome: Dictionary = outcomes.get(hero_id, {})
			status_plan.append({
				"hero_id": hero_id,
				"status": "normal" if bool(outcome.get("survived", false)) else "wounded",
				"outcome": outcome.duplicate(true),
			})
	if not status_plan.is_empty() or not transaction_id.is_empty():
		return status_plan
	var losing_city_id := attacker_city_id if result_kind == RESULT_DEFENDER_WIN else (defender_city_id if result_kind == RESULT_ATTACKER_WIN else "")
	if losing_city_id.is_empty():
		return status_plan
	var raw_ids: Variant = _q("city_hero_ids", [losing_city_id], [])
	if not raw_ids is Array:
		return status_plan
	for hero_id_variant in raw_ids:
		var hero_id := str(hero_id_variant)
		if hero_id.is_empty() or not bool(_q("hero_status_mutable", [hero_id], false)):
			continue
		status_plan.append({"hero_id": hero_id, "status": "wounded" if status_plan.is_empty() else "captured", "outcome": {}})
		if status_plan.size() >= 2:
			break
	return status_plan


func _build_t02_hero_status_plan(result: Dictionary) -> Array[Dictionary]:
	var status_plan: Array[Dictionary] = []
	for side in ["attacker", "defender"]:
		var all_ids := _normalize_battle_result_hero_ids(result.get("%s_general_ids" % side, []))
		var surviving_ids := _normalize_battle_result_hero_ids(result.get("%s_surviving_general_ids" % side, []))
		for hero_id in all_ids:
			status_plan.append({
				"hero_id": hero_id,
				"status": "normal" if surviving_ids.has(hero_id) else "wounded",
				"outcome": {},
			})
	return status_plan


func _build_defender_disposition_plan(target_city_id: String, defeated_owner: String, attacker_owner: String, all_hero_ids: Array[String], surviving_hero_ids: Array[String], transaction_id: String, result_id: String) -> Dictionary:
	var participants: Array[String] = all_hero_ids.duplicate()
	var raw_roster: Variant = _q("city_hero_ids", [target_city_id], [])
	if raw_roster is Array:
		for hero_id in _normalize_battle_result_hero_ids(raw_roster):
			if not participants.has(hero_id):
				participants.append(hero_id)
	var survivors: Array[String] = surviving_hero_ids.duplicate()
	if survivors.is_empty():
		survivors = participants.duplicate()
	var escape_city_ids: Array[String] = []
	var raw_neighbors: Variant = _q("city_neighbors", [target_city_id], [])
	if raw_neighbors is Array:
		for city_id_variant in raw_neighbors:
			var city_id := str(city_id_variant)
			if _city_owner(city_id) == defeated_owner:
				escape_city_ids.append(city_id)
	escape_city_ids.sort()
	var remaining_city_count := maxi(0, int(_q("faction_city_count", [defeated_owner], 0)) - 1)
	var align_all := escape_city_ids.is_empty() or remaining_city_count <= 0
	var aligned_count := survivors.size() if align_all else maxi(1, int(floor(float(survivors.size()) / 3.0)))
	survivors.sort()
	var assignments: Array[Dictionary] = []
	var aligned_ids: Array[String] = []
	var escaped_ids: Array[String] = []
	for index in range(survivors.size()):
		var hero_id: String = survivors[index]
		if index < aligned_count:
			aligned_ids.append(hero_id)
			assignments.append({"hero_id": hero_id, "faction_id": attacker_owner, "city_id": target_city_id, "acquired": true})
		else:
			var destination: String = escape_city_ids[(index - aligned_count) % escape_city_ids.size()]
			escaped_ids.append(hero_id)
			assignments.append({"hero_id": hero_id, "faction_id": defeated_owner, "city_id": destination, "acquired": false})
	var unstationed: Array[String] = []
	for hero_id in participants:
		if not survivors.has(hero_id):
			unstationed.append(hero_id)
	return {
		"assignments": assignments,
		"unstationed_hero_ids": unstationed,
		"aligned_count": aligned_ids.size(), "escaped_count": escaped_ids.size(),
		"aligned_ids": aligned_ids, "escaped_ids": escaped_ids,
		"primary_escape_city_id": escape_city_ids[0] if not escape_city_ids.is_empty() else "",
		"faction_defeated": remaining_city_count <= 0, "defeated_faction_id": defeated_owner,
		"defeated_owner": defeated_owner, "transaction_id": transaction_id, "result_id": result_id,
	}


func _is_player_attack_battle_result(result_payload: Dictionary) -> bool:
	var source := str(result_payload.get("source", "")).to_lower()
	var result_type := str(result_payload.get("type", "")).to_lower()
	return source == str(_config.get("player_attack_context_source", "player_attack")) or result_type.begins_with("attack")


func _is_enemy_invasion_battle_result(result_payload: Dictionary) -> bool:
	var source := str(result_payload.get("source", "")).to_lower()
	var result_type := str(result_payload.get("type", "")).to_lower()
	return source == "enemy_invasion" or result_type.begins_with("defense")


func _normalize_invasion_battle_result_kind(result_payload: Dictionary) -> String:
	if result_payload.has("is_player_win") and result_payload.get("is_player_win") is bool:
		return RESULT_DEFENDER_WIN if bool(result_payload.get("is_player_win")) else RESULT_ATTACKER_WIN
	for token in _result_tokens(result_payload):
		if ["player_win", "defender_win", "victory", "win"].has(token):
			return RESULT_DEFENDER_WIN
		if ["player_loss", "attacker_win", "defeat", "lose", "loss"].has(token):
			return RESULT_ATTACKER_WIN
		if ["retreat", "cancel", "cancelled", "canceled", "aborted"].has(token):
			return RESULT_RETREAT
	var winner := str(result_payload.get("winner", "")).to_lower()
	if ["defender", "player", "ally"].has(winner):
		return RESULT_DEFENDER_WIN
	if ["attacker", "enemy"].has(winner):
		return RESULT_ATTACKER_WIN
	return RESULT_UNKNOWN


func _normalize_player_attack_battle_result_kind(result_payload: Dictionary) -> String:
	var winner := str(result_payload.get("winner", "")).to_lower()
	if ["attacker", "player", "ally"].has(winner):
		return RESULT_ATTACKER_WIN
	if ["defender", "enemy"].has(winner):
		return RESULT_DEFENDER_WIN
	if result_payload.has("is_player_win") and result_payload.get("is_player_win") is bool:
		return RESULT_ATTACKER_WIN if bool(result_payload.get("is_player_win")) else RESULT_DEFENDER_WIN
	for token in _result_tokens(result_payload):
		if ["player_win", "attacker_win", "victory", "win"].has(token):
			return RESULT_ATTACKER_WIN
		if ["player_loss", "defender_win", "defeat", "lose", "loss"].has(token):
			return RESULT_DEFENDER_WIN
		if ["retreat", "cancel", "cancelled", "canceled", "aborted"].has(token):
			return RESULT_RETREAT
	return RESULT_UNKNOWN


func _get_invasion_result_city_id(result_payload: Dictionary, keys: Array[String]) -> String:
	for key in keys:
		var city_id := str(result_payload.get(key, ""))
		if not city_id.is_empty():
			return city_id
	return ""


func _build_invasion_result_summary(result_kind: String, defender_city_id: String, attacker_city_id: String, defender_city_name: String, attacker_city_name: String, old_owner: String, new_owner: String, casualty_result: Dictionary, message_title: String, leading_lines: Array) -> Dictionary:
	var defender_before := int(casualty_result.get("defender_before", _city_troops(defender_city_id)))
	var defender_after := _city_troops(defender_city_id)
	var attacker_before := int(casualty_result.get("attacker_before", _city_troops(attacker_city_id)))
	var attacker_after := _city_troops(attacker_city_id)
	var occupied_city_troops := int(casualty_result.get("occupied_city_troops", 0))
	var normalized_old_owner := old_owner if not old_owner.is_empty() else _city_owner(defender_city_id)
	var normalized_new_owner := new_owner if not new_owner.is_empty() else normalized_old_owner
	var owner_changed := not normalized_old_owner.is_empty() and not normalized_new_owner.is_empty() and normalized_old_owner != normalized_new_owner
	var message_lines: Array[String] = []
	for line_variant in leading_lines:
		var line := str(line_variant)
		if not line.is_empty():
			message_lines.append(line)
	if owner_changed:
		message_lines.append("소유권: %s → %s" % [_faction_label(normalized_old_owner), _faction_label(normalized_new_owner)])
	else:
		var owner_label := _faction_label(normalized_new_owner)
		message_lines.append("소유권: 유지%s" % (" (%s)" % owner_label if not owner_label.is_empty() else ""))
	if _has_city(defender_city_id):
		message_lines.append("도시 병력: %d → %d" % [defender_before, defender_after])
	if _has_city(attacker_city_id):
		message_lines.append("공격 출발지 %s 병력: %d → %d" % [attacker_city_name, attacker_before, attacker_after])
	if occupied_city_troops > 0:
		message_lines.append("점령 병력: %d" % occupied_city_troops)
	return {
		"result": result_kind, "city_id": defender_city_id, "city_name": defender_city_name,
		"old_owner": normalized_old_owner, "new_owner": normalized_new_owner, "owner_changed": owner_changed,
		"defender_city_troops_before": defender_before, "defender_city_troops_after": defender_after,
		"attacker_source_city_id": attacker_city_id, "attacker_source_city_name": attacker_city_name,
		"attacker_source_troops_before": attacker_before, "attacker_source_troops_after": attacker_after,
		"occupied_city_troops": occupied_city_troops, "message_title": message_title, "message_lines": message_lines,
	}


func _normalize_battle_result_hero_ids(raw_hero_ids: Variant) -> Array[String]:
	var normalized: Array[String] = []
	if not raw_hero_ids is Array:
		return normalized
	var compatibility := _dictionary(_config.get("hero_id_compatibility", {}))
	for raw_hero_id in raw_hero_ids:
		var hero_id := str(raw_hero_id)
		var worldmap_id := str(compatibility.get(hero_id, hero_id))
		if not worldmap_id.is_empty() and not normalized.has(worldmap_id) and bool(_q("has_hero", [worldmap_id], true)):
			normalized.append(worldmap_id)
	return normalized


func _normalize_battle_hero_outcomes(raw_outcomes: Variant) -> Dictionary:
	var normalized := {}
	if not raw_outcomes is Dictionary:
		return normalized
	var compatibility := _dictionary(_config.get("hero_id_compatibility", {}))
	for key_variant in (raw_outcomes as Dictionary).keys():
		var raw_value: Variant = (raw_outcomes as Dictionary).get(key_variant, {})
		if not raw_value is Dictionary:
			continue
		var outcome := (raw_value as Dictionary).duplicate(true)
		var raw_hero_id := str(outcome.get("hero_id", key_variant))
		var hero_id := str(compatibility.get(raw_hero_id, raw_hero_id))
		if not hero_id.is_empty():
			outcome["hero_id"] = hero_id
			normalized[hero_id] = outcome
	return normalized


func _get_player_troop_outcome_from_result(result_payload: Dictionary) -> Dictionary:
	var raw_outcome: Variant = result_payload.get("player_troop_outcome", {})
	if raw_outcome is Dictionary:
		return (raw_outcome as Dictionary).duplicate(true)
	var allocated := maxi(0, int(result_payload.get("attacker_total_allocated_troops", result_payload.get("attacker_troops", 0))))
	var did_win := _normalize_player_attack_battle_result_kind(result_payload) == RESULT_ATTACKER_WIN
	return _calculate_player_attack_troop_outcome_fallback(allocated, maxi(0, int(result_payload.get("attacker_surviving_troops", 0))), did_win)


func _get_enemy_troop_outcome_from_result(result_payload: Dictionary) -> Dictionary:
	var raw_outcome: Variant = result_payload.get("enemy_troop_outcome", {})
	if raw_outcome is Dictionary:
		return (raw_outcome as Dictionary).duplicate(true)
	var allocated := maxi(0, int(result_payload.get("defender_total_allocated_troops", result_payload.get("defender_troops", 0))))
	var did_win := _normalize_player_attack_battle_result_kind(result_payload) == RESULT_DEFENDER_WIN
	return _calculate_player_attack_troop_outcome_fallback(allocated, maxi(0, int(result_payload.get("defender_surviving_troops", 0))), did_win)


func _calculate_player_attack_troop_outcome_fallback(allocated: int, raw_survivors: int, did_win: bool) -> Dictionary:
	var safe_allocated := maxi(0, allocated)
	var survivors := mini(safe_allocated, maxi(0, raw_survivors)) if did_win else 0
	var losses := maxi(0, safe_allocated - survivors)
	var wounded := int(floor(float(losses) * 0.30)) if did_win else int(floor(float(safe_allocated) * 0.50))
	wounded = clampi(wounded, 0, safe_allocated)
	return {"allocated": safe_allocated, "survivors": survivors, "losses": losses, "wounded": wounded, "dead": maxi(0, safe_allocated - survivors - wounded)}


func _calculate_invasion_casualty_result(result_kind: String, defender_city_id: String, attacker_city_id: String, result_payload: Dictionary) -> Dictionary:
	var defender_before := _clamp_invasion_troops(_city_troops(defender_city_id))
	var attacker_before := _clamp_invasion_troops(_city_troops(attacker_city_id))
	if not _has_city(defender_city_id):
		return {"attacker_before": attacker_before, "defender_before": defender_before, "attacker_remaining_troops": attacker_before, "defender_remaining_troops": defender_before, "occupied_city_troops": 0, "attacker_source_remaining_troops": attacker_before, "attacker_loss": 0, "defender_loss": 0}
	var attacker_payload_survivors := _get_result_troop_value(result_payload, ["attacker_surviving_troops", "attacker_remaining_troops", "enemy_surviving_troops"], -1)
	var defender_payload_survivors := _get_result_troop_value(result_payload, ["defender_surviving_troops", "defender_remaining_troops", "player_surviving_troops"], -1)
	var attacker_remaining := attacker_before
	var defender_remaining := defender_before
	var occupied_city_troops := 0
	var attacker_source_remaining := attacker_before
	if result_kind == RESULT_DEFENDER_WIN:
		defender_remaining = _resolve_invasion_remaining_troops(defender_before, defender_payload_survivors, float(_config.get("defender_win_defender_loss_rate", 0.15)), int(_config.get("minimum_city_troops", 30)))
		attacker_remaining = _resolve_invasion_remaining_troops(attacker_before, attacker_payload_survivors, float(_config.get("defender_win_attacker_loss_rate", 0.70)), 0)
		attacker_source_remaining = attacker_remaining
	elif result_kind == RESULT_ATTACKER_WIN:
		defender_remaining = _resolve_invasion_remaining_troops(defender_before, defender_payload_survivors, float(_config.get("attacker_win_defender_loss_rate", 0.75)), 0)
		attacker_remaining = _resolve_invasion_remaining_troops(attacker_before, attacker_payload_survivors, float(_config.get("attacker_win_attacker_loss_rate", 0.35)), 0)
		occupied_city_troops = _resolve_occupation_troops(attacker_remaining, attacker_before, result_payload)
		attacker_source_remaining = _clamp_invasion_troops(maxi(0, attacker_remaining - occupied_city_troops))
	return {
		"attacker_before": attacker_before, "defender_before": defender_before,
		"attacker_remaining_troops": attacker_remaining, "defender_remaining_troops": defender_remaining,
		"occupied_city_troops": occupied_city_troops, "attacker_source_remaining_troops": attacker_source_remaining,
		"attacker_loss": maxi(0, attacker_before - attacker_remaining), "defender_loss": maxi(0, defender_before - defender_remaining),
	}


func _resolve_invasion_remaining_troops(before_troops: int, payload_survivors: int, loss_rate: float, minimum_when_present: int) -> int:
	var before := _clamp_invasion_troops(before_troops)
	if before <= 0:
		return 0
	var remaining := payload_survivors
	if remaining < 0:
		remaining = int(round(float(before) * (1.0 - clampf(loss_rate, 0.0, 1.0))))
	remaining = clampi(_clamp_invasion_troops(remaining), 0, before)
	if minimum_when_present > 0:
		remaining = clampi(maxi(minimum_when_present, remaining), 0, before)
	return remaining


func _resolve_occupation_troops(attacker_remaining: int, attacker_before: int, result_payload: Dictionary) -> int:
	var remaining := _clamp_invasion_troops(attacker_remaining)
	if remaining <= 0:
		var fallback_source := _get_result_troop_value(result_payload, ["attacker_troops", "enemy_troops"], attacker_before)
		remaining = _resolve_invasion_remaining_troops(fallback_source, -1, float(_config.get("attacker_win_attacker_loss_rate", 0.35)), 0)
	if remaining <= 0:
		return int(_config.get("minimum_occupation_troops", 80))
	return _clamp_invasion_troops(maxi(int(_config.get("minimum_occupation_troops", 80)), int(round(float(remaining) * 0.60))))


func _clamp_invasion_troops(troops: int) -> int:
	return clampi(troops, 0, int(_config.get("maximum_city_troops", 99999)))


func _get_result_troop_value(result_payload: Dictionary, keys: Array[String], fallback: int) -> int:
	for key in keys:
		if result_payload.has(key):
			return _clamp_invasion_troops(int(result_payload.get(key, fallback)))
	return fallback


func _result_tokens(result_payload: Dictionary) -> Array[String]:
	var result: Array[String] = []
	for key in ["result", "battle_result", "outcome", "state"]:
		if result_payload.has(key):
			result.append(str(result_payload.get(key, "")).to_lower())
	return result


func _q(query_id: String, args: Array = [], fallback: Variant = null) -> Variant:
	if not _query.is_valid():
		return fallback
	var value: Variant = _query.call(query_id, args)
	return fallback if value == null else value


func _has_city(city_id: String) -> bool:
	return not city_id.is_empty() and bool(_q("has_city", [city_id], false))


func _city_troops(city_id: String) -> int:
	return maxi(0, int(_q("city_troops", [city_id], 0)))


func _city_owner(city_id: String) -> String:
	return str(_q("city_owner", [city_id], ""))


func _faction_label(faction_id: String) -> String:
	return str(_q("faction_label", [faction_id], faction_id))


func _dictionary(value: Variant) -> Dictionary:
	return value if value is Dictionary else {}
