extends Node2D

const HeroPortraitHelper := preload("res://scripts/worldmap_hero_portrait_helper.gd")

const WORLD_MAP_CAMERA_SPEED := 900.0
const WORLD_MAP_CAMERA_DRAG_SPEED := 1.0
const WORLD_MAP_MIN_ZOOM := 0.35
const WORLD_MAP_MAX_ZOOM := 1.6
const WORLD_MAP_CLAMP_PADDING := 24.0
const WORLD_MAP_ZOOM_STEP := 0.1
const PLAYER_FACTION_ID := "player"
const UNIFIED_PANEL_TAB_CITY_DETAIL := "city-detail"
const UNIFIED_PANEL_TAB_DIPLOMACY_SPY := "diplomacy-spy"
const CITY_DETAIL_TAB_RESOURCES := "resources"
const CITY_DETAIL_TAB_INTERNAL_TRADE := "internal-trade"
const CITY_DETAIL_TAB_EXTERNAL_TRADE := "external-trade"
const DIPLOMACY_SPY_TAB_DIPLOMACY := "diplomacy"
const DIPLOMACY_SPY_TAB_SPY := "spy"
const UNIFIED_PANEL_COLLAPSED_LABEL := "도시상세 / 외교·첩보 열기"
const UNIFIED_PANEL_COLLAPSED_HEIGHT := 48.0
const UNIFIED_PANEL_MIN_EXPANDED_HEIGHT := 188.0
const UNIFIED_PANEL_SCREEN_PADDING := 18.0
const UNIFIED_PANEL_COLLAPSED_DRAG_THRESHOLD := 6.0
const WORLDMAP_SAVE_PATH := "user://worldmap_left_panel_state.json"
const TURN_PHASE_PLAYER := "player"
const TURN_PHASE_ENEMY := "enemy"
const ENEMY_TURN_MVP_DELAY := 0.75
const ENEMY_INVASION_CHANCE := 0.45
const WORLD_CALENDAR_START_YEAR := 154
const WORLD_CALENDAR_SEASON_TURNS := 10
const WORLD_CALENDAR_YEAR_TURNS := 40
const WORLD_CALENDAR_SEASON_ORDER := ["spring", "summer", "autumn", "winter"]
const WORLD_CALENDAR_SEASON_LABELS := {
	"spring": "봄",
	"summer": "여름",
	"autumn": "가을",
	"winter": "겨울",
}
const DOMESTIC_INCOME_RULES := {
	"seafood_per_rating_per_turn": 2,
	"barley_per_rating_in_spring": 5,
	"rice_per_rating_in_autumn": 5,
}
const POPULATION_TAX_POINT_PER_RATING := 3
const COMMERCE_TAX_POINT_PER_RATING := 3
const TAX_POINT_TO_GOLD := 1
const CHANCELLOR_PRIMARY_RATE := 0.03
const CHANCELLOR_SECONDARY_RATE := 0.015

# v0.68b-12b-10b WorldMap Hero Portrait Asset Binding MVP
# v0.68b-12b-11 WorldMap Enemy Invasion BattleContext Bridge
# v0.68b-12b-12 WorldMap Enemy Invasion Battle Scene Handoff MVP
# v0.68b-12b-14 WorldMap Battle Result Return MVP
# v0.68b-12b-14-hotfix2 Integer Division Warning Cleanup
# v0.68b-12b-14-hotfix1 Unified Panel Chrome Nil Visible Guard
# v0.68b-12b-15 WorldMap Invasion Result Ownership Troop Apply MVP

const WORLDMAP_BATTLE_CONTEXT_META_KEY := "samwar_worldmap_battle_context"
const WORLDMAP_BATTLE_RESULT_META_KEY := "samwar_worldmap_battle_result"
const WORLDMAP_BATTLE_SCENE_PATH := "res://Battle_Fullscreen_Test.tscn"
const INVASION_RESULT_DEFENDER_WIN := "defender_win"
const INVASION_RESULT_ATTACKER_WIN := "attacker_win"
const INVASION_RESULT_RETREAT := "retreat"
const INVASION_RESULT_UNKNOWN := "unknown"
const INVASION_RESULT_DEFAULT_OCCUPATION_TROOPS := 100
const INVASION_RESULT_DEFENDER_WIN_DEFENDER_TROOP_RATE := 0.90
const INVASION_RESULT_DEFENDER_WIN_ATTACKER_TROOP_RATE := 0.80

const REGION_LABELS := {
	"region.china_mainland": "중국대륙",
	"region.korean_peninsula": "한반도",
	"region.japanese_archipelago": "일본열도",
	"region.northern_steppe": "북방초원",
}

const FACTION_LABELS := {
	"player": "PLAYER",
	"goguryeo": "GOGURYEO",
	"baekje_faction": "BAEKJE",
	"silla": "SILLA",
	"chu": "CHU",
	"wei": "WEI",
	"shu": "SHU",
	"wu": "WU",
	"oda": "ODA",
	"toyotomi": "TOYOTOMI",
	"kyushu_faction": "KYUSHU",
	"tokugawa": "TOKUGAWA",
	"mongol_faction": "MONGOL",
}

const CITY_TYPE_LABELS := {
	"hanseong": "상업 수도",
	"pyeongyang": "북방 요새",
	"gyeongju": "왕도",
	"sabi": "강역 거점",
	"luoyang": "중원 수도",
	"yecheng": "군사 거점",
	"chengdu": "산악 거점",
	"jianye": "강남 항구",
	"karakorum": "초원 본거지",
	"kyoto": "열도 수도",
	"osaka": "상업 항구",
	"kyushu": "해상 거점",
	"edo": "동방 성곽",
}

const CHANCELLOR_POLICY_DATA := {
	"balanced": {
		"name": "균형형",
		"description": "보정 없음",
		"income_multiplier": 1.0,
		"rice_multiplier": 1.0,
		"barley_multiplier": 1.0,
		"seafood_multiplier": 1.0,
		"gold_multiplier": 1.0,
		"hero_upkeep_multiplier": 1.0,
		"soldier_upkeep_preview_multiplier": 1.0,
		"salt_preservation_multiplier": 1.0,
	},
	"agriculture": {
		"name": "농업 중심",
		"description": "쌀/보리 수입 증가, 금전 소폭 감소",
		"income_multiplier": 1.0,
		"rice_multiplier": 1.15,
		"barley_multiplier": 1.15,
		"seafood_multiplier": 1.0,
		"gold_multiplier": 0.95,
		"hero_upkeep_multiplier": 1.0,
		"soldier_upkeep_preview_multiplier": 1.0,
		"salt_preservation_multiplier": 1.0,
	},
	"commerce": {
		"name": "상업 중심",
		"description": "금전 수입 증가, 식량 수입 소폭 감소",
		"income_multiplier": 1.0,
		"rice_multiplier": 0.95,
		"barley_multiplier": 0.95,
		"seafood_multiplier": 1.0,
		"gold_multiplier": 1.15,
		"hero_upkeep_multiplier": 1.0,
		"soldier_upkeep_preview_multiplier": 1.0,
		"salt_preservation_multiplier": 1.0,
	},
	"trade": {
		"name": "무역 중심",
		"description": "수산물/금전 소폭 증가, 소금 보존 부담 완화",
		"income_multiplier": 1.0,
		"rice_multiplier": 1.0,
		"barley_multiplier": 1.0,
		"seafood_multiplier": 1.1,
		"gold_multiplier": 1.05,
		"hero_upkeep_multiplier": 1.0,
		"soldier_upkeep_preview_multiplier": 1.0,
		"salt_preservation_multiplier": 0.9,
	},
	"military": {
		"name": "군사 중심",
		"description": "영웅 유지비 감소, 금전 소폭 감소",
		"income_multiplier": 1.0,
		"rice_multiplier": 1.0,
		"barley_multiplier": 1.0,
		"seafood_multiplier": 1.0,
		"gold_multiplier": 0.95,
		"hero_upkeep_multiplier": 0.9,
		"soldier_upkeep_preview_multiplier": 0.9,
		"salt_preservation_multiplier": 1.0,
	},
}

const CHANCELLOR_POLICY_ORDER := ["balanced", "agriculture", "commerce", "trade", "military"]

const CHANCELLOR_TYPE_LABELS := {
	"political": "정치형",
	"economic": "경제형",
	"administrative": "행정형",
	"diplomatic": "외교형",
	"militaryAdmin": "군정형",
}

const RESOURCE_LABELS := {
	"rice": "쌀",
	"barley": "보리",
	"seafood": "수산물",
	"wood": "목재",
	"iron": "철",
	"horses": "말",
	"silk": "비단",
	"salt": "소금",
	"gold": "금전",
}

const RESOURCE_DISPLAY_ORDER := ["rice", "barley", "seafood", "wood", "iron", "horses", "silk", "salt", "gold"]
const WAREHOUSE_CAPACITY := {
	"rice": 1000,
	"barley": 1000,
	"seafood": 500,
	"wood": 800,
	"iron": 500,
	"horses": 300,
	"silk": 300,
	"salt": 400,
	"gold": 9999,
}
const WAREHOUSE_LOW_RATIO := 0.2
const WAREHOUSE_STABLE_RATIO := 0.8
const HERO_UPKEEP_RULES := {"rice": 8, "seafood": 3, "silk": 1}
const SOLDIER_UPKEEP_RULES := {"troops_per_unit": 100, "rice": 6, "barley": 5, "seafood": 1}
const SALT_PRESERVATION_RULES := {"food_ratio": 0.08, "seafood_ratio": 0.12}

const GOVERNOR_POLICY_DATA := {
	"follow_chancellor": {
		"name": "재상 정책 수행",
		"description": "도시 운영 효과 적용 · Godot에서는 표시 전용",
	},
	"agriculture": {
		"name": "농업 중심",
		"description": "도시 운영 효과 적용 · Godot에서는 표시 전용",
	},
	"commerce": {
		"name": "상업 중심",
		"description": "도시 운영 효과 적용 · Godot에서는 표시 전용",
	},
	"military": {
		"name": "군사 중심",
		"description": "도시 운영 효과 적용 · Godot에서는 표시 전용",
	},
}

