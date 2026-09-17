class_name WorldMapTurnController
extends Node

const TurnOutcomeRulesScript := preload("res://scripts/worldmap/t04_t05/turn_outcome_rules.gd")

const PHASE_PLAYER := "player"
const PHASE_ENEMY := "enemy"
const ENEMY_TURN_DELAY := 0.75

var _query: Callable
var _command: Callable
var _enemy_turn_pending := false
var _domestic_apply_pending := false
var _enemy_turn_timer: Timer = null


func configure(query: Callable, command: Callable) -> void:
	_query = query
	_command = command


func normalize_phase(phase: String) -> String:
	return PHASE_ENEMY if phase == PHASE_ENEMY else PHASE_PLAYER


func get_phase_label(phase: String) -> String:
	return "적군 턴" if normalize_phase(phase) == PHASE_ENEMY else "아군 턴"


func set_phase(phase: String) -> void:
	var normalized_phase := normalize_phase(phase)
	_do("set_player_state", ["turn_phase", normalized_phase])
	_do("set_player_state", ["current_phase_label", get_phase_label(normalized_phase)])
	_do("refresh_world_status")


func is_enemy_turn_pending() -> bool:
	return _enemy_turn_pending


func set_enemy_turn_pending(value: bool) -> void:
	_enemy_turn_pending = value


func is_domestic_apply_pending() -> bool:
	return _domestic_apply_pending


func set_domestic_apply_pending(value: bool) -> void:
	_domestic_apply_pending = value


func request_end_turn() -> void:
	if bool(_ask("has_terminal_outcome")):
		_do("set_status", ["게임이 종료되었습니다. 결과 화면에서 새 게임을 선택하십시오."])
		_do("present_outcome")
		return
	if _enemy_turn_pending:
		_do("set_status", ["적군 턴 진행 중..."])
		return
	var pending_invasion: Variant = _ask("pending_invasion_event")
	if pending_invasion is Dictionary and not (pending_invasion as Dictionary).is_empty():
		_do("set_status", ["진행 중인 침공 이벤트를 먼저 처리하십시오."])
		return
	var pending_battle_context: Variant = _ask("pending_battle_context")
	if pending_battle_context is Dictionary and not (pending_battle_context as Dictionary).is_empty():
		_do("set_status", ["진행 중인 전투 데이터를 먼저 처리하십시오."])
		return
	if normalize_phase(str(_ask("turn_phase"))) == PHASE_ENEMY:
		_do("set_status", ["이미 적군 턴입니다."])
		return
	var turn_number := maxi(1, int(_ask("turn_number")))
	var transaction_id := TurnOutcomeRulesScript.make_turn_resolution_id(turn_number, str(_ask("player_faction_id")))
	var completed_ids := TurnOutcomeRulesScript.normalize_string_array(_ask("completed_turn_resolution_ids"))
	if completed_ids.has(transaction_id):
		_do("set_status", ["이미 완료된 턴입니다."])
		return
	_do("set_player_state", ["turn_resolution_state", {
		"transaction_id": transaction_id,
		"source_turn": turn_number,
		"stage": "enemy_actions",
		"started": true,
	}])
	_do("play_turn_end_sfx")
	_domestic_apply_pending = true
	_do("set_player_state", ["domestic_apply_pending", true])
	set_phase(PHASE_ENEMY)
	_do("checkpoint")
	run_enemy_turn()


func run_enemy_turn() -> void:
	if bool(_ask("has_terminal_outcome")):
		_enemy_turn_pending = false
		_domestic_apply_pending = false
		_do("set_player_state", ["domestic_apply_pending", false])
		_do("present_outcome")
		return
	if _enemy_turn_pending:
		_do("set_status", ["적군 턴 진행 중..."])
		return
	print("[WorldMap] Enemy turn MVP hook reached. Enemy faction reinforcement and invasion event roll are running.")
	_enemy_turn_pending = true
	_do("set_status", ["적군 턴 진행 중..."])
	var turn_number := maxi(1, int(_ask("turn_number")))
	var turn_resolution_state := get_or_restore_resolution_state(turn_number)
	turn_resolution_state["stage"] = "enemy_actions"
	_do("set_player_state", ["turn_resolution_state", turn_resolution_state])
	var ai_domestic_result: Dictionary = _as_dictionary(_do("apply_ai_city_production"))
	var enemy_turn_already_processed := int(_ask("last_enemy_faction_turn_processed_turn")) == turn_number
	var enemy_turn_result: Dictionary = _as_dictionary(_do("process_enemy_faction_turn"))
	var invasion_event := {}
	if not enemy_turn_already_processed:
		invasion_event = _as_dictionary(_do("roll_enemy_invasion"))
		_do("attach_enemy_invasion", [invasion_event])
	if bool(invasion_event.get("resolved_automatically", false)):
		_do("set_status", ["AI 세력전 정산 완료 · 다음 아군 턴에 결과 보고"])
	elif not invasion_event.is_empty():
		_do("set_status", [str(_do("format_invasion_status", [invasion_event]))])
	elif not enemy_turn_result.is_empty():
		_do("set_status", [str(enemy_turn_result.get("summary", "이번 턴 적 행동 처리 완료"))])
	turn_resolution_state = get_or_restore_resolution_state(turn_number)
	turn_resolution_state["stage"] = "enemy_actions_complete"
	turn_resolution_state["ai_domestic_result"] = ai_domestic_result.duplicate(true)
	turn_resolution_state["enemy_turn_result"] = enemy_turn_result.duplicate(true)
	_do("set_player_state", ["turn_resolution_state", turn_resolution_state])
	_do("checkpoint")
	_do("refresh_world_status")
	var timer := get_enemy_turn_timer()
	if timer.is_inside_tree():
		timer.start(ENEMY_TURN_DELAY)


