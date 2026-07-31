extends SceneTree

var _failures: Array[String] = []


func _initialize() -> void:
	Engine.set_meta("samwar_worldmap_battle_context", _build_context())
	var battle := (load("res://Battle_Land.tscn") as PackedScene).instantiate()
	root.add_child(battle)
	await process_frame
	await process_frame
	_validate_multi_enemy_plans(battle)
	_validate_target_replan(battle)
	_validate_directional_attack_contract(battle)
	if _failures.is_empty():
		print("[ENEMY_SURROUND_TEST] same_target_shared PASS")
		print("[ENEMY_SURROUND_TEST] destination_unique PASS")
		print("[ENEMY_SURROUND_TEST] engagement_unique PASS")
		print("[ENEMY_SURROUND_TEST] directional_pressure PASS")
		print("[ENEMY_SURROUND_TEST] blocked_actor_repath PASS")
		print("[ENEMY_SURROUND_TEST] target_replan PASS")
		print("[ENEMY_SURROUND_TEST] cooperative_attack_eligible PASS")
		print("[ENEMY_SURROUND_TEST] PASS scenarios=8")
		quit(0)
		return
	for failure in _failures:
		push_error("[ENEMY_SURROUND_TEST] FAIL %s" % failure)
	quit(1)


func _validate_multi_enemy_plans(battle: Node) -> void:
	var target := battle.get("ally_unit_state") as BattleUnitState
	var enemies: Array[BattleUnitState] = [
		battle.get("enemy_unit_state") as BattleUnitState,
		battle.get("enemy_support_unit_state") as BattleUnitState,
		battle.get("enemy_main_03_unit_state") as BattleUnitState,
		battle.get("enemy_reinforce_01_unit_state") as BattleUnitState,
	]
	_expect(target != null, "target_missing")
	for enemy in enemies:
		_expect(enemy != null, "enemy_missing")
	if not _failures.is_empty():
		return

	# This is a planning validator, so explicitly deploy the fourth context slot
	# instead of waiting for its normal later reinforcement trigger.
	battle.call("_set_unit_deployed", enemies[3], true)
	target.set_grid_cell(Vector2i(8, 5))
	enemies[0].set_grid_cell(Vector2i(13, 5))
	enemies[1].set_grid_cell(Vector2i(13, 2))
	enemies[2].set_grid_cell(Vector2i(13, 8))
	enemies[3].set_grid_cell(Vector2i(15, 5))
	battle.call("_clear_enemy_ai_turn_reservations")
	var first_plan: Dictionary = battle.call("_get_enemy_ai_decision_plan_for_actor", enemies[0], target)
	battle.call("_reserve_enemy_ai_decision_plan_for_actor", enemies[0], first_plan)
	var blocked_actor_plan: Dictionary = battle.call("_get_enemy_ai_decision_plan_for_actor", enemies[1], target)
	_expect(str(blocked_actor_plan.get("action_reason", "WAIT")) != "WAIT", "blocked_actor_waited")
	_expect(blocked_actor_plan.get("destination", enemies[1].grid_cell) != first_plan.get("destination", enemies[0].grid_cell), "blocked_actor_no_alternate_destination")
	battle.call("_clear_enemy_ai_turn_reservations")

	var destinations: Dictionary = {}
	var engagement_cells: Dictionary = {}
	var directions: Dictionary = {}
	for enemy in enemies:
		var plan: Dictionary = battle.call("_get_enemy_ai_decision_plan_for_actor", enemy, target)
		var final_target := plan.get("final_target_state", null) as BattleUnitState
		var destination: Vector2i = plan.get("destination", enemy.grid_cell)
		var final_cell: Vector2i = plan.get("final_cell", destination)
		_expect(final_target == target, "target_not_shared actor=%s" % enemy.unit_id)
		_expect(str(plan.get("action_reason", "WAIT")) != "WAIT", "unexpected_wait actor=%s" % enemy.unit_id)
		_expect(not destinations.has(destination), "destination_duplicate cell=%s" % destination)
		_expect(not engagement_cells.has(final_cell), "engagement_duplicate cell=%s" % final_cell)
		destinations[destination] = enemy.unit_id
		engagement_cells[final_cell] = enemy.unit_id
		directions[_direction_key(final_cell - target.grid_cell)] = true
		battle.call("_reserve_enemy_ai_decision_plan_for_actor", enemy, plan)

	_expect(destinations.size() == enemies.size(), "destination_reservation_size")
	_expect(engagement_cells.size() == enemies.size(), "engagement_reservation_size")
	_expect(directions.size() >= 2, "insufficient_directional_pressure")
	_expect((battle.get("enemy_ai_reserved_destination_cells") as Dictionary).size() == enemies.size(), "destination_reservation_not_retained")
	_expect((battle.get("enemy_ai_reserved_engagement_cells") as Dictionary).size() == enemies.size(), "engagement_reservation_not_retained")

	battle.call("_clear_enemy_ai_turn_reservations")
	_expect((battle.get("enemy_ai_reserved_destination_cells") as Dictionary).is_empty(), "destination_reset")
	_expect((battle.get("enemy_ai_reserved_engagement_cells") as Dictionary).is_empty(), "engagement_reset")