# v0.68b-12b-1 WorldMap Hero City Seed Data Import
# v0.68b-12b-2 WorldMap Left Panel Seed Binding QA
# v0.68b-12b-2 WorldMap Left Panel Web Parity Controls MVP
# v0.68b-12b-3 WorldMap Chancellor Policy + National Warehouse Web Parity MVP
# v0.68b-12b-3a WorldMap National Warehouse Card UI Cleanup
# v0.68b-12b-4 WorldMap Turn End + Save Management Web Parity MVP
# v0.68b-12b-5 WorldMap Enemy Turn Return / Turn Cycle MVP
# v0.68b-12b-6 WorldMap Turn Domestic Apply Web Parity MVP
# v0.68b-12b-7 WorldMap Domestic Apply Visual QA + Balance Check
# v0.68b-12b-9 WorldMap Enemy Invasion Event MVP
# v0.68b-12b-10 WorldMap Enemy Invasion Choice UI MVP
# v0.68b-12b-10a WorldMap Right City Info Panel Web Parity Cleanup
# Seed-only alignment from SamWar_web data/heroes.js, data/cities.js, and data/battle_rosters.js.
const HERO_DATA := {
	"yi_sun_sin": {"id": "yi_sun_sin", "hero_id": "yi_sun_sin", "display_name": "이순신", "name": "이순신", "role": "수군 지휘", "web_role": "ranged", "faction_id": "goryeo_joseon", "force_id": "goryeo_joseon", "side": "player", "nation": "player", "command_rank": "general", "politics": 76, "war": 90, "intelligence": 85, "loyalty": 98, "assigned_city_id": "hanseong", "city_id": "hanseong", "location_city_id": "hanseong", "troops": 110, "max_troops": 110, "max_hp": 110, "attack": 32, "defense": 16, "move_range": 2, "attack_range": 3, "skill_range": 3, "unique_skill_id": "hakikjin_barrage", "portrait_image": "assets/portraits/yi_sunsin_portrait.png", "battlefield_portrait_image": "assets/portraits_battlefield/yi_sunsin_battlefield.png", "chancellor_primary_type": "militaryAdmin", "chancellor_primary_aptitude": 5, "chancellor_secondary_type": "administrative", "chancellor_secondary_aptitude": 2},
	"jeong_do_jeon": {"id": "jeong_do_jeon", "hero_id": "jeong_do_jeon", "display_name": "정도전", "name": "정도전", "role": "재상", "web_role": "support", "faction_id": "goryeo_joseon", "force_id": "goryeo_joseon", "side": "player", "nation": "player", "command_rank": "officer", "politics": 94, "war": 40, "intelligence": 95, "loyalty": 90, "assigned_city_id": "hanseong", "city_id": "hanseong", "location_city_id": "hanseong", "troops": 90, "max_troops": 90, "max_hp": 90, "attack": 12, "defense": 12, "move_range": 3, "attack_range": 1, "skill_range": 3, "unique_skill_id": "reform_order", "portrait_image": "assets/portraits/jeong_dojeon_portrait.png", "battlefield_portrait_image": "assets/portraits_battlefield/jeong_dojeon_battlefield.png", "chancellor_primary_type": "political", "chancellor_primary_aptitude": 4, "chancellor_secondary_type": "administrative", "chancellor_secondary_aptitude": 3},
	"cheok_jun_gyeong": {"id": "cheok_jun_gyeong", "hero_id": "cheok_jun_gyeong", "display_name": "척준경", "name": "척준경", "role": "돌격", "web_role": "melee", "faction_id": "goryeo_joseon", "force_id": "goryeo_joseon", "side": "player", "nation": "player", "command_rank": "general", "politics": 48, "war": 98, "intelligence": 48, "loyalty": 86, "assigned_city_id": "hanseong", "city_id": "hanseong", "location_city_id": "hanseong", "troops": 110, "max_troops": 110, "max_hp": 110, "attack": 38, "defense": 22, "move_range": 3, "attack_range": 1, "skill_range": 1, "unique_skill_id": "berserker_slash", "portrait_image": "", "battlefield_portrait_image": "", "chancellor_primary_type": "militaryAdmin", "chancellor_primary_aptitude": 5, "chancellor_secondary_type": "administrative", "chancellor_secondary_aptitude": 1},
	"gwanggaeto": {"id": "gwanggaeto", "hero_id": "gwanggaeto", "display_name": "광개토대왕", "name": "광개토대왕", "role": "북방 원정", "web_role": "melee", "faction_id": "goguryeo", "force_id": "goguryeo", "side": "goguryeo", "nation": "goguryeo", "command_rank": "general", "politics": 84, "war": 92, "intelligence": 72, "loyalty": 92, "assigned_city_id": "pyeongyang", "city_id": "pyeongyang", "location_city_id": "pyeongyang", "troops": 120, "max_troops": 120, "max_hp": 120, "attack": 34, "defense": 18, "move_range": 3, "attack_range": 1, "skill_range": 3, "unique_skill_id": "yeongnak_grand_legacy", "portrait_image": "assets/portraits/gwanggaeto_portrait.png", "battlefield_portrait_image": "assets/portraits_battlefield/gwanggaeto_battlefield.png", "chancellor_primary_type": "militaryAdmin", "chancellor_primary_aptitude": 5, "chancellor_secondary_type": "political", "chancellor_secondary_aptitude": 2},
	"eulji_mundeok": {"id": "eulji_mundeok", "hero_id": "eulji_mundeok", "display_name": "을지문덕", "name": "을지문덕", "role": "책략", "web_role": "ranged", "faction_id": "goguryeo", "force_id": "goguryeo", "side": "goguryeo", "nation": "goguryeo", "command_rank": "general", "politics": 82, "war": 78, "intelligence": 92, "loyalty": 90, "assigned_city_id": "pyeongyang", "city_id": "pyeongyang", "location_city_id": "pyeongyang", "troops": 105, "max_troops": 105, "max_hp": 105, "attack": 26, "defense": 16, "move_range": 3, "attack_range": 2, "skill_range": 3, "unique_skill_id": "salsu_ambush", "portrait_image": "", "battlefield_portrait_image": "", "chancellor_primary_type": "militaryAdmin", "chancellor_primary_aptitude": 5, "chancellor_secondary_type": "administrative", "chancellor_secondary_aptitude": 2},
	"dorim": {"id": "dorim", "hero_id": "dorim", "display_name": "도림", "name": "도림", "role": "지원", "web_role": "support", "faction_id": "goguryeo", "force_id": "goguryeo", "side": "goguryeo", "nation": "goguryeo", "command_rank": "officer", "politics": 72, "war": 32, "intelligence": 88, "loyalty": 70, "assigned_city_id": "pyeongyang", "city_id": "pyeongyang", "location_city_id": "pyeongyang", "troops": 85, "max_troops": 85, "max_hp": 85, "attack": 10, "defense": 10, "move_range": 3, "attack_range": 1, "skill_range": 4, "unique_skill_id": "black_white_scheming", "portrait_image": "assets/portraits/dorim_portrait.png", "battlefield_portrait_image": "assets/portraits_battlefield/dorim_battlefield.png", "chancellor_primary_type": "political", "chancellor_primary_aptitude": 3, "chancellor_secondary_type": "administrative", "chancellor_secondary_aptitude": 3},
	"kim_chun_chu": {"id": "kim_chun_chu", "hero_id": "kim_chun_chu", "display_name": "김춘추", "name": "김춘추", "role": "외교", "web_role": "support", "faction_id": "silla", "force_id": "silla", "side": "silla", "nation": "silla", "command_rank": "general", "politics": 91, "war": 42, "intelligence": 94, "loyalty": 84, "assigned_city_id": "gyeongju", "city_id": "gyeongju", "location_city_id": "gyeongju", "troops": 85, "max_troops": 85, "max_hp": 85, "attack": 12, "defense": 14, "move_range": 3, "attack_range": 1, "skill_range": 4, "unique_skill_id": "tang_alliance", "portrait_image": "", "battlefield_portrait_image": "", "chancellor_primary_type": "political", "chancellor_primary_aptitude": 5, "chancellor_secondary_type": "economic", "chancellor_secondary_aptitude": 3},
	"kim_yu_sin": {"id": "kim_yu_sin", "hero_id": "kim_yu_sin", "display_name": "김유신", "name": "김유신", "role": "정예 지휘", "web_role": "cavalry", "faction_id": "silla", "force_id": "silla", "side": "silla", "nation": "silla", "command_rank": "general", "politics": 72, "war": 90, "intelligence": 76, "loyalty": 91, "assigned_city_id": "gyeongju", "city_id": "gyeongju", "location_city_id": "gyeongju", "troops": 115, "max_troops": 115, "max_hp": 115, "attack": 33, "defense": 18, "move_range": 4, "attack_range": 1, "skill_range": 2, "unique_skill_id": "unification_charge", "portrait_image": "", "battlefield_portrait_image": "", "chancellor_primary_type": "militaryAdmin", "chancellor_primary_aptitude": 4, "chancellor_secondary_type": "administrative", "chancellor_secondary_aptitude": 2},
	"jang_bo_go": {"id": "jang_bo_go", "hero_id": "jang_bo_go", "display_name": "장보고", "name": "장보고", "role": "해상 교역", "web_role": "ranged", "faction_id": "silla", "force_id": "silla", "side": "silla", "nation": "silla", "command_rank": "general", "politics": 78, "war": 74, "intelligence": 82, "loyalty": 84, "assigned_city_id": "gyeongju", "city_id": "gyeongju", "location_city_id": "gyeongju", "troops": 100, "max_troops": 100, "max_hp": 100, "attack": 28, "defense": 14, "move_range": 3, "attack_range": 3, "skill_range": 3, "unique_skill_id": "cheonghae_fleet", "portrait_image": "", "battlefield_portrait_image": "", "chancellor_primary_type": "economic", "chancellor_primary_aptitude": 4, "chancellor_secondary_type": "militaryAdmin", "chancellor_secondary_aptitude": 3},
	"uija_wang": {"id": "uija_wang", "hero_id": "uija_wang", "display_name": "의자왕", "name": "의자왕", "role": "왕도 운영", "web_role": "support", "faction_id": "baekje_faction", "force_id": "baekje_faction", "side": "baekje_faction", "nation": "baekje_faction", "command_rank": "general", "politics": 82, "war": 70, "intelligence": 82, "loyalty": 78, "assigned_city_id": "sabi", "city_id": "sabi", "location_city_id": "sabi", "troops": 95, "max_troops": 95, "max_hp": 95, "attack": 18, "defense": 16, "move_range": 3, "attack_range": 1, "skill_range": 4, "unique_skill_id": "great_baekje_advance", "portrait_image": "", "battlefield_portrait_image": "", "chancellor_primary_type": "political", "chancellor_primary_aptitude": 4, "chancellor_secondary_type": "militaryAdmin", "chancellor_secondary_aptitude": 3},
	"gyebaek": {"id": "gyebaek", "hero_id": "gyebaek", "display_name": "계백", "name": "계백", "role": "결사 방위", "web_role": "melee", "faction_id": "baekje_faction", "force_id": "baekje_faction", "side": "baekje_faction", "nation": "baekje_faction", "command_rank": "general", "politics": 62, "war": 91, "intelligence": 68, "loyalty": 89, "assigned_city_id": "sabi", "city_id": "sabi", "location_city_id": "sabi", "troops": 115, "max_troops": 115, "max_hp": 115, "attack": 35, "defense": 22, "move_range": 3, "attack_range": 1, "skill_range": 1, "unique_skill_id": "hwangsanbeol_last_stand", "portrait_image": "", "battlefield_portrait_image": "", "chancellor_primary_type": "militaryAdmin", "chancellor_primary_aptitude": 4, "chancellor_secondary_type": "political", "chancellor_secondary_aptitude": 2},
	"heukchi_sangji": {"id": "heukchi_sangji", "hero_id": "heukchi_sangji", "display_name": "흑치상지", "name": "흑치상지", "role": "복국 지휘", "web_role": "ranged", "faction_id": "baekje_faction", "force_id": "baekje_faction", "side": "baekje_faction", "nation": "baekje_faction", "command_rank": "general", "politics": 70, "war": 82, "intelligence": 86, "loyalty": 88, "assigned_city_id": "sabi", "city_id": "sabi", "location_city_id": "sabi", "troops": 105, "max_troops": 105, "max_hp": 105, "attack": 28, "defense": 18, "move_range": 3, "attack_range": 2, "skill_range": 3, "unique_skill_id": "heukchi_restoration", "portrait_image": "", "battlefield_portrait_image": "", "chancellor_primary_type": "militaryAdmin", "chancellor_primary_aptitude": 4, "chancellor_secondary_type": "administrative", "chancellor_secondary_aptitude": 3},
	"xiang_yu": {"id": "xiang_yu", "hero_id": "xiang_yu", "display_name": "항우", "name": "항우", "role": "패왕", "web_role": "melee", "faction_id": "chu", "force_id": "chu", "side": "chu", "nation": "chu", "command_rank": "general", "politics": 58, "war": 99, "intelligence": 55, "loyalty": 75, "assigned_city_id": "luoyang", "city_id": "luoyang", "location_city_id": "luoyang", "troops": 130, "max_troops": 130, "max_hp": 130, "attack": 40, "defense": 24, "move_range": 3, "attack_range": 1, "skill_range": 1, "unique_skill_id": "overlord_rampage", "portrait_image": "", "battlefield_portrait_image": "", "chancellor_primary_type": "militaryAdmin", "chancellor_primary_aptitude": 5, "chancellor_secondary_type": "political", "chancellor_secondary_aptitude": 1},
	"fan_zeng": {"id": "fan_zeng", "hero_id": "fan_zeng", "display_name": "범증", "name": "범증", "role": "책사", "web_role": "support", "faction_id": "chu", "force_id": "chu", "side": "chu", "nation": "chu", "command_rank": "officer", "politics": 94, "war": 35, "intelligence": 97, "loyalty": 78, "assigned_city_id": "luoyang", "city_id": "luoyang", "location_city_id": "luoyang", "troops": 80, "max_troops": 80, "max_hp": 80, "attack": 10, "defense": 12, "move_range": 2, "attack_range": 1, "skill_range": 4, "unique_skill_id": "hongmen_scheme", "portrait_image": "", "battlefield_portrait_image": "", "chancellor_primary_type": "political", "chancellor_primary_aptitude": 5, "chancellor_secondary_type": "militaryAdmin", "chancellor_secondary_aptitude": 2},
	"cao_cao": {"id": "cao_cao", "hero_id": "cao_cao", "display_name": "조조", "name": "조조", "role": "위왕", "web_role": "ranged", "faction_id": "wei", "force_id": "wei", "side": "wei", "nation": "wei", "command_rank": "general", "politics": 96, "war": 80, "intelligence": 95, "loyalty": 81, "assigned_city_id": "yecheng", "city_id": "yecheng", "location_city_id": "yecheng", "troops": 115, "max_troops": 115, "max_hp": 115, "attack": 28, "defense": 18, "move_range": 3, "attack_range": 2, "skill_range": 3, "unique_skill_id": "cao_cao_decree", "portrait_image": "", "battlefield_portrait_image": "", "chancellor_primary_type": "political", "chancellor_primary_aptitude": 5, "chancellor_secondary_type": "economic", "chancellor_secondary_aptitude": 3},
	"xun_yu": {"id": "xun_yu", "hero_id": "xun_yu", "display_name": "순욱", "name": "순욱", "role": "행정", "web_role": "support", "faction_id": "wei", "force_id": "wei", "side": "wei", "nation": "wei", "command_rank": "officer", "politics": 96, "war": 30, "intelligence": 98, "loyalty": 86, "assigned_city_id": "yecheng", "city_id": "yecheng", "location_city_id": "yecheng", "troops": 75, "max_troops": 75, "max_hp": 75, "attack": 10, "defense": 10, "move_range": 2, "attack_range": 1, "skill_range": 5, "unique_skill_id": "xun_yu_strategy", "portrait_image": "", "battlefield_portrait_image": "", "chancellor_primary_type": "administrative", "chancellor_primary_aptitude": 5, "chancellor_secondary_type": "political", "chancellor_secondary_aptitude": 4},
	"lu_bu": {"id": "lu_bu", "hero_id": "lu_bu", "display_name": "여포", "name": "여포", "role": "예비", "web_role": "cavalry", "faction_id": "wei", "force_id": "wei", "side": "wei", "nation": "wei", "command_rank": "general", "active": false, "is_active_roster": false, "is_reserve": true, "reserve_reason": "v0.5-8i active roster reserve", "politics": 45, "war": 97, "intelligence": 45, "loyalty": 70, "assigned_city_id": "", "city_id": "", "location_city_id": "", "troops": 120, "max_troops": 120, "max_hp": 120, "attack": 38, "defense": 20, "move_range": 5, "attack_range": 1, "skill_range": 2, "unique_skill_id": "red_hare_charge", "portrait_image": "", "battlefield_portrait_image": "", "chancellor_primary_type": "militaryAdmin", "chancellor_primary_aptitude": 5, "chancellor_secondary_type": "political", "chancellor_secondary_aptitude": 1},
	"guo_jia": {"id": "guo_jia", "hero_id": "guo_jia", "display_name": "곽가", "name": "곽가", "role": "책략", "web_role": "support", "faction_id": "wei", "force_id": "wei", "side": "wei", "nation": "wei", "command_rank": "officer", "politics": 82, "war": 34, "intelligence": 97, "loyalty": 82, "assigned_city_id": "yecheng", "city_id": "yecheng", "location_city_id": "yecheng", "troops": 80, "max_troops": 80, "max_hp": 80, "attack": 10, "defense": 12, "move_range": 2, "attack_range": 1, "skill_range": 4, "unique_skill_id": "heavenly_stratagem", "portrait_image": "", "battlefield_portrait_image": "", "chancellor_primary_type": "political", "chancellor_primary_aptitude": 4, "chancellor_secondary_type": "militaryAdmin", "chancellor_secondary_aptitude": 3},
	"zhuge_liang": {"id": "zhuge_liang", "hero_id": "zhuge_liang", "display_name": "제갈량", "name": "제갈량", "role": "책사", "web_role": "support", "faction_id": "shu", "force_id": "shu", "side": "shu", "nation": "shu", "command_rank": "general", "politics": 98, "war": 38, "intelligence": 99, "loyalty": 95, "assigned_city_id": "chengdu", "city_id": "chengdu", "location_city_id": "chengdu", "troops": 90, "max_troops": 90, "max_hp": 90, "attack": 12, "defense": 14, "move_range": 2, "attack_range": 1, "skill_range": 5, "unique_skill_id": "eight_trigram_formation", "portrait_image": "", "battlefield_portrait_image": "", "chancellor_primary_type": "administrative", "chancellor_primary_aptitude": 5, "chancellor_secondary_type": "economic", "chancellor_secondary_aptitude": 4},
	"guan_yu": {"id": "guan_yu", "hero_id": "guan_yu", "display_name": "관우", "name": "관우", "role": "장군", "web_role": "melee", "faction_id": "shu", "force_id": "shu", "side": "shu", "nation": "shu", "command_rank": "general", "politics": 70, "war": 94, "intelligence": 62, "loyalty": 95, "assigned_city_id": "chengdu", "city_id": "chengdu", "location_city_id": "chengdu", "troops": 115, "max_troops": 115, "max_hp": 115, "attack": 36, "defense": 20, "move_range": 3, "attack_range": 1, "skill_range": 1, "unique_skill_id": "crescent_blade_slash", "portrait_image": "assets/portraits/guan_yu_portrait.png", "battlefield_portrait_image": "assets/portraits_battlefield/guan_yu_battlefield.png", "chancellor_primary_type": "militaryAdmin", "chancellor_primary_aptitude": 4, "chancellor_secondary_type": "political", "chancellor_secondary_aptitude": 2},
	"zhang_fei": {"id": "zhang_fei", "hero_id": "zhang_fei", "display_name": "장비", "name": "장비", "role": "돌격", "web_role": "melee", "faction_id": "shu", "force_id": "shu", "side": "shu", "nation": "shu", "command_rank": "general", "politics": 52, "war": 92, "intelligence": 48, "loyalty": 92, "assigned_city_id": "chengdu", "city_id": "chengdu", "location_city_id": "chengdu", "troops": 110, "max_troops": 110, "max_hp": 110, "attack": 35, "defense": 18, "move_range": 3, "attack_range": 1, "skill_range": 1, "unique_skill_id": "changban_shatter", "portrait_image": "assets/portraits/zhang_fei_portrait.png", "battlefield_portrait_image": "assets/portraits_battlefield/zhang_fei_battlefield.png", "chancellor_primary_type": "militaryAdmin", "chancellor_primary_aptitude": 3, "chancellor_secondary_type": "political", "chancellor_secondary_aptitude": 1},
	"sun_ce": {"id": "sun_ce", "hero_id": "sun_ce", "display_name": "손책", "name": "손책", "role": "강동 돌파", "web_role": "melee", "faction_id": "wu", "force_id": "wu", "side": "wu", "nation": "wu", "command_rank": "general", "politics": 78, "war": 92, "intelligence": 72, "loyalty": 82, "assigned_city_id": "jianye", "city_id": "jianye", "location_city_id": "jianye", "troops": 115, "max_troops": 115, "max_hp": 115, "attack": 34, "defense": 18, "move_range": 3, "attack_range": 1, "skill_range": 2, "unique_skill_id": "little_conqueror_strike", "portrait_image": "", "battlefield_portrait_image": "", "chancellor_primary_type": "militaryAdmin", "chancellor_primary_aptitude": 4, "chancellor_secondary_type": "political", "chancellor_secondary_aptitude": 3},
	"zhou_yu": {"id": "zhou_yu", "hero_id": "zhou_yu", "display_name": "주유", "name": "주유", "role": "수군 책략", "web_role": "ranged", "faction_id": "wu", "force_id": "wu", "side": "wu", "nation": "wu", "command_rank": "general", "politics": 88, "war": 75, "intelligence": 90, "loyalty": 88, "assigned_city_id": "jianye", "city_id": "jianye", "location_city_id": "jianye", "troops": 100, "max_troops": 100, "max_hp": 100, "attack": 26, "defense": 16, "move_range": 3, "attack_range": 3, "skill_range": 3, "unique_skill_id": "red_cliff_fire", "portrait_image": "", "battlefield_portrait_image": "", "chancellor_primary_type": "militaryAdmin", "chancellor_primary_aptitude": 4, "chancellor_secondary_type": "administrative", "chancellor_secondary_aptitude": 3},
	"lu_meng": {"id": "lu_meng", "hero_id": "lu_meng", "display_name": "여몽", "name": "여몽", "role": "장군", "web_role": "ranged", "faction_id": "wu", "force_id": "wu", "side": "wu", "nation": "wu", "command_rank": "general", "politics": 78, "war": 80, "intelligence": 84, "loyalty": 84, "assigned_city_id": "jianye", "city_id": "jianye", "location_city_id": "jianye", "troops": 105, "max_troops": 105, "max_hp": 105, "attack": 28, "defense": 16, "move_range": 3, "attack_range": 3, "skill_range": 3, "unique_skill_id": "lu_meng_ambush", "portrait_image": "", "battlefield_portrait_image": "", "chancellor_primary_type": "militaryAdmin", "chancellor_primary_aptitude": 4, "chancellor_secondary_type": "administrative", "chancellor_secondary_aptitude": 2},
	"nobunaga": {"id": "nobunaga", "hero_id": "nobunaga", "display_name": "노부나가", "name": "노부나가", "role": "개혁 군주", "web_role": "ranged", "faction_id": "oda", "force_id": "oda", "side": "oda", "nation": "oda", "command_rank": "general", "politics": 92, "war": 85, "intelligence": 75, "loyalty": 80, "assigned_city_id": "kyoto", "city_id": "kyoto", "location_city_id": "kyoto", "troops": 120, "max_troops": 120, "max_hp": 120, "attack": 30, "defense": 16, "move_range": 3, "attack_range": 2, "skill_range": 2, "unique_skill_id": "matchlock_volley", "portrait_image": "assets/portraits/nobunaga_portrait.png", "battlefield_portrait_image": "assets/portraits_battlefield/nobunaga_battlefield.png", "chancellor_primary_type": "economic", "chancellor_primary_aptitude": 4, "chancellor_secondary_type": "militaryAdmin", "chancellor_secondary_aptitude": 3},
	"takeda_shingen": {"id": "takeda_shingen", "hero_id": "takeda_shingen", "display_name": "다케다 신겐", "name": "다케다 신겐", "role": "기병", "web_role": "cavalry", "faction_id": "oda", "force_id": "oda", "side": "oda", "nation": "oda", "command_rank": "general", "politics": 86, "war": 90, "intelligence": 80, "loyalty": 82, "assigned_city_id": "kyoto", "city_id": "kyoto", "location_city_id": "kyoto", "troops": 120, "max_troops": 120, "max_hp": 120, "attack": 35, "defense": 20, "move_range": 5, "attack_range": 1, "skill_range": 2, "unique_skill_id": "furinkazan", "portrait_image": "", "battlefield_portrait_image": "", "chancellor_primary_type": "militaryAdmin", "chancellor_primary_aptitude": 5, "chancellor_secondary_type": "economic", "chancellor_secondary_aptitude": 2},
	"toyotomi_hideyoshi": {"id": "toyotomi_hideyoshi", "hero_id": "toyotomi_hideyoshi", "display_name": "도요토미 히데요시", "name": "도요토미 히데요시", "role": "상업 통치", "web_role": "support", "faction_id": "toyotomi", "force_id": "toyotomi", "side": "toyotomi", "nation": "toyotomi", "command_rank": "general", "politics": 95, "war": 68, "intelligence": 92, "loyalty": 82, "assigned_city_id": "osaka", "city_id": "osaka", "location_city_id": "osaka", "troops": 100, "max_troops": 100, "max_hp": 100, "attack": 18, "defense": 16, "move_range": 3, "attack_range": 1, "skill_range": 4, "unique_skill_id": "taikosama_order", "portrait_image": "", "battlefield_portrait_image": "", "chancellor_primary_type": "political", "chancellor_primary_aptitude": 5, "chancellor_secondary_type": "economic", "chancellor_secondary_aptitude": 4},
	"kenshin": {"id": "kenshin", "hero_id": "kenshin", "display_name": "겐신", "name": "겐신", "role": "장군", "web_role": "melee", "faction_id": "toyotomi", "force_id": "toyotomi", "side": "toyotomi", "nation": "toyotomi", "command_rank": "general", "politics": 80, "war": 95, "intelligence": 70, "loyalty": 82, "assigned_city_id": "osaka", "city_id": "osaka", "location_city_id": "osaka", "troops": 115, "max_troops": 115, "max_hp": 115, "attack": 34, "defense": 14, "move_range": 4, "attack_range": 1, "skill_range": 2, "unique_skill_id": "cavalry_charge", "portrait_image": "assets/portraits/kenshin_portrait.png", "battlefield_portrait_image": "assets/portraits_battlefield/kenshin_battlefield.png", "chancellor_primary_type": "militaryAdmin", "chancellor_primary_aptitude": 4, "chancellor_secondary_type": "political", "chancellor_secondary_aptitude": 2},
	"shimazu_yoshihiro": {"id": "shimazu_yoshihiro", "hero_id": "shimazu_yoshihiro", "display_name": "시마즈 요시히로", "name": "시마즈 요시히로", "role": "해상 방위", "web_role": "melee", "faction_id": "kyushu_faction", "force_id": "kyushu_faction", "side": "kyushu_faction", "nation": "kyushu_faction", "command_rank": "general", "politics": 70, "war": 93, "intelligence": 70, "loyalty": 83, "assigned_city_id": "kyushu", "city_id": "kyushu", "location_city_id": "kyushu", "troops": 115, "max_troops": 115, "max_hp": 115, "attack": 36, "defense": 20, "move_range": 3, "attack_range": 1, "skill_range": 1, "unique_skill_id": "demon_shimazu", "portrait_image": "", "battlefield_portrait_image": "", "chancellor_primary_type": "militaryAdmin", "chancellor_primary_aptitude": 4, "chancellor_secondary_type": "political", "chancellor_secondary_aptitude": 2},
	"konishi_yukinaga": {"id": "konishi_yukinaga", "hero_id": "konishi_yukinaga", "display_name": "고니시 유키나가", "name": "고니시 유키나가", "role": "교역", "web_role": "support", "faction_id": "kyushu_faction", "force_id": "kyushu_faction", "side": "kyushu_faction", "nation": "kyushu_faction", "command_rank": "lieutenant", "politics": 78, "war": 58, "intelligence": 86, "loyalty": 76, "assigned_city_id": "kyushu", "city_id": "kyushu", "location_city_id": "kyushu", "troops": 90, "max_troops": 90, "max_hp": 90, "attack": 16, "defense": 14, "move_range": 3, "attack_range": 1, "skill_range": 4, "unique_skill_id": "sea_supply_route", "portrait_image": "", "battlefield_portrait_image": "", "chancellor_primary_type": "diplomatic", "chancellor_primary_aptitude": 4, "chancellor_secondary_type": "administrative", "chancellor_secondary_aptitude": 3},
	"tokugawa_ieyasu": {"id": "tokugawa_ieyasu", "hero_id": "tokugawa_ieyasu", "display_name": "도쿠가와 이에야스", "name": "도쿠가와 이에야스", "role": "동방 행정", "web_role": "support", "faction_id": "tokugawa", "force_id": "tokugawa", "side": "tokugawa", "nation": "tokugawa", "command_rank": "general", "politics": 97, "war": 72, "intelligence": 90, "loyalty": 88, "assigned_city_id": "edo", "city_id": "edo", "location_city_id": "edo", "troops": 105, "max_troops": 105, "max_hp": 105, "attack": 20, "defense": 20, "move_range": 2, "attack_range": 1, "skill_range": 4, "unique_skill_id": "edo_endurance", "portrait_image": "", "battlefield_portrait_image": "", "chancellor_primary_type": "political", "chancellor_primary_aptitude": 5, "chancellor_secondary_type": "administrative", "chancellor_secondary_aptitude": 4},
	"honda_masanobu": {"id": "honda_masanobu", "hero_id": "honda_masanobu", "display_name": "혼다 마사노부", "name": "혼다 마사노부", "role": "행정", "web_role": "support", "faction_id": "tokugawa", "force_id": "tokugawa", "side": "tokugawa", "nation": "tokugawa", "command_rank": "officer", "politics": 90, "war": 28, "intelligence": 93, "loyalty": 84, "assigned_city_id": "edo", "city_id": "edo", "location_city_id": "edo", "troops": 75, "max_troops": 75, "max_hp": 75, "attack": 10, "defense": 12, "move_range": 2, "attack_range": 1, "skill_range": 5, "unique_skill_id": "shadow_counsel", "portrait_image": "", "battlefield_portrait_image": "", "chancellor_primary_type": "administrative", "chancellor_primary_aptitude": 5, "chancellor_secondary_type": "political", "chancellor_secondary_aptitude": 3},
	"honda_tadakatsu": {"id": "honda_tadakatsu", "hero_id": "honda_tadakatsu", "display_name": "혼다 타다카츠", "name": "혼다 타다카츠", "role": "장군", "web_role": "melee", "faction_id": "tokugawa", "force_id": "tokugawa", "side": "tokugawa", "nation": "tokugawa", "command_rank": "general", "politics": 72, "war": 93, "intelligence": 65, "loyalty": 88, "assigned_city_id": "edo", "city_id": "edo", "location_city_id": "edo", "troops": 115, "max_troops": 115, "max_hp": 115, "attack": 36, "defense": 24, "move_range": 3, "attack_range": 1, "skill_range": 1, "unique_skill_id": "tonbo_giri_thrust", "portrait_image": "", "battlefield_portrait_image": "", "chancellor_primary_type": "militaryAdmin", "chancellor_primary_aptitude": 4, "chancellor_secondary_type": "administrative", "chancellor_secondary_aptitude": 2},
	"genghis_khan": {"id": "genghis_khan", "hero_id": "genghis_khan", "display_name": "징기스칸", "name": "징기스칸", "role": "초원 군주", "web_role": "cavalry", "faction_id": "mongol_faction", "force_id": "mongol_faction", "side": "mongol_faction", "nation": "mongol_faction", "command_rank": "general", "politics": 86, "war": 99, "intelligence": 88, "loyalty": 86, "assigned_city_id": "karakorum", "city_id": "karakorum", "location_city_id": "karakorum", "troops": 130, "max_troops": 130, "max_hp": 130, "attack": 40, "defense": 22, "move_range": 5, "attack_range": 1, "skill_range": 3, "unique_skill_id": "steppe_conqueror", "portrait_image": "", "battlefield_portrait_image": "", "chancellor_primary_type": "militaryAdmin", "chancellor_primary_aptitude": 5, "chancellor_secondary_type": "political", "chancellor_secondary_aptitude": 3},
	"subutai": {"id": "subutai", "hero_id": "subutai", "display_name": "수부타이", "name": "수부타이", "role": "기병 지휘", "web_role": "cavalry", "faction_id": "mongol_faction", "force_id": "mongol_faction", "side": "mongol_faction", "nation": "mongol_faction", "command_rank": "general", "politics": 72, "war": 91, "intelligence": 96, "loyalty": 86, "assigned_city_id": "karakorum", "city_id": "karakorum", "location_city_id": "karakorum", "troops": 120, "max_troops": 120, "max_hp": 120, "attack": 35, "defense": 18, "move_range": 5, "attack_range": 1, "skill_range": 2, "unique_skill_id": "thunder_maneuver", "portrait_image": "", "battlefield_portrait_image": "", "chancellor_primary_type": "militaryAdmin", "chancellor_primary_aptitude": 5, "chancellor_secondary_type": "administrative", "chancellor_secondary_aptitude": 3},
	"jebe": {"id": "jebe", "hero_id": "jebe", "display_name": "제베", "name": "제베", "role": "기병", "web_role": "ranged", "faction_id": "mongol_faction", "force_id": "mongol_faction", "side": "mongol_faction", "nation": "mongol_faction", "command_rank": "general", "politics": 58, "war": 88, "intelligence": 82, "loyalty": 82, "assigned_city_id": "karakorum", "city_id": "karakorum", "location_city_id": "karakorum", "troops": 110, "max_troops": 110, "max_hp": 110, "attack": 30, "defense": 16, "move_range": 4, "attack_range": 3, "skill_range": 3, "unique_skill_id": "arrow_pursuit", "portrait_image": "", "battlefield_portrait_image": "", "chancellor_primary_type": "militaryAdmin", "chancellor_primary_aptitude": 4, "chancellor_secondary_type": "diplomatic", "chancellor_secondary_aptitude": 2},
}

