class_name WorldMapSpyIntelSnapshotService
extends RefCounted

const STOCK_KEYS := ["gold", "rice", "barley", "seafood", "wood", "iron", "horses", "silk", "salt"]


# Only transforms observations supplied by the caller. The caller still owns
# collection, spy rolls and the existing estimated-report path.
static func build_snapshot(input: Dictionary) -> Dictionary:
	var precision := str(input.get("precision", ""))
	var unknown_fields: Array[String] = []
	var snapshot := {
		"city_id": input.get("city_id", ""),
		"observed_turn": input.get("observed_turn", -1),
		"precision": precision,
		"unknown_fields": unknown_fields,
	}
	var fields: Variant = input.get("fields", [])
	if not fields is Array:
		return snapshot
	if precision != "exact":
		snapshot["error"] = "unsupported_precision"
	for raw_field in fields:
		if not raw_field is String and not raw_field is StringName:
			continue
		var field := str(raw_field)
		if precision == "exact":
			if field == "resources":
				var stock: Variant = input.get("stock")
				if stock is Dictionary:
					var resources := {}
					for key in STOCK_KEYS:
						var amount: Variant = stock.get(key)
						if amount is int:
							resources[key] = maxi(0, amount)
						elif amount is float and is_finite(amount):
							resources[key] = maxi(0, int(amount))
						else:
							_append_unknown(unknown_fields, "resources." + key)
					snapshot[field] = resources
					continue
			elif field == "heroes":
				snapshot[field] = _collect_heroes(input.get("heroes", []), str(input.get("owner_faction_id", "")))
				continue
		_append_unknown(unknown_fields, field)
	return snapshot


static func _collect_heroes(rows: Variant, owner_faction_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if owner_faction_id.is_empty() or not rows is Array:
		return result
	var seen_ids := {}
	for raw_row in rows:
		if not raw_row is Dictionary:
			continue
		var row: Dictionary = raw_row
		var hero_id := str(row.get("hero_id", ""))
		var status := str(row.get("status", ""))
		if hero_id.is_empty() or seen_ids.has(hero_id) or str(row.get("faction_id", "")) != owner_faction_id:
			continue
		if status != "normal" and status != "wounded":
			continue
		seen_ids[hero_id] = true
		result.append({
			"hero_id": hero_id,
			"display_name": str(row.get("display_name", "")),
			"status": status,
			"role": str(row.get("role", "none")),
		})
	return result


static func _append_unknown(fields: Array[String], key: String) -> void:
	if not fields.has(key):
		fields.append(key)
