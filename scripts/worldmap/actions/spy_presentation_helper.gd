class_name WorldMapSpyPresentationHelper
extends RefCounted

const DiplomacySpyHelpers := preload("res://scripts/worldmap/diplomacy_spy/diplomacy_spy_helpers.gd")
const ACTIONS := ["gather_info", "public_support_disrupt", "loyalty_disrupt", "revolt_instigate", "wedge"]

var _host: Node
var _controller: RefCounted


func configure(host: Node, controller: RefCounted) -> void:
	_host = host
	_controller = controller


func has_enemy_intel_payload(fields: Array[String], payload: Dictionary, field: String) -> bool:
	match field:
		"troops_estimated": return fields.has(field) and payload.has(field) and not (fields.has("troops") and payload.has("troops"))
		"troops", "resources", "publicSupport", "loyalty", "tech": return fields.has(field) and payload.has(field)
		"governor": return fields.has(field) and payload.has(field) and str(payload.get(field, "")) != "not_available"
	return false


func get_revealed_field_ids(fields: Array[String], payload: Dictionary) -> Array[String]:
	var revealed: Array[String] = []
	if has_enemy_intel_payload(fields, payload, "troops"):
		revealed.append("troops")
	elif has_enemy_intel_payload(fields, payload, "troops_estimated"):
		revealed.append("troops_estimated")
	for field in ["resources", "publicSupport", "loyalty", "governor", "tech"]:
		if has_enemy_intel_payload(fields, payload, field): revealed.append(field)
	return revealed


func get_city_intel_fields(entry: Dictionary) -> Array[String]:
	var fields: Array[String] = []
	var raw: Variant = entry.get("fields", [])
	if raw is Array:
		for value in raw:
			var field := str(value)
			if not field.is_empty() and not fields.has(field): fields.append(field)
	return fields


func get_city_intel_payload(entry: Dictionary) -> Dictionary:
	var raw: Variant = entry.get("payload", entry.get("info", {}))
	return (raw as Dictionary).duplicate(true) if raw is Dictionary else {}


func get_city_intel_entry(city_id: String) -> Dictionary:
	var state: Dictionary = _host.get("_player_state")
	var registry: Dictionary = _controller.call("normalize_city_intel_registry", state.get("city_intel", {}))
	var raw: Variant = registry.get(city_id, {})
	return raw as Dictionary if raw is Dictionary else {}


func format_visibility_summary(city_marker) -> String:
	if city_marker == null: return "정보 수준\n정보 미확인"
	var owner := str(_host.call("_get_city_owner_faction_id_for_trade_display", city_marker.city_id))
	if owner.is_empty(): return "정보 수준\n정보 미확인"
	if owner == str(_host.call("_get_current_player_faction_id")): return "정보 수준\n자국 도시"
	var entry := get_city_intel_entry(city_marker.city_id)
	if entry.is_empty(): return "정보 수준\n미확인\n공개: 도시명 / 세력 / 유형\n잠김: 병력 / 자원 / 민심 / 충성도 / 태수 / 기술\n다음: 정탐 필요"
	var fields := get_city_intel_fields(entry)
	var revealed := get_revealed_field_ids(fields, get_city_intel_payload(entry))
	var revealed_labels := _field_labels(revealed)
	var locked_labels := _locked_field_labels(revealed)
	var revealed_text := "도시명 / 세력 / 유형"
	if not revealed_labels.is_empty(): revealed_text += " / %s" % " / ".join(revealed_labels)
	var text := "정보 수준\n%s\n공개: %s\n잠김: %s\n다음: %s" % [
		_level_label(_level_id(revealed)), revealed_text,
		"없음" if locked_labels.is_empty() else " / ".join(locked_labels),
		"추가 정탐 필요" if not locked_labels.is_empty() else "잠김 정보 없음",
	]
	var modifier := format_player_tech_modifier_summary(city_marker.city_id)
	return text if modifier.is_empty() else "%s\n%s" % [text, modifier]


