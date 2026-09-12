extends SceneTree

const SCENE_PATH := "res://WorldMap_16x9_Test.tscn"
const TRADE_RESOURCES := ["rice", "barley", "seafood", "wood", "iron", "horses", "silk", "salt"]

var _failures := 0
var _checks := 0
var _resolved := 0
var _presented := 0
var _last_result: Dictionary = {}
var _worldmap: Node
var _presentation: Node
var _baseline_state: Dictionary
var _baseline_cities: Dictionary
var _baseline_owners: Dictionary
var _source := ""
var _target := ""


func _initialize() -> void:
	call_deferred("_run")


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("[TRADE_ROUTING] FAIL: " + label)


func _prepare(gold: int = 10000) -> void:
	_worldmap.call("cancel_contextual_worldmap_action")
	_worldmap.set("_player_state", _baseline_state.duplicate(true))
	_worldmap.set("_city_runtime_states", _baseline_cities.duplicate(true))
	_worldmap.set("_manual_trade_orders", {})
	for city_id in _baseline_owners:
		_worldmap.get("_city_markers_by_id")[city_id].owner_faction_id = _baseline_owners[city_id]
	var storage := {"gold": gold}
	for resource_id in TRADE_RESOURCES:
		storage[resource_id] = 100
	_worldmap.call("_set_city_storage", _source, storage)
	var source_faction := str(_worldmap.call("_get_city_owner_faction_id_for_trade_display", _source))
	var target_faction := str(_worldmap.call("_get_city_owner_faction_id_for_trade_display", _target))
	var relation: Dictionary = _worldmap.call("_ensure_faction_relation_entry", source_faction, target_faction)
	relation["status"] = "neutral"
	relation["score"] = 50
	var relations: Dictionary = _worldmap.get("_player_state").get("faction_relations", {})
	relations[_worldmap.call("_make_faction_relation_key", source_faction, target_faction)] = relation
	_worldmap.get("_player_state")["faction_relations"] = relations


func _find_pair() -> Dictionary:
	var markers: Dictionary = _worldmap.get("_city_markers_by_id")
	for target_id in markers:
		var source_id := str(_worldmap.call("_find_contextual_trade_source_city_id", str(target_id)))
		if not source_id.is_empty():
			return {"source": source_id, "target": str(target_id)}
	return {}


func _make_order(import_amount: int = 4, export_amount: int = 10) -> Dictionary:
	var orders := {
		"rice": {"action": "export", "amount": export_amount},
		"salt": {"action": "import", "amount": import_amount},
	}
	var order := {
		"source_city_id": _source,
		"target_city_id": _target,
		"trade_type": "external",
		"mode": "manual",
		"orders": orders,
	}
	order["preview"] = _worldmap.call("_build_external_manual_trade_execution_preview", order)
	order["efficiency"] = _worldmap.call("_get_trade_efficiency_for_cities", _source, _target)
	return order


func _storage(city_id: String) -> Dictionary:
	return _worldmap.call("_get_city_storage", city_id, _worldmap.call("_get_city_hud_entry", city_id)).duplicate(true)


func _check_external_parity() -> void:
	_prepare()
	var order := _make_order()
	var target_before := _storage(_target)
	var source_before := _storage(_source)
	var initial_state: Dictionary = _worldmap.get("_player_state").duplicate(true)
	var initial_cities: Dictionary = _worldmap.get("_city_runtime_states").duplicate(true)
	var legacy: Dictionary = _worldmap.call("_execute_external_manual_trade_order_legacy", order)
	var expected_state: Dictionary = _worldmap.get("_player_state").duplicate(true)
	var expected_cities: Dictionary = _worldmap.get("_city_runtime_states").duplicate(true)
	_worldmap.set("_player_state", initial_state.duplicate(true))
	_worldmap.set("_city_runtime_states", initial_cities.duplicate(true))
	var actual: Dictionary = _worldmap.call("_execute_external_manual_trade_order", order)
	_expect(actual == legacy, "service result equals legacy result")
	_expect(_worldmap.get("_player_state") == expected_state, "service player state equals legacy")
	_expect(_worldmap.get("_city_runtime_states") == expected_cities, "service city state equals legacy")
	_expect(_storage(_target) == target_before, "external trade does not mutate target storage")
	var applied: Dictionary = actual.get("applied", {})
	_expect(int(applied.get("gold", 0)) != 0, "external trade changes gold")
	_expect(int(applied.get("rice", 0)) != 0 and int(applied.get("salt", 0)) != 0, "external trade changes food and salt")
	var source_after := _storage(_source)
	for resource_id in ["gold", "rice", "salt"]:
		_expect(int(source_after.get(resource_id, 0)) == int(source_before.get(resource_id, 0)) + int(applied.get(resource_id, 0)), "preview matches executed " + resource_id)
	for field in ["efficiency", "market_turn", "market_prices"]:
		_expect(actual.has(field), "legacy result field retained: " + field)


