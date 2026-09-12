class_name WorldMapSpyActionService
extends RefCounted

const ACTION_GATHER_INFO := "gather_info"
const ACTION_PUBLIC_SUPPORT_DISRUPT := "public_support_disrupt"
const ACTION_LOYALTY_DISRUPT := "loyalty_disrupt"
const ACTION_REVOLT_INSTIGATE := "revolt_instigate"
const ACTION_WEDGE := "wedge"


func execute(
	host: Object,
	action_id: String,
	target_city_id: String,
	_source_city_id: String = ""
) -> Dictionary:
	if host == null:
		return _failure("executor_unavailable", "첩보 행동 실행기를 찾을 수 없습니다.")
	if not host.has_method("_validate_spy_action") or not host.has_method("_store_failed_spy_action_result"):
		return _failure("executor_unavailable", "첩보 행동 검증기를 찾을 수 없습니다.")

	var validation_variant: Variant = host.call("_validate_spy_action", action_id, target_city_id)
	if not validation_variant is Dictionary:
		return _failure("invalid_validation", "첩보 행동 조건을 확인할 수 없습니다.")
	var validation := validation_variant as Dictionary
	if not bool(validation.get("ok", false)):
		return _call_result(host, "_store_failed_spy_action_result", [action_id, validation])

	var resolved_target_city_id := str(validation.get("target_city_id", target_city_id))
	match action_id:
		ACTION_GATHER_INFO:
			return _call_result(host, "_gather_spy_info", [resolved_target_city_id])
		ACTION_PUBLIC_SUPPORT_DISRUPT:
			return _call_result(host, "_disrupt_city_public_support", [resolved_target_city_id])
		ACTION_LOYALTY_DISRUPT:
			return _call_result(host, "_disrupt_city_loyalty", [resolved_target_city_id])
		ACTION_REVOLT_INSTIGATE:
			return _call_result(host, "_instigate_revolt", [resolved_target_city_id])
		ACTION_WEDGE:
			return _call_result(host, "_apply_spy_wedge_action", [validation])

	return _call_result(
		host,
		"_store_failed_spy_action_result",
		[
			action_id,
			{
				"reason": "invalid_action",
				"message": "알 수 없는 첩보 행동입니다.",
				"target_city_id": target_city_id,
			},
		]
	)


func _call_result(host: Object, method_name: String, args: Array) -> Dictionary:
	if not host.has_method(method_name):
		return _failure("executor_unavailable", "첩보 행동 처리기를 찾을 수 없습니다: %s" % method_name)
	var raw_result: Variant = host.callv(method_name, args)
	if raw_result is Dictionary:
		return raw_result as Dictionary
	return _failure("invalid_result", "첩보 행동 결과를 처리할 수 없습니다.")


func _failure(reason: String, message: String) -> Dictionary:
	return {
		"ok": false,
		"success": false,
		"reason": reason,
		"message": message,
	}
