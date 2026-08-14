extends SceneTree


const BATTLE_SCENE_PATH := "res://Battle_Land.tscn"
const PHASE_ALLY_TURN := "ally_turn"
const PHASE_ENEMY_TURN := "enemy_turn"

var failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	await _test_one_vs_many_continues_enemy_turn()
	if failed:
		return
	await _test_many_vs_one_returns_next_unacted_ally()
	if failed:
		return
	await _test_one_vs_one_completes_once()
	if failed:
		return
	print("[ONE_SIDE_EXHAUSTION_TURN] PASS")
	quit(0)


func _test_one_vs_many_continues_enemy_turn() -> void:
	var battle := await _spawn_battle(["yi_sun_sin"], ["gwanggaeto", "uija_wang", "kim_chun_chu", "jang_bo_go", "heukchi_sangji"], "turn-order-1v5")
	_deploy_context_reinforcements(battle, "enemy")
	var allies: Array = battle.call("_get_alive_ally_units")
	var enemies: Array = battle.call("_get_alive_enemy_units")
	_expect(allies.size() == 1 and enemies.size() == 5, "1v5 fixture has one ally and five enemies")
	_expect(battle.get("battle_supply_runtime") != null, "1v5 fixture configures BattleSupplyRuntime")
	var preview_before = battle.call("_get_production_roster_next_enemy_actor")
	var preview_repeat = battle.call("_get_production_roster_next_enemy_actor")
	_expect(preview_before == enemies[0] and preview_repeat == preview_before, "1v5 preview matches the first live enemy selector result without mutation")
	battle.call("_mark_ally_unit_acted", allies[0])
	battle.call("_mark_enemy_unit_acted", enemies[0])
	_expect(battle.call("_get_production_roster_next_enemy_actor") == enemies[1], "1v5 preview skips the enemy actor already consumed by turn order")
	battle.call("_return_to_ally_turn")
	_expect(str(battle.get("current_phase")) == PHASE_ENEMY_TURN, "1v5 exhaustion stays in enemy turn")
	_expect(battle.get("active_unit_state") == null, "1v5 clears acted ally selection")
	var current_enemy = battle.get("current_enemy_ai_actor_state")
	_expect(current_enemy != null and not bool(current_enemy.has_acted), "1v5 schedules exactly the next unacted enemy")
	await _cleanup_battle(battle)


func _test_many_vs_one_returns_next_unacted_ally() -> void:
	var battle := await _spawn_battle(["yi_sun_sin", "jeong_do_jeon", "kwon_yul", "kim_yu_sin", "eulji_mundeok"], ["gwanggaeto"], "turn-order-5v1")
	_deploy_context_reinforcements(battle, "ally")
	var allies: Array = battle.call("_get_alive_ally_units")
	var enemies: Array = battle.call("_get_alive_enemy_units")
	_expect(allies.size() == 5 and enemies.size() == 1, "5v1 fixture has five allies and one enemy")
	battle.call("_mark_ally_unit_acted", allies[0])
	battle.call("_mark_enemy_unit_acted", enemies[0])
	battle.call("_return_to_ally_turn")
	var selected_ally = battle.get("active_unit_state")
	_expect(str(battle.get("current_phase")) == PHASE_ALLY_TURN, "5v1 returns player control")
	_expect(selected_ally != null and selected_ally != allies[0] and not bool(selected_ally.has_acted), "5v1 selects next unacted ally")
	await _cleanup_battle(battle)


func _test_one_vs_one_completes_once() -> void:
	var battle := await _spawn_battle(["yi_sun_sin"], ["gwanggaeto"], "turn-order-1v1")
	var allies: Array = battle.call("_get_alive_ally_units")
	var enemies: Array = battle.call("_get_alive_enemy_units")
	var round_before := int(battle.get("battle_round"))
	battle.call("_mark_ally_unit_acted", allies[0])
	battle.call("_mark_enemy_unit_acted", enemies[0])
	battle.call("_return_to_ally_turn")
	_expect(int(battle.get("battle_round")) == round_before + 1, "1v1 increments one completed round")
	_expect(str(battle.get("current_phase")) == PHASE_ALLY_TURN, "1v1 opens next round for ally")
	await _cleanup_battle(battle)


func _spawn_battle(ally_ids: Array[String], enemy_ids: Array[String], transaction_id: String) -> Node:
	Engine.set_meta("samwar_worldmap_battle_context", _build_context(ally_ids, enemy_ids, transaction_id))
	var scene := load(BATTLE_SCENE_PATH) as PackedScene
	_expect(scene != null, "Battle_Land scene loads")
	if scene == null:
		return null
	var battle := scene.instantiate()
	root.add_child(battle)
	await process_frame
	return battle


func _cleanup_battle(battle: Node) -> void:
	if battle != null and is_instance_valid(battle):
		battle.queue_free()
	await process_frame


func _deploy_context_reinforcements(battle: Node, side: String) -> void:
	var property_names := [
		"%s_reinforce_01_unit_state" % side,
		"%s_reinforce_02_unit_state" % side,
	]
	for property_name in property_names:
		var unit_state = battle.get(property_name)
		if unit_state != null:
			battle.call("_set_unit_deployed", unit_state, true)


func _build_context(ally_ids: Array[String], enemy_ids: Array[String], transaction_id: String) -> Dictionary:
	return {
		"type": "attack", "source": "player_attack", "mode": "manual", "battle_mode": "invasion",
		"transaction_id": transaction_id, "scenario_id": "korea_mvp", "player_faction_id": "player",
		"attacker_city_id": "hanseong", "defender_city_id": "pyeongyang",
		"attacker_city_name": "한성", "defender_city_name": "평양",
		"attacker_faction_display_name": "조선", "target_city_display_name": "평양",
		"attacker_owner": "player", "defender_owner": "goguryeo",
		"attacker_troops": 300, "defender_troops": 300,
		"attacker_initial_healthy_troops": 300, "defender_initial_healthy_troops": 300,
		"attacker_hero_ids": ally_ids, "defender_hero_ids": enemy_ids,
		"attacker_general_ids": ally_ids, "defender_general_ids": enemy_ids,
		"attacker_troop_allocation": _allocation(ally_ids), "defender_troop_allocation": _allocation(enemy_ids),
		"attacker_heroes": _heroes(ally_ids), "defender_heroes": _heroes(enemy_ids),
		"attacker_carried_gold": 80, "attacker_food_type": "rice", "attacker_food_amount": 20, "attacker_salt_amount": 2,
		"defender_food_type": "barley", "defender_food_amount": 20, "defender_salt_amount": 2,
		"battle_max_turns": 30, "current_battle_turn": 1,
	}


func _allocation(hero_ids: Array[String]) -> Dictionary:
	var allocation := {}
	for hero_id in hero_ids:
		allocation[hero_id] = 60
	return allocation


func _heroes(hero_ids: Array[String]) -> Array[Dictionary]:
	var heroes: Array[Dictionary] = []
	for hero_id in hero_ids:
		heroes.append({"hero_id": hero_id, "display_name": hero_id, "troops": 60, "allocated_troops": 60, "initial_allocated_troops": 60})
	return heroes


func _expect(condition: bool, label: String) -> void:
	if condition:
		print("[ONE_SIDE_EXHAUSTION_TURN_PASS] %s" % label)
		return
	failed = true
	push_error("[ONE_SIDE_EXHAUSTION_TURN_FAIL] %s" % label)
	quit(1)
