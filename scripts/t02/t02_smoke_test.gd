extends SceneTree

var failures: Array[String] = []


func _initialize() -> void:
	_run_supply_smoke()
	_run_wounded_smoke()
	_run_settlement_smoke.call_deferred()


func _run_supply_smoke() -> void:
	_expect(ExpeditionSupplyCalculator.minimum_gold(301) == 80, "formation: minimum gold")
	_expect(ExpeditionSupplyCalculator.deployment_limits(900, 40, 20).get("gold") == 200, "formation: gold cap")
	_expect(ExpeditionSupplyCalculator.minimum_food(100) == 2, "formation: no-salt one-turn food")
	_expect(ExpeditionSupplyCalculator.food_per_turn(100, false) == 2, "supply: no-salt +10 percent ceil")
	_expect(ExpeditionSupplyCalculator.salt_per_turn(501) == 2, "supply: salt ceil")
	var prediction := ExpeditionSupplyCalculator.predict_supply(100, 100, 0)
	_expect(int(prediction.get("sustained_turns", 0)) == 30, "formation: cargo beyond 30 turns allowed")

	var runtime := BattleSupplyRuntime.new()
	runtime.configure({
		"attacker_food_type": "rice", "attacker_food_amount": 10, "attacker_salt_amount": 1, "attacker_carried_gold": 50,
		"defender_food_type": "barley", "defender_food_amount": 0, "defender_salt_amount": 0,
	})
	var first := runtime.settle_turn(1, {"attacker": 500, "defender": 1000}, {"attacker": 500, "defender": 1000})
	var duplicate := runtime.settle_turn(1, {"attacker": 500, "defender": 1000}, {"attacker": 500, "defender": 1000})
	_expect(bool(first.get("applied", false)), "supply: first settlement")
	_expect(not bool(duplicate.get("applied", true)), "supply: once per turn")
	_expect(int(((first.get("sides", {}) as Dictionary).get("attacker", {}) as Dictionary).get("salt_used", 0)) == 1, "supply: normal salt consumption")
	_expect(int(((first.get("sides", {}) as Dictionary).get("defender", {}) as Dictionary).get("deserters", 0)) == 100, "supply: food-zero desertion")
	var second := runtime.settle_turn(2, {"attacker": 400, "defender": 900}, {"attacker": 400, "defender": 900})
	_expect(int(((second.get("sides", {}) as Dictionary).get("attacker", {}) as Dictionary).get("food_needed", 0)) == 5, "supply: lower troops lower next consumption")


func _run_wounded_smoke() -> void:
	var normal := WoundedRecovery.make_entry(250, "normal", "tx-normal")
	var fast := WoundedRecovery.make_entry(250, "fast", "tx-fast")
	_expect(int(normal.get("recovery_months_remaining", 0)) == 3, "wounded: normal three months")
	_expect(int(fast.get("recovery_months_remaining", 0)) == 1, "wounded: fast one month")
	_expect(ExpeditionSupplyCalculator.fast_recovery_salt(250) == 3, "wounded: fast salt ceil")
	var recovered := WoundedRecovery.advance_month([fast])
	_expect(int(recovered.get("recovered", 0)) == 250, "wounded: recover into healthy")


