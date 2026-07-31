extends SceneTree

const HeroDefinitionRegistryScript := preload("res://scripts/worldmap/hero_definition_registry.gd")
const HeroPortraitHelper := preload("res://scripts/worldmap_hero_portrait_helper.gd")

const KOREA_MVP_HERO_IDS := [
	"yi_sun_sin",
	"uija_wang",
	"kim_yu_sin",
	"kim_chun_chu",
	"jeong_do_jeon",
	"jang_bo_go",
	"heukchi_sangji",
	"gyebaek",
	"kwon_yul",
	"gwanggaeto",
	"eulji_mundeok",
	"dorim",
	"cheok_jun_gyeong",
]


func _init() -> void:
	var passed := 0
	for hero_id in KOREA_MVP_HERO_IDS:
		if _validate_hero_round_trip(hero_id):
			passed += 1
	if passed == KOREA_MVP_HERO_IDS.size():
		print("[GARRISON_HERO_PARITY] %d/%d PASS" % [passed, KOREA_MVP_HERO_IDS.size()])
		quit(0)
		return
	push_error("[GARRISON_HERO_PARITY] %d/%d FAIL" % [passed, KOREA_MVP_HERO_IDS.size()])
	quit(1)


func _validate_hero_round_trip(hero_id: String) -> bool:
	var authoritative := HeroDefinitionRegistryScript.get_hero(hero_id)
	if authoritative.is_empty() or str(authoritative.get("hero_id", "")) != hero_id:
		push_error("[GARRISON_HERO_PARITY] %s FAIL reason=authoritative_id" % hero_id)
		return false

	# Mirrors the WorldMap contract: static registry metadata is retained while
	# only mutable battle/settlement state is overlaid for the garrison UI.
	var battle_result_state := {
		"current_city_id": "sabi",
		"city_id": "sabi",
		"status": "wounded",
		"wounded": true,
		"wounded_turns_remaining": 2,
		"last_battle_current_troops": 37,
	}
	var garrison_hero := authoritative.duplicate(true)
	for state_key in battle_result_state:
		garrison_hero[state_key] = battle_result_state[state_key]
	if str(garrison_hero.get("hero_id", "")) != hero_id \
		or str(garrison_hero.get("current_city_id", "")) != "sabi" \
		or not bool(garrison_hero.get("wounded", false)):
		push_error("[GARRISON_HERO_PARITY] %s FAIL reason=mutable_state_merge" % hero_id)
		return false

	var portrait_path := HeroPortraitHelper.get_hero_portrait_path(garrison_hero)
	var portrait_texture := HeroPortraitHelper.load_hero_portrait_texture(garrison_hero)
	if portrait_path.is_empty() or portrait_texture == null:
		push_error("[GARRISON_HERO_PARITY] %s FAIL reason=portrait_unresolvable path=%s" % [hero_id, portrait_path])
		return false
	print("[GARRISON_HERO_PARITY] %s PASS path=%s" % [hero_id, portrait_path])
	return true
