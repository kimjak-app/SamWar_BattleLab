extends SceneTree
# M5-a2: the 3D [자동] (4x) now holds the engine auto tick while its presentation
# runs (`set_auto_presentation_hold`, sent on a change only). Per seed, until the
# engine ends the battle: (a) at every engine auto action start the 3D is idle
# (no move playback, empty enemy replay queue and hold, four cursors at their
# log ends); (b) the final engine state equals the engine's own auto without 3D
# (units, controller, four logs, round 2/3 start snapshots with the next random
# value, write sequence); hold calls alternate true/false and end false; every
# 3D write is one of the fourteen. Run per seed (CI 120 s per file).
var h

func _initialize() -> void:
	run.call_deferred()

func seeds() -> Array:
	return [1, 2, 3]

func speed_presses() -> int:
	return 2 # 1x -> 2x -> 4x

func stop_round() -> int:
	return 0

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_auto_hold_harness.gd").new()
	var speed: float = [1.0, 2.0, 4.0][speed_presses()]
	for seed_value in seeds():
		var t0 := Time.get_ticks_msec()
		var direct: Dictionary = await h.run_auto_direct(self, seed_value, speed, stop_round())
		var td: Dictionary = await h.run_hold_3d(self, seed_value, speed_presses(), stop_round())
		await h.close_lab(self)
		var tag := "seed %d %sx" % [seed_value, speed]
		h.expect(td.time_scale == speed and Engine.time_scale == 1.0, tag + " lab speed, restored on close")
		# (a) no overlap.
		var busy: Array = td.action_starts.filter(func(a): return not a[1].get("idle", false))
		h.expect(td.action_starts.size() > 0 and busy.is_empty(), tag + " 3D idle at every engine auto action start (%d starts) %s" % [td.action_starts.size(), str(busy.slice(0, 2))])
		# Hold edges.
		h.expect(td.hold_calls.size() >= 2 and h.hold_edges_ok(td.hold_calls), tag + " hold sent on changes only, alternating (%d calls)" % td.hold_calls.size())
		if stop_round() == 0:
			h.expect(td.hold_calls[-1][0] == false and td.hold_now == false and td.sent == false, tag + " hold false at the end")
		# (b) same engine result as the engine alone.
		h.expect(direct.writes == td.writes, tag + " same engine write sequence (" + str(td.writes.size()) + " calls)")
		for call in td.writes: h.expect(h.FOURTEEN.has(call), tag + " write within the fourteen " + call)
		for r in [2, 3]:
			h.expect(direct.round_snaps.has(r) and td.round_snaps.has(r) and h.fingerprint.diff(direct.round_snaps[r], td.round_snaps[r]).is_empty(), tag + " round %d start snapshot equal (units, momentum, four logs, next random)" % r)
		if stop_round() == 0:
			h.expect(h.fingerprint.diff(direct.units, td.units).is_empty(), tag + " final units equal")
			h.expect(h.fingerprint.diff(direct.controller, td.controller).is_empty(), tag + " final controller equal " + str(h.fingerprint.diff(direct.controller, td.controller)))
			for name in direct.logs: h.expect(direct.logs[name] == td.logs[name], tag + " " + name + " equal")
			h.expect(direct.tactic == td.tactic, tag + " tactic_event_log equal")
			h.expect(not td.auto_on and td.controller.battle_result_state != "", tag + " the engine ended the battle: " + td.controller.battle_result_state)
		print("[AUTO_HOLD] ", tag, " starts=", td.action_starts.size(), " hold_calls=", td.hold_calls.size(), " result=", td.controller.battle_result_state, " ms=", Time.get_ticks_msec() - t0)
	print("[AUTO_HOLD] checks=", h.checks, " failures=", h.failures)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
