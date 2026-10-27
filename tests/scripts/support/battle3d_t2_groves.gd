extends RefCounted
# T2: the three grove combinations (two 6-cell groves each) compared in the report. C1 is the default written in
# terrain_types.json; C2 and C3 exist only here, for the tests and captures. apply() rewrites a board's play-area cells in
# memory (every play-area forest cell -> plain, the combination's cells -> forest); the builder and the lab read the same
# array (board.terrain_cells is board.terrain_data.cells).
const COMBOS := {
	"C1": [Rect2i(0, 3, 2, 3), Rect2i(16, 6, 2, 3)],
	"C2": [Rect2i(0, 4, 3, 2), Rect2i(16, 5, 2, 3)],
	"C3": [Rect2i(1, 4, 3, 2), Rect2i(15, 5, 3, 2)],
}

static func cells(combo: String) -> Array:
	var out := []
	for r in COMBOS[combo]:
		for y in range(r.position.y, r.end.y):
			for x in range(r.position.x, r.end.x):
				out.append(Vector2i(x, y))
	return out

static func apply(board, combo: String) -> void:
	var grove := cells(combo)
	for y in range(board.PLAY_SIZE.y):
		for x in range(board.PLAY_SIZE.x):
			if board.terrain_cells[y][x] == "forest": board.terrain_cells[y][x] = "plain"
	for c in grove:
		board.terrain_cells[c.y][c.x] = "forest"
