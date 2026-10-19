extends SceneTree
func _initialize() -> void:
	run.call_deferred()
func run() -> void:
	var harness=load("res://tests/scripts/support/battle3d_engine_attack_harness.gd").new()
	for label in ["A6b", "A9", "A10"]:
		await harness.run_case(self,label)
		if not harness.failures.is_empty(): break
	print("M2_ATTACK_SHARD_3 checks=",harness.checks," failures=",harness.failures)
	quit(0 if harness.failures.is_empty() else 1)
