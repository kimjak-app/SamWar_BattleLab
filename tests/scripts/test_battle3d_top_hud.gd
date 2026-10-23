extends SceneTree
# HUD spike: the 2D top HUD copy (momentum diamonds, "round / 30") on the
# scenario shell. Expected values are built here from the engine: filled slots =
# the engine's momentum, label = "%d / 30" % battle_round. Default battle: start
# 3/3 1/30, three waits to round 2 (round-end gain), the lab's round/momentum
# text labels hidden while the HUD is shown (false = both shown, overlap), the
# HUD applies only on a value change and adds no engine write. Win practice
# played with [자동] to the result: every frame the HUD shows the lab's values,
# and once the battle has a result the HUD is hidden like the 2D one.
var h
var hud

func _initialize() -> void:
	run.call_deferred()

func expect_engine_values(label: String) -> void:
	var b: Node = h.lab.engine
	for side in ["Ally", "Enemy"]:
		var value: int = b.battle_momentum.get_value(side.to_lower())
		var wrong := []
		for index in range(10):
			var slot: Panel = hud.slot_row(side).get_child(index).get_node("Slot%02d" % (index + 1))
			var kind := "Filled" if index < value else "Empty"
			var style = slot.get_meta("_diamond_%s_style" % kind.to_lower())
			if slot.theme_type_variation != StringName("MomentumSlot%s%s" % [side, kind]) or slot.get_theme_stylebox(&"panel") != style: wrong.append(index)
		h.expect(wrong.is_empty() and hud.slot_row(side).get_child_count() == 10, "%s: %s %d of 10 filled (wrong slots %s)" % [label, side, value, str(wrong)])
	var want := "%d / 30" % b.battle_round
	h.expect(hud.turn_label().text == want, "%s: turn '%s' == '%s'" % [label, hud.turn_label().text, want])

func settle(label: String) -> void:
	var stable := 0
	for i in range(6000):
		await process_frame
		var b: Node = h.lab.engine
		stable = stable + 1 if b.current_phase == "ally_turn" and not b.is_demo_animating and not h.lab._enemy_presentation_busy() else 0
		if stable >= 30: return
		if b.call("_get_battle_result_state") != "": break
	h.expect(false, label + " settled (back to an ally turn, battle not over)")

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_scenario_harness.gd").new()
	var plain: Dictionary = await h.bare_start(self, {})
	await h.open_shell(self)
	hud = h.shell.top_hud
	h.expect(hud.layer == 5 and h.shell.layer.layer == 10 and not hud.visible, "start screen: HUD (layer 5, under the shell's 10) hidden")
	await h.press_scenario(self, "default")
	for i in range(5): await process_frame
	var b: Node = h.lab.engine
	h.expect(hud.visible and b.battle_momentum.get_value("ally") == 3 and b.battle_momentum.get_value("enemy") == 3 and b.battle_round == 1, "default started: HUD shown, engine 3/3 round 1")
	expect_engine_values("start")
	h.expect(b.writes == plain.writes, "before any input: writes == an engine started alone %s" % str(b.writes))
	h.expect(not h.lab.turn_label.visible and not h.lab.momentum_label.visible, "lab round/momentum text labels hidden while the HUD is shown")
	# Only a value change re-applies; idle frames add no engine write.
	var applies: int = hud.apply_count
	var writes: Array = b.writes.duplicate()
	for i in range(30): await process_frame
	h.expect(hud.apply_count == applies and b.writes == writes, "30 idle frames: no re-apply (%d), no engine write" % hud.apply_count)
	# Overlap option: keep the lab's labels; their rects lie inside the HUD's top area.
	h.shell.hide_lab_top_labels = false
	await process_frame
	var top: Rect2 = hud.get_node("ProductionHudRoot/TopHudRoot").get_global_rect()
	h.expect(h.lab.turn_label.visible and h.lab.momentum_label.visible and top.intersects(h.lab.turn_label.get_global_rect()) and top.intersects(h.lab.momentum_label.get_global_rect()), "hide off: lab labels shown and overlapping the HUD %s / %s / %s" % [top, h.lab.turn_label.get_global_rect(), h.lab.momentum_label.get_global_rect()])
	h.shell.hide_lab_top_labels = true
	await process_frame
	h.expect(not h.lab.turn_label.visible, "hide on again")
	# Three waits: the round ends, both sides gain, the HUD follows after the enemy replay.
	for step in range(3):
		var active = b.active_unit_state
		if active == null or active.side != "ally":
			h.expect(false, "wait %d: the engine offers an ally" % step)
			await finish()
			return
		h.click(active.grid_cell)
		h.lab._sync_views()
		h.press_wait()
		await settle("wait %d" % step)
	h.expect(b.battle_round == 2 and h.lab.current_round == 2, "round 2 reached")
	h.expect(b.battle_momentum.get_value("ally") > 3, "ally momentum rose at the round end: %d" % b.battle_momentum.get_value("ally"))
	expect_engine_values("round 2")
	var three_waits: Array = b.writes.duplicate()
	h.expect(three_waits.count("_end_ally_turn_by_wait") == 3, "writes are the lab's own commands only " + str(three_waits))
	# Win practice with [자동] to the result.
	h.shell.choose_button.pressed.emit()
	await process_frame
	h.expect(not hud.visible, "[시나리오 선택]: HUD hidden")
	await h.press_scenario(self, "win_practice")
	b = h.lab.engine
	for i in range(2): h.lab.speed_button.pressed.emit()
	h.lab._sync_views()
	seed(1)
	h.press_auto()
	var mismatched := 0
	var ally_rises := 0
	var last_ally := 3
	for i in range(80000):
		await process_frame
		if hud.visible:
			var want := {"Ally":h.lab.momentum_display.ally, "Enemy":h.lab.momentum_display.enemy, "round":h.lab.current_round}
			if hud.shown != want or hud.filled_count("Ally") != mini(want.Ally, 10) or hud.filled_count("Enemy") != mini(want.Enemy, 10): mismatched += 1
			if want.Ally > last_ally: ally_rises += 1
			last_ally = want.Ally
		if h.shell.result_panel.visible: break
	h.expect(h.shell.result_panel.visible and b.call("_get_battle_result_state") == "victory", "win practice ends in victory")
	h.expect(mismatched == 0 and ally_rises > 0, "every shown frame matched the lab's values (mismatches %d, ally rises %d)" % [mismatched, ally_rises])
	h.expect(not hud.visible and h.lab.turn_label.visible, "battle result: HUD hidden (like 2D), lab labels back")
	print("[TOP_HUD] applies=", hud.apply_count, " writes_default=", three_waits.size(), " ally_rises=", ally_rises)
	await finish()

func finish() -> void:
	await h.close_shell(self)
	print("[TOP_HUD] checks=", h.checks, " failures=", h.failures)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	hud = null
	await process_frame
	quit(code)
