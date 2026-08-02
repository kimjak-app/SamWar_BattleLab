class_name KoreaMvpHeroCutinRegistry
extends RefCounted

const REGISTRY_PATH := "res://data/cutin/korea_mvp_hero_cutins.json"

## The cutin boundary receives both legacy battle IDs and canonical design IDs.
## Keep this as the single authoritative hero identity contract for cutin routing.
const HERO_ID_CANONICAL_ALIASES := {
	"yi_sunsin": "yi_sun_sin",
	"jeong_dojeon": "jeong_do_jeon",
	"gim_yusin": "kim_yu_sin",
	"gwon_yul": "kwon_yul",
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


static func canonicalize_hero_id(raw_id: String) -> String:
	var normalized_id := raw_id.strip_edges().to_lower()
	return String(HERO_ID_CANONICAL_ALIASES.get(normalized_id, normalized_id))


static func canonicalize_skill_id(raw_id: String) -> String:
	var normalized_id := raw_id.strip_edges().to_lower()
	return String(RUNTIME_SKILL_ID_ALIASES.get(normalized_id, normalized_id))


static func get_portrait_path(hero_id: String) -> String:
	var canonical_hero_id := canonicalize_hero_id(hero_id)
	if canonical_hero_id.is_empty():
		return ""
	var korea_portrait_path := "res://assets/heroes/portraits/korea/korea_%s.png" % canonical_hero_id
	if ResourceLoader.exists(korea_portrait_path):
		return korea_portrait_path
	var legacy_portrait_path := "res://assets/web_battle/portraits/%s_portrait.png" % canonical_hero_id
	if ResourceLoader.exists(legacy_portrait_path):
		return legacy_portrait_path
	return korea_portrait_path


static func find_entry(hero_id: String, skill_id: String) -> Dictionary:
	var canonical_hero_id := canonicalize_hero_id(hero_id)
	var canonical_skill_id := canonicalize_skill_id(skill_id)
	if canonical_hero_id.is_empty() or canonical_skill_id.is_empty():
		return {}
	for entry in load_entries():
		if canonicalize_hero_id(String(entry.get("hero_id", ""))) != canonical_hero_id:
			continue
		if canonicalize_skill_id(String(entry.get("skill_id", ""))) == canonical_skill_id and bool(entry.get("enabled", false)):
			return entry.duplicate(true)
	return {}
