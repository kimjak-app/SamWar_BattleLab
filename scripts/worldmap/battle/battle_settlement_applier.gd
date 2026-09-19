class_name WorldMapBattleSettlementApplier
extends RefCounted

const RESULT_DEFENDER_WIN := "defender_win"
const RESULT_ATTACKER_WIN := "attacker_win"
const RESULT_RETREAT := "retreat"

var _query: Callable
var _mutation: Callable
var _config: Dictionary = {}


func configure(query: Callable, mutation: Callable, config: Dictionary = {}) -> void:
	_query = query
	_mutation = mutation
	_config = config.duplicate(true)


func apply(settlement_plan: Dictionary) -> Dictionary:
	var plan := settlement_plan.duplicate(true)
	var report := _empty_report(plan)
	var battle_kind := str(plan.get("battle_kind", ""))
	var result_kind := str(plan.get("result_kind", ""))
	var attacker_city_id := str(plan.get("attacker_city_id", ""))
	var target_city_id := str(plan.get("target_city_id", plan.get("defender_city_id", "")))
	if not ["player_attack", "enemy_invasion"].has(battle_kind):
		return _reject(report, "unsupported_battle_kind")
	if not [RESULT_DEFENDER_WIN, RESULT_ATTACKER_WIN, RESULT_RETREAT].has(result_kind):
		return _reject(report, "unsupported_result_kind")
	if target_city_id.is_empty() or not bool(_q("has_city", [target_city_id], false)):
		return _reject(report, "missing_target_city")
	if result_kind != RESULT_RETREAT and (attacker_city_id.is_empty() or not bool(_q("has_city", [attacker_city_id], false))):
		return _reject(report, "missing_attacker_city")
	var transaction_id := str(plan.get("transaction_id", ""))
	var result_id := str(plan.get("result_id", ""))
	if not transaction_id.is_empty() or not result_id.is_empty():
		if transaction_id.is_empty() or result_id.is_empty():
			return _reject(report, "incomplete_result_identity")
		if bool(_q("is_result_applied", [result_id], false)):
			report["duplicate"] = true
			return _reject(report, "duplicate_result")
		if str(_q("pending_transaction_id", [], "")) != transaction_id:
			return _reject(report, "transaction_mismatch")
	if result_kind == RESULT_RETREAT and str(plan.get("settlement_profile", "standard")) != "t02_return":
		report["ok"] = true
		_mark_applied(result_id)
		return report

	if str(plan.get("settlement_profile", "standard")) == "t02_return":
		_apply_t02_troops(plan, report)
	else:
		_apply_standard_troops(plan, report)
	_apply_faction_transfer(plan, report)
	_apply_supply(plan, report)
	_apply_hero_movements(plan, report)
	_apply_hero_status_plan(plan, report)
	_apply_hero_disposition(plan, report)
	_mark_applied(result_id)
	report["ok"] = true
	return report


func move_hero(hero_id: String, city_id: String) -> bool:
	if hero_id.is_empty() or city_id.is_empty():
		return false
	return bool(_m("move_hero", [hero_id, city_id], false))


func set_hero_faction(hero_id: String, faction_id: String, city_id: String, transaction_id: String = "", old_faction_id: String = "") -> bool:
	if hero_id.is_empty() or faction_id.is_empty() or city_id.is_empty():
		return false
	return bool(_m("set_hero_faction", [hero_id, faction_id, city_id, transaction_id, old_faction_id], false))


func set_hero_status(hero_id: String, status: String, outcome: Dictionary = {}, transaction_id: String = "") -> bool:
	if hero_id.is_empty() or not ["normal", "wounded", "captured", "dead"].has(status):
		return false
	return bool(_m("set_hero_status", [hero_id, status, outcome, transaction_id], false))


func apply_defender_supply(city_id: String, settlement: Dictionary) -> Dictionary:
	if city_id.is_empty() or not bool(_q("has_city", [city_id], false)):
		return {"ok": false, "city_id": city_id}
	var change: Variant = _m("set_defender_supply", [city_id, settlement], {})
	return change if change is Dictionary else {"ok": false, "city_id": city_id}


