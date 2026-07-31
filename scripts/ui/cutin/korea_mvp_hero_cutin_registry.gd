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
