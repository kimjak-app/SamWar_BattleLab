extends "res://scripts/battle_web_import_test.gd"

## Demo/Test2 scenario only.
##
## The Production HUD and battle controller remain inherited from
## Battle_UI_Production_Test. Only scenario roster/visual identity selection is
## overridden here so Test1 (Korea vs China) stays unchanged.

const IMJIN_TEST_BATTLE_ROSTER := {
	"ally_main_01": "yi_sun_sin",
	"ally_main_02": "gwak_jae_u",
	"ally_main_03": "kim_deok_ryeong",
	"ally_reinforce_01": "kwon_yul",
	"ally_reinforce_02": "go_gyeong_myeong",
	"enemy_main_01": "toyotomi_hideyoshi",
	"enemy_main_02": "shimazu_yoshihiro",
	"enemy_main_03": "kato_kiyomasa",
	"enemy_reinforce_01": "konishi_yukinaga",
	"enemy_reinforce_02": "kuroda_nagamasa",
}

const KOREA_DEMO_HERO_IDS := {
	"yi_sun_sin": true,
	"gwak_jae_u": true,
	"kim_deok_ryeong": true,
	"kwon_yul": true,
	"go_gyeong_myeong": true,
}
const JAPAN_DEMO_HERO_IDS := {
	"toyotomi_hideyoshi": true,
	"shimazu_yoshihiro": true,
	"kato_kiyomasa": true,
	"konishi_yukinaga": true,
	"kuroda_nagamasa": true,
}


func _get_test_battle_roster_hero_id(slot_id: String) -> String:
	return String(IMJIN_TEST_BATTLE_ROSTER.get(slot_id, ""))


func _get_hero_registry_entry(hero_id: String) -> Dictionary:
	var existing := super._get_hero_registry_entry(hero_id)
	if not existing.is_empty():
		return existing
	var hero_data := HeroDefinitionRegistry.get_hero(hero_id)
	if hero_data.is_empty():
		return {}
	var entry := _build_worldmap_context_hero_registry_entry(hero_data)
	entry["default_visual_key"] = _get_imjin_visual_key(hero_id, String(hero_data.get("unit_type", "infantry")))
	var actor_portrait := _get_imjin_current_actor_portrait_path(hero_id)
	if not actor_portrait.is_empty():
		entry["closeup_portrait_path"] = actor_portrait
		if String(hero_data.get("portrait_path", "")).is_empty():
			entry["battlefield_portrait_path"] = actor_portrait
	return entry


func _get_sample_unique_skill_entry_for_worldmap_hero(hero_data: Dictionary) -> Dictionary:
	var existing := super._get_sample_unique_skill_entry_for_worldmap_hero(hero_data)
	if not existing.is_empty():
		return existing
	return _build_worldmap_context_unique_skill_entry(hero_data)


func _get_imjin_visual_key(hero_id: String, unit_type: String) -> String:
	if KOREA_DEMO_HERO_IDS.has(hero_id):
		return "korea_%s" % unit_type
	if JAPAN_DEMO_HERO_IDS.has(hero_id):
		return "japan_%s" % unit_type
	return unit_type


func _get_imjin_current_actor_portrait_path(hero_id: String) -> String:
	var nation_dir := ""
	var prefix := ""
	if KOREA_DEMO_HERO_IDS.has(hero_id):
		nation_dir = "korea"
		prefix = "korea"
	elif JAPAN_DEMO_HERO_IDS.has(hero_id):
		nation_dir = "japan"
		prefix = "japan"
	else:
		return ""
	var path := "res://assets/heroes/portraits/current_actor/%s/%s_%s.png" % [nation_dir, prefix, hero_id]
	return path if FileAccess.file_exists(path) else ""
