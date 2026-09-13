extends SceneTree

const SCENE_PATH := "res://WorldMap_16x9_Test.tscn"
const RESOURCES := ["rice", "barley", "seafood", "wood", "iron", "horses", "silk", "salt"]

var _checks := 0
var _failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("[TRADE_CONTROLLER] FAIL: " + label)


func _storage(host: Node, city_id: String) -> Dictionary:
	return host.call("_get_city_storage", city_id, host.call("_get_city_hud_entry", city_id)).duplicate(true)


func _run() -> void:
	change_scene_to_file(SCENE_PATH)
	await process_frame
	await process_frame
	var host := current_scene.get_node("ProductionWorldMap")
	var controller: RefCounted = host.call("_ensure_trade_controller")
	var presenter: RefCounted = host.call("_ensure_trade_presenter")
	var coordinator := host.call("_ensure_diplomacy_action_coordinator") as Node
	_expect(controller != null, "Controller constructed")
	_expect(presenter != null, "Presenter constructed")
	_expect(coordinator.get("_trade_controller") == controller, "Coordinator receives the Controller")
	_expect(coordinator.get("_spy_service") != null, "Spy owner remains unchanged")

	var source := ""
	var target := ""
	for target_variant in host.get("_city_markers_by_id"):
		var candidate := str(host.call("_find_contextual_trade_source_city_id", str(target_variant)))
		if not candidate.is_empty():
			source = candidate
			target = str(target_variant)
			break
	_expect(not source.is_empty() and not target.is_empty(), "Trade pair resolved")
	if source.is_empty():
		quit(1)
		return

	var storage := {"gold": 10000}
	for resource_id in RESOURCES:
		storage[resource_id] = 100
	host.call("_set_city_storage", source, storage)
	var source_faction := str(host.call("_get_city_owner_faction_id_for_trade_display", source))
	var target_faction := str(host.call("_get_city_owner_faction_id_for_trade_display", target))
	var relation: Dictionary = host.call("_ensure_faction_relation_entry", source_faction, target_faction)
	relation["status"] = "neutral"
	relation["score"] = 50
	var state: Dictionary = host.get("_player_state")
	state["faction_relations"][host.call("_make_faction_relation_key", source_faction, target_faction)] = relation

	var order := {
		"source_city_id": source,
		"target_city_id": target,
		"trade_type": "external",
		"mode": "manual",
		"orders": {"rice": {"action": "export", "amount": 10}, "salt": {"action": "import", "amount": 4}},
	}
	var preview: Dictionary = controller.call("build_external_manual_trade_execution_preview", order)
	order["preview"] = preview.duplicate(true)
	order["efficiency"] = float(preview.get("efficiency", 0.0))
	_expect(bool(controller.call("validate_external_manual_trade_execution", order).get("ok", false)), "Valid order accepted")
	_expect(not bool(controller.call("validate_external_manual_trade_execution", {}).get("ok", false)), "Missing order rejected")
	var invalid_target := order.duplicate(true)
	invalid_target["target_city_id"] = source
	_expect(controller.call("validate_external_manual_trade_execution", invalid_target).get("reason") == "target_invalid", "Invalid target rejected")
	_expect(int(preview.get("rice", 0)) == -10 and int(preview.get("salt", 0)) == 4, "Preview resource parity")
	_expect(int(preview.get("gold", 0)) != 0, "Preview price calculation")
	_expect(float(preview.get("efficiency", 0.0)) == float(controller.call("get_trade_efficiency_for_cities", source, target)), "Efficiency query parity")
	_expect(controller.call("calculate_trade_import_cost", "salt", 4, float(preview["efficiency"])) > 0, "Import rule owned by Service")
	_expect(controller.call("calculate_trade_export_gain", "rice", 10, float(preview["efficiency"])) > 0, "Export rule owned by Service")

	controller.call("store_manual_trade_order", order)
	_expect(controller.call("get_manual_trade_order", source) == order, "Manual order stored")
	var before := _storage(host, source)
	var result: Dictionary = coordinator.call("execute_trade_order", order)
	_expect(bool(result.get("ok", false)), "Coordinator execute_trade_order succeeds")
	_expect(result.get("applied") == preview, "Result dictionary keeps preview")
	_expect(result.has("market_prices") and result.has("market_turn"), "Market snapshot retained")
	_expect(controller.call("get_manual_trade_order", source).is_empty(), "Successful order consumed")
	_expect(host.get("_player_state").get("last_external_manual_trade_execution_result") == result, "Last result mirrored")
	for resource_id in ["gold", "rice", "salt"]:
		_expect(int(_storage(host, source)[resource_id]) == int(before[resource_id]) + int(preview[resource_id]), "Storage mutation " + resource_id)

	controller.call("store_manual_trade_order", order)
	var depleted := _storage(host, source)
	depleted["gold"] = 0
	host.call("_set_city_storage", source, depleted)
	var failed: Dictionary = coordinator.call("execute_trade_order", order)
	_expect(not bool(failed.get("ok", false)) and failed.get("reason") == "gold", "Failure revalidates live storage")
	_expect(not controller.call("get_manual_trade_order", source).is_empty(), "Failed order retained")
	_expect(_storage(host, source) == depleted, "Failure has no partial mutation")

	var normalized: Dictionary = controller.call("normalize_manual_trade_orders", {source: order, "missing": {}})
	_expect(normalized.has(source) and not normalized.has("missing"), "Save payload normalization")
	controller.call("sync_persistence_to_player_state")
	_expect(host.get("_player_state").get("manual_trade_orders") == host.get("_manual_trade_orders"), "Save sync parity")
	host.set("_manual_trade_orders", {})
	controller.call("restore_persistence_from_player_state")
	_expect(not controller.call("get_manual_trade_order", source).is_empty(), "Load restore parity")

	var preview_text := str(presenter.call("format_manual_trade_preview_summary", preview))
	_expect(preview_text.contains("효율") and preview_text.contains("금전"), "Preview presentation parity")
	var presentation_targets: Array[String] = [target]
	var order_text := str(presenter.call("format_external_trade_manual_order_summary", source, presentation_targets))
	_expect(order_text.contains("수동 무역"), "Order presentation parity")
	_expect(str(presenter.call("format_trade_market_prices_for_external_trade_ui")).contains("시장가"), "Market presentation parity")
	_expect(host.call("_get_trade_efficiency_for_cities", source, target) == controller.call("get_trade_efficiency_for_cities", source, target), "Diplomacy agreement boundary parity")

	current_scene.queue_free()
	await process_frame
	await process_frame
	print("[TRADE_CONTROLLER] %s: %d checks, %d failures" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	quit(0 if _failures == 0 else 1)
