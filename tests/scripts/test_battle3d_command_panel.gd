extends SceneTree
# HUD block 4-2: the 2D floating command panel and facing arrows on the
# scenario shell. Expected values come from the engine, the lab's own (hidden)
# buttons and the lab camera; button presses are real mouse events. Checks:
#   - the lab's five buttons and facing row are off screen, its info box hidden
#     (kept); 1920x1080 and 1280x800;
#   - the panel: open rule (= the lab's rule), texts (기본공격 / "특기명 · 기세 N"
#     with N = engine N7 / 책략 / 방어 / 대기), disabled and tooltip = the lab's
#     buttons, position = the 2D candidate/clamp/score rule around the unit model's
#     screen point, inside the screen, following camera yaw/zoom, hidden when the
#     unit is off screen; N7 leaves the engine fingerprint unchanged;
#   - each of the five buttons pressed by a real mouse click calls the same engine
#     command the same number of times as the lab's own button (pressed.emit) and
#     leaves the same engine fingerprint; a disabled button changes nothing;
#   - the facing arrows: on the four neighbour cells' screen boxes (x 0.96), grid
#     texts that do not turn with the camera, a real click on each sends
#     confirm_facing with that direction (engine facing = it);
#   - overlaps with the other HUDs are measured; one manual stretch (waits by real
#     clicks) and one win-practice [자동] battle: every frame the panel state = the
#     lab state now or one frame before, no open panel outside the rule.
const DIRS := ["up", "down", "left", "right"]
const OFFSETS := {"up":Vector2i(0, -1), "down":Vector2i(0, 1), "left":Vector2i(-1, 0), "right":Vector2i(1, 0)}
const TEXT := {"up":"↑", "down":"↓", "left":"←", "right":"→"}
var h
var panel

func _initialize() -> void:
	run.call_deferred()

func engine_print(b: Node) -> Dictionary:
	var p: Dictionary = h.start_print(b)
	p["writes"] = b.writes.duplicate()
	p["phase"] = b.current_phase
	return p

func lab_buttons(lab) -> Array:
	return [lab.attack_button, lab.skill_button, lab.strategy_button, lab.defend_button, lab.wait_button]

func mouse(at: Vector2, kind: String) -> void:
	var event: InputEvent
	if kind == "move":
		event = InputEventMouseMotion.new()
	else:
		event = InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = kind == "down"
		event.button_mask = MOUSE_BUTTON_MASK_LEFT if kind == "down" else 0
	event.position = at
	event.global_position = at
	root.push_input(event)

func real_click(control: Control) -> Control:
	# Move, press, release at the control's centre; returns the control under the mouse.
	var at := control.get_global_rect().get_center()
	mouse(at, "move")
	await process_frame
	var hovered: Control = root.gui_get_hovered_control()
	mouse(at, "down")
	await process_frame
	mouse(at, "up")
	await process_frame
	return hovered

func settle(lab, b: Node) -> int:
	# Until the lab takes input again (or a selection phase waits for it).
	var frames := 0
	while frames < 4000:
		await process_frame
		frames += 1
		if b.is_demo_animating or lab._enemy_presentation_busy() or b.current_phase in ["enemy_turn", "resolving"]: continue
		if b.current_phase in ["ally_turn", "attack_select", "unique_skill_target_select", "strategy", "facing_select"] or not lab.battle_result.is_empty(): break
	for i in range(3): await process_frame
	return frames

func expected_open(lab) -> bool:
	var id: String = lab.hud_active_unit_id()
	if not lab.hud_command_panel_open() or not lab.views.has(id): return false
	return root.get_visible_rect().has_point(lab.camera.unproject_position(lab.views[id].position + Vector3(0, h.shell.PANEL_ANCHOR_HEIGHT, 0)))

func panel_open() -> bool:
	return panel.visible and panel.panel.visible

func arrows_open() -> bool:
	return panel.visible and panel.arrows.visible

