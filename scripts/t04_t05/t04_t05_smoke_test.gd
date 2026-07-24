extends SceneTree

const TurnOutcomeRulesScript := preload("res://scripts/worldmap/t04_t05/turn_outcome_rules.gd")

var failures: Array[String] = []


func _initialize() -> void:
	_run_pure_rules_smoke()
	_run_worldmap_smoke.call_deferred()


func _run_pure_rules_smoke() -> void:
	_expect(TurnOutcomeRulesScript.make_turn_resolution_id(7, "silla") == "t04-7-silla", "transaction: deterministic turn id")
	_expect(TurnOutcomeRulesScript.normalize_string_array(["a", "a", "", "b"]) == ["a", "b"], "transaction: duplicate completion ids removed")
	_expect(TurnOutcomeRulesScript.evaluate_outcome(4) == TurnOutcomeRulesScript.OUTCOME_VICTORY, "outcome: four cities victory")
	_expect(TurnOutcomeRulesScript.evaluate_outcome(0) == TurnOutcomeRulesScript.OUTCOME_DEFEAT, "outcome: zero cities defeat")
	_expect(TurnOutcomeRulesScript.evaluate_outcome(2) == TurnOutcomeRulesScript.OUTCOME_ACTIVE, "outcome: partial ownership remains active")
	var victory: Dictionary = TurnOutcomeRulesScript.make_outcome_state("victory", "player", 9, 4)
	var repeated: Dictionary = TurnOutcomeRulesScript.make_outcome_state("defeat", "player", 10, 0, victory)
	_expect(str(victory.get("outcome_id", "")) == "t05-victory-player-9", "outcome: deterministic result id")
	_expect(repeated == victory, "outcome: terminal result is immutable")


func _run_worldmap_smoke() -> void:
	var packed := load("res://WorldMap.tscn") as PackedScene
	var worldmap := packed.instantiate()
	root.add_child(worldmap)
	await process_frame
	worldmap.call("_initialize_korea_mvp_new_game", "player")
	var state: Dictionary = worldmap.get("_player_state")
	state["turn_number"] = 1
	var hanseong_before: Dictionary = (worldmap.call("_get_city_hud_entry", "hanseong") as Dictionary).get("resource_stock", {}).duplicate(true)
	worldmap.call("_on_ally_turn_end_pressed")
	await create_timer(1.0).timeout
	state = worldmap.get("_player_state")
	_expect(int(state.get("turn_number", 0)) == 2 and str(state.get("turn_phase", "")) == "player", "turn loop: enemy and domestic resolution advances exactly once")
	_expect((state.get("completed_turn_resolution_ids", []) as Array).has("t04-1-player"), "turn loop: completion id persisted")
	var hanseong_after: Dictionary = (worldmap.call("_get_city_hud_entry", "hanseong") as Dictionary).get("resource_stock", {})
	_expect(hanseong_after != hanseong_before, "turn loop: player city stock receives production/upkeep mutation")
	for city_id in ["pyeongyang", "gyeongju", "sabi"]:
		worldmap.call("_set_city_runtime_owner", city_id, "player")
	worldmap.call("_rebuild_occupation_runtime_indexes_mvp")
	state = worldmap.get("_player_state")
	_expect(str((state.get("game_outcome", {}) as Dictionary).get("status", "")) == "victory", "outcome: runtime ownership opens victory state")
	var saved: Dictionary = worldmap.call("_serialize_worldmap_state")
	var restored := packed.instantiate()
	root.add_child(restored)
	await process_frame
	_expect(bool(restored.call("_apply_worldmap_state", saved)), "persistence: T04-T05 state accepted")
	var restored_state: Dictionary = restored.get("_player_state")
	_expect((restored_state.get("completed_turn_resolution_ids", []) as Array).has("t04-1-player"), "persistence: completion guard restored")
	_expect(str((restored_state.get("game_outcome", {}) as Dictionary).get("status", "")) == "victory", "persistence: terminal outcome restored")
	restored.queue_free()
	worldmap.queue_free()
	_finish()


func _expect(condition: bool, label: String) -> void:
	if condition:
		print("[T04_T05_SMOKE_PASS] %s" % label)
	else:
		failures.append(label)
		push_error("[T04_T05_SMOKE_FAIL] %s" % label)


func _finish() -> void:
	if failures.is_empty():
		print("[T04_T05_SMOKE] PASS")
		quit(0)
	else:
		print("[T04_T05_SMOKE] FAIL %s" % str(failures))
		quit(1)
