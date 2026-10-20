extends SceneTree
# M3-b wait refusals. A spy records every engine write; a refused wait must
# add none. Engine refusal (confused ally) must be shown as a refusal.
var h
var fired := {}

func _initialize() -> void:
	run.call_deferred()

func waits(battle: Node) -> int:
	return battle.writes.count("_end_ally_turn_by_wait")

func refused(label: String, reason_prefix: String) -> void:
	var lab = h.lab
	var battle: Node = lab.engine
	var writes: int = battle.writes.size()
	var rejects: int = lab.rejected
	lab._sync_views()
	h.expect(lab.wait_button.disabled, label + " wait button disabled")
	h.press_wait()
	h.expect(battle.writes.size() == writes, label + " no engine write call " + str(battle.writes.slice(writes)))
	h.expect(lab.rejected == rejects + 1, label + " one visible rejection")
	h.expect(lab.status.text.begins_with("거절 / " + reason_prefix), label + " reason: " + lab.status.text)

func window_probe(tree: SceneTree) -> void:
	var lab = h.lab
	var phase: String = lab.engine.get("current_phase")
	if phase == "enemy_turn" and not fired.has("enemy_turn"):
		fired["enemy_turn"] = true
		refused("during engine enemy_turn", "적 턴 중")
	if phase == "ally_turn" and not lab.engine.get("is_demo_animating") and (not lab.enemy_queue.is_empty() or lab.enemy_hold > 0.0) and not fired.has("queue"):
		fired["queue"] = true
		refused("during playback queue", "적 행동 재생 중")

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_wait_harness.gd").new()
	# a/b/c: double press, engine enemy turn, playback queue (two enemy slots with paths).
	fired.clear()
	await h.open_lab(self)
	var lab = h.lab
	var battle: Node = lab.engine
	h.setup(battle, "M10_round_two_slots")
	lab._sync_views()
	await process_frame
	h.click(h.roles(battle).ally.grid_cell)
	lab._sync_views()
	h.press_wait()
	var rejects: int = lab.rejected
	h.press_wait()
	h.expect(waits(battle) == 1, "double press sends one wait")
	h.expect(lab.rejected == rejects + 1 and lab.status.text.begins_with("거절 / 적 턴 중"), "second press refused: " + lab.status.text)
	await h.settle_lab(self, "two slots", window_probe)
	h.expect(fired.has("enemy_turn") and fired.has("queue"), "both lock windows observed " + str(fired.keys()))
	lab._sync_views()
	h.expect(not lab.wait_button.disabled, "wait enabled again after playback for the next ally")
	await h.close_lab(self)
	# d/e/f-facing: already acted, no selection, facing must be confirmed first.
	for label in ["acted", "no_selection", "facing_select"]:
		await h.open_lab(self)
		lab = h.lab
		battle = lab.engine
		h.setup(battle, "M6_infantry_attack")
		var ally: BattleUnitState = h.roles(battle).ally
		if label == "acted":
			ally.has_acted = true
			battle.get("action_lock_state_service").register_unit_acted(ally, "ally")
		lab._sync_views()
		await process_frame
		if label != "no_selection": h.click(ally.grid_cell)
		if label == "no_selection": battle.active_unit_state = null # fixture: engine with no active unit
		if label == "facing_select":
			h.click(Vector2i(8,5))
			await h.wait_for(self, "facing_select")
		var before: Array = battle.writes.duplicate()
		refused(label, {"acted":"대기 불가 · 이미 행동한 부대", "no_selection":"대기 불가 · 먼저 아군을 선택", "facing_select":"행동 불가 · 현재 선택 단계"}[label])
		h.expect(battle.writes == before, label + " writes unchanged")
		await h.close_lab(self)
	# Engine refusal: a confused ally passes the 3D guidance; the engine refuses.
	await h.open_lab(self)
	lab = h.lab
	battle = lab.engine
	h.setup(battle, "M6_infantry_attack")
	var confused: BattleUnitState = h.roles(battle).ally
	confused.apply_status_effect("confusion", 2, 0)
	lab._sync_views()
	await process_frame
	h.click(confused.grid_cell)
	lab._sync_views()
	h.expect(not lab.wait_button.disabled, "3D does not compute the confusion rule (button enabled)")
	var snap: Dictionary = h.final_state(battle)
	rejects = lab.rejected
	h.press_wait()
	h.expect(waits(battle) == 1, "wait sent to the engine once")
	h.expect(lab.rejected == rejects + 1 and lab.status.text == "거절 / 행동 불가 · 엔진이 대기를 수락하지 않았습니다", "engine refusal shown as refusal: " + lab.status.text)
	var after: Dictionary = h.final_state(battle)
	h.expect(h.fingerprint.diff(snap.units, after.units).is_empty() and battle.current_phase == "ally_turn", "engine refusal changed no unit state")
	h.expect(not lab.combat_lines.has("대기 · " + confused.unit_id), "refused wait not logged as done")
	await h.close_lab(self)
	# f: after victory / defeat (battle ended by the real attack flow).
	for label in ["M13_enemy_wipe_victory", "M12_ally_wipe_defeat"]:
		await h.open_lab(self)
		lab = h.lab
		battle = lab.engine
		h.setup(battle, label)
		lab._sync_views()
		await process_frame
		var r: Dictionary = h.roles(battle)
		h.click(r.ally.grid_cell)
		h.press_attack()
		h.click(r.bag.grid_cell)
		await h.settle_lab(self, label)
		var alive_ally = null
		for unit in battle.all_battle_unit_states:
			if unit.side == "ally" and unit.is_alive() and not unit.has_acted and battle._is_unit_state_available_for_battle_slot(unit): alive_ally = unit
		for i in range(2):
			refused(label + " after end " + str(i), "전투 종료")
			if alive_ally != null:
				h.click(alive_ally.grid_cell)
				refused(label + " after end, clicking another ally " + str(i), "전투 종료")
		# Fixture: expose an unacted live ally as active after the end, so only
		# the result lock (not the acted/no-selection guidance) can refuse.
		var spare: BattleUnitState = h.roles(battle).units[1]
		spare.current_hp = 300
		spare.current_troops = 300
		spare.has_acted = false
		battle.active_unit_state = spare
		lab._sync_views()
		h.expect(lab._wait_block_reason().begins_with("전투 종료"), label + " guidance reports the end first")
		refused(label + " after end with an unacted active ally", "전투 종료")
		h.expect(waits(battle) == 0 and battle.defend_calls == 0 and battle.worldmap_calls == 0, label + " no wait/defend/world-map call")
		await h.close_lab(self)
	# Isolation: a fresh lab starts with wait available and no residue.
	var children := root.get_child_count()
	await h.open_lab(self)
	lab = h.lab
	lab._sync_views()
	h.expect(not lab.wait_button.disabled and lab.battle_result.is_empty() and lab.enemy_cursor == 0 and lab.enemy_queue.is_empty(), "fresh lab: wait available, no residue")
	h.expect(lab.engine.writes.is_empty() or lab.engine.writes == ["_select_ally_unit"], "fresh lab: no stray engine writes " + str(lab.engine.writes))
	await h.close_lab(self)
	h.expect(root.get_child_count() == children, "no leftover lab/engine node")
	print("[M3B_WAIT_REJECTIONS] checks=", h.checks, " failures=", h.failures)
	quit(0 if h.failures.is_empty() else 1)