func panel_matches(lab) -> String:
	# "" when the panel shows the lab's state; else what differs.
	var open := expected_open(lab)
	if panel_open() != open: return "visible %s vs %s" % [panel_open(), open]
	if not open: return ""
	var id: String = lab.hud_active_unit_id()
	var skill: Dictionary = lab.engine.call("_get_unique_skill_for_unit", lab.engine.active_unit_state)
	var cost := int(lab.engine.call("_get_effective_unique_skill_cost", lab.engine.active_unit_state, skill)) if not skill.is_empty() else -1
	var texts := ["기본공격", "고유특기" if skill.is_empty() else "%s · 기세 %d" % [str(skill.get("name", "고유특기")), cost], "책략", "방어", "대기"]
	for i in range(5):
		var shown: Button = panel.button_at(i)
		var source: Button = lab_buttons(lab)[i]
		if shown.text != texts[i] or shown.disabled != source.disabled or shown.tooltip_text != source.tooltip_text:
			return "button %d '%s'/%s/'%s' vs '%s'/%s/'%s'" % [i, shown.text, shown.disabled, shown.tooltip_text, texts[i], source.disabled, source.tooltip_text]
	var anchor: Vector2 = lab.camera.unproject_position(lab.views[id].position + Vector3(0, h.shell.PANEL_ANCHOR_HEIGHT, 0))
	var rects := []
	for world in lab.hud_range_cell_positions(): rects.append(h.shell.cell_screen_rect(world))
	var want: Vector2 = panel.choose_position(anchor, panel.PANEL_SIZE, rects)
	if panel.panel.position != want: return "position %s vs %s" % [panel.panel.position, want]
	return ""

func near_candidate(lab) -> bool:
	var id: String = lab.hud_active_unit_id()
	var anchor: Vector2 = lab.camera.unproject_position(lab.views[id].position + Vector3(0, h.shell.PANEL_ANCHOR_HEIGHT, 0))
	var view_size := root.get_visible_rect().size
	var near: Array = panel.candidate_positions(anchor, panel.PANEL_SIZE, view_size).slice(0, 8).map(func(c): return panel.clamp_position(c, panel.PANEL_SIZE, view_size))
	return near.has(panel.panel.position)

func inside_screen() -> bool:
	return root.get_visible_rect().grow(-panel.VIEWPORT_MARGIN + 0.01).encloses(panel.panel_rect())

