class_name WorldTurnStateService
extends RefCounted


const CITY_PUBLIC_SUPPORT_DEFAULT := 70
const PUBLIC_SUPPORT_DELTA_MIN := -7
const PUBLIC_SUPPORT_DELTA_MAX := 3
const CITY_LOYALTY_DRIFT_MIN := -3
const CITY_LOYALTY_DRIFT_MAX := 3
const STATIONED_HERO_SECURITY_WEIGHT := 1.0

var _query: Callable
var _mutation: Callable


func configure(query: Callable, mutation: Callable) -> void:
	_query = query
	_mutation = mutation


func calculate_public_support_delta(city_id: String, tax_level: int, has_food_surplus: bool, has_commerce_surplus: bool, supply_state: Dictionary = {}) -> Dictionary:
	var normalized_tax := clampi(int(round(float(tax_level))), 0, 100)
	var tax_delta := 1
	if normalized_tax > 90:
		tax_delta = -3
	elif normalized_tax > 60:
		tax_delta = -2
	elif normalized_tax > 30:
		tax_delta = -1
	var food_delta := 1 if has_food_surplus else -1
	var commerce_delta := 1 if has_commerce_surplus else -1
	var supply_delta := -2 if bool(supply_state.get("isolated", false)) else 0
	var delta := clampi(tax_delta + food_delta + commerce_delta + supply_delta, PUBLIC_SUPPORT_DELTA_MIN, PUBLIC_SUPPORT_DELTA_MAX)
	var reasons: Array[String] = [
		"tax=%s" % _format_signed_int(tax_delta),
		"food=%s" % _format_signed_int(food_delta),
		"commerce=%s" % _format_signed_int(commerce_delta),
		"supply=%s" % _format_signed_int(supply_delta),
	]
	return {
		"city_id": city_id,
		"delta": delta,
		"reasons": reasons,
		"tax_delta": tax_delta,
		"food_delta": food_delta,
		"commerce_delta": commerce_delta,
		"supply_delta": supply_delta,
		"supply_state": supply_state,
	}


func apply_public_support_tick(tax_level: int, supply_states: Dictionary = {}) -> Dictionary:
	var result := {"turn": maxi(1, int(_ask("turn_number"))), "city_results": {}}
	var owned_city_ids: Variant = _ask("owned_city_ids")
	if not owned_city_ids is Array:
		_commit("set_player_result", ["last_public_support_result", result])
		return result
	for city_id_variant in owned_city_ids:
		var city_id := str(city_id_variant)
		var city_data: Variant = _ask("city_data", [city_id])
		if not city_data is Dictionary or (city_data as Dictionary).is_empty():
			continue
		var before_support := clampi(int(_ask("public_support", [city_id])), 0, 100)
		var context: Variant = _ask("public_support_context", [city_id])
		var support_context: Dictionary = context if context is Dictionary else {}
		var drift := calculate_public_support_delta(
			city_id,
			tax_level,
			bool(support_context.get("food_surplus", false)),
			bool(support_context.get("commerce_surplus", false)),
			_get_supply_city_state(supply_states, city_id)
		)
		var after_support := clampi(before_support + int(drift.get("delta", 0)), 0, 100)
		_commit("set_public_support", [city_id, after_support])
		var city_result := {
			"before": before_support,
			"after": after_support,
			"delta": after_support - before_support,
			"reasons": drift.get("reasons", []),
			"tax_delta": int(drift.get("tax_delta", 0)),
			"food_delta": int(drift.get("food_delta", 0)),
			"commerce_delta": int(drift.get("commerce_delta", 0)),
			"supply_delta": int(drift.get("supply_delta", 0)),
		}
		(result["city_results"] as Dictionary)[city_id] = city_result
		print("[PUBLIC_SUPPORT_DRIFT] city=%s before=%d delta=%d after=%d reasons=%s" % [city_id, before_support, int(city_result.get("delta", 0)), after_support, str(city_result.get("reasons", []))])
	_commit("set_player_result", ["last_public_support_result", result])
	_commit("refresh_city_hud")
	return result


