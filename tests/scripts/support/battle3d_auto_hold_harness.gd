extends "res://tests/scripts/support/battle3d_auto_harness.gd"
# M5-a2 harness: the M5-a auto harness plus the fourteenth write call
# (`set_auto_presentation_hold`). The spy records every hold call (value, frame)
# and, at each engine auto action start (`_run_auto_action_for_active_ally_once`,
# reached only from the auto tick), whether the 3D presentation was idle:
# no move playback, empty enemy replay queue and hold, four cursors at their log ends.
const AutoHarness = preload("res://tests/scripts/support/battle3d_auto_harness.gd")
const FOURTEEN := ["_select_ally_unit", "_try_direct_move_to_cell", "_select_post_move_facing", "_handle_right_click_cancel", "try_basic_attack",
	"_try_attack_enemy_target_from_attack_select", "_end_ally_turn_by_wait", "_on_defend_button_pressed", "_on_strategy_button_pressed", "_try_use_strategy_on_target",
	"_on_unique_skill_button_pressed", "_try_use_unique_skill_on_target", "_toggle_full_auto_battle", "set_auto_presentation_hold"]

class HoldSpyBattle extends AutoHarness.AutoSpyBattle:
	var hold_calls: Array = [] # [value, process frame]
	var action_starts: Array = [] # [process frame, lab idle report]
	var lab_probe := Callable()
	func set_auto_presentation_hold(hold: bool) -> void:
		hold_calls.append([hold, Engine.get_process_frames()])
		super.set_auto_presentation_hold(hold)
	func _run_auto_action_for_active_ally_once() -> void:
		action_starts.append([Engine.get_process_frames(), lab_probe.call() if lab_probe.is_valid() else {}])
		super._run_auto_action_for_active_ally_once()

class HoldHost extends Host:
	func create_battle() -> Node:
		var node := super.create_battle()
		node.set_script(HoldSpyBattle)
		return node

func open_lab(tree: SceneTree) -> void:
	tree.root.size = Vector2i(1280,800)
	lab = preload("res://tests/scripts/support/battle3d_test_world.gd").lab(load("res://scenes/battle3d/Battle3D_EnginePlayLab.tscn").instantiate()) # T2 split: the test world (C1 groves)
	lab.host.free()
	lab.host = HoldHost.new()
	tree.root.add_child(lab)
	while not lab.ready_for_input: await tree.process_frame
	await tree.physics_frame
	lab.engine.lab_probe = lab_idle_report

func lab_idle_report() -> Dictionary:
	var e: Node = lab.engine
	var sizes := [e.ally_move_event_log.export().size(), e.battle_action_event_log.export().size(), e.enemy_action_event_log.export().size(), e.tactic_event_log.export().size()]
	var cursors := [lab.event_cursor, lab.action_cursor, lab.enemy_cursor, lab.tactic_cursor]
	return {"idle":lab.playback.is_empty() and lab.enemy_queue.is_empty() and lab.enemy_hold == 0.0 and cursors == sizes,
		"playback":lab.playback.keys(), "queue":lab.enemy_queue.size(), "enemy_hold":lab.enemy_hold, "cursors":cursors, "sizes":sizes}

func hold_edges_ok(calls: Array) -> bool:
	# Sent on a change only: values alternate, starting with true.
	for i in range(calls.size()):
		if calls[i][0] != (i % 2 == 0): return false
	return true

func run_hold_3d(tree: SceneTree, seed_value: int, speed_presses: int, stop_round := 0) -> Dictionary:
	frames.clear()
	label_seen.clear()
	await open_lab(tree)
	var battle: Node = lab.engine
	for i in range(speed_presses): lab.speed_button.pressed.emit()
	lab._sync_views()
	seed(seed_value)
	press_auto()
	for i in range(80000):
		await tree.process_frame
		_observe_frame(roles(battle).enemy.unit_id)
		if ended_or_round(battle, stop_round) and (stop_round > 0 or not lab._enemy_presentation_busy()): break
	if stop_round == 0:
		for i in range(60): await tree.process_frame
	lab._process(0.0)
	var result := auto_final(battle)
	result["hold_calls"] = battle.hold_calls.duplicate(true)
	result["action_starts"] = battle.action_starts.duplicate(true)
	result["hold_now"] = battle.auto_presentation_hold
	result["sent"] = lab.auto_hold_sent
	result["time_scale"] = Engine.time_scale
	return result
