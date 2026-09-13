class_name WorldMapSpyActionService
extends RefCounted

const DiplomacySpyHelpers := preload("res://scripts/worldmap/diplomacy_spy/diplomacy_spy_helpers.gd")

const ACTION_GATHER_INFO := "gather_info"
const ACTION_PUBLIC_SUPPORT_DISRUPT := "public_support_disrupt"
const ACTION_LOYALTY_DISRUPT := "loyalty_disrupt"
const ACTION_REVOLT_INSTIGATE := "revolt_instigate"
const ACTION_WEDGE := "wedge"
const SPY_ACTION_GATHER_INFO := ACTION_GATHER_INFO
const SPY_ACTION_PUBLIC_SUPPORT_DISRUPT := ACTION_PUBLIC_SUPPORT_DISRUPT
const SPY_ACTION_LOYALTY_DISRUPT := ACTION_LOYALTY_DISRUPT
const SPY_ACTION_REVOLT_INSTIGATE := ACTION_REVOLT_INSTIGATE
const SPY_ACTION_WEDGE := ACTION_WEDGE
const SPY_COOLDOWN_TURNS := 1
const SPY_PUBLIC_SUPPORT_DISRUPT_COST := {"gold": 300}
const SPY_PUBLIC_SUPPORT_DISRUPT_COOLDOWN_TURNS := 2
const SPY_DETECTED_RELATION_PENALTY_GATHER_INFO := -6
const SPY_DETECTED_RELATION_PENALTY_PUBLIC_SUPPORT := -10
const SPY_LOYALTY_DISRUPT_COST := {"gold": 500, "silk": 50}
const SPY_LOYALTY_DISRUPT_COOLDOWN_TURNS := 2
const SPY_DETECTED_RELATION_PENALTY_LOYALTY := -10
const SPY_REVOLT_INSTIGATION_COST := {"gold": 800, "silk": 100}
const SPY_REVOLT_INSTIGATION_COOLDOWN_TURNS := 2
const SPY_REVOLT_INSTIGATION_DURATION_TURNS := 3
const SPY_DETECTED_RELATION_PENALTY_REVOLT := -10
const SPY_WEDGE_COST := {"gold": 600, "silk": 150}
const SPY_WEDGE_COOLDOWN_TURNS := 12
const SPY_DETECTED_RELATION_PENALTY_WEDGE := -20
const CITY_PUBLIC_SUPPORT_DEFAULT := 70
const DIPLOMACY_SCORE_MIN := 0
const DIPLOMACY_SCORE_MAX := 100
const DIPLOMACY_DEFAULT_SCORE := 50
const ALLIANCE_ACCEPTANCE_THRESHOLD := 70
const FACTION_RELATION_STATUS := {"ALLIED": "allied", "NEUTRAL": "neutral", "HOSTILE": "hostile", "SUSPENDED": "suspended"}

var _adapter: Object
var _player_state: Dictionary:
	get:
		return _adapter.get("_player_state")
	set(value):
		_adapter.set("_player_state", value)

var selected_city_marker:
	get:
		return _adapter.get("selected_city_marker")

var selected_city_id: String:
	get:
		return str(_adapter.get("selected_city_id"))

var _city_runtime_states: Dictionary:
	get:
		return _adapter.get("_city_runtime_states")
	set(value):
		_adapter.set("_city_runtime_states", value)


@warning_ignore_start("inference_on_variant")
func execute(adapter: Object, action_id: String, target_city_id: String, _source_city_id: String = "") -> Dictionary:
	if adapter == null:
		return _failure("executor_unavailable", "첩보 행동 실행기를 찾을 수 없습니다.")
	_adapter = adapter
	var validation := _validate_spy_action(action_id, target_city_id)
	if not bool(validation.get("ok", false)):
		return _store_failed_spy_action_result(action_id, validation)
	var resolved_target := str(validation.get("target_city_id", target_city_id))
	match action_id:
		ACTION_GATHER_INFO:
			return _gather_spy_info(resolved_target)
		ACTION_PUBLIC_SUPPORT_DISRUPT:
			return _disrupt_city_public_support(resolved_target)
		ACTION_LOYALTY_DISRUPT:
			return _disrupt_city_loyalty(resolved_target)
		ACTION_REVOLT_INSTIGATE:
			return _instigate_revolt(resolved_target)
		ACTION_WEDGE:
			return _apply_spy_wedge_action(validation)
	return _store_failed_spy_action_result(action_id, {"reason": "invalid_action", "message": "알 수 없는 첩보 행동입니다.", "target_city_id": target_city_id})


func validate_action(adapter: Object, action_id: String, target_city_id: String = "") -> Dictionary:
	_adapter = adapter
	return _validate_spy_action(action_id, target_city_id)


func get_action_definition(action_id: String) -> Dictionary:
	return _get_spy_action_definition(action_id)


func format_validation_message(check: Dictionary) -> String:
	return _format_spy_validation_message(check)


func advance_cooldown(adapter: Object) -> Dictionary:
	_adapter = adapter
	return _advance_spy_cooldown_for_world_turn()


func advance_revolt_instigation(adapter: Object) -> Dictionary:
	_adapter = adapter
	return _advance_revolt_instigation_for_world_turn()


func get_player_tech_modifier(adapter: Object, city_id: String = "") -> Dictionary:
	_adapter = adapter
	return _get_player_spy_tech_modifier_mvp(city_id)


func get_city_security_score(adapter: Object, city_id: String) -> int:
	_adapter = adapter
	return _get_city_security_score_for_spy(city_id)



func _get_selected_spy_target() -> Dictionary:
	var target_city_id := ""
	if selected_city_marker != null:
		target_city_id = selected_city_marker.city_id
	elif not selected_city_id.is_empty():
		target_city_id = selected_city_id
	var city_data := _adapter.call("_get_city_hud_entry", target_city_id)
	var target_faction_id := _adapter.call("_get_city_owner_faction_id", city_data) if not city_data.is_empty() else ""
	return {
		"target_city_id": target_city_id,
		"target_faction_id": target_faction_id,
		"city_data": city_data,
	}


func _get_spy_action_definition(action_id: String) -> Dictionary:
	match action_id:
		SPY_ACTION_GATHER_INFO:
			return {"action_id": action_id, "label": "정탐", "result_key": "last_spy_result", "cooldown": _get_spy_cooldown_turns(), "message_success": "정탐에 성공했습니다.", "message_failure": "정탐에 실패했습니다."}
		SPY_ACTION_PUBLIC_SUPPORT_DISRUPT:
			return {"action_id": action_id, "label": "민심 교란", "result_key": "last_spy_public_support_disrupt_result", "cooldown": _get_spy_public_support_disrupt_cooldown_turns(), "message_success": "민심 교란에 성공했습니다.", "message_failure": "민심 교란에 실패했습니다."}
		SPY_ACTION_LOYALTY_DISRUPT:
			return {"action_id": action_id, "label": "성 충성도 교란", "result_key": "last_spy_loyalty_disrupt_result", "cooldown": _get_spy_action_cooldown_turns(SPY_LOYALTY_DISRUPT_COOLDOWN_TURNS), "message_success": "성 충성도 교란에 성공했습니다.", "message_failure": "성 충성도 교란에 실패했습니다."}
		SPY_ACTION_REVOLT_INSTIGATE:
			return {"action_id": action_id, "label": "반란 조장", "result_key": "last_spy_revolt_instigation_result", "cooldown": _get_spy_action_cooldown_turns(SPY_REVOLT_INSTIGATION_COOLDOWN_TURNS), "message_success": "반란 조장에 성공했습니다.", "message_failure": "반란 조장에 실패했습니다."}
		SPY_ACTION_WEDGE:
			return {"action_id": action_id, "label": "이간질", "result_key": "last_spy_wedge_result", "cooldown": _get_spy_action_cooldown_turns(SPY_WEDGE_COOLDOWN_TURNS), "message_success": "이간질에 성공했습니다.", "message_failure": "이간질에 실패했습니다.", "cost": SPY_WEDGE_COST.duplicate(true)}
		_:
			return {}


func _format_spy_validation_message(check: Dictionary) -> String:
	return DiplomacySpyHelpers.format_spy_validation_message(check)


func _validate_spy_action(action_id: String, target_city_id: String = "") -> Dictionary:
	var definition := _get_spy_action_definition(action_id)
	if definition.is_empty():
		return {"ok": false, "reason": "invalid_action", "message": _format_spy_validation_message({"reason": "invalid_action"})}
	var resolved_city_id := target_city_id
	if resolved_city_id.is_empty():
		resolved_city_id = str(_get_selected_spy_target().get("target_city_id", ""))
	var check := {}
	match action_id:
		SPY_ACTION_GATHER_INFO:
			check = _can_gather_spy_info(resolved_city_id)
		SPY_ACTION_PUBLIC_SUPPORT_DISRUPT:
			check = _can_disrupt_city_public_support(resolved_city_id)
		SPY_ACTION_LOYALTY_DISRUPT:
			check = _can_disrupt_city_loyalty(resolved_city_id)
		SPY_ACTION_REVOLT_INSTIGATE:
			check = _can_instigate_revolt(resolved_city_id)
		SPY_ACTION_WEDGE:
			check = _can_wedge_faction_relation(resolved_city_id)
		_:
			check = {"ok": false, "reason": "invalid_action"}
	var city_data := _adapter.call("_get_city_hud_entry", resolved_city_id)
	var target_faction_id := _adapter.call("_get_city_owner_faction_id", city_data) if not city_data.is_empty() else ""
	var result := check.duplicate(true)
	result["action_id"] = action_id
	result["action_label"] = str(definition.get("label", action_id))
	result["target_city_id"] = resolved_city_id
	result["target_faction_id"] = target_faction_id
	result["cooldown"] = int(definition.get("cooldown", 0))
	result["message"] = _format_spy_validation_message(result)
	return result


