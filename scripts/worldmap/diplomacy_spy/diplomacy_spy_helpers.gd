extends RefCounted


static func format_diplomacy_relation_status_for_ui(status: String) -> String:
	match status:
		"allied":
			return "동맹"
		"neutral":
			return "중립"
		"hostile":
			return "적대"
		"suspended":
			return "교역 중단"
		_:
			return "관계 미확인"


static func format_faction_relation_status_for_ui(status: String) -> String:
	match status:
		"allied":
			return "동맹"
		"neutral":
			return "중립"
		"hostile":
			return "적대"
		"suspended":
			return "교역 중단"
		_:
			return "관계 미확인"


static func format_spy_check_status_for_ui(check: Dictionary) -> String:
	if bool(check.get("ok", false)):
		return "행동 가능"
	var reason := str(check.get("reason", "unknown"))
	match reason:
		"own_city":
			return "자국 도시"
		"no_chancellor":
			return "재상 필요"
		"no_political_aptitude":
			return "정치형 재상 필요"
		"cooldown":
			return "쿨다운"
		"resources":
			return "자원 부족"
		"no_counterpart":
			return "상대 세력 없음"
		"already_hostile":
			return "이미 최악"
		"iron_wall":
			return "방첩 경계"
		"prerequisite_public_support", "prerequisite_loyalty":
			return "조건 확인 필요"
		"invalid_target":
			return "대상 확인 필요"
		_:
			return "조건 확인 필요"


static func format_spy_validation_message(check: Dictionary) -> String:
	if bool(check.get("ok", false)):
		return "실행 가능"
	match str(check.get("reason", "unknown")):
		"invalid_action":
			return "알 수 없는 첩보 행동입니다."
		"invalid_target":
			return "대상 도시 확인이 필요합니다."
		"own_city":
			return "자국 도시는 첩보 대상이 아닙니다."
		"no_chancellor":
			return "재상이 필요합니다."
		"no_political_aptitude":
			return "정치형 재상이 필요합니다."
		"cooldown":
			return "첩보 대기 중입니다."
		"iron_wall":
			return "대상 도시 경계가 너무 높습니다."
		"prerequisite_public_support":
			return "민심 50 이하 대상에서만 가능합니다."
		"prerequisite_loyalty":
			return "충성도 40 이하 대상에서만 가능합니다."
		"no_counterpart":
			return "이간질할 상대 세력을 찾을 수 없습니다."
		"already_hostile":
			return "이미 사이가 최악입니다."
		"resources":
			return "금전/비단이 부족합니다."
		_:
			return "실행 조건을 충족하지 못했습니다."


static func get_diplomacy_spy_tab_label(tab_id: String, spy_tab_id: String) -> String:
	if tab_id == spy_tab_id:
		return "첩보"
	return "외교"
