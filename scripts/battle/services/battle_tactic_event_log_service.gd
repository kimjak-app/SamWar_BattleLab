extends RefCounted

## S4-1 observation-only tactic event log (strategy, unique skill,
## reinforcement, status tick). Independent from `battle_action_event_log`,
## `ally_move_event_log` and `enemy_action_event_log`: own sequence, own
## consumer cursor. Reads unit values, never writes battle state, never rolls
## random numbers. Events hold plain values only (int/float/String/bool/Array/Dictionary).

const FIELDS := {
	"strategy_cast": ["caster_id", "target_id", "success_rate", "success", "status_id", "turns", "turns_after"],
	"status_tick": ["unit_id", "burn_damage", "expired", "remaining"],
	"skill_cast": ["caster_id", "side", "skill_id", "effect_type", "target_mode", "target_id", "momentum_cost"],
	"skill_effect": ["caster_id", "effect_kind", "target_id", "amount", "status_id", "turns", "turns_after", "killed", "from_cell", "to_cell"],
	"skill_finished": ["caster_id", "cooldown_turns"],
	"reinforcement_arrived": ["unit_id", "side", "cell", "round", "source"],
}
const EFFECT_KINDS := ["damage", "heal", "status", "cleanse", "momentum", "move"]
const SIDES := ["ally", "enemy"]
const REINFORCEMENT_SOURCES := ["reinforce_01", "city_reinforce_02"]

var _events: Array[Dictionary] = []
var _sequence := 0
# Observation-only copy of a unit's values taken before a status tick; the
# controller records `status_tick` after the tick with the applied difference.
var _staged_tick := {}
# Observation-only copy taken right before a skill command that may move a
# unit or remove a status; the matching record call consumes it.
var _staged_command := {}


func clear() -> void:
	_events.clear()
	_sequence = 0
	_staged_tick = {}
	_staged_command = {}


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


func record_skill_cast(caster: BattleUnitState, plan: Dictionary, skill: Dictionary, target: BattleUnitState) -> Dictionary:
	if caster == null:
		return {}
	return emit("skill_cast", {
		"caster_id": caster.unit_id,
		"side": caster.side,
		"skill_id": String(plan.get("skill_id", skill.get("skill_id", ""))),
		"effect_type": String(plan.get("effect_type", skill.get("effect_type", ""))),
		"target_mode": String(skill.get("target_mode", "")),
		"target_id": target.unit_id if target != null else "",
		"momentum_cost": int(plan.get("momentum_cost", 0)),
	})


func stage_skill_command(caster: BattleUnitState, target: BattleUnitState) -> void:
	if caster == null or target == null:
		_staged_command = {}
		return
	_staged_command = {"caster_id": caster.unit_id, "caster_cell": _cell_of(caster), "target_id": target.unit_id,
		"target_cell": _cell_of(target), "target_status_ids": _status_ids(target)}


func record_skill_damage(caster: BattleUnitState, target: BattleUnitState, applied: int, damage_flag: String) -> Dictionary:
	# from/to are the caster's cells: they differ only after an advance_on_kill.
	var staged := _take_staged(caster, target)
	if staged.is_empty():
		return {}
	return _effect(caster, "damage", target.unit_id, applied, damage_flag, 0, 0, not target.is_alive(), staged.caster_cell, _cell_of(caster))


func record_skill_heal(caster: BattleUnitState, target: BattleUnitState, healed: int) -> Dictionary:
	if caster == null or target == null:
		return {}
	return _effect(caster, "heal", target.unit_id, healed, "", 0, 0, false, _cell_of(target), _cell_of(target))


func record_skill_status(caster: BattleUnitState, target: BattleUnitState, status_id: String, turns: int, magnitude: int) -> Dictionary:
	if caster == null or target == null:
		return {}
	return _effect(caster, "status", target.unit_id, magnitude, status_id, turns, target.get_status_turns(status_id), false, _cell_of(target), _cell_of(target))


func record_staged_cleanse(caster: BattleUnitState, target: BattleUnitState) -> Dictionary:
	var staged := _take_staged(caster, target)
	if staged.is_empty():
		return {}
	var current := _status_ids(target)
	for status_id in staged.target_status_ids:
		if not current.has(status_id):
			return _effect(caster, "cleanse", target.unit_id, 0, status_id, 0, 0, false, _cell_of(target), _cell_of(target))
	return {}


func record_skill_momentum(caster: BattleUnitState, side: String, amount: int) -> Dictionary:
	# target_id carries the side whose momentum changed; amount is signed.
	if caster == null:
		return {}
	return _effect(caster, "momentum", side, amount, "", 0, 0, false, [], [])


func record_staged_move(caster: BattleUnitState, target: BattleUnitState) -> Dictionary:
	# Recorded only when the unit actually changed cell.
	var staged := _take_staged(caster, target)
	if staged.is_empty() or staged.target_cell == _cell_of(target):
		return {}
	return _effect(caster, "move", target.unit_id, 0, "", 0, 0, false, staged.target_cell, _cell_of(target))


func record_skill_finished(caster: BattleUnitState, cooldown_turns: int) -> Dictionary:
	if caster == null:
		return {}
	return emit("skill_finished", {"caster_id": caster.unit_id, "cooldown_turns": cooldown_turns})


func record_reinforcement(unit: BattleUnitState, battle_round: int, source: String) -> Dictionary:
	if unit == null:
		return {}
	return emit("reinforcement_arrived", {"unit_id": unit.unit_id, "side": unit.side, "cell": _cell_of(unit), "round": battle_round, "source": source})


func _effect(caster: BattleUnitState, effect_kind: String, target_id: String, amount: int, status_id: String, turns: int, turns_after: int, killed: bool, from_cell: Array, to_cell: Array) -> Dictionary:
	return emit("skill_effect", {"caster_id": caster.unit_id, "effect_kind": effect_kind, "target_id": target_id, "amount": amount,
		"status_id": status_id, "turns": turns, "turns_after": turns_after, "killed": killed, "from_cell": from_cell, "to_cell": to_cell})


func _take_staged(caster: BattleUnitState, target: BattleUnitState) -> Dictionary:
	# Consumed once; a stage for another caster/target pair records nothing.
	var staged := _staged_command
	_staged_command = {}
	if caster == null or target == null or staged.is_empty():
		return {}
	if staged.caster_id != caster.unit_id or staged.target_id != target.unit_id:
		return {}
	return staged


func _cell_of(unit: BattleUnitState) -> Array:
	return [unit.grid_cell.x, unit.grid_cell.y]


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
		"skill_cast":
			if not _id(fields.caster_id) or not SIDES.has(fields.side) or not _id(fields.skill_id):
				return false
			return fields.effect_type is String and fields.target_mode is String and fields.target_id is String and fields.momentum_cost is int
		"skill_effect":
			if not _id(fields.caster_id) or not EFFECT_KINDS.has(fields.effect_kind) or not _id(fields.target_id):
				return false
			for key in ["amount", "turns", "turns_after"]:
				if not fields[key] is int:
					return false
			if not fields.status_id is String or not fields.killed is bool:
				return false
			for key in ["from_cell", "to_cell"]:
				if not (_cell(fields[key]) or (fields.effect_kind == "momentum" and fields[key] == [])):
					return false
			return fields.effect_kind != "momentum" or SIDES.has(fields.target_id)
		"skill_finished":
			return _id(fields.caster_id) and fields.cooldown_turns is int
		"reinforcement_arrived":
			if not _id(fields.unit_id) or not SIDES.has(fields.side) or not _cell(fields.cell):
				return false
			return fields.round is int and REINFORCEMENT_SOURCES.has(fields.source)
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
