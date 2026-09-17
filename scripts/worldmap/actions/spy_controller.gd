class_name WorldMapSpyController
extends RefCounted

const SpyActionServiceScript := preload("res://scripts/worldmap/actions/spy_action_service.gd")
const SPY_ACTION_GATHER_INFO := SpyActionServiceScript.SPY_ACTION_GATHER_INFO
const SPY_ACTION_PUBLIC_SUPPORT_DISRUPT := SpyActionServiceScript.SPY_ACTION_PUBLIC_SUPPORT_DISRUPT
const SPY_ACTION_LOYALTY_DISRUPT := SpyActionServiceScript.SPY_ACTION_LOYALTY_DISRUPT
const SPY_ACTION_REVOLT_INSTIGATE := SpyActionServiceScript.SPY_ACTION_REVOLT_INSTIGATE
const SPY_ACTION_WEDGE := SpyActionServiceScript.SPY_ACTION_WEDGE
const SPY_COOLDOWN_TURNS := SpyActionServiceScript.SPY_COOLDOWN_TURNS
const SPY_PUBLIC_SUPPORT_DISRUPT_COST := SpyActionServiceScript.SPY_PUBLIC_SUPPORT_DISRUPT_COST
const SPY_PUBLIC_SUPPORT_DISRUPT_COOLDOWN_TURNS := SpyActionServiceScript.SPY_PUBLIC_SUPPORT_DISRUPT_COOLDOWN_TURNS
const SPY_DETECTED_RELATION_PENALTY_GATHER_INFO := SpyActionServiceScript.SPY_DETECTED_RELATION_PENALTY_GATHER_INFO
const SPY_DETECTED_RELATION_PENALTY_PUBLIC_SUPPORT := SpyActionServiceScript.SPY_DETECTED_RELATION_PENALTY_PUBLIC_SUPPORT
const SPY_LOYALTY_DISRUPT_COST := SpyActionServiceScript.SPY_LOYALTY_DISRUPT_COST
const SPY_LOYALTY_DISRUPT_COOLDOWN_TURNS := SpyActionServiceScript.SPY_LOYALTY_DISRUPT_COOLDOWN_TURNS
const SPY_DETECTED_RELATION_PENALTY_LOYALTY := SpyActionServiceScript.SPY_DETECTED_RELATION_PENALTY_LOYALTY
const SPY_REVOLT_INSTIGATION_COST := SpyActionServiceScript.SPY_REVOLT_INSTIGATION_COST
const SPY_REVOLT_INSTIGATION_COOLDOWN_TURNS := SpyActionServiceScript.SPY_REVOLT_INSTIGATION_COOLDOWN_TURNS
const SPY_REVOLT_INSTIGATION_DURATION_TURNS := SpyActionServiceScript.SPY_REVOLT_INSTIGATION_DURATION_TURNS
const SPY_DETECTED_RELATION_PENALTY_REVOLT := SpyActionServiceScript.SPY_DETECTED_RELATION_PENALTY_REVOLT
const SPY_WEDGE_COST := SpyActionServiceScript.SPY_WEDGE_COST
const SPY_WEDGE_COOLDOWN_TURNS := SpyActionServiceScript.SPY_WEDGE_COOLDOWN_TURNS
const SPY_DETECTED_RELATION_PENALTY_WEDGE := SpyActionServiceScript.SPY_DETECTED_RELATION_PENALTY_WEDGE

var _host: Node
var _service = SpyActionServiceScript.new()

var _player_state: Dictionary:
	get:
		return _host.get("_player_state")
	set(value):
		_host.set("_player_state", value)

var selected_city_marker:
	get:
		return _host.get("selected_city_marker")

var selected_city_id: String:
	get:
		return str(_host.get("selected_city_id"))

# Accessed dynamically by SpyActionService through Object.get()/set().
@warning_ignore("unused_private_class_variable")
var _city_runtime_states: Dictionary:
	get:
		return _host.get("_city_runtime_states")
	set(value):
		_host.set("_city_runtime_states", value)


func configure(host: Node) -> void:
	_host = host


func execute(action_id: String, target_city_id: String = "", source_city_id: String = "") -> Dictionary:
	return _service.execute(self, action_id, target_city_id, source_city_id)


