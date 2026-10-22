extends SceneTree
# M5-b: the start screen offers the two scenarios; each starts the lab with the
# engine start state expected for it. Default = the untouched battle (equals an
# engine started with no setup). Win practice = the five enemy units' six troop
# fields at 1/4 (floor, at least 1), every allied value and every other field
# unchanged. The setup meta never outlives the start. [시나리오 선택] closes the
# battle and the other scenario starts from the start screen.
var h

func _initialize() -> void:
	run.call_deferred()

func without_troops(units: Array) -> Array:
	var copy: Array = units.duplicate(true)
	for values in copy:
		if h.ENEMY_IDS.has(values.get("unit_id", "")):
			for f in h.TROOP_FIELDS: values.erase(f)
	return copy

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_scenario_harness.gd").new()
	var plain: Dictionary = await h.bare_start(self, {})
	await h.open_shell(self)
	h.expect(h.shell.start_panel.visible and h.shell.lab == null and not h.shell.result_panel.visible, "start screen first, no battle yet")
	h.expect(h.shell.scenario_buttons.keys() == ["default", "win_practice"] and h.shell.scenario_buttons.default.text == "기본 배치" and h.shell.scenario_buttons.win_practice.text == "승리 연습 (적 병력 1/4)", "two scenario buttons")
	# Default.
	await h.press_scenario(self, "default")
	var s: Dictionary = h.start_print(h.lab.engine)
	h.expect(not Engine.has_meta(h.SETUP_KEY) and not h.shell.start_panel.visible, "default started, no meta left")
	h.expect(h.fingerprint.diff(plain.units, s.units).is_empty() and h.fingerprint.diff(plain.controller, s.controller).is_empty() and s.logs == plain.logs and s.momentum == plain.momentum, "default start == engine with no setup")
	h.expect(h.lab.engine.writes == plain.writes, "starting a scenario adds no engine write (same as an engine started alone: %s)" % str(h.lab.engine.writes))
	# Switch to win practice through [시나리오 선택].
	h.shell.choose_button.pressed.emit()
	await process_frame
	h.expect(h.shell.lab == null and h.shell.start_panel.visible and not h.shell.result_panel.visible, "[시나리오 선택]: battle closed, start screen back")
	await h.press_scenario(self, "win_practice")
	var b: Node = h.lab.engine
	s = h.start_print(b)
	h.expect(not Engine.has_meta(h.SETUP_KEY), "win practice started, meta consumed")
	for u in b.all_battle_unit_states:
		var want: Dictionary = plain.troops[u.unit_id].duplicate()
		if h.ENEMY_IDS.has(u.unit_id):
			for f in h.TROOP_FIELDS: want[f] = h.expected_scaled(plain.troops[u.unit_id][f], 0.25)
		h.expect(h.troop_fields(u) == want, "win practice %s %s" % [u.unit_id, str(h.troop_fields(u))])
	h.expect(without_troops(s.units) == without_troops(plain.units), "win practice: allies and every other field unchanged")
	h.expect(h.fingerprint.diff(plain.controller, s.controller).is_empty() and s.logs == plain.logs and s.momentum == plain.momentum, "win practice: controller, logs, momentum unchanged")
	# Each enemy unit label in 3D shows the engine's (scaled) troops.
	h.lab._sync_views()
	for u in b.all_battle_unit_states:
		if u.side != "enemy" or not b._is_unit_state_available_for_battle_slot(u): continue
		var texts: Array = h.lab.views[u.unit_id].get_children().filter(func(c): return c is Label3D).map(func(c): return c.text)
		h.expect(texts.has("%s | %s%s%d" % [u.unit_id, u.unit_type, char(10), u.current_troops]) and u.current_troops == h.expected_scaled(plain.troops[u.unit_id].current_troops, 0.25), "3D label shows the scaled troops " + str(texts))
	# And back to default: the scaled state does not carry over.
	h.shell.choose_button.pressed.emit()
	await process_frame
	await h.press_scenario(self, "default")
	s = h.start_print(h.lab.engine)
	h.expect(h.fingerprint.diff(plain.units, s.units).is_empty(), "default again: untouched start")
	h.expect(h.shell.lab_count == 3, "three labs created")
	await h.close_shell(self)
	print("[SCENARIO_START] checks=", h.checks, " failures=", h.failures)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
