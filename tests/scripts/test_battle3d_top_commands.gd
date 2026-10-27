extends SceneTree
# HUD block 1: the top command row on the scenario shell (game window
# 1920x1080), pressed with real mouse clicks (root.push_input at each button's
# centre). Each press is checked by the state it changes, not by its text:
#   option -> the lab's option box opens under the row (closed by default), a
#     click on [중] sets the engine's pending AI level, a second press closes it;
#   speed -> the lab speed step and Engine.time_scale (1 -> 2 -> 4 -> 1);
#   auto -> the engine full auto on (one _toggle_full_auto_battle) and off;
#   end turn -> the engine's _end_ally_turn_by_wait for the active ally (the
#     same engine function as the 2D [턴 종료]); with no active ally the lab and
#     the engine both do nothing;
#   retreat -> disabled, no handler: a click changes nothing.
# Also: the row's rects; all five one plain text-button style (polish 1-B, the 2D
# round icons not used), each text fitting 68x68, retreat visibly dimmed, auto
# lit (brighter gold border and text) while on; the lab's auto/speed buttons moved
# off-screen (still pressable by the lab tests), the row hidden on the start screen.
var h
var cmd

func _initialize() -> void:
	run.call_deferred()

func click(control: Control) -> void:
	var pos := control.get_global_rect().get_center()
	var motion := InputEventMouseMotion.new()
	motion.position = pos
	root.push_input(motion)
	for pressed in [true, false]:
		var ev := InputEventMouseButton.new()
		ev.button_index = MOUSE_BUTTON_LEFT
		ev.pressed = pressed
		ev.position = pos
		root.push_input(ev)
	await process_frame
	await process_frame

func handlers(button: BaseButton) -> Array:
	# pressed connections other than the game-wide click sound (game_audio autoload hooks every button).
	return button.pressed.get_connections().filter(func(c): return not str(c.callable.get_object().get_script().resource_path).ends_with("game_audio.gd"))

func engine_state(b: Node) -> Dictionary:
	return {"phase":b.current_phase, "round":b.battle_round, "auto":b.is_full_auto_battle_enabled, "writes":b.writes.duplicate(),
		"events":[b.ally_move_event_log.export().size(), b.battle_action_event_log.export().size(), b.enemy_action_event_log.export().size(), b.tactic_event_log.export().size()],
		"acted":b.all_battle_unit_states.map(func(u): return u.has_acted)}

