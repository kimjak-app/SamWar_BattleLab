extends SceneTree
# Unit3D I7: the new soldiers face their travel while the lab plays a move back and the engine's facing otherwise,
# turning smoothly (battle3d_unit_visuals.gd _target_yaw / update). Not a CI test. Checks:
#   1. moves along +x, +z and the diagonal: 0.4 s in, each soldier's front (+Z of the model) is within 2 deg of the travel;
#   2. after the move, with the engine facing "left", 0.5 s later each front is within 2 deg of the lab's "left";
#   3. no frame turns a soldier by more than PI * (1 - exp(-TURN_RATE * delta)) (the largest smooth step; the test steps
#      the lab at exactly 1/60 s for this), except the
#      first yaw, which is set: at the start every soldier already looks along its facing;
#   4. switch off: every old soldier's rotation.y is the lab's table value for its unit's facing, the same frame;
#   5. the 9 soldiers of the unit look the same way (within 0.5 deg).
# A move is played back by writing lab.playback (as _consume_events does); facing by the engine unit's facing (restored).
const LAB_SCENE := "res://scenes/battle3d/Battle3D_EnginePlayLab.tscn"
const Visuals := preload("res://scripts/battle3d/battle3d_unit_visuals.gd")
const TABLE := {"up": 0.0, "down": PI, "left": PI / 2, "right": -PI / 2} # battle3d_engine_play.gd _sync_views
var fails := 0

func _initialize() -> void:
	_run.call_deferred()

func check(ok: bool, what: String) -> void:
	if not ok: fails += 1
	print(("[UNIT3D_FACE_TRAVEL] PASS " if ok else "[UNIT3D_FACE_TRAVEL] FAIL ") + what)

func open_lab(on: bool) -> Node:
	var lab: Node = preload("res://tests/scripts/support/battle3d_test_world.gd").lab(load(LAB_SCENE).instantiate())
	lab.unit3d_models = on
	root.add_child(lab)
	while not lab.ready_for_input: await process_frame
	await process_frame
	return lab

func close_lab(lab: Node) -> void: # as battle3d_engine_attack_harness.gd close_lab
	var iso = lab.engine.get("_iso_grid_controller")
	lab.free()
	if is_instance_valid(iso) and iso.get_parent() == null: iso.free()
	await process_frame

func front(soldier: Node3D) -> Vector3: # the new models look along their +Z
	var f := soldier.global_basis.z
	return Vector3(f.x, 0, f.z).normalized()

func degrees(a: Vector3, b: Vector3) -> float:
	return rad_to_deg(a.angle_to(b))

func spread(lab: Node, id: String) -> float: # largest angle between the unit's first soldier and the others
	var first := front(lab.soldiers[id][0])
	var out := 0.0
	for s in lab.soldiers[id]: out = maxf(out, degrees(first, front(s)))
	return out

