class_name WorldMapDiplomacyPresentationHelper
extends RefCounted

const ControllerScript := preload("res://scripts/worldmap/actions/diplomacy_controller.gd")
const DiplomacyActionServiceScript := preload("res://scripts/worldmap/actions/diplomacy_action_service.gd")
const DiplomacySpyHelpers := preload("res://scripts/worldmap/diplomacy_spy/diplomacy_spy_helpers.gd")
const FACTION_RELATION_STATUS := ControllerScript.FACTION_RELATION_STATUS
const DIPLOMACY_ACTION_ENVOY := ControllerScript.DIPLOMACY_ACTION_ENVOY
const DIPLOMACY_ACTION_TRIBUTE := ControllerScript.DIPLOMACY_ACTION_TRIBUTE
const DIPLOMACY_ACTION_TRADE_AGREEMENT := ControllerScript.DIPLOMACY_ACTION_TRADE_AGREEMENT
const DIPLOMACY_ACTION_RESTORE_RELATIONS := ControllerScript.DIPLOMACY_ACTION_RESTORE_RELATIONS
const DIPLOMACY_ACTION_ALLIANCE_PROPOSAL := ControllerScript.DIPLOMACY_ACTION_ALLIANCE_PROPOSAL

var _controller: ControllerScript
var _host: Node
var _player_state: Dictionary:
	get:
		return _host.get("_player_state")
var RESOURCE_LABELS: Dictionary:
	get:
		return _host.get("RESOURCE_LABELS")
var FACTION_LABELS: Dictionary:
	get:
		return _host.get("FACTION_LABELS")


func configure(host: Node, controller: ControllerScript) -> void:
	_host = host
	_controller = controller


func _format_diplomacy_owner_display(city_marker: WorldMapCityMarker) -> String:
	if city_marker == null:
		return "소유 세력\n세력 미확인"
	var owner_id := _controller._get_city_owner_faction_id_for_trade_display(city_marker.city_id)
	if owner_id.is_empty():
		return "소유 세력\n세력 미확인"
	return "소유 세력\n%s" % _format_faction_label(owner_id)


func _format_diplomacy_relation_summary_for_ui(city_marker: WorldMapCityMarker) -> String:
	if city_marker == null:
		return "관계 상태\n관계 미확인"
	var owner_id := _controller._get_city_owner_faction_id_for_trade_display(city_marker.city_id)
	if owner_id.is_empty():
		return "관계 상태\n관계 미확인"
	if owner_id == _controller._get_current_player_faction_id():
		return "관계 상태\n자국 도시"
	var status := _controller._get_faction_relation_status(_controller._get_current_player_faction_id(), owner_id)
	var score := _controller._get_faction_relation_score(_controller._get_current_player_faction_id(), owner_id)
	return "관계 상태\n%s · 관계 점수 %d" % [
		_format_diplomacy_relation_status_for_ui(status),
		score,
	]


func _format_diplomacy_relation_status_for_ui(status: String) -> String:
	return DiplomacySpyHelpers.format_diplomacy_relation_status_for_ui(status)


func _format_diplomacy_trade_status_for_ui(city_marker: WorldMapCityMarker) -> String:
	if city_marker == null:
		return "교역 상태\n관계 미확인"
	var owner_id := _controller._get_city_owner_faction_id_for_trade_display(city_marker.city_id)
	if owner_id.is_empty():
		return "교역 상태\n관계 미확인"
	if owner_id == _controller._get_current_player_faction_id():
		return "교역 상태\n자국 관리 대상"
	var trade_status := "교역 제한"
	if _can_trade_between_factions(_controller._get_current_player_faction_id(), owner_id):
		trade_status = "교역 가능"
	return "교역 상태\n%s" % trade_status


func _format_diplomacy_action_candidates_for_ui(city_marker: WorldMapCityMarker) -> String:
	if city_marker == null:
		return "외교 행동\n도시를 선택하면 외교 후보가 표시됩니다."
	var owner_id := _controller._get_city_owner_faction_id_for_trade_display(city_marker.city_id)
	if owner_id.is_empty():
		return "외교 행동\n소유 세력 확인이 필요합니다."
	if owner_id == _controller._get_current_player_faction_id():
		return "외교 행동\n자국 도시는 외교 대상이 아닙니다."
	var status := _controller._get_faction_relation_status(_controller._get_current_player_faction_id(), owner_id)
	if status == FACTION_RELATION_STATUS["HOSTILE"] or status == FACTION_RELATION_STATUS["SUSPENDED"]:
		return "외교 행동\n관계 회복 / 사절 파견 / 조공"
	return "외교 행동\n사절 파견 / 조공 / 교역 협정"