func lab_ui_hidden(lab) -> String:
	var screen := root.get_visible_rect()
	for c in lab_buttons(lab) + [lab.facing_ui]:
		if (c as Control).get_global_rect().intersects(screen): return "%s at %s" % [c.name, (c as Control).get_global_rect()]
	if h.shell._lab_info_box().visible: return "info box visible"
	return ""

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_scenario_harness.gd").new()
	await h.open_shell(self)
	root.size = Vector2i(1920, 1080)
	panel = h.shell.command_panel
	h.expect(not panel_open() and not arrows_open(), "start screen: panel and arrows hidden")
	await h.press_scenario(self, "default")
	for i in range(5): await process_frame
	var lab = h.lab
	var b: Node = lab.engine
	h.expect(lab_ui_hidden(lab) == "", "lab's five buttons and facing row off screen, info box hidden (1920x1080): %s" % lab_ui_hidden(lab))
	h.expect(panel.layer == 7 and panel.panel.mouse_filter == Control.MOUSE_FILTER_STOP and panel.arrows.mouse_filter == Control.MOUSE_FILTER_IGNORE, "layer 7; panel takes the mouse, the arrow layer does not")
	h.expect(panel.panel.visible and panel_matches(lab) == "", "start (yi_sunsin, ally_turn): panel open, = lab state %s" % panel_matches(lab))
	h.expect(near_candidate(lab) and inside_screen(), "start: one of the eight near-unit candidates, inside the screen %s" % panel.panel_rect())
	print("[COMMAND_PANEL] start panel ", panel.panel_rect(), " texts ", range(5).map(func(i): return panel.button_at(i).text), " disabled ", range(5).map(func(i): return panel.button_at(i).disabled))
	# N7: = the engine function, read only.
	var before := engine_print(b)
	var costs := {}
	for u in b.all_battle_unit_states.filter(func(x): return x.side == "ally"):
		var skill: Dictionary = b.call("_get_unique_skill_for_unit", u)
		costs[u.unit_id] = [lab.hud_skill_cost(u.unit_id), -1 if skill.is_empty() else int(b.call("_get_effective_unique_skill_cost", u, skill))]
	h.expect(costs.values().all(func(c): return c[0] == c[1]), "N7 = the engine cost for every ally %s" % costs)
	for k in range(20):
		for u in b.all_battle_unit_states.filter(func(x): return x.side == "ally"): lab.hud_skill_cost(u.unit_id)
		h.shell.command_state()
	h.expect(engine_print(b) == before, "N7 x20 for five allies (+ shell command_state): engine fingerprint unchanged")
	# Camera: the panel follows the unit model; inside the screen; hidden when the unit is off screen.
	var follow_bad := []
	for yaw in [0.32, 1.2, -0.9]:
		for zoom in [20.0, 45.0, 70.0]:
			lab.yaw = yaw
			lab.zoom = zoom
			for i in range(2): await process_frame
			if not panel.panel.visible:
				if expected_open(lab): follow_bad.append([yaw, zoom, "hidden"])
				continue
			if panel_matches(lab) != "" or not inside_screen() or not near_candidate(lab): follow_bad.append([yaw, zoom, panel_matches(lab), panel.panel_rect()])
	h.expect(follow_bad.is_empty(), "yaw 0.32/1.2/-0.9 x zoom 20/45/70: panel = rule around the unit model, inside the screen %s" % str(follow_bad))
	lab.yaw = 0.32
	lab.zoom = 20.0
	var unit_pos: Vector3 = lab.views[lab.hud_active_unit_id()].position
	lab.focus = Vector3(lab.board.SIZE.x * lab.board.CELL - unit_pos.x, 0, lab.board.SIZE.y * lab.board.CELL - unit_pos.z) # the far side of the board
	for i in range(2): await process_frame
	h.expect(not expected_open(lab) and not panel.panel.visible, "unit off screen (zoom 20, focus far side): panel hidden")
	lab.focus = Vector3(lab.board.SIZE.x * lab.board.CELL * .5, 0, lab.board.SIZE.y * lab.board.CELL * .5)
	lab.zoom = 60.0
	for i in range(2): await process_frame
	h.expect(panel.panel.visible and panel_matches(lab) == "", "camera back: panel open again")
	# 1280x800.
	root.size = Vector2i(1280, 800)
	for i in range(3): await process_frame
	h.expect(panel.panel.visible and panel_matches(lab) == "" and inside_screen() and lab_ui_hidden(lab) == "", "1280x800: panel = rule and inside the screen %s, lab UI off screen %s" % [panel.panel_rect(), lab_ui_hidden(lab)])
	root.size = Vector2i(1920, 1080)
	for i in range(3): await process_frame
	# Overlaps with the other HUDs (measured, several cameras).
	var huds := {"ally_roster":h.shell.ally_roster.roster_rect(), "current_actor":h.shell.actor_hud.panel_rect(), "enemy_roster":h.shell.enemy_roster.roster_rect(),
		"log":h.shell.log_hud.get_node("ProductionHudRoot/BattleLogHud").get_global_rect(), "top_hud":h.shell.top_hud.frame_rect()}
	for i in range(5): huds["top_button_%d" % i] = h.shell.top_commands.slot_rect(i)
	for cam in [[0.32, 60.0], [0.32, 20.0], [1.2, 45.0], [-0.9, 70.0]]:
		lab.yaw = cam[0]
		lab.zoom = cam[1]
		for i in range(2): await process_frame
		var hits := {}
		for name in huds:
			var o: Rect2 = panel.panel_rect().intersection(huds[name])
			if o.has_area(): hits[name] = o.size
		print("[COMMAND_PANEL] overlap yaw=", cam[0], " zoom=", cam[1], " panel ", panel.panel_rect(), " with ", hits)
	lab.yaw = 0.32
	lab.zoom = 60.0
	for i in range(2): await process_frame
	# Disabled buttons: a real click changes nothing (yi_sunsin: skill not ready).
	for i in range(5):
		if not panel.button_at(i).disabled: continue
		before = engine_print(b)
		var hovered: Control = await real_click(panel.button_at(i))
		h.expect(hovered == panel.button_at(i) and engine_print(b) == before, "disabled %s: real click changes nothing (hovered %s)" % [panel.button_at(i).text, hovered.name if hovered else "?"])
	# Each enabled button: real mouse click on the panel vs the lab's own button, from the same start.
	var commands := {0:["try_basic_attack"], 1:["_on_unique_skill_button_pressed"], 2:["_on_strategy_button_pressed"], 3:["_on_defend_button_pressed"], 4:["_end_ally_turn_by_wait"]}
	var press_results := []
	for i in range(5):
		for actor in ["yi_sunsin", "jeong_dojeon"]:
			var prints := []
			for path in ["panel_mouse", "lab_emit"]:
				await h.press_restart(self)
				lab = h.lab
				b = lab.engine
				for k in range(3): await process_frame
				if actor != b.active_unit_state.unit_id:
					h.click(b.all_battle_unit_states.filter(func(u): return u.unit_id == actor)[0].grid_cell)
					lab._sync_views()
					for k in range(3): await process_frame
				var enabled: bool = not lab_buttons(lab)[i].disabled
				if not enabled and path == "lab_emit": break # a disabled button is not pressed in the 2D either
				var writes_before: Array = b.writes.duplicate()
				var start_print := engine_print(b)
				seed(7)
				if path == "panel_mouse":
					h.expect(panel.button_at(i).disabled == not enabled, "%s %s: panel disabled = lab" % [actor, panel.button_at(i).text])
					await real_click(panel.button_at(i))
				else:
					lab_buttons(lab)[i].pressed.emit()
				await settle(lab, b)
				var new_writes: Array = b.writes.slice(writes_before.size())
				prints.append([engine_print(b), new_writes, b.current_phase, enabled, start_print])
			if not prints[0][3]:
				h.expect(prints[0][1].is_empty() and prints[0][0] == prints[0][4], "%s button %d disabled: a real click calls nothing, engine unchanged" % [actor, i])
				press_results.append([actor, i, false, [], prints[0][2]])
				continue
			h.expect(prints[0][0] == prints[1][0], "%s button %d: engine fingerprint after a real panel click = after the lab's own button (writes %s / %s, phase %s / %s)" % [actor, i, prints[0][1], prints[1][1], prints[0][2], prints[1][2]])
			h.expect(prints[0][1].slice(0, 1) == commands[i] and prints[0][1].count(commands[i][0]) == prints[1][1].count(commands[i][0]), "%s button %d: %s first and called %d time(s) on both paths" % [actor, i, commands[i][0], prints[0][1].count(commands[i][0])])
			press_results.append([actor, i, true, prints[0][1].slice(0, 3), prints[0][2]])
	print("[COMMAND_PANEL] presses (actor, button, enabled, first writes, phase after)=", press_results)
	# Target selection hides the panel (attack): the 2D _should_show rule.
	await h.press_restart(self)
	lab = h.lab
	b = lab.engine
	for k in range(3): await process_frame
	await real_click(panel.button_at(0))
	for k in range(2): await process_frame
	h.expect(b.current_phase == "attack_select" and not panel.panel.visible, "attack target selection: panel hidden (phase %s)" % b.current_phase)
	b.call("_handle_right_click_cancel") # back to ally_turn, as the lab's right click does
	lab._sync_views()
	for k in range(3): await process_frame
	h.expect(panel.panel.visible == expected_open(lab), "after cancel: panel follows the rule again")
	# Facing arrows: one move per direction, then a real click on that arrow.
	var facing_done := []
	for direction in DIRS:
		await h.press_restart(self)
		lab = h.lab
		b = lab.engine
		for k in range(3): await process_frame
		var unit: BattleUnitState = b.active_unit_state
		var targets: Array = lab.queries.query(unit.unit_id, unit.grid_cell).get("reachable", {}).keys()
		var target_cell = null
		for c in targets:
			if c != unit.grid_cell and lab.board.valid(c + OFFSETS[direction]) and b.all_battle_unit_states.all(func(u): return u.grid_cell != c):
				target_cell = c
				break
		if target_cell == null:
			h.expect(false, "%s: a reachable cell with a %s neighbour" % [unit.unit_id, direction])
			continue
		h.click(unit.grid_cell) # select first, like the lab's own move tests
		lab._sync_views()
		await process_frame
		h.click(target_cell)
		var waited := 0
		while b.current_phase != "facing_select" and waited < 2000:
			await process_frame
			waited += 1
		for k in range(3): await process_frame
		h.expect(panel.arrows.visible and not panel.panel.visible and lab.facing_ui.visible, "%s: moved to %s, facing arrows shown, panel hidden" % [direction, target_cell])
		var bad := []
		var arrow_sizes := {}
		for d in DIRS:
			var arrow: Button = panel.arrow_for(d)
			var cell: Vector2i = unit.grid_cell + OFFSETS[d]
			var want: Rect2 = h.shell.cell_screen_rect(lab.board.world(cell))
			if lab.board.valid(cell) != arrow.visible or (arrow.visible and (arrow.text != TEXT[d] or not arrow.get_global_rect().get_center().is_equal_approx(want.get_center()) or not arrow.size.is_equal_approx((want.size * 0.96).max(arrow.get_combined_minimum_size())))): bad.append([d, cell, arrow.get_global_rect(), want])
			arrow_sizes[d] = [arrow.size, want.size * 0.96]
		h.expect(bad.is_empty(), "%s: arrows centred on the neighbour cells' screen boxes, size = box x 0.96 (at least the button's minimum), grid texts %s" % [direction, bad])
		if direction == "up": print("[COMMAND_PANEL] arrow size (shown, cell box x 0.96) at zoom 60: ", arrow_sizes)
		lab.yaw = 1.4
		for k in range(2): await process_frame
		h.expect(DIRS.all(func(d): return not panel.arrow_for(d).visible or panel.arrow_for(d).text == TEXT[d]) and panel.arrow_for(direction).get_global_rect().get_center().is_equal_approx(h.shell.cell_screen_rect(lab.board.world(unit.grid_cell + OFFSETS[direction])).get_center()),
			"%s: camera yaw 1.4 moves the arrows but keeps the grid texts" % direction)
		var writes_before: Array = b.writes.duplicate()
		var hovered: Control = await real_click(panel.arrow_for(direction))
		h.expect(hovered == panel.arrow_for(direction) and b.writes.slice(writes_before.size()) == ["_select_post_move_facing"] and unit.facing == direction and b.current_phase == "ally_turn" and not panel.arrows.visible,
			"%s: a real click on the %s arrow confirms facing %s (engine facing %s, writes %s)" % [direction, TEXT[direction], direction, unit.facing, b.writes.slice(writes_before.size())])
		facing_done.append(direction)
		lab.yaw = 0.32
	print("[COMMAND_PANEL] facing confirmed by real clicks: ", facing_done)
	# A manual stretch: waits by real clicks on the panel, every frame compared.
	await h.press_restart(self)
	lab = h.lab
	b = lab.engine
	var manual := {"frames":0, "open_frames":0, "lag":0, "bad":0, "waits":0}
	var manual_bad := []
	var prev := ""
	for i in range(6000):
		await process_frame
		manual.frames += 1
		var diff := panel_matches(lab)
		if diff != "":
			if prev == "": manual.lag += 1 # a state change shown one frame later
			else:
				manual.bad += 1
				if manual_bad.size() < 5: manual_bad.append([manual.frames, b.current_phase, diff])
		prev = diff
		if panel.panel.visible:
			manual.open_frames += 1
			if not panel.button_at(4).disabled and manual.waits < 8 and diff == "":
				await real_click(panel.button_at(4))
				manual.waits += 1
				prev = ""
		if manual.waits >= 8 and panel.panel.visible: break
	h.expect(manual.waits >= 8 and manual.bad == 0, "manual stretch: 8 waits by real clicks; every frame the panel = lab state now or one frame later %s %s" % [manual, manual_bad])
	# Win practice with [자동]: the panel never opens; every frame = the rule.
	h.shell.choose_button.pressed.emit()
	await process_frame
	h.expect(not panel_open() and not arrows_open(), "[시나리오 선택]: panel hidden")
	await h.press_scenario(self, "win_practice")
	lab = h.lab
	b = lab.engine
	for i in range(2): lab.speed_button.pressed.emit()
	lab._sync_views()
	seed(1)
	h.press_auto()
	var auto := {"frames":0, "open_frames":0, "bad":0, "lag":0}
	var auto_open := []
	prev = ""
	for i in range(80000):
		await process_frame
		if not h.shell.top_hud.visible:
			if h.shell.result_panel.visible: break
			continue
		auto.frames += 1
		if panel_open():
			auto.open_frames += 1
			if auto_open.size() < 5: auto_open.append([auto.frames, b.current_phase, b.is_full_auto_battle_enabled, lab.hud_active_unit_id()])
		var diff := panel_matches(lab)
		if diff != "":
			if prev == "": auto.lag += 1
			else: auto.bad += 1
		prev = diff
		if h.shell.result_panel.visible: break
	h.expect(h.shell.result_panel.visible and auto.bad == 0, "win practice [자동]: every frame the panel = the rule now or one frame later %s; open frames (frame, phase, auto, actor) %s" % [auto, auto_open])
	h.expect(not panel_open() and not arrows_open(), "after the result: panel hidden")
	print("[COMMAND_PANEL] manual=", manual, " auto=", auto, " auto open frames=", auto_open)
	await h.close_shell(self)
	print("[COMMAND_PANEL] checks=", h.checks, " failures=", h.failures)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	panel = null
	await process_frame
	quit(code)
