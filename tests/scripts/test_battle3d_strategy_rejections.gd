extends SceneTree
# M4-b strategy refusals. A spy records every engine write; a refused strategy
# step adds none (the right-click cancel adds only the existing cancel call).
var h
var fired := {}

func _initialize() -> void:
	run.call_deferred()

func strategy_calls(battle: Node) -> int:
	return battle.writes.count("_on_strategy_button_pressed") + battle.writes.count("_try_use_strategy_on_target")

func refused_button(label: String, reason_prefix: String) -> void:
	var lab = h.lab
	var battle: Node = lab.engine
	var writes: int = battle.writes.size()
	var rejects: int = lab.rejected
	lab._sync_views()
	h.expect(lab.strategy_button.disabled, label + " strategy button disabled")
	h.press_strategy()
	h.expect(battle.writes.size() == writes, label + " no engine write call " + str(battle.writes.slice(writes)))
	h.expect(lab.rejected == rejects + 1, label + " one visible rejection")
	h.expect(lab.status.text.begins_with("거절 / " + reason_prefix), label + " reason: " + lab.status.text)

func refused_click(label: String, cell: Vector2i, reason_prefix: String) -> void:
	var lab = h.lab
	var battle: Node = lab.engine
	var writes: int = battle.writes.size()
	var rejects: int = lab.rejected
	h.click(cell)
	h.expect(battle.writes.size() == writes, label + " no engine write call " + str(battle.writes.slice(writes)))
	h.expect(lab.rejected == rejects + 1 and lab.status.text.begins_with("거절 / " + reason_prefix), label + " refused: " + lab.status.text)

func open_case(fixture: String, intelligence := 95) -> Dictionary:
	await h.open_lab(self)
	var battle: Node = h.lab.engine
	h.setup(battle, fixture)
	var r: Dictionary = h.roles(battle)
	r.ally.intelligence = intelligence
	r.enemy.intelligence = 70
	battle.strategy_roll_override = h.forced_roll(true, 0)
	h.lab._sync_views()
	await process_frame
	return r