const CITY_HUD_DATA := {
	"hanseong": {"id": "hanseong", "name": "한성", "owner": "player", "nation": "player", "region": "한반도", "region_key": "region.korean_peninsula", "type": "commercial_capital", "population": 50000, "population_rating": 4, "commerce_rating": 5, "gold": 650, "food": 468, "troops": 300, "public_order": 74, "commerce": 70, "agriculture": 62, "defense": 3, "governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": ["yi_sun_sin", "jeong_do_jeon", "cheok_jun_gyeong"], "hero_ids": ["yi_sun_sin", "jeong_do_jeon", "cheok_jun_gyeong"], "loyalty": 78, "resources": "쌀 ★★★ / 보리 ★★★ / 수산물 ★ / 목재 ★ / 철 ★ / 말 - / 비단 ★★★ / 소금 ★★", "military": "도시 주둔군 300 / 치안 기준 500 / 방어력 3", "trade": "내부 교역로: 평양-경주-사비 연결 후보", "rating": "인구 ★★★★ · 상업력 ★★★★★ · 금전 650", "resource_seed": {"rice": 3, "barley": 3, "seafood": 1, "wood": 1, "iron": 1, "horses": 0, "silk": 3, "salt": 2, "gold": 650, "specialty": 1}, "domestic_seed": {"publicSupport": 72, "publicOrder": 74, "agriculture": 62, "commerce": 70, "stability": 68}, "yield_seed": {"riceHarvest": 310, "barleyHarvest": 130, "seafoodPerTurn": 28, "commerceIncome": 145, "specialtyIncome": 320}},
	"pyeongyang": {"id": "pyeongyang", "name": "평양", "owner": "goguryeo", "nation": "goguryeo", "region": "한반도", "region_key": "region.korean_peninsula", "type": "production_city", "population": 42000, "population_rating": 3, "commerce_rating": 3, "gold": 420, "food": 512, "troops": 280, "public_order": 66, "commerce": 42, "agriculture": 68, "defense": 3, "governor_id": "gwanggaeto", "governor_policy_id": "military", "stationed_hero_ids": ["gwanggaeto", "eulji_mundeok", "dorim"], "hero_ids": ["gwanggaeto", "eulji_mundeok", "dorim"], "loyalty": 72, "resources": "쌀 ★★★ / 보리 ★★★ / 수산물 ★ / 목재 ★★★ / 철 ★★ / 말 ★★★ / 비단 ★ / 소금 ★", "military": "도시 주둔군 280 / 치안 기준 500 / 방어력 3", "trade": "내부 교역로: 한성-카라코룸 연결 후보", "rating": "인구 ★★★ · 상업력 ★★★ · 금전 420", "resource_seed": {"rice": 3, "barley": 3, "seafood": 1, "wood": 3, "iron": 2, "horses": 3, "silk": 1, "salt": 1, "gold": 420, "specialty": 1}, "domestic_seed": {"publicSupport": 62, "publicOrder": 66, "agriculture": 68, "commerce": 42, "stability": 58}, "yield_seed": {"riceHarvest": 340, "barleyHarvest": 160, "seafoodPerTurn": 12, "commerceIncome": 90, "specialtyIncome": 260}},
	"karakorum": {"id": "karakorum", "name": "카라코룸", "owner": "mongol_faction", "nation": "mongol_faction", "region": "북방초원", "region_key": "region.northern_steppe", "type": "military_fortress", "population": 36000, "population_rating": 3, "commerce_rating": 2, "gold": 620, "food": 380, "troops": 460, "public_order": 74, "commerce": 44, "agriculture": 42, "defense": 4, "governor_id": "genghis_khan", "governor_policy_id": "military", "stationed_hero_ids": ["genghis_khan", "subutai", "jebe"], "hero_ids": ["genghis_khan", "subutai", "jebe"], "loyalty": 78, "resources": "쌀 ★ / 보리 ★★★★ / 수산물 - / 목재 ★★ / 철 ★★★★ / 말 ★★★★★ / 비단 ★★ / 소금 ★", "military": "도시 주둔군 460 / 치안 기준 900 / 방어력 4", "trade": "내부 교역로: 평양-업성 북방 연결", "rating": "인구 ★★★ · 상업력 ★★ · 금전 620", "resource_seed": {"rice": 1, "barley": 4, "seafood": 0, "wood": 2, "iron": 4, "horses": 5, "silk": 2, "salt": 1, "gold": 620, "specialty": 2}, "domestic_seed": {"publicSupport": 68, "publicOrder": 74, "agriculture": 42, "commerce": 44, "stability": 70}, "yield_seed": {"riceHarvest": 160, "barleyHarvest": 220, "seafoodPerTurn": 0, "commerceIncome": 105, "specialtyIncome": 360}},
	"gyeongju": {"id": "gyeongju", "name": "경주", "owner": "silla", "nation": "silla", "region": "한반도", "region_key": "region.korean_peninsula", "type": "commercial_capital", "population": 48000, "population_rating": 4, "commerce_rating": 4, "gold": 580, "food": 442, "troops": 280, "public_order": 72, "commerce": 74, "agriculture": 60, "defense": 3, "governor_id": "kim_chun_chu", "governor_policy_id": "commerce", "stationed_hero_ids": ["kim_chun_chu", "kim_yu_sin", "jang_bo_go"], "hero_ids": ["kim_chun_chu", "kim_yu_sin", "jang_bo_go"], "loyalty": 76, "resources": "쌀 ★★★ / 보리 ★★ / 수산물 ★★★ / 목재 ★★ / 철 ★ / 말 ★ / 비단 ★★★★ / 소금 ★★", "military": "도시 주둔군 280 / 치안 기준 500 / 방어력 3", "trade": "대외 무역: 경주 ↔ 교토 / 경주 ↔ 오사카 후보", "rating": "인구 ★★★★ · 상업력 ★★★★ · 금전 580", "resource_seed": {"rice": 3, "barley": 2, "seafood": 3, "wood": 2, "iron": 1, "horses": 1, "silk": 4, "salt": 2, "gold": 580, "specialty": 2}, "domestic_seed": {"publicSupport": 70, "publicOrder": 72, "agriculture": 60, "commerce": 74, "stability": 66}, "yield_seed": {"riceHarvest": 300, "barleyHarvest": 110, "seafoodPerTurn": 32, "commerceIncome": 155, "specialtyIncome": 410}},
	"sabi": {"id": "sabi", "name": "사비", "owner": "baekje_faction", "nation": "baekje_faction", "region": "한반도", "region_key": "region.korean_peninsula", "type": "river_trade_city", "population": 44000, "population_rating": 4, "commerce_rating": 4, "gold": 620, "food": 414, "troops": 300, "public_order": 68, "commerce": 76, "agriculture": 62, "defense": 3, "governor_id": "uija_wang", "governor_policy_id": "agriculture", "stationed_hero_ids": ["uija_wang", "gyebaek", "heukchi_sangji"], "hero_ids": ["uija_wang", "gyebaek", "heukchi_sangji"], "loyalty": 73, "resources": "쌀 ★★★ / 보리 ★★ / 수산물 ★★★ / 목재 ★★ / 철 ★ / 말 ★ / 비단 ★★★ / 소금 ★★★", "military": "도시 주둔군 300 / 치안 기준 600 / 방어력 3", "trade": "대외 무역: 사비 ↔ 큐슈 / 사비 ↔ 건업 후보", "rating": "인구 ★★★★ · 상업력 ★★★★ · 금전 620", "resource_seed": {"rice": 3, "barley": 2, "seafood": 3, "wood": 2, "iron": 1, "horses": 1, "silk": 3, "salt": 3, "gold": 620, "specialty": 2}, "domestic_seed": {"publicSupport": 66, "publicOrder": 68, "agriculture": 62, "commerce": 76, "stability": 61}, "yield_seed": {"riceHarvest": 280, "barleyHarvest": 100, "seafoodPerTurn": 34, "commerceIncome": 150, "specialtyIncome": 430}},
	"luoyang": {"id": "luoyang", "name": "낙양", "owner": "chu", "nation": "chu", "region": "중국대륙", "region_key": "region.china_mainland", "type": "commercial_capital", "population": 80000, "population_rating": 5, "commerce_rating": 5, "gold": 880, "food": 410, "troops": 420, "public_order": 62, "commerce": 82, "agriculture": 59, "defense": 4, "governor_id": "xiang_yu", "governor_policy_id": "military", "stationed_hero_ids": ["xiang_yu", "fan_zeng"], "hero_ids": ["xiang_yu", "fan_zeng"], "loyalty": 74, "resources": "쌀 ★★★ / 보리 ★★★ / 수산물 - / 목재 ★ / 철 ★★★ / 말 ★★ / 비단 ★★★★★ / 소금 ★", "military": "도시 주둔군 420 / 치안 기준 1000 / 방어력 4", "trade": "내부 교역로: 업성-성도-건업 내륙 연결", "rating": "인구 ★★★★★ · 상업력 ★★★★★ · 금전 880", "resource_seed": {"rice": 3, "barley": 3, "seafood": 0, "wood": 1, "iron": 3, "horses": 2, "silk": 5, "salt": 1, "gold": 880, "specialty": 2}, "domestic_seed": {"publicSupport": 58, "publicOrder": 62, "agriculture": 59, "commerce": 82, "stability": 55}, "yield_seed": {"riceHarvest": 320, "barleyHarvest": 90, "seafoodPerTurn": 0, "commerceIncome": 180, "specialtyIncome": 520}},
	"yecheng": {"id": "yecheng", "name": "업성", "owner": "wei", "nation": "wei", "region": "중국대륙", "region_key": "region.china_mainland", "type": "military_fortress", "population": 55000, "population_rating": 4, "commerce_rating": 3, "gold": 720, "food": 550, "troops": 450, "public_order": 68, "commerce": 52, "agriculture": 64, "defense": 5, "governor_id": "cao_cao", "governor_policy_id": "military", "stationed_hero_ids": ["cao_cao", "xun_yu", "guo_jia"], "hero_ids": ["cao_cao", "xun_yu", "guo_jia"], "loyalty": 70, "resources": "쌀 ★★★ / 보리 ★★★★ / 수산물 - / 목재 ★★ / 철 ★★★★★ / 말 ★★★★ / 비단 ★★ / 소금 ★", "military": "도시 주둔군 450 / 치안 기준 1000 / 방어력 5", "trade": "내부 교역로: 낙양-건업-카라코룸 연결", "rating": "인구 ★★★★ · 상업력 ★★★ · 금전 720", "resource_seed": {"rice": 3, "barley": 4, "seafood": 0, "wood": 2, "iron": 5, "horses": 4, "silk": 2, "salt": 1, "gold": 720, "specialty": 1}, "domestic_seed": {"publicSupport": 60, "publicOrder": 68, "agriculture": 64, "commerce": 52, "stability": 58}, "yield_seed": {"riceHarvest": 350, "barleyHarvest": 200, "seafoodPerTurn": 0, "commerceIncome": 110, "specialtyIncome": 280}},
	"chengdu": {"id": "chengdu", "name": "성도", "owner": "shu", "nation": "shu", "region": "중국대륙", "region_key": "region.china_mainland", "type": "production_city", "population": 60000, "population_rating": 4, "commerce_rating": 3, "gold": 640, "food": 630, "troops": 350, "public_order": 70, "commerce": 48, "agriculture": 80, "defense": 4, "governor_id": "zhuge_liang", "governor_policy_id": "agriculture", "stationed_hero_ids": ["zhuge_liang", "guan_yu", "zhang_fei"], "hero_ids": ["zhuge_liang", "guan_yu", "zhang_fei"], "loyalty": 72, "resources": "쌀 ★★★★★ / 보리 ★★★ / 수산물 - / 목재 ★★★★ / 철 ★★ / 말 ★ / 비단 ★★★ / 소금 ★★", "military": "도시 주둔군 350 / 치안 기준 800 / 방어력 4", "trade": "내부 교역로: 낙양/건업 장거리 내륙 교역", "rating": "인구 ★★★★ · 상업력 ★★★ · 금전 640", "resource_seed": {"rice": 5, "barley": 3, "seafood": 0, "wood": 4, "iron": 2, "horses": 1, "silk": 3, "salt": 2, "gold": 640, "specialty": 2}, "domestic_seed": {"publicSupport": 68, "publicOrder": 70, "agriculture": 80, "commerce": 48, "stability": 64}, "yield_seed": {"riceHarvest": 480, "barleyHarvest": 150, "seafoodPerTurn": 0, "commerceIncome": 100, "specialtyIncome": 320}},
	"jianye": {"id": "jianye", "name": "건업", "owner": "wu", "nation": "wu", "region": "중국대륙", "region_key": "region.china_mainland", "type": "river_trade_city", "population": 52000, "population_rating": 4, "commerce_rating": 5, "gold": 820, "food": 402, "troops": 300, "public_order": 66, "commerce": 84, "agriculture": 55, "defense": 3, "governor_id": "sun_ce", "governor_policy_id": "commerce", "stationed_hero_ids": ["sun_ce", "zhou_yu", "lu_meng"], "hero_ids": ["sun_ce", "zhou_yu", "lu_meng"], "loyalty": 74, "resources": "쌀 ★★★ / 보리 ★★ / 수산물 ★★★ / 목재 ★★★★ / 철 ★ / 말 - / 비단 ★★★★ / 소금 ★★★", "military": "도시 주둔군 300 / 치안 기준 600 / 방어력 3", "trade": "대외 무역: 건업 ↔ 사비 후보", "rating": "인구 ★★★★ · 상업력 ★★★★★ · 금전 820", "resource_seed": {"rice": 3, "barley": 2, "seafood": 3, "wood": 4, "iron": 1, "horses": 0, "silk": 4, "salt": 3, "gold": 820, "specialty": 3}, "domestic_seed": {"publicSupport": 64, "publicOrder": 66, "agriculture": 55, "commerce": 84, "stability": 60}, "yield_seed": {"riceHarvest": 290, "barleyHarvest": 80, "seafoodPerTurn": 32, "commerceIncome": 200, "specialtyIncome": 580}},
	"kyoto": {"id": "kyoto", "name": "교토", "owner": "oda", "nation": "oda", "region": "일본열도", "region_key": "region.japanese_archipelago", "type": "coastal_trade_city", "population": 45000, "population_rating": 3, "commerce_rating": 3, "gold": 760, "food": 335, "troops": 240, "public_order": 72, "commerce": 78, "agriculture": 49, "defense": 3, "governor_id": "nobunaga", "governor_policy_id": "commerce", "stationed_hero_ids": ["nobunaga", "takeda_shingen"], "hero_ids": ["nobunaga", "takeda_shingen"], "loyalty": 76, "resources": "쌀 ★ / 보리 ★ / 수산물 ★★★★★ / 목재 ★★ / 철 ★ / 말 - / 비단 ★★ / 소금 ★★★★", "military": "도시 주둔군 240 / 치안 기준 500 / 방어력 3", "trade": "대외 무역: 교토 ↔ 경주 후보", "rating": "인구 ★★★ · 상업력 ★★★ · 금전 760", "resource_seed": {"rice": 1, "barley": 1, "seafood": 5, "wood": 2, "iron": 1, "horses": 0, "silk": 2, "salt": 4, "gold": 760, "specialty": 2}, "domestic_seed": {"publicSupport": 66, "publicOrder": 72, "agriculture": 49, "commerce": 78, "stability": 64}, "yield_seed": {"riceHarvest": 220, "barleyHarvest": 70, "seafoodPerTurn": 45, "commerceIncome": 170, "specialtyIncome": 600}},
	"osaka": {"id": "osaka", "name": "오사카", "owner": "toyotomi", "nation": "toyotomi", "region": "일본열도", "region_key": "region.japanese_archipelago", "type": "commercial_capital", "population": 50000, "population_rating": 4, "commerce_rating": 5, "gold": 900, "food": 310, "troops": 260, "public_order": 68, "commerce": 86, "agriculture": 50, "defense": 3, "governor_id": "toyotomi_hideyoshi", "governor_policy_id": "commerce", "stationed_hero_ids": ["toyotomi_hideyoshi", "kenshin"], "hero_ids": ["toyotomi_hideyoshi", "kenshin"], "loyalty": 72, "resources": "쌀 ★★ / 보리 ★ / 수산물 ★★★★ / 목재 ★★ / 철 ★ / 말 - / 비단 ★★★ / 소금 ★★★★", "military": "도시 주둔군 260 / 치안 기준 500 / 방어력 3", "trade": "대외 무역: 오사카 ↔ 경주 / 큐슈 후보", "rating": "인구 ★★★★ · 상업력 ★★★★★ · 금전 900", "resource_seed": {"rice": 2, "barley": 1, "seafood": 4, "wood": 2, "iron": 1, "horses": 0, "silk": 3, "salt": 4, "gold": 900, "specialty": 3}, "domestic_seed": {"publicSupport": 66, "publicOrder": 68, "agriculture": 50, "commerce": 86, "stability": 62}, "yield_seed": {"riceHarvest": 210, "barleyHarvest": 60, "seafoodPerTurn": 40, "commerceIncome": 220, "specialtyIncome": 640}},
	"kyushu": {"id": "kyushu", "name": "큐슈", "owner": "kyushu_faction", "nation": "kyushu_faction", "region": "일본열도", "region_key": "region.japanese_archipelago", "type": "coastal_trade_city", "population": 42000, "population_rating": 3, "commerce_rating": 4, "gold": 680, "food": 296, "troops": 270, "public_order": 70, "commerce": 78, "agriculture": 48, "defense": 3, "governor_id": "shimazu_yoshihiro", "governor_policy_id": "military", "stationed_hero_ids": ["shimazu_yoshihiro", "konishi_yukinaga"], "hero_ids": ["shimazu_yoshihiro", "konishi_yukinaga"], "loyalty": 72, "resources": "쌀 ★★ / 보리 ★ / 수산물 ★★★★★ / 목재 ★★ / 철 ★ / 말 - / 비단 ★★ / 소금 ★★★★", "military": "도시 주둔군 270 / 치안 기준 500 / 방어력 3", "trade": "대외 무역: 큐슈 ↔ 사비 / 오사카 후보", "rating": "인구 ★★★ · 상업력 ★★★★ · 금전 680", "resource_seed": {"rice": 2, "barley": 1, "seafood": 5, "wood": 2, "iron": 1, "horses": 0, "silk": 2, "salt": 4, "gold": 680, "specialty": 2}, "domestic_seed": {"publicSupport": 64, "publicOrder": 70, "agriculture": 48, "commerce": 78, "stability": 62}, "yield_seed": {"riceHarvest": 190, "barleyHarvest": 60, "seafoodPerTurn": 46, "commerceIncome": 165, "specialtyIncome": 500}},
	"edo": {"id": "edo", "name": "에도", "owner": "tokugawa", "nation": "tokugawa", "region": "일본열도", "region_key": "region.japanese_archipelago", "type": "military_fortress", "population": 46000, "population_rating": 3, "commerce_rating": 3, "gold": 700, "food": 368, "troops": 380, "public_order": 78, "commerce": 60, "agriculture": 54, "defense": 4, "governor_id": "tokugawa_ieyasu", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": ["tokugawa_ieyasu", "honda_masanobu", "honda_tadakatsu"], "hero_ids": ["tokugawa_ieyasu", "honda_masanobu", "honda_tadakatsu"], "loyalty": 78, "resources": "쌀 ★★ / 보리 ★★ / 수산물 ★★★ / 목재 ★★★ / 철 ★★★ / 말 ★★ / 비단 ★ / 소금 ★★★", "military": "도시 주둔군 380 / 치안 기준 800 / 방어력 4", "trade": "내부 교역로: 교토 동방 내륙 연결", "rating": "인구 ★★★ · 상업력 ★★★ · 금전 700", "resource_seed": {"rice": 2, "barley": 2, "seafood": 3, "wood": 3, "iron": 3, "horses": 2, "silk": 1, "salt": 3, "gold": 700, "specialty": 1}, "domestic_seed": {"publicSupport": 72, "publicOrder": 78, "agriculture": 54, "commerce": 60, "stability": 74}, "yield_seed": {"riceHarvest": 240, "barleyHarvest": 100, "seafoodPerTurn": 28, "commerceIncome": 130, "specialtyIncome": 300}},
}

@onready var tile_a1_top_left: Sprite2D = $WorldMapRoot/WorldMapTileLayer/Tile_A1_TopLeft
@onready var tile_a2_top_right: Sprite2D = $WorldMapRoot/WorldMapTileLayer/Tile_A2_TopRight
@onready var tile_b1_bottom_left: Sprite2D = $WorldMapRoot/WorldMapTileLayer/Tile_B1_BottomLeft
@onready var tile_b2_bottom_right: Sprite2D = $WorldMapRoot/WorldMapTileLayer/Tile_B2_BottomRight
@onready var city_layer: Node2D = $WorldMapRoot/CityLayer
@onready var world_map_camera: Camera2D = $WorldMapCamera
@onready var camera_debug_label: Label = $WorldMapUI/CameraDebugLabel
@onready var world_title_panel: Control = $WorldMapUI/WorldTitlePanel
@onready var right_hud_dragbar: Control = $WorldMapUI/RightHudDragbar
@onready var city_info_panel: Node = $WorldMapUI/CityInfoPanel
@onready var city_info_panel_control: Control = $WorldMapUI/CityInfoPanel
@onready var city_info_eyebrow_label: Label = $WorldMapUI/CityInfoPanel/MarginContainer/Content/EyebrowLabel
@onready var city_info_city_name_label: Label = $WorldMapUI/CityInfoPanel/MarginContainer/Content/CityNameLabel
@onready var left_world_status_panel: Control = $WorldMapUI/LeftWorldStatusPanel
@onready var left_world_status_eyebrow_label: Label = $WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/EyebrowLabel
@onready var turn_label: Label = $WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/TurnLabel
@onready var calendar_label: Label = $WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/CalendarLabel
@onready var nation_label: Label = $WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/NationLabel
@onready var power_label: Label = $WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/NationalGaugeCard/MarginContainer/GaugeList/PowerLabel
@onready var power_bar: ProgressBar = $WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/NationalGaugeCard/MarginContainer/GaugeList/PowerBar
@onready var tax_label: Label = $WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/NationalGaugeCard/MarginContainer/GaugeList/TaxLabel
@onready var tax_bar: ProgressBar = $WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/NationalGaugeCard/MarginContainer/GaugeList/TaxBar
@onready var tax_slider: HSlider = $WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/NationalGaugeCard/MarginContainer/GaugeList/TaxSlider
@onready var security_label: Label = $WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/NationalGaugeCard/MarginContainer/GaugeList/SecurityLabel
@onready var security_bar: ProgressBar = $WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/NationalGaugeCard/MarginContainer/GaugeList/SecurityBar
@onready var chancellor_label: Label = $WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/ChancellorLabel
@onready var chancellor_portrait_label: Label = $WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/ChancellorCard/MarginContainer/Content/HeaderRow/PortraitBox/PortraitLabel
@onready var chancellor_name_label: Label = $WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/ChancellorCard/MarginContainer/Content/HeaderRow/Copy/ChancellorNameLabel
@onready var chancellor_stats_label: Label = $WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/ChancellorCard/MarginContainer/Content/HeaderRow/Copy/ChancellorStatsLabel
@onready var chancellor_assignment_option: OptionButton = $WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/ChancellorCard/MarginContainer/Content/ChancellorAssignmentOption
@onready var chancellor_policy_option: OptionButton = $WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/ChancellorCard/MarginContainer/Content/ChancellorPolicyOption
@onready var chancellor_policy_description_label: Label = $WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/ChancellorCard/MarginContainer/Content/ChancellorPolicyDescriptionLabel
@onready var resource_label: Label = $WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/ResourceLabel
@onready var supply_label: Label = $WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/SupplyLabel
@onready var military_logistics_label: Label = $WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/MilitaryLogisticsLabel
@onready var external_trade_label: Label = $WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/ExternalTradeLabel
@onready var world_status_hint_label: Label = $WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/WorldStatusHintLabel
@onready var wild_army_edit_button_placeholder: Button = $WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/WildArmyEditButtonPlaceholder
@onready var save_button_placeholder: Button = $WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/SaveButtonRow/SaveButtonPlaceholder
@onready var load_button_placeholder: Button = $WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/SaveButtonRow/LoadButtonPlaceholder
@onready var reset_button_placeholder: Button = $WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/SaveButtonRow/ResetButtonPlaceholder
@onready var diplomacy_spy_panel: Control = $WorldMapUI/DiplomacySpyPanel
@onready var diplomacy_spy_eyebrow_label: Label = $WorldMapUI/DiplomacySpyPanel/MarginContainer/Content/EyebrowLabel
@onready var diplomacy_spy_heading_label: Label = $WorldMapUI/DiplomacySpyPanel/MarginContainer/Content/HeadingLabel
@onready var diplomacy_hint_label: Label = $WorldMapUI/DiplomacySpyPanel/MarginContainer/Content/DiplomacyHintLabel
@onready var diplomacy_mode_button_placeholder: Button = $WorldMapUI/DiplomacySpyPanel/MarginContainer/Content/TabRow/DiplomacyModeButtonPlaceholder
@onready var spy_mode_button_placeholder: Button = $WorldMapUI/DiplomacySpyPanel/MarginContainer/Content/TabRow/SpyModeButtonPlaceholder
@onready var city_detail_panel: Control = $WorldMapUI/CityDetailPanel
@onready var city_detail_eyebrow_label: Label = $WorldMapUI/CityDetailPanel/MarginContainer/Content/EyebrowLabel
@onready var city_detail_content_container: VBoxContainer = $WorldMapUI/CityDetailPanel/MarginContainer/Content
@onready var city_detail_header_row: HBoxContainer = $WorldMapUI/CityDetailPanel/MarginContainer/Content/HeaderRow
@onready var city_detail_secondary_tab_row: HBoxContainer = $WorldMapUI/CityDetailPanel/MarginContainer/Content/TabRow
@onready var city_detail_heading_label: Label = $WorldMapUI/CityDetailPanel/MarginContainer/Content/HeaderRow/HeadingLabel
@onready var city_detail_resource_tab_button_placeholder: Button = $WorldMapUI/CityDetailPanel/MarginContainer/Content/TabRow/ResourceTabButtonPlaceholder
@onready var city_detail_internal_trade_tab_button_placeholder: Button = $WorldMapUI/CityDetailPanel/MarginContainer/Content/TabRow/InternalTradeTabButtonPlaceholder
@onready var city_detail_external_trade_tab_button_placeholder: Button = $WorldMapUI/CityDetailPanel/MarginContainer/Content/TabRow/ExternalTradeTabButtonPlaceholder
@onready var city_detail_collapse_button_placeholder: Button = $WorldMapUI/CityDetailPanel/MarginContainer/Content/HeaderRow/CollapseButtonPlaceholder
@onready var city_detail_name_label: Label = $WorldMapUI/CityDetailPanel/MarginContainer/Content/CityNameLabel
@onready var city_detail_type_label: Label = $WorldMapUI/CityDetailPanel/MarginContainer/Content/CityTypeLabel
@onready var city_detail_region_owner_label: Label = $WorldMapUI/CityDetailPanel/MarginContainer/Content/RegionOwnerLabel
@onready var city_detail_resource_label: Label = $WorldMapUI/CityDetailPanel/MarginContainer/Content/ResourceLabel
@onready var city_detail_security_label: Label = $WorldMapUI/CityDetailPanel/MarginContainer/Content/SecurityLabel
@onready var city_detail_military_label: Label = $WorldMapUI/CityDetailPanel/MarginContainer/Content/MilitaryLabel
@onready var city_detail_commerce_label: Label = $WorldMapUI/CityDetailPanel/MarginContainer/Content/CommerceLabel
@onready var city_detail_rating_label: Label = $WorldMapUI/CityDetailPanel/MarginContainer/Content/RatingLabel
@onready var city_detail_status_label: Label = $WorldMapUI/CityDetailPanel/MarginContainer/Content/StatusLabel
@onready var city_detail_hint_label: Label = $WorldMapUI/CityDetailPanel/MarginContainer/Content/HintLabel
@onready var city_detail_domestic_button_placeholder: Button = $WorldMapUI/CityDetailPanel/MarginContainer/Content/DomesticButtonPlaceholder

var _world_rect := Rect2()
var _is_dragging := false
var _dragging_hud_panel: Control = null
var _dragging_hud_pointer_offset := Vector2.ZERO
var _chancellor_portrait_texture_rect: TextureRect = null
var selected_city_id: String = ""
var selected_city_marker: WorldMapCityMarker = null
var _city_markers_by_id: Dictionary = {}
var _unified_primary_tab := UNIFIED_PANEL_TAB_CITY_DETAIL
var _selected_diplomacy_spy_tab := DIPLOMACY_SPY_TAB_DIPLOMACY
var _warehouse_card: PanelContainer
var _warehouse_resource_row_labels: Dictionary = {}
var _pending_invasion_choice_card: PanelContainer
var _pending_invasion_title_label: Label
var _pending_invasion_detail_label: Label
var _pending_invasion_instruction_label: Label
var _manual_defense_button: Button
var _auto_defense_button: Button
var _save_management_title_label: Label
var _save_management_status_label: Label
var _save_management_status := ""
var _enemy_turn_mvp_timer: Timer
var _enemy_turn_mvp_pending := false
var _domestic_turn_apply_pending := false
var _default_player_state: Dictionary = {}
var _is_unified_city_panel_collapsed := false
var _unified_city_panel_expanded_size := Vector2.ZERO
var _unified_city_detail_primary_button: Button = null
var _unified_diplomacy_spy_primary_button: Button = null
var _has_warned_missing_unified_panel_chrome := false
var _collapsed_unified_panel_click_candidate := false
var _collapsed_unified_panel_drag_started := false
var _collapsed_unified_panel_click_start_position := Vector2.ZERO
var _player_state := {
	"player_faction_id": "player",
	"ruler_current_city_id": "hanseong",
	"selected_city_id": "hanseong",
	"origin_city_id": "hanseong",
	"owned_city_ids": ["hanseong"],
	"owned_hero_ids": ["yi_sun_sin", "jeong_do_jeon", "cheok_jun_gyeong"],
	"turn_number": 1,
	"turn_phase": TURN_PHASE_PLAYER,
	"turn_label": "제 1턴",
	"year_label": "154년 봄 1일",
	"current_phase_label": "아군 턴",
	"pending_invasion_event": {},
	"pending_battle_context": {},
	"enemy_invasion_roll_turn": 0,
	"domestic_apply_pending": false,
	"last_domestic_apply_turn": 0,
	"national_loyalty": 75,
	"tax_level": 30,
	"public_order": 68,
	"chancellor_id": "",
	"chancellor_policy_id": "balanced",
	"resources": "쌀 300 / 보리 250 / 수산물 80 / 목재 100 / 철 50 / 말 30 / 비단 30 / 소금 50 / 금전 500",
	"resource_stock": {"rice": 300, "barley": 250, "seafood": 80, "wood": 100, "iron": 50, "horses": 30, "silk": 30, "salt": 50, "gold": 500},
	"warehouse": "국가 창고: 쌀 300/1000 정상 · 보리 250/1000 정상 · 수산물 80/500 낮음 · 목재 100/800 낮음 · 철 50/500 낮음 · 말 30/300 낮음 · 비단 30/300 낮음 · 소금 50/400 낮음 · 금전 500/9999 정상",
	"upkeep": "영웅 유지비: 쌀 -8 / 수산물 -3 / 비단 -1 · 병사 유지비 preview: 쌀 -18 / 보리 -15 / 수산물 -3 (영웅 병력 0명 + 주둔군 300명 기준, 미차감)",
	"salt": "보존 소금: 필요 50 / 보유 50 / 유지비 정상",
	"supply": "활성 교역로 3개 · 금전 +0 / 식량 +0 / 소금 +0 · 군사 지원 필요 도시: 한성",
	"troop_rebalance": "목표 주둔군 충족 · 총 이동 0명",
	"trade": "활성 교역로 0개 · 이번 턴 수익: 금전 +0 / 식량 +0 / 소금 +0 · 세력 관계: 없음",
	"income": "이번 턴 수입 없음",
	"tax_effect": "세금 효과: 인구·상업세 적용, 충성도 0",
}
var _city_policy_state: Dictionary = {}
var _selected_city_detail_tab := CITY_DETAIL_TAB_RESOURCES


func _ready() -> void:
	_default_player_state = _player_state.duplicate(true)
	_ensure_worldmap_runtime_state_defaults()
	_hide_retired_top_worldmap_hud()
	_refresh_world_rect_from_scene_tiles()
	_connect_city_markers()
	city_info_panel.set_city_markers(_city_markers_by_id)
	city_info_panel.set_hud_data(HERO_DATA, CITY_HUD_DATA, GOVERNOR_POLICY_DATA, _city_policy_state)
	city_info_panel.set_pending_invasion_event(_get_pending_invasion_event_mvp())
	_setup_left_world_controls()
	_ensure_chancellor_portrait_texture_rect()
	_setup_left_world_status_panel_layout()
	_consume_worldmap_battle_result_if_any()
	_refresh_left_world_status_panel()
	_connect_world_hud_placeholders()
	_setup_unified_city_detail_diplomacy_panel()
	_setup_independent_hud_panel_drag()
	_reset_city_detail_panel()
	_configure_camera()
	_update_camera_debug_label()


func _process(delta: float) -> void:
	_handle_keyboard_pan(delta)
	_update_camera_debug_label()


func _input(event: InputEvent) -> void:
	if _dragging_hud_panel == null:
		return

	if event is InputEventMouseMotion:
		var mouse_motion_event := event as InputEventMouseMotion
		if _collapsed_unified_panel_click_candidate and not _collapsed_unified_panel_drag_started:
			var drag_distance := mouse_motion_event.global_position.distance_to(_collapsed_unified_panel_click_start_position)
			if drag_distance < UNIFIED_PANEL_COLLAPSED_DRAG_THRESHOLD:
				get_viewport().set_input_as_handled()
				return
			_collapsed_unified_panel_drag_started = true
		_move_hud_panel_to_screen_position(_dragging_hud_panel, mouse_motion_event.global_position - _dragging_hud_pointer_offset)
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton:
		var mouse_button_event := event as InputEventMouseButton
		if mouse_button_event.button_index == MOUSE_BUTTON_LEFT and not mouse_button_event.pressed:
			var should_expand_unified_panel := (
				_dragging_hud_panel == city_detail_panel
				and _is_unified_city_panel_collapsed
				and _collapsed_unified_panel_click_candidate
				and not _collapsed_unified_panel_drag_started
			)
			_dragging_hud_panel = null
			_collapsed_unified_panel_click_candidate = false
			_collapsed_unified_panel_drag_started = false
			if should_expand_unified_panel:
				_set_unified_city_panel_collapsed(false)
			get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_button_event := event as InputEventMouseButton
		if mouse_button_event.button_index == MOUSE_BUTTON_MIDDLE or mouse_button_event.button_index == MOUSE_BUTTON_RIGHT:
			_is_dragging = mouse_button_event.pressed
			get_viewport().set_input_as_handled()
		elif mouse_button_event.pressed and mouse_button_event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_apply_zoom(WORLD_MAP_ZOOM_STEP)
			get_viewport().set_input_as_handled()
		elif mouse_button_event.pressed and mouse_button_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_apply_zoom(-WORLD_MAP_ZOOM_STEP)
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and _is_dragging:
		var mouse_motion_event := event as InputEventMouseMotion
		world_map_camera.position -= mouse_motion_event.relative / world_map_camera.zoom * WORLD_MAP_CAMERA_DRAG_SPEED
		_clamp_camera_to_world()
		get_viewport().set_input_as_handled()


func _hide_retired_top_worldmap_hud() -> void:
	world_title_panel.visible = false
	right_hud_dragbar.visible = false


func _setup_independent_hud_panel_drag() -> void:
	_register_hud_panel_drag(left_world_status_panel, [left_world_status_eyebrow_label, turn_label])
	_register_hud_panel_drag(city_detail_panel, [city_detail_eyebrow_label, city_detail_heading_label])
	_register_hud_panel_drag(city_info_panel_control, [city_info_eyebrow_label, city_info_city_name_label])


func _register_hud_panel_drag(panel: Control, handles: Array) -> void:
	if panel == null:
		return

	for handle in handles:
		var handle_control := handle as Control
		if handle_control == null:
			continue
		handle_control.mouse_filter = Control.MOUSE_FILTER_STOP
		if not handle_control.gui_input.is_connected(_on_hud_drag_handle_gui_input):
			handle_control.gui_input.connect(_on_hud_drag_handle_gui_input.bind(panel, handle_control))


func _on_hud_drag_handle_gui_input(event: InputEvent, panel: Control, handle: Control) -> void:
	if not event is InputEventMouseButton:
		return

	var mouse_button_event := event as InputEventMouseButton
	if mouse_button_event.button_index != MOUSE_BUTTON_LEFT or not mouse_button_event.pressed:
		return

	_dragging_hud_panel = panel
	_dragging_hud_pointer_offset = mouse_button_event.global_position - panel.global_position
	if panel == city_detail_panel and _is_unified_city_panel_collapsed:
		_collapsed_unified_panel_click_candidate = true
		_collapsed_unified_panel_drag_started = false
		_collapsed_unified_panel_click_start_position = mouse_button_event.global_position
	else:
		_collapsed_unified_panel_click_candidate = false
		_collapsed_unified_panel_drag_started = false
	panel.move_to_front()
	handle.accept_event()


func _move_hud_panel_to_screen_position(panel: Control, next_global_position: Vector2) -> void:
	if panel == null:
		return

	var viewport_size := get_viewport_rect().size
	var min_visible_size := Vector2(72.0, 42.0)
	var panel_size := panel.size
	if panel_size.x <= 0.0 or panel_size.y <= 0.0:
		panel_size = panel.get_rect().size

	var clamped_global_position := Vector2(
		clampf(next_global_position.x, -panel_size.x + min_visible_size.x, viewport_size.x - min_visible_size.x),
		clampf(next_global_position.y, 0.0, viewport_size.y - min_visible_size.y)
	)
	panel.global_position = clamped_global_position


func _refresh_world_rect_from_scene_tiles() -> void:
	var tile_rects: Array[Rect2] = []
	var tiles: Array[Sprite2D] = [tile_a1_top_left, tile_a2_top_right, tile_b1_bottom_left, tile_b2_bottom_right]
	for tile in tiles:
		var tile_rect := _get_tile_world_rect(tile)
		if tile_rect.size != Vector2.ZERO:
			tile_rects.append(tile_rect)

	if tile_rects.is_empty():
		push_warning("WorldMap tile rects are unavailable; using fallback camera clamp rect.")
		_world_rect = Rect2(Vector2.ZERO, Vector2(1024.0, 1024.0))
		return

	_world_rect = tile_rects[0]
	for tile_rect_index in range(1, tile_rects.size()):
		_world_rect = _world_rect.merge(tile_rects[tile_rect_index])


func _configure_camera() -> void:
	world_map_camera.enabled = true
	world_map_camera.make_current()
	world_map_camera.zoom = Vector2(0.7, 0.7)
	world_map_camera.position = _world_rect.get_center()
	_clamp_camera_to_world()


func _handle_keyboard_pan(delta: float) -> void:
	var input_vector := Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		input_vector.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		input_vector.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		input_vector.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		input_vector.y += 1.0

	if input_vector == Vector2.ZERO:
		return

	world_map_camera.position += input_vector.normalized() * WORLD_MAP_CAMERA_SPEED * delta / world_map_camera.zoom.x
	_clamp_camera_to_world()


func _apply_zoom(zoom_delta: float) -> void:
	var next_zoom_value := clampf(world_map_camera.zoom.x + zoom_delta, WORLD_MAP_MIN_ZOOM, WORLD_MAP_MAX_ZOOM)
	world_map_camera.zoom = Vector2(next_zoom_value, next_zoom_value)
	_clamp_camera_to_world()


func _clamp_camera_to_world() -> void:
	if _world_rect.size == Vector2.ZERO:
		return

	var viewport_size := get_viewport_rect().size
	var half_visible_size := viewport_size / (world_map_camera.zoom * 2.0)
	var min_center := _world_rect.position + half_visible_size - Vector2.ONE * WORLD_MAP_CLAMP_PADDING
	var max_center := _world_rect.end - half_visible_size + Vector2.ONE * WORLD_MAP_CLAMP_PADDING

	var clamped_x := world_map_camera.position.x
	var clamped_y := world_map_camera.position.y
	if min_center.x > max_center.x:
		clamped_x = _world_rect.get_center().x
	else:
		clamped_x = clampf(world_map_camera.position.x, min_center.x, max_center.x)

	if min_center.y > max_center.y:
		clamped_y = _world_rect.get_center().y
	else:
		clamped_y = clampf(world_map_camera.position.y, min_center.y, max_center.y)

	world_map_camera.position = Vector2(clamped_x, clamped_y)


func _get_tile_world_rect(tile: Sprite2D) -> Rect2:
	if tile == null or tile.texture == null:
		return Rect2()

	var texture_size := tile.texture.get_size()
	var local_top_left := Vector2.ZERO
	if tile.centered:
		local_top_left = -texture_size * 0.5

	var local_corners: Array[Vector2] = [
		local_top_left,
		local_top_left + Vector2(texture_size.x, 0.0),
		local_top_left + Vector2(0.0, texture_size.y),
		local_top_left + texture_size,
	]

	var world_points: Array[Vector2] = []
	for local_corner in local_corners:
		world_points.append(tile.to_global(local_corner))

	var min_point := world_points[0]
	var max_point := world_points[0]
	for point_index in range(1, world_points.size()):
		min_point = min_point.min(world_points[point_index])
		max_point = max_point.max(world_points[point_index])

	return Rect2(min_point, max_point - min_point)


func _update_camera_debug_label() -> void:
	camera_debug_label.text = "Camera: %s  Zoom: %.2f" % [
		_format_vector2(world_map_camera.position),
		world_map_camera.zoom.x,
	]


func _format_vector2(value: Vector2) -> String:
	return "(%.0f, %.0f)" % [value.x, value.y]


func _connect_city_markers() -> void:
	for child in city_layer.get_children():
		var city_marker := child as WorldMapCityMarker
		if city_marker == null:
			continue
		_city_markers_by_id[city_marker.city_id] = city_marker
		if not city_marker.city_selected.is_connected(_on_city_marker_selected):
			city_marker.city_selected.connect(_on_city_marker_selected)


func _on_city_marker_selected(city_marker: WorldMapCityMarker) -> void:
	if selected_city_marker != null and selected_city_marker != city_marker:
		selected_city_marker.set_selected(false)

	selected_city_id = city_marker.city_id
	selected_city_marker = city_marker
	selected_city_marker.set_selected(true)
	_player_state["selected_city_id"] = selected_city_id
	city_info_panel.set_pending_invasion_event(_get_pending_invasion_event_mvp())
	city_info_panel.show_city(city_marker)
	_refresh_left_world_status_panel()
	_refresh_unified_panel_content()


func _connect_world_hud_placeholders() -> void:
	wild_army_edit_button_placeholder.pressed.connect(_on_ally_turn_end_pressed)
	save_button_placeholder.pressed.connect(_save_worldmap_state)
	load_button_placeholder.pressed.connect(_load_worldmap_state)
	reset_button_placeholder.pressed.connect(_reset_worldmap_state)
	diplomacy_mode_button_placeholder.pressed.connect(_on_diplomacy_mode_placeholder_pressed)
	spy_mode_button_placeholder.pressed.connect(_on_spy_mode_placeholder_pressed)
	city_detail_resource_tab_button_placeholder.pressed.connect(_on_unified_secondary_tab_pressed.bind(0))
	city_detail_internal_trade_tab_button_placeholder.pressed.connect(_on_unified_secondary_tab_pressed.bind(1))
	city_detail_external_trade_tab_button_placeholder.pressed.connect(_on_unified_secondary_tab_pressed.bind(2))
	city_detail_collapse_button_placeholder.pressed.connect(_on_city_detail_collapse_placeholder_pressed)
	city_detail_domestic_button_placeholder.pressed.connect(_on_city_detail_domestic_placeholder_pressed)


func _setup_unified_city_detail_diplomacy_panel() -> void:
	diplomacy_spy_panel.visible = false
	_unified_city_panel_expanded_size = city_detail_panel.size
	city_detail_eyebrow_label.text = "CITY DETAIL / DIPLOMACY"
	city_detail_heading_label.visible = false
	city_detail_heading_label.text = ""
	city_detail_collapse_button_placeholder.text = "접기"
	_ensure_unified_primary_tab_buttons()
	_refresh_unified_panel_chrome()
	_queue_unified_city_panel_resize()


func _ensure_unified_primary_tab_buttons() -> void:
	if _unified_city_detail_primary_button != null and _unified_diplomacy_spy_primary_button != null:
		return
	if city_detail_header_row == null:
		_warn_missing_unified_panel_chrome("HeaderRow")
		return

	_unified_city_detail_primary_button = _create_unified_primary_tab_button("도시 상세", UNIFIED_PANEL_TAB_CITY_DETAIL)
	_unified_diplomacy_spy_primary_button = _create_unified_primary_tab_button("외교·첩보", UNIFIED_PANEL_TAB_DIPLOMACY_SPY)
	var collapse_index := city_detail_header_row.get_children().find(city_detail_collapse_button_placeholder)
	if collapse_index < 0:
		collapse_index = city_detail_header_row.get_child_count()
	city_detail_header_row.add_child(_unified_city_detail_primary_button)
	city_detail_header_row.move_child(_unified_city_detail_primary_button, collapse_index)
	city_detail_header_row.add_child(_unified_diplomacy_spy_primary_button)
	city_detail_header_row.move_child(_unified_diplomacy_spy_primary_button, collapse_index + 1)


func _create_unified_primary_tab_button(label_text: String, tab_id: String) -> Button:
	var button := Button.new()
	button.text = label_text
	button.custom_minimum_size = Vector2(82.0, 24.0)
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.add_theme_font_size_override("font_size", 11)
	button.pressed.connect(_on_unified_primary_tab_pressed.bind(tab_id))
	return button


func _warn_missing_unified_panel_chrome(node_name: String) -> void:
	if _has_warned_missing_unified_panel_chrome:
		return
	_has_warned_missing_unified_panel_chrome = true
	push_warning("[WorldMap] Unified panel chrome node missing: %s" % node_name)


func _refresh_unified_panel_chrome() -> void:
	if _is_unified_city_panel_collapsed:
		return

	_ensure_unified_primary_tab_buttons()
	if city_detail_heading_label != null:
		city_detail_heading_label.visible = false
	if _unified_city_detail_primary_button != null:
		_unified_city_detail_primary_button.visible = true
		_unified_city_detail_primary_button.modulate = Color(1.0, 0.9, 0.68, 1.0) if _unified_primary_tab == UNIFIED_PANEL_TAB_CITY_DETAIL else Color(0.82, 0.86, 0.92, 1.0)
	else:
		_warn_missing_unified_panel_chrome("CityDetailPrimaryButton")
	if _unified_diplomacy_spy_primary_button != null:
		_unified_diplomacy_spy_primary_button.visible = true
		_unified_diplomacy_spy_primary_button.modulate = Color(1.0, 0.9, 0.68, 1.0) if _unified_primary_tab == UNIFIED_PANEL_TAB_DIPLOMACY_SPY else Color(0.82, 0.86, 0.92, 1.0)
	else:
		_warn_missing_unified_panel_chrome("DiplomacySpyPrimaryButton")
	if city_detail_secondary_tab_row != null:
		city_detail_secondary_tab_row.visible = true
	else:
		_warn_missing_unified_panel_chrome("TabRow")

	if _unified_primary_tab == UNIFIED_PANEL_TAB_DIPLOMACY_SPY:
		if city_detail_resource_tab_button_placeholder != null:
			city_detail_resource_tab_button_placeholder.text = "외교"
			_set_city_detail_tab_active(city_detail_resource_tab_button_placeholder, _selected_diplomacy_spy_tab == DIPLOMACY_SPY_TAB_DIPLOMACY)
		else:
			_warn_missing_unified_panel_chrome("ResourceTabButtonPlaceholder")
		if city_detail_internal_trade_tab_button_placeholder != null:
			city_detail_internal_trade_tab_button_placeholder.text = "첩보"
			_set_city_detail_tab_active(city_detail_internal_trade_tab_button_placeholder, _selected_diplomacy_spy_tab == DIPLOMACY_SPY_TAB_SPY)
		else:
			_warn_missing_unified_panel_chrome("InternalTradeTabButtonPlaceholder")
		if city_detail_external_trade_tab_button_placeholder != null:
			city_detail_external_trade_tab_button_placeholder.visible = false
		else:
			_warn_missing_unified_panel_chrome("ExternalTradeTabButtonPlaceholder")
	else:
		if city_detail_resource_tab_button_placeholder != null:
			city_detail_resource_tab_button_placeholder.text = "자원"
		else:
			_warn_missing_unified_panel_chrome("ResourceTabButtonPlaceholder")
		if city_detail_internal_trade_tab_button_placeholder != null:
			city_detail_internal_trade_tab_button_placeholder.text = "자국무역"
		else:
			_warn_missing_unified_panel_chrome("InternalTradeTabButtonPlaceholder")
		if city_detail_external_trade_tab_button_placeholder != null:
			city_detail_external_trade_tab_button_placeholder.text = "타국무역"
			city_detail_external_trade_tab_button_placeholder.visible = true
		else:
			_warn_missing_unified_panel_chrome("ExternalTradeTabButtonPlaceholder")
		_refresh_city_detail_tab_styles()


func _refresh_unified_panel_content() -> void:
	_refresh_unified_panel_chrome()
	if _is_unified_city_panel_collapsed:
		return
	if _unified_primary_tab == UNIFIED_PANEL_TAB_DIPLOMACY_SPY:
		_show_unified_diplomacy_spy_content()
	elif selected_city_marker != null:
		_show_city_detail(selected_city_marker)
	else:
		_reset_city_detail_panel()
	_queue_unified_city_panel_resize()


func _reset_city_detail_panel() -> void:
	if _unified_primary_tab == UNIFIED_PANEL_TAB_DIPLOMACY_SPY:
		_show_unified_diplomacy_spy_content()
		return

	_refresh_city_detail_tab_styles()
	city_detail_name_label.text = "도시를 선택하세요"
	city_detail_type_label.text = "유형: -"
	city_detail_region_owner_label.text = "지역 · 세력: -"
	city_detail_resource_label.text = "도시 상세: 도시를 선택하세요."
	city_detail_security_label.text = "자원 / 자국무역 / 타국무역 탭은 웹버전 구조를 따릅니다."
	city_detail_military_label.text = "군사: -"
	city_detail_commerce_label.text = "상업: -"
	city_detail_rating_label.text = "도시 자원 별점: -"
	city_detail_status_label.text = "상태: 선택 도시 없음"
	city_detail_hint_label.text = "도시 선택 시 상세 정보가 갱신됩니다."
	_queue_unified_city_panel_resize()


func _show_city_detail(city_marker: WorldMapCityMarker) -> void:
	if _unified_primary_tab == UNIFIED_PANEL_TAB_DIPLOMACY_SPY:
		_show_unified_diplomacy_spy_content()
		return

	if city_marker == null:
		_reset_city_detail_panel()
		return

	city_detail_name_label.text = city_marker.display_name
	city_detail_type_label.text = "유형: %s" % _format_city_type(city_marker.city_id)
	city_detail_region_owner_label.text = "%s · %s" % [
		_format_region_label(city_marker.region_id),
		_format_faction_label(city_marker.owner_faction_id),
	]
	var city_data := _get_city_hud_entry(city_marker.city_id)
	var governor_id := str(city_data.get("governor_id", ""))
	var governor_data := _get_hero_entry(governor_id)
	var governor_name := str(governor_data.get("display_name", "태수 미임명"))
	var policy_id := _get_city_policy_id(city_marker.city_id, city_data)
	var policy_data := _get_governor_policy_entry(policy_id)
	var stationed_hero_ids: Array = city_data.get("stationed_hero_ids", [])
	var loyalty := int(city_data.get("loyalty", 75))
	_refresh_city_detail_tab_styles()
	_apply_city_detail_tab_content(city_marker, city_data, loyalty, policy_data)
	city_detail_status_label.text = "상태: %s · 태수: %s · 배치 무장 %d명" % [
		_get_city_detail_status(city_marker),
		governor_name,
		stationed_hero_ids.size(),
	]
	city_detail_hint_label.text = "웹버전 City Detail 구조 표시 전용입니다. 내정 수치 변경과 턴 처리는 실행하지 않습니다."
	_queue_unified_city_panel_resize()


func _apply_city_detail_tab_content(city_marker: WorldMapCityMarker, city_data: Dictionary, loyalty: int, policy_data: Dictionary) -> void:
	match _selected_city_detail_tab:
		CITY_DETAIL_TAB_INTERNAL_TRADE:
			city_detail_resource_label.text = "무역/보급 정보: 내부 교역로 %s" % _format_internal_route_summary(city_marker)
			city_detail_security_label.text = "보급 우선도: 표시 전용 · 이번 턴 배분: 금전 +0 / 식량 +0 / 소금 +0"
			city_detail_military_label.text = "군사 보급 판단: 도시 역할 %s · %s" % [
				_get_city_detail_status(city_marker),
				str(city_data.get("military", "현재 주둔군 / 목표 주둔군 placeholder")),
			]
			city_detail_commerce_label.text = "내부 병력 재배치: 최근 이동 없음 · 실제 병력 이동 없음"
			city_detail_rating_label.text = "자국무역 탭: 무역/보급 정보 · 군사 보급 판단 · 내부 병력 재배치"
			city_detail_domestic_button_placeholder.text = "무역 조정"
		CITY_DETAIL_TAB_EXTERNAL_TRADE:
			city_detail_resource_label.text = "대외 무역 / 세력 관계: %s" % _format_external_trade_target(city_marker)
			city_detail_security_label.text = "관계: 표시 전용 · 상태: 교역 가능 여부 계산은 웹 후속 로직"
			city_detail_military_label.text = "운영: 자동 운영 · 교역 강도: 보통 · 효율 100%"
			city_detail_commerce_label.text = "무역 수익: 금전 +0 / 식량 +0 / 소금 +0 · 주요 품목: 일반 물자"
			city_detail_rating_label.text = "타국무역 탭 버튼: 무역 조정 / 교역 강화 / 교역 중단 / 교역 재개 placeholder"
			city_detail_domestic_button_placeholder.text = "무역 조정"
		_:
			city_detail_resource_label.text = "식량 자원: %s" % _extract_resource_group(str(city_data.get("resources", "")), ["쌀", "보리", "수산물"])
			city_detail_security_label.text = "전략 자원: %s" % _extract_resource_group(str(city_data.get("resources", "")), ["목재", "철", "말"])
			city_detail_military_label.text = "특산 자원: %s" % _extract_resource_group(str(city_data.get("resources", "")), ["비단", "소금"])
			city_detail_commerce_label.text = "상업: %s · 태수 정책: %s" % [
				str(city_data.get("rating", "상업력 -")),
				str(policy_data.get("name", "정책 미정")),
			]
			city_detail_rating_label.text = "성충성도: %d · %s" % [loyalty, str(city_data.get("military", "군대 상태 준비 중"))]
			city_detail_domestic_button_placeholder.text = "무역 조정"


func _show_unified_diplomacy_spy_content() -> void:
	_refresh_unified_panel_chrome()
	city_detail_name_label.text = "외교·첩보"
	var selected_city_name := "미선택"
	var selected_city_label := "미선택"
	var owner_label := "미상 세력"
	var relation_label := "관계 미확인"
	var relation_description := "세력 정보를 확인 중입니다."
	if selected_city_marker != null:
		selected_city_name = selected_city_marker.display_name
		owner_label = _format_faction_label(selected_city_marker.owner_faction_id)
		selected_city_label = "%s · %s" % [
			selected_city_marker.display_name,
			owner_label,
		]
		relation_label = _get_selected_city_relation_label(selected_city_marker)
		relation_description = _get_selected_city_relation_description(selected_city_marker)
	city_detail_type_label.text = "모드: %s" % _get_diplomacy_spy_tab_label(_selected_diplomacy_spy_tab)
	city_detail_region_owner_label.text = "기준: PLAYER · 선택 도시: %s" % selected_city_label
	if _selected_diplomacy_spy_tab == DIPLOMACY_SPY_TAB_SPY:
		city_detail_resource_label.text = "첩보 가시성: 정보 등급 기초 정보 · 대상 도시 %s" % selected_city_name
		city_detail_security_label.text = "자원 정보: 제한 공개 · 병력 정보: 제한 공개"
		city_detail_military_label.text = "첩보 행동: 정탐 / 유언비어 / 내통 시도"
		city_detail_commerce_label.text = "성주 / 재상 정보는 준비 중입니다."
		city_detail_rating_label.text = "첩보 계산과 성공/실패 판정은 후속 버전에서 연결합니다."
		city_detail_domestic_button_placeholder.text = "정탐"
		city_detail_hint_label.text = "웹버전 Diplomacy / Spy의 첩보 구조를 표시만 합니다. 확률 계산과 턴 소비는 없습니다."
	else:
		city_detail_resource_label.text = "외교 현황: 선택 도시 %s · 소유 세력 %s" % [selected_city_name, owner_label]
		city_detail_security_label.text = "관계 상태: %s · %s" % [relation_label, relation_description]
		city_detail_military_label.text = "외교 행동: 사절 교환 / 교섭 요청 / 교역 압박"
		city_detail_commerce_label.text = "행동 상태: 사절 교환 준비 중 · 교섭 요청 준비 중 · 교역 압박 준비 중"
		city_detail_rating_label.text = "외교 행동은 준비 중입니다."
		city_detail_domestic_button_placeholder.text = "사절 교환"
		city_detail_hint_label.text = "웹버전 Diplomacy / Spy의 외교 구조를 표시만 합니다. 관계 변경과 교역 조정은 실행하지 않습니다."
	city_detail_status_label.text = "상태: %s 표시 전용" % _get_diplomacy_spy_tab_label(_selected_diplomacy_spy_tab)
	_queue_unified_city_panel_resize()


func _get_selected_city_relation_label(city_marker: WorldMapCityMarker) -> String:
	if city_marker == null or city_marker.owner_faction_id.is_empty():
		return "관계 미확인"
	if city_marker.owner_faction_id == PLAYER_FACTION_ID:
		return "자국 도시"
	return "중립 교역"


func _get_selected_city_relation_description(city_marker: WorldMapCityMarker) -> String:
	if city_marker == null or city_marker.owner_faction_id.is_empty():
		return "세력 정보를 확인 중입니다."
	if city_marker.owner_faction_id == PLAYER_FACTION_ID:
		return "동일 세력 소유 도시입니다."
	return "교역 가능"


func _get_diplomacy_spy_tab_label(tab_id: String) -> String:
	if tab_id == DIPLOMACY_SPY_TAB_SPY:
		return "첩보"
	return "외교"


func _refresh_city_detail_tab_styles() -> void:
	if _unified_primary_tab == UNIFIED_PANEL_TAB_DIPLOMACY_SPY:
		_refresh_unified_panel_chrome()
		return

	_set_city_detail_tab_active(city_detail_resource_tab_button_placeholder, _selected_city_detail_tab == CITY_DETAIL_TAB_RESOURCES)
	_set_city_detail_tab_active(city_detail_internal_trade_tab_button_placeholder, _selected_city_detail_tab == CITY_DETAIL_TAB_INTERNAL_TRADE)
	_set_city_detail_tab_active(city_detail_external_trade_tab_button_placeholder, _selected_city_detail_tab == CITY_DETAIL_TAB_EXTERNAL_TRADE)


func _set_city_detail_tab_active(button: Button, is_active: bool) -> void:
	if button == null:
		_warn_missing_unified_panel_chrome("CityDetailTabButton")
		return
	button.modulate = Color(1.0, 0.9, 0.68, 1.0) if is_active else Color(0.82, 0.86, 0.92, 1.0)


func _extract_resource_group(resource_summary: String, resource_names: Array[String]) -> String:
	if resource_summary.is_empty():
		return "미확인"

	var matches: Array[String] = []
	for chunk in resource_summary.split(" / "):
		for resource_name in resource_names:
			if chunk.begins_with(resource_name):
				matches.append(chunk)
				break

	return " / ".join(matches) if not matches.is_empty() else "미확인"


func _format_internal_route_summary(city_marker: WorldMapCityMarker) -> String:
	if city_marker.neighbors.is_empty():
		return "비활성"

	var linked_names: Array[String] = []
	for neighbor_id in city_marker.neighbors.slice(0, 2):
		var neighbor_marker := _city_markers_by_id.get(neighbor_id) as WorldMapCityMarker
		linked_names.append(neighbor_marker.display_name if neighbor_marker != null else str(neighbor_id))
	return " / ".join(linked_names)


func _format_external_trade_target(city_marker: WorldMapCityMarker) -> String:
	for neighbor_id in city_marker.neighbors:
		var neighbor_marker := _city_markers_by_id.get(neighbor_id) as WorldMapCityMarker
		if neighbor_marker != null and neighbor_marker.owner_faction_id != city_marker.owner_faction_id:
			return "%s · %s" % [neighbor_marker.display_name, _format_faction_label(neighbor_marker.owner_faction_id)]
	return "인접 대외 교역 없음"


func _setup_left_world_controls() -> void:
	tax_slider.min_value = 0.0
	tax_slider.max_value = 100.0
	tax_slider.step = 1.0
	tax_slider.value = float(_normalize_tax_level(_player_state.get("tax_level", 30)))
	if not tax_slider.value_changed.is_connected(_on_tax_slider_value_changed):
		tax_slider.value_changed.connect(_on_tax_slider_value_changed)
	if not chancellor_assignment_option.item_selected.is_connected(_on_chancellor_assignment_selected):
		chancellor_assignment_option.item_selected.connect(_on_chancellor_assignment_selected)
	_populate_chancellor_policy_dropdown()
	if not chancellor_policy_option.item_selected.is_connected(_on_chancellor_policy_selected):
		chancellor_policy_option.item_selected.connect(_on_chancellor_policy_selected)


func _setup_left_world_status_panel_layout() -> void:
	left_world_status_panel.custom_minimum_size.x = 320.0
	_setup_warehouse_card_ui()
	_setup_pending_invasion_choice_ui()
	_setup_save_management_ui()
	for label in [
		power_label,
		tax_label,
		security_label,
		chancellor_stats_label,
		chancellor_policy_description_label,
		resource_label,
		supply_label,
		military_logistics_label,
		external_trade_label,
		world_status_hint_label,
	]:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	resource_label.visible = false
	resource_label.text = ""
	resource_label.add_theme_font_size_override("font_size", 10)
	supply_label.add_theme_font_size_override("font_size", 10)
	military_logistics_label.add_theme_font_size_override("font_size", 10)
	external_trade_label.add_theme_font_size_override("font_size", 10)


func _setup_pending_invasion_choice_ui() -> void:
	if _pending_invasion_choice_card != null:
		return
	var parent := world_status_hint_label.get_parent()
	_pending_invasion_choice_card = PanelContainer.new()
	_pending_invasion_choice_card.name = "PendingInvasionChoiceCard"
	_pending_invasion_choice_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.11, 0.05, 0.06, 0.92)
	panel_style.border_color = Color(0.95, 0.46, 0.32, 0.76)
	panel_style.set_border_width_all(1)
	panel_style.set_corner_radius_all(4)
	panel_style.content_margin_left = 9.0
	panel_style.content_margin_top = 8.0
	panel_style.content_margin_right = 9.0
	panel_style.content_margin_bottom = 8.0
	_pending_invasion_choice_card.add_theme_stylebox_override("panel", panel_style)
	parent.add_child(_pending_invasion_choice_card)
	parent.move_child(_pending_invasion_choice_card, world_status_hint_label.get_index())

	var content := VBoxContainer.new()
	content.name = "PendingInvasionChoiceContent"
	content.add_theme_constant_override("separation", 5)
	_pending_invasion_choice_card.add_child(content)

	var eyebrow_label := Label.new()
	eyebrow_label.name = "EnemyInvasionEyebrowLabel"
	eyebrow_label.text = "Enemy Invasion"
	eyebrow_label.add_theme_color_override("font_color", Color(0.98, 0.74, 0.46, 1.0))
	eyebrow_label.add_theme_font_size_override("font_size", 10)
	content.add_child(eyebrow_label)

	_pending_invasion_title_label = Label.new()
	_pending_invasion_title_label.name = "PendingInvasionTitleLabel"
	_pending_invasion_title_label.text = "적군 침공 발생"
	_pending_invasion_title_label.add_theme_color_override("font_color", Color(1.0, 0.90, 0.70, 1.0))
	_pending_invasion_title_label.add_theme_font_size_override("font_size", 14)
	content.add_child(_pending_invasion_title_label)

	_pending_invasion_detail_label = Label.new()
	_pending_invasion_detail_label.name = "PendingInvasionDetailLabel"
	_pending_invasion_detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_pending_invasion_detail_label.add_theme_color_override("font_color", Color(0.95, 0.93, 0.85, 1.0))
	_pending_invasion_detail_label.add_theme_font_size_override("font_size", 11)
	content.add_child(_pending_invasion_detail_label)

	_pending_invasion_instruction_label = Label.new()
	_pending_invasion_instruction_label.name = "PendingInvasionInstructionLabel"
	_pending_invasion_instruction_label.text = "방어전을 준비하십시오."
	_pending_invasion_instruction_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_pending_invasion_instruction_label.add_theme_color_override("font_color", Color(1.0, 0.76, 0.62, 1.0))
	_pending_invasion_instruction_label.add_theme_font_size_override("font_size", 11)
	content.add_child(_pending_invasion_instruction_label)

	var action_row := HBoxContainer.new()
	action_row.name = "PendingInvasionActionRow"
	action_row.add_theme_constant_override("separation", 6)
	content.add_child(action_row)

	_manual_defense_button = Button.new()
	_manual_defense_button.name = "ManualDefenseButton"
	_manual_defense_button.text = "수동 방어"
	_manual_defense_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_manual_defense_button.add_theme_font_size_override("font_size", 11)
	action_row.add_child(_manual_defense_button)
	if not _manual_defense_button.pressed.is_connected(_on_manual_defense_pressed):
		_manual_defense_button.pressed.connect(_on_manual_defense_pressed)

	_auto_defense_button = Button.new()
	_auto_defense_button.name = "AutoDefenseButton"
	_auto_defense_button.text = "자동 방어"
	_auto_defense_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_auto_defense_button.add_theme_font_size_override("font_size", 11)
	action_row.add_child(_auto_defense_button)
	if not _auto_defense_button.pressed.is_connected(_on_auto_defense_pressed):
		_auto_defense_button.pressed.connect(_on_auto_defense_pressed)

	_pending_invasion_choice_card.visible = false


