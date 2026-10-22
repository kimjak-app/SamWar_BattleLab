extends RefCounted

## S3-1 observation-only enemy-turn event log.
## Independent from `battle_action_event_log` / `ally_move_event_log`: own
## sequence, own consumer cursor. Reads unit values, never writes battle state.
## Events hold plain values only (int/String/bool/Array/Dictionary).

const FIELDS := {
	"enemy_turn_started": ["round"],
	"enemy_actor_selected": ["unit_id"],
	"enemy_moved": ["unit_id", "path", "from", "to"],
	"enemy_attack_resolved": ["attacker_id", "target_id", "damage_applied", "raw_damage", "angle_type", "target_troops_after", "killed"],
	"enemy_waited": ["unit_id", "reason"],
	"enemy_action_completed": ["unit_id"],
	"enemy_skill_used": ["unit_id", "skill_id", "target_id"],
	"round_started": ["round"],
	"battle_ended": ["result_state"],
	# S4-2a: an enemy strategy attempt (recorded before its strategy_cast effect).
	"enemy_strategy_used": ["unit_id", "target_id"],
}
const WAIT_REASONS := ["wait", "confused", "no_path", "path_blocked", "no_target"]
const ANGLE_TYPES := ["front", "side", "back"]

var _events: Array[Dictionary] = []
var _sequence := 0
# Observation-only copy of the path handed to the enemy move Tween. The
# controller records `enemy_moved` when the Tween commits the cell.
var _staged_move_unit_id := ""
var _staged_move_path: Array = []


func clear() -> void:
	_events.clear()
	_sequence = 0
	_clear_staged_move()


func emit(kind: String, fields: Dictionary) -> Dictionary:
	if not _valid_fields(kind, fields):
		return {}
	var event := fields.duplicate(true)
	event["schema_version"] = 0
	event["sequence"] = _sequence
	event["kind"] = kind
	_sequence += 1
	_events.append(event)
	return event.duplicate(true)


func export() -> Array[Dictionary]:
	return _events.duplicate(true)


func record_unit(kind: String, unit: BattleUnitState) -> Dictionary:
	if unit == null:
		return {}
	return emit(kind, {"unit_id": unit.unit_id})


func record_waited(unit: BattleUnitState, reason: String) -> Dictionary:
	if unit == null:
		return {}
	return emit("enemy_waited", {"unit_id": unit.unit_id, "reason": reason})


func record_attack(attacker: BattleUnitState, target: BattleUnitState, raw_damage: int, damage_applied: int, angle_type: String) -> Dictionary:
	if attacker == null or target == null:
		return {}
	return emit("enemy_attack_resolved", {
		"attacker_id": attacker.unit_id,
		"target_id": target.unit_id,
		"damage_applied": damage_applied,
		"raw_damage": raw_damage,
		"angle_type": angle_type,
		"target_troops_after": target.current_troops,
		"killed": not target.is_alive(),
	})


func record_skill(caster: BattleUnitState, skill_data: Dictionary, target: BattleUnitState) -> Dictionary:
	if caster == null or caster.side != "enemy":
		return {}
	return emit("enemy_skill_used", {
		"unit_id": caster.unit_id,
		"skill_id": String(skill_data.get("skill_id", "")),
		"target_id": target.unit_id if target != null else "",
	})


func record_strategy(caster: BattleUnitState, target: BattleUnitState) -> Dictionary:
	if caster == null or caster.side != "enemy" or target == null:
		return {}
	return emit("enemy_strategy_used", {"unit_id": caster.unit_id, "target_id": target.unit_id})


func stage_move_path(unit_id: String, path: Array) -> void:
	_staged_move_unit_id = unit_id
	_staged_move_path = []
	for cell in path:
		if cell is Vector2i:
			_staged_move_path.append([cell.x, cell.y])


func emit_staged_move(unit_id: String, to_cell: Vector2i) -> Dictionary:
	# Consumed once: a repeated finish for the same move records nothing.
	if unit_id.is_empty() or unit_id != _staged_move_unit_id or _staged_move_path.size() < 2:
		_clear_staged_move()
		return {}
	var path := _staged_move_path.duplicate(true)
	_clear_staged_move()
	if path[-1] != [to_cell.x, to_cell.y]:
		return {}
	return emit("enemy_moved", {"unit_id": unit_id, "path": path, "from": path[0], "to": path[-1]})


func _clear_staged_move() -> void:
	_staged_move_unit_id = ""
	_staged_move_path = []


func _valid_fields(kind: String, fields: Dictionary) -> bool:
	if not FIELDS.has(kind) or not _json_value(fields):
		return false
	if fields.size() != FIELDS[kind].size():
		return false
	for key in FIELDS[kind]:
		if not fields.has(key):
			return false
	match kind:
		"enemy_turn_started", "round_started":
			return fields.round is int
		"battle_ended":
			return fields.result_state is String and not fields.result_state.is_empty()
		"enemy_attack_resolved":
			for key in ["attacker_id", "target_id"]:
				if not _id(fields[key]):
					return false
			for key in ["damage_applied", "raw_damage", "target_troops_after"]:
				if not fields[key] is int:
					return false
			return ANGLE_TYPES.has(fields.angle_type) and fields.killed is bool
	if not _id(fields.unit_id):
		return false
	match kind:
		"enemy_actor_selected", "enemy_action_completed":
			return true
		"enemy_waited":
			return WAIT_REASONS.has(fields.reason)
		"enemy_skill_used":
			return fields.skill_id is String and fields.target_id is String
		"enemy_strategy_used":
			return _id(fields.target_id)
		"enemy_moved":
			if not fields.path is Array or fields.path.size() < 2:
				return false
			for cell in fields.path:
				if not _cell(cell):
					return false
			return fields.path[0] == fields.from and fields.path[-1] == fields.to
	return false


func _id(value: Variant) -> bool:
	return value is String and not value.is_empty()


func _cell(value: Variant) -> bool:
	return value is Array and value.size() == 2 and value[0] is int and value[1] is int


func _json_value(value: Variant) -> bool:
	match typeof(value):
		TYPE_NIL, TYPE_BOOL, TYPE_INT, TYPE_STRING:
			return true
		TYPE_FLOAT:
			return is_finite(value)
		TYPE_ARRAY:
			for item in value:
				if not _json_value(item):
					return false
			return true
		TYPE_DICTIONARY:
			for key in value:
				if not key is String or not _json_value(value[key]):
					return false
			return true
	return false
