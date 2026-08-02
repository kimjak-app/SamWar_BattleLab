class_name KoreaMvpHeroCutinRegistry
extends RefCounted

const REGISTRY_PATH := "res://data/cutin/korea_mvp_hero_cutins.json"

const RUNTIME_KEY_ALIASES := {
	"yi_sunsin|hakikjin_barrage": ["yi_sun_sin", "yi_sun_sin_unique"],
	"jeong_dojeon|reform_order": ["jeong_do_jeon", "jeong_do_jeon_unique"],
	"kwon_yul|gwon_yul_haengju_defense": ["kwon_yul", "kwon_yul_unique"],
	"gim_yusin|kim_yu_sin_unification_charge": ["kim_yu_sin", "kim_yu_sin_unique"],
	"eulji_mundeok|eulji_mundeok_salsu_ambush": ["eulji_mundeok", "eulji_mundeok_unique"],
}

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
	var resolved_hero_id := hero_id
	var resolved_skill_id := skill_id
	var alias: Array = RUNTIME_KEY_ALIASES.get("%s|%s" % [hero_id, skill_id], [])
	if alias.size() == 2:
		resolved_hero_id = String(alias[0])
		resolved_skill_id = String(alias[1])
	for entry in load_entries():
		if String(entry.get("hero_id", "")) != resolved_hero_id:
			continue
		if String(entry.get("skill_id", "")) == resolved_skill_id and bool(entry.get("enabled", false)):
			return entry.duplicate(true)
	return {}
