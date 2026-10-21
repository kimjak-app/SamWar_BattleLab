extends "res://tests/scripts/test_battle3d_strategy_equivalence.gd"
# M4-b: untouched default 18x10 battle (no fixture). No ally can reach a
# strategy target in round 1 (pre-check 4), so 3D input only: round 1 all
# three allies wait (strategy button disabled: no enemy in range); round 2 the
# first ally waits, the second moves to the first reachable cell with an enemy
# in strategy range, confirms facing and uses strategy on the engine's first
# target; every other ally (incl. the round-2 reinforcement) waits -> round 3.
# Compared with the same commands sent to an engine without 3D (the dice is
# forced by the S4-1 test hook on both paths). The M3 per-case helper is not
# reused here: its last-summary skill check assumes one enemy slot, while this
# round has several (enemies use skills in round 2); the same comparisons are
# made directly below.
const GOLDEN := "res://tests/golden/battle3d_m3_start_v0.json"

func strategy_cell(battle: Node, unit: BattleUnitState) -> Vector2i:
	# Test-side choice only (same rule on both paths): first reachable cell, in
	# x/y order, within the unit's strategy range (engine value) of a live enemy.
	var q = load("res://scripts/battle3d/battle3d_movement_adapter.gd").new()
	q.grid = battle.battle_grid_controller
	for u in battle.all_battle_unit_states: q.alive_units.append(u)
	var cells: Array = q.query(unit.unit_id, unit.grid_cell).get("reachable", {}).keys()
	cells.sort_custom(func(a, b): return a.x < b.x or (a.x == b.x and a.y < b.y))
	var reach: int = battle.call("_get_strategy_range", unit)
	for cell in cells:
		for e in battle.all_battle_unit_states:
			if e.side == "enemy" and e.is_alive() and battle.call("_is_unit_state_available_for_battle_slot", e) and absi(e.grid_cell.x - cell.x) + absi(e.grid_cell.y - cell.y) <= reach:
				return cell
	return Vector2i(-1, -1)

const STRATEGY_STEP := 4

func plan(step: int) -> String:
	return "strategy" if step == STRATEGY_STEP else "wait"

func direct_round() -> Dictionary:
	var host = await h.open_bare(self)
	var battle: Node = host.battle
	battle.strategy_roll_override = h.forced_roll(true, 1)
	for step in range(10):
		if battle.get("battle_round") >= 3: break
		var active = battle.get("active_unit_state")
		battle.call("_select_ally_unit", active, false, false, false)
		if plan(step) == "strategy":
			battle.call("_try_direct_move_to_cell", strategy_cell(battle, active))
			for i in range(1800):
				await process_frame
				if battle.get("current_phase") == "facing_select" and not battle.get("is_demo_animating"): break
			battle.call("_select_post_move_facing", "right")
			battle.call("_on_strategy_button_pressed")
			battle.call("_try_use_strategy_on_target", battle.call("_get_strategy_targets", active)[0])
		else:
			battle.call("_end_ally_turn_by_wait")
		await h.settle_bare(self, battle, "direct step " + str(step))
	var result: Dictionary = h.final_state(battle)
	result["tactic"] = battle.get("tactic_event_log").export()
	await h.close_bare(self, host)
	return result

