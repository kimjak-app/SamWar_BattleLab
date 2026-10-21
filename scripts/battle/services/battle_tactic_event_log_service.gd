extends RefCounted

## S4-1 observation-only tactic event log (strategy, unique skill,
## reinforcement, status tick). Independent from `battle_action_event_log`,
## `ally_move_event_log` and `enemy_action_event_log`: own sequence, own
## consumer cursor. Reads unit values, never writes battle state, never rolls
## random numbers. Events hold plain values only (int/float/String/bool/Array/Dictionary).

const FIELDS := {
	"strategy_cast": ["caster_id", "target_id", "success_rate", "success", "status_id", "turns", "turns_after"],
	"status_tick": ["unit_id", "burn_damage", "expired", "remaining"],
}

var _events: Array[Dictionary] = []
var _sequence := 0
# Observation-only copy of a unit's values taken before a status tick; the
# controller records `status_tick` after the tick with the applied difference.
var _staged_tick := {}


func clear() -> void:
	_events.clear()
	_sequence = 0
	_staged_tick = {}


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


func record_strategy_cast(caster: BattleUnitState, target: BattleUnitState, success_rate: float, success: bool, status_id: String, turns: int) -> Dictionary:
	if caster == null or target == null:
		return {}
	return emit("strategy_cast", {
		"caster_id": caster.unit_id,
		"target_id": target.unit_id,
		"success_rate": success_rate,
		"success": success,
		"status_id": status_id if success else "",
		"turns": turns if success else 0,
		# apply_status_effect keeps the longer of the old and new turns.
		"turns_after": target.get_status_turns(status_id) if success else 0,
	})


func stage_status_tick(unit: BattleUnitState) -> void:
	if unit == null:
		_staged_tick = {}
		return
	_staged_tick = {"unit_id": unit.unit_id, "hp": unit.current_hp, "status_ids": _status_ids(unit)}


func emit_staged_status_tick(unit: BattleUnitState) -> Dictionary:
	# Consumed once: a tick without a matching stage records nothing.
	var staged := _staged_tick
	_staged_tick = {}
	if unit == null or staged.is_empty() or staged.unit_id != unit.unit_id:
		return {}
	var remaining := {}
	for status_id in _status_ids(unit):
		remaining[status_id] = unit.get_status_turns(status_id)
	var expired: Array = []
	for status_id in staged.status_ids:
		if not remaining.has(status_id):
			expired.append(status_id)
	return emit("status_tick", {
		"unit_id": unit.unit_id,
		"burn_damage": int(staged.hp) - unit.current_hp,
		"expired": expired,
		"remaining": remaining,
	})


func _status_ids(unit: BattleUnitState) -> Array:
	var ids: Array = []
	for key in unit.status_effects.keys():
		ids.append(String(key))
	ids.sort()
	return ids


func _valid_fields(kind: String, fields: Dictionary) -> bool:
	if not FIELDS.has(kind) or not _json_value(fields):
		return false
	if fields.size() != FIELDS[kind].size():
		return false
	for key in FIELDS[kind]:
		if not fields.has(key):
			return false
	match kind:
		"strategy_cast":
			if not _id(fields.caster_id) or not _id(fields.target_id):
				return false
			if not (fields.success_rate is float or fields.success_rate is int) or not fields.success is bool:
				return false
			if not fields.status_id is String or not fields.turns is int or not fields.turns_after is int:
				return false
			return fields.success == not fields.status_id.is_empty()
		"status_tick":
			if not _id(fields.unit_id) or not fields.burn_damage is int or fields.burn_damage < 0:
				return false
			return fields.expired is Array and fields.remaining is Dictionary
	return false


func _id(value: Variant) -> bool:
	return value is String and not value.is_empty()


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
