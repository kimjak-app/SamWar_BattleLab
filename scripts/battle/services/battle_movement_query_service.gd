class_name BattleMovementQueryService
extends RefCounted

const DIRECTIONS: Array[Vector2i] = [
	Vector2i(1, 0),
	Vector2i(-1, 0),
	Vector2i(0, 1),
	Vector2i(0, -1),
]


func get_effective_move_range(unit_state: BattleUnitState) -> int:
	if unit_state == null:
		return 0
	var result := unit_state.move_range
	if unit_state.has_status_effect("mobility_up"):
		result += 1
	if unit_state.has_status_effect("movement_down"):
		result -= 1
	return maxi(result, 0)


func get_occupied_cells_except(alive_unit_states: Array[BattleUnitState], mover_state: BattleUnitState, allow_breakthrough: bool) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	if allow_breakthrough:
		return cells
	for alive_unit_state in alive_unit_states:
		if alive_unit_state == mover_state:
			continue
		cells.append(alive_unit_state.grid_cell)
	return cells


func is_cell_occupied_except(cell: Vector2i, alive_unit_states: Array[BattleUnitState], mover_state: BattleUnitState, allow_breakthrough: bool) -> bool:
	for occupied_cell in get_occupied_cells_except(alive_unit_states, mover_state, allow_breakthrough):
		if occupied_cell == cell:
			return true
	return false


func is_valid_destination_for_unit(target_cell: Vector2i, mover_state: BattleUnitState, grid_controller: BattleGridController, alive_unit_states: Array[BattleUnitState], allow_breakthrough: bool) -> bool:
	if mover_state == null or grid_controller == null:
		return false
	if not grid_controller.is_in_bounds(target_cell):
		return false
	return not is_cell_occupied_except(target_cell, alive_unit_states, mover_state, allow_breakthrough)


func is_path_clear_for_unit(path: Array[Vector2i], mover_state: BattleUnitState, alive_unit_states: Array[BattleUnitState], allow_breakthrough: bool) -> bool:
	if mover_state == null or path.is_empty():
		return false
	for index in range(1, path.size()):
		if is_cell_occupied_except(path[index], alive_unit_states, mover_state, allow_breakthrough):
			return false
	return true


func is_cell_walkable(cell: Vector2i, start_cell: Vector2i, mover_state: BattleUnitState, grid_controller: BattleGridController, alive_unit_states: Array[BattleUnitState], allow_breakthrough: bool) -> bool:
	if grid_controller == null or not grid_controller.is_in_bounds(cell):
		return false
	if cell == start_cell:
		return true
	return not is_cell_occupied_except(cell, alive_unit_states, mover_state, allow_breakthrough)


func find_move_path(start_cell: Vector2i, target_cell: Vector2i, mover_state: BattleUnitState, max_steps: int, grid_controller: BattleGridController, alive_unit_states: Array[BattleUnitState], allow_breakthrough: bool) -> Array[Vector2i]:
	var empty_path: Array[Vector2i] = []
	if grid_controller == null or mover_state == null:
		return empty_path
	if start_cell == target_cell:
		return [start_cell]
	if not is_valid_destination_for_unit(target_cell, mover_state, grid_controller, alive_unit_states, allow_breakthrough):
		return empty_path
	if not is_cell_walkable(target_cell, start_cell, mover_state, grid_controller, alive_unit_states, allow_breakthrough):
		return empty_path

	var frontier: Array[Vector2i] = [start_cell]
	var came_from: Dictionary = {start_cell: start_cell}
	var steps_from_start: Dictionary = {start_cell: 0}

	while not frontier.is_empty():
		var current: Vector2i = frontier.pop_front()
		if current == target_cell:
			break

		var current_steps: int = steps_from_start.get(current, 0)
		if current_steps >= max_steps:
			continue

		for direction in DIRECTIONS:
			var next: Vector2i = current + direction
			if came_from.has(next):
				continue
			if not is_cell_walkable(next, start_cell, mover_state, grid_controller, alive_unit_states, allow_breakthrough):
				continue
			came_from[next] = current
			steps_from_start[next] = current_steps + 1
			frontier.append(next)

	if not came_from.has(target_cell):
		return empty_path

	var path := _build_path(came_from, start_cell, target_cell)
	if path.size() - 1 > max_steps:
		return empty_path
	if not is_path_clear_for_unit(path, mover_state, alive_unit_states, allow_breakthrough):
		return empty_path
	return path


func get_reachable_paths(start_cell: Vector2i, mover_state: BattleUnitState, max_steps: int, grid_controller: BattleGridController, alive_unit_states: Array[BattleUnitState], allow_breakthrough: bool) -> Dictionary:
	var reachable_paths: Dictionary = {}
	if grid_controller == null or mover_state == null:
		return reachable_paths

	var frontier: Array[Vector2i] = [start_cell]
	var came_from: Dictionary = {start_cell: start_cell}
	var steps_from_start: Dictionary = {start_cell: 0}

	while not frontier.is_empty():
		var current: Vector2i = frontier.pop_front()
		var current_steps: int = steps_from_start.get(current, 0)
		if current_steps >= max_steps:
			continue

		for direction in DIRECTIONS:
			var next: Vector2i = current + direction
			if came_from.has(next):
				continue
			if not is_cell_walkable(next, start_cell, mover_state, grid_controller, alive_unit_states, allow_breakthrough):
				continue
			came_from[next] = current
			steps_from_start[next] = current_steps + 1
			frontier.append(next)

	for cell_variant in came_from.keys():
		var cell: Vector2i = cell_variant
		if not is_valid_destination_for_unit(cell, mover_state, grid_controller, alive_unit_states, allow_breakthrough):
			continue
		var path := _build_path(came_from, start_cell, cell)
		if not is_path_clear_for_unit(path, mover_state, alive_unit_states, allow_breakthrough):
			continue
		reachable_paths[cell] = path

	return reachable_paths


func get_unit_grid_distance(attacker: BattleUnitState, target: BattleUnitState) -> int:
	if attacker == null or target == null:
		return 9999
	return absi(attacker.grid_cell.x - target.grid_cell.x) + absi(attacker.grid_cell.y - target.grid_cell.y)


func _build_path(came_from: Dictionary, start_cell: Vector2i, target_cell: Vector2i) -> Array[Vector2i]:
	var path: Array[Vector2i] = []
	var cursor := target_cell
	while cursor != start_cell:
		path.push_front(cursor)
		cursor = came_from[cursor]
	path.push_front(start_cell)
	return path
