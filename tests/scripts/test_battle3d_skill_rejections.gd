extends SceneTree
# M4-c1 unique skill refusals. A spy records every engine write; a refused
# skill step adds none (the right-click cancel adds only the existing cancel call).
var h
var fired := {}

func _initialize() -> void:
	run.call_deferred()

func skill_calls(battle: Node) -> int:
	return battle.writes.count("_on_unique_skill_button_pressed") + battle.writes.count("_try_use_unique_skill_on_target")

func refused_button(label: String, reason_prefix: String, disabled := true) -> void:
	var lab = h.lab
	var battle: Node = lab.engine
	var writes: int = battle.writes.size()
	var rejects: int = lab.rejected
	lab._sync_views()
	if disabled: h.expect(lab.skill_button.disabled, label + " skill button disabled")
	h.press_skill()
	h.expect(battle.writes.size() == writes, label + " no engine write call " + str(battle.writes.slice(writes)))
	h.expect(lab.rejected == rejects + 1, label + " one visible rejection")
	h.expect(lab.status.text.begins_with("거절 / " + reason_prefix), label + " reason: " + lab.status.text)

func refused_click(label: String, cell: Vector2i, reason_prefix: String, button := MOUSE_BUTTON_LEFT) -> void:
	var lab = h.lab
	var battle: Node = lab.engine
	var writes: int = battle.writes.size()
	var rejects: int = lab.rejected
	h.click(cell, button)
	h.expect(battle.writes.size() == writes, label + " no engine write call " + str(battle.writes.slice(writes)))
	h.expect(lab.rejected == rejects + 1 and lab.status.text.begins_with("거절 / " + reason_prefix), label + " refused: " + lab.status.text)

func open_case(label: String) -> Dictionary:
	await h.open_lab(self)
	var s: Dictionary = h.skill_setup(h.lab.engine, label)
	h.lab._sync_views()
	await process_frame
	return s

