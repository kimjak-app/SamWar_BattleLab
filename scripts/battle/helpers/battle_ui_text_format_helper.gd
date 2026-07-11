class_name BattleUITextFormatHelper
extends RefCounted


static func format_strategy_status_display_name(status_id: String) -> String:
	match status_id:
		"confusion":
			return "혼란"
		"shake":
			return "동요"
		_:
			return "상태"


static func format_side_display_name(side: String) -> String:
	if side == "enemy":
		return "적군"
	return "아군"


static func get_debug_object_class_name(value: Object) -> String:
	if value == null:
		return "null"
	return value.get_class()
