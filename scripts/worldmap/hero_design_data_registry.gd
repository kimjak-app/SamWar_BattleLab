class_name HeroDesignDataRegistry
extends RefCounted

const BASE_STATS_PATH := "res://data/heroes/generated/hero_base_stats.json"
const INITIAL_LOYALTY_PATH := "res://data/heroes/generated/hero_initial_loyalty.json"
const BATTLE_PROFILES_PATH := "res://data/heroes/generated/hero_battle_profiles.json"
const UNIQUE_SKILLS_PATH := "res://data/heroes/generated/hero_unique_skills.json"
const UNIT_TYPE_RULES_PATH := "res://data/heroes/generated/unit_type_rules.json"
const BATTLE_ROLE_RULES_PATH := "res://data/heroes/generated/battle_role_rules.json"
const EXPECTED_HERO_COUNT := 39

static var _loaded := false
static var _load_error := ""
static var _base_stats_by_hero: Dictionary = {}
static var _initial_loyalty_by_hero: Dictionary = {}
static var _battle_profiles_by_hero: Dictionary = {}
static var _unique_skills_by_id: Dictionary = {}
static var _unit_type_rules_by_id: Dictionary = {}
static var _battle_role_rules_by_id: Dictionary = {}

static func ensure_loaded() -> bool:
	if _loaded:
		return _load_error.is_empty()

	_loaded = true
	_load_error = ""
	_base_stats_by_hero = _index_records(BASE_STATS_PATH, "heroes", "hero_id")
	_initial_loyalty_by_hero = _index_records(INITIAL_LOYALTY_PATH, "heroes", "hero_id")
	_battle_profiles_by_hero = _index_records(BATTLE_PROFILES_PATH, "profiles", "hero_id")
	_unique_skills_by_id = _index_records(UNIQUE_SKILLS_PATH, "skills", "skill_id")
	_unit_type_rules_by_id = _index_records(UNIT_TYPE_RULES_PATH, "unit_types", "unit_type")
	_battle_role_rules_by_id = _index_records(BATTLE_ROLE_RULES_PATH, "roles", "role")

	if not _load_error.is_empty():
		return false
	if _base_stats_by_hero.size() != EXPECTED_HERO_COUNT:
		_load_error = "hero_base_stats count mismatch: %d" % _base_stats_by_hero.size()
		return false
	if _initial_loyalty_by_hero.size() != EXPECTED_HERO_COUNT:
		_load_error = "hero_initial_loyalty count mismatch: %d" % _initial_loyalty_by_hero.size()
		return false
	if _battle_profiles_by_hero.size() != EXPECTED_HERO_COUNT:
		_load_error = "hero_battle_profiles count mismatch: %d" % _battle_profiles_by_hero.size()
		return false
	if _unique_skills_by_id.size() != EXPECTED_HERO_COUNT:
		_load_error = "hero_unique_skills count mismatch: %d" % _unique_skills_by_id.size()
		return false
	return true

static func get_load_error() -> String:
	ensure_loaded()
	return _load_error

static func get_base_stats(hero_id: String) -> Dictionary:
	if not ensure_loaded():
		return {}
	return _base_stats_by_hero.get(hero_id, {}).duplicate(true)

static func get_initial_loyalty_record(hero_id: String) -> Dictionary:
	if not ensure_loaded():
		return {}
	return _initial_loyalty_by_hero.get(hero_id, {}).duplicate(true)

static func get_initial_loyalty(hero_id: String, fallback: int = 100) -> int:
	var record := get_initial_loyalty_record(hero_id)
	if record.is_empty():
		return clampi(fallback, 0, 100)
	return clampi(int(record.get("initial_loyalty", fallback)), 0, 100)

static func get_battle_profile(hero_id: String) -> Dictionary:
	if not ensure_loaded():
		return {}
	return _battle_profiles_by_hero.get(hero_id, {}).duplicate(true)

static func get_unique_skill(skill_id: String) -> Dictionary:
	if not ensure_loaded():
		return {}
	return _unique_skills_by_id.get(skill_id, {}).duplicate(true)

static func get_unique_skill_for_hero(hero_id: String) -> Dictionary:
	var profile := get_battle_profile(hero_id)
	var skill_id := String(profile.get("unique_skill_id", ""))
	if skill_id.is_empty():
		return {}
	return get_unique_skill(skill_id)

static func get_unit_type_rule(unit_type: String) -> Dictionary:
	if not ensure_loaded():
		return {}
	return _unit_type_rules_by_id.get(unit_type, {}).duplicate(true)

static func get_battle_role_rule(role_id: String) -> Dictionary:
	if not ensure_loaded():
		return {}
	return _battle_role_rules_by_id.get(role_id, {}).duplicate(true)

static func get_all_hero_ids() -> Array[String]:
	if not ensure_loaded():
		return []
	var result: Array[String] = []
	for hero_id in _base_stats_by_hero.keys():
		result.append(String(hero_id))
	return result

static func _index_records(path: String, array_key: String, id_key: String) -> Dictionary:
	var payload := _load_json_object(path)
	if payload.is_empty():
		return {}
	if int(payload.get("schema_version", 0)) != 1:
		_load_error = "%s: unsupported schema_version" % path
		return {}
	var records: Variant = payload.get(array_key, [])
	if not records is Array:
		_load_error = "%s: %s must be an Array" % [path, array_key]
		return {}
	var result := {}
	for record_variant in records:
		if not record_variant is Dictionary:
			_load_error = "%s: invalid record" % path
			return {}
		var record: Dictionary = record_variant
		var record_id := String(record.get(id_key, ""))
		if record_id.is_empty() or result.has(record_id):
			_load_error = "%s: empty or duplicate %s" % [path, id_key]
			return {}
		result[record_id] = record.duplicate(true)
	return result

static func _load_json_object(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		_load_error = "Missing design JSON: %s" % path
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		_load_error = "Cannot open design JSON: %s" % path
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		_load_error = "Invalid JSON object: %s" % path
		return {}
	return parsed
