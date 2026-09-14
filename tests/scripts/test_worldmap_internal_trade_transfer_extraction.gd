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
		push_error("[INTERNAL_TRADE_TRANSFER] FAIL: " + label)


func _storage(host: Node, city_id: String) -> Dictionary:
	return host.call("_get_city_storage", city_id, host.call("_get_city_hud_entry", city_id)).duplicate(true)


func _run() -> void:
	change_scene_to_file(SCENE_PATH)
	await process_frame
	await process_frame
	var host := current_scene.get_node("ProductionWorldMap")
	var controller: RefCounted = host.call("_ensure_trade_controller")
	var source := ""
	var target := ""
	for source_variant in host.get("_city_markers_by_id"):
		var marker = host.get("_city_markers_by_id")[source_variant]
		if not marker.neighbors.is_empty():
			source = str(source_variant)
			target = str(marker.neighbors[0])
			break
	_expect(not source.is_empty() and not target.is_empty(), "connected city pair exists")
	if source.is_empty() or target.is_empty():
		quit(1)
		return
	var player_faction := str(host.call("_get_current_player_faction_id"))
	var source_marker = host.get("_city_markers_by_id")[source]
	var target_marker = host.get("_city_markers_by_id")[target]
	var source_owner: String = source_marker.owner_faction_id
	var target_owner: String = target_marker.owner_faction_id
	source_marker.owner_faction_id = player_faction
	target_marker.owner_faction_id = player_faction
	host.call("_set_city_storage", source, {"gold": 50, "rice": 40, "salt": 9})
	host.call("_set_city_storage", target, {"gold": 5, "rice": 7, "salt": 1})

	_expect(not bool(controller.call("validate_internal_transfer", "", target, {"rice": 1}).get("ok", false)), "source validation")
	_expect(not bool(controller.call("validate_internal_transfer", source, "", {"rice": 1}).get("ok", false)), "target validation")
	_expect(not bool(controller.call("validate_internal_transfer", source, source, {"rice": 1}).get("ok", false)), "same-city rejection")
	target_marker.owner_faction_id = "foreign_test"
	_expect(not bool(controller.call("validate_internal_transfer", source, target, {"rice": 1}).get("ok", false)), "player ownership validation")
	target_marker.owner_faction_id = player_faction
	_expect(not bool(controller.call("validate_internal_transfer", source, target, {"unknown": 1}).get("ok", false)), "invalid resource")
	_expect(not bool(controller.call("validate_internal_transfer", source, target, {"rice": -1}).get("ok", false)), "invalid amount")
	_expect(not bool(controller.call("validate_internal_transfer", source, target, {"rice": 41}).get("ok", false)), "insufficient stock")
	_expect(not bool(controller.call("validate_internal_transfer", source, target, {}).get("ok", false)), "empty transfer")

	var before_source := _storage(host, source)
	var before_target := _storage(host, target)
	var amounts := {"gold": 3, "rice": 11, "salt": 2}
	var result: Dictionary = controller.call("execute_internal_transfer", source, target, amounts)
	_expect(result.get("amounts") == amounts and result.get("mode") == "manual_transfer", "result parity")
	for resource_id in amounts:
		var moved := int(amounts[resource_id])
		_expect(int(_storage(host, source)[resource_id]) == int(before_source[resource_id]) - moved, "source deduction " + resource_id)
		_expect(int(_storage(host, target)[resource_id]) == int(before_target[resource_id]) + moved, "target addition " + resource_id)
		_expect(int(_storage(host, source)[resource_id]) + int(_storage(host, target)[resource_id]) == int(before_source[resource_id]) + int(before_target[resource_id]), "transfer conservation " + resource_id)
	_expect(host.get("_player_state").get("last_internal_trade_transfer_result") == result, "state replacement")
	_expect(host.call("_validate_internal_trade_transfer", source, target, {"rice": 1}) == controller.call("validate_internal_transfer", source, target, {"rice": 1}), "main validation thin bridge")

	source_marker.owner_faction_id = source_owner
	target_marker.owner_faction_id = target_owner
	current_scene.queue_free()
	await process_frame
	await process_frame
	print("[INTERNAL_TRADE_TRANSFER] %s: %d checks, %d failures" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	quit(0 if _failures == 0 else 1)
