extends SceneTree
# F2 step latch (engine). (1) Latch off: with no hold ever sent (no 3D), the
# engine auto runs step after step on its own and never holds itself (the BASE
# parity golden covers the whole battle). (2) Latch on: after one hold, every
# auto step re-arms the hold at its start, so one release = exactly one step,
# even when a step ends inside the frame. (3) Close: the latch belongs to the
# engine node the 3D lab owns; closing the lab frees it, and a new lab starts
# with the latch off and its auto running.
var e
var h3

func _initialize() -> void:
	run.call_deferred()

func settle(b: Node, max_frames := 4000) -> int:
	var frames := 0
	while frames < max_frames:
		await process_frame
		frames += 1
		if b.current_phase == "ally_turn" and not b.is_demo_animating: return frames
	return frames

func run() -> void:
	e = load("res://tests/scripts/support/battle_setup_s43_harness.gd").new()
	# (1) Latch off.
	var host = await e.open_s43(self, null)
	var b: Node = host.battle
	Engine.time_scale = 4.0
	seed(1)
	b._toggle_full_auto_battle()
	var held_frames := 0
	for i in range(20000):
		await process_frame
		if b.auto_presentation_hold or b.auto_presentation_latch: held_frames += 1
		if b.auto_battle_step_count >= 6 or b._get_battle_result_state() != "": break
	e.expect(not b.auto_presentation_latch and held_frames == 0 and b.auto_battle_step_count >= 6, "latch off: the engine auto runs %d steps with no hold at all" % b.auto_battle_step_count)
	Engine.time_scale = 1.0
	await e.close_bare(self, host)

	# (2) Latch on: one release = one step.
	host = await e.open_s43(self, null)
	b = host.battle
	Engine.time_scale = 4.0
	seed(1)
	b.set_auto_presentation_hold(true)
	b._toggle_full_auto_battle()
	for i in range(60): await process_frame
	e.expect(b.auto_presentation_latch and b.auto_presentation_hold and b.auto_battle_step_count == 0, "held before the first step (latch on)")
	for k in range(5):
		var steps: int = b.auto_battle_step_count
		b.set_auto_presentation_hold(false)
		await settle(b)
		for i in range(60): await process_frame # stays put: nothing releases it
		e.expect(b.auto_battle_step_count == steps + 1 and b.auto_presentation_hold, "release %d: exactly one step (%d -> %d), hold re-armed" % [k + 1, steps, b.auto_battle_step_count])
		if b._get_battle_result_state() != "": break
	# Two ticks in the same idle state after a release: the first step re-arms, the second tick is held.
	var before: int = b.auto_battle_step_count
	b.auto_presentation_hold = false # fixture write: release without the deferred resume
	b._tick_full_auto_battle_if_needed()
	b._tick_full_auto_battle_if_needed()
	e.expect(b.auto_battle_step_count == before + 1 and b.auto_presentation_hold, "a second tick in the same frame is held by the latch")
	Engine.time_scale = 1.0
	await settle(b)
	await e.close_bare(self, host)

	# (3) Close: the 3D lab owns the engine and its latch.
	h3 = load("res://tests/scripts/support/battle3d_auto_hold_harness.gd").new()
	await h3.open_lab(self)
	var engine: Node = h3.lab.engine
	var calls: Array = engine.hold_calls
	h3.press_auto()
	for i in range(3000):
		await process_frame
		if engine.auto_presentation_latch and engine.auto_presentation_hold: break
	e.expect(engine.auto_presentation_latch and engine.auto_presentation_hold, "3D running: latch on, hold on")
	await h3.close_lab(self)
	e.expect(not is_instance_valid(engine) and calls[-1][0] == false, "lab closed: the latched engine is freed, last hold call false")
	await h3.open_lab(self)
	engine = h3.lab.engine
	e.expect(not engine.auto_presentation_latch and not engine.auto_presentation_hold, "new lab: a new engine with the latch off")
	h3.press_auto()
	var frames := 0
	while frames < 20000 and engine.auto_battle_step_count < 3:
		await process_frame
		frames += 1
	e.expect(engine.auto_battle_step_count >= 3, "new lab: auto keeps running through releases (%d steps in %d frames)" % [engine.auto_battle_step_count, frames])
	await h3.close_lab(self)

	print("[AUTO_PRESENTATION_LATCH] checks=", e.checks + h3.checks, " failures=", e.failures + h3.failures)
	var code := 0 if (e.failures + h3.failures).is_empty() else 1
	e = null
	h3 = null
	await process_frame
	quit(code)
