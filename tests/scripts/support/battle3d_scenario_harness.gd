extends "res://tests/scripts/support/battle3d_auto_hold_harness.gd"
# M5-b harness: the scenario shell (start screen, result overlay, new battle)
# with the M5-a2 observing host inside every lab it creates (write spy, hold
# calls). Engine-only references run on a bare host with the same start setup.
const HoldHarness = preload("res://tests/scripts/support/battle3d_auto_hold_harness.gd")
const ShellScript = preload("res://scripts/battle3d/battle3d_scenario_shell.gd")
const SETUP_KEY := "samwar_battle_setup"
const ENEMY_IDS := ["guan_yu", "zhang_fei", "xiahou_dun", "enemy_reinforce_01_demo", "enemy_reinforce_02_test_unit"]
const TROOP_FIELDS := ["current_troops", "max_troops", "allocated_troops", "initial_allocated_troops", "current_hp", "max_hp"]

class SpyShell extends ShellScript:
	var test_world := true
	func create_lab() -> Node:
		var node := super.create_lab()
		if test_world: preload("res://tests/scripts/support/battle3d_test_world.gd").lab(node) # T2 split: the test world (C1 groves)
		node.host.free()
		node.host = HoldHarness.HoldHost.new()
		return node

var shell: Node
var test_world := true # T2 split: false = the lab keeps terrain_types.json's groves (tests of the presentation default)

func open_shell(tree: SceneTree) -> void:
	tree.root.size = Vector2i(1280,800)
	if Engine.has_meta(SETUP_KEY): Engine.remove_meta(SETUP_KEY)
	shell = SpyShell.new()
	shell.test_world = test_world
	tree.root.add_child(shell)
	await tree.process_frame

func close_shell(tree: SceneTree) -> void:
	shell._close_lab()
	shell.free()
	shell = null
	lab = null
	await tree.process_frame

func wait_lab(tree: SceneTree) -> void:
	lab = shell.lab
	while not lab.ready_for_input: await tree.process_frame
	await tree.physics_frame

func press_scenario(tree: SceneTree, id: String) -> void:
	shell.scenario_buttons[id].pressed.emit()
	await wait_lab(tree)

func press_restart(tree: SceneTree) -> void:
	shell.restart_button.pressed.emit()
	await wait_lab(tree)

func troop_fields(unit: BattleUnitState) -> Dictionary:
	var out := {}
	for f in TROOP_FIELDS: out[f] = unit.get(f)
	return out

func expected_scaled(value: int, ratio: float) -> int:
	# Independent of the engine service: floor, at least 1 for a positive value.
	if value <= 0: return value
	var scaled := int(floor(value * ratio))
	return scaled if scaled >= 1 else 1

func start_print(battle: Node) -> Dictionary:
	return {"units":fingerprint.fingerprint_units(battle.get("all_battle_unit_states")), "controller":oracle.controller_state(battle), "logs":logs4(battle),
		"momentum":[battle.battle_momentum.get_value("ally"), battle.battle_momentum.get_value("enemy")]}

func bare_start(tree: SceneTree, setup: Dictionary) -> Dictionary:
	# Engine-only start of a scenario (same setup meta) for comparison.
	if Engine.has_meta(SETUP_KEY): Engine.remove_meta(SETUP_KEY)
	if not setup.is_empty(): Engine.set_meta(SETUP_KEY, setup)
	var host = await open_bare(tree)
	var result := start_print(host.battle)
	result["writes"] = host.battle.writes.duplicate() # the engine's own first ally selection
	result["troops"] = {}
	for u in host.battle.all_battle_unit_states: result.troops[u.unit_id] = troop_fields(u)
	await close_bare(tree, host)
	return result

func engine_auto(tree: SceneTree, seed_value: int, setup: Dictionary, speed: float) -> Dictionary:
	if Engine.has_meta(SETUP_KEY): Engine.remove_meta(SETUP_KEY)
	if not setup.is_empty(): Engine.set_meta(SETUP_KEY, setup)
	return await run_auto_direct(tree, seed_value, speed)

func engine_all_wait(tree: SceneTree, seed_value: int) -> Dictionary:
	# Engine only: every ally turn ends with the engine's wait command until the result.
	if Engine.has_meta(SETUP_KEY): Engine.remove_meta(SETUP_KEY)
	var host = await open_bare(tree)
	var battle: Node = host.battle
	seed(seed_value)
	for i in range(60000):
		await tree.process_frame
		if battle.call("_get_battle_result_state") != "": break
		if battle.current_phase == "ally_turn" and not battle.is_demo_animating and battle.active_unit_state != null: battle.call("_end_ally_turn_by_wait")
	await settle_engine(tree, battle)
	var result := auto_final(battle)
	await close_bare(tree, host)
	return result

func settle_engine(tree: SceneTree, battle: Node) -> void:
	# After the result the engine may still finish the running action: wait until it stops animating.
	for i in range(6000):
		if not battle.is_demo_animating: break
		await tree.process_frame
	for i in range(60): await tree.process_frame

func expected_overlay(battle: Node, result_state: String) -> String:
	# Written from engine values independently of the shell: result word, battle_round, deployed allies with troops left.
	var allies := 0
	for u in battle.all_battle_unit_states:
		if u.side == "ally" and u.current_troops > 0 and battle._is_unit_state_available_for_battle_slot(u): allies += 1
	return "%s · 라운드 %d · 생존 아군 %d부대" % [{"victory":"승리", "defeat":"패배"}[result_state], battle.battle_round, allies]