func _run() -> void:
	var lab := await open_lab(true)
	var v = lab.unit_visuals
	# the unit: a new-model foot unit with room for 3 cells along +x, +z and the diagonal
	var id := ""
	for u in lab.views:
		if not lab.views[u].visible or not lab.views[u].has_meta("unit3d") or lab.soldiers[u].size() != 9: continue
		var c: Vector2i = lab.display_values[u].grid_cell
		if lab.board.on_board(c + Vector2i(3, 3)): id = u
	check(id != "", "a 9-soldier new-model unit with room to move: %s" % id)
	var unit = lab.queries.find_unit(id)
	var start_cell: Vector2i = unit.grid_cell
	var facing0: String = unit.facing
	var start_worst := 0.0
	for u in lab.views:
		if not lab.views[u].has_meta("unit3d"): continue
		var want := Basis(Vector3.UP, TABLE.get(lab.display_values[u].facing, 0.0)) * Vector3(0, 0, -1) # the old models' front
		for s in lab.soldiers[u]: start_worst = maxf(start_worst, degrees(front(s), want))
	check(start_worst <= .01, "start: every new soldier already faces its unit's facing (worst %.4f deg)" % start_worst)
	var largest_step := 0.0
	var largest_allowed := 0.0
	var over := 0
	var ratio := 0.0 # largest turned / (TURN_RATE * delta)
	for move in [["+x", Vector2i(1, 0)], ["+z", Vector2i(0, 1)], ["diagonal", Vector2i(1, 1)]]:
		var step: Vector2i = move[1]
		var path: Array = []
		for i in 4: path.append(start_cell + step * i)
		lab.playback[id] = {"path": path, "index": 1}
		var travel := Vector3(step.x, 0, step.y).normalized()
		var last: Array = lab.soldiers[id].map(func(s): return s.rotation.y)
		lab.set_process(false) # the test steps the lab itself: 24 frames of exactly 1/60 s = 0.4 s
		var dt := 1.0 / 60.0
		var allowed := PI * (1.0 - exp(-Visuals.TURN_RATE * dt)) + 1e-5
		largest_allowed = allowed
		for frame in 24:
			lab._process(dt)
			await process_frame
			for i in lab.soldiers[id].size():
				var turned := absf(angle_difference(last[i], lab.soldiers[id][i].rotation.y))
				largest_step = maxf(largest_step, turned)
				ratio = maxf(ratio, turned / (Visuals.TURN_RATE * dt))
				if turned > allowed: over += 1
				last[i] = lab.soldiers[id][i].rotation.y
		lab.set_process(true)
		var moving: bool = lab.playback.has(id)
		var worst := 0.0
		for s in lab.soldiers[id]: worst = maxf(worst, degrees(front(s), travel))
		check(moving and worst <= 2.0, "%s move, 0.4 s in (still moving %s): fronts within %.3f deg of the travel" % [move[0], moving, worst])
		check(spread(lab, id) <= .5, "%s move: the 9 soldiers look the same way (spread %.4f deg)" % [move[0], spread(lab, id)])
		while lab.playback.has(id): await process_frame
		await create_timer(.6, true, false, true).timeout # back at the engine cell (the move was presentation only), facing again
	check(over == 0, "turns are smooth: largest step %.4f rad a frame, allowed up to %.4f (PI * (1 - exp(-%.0f * delta))); largest turned / (TURN_RATE * delta) %.3f" % [largest_step, largest_allowed, Visuals.TURN_RATE, ratio])
	# 2. after the move, facing "left"
	unit.facing = "left"
	await create_timer(.5, true, false, true).timeout
	var left := Basis(Vector3.UP, TABLE.left) * Vector3(0, 0, -1)
	var worst_left := 0.0
	for s in lab.soldiers[id]: worst_left = maxf(worst_left, degrees(front(s), left))
	check(worst_left <= 2.0, "facing left, 0.5 s later: fronts within %.3f deg of the lab's left %s" % [worst_left, left])
	check(spread(lab, id) <= .5, "facing left: the 9 soldiers look the same way (spread %.4f deg)" % spread(lab, id))
	unit.facing = facing0
	await process_frame
	await close_lab(lab)
	# 4. switch off: the table value, at once
	lab = await open_lab(false)
	check(lab.unit_visuals == null, "switch off: no visuals layer")
	var off_worst := 0.0
	for u in lab.views:
		for s in lab.soldiers[u]: off_worst = maxf(off_worst, absf(s.rotation.y - TABLE.get(lab.display_values[u].facing, 0.0)))
	var some: String = lab.views.keys()[0]
	var some_unit = lab.queries.find_unit(some)
	var f0: String = some_unit.facing
	some_unit.facing = "right" if f0 != "right" else "left"
	lab._sync_views()
	var same_frame: bool = lab.soldiers[some].all(func(s): return absf(s.rotation.y - TABLE[some_unit.facing]) <= 1e-6)
	check(off_worst <= 1e-6 and same_frame, "switch off: old soldiers' rotation.y is the table value (largest difference %.9f rad, float32 storage), and a facing change applies in the same sync" % off_worst)
	some_unit.facing = f0
	await process_frame
	await close_lab(lab)
	await create_timer(.5, true, false, true).timeout # the engine's round-start sound (2D) may still hold its playback
	print("[UNIT3D_FACE_TRAVEL] RESULT fails=%d" % fails)
	quit(1 if fails else 0)
