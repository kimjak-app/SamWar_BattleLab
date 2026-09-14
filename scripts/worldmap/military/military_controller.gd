class_name WorldMapMilitaryController
extends RefCounted

const TROOP_MOVE_MIN_GARRISON_RATIO := 0.6
const WORLDMAP_BATTLE_CONTEXT_META_KEY := "samwar_worldmap_battle_context"
const TURN_PHASE_PLAYER := "player"

var _host: Node


func configure(host: Node) -> void:
	_host = host


func is_supply_path_between(from_id: String, to_id: String) -> bool:
	if from_id.is_empty() or to_id.is_empty():
		return false
	if from_id == to_id:
		return true
	if not _is_city_owned_by_player(from_id) or not _is_city_owned_by_player(to_id):
		return false
	var visited := {}
	var queue: Array[String] = [from_id]
	while not queue.is_empty():
		var current_city_id := str(queue.pop_front())
		if current_city_id == to_id:
			return true
		if visited.has(current_city_id):
			continue
		visited[current_city_id] = true
		var marker: Variant = _city_markers().get(current_city_id)
		if marker == null:
			continue
		var neighbors: Variant = marker.get("neighbors")
		if not neighbors is Array:
			continue
		for neighbor_id_variant in neighbors:
			var neighbor_id := str(neighbor_id_variant)
			if not visited.has(neighbor_id) and _is_city_owned_by_player(neighbor_id):
				queue.append(neighbor_id)
	return false


func get_city_min_garrison(city_id: String) -> int:
	var city_data := _get_city(city_id)
	if city_data.is_empty():
		return 0
	var required := int(_host.call("_get_city_security_required_troops", city_data))
	return maxi(0, int(round(float(required) * TROOP_MOVE_MIN_GARRISON_RATIO)))


func is_peacetime_for_troop_move() -> bool:
	if bool(_host.get("_enemy_turn_mvp_pending")):
		return false
	if bool(_host.call("_has_pending_invasion_event_mvp")):
		return false
	var pending_context: Variant = _host.call("_get_pending_battle_context_mvp")
	if pending_context is Dictionary and not (pending_context as Dictionary).is_empty():
		return false
	if Engine.has_meta(WORLDMAP_BATTLE_CONTEXT_META_KEY):
		return false
	var phase := str(_host.call("_normalize_turn_phase", str(_player_state().get("turn_phase", TURN_PHASE_PLAYER))))
	return phase == TURN_PHASE_PLAYER


func can_move_troops(from_id: String, to_id: String, amount: int) -> Dictionary:
	if amount <= 0:
		return {"ok": false, "reason": "amount"}
	if from_id == to_id:
		return {"ok": false, "reason": "same_city"}
	if not _is_city_owned_by_player(from_id) or not _is_city_owned_by_player(to_id):
		return {"ok": false, "reason": "ownership"}
	if not is_peacetime_for_troop_move():
		return {"ok": false, "reason": "not_peacetime"}
	if not is_supply_path_between(from_id, to_id):
		return {"ok": false, "reason": "no_supply_path"}
	var from_troops := _get_city_troops(from_id)
	var min_keep := get_city_min_garrison(from_id)
	if from_troops - amount < min_keep:
		return {"ok": false, "reason": "min_garrison", "min_keep": min_keep, "from_troops": from_troops}
	return {"ok": true, "min_keep": min_keep}


func move_troops(from_id: String, to_id: String, amount: int) -> bool:
	var validation := can_move_troops(from_id, to_id, amount)
	var state := _player_state()
	if not bool(validation.get("ok", false)):
		state["last_troop_move_result"] = {
			"ok": false, "from": from_id, "to": to_id, "amount": amount,
			"commanded_amount": amount, "turn": maxi(1, int(state.get("turn_number", 1))),
			"reason": str(validation.get("reason", "")),
		}
		return false
	var total_before := int(_host.call("_get_world_city_troop_total"))
	var from_troops := _get_city_troops(from_id)
	var to_troops := _get_city_troops(to_id)
	var from_loyalty := int(_host.call("_get_city_loyalty_value", _get_city(from_id)))
	var arrived_amount := calculate_troop_move_arrived_amount(amount, from_loyalty)
	var lost_amount := maxi(0, amount - arrived_amount)
	var from_after := from_troops - amount
	var to_after := to_troops + arrived_amount
	_set_city_troops(from_id, from_after)
	_set_city_troops(to_id, to_after)
	var total_after := int(_host.call("_get_world_city_troop_total"))
	state["last_troop_move_result"] = {
		"ok": true, "from": from_id, "to": to_id, "amount": amount,
		"commanded_amount": amount, "departed_amount": amount, "arrived_amount": arrived_amount,
		"lost_amount": lost_amount, "from_loyalty": from_loyalty,
		"turn": maxi(1, int(state.get("turn_number", 1))), "from_after": from_after,
		"to_after": to_after, "total_before": total_before, "total_after": total_after,
		"total_loss": total_before - total_after,
	}
	print("[TROOP_MOVE] from=%s to=%s commanded=%d departed=%d arrived=%d lost=%d loyalty=%d from_after=%d to_after=%d total=%d->%d" % [from_id, to_id, amount, amount, arrived_amount, lost_amount, from_loyalty, from_after, to_after, total_before, total_after])
	return true