func window_probe(tree: SceneTree) -> void:
	var lab = h.lab
	var phase: String = lab.engine.get("current_phase")
	if phase == "enemy_turn" and not fired.has("enemy_turn"):
		fired["enemy_turn"] = true
		refused_button("during engine enemy_turn", "적 턴 중")
	if phase == "ally_turn" and not lab.engine.get("is_demo_animating") and (not lab.enemy_queue.is_empty() or lab.enemy_hold > 0.0) and not fired.has("queue"):
		fired["queue"] = true
		refused_button("during playback queue", "적 행동 재생 중")

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_strategy_harness.gd").new()
	# Double send, engine enemy turn, playback queue (shaken enemy moves and attacks).
	fired.clear()
	var r: Dictionary = await open_case("M10_round_two_slots")
	var lab = h.lab
	var battle: Node = lab.engine
	h.click(r.ally.grid_cell)
	lab._sync_views()
	h.press_strategy()
	h.click(r.enemy.grid_cell)
	var rejects: int = lab.rejected
	h.click(r.enemy.grid_cell)
	h.expect(battle.writes.count("_try_use_strategy_on_target") == 1, "double click sends one target call")
	h.expect(lab.rejected == rejects + 1, "second click refused: " + lab.status.text)
	await h.settle_lab(self, "two slots", window_probe)
	h.expect(fired.has("enemy_turn") and fired.has("queue"), "both lock windows observed " + str(fired.keys()))
	await h.close_lab(self)
	# Already acted, no selection, low intelligence, confused ally (engine rule via the read query).
	for label in ["acted", "no_selection", "low_intelligence", "confused"]:
		r = await open_case("M6_infantry_attack", 70 if label == "low_intelligence" else 95)
		lab = h.lab
		battle = lab.engine
		if label == "acted":
			r.ally.has_acted = true
			battle.get("action_lock_state_service").register_unit_acted(r.ally, "ally")
		if label == "confused": r.ally.apply_status_effect("confusion", 2, 0)
		lab._sync_views()
		if label != "no_selection": h.click(r.ally.grid_cell)
		if label == "no_selection": battle.active_unit_state = null # fixture: engine with no active unit
		refused_button(label, {"acted":"책략 불가 · 이미 행동한 부대", "no_selection":"책략 불가 · 먼저 아군을 선택", "low_intelligence":"책략 불가 · 엔진 조건", "confused":"책략 불가 · 엔진 조건"}[label])
		h.expect(strategy_calls(battle) == 0, label + " no strategy call")
		await h.close_lab(self)
	# Target select: out-of-range enemy, ally clicked, empty cell; then right-click cancel.
	r = await open_case("M6_infantry_attack", 80)
	lab = h.lab
	battle = lab.engine
	h.click(r.ally.grid_cell)
	h.press_strategy()
	h.expect(battle.current_phase == "strategy", "strategy target select entered")
	var targets: Array = battle.call("_get_strategy_targets", r.ally).map(func(u): return u.unit_id)
	var far = r.units[7]
	h.expect(not targets.has(far.unit_id), "far enemy is out of the engine's strategy range")
	refused_click("out of range enemy", far.grid_cell, "대상 아님")
	refused_click("ally as target", r.units[1].grid_cell, "대상 아님")
	refused_click("empty cell", Vector2i(12,7), "대상 아님")
	h.expect(battle.writes.count("_try_use_strategy_on_target") == 0 and battle.current_phase == "strategy", "still selecting, no target call")
	var writes_before: int = battle.writes.size()
	h.click(r.ally.grid_cell, MOUSE_BUTTON_RIGHT)
	lab._sync_views()
	h.expect(battle.writes.slice(writes_before) == ["_handle_right_click_cancel"], "cancel sends only the existing cancel call " + str(battle.writes.slice(writes_before)))
	h.expect(battle.current_phase == "ally_turn" and not r.ally.has_acted and lab.strategy_target_ids.is_empty() and lab.strategy_marks.get_child_count() == 0, "cancel restores the ally turn, clears marks, not acted")
	h.expect(battle.tactic_event_log.export().is_empty(), "cancel records no strategy")
	await h.close_lab(self)
	# Engine refusal at the target call: the caster becomes confused (fixture)
	# after the target select opened; the engine cancels, 3D shows a refusal.
	r = await open_case("M6_infantry_attack", 95)
	lab = h.lab
	battle = lab.engine
	h.click(r.ally.grid_cell)
	h.press_strategy()
	r.ally.apply_status_effect("confusion", 2, 0)
	rejects = lab.rejected
	h.click(r.enemy.grid_cell)
	h.expect(battle.writes.count("_try_use_strategy_on_target") == 1, "engine refusal: the target call was sent once")
	h.expect(lab.rejected == rejects + 1 and lab.status.text == "거절 / 행동 불가 · 엔진이 책략을 수락하지 않았습니다", "engine refusal shown as refusal: " + lab.status.text)
	h.expect(battle.tactic_event_log.export().is_empty() and not r.ally.has_acted and lab.tactic_presentations.is_empty(), "nothing recorded or shown as done")
	await h.close_lab(self)
	# After victory / defeat (battle ended by the real attack flow).
	for label in ["M13_enemy_wipe_victory", "M12_ally_wipe_defeat"]:
		r = await open_case(label)
		lab = h.lab
		battle = lab.engine
		h.click(r.ally.grid_cell)
		h.press_attack()
		h.click(r.bag.grid_cell)
		await h.settle_lab(self, label)
		var spare: BattleUnitState = r.units[1]
		spare.current_hp = 300
		spare.current_troops = 300
		spare.has_acted = false
		spare.intelligence = 95
		battle.get("action_lock_state_service").erase_unit_id(spare.unit_id)
		battle.active_unit_state = spare
		lab._sync_views()
		h.expect(lab._strategy_block_reason().begins_with("전투 종료"), label + " guidance reports the end first")
		refused_button(label + " after end", "전투 종료")
		h.expect(strategy_calls(battle) == 0 and battle.worldmap_calls == 0, label + " no strategy/world-map call")
		await h.close_lab(self)
	# Isolation: a fresh lab starts with no strategy residue.
	var children := root.get_child_count()
	await h.open_lab(self)
	lab = h.lab
	lab._sync_views()
	h.expect(lab.tactic_cursor == 0 and lab.tactic_presentations.is_empty() and lab.pending_enemy_ticks.is_empty() and lab.strategy_target_ids.is_empty(), "fresh lab: no tactic residue")
	h.expect(lab.strategy_button.disabled and lab.strategy_button.tooltip_text.begins_with("책략 불가 · 사거리 안에 적이 없습니다"), "fresh default lab: no enemy in strategy range")
	await h.close_lab(self)
	h.expect(root.get_child_count() == children, "no leftover lab/engine node")
	print("[M4B_STRATEGY_REJECTIONS] checks=", h.checks, " failures=", h.failures)
	quit(0 if h.failures.is_empty() else 1)
