extends SceneTree
# M5-a stop and refusals. Stop is accepted at any moment of auto (during an ally
# action, during the enemy replay, right after the start); the running action
# completes, then manual input works and the 3D selection follows the engine.
# During auto every other command is refused with no engine write; a second
# press in the same frame sends nothing; auto cannot start during an
# animation, the enemy turn, or after the battle end.
var h

func _initialize() -> void:
	run.call_deferred()

func refused(label: String, action: Callable, prefix: String) -> void:
	var lab = h.lab
	var writes: int = lab.engine.writes.size()
	var rejects: int = lab.rejected
	action.call()
	h.expect(lab.engine.writes.size() == writes, label + " no engine write " + str(lab.engine.writes.slice(writes)))
	h.expect(lab.rejected == rejects + 1 and lab.status.text.begins_with("거절 / " + prefix), label + " refused: " + lab.status.text)

func settle_manual(label: String) -> void:
	var lab = h.lab
	for i in range(6000):
		await process_frame
		if lab.engine.current_phase in ["ally_turn", "facing_select"] and not lab.engine.is_demo_animating and not lab._enemy_presentation_busy() and not lab.engine.is_full_auto_battle_enabled: break
	for i in range(30): await process_frame
	lab._sync_views()
	# A stop during an auto move hands the unit back in the engine's facing select (no auto facing).
	if lab.engine.current_phase == "facing_select":
		h.expect(lab.facing_ui.visible, label + " stopped mid-move: 3D shows the facing choice")
		for button in lab.facing_ui.get_children():
			if button.text == "방향 left": button.pressed.emit()
		await process_frame
		lab._sync_views()
	h.expect(lab.engine.current_phase == "ally_turn" and not lab.engine.is_full_auto_battle_enabled, label + " back to a manual ally turn")

func manual_after_stop(label: String) -> void:
	var lab = h.lab
	var battle: Node = lab.engine
	await settle_manual(label)
	var active = battle.active_unit_state
	h.expect(active != null and lab.selected == active.unit_id and lab.ring.visible, label + " 3D selection == engine active unit")
	h.expect(lab.range_view.get_child_count() == 0 and lab.target_marks.get_child_count() == 0, label + " no stale range or target marks")
	h.expect(lab.auto_button.text == "자동 ▶" and not lab.auto_button.disabled, label + " auto button ready again")
	var writes: int = battle.writes.size()
	h.press_wait()
	h.expect(battle.writes.slice(writes) == ["_end_ally_turn_by_wait"] and lab.combat_lines.has("대기 · " + active.unit_id), label + " manual wait accepted after stop")

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_auto_harness.gd").new()
	# Stop during an ally action.
	await h.open_lab(self)
	var lab = h.lab
	var battle: Node = lab.engine
	h.press_auto()
	await process_frame
	for i in range(600):
		await process_frame
		if battle.is_demo_animating and battle.current_phase != "enemy_turn": break
	h.expect(battle.is_demo_animating, "an ally auto action is animating")
	h.press_auto()
	h.expect(not battle.is_full_auto_battle_enabled and battle.writes.count("_toggle_full_auto_battle") == 2, "stop during an ally action accepted")
	h.expect(lab.auto_texts[-1] == "자동 중지 · 진행 중인 행동이 끝나면 수동 조작", "stop shown")
	await manual_after_stop("stop during ally action")
	await h.close_lab(self)
	# Stop during the enemy replay.
	await h.open_lab(self)
	lab = h.lab
	battle = lab.engine
	h.press_auto()
	for i in range(6000):
		await process_frame
		if lab._enemy_presentation_busy() and battle.is_full_auto_battle_enabled: break
	h.expect(lab._enemy_presentation_busy(), "enemy replay running")
	h.press_auto()
	h.expect(not battle.is_full_auto_battle_enabled, "stop during the enemy replay accepted")
	await manual_after_stop("stop during enemy replay")
	await h.close_lab(self)
	# Double press in the same frame: one toggle; stop on the next frame.
	await h.open_lab(self)
	lab = h.lab
	battle = lab.engine
	h.press_auto()
	refused("second press in the same frame", h.press_auto, "연타")
	h.expect(battle.writes.count("_toggle_full_auto_battle") == 1 and battle.is_full_auto_battle_enabled, "double press sent one toggle")
	# During auto: every other command refused, no engine write.
	await process_frame
	var ally = battle.get("all_battle_unit_states")[0]
	refused("click an ally during auto", func(): h.click(ally.grid_cell), "자동 진행 중")
	refused("click a cell during auto", func(): h.click(Vector2i(6,5)), "자동 진행 중")
	refused("right-click during auto", func(): h.click(ally.grid_cell, MOUSE_BUTTON_RIGHT), "자동 진행 중")
	for pair in [[h.press_attack, "attack"], [h.press_wait, "wait"], [h.press_defend, "defend"], [h.press_strategy, "strategy"], [h.press_skill, "skill"]]:
		refused(pair[1] + " during auto", pair[0], "자동 진행 중")
	for button in lab.facing_ui.get_children():
		refused(button.text + " during auto", func(): button.pressed.emit(), "자동 진행 중")
	await process_frame
	h.press_auto()
	h.expect(not battle.is_full_auto_battle_enabled, "stop on the next frame")
	await manual_after_stop("stop right after start")
	await h.close_lab(self)
	# Start refused during an animation and during the enemy turn (manual attack fixture).
	await h.open_lab(self)
	lab = h.lab
	battle = lab.engine
	h.setup(battle, "M6_infantry_attack")
	var r: Dictionary = h.roles(battle)
	lab._sync_views()
	await process_frame
	h.click(r.ally.grid_cell)
	h.press_attack()
	h.click(r.bag.grid_cell)
	h.expect(battle.is_demo_animating, "manual attack animating")
	refused("start during an animation", h.press_auto, "연출 중")
	var saw_enemy_turn := false
	for i in range(3000):
		await process_frame
		if battle.current_phase == "enemy_turn" and not saw_enemy_turn:
			saw_enemy_turn = true
			refused("start during the enemy turn", h.press_auto, "적 턴 중")
		if battle.current_phase == "ally_turn" and not battle.is_demo_animating and not lab._enemy_presentation_busy(): break
	h.expect(saw_enemy_turn and battle.writes.count("_toggle_full_auto_battle") == 0, "no toggle sent while refused")
	await h.close_lab(self)
	# After the battle end (victory by the real attack flow).
	await h.open_lab(self)
	lab = h.lab
	battle = lab.engine
	h.setup(battle, "M13_enemy_wipe_victory")
	r = h.roles(battle)
	lab._sync_views()
	await process_frame
	h.click(r.ally.grid_cell)
	h.press_attack()
	h.click(r.bag.grid_cell)
	await h.settle_lab(self, "victory")
	lab._sync_views()
	h.expect(lab.auto_button.disabled, "auto disabled after the end")
	refused("start after the battle end", h.press_auto, "전투 종료")
	h.expect(battle.writes.count("_toggle_full_auto_battle") == 0 and battle.worldmap_calls == 0, "no toggle, no world map")
	await h.close_lab(self)
	h.expect(Engine.time_scale == 1.0, "time scale untouched by these runs")
	print("[M5A_AUTO_STOP_REJECTIONS] checks=", h.checks, " failures=", h.failures)
	quit(0 if h.failures.is_empty() else 1)
