extends SceneTree

const SCENE_PATH := "res://WorldMap_16x9_Test.tscn"

var _checks := 0
var _failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("[ENEMY_WARFARE_SERVICE] FAIL: " + label)


func _run() -> void:
	change_scene_to_file(SCENE_PATH)
	await process_frame
	await process_frame
	var host := current_scene.get_node("ProductionWorldMap")
	var service: RefCounted = host.call("_ensure_enemy_warfare_service")
	_expect(service != null, "Service constructed")
	_expect(host.call("_ensure_enemy_warfare_service") == service, "Service is not duplicated")
	_expect(host.call("_normalize_enemy_pressure_type_mvp", "aggressive", "") == "military", "Legacy aggressive pressure normalized")
	_expect(host.call("_normalize_enemy_pressure_type_mvp", "trade_defensive", "") == "defensive", "Legacy defensive pressure normalized")
	_expect(host.call("_score_enemy_invasion_pair_mvp", "hanseong", "pyeongyang") == 0, "T03 neutral invasion score preserved")
	_expect(not host.call("_is_enemy_invasion_pair_eligible_mvp", "", ""), "Invalid invasion pair rejected")

	var faction_ids: Array[String] = host.call("_get_enemy_faction_ids_for_turn_mvp")
	_expect(not faction_ids.is_empty(), "Enemy factions discovered")
	if not faction_ids.is_empty():
		var faction_id := faction_ids[0]
		_expect(not str(host.call("_get_enemy_faction_personality_profile_id", faction_id)).is_empty(), "Personality profile resolved")
		_expect(not str(host.call("_get_enemy_faction_goal_id", faction_id)).is_empty(), "Strategic goal resolved")
		var picked_city := str(host.call("_pick_enemy_city_for_turn_action", faction_id))
		_expect(not picked_city.is_empty(), "Reinforcement target selected")
		_expect(int(host.call("_score_enemy_reinforcement_city_for_personality", faction_id, picked_city)) >= 0, "Reinforcement target scored")

	var candidates: Array[Dictionary] = host.call("_build_enemy_pressure_plan_candidates_mvp")
	_expect(not candidates.is_empty(), "Pressure-plan candidates built")
	if not candidates.is_empty():
		var candidate := candidates[0]
		_expect(float(candidate.get("score", -INF)) > -INF, "Pressure candidate scored")
		_expect(not str(candidate.get("source_city_id", "")).is_empty(), "Pressure source selected")
		_expect(not str(candidate.get("target_city_id", "")).is_empty(), "Pressure target selected")

	var pairs: Array[Dictionary] = host.call("_get_enemy_invasion_pairs_mvp")
	for pair in pairs:
		_expect(host.call("_is_enemy_invasion_pair_eligible_mvp", str(pair.get("attacker_city_id", "")), str(pair.get("defender_city_id", ""))), "Returned invasion pair remains eligible")

	current_scene.queue_free()
	await process_frame
	await process_frame
	print("[ENEMY_WARFARE_SERVICE] %s: %d checks, %d failures" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	quit(0 if _failures == 0 else 1)