func _get_spy_result_key_for_action(action_id: String) -> String:
	var definition := _get_spy_action_definition(action_id)
	return str(definition.get("result_key", "last_spy_result"))


func _apply_spy_detection_relation_penalty(target_faction_id: String, relation_penalty: int, reason: String) -> Dictionary:
	if target_faction_id.is_empty() or relation_penalty == 0:
		return {"before_score": DIPLOMACY_DEFAULT_SCORE, "after_score": DIPLOMACY_DEFAULT_SCORE, "relation_penalty": 0}
	var relation_result := _adapter.call("_adjust_faction_relation_score", _adapter.call("_get_current_player_faction_id"), target_faction_id, relation_penalty, reason)
	return {
		"before_score": int(relation_result.get("before_score", relation_result.get("after_score", DIPLOMACY_DEFAULT_SCORE))),
		"after_score": int(relation_result.get("after_score", DIPLOMACY_DEFAULT_SCORE)),
		"relation_penalty": relation_penalty,
	}


func _store_failed_spy_action_result(action_id: String, validation: Dictionary) -> Dictionary:
	var definition := _get_spy_action_definition(action_id)
	var target_city_id := str(validation.get("target_city_id", ""))
	var city_data := _adapter.call("_get_city_hud_entry", target_city_id)
	var target_faction_id := str(validation.get("target_faction_id", _adapter.call("_get_city_owner_faction_id", city_data) if not city_data.is_empty() else ""))
	var result := {
		"turn": maxi(1, int(_player_state.get("turn_number", 1))),
		"action_id": action_id,
		"action_label": str(definition.get("label", action_id)),
		"target_city_id": target_city_id,
		"target_faction": target_faction_id,
		"target_faction_id": target_faction_id,
		"counterpart_faction_id": str(validation.get("counterpart_faction_id", "")),
		"success": false,
		"detected": false,
		"effect_applied": false,
		"success_valid": false,
		"reason": str(validation.get("reason", "unknown")),
		"relation_penalty": 0,
		"cost": validation.get("cost", {}),
		"cooldown": 0,
		"message": str(validation.get("message", _format_spy_validation_message(validation))),
	}
	_player_state[_get_spy_result_key_for_action(action_id)] = result
	return result


func _get_spy_info_success_chance() -> int:
	match _adapter.call("_get_current_chancellor_political_aptitude"):
		5:
			return 80
		4:
			return 65
		3:
			return 50
		2:
			return 35
		1:
			return 20
		_:
			return 0


func _get_city_security_score_for_spy(target_city_id: String) -> int:
	var city_data := _adapter.call("_get_city_hud_entry", target_city_id)
	if city_data.is_empty():
		return 0
	if city_data.has("security"):
		return clampi(int(city_data.get("security", 0)), 0, 100)
	if city_data.has("public_order"):
		return clampi(int(city_data.get("public_order", 0)), 0, 100)
	var domestic_seed: Dictionary = {}
	var raw_domestic_seed: Variant = city_data.get("domestic_seed", {})
	if raw_domestic_seed is Dictionary:
		domestic_seed = raw_domestic_seed as Dictionary
	if domestic_seed.has("publicOrder"):
		return clampi(int(domestic_seed.get("publicOrder", 0)), 0, 100)
	var required := maxi(1, _adapter.call("_get_city_security_required_troops", city_data))
	var troops := _adapter.call("_get_city_troops_for_battle_context", target_city_id)
	return clampi(int(round((float(troops) / float(required)) * 100.0)), 0, 100)


func _calculate_spy_detection_chance(target_city_id: String) -> int:
	var city_data := _adapter.call("_get_city_hud_entry", target_city_id)
	if city_data.is_empty():
		return 0
	var detection := 20
	var security := _get_city_security_score_for_spy(target_city_id)
	var loyalty := _adapter.call("_get_city_loyalty_value", city_data)
	if security >= 90:
		detection += 35
	elif security >= 70:
		detection += 20
	if loyalty >= 90:
		detection += 25
	elif loyalty >= 70:
		detection += 15
	if _adapter.call("_is_current_chancellor_political_type"):
		detection -= 10
	return clampi(detection, 0, 95)


func _get_spy_info_visibility_level(political_aptitude: int) -> Dictionary:
	var aptitude := clampi(political_aptitude, 0, 5)
	match aptitude:
		5:
			return {"fields": ["troops", "resources", "publicSupport", "loyalty", "governor", "tech"], "estimated": false}
		4:
			return {"fields": ["troops", "resources", "publicSupport", "loyalty"], "estimated": false}
		3:
			return {"fields": ["troops", "resources"], "estimated": false}
		2:
			return {"fields": ["troops"], "estimated": false}
		1:
			return {"fields": ["troops_estimated"], "estimated": true}
		_:
			return {"fields": [], "estimated": false}


func _can_gather_spy_info(target_city_id: String) -> Dictionary:
	var city_data := _adapter.call("_get_city_hud_entry", target_city_id)
	if target_city_id.is_empty() or city_data.is_empty():
		return {"ok": false, "reason": "invalid_target"}
	if _adapter.call("_is_city_owned_by_player_mvp", target_city_id):
		return {"ok": false, "reason": "own_city"}
	var chancellor_id := str(_player_state.get("chancellor_id", ""))
	if chancellor_id.is_empty() or _adapter.call("_get_hero_entry", chancellor_id).is_empty():
		return {"ok": false, "reason": "no_chancellor"}
	var political_aptitude: int = int(_adapter.call("_get_current_chancellor_political_aptitude"))
	if political_aptitude <= 0:
		return {"ok": false, "reason": "no_political_aptitude"}
	var spy_cooldown := maxi(0, int(_player_state.get("spy_cooldown", 0)))
	if spy_cooldown > 0:
		return {"ok": false, "reason": "cooldown", "cooldown": spy_cooldown}
	var security := _get_city_security_score_for_spy(target_city_id)
	var loyalty := _adapter.call("_get_city_loyalty_value", city_data)
	if security >= 100 and loyalty >= 100:
		return {"ok": false, "reason": "iron_wall", "security": security, "loyalty": loyalty}
	var visibility := _get_modified_spy_visibility_level_mvp(target_city_id, political_aptitude)
	var base_success_chance := _get_spy_info_success_chance()
	var base_detection_chance := _calculate_spy_detection_chance(target_city_id)
	return {
		"ok": true,
		"political_aptitude": political_aptitude,
		"success_chance": _get_modified_spy_success_chance_mvp(target_city_id, base_success_chance, SPY_ACTION_GATHER_INFO),
		"detection_chance": _get_modified_spy_detection_chance_mvp(target_city_id, base_detection_chance),
		"fields": visibility.get("fields", []),
		"estimated": bool(visibility.get("estimated", false)),
	}


func _roll_spy_info_result(target_city_id: String, forced_roll: int = -1, forced_detection_roll: int = -1) -> Dictionary:
	var check := _can_gather_spy_info(target_city_id)
	if not bool(check.get("ok", false)):
		return {
			"ok": false,
			"reason": str(check.get("reason", "unknown")),
			"target_city_id": target_city_id,
			"success": false,
			"detected": false,
		}
	var roll := forced_roll if forced_roll >= 0 else (randi() % 100) + 1
	var detection_roll := forced_detection_roll if forced_detection_roll >= 0 else (randi() % 100) + 1
	roll = clampi(roll, 1, 100)
	detection_roll = clampi(detection_roll, 1, 100)
	var success_chance := int(check.get("success_chance", 0))
	var detection_chance := int(check.get("detection_chance", 0))
	return {
		"ok": true,
		"target_city_id": target_city_id,
		"success": roll <= success_chance,
		"detected": detection_roll <= detection_chance,
		"roll": roll,
		"detection_roll": detection_roll,
		"success_chance": success_chance,
		"detection_chance": detection_chance,
		"political_aptitude": int(check.get("political_aptitude", 0)),
		"fields": check.get("fields", []),
		"estimated": bool(check.get("estimated", false)),
	}