func calculate_loyalty_delta_from_public_support(public_support: int) -> int:
	var value := clampi(public_support, 0, 100)
	if value >= 90:
		return 2
	if value >= 80:
		return 1
	if value >= 60:
		return -1
	if value >= 40:
		return -2
	return -3


func apply_seasonal_loyalty_tick(turn_number: int, is_season_boundary: bool, next_boundary_turn: int) -> Dictionary:
	var safe_turn := maxi(1, turn_number)
	var result := {"turn": safe_turn, "applied": false, "city_results": {}}
	if not is_season_boundary:
		result["next_turn"] = next_boundary_turn
		result["reason"] = "not_seasonal_turn"
		_commit("set_player_result", ["last_seasonal_loyalty_result", result])
		return result
	var owned_city_ids: Variant = _ask("owned_city_ids")
	if not owned_city_ids is Array:
		result["applied"] = true
		_commit("set_player_result", ["last_seasonal_loyalty_result", result])
		return result
	result["applied"] = true
	for city_id_variant in owned_city_ids:
		var city_id := str(city_id_variant)
		var city_data: Variant = _ask("city_data", [city_id])
		if not city_data is Dictionary or (city_data as Dictionary).is_empty():
			continue
		var public_support := clampi(int(_ask("public_support", [city_id])), 0, 100)
		var before_loyalty := _get_city_loyalty_value(city_data as Dictionary)
		var raw_delta := calculate_loyalty_delta_from_public_support(public_support)
		var after_loyalty := clampi(before_loyalty + raw_delta, 0, 100)
		_commit("set_city_loyalty", [city_id, after_loyalty])
		var reasons: Array[String] = ["publicSupport=%d" % public_support]
		var city_result := {
			"publicSupport": public_support,
			"before_loyalty": before_loyalty,
			"after_loyalty": after_loyalty,
			"delta": after_loyalty - before_loyalty,
			"raw_delta": raw_delta,
			"reasons": reasons,
		}
		(result["city_results"] as Dictionary)[city_id] = city_result
		print("[SEASONAL_LOYALTY_PUBLIC_SUPPORT] turn=%d city=%s publicSupport=%d before=%d delta=%d after=%d" % [safe_turn, city_id, public_support, before_loyalty, int(city_result.get("delta", 0)), after_loyalty])
	_commit("set_player_result", ["last_seasonal_loyalty_result", result])
	_commit("refresh_city_hud")
	return result


func apply_city_loyalty_tick(tax_level: int, policy_id: String, supply_states: Dictionary = {}) -> Dictionary:
	var result := {"tax_level": tax_level, "policy_id": policy_id, "cities": []}
	var owned_city_ids: Variant = _ask("owned_city_ids")
	if not owned_city_ids is Array:
		_commit("set_player_result", ["last_city_loyalty_drift_result", result])
		return result
	for city_id_variant in owned_city_ids:
		var city_id := str(city_id_variant)
		var city_data: Variant = _ask("city_data", [city_id])
		if not city_data is Dictionary or (city_data as Dictionary).is_empty():
			continue
		var before_loyalty := _get_city_loyalty_value(city_data as Dictionary)
		var inputs: Variant = _ask("loyalty_inputs", [city_id, tax_level, policy_id])
		var loyalty_inputs: Dictionary = inputs if inputs is Dictionary else {}
		var drift := calculate_city_loyalty_drift(city_data as Dictionary, loyalty_inputs, _get_supply_city_state(supply_states, city_id))
		var after_loyalty := clampi(before_loyalty + int(drift.get("delta", 0)), 0, 100)
		_commit("set_city_loyalty", [city_id, after_loyalty])
		drift["before_loyalty"] = before_loyalty
		drift["after_loyalty"] = after_loyalty
		(result["cities"] as Array).append(drift)
		print("[CITY_LOYALTY_DRIFT] city=%s before=%d delta=%d after=%d reasons=%s" % [city_id, before_loyalty, int(drift.get("delta", 0)), after_loyalty, str(drift.get("reasons", []))])
	_commit("set_player_result", ["last_city_loyalty_drift_result", result])
	_commit("refresh_city_hud")
	return result


