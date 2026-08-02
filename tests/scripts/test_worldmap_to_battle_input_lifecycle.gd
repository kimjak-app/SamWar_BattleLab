extends SceneTree


const WORLDMAP_SCENE := preload("res://WorldMap.tscn")
const BATTLE_SCENE_PATH := "res://Battle_Land.tscn"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var change_result := change_scene_to_packed(WORLDMAP_SCENE)
	_expect(change_result == OK, "WorldMap scene transition starts")
	await process_frame
	await process_frame
	var worldmap := current_scene
	_expect(worldmap != null, "WorldMap scene loaded")

	worldmap.call("_handoff_battle_context_to_battle_scene", _build_context())
	await process_frame
	_expect(bool(worldmap.get("_worldmap_battle_entry_handoff_in_progress")), "battle handoff entered once")

	var skip_event := InputEventKey.new()
	skip_event.pressed = true
	skip_event.keycode = KEY_ENTER
	worldmap.call("_input", skip_event)
	# These events model Enter double-press and mixed button/key burst input while
	# the replacement commits.
	worldmap.call("_input", skip_event)
	var click_event := InputEventMouseButton.new()
	click_event.pressed = true
	click_event.button_index = MOUSE_BUTTON_LEFT
	worldmap.call("_input", click_event)
	await process_frame
	await process_frame

	var battle := current_scene
	_expect(battle != null and battle.scene_file_path == BATTLE_SCENE_PATH, "single input handoff enters Battle_Land")
	_expect(not Engine.has_meta("samwar_worldmap_battle_context"), "context consumed exactly once")
	_expect(battle.get("battle_supply_runtime") != null, "BattleSupplyRuntime configured")
	var supply_panel := battle.get_node_or_null("BattleUI/T02BattleSupplyAnchor/T02BattleSupplyPanel") as Control
	_expect(supply_panel != null and supply_panel.visible, "runtime supply panel visible")
	print("[WORLDMAP_INPUT_LIFECYCLE] PASS")
	quit(0)


func _build_context() -> Dictionary:
	return {
		"type": "attack", "source": "player_attack", "mode": "manual", "battle_mode": "invasion",
		"transaction_id": "worldmap-input-lifecycle", "scenario_id": "korea_mvp", "player_faction_id": "player",
		"attacker_city_id": "hanseong", "defender_city_id": "pyeongyang",
		"attacker_city_name": "한성", "defender_city_name": "평양",
		"attacker_faction_display_name": "조선", "target_city_display_name": "평양",
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


func _expect(condition: bool, label: String) -> void:
	if condition:
		print("[WORLDMAP_INPUT_LIFECYCLE_PASS] %s" % label)
		return
	push_error("[WORLDMAP_INPUT_LIFECYCLE_FAIL] %s" % label)
	quit(1)
