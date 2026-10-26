extends SceneTree
# Block 7 test 1: cells outside the play area (the scenery of the 20x20 board, columns 18-19 and rows 10-19, and
# anything off the board) never appear in a move range, a click or a facing arrow, and a real click there makes no
# engine query and no engine write. The play area is written here independently as 18x10 (the engine grid).
# Checks:
#   - the predicates: board.valid (move/facing/click) and the projection's is_in_bounds agree with x < 18 and y < 10 on
#     every cell of the board and a 2-cell margin around it;
#   - move ranges: every engine unit's reachable cells (lab.queries) and every demo unit's routes stay in the play area;
#   - real clicks on scenery cells (the ray's first ground hit independently confirmed to be that cell) and on a point
#     whose ray misses the ground: "칸 없음", no engine write, no lab.queries.query call, phase / actor / units unchanged;
#     then a real click on the acting ally (positive control) does query and write;
#   - facing: the ally moved by real clicks to an edge cell of the play area gets an arrow exactly for its in-area
#     neighbours (the shell's command_state and the panel's arrow buttons).
const PLAY := Vector2i(18, 10)
const Port = preload("res://scripts/battle3d/lab_demo_port.gd")
const FACING := {"up":Vector2i(0, -1), "down":Vector2i(0, 1), "left":Vector2i(-1, 0), "right":Vector2i(1, 0)}
const MISS := Vector2i(-999, -999)
var h

class CountingQueries extends "res://scripts/battle3d/battle3d_movement_adapter.gd":
	var calls := 0
	func query(id: String, target: Vector2i, allow_breakthrough := false) -> Dictionary:
		calls += 1
		return super(id, target, allow_breakthrough)

func _initialize() -> void:
	run.call_deferred()

func in_play(c: Vector2i) -> bool:
	return c.x >= 0 and c.y >= 0 and c.x < PLAY.x and c.y < PLAY.y

func settle(lab, b) -> void:
	for i in range(8000):
		await process_frame
		if b.is_demo_animating or lab._enemy_presentation_busy() or lab._presentation_busy(): continue
		if b.current_phase in ["ally_turn", "facing_select", "attack_select"] or not lab.battle_result.is_empty(): break
	for i in range(3): await process_frame

func push(at: Vector2, kind: String) -> void:
	var e: InputEvent
	if kind == "move":
		e = InputEventMouseMotion.new()
	else:
		e = InputEventMouseButton.new()
		e.button_index = MOUSE_BUTTON_LEFT
		e.pressed = kind == "down"
	e.position = at
	e.global_position = at
	root.push_input(e)
	await process_frame

func click_at(at: Vector2) -> void:
	await push(at, "move")
	await push(at, "down")
	await push(at, "up")

func first_ground_cell(lab, at: Vector2) -> Vector2i:
	# Independent of the projection: the first physics hit on the lab's ground (mask 1), floored by the 3 m cell.
	var o: Vector3 = lab.camera.project_ray_origin(at)
	var hit: Dictionary = lab.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(o, o + lab.camera.project_ray_normal(at) * 1000.0, 1))
	if hit.is_empty(): return MISS
	return Vector2i(floori(hit.position.x / 3.0), floori(hit.position.z / 3.0))

func snapshot(lab, b) -> Dictionary:
	var u = b.active_unit_state
	return {"phase":b.current_phase, "active":u.unit_id if u else "", "units":b.all_battle_unit_states.map(func(x): return [x.unit_id, x.grid_cell, x.facing, x.has_moved, x.has_acted]),
		"views":lab.views.keys().map(func(id): return lab.views[id].position)}