func _validate_target_replan(battle: Node) -> void:
	var target := battle.get("ally_unit_state") as BattleUnitState
	var enemy := battle.get("enemy_unit_state") as BattleUnitState
	if target == null or enemy == null:
		return
	target.set_grid_cell(Vector2i(6, 3))
	battle.call("_clear_enemy_ai_turn_reservations")
	var replan: Dictionary = battle.call("_get_enemy_ai_decision_plan_for_actor", enemy, target)
	_expect(replan.get("final_target_state", null) == target, "moved_target_not_replanned")
	_expect(str(replan.get("action_reason", "WAIT")) != "WAIT", "moved_target_unexpected_wait")


func _validate_directional_attack_contract(battle: Node) -> void:
	var target := battle.get("ally_unit_state") as BattleUnitState
	var enemy := battle.get("enemy_unit_state") as BattleUnitState
	if target == null or enemy == null:
		return
	target.facing = "right"
	target.set_grid_cell(Vector2i(8, 5))
	enemy.set_grid_cell(Vector2i(7, 5))
	var back_angle := str(battle.call("_get_attack_angle_type", enemy, target))
	enemy.set_grid_cell(Vector2i(8, 4))
	var side_angle := str(battle.call("_get_attack_angle_type", enemy, target))
	_expect(back_angle == "back", "back_attack_eligibility")
	_expect(side_angle == "side", "side_attack_eligibility")
	_expect(is_equal_approx(float(battle.call("_get_attack_angle_damage_multiplier", back_angle)), 1.3), "back_multiplier_parity")
	_expect(is_equal_approx(float(battle.call("_get_attack_angle_damage_multiplier", side_angle)), 1.15), "side_multiplier_parity")


func _direction_key(offset: Vector2i) -> String:
	return "%d,%d" % [signi(offset.x), signi(offset.y)]


func _expect(condition: bool, label: String) -> void:
	if not condition:
		_failures.append(label)


func _build_context() -> Dictionary:
	var attacker_hero := _hero("yi_sun_sin", "이순신")
	var defenders := [
		_hero("uija_wang", "의자왕"),
		_hero("gyebaek", "계백"),
		_hero("heukchi_sangji", "흑치상지"),
		_hero("kim_chun_chu", "김춘추"),
	]
	return {
		"type": "attack", "source": "enemy-surround-validator", "mode": "manual", "battle_mode": "invasion",
		"transaction_id": "enemy-surround-validator", "scenario_id": "korea_mvp", "player_faction_id": "player",
		"attacker_city_id": "hanseong", "defender_city_id": "sabi",
		"attacker_city_name": "한성", "defender_city_name": "사비",
		"attacker_faction_display_name": "조선", "target_city_display_name": "사비",
		"attacker_owner": "player", "defender_owner": "baekje",
		"attacker_troops": 300, "defender_troops": 1200,
		"attacker_initial_healthy_troops": 300, "defender_initial_healthy_troops": 1200,
		"attacker_hero_ids": ["yi_sun_sin"],
		"defender_hero_ids": ["uija_wang", "gyebaek", "heukchi_sangji", "kim_chun_chu"],
		"attacker_general_ids": ["yi_sun_sin"],
		"defender_general_ids": ["uija_wang", "gyebaek", "heukchi_sangji", "kim_chun_chu"],
		"attacker_troop_allocation": {"yi_sun_sin": 300},
		"defender_troop_allocation": {"uija_wang": 300, "gyebaek": 300, "heukchi_sangji": 300, "kim_chun_chu": 300},
		"attacker_heroes": [attacker_hero], "defender_heroes": defenders,
		"attacker_carried_gold": 0, "attacker_food_type": "rice", "attacker_food_amount": 20, "attacker_salt_amount": 2,
		"defender_food_type": "barley", "defender_food_amount": 20, "defender_salt_amount": 2,
		"battle_max_turns": 30, "current_battle_turn": 1,
	}


func _hero(hero_id: String, display_name: String) -> Dictionary:
	return {
		"hero_id": hero_id,
		"display_name": display_name,
		"troops": 300,
		"allocated_troops": 300,
		"initial_allocated_troops": 300,
	}
