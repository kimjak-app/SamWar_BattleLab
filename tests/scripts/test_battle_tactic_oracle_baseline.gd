extends SceneTree
# S4-1: tactic scenarios (strategy, unique skill per effect_type, status tick,
# reinforcement) on the new engine == golden captured on the BASE engine with
# the same RNG seed. Units (40 fields), controller (12 values) and the three
# existing logs; the new tactic log is not part of the golden.
const GOLDEN := "res://tests/golden/battle_tactic_baseline_v0.json"
const BASE_COMMIT := "608cb77d0d99e9cbefbfecd9ee0f02eb51b6a296"

func case_labels() -> Array:
	return load("res://tests/scripts/support/battle_tactic_oracle_harness.gd").all_cases()

func _initialize() -> void:
	_run.call_deferred()

func _golden_view(result: Dictionary) -> Dictionary:
	# Underscore keys are observations of the recording code, never golden.
	var view := {}
	for key in result:
		if not String(key).begins_with("_"): view[key] = result[key]
	return view

func _run() -> void:
	var harness = load("res://tests/scripts/support/battle_tactic_oracle_harness.gd").new()
	harness.tag = "[TACTIC_ORACLE]"
	var all_cases: Array = harness.all_cases()
	var args := OS.get_cmdline_user_args()
	var labels: Array = case_labels()
	for arg in args:
		if arg.begins_with("--case="): labels = [arg.trim_prefix("--case=")]
	var repeat := 2 if args.has("--update-golden") or args.has("--twice") else 1
	var scenarios := []
	for label in labels:
		harness.expect(all_cases.has(label), "known case " + str(label))
		if not harness.failures.is_empty(): break
		var t0 := Time.get_ticks_msec()
		var first: Dictionary = _golden_view(await harness.run_case(self, label))
		for i in range(repeat - 1):
			var again: Dictionary = _golden_view(await harness.run_case(self, label))
			var differences: Array = harness.fingerprint.diff([first], [again])
			harness.expect(differences.is_empty(), label + " deterministic twice " + str(differences))
		scenarios.append(first)
		print("[TACTIC_ORACLE_CASE] ", label, " runs=", repeat, " ms=", Time.get_ticks_msec() - t0, " failures=", harness.failures.size())
		if not harness.failures.is_empty(): break
	var captured := {"schema_version":0, "base_commit":BASE_COMMIT, "scenarios":scenarios}
	if args.has("--update-golden"):
		harness.expect(labels.size() == all_cases.size(), "only complete passing suite can write golden")
		if harness.failures.is_empty():
			var file := FileAccess.open(GOLDEN, FileAccess.WRITE)
			file.store_string(JSON.stringify(captured, "\t", true) + "\n")
			file.close()
			print("[TACTIC_ORACLE] golden written")
	elif harness.failures.is_empty():
		harness.expect(FileAccess.file_exists(GOLDEN), "golden exists")
		if FileAccess.file_exists(GOLDEN):
			var expected = JSON.parse_string(FileAccess.get_file_as_string(GOLDEN))
			harness.expect(expected.base_commit == BASE_COMMIT, "golden generated on BASE")
			expected.scenarios = expected.scenarios.filter(func(item): return labels.has(item.case))
			harness.expect(expected.scenarios.size() == labels.size(), "golden covers selected cases")
			var golden_diff: Array = harness.fingerprint.diff(captured, expected)
			harness.expect(golden_diff.is_empty(), "golden parity " + str(golden_diff.slice(0, 20)))
	print("[TACTIC_ORACLE] checks=", harness.checks, " failures=", harness.failures)
	var exit_code := 0 if harness.failures.is_empty() else 1
	harness = null
	await process_frame
	quit(exit_code)
