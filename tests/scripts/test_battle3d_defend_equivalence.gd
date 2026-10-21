extends "res://tests/scripts/test_battle3d_enemy_turn_equivalence.gd"
# M4-a: an ally slot ended by the engine's defend command, 3D input vs engine
# direct. Reuses every M3 per-case check (40 fields, 12 controller values,
# three logs, playback, hits, summaries) and adds the eight-command contract,
# the engine-read defend display and the engine-only recovery.
const EIGHT := ["_select_ally_unit", "_try_direct_move_to_cell", "_select_post_move_facing", "_handle_right_click_cancel", "try_basic_attack", "_try_attack_enemy_target_from_attack_select", "_end_ally_turn_by_wait", "_on_defend_button_pressed"]

func case_labels() -> Array:
	return load("res://tests/scripts/support/battle3d_defend_harness.gd").DEFEND_CASES

func without_end_commands(state: Dictionary) -> Dictionary:
	var copy := state.duplicate(true)
	copy.writes = copy.writes.filter(func(call): return call != "_end_ally_turn_by_wait" and call != "_on_defend_button_pressed")
	return copy

func attacks_on(state: Dictionary, unit_id: String) -> Array:
	return state.logs.enemy_action_event_log.filter(func(e): return e.kind == "enemy_attack_resolved" and e.target_id == unit_id)

func defending_after(state: Dictionary, unit_id: String) -> bool:
	for unit in state.units:
		if unit.unit_id == unit_id: return unit.is_defending
	return false

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_defend_harness.gd").new()
	var labels: Array = case_labels()
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--case="): labels = [arg.trim_prefix("--case=")]
	var direct_by_label := {}
	for label in labels:
		var t0 := Time.get_ticks_msec()
		var direct: Dictionary = await h.run_defend_direct(self, label)
		var td: Dictionary = await h.run_defend_3d(self, label)
		h.roles_ids = {"enemy":h.roles(h.lab.engine).enemy.unit_id}
		var defend_calls: int = h.lab.engine.defend_calls
		await h.close_lab(self)
		direct_by_label[label] = direct
		var id: String = td.defender
		h.expect(direct.writes == td.writes, label + " same eight-command write sequence " + str(td.writes))
		h.expect(td.writes.count("_on_defend_button_pressed") == 1 and defend_calls == 1, label + " exactly one defend call")
		h.expect(not td.writes.has("_end_ally_turn_by_wait"), label + " defend is not sent as wait")
		for call in td.writes: h.expect(EIGHT.has(call), label + " write within the eight commands " + call)
		h.expect(td.lab.combat_lines.has("방어 · " + id), label + " defend shown in combat log")
		# An instant enemy slot (e.g. the enemy only waits) can finish inside the
		# defend call and start a new round, which already reset is_defending and
		# has_acted; the 3D side still accepted it (combat line above).
		var instant_round: bool = td.after_call.round > 1 and not td.after_call.acted and not td.after_call.defending
		h.expect((td.after_call.defending and td.after_call.acted) or instant_round, label + " engine marked the unit defending and acted (or an instant new round reset it)")
		if label == "D4_full_hp_defend_no_recovery": h.expect(instant_round, label + " instant enemy wait: new round already reset is_defending, still accepted")
		h.expect(td.recovered == direct.recovered and td.after_call == direct.after_call, label + " recovery equals engine direct (%d vs %d)" % [td.recovered, direct.recovered])
		# Defend itself records nothing in the ally logs (pre-check 1).
		var killed_ids := []
		for event in td.logs.enemy_action_event_log:
			if event.kind == "enemy_attack_resolved" and event.killed: killed_ids.append(event.target_id)
		for event in td.logs.ally_move_event_log:
			h.expect(event.kind in ["unit_moved", "facing_changed", "move_confirmed"], label + " defend adds no ally_move event (" + event.kind + ")")
		for event in td.logs.battle_action_event_log:
			h.expect(event.kind == "unit_defeated" and killed_ids.has(event.unit_id), label + " defend adds no battle_action event (" + event.kind + ")")
		check_case(label, without_end_commands(direct), without_end_commands(td))
		var round_started: Array = td.logs.enemy_action_event_log.filter(func(e): return e.kind == "round_started")
		match label:
			"D1_defend_unmoved_enemy_attacks":
				h.expect(attacks_on(td, id).size() == 1, label + " enemy slot attacks the defender")
			"D3_wounded_defend_recovers":
				h.expect(td.recovered > 0 and td.after_call.troops == 140 + td.recovered, label + " wounded unit recovered troops from the engine (%d)" % td.recovered)
			"D2_move_facing_defend":
				h.expect(td.after_call.acted and td.writes.has("_select_post_move_facing"), label + " defend accepted right after move + facing")
			"D5_last_ally_defend_round_reset":
				h.expect(not round_started.is_empty() and td.lab.round == 2, label + " round 2 started")
				h.expect(not defending_after(td, id), label + " is_defending reset by the engine at the new round")
			"D6_defend_other_unit_attacked":
				h.expect(attacks_on(td, id).is_empty() and not attacks_on(td, td.units[0].unit_id).is_empty(), label + " a non-defending unit is attacked")
			"D7_defend_enemy_moves_waits_default":
				var kinds: Array = td.logs.enemy_action_event_log.map(func(e): return e.kind)
				h.expect(kinds.has("enemy_moved") and kinds.has("enemy_waited") and round_started.is_empty(), label + " enemy moved and waited, round 1 continues " + str(kinds))
				h.expect(defending_after(td, id) and td.lab.round == 1, label + " defending kept through the enemy slot within the round")
		if label in ["D1_defend_unmoved_enemy_attacks", "D4_full_hp_defend_no_recovery"]:
			h.expect(td.recovered == 0, label + " full-hp defend recovers 0")
		var kinds := []
		for event in td.logs.enemy_action_event_log: kinds.append(event.kind)
		print("[M4A_DEFEND_CASE] ", label, " defender=", id, " recovered=", td.recovered, " writes=", td.writes, " enemy_events=", kinds, " round=", td.lab.round, " ms=", Time.get_ticks_msec() - t0, " failures=", h.failures.size())
		if not h.failures.is_empty(): break
	# Engine direct only: same fixture (M6), defend vs wait. The reduced damage is
	# produced by the engine; the 3D side only shows damage_applied.
	if direct_by_label.has("D1_defend_unmoved_enemy_attacks") and h.failures.is_empty():
		var waited: Dictionary = await h.run_wait_direct(self, "W1_wait_unmoved_enemy_attacks")
		var defended: Dictionary = direct_by_label["D1_defend_unmoved_enemy_attacks"]
		var id: String = defended.defender
		var d_hit: Array = attacks_on(defended, id)
		var w_hit: Array = attacks_on(waited, id)
		h.expect(d_hit.size() == 1 and w_hit.size() == 1, "engine direct: both runs have one enemy attack on " + id)
		if d_hit.size() == 1 and w_hit.size() == 1:
			h.expect(d_hit[0].damage_applied < w_hit[0].damage_applied, "engine direct: defended damage %d < undefended damage %d" % [d_hit[0].damage_applied, w_hit[0].damage_applied])
			print("[M4A_DEFEND_DAMAGE] engine direct M6 fixture: defended=", d_hit[0].damage_applied, " undefended=", w_hit[0].damage_applied)
	print("[M4A_DEFEND_EQUIVALENCE] checks=", h.checks, " display_checks=", h.display_checks, " failures=", h.failures)
	quit(0 if h.failures.is_empty() else 1)
