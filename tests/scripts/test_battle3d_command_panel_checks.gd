extends SceneTree
# HUD block 4-3: the checks added to the block 4-2 command panel test (the instruction's section 3), in their own file
# so each stays inside the CI's 120 s per test (the block 4-2 test alone takes about 72 s). Expected values are
# computed here, independently of the panel and the shell; the 2D placement constants are read from the 2D script:
#   1. N7 under skill_cost_up: the skill line shows the engine's effective cost, not the base cost;
#   2. the open rule from engine and lab state every frame (enemy replay, engine animation, cut-in hold, result);
#   3. the move-range cells: the panel overlaps none of them (unless every near candidate does);
#   4. the placement: the 2D candidates, clamp, distance weight and far penalty for several anchors;
#   5. [책략] enabled: a real panel click = the lab's [책략] (_on_strategy_button_pressed, same engine fingerprint).
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

func panel_open() -> bool:
	return panel.visible and panel.panel.visible

# --- Block 4-3 additions (expected values computed here, independently of the panel and the shell) ------------------

func c_constants() -> Dictionary:
	# The 2D placement constants, read from the 2D script's text (C:63-68).
	var src := FileAccess.get_file_as_string("res://scripts/battle_web_import_test.gd")
	var out := {}
	for name in ["VIEWPORT_MARGIN", "ANCHOR_GAP", "GRID_AVOID_PADDING", "DISTANCE_SCORE_WEIGHT", "FAR_FALLBACK_SCORE", "NEAR_CANDIDATE_COUNT"]:
		var m := RegEx.create_from_string("const FLOATING_COMMAND_PANEL_%s := ([0-9.]+)" % name).search(src)
		if m != null: out[name] = float(m.get_string(1))
	return out

func expected_candidates(k: Dictionary, anchor: Vector2, size: Vector2, view: Vector2) -> Array:
	# C:6336-6351 (eight near the anchor, four screen corners), each clamped as C:6354-6358.
	var m: float = k.VIEWPORT_MARGIN
	var g: float = k.ANCHOR_GAP
	var raw := [anchor + Vector2(g, -size.y * 0.5), anchor + Vector2(-size.x - g, -size.y * 0.5), anchor + Vector2(-size.x * 0.5, -size.y - g), anchor + Vector2(-size.x * 0.5, g),
		anchor + Vector2(g, g), anchor + Vector2(-size.x - g, g), anchor + Vector2(g, -size.y - g), anchor + Vector2(-size.x - g, -size.y - g),
		Vector2(view.x - size.x - m, view.y - size.y - m), Vector2(m, view.y - size.y - m), Vector2(view.x - size.x - m, m), Vector2(m, m)]
	return raw.map(func(p): return Vector2(clampf(p.x, m, maxf(m, view.x - size.x - m)), clampf(p.y, m, maxf(m, view.y - size.y - m))))

func expected_position(k: Dictionary, anchor: Vector2, size: Vector2, view: Vector2, cells: Array) -> Vector2:
	# C:6316-6333 with the score of C:6361-6372.
	var m: float = k.VIEWPORT_MARGIN
	var start: Vector2 = anchor + Vector2(52.0, -size.y - k.ANCHOR_GAP)
	var best := Vector2(clampf(start.x, m, maxf(m, view.x - size.x - m)), clampf(start.y, m, maxf(m, view.y - size.y - m)))
	var best_score := INF
	var candidates := expected_candidates(k, anchor, size, view)
	for i in range(candidates.size()):
		var p: Vector2 = candidates[i]
		var grown := Rect2(p, size).grow(k.GRID_AVOID_PADDING)
		var score := 0.0
		for c in cells:
			var o: Rect2 = grown.intersection(c)
			if o.has_area(): score += o.get_area()
		score += (p + size * 0.5).distance_to(anchor) * k.DISTANCE_SCORE_WEIGHT
		if i >= int(k.NEAR_CANDIDATE_COUNT): score += k.FAR_FALLBACK_SCORE
		score += float(i) * 0.01
		if score < best_score:
			best_score = score
			best = p
	return best

func cell_box(lab, world: Vector3) -> Rect2:
	# A cell's screen box: its four edge midpoints projected by the lab camera.
	var half: float = lab.board.CELL * 0.5
	var r := Rect2(lab.camera.unproject_position(world), Vector2.ZERO)
	for o in [Vector3(half, 0, 0), Vector3(-half, 0, 0), Vector3(0, 0, half), Vector3(0, 0, -half)]: r = r.expand(lab.camera.unproject_position(world + o))
	return r

