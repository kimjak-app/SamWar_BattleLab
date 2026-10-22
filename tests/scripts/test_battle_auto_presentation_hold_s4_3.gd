extends SceneTree
# S4-3 auto presentation hold (`set_auto_presentation_hold`, default false).
# While held, the full auto tick does nothing (no step, no log, no random draw);
# releasing it once resumes with one tick; holding in the middle of auto lets the
# running step (one engine auto tick: a move, or an attack / wait) finish and
# stops before the next tick; stopping auto while held returns to manual play,
# and the enemy slot after a manual action plays while held; with auto off the
# hold changes nothing; a second release adds nothing. A doubled tick in the
# same state starts one action only.
var h
const PROBE_SEED := 4242

func _initialize() -> void:
	run.call_deferred()

func frames(n: int) -> void:
	for i in range(n): await process_frame

func counts(b: Node) -> Array:
	return [b.auto_battle_step_count, b.ally_move_event_log.export().size(), b.battle_action_event_log.export().size(), b.enemy_action_event_log.export().size(), b.tactic_event_log.export().size()]

func run() -> void:
	h = load("res://tests/scripts/support/battle_setup_s43_harness.gd").new()
	var host = await h.open_s43(self, null)
	var b: Node = host.battle
	h.expect(b.auto_presentation_hold == false, "default false")
	# Held before auto starts: nothing happens.
	b.set_auto_presentation_hold(true)
	seed(PROBE_SEED)
	var expected_random := randf()
	seed(PROBE_SEED)
	var before := counts(b)
	b._toggle_full_auto_battle()
	await frames(90)
	h.expect(b.is_full_auto_battle_enabled and counts(b) == before and b.tick_calls >= 1, "held: auto on, ticks blocked, no step or log " + str(counts(b)) + " ticks=" + str(b.tick_calls))
	h.expect(randf() == expected_random, "held: no random number drawn")
	seed(PROBE_SEED)
	# Release once: one tick, one step.
	var ticks: int = b.tick_calls
	var enemy_before: int = b.enemy_action_event_log.export().size()
	b.set_auto_presentation_hold(false)
	await process_frame
	h.expect(b.tick_calls == ticks + 1 and b.auto_battle_step_count == 1, "release: one deferred tick, one step (ticks %d -> %d, steps %d)" % [ticks, b.tick_calls, b.auto_battle_step_count])
	# A second release adds nothing.
	b.set_auto_presentation_hold(false)
	await process_frame
	h.expect(b.tick_calls == ticks + 1 and b.auto_battle_step_count == 1, "second release: no extra tick or step")
	# Hold in the middle: the running ally action and the enemy slot finish, the next ally action does not start.
	b.set_auto_presentation_hold(true)
	await h.settle(self, b)
	await frames(120)
	h.expect(b.auto_battle_step_count == 1 and b.current_phase == "ally_turn" and not b.is_demo_animating, "held mid-auto: stops at the next ally turn (steps %d)" % b.auto_battle_step_count)
	# The first auto step of the default battle is a move (the attack / wait after it is the next tick): the move finished.
	h.expect(b.ally_move_event_log.export().any(func(e): return e.kind == "unit_moved") and b.enemy_action_event_log.export().size() == enemy_before, "held mid-auto: the running move finished, no further step and no enemy slot " + str(counts(b)))
	# Stop auto while held: manual play works.
	b._toggle_full_auto_battle()
	h.expect(not b.is_full_auto_battle_enabled and b._is_active_ally_action_available(), "stopped while held: manual command available")
	var acted_before: int = b.action_lock_state_service.export_acted_ids("ally").size()
	var enemy_slots: int = b.enemy_action_event_log.export().filter(func(e): return e.kind == "enemy_action_completed").size()
	await h.ally_wait(self, b)
	h.expect(b.auto_presentation_hold and (b.action_lock_state_service.export_acted_ids("ally").size() > acted_before or b.battle_round > 1), "manual wait works while held with auto off")
	h.expect(b.enemy_action_event_log.export().filter(func(e): return e.kind == "enemy_action_completed").size() == enemy_slots + 1, "the enemy slot plays while held (the gate is only the auto tick)")
	# Auto off: releasing changes nothing.
	ticks = b.tick_calls
	var c0: Array = counts(b)
	b.set_auto_presentation_hold(false)
	await frames(30)
	h.expect(b.auto_battle_step_count == 0 and counts(b) == c0, "auto off: hold release does not act")
	await h.close_bare(self, host)

	# A doubled tick in the same ally state starts one action only.
	host = await h.open_s43(self, null)
	b = host.battle
	b.set_auto_presentation_hold(true)
	b._toggle_full_auto_battle()
	await process_frame
	b.auto_presentation_hold = false # fixture write: release without the deferred resume
	b._tick_full_auto_battle_if_needed()
	b._tick_full_auto_battle_if_needed()
	h.expect(b.auto_battle_step_count == 1, "two ticks in the same state: one step (%d)" % b.auto_battle_step_count)
	await h.close_bare(self, host)

	print("[AUTO_PRESENTATION_HOLD] checks=", h.checks, " failures=", h.failures)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