func _format_diplomacy_policy_display_for_ui(city_marker: WorldMapCityMarker) -> String:
	if city_marker == null:
		return "외교 판단\n도시를 선택하면 외교 판단이 표시됩니다."
	var owner_id := _controller._get_city_owner_faction_id_for_trade_display(city_marker.city_id)
	if owner_id.is_empty():
		return "외교 판단\n소유 세력 확인이 필요합니다."
	if owner_id == _controller._get_current_player_faction_id():
		return "외교 판단\n자국 도시는 외교 대상이 아닙니다."
	var recent_summary := _format_last_diplomacy_action_result_for_ui(owner_id)
	var modifier_summary := _format_player_diplomacy_tech_modifier_summary_mvp(owner_id)
	if modifier_summary.is_empty():
		return recent_summary
	return "%s\n%s" % [recent_summary, modifier_summary]


func _format_diplomacy_action_hint(validation_map: Dictionary) -> String:
	var enabled_parts: Array[String] = []
	var blocked_parts: Array[String] = []
	for action_id in [DIPLOMACY_ACTION_ENVOY, DIPLOMACY_ACTION_TRIBUTE, DIPLOMACY_ACTION_TRADE_AGREEMENT, DIPLOMACY_ACTION_RESTORE_RELATIONS, DIPLOMACY_ACTION_ALLIANCE_PROPOSAL]:
		var validation: Dictionary = validation_map.get(action_id, {})
		var definition := _controller._get_diplomacy_action_definition(action_id)
		var label_text := str(definition.get("label", action_id))
		if bool(validation.get("ok", false)):
			var cost: Dictionary = validation.get("cost", {})
			if action_id == DIPLOMACY_ACTION_ALLIANCE_PROPOSAL:
				enabled_parts.append("%s: 비용 %s · 수락 %d/%d" % [
					label_text,
					_format_resource_costs(cost, ["gold", "silk"]),
					int(validation.get("acceptance_score", 0)),
					int(validation.get("required_score", DiplomacyActionServiceScript.ALLIANCE_ACCEPTANCE_THRESHOLD)),
				])
			else:
				enabled_parts.append("%s: 비용 %s" % [label_text, _format_resource_costs(cost, ["gold"])])
		else:
			blocked_parts.append("%s: %s" % [label_text, str(validation.get("message", "불가"))])
	if not enabled_parts.is_empty():
		return "행동 가능\n%s" % "\n".join(enabled_parts)
	if not blocked_parts.is_empty():
		return "행동 불가\n%s" % blocked_parts[0]
	return "외교 행동 조건을 확인합니다."


func _format_last_diplomacy_action_result_for_ui(target_faction_id: String = "") -> String:
	var result_variant: Variant = _player_state.get("last_diplomacy_action_result", {})
	if not result_variant is Dictionary or (result_variant as Dictionary).is_empty():
		return "최근 외교\n기록 없음"
	var result := result_variant as Dictionary
	if not target_faction_id.is_empty() and str(result.get("target_faction_id", "")) != target_faction_id:
		return "최근 외교\n선택 세력 관련 기록 없음"
	var diplomacy_target_label := _format_faction_label(str(result.get("target_faction_id", "")))
	var action_id := str(result.get("action_id", ""))
	if action_id == DIPLOMACY_ACTION_ALLIANCE_PROPOSAL:
		if bool(result.get("accepted", false)):
			return "최근 외교\n동맹 체결 성공 → %s\n%d턴 / 수락 점수 %d / 기준 %d" % [
				diplomacy_target_label,
				int(result.get("alliance_turns_remaining", result.get("duration_turns", 0))),
				int(result.get("acceptance_score", result.get("acceptance_chance", 0))),
				int(result.get("required_score", result.get("acceptance_threshold", DiplomacyActionServiceScript.ALLIANCE_ACCEPTANCE_THRESHOLD))),
			]
		if str(result.get("reason", "")) == "rejected":
			return "최근 외교\n동맹 제안 거절 → %s\n수락 점수 %d / 기준 %d" % [
				diplomacy_target_label,
				int(result.get("acceptance_score", result.get("acceptance_chance", 0))),
				int(result.get("required_score", result.get("acceptance_threshold", DiplomacyActionServiceScript.ALLIANCE_ACCEPTANCE_THRESHOLD))),
			]
	if not bool(result.get("success", false)):
		return "최근 외교\n실패: %s" % str(result.get("message", "실행 실패"))
	var action_label := str(result.get("action_label", result.get("action_id", "외교")))
	var relation_line := "관계 %d → %d" % [int(result.get("before_score", 0)), int(result.get("after_score", 0))]
	var result_cost: Dictionary = result.get("cost", {})
	var gold_cost := maxi(0, int(result_cost.get("gold", 0)))
	var cost_text := "%s -%d" % [str(RESOURCE_LABELS.get("gold", "금전")), gold_cost] if gold_cost > 0 else _format_resource_costs(result_cost, ["gold"])
	if str(result.get("action_id", "")) == DIPLOMACY_ACTION_TRADE_AGREEMENT:
		var agreement: Dictionary = result.get("agreement", {})
		return "최근 외교\n%s → %s\n효율 보정 %d턴 / %s" % [
			action_label,
			diplomacy_target_label,
			int(agreement.get("turns_remaining", 0)),
			relation_line,
		]
	if cost_text.is_empty():
		var cost_variant: Variant = result.get("cost", {})
		if cost_variant is Dictionary:
			gold_cost = int((cost_variant as Dictionary).get("gold", 0))
		cost_text = "%s -%d" % [str(RESOURCE_LABELS.get("gold", "금전")), gold_cost]
	return "최근 외교\n%s → %s\n%s / %s" % [action_label, diplomacy_target_label, relation_line, cost_text]


