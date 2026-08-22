class_name KoreaMvpHeroCutinRegistry
extends RefCounted

const REGISTRY_PATH := "res://data/cutin/korea_mvp_hero_cutins.json"
const ADDITIONAL_REGISTRY_PATHS := [
	"res://data/cutin/imjin_demo_hero_cutins.json",
]

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
	"crescent_blade_slash": "guan_yu_unique",
	"changban_shatter": "zhang_fei_unique",
	"xiahou_dun_fierce_breakthrough": "xiahou_dun_unique",
	"liu_bei_banner_of_benevolence": "liu_bei_unique",
	"zhuge_liang_eight_trigram_formation": "zhuge_liang_unique",
}
const STATIC_FALLBACK_IMAGE_PATHS := {
	"guan_yu": {"skill_id": "guan_yu_unique", "path": "res://assets/web_battle/skill_cutins/guan_yu_crescent_blade_slash.png"},
	"zhang_fei": {"skill_id": "zhang_fei_unique", "path": "res://assets/web_battle/skill_cutins/zhang_fei_changban_shatter.png"},
	"xiahou_dun": {"skill_id": "xiahou_dun_unique", "path": "res://assets/web_battle/skill_cutins/xiahou_dun_fierce_breakthrough.png"},
	"liu_bei": {"skill_id": "liu_bei_unique", "path": "res://assets/web_battle/skill_cutins/liu_bei_banner_of_benevolence.png"},
	"zhuge_liang": {"skill_id": "zhuge_liang_unique", "path": "res://assets/web_battle/skill_cutins/zhuge_liang_eight_trigram_formation.png"},
}
const GENERIC_STATIC_FALLBACK_IMAGE_PATH := "res://assets/web_battle/ui/formation_guide/unique_skill_ready_icon.png"

static func load_entries() -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	_append_registry_entries(entries, REGISTRY_PATH)
	for registry_path_variant in ADDITIONAL_REGISTRY_PATHS:
		_append_registry_entries(entries, String(registry_path_variant))
	return entries


static func _append_registry_entries(entries: Array[Dictionary], registry_path: String) -> void:
	if not FileAccess.file_exists(registry_path):
		push_error("Hero cutin registry file is missing: %s" % registry_path)
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(registry_path))
	if not parsed is Dictionary:
		push_error("Hero cutin registry is not a JSON object: %s" % registry_path)
		return
	var raw_entries: Variant = parsed.get("entries", [])
	if not raw_entries is Array:
		push_error("Hero cutin registry entries are not an array: %s" % registry_path)
		return
	for raw_entry in raw_entries:
		if raw_entry is Dictionary:
			entries.append((raw_entry as Dictionary).duplicate(true))
		else:
			push_error("Hero cutin registry has a non-object entry: %s" % registry_path)


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
	var japan_portrait_path := "res://assets/heroes/portraits/japan/japan_%s.png" % canonical_hero_id
	if ResourceLoader.exists(japan_portrait_path):
		return japan_portrait_path
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


static func has_enabled_entry_for_hero(hero_id: String) -> bool:
	var canonical_hero_id := canonicalize_hero_id(hero_id)
	if canonical_hero_id.is_empty():
		return false
	for entry in load_entries():
		if canonicalize_hero_id(String(entry.get("hero_id", ""))) == canonical_hero_id and bool(entry.get("enabled", false)):
			return true
	return false


static func get_static_fallback_image_path(hero_id: String, skill_id: String) -> String:
	var canonical_hero_id := canonicalize_hero_id(hero_id)
	var canonical_skill_id := canonicalize_skill_id(skill_id)
	var configured_entry: Dictionary = STATIC_FALLBACK_IMAGE_PATHS.get(canonical_hero_id, {})
	if not configured_entry.is_empty() and canonicalize_skill_id(String(configured_entry.get("skill_id", ""))) == canonical_skill_id:
		var configured_path := String(configured_entry.get("path", ""))
		if ResourceLoader.exists(configured_path):
			return configured_path
	if ResourceLoader.exists(GENERIC_STATIC_FALLBACK_IMAGE_PATH):
		return GENERIC_STATIC_FALLBACK_IMAGE_PATH
	return ""
