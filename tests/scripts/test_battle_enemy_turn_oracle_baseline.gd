extends SceneTree
const GOLDEN := "res://tests/golden/battle_enemy_turn_baseline_v0.json"
const BASE_COMMIT := "a19a08d4a370b68e50ee5a8cf24513d6689b6024"

func case_labels() -> Array:
	return load("res://tests/scripts/support/battle_enemy_turn_oracle_harness.gd").CASES

func _initialize() -> void:
	_run.call_deferred()

func _golden_view(result: Dictionary) -> Dictionary:
	# Underscore keys are observations of the recording code, never golden.
	var view := {}
	for key in result:
		if not String(key).begins_with("_"): view[key] = result[key]
	return view

func _run() -> void:
	var harness = load("res://tests/scripts/support/battle_enemy_turn_oracle_harness.gd").new()
	var all_cases: Array = harness.CASES
	var args := OS.get_cmdline_user_args()
	var labels: Array = case_labels()
	for arg in args:
		if arg.begins_with("--case="): labels = [arg.trim_prefix("--case=")]
	var scenarios := []
	for label in labels:
		harness.expect(all_cases.has(label), "known case " + str(label))
		if not harness.failures.is_empty(): break
		var first: Dictionary = _golden_view(await harness.run_case(self, label))
		var second: Dictionary = _golden_view(await harness.run_case(self, label))
		var differences: Array = harness.fingerprint.diff([first], [second])
		harness.expect(differences.is_empty(), label + " deterministic twice " + str(differences))
		scenarios.append(first)
		print("[ENEMY_TURN_ORACLE_CASE] ", label, " runs=2 failures=", harness.failures.size())
		if not harness.failures.is_empty(): break
	var captured := {"schema_version":0, "base_commit":BASE_COMMIT, "scenarios":scenarios}
	if args.has("--update-golden"):
		harness.expect(labels.size() == all_cases.size(), "only complete passing suite can write golden")
		if harness.failures.is_empty():
			var file := FileAccess.open(GOLDEN, FileAccess.WRITE)
			file.store_string(JSON.stringify(captured, "\t", true) + "\n")
			file.close()
			print("[ENEMY_TURN_ORACLE] golden written")
	elif harness.failures.is_empty():
		harness.expect(FileAccess.file_exists(GOLDEN), "golden exists")
		if FileAccess.file_exists(GOLDEN):
			var expected = JSON.parse_string(FileAccess.get_file_as_string(GOLDEN))
			harness.expect(expected.base_commit == BASE_COMMIT, "golden generated on BASE")
			expected.scenarios = expected.scenarios.filter(func(item): return labels.has(item.case))
			harness.expect(expected.scenarios.size() == labels.size(), "golden covers selected cases")
			var golden_diff: Array = harness.fingerprint.diff(captured, expected)
			harness.expect(golden_diff.is_empty(), "golden parity " + str(golden_diff))
	print("[ENEMY_TURN_ORACLE] checks=", harness.checks, " failures=", harness.failures)
	var exit_code := 0 if harness.failures.is_empty() else 1
	harness = null
	await process_frame
	quit(exit_code)
