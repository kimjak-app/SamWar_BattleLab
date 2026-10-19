extends SceneTree
const Harness = preload("res://tests/scripts/support/battle_move_oracle_harness.gd")
const GOLDEN := "res://tests/golden/battle_move_baseline_v0.json"

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var harness := Harness.new()
	var cases := []
	for label in ["M1","M2","M3_occupied","M3_range","M3_no_path","M4","M5"]:
		var first: Dictionary = await harness.run_case(self,label)
		if first.is_empty() or not harness.failures.is_empty():
			printerr("[BATTLE_MOVE_ORACLE] STOP: actual controller case failed: ",label)
			quit(1)
			return
		var second: Dictionary = await harness.run_case(self,label)
		var differences: Array = harness.fingerprint.diff([first],[second])
		harness.expect(differences.is_empty(),label + " deterministic twice: " + str(differences))
		if not harness.failures.is_empty():
			printerr("[BATTLE_MOVE_ORACLE] STOP: repeat mismatch: ",label)
			quit(1)
			return
		cases.append(first)
		print("[MOVE_ORACLE_CASE] ",label," PASS: runs=2 deterministic=true checkpoints=",first.checkpoints.size())
	var captured := {"schema_version":0,"base_commit":"62f5b726260aa3e6134225e7e903b1098792f23a","scenarios":cases}
	var updating := OS.get_cmdline_user_args().has("--update-golden")
	if updating:
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://tests/golden"))
		var output := FileAccess.open(GOLDEN,FileAccess.WRITE)
		harness.expect(output != null,"golden writable")
		if output != null:
			output.store_string(JSON.stringify(captured,"\t",true) + "\n")
			output.close()
			print("[MOVE_ORACLE_GOLDEN] UPDATED by explicit --update-golden")
	else:
		harness.expect(FileAccess.file_exists(GOLDEN),"golden exists; generation requires --update-golden")
		if FileAccess.file_exists(GOLDEN):
			var saved: Variant = JSON.parse_string(FileAccess.get_file_as_string(GOLDEN))
			var differences: Array = harness.fingerprint.diff([captured],[saved])
			harness.expect(differences.is_empty(),"golden parity: " + str(differences))
			if differences.is_empty(): print("[MOVE_ORACLE_GOLDEN] PASS: unchanged baseline")
	print("[BATTLE_MOVE_ORACLE] %s: %d checks, %d failures; scenarios=5; cases=7; runs=14" % ["PASS" if harness.failures.is_empty() else "FAIL",harness.checks,harness.failures.size()])
	quit(0 if harness.failures.is_empty() else 1)
