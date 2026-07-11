extends RefCounted


static func format_vector2(value: Vector2) -> String:
	return "(%.0f, %.0f)" % [value.x, value.y]


static func get_trade_control_mode_label(mode: String, manual_mode_id: String) -> String:
	if mode == manual_mode_id:
		return "수동 조정"
	return "재상 일임"


static func get_trade_control_hint(tab_id: String, mode: String, has_manual_targets: bool, internal_trade_tab_id: String, manual_mode_id: String) -> String:
	if not has_manual_targets:
		if tab_id == internal_trade_tab_id:
			return "수동 이송 잠김 · 연결 아군 성 필요"
		return "수동 무역 잠김 · 인접 외국 성 필요"
	if mode == manual_mode_id:
		if tab_id == internal_trade_tab_id:
			return "수동 이송 · 연결 아군 성으로 창고 자원을 옮깁니다."
		return "수동 무역 · 수입/수출 계획을 저장한 뒤 실행합니다."
	return "재상 일임 · 연결 성, 관계, 창고 상태를 기준으로 자동 조정합니다."


static func format_internal_trade_transfer_amounts(amounts: Dictionary, transfer_resource_order: Array, resource_labels: Dictionary) -> String:
	var parts: Array[String] = []
	for resource_id_variant in transfer_resource_order:
		var resource_id := str(resource_id_variant)
		var amount := int(amounts.get(resource_id, 0))
		if amount <= 0:
			continue
		parts.append("%s %d" % [str(resource_labels.get(resource_id, resource_id)), amount])
	if parts.is_empty():
		return "없음"
	return " / ".join(parts)


static func format_star_rating(value: int, max_value: int = 5) -> String:
	var safe_max := maxi(1, max_value)
	var filled := clampi(value, 0, safe_max)
	if filled <= 0:
		return "-"
	var stars := ""
	for _index in range(filled):
		stars += "★"
	return stars


static func format_revolt_risk_label(risk: String, danger_id: String, warning_id: String) -> String:
	if risk == danger_id:
		return "위험"
	if risk == warning_id:
		return "경고"
	return "안정"


static func format_selected_city_revolt_risk_label(risk: String, danger_id: String, warning_id: String, stable_id: String) -> String:
	if risk == danger_id:
		return "위험"
	if risk == warning_id:
		return "주의"
	if risk == stable_id:
		return "낮음"
	return "확인 필요"


static func format_signed_int(value: int) -> String:
	if value > 0:
		return "+%d" % value
	return str(value)


static func format_region_label(region_id: String, region_labels: Dictionary) -> String:
	return str(region_labels.get(region_id, region_id))


static func format_faction_label(owner_faction_id: String, faction_labels: Dictionary) -> String:
	return str(faction_labels.get(owner_faction_id, owner_faction_id))


static func format_city_type(city_id: String, city_type_labels: Dictionary) -> String:
	return str(city_type_labels.get(city_id, "거점"))


static func get_city_detail_tab_label(tab_id: String, internal_trade_tab_id: String, external_trade_tab_id: String) -> String:
	if tab_id == internal_trade_tab_id:
		return "자국무역"
	if tab_id == external_trade_tab_id:
		return "타국무역"
	return "자원"
