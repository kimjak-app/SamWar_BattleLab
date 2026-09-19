extends SceneTree

const WORLDMAP_SCENE_PATH := "res://WorldMap.tscn"
const BATTLE_SCENE_PATH := "res://scenes/battle/Battle_Main.tscn"
const RESULT_META_KEY := "samwar_worldmap_battle_result"

var _checks := 0
var _failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var change_result := change_scene_to_file(WORLDMAP_SCENE_PATH)
	_expect(change_result == OK, "WorldMap scene transition starts")
	await process_frame
	await process_frame
	var worldmap := current_scene
	_expect(worldmap != null and worldmap.scene_file_path == WORLDMAP_SCENE_PATH, "WorldMap scene loaded")
	if worldmap == null:
		_finish()
		return

	var source_city_id := "hanseong"
	var target_city_id := "pyeongyang"
	var player_faction_id := str(worldmap.call("_get_current_player_faction_id"))
	var target_owner_before := str(worldmap.call("_get_city_owner_id_for_battle_context", target_city_id))
	_expect(not player_faction_id.is_empty(), "Player faction resolved")
	_expect(target_owner_before != player_faction_id, "Target city begins enemy-owned")

	var hero_ids: Array = worldmap.call("_get_available_player_attack_main_hero_ids", source_city_id)
	_expect(not hero_ids.is_empty(), "Attack hero available in source city")
	if hero_ids.is_empty():
		_finish()
		return
	var hero_id := str(hero_ids[0])
	var hero_entry: Dictionary = worldmap.call("_get_hero_entry", hero_id)
	var command_limit := int(worldmap.call("_get_hero_command_limit_for_city_mvp", hero_entry, source_city_id))
	var source_troops_before := int(worldmap.call("_get_city_troops_for_battle_context", source_city_id))
	_expect(command_limit > 0 and source_troops_before > 1, "Source has command capacity and spare garrison")
	if command_limit <= 0 or source_troops_before <= 1:
		_finish()
		return

	var deploy_troops := 1
	var minimum_supply: Dictionary = worldmap.call("_calculate_player_attack_supply_cost", deploy_troops)
	var food_needed := maxi(0, int(minimum_supply.get("food", 0)))
	var gold_needed := maxi(0, int(minimum_supply.get("gold", 0)))
	var salt_needed := maxi(0, int(minimum_supply.get("salt", 0)))
	var food_type := _pick_affordable_food_type(worldmap, source_city_id, food_needed)
	_expect(not food_type.is_empty(), "Source has an affordable food type")
	_expect(int(worldmap.call("_get_city_supply_resource_amount", source_city_id, "gold")) >= gold_needed, "Source has minimum gold")
	if food_type.is_empty():
		_finish()
		return

	var supply_cost := {
		"food_type": food_type,
		"food": food_needed,
		"gold": gold_needed,
		"salt": salt_needed,
		food_type: food_needed,
	}
	var deployment := {
		"deployment_type": "attack",
		"mode": "manual",
		"source_city_id": source_city_id,
		"target_city_id": target_city_id,
		"selected_hero_ids": [hero_id],
		"attacker_troop_allocation": {hero_id: deploy_troops},
		"attacker_food_type": food_type,
		"attacker_food_amount": food_needed,
		"attacker_carried_gold": gold_needed,
		"attacker_salt_amount": salt_needed,
		"supply_cost": supply_cost,
	}

	worldmap.call("_confirm_player_attack_deployment", deployment)
	await process_frame
	_expect(bool(worldmap.get("_worldmap_battle_entry_handoff_in_progress")), "Real player attack enters handoff")
	var skip_event := InputEventKey.new()
	skip_event.pressed = true
	skip_event.keycode = KEY_ENTER
	worldmap.call("_input", skip_event)
	await process_frame
	await process_frame

	var battle := current_scene
	_expect(battle != null and battle.scene_file_path == BATTLE_SCENE_PATH, "Real player attack enters canonical Battle_Main")
	if battle == null or battle.scene_file_path != BATTLE_SCENE_PATH:
		_finish()
		return

	var context: Dictionary = battle.get("worldmap_battle_context")
	var transaction_id := str(context.get("transaction_id", ""))
	_expect(not transaction_id.is_empty(), "Battle_Main received real transaction id")
	_expect(str(context.get("attacker_city_id", "")) == source_city_id and str(context.get("defender_city_id", "")) == target_city_id, "Battle_Main received source/target cities")
	_expect((context.get("attacker_hero_ids", []) as Array).has(hero_id), "Battle_Main received selected attacker hero")
	_expect(int((context.get("attacker_troop_allocation", {}) as Dictionary).get(hero_id, 0)) == deploy_troops, "Battle_Main received selected troop allocation")

	var deployed_enemies: Array = battle.call("_get_deployed_unit_states_for_side", "enemy")
	_expect(not deployed_enemies.is_empty(), "Battle_Main has deployed defenders")
	for enemy_unit in deployed_enemies:
		enemy_unit.set("current_hp", 0)
		enemy_unit.set("current_troops", 0)
	_expect(str(battle.call("_get_battle_result_state")) == "victory", "Enemy elimination resolves victory")

	var result_payload: Dictionary = battle.call("_build_worldmap_battle_result_payload", "victory")
	var result_id := str(result_payload.get("result_id", ""))
	var expected_occupation_troops := maxi(0, int(result_payload.get("attacker_healthy_survivors", 0)))
	_expect(str(result_payload.get("transaction_id", "")) == transaction_id, "Result preserves transaction identity")
	_expect(str(result_payload.get("winner", "")) == "attacker", "Player attack victory returns attacker winner")
	_expect(not result_id.is_empty(), "Result id created")
	_expect(expected_occupation_troops > 0, "Victory has surviving occupation troops")

	battle.call("_return_to_worldmap_with_result")
	await process_frame
	await process_frame
	await process_frame

	var returned_worldmap := current_scene
	_expect(returned_worldmap != null and returned_worldmap.scene_file_path == WORLDMAP_SCENE_PATH, "Battle_Main returns to WorldMap")
	if returned_worldmap == null or returned_worldmap.scene_file_path != WORLDMAP_SCENE_PATH:
		_finish()
		return

	_expect(not Engine.has_meta(RESULT_META_KEY), "WorldMap consumes battle result meta exactly once")
	_expect(str(returned_worldmap.call("_get_city_owner_id_for_battle_context", target_city_id)) == player_faction_id, "Victory transfers target ownership to player")
	_expect(int(returned_worldmap.call("_get_city_troops_for_battle_context", target_city_id)) == expected_occupation_troops, "Target garrison equals surviving attacker troops")
	_expect(int(returned_worldmap.call("_get_city_troops_for_battle_context", source_city_id)) == int(context.get("attacker_source_city_troops_after", source_troops_before - deploy_troops)), "Source garrison preserves departure deduction")
	_expect(str(returned_worldmap.call("_get_hero_city_id_for_battle_context", hero_id)) == target_city_id, "Surviving attacker hero moves to occupied target")
	_expect((returned_worldmap.call("_get_pending_battle_context_mvp") as Dictionary).is_empty(), "Pending battle context clears after settlement")
	var player_state: Dictionary = returned_worldmap.get("_player_state")
	var applied_result_ids: Array = player_state.get("applied_battle_result_ids", []) if player_state.get("applied_battle_result_ids", []) is Array else []
	_expect(applied_result_ids.has(result_id), "Result id is recorded against duplicate settlement")

	_finish()


func _pick_affordable_food_type(worldmap: Node, city_id: String, required_food: int) -> String:
	for food_type in ["rice", "barley", "seafood"]:
		if int(worldmap.call("_get_city_supply_resource_amount", city_id, food_type)) >= required_food:
			return food_type
	return ""


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if condition:
		print("[BATTLE_MAIN_ROUNDTRIP_PASS] %s" % label)
		return
	_failures += 1
	push_error("[BATTLE_MAIN_ROUNDTRIP_FAIL] %s" % label)


func _finish() -> void:
	if Engine.has_meta(RESULT_META_KEY):
		Engine.remove_meta(RESULT_META_KEY)
	print("[BATTLE_MAIN_ROUNDTRIP] %s: %d checks, %d failures" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	quit(0 if _failures == 0 else 1)