func _setup_save_management_ui() -> void:
	var save_row := save_button_placeholder.get_parent() as Control
	var parent := save_row.get_parent() as VBoxContainer
	if parent == null:
		return
	military_logistics_label.visible = false
	external_trade_label.visible = false
	world_status_hint_label.visible = false
	if _save_management_title_label == null:
		_save_management_title_label = Label.new()
		_save_management_title_label.name = "SaveManagementTitleLabel"
		_save_management_title_label.text = "저장 관리"
		_save_management_title_label.add_theme_color_override("font_color", Color(0.98, 0.82, 0.46, 1.0))
		_save_management_title_label.add_theme_font_size_override("font_size", 12)
		parent.add_child(_save_management_title_label)
		parent.move_child(_save_management_title_label, save_row.get_index())
	if _save_management_status_label == null:
		_save_management_status_label = Label.new()
		_save_management_status_label.name = "SaveManagementStatusLabel"
		_save_management_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_save_management_status_label.add_theme_color_override("font_color", Color(0.95, 0.94, 0.86, 1.0))
		_save_management_status_label.add_theme_font_size_override("font_size", 11)
		parent.add_child(_save_management_status_label)
		parent.move_child(_save_management_status_label, save_row.get_index() + 1)
	_save_management_status_label.visible = not _save_management_status.is_empty()


