extends SceneTree
# NIGHT3 test gaps (engine side). G1/G2: the S4-3 troop scaling keeps a scaled
# positive value at least 1 and leaves a zero (or negative) value as it is.
# G3: releasing the auto presentation hold when nothing was held adds no tick.
# G4: a hold the engine re-armed (step latch) while the 3D believes it already
# released is still released by the 3D (it compares with the engine's own hold).
const Rules = preload("res://scripts/battle/services/battle_setup_rules_service.gd")
var e
var h3

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	e = load("res://tests/scripts/support/battle_setup_s43_harness.gd").new()
	# G1: floor would give 0; at least 1 for a positive value.
	e.expect(Rules.scale_troop_value(3, 0.25) == 1 and Rules.scale_troop_value(1, 0.25) == 1 and Rules.scale_troop_value(2, 0.1) == 1, "G1 a positive value never scales to 0")
	e.expect(Rules.scale_troop_value(8, 0.25) == 2 and Rules.scale_troop_value(115, 0.25) == 28, "G1 floor otherwise")
	# G2: zero / negative values stay as they are.
	e.expect(Rules.scale_troop_value(0, 0.25) == 0 and Rules.scale_troop_value(0, 1.0) == 0 and Rules.scale_troop_value(-5, 0.25) == -5, "G2 zero and negative values unchanged")

	# G3: a release with no hold in place adds no tick.
	var host = await e.open_s43(self, null)
	var b: Node = host.battle
	b.set_auto_presentation_hold(true)
	b._toggle_full_auto_battle()
	for i in range(10): await process_frame
	b.auto_presentation_hold = false # fixture write: no hold in place, auto on, ally turn, idle, no tick pending
	var ticks: int = b.tick_calls
	var steps: int = b.auto_battle_step_count
	e.expect(b.is_full_auto_battle_enabled and b.current_phase == "ally_turn" and not b.is_demo_animating and steps == 0, "G3 fixture: auto on, idle, not held, no step yet")
	b.set_auto_presentation_hold(false)
	for i in range(10): await process_frame
	e.expect(b.tick_calls == ticks and b.auto_battle_step_count == steps, "G3 release without a hold: no tick (%d -> %d), no step" % [ticks, b.tick_calls])
	await e.close_bare(self, host)

	# G4: engine hold re-armed by the latch, 3D last sent false and is idle -> the 3D still releases.
	h3 = load("res://tests/scripts/support/battle3d_auto_hold_harness.gd").new()
	await h3.open_lab(self)
	var lab = h3.lab
	var engine: Node = lab.engine
	for i in range(5): await process_frame
	e.expect(not lab._presentation_busy() and not lab.auto_hold_sent, "G4 fixture: 3D idle, last value sent false")
	engine.auto_presentation_latch = true # fixture writes: a step re-armed the hold and ended before the 3D saw it busy
	engine.auto_presentation_hold = true
	h3.press_auto()
	var frames := 0
	while frames < 600 and engine.auto_battle_step_count < 1:
		await process_frame
		frames += 1
	e.expect(engine.auto_battle_step_count >= 1 and engine.hold_calls.any(func(c): return c[0] == false), "G4 the 3D released the latched hold and auto went on (%d steps after %d frames, calls %s)" % [engine.auto_battle_step_count, frames, str(engine.hold_calls.slice(0, 3))])
	await h3.close_lab(self)

	print("[NIGHT3_GAPS_ENGINE] checks=", e.checks + h3.checks, " failures=", e.failures + h3.failures)
	var code := 0 if (e.failures + h3.failures).is_empty() else 1
	e = null
	h3 = null
	await process_frame
	quit(code)