func _build_spy_info_payload(target_city_id: String, fields: Array, estimated: bool = false) -> Dictionary:
	var city_data := _adapter.call("_get_city_hud_entry", target_city_id)
	if city_data.is_empty():
		return {}
	var payload := {"city_id": target_city_id, "city_name": _adapter.call("_format_city_name_by_id", target_city_id, target_city_id)}
	for field_variant in fields:
		var field := str(field_variant)
		match field:
			"troops":
				payload["troops"] = _adapter.call("_get_city_troops_for_battle_context", target_city_id)
			"troops_estimated":
				var troops := _adapter.call("_get_city_troops_for_battle_context", target_city_id)
				payload["troops_estimated"] = int(round(float(troops) / 500.0)) * 500
			"resources":
				if city_data.has("resource_seed") and city_data.get("resource_seed") is Dictionary:
					payload["resources"] = (city_data.get("resource_seed") as Dictionary).duplicate(true)
				elif city_data.has("resources"):
					payload["resources"] = str(city_data.get("resources", "not_available"))
				else:
					payload["resources"] = "not_available"
			"publicSupport":
				var domestic_seed: Dictionary = {}
				var raw_domestic_seed: Variant = city_data.get("domestic_seed", {})
				if raw_domestic_seed is Dictionary:
					domestic_seed = raw_domestic_seed as Dictionary
				if city_data.has("publicSupport"):
					payload["publicSupport"] = _adapter.call("_get_city_public_support", target_city_id)
				elif domestic_seed.has("publicSupport"):
					payload["publicSupport"] = clampi(int(domestic_seed.get("publicSupport", CITY_PUBLIC_SUPPORT_DEFAULT)), 0, 100)
				else:
					payload["publicSupport"] = "not_available"
			"loyalty":
				payload["loyalty"] = _adapter.call("_get_city_loyalty_value", city_data)
			"governor":
				var governor_id := str(city_data.get("governor_id", city_data.get("governorHeroId", "")))
				payload["governor"] = governor_id if not governor_id.is_empty() else "not_available"
			"tech":
				var tech_payload := {"city_completed": "not_available", "national_completed": "not_available"}
				if _city_runtime_states.has(target_city_id):
					var runtime_state: Dictionary = {}
					var raw_runtime_state: Variant = _city_runtime_states.get(target_city_id, {})
					if raw_runtime_state is Dictionary:
						runtime_state = raw_runtime_state as Dictionary
					var city_tech: Dictionary = {}
					var raw_city_tech: Variant = runtime_state.get("city_tech", {})
					if raw_city_tech is Dictionary:
						city_tech = raw_city_tech as Dictionary
					var completed: Dictionary = {}
					var raw_completed: Variant = city_tech.get("completed", {})
					if raw_completed is Dictionary:
						completed = raw_completed as Dictionary
					if not completed.is_empty():
						tech_payload["city_completed"] = completed.keys()
					else:
						tech_payload["city_completed"] = "not_available"
				payload["tech"] = tech_payload
	if estimated and not payload.has("troops_estimated") and payload.has("troops"):
		payload["troops_estimated"] = int(round(float(int(payload.get("troops", 0))) / 500.0)) * 500
		payload.erase("troops")
	return payload


func _get_spy_cooldown_turns() -> int:
	return maxi(1, SPY_COOLDOWN_TURNS - (2 if _adapter.call("_is_current_chancellor_political_type") else 0))


func _gather_spy_info(target_city_id: String, forced_roll: int = -1, forced_detection_roll: int = -1) -> Dictionary:
	var roll_result := _roll_spy_info_result(target_city_id, forced_roll, forced_detection_roll)
	var cooldown := 0
	var payload := {}
	var city_data := _adapter.call("_get_city_hud_entry", target_city_id)
	var target_faction_id := _adapter.call("_get_city_owner_faction_id", city_data) if not city_data.is_empty() else ""
	var relation_penalty := 0
	var relation_change := {"before_score": DIPLOMACY_DEFAULT_SCORE, "after_score": DIPLOMACY_DEFAULT_SCORE}
	if not target_faction_id.is_empty():
		var current_score := _adapter.call("_get_faction_relation_score", _adapter.call("_get_current_player_faction_id"), target_faction_id)
		relation_change = {"before_score": current_score, "after_score": current_score}
	if bool(roll_result.get("ok", false)):
		cooldown = _get_spy_cooldown_turns()
		_player_state["spy_cooldown"] = cooldown
		if bool(roll_result.get("success", false)):
			payload = _build_spy_info_payload(target_city_id, roll_result.get("fields", []), bool(roll_result.get("estimated", false)))
		if bool(roll_result.get("detected", false)):
			relation_penalty = SPY_DETECTED_RELATION_PENALTY_GATHER_INFO
			relation_change = _apply_spy_detection_relation_penalty(target_faction_id, relation_penalty, "spy_gather_info_detected")
	var result := {
		"turn": maxi(1, int(_player_state.get("turn_number", 1))),
		"action_id": SPY_ACTION_GATHER_INFO,
		"action_label": "정탐",
		"target_city_id": target_city_id,
		"target_faction": target_faction_id,
		"target_faction_id": target_faction_id,
		"success": bool(roll_result.get("success", false)),
		"detected": bool(roll_result.get("detected", false)),
		"roll": int(roll_result.get("roll", -1)),
		"detection_roll": int(roll_result.get("detection_roll", -1)),
		"success_chance": int(roll_result.get("success_chance", 0)),
		"detection_chance": int(roll_result.get("detection_chance", 0)),
		"political_aptitude": int(roll_result.get("political_aptitude", 0)),
		"fields": roll_result.get("fields", []),
		"payload": payload,
		"info": payload,
		"effect_applied": bool(roll_result.get("success", false)),
		"relation_penalty": relation_penalty,
		"before_score": int(relation_change.get("before_score", 0)),
		"after_score": int(relation_change.get("after_score", 0)),
		"cost": {},
		"cooldown": cooldown,
		"success_valid": bool(roll_result.get("ok", false)),
		"message": "정탐에 성공했습니다." if bool(roll_result.get("success", false)) else "정탐에 실패했습니다.",
	}
	if not bool(roll_result.get("ok", false)):
		result["reason"] = str(roll_result.get("reason", "unknown"))
	_player_state["last_spy_result"] = result
	_adapter.call("_record_city_intel_from_spy_result", result)
	return result


func _get_spy_public_support_disrupt_amount(political_aptitude: int) -> int:
	match clampi(political_aptitude, 0, 5):
		5:
			return 20
		4:
			return 15
		3:
			return 10
		2:
			return 5
		1:
			return 3
		_:
			return 0


func _get_spy_public_support_disrupt_cost(_target_city_id: String) -> Dictionary:
	return SPY_PUBLIC_SUPPORT_DISRUPT_COST.duplicate(true)


func _can_disrupt_city_public_support(target_city_id: String) -> Dictionary:
	var city_data := _adapter.call("_get_city_hud_entry", target_city_id)
	if target_city_id.is_empty() or city_data.is_empty():
		return {"ok": false, "reason": "invalid_target"}
	if _adapter.call("_is_city_owned_by_player_mvp", target_city_id):
		return {"ok": false, "reason": "own_city"}
	var chancellor_id := str(_player_state.get("chancellor_id", ""))
	if chancellor_id.is_empty() or _adapter.call("_get_hero_entry", chancellor_id).is_empty():
		return {"ok": false, "reason": "no_chancellor"}
	var political_aptitude := _adapter.call("_get_current_chancellor_political_aptitude")
	if political_aptitude <= 0:
		return {"ok": false, "reason": "no_political_aptitude"}
	var spy_cooldown := maxi(0, int(_player_state.get("spy_cooldown", 0)))
	if spy_cooldown > 0:
		return {"ok": false, "reason": "cooldown", "cooldown": spy_cooldown}
	var security := _get_city_security_score_for_spy(target_city_id)
	var loyalty := _adapter.call("_get_city_loyalty_value", city_data)
	if security >= 100 and loyalty >= 100:
		return {"ok": false, "reason": "iron_wall", "security": security, "loyalty": loyalty}
	return {
		"ok": true,
		"political_aptitude": political_aptitude,
		"effect_amount": _get_spy_public_support_disrupt_amount(political_aptitude),
		"cost": {},
		"success_chance": _get_modified_spy_success_chance_mvp(target_city_id, _get_spy_info_success_chance(), SPY_ACTION_PUBLIC_SUPPORT_DISRUPT),
		"detection_chance": _get_modified_spy_detection_chance_mvp(target_city_id, _calculate_spy_detection_chance(target_city_id)),
	}


func _roll_spy_public_support_disrupt_result(target_city_id: String, forced_roll: int = -1, forced_detection_roll: int = -1) -> Dictionary:
	var check := _can_disrupt_city_public_support(target_city_id)
	if not bool(check.get("ok", false)):
		return {
			"ok": false,
			"reason": str(check.get("reason", "unknown")),
			"target_city_id": target_city_id,
			"success": false,
			"detected": false,
		}
	var roll := forced_roll if forced_roll >= 0 else (randi() % 100) + 1
	var detection_roll := forced_detection_roll if forced_detection_roll >= 0 else (randi() % 100) + 1
	roll = clampi(roll, 1, 100)
	detection_roll = clampi(detection_roll, 1, 100)
	var success_chance := int(check.get("success_chance", 0))
	var detection_chance := int(check.get("detection_chance", 0))
	var detected := detection_roll <= detection_chance
	var success := roll <= success_chance
	return {
		"ok": true,
		"target_city_id": target_city_id,
		"political_aptitude": int(check.get("political_aptitude", 0)),
		"effect_amount": int(check.get("effect_amount", 0)),
		"cost": check.get("cost", {}),
		"roll": roll,
		"success_chance": success_chance,
		"success": success,
		"detection_roll": detection_roll,
		"detection_chance": detection_chance,
		"detected": detected,
		"effect_applied": success and not detected,
	}


func _get_spy_public_support_disrupt_cooldown_turns() -> int:
	return maxi(1, SPY_PUBLIC_SUPPORT_DISRUPT_COOLDOWN_TURNS - (2 if _adapter.call("_is_current_chancellor_political_type") else 0))


func _get_spy_action_cooldown_turns(base_cooldown: int) -> int:
	return maxi(1, base_cooldown - (2 if _adapter.call("_is_current_chancellor_political_type") else 0))


