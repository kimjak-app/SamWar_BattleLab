extends SceneTree
# HUD block 4-3 item 1: the "이미 행동한 부대입니다" stall in manual play. Every input is a real mouse event on the
# scenario shell: select (the unit's cell), move (a reachable empty cell), facing (the panel's arrow), wait (the panel's
# [대기]). Checks:
#   - the instructed path (round 1: every ally moves, faces and waits; round 2: the first ally does the same): no
#     engine "이미 행동한 부대입니다", no lab rejection, the state at the round-2 turn start is recorded;
#   - the stall: on the next ally's turn a real click on an ally that already acted keeps the acting ally (no engine
#     selection, no engine message, [대기] still enabled) and the lab says which ally acts now;
#   - after move + facing a real click on the acting unit's own cell does not land on the command panel (no attack
#     selection): the panel never covers the unit's own cell.
var h

func _initialize() -> void:
	run.call_deferred()

func settle(lab, b) -> void:
	for i in range(8000):
		await process_frame
		if b.is_demo_animating or lab._enemy_presentation_busy() or lab._presentation_busy(): continue
		if b.current_phase in ["ally_turn", "facing_select", "attack_select"] or not lab.battle_result.is_empty(): break
	for i in range(3): await process_frame

func push(at: Vector2, kind: String, button := MOUSE_BUTTON_LEFT) -> void:
	var e: InputEvent
	if kind == "move":
		e = InputEventMouseMotion.new()
	else:
		e = InputEventMouseButton.new()
		e.button_index = button
		e.pressed = kind == "down"
	e.position = at
	e.global_position = at
	root.push_input(e)
	await process_frame

func click_at(at: Vector2) -> void:
	await push(at, "move")
	await push(at, "down")
	await push(at, "up")

func cell_point(lab, cell: Vector2i) -> Vector2:
	return lab.camera.unproject_position(lab.board.world(cell))

func engine_messages(b) -> int:
	return b.battle_log_lines.count("이미 행동한 부대입니다")

