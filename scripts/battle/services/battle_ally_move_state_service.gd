class_name BattleAllyMoveStateService
extends RefCounted

const Facing = preload("res://scripts/battle/helpers/battle_formation_facing_helper.gd")

func capture_snapshot(unit_state: BattleUnitState, ally_has_moved: bool) -> Dictionary:
	if unit_state == null: return {}
	return {"unit_id":unit_state.unit_id,"grid_cell":[unit_state.grid_cell.x,unit_state.grid_cell.y],
		"facing":unit_state.facing,"has_moved":unit_state.has_moved,"ally_has_moved":ally_has_moved}

func apply_step_facing(unit_state: BattleUnitState, from_cell: Vector2i, to_cell: Vector2i) -> Dictionary:
	if unit_state == null or to_cell.x == from_cell.x:
		return {"applied":false,"changed":false,"events":[]}
	var before := unit_state.facing
	unit_state.facing = Facing.normalize_facing("right" if to_cell.x > from_cell.x else "left")
	var events := []
	if before != unit_state.facing:
		events.append(_facing_event(unit_state,before,"step"))
	return {"applied":true,"changed":before != unit_state.facing,"from":before,"to":unit_state.facing,"events":events}

func apply_destination(unit_state: BattleUnitState, target_cell: Vector2i) -> void:
	if unit_state != null:
		unit_state.set_grid_cell(target_cell)

func commit_move_metadata(unit_state: BattleUnitState, origin_cell: Vector2i, target_cell: Vector2i, grid_distance: int, path: Array, facing_before: String) -> Dictionary:
	if unit_state == null: return {"events":[]}
	var before := unit_state.has_moved
	unit_state.has_moved = true
	unit_state.last_action = {"type":"move","origin_cell":[origin_cell.x,origin_cell.y],
		"destination_cell":[target_cell.x,target_cell.y],"moved_distance":grid_distance}
	var cells := []
	for cell in path:
		cells.append([cell.x,cell.y])
	# Legacy three-argument completion calls have no recorded route: don't invent one.
	if cells.is_empty(): return {"events":[]}
	return {"events":[{"kind":"unit_moved","fields":{
		"unit_id":unit_state.unit_id,"from":[origin_cell.x,origin_cell.y],"to":[target_cell.x,target_cell.y],
		"path":cells,"movement_kind":"normal","facing_before":facing_before,"facing_after":unit_state.facing,
		"flags_before":{"has_moved":before},"flags_after":{"has_moved":unit_state.has_moved},
		"last_action_after":unit_state.last_action.duplicate(true)}}]}

func confirm_facing(unit_state: BattleUnitState, facing: String) -> Dictionary:
	if unit_state == null: return {"events":[]}
	var before := unit_state.facing
	unit_state.facing = Facing.normalize_facing(facing)
	return {"events":[_facing_event(unit_state,before,"manual"),
		{"kind":"move_confirmed","fields":{"unit_id":unit_state.unit_id,"restored_fields":[]}}]}

func rollback(unit_state: BattleUnitState, snapshot: Dictionary) -> Dictionary:
	if unit_state == null or snapshot.is_empty(): return {"events":[]}
	unit_state.set_grid_cell(Vector2i(snapshot.grid_cell[0],snapshot.grid_cell[1]))
	unit_state.has_moved = snapshot.has_moved
	unit_state.facing = Facing.normalize_facing(snapshot.facing)
	return {"events":[{"kind":"move_reverted","fields":{"unit_id":unit_state.unit_id,
		"restored_fields":["grid_cell","facing","has_moved","ally_has_moved"]}}]}

func _facing_event(unit_state: BattleUnitState, before: String, reason: String) -> Dictionary:
	return {"kind":"facing_changed","fields":{"unit_id":unit_state.unit_id,"from":before,"to":unit_state.facing,"reason":reason}}
