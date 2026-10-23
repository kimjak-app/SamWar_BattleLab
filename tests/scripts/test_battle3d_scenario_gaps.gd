extends SceneTree
# NIGHT3 test gaps (M5-b scenario shell). G5: [다시 시작] frees the old lab at
# once and the new engine has already read the start setup, in the same frame
# (no frame wait). G6: the result overlay stays hidden while the last enemy
# action is still replayed, and shows once the replay queue is empty. G7: a
# result before the reinforcements arrive counts only the deployed allies
# (fixture: weakened enemies next to the allies, battle won in round 1).
var h

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_scenario_harness.gd").new()
	await h.open_shell(self)

	# G5: same-frame restart.
	await h.press_scenario(self, "win_practice")
	var old_lab = h.shell.lab
	var old_engine: Node = old_lab.engine
	h.shell.restart_button.pressed.emit() # no frame in between
	var new_lab = h.shell.lab
	var guan: BattleUnitState = null
	if new_lab != null and is_instance_valid(new_lab) and new_lab.engine != null:
		for u in new_lab.engine.all_battle_unit_states:
			if u.unit_id == "guan_yu": guan = u
	h.expect(not is_instance_valid(old_lab) and not is_instance_valid(old_engine), "G5 the old lab and engine are gone in the same frame")
	h.expect(new_lab != old_lab and guan != null and guan.current_troops == 25 and not Engine.has_meta(h.SETUP_KEY), "G5 the new engine read the setup at once (guan_yu %s)" % [str(guan.current_troops) if guan != null else "missing"])
	await h.wait_lab(self)

	# G7: result in round 1, before any reinforcement arrives.
	var b: Node = h.lab.engine
	var units: Array[BattleUnitState] = b.all_battle_unit_states
	# Every weakened enemy is next to the infantry gwon_yul (range 1) and within the archers' range 3.
	var cells := {5:Vector2i(4,3), 6:Vector2i(6,3), 7:Vector2i(5,2)}
	var ally_cells := {0:Vector2i(5,4), 1:Vector2i(5,5), 2:Vector2i(5,3)}
	for i in ally_cells: units[i].set_grid_cell(ally_cells[i])
	for i in cells:
		units[i].set_grid_cell(cells[i])
		units[i].current_hp = 1
		units[i].current_troops = 1
	for u in units: b.call("_sync_resumed_unit_markers_to_grid", u)
	b.call("_sync_demo_positions")
	h.lab._sync_views()
	for i in range(2): h.lab.speed_button.pressed.emit()
	seed(1)
	h.press_auto()
	for i in range(30000):
		await process_frame
		if h.shell.result_panel.visible: break
	var reinforcements := units.filter(func(u): return u.side == "ally" and u.unit_id.contains("reinforce"))
	var deployed_allies := units.filter(func(u): return u.side == "ally" and u.current_troops > 0 and b._is_unit_state_available_for_battle_slot(u)).size()
	h.expect(b.battle_round == 1 and h.lab.battle_result == "victory", "G7 fixture: victory in round 1 (round %d, %s)" % [b.battle_round, h.lab.battle_result])
	h.expect(reinforcements.size() == 2 and reinforcements.all(func(u): return not b._is_unit_state_available_for_battle_slot(u) and u.current_troops > 0), "G7 the two ally reinforcements are not deployed yet (and have troops)")
	h.expect(h.shell.result_label.text == "승리 · 라운드 1 · 생존 아군 %d부대" % deployed_allies and deployed_allies == 3, "G7 overlay counts deployed allies only: " + h.shell.result_label.text)
	h.shell.choose_button.pressed.emit()
	await process_frame

	# G6: default battle, 3D waits until the engine defeats the allies (round 6); the overlay waits for the replay.
	await h.press_scenario(self, "default")
	b = h.lab.engine
	Engine.time_scale = 4.0
	seed(1)
	var busy_after_result := 0
	var shown_while_busy := 0
	for i in range(60000):
		await process_frame
		if not h.lab.battle_result.is_empty():
			if h.lab._enemy_presentation_busy():
				busy_after_result += 1
				if h.shell.result_panel.visible: shown_while_busy += 1
			elif h.shell.result_panel.visible:
				break
		elif b.current_phase == "ally_turn" and not b.is_demo_animating and not h.lab._enemy_presentation_busy() and not h.lab.wait_button.disabled:
			h.lab.wait_button.pressed.emit()
	Engine.time_scale = 1.0
	h.expect(h.lab.battle_result == "defeat" and busy_after_result > 0, "G6 fixture: the engine result arrives while the 3D still replays (%d busy frames)" % busy_after_result)
	h.expect(shown_while_busy == 0 and h.shell.result_panel.visible, "G6 overlay hidden during the replay (%d frames shown while busy), shown after" % shown_while_busy)

	await h.close_shell(self)
	print("[SCENARIO_GAPS] checks=", h.checks, " failures=", h.failures)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
