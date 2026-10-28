extends "res://tests/scripts/support/battle3d_defend_harness.gd"
# M4-b harness: M4-a harness plus the ninth and tenth write calls
# (`_on_strategy_button_pressed`, `_try_use_strategy_on_target`). The strategy
# dice is forced through the S4-1 test hook on both paths (tests only).
const WaitHarness = preload("res://tests/scripts/support/battle3d_wait_harness.gd")
const STRATEGY_CASES := [
	"G1_basic_success", "G2_basic_fail", "G3_advanced_success_pool0", "G4_advanced_success_pool1", "G5_advanced_fail",
	"G6_master_success_pool0", "G7_master_success_pool1", "G8_master_fail", "G9_shaken_enemy_acts_in_slot", "G10_burning_caster_ticks",
]
const SPEC := {
	"G1_basic_success":[80, true, 0, "M6_infantry_attack"], "G2_basic_fail":[80, false, 0, "M6_infantry_attack"],
	"G3_advanced_success_pool0":[90, true, 0, "M6_infantry_attack"], "G4_advanced_success_pool1":[90, true, 1, "M6_infantry_attack"],
	"G5_advanced_fail":[90, false, 0, "M6_infantry_attack"], "G6_master_success_pool0":[95, true, 0, "M6_infantry_attack"],
	"G7_master_success_pool1":[95, true, 1, "M6_infantry_attack"], "G8_master_fail":[95, false, 0, "M6_infantry_attack"],
	"G9_shaken_enemy_acts_in_slot":[95, true, 1, "M10_round_two_slots"], "G10_burning_caster_ticks":[90, false, 0, "M6_infantry_attack"],
}
const TEN := ["_select_ally_unit", "_try_direct_move_to_cell", "_select_post_move_facing", "_handle_right_click_cancel", "try_basic_attack",
	"_try_attack_enemy_target_from_attack_select", "_end_ally_turn_by_wait", "_on_defend_button_pressed", "_on_strategy_button_pressed", "_try_use_strategy_on_target"]

class StrategySpyBattle extends WaitHarness.WaitSpyBattle:
	var strategy_calls := 0
	func _on_strategy_button_pressed() -> void:
		writes.append("_on_strategy_button_pressed")
		strategy_calls += 1
		super._on_strategy_button_pressed()
	func _try_use_strategy_on_target(target_state: BattleUnitState) -> void:
		writes.append("_try_use_strategy_on_target")
		strategy_calls += 1
		super._try_use_strategy_on_target(target_state)

class StrategyHost extends Host:
	func create_battle() -> Node:
		var node := super.create_battle()
		node.set_script(StrategySpyBattle)
		return node

static func forced_roll(success: bool, pool: int) -> Callable:
	return func(kind: String, _value): return success if kind == "success" else pool

func open_lab(tree: SceneTree) -> void:
	tree.root.size = Vector2i(1280,800)
	lab = preload("res://tests/scripts/support/battle3d_test_world.gd").lab(load("res://scenes/battle3d/Battle3D_EnginePlayLab.tscn").instantiate()) # T2 split: the test world (C1 groves)
	lab.host.free()
	lab.host = StrategyHost.new()
	tree.root.add_child(lab)
	while not lab.ready_for_input: await tree.process_frame
	await tree.physics_frame

func open_bare(tree: SceneTree, spy := true) -> Node:
	var host = StrategyHost.new() if spy else Host.new()
	tree.root.add_child(host)
	await host.initialized
	preload("res://tests/scripts/support/battle3d_blocked_reference.gd").apply(host.battle) # T1: the same blocked cells as the 3D lab
	await tree.process_frame
	return host

func press_strategy() -> void:
	lab.strategy_button.pressed.emit()

