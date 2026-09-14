class_name WorldMapTradeController
extends RefCounted

const TradeActionServiceScript := preload("res://scripts/worldmap/actions/trade_action_service.gd")
const TradeAutomationServiceScript := preload("res://scripts/worldmap/actions/trade_automation_service.gd")
const InternalTradeTransferServiceScript := preload("res://scripts/worldmap/actions/internal_trade_transfer_service.gd")
const TRADE_CONTROL_MODE_CHANCELLOR := "chancellor"
const TRADE_CONTROL_MODE_MANUAL := "manual"
const INTERNAL_TRADE_TAB := "internal_trade"
const EXTERNAL_TRADE_TAB := "external_trade"
const RESOURCE_DISPLAY_ORDER := ["rice", "barley", "seafood", "wood", "iron", "horses", "silk", "salt", "gold"]

var _host: Node
var _action_service = TradeActionServiceScript.new()
var _automation_service = TradeAutomationServiceScript.new()
var _internal_transfer_service = InternalTradeTransferServiceScript.new()


func configure(host: Node) -> void:
	_host = host


func execute(_action_id: String, _target_city_id: String, source_city_id: String = "") -> Dictionary:
	if source_city_id.is_empty():
		return {"ok": false, "success": false, "reason": "missing_source", "message": "교역 출발 도시를 확인할 수 없습니다."}
	return execute_order(get_manual_trade_order(source_city_id))


func execute_order(order: Dictionary) -> Dictionary:
	var result := _action_service.execute_order(self, order, _build_external_manual_trade_execution_context(order))
	_record_manual_trade_execution_result(order, result)
	return result


func validate_external_manual_trade_execution(order: Dictionary) -> Dictionary:
	return _action_service.validate_order(order, _build_external_manual_trade_execution_context(order))


func build_external_manual_trade_execution_preview(order: Dictionary) -> Dictionary:
	return _action_service.build_preview(order, _build_external_manual_trade_execution_context(order))


func get_trade_efficiency_for_cities(source_city_id: String, target_city_id: String) -> float:
	if source_city_id.is_empty() or target_city_id.is_empty():
		return 0.0
	var source_faction_id := _get_city_owner_faction_id_for_trade_display(source_city_id)
	var target_faction_id := _get_city_owner_faction_id_for_trade_display(target_city_id)
	if not _can_trade_between_factions(source_faction_id, target_faction_id):
		return 0.0
	return _action_service.normalize_efficiency(_get_trade_relation_multiplier(source_faction_id, target_faction_id))


func calculate_trade_import_cost(resource_id: String, amount: int, efficiency: float) -> int:
	return _action_service.calculate_import_cost(_get_trade_market_price(resource_id), amount, efficiency)


func calculate_trade_export_gain(resource_id: String, amount: int, efficiency: float) -> int:
	return _action_service.calculate_export_gain(_get_trade_market_price(resource_id), amount, efficiency)


func run_chancellor_auto_trade(turn_number: int) -> Dictionary:
	return _automation_service.run_chancellor_auto_trade(self, turn_number)


func validate_internal_transfer(source_city_id: String, target_city_id: String, amounts: Dictionary) -> Dictionary:
	return _internal_transfer_service.validate_transfer(self, source_city_id, target_city_id, amounts)


func execute_internal_transfer(source_city_id: String, target_city_id: String, amounts: Dictionary) -> Dictionary:
	return _internal_transfer_service.execute_transfer(self, source_city_id, target_city_id, amounts)


func get_manual_trade_order(source_city_id: String) -> Dictionary:
	var order: Variant = _get_manual_trade_orders().get(source_city_id, {})
	return (order as Dictionary).duplicate(true) if order is Dictionary else {}


func store_manual_trade_order(order: Dictionary) -> void:
	var source_city_id := str(order.get("source_city_id", ""))
	if source_city_id.is_empty():
		return
	var orders := _get_manual_trade_orders()
	orders[source_city_id] = order.duplicate(true)
	_set_manual_trade_orders(orders)