func _disrupt_city_public_support(target_city_id: String, forced_roll: int = -1, forced_detection_roll: int = -1) -> Dictionary:
	var check := _can_disrupt_city_public_support(target_city_id)
	var turn_number := maxi(1, int(_player_state.get("turn_number", 1)))
	var city_data := _adapter.call("_get_city_hud_entry", target_city_id)
	var target_faction := _adapter.call("_get_city_owner_faction_id", city_data) if not city_data.is_empty() else ""
	var before_support := _adapter.call("_get_city_public_support", target_city_id) if not city_data.is_empty() else CITY_PUBLIC_SUPPORT_DEFAULT
	if not bool(check.get("ok", false)):
		var failed_result := {
			"turn": turn_number,
			"action_id": SPY_ACTION_PUBLIC_SUPPORT_DISRUPT,
			"action_label": "민심 교란",
			"target_city_id": target_city_id,
			"target_faction": target_faction,
			"target_faction_id": target_faction,
			"success": false,
			"detected": false,
			"effect_applied": false,
			"reason": str(check.get("reason", "unknown")),
			"publicSupport_before": before_support,
			"publicSupport_after": before_support,
			"relation_penalty": 0,
			"cost": {},
			"cooldown": 0,
			"message": _format_spy_validation_message(check),
		}
		_player_state["last_spy_public_support_disrupt_result"] = failed_result
		return failed_result
	var roll_result := _roll_spy_public_support_disrupt_result(target_city_id, forced_roll, forced_detection_roll)
	var cost: Dictionary = check.get("cost", {})
	var payment_result := _adapter.call("_apply_generic_resource_cost", cost)
	var cooldown := _get_spy_public_support_disrupt_cooldown_turns()
	_player_state["spy_cooldown"] = cooldown
	var relation_penalty := 0
	var relation_change := {"before_score": DIPLOMACY_DEFAULT_SCORE, "after_score": DIPLOMACY_DEFAULT_SCORE}
	if not target_faction.is_empty():
		var current_score := _adapter.call("_get_faction_relation_score", _adapter.call("_get_current_player_faction_id"), target_faction)
		relation_change = {"before_score": current_score, "after_score": current_score}
	var after_support := before_support
	var effect_applied := bool(roll_result.get("effect_applied", false))
	if bool(roll_result.get("detected", false)):
		relation_penalty = SPY_DETECTED_RELATION_PENALTY_PUBLIC_SUPPORT
		if not target_faction.is_empty():
			relation_change = _apply_spy_detection_relation_penalty(target_faction, relation_penalty, "spy_public_support_disrupt_detected")
	elif effect_applied:
		after_support = clampi(before_support - int(roll_result.get("effect_amount", 0)), 0, 100)
		_adapter.call("_set_city_public_support", target_city_id, after_support)
	var result := {
		"turn": turn_number,
		"action_id": SPY_ACTION_PUBLIC_SUPPORT_DISRUPT,
		"action_label": "민심 교란",
		"target_city_id": target_city_id,
		"target_faction": target_faction,
		"target_faction_id": target_faction,
		"political_aptitude": int(roll_result.get("political_aptitude", 0)),
		"roll": int(roll_result.get("roll", -1)),
		"success_chance": int(roll_result.get("success_chance", 0)),
		"success": bool(roll_result.get("success", false)),
		"detection_roll": int(roll_result.get("detection_roll", -1)),
		"detection_chance": int(roll_result.get("detection_chance", 0)),
		"detected": bool(roll_result.get("detected", false)),
		"effect_amount": int(roll_result.get("effect_amount", 0)),
		"effect_applied": effect_applied and not bool(roll_result.get("detected", false)),
		"publicSupport_before": before_support,
		"publicSupport_after": after_support,
		"relation_penalty": relation_penalty,
		"before_score": int(relation_change.get("before_score", 0)),
		"after_score": int(relation_change.get("after_score", 0)),
		"cost": cost,
		"payment": payment_result,
		"cooldown": cooldown,
		"message": "민심 교란에 성공했습니다." if effect_applied and not bool(roll_result.get("detected", false)) else "민심 교란에 실패했습니다.",
	}
	_player_state["last_spy_public_support_disrupt_result"] = result
	return result


func _get_spy_loyalty_disrupt_amount(political_aptitude: int) -> int:
	match clampi(political_aptitude, 0, 5):
		5:
			return 10
		4:
			return 7
		3:
			return 5
		2:
			return 3
		1:
			return 1
		_:
			return 0


func _get_spy_loyalty_disrupt_cost(_target_city_id: String) -> Dictionary:
	return SPY_LOYALTY_DISRUPT_COST.duplicate(true)


func _can_disrupt_city_loyalty(target_city_id: String) -> Dictionary:
	var city_data := _adapter.call("_get_city_hud_entry", target_city_id)
	if target_city_id.is_empty() or city_data.is_empty():
		return {"ok": false, "reason": "invalid_target"}
	if _adapter.call("_is_city_owned_by_player_mvp", target_city_id):
		return {"ok": false, "reason": "own_city"}
	var chancellor_id := str(_player_state.get("chancellor_id", ""))
	if chancellor_id.is_empty() or _adapter.call("_get_hero_entry", chancellor_id).is_empty():
		return {"ok": false, "reason": "no_chancellor"}
	var political_aptitude := _adapter.call("_get_current_chancellor_political_aptitude")
	if political_aptitude <= 0:
		return {"ok": false, "reason": "no_political_aptitude"}
	var spy_cooldown := maxi(0, int(_player_state.get("spy_cooldown", 0)))
	if spy_cooldown > 0:
		return {"ok": false, "reason": "cooldown", "cooldown": spy_cooldown}
	var security := _get_city_security_score_for_spy(target_city_id)
	var loyalty := _adapter.call("_get_city_loyalty_value", city_data)
	if security >= 100 and loyalty >= 100:
		return {"ok": false, "reason": "iron_wall", "security": security, "loyalty": loyalty}
	return {
		"ok": true,
		"political_aptitude": political_aptitude,
		"effect_amount": _get_spy_loyalty_disrupt_amount(political_aptitude),
		"cost": {},
		"success_chance": _get_modified_spy_success_chance_mvp(target_city_id, _get_spy_info_success_chance(), SPY_ACTION_LOYALTY_DISRUPT),
		"detection_chance": _get_modified_spy_detection_chance_mvp(target_city_id, _calculate_spy_detection_chance(target_city_id)),
	}


func _roll_spy_loyalty_disrupt_result(target_city_id: String, forced_roll: int = -1, forced_detection_roll: int = -1) -> Dictionary:
	var check := _can_disrupt_city_loyalty(target_city_id)
	if not bool(check.get("ok", false)):
		return {"ok": false, "reason": str(check.get("reason", "unknown")), "target_city_id": target_city_id, "success": false, "detected": false}
	var roll := forced_roll if forced_roll >= 0 else (randi() % 100) + 1
	var detection_roll := forced_detection_roll if forced_detection_roll >= 0 else (randi() % 100) + 1
	roll = clampi(roll, 1, 100)
	detection_roll = clampi(detection_roll, 1, 100)
	var success_chance := int(check.get("success_chance", 0))
	var detection_chance := int(check.get("detection_chance", 0))
	var detected := detection_roll <= detection_chance
	var success := roll <= success_chance
	return {
		"ok": true,
		"target_city_id": target_city_id,
		"political_aptitude": int(check.get("political_aptitude", 0)),
		"effect_amount": int(check.get("effect_amount", 0)),
		"cost": check.get("cost", {}),
		"roll": roll,
		"success_chance": success_chance,
		"success": success,
		"detection_roll": detection_roll,
		"detection_chance": detection_chance,
		"detected": detected,
		"effect_applied": success and not detected,
	}


func _disrupt_city_loyalty(target_city_id: String, forced_roll: int = -1, forced_detection_roll: int = -1) -> Dictionary:
	var check := _can_disrupt_city_loyalty(target_city_id)
	var turn_number := maxi(1, int(_player_state.get("turn_number", 1)))
	var city_data := _adapter.call("_get_city_hud_entry", target_city_id)
	var target_faction := _adapter.call("_get_city_owner_faction_id", city_data) if not city_data.is_empty() else ""
	var before_loyalty := _adapter.call("_get_city_loyalty_value", city_data) if not city_data.is_empty() else 75
	if not bool(check.get("ok", false)):
		var failed_result := {
			"turn": turn_number,
			"action_id": SPY_ACTION_LOYALTY_DISRUPT,
			"action_label": "성 충성도 교란",
			"target_city_id": target_city_id,
			"target_faction": target_faction,
			"target_faction_id": target_faction,
			"success": false,
			"detected": false,
			"effect_applied": false,
			"reason": str(check.get("reason", "unknown")),
			"loyalty_before": before_loyalty,
			"loyalty_after": before_loyalty,
			"relation_penalty": 0,
			"cost": {},
			"cooldown": 0,
			"message": _format_spy_validation_message(check),
		}
		_player_state["last_spy_loyalty_disrupt_result"] = failed_result
		return failed_result
	var roll_result := _roll_spy_loyalty_disrupt_result(target_city_id, forced_roll, forced_detection_roll)
	var cost: Dictionary = check.get("cost", {})
	var payment_result := _adapter.call("_apply_generic_resource_cost", cost)
	var cooldown := _get_spy_action_cooldown_turns(SPY_LOYALTY_DISRUPT_COOLDOWN_TURNS)
	_player_state["spy_cooldown"] = cooldown
	var relation_penalty := 0
	var relation_change := {"before_score": DIPLOMACY_DEFAULT_SCORE, "after_score": DIPLOMACY_DEFAULT_SCORE}
	if not target_faction.is_empty():
		var current_score := _adapter.call("_get_faction_relation_score", _adapter.call("_get_current_player_faction_id"), target_faction)
		relation_change = {"before_score": current_score, "after_score": current_score}
	var after_loyalty := before_loyalty
	var effect_applied := bool(roll_result.get("effect_applied", false))
	if bool(roll_result.get("detected", false)):
		relation_penalty = SPY_DETECTED_RELATION_PENALTY_LOYALTY
		if not target_faction.is_empty():
			relation_change = _apply_spy_detection_relation_penalty(target_faction, relation_penalty, "spy_loyalty_disrupt_detected")
	elif effect_applied:
		after_loyalty = clampi(before_loyalty - int(roll_result.get("effect_amount", 0)), 0, 100)
		_adapter.call("_set_city_loyalty_value", target_city_id, after_loyalty)
	var result := {
		"turn": turn_number,
		"action_id": SPY_ACTION_LOYALTY_DISRUPT,
		"action_label": "성 충성도 교란",
		"target_city_id": target_city_id,
		"target_faction": target_faction,
		"target_faction_id": target_faction,
		"political_aptitude": int(roll_result.get("political_aptitude", 0)),
		"roll": int(roll_result.get("roll", -1)),
		"success_chance": int(roll_result.get("success_chance", 0)),
		"success": bool(roll_result.get("success", false)),
		"detection_roll": int(roll_result.get("detection_roll", -1)),
		"detection_chance": int(roll_result.get("detection_chance", 0)),
		"detected": bool(roll_result.get("detected", false)),
		"effect_amount": int(roll_result.get("effect_amount", 0)),
		"effect_applied": effect_applied and not bool(roll_result.get("detected", false)),
		"loyalty_before": before_loyalty,
		"loyalty_after": after_loyalty,
		"relation_penalty": relation_penalty,
		"before_score": int(relation_change.get("before_score", 0)),
		"after_score": int(relation_change.get("after_score", 0)),
		"cost": cost,
		"payment": payment_result,
		"cooldown": cooldown,
		"message": "성 충성도 교란에 성공했습니다." if effect_applied and not bool(roll_result.get("detected", false)) else "성 충성도 교란에 실패했습니다.",
	}
	_player_state["last_spy_loyalty_disrupt_result"] = result
	return result


