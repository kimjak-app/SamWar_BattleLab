extends SceneTree


func _initialize() -> void:
	var context := {
		"type": "attack", "source": "player_attack", "mode": "manual",
		"transaction_id": "t02-battle-smoke", "scenario_id": "korea_mvp", "player_faction_id": "player",
		"attacker_city_id": "hanseong", "defender_city_id": "pyeongyang",
		"attacker_city_name": "한성", "defender_city_name": "평양",
		"attacker_owner": "player", "defender_owner": "goguryeo",
		"attacker_troops": 200, "defender_troops": 200,
		"attacker_initial_healthy_troops": 200, "defender_initial_healthy_troops": 200,
		"attacker_hero_ids": ["yi_sun_sin"], "defender_hero_ids": ["gwanggaeto"],
		"attacker_general_ids": ["yi_sun_sin"], "defender_general_ids": ["gwanggaeto"],
		"attacker_troop_allocation": {"yi_sun_sin": 200}, "defender_troop_allocation": {"gwanggaeto": 200},
		"attacker_heroes": [{"hero_id": "yi_sun_sin", "display_name": "이순신", "troops": 200, "allocated_troops": 200, "initial_allocated_troops": 200}],
		"defender_heroes": [{"hero_id": "gwanggaeto", "display_name": "광개토대왕", "troops": 200, "allocated_troops": 200, "initial_allocated_troops": 200}],
		"attacker_carried_gold": 80, "attacker_food_type": "rice", "attacker_food_amount": 20, "attacker_salt_amount": 2,
		"defender_food_type": "barley", "defender_food_amount": 20, "defender_salt_amount": 2,
		"battle_max_turns": 30, "current_battle_turn": 1,
	}
	Engine.set_meta("samwar_worldmap_battle_context", context)
	var battle := (load("res://Battle_Land.tscn") as PackedScene).instantiate()
	root.add_child(battle)
	await process_frame
	var runtime: BattleSupplyRuntime = battle.get("battle_supply_runtime")
	_expect(runtime != null, "runtime configured")
	_expect(int((runtime.snapshot().get("attacker", {}) as Dictionary).get("food", -1)) == 18, "round one supply consumed once")
	_expect(battle.get_node_or_null("BattleUI/T02BattleSupplyHUD") != null, "supply HUD created")
	battle.set("battle_round", 30)
	battle.call("_start_new_round")
	_expect(str(battle.get("battle_result_reason")) == "turn_limit", "30-turn reason")
	_expect(str(battle.call("_get_battle_result_state")) == "defeat", "30-turn defender win for player attack")
	var result: Dictionary = battle.call("_build_worldmap_battle_result_payload", "defeat")
	_expect(str(result.get("transaction_id", "")) == "t02-battle-smoke", "result transaction id")
	_expect(str(result.get("result_reason", "")) == "turn_limit", "result turn-limit contract")
	_expect(result.has("attacker_remaining_food") and result.has("defender_remaining_salt"), "result supply contract")
	print("[T02_BATTLE_SMOKE] PASS")
	quit(0)


func _expect(condition: bool, label: String) -> void:
	if not condition:
		push_error("[T02_BATTLE_SMOKE_FAIL] %s" % label)
		quit(1)
	else:
		print("[T02_BATTLE_SMOKE_PASS] %s" % label)
