class_name BattleReinforcementHelper
extends RefCounted


static func get_capacity_slot_id_for_legacy_slot_id(legacy_slot_id: String, legacy_to_capacity_slot_id: Dictionary) -> String:
	return String(legacy_to_capacity_slot_id.get(legacy_slot_id, ""))


static func get_legacy_slot_id_for_capacity_slot_id(capacity_slot_id: String, capacity_to_legacy_slot_id: Dictionary) -> String:
	return String(capacity_to_legacy_slot_id.get(capacity_slot_id, ""))