func _get_spy_revolt_instigation_boost(political_aptitude: int) -> int:
	match clampi(political_aptitude, 0, 5):
		5:
			return 50
		4:
			return 35
		3:
			return 20
		2:
			return 10
		1:
			return 5
		_:
			return 0


func _get_spy_revolt_instigation_cost(_target_city_id: String) -> Dictionary:
	return SPY_REVOLT_INSTIGATION_COST.duplicate(true)


func _can_instigate_revolt(target_city_id: String) -> Dictionary:
	var city_data := _adapter.call("_get_city_hud_entry", target_city_id)
	if target_city_id.is_empty() or city_data.is_empty():
		return {"ok": false, "reason": "invalid_target"}
	if _adapter.call("_is_city_owned_by_player_mvp", target_city_id):
		return {"ok": false, "reason": "own_city"}
	var chancellor_id := str(_player_state.get("chancellor_id", ""))
	if chancellor_id.is_empty() or _adapter.call("_get_hero_entry", chancellor_id).is_empty():
		return {"ok": false, "reason": "no_chancellor"}
	var political_aptitude := _adapter.call("_get_current_chancellor_political_aptitude")
	if political_aptitude <= 0:
		return {"ok": false, "reason": "no_political_aptitude"}
	var spy_cooldown := maxi(0, int(_player_state.get("spy_cooldown", 0)))
	if spy_cooldown > 0:
		return {"ok": false, "reason": "cooldown", "cooldown": spy_cooldown}
	var security := _get_city_security_score_for_spy(target_city_id)
	var loyalty := _adapter.call("_get_city_loyalty_value", city_data)
	if security >= 100 and loyalty >= 100:
		return {"ok": false, "reason": "iron_wall", "security": security, "loyalty": loyalty}
	var public_support := _adapter.call("_get_city_public_support", target_city_id)
	if public_support > 50:
		return {"ok": false, "reason": "prerequisite_public_support", "publicSupport": public_support}
	if loyalty > 40:
		return {"ok": false, "reason": "prerequisite_loyalty", "loyalty": loyalty}
	return {
		"ok": true,
		"political_aptitude": political_aptitude,
		"probability_boost": _get_spy_revolt_instigation_boost(political_aptitude),
		"cost": {},
		"success_chance": _get_modified_spy_success_chance_mvp(target_city_id, _get_spy_info_success_chance(), SPY_ACTION_REVOLT_INSTIGATE),
		"detection_chance": _get_modified_spy_detection_chance_mvp(target_city_id, _calculate_spy_detection_chance(target_city_id)),
		"publicSupport": public_support,
		"loyalty": loyalty,
	}


func _roll_spy_revolt_instigation_result(target_city_id: String, forced_roll: int = -1, forced_detection_roll: int = -1) -> Dictionary:
	var check := _can_instigate_revolt(target_city_id)
	if not bool(check.get("ok", false)):
		return {"ok": false, "reason": str(check.get("reason", "unknown")), "target_city_id": target_city_id, "success": false, "detected": false}
	var roll := forced_roll if forced_roll >= 0 else (randi() % 100) + 1
	var detection_roll := forced_detection_roll if forced_detection_roll >= 0 else (randi() % 100) + 1
	roll = clampi(roll, 1, 100)
	detection_roll = clampi(detection_roll, 1, 100)
	var success_chance := int(check.get("success_chance", 0))
	var detection_chance := int(check.get("detection_chance", 0))
	var detected := detection_roll <= detection_chance
	var success := roll <= success_chance
	return {
		"ok": true,
		"target_city_id": target_city_id,
		"political_aptitude": int(check.get("political_aptitude", 0)),
		"probability_boost": int(check.get("probability_boost", 0)),
		"cost": check.get("cost", {}),
		"roll": roll,
		"success_chance": success_chance,
		"success": success,
		"detection_roll": detection_roll,
		"detection_chance": detection_chance,
		"detected": detected,
		"effect_applied": success and not detected,
	}


func _instigate_revolt(target_city_id: String, forced_roll: int = -1, forced_detection_roll: int = -1) -> Dictionary:
	var check := _can_instigate_revolt(target_city_id)
	var turn_number := maxi(1, int(_player_state.get("turn_number", 1)))
	var city_data := _adapter.call("_get_city_hud_entry", target_city_id)
	var target_faction := _adapter.call("_get_city_owner_faction_id", city_data) if not city_data.is_empty() else ""
	if not bool(check.get("ok", false)):
		var failed_result := {
			"turn": turn_number,
			"action_id": SPY_ACTION_REVOLT_INSTIGATE,
			"action_label": "반란 조장",
			"target_city_id": target_city_id,
			"target_faction": target_faction,
			"target_faction_id": target_faction,
			"success": false,
			"detected": false,
			"effect_applied": false,
			"reason": str(check.get("reason", "unknown")),
			"relation_penalty": 0,
			"cost": {},
			"cooldown": 0,
			"message": _format_spy_validation_message(check),
		}
		_player_state["last_spy_revolt_instigation_result"] = failed_result
		return failed_result
	var roll_result := _roll_spy_revolt_instigation_result(target_city_id, forced_roll, forced_detection_roll)
	var cost: Dictionary = check.get("cost", {})
	var payment_result := _adapter.call("_apply_generic_resource_cost", cost)
	var cooldown := _get_spy_action_cooldown_turns(SPY_REVOLT_INSTIGATION_COOLDOWN_TURNS)
	_player_state["spy_cooldown"] = cooldown
	var relation_penalty := 0
	var relation_change := {"before_score": DIPLOMACY_DEFAULT_SCORE, "after_score": DIPLOMACY_DEFAULT_SCORE}
	if not target_faction.is_empty():
		var current_score := _adapter.call("_get_faction_relation_score", _adapter.call("_get_current_player_faction_id"), target_faction)
		relation_change = {"before_score": current_score, "after_score": current_score}
	var effect_applied := bool(roll_result.get("effect_applied", false))
	if bool(roll_result.get("detected", false)):
		relation_penalty = SPY_DETECTED_RELATION_PENALTY_REVOLT
		if not target_faction.is_empty():
			relation_change = _apply_spy_detection_relation_penalty(target_faction, relation_penalty, "spy_revolt_instigation_detected")
	elif effect_applied:
		var instigations: Dictionary = {}
		var raw_instigations: Variant = _player_state.get("revolt_instigation", {})
		if raw_instigations is Dictionary:
			instigations = raw_instigations as Dictionary
		instigations[target_city_id] = {
			"turns_remaining": SPY_REVOLT_INSTIGATION_DURATION_TURNS,
			"probability_boost": int(roll_result.get("probability_boost", 0)),
			"source": "spy",
			"started_turn": turn_number,
		}
		_player_state["revolt_instigation"] = instigations
	var result := {
		"turn": turn_number,
		"action_id": SPY_ACTION_REVOLT_INSTIGATE,
		"action_label": "반란 조장",
		"target_city_id": target_city_id,
		"target_faction": target_faction,
		"target_faction_id": target_faction,
		"political_aptitude": int(roll_result.get("political_aptitude", 0)),
		"roll": int(roll_result.get("roll", -1)),
		"success_chance": int(roll_result.get("success_chance", 0)),
		"success": bool(roll_result.get("success", false)),
		"detection_roll": int(roll_result.get("detection_roll", -1)),
		"detection_chance": int(roll_result.get("detection_chance", 0)),
		"detected": bool(roll_result.get("detected", false)),
		"probability_boost": int(roll_result.get("probability_boost", 0)),
		"effect_applied": effect_applied and not bool(roll_result.get("detected", false)),
		"relation_penalty": relation_penalty,
		"before_score": int(relation_change.get("before_score", 0)),
		"after_score": int(relation_change.get("after_score", 0)),
		"cost": cost,
		"payment": payment_result,
		"cooldown": cooldown,
		"message": "반란 조장에 성공했습니다." if effect_applied and not bool(roll_result.get("detected", false)) else "반란 조장에 실패했습니다.",
	}
	_player_state["last_spy_revolt_instigation_result"] = result
	return result


