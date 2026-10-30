extends SceneTree
# Unit3D I9: spearmen (infantry) and gunners run with run_carry (weapon raised) while the lab plays their move back
# (battle3d_unit_visuals.gd update / _spear_to / _musket_to), in the 3D lab. Not a CI test. Checks:
#   1. while moving, every soldier of a spearman and a gunner unit plays run_carry; archers play run; the cavalry horses
#      play run;
#   2. 0.3 s into the move (MUSKET_SLERP is 0.1 s) each musket is at MUSKET_RUN_Q and each spear at SPEAR_RUN_Q (within
#      ANGLE_TOL); after the move, idle again and the musket back at MUSKET_Q.idle, the spear at SPEAR_Q;
#   3. a spearman attack during a move puts the spear at SPEAR_Q at once (the same call);
#   4. switch off: no visuals layer and no AnimationPlayer in the lab holds run_carry.
# A move is played back by writing lab.playback (as _consume_events does); the test steps the lab at exactly 1/60 s.
const LAB_SCENE := "res://scenes/battle3d/Battle3D_EnginePlayLab.tscn"
const Visuals := preload("res://scripts/battle3d/battle3d_unit_visuals.gd")
const ANGLE_TOL := 0.002 # rad (about 0.11 deg): float32 node rotation and the 4-decimal quaternions
const DIRS := [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
var fails := 0

func _initialize() -> void:
	_run.call_deferred()

func check(ok: bool, what: String) -> void:
	if not ok: fails += 1
	print(("[UNIT3D_RUN_CARRY] PASS " if ok else "[UNIT3D_RUN_CARRY] FAIL ") + what)

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

func step(lab: Node, frames: int) -> void:
	lab.set_process(false)
	for i in frames:
		lab._process(1.0 / 60.0)
		await process_frame
	lab.set_process(true)

## A shown new-model unit of this kind (not in taken) and a 3-cell path from its cell that stays on the board.
func pick(lab: Node, kind: String, taken: Array = []) -> Array:
	for u in lab.views:
		if u in taken or not lab.views[u].visible or not lab.views[u].has_meta("unit3d") or lab.soldiers[u][0].get_meta("unit3d_kind") != kind: continue
		var c: Vector2i = lab.display_values[u].grid_cell
		for d in DIRS:
			if lab.board.on_board(c + d * 3): return [u, [c, c + d, c + d * 2, c + d * 3]]
	return []

func anims(lab: Node, v, id: String) -> Array:
	return lab.soldiers[id].map(func(s): return String(v.player_of(s).current_animation))

func worst_angle(lab: Node, table: Dictionary, id: String, want: Quaternion) -> float:
	var out := 0.0 # want normalized: the 4-decimal constants are not unit length (angle_to of SPEAR_Q with itself is 0.022)
	for s in lab.soldiers[id]: out = maxf(out, (table[s.get_instance_id()].node as Node3D).quaternion.angle_to(want.normalized()))
	return out

func _run() -> void:
	var lab := await open_lab(true)
	var v = lab.unit_visuals
	check(v != null, "switch on: visuals layer loaded")
	var units: Dictionary = {} # kind -> [id, path]
	for kind in ["infantry", "archer", "cavalry"]:
		units[kind] = pick(lab, kind)
		check(not units[kind].is_empty(), "%s unit with room to move: %s" % [kind, units[kind]])
	# the two gunner units are hidden reinforcements at the start: a shown 9-soldier foot unit gets gunner soldiers from
	# spawn_soldiers instead
	var taken: Array = units.values().filter(func(x): return not x.is_empty()).map(func(x): return x[0])
	units.gunner = pick(lab, "archer", taken)
	if units.gunner.is_empty(): units.gunner = pick(lab, "infantry", taken)
	if not units.gunner.is_empty():
		var gid: String = units.gunner[0]
		for s in lab.soldiers[gid]: s.free()
		lab.soldiers[gid] = v.spawn_soldiers({"unit_type": "gunner", "side": lab.display_values[gid].side}, lab.views[gid])
		await process_frame
	check(not units.gunner.is_empty() and lab.soldiers[units.gunner[0]].all(func(s): return s.get_meta("unit3d_kind") == "gunner"), "gunner unit (soldiers respawned as gunners): %s" % [units.gunner])
	if units.values().any(func(x): return x.is_empty()):
		await close_lab(lab)
		print("[UNIT3D_RUN_CARRY] RESULT fails=%d" % fails)
		quit(1)
		return
	var spear_id: String = units.infantry[0]
	var gun_id: String = units.gunner[0]
	check(v._spears.size() > 0 and lab.soldiers[spear_id].all(func(s): return v._spears.has(s.get_instance_id())), "every spearman's spear is tracked (%d spears)" % v._spears.size())
	check(worst_angle(lab, v._spears, spear_id, Visuals.SPEAR_Q) <= ANGLE_TOL and worst_angle(lab, v._muskets, gun_id, Visuals.MUSKET_Q.idle) <= ANGLE_TOL, "before the move: spears at SPEAR_Q, muskets at MUSKET_Q.idle")
	# 1. + 2. moving
	for kind in units: lab.playback[units[kind][0]] = {"path": units[kind][1], "index": 1}
	await step(lab, 18) # 0.3 s
	var moving: bool = units.values().all(func(x): return lab.playback.has(x[0]))
	check(moving, "all four units still moving 0.3 s in")
	check(anims(lab, v, spear_id).all(func(a): return a == "run_carry"), "spearmen moving: %s" % [anims(lab, v, spear_id)])
	check(anims(lab, v, gun_id).all(func(a): return a == "run_carry"), "gunners moving: %s" % [anims(lab, v, gun_id)])
	check(anims(lab, v, units.archer[0]).all(func(a): return a == "run"), "archers moving: %s" % [anims(lab, v, units.archer[0])])
	check(anims(lab, v, units.cavalry[0]).all(func(a): return a == "run"), "cavalry horses moving: %s" % [anims(lab, v, units.cavalry[0])])
	var spear_run := worst_angle(lab, v._spears, spear_id, Visuals.SPEAR_RUN_Q)
	var musket_run := worst_angle(lab, v._muskets, gun_id, Visuals.MUSKET_RUN_Q)
	check(spear_run <= ANGLE_TOL, "0.3 s into the move every spear is at SPEAR_RUN_Q (largest %.5f rad, tolerance %.3f)" % [spear_run, ANGLE_TOL])
	check(musket_run <= ANGLE_TOL, "0.3 s into the move every musket is at MUSKET_RUN_Q (largest %.5f rad, tolerance %.3f)" % [musket_run, ANGLE_TOL])
	while units.values().any(func(x): return lab.playback.has(x[0])): await process_frame
	await step(lab, 18) # 0.3 s after the move ended
	check(anims(lab, v, spear_id).all(func(a): return a == "idle") and anims(lab, v, gun_id).all(func(a): return a == "idle"), "stopped: spearmen %s, gunners %s" % [anims(lab, v, spear_id), anims(lab, v, gun_id)])
	check(anims(lab, v, units.archer[0]).all(func(a): return a == "idle") and anims(lab, v, units.cavalry[0]).all(func(a): return a == "idle"), "stopped: archers and horses idle")
	var spear_idle := worst_angle(lab, v._spears, spear_id, Visuals.SPEAR_Q)
	var musket_idle := worst_angle(lab, v._muskets, gun_id, Visuals.MUSKET_Q.idle)
	check(spear_idle <= ANGLE_TOL and musket_idle <= ANGLE_TOL, "stopped: spears back at SPEAR_Q (%.5f rad), muskets at MUSKET_Q.idle (%.5f rad)" % [spear_idle, musket_idle])
	# 3. spearman attack during a move: SPEAR_Q at once
	await create_timer(.6, true, false, true).timeout # back at the engine cell (the move was presentation only)
	lab.playback[spear_id] = {"path": units.infantry[1], "index": 1}
	await step(lab, 18)
	var before_attack := worst_angle(lab, v._spears, spear_id, Visuals.SPEAR_RUN_Q)
	v.attack(lab, spear_id, gun_id)
	var at_attack := worst_angle(lab, v._spears, spear_id, Visuals.SPEAR_Q)
	check(before_attack <= ANGLE_TOL and at_attack <= ANGLE_TOL and anims(lab, v, spear_id).all(func(a): return a == "attack_spear_short"), "spearman attack while moving: spear SPEAR_RUN_Q before (%.5f rad), SPEAR_Q right after the call (%.5f rad), playing %s" % [before_attack, at_attack, anims(lab, v, spear_id)[0]])
	while lab.playback.has(spear_id): await process_frame
	await create_timer(1.5, true, false, true).timeout
	await close_lab(lab)
	# 4. switch off
	lab = await open_lab(false)
	check(lab.unit_visuals == null, "switch off: no visuals layer")
	var carry := 0
	var new_units := 0
	for u in lab.views:
		if lab.views[u].has_meta("unit3d"): new_units += 1
	for p in lab.find_children("*", "AnimationPlayer", true, false):
		if (p as AnimationPlayer).has_animation("run_carry"): carry += 1
	check(carry == 0 and new_units == 0, "switch off: %d new-model units, %d AnimationPlayers with run_carry" % [new_units, carry])
	await close_lab(lab)
	await create_timer(.5, true, false, true).timeout # the engine's round-start sound (2D) may still hold its playback
	print("[UNIT3D_RUN_CARRY] RESULT fails=%d" % fails)
	quit(1 if fails else 0)