func window_probe(tree: SceneTree) -> void:
	var lab = h.lab
	var phase: String = lab.engine.get("current_phase")
	if lab.engine.get("is_unique_skill_presenting") and not fired.has("presenting"):
		fired["presenting"] = true
		refused_button("during the skill presentation", "연출 중")
	if phase == "enemy_turn" and not fired.has("enemy_turn"):
		fired["enemy_turn"] = true
		refused_button("during engine enemy_turn", "적 턴 중")
	if phase == "ally_turn" and not lab.engine.get("is_demo_animating") and (not lab.enemy_queue.is_empty() or lab.enemy_hold > 0.0) and not fired.has("queue"):
		fired["queue"] = true
		refused_button("during playback queue", "적 행동 재생 중")

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_skill_harness.gd").new()
	# Double send, presentation, engine enemy turn, playback queue (manual target mode).
	fired.clear()
	var s: Dictionary = await open_case("K_single_burst")
	var lab = h.lab
	var battle: Node = lab.engine
	var enemy: BattleUnitState = s.units[5]
	h.click(s.caster.grid_cell)
	h.press_skill()
	h.click(enemy.grid_cell)
	h.expect(battle.writes.count("_try_use_unique_skill_on_target") == 1, "target call sent once")
	refused_click("second target click (double send)", enemy.grid_cell, "연출 중")
	refused_click("right-click during the presentation", enemy.grid_cell, "연출 중", MOUSE_BUTTON_RIGHT)
	await h.settle_lab(self, "manual skill", window_probe)
	h.expect(fired.has("presenting") and fired.has("enemy_turn") and fired.has("queue"), "presentation, enemy turn and queue windows observed " + str(fired.keys()))
	h.expect(skill_calls(battle) == 2 and battle.tactic_event_log.export().filter(func(e): return e.kind == "skill_cast").size() == 1, "one skill committed")
	await h.close_lab(self)
	# Self-resolving mode: button only; the engine preview locks every input (no cancel sent).
	s = await open_case("K_adjacent_aoe")
	lab = h.lab
	battle = lab.engine
	h.click(s.caster.grid_cell)
	h.press_skill()
	h.expect(battle.get("is_manual_unique_skill_preview_pending") and battle.writes.count("_try_use_unique_skill_on_target") == 0, "preview started by the button alone")
	refused_button("button during the preview", "연출 중")
	refused_click("click during the preview", s.units[5].grid_cell, "연출 중")
	refused_click("right-click during the preview", s.units[5].grid_cell, "연출 중", MOUSE_BUTTON_RIGHT)
	h.expect(not battle.writes.has("_handle_right_click_cancel"), "no cancel sent during the preview")
	await h.settle_lab(self, "auto skill")
	h.expect(battle.writes.count("_on_unique_skill_button_pressed") == 1 and battle.tactic_event_log.export().filter(func(e): return e.kind == "skill_cast").size() == 1, "the preview fired the skill once")
	await h.close_lab(self)
	# Guidance refusals before the button: acted, no selection, momentum short, no target, confused.
	for label in ["acted", "no_selection", "momentum", "no_target", "confused"]:
		s = await open_case("K_single_burst")
		lab = h.lab
		battle = lab.engine
		var caster: BattleUnitState = s.caster
		if label == "acted":
			caster.has_acted = true
			battle.get("action_lock_state_service").register_unit_acted(caster, "ally")
		if label == "momentum":
			var momentum = battle.battle_momentum
			momentum.spend("ally", momentum.get_value("ally") - 1, "fixture")
		if label == "no_target":
			for i in [5, 6, 7]: h.tactic._setup_unit(s.units[i], "infantry", [Vector2i(17,9), Vector2i(16,9), Vector2i(15,9)][i - 5])
			h.tactic._sync(battle, s.units)
		if label == "confused": caster.apply_status_effect("confusion", 2, 0)
		lab._sync_views()
		if label != "no_selection": h.click(caster.grid_cell)
		if label == "no_selection": battle.active_unit_state = null # fixture: engine with no active unit
		refused_button(label, {"acted":"특기 불가 · 이미 행동한 부대", "no_selection":"특기 불가 · 먼저 아군을 선택",
			"momentum":"특기 불가 · 기세가 부족합니다 (필요 %d / 현재 1)" % int(s.skill.momentum_cost), "no_target":"특기 불가 · 유효 대상이 없습니다",
			"confused":"특기 불가 · 엔진 조건을 충족하지 않습니다"}[label])
		h.expect(skill_calls(battle) == 0, label + " no skill call")
		await h.close_lab(self)
	# Target select: invalid clicks, then right-click cancel.
	s = await open_case("K_single_burst")
	lab = h.lab
	battle = lab.engine
	var momentum_before: int = battle.battle_momentum.get_value("ally")
	h.click(s.caster.grid_cell)
	h.press_skill()
	h.expect(battle.current_phase == "unique_skill_target_select", "skill target select entered")
	var valid: Array = battle.call("_get_unique_skill_valid_targets", s.caster, s.skill).map(func(u): return u.unit_id)
	h.expect(not valid.has(s.units[6].unit_id), "units[6] is not an engine target")
	refused_click("enemy outside the engine targets", s.units[6].grid_cell, "대상 아님")
	refused_click("ally as target", s.units[1].grid_cell, "대상 아님")
	refused_click("empty cell", Vector2i(12,7), "대상 아님")
	h.expect(battle.writes.count("_try_use_unique_skill_on_target") == 0 and battle.current_phase == "unique_skill_target_select", "still selecting, no target call")
	var writes_before: int = battle.writes.size()
	h.click(s.caster.grid_cell, MOUSE_BUTTON_RIGHT)
	lab._sync_views()
	h.expect(battle.writes.slice(writes_before) == ["_handle_right_click_cancel"], "cancel sends only the existing cancel call " + str(battle.writes.slice(writes_before)))
	h.expect(battle.current_phase == "ally_turn" and not s.caster.has_acted and lab.skill_target_ids.is_empty() and lab.skill_marks.get_child_count() == 0, "cancel restores the ally turn, clears marks, not acted")
	h.expect(battle.battle_momentum.get_value("ally") == momentum_before and battle.tactic_event_log.export().is_empty(), "cancel spends no momentum, records no skill")
	await h.close_lab(self)
	# Engine refusal at the target call: the caster becomes confused (fixture) after the
	# target select opened; the engine cancels, 3D shows a refusal.
	s = await open_case("K_single_burst")
	lab = h.lab
	battle = lab.engine
	h.click(s.caster.grid_cell)
	h.press_skill()
	s.caster.apply_status_effect("confusion", 2, 0)
	var rejects: int = lab.rejected
	h.click(s.units[5].grid_cell)
	h.expect(battle.writes.count("_try_use_unique_skill_on_target") == 1, "engine refusal: the target call was sent once")
	h.expect(lab.rejected == rejects + 1 and lab.status.text == "거절 / 행동 불가 · 엔진이 특기를 수락하지 않았습니다", "engine refusal shown as refusal: " + lab.status.text)
	h.expect(battle.tactic_event_log.export().is_empty() and not s.caster.has_acted and lab.skill_presentations.is_empty(), "nothing recorded or shown as done")
	await h.close_lab(self)
	# After victory / defeat (battle ended by the real attack flow).
	for label in ["M13_enemy_wipe_victory", "M12_ally_wipe_defeat"]:
		await h.open_lab(self)
		lab = h.lab
		battle = lab.engine
		h.setup(battle, label)
		var r: Dictionary = h.roles(battle)
		lab._sync_views()
		await process_frame
		h.click(r.ally.grid_cell)
		h.press_attack()
		h.click(r.bag.grid_cell)
		await h.settle_lab(self, label)
		var spare: BattleUnitState = r.units[1]
		spare.current_hp = 300
		spare.current_troops = 300
		spare.has_acted = false
		battle.get("action_lock_state_service").erase_unit_id(spare.unit_id)
		battle.active_unit_state = spare
		lab._sync_views()
		h.expect(lab._skill_block_reason().begins_with("전투 종료"), label + " guidance reports the end first")
		refused_button(label + " after end", "전투 종료")
		h.expect(skill_calls(battle) == 0 and battle.worldmap_calls == 0, label + " no skill/world-map call")
		await h.close_lab(self)
	# The ally skill itself ends the battle (last enemy killed by the skill).
	s = await open_case("K_single_burst")
	lab = h.lab
	battle = lab.engine
	for i in [6, 7, 8, 9]: h.oracle._kill_for_fixture(s.units[i])
	s.units[5].current_hp = 3
	s.units[5].current_troops = 3
	battle.call("_cleanup_dead_units")
	h.tactic._sync(battle, s.units)
	lab._sync_views()
	h.click(s.caster.grid_cell)
	h.press_skill()
	h.click(s.units[5].grid_cell)
	await h.settle_lab(self, "skill victory")
	h.expect(battle.call("_get_battle_result_state") == "victory" and lab.battle_result == "victory" and lab.result_overlay.visible, "skill kill ends the battle; 3D shows the result " + lab.battle_result)
	h.expect(lab.skill_texts.any(func(x): return x.contains("격파")), "the kill is shown from the event")
	var spare: BattleUnitState = s.units[1]
	spare.has_acted = false
	battle.get("action_lock_state_service").erase_unit_id(spare.unit_id)
	battle.active_unit_state = spare
	lab._sync_views()
	refused_button("right after the skill victory", "전투 종료")
	refused_click("click after the skill victory", s.caster.grid_cell, "전투 종료")
	h.expect(skill_calls(battle) == 2 and battle.worldmap_calls == 0, "no further skill call, no world-map call")
	await h.close_lab(self)
	# Isolation: a fresh lab starts with no skill residue.
	var children := root.get_child_count()
	await h.open_lab(self)
	lab = h.lab
	lab._sync_views()
	h.expect(lab.tactic_cursor == 0 and lab.skill_presentations.is_empty() and lab.skill_texts.is_empty() and lab.skill_target_ids.is_empty() and lab.momentum_note.is_empty(), "fresh lab: no skill residue")
	h.expect(lab.momentum_label.text == "기세 아군 3 / 적 3", "fresh lab: momentum HUD from the engine " + lab.momentum_label.text)
	await h.close_lab(self)
	h.expect(root.get_child_count() == children, "no leftover lab/engine node")
	print("[M4C1_SKILL_REJECTIONS] checks=", h.checks, " failures=", h.failures)
	quit(0 if h.failures.is_empty() else 1)
