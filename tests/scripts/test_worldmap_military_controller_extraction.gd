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
		push_error("[MILITARY_CONTROLLER] FAIL: " + label)


func _run() -> void:
	change_scene_to_file(SCENE_PATH)
	await process_frame
	await process_frame
	var host := current_scene.get_node("ProductionWorldMap")
	var controller: RefCounted = host.call("_ensure_military_controller")
	_expect(controller != null, "Controller constructed")
	_expect(host.call("_ensure_military_controller") == controller, "Controller is not duplicated")
	_expect(int(controller.call("calculate_troop_move_arrived_amount", 100, 75)) == 75, "Troop arrival rule moved")
	_expect(host.call("_calculate_troop_move_arrived_amount", 100, 75) == 75, "Arrival wrapper parity")
	_expect(controller.call("calculate_recruitment_cost", 100) == {"gold": 100, "food": 50}, "Recruitment cost rule moved")
	_expect(host.call("_calculate_recruitment_cost", 100) == {"gold": 100, "food": 50}, "Recruitment wrapper parity")
	_expect(not bool(host.call("_can_move_troops", "", "", 0).get("ok", true)), "Invalid troop move rejected")
	_expect(not bool(host.call("_can_recruit_troops", "", 100).get("ok", true)), "Invalid recruitment rejected")

	var state: Dictionary = host.get("_player_state")
	var owned_city_ids: Variant = state.get("owned_city_ids", [])
	if owned_city_ids is Array and not (owned_city_ids as Array).is_empty():
		var city_id := str((owned_city_ids as Array)[0])
		_expect(
			host.call("_get_conscription_capacity_by_loyalty", city_id) == controller.call("get_conscription_capacity_by_loyalty", city_id),
			"Conscription capacity wrapper parity"
		)
		host.call("_set_city_loyalty_value", city_id, 90)
		state["resource_stock"] = {"gold": 1000, "rice": 1000, "barley": 0, "seafood": 0}
		var before_troops := int(host.call("_get_city_troops_for_battle_context", city_id))
		_expect(bool(host.call("_can_recruit_troops", city_id, 100).get("ok", false)), "Valid recruitment accepted")
		_expect(bool(host.call("_recruit_troops", city_id, 100)), "Recruitment mutation routed")
		_expect(int(host.call("_get_city_troops_for_battle_context", city_id)) == before_troops + 100, "Recruitment troop delta preserved")
		var marker: Variant = (host.get("_city_markers_by_id") as Dictionary).get(city_id)
		var neighbors: Variant = marker.get("neighbors") if marker != null else []
		if neighbors is Array and not (neighbors as Array).is_empty():
			var target_city_id := str((neighbors as Array)[0])
			host.call("_set_city_runtime_owner", target_city_id, host.call("_get_current_player_faction_id"))
			host.call("_set_city_runtime_troops", city_id, 1000)
			host.call("_set_city_runtime_troops", target_city_id, 100)
			host.call("_set_city_loyalty_value", city_id, 100)
			var total_before := int(host.call("_get_world_city_troop_total"))
			_expect(bool(host.call("_can_move_troops", city_id, target_city_id, 100).get("ok", false)), "Valid connected troop move accepted")
			_expect(bool(host.call("_move_troops", city_id, target_city_id, 100)), "Troop movement mutation routed")
			_expect(int(host.call("_get_city_troops_for_battle_context", city_id)) == 900, "Source troop delta preserved")
			_expect(int(host.call("_get_city_troops_for_battle_context", target_city_id)) == 200, "Target troop delta preserved")
			_expect(int(host.call("_get_world_city_troop_total")) == total_before, "100 loyalty movement conserves troops")

	current_scene.queue_free()
	await process_frame
	await process_frame
	print("[MILITARY_CONTROLLER] %s: %d checks, %d failures" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	quit(0 if _failures == 0 else 1)