func _format_player_diplomacy_tech_modifier_summary_mvp(target_faction_id: String = "") -> String:
	var modifier := _controller._get_player_diplomacy_tech_modifier_mvp()
	if not _controller._has_domestic_diplomacy_modifier_data_mvp(modifier):
		return ""
	var parts: Array[String] = []
	if not is_equal_approx(float(modifier.get("diplomacy_success_pct", 0.0)), 0.0):
		parts.append("외교 성공 %s" % _format_domestic_tech_percent_bonus_mvp(float(modifier.get("diplomacy_success_pct", 0.0))))
	if not is_equal_approx(float(modifier.get("relation_gain_pct", 0.0)), 0.0):
		parts.append("관계 개선 %s" % _format_domestic_tech_percent_bonus_mvp(float(modifier.get("relation_gain_pct", 0.0))))
	if not is_equal_approx(float(modifier.get("alliance_success_pct", 0.0)), 0.0):
		parts.append("동맹 수락 %s" % _format_domestic_tech_percent_bonus_mvp(float(modifier.get("alliance_success_pct", 0.0))))
	if not is_equal_approx(float(modifier.get("tribute_success_pct", 0.0)), 0.0):
		parts.append("조공 외교 %s" % _format_domestic_tech_percent_bonus_mvp(float(modifier.get("tribute_success_pct", 0.0))))
	if not is_equal_approx(float(modifier.get("envoy_effect_pct", 0.0)), 0.0):
		parts.append("사신 영향 %s" % _format_domestic_tech_percent_bonus_mvp(float(modifier.get("envoy_effect_pct", 0.0))))
	if parts.is_empty():
		return ""
	var baseline_suffix := ""
	var baseline := _controller._get_enemy_diplomacy_baseline_mvp(target_faction_id)
	if not target_faction_id.is_empty() and not bool(baseline.get("masked", true)):
		baseline_suffix = "\n상대 외교 기본 저항: %s" % str(baseline.get("baseline_grade_label", "보통"))
	return "내정 연구 외교 보정\n%s%s" % [", ".join(parts.slice(0, 5)), baseline_suffix]


func _format_diplomacy_normalize_summary(result: Dictionary) -> String:
	var created_count := int(result.get("created_count", 0))
	var patched_count := int(result.get("patched_score_count", 0)) + int(result.get("patched_status_count", 0)) + int(result.get("patched_cooldown_count", 0)) + int(result.get("patched_tribute_cooldown_count", 0))
	if created_count <= 0 and patched_count <= 0:
		return ""
	return "외교 관계 정규화 %d건 · 보정 %d건" % [int(result.get("ensured_count", 0)), patched_count]


func _format_diplomacy_cooldown_summary(result: Dictionary) -> String:
	var changed_count := int(result.get("changed_count", 0))
	if changed_count <= 0:
		return ""
	var action_count := 0
	var tribute_count := 0
	var agreement_count := 0
	var changed_variant: Variant = result.get("changed", [])
	if changed_variant is Array:
		for changed_entry_variant in changed_variant:
			if not changed_entry_variant is Dictionary:
				continue
			match str((changed_entry_variant as Dictionary).get("type", "")):
				"diplomacy_action_cooldown":
					action_count += 1
				"trade_agreement":
					agreement_count += 1
				_:
					tribute_count += 1
	var parts: Array[String] = []
	if action_count > 0:
		parts.append("외교 행동 %d건" % action_count)
	if tribute_count > 0:
		parts.append("조공 %d건" % tribute_count)
	if agreement_count > 0:
		parts.append("교역 협정 %d건" % agreement_count)
	return "외교 경과 감소: %s" % " / ".join(parts)


