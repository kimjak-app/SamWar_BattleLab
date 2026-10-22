extends SceneTree
# S4-2b: with both new flags off (the committed default), the skill-spread
# scenarios (several enemies with high-value unique skills, momentum for one or
# both, recent-use history, a blocked follower) on the new engine == golden
# captured on the BASE engine: units (40 fields), controller (12 values),
# checkpoints, the four event logs and the battle log lines.
const GOLDEN := "res://tests/golden/battle_enemy_skill_spread_base_v0.json"
const BASE_COMMIT := "8957b27c9cbf68e7c4b444b7397a2e68edb7ca93"
const HARNESS := "res://tests/scripts/support/battle_enemy_strategy_oracle_harness.gd"

static func all_labels() -> Array:
	return load(HARNESS).SPREAD_SCENARIOS.duplicate()

func case_labels() -> Array:
	return all_labels()

func _initialize() -> void:
	_run.call_deferred()

func _golden_view(result: Dictionary) -> Dictionary:
	var view := {}
	for key in result:
		if not String(key).begins_with("_"): view[key] = result[key]
	return view

func run_label(harness, label: String) -> Dictionary:
	return await harness.run_spread_scenario(self, label)

func _run() -> void:
	var harness = load(HARNESS).new()
	harness.tag = "[ENEMY_SKILL_SPREAD_BASE_PARITY]"
	harness.battle_script = load("res://tests/scripts/support/battle_enemy_skill_seam_battle.gd")
	var args := OS.get_cmdline_user_args()
	var labels: Array = case_labels()
	for arg in args:
		if arg.begins_with("--case="): labels = [arg.trim_prefix("--case=")]
	var repeat := 2 if args.has("--update-golden") else 1
	var scenarios := []
	for label in labels:
		var t0 := Time.get_ticks_msec()
		var first: Dictionary = _golden_view(await run_label(harness, label))
		for i in range(repeat - 1):
			var again: Dictionary = _golden_view(await run_label(harness, label))
			harness.expect(harness.fingerprint.diff([first], [again]).is_empty(), label + " deterministic twice " + str(harness.fingerprint.diff([first], [again]).slice(0, 5)))
		scenarios.append(first)
		print("[ENEMY_SKILL_SPREAD_BASE_PARITY_CASE] ", label, " enemy=", first.logs_end.enemy_action_event_log.map(func(e): return e.kind), " ms=", Time.get_ticks_msec() - t0, " failures=", harness.failures.size())
		if not harness.failures.is_empty(): break
	var captured := {"schema_version":0, "base_commit":BASE_COMMIT, "scenarios":scenarios}
	if args.has("--update-golden"):
		harness.expect(labels.size() == all_labels().size(), "only the complete suite can write the golden")
		if harness.failures.is_empty():
			var file := FileAccess.open(GOLDEN, FileAccess.WRITE)
			file.store_string(JSON.stringify(captured, "\t", true) + "\n")
			file.close()
			print("[ENEMY_SKILL_SPREAD_BASE_PARITY] golden written")
	elif harness.failures.is_empty():
		harness.expect(FileAccess.file_exists(GOLDEN), "golden exists")
		if FileAccess.file_exists(GOLDEN):
			var expected = JSON.parse_string(FileAccess.get_file_as_string(GOLDEN))
			harness.expect(expected.base_commit == BASE_COMMIT, "golden generated on BASE")
			expected.scenarios = expected.scenarios.filter(func(item): return labels.has(item.case))
			harness.expect(expected.scenarios.size() == labels.size(), "golden covers the selected cases")
			var golden_diff: Array = harness.fingerprint.diff(JSON.parse_string(JSON.stringify(captured)), expected)
			harness.expect(golden_diff.is_empty(), "golden parity " + str(golden_diff.slice(0, 20)))
	print("[ENEMY_SKILL_SPREAD_BASE_PARITY] checks=", harness.checks, " failures=", harness.failures)
	var exit_code := 0 if harness.failures.is_empty() else 1
	harness = null
	await process_frame
	quit(exit_code)
