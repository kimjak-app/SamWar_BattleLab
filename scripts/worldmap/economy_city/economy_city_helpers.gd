extends RefCounted


static func extract_resource_group(resource_summary: String, resource_names: Array[String]) -> String:
	if resource_summary.is_empty():
		return "미확인"

	var matches: Array[String] = []
	for chunk in resource_summary.split(" / "):
		for resource_name in resource_names:
			if chunk.begins_with(resource_name):
				matches.append(chunk)
				break

	if not matches.is_empty():
		return " / ".join(matches)
	return "미확인"


static func format_internal_trade_lead_display(connected_player_city_ids: Array[String]) -> String:
	if connected_player_city_ids.is_empty():
		return ""
	return ""


static func format_internal_trade_policy_display(connected_player_city_ids: Array[String]) -> String:
	if connected_player_city_ids.is_empty():
		return "현재 방침\n아군 성 연결 후 무역 주도를 선택할 수 있습니다."
	return "현재 방침\n무역 주도 방식은 아래 버튼에서 선택합니다."


static func format_external_trade_lead_display(candidate_city_ids: Array[String]) -> String:
	if candidate_city_ids.is_empty():
		return ""
	return ""


static func format_external_trade_policy_display(candidate_city_ids: Array[String]) -> String:
	if candidate_city_ids.is_empty():
		return ""
	return "현재 방침\n무역 주도 방식은 아래 버튼에서 선택합니다."


static func format_supply_role_label(role_id: String) -> String:
	match role_id:
		"hub":
			return "중심 거점"
		"rear":
			return "후방"
		"frontline":
			return "전방"
		_:
			return "일반"


static func format_supply_status_label(status_id: String) -> String:
	match status_id:
		"supplied":
			return "보급 연결"
		"isolated":
			return "고립"
		"unsupplied":
			return "보급 미연결"
		_:
			return "확인 필요"


static func get_trade_display_totals(result: Dictionary) -> Dictionary:
	var applied_totals: Variant = result.get("applied_player_totals", {})
	if applied_totals is Dictionary and not (applied_totals as Dictionary).is_empty():
		return applied_totals
	var player_totals: Variant = result.get("player_totals", {})
	if player_totals is Dictionary:
		return player_totals
	return {}


static func format_trade_resource_totals_display(totals: Dictionary, resource_labels: Dictionary) -> String:
	var parts: Array[String] = []
	for resource_id in ["gold", "rice", "barley", "seafood", "salt"]:
		var delta := int(totals.get(resource_id, 0))
		parts.append("%s %s" % [str(resource_labels.get(resource_id, resource_id)), _format_signed_int(delta)])
	return " / ".join(parts)


static func get_city_storage_amount(storage: Dictionary, resource_id: String) -> int:
	return maxi(0, int(storage.get(resource_id, 0)))


static func get_city_storage_status_label(total: int) -> String:
	if total >= 300:
		return "안정"
	if total >= 100:
		return "주의"
	return "부족"


static func get_resource_status_label(value: int, max_value: int, low_ratio: float, stable_ratio: float) -> String:
	if max_value <= 0:
		return "상한 없음"
	var ratio := float(value) / float(max_value)
	if ratio <= low_ratio:
		return "부족"
	if ratio <= stable_ratio:
		return "안정"
	if ratio <= 1.0:
		return "충분"
	return "과잉"


static func format_resource_costs(costs: Dictionary, resource_order: Array, resource_labels: Dictionary) -> String:
	var parts: Array[String] = []
	for resource_id in resource_order:
		var resource_id_string := str(resource_id)
		var amount := int(costs.get(resource_id_string, 0))
		if amount > 0:
			parts.append("%s -%d" % [str(resource_labels.get(resource_id_string, resource_id_string)), amount])
	if parts.is_empty():
		return "없음"
	return " / ".join(parts)


static func _format_signed_int(value: int) -> String:
	if value > 0:
		return "+%d" % value
	return str(value)
