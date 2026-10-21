extends SceneTree
# S4-1 strategy dice hook. (1) A hook forces success/failure and the outcome
# pool index on every tier; the hook is asked for the pool index only on a
# success. (2) With the same RNG seed, no hook == a hook that returns exactly
# what BASE would draw (randf() <= rate, randi() % size): same units,
# controller, existing logs and tactic events.
var h
var calls: Array = []

func _initialize() -> void:
	_run.call_deferred()

func forced(want_success: bool, want_pool: int) -> Callable:
	return func(kind: String, value):
		calls.append(kind)
		return want_success if kind == "success" else want_pool

func base_equivalent(kind: String, value):
	calls.append(kind)
	return randf() <= value if kind == "success" else randi() % value

func view(result: Dictionary) -> Dictionary:
	return {"checkpoints":result.checkpoints, "logs_end":result.logs_end, "tactic":result._tactic_events}

func _run() -> void:
	h = load("res://tests/scripts/support/battle_tactic_oracle_harness.gd").new()
	h.tag = "[TACTIC_DICE_HOOK]"
	var pools := {80:[["shake", 1]], 90:[["confusion", 1], ["shake", 2]], 95:[["confusion", 2], ["shake", 3]]}
	var tier_case := {80:"S1_basic_success", 90:"S3_advanced_success_pool0", 95:"S6_master_success_pool0"}
	for intel in [80, 90, 95]:
		var options: Array = pools[intel]
		var wanted: Array = [[false, 0]]
		for i in range(options.size()): wanted.append([true, i])
		for want in wanted:
			calls.clear()
			h.roll_override = forced(want[0], want[1])
			var result: Dictionary = await h.run_case(self, tier_case[intel])
			var casts: Array = result._tactic_events.filter(func(e): return e.kind == "strategy_cast")
			var label := "int=%d success=%s pool=%d" % [intel, want[0], want[1]]
			h.expect(casts.size() == 1, label + " one strategy_cast")
			if casts.size() == 1:
				var e: Dictionary = casts[0]
				h.expect(e.success == want[0], label + " forced success flag")
				if want[0]:
					h.expect(e.status_id == options[want[1]][0] and e.turns == options[want[1]][1], label + " forced pool entry " + str(e))
				else:
					h.expect(e.status_id == "" and e.turns == 0, label + " failure has no status")
			h.expect(calls == (["success", "pool_index"] if want[0] else ["success"]), label + " hook asked " + str(calls))
			print("[TACTIC_DICE_HOOK] ", label, " calls=", calls, " cast=", casts)
	# No hook vs a BASE-equivalent hook with the same seed.
	for label in ["S1_basic_success", "S2_basic_fail", "S4_advanced_success_pool1", "S6_master_success_pool0", "S8_master_fail"]:
		h.roll_override = Callable()
		var plain: Dictionary = await h.run_case(self, label)
		calls.clear()
		h.roll_override = base_equivalent
		var hooked: Dictionary = await h.run_case(self, label)
		var diff: Array = h.fingerprint.diff([view(plain)], [view(hooked)])
		h.expect(diff.is_empty(), label + " no hook == BASE-equivalent hook " + str(diff.slice(0, 10)))
		h.expect(not calls.is_empty(), label + " BASE-equivalent hook was used")
		print("[TACTIC_DICE_HOOK] ", label, " plain==hooked diff=", diff.size(), " hook calls=", calls)
	h.roll_override = Callable()
	print("[TACTIC_DICE_HOOK] checks=", h.checks, " failures=", h.failures)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
