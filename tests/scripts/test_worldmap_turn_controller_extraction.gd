extends SceneTree

const TurnControllerScript := preload("res://scripts/worldmap/turn/worldmap_turn_controller.gd")

var _checks := 0
var _failures := 0
var _state := {
	"turn_phase": "player",
	"current_phase_label": "아군 턴",
	"turn_number": 1,
	"player_faction_id": "joseon",
	"completed_turn_resolution_ids": [],
	"turn_resolution_state": {},
	"domestic_apply_pending": false,
	"last_enemy_faction_turn_processed_turn": 0,
	"last_enemy_faction_turn_result": {},
	"last_ai_domestic_apply_result": {},
	"last_turn_resolution_result": {},
	"game_outcome": {"status": "active"},
}
var _pending_invasion := {}
var _counts := {}


func _initialize() -> void:
	var original_keys := _state.keys()
	var controller := TurnControllerScript.new()
	root.add_child(controller)
	controller.configure(Callable(self, "_query"), Callable(self, "_command"))
	_expect(controller.normalize_phase("invalid") == "player" and controller.get_phase_label("enemy") == "적군 턴", "phase normalization")
	controller.request_end_turn()
	_expect(str(_state.get("turn_phase")) == "enemy" and controller.is_enemy_turn_pending(), "player to enemy phase transition")
	_expect(_count("process_enemy") == 1 and _count("ai_production") == 1, "enemy phase executes once")
	_expect(_count("roll_invasion") == 1 and _count("attach_invasion") == 1, "battle invasion handoff once")
	controller.request_end_turn()
	_expect(_count("process_enemy") == 1 and _count("roll_invasion") == 1, "double end turn blocked")
	controller.finish_enemy_turn()
	_expect(int(_state.get("turn_number", 0)) == 2 and _count("domestic") == 1, "turn increments and domestic tick once")
	_expect(str(_state.get("turn_phase")) == "player" and str(_state.get("current_phase_label")) == "아군 턴", "player phase restores")
	_expect((_state.get("completed_turn_resolution_ids", []) as Array).size() == 1, "turn resolution completes once")
	controller.finish_enemy_turn()
	_expect(int(_state.get("turn_number", 0)) == 2 and _count("domestic") == 1, "duplicate finish ignored")
	controller.request_end_turn()
	_expect(_count("process_enemy") == 1 and _count("roll_invasion") == 1, "pending invasion blocks next turn and duplicate handoff")
	var final_keys := _state.keys()
	original_keys.sort()
	final_keys.sort()
	_expect(original_keys == final_keys, "save state schema keys unchanged")
	controller.cancel_pending_turn()
	controller.queue_free()
	print("[WORLDMAP_TURN_CONTROLLER] %s: %d checks, %d failures" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	quit(0 if _failures == 0 else 1)


func _query(query_id: String, _args: Array) -> Variant:
	match query_id:
		"has_terminal_outcome": return false
		"pending_invasion_event": return _pending_invasion
		"pending_battle_context": return {}
		"turn_phase": return _state.get("turn_phase")
		"turn_number": return _state.get("turn_number")
		"player_faction_id": return _state.get("player_faction_id")
		"completed_turn_resolution_ids": return _state.get("completed_turn_resolution_ids")
		"turn_resolution_state": return _state.get("turn_resolution_state")
		"last_enemy_faction_turn_processed_turn": return _state.get("last_enemy_faction_turn_processed_turn")
		"last_enemy_faction_turn_result": return _state.get("last_enemy_faction_turn_result")
		"last_ai_domestic_apply_result": return _state.get("last_ai_domestic_apply_result")
		"game_outcome": return _state.get("game_outcome")
	return null


func _command(command_id: String, args: Array) -> Variant:
	match command_id:
		"set_player_state":
			_state[str(args[0])] = args[1]
		"apply_ai_city_production":
			_bump("ai_production")
			var result := {"city_count": 2}
			_state["last_ai_domestic_apply_result"] = result
			return result
		"process_enemy_faction_turn":
			_bump("process_enemy")
			_state["last_enemy_faction_turn_processed_turn"] = int(_state.get("turn_number", 1))
			var result := {"summary": "enemy complete"}
			_state["last_enemy_faction_turn_result"] = result
			return result
		"roll_enemy_invasion":
			_bump("roll_invasion")
			_pending_invasion = {"defender_city_id": "hanseong"}
			return _pending_invasion
		"attach_enemy_invasion":
			_bump("attach_invasion")
		"apply_domestic_turn":
			_bump("domestic")
			return "domestic complete"
		"world_month_serial":
			return int(floor(float(maxi(0, int(args[0]) - 1)) * 12.0 / 40.0))
		"format_invasion_status":
			return "invasion pending"
	return null


func _bump(key: String) -> void:
	_counts[key] = _count(key) + 1


func _count(key: String) -> int:
	return int(_counts.get(key, 0))


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("[WORLDMAP_TURN_CONTROLLER_FAIL] %s" % label)
