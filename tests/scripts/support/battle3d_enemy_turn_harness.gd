extends "res://tests/scripts/support/battle3d_engine_attack_harness.gd"
# M3 harness. 3D input path reuses the M2 harness (open/close/click/press);
# engine fixtures reuse the S3-1 oracle harness (unit setup, case specs, seams).
const EnemyOracle = preload("res://tests/scripts/support/battle_enemy_turn_oracle_harness.gd")
const WRITES := ["_select_ally_unit", "_try_direct_move_to_cell", "_select_post_move_facing", "_handle_right_click_cancel", "try_basic_attack", "_try_attack_enemy_target_from_attack_select"]
const CASES := [
	"M1_infantry_approach", "M2_cavalry_approach", "M3_archer_approach", "M4_gunner_approach", "M5_mounted_archer_approach",
	"M6_infantry_attack", "M7_enemy_lethal_hit", "M8_enemy_wait", "M9_enemy_confused", "M10_round_two_slots",
	"M11_ally_kills_target", "M12_ally_wipe_defeat", "M13_enemy_wipe_victory", "M14_enemy_unique_skill",
	"M15_no_path_seam", "M16_path_blocked_seam", "M17_no_target_seam", "M18_ally_move_then_attack",
]
var oracle = EnemyOracle.new()
var frames: Array = [] # per-frame playback observations of the 3D path
var roles_ids := {}

# Transparent spy: each command runs once through super. World-map/result
# handoff entry points are counted (3D must never reach them).
class SpyBattle extends EnemyOracle.SeamBattle:
	var observe: Callable
	var writes: Array = []
	var worldmap_calls := 0
	var target_calls := 0
	var attack_calls := 0
	func _select_ally_unit(unit_state: BattleUnitState, should_log: bool = true, should_open_command_panel: bool = true, should_pulse_turn_start: bool = false) -> void:
		writes.append("_select_ally_unit")
		super._select_ally_unit(unit_state, should_log, should_open_command_panel, should_pulse_turn_start)
	func _try_direct_move_to_cell(target_cell: Vector2i) -> bool:
		writes.append("_try_direct_move_to_cell")
		return super._try_direct_move_to_cell(target_cell)
	func _select_post_move_facing(facing: String) -> void:
		writes.append("_select_post_move_facing")
		super._select_post_move_facing(facing)
	func _handle_right_click_cancel() -> void:
		writes.append("_handle_right_click_cancel")
		super._handle_right_click_cancel()
	func try_basic_attack() -> void:
		writes.append("try_basic_attack")
		attack_calls += 1
		super.try_basic_attack()
	func _try_attack_enemy_target_from_attack_select(target_state: BattleUnitState) -> void:
		writes.append("_try_attack_enemy_target_from_attack_select")
		target_calls += 1
		super._try_attack_enemy_target_from_attack_select(target_state)
	func _on_worldmap_result_return_pressed() -> void:
		worldmap_calls += 1
		super._on_worldmap_result_return_pressed()
	func _return_to_worldmap_with_result() -> void:
		worldmap_calls += 1
		super._return_to_worldmap_with_result()
	func _build_worldmap_battle_result_payload(battle_result_state: String) -> Dictionary:
		worldmap_calls += 1
		return super._build_worldmap_battle_result_payload(battle_result_state)

class M3Host extends Host:
	func create_battle() -> Node:
		var node := super.create_battle()
		node.set_script(SpyBattle)
		return node

