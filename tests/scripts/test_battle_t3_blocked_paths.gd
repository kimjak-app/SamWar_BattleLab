extends SceneTree
# T3 test 1: the three paths outside the move search refuse a blocked cell, on the engine alone (the 3D lab's host).
# The C4b groves of terrain_types.json (read here) are handed to the engine's grid, as the 3D lab does:
#   1. advance: Yi at (7,2) toward a defeated unit at (5,2): the step cell (6,2) is forest, so Yi stays at (7,2);
#      control: toward (9,2) Yi steps to (8,2);
#      forest, stays; control: Guan Yu at (10,5) by 1 -> (11,5);
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
	# 1-3: the groves blocked.
	grid.set_blocked_cells(forest)
	var c := advance(Vector2i(7, 2), Vector2i(5, 2))
	expect(c == Vector2i(7, 2), "advance toward (5,2): (6,2) is forest, Yi stays at (7,2) (at %s)" % c)
	c = advance(Vector2i(7, 2), Vector2i(9, 2))
	expect(c == Vector2i(8, 2), "control: advance toward (9,2) steps to (8,2) (at %s)" % c)
	grid.set_blocked_cells([])
	quit(0 if failures == 0 else 1)
