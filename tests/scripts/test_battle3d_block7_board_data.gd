extends SceneTree
# Block 7 test 4: the board's data. Read straight from the delivered JSON files (not through the code under test), then
# compared with lab_heightfield.gd and terrain_board_builder.gd: a cell is 3.0 m, the board is 20x20 cells = 60 m, the
# height grid is 121x121 at 0.5 m, and every terrain type string is one of plain/forest/hill/river/ford/mountain/fort.
const Board = preload("res://scripts/battle3d/lab_heightfield.gd")
const Builder = preload("res://scripts/battle3d/terrain_board_builder.gd")
const TYPES := ["plain", "forest", "hill", "river", "ford", "mountain", "fort"]
var checks := 0
var failures := 0

func _initialize() -> void:
	run.call_deferred()

func expect(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", label)

func run() -> void:
	var height_json: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/battle3d/heightfield.json"))
	var types_json: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/battle3d/terrain_types.json"))
	var b: Dictionary = height_json.board
	expect(float(b.cell_size) == 3.0, "heightfield.json cell_size 3.0 (got %s)" % b.cell_size)
	expect(int(b.width) == 20 and int(b.height) == 20, "heightfield.json board 20x20 (got %sx%s)" % [b.width, b.height])
	expect(float(b.width) * float(b.cell_size) == 60.0 and float(b.height) * float(b.cell_size) == 60.0, "the board is 60 m x 60 m")
	expect(float(height_json.step) == 0.5, "height step 0.5 m (got %s)" % height_json.step)
	expect(int(height_json.nx) == 121 and int(height_json.nz) == 121, "nx, nz = 121, 121 (got %s, %s)" % [height_json.nx, height_json.nz])
	var rows: Array = height_json.heights
	expect(rows.size() == 121 and rows.all(func(r): return (r as Array).size() == 121), "heights: 121 rows of 121 (rows %d)" % rows.size())
	expect(rows.all(func(r): return (r as Array).all(func(v): return typeof(v) in [TYPE_FLOAT, TYPE_INT] and is_finite(float(v)))), "every height is a finite number")
	var cells: Array = types_json.cells
	expect(cells.size() == 20 and cells.all(func(r): return (r as Array).size() == 20), "terrain_types.json cells: 20 rows of 20")
	var strange := {}
	var counts := {}
	for row in cells:
		for t in row:
			counts[t] = counts.get(t, 0) + 1
			if not (typeof(t) == TYPE_STRING and t in TYPES): strange[t] = true
	expect(strange.is_empty(), "terrain type strings only from %s (others %s)" % [TYPES, strange.keys()])
	# The code reads the same numbers.
	var board = Board.new()
	expect(board.CELL == 3.0 and board.SIZE == Vector2i(20, 20), "lab_heightfield: CELL %s, SIZE %s" % [board.CELL, board.SIZE])
	expect(board.PLAY_SIZE == Vector2i(18, 10), "lab_heightfield: PLAY_SIZE 18x10 (the engine grid) (got %s)" % board.PLAY_SIZE)
	var board_types := {}
	var mismatches := {}
	for y in range(board.SIZE.y):
		for x in range(board.SIZE.x):
			var t: String = board.terrain(Vector2i(x, y))
			board_types[t] = true
			if t != cells[y][x]: mismatches[Vector2i(x, y)] = t
	expect(mismatches.is_empty() and board_types.keys().all(func(t): return t in TYPES), "board.terrain() returns the JSON type for all 400 board cells (mismatches %s)" % str(mismatches))
	expect(Builder.TILE_SIZE == board.CELL and Builder.GRID_W == board.SIZE.x and Builder.GRID_H == board.SIZE.y and Builder.TILE_SIZE / Builder.SUBDIV == float(height_json.step),
		"builder TILE_SIZE %s, GRID %dx%d, step %s match the data" % [Builder.TILE_SIZE, Builder.GRID_W, Builder.GRID_H, Builder.TILE_SIZE / Builder.SUBDIV])
	print("[BLOCK7_BOARD_DATA] %s: %d checks, %d failures; types %s" % ["PASS" if failures == 0 else "FAIL", checks, failures, counts])
	quit(0 if failures == 0 else 1)