func independent_open(lab, b) -> bool:
	# The open rule from engine and lab state (not hud_command_panel_open): an ally to act in ally_turn, no engine
	# animation, no auto, no result, no enemy replay, no cut-in hold, its view shown and its anchor on screen.
	var u = b.active_unit_state
	if u == null or u.side != "ally" or b.current_phase != "ally_turn" or b.is_demo_animating or b.is_full_auto_battle_enabled: return false
	if not lab.battle_result.is_empty() or not lab.enemy_queue.is_empty() or lab.enemy_hold > 0.0 or lab.hud_cutin_hold: return false
	if not lab.views.has(u.unit_id) or not lab.views[u.unit_id].visible: return false
	return root.get_visible_rect().has_point(lab.camera.unproject_position(lab.views[u.unit_id].position + Vector3(0, h.shell.PANEL_ANCHOR_HEIGHT, 0)))

func click_point(at: Vector2) -> void:
	mouse(at, "move")
	await process_frame
	mouse(at, "down")
	await process_frame
	mouse(at, "up")
	await process_frame

func block43_additions() -> void:
	var k := c_constants()
	h.expect(k.size() == 6, "the six 2D placement constants read from the 2D script %s" % k)
	# 4. Placement = the 2D rule recomputed here, for several anchors (middle, edges, corners), with and without cells.
	var view := root.get_visible_rect().size
	var anchors := [view * 0.5, Vector2(5, 5), Vector2(view.x - 5, 5), Vector2(5, view.y - 5), Vector2(view.x - 5, view.y - 5), Vector2(view.x * 0.5, 8), Vector2(8, view.y * 0.5), Vector2(view.x - 30, view.y * 0.4)]
	var cells := [Rect2(view.x * 0.5 + 30, view.y * 0.5 - 60, 80, 50), Rect2(view.x * 0.5 - 200, view.y * 0.5 + 40, 80, 50)]
	var pos_bad := []
	for a in anchors:
		for rects in [[], cells]:
			var want := expected_position(k, a, panel.PANEL_SIZE, view, rects)
			var got: Vector2 = panel.choose_position(a, panel.PANEL_SIZE, rects)
			if not got.is_equal_approx(want): pos_bad.append([a, rects.size(), got, want])
	h.expect(pos_bad.is_empty(), "placement = the 2D candidates, clamp, distance weight and far penalty recomputed from the 2D constants (16 cases) %s" % str(pos_bad))
	# 3. Move-range avoidance on a real selection, and the live position = the recomputed rule.
	await h.press_scenario(self, "default")
	var lab = h.lab
	var b: Node = lab.engine
	await settle(lab, b)
	var u = b.active_unit_state
	await click_point(lab.camera.unproject_position(lab.board.world(u.grid_cell)))
	for i in range(3): await process_frame
	var ranges: Array = lab.hud_range_cell_positions()
	h.expect(not ranges.is_empty(), "a real selection click shows the move range (%d cells)" % ranges.size())
	var boxes := ranges.map(func(w): return cell_box(lab, w))
	var avoid := boxes + [cell_box(lab, lab.board.world(u.grid_cell))]
	var anchor: Vector2 = lab.camera.unproject_position(lab.views[u.unit_id].position + Vector3(0, h.shell.PANEL_ANCHOR_HEIGHT, 0))
	var pr: Rect2 = panel.panel_rect()
	var all_near_overlap := expected_candidates(k, anchor, panel.PANEL_SIZE, view).slice(0, 8).all(func(p): return boxes.any(func(c): return Rect2(p, panel.PANEL_SIZE).intersects(c)))
	var overlapping := boxes.filter(func(c): return (c as Rect2).intersects(pr))
	h.expect(overlapping.is_empty() or all_near_overlap, "the panel %s overlaps no move-range cell (%d overlap; every near candidate overlapping: %s)" % [pr, overlapping.size(), all_near_overlap])
	h.expect(pr.position.is_equal_approx(expected_position(k, anchor, panel.PANEL_SIZE, view, avoid)), "live position = the 2D rule recomputed with the range cells and the unit's own cell %s / %s" % [pr.position, expected_position(k, anchor, panel.PANEL_SIZE, view, avoid)])
	# 1. N7 under a raised cost: the skill line shows the engine's effective cost, not the base cost.
	var skill: Dictionary = b.call("_get_unique_skill_for_unit", u)
	var base := int(skill.get("momentum_cost", 0))
	u.apply_status_effect("skill_cost_up", 2, 2) # test-only fixture: the engine's cost-raising status
	for i in range(3): await process_frame
	var cost := int(b.call("_get_effective_unique_skill_cost", u, skill))
	h.expect(cost != base and panel.button_at(1).text == "%s · 기세 %d" % [str(skill.get("name", "고유특기")), cost], "skill_cost_up: the panel shows the engine's effective cost %d (base %d) '%s'" % [cost, base, panel.button_at(1).text])
	# 5. [책략] enabled (test-only fixture: an enemy next to the acting ally), real panel click vs the lab's own button.
	var strategy_prints := []
	var offsets := [Vector2i(1, 0), Vector2i(0, -1), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(2, 0), Vector2i(1, -1)]
	for path in ["panel_mouse", "lab_emit"]:
		await h.press_restart(self)
		lab = h.lab
		b = lab.engine
		await settle(lab, b)
		var actor = b.active_unit_state
		var enemy = b.all_battle_unit_states.filter(func(x): return x.unit_id == "guan_yu")[0]
		for o in offsets:
			var c: Vector2i = actor.grid_cell + o
			if lab.board.valid(c) and b.all_battle_unit_states.all(func(x): return x.grid_cell != c):
				enemy.grid_cell = c
				lab._sync_views()
				for i in range(2): await process_frame
				if not lab.strategy_button.disabled: break
		var enabled: bool = not lab.strategy_button.disabled
		var start_print := engine_print(b)
		var writes: Array = b.writes.duplicate()
		seed(11)
		if path == "panel_mouse":
			h.expect(enabled and not panel.button_at(2).disabled, "[책략] enabled with %s next to %s (lab tooltip '%s')" % [enemy.grid_cell, actor.unit_id, lab.strategy_button.tooltip_text])
			await real_click(panel.button_at(2))
		else:
			lab.strategy_button.pressed.emit()
		await settle(lab, b)
		strategy_prints.append([engine_print(b), b.writes.slice(writes.size()), b.current_phase, start_print])
	h.expect(strategy_prints[0][1].slice(0, 1) == ["_on_strategy_button_pressed"] and strategy_prints[0][0] == strategy_prints[1][0],
		"[책략] by a real panel click = the lab's [책략]: _on_strategy_button_pressed, same engine fingerprint (writes %s / %s, phase %s / %s)" % [strategy_prints[0][1], strategy_prints[1][1], strategy_prints[0][2], strategy_prints[1][2]])
	# 2. The open rule from engine state, every frame: waits by real panel clicks, then [자동] to the result.
	h.shell.choose_button.pressed.emit()
	await process_frame
	await h.press_scenario(self, "win_practice")
	lab = h.lab
	b = lab.engine
	var seen := {"open":0, "replay":0, "demo":0, "cutin":0, "result":0}
	var wrong := []
	var lag := 0
	var prev_ok := true
	var waits := 0
	for i in range(120000):
		await process_frame
		if not h.shell.top_hud.visible and not lab.battle_result.is_empty():
			seen.result += 1 if not panel_open() else 0
			if h.shell.result_panel.visible: break
			continue
		var want := independent_open(lab, b)
		var ok := panel_open() == want
		if not ok:
			if prev_ok: lag += 1
			elif wrong.size() < 5: wrong.append([i, b.current_phase, panel_open(), want])
		prev_ok = ok
		if not panel_open():
			if not lab.enemy_queue.is_empty() or lab.enemy_hold > 0.0: seen.replay += 1
			if b.is_demo_animating: seen.demo += 1
			if lab.hud_cutin_hold: seen.cutin += 1
		else:
			seen.open += 1
			if waits < 3 and ok:
				await real_click(panel.button_at(4))
				waits += 1
				prev_ok = true
			elif waits >= 3 and not b.is_full_auto_battle_enabled:
				h.press_auto()
	h.expect(wrong.is_empty() and seen.open > 0 and seen.replay > 0 and seen.demo > 0 and seen.result > 0,
		"open rule from engine state every frame (one-frame lag %d): closed during the enemy replay (%d frames), engine animation (%d), cut-in hold (%d), after the result (%d); wrong %s" % [lag, seen.replay, seen.demo, seen.cutin, seen.result, wrong])
	print("[COMMAND_PANEL_CHECKS] open rule: open rule frames ", seen, " lag ", lag)


func run() -> void:
	h = load("res://tests/scripts/support/battle3d_scenario_harness.gd").new()
	await h.open_shell(self)
	root.size = Vector2i(1920, 1080)
	panel = h.shell.command_panel
	await block43_additions()
	await h.close_shell(self)
	print("[COMMAND_PANEL_CHECKS] checks=", h.checks, " failures=", h.failures)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	panel = null
	await process_frame
	quit(code)
