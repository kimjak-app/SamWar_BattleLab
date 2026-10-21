extends "res://tests/scripts/support/battle3d_wait_harness.gd"
# M4-a harness: M3-b harness plus the eighth write call (`_on_defend_button_pressed`,
# already spied by WaitSpyBattle). Fixtures reuse the M3 cases.
const DEFEND_CASES := [
	"D1_defend_unmoved_enemy_attacks", "D2_move_facing_defend", "D3_wounded_defend_recovers", "D4_full_hp_defend_no_recovery",
	"D5_last_ally_defend_round_reset", "D6_defend_other_unit_attacked", "D7_defend_enemy_moves_waits_default",
]
const DEFEND_FIXTURE := {
	"D1_defend_unmoved_enemy_attacks":"M6_infantry_attack", "D2_move_facing_defend":"M18_ally_move_then_attack",
	"D3_wounded_defend_recovers":"M6_infantry_attack", "D4_full_hp_defend_no_recovery":"M8_enemy_wait",
	"D5_last_ally_defend_round_reset":"M10_round_two_slots", "D6_defend_other_unit_attacked":"M7_enemy_lethal_hit",
	"D7_defend_enemy_moves_waits_default":"",
}
var display_checks := 0

func press_defend() -> void:
	lab.defend_button.pressed.emit()

func defend_setup(battle: Node, label: String) -> BattleUnitState:
	# Fixture writes only, shared by both paths. Returns the unit that defends.
	if DEFEND_FIXTURE[label].is_empty(): return battle.get("active_unit_state") # untouched default layout
	setup(battle, DEFEND_FIXTURE[label])
	var r := roles(battle)
	if label == "D3_wounded_defend_recovers":
		# hp and troops differ on purpose: the engine heals from missing hp, so a
		# 3D-side formula on troops would show a different number.
		r.ally.current_hp = 150
		r.ally.current_troops = 140
	if label == "D6_defend_other_unit_attacked":
		# M7 leaves units[1] unacted; units[0] (not defending) is attacked, not killed.
		r.ally.current_hp = r.ally.max_hp
		r.ally.current_troops = r.ally.max_troops
		return r.units[1]
	return r.ally

func move_then_facing_direct(tree: SceneTree, battle: Node) -> void:
	battle.call("_try_direct_move_to_cell", Vector2i(8,4))
	for i in range(1800):
		await tree.process_frame
		if battle.get("current_phase") == "facing_select" and not battle.get("is_demo_animating"): break
	battle.call("_select_post_move_facing", "left")

func run_defend_direct(tree: SceneTree, label: String) -> Dictionary:
	var host = await open_bare(tree)
	var battle: Node = host.battle
	var unit: BattleUnitState = defend_setup(battle, label)
	await tree.process_frame
	battle.call("_select_ally_unit", unit, false, false, false)
	if label == "D2_move_facing_defend": await move_then_facing_direct(tree, battle)
	var troops_before: int = unit.current_troops
	battle.call("_on_defend_button_pressed")
	var after_call := {"troops":unit.current_troops, "defending":unit.is_defending, "acted":unit.has_acted, "round":battle.get("battle_round")}
	await settle_bare(tree, battle, label)
	var result := final_state(battle)
	result["defender"] = unit.unit_id
	result["recovered"] = after_call.troops - troops_before
	result["after_call"] = after_call
	await close_bare(tree, host)
	return result

func display_probe(tree: SceneTree) -> void:
	# The badge and unit panel "방어 중" must equal the engine's is_defending.
	lab._sync_views()
	for badge in lab.action_badges.get_children():
		if not badge.visible: continue
		var unit = lab.queries.find_unit(badge.get_meta("unit_id"))
		display_checks += 1
		if badge.text.contains("방어 중") != unit.is_defending:
			expect(false, "badge %s shows defend=%s but engine is_defending=%s" % [unit.unit_id, badge.text.contains("방어 중"), unit.is_defending])
	var active = lab.engine.get("active_unit_state")
	if active != null and lab.selected == active.unit_id:
		display_checks += 1
		if lab.info.text.contains("방어 중") != active.is_defending:
			expect(false, "unit panel %s defend display differs from engine" % active.unit_id)

func run_defend_3d(tree: SceneTree, label: String) -> Dictionary:
	frames.clear()
	await open_lab(tree)
	var battle: Node = lab.engine
	var unit: BattleUnitState = defend_setup(battle, label)
	lab._sync_views()
	await tree.process_frame
	click(unit.grid_cell)
	if label == "D2_move_facing_defend":
		click(Vector2i(8,4))
		await wait_for(tree, "facing_select")
		lab._sync_views()
		expect(lab.defend_button.disabled and lab.defend_button.tooltip_text.begins_with("행동 불가"), label + " defend disabled while facing must be confirmed")
		for button in lab.facing_ui.get_children():
			if button.text == "방향 left": button.pressed.emit()
	lab._sync_views()
	expect(battle.get("active_unit_state") == unit, label + " clicked unit is the engine's active unit")
	expect(not lab.defend_button.disabled, label + " defend button enabled for an unacted selected ally")
	var troops_before: int = unit.current_troops
	press_defend()
	var after_call := {"troops":unit.current_troops, "defending":unit.is_defending, "acted":unit.has_acted, "round":battle.get("battle_round")}
	expect(lab.status.text == "방어 · %s / 병력 %s→%s · 이후 적 자동 행동" % [unit.unit_id, troops_before, unit.current_troops], label + " status shows engine troops " + lab.status.text)
	display_probe(tree)
	await settle_lab(tree, label, display_probe)
	var result := final_state(battle)
	result["lab"] = lab_view()
	result["defender"] = unit.unit_id
	result["recovered"] = after_call.troops - troops_before
	result["after_call"] = after_call
	return result
