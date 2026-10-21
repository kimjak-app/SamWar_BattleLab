extends SceneTree
# M4-d: untouched default 18x10 battle (no fixture), 3D input only, compared with
# the same commands sent to an engine without 3D. Round 1: all wait. Round 2:
# the arrived ally reinforcement moves, confirms facing and defends; the others
# wait (the arrived enemy reinforcement acts in a replayed enemy slot). Round 3:
# after the city reinforcements arrive, the arrived city ally is selected,
# moves, confirms facing and waits. Per frame: no unit shown before its arrival
# is presented; idle: shown units == engine deployed units, badges == roster.
const GOLDEN := "res://tests/golden/battle3d_m3_start_v0.json"
const R01 := "ally_reinforce_01_demo"
const R02 := "ally_reinforce_02_test_unit"
var h

func _initialize() -> void:
	run.call_deferred()

func first_free_cell(battle: Node, unit) -> Vector2i:
	# Test-side choice (same on both paths): first reachable cell in x/y order.
	var q = load("res://scripts/battle3d/battle3d_movement_adapter.gd").new()
	q.grid = battle.battle_grid_controller
	for u in battle.all_battle_unit_states: q.alive_units.append(u)
	var cells: Array = q.query(unit.unit_id, unit.grid_cell).get("reachable", {}).keys()
	cells.sort_custom(func(a, b): return a.x < b.x or (a.x == b.x and a.y < b.y))
	return cells[0]

func find(battle: Node, id: String):
	for u in battle.all_battle_unit_states:
		if u.unit_id == id: return u
	return null

func direct() -> Dictionary:
	var host = await h.open_bare(self)
	var battle: Node = host.battle
	var r02_done := false
	for step in range(14):
		if battle.battle_round >= 3 and r02_done: break
		if battle.battle_round >= 3:
			var r02 = find(battle, R02)
			battle.call("_select_ally_unit", r02, false, false, false)
			battle.call("_try_direct_move_to_cell", first_free_cell(battle, r02))
			for i in range(1800):
				await process_frame
				if battle.current_phase == "facing_select" and not battle.is_demo_animating: break
			battle.call("_select_post_move_facing", "left")
			battle.call("_end_ally_turn_by_wait")
			r02_done = true
		else:
			var active = battle.active_unit_state
			battle.call("_select_ally_unit", active, false, false, false)
			if active.unit_id == R01:
				battle.call("_try_direct_move_to_cell", first_free_cell(battle, active))
				for i in range(1800):
					await process_frame
					if battle.current_phase == "facing_select" and not battle.is_demo_animating: break
				battle.call("_select_post_move_facing", "right")
				battle.call("_on_defend_button_pressed")
			else:
				battle.call("_end_ally_turn_by_wait")
		await h.settle_bare(self, battle, "direct step " + str(step))
	var result: Dictionary = h.state4(battle)
	await h.close_bare(self, host)
	return result

