extends SceneTree

const BattleSupplyRuntimeScript := preload("res://scripts/t02/battle_supply_runtime.gd")
const AutoResolverScript := preload("res://scripts/worldmap/t03/auto_battle_resolver.gd")

var failures: Array[String] = []


func _initialize() -> void:
	_run_pure_calculation_smoke()
	_run_worldmap_smoke.call_deferred()


func _run_pure_calculation_smoke() -> void:
	var supply := BattleSupplyRuntimeScript.new()
	supply.configure({
		"attacker_food_stock": {"rice": 2, "barley": 1, "seafood": 0},
		"attacker_salt_amount": 1,
		"defender_food_type": "seafood",
		"defender_food_amount": 4,
		"defender_salt_amount": 0,
	})
	var turn: Dictionary = supply.settle_turn(1, {"attacker": 300, "defender": 300}, {"attacker": 300, "defender": 300})
	var attacker: Dictionary = (turn.get("sides", {}) as Dictionary).get("attacker", {})
	var attacker_used: Dictionary = attacker.get("food_used_by_type", {})
	_expect(int(attacker_used.get("rice", 0)) == 2 and int(attacker_used.get("barley", 0)) == 1, "multi-food: same-turn fallback")
	_expect(int(attacker.get("deserters", -1)) == 0, "multi-food: no desertion while aggregate food covers need")
	var defender: Dictionary = (turn.get("sides", {}) as Dictionary).get("defender", {})
	_expect(bool(defender.get("salt_shortage", false)) and int(defender.get("food_needed", 0)) == 4, "multi-food: salt shortage adds ten percent")
	var tie_supply := BattleSupplyRuntimeScript.new()
	tie_supply.configure({"attacker_food_stock": {"rice": 1, "barley": 1, "seafood": 1}, "attacker_salt_amount": 1})
	var tie_turn: Dictionary = tie_supply.settle_turn(1, {"attacker": 100, "defender": 0}, {"attacker": 100, "defender": 0})
	var tie_attacker: Dictionary = (tie_turn.get("sides", {}) as Dictionary).get("attacker", {})
	_expect(int((tie_attacker.get("food_used_by_type", {}) as Dictionary).get("rice", 0)) == 1, "multi-food: stable rice-first tie order")

	var allocation := AutoResolverScript.build_force_allocation([
		{"hero_id": "a", "command_limit": 100},
		{"hero_id": "b", "command_limit": 100},
	], 160, 1)
	_expect(int(allocation.get("a", 0)) + int(allocation.get("b", 0)) == 159, "allocation: leaves one garrison")
	var context := _resolver_context("deterministic")
	var first: Dictionary = AutoResolverScript.resolve(context)
	var second: Dictionary = AutoResolverScript.resolve(context)
	_expect(first == second, "resolver: transaction id deterministic")
	_expect(_casualty_total(first, "attacker") == int(context.get("attacker_total_allocated_troops", 0)), "resolver: attacker casualty conservation")
	_expect(_casualty_total(first, "defender") == int(context.get("defender_total_allocated_troops", 0)), "resolver: defender casualty conservation")
	var turn_limit_context := _resolver_context("turn-limit")
	turn_limit_context["automatic_damage_rate"] = 0.0
	var turn_limit_result: Dictionary = AutoResolverScript.resolve(turn_limit_context)
	_expect(str(turn_limit_result.get("winner", "")) == "defender" and int(turn_limit_result.get("completed_turn", 0)) == 30 and str(turn_limit_result.get("result_reason", "")) == "turn_limit", "resolver: round 30 defender victory")


