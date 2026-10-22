extends SceneTree
# M5-c: the option panel (top right) shows the engine's enemy AI level and its
# pending value, sends set_enemy_ai_level on a button (real GUI clicks), shows
# a refusal, folds, works during an enemy turn and during auto, and its clicks
# never reach the battlefield (no other engine write, selection unchanged). A
# level chosen in the ally turn applies at the next enemy turn start; one chosen
# during an enemy action leaves that action on the old flags.
var h

func _initialize() -> void:
	run.call_deferred()

func label(): return h.lab.ai_level_label.text

func wait_idle() -> void:
	for i in range(4000):
		await process_frame
		# The engine back in the ally turn and the 3D replay consumed (the M5-a2 busy check, cursors included).
		if h.lab.engine.current_phase == "ally_turn" and not h.lab._presentation_busy(): return

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_option_harness.gd").new()
	await h.open_lab(self)
	var lab = h.lab
	var b: Node = lab.engine
	lab._sync_views()
	h.expect(label() == h.expected_level_text("low", "") and lab.ai_level_buttons.keys() == ["low", "mid", "high"], "default: '%s'" % label())
	h.expect([lab.ai_level_buttons.low.text, lab.ai_level_buttons.mid.text, lab.ai_level_buttons.high.text] == ["하", "중", "상"] and lab.ai_level_buttons.low.button_pressed, "buttons 하/중/상, 하 shown")
	var start_writes: Array = b.writes.duplicate()
	var active_before: String = b.active_unit_state.unit_id
	# 중 in the ally turn: pending until the next enemy turn start.
	await h.push_click(self, lab.ai_level_buttons.mid)
	h.expect(b.get_pending_enemy_ai_level() == "mid" and b.get_enemy_ai_level() == "low" and label() == h.expected_level_text("low", "mid"), "중 pending: '%s'" % label())
	h.expect(b.writes == start_writes + ["set_enemy_ai_level"] and b.active_unit_state.unit_id == active_before and lab.selected == active_before, "the click reached only the level command " + str(b.writes.slice(start_writes.size())))
	h.expect(lab.ai_level_texts[-1] == "적 AI 선택 · " + h.expected_level_text("low", "mid") and lab.status.text == lab.ai_level_texts[-1], "choice line")
	# Fold and unfold: presentation only.
	var writes_before: int = b.writes.size()
	await h.push_click(self, lab.option_toggle)
	h.expect(not lab.option_panel.visible and lab.option_toggle.text == "옵션 ▸", "panel folded")
	await h.push_click(self, lab.option_toggle)
	h.expect(lab.option_panel.visible and lab.option_toggle.text == "옵션 ▾" and b.writes.size() == writes_before, "panel unfolded, no engine write")
	# Ally wait from 3D: the enemy turn applies 중.
	lab.wait_button.pressed.emit()
	await wait_idle()
	h.expect(b.enemy_turns.size() >= 1 and b.enemy_turns[0][1] == "mid" and b.enemy_turns[0][2] == [false, false, false] and b.enemy_turns[0][3] == [true, true, true], "applied at the enemy turn start " + str(b.enemy_turns.slice(0, 1)))
	lab._sync_views()
	h.expect(b.get_enemy_ai_level() == "mid" and label() == h.expected_level_text("mid", "") and lab.ai_level_buttons.mid.button_pressed and not lab.ai_level_buttons.low.button_pressed, "중 applied: '%s'" % label())
	# 하 during an enemy action: that action keeps the 중 flags; the next enemy turn applies 하 (cap only).
	var actions_before: int = b.actions_done.size()
	lab.wait_button.pressed.emit()
	for i in range(600):
		if b.current_phase == "enemy_turn" and b.is_demo_animating: break
		await process_frame
	h.expect(b.current_phase == "enemy_turn", "an enemy action is running")
	await h.push_click(self, lab.ai_level_buttons.low)
	h.expect(b.get_pending_enemy_ai_level() == "low" and label() == h.expected_level_text("mid", "low"), "하 chosen during the enemy turn: '%s'" % label())
	await wait_idle()
	h.expect(b.actions_done.size() > actions_before and b.actions_done[actions_before][1] == [true, true, true], "the running enemy action ended on the 중 flags " + str(b.actions_done.slice(actions_before)))
	lab.wait_button.pressed.emit()
	await wait_idle()
	h.expect(b.enemy_turns[-1][3] == [false, false, true] and b.get_enemy_ai_level() == "low", "next enemy turn: 하 (use cap only) " + str(b.enemy_turns[-1]))
	# Refusal shown.
	b.refuse_level = true
	await h.push_click(self, lab.ai_level_buttons.high)
	h.expect(lab.ai_level_texts[-1] == "적 AI 변경 거절 · 엔진이 상 등급을 받지 않았습니다" and b.get_pending_enemy_ai_level() == "", "refusal shown: " + lab.ai_level_texts[-1])
	b.refuse_level = false
	await wait_idle()
	# During auto (input locked): the panel still works.
	lab.auto_button.pressed.emit()
	await process_frame
	h.expect(b.is_full_auto_battle_enabled and lab._input_locked(), "auto on, inputs locked")
	await h.push_click(self, lab.ai_level_buttons.high)
	h.expect(b.get_pending_enemy_ai_level() == "high" and label() == h.expected_level_text("low", "high"), "상 accepted during auto: '%s'" % label())
	await process_frame
	lab.auto_button.pressed.emit()
	for call in b.writes: h.expect(h.FIFTEEN.has(call), "write within the fifteen " + call)
	await h.close_lab(self)
	print("[OPTION_AI_LEVEL] checks=", h.checks, " failures=", h.failures)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