func _advance_revolt_instigation_for_world_turn() -> Dictionary:
	var instigations: Dictionary = {}
	var raw_instigations: Variant = _player_state.get("revolt_instigation", {})
	if raw_instigations is Dictionary:
		instigations = raw_instigations as Dictionary
	var changed: Array = []
	var expired: Array = []
	for city_id_variant in instigations.keys():
		var city_id := str(city_id_variant)
		var entry_variant: Variant = instigations.get(city_id, {})
		if not entry_variant is Dictionary:
			expired.append(city_id)
			continue
		var entry := (entry_variant as Dictionary).duplicate(true)
		var before_turns := maxi(0, int(entry.get("turns_remaining", 0)))
		var after_turns := maxi(0, before_turns - 1)
		if after_turns <= 0:
			expired.append(city_id)
		else:
			entry["turns_remaining"] = after_turns
			instigations[city_id] = entry
			changed.append({"city_id": city_id, "before": before_turns, "after": after_turns})
	for city_id_variant in expired:
		instigations.erase(str(city_id_variant))
	_player_state["revolt_instigation"] = instigations
	var result := {
		"turn": maxi(1, int(_player_state.get("turn_number", 1))),
		"changed": changed,
		"expired": expired,
		"active_count": instigations.size(),
	}
	_player_state["last_revolt_instigation_tick_result"] = result
	return result


func _get_spy_wedge_relation_delta(political_aptitude: int) -> int:
	match clampi(political_aptitude, 0, 5):
		5:
			return 20
		4:
			return 15
		3:
			return 12
		2:
			return 12
		1:
			return 12
		_:
			return 0


func _get_spy_wedge_cost(_target_faction_a: String, _target_faction_b: String) -> Dictionary:
	return SPY_WEDGE_COST.duplicate(true)


func _calculate_spy_wedge_detection_chance(target_city_id: String = "") -> int:
	return clampi(_get_modified_spy_detection_chance_mvp(target_city_id, _calculate_spy_detection_chance(target_city_id)) + 10, 0, 95)


func _get_spy_wedge_candidate_faction_ids(target_faction_id: String) -> Array[String]:
	var result: Array[String] = []
	for faction_id_variant in _adapter.call("_get_known_faction_ids_for_diplomacy"):
		var faction_id := str(faction_id_variant)
		if faction_id.is_empty() or faction_id == _adapter.call("_get_current_player_faction_id") or faction_id == target_faction_id:
			continue
		result.append(faction_id)
	return result


func _get_spy_wedge_counterpart_faction_id(target_faction_id: String) -> String:
	if target_faction_id.is_empty() or target_faction_id == _adapter.call("_get_current_player_faction_id"):
		return ""
	var best_faction_id := ""
	var best_priority := -1
	var best_score := -1
	for candidate_faction_id in _get_spy_wedge_candidate_faction_ids(target_faction_id):
		var relation := _adapter.call("_ensure_faction_relation_entry", target_faction_id, candidate_faction_id)
		var status := _adapter.call("_normalize_faction_relation_status", str(relation.get("status", FACTION_RELATION_STATUS["NEUTRAL"])))
		var score := clampi(int(relation.get("score", DIPLOMACY_DEFAULT_SCORE)), DIPLOMACY_SCORE_MIN, DIPLOMACY_SCORE_MAX)
		var priority := 0
		if status == FACTION_RELATION_STATUS["ALLIED"]:
			priority = 4
		elif score >= 60:
			priority = 3
		elif int(relation.get("alliance_turns_remaining", 0)) > 0 or bool(relation.get("trade_agreement_active", false)) or int(relation.get("trade_agreement_turns_remaining", 0)) > 0:
			priority = 2
		else:
			priority = 1
		if priority > best_priority or (priority == best_priority and score > best_score):
			best_priority = priority
			best_score = score
			best_faction_id = candidate_faction_id
	return best_faction_id


func _get_spy_wedge_success_chance(target_city_id: String, counterpart_faction_id: String) -> int:
	var political_aptitude := _adapter.call("_get_current_chancellor_political_aptitude")
	var city_security := _get_city_security_score_for_spy(target_city_id)
	var target_faction_id: String = str(_adapter.call("_get_city_owner_faction_id_for_trade_display", target_city_id))
	var status: String = str(_adapter.call("_get_faction_relation_status", target_faction_id, counterpart_faction_id))
	var chance: int = 35 + political_aptitude * 8 - int(floor(float(city_security) / 10.0))
	if status == FACTION_RELATION_STATUS["ALLIED"]:
		chance += 5
	return clampi(_get_modified_spy_success_chance_mvp(target_city_id, chance, SPY_ACTION_WEDGE), 15, 80)


func _can_wedge_faction_relation(target_city_id: String) -> Dictionary:
	var city_data := _adapter.call("_get_city_hud_entry", target_city_id)
	if target_city_id.is_empty() or city_data.is_empty():
		return {"ok": false, "reason": "invalid_target"}
	if _adapter.call("_is_city_owned_by_player_mvp", target_city_id):
		return {"ok": false, "reason": "own_city"}
	var target_faction_id := _adapter.call("_get_city_owner_faction_id", city_data)
	if target_faction_id.is_empty() or target_faction_id == _adapter.call("_get_current_player_faction_id"):
		return {"ok": false, "reason": "invalid_target"}
	var chancellor_id := str(_player_state.get("chancellor_id", ""))
	if chancellor_id.is_empty() or _adapter.call("_get_hero_entry", chancellor_id).is_empty():
		return {"ok": false, "reason": "no_chancellor"}
	var political_aptitude := _adapter.call("_get_current_chancellor_political_aptitude")
	if political_aptitude <= 0:
		return {"ok": false, "reason": "no_political_aptitude"}
	var spy_cooldown := maxi(0, int(_player_state.get("spy_cooldown", 0)))
	if spy_cooldown > 0:
		return {"ok": false, "reason": "cooldown", "cooldown": spy_cooldown}
	var security := _get_city_security_score_for_spy(target_city_id)
	var loyalty := _adapter.call("_get_city_loyalty_value", city_data)
	if security >= 100 and loyalty >= 100:
		return {"ok": false, "reason": "iron_wall", "security": security, "loyalty": loyalty}
	var counterpart_faction_id := _get_spy_wedge_counterpart_faction_id(target_faction_id)
	if counterpart_faction_id.is_empty():
		return {"ok": false, "reason": "no_counterpart", "target_faction_id": target_faction_id}
	var relation := _adapter.call("_ensure_faction_relation_entry", target_faction_id, counterpart_faction_id)
	var relation_status := _adapter.call("_normalize_faction_relation_status", str(relation.get("status", FACTION_RELATION_STATUS["NEUTRAL"])))
	var relation_score := clampi(int(relation.get("score", DIPLOMACY_DEFAULT_SCORE)), DIPLOMACY_SCORE_MIN, DIPLOMACY_SCORE_MAX)
	if relation_status == FACTION_RELATION_STATUS["HOSTILE"] or relation_score <= 20:
		return {
			"ok": false,
			"reason": "already_hostile",
			"target_faction_id": target_faction_id,
			"counterpart_faction_id": counterpart_faction_id,
			"relation_score": relation_score,
			"relation_status": relation_status,
		}
	var cost := _get_spy_wedge_cost(target_faction_id, counterpart_faction_id)
	var payment_check := _adapter.call("_can_pay_generic_resource_cost", cost)
	if not bool(payment_check.get("ok", false)):
		return {
			"ok": false,
			"reason": "resources",
			"target_faction_id": target_faction_id,
			"counterpart_faction_id": counterpart_faction_id,
			"cost": cost,
			"missing": payment_check.get("missing", {}),
		}
	return {
		"ok": true,
		"political_aptitude": political_aptitude,
		"target_city_id": target_city_id,
		"target_faction_id": target_faction_id,
		"counterpart_faction_id": counterpart_faction_id,
		"relation_score": relation_score,
		"relation_status": relation_status,
		"relation_delta": -_get_spy_wedge_relation_delta(political_aptitude),
		"cost": cost,
		"success_chance": _get_spy_wedge_success_chance(target_city_id, counterpart_faction_id),
		"detection_chance": _calculate_spy_wedge_detection_chance(target_city_id),
	}


func _can_drive_wedge(target_faction_a: String, target_faction_b: String) -> Dictionary:
	if target_faction_a.is_empty() or target_faction_b.is_empty() or target_faction_a == target_faction_b:
		return {"ok": false, "reason": "invalid_target"}
	if target_faction_a == _adapter.call("_get_current_player_faction_id") or target_faction_b == _adapter.call("_get_current_player_faction_id"):
		return {"ok": false, "reason": "self_target"}
	var status := _adapter.call("_get_faction_relation_status", target_faction_a, target_faction_b)
	if status != FACTION_RELATION_STATUS["ALLIED"]:
		return {"ok": false, "reason": "not_allied", "status": status}
	var chancellor_id := str(_player_state.get("chancellor_id", ""))
	if chancellor_id.is_empty() or _adapter.call("_get_hero_entry", chancellor_id).is_empty():
		return {"ok": false, "reason": "no_chancellor"}
	var political_aptitude := _adapter.call("_get_current_chancellor_political_aptitude")
	if political_aptitude <= 0:
		return {"ok": false, "reason": "no_political_aptitude"}
	var spy_cooldown := maxi(0, int(_player_state.get("spy_cooldown", 0)))
	if spy_cooldown > 0:
		return {"ok": false, "reason": "cooldown", "cooldown": spy_cooldown}
	var cost := _get_spy_wedge_cost(target_faction_a, target_faction_b)
	var payment_check := _adapter.call("_can_pay_generic_resource_cost", cost)
	if not bool(payment_check.get("ok", false)):
		return {"ok": false, "reason": "resources", "cost": cost, "missing": payment_check.get("missing", {})}
	return {
		"ok": true,
		"political_aptitude": political_aptitude,
		"relation_delta": _get_spy_wedge_relation_delta(political_aptitude),
		"cost": cost,
		"success_chance": _get_modified_spy_success_chance_mvp("", _get_spy_info_success_chance(), SPY_ACTION_WEDGE),
		"detection_chance": clampi(_get_modified_spy_detection_chance_mvp("", _calculate_spy_wedge_detection_chance()), 0, 95),
		"status": status,
	}


