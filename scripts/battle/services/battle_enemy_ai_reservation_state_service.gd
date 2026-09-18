class_name BattleEnemyAiReservationStateService
extends RefCounted

var _reserved_destination_cells: Dictionary = {}
var _reserved_engagement_cells: Dictionary = {}


func clear_turn_reservations() -> void:
	_reserved_destination_cells.clear()
	_reserved_engagement_cells.clear()


func is_destination_reserved_for_other_actor(cell: Vector2i, actor_cell: Vector2i, actor_slot_id: String) -> bool:
	if cell == actor_cell:
		return false
	if not _reserved_destination_cells.has(cell):
		return false
	return str(_reserved_destination_cells.get(cell, "")) != actor_slot_id


func is_engagement_reserved_for_other_actor(cell: Vector2i, actor_cell: Vector2i, actor_slot_id: String) -> bool:
	if cell == actor_cell:
		return false
	if not _reserved_engagement_cells.has(cell):
		return false
	return str(_reserved_engagement_cells.get(cell, "")) != actor_slot_id


func reserve_decision_plan(actor_cell: Vector2i, actor_slot_id: String, decision_plan: Dictionary) -> void:
	if decision_plan.is_empty():
		return
	var destination: Vector2i = decision_plan.get("destination", actor_cell)
	var final_cell: Vector2i = decision_plan.get("final_cell", destination)
	if destination != actor_cell:
		_reserved_destination_cells[destination] = actor_slot_id
	if final_cell != actor_cell:
		_reserved_engagement_cells[final_cell] = actor_slot_id