func calculate_troop_move_arrived_amount(commanded_amount: int, from_loyalty: int) -> int:
	return maxi(0, int(floor(float(maxi(0, commanded_amount)) * float(clampi(from_loyalty, 0, 100)) / 100.0)))


func get_conscription_capacity_by_loyalty(city_id: String) -> int:
	var city_data := _get_city(city_id)
	if city_data.is_empty():
		return 0
	var loyalty := int(_host.call("_get_city_loyalty_value", city_data))
	var population := maxi(0, int(city_data.get("population", 0)))
	var ratio := 0.05
	if loyalty < 20:
		ratio = 0.0
	elif loyalty < 40:
		ratio = 0.05
	elif loyalty < 60:
		ratio = 0.10
	elif loyalty < 80:
		ratio = 0.20
	elif loyalty < 90:
		ratio = 0.30
	elif loyalty < 100:
		ratio = 0.40
	else:
		ratio = 0.50
	return maxi(0, int(floor(float(population) * ratio)))


func get_city_conscription_available(city_id: String) -> int:
	return maxi(0, get_conscription_capacity_by_loyalty(city_id) - _get_city_troops(city_id))


func get_conscription_turn_add_multiplier() -> float:
	return 1.10 if bool(_host.call("_is_national_tech_completed", "conscription_system")) else 1.0


func apply_city_conscription_for_world_turn() -> Dictionary:
	var state := _player_state()
	var result := {"turn": maxi(1, int(state.get("turn_number", 1))), "applied": false, "city_results": {}}
	if not is_peacetime_for_troop_move():
		result["reason"] = "not_peacetime"
		state["last_conscription_result"] = result
		return result
	var owned_city_ids: Variant = state.get("owned_city_ids", [])
	if not owned_city_ids is Array:
		state["last_conscription_result"] = result
		return result
	result["applied"] = true
	for city_id_variant in owned_city_ids:
		var city_id := str(city_id_variant)
		if not _is_city_owned_by_player(city_id):
			continue
		var city_data := _get_city(city_id)
		if city_data.is_empty():
			continue
		var loyalty := int(_host.call("_get_city_loyalty_value", city_data))
		var population := maxi(0, int(city_data.get("population", 0)))
		var capacity := get_conscription_capacity_by_loyalty(city_id)
		var available_before := get_city_conscription_available(city_id)
		var before_troops := _get_city_troops(city_id)
		var reason := ""
		var base_add := mini(available_before, 100)
		var added := mini(available_before, int(floor(float(base_add) * get_conscription_turn_add_multiplier())))
		if not bool(_host.call("_is_city_tech_completed", city_id, "barracks")):
			reason = "barracks_required"
			added = 0
		var after_troops := before_troops + added
		if added > 0:
			_set_city_troops(city_id, after_troops)
		(result["city_results"] as Dictionary)[city_id] = {
			"loyalty": loyalty, "population": population, "capacity": capacity,
			"available_before": available_before, "before_troops": before_troops,
			"after_troops": after_troops, "added": added, "base_add": base_add,
			"multiplier": get_conscription_turn_add_multiplier(), "reason": reason,
		}
		print("[CONSCRIPT_WORLD_TURN] city=%s loyalty=%d population=%d capacity=%d available=%d added=%d troops=%d->%d" % [city_id, loyalty, population, capacity, available_before, added, before_troops, after_troops])
	state["last_conscription_result"] = result
	if not (result["city_results"] as Dictionary).is_empty():
		_host.call("_refresh_city_hud_data_bindings")
	return result


func get_recruitment_limit_by_loyalty(city_id: String) -> int:
	var loyalty := int(_host.call("_get_city_loyalty_value", _get_city(city_id)))
	if loyalty >= 90:
		return 500
	if loyalty >= 80:
		return 300
	if loyalty >= 60:
		return 200
	if loyalty >= 40:
		return 100
	return 0