func format_known_info_summary(city_marker) -> String:
	if city_marker == null: return "확인 정보\n도시를 선택하면 확인 정보가 표시됩니다."
	var owner := str(_host.call("_get_city_owner_faction_id_for_trade_display", city_marker.city_id))
	if owner == str(_host.call("_get_current_player_faction_id")): return "확인 정보\n자국 도시는 도시 정보창에서 상세 정보를 확인할 수 있습니다."
	if owner.is_empty(): return "확인 정보\n소유 세력 확인이 필요합니다."
	var entry := get_city_intel_entry(city_marker.city_id)
	if entry.is_empty(): return "확인 정보\n공개: 도시명 / 세력 / 유형\n잠김: 병력 / 자원 / 민심 / 충성도 / 태수 / 기술\n다음: 정탐 필요"
	var fields := get_city_intel_fields(entry)
	var payload := get_city_intel_payload(entry)
	var revealed := get_revealed_field_ids(fields, payload)
	var values: Array[String] = []
	if has_enemy_intel_payload(fields, payload, "troops"): values.append("병력 %d" % int(payload.get("troops", 0)))
	elif has_enemy_intel_payload(fields, payload, "troops_estimated"): values.append("병력 약 %d" % int(payload.get("troops_estimated", 0)))
	if has_enemy_intel_payload(fields, payload, "resources"): values.append("자원 개략")
	if has_enemy_intel_payload(fields, payload, "publicSupport"): values.append("민심 %s" % str(payload.get("publicSupport", "")))
	if has_enemy_intel_payload(fields, payload, "loyalty"): values.append("충성도 %s" % str(payload.get("loyalty", "")))
	if has_enemy_intel_payload(fields, payload, "governor"): values.append("태수 확인")
	if has_enemy_intel_payload(fields, payload, "tech"): values.append("기술 확인")
	var shown := _field_labels(revealed)
	var locked := _locked_field_labels(revealed)
	var public_text := "도시명 / 세력 / 유형" + (" / %s" % " / ".join(shown) if not shown.is_empty() else "")
	var value_text := "확인값: %s\n" % " / ".join(values) if not values.is_empty() else ""
	return "확인 정보\n수준: %s\n공개: %s\n잠김: %s\n%s%s" % [_level_label(_level_id(revealed)), public_text, "없음" if locked.is_empty() else " / ".join(locked), value_text, "\n다음: 추가 정탐 필요" if not locked.is_empty() else "\n다음: 잠김 정보 없음"]


func format_action_candidates(city_marker) -> String:
	if city_marker == null: return "첩보 행동\n도시를 선택하면 첩보 후보가 표시됩니다."
	var owner := str(_host.call("_get_city_owner_faction_id_for_trade_display", city_marker.city_id))
	if owner == str(_host.call("_get_current_player_faction_id")): return "첩보 판단\n자국 도시는 첩보 대상이 아닙니다."
	if owner.is_empty(): return "첩보 행동\n대상 세력 확인이 필요합니다."
	var lines: Array[String] = ["첩보 행동"]
	for action in ACTIONS:
		var check: Dictionary = _controller.call("validate_spy_action", action, city_marker.city_id)
		lines.append("%s: %s" % [str(_controller.call("get_spy_action_definition", action).get("label", action)), DiplomacySpyHelpers.format_spy_check_status_for_ui(check)])
		if action == "wedge" and bool(check.get("ok", false)):
			lines.append("대상 관계: %s ↔ %s / %d" % [_faction(str(check.get("target_faction_id", ""))), _faction(str(check.get("counterpart_faction_id", ""))), int(check.get("relation_score", 0))])
	return "\n".join(lines)


func format_recent_result(city_id: String) -> String:
	for pair in [["last_spy_result", "정탐"], ["last_spy_public_support_disrupt_result", "민심 교란"], ["last_spy_loyalty_disrupt_result", "성 충성도 교란"], ["last_spy_revolt_instigation_result", "반란 조장"], ["last_spy_wedge_result", "이간질"]]:
		var text := _format_result_key(pair[0], city_id, pair[1])
		if not text.is_empty(): return "최근 첩보\n%s" % text
	return "최근 첩보\n최근 첩보 기록 없음"