func _run_settlement_smoke() -> void:
	var packed := load("res://WorldMap.tscn") as PackedScene
	var worldmap := packed.instantiate()
	root.add_child(worldmap)
	await process_frame
	_run_four_faction_smoke(worldmap)
	worldmap.call("_initialize_korea_mvp_new_game", "player")
	await _run_defender_supply_persistence_smoke(worldmap, packed)
	worldmap.call("_ensure_city_supply_resource_defaults", "hanseong")
	worldmap.call("_ensure_city_supply_resource_defaults", "pyeongyang")
	var rollback_before: Dictionary = (worldmap.call("_get_city_hud_entry", "hanseong") as Dictionary).get("resource_stock", {}).duplicate(true)
	worldmap.call("_pay_player_attack_supply_cost", "hanseong", {"food_type": "rice", "food": 5, "gold": 20, "salt": 2})
	worldmap.call("_set_city_runtime_troops", "hanseong", 250)
	var rollback_selection: Array[String] = ["yi_sun_sin"]
	worldmap.call("_move_generals_for_pending_expedition", "hanseong", rollback_selection)
	worldmap.call("_rollback_player_attack_handoff", {"source": "player_attack", "attacker_source_city_id": "hanseong", "attacker_source_city_troops_before": 300, "attacker_food_type": "rice", "attacker_food_amount": 5, "attacker_carried_gold": 20, "attacker_salt_amount": 2, "attacker_general_ids": rollback_selection})
	var rollback_after: Dictionary = (worldmap.call("_get_city_hud_entry", "hanseong") as Dictionary).get("resource_stock", {})
	_expect(rollback_after == rollback_before and int(worldmap.call("_get_city_troops_for_battle_context", "hanseong")) == 300, "system failure: cargo and troops rolled back")
	_expect(((worldmap.call("_get_city_hud_entry", "hanseong") as Dictionary).get("stationed_hero_ids", []) as Array).has("yi_sun_sin"), "system failure: general rolled back")
	worldmap.call("_set_city_runtime_troops", "hanseong", 200)
	var snapshot: Dictionary = worldmap.call("_serialize_worldmap_state")
	var player_state: Dictionary = snapshot.get("player_state", {}).duplicate(true)
	player_state["pending_battle_context"] = {"transaction_id": "t02-smoke-victory"}
	snapshot["player_state"] = player_state
	var result := _make_result(snapshot, "t02-smoke-victory", "result-victory", "attacker")
	worldmap.call("_apply_returned_battle_result_mvp", result)
	_expect(str(worldmap.call("_get_city_owner_id_for_battle_context", "pyeongyang")) == "player", "victory: ownership")
	_expect(int(worldmap.call("_get_city_troops_for_battle_context", "pyeongyang")) == 120, "victory: healthy troops")
	var target: Dictionary = worldmap.call("_get_city_hud_entry", "pyeongyang")
	var queue: Array = target.get("wounded_queue", [])
	_expect(queue.size() == 1 and int((queue[0] as Dictionary).get("wounded_count", 0)) == 30, "victory: wounded queue")
	var stock: Dictionary = target.get("resource_stock", {})
	_expect(int(stock.get("gold", 0)) >= 75, "victory: remaining gold transfer")
	_expect((target.get("stationed_hero_ids", []) as Array).has("yi_sun_sin"), "victory: surviving general stationed at occupation")
	_expect(not ((worldmap.call("_get_city_hud_entry", "hanseong") as Dictionary).get("stationed_hero_ids", []) as Array).has("yi_sun_sin"), "victory: general not duplicated at source")
	_expect(str((worldmap.call("_get_hero_entry", "yi_sun_sin") as Dictionary).get("current_city_id", "")) == "pyeongyang", "victory: attacker runtime city is occupation")
	_expect(str(target.get("governor_id", "")) == "", "victory: occupied city has no governor")
	_expect((target.get("stationed_hero_ids", []) as Array).has("gwanggaeto"), "defender: no adjacent retreat aligns survivor")
	_expect(str((worldmap.call("_get_hero_entry", "gwanggaeto") as Dictionary).get("faction_id", "")) == "player", "defender: aligned faction persisted")
	var aggregation: Dictionary = (worldmap.get("_player_state") as Dictionary).get("national_aggregation", {})
	_expect(int(aggregation.get("population", 0)) >= 92000, "aggregation: occupied city population included")
	worldmap.call("_on_fast_wounded_treatment_pressed")
	target = worldmap.call("_get_city_hud_entry", "pyeongyang")
	queue = target.get("wounded_queue", [])
	_expect(int((queue[0] as Dictionary).get("recovery_months_remaining", 0)) == 1, "wounded: fast treatment runtime selection")
	var troops_after := int(worldmap.call("_get_city_troops_for_battle_context", "pyeongyang"))
	worldmap.call("_apply_returned_battle_result_mvp", result)
	_expect(int(worldmap.call("_get_city_troops_for_battle_context", "pyeongyang")) == troops_after, "duplicate result: no-op")
	var victory_saved: Dictionary = worldmap.call("_serialize_worldmap_state")
	var restored_worldmap := packed.instantiate()
	root.add_child(restored_worldmap)
	await process_frame
	_expect(bool(restored_worldmap.call("_apply_worldmap_state", victory_saved)), "save/load: victory state accepted")
	_expect(str(restored_worldmap.call("_get_city_owner_id_for_battle_context", "pyeongyang")) == "player", "save/load: occupation restored")
	var restored_target: Dictionary = restored_worldmap.call("_get_city_hud_entry", "pyeongyang")
	_expect((restored_target.get("wounded_queue", []) as Array).size() == 1, "save/load: wounded queue restored")
	_expect(str((restored_worldmap.call("_get_hero_entry", "yi_sun_sin") as Dictionary).get("current_city_id", "")) == "pyeongyang", "save/load: attacker occupation location restored")
	_expect(str((restored_worldmap.call("_get_hero_entry", "gwanggaeto") as Dictionary).get("faction_id", "")) == "player", "save/load: aligned defender faction restored")
	restored_worldmap.queue_free()

	worldmap.call("_set_city_runtime_owner", "pyeongyang", "goguryeo")
	var defeat_snapshot: Dictionary = worldmap.call("_serialize_worldmap_state")
	var defeat_player: Dictionary = defeat_snapshot.get("player_state", {}).duplicate(true)
	defeat_player["pending_battle_context"] = {"transaction_id": "t02-smoke-defeat"}
	defeat_snapshot["player_state"] = defeat_player
	var defeat := _make_result(defeat_snapshot, "t02-smoke-defeat", "result-defeat", "defender")
	defeat["result_reason"] = "turn_limit"
	worldmap.call("_apply_returned_battle_result_mvp", defeat)
	_expect(str(worldmap.call("_get_city_owner_id_for_battle_context", "pyeongyang")) == "goguryeo", "turn limit: ownership unchanged")
	_expect(int(worldmap.call("_get_city_troops_for_battle_context", "hanseong")) >= 260, "defeat: survivors return")
	var saved := worldmap.call("_serialize_worldmap_state") as Dictionary
	_expect((saved.get("player_state", {}) as Dictionary).get("applied_battle_result_ids", []).has("result-defeat"), "save/load: applied result persisted")
	_finish()


