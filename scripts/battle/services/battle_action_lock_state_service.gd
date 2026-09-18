class_name BattleActionLockStateService
extends RefCounted

const SIDE_ALLY := "ally"
const SIDE_ENEMY := "enemy"

var _acted_ally_unit_ids: Dictionary = {}
var _acted_enemy_unit_ids: Dictionary = {}


func has_unit_acted(unit_state: BattleUnitState, expected_side: String) -> bool:
	if unit_state == null:
		return true
	if unit_state.side != expected_side:
		return false
	if unit_state.unit_id.is_empty():
		return unit_state.has_acted
	return bool(_registry_for_side(expected_side).get(unit_state.unit_id, unit_state.has_acted))


func register_unit_acted(unit_state: BattleUnitState, expected_side: String) -> Dictionary:
	if unit_state == null or unit_state.side != expected_side or unit_state.unit_id.is_empty():
		return {"accepted": false, "was_already_acted": false}
	var was_already_acted := has_unit_acted(unit_state, expected_side)
	_registry_for_side(expected_side)[unit_state.unit_id] = true
	return {"accepted": true, "was_already_acted": was_already_acted}


func clear_side(side: String) -> void:
	match side:
		SIDE_ALLY:
			_acted_ally_unit_ids.clear()
		SIDE_ENEMY:
			_acted_enemy_unit_ids.clear()


func erase_unit_id(unit_id: String) -> void:
	if unit_id.is_empty():
		return
	_acted_ally_unit_ids.erase(unit_id)
	_acted_enemy_unit_ids.erase(unit_id)


func export_acted_ids(side: String) -> Dictionary:
	return _registry_for_side(side).duplicate(true)


func restore_acted_ids(side: String, value: Variant) -> void:
	var restored: Dictionary = (value as Dictionary).duplicate(true) if value is Dictionary else {}
	match side:
		SIDE_ALLY:
			_acted_ally_unit_ids = restored
		SIDE_ENEMY:
			_acted_enemy_unit_ids = restored


func count_unacted(units: Array[BattleUnitState], expected_side: String) -> int:
	var remaining_count := 0
	for unit_state in units:
		if not has_unit_acted(unit_state, expected_side):
			remaining_count += 1
	return remaining_count


func first_unacted(units: Array[BattleUnitState], expected_side: String) -> BattleUnitState:
	for unit_state in units:
		if not has_unit_acted(unit_state, expected_side):
			return unit_state
	return null


func are_all_acted(units: Array[BattleUnitState], expected_side: String) -> bool:
	return count_unacted(units, expected_side) == 0


func _registry_for_side(side: String) -> Dictionary:
	match side:
		SIDE_ALLY:
			return _acted_ally_unit_ids
		SIDE_ENEMY:
			return _acted_enemy_unit_ids
	return {}