func _roll_spy_wedge_result(target_faction_a: String, target_faction_b: String, forced_roll: int = -1, forced_detection_roll: int = -1) -> Dictionary:
	var check := _can_drive_wedge(target_faction_a, target_faction_b)
	if not bool(check.get("ok", false)):
		return {"ok": false, "reason": str(check.get("reason", "unknown")), "success": false, "detected": false}
	var roll := forced_roll if forced_roll >= 0 else (randi() % 100) + 1
	var detection_roll := forced_detection_roll if forced_detection_roll >= 0 else (randi() % 100) + 1
	roll = clampi(roll, 1, 100)
	detection_roll = clampi(detection_roll, 1, 100)
	var success_chance := int(check.get("success_chance", 0))
	var detection_chance := int(check.get("detection_chance", 0))
	var detected := detection_roll <= detection_chance
	var success := roll <= success_chance
	return {
		"ok": true,
		"target_faction_a": target_faction_a,
		"target_faction_b": target_faction_b,
		"political_aptitude": int(check.get("political_aptitude", 0)),
		"relation_delta": int(check.get("relation_delta", 0)),
		"cost": check.get("cost", {}),
		"roll": roll,
		"success_chance": success_chance,
		"success": success,
		"detection_roll": detection_roll,
		"detection_chance": detection_chance,
		"detected": detected,
		"effect_applied": success,
	}


func _drive_wedge(target_faction_a: String, target_faction_b: String, forced_roll: int = -1, forced_detection_roll: int = -1) -> Dictionary:
	var check := _can_drive_wedge(target_faction_a, target_faction_b)
	var turn_number := maxi(1, int(_player_state.get("turn_number", 1)))
	if not bool(check.get("ok", false)):
		var failed_result := {
			"turn": turn_number,
			"target_faction_a": target_faction_a,
			"target_faction_b": target_faction_b,
			"success": false,
			"detected": false,
			"effect_applied": false,
			"reason": str(check.get("reason", "unknown")),
			"relation_delta": 0,
			"player_relation_penalty": 0,
			"cost": check.get("cost", _get_spy_wedge_cost(target_faction_a, target_faction_b)),
			"cooldown": 0,
		}
		_player_state["last_spy_wedge_result"] = failed_result
		return failed_result
	var roll_result := _roll_spy_wedge_result(target_faction_a, target_faction_b, forced_roll, forced_detection_roll)
	var cost: Dictionary = check.get("cost", {})
	_adapter.call("_apply_generic_resource_cost", cost)
	var cooldown := _get_spy_action_cooldown_turns(SPY_WEDGE_COOLDOWN_TURNS)
	_player_state["spy_cooldown"] = cooldown
	var effect_applied := bool(roll_result.get("effect_applied", false))
	var player_relation_penalty := 0
	if bool(roll_result.get("detected", false)):
		player_relation_penalty = SPY_DETECTED_RELATION_PENALTY_WEDGE
		_adapter.call("_adjust_faction_relation_score", _adapter.call("_get_current_player_faction_id"), target_faction_a, player_relation_penalty, "spy_wedge_detected")
	if effect_applied:
		_adapter.call("_adjust_faction_relation_score", target_faction_a, target_faction_b, -int(roll_result.get("relation_delta", 0)), "spy_wedge")
	var result := {
		"turn": turn_number,
		"target_faction_a": target_faction_a,
		"target_faction_b": target_faction_b,
		"political_aptitude": int(roll_result.get("political_aptitude", 0)),
		"roll": int(roll_result.get("roll", -1)),
		"success_chance": int(roll_result.get("success_chance", 0)),
		"success": bool(roll_result.get("success", false)),
		"detection_roll": int(roll_result.get("detection_roll", -1)),
		"detection_chance": int(roll_result.get("detection_chance", 0)),
		"detected": bool(roll_result.get("detected", false)),
		"relation_delta": int(roll_result.get("relation_delta", 0)),
		"effect_applied": effect_applied,
		"player_relation_penalty": player_relation_penalty,
		"cost": cost,
		"cooldown": cooldown,
	}
	_player_state["last_spy_wedge_result"] = result
	return result


func _roll_spy_wedge_city_result(validation: Dictionary, forced_roll: int = -1, forced_detection_roll: int = -1) -> Dictionary:
	if not bool(validation.get("ok", false)):
		return {"ok": false, "reason": str(validation.get("reason", "unknown")), "success": false, "detected": false}
	var roll := forced_roll if forced_roll >= 0 else (randi() % 100) + 1
	var detection_roll := forced_detection_roll if forced_detection_roll >= 0 else (randi() % 100) + 1
	roll = clampi(roll, 1, 100)
	detection_roll = clampi(detection_roll, 1, 100)
	var success_chance := int(validation.get("success_chance", 0))
	var detection_chance := int(validation.get("detection_chance", 0))
	var success := roll <= success_chance
	var detected := detection_roll <= detection_chance
	return {
		"ok": true,
		"roll": roll,
		"success_chance": success_chance,
		"success": success,
		"detection_roll": detection_roll,
		"detection_chance": detection_chance,
		"detected": detected,
		"effect_applied": success,
	}


func _apply_spy_wedge_action(validation: Dictionary, forced_roll: int = -1, forced_detection_roll: int = -1) -> Dictionary:
	var target_city_id := str(validation.get("target_city_id", ""))
	var target_faction_id := str(validation.get("target_faction_id", ""))
	var counterpart_faction_id := str(validation.get("counterpart_faction_id", ""))
	var turn_number := maxi(1, int(_player_state.get("turn_number", 1)))
	var cost: Dictionary = validation.get("cost", _get_spy_wedge_cost(target_faction_id, counterpart_faction_id))
	var payment_result := _adapter.call("_apply_generic_resource_cost", cost)
	var cooldown := _get_spy_action_cooldown_turns(SPY_WEDGE_COOLDOWN_TURNS)
	_player_state["spy_cooldown"] = cooldown
	var roll_result := _roll_spy_wedge_city_result(validation, forced_roll, forced_detection_roll)
	var before_score := _adapter.call("_get_faction_relation_score", target_faction_id, counterpart_faction_id)
	var after_score := before_score
	var relation_delta := int(validation.get("relation_delta", 0))
	var alliance_broken := false
	if bool(roll_result.get("effect_applied", false)):
		var wedge_relation_result := _adapter.call("_adjust_faction_relation_score", target_faction_id, counterpart_faction_id, relation_delta, "spy_wedge")
		before_score = int(wedge_relation_result.get("before_score", before_score))
		after_score = int(wedge_relation_result.get("after_score", after_score))
		alliance_broken = _adapter.call("_break_spy_wedge_alliance_if_needed", target_faction_id, counterpart_faction_id, after_score)
	var relation_penalty := 0
	var player_before_score := _adapter.call("_get_faction_relation_score", _adapter.call("_get_current_player_faction_id"), target_faction_id)
	var player_after_score := player_before_score
	if bool(roll_result.get("detected", false)):
		relation_penalty = SPY_DETECTED_RELATION_PENALTY_WEDGE
		var detected_relation_result := _apply_spy_detection_relation_penalty(target_faction_id, relation_penalty, "spy_wedge_detected")
		player_before_score = int(detected_relation_result.get("before_score", player_before_score))
		player_after_score = int(detected_relation_result.get("after_score", player_after_score))
	var result := {
		"turn": turn_number,
		"action_id": SPY_ACTION_WEDGE,
		"action_label": "이간질",
		"target_city_id": target_city_id,
		"target_faction": target_faction_id,
		"target_faction_id": target_faction_id,
		"target_faction_a": target_faction_id,
		"counterpart_faction_id": counterpart_faction_id,
		"target_faction_b": counterpart_faction_id,
		"political_aptitude": int(validation.get("political_aptitude", 0)),
		"roll": int(roll_result.get("roll", -1)),
		"success_chance": int(roll_result.get("success_chance", 0)),
		"success": bool(roll_result.get("success", false)),
		"detection_roll": int(roll_result.get("detection_roll", -1)),
		"detection_chance": int(roll_result.get("detection_chance", 0)),
		"detected": bool(roll_result.get("detected", false)),
		"relation_delta": relation_delta if bool(roll_result.get("effect_applied", false)) else 0,
		"effect_applied": bool(roll_result.get("effect_applied", false)),
		"before_score": before_score,
		"after_score": after_score,
		"alliance_broken": alliance_broken,
		"relation_penalty": relation_penalty,
		"player_before_score": player_before_score,
		"player_after_score": player_after_score,
		"cost": cost,
		"payment": payment_result,
		"cooldown": cooldown,
		"message": "이간질에 성공했습니다." if bool(roll_result.get("effect_applied", false)) else "이간질에 실패했습니다.",
	}
	_player_state["last_spy_wedge_result"] = result
	return result


