extends SceneTree
const Harness = preload("res://tests/scripts/support/battle_ally_move_event_harness.gd")
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var harness := Harness.new()
	var golden: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/golden/battle_move_baseline_v0.json"))
	for expected in golden.scenarios:
		if not expected.case in ["M1","M2","M4","M5"]: continue
		var actual: Dictionary = await harness.run_case(self,expected.case)
		if actual.is_empty():
			quit(1)
			return
		for event in actual.events: event.erase("sequence")
		var expected_events: Array = expected.events.duplicate(true)
		for event in expected_events: event.erase("sequence")
		var differences: Array = harness.fingerprint.diff(actual.events,expected_events)
		harness.expect(differences.is_empty(),expected.case+" actual service log vs golden: "+str(differences))
		print("[ALLY_MOVE_EVENT_CASE] ",expected.case," events=",actual.events.size()," differences=",differences)
	print("[BATTLE_ALLY_MOVE_EVENTS] %s: %d checks, %d failures" % ["PASS" if harness.failures.is_empty() else "FAIL",harness.checks,harness.failures.size()])
	quit(0 if harness.failures.is_empty() else 1)
