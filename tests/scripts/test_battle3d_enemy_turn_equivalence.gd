extends SceneTree
# M3: 3D input round == engine direct round (same six commands), plus
# playback accuracy, hit numbers, event summaries and end overlay per case.
var h

func case_labels() -> Array:
	return load("res://tests/scripts/support/battle3d_enemy_turn_harness.gd").CASES

func _initialize() -> void:
	run.call_deferred()

func cells(path: Array) -> Array:
	var result := []
	for cell in path: result.append(Vector2i(int(cell[0]), int(cell[1])))
	return result

func check_case(label: String, direct: Dictionary, td: Dictionary) -> void:
	h.expect(h.fingerprint.diff(direct.units, td.units).is_empty(), label + " 40-field units equal " + str(h.fingerprint.diff(direct.units, td.units)))
	h.expect(h.fingerprint.diff(direct.controller, td.controller).is_empty(), label + " controller equal " + str(h.fingerprint.diff(direct.controller, td.controller)))
	for name in direct.logs:
		h.expect(direct.logs[name] == td.logs[name], label + " " + name + " equal")
	h.expect(direct.writes == td.writes, label + " same engine write sequence " + str(td.writes))
	for call in td.writes: h.expect(h.WRITES.has(call), label + " write within the six commands " + call)
	var events: Array = td.logs.enemy_action_event_log
	var lab: Dictionary = td.lab
	# Cursors consumed each log exactly once and independently.
	h.expect(lab.cursors == [td.logs.ally_move_event_log.size(), td.logs.battle_action_event_log.size(), events.size()], label + " three cursors at their own log ends")
	# Playback: every enemy_moved path played in order and ended on the engine cell.
	var moved := events.filter(func(e): return e.kind == "enemy_moved")
	h.expect(lab.enemy_played_paths.size() == moved.size(), label + " each enemy_moved played once")
	for i in range(moved.size()):
		h.expect(lab.enemy_played_paths[i] == moved[i].path, label + " played path equals event path")
	var enemy_id: String = h.roles_ids.enemy
	var path_events := moved.filter(func(e): return e.unit_id == enemy_id)
	if not path_events.is_empty():
		var expected: Array = cells(path_events[0].path)
		var visited := []
		var started := false
		for frame in lab.frames:
			if frame.moving: started = true
			if started and (visited.is_empty() or visited[-1] != frame.cell): visited.append(frame.cell)
			if started and not frame.moving: break
		h.expect(visited == expected, label + " 3D view passes path cells in order " + str(visited) + " vs " + str(expected))
		var final_cell: Array = []
		for unit in td.units:
			if unit.unit_id == enemy_id: final_cell = unit.grid_cell
		h.expect(lab.frames[-1].cell == Vector2i(final_cell[0], final_cell[1]), label + " final view cell equals engine grid_cell")
	# Hit numbers come from damage_applied.
	var attacks := events.filter(func(e): return e.kind == "enemy_attack_resolved")
	h.expect(lab.hits == attacks, label + " hit presentations equal attack events")
	for attack in attacks:
		var shown := false
		for frame in lab.frames:
			for text in frame.hit_labels:
				if text == "−%s · %s" % [attack.damage_applied, attack.angle_type]: shown = true
		h.expect(shown, label + " hit label shows damage_applied " + str(attack.damage_applied))
	# One event-based summary per enemy slot.
	var slots := events.filter(func(e): return e.kind == "enemy_actor_selected").size()
	h.expect(lab.summaries.size() == slots, label + " one summary per enemy slot")
	for summary in lab.summaries:
		h.expect(summary.events[0].kind == "enemy_actor_selected", label + " summary built from slot events")
	for event in events.filter(func(e): return e.kind == "enemy_waited"):
		var reason_text: String = {"wait":"대기","confused":"혼란","no_path":"경로 없음","path_blocked":"경로 막힘","no_target":"대상 없음"}[event.reason]
		h.expect(lab.texts.has("적 %s · %s" % [event.unit_id, reason_text]), label + " wait reason text " + reason_text)
	for event in events.filter(func(e): return e.kind == "enemy_skill_used"):
		h.expect(lab.texts.has("적 특기 사용: " + event.skill_id), label + " skill text")
		h.expect(not lab.summaries.is_empty() and lab.summaries[-1].text.contains("병력"), label + " skill result shown through state-diff fallback")
	for event in events.filter(func(e): return e.kind == "round_started"):
		h.expect(lab.texts.has("라운드 %d" % event.round) and lab.round == event.round, label + " round text")
	var ended := events.filter(func(e): return e.kind == "battle_ended")
	h.expect(lab.overlay[0] == not ended.is_empty(), label + " overlay only on battle_ended")
	if not ended.is_empty():
		h.expect(lab.result == ended[0].result_state and lab.overlay[1] == {"victory":"승리","defeat":"패배"}[ended[0].result_state], label + " result overlay text")
	h.expect(td.controller.battle_result_state == lab.result, label + " lab result mirrors engine result")

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_enemy_turn_harness.gd").new()
	var labels: Array = case_labels()
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--case="): labels = [arg.trim_prefix("--case=")]
	for label in labels:
		var t0 := Time.get_ticks_msec()
		var direct: Dictionary = await h.run_direct(self, label)
		var td: Dictionary = await h.run_3d(self, label)
		h.roles_ids = {"enemy":h.roles(h.lab.engine).enemy.unit_id}
		await h.close_lab(self)
		check_case(label, direct, td)
		var kinds := []
		for event in td.logs.enemy_action_event_log: kinds.append(event.kind)
		print("[M3_EQUIVALENCE_CASE] ", label, " enemy_events=", kinds, " round=", td.lab.round, " result=", td.lab.result, " ms=", Time.get_ticks_msec() - t0, " failures=", h.failures.size())
		if not h.failures.is_empty(): break
	print("[M3_EQUIVALENCE] checks=", h.checks, " failures=", h.failures)
	quit(0 if h.failures.is_empty() else 1)