func apply_attacker_cargo(city_id: String, settlement: Dictionary) -> Dictionary:
	if city_id.is_empty() or not bool(_q("has_city", [city_id], false)):
		return {"ok": false, "city_id": city_id}
	var change: Variant = _m("add_attacker_cargo", [city_id, settlement], {})
	return change if change is Dictionary else {"ok": false, "city_id": city_id}


func apply_defender_disposition(target_city_id: String, disposition: Dictionary) -> Dictionary:
	var report := _empty_report({"target_city_id": target_city_id})
	_apply_hero_disposition({"target_city_id": target_city_id, "transaction_id": str(disposition.get("transaction_id", "")), "defender_disposition": disposition}, report)
	return _dictionary(report.get("defender_disposition", {}))


func apply_hero_statuses(status_plan: Array, transaction_id: String = "") -> Array:
	var report := _empty_report({"transaction_id": transaction_id})
	_apply_hero_status_plan({"hero_status_plan": status_plan, "transaction_id": transaction_id}, report)
	return report.get("hero_changes", [])


func _apply_standard_troops(plan: Dictionary, report: Dictionary) -> void:
	var casualty := _dictionary(plan.get("casualty_plan", {}))
	var attacker_city_id := str(plan.get("attacker_city_id", ""))
	var target_city_id := str(plan.get("target_city_id", ""))
	var result_kind := str(plan.get("result_kind", ""))
	var target_after := int(casualty.get("defender_remaining_troops", _q("city_troops", [target_city_id], 0)))
	var attacker_after := int(casualty.get("attacker_source_remaining_troops", casualty.get("attacker_remaining_troops", _q("city_troops", [attacker_city_id], 0))))
	if result_kind == RESULT_ATTACKER_WIN:
		target_after = int(plan.get("occupation_troops", casualty.get("occupied_city_troops", target_after)))
	_apply_city_troops(target_city_id, target_after, report)
	_apply_city_troops(attacker_city_id, attacker_after, report)
	_apply_standard_wounded(plan, report)


func _apply_t02_troops(plan: Dictionary, report: Dictionary) -> void:
	var troop_plan := _dictionary(plan.get("troop_settlement", {}))
	var attacker_city_id := str(plan.get("attacker_city_id", ""))
	var target_city_id := str(plan.get("target_city_id", ""))
	var attacker_won := str(plan.get("result_kind", "")) == RESULT_ATTACKER_WIN
	var destination_city_id := target_city_id if attacker_won else attacker_city_id
	if attacker_won:
		_apply_city_troops(target_city_id, int(plan.get("occupation_troops", troop_plan.get("attacker_healthy", 0))), report)
	else:
		_apply_city_troops(attacker_city_id, int(_q("city_troops", [attacker_city_id], 0)) + int(troop_plan.get("attacker_healthy", 0)), report)
		_apply_city_troops(target_city_id, int(troop_plan.get("defender_healthy", _q("city_troops", [target_city_id], 0))), report)
	var attacker_wounded := maxi(0, int(troop_plan.get("attacker_wounded", 0)))
	if attacker_wounded > 0:
		_m("add_wounded", [destination_city_id, attacker_wounded, int(_config.get("normal_wounded_turns", 3)), "normal", str(plan.get("transaction_id", ""))], null)
		report["troop_changes"].append({"city_id": destination_city_id, "wounded_added": attacker_wounded})
	var disposition := _dictionary(plan.get("defender_disposition", {}))
	var retreat_city_id := str(disposition.get("primary_escape_city_id", ""))
	if attacker_won and not retreat_city_id.is_empty():
		var defender_healthy := maxi(0, int(troop_plan.get("defender_healthy", 0)))
		_apply_city_troops(retreat_city_id, int(_q("city_troops", [retreat_city_id], 0)) + defender_healthy, report)
		var defender_wounded := maxi(0, int(troop_plan.get("defender_wounded", 0)))
		if defender_wounded > 0:
			_m("add_wounded", [retreat_city_id, defender_wounded, int(_config.get("normal_wounded_turns", 3)), "normal", str(plan.get("transaction_id", ""))], null)
	elif not attacker_won:
		var defending_wounded := maxi(0, int(troop_plan.get("defender_wounded", 0)))
		if defending_wounded > 0:
			_m("add_wounded", [target_city_id, defending_wounded, int(_config.get("normal_wounded_turns", 3)), "normal", str(plan.get("transaction_id", ""))], null)
			report["troop_changes"].append({"city_id": target_city_id, "wounded_added": defending_wounded})