func validate_spy_action(action_id: String, target_city_id: String = "") -> Dictionary:
	return _service.validate_action(self, action_id, target_city_id)


func get_spy_action_definition(action_id: String) -> Dictionary:
	return _service.get_action_definition(action_id)


func format_spy_validation_message(check: Dictionary) -> String:
	return _service.format_validation_message(check)


func advance_spy_cooldown_for_world_turn() -> Dictionary:
	return _service.advance_cooldown(self)


func advance_revolt_instigation_for_world_turn() -> Dictionary:
	return _service.advance_revolt_instigation(self)


func get_player_spy_tech_modifier(city_id: String = "") -> Dictionary:
	return _service.get_player_tech_modifier(self, city_id)


func get_city_security_score(city_id: String) -> int:
	return _service.get_city_security_score(self, city_id)


func normalize_city_intel_registry(raw_intel: Variant) -> Dictionary:
	var result := {}
	if not raw_intel is Dictionary:
		return result
	var allowed_fields := ["troops_estimated", "troops", "resources", "publicSupport", "loyalty", "governor", "tech"]
	for city_id_variant in (raw_intel as Dictionary).keys():
		var city_id := str(city_id_variant)
		if not bool(_host.call("_has_worldmap_city_for_trade_persistence", city_id)):
			continue
		var raw_entry: Variant = (raw_intel as Dictionary).get(city_id, {})
		if not raw_entry is Dictionary:
			continue
		var entry := raw_entry as Dictionary
		var fields: Array = []
		for field_variant in entry.get("fields", []):
			var field := str(field_variant)
			if allowed_fields.has(field) and not fields.has(field):
				fields.append(field)
		var payload: Dictionary = {}
		var raw_payload: Variant = entry.get("payload", entry.get("info", {}))
		if raw_payload is Dictionary:
			payload = (raw_payload as Dictionary).duplicate(true)
		result[city_id] = {
			"turn": maxi(0, int(entry.get("turn", 0))),
			"fields": fields,
			"estimated": bool(entry.get("estimated", fields.has("troops_estimated"))),
			"payload": payload,
		}
	return result


func _record_city_intel_from_spy_result(spy_result: Dictionary) -> void:
	if not bool(spy_result.get("success", false)):
		return
	var target_city_id := str(spy_result.get("target_city_id", ""))
	if not bool(_host.call("_has_worldmap_city_for_trade_persistence", target_city_id)):
		return
	var raw_payload: Variant = spy_result.get("payload", spy_result.get("info", {}))
	if not raw_payload is Dictionary or (raw_payload as Dictionary).is_empty():
		return
	var intel_registry := normalize_city_intel_registry(_player_state.get("city_intel", {}))
	var fields: Array = []
	if spy_result.get("fields", []) is Array:
		fields = (spy_result.get("fields", []) as Array).duplicate()
	intel_registry[target_city_id] = {
		"turn": maxi(1, int(spy_result.get("turn", _player_state.get("turn_number", 1)))),
		"fields": fields,
		"estimated": bool(spy_result.get("estimated", false)),
		"payload": (raw_payload as Dictionary).duplicate(true),
	}
	_player_state["city_intel"] = normalize_city_intel_registry(intel_registry)


# Diplomacy-owned relation/alliance boundary.
func _diplomacy() -> RefCounted:
	return _host.call("_ensure_diplomacy_controller")


func _adjust_faction_relation_score(a: String, b: String, delta: int, reason: String = "") -> Dictionary:
	return _diplomacy().call("apply_spy_relation_delta", a, b, delta, reason)


func _break_spy_wedge_alliance_if_needed(a: String, b: String, after_score: int) -> bool:
	return bool(_diplomacy().call("break_alliance_for_spy_wedge", a, b, after_score))


func _ensure_faction_relation_entry(a: String, b: String) -> Dictionary:
	return _diplomacy().call("_ensure_faction_relation_entry", a, b)


func _normalize_faction_relation_status(status: String) -> String:
	return str(_diplomacy().call("_normalize_faction_relation_status", status))


func _get_faction_relation_score(a: String, b: String) -> int:
	return int(_diplomacy().call("_get_faction_relation_score", a, b))


