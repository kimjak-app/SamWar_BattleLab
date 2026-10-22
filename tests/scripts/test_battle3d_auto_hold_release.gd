extends SceneTree
# M5-a2: the hold never stays on. Stopping auto from 3D while the hold is on
# sends false at once; freeing the lab (`_exit_tree`) while the hold is on
# sends false; manual play (auto off) sends no hold at all. Also prints the frame
# order of one auto cycle (hold on / off, engine auto action starts) at 1x and 4x.
var h

func _initialize() -> void:
	run.call_deferred()

func wait_until(cond: Callable, max_frames := 3000) -> bool:
	for i in range(max_frames):
		if cond.call(): return true
		await process_frame
	return cond.call()

func trace(battle: Node, speed_label: String) -> void:
	var rows: Array = []
	for c in battle.hold_calls: rows.append([c[1], "hold " + str(c[0])])
	for a in battle.action_starts: rows.append([a[0], "auto action start (3D idle=%s)" % str(a[1].get("idle"))])
	rows.sort_custom(func(x, y): return x[0] < y[0] or (x[0] == y[0] and x[1] < y[1]))
	var first: int = rows[0][0] if not rows.is_empty() else 0
	print("[AUTO_HOLD_TRACE] ", speed_label, " ", rows.slice(0, 12).map(func(r): return "+%d %s" % [r[0] - first, r[1]]))

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_auto_hold_harness.gd").new()
	# Stop while held.
	await h.open_lab(self)
	var battle: Node = h.lab.engine
	seed(1)
	h.press_auto()
	h.expect(await wait_until(func(): return battle.auto_presentation_hold), "hold turned on during the first auto action")
	await process_frame # next frame: a new press is not a double press
	h.press_auto()
	h.expect(not battle.is_full_auto_battle_enabled and battle.auto_presentation_hold == false and battle.hold_calls[-1][0] == false and h.lab.auto_hold_sent == false, "stop from 3D: hold false at once")
	h.expect(await wait_until(func(): return battle.current_phase in ["ally_turn", "facing_select"] and not battle.is_demo_animating and not h.lab._enemy_presentation_busy()), "manual play returns (ally turn or the facing choice after a stopped auto move) " + str([battle.current_phase, battle.is_demo_animating, h.lab._enemy_presentation_busy(), h.lab.enemy_queue.size(), h.lab.enemy_hold, battle.active_unit_state.unit_id if battle.active_unit_state else ""]))
	var calls_after_stop: int = battle.hold_calls.size()
	await h.close_lab(self)
	h.expect(calls_after_stop == battle.hold_calls.size() if is_instance_valid(battle) else true, "no hold call after the stop")

	# Free the lab while held.
	await h.open_lab(self)
	battle = h.lab.engine
	var calls: Array = battle.hold_calls # shared array: still readable after the engine is freed
	seed(1)
	h.press_auto()
	h.expect(await wait_until(func(): return battle.auto_presentation_hold), "held again")
	await h.close_lab(self)
	h.expect(calls.size() >= 2 and calls[-1][0] == false, "lab freed while held: last hold call false " + str(calls.slice(-2)))

	# Manual play sends no hold.
	await h.open_lab(self)
	battle = h.lab.engine
	var ally: BattleUnitState = h.roles(battle).ally
	h.lab.selected = ally.unit_id
	battle.call("_select_ally_unit", ally, false, false, false)
	await process_frame
	h.lab.request_wait()
	await wait_until(func(): return battle.current_phase == "ally_turn" and not battle.is_demo_animating and not h.lab._enemy_presentation_busy())
	h.expect(battle.hold_calls.is_empty() and not battle.auto_presentation_hold, "manual play: no hold call")
	await h.close_lab(self)

	# Frame order of the first auto cycles (pre-check evidence).
	for presses in [0, 2]:
		await h.open_lab(self)
		battle = h.lab.engine
		for i in range(presses): h.lab.speed_button.pressed.emit()
		seed(1)
		h.press_auto()
		await wait_until(func(): return battle.action_starts.size() >= 4, 6000)
		trace(battle, "%dx" % [1, 2, 4][presses])
		h.expect(battle.action_starts.all(func(a): return a[1].get("idle", false)), "%dx: 3D idle at the first auto action starts" % [1, 2, 4][presses])
		await h.close_lab(self)

	print("[AUTO_HOLD_RELEASE] checks=", h.checks, " failures=", h.failures)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