func settle_ally_turn(label: String) -> void:
	var stable := 0
	for i in range(6000):
		await process_frame
		var b: Node = h.lab.engine
		stable = stable + 1 if b.current_phase == "ally_turn" and not b.is_demo_animating and not h.lab._enemy_presentation_busy() else 0
		if stable >= 30: return
		if b.call("_get_battle_result_state") != "": break
	h.expect(false, label + " settled")

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_scenario_harness.gd").new()
	await h.open_shell(self)
	root.size = Vector2i(1920, 1080) # the game window; the lab lays out its UI from it
	cmd = h.shell.top_commands
	h.expect(not cmd.visible, "start screen: command row hidden")
	await h.press_scenario(self, "default")
	for i in range(5): await process_frame
	var lab = h.lab
	var b: Node = lab.engine
	# Layout: 68x68, gap 18, y 27, option 1435 / speed 1521 / auto 1607 / end turn 1693 / retreat 1779.
	var buttons := [cmd.option_button, cmd.speed_button, cmd.auto_button, cmd.end_turn_button, cmd.retreat_button]
	var xs := [1435, 1521, 1607, 1693, 1779]
	for i in range(5):
		h.expect(cmd.visible and buttons[i].is_visible_in_tree() and buttons[i].get_global_rect() == Rect2(xs[i], 27, 68, 68), "button %d at %d,27 68x68: %s" % [i, xs[i], buttons[i].get_global_rect()])
	# Polish 1-B (Kim, 10-25): all five are the same plain text-button style; the 2D round icons are not used.
	var texts := buttons.map(func(x): return x.text)
	h.expect(texts == ["옵션", "속도\n×1", "자동\n전투", "턴 종료", "후퇴"] and buttons.all(func(x): return x is Button and not x is TextureButton and x.icon == null), "five text buttons, no 2D picture %s" % str(texts))
	var border0: Color = (buttons[0].get_theme_stylebox("normal") as StyleBoxFlat).border_color
	var auto_text_colors := func() -> Array: return ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"].map(func(n): return cmd.auto_button.get_theme_color(n))
	var text0: Array = auto_text_colors.call() # the auto button's text colors while off
	h.expect(buttons.all(func(x): return x.get_theme_stylebox("normal") is StyleBoxFlat and (x.get_theme_stylebox("normal") as StyleBoxFlat).border_color == border0), "one style for all five (same frame and border)")
	for x in buttons:
		var font: Font = x.get_theme_font("font")
		var style: StyleBox = x.get_theme_stylebox("normal")
		var need: Vector2 = font.get_multiline_string_size(x.text, HORIZONTAL_ALIGNMENT_CENTER, -1, x.get_theme_font_size("font_size")) + Vector2(style.get_margin(SIDE_LEFT) + style.get_margin(SIDE_RIGHT), style.get_margin(SIDE_TOP) + style.get_margin(SIDE_BOTTOM))
		h.expect(need.x <= 68.0 and need.y <= 68.0 and x.size == Vector2(68, 68), "'%s' fits in 68x68 (needs %s)" % [x.text.replace("\n", "/"), need])
		print("[TOP_COMMANDS] text size ", x.text.replace("\n", "/"), " needs ", need)
	var dis: StyleBoxFlat = cmd.retreat_button.get_theme_stylebox("disabled")
	h.expect(cmd.retreat_button.disabled and dis.border_color.a < border0.a and dis.border_color.v < border0.v and cmd.retreat_button.get_theme_color("font_disabled_color").v < cmd.retreat_button.get_theme_color("font_color").v,
		"retreat disabled is dimmed (border %s vs %s, text darker)" % [dis.border_color, border0])
	var screen := Rect2(0, 0, 1920, 1080)
	h.expect(not screen.intersects(lab.auto_button.get_global_rect()) and not screen.intersects(lab.speed_button.get_global_rect()), "lab auto/speed moved off-screen %s %s" % [lab.auto_button.get_global_rect(), lab.speed_button.get_global_rect()])
	var box: Control = lab.option_toggle.get_parent()
	h.expect(not box.is_visible_in_tree(), "option box closed by default")
	for i in range(5):
		h.expect(not cmd.slot_rect(i).intersects(h.shell.top_hud.frame_rect()), "button %d clear of the top HUD frame" % i)
	# Option: open, choose 중 with a click, close.
	await click(cmd.option_button)
	h.expect(box.is_visible_in_tree() and lab.option_panel.is_visible_in_tree() and box.get_global_rect().position.y >= 100.0 and box.get_global_rect().position.x <= 1435.0 and box.get_global_rect().end.x <= h.shell.enemy_roster.roster_rect().position.x, "option opens the AI level box under the row, left of the enemy roster (block 6a: was x 1435) %s" % box.get_global_rect())
	await click(lab.ai_level_buttons.mid)
	h.expect(b.call("get_pending_enemy_ai_level") == "mid" or b.call("get_enemy_ai_level") == "mid", "click 중: engine level pending 'mid' (%s / %s)" % [b.call("get_enemy_ai_level"), b.call("get_pending_enemy_ai_level")])
	await click(cmd.option_button)
	h.expect(not box.is_visible_in_tree(), "option closes the box")
	# Speed: 1 -> 2 -> 4 -> 1, the lab's own step and Engine.time_scale.
	var steps := []
	for i in range(3):
		await click(cmd.speed_button)
		steps.append([lab.speed_index, Engine.time_scale, cmd.speed_button.text.replace("\n", " ")])
	h.expect(steps == [[1, 2.0, "속도 ×2"], [2, 4.0, "속도 ×4"], [0, 1.0, "속도 ×1"]], "speed steps %s" % str(steps))
	# Retreat: disabled, no handler; a click changes nothing.
	h.expect(cmd.retreat_button.disabled and cmd.retreat_button.tooltip_text == "월드맵 연결 후 사용" and handlers(cmd.retreat_button).is_empty(), "retreat: disabled, tooltip, no handler (%s, '%s', %s)" % [cmd.retreat_button.disabled, cmd.retreat_button.tooltip_text, handlers(cmd.retreat_button)])
	var before := engine_state(b)
	await click(cmd.retreat_button)
	h.expect(engine_state(b) == before and h.shell.result_panel.visible == false and b.call("_get_battle_result_state") == "", "retreat click: engine unchanged, no result")
	# End turn: the active ally's wait (the 2D [턴 종료] calls the same _end_ally_turn_by_wait).
	var active: BattleUnitState = b.active_unit_state
	h.expect(active != null and active.side == "ally" and not cmd.end_turn_button.disabled, "end turn enabled with an active ally (%s)" % (active.unit_id if active != null else "none"))
	var writes_before: Array = b.writes.duplicate()
	await click(cmd.end_turn_button)
	h.expect(b.writes.slice(writes_before.size()) == ["_end_ally_turn_by_wait"] and active.has_acted, "end turn click: one _end_ally_turn_by_wait, %s acted" % active.unit_id)
	await settle_ally_turn("after end turn")
	# No active ally: the lab refuses and sends nothing; the engine itself does nothing either.
	var keep: BattleUnitState = b.active_unit_state
	b.active_unit_state = null # fixture write
	await process_frame
	before = engine_state(b)
	h.expect(cmd.end_turn_button.disabled and cmd.end_turn_button.tooltip_text.contains("먼저 아군을 선택"), "no active ally: end turn disabled, '%s'" % cmd.end_turn_button.tooltip_text)
	cmd.on_end_turn.call() # as if the disabled button were pressed
	h.expect(engine_state(b) == before, "no active ally: lab sends nothing")
	b.call("_end_ally_turn_by_wait") # the engine function alone, same state (the spy records this call itself)
	var after := engine_state(b)
	h.expect(after.writes.slice(before.writes.size()) == ["_end_ally_turn_by_wait"], "the direct call is the only new write")
	after.erase("writes")
	var before_rest := before.duplicate()
	before_rest.erase("writes")
	h.expect(after == before_rest, "no active ally: the engine's _end_ally_turn_by_wait changes nothing either %s / %s" % [after, before_rest])
	b.active_unit_state = keep
	await process_frame
	# Auto: on (one toggle), tooltip like 2D, then off.
	writes_before = b.writes.duplicate()
	await click(cmd.auto_button)
	h.expect(b.is_full_auto_battle_enabled and b.writes.slice(writes_before.size()) == ["_toggle_full_auto_battle"] and cmd.auto_button.tooltip_text == "자동중지" and not cmd.auto_button.disabled and (cmd.auto_button.get_theme_stylebox("normal") as StyleBoxFlat).border_color != border0 and cmd.auto_button.text == "자동\n전투", "auto click: engine full auto on, tooltip 자동중지")
	h.expect(auto_text_colors.call().all(func(c): return not text0.has(c)), "auto on: every text color (normal/hover/pressed/focus) differs from the off colors %s / %s" % [auto_text_colors.call(), text0])
	for i in range(10): await process_frame
	await click(cmd.auto_button)
	h.expect(not b.is_full_auto_battle_enabled and b.writes.count("_toggle_full_auto_battle") == 2 and cmd.auto_button.tooltip_text == "자동전투" and (cmd.auto_button.get_theme_stylebox("normal") as StyleBoxFlat).border_color == border0 and cmd.auto_button.text == "자동\n전투", "second auto click: engine full auto off, tooltip 자동전투")
	h.expect(auto_text_colors.call() == text0, "auto off: the text colors are back to the off colors %s" % [auto_text_colors.call()])
	# Lab's own (off-screen) buttons still work as before.
	lab.speed_button.pressed.emit()
	await process_frame
	h.expect(lab.speed_index == 1 and cmd.speed_button.text.replace("\n", " ") == "속도 ×2", "the lab's speed button (off-screen) still steps the same state")
	lab.speed_button.pressed.emit()
	lab.speed_button.pressed.emit()
	h.shell.choose_button.pressed.emit()
	await process_frame
	h.expect(not cmd.visible, "[시나리오 선택]: command row hidden")
	await h.close_shell(self)
	print("[TOP_COMMANDS] checks=", h.checks, " failures=", h.failures)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	cmd = null
	await process_frame
	quit(code)
