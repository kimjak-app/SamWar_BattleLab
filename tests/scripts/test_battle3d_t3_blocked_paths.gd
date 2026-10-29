extends SceneTree
# T3 test 2: the 3D engine lab on the presentation default (C4b groves, the lab hands them to the engine), scenario shell
# (default battle, test_world = false). The G cases of the T2 split report, on the lab's engine:
#   - after the lab syncs its views, each unit's view stands on its engine cell (no view in the forest);
#   - reinforcement arrival (record only, no code change): the four reinforcement marker cells are not blocked.
var h

func _initialize() -> void:
	run.call_deferred()

func unit(b: Node, id: String):
	for u in b.all_battle_unit_states:
		if u.unit_id == id: return u

func park(b: Node) -> void:
	var x := 0
	for u in b.all_battle_unit_states:
		u.set_grid_cell(Vector2i(x, 9))
		x += 1

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_scenario_harness.gd").new()
	h.test_world = false # T3: the presentation default (terrain_types.json's C4b groves)
	await h.open_shell(self)
	root.size = Vector2i(1920, 1080)
	await h.press_scenario(self, "default")
	var lab = h.lab
	var b: Node = lab.engine
	for i in range(60): await process_frame
	var grid = b.get("battle_grid_controller")
	var forest: Array = grid.blocked_cells.keys()
	h.expect(forest.size() == 12 and forest.all(func(c): return lab.board.terrain(c) == "forest"), "the lab handed the engine the 12 grove cells (%s)" % str(forest))
	# Reinforcement arrival, recorded before any unit is moved: the marker cells.
	var arrivals := []
	for u in b.all_battle_unit_states:
		if not u.unit_id.contains("reinforce"): continue
		var m = b.call("_get_unit_marker_for_unit", u)
		var c: Vector2i = b.call("_get_cell_from_world", m.position)
		arrivals.append([u.unit_id, c])
		h.expect(not grid.is_blocked(c), "arrival (record only): %s lands on %s, not blocked" % [u.unit_id, c])
	h.expect(arrivals.size() == 4, "four reinforcement marker cells (%d)" % arrivals.size())
	var yi = unit(b, "yi_sunsin")
	var guan = unit(b, "guan_yu")
	park(b)
	yi.set_grid_cell(Vector2i(7, 2)); guan.set_grid_cell(Vector2i(5, 2))
	b.call("_apply_resolver_advance_toward_target", yi, guan)
	h.expect(yi.grid_cell == Vector2i(7, 2), "advance (7,2) toward (5,2): Yi stays off the forest (at %s)" % yi.grid_cell)
	park(b)
	yi.set_grid_cell(Vector2i(8, 1))
	park(b)
	guan.set_grid_cell(Vector2i(10, 7))
	park(b)
	yi.set_grid_cell(Vector2i(5, 3))
	park(b)
	yi.set_grid_cell(Vector2i(7, 2)); guan.set_grid_cell(Vector2i(10, 7))
	lab._sync_views()
	for i in range(10): await process_frame
	for u in [yi, guan]:
		var at: Vector2i = lab.board.cell_at(lab.views[u.unit_id].position)
		h.expect(at == u.grid_cell and not forest.has(at), "%s's view stands on its engine cell %s (view %s), not forest" % [u.unit_id, u.grid_cell, at])
	await h.close_shell(self)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
