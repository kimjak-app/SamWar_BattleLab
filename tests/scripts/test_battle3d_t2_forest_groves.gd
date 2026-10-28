extends SceneTree
# T2: two 6-cell forest groves and 32 pines. For each grove combination of the report (C4b, the default, =
# terrain_types.json read as it is; C1 and C4 written over it by tests/scripts/support/battle3d_t2_groves.gd) on a board
# built with the default settings, the grove being the board's own play-area forest cells:
#   - the cells the lab would hand the engine (the play area's forest cells, as the lab reads them) = the combination's
#     12 cells, and an engine grid given them blocks 12;
#   - 32 trees (16 a grove, 2-3 a cell), triangles <= 16,000 in all (counted from the mesh's own arrays);
#   - every tree stands on a grove cell of the play area (none off the board or on river/ford); its crown (the radius of
#     the mesh's own vertices around its axis x the tree's scale) reaches at most 0.5 m into any non-grove cell; trees of
#     one cell are >= 1.2 m apart; a second build gives the same trees;
#   - every start and reinforcement arrival cell of the default battle (read from the engine) is >= 2 cells from the
#     grove (not on it, not beside it); no grove cell is a cell the scenario harnesses fix for far units ((0..3,9),
#     (14..17,0));
#   - the default (C4b): no grove cell on the play area's edge (row 0 or 9, column 0 or 17);
#   - T2 split, every combination: no grove cell was river or ford (the 0dd9239 play-area types, tests/data); with the
#     grove blocked, a 4-way search from the first ally's start reaches every other play cell (no cell cut off); and the
#     engine's own move search (BattleMovementQueryService.find_move_path, the grove handed through set_blocked_cells)
#     finds the two main engagement routes (이순신's start -> 관우's, 관우's -> 이순신's) with exactly the search's step count,
#     on no grove cell.
const Board = preload("res://scripts/battle3d/lab_heightfield.gd")
const Builder = preload("res://scripts/battle3d/terrain_board_builder.gd")
const Host := preload("res://scripts/battle3d/battle3d_engine_host.gd")
const Groves = preload("res://tests/scripts/support/battle3d_t2_groves.gd")
const FIXED := [Rect2i(0, 9, 4, 1), Rect2i(14, 0, 4, 1)] # (0..3,9) and (14..17,0)
const OLD_TYPES := "res://tests/data/block7_old_play_area_0dd9239.json"
const TREES := 32
const TREES_MAX := 16000
const OVERHANG := 0.5
const SPACING := 1.2
var checks := 0
var failures := 0

func _initialize() -> void:
	run.call_deferred()