func _run_worldmap_smoke() -> void:
	var packed := load("res://WorldMap.tscn") as PackedScene
	var worldmap := packed.instantiate()
	root.add_child(worldmap)
	await process_frame
	worldmap.call("_initialize_korea_mvp_new_game", "silla")
	for city_id in ["pyeongyang", "hanseong", "sabi", "gyeongju"]:
		_seed_city_for_invasion(worldmap, city_id, 300)
	var state: Dictionary = worldmap.get("_player_state")
	state["turn_number"] = 3
	state["enemy_invasion_roll_turn"] = 0
	_expect((worldmap.call("_roll_enemy_invasion_event_mvp", 0.0, 0) as Dictionary).is_empty(), "willingness: first three turns peaceful")
	state["turn_number"] = 4
	state["enemy_invasion_roll_turn"] = 0
	_expect((worldmap.call("_roll_enemy_invasion_event_mvp", 0.20, 0) as Dictionary).is_empty(), "willingness: twenty-percent boundary excluded")
	state["turn_number"] = 5
	state["enemy_invasion_roll_turn"] = 0
	var rolled_event: Dictionary = worldmap.call("_roll_enemy_invasion_event_mvp", 0.19, 0)
	_expect(not rolled_event.is_empty(), "willingness: eligible roll creates one war")
	state["turn_number"] = 6
	state["enemy_invasion_roll_turn"] = 0
	var cooldown_turn_one := (worldmap.call("_roll_enemy_invasion_event_mvp", 0.0, 0) as Dictionary).is_empty()
	state["turn_number"] = 7
	state["enemy_invasion_roll_turn"] = 0
	var cooldown_turn_two := (worldmap.call("_roll_enemy_invasion_event_mvp", 0.0, 0) as Dictionary).is_empty()
	_expect(cooldown_turn_one and cooldown_turn_two, "willingness: two-turn global cooldown")

	worldmap.call("_initialize_korea_mvp_new_game", "silla")
	_seed_city_for_invasion(worldmap, "pyeongyang", 300)
	_seed_city_for_invasion(worldmap, "hanseong", 260)
	var ai_event: Dictionary = worldmap.call("_create_pending_invasion_event_mvp", "pyeongyang", "hanseong")
	_expect(not ai_event.is_empty() and str(ai_event.get("defender_owner", "")) != "silla", "AI-vs-AI: eligible event")
	var ai_result: Dictionary = worldmap.call("_resolve_t03_automatic_invasion", ai_event)
	_expect(not ai_result.is_empty(), "AI-vs-AI: automatic result")
	state = worldmap.get("_player_state")
	_expect((state.get("applied_battle_result_ids", []) as Array).has(str(ai_result.get("result_id", ""))), "AI-vs-AI: result applied once")
	_expect((state.get("t03_automatic_battle_reports", []) as Array).size() == 1, "AI-vs-AI: presentation queued after settlement")
	var duplicate_result: Dictionary = worldmap.call("_resolve_t03_automatic_invasion", ai_event)
	_expect(duplicate_result.is_empty() and (state.get("t03_automatic_battle_reports", []) as Array).size() == 1, "AI-vs-AI: duplicate transaction no-op")

	worldmap.call("_initialize_korea_mvp_new_game", "player")
	_seed_city_for_invasion(worldmap, "pyeongyang", 300)
	_seed_city_for_invasion(worldmap, "hanseong", 260)
	var player_event: Dictionary = worldmap.call("_create_pending_invasion_event_mvp", "pyeongyang", "hanseong")
	var saved: Dictionary = worldmap.call("_serialize_worldmap_state")
	var restored := packed.instantiate()
	root.add_child(restored)
	await process_frame
	_expect(bool(restored.call("_apply_worldmap_state", saved)), "persistence: pending invasion state accepted")
	var restored_event: Dictionary = restored.call("_get_pending_invasion_event_mvp")
	_expect(str(restored_event.get("transaction_id", "")) == str(player_event.get("transaction_id", "")), "persistence: transaction identity restored")
	restored.queue_free()
	worldmap.queue_free()
	_finish()


func _resolver_context(transaction_id: String) -> Dictionary:
	var attacker_heroes := [{"hero_id": "attacker", "leadership": 75, "war": 78, "attack": 70, "defense": 55, "unit_type": "infantry", "skill_id": "skill_a", "troops": 300}]
	var defender_heroes := [{"hero_id": "defender", "leadership": 74, "war": 72, "attack": 60, "defense": 72, "unit_type": "archer", "skill_id": "skill_d", "troops": 300}]
	return {
		"transaction_id": transaction_id,
		"attacker_city_id": "pyeongyang",
		"defender_city_id": "hanseong",
		"attacker_owner": "goguryeo",
		"defender_owner": "player",
		"attacker_total_allocated_troops": 300,
		"defender_total_allocated_troops": 300,
		"attacker_general_ids": ["attacker"],
		"defender_general_ids": ["defender"],
		"attacker_heroes": attacker_heroes,
		"defender_heroes": defender_heroes,
		"attacker_food_stock": {"rice": 300, "barley": 0, "seafood": 0},
		"defender_food_stock": {"rice": 300, "barley": 0, "seafood": 0},
		"attacker_salt_amount": 100,
		"defender_salt_amount": 100,
	}


func _seed_city_for_invasion(worldmap: Node, city_id: String, troops: int) -> void:
	worldmap.call("_set_city_runtime_troops", city_id, troops)
	worldmap.call("_ensure_city_supply_resource_defaults", city_id)
	var cities: Dictionary = worldmap.get("_city_runtime_states")
	var city: Dictionary = cities.get(city_id, {}).duplicate(true)
	city["resource_stock"] = {"rice": 500, "barley": 500, "seafood": 500, "gold": 5000, "salt": 500}
	cities[city_id] = city


func _casualty_total(result: Dictionary, side: String) -> int:
	return int(result.get("%s_healthy_survivors" % side, 0)) + int(result.get("%s_wounded" % side, 0)) + int(result.get("%s_dead" % side, 0)) + int(result.get("%s_deserters" % side, 0))


func _expect(condition: bool, label: String) -> void:
	if condition:
		print("[T03_SMOKE_PASS] %s" % label)
	else:
		failures.append(label)
		push_error("[T03_SMOKE_FAIL] %s" % label)


func _finish() -> void:
	if failures.is_empty():
		print("[T03_SMOKE] PASS")
		quit(0)
	else:
		print("[T03_SMOKE] FAIL %s" % str(failures))
		quit(1)
