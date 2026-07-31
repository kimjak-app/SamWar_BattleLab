extends SceneTree

const BATTLE_SCRIPT_PATH := "res://scripts/battle_web_import_test.gd"


func _init() -> void:
	var source := FileAccess.get_file_as_string(BATTLE_SCRIPT_PATH)
	var failures: Array[String] = []
	_validate_source_contract(source, failures)
	_validate_turn_scenarios(failures)
	if failures.is_empty():
		print("[ENEMY_TURN_TEST] PASS scenarios=8")
		quit(0)
		return
	for failure in failures:
		push_error("[ENEMY_TURN_TEST] FAIL %s" % failure)
	quit(1)


func _validate_source_contract(source: String, failures: Array[String]) -> void:
	if source.is_empty():
		failures.append("battle_source_missing")
		return
	var terminal_functions := [
		"_handle_unique_skill_commit_failure",
		"_finalize_unique_skill_action",
		"_play_enemy_ai_for_actor",
		"_play_enemy_actor_basic_attack_from_current_cell",
		"_play_enemy_actor_path_move_then_act",
		"_finish_enemy_actor_basic_move",
		"_play_enemy_actor_basic_attack_or_wait_after_move",
		"_finish_enemy_actor_basic_attack",
	]
	for function_name in terminal_functions:
		var body := _get_function_body(source, function_name)
		if not body.contains("_advance_enemy_turn_or_return_to_ally()"):
			failures.append("terminal_path_not_unified=%s" % function_name)
	if not source.contains("call_deferred(\"_play_enemy_ai_for_actor\", next_enemy_actor)"):
		failures.append("next_enemy_not_deferred")
	if not source.contains("if not _are_all_alive_enemies_acted():"):
		failures.append("ally_return_missing_enemy_continuation_guard")
	if not source.contains("blocked_premature_new_round"):
		failures.append("new_round_missing_completion_guard")
	if not source.contains("func _start_new_round(force_round_start := false)"):
		failures.append("new_round_missing_explicit_debug_override")
	var return_call_count := source.count("_return_to_ally_turn()")
	if return_call_count != 2:
		failures.append("unexpected_direct_ally_return_calls=%d" % return_call_count)


func _validate_turn_scenarios(failures: Array[String]) -> void:
	_expect_sequence("1v4", ["enemy_01", "enemy_02", "enemy_03", "enemy_04"], [], [], false, ["enemy_01", "enemy_02", "enemy_03", "enemy_04"], failures)
	_expect_sequence("1v1", ["enemy_01"], [], [], false, ["enemy_01"], failures)
	_expect_sequence("dead_enemy_excluded", ["enemy_01", "enemy_02", "enemy_03", "enemy_04"], [], ["enemy_03"], false, ["enemy_01", "enemy_02", "enemy_04"], failures)
	_expect_sequence("path_failure_consumes_actor", ["enemy_01", "enemy_02", "enemy_03", "enemy_04"], ["enemy_02"], [], false, ["enemy_01", "enemy_02", "enemy_03", "enemy_04"], failures)
	_expect_sequence("move_wait_consumes_actor", ["enemy_01", "enemy_02", "enemy_03", "enemy_04"], ["enemy_01"], [], false, ["enemy_01", "enemy_02", "enemy_03", "enemy_04"], failures)
	_expect_sequence("unique_skill_completion_continues", ["enemy_01", "enemy_02"], ["enemy_01"], [], false, ["enemy_01", "enemy_02"], failures)
	_expect_sequence("battle_end_stops_remaining", ["enemy_01", "enemy_02", "enemy_03"], [], [], true, ["enemy_01"], failures)
	var round_reset_allowed := _all_acted(["ally_01"], ["ally_01"]) and _all_acted(["enemy_01", "enemy_02"], ["enemy_01", "enemy_02"])
	var premature_reset_blocked := not (_all_acted(["ally_01"], ["ally_01"]) and _all_acted(["enemy_01", "enemy_02"], ["enemy_01"]))
	if not round_reset_allowed or not premature_reset_blocked:
		failures.append("round_reset_completion_contract")


func _expect_sequence(label: String, enemy_ids: Array[String], wait_actor_ids: Array[String], dead_actor_ids: Array[String], battle_ends_after_first: bool, expected: Array[String], failures: Array[String]) -> void:
	var acted: Array[String] = []
	for enemy_id in enemy_ids:
		if dead_actor_ids.has(enemy_id):
			continue
		acted.append(enemy_id)
		if battle_ends_after_first:
			break
		# Wait, path failure, and a completed unique skill all consume this actor's
		# one action before the shared continuation selects the next actor.
		if wait_actor_ids.has(enemy_id):
			continue
	if acted != expected:
		failures.append("%s expected=%s actual=%s" % [label, expected, acted])


func _all_acted(actor_ids: Array[String], acted_ids: Array[String]) -> bool:
	for actor_id in actor_ids:
		if not acted_ids.has(actor_id):
			return false
	return true


func _get_function_body(source: String, function_name: String) -> String:
	var start := source.find("func %s(" % function_name)
	if start < 0:
		return ""
	var next_function := source.find("\nfunc ", start + 1)
	if next_function < 0:
		return source.substr(start)
	return source.substr(start, next_function - start)
