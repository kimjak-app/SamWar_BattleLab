class_name WorldMapDiplomacyActionService
extends RefCounted


func execute(
	host: Object,
	action_id: String,
	target_city_id: String,
	_source_city_id: String = ""
) -> Dictionary:
	if host == null or not host.has_method("_apply_diplomacy_action"):
		return _failure("executor_unavailable", "외교 행동 실행기를 찾을 수 없습니다.")
	var raw_result: Variant = host.call("_apply_diplomacy_action", action_id, target_city_id)
	if raw_result is Dictionary:
		return raw_result as Dictionary
	return _failure("invalid_result", "외교 행동 결과를 처리할 수 없습니다.")


func _failure(reason: String, message: String) -> Dictionary:
	return {
		"ok": false,
		"success": false,
		"reason": reason,
		"message": message,
	}