func _apply_standard_wounded(plan: Dictionary, _report: Dictionary) -> void:
	var battle_kind := str(plan.get("battle_kind", ""))
	var result_kind := str(plan.get("result_kind", ""))
	var attacker_city_id := str(plan.get("attacker_city_id", ""))
	var target_city_id := str(plan.get("target_city_id", ""))
	var player_outcome := _dictionary(plan.get("player_troop_outcome", {}))
	var enemy_outcome := _dictionary(plan.get("enemy_troop_outcome", {}))
	var winner_outcome := player_outcome if (battle_kind == "player_attack") else enemy_outcome
	var loser_outcome := enemy_outcome if (battle_kind == "player_attack") else player_outcome
	var turns := int(_config.get("legacy_wounded_turns", 3))
	if result_kind == RESULT_ATTACKER_WIN:
		_m("clear_wounded", [target_city_id], null)
		var winner_wounded := maxi(0, int(winner_outcome.get("wounded", 0)))
		if winner_wounded > 0:
			_m("add_wounded", [target_city_id, winner_wounded, turns, "normal", "legacy"], null)
		var losing_retreat := attacker_city_id if battle_kind == "player_attack" else str(_q("nearest_player_retreat_city", [target_city_id], ""))
		var loser_wounded := maxi(0, int(loser_outcome.get("wounded", 0)))
		if loser_wounded > 0 and not losing_retreat.is_empty():
			_m("add_wounded", [losing_retreat, loser_wounded, turns, "normal", "legacy"], null)
	else:
		var defender_outcome := player_outcome if battle_kind == "enemy_invasion" else enemy_outcome
		var attacker_outcome := enemy_outcome if battle_kind == "enemy_invasion" else player_outcome
		var defender_wounded := maxi(0, int(defender_outcome.get("wounded", 0)))
		var attacker_wounded := maxi(0, int(attacker_outcome.get("wounded", 0)))
		if defender_wounded > 0:
			_m("add_wounded", [target_city_id, defender_wounded, turns, "normal", "legacy"], null)
		if attacker_wounded > 0:
			_m("add_wounded", [attacker_city_id, attacker_wounded, turns, "normal", "legacy"], null)


func _apply_faction_transfer(plan: Dictionary, report: Dictionary) -> void:
	var transfer := _dictionary(plan.get("faction_transfer", {}))
	report["old_owner"] = str(transfer.get("old_owner", ""))
	report["new_owner"] = str(transfer.get("new_owner", report.get("old_owner", "")))
	if not bool(transfer.get("required", false)):
		return
	var city_id := str(transfer.get("city_id", plan.get("target_city_id", "")))
	var old_owner := str(report.get("old_owner", ""))
	var new_owner := str(report.get("new_owner", ""))
	if city_id.is_empty() or old_owner.is_empty() or new_owner.is_empty():
		report["warnings"].append("incomplete_faction_transfer")
		return
	_m("set_city_owner", [city_id, new_owner], null)
	report["ownership_changed"] = old_owner != new_owner
	report["old_owner"] = old_owner
	report["new_owner"] = new_owner


func _apply_supply(plan: Dictionary, report: Dictionary) -> void:
	if not bool(plan.get("apply_supply_settlement", false)):
		return
	var supply := _dictionary(plan.get("supply_settlement", {}))
	var defender := _dictionary(supply.get("defender", {}))
	var defender_change := apply_defender_supply(str(defender.get("city_id", "")), defender)
	if bool(defender_change.get("ok", false)):
		report["supply_changes"].append(defender_change)
	if str(plan.get("result_kind", "")) == RESULT_ATTACKER_WIN or str(plan.get("settlement_profile", "standard")) == "t02_return":
		var cargo := _dictionary(supply.get("attacker_cargo", {}))
		var cargo_change := apply_attacker_cargo(str(cargo.get("destination_city_id", "")), cargo)
		if bool(cargo_change.get("ok", false)):
			report["cargo_changes"].append(cargo_change)


