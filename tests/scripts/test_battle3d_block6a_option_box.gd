extends SceneTree
# HUD block 6a test 1: the option box on the scenario shell at 1920 x 1080. Opened with the real [옵션] button, with an
# ally selected (the ally turn) and with none (the enemy turn, after the three allies wait):
#   - the box's rect overlaps none of the HUD rects read here from the HUD nodes (both rosters, the current-actor panel,
#     the top HUD frame, the five top command buttons) and lies inside the window;
#   - the box is drawn above every HUD layer (its CanvasLayer above the rosters', the top HUD's, the commands' and the
#     shell's own);
#   - control: the old place (under the option button: its x, its bottom + 6) with the same box size covers the enemy
#     roster.
var h

func _initialize() -> void:
	run.call_deferred()

func hud(shell) -> Array:
	var rects := [shell.ally_roster.roster_rect(), shell.enemy_roster.roster_rect(), shell.actor_hud.panel_rect(), shell.top_hud.frame_rect()]
	for i in range(5): rects.append(shell.top_commands.slot_rect(i))
	return rects

func click(control: Control) -> void:
	var at := control.get_global_rect().get_center()
	for pressed in [true, false]:
		var e := InputEventMouseButton.new()
		e.button_index = MOUSE_BUTTON_LEFT
		e.pressed = pressed
		e.position = at
		e.global_position = at
		root.push_input(e)
		for i in range(3): await process_frame

func check_open(shell, lab, label: String) -> void:
	var box: Control = lab.option_toggle.get_parent()
	await click(shell.top_commands.option_button)
	for i in range(3): await process_frame
	var rect := box.get_global_rect()
	var hits: Array = hud(shell).filter(func(r): return rect.intersects(r))
	print("[BLOCK6A_OPTION] ", label, " box ", rect)
	h.expect(box.is_visible_in_tree() and lab.option_panel.is_visible_in_tree() and Rect2(Vector2.ZERO, Vector2(root.size)).encloses(rect) and hits.is_empty(),
		"%s: the option box %s inside the window, clear of the HUD (covers %s)" % [label, rect, str(hits)])
	var layers := [shell.ally_roster.layer, shell.enemy_roster.layer, shell.actor_hud.layer, shell.top_hud.layer, shell.top_commands.layer, shell.layer.layer]
	h.expect(box.get_parent().layer > layers.max(), "%s: the option box on layer %d, above the HUD layers %s" % [label, box.get_parent().layer, str(layers)])
	var slot: Rect2 = shell.top_commands.slot_rect(0)
	var old := Rect2(Vector2(slot.position.x, slot.end.y + 6.0), rect.size)
	h.expect(old.intersects(shell.enemy_roster.roster_rect()), "%s control: the old place %s covers the enemy roster" % [label, old])
	await click(shell.top_commands.option_button)
	h.expect(not box.is_visible_in_tree(), "%s: the option button closes the box" % label)

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_scenario_harness.gd").new()
	await h.open_shell(self)
	root.size = Vector2i(1920, 1080)
	await h.press_scenario(self, "default")
	var lab = h.lab
	var b: Node = lab.engine
	for i in range(120): await process_frame
	h.expect(lab.hud_ally_actor_id() != "", "an ally is selected (%s)" % lab.hud_ally_actor_id())
	await check_open(h.shell, lab, "ally selected")
	# No ally selected: every ally waits, then the enemy turn.
	for i in range(3000):
		if lab.hud_turn_side() == "적군 턴" and lab.hud_ally_actor_id() == "": break
		if i % 120 == 0 and b.active_unit_state != null and b.active_unit_state.side == "ally": lab.request_wait()
		await process_frame
	h.expect(lab.hud_ally_actor_id() == "", "no ally selected (%s, %s)" % [lab.hud_turn_side(), lab.hud_ally_actor_id()])
	await check_open(h.shell, lab, "no ally selected")
	await h.close_shell(self)
	print("[BLOCK6A_OPTION] checks=", h.checks, " failures=", h.failures)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