func format_action_policy(city_marker) -> String:
	if city_marker == null: return "첩보 대기\n도시를 선택하면 실행 상태가 표시됩니다."
	var owner := str(_host.call("_get_city_owner_faction_id_for_trade_display", city_marker.city_id))
	if owner.is_empty(): return "첩보 대기\n대상 세력 확인이 필요합니다."
	if owner == str(_host.call("_get_current_player_faction_id")): return "첩보 대기\n자국 도시는 첩보 대상이 아닙니다."
	var state: Dictionary = _host.get("_player_state")
	var modifier := format_player_tech_modifier_summary(city_marker.city_id)
	var cooldown := maxi(0, int(state.get("spy_cooldown", 0)))
	if cooldown > 0:
		var cooldown_text := "첩보 대기 중\n%d턴 후 다시 실행 가능" % cooldown
		return cooldown_text if modifier.is_empty() else "%s\n%s" % [cooldown_text, modifier]
	var check: Dictionary = _controller.call("validate_spy_action", "wedge", city_marker.city_id)
	var text := "첩보 실행\n이간질: %s" % str(check.get("message", "조건 확인 필요"))
	if bool(check.get("ok", false)): text = "첩보 실행\n이간질 대상 %s ↔ %s / 성공률 %d%%" % [_faction(str(check.get("target_faction_id", ""))), _faction(str(check.get("counterpart_faction_id", ""))), int(check.get("success_chance", 0))]
	return text if modifier.is_empty() else "%s\n%s" % [text, modifier]


func format_action_hint(validations: Dictionary) -> String:
	var enabled: Array[String] = []
	var blocked: Array[String] = []
	for action in ACTIONS:
		var check: Dictionary = validations.get(action, {})
		var label := str(_controller.call("get_spy_action_definition", action).get("label", action))
		if bool(check.get("ok", false)):
			if action == "wedge": enabled.append("%s %s-%s 성공 %d%%" % [label, _faction(str(check.get("target_faction_id", ""))), _faction(str(check.get("counterpart_faction_id", ""))), int(check.get("success_chance", 0))])
			else: enabled.append("%s 성공 %d%%" % [label, int(check.get("success_chance", 0))])
		else: blocked.append("%s: %s" % [label, str(check.get("message", "불가"))])
	if not enabled.is_empty(): return "행동 가능\n%s" % "\n".join(enabled)
	if not blocked.is_empty(): return "행동 불가\n%s" % blocked[0]
	return "첩보 행동을 선택하세요."


func format_player_tech_modifier_summary(city_id: String = "") -> String:
	var modifier: Dictionary = _controller.call("get_player_spy_tech_modifier", city_id)
	var parts: Array[String] = []
	for pair in [["spy_success_pct", "첩보 성공", 1.0], ["spy_detection_reduction_pct", "발각 위험", -1.0], ["intel_visibility_pct", "정보 가시성", 1.0], ["counter_spy_pct", "방첩 대비", 1.0]]:
		var value := float(modifier.get(pair[0], 0.0)) * float(pair[2])
		if not is_zero_approx(value): parts.append("%s %s" % [pair[1], str(_host.call("_format_domestic_tech_percent_bonus_mvp", value))])
	if parts.is_empty(): return ""
	var suffix := ""
	if not city_id.is_empty():
		var baseline: Dictionary = _host.call("_get_enemy_spy_resistance_baseline_mvp", _host.call("_get_city_hud_entry", city_id))
		if not bool(baseline.get("masked", true)): suffix = "\n상대 첩보 방어 체급: %s" % str(baseline.get("baseline_grade_label", "보통"))
	return "내정 연구 첩보 보정\n%s%s" % [", ".join(parts.slice(0, 5)), suffix]


func format_cooldown_summary(result: Dictionary) -> String:
	return "" if not bool(result.get("changed", false)) else "첩보 쿨다운 감소: %d→%d" % [int(result.get("before", 0)), int(result.get("after", 0))]


func format_last_summary(turn_number: int) -> String:
	var state: Dictionary = _host.get("_player_state")
	for key in ["last_spy_wedge_result", "last_spy_revolt_instigation_result", "last_spy_loyalty_disrupt_result", "last_spy_public_support_disrupt_result", "last_spy_result"]:
		var raw: Variant = state.get(key, {})
		if not raw is Dictionary or int((raw as Dictionary).get("turn", 0)) != maxi(1, turn_number): continue
		var result := raw as Dictionary
		if bool(result.get("detected", false)): return "첩보 발각: %s 관계 %d" % [_faction(str(result.get("target_faction_id", result.get("target_faction", "")))), int(result.get("relation_penalty", 0))]
		if bool(result.get("effect_applied", false)):
			match key:
				"last_spy_loyalty_disrupt_result": return "첩보 충성도 교란 성공: %s 충성도 -%d" % [_city(str(result.get("target_city_id", ""))), int(result.get("effect_amount", 0))]
				"last_spy_revolt_instigation_result": return "첩보 반란 조장 성공: %s 위험 보정 +%d" % [_city(str(result.get("target_city_id", ""))), int(result.get("probability_boost", 0))]
				"last_spy_public_support_disrupt_result": return "첩보 민심 교란 성공: %s 민심 -%d" % [_city(str(result.get("target_city_id", ""))), int(result.get("effect_amount", 0))]
				"last_spy_wedge_result": return "첩보 이간질 성공: %s-%s 관계 -%d" % [_faction(str(result.get("target_faction_a", ""))), _faction(str(result.get("target_faction_b", ""))), absi(int(result.get("relation_delta", 0)))]
		if key == "last_spy_result" and bool(result.get("success_valid", true)): return "첩보 결과: %s%s" % ["성공" if bool(result.get("success", false)) else "실패", " / 발각" if bool(result.get("detected", false)) else ""]
		if result.has("roll"): return "첩보 실패"
	return ""


