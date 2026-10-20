extends "res://tests/scripts/test_battle3d_wait_equivalence.gd"
# M3-b: untouched default 18x10 battle (no fixture). 3D input only: first ally
# moves + confirms facing + waits, the others wait; every enemy slot is
# replayed; the round must reach 2. Compared with the same commands sent to an
# engine without 3D, with the M3 per-case checks reused.
const GOLDEN := "res://tests/golden/battle3d_m3_start_v0.json"
const FIRST_MOVE := Vector2i(4,8)

func direct_round() -> Dictionary:
	var host = await h.open_bare(self)
	var battle: Node = host.battle
	for step in range(3):
		var active = battle.get("active_unit_state")
		battle.call("_select_ally_unit", active, false, false, false)
		if step == 0:
			battle.call("_try_direct_move_to_cell", FIRST_MOVE)
			for i in range(1800):
				await process_frame
				if battle.get("current_phase") == "facing_select" and not battle.get("is_demo_animating"): break
			battle.call("_select_post_move_facing", "right")
		battle.call("_end_ally_turn_by_wait")
		await h.settle_bare(self, battle, "direct step " + str(step))
	var result: Dictionary = h.final_state(battle)
	await h.close_bare(self, host)
	return result

func lab_round(golden: Dictionary) -> Dictionary:
	h.frames.clear()
	await h.open_lab(self)
	var lab = h.lab
	var battle: Node = lab.engine
	var start := {"units":h.fingerprint.fingerprint_units(battle.get("all_battle_unit_states")), "controller":h.oracle.controller_state(battle)}
	h.expect(h.fingerprint.diff(golden.layouts.default, start).is_empty(), "default start equals golden (no fixture)")
	var waited := []
	for step in range(3):
		var active = battle.active_unit_state
		h.expect(active != null and active.side == "ally" and not active.has_acted, "step %d: engine offers an unacted ally" % step)
		h.click(active.grid_cell)
		if step == 0:
			h.click(FIRST_MOVE)
			await h.wait_for(self, "facing_select")
			lab._sync_views()
			h.expect(lab.wait_button.disabled and lab.wait_button.tooltip_text.begins_with("행동 불가"), "wait disabled while facing must be confirmed")
			for button in lab.facing_ui.get_children():
				if button.text == "방향 right": button.pressed.emit()
		lab._sync_views()
		h.expect(not lab.wait_button.disabled, "step %d: wait enabled" % step)
		waited.append(active.unit_id)
		h.press_wait()
		h.expect(lab.status.text.begins_with("대기 · " + active.unit_id), "step %d: wait accepted and shown" % step)
		await h.settle_lab(self, "3D step " + str(step))
		lab._sync_views()
		print("[M3B_DEFAULT_ROUND] step ", step, " waited=", active.unit_id, " round=", battle.battle_round, " lab_round=", lab.current_round, " enemy_events=", battle.enemy_action_event_log.export().size())
	h.expect(battle.battle_round == 2 and lab.current_round == 2, "round 2 reached in the default layout")
	h.expect(lab.turn_label.text.begins_with("라운드 2 · 아군 턴"), "turn label shows round 2 " + lab.turn_label.text)
	h.expect(waited.size() == 3 and waited[0] != waited[1] and waited[1] != waited[2], "three different allies acted " + str(waited))
	for badge in lab.action_badges.get_children():
		if badge.visible: h.expect(badge.text == "미행동", "round 2 badge reset from engine flags " + badge.get_meta("unit_id"))
	var result: Dictionary = h.final_state(battle)
	result["lab"] = h.lab_view()
	result["waited"] = waited
	return result

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_wait_harness.gd").new()
	var golden: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(GOLDEN))
	var t0 := Time.get_ticks_msec()
	var direct: Dictionary = await direct_round()
	var td: Dictionary = await lab_round(golden)
	h.roles_ids = {"enemy":h.roles(h.lab.engine).enemy.unit_id}
	var defend: int = h.lab.engine.defend_calls
	await h.close_lab(self)
	h.expect(direct.writes == td.writes, "same write sequence " + str(td.writes))
	h.expect(td.writes.count("_end_ally_turn_by_wait") == 3 and defend == 0, "three waits, no defend")
	for call in td.writes: h.expect(SEVEN.has(call), "write within the seven commands " + call)
	var slots: int = td.logs.enemy_action_event_log.filter(func(e): return e.kind == "enemy_actor_selected").size()
	h.expect(slots == 3 and td.lab.summaries.size() == 3, "three enemy slots replayed and summarised")
	h.expect(td.logs.enemy_action_event_log[-1].kind == "round_started" and td.logs.enemy_action_event_log[-1].round == 2, "last enemy event is round_started 2")
	check_case("default_round", without_wait(direct), without_wait(td))
	var kinds := []
	for event in td.logs.enemy_action_event_log: kinds.append(event.kind)
	print("[M3B_DEFAULT_ROUND] waited=", td.waited, " writes=", td.writes, " enemy_events=", kinds, " ms=", Time.get_ticks_msec() - t0)
	print("[M3B_DEFAULT_ROUND] checks=", h.checks, " failures=", h.failures)
	quit(0 if h.failures.is_empty() else 1)