func normalize_trade_control_modes(raw_modes: Variant) -> Dictionary:
	var modes := {INTERNAL_TRADE_TAB: TRADE_CONTROL_MODE_CHANCELLOR, EXTERNAL_TRADE_TAB: TRADE_CONTROL_MODE_CHANCELLOR}
	if not raw_modes is Dictionary:
		return modes
	for tab_id in modes:
		var mode := str((raw_modes as Dictionary).get(tab_id, modes[tab_id]))
		modes[tab_id] = mode if [TRADE_CONTROL_MODE_CHANCELLOR, TRADE_CONTROL_MODE_MANUAL].has(mode) else TRADE_CONTROL_MODE_CHANCELLOR
	return modes


func normalize_manual_trade_orders(raw_orders: Variant) -> Dictionary:
	var normalized := {}
	if not raw_orders is Dictionary:
		return normalized
	for source_variant in (raw_orders as Dictionary):
		var source_city_id := str(source_variant)
		var order := normalize_manual_trade_order_payload((raw_orders as Dictionary).get(source_variant, {}), source_city_id)
		if order.is_empty():
			print("[TRADE_SAVE_LOAD] dropped invalid manual trade order for source=%s" % source_city_id)
			continue
		normalized[str(order.get("source_city_id", source_city_id))] = order
	return normalized


func normalize_manual_trade_order_payload(raw_order: Variant, source_city_id: String = "") -> Dictionary:
	if not raw_order is Dictionary:
		return {}
	var raw := raw_order as Dictionary
	var resolved_source := str(raw.get("source_city_id", source_city_id))
	var target_city_id := str(raw.get("target_city_id", ""))
	if resolved_source.is_empty() or target_city_id.is_empty():
		return {}
	if not _has_worldmap_city(resolved_source) or not _has_worldmap_city(target_city_id) or not _is_city_owned_by_player(resolved_source):
		return {}
	var candidates := _get_external_trade_candidate_city_ids(resolved_source)
	if not candidates.is_empty() and not candidates.has(target_city_id):
		return {}
	var items := normalize_manual_trade_order_items(raw.get("orders", {}))
	if items.is_empty():
		return {}
	var order := {"source_city_id": resolved_source, "target_city_id": target_city_id, "orders": items}
	var preview := build_external_manual_trade_execution_preview(order)
	return {
		"source_city_id": resolved_source,
		"target_city_id": target_city_id,
		"trade_type": "external",
		"mode": TRADE_CONTROL_MODE_MANUAL,
		"orders": items,
		"preview": preview,
		"efficiency": float(preview.get("efficiency", 0.0)),
	}


func normalize_manual_trade_order_items(raw_items: Variant) -> Dictionary:
	var normalized := {}
	if not raw_items is Dictionary:
		return normalized
	for resource_id in TradeActionServiceScript.TRADE_RESOURCE_ORDER:
		var item: Variant = (raw_items as Dictionary).get(resource_id, {})
		if not item is Dictionary:
			continue
		var action := str((item as Dictionary).get("action", TradeActionServiceScript.ACTION_NONE))
		var amount := maxi(0, int((item as Dictionary).get("amount", 0)))
		if [TradeActionServiceScript.ACTION_IMPORT, TradeActionServiceScript.ACTION_EXPORT].has(action) and amount > 0:
			normalized[resource_id] = {"action": action, "amount": amount}
	return normalized


func normalize_trade_result_payload(raw_result: Variant) -> Dictionary:
	if not raw_result is Dictionary:
		return {}
	var normalized := (raw_result as Dictionary).duplicate(true)
	for key in ["applied", "preview", "amounts"]:
		if normalized.has(key):
			if normalized[key] is Dictionary:
				normalized[key] = normalize_trade_delta_payload(normalized[key])
			else:
				normalized.erase(key)
	return normalized


func normalize_trade_delta_payload(raw_delta: Variant) -> Dictionary:
	var normalized := {}
	if raw_delta is Dictionary:
		for resource_id in RESOURCE_DISPLAY_ORDER:
			if (raw_delta as Dictionary).has(resource_id):
				normalized[resource_id] = int((raw_delta as Dictionary).get(resource_id, 0))
	return normalized


