extends RefCounted
# HUD block 4-1: the approved read-only access to the hero data registry (data
# outside the engine) for the current-actor HUD. Only get_base_stats,
# get_battle_profile and get_unique_skill_for_hero are called; every result is a
# deep copy. The registry reads its JSON files once into its own static cache
# on the first call (not engine state). The hero id aliases are the 2D
# current-actor bridge's (battle_current_actor_hud_controller.gd HERO_ID_ALIASES).
const Registry := preload("res://scripts/worldmap/hero_design_data_registry.gd")
const HERO_ID_ALIASES := {
	"yi_sunsin": "yi_sun_sin",
	"jeong_dojeon": "jeong_do_jeon",
	"gim_yusin": "kim_yu_sin",
	"gwon_yul": "kwon_yul",
}

static func resolve_hero_id(read_hero_id: String, unit_id: String) -> String:
	# Like the 2D _resolve_hero_id: the hero id read from the engine (N6, by the lab), else the unit id without "_battle_unit", then the alias table.
	var hero_id := read_hero_id
	if hero_id.is_empty():
		hero_id = unit_id.trim_suffix("_battle_unit") if unit_id.ends_with("_battle_unit") else unit_id
	return str(HERO_ID_ALIASES.get(hero_id, hero_id))

static func base_stats(hero_id: String) -> Dictionary:
	return {} if hero_id.is_empty() else Registry.get_base_stats(hero_id).duplicate(true)

static func battle_profile(hero_id: String) -> Dictionary:
	return {} if hero_id.is_empty() else Registry.get_battle_profile(hero_id).duplicate(true)

static func unique_skill_for_hero(hero_id: String) -> Dictionary:
	return {} if hero_id.is_empty() else Registry.get_unique_skill_for_hero(hero_id).duplicate(true)

# The 2D current-actor portrait file (battle_current_actor_hud_controller.gd
# _get_current_actor_country / _get_current_actor_portrait): the first country
# whose current_actor/<country>/<country>_<hero_id>.png exists, cached per hero.
const PORTRAIT_COUNTRIES := ["korea", "china", "japan", "mongol"]
const PORTRAIT_PATH := "res://assets/heroes/portraits/current_actor/%s/%s_%s.png"
static var countries := {} # hero_id -> country ("" = none)
static var portraits := {} # hero_id -> Texture2D or null

static func portrait_country(hero_id: String) -> String:
	if hero_id.is_empty(): return ""
	if not countries.has(hero_id):
		countries[hero_id] = ""
		for country in PORTRAIT_COUNTRIES:
			if ResourceLoader.exists(PORTRAIT_PATH % [country, country, hero_id]):
				countries[hero_id] = country
				break
	return countries[hero_id]

static func current_actor_portrait(hero_id: String) -> Texture2D:
	if hero_id.is_empty(): return null
	if not portraits.has(hero_id):
		var country := portrait_country(hero_id)
		var resource = null if country.is_empty() else ResourceLoader.load(PORTRAIT_PATH % [country, country, hero_id])
		portraits[hero_id] = resource if resource is Texture2D else null
	return portraits[hero_id]