func lab_run(golden: Dictionary) -> Dictionary:
	h.frames.clear()
	await h.open_lab(self)
	var lab = h.lab
	var battle: Node = lab.engine
	var start := {"units":h.fingerprint.fingerprint_units(battle.all_battle_unit_states), "controller":h.oracle.controller_state(battle)}
	h.expect(h.fingerprint.diff(golden.layouts.default, start).is_empty(), "default start equals golden (no fixture)")
	lab._sync_views()
	h.expect(h.visible_ids().size() == 6 and h.available_ids(battle).size() == 6, "round 1: six deployed units shown")
	var r02_done := false
	var counts := []
	for step in range(14):
		if battle.battle_round >= 3 and r02_done: break
		if battle.battle_round >= 3:
			var r02 = find(battle, R02)
			h.expect(lab.views[R02].visible, "round 3: arrived city ally shown before it is selected")
			h.click(r02.grid_cell)
			h.expect(battle.active_unit_state == r02, "round 3: arrived city ally selected through the existing click path")
			h.click(first_free_cell(battle, r02))
			await h.wait_for(self, "facing_select")
			for button in lab.facing_ui.get_children():
				if button.text == "방향 left": button.pressed.emit()
			lab._sync_views()
			h.press_wait()
			r02_done = true
		else:
			var active = battle.active_unit_state
			h.click(active.grid_cell)
			if active.unit_id == R01:
				h.expect(lab.views[R01].visible, "round 2: arrived ally shown before it acts")
				h.click(first_free_cell(battle, active))
				await h.wait_for(self, "facing_select")
				for button in lab.facing_ui.get_children():
					if button.text == "방향 right": button.pressed.emit()
				lab._sync_views()
				h.press_defend()
				h.expect(lab.status.text.begins_with("방어 · " + R01), "round 2: arrived ally defends through the existing path")
			else:
				h.press_wait()
		await h.settle_lab(self, "3D step " + str(step), h.arrival_probe)
		lab._sync_views()
		counts.append([battle.battle_round, h.visible_ids().size(), h.available_ids(battle).size()])
	h.expect(battle.battle_round == 3 and lab.current_round == 3, "round 3 reached")
	var result: Dictionary = h.state4(battle)
	result["lab"] = h.lab_view()
	result["lab"]["tactic_cursor"] = lab.tactic_cursor
	result["lab"]["arrivals"] = lab.arrival_presentations.duplicate(true)
	result["lab"]["arrival_texts"] = lab.arrival_texts.duplicate()
	result["lab"]["pending"] = lab.pending_arrivals.duplicate(true)
	result["lab"]["counts"] = counts
	result["lab"]["visible_end"] = h.visible_ids()
	return result

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_reinforce_harness.gd").new()
	var golden: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(GOLDEN))
	var d: Dictionary = await direct()
	var td: Dictionary = await lab_run(golden)
	await h.close_lab(self)
	h.expect(d.writes == td.writes, "same write sequence " + str(td.writes))
	for call in td.writes: h.expect(h.EIGHT.has(call), "write within the eight commands " + call)
	h.expect(d.deploys == td.deploys and td.deploys.size() == 4, "deploy entry points called by the engine only, same on both paths " + str(td.deploys))
	h.expect(h.fingerprint.diff(d.units, td.units).is_empty(), "40-field units equal " + str(h.fingerprint.diff(d.units, td.units)))
	h.expect(h.fingerprint.diff(d.controller, td.controller).is_empty(), "controller equal")
	for name in d.logs: h.expect(d.logs[name] == td.logs[name], name + " equal")
	h.expect(d.tactic == td.tactic, "tactic_event_log equal")
	var events: Array = td.logs.enemy_action_event_log
	h.expect(td.lab.cursors == [td.logs.ally_move_event_log.size(), td.logs.battle_action_event_log.size(), events.size()], "three cursors at their own log ends")
	h.expect(td.lab.tactic_cursor == td.tactic.size(), "fourth cursor at the tactic log end")
	var arrivals: Array = td.tactic.filter(func(e): return e.kind == "reinforcement_arrived")
	h.expect(arrivals.size() == 4 and td.lab.arrivals == arrivals and td.lab.pending.is_empty(), "every arrival presented once, in log order, none pending")
	for e in arrivals:
		h.expect(td.lab.arrival_texts.has("지원군 도착 · %s · %s" % ["아군" if e.side == "ally" else "적군", e.unit_id]), "arrival line from the event " + e.unit_id)
		h.expect(td.lab.combat_lines.has("지원군 도착 · %s · %s" % ["아군" if e.side == "ally" else "적군", e.unit_id]), "arrival line in the combat log " + e.unit_id)
		var unit_cell: Array = []
		for u in td.units:
			if u.unit_id == e.unit_id: unit_cell = u.grid_cell
		h.expect(not td.lab.arrival_texts.any(func(x): return x.contains("우선")), "event cell == engine cell for every arrival")
	h.expect(td.lab.enemy_played_paths == events.filter(func(e): return e.kind == "enemy_moved").map(func(e): return e.path), "every enemy path (incl. the enemy reinforcement) replayed")
	h.expect(events.any(func(e): return e.kind == "enemy_actor_selected" and e.unit_id == "enemy_reinforce_01_demo"), "the arrived enemy reinforcement acted in a replayed slot")
	var shown_end: Array = td.lab.visible_end
	shown_end.sort()
	h.expect(shown_end.size() == 10, "round 3: all ten units shown " + str(shown_end))
	h.expect(h.deferred_frames > 0, "arrivals were held back while the enemy replay was still running (%d frames)" % h.deferred_frames)
	print("[M4D_DEFAULT_ROUNDS] counts(round,shown,engine)=", td.lab.counts, " arrivals=", arrivals.map(func(e): return [e.round, e.unit_id, e.cell]))
	print("[M4D_DEFAULT_ROUNDS] writes=", td.writes)
	print("[M4D_DEFAULT_ROUNDS] checks=", h.checks, " display_checks=", h.display_checks, " failures=", h.failures)
	quit(0 if h.failures.is_empty() else 1)