func expect(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", label)

func triangles(mesh: Mesh) -> int:
	var total := 0
	for s in range(mesh.get_surface_count()):
		var arrays := mesh.surface_get_arrays(s)
		var indices = arrays[Mesh.ARRAY_INDEX]
		total += (indices.size() if indices != null and indices.size() > 0 else (arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array).size()) / 3
	return total

func crown(mesh: Mesh) -> float:
	var r := 0.0
	for s in range(mesh.get_surface_count()):
		for v in (mesh.surface_get_arrays(s)[Mesh.ARRAY_VERTEX] as PackedVector3Array):
			r = maxf(r, Vector2(v.x, v.z).length())
	return r

func build(combo: String) -> Dictionary:
	var board = Board.new()
	if combo != Groves.DEFAULT: Groves.apply(board, combo) # the default is the file itself
	var field = Builder.new()
	field.play_cells = board.PLAY_SIZE
	field.setup_from_board(board)
	root.add_child(field)
	await process_frame
	var mm: MultiMesh = field.forest_multimesh.multimesh
	var out := {"board":board, "transforms":field.forest_tree_transforms.duplicate(), "count":mm.instance_count, "mesh":mm.mesh}
	field.queue_free()
	await process_frame
	return out

func lab_forest(board) -> Array:
	# As the lab reads them (battle3d_engine_play.gd forest_cells): play-area cells whose terrain is forest.
	var out := []
	for y in range(board.PLAY_SIZE.y):
		for x in range(board.PLAY_SIZE.x):
			if board.terrain(Vector2i(x, y)) == "forest": out.append(Vector2i(x, y))
	return out

func unit_cells() -> Array:
	var host := Host.new()
	root.add_child(host)
	await host.initialized
	await process_frame
	var out := []
	for u in host.battle.all_battle_unit_states: out.append([u.unit_id, u.grid_cell])
	var iso = host.battle.get("_iso_grid_controller")
	host.free()
	if is_instance_valid(iso) and iso.get_parent() == null: iso.free()
	await process_frame
	return out

func steps(from: Vector2i, blocked: Dictionary, size: Vector2i) -> Dictionary:
	# The test's own 4-way search: cell -> fewest steps from `from`, never entering a blocked cell.
	var dist := {from: 0}
	var queue := [from]
	while not queue.is_empty():
		var c: Vector2i = queue.pop_front()
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var n: Vector2i = c + d
			if n.x < 0 or n.y < 0 or n.x >= size.x or n.y >= size.y or blocked.has(n) or dist.has(n): continue
			dist[n] = dist[c] + 1
			queue.append(n)
	return dist

func engine_route(from: Vector2i, to: Vector2i, grove: Array, size: Vector2i) -> Array:
	var grid := BattleGridController.new()
	grid.grid_width = size.x
	grid.grid_height = size.y
	grid.set_blocked_cells(grove)
	var mover := BattleUnitState.new()
	mover.grid_cell = from
	mover.move_range = 99
	mover.current_hp = 100
	mover.max_hp = 100
	mover.current_troops = 100
	mover.max_troops = 100
	var alone: Array[BattleUnitState] = [mover]
	var path: Array = BattleMovementQueryService.new().find_move_path(from, to, mover, 99, grid, alone, false)
	grid.free()
	return path

func run() -> void:
	var units := await unit_cells()
	var old_types: Array = JSON.parse_string(FileAccess.get_file_as_string(OLD_TYPES)).types
	var summary := {}
	for combo in Groves.COMBOS:
		var b: Dictionary = await build(combo)
		var board = b.board
		var handed := lab_forest(board)
		var grove: Array = handed
		var in_grove := {}
		for c in grove: in_grove[c] = true
		var grid := BattleGridController.new()
		grid.grid_width = board.PLAY_SIZE.x
		grid.grid_height = board.PLAY_SIZE.y
		grid.set_blocked_cells(handed)
		expect(handed.size() == 12 and Groves.cells(combo).all(func(c): return handed.has(c)) and grid.blocked_cells.size() == 12, "%s: the lab hands the engine the 12 grove cells (handed %s, blocked %d)" % [combo, str(handed), grid.blocked_cells.size()])
		grid.free()
		var mesh: Mesh = b.mesh
		var per_tree := triangles(mesh)
		var radius := crown(mesh)
		var ts: Array = b.transforms
		expect(b.count == TREES and ts.size() == TREES and per_tree * b.count <= TREES_MAX, "%s: %d trees (MultiMesh %d) x %d triangles = %d <= %d" % [combo, ts.size(), b.count, per_tree, per_tree * b.count, TREES_MAX])
		var by_cell := {}
		var off := []
		var over := []
		var worst := 0.0
		for t in ts:
			var p := Vector2(t.origin.x, t.origin.z)
			var cell := Vector2i(floori(p.x / board.CELL), floori(p.y / board.CELL))
			var kind: String = board.terrain(cell)
			if not board.valid(cell) or not in_grove.has(cell) or kind == "river" or kind == "ford": off.append([cell, kind])
			by_cell[cell] = by_cell.get(cell, []) + [p]
			var r: float = radius * t.basis.get_scale().x
			for dy in range(-2, 3):
				for dx in range(-2, 3):
					var n := cell + Vector2i(dx, dy)
					if in_grove.has(n): continue
					var lo: Vector2 = Vector2(n) * board.CELL
					var d: float = p.distance_to(p.clamp(lo, lo + Vector2(board.CELL, board.CELL)))
					worst = maxf(worst, r - d)
					if r - d > OVERHANG + 0.0001: over.append([cell, n, snappedf(r - d, 0.001)])
		expect(off.is_empty(), "%s: every tree on a grove cell of the play area, none off the board or on river/ford (%s)" % [combo, str(off)])
		expect(over.is_empty(), "%s: no crown (radius %.3f m x scale) reaches more than %.1f m into a non-grove cell (worst %.3f m; %s)" % [combo, radius, OVERHANG, worst, str(over.slice(0, 4))])
		var counts := []
		var close := []
		for c in grove:
			var ps: Array = by_cell.get(c, [])
			counts.append(ps.size())
			for i in range(ps.size()):
				for j in range(i + 1, ps.size()):
					if ps[i].distance_to(ps[j]) < SPACING: close.append([c, snappedf(ps[i].distance_to(ps[j]), 0.001)])
		var left := 0
		for c in grove:
			if c.x <= 8: left += by_cell.get(c, []).size()
		expect(counts.all(func(n): return n >= 2 and n <= 3) and left == 16, "%s: 2-3 trees a cell %s, 16 a grove (left %d)" % [combo, str(counts), left])
		expect(close.is_empty(), "%s: trees of one cell >= %.1f m apart (%s)" % [combo, SPACING, str(close)])
		var again: Dictionary = await build(combo)
		expect(again.transforms == ts, "%s: a second build gives the same %d trees" % [combo, ts.size()])
		var near := []
		for u in units:
			for c in grove:
				if absi(u[1].x - c.x) + absi(u[1].y - c.y) < 2: near.append([u[0], u[1], c])
		expect(units.size() == 10 and near.is_empty(), "%s: the %d start/arrival cells are >= 2 cells from the grove (%s)" % [combo, units.size(), str(near)])
		var fixed := grove.filter(func(c): return FIXED.any(func(r): return r.has_point(c)))
		expect(fixed.is_empty(), "%s: no grove cell on the harnesses' fixed far-unit cells (0..3,9)/(14..17,0) (%s)" % [combo, str(fixed)])
		if combo == Groves.DEFAULT:
			var edge := grove.filter(func(c): return c.x == 0 or c.y == 0 or c.x == board.PLAY_SIZE.x - 1 or c.y == board.PLAY_SIZE.y - 1)
			expect(edge.is_empty(), "%s (default): no grove cell on the play area's edge (%s)" % [combo, str(edge)])
		var wet := grove.filter(func(c): return String(old_types[c.y][c.x]) in ["river", "ford"])
		expect(wet.is_empty(), "%s: no grove cell was river or ford (%s)" % [combo, str(wet)])
		var size: Vector2i = board.PLAY_SIZE
		var cell_of := {}
		for u in units: cell_of[u[0]] = u[1]
		var yi: Vector2i = cell_of.get("yi_sunsin", Vector2i(-1, -1))
		var guan: Vector2i = cell_of.get("guan_yu", Vector2i(-1, -1))
		var from_yi := steps(yi, in_grove, size)
		expect(from_yi.size() == size.x * size.y - grove.size(), "%s: from 이순신 %s the search reaches all %d other play cells (reached %d)" % [combo, yi, size.x * size.y - grove.size(), from_yi.size()])
		var routes := []
		for pair in [[yi, guan], [guan, yi]]:
			var path := engine_route(pair[0], pair[1], grove, size)
			var want: int = steps(pair[0], in_grove, size).get(pair[1], -1)
			routes.append([pair[0], pair[1], path.size() - 1, want])
			expect(want > 0 and path.size() - 1 == want and path.front() == pair[0] and path.back() == pair[1] and not path.any(func(c): return in_grove.has(c)),
				"%s: the engine's move search %s -> %s takes %d steps = the search's %d, on no grove cell" % [combo, pair[0], pair[1], path.size() - 1, want])
		summary[combo] = {"routes":routes, "trees":ts.size(), "tris":per_tree * b.count, "worst_overhang":snappedf(worst, 0.001), "per_cell":counts}
	print("[T2_FOREST_GROVES] %s: %d checks, %d failures; %s" % ["PASS" if failures == 0 else "FAIL", checks, failures, summary])
	quit(0 if failures == 0 else 1)
