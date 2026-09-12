class_name WorldMapActionCoordinator
extends Node

signal presentation_requested(action_type: String, action_id: String, target_city_id: String)
signal action_resolved(action_type: String, result: Dictionary)

const DiplomacyActionServiceScript := preload("res://scripts/worldmap/actions/diplomacy_action_service.gd")
const SpyActionServiceScript := preload("res://scripts/worldmap/actions/spy_action_service.gd")
const TradeActionServiceScript := preload("res://scripts/worldmap/actions/trade_action_service.gd")
const VALID_ACTION_TYPES := ["diplomacy", "spy", "trade"]

var _action_type := ""
var _target_city_id := ""
var _source_city_id := ""
var _pending_presentation := false
var _resolving := false
var _diplomacy_service = DiplomacyActionServiceScript.new()
var _spy_service = SpyActionServiceScript.new()
var _trade_service = TradeActionServiceScript.new()


func begin(action_type: String, target_city_id: String, source_city_id: String = "") -> Dictionary:
	cancel()
	var normalized_type := action_type.strip_edges().to_lower()
	var normalized_target := target_city_id.strip_edges()
	if not VALID_ACTION_TYPES.has(normalized_type):
		return _failure("unsupported_action", "지원하지 않는 도시 행동입니다.")
	if normalized_target.is_empty():
		return _failure("missing_target", "대상 도시를 확인할 수 없습니다.")
	_action_type = normalized_type
	_target_city_id = normalized_target
	_source_city_id = source_city_id.strip_edges()
	return {
		"ok": true,
		"success": true,
		"action_type": _action_type,
		"target_city_id": _target_city_id,
		"source_city_id": _source_city_id,
		"message": "행동을 선택한 뒤 실행하면 영상과 결과가 표시됩니다.",
	}


func cancel() -> void:
	_action_type = ""
	_target_city_id = ""
	_source_city_id = ""
	_pending_presentation = false
	_resolving = false


func get_action_type() -> String:
	return _action_type


func get_target_city_id() -> String:
	return _target_city_id


func get_source_city_id() -> String:
	return _source_city_id


func is_active(action_type: String = "") -> bool:
	if _action_type.is_empty():
		return false
	return action_type.is_empty() or _action_type == action_type.strip_edges().to_lower()


func request_presentation(action_type: String, action_id: String, target_city_id: String) -> Dictionary:
	if _resolving or _pending_presentation:
		return _failure("already_pending", "이미 실행 중인 도시 행동이 있습니다.")
	if not _matches(action_type, target_city_id):
		return _failure("context_changed", "도시 행동 대상이 변경되었습니다.")
	if action_id.strip_edges().is_empty():
		return _failure("missing_action", "실행할 행동을 선택해 주세요.")
	_pending_presentation = true
	presentation_requested.emit(_action_type, action_id, _target_city_id)
	return {"ok": true, "success": true}


func complete(
	action_type: String,
	action_id: String,
	target_city_id: String
) -> Dictionary:
	if _resolving or not _pending_presentation:
		return _failure("not_pending", "실행 대기 중인 도시 행동이 없습니다.")
	if not _matches(action_type, target_city_id):
		var changed_result := _failure("context_changed", "도시 행동 대상이 변경되었습니다.")
		resolve_without_video(_action_type, changed_result)
		return changed_result
	_resolving = true
	_pending_presentation = false
	var completed_type := _action_type
	var completed_target := _target_city_id
	var completed_source := _source_city_id
	var raw_result: Variant = _execute_domain_action(
		completed_type,
		action_id,
		completed_target,
		completed_source
	)
	var result: Dictionary = raw_result if raw_result is Dictionary else _failure(
		"invalid_result",
		"도시 행동 결과를 처리할 수 없습니다."
	)
	_clear_after_resolution()
	action_resolved.emit(completed_type, result)
	return result


func execute_now(
	action_type: String,
	action_id: String,
	target_city_id: String = "",
	source_city_id: String = ""
) -> Dictionary:
	var normalized_type := action_type.strip_edges().to_lower()
	if not VALID_ACTION_TYPES.has(normalized_type):
		return _failure("unsupported_action", "지원하지 않는 도시 행동입니다.")
	var raw_result: Variant = _execute_domain_action(
		normalized_type,
		action_id,
		target_city_id.strip_edges(),
		source_city_id.strip_edges()
	)
	return raw_result if raw_result is Dictionary else _failure(
		"invalid_result",
		"도시 행동 결과를 처리할 수 없습니다."
	)


func execute_trade_order(order: Dictionary) -> Dictionary:
	return _trade_service.execute_order(get_parent(), order)


func resolve_without_video(action_type: String, result: Dictionary) -> void:
	if _resolving:
		return
	var resolved_type := action_type.strip_edges().to_lower()
	if resolved_type.is_empty():
		resolved_type = _action_type
	_clear_after_resolution()
	action_resolved.emit(resolved_type, result)


func _execute_domain_action(
	action_type: String,
	action_id: String,
	target_city_id: String,
	source_city_id: String
) -> Variant:
	var host := get_parent()
	match action_type:
		"diplomacy":
			return _diplomacy_service.execute(host, action_id, target_city_id, source_city_id)
		"spy":
			return _spy_service.execute(host, action_id, target_city_id, source_city_id)
		"trade":
			return _trade_service.execute(host, action_id, target_city_id, source_city_id)
	return _failure("unsupported_action", "지원하지 않는 도시 행동입니다.")


func _matches(action_type: String, target_city_id: String) -> bool:
	return not _action_type.is_empty() \
		and action_type.strip_edges().to_lower() == _action_type \
		and target_city_id.strip_edges() == _target_city_id


func _clear_after_resolution() -> void:
	_action_type = ""
	_target_city_id = ""
	_source_city_id = ""
	_pending_presentation = false
	_resolving = false


func _failure(reason: String, message: String) -> Dictionary:
	return {
		"ok": false,
		"success": false,
		"reason": reason,
		"message": message,
	}
