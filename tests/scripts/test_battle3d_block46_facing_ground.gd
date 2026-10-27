extends SceneTree
# HUD block 4-6 test 5: the facing arrows on the ground, on the scenario shell. The 2D grid directions are written here
# (up = row - 1 = world -z, down = +z, left = column - 1 = -x, right = +x).
#   - every unit's arrow points the way of its engine facing (BattleUnitState.facing), as a world direction on the ground;
#   - all four facings, each put on one unit's arrow in turn by the lab's own placement, point their own way;
#   - after real Q / E key presses (the camera yaw changes) the arrows' world directions are the same;
#   - the arrow sits in front of the unit, beyond the soldiers and inside the selection ring (centre 0.8-1.1 m out, flat).
const WORLD := {"up":Vector3(0, 0, -1), "down":Vector3(0, 0, 1), "left":Vector3(-1, 0, 0), "right":Vector3(1, 0, 0)}
var h

func _initialize() -> void:
	run.call_deferred()

func key(code: Key, frames := 20) -> void:
	var e := InputEventKey.new()
	e.keycode = code
	e.physical_keycode = code
	e.pressed = true
	root.push_input(e)
	for i in range(frames): await process_frame
	var up := e.duplicate()
	up.pressed = false
	root.push_input(up)
	for i in range(3): await process_frame

func arrow_of(lab, id: String) -> MeshInstance3D:
	for child in lab.views[id].get_children():
		if child.has_meta("facing_arrow"): return child
	return null

func pointing(arrow: Node3D) -> Vector3:
	var f := -arrow.global_transform.basis.z
	return Vector3(f.x, 0, f.z).normalized()

func directions(lab, b) -> Dictionary:
	var out := {}
	for unit in b.all_battle_unit_states:
		var arrow := arrow_of(lab, unit.unit_id)
		if arrow != null: out[unit.unit_id] = pointing(arrow)
	return out

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_scenario_harness.gd").new()
	await h.open_shell(self)
	root.size = Vector2i(1920, 1080)
	await h.press_scenario(self, "default")
	var lab = h.lab
	var b: Node = lab.engine
	for i in range(30): await process_frame
	var wrong := []
	var facings := {}
	for unit in b.all_battle_unit_states:
		var arrow := arrow_of(lab, unit.unit_id)
		facings[unit.facing] = true
		if arrow == null or pointing(arrow).distance_to(WORLD[unit.facing]) > 0.001: wrong.append([unit.unit_id, unit.facing, pointing(arrow) if arrow else null])
	h.expect(wrong.is_empty() and b.all_battle_unit_states.size() > 0, "every unit's arrow = its engine facing (facings seen %s; wrong %s)" % [facings.keys(), str(wrong)])
	var id: String = b.all_battle_unit_states[0].unit_id
	var arrow := arrow_of(lab, id)
	var four := []
	for facing in WORLD:
		lab._place_facing_arrow(arrow, lab.views[id], facing)
		var out: Vector3 = arrow.position
		var flat := Vector2(out.x, out.z)
		four.append([facing, pointing(arrow).distance_to(WORLD[facing]) < 0.001, flat.length() >= 0.8 and flat.length() <= 1.1, Vector2(WORLD[facing].x, WORLD[facing].z).dot(flat.normalized()) > 0.999, absf(arrow.global_transform.basis.y.normalized().dot(Vector3.UP) - 1.0) < 0.001])
	h.expect(four.all(func(r): return r[1] and r[2] and r[3] and r[4]), "the four facings point their own way, in front, flat [facing, direction, distance, ahead, flat] %s" % str(four))
	for i in range(3): await process_frame # the next sync puts the arrow back to the engine facing
	var before := directions(lab, b)
	var yaw0: float = lab.yaw
	await key(KEY_Q)
	var after_q := directions(lab, b)
	var yaw_q: float = lab.yaw
	await key(KEY_E, 40)
	var after_e := directions(lab, b)
	h.expect(absf(yaw_q - yaw0) > 0.1 and absf(lab.yaw - yaw_q) > 0.1, "Q and E turned the camera (yaw %.2f -> %.2f -> %.2f)" % [yaw0, yaw_q, lab.yaw])
	var moved := []
	for uid in before:
		if before[uid].distance_to(after_q.get(uid, Vector3.INF)) > 0.001 or before[uid].distance_to(after_e.get(uid, Vector3.INF)) > 0.001: moved.append(uid)
	h.expect(not before.is_empty() and moved.is_empty(), "after Q / E every arrow keeps its world direction (changed %s)" % str(moved))
	await h.close_shell(self)
	print("[BLOCK46_FACING] checks=", h.checks, " failures=", h.failures)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