func normalize_chancellor_auto_trade_result_payload(raw_result: Variant) -> Dictionary:
	if not raw_result is Dictionary:
		return {}
	var normalized := (raw_result as Dictionary).duplicate(true)
	normalized["turn"] = maxi(0, int(normalized.get("turn", 0)))
	if normalized.get("internal") is Dictionary:
		normalized["internal"] = _normalize_chancellor_auto_trade_section_payload(normalized["internal"], true)
	if normalized.get("external") is Dictionary:
		normalized["external"] = _normalize_chancellor_auto_trade_section_payload(normalized["external"], false)
	return normalized


func _normalize_chancellor_auto_trade_section_payload(raw_section: Variant, internal: bool) -> Dictionary:
	var section := {"enabled": false, "applied": []}
	if not raw_section is Dictionary:
		return section
	section["enabled"] = bool((raw_section as Dictionary).get("enabled", false))
	for item_variant in (raw_section as Dictionary).get("applied", []):
		if item_variant is Dictionary:
			var item := (item_variant as Dictionary).duplicate(true)
			var key := "amounts" if internal else "applied"
			item[key] = normalize_trade_delta_payload(item.get(key, {}))
			if not internal and item.has("efficiency"):
				item["efficiency"] = clampf(float(item["efficiency"]), 0.0, TradeActionServiceScript.EFFICIENCY_MAX)
			section["applied"].append(item)
	if (raw_section as Dictionary).has("total_moved"):
		section["total_moved"] = maxi(0, int((raw_section as Dictionary).get("total_moved", 0)))
	return section


func sync_persistence_to_player_state() -> void:
	_host.call("_ensure_trade_market_for_current_turn")
	var modes := normalize_trade_control_modes(_host.get("_trade_control_modes"))
	var orders := normalize_manual_trade_orders(_get_manual_trade_orders())
	_host.set("_trade_control_modes", modes)
	_set_manual_trade_orders(orders)
	var state := _get_player_state()
	state["trade_control_modes"] = modes.duplicate(true)
	state["manual_trade_orders"] = orders.duplicate(true)
	state["last_external_manual_trade_execution_result"] = normalize_trade_result_payload(state.get("last_external_manual_trade_execution_result", {}))
	state["last_internal_trade_transfer_result"] = normalize_trade_result_payload(state.get("last_internal_trade_transfer_result", {}))
	state["last_chancellor_auto_trade_result"] = normalize_chancellor_auto_trade_result_payload(state.get("last_chancellor_auto_trade_result", {}))
	state["last_chancellor_auto_trade_turn"] = maxi(0, int(state.get("last_chancellor_auto_trade_turn", 0)))
	_set_player_state(state)


func restore_persistence_from_player_state() -> void:
	var state := _get_player_state()
	var modes := normalize_trade_control_modes(state.get("trade_control_modes", {}))
	_host.set("_trade_control_modes", modes)
	state["last_trade_market_result"] = _host.call("_normalize_trade_market_result", state.get("last_trade_market_result", {}))
	_set_player_state(state)
	_host.call("_sync_trade_market_mirror_from_result", state["last_trade_market_result"])
	_host.call("_ensure_trade_market_for_current_turn")
	state = _get_player_state()
	var orders := normalize_manual_trade_orders(state.get("manual_trade_orders", {}))
	_set_manual_trade_orders(orders)
	state["trade_control_modes"] = modes.duplicate(true)
	state["manual_trade_orders"] = orders.duplicate(true)
	state["last_external_manual_trade_execution_result"] = normalize_trade_result_payload(state.get("last_external_manual_trade_execution_result", {}))
	state["last_internal_trade_transfer_result"] = normalize_trade_result_payload(state.get("last_internal_trade_transfer_result", {}))
	state["last_chancellor_auto_trade_result"] = normalize_chancellor_auto_trade_result_payload(state.get("last_chancellor_auto_trade_result", {}))
	state["last_chancellor_auto_trade_turn"] = maxi(0, int(state.get("last_chancellor_auto_trade_turn", 0)))
	_set_player_state(state)


