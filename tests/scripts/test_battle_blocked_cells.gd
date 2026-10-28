extends SceneTree
# T1 test 1: the movement service with the grid's blocked cells, against this test's own breadth-first search (the same
# four directions in the same order, written here, not taken from the service). On an 18 x 10 grid:
#   1. no blocked cell (the default, and after set_blocked_cells([])): for several starts, ranges and blockers the
#      reachable cells AND every path are exactly the test's search without blocked cells (the old behaviour);
#   2. the 12 forest cells of the play area (T2's two groves; read here from terrain_types.json) blocked: the reachable cells and paths
#      are the test's search with those cells removed; no path steps on a blocked cell; a blocked target gives no path;
#   3. a wall (x = 5, y 0-7 blocked): the path round its end is exactly the test's shortest detour (16 steps, not 4);
#   4. a unit standing on a blocked cell beside the plain can leave it; it cannot step onto the next blocked cell.
const MovementQueryServiceScript := preload("res://scripts/battle/services/battle_movement_query_service.gd")
const DIRS: Array[Vector2i] = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
const W := 18
const H := 10
var checks := 0
var failures := 0
var service := MovementQueryServiceScript.new()

func _initialize() -> void:
	run.call_deferred()

func expect(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", label)

func unit(cell: Vector2i, move_range: int) -> BattleUnitState:
	var u := BattleUnitState.new()
	u.grid_cell = cell
	u.move_range = move_range
	u.current_hp = 100
	u.max_hp = 100
	u.current_troops = 100
	u.max_troops = 100
	return u

func search(start: Vector2i, steps: int, blocked: Dictionary, occupied: Array) -> Dictionary:
	# Breadth-first, first visit wins, DIRS order: cell -> path (start included), occupied and blocked cells never
	# entered (the start always counts as walkable).
	var came := {start: start}
	var depth := {start: 0}
	var frontier: Array[Vector2i] = [start]
	while not frontier.is_empty():
		var cur: Vector2i = frontier.pop_front()
		if depth[cur] >= steps: continue
		for d in DIRS:
			var n: Vector2i = cur + d
			if came.has(n) or n.x < 0 or n.y < 0 or n.x >= W or n.y >= H or blocked.has(n) or occupied.has(n): continue
			came[n] = cur
			depth[n] = depth[cur] + 1
			frontier.append(n)
	var out := {}
	for cell in came:
		var path: Array[Vector2i] = []
		var c: Vector2i = cell
		while c != start:
			path.push_front(c)
			c = came[c]
		path.push_front(start)
		out[cell] = path
	return out

func forest_cells() -> Array:
	var cells: Array = JSON.parse_string(FileAccess.get_file_as_string("res://assets/battle3d/terrain_types.json")).cells
	var out := []
	for y in range(H):
		for x in range(W):
			if cells[y][x] == "forest": out.append(Vector2i(x, y))
	return out

func compare(grid: BattleGridController, start: Vector2i, steps: int, blocked: Dictionary, others: Array) -> Array:
	# Differences between the service and the test's search (reachable cells and each path).
	var mover := unit(start, steps)
	var units: Array[BattleUnitState] = [mover]
	for cell in others: units.append(unit(cell, 1))
	var got: Dictionary = service.get_reachable_paths(start, mover, steps, grid, units, false)
	var want := search(start, steps, blocked, others)
	var diffs := []
	if got.keys().size() != want.keys().size() or not want.keys().all(func(k): return got.has(k)): diffs.append(["cells", start, steps, got.size(), want.size()])
	for cell in want:
		if got.has(cell) and got[cell] != want[cell]: diffs.append(["path", start, cell, got[cell], want[cell]])
		if cell != start:
			var path: Array = service.find_move_path(start, cell, mover, steps, grid, units, false)
			if path != want[cell]: diffs.append(["find_move_path", start, cell, path, want[cell]])
	return diffs

func run() -> void:
	var grid := BattleGridController.new()
	grid.grid_width = W
	grid.grid_height = H
	var cases := [[Vector2i(3, 8), 3, []], [Vector2i(3, 5), 4, [Vector2i(2, 4)]], [Vector2i(13, 1), 4, [Vector2i(13, 2)]], [Vector2i(8, 5), 5, [Vector2i(9, 5), Vector2i(8, 6)]], [Vector2i(16, 4), 3, []]]
	# 1. No blocked cell: the default and an explicit empty list.
	var diffs := []
	for c in cases: diffs += compare(grid, c[0], c[1], {}, c[2])
	grid.set_blocked_cells([])
	for c in cases: diffs += compare(grid, c[0], c[1], {}, c[2])
	expect(grid.blocked_cells.is_empty() and diffs.is_empty(), "no blocked cell: reachable cells and every path = the search without blocked cells (%d cases x 2; wrong %s)" % [cases.size(), str(diffs.slice(0, 3))])
	# 2. The forest blocked.
	var forest := forest_cells()
	var blocked := {}
	for cell in forest: blocked[cell] = true
	grid.set_blocked_cells(forest)
	diffs = []
	var stepped := []
	var into := []
	for c in cases:
		diffs += compare(grid, c[0], c[1], blocked, c[2])
		var mover := unit(c[0], c[1])
		var units: Array[BattleUnitState] = [mover]
		var got: Dictionary = service.get_reachable_paths(c[0], mover, c[1], grid, units, false)
		for cell in got:
			for step in got[cell].slice(1): if blocked.has(step): stepped.append([c[0], cell, step])
		for cell in forest:
			if absi(cell.x - c[0].x) + absi(cell.y - c[0].y) <= c[1]:
				if not service.find_move_path(c[0], cell, mover, c[1], grid, units, false).is_empty(): into.append([c[0], cell])
	expect(forest.size() == 12 and diffs.is_empty(), "12 forest cells blocked: reachable cells and paths = the search without them (wrong %s)" % str(diffs.slice(0, 3)))
	expect(stepped.is_empty() and into.is_empty(), "no path steps on a forest cell (%s); no path ends on one (%s)" % [str(stepped.slice(0, 3)), str(into.slice(0, 3))])
	# Control: the same starts without the block reach forest cells.
	grid.set_blocked_cells([])
	var reach_forest := 0
	for c in cases:
		var mover := unit(c[0], c[1])
		var units: Array[BattleUnitState] = [mover]
		for cell in service.get_reachable_paths(c[0], mover, c[1], grid, units, false): if blocked.has(cell): reach_forest += 1
	expect(reach_forest > 0, "control: without the block the same starts reach %d forest cells" % reach_forest)
	# 3. A wall: the detour round its end.
	var wall := []
	for y in range(8): wall.append(Vector2i(5, y))
	var wall_set := {}
	for cell in wall: wall_set[cell] = true
	grid.set_blocked_cells(wall)
	var walker := unit(Vector2i(3, 2), 16)
	var only: Array[BattleUnitState] = [walker]
	var detour: Array = service.find_move_path(Vector2i(3, 2), Vector2i(7, 2), walker, 16, grid, only, false)
	var want: Array = search(Vector2i(3, 2), 16, wall_set, [])[Vector2i(7, 2)]
	expect(detour == want and detour.size() - 1 == 16 and not detour.any(func(c): return wall_set.has(c)), "wall x=5 y0-7: the path (3,2) -> (7,2) goes round its end, %d steps = the search's %s" % [detour.size() - 1, str(want)])
	expect(service.find_move_path(Vector2i(3, 2), Vector2i(7, 2), walker, 15, grid, only, false).is_empty(), "wall: 15 steps are not enough")
	# 4. Standing on a blocked cell: leaving is allowed.
	grid.set_blocked_cells(forest)
	var sitter := unit(Vector2i(4, 2), 3)
	var alone: Array[BattleUnitState] = [sitter]
	var leave: Dictionary = service.get_reachable_paths(Vector2i(4, 2), sitter, 3, grid, alone, false)
	var want_leave := search(Vector2i(4, 2), 3, blocked, [])
	expect(service.is_cell_walkable(Vector2i(4, 2), Vector2i(4, 2), sitter, grid, alone, false) and leave.has(Vector2i(4, 4)) and leave.keys().size() == want_leave.keys().size()
		and service.find_move_path(Vector2i(4, 2), Vector2i(4, 4), sitter, 3, grid, alone, false) == want_leave[Vector2i(4, 4)],
		"a unit on forest (4,2), beside the plain, can leave: %d cells reachable (search %d), path to (4,4) %s" % [leave.size(), want_leave.size(), str(want_leave.get(Vector2i(4, 4)))])
	expect(not service.is_cell_walkable(Vector2i(5, 2), Vector2i(4, 2), sitter, grid, alone, false), "but it cannot step onto the next forest cell (5,2)")
	grid.free()
	print("[T1_BLOCKED_CELLS] %s: %d checks, %d failures; forest %d" % ["PASS" if failures == 0 else "FAIL", checks, failures, forest.size()])
	quit(0 if failures == 0 else 1)
