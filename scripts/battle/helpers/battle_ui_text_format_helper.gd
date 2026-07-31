class_name BattleUITextFormatHelper
extends RefCounted

const UNIQUE_SKILL_EFFECT_DISPLAY_NAMES := {
	"adjacent_aoe": "인접 범위 타격",
	"ally_focus_buff": "아군 집중 강화",
	"aoe_damage_debuff": "광역 타격 및 약화",
	"aoe_debuff": "광역 약화",
	"charge_aoe": "돌격 범위 타격",
	"charge_damage": "돌격 공격",
	"charge_line": "돌파 돌격",
	"command_debuff": "지휘 약화",
	"control_field": "제압 지대",
	"encirclement_debuff": "포위 약화",
	"fear_aoe": "공포 확산",
	"fire_aoe": "화염 범위 공격",
	"flank_debuff_attack": "측후방 약화 공격",
	"guard_aura": "수호 진형",
	"gunner_volley": "일제 사격",
	"line_damage": "직선 관통 공격",
	"mounted_team_buff": "기마 부대 강화",
	"naval_team_buff": "수군 부대 강화",
	"prediction_debuff": "예측 약화",
	"rally_restore": "재집결 회복",
	"retreat_counter": "후퇴 반격",
	"single_burst": "집중 연속 타격",
	"single_debuff": "단일 약화",
	"single_ranged_damage": "정밀 원거리 공격",
	"skill_cost_debuff": "기세 비용 약화",
	"splash_charge": "돌격 파급 공격",
	"stance_team_buff": "진형 강화",
	"team_action_buff": "아군 행동 강화",
	"team_buff": "아군 강화",
	"team_command": "지휘 강화",
	"team_guard": "아군 방어 강화",
	"team_logistics": "보급 강화",
	"team_mobility_buff": "기동 강화",
	"team_morale": "사기 강화",
	"team_support": "아군 지원",
	"trap_aoe": "매복 범위 공격",
}

const UNIQUE_SKILL_STATUS_DISPLAY_NAMES := {
	"accuracy_down": "명중 저하",
	"action_lock": "행동 봉쇄",
	"attack_defense_down": "공격·방어 저하",
	"attack_defense_up": "공격·방어 상승",
	"burn": "화상",
	"confusion": "혼란",
	"counter_up": "반격 강화",
	"damage_reduction": "피해 감소",
	"defense_down": "방어 저하",
	"defense_up": "방어 상승",
	"fear": "공포",
	"flank_damage_taken_up": "측후방 피격 증가",
	"flank_damage_up": "측후방 공격 강화",
	"formation_break": "진형 붕괴",
	"incoming_damage_down": "받는 피해 감소",
	"mobility_up": "기동력 상승",
	"momentum_gain_down": "기세 획득 저하",
	"momentum_gain_up": "기세 획득 상승",
	"movement_down": "이동 저하",
	"rout_resist": "패주 저항",
	"shake": "동요",
	"siege_attack_up": "공성 공격 상승",
	"skill_cost_up": "기세 비용 증가",
	"status_resist": "상태 저항",
}

const UNIQUE_SKILL_FAILURE_DISPLAY_NAMES := {
	"empty_effect_plan": "효과 계획 없음",
	"insufficient_momentum": "기세 부족",
	"invalid_caster": "시전자 행동 불가",
	"invalid_momentum_cost": "기세 비용 오류",
	"invalid_target": "대상 오류",
	"missing_hero_id": "장수 식별자 없음",
	"missing_skill_id": "고유기 식별자 없음",
	"no_affected_target": "영향 대상 없음",
	"no_valid_target": "유효 대상 없음",
	"resolver_rejected": "고유기 검증 실패",
	"unsupported_effect_type": "지원하지 않는 효과",
	"unsupported_target_mode": "지원하지 않는 대상 방식",
}

const UNIT_TYPE_DISPLAY_NAMES := {
	"infantry": "보병",
	"cavalry": "기병",
	"archer": "궁병",
	"gunner": "총병",
	"mounted_archer": "궁기병",
}


static func format_strategy_status_display_name(status_id: String) -> String:
	return format_unique_skill_status_display_name(status_id)


static func format_unique_skill_effect_display_name(effect_id: String) -> String:
	return String(UNIQUE_SKILL_EFFECT_DISPLAY_NAMES.get(effect_id, "추가 효과"))


static func format_unique_skill_status_display_name(status_id: String) -> String:
	return String(UNIQUE_SKILL_STATUS_DISPLAY_NAMES.get(status_id, "특수 상태"))


static func format_unique_skill_failure_display_name(reason_id: String) -> String:
	return String(UNIQUE_SKILL_FAILURE_DISPLAY_NAMES.get(reason_id, "실행 조건 미충족"))


static func format_side_display_name(side: String) -> String:
	if side == "enemy":
		return "적군"
	return "아군"


static func format_unit_type_display_name(unit_type: String, fallback: String = "") -> String:
	return String(UNIT_TYPE_DISPLAY_NAMES.get(unit_type, fallback))


static func get_debug_object_class_name(value: Object) -> String:
	if value == null:
		return "null"
	return value.get_class()
