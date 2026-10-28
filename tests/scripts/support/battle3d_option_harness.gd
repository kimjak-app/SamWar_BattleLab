extends "res://tests/scripts/support/battle3d_auto_hold_harness.gd"
# M5-c harness: the M5-a2 observing host plus the fifteenth write call
# (`set_enemy_ai_level`, recorded in the write list), the flags at every enemy
# turn start (before / after the engine applies a pending level) and at the end
# of every enemy action, and an optional forced refusal of the level call.
const HoldHarness2 = preload("res://tests/scripts/support/battle3d_auto_hold_harness.gd")
const FIFTEEN := ["_select_ally_unit", "_try_direct_move_to_cell", "_select_post_move_facing", "_handle_right_click_cancel", "try_basic_attack",
	"_try_attack_enemy_target_from_attack_select", "_end_ally_turn_by_wait", "_on_defend_button_pressed", "_on_strategy_button_pressed", "_try_use_strategy_on_target",
	"_on_unique_skill_button_pressed", "_try_use_unique_skill_on_target", "_toggle_full_auto_battle", "set_auto_presentation_hold", "set_enemy_ai_level"]
const LEVEL_TEXT := {"low":"하", "mid":"중", "high":"상"}

class OptionSpyBattle extends HoldHarness2.HoldSpyBattle:
	var refuse_level := false
	var enemy_turns: Array = [] # [round, pending before, flags before, flags after]
	var actions_done: Array = [] # [unit_id, flags at the end of the action]
	func set_enemy_ai_level(level: Variant) -> bool:
		writes.append("set_enemy_ai_level")
		if refuse_level: return false
		return super.set_enemy_ai_level(level)
	func _play_enemy_ai_turn() -> void:
		var index := enemy_turns.size()
		enemy_turns.append([battle_round, _pending_enemy_ai_level, [enemy_strategy_enabled, enemy_skill_spread_enabled, enemy_skill_cap_enabled], []])
		super._play_enemy_ai_turn()
		enemy_turns[index][3] = [enemy_strategy_enabled, enemy_skill_spread_enabled, enemy_skill_cap_enabled]
	func _advance_enemy_turn_or_return_to_ally() -> void:
		actions_done.append([current_enemy_ai_actor_state.unit_id if current_enemy_ai_actor_state != null else "", [enemy_strategy_enabled, enemy_skill_spread_enabled, enemy_skill_cap_enabled]])
		super._advance_enemy_turn_or_return_to_ally()

class OptionHost extends Host:
	func create_battle() -> Node:
		var node := super.create_battle()
		node.set_script(OptionSpyBattle)
		return node

func open_lab(tree: SceneTree) -> void:
	tree.root.size = Vector2i(1280,800)
	lab = preload("res://tests/scripts/support/battle3d_test_world.gd").lab(load("res://scenes/battle3d/Battle3D_EnginePlayLab.tscn").instantiate()) # T2 split: the test world (C1 groves)
	lab.host.free()
	lab.host = OptionHost.new()
	tree.root.add_child(lab)
	while not lab.ready_for_input: await tree.process_frame
	await tree.physics_frame
	lab.engine.lab_probe = lab_idle_report

func open_option_bare(tree: SceneTree) -> Node:
	var host = OptionHost.new()
	tree.root.add_child(host)
	await host.initialized
	preload("res://tests/scripts/support/battle3d_blocked_reference.gd").apply(host.battle) # T1: the same blocked cells as the 3D lab
	await tree.process_frame
	return host

func expected_level_text(current: String, pending: String) -> String:
	# Written from the engine values independently of the lab.
	var text: String = "적 AI: " + LEVEL_TEXT[current]
	if pending != "": text += " → " + LEVEL_TEXT[pending] + " (다음 적 턴부터 적용)"
	return text

func push_click(tree: SceneTree, control: Control) -> void:
	# A real GUI click at the control's screen position (viewport input injection).
	var pos := control.get_global_rect().get_center()
	var motion := InputEventMouseMotion.new()
	motion.position = pos
	tree.root.push_input(motion)
	for pressed in [true, false]:
		var ev := InputEventMouseButton.new()
		ev.button_index = MOUSE_BUTTON_LEFT
		ev.pressed = pressed
		ev.position = pos
		tree.root.push_input(ev)
	await tree.process_frame
	await tree.process_frame