func look_at_cell(lab, cell: Vector2i) -> void:
	lab.focus = lab.board.world(cell) * Vector3(1, 0, 1)
	lab._update_camera()
	await process_frame
	await physics_frame

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_scenario_harness.gd").new()
	await h.open_shell(self)
	root.size = Vector2i(1920, 1080)
	await h.press_scenario(self, "default")
	var lab = h.lab
	var b: Node = lab.engine
	await settle(lab, b)
	var board = lab.board
	# The predicates.
	var disagree := []
	for y in range(-2, board.SIZE.y + 2):
		for x in range(-2, board.SIZE.x + 2):
			var c := Vector2i(x, y)
			if board.valid(c) != in_play(c) or lab.projection.is_in_bounds(c) != in_play(c): disagree.append(c)
	h.expect(board.SIZE == Vector2i(20, 20) and disagree.is_empty(), "board.valid and the projection's bounds = the 18x10 play area on all %d cells (disagree %s)" % [(board.SIZE.x + 4) * (board.SIZE.y + 4), str(disagree.slice(0, 8))])
	# Move ranges: the engine's (through the lab's queries) and the demo port's.
	var out_of_area := []
	for unit in lab.queries.alive_units:
		for c in lab.queries.query(unit.unit_id, unit.grid_cell).get("reachable", {}).keys():
			if not in_play(c): out_of_area.append([unit.unit_id, c])
	h.expect(lab.queries.alive_units.size() > 0 and out_of_area.is_empty(), "%d engine units: no reachable cell outside the play area (%s)" % [lab.queries.alive_units.size(), str(out_of_area.slice(0, 8))])
	var port = Port.new()
	port.board = board
	var demo_out := []
	for u in port.units:
		for y in range(-1, board.SIZE.y + 1):
			for x in range(-1, board.SIZE.x + 1):
				var route: Array = port.path_to(u.unit_id, Vector2i(x, y))
				if not in_play(Vector2i(x, y)) and not route.is_empty(): demo_out.append([u.unit_id, Vector2i(x, y)])
				if route.any(func(c): return not in_play(c)): demo_out.append([u.unit_id, route])
	h.expect(demo_out.is_empty(), "demo port: no route to or through a cell outside the play area (%s)" % str(demo_out.slice(0, 8)))
	# Real clicks outside the play area.
	for i in range(90): await process_frame # the turn's camera centring (0.35 s) ends
	if is_instance_valid(h.shell.camera_tween): h.shell.camera_tween.kill()
	lab.focus = Vector3(PLAY.x * board.CELL, 0, PLAY.y * board.CELL) # the play area's far corner: columns 18-19 and rows 10+ in view
	lab._update_camera()
	await process_frame
	await physics_frame
	var spy := CountingQueries.new()
	spy.grid = lab.queries.grid
	spy.alive_units = lab.queries.alive_units
	var real_queries = lab.queries
	lab.queries = spy
	var view := root.get_visible_rect()
	var targets := []
	for c in [Vector2i(18, 2), Vector2i(19, 6), Vector2i(18, 9), Vector2i(4, 10), Vector2i(12, 11), Vector2i(17, 10), Vector2i(19, 12), Vector2i(8, 14), Vector2i(19, 19)]:
		var at: Vector2 = lab.camera.unproject_position(board.world(c))
		if view.has_point(at) and first_ground_cell(lab, at) == c: targets.append([c, at])
	var sky := Vector2(-1, -1)
	for y in range(4, int(view.size.y * .5), 8):
		if first_ground_cell(lab, Vector2(view.size.x * .5, y)) == MISS:
			sky = Vector2(view.size.x * .5, y)
			break
	if sky.x >= 0: targets.append([MISS, sky])
	var cols := targets.filter(func(t): return t[0] != MISS and t[0].x >= PLAY.x).size()
	var rows := targets.filter(func(t): return t[0] != MISS and t[0].y >= PLAY.y).size()
	h.expect(cols >= 1 and rows >= 1 and sky.x >= 0 and targets.size() >= 4, "clickable outside targets: %d, %d in columns 18-19, %d in rows 10+, ground miss at %s (%s)" % [targets.size(), cols, rows, sky, str(targets.map(func(t): return t[0]))])
	var results := []
	for t in targets:
		var before := snapshot(lab, b)
		var writes: Array = b.writes.duplicate()
		var rejected: int = lab.rejected
		var calls := spy.calls
		await click_at(t[1])
		for i in range(2): await process_frame
		var new_writes: Array = b.writes.slice(writes.size())
		var ok: bool = new_writes.is_empty() and spy.calls == calls and lab.rejected == rejected + 1 and lab.status.text.contains("플레이 구역 밖") and snapshot(lab, b) == before
		results.append([t[0], ok, new_writes, spy.calls - calls, lab.status.text])
	h.expect(results.all(func(r): return r[1]), "outside clicks: 칸 없음, 0 writes, 0 queries, nothing changed %s" % str(results))
	# Positive control: the acting ally's own cell, same spy.
	var actor = b.active_unit_state
	var calls_before := spy.calls
	var writes_before: Array = b.writes.duplicate()
	await look_at_cell(lab, actor.grid_cell)
	await click_at(lab.camera.unproject_position(board.world(actor.grid_cell)))
	for i in range(2): await process_frame
	h.expect(spy.calls > calls_before and b.writes.slice(writes_before.size()).has("_select_ally_unit"), "control: a click on the acting ally queries (%d) and writes %s" % [spy.calls - calls_before, b.writes.slice(writes_before.size())])
	lab.queries = real_queries
	# Facing: move the actor by real clicks to a reachable empty edge cell (one with an outside neighbour).
	var edge = null
	for c in lab.queries.query(actor.unit_id, actor.grid_cell).get("reachable", {}).keys():
		if c != actor.grid_cell and b.all_battle_unit_states.all(func(x): return x.grid_cell != c) and FACING.values().any(func(d): return not in_play(c + d)):
			edge = c
			break
	if edge == null:
		h.expect(false, "no reachable empty edge cell for %s from %s: the facing check could not run" % [actor.unit_id, actor.grid_cell])
	else:
		await look_at_cell(lab, edge)
		await click_at(lab.camera.unproject_position(board.world(edge)))
		var waited := 0
		while not (b.current_phase == "facing_select" and h.shell.command_panel.arrows.visible) and waited < 3000:
			await process_frame
			waited += 1
		for i in range(3): await process_frame
		var state: Dictionary = h.shell.command_state()
		var wrong := []
		for d in FACING:
			var target: Vector2i = actor.grid_cell + FACING[d]
			var arrow: Dictionary = state.get("arrows", {}).get(d, {})
			if arrow.get("valid", null) != in_play(target) or h.shell.command_panel.arrow_for(d).visible != in_play(target): wrong.append([d, target, arrow.get("valid", null), h.shell.command_panel.arrow_for(d).visible])
		h.expect(b.current_phase == "facing_select" and actor.grid_cell == edge and state.get("facing_open", false) and wrong.is_empty(),
			"facing at the edge cell %s: arrows exactly for in-area neighbours (phase %s, wrong %s)" % [edge, b.current_phase, str(wrong)])
	await h.close_shell(self)
	print("[BLOCK7_OUTSIDE] checks=", h.checks, " failures=", h.failures, " outside clicks=", targets.size())
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
