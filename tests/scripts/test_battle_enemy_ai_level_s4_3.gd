extends SceneTree
# S4-3 enemy AI level: set_enemy_ai_level / get_enemy_ai_level /
# get_pending_enemy_ai_level. Default "low" with the three flags untouched;
# an invalid value is refused with no change; a valid one waits and is applied
# at the next enemy turn start (each enemy action slot starts one), never in the
# middle of an enemy action. low = only the use cap; mid / high = all three.
var h
const LOW := [false, false, true]
const SMART := [true, true, true]

func _initialize() -> void:
	run.call_deferred()

func state(b: Node) -> Array:
	return [b.get_enemy_ai_level(), b.get_pending_enemy_ai_level(), h.flags(b), b.enemy_ai_level_applied]

func run() -> void:
	h = load("res://tests/scripts/support/battle_setup_s43_harness.gd").new()
	var host = await h.open_s43(self, null)
	var b: Node = host.battle
	h.expect(state(b) == ["low", "", [false, false, false], false], "default low, nothing pending, flags untouched " + str(state(b)))
	for bad in ["", "LOW", "medium", 3, null, true]:
		h.expect(b.set_enemy_ai_level(bad) == false and state(b) == ["low", "", [false, false, false], false], "invalid %s refused, state unchanged" % str(bad))
	# Set during the ally turn: pending until the next enemy turn start.
	h.expect(b.set_enemy_ai_level("mid") and state(b) == ["low", "mid", [false, false, false], false], "mid pending in the ally turn")
	await h.ally_wait(self, b)
	h.expect(b.enemy_turns.size() == 1 and b.enemy_turns[0][1] == "mid" and b.enemy_turns[0][2] == [false, false, false] and b.enemy_turns[0][3] == SMART, "applied at the enemy turn start " + str(b.enemy_turns))
	h.expect(b.actions_done.size() == 1 and b.actions_done[0][1] == SMART, "the whole first enemy action ran with the new flags")
	h.expect(state(b) == ["mid", "", SMART, true], "mid applied, pending cleared " + str(state(b)))
	# Same value again: nothing pending. A change and back again before the enemy turn: nothing pending.
	h.expect(b.set_enemy_ai_level("mid") and b.get_pending_enemy_ai_level() == "", "same value: nothing pending")
	h.expect(b.set_enemy_ai_level("low") and b.get_pending_enemy_ai_level() == "low" and b.set_enemy_ai_level("mid") and b.get_pending_enemy_ai_level() == "", "low then mid again: nothing pending")
	# Back to low: only the cap.
	b.set_enemy_ai_level("low")
	await h.ally_wait(self, b)
	h.expect(state(b) == ["low", "", LOW, true] and b.enemy_turns[-1][3] == LOW, "low applied: strategy and rotation off, cap on " + str(state(b)))
	# High plays as mid (S4-4 later).
	b.set_enemy_ai_level("high")
	await h.ally_wait(self, b)
	h.expect(state(b) == ["high", "", SMART, true], "high: same flags as mid " + str(state(b)))
	await h.close_bare(self, host)

	# Set while an enemy action runs: that action keeps the old flags, the next enemy turn applies.
	var base_host = await h.open_s43(self, null)
	var base_b: Node = base_host.battle
	seed(7)
	await h.ally_wait(self, base_b)
	var base_final: Dictionary = h.final_state(base_b)
	await h.close_bare(self, base_host)
	host = await h.open_s43(self, null)
	b = host.battle
	b.set_level_on_enemy_action = "mid"
	seed(7)
	await h.ally_wait(self, b)
	var final: Dictionary = h.final_state(b)
	h.expect(b.actions_done.size() == 1 and b.actions_done[0][1] == [false, false, false] and b.get_pending_enemy_ai_level() == "mid", "set during the enemy action: flags unchanged until it ends, mid pending " + str(b.actions_done))
	h.expect(h.fingerprint.diff(base_final.units, final.units).is_empty() and h.fingerprint.diff(base_final.controller, final.controller).is_empty() and base_final.logs == final.logs, "the running enemy action is unchanged (units, controller, logs)")
	await h.ally_wait(self, b)
	h.expect(b.enemy_turns[-1][3] == SMART and state(b)[0] == "mid", "next enemy turn applies mid")
	await h.close_bare(self, host)

	# Never set: flags written by a test are kept through enemy turns.
	host = await h.open_s43(self, null)
	b = host.battle
	b.enemy_strategy_enabled = true
	b.enemy_skill_spread_enabled = true
	await h.ally_wait(self, b)
	await h.ally_wait(self, b)
	h.expect(h.flags(b) == [true, true, false] and b.enemy_turns.all(func(t): return t[3] == [true, true, false]), "unset level leaves test-written flags alone " + str(h.flags(b)))
	await h.close_bare(self, host)

	print("[ENEMY_AI_LEVEL] checks=", h.checks, " failures=", h.failures)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
