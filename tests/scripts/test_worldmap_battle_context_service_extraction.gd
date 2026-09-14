extends SceneTree

const SCENE_PATH := "res://WorldMap_16x9_Test.tscn"
const BattleContextServiceScript := preload("res://scripts/worldmap/battle/battle_context_service.gd")

var _checks := 0
var _failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("[BATTLE_CONTEXT_SERVICE] FAIL: " + label)


func _run() -> void:
	change_scene_to_file(SCENE_PATH)
	await process_frame
	await process_frame
	var host := current_scene.get_node("ProductionWorldMap")
	var service: RefCounted = host.call("_ensure_battle_context_service")
	_expect(service != null, "Service constructed")
	_expect(host.call("_ensure_battle_context_service") == service, "Service is not duplicated")
	_expect(not service.has_method("get_node"), "Service does not own scene nodes")
	_expect(not service.has_method("_set_pending_battle_context_mvp"), "Pending lifecycle is not service state")

	var even: Dictionary = host.call("_build_even_troop_allocation_for_heroes", ["a", "b", "c"], 101)
	_expect(int(host.call("_sum_troop_allocation", even)) == 101, "Even allocation preserves total")
	_expect(int(even.get("a", 0)) == 34 and int(even.get("b", 0)) == 34 and int(even.get("c", 0)) == 33, "Even allocation remainder is deterministic")

	var source_city_id := "hanseong"
	var target_city_id := "pyeongyang"
	var source_heroes: Array = host.call("_get_available_player_attack_main_hero_ids", source_city_id)
	_expect(not source_heroes.is_empty(), "Player attack hero candidates discovered")
	if not source_heroes.is_empty():
		var hero_id := str(source_heroes[0])
		var selected_hero_ids: Array[String] = [hero_id]
		var hero_entry: Dictionary = host.call("_get_hero_entry", hero_id)
		var command_limit := int(host.call("_get_hero_command_limit_for_city_mvp", hero_entry, source_city_id))
		_expect(command_limit > 0, "Command limit resolved")
		var command_allocation: Dictionary = host.call("_build_command_limit_troop_allocation_for_heroes", [hero_id], command_limit + 500, source_city_id)
		_expect(int(command_allocation.get(hero_id, 0)) == command_limit, "Command allocation clamps to rank limit")
		var allocation := {hero_id: mini(120, command_limit)}
		var roster: Dictionary = host.call("_build_player_attack_selected_roster_for_battle_context", source_city_id, selected_hero_ids, allocation, {})
		_expect(roster.get("hero_ids", []) == [hero_id], "Selected roster preserves hero selection")
		var roster_heroes: Array = roster.get("heroes", [])
		_expect(not roster_heroes.is_empty() and int((roster_heroes[0] as Dictionary).get("allocated_troops", 0)) == int(allocation[hero_id]), "Roster preserves troop allocation")
		var attack_context: Dictionary = host.call("_build_player_attack_battle_context", source_city_id, target_city_id, "manual", selected_hero_ids, allocation, {"gold": 10, "food": 8, "salt": 2, "food_type": "rice"})
		_expect(str(attack_context.get("source", "")) == "player_attack", "Player attack context source preserved")
		_expect(attack_context.get("attacker_hero_ids", []) == [hero_id], "Player attack context roster preserved")
		_expect(int((attack_context.get("attacker_troop_allocation", {}) as Dictionary).get(hero_id, 0)) == int(allocation[hero_id]), "Player attack context allocation preserved")

	var invasion_event := {"type": "defense", "attacker_city_id": target_city_id, "defender_city_id": source_city_id, "turn_number": 1}
	var validation: Dictionary = host.call("_validate_pending_invasion_event_for_battle_context", invasion_event)
	_expect(bool(validation.get("ok", false)), "Enemy invasion input validates")
	var defense_context: Dictionary = host.call("_build_battle_context_from_pending_invasion", invasion_event, "manual")
	_expect(str(defense_context.get("source", "")) == "enemy_invasion", "Enemy invasion context source preserved")
	_expect(not (defense_context.get("attacker_hero_ids", []) as Array).is_empty(), "Enemy invasion attacker roster built")
	_expect(int(defense_context.get("attacker_total_allocated_troops", -1)) == int(host.call("_sum_troop_allocation", defense_context.get("attacker_troop_allocation", {}))), "Enemy invasion allocation total preserved")

	var reinforcement_ids: Array[String] = host.call("_get_reinforcement_candidate_city_ids_for_battle_context", source_city_id)
	var unique_reinforcement_ids := {}
	for city_id in reinforcement_ids:
		unique_reinforcement_ids[city_id] = true
	_expect(not reinforcement_ids.has(source_city_id), "Reinforcement search excludes source")
	_expect(unique_reinforcement_ids.size() == reinforcement_ids.size(), "Reinforcement candidates are unique")

	var synthetic_service := BattleContextServiceScript.new()
	synthetic_service.configure(Callable(self, "_synthetic_query"), {})
	var modified: Dictionary = synthetic_service._apply_domestic_battle_tech_modifier_to_hero_data_mvp({"unit_type": "infantry", "attack": 100, "defense": 100}, "test_city")
	_expect(int(modified.get("attack", 0)) == 110 and int(modified.get("defense", 0)) == 120, "Domestic battle tech modifier applied")

	host.call("_set_pending_battle_context_mvp", {"source": "m3_lifecycle_probe"})
	_expect(str((host.call("_get_pending_battle_context_mvp") as Dictionary).get("source", "")) == "m3_lifecycle_probe", "Pending context remains in coordinator store")
	host.call("_clear_pending_battle_context_mvp")
	_expect((host.call("_get_pending_battle_context_mvp") as Dictionary).is_empty(), "Pending context coordinator clear preserved")

	current_scene.queue_free()
	await process_frame
	await process_frame
	print("[BATTLE_CONTEXT_SERVICE] %s: %d checks, %d failures" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	quit(0 if _failures == 0 else 1)


func _synthetic_query(query_id: String, _args: Array) -> Variant:
	match query_id:
		"is_city_owned_by_player": return true
		"player_battle_tech_modifier":
			return {"global_attack_pct": 0.10, "global_defense_pct": 0.20}
		"has_domestic_battle_modifier_data": return true
	return null
