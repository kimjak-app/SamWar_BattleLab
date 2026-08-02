class_name KoreaMvpHeroCutinRegistry
extends RefCounted

const REGISTRY_PATH := "res://data/cutin/korea_mvp_hero_cutins.json"

const RUNTIME_HERO_ID_ALIASES := {
	"yi_sunsin": "yi_sun_sin",
	"jeong_dojeon": "jeong_do_jeon",
	"gim_yusin": "kim_yu_sin",
}
const RUNTIME_SKILL_ID_ALIASES := {
	"hakikjin_barrage": "yi_sun_sin_unique",
	"reform_order": "jeong_do_jeon_unique",
	"gwon_yul_haengju_defense": "kwon_yul_unique",
	"kim_yu_sin_unification_charge": "kim_yu_sin_unique",
	"eulji_mundeok_salsu_ambush": "eulji_mundeok_unique",
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
	var resolved_hero_id := String(RUNTIME_HERO_ID_ALIASES.get(hero_id, hero_id))
	var resolved_skill_id := String(RUNTIME_SKILL_ID_ALIASES.get(skill_id, skill_id))
	for entry in load_entries():
		if String(entry.get("hero_id", "")) != resolved_hero_id:
			continue
		if String(entry.get("skill_id", "")) == resolved_skill_id and bool(entry.get("enabled", false)):
			return entry.duplicate(true)
	return {}
