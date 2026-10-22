extends "res://tests/scripts/test_battle3d_skill_equivalence.gd"
# M4-c1: untouched default 18x10 battle (no fixture). Round 1: the first ally
# the engine allows to use its unique skill (momentum 3: jeong_dojeon or
# gwon_yul, self_area) uses it through 3D input (button -> click the engine's
# best target); every other ally waits; the enemy slots replay -> round 2.
# yi_sunsin (cost 4) is refused by guidance with the engine's momentum values.
# Compared with the same commands sent to an engine without 3D.
const GOLDEN := "res://tests/golden/battle3d_m3_start_v0.json"

func wants_skill(battle: Node, used: bool) -> bool:
	# Test-side plan, same rule on both paths: the first ally the engine lets use its skill.
	return not used and battle.call("_can_use_unique_skill", battle.get("active_unit_state"))

func direct_round() -> Dictionary:
	var host = await h.open_bare(self)
	var battle: Node = host.battle
	var used := ""
	for step in range(10):
		if battle.get("battle_round") >= 2: break
		var active = battle.get("active_unit_state")
		battle.call("_select_ally_unit", active, false, false, false)
		if wants_skill(battle, not used.is_empty()):
			used = active.unit_id
			var target: BattleUnitState = h.chosen_target(battle, active)
			battle.call("_on_unique_skill_button_pressed")
			if not h.is_auto(battle, active): battle.call("_try_use_unique_skill_on_target", target)
		else:
			battle.call("_end_ally_turn_by_wait")
		await h.settle_bare(self, battle, "direct step " + str(step))
	var result: Dictionary = h.final_state(battle)
	result["tactic"] = battle.get("tactic_event_log").export()
	result["used"] = used
	await h.close_bare(self, host)
	return result