func get_enemy_turn_timer() -> Timer:
	if _enemy_turn_timer == null:
		_enemy_turn_timer = Timer.new()
		_enemy_turn_timer.name = "EnemyTurnMvpTimer"
		_enemy_turn_timer.one_shot = true
		add_child(_enemy_turn_timer)
		_enemy_turn_timer.timeout.connect(finish_enemy_turn)
	return _enemy_turn_timer


func finish_enemy_turn() -> void:
	if not _enemy_turn_pending:
		return
	_enemy_turn_pending = false
	if normalize_phase(str(_ask("turn_phase"))) != PHASE_ENEMY:
		_domestic_apply_pending = false
		_do("set_player_state", ["domestic_apply_pending", false])
		_do("refresh_world_status")
		return
	var source_turn := maxi(1, int(_ask("turn_number")))
	var turn_resolution_state := get_or_restore_resolution_state(source_turn)
	var transaction_id := str(turn_resolution_state.get("transaction_id", TurnOutcomeRulesScript.make_turn_resolution_id(source_turn, str(_ask("player_faction_id")))))
	var completed_ids := TurnOutcomeRulesScript.normalize_string_array(_ask("completed_turn_resolution_ids"))
	if completed_ids.has(transaction_id):
		_domestic_apply_pending = false
		_do("set_player_state", ["domestic_apply_pending", false])
		set_phase(PHASE_PLAYER)
		_do("checkpoint")
		return
	turn_resolution_state["stage"] = "domestic_resolution"
	_do("set_player_state", ["turn_resolution_state", turn_resolution_state])
	var domestic_summary := ""
	if _domestic_apply_pending:
		domestic_summary = str(_do("apply_domestic_turn"))
		_domestic_apply_pending = false
		_do("set_player_state", ["domestic_apply_pending", false])
	advance_world_turn()
	set_phase(PHASE_PLAYER)
	_do("evaluate_outcome")
	var next_turn := maxi(1, int(_ask("turn_number")))
	var enemy_result := _as_dictionary(_ask("last_enemy_faction_turn_result"))
	var ai_domestic_result := _as_dictionary(_ask("last_ai_domestic_apply_result"))
	var game_outcome := _as_dictionary(_ask("game_outcome"))
	var turn_result := {
		"transaction_id": transaction_id,
		"source_turn": source_turn,
		"next_turn": next_turn,
		"domestic_summary": domestic_summary,
		"enemy_summary": str(enemy_result.get("summary", "")),
		"ai_city_production_count": int(ai_domestic_result.get("city_count", 0)),
		"outcome": str(game_outcome.get("status", TurnOutcomeRulesScript.OUTCOME_ACTIVE)),
	}
	_do("set_player_state", ["last_turn_resolution_result", turn_result])
	completed_ids.append(transaction_id)
	_do("set_player_state", ["completed_turn_resolution_ids", completed_ids])
	_do("set_player_state", ["turn_resolution_state", {
		"transaction_id": transaction_id,
		"source_turn": source_turn,
		"stage": "complete",
		"completed": true,
		"next_turn": next_turn,
	}])
	var pending_invasion_event := _as_dictionary(_ask("pending_invasion_event"))
	if not pending_invasion_event.is_empty():
		_do("set_status", [str(_do("format_invasion_status", [pending_invasion_event]))])
	elif domestic_summary.is_empty():
		_do("set_status", ["다음 아군 턴 시작"])
	else:
		_do("set_status", ["내정 적용 완료 · %s" % domestic_summary])
	_do("refresh_world_status")
	_do("checkpoint")
	if bool(_ask("has_terminal_outcome")):
		_do("defer_present_outcome")
		return
	_do("defer_next_battle_report")


func advance_world_turn() -> void:
	var current_turn := maxi(1, int(_ask("turn_number")))
	var previous_month_serial := int(_do("world_month_serial", [current_turn]))
	var next_turn := current_turn + 1
	_do("set_player_state", ["turn_number", next_turn])
	var next_month_serial := int(_do("world_month_serial", [next_turn]))
	if next_month_serial != previous_month_serial:
		_do("advance_wounded_recovery_month", [next_month_serial])
	_do("update_turn_labels")
	_do("refresh_city_hud")


func get_or_restore_resolution_state(turn_number: int) -> Dictionary:
	var state := _as_dictionary(_ask("turn_resolution_state"))
	var expected_id := TurnOutcomeRulesScript.make_turn_resolution_id(turn_number, str(_ask("player_faction_id")))
	if str(state.get("transaction_id", "")) != expected_id:
		state = {
			"transaction_id": expected_id,
			"source_turn": maxi(1, turn_number),
			"stage": "enemy_actions",
			"started": true,
		}
	return state


func cancel_pending_turn() -> void:
	_enemy_turn_pending = false
	_domestic_apply_pending = false
	_do("set_player_state", ["domestic_apply_pending", false])
	if _enemy_turn_timer != null and not _enemy_turn_timer.is_stopped():
		_enemy_turn_timer.stop()


func _as_dictionary(value: Variant) -> Dictionary:
	return value if value is Dictionary else {}


func _ask(query_id: String, args: Array = []) -> Variant:
	if not _query.is_valid():
		return null
	return _query.call(query_id, args)


func _do(command_id: String, args: Array = []) -> Variant:
	if not _command.is_valid():
		return null
	return _command.call(command_id, args)
