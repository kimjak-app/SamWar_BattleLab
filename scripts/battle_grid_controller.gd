class_name BattleGridController
extends Node

@export var grid_width: int = 14
@export var grid_height: int = 8
@export var board_top_left_marker_path: NodePath
@export var board_bottom_right_marker_path: NodePath

@onready var board_top_left_marker: Marker2D = get_node_or_null(board_top_left_marker_path) as Marker2D
@onready var board_bottom_right_marker: Marker2D = get_node_or_null(board_bottom_right_marker_path) as Marker2D


func get_board_top_left() -> Vector2:
	if board_top_left_marker == null:
		return Vector2.ZERO
	return board_top_left_marker.global_position


func get_board_bottom_right() -> Vector2:
	if board_bottom_right_marker == null:
		return Vector2.ZERO
	return board_bottom_right_marker.global_position


func get_cell_size() -> Vector2:
	var board_size := get_board_bottom_right() - get_board_top_left()
	return Vector2(
		board_size.x / max(1, grid_width),
		board_size.y / max(1, grid_height)
	)


func is_in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < grid_width and cell.y >= 0 and cell.y < grid_height


func grid_to_world(cell: Vector2i) -> Vector2:
	var cell_size := get_cell_size()
	return get_board_top_left() + Vector2(
		(float(cell.x) + 0.5) * cell_size.x,
		(float(cell.y) + 0.5) * cell_size.y
	)


func world_to_grid(world_pos: Vector2) -> Vector2i:
	var cell_size := get_cell_size()
	if is_zero_approx(cell_size.x) or is_zero_approx(cell_size.y):
		return Vector2i.ZERO

	var local_pos := world_pos - get_board_top_left()
	return Vector2i(
		floori(local_pos.x / cell_size.x),
		floori(local_pos.y / cell_size.y)
	)


func get_distance(a: Vector2i, b: Vector2i) -> int:
	return absi(a.x - b.x) + absi(a.y - b.y)


func get_tiles_in_range(center: Vector2i, tile_range: int) -> Array[Vector2i]:
	var tiles: Array[Vector2i] = []
	for x in range(grid_width):
		for y in range(grid_height):
			var candidate := Vector2i(x, y)
			if get_distance(center, candidate) <= tile_range:
				tiles.append(candidate)
	return tiles


func describe_grid() -> String:
	return "BattleGridController %dx%d top_left=%s bottom_right=%s cell_size=%s" % [
		grid_width,
		grid_height,
		get_board_top_left(),
		get_board_bottom_right(),
		get_cell_size(),
	]
