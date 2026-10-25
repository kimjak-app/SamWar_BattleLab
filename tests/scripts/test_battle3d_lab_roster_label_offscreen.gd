extends SceneTree
# HUD polish 1-A: the lab's debug "부대 상태" text (roster_label) moved
# off-screen by the scenario shell (game window 1920x1080). The node stays
# (the lab tests read its text), its rect no longer meets the screen, and its
# text keeps following the engine: after an ally wait the waiting unit's line
# shows "행동 완료" (engine has_acted), every deployed unit has a line, and the
# label stays off-screen through a new battle.
var h

func _initialize() -> void:
	run.call_deferred()

func check_offscreen(tag: String) -> void:
	var r: Rect2 = h.lab.roster_label.get_global_rect()
	h.expect(is_instance_valid(h.lab.roster_label) and h.lab.roster_label.visible and not Rect2(0, 0, 1920, 1080).intersects(r) and is_equal_approx(r.position.x, 4000.0),
		"%s: roster_label kept (visible flag on) and off-screen %s" % [tag, r])

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_scenario_harness.gd").new()
	await h.open_shell(self)
	root.size = Vector2i(1920, 1080)
	await h.press_scenario(self, "default")
	for i in range(5): await process_frame
	var lab = h.lab
	var b: Node = lab.engine
	check_offscreen("default start")
	var deployed: Array = b.all_battle_unit_states.filter(func(u): return b._is_unit_state_available_for_battle_slot(u))
	var text: String = lab.roster_label.text
	h.expect(text.begins_with("부대 상태") and deployed.all(func(u): return text.contains(u.unit_id)), "text lists every deployed unit (%d)" % deployed.size())
	var active: BattleUnitState = b.active_unit_state
	var line_before: String = Array(text.split("\n")).filter(func(l): return l.contains(" " + active.unit_id + " "))[0]
	h.click(active.grid_cell)
	lab._sync_views()
	h.press_wait()
	for i in range(3): await process_frame
	var line_after: String = Array(lab.roster_label.text.split("\n")).filter(func(l): return l.contains(" " + active.unit_id + " "))[0]
	h.expect(active.has_acted and line_before.contains("미행동") and line_after.contains("행동 완료"), "the text still follows the engine: '%s' -> '%s'" % [line_before, line_after])
	check_offscreen("after the wait")
	h.shell.choose_button.pressed.emit()
	await process_frame
	await h.press_scenario(self, "win_practice")
	for i in range(5): await process_frame
	check_offscreen("a new battle (new lab)")
	await h.close_shell(self)
	print("[LAB_ROSTER_OFFSCREEN] checks=", h.checks, " failures=", h.failures)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
