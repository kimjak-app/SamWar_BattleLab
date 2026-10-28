extends RefCounted
# T1: the "engine alone" reference of the 3D equivalence tests gets the blocked cells the 3D engine lab hands its
# engine, through the same API (the engine grid's set_blocked_cells) and from the same source (the play area's forest
# cells in the lab board's terrain types, as the lab's forest_cells()), right after the engine reaches its first ally
# turn. Expectations, tolerances and what each test compares stay as they were.
const Board = preload("res://scripts/battle3d/lab_heightfield.gd")

static func forest_cells() -> Array:
	var board = Board.new()
	preload("res://tests/scripts/support/battle3d_test_world.gd").freeze(board) # T2 split: the same test world as the harness labs
	var cells := []
	for y in range(board.PLAY_SIZE.y):
		for x in range(board.PLAY_SIZE.x):
			if board.terrain(Vector2i(x, y)) == "forest": cells.append(Vector2i(x, y))
	return cells

static func apply(battle: Node) -> void:
	battle.get("battle_grid_controller").set_blocked_cells(forest_cells())
