extends "res://tests/scripts/support/battle3d_enemy_turn_harness.gd"
# M3-b harness: M3 harness plus the seventh write call (`_end_ally_turn_by_wait`).
# Defend is spied only to prove it is never called (M4 scope).
const M3Harness = preload("res://tests/scripts/support/battle3d_enemy_turn_harness.gd")
const WAIT_CASES := [
	"W1_wait_unmoved_enemy_attacks", "W2_move_facing_wait_enemy_moves", "W3_last_ally_wait_enemy_waits",
	"W4_wait_with_ally_left_enemy_kills", "W5_wait_two_enemy_slots", "W6_wait_enemy_confused",
]
const FIXTURE := {
	"W1_wait_unmoved_enemy_attacks":"M6_infantry_attack", "W2_move_facing_wait_enemy_moves":"M18_ally_move_then_attack",
	"W3_last_ally_wait_enemy_waits":"M8_enemy_wait", "W4_wait_with_ally_left_enemy_kills":"M7_enemy_lethal_hit",
	"W5_wait_two_enemy_slots":"M10_round_two_slots", "W6_wait_enemy_confused":"M9_enemy_confused",
}

class WaitSpyBattle extends M3Harness.SpyBattle:
	var defend_calls := 0
	func _end_ally_turn_by_wait() -> void:
		writes.append("_end_ally_turn_by_wait")
		super._end_ally_turn_by_wait()
	func _on_defend_button_pressed() -> void:
		defend_calls += 1
		writes.append("_on_defend_button_pressed")
		super._on_defend_button_pressed()

class WaitHost extends Host:
	func create_battle() -> Node:
		var node := super.create_battle()
		node.set_script(WaitSpyBattle)
		return node

func open_lab(tree: SceneTree) -> void:
	tree.root.size = Vector2i(1280,800)
	lab = load("res://scenes/battle3d/Battle3D_EnginePlayLab.tscn").instantiate()
	lab.host.free()
	lab.host = WaitHost.new()
	tree.root.add_child(lab)
	while not lab.ready_for_input: await tree.process_frame
	await tree.physics_frame

func open_bare(tree: SceneTree, spy := true) -> Node:
	var host = WaitHost.new() if spy else Host.new()
	tree.root.add_child(host)
	await host.initialized
	preload("res://tests/scripts/support/battle3d_blocked_reference.gd").apply(host.battle) # T1: the same blocked cells as the 3D lab
	await tree.process_frame
	return host

func press_wait() -> void:
	lab.wait_button.pressed.emit()

func settle_bare(tree: SceneTree, battle: Node, label: String) -> void:
	var stable := 0
	for i in range(4000):
		await tree.process_frame
		stable = stable + 1 if settled(battle) else 0
		if stable >= 30: return
	expect(false, label + " direct settled")

func settle_lab(tree: SceneTree, label: String, probe: Callable = Callable()) -> void:
	var stable := 0
	for i in range(4000):
		await tree.process_frame
		_observe_frame(roles(lab.engine).enemy.unit_id)
		if probe.is_valid(): await probe.call(tree)
		stable = stable + 1 if settled(lab.engine) and not lab._enemy_presentation_busy() else 0
		if stable >= 30: return
	expect(false, label + " 3D settled with empty playback queue")

func lab_view() -> Dictionary:
	return {"enemy_played_paths":lab.enemy_played_paths.duplicate(true), "hits":lab.enemy_damage_presentations.duplicate(true),
		"summaries":lab.enemy_summaries.duplicate(true), "texts":lab.enemy_texts.duplicate(), "frames":frames.duplicate(true),
		"cursors":[lab.event_cursor, lab.action_cursor, lab.enemy_cursor], "result":lab.battle_result,
		"overlay":[lab.result_overlay.visible, lab.result_overlay.text], "round":lab.current_round, "combat_lines":lab.combat_lines.duplicate()}

func run_wait_direct(tree: SceneTree, label: String) -> Dictionary:
	var host = await open_bare(tree)
	var battle: Node = host.battle
	setup(battle, FIXTURE[label])
	await tree.process_frame
	var r := roles(battle)
	battle.call("_select_ally_unit", r.ally, false, false, false)
	if label == "W2_move_facing_wait_enemy_moves":
		battle.call("_try_direct_move_to_cell", Vector2i(8,4))
		for i in range(1800):
			await tree.process_frame
			if battle.get("current_phase") == "facing_select" and not battle.get("is_demo_animating"): break
		battle.call("_select_post_move_facing", "left")
	battle.call("_end_ally_turn_by_wait")
	await settle_bare(tree, battle, label)
	var result := final_state(battle)
	await close_bare(tree, host)
	return result

func run_wait_3d(tree: SceneTree, label: String, probe: Callable = Callable()) -> Dictionary:
	frames.clear()
	await open_lab(tree)
	var battle: Node = lab.engine
	setup(battle, FIXTURE[label])
	lab._sync_views()
	await tree.process_frame
	var r := roles(battle)
	click(r.ally.grid_cell)
	if label == "W2_move_facing_wait_enemy_moves":
		click(Vector2i(8,4))
		await wait_for(tree, "facing_select")
		for button in lab.facing_ui.get_children():
			if button.text == "방향 left": button.pressed.emit()
	lab._sync_views()
	expect(not lab.wait_button.disabled, label + " wait button enabled for an unacted selected ally")
	press_wait()
	await settle_lab(tree, label, probe)
	var result := final_state(battle)
	result["lab"] = lab_view()
	return result
