extends SceneTree
# HUD block 4-6 test 1: the battlefield debug text on the scenario shell, by real F3 key presses.
#   - default: the unit info labels (id | type | troops), the per-unit state lines (their parent node) and the control
#     help are hidden; their nodes and texts are still there and still updated;
#   - F3: all of them shown; F3 again: hidden again;
#   - the top turn / momentum lines stay shown (HIDE_TOP_LINES false, see the report);
#   - the TurnHud title shows the acting side: "아군 턴" on the ally turn, "적군 턴" once the enemy turn plays.
var h

func _initialize() -> void:
	run.call_deferred()

func key(code: Key) -> void:
	var e := InputEventKey.new()
	e.keycode = code
	e.physical_keycode = code
	e.pressed = true
	root.push_input(e)
	await process_frame
	var up := e.duplicate()
	up.pressed = false
	root.push_input(up)
	for i in range(3): await process_frame

func info_labels(lab) -> Array:
	var out := []
	for id in lab.views:
		for child in lab.views[id].get_children():
			if child is Label3D and child.has_meta("unit_info"): out.append(child)
	return out

func state(lab) -> Dictionary:
	var labels := info_labels(lab)
	# Each label's own flag (undeployed units' labels sit under a hidden unit) and, for shown units, on screen.
	var shown := labels.filter(func(l): return l.get_parent().is_visible_in_tree())
	return {"info":labels.map(func(l): return l.visible) + shown.map(func(l): return l.is_visible_in_tree()), "badges":lab.action_badges.is_visible_in_tree(), "help":lab.help_label.is_visible_in_tree()}

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_scenario_harness.gd").new()
	await h.open_shell(self)
	root.size = Vector2i(1920, 1080)
	await h.press_scenario(self, "default")
	var lab = h.lab
	var b: Node = lab.engine
	for i in range(30): await process_frame
	h.expect(not lab.debug_text_visible, "the debug text starts off")
	var labels := info_labels(lab)
	h.expect(labels.size() == lab.views.size() and labels.all(func(l): return not l.text.is_empty()), "one info label per unit, texts kept (%d labels)" % labels.size())
	var s0 := state(lab)
	h.expect(s0.info.all(func(v): return not v) and not s0.badges and not s0.help, "default: info labels, state lines and help hidden %s" % str(s0))
	var shown_badges: int = lab.action_badges.get_children().filter(func(x): return x.visible and not x.text.is_empty()).size()
	h.expect(shown_badges > 0, "the state lines still update (%d with text and their own visible flag on)" % shown_badges)
	h.expect(lab.turn_label.is_visible_in_tree() and lab.momentum_label.is_visible_in_tree(), "the top turn / momentum lines stay shown (HIDE_TOP_LINES %s)" % lab.HIDE_TOP_LINES)
	await key(KEY_F3)
	var s1 := state(lab)
	h.expect(lab.debug_text_visible and s1.info.all(func(v): return v) and s1.badges and s1.help, "F3: everything shown %s" % str(s1))
	await key(KEY_F3)
	var s2 := state(lab)
	h.expect(not lab.debug_text_visible and s2.info.all(func(v): return not v) and not s2.badges and not s2.help, "F3 again: hidden %s" % str(s2))
	# The acting side in the TurnHud title.
	var title: Label = h.shell.top_hud.get_node("ProductionHudRoot/TopHudRoot/TurnHud/Frame")
	h.expect(title.text == "아군 턴" and b.current_phase != "enemy_turn", "ally turn: TurnHud says 아군 턴 ('%s', phase %s)" % [title.text, b.current_phase])
	var saw_enemy := false
	for turn in range(6):
		if b.current_phase == "ally_turn" and not b.is_demo_animating: lab.request_wait()
		for i in range(60):
			await process_frame
			if b.current_phase == "enemy_turn" or lab._enemy_presentation_busy():
				saw_enemy = saw_enemy or title.text == "적군 턴"
		if saw_enemy: break
	h.expect(saw_enemy, "enemy turn: TurnHud says 적군 턴")
	lab.debug_text_visible = false
	await h.close_shell(self)
	print("[BLOCK46_DEBUG_TEXT] checks=", h.checks, " failures=", h.failures)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
