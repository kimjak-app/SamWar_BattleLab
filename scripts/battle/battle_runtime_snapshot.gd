class_name BattleRuntimeSnapshot
extends RefCounted

const SCHEMA_VERSION := 1


static func capture(
	battle_id: String,
	battle_round: int,
	current_phase: String,
	units: Array[BattleUnitState],
	momentum: BattleMomentumState,
	extra_state: Dictionary = {}
) -> Dictionary:
	var serialized_units: Array[Dictionary] = []
	for unit in units:
		if unit != null:
			serialized_units.append(unit.serialize_battle_runtime())
	return {
		"schema_version": SCHEMA_VERSION,
		"battle_id": battle_id,
		"battle_round": maxi(battle_round, 1),
		"current_phase": current_phase,
		"units": serialized_units,
		"momentum": momentum.serialize() if momentum != null else {},
		"extra_state": extra_state.duplicate(true),
	}


static func restore(
	snapshot: Dictionary,
	expected_battle_id: String,
	units: Array[BattleUnitState],
	momentum: BattleMomentumState
) -> Dictionary:
	if int(snapshot.get("schema_version", 0)) != SCHEMA_VERSION:
		return _failure("schema_mismatch")
	if String(snapshot.get("battle_id", "")) != expected_battle_id:
		return _failure("battle_id_mismatch")
	var unit_lookup := {}
	for unit in units:
		if unit != null:
			unit_lookup[unit.unit_id] = unit
	var units_variant: Variant = snapshot.get("units", [])
	if not units_variant is Array:
		return _failure("units_not_array")
	for unit_snapshot_variant in units_variant:
		if not unit_snapshot_variant is Dictionary:
			return _failure("invalid_unit_snapshot")
		var unit_snapshot: Dictionary = unit_snapshot_variant
		var unit_id := String(unit_snapshot.get("unit_id", ""))
		var unit: BattleUnitState = unit_lookup.get(unit_id, null)
		if unit == null or not unit.restore_battle_runtime(unit_snapshot):
			return _failure("unit_restore_failed:%s" % unit_id)
	var momentum_variant: Variant = snapshot.get("momentum", {})
	if momentum == null or not momentum_variant is Dictionary \
			or not momentum.restore(momentum_variant as Dictionary):
		return _failure("momentum_restore_failed")
	var extra_variant: Variant = snapshot.get("extra_state", {})
	return {
		"ok": true,
		"battle_round": maxi(int(snapshot.get("battle_round", 1)), 1),
		"current_phase": String(snapshot.get("current_phase", "ally_turn")),
		"extra_state": (extra_variant as Dictionary).duplicate(true) if extra_variant is Dictionary else {},
	}


static func _failure(reason: String) -> Dictionary:
	return {"ok": false, "reason": reason}
