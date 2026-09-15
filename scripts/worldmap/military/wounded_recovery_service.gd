class_name WorldMapWoundedRecoveryService
extends RefCounted

const ExpeditionSupplyCalculatorScript := preload("res://scripts/t02/expedition_supply_calculator.gd")
const WoundedRecoveryRulesScript := preload("res://scripts/t02/wounded_recovery.gd")

var _query: Callable
var _mutation: Callable
var _config: Dictionary = {}


func configure(query: Callable, mutation: Callable, config: Dictionary = {}) -> void:
	_query = query
	_mutation = mutation
	_config = config.duplicate(true)


func get_city_wounded_queue(city_data: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var raw_queue: Variant = city_data.get("woundedQueue", city_data.get("wounded_queue", []))
	if not raw_queue is Array:
		return result
	for raw_entry in raw_queue:
		if not raw_entry is Dictionary:
			continue
		var entry := raw_entry as Dictionary
		var troops := maxi(0, int(entry.get("wounded_count", entry.get("troops", 0))))
		var turns_left := maxi(0, int(entry.get("recovery_months_remaining", entry.get("turnsLeft", entry.get("turns_left", 0)))))
		if troops <= 0:
			continue
		result.append({
			"wounded_count": troops,
			"recovery_months_remaining": turns_left,
			"recovery_mode": str(entry.get("recovery_mode", "normal")),
			"source_transaction_id": str(entry.get("source_transaction_id", "legacy")),
			"turnsLeft": turns_left,
			"troops": troops,
		})
	return result


func add_wounded_to_city(city_id: String, wounded_troops: int, turns_left: int, recovery_mode: String, transaction_id: String) -> Dictionary:
	var report := _result("add_wounded", city_id)
	var troops := maxi(0, wounded_troops)
	if city_id.is_empty() or not bool(_q("has_city", [city_id], false)):
		return _reject(report, "missing_city")
	if troops <= 0:
		return _reject(report, "empty_wounded_count")
	var queue := _city_queue(city_id)
	if not transaction_id.is_empty() and transaction_id != "legacy":
		for existing in queue:
			if str(existing.get("source_transaction_id", "")) == transaction_id \
				and int(existing.get("wounded_count", 0)) == troops \
				and str(existing.get("recovery_mode", "normal")) == ("fast" if recovery_mode == "fast" else "normal"):
				report["ok"] = true
				report["duplicate"] = true
				return report
	var entry := WoundedRecoveryRulesScript.make_entry(troops, recovery_mode, transaction_id)
	entry["recovery_months_remaining"] = maxi(1, turns_left)
	entry["turnsLeft"] = maxi(1, turns_left)
	entry["troops"] = troops
	queue.append(entry)
	if not bool(_m("set_city_wounded_queue", [city_id, queue], false)):
		return _reject(report, "queue_write_failed")
	report["ok"] = true
	report["queue_changed"] = true
	report["wounded_added"] = troops
	report["queue"] = queue.duplicate(true)
	return report


func clear_city_wounded_queue(city_id: String) -> Dictionary:
	var report := _result("clear_queue", city_id)
	if city_id.is_empty() or not bool(_q("has_city", [city_id], false)):
		return _reject(report, "missing_city")
	var before := _city_queue(city_id)
	if not bool(_m("set_city_wounded_queue", [city_id, []], false)):
		return _reject(report, "queue_write_failed")
	report["ok"] = true
	report["queue_changed"] = not before.is_empty()
	report["queue"] = []
	return report


func apply_battle_hero_status(hero_id: String, status: String, outcome: Dictionary, transaction_id: String) -> Dictionary:
	var report := _result("battle_hero_status")
	report["hero_id"] = hero_id
	if hero_id.is_empty() or not bool(_q("has_hero", [hero_id], false)):
		return _reject(report, "missing_hero")
	var allowed_statuses: Array = _config.get("allowed_statuses", ["normal", "wounded", "captured", "dead"])
	if not allowed_statuses.has(status):
		return _reject(report, "invalid_status")
	var hero_state := _dictionary(_q("hero_state", [hero_id], {})).duplicate(true)
	if bool(hero_state.get("captured", false)) or bool(hero_state.get("dead", false)):
		return _reject(report, "immutable_hero_status")
	var wounded_status := str(_config.get("wounded_status", "wounded"))
	var captured_status := str(_config.get("captured_status", "captured"))
	var dead_status := str(_config.get("dead_status", "dead"))
	var was_wounded := bool(hero_state.get("wounded", false)) or str(hero_state.get("status", "")) == wounded_status
	var turns_before := maxi(0, int(hero_state.get("wounded_turns_remaining", 0)))
	if status == wounded_status and was_wounded and not transaction_id.is_empty() \
		and str(hero_state.get("last_battle_transaction_id", "")) == transaction_id:
		report["ok"] = true
		report["duplicate"] = true
		report["was_wounded"] = true
		report["is_wounded"] = true
		report["turns_before"] = turns_before
		report["turns_after"] = turns_before
		return report
	hero_state["status"] = status
	hero_state["wounded"] = status == wounded_status
	hero_state["captured"] = status == captured_status
	hero_state["dead"] = status == dead_status
	hero_state["wounded_turns_remaining"] = int(_config.get("normal_recovery_months", 3)) if status == wounded_status else 0
	if not outcome.is_empty():
		hero_state["last_battle_current_troops"] = maxi(0, int(outcome.get("current_troops", 0)))
		hero_state["last_battle_max_troops"] = maxi(0, int(outcome.get("max_troops", 0)))
	if not transaction_id.is_empty():
		hero_state["last_battle_transaction_id"] = transaction_id
	if not bool(_m("set_hero_state", [hero_id, hero_state], false)):
		return _reject(report, "hero_write_failed")
	report["ok"] = true
	report["was_wounded"] = was_wounded
	report["is_wounded"] = bool(hero_state.get("wounded", false))
	report["turns_before"] = turns_before
	report["turns_after"] = maxi(0, int(hero_state.get("wounded_turns_remaining", 0)))
	return report


func world_month_serial(turn_number: int) -> int:
	var turns_per_year := maxi(1, int(_config.get("world_calendar_year_turns", 40)))
	var zero_based := maxi(0, turn_number - 1)
	return int(floor(float(zero_based) * 12.0 / float(turns_per_year)))


func advance_recovery_month(month_serial: int) -> Dictionary:
	var report := _result("advance_month")
	report["month_serial"] = month_serial
	if month_serial < 0:
		return _reject(report, "invalid_month_serial")
	var last_serial := int(_q("last_recovery_month_serial", [], -1))
	if last_serial >= month_serial:
		report["ok"] = true
		report["duplicate"] = true
		return report
	var recovered_hero_ids: Array[String] = []
	var hero_changes: Array[Dictionary] = []
	for hero_id_variant in _q("hero_ids", [], []):
		var hero_id := str(hero_id_variant)
		if hero_id.is_empty():
			continue
		var hero_state := _dictionary(_q("hero_state", [hero_id], {})).duplicate(true)
		if hero_state.is_empty():
			continue
		if bool(hero_state.get("dead", false)) or bool(hero_state.get("captured", false)):
			if bool(hero_state.get("wounded", false)) or int(hero_state.get("wounded_turns_remaining", 0)) > 0:
				hero_state["wounded"] = false
				hero_state["wounded_turns_remaining"] = 0
				_m("set_hero_state", [hero_id, hero_state], null)
			continue
		if not bool(hero_state.get("wounded", false)) and str(hero_state.get("status", "normal")) != str(_config.get("wounded_status", "wounded")):
			continue
		var before := maxi(0, int(hero_state.get("wounded_turns_remaining", int(_config.get("normal_recovery_months", 3)))))
		var after := maxi(0, before - 1)
		hero_state["wounded_turns_remaining"] = after
		if after <= 0:
			hero_state["status"] = str(_config.get("normal_status", "normal"))
			hero_state["wounded"] = false
			recovered_hero_ids.append(hero_id)
		else:
			hero_state["status"] = str(_config.get("wounded_status", "wounded"))
			hero_state["wounded"] = true
		_m("set_hero_state", [hero_id, hero_state], null)
		hero_changes.append({"hero_id": hero_id, "turns_before": before, "turns_after": after, "is_wounded": after > 0})
	var city_changes: Array[Dictionary] = []
	for city_id_variant in _q("city_ids", [], []):
		var city_id := str(city_id_variant)
		var queue := _city_queue(city_id)
		if queue.is_empty():
			continue
		var recovery := WoundedRecoveryRulesScript.advance_month(queue)
		var remaining: Array = recovery.get("queue", [])
		var recovered := maxi(0, int(recovery.get("recovered", 0)))
		_m("set_city_wounded_queue", [city_id, remaining], null)
		if recovered > 0:
			_m("set_city_troops", [city_id, maxi(0, int(_q("city_troops", [city_id], 0))) + recovered], null)
		city_changes.append({"city_id": city_id, "recovered_troops": recovered, "queue": remaining.duplicate(true)})
	_m("set_last_recovery_month_serial", [month_serial], null)
	report["ok"] = true
	report["recovered_hero_ids"] = recovered_hero_ids
	report["hero_changes"] = hero_changes
	report["city_changes"] = city_changes
	return report


func evaluate_fast_treatment(treatment: Dictionary) -> Dictionary:
	var report := _result("fast_treatment", str(treatment.get("city_id", "")))
	var city_id := str(treatment.get("city_id", ""))
	var transaction_id := str(treatment.get("transaction_id", ""))
	var wounded := maxi(0, int(treatment.get("wounded_count", 0)))
	var required_salt := ExpeditionSupplyCalculatorScript.fast_recovery_salt(wounded)
	var available_salt := maxi(0, int(_q("city_resource_amount", [city_id, "salt"], 0))) if not city_id.is_empty() else 0
	report["transaction_id"] = transaction_id
	report["wounded_count"] = wounded
	report["required_salt"] = required_salt
	report["available_salt"] = available_salt
	if city_id.is_empty() or not bool(_q("has_city", [city_id], false)):
		return _reject(report, "missing_city")
	if wounded <= 0:
		return _reject(report, "empty_wounded_count")
	if str(treatment.get("mode", "normal")) == "fast":
		return _reject(report, "already_fast")
	if available_salt < required_salt:
		return _reject(report, "insufficient_salt")
	var matching := 0
	for entry in _city_queue(city_id):
		if str(entry.get("source_transaction_id", "")) == transaction_id:
			matching += 1
	if matching <= 0:
		return _reject(report, "missing_wounded_queue_entry")
	report["ok"] = true
	report["matching_queue_entries"] = matching
	return report


func apply_fast_treatment(treatment: Dictionary) -> Dictionary:
	var report := evaluate_fast_treatment(treatment)
	if not bool(report.get("ok", false)):
		return report
	var city_id := str(report.get("city_id", ""))
	var transaction_id := str(report.get("transaction_id", ""))
	var required_salt := maxi(0, int(report.get("required_salt", 0)))
	var available_salt := maxi(0, int(report.get("available_salt", 0)))
	var queue := _city_queue(city_id)
	for index in range(queue.size()):
		var entry: Dictionary = queue[index]
		if str(entry.get("source_transaction_id", "")) != transaction_id:
			continue
		entry["recovery_mode"] = "fast"
		entry["recovery_months_remaining"] = int(_config.get("fast_recovery_months", 1))
		entry["turnsLeft"] = int(_config.get("fast_recovery_months", 1))
		queue[index] = entry
	var treated_hero_ids: Array[String] = []
	for hero_id_variant in _q("hero_ids", [], []):
		var hero_id := str(hero_id_variant)
		var hero_state := _dictionary(_q("hero_state", [hero_id], {})).duplicate(true)
		if not bool(hero_state.get("wounded", false)) \
			or str(hero_state.get("current_city_id", hero_state.get("city_id", ""))) != city_id \
			or str(hero_state.get("last_battle_transaction_id", "")) != transaction_id:
			continue
		hero_state["wounded_turns_remaining"] = int(_config.get("fast_recovery_months", 1))
		_m("set_hero_state", [hero_id, hero_state], null)
		treated_hero_ids.append(hero_id)
	_m("set_city_resource_amount", [city_id, "salt", available_salt - required_salt], null)
	_m("set_city_wounded_queue", [city_id, queue], null)
	var next_treatment := treatment.duplicate(true)
	next_treatment["mode"] = "fast"
	_m("set_last_wounded_treatment", [next_treatment], null)
	report["ok"] = true
	report["resource_changes"] = {"salt": {"before": available_salt, "after": available_salt - required_salt, "delta": -required_salt}}
	report["queue_changed"] = true
	report["treated_hero_ids"] = treated_hero_ids
	return report


func _city_queue(city_id: String) -> Array[Dictionary]:
	return get_city_wounded_queue(_dictionary(_q("city_state", [city_id], {})))


func _result(action: String, city_id: String = "") -> Dictionary:
	return {
		"ok": false, "action": action, "city_id": city_id, "hero_id": "",
		"duplicate": false, "was_wounded": false, "is_wounded": false,
		"turns_before": 0, "turns_after": 0, "queue_changed": false,
		"resource_changes": {}, "recovered_hero_ids": [], "hero_changes": [], "city_changes": [],
		"error_code": "", "warnings": [],
	}


func _reject(report: Dictionary, error_code: String) -> Dictionary:
	report["ok"] = false
	report["error_code"] = error_code
	(report["warnings"] as Array).append(error_code)
	return report


func _q(query_id: String, args: Array = [], fallback: Variant = null) -> Variant:
	if not _query.is_valid():
		return fallback
	var value: Variant = _query.call(query_id, args)
	return fallback if value == null else value


func _m(mutation_id: String, args: Array = [], fallback: Variant = null) -> Variant:
	if not _mutation.is_valid():
		return fallback
	var value: Variant = _mutation.call(mutation_id, args)
	return fallback if value == null else value


func _dictionary(value: Variant) -> Dictionary:
	return value if value is Dictionary else {}