func expect(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures.append(label)
		printerr("[M3] FAIL ", label)

func open_lab(tree: SceneTree) -> void:
	tree.root.size = Vector2i(1280,800)
	lab = preload("res://tests/scripts/support/battle3d_test_world.gd").lab(load("res://scenes/battle3d/Battle3D_EnginePlayLab.tscn").instantiate()) # T2 split: the test world (C1 groves)
	lab.host.free()
	lab.host = M3Host.new()
	tree.root.add_child(lab)
	while not lab.ready_for_input: await tree.process_frame
	await tree.physics_frame

func open_bare(tree: SceneTree, spy := true) -> Node:
	# Engine without any 3D presentation: the "engine direct" reference.
	var host = M3Host.new() if spy else Host.new()
	tree.root.add_child(host)
	await host.initialized
	preload("res://tests/scripts/support/battle3d_blocked_reference.gd").apply(host.battle) # T1: the same blocked cells as the 3D lab
	await tree.process_frame # leave the emitting coroutine before callers may free the host
	return host

func close_bare(tree: SceneTree, host: Node) -> void:
	var iso = host.battle.get("_iso_grid_controller")
	host.free()
	if is_instance_valid(iso) and iso.get_parent() == null: iso.free()
	await tree.process_frame

func roles(battle: Node) -> Dictionary:
	var units: Array[BattleUnitState] = battle.get("all_battle_unit_states")
	return {"ally":units[0], "enemy":units[5], "bag":units[6], "units":units}

func setup(battle: Node, label: String) -> void:
	# Fixture writes only (before any observed command), shared by both paths.
	var r := roles(battle)
	var units: Array[BattleUnitState] = r.units
	var ally: BattleUnitState = r.ally
	var enemy: BattleUnitState = r.enemy
	var bag: BattleUnitState = r.bag
	var spec: Dictionary = oracle.case_spec({
		"M1_infantry_approach":"E2_infantry_approach", "M2_cavalry_approach":"E4_cavalry_approach",
		"M3_archer_approach":"E6_archer_approach", "M4_gunner_approach":"E8_gunner_approach",
		"M5_mounted_archer_approach":"E10_mounted_archer_approach", "M8_enemy_wait":"E12_wait",
		"M14_enemy_unique_skill":"E20_enemy_unique_skill", "M15_no_path_seam":"E14_no_path",
		"M16_path_blocked_seam":"E18_path_blocked", "M17_no_target_seam":"E19_no_target",
		"M10_round_two_slots":"E2_infantry_approach", "M18_ally_move_then_attack":"E2_infantry_approach",
	}.get(label, "E1_infantry_attack"))
	var far_allies := [Vector2i(0,9), Vector2i(1,9), Vector2i(2,9), Vector2i(3,9)]
	var far_enemies := [Vector2i(17,0), Vector2i(16,0), Vector2i(15,0), Vector2i(14,0)]
	for i in range(1,5): oracle._setup_unit(units[i], "infantry", far_allies[i-1])
	for i in range(6,10): oracle._setup_unit(units[i], "infantry", far_enemies[i-6])
	var enemy_skill: Dictionary = enemy.unique_skill_definition.duplicate(true)
	oracle._setup_unit(ally, "infantry", spec.target)
	oracle._setup_unit(enemy, spec.type, spec.actor)
	oracle._setup_unit(bag, "infantry", Vector2i(7,4))
	if label == "M18_ally_move_then_attack": ally.set_grid_cell(Vector2i(8,6))
	var lock = battle.get("action_lock_state_service")
	if label == "M8_enemy_wait":
		enemy.move_range = 1
		enemy.apply_status_effect("movement_down", 2, 0)
	if label == "M9_enemy_confused": enemy.apply_status_effect("confusion", 2, 0)
	if label in ["M15_no_path_seam", "M16_path_blocked_seam", "M17_no_target_seam"]:
		battle.seam = {"M15_no_path_seam":"no_path", "M16_path_blocked_seam":"path_blocked", "M17_no_target_seam":"no_target"}[label]
		battle.seam_unit_id = enemy.unit_id
	if label == "M14_enemy_unique_skill":
		enemy.unique_skill_definition = enemy_skill
		battle.get("battle_momentum").gain("enemy", 5, "fixture")
	if label in ["M7_enemy_lethal_hit", "M12_ally_wipe_defeat"]:
		ally.current_hp = 5
		ally.current_troops = 5
	if label == "M11_ally_kills_target":
		bag.current_hp = 1
		bag.current_troops = 1
	if label == "M12_ally_wipe_defeat":
		for i in range(1,5): oracle._kill_for_fixture(units[i])
	if label == "M13_enemy_wipe_victory":
		bag.current_hp = 5
		bag.current_troops = 5
		oracle._kill_for_fixture(enemy)
		for i in range(7,10): oracle._kill_for_fixture(units[i])
	# The bag and the far enemies have already acted; the enemy actor has not.
	for i in range(6,10):
		if units[i].is_alive() and not (label == "M10_round_two_slots" and i == 7): lock.register_unit_acted(units[i], "enemy")
	for i in range(1,5):
		if units[i].is_alive() and not (label == "M7_enemy_lethal_hit" and i == 1): lock.register_unit_acted(units[i], "ally")
	for u in units: battle.call("_sync_resumed_unit_markers_to_grid", u)
	battle.call("_sync_demo_positions")
	if label in ["M12_ally_wipe_defeat", "M13_enemy_wipe_victory"]: battle.call("_cleanup_dead_units")

func logs(battle: Node) -> Dictionary:
	return {"ally_move_event_log":battle.get("ally_move_event_log").export(), "battle_action_event_log":battle.get("battle_action_event_log").export(), "enemy_action_event_log":battle.get("enemy_action_event_log").export()}

func final_state(battle: Node) -> Dictionary:
	return {"units":fingerprint.fingerprint_units(battle.get("all_battle_unit_states")), "controller":oracle.controller_state(battle), "logs":logs(battle), "writes":battle.writes.duplicate()}

func settled(battle: Node) -> bool:
	return not battle.get("is_demo_animating") and (battle.get("current_phase") == "ally_turn" or battle.call("_get_battle_result_state") != "")

func run_direct(tree: SceneTree, label: String) -> Dictionary:
	var host = await open_bare(tree)
	var battle: Node = host.battle
	setup(battle, label)
	await tree.process_frame
	var r := roles(battle)
	battle.call("_select_ally_unit", r.ally, false, false, false)
	if label == "M18_ally_move_then_attack":
		battle.call("_try_direct_move_to_cell", Vector2i(8,4))
		for i in range(1800):
			await tree.process_frame
			if battle.get("current_phase") == "facing_select" and not battle.get("is_demo_animating"): break
		battle.call("_select_post_move_facing", "left")
	battle.call("try_basic_attack")
	battle.call("_try_attack_enemy_target_from_attack_select", r.bag)
	var stable := 0
	for i in range(3000):
		await tree.process_frame
		stable = stable + 1 if settled(battle) else 0
		if stable >= 30: break
	expect(stable >= 30, label + " direct settled")
	var result := final_state(battle)
	await close_bare(tree, host)
	return result

# 3D path: every command comes from lab._unhandled_input / lab buttons.
func run_3d(tree: SceneTree, label: String, probe: Callable = Callable()) -> Dictionary:
	frames.clear()
	await open_lab(tree)
	var battle: Node = lab.engine
	setup(battle, label)
	lab._sync_views()
	await tree.process_frame
	var r := roles(battle)
	click(r.ally.grid_cell)
	if label == "M18_ally_move_then_attack":
		click(Vector2i(8,4))
		await wait_for(tree, "facing_select")
		for button in lab.facing_ui.get_children():
			if button.text == "방향 left": button.pressed.emit()
	press_attack()
	click(r.bag.grid_cell)
	var stable := 0
	for i in range(4000):
		await tree.process_frame
		_observe_frame(r.enemy.unit_id)
		if probe.is_valid(): await probe.call(tree)
		stable = stable + 1 if settled(battle) and not lab._enemy_presentation_busy() else 0
		if stable >= 30: break
	expect(stable >= 30, label + " 3D settled with empty playback queue")
	var result := final_state(battle)
	result["lab"] = {"enemy_played_paths":lab.enemy_played_paths.duplicate(true), "hits":lab.enemy_damage_presentations.duplicate(true),
		"summaries":lab.enemy_summaries.duplicate(true), "texts":lab.enemy_texts.duplicate(), "frames":frames.duplicate(true),
		"cursors":[lab.event_cursor, lab.action_cursor, lab.enemy_cursor], "result":lab.battle_result,
		"overlay":[lab.result_overlay.visible, lab.result_overlay.text], "round":lab.current_round}
	return result

func _observe_frame(enemy_id: String) -> void:
	var hit_labels: Array = []
	for child in lab.get_children():
		if child is Label3D and child.has_meta("enemy_hit"): hit_labels.append(child.text)
	frames.append({"moving":lab.playback.has(enemy_id), "cell":lab.board.cell_at(lab.views[enemy_id].position),
		"hit_labels":hit_labels, "busy":lab._enemy_presentation_busy(), "phase":lab.engine.get("current_phase"),
		"animating":lab.engine.get("is_demo_animating"), "queue":lab.enemy_queue.size()})