func _setup_warehouse_card_ui() -> void:
	if _warehouse_card != null:
		return
	var parent := supply_label.get_parent()
	_warehouse_card = PanelContainer.new()
	_warehouse_card.name = "WarehouseCard"
	_warehouse_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.05, 0.08, 0.12, 0.86)
	panel_style.border_color = Color(0.85, 0.66, 0.32, 0.58)
	panel_style.set_border_width_all(1)
	panel_style.set_corner_radius_all(4)
	panel_style.content_margin_left = 8.0
	panel_style.content_margin_top = 7.0
	panel_style.content_margin_right = 8.0
	panel_style.content_margin_bottom = 7.0
	_warehouse_card.add_theme_stylebox_override("panel", panel_style)
	parent.add_child(_warehouse_card)
	parent.move_child(_warehouse_card, supply_label.get_index())

	var content := VBoxContainer.new()
	content.name = "WarehouseCardContent"
	content.add_theme_constant_override("separation", 4)
	_warehouse_card.add_child(content)

	var title_label := Label.new()
	title_label.name = "WarehouseTitleLabel"
	title_label.text = "국가 창고"
	title_label.add_theme_color_override("font_color", Color(0.98, 0.82, 0.46, 1.0))
	title_label.add_theme_font_size_override("font_size", 12)
	content.add_child(title_label)

	for resource_id in RESOURCE_DISPLAY_ORDER:
		var resource_id_string := str(resource_id)
		var row := HBoxContainer.new()
		row.name = "WarehouseRow_%s" % resource_id_string
		row.add_theme_constant_override("separation", 6)
		content.add_child(row)

		var name_label := Label.new()
		name_label.name = "ResourceNameLabel"
		name_label.text = str(RESOURCE_LABELS.get(resource_id_string, resource_id_string))
		name_label.custom_minimum_size.x = 52.0
		name_label.add_theme_color_override("font_color", Color(0.82, 0.86, 0.92, 1.0))
		name_label.add_theme_font_size_override("font_size", 10)
		row.add_child(name_label)

		var amount_label := Label.new()
		amount_label.name = "ResourceAmountLabel"
		amount_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		amount_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		amount_label.add_theme_color_override("font_color", Color(0.90, 0.91, 0.86, 1.0))
		amount_label.add_theme_font_size_override("font_size", 10)
		row.add_child(amount_label)

		var status_label := Label.new()
		status_label.name = "ResourceStatusLabel"
		status_label.custom_minimum_size.x = 38.0
		status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		status_label.add_theme_color_override("font_color", Color(0.68, 0.88, 0.72, 1.0))
		status_label.add_theme_font_size_override("font_size", 10)
		row.add_child(status_label)

		_warehouse_resource_row_labels[resource_id_string] = {
			"name": name_label,
			"amount": amount_label,
			"status": status_label,
		}

	supply_label.visible = false
	supply_label.text = ""


func _refresh_left_world_status_panel() -> void:
	_ensure_worldmap_runtime_state_defaults()
	var selected_state_city_id := str(_player_state.get("selected_city_id", selected_city_id))
	var origin_city_id := str(_player_state.get("origin_city_id", ""))
	var selected_city_name := _format_city_name_by_id(selected_state_city_id, "선택 도시 없음")
	var origin_city_name := _format_city_name_by_id(origin_city_id, "알 수 없는 도시")
	var selected_city_data := _get_city_hud_entry(selected_state_city_id)
	left_world_status_eyebrow_label.text = "World Turn"
	turn_label.text = str(_player_state.get("turn_label", "제 1턴"))
	calendar_label.text = str(_player_state.get("year_label", "154년 봄 1일"))
	nation_label.text = "%s · 선택 %s / 기준 %s" % [
		str(_player_state.get("current_phase_label", "아군 턴")),
		selected_city_name,
		origin_city_name,
	]
	var national_loyalty := int(_player_state.get("national_loyalty", 0))
	var tax_level := _normalize_tax_level(_player_state.get("tax_level", 0))
	var public_order := int(_player_state.get("public_order", 0))
	power_label.text = "국가충성도 %d · %s" % [national_loyalty, _get_loyalty_status(national_loyalty)]
	power_bar.value = national_loyalty
	tax_label.text = "세금 수준 %d · %s" % [tax_level, _get_tax_description(tax_level)]
	tax_bar.value = tax_level
	tax_slider.set_value_no_signal(float(tax_level))
	security_label.text = _format_tax_preview(tax_level, national_loyalty, public_order)
	security_bar.value = public_order

	_sync_chancellor_assignment_for_selected_city(selected_city_data)
	_populate_chancellor_assignment_dropdown(selected_city_data)
	var chancellor_id := str(_player_state.get("chancellor_id", ""))
	var chancellor_data := _get_hero_entry(chancellor_id)
	var chancellor_name := _format_hero_name_by_id(chancellor_id, "미임명")
	var policy_id := str(_player_state.get("chancellor_policy_id", "balanced"))
	if not CHANCELLOR_POLICY_DATA.has(policy_id):
		policy_id = "balanced"
		_player_state["chancellor_policy_id"] = policy_id
	var policy_data := _get_chancellor_policy_entry(policy_id)
	chancellor_label.text = "재상"
	HeroPortraitHelper.apply_hero_portrait_or_placeholder(_chancellor_portrait_texture_rect, chancellor_portrait_label, chancellor_data)
	chancellor_name_label.text = chancellor_name
	chancellor_stats_label.text = "%s\n재상 임명: %s" % [
		"재상 없음" if chancellor_data.is_empty() else _format_chancellor_type_summary(chancellor_data),
		chancellor_name,
	]
	chancellor_policy_description_label.text = "재상 효과: %s\n재상 정책: %s · %s" % [
		_get_chancellor_effect_text(chancellor_data),
		str(policy_data.get("name", policy_id)),
		str(policy_data.get("description", "재상 정책 설명 준비 중")),
	]
	_select_option_by_metadata(chancellor_assignment_option, chancellor_id)
	_select_option_by_metadata(chancellor_policy_option, policy_id)
	resource_label.visible = false
	resource_label.text = ""
	supply_label.visible = false
	supply_label.text = ""
	_refresh_warehouse_card()
	military_logistics_label.visible = false
	military_logistics_label.text = ""
	external_trade_label.visible = false
	external_trade_label.text = ""
	var pending_invasion_event := _get_pending_invasion_event_mvp()
	city_info_panel.set_pending_invasion_event(pending_invasion_event)
	world_status_hint_label.text = _format_invasion_status_text(pending_invasion_event)
	world_status_hint_label.visible = not pending_invasion_event.is_empty()
	_refresh_pending_invasion_choice_ui(pending_invasion_event)
	wild_army_edit_button_placeholder.text = "아군 턴 종료"
	wild_army_edit_button_placeholder.disabled = _enemy_turn_mvp_pending or not pending_invasion_event.is_empty()
	save_button_placeholder.text = "저장"
	load_button_placeholder.text = "불러오기"
	reset_button_placeholder.text = "초기화"
	if _save_management_title_label != null:
		_save_management_title_label.text = "저장 관리"
	if _save_management_status_label != null:
		_save_management_status_label.text = _save_management_status
		_save_management_status_label.visible = not _save_management_status.is_empty()


func _ensure_worldmap_runtime_state_defaults() -> void:
	if not _player_state.has("turn_number"):
		_player_state["turn_number"] = 1
	_player_state["turn_number"] = maxi(1, int(_player_state.get("turn_number", 1)))
	if not _player_state.has("turn_phase"):
		_player_state["turn_phase"] = TURN_PHASE_PLAYER
	var phase := _normalize_turn_phase(str(_player_state.get("turn_phase", TURN_PHASE_PLAYER)))
	_player_state["turn_phase"] = phase
	_player_state["current_phase_label"] = _get_turn_phase_label(phase)
	_update_world_turn_labels()
	if not _player_state.has("resource_stock"):
		_player_state["resource_stock"] = {}
	if not _player_state.has("chancellor_policy_id"):
		_player_state["chancellor_policy_id"] = "balanced"
	if not _player_state.has("chancellor_id"):
		_player_state["chancellor_id"] = ""
	if not _player_state.has("domestic_apply_pending"):
		_player_state["domestic_apply_pending"] = false
	if not _player_state.has("last_domestic_apply_turn"):
		_player_state["last_domestic_apply_turn"] = 0
	if not _player_state.has("pending_invasion_event") or not (_player_state["pending_invasion_event"] is Dictionary):
		_player_state["pending_invasion_event"] = {}
	if not _player_state.has("pending_battle_context") or not (_player_state["pending_battle_context"] is Dictionary):
		_player_state["pending_battle_context"] = {}
	if not _player_state.has("enemy_invasion_roll_turn"):
		_player_state["enemy_invasion_roll_turn"] = 0


func _normalize_turn_phase(phase: String) -> String:
	return TURN_PHASE_ENEMY if phase == TURN_PHASE_ENEMY else TURN_PHASE_PLAYER


func _get_turn_phase_label(phase: String) -> String:
	return "적군 턴" if _normalize_turn_phase(phase) == TURN_PHASE_ENEMY else "아군 턴"


func _set_turn_phase(phase: String) -> void:
	var normalized_phase := _normalize_turn_phase(phase)
	_player_state["turn_phase"] = normalized_phase
	_player_state["current_phase_label"] = _get_turn_phase_label(normalized_phase)
	_refresh_left_world_status_panel()