func _run_defender_supply_persistence_smoke(worldmap: Node, packed: PackedScene) -> void:
	var cities: Dictionary = worldmap.get("_city_runtime_states")
	var sabi: Dictionary = cities.get("sabi", {}).duplicate(true)
	sabi["resource_stock"] = {"rice": 90, "barley": 120, "seafood": 142, "salt": 56, "gold": 620}
	cities["sabi"] = sabi
	var selected_heroes: Array[String] = ["yi_sun_sin"]
	var context: Dictionary = worldmap.call("_build_player_attack_battle_context", "hanseong", "sabi", "manual", selected_heroes, {"yi_sun_sin": 1}, {"food_type": "rice", "food": 2, "gold": 20, "salt": 0})
	_expect(str(context.get("defender_food_type", "")) == "seafood", "defender supply: persistent city selects seafood")
	_expect(int(context.get("defender_food_amount", -1)) == 142 and int(context.get("defender_salt_amount", -1)) == 56, "defender supply: context equals Sabi stock")
	var runtime := BattleSupplyRuntime.new()
	runtime.configure(context)
	var initial: Dictionary = runtime.snapshot().get("defender", {})
	_expect(str(initial.get("food_type", "")) == "seafood" and int(initial.get("food", -1)) == 142 and int(initial.get("salt", -1)) == 56, "defender supply: runtime equals context")
	runtime.settle_turn(1, {"attacker": 100, "defender": 100}, {"attacker": 100, "defender": 100})
	var remaining: Dictionary = runtime.snapshot().get("defender", {})
	_expect(int(remaining.get("food", -1)) == 141 and int(remaining.get("salt", -1)) == 55, "defender supply: one-turn consumption")
	worldmap.call("_apply_t02_defender_supply_result", "sabi", {"defender_remaining_food_type": "seafood", "defender_remaining_food": 141, "defender_remaining_salt": 55})
	var settled: Dictionary = (worldmap.call("_get_city_hud_entry", "sabi") as Dictionary).get("resource_stock", {})
	_expect(int(settled.get("seafood", -1)) == 141 and int(settled.get("salt", -1)) == 55, "defender supply: settlement updates persistent city")
	var saved := worldmap.call("_serialize_worldmap_state") as Dictionary
	var restored := packed.instantiate()
	root.add_child(restored)
	await process_frame
	_expect(bool(restored.call("_apply_worldmap_state", saved)), "defender supply: save state accepted")
	var restored_stock: Dictionary = (restored.call("_get_city_hud_entry", "sabi") as Dictionary).get("resource_stock", {})
	_expect(int(restored_stock.get("seafood", -1)) == 141 and int(restored_stock.get("salt", -1)) == 55, "defender supply: save/load preserves consumed stock")
	var repeat_context: Dictionary = restored.call("_build_player_attack_battle_context", "hanseong", "sabi", "manual", selected_heroes, {"yi_sun_sin": 1}, {"food_type": "rice", "food": 2, "gold": 20, "salt": 0})
	_expect(int(repeat_context.get("defender_salt_amount", -1)) == 55, "defender supply: context does not reseed salt")
	restored.queue_free()