func calculate_recruitment_cost(amount: int) -> Dictionary:
	var safe_amount := maxi(0, amount)
	return {"gold": safe_amount, "food": int(floor(float(safe_amount) / 2.0))}


func can_recruit_troops(city_id: String, amount: int) -> Dictionary:
	if not _is_city_owned_by_player(city_id):
		return {"ok": false, "reason": "ownership"}
	if amount <= 0 or amount % 100 != 0:
		return {"ok": false, "reason": "amount"}
	if not is_peacetime_for_troop_move():
		return {"ok": false, "reason": "not_peacetime"}
	var public_support := int(_host.call("_get_city_public_support", city_id))
	var loyalty := int(_host.call("_get_city_loyalty_value", _get_city(city_id)))
	var limit := get_recruitment_limit_by_loyalty(city_id)
	if loyalty < 40:
		return {"ok": false, "reason": "loyalty", "limit": limit, "loyalty_limit": limit, "publicSupport": public_support, "loyalty": loyalty}
	if amount > limit:
		return {"ok": false, "reason": "loyalty_limit", "limit": limit, "loyalty_limit": limit, "publicSupport": public_support, "loyalty": loyalty}
	var cost := calculate_recruitment_cost(amount)
	if not bool(_host.call("_can_pay_recruitment_cost", cost)):
		return {"ok": false, "reason": "resources", "cost": cost, "limit": limit, "loyalty_limit": limit, "publicSupport": public_support, "loyalty": loyalty}
	return {"ok": true, "cost": cost, "limit": limit, "loyalty_limit": limit, "publicSupport": public_support, "loyalty": loyalty}


func recruit_troops(city_id: String, amount: int) -> bool:
	var validation := can_recruit_troops(city_id, amount)
	var state := _player_state()
	if not bool(validation.get("ok", false)):
		state["last_recruitment_result"] = {
			"ok": false, "city_id": city_id, "amount": amount,
			"turn": maxi(1, int(state.get("turn_number", 1))), "reason": str(validation.get("reason", "")),
			"publicSupport": validation.get("publicSupport", _host.call("_get_city_public_support", city_id)),
			"loyalty": validation.get("loyalty", _host.call("_get_city_loyalty_value", _get_city(city_id))),
			"loyalty_limit": validation.get("loyalty_limit", validation.get("limit", get_recruitment_limit_by_loyalty(city_id))),
			"cost": validation.get("cost", calculate_recruitment_cost(amount)),
		}
		return false
	var before_support := int(_host.call("_get_city_public_support", city_id))
	var before_loyalty := int(_host.call("_get_city_loyalty_value", _get_city(city_id)))
	var before_troops := _get_city_troops(city_id)
	var cost: Dictionary = validation.get("cost", {})
	var paid_cost: Dictionary = _host.call("_apply_recruitment_cost", cost)
	var after_troops := before_troops + amount
	_set_city_troops(city_id, after_troops)
	state["last_recruitment_result"] = {
		"ok": true, "city_id": city_id, "amount": amount, "cost": cost, "paid_cost": paid_cost,
		"publicSupport": before_support, "loyalty": before_loyalty,
		"loyalty_limit": int(validation.get("loyalty_limit", validation.get("limit", get_recruitment_limit_by_loyalty(city_id)))),
		"before_troops": before_troops, "after_troops": after_troops,
		"turn": maxi(1, int(state.get("turn_number", 1))),
	}
	print("[RECRUIT_TROOPS] city=%s amount=%d publicSupport=%d loyalty=%d troops=%d->%d cost=%s paid=%s" % [city_id, amount, before_support, before_loyalty, before_troops, after_troops, str(cost), str(paid_cost)])
	_host.call("_refresh_city_hud_data_bindings")
	return true


func _player_state() -> Dictionary:
	var value: Variant = _host.get("_player_state")
	return value as Dictionary if value is Dictionary else {}


func _city_markers() -> Dictionary:
	var value: Variant = _host.get("_city_markers_by_id")
	return value as Dictionary if value is Dictionary else {}


func _get_city(city_id: String) -> Dictionary:
	var value: Variant = _host.call("_get_city_hud_entry", city_id)
	return value as Dictionary if value is Dictionary else {}


func _get_city_troops(city_id: String) -> int:
	return int(_host.call("_get_city_troops_for_battle_context", city_id))


func _set_city_troops(city_id: String, troops: int) -> void:
	_host.call("_set_city_runtime_troops", city_id, troops)


func _is_city_owned_by_player(city_id: String) -> bool:
	return bool(_host.call("_is_city_owned_by_player_mvp", city_id))