func manual_turn(lab, b, tag: String) -> Dictionary:
	# Select, move one or two cells, face via the panel arrow, wait via the panel; returns what happened.
	var panel = h.shell.command_panel
	var u = b.active_unit_state
	var rejected: int = lab.rejected
	var log_before: Array = b.battle_log_lines.duplicate()
	await click_at(cell_point(lab, u.grid_cell))
	var target = null
	for c in lab.queries.query(u.unit_id, u.grid_cell).get("reachable", {}).keys():
		if c != u.grid_cell and b.all_battle_unit_states.all(func(x): return x.grid_cell != c) and lab.board.valid(c + Vector2i(1, 0)):
			target = c
			break
	if target == null: return {"tag":tag, "unit":u.unit_id, "error":"no target"}
	await click_at(cell_point(lab, target))
	var waited := 0
	while not (b.current_phase == "facing_select" and panel.arrows.visible) and waited < 3000:
		await process_frame
		waited += 1
	await click_at(panel.arrow_for("right").get_global_rect().get_center())
	await process_frame
	var faced: bool = b.current_phase == "ally_turn" and u.facing == "right"
	for i in range(3): await process_frame
	await click_at(panel.button_at(4).get_global_rect().get_center()) # [대기]
	var acted: bool = u.has_acted
	await settle(lab, b)
	return {"tag":tag, "unit":u.unit_id, "moved_to":target, "faced":faced, "acted":acted, "lab_rejected":lab.rejected - rejected,
		"engine_message":b.battle_log_lines.slice(log_before.size()).has("이미 행동한 부대입니다") or engine_messages(b) > log_before.count("이미 행동한 부대입니다")}

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_scenario_harness.gd").new()
	await h.open_shell(self)
	root.size = Vector2i(1920, 1080)
	await h.press_scenario(self, "default")
	var lab = h.lab
	var b: Node = lab.engine
	await settle(lab, b)
	# The instructed path: round 1 every ally, then round 2's first ally.
	var turns := []
	while b.battle_round == 1 and b.current_phase == "ally_turn" and turns.size() < 6:
		turns.append(await manual_turn(lab, b, "round 1"))
	var u = b.active_unit_state
	var round2_start := {"round":b.battle_round, "phase":b.current_phase, "active":u.unit_id if u else "null", "has_moved":u.has_moved if u else null,
		"has_acted":u.has_acted if u else null, "lock_acted":b.call("_has_ally_unit_acted", u) if u else null, "confused":b.call("_is_unit_confused", u) if u else null}
	print("[ACTED] round 2 first ally turn state: ", round2_start)
	turns.append(await manual_turn(lab, b, "round 2"))
	print("[ACTED] manual turns: ", turns)
	h.expect(turns.size() == 4 and turns.all(func(t): return not t.has("error") and t.faced and t.acted and t.lab_rejected == 0 and not t.engine_message),
		"real-click manual path, round 1 (3 allies) + round 2 first ally: moved, faced by the arrow, waited by the panel; no rejection, no engine message %s" % str(turns))
	h.expect(round2_start.round == 2 and round2_start.phase == "ally_turn" and round2_start.active == "yi_sunsin" and not round2_start.has_acted and not round2_start.lock_acted,
		"round 2 starts with yi_sunsin to act (not acted) %s" % str(round2_start))
	# The stall: the next ally's turn, a real click on the ally that already acted.
	var acting: String = b.active_unit_state.unit_id
	var acted_unit = b.all_battle_unit_states.filter(func(x): return x.unit_id == "yi_sunsin")[0]
	h.expect(acted_unit.has_acted and acting != "yi_sunsin", "next ally's turn (%s); yi_sunsin has acted" % acting)
	var messages := engine_messages(b)
	var writes: Array = b.writes.duplicate()
	await click_at(cell_point(lab, acted_unit.grid_cell))
	for i in range(2): await process_frame
	h.expect(b.active_unit_state.unit_id == acting and engine_messages(b) == messages and not b.writes.slice(writes.size()).has("_select_ally_unit"),
		"a real click on an ally that already acted keeps %s active (active %s, engine message +%d, writes %s)" % [acting, b.active_unit_state.unit_id, engine_messages(b) - messages, b.writes.slice(writes.size())])
	h.expect(not lab.wait_button.disabled and lab.status.text.contains("이미 행동한 부대") and lab.status.text.contains(acting), "[대기] stays enabled; the lab names the acting ally ('%s')" % lab.status.text)
	# The acting unit's own cell after move + facing: not covered by the panel (no attack selection).
	var own = b.active_unit_state
	await click_at(cell_point(lab, own.grid_cell))
	var target = null
	for c in lab.queries.query(own.unit_id, own.grid_cell).get("reachable", {}).keys():
		if c != own.grid_cell and b.all_battle_unit_states.all(func(x): return x.grid_cell != c) and lab.board.valid(c + Vector2i(1, 0)):
			target = c
			break
	await click_at(cell_point(lab, target))
	var waited := 0
	while not (b.current_phase == "facing_select" and h.shell.command_panel.arrows.visible) and waited < 3000:
		await process_frame
		waited += 1
	await click_at(h.shell.command_panel.arrow_for("right").get_global_rect().get_center())
	for i in range(3): await process_frame
	var own_point := cell_point(lab, own.grid_cell)
	var panel_rect: Rect2 = h.shell.command_panel.panel_rect()
	h.expect(h.shell.command_panel.panel.visible and not panel_rect.has_point(own_point), "after move + facing the panel %s does not cover the unit's own point %s" % [panel_rect, own_point])
	var own_writes: Array = b.writes.duplicate()
	await click_at(own_point)
	for i in range(2): await process_frame
	var new_writes: Array = b.writes.slice(own_writes.size())
	h.expect(b.current_phase == "ally_turn" and new_writes.all(func(w): return w == "_select_ally_unit"), "a real click on the acting unit's own cell presses no panel command (phase %s, writes %s)" % [b.current_phase, new_writes])
	await h.close_shell(self)
	print("[ACTED] checks=", h.checks, " failures=", h.failures)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
