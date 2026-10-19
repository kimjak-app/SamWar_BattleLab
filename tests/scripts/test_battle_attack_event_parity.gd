extends SceneTree
const GOLDEN := "res://tests/golden/battle_attack_baseline_v0.json"
func _initialize() -> void:
	_run.call_deferred()
func point(scenario: Dictionary, stage: String) -> Dictionary:
	for item in scenario.checkpoints:
		if item.stage==stage: return item
	return {}
func _run() -> void:
	var harness = load("res://tests/scripts/support/battle_attack_event_harness.gd").new()
	var golden: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(GOLDEN))
	var args := OS.get_cmdline_user_args()
	var selected_case := ""
	for arg in args:
		if arg.begins_with("--case="): selected_case=arg.trim_prefix("--case=")
	if not selected_case.is_empty():
		var known := false
		for item in golden.scenarios:
			if item.case==selected_case: known=true
		harness.expect(known,"known event case "+selected_case)
		if not known:
			quit(1)
			return
	var front_damage: int = point(golden.scenarios[0],"start").units[5].current_hp-point(golden.scenarios[0],"requested").units[5].current_hp
	for expected in golden.scenarios:
		if not selected_case.is_empty() and expected.case!=selected_case: continue
		harness.events_at.clear()
		var actual: Dictionary = await harness.run_case(self,expected.case)
		harness.expect(harness.fingerprint.diff(actual,expected).is_empty(),expected.case+" unchanged authoritative golden")
		harness.expect(harness.events_at.start.is_empty() and harness.events_at.attack_select.is_empty(),expected.case+" selection emits no action event")
		var requested := point(expected,"requested")
		var finished := point(expected,"finished_before_enemy")
		if finished.is_empty():
			for stage in harness.events_at:
				harness.expect(harness.events_at[stage].is_empty(),expected.case+" rejected/cancelled has no event at "+stage)
		else:
			var target_index := 1 if expected.case=="A7a" else 5
			var before: Dictionary = point(expected,"start").units[target_index]
			var after: Dictionary = requested.units[target_index]
			var damage: int = before.current_hp-after.current_hp
			var event := {"schema_version":0,"sequence":0,"kind":"attack_resolved","attacker_id":requested.units[0].unit_id,"target_id":before.unit_id,"angle_type":expected.angle_type,"damage_requested":front_damage if expected.case=="A9" else damage,"damage_applied":damage,"troops_before":before.current_troops,"troops_after":after.current_troops,"target_defending":before.is_defending,"killed":after.current_hp<=0 or after.current_troops<=0}
			harness.expect(harness.fingerprint.diff(harness.events_at.requested,[event]).is_empty(),expected.case+" request event values and count")
			harness.expect(harness.fingerprint.diff(harness.events_at.animating,[event]).is_empty(),expected.case+" no completion before tween finishes")
			if expected.case=="A10": harness.expect(harness.fingerprint.diff(harness.events_at.duplicate_cancel_input,[event]).is_empty(),"duplicate input emits no duplicate event")
			var expected_events := [event,{"schema_version":0,"sequence":1,"kind":"action_completed","unit_id":requested.units[0].unit_id}]
			if expected.case=="A9": expected_events.append({"schema_version":0,"sequence":2,"kind":"unit_defeated","unit_id":before.unit_id})
			for stage in ["finished_before_enemy","finished_after_enemy_start","after_enemy_callback","after_enemy_slot"]:
				harness.expect(harness.fingerprint.diff(harness.events_at[stage],expected_events).is_empty(),expected.case+" completion/death exactly once before enemy: "+stage)
		print("[ATTACK_EVENT_CASE] ",expected.case," failures=",harness.failures.size())
		if not harness.failures.is_empty(): break
	print("[ATTACK_EVENTS] checks=",harness.checks," failures=",harness.failures)
	var code := 0 if harness.failures.is_empty() else 1
	harness=null
	await process_frame
	quit(code)
