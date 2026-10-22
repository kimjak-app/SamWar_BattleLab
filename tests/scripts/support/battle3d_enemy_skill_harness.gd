extends "res://tests/scripts/support/battle3d_skill_harness.gd"
# M4-c2 harness: the M4-c1 harness (twelve commands, no new write). The ally
# waits; the enemy actor (units[5]) uses a unique skill in its replayed slot.
# Fixtures reuse the S4-1 board; the enemy skill and momentum are fixture writes.
const ENEMY_CASES := ["C1_enemy_line", "C2_single_enemy", "C3_enemy_area", "C4_self_area", "C5_after_move", "C6_lethal_defeat", "C7_charge_advance"]
var enemy_label_seen := {}
var order_failures := 0

func enemy_setup(battle: Node, label: String) -> Dictionary:
	var s := skill_setup(battle, "X_enemy_skill_in_slot") # guan_yu line skill, enemy momentum 10
	var units: Array = s.units
	var enemy: BattleUnitState = units[5]
	match label:
		"C2_single_enemy": enemy.unique_skill_definition = tactic.skill_for_effect("single_burst")
		"C3_enemy_area": enemy.unique_skill_definition = tactic.skill_for_effect("trap_aoe")
		"C4_self_area": enemy.unique_skill_definition = tactic.skill_for_effect("team_buff")
		"C5_after_move":
			# Out of reach at the start: the enemy moves, then uses its skill after the move.
			tactic._setup_unit(enemy, "cavalry", Vector2i(17,4))
			enemy.unique_skill_definition = tactic.skill_for_effect("single_ranged_damage")
		"C6_lethal_defeat":
			# The last ally is out of attack range but in the skill's range with few troops.
			for i in [1, 2, 3, 4]: oracle._kill_for_fixture(units[i])
			tactic._setup_unit(units[0], "infantry", Vector2i(4,4))
			units[0].current_hp = 5
			units[0].current_troops = 5
			enemy.unique_skill_definition = tactic.skill_for_effect("single_ranged_damage")
		"C7_charge_advance":
			# A charge that kills and advances the caster (damage effect with caster cells).
			enemy.unique_skill_definition = tactic.skill_by_id("cheok_jun_gyeong_unique")
			units[1].current_hp = 5
			units[1].current_troops = 5
	tactic._sync(battle, units)
	if label == "C6_lethal_defeat": battle.call("_cleanup_dead_units")
	return s

func run_enemy_direct(tree: SceneTree, label: String) -> Dictionary:
	var host = await open_bare(tree)
	var battle: Node = host.battle
	var s := enemy_setup(battle, label)
	await tree.process_frame
	battle.call("_select_ally_unit", s.caster, false, false, false)
	battle.call("_end_ally_turn_by_wait")
	await settle_bare(tree, battle, label)
	var result := final_state(battle)
	result["tactic"] = battle.get("tactic_event_log").export()
	await close_bare(tree, host)
	return result

func enemy_skill_probe(tree: SceneTree) -> void:
	for child in lab.get_children():
		if child is Label3D and child.has_meta("enemy_skill_label"): enemy_label_seen[child.get_instance_id()] = [child.get_meta("enemy_skill_label"), child.text]
	# Never before the replay: every presented enemy cast's skill text was replayed first.
	var replayed: Array = lab.enemy_texts.filter(func(x): return x.begins_with("적 특기 사용: ")).map(func(x): return x.trim_prefix("적 특기 사용: "))
	for e in lab.enemy_skill_presentations:
		if e.kind == "skill_cast" and not replayed.has(e.skill_id):
			order_failures += 1
			expect(false, "enemy skill %s shown before its replayed enemy_skill_used" % e.skill_id)
	# Input stays locked while an enemy skill is open: the replay queue, or the engine itself
	# (enemy turn / skill presentation) while the queue waits for the completion event.
	# Read the logs first, exactly as `_input_locked()` does before deciding (an engine timer may
	# have closed the slot after the lab's frame).
	lab._consume_tactic_events()
	var engine_busy: bool = lab.engine.get("is_demo_animating") or lab.engine.get("current_phase") != "ally_turn"
	if not lab.enemy_skill_open.is_empty() and not lab._enemy_presentation_busy() and not engine_busy:
		expect(false, "enemy skill open while neither the replay nor the engine locks input " + str([lab.enemy_skill_open, lab.engine.get("current_phase"), lab.enemy_queue.map(func(e): return e.kind), lab.enemy_hold, lab.enemy_texts.slice(-2)]))

func run_enemy_3d(tree: SceneTree, label: String) -> Dictionary:
	frames.clear()
	label_seen.clear()
	enemy_label_seen.clear()
	await open_lab(tree)
	var battle: Node = lab.engine
	var s := enemy_setup(battle, label)
	lab._sync_views()
	await tree.process_frame
	click(s.caster.grid_cell)
	lab._sync_views()
	press_wait()
	await settle_lab(tree, label, enemy_skill_probe)
	await tree.process_frame
	lab._process(0.0)
	var result := final_state(battle)
	result["tactic"] = battle.get("tactic_event_log").export()
	result["lab"] = skill_lab_view()
	result["lab"]["enemy_presentations"] = lab.enemy_skill_presentations.duplicate(true)
	result["lab"]["enemy_texts_skill"] = lab.enemy_skill_texts.duplicate()
	result["lab"]["enemy_labels"] = enemy_label_seen.values()
	result["lab"]["pending"] = lab.pending_enemy_skills.duplicate(true)
	result["lab"]["leftovers"] = lab.enemy_skill_leftovers.duplicate(true)
	result["lab"]["open"] = lab.enemy_skill_open.duplicate()
	return result

static func enemy_skill_events(events: Array, sides: Dictionary) -> Array:
	return events.filter(func(e): return e.kind in ["skill_cast", "skill_effect", "skill_finished"] and sides.get(e.caster_id, "") == "enemy")

static func enemy_expected(events: Array, names: Dictionary) -> Dictionary:
	# The M4-c1 expected strings with the enemy prefix; the momentum note is never touched.
	var base := expected_display(events, names)
	return {"lines":base.lines.map(func(x): return "적 " + x), "labels":base.labels}
