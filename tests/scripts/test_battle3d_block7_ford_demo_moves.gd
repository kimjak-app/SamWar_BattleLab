extends SceneTree
# Block 7 test 7: the river and the ford on the new board, through the demo port (lab_demo_port.gd), which reads
# board.valid() and board.terrain(). The ford cells of row 5 (read from terrain_types.json directly) can be entered and
# a route across the river at row 5 goes through one; no river cell is ever entered. The four demo units (3,5), (4,2),
# (14,6), (15,2) reach exactly the cells they reached on the old branch: tests/data/block7_old_demo_reach_0dd9239.json,
# dumped from 0dd9239 by running its own lab_demo_port.gd path_to on its own board over the 18x10 play area.
const Board = preload("res://scripts/battle3d/lab_heightfield.gd")
const Port = preload("res://scripts/battle3d/lab_demo_port.gd")
const FIXTURE := "res://tests/data/block7_old_demo_reach_0dd9239.json"
const FORD_ROW := 5
var checks := 0
var failures := 0

func _initialize() -> void:
	run.call_deferred()

func expect(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", label)

func reachable(port, u: Dictionary) -> Array:
	var cells := []
	for y in range(10):
		for x in range(18):
			var c := Vector2i(x, y)
			if c != u.grid_cell and not port.path_to(u.unit_id, c).is_empty(): cells.append([x, y])
	return cells

func run() -> void:
	var board = Board.new()
	var port = Port.new()
	port.board = board
	var types: Array = JSON.parse_string(FileAccess.get_file_as_string("res://assets/battle3d/terrain_types.json")).cells
	var fords := []
	var rivers := []
	for y in range(10):
		for x in range(18):
			if types[y][x] == "ford": fords.append(Vector2i(x, y))
			if types[y][x] == "river": rivers.append(Vector2i(x, y))
	expect(not fords.is_empty() and fords.all(func(c): return c.y == FORD_ROW), "the play area's ford cells are on row 5 (%s)" % str(fords))
	expect(not rivers.is_empty() and rivers.all(func(c): return c.y != FORD_ROW), "river cells exist and none is on row 5 (%d)" % rivers.size())
	expect(fords.all(func(c): return board.terrain(c) == "ford") and rivers.all(func(c): return board.terrain(c) == "river"), "board.terrain() agrees with the JSON for ford and river cells")
	var ally = port.by_id("lab_ally_01")
	expect(ally.grid_cell == Vector2i(3, FORD_ROW), "the ally at (3,5) stands on the ford row")
	for f in fords:
		var route: Array = port.path_to(ally.unit_id, f)
		expect(not route.is_empty() and route[-1] == f, "ford %s can be entered (route %s)" % [f, route])
	# Across: the first non-river cell east of the river on row 5.
	var east := Vector2i(-1, -1)
	for x in range(fords.map(func(c): return c.x).max() + 1, 18):
		if types[FORD_ROW][x] != "river":
			east = Vector2i(x, FORD_ROW)
			break
	var crossing: Array = port.path_to(ally.unit_id, east)
	expect(east.x >= 0 and not crossing.is_empty() and crossing.any(func(c): return c in fords), "a route across the river to %s goes through the ford (%s)" % [east, crossing])
	for u in port.units:
		var entered := rivers.filter(func(c): return not port.path_to(u.unit_id, c).is_empty())
		expect(entered.is_empty(), "%s never enters a river cell (entered %s)" % [u.unit_id, entered])
		var through := []
		for y in range(10):
			for x in range(18):
				for c in port.path_to(u.unit_id, Vector2i(x, y)):
					if c in rivers: through.append(c)
		expect(through.is_empty(), "%s: no route crosses a river cell (%s)" % [u.unit_id, through.slice(0, 5)])
	var old: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(FIXTURE))
	expect(old.demo_reachable.size() == 4, "the fixture has the four demo units")
	for u in port.units:
		var key := "%d,%d" % [u.grid_cell.x, u.grid_cell.y]
		var want: Array = old.demo_reachable.get(key, {}).get("reachable", [])
		var got := reachable(port, u)
		var want_set := want.map(func(p): return Vector2i(int(p[0]), int(p[1])))
		var got_set := got.map(func(p): return Vector2i(p[0], p[1]))
		expect(old.demo_reachable.has(key) and old.demo_reachable[key].unit_id == u.unit_id and not want_set.is_empty(), "fixture entry for %s at %s" % [u.unit_id, key])
		expect(want_set == got_set, "%s at %s reaches the same %d cells as 0dd9239 (got %d; missing %s, extra %s)" % [u.unit_id, key, want_set.size(), got_set.size(),
			want_set.filter(func(c): return not c in got_set), got_set.filter(func(c): return not c in want_set)])
	print("[BLOCK7_FORD_DEMO] %s: %d checks, %d failures; fords %s, river cells %d" % ["PASS" if failures == 0 else "FAIL", checks, failures, fords, rivers.size()])
	quit(0 if failures == 0 else 1)