func _update_world_turn_labels() -> void:
	var turn_number := maxi(1, int(_player_state.get("turn_number", 1)))
	_player_state["turn_label"] = "제 %d턴" % turn_number
	_player_state["year_label"] = _format_world_calendar_label(turn_number)


func _format_world_calendar_label(turn_number: int) -> String:
	var safe_turn := maxi(1, turn_number)
	var zero_based_turn := safe_turn - 1
	var year := WORLD_CALENDAR_START_YEAR + floori(float(zero_based_turn) / float(WORLD_CALENDAR_YEAR_TURNS))
	var season_index := floori(float(zero_based_turn % WORLD_CALENDAR_YEAR_TURNS) / float(WORLD_CALENDAR_SEASON_TURNS))
	var season_turn := (zero_based_turn % WORLD_CALENDAR_SEASON_TURNS) + 1
	var season_id := str(WORLD_CALENDAR_SEASON_ORDER[season_index])
	var season_label := str(WORLD_CALENDAR_SEASON_LABELS.get(season_id, season_id))
	return "%d년 %s %d턴" % [year, season_label, season_turn]


func _set_save_management_status(message: String) -> void:
	_save_management_status = message
	if _save_management_status_label != null:
		_save_management_status_label.text = message
		_save_management_status_label.visible = not message.is_empty()


func _on_ally_turn_end_pressed() -> void:
	if _enemy_turn_mvp_pending:
		_set_save_management_status("적군 턴 진행 중...")
		return
	if _has_pending_invasion_event_mvp():
		_set_save_management_status("진행 중인 침공 이벤트를 먼저 처리하십시오.")
		return
	if _normalize_turn_phase(str(_player_state.get("turn_phase", TURN_PHASE_PLAYER))) == TURN_PHASE_ENEMY:
		_set_save_management_status("이미 적군 턴입니다.")
		return
	_domestic_turn_apply_pending = true
	_player_state["domestic_apply_pending"] = true
	_set_turn_phase(TURN_PHASE_ENEMY)
	_run_enemy_turn_mvp()


func _run_enemy_turn_mvp() -> void:
	if _enemy_turn_mvp_pending:
		_set_save_management_status("적군 턴 진행 중...")
		return
	# v0.68b-12b-9: event generation only. Future patches will add choice UI and battle handoff.
	print("[WorldMap] Enemy turn MVP hook reached. Enemy invasion event generation only; AI and battle transition are deferred.")
	_enemy_turn_mvp_pending = true
	_set_save_management_status("적군 턴 진행 중...")
	var invasion_event := _roll_enemy_invasion_event_mvp()
	if not invasion_event.is_empty():
		_set_save_management_status(_format_invasion_status_text(invasion_event))
	_refresh_left_world_status_panel()
	_get_enemy_turn_mvp_timer().start(ENEMY_TURN_MVP_DELAY)


func _get_enemy_turn_mvp_timer() -> Timer:
	if _enemy_turn_mvp_timer == null:
		_enemy_turn_mvp_timer = Timer.new()
		_enemy_turn_mvp_timer.name = "EnemyTurnMvpTimer"
		_enemy_turn_mvp_timer.one_shot = true
		add_child(_enemy_turn_mvp_timer)
		_enemy_turn_mvp_timer.timeout.connect(_finish_enemy_turn_mvp)
	return _enemy_turn_mvp_timer


func _finish_enemy_turn_mvp() -> void:
	if not _enemy_turn_mvp_pending:
		return
	_enemy_turn_mvp_pending = false
	if _normalize_turn_phase(str(_player_state.get("turn_phase", TURN_PHASE_PLAYER))) != TURN_PHASE_ENEMY:
		_domestic_turn_apply_pending = false
		_player_state["domestic_apply_pending"] = false
		_refresh_left_world_status_panel()
		return
	var domestic_summary := ""
	if _domestic_turn_apply_pending:
		domestic_summary = _apply_domestic_turn_mvp()
		_domestic_turn_apply_pending = false
		_player_state["domestic_apply_pending"] = false
	_advance_world_turn_mvp()
	_set_turn_phase(TURN_PHASE_PLAYER)
	var pending_invasion_event := _get_pending_invasion_event_mvp()
	if not pending_invasion_event.is_empty():
		_set_save_management_status(_format_invasion_status_text(pending_invasion_event))
	elif domestic_summary.is_empty():
		_set_save_management_status("다음 아군 턴 시작")
	else:
		_set_save_management_status("내정 적용 완료 · %s" % domestic_summary)


func _roll_enemy_invasion_event_mvp(roll_value: float = -1.0, candidate_index: int = -1) -> Dictionary:
	_ensure_worldmap_runtime_state_defaults()
	if _has_pending_invasion_event_mvp():
		return {}
	var turn_number := maxi(1, int(_player_state.get("turn_number", 1)))
	if int(_player_state.get("enemy_invasion_roll_turn", 0)) == turn_number:
		return {}
	_player_state["enemy_invasion_roll_turn"] = turn_number
	var candidate_pairs := _get_enemy_invasion_pairs_mvp()
	if candidate_pairs.is_empty():
		print("[WorldMap] Enemy invasion MVP: no adjacent enemy/player city pairs.")
		return {}
	var roll := roll_value if roll_value >= 0.0 else randf()
	if roll >= ENEMY_INVASION_CHANCE:
		print("[WorldMap] Enemy invasion MVP: no invasion this turn. roll=%.3f" % roll)
		return {}
	var pair_index := candidate_index if candidate_index >= 0 else randi() % candidate_pairs.size()
	pair_index = clampi(pair_index, 0, candidate_pairs.size() - 1)
	var selected_pair := candidate_pairs[pair_index] as Dictionary
	return _create_pending_invasion_event_mvp(
		str(selected_pair.get("attacker_city_id", "")),
		str(selected_pair.get("defender_city_id", ""))
	)


func _get_enemy_invasion_pairs_mvp() -> Array[Dictionary]:
	var pairs: Array[Dictionary] = []
	for attacker_city_id_variant in _city_markers_by_id.keys():
		var attacker_city_id := str(attacker_city_id_variant)
		if not _is_city_owned_by_enemy_mvp(attacker_city_id):
			continue
		for defender_city_id_variant in _get_city_neighbors_mvp(attacker_city_id):
			var defender_city_id := str(defender_city_id_variant)
			if _is_city_owned_by_player_mvp(defender_city_id):
				pairs.append({
					"attacker_city_id": attacker_city_id,
					"defender_city_id": defender_city_id,
				})
	return pairs


func _is_city_owned_by_player_mvp(city_id: String) -> bool:
	var city_marker := _city_markers_by_id.get(city_id) as WorldMapCityMarker
	if city_marker != null:
		return city_marker.owner_faction_id == PLAYER_FACTION_ID
	var city_data := _get_city_hud_entry(city_id)
	return str(city_data.get("owner", city_data.get("nation", ""))) == PLAYER_FACTION_ID


func _is_city_owned_by_enemy_mvp(city_id: String) -> bool:
	var city_marker := _city_markers_by_id.get(city_id) as WorldMapCityMarker
	if city_marker != null:
		return not city_marker.owner_faction_id.is_empty() and city_marker.owner_faction_id != PLAYER_FACTION_ID
	var city_data := _get_city_hud_entry(city_id)
	var owner_id := str(city_data.get("owner", city_data.get("nation", "")))
	return not owner_id.is_empty() and owner_id != PLAYER_FACTION_ID


func _get_city_neighbors_mvp(city_id: String) -> Array[String]:
	var city_marker := _city_markers_by_id.get(city_id) as WorldMapCityMarker
	if city_marker != null:
		return city_marker.neighbors.duplicate()
	var city_data := _get_city_hud_entry(city_id)
	var neighbors: Array[String] = []
	var source_neighbors: Variant = city_data.get("neighbors", [])
	if source_neighbors is Array:
		for neighbor_id in source_neighbors:
			neighbors.append(str(neighbor_id))
	return neighbors


func _create_pending_invasion_event_mvp(attacker_city_id: String, defender_city_id: String) -> Dictionary:
	if attacker_city_id.is_empty() or defender_city_id.is_empty():
		return {}
	_clear_pending_battle_context_mvp()
	var event := {
		"type": "defense",
		"attacker_city_id": attacker_city_id,
		"defender_city_id": defender_city_id,
		"source": "enemy_invasion_mvp",
		"turn_number": maxi(1, int(_player_state.get("turn_number", 1))),
	}
	_player_state["pending_invasion_event"] = event
	_player_state["selected_city_id"] = defender_city_id
	_player_state["origin_city_id"] = defender_city_id
	if _city_markers_by_id.has(defender_city_id):
		_on_city_marker_selected(_city_markers_by_id[defender_city_id])
	print("[WorldMap] Enemy invasion MVP event created: %s -> %s" % [attacker_city_id, defender_city_id])
	return event


func _get_pending_invasion_event_mvp() -> Dictionary:
	var event: Variant = _player_state.get("pending_invasion_event", {})
	if event is Dictionary:
		return event
	return {}


func _has_pending_invasion_event_mvp() -> bool:
	return not _get_pending_invasion_event_mvp().is_empty()


func _refresh_pending_invasion_choice_ui(event: Dictionary = {}) -> void:
	if _pending_invasion_choice_card == null:
		return
	if event.is_empty():
		_pending_invasion_choice_card.visible = false
		return
	_pending_invasion_choice_card.visible = true
	if _pending_invasion_title_label != null:
		_pending_invasion_title_label.text = "적군 침공 발생"
	if _pending_invasion_detail_label != null:
		_pending_invasion_detail_label.text = _format_pending_invasion_detail(event)
	if _pending_invasion_instruction_label != null:
		_pending_invasion_instruction_label.text = _format_pending_battle_context_status_for_event(event)
	if _manual_defense_button != null:
		_manual_defense_button.text = "수동 방어"
		_manual_defense_button.disabled = false
	if _auto_defense_button != null:
		_auto_defense_button.text = "자동 방어"
		_auto_defense_button.disabled = false


func _on_manual_defense_pressed() -> void:
	_start_pending_invasion_battle_scene_handoff("manual")


func _on_auto_defense_pressed() -> void:
	_start_pending_invasion_battle_scene_handoff("auto")


func _start_pending_invasion_battle_scene_handoff(mode: String) -> void:
	var battle_context := _prepare_pending_invasion_battle_context(mode)
	if battle_context.is_empty():
		return
	_handoff_battle_context_to_battle_scene(battle_context)


func _prepare_pending_invasion_battle_context(mode: String) -> Dictionary:
	var normalized_mode := "auto" if mode == "auto" else "manual"
	var event := _get_pending_invasion_event_mvp()
	var validation := _validate_pending_invasion_event_for_battle_context(event)
	if not bool(validation.get("ok", false)):
		_clear_pending_battle_context_mvp()
		_set_save_management_status("전투 데이터 생성 실패 · %s" % str(validation.get("message", "침공 이벤트 확인 필요")))
		_refresh_left_world_status_panel()
		return {}
	var battle_context := _build_battle_context_from_pending_invasion(event, normalized_mode)
	if battle_context.is_empty():
		_clear_pending_battle_context_mvp()
		_set_save_management_status("전투 데이터 생성 실패")
		_refresh_left_world_status_panel()
		return {}
	_set_pending_battle_context_mvp(battle_context)
	if normalized_mode == "auto":
		_set_save_management_status("자동 방어 전투 데이터 준비 완료 · 자동 해결은 아직 미구현")
	else:
		_set_save_management_status("수동 방어 전투 데이터 준비 완료 · 다음 단계에서 전투 화면으로 이동")
	_refresh_left_world_status_panel()
	return battle_context


func _handoff_battle_context_to_battle_scene(battle_context: Dictionary) -> void:
	if battle_context.is_empty():
		_set_save_management_status("전투 화면 이동 실패 · 전투 데이터 없음")
		_refresh_left_world_status_panel()
		return
	if not ResourceLoader.exists(WORLDMAP_BATTLE_SCENE_PATH):
		if Engine.has_meta(WORLDMAP_BATTLE_CONTEXT_META_KEY):
			Engine.remove_meta(WORLDMAP_BATTLE_CONTEXT_META_KEY)
		_set_save_management_status("전투 화면 이동 실패 · 전투 씬 없음")
		_refresh_left_world_status_panel()
		return
	var handoff_context := battle_context.duplicate(true)
	Engine.set_meta(WORLDMAP_BATTLE_CONTEXT_META_KEY, handoff_context)
	_set_save_management_status("전투 화면 이동 중 · %s → %s" % [
		str(handoff_context.get("attacker_city_name", "알 수 없는 적 도시")),
		str(handoff_context.get("defender_city_name", "알 수 없는 아군 도시")),
	])
	var transition_result := get_tree().change_scene_to_file(WORLDMAP_BATTLE_SCENE_PATH)
	if transition_result != OK:
		if Engine.has_meta(WORLDMAP_BATTLE_CONTEXT_META_KEY):
			Engine.remove_meta(WORLDMAP_BATTLE_CONTEXT_META_KEY)
		_set_save_management_status("전투 화면 이동 실패")
		_refresh_left_world_status_panel()


func _consume_worldmap_battle_result_if_any() -> void:
	if not Engine.has_meta(WORLDMAP_BATTLE_RESULT_META_KEY):
		return
	var result_payload: Variant = Engine.get_meta(WORLDMAP_BATTLE_RESULT_META_KEY)
	Engine.remove_meta(WORLDMAP_BATTLE_RESULT_META_KEY)
	if not result_payload is Dictionary:
		_set_save_management_status("전투 결과 수신 실패")
		return
	var result := (result_payload as Dictionary).duplicate(true)
	if result.is_empty():
		_set_save_management_status("전투 결과 수신 실패")
		return
	_apply_returned_battle_result_mvp(result)


func _apply_returned_battle_result_mvp(result: Dictionary) -> void:
	_apply_invasion_battle_result(result)


func _apply_invasion_battle_result(result_payload: Dictionary) -> void:
	var result_kind := _normalize_invasion_battle_result_kind(result_payload)
	var defender_city_id := _get_invasion_result_city_id(result_payload, ["defender_city_id", "target_city_id", "city_id"])
	var attacker_city_id := _get_invasion_result_city_id(result_payload, ["attacker_city_id", "source_city_id", "origin_city_id"])
	var defender_city_name := str(result_payload.get("defender_city_name", _format_city_name_by_id(defender_city_id, "알 수 없는 아군 도시")))
	var attacker_city_name := str(result_payload.get("attacker_city_name", _format_city_name_by_id(attacker_city_id, "알 수 없는 적 도시")))
	var status_message := ""
	if not _is_enemy_invasion_battle_result(result_payload):
		status_message = "전투 결과 수신 완료: 침공전 결과가 아니므로 점령 적용 없이 정리했습니다."
	elif defender_city_id.is_empty() or not _has_city_for_battle_context(defender_city_id):
		status_message = "전투 결과 적용 실패: 방어 도시 정보를 찾을 수 없어 점령 적용 없이 정리했습니다."
	else:
		match result_kind:
			INVASION_RESULT_DEFENDER_WIN:
				status_message = _apply_defender_win_invasion_result(defender_city_id, attacker_city_id, defender_city_name, attacker_city_name, result_payload)
			INVASION_RESULT_ATTACKER_WIN:
				status_message = _apply_attacker_win_invasion_result(defender_city_id, attacker_city_id, defender_city_name, attacker_city_name, result_payload)
			INVASION_RESULT_RETREAT:
				status_message = "침공 중단: %s 방어전이 취소/퇴각 처리되었습니다. · 소유권 변경 없음" % defender_city_name
			_:
				status_message = "전투 결과 확인 필요: %s 방어전 결과를 해석할 수 없어 소유권 변경 없이 정리했습니다." % defender_city_name

	_clear_pending_invasion_event_mvp()
	if not defender_city_id.is_empty():
		_select_city_after_invasion_result(defender_city_id)
	_refresh_pending_invasion_choice_ui({})
	city_info_panel.set_pending_invasion_event({})
	_refresh_left_world_status_panel()
	_refresh_unified_panel_content()
	_set_save_management_status(status_message)
	print("[WorldMap] Invasion battle result applied: %s / payload=%s" % [status_message, str(result_payload)])


func _format_battle_result_status(result: Dictionary) -> String:
	var defender_city_name := str(result.get("defender_city_name", "알 수 없는 아군 도시"))
	var attacker_city_name := str(result.get("attacker_city_name", "알 수 없는 적 도시"))
	var battle_result := str(result.get("result", ""))
	var winner := str(result.get("winner", ""))
	if battle_result == "victory" or winner == "defender":
		return "방어 성공: %s을 지켜냈습니다." % defender_city_name
	if battle_result == "defeat" or winner == "attacker":
		return "방어 실패: %s이 함락되었습니다." % defender_city_name
	return "전투 결과 수신 완료: %s → %s" % [attacker_city_name, defender_city_name]


func _is_enemy_invasion_battle_result(result_payload: Dictionary) -> bool:
	var source := str(result_payload.get("source", "")).to_lower()
	var result_type := str(result_payload.get("type", "")).to_lower()
	return source == "enemy_invasion" or result_type.begins_with("defense")


func _normalize_invasion_battle_result_kind(result_payload: Dictionary) -> String:
	if result_payload.has("is_player_win") and result_payload.get("is_player_win") is bool:
		return INVASION_RESULT_DEFENDER_WIN if bool(result_payload.get("is_player_win")) else INVASION_RESULT_ATTACKER_WIN
	var result_tokens: Array[String] = []
	for key in ["result", "battle_result", "outcome", "state"]:
		if result_payload.has(key):
			result_tokens.append(str(result_payload.get(key, "")).to_lower())
	for token in result_tokens:
		if ["player_win", "defender_win", "victory", "win"].has(token):
			return INVASION_RESULT_DEFENDER_WIN
		if ["player_loss", "attacker_win", "defeat", "lose", "loss"].has(token):
			return INVASION_RESULT_ATTACKER_WIN
		if ["retreat", "cancel", "cancelled", "canceled", "aborted"].has(token):
			return INVASION_RESULT_RETREAT
	var winner := str(result_payload.get("winner", "")).to_lower()
	if ["defender", "player", "ally"].has(winner):
		return INVASION_RESULT_DEFENDER_WIN
	if ["attacker", "enemy"].has(winner):
		return INVASION_RESULT_ATTACKER_WIN
	return INVASION_RESULT_UNKNOWN


func _get_invasion_result_city_id(result_payload: Dictionary, keys: Array[String]) -> String:
	for key in keys:
		var city_id := str(result_payload.get(key, ""))
		if not city_id.is_empty():
			return city_id
	return ""


func _apply_defender_win_invasion_result(defender_city_id: String, attacker_city_id: String, defender_city_name: String, attacker_city_name: String, result_payload: Dictionary) -> String:
	var defender_before := _get_city_troops_for_battle_context(defender_city_id)
	var defender_after := _get_result_troop_value(result_payload, ["defender_surviving_troops", "defender_remaining_troops", "player_surviving_troops"], -1)
	if defender_after < 0 and defender_before > 0:
		defender_after = int(round(float(defender_before) * INVASION_RESULT_DEFENDER_WIN_DEFENDER_TROOP_RATE))
	if defender_after >= 0:
		_set_city_runtime_troops(defender_city_id, clampi(defender_after, 0, defender_before if defender_before > 0 else defender_after))
	var attacker_before := _get_city_troops_for_battle_context(attacker_city_id)
	var attacker_after := _get_result_troop_value(result_payload, ["attacker_surviving_troops", "attacker_remaining_troops", "enemy_surviving_troops"], -1)
	if attacker_after < 0 and attacker_before > 0:
		attacker_after = int(round(float(attacker_before) * INVASION_RESULT_DEFENDER_WIN_ATTACKER_TROOP_RATE))
	if not attacker_city_id.is_empty() and _has_city_for_battle_context(attacker_city_id) and attacker_after >= 0:
		_set_city_runtime_troops(attacker_city_id, clampi(attacker_after, 0, attacker_before if attacker_before > 0 else attacker_after))
	return "방어 성공: %s을 지켜냈습니다. · %s 병력 %d→%d · %s 병력 %d→%d" % [
		defender_city_name,
		defender_city_name,
		defender_before,
		_get_city_troops_for_battle_context(defender_city_id),
		attacker_city_name,
		attacker_before,
		_get_city_troops_for_battle_context(attacker_city_id),
	]


func _apply_attacker_win_invasion_result(defender_city_id: String, attacker_city_id: String, defender_city_name: String, attacker_city_name: String, result_payload: Dictionary) -> String:
	var attacker_owner := str(result_payload.get("attacker_owner", _get_city_owner_id_for_battle_context(attacker_city_id)))
	var defender_before_troops := _get_city_troops_for_battle_context(defender_city_id)
	if attacker_owner.is_empty():
		return "방어 실패: %s이 함락되었으나 공격 세력 정보가 없어 소유권 변경 없이 정리했습니다." % defender_city_name
	_set_city_runtime_owner(defender_city_id, attacker_owner)
	var occupation_troops := _get_result_troop_value(result_payload, ["attacker_surviving_troops", "attacker_remaining_troops", "enemy_surviving_troops"], -1)
	if occupation_troops <= 0:
		occupation_troops = _get_result_troop_value(result_payload, ["attacker_troops", "enemy_troops"], -1)
		if occupation_troops > 0:
			occupation_troops = maxi(1, int(round(float(occupation_troops) * 0.5)))
	if occupation_troops <= 0:
		occupation_troops = INVASION_RESULT_DEFAULT_OCCUPATION_TROOPS
	_set_city_runtime_troops(defender_city_id, maxi(0, occupation_troops))
	return "도시 함락: %s이 %s에 점령되었습니다. · %s 잔존 병력 %d→%d" % [
		defender_city_name,
		_format_faction_label(attacker_owner),
		defender_city_name,
		defender_before_troops,
		_get_city_troops_for_battle_context(defender_city_id),
	]


func _get_result_troop_value(result_payload: Dictionary, keys: Array[String], fallback: int) -> int:
	for key in keys:
		if result_payload.has(key):
			return maxi(0, int(result_payload.get(key, fallback)))
	return fallback


func _set_city_runtime_owner(city_id: String, owner_id: String) -> void:
	if city_id.is_empty() or owner_id.is_empty():
		return
	var city_data := _get_city_hud_entry(city_id)
	if not city_data.is_empty():
		city_data["owner"] = owner_id
		city_data["nation"] = owner_id
	var city_marker := _city_markers_by_id.get(city_id) as WorldMapCityMarker
	if city_marker != null:
		city_marker.owner_faction_id = owner_id
		city_marker._refresh_marker_visuals()
	_update_owned_city_ids_after_runtime_owner_change(city_id, owner_id)


func _set_city_runtime_troops(city_id: String, troops: int) -> void:
	if city_id.is_empty():
		return
	var city_data := _get_city_hud_entry(city_id)
	if city_data.is_empty():
		return
	city_data["troops"] = maxi(0, troops)


func _update_owned_city_ids_after_runtime_owner_change(city_id: String, owner_id: String) -> void:
	var owned_city_ids: Array = []
	var current_city_ids: Variant = _player_state.get("owned_city_ids", [])
	if current_city_ids is Array:
		for owned_city_id in current_city_ids:
			var owned_id := str(owned_city_id)
			if owned_id != city_id and not owned_city_ids.has(owned_id):
				owned_city_ids.append(owned_id)
	if owner_id == PLAYER_FACTION_ID and not owned_city_ids.has(city_id):
		owned_city_ids.append(city_id)
	_player_state["owned_city_ids"] = owned_city_ids


func _select_city_after_invasion_result(city_id: String) -> void:
	_player_state["selected_city_id"] = city_id
	var city_marker := _city_markers_by_id.get(city_id) as WorldMapCityMarker
	if city_marker == null:
		return
	if selected_city_marker != null and selected_city_marker != city_marker:
		selected_city_marker.set_selected(false)
	selected_city_id = city_id
	selected_city_marker = city_marker
	selected_city_marker.set_selected(true)
	city_info_panel.show_city(city_marker)


func _validate_pending_invasion_event_for_battle_context(event: Dictionary) -> Dictionary:
	if event.is_empty():
		return {"ok": false, "message": "진행 중인 침공 이벤트가 없습니다."}
	if str(event.get("type", "")) != "defense":
		return {"ok": false, "message": "방어전 이벤트가 아닙니다."}
	var attacker_city_id := str(event.get("attacker_city_id", ""))
	var defender_city_id := str(event.get("defender_city_id", ""))
	if not _has_city_for_battle_context(attacker_city_id):
		return {"ok": false, "message": "침공 도시 정보를 찾을 수 없습니다."}
	if not _has_city_for_battle_context(defender_city_id):
		return {"ok": false, "message": "방어 도시 정보를 찾을 수 없습니다."}
	if not _is_city_owned_by_enemy_mvp(attacker_city_id):
		return {"ok": false, "message": "침공 도시가 적 소유가 아닙니다."}
	if not _is_city_owned_by_player_mvp(defender_city_id):
		return {"ok": false, "message": "방어 도시가 아군 소유가 아닙니다."}
	return {"ok": true, "message": ""}