func strategy_setup(battle: Node, label: String) -> Dictionary:
	# Fixture writes only, shared by both paths: caster intelligence, dice hook, optional burn.
	var spec: Array = SPEC[label]
	setup(battle, spec[3])
	var r := roles(battle)
	r.ally.intelligence = spec[0]
	r.enemy.intelligence = 70
	if label == "G10_burning_caster_ticks": r.ally.apply_status_effect("burn", 2, 12)
	battle.strategy_roll_override = forced_roll(spec[1], spec[2])
	return r

func logs4(battle: Node) -> Dictionary:
	var result := logs(battle)
	result["tactic_event_log"] = battle.get("tactic_event_log").export()
	return result

func run_strategy_direct(tree: SceneTree, label: String) -> Dictionary:
	var host = await open_bare(tree)
	var battle: Node = host.battle
	var r := strategy_setup(battle, label)
	await tree.process_frame
	battle.call("_select_ally_unit", r.ally, false, false, false)
	battle.call("_on_strategy_button_pressed")
	battle.call("_try_use_strategy_on_target", r.enemy)
	await settle_bare(tree, battle, label)
	var result := final_state(battle)
	result["tactic"] = battle.get("tactic_event_log").export()
	await close_bare(tree, host)
	return result

func strategy_display_probe(tree: SceneTree) -> void:
	# A status_tick of an enemy is never shown before its replayed enemy_action_completed.
	for shown in lab.tactic_presentations:
		if shown.kind == "status_tick" and lab._enemy_completion_pending(shown.unit_id):
			expect(false, "tick of %s shown before its replayed action completed" % shown.unit_id)
	# Badge/unit panel status == engine status_effects whenever no enemy replay is pending.
	if lab._enemy_presentation_busy(): return
	lab._sync_views()
	for badge in lab.action_badges.get_children():
		if not badge.visible: continue
		var unit = lab.queries.find_unit(badge.get_meta("unit_id"))
		var expected: String = lab._status_text(unit.status_effects)
		display_checks += 1
		if not expected.is_empty() and not badge.text.ends_with(" · " + expected):
			expect(false, "badge %s status %s vs engine %s" % [unit.unit_id, badge.text, expected])
		if expected.is_empty() and badge.text.contains("턴"):
			expect(false, "badge %s shows a status the engine no longer has: %s" % [unit.unit_id, badge.text])

func run_strategy_3d(tree: SceneTree, label: String) -> Dictionary:
	frames.clear()
	await open_lab(tree)
	var battle: Node = lab.engine
	var r := strategy_setup(battle, label)
	lab._sync_views()
	await tree.process_frame
	click(r.ally.grid_cell)
	lab._sync_views()
	expect(not lab.strategy_button.disabled, label + " strategy button enabled")
	press_strategy()
	expect(battle.get("current_phase") == "strategy", label + " engine entered strategy target select")
	var targets: Array = battle.call("_get_strategy_targets", r.ally)
	var previews := {}
	for child in lab.strategy_marks.get_children():
		if child.has_meta("strategy_preview"): previews[child.get_meta("strategy_preview")] = child.text
	for t in targets:
		expect(previews.get(t.unit_id, "") == "성공률 %d%%" % roundi(battle.call("_get_strategy_success_rate", r.ally, t) * 100.0), label + " preview == engine rate for " + t.unit_id)
	expect(previews.size() == targets.size(), label + " one preview per engine target")
	click(r.enemy.grid_cell)
	await settle_lab(tree, label, strategy_display_probe)
	await tree.process_frame
	lab._process(0.0)
	var result := final_state(battle)
	result["tactic"] = battle.get("tactic_event_log").export()
	result["lab"] = lab_view()
	result["lab"]["tactic_cursor"] = lab.tactic_cursor
	result["lab"]["presentations"] = lab.tactic_presentations.duplicate(true)
	result["lab"]["tactic_texts"] = lab.tactic_texts.duplicate()
	result["lab"]["pending_ticks"] = lab.pending_enemy_ticks.duplicate(true)
	return result