func _format_result_key(key: String, city_id: String, label: String) -> String:
	if city_id.is_empty(): return ""
	var state: Dictionary = _host.get("_player_state")
	var raw: Variant = state.get(key, {})
	if not raw is Dictionary: return ""
	var result := raw as Dictionary
	if str(result.get("target_city_id", "")) != city_id: return ""
	if not bool(result.get("success", false)) and not bool(result.get("effect_applied", false)) and not bool(result.get("detected", false)) and result.has("message"): return "%s 실패 · %s" % [label, str(result.get("message", "실패"))]
	var detail: Array[String] = []
	if key == "last_spy_result":
		var payload: Variant = result.get("payload", result.get("info", {}))
		if payload is Dictionary:
			if payload.has("troops"): detail.append("병력 %d" % int(payload.get("troops", 0)))
			elif payload.has("troops_estimated"): detail.append("병력 약 %d" % int(payload.get("troops_estimated", 0)))
	elif bool(result.get("effect_applied", false)):
		if key == "last_spy_public_support_disrupt_result": detail.append("민심 -%d" % int(result.get("effect_amount", 0)))
		elif key == "last_spy_loyalty_disrupt_result": detail.append("충성도 -%d" % int(result.get("effect_amount", 0)))
		elif key == "last_spy_revolt_instigation_result": detail.append("반란 위험 +%d" % int(result.get("probability_boost", 0)))
		elif key == "last_spy_wedge_result": detail.append("%s-%s 관계 %d → %d" % [_faction(str(result.get("target_faction_id", ""))), _faction(str(result.get("counterpart_faction_id", ""))), int(result.get("before_score", 0)), int(result.get("after_score", 0))])
	if bool(result.get("alliance_broken", false)): detail.append("동맹 균열")
	if bool(result.get("detected", false)): detail.append("관계 %d" % int(result.get("relation_penalty", 0)))
	var outcome := "성공" if bool(result.get("success", false)) or bool(result.get("effect_applied", false)) else "실패"
	var base := "%s %s · %s" % [label, outcome, "발각 있음" if bool(result.get("detected", false)) else "발각 없음"]
	return base if detail.is_empty() else "%s\n%s" % [base, " / ".join(detail)]


func _level_id(fields: Array[String]) -> String:
	if fields.has("governor") and fields.has("tech"): return "full"
	if fields.has("publicSupport") or fields.has("loyalty") or fields.has("governor") or fields.has("tech"): return "domestic"
	if fields.has("resources"): return "resource"
	if fields.has("troops"): return "military"
	return "basic" if fields.has("troops_estimated") else "none"


func _level_label(id: String) -> String:
	return {"basic": "기초 정탐", "military": "군사 정탐", "resource": "군사/자원 정탐", "domestic": "내정 정탐", "full": "상세 정탐"}.get(id, "미확인")


func _field_labels(fields: Array[String]) -> Array[String]:
	var labels: Array[String] = []
	for field in fields:
		var label: String = {"troops_estimated": "병력 추정", "troops": "병력", "resources": "자원", "publicSupport": "민심", "loyalty": "충성도", "governor": "태수", "tech": "기술"}.get(field, field)
		if not labels.has(label): labels.append(label)
	return labels


func _locked_field_labels(fields: Array[String]) -> Array[String]:
	var locked: Array[String] = []
	for field in ["troops", "resources", "publicSupport", "loyalty", "governor", "tech"]:
		if field == "troops" and (fields.has("troops") or fields.has("troops_estimated")): continue
		if field != "troops" and fields.has(field): continue
		locked.append(_field_labels([field])[0])
	return locked


func _faction(id: String) -> String: return str(_host.call("_format_faction_label", id))
func _city(id: String) -> String: return str(_host.call("_format_city_name_by_id", id, id))