func _record_manual_trade_execution_result(order: Dictionary, result: Dictionary) -> void:
	var player_state := _get_player_state()
	player_state["last_external_manual_trade_execution_result"] = result.duplicate(true)
	_set_player_state(player_state)
	if bool(result.get("ok", false)):
		var orders := _get_manual_trade_orders()
		orders.erase(str(order.get("source_city_id", "")))
		_set_manual_trade_orders(orders)


func _build_external_manual_trade_execution_context(order: Dictionary) -> Dictionary:
	var source_city_id := str(order.get("source_city_id", ""))
	var target_city_id := str(order.get("target_city_id", ""))
	var source_faction_id := _get_city_owner_faction_id_for_trade_display(source_city_id)
	var target_faction_id := _get_city_owner_faction_id_for_trade_display(target_city_id)
	return {
		"source_owned": _is_city_owned_by_player(source_city_id),
		"target_candidate": _get_external_trade_candidate_city_ids(source_city_id).has(target_city_id),
		"source_faction_id": source_faction_id,
		"target_faction_id": target_faction_id,
		"can_trade": _can_trade_between_factions(source_faction_id, target_faction_id),
		"efficiency": get_trade_efficiency_for_cities(source_city_id, target_city_id),
		"source_storage": _get_city_storage(source_city_id, _get_city_hud_entry(source_city_id)),
		"market_turn": int(_get_player_state().get("trade_market_turn", 0)),
		"market_prices": _get_trade_market_price_snapshot_for_order(order),
	}


# Explicit bridges into generic worldmap, city/economy, and diplomacy state.
func _get_player_state() -> Dictionary:
	var value: Variant = _host.get("_player_state")
	return value as Dictionary if value is Dictionary else {}


func get_player_state() -> Dictionary:
	return _get_player_state()


func _set_player_state(value: Dictionary) -> void:
	_host.set("_player_state", value)


func _get_manual_trade_orders() -> Dictionary:
	var value: Variant = _host.get("_manual_trade_orders")
	return (value as Dictionary).duplicate(true) if value is Dictionary else {}


func _set_manual_trade_orders(value: Dictionary) -> void:
	_host.set("_manual_trade_orders", value)


func _is_city_owned_by_player(city_id: String) -> bool:
	return bool(_host.call("_is_city_owned_by_player_mvp", city_id))


func is_city_owned_by_player(city_id: String) -> bool:
	return _is_city_owned_by_player(city_id)


func _get_external_trade_candidate_city_ids(source_city_id: String) -> Array[String]:
	var value: Variant = _host.call("_get_external_trade_candidate_city_ids", source_city_id)
	var result: Array[String] = []
	if value is Array:
		for city_id in value:
			result.append(str(city_id))
	return result


func get_external_trade_candidate_city_ids(source_city_id: String) -> Array[String]:
	return _get_external_trade_candidate_city_ids(source_city_id)


func _get_city_owner_faction_id_for_trade_display(city_id: String) -> String:
	return str(_host.call("_get_city_owner_faction_id_for_trade_display", city_id))


func get_city_owner_faction_id(city_id: String) -> String:
	return _get_city_owner_faction_id_for_trade_display(city_id)


func _can_trade_between_factions(source_faction_id: String, target_faction_id: String) -> bool:
	return bool(_host.call("_can_trade_between_factions", source_faction_id, target_faction_id))


func can_trade_between_factions(source_faction_id: String, target_faction_id: String) -> bool:
	return _can_trade_between_factions(source_faction_id, target_faction_id)


func _get_trade_relation_multiplier(source_faction_id: String, target_faction_id: String) -> float:
	return float(_host.call("_get_trade_relation_multiplier_for_ui", source_faction_id, target_faction_id))


func _get_city_hud_entry(city_id: String) -> Dictionary:
	var value: Variant = _host.call("_get_city_hud_entry", city_id)
	return value as Dictionary if value is Dictionary else {}