func _advance_spy_cooldown_for_world_turn() -> Dictionary:
	var before_cooldown := maxi(0, int(_player_state.get("spy_cooldown", 0)))
	var after_cooldown := maxi(0, before_cooldown - 1)
	_player_state["spy_cooldown"] = after_cooldown
	var result := {
		"turn": maxi(1, int(_player_state.get("turn_number", 1))),
		"before": before_cooldown,
		"after": after_cooldown,
		"changed": before_cooldown != after_cooldown,
	}
	_player_state["last_spy_cooldown_result"] = result
	return result


func _get_empty_domestic_spy_modifier_mvp() -> Dictionary:
	return {
		"spy_success_pct": 0.0,
		"spy_detection_reduction_pct": 0.0,
		"intel_visibility_pct": 0.0,
		"loyalty_disrupt_bonus_pct": 0.0,
		"revolt_instigation_bonus_pct": 0.0,
		"discord_bonus_pct": 0.0,
		"counter_spy_pct": 0.0,
		"corruption_detection_pct": 0.0,
		"source_techs": [],
	}


func _get_player_spy_tech_modifier_mvp(city_id: String = "") -> Dictionary:
	var modifier := _get_empty_domestic_spy_modifier_mvp()
	var bonus := _adapter.call("_get_domestic_tech_diplomacy_spy_bonus_mvp")
	var city_bonus := _adapter.call("_get_domestic_tech_city_spy_intel_bonus_mvp", city_id)
	modifier["spy_success_pct"] = float(modifier.get("spy_success_pct", 0.0)) + float(bonus.get("spy_preparation_percent", 0.0))
	modifier["intel_visibility_pct"] = float(modifier.get("intel_visibility_pct", 0.0)) + minf(0.08, float(int(bonus.get("spy_network_flat", 0))) * 0.00625)
	modifier["spy_success_pct"] = float(modifier.get("spy_success_pct", 0.0)) + minf(0.04, float(int(bonus.get("spy_network_flat", 0))) * 0.00375)
	modifier["spy_detection_reduction_pct"] = float(modifier.get("spy_detection_reduction_pct", 0.0)) + float(bonus.get("counter_intel_display_percent", 0.0))
	modifier["counter_spy_pct"] = float(modifier.get("counter_spy_pct", 0.0)) + float(bonus.get("counter_intel_display_percent", 0.0))
	modifier["source_techs"] = _adapter.call("_get_unique_domestic_tech_source_ids_mvp", bonus.get("source_techs", []))
	if _adapter.call("_has_domestic_tech_city_spy_intel_bonus_data_mvp", city_bonus):
		modifier["spy_success_pct"] = float(modifier.get("spy_success_pct", 0.0)) + float(city_bonus.get("local_intel_readiness_percent", 0.0))
		modifier["spy_detection_reduction_pct"] = float(modifier.get("spy_detection_reduction_pct", 0.0)) + float(city_bonus.get("local_counter_intel_display_percent", 0.0))
		modifier["intel_visibility_pct"] = float(modifier.get("intel_visibility_pct", 0.0)) + minf(0.05, float(int(city_bonus.get("local_spy_network_flat", 0))) * 0.005)
		modifier["source_techs"] = _adapter.call("_merge_domestic_battle_source_techs_mvp", modifier.get("source_techs", []), city_bonus.get("source_techs", []))
	if _adapter.call("_has_completed_national_domestic_tech_mvp", "nation_bureaucracy"):
		modifier["spy_detection_reduction_pct"] = float(modifier.get("spy_detection_reduction_pct", 0.0)) + 0.03
		_adapter.call("_append_domestic_modifier_source_if_completed_mvp", modifier, "nation_bureaucracy")
	if _adapter.call("_has_completed_national_domestic_tech_mvp", "nation_local_administration"):
		modifier["intel_visibility_pct"] = float(modifier.get("intel_visibility_pct", 0.0)) + 0.03
		_adapter.call("_append_domestic_modifier_source_if_completed_mvp", modifier, "nation_local_administration")
	if _adapter.call("_has_completed_national_domestic_tech_mvp", "nation_centralization"):
		modifier["counter_spy_pct"] = float(modifier.get("counter_spy_pct", 0.0)) + 0.03
		_adapter.call("_append_domestic_modifier_source_if_completed_mvp", modifier, "nation_centralization")
	if _adapter.call("_has_completed_national_domestic_tech_mvp", "nation_anti_corruption"):
		modifier["counter_spy_pct"] = float(modifier.get("counter_spy_pct", 0.0)) + 0.03
		modifier["corruption_detection_pct"] = float(modifier.get("corruption_detection_pct", 0.0)) + 0.05
		_adapter.call("_append_domestic_modifier_source_if_completed_mvp", modifier, "nation_anti_corruption")
	if _adapter.call("_has_completed_national_domestic_tech_mvp", "nation_intelligence_org"):
		modifier["loyalty_disrupt_bonus_pct"] = float(modifier.get("loyalty_disrupt_bonus_pct", 0.0)) + 0.05
		modifier["revolt_instigation_bonus_pct"] = float(modifier.get("revolt_instigation_bonus_pct", 0.0)) + 0.05
		modifier["discord_bonus_pct"] = float(modifier.get("discord_bonus_pct", 0.0)) + 0.05
		_adapter.call("_append_domestic_modifier_source_if_completed_mvp", modifier, "nation_intelligence_org")
	modifier["source_techs"] = _adapter.call("_get_unique_domestic_tech_source_ids_mvp", modifier.get("source_techs", []))
	return modifier


func _has_domestic_spy_modifier_data_mvp(modifier: Dictionary) -> bool:
	return not is_equal_approx(float(modifier.get("spy_success_pct", 0.0)), 0.0) \
		or not is_equal_approx(float(modifier.get("spy_detection_reduction_pct", 0.0)), 0.0) \
		or not is_equal_approx(float(modifier.get("intel_visibility_pct", 0.0)), 0.0) \
		or not is_equal_approx(float(modifier.get("loyalty_disrupt_bonus_pct", 0.0)), 0.0) \
		or not is_equal_approx(float(modifier.get("revolt_instigation_bonus_pct", 0.0)), 0.0) \
		or not is_equal_approx(float(modifier.get("discord_bonus_pct", 0.0)), 0.0) \
		or not is_equal_approx(float(modifier.get("counter_spy_pct", 0.0)), 0.0) \
		or not is_equal_approx(float(modifier.get("corruption_detection_pct", 0.0)), 0.0)


func _get_modified_spy_success_chance_mvp(target_city_id: String, base_chance: int, action_id: String = SPY_ACTION_GATHER_INFO) -> int:
	var modifier := _get_player_spy_tech_modifier_mvp(target_city_id)
	var bonus_pct := float(modifier.get("spy_success_pct", 0.0))
	match action_id:
		SPY_ACTION_LOYALTY_DISRUPT:
			bonus_pct += float(modifier.get("loyalty_disrupt_bonus_pct", 0.0))
		SPY_ACTION_REVOLT_INSTIGATE:
			bonus_pct += float(modifier.get("revolt_instigation_bonus_pct", 0.0))
		SPY_ACTION_WEDGE:
			bonus_pct += float(modifier.get("discord_bonus_pct", 0.0))
		_:
			pass
	var city_data := _adapter.call("_get_city_hud_entry", target_city_id)
	var enemy_baseline := _adapter.call("_get_enemy_spy_resistance_baseline_mvp", city_data)
	if not bool(enemy_baseline.get("masked", true)):
		bonus_pct -= float(enemy_baseline.get("spy_resistance_pct", 0.0))
	return clampi(base_chance + int(round(bonus_pct * 100.0)), 0, 95)


func _get_modified_spy_detection_chance_mvp(target_city_id: String, base_detection: int) -> int:
	var modifier := _get_player_spy_tech_modifier_mvp(target_city_id)
	var reduction_pct := float(modifier.get("spy_detection_reduction_pct", 0.0))
	var city_data := _adapter.call("_get_city_hud_entry", target_city_id)
	var enemy_baseline := _adapter.call("_get_enemy_spy_resistance_baseline_mvp", city_data)
	if not bool(enemy_baseline.get("masked", true)):
		reduction_pct -= float(enemy_baseline.get("detection_bonus_pct", 0.0))
	return clampi(base_detection - int(round(reduction_pct * 100.0)), 0, 95)


func _get_modified_spy_visibility_level_mvp(target_city_id: String, political_aptitude: int) -> Dictionary:
	var visibility := _get_spy_info_visibility_level(political_aptitude)
	var fields: Array[String] = []
	for field_variant in visibility.get("fields", []):
		fields.append(str(field_variant))
	var modifier := _get_player_spy_tech_modifier_mvp(target_city_id)
	var visibility_bonus := float(modifier.get("intel_visibility_pct", 0.0))
	var city_data := _adapter.call("_get_city_hud_entry", target_city_id)
	var enemy_baseline := _adapter.call("_get_enemy_city_intel_resistance_baseline_mvp", city_data)
	if not bool(enemy_baseline.get("masked", true)):
		visibility_bonus -= float(enemy_baseline.get("intel_visibility_resistance_pct", 0.0))
	if visibility_bonus >= 0.05:
		if not fields.has("resources") and (fields.has("troops") or fields.has("troops_estimated")):
			fields.append("resources")
		elif not fields.has("publicSupport") and fields.has("resources"):
			fields.append("publicSupport")
		elif not fields.has("loyalty") and fields.has("publicSupport"):
			fields.append("loyalty")
		elif not fields.has("governor") and fields.has("loyalty"):
			fields.append("governor")
	return {
		"fields": fields,
		"estimated": bool(visibility.get("estimated", false)),
	}


func _failure(reason: String, message: String) -> Dictionary:
	return {"ok": false, "success": false, "reason": reason, "message": message}