func _run_four_faction_smoke(worldmap: Node) -> void:
	var starts := {"player": "hanseong", "goguryeo": "pyeongyang", "silla": "gyeongju", "baekje_faction": "sabi"}
	for faction_id in starts.keys():
		(worldmap.get("_city_runtime_states") as Dictionary).clear()
		(worldmap.get("_hero_runtime_states") as Dictionary).clear()
		worldmap.call("_initialize_korea_mvp_new_game", faction_id)
		var source_city_id := str(starts.get(faction_id, ""))
		var target_city_id := ""
		for neighbor in worldmap.call("_get_city_neighbors_mvp", source_city_id):
			if str(worldmap.call("_get_city_owner_id_for_battle_context", str(neighbor))) != faction_id:
				target_city_id = str(neighbor)
				break
		var heroes: Array = worldmap.call("_get_available_player_attack_main_hero_ids", source_city_id)
		var hero_id := str(heroes[0]) if not heroes.is_empty() else ""
		var selection: Array[String] = [hero_id]
		var context: Dictionary = worldmap.call("_build_player_attack_battle_context", source_city_id, target_city_id, "manual", selection, {hero_id: 1}, {"food_type": "rice", "food": 2, "gold": 20, "salt": 0})
		_expect(not context.is_empty(), "four-faction %s: formation" % faction_id)
		_expect(str(context.get("attacker_faction_id", "")) == faction_id, "four-faction %s: attacker side" % faction_id)
		_expect((context.get("attacker_general_ids", []) as Array).has(hero_id), "four-faction %s: actual stationed general" % faction_id)
		worldmap.call("_ensure_city_supply_resource_defaults", source_city_id)
		worldmap.call("_ensure_city_supply_resource_defaults", target_city_id)
		var snapshot: Dictionary = worldmap.call("_serialize_worldmap_state")
		var transaction_id := "four-%s" % faction_id
		var snapshot_player: Dictionary = snapshot.get("player_state", {}).duplicate(true)
		snapshot_player["pending_battle_context"] = {"transaction_id": transaction_id}
		snapshot["player_state"] = snapshot_player
		var settlement := {
			"source": "player_attack", "type": "attack_result", "transaction_id": transaction_id, "result_id": "%s-result" % transaction_id,
			"winner": "attacker", "winner_side": "attacker", "attacker_city_id": source_city_id, "attacker_source_city_id": source_city_id,
			"defender_city_id": target_city_id, "attacker_owner": faction_id, "attacker_healthy_survivors": 1,
			"attacker_wounded": 0, "attacker_dead": 0, "attacker_deserters": 0,
			"attacker_remaining_gold": 20, "attacker_remaining_food_type": "rice", "attacker_remaining_food": 1, "attacker_remaining_salt": 0,
			"defender_healthy_survivors": 0, "defender_remaining_food_type": "rice", "defender_remaining_food": 0, "defender_remaining_salt": 0,
			"attacker_general_ids": [hero_id], "attacker_surviving_general_ids": [hero_id],
			"defender_general_ids": context.get("defender_general_ids", []), "defender_surviving_general_ids": [],
			"worldmap_state_snapshot": snapshot,
		}
		worldmap.call("_apply_returned_battle_result_mvp", settlement)
		_expect(str(worldmap.call("_get_city_owner_id_for_battle_context", target_city_id)) == faction_id, "four-faction %s: settlement" % faction_id)


func _make_result(snapshot: Dictionary, transaction_id: String, result_id: String, winner: String) -> Dictionary:
	return {
		"source": "player_attack", "type": "attack_result", "transaction_id": transaction_id, "result_id": result_id,
		"winner": winner, "winner_side": winner, "result_reason": "elimination", "completed_turn": 7,
		"attacker_city_id": "hanseong", "attacker_source_city_id": "hanseong", "defender_city_id": "pyeongyang",
		"attacker_owner": "player", "attacker_healthy_survivors": 120 if winner == "attacker" else 60,
		"attacker_wounded": 30, "attacker_dead": 40, "attacker_deserters": 10,
		"attacker_remaining_gold": 75, "attacker_remaining_food_type": "rice", "attacker_remaining_food": 40, "attacker_remaining_salt": 8,
		"defender_healthy_survivors": 80, "defender_wounded": 20, "defender_dead": 30, "defender_deserters": 0,
		"defender_remaining_food_type": "barley", "defender_remaining_food": 25, "defender_remaining_salt": 4,
		"attacker_surviving_general_ids": ["yi_sun_sin"], "defender_surviving_general_ids": ["gwanggaeto"],
		"attacker_general_ids": ["yi_sun_sin"], "defender_general_ids": ["gwanggaeto", "eulji_mundeok", "dorim", "cheok_jun_gyeong"],
		"worldmap_state_snapshot": snapshot,
	}


func _expect(condition: bool, label: String) -> void:
	if condition:
		print("[T02_SMOKE_PASS] %s" % label)
	else:
		failures.append(label)
		push_error("[T02_SMOKE_FAIL] %s" % label)


func _finish() -> void:
	if failures.is_empty():
		print("[T02_SMOKE] PASS")
		quit(0)
	else:
		print("[T02_SMOKE] FAIL %s" % str(failures))
		quit(1)