func _get_faction_relation_status(a: String, b: String) -> String:
	return str(_diplomacy().call("_get_faction_relation_status", a, b))


func _get_known_faction_ids_for_diplomacy() -> Array:
	return _diplomacy().call("_get_known_faction_ids_for_diplomacy")


# Generic worldmap/city/resource/technology adapters.
func _get_city_hud_entry(city_id: String) -> Dictionary: return _host.call("_get_city_hud_entry", city_id)
func _get_city_owner_faction_id(city: Dictionary) -> String: return str(_host.call("_get_city_owner_faction_id", city))
func _get_city_owner_faction_id_for_trade_display(city_id: String) -> String: return str(_host.call("_get_city_owner_faction_id_for_trade_display", city_id))
func _get_current_player_faction_id() -> String: return str(_host.call("_get_current_player_faction_id"))
func _is_city_owned_by_player_mvp(city_id: String) -> bool: return bool(_host.call("_is_city_owned_by_player_mvp", city_id))
func _get_hero_entry(hero_id: String) -> Dictionary: return _host.call("_get_hero_entry", hero_id)
func _get_current_chancellor_political_aptitude() -> int: return int(_host.call("_get_current_chancellor_political_aptitude"))
func _is_current_chancellor_political_type() -> bool: return bool(_host.call("_is_current_chancellor_political_type"))
func _get_city_security_required_troops(city: Dictionary) -> int: return int(_host.call("_get_city_security_required_troops", city))
func _get_city_troops_for_battle_context(city_id: String) -> int: return int(_host.call("_get_city_troops_for_battle_context", city_id))
func _get_city_loyalty_value(city: Dictionary) -> int: return int(_host.call("_get_city_loyalty_value", city))
func _get_city_public_support(city_id: String) -> int: return int(_host.call("_get_city_public_support", city_id))
func _set_city_loyalty_value(city_id: String, value: int) -> void: _host.call("_set_city_loyalty_value", city_id, value)
func _set_city_public_support(city_id: String, value: int) -> void: _host.call("_set_city_public_support", city_id, value)
func _format_city_name_by_id(city_id: String, fallback: String = "") -> String: return str(_host.call("_format_city_name_by_id", city_id, fallback))
func _can_pay_generic_resource_cost(cost: Dictionary) -> Dictionary: return _host.call("_can_pay_generic_resource_cost", cost)
func _apply_generic_resource_cost(cost: Dictionary) -> Dictionary: return _host.call("_apply_generic_resource_cost", cost)
func _get_domestic_tech_diplomacy_spy_bonus_mvp() -> Dictionary: return _host.call("_get_domestic_tech_diplomacy_spy_bonus_mvp")
func _get_domestic_tech_city_spy_intel_bonus_mvp(city_id: String) -> Dictionary: return _host.call("_get_domestic_tech_city_spy_intel_bonus_mvp", city_id)
func _get_unique_domestic_tech_source_ids_mvp(value: Variant) -> Array[String]: return _host.call("_get_unique_domestic_tech_source_ids_mvp", value)
func _has_domestic_tech_city_spy_intel_bonus_data_mvp(value: Dictionary) -> bool: return bool(_host.call("_has_domestic_tech_city_spy_intel_bonus_data_mvp", value))
func _merge_domestic_battle_source_techs_mvp(a: Variant, b: Variant) -> Array[String]: return _host.call("_merge_domestic_battle_source_techs_mvp", a, b)
func _has_completed_national_domestic_tech_mvp(tech_id: String) -> bool: return bool(_host.call("_has_completed_national_domestic_tech_mvp", tech_id))
func _append_domestic_modifier_source_if_completed_mvp(modifier: Dictionary, tech_id: String) -> void: _host.call("_append_domestic_modifier_source_if_completed_mvp", modifier, tech_id)
func _get_enemy_spy_resistance_baseline_mvp(city: Dictionary) -> Dictionary: return _host.call("_get_enemy_spy_resistance_baseline_mvp", city)
func _get_enemy_city_intel_resistance_baseline_mvp(city: Dictionary) -> Dictionary: return _host.call("_get_enemy_city_intel_resistance_baseline_mvp", city)
