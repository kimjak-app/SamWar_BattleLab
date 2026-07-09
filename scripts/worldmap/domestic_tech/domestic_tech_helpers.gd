extends RefCounted


static func get_duration_class_mvp(tier: int, rarity: int) -> String:
	if rarity >= 2:
		return "legendary"
	if rarity >= 1 or tier >= 4:
		return "advanced"
	if tier >= 3:
		return "mid"
	return "basic"


static func get_duration_turns_hint_mvp(tier: int, rarity: int) -> Dictionary:
	var duration_turns := get_tier_duration_turns_mvp(tier)
	return {"min": duration_turns, "max": duration_turns, "rule": "tier_based", "rarity": rarity}


static func get_tier_duration_turns_mvp(tier: int) -> int:
	match clampi(tier, 1, 5):
		1:
			return 2
		2:
			return 3
		3:
			return 5
		4:
			return 7
		_:
			return 8


static func get_scope_duration_turns_mvp(scope: String, tier: int, rarity: int, national_scope_id: String) -> int:
	var safe_tier := clampi(tier, 1, 5)
	var duration_turns := 2
	if scope == national_scope_id:
		match safe_tier:
			1:
				duration_turns = 3
			2:
				duration_turns = 4
			3:
				duration_turns = 6
			4:
				duration_turns = 8
			_:
				duration_turns = 9
	else:
		match safe_tier:
			1:
				duration_turns = 2
			2:
				duration_turns = 3
			3:
				duration_turns = 5
			4:
				duration_turns = 6
			_:
				duration_turns = 8
	if rarity >= 2:
		duration_turns += 1
	return duration_turns


static func format_percent_bonus_mvp(value: float) -> String:
	return "%s%%" % _format_signed_int(int(round(value * 100.0)))


static func get_unique_source_ids_mvp(source_techs: Variant) -> Array[String]:
	var result: Array[String] = []
	if not source_techs is Array:
		return result
	var seen := {}
	for tech_id_variant in source_techs:
		var tech_id := str(tech_id_variant)
		if tech_id.is_empty() or seen.has(tech_id):
			continue
		seen[tech_id] = true
		result.append(tech_id)
	return result


static func get_ui64_icon_filename_mvp(tech_id: String, filename_map: Dictionary) -> String:
	return str(filename_map.get(tech_id, ""))


static func get_resolved_icon_path_mvp(tech_id: String, definition_icon_path: String, ui64_icon_root: String, filename_map: Dictionary) -> String:
	var ui64_filename := get_ui64_icon_filename_mvp(tech_id, filename_map)
	if not ui64_filename.is_empty():
		var ui64_path := ui64_icon_root + ui64_filename
		if ResourceLoader.exists(ui64_path):
			return ui64_path
	if not definition_icon_path.is_empty() and ResourceLoader.exists(definition_icon_path):
		return definition_icon_path
	return ""


static func _format_signed_int(value: int) -> String:
	if value > 0:
		return "+%d" % value
	return str(value)
