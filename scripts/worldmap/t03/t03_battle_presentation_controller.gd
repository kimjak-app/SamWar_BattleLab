class_name T03BattlePresentationController
extends Node

signal presentation_completed(result: Dictionary)
signal presentation_queue_empty(result: Dictionary)

var _root: Control
var _video_player: VideoStreamPlayer
var _video_labels: Label
var _skip_button: Button
var _result_card: PanelContainer
var _result_title: Label
var _result_body: Label
var _confirm_button: Button
var _state_query: Callable
var _state_mutation: Callable
var _format_faction: Callable
var _format_city: Callable
var _video_path := ""
var _active_report: Dictionary = {}
var _phase := "idle"
var _completion_emitted := false
var _queue_empty_emitted := false


func configure(nodes: Dictionary, state_query: Callable, state_mutation: Callable, format_faction: Callable, format_city: Callable, video_path: String) -> void:
	_root = nodes.get("root") as Control
	_video_player = nodes.get("video_player") as VideoStreamPlayer
	_video_labels = nodes.get("video_labels") as Label
	_skip_button = nodes.get("skip_button") as Button
	_result_card = nodes.get("result_card") as PanelContainer
	_result_title = nodes.get("result_title") as Label
	_result_body = nodes.get("result_body") as Label
	_confirm_button = nodes.get("confirm_button") as Button
	_state_query = state_query
	_state_mutation = state_mutation
	_format_faction = format_faction
	_format_city = format_city
	_video_path = video_path


func setup() -> Dictionary:
	var report := _result("setup")
	if not _nodes_valid():
		return _reject(report, "missing_presentation_node")
	_root.visible = false
	_result_card.visible = false
	if not _skip_button.pressed.is_connected(_on_skip_pressed):
		_skip_button.pressed.connect(_on_skip_pressed)
	if not _confirm_button.pressed.is_connected(_on_confirm_pressed):
		_confirm_button.pressed.connect(_on_confirm_pressed)
	if not _video_player.finished.is_connected(_on_video_finished):
		_video_player.finished.connect(_on_video_finished)
	_video_player.stream = load(_video_path) as VideoStream if not _video_path.is_empty() and ResourceLoader.exists(_video_path) else null
	_phase = "idle"
	report["ok"] = true
	report["video_available"] = _video_player.stream != null
	return report


func build_report(result: Dictionary) -> Dictionary:
	if result.is_empty():
		return {}
	var attacker_city_id := str(result.get("attacker_city_id", result.get("attacker_source_city_id", "")))
	var defender_city_id := str(result.get("defender_city_id", ""))
	var attacker_owner := str(result.get("attacker_owner", ""))
	var defender_owner := str(result.get("defender_owner", ""))
	var attacker_won := str(result.get("winner_side", result.get("winner", "defender"))) == "attacker"
	var title := "%s군이 %s을 점령했습니다." % [_faction(attacker_owner), _city(defender_city_id)] if attacker_won else "%s군이 방어에 성공했습니다." % _faction(defender_owner)
	return {
		"report_id": str(result.get("result_id", "")),
		"transaction_id": str(result.get("transaction_id", "")),
		"attacker_city_id": attacker_city_id,
		"defender_city_id": defender_city_id,
		"attacker_owner": attacker_owner,
		"defender_owner": defender_owner,
		"title": title,
		"labels": "%s군\n%s → %s\n%s군" % [_faction(attacker_owner), _city(attacker_city_id), _city(defender_city_id), _faction(defender_owner)],
		"lines": [
			"%s군이 %s을 공격했습니다." % [_faction(attacker_owner), _city(defender_city_id)],
			"공격군 · 정상병 %d · 부상병 %d · 전사 %d · 이탈 %d" % [int(result.get("attacker_healthy_survivors", 0)), int(result.get("attacker_wounded", 0)), int(result.get("attacker_dead", 0)), int(result.get("attacker_deserters", 0))],
			"방어군 · 정상병 %d · 부상병 %d · 전사 %d · 이탈 %d" % [int(result.get("defender_healthy_survivors", 0)), int(result.get("defender_wounded", 0)), int(result.get("defender_dead", 0)), int(result.get("defender_deserters", 0))],
			"전투 %d턴 종료 · %s" % [int(result.get("completed_turn", 0)), "30턴 수비 승리" if str(result.get("result_reason", "")) == "turn_limit" else "전투 종료"],
		],
	}


