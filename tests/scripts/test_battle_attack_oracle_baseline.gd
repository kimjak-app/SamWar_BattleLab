extends SceneTree
const GOLDEN := "res://tests/golden/battle_attack_baseline_v0.json"
const CASES := ["A1","A2_side","A2_back","A3","A4","A5","A6","A6b","A7_range","A7_acted","A7a","A7b","A8","A9","A10","A11"]

func case_labels() -> Array:
	return CASES

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var harness = load("res://tests/scripts/support/battle_attack_oracle_harness.gd").new()
	var scenarios := []
	var args := OS.get_cmdline_user_args()
	var labels: Array = case_labels()
	for arg in args:
		if arg.begins_with("--case="): labels=[arg.trim_prefix("--case=")]
	for label in labels:
		harness.expect(CASES.has(label),"known case "+str(label))
		if not harness.failures.is_empty():
			quit(1)
			return
		var first: Dictionary = await harness.run_case(self,label)
		print("[ATTACK_CASE_CAPTURE] ",JSON.stringify(first))
		if not harness.failures.is_empty():
			quit(1)
			return
		var second: Dictionary = await harness.run_case(self,label)
		var differences: Array = harness.fingerprint.diff([first],[second])
		harness.expect(differences.is_empty(),label+" deterministic twice "+str(differences))
		if not harness.failures.is_empty():
			quit(1)
			return
		scenarios.append(first)
		print("[ATTACK_ORACLE_CASE] ",label," PASS runs=2")
	var captured := {"schema_version":0,"base_commit":"2ba04645f7736fbee3a0eecd8a9ef0a38ef13b02","scenarios":scenarios}
	if args.has("--update-golden"):
		harness.expect(labels.size()==CASES.size(),"only complete passing suite can write golden")
		if harness.failures.is_empty():
			var file := FileAccess.open(GOLDEN,FileAccess.WRITE)
			file.store_string(JSON.stringify(captured,"\t",true)+"\n")
	else:
		harness.expect(FileAccess.file_exists(GOLDEN),"golden exists")
		if FileAccess.file_exists(GOLDEN):
			var expected = JSON.parse_string(FileAccess.get_file_as_string(GOLDEN))
			if labels.size()!=CASES.size():
				expected.scenarios=expected.scenarios.filter(func(item): return labels.has(item.case))
			harness.expect(harness.fingerprint.diff(captured,expected).is_empty(),"golden parity")
	print("[ATTACK_ORACLE] checks=",harness.checks," failures=",harness.failures)
	var exit_code := 0 if harness.failures.is_empty() else 1
	harness=null
	await process_frame
	quit(exit_code)