func _check_failure_parity() -> void:
	var invalid_orders := [
		{},
		{"source_city_id": _source, "target_city_id": _source, "orders": {"rice": {"action": "export", "amount": 1}}},
		{"source_city_id": _source, "target_city_id": _target, "orders": {}},
		{"source_city_id": _source, "target_city_id": _target, "orders": {"rice": {"action": "export", "amount": 100000}}},
		{"source_city_id": _source, "target_city_id": _target, "orders": {"unknown": {"action": "import", "amount": 1}}},
	]
	for index in invalid_orders.size():
		_prepare()
		var order: Dictionary = invalid_orders[index]
		var legacy: Dictionary = _worldmap.call("_execute_external_manual_trade_order_legacy", order)
		_prepare()
		var actual: Dictionary = _worldmap.call("_execute_external_manual_trade_order", order)
		_expect(actual == legacy, "failure parity case %d" % index)
		_expect(not bool(actual.get("ok", false)), "failure rejected case %d" % index)

	_prepare(0)
	var costly_order := _make_order(100000, 0)
	var costly_legacy: Dictionary = _worldmap.call("_execute_external_manual_trade_order_legacy", costly_order)
	_prepare(0)
	var costly_actual: Dictionary = _worldmap.call("_execute_external_manual_trade_order", costly_order)
	_expect(costly_actual == costly_legacy and costly_actual.get("reason") == "gold", "gold shortage parity")


func _check_internal_trade_unchanged() -> void:
	_prepare()
	var source_marker = _worldmap.get("_city_markers_by_id")[_source]
	var neighbor_id := str(source_marker.neighbors[0]) if not source_marker.neighbors.is_empty() else ""
	_expect(not neighbor_id.is_empty(), "internal test neighbor exists")
	if neighbor_id.is_empty():
		return
	var neighbor_marker = _worldmap.get("_city_markers_by_id")[neighbor_id]
	neighbor_marker.owner_faction_id = _worldmap.call("_get_current_player_faction_id")
	_worldmap.call("_set_city_storage", neighbor_id, {"gold": 20, "rice": 20, "salt": 20})
	var source_before := _storage(_source)
	var target_before := _storage(neighbor_id)
	var amounts := {"gold": 7, "rice": 9, "salt": 3}
	var validation: Dictionary = _worldmap.call("_validate_internal_trade_transfer", _source, neighbor_id, amounts)
	_expect(bool(validation.get("ok", false)), "domestic connected-city trade validates")
	if bool(validation.get("ok", false)):
		var result: Dictionary = _worldmap.call("_apply_internal_trade_transfer", _source, neighbor_id, amounts)
		_expect(result.get("amounts") == amounts, "domestic result retains transfer amounts")
		for resource_id in amounts:
			_expect(int(_storage(_source)[resource_id]) == int(source_before[resource_id]) - int(amounts[resource_id]), "domestic source decreases " + resource_id)
			_expect(int(_storage(neighbor_id)[resource_id]) == int(target_before[resource_id]) + int(amounts[resource_id]), "domestic target increases " + resource_id)
	var self_validation: Dictionary = _worldmap.call("_validate_internal_trade_transfer", _source, _source, {"rice": 1})
	_expect(not bool(self_validation.get("ok", false)), "self trade remains blocked")
	neighbor_marker.owner_faction_id = _baseline_owners[neighbor_id]


func _open_trade_ui() -> void:
	var markers: Dictionary = _worldmap.get("_city_markers_by_id")
	var menu := current_scene.get_node("CityActionTestController")
	menu.set("_selected_marker", markers[_target])
	(menu.get("_trade_button") as Button).pressed.emit()
	_expect(_worldmap.get("_contextual_worldmap_action_type") == "trade", "city UI opens production trade")
	var coordinator := _worldmap.get_node("DiplomacyActionCoordinator")
	_expect(bool(coordinator.call("is_active", "trade")), "shared coordinator begins trade")
	_expect(coordinator.call("get_source_city_id") == _source, "coordinator retains source city")


func _store_order_from_panel() -> Dictionary:
	var options: Dictionary = _worldmap.get("_manual_trade_action_options")
	var amounts: Dictionary = _worldmap.get("_manual_trade_amount_spinboxes")
	_worldmap.call("_select_option_by_metadata", options["rice"], "export")
	(amounts["rice"] as SpinBox).value = 10
	_worldmap.call("_select_option_by_metadata", options["salt"], "import")
	(amounts["salt"] as SpinBox).value = 4
	_worldmap.call("_on_manual_trade_order_confirm_pressed")
	var order: Dictionary = _worldmap.get("_manual_trade_orders").get(_source, {})
	_expect(not order.is_empty(), "manual order stored through production panel")
	_expect(order.get("preview") == _worldmap.call("_build_external_manual_trade_execution_preview", order), "stored preview matches execute calculation")
	return order


