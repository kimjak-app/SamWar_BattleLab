class_name BattleEventLogService
extends RefCounted

const FIELDS := {
	"unit_moved": ["unit_id", "from", "to", "path", "movement_kind", "facing_before", "facing_after", "flags_before", "flags_after", "last_action_after"],
	"facing_changed": ["unit_id", "from", "to", "reason"],
	"move_confirmed": ["unit_id", "restored_fields"],
	"move_reverted": ["unit_id", "restored_fields"],
}
const FACINGS := ["left", "right", "up", "down"]
var _events: Array[Dictionary] = []
var _sequence := 0

func clear() -> void:
	_events.clear()
	_sequence = 0

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

func _valid_fields(kind: String, fields: Dictionary) -> bool:
	if not FIELDS.has(kind) or not _json_value(fields):
		return false
	if fields.size() != FIELDS[kind].size():
		return false
	for key in FIELDS[kind]:
		if not fields.has(key):
			return false
	if not fields.unit_id is String or fields.unit_id.is_empty():
		return false
	match kind:
		"unit_moved":
			if not _cell(fields.from) or not _cell(fields.to) or not fields.path is Array:
				return false
			if fields.path.size() < 2 or fields.path[0] != fields.from or fields.path[-1] != fields.to:
				return false
			for cell in fields.path:
				if not _cell(cell):
					return false
			if fields.movement_kind != "normal" or not FACINGS.has(fields.facing_before) or not FACINGS.has(fields.facing_after):
				return false
			return _flags(fields.flags_before) and _flags(fields.flags_after) and fields.last_action_after is Dictionary
		"facing_changed":
			return FACINGS.has(fields.from) and FACINGS.has(fields.to) and ["step", "manual"].has(fields.reason)
		"move_confirmed":
			return fields.restored_fields is Array and fields.restored_fields.is_empty()
		"move_reverted":
			return fields.restored_fields == ["grid_cell", "facing", "has_moved", "ally_has_moved"]
	return false

func _flags(value: Variant) -> bool:
	return value is Dictionary and value.size() == 1 and value.has("has_moved") and value.has_moved is bool

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
