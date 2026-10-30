extends SceneTree
# Unit3D I5: the hit push and the troop-drop sink of the new soldiers (battle3d_unit_visuals.gd hit / show_soldier),
# in the 3D lab. Not a CI test. Checks:
#   1. a hit pushes the target's shown soldiers away from the attacker (at most HIT_PUSH) and they are home again
#      (x / z within 0.001 m) after HIT_STAGGER + HIT_OUT + HIT_BACK;
#   2. soldiers the troop count drops sink while still visible, then are hidden at their grounded height;
#      raising the count back shows them at once;
#   3. switch off: no visuals layer, a troop drop hides the old soldiers at once and moves none, and hit() on that
#      lab changes nothing;
#   4. visible_count gives the same number while the soldiers sink.
# Engine state is written only for the troop drop (current_troops of one unit) and restored after.
const LAB_SCENE := "res://scenes/battle3d/Battle3D_EnginePlayLab.tscn"
const Visuals := preload("res://scripts/battle3d/battle3d_unit_visuals.gd")
const Adapter := preload("res://scripts/battle3d/battle3d_unit_adapter.gd")
var fails := 0

func _initialize() -> void:
	_run.call_deferred()

func check(ok: bool, what: String) -> void:
	if not ok: fails += 1
	print(("[UNIT3D_HIT_SINK] PASS " if ok else "[UNIT3D_HIT_SINK] FAIL ") + what)

func wait(seconds: float) -> void:
	await create_timer(seconds, true, false, true).timeout
	await process_frame

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

func shown_ids(lab: Node, kind: String) -> Array:
	var out: Array = []
	for id in lab.views:
		if lab.views[id].visible and lab.views[id].has_meta("unit3d") and lab.soldiers[id][0].get_meta("unit3d_kind") == kind: out.append(id)
	return out