func lab_round(golden: Dictionary) -> Dictionary:
	h.frames.clear()
	await h.open_lab(self)
	var lab = h.lab
	var battle: Node = lab.engine
	var start := {"units":h.fingerprint.fingerprint_units(battle.get("all_battle_unit_states")), "controller":h.oracle.controller_state(battle)}
	h.expect(h.fingerprint.diff(golden.layouts.default, start).is_empty(), "default start equals golden (no fixture)")
	battle.strategy_roll_override = h.forced_roll(true, 1)
	lab._sync_views()
	for step in range(10):
		if battle.battle_round >= 3: break
		var active = battle.active_unit_state
		h.click(active.grid_cell)
		lab._sync_views()
		if plan(step) == "strategy":
			h.click(strategy_cell(battle, active))
			await h.wait_for(self, "facing_select")
			for button in lab.facing_ui.get_children():
				if button.text == "방향 right": button.pressed.emit()
			lab._sync_views()
			h.expect(not lab.strategy_button.disabled, "round 2: strategy enabled after moving into range")
			h.press_strategy()
			h.expect(battle.current_phase == "strategy" and not lab.strategy_target_ids.is_empty(), "strategy targets shown " + str(lab.strategy_target_ids))
			h.click(battle.call("_get_strategy_targets", active)[0].grid_cell)
			h.expect(lab.tactic_texts.any(func(x): return x.begins_with("책략 성공")), "strategy result shown from the event")
		else:
			if step == 0:
				# Round 1: no enemy in strategy range (engine target query) -> refused, no engine call.
				var writes: int = battle.writes.size()
				h.expect(lab.strategy_button.disabled and lab.strategy_button.tooltip_text.begins_with("책략 불가 · 사거리 안에 적이 없습니다"), "round 1: strategy disabled with the range reason")
				h.press_strategy()
				h.expect(battle.writes.size() == writes, "round 1: refused strategy sends nothing")
			h.press_wait()
		await h.settle_lab(self, "3D step " + str(step), h.strategy_display_probe)
		lab._sync_views()
		print("[M4B_DEFAULT_ROUND] step ", step, " ", plan(step), "=", active.unit_id, " round=", battle.battle_round, " lab_round=", lab.current_round, " tactic=", battle.tactic_event_log.export().size())
	h.expect(battle.battle_round == 3 and lab.current_round == 3, "round 3 reached in the default layout")
	h.expect(battle.tactic_event_log.export().any(func(e): return e.kind.begins_with("skill_")), "the log also holds enemy skill events (skipped)")
	var result: Dictionary = h.final_state(battle)
	result["tactic"] = battle.get("tactic_event_log").export()
	result["lab"] = h.lab_view()
	result["lab"]["tactic_cursor"] = lab.tactic_cursor
	result["lab"]["presentations"] = lab.tactic_presentations.duplicate(true)
	result["lab"]["tactic_texts"] = lab.tactic_texts.duplicate()
	result["lab"]["pending_ticks"] = lab.pending_enemy_ticks.duplicate(true)
	return result

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_strategy_harness.gd").new()
	var golden: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(GOLDEN))
	var direct: Dictionary = await direct_round()
	var td: Dictionary = await lab_round(golden)
	h.roles_ids = {"enemy":h.roles(h.lab.engine).enemy.unit_id}
	await h.close_lab(self)
	h.expect(direct.writes == td.writes, "same write sequence " + str(td.writes))
	for call in td.writes: h.expect(h.TEN.has(call), "write within the ten commands " + call)
	h.expect(direct.tactic == td.tactic, "tactic_event_log equal")
	var d: Dictionary = without_new_commands(direct)
	var t3: Dictionary = without_new_commands(td)
	h.expect(h.fingerprint.diff(d.units, t3.units).is_empty(), "40-field units equal " + str(h.fingerprint.diff(d.units, t3.units)))
	h.expect(h.fingerprint.diff(d.controller, t3.controller).is_empty(), "controller equal")
	for name in d.logs: h.expect(d.logs[name] == t3.logs[name], name + " equal")
	var events: Array = td.logs.enemy_action_event_log
	h.expect(td.lab.cursors == [td.logs.ally_move_event_log.size(), td.logs.battle_action_event_log.size(), events.size()], "three cursors at their own log ends")
	h.expect(td.lab.enemy_played_paths == events.filter(func(e): return e.kind == "enemy_moved").map(func(e): return e.path), "every enemy path replayed in order")
	h.expect(td.lab.hits == events.filter(func(e): return e.kind == "enemy_attack_resolved"), "hit presentations equal attack events")
	h.expect(td.lab.summaries.size() == events.filter(func(e): return e.kind == "enemy_actor_selected").size(), "one summary per enemy slot")
	h.expect(td.lab.tactic_cursor == td.tactic.size(), "fourth cursor at the log end")
	h.expect(td.lab.presentations == td.tactic.filter(func(e): return e.kind in ["strategy_cast", "status_tick"]), "strategy_cast/status_tick presented once each, reinforcements skipped")
	h.expect(td.tactic.any(func(e): return e.kind == "reinforcement_arrived"), "the log also holds reinforcement events (skipped)")
	print("[M4B_DEFAULT_ROUND] writes=", td.writes, " tactic=", td.tactic.map(func(e): return e.kind))
	print("[M4B_DEFAULT_ROUND] checks=", h.checks, " failures=", h.failures)
	quit(0 if h.failures.is_empty() else 1)
