extends SceneTree
# M3: input lock while the engine or the 3D playback queue is busy, result
# lock priority, cursor independence and lab isolation.
var h
var fired := {}

func _initialize() -> void:
	run.call_deferred()

func fire_all_inputs(label: String) -> Dictionary:
	var lab = h.lab
	var battle: Node = lab.engine
	var r: Dictionary = h.roles(battle)
	var writes: int = battle.writes.size()
	var rejects: int = lab.rejected
	h.click(r.ally.grid_cell)
	h.click(Vector2i(5,2))
	h.press_attack()
	var key := InputEventKey.new()
	key.keycode = KEY_F
	key.pressed = true
	lab._unhandled_input(key)
	h.click(r.ally.grid_cell, MOUSE_BUTTON_RIGHT)
	for button in lab.facing_ui.get_children(): button.pressed.emit()
	h.expect(battle.writes.size() == writes, label + " no engine write call " + str(battle.writes.slice(writes)))
	h.expect(lab.rejected > rejects, label + " visible rejection")
	return {"status":lab.status.text}

func lock_probe(tree: SceneTree) -> void:
	var lab = h.lab
	var phase: String = lab.engine.get("current_phase")
	var animating: bool = lab.engine.get("is_demo_animating")
	if phase == "enemy_turn" and not fired.has("enemy_turn"):
		fired["enemy_turn"] = fire_all_inputs("engine enemy_turn")
		h.expect(fired["enemy_turn"].status.contains("적 턴") or fired["enemy_turn"].status.contains("연출 중"), "enemy_turn reason text")
		lab._sync_views()
		var ally_id: String = h.roles(lab.engine).ally.unit_id
		for badge in lab.action_badges.get_children():
			if badge.get_meta("unit_id") == ally_id: h.expect(badge.text == "행동 완료", "attacked ally badge shows engine has_acted")
		h.expect(lab.turn_label.text.begins_with("라운드 1 · 적 턴"), "turn label shows enemy side " + lab.turn_label.text)
	# Window detected from the queue itself, not from the lock helper under test.
	if phase == "ally_turn" and not animating and (not lab.enemy_queue.is_empty() or lab.enemy_hold > 0.0) and not fired.has("queue"):
		# Engine already allows input here; only the 3D playback queue holds it.
		fired["queue"] = fire_all_inputs("playback queue")
		h.expect(fired["queue"].status.contains("적 행동 재생 중"), "queue reason text")
	if lab.enemy_moving_id != "" and not fired.has("moving"):
		fired["moving"] = fire_all_inputs("enemy path playback")

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_enemy_turn_harness.gd").new()
	# A. Locks during a two-slot enemy turn with path playback.
	fired.clear()
	var td: Dictionary = await h.run_3d(self, "M10_round_two_slots", lock_probe)
	h.expect(fired.has("enemy_turn") and fired.has("queue") and fired.has("moving"), "all lock windows observed " + str(fired.keys()))
	var lab = h.lab
	var battle: Node = lab.engine
	h.expect(not lab._enemy_presentation_busy() and lab.status.text.begins_with("아군 조작 가능"), "status returns to ally control after playback")
	var writes: int = battle.writes.size()
	h.click(h.roles(battle).ally.grid_cell)
	h.expect(battle.writes.size() == writes + 1 and battle.writes[-1] == "_select_ally_unit", "input accepted only after playback queue is empty")
	# B. Cursor independence: each consumer advances only its own cursor once.
	var before: Array = [lab.event_cursor, lab.action_cursor, lab.enemy_cursor]
	var counts: Array = [lab.played_paths.size(), lab.damage_presentations.size(), lab.enemy_damage_presentations.size(), lab.enemy_summaries.size(), lab.enemy_played_paths.size()]
	for i in range(3):
		lab._consume_enemy_events()
		h.expect([lab.event_cursor, lab.action_cursor] == [before[0], before[1]], "enemy consumer leaves other cursors")
		lab._consume_action_events()
		lab._consume_events()
	h.expect([lab.event_cursor, lab.action_cursor, lab.enemy_cursor] == before, "repeated polling keeps cursors")
	h.expect([lab.played_paths.size(), lab.damage_presentations.size(), lab.enemy_damage_presentations.size(), lab.enemy_summaries.size(), lab.enemy_played_paths.size()] == counts and lab.enemy_queue.is_empty(), "no duplicate consumption")
	h.expect(before == [battle.ally_move_event_log.export().size(), battle.battle_action_event_log.export().size(), battle.enemy_action_event_log.export().size()], "cursor i reads log i")
	h.expect(lab.action_cursor != lab.enemy_cursor, "action and enemy sequences are separate in this case")
	await h.close_lab(self)
	# C. Battle end: result outranks phase/queue, every input refused, no world-map call.
	for label in ["M13_enemy_wipe_victory", "M12_ally_wipe_defeat"]:
		var probe := func(tree: SceneTree) -> void:
			var l = h.lab
			if l.engine.enemy_action_event_log.export().any(func(e): return e.kind == "battle_ended") and not fired.has(label):
				fired[label] = true
				h.expect(l._input_locked() and l.status.text.begins_with("거절 / 전투 종료"), label + " locked on the frame battle_ended is logged")
		await h.run_3d(self, label, probe)
		lab = h.lab
		battle = lab.engine
		var result: String = {"M13_enemy_wipe_victory":"victory", "M12_ally_wipe_defeat":"defeat"}[label]
		h.expect(battle._get_battle_result_state() == result and lab.battle_result == result, label + " engine and lab result")
		h.expect(lab.result_overlay.visible and lab.result_overlay.text == {"victory":"승리","defeat":"패배"}[result], label + " overlay")
		if label == "M13_enemy_wipe_victory":
			h.expect(battle.current_phase == "ally_turn" and not battle.is_demo_animating and not lab._enemy_presentation_busy(), "victory: phase alone would allow input")
		else:
			h.expect(battle.current_phase == "enemy_turn", "defeat: phase stays enemy_turn")
		for i in range(2):
			var status: Dictionary = fire_all_inputs(label + " after end " + str(i))
			h.expect(status.status.contains("전투 종료"), label + " end reason text")
			await process_frame
		h.expect(lab.attack_button.disabled and not lab.facing_ui.visible, label + " controls disabled")
		h.expect(battle.worldmap_calls == 0, label + " no world-map/result handoff call")
		await h.close_lab(self)
	# D. Isolation: a new lab starts clean; audio and nodes are released.
	var children := root.get_child_count()
	await h.open_lab(self)
	lab = h.lab
	h.expect(lab.enemy_cursor == 0 and lab.enemy_queue.is_empty() and lab.battle_result.is_empty() and not lab.result_overlay.visible, "restart has no enemy residue")
	h.expect(lab.enemy_summaries.is_empty() and lab.enemy_played_paths.is_empty() and lab.enemy_damage_presentations.is_empty() and lab.current_round == 1, "restart presentation state clean")
	h.expect(lab.engine.enemy_action_event_log.export().is_empty(), "new engine has an empty enemy log")
	await h.close_lab(self)
	h.expect(root.get_child_count() == children, "no leftover lab/engine node")
	var audio = root.get_node_or_null("GameAudio")
	if audio:
		for voice in audio.get_children():
			if voice is AudioStreamPlayer: h.expect(not voice.playing, "audio stopped " + voice.name)
	print("[M3_LOCKS] checks=", h.checks, " failures=", h.failures)
	quit(0 if h.failures.is_empty() else 1)