func _run() -> void:
	var lab := await open_lab(true)
	var v = lab.unit_visuals
	check(v != null, "switch on: visuals layer loaded")
	# 1. hit push
	var target: String = shown_ids(lab, "infantry")[0]
	var attacker: String = ""
	for id in lab.views:
		if id != target and lab.views[id].visible and (lab.views[id] as Node3D).global_position.distance_to(lab.views[target].global_position) > .1: attacker = id
	var root: Node3D = lab.views[target]
	var away: Vector3 = root.global_position - (lab.views[attacker] as Node3D).global_position
	away.y = 0.0
	var dir_local: Vector3 = (root.global_transform.basis.inverse() * away.normalized()).normalized()
	var home: Dictionary = {}
	var peak: Dictionary = {}
	for s in lab.soldiers[target]:
		home[s] = s.position
		peak[s] = Vector3.ZERO
	v.hit(lab, attacker, target)
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 300:
		await process_frame
		for s in lab.soldiers[target]:
			var d: Vector3 = s.position - home[s]
			d.y = 0.0
			if d.length() > (peak[s] as Vector3).length(): peak[s] = d
	var worst_peak := 1.0
	var worst_dot := 1.0
	var longest := 0.0
	for s in lab.soldiers[target]:
		if not s.visible: continue
		var d: Vector3 = peak[s]
		worst_peak = minf(worst_peak, d.length())
		longest = maxf(longest, d.length())
		if d.length() > .001: worst_dot = minf(worst_dot, d.normalized().dot(dir_local))
	check(worst_peak > .08 and longest <= Visuals.HIT_PUSH + .001, "hit %s by %s: each shown soldier pushed (peak %.3f..%.3f m, limit %.2f)" % [target, attacker, worst_peak, longest, Visuals.HIT_PUSH])
	check(worst_dot > .999, "pushed away from the attacker (lowest cos %.4f)" % worst_dot)
	var back := 0.0
	for s in lab.soldiers[target]:
		var d: Vector3 = s.position - home[s]
		d.y = 0.0
		back = maxf(back, d.length())
	check(back <= .001 and v._hits.is_empty(), "home again after %.2f s: largest x/z offset %.5f m" % [Visuals.HIT_STAGGER + Visuals.HIT_OUT + Visuals.HIT_BACK, back])
	# 2. + 4. sink on a troop drop, visible_count unchanged
	var sink_id: String = shown_ids(lab, "archer")[0]
	var unit = lab.queries.find_unit(sink_id)
	var troops: int = unit.current_troops
	var n: int = lab.soldiers[sink_id].size()
	var ground: Dictionary = {}
	for s in lab.soldiers[sink_id]: ground[s] = s.global_position.y
	check(lab.soldiers[sink_id].all(func(s): return s.visible), "%s: all %d soldiers shown before the drop (troops %d/%d)" % [sink_id, n, troops, unit.max_troops])
	unit.current_troops = int(floor(unit.max_troops * 6.0 / 9.0))
	var want: int = v.visible_count(Adapter.to_view(unit), n)
	await process_frame
	await process_frame
	await wait(.12)
	var dropped: Array = lab.soldiers[sink_id].slice(want)
	var kept: Array = lab.soldiers[sink_id].slice(0, want)
	var mid_depth := 99.0
	for s in dropped: mid_depth = minf(mid_depth, ground[s] - s.global_position.y)
	check(want == 6 and dropped.size() == 3, "troops %d/%d: visible_count %d of %d" % [unit.current_troops, unit.max_troops, want, n])
	check(dropped.all(func(s): return s.visible) and mid_depth > .2, "while sinking the 3 dropped soldiers stay visible and go down (at least %.3f m at ~0.12 s; read heights %s, SINK_EXTRA %.2f)" % [mid_depth, v._heights, Visuals.SINK_EXTRA])
	check(v.visible_count(lab.display_values[sink_id], n) == want, "visible_count while sinking: %d (the lab's shown count)" % v.visible_count(lab.display_values[sink_id], n))
	check(kept.all(func(s): return s.visible and absf(s.global_position.y - ground[s]) <= .001), "the 6 kept soldiers stay shown at their height")
	await wait(.35)
	var off_ground := 0.0
	for s in dropped: off_ground = maxf(off_ground, absf(s.global_position.y - ground[s]))
	check(dropped.all(func(s): return not s.visible) and off_ground <= .001 and v._sinks.is_empty(), "after %.1f s the dropped soldiers are hidden at their own height (largest y offset %.5f m)" % [Visuals.SINK_TIME, off_ground])
	unit.current_troops = troops
	await process_frame
	await process_frame
	var all_back: bool = lab.soldiers[sink_id].all(func(s): return s.visible and absf(s.global_position.y - ground[s]) <= .001)
	check(all_back, "troops back to %d: all %d shown at once at their height" % [troops, n])
	await close_lab(lab)
	# 3. switch off: nothing new runs
	lab = await open_lab(false)
	check(lab.unit_visuals == null, "switch off: no visuals layer")
	var id: String = ""
	for u in lab.views:
		if lab.views[u].visible: id = u
	unit = lab.queries.find_unit(id)
	troops = unit.current_troops
	var before: Array = lab.soldiers[id].map(func(s): return [s.visible, s.global_position])
	unit.current_troops = int(floor(unit.max_troops * 0.5))
	await process_frame
	await process_frame
	var expect: int = lab.visual_soldier_count(Adapter.to_view(unit))
	var vis: Array = lab.soldiers[id].map(func(s): return s.visible)
	var moved := 0
	for i in lab.soldiers[id].size():
		if lab.soldiers[id][i].global_position.distance_to(before[i][1]) > .0001: moved += 1
	check(vis.count(true) == expect and vis.slice(expect).all(func(x): return not x) and moved == 0, "switch off, troops %d/%d: %d of %d old soldiers shown at once, none moved" % [unit.current_troops, unit.max_troops, vis.count(true), vis.size()])
	var probe = Visuals.new()
	var other: String = ""
	for u in lab.views:
		if u != id and lab.views[u].visible: other = u
	probe.hit(lab, other, id)
	await wait(.3)
	moved = 0
	for i in lab.soldiers[id].size():
		if lab.soldiers[id][i].global_position.distance_to(before[i][1]) > .0001: moved += 1
	check(probe._hits.is_empty() and moved == 0, "switch off: hit() on an old-model unit changes nothing")
	unit.current_troops = troops
	await process_frame
	await close_lab(lab)
	await wait(.5) # the engine's round-start sound (2D) may still hold its playback right after the lab is freed
	print("[UNIT3D_HIT_SINK] RESULT fails=%d" % fails)
	quit(1 if fails else 0)