func _get_city_storage(city_id: String, city_data: Dictionary) -> Dictionary:
	var value: Variant = _host.call("_get_city_storage", city_id, city_data)
	return value as Dictionary if value is Dictionary else {}


func get_city_storage(city_id: String) -> Dictionary:
	return _get_city_storage(city_id, _get_city_hud_entry(city_id))


func set_city_storage(city_id: String, storage: Dictionary) -> void:
	_host.call("_set_city_storage", city_id, storage)


func _get_trade_market_price_snapshot_for_order(order: Dictionary) -> Dictionary:
	var value: Variant = _host.call("_get_trade_market_price_snapshot_for_order", order)
	return value as Dictionary if value is Dictionary else {}


func _get_trade_market_price(resource_id: String) -> int:
	return int(_host.call("_get_trade_market_price", resource_id))


func get_trade_market_turn() -> int:
	return maxi(0, int(_get_player_state().get("trade_market_turn", 0)))


func get_trade_market_price_snapshot_for_delta(delta: Dictionary) -> Dictionary:
	var value: Variant = _host.call("_get_trade_market_price_snapshot_for_delta", delta)
	return value as Dictionary if value is Dictionary else {}


func get_current_player_faction_id() -> String:
	return str(_host.call("_get_current_player_faction_id"))


func get_hero_entry(hero_id: String) -> Dictionary:
	var value: Variant = _host.call("_get_hero_entry", hero_id)
	return value as Dictionary if value is Dictionary else {}


func normalize_chancellor_policy_id(policy_id: String) -> String:
	return str(_host.call("_normalize_chancellor_policy_id", policy_id))


func is_chancellor_trade_mode_enabled(tab_id: String) -> bool:
	var raw_modes: Variant = _host.get("_trade_control_modes")
	var modes: Dictionary = raw_modes if raw_modes is Dictionary else {}
	return str(modes.get(tab_id, TRADE_CONTROL_MODE_CHANCELLOR)) == TRADE_CONTROL_MODE_CHANCELLOR


func get_player_owned_city_ids_for_trade() -> Array[String]:
	var result: Array[String] = []
	var owned_city_ids: Variant = _get_player_state().get("owned_city_ids", [])
	if not owned_city_ids is Array:
		return result
	for city_id_variant in owned_city_ids:
		var city_id := str(city_id_variant)
		if not city_id.is_empty() and not result.has(city_id) and _is_city_owned_by_player(city_id):
			result.append(city_id)
	return result


func get_internal_trade_connected_player_city_ids(source_city_id: String) -> Array[String]:
	var result: Array[String] = []
	if source_city_id.is_empty() or not _is_city_owned_by_player(source_city_id):
		return result
	var raw_markers: Variant = _host.get("_city_markers_by_id")
	if not raw_markers is Dictionary:
		return result
	var marker: Variant = (raw_markers as Dictionary).get(source_city_id)
	if marker == null:
		return result
	var neighbors: Variant = marker.get("neighbors")
	if not neighbors is Array:
		return result
	for neighbor_id_variant in neighbors:
		var neighbor_id := str(neighbor_id_variant)
		if not neighbor_id.is_empty() and _is_city_owned_by_player(neighbor_id) and not result.has(neighbor_id):
			result.append(neighbor_id)
	return result


func record_internal_trade_transfer_result(result: Dictionary) -> void:
	var state := _get_player_state()
	state["last_internal_trade_transfer_result"] = result.duplicate(true)
	_set_player_state(state)


func record_chancellor_auto_trade_result(result: Dictionary) -> void:
	var state := _get_player_state()
	var safe_turn := maxi(1, int(result.get("turn", state.get("turn_number", 1))))
	result["turn"] = safe_turn
	state["last_chancellor_auto_trade_result"] = result.duplicate(true)
	state["last_chancellor_auto_trade_turn"] = safe_turn
	_set_player_state(state)


func _has_worldmap_city(city_id: String) -> bool:
	return bool(_host.call("_has_worldmap_city_for_trade_persistence", city_id))