func lab_round(golden: Dictionary) -> Dictionary:
	h.frames.clear()
	h.label_seen.clear()
	await h.open_lab(self)
	var lab = h.lab
	var battle: Node = lab.engine
	var start := {"units":h.fingerprint.fingerprint_units(battle.get("all_battle_unit_states")), "controller":h.oracle.controller_state(battle)}
	h.expect(h.fingerprint.diff(golden.layouts.default, start).is_empty(), "default start equals golden (no fixture)")
	lab._sync_views()
	h.expect(lab.momentum_label.text == "기세 아군 3 / 적 3", "momentum HUD at start from the engine " + lab.momentum_label.text)
	var used := ""
	for step in range(10):
		if battle.battle_round >= 2: break
		var active = battle.active_unit_state
		h.click(active.grid_cell)
		lab._sync_views()
		var skill: Dictionary = battle.call("_get_unique_skill_for_unit", active)
		var momentum: int = battle.battle_momentum.get_value("ally")
		if wants_skill(battle, not used.is_empty()):
			used = active.unit_id
			h.expect(not lab.skill_button.disabled, "skill enabled for " + active.unit_id)
			var target: BattleUnitState = h.chosen_target(battle, active)
			h.press_skill()
			h.expect(battle.current_phase == "unique_skill_target_select" and lab.skill_target_ids.has(target.unit_id), "skill targets shown " + str(lab.skill_target_ids))
			h.click(target.grid_cell)
			h.expect(lab.skill_texts.size() > 0 and lab.skill_texts[0].begins_with("특기 · " + active.unit_id), "skill cast shown from the event " + str(lab.skill_texts))
		else:
			if used.is_empty() and momentum < int(skill.momentum_cost):
				var writes: int = battle.writes.size()
				var reason := "특기 불가 · 기세가 부족합니다 (필요 %d / 현재 %d)" % [int(skill.momentum_cost), momentum]
				h.expect(lab.skill_button.disabled and lab.skill_button.tooltip_text == reason, active.unit_id + " refused with the engine momentum values: " + lab.skill_button.tooltip_text)
				h.press_skill()
				h.expect(battle.writes.size() == writes and lab.status.text == "거절 / " + reason, active.unit_id + " refused skill sends nothing")
			h.press_wait()
		await h.settle_lab(self, "3D step " + str(step), h.skill_display_probe)
		lab._sync_views()
		print("[M4C1_DEFAULT_ROUND] step ", step, " ", active.unit_id, " skill=", active.unit_id == used, " round=", battle.battle_round, " lab_round=", lab.current_round, " momentum=", lab.momentum_label.text)
	h.expect(used in ["jeong_dojeon", "gwon_yul"], "round 1 skill used by jeong_dojeon or gwon_yul: " + used)
	h.expect(battle.battle_round == 2 and lab.current_round == 2, "round 2 reached in the default layout")
	var result: Dictionary = h.final_state(battle)
	result["tactic"] = battle.get("tactic_event_log").export()
	result["used"] = used
	result["lab"] = h.skill_lab_view()
	return result

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_skill_harness.gd").new()
	var golden: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(GOLDEN))
	var direct: Dictionary = await direct_round()
	var td: Dictionary = await lab_round(golden)
	var battle: Node = h.lab.engine
	var sides := {}
	var skill_names := {}
	for u in battle.all_battle_unit_states:
		sides[u.unit_id] = u.side
		if not u.unique_skill_definition.is_empty(): skill_names[u.unique_skill_definition.skill_id] = u.unique_skill_definition.display_name
	h.roles_ids = {"enemy":h.roles(battle).enemy.unit_id}
	await h.close_lab(self)
	h.expect(direct.used == td.used, "same ally used the skill on both paths")
	h.expect(direct.writes == td.writes, "same write sequence " + str(td.writes))
	for call in td.writes: h.expect(h.TWELVE.has(call), "write within the twelve commands " + call)
	h.expect(direct.tactic == td.tactic, "tactic_event_log equal")
	var d: Dictionary = without_new_commands(direct)
	var t3: Dictionary = without_new_commands(td)
	h.expect(h.fingerprint.diff(d.units, t3.units).is_empty(), "40-field units equal " + str(h.fingerprint.diff(d.units, t3.units)))
	h.expect(h.fingerprint.diff(d.controller, t3.controller).is_empty(), "controller equal")
	for name in d.logs: h.expect(d.logs[name] == t3.logs[name], name + " equal")
	var events: Array = td.logs.enemy_action_event_log
	h.expect(td.lab.cursors == [td.logs.ally_move_event_log.size(), td.logs.battle_action_event_log.size(), events.size()], "three cursors at their own log ends")
	h.expect(td.lab.enemy_played_paths == events.filter(func(e): return e.kind == "enemy_moved").map(func(e): return e.path), "every enemy path replayed in order")
	h.expect(td.lab.summaries.size() == events.filter(func(e): return e.kind == "enemy_actor_selected").size(), "one summary per enemy slot")
	h.expect(td.lab.tactic_cursor == td.tactic.size(), "fourth cursor at the log end")
	var ally_events: Array = h.ally_skill_events(td.tactic, sides)
	h.expect(td.lab.skill_presentations == ally_events and not ally_events.is_empty(), "allied skill events presented once each, enemy skills skipped")
	var expected: Dictionary = h.expected_display(ally_events, skill_names)
	h.expect(td.lab.skill_texts == expected.lines, "skill lines from the events " + str(td.lab.skill_texts))
	h.expect(h.sorted_pairs(td.lab.labels) == h.sorted_pairs(expected.labels), "Label3D texts from the events " + str(h.sorted_pairs(td.lab.labels)))
	h.expect(td.lab.momentum_text == "기세 아군 %d / 적 %d%s" % [td.controller.ally_momentum, td.controller.enemy_momentum, "" if expected.note == "" else " · " + expected.note], "momentum HUD at the end " + td.lab.momentum_text)
	print("[M4C1_DEFAULT_ROUND] used=", td.used, " writes=", td.writes, " tactic=", td.tactic.map(func(e): return e.kind))
	print("[M4C1_DEFAULT_ROUND] checks=", h.checks, " display_checks=", h.display_checks, " momentum_checks=", h.momentum_checks, " failures=", h.failures)
	quit(0 if h.failures.is_empty() else 1)