func _apply_hero_status_plan(plan: Dictionary, report: Dictionary) -> void:
	var status_plan: Variant = plan.get("hero_status_plan", [])
	if not status_plan is Array:
		report["warnings"].append("invalid_hero_status_plan")
		return
	for entry_variant in status_plan:
		if not entry_variant is Dictionary:
			continue
		var entry := entry_variant as Dictionary
		var hero_id := str(entry.get("hero_id", ""))
		var status := str(entry.get("status", ""))
		if set_hero_status(hero_id, status, _dictionary(entry.get("outcome", {})), str(plan.get("transaction_id", ""))):
			report["hero_changes"].append({"hero_id": hero_id, "status": status, "kind": "status"})
		else:
			report["warnings"].append("hero_status_skipped:%s" % hero_id)


func _apply_hero_movements(plan: Dictionary, report: Dictionary) -> void:
	var movements: Variant = plan.get("hero_movements", [])
	if not movements is Array:
		return
	for movement_variant in movements:
		if not movement_variant is Dictionary:
			continue
		var movement := movement_variant as Dictionary
		var hero_id := str(movement.get("hero_id", ""))
		var city_id := str(movement.get("city_id", ""))
		if move_hero(hero_id, city_id):
			report["hero_changes"].append({"hero_id": hero_id, "city_id": city_id, "kind": "city"})


func _apply_hero_disposition(plan: Dictionary, report: Dictionary) -> void:
	var disposition := _dictionary(plan.get("defender_disposition", {}))
	for entry_variant in disposition.get("assignments", []):
		if not entry_variant is Dictionary:
			continue
		var entry := entry_variant as Dictionary
		var hero_id := str(entry.get("hero_id", ""))
		var faction_id := str(entry.get("faction_id", ""))
		var city_id := str(entry.get("city_id", ""))
		var acquired := bool(entry.get("acquired", false))
		if set_hero_faction(hero_id, faction_id, city_id, str(plan.get("transaction_id", "")) if acquired else "", str(disposition.get("defeated_owner", "")) if acquired else ""):
			report["hero_changes"].append({"hero_id": hero_id, "faction_id": faction_id, "city_id": city_id, "kind": "faction_and_city"})
	for hero_id_variant in disposition.get("unstationed_hero_ids", []):
		_m("unstation_hero", [str(hero_id_variant)], null)
	if not disposition.is_empty():
		_m("clear_city_governor", [str(plan.get("target_city_id", ""))], null)
		_m("record_defender_disposition", [disposition], null)
		report["defender_disposition"] = disposition.duplicate(true)


func _apply_city_troops(city_id: String, troops: int, report: Dictionary) -> void:
	if city_id.is_empty():
		return
	var before := maxi(0, int(_q("city_troops", [city_id], 0)))
	var after := maxi(0, troops)
	_m("set_city_troops", [city_id, after], null)
	report["troop_changes"].append({"city_id": city_id, "before": before, "after": after})


func _mark_applied(result_id: String) -> void:
	if not result_id.is_empty():
		_m("mark_result_applied", [result_id], null)


func _empty_report(plan: Dictionary) -> Dictionary:
	return {
		"ok": false,
		"battle_kind": str(plan.get("battle_kind", "")),
		"result_kind": str(plan.get("result_kind", "")),
		"target_city_id": str(plan.get("target_city_id", plan.get("defender_city_id", ""))),
		"transaction_id": str(plan.get("transaction_id", "")),
		"result_id": str(plan.get("result_id", "")),
		"duplicate": false,
		"troop_changes": [],
		"ownership_changed": false,
		"old_owner": "",
		"new_owner": "",
		"hero_changes": [],
		"supply_changes": [],
		"cargo_changes": [],
		"indexes_rebuilt": false,
		"warnings": [],
	}


func _reject(report: Dictionary, warning: String) -> Dictionary:
	report["warnings"].append(warning)
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
