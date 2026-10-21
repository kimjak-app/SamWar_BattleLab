extends "res://tests/scripts/test_battle3d_defend_equivalence.gd"
# M4-a: untouched default 18x10 battle (no fixture). 3D input only: first ally
# moves + confirms facing + waits, the other two defend; every enemy slot is
# replayed; the round must reach 2. Compared with the same commands sent to an
# engine without 3D, with the M3 per-case checks reused. The "방어 중" display
# is checked against the engine every frame (after defend, during enemy slots,
# after the new round).
const GOLDEN := "res://tests/golden/battle3d_m3_start_v0.json"
const FIRST_MOVE := Vector2i(4,8)
const PLAN := ["move_wait", "defend", "defend"]

func direct_round() -> Dictionary:
	var host = await h.open_bare(self)
	var battle: Node = host.battle
	for step in range(3):
		var active = battle.get("active_unit_state")
		battle.call("_select_ally_unit", active, false, false, false)
		if PLAN[step] == "move_wait":
			battle.call("_try_direct_move_to_cell", FIRST_MOVE)
			for i in range(1800):
				await process_frame
				if battle.get("current_phase") == "facing_select" and not battle.get("is_demo_animating"): break
			battle.call("_select_post_move_facing", "right")
			battle.call("_end_ally_turn_by_wait")
		else:
			battle.call("_on_defend_button_pressed")
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
	var acted := []
	var defenders := []
	for step in range(3):
		var active = battle.active_unit_state
		h.expect(active != null and active.side == "ally" and not active.has_acted, "step %d: engine offers an unacted ally" % step)
		h.click(active.grid_cell)
		if PLAN[step] == "move_wait":
			h.click(FIRST_MOVE)
			await h.wait_for(self, "facing_select")
			lab._sync_views()
			h.expect(lab.defend_button.disabled and lab.wait_button.disabled, "defend and wait disabled while facing must be confirmed")
			for button in lab.facing_ui.get_children():
				if button.text == "방향 right": button.pressed.emit()
		lab._sync_views()
		h.expect(not lab.defend_button.disabled and not lab.wait_button.disabled, "step %d: defend and wait enabled" % step)
		acted.append(active.unit_id)
		if PLAN[step] == "move_wait":
			h.press_wait()
			h.expect(lab.status.text.begins_with("대기 · " + active.unit_id), "step %d: wait accepted and shown" % step)
		else:
			h.press_defend()
			defenders.append(active.unit_id)
			h.expect(lab.status.text.begins_with("방어 · " + active.unit_id), "step %d: defend accepted and shown" % step)
			h.display_probe(self)
			for badge in lab.action_badges.get_children():
				if badge.get_meta("unit_id") == active.unit_id and battle.battle_round == 1:
					h.expect(badge.text == "행동 완료 · 방어 중", "step %d: defender badge right after defend: %s" % [step, badge.text])
		await h.settle_lab(self, "3D step " + str(step), h.display_probe)
		lab._sync_views()
		var defending_now := []
		for id in defenders:
			if lab.queries.find_unit(id).is_defending: defending_now.append(id)
		print("[M4A_DEFAULT_ROUND] step ", step, " ", PLAN[step], "=", active.unit_id, " round=", battle.battle_round, " lab_round=", lab.current_round, " engine_defending=", defending_now, " enemy_events=", battle.enemy_action_event_log.export().size())
		if step == 1: h.expect(defending_now == [active.unit_id] and battle.battle_round == 1, "step 1: defender still defending after its enemy slot (round 1)")
	h.expect(battle.battle_round == 2 and lab.current_round == 2, "round 2 reached in the default layout")
	h.expect(lab.turn_label.text.begins_with("라운드 2 · 아군 턴"), "turn label shows round 2 " + lab.turn_label.text)
	h.expect(acted.size() == 3 and acted[0] != acted[1] and acted[1] != acted[2], "three different allies acted " + str(acted))
	for badge in lab.action_badges.get_children():
		if badge.visible: h.expect(badge.text == "미행동", "round 2 badge reset from engine flags (no 방어 중) " + badge.get_meta("unit_id") + " " + badge.text)
	h.expect(not lab.info.text.contains("방어 중"), "round 2 unit panel shows no defend")
	var result: Dictionary = h.final_state(battle)
	result["lab"] = h.lab_view()
	result["acted"] = acted
	return result

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_defend_harness.gd").new()
	var golden: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(GOLDEN))
	var t0 := Time.get_ticks_msec()
	var direct: Dictionary = await direct_round()
	var td: Dictionary = await lab_round(golden)
	h.roles_ids = {"enemy":h.roles(h.lab.engine).enemy.unit_id}
	await h.close_lab(self)
	h.expect(direct.writes == td.writes, "same write sequence " + str(td.writes))
	h.expect(td.writes.count("_on_defend_button_pressed") == 2 and td.writes.count("_end_ally_turn_by_wait") == 1, "two defends, one wait")
	for call in td.writes: h.expect(EIGHT.has(call), "write within the eight commands " + call)
	var slots: int = td.logs.enemy_action_event_log.filter(func(e): return e.kind == "enemy_actor_selected").size()
	h.expect(slots == 3 and td.lab.summaries.size() == 3, "three enemy slots replayed and summarised")
	h.expect(td.logs.enemy_action_event_log[-1].kind == "round_started" and td.logs.enemy_action_event_log[-1].round == 2, "last enemy event is round_started 2")
	for id in td.acted.slice(1):
		h.expect(td.lab.combat_lines.has("방어 · " + id), "combat log has defend line for " + id)
	check_case("default_round", without_end_commands(direct), without_end_commands(td))
	var kinds := []
	for event in td.logs.enemy_action_event_log: kinds.append(event.kind)
	print("[M4A_DEFAULT_ROUND] acted=", td.acted, " writes=", td.writes, " enemy_events=", kinds, " ms=", Time.get_ticks_msec() - t0)
	print("[M4A_DEFAULT_ROUND] checks=", h.checks, " display_checks=", h.display_checks, " failures=", h.failures)
	quit(0 if h.failures.is_empty() else 1)
