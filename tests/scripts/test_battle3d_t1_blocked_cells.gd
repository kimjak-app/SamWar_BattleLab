extends SceneTree
# T1 test 2: the 3D engine lab hands the engine its forest cells, on the scenario shell (default battle).
#   - the engine's grid holds exactly the play area's forest cells (read here from terrain_types.json, 24 cells);
#   - the active ally's move range drawn by the lab (range_view discs, the movement adapter's projection) holds no
#     blocked cell; control: this test's own search without the block from the same start reaches forest cells;
#   - a click on a forest cell inside the ally's raw range: the engine's move command refuses (the lab counts a
#     rejection; unit cell, has_moved and phase unchanged); control: a click on a plain cell of the drawn range moves
#     the ally there.
const DIRS: Array[Vector2i] = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
var h

func _initialize() -> void:
	run.call_deferred()

func forest_cells() -> Array:
	var cells: Array = JSON.parse_string(FileAccess.get_file_as_string("res://assets/battle3d/terrain_types.json")).cells
	var out := []
	for y in range(10):
		for x in range(18):
			if cells[y][x] == "forest": out.append(Vector2i(x, y))
	return out

func reach(start: Vector2i, steps: int, occupied: Array) -> Array:
	var depth := {start: 0}
	var frontier: Array[Vector2i] = [start]
	while not frontier.is_empty():
		var cur: Vector2i = frontier.pop_front()
		if depth[cur] >= steps: continue
		for d in DIRS:
			var n: Vector2i = cur + d
			if depth.has(n) or n.x < 0 or n.y < 0 or n.x >= 18 or n.y >= 10 or occupied.has(n): continue
			depth[n] = depth[cur] + 1
			frontier.append(n)
	return depth.keys()

func click(lab, cell: Vector2i) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	event.position = lab.camera.unproject_position(lab.board.world(cell))
	lab._unhandled_input(event)
	for i in range(30): await process_frame

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_scenario_harness.gd").new()
	await h.open_shell(self)
	root.size = Vector2i(1920, 1080)
	await h.press_scenario(self, "default")
	var lab = h.lab
	var b: Node = lab.engine
	for i in range(60): await process_frame
	lab.edge_scroll_enabled = false
	var forest := forest_cells()
	var grid = b.get("battle_grid_controller")
	var held: Array = grid.blocked_cells.keys()
	h.expect(held.size() == forest.size() and forest.all(func(c): return grid.is_blocked(c)), "the engine's grid blocks the %d forest cells (holds %d)" % [forest.size(), held.size()])
	var ally = b.active_unit_state
	var start: Vector2i = ally.grid_cell
	var others := []
	for u in b.all_battle_unit_states:
		if u != ally and lab.views[u.unit_id].visible: others.append(u.grid_cell)
	await click(lab, start) # select the ally: the lab draws its move range
	var drawn: Array = lab.hud_range_cell_positions().map(func(p): return lab.board.cell_at(p))
	var raw := reach(start, ally.move_range, others)
	var raw_forest: Array = raw.filter(func(c): return forest.has(c))
	h.expect(not drawn.is_empty() and drawn.all(func(c): return not forest.has(c)), "%s at %s: the drawn move range (%d cells) holds no forest cell (%s)" % [ally.unit_id, start, drawn.size(), str(drawn.filter(func(c): return forest.has(c)))])
	h.expect(not raw_forest.is_empty(), "control: without the block %s's range from %s reaches forest %s" % [ally.unit_id, start, str(raw_forest)])
	# A forest cell inside the raw range: refused.
	var target: Vector2i = raw_forest[0] if not raw_forest.is_empty() else start
	var before := {"cell":ally.grid_cell, "moved":ally.has_moved, "phase":b.current_phase, "rejected":lab.rejected}
	await click(lab, target)
	var after := {"cell":ally.grid_cell, "moved":ally.has_moved, "phase":b.current_phase, "rejected":lab.rejected}
	h.expect(after.cell == before.cell and after.moved == before.moved and after.phase == before.phase and after.rejected == before.rejected + 1,
		"click on forest %s: the engine refuses (the lab's rejection count +1), its state unchanged %s -> %s" % [target, before, after])
	# Control: a plain cell of the drawn range.
	var plain: Vector2i = drawn.filter(func(c): return c != start)[0] if drawn.size() > 1 else start
	await click(lab, plain)
	for i in range(240):
		if ally.grid_cell == plain: break
		await process_frame
	h.expect(ally.grid_cell == plain, "control: click on %s (drawn range) moves %s there (at %s)" % [plain, ally.unit_id, ally.grid_cell])
	lab.edge_scroll_enabled = true
	await h.close_shell(self)
	print("[T1_3D_BLOCKED] checks=", h.checks, " failures=", h.failures, " forest ", forest.size(), " start ", start, " drawn ", drawn.size(), " raw forest ", raw_forest, " clicked ", target, " then ", plain)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
