extends SceneTree
# M5-a speed: the same 3D auto run (default battle, seed 1) at 1x, 2x and 4x
# reaches the start of round 3 with identical engine snapshots at rounds 2 and 3
# (units, momentum, four logs in order, next random value). The speed button
# cycles 1x -> 2x -> 4x -> 1x, changes only Engine.time_scale (no engine write),
# and closing the lab restores Engine.time_scale = 1.0 from any speed.
var h

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_auto_harness.gd").new()
	# Button cycle and no engine write.
	await h.open_lab(self)
	var lab = h.lab
	var writes: int = lab.engine.writes.size()
	var seen := [[lab.speed_button.text, Engine.time_scale]]
	for i in range(3):
		lab.speed_button.pressed.emit()
		seen.append([lab.speed_button.text, Engine.time_scale])
	h.expect(seen == [["속도 1x", 1.0], ["속도 2x", 2.0], ["속도 4x", 4.0], ["속도 1x", 1.0]], "speed cycle " + str(seen))
	h.expect(lab.engine.writes.size() == writes, "speed changes send no engine write")
	lab.speed_button.pressed.emit()
	lab.speed_button.pressed.emit()
	h.expect(Engine.time_scale == 4.0, "lab at 4x before close")
	await h.close_lab(self)
	h.expect(Engine.time_scale == 1.0, "closing the lab restores 1x")
	# Same result at every speed.
	var runs := {}
	for presses in [0, 1, 2]:
		var t0 := Time.get_ticks_msec()
		var td: Dictionary = await h.run_auto_3d(self, 1, presses, 3)
		await h.close_lab(self)
		var speed: float = [1.0, 2.0, 4.0][presses]
		h.expect(td.lab.time_scale == speed and Engine.time_scale == 1.0, "ran at %sx, restored 1x after close" % speed)
		h.expect(td.round_snaps.has(2) and td.round_snaps.has(3), "%sx reached round 3" % speed)
		runs[speed] = td.round_snaps
		print("[M5A_SPEED_CASE] ", speed, "x ms=", Time.get_ticks_msec() - t0, " next_randf=", td.round_snaps.get(3, {}).get("next_randf", -1))
	for speed in [2.0, 4.0]:
		for r in [2, 3]:
			h.expect(runs[1.0].has(r) and runs[speed].has(r) and h.fingerprint.diff(runs[1.0][r], runs[speed][r]).is_empty(), "round %d start identical at 1x and %sx (event order, state, next random)" % [r, speed])
	print("[M5A_SPEED] checks=", h.checks, " failures=", h.failures)
	quit(0 if h.failures.is_empty() else 1)
