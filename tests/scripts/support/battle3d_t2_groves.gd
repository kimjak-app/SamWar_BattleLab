extends RefCounted
# T2: the grove combinations (two 6-cell groves each) compared in the report. C4b is the default written in
# terrain_types.json (10-28 보정); C1 (the first default) and C4 exist only here, for the tests and captures. apply()
# rewrites a board's play-area cells in memory (every play-area forest cell -> the kind its height gives, hill above
# 1.5 m else plain, as lab_heightfield.gd terrain() does; the combination's cells -> forest); the builder and the lab
# read the same array (board.terrain_cells is board.terrain_data.cells).
const DEFAULT := "C4b"
const COMBOS := {
	"C4b": [Rect2i(4, 1, 3, 2), Rect2i(11, 7, 3, 2)],
	"C4": [Rect2i(2, 1, 3, 2), Rect2i(13, 7, 3, 2)],
	"C1": [Rect2i(0, 3, 2, 3), Rect2i(16, 6, 2, 3)],
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
			if board.terrain_cells[y][x] == "forest": board.terrain_cells[y][x] = "hill" if board.world(Vector2i(x, y)).y > 1.5 else "plain"
	for c in grove:
		board.terrain_cells[c.y][c.x] = "forest"