func _check_production_video_flow() -> void:
	_prepare()
	_open_trade_ui()
	var order := _store_order_from_panel()
	var source_before := _storage(_source)
	_worldmap.call("_on_manual_trade_execution_button_pressed")
	_expect(_presented == 1 and _resolved == 0, "presentation precedes execution")
	_expect(_presentation.get_node("VideoOverlay").visible, "real trade video starts")
	_expect(_storage(_source) == source_before, "no mutation before video completion")
	_worldmap.call("_on_manual_trade_execution_button_pressed")
	_expect(_presented == 1, "duplicate click does not request another video")
	var wrong_target: Dictionary = _worldmap.call("complete_contextual_worldmap_action", "trade", "external_manual_trade", _source)
	_expect(not bool(wrong_target.get("success", false)), "changed target rejected")
	var wrong_action: Dictionary = _worldmap.call("complete_contextual_worldmap_action", "trade", "changed_order", _target)
	_expect(not bool(wrong_action.get("success", false)), "changed action rejected")
	await create_timer(8.0).timeout
	_expect(_resolved == 1, "video completion resolves once")
	_expect(_presentation.get_node("ResultOverlay").visible, "trade result shown immediately")
	_expect(not _worldmap.get("_manual_trade_orders").has(_source), "successful order removed")
	_expect(_last_result.get("applied") == order.get("preview"), "production mutation matches stored preview")
	_worldmap.call("complete_contextual_worldmap_action", "trade", "external_manual_trade", _target)
	_expect(_resolved == 1, "duplicate completion ignored")


func _check_cancel_escape_and_failure() -> void:
	_prepare()
	_open_trade_ui()
	_store_order_from_panel()
	_worldmap.call("_on_manual_trade_execution_button_pressed")
	var escape := InputEventKey.new()
	escape.keycode = KEY_ESCAPE
	escape.pressed = true
	_presentation.call("_unhandled_input", escape)
	_expect(_resolved == 2, "Escape completes trade presentation")

	_prepare()
	_open_trade_ui()
	_store_order_from_panel()
	var before_cancel := _storage(_source)
	_worldmap.call("_on_manual_trade_execution_button_pressed")
	_worldmap.call("cancel_contextual_worldmap_action")
	_presentation.call("_finish_pending_video")
	_expect(_resolved == 2, "cancelled context cannot execute")
	_expect(_storage(_source) == before_cancel, "cancel does not mutate storage")
	_expect(_worldmap.get("_manual_trade_orders").has(_source), "cancel preserves order")

	_prepare()
	_open_trade_ui()
	var order := _store_order_from_panel()
	_worldmap.call("_on_manual_trade_execution_button_pressed")
	var depleted := _storage(_source)
	depleted["gold"] = 0
	_worldmap.call("_set_city_storage", _source, depleted)
	_presentation.call("_finish_pending_video")
	_expect(_resolved == 3 and _last_result.get("reason") == "gold", "resources revalidated after video")
	_expect(_storage(_source) == depleted, "failed execution does not partially mutate storage")
	_expect(_worldmap.get("_manual_trade_orders").get(_source) == order, "failed order preserved")
	_expect(_presentation.get_node("ResultOverlay").visible, "failure result shown")


func _run() -> void:
	change_scene_to_file(SCENE_PATH)
	await process_frame
	await process_frame
	_worldmap = current_scene.get_node("ProductionWorldMap")
	_presentation = current_scene.get_node("ActionPresentationController")
	_baseline_state = _worldmap.get("_player_state").duplicate(true)
	_baseline_cities = _worldmap.get("_city_runtime_states").duplicate(true)
	_baseline_owners = {}
	for city_id in _worldmap.get("_city_markers_by_id"):
		_baseline_owners[city_id] = _worldmap.get("_city_markers_by_id")[city_id].owner_faction_id
		if not _baseline_cities.has(city_id):
			_baseline_cities[city_id] = _worldmap.call("_get_city_hud_entry", city_id).duplicate(true)
	var pair := _find_pair()
	_source = str(pair.get("source", ""))
	_target = str(pair.get("target", ""))
	_expect(not _source.is_empty() and not _target.is_empty(), "external player/foreign trade pair exists")
	if _source.is_empty() or _target.is_empty():
		quit(1)
		return
	_worldmap.connect("contextual_worldmap_action_resolved", func(type: String, result: Dictionary) -> void:
		if type == "trade":
			_resolved += 1
			_last_result = result.duplicate(true)
	)
	_worldmap.connect("contextual_worldmap_action_presentation_requested", func(type: String, _id: String, _city: String) -> void:
		if type == "trade": _presented += 1
	)

	_check_external_parity()
	_check_failure_parity()
	_check_internal_trade_unchanged()
	await _check_production_video_flow()
	_check_cancel_escape_and_failure()

	await create_timer(2.2).timeout
	current_scene.queue_free()
	await process_frame
	await process_frame
	print("[TRADE_ROUTING] %s: %d checks, %d failures" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	quit(0 if _failures == 0 else 1)