func calculate_city_loyalty_drift(city_data: Dictionary, inputs: Dictionary, supply_state: Dictionary = {}) -> Dictionary:
	var city_effects: Dictionary = inputs.get("city_effects", {})
	var tax_delta := int(inputs.get("tax_delta", 0))
	var garrison_troops := maxi(0, int(city_data.get("troops", 0)))
	var stationed_hero_troops := maxi(0, int(inputs.get("stationed_hero_troops", 0)))
	var security_troops := int(round(float(garrison_troops) + (float(stationed_hero_troops) * STATIONED_HERO_SECURITY_WEIGHT)))
	var security_required_troops := maxi(1, int(inputs.get("security_required_troops", 500)))
	var security_delta := 0
	if security_troops >= int(ceil(float(security_required_troops) * 1.2)):
		security_delta = 1
	elif security_troops < security_required_troops:
		security_delta = -1
	var supply_security_delta := int(supply_state.get("security_delta", 0))
	security_delta += supply_security_delta
	var commerce_rating := _get_city_numeric_rating(city_data, "commerce_rating", 3)
	var population_rating := _get_city_numeric_rating(city_data, "population_rating", 3)
	var economy_score := clampi((commerce_rating * 10) + (population_rating * 8) + int(round((float(city_effects.get("gold_multiplier", 1.0)) - 1.0) * 80.0)), 0, 100)
	var economy_delta := 0
	if economy_score >= 75:
		economy_delta = 1
	elif economy_score < 50:
		economy_delta = -1
	var population := maxi(1, int(city_data.get("population", 30000)))
	var troop_population_ratio := float(garrison_troops) / float(population)
	var military_burden_delta := 0
	if troop_population_ratio > 0.45:
		military_burden_delta = -2
	elif troop_population_ratio > 0.35:
		military_burden_delta = -1
	var supply_delta := int(supply_state.get("loyalty_delta", 0))
	var preliminary_delta := tax_delta + security_delta + economy_delta + military_burden_delta + supply_delta
	var control_delta := 1 if preliminary_delta < 0 and bool(inputs.get("governor_controls_loss", false)) else 0
	var delta := clampi(preliminary_delta + control_delta, CITY_LOYALTY_DRIFT_MIN, CITY_LOYALTY_DRIFT_MAX)
	var reasons: Array[String] = []
	for entry in [["tax", tax_delta], ["security", security_delta], ["economy", economy_delta], ["military", military_burden_delta], ["supply", supply_delta], ["supply_security", supply_security_delta], ["control", control_delta]]:
		if int(entry[1]) != 0:
			reasons.append("%s=%s" % [str(entry[0]), _format_signed_int(int(entry[1]))])
	return {
		"city_id": str(city_data.get("id", "")), "delta": delta, "tax_delta": tax_delta,
		"security_delta": security_delta, "supply_delta": supply_delta, "supply_security_delta": supply_security_delta,
		"economy_delta": economy_delta, "military_burden_delta": military_burden_delta, "control_delta": control_delta,
		"security_troops": security_troops, "security_required_troops": security_required_troops,
		"economy_score": economy_score, "troop_population_ratio": troop_population_ratio,
		"city_loyalty_loss_multiplier": float(city_effects.get("city_loyalty_loss_multiplier", 1.0)),
		"supply_state": supply_state, "reasons": reasons,
	}


func _get_supply_city_state(supply_states: Dictionary, city_id: String) -> Dictionary:
	var city_states: Variant = supply_states.get("city_states", {})
	if city_states is Dictionary:
		var state: Variant = (city_states as Dictionary).get(city_id, {})
		if state is Dictionary:
			return state
	return {}


func _get_city_loyalty_value(city_data: Dictionary) -> int:
	return clampi(int(city_data.get("cityLoyalty", city_data.get("loyalty", 75))), 0, 100)


func _get_city_numeric_rating(city_data: Dictionary, key: String, fallback: int) -> int:
	return clampi(int(city_data.get(key, fallback)), 1, 5)


func _format_signed_int(value: int) -> String:
	return "+%d" % value if value > 0 else str(value)


func _ask(query_id: String, args: Array = []) -> Variant:
	if not _query.is_valid():
		return null
	return _query.call(query_id, args)


func _commit(mutation_id: String, args: Array = []) -> Variant:
	if not _mutation.is_valid():
		return null
	return _mutation.call(mutation_id, args)