func _build_battle_context_from_pending_invasion(event: Dictionary, mode: String) -> Dictionary:
	var attacker_city_id := str(event.get("attacker_city_id", ""))
	var defender_city_id := str(event.get("defender_city_id", ""))
	return {
		"type": "defense",
		"source": "enemy_invasion",
		"mode": "auto" if mode == "auto" else "manual",
		"attacker_city_id": attacker_city_id,
		"defender_city_id": defender_city_id,
		"attacker_city_name": _format_city_name_by_id(attacker_city_id, "알 수 없는 적 도시"),
		"defender_city_name": _format_city_name_by_id(defender_city_id, "알 수 없는 아군 도시"),
		"turn_number": maxi(1, int(_player_state.get("turn_number", 1))),
		"event_turn_number": int(event.get("turn_number", _player_state.get("turn_number", 1))),
		"attacker_owner": _get_city_owner_id_for_battle_context(attacker_city_id),
		"defender_owner": _get_city_owner_id_for_battle_context(defender_city_id),
		"attacker_troops": _get_city_troops_for_battle_context(attacker_city_id),
		"defender_troops": _get_city_troops_for_battle_context(defender_city_id),
		"attacker_hero_ids": _get_city_stationed_hero_ids_for_battle_context(attacker_city_id),
		"defender_hero_ids": _get_city_stationed_hero_ids_for_battle_context(defender_city_id),
		"attacker_governor_id": _get_city_governor_id_for_battle_context(attacker_city_id),
		"defender_governor_id": _get_city_governor_id_for_battle_context(defender_city_id),
	}


func _has_city_for_battle_context(city_id: String) -> bool:
	if city_id.is_empty():
		return false
	return _city_markers_by_id.has(city_id) or not _get_city_hud_entry(city_id).is_empty()


func _get_city_owner_id_for_battle_context(city_id: String) -> String:
	var city_marker := _city_markers_by_id.get(city_id) as WorldMapCityMarker
	if city_marker != null and not city_marker.owner_faction_id.is_empty():
		return city_marker.owner_faction_id
	var city_data := _get_city_hud_entry(city_id)
	return str(city_data.get("owner", city_data.get("nation", "")))


func _get_city_troops_for_battle_context(city_id: String) -> int:
	var city_data := _get_city_hud_entry(city_id)
	return maxi(0, int(city_data.get("troops", 0)))


func _get_city_stationed_hero_ids_for_battle_context(city_id: String) -> Array:
	var hero_ids: Array = []
	for hero_id in _get_stationed_hero_ids_for_city(_get_city_hud_entry(city_id)):
		hero_ids.append(str(hero_id))
	return hero_ids


func _get_city_governor_id_for_battle_context(city_id: String) -> String:
	return str(_get_city_hud_entry(city_id).get("governor_id", ""))


func _set_pending_battle_context_mvp(battle_context: Dictionary) -> void:
	_player_state["pending_battle_context"] = battle_context.duplicate(true)


func _get_pending_battle_context_mvp() -> Dictionary:
	var battle_context: Variant = _player_state.get("pending_battle_context", {})
	if battle_context is Dictionary:
		return battle_context
	return {}


func _clear_pending_battle_context_mvp() -> void:
	_player_state["pending_battle_context"] = {}


func _format_pending_battle_context_status_for_event(event: Dictionary) -> String:
	var battle_context := _get_pending_battle_context_mvp()
	if event.is_empty() or battle_context.is_empty():
		return "방어전을 준비하십시오."
	if str(battle_context.get("source", "")) != "enemy_invasion":
		return "방어전을 준비하십시오."
	if str(battle_context.get("attacker_city_id", "")) != str(event.get("attacker_city_id", "")):
		return "방어전을 준비하십시오."
	if str(battle_context.get("defender_city_id", "")) != str(event.get("defender_city_id", "")):
		return "방어전을 준비하십시오."
	if str(battle_context.get("mode", "")) == "auto":
		return "자동 방어 전투 데이터 준비 완료 · 자동 해결은 아직 미구현"
	return "수동 방어 전투 데이터 준비 완료 · 다음 단계에서 전투 화면으로 이동"


func _clear_pending_invasion_event_mvp() -> void:
	_player_state["pending_invasion_event"] = {}
	_clear_pending_battle_context_mvp()
	_player_state["enemy_invasion_roll_turn"] = 0


func _format_pending_invasion_detail(event: Dictionary) -> String:
	if event.is_empty():
		return ""
	var attacker_city_name := _format_city_name_by_id(str(event.get("attacker_city_id", "")), "알 수 없는 적 도시")
	var defender_city_name := _format_city_name_by_id(str(event.get("defender_city_id", "")), "알 수 없는 아군 도시")
	return "침공 도시: %s\n방어 도시: %s\n%s → %s" % [
		attacker_city_name,
		defender_city_name,
		attacker_city_name,
		defender_city_name,
	]


func _format_invasion_status_text(event: Dictionary) -> String:
	if event.is_empty():
		return ""
	var attacker_city_name := _format_city_name_by_id(str(event.get("attacker_city_id", "")), "알 수 없는 적 도시")
	var defender_city_name := _format_city_name_by_id(str(event.get("defender_city_id", "")), "알 수 없는 아군 도시")
	return "적군 침공 발생: %s → %s · 방어전 준비 필요" % [attacker_city_name, defender_city_name]


func _advance_world_turn_mvp() -> void:
	var next_turn := maxi(1, int(_player_state.get("turn_number", 1))) + 1
	_player_state["turn_number"] = next_turn
	_update_world_turn_labels()


func _apply_domestic_turn_mvp() -> String:
	# v0.68b-12b-6: port the web domestic income/tax/policy MVP once per completed player turn.
	var turn_number := maxi(1, int(_player_state.get("turn_number", 1)))
	if int(_player_state.get("last_domestic_apply_turn", 0)) == turn_number:
		return "내정 이미 적용됨"
	var tax_level := _normalize_tax_level(_player_state.get("tax_level", 30))
	var policy_id := _normalize_chancellor_policy_id(str(_player_state.get("chancellor_policy_id", "balanced")))
	var national_effects := _calculate_active_chancellor_national_effects()
	var income_delta := _calculate_player_domestic_income_delta(turn_number, tax_level, policy_id, national_effects)
	var upkeep_delta := _calculate_player_hero_upkeep_delta(policy_id, national_effects)
	var combined_delta := _combine_resource_deltas(income_delta, upkeep_delta)
	var applied_delta := _apply_resource_delta(combined_delta)
	var base_loyalty_delta := _get_tax_loyalty_delta(tax_level)
	var loyalty_delta := _adjust_loyalty_delta(base_loyalty_delta, float(national_effects.get("national_loyalty_loss_multiplier", 1.0)))
	var before_loyalty := clampi(int(_player_state.get("national_loyalty", 75)), 0, 100)
	var after_loyalty := clampi(before_loyalty + loyalty_delta, 0, 100)
	var applied_loyalty_delta := after_loyalty - before_loyalty
	_player_state["national_loyalty"] = after_loyalty
	_player_state["last_domestic_apply_turn"] = turn_number
	_player_state["resources"] = _format_player_resource_summary()
	_player_state["income"] = _format_domestic_apply_summary(applied_delta, applied_loyalty_delta)
	_player_state["tax_effect"] = _format_tax_effect_text(tax_level)
	_player_state["last_domestic_apply_result"] = {
		"version": "v0.68b-12b-7",
		"turn_number": turn_number,
		"tax_level": tax_level,
		"chancellor_policy_id": policy_id,
		"income_delta": income_delta,
		"upkeep_delta": upkeep_delta,
		"resource_delta": applied_delta,
		"loyalty_delta": applied_loyalty_delta,
		"national_effects": national_effects,
	}
	return _format_domestic_apply_summary(applied_delta, applied_loyalty_delta)


func _get_world_calendar_for_turn(turn_number: int) -> Dictionary:
	var safe_turn := maxi(1, turn_number)
	var zero_based_turn := safe_turn - 1
	var season_index := floori(float(zero_based_turn % WORLD_CALENDAR_YEAR_TURNS) / float(WORLD_CALENDAR_SEASON_TURNS))
	var season_id := str(WORLD_CALENDAR_SEASON_ORDER[season_index])
	return {
		"turn": safe_turn,
		"season": season_id,
		"season_label": str(WORLD_CALENDAR_SEASON_LABELS.get(season_id, season_id)),
	}


func _create_empty_domestic_income_totals() -> Dictionary:
	return {"rice": 0, "barley": 0, "seafood": 0, "gold": 0}


func _calculate_player_domestic_income_delta(turn_number: int, tax_level: int, policy_id: String, national_effects: Dictionary) -> Dictionary:
	var calendar := _get_world_calendar_for_turn(turn_number)
	var totals := _create_empty_domestic_income_totals()
	var owned_city_ids: Variant = _player_state.get("owned_city_ids", [])
	if not owned_city_ids is Array:
		return totals
	for city_id in owned_city_ids:
		var city_data := _get_city_hud_entry(str(city_id))
		if city_data.is_empty():
			continue
		var city_income := _calculate_city_domestic_income(city_data, calendar, tax_level)
		for resource_id in totals.keys():
			totals[resource_id] = int(totals.get(resource_id, 0)) + int(city_income.get(resource_id, 0))
	var policy_totals := _apply_chancellor_policy_to_income_totals(totals, policy_id)
	return _apply_income_multipliers_to_totals(policy_totals, national_effects)


func _calculate_city_domestic_income(city_data: Dictionary, calendar: Dictionary, tax_level: int) -> Dictionary:
	var resource_seed: Dictionary = city_data.get("resource_seed", {})
	var income := _create_empty_domestic_income_totals()
	income["seafood"] = _get_rating(resource_seed, "seafood") * int(DOMESTIC_INCOME_RULES.get("seafood_per_rating_per_turn", 2))
	if str(calendar.get("season", "")) == "spring":
		income["barley"] = _get_rating(resource_seed, "barley") * int(DOMESTIC_INCOME_RULES.get("barley_per_rating_in_spring", 5))
	if str(calendar.get("season", "")) == "autumn":
		income["rice"] = _get_rating(resource_seed, "rice") * int(DOMESTIC_INCOME_RULES.get("rice_per_rating_in_autumn", 5))
	income["gold"] = _calculate_city_gold_tax_income(city_data, tax_level)
	return income


func _calculate_city_gold_tax_income(city_data: Dictionary, tax_level: int) -> int:
	var population_tax_points := _get_city_numeric_rating(city_data, "population_rating", 3) * POPULATION_TAX_POINT_PER_RATING
	var commerce_tax_points := _get_city_numeric_rating(city_data, "commerce_rating", 0) * COMMERCE_TAX_POINT_PER_RATING
	var taxable_value := (population_tax_points + commerce_tax_points) * TAX_POINT_TO_GOLD
	return maxi(0, int(round(float(taxable_value) * _get_tax_gold_multiplier(tax_level))))


func _get_rating(source: Dictionary, key: String) -> int:
	return maxi(0, int(source.get(key, 0)))


func _get_city_numeric_rating(city_data: Dictionary, key: String, fallback: int) -> int:
	return clampi(int(city_data.get(key, fallback)), 1, 5)


func _apply_chancellor_policy_to_income_totals(totals: Dictionary, policy_id: String) -> Dictionary:
	var policy_data: Dictionary = CHANCELLOR_POLICY_DATA.get(_normalize_chancellor_policy_id(policy_id), CHANCELLOR_POLICY_DATA.get("balanced", {}))
	var income_multiplier := float(policy_data.get("income_multiplier", 1.0))
	return {
		"rice": maxi(0, int(round(float(totals.get("rice", 0)) * income_multiplier * float(policy_data.get("rice_multiplier", 1.0))))),
		"barley": maxi(0, int(round(float(totals.get("barley", 0)) * income_multiplier * float(policy_data.get("barley_multiplier", 1.0))))),
		"seafood": maxi(0, int(round(float(totals.get("seafood", 0)) * income_multiplier * float(policy_data.get("seafood_multiplier", 1.0))))),
		"gold": maxi(0, int(round(float(totals.get("gold", 0)) * income_multiplier * float(policy_data.get("gold_multiplier", 1.0))))),
	}


func _calculate_active_chancellor_national_effects() -> Dictionary:
	var effect := {
		"rice_multiplier": 1.0,
		"barley_multiplier": 1.0,
		"seafood_multiplier": 1.0,
		"gold_multiplier": 1.0,
		"hero_upkeep_multiplier": 1.0,
		"soldier_upkeep_preview_multiplier": 1.0,
		"salt_preservation_multiplier": 1.0,
		"national_loyalty_loss_multiplier": 1.0,
	}
	var chancellor_id := str(_player_state.get("chancellor_id", ""))
	if chancellor_id.is_empty():
		return effect
	var hero_data := _get_hero_entry(chancellor_id)
	if hero_data.is_empty() or str(hero_data.get("side", "")) != PLAYER_FACTION_ID:
		return effect
	_apply_chancellor_type_effect(effect, str(hero_data.get("chancellor_primary_type", "")), float(hero_data.get("chancellor_primary_aptitude", 0)), CHANCELLOR_PRIMARY_RATE)
	_apply_chancellor_type_effect(effect, str(hero_data.get("chancellor_secondary_type", "")), float(hero_data.get("chancellor_secondary_aptitude", 0)), CHANCELLOR_SECONDARY_RATE)
	return effect


func _apply_chancellor_type_effect(effect: Dictionary, type_id: String, aptitude: float, rate: float) -> void:
	var strength := maxf(0.0, aptitude) * rate
	if type_id.is_empty() or strength <= 0.0:
		return
	match type_id:
		"political":
			effect["national_loyalty_loss_multiplier"] = clampf(float(effect.get("national_loyalty_loss_multiplier", 1.0)) * (1.0 - strength), 0.7, 1.0)
		"economic":
			effect["gold_multiplier"] = clampf(float(effect.get("gold_multiplier", 1.0)) * (1.0 + strength), 1.0, 1.22)
		"administrative":
			effect["hero_upkeep_multiplier"] = clampf(float(effect.get("hero_upkeep_multiplier", 1.0)) * (1.0 - (strength * 0.45)), 0.82, 1.0)
			effect["salt_preservation_multiplier"] = clampf(float(effect.get("salt_preservation_multiplier", 1.0)) * (1.0 - (strength * 0.45)), 0.82, 1.0)
		"diplomatic":
			effect["gold_multiplier"] = clampf(float(effect.get("gold_multiplier", 1.0)) * (1.0 + (strength * 0.55)), 1.0, 1.12)
		"militaryAdmin":
			effect["soldier_upkeep_preview_multiplier"] = clampf(float(effect.get("soldier_upkeep_preview_multiplier", 1.0)) * (1.0 - (strength * 0.55)), 0.82, 1.0)


func _apply_income_multipliers_to_totals(totals: Dictionary, effect: Dictionary) -> Dictionary:
	return {
		"rice": maxi(0, int(round(float(totals.get("rice", 0)) * float(effect.get("rice_multiplier", 1.0))))),
		"barley": maxi(0, int(round(float(totals.get("barley", 0)) * float(effect.get("barley_multiplier", 1.0))))),
		"seafood": maxi(0, int(round(float(totals.get("seafood", 0)) * float(effect.get("seafood_multiplier", 1.0))))),
		"gold": maxi(0, int(round(float(totals.get("gold", 0)) * float(effect.get("gold_multiplier", 1.0))))),
	}


func _calculate_player_hero_upkeep_delta(policy_id: String, national_effects: Dictionary) -> Dictionary:
	var owned_hero_ids: Variant = _player_state.get("owned_hero_ids", [])
	if not owned_hero_ids is Array:
		return {}
	var active_count := 0
	for hero_id in owned_hero_ids:
		var hero_data := _get_hero_entry(str(hero_id))
		if hero_data.is_empty() or str(hero_data.get("side", "")) != PLAYER_FACTION_ID:
			continue
		if hero_data.get("active", true) == false or hero_data.get("isDead", false) == true or hero_data.get("dead", false) == true:
			continue
		active_count += 1
	var policy_data: Dictionary = CHANCELLOR_POLICY_DATA.get(_normalize_chancellor_policy_id(policy_id), CHANCELLOR_POLICY_DATA.get("balanced", {}))
	var upkeep_multiplier := float(policy_data.get("hero_upkeep_multiplier", 1.0)) * float(national_effects.get("hero_upkeep_multiplier", 1.0))
	var delta := {}
	for resource_id in HERO_UPKEEP_RULES.keys():
		var base_cost := active_count * int(HERO_UPKEEP_RULES.get(resource_id, 0))
		var adjusted_cost := _round_discounted_amount(base_cost, upkeep_multiplier)
		if adjusted_cost > 0:
			delta[str(resource_id)] = -adjusted_cost
	return delta


func _round_discounted_amount(amount: int, multiplier: float) -> int:
	var adjusted_amount := float(amount) * multiplier
	if multiplier < 1.0 and adjusted_amount < float(amount):
		return maxi(0, int(floor(adjusted_amount)))
	return maxi(0, int(round(adjusted_amount)))


func _combine_resource_deltas(first: Dictionary, second: Dictionary) -> Dictionary:
	var combined := {}
	for resource_id in RESOURCE_DISPLAY_ORDER:
		combined[resource_id] = int(first.get(resource_id, 0)) + int(second.get(resource_id, 0))
	return combined


func _apply_resource_delta(delta: Dictionary) -> Dictionary:
	var resource_stock: Dictionary = _player_state.get("resource_stock", {}).duplicate(true)
	var applied_delta := {}
	for resource_id in RESOURCE_DISPLAY_ORDER:
		var resource_key := str(resource_id)
		var before := int(resource_stock.get(resource_key, 0))
		var capacity := int(WAREHOUSE_CAPACITY.get(resource_key, 0))
		var after := before + int(delta.get(resource_key, 0))
		after = clampi(after, 0, capacity) if capacity > 0 else maxi(0, after)
		resource_stock[resource_key] = after
		applied_delta[resource_key] = after - before
	_player_state["resource_stock"] = resource_stock
	return applied_delta


func _adjust_loyalty_delta(base_delta: int, loss_multiplier: float) -> int:
	if base_delta >= 0:
		return base_delta
	return mini(-1, int(ceil(float(base_delta) * loss_multiplier)))


func _format_domestic_apply_summary(resource_delta: Dictionary, loyalty_delta: int) -> String:
	var parts: Array[String] = []
	for resource_id in RESOURCE_DISPLAY_ORDER:
		var delta := int(resource_delta.get(resource_id, 0))
		if delta == 0:
			continue
		parts.append("%s %s" % [str(RESOURCE_LABELS.get(resource_id, resource_id)), _format_signed_int(delta)])
	if loyalty_delta != 0:
		parts.append("충성도 %s" % _format_signed_int(loyalty_delta))
	if parts.is_empty():
		return "변동 없음"
	return " · ".join(parts)


func _cancel_enemy_turn_timer_if_needed() -> void:
	_enemy_turn_mvp_pending = false
	_domestic_turn_apply_pending = false
	_player_state["domestic_apply_pending"] = false
	if _enemy_turn_mvp_timer != null and not _enemy_turn_mvp_timer.is_stopped():
		_enemy_turn_mvp_timer.stop()


func _get_default_player_state() -> Dictionary:
	return _default_player_state.duplicate(true)


func _serialize_worldmap_state() -> Dictionary:
	_ensure_worldmap_runtime_state_defaults()
	var saved_player_state := _player_state.duplicate(true)
	saved_player_state["pending_invasion_event"] = {}
	saved_player_state["pending_battle_context"] = {}
	saved_player_state["enemy_invasion_roll_turn"] = 0
	return {
		"version": "v0.68b-12b-11",
		"title": "WorldMap Enemy Invasion BattleContext Bridge",
		"player_state": saved_player_state,
	}


func _apply_worldmap_state(data: Dictionary) -> bool:
	var restored_state: Variant = data.get("player_state", {})
	if not restored_state is Dictionary:
		return false
	var next_state := _get_default_player_state()
	for key in restored_state.keys():
		next_state[key] = restored_state[key]
	_player_state = next_state
	_ensure_worldmap_runtime_state_defaults()
	_clear_pending_invasion_event_mvp()
	_domestic_turn_apply_pending = bool(_player_state.get("domestic_apply_pending", false))
	if _normalize_turn_phase(str(_player_state.get("turn_phase", TURN_PHASE_PLAYER))) == TURN_PHASE_ENEMY:
		_player_state["turn_phase"] = TURN_PHASE_PLAYER
		_player_state["current_phase_label"] = _get_turn_phase_label(TURN_PHASE_PLAYER)
	_domestic_turn_apply_pending = false
	_player_state["domestic_apply_pending"] = false
	return true


