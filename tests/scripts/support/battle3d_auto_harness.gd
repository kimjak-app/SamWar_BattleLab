extends "res://tests/scripts/support/battle3d_skill_harness.gd"
# M5-a harness: M4-c1 harness plus the thirteenth write call
# (`_toggle_full_auto_battle`, start and stop). The spy also snapshots the
# engine at each round start (inside `_start_new_round`, a deterministic
# program point on every path and speed), including the next global random value.
const SkillHarness = preload("res://tests/scripts/support/battle3d_skill_harness.gd")
const THIRTEEN := ["_select_ally_unit", "_try_direct_move_to_cell", "_select_post_move_facing", "_handle_right_click_cancel", "try_basic_attack",
	"_try_attack_enemy_target_from_attack_select", "_end_ally_turn_by_wait", "_on_defend_button_pressed", "_on_strategy_button_pressed", "_try_use_strategy_on_target",
	"_on_unique_skill_button_pressed", "_try_use_unique_skill_on_target", "_toggle_full_auto_battle"]

class AutoSpyBattle extends SkillHarness.SkillSpyBattle:
	var auto_calls := 0
	var round_snaps := {}
	var fp = preload("res://scripts/battle/services/battle_state_fingerprint_service.gd").new()
	func _toggle_full_auto_battle() -> void:
		writes.append("_toggle_full_auto_battle")
		auto_calls += 1
		super._toggle_full_auto_battle()
	func _start_new_round(force_round_start := false) -> void:
		super._start_new_round(force_round_start)
		if not round_snaps.has(battle_round):
			round_snaps[battle_round] = {"units":fp.fingerprint_units(all_battle_unit_states), "momentum":[battle_momentum.get_value("ally"), battle_momentum.get_value("enemy")],
				"logs":[ally_move_event_log.export(), battle_action_event_log.export(), enemy_action_event_log.export(), tactic_event_log.export()], "next_randf":randf()}

class AutoHost extends Host:
	func create_battle() -> Node:
		var node := super.create_battle()
		node.set_script(AutoSpyBattle)
		return node

func open_lab(tree: SceneTree) -> void:
	tree.root.size = Vector2i(1280,800)
	lab = load("res://scenes/battle3d/Battle3D_EnginePlayLab.tscn").instantiate()
	lab.host.free()
	lab.host = AutoHost.new()
	tree.root.add_child(lab)
	while not lab.ready_for_input: await tree.process_frame
	await tree.physics_frame

func open_bare(tree: SceneTree, spy := true) -> Node:
	var host = AutoHost.new() if spy else Host.new()
	tree.root.add_child(host)
	await host.initialized
	await tree.process_frame
	return host

func press_auto() -> void:
	lab.auto_button.pressed.emit()

func logs4(battle: Node) -> Dictionary:
	var result := logs(battle)
	result["tactic_event_log"] = battle.get("tactic_event_log").export()
	return result

func auto_final(battle: Node) -> Dictionary:
	var result := final_state(battle)
	result["tactic"] = battle.get("tactic_event_log").export()
	result["round_snaps"] = battle.round_snaps.duplicate(true)
	result["auto_on"] = battle.get("is_full_auto_battle_enabled")
	return result

func ended_or_round(battle: Node, stop_round: int) -> bool:
	return battle.call("_get_battle_result_state") != "" or (stop_round > 0 and battle.round_snaps.has(stop_round))

func run_auto_direct(tree: SceneTree, seed_value: int, speed: float, stop_round := 0) -> Dictionary:
	# Engine without 3D: one `_toggle_full_auto_battle`, then the engine plays until the end (or stop_round starts).
	var host = await open_bare(tree)
	var battle: Node = host.battle
	Engine.time_scale = speed
	seed(seed_value)
	battle.call("_toggle_full_auto_battle")
	for i in range(60000):
		await tree.process_frame
		if ended_or_round(battle, stop_round): break
	if stop_round == 0:
		for i in range(60): await tree.process_frame
	Engine.time_scale = 1.0
	var result := auto_final(battle)
	await close_bare(tree, host)
	return result

func auto_display_probe(tree: SceneTree) -> void:
	# Skill labels as in M4-c1. The M4-b/M4-c1 per-frame badge, tick and "HUD frozen during a
	# replay" probes are not used: they assume one enemy slot in the queue, while in auto the
	# engine runs ahead of the 3D replay (the same enemy's next slot is often queued already).
	# The replay itself is compared with the logs after the run.
	for child in lab.get_children():
		if child is Label3D and child.has_meta("skill_label"): label_seen[child.get_instance_id()] = [child.get_meta("skill_label"), child.text]
	# While auto runs, every manual command button is disabled and the auto button stays usable.
	if lab.engine.get("is_full_auto_battle_enabled"):
		display_checks += 1
		for button in [lab.attack_button, lab.wait_button, lab.defend_button, lab.strategy_button, lab.skill_button]:
			if not button.disabled: expect(false, "manual button enabled during auto: " + button.text)
		if lab.auto_button.disabled or lab.auto_button.text != "자동 ■ (중지)": expect(false, "auto button shows stop during auto: " + lab.auto_button.text)

func run_auto_3d(tree: SceneTree, seed_value: int, speed_presses: int, stop_round := 0) -> Dictionary:
	frames.clear()
	label_seen.clear()
	await open_lab(tree)
	var battle: Node = lab.engine
	for i in range(speed_presses): lab.speed_button.pressed.emit()
	lab._sync_views()
	expect(not lab.auto_button.disabled and lab.auto_button.text == "자동 ▶", "auto button ready at the ally turn")
	seed(seed_value)
	press_auto()
	expect(battle.get("is_full_auto_battle_enabled") and lab.auto_texts.has(lab.AUTO_STATUS), "auto accepted (engine flag read back)")
	for i in range(60000):
		await tree.process_frame
		_observe_frame(roles(battle).enemy.unit_id)
		auto_display_probe(tree)
		if ended_or_round(battle, stop_round) and (stop_round > 0 or not lab._enemy_presentation_busy()): break
	if stop_round == 0:
		for i in range(60):
			await tree.process_frame
			auto_display_probe(tree)
	lab._process(0.0)
	var result := auto_final(battle)
	result["lab"] = skill_lab_view()
	result["lab"]["auto_texts"] = lab.auto_texts.duplicate()
	result["lab"]["played_paths"] = lab.played_paths.duplicate(true)
	result["lab"]["damage"] = lab.damage_presentations.duplicate(true)
	result["lab"]["time_scale"] = Engine.time_scale
	return result
