extends SceneTree
# T2: two 6-cell forest groves and 32 pines. For each grove combination of the report (C1 = terrain_types.json read as
# it is, C2 and C3 written over it by tests/scripts/support/battle3d_t2_groves.gd) on a board built with the default
# settings, the grove being the board's own play-area forest cells:
#   - the cells the lab would hand the engine (the play area's forest cells, as the lab reads them) = the combination's
#     12 cells, and an engine grid given them blocks 12;
#   - 32 trees (16 a grove, 2-3 a cell), triangles <= 16,000 in all (counted from the mesh's own arrays);
#   - every tree stands on a grove cell of the play area (none off the board or on river/ford); its crown (the radius of
#     the mesh's own vertices around its axis x the tree's scale) reaches at most 0.5 m into any non-grove cell; trees of
#     one cell are >= 1.2 m apart; a second build gives the same trees;
#   - every start and reinforcement arrival cell of the default battle (read from the engine) is >= 2 cells from the
#     grove (not on it, not beside it).
const Board = preload("res://scripts/battle3d/lab_heightfield.gd")
const Builder = preload("res://scripts/battle3d/terrain_board_builder.gd")
const Host := preload("res://scripts/battle3d/battle3d_engine_host.gd")
const Groves = preload("res://tests/scripts/support/battle3d_t2_groves.gd")
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
	if combo != "C1": Groves.apply(board, combo) # C1 is the file itself
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

func run() -> void:
	var units := await unit_cells()
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
		summary[combo] = {"trees":ts.size(), "tris":per_tree * b.count, "worst_overhang":snappedf(worst, 0.001), "per_cell":counts}
	print("[T2_FOREST_GROVES] %s: %d checks, %d failures; %s" % ["PASS" if failures == 0 else "FAIL", checks, failures, summary])
	quit(0 if failures == 0 else 1)
