extends "res://scripts/battle_web_import_test.gd"

## Demo/Test2 scenario only.
##
## The Production HUD and battle controller remain inherited from
## Battle_UI_Production_Test. Test2 swaps only scenario identity/content while
## reusing the same battle core and Production HUD.

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
const REGULAR_PORTRAIT_STEM_OVERRIDES := {
	"kwon_yul": "gwon_yul",
}


func _create_demo_unit_states() -> void:
	# The inherited Test1 builder owns positions, troop allocation, turn flags and
	# battle wiring. Immediately after it builds the ten state objects, rebind
	# each object to Test2's canonical hero id. BattleUnitState.unit_id is an
	# authority setter: assigning a registered hero id refreshes the authoritative
	# unit type, stats and unique-skill definition from HERO_DATA/design JSON.
	super._create_demo_unit_states()
	_rebind_imjin_demo_state(ally_unit_state, "ally_main_01")
	_rebind_imjin_demo_state(ally_support_unit_state, "ally_main_02")
	_rebind_imjin_demo_state(ally_main_03_unit_state, "ally_main_03")
	_rebind_imjin_demo_state(ally_reinforce_01_unit_state, "ally_reinforce_01")
	_rebind_imjin_demo_state(ally_reinforce_02_unit_state, "ally_reinforce_02")
	_rebind_imjin_demo_state(enemy_unit_state, "enemy_main_01")
	_rebind_imjin_demo_state(enemy_support_unit_state, "enemy_main_02")
	_rebind_imjin_demo_state(enemy_main_03_unit_state, "enemy_main_03")
	_rebind_imjin_demo_state(enemy_reinforce_01_unit_state, "enemy_reinforce_01")
	_rebind_imjin_demo_state(enemy_reinforce_02_unit_state, "enemy_reinforce_02")


func _rebind_imjin_demo_state(unit_state: BattleUnitState, slot_id: String) -> void:
	if unit_state == null:
		return
	var hero_id := _get_test_battle_roster_hero_id(slot_id)
	if hero_id.is_empty():
		return
	# Set capacity slot first so the authority rebuild sees the final slot id.
	unit_state.slot_id = slot_id
	unit_state.unit_id = hero_id
	# HERO_DATA owns combat authority. These two fields are presentation-only and
	# select the correct nation-specific troop visuals for this scenario.
	unit_state.nation = _get_imjin_nation_key(hero_id)
	unit_state.visual_key = _get_imjin_visual_key(hero_id, unit_state.unit_type)
	unit_state.portrait_key = hero_id


func _get_test_battle_roster_hero_id(slot_id: String) -> String:
	return String(IMJIN_TEST_BATTLE_ROSTER.get(slot_id, ""))


func _get_hero_registry_entry(hero_id: String) -> Dictionary:
	var entry := super._get_hero_registry_entry(hero_id)
	var hero_data := HeroDefinitionRegistry.get_hero(hero_id)
	if entry.is_empty() and not hero_data.is_empty():
		entry = _build_worldmap_context_hero_registry_entry(hero_data)
	if entry.is_empty():
		return {}
	# Parent registries may return const/read-only dictionaries. Test2 only needs
	# presentation overrides, so always detach into a writable deep copy before
	# mutating visual/portrait fields.
	entry = entry.duplicate(true)
	entry["default_visual_key"] = _get_imjin_visual_key(
		hero_id,
		String(hero_data.get("unit_type", entry.get("unit_type", "infantry")))
	)
	# Roster/close-up surfaces use the normal portrait. The large cinematic
	# current_actor image is intentionally NOT placed in closeup_portrait_path;
	# battle_ui_production_test_bottom_hud.gd owns that separate contract.
	var regular_portrait := _get_imjin_regular_portrait_path(hero_id)
	if not regular_portrait.is_empty():
		entry["closeup_portrait_path"] = regular_portrait
		entry["battlefield_portrait_path"] = regular_portrait
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


func _get_imjin_nation_key(hero_id: String) -> String:
	if KOREA_DEMO_HERO_IDS.has(hero_id):
		return "korea"
	if JAPAN_DEMO_HERO_IDS.has(hero_id):
		return "japan"
	return ""


func _get_imjin_regular_portrait_path(hero_id: String) -> String:
	var nation_dir := _get_imjin_nation_key(hero_id)
	if nation_dir.is_empty():
		return ""
	var stem := String(REGULAR_PORTRAIT_STEM_OVERRIDES.get(hero_id, hero_id))
	var path := "res://assets/heroes/portraits/%s/%s_%s.png" % [nation_dir, nation_dir, stem]
	return path if FileAccess.file_exists(path) else ""
