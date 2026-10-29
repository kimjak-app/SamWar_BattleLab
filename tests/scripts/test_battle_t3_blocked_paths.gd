extends SceneTree
# T3 test 1: the three paths outside the move search refuse a blocked cell, on the engine alone (the 3D lab's host).
# The C4b groves of terrain_types.json (read here) are handed to the engine's grid, as the 3D lab does:
#   1. advance: Yi at (7,2) toward a defeated unit at (5,2): the step cell (6,2) is forest, so Yi stays at (7,2);
#      control: toward (9,2) Yi steps to (8,2);
#   2. retreat: Yi (ally, west) at (8,1) by 2 -> (6,1) forest, stays; Guan Yu (enemy, east) at (10,7) by 1 -> (11,7)
#      forest, stays; control: Guan Yu at (10,5) by 1 -> (11,5);
#   3. redeploy candidates from (5,3), range 3: the 24 cells of the empty list minus the 6 forest cells (18);
#      no candidate left (Yi at (3,1), range 1: (4,1) forest, (2,1) (3,0) (3,2) occupied): an empty list, Yi stays;
#   4. the empty list (set_blocked_cells([])): the same calls enter the forest cells as before T3 ((6,2), (6,1), (11,7),
#      24 candidates with the 6 forest cells).
const Host := preload("res://scripts/battle3d/battle3d_engine_host.gd")
var checks := 0
var failures := 0
var battle: Node
var grid

func _initialize() -> void:
	run.call_deferred()

func expect(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", label)

func forest_cells() -> Array:
	var cells: Array = JSON.parse_string(FileAccess.get_file_as_string("res://assets/battle3d/terrain_types.json")).cells
	var out := []
	for y in range(10):
		for x in range(18):
			if cells[y][x] == "forest": out.append(Vector2i(x, y))
	return out

func unit(id: String):
	for u in battle.all_battle_unit_states:
		if u.unit_id == id: return u

func park() -> void:
	# Every unit off the rows the cases use (row 9, x 0-9), so only the case's units stand near them.
	var x := 0
	for u in battle.all_battle_unit_states:
		u.set_grid_cell(Vector2i(x, 9))
		x += 1

func advance(from: Vector2i, toward: Vector2i) -> Vector2i:
	park()
	var yi = unit("yi_sunsin")
	var guan = unit("guan_yu")
	yi.set_grid_cell(from)
	guan.set_grid_cell(toward)
	battle.call("_apply_resolver_advance_toward_target", yi, guan)
	return yi.grid_cell

func retreat(id: String, from: Vector2i, distance: int) -> Vector2i:
	park()
	var u = unit(id)
	u.set_grid_cell(from)
	battle.call("_apply_resolver_retreat_move", u, distance)
	return u.grid_cell

func redeploy(from: Vector2i, reach: int, others: Array = []) -> Array:
	park()
	var yi = unit("yi_sunsin")
	yi.set_grid_cell(from)
	var ids := ["guan_yu", "zhang_fei", "xiahou_dun"]
	for i in range(others.size()):
		unit(ids[i]).set_grid_cell(others[i])
	var cand: Array = battle.call("_get_post_skill_reposition_valid_cells", yi, reach)
	expect(yi.grid_cell == from, "redeploy candidates leave Yi at %s (at %s)" % [from, yi.grid_cell])
	return cand

func run() -> void:
	var host := Host.new()
	root.add_child(host)
	await host.initialized
	await process_frame
	battle = host.battle
	grid = battle.get("battle_grid_controller")
	var forest := forest_cells()
	expect(forest.size() == 12, "terrain_types.json holds the 12 grove cells (%d)" % forest.size())
	# 4 first: the empty list, the behaviour before T3.
	grid.set_blocked_cells([])
	expect(advance(Vector2i(7, 2), Vector2i(5, 2)) == Vector2i(6, 2), "empty list: advance enters (6,2)")
	expect(retreat("yi_sunsin", Vector2i(8, 1), 2) == Vector2i(6, 1), "empty list: ally retreat enters (6,1)")
	expect(retreat("guan_yu", Vector2i(10, 7), 1) == Vector2i(11, 7), "empty list: enemy retreat enters (11,7)")
	var open: Array = redeploy(Vector2i(5, 3), 3)
	var open_forest: Array = open.filter(func(c): return forest.has(c))
	expect(open.size() == 24 and open_forest.size() == 6, "empty list: 24 redeploy candidates, 6 of them forest (%d, %s)" % [open.size(), str(open_forest)])
	# 1-3: the groves blocked.
	grid.set_blocked_cells(forest)
	var c := advance(Vector2i(7, 2), Vector2i(5, 2))
	expect(c == Vector2i(7, 2), "advance toward (5,2): (6,2) is forest, Yi stays at (7,2) (at %s)" % c)
	c = advance(Vector2i(7, 2), Vector2i(9, 2))
	expect(c == Vector2i(8, 2), "control: advance toward (9,2) steps to (8,2) (at %s)" % c)
	c = retreat("yi_sunsin", Vector2i(8, 1), 2)
	expect(c == Vector2i(8, 1), "ally retreat (8,1) by 2: (6,1) is forest, Yi stays (at %s)" % c)
	c = retreat("guan_yu", Vector2i(10, 7), 1)
	expect(c == Vector2i(10, 7), "enemy retreat (10,7) by 1: (11,7) is forest, Guan Yu stays (at %s)" % c)
	c = retreat("guan_yu", Vector2i(10, 5), 1)
	expect(c == Vector2i(11, 5), "control: enemy retreat (10,5) by 1 -> (11,5) (at %s)" % c)
	var cand: Array = redeploy(Vector2i(5, 3), 3)
	var want: Array = open.filter(func(x): return not forest.has(x))
	expect(cand == want and cand.size() == 18, "redeploy from (5,3) range 3: the 24 minus the 6 forest cells, in order (%d: %s)" % [cand.size(), str(cand)])
	expect(cand.all(func(x): return not grid.is_blocked(x)), "no redeploy candidate is blocked")
	var none: Array = redeploy(Vector2i(3, 1), 1, [Vector2i(2, 1), Vector2i(3, 0), Vector2i(3, 2)])
	expect(none.is_empty(), "redeploy from (3,1) range 1: (4,1) forest, the rest occupied: no candidate (%s)" % str(none))
	grid.set_blocked_cells([])
	print("[T3_BLOCKED_PATHS] checks=", checks, " failures=", failures, " forest ", forest, " redeploy ", cand.size(), "/", open.size())
	quit(0 if failures == 0 else 1)
