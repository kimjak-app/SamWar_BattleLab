extends SceneTree


func _initialize() -> void:
	var context := {
		"type": "attack", "source": "player_attack", "mode": "manual",
		"transaction_id": "t02-battle-smoke", "scenario_id": "korea_mvp", "player_faction_id": "player",
		"attacker_city_id": "hanseong", "defender_city_id": "pyeongyang",
		"attacker_city_name": "한성", "defender_city_name": "평양",
		"attacker_owner": "player", "defender_owner": "goguryeo",
		"attacker_troops": 300, "defender_troops": 300,
		"attacker_initial_healthy_troops": 300, "defender_initial_healthy_troops": 300,
		"attacker_hero_ids": ["yi_sun_sin"], "defender_hero_ids": ["gwanggaeto"],
		"attacker_general_ids": ["yi_sun_sin"], "defender_general_ids": ["gwanggaeto"],
		"attacker_troop_allocation": {"yi_sun_sin": 300}, "defender_troop_allocation": {"gwanggaeto": 300},
		"attacker_heroes": [{"hero_id": "yi_sun_sin", "display_name": "이순신", "troops": 300, "allocated_troops": 300, "initial_allocated_troops": 300}],
		"defender_heroes": [{"hero_id": "gwanggaeto", "display_name": "광개토대왕", "troops": 300, "allocated_troops": 300, "initial_allocated_troops": 300}],
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
	_expect(int((runtime.snapshot().get("attacker", {}) as Dictionary).get("food", -1)) == 17, "round one supply consumed once")
	var supply_panel := battle.get_node_or_null("BattleUI/T02BattleSupplyAnchor/T02BattleSupplyPanel") as Control
	_expect(supply_panel != null and supply_panel.visible, "right-bottom supply panel visible")
	_expect(supply_panel.position.x >= 1200.0 and supply_panel.position.y >= 500.0, "supply panel occupies intended right-bottom quadrant")
	_expect(battle.get_node_or_null("BattleUI/T02BattleSupplyHUD") == null, "legacy left-top supply HUD removed")
	var command_bar := battle.get_node("BattleUI/CommandBar") as Control
	var enemy_formation := battle.get_node("BattleUI/FormationSlotGuideLayer/EnemyFormationGuidePanel") as Control
	var ally_formation := battle.get_node("BattleUI/FormationSlotGuideLayer/AllyFormationGuidePanel") as Control
	_expect(not supply_panel.get_global_rect().intersects(command_bar.get_global_rect()), "supply panel does not overlap command buttons")
	_expect(not supply_panel.get_global_rect().intersects(enemy_formation.get_global_rect()), "supply panel does not overlap enemy formation")
	_expect(not supply_panel.get_global_rect().intersects(ally_formation.get_global_rect()), "supply panel does not overlap ally formation")
	runtime.sides["attacker"] = {"food_type": "rice", "food": 180, "salt": 32, "gold": 80, "deserters": 0}
	runtime.sides["defender"] = {"food_type": "barley", "food": 140, "salt": 18, "gold": 0, "deserters": 0}
	battle.set("battle_round", 3)
	battle.call("_refresh_battle_supply_hud")
	_expect(_label_text(battle, "Margin/Content/Header/TurnLabel") == "전투 턴 3 / 30\n남은 턴 27", "turn and remaining-turn text")
	_expect(_label_text(battle, "Margin/Content/AllyGrid/FoodValue") == "쌀 180", "ally food type and amount")
	_expect(_label_text(battle, "Margin/Content/AllyGrid/SaltValue") == "32", "ally salt amount")
	_expect(_label_text(battle, "Margin/Content/AllyGrid/FoodConsumptionValue") == "3 / 턴", "ally food consumption")
	_expect(_label_text(battle, "Margin/Content/AllyGrid/SaltConsumptionValue") == "1 / 턴", "ally salt consumption")
	_expect(_label_text(battle, "Margin/Content/AllyGrid/SustainValue") == "30턴 이상", "ally sustain text")
	_expect(_label_text(battle, "Margin/Content/EnemyGrid/FoodValue") == "보리 140", "enemy food type and amount")
	_expect(_label_text(battle, "Margin/Content/EnemyGrid/SaltValue") == "18", "enemy salt amount")
	_expect(_label_text(battle, "Margin/Content/EnemyGrid/FoodConsumptionValue") == "3 / 턴", "enemy food consumption")
	_expect(_label_text(battle, "Margin/Content/EnemyGrid/SaltConsumptionValue") == "1 / 턴", "enemy salt consumption")
	if OS.has_environment("T02_HUD_VISUAL_QA"):
		print("[T02_HUD_VISUAL_QA] sample panel held for inspection")
		await create_timer(60.0).timeout
		quit(0)
		return
	runtime.sides["attacker"] = {"food_type": "rice", "food": 180, "salt": 0, "gold": 80, "deserters": 0}
	battle.call("_refresh_battle_supply_hud")
	_expect(_label_text(battle, "Margin/Content/AllyWarningLabel").contains("소금 고갈"), "salt-zero warning")
	_expect(_label_text(battle, "Margin/Content/AllyGrid/FoodConsumptionValue") == "4 / 턴", "salt-zero food surcharge display")
	runtime.sides["attacker"] = {"food_type": "rice", "food": 0, "salt": 0, "gold": 80, "deserters": 0}
	runtime.sides["defender"] = {"food_type": "barley", "food": 0, "salt": 0, "gold": 0, "deserters": 0}
	battle.call("_refresh_battle_supply_hud")
	_expect(_label_text(battle, "Margin/Content/AllyWarningLabel").contains("10% 이탈"), "food-zero warning")
	await process_frame
	var supply_content := battle.get_node("BattleUI/T02BattleSupplyAnchor/T02BattleSupplyPanel/Margin/Content") as Control
	_expect(supply_panel.get_global_rect().encloses(supply_content.get_global_rect()), "all warning text fits inside supply panel")
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


func _label_text(battle: Node, relative_path: String) -> String:
	var label := battle.get_node_or_null("BattleUI/T02BattleSupplyAnchor/T02BattleSupplyPanel/%s" % relative_path) as Label
	return label.text if label != null else ""
