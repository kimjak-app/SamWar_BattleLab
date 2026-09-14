extends SceneTree

const SCENE_PATH := "res://WorldMap_16x9_Test.tscn"

var _checks := 0
var _failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("[TRADE_AUTOMATION] FAIL: " + label)


func _storage(host: Node, city_id: String) -> Dictionary:
	return host.call("_get_city_storage", city_id, host.call("_get_city_hud_entry", city_id)).duplicate(true)


func _run() -> void:
	change_scene_to_file(SCENE_PATH)
	await process_frame
	await process_frame
	var host := current_scene.get_node("ProductionWorldMap")
	var controller: RefCounted = host.call("_ensure_trade_controller")
	_expect(controller.get("_action_service") != null, "manual TradeActionService owned")
	_expect(controller.get("_automation_service") != null, "TradeAutomationService owned")
	_expect(controller.get("_internal_transfer_service") != null, "InternalTradeTransferService owned")
	var baseline_state: Dictionary = host.get("_player_state").duplicate(true)
	var baseline_cities: Dictionary = host.get("_city_runtime_states").duplicate(true)

	var no_chancellor_state := baseline_state.duplicate(true)
	no_chancellor_state["chancellor_id"] = ""
	no_chancellor_state["last_chancellor_auto_trade_turn"] = 0
	host.set("_player_state", no_chancellor_state)
	var missing: Dictionary = controller.call("run_chancellor_auto_trade", 901)
	_expect(missing.get("reason") == "no_chancellor", "chancellor eligibility")
	_expect(int(host.get("_player_state").get("last_chancellor_auto_trade_turn", 0)) == 901, "eligibility result lifecycle")
	_expect(controller.call("run_chancellor_auto_trade", 901) == missing, "same-turn idempotence")

	host.set("_player_state", baseline_state.duplicate(true))
	host.set("_city_runtime_states", baseline_cities.duplicate(true))
	var state: Dictionary = host.get("_player_state")
	var chancellor_id := str(state.get("chancellor_id", ""))
	if chancellor_id.is_empty():
		var candidates: Array[String] = host.call("_get_player_chancellor_candidate_hero_ids")
		if not candidates.is_empty():
			chancellor_id = candidates[0]
			state["chancellor_id"] = chancellor_id
	_expect(not chancellor_id.is_empty(), "seeded chancellor exists")
	var pair: Array[String] = []
	for source_variant in host.get("_city_markers_by_id"):
		var marker = host.get("_city_markers_by_id")[source_variant]
		if not marker.neighbors.is_empty():
			pair = [str(source_variant), str(marker.neighbors[0])]
			break
	_expect(pair.size() == 2, "auto-trade connected pair exists")
	if chancellor_id.is_empty() or pair.size() != 2:
		quit(1)
		return
	var source := pair[0]
	var target := pair[1]
	var player_faction := str(host.call("_get_current_player_faction_id"))
	host.get("_city_markers_by_id")[source].owner_faction_id = player_faction
	host.get("_city_markers_by_id")[target].owner_faction_id = player_faction
	state["owned_city_ids"] = [source, target]
	state["last_chancellor_auto_trade_turn"] = 0
	state["chancellor_policy_id"] = "balanced"
	host.set("_trade_control_modes", {"internal_trade": "chancellor", "external_trade": "manual"})
	host.call("_set_city_storage", source, {"gold": 500, "rice": 400, "barley": 300, "seafood": 200, "wood": 200, "iron": 200, "horses": 200, "silk": 200, "salt": 200})
	host.call("_set_city_storage", target, {"gold": 0, "rice": 0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0})
	var total_before := int(_storage(host, source).get("gold", 0)) + int(_storage(host, target).get("gold", 0))
	var result: Dictionary = host.call("_apply_chancellor_auto_trade_for_world_turn", 902)
	_expect(bool(result.get("ok", false)), "successful execution")
	_expect(bool(result.get("internal", {}).get("enabled", false)) and not bool(result.get("external", {}).get("enabled", true)), "control-mode parity")
	_expect(int(result.get("internal", {}).get("total_moved", 0)) <= 200, "turn amount cap")
	_expect(not (result.get("internal", {}).get("applied", []) as Array).is_empty(), "shortage/surplus candidate selected")
	_expect(int(_storage(host, source).get("gold", 0)) + int(_storage(host, target).get("gold", 0)) == total_before, "internal auto-trade conservation")
	_expect(host.get("_player_state").get("last_chancellor_auto_trade_result") == result, "result/state parity")
	_expect(controller.call("run_chancellor_auto_trade", 902) == result, "turn lifecycle parity")

	current_scene.queue_free()
	await process_frame
	await process_frame
	print("[TRADE_AUTOMATION] %s: %d checks, %d failures" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	quit(0 if _failures == 0 else 1)
