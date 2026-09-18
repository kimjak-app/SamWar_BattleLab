class_name BattleCombatQueryService
extends RefCounted

const BattleFormationFacingHelperScript := preload("res://scripts/battle/helpers/battle_formation_facing_helper.gd")
const UnitTypeContractScript := preload("res://scripts/battle/unit_type_contract.gd")

const ATTACK_ANGLE_FRONT := "front"
const ATTACK_ANGLE_SIDE := "side"
const ATTACK_ANGLE_BACK := "back"


func get_direction_from_positions(from_cell: Vector2i, to_cell: Vector2i) -> String:
	var delta := to_cell - from_cell
	if absi(delta.x) >= absi(delta.y):
		if delta.x > 0:
			return BattleFormationFacingHelperScript.FACING_RIGHT
		if delta.x < 0:
			return BattleFormationFacingHelperScript.FACING_LEFT
	if delta.y > 0:
		return BattleFormationFacingHelperScript.FACING_DOWN
	if delta.y < 0:
		return BattleFormationFacingHelperScript.FACING_UP
	return BattleFormationFacingHelperScript.FACING_RIGHT


func get_opposite_facing(facing: String) -> String:
	match BattleFormationFacingHelperScript.normalize_facing(facing):
		BattleFormationFacingHelperScript.FACING_LEFT:
			return BattleFormationFacingHelperScript.FACING_RIGHT
		BattleFormationFacingHelperScript.FACING_RIGHT:
			return BattleFormationFacingHelperScript.FACING_LEFT
		BattleFormationFacingHelperScript.FACING_UP:
			return BattleFormationFacingHelperScript.FACING_DOWN
		BattleFormationFacingHelperScript.FACING_DOWN:
			return BattleFormationFacingHelperScript.FACING_UP
		_:
			return BattleFormationFacingHelperScript.FACING_LEFT


func get_attack_angle_type(attacker_state: BattleUnitState, defender_state: BattleUnitState) -> String:
	if attacker_state == null or defender_state == null:
		return ATTACK_ANGLE_FRONT
	var incoming_direction := get_direction_from_positions(defender_state.grid_cell, attacker_state.grid_cell)
	var defender_facing := BattleFormationFacingHelperScript.normalize_facing(defender_state.facing)
	if incoming_direction == defender_facing:
		return ATTACK_ANGLE_FRONT
	if incoming_direction == get_opposite_facing(defender_facing):
		return ATTACK_ANGLE_BACK
	return ATTACK_ANGLE_SIDE


func is_unit_in_attack_range(attacker: BattleUnitState, target: BattleUnitState, distance: int) -> bool:
	if attacker == null or target == null:
		return false
	if not target.is_alive():
		return false
	return UnitTypeContractScript.can_unit_attack(attacker.unit_type, attacker.has_moved, attacker.has_acted, distance)