func enqueue_report(report: Dictionary) -> Dictionary:
	var result := _result("enqueue")
	var report_id := str(report.get("report_id", ""))
	result["report_id"] = report_id
	if report.is_empty() or report_id.is_empty():
		return _reject(result, "malformed_report")
	var acknowledged := _string_array(_q("acknowledged_report_ids", [], []))
	var queue := _report_array(_q("report_queue", [], []))
	if acknowledged.has(report_id) or str(_active_report.get("report_id", "")) == report_id or _queue_has_report(queue, report_id):
		result["ok"] = true
		result["duplicate"] = true
		result["queue_size"] = queue.size()
		return result
	queue.append(report.duplicate(true))
	if not bool(_m("set_report_queue", [queue], false)):
		return _reject(result, "queue_write_failed")
	_queue_empty_emitted = false
	result["ok"] = true
	result["queue_changed"] = true
	result["queue_size"] = queue.size()
	return result


func try_present_next() -> Dictionary:
	var result := _result("present_next")
	if not _nodes_valid():
		return _reject(result, "missing_presentation_node")
	if _root.visible or not _active_report.is_empty():
		result["ok"] = true
		result["duplicate"] = true
		return result
	var acknowledged := _string_array(_q("acknowledged_report_ids", [], []))
	var queue := _report_array(_q("report_queue", [], []))
	while not queue.is_empty():
		var candidate: Dictionary = queue[0]
		var report_id := str(candidate.get("report_id", ""))
		if not report_id.is_empty() and not acknowledged.has(report_id):
			_active_report = candidate.duplicate(true)
			break
		queue.pop_front()
	_m("set_report_queue", [queue], null)
	if _active_report.is_empty():
		_phase = "idle"
		result["ok"] = true
		result["queue_empty"] = true
		if not _queue_empty_emitted:
			_queue_empty_emitted = true
			presentation_queue_empty.emit(result.duplicate(true))
		return result
	_completion_emitted = false
	_root.visible = true
	_result_card.visible = false
	_video_labels.visible = true
	_video_labels.text = str(_active_report.get("labels", ""))
	_skip_button.visible = true
	_video_player.visible = true
	result["ok"] = true
	result["report_id"] = str(_active_report.get("report_id", ""))
	if _video_player.stream != null:
		_phase = "video"
		_video_player.play()
		result["phase"] = _phase
	else:
		show_result_card()
		result["phase"] = _phase
	return result


func skip_video() -> Dictionary:
	var result := _result("skip_video")
	if _phase != "video":
		return _reject(result, "video_not_playing")
	_video_player.stop()
	return show_result_card()


func finish_video() -> Dictionary:
	var result := _result("finish_video")
	if _phase != "video":
		return _reject(result, "video_not_playing")
	return show_result_card()


func show_result_card() -> Dictionary:
	var result := _result("show_card")
	if _active_report.is_empty():
		return _reject(result, "missing_active_report")
	if _phase == "card":
		result["ok"] = true
		result["duplicate"] = true
		return result
	_video_player.visible = false
	_video_labels.visible = false
	_skip_button.visible = false
	_result_card.visible = true
	_result_title.text = str(_active_report.get("title", "전투 결과"))
	var lines: Variant = _active_report.get("lines", [])
	var formatted_lines: Array[String] = []
	if lines is Array:
		for line in lines:
			formatted_lines.append(str(line))
	_result_body.text = "\n\n".join(formatted_lines) if lines is Array else str(lines)
	_phase = "card"
	result["ok"] = true
	result["phase"] = _phase
	result["report_id"] = str(_active_report.get("report_id", ""))
	return result