func _format_last_tribute_summary(turn_number: int) -> String:
	var result: Variant = _player_state.get("last_tribute_result", {})
	if not result is Dictionary:
		return ""
	var tribute_result := result as Dictionary
	if not bool(tribute_result.get("success", false)):
		return ""
	if int(tribute_result.get("turn", 0)) != maxi(1, turn_number):
		return ""
	var target_faction := str(tribute_result.get("target_faction", ""))
	return "조공 결과: %s 관계 +%d, 현재 %d" % [
		str(FACTION_LABELS.get(target_faction, target_faction)),
		int(tribute_result.get("relation_gain", 0)),
		int(tribute_result.get("after_score", 0)),
	]


func build_action_card_model(city_marker: WorldMapCityMarker) -> Dictionary:
	if city_marker == null:
		return {"visible": false}
	var target_city_id := city_marker.city_id
	var target_faction_id := _controller._get_city_owner_faction_id_for_trade_display(target_city_id)
	if target_faction_id.is_empty() or target_faction_id == _controller._get_current_player_faction_id():
		return {"visible": false}
	var model := {"visible": true}
	var status := _controller._get_faction_relation_status(_controller._get_current_player_faction_id(), target_faction_id)
	var score := _controller._get_faction_relation_score(_controller._get_current_player_faction_id(), target_faction_id)
	var cooldown_turns := _controller._get_diplomacy_action_cooldown(target_faction_id)
	var agreement_turns := _controller._get_active_trade_agreement_turns(target_faction_id)
	var alliance_turns := _controller._get_active_alliance_turns(target_faction_id)
	model["title"] = "외교 실행 · %s" % _format_faction_label(target_faction_id)
	var status_parts := [
		"%s · 관계 %d" % [_format_diplomacy_relation_status_for_ui(status), score],
		"쿨다운 %d턴" % cooldown_turns if cooldown_turns > 0 else "행동 가능",
	]
	if agreement_turns > 0:
		status_parts.append("교역 협정 %d턴" % agreement_turns)
	if alliance_turns > 0:
		status_parts.append("동맹 %d턴" % alliance_turns)
	model["status"] = " / ".join(status_parts)
	var validation_map := {
		DIPLOMACY_ACTION_ENVOY: _controller._validate_diplomacy_action(DIPLOMACY_ACTION_ENVOY, target_city_id),
		DIPLOMACY_ACTION_TRIBUTE: _controller._validate_diplomacy_action(DIPLOMACY_ACTION_TRIBUTE, target_city_id),
		DIPLOMACY_ACTION_TRADE_AGREEMENT: _controller._validate_diplomacy_action(DIPLOMACY_ACTION_TRADE_AGREEMENT, target_city_id),
		DIPLOMACY_ACTION_RESTORE_RELATIONS: _controller._validate_diplomacy_action(DIPLOMACY_ACTION_RESTORE_RELATIONS, target_city_id),
		DIPLOMACY_ACTION_ALLIANCE_PROPOSAL: _controller._validate_diplomacy_action(DIPLOMACY_ACTION_ALLIANCE_PROPOSAL, target_city_id),
	}
	model["validation_map"] = validation_map
	model["hint"] = _format_diplomacy_action_hint(validation_map)
	return model


func build_action_button_model(validation: Dictionary) -> Dictionary:
	var model := {}
	model["disabled"] = not bool(validation.get("ok", false))
	var cost: Dictionary = validation.get("cost", {})
	if model["disabled"]:
		model["tooltip"] = "행동 불가 · %s" % str(validation.get("message", "조건 미충족"))
	elif str(validation.get("action_id", "")) == DIPLOMACY_ACTION_ALLIANCE_PROPOSAL:
		model["tooltip"] = "동맹 제안 · 비용 %s · 수락 %d/%d · 지속 %d턴 · 쿨다운 %d턴" % [
			_format_resource_costs(cost, ["gold", "silk"]),
			int(validation.get("acceptance_score", 0)),
			int(validation.get("required_score", DiplomacyActionServiceScript.ALLIANCE_ACCEPTANCE_THRESHOLD)),
			int(validation.get("alliance_turns", DiplomacyActionServiceScript.ACTION_ALLIANCE_TURNS)),
			int(validation.get("cooldown", 0)),
		]
	else:
		model["tooltip"] = "행동 가능 · 비용 %s · 관계 %+d · 쿨다운 %d턴" % [
			_format_resource_costs(cost, ["gold"]),
			int(validation.get("relation_delta", 0)),
			int(validation.get("cooldown", 0)),
		]
	return model


func _format_faction_label(owner_faction_id: String) -> String:
	return _host.call("_format_faction_label", owner_faction_id)


func _can_trade_between_factions(faction_a: String, faction_b: String) -> bool:
	return _host.call("_can_trade_between_factions", faction_a, faction_b)


func _format_resource_costs(costs: Dictionary, resource_order: Array) -> String:
	return _host.call("_format_resource_costs", costs, resource_order)


func _format_domestic_tech_percent_bonus_mvp(value: float) -> String:
	return _host.call("_format_domestic_tech_percent_bonus_mvp", value)