func _save_worldmap_state() -> void:
	var save_data := _serialize_worldmap_state()
	var file := FileAccess.open(WORLDMAP_SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("[WorldMap] Failed to open worldmap save path: %s" % WORLDMAP_SAVE_PATH)
		_set_save_management_status("저장 실패")
		return
	file.store_string(JSON.stringify(save_data, "\t"))
	_set_save_management_status("저장 완료")


func _load_worldmap_state() -> void:
	if not FileAccess.file_exists(WORLDMAP_SAVE_PATH):
		_set_save_management_status("저장 데이터 없음")
		return
	_cancel_enemy_turn_timer_if_needed()
	var file := FileAccess.open(WORLDMAP_SAVE_PATH, FileAccess.READ)
	if file == null:
		_set_save_management_status("불러오기 실패")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary or not _apply_worldmap_state(parsed):
		_set_save_management_status("불러오기 실패")
		return
	_refresh_left_world_status_panel()
	_refresh_unified_panel_content()
	_set_save_management_status("불러오기 완료")
	if _normalize_turn_phase(str(_player_state.get("turn_phase", TURN_PHASE_PLAYER))) == TURN_PHASE_ENEMY:
		_run_enemy_turn_mvp()


func _reset_worldmap_state() -> void:
	_cancel_enemy_turn_timer_if_needed()
	_player_state = _get_default_player_state()
	_ensure_worldmap_runtime_state_defaults()
	_clear_pending_invasion_event_mvp()
	_refresh_left_world_status_panel()
	_refresh_unified_panel_content()
	_set_save_management_status("초기화 완료")


func _get_city_hud_entry(city_id: String) -> Dictionary:
	return CITY_HUD_DATA.get(city_id, {})


func _get_hero_entry(hero_id: String) -> Dictionary:
	return HERO_DATA.get(hero_id, {})


func _format_city_name_by_id(city_id: String, empty_fallback: String) -> String:
	if city_id.is_empty():
		return empty_fallback
	var city_data := _get_city_hud_entry(city_id)
	if city_data.is_empty():
		return "알 수 없는 도시"
	return str(city_data.get("name", empty_fallback))


func _format_hero_name_by_id(hero_id: String, empty_fallback: String) -> String:
	if hero_id.is_empty():
		return empty_fallback
	var hero_data := _get_hero_entry(hero_id)
	if hero_data.is_empty():
		return "알 수 없는 장수"
	return str(hero_data.get("display_name", hero_data.get("name", empty_fallback)))


func _format_city_list(city_ids: Variant, empty_fallback: String) -> String:
	if not city_ids is Array:
		return empty_fallback
	var names: Array[String] = []
	for city_id in city_ids:
		names.append(_format_city_name_by_id(str(city_id), "알 수 없는 도시"))
	if names.is_empty():
		return empty_fallback
	return ", ".join(names)


func _format_hero_list(hero_ids: Variant, empty_fallback: String) -> String:
	if not hero_ids is Array:
		return empty_fallback
	var names: Array[String] = []
	for hero_id in hero_ids:
		names.append(_format_hero_name_by_id(str(hero_id), "알 수 없는 장수"))
	if names.is_empty():
		return empty_fallback
	return ", ".join(names)


func _format_player_resource_summary() -> String:
	var resource_stock: Dictionary = _player_state.get("resource_stock", {})
	if resource_stock.is_empty():
		return str(_player_state.get("resources", "보유 자원 없음"))
	var parts: Array[String] = []
	for resource_id in ["rice", "barley", "seafood", "wood", "iron", "horses", "silk", "salt", "gold"]:
		parts.append("%s %d" % [
			str(RESOURCE_LABELS.get(resource_id, resource_id)),
			int(resource_stock.get(resource_id, 0)),
		])
	return " / ".join(parts)


func _get_player_resource_amount(resource_id: String) -> int:
	var resource_stock: Dictionary = _player_state.get("resource_stock", {})
	return int(resource_stock.get(resource_id, 0))


func _refresh_warehouse_card() -> void:
	if _warehouse_card == null:
		return
	_warehouse_card.visible = true
	var resource_stock: Dictionary = _player_state.get("resource_stock", {})
	for resource_id in RESOURCE_DISPLAY_ORDER:
		var resource_id_string := str(resource_id)
		var row_labels: Dictionary = _warehouse_resource_row_labels.get(resource_id_string, {})
		if row_labels.is_empty():
			continue
		var value := int(resource_stock.get(resource_id_string, 0))
		var capacity := int(WAREHOUSE_CAPACITY.get(resource_id_string, 0))
		var status := _get_resource_status_label(resource_id_string, value, capacity)
		var amount_label := row_labels.get("amount") as Label
		var status_label := row_labels.get("status") as Label
		if amount_label != null:
			amount_label.text = "%d / %d" % [value, capacity]
		if status_label != null:
			status_label.text = status
			status_label.add_theme_color_override("font_color", _get_resource_status_color(status))


func _format_warehouse_summary(_policy_id: String) -> String:
	var resource_stock: Dictionary = _player_state.get("resource_stock", {})
	if resource_stock.is_empty():
		return "국가 창고: 보유 자원 없음"
	var lines: Array[String] = ["국가 창고"]
	for resource_id in RESOURCE_DISPLAY_ORDER:
		var resource_id_string := str(resource_id)
		var value := int(resource_stock.get(resource_id_string, 0))
		var capacity := int(WAREHOUSE_CAPACITY.get(resource_id_string, 0))
		lines.append("%s %d / %d · %s" % [
			str(RESOURCE_LABELS.get(resource_id_string, resource_id_string)),
			value,
			capacity,
			_get_resource_status_label(resource_id_string, value, capacity),
		])
	return "\n".join(lines)


func _get_resource_status_color(status: String) -> Color:
	match status:
		"부족":
			return Color(0.95, 0.48, 0.42, 1.0)
		"과잉":
			return Color(0.60, 0.78, 1.0, 1.0)
		"충분":
			return Color(0.98, 0.82, 0.46, 1.0)
		_:
			return Color(0.68, 0.88, 0.72, 1.0)


func _get_resource_status_label(_resource_id: String, value: int, max_value: int) -> String:
	if max_value <= 0:
		return "상한 없음"
	var ratio := float(value) / float(max_value)
	if ratio <= WAREHOUSE_LOW_RATIO:
		return "부족"
	if ratio <= WAREHOUSE_STABLE_RATIO:
		return "안정"
	if ratio <= 1.0:
		return "충분"
	return "과잉"


func _format_policy_preview_summary(policy_id: String) -> String:
	return "정책 preview: %s\n%s" % [
		_format_chancellor_policy_multiplier_summary(policy_id),
		"현재 보유량은 변경하지 않음",
	]


func _format_chancellor_policy_multiplier_summary(policy_id: String) -> String:
	var policy_data := _get_chancellor_policy_entry(policy_id)
	var parts: Array[String] = []
	for resource_id in ["rice", "barley", "seafood", "gold"]:
		var resource_id_string := str(resource_id)
		var multiplier := float(policy_data.get("%s_multiplier" % resource_id_string, 1.0))
		if not is_equal_approx(multiplier, 1.0):
			parts.append("%s x%.2f" % [str(RESOURCE_LABELS.get(resource_id_string, resource_id_string)), multiplier])
	var upkeep_multiplier := float(policy_data.get("hero_upkeep_multiplier", 1.0))
	if not is_equal_approx(upkeep_multiplier, 1.0):
		parts.append("영웅 유지비 x%.2f" % upkeep_multiplier)
	var soldier_multiplier := float(policy_data.get("soldier_upkeep_preview_multiplier", 1.0))
	if not is_equal_approx(soldier_multiplier, 1.0):
		parts.append("병사 유지비 x%.2f" % soldier_multiplier)
	var salt_multiplier := float(policy_data.get("salt_preservation_multiplier", 1.0))
	if not is_equal_approx(salt_multiplier, 1.0):
		parts.append("보존 소금 x%.2f" % salt_multiplier)
	if parts.is_empty():
		return "보정 없음"
	return " / ".join(parts)


func _format_hero_upkeep_preview(policy_id: String) -> String:
	var hero_count := _get_owned_hero_ids().size()
	var costs := {
		"rice": _apply_policy_cost_multiplier(int(HERO_UPKEEP_RULES["rice"]) * hero_count, policy_id, "hero_upkeep_multiplier"),
		"seafood": _apply_policy_cost_multiplier(int(HERO_UPKEEP_RULES["seafood"]) * hero_count, policy_id, "hero_upkeep_multiplier"),
		"silk": _apply_policy_cost_multiplier(int(HERO_UPKEEP_RULES["silk"]) * hero_count, policy_id, "hero_upkeep_multiplier"),
	}
	return "영웅 유지비 preview: %s · 실제 차감 없음" % _format_resource_costs(costs, ["rice", "seafood", "silk"])


func _format_soldier_upkeep_preview(policy_id: String) -> String:
	var troop_total := _get_owned_hero_troop_total() + _get_owned_city_garrison_total()
	var unit_count := int(ceil(float(troop_total) / float(SOLDIER_UPKEEP_RULES["troops_per_unit"])))
	var costs := {
		"rice": _apply_policy_cost_multiplier(int(SOLDIER_UPKEEP_RULES["rice"]) * unit_count, policy_id, "soldier_upkeep_preview_multiplier"),
		"barley": _apply_policy_cost_multiplier(int(SOLDIER_UPKEEP_RULES["barley"]) * unit_count, policy_id, "soldier_upkeep_preview_multiplier"),
		"seafood": _apply_policy_cost_multiplier(int(SOLDIER_UPKEEP_RULES["seafood"]) * unit_count, policy_id, "soldier_upkeep_preview_multiplier"),
	}
	return "병사 유지비 preview: %s · 병력 %d명 기준, 미차감" % [
		_format_resource_costs(costs, ["rice", "barley", "seafood"]),
		troop_total,
	]


func _format_salt_preservation_preview(policy_id: String) -> String:
	var food_total := _get_player_resource_amount("rice") + _get_player_resource_amount("barley")
	var seafood := _get_player_resource_amount("seafood")
	var base_need := int(ceil((float(food_total) * float(SALT_PRESERVATION_RULES["food_ratio"])) + (float(seafood) * float(SALT_PRESERVATION_RULES["seafood_ratio"]))))
	var needed := _apply_policy_cost_multiplier(base_need, policy_id, "salt_preservation_multiplier")
	var current_salt := _get_player_resource_amount("salt")
	var status := "안정" if current_salt >= needed else "부족"
	return "보존 소금 preview: 필요 %d / 보유 %d · %s · 미차감" % [needed, current_salt, status]


func _apply_policy_cost_multiplier(amount: int, policy_id: String, multiplier_key: String) -> int:
	var multiplier := float(_get_chancellor_policy_entry(policy_id).get(multiplier_key, 1.0))
	var adjusted := amount * multiplier
	if multiplier < 1.0:
		return int(floor(adjusted))
	return int(round(adjusted))


func _format_resource_costs(costs: Dictionary, resource_order: Array) -> String:
	var parts: Array[String] = []
	for resource_id in resource_order:
		var resource_id_string := str(resource_id)
		var amount := int(costs.get(resource_id_string, 0))
		if amount > 0:
			parts.append("%s -%d" % [str(RESOURCE_LABELS.get(resource_id_string, resource_id_string)), amount])
	if parts.is_empty():
		return "없음"
	return " / ".join(parts)


func _get_owned_hero_ids() -> Array:
	var hero_ids: Variant = _player_state.get("owned_hero_ids", [])
	if hero_ids is Array:
		return hero_ids
	return []


func _get_owned_hero_troop_total() -> int:
	var total := 0
	for hero_id in _get_owned_hero_ids():
		var hero_data := _get_hero_entry(str(hero_id))
		total += int(hero_data.get("troops", 0))
	return total


func _get_owned_city_garrison_total() -> int:
	var total := 0
	var city_ids: Variant = _player_state.get("owned_city_ids", [])
	if not city_ids is Array:
		return total
	for city_id in city_ids:
		var city_data := _get_city_hud_entry(str(city_id))
		total += int(city_data.get("troops", 0))
	return total


func _normalize_tax_level(value: Variant) -> int:
	return clampi(int(round(float(value))), 0, 100)


func _get_tax_gold_multiplier(tax_level: int) -> float:
	var normalized_tax := _normalize_tax_level(tax_level)
	if normalized_tax <= 30:
		return 0.5 + (float(normalized_tax) / 30.0) * 0.5
	return 1.0 + (float(normalized_tax - 30) / 70.0)


func _get_tax_loyalty_delta(tax_level: int) -> int:
	var normalized_tax := _normalize_tax_level(tax_level)
	if normalized_tax > 30:
		return -int(ceil(float(normalized_tax - 30) / 25.0))
	if normalized_tax < 30:
		return int(ceil(float(30 - normalized_tax) / 30.0))
	return 0


func _format_tax_effect_text(tax_level: int) -> String:
	return "세금 효과: 인구·상업세 적용, 충성도 %s" % _format_signed_int(_get_tax_loyalty_delta(tax_level))


func _format_tax_preview(tax_level: int, national_loyalty: int, public_order: int) -> String:
	return "세금 preview: 금전 x%.2f · 충성도 %s · 현재 %s / 치안 %d" % [
		_get_tax_gold_multiplier(tax_level),
		_format_signed_int(_get_tax_loyalty_delta(tax_level)),
		_get_loyalty_status(national_loyalty),
		public_order,
	]


func _format_signed_int(value: int) -> String:
	if value > 0:
		return "+%d" % value
	return str(value)


func _get_loyalty_status(value: int) -> String:
	if value >= 85:
		return "매우 안정"
	if value >= 70:
		return "안정"
	if value >= 55:
		return "주의"
	return "위험"


func _get_stationed_hero_ids_for_city(city_data: Dictionary) -> Array:
	var hero_ids: Variant = city_data.get("stationed_hero_ids", city_data.get("hero_ids", []))
	if hero_ids is Array:
		return hero_ids
	return []


func _sync_chancellor_assignment_for_selected_city(city_data: Dictionary) -> void:
	var chancellor_id := str(_player_state.get("chancellor_id", ""))
	if chancellor_id.is_empty():
		return
	var stationed_hero_ids := _get_stationed_hero_ids_for_city(city_data)
	if not stationed_hero_ids.has(chancellor_id):
		_player_state["chancellor_id"] = ""


func _populate_chancellor_assignment_dropdown(city_data: Dictionary) -> void:
	chancellor_assignment_option.clear()
	chancellor_assignment_option.add_item("미임명")
	chancellor_assignment_option.set_item_metadata(0, "")
	for hero_id in _get_stationed_hero_ids_for_city(city_data):
		var hero_name := _format_hero_name_by_id(str(hero_id), "알 수 없는 장수")
		chancellor_assignment_option.add_item(hero_name)
		chancellor_assignment_option.set_item_metadata(chancellor_assignment_option.item_count - 1, str(hero_id))


func _populate_chancellor_policy_dropdown() -> void:
	chancellor_policy_option.clear()
	for policy_id in CHANCELLOR_POLICY_ORDER:
		var policy_id_string := str(policy_id)
		var policy_data := _get_chancellor_policy_entry(policy_id_string)
		chancellor_policy_option.add_item(str(policy_data.get("name", policy_id_string)))
		chancellor_policy_option.set_item_metadata(chancellor_policy_option.item_count - 1, policy_id_string)


func _ensure_chancellor_portrait_texture_rect() -> void:
	if _chancellor_portrait_texture_rect != null:
		return
	var portrait_box := chancellor_portrait_label.get_parent()
	if not portrait_box is Control:
		return
	_chancellor_portrait_texture_rect = TextureRect.new()
	_chancellor_portrait_texture_rect.name = "ChancellorPortraitTexture"
	_chancellor_portrait_texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_chancellor_portrait_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_chancellor_portrait_texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_chancellor_portrait_texture_rect.visible = false
	portrait_box.add_child(_chancellor_portrait_texture_rect)
	_chancellor_portrait_texture_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _get_chancellor_effect_text(hero_data: Dictionary) -> String:
	if hero_data.is_empty():
		return "재상 효과 없음"
	var tags: Array[String] = []
	_add_chancellor_effect_tag(tags, str(hero_data.get("chancellor_primary_type", "")))
	_add_chancellor_effect_tag(tags, str(hero_data.get("chancellor_secondary_type", "")))
	if tags.is_empty():
		tags.append("균형 운영")
	return "%s: %s" % [
		str(hero_data.get("display_name", hero_data.get("name", "알 수 없는 장수"))),
		" · ".join(tags.slice(0, 3)),
	]


func _add_chancellor_effect_tag(tags: Array[String], type_id: String) -> void:
	var tag := ""
	match type_id:
		"political":
			tag = "세금 부담 완화"
		"economic":
			tag = "금전 수입 증가"
		"administrative":
			tag = "유지비 절감"
		"diplomatic":
			tag = "교역 기반 금전 보정"
		"militaryAdmin":
			tag = "병사 유지비 preview 완화"
		_:
			tag = ""
	if not tag.is_empty() and not tags.has(tag):
		tags.append(tag)


func _get_chancellor_policy_entry(policy_id: String) -> Dictionary:
	return CHANCELLOR_POLICY_DATA.get(_normalize_chancellor_policy_id(policy_id), CHANCELLOR_POLICY_DATA["balanced"])


func _normalize_chancellor_policy_id(policy_id: String) -> String:
	return policy_id if CHANCELLOR_POLICY_DATA.has(policy_id) else "balanced"


func _get_governor_policy_entry(policy_id: String) -> Dictionary:
	return GOVERNOR_POLICY_DATA.get(policy_id, GOVERNOR_POLICY_DATA["follow_chancellor"])


func _get_city_policy_id(city_id: String, city_data: Dictionary) -> String:
	return str(_city_policy_state.get(city_id, city_data.get("governor_policy_id", "follow_chancellor")))


func _format_hero_stats(hero_data: Dictionary) -> String:
	if hero_data.is_empty():
		return "능력: -"
	return "정 %d / 무 %d / 지 %d / 충 %d" % [
		int(hero_data.get("politics", 0)),
		int(hero_data.get("war", 0)),
		int(hero_data.get("intelligence", 0)),
		int(hero_data.get("loyalty", 0)),
	]


func _format_chancellor_type_summary(hero_data: Dictionary) -> String:
	if hero_data.is_empty():
		return "주: 없음\n보조: 없음"
	return "%s\n%s" % [
		_format_chancellor_type_line(
			"주",
			str(hero_data.get("chancellor_primary_type", "")),
			int(hero_data.get("chancellor_primary_aptitude", 0))
		),
		_format_chancellor_type_line(
			"보조",
			str(hero_data.get("chancellor_secondary_type", "")),
			int(hero_data.get("chancellor_secondary_aptitude", 0))
		),
	]


func _format_chancellor_type_line(label: String, type_id: String, aptitude: int) -> String:
	if type_id.is_empty():
		return "%s: 없음" % label
	return "%s: %s %d" % [
		label,
		str(CHANCELLOR_TYPE_LABELS.get(type_id, type_id)),
		aptitude,
	]


func _get_tax_description(tax_level: int) -> String:
	if tax_level < 30:
		return "가벼운 세금, 충성도 회복"
	if tax_level > 30:
		return "무거운 세금, 금전 증가 / 충성도 하락"
	return "평소 수준"


func _select_option_by_metadata(option_button: OptionButton, metadata_value: String) -> void:
	for index in range(option_button.item_count):
		if str(option_button.get_item_metadata(index)) == metadata_value:
			option_button.select(index)
			return


func _on_tax_slider_value_changed(value: float) -> void:
	var tax_level := _normalize_tax_level(value)
	_player_state["tax_level"] = tax_level
	_refresh_left_world_status_panel()


func _on_chancellor_assignment_selected(index: int) -> void:
	var chancellor_id := str(chancellor_assignment_option.get_item_metadata(index))
	_player_state["chancellor_id"] = chancellor_id
	var log_chancellor_id := chancellor_id if not chancellor_id.is_empty() else "unassigned"
	print("[WorldMap] Chancellor assignment placeholder selected: %s. No policy effect applied." % log_chancellor_id)
	_refresh_left_world_status_panel()


func _on_chancellor_policy_selected(index: int) -> void:
	var policy_id := str(chancellor_policy_option.get_item_metadata(index))
	if not CHANCELLOR_POLICY_DATA.has(policy_id):
		policy_id = "balanced"
	_player_state["chancellor_policy_id"] = policy_id
	_refresh_left_world_status_panel()


func _format_region_label(region_id: String) -> String:
	return str(REGION_LABELS.get(region_id, region_id))


func _format_faction_label(owner_faction_id: String) -> String:
	return str(FACTION_LABELS.get(owner_faction_id, owner_faction_id))


func _format_city_type(city_id: String) -> String:
	return str(CITY_TYPE_LABELS.get(city_id, "거점"))


func _get_city_detail_status(city_marker: WorldMapCityMarker) -> String:
	if city_marker.owner_faction_id == PLAYER_FACTION_ID:
		return "아군 도시"
	if _has_player_neighbor(city_marker):
		return "아군 인접 적 도시"
	if not city_marker.owner_faction_id.is_empty():
		return "적 도시"
	return "월드맵 이식 중"


func _has_player_neighbor(city_marker: WorldMapCityMarker) -> bool:
	for neighbor_id in city_marker.neighbors:
		var neighbor_marker := _city_markers_by_id.get(neighbor_id) as WorldMapCityMarker
		if neighbor_marker != null and neighbor_marker.owner_faction_id == PLAYER_FACTION_ID:
			return true
	return false


func _on_wild_army_edit_placeholder_pressed() -> void:
	_on_ally_turn_end_pressed()


func _on_save_placeholder_pressed() -> void:
	_save_worldmap_state()


func _on_load_placeholder_pressed() -> void:
	_load_worldmap_state()


func _on_reset_placeholder_pressed() -> void:
	_reset_worldmap_state()


func _on_diplomacy_mode_placeholder_pressed() -> void:
	print("[WorldMap] Diplomacy tab placeholder selected. Diplomacy logic is deferred.")
	diplomacy_hint_label.text = "외교 행동은 준비 중입니다."


func _on_spy_mode_placeholder_pressed() -> void:
	print("[WorldMap] Spy tab placeholder selected. Spy logic is deferred.")
	diplomacy_hint_label.text = "첩보 판정은 준비 중입니다."


func _on_unified_primary_tab_pressed(tab_id: String) -> void:
	if not [UNIFIED_PANEL_TAB_CITY_DETAIL, UNIFIED_PANEL_TAB_DIPLOMACY_SPY].has(tab_id):
		tab_id = UNIFIED_PANEL_TAB_CITY_DETAIL
	_unified_primary_tab = tab_id
	print("[WorldMap] Unified city panel primary tab selected: %s. Display only." % tab_id)
	_refresh_unified_panel_content()


func _on_unified_secondary_tab_pressed(tab_index: int) -> void:
	if _unified_primary_tab == UNIFIED_PANEL_TAB_DIPLOMACY_SPY:
		_selected_diplomacy_spy_tab = DIPLOMACY_SPY_TAB_SPY if tab_index == 1 else DIPLOMACY_SPY_TAB_DIPLOMACY
		print("[WorldMap] Unified diplomacy/spy tab selected: %s. Display only." % _selected_diplomacy_spy_tab)
		_show_unified_diplomacy_spy_content()
		return

	var city_tab_id := CITY_DETAIL_TAB_RESOURCES
	if tab_index == 1:
		city_tab_id = CITY_DETAIL_TAB_INTERNAL_TRADE
	elif tab_index == 2:
		city_tab_id = CITY_DETAIL_TAB_EXTERNAL_TRADE
	_on_city_detail_tab_pressed(city_tab_id)


func _on_city_detail_tab_pressed(tab_id: String) -> void:
	if not [CITY_DETAIL_TAB_RESOURCES, CITY_DETAIL_TAB_INTERNAL_TRADE, CITY_DETAIL_TAB_EXTERNAL_TRADE].has(tab_id):
		tab_id = CITY_DETAIL_TAB_RESOURCES
	_unified_primary_tab = UNIFIED_PANEL_TAB_CITY_DETAIL
	_selected_city_detail_tab = tab_id
	print("[WorldMap] City detail tab selected: %s. Display only; no domestic/trade effect applied." % tab_id)
	if selected_city_marker != null:
		_show_city_detail(selected_city_marker)
	else:
		_reset_city_detail_panel()
	city_detail_hint_label.text = "%s 탭 표시 전환됨. 실제 내정/무역 처리는 실행하지 않습니다." % _get_city_detail_tab_label(tab_id)
	_queue_unified_city_panel_resize()


func _get_city_detail_tab_label(tab_id: String) -> String:
	match tab_id:
		CITY_DETAIL_TAB_INTERNAL_TRADE:
			return "자국무역"
		CITY_DETAIL_TAB_EXTERNAL_TRADE:
			return "타국무역"
		_:
			return "자원"


func _on_city_detail_collapse_placeholder_pressed() -> void:
	_set_unified_city_panel_collapsed(not _is_unified_city_panel_collapsed)
	print("[WorldMap] Unified city panel collapse toggled: %s. Position is runtime-only." % str(_is_unified_city_panel_collapsed))


func _queue_unified_city_panel_resize() -> void:
	if _is_unified_city_panel_collapsed:
		return
	call_deferred("_resize_unified_city_panel_to_content")


func _resize_unified_city_panel_to_content() -> void:
	if _is_unified_city_panel_collapsed or city_detail_panel == null:
		return

	if _unified_city_panel_expanded_size == Vector2.ZERO:
		_unified_city_panel_expanded_size = city_detail_panel.size

	var viewport_size: Vector2 = get_viewport_rect().size
	var panel_width := maxf(_unified_city_panel_expanded_size.x, city_detail_panel.size.x)
	var minimum_height := maxf(
		UNIFIED_PANEL_MIN_EXPANDED_HEIGHT,
		city_detail_panel.get_combined_minimum_size().y
	)
	var available_height := viewport_size.y - city_detail_panel.global_position.y - UNIFIED_PANEL_SCREEN_PADDING
	var next_height := clampf(minimum_height, UNIFIED_PANEL_MIN_EXPANDED_HEIGHT, maxf(UNIFIED_PANEL_MIN_EXPANDED_HEIGHT, available_height))
	city_detail_panel.size = Vector2(panel_width, next_height)


func _set_unified_city_panel_collapsed(is_collapsed: bool) -> void:
	if _unified_city_panel_expanded_size == Vector2.ZERO:
		_unified_city_panel_expanded_size = city_detail_panel.size

	_is_unified_city_panel_collapsed = is_collapsed
	for child in city_detail_content_container.get_children():
		if child != city_detail_header_row:
			var child_control := child as Control
			if child_control != null:
				child_control.visible = not is_collapsed

	if _unified_city_detail_primary_button != null:
		_unified_city_detail_primary_button.visible = not is_collapsed
	if _unified_diplomacy_spy_primary_button != null:
		_unified_diplomacy_spy_primary_button.visible = not is_collapsed

	if is_collapsed:
		city_detail_heading_label.visible = true
		city_detail_heading_label.text = UNIFIED_PANEL_COLLAPSED_LABEL
		city_detail_collapse_button_placeholder.text = "열기"
		city_detail_panel.size = Vector2(_unified_city_panel_expanded_size.x, UNIFIED_PANEL_COLLAPSED_HEIGHT)
	else:
		city_detail_heading_label.visible = false
		city_detail_heading_label.text = ""
		city_detail_collapse_button_placeholder.text = "접기"
		_refresh_unified_panel_content()
		_queue_unified_city_panel_resize()


func _on_city_detail_domestic_placeholder_pressed() -> void:
	print("[WorldMap] City detail domestic placeholder selected. Domestic execution is deferred.")
	city_detail_hint_label.text = "내정 실행은 아직 수치나 턴 처리와 연결되지 않았습니다."
