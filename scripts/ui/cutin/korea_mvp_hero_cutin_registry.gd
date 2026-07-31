class_name KoreaMvpHeroCutinRegistry
extends RefCounted

const REGISTRY_PATH := "res://data/cutin/korea_mvp_hero_cutins.json"

static func load_entries() -> Array[Dictionary]:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(REGISTRY_PATH))
	if not parsed is Dictionary:
		push_error("Korea MVP cutin registry is not a JSON object: %s" % REGISTRY_PATH)
		return []
	var raw_entries: Variant = parsed.get("entries", [])
	if not raw_entries is Array:
		push_error("Korea MVP cutin registry entries are not an array: %s" % REGISTRY_PATH)
		return []
	var entries: Array[Dictionary] = []
	for raw_entry in raw_entries:
		if raw_entry is Dictionary:
			entries.append(raw_entry)
		else:
			push_error("Korea MVP cutin registry has a non-object entry")
	return entries


static func find_entry(hero_id: String, skill_id: String) -> Dictionary:
	if hero_id.is_empty() or skill_id.is_empty():
		return {}
	for entry in load_entries():
		if String(entry.get("hero_id", "")) != hero_id:
			continue
		if String(entry.get("skill_id", "")) == skill_id and bool(entry.get("enabled", false)):
			return entry.duplicate(true)
		return {}
	return {}
