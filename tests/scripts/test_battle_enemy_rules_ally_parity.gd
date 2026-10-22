extends "res://tests/scripts/test_battle_tactic_oracle_baseline.gd"
# S4-2: with BOTH new enemy flags on (test-only), the S4-1 ally scenarios
# (strategy S1..S8, every unique skill effect type, ally auto skill, advance on
# kill, commit failure, status ticks, the single-candidate enemy skill) still
# equal the S4-1 golden captured on its BASE. This proves the `_resolve_strategy`
# split and the enemy-only skill spread leave the ally paths unchanged. The
# default-layout reinforcement round (R1) is excluded: there several enemies
# with skills and two strategists act, which the flags are meant to change.
# Run in shards (CI 120 s per file).

func case_labels() -> Array:
	return super.case_labels().filter(func(label): return label != "R1_default_reinforcements_round3")

func _run() -> void:
	var harness = load("res://tests/scripts/support/battle_tactic_oracle_harness.gd").new()
	harness.tag = "[ENEMY_RULES_ALLY_PARITY]"
	harness.battle_script = load("res://tests/scripts/support/battle_enemy_rules_flags_on_battle.gd")
	harness.post_hook = func(battle: Node, _unit): return {"strategy":battle.get("enemy_strategy_enabled"), "spread":battle.get("enemy_skill_spread_enabled")}
	var labels: Array = case_labels()
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--case="): labels = [arg.trim_prefix("--case=")]
	var scenarios := []
	for label in labels:
		var t0 := Time.get_ticks_msec()
		var result: Dictionary = await harness.run_case(self, label)
		harness.expect(result._post.strategy == true, label + " enemy_strategy_enabled is on in this battle")
		scenarios.append(_golden_view(result))
		print("[ENEMY_RULES_ALLY_PARITY_CASE] ", label, " ms=", Time.get_ticks_msec() - t0, " failures=", harness.failures.size())
		if not harness.failures.is_empty(): break
	var expected = JSON.parse_string(FileAccess.get_file_as_string(GOLDEN))
	harness.expect(expected.base_commit == BASE_COMMIT, "S4-1 golden")
	expected.scenarios = expected.scenarios.filter(func(item): return labels.has(item.case))
	harness.expect(expected.scenarios.size() == labels.size(), "golden covers the selected cases")
	var captured := {"schema_version":0, "base_commit":BASE_COMMIT, "scenarios":scenarios}
	var golden_diff: Array = harness.fingerprint.diff(captured, expected)
	harness.expect(golden_diff.is_empty(), "ally paths with the enemy flags on == S4-1 golden " + str(golden_diff.slice(0, 20)))
	print("[ENEMY_RULES_ALLY_PARITY] checks=", harness.checks, " failures=", harness.failures)
	var exit_code := 0 if harness.failures.is_empty() else 1
	harness = null
	await process_frame
	quit(exit_code)