func confirm_report() -> Dictionary:
	var result := _result("confirm")
	if _phase != "card" or _active_report.is_empty():
		return _reject(result, "report_not_confirmable")
	if _completion_emitted:
		result["ok"] = true
		result["duplicate"] = true
		return result
	_completion_emitted = true
	var report_id := str(_active_report.get("report_id", ""))
	var acknowledged := _string_array(_q("acknowledged_report_ids", [], []))
	if not report_id.is_empty() and not acknowledged.has(report_id):
		acknowledged.append(report_id)
	_m("set_acknowledged_report_ids", [acknowledged], null)
	var next_queue: Array[Dictionary] = []
	for queued in _report_array(_q("report_queue", [], [])):
		if str(queued.get("report_id", "")) != report_id:
			next_queue.append(queued)
	_m("set_report_queue", [next_queue], null)
	result["ok"] = true
	result["report_id"] = report_id
	result["transaction_id"] = str(_active_report.get("transaction_id", ""))
	result["queue_size"] = next_queue.size()
	_active_report = {}
	_phase = "idle"
	_root.visible = false
	presentation_completed.emit(result.duplicate(true))
	return result


func reset_presentation() -> void:
	if _video_player != null:
		_video_player.stop()
	if _root != null:
		_root.visible = false
	if _result_card != null:
		_result_card.visible = false
	_active_report = {}
	_phase = "idle"
	_completion_emitted = false


func get_state_snapshot() -> Dictionary:
	return {
		"phase": _phase,
		"active_report": _active_report.duplicate(true),
		"root_visible": _root != null and _root.visible,
		"card_visible": _result_card != null and _result_card.visible,
	}


func _on_skip_pressed() -> void:
	skip_video()


func _on_confirm_pressed() -> void:
	confirm_report()


func _on_video_finished() -> void:
	finish_video()


func _nodes_valid() -> bool:
	return _root != null and _video_player != null and _video_labels != null and _skip_button != null and _result_card != null and _result_title != null and _result_body != null and _confirm_button != null


func _faction(faction_id: String) -> String:
	return str(_format_faction.call(faction_id)) if _format_faction.is_valid() else faction_id


func _city(city_id: String) -> String:
	return str(_format_city.call(city_id, city_id)) if _format_city.is_valid() else city_id


func _queue_has_report(queue: Array[Dictionary], report_id: String) -> bool:
	for queued in queue:
		if str(queued.get("report_id", "")) == report_id:
			return true
	return false


func _report_array(value: Variant) -> Array[Dictionary]:
	var reports: Array[Dictionary] = []
	if value is Array:
		for entry in value:
			if entry is Dictionary:
				reports.append((entry as Dictionary).duplicate(true))
	return reports


func _string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if value is Array:
		for entry in value:
			var text := str(entry)
			if not text.is_empty() and not result.has(text):
				result.append(text)
	return result


func _result(action: String) -> Dictionary:
	return {"ok": false, "action": action, "report_id": "", "transaction_id": "", "phase": _phase, "duplicate": false, "queue_changed": false, "queue_empty": false, "queue_size": 0, "error_code": "", "warnings": []}


func _reject(result: Dictionary, error_code: String) -> Dictionary:
	result["error_code"] = error_code
	(result["warnings"] as Array).append(error_code)
	return result


func _q(query_id: String, args: Array = [], fallback: Variant = null) -> Variant:
	if not _state_query.is_valid():
		return fallback
	var value: Variant = _state_query.call(query_id, args)
	return fallback if value == null else value


func _m(mutation_id: String, args: Array = [], fallback: Variant = null) -> Variant:
	if not _state_mutation.is_valid():
		return fallback
	var value: Variant = _state_mutation.call(mutation_id, args)
	return fallback if value == null else value
