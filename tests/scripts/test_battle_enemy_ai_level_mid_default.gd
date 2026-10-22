extends SceneTree
# S4-3: the mid level reaches the S4-2 / S4-2c rules. Default layout, engine
# full auto at 4x, seed 1: a battle started with `enemy_ai_level: "mid"` in the
# start setup equals a battle whose three flags the test writes directly
# (strategy, rotation, use cap) before the toggle: final units, controller, four
# logs, round-start snapshots, writes. The enemy skill counts are printed for the
# report (compared there with the S4-2c "cap + rotation" measurement).
var h

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	h = load("res://tests/scripts/support/battle_setup_s43_harness.gd").new()
	var by_level: Dictionary = await h.run_auto_with(self, 1, {"enemy_ai_level":"mid"}, [])
	var direct: Dictionary = await h.run_auto_with(self, 1, null, [true, true, true])
	h.expect(by_level.level == ["mid", ""] and by_level.flags == [true, true, true], "mid applied " + str(by_level.level))
	h.expect(direct.level == ["low", ""], "direct flags run never set a level")
	h.expect(h.battle_digest(by_level) == h.battle_digest(direct), "mid level == three flags written directly")
	h.expect(h.fingerprint.diff(by_level.units, direct.units).is_empty() and h.fingerprint.diff(by_level.controller, direct.controller).is_empty(), "units and controller equal")
	var counts := {}
	for id in by_level.enemy_skills: counts[id] = counts.get(id, 0) + 1
	print("[ENEMY_AI_LEVEL_MID] result=", by_level.controller.battle_result_state, " round=", by_level.controller.battle_round, " enemy_skills=", by_level.enemy_skills, " counts=", counts)
	print("[ENEMY_AI_LEVEL_MID] checks=", h.checks, " failures=", h.failures)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
