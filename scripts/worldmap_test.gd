extends Node2D

const HeroPortraitHelper := preload("res://scripts/worldmap_hero_portrait_helper.gd")
const PlayerAttackDeploymentPanelScript := preload("res://scripts/player_attack_deployment_panel.gd")

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
const REVOLT_RISK_STABLE := "stable"
const REVOLT_RISK_WARNING := "warning"
const REVOLT_RISK_DANGER := "danger"
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
const GOVERNOR_PRIMARY_RATE := 0.025
const GOVERNOR_SECONDARY_RATE := 0.0125
const CITY_PUBLIC_SUPPORT_DEFAULT := 70
const PUBLIC_SUPPORT_DELTA_MIN := -7
const PUBLIC_SUPPORT_DELTA_MAX := 3
const CITY_LOYALTY_DRIFT_MIN := -3
const CITY_LOYALTY_DRIFT_MAX := 3
const STATIONED_HERO_SECURITY_WEIGHT := 1.0
const FACTION_RELATION_STATUS := {
	"ALLIED": "allied",
	"NEUTRAL": "neutral",
	"HOSTILE": "hostile",
	"SUSPENDED": "suspended",
}
const TRADE_SUSPENSION_TURNS := 3
const RELATION_TRADE_MULTIPLIER := {
	"allied": 1.25,
	"neutral": 1.0,
	"hostile": 0.0,
	"suspended": 0.0,
}
const TRADE_ROUTE_CAP := {
	"gold": 90,
	"rice": 20,
	"barley": 20,
	"seafood": 22,
	"salt": 16,
}
# v0.68b-13-2B Trade balance tuning (web parity restore)
const TRADE_GLOBAL_DAMPENER := 0.5
const TRADE_FOOD_FACTOR := 1.5
const SUPPLY_INCOME_BONUS := 1.10
const SUPPLY_INCOME_PENALTY := 0.80
const SUPPLY_LOYALTY_BONUS := 1
const SUPPLY_LOYALTY_PENALTY := -2
const SUPPLY_SECURITY_BONUS := 1
const SUPPLY_SECURITY_PENALTY := -1
const SUPPLY_UPKEEP_DISCOUNT_PER_CITY := 0.03
const SUPPLY_UPKEEP_DISCOUNT_FLOOR := 0.85
const TROOP_MOVE_MIN_GARRISON_RATIO := 0.6
const ROLE_TARGET_GARRISON_RATIO := {
	"hub": 0.006,
	"rear": 0.006,
	"frontline": 0.01,
}

# v0.68b-12b-10b WorldMap Hero Portrait Asset Binding MVP
# v0.68b-12b-11 WorldMap Enemy Invasion BattleContext Bridge
# v0.68b-12b-12 WorldMap Enemy Invasion Battle Scene Handoff MVP
# v0.68b-12b-14 WorldMap Battle Result Return MVP
# v0.68b-12b-14-hotfix2 Integer Division Warning Cleanup
# v0.68b-12b-14-hotfix1 Unified Panel Chrome Nil Visible Guard
# v0.68b-12b-15 WorldMap Invasion Result Ownership Troop Apply MVP
# v0.68b-12b-15-hotfix1 ReadOnly City Dictionary Troop Apply Fix

const WORLDMAP_BATTLE_CONTEXT_META_KEY := "samwar_worldmap_battle_context"
const WORLDMAP_BATTLE_RESULT_META_KEY := "samwar_worldmap_battle_result"
const WORLDMAP_BATTLE_SCENE_PATH := "res://Battle_Fullscreen_Test.tscn"
const PLAYER_ATTACK_CONTEXT_SOURCE := "player_attack"
const INVASION_RESULT_DEFENDER_WIN := "defender_win"
const INVASION_RESULT_ATTACKER_WIN := "attacker_win"
const INVASION_RESULT_RETREAT := "retreat"
const INVASION_RESULT_UNKNOWN := "unknown"
const INVASION_RESULT_DEFAULT_OCCUPATION_TROOPS := 100
const INVASION_MIN_CITY_TROOPS := 30
const INVASION_MIN_OCCUPATION_TROOPS := 80
const INVASION_MAX_REASONABLE_CITY_TROOPS := 99999
const INVASION_DEFENDER_WIN_DEFENDER_LOSS_RATE := 0.15
const INVASION_DEFENDER_WIN_ATTACKER_LOSS_RATE := 0.70
const INVASION_ATTACKER_WIN_DEFENDER_LOSS_RATE := 0.75
const INVASION_ATTACKER_WIN_ATTACKER_LOSS_RATE := 0.35
const INVASION_BATTLE_MAX_HEROES_PER_SIDE := 5
const INVASION_REINFORCEMENT_MAX_HOPS := 2
const INVASION_REINFORCEMENT_ALLY_FACTIONS := {}
const HERO_RUNTIME_STATUS_NORMAL := "normal"
const HERO_RUNTIME_STATUS_WOUNDED := "wounded"
const HERO_RUNTIME_STATUS_CAPTURED := "captured"
const HERO_RUNTIME_STATUS_DEAD := "dead"
const DEFAULT_WOUNDED_RECOVERY_TURNS := 3
const PLAYER_ATTACK_MIN_SOURCE_CITY_TROOPS := 1
const COMMAND_RANK_GOVERNOR := "governor"
const COMMAND_RANK_GENERAL := "general"
const COMMAND_RANK_LIEUTENANT := "lieutenant"
const COMMAND_RANK_OFFICER := "officer"
const COMMAND_RANK_LABELS := {
	"governor": "태수",
	"general": "장군",
	"lieutenant": "부장",
	"officer": "군관",
}
const COMMAND_RANK_LIMITS := {
	"governor": 10000,
	"general": 8000,
	"lieutenant": 6000,
	"officer": 5000,
}

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
const PLAYER_ATTACK_SUPPLY_FOOD_RESOURCE_ID := "rice"
const PLAYER_ATTACK_SUPPLY_GOLD_RESOURCE_ID := "gold"
const PLAYER_ATTACK_SUPPLY_SALT_RESOURCE_ID := "salt"
const PLAYER_ATTACK_SUPPLY_GOLD_RATE := 0.2
const PLAYER_ATTACK_SUPPLY_SALT_RATE := 0.1
const PLAYER_ATTACK_WOUNDED_QUEUE_TURNS := 3

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
# v0.68b-12b-16 WorldMap Hero Battle Data Unique Skill Contract MVP
# v0.68b-12b-16b Hero Placement Data Patch
# Seed-only alignment from SamWar_web data/heroes.js, data/cities.js, and data/battle_rosters.js.
const HERO_DATA := {
	"yi_sun_sin": {"id": "yi_sun_sin", "hero_id": "yi_sun_sin", "display_name": "이순신", "name": "이순신", "role": "수군 지휘", "web_role": "ranged", "faction_id": "goryeo_joseon", "force_id": "goryeo_joseon", "side": "player", "nation": "player", "command_rank": "general", "politics": 76, "war": 90, "intelligence": 85, "loyalty": 98, "assigned_city_id": "hanseong", "city_id": "hanseong", "location_city_id": "hanseong", "troops": 110, "max_troops": 110, "max_hp": 110, "attack": 32, "defense": 16, "move_range": 2, "attack_range": 3, "skill_range": 3, "unique_skill_id": "hakikjin_barrage", "portrait_image": "assets/portraits/yi_sunsin_portrait.png", "battlefield_portrait_image": "assets/portraits_battlefield/yi_sunsin_battlefield.png", "chancellor_primary_type": "militaryAdmin", "chancellor_primary_aptitude": 5, "chancellor_secondary_type": "administrative", "chancellor_secondary_aptitude": 2},
	"jeong_do_jeon": {"id": "jeong_do_jeon", "hero_id": "jeong_do_jeon", "display_name": "정도전", "name": "정도전", "role": "재상", "web_role": "support", "faction_id": "goryeo_joseon", "force_id": "goryeo_joseon", "side": "player", "nation": "player", "command_rank": "officer", "politics": 94, "war": 40, "intelligence": 95, "loyalty": 90, "assigned_city_id": "hanseong", "city_id": "hanseong", "location_city_id": "hanseong", "troops": 90, "max_troops": 90, "max_hp": 90, "attack": 12, "defense": 12, "move_range": 3, "attack_range": 1, "skill_range": 3, "unique_skill_id": "reform_order", "portrait_image": "assets/portraits/jeong_dojeon_portrait.png", "battlefield_portrait_image": "assets/portraits_battlefield/jeong_dojeon_battlefield.png", "chancellor_primary_type": "political", "chancellor_primary_aptitude": 4, "chancellor_secondary_type": "administrative", "chancellor_secondary_aptitude": 3},
	"kwon_yul": {"id": "kwon_yul", "hero_id": "kwon_yul", "display_name": "권율", "name": "권율", "role": "방어전 지휘", "web_role": "support", "faction_id": "goryeo_joseon", "force_id": "goryeo_joseon", "side": "player", "nation": "player", "command_rank": "general", "politics": 68, "war": 84, "intelligence": 82, "loyalty": 92, "assigned_city_id": "hanseong", "city_id": "hanseong", "location_city_id": "hanseong", "unit_type": "infantry", "troops": 105, "troop_count": 105, "max_troops": 105, "max_hp": 105, "leadership": 88, "command": 88, "attack": 26, "defense": 24, "move_range": 3, "mobility": 3, "attack_range": 1, "skill_range": 3, "unique_skill_id": "gwon_yul_haengju_defense", "skill_id": "gwon_yul_haengju_defense", "skill_name": "행주대첩 항전", "skill_desc": "방어전 지휘로 아군의 방어 태세를 끌어올리는 고유특기.", "skill_effect_type": "guard_stance", "skill_power": 8, "skill_value": 8, "skill_cooldown": 3, "skill_toast_icon": "skill_unknown", "portrait_path": "res://assets/heroes/portraits/korea/korea_gwon_yul.png", "cutin_path": "res://assets/heroes/cutins/korea/korea_gwon_yul_cutin.png", "portrait_image": "", "battlefield_portrait_image": "", "chancellor_primary_type": "militaryAdmin", "chancellor_primary_aptitude": 4, "chancellor_secondary_type": "administrative", "chancellor_secondary_aptitude": 2},
	"cheok_jun_gyeong": {"id": "cheok_jun_gyeong", "hero_id": "cheok_jun_gyeong", "display_name": "척준경", "name": "척준경", "role": "초강력 개인 무력", "web_role": "melee", "faction_id": "goryeo_joseon", "force_id": "goryeo_joseon", "side": "player", "nation": "player", "command_rank": "general", "politics": 48, "war": 98, "intelligence": 48, "loyalty": 86, "assigned_city_id": "pyeongyang", "city_id": "pyeongyang", "location_city_id": "pyeongyang", "unit_type": "infantry", "troops": 115, "troop_count": 115, "max_troops": 115, "max_hp": 115, "leadership": 82, "command": 82, "attack": 40, "defense": 22, "move_range": 3, "mobility": 3, "attack_range": 1, "skill_range": 1, "unique_skill_id": "cheok_jun_gyeong_sword_king_break", "skill_id": "cheok_jun_gyeong_sword_king_break", "skill_name": "검왕돌파", "skill_desc": "압도적인 무력으로 인접한 적 하나를 강하게 베어 돌파하는 고유특기.", "skill_effect_type": "power_strike", "skill_power": 46, "skill_value": 46, "skill_cooldown": 3, "skill_toast_icon": "skill_unknown", "portrait_path": "res://assets/heroes/portraits/korea/korea_cheok_jun_gyeong.png", "cutin_path": "res://assets/heroes/cutins/korea/korea_cheok_jun_gyeong_cutin.png", "portrait_image": "", "battlefield_portrait_image": "", "chancellor_primary_type": "militaryAdmin", "chancellor_primary_aptitude": 5, "chancellor_secondary_type": "administrative", "chancellor_secondary_aptitude": 1},
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
	"xiahou_dun": {"id": "xiahou_dun", "hero_id": "xiahou_dun", "display_name": "하후돈", "name": "하후돈", "role": "돌파형 맹장", "web_role": "cavalry", "faction_id": "wei", "force_id": "wei", "side": "wei", "nation": "wei", "command_rank": "general", "politics": 62, "war": 90, "intelligence": 60, "loyalty": 88, "assigned_city_id": "yecheng", "city_id": "yecheng", "location_city_id": "yecheng", "unit_type": "cavalry", "troops": 112, "troop_count": 112, "max_troops": 112, "max_hp": 112, "leadership": 84, "command": 84, "attack": 35, "defense": 20, "move_range": 4, "mobility": 4, "attack_range": 1, "skill_range": 2, "unique_skill_id": "xiahou_dun_blade_breakthrough", "skill_id": "xiahou_dun_blade_breakthrough", "skill_name": "발검돌파", "skill_desc": "맹장의 돌파력으로 근접 공격을 강화해 적 진형을 흔드는 고유특기.", "skill_effect_type": "charge_bonus", "skill_power": 42, "skill_value": 42, "skill_cooldown": 3, "skill_toast_icon": "skill_unknown", "portrait_path": "res://assets/heroes/portraits/china/china_xiahou_dun.png", "cutin_path": "res://assets/heroes/cutins/china/china_xiahou_dun_cutin.png", "portrait_image": "", "battlefield_portrait_image": "", "chancellor_primary_type": "militaryAdmin", "chancellor_primary_aptitude": 4, "chancellor_secondary_type": "administrative", "chancellor_secondary_aptitude": 2},
	"xun_yu": {"id": "xun_yu", "hero_id": "xun_yu", "display_name": "순욱", "name": "순욱", "role": "행정", "web_role": "support", "faction_id": "wei", "force_id": "wei", "side": "wei", "nation": "wei", "command_rank": "officer", "politics": 96, "war": 30, "intelligence": 98, "loyalty": 86, "assigned_city_id": "yecheng", "city_id": "yecheng", "location_city_id": "yecheng", "troops": 75, "max_troops": 75, "max_hp": 75, "attack": 10, "defense": 10, "move_range": 2, "attack_range": 1, "skill_range": 5, "unique_skill_id": "xun_yu_strategy", "portrait_image": "", "battlefield_portrait_image": "", "chancellor_primary_type": "administrative", "chancellor_primary_aptitude": 5, "chancellor_secondary_type": "political", "chancellor_secondary_aptitude": 4},
	"lu_bu": {"id": "lu_bu", "hero_id": "lu_bu", "display_name": "여포", "name": "여포", "role": "최상위 무력/기병 돌격", "web_role": "cavalry", "faction_id": "chu", "force_id": "chu", "side": "chu", "nation": "chu", "command_rank": "general", "active": true, "is_active_roster": true, "is_reserve": false, "politics": 45, "war": 97, "intelligence": 45, "loyalty": 70, "assigned_city_id": "luoyang", "city_id": "luoyang", "location_city_id": "luoyang", "unit_type": "cavalry", "troops": 125, "troop_count": 125, "max_troops": 125, "max_hp": 125, "leadership": 78, "command": 78, "attack": 40, "defense": 20, "move_range": 5, "mobility": 5, "attack_range": 1, "skill_range": 2, "unique_skill_id": "lu_bu_musou_rampage", "skill_id": "lu_bu_musou_rampage", "skill_name": "무쌍난무", "skill_desc": "기병 돌격의 힘으로 적 하나를 압도하는 강력한 고유특기.", "skill_effect_type": "charge_bonus", "skill_power": 48, "skill_value": 48, "skill_cooldown": 3, "skill_toast_icon": "skill_unknown", "portrait_path": "res://assets/heroes/portraits/china/china_lu_bu.png", "cutin_path": "res://assets/heroes/cutins/china/china_lu_bu_cutin.png", "portrait_image": "", "battlefield_portrait_image": "", "chancellor_primary_type": "militaryAdmin", "chancellor_primary_aptitude": 5, "chancellor_secondary_type": "political", "chancellor_secondary_aptitude": 1},
	"guo_jia": {"id": "guo_jia", "hero_id": "guo_jia", "display_name": "곽가", "name": "곽가", "role": "책략", "web_role": "support", "faction_id": "wei", "force_id": "wei", "side": "wei", "nation": "wei", "command_rank": "officer", "politics": 82, "war": 34, "intelligence": 97, "loyalty": 82, "assigned_city_id": "yecheng", "city_id": "yecheng", "location_city_id": "yecheng", "troops": 80, "max_troops": 80, "max_hp": 80, "attack": 10, "defense": 12, "move_range": 2, "attack_range": 1, "skill_range": 4, "unique_skill_id": "heavenly_stratagem", "portrait_image": "", "battlefield_portrait_image": "", "chancellor_primary_type": "political", "chancellor_primary_aptitude": 4, "chancellor_secondary_type": "militaryAdmin", "chancellor_secondary_aptitude": 3},
	"zhuge_liang": {"id": "zhuge_liang", "hero_id": "zhuge_liang", "display_name": "제갈량", "name": "제갈량", "role": "책사", "web_role": "support", "faction_id": "shu", "force_id": "shu", "side": "shu", "nation": "shu", "command_rank": "general", "politics": 98, "war": 38, "intelligence": 99, "loyalty": 95, "assigned_city_id": "chengdu", "city_id": "chengdu", "location_city_id": "chengdu", "troops": 90, "max_troops": 90, "max_hp": 90, "attack": 12, "defense": 14, "move_range": 2, "attack_range": 1, "skill_range": 5, "unique_skill_id": "eight_trigram_formation", "portrait_image": "", "battlefield_portrait_image": "", "chancellor_primary_type": "administrative", "chancellor_primary_aptitude": 5, "chancellor_secondary_type": "economic", "chancellor_secondary_aptitude": 4},
	"guan_yu": {"id": "guan_yu", "hero_id": "guan_yu", "display_name": "관우", "name": "관우", "role": "장군", "web_role": "melee", "faction_id": "shu", "force_id": "shu", "side": "shu", "nation": "shu", "command_rank": "general", "politics": 70, "war": 94, "intelligence": 62, "loyalty": 95, "assigned_city_id": "chengdu", "city_id": "chengdu", "location_city_id": "chengdu", "troops": 115, "max_troops": 115, "max_hp": 115, "attack": 36, "defense": 20, "move_range": 3, "attack_range": 1, "skill_range": 1, "unique_skill_id": "crescent_blade_slash", "portrait_image": "assets/portraits/guan_yu_portrait.png", "battlefield_portrait_image": "assets/portraits_battlefield/guan_yu_battlefield.png", "chancellor_primary_type": "militaryAdmin", "chancellor_primary_aptitude": 4, "chancellor_secondary_type": "political", "chancellor_secondary_aptitude": 2},
	"zhang_fei": {"id": "zhang_fei", "hero_id": "zhang_fei", "display_name": "장비", "name": "장비", "role": "돌격", "web_role": "melee", "faction_id": "shu", "force_id": "shu", "side": "shu", "nation": "shu", "command_rank": "general", "politics": 52, "war": 92, "intelligence": 48, "loyalty": 92, "assigned_city_id": "chengdu", "city_id": "chengdu", "location_city_id": "chengdu", "troops": 110, "max_troops": 110, "max_hp": 110, "attack": 35, "defense": 18, "move_range": 3, "attack_range": 1, "skill_range": 1, "unique_skill_id": "changban_shatter", "portrait_image": "assets/portraits/zhang_fei_portrait.png", "battlefield_portrait_image": "assets/portraits_battlefield/zhang_fei_battlefield.png", "chancellor_primary_type": "militaryAdmin", "chancellor_primary_aptitude": 3, "chancellor_secondary_type": "political", "chancellor_secondary_aptitude": 1},
	"liu_bei": {"id": "liu_bei", "hero_id": "liu_bei", "display_name": "유비", "name": "유비", "role": "군주형/지휘", "web_role": "support", "faction_id": "shu", "force_id": "shu", "side": "shu", "nation": "shu", "command_rank": "general", "politics": 88, "war": 72, "intelligence": 82, "loyalty": 96, "assigned_city_id": "chengdu", "city_id": "chengdu", "location_city_id": "chengdu", "unit_type": "support", "troops": 100, "troop_count": 100, "max_troops": 100, "max_hp": 100, "leadership": 90, "command": 90, "attack": 20, "defense": 18, "move_range": 3, "mobility": 3, "attack_range": 1, "skill_range": 4, "unique_skill_id": "liu_bei_banner_of_benevolence", "skill_id": "liu_bei_banner_of_benevolence", "skill_name": "인의의 깃발", "skill_desc": "군주의 인덕으로 아군의 사기와 공격 흐름을 보조하는 고유특기.", "skill_effect_type": "command_aura", "skill_power": 7, "skill_value": 7, "skill_cooldown": 3, "skill_toast_icon": "skill_unknown", "portrait_path": "res://assets/heroes/portraits/china/china_liu_bei.png", "cutin_path": "res://assets/heroes/cutins/china/china_liu_bei_cutin.png", "portrait_image": "", "battlefield_portrait_image": "", "chancellor_primary_type": "political", "chancellor_primary_aptitude": 5, "chancellor_secondary_type": "militaryAdmin", "chancellor_secondary_aptitude": 3},
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
	"hanseong": {"id": "hanseong", "name": "한성", "owner": "player", "nation": "player", "region": "한반도", "region_key": "region.korean_peninsula", "type": "commercial_capital", "population": 50000, "population_rating": 4, "commerce_rating": 5, "gold": 650, "food": 468, "troops": 300, "public_order": 74, "commerce": 70, "agriculture": 62, "defense": 3, "governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": ["yi_sun_sin", "jeong_do_jeon", "kwon_yul"], "hero_ids": ["yi_sun_sin", "jeong_do_jeon", "kwon_yul"], "loyalty": 78, "resources": "쌀 ★★★ / 보리 ★★★ / 수산물 ★ / 목재 ★ / 철 ★ / 말 - / 비단 ★★★ / 소금 ★★", "military": "도시 주둔군 300 / 치안 기준 500 / 방어력 3", "trade": "내부 교역로: 평양-경주-사비 연결 후보", "rating": "인구 ★★★★ · 상업력 ★★★★★ · 금전 650", "resource_seed": {"rice": 3, "barley": 3, "seafood": 1, "wood": 1, "iron": 1, "horses": 0, "silk": 3, "salt": 2, "gold": 650, "specialty": 1}, "domestic_seed": {"publicSupport": 72, "publicOrder": 74, "agriculture": 62, "commerce": 70, "stability": 68}, "yield_seed": {"riceHarvest": 310, "barleyHarvest": 130, "seafoodPerTurn": 28, "commerceIncome": 145, "specialtyIncome": 320}},
	"pyeongyang": {"id": "pyeongyang", "name": "평양", "owner": "goguryeo", "nation": "goguryeo", "region": "한반도", "region_key": "region.korean_peninsula", "type": "production_city", "population": 42000, "population_rating": 3, "commerce_rating": 3, "gold": 420, "food": 512, "troops": 280, "public_order": 66, "commerce": 42, "agriculture": 68, "defense": 3, "governor_id": "gwanggaeto", "governor_policy_id": "military", "stationed_hero_ids": ["gwanggaeto", "eulji_mundeok", "dorim", "cheok_jun_gyeong"], "hero_ids": ["gwanggaeto", "eulji_mundeok", "dorim", "cheok_jun_gyeong"], "loyalty": 72, "resources": "쌀 ★★★ / 보리 ★★★ / 수산물 ★ / 목재 ★★★ / 철 ★★ / 말 ★★★ / 비단 ★ / 소금 ★", "military": "도시 주둔군 280 / 치안 기준 500 / 방어력 3", "trade": "내부 교역로: 한성-카라코룸 연결 후보", "rating": "인구 ★★★ · 상업력 ★★★ · 금전 420", "resource_seed": {"rice": 3, "barley": 3, "seafood": 1, "wood": 3, "iron": 2, "horses": 3, "silk": 1, "salt": 1, "gold": 420, "specialty": 1}, "domestic_seed": {"publicSupport": 62, "publicOrder": 66, "agriculture": 68, "commerce": 42, "stability": 58}, "yield_seed": {"riceHarvest": 340, "barleyHarvest": 160, "seafoodPerTurn": 12, "commerceIncome": 90, "specialtyIncome": 260}},
	"karakorum": {"id": "karakorum", "name": "카라코룸", "owner": "mongol_faction", "nation": "mongol_faction", "region": "북방초원", "region_key": "region.northern_steppe", "type": "military_fortress", "population": 36000, "population_rating": 3, "commerce_rating": 2, "gold": 620, "food": 380, "troops": 460, "public_order": 74, "commerce": 44, "agriculture": 42, "defense": 4, "governor_id": "genghis_khan", "governor_policy_id": "military", "stationed_hero_ids": ["genghis_khan", "subutai", "jebe"], "hero_ids": ["genghis_khan", "subutai", "jebe"], "loyalty": 78, "resources": "쌀 ★ / 보리 ★★★★ / 수산물 - / 목재 ★★ / 철 ★★★★ / 말 ★★★★★ / 비단 ★★ / 소금 ★", "military": "도시 주둔군 460 / 치안 기준 900 / 방어력 4", "trade": "내부 교역로: 평양-업성 북방 연결", "rating": "인구 ★★★ · 상업력 ★★ · 금전 620", "resource_seed": {"rice": 1, "barley": 4, "seafood": 0, "wood": 2, "iron": 4, "horses": 5, "silk": 2, "salt": 1, "gold": 620, "specialty": 2}, "domestic_seed": {"publicSupport": 68, "publicOrder": 74, "agriculture": 42, "commerce": 44, "stability": 70}, "yield_seed": {"riceHarvest": 160, "barleyHarvest": 220, "seafoodPerTurn": 0, "commerceIncome": 105, "specialtyIncome": 360}},
	"gyeongju": {"id": "gyeongju", "name": "경주", "owner": "silla", "nation": "silla", "region": "한반도", "region_key": "region.korean_peninsula", "type": "commercial_capital", "population": 48000, "population_rating": 4, "commerce_rating": 4, "gold": 580, "food": 442, "troops": 280, "public_order": 72, "commerce": 74, "agriculture": 60, "defense": 3, "governor_id": "kim_chun_chu", "governor_policy_id": "commerce", "stationed_hero_ids": ["kim_chun_chu", "kim_yu_sin", "jang_bo_go"], "hero_ids": ["kim_chun_chu", "kim_yu_sin", "jang_bo_go"], "loyalty": 76, "resources": "쌀 ★★★ / 보리 ★★ / 수산물 ★★★ / 목재 ★★ / 철 ★ / 말 ★ / 비단 ★★★★ / 소금 ★★", "military": "도시 주둔군 280 / 치안 기준 500 / 방어력 3", "trade": "대외 무역: 경주 ↔ 교토 / 경주 ↔ 오사카 후보", "rating": "인구 ★★★★ · 상업력 ★★★★ · 금전 580", "resource_seed": {"rice": 3, "barley": 2, "seafood": 3, "wood": 2, "iron": 1, "horses": 1, "silk": 4, "salt": 2, "gold": 580, "specialty": 2}, "domestic_seed": {"publicSupport": 70, "publicOrder": 72, "agriculture": 60, "commerce": 74, "stability": 66}, "yield_seed": {"riceHarvest": 300, "barleyHarvest": 110, "seafoodPerTurn": 32, "commerceIncome": 155, "specialtyIncome": 410}},
	"sabi": {"id": "sabi", "name": "사비", "owner": "baekje_faction", "nation": "baekje_faction", "region": "한반도", "region_key": "region.korean_peninsula", "type": "river_trade_city", "population": 44000, "population_rating": 4, "commerce_rating": 4, "gold": 620, "food": 414, "troops": 300, "public_order": 68, "commerce": 76, "agriculture": 62, "defense": 3, "governor_id": "uija_wang", "governor_policy_id": "agriculture", "stationed_hero_ids": ["uija_wang", "gyebaek", "heukchi_sangji"], "hero_ids": ["uija_wang", "gyebaek", "heukchi_sangji"], "loyalty": 73, "resources": "쌀 ★★★ / 보리 ★★ / 수산물 ★★★ / 목재 ★★ / 철 ★ / 말 ★ / 비단 ★★★ / 소금 ★★★", "military": "도시 주둔군 300 / 치안 기준 600 / 방어력 3", "trade": "대외 무역: 사비 ↔ 큐슈 / 사비 ↔ 건업 후보", "rating": "인구 ★★★★ · 상업력 ★★★★ · 금전 620", "resource_seed": {"rice": 3, "barley": 2, "seafood": 3, "wood": 2, "iron": 1, "horses": 1, "silk": 3, "salt": 3, "gold": 620, "specialty": 2}, "domestic_seed": {"publicSupport": 66, "publicOrder": 68, "agriculture": 62, "commerce": 76, "stability": 61}, "yield_seed": {"riceHarvest": 280, "barleyHarvest": 100, "seafoodPerTurn": 34, "commerceIncome": 150, "specialtyIncome": 430}},
	"luoyang": {"id": "luoyang", "name": "낙양", "owner": "chu", "nation": "chu", "region": "중국대륙", "region_key": "region.china_mainland", "type": "commercial_capital", "population": 80000, "population_rating": 5, "commerce_rating": 5, "gold": 880, "food": 410, "troops": 420, "public_order": 62, "commerce": 82, "agriculture": 59, "defense": 4, "governor_id": "xiang_yu", "governor_policy_id": "military", "stationed_hero_ids": ["xiang_yu", "fan_zeng", "lu_bu"], "hero_ids": ["xiang_yu", "fan_zeng", "lu_bu"], "loyalty": 74, "resources": "쌀 ★★★ / 보리 ★★★ / 수산물 - / 목재 ★ / 철 ★★★ / 말 ★★ / 비단 ★★★★★ / 소금 ★", "military": "도시 주둔군 420 / 치안 기준 1000 / 방어력 4", "trade": "내부 교역로: 업성-성도-건업 내륙 연결", "rating": "인구 ★★★★★ · 상업력 ★★★★★ · 금전 880", "resource_seed": {"rice": 3, "barley": 3, "seafood": 0, "wood": 1, "iron": 3, "horses": 2, "silk": 5, "salt": 1, "gold": 880, "specialty": 2}, "domestic_seed": {"publicSupport": 58, "publicOrder": 62, "agriculture": 59, "commerce": 82, "stability": 55}, "yield_seed": {"riceHarvest": 320, "barleyHarvest": 90, "seafoodPerTurn": 0, "commerceIncome": 180, "specialtyIncome": 520}},
	"yecheng": {"id": "yecheng", "name": "업성", "owner": "wei", "nation": "wei", "region": "중국대륙", "region_key": "region.china_mainland", "type": "military_fortress", "population": 55000, "population_rating": 4, "commerce_rating": 3, "gold": 720, "food": 550, "troops": 450, "public_order": 68, "commerce": 52, "agriculture": 64, "defense": 5, "governor_id": "cao_cao", "governor_policy_id": "military", "stationed_hero_ids": ["cao_cao", "xiahou_dun", "xun_yu", "guo_jia"], "hero_ids": ["cao_cao", "xiahou_dun", "xun_yu", "guo_jia"], "loyalty": 70, "resources": "쌀 ★★★ / 보리 ★★★★ / 수산물 - / 목재 ★★ / 철 ★★★★★ / 말 ★★★★ / 비단 ★★ / 소금 ★", "military": "도시 주둔군 450 / 치안 기준 1000 / 방어력 5", "trade": "내부 교역로: 낙양-건업-카라코룸 연결", "rating": "인구 ★★★★ · 상업력 ★★★ · 금전 720", "resource_seed": {"rice": 3, "barley": 4, "seafood": 0, "wood": 2, "iron": 5, "horses": 4, "silk": 2, "salt": 1, "gold": 720, "specialty": 1}, "domestic_seed": {"publicSupport": 60, "publicOrder": 68, "agriculture": 64, "commerce": 52, "stability": 58}, "yield_seed": {"riceHarvest": 350, "barleyHarvest": 200, "seafoodPerTurn": 0, "commerceIncome": 110, "specialtyIncome": 280}},
	"chengdu": {"id": "chengdu", "name": "성도", "owner": "shu", "nation": "shu", "region": "중국대륙", "region_key": "region.china_mainland", "type": "production_city", "population": 60000, "population_rating": 4, "commerce_rating": 3, "gold": 640, "food": 630, "troops": 350, "public_order": 70, "commerce": 48, "agriculture": 80, "defense": 4, "governor_id": "zhuge_liang", "governor_policy_id": "agriculture", "stationed_hero_ids": ["zhuge_liang", "guan_yu", "zhang_fei", "liu_bei"], "hero_ids": ["zhuge_liang", "guan_yu", "zhang_fei", "liu_bei"], "loyalty": 72, "resources": "쌀 ★★★★★ / 보리 ★★★ / 수산물 - / 목재 ★★★★ / 철 ★★ / 말 ★ / 비단 ★★★ / 소금 ★★", "military": "도시 주둔군 350 / 치안 기준 800 / 방어력 4", "trade": "내부 교역로: 낙양/건업 장거리 내륙 교역", "rating": "인구 ★★★★ · 상업력 ★★★ · 금전 640", "resource_seed": {"rice": 5, "barley": 3, "seafood": 0, "wood": 4, "iron": 2, "horses": 1, "silk": 3, "salt": 2, "gold": 640, "specialty": 2}, "domestic_seed": {"publicSupport": 68, "publicOrder": 70, "agriculture": 80, "commerce": 48, "stability": 64}, "yield_seed": {"riceHarvest": 480, "barleyHarvest": 150, "seafoodPerTurn": 0, "commerceIncome": 100, "specialtyIncome": 320}},
	"jianye": {"id": "jianye", "name": "건업", "owner": "wu", "nation": "wu", "region": "중국대륙", "region_key": "region.china_mainland", "type": "river_trade_city", "population": 52000, "population_rating": 4, "commerce_rating": 5, "gold": 820, "food": 402, "troops": 300, "public_order": 66, "commerce": 84, "agriculture": 55, "defense": 3, "governor_id": "sun_ce", "governor_policy_id": "commerce", "stationed_hero_ids": ["sun_ce", "zhou_yu", "lu_meng"], "hero_ids": ["sun_ce", "zhou_yu", "lu_meng"], "loyalty": 74, "resources": "쌀 ★★★ / 보리 ★★ / 수산물 ★★★ / 목재 ★★★★ / 철 ★ / 말 - / 비단 ★★★★ / 소금 ★★★", "military": "도시 주둔군 300 / 치안 기준 600 / 방어력 3", "trade": "대외 무역: 건업 ↔ 사비 후보", "rating": "인구 ★★★★ · 상업력 ★★★★★ · 금전 820", "resource_seed": {"rice": 3, "barley": 2, "seafood": 3, "wood": 4, "iron": 1, "horses": 0, "silk": 4, "salt": 3, "gold": 820, "specialty": 3}, "domestic_seed": {"publicSupport": 64, "publicOrder": 66, "agriculture": 55, "commerce": 84, "stability": 60}, "yield_seed": {"riceHarvest": 290, "barleyHarvest": 80, "seafoodPerTurn": 32, "commerceIncome": 200, "specialtyIncome": 580}},
	"kyoto": {"id": "kyoto", "name": "교토", "owner": "oda", "nation": "oda", "region": "일본열도", "region_key": "region.japanese_archipelago", "type": "coastal_trade_city", "population": 45000, "population_rating": 3, "commerce_rating": 3, "gold": 760, "food": 335, "troops": 240, "public_order": 72, "commerce": 78, "agriculture": 49, "defense": 3, "governor_id": "nobunaga", "governor_policy_id": "commerce", "stationed_hero_ids": ["nobunaga", "takeda_shingen"], "hero_ids": ["nobunaga", "takeda_shingen"], "loyalty": 76, "resources": "쌀 ★ / 보리 ★ / 수산물 ★★★★★ / 목재 ★★ / 철 ★ / 말 - / 비단 ★★ / 소금 ★★★★", "military": "도시 주둔군 240 / 치안 기준 500 / 방어력 3", "trade": "대외 무역: 교토 ↔ 경주 후보", "rating": "인구 ★★★ · 상업력 ★★★ · 금전 760", "resource_seed": {"rice": 1, "barley": 1, "seafood": 5, "wood": 2, "iron": 1, "horses": 0, "silk": 2, "salt": 4, "gold": 760, "specialty": 2}, "domestic_seed": {"publicSupport": 66, "publicOrder": 72, "agriculture": 49, "commerce": 78, "stability": 64}, "yield_seed": {"riceHarvest": 220, "barleyHarvest": 70, "seafoodPerTurn": 45, "commerceIncome": 170, "specialtyIncome": 600}},
	"osaka": {"id": "osaka", "name": "오사카", "owner": "toyotomi", "nation": "toyotomi", "region": "일본열도", "region_key": "region.japanese_archipelago", "type": "commercial_capital", "population": 50000, "population_rating": 4, "commerce_rating": 5, "gold": 900, "food": 310, "troops": 260, "public_order": 68, "commerce": 86, "agriculture": 50, "defense": 3, "governor_id": "toyotomi_hideyoshi", "governor_policy_id": "commerce", "stationed_hero_ids": ["toyotomi_hideyoshi", "kenshin"], "hero_ids": ["toyotomi_hideyoshi", "kenshin"], "loyalty": 72, "resources": "쌀 ★★ / 보리 ★ / 수산물 ★★★★ / 목재 ★★ / 철 ★ / 말 - / 비단 ★★★ / 소금 ★★★★", "military": "도시 주둔군 260 / 치안 기준 500 / 방어력 3", "trade": "대외 무역: 오사카 ↔ 경주 / 큐슈 후보", "rating": "인구 ★★★★ · 상업력 ★★★★★ · 금전 900", "resource_seed": {"rice": 2, "barley": 1, "seafood": 4, "wood": 2, "iron": 1, "horses": 0, "silk": 3, "salt": 4, "gold": 900, "specialty": 3}, "domestic_seed": {"publicSupport": 66, "publicOrder": 68, "agriculture": 50, "commerce": 86, "stability": 62}, "yield_seed": {"riceHarvest": 210, "barleyHarvest": 60, "seafoodPerTurn": 40, "commerceIncome": 220, "specialtyIncome": 640}},
	"kyushu": {"id": "kyushu", "name": "큐슈", "owner": "kyushu_faction", "nation": "kyushu_faction", "region": "일본열도", "region_key": "region.japanese_archipelago", "type": "coastal_trade_city", "population": 42000, "population_rating": 3, "commerce_rating": 4, "gold": 680, "food": 296, "troops": 270, "public_order": 70, "commerce": 78, "agriculture": 48, "defense": 3, "governor_id": "shimazu_yoshihiro", "governor_policy_id": "military", "stationed_hero_ids": ["shimazu_yoshihiro", "konishi_yukinaga"], "hero_ids": ["shimazu_yoshihiro", "konishi_yukinaga"], "loyalty": 72, "resources": "쌀 ★★ / 보리 ★ / 수산물 ★★★★★ / 목재 ★★ / 철 ★ / 말 - / 비단 ★★ / 소금 ★★★★", "military": "도시 주둔군 270 / 치안 기준 500 / 방어력 3", "trade": "대외 무역: 큐슈 ↔ 사비 / 오사카 후보", "rating": "인구 ★★★ · 상업력 ★★★★ · 금전 680", "resource_seed": {"rice": 2, "barley": 1, "seafood": 5, "wood": 2, "iron": 1, "horses": 0, "silk": 2, "salt": 4, "gold": 680, "specialty": 2}, "domestic_seed": {"publicSupport": 64, "publicOrder": 70, "agriculture": 48, "commerce": 78, "stability": 62}, "yield_seed": {"riceHarvest": 190, "barleyHarvest": 60, "seafoodPerTurn": 46, "commerceIncome": 165, "specialtyIncome": 500}},
	"edo": {"id": "edo", "name": "에도", "owner": "tokugawa", "nation": "tokugawa", "region": "일본열도", "region_key": "region.japanese_archipelago", "type": "military_fortress", "population": 46000, "population_rating": 3, "commerce_rating": 3, "gold": 700, "food": 368, "troops": 380, "public_order": 78, "commerce": 60, "agriculture": 54, "defense": 4, "governor_id": "tokugawa_ieyasu", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": ["tokugawa_ieyasu", "honda_masanobu", "honda_tadakatsu"], "hero_ids": ["tokugawa_ieyasu", "honda_masanobu", "honda_tadakatsu"], "loyalty": 78, "resources": "쌀 ★★ / 보리 ★★ / 수산물 ★★★ / 목재 ★★★ / 철 ★★★ / 말 ★★ / 비단 ★ / 소금 ★★★", "military": "도시 주둔군 380 / 치안 기준 800 / 방어력 4", "trade": "내부 교역로: 교토 동방 내륙 연결", "rating": "인구 ★★★ · 상업력 ★★★ · 금전 700", "resource_seed": {"rice": 2, "barley": 2, "seafood": 3, "wood": 3, "iron": 3, "horses": 2, "silk": 1, "salt": 3, "gold": 700, "specialty": 1}, "domestic_seed": {"publicSupport": 72, "publicOrder": 78, "agriculture": 54, "commerce": 60, "stability": 74}, "yield_seed": {"riceHarvest": 240, "barleyHarvest": 100, "seafoodPerTurn": 28, "commerceIncome": 130, "specialtyIncome": 300}},
}

const HERO_BATTLE_ROLE_CONTRACTS := {
	"melee": {"unit_type": "infantry", "skill_effect_type": "power_strike", "battle_effect_type": "single_damage_adjacent_shake", "skill_power": 44, "skill_range": 1, "attack_range": 1, "move_range": 3},
	"cavalry": {"unit_type": "cavalry", "skill_effect_type": "charge_bonus", "battle_effect_type": "self_defense_single", "skill_power": 42, "skill_range": 2, "attack_range": 1, "move_range": 4},
	"ranged": {"unit_type": "archer", "skill_effect_type": "arrow_volley", "battle_effect_type": "cannon_aoe", "skill_power": 38, "skill_range": 3, "attack_range": 3, "move_range": 3},
	"support": {"unit_type": "support", "skill_effect_type": "rally", "battle_effect_type": "ally_attack_buff", "skill_power": 6, "skill_range": 4, "attack_range": 1, "move_range": 3},
}
const HERO_BATTLE_DEFAULT_ROLE_CONTRACT := {"unit_type": "infantry", "skill_effect_type": "command_aura", "battle_effect_type": "ally_attack_buff", "skill_power": 6, "skill_range": 3, "attack_range": 1, "move_range": 3}
const HERO_PORTRAIT_NATION_BY_FACTION := {
	"player": "korea",
	"goryeo_joseon": "korea",
	"goguryeo": "korea",
	"silla": "korea",
	"baekje_faction": "korea",
	"chu": "china",
	"wei": "china",
	"shu": "china",
	"wu": "china",
	"oda": "japan",
	"toyotomi": "japan",
	"kyushu_faction": "japan",
	"tokugawa": "japan",
	"mongol_faction": "mongol",
}
const HERO_BATTLE_TOAST_ICON_FALLBACK := "skill_unknown"

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
var _post_battle_result_card: PanelContainer
var _post_battle_result_title_label: Label
var _post_battle_result_detail_label: Label
var _last_invasion_result_summary: Dictionary = {}
var _save_management_title_label: Label
var _save_management_status_label: Label
var _save_management_status := ""
var _player_attack_deployment_panel: Node = null
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
var _city_runtime_states: Dictionary = {}
var _hero_runtime_states: Dictionary = {}
var _player_state := {
	"player_faction_id": "player",
	"ruler_current_city_id": "hanseong",
	"selected_city_id": "hanseong",
	"origin_city_id": "hanseong",
	"owned_city_ids": ["hanseong"],
	"owned_hero_ids": ["yi_sun_sin", "jeong_do_jeon", "kwon_yul", "cheok_jun_gyeong"],
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
	"faction_relations": {},
	"last_inter_faction_trade_result": {},
	"last_supply_state_result": {},
	"last_public_support_result": {},
	"last_seasonal_loyalty_result": {},
	"last_conscription_result": {},
	"last_recruitment_result": {},
	"last_revolt_warning_result": {},
	"national_tech": {"completed": {}, "in_progress": {}, "available_cache": {}},
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
	_connect_city_info_panel_actions()
	_refresh_city_hud_data_bindings()
	city_info_panel.set_pending_invasion_event(_get_pending_invasion_event_mvp())
	_setup_left_world_controls()
	_ensure_chancellor_portrait_texture_rect()
	_setup_left_world_status_panel_layout()
	_ensure_player_attack_deployment_panel()
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
	if _is_city_owned_by_player_mvp(selected_city_id):
		_player_state["origin_city_id"] = selected_city_id
	city_info_panel.set_pending_invasion_event(_get_pending_invasion_event_mvp())
	city_info_panel.show_city(city_marker)
	_refresh_city_info_attack_action_state(city_marker.city_id)
	_refresh_left_world_status_panel()
	_refresh_unified_panel_content()


func _connect_city_info_panel_actions() -> void:
	if city_info_panel == null:
		return
	var callback := Callable(self, "_on_city_info_attack_requested")
	if city_info_panel.has_signal("attack_requested") and not city_info_panel.is_connected("attack_requested", callback):
		city_info_panel.connect("attack_requested", callback)


func _on_city_info_attack_requested(city_id: String) -> void:
	_start_player_attack_battle(city_id, "manual")


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
			var supply_state := _get_display_supply_state_for_city(city_marker.city_id)
			var troop_move_preview := _get_troop_move_preview_for_city(city_marker.city_id)
			city_detail_resource_label.text = "내부 교역로: %s\n%s" % [
				_format_internal_route_summary(city_marker),
				_format_city_supply_state_display(supply_state),
			]
			city_detail_security_label.text = _format_city_supply_adjustment_display(supply_state)
			city_detail_military_label.text = "군사 보급 판단: %s" % str(city_data.get("military", "현재 주둔군 / 목표 주둔군 placeholder"))
			city_detail_commerce_label.text = "%s\n%s" % [
				_format_city_public_support_display(city_marker.city_id),
				"%s\n%s" % [
					_format_city_loyalty_drift_display(city_marker.city_id),
					"%s\n%s" % [
						_format_city_seasonal_loyalty_display(city_marker.city_id),
						_format_city_revolt_risk_display(city_marker.city_id),
					],
				],
			]
			city_detail_rating_label.text = "%s\n%s" % [
				_format_troop_move_preview_display(troop_move_preview),
				_format_city_recruitment_conscription_display(city_marker.city_id),
			]
			city_detail_domestic_button_placeholder.text = _format_troop_move_button_text(troop_move_preview)
		CITY_DETAIL_TAB_EXTERNAL_TRADE:
			var last_trade_result: Dictionary = _player_state.get("last_inter_faction_trade_result", {})
			city_detail_resource_label.text = "대외 무역 / 세력 관계: %s" % _format_external_trade_target(city_marker)
			city_detail_security_label.text = _format_trade_result_summary(last_trade_result)
			city_detail_military_label.text = _format_trade_resource_totals_display(_get_trade_display_totals(last_trade_result))
			city_detail_commerce_label.text = _format_city_trade_route_display(city_marker.city_id, last_trade_result)
			city_detail_rating_label.text = "타국무역 탭: 마지막 세력간 무역 result 표시 전용"
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


func _get_display_supply_state_for_city(city_id: String) -> Dictionary:
	var supply_result := _calculate_all_city_supply_states()
	var city_states: Variant = supply_result.get("city_states", {})
	if city_states is Dictionary:
		var city_state: Variant = (city_states as Dictionary).get(city_id, {})
		if city_state is Dictionary:
			return city_state
	return {}


func _format_city_supply_state_display(supply_state: Dictionary) -> String:
	if supply_state.is_empty():
		return "■ 보급 상태\n최근 보급 결과 없음"
	var state_label := "isolated" if bool(supply_state.get("isolated", false)) else ("supplied" if bool(supply_state.get("supplied", false)) else "unsupplied")
	return "■ 보급 상태\n역할: %s\n상태: %s\n수입 배수: x%.2f" % [
		str(supply_state.get("role", "rear")),
		state_label,
		float(supply_state.get("income_multiplier", 1.0)),
	]


func _format_city_supply_adjustment_display(supply_state: Dictionary) -> String:
	if supply_state.is_empty():
		return "■ 보급 보정\n최근 보급 결과 없음"
	return "■ 보급 보정\n충성도: %s\n치안: %s" % [
		_format_signed_int(int(supply_state.get("loyalty_delta", 0))),
		_format_signed_int(int(supply_state.get("security_delta", 0))),
	]


func _format_city_loyalty_drift_display(city_id: String) -> String:
	var drift_result: Dictionary = _player_state.get("last_city_loyalty_drift_result", {})
	var city_drift := _get_city_loyalty_drift_entry(city_id, drift_result)
	if city_drift.is_empty():
		return "■ 충성도 변화\n최근 충성도 변화 기록 없음"
	var reasons: Array = city_drift.get("reasons", [])
	var reason_text := " / ".join(_string_array_from_variant_array(reasons))
	if reason_text.is_empty():
		reason_text = "요인 없음"
	return "■ 충성도 변화\n최근 변화: %s\n세금: %s · 치안: %s · 경제: %s\n군사: %s · 보급: %s · 보급치안: %s · 통제: %s\n요인: %s" % [
		_format_signed_int(int(city_drift.get("delta", 0))),
		_format_signed_int(int(city_drift.get("tax_delta", 0))),
		_format_signed_int(int(city_drift.get("security_delta", 0))),
		_format_signed_int(int(city_drift.get("economy_delta", 0))),
		_format_signed_int(int(city_drift.get("military_burden_delta", 0))),
		_format_signed_int(int(city_drift.get("supply_delta", 0))),
		_format_signed_int(int(city_drift.get("supply_security_delta", 0))),
		_format_signed_int(int(city_drift.get("control_delta", 0))),
		reason_text,
	]


func _format_city_public_support_display(city_id: String) -> String:
	var value := _get_city_public_support(city_id)
	var result: Dictionary = _player_state.get("last_public_support_result", {})
	var city_results: Variant = result.get("city_results", {})
	if not city_results is Dictionary or not (city_results as Dictionary).has(city_id):
		return "■ 민심\n민심: %d\n최근 민심 변화 기록 없음" % value
	var city_result: Variant = (city_results as Dictionary).get(city_id, {})
	if not city_result is Dictionary:
		return "■ 민심\n민심: %d\n최근 민심 변화 기록 없음" % value
	var support_result := city_result as Dictionary
	var reasons: Array = support_result.get("reasons", [])
	var reason_text := " / ".join(_string_array_from_variant_array(reasons))
	if reason_text.is_empty():
		reason_text = "요인 없음"
	return "■ 민심\n민심: %d (%s)\n사유: 세율 %s, 식량 %s, 상업 %s, 보급 %s\n요인: %s" % [
		int(support_result.get("after", value)),
		_format_signed_int(int(support_result.get("delta", 0))),
		_format_signed_int(int(support_result.get("tax_delta", 0))),
		_format_signed_int(int(support_result.get("food_delta", 0))),
		_format_signed_int(int(support_result.get("commerce_delta", 0))),
		_format_signed_int(int(support_result.get("supply_delta", 0))),
		reason_text,
	]


func _format_city_seasonal_loyalty_display(city_id: String) -> String:
	var result: Dictionary = _player_state.get("last_seasonal_loyalty_result", {})
	if result.is_empty():
		return "■ 계절 충성도\n다음 계절 반영 대기"
	if not bool(result.get("applied", false)):
		var next_turn := _get_next_seasonal_loyalty_turn(maxi(1, int(result.get("turn", _player_state.get("turn_number", 1)))))
		return "■ 계절 충성도\n비계절 턴 · 다음 반영: %d턴" % next_turn
	var city_results: Variant = result.get("city_results", {})
	if not city_results is Dictionary or not (city_results as Dictionary).has(city_id):
		return "■ 계절 충성도\n이번 계절 반영 기록 없음"
	var city_result: Variant = (city_results as Dictionary).get(city_id, {})
	if not city_result is Dictionary:
		return "■ 계절 충성도\n이번 계절 반영 기록 없음"
	var seasonal_result := city_result as Dictionary
	return "■ 계절 충성도\n민심 %d → 충성도 %s\n%d → %d" % [
		int(seasonal_result.get("publicSupport", _get_city_public_support(city_id))),
		_format_signed_int(int(seasonal_result.get("delta", 0))),
		int(seasonal_result.get("before_loyalty", 0)),
		int(seasonal_result.get("after_loyalty", 0)),
	]


func _format_city_recruitment_conscription_display(city_id: String) -> String:
	var conscription_capacity := _get_conscription_capacity_by_loyalty(city_id)
	var conscription_available := _get_city_conscription_available(city_id)
	var conscription_expected := mini(conscription_available, 100)
	var recruitment_limit := _get_recruitment_limit_by_public_support(city_id)
	var sample_amount := 100 if recruitment_limit >= 100 else 0
	var sample_cost := _calculate_recruitment_cost(sample_amount)
	var cost_text := "모병 불가" if sample_amount <= 0 else "100명: 금전 %d + 식량 %d" % [
		int(sample_cost.get("gold", 0)),
		int(sample_cost.get("food", 0)),
	]
	var last_conscription: Dictionary = _player_state.get("last_conscription_result", {})
	var city_results: Variant = last_conscription.get("city_results", {})
	var last_added := 0
	if city_results is Dictionary and (city_results as Dictionary).has(city_id):
		var city_result: Variant = (city_results as Dictionary).get(city_id, {})
		if city_result is Dictionary:
			last_added = int((city_result as Dictionary).get("added", 0))
	return "■ 징병/모병 MVP\n징병 한계: %d · 가능 %d · 턴당 예상 +%d\n최근 자동 징병: +%d\n모병 1회 한계: %d · 비용 %s\n식량 차감: 쌀 → 보리 → 수산물" % [
		conscription_capacity,
		conscription_available,
		conscription_expected,
		last_added,
		recruitment_limit,
		cost_text,
	]


func _format_city_revolt_risk_display(city_id: String) -> String:
	var risk_result := _get_last_or_current_city_revolt_risk(city_id)
	var risk := str(risk_result.get("risk", REVOLT_RISK_STABLE))
	var risk_label := _format_revolt_risk_label(risk)
	var reasons: Array = risk_result.get("reasons", [])
	var reason_text := " / ".join(_string_array_from_variant_array(reasons))
	if reason_text.is_empty():
		reason_text = "요인 없음"
	return "■ 반란 위험\n반란 위험: %s — 민심 %d, 충성도 %d\n요인: %s" % [
		risk_label,
		int(risk_result.get("publicSupport", _get_city_public_support(city_id))),
		int(risk_result.get("loyalty", _get_city_loyalty_value(_get_city_hud_entry(city_id)))),
		reason_text,
	]


func _get_last_or_current_city_revolt_risk(city_id: String) -> Dictionary:
	var result: Dictionary = _player_state.get("last_revolt_warning_result", {})
	var city_results: Variant = result.get("city_results", {})
	if city_results is Dictionary and (city_results as Dictionary).has(city_id):
		var city_result: Variant = (city_results as Dictionary).get(city_id, {})
		if city_result is Dictionary:
			return city_result as Dictionary
	return _calculate_city_revolt_risk(city_id)


func _format_revolt_risk_label(risk: String) -> String:
	match risk:
		REVOLT_RISK_DANGER:
			return "위험"
		REVOLT_RISK_WARNING:
			return "경고"
		_:
			return "안정"


func _get_city_loyalty_drift_entry(city_id: String, drift_result: Dictionary) -> Dictionary:
	var cities: Variant = drift_result.get("cities", [])
	if not cities is Array:
		return {}
	for city_drift_variant in cities:
		if not city_drift_variant is Dictionary:
			continue
		var city_drift := city_drift_variant as Dictionary
		if str(city_drift.get("city_id", "")) == city_id:
			return city_drift
	return {}


func _string_array_from_variant_array(values: Array) -> Array[String]:
	var result: Array[String] = []
	for value in values:
		var text := str(value)
		if not text.is_empty():
			result.append(text)
	return result


func _get_trade_display_totals(result: Dictionary) -> Dictionary:
	var applied_totals: Variant = result.get("applied_player_totals", {})
	if applied_totals is Dictionary and not (applied_totals as Dictionary).is_empty():
		return applied_totals
	var player_totals: Variant = result.get("player_totals", {})
	if player_totals is Dictionary:
		return player_totals
	return {}


func _format_trade_result_summary(result: Dictionary) -> String:
	if result.is_empty():
		return "■ 무역\n최근 무역 결과 없음"
	return "■ 무역\n최근 세력간 무역: 루트 %d개\n%s" % [
		int(result.get("route_count", 0)),
		_format_trade_resource_totals_display(_get_trade_display_totals(result)),
	]


func _format_trade_resource_totals_display(totals: Dictionary) -> String:
	var parts: Array[String] = []
	for resource_id in ["gold", "rice", "barley", "seafood", "salt"]:
		var delta := int(totals.get(resource_id, 0))
		parts.append("%s %s" % [str(RESOURCE_LABELS.get(resource_id, resource_id)), _format_signed_int(delta)])
	return " / ".join(parts)


func _format_city_trade_route_display(_city_id: String, result: Dictionary) -> String:
	if result.is_empty():
		return "■ 무역 루트\n최근 무역 결과 없음"
	var routes: Variant = result.get("routes", [])
	if not routes is Array:
		return "■ 무역 루트\n최근 무역 결과 없음"
	var route_list := routes as Array
	var max_route_count := 3
	var display_routes := route_list.slice(0, mini(max_route_count, route_list.size()))
	var lines: Array[String] = []
	for route_variant in display_routes:
		if not route_variant is Dictionary:
			continue
		var route := route_variant as Dictionary
		var city_a_id := str(route.get("city_a_id", ""))
		var city_b_id := str(route.get("city_b_id", ""))
		lines.append("%s-%s\n금전 %s / 쌀 %s / 보리 %s\n수산 %s / 소금 %s" % [
			_format_city_name_by_id(city_a_id, city_a_id),
			_format_city_name_by_id(city_b_id, city_b_id),
			_format_signed_int(int(route.get("gold", 0))),
			_format_signed_int(int(route.get("rice", 0))),
			_format_signed_int(int(route.get("barley", 0))),
			_format_signed_int(int(route.get("seafood", 0))),
			_format_signed_int(int(route.get("salt", 0))),
		])
	if lines.is_empty():
		return "■ 무역 루트\n최근 무역 결과 없음"
	var remaining_count := maxi(0, route_list.size() - display_routes.size())
	var suffix := "\n외 %d개" % remaining_count if remaining_count > 0 else ""
	return "■ 무역 루트\n%s%s" % ["\n".join(lines), suffix]


func _get_troop_move_preview_for_city(from_id: String) -> Dictionary:
	if from_id.is_empty():
		return {"ok": false, "reason": "ownership", "message": "도시를 선택하십시오."}
	var amount := _get_troop_move_default_amount(from_id)
	var target_id := _get_default_troop_move_target_city(from_id, amount)
	if target_id.is_empty():
		return {
			"ok": false,
			"reason": "no_supply_path",
			"from": from_id,
			"amount": amount,
			"message": "보급 경로로 연결된 이동 대상 도시가 없습니다.",
		}
	var validation := _can_move_troops(from_id, target_id, amount)
	validation["from"] = from_id
	validation["to"] = target_id
	validation["amount"] = amount
	return validation


func _get_troop_move_default_amount(from_id: String) -> int:
	var movable := maxi(0, _get_city_troops_for_battle_context(from_id) - _get_city_min_garrison(from_id))
	return mini(100, movable)


func _get_default_troop_move_target_city(from_id: String, amount: int) -> String:
	var owned_city_ids: Variant = _player_state.get("owned_city_ids", [])
	if not owned_city_ids is Array:
		return ""
	var fallback_connected_city_id := ""
	for city_id_variant in owned_city_ids:
		var to_id := str(city_id_variant)
		if to_id.is_empty() or to_id == from_id:
			continue
		if not _is_city_owned_by_player_mvp(to_id):
			continue
		if not _is_supply_path_between(from_id, to_id):
			continue
		if fallback_connected_city_id.is_empty():
			fallback_connected_city_id = to_id
		if bool(_can_move_troops(from_id, to_id, amount).get("ok", false)):
			return to_id
	return fallback_connected_city_id


func _format_troop_move_preview_display(preview: Dictionary) -> String:
	var from_id := str(preview.get("from", ""))
	var to_id := str(preview.get("to", ""))
	if bool(preview.get("ok", false)):
		var commanded_amount := int(preview.get("amount", 0))
		var from_loyalty := _get_city_loyalty_value(_get_city_hud_entry(from_id))
		var expected_arrived := _calculate_troop_move_arrived_amount(commanded_amount, from_loyalty)
		var expected_lost := maxi(0, commanded_amount - expected_arrived)
		return "■ 수동 병력 이동\n%s → %s\n명령: %d명 · 예상 도착 %d명 · 이탈 %d명\n최소 잔류 %d명" % [
			_format_city_name_by_id(from_id, from_id),
			_format_city_name_by_id(to_id, to_id),
			commanded_amount,
			expected_arrived,
			expected_lost,
			int(preview.get("min_keep", 0)),
		]
	return "■ 수동 병력 이동\n이동 불가: %s" % _format_troop_move_reason(preview)


func _format_troop_move_button_text(preview: Dictionary) -> String:
	if bool(preview.get("ok", false)):
		return "병력 %d 이동" % int(preview.get("amount", 0))
	return "병력 이동 불가"


func _format_troop_move_reason(result: Dictionary) -> String:
	var reason := str(result.get("reason", ""))
	match reason:
		"amount":
			return "이동 병력이 1 이상이어야 합니다."
		"ownership":
			return "출발/도착 도시가 모두 플레이어 소유여야 합니다."
		"same_city":
			return "같은 도시로는 이동할 수 없습니다."
		"not_peacetime":
			return "전투/침공 예약 중에는 이동할 수 없습니다."
		"no_supply_path":
			return "두 도시 사이에 아군 보급 경로가 없습니다."
		"min_garrison":
			return "출발 도시 최소 잔류 병력을 유지해야 합니다."
		_:
			var message := str(result.get("message", ""))
			return message if not message.is_empty() else "이동 조건을 만족하지 않습니다."


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
	_setup_post_battle_result_ui()
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


func _setup_post_battle_result_ui() -> void:
	if _post_battle_result_card != null:
		return
	var parent := world_status_hint_label.get_parent()
	if parent == null:
		return
	_post_battle_result_card = PanelContainer.new()
	_post_battle_result_card.name = "PostBattleResultCard"
	_post_battle_result_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.06, 0.09, 0.12, 0.94)
	panel_style.border_color = Color(0.62, 0.78, 0.96, 0.72)
	panel_style.set_border_width_all(1)
	panel_style.set_corner_radius_all(4)
	panel_style.content_margin_left = 9.0
	panel_style.content_margin_top = 8.0
	panel_style.content_margin_right = 9.0
	panel_style.content_margin_bottom = 8.0
	_post_battle_result_card.add_theme_stylebox_override("panel", panel_style)
	parent.add_child(_post_battle_result_card)
	parent.move_child(_post_battle_result_card, world_status_hint_label.get_index())

	var content := VBoxContainer.new()
	content.name = "PostBattleResultContent"
	content.add_theme_constant_override("separation", 5)
	_post_battle_result_card.add_child(content)

	var eyebrow_label := Label.new()
	eyebrow_label.name = "PostBattleResultEyebrowLabel"
	eyebrow_label.text = "Battle Result"
	eyebrow_label.add_theme_color_override("font_color", Color(0.72, 0.86, 1.0, 1.0))
	eyebrow_label.add_theme_font_size_override("font_size", 10)
	content.add_child(eyebrow_label)

	_post_battle_result_title_label = Label.new()
	_post_battle_result_title_label.name = "PostBattleResultTitleLabel"
	_post_battle_result_title_label.add_theme_color_override("font_color", Color(0.96, 0.92, 0.78, 1.0))
	_post_battle_result_title_label.add_theme_font_size_override("font_size", 14)
	content.add_child(_post_battle_result_title_label)

	_post_battle_result_detail_label = Label.new()
	_post_battle_result_detail_label.name = "PostBattleResultDetailLabel"
	_post_battle_result_detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_post_battle_result_detail_label.add_theme_color_override("font_color", Color(0.92, 0.94, 0.96, 1.0))
	_post_battle_result_detail_label.add_theme_font_size_override("font_size", 11)
	content.add_child(_post_battle_result_detail_label)
	_post_battle_result_card.visible = false


func _ensure_player_attack_deployment_panel() -> void:
	if _player_attack_deployment_panel != null:
		return
	var worldmap_ui := get_node_or_null("WorldMapUI") as CanvasLayer
	if worldmap_ui == null:
		return
	_player_attack_deployment_panel = PlayerAttackDeploymentPanelScript.new()
	_player_attack_deployment_panel.name = "PlayerAttackDeploymentPanel"
	worldmap_ui.add_child(_player_attack_deployment_panel)
	var confirm_callback := Callable(self, "_on_player_attack_deployment_confirmed")
	if _player_attack_deployment_panel.has_signal("deployment_confirmed") and not _player_attack_deployment_panel.is_connected("deployment_confirmed", confirm_callback):
		_player_attack_deployment_panel.connect("deployment_confirmed", confirm_callback)
	var cancel_callback := Callable(self, "_on_player_attack_deployment_cancelled")
	if _player_attack_deployment_panel.has_signal("deployment_cancelled") and not _player_attack_deployment_panel.is_connected("deployment_cancelled", cancel_callback):
		_player_attack_deployment_panel.connect("deployment_cancelled", cancel_callback)


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
	var last_trade_result: Dictionary = _player_state.get("last_inter_faction_trade_result", {})
	external_trade_label.visible = not last_trade_result.is_empty()
	external_trade_label.text = _format_inter_faction_trade_summary(last_trade_result) if external_trade_label.visible else ""
	var pending_invasion_event := _get_pending_invasion_event_mvp()
	city_info_panel.set_pending_invasion_event(pending_invasion_event)
	_refresh_city_info_attack_action_state(selected_city_id)
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
	_refresh_post_battle_result_panel()


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
	if not _player_state.has("faction_relations") or not (_player_state["faction_relations"] is Dictionary):
		_player_state["faction_relations"] = {}
	if not _player_state.has("last_inter_faction_trade_result") or not (_player_state["last_inter_faction_trade_result"] is Dictionary):
		_player_state["last_inter_faction_trade_result"] = {}
	if not _player_state.has("last_supply_state_result") or not (_player_state["last_supply_state_result"] is Dictionary):
		_player_state["last_supply_state_result"] = {}
	if not _player_state.has("last_public_support_result") or not (_player_state["last_public_support_result"] is Dictionary):
		_player_state["last_public_support_result"] = {}
	if not _player_state.has("last_seasonal_loyalty_result") or not (_player_state["last_seasonal_loyalty_result"] is Dictionary):
		_player_state["last_seasonal_loyalty_result"] = {}
	if not _player_state.has("last_conscription_result") or not (_player_state["last_conscription_result"] is Dictionary):
		_player_state["last_conscription_result"] = {}
	if not _player_state.has("last_recruitment_result") or not (_player_state["last_recruitment_result"] is Dictionary):
		_player_state["last_recruitment_result"] = {}
	if not _player_state.has("last_revolt_warning_result") or not (_player_state["last_revolt_warning_result"] is Dictionary):
		_player_state["last_revolt_warning_result"] = {}
	_ensure_national_tech_state()


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


func _show_post_battle_result_summary(summary: Dictionary) -> void:
	_last_invasion_result_summary = summary.duplicate(true)
	_refresh_post_battle_result_panel()
	var lines: Array = summary.get("message_lines", [])
	print("[INVASION_RESULT_PANEL] result=%s city=%s title=%s lines=%s" % [
		str(summary.get("result", "")),
		str(summary.get("city_id", "")),
		str(summary.get("message_title", "")),
		str(lines)
	])


func _clear_post_battle_result_summary() -> void:
	_last_invasion_result_summary.clear()
	_refresh_post_battle_result_panel()


func _refresh_post_battle_result_panel() -> void:
	if _post_battle_result_card == null:
		return
	if _last_invasion_result_summary.is_empty():
		_post_battle_result_card.visible = false
		return
	var title := str(_last_invasion_result_summary.get("message_title", "전투 결과"))
	var lines: Array = _last_invasion_result_summary.get("message_lines", [])
	_post_battle_result_card.visible = true
	if _post_battle_result_title_label != null:
		_post_battle_result_title_label.text = title
	if _post_battle_result_detail_label != null:
		_post_battle_result_detail_label.text = "\n".join(_limit_invasion_result_lines(lines, 6))


func _limit_invasion_result_lines(lines: Array, limit: int) -> Array[String]:
	var result: Array[String] = []
	var safe_limit := maxi(1, limit)
	for line_variant in lines:
		if result.size() >= safe_limit:
			break
		var line := str(line_variant)
		if line.is_empty():
			continue
		result.append(line)
	return result


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


func _get_player_attack_block_reason(target_city_id: String) -> String:
	if target_city_id.is_empty() or not _has_city_for_battle_context(target_city_id):
		return "공격할 수 없는 도시입니다."
	if _has_pending_invasion_event_mvp():
		return "현재 처리 중인 침공 이벤트가 있어 공격할 수 없습니다."
	if _enemy_turn_mvp_pending or _normalize_turn_phase(str(_player_state.get("turn_phase", TURN_PHASE_PLAYER))) != TURN_PHASE_PLAYER:
		return "아군 턴에만 공격할 수 있습니다."
	if not _is_city_owned_by_enemy_mvp(target_city_id):
		return "적 도시만 공격할 수 있습니다."
	var source_city_id := _find_player_attack_source_city(target_city_id)
	if source_city_id.is_empty():
		return "인접한 아군 도시가 없습니다."
	if _get_available_player_attack_main_hero_ids(source_city_id).is_empty():
		return "출전 가능한 장수가 없습니다."
	var source_troops := _get_city_troops_for_battle_context(source_city_id)
	if source_troops <= PLAYER_ATTACK_MIN_SOURCE_CITY_TROOPS:
		return "출발 도시에 남길 병력이 부족합니다."
	return ""


func _can_player_attack_city(target_city_id: String) -> bool:
	return _get_player_attack_block_reason(target_city_id).is_empty()


func _find_player_attack_source_city(target_city_id: String) -> String:
	if target_city_id.is_empty() or not _has_city_for_battle_context(target_city_id):
		return ""
	var target_neighbors := _get_city_neighbors_mvp(target_city_id)
	var selected_source_id := str(_player_state.get("origin_city_id", ""))
	if selected_source_id.is_empty():
		selected_source_id = selected_city_id
	if not selected_source_id.is_empty() and target_neighbors.has(selected_source_id) and _is_city_owned_by_player_mvp(selected_source_id):
		return selected_source_id
	for neighbor_id in target_neighbors:
		if _is_city_owned_by_player_mvp(str(neighbor_id)):
			return str(neighbor_id)
	return ""


func _find_nearest_player_owned_neighbor_city_mvp(city_id: String) -> String:
	if city_id.is_empty():
		return ""
	for neighbor_id in _get_city_neighbors_mvp(city_id):
		var neighbor_city_id := str(neighbor_id)
		if _is_city_owned_by_player_mvp(neighbor_city_id):
			return neighbor_city_id
	return ""


func _get_available_player_attack_main_hero_ids(source_city_id: String) -> Array[String]:
	var hero_ids: Array[String] = []
	if source_city_id.is_empty():
		return hero_ids
	for hero_id_variant in _get_city_stationed_hero_ids_for_battle_context(source_city_id):
		var hero_id := str(hero_id_variant)
		if hero_id.is_empty():
			continue
		if _is_hero_captured_for_battle(hero_id):
			print("[HERO_BATTLE_EXCLUDE] source=%s city=%s hero=%s reason=%s" % [
				PLAYER_ATTACK_CONTEXT_SOURCE,
				source_city_id,
				hero_id,
				_get_hero_battle_exclusion_reason(hero_id)
			])
			continue
		hero_ids.append(hero_id)
	return hero_ids


func _refresh_city_info_attack_action_state(city_id: String = "") -> void:
	if city_info_panel == null:
		return
	var target_city_id := city_id if not city_id.is_empty() else selected_city_id
	var block_reason := _get_player_attack_block_reason(target_city_id)
	var enabled := block_reason.is_empty()
	var hint := ""
	if enabled:
		var source_city_id := _find_player_attack_source_city(target_city_id)
		hint = "%s에서 %s 공격 가능" % [
			_format_city_name_by_id(source_city_id, "인접 아군 도시"),
			_format_city_name_by_id(target_city_id, "대상 도시")
		]
	else:
		hint = block_reason
	if city_info_panel.has_method("set_attack_action_state"):
		city_info_panel.call("set_attack_action_state", enabled, hint)


func _start_player_attack_battle(target_city_id: String, mode: String = "manual") -> void:
	var block_reason := _get_player_attack_block_reason(target_city_id)
	if not block_reason.is_empty():
		_set_save_management_status(block_reason)
		_refresh_city_info_attack_action_state(target_city_id)
		_refresh_left_world_status_panel()
		return
	var source_city_id := _find_player_attack_source_city(target_city_id)
	if source_city_id.is_empty():
		_set_save_management_status("인접한 아군 도시가 없습니다.")
		_refresh_city_info_attack_action_state(target_city_id)
		_refresh_left_world_status_panel()
		return
	_open_player_attack_deployment(target_city_id, mode)


func _open_player_attack_deployment(target_city_id: String, mode: String = "manual") -> void:
	var source_city_id := _find_player_attack_source_city(target_city_id)
	if source_city_id.is_empty():
		_set_save_management_status("인접한 아군 도시가 없습니다.")
		_refresh_left_world_status_panel()
		return
	var payload := _build_player_attack_deployment_payload(source_city_id, target_city_id, mode)
	if payload.is_empty():
		_set_save_management_status("출정 준비 데이터를 만들 수 없습니다.")
		_refresh_left_world_status_panel()
		return
	_ensure_player_attack_deployment_panel()
	if _player_attack_deployment_panel == null:
		_set_save_management_status("출정 준비 UI를 열 수 없습니다.")
		_refresh_left_world_status_panel()
		return
	if _player_attack_deployment_panel.has_method("open"):
		_player_attack_deployment_panel.call("open", payload)
	_set_save_management_status("%s에서 %s 공격 출정 준비" % [
		str(payload.get("source_city_name", _format_city_name_by_id(source_city_id, "아군 도시"))),
		str(payload.get("target_city_name", _format_city_name_by_id(target_city_id, "적 도시"))),
	])
	_refresh_left_world_status_panel()


func _build_player_attack_deployment_payload(source_city_id: String, target_city_id: String, mode: String = "manual") -> Dictionary:
	if source_city_id.is_empty() or target_city_id.is_empty():
		return {}
	var source_troops := _get_city_troops_for_battle_context(source_city_id)
	var max_deployable := maxi(0, source_troops - PLAYER_ATTACK_MIN_SOURCE_CITY_TROOPS)
	var heroes := _get_deployable_player_heroes_for_city(source_city_id)
	if heroes.is_empty() or max_deployable <= 0:
		return {}
	_ensure_city_supply_resource_defaults(source_city_id)
	return {
		"mode": "auto" if mode == "auto" else "manual",
		"source_city_id": source_city_id,
		"target_city_id": target_city_id,
		"source_city_name": _format_city_name_by_id(source_city_id, "아군 도시"),
		"target_city_name": _format_city_name_by_id(target_city_id, "적 도시"),
		"source_troops": source_troops,
		"max_deployable_troops": max_deployable,
		"food_available": _get_city_supply_resource_amount(source_city_id, PLAYER_ATTACK_SUPPLY_FOOD_RESOURCE_ID),
		"gold_available": _get_city_supply_resource_amount(source_city_id, PLAYER_ATTACK_SUPPLY_GOLD_RESOURCE_ID),
		"salt_available": _get_city_supply_resource_amount(source_city_id, PLAYER_ATTACK_SUPPLY_SALT_RESOURCE_ID),
		"heroes": heroes,
	}


func _get_deployable_player_heroes_for_city(city_id: String) -> Array[Dictionary]:
	var heroes: Array[Dictionary] = []
	if city_id.is_empty() or not _is_city_owned_by_player_mvp(city_id):
		return heroes
	for hero_id_variant in _get_city_stationed_hero_ids_for_battle_context(city_id):
		var hero_id := str(hero_id_variant)
		if hero_id.is_empty():
			continue
		var hero_entry := _get_hero_entry(hero_id)
		if hero_entry.is_empty():
			continue
		if _is_hero_captured_for_battle(hero_id):
			print("[PLAYER_ATTACK_DEPLOY_SKIP] city=%s hero=%s reason=%s" % [city_id, hero_id, _get_hero_battle_exclusion_reason(hero_id)])
			continue
		var command_summary := _get_hero_command_summary_for_city_mvp(hero_entry, city_id)
		var deploy_entry := {
			"hero_id": hero_id,
			"display_name": str(hero_entry.get("display_name", hero_entry.get("name", hero_id))),
			"state_badge": _get_hero_state_badge_text(hero_id),
			"current_city_id": str(hero_entry.get("current_city_id", hero_entry.get("city_id", city_id))),
			"war": int(hero_entry.get("war", hero_entry.get("attack", 0))),
			"intelligence": int(hero_entry.get("intelligence", 0)),
			"leadership": int(hero_entry.get("leadership", hero_entry.get("command", hero_entry.get("war", 0)))),
			"command_rank": str(command_summary.get("command_rank", COMMAND_RANK_OFFICER)),
			"command_label": str(command_summary.get("command_label", "군관")),
			"command_limit": int(command_summary.get("command_limit", 0)),
		}
		heroes.append(deploy_entry)
	return heroes


func _confirm_player_attack_deployment(deployment: Dictionary) -> void:
	var validation := _validate_player_attack_deployment(deployment)
	if not bool(validation.get("ok", false)):
		_set_save_management_status(str(validation.get("message", "출정 조건을 확인하십시오.")))
		_refresh_left_world_status_panel()
		return
	var source_city_id := str(deployment.get("source_city_id", ""))
	var target_city_id := str(deployment.get("target_city_id", ""))
	var selected_hero_ids: Array[String] = _normalize_hero_id_array(validation.get("selected_hero_ids", deployment.get("selected_hero_ids", [])))
	var troop_allocation: Dictionary = validation.get("attacker_troop_allocation", deployment.get("attacker_troop_allocation", {})).duplicate(true)
	var supply_cost: Dictionary = validation.get("supply_cost", deployment.get("supply_cost", {})).duplicate(true)
	var total_allocated_troops := int(validation.get("total_troops", 0))
	var source_troops_before := _get_city_troops_for_battle_context(source_city_id)
	var source_troops_after := maxi(0, source_troops_before - total_allocated_troops)
	var battle_context := _build_player_attack_battle_context(source_city_id, target_city_id, str(deployment.get("mode", "manual")), selected_hero_ids, troop_allocation, supply_cost)
	if battle_context.is_empty():
		_set_save_management_status("공격 전투 데이터 생성 실패")
		_refresh_left_world_status_panel()
		return
	battle_context["attacker_total_allocated_troops"] = total_allocated_troops
	battle_context["attacker_source_city_id"] = source_city_id
	battle_context["attacker_source_city_troops_before"] = source_troops_before
	battle_context["attacker_source_city_troops_after"] = source_troops_after
	battle_context["troop_deployed_from_city"] = true
	_set_city_runtime_troops(source_city_id, source_troops_after)
	battle_context = _apply_context_side_troop_pre_decrement_mvp(battle_context, "defender", "defender_troop_deployed_from_city")
	_pay_player_attack_supply_cost(source_city_id, supply_cost)
	if _player_attack_deployment_panel != null:
		if _player_attack_deployment_panel.has_method("close"):
			_player_attack_deployment_panel.call("close")
	_set_pending_battle_context_mvp(battle_context)
	var deploy_feedback := "%s에서 %s으로 출정합니다! 출정 병력 %d / 식량 %d, 금 %d, 소금 %d 소모" % [
		str(battle_context.get("attacker_city_name", _format_city_name_by_id(source_city_id, "아군 도시"))),
		str(battle_context.get("defender_city_name", _format_city_name_by_id(target_city_id, "적 도시"))),
		total_allocated_troops,
		int(supply_cost.get("food", 0)),
		int(supply_cost.get("gold", 0)),
		int(supply_cost.get("salt", 0)),
	]
	_set_save_management_status(deploy_feedback)
	print("[PLAYER_ATTACK_DEPLOY] %s selected=%s allocation=%s" % [
		deploy_feedback,
		str(selected_hero_ids),
		str(troop_allocation),
	])
	print("[PLAYER_ATTACK_TROOP_DEPLOY] city=%s before=%d allocated=%d after=%d" % [
		source_city_id,
		source_troops_before,
		total_allocated_troops,
		source_troops_after,
	])
	print("[PLAYER_ATTACK] start source=%s target=%s attacker_heroes=%s defender_heroes=%s" % [
		source_city_id,
		target_city_id,
		str(battle_context.get("attacker_hero_ids", [])),
		str(battle_context.get("defender_hero_ids", []))
	])
	_handoff_battle_context_to_battle_scene(battle_context)


func _validate_player_attack_deployment(deployment: Dictionary) -> Dictionary:
	var source_city_id := str(deployment.get("source_city_id", ""))
	var target_city_id := str(deployment.get("target_city_id", ""))
	var block_reason := _get_player_attack_block_reason(target_city_id)
	if not block_reason.is_empty():
		return {"ok": false, "message": block_reason}
	if source_city_id != _find_player_attack_source_city(target_city_id):
		return {"ok": false, "message": "출정 도시가 현재 공격 조건과 일치하지 않습니다."}
	var selected_hero_ids := _normalize_hero_id_array(deployment.get("selected_hero_ids", []))
	if selected_hero_ids.is_empty():
		return {"ok": false, "message": "장수를 1명 이상 선택하십시오."}
	var available_hero_ids := _get_available_player_attack_main_hero_ids(source_city_id)
	var troop_allocation: Dictionary = deployment.get("attacker_troop_allocation", {})
	var clamped_allocation := {}
	var total_troops := 0
	var remaining_garrison := maxi(0, _get_city_troops_for_battle_context(source_city_id) - PLAYER_ATTACK_MIN_SOURCE_CITY_TROOPS)
	for hero_id in selected_hero_ids:
		if not available_hero_ids.has(hero_id):
			return {"ok": false, "message": "출전 불가 장수가 포함되어 있습니다: %s" % hero_id}
		var hero_entry := _get_hero_entry(hero_id)
		var command_limit := _get_hero_command_limit_for_city_mvp(hero_entry, source_city_id)
		if command_limit <= 0:
			return {"ok": false, "message": "지휘 한계가 없는 장수가 포함되어 있습니다: %s" % hero_id}
		var requested_troops := maxi(0, int(troop_allocation.get(hero_id, 0)))
		var troop_count := mini(mini(requested_troops, command_limit), remaining_garrison)
		if troop_count <= 0:
			return {"ok": false, "message": "선택 장수마다 병력 1 이상을 배정하십시오."}
		clamped_allocation[hero_id] = troop_count
		total_troops += troop_count
		remaining_garrison = maxi(0, remaining_garrison - troop_count)
	var max_deployable := maxi(0, _get_city_troops_for_battle_context(source_city_id) - PLAYER_ATTACK_MIN_SOURCE_CITY_TROOPS)
	if total_troops <= 0 or total_troops > max_deployable:
		return {"ok": false, "message": "출정 병력은 1 이상, 도시 병력-1 이하이어야 합니다."}
	var expected_cost := _calculate_player_attack_supply_cost(total_troops)
	var supplied_cost: Dictionary = deployment.get("supply_cost", {})
	if int(supplied_cost.get("food", -1)) != int(expected_cost.get("food", 0)) \
			or int(supplied_cost.get("gold", -1)) != int(expected_cost.get("gold", 0)) \
			or int(supplied_cost.get("salt", -1)) != int(expected_cost.get("salt", 0)):
		return {"ok": false, "message": "보급 비용 preview가 현재 병력 배정과 일치하지 않습니다."}
	if not _can_pay_player_attack_supply_cost(source_city_id, expected_cost):
		return {"ok": false, "message": "식량/금/소금이 부족합니다."}
	return {
		"ok": true,
		"message": "출정 가능",
		"total_troops": total_troops,
		"selected_hero_ids": selected_hero_ids,
		"attacker_troop_allocation": clamped_allocation,
		"supply_cost": expected_cost,
	}


func _calculate_player_attack_supply_cost(total_troops: int) -> Dictionary:
	var troop_total := maxi(0, int(total_troops))
	var gold_cost := int(ceil(float(troop_total) * PLAYER_ATTACK_SUPPLY_GOLD_RATE))
	var salt_cost := int(ceil(float(troop_total) * PLAYER_ATTACK_SUPPLY_SALT_RATE))
	return {
		"food": troop_total,
		"gold": gold_cost,
		"salt": salt_cost,
		PLAYER_ATTACK_SUPPLY_FOOD_RESOURCE_ID: troop_total,
	}


func _can_pay_player_attack_supply_cost(_source_city_id: String, supply_cost: Dictionary) -> bool:
	_ensure_city_supply_resource_defaults(_source_city_id)
	return _get_city_supply_resource_amount(_source_city_id, PLAYER_ATTACK_SUPPLY_FOOD_RESOURCE_ID) >= int(supply_cost.get("food", 0)) \
		and _get_city_supply_resource_amount(_source_city_id, PLAYER_ATTACK_SUPPLY_GOLD_RESOURCE_ID) >= int(supply_cost.get("gold", 0)) \
		and _get_city_supply_resource_amount(_source_city_id, PLAYER_ATTACK_SUPPLY_SALT_RESOURCE_ID) >= int(supply_cost.get("salt", 0))


func _pay_player_attack_supply_cost(source_city_id: String, supply_cost: Dictionary) -> void:
	_ensure_city_supply_resource_defaults(source_city_id)
	var city_data := _get_mutable_city_runtime_state(source_city_id)
	var resource_stock: Dictionary = city_data.get("resource_stock", {}).duplicate(true)
	var before_stock := resource_stock.duplicate(true)
	resource_stock[PLAYER_ATTACK_SUPPLY_FOOD_RESOURCE_ID] = maxi(0, int(resource_stock.get(PLAYER_ATTACK_SUPPLY_FOOD_RESOURCE_ID, 0)) - maxi(0, int(supply_cost.get("food", 0))))
	resource_stock[PLAYER_ATTACK_SUPPLY_GOLD_RESOURCE_ID] = maxi(0, int(resource_stock.get(PLAYER_ATTACK_SUPPLY_GOLD_RESOURCE_ID, 0)) - maxi(0, int(supply_cost.get("gold", 0))))
	resource_stock[PLAYER_ATTACK_SUPPLY_SALT_RESOURCE_ID] = maxi(0, int(resource_stock.get(PLAYER_ATTACK_SUPPLY_SALT_RESOURCE_ID, 0)) - maxi(0, int(supply_cost.get("salt", 0))))
	city_data["resource_stock"] = resource_stock
	_city_runtime_states[source_city_id] = city_data
	_refresh_city_hud_data_bindings()
	_refresh_left_world_status_panel()
	print("[PLAYER_ATTACK_SUPPLY_PAY] source_city=%s cost=%s before=%s after=%s" % [source_city_id, str(supply_cost), str(before_stock), str(resource_stock)])


func _ensure_city_supply_resource_defaults(city_id: String) -> void:
	if city_id.is_empty():
		return
	var city_data := _get_mutable_city_runtime_state(city_id)
	if city_data.is_empty():
		return
	var resource_stock: Dictionary = {}
	var raw_stock: Variant = city_data.get("resource_stock", {})
	if raw_stock is Dictionary:
		resource_stock = (raw_stock as Dictionary).duplicate(true)
	var defaults := {
		PLAYER_ATTACK_SUPPLY_FOOD_RESOURCE_ID: 10000,
		PLAYER_ATTACK_SUPPLY_GOLD_RESOURCE_ID: 3000,
		PLAYER_ATTACK_SUPPLY_SALT_RESOURCE_ID: 1000,
	}
	var changed := false
	for resource_id in defaults.keys():
		var resource_key := str(resource_id)
		if not resource_stock.has(resource_key):
			resource_stock[resource_key] = int(defaults.get(resource_key, 0))
			changed = true
	if changed:
		city_data["resource_stock"] = resource_stock
		_city_runtime_states[city_id] = city_data
		_refresh_city_hud_data_bindings()
		print("[PLAYER_ATTACK_SUPPLY_DEFAULT] city=%s resources=%s" % [city_id, str(resource_stock)])


func _get_city_supply_resource_amount(city_id: String, resource_id: String) -> int:
	_ensure_city_supply_resource_defaults(city_id)
	var city_data := _get_city_hud_entry(city_id)
	var resource_stock: Dictionary = city_data.get("resource_stock", {})
	return maxi(0, int(resource_stock.get(resource_id, 0)))


func _on_player_attack_deployment_confirmed(deployment: Dictionary) -> void:
	if str(deployment.get("deployment_type", "attack")) == "defense":
		_confirm_defense_deployment(deployment)
		return
	_confirm_player_attack_deployment(deployment)


func _on_player_attack_deployment_cancelled() -> void:
	_set_save_management_status("방어 준비 취소 · 침공 이벤트 유지" if _has_pending_invasion_event_mvp() else "출정 준비 취소")
	_refresh_left_world_status_panel()


func _create_pending_invasion_event_mvp(attacker_city_id: String, defender_city_id: String) -> Dictionary:
	if attacker_city_id.is_empty() or defender_city_id.is_empty():
		return {}
	_clear_post_battle_result_summary()
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
	_open_defense_deployment_panel_from_pending_invasion("manual")


func _on_auto_defense_pressed() -> void:
	_open_defense_deployment_panel_from_pending_invasion("auto")


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
	battle_context = _apply_context_side_troop_pre_decrement_mvp(battle_context, "attacker", "attacker_troop_deployed_from_city")
	battle_context = _apply_context_side_troop_pre_decrement_mvp(battle_context, "defender", "defender_troop_deployed_from_city")
	_set_pending_battle_context_mvp(battle_context)
	if normalized_mode == "auto":
		_set_save_management_status("자동 방어 전투 데이터 준비 완료 · 자동 해결은 아직 미구현")
	else:
		_set_save_management_status("수동 방어 전투 데이터 준비 완료 · 다음 단계에서 전투 화면으로 이동")
	_refresh_left_world_status_panel()
	return battle_context


func _open_defense_deployment_panel_from_pending_invasion(mode: String = "manual") -> void:
	var normalized_mode := "auto" if mode == "auto" else "manual"
	var event := _get_pending_invasion_event_mvp()
	var payload := _build_defense_deployment_payload(event, normalized_mode)
	if payload.is_empty():
		_set_save_management_status("방어 준비 패널 생성 실패")
		_refresh_left_world_status_panel()
		return
	_ensure_player_attack_deployment_panel()
	if _player_attack_deployment_panel == null:
		_set_save_management_status("방어 준비 패널을 찾을 수 없습니다.")
		_refresh_left_world_status_panel()
		return
	if _player_attack_deployment_panel.has_method("open"):
		_player_attack_deployment_panel.call("open", payload)
	_set_save_management_status("%s의 침공을 %s에서 방어 준비" % [
		str(payload.get("target_city_name", "침공 도시")),
		str(payload.get("source_city_name", "방어 도시")),
	])
	_refresh_left_world_status_panel()


func _build_defense_deployment_payload(event: Dictionary, mode: String) -> Dictionary:
	var validation := _validate_pending_invasion_event_for_battle_context(event)
	if not bool(validation.get("ok", false)):
		return {}
	var attacker_city_id := str(event.get("attacker_city_id", ""))
	var defender_city_id := str(event.get("defender_city_id", ""))
	var defender_troops := _get_city_troops_for_battle_context(defender_city_id)
	var max_deployable := maxi(0, defender_troops - PLAYER_ATTACK_MIN_SOURCE_CITY_TROOPS)
	var heroes := _get_deployable_player_heroes_for_city(defender_city_id)
	if heroes.is_empty() or max_deployable <= 0:
		return {}
	return {
		"deployment_type": "defense",
		"mode": "auto" if mode == "auto" else "manual",
		"source_city_id": defender_city_id,
		"target_city_id": attacker_city_id,
		"source_city_name": _format_city_name_by_id(defender_city_id, "방어 도시"),
		"target_city_name": _format_city_name_by_id(attacker_city_id, "침공 도시"),
		"source_troops": defender_troops,
		"max_deployable_troops": max_deployable,
		"food_available": 0,
		"gold_available": 0,
		"salt_available": 0,
		"heroes": heroes,
	}


func _confirm_defense_deployment(deployment: Dictionary) -> void:
	var validation := _validate_defense_deployment(deployment)
	if not bool(validation.get("ok", false)):
		_set_save_management_status(str(validation.get("message", "방어 조건을 확인하십시오.")))
		_refresh_left_world_status_panel()
		return
	var event := _get_pending_invasion_event_mvp()
	var mode := str(deployment.get("mode", "manual"))
	var selected_hero_ids: Array[String] = _normalize_hero_id_array(validation.get("selected_hero_ids", []))
	var defender_troop_allocation: Dictionary = validation.get("defender_troop_allocation", {}).duplicate(true)
	var battle_context := _build_battle_context_from_pending_invasion(event, mode, selected_hero_ids, defender_troop_allocation)
	if battle_context.is_empty():
		_set_save_management_status("방어 전투 데이터 생성 실패")
		_refresh_left_world_status_panel()
		return
	battle_context["selected_defender_hero_ids"] = selected_hero_ids.duplicate()
	battle_context["defender_troop_allocation"] = defender_troop_allocation.duplicate(true)
	battle_context["defender_total_allocated_troops"] = int(validation.get("total_troops", 0))
	battle_context["defender_source_city_id"] = str(deployment.get("source_city_id", ""))
	battle_context = _apply_context_side_troop_pre_decrement_mvp(battle_context, "attacker", "attacker_troop_deployed_from_city")
	battle_context = _apply_context_side_troop_pre_decrement_mvp(battle_context, "defender", "defender_troop_deployed_from_city")
	if _player_attack_deployment_panel != null and _player_attack_deployment_panel.has_method("close"):
		_player_attack_deployment_panel.call("close")
	_set_pending_battle_context_mvp(battle_context)
	_set_save_management_status("%s 방어 배정 완료 · 병력 %d명" % [
		str(battle_context.get("defender_city_name", "방어 도시")),
		int(validation.get("total_troops", 0)),
	])
	print("[DEFENSE_DEPLOY] city=%s selected=%s allocation=%s" % [
		str(deployment.get("source_city_id", "")),
		str(selected_hero_ids),
		str(defender_troop_allocation),
	])
	_refresh_left_world_status_panel()
	_handoff_battle_context_to_battle_scene(battle_context)


func _validate_defense_deployment(deployment: Dictionary) -> Dictionary:
	var event := _get_pending_invasion_event_mvp()
	var validation := _validate_pending_invasion_event_for_battle_context(event)
	if not bool(validation.get("ok", false)):
		return validation
	var defender_city_id := str(event.get("defender_city_id", ""))
	var attacker_city_id := str(event.get("attacker_city_id", ""))
	if str(deployment.get("source_city_id", "")) != defender_city_id or str(deployment.get("target_city_id", "")) != attacker_city_id:
		return {"ok": false, "message": "방어 배정 도시가 현재 침공 이벤트와 일치하지 않습니다."}
	var selected_hero_ids := _normalize_hero_id_array(deployment.get("selected_hero_ids", []))
	if selected_hero_ids.is_empty():
		return {"ok": false, "message": "방어 장수를 1명 이상 선택하십시오."}
	var available_hero_ids := _get_available_player_attack_main_hero_ids(defender_city_id)
	var troop_allocation: Dictionary = deployment.get("defender_troop_allocation", deployment.get("attacker_troop_allocation", {}))
	var clamped_allocation := {}
	var total_troops := 0
	var remaining_garrison := maxi(0, _get_city_troops_for_battle_context(defender_city_id) - PLAYER_ATTACK_MIN_SOURCE_CITY_TROOPS)
	for hero_id in selected_hero_ids:
		if not available_hero_ids.has(hero_id):
			return {"ok": false, "message": "방어 출전 불가 장수가 포함되어 있습니다: %s" % hero_id}
		var hero_entry := _get_hero_entry(hero_id)
		var command_limit := _get_hero_command_limit_for_city_mvp(hero_entry, defender_city_id)
		if command_limit <= 0:
			return {"ok": false, "message": "지휘 한계가 없는 장수가 포함되어 있습니다: %s" % hero_id}
		var requested_troops := maxi(0, int(troop_allocation.get(hero_id, 0)))
		var troop_count := mini(mini(requested_troops, command_limit), remaining_garrison)
		if troop_count <= 0:
			return {"ok": false, "message": "선택 방어 장수마다 병력 1 이상을 배정하십시오."}
		clamped_allocation[hero_id] = troop_count
		total_troops += troop_count
		remaining_garrison = maxi(0, remaining_garrison - troop_count)
	var max_deployable := maxi(0, _get_city_troops_for_battle_context(defender_city_id) - PLAYER_ATTACK_MIN_SOURCE_CITY_TROOPS)
	if total_troops <= 0 or total_troops > max_deployable:
		return {"ok": false, "message": "방어 병력은 1 이상, 도시 병력-1 이하이어야 합니다."}
	return {
		"ok": true,
		"message": "방어 가능",
		"total_troops": total_troops,
		"selected_hero_ids": selected_hero_ids,
		"defender_troop_allocation": clamped_allocation,
	}


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
	if _is_player_attack_battle_result(result):
		_apply_player_attack_battle_result(result)
		return
	_apply_invasion_battle_result(result)


func _is_player_attack_battle_result(result_payload: Dictionary) -> bool:
	var source := str(result_payload.get("source", "")).to_lower()
	var result_type := str(result_payload.get("type", "")).to_lower()
	return source == PLAYER_ATTACK_CONTEXT_SOURCE or result_type.begins_with("attack")


func _apply_player_attack_battle_result(result_payload: Dictionary) -> void:
	var result_kind := _normalize_player_attack_battle_result_kind(result_payload)
	var defender_city_id := _get_invasion_result_city_id(result_payload, ["defender_city_id", "target_city_id", "city_id"])
	var attacker_city_id := _get_invasion_result_city_id(result_payload, ["attacker_city_id", "source_city_id", "origin_city_id"])
	var defender_city_name := str(result_payload.get("defender_city_name", _format_city_name_by_id(defender_city_id, "알 수 없는 적 도시")))
	var attacker_city_name := str(result_payload.get("attacker_city_name", _format_city_name_by_id(attacker_city_id, "알 수 없는 아군 도시")))
	var status_message := ""
	var result_summary: Dictionary = {}
	if defender_city_id.is_empty() or not _has_city_for_battle_context(defender_city_id):
		result_summary = _build_invasion_result_summary(INVASION_RESULT_UNKNOWN, defender_city_id, attacker_city_id, defender_city_name, attacker_city_name, "", "", {}, "공격 결과 확인 필요", [
			"공격 대상 도시 정보를 찾을 수 없어 소유권 변화는 적용하지 않았습니다.",
		])
		status_message = _format_invasion_result_status_from_summary(result_summary)
	else:
		match result_kind:
			INVASION_RESULT_ATTACKER_WIN:
				result_summary = _apply_player_attack_win_result(defender_city_id, attacker_city_id, defender_city_name, attacker_city_name, result_payload)
				status_message = _format_invasion_result_status_from_summary(result_summary)
			INVASION_RESULT_DEFENDER_WIN:
				result_summary = _apply_player_attack_loss_result(defender_city_id, attacker_city_id, defender_city_name, attacker_city_name, result_payload)
				status_message = _format_invasion_result_status_from_summary(result_summary)
			INVASION_RESULT_RETREAT:
				var current_owner := _get_city_owner_id_for_battle_context(defender_city_id)
				result_summary = _build_invasion_result_summary(result_kind, defender_city_id, attacker_city_id, defender_city_name, attacker_city_name, current_owner, current_owner, {}, "공격 종료", [
					"%s 공격이 취소/퇴각 처리되었습니다." % defender_city_name,
					"소유권 변화 없음.",
				])
				status_message = _format_invasion_result_status_from_summary(result_summary)
			_:
				var current_owner := _get_city_owner_id_for_battle_context(defender_city_id)
				result_summary = _build_invasion_result_summary(result_kind, defender_city_id, attacker_city_id, defender_city_name, attacker_city_name, current_owner, current_owner, {}, "공격 결과 확인 필요", [
					"%s 공격 결과를 해석할 수 없어 소유권 변화는 적용하지 않았습니다." % defender_city_name,
				])
				status_message = _format_invasion_result_status_from_summary(result_summary)
	if not result_summary.is_empty():
		result_summary = _apply_invasion_hero_state_placeholder(result_payload, result_summary)
		status_message = _format_invasion_result_status_from_summary(result_summary)
		_sync_worldmap_hero_locations_from_city_runtime_states()
	if not defender_city_id.is_empty():
		_select_city_after_invasion_result(defender_city_id)
	_refresh_city_info_attack_action_state(defender_city_id)
	_show_post_battle_result_summary(result_summary)
	_set_save_management_status(status_message)
	_refresh_left_world_status_panel()
	_refresh_unified_panel_content()
	print("[PLAYER_ATTACK_RESULT] result=%s attacker_city=%s defender_city=%s status=%s" % [
		result_kind,
		attacker_city_id,
		defender_city_id,
		status_message
	])


func _apply_invasion_battle_result(result_payload: Dictionary) -> void:
	var result_kind := _normalize_invasion_battle_result_kind(result_payload)
	var defender_city_id := _get_invasion_result_city_id(result_payload, ["defender_city_id", "target_city_id", "city_id"])
	var attacker_city_id := _get_invasion_result_city_id(result_payload, ["attacker_city_id", "source_city_id", "origin_city_id"])
	var defender_city_name := str(result_payload.get("defender_city_name", _format_city_name_by_id(defender_city_id, "알 수 없는 아군 도시")))
	var attacker_city_name := str(result_payload.get("attacker_city_name", _format_city_name_by_id(attacker_city_id, "알 수 없는 적 도시")))
	var status_message := ""
	var result_summary: Dictionary = {}
	if not _is_enemy_invasion_battle_result(result_payload):
		result_summary = _build_invasion_result_summary(INVASION_RESULT_UNKNOWN, defender_city_id, attacker_city_id, defender_city_name, attacker_city_name, "", "", {}, "전투 결과 확인 필요", [
			"침공전 결과가 아니므로 점령 적용 없이 정리했습니다.",
		])
		status_message = _format_invasion_result_status_from_summary(result_summary)
	elif defender_city_id.is_empty() or not _has_city_for_battle_context(defender_city_id):
		result_summary = _build_invasion_result_summary(INVASION_RESULT_UNKNOWN, defender_city_id, attacker_city_id, defender_city_name, attacker_city_name, "", "", {}, "전투 결과 확인 필요", [
			"방어 도시 정보를 찾을 수 없어 소유권 변화는 적용하지 않았습니다.",
		])
		status_message = _format_invasion_result_status_from_summary(result_summary)
	else:
		match result_kind:
			INVASION_RESULT_DEFENDER_WIN:
				result_summary = _apply_defender_win_invasion_result(defender_city_id, attacker_city_id, defender_city_name, attacker_city_name, result_payload)
				status_message = _format_invasion_result_status_from_summary(result_summary)
			INVASION_RESULT_ATTACKER_WIN:
				result_summary = _apply_attacker_win_invasion_result(defender_city_id, attacker_city_id, defender_city_name, attacker_city_name, result_payload)
				status_message = _format_invasion_result_status_from_summary(result_summary)
			INVASION_RESULT_RETREAT:
				var current_owner := _get_city_owner_id_for_battle_context(defender_city_id)
				result_summary = _build_invasion_result_summary(result_kind, defender_city_id, attacker_city_id, defender_city_name, attacker_city_name, current_owner, current_owner, {}, "전투 종료", [
					"%s 방어전이 취소/퇴각 처리되었습니다." % defender_city_name,
					"소유권 변화 없음.",
				])
				status_message = _format_invasion_result_status_from_summary(result_summary)
			_:
				var current_owner := _get_city_owner_id_for_battle_context(defender_city_id)
				result_summary = _build_invasion_result_summary(result_kind, defender_city_id, attacker_city_id, defender_city_name, attacker_city_name, current_owner, current_owner, {}, "전투 결과 확인 필요", [
					"%s 방어전 결과를 해석할 수 없어 소유권 변화는 적용하지 않았습니다." % defender_city_name,
				])
				status_message = _format_invasion_result_status_from_summary(result_summary)
	if not result_summary.is_empty():
		result_summary = _apply_invasion_hero_state_placeholder(result_payload, result_summary)
		status_message = _format_invasion_result_status_from_summary(result_summary)

	_clear_pending_invasion_event_mvp()
	_sync_worldmap_hero_locations_from_city_runtime_states()
	if not defender_city_id.is_empty():
		_select_city_after_invasion_result(defender_city_id)
	_refresh_pending_invasion_choice_ui({})
	city_info_panel.set_pending_invasion_event({})
	_refresh_left_world_status_panel()
	_refresh_unified_panel_content()
	if not result_summary.is_empty():
		_show_post_battle_result_summary(result_summary)
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


func _normalize_player_attack_battle_result_kind(result_payload: Dictionary) -> String:
	var winner := str(result_payload.get("winner", "")).to_lower()
	if ["attacker", "player", "ally"].has(winner):
		return INVASION_RESULT_ATTACKER_WIN
	if ["defender", "enemy"].has(winner):
		return INVASION_RESULT_DEFENDER_WIN
	if result_payload.has("is_player_win") and result_payload.get("is_player_win") is bool:
		return INVASION_RESULT_ATTACKER_WIN if bool(result_payload.get("is_player_win")) else INVASION_RESULT_DEFENDER_WIN
	var result_tokens: Array[String] = []
	for key in ["result", "battle_result", "outcome", "state"]:
		if result_payload.has(key):
			result_tokens.append(str(result_payload.get(key, "")).to_lower())
	for token in result_tokens:
		if ["player_win", "attacker_win", "victory", "win"].has(token):
			return INVASION_RESULT_ATTACKER_WIN
		if ["player_loss", "defender_win", "defeat", "lose", "loss"].has(token):
			return INVASION_RESULT_DEFENDER_WIN
		if ["retreat", "cancel", "cancelled", "canceled", "aborted"].has(token):
			return INVASION_RESULT_RETREAT
	return INVASION_RESULT_UNKNOWN


func _get_invasion_result_city_id(result_payload: Dictionary, keys: Array[String]) -> String:
	for key in keys:
		var city_id := str(result_payload.get(key, ""))
		if not city_id.is_empty():
			return city_id
	return ""


func _build_invasion_result_summary(
	result_kind: String,
	defender_city_id: String,
	attacker_city_id: String,
	defender_city_name: String,
	attacker_city_name: String,
	old_owner: String,
	new_owner: String,
	casualty_result: Dictionary,
	message_title: String,
	leading_lines: Array
) -> Dictionary:
	var defender_before := int(casualty_result.get("defender_before", _get_city_troops_for_battle_context(defender_city_id)))
	var defender_after := _get_city_troops_for_battle_context(defender_city_id)
	var attacker_before := int(casualty_result.get("attacker_before", _get_city_troops_for_battle_context(attacker_city_id)))
	var attacker_after := _get_city_troops_for_battle_context(attacker_city_id)
	var occupied_city_troops := int(casualty_result.get("occupied_city_troops", 0))
	var normalized_old_owner := old_owner
	var normalized_new_owner := new_owner
	if normalized_old_owner.is_empty() and not defender_city_id.is_empty():
		normalized_old_owner = _get_city_owner_id_for_battle_context(defender_city_id)
	if normalized_new_owner.is_empty():
		normalized_new_owner = normalized_old_owner
	var owner_changed := not normalized_old_owner.is_empty() and not normalized_new_owner.is_empty() and normalized_old_owner != normalized_new_owner
	var message_lines: Array[String] = []
	for line_variant in leading_lines:
		var line := str(line_variant)
		if not line.is_empty():
			message_lines.append(line)
	if owner_changed:
		message_lines.append("소유권: %s → %s" % [_format_faction_label(normalized_old_owner), _format_faction_label(normalized_new_owner)])
	else:
		var owner_label := _format_faction_label(normalized_new_owner)
		message_lines.append("소유권: 유지%s" % (" (%s)" % owner_label if not owner_label.is_empty() else ""))
	if not defender_city_id.is_empty() and _has_city_for_battle_context(defender_city_id):
		message_lines.append("도시 병력: %d → %d" % [defender_before, defender_after])
	if not attacker_city_id.is_empty() and _has_city_for_battle_context(attacker_city_id):
		message_lines.append("공격 출발지 %s 병력: %d → %d" % [attacker_city_name, attacker_before, attacker_after])
	if occupied_city_troops > 0:
		message_lines.append("점령 병력: %d" % occupied_city_troops)
	var summary := {
		"result": result_kind,
		"city_id": defender_city_id,
		"city_name": defender_city_name,
		"old_owner": normalized_old_owner,
		"new_owner": normalized_new_owner,
		"owner_changed": owner_changed,
		"defender_city_troops_before": defender_before,
		"defender_city_troops_after": defender_after,
		"attacker_source_city_id": attacker_city_id,
		"attacker_source_city_name": attacker_city_name,
		"attacker_source_troops_before": attacker_before,
		"attacker_source_troops_after": attacker_after,
		"occupied_city_troops": occupied_city_troops,
		"message_title": message_title,
		"message_lines": message_lines,
	}
	print("[INVASION_RESULT_SUMMARY] result=%s city=%s owner=%s->%s city_troops=%d->%d attacker_city=%s attacker_troops=%d->%d occupied=%d" % [
		result_kind,
		defender_city_id,
		normalized_old_owner,
		normalized_new_owner,
		defender_before,
		defender_after,
		attacker_city_id,
		attacker_before,
		attacker_after,
		occupied_city_troops
	])
	return summary


func _format_invasion_result_status_from_summary(summary: Dictionary) -> String:
	var title := str(summary.get("message_title", "전투 결과"))
	var lines: Array = summary.get("message_lines", [])
	if lines.is_empty():
		return title
	return "%s: %s" % [title, str(lines[0])]


func _apply_invasion_hero_state_placeholder(result_payload: Dictionary, result_summary: Dictionary) -> Dictionary:
	var updated_summary := result_summary.duplicate(true)
	var result_kind := str(updated_summary.get("result", _normalize_invasion_battle_result_kind(result_payload)))
	var losing_side := ""
	var losing_city_id := ""
	match result_kind:
		INVASION_RESULT_DEFENDER_WIN:
			losing_side = "attacker"
			losing_city_id = str(updated_summary.get("attacker_source_city_id", _get_invasion_result_city_id(result_payload, ["attacker_city_id", "source_city_id", "origin_city_id"])))
		INVASION_RESULT_ATTACKER_WIN:
			losing_side = "defender"
			losing_city_id = str(updated_summary.get("city_id", _get_invasion_result_city_id(result_payload, ["defender_city_id", "target_city_id", "city_id"])))
		_:
			updated_summary["hero_state_result"] = {
				"wounded_hero_ids": [],
				"captured_hero_ids": [],
				"dead_hero_ids": [],
				"skipped_hero_ids": [],
				"losing_side": losing_side,
			}
			_append_hero_state_result_lines(updated_summary)
			print("[HERO_STATE_RESULT] result=%s losing_side=%s wounded=[] captured=[] skipped=[] dead=[]" % [result_kind, losing_side])
			return updated_summary
	var losing_hero_ids := _get_city_stationed_hero_ids_for_battle_context(losing_city_id)
	var wounded_hero_ids: Array[String] = []
	var captured_hero_ids: Array[String] = []
	var skipped_hero_ids: Array[String] = []
	for hero_id_variant in losing_hero_ids:
		var hero_id := str(hero_id_variant)
		if not _is_hero_eligible_for_placeholder_state(hero_id):
			skipped_hero_ids.append(hero_id)
			print("[HERO_STATE_SKIP] result=%s side=%s hero=%s reason=already_captured_or_dead_or_missing" % [result_kind, losing_side, hero_id])
			continue
		if wounded_hero_ids.is_empty():
			if _set_hero_runtime_status_placeholder(hero_id, HERO_RUNTIME_STATUS_WOUNDED):
				wounded_hero_ids.append(hero_id)
			continue
		if captured_hero_ids.is_empty() and not wounded_hero_ids.has(hero_id):
			if _set_hero_runtime_status_placeholder(hero_id, HERO_RUNTIME_STATUS_CAPTURED):
				captured_hero_ids.append(hero_id)
			continue
		if not wounded_hero_ids.is_empty() and not captured_hero_ids.is_empty():
			break
	updated_summary["hero_state_result"] = {
		"wounded_hero_ids": wounded_hero_ids,
		"captured_hero_ids": captured_hero_ids,
		"dead_hero_ids": [],
		"skipped_hero_ids": skipped_hero_ids,
		"losing_side": losing_side,
		"losing_city_id": losing_city_id,
	}
	_append_hero_state_result_lines(updated_summary)
	print("[HERO_STATE_RESULT] result=%s losing_side=%s wounded=%s captured=%s skipped=%s dead=[]" % [
		result_kind,
		losing_side,
		str(wounded_hero_ids),
		str(captured_hero_ids),
		str(skipped_hero_ids)
	])
	return updated_summary


func _is_hero_eligible_for_placeholder_state(hero_id: String) -> bool:
	if hero_id.is_empty() or _get_hero_seed_entry(hero_id).is_empty():
		return false
	var hero_state := _normalize_hero_runtime_state(hero_id, _get_existing_hero_runtime_state(hero_id))
	return not bool(hero_state.get("captured", false)) and not bool(hero_state.get("dead", false))


func _get_existing_hero_runtime_state(hero_id: String) -> Dictionary:
	var existing_state: Variant = _hero_runtime_states.get(hero_id, {})
	if existing_state is Dictionary:
		return existing_state as Dictionary
	return {}


func _set_hero_runtime_status_placeholder(hero_id: String, status: String) -> bool:
	if hero_id.is_empty() or _get_hero_seed_entry(hero_id).is_empty():
		print("[HERO_STATE_SKIP] hero=%s status=%s reason=missing_hero" % [hero_id, status])
		return false
	var hero_state := _normalize_hero_runtime_state(hero_id, _get_existing_hero_runtime_state(hero_id))
	match status:
		HERO_RUNTIME_STATUS_WOUNDED:
			hero_state["status"] = HERO_RUNTIME_STATUS_WOUNDED
			hero_state["wounded"] = true
			hero_state["captured"] = false
			hero_state["dead"] = false
			hero_state["wounded_turns_remaining"] = DEFAULT_WOUNDED_RECOVERY_TURNS
		HERO_RUNTIME_STATUS_CAPTURED:
			hero_state["status"] = HERO_RUNTIME_STATUS_CAPTURED
			hero_state["wounded"] = false
			hero_state["captured"] = true
			hero_state["dead"] = false
			hero_state["wounded_turns_remaining"] = 0
		_:
			hero_state["status"] = HERO_RUNTIME_STATUS_NORMAL
			hero_state["wounded"] = false
			hero_state["captured"] = false
			hero_state["dead"] = false
			hero_state["wounded_turns_remaining"] = 0
	_hero_runtime_states[hero_id] = hero_state
	print("[HERO_STATE_APPLY] hero=%s status=%s wounded=%s captured=%s dead=%s wounded_turns=%d city=%s" % [
		hero_id,
		str(hero_state.get("status", HERO_RUNTIME_STATUS_NORMAL)),
		str(hero_state.get("wounded", false)),
		str(hero_state.get("captured", false)),
		str(hero_state.get("dead", false)),
		int(hero_state.get("wounded_turns_remaining", 0)),
		str(hero_state.get("current_city_id", ""))
	])
	return true


func _append_hero_state_result_lines(result_summary: Dictionary) -> void:
	var hero_state_result: Variant = result_summary.get("hero_state_result", {})
	if not hero_state_result is Dictionary:
		return
	var state_result := hero_state_result as Dictionary
	var wounded_hero_ids: Array = state_result.get("wounded_hero_ids", [])
	var captured_hero_ids: Array = state_result.get("captured_hero_ids", [])
	var message_lines: Array = result_summary.get("message_lines", [])
	if wounded_hero_ids.is_empty() and captured_hero_ids.is_empty():
		message_lines.append("장수 상태 변화 없음")
	else:
		var wounded_text := _format_hero_name_list(wounded_hero_ids) if not wounded_hero_ids.is_empty() else "없음"
		var captured_text := _format_hero_name_list(captured_hero_ids) if not captured_hero_ids.is_empty() else "없음"
		message_lines.append("장수 상태: 부상 %s / 포로 상태 %s" % [wounded_text, captured_text])
	result_summary["message_lines"] = message_lines


func _format_hero_name_list(hero_ids: Array) -> String:
	var names: Array[String] = []
	for hero_id_variant in hero_ids:
		var hero_id := str(hero_id_variant)
		var hero_data := _get_hero_entry(hero_id)
		var display_name := str(hero_data.get("display_name", hero_data.get("name", hero_id)))
		if display_name.is_empty():
			display_name = hero_id
		names.append(_get_hero_display_name_with_state(hero_id, display_name))
	return "없음" if names.is_empty() else ", ".join(names)


func _get_hero_state_badge_text(hero_id: String) -> String:
	if hero_id.is_empty():
		return ""
	var hero_state := _normalize_hero_runtime_state(hero_id, _get_existing_hero_runtime_state(hero_id))
	if bool(hero_state.get("dead", false)) or str(hero_state.get("status", "")) == HERO_RUNTIME_STATUS_DEAD:
		return " [사망]"
	if bool(hero_state.get("captured", false)) or str(hero_state.get("status", "")) == HERO_RUNTIME_STATUS_CAPTURED:
		return " [포로]"
	if bool(hero_state.get("wounded", false)) or str(hero_state.get("status", "")) == HERO_RUNTIME_STATUS_WOUNDED:
		var turns_remaining := maxi(0, int(hero_state.get("wounded_turns_remaining", 0)))
		if turns_remaining > 0:
			return " [부상 %d턴]" % turns_remaining
		return " [부상]"
	return ""


func _get_hero_display_name_with_state(hero_id: String, base_name: String) -> String:
	if hero_id.is_empty():
		return base_name
	return "%s%s" % [base_name, _get_hero_state_badge_text(hero_id)]


func _is_hero_captured_for_battle(hero_id: String) -> bool:
	if hero_id.is_empty():
		return false
	var hero_state := _normalize_hero_runtime_state(hero_id, _get_existing_hero_runtime_state(hero_id))
	var status := str(hero_state.get("status", HERO_RUNTIME_STATUS_NORMAL))
	if bool(hero_state.get("dead", false)) or status == HERO_RUNTIME_STATUS_DEAD:
		return true
	if bool(hero_state.get("captured", false)) or status == HERO_RUNTIME_STATUS_CAPTURED:
		return true
	return false


func _get_hero_battle_exclusion_reason(hero_id: String) -> String:
	var hero_state := _normalize_hero_runtime_state(hero_id, _get_existing_hero_runtime_state(hero_id))
	var status := str(hero_state.get("status", HERO_RUNTIME_STATUS_NORMAL))
	if bool(hero_state.get("dead", false)) or status == HERO_RUNTIME_STATUS_DEAD:
		return "dead"
	if bool(hero_state.get("captured", false)) or status == HERO_RUNTIME_STATUS_CAPTURED:
		return "captured"
	return ""


func _apply_defender_win_invasion_result(defender_city_id: String, attacker_city_id: String, defender_city_name: String, attacker_city_name: String, result_payload: Dictionary) -> Dictionary:
	var old_owner := _get_city_owner_id_for_battle_context(defender_city_id)
	var defender_before := _get_city_troops_for_battle_context(defender_city_id)
	var attacker_before := _get_city_troops_for_battle_context(attacker_city_id)
	var player_outcome := _get_player_troop_outcome_from_result(result_payload)
	var enemy_outcome := _get_enemy_troop_outcome_from_result(result_payload)
	var player_survivors := maxi(0, int(player_outcome.get("survivors", 0)))
	var player_wounded := maxi(0, int(player_outcome.get("wounded", 0)))
	var player_dead := maxi(0, int(player_outcome.get("dead", 0)))
	var enemy_wounded := maxi(0, int(enemy_outcome.get("wounded", 0)))
	var defender_after := defender_before + player_survivors
	_set_city_runtime_troops(defender_city_id, defender_after)
	_add_wounded_to_city_mvp(defender_city_id, player_wounded, PLAYER_ATTACK_WOUNDED_QUEUE_TURNS)
	_add_wounded_to_city_mvp(attacker_city_id, enemy_wounded, PLAYER_ATTACK_WOUNDED_QUEUE_TURNS)
	var casualty_result := {
		"defender_before": defender_before,
		"defender_remaining_troops": defender_after,
		"attacker_before": attacker_before,
		"attacker_remaining_troops": attacker_before,
		"attacker_source_remaining_troops": attacker_before,
		"occupied_city_troops": 0,
		"player_troop_outcome": player_outcome,
		"enemy_troop_outcome": enemy_outcome,
	}
	print("[INVASION_TROOP_APPLY] result=defender_win city=%s before=%d survivors=%d wounded=%d after=%d reason=defender_city_survived" % [
		defender_city_id,
		defender_before,
		player_survivors,
		player_wounded,
		defender_after
	])
	print("[INVASION_TROOP_APPLY] result=defender_win city=%s before=%d enemy_wounded=%d after=%d reason=attacker_wounded_return" % [
		attacker_city_id,
		attacker_before,
		enemy_wounded,
		_get_city_troops_for_battle_context(attacker_city_id)
	])
	return _build_invasion_result_summary(INVASION_RESULT_DEFENDER_WIN, defender_city_id, attacker_city_id, defender_city_name, attacker_city_name, old_owner, old_owner, casualty_result, "방어 성공", [
		"%s을 지켜냈습니다." % defender_city_name,
		"방어군 출전 %d / 생존 %d / 부상 %d / 전사 %d" % [
			int(player_outcome.get("allocated", 0)),
			player_survivors,
			player_wounded,
			player_dead,
		],
		"적 부상병 %d명은 %s에서 %d턴 후 회복됩니다." % [enemy_wounded, attacker_city_name, PLAYER_ATTACK_WOUNDED_QUEUE_TURNS],
	])


func _apply_attacker_win_invasion_result(defender_city_id: String, attacker_city_id: String, defender_city_name: String, attacker_city_name: String, result_payload: Dictionary) -> Dictionary:
	var old_owner := _get_city_owner_id_for_battle_context(defender_city_id)
	var attacker_owner := str(result_payload.get("attacker_owner", _get_city_owner_id_for_battle_context(attacker_city_id)))
	var defender_before_troops := _get_city_troops_for_battle_context(defender_city_id)
	var attacker_before_troops := _get_city_troops_for_battle_context(attacker_city_id)
	var player_outcome := _get_player_troop_outcome_from_result(result_payload)
	var enemy_outcome := _get_enemy_troop_outcome_from_result(result_payload)
	var enemy_survivors := maxi(0, int(enemy_outcome.get("survivors", 0)))
	var enemy_wounded := maxi(0, int(enemy_outcome.get("wounded", 0)))
	var enemy_dead := maxi(0, int(enemy_outcome.get("dead", 0)))
	var player_wounded := maxi(0, int(player_outcome.get("wounded", 0)))
	var player_dead := maxi(0, int(player_outcome.get("dead", 0)))
	var retreat_city_id := _find_nearest_player_owned_neighbor_city_mvp(defender_city_id)
	if attacker_owner.is_empty():
		return _build_invasion_result_summary(INVASION_RESULT_UNKNOWN, defender_city_id, attacker_city_id, defender_city_name, attacker_city_name, old_owner, old_owner, {}, "전투 결과 확인 필요", [
			"%s이 함락되었으나 공격 세력 정보가 없어 소유권 변화 없이 정리했습니다." % defender_city_name,
		])
	_set_city_runtime_owner(defender_city_id, attacker_owner)
	_set_city_runtime_troops(defender_city_id, enemy_survivors)
	_clear_city_wounded_queue_mvp(defender_city_id)
	_add_wounded_to_city_mvp(defender_city_id, enemy_wounded, PLAYER_ATTACK_WOUNDED_QUEUE_TURNS)
	if not retreat_city_id.is_empty():
		_add_wounded_to_city_mvp(retreat_city_id, player_wounded, PLAYER_ATTACK_WOUNDED_QUEUE_TURNS)
	else:
		print("[INVASION_TROOP_APPLY] result=attacker_win defender=%s player_wounded_lost=%d reason=no_retreat_city" % [defender_city_id, player_wounded])
	var casualty_result := {
		"defender_before": defender_before_troops,
		"defender_remaining_troops": enemy_survivors,
		"attacker_before": attacker_before_troops,
		"attacker_remaining_troops": attacker_before_troops,
		"attacker_source_remaining_troops": attacker_before_troops,
		"occupied_city_troops": enemy_survivors,
		"player_troop_outcome": player_outcome,
		"enemy_troop_outcome": enemy_outcome,
		"retreat_city_id": retreat_city_id,
	}
	print("[INVASION_TROOP_APPLY] result=attacker_win city=%s before=%d after=%d reason=occupied_city" % [
		defender_city_id,
		defender_before_troops,
		enemy_survivors
	])
	return _build_invasion_result_summary(INVASION_RESULT_ATTACKER_WIN, defender_city_id, attacker_city_id, defender_city_name, attacker_city_name, old_owner, attacker_owner, casualty_result, "도시 함락", [
		"%s이 %s에 점령되었습니다." % [defender_city_name, _format_faction_label(attacker_owner)],
		"공격군 출전 %d / 생존 %d / 부상 %d / 전사 %d" % [
			int(enemy_outcome.get("allocated", 0)),
			enemy_survivors,
			enemy_wounded,
			enemy_dead,
		],
		"방어군 부상 %d / 전사 %d%s" % [
			player_wounded,
			player_dead,
			(" · 후송지: %s" % _format_city_name_by_id(retreat_city_id, retreat_city_id)) if not retreat_city_id.is_empty() else " · 후송지 없음",
		],
	])


func _apply_player_attack_win_result(defender_city_id: String, attacker_city_id: String, defender_city_name: String, attacker_city_name: String, result_payload: Dictionary) -> Dictionary:
	var old_owner := _get_city_owner_id_for_battle_context(defender_city_id)
	var defender_before_troops := _get_city_troops_for_battle_context(defender_city_id)
	var attacker_before_troops := _get_city_troops_for_battle_context(attacker_city_id)
	var player_outcome := _get_player_troop_outcome_from_result(result_payload)
	var enemy_outcome := _get_enemy_troop_outcome_from_result(result_payload)
	var player_survivors := maxi(0, int(player_outcome.get("survivors", 0)))
	var player_wounded := maxi(0, int(player_outcome.get("wounded", 0)))
	var player_dead := maxi(0, int(player_outcome.get("dead", 0)))
	_set_city_runtime_owner(defender_city_id, PLAYER_FACTION_ID)
	_set_city_runtime_troops(defender_city_id, player_survivors)
	_clear_city_wounded_queue_mvp(defender_city_id)
	_add_wounded_to_city_mvp(defender_city_id, player_wounded, PLAYER_ATTACK_WOUNDED_QUEUE_TURNS)
	var casualty_result := {
		"defender_before": defender_before_troops,
		"defender_remaining_troops": player_survivors,
		"attacker_before": attacker_before_troops,
		"attacker_remaining_troops": attacker_before_troops,
		"attacker_source_remaining_troops": attacker_before_troops,
		"occupied_city_troops": player_survivors,
		"player_troop_outcome": player_outcome,
		"enemy_troop_outcome": enemy_outcome,
	}
	print("[PLAYER_ATTACK_RESULT] apply=attacker_win city=%s before=%d after=%d reason=occupied_by_player" % [
		defender_city_id,
		defender_before_troops,
		player_survivors
	])
	return _build_invasion_result_summary(INVASION_RESULT_ATTACKER_WIN, defender_city_id, attacker_city_id, defender_city_name, attacker_city_name, old_owner, PLAYER_FACTION_ID, casualty_result, "도시 점령", [
		"%s 점령 성공!" % defender_city_name,
		"%s의 출정군이 %s을 장악했습니다." % [attacker_city_name, defender_city_name],
		"출정 %d / 생존 %d / 부상 %d / 전사 %d" % [
			int(player_outcome.get("allocated", 0)),
			player_survivors,
			player_wounded,
			player_dead,
		],
		"생존병은 %s에 주둔, 부상병은 %d턴 후 회복됩니다." % [defender_city_name, PLAYER_ATTACK_WOUNDED_QUEUE_TURNS],
	])


func _apply_player_attack_loss_result(defender_city_id: String, attacker_city_id: String, defender_city_name: String, attacker_city_name: String, result_payload: Dictionary) -> Dictionary:
	var old_owner := _get_city_owner_id_for_battle_context(defender_city_id)
	var defender_before := _get_city_troops_for_battle_context(defender_city_id)
	var attacker_before := _get_city_troops_for_battle_context(attacker_city_id)
	var player_outcome := _get_player_troop_outcome_from_result(result_payload)
	var enemy_outcome := _get_enemy_troop_outcome_from_result(result_payload)
	var player_wounded := maxi(0, int(player_outcome.get("wounded", 0)))
	var player_dead := maxi(0, int(player_outcome.get("dead", 0)))
	var enemy_survivors := maxi(0, int(enemy_outcome.get("survivors", 0)))
	var defender_after := defender_before + enemy_survivors
	_set_city_runtime_troops(defender_city_id, defender_after)
	_add_wounded_to_city_mvp(defender_city_id, maxi(0, int(enemy_outcome.get("wounded", 0))), PLAYER_ATTACK_WOUNDED_QUEUE_TURNS)
	_add_wounded_to_city_mvp(attacker_city_id, player_wounded, PLAYER_ATTACK_WOUNDED_QUEUE_TURNS)
	var casualty_result := {
		"defender_before": defender_before,
		"defender_remaining_troops": defender_after,
		"attacker_before": attacker_before,
		"attacker_remaining_troops": attacker_before,
		"attacker_source_remaining_troops": attacker_before,
		"occupied_city_troops": 0,
		"player_troop_outcome": player_outcome,
		"enemy_troop_outcome": enemy_outcome,
	}
	print("[PLAYER_ATTACK_RESULT] apply=defender_win city=%s before=%d after=%d reason=target_defended" % [
		defender_city_id,
		defender_before,
		defender_after
	])
	return _build_invasion_result_summary(INVASION_RESULT_DEFENDER_WIN, defender_city_id, attacker_city_id, defender_city_name, attacker_city_name, old_owner, old_owner, casualty_result, "공격 실패", [
		"%s 공격 실패" % defender_city_name,
		"출정군이 패퇴했습니다.",
		"출정 %d / 부상 %d / 전사 %d" % [
			int(player_outcome.get("allocated", 0)),
			player_wounded,
			player_dead,
		],
		"부상병은 %s으로 후송되어 %d턴 후 회복됩니다." % [attacker_city_name, PLAYER_ATTACK_WOUNDED_QUEUE_TURNS],
	])


func _get_player_troop_outcome_from_result(result_payload: Dictionary) -> Dictionary:
	var raw_outcome: Variant = result_payload.get("player_troop_outcome", {})
	if raw_outcome is Dictionary:
		return (raw_outcome as Dictionary).duplicate(true)
	var allocated := maxi(0, int(result_payload.get("attacker_total_allocated_troops", result_payload.get("attacker_troops", 0))))
	var did_win := _normalize_player_attack_battle_result_kind(result_payload) == INVASION_RESULT_ATTACKER_WIN
	return _calculate_player_attack_troop_outcome_fallback(allocated, maxi(0, int(result_payload.get("attacker_surviving_troops", 0))), did_win)


func _get_enemy_troop_outcome_from_result(result_payload: Dictionary) -> Dictionary:
	var raw_outcome: Variant = result_payload.get("enemy_troop_outcome", {})
	if raw_outcome is Dictionary:
		return (raw_outcome as Dictionary).duplicate(true)
	var allocated := maxi(0, int(result_payload.get("defender_total_allocated_troops", result_payload.get("defender_troops", 0))))
	var did_win := _normalize_player_attack_battle_result_kind(result_payload) == INVASION_RESULT_DEFENDER_WIN
	return _calculate_player_attack_troop_outcome_fallback(allocated, maxi(0, int(result_payload.get("defender_surviving_troops", 0))), did_win)


func _calculate_player_attack_troop_outcome_fallback(allocated: int, raw_survivors: int, did_win: bool) -> Dictionary:
	var safe_allocated := maxi(0, int(allocated))
	var survivors := mini(safe_allocated, maxi(0, int(raw_survivors))) if did_win else 0
	var losses := maxi(0, safe_allocated - survivors)
	var wounded := int(floor(float(losses) * 0.30)) if did_win else int(floor(float(safe_allocated) * 0.50))
	wounded = clampi(wounded, 0, safe_allocated)
	var dead := maxi(0, safe_allocated - survivors - wounded)
	return {
		"allocated": safe_allocated,
		"survivors": survivors,
		"losses": losses,
		"wounded": wounded,
		"dead": dead,
	}


func _calculate_invasion_casualty_result(result_kind: String, defender_city_id: String, attacker_city_id: String, result_payload: Dictionary) -> Dictionary:
	var defender_before := _clamp_invasion_troops(_get_city_troops_for_battle_context(defender_city_id))
	var attacker_before := _clamp_invasion_troops(_get_city_troops_for_battle_context(attacker_city_id))
	if defender_city_id.is_empty() or not _has_city_for_battle_context(defender_city_id):
		print("[INVASION_CASUALTY] result=%s reason=missing_defender_city defender_city=%s" % [result_kind, defender_city_id])
		return {
			"attacker_before": attacker_before,
			"defender_before": defender_before,
			"attacker_remaining_troops": attacker_before,
			"defender_remaining_troops": defender_before,
			"occupied_city_troops": 0,
			"attacker_source_remaining_troops": attacker_before,
			"attacker_loss": 0,
			"defender_loss": 0,
		}
	var attacker_payload_survivors := _get_result_troop_value(result_payload, ["attacker_surviving_troops", "attacker_remaining_troops", "enemy_surviving_troops"], -1)
	var defender_payload_survivors := _get_result_troop_value(result_payload, ["defender_surviving_troops", "defender_remaining_troops", "player_surviving_troops"], -1)
	var attacker_remaining := attacker_before
	var defender_remaining := defender_before
	var occupied_city_troops := 0
	var attacker_source_remaining := attacker_before
	match result_kind:
		INVASION_RESULT_DEFENDER_WIN:
			defender_remaining = _resolve_invasion_remaining_troops(defender_before, defender_payload_survivors, INVASION_DEFENDER_WIN_DEFENDER_LOSS_RATE, INVASION_MIN_CITY_TROOPS)
			attacker_remaining = _resolve_invasion_remaining_troops(attacker_before, attacker_payload_survivors, INVASION_DEFENDER_WIN_ATTACKER_LOSS_RATE, 0)
			attacker_source_remaining = attacker_remaining
		INVASION_RESULT_ATTACKER_WIN:
			defender_remaining = _resolve_invasion_remaining_troops(defender_before, defender_payload_survivors, INVASION_ATTACKER_WIN_DEFENDER_LOSS_RATE, 0)
			attacker_remaining = _resolve_invasion_remaining_troops(attacker_before, attacker_payload_survivors, INVASION_ATTACKER_WIN_ATTACKER_LOSS_RATE, 0)
			occupied_city_troops = _resolve_occupation_troops(attacker_remaining, attacker_before, result_payload)
			attacker_source_remaining = _clamp_invasion_troops(maxi(0, attacker_remaining - occupied_city_troops))
		_:
			pass
	var result := {
		"attacker_before": attacker_before,
		"defender_before": defender_before,
		"attacker_remaining_troops": attacker_remaining,
		"defender_remaining_troops": defender_remaining,
		"occupied_city_troops": occupied_city_troops,
		"attacker_source_remaining_troops": attacker_source_remaining,
		"attacker_loss": maxi(0, attacker_before - attacker_remaining),
		"defender_loss": maxi(0, defender_before - defender_remaining),
	}
	print("[INVASION_CASUALTY] result=%s attacker=%d->%d loss=%d defender=%d->%d loss=%d occupied=%d source_remaining=%d" % [
		result_kind,
		attacker_before,
		attacker_remaining,
		int(result.get("attacker_loss", 0)),
		defender_before,
		defender_remaining,
		int(result.get("defender_loss", 0)),
		occupied_city_troops,
		attacker_source_remaining
	])
	return result


func _resolve_invasion_remaining_troops(before_troops: int, payload_survivors: int, loss_rate: float, minimum_when_present: int) -> int:
	var before := _clamp_invasion_troops(before_troops)
	if before <= 0:
		return 0
	var remaining := payload_survivors
	if remaining < 0:
		remaining = int(round(float(before) * (1.0 - clampf(loss_rate, 0.0, 1.0))))
	remaining = clampi(_clamp_invasion_troops(remaining), 0, before)
	if minimum_when_present > 0:
		remaining = clampi(maxi(minimum_when_present, remaining), 0, before)
	return remaining


func _resolve_occupation_troops(attacker_remaining: int, attacker_before: int, result_payload: Dictionary) -> int:
	var remaining := _clamp_invasion_troops(attacker_remaining)
	if remaining <= 0:
		var fallback_source := _get_result_troop_value(result_payload, ["attacker_troops", "enemy_troops"], attacker_before)
		remaining = _resolve_invasion_remaining_troops(fallback_source, -1, INVASION_ATTACKER_WIN_ATTACKER_LOSS_RATE, 0)
	if remaining <= 0:
		return INVASION_MIN_OCCUPATION_TROOPS
	var occupation_troops := maxi(INVASION_MIN_OCCUPATION_TROOPS, int(round(float(remaining) * 0.60)))
	return _clamp_invasion_troops(occupation_troops)


func _clamp_invasion_troops(troops: int) -> int:
	return clampi(int(troops), 0, INVASION_MAX_REASONABLE_CITY_TROOPS)


func _get_result_troop_value(result_payload: Dictionary, keys: Array[String], fallback: int) -> int:
	for key in keys:
		if result_payload.has(key):
			return _clamp_invasion_troops(int(result_payload.get(key, fallback)))
	return fallback


func _set_city_runtime_owner(city_id: String, owner_id: String) -> void:
	if city_id.is_empty() or owner_id.is_empty():
		return
	var city_data := _get_mutable_city_runtime_state(city_id)
	if city_data.is_empty():
		push_warning("[WorldMap] Runtime owner apply skipped; city not found: %s" % city_id)
		return
	city_data["owner"] = owner_id
	city_data["nation"] = owner_id
	city_data["owner_faction_id"] = owner_id
	city_data["faction"] = owner_id
	_city_runtime_states[city_id] = city_data
	var city_marker := _city_markers_by_id.get(city_id) as WorldMapCityMarker
	if city_marker != null:
		city_marker.owner_faction_id = owner_id
		city_marker._refresh_marker_visuals()
	_update_owned_city_ids_after_runtime_owner_change(city_id, owner_id)
	_refresh_city_hud_data_bindings()


func _set_city_runtime_troops(city_id: String, troops: int) -> void:
	if city_id.is_empty():
		return
	var city_data := _get_mutable_city_runtime_state(city_id)
	if city_data.is_empty():
		push_warning("[WorldMap] Runtime troop apply skipped; city not found: %s" % city_id)
		return
	city_data["troops"] = maxi(0, int(troops))
	_city_runtime_states[city_id] = city_data
	_refresh_city_hud_data_bindings()


func _is_supply_path_between(from_id: String, to_id: String) -> bool:
	if from_id.is_empty() or to_id.is_empty():
		return false
	if from_id == to_id:
		return true
	if not _is_city_owned_by_player_mvp(from_id) or not _is_city_owned_by_player_mvp(to_id):
		return false
	var visited := {}
	var queue: Array[String] = [from_id]
	while not queue.is_empty():
		var current_city_id := str(queue.pop_front())
		if current_city_id == to_id:
			return true
		if visited.has(current_city_id):
			continue
		visited[current_city_id] = true
		var city_marker := _city_markers_by_id.get(current_city_id) as WorldMapCityMarker
		if city_marker == null:
			continue
		for neighbor_id_variant in city_marker.neighbors:
			var neighbor_id := str(neighbor_id_variant)
			if visited.has(neighbor_id):
				continue
			if not _is_city_owned_by_player_mvp(neighbor_id):
				continue
			queue.append(neighbor_id)
	return false


func _get_city_min_garrison(city_id: String) -> int:
	var city_data := _get_city_hud_entry(city_id)
	if city_data.is_empty():
		return 0
	return maxi(0, int(round(float(_get_city_security_required_troops(city_data)) * TROOP_MOVE_MIN_GARRISON_RATIO)))


func _is_peacetime_for_troop_move() -> bool:
	if _enemy_turn_mvp_pending:
		return false
	if _has_pending_invasion_event_mvp():
		return false
	if not _get_pending_battle_context_mvp().is_empty():
		return false
	if Engine.has_meta(WORLDMAP_BATTLE_CONTEXT_META_KEY):
		return false
	if _normalize_turn_phase(str(_player_state.get("turn_phase", TURN_PHASE_PLAYER))) != TURN_PHASE_PLAYER:
		return false
	return true


func _can_move_troops(from_id: String, to_id: String, amount: int) -> Dictionary:
	if amount <= 0:
		return {"ok": false, "reason": "amount"}
	if from_id == to_id:
		return {"ok": false, "reason": "same_city"}
	if not _is_city_owned_by_player_mvp(from_id) or not _is_city_owned_by_player_mvp(to_id):
		return {"ok": false, "reason": "ownership"}
	if not _is_peacetime_for_troop_move():
		return {"ok": false, "reason": "not_peacetime"}
	if not _is_supply_path_between(from_id, to_id):
		return {"ok": false, "reason": "no_supply_path"}
	var from_troops := _get_city_troops_for_battle_context(from_id)
	var min_keep := _get_city_min_garrison(from_id)
	if from_troops - amount < min_keep:
		return {
			"ok": false,
			"reason": "min_garrison",
			"min_keep": min_keep,
			"from_troops": from_troops,
		}
	return {"ok": true, "min_keep": min_keep}


func _move_troops(from_id: String, to_id: String, amount: int) -> bool:
	var validation := _can_move_troops(from_id, to_id, amount)
	if not bool(validation.get("ok", false)):
		_player_state["last_troop_move_result"] = {
			"ok": false,
			"from": from_id,
			"to": to_id,
			"amount": amount,
			"commanded_amount": amount,
			"turn": maxi(1, int(_player_state.get("turn_number", 1))),
			"reason": str(validation.get("reason", "")),
		}
		return false
	var total_before := _get_world_city_troop_total()
	var from_troops := _get_city_troops_for_battle_context(from_id)
	var to_troops := _get_city_troops_for_battle_context(to_id)
	var commanded_amount := amount
	var departed_amount := commanded_amount
	var from_loyalty := _get_city_loyalty_value(_get_city_hud_entry(from_id))
	var arrived_amount := _calculate_troop_move_arrived_amount(commanded_amount, from_loyalty)
	var lost_amount := maxi(0, departed_amount - arrived_amount)
	var from_after := from_troops - departed_amount
	var to_after := to_troops + arrived_amount
	_set_city_runtime_troops(from_id, from_after)
	_set_city_runtime_troops(to_id, to_after)
	var total_after := _get_world_city_troop_total()
	_player_state["last_troop_move_result"] = {
		"ok": true,
		"from": from_id,
		"to": to_id,
		"amount": amount,
		"commanded_amount": commanded_amount,
		"departed_amount": departed_amount,
		"arrived_amount": arrived_amount,
		"lost_amount": lost_amount,
		"from_loyalty": from_loyalty,
		"turn": maxi(1, int(_player_state.get("turn_number", 1))),
		"from_after": from_after,
		"to_after": to_after,
		"total_before": total_before,
		"total_after": total_after,
		"total_loss": total_before - total_after,
	}
	print("[TROOP_MOVE] from=%s to=%s commanded=%d departed=%d arrived=%d lost=%d loyalty=%d from_after=%d to_after=%d total=%d->%d" % [
		from_id,
		to_id,
		commanded_amount,
		departed_amount,
		arrived_amount,
		lost_amount,
		from_loyalty,
		from_after,
		to_after,
		total_before,
		total_after,
	])
	return true


func _calculate_troop_move_arrived_amount(commanded_amount: int, from_loyalty: int) -> int:
	var safe_amount := maxi(0, commanded_amount)
	var safe_loyalty := clampi(from_loyalty, 0, 100)
	return maxi(0, int(floor(float(safe_amount) * float(safe_loyalty) / 100.0)))


func _get_conscription_capacity_by_loyalty(city_id: String) -> int:
	var city_data := _get_city_hud_entry(city_id)
	if city_data.is_empty():
		return 0
	var loyalty := _get_city_loyalty_value(city_data)
	var population := maxi(0, int(city_data.get("population", 0)))
	var ratio := 0.05
	if loyalty < 20:
		ratio = 0.0
	elif loyalty < 40:
		ratio = 0.05
	elif loyalty < 60:
		ratio = 0.10
	elif loyalty < 80:
		ratio = 0.20
	elif loyalty < 90:
		ratio = 0.30
	elif loyalty < 100:
		ratio = 0.40
	else:
		ratio = 0.50
	return maxi(0, int(floor(float(population) * ratio)))


func _get_city_conscription_available(city_id: String) -> int:
	var capacity := _get_conscription_capacity_by_loyalty(city_id)
	var current_troops := _get_city_troops_for_battle_context(city_id)
	return maxi(0, capacity - current_troops)


func _apply_city_conscription_for_world_turn() -> Dictionary:
	var result := {
		"turn": maxi(1, int(_player_state.get("turn_number", 1))),
		"applied": false,
		"city_results": {},
	}
	if not _is_peacetime_for_troop_move():
		result["reason"] = "not_peacetime"
		_player_state["last_conscription_result"] = result
		return result
	var owned_city_ids: Variant = _player_state.get("owned_city_ids", [])
	if not owned_city_ids is Array:
		_player_state["last_conscription_result"] = result
		return result
	result["applied"] = true
	for city_id_variant in owned_city_ids:
		var city_id := str(city_id_variant)
		if not _is_city_owned_by_player_mvp(city_id):
			continue
		var city_data := _get_city_hud_entry(city_id)
		if city_data.is_empty():
			continue
		var loyalty := _get_city_loyalty_value(city_data)
		var population := maxi(0, int(city_data.get("population", 0)))
		var capacity := _get_conscription_capacity_by_loyalty(city_id)
		var available_before := _get_city_conscription_available(city_id)
		var before_troops := _get_city_troops_for_battle_context(city_id)
		var added := mini(available_before, 100)
		var after_troops := before_troops + added
		if added > 0:
			_set_city_runtime_troops(city_id, after_troops)
		var city_result := {
			"loyalty": loyalty,
			"population": population,
			"capacity": capacity,
			"available_before": available_before,
			"before_troops": before_troops,
			"after_troops": after_troops,
			"added": added,
		}
		(result["city_results"] as Dictionary)[city_id] = city_result
		print("[CONSCRIPT_WORLD_TURN] city=%s loyalty=%d population=%d capacity=%d available=%d added=%d troops=%d->%d" % [
			city_id,
			loyalty,
			population,
			capacity,
			available_before,
			added,
			before_troops,
			after_troops,
		])
	_player_state["last_conscription_result"] = result
	if not (result["city_results"] as Dictionary).is_empty():
		_refresh_city_hud_data_bindings()
	return result


func _get_recruitment_limit_by_public_support(city_id: String) -> int:
	var public_support := _get_city_public_support(city_id)
	if public_support >= 90:
		return 500
	if public_support >= 80:
		return 300
	if public_support >= 60:
		return 200
	if public_support >= 40:
		return 100
	return 0


func _calculate_recruitment_cost(amount: int) -> Dictionary:
	var safe_amount := maxi(0, amount)
	return {
		"gold": safe_amount,
		"food": int(floor(float(safe_amount) / 2.0)),
	}


func _get_total_recruitment_food_stock() -> int:
	var resource_stock: Dictionary = _player_state.get("resource_stock", {})
	return maxi(0, int(resource_stock.get("rice", 0))) + maxi(0, int(resource_stock.get("barley", 0))) + maxi(0, int(resource_stock.get("seafood", 0)))


func _can_pay_recruitment_cost(cost: Dictionary) -> bool:
	var resource_stock: Dictionary = _player_state.get("resource_stock", {})
	return int(resource_stock.get("gold", 0)) >= int(cost.get("gold", 0)) and _get_total_recruitment_food_stock() >= int(cost.get("food", 0))


func _apply_recruitment_cost(cost: Dictionary) -> Dictionary:
	var resource_stock: Dictionary = _player_state.get("resource_stock", {}).duplicate(true)
	var before_stock := resource_stock.duplicate(true)
	var gold_cost := maxi(0, int(cost.get("gold", 0)))
	resource_stock["gold"] = maxi(0, int(resource_stock.get("gold", 0)) - gold_cost)
	var remaining_food := maxi(0, int(cost.get("food", 0)))
	var food_paid := {}
	for resource_id in ["rice", "barley", "seafood"]:
		var before_amount := maxi(0, int(resource_stock.get(resource_id, 0)))
		var paid := mini(before_amount, remaining_food)
		if paid > 0:
			resource_stock[resource_id] = before_amount - paid
			remaining_food -= paid
		food_paid[resource_id] = paid
	_player_state["resource_stock"] = resource_stock
	return {
		"before": before_stock,
		"after": resource_stock.duplicate(true),
		"gold": gold_cost,
		"food": maxi(0, int(cost.get("food", 0))) - remaining_food,
		"food_breakdown": food_paid,
		"food_order": ["rice", "barley", "seafood"],
	}


func _can_recruit_troops(city_id: String, amount: int) -> Dictionary:
	if not _is_city_owned_by_player_mvp(city_id):
		return {"ok": false, "reason": "ownership"}
	if amount <= 0 or amount % 100 != 0:
		return {"ok": false, "reason": "amount"}
	if not _is_peacetime_for_troop_move():
		return {"ok": false, "reason": "not_peacetime"}
	var public_support := _get_city_public_support(city_id)
	var limit := _get_recruitment_limit_by_public_support(city_id)
	if public_support < 40 or amount > limit:
		return {"ok": false, "reason": "public_support", "limit": limit, "publicSupport": public_support}
	var cost := _calculate_recruitment_cost(amount)
	if not _can_pay_recruitment_cost(cost):
		return {"ok": false, "reason": "resources", "cost": cost, "limit": limit, "publicSupport": public_support}
	return {
		"ok": true,
		"cost": cost,
		"limit": limit,
		"publicSupport": public_support,
	}


func _recruit_troops(city_id: String, amount: int) -> bool:
	var validation := _can_recruit_troops(city_id, amount)
	if not bool(validation.get("ok", false)):
		_player_state["last_recruitment_result"] = {
			"ok": false,
			"city_id": city_id,
			"amount": amount,
			"turn": maxi(1, int(_player_state.get("turn_number", 1))),
			"reason": str(validation.get("reason", "")),
		}
		return false
	var before_support := _get_city_public_support(city_id)
	var before_loyalty := _get_city_loyalty_value(_get_city_hud_entry(city_id))
	var before_troops := _get_city_troops_for_battle_context(city_id)
	var cost: Dictionary = validation.get("cost", {})
	var paid_cost := _apply_recruitment_cost(cost)
	var after_troops := before_troops + amount
	_set_city_runtime_troops(city_id, after_troops)
	_player_state["last_recruitment_result"] = {
		"ok": true,
		"city_id": city_id,
		"amount": amount,
		"cost": cost,
		"paid_cost": paid_cost,
		"publicSupport": before_support,
		"loyalty": before_loyalty,
		"before_troops": before_troops,
		"after_troops": after_troops,
		"turn": maxi(1, int(_player_state.get("turn_number", 1))),
	}
	print("[RECRUIT_TROOPS] city=%s amount=%d publicSupport=%d loyalty=%d troops=%d->%d cost=%s paid=%s" % [
		city_id,
		amount,
		before_support,
		before_loyalty,
		before_troops,
		after_troops,
		str(cost),
		str(paid_cost),
	])
	_refresh_city_hud_data_bindings()
	return true


func _get_national_tech_definitions() -> Dictionary:
	return {
		"national_foundation": _make_national_tech_definition("national_foundation", "국가 기반 정비", "foundation", "basic", [], "", {}, {"gold": 200}, "국가 테크트리 기초를 연다."),
		"legal_reform": _make_national_tech_definition("legal_reform", "법률 정비", "administrative", "basic", ["national_foundation"], "administrative", {}, {"gold": 300, "silk": 100}, "법률 정비 기반."),
		"bureaucracy_system": _make_national_tech_definition("bureaucracy_system", "관료 체계", "administrative", "mid", ["legal_reform"], "", {"owned_city_count": 2}, {"gold": 500, "silk": 200}, "관료 체계 기반."),
		"local_administration": _make_national_tech_definition("local_administration", "지방 행정", "administrative", "mid", ["bureaucracy_system"], "", {"owned_city_count": 3, "governor_assigned_city_count": 2}, {"gold": 600, "silk": 300}, "지방 행정 기반."),
		"centralization": _make_national_tech_definition("centralization", "중앙집권", "administrative", "capstone", ["local_administration"], "administrative", {"national_loyalty": 70, "owned_city_count": 5, "chancellor_type_turns": 10}, {"gold": 1000, "silk": 500}, "중앙집권 기반."),
		"tax_reform": _make_national_tech_definition("tax_reform", "세제 개혁", "economic", "basic", ["national_foundation"], "economic", {}, {"gold": 400}, "세제 개혁 기반."),
		"equal_tax": _make_national_tech_definition("equal_tax", "균등세", "economic", "mid", ["tax_reform"], "", {"owned_city_count": 2}, {"gold": 500, "silk": 100}, "균등세 기반."),
		"unified_currency": _make_national_tech_definition("unified_currency", "화폐 통일", "economic", "advanced", ["equal_tax"], "economic", {"avg_commerce": 50, "chancellor_type_turns": 5}, {"gold": 800, "iron": 200}, "화폐 통일 기반."),
		"national_economy": _make_national_tech_definition("national_economy", "국가 경제", "economic", "capstone", ["unified_currency"], "", {"owned_city_count": 4, "has_city_tech_mint": true}, {"gold": 1500, "silk": 500}, "국가 경제 기반."),
		"conscription_system": _make_national_tech_definition("conscription_system", "징병 제도", "military", "basic", ["national_foundation"], "militaryAdmin", {}, {"gold": 300, "food": 200}, "징병 제도 기반."),
		"military_training_order": _make_national_tech_definition("military_training_order", "군사 훈련령", "military", "mid", ["conscription_system"], "", {"avg_loyalty": 60}, {"iron": 200, "gold": 400, "food": 300}, "군사 훈련 기반."),
		"military_reform": _make_national_tech_definition("military_reform", "군사 개혁", "military", "advanced", ["military_training_order"], "militaryAdmin", {"chancellor_type_turns": 5}, {"iron": 500, "gold": 600, "food": 400}, "군사 개혁 기반."),
		"standing_army": _make_national_tech_definition("standing_army", "상비군", "military", "capstone", ["military_reform"], "", {"avg_loyalty": 75, "owned_city_count": 4}, {"iron": 800, "gold": 1000, "food": 800}, "상비군 기반."),
		"logistics_system": _make_national_tech_definition("logistics_system", "병참 제도", "military", "advanced", ["military_training_order"], "", {"connected_supply_city_count": 3}, {"food": 500, "salt": 300, "gold": 400}, "원정 보급 안정 기반."),
		"envoy_dispatch": _make_national_tech_definition("envoy_dispatch", "사신 파견", "diplomatic", "basic", ["national_foundation"], "diplomatic", {}, {"gold": 300, "silk": 200}, "사신 파견 기반."),
		"diplomacy_system": _make_national_tech_definition("diplomacy_system", "외교 체계", "diplomatic", "mid", ["envoy_dispatch"], "", {"neutral_faction_count": 2}, {"gold": 400, "silk": 300}, "외교 체계 기반."),
		"alliance_system": _make_national_tech_definition("alliance_system", "동맹 체계", "diplomatic", "advanced", ["diplomacy_system"], "diplomatic", {"allied_faction_count": 1, "chancellor_type_turns": 5}, {"gold": 600, "silk": 400}, "동맹 체계 기반."),
		"world_diplomacy": _make_national_tech_definition("world_diplomacy", "천하 외교", "diplomatic", "capstone", ["alliance_system"], "", {"allied_faction_count": 2, "has_silkroad_or_trade_port": true}, {"gold": 1000, "silk": 800}, "천하 외교 기반."),
		"inspection_system": _make_national_tech_definition("inspection_system", "감찰 제도", "political", "mid", ["bureaucracy_system"], "political", {}, {"gold": 400, "silk": 200}, "감찰 제도 기반."),
		"anti_corruption": _make_national_tech_definition("anti_corruption", "부패 방지", "political", "advanced", ["inspection_system"], "", {"national_loyalty": 65}, {"gold": 600, "silk": 300}, "부패 방지 기반."),
		"spy_network_system": _make_national_tech_definition("spy_network_system", "첩보 체계", "political", "mid", ["diplomacy_system"], "political", {}, {"gold": 500, "silk": 200}, "첩보 체계 기반."),
		"intelligence_organization": _make_national_tech_definition("intelligence_organization", "첩보 조직", "political", "advanced", ["spy_network_system"], "", {"owned_city_count": 3}, {"gold": 800, "silk": 400}, "첩보 조직 기반."),
	}


func _make_national_tech_definition(id: String, name: String, branch: String, tier: String, requires: Array, required_chancellor_type: String, conditions: Dictionary, cost: Dictionary, effect_summary: String) -> Dictionary:
	return {
		"id": id,
		"name": name,
		"branch": branch,
		"tier": tier,
		"requires": requires.duplicate(true),
		"required_chancellor_type": required_chancellor_type,
		"conditions": conditions.duplicate(true),
		"cost": cost.duplicate(true),
		"effect_summary": effect_summary,
		"icon_path": "",
		"image_path": "",
	}


func _ensure_national_tech_state() -> void:
	if not _player_state.has("national_tech") or not (_player_state["national_tech"] is Dictionary):
		_player_state["national_tech"] = {}
	var national_tech: Dictionary = _player_state["national_tech"]
	if not national_tech.has("completed") or not (national_tech["completed"] is Dictionary):
		national_tech["completed"] = {}
	if not national_tech.has("in_progress") or not (national_tech["in_progress"] is Dictionary):
		national_tech["in_progress"] = {}
	if not national_tech.has("available_cache") or not (national_tech["available_cache"] is Dictionary):
		national_tech["available_cache"] = {}
	_player_state["national_tech"] = national_tech


func _get_completed_national_tech_ids() -> Array:
	_ensure_national_tech_state()
	var completed: Dictionary = (_player_state["national_tech"] as Dictionary).get("completed", {})
	var result: Array[String] = []
	for tech_id_variant in completed.keys():
		var tech_id := str(tech_id_variant)
		if bool(completed.get(tech_id_variant, false)):
			result.append(tech_id)
	return result


func _is_national_tech_completed(tech_id: String) -> bool:
	_ensure_national_tech_state()
	var completed: Dictionary = (_player_state["national_tech"] as Dictionary).get("completed", {})
	return bool(completed.get(tech_id, false))


func _is_national_tech_in_progress(tech_id: String) -> bool:
	_ensure_national_tech_state()
	var in_progress: Dictionary = (_player_state["national_tech"] as Dictionary).get("in_progress", {})
	return bool(in_progress.get(tech_id, false))


func _get_national_tech_definition(tech_id: String) -> Dictionary:
	var definitions := _get_national_tech_definitions()
	var definition: Variant = definitions.get(tech_id, {})
	return (definition as Dictionary).duplicate(true) if definition is Dictionary else {}


func _get_current_chancellor_aptitude_type() -> String:
	var chancellor_id := str(_player_state.get("chancellor_id", ""))
	if chancellor_id.is_empty():
		return ""
	var hero_data := _get_hero_entry(chancellor_id)
	if hero_data.is_empty() or str(hero_data.get("side", "")) != PLAYER_FACTION_ID:
		return ""
	return str(hero_data.get("chancellor_primary_type", ""))


func _check_national_tech_requirements(tech_id: String) -> Dictionary:
	var definition := _get_national_tech_definition(tech_id)
	var reasons: Array[String] = []
	var missing_requires: Array[String] = []
	var missing_conditions: Array[String] = []
	if definition.is_empty():
		return {"ok": false, "reasons": ["tech_not_found"], "missing_requires": missing_requires, "missing_conditions": missing_conditions}
	var requires: Array = definition.get("requires", [])
	for required_id_variant in requires:
		var required_id := str(required_id_variant)
		if not _is_national_tech_completed(required_id):
			missing_requires.append(required_id)
			reasons.append("missing_required:%s" % required_id)
	var required_chancellor_type := str(definition.get("required_chancellor_type", ""))
	if not required_chancellor_type.is_empty() and _get_current_chancellor_aptitude_type() != required_chancellor_type:
		missing_conditions.append("required_chancellor_type:%s" % required_chancellor_type)
		reasons.append("required_chancellor_type:%s" % required_chancellor_type)
	var conditions: Dictionary = definition.get("conditions", {})
	for condition_key_variant in conditions.keys():
		var condition_key := str(condition_key_variant)
		var required_value: Variant = conditions.get(condition_key_variant)
		if not _is_national_tech_condition_met(condition_key, required_value):
			var reason := _get_national_tech_condition_missing_reason(condition_key, required_value)
			missing_conditions.append(reason)
			reasons.append(reason)
	return {
		"ok": missing_requires.is_empty() and missing_conditions.is_empty(),
		"reasons": reasons,
		"missing_requires": missing_requires,
		"missing_conditions": missing_conditions,
	}


func _is_national_tech_condition_met(condition_key: String, required_value: Variant) -> bool:
	match condition_key:
		"owned_city_count":
			return _get_owned_city_count_for_national_tech() >= int(required_value)
		"governor_assigned_city_count":
			return _get_governor_assigned_city_count_for_national_tech() >= int(required_value)
		"national_loyalty":
			return clampi(int(_player_state.get("national_loyalty", 75)), 0, 100) >= int(required_value)
		"avg_loyalty":
			return _get_average_city_loyalty_for_national_tech() >= float(required_value)
		"avg_commerce":
			return _get_average_city_commerce_for_national_tech() >= float(required_value)
		"chancellor_type_turns", "connected_supply_city_count", "allied_faction_count", "neutral_faction_count", "has_city_tech_mint", "has_silkroad_or_trade_port":
			return false
		_:
			return false


func _get_national_tech_condition_missing_reason(condition_key: String, required_value: Variant) -> String:
	match condition_key:
		"chancellor_type_turns":
			return "chancellor_type_turns_not_tracked:%s" % str(required_value)
		"connected_supply_city_count":
			return "connected_supply_city_count_not_supported_yet:%s" % str(required_value)
		"allied_faction_count":
			return "allied_faction_count_not_supported_yet:%s" % str(required_value)
		"neutral_faction_count":
			return "neutral_faction_count_not_supported_yet:%s" % str(required_value)
		"has_city_tech_mint":
			return "has_city_tech_mint_not_supported_yet"
		"has_silkroad_or_trade_port":
			return "has_silkroad_or_trade_port_not_supported_yet"
		_:
			return "%s:%s" % [condition_key, str(required_value)]


func _get_owned_city_count_for_national_tech() -> int:
	var owned_city_ids: Variant = _player_state.get("owned_city_ids", [])
	if not owned_city_ids is Array:
		return 0
	var count := 0
	for city_id_variant in owned_city_ids:
		var city_id := str(city_id_variant)
		if _is_city_owned_by_player_mvp(city_id):
			count += 1
	return count


func _get_governor_assigned_city_count_for_national_tech() -> int:
	var owned_city_ids: Variant = _player_state.get("owned_city_ids", [])
	if not owned_city_ids is Array:
		return 0
	var count := 0
	for city_id_variant in owned_city_ids:
		var city_id := str(city_id_variant)
		if not _is_city_owned_by_player_mvp(city_id):
			continue
		var city_data := _get_city_hud_entry(city_id)
		if not str(city_data.get("governor_id", city_data.get("governorHeroId", ""))).is_empty():
			count += 1
	return count


func _get_average_city_loyalty_for_national_tech() -> float:
	var owned_city_ids: Variant = _player_state.get("owned_city_ids", [])
	if not owned_city_ids is Array:
		return 0.0
	var total := 0
	var count := 0
	for city_id_variant in owned_city_ids:
		var city_id := str(city_id_variant)
		if not _is_city_owned_by_player_mvp(city_id):
			continue
		total += _get_city_loyalty_value(_get_city_hud_entry(city_id))
		count += 1
	return 0.0 if count <= 0 else float(total) / float(count)


func _get_average_city_commerce_for_national_tech() -> float:
	var owned_city_ids: Variant = _player_state.get("owned_city_ids", [])
	if not owned_city_ids is Array:
		return 0.0
	var total := 0
	var count := 0
	for city_id_variant in owned_city_ids:
		var city_id := str(city_id_variant)
		if not _is_city_owned_by_player_mvp(city_id):
			continue
		total += _get_city_numeric_rating(_get_city_hud_entry(city_id), "commerce_rating", 0) * 20
		count += 1
	return 0.0 if count <= 0 else float(total) / float(count)


func _can_pay_national_tech_cost(tech_id: String) -> Dictionary:
	var definition := _get_national_tech_definition(tech_id)
	var cost: Dictionary = definition.get("cost", {}) if not definition.is_empty() else {}
	var missing := {}
	var resource_stock: Dictionary = _player_state.get("resource_stock", {})
	for resource_id_variant in cost.keys():
		var resource_id := str(resource_id_variant)
		var required_amount := maxi(0, int(cost.get(resource_id_variant, 0)))
		var available_amount := _get_total_recruitment_food_stock() if resource_id == "food" else maxi(0, int(resource_stock.get(resource_id, 0)))
		if available_amount < required_amount:
			missing[resource_id] = required_amount - available_amount
	return {
		"ok": not definition.is_empty() and missing.is_empty(),
		"cost": cost.duplicate(true),
		"missing": missing,
	}


func _can_start_national_tech(tech_id: String) -> Dictionary:
	_ensure_national_tech_state()
	var reasons: Array[String] = []
	if _get_national_tech_definition(tech_id).is_empty():
		return {"ok": false, "requirements": {"ok": false, "reasons": ["tech_not_found"], "missing_requires": [], "missing_conditions": []}, "cost": {"ok": false, "cost": {}, "missing": {}}, "reasons": ["tech_not_found"]}
	if _is_national_tech_completed(tech_id):
		reasons.append("already_completed")
	if _is_national_tech_in_progress(tech_id):
		reasons.append("already_in_progress")
	var requirements := _check_national_tech_requirements(tech_id)
	var cost := _can_pay_national_tech_cost(tech_id)
	if not bool(requirements.get("ok", false)):
		reasons.append_array(_string_array_from_variant_array(requirements.get("reasons", [])))
	if not bool(cost.get("ok", false)):
		reasons.append("cost")
	return {
		"ok": reasons.is_empty(),
		"requirements": requirements,
		"cost": cost,
		"reasons": reasons,
	}


func _start_national_tech(tech_id: String) -> bool:
	var start_check := _can_start_national_tech(tech_id)
	_player_state["last_national_tech_start_check"] = {
		"tech_id": tech_id,
		"ok": bool(start_check.get("ok", false)),
		"reasons": start_check.get("reasons", []),
	}
	return false


func _get_city_tech_definitions() -> Dictionary:
	return {
		"improved_farming_tools": _make_city_tech_definition("improved_farming_tools", "농기구 개량", "agriculture", "basic", [], "", [], {}, {"iron": 100}, "농업 생산 기반을 정비한다."),
		"irrigation_channel": _make_city_tech_definition("irrigation_channel", "관개수로", "agriculture", "mid", ["improved_farming_tools"], "administrative", [], {"agriculture_rating": 35}, {"wood": 300, "iron": 150}, "관개 기반을 확장한다."),
		"reservoir": _make_city_tech_definition("reservoir", "저수지", "agriculture", "advanced", ["irrigation_channel"], "", [], {"population": 20000}, {"wood": 500, "iron": 200}, "식량 안정 기반을 확장한다."),
		"double_cropping": _make_city_tech_definition("double_cropping", "이모작", "agriculture", "advanced", ["reservoir"], "", [], {"food_surplus_turns": 3}, {"gold": 500, "food": 200}, "계절 식량 생산 기반을 강화한다."),
		"granary_region": _make_city_tech_definition("granary_region", "곡창지대", "agriculture", "capstone", ["double_cropping"], "administrative", [], {"agriculture_rating": 80, "loyalty": 70, "governor_type_turns": 5}, {"wood": 800, "iron": 500, "gold": 1000}, "도시를 곡창 거점으로 육성한다."),
		"street_market": _make_city_tech_definition("street_market", "노점시장", "commerce", "basic", [], "", [], {}, {"gold": 100}, "기초 상업 기반을 연다."),
		"permanent_market": _make_city_tech_definition("permanent_market", "상설시장", "commerce", "mid", ["street_market"], "", [], {"commerce_rating": 20}, {"wood": 200, "gold": 200}, "상설 거래 기반을 구축한다."),
		"large_market": _make_city_tech_definition("large_market", "대형시장", "commerce", "advanced", ["permanent_market"], "", [], {"commerce_rating": 40, "population": 20000}, {"wood": 300, "gold": 400}, "대형 상업 기반을 구축한다."),
		"currency_system": _make_city_tech_definition("currency_system", "화폐제도", "commerce", "advanced", ["large_market"], "administrative", [], {"commerce_rating": 55}, {"iron": 200, "gold": 600}, "도시 단위 화폐 운용 기반을 마련한다."),
		"mint": _make_city_tech_definition("mint", "조폐소", "commerce", "capstone", ["currency_system"], "economic", ["unified_currency"], {"commerce_rating": 75, "loyalty": 60, "governor_type_turns": 5}, {"iron": 500, "gold": 1000}, "국가 화폐 통일 이후 도시 조폐 거점을 연다."),
		"fishing_village": _make_city_tech_definition("fishing_village", "어촌 형성", "fishery", "basic", [], "", [], {"is_coastal_city": true}, {"wood": 100, "food": 50}, "해안 도시의 어업 기반을 연다."),
		"coastal_fishing": _make_city_tech_definition("coastal_fishing", "연안 어업", "fishery", "mid", ["fishing_village"], "", [], {"fishery_rating": 20}, {"wood": 200, "gold": 100}, "연안 어업 생산 기반을 강화한다."),
		"fishing_fleet": _make_city_tech_definition("fishing_fleet", "어선단", "fishery", "advanced", ["coastal_fishing"], "maritime", [], {"fishery_rating": 35}, {"wood": 400, "iron": 100, "gold": 200}, "어선단 운용 기반을 마련한다."),
		"dried_fish_supply_base": _make_city_tech_definition("dried_fish_supply_base", "건어물 보급기지", "fishery", "capstone", ["fishing_fleet"], "", ["logistics_system"], {"fishery_rating": 65, "connected_supply_city_count": 2}, {"wood": 400, "salt": 300, "gold": 500}, "수산물 기반 보급 거점을 준비한다."),
		"barracks": _make_city_tech_definition("barracks", "병영 설치", "military", "basic", [], "", [], {}, {"wood": 200, "gold": 100}, "기초 군사 시설을 설치한다."),
		"infantry_training": _make_city_tech_definition("infantry_training", "보병 훈련", "military", "mid", ["barracks"], "militaryAdmin", [], {}, {"iron": 100, "food": 200, "gold": 200}, "보병 훈련 기반을 마련한다."),
		"elite_infantry": _make_city_tech_definition("elite_infantry", "정예 보병", "military", "advanced", ["infantry_training"], "", [], {"loyalty": 60}, {"iron": 300, "gold": 400}, "충성도 기반 정예 보병을 준비한다."),
		"armored_infantry": _make_city_tech_definition("armored_infantry", "철갑 보병", "military", "capstone", ["elite_infantry"], "militaryAdmin", ["military_reform"], {"loyalty": 75, "governor_type_turns": 5}, {"iron": 800, "gold": 800, "food": 400}, "군사 개혁 이후 철갑 보병 기반을 연다."),
		"siege_unit": _make_city_tech_definition("siege_unit", "공성 부대", "military", "advanced", ["elite_infantry"], "militaryAdmin", [], {}, {"wood": 500, "iron": 300, "gold": 500}, "공성 부대 편성 기반을 마련한다."),
		"siege_engine": _make_city_tech_definition("siege_engine", "공성 병기", "military", "capstone", ["siege_unit"], "", [], {}, {"wood": 600, "iron": 600, "gold": 800}, "공성 병기 제작 기반을 마련한다."),
		"port": _make_city_tech_definition("port", "항구", "commerce", "basic", [], "", [], {"is_coastal_city": true}, {"wood": 400, "gold": 300}, "해안 도시 항구 기반을 연다."),
		"shipyard": _make_city_tech_definition("shipyard", "조선소", "commerce", "mid", ["port"], "", [], {"is_coastal_city": true}, {"wood": 600, "iron": 400, "gold": 500}, "조선 기반을 마련한다."),
		"large_shipyard": _make_city_tech_definition("large_shipyard", "대형조선소", "commerce", "advanced", ["shipyard"], "maritime", [], {}, {"wood": 1000, "iron": 600, "gold": 800}, "대형 함선 건조 기반을 준비한다."),
		"turtle_ship": _make_city_tech_definition("turtle_ship", "거북선", "military", "rare", ["large_shipyard"], "", ["military_reform"], {"has_hero_yi_sunsin": true, "loyalty": 85}, {"iron": 1200, "wood": 1200, "gold": 2000}, "특수 수군 병기 기반을 준비한다."),
	}


func _make_city_tech_definition(id: String, name: String, branch: String, tier: String, requires: Array, required_governor_type: String, required_national_tech: Array, conditions: Dictionary, cost: Dictionary, effect_summary: String) -> Dictionary:
	return {
		"id": id,
		"name": name,
		"branch": branch,
		"tier": tier,
		"requires": requires.duplicate(true),
		"required_governor_type": required_governor_type,
		"required_national_tech": required_national_tech.duplicate(true),
		"conditions": conditions.duplicate(true),
		"cost": cost.duplicate(true),
		"effect_summary": effect_summary,
		"icon_path": "",
		"image_path": "",
	}


func _ensure_city_tech_state(city_id: String) -> Dictionary:
	var city_state := _get_mutable_city_runtime_state(city_id)
	if city_state.is_empty():
		return {}
	var city_tech: Dictionary = city_state.get("city_tech", {}) if city_state.get("city_tech", {}) is Dictionary else {}
	if not city_tech.has("completed") or not (city_tech["completed"] is Dictionary):
		city_tech["completed"] = {}
	if not city_tech.has("in_progress") or not (city_tech["in_progress"] is Dictionary):
		city_tech["in_progress"] = {}
	if not city_tech.has("available_cache") or not (city_tech["available_cache"] is Dictionary):
		city_tech["available_cache"] = {}
	city_state["city_tech"] = city_tech
	_city_runtime_states[city_id] = city_state
	return city_tech


func _get_completed_city_tech_ids(city_id: String) -> Array:
	var city_tech := _ensure_city_tech_state(city_id)
	var completed: Dictionary = city_tech.get("completed", {}) if city_tech.get("completed", {}) is Dictionary else {}
	var result: Array[String] = []
	for tech_id_variant in completed.keys():
		var tech_id := str(tech_id_variant)
		if bool(completed.get(tech_id_variant, false)):
			result.append(tech_id)
	return result


func _is_city_tech_completed(city_id: String, tech_id: String) -> bool:
	var city_tech := _ensure_city_tech_state(city_id)
	var completed: Dictionary = city_tech.get("completed", {}) if city_tech.get("completed", {}) is Dictionary else {}
	return bool(completed.get(tech_id, false))


func _is_city_tech_in_progress(city_id: String, tech_id: String) -> bool:
	var city_tech := _ensure_city_tech_state(city_id)
	var in_progress: Dictionary = city_tech.get("in_progress", {}) if city_tech.get("in_progress", {}) is Dictionary else {}
	return bool(in_progress.get(tech_id, false))


func _get_city_tech_definition(tech_id: String) -> Dictionary:
	var definitions := _get_city_tech_definitions()
	var definition: Variant = definitions.get(tech_id, {})
	return (definition as Dictionary).duplicate(true) if definition is Dictionary else {}


func _get_city_governor_aptitude_type(city_id: String) -> String:
	var city_data := _get_city_hud_entry(city_id)
	if city_data.is_empty():
		return ""
	var governor_id := str(city_data.get("governor_id", city_data.get("governorHeroId", "")))
	if governor_id.is_empty():
		return ""
	var hero_data := _get_hero_entry(governor_id)
	if hero_data.is_empty():
		return ""
	var primary_type := str(hero_data.get("chancellor_primary_type", ""))
	if not primary_type.is_empty():
		return primary_type
	return str(hero_data.get("chancellor_secondary_type", ""))


func _check_city_tech_requirements(city_id: String, tech_id: String) -> Dictionary:
	var definition := _get_city_tech_definition(tech_id)
	var reasons: Array[String] = []
	var missing_requires: Array[String] = []
	var missing_national_tech: Array[String] = []
	var missing_conditions: Array[String] = []
	if definition.is_empty():
		return {"ok": false, "reasons": ["tech_not_found"], "missing_requires": missing_requires, "missing_national_tech": missing_national_tech, "missing_conditions": missing_conditions}
	if _get_city_hud_entry(city_id).is_empty():
		return {"ok": false, "reasons": ["city_not_found"], "missing_requires": missing_requires, "missing_national_tech": missing_national_tech, "missing_conditions": ["city_not_found"]}
	var requires: Array = definition.get("requires", [])
	for required_id_variant in requires:
		var required_id := str(required_id_variant)
		if not _is_city_tech_completed(city_id, required_id):
			missing_requires.append(required_id)
			reasons.append("missing_city_tech:%s" % required_id)
	var national_requires: Array = definition.get("required_national_tech", [])
	for national_tech_id_variant in national_requires:
		var national_tech_id := str(national_tech_id_variant)
		if not _is_national_tech_completed(national_tech_id):
			missing_national_tech.append(national_tech_id)
			reasons.append("missing_national_tech:%s" % national_tech_id)
	var required_governor_type := str(definition.get("required_governor_type", ""))
	if not required_governor_type.is_empty() and _get_city_governor_aptitude_type(city_id) != required_governor_type:
		missing_conditions.append("required_governor_type:%s" % required_governor_type)
		reasons.append("required_governor_type:%s" % required_governor_type)
	var conditions: Dictionary = definition.get("conditions", {})
	for condition_key_variant in conditions.keys():
		var condition_key := str(condition_key_variant)
		var required_value: Variant = conditions.get(condition_key_variant)
		if not _is_city_tech_condition_met(city_id, condition_key, required_value):
			var reason := _get_city_tech_condition_missing_reason(condition_key, required_value)
			missing_conditions.append(reason)
			reasons.append(reason)
	return {
		"ok": missing_requires.is_empty() and missing_national_tech.is_empty() and missing_conditions.is_empty(),
		"reasons": reasons,
		"missing_requires": missing_requires,
		"missing_national_tech": missing_national_tech,
		"missing_conditions": missing_conditions,
	}


func _is_city_tech_condition_met(city_id: String, condition_key: String, required_value: Variant) -> bool:
	match condition_key:
		"agriculture_rating":
			return _get_city_tech_agriculture_value(city_id) >= int(required_value)
		"commerce_rating":
			return _get_city_tech_commerce_value(city_id) >= int(required_value)
		"fishery_rating":
			return _get_city_tech_fishery_value(city_id) >= int(required_value)
		"population":
			return maxi(0, int(_get_city_hud_entry(city_id).get("population", 0))) >= int(required_value)
		"loyalty":
			return _get_city_loyalty_value(_get_city_hud_entry(city_id)) >= int(required_value)
		"is_coastal_city":
			return _is_city_coastal_for_city_tech(city_id) == bool(required_value)
		"governor_type_turns", "food_surplus_turns", "connected_supply_city_count", "has_hero_yi_sunsin":
			return false
		_:
			return false


func _get_city_tech_condition_missing_reason(condition_key: String, required_value: Variant) -> String:
	match condition_key:
		"governor_type_turns":
			return "governor_type_turns_not_tracked:%s" % str(required_value)
		"food_surplus_turns":
			return "food_surplus_turns_not_supported_yet:%s" % str(required_value)
		"connected_supply_city_count":
			return "connected_supply_city_count_not_supported_yet:%s" % str(required_value)
		"has_hero_yi_sunsin":
			return "has_hero_yi_sunsin_not_supported_yet"
		_:
			return "%s:%s" % [condition_key, str(required_value)]


func _get_city_tech_agriculture_value(city_id: String) -> int:
	var city_data := _get_city_hud_entry(city_id)
	if city_data.has("agriculture"):
		return maxi(0, int(city_data.get("agriculture", 0)))
	var domestic_seed: Dictionary = city_data.get("domestic_seed", {}) if city_data.get("domestic_seed", {}) is Dictionary else {}
	if domestic_seed.has("agriculture"):
		return maxi(0, int(domestic_seed.get("agriculture", 0)))
	var resource_seed: Dictionary = city_data.get("resource_seed", {}) if city_data.get("resource_seed", {}) is Dictionary else {}
	return maxi(0, int(resource_seed.get("rice", 0)) + int(resource_seed.get("barley", 0))) * 10


func _get_city_tech_commerce_value(city_id: String) -> int:
	var city_data := _get_city_hud_entry(city_id)
	if city_data.has("commerce"):
		return maxi(0, int(city_data.get("commerce", 0)))
	var domestic_seed: Dictionary = city_data.get("domestic_seed", {}) if city_data.get("domestic_seed", {}) is Dictionary else {}
	if domestic_seed.has("commerce"):
		return maxi(0, int(domestic_seed.get("commerce", 0)))
	return maxi(0, int(city_data.get("commerce_rating", 0))) * 20


func _get_city_tech_fishery_value(city_id: String) -> int:
	var city_data := _get_city_hud_entry(city_id)
	if city_data.has("fishery"):
		return maxi(0, int(city_data.get("fishery", 0)))
	var resource_seed: Dictionary = city_data.get("resource_seed", {}) if city_data.get("resource_seed", {}) is Dictionary else {}
	return maxi(0, int(resource_seed.get("seafood", 0))) * 20


func _is_city_coastal_for_city_tech(city_id: String) -> bool:
	var city_data := _get_city_hud_entry(city_id)
	var city_type := str(city_data.get("type", ""))
	return city_type.find("coastal") >= 0 or city_type.find("port") >= 0 or city_type.find("maritime") >= 0


func _can_pay_city_tech_cost(city_id: String, tech_id: String) -> Dictionary:
	var definition := _get_city_tech_definition(tech_id)
	var cost: Dictionary = definition.get("cost", {}) if not definition.is_empty() and not _get_city_hud_entry(city_id).is_empty() else {}
	var missing := {}
	var resource_stock: Dictionary = _player_state.get("resource_stock", {})
	for resource_id_variant in cost.keys():
		var resource_id := str(resource_id_variant)
		var required_amount := maxi(0, int(cost.get(resource_id_variant, 0)))
		var available_amount := _get_total_recruitment_food_stock() if resource_id == "food" else maxi(0, int(resource_stock.get(resource_id, 0)))
		if available_amount < required_amount:
			missing[resource_id] = required_amount - available_amount
	return {
		"ok": not definition.is_empty() and not _get_city_hud_entry(city_id).is_empty() and missing.is_empty(),
		"cost": cost.duplicate(true),
		"missing": missing,
	}


func _can_start_city_tech(city_id: String, tech_id: String) -> Dictionary:
	var reasons: Array[String] = []
	if _get_city_hud_entry(city_id).is_empty():
		return {"ok": false, "requirements": {"ok": false, "reasons": ["city_not_found"], "missing_requires": [], "missing_national_tech": [], "missing_conditions": ["city_not_found"]}, "cost": {"ok": false, "cost": {}, "missing": {}}, "reasons": ["city_not_found"]}
	if _get_city_tech_definition(tech_id).is_empty():
		return {"ok": false, "requirements": {"ok": false, "reasons": ["tech_not_found"], "missing_requires": [], "missing_national_tech": [], "missing_conditions": []}, "cost": {"ok": false, "cost": {}, "missing": {}}, "reasons": ["tech_not_found"]}
	if _is_city_tech_completed(city_id, tech_id):
		reasons.append("already_completed")
	if _is_city_tech_in_progress(city_id, tech_id):
		reasons.append("already_in_progress")
	var requirements := _check_city_tech_requirements(city_id, tech_id)
	var cost := _can_pay_city_tech_cost(city_id, tech_id)
	if not bool(requirements.get("ok", false)):
		reasons.append_array(_string_array_from_variant_array(requirements.get("reasons", [])))
	if not bool(cost.get("ok", false)):
		reasons.append("cost")
	return {
		"ok": reasons.is_empty(),
		"requirements": requirements,
		"cost": cost,
		"reasons": reasons,
	}


func _start_city_tech(city_id: String, tech_id: String) -> bool:
	var start_check := _can_start_city_tech(city_id, tech_id)
	_player_state["last_city_tech_start_check"] = {
		"city_id": city_id,
		"tech_id": tech_id,
		"ok": bool(start_check.get("ok", false)),
		"reasons": start_check.get("reasons", []),
	}
	return false


func _validate_tech_data_consistency() -> Dictionary:
	var national_definitions := _get_national_tech_definitions()
	var city_definitions := _get_city_tech_definitions()
	var allowed_aptitude_types := ["administrative", "economic", "militaryAdmin", "diplomatic", "political", "maritime"]
	var allowed_cost_keys := ["gold", "food", "rice", "barley", "seafood", "silk", "iron", "wood", "salt", "horse"]
	var placeholder_condition_keys := [
		"chancellor_type_turns",
		"governor_type_turns",
		"food_surplus_turns",
		"connected_supply_city_count",
		"has_hero_yi_sunsin",
		"has_city_tech_mint",
		"has_silkroad_or_trade_port",
		"neutral_faction_count",
		"allied_faction_count",
	]
	var missing_national_refs: Array[Dictionary] = []
	var missing_city_refs: Array[Dictionary] = []
	var invalid_cost_keys: Array[Dictionary] = []
	var invalid_aptitude_types: Array[Dictionary] = []
	var missing_image_fields: Array[Dictionary] = []
	var placeholder_conditions: Array[Dictionary] = []
	for tech_id_variant in national_definitions.keys():
		var tech_id := str(tech_id_variant)
		var definition: Dictionary = national_definitions.get(tech_id_variant, {})
		for required_id_variant in definition.get("requires", []):
			var required_id := str(required_id_variant)
			if not national_definitions.has(required_id):
				missing_national_refs.append({"scope": "national_requires", "tech_id": tech_id, "missing_id": required_id})
		var required_chancellor_type := str(definition.get("required_chancellor_type", ""))
		if not required_chancellor_type.is_empty() and not allowed_aptitude_types.has(required_chancellor_type):
			invalid_aptitude_types.append({"scope": "national", "tech_id": tech_id, "field": "required_chancellor_type", "value": required_chancellor_type})
		_validate_tech_definition_cost_keys("national", tech_id, definition, allowed_cost_keys, invalid_cost_keys)
		_validate_tech_definition_image_fields("national", tech_id, definition, missing_image_fields)
		_collect_tech_placeholder_conditions("national", tech_id, definition, placeholder_condition_keys, placeholder_conditions)
	for tech_id_variant in city_definitions.keys():
		var tech_id := str(tech_id_variant)
		var definition: Dictionary = city_definitions.get(tech_id_variant, {})
		for required_id_variant in definition.get("requires", []):
			var required_id := str(required_id_variant)
			if not city_definitions.has(required_id):
				missing_city_refs.append({"scope": "city_requires", "tech_id": tech_id, "missing_id": required_id})
		for national_id_variant in definition.get("required_national_tech", []):
			var national_id := str(national_id_variant)
			if not national_definitions.has(national_id):
				missing_national_refs.append({"scope": "city_required_national_tech", "tech_id": tech_id, "missing_id": national_id})
		var required_governor_type := str(definition.get("required_governor_type", ""))
		if not required_governor_type.is_empty() and not allowed_aptitude_types.has(required_governor_type):
			invalid_aptitude_types.append({"scope": "city", "tech_id": tech_id, "field": "required_governor_type", "value": required_governor_type})
		_validate_tech_definition_cost_keys("city", tech_id, definition, allowed_cost_keys, invalid_cost_keys)
		_validate_tech_definition_image_fields("city", tech_id, definition, missing_image_fields)
		_collect_tech_placeholder_conditions("city", tech_id, definition, placeholder_condition_keys, placeholder_conditions)
	var ok := missing_national_refs.is_empty() and missing_city_refs.is_empty() and invalid_cost_keys.is_empty() and invalid_aptitude_types.is_empty() and missing_image_fields.is_empty()
	return {
		"ok": ok,
		"missing_national_refs": missing_national_refs,
		"missing_city_refs": missing_city_refs,
		"invalid_cost_keys": invalid_cost_keys,
		"invalid_aptitude_types": invalid_aptitude_types,
		"missing_image_fields": missing_image_fields,
		"placeholder_conditions": placeholder_conditions,
	}


func _validate_tech_definition_cost_keys(scope: String, tech_id: String, definition: Dictionary, allowed_cost_keys: Array, invalid_cost_keys: Array) -> void:
	var cost: Dictionary = definition.get("cost", {}) if definition.get("cost", {}) is Dictionary else {}
	for cost_key_variant in cost.keys():
		var cost_key := str(cost_key_variant)
		if not allowed_cost_keys.has(cost_key):
			invalid_cost_keys.append({"scope": scope, "tech_id": tech_id, "cost_key": cost_key})


func _validate_tech_definition_image_fields(scope: String, tech_id: String, definition: Dictionary, missing_image_fields: Array) -> void:
	for field_name in ["icon_path", "image_path"]:
		if not definition.has(field_name):
			missing_image_fields.append({"scope": scope, "tech_id": tech_id, "field": field_name})


func _collect_tech_placeholder_conditions(scope: String, tech_id: String, definition: Dictionary, placeholder_condition_keys: Array, placeholder_conditions: Array) -> void:
	var conditions: Dictionary = definition.get("conditions", {}) if definition.get("conditions", {}) is Dictionary else {}
	for condition_key_variant in conditions.keys():
		var condition_key := str(condition_key_variant)
		if placeholder_condition_keys.has(condition_key):
			placeholder_conditions.append({"scope": scope, "tech_id": tech_id, "condition": condition_key, "required": conditions.get(condition_key_variant)})


func _calculate_city_revolt_risk(city_id: String) -> Dictionary:
	var public_support := _get_city_public_support(city_id)
	var loyalty := _get_city_loyalty_value(_get_city_hud_entry(city_id))
	var risk := REVOLT_RISK_STABLE
	var reasons: Array[String] = []
	if public_support <= 40:
		reasons.append("민심 40 이하")
	if loyalty <= 40:
		reasons.append("충성도 40 이하")
	if public_support <= 30:
		reasons.append("민심 30 이하")
	if loyalty <= 30:
		reasons.append("충성도 30 이하")
	if public_support <= 30 and loyalty <= 30:
		risk = REVOLT_RISK_DANGER
	elif public_support <= 40 and loyalty <= 40:
		risk = REVOLT_RISK_WARNING
	return {
		"city_id": city_id,
		"publicSupport": public_support,
		"loyalty": loyalty,
		"risk": risk,
		"warning": risk == REVOLT_RISK_WARNING,
		"danger": risk == REVOLT_RISK_DANGER,
		"reasons": reasons,
	}


func _apply_revolt_warning_check_for_world_turn() -> Dictionary:
	var result := {
		"turn": maxi(1, int(_player_state.get("turn_number", 1))),
		"warning_count": 0,
		"danger_count": 0,
		"city_results": {},
	}
	var owned_city_ids: Variant = _player_state.get("owned_city_ids", [])
	if not owned_city_ids is Array:
		_player_state["last_revolt_warning_result"] = result
		return result
	for city_id_variant in owned_city_ids:
		var city_id := str(city_id_variant)
		if not _is_city_owned_by_player_mvp(city_id):
			continue
		var city_result := _calculate_city_revolt_risk(city_id)
		(result["city_results"] as Dictionary)[city_id] = city_result
		if bool(city_result.get("danger", false)):
			result["danger_count"] = int(result.get("danger_count", 0)) + 1
		elif bool(city_result.get("warning", false)):
			result["warning_count"] = int(result.get("warning_count", 0)) + 1
		print("[REVOLT_WARNING_CHECK] city=%s publicSupport=%d loyalty=%d risk=%s reasons=%s" % [
			city_id,
			int(city_result.get("publicSupport", 0)),
			int(city_result.get("loyalty", 0)),
			str(city_result.get("risk", REVOLT_RISK_STABLE)),
			str(city_result.get("reasons", [])),
		])
	_player_state["last_revolt_warning_result"] = result
	return result


func _calculate_troop_rebalance_suggestions() -> Array:
	var suggestions: Array = []
	var supply_states := _calculate_all_city_supply_states()
	var city_states: Variant = supply_states.get("city_states", {})
	var owned_city_ids: Variant = _player_state.get("owned_city_ids", [])
	if not city_states is Dictionary or not owned_city_ids is Array:
		_player_state["last_troop_rebalance_suggestions"] = suggestions
		return suggestions

	var suppliers: Array[Dictionary] = []
	var demands: Array[Dictionary] = []
	for city_id_variant in owned_city_ids:
		var city_id := str(city_id_variant)
		var city_state: Variant = (city_states as Dictionary).get(city_id, {})
		if not city_state is Dictionary:
			continue
		var city_data := _get_city_hud_entry(city_id)
		if city_data.is_empty():
			continue
		var role := str((city_state as Dictionary).get("role", "rear"))
		var target_ratio := float(ROLE_TARGET_GARRISON_RATIO.get(role, ROLE_TARGET_GARRISON_RATIO.get("rear", 0.0)))
		var target := maxi(0, int(floor(float(maxi(0, int(city_data.get("population", 0)))) * target_ratio)))
		var current_troops := _get_city_troops_for_battle_context(city_id)
		var surplus := maxi(0, current_troops - target)
		var shortage := maxi(0, target - current_troops)
		if role != "frontline" and surplus > 0:
			suppliers.append({
				"city_id": city_id,
				"role": role,
				"surplus": surplus,
			})
		elif role == "frontline" and shortage > 0:
			demands.append({
				"city_id": city_id,
				"role": role,
				"shortage": shortage,
			})

	demands.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("shortage", 0)) > int(b.get("shortage", 0))
	)
	suppliers.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("surplus", 0)) > int(b.get("surplus", 0))
	)

	for demand in demands:
		var to_id := str(demand.get("city_id", ""))
		var to_role := str(demand.get("role", "frontline"))
		var shortage_left := int(demand.get("shortage", 0))
		for supplier_index in range(suppliers.size()):
			if shortage_left <= 0:
				break
			var supplier: Dictionary = suppliers[supplier_index]
			var from_id := str(supplier.get("city_id", ""))
			var from_role := str(supplier.get("role", "rear"))
			var supplier_surplus := int(supplier.get("surplus", 0))
			var amount := mini(supplier_surplus, shortage_left)
			if amount <= 0:
				continue
			var validation := _can_move_troops(from_id, to_id, amount)
			if not bool(validation.get("ok", false)):
				continue
			suggestions.append({
				"from": from_id,
				"to": to_id,
				"amount": amount,
				"reason": "후방 %s 잉여 병력 %d명 → 전선 %s 보강" % [from_id, amount, to_id],
				"from_role": from_role,
				"to_role": to_role,
				"from_surplus_before": supplier_surplus,
				"to_shortage_before": shortage_left,
			})
			supplier["surplus"] = supplier_surplus - amount
			suppliers[supplier_index] = supplier
			shortage_left -= amount

	_player_state["last_troop_rebalance_suggestions"] = suggestions
	return suggestions


func _apply_troop_rebalance_suggestion(suggestion: Dictionary) -> bool:
	var from_id := str(suggestion.get("from", ""))
	var to_id := str(suggestion.get("to", ""))
	var amount := int(suggestion.get("amount", 0))
	return _move_troops(from_id, to_id, amount)


func _get_world_city_troop_total() -> int:
	var total := 0
	for city_id_variant in CITY_HUD_DATA.keys():
		total += _get_city_troops_for_battle_context(str(city_id_variant))
	return total


func _apply_context_side_troop_pre_decrement_mvp(battle_context: Dictionary, side_prefix: String, deployed_key: String) -> Dictionary:
	var context := battle_context.duplicate(true)
	if bool(context.get(deployed_key, false)):
		return context
	var source_city_id := str(context.get("%s_source_city_id" % side_prefix, context.get("%s_city_id" % side_prefix, "")))
	var total_key := "%s_total_allocated_troops" % side_prefix
	var requested_total := maxi(0, int(context.get(total_key, 0)))
	if source_city_id.is_empty() or requested_total <= 0:
		return context
	var before_troops := _get_city_troops_for_battle_context(source_city_id)
	var deployed_total := mini(requested_total, before_troops)
	var after_troops := maxi(0, before_troops - deployed_total)
	context[total_key] = deployed_total
	context["%s_source_city_id" % side_prefix] = source_city_id
	context["%s_source_city_troops_before" % side_prefix] = before_troops
	context["%s_source_city_troops_after" % side_prefix] = after_troops
	context[deployed_key] = deployed_total > 0
	_set_city_runtime_troops(source_city_id, after_troops)
	print("[TROOP_PRE_DEPLOY] side=%s city=%s before=%d allocated=%d after=%d" % [
		side_prefix,
		source_city_id,
		before_troops,
		deployed_total,
		after_troops,
	])
	return context


func _set_city_runtime_stationed_hero_ids(city_id: String, stationed_hero_ids: Array) -> void:
	if city_id.is_empty():
		return
	var city_data := _get_mutable_city_runtime_state(city_id)
	if city_data.is_empty():
		push_warning("[WorldMap] Runtime hero roster apply skipped; city not found: %s" % city_id)
		return
	var normalized_hero_ids: Array[String] = []
	for hero_id_variant in stationed_hero_ids:
		var hero_id := str(hero_id_variant)
		if hero_id.is_empty() or normalized_hero_ids.has(hero_id):
			continue
		if _get_hero_seed_entry(hero_id).is_empty():
			print("[LOAD_STATE_SKIP] type=city_stationed_hero city=%s hero=%s reason=missing_hero" % [city_id, hero_id])
			continue
		normalized_hero_ids.append(hero_id)
	city_data["stationed_hero_ids"] = normalized_hero_ids
	city_data["hero_ids"] = normalized_hero_ids
	_city_runtime_states[city_id] = city_data
	for hero_id in normalized_hero_ids:
		_set_hero_runtime_city(hero_id, city_id)
	_refresh_city_hud_data_bindings()


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


func _build_battle_context_from_pending_invasion(event: Dictionary, mode: String, selected_defender_hero_ids: Array[String] = [], defender_troop_allocation_override: Dictionary = {}) -> Dictionary:
	var attacker_city_id := str(event.get("attacker_city_id", ""))
	var defender_city_id := str(event.get("defender_city_id", ""))
	var attacker_owner := _get_city_owner_id_for_battle_context(attacker_city_id)
	var defender_owner := _get_city_owner_id_for_battle_context(defender_city_id)
	var used_hero_ids := {}
	var attacker_roster := _build_invasion_side_roster_for_battle_context(attacker_city_id, attacker_owner, used_hero_ids, "attacker")
	var defender_roster := {}
	if selected_defender_hero_ids.is_empty():
		defender_roster = _build_invasion_side_roster_for_battle_context(defender_city_id, defender_owner, used_hero_ids, "defender")
	else:
		defender_roster = _build_selected_side_roster_for_battle_context(defender_city_id, selected_defender_hero_ids, defender_troop_allocation_override, used_hero_ids, "defender")
	var attacker_troop_allocation := _build_command_limit_troop_allocation_for_heroes(attacker_roster.get("hero_ids", []), _get_city_troops_for_battle_context(attacker_city_id), attacker_city_id)
	var defender_troop_allocation := _build_command_limit_troop_allocation_for_heroes(defender_roster.get("hero_ids", []), _get_city_troops_for_battle_context(defender_city_id), defender_city_id)
	if not selected_defender_hero_ids.is_empty():
		defender_troop_allocation = defender_troop_allocation_override.duplicate(true)
	attacker_roster = _apply_troop_allocation_to_roster(attacker_roster, attacker_troop_allocation, attacker_city_id)
	defender_roster = _apply_troop_allocation_to_roster(defender_roster, defender_troop_allocation, defender_city_id)
	_log_invasion_reinforcement_rule_summary(attacker_city_id, defender_city_id, attacker_owner, defender_owner, attacker_roster, defender_roster)
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
		"attacker_owner": attacker_owner,
		"defender_owner": defender_owner,
		"attacker_troops": _get_city_troops_for_battle_context(attacker_city_id),
		"defender_troops": _get_city_troops_for_battle_context(defender_city_id),
		"attacker_troop_allocation": attacker_troop_allocation.duplicate(true),
		"defender_troop_allocation": defender_troop_allocation.duplicate(true),
		"attacker_total_allocated_troops": _sum_troop_allocation(attacker_troop_allocation),
		"defender_total_allocated_troops": _sum_troop_allocation(defender_troop_allocation),
		"attacker_source_city_id": attacker_city_id,
		"defender_source_city_id": defender_city_id,
		"selected_defender_hero_ids": _normalize_hero_id_array(selected_defender_hero_ids),
		"attacker_hero_ids": attacker_roster.get("hero_ids", []),
		"defender_hero_ids": defender_roster.get("hero_ids", []),
		"attacker_heroes": attacker_roster.get("heroes", []),
		"defender_heroes": defender_roster.get("heroes", []),
		"attacker_main_hero_ids": attacker_roster.get("main_hero_ids", []),
		"defender_main_hero_ids": defender_roster.get("main_hero_ids", []),
		"attacker_support_hero_ids": attacker_roster.get("support_hero_ids", []),
		"defender_support_hero_ids": defender_roster.get("support_hero_ids", []),
		"attacker_support_city_ids": attacker_roster.get("support_city_ids", []),
		"defender_support_city_ids": defender_roster.get("support_city_ids", []),
		"attacker_governor_id": _get_city_governor_id_for_battle_context(attacker_city_id),
		"defender_governor_id": _get_city_governor_id_for_battle_context(defender_city_id),
	}


func _build_player_attack_battle_context(source_city_id: String, target_city_id: String, mode: String = "manual", selected_attacker_hero_ids: Array[String] = [], attacker_troop_allocation: Dictionary = {}, supply_cost: Dictionary = {}) -> Dictionary:
	var attacker_city_id := source_city_id
	var defender_city_id := target_city_id
	if attacker_city_id.is_empty() or defender_city_id.is_empty():
		return {}
	if not _has_city_for_battle_context(attacker_city_id) or not _has_city_for_battle_context(defender_city_id):
		return {}
	var attacker_owner := _get_city_owner_id_for_battle_context(attacker_city_id)
	var defender_owner := _get_city_owner_id_for_battle_context(defender_city_id)
	var used_hero_ids := {}
	var attacker_roster := _build_player_attack_selected_roster_for_battle_context(attacker_city_id, selected_attacker_hero_ids, attacker_troop_allocation, used_hero_ids)
	var defender_roster := _build_invasion_side_roster_for_battle_context(defender_city_id, defender_owner, used_hero_ids, "defender")
	var defender_troop_allocation := _build_command_limit_troop_allocation_for_heroes(defender_roster.get("hero_ids", []), _get_city_troops_for_battle_context(defender_city_id), defender_city_id)
	defender_roster = _apply_troop_allocation_to_roster(defender_roster, defender_troop_allocation, defender_city_id)
	var attacker_main_hero_ids: Array = attacker_roster.get("main_hero_ids", [])
	if attacker_main_hero_ids.is_empty():
		print("[PLAYER_ATTACK] context_build_blocked source=%s target=%s reason=no_main_attackers" % [attacker_city_id, defender_city_id])
		return {}
	var total_assigned_troops := 0
	for hero_id in attacker_main_hero_ids:
		total_assigned_troops += maxi(0, int(attacker_troop_allocation.get(str(hero_id), 0)))
	_log_invasion_reinforcement_rule_summary(attacker_city_id, defender_city_id, attacker_owner, defender_owner, attacker_roster, defender_roster)
	return {
		"type": "attack",
		"source": PLAYER_ATTACK_CONTEXT_SOURCE,
		"mode": "auto" if mode == "auto" else "manual",
		"attacker_city_id": attacker_city_id,
		"defender_city_id": defender_city_id,
		"attacker_city_name": _format_city_name_by_id(attacker_city_id, "알 수 없는 아군 도시"),
		"defender_city_name": _format_city_name_by_id(defender_city_id, "알 수 없는 적 도시"),
		"turn_number": maxi(1, int(_player_state.get("turn_number", 1))),
		"attacker_owner": attacker_owner,
		"defender_owner": defender_owner,
		"attacker_troops": total_assigned_troops if total_assigned_troops > 0 else _get_city_troops_for_battle_context(attacker_city_id),
		"defender_troops": _get_city_troops_for_battle_context(defender_city_id),
		"attacker_hero_ids": attacker_roster.get("hero_ids", []),
		"defender_hero_ids": defender_roster.get("hero_ids", []),
		"attacker_heroes": attacker_roster.get("heroes", []),
		"defender_heroes": defender_roster.get("heroes", []),
		"selected_attacker_hero_ids": attacker_main_hero_ids.duplicate(),
		"attacker_troop_allocation": attacker_troop_allocation.duplicate(true),
		"supply_cost": supply_cost.duplicate(true),
		"supply_source_city_id": attacker_city_id,
		"defender_troop_allocation": defender_troop_allocation.duplicate(true),
		"defender_total_allocated_troops": _sum_troop_allocation(defender_troop_allocation),
		"defender_source_city_id": defender_city_id,
		"attacker_main_hero_ids": attacker_roster.get("main_hero_ids", []),
		"defender_main_hero_ids": defender_roster.get("main_hero_ids", []),
		"attacker_support_hero_ids": attacker_roster.get("support_hero_ids", []),
		"defender_support_hero_ids": defender_roster.get("support_hero_ids", []),
		"attacker_support_city_ids": attacker_roster.get("support_city_ids", []),
		"defender_support_city_ids": defender_roster.get("support_city_ids", []),
		"attacker_governor_id": str(attacker_main_hero_ids[0]) if not attacker_main_hero_ids.is_empty() else "",
		"defender_governor_id": _get_city_governor_id_for_battle_context(defender_city_id),
	}


func _build_player_attack_selected_roster_for_battle_context(source_city_id: String, selected_hero_ids: Array[String], troop_allocation: Dictionary, used_hero_ids: Dictionary) -> Dictionary:
	return _build_selected_side_roster_for_battle_context(source_city_id, selected_hero_ids, troop_allocation, used_hero_ids, "attacker")


func _build_selected_side_roster_for_battle_context(source_city_id: String, selected_hero_ids: Array[String], troop_allocation: Dictionary, used_hero_ids: Dictionary, side_label: String) -> Dictionary:
	var hero_ids: Array[String] = []
	var main_hero_ids: Array[String] = []
	var support_hero_ids: Array[String] = []
	var support_city_ids: Array[String] = []
	var source_heroes := selected_hero_ids.duplicate()
	if source_heroes.is_empty():
		source_heroes = _get_available_player_attack_main_hero_ids(source_city_id)
	for hero_id in source_heroes:
		if not selected_hero_ids.is_empty() and maxi(0, int(troop_allocation.get(str(hero_id), 0))) <= 0:
			continue
		if _append_invasion_roster_hero_id(hero_ids, main_hero_ids, str(hero_id), used_hero_ids, side_label, source_city_id, "selected_main"):
			if hero_ids.size() >= INVASION_BATTLE_MAX_HEROES_PER_SIDE:
				break
	var heroes: Array[Dictionary] = []
	for hero_id in hero_ids:
		var hero_battle_data := _get_hero_battle_data_for_battle_context(hero_id, source_city_id)
		if hero_battle_data.is_empty():
			continue
		var command_summary := _get_hero_command_summary_for_city_mvp(hero_battle_data, source_city_id)
		hero_battle_data["command_rank"] = str(command_summary.get("command_rank", COMMAND_RANK_OFFICER))
		hero_battle_data["command_label"] = str(command_summary.get("command_label", "군관"))
		hero_battle_data["command_limit"] = int(command_summary.get("command_limit", 0))
		var assigned_troops := mini(maxi(0, int(troop_allocation.get(hero_id, hero_battle_data.get("troops", 0)))), int(hero_battle_data.get("command_limit", 0)))
		if assigned_troops > 0:
			hero_battle_data["troop_count"] = assigned_troops
			hero_battle_data["troops"] = assigned_troops
			hero_battle_data["max_troops"] = assigned_troops
			hero_battle_data["allocated_troops"] = assigned_troops
			hero_battle_data["initial_allocated_troops"] = assigned_troops
		heroes.append(hero_battle_data)
	return {
		"hero_ids": hero_ids,
		"heroes": heroes,
		"main_hero_ids": main_hero_ids,
		"support_hero_ids": support_hero_ids,
		"support_city_ids": support_city_ids,
	}


func _build_even_troop_allocation_for_heroes(hero_ids_source: Array, total_troops: int) -> Dictionary:
	var allocation := {}
	var hero_ids := _normalize_hero_id_array(hero_ids_source)
	var remaining := maxi(0, int(total_troops))
	if hero_ids.is_empty() or remaining <= 0:
		return allocation
	var base := int(floor(float(remaining) / float(hero_ids.size())))
	var extra := remaining % hero_ids.size()
	for index in range(hero_ids.size()):
		var hero_id := str(hero_ids[index])
		var amount := base + (1 if index < extra else 0)
		if amount > 0:
			allocation[hero_id] = amount
	return allocation


func _build_command_limit_troop_allocation_for_heroes(hero_ids_source: Array, total_troops: int, source_city_id: String) -> Dictionary:
	var allocation := {}
	var hero_ids := _normalize_hero_id_array(hero_ids_source)
	var active_heroes: Array[Dictionary] = []
	var total_command_limit := 0
	for hero_id in hero_ids:
		allocation[hero_id] = 0
		var hero_data := _get_hero_entry(hero_id)
		if hero_data.is_empty():
			continue
		var command_limit := _get_hero_command_limit_for_city_mvp(hero_data, source_city_id)
		if command_limit <= 0:
			continue
		active_heroes.append({
			"hero_id": hero_id,
			"limit": command_limit,
		})
		total_command_limit += command_limit
	var remaining := mini(maxi(0, int(total_troops)), total_command_limit)
	while remaining > 0:
		var open_heroes: Array[Dictionary] = []
		for entry in active_heroes:
			var hero_id := str(entry.get("hero_id", ""))
			var limit := maxi(0, int(entry.get("limit", 0)))
			if int(allocation.get(hero_id, 0)) < limit:
				open_heroes.append(entry)
		if open_heroes.is_empty():
			break
		var share := maxi(1, int(ceil(float(remaining) / float(open_heroes.size()))))
		var assigned_this_pass := 0
		for entry in open_heroes:
			var hero_id := str(entry.get("hero_id", ""))
			var limit := maxi(0, int(entry.get("limit", 0)))
			var room := maxi(0, limit - int(allocation.get(hero_id, 0)))
			var amount := mini(mini(room, share), remaining)
			if amount <= 0:
				continue
			allocation[hero_id] = int(allocation.get(hero_id, 0)) + amount
			assigned_this_pass += amount
			remaining -= amount
			if remaining <= 0:
				break
		if assigned_this_pass <= 0:
			break
	return allocation


func _apply_troop_allocation_to_roster(roster: Dictionary, allocation: Dictionary, fallback_city_id: String) -> Dictionary:
	var next_roster := roster.duplicate(true)
	var heroes: Array[Dictionary] = []
	var hero_ids := _normalize_hero_id_array(next_roster.get("hero_ids", []))
	for hero_id in hero_ids:
		var hero_battle_data := _get_hero_battle_data_for_battle_context(hero_id, fallback_city_id)
		if hero_battle_data.is_empty():
			continue
		var allocated := maxi(0, int(allocation.get(hero_id, hero_battle_data.get("troops", 0))))
		var command_summary := _get_hero_command_summary_for_city_mvp(hero_battle_data, fallback_city_id)
		hero_battle_data["command_rank"] = str(command_summary.get("command_rank", COMMAND_RANK_OFFICER))
		hero_battle_data["command_label"] = str(command_summary.get("command_label", "군관"))
		hero_battle_data["command_limit"] = int(command_summary.get("command_limit", 0))
		if allocated > 0:
			hero_battle_data["troops"] = allocated
			hero_battle_data["troop_count"] = allocated
			hero_battle_data["max_troops"] = allocated
			hero_battle_data["allocated_troops"] = allocated
			hero_battle_data["initial_allocated_troops"] = allocated
		heroes.append(hero_battle_data)
	next_roster["heroes"] = heroes
	return next_roster


func _sum_troop_allocation(allocation: Dictionary) -> int:
	var total := 0
	for key in allocation.keys():
		total += maxi(0, int(allocation.get(key, 0)))
	return total


func _build_invasion_side_roster_for_battle_context(source_city_id: String, faction_id: String, used_hero_ids: Dictionary, context_side: String) -> Dictionary:
	var hero_ids: Array[String] = []
	var main_hero_ids: Array[String] = []
	var support_hero_ids: Array[String] = []
	var support_city_ids: Array[String] = []
	if source_city_id.is_empty() or not _has_city_for_battle_context(source_city_id):
		print("[REINFORCE_FALLBACK] side=%s reason=missing_city city=%s" % [context_side, source_city_id])
		return _build_invasion_roster_result(hero_ids, main_hero_ids, support_hero_ids, support_city_ids)
	for hero_id in _get_city_stationed_hero_ids_for_battle_context(source_city_id):
		if _append_invasion_roster_hero_id(hero_ids, main_hero_ids, str(hero_id), used_hero_ids, context_side, source_city_id, "main"):
			if hero_ids.size() >= INVASION_BATTLE_MAX_HEROES_PER_SIDE:
				return _build_invasion_roster_result(hero_ids, main_hero_ids, support_hero_ids, support_city_ids)
	var candidate_city_ids := _get_reinforcement_candidate_city_ids_for_battle_context(source_city_id)
	print("[REINFORCE_RULE] side=%s source_city=%s faction=%s candidate_cities=%s" % [context_side, source_city_id, faction_id, str(candidate_city_ids)])
	for candidate_city_id in candidate_city_ids:
		if hero_ids.size() >= INVASION_BATTLE_MAX_HEROES_PER_SIDE:
			break
		if not _has_city_for_battle_context(candidate_city_id):
			print("[REINFORCE_SKIP] side=%s city=%s reason=missing_city" % [context_side, candidate_city_id])
			continue
		var candidate_owner := _get_city_owner_id_for_battle_context(candidate_city_id)
		if not _are_factions_reinforcement_compatible(faction_id, candidate_owner):
			print("[REINFORCE_SKIP] side=%s city=%s owner=%s reason=wrong_faction" % [context_side, candidate_city_id, candidate_owner])
			continue
		var city_added_hero := false
		for hero_id in _get_city_stationed_hero_ids_for_battle_context(candidate_city_id):
			if hero_ids.size() >= INVASION_BATTLE_MAX_HEROES_PER_SIDE:
				break
			if _append_invasion_roster_hero_id(hero_ids, support_hero_ids, str(hero_id), used_hero_ids, context_side, candidate_city_id, "support"):
				city_added_hero = true
		if city_added_hero and not support_city_ids.has(candidate_city_id):
			support_city_ids.append(candidate_city_id)
		elif not city_added_hero:
			print("[REINFORCE_SKIP] side=%s city=%s reason=no_heroes" % [context_side, candidate_city_id])
	if hero_ids.is_empty():
		print("[REINFORCE_FALLBACK] side=%s reason=empty_roster city=%s; sample fallback may be used only as crash guard" % [context_side, source_city_id])
	return _build_invasion_roster_result(hero_ids, main_hero_ids, support_hero_ids, support_city_ids)


func _append_invasion_roster_hero_id(target_hero_ids: Array[String], source_bucket: Array[String], hero_id: String, used_hero_ids: Dictionary, context_side: String, city_id: String, pick_type: String) -> bool:
	if hero_id.is_empty():
		return false
	if used_hero_ids.has(hero_id) or target_hero_ids.has(hero_id):
		print("[REINFORCE_SKIP] side=%s hero=%s city=%s reason=duplicate" % [context_side, hero_id, city_id])
		return false
	var hero_entry := _get_hero_entry(hero_id)
	if hero_entry.is_empty():
		print("[REINFORCE_SKIP] side=%s hero=%s city=%s reason=missing_hero" % [context_side, hero_id, city_id])
		return false
	if _is_hero_captured_for_battle(hero_id):
		var reason := _get_hero_battle_exclusion_reason(hero_id)
		var display_name := str(hero_entry.get("display_name", hero_entry.get("name", hero_id)))
		print("[HERO_BATTLE_EXCLUDE] side=%s type=%s city=%s hero=%s display_name=%s status=%s captured=%s reason=%s" % [
			context_side,
			pick_type,
			city_id,
			hero_id,
			display_name,
			str(hero_entry.get("status", HERO_RUNTIME_STATUS_NORMAL)),
			str(bool(hero_entry.get("captured", false))),
			reason,
		])
		print("[REINFORCE_SKIP] side=%s hero=%s city=%s reason=%s" % [context_side, hero_id, city_id, reason])
		return false
	used_hero_ids[hero_id] = true
	target_hero_ids.append(hero_id)
	source_bucket.append(hero_id)
	print("[REINFORCE_PICK] side=%s type=%s city=%s hero=%s" % [context_side, pick_type, city_id, hero_id])
	return true


func _build_invasion_roster_result(hero_ids: Array[String], main_hero_ids: Array[String], support_hero_ids: Array[String], support_city_ids: Array[String]) -> Dictionary:
	var heroes: Array[Dictionary] = []
	for hero_id in hero_ids:
		var city_id := _get_hero_city_id_for_battle_context(hero_id)
		var hero_battle_data := _get_hero_battle_data_for_battle_context(hero_id, city_id)
		if not hero_battle_data.is_empty():
			heroes.append(hero_battle_data)
	return {
		"hero_ids": hero_ids,
		"heroes": heroes,
		"main_hero_ids": main_hero_ids,
		"support_hero_ids": support_hero_ids,
		"support_city_ids": support_city_ids,
	}


func _get_reinforcement_candidate_city_ids_for_battle_context(source_city_id: String) -> Array[String]:
	var result: Array[String] = []
	var seen := {}
	seen[source_city_id] = true
	var frontier: Array[String] = [source_city_id]
	for _hop in range(1, INVASION_REINFORCEMENT_MAX_HOPS + 1):
		var next_frontier: Array[String] = []
		for city_id in frontier:
			for neighbor_id in _get_city_neighbors_mvp(city_id):
				if seen.has(neighbor_id):
					continue
				seen[neighbor_id] = true
				result.append(neighbor_id)
				next_frontier.append(neighbor_id)
		frontier = next_frontier
	return result


func _are_factions_reinforcement_compatible(source_faction_id: String, candidate_faction_id: String) -> bool:
	if source_faction_id.is_empty() or candidate_faction_id.is_empty():
		return false
	if source_faction_id == candidate_faction_id:
		return true
	var allies: Variant = INVASION_REINFORCEMENT_ALLY_FACTIONS.get(source_faction_id, [])
	return allies is Array and (allies as Array).has(candidate_faction_id)


func _get_hero_city_id_for_battle_context(hero_id: String) -> String:
	var hero_data := _get_hero_entry(hero_id)
	return str(hero_data.get("current_city_id", hero_data.get("city_id", hero_data.get("location_city_id", ""))))


func _log_invasion_reinforcement_rule_summary(attacker_city_id: String, defender_city_id: String, attacker_faction_id: String, defender_faction_id: String, attacker_roster: Dictionary, defender_roster: Dictionary) -> void:
	print("[REINFORCE_RULE] attacker_city=%s defender_city=%s attacker_faction=%s defender_faction=%s" % [attacker_city_id, defender_city_id, attacker_faction_id, defender_faction_id])
	print("[REINFORCE_RULE] attacker_main=%s attacker_support=%s attacker_support_cities=%s" % [str(attacker_roster.get("main_hero_ids", [])), str(attacker_roster.get("support_hero_ids", [])), str(attacker_roster.get("support_city_ids", []))])
	print("[REINFORCE_RULE] defender_main=%s defender_support=%s defender_support_cities=%s" % [str(defender_roster.get("main_hero_ids", [])), str(defender_roster.get("support_hero_ids", [])), str(defender_roster.get("support_city_ids", []))])


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


func _get_city_battle_heroes_for_battle_context(city_id: String) -> Array[Dictionary]:
	var battle_heroes: Array[Dictionary] = []
	for hero_id in _get_city_stationed_hero_ids_for_battle_context(city_id):
		var hero_battle_data := _get_hero_battle_data_for_battle_context(str(hero_id), city_id)
		if not hero_battle_data.is_empty():
			battle_heroes.append(hero_battle_data)
	return battle_heroes


func _get_hero_battle_data_for_battle_context(hero_id: String, fallback_city_id: String) -> Dictionary:
	var hero_data := _get_hero_entry(hero_id)
	if hero_data.is_empty():
		return {}
	var battle_data := hero_data.duplicate(true)
	var normalized_hero_id := str(battle_data.get("hero_id", battle_data.get("id", hero_id)))
	var role := str(battle_data.get("web_role", battle_data.get("role", ""))).to_lower()
	var role_contract: Dictionary = HERO_BATTLE_ROLE_CONTRACTS.get(role, HERO_BATTLE_DEFAULT_ROLE_CONTRACT).duplicate(true)
	var faction_id := str(battle_data.get("faction_id", battle_data.get("force_id", battle_data.get("nation", ""))))
	var current_city_id := str(battle_data.get("current_city_id", battle_data.get("city_id", battle_data.get("location_city_id", fallback_city_id))))
	var skill_id := str(battle_data.get("skill_id", battle_data.get("unique_skill_id", "%s_skill" % normalized_hero_id)))
	battle_data["hero_id"] = normalized_hero_id
	battle_data["display_name"] = str(battle_data.get("display_name", battle_data.get("name", normalized_hero_id)))
	battle_data["faction_id"] = faction_id
	battle_data["force_id"] = str(battle_data.get("force_id", faction_id))
	battle_data["nation"] = str(battle_data.get("nation", faction_id))
	battle_data["owner"] = str(battle_data.get("owner", battle_data.get("nation", faction_id)))
	battle_data["current_city_id"] = current_city_id
	battle_data["city_id"] = current_city_id
	battle_data["unit_type"] = str(battle_data.get("unit_type", role_contract.get("unit_type", "infantry")))
	battle_data["troop_count"] = maxi(0, int(battle_data.get("troop_count", battle_data.get("troops", 0))))
	battle_data["troops"] = int(battle_data["troop_count"])
	battle_data["leadership"] = int(battle_data.get("leadership", battle_data.get("command", battle_data.get("war", 70))))
	battle_data["command"] = int(battle_data["leadership"])
	battle_data["war"] = int(battle_data.get("war", battle_data.get("attack", 60)))
	battle_data["attack"] = int(battle_data.get("attack", maxi(10, floori(float(int(battle_data["war"])) / 3.0))))
	battle_data["defense"] = int(battle_data.get("defense", 12))
	battle_data["intelligence"] = int(battle_data.get("intelligence", 60))
	battle_data["move_range"] = maxi(1, int(battle_data.get("move_range", role_contract.get("move_range", 3))))
	battle_data["mobility"] = int(battle_data["move_range"])
	battle_data["attack_range"] = maxi(1, int(battle_data.get("attack_range", role_contract.get("attack_range", 1))))
	battle_data["portrait_path"] = str(battle_data.get("portrait_path", _get_hero_contract_portrait_path(normalized_hero_id, faction_id)))
	battle_data["cutin_path"] = str(battle_data.get("cutin_path", _get_hero_contract_cutin_path(normalized_hero_id, faction_id)))
	battle_data["skill_id"] = skill_id
	battle_data["skill_name"] = _format_hero_contract_skill_name(battle_data)
	battle_data["skill_desc"] = _format_hero_contract_skill_desc(battle_data, role_contract)
	battle_data["skill_effect_type"] = str(battle_data.get("skill_effect_type", role_contract.get("skill_effect_type", "command_aura")))
	battle_data["battle_effect_type"] = str(battle_data.get("battle_effect_type", role_contract.get("battle_effect_type", "ally_attack_buff")))
	battle_data["skill_power"] = int(battle_data.get("skill_power", role_contract.get("skill_power", 6)))
	battle_data["skill_value"] = int(battle_data["skill_power"])
	battle_data["skill_range"] = maxi(0, int(battle_data.get("skill_range", role_contract.get("skill_range", 3))))
	battle_data["skill_cooldown"] = maxi(0, int(battle_data.get("skill_cooldown", 0)))
	battle_data["skill_toast_icon"] = str(battle_data.get("skill_toast_icon", HERO_BATTLE_TOAST_ICON_FALLBACK))
	return battle_data


func _get_hero_contract_nation_key(faction_id: String) -> String:
	return str(HERO_PORTRAIT_NATION_BY_FACTION.get(faction_id, "unknown"))


func _get_hero_contract_portrait_path(hero_id: String, faction_id: String) -> String:
	var nation_key := _get_hero_contract_nation_key(faction_id)
	return "res://assets/heroes/portraits/%s/%s_%s.png" % [nation_key, nation_key, hero_id]


func _get_hero_contract_cutin_path(hero_id: String, faction_id: String) -> String:
	var nation_key := _get_hero_contract_nation_key(faction_id)
	return "res://assets/heroes/cutins/%s/%s_%s_cutin.png" % [nation_key, nation_key, hero_id]


func _format_hero_contract_skill_name(hero_data: Dictionary) -> String:
	return str(hero_data.get("skill_name", "%s 전법" % str(hero_data.get("display_name", "장수"))))


func _format_hero_contract_skill_desc(hero_data: Dictionary, role_contract: Dictionary) -> String:
	if hero_data.has("skill_desc") and not str(hero_data.get("skill_desc", "")).is_empty():
		return str(hero_data.get("skill_desc"))
	return "%s의 %s 계열 임시 고유특기입니다." % [
		str(hero_data.get("display_name", "장수")),
		str(role_contract.get("skill_effect_type", "command_aura")),
	]


func _get_city_governor_id_for_battle_context(city_id: String) -> String:
	var city_entry := _get_city_hud_entry(city_id)
	return str(city_entry.get("governor_id", city_entry.get("governorHeroId", "")))


func _normalize_command_rank_mvp(raw_rank: Variant) -> String:
	var rank := str(raw_rank).strip_edges()
	if COMMAND_RANK_LIMITS.has(rank):
		return rank
	if rank == "captain":
		return COMMAND_RANK_LIEUTENANT
	return COMMAND_RANK_OFFICER


func _get_hero_command_rank_for_city_mvp(hero_data: Dictionary, city_id: String) -> String:
	var hero_id := str(hero_data.get("hero_id", hero_data.get("id", "")))
	var governor_id := _get_city_governor_id_for_battle_context(city_id)
	if not hero_id.is_empty() and not governor_id.is_empty() and hero_id == governor_id:
		return COMMAND_RANK_GOVERNOR
	return _normalize_command_rank_mvp(hero_data.get("command_rank", hero_data.get("commandRank", COMMAND_RANK_OFFICER)))


func _get_hero_command_limit_for_city_mvp(hero_data: Dictionary, city_id: String) -> int:
	var rank := _get_hero_command_rank_for_city_mvp(hero_data, city_id)
	return maxi(0, int(COMMAND_RANK_LIMITS.get(rank, COMMAND_RANK_LIMITS.get(COMMAND_RANK_OFFICER, 5000))))


func _get_hero_command_summary_for_city_mvp(hero_data: Dictionary, city_id: String) -> Dictionary:
	var rank := _get_hero_command_rank_for_city_mvp(hero_data, city_id)
	return {
		"command_rank": rank,
		"command_label": str(COMMAND_RANK_LABELS.get(rank, COMMAND_RANK_LABELS.get(COMMAND_RANK_OFFICER, "군관"))),
		"command_limit": _get_hero_command_limit_for_city_mvp(hero_data, city_id),
	}


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
	_advance_wounded_hero_recovery_turns()
	_apply_wounded_recovery_for_world_turn_mvp()
	_update_world_turn_labels()
	_refresh_city_hud_data_bindings()


func _get_city_wounded_queue_mvp(city_data: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var raw_queue: Variant = city_data.get("woundedQueue", city_data.get("wounded_queue", []))
	if not raw_queue is Array:
		return result
	for raw_entry in raw_queue:
		if not raw_entry is Dictionary:
			continue
		var entry := raw_entry as Dictionary
		var troops := maxi(0, int(entry.get("troops", 0)))
		var turns_left := maxi(0, int(entry.get("turnsLeft", entry.get("turns_left", 0))))
		if troops <= 0:
			continue
		result.append({
			"turnsLeft": turns_left,
			"troops": troops,
		})
	return result


func _add_wounded_to_city_mvp(city_id: String, wounded_troops: int, turns_left: int = PLAYER_ATTACK_WOUNDED_QUEUE_TURNS) -> void:
	var troops := maxi(0, int(wounded_troops))
	if city_id.is_empty() or troops <= 0:
		return
	var city_data := _get_mutable_city_runtime_state(city_id)
	if city_data.is_empty():
		return
	var queue := _get_city_wounded_queue_mvp(city_data)
	queue.append({
		"turnsLeft": maxi(1, int(turns_left)),
		"troops": troops,
	})
	city_data["woundedQueue"] = queue
	city_data["wounded_queue"] = queue.duplicate(true)
	_city_runtime_states[city_id] = city_data
	print("[TROOP_WOUNDED_QUEUE_ADD] city=%s troops=%d turns=%d queue_size=%d" % [city_id, troops, maxi(1, int(turns_left)), queue.size()])


func _clear_city_wounded_queue_mvp(city_id: String) -> void:
	if city_id.is_empty():
		return
	var city_data := _get_mutable_city_runtime_state(city_id)
	if city_data.is_empty():
		return
	city_data["woundedQueue"] = []
	city_data["wounded_queue"] = []
	_city_runtime_states[city_id] = city_data


func _apply_wounded_recovery_for_world_turn_mvp() -> void:
	for city_id_variant in _city_runtime_states.keys():
		var city_id := str(city_id_variant)
		var city_data := _get_mutable_city_runtime_state(city_id)
		if city_data.is_empty():
			continue
		var queue := _get_city_wounded_queue_mvp(city_data)
		if queue.is_empty():
			continue
		var remaining_queue: Array[Dictionary] = []
		var recovered_troops := 0
		for entry in queue:
			var troops := maxi(0, int(entry.get("troops", 0)))
			var turns_left := maxi(0, int(entry.get("turnsLeft", 0))) - 1
			if troops <= 0:
				continue
			if turns_left <= 0:
				recovered_troops += troops
			else:
				remaining_queue.append({
					"turnsLeft": turns_left,
					"troops": troops,
				})
		if recovered_troops > 0:
			var before_troops := maxi(0, int(city_data.get("troops", 0)))
			city_data["troops"] = before_troops + recovered_troops
			print("[TROOP_WOUNDED_RECOVERED] city=%s before=%d recovered=%d after=%d" % [
				city_id,
				before_troops,
				recovered_troops,
				int(city_data.get("troops", 0)),
			])
		city_data["woundedQueue"] = remaining_queue
		city_data["wounded_queue"] = remaining_queue.duplicate(true)
		_city_runtime_states[city_id] = city_data


func _advance_wounded_hero_recovery_turns() -> void:
	for hero_id_variant in _hero_runtime_states.keys():
		var hero_id := str(hero_id_variant)
		var raw_state: Variant = _hero_runtime_states.get(hero_id, {})
		if not raw_state is Dictionary:
			continue
		var hero_state := _normalize_hero_runtime_state(hero_id, raw_state as Dictionary)
		if bool(hero_state.get("dead", false)) or bool(hero_state.get("captured", false)):
			hero_state["wounded"] = false
			hero_state["wounded_turns_remaining"] = 0
			_hero_runtime_states[hero_id] = hero_state
			continue
		if not bool(hero_state.get("wounded", false)) and str(hero_state.get("status", HERO_RUNTIME_STATUS_NORMAL)) != HERO_RUNTIME_STATUS_WOUNDED:
			continue
		var before_turns := maxi(0, int(hero_state.get("wounded_turns_remaining", DEFAULT_WOUNDED_RECOVERY_TURNS)))
		var after_turns := maxi(0, before_turns - 1)
		print("[HERO_RECOVERY_TICK] hero=%s before=%d after=%d" % [hero_id, before_turns, after_turns])
		if after_turns <= 0:
			hero_state["status"] = HERO_RUNTIME_STATUS_NORMAL
			hero_state["wounded"] = false
			hero_state["wounded_turns_remaining"] = 0
			print("[HERO_RECOVERED] hero=%s status=normal" % hero_id)
		else:
			hero_state["status"] = HERO_RUNTIME_STATUS_WOUNDED
			hero_state["wounded"] = true
			hero_state["wounded_turns_remaining"] = after_turns
		_hero_runtime_states[hero_id] = hero_state


func _apply_domestic_turn_mvp() -> String:
	# v0.68b-12b-6: port the web domestic income/tax/policy MVP once per completed player turn.
	var turn_number := maxi(1, int(_player_state.get("turn_number", 1)))
	if int(_player_state.get("last_domestic_apply_turn", 0)) == turn_number:
		return "내정 이미 적용됨"
	var tax_level := _normalize_tax_level(_player_state.get("tax_level", 30))
	var policy_id := _normalize_chancellor_policy_id(str(_player_state.get("chancellor_policy_id", "balanced")))
	var national_effects := _calculate_active_chancellor_national_effects()
	var supply_states := _calculate_all_city_supply_states()
	var income_delta := _calculate_player_domestic_income_delta(turn_number, tax_level, policy_id, national_effects, supply_states)
	var upkeep_delta := _calculate_player_hero_upkeep_delta(policy_id, national_effects, supply_states)
	var combined_delta := _combine_resource_deltas(income_delta, upkeep_delta)
	var applied_delta := _apply_resource_delta(combined_delta)
	var inter_faction_trade_result := _apply_player_inter_faction_trade_income(turn_number)
	var public_support_result := _apply_city_public_support_drift_for_world_turn(tax_level, supply_states)
	var base_loyalty_delta := _get_tax_loyalty_delta(tax_level)
	var loyalty_delta := _adjust_loyalty_delta(base_loyalty_delta, float(national_effects.get("national_loyalty_loss_multiplier", 1.0)))
	var before_loyalty := clampi(int(_player_state.get("national_loyalty", 75)), 0, 100)
	var after_loyalty := clampi(before_loyalty + loyalty_delta, 0, 100)
	var applied_loyalty_delta := after_loyalty - before_loyalty
	_player_state["national_loyalty"] = after_loyalty
	var city_loyalty_drift_result := _apply_city_loyalty_drift_for_world_turn(tax_level, policy_id, supply_states)
	var seasonal_loyalty_result := _apply_seasonal_loyalty_from_public_support(turn_number, supply_states)
	var conscription_result := _apply_city_conscription_for_world_turn()
	var revolt_warning_result := _apply_revolt_warning_check_for_world_turn()
	_player_state["last_domestic_apply_turn"] = turn_number
	_player_state["resources"] = _format_player_resource_summary()
	_player_state["income"] = _format_domestic_apply_summary(applied_delta, applied_loyalty_delta, inter_faction_trade_result, supply_states, city_loyalty_drift_result, public_support_result, seasonal_loyalty_result, conscription_result, revolt_warning_result)
	_player_state["tax_effect"] = _format_tax_effect_text(tax_level)
	_player_state["last_domestic_apply_result"] = {
		"version": "v0.69-4",
		"turn_number": turn_number,
		"tax_level": tax_level,
		"chancellor_policy_id": policy_id,
		"income_delta": income_delta,
		"upkeep_delta": upkeep_delta,
		"resource_delta": applied_delta,
		"loyalty_delta": applied_loyalty_delta,
		"national_effects": national_effects,
		"supply_state_result": supply_states,
		"inter_faction_trade_result": inter_faction_trade_result,
		"public_support_result": public_support_result,
		"city_loyalty_drift_result": city_loyalty_drift_result,
		"seasonal_loyalty_result": seasonal_loyalty_result,
		"conscription_result": conscription_result,
		"revolt_warning_result": revolt_warning_result,
	}
	return _format_domestic_apply_summary(applied_delta, applied_loyalty_delta, inter_faction_trade_result, supply_states, city_loyalty_drift_result, public_support_result, seasonal_loyalty_result, conscription_result, revolt_warning_result)


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


func _is_seasonal_loyalty_turn(turn_number: int) -> bool:
	return maxi(1, turn_number) % WORLD_CALENDAR_SEASON_TURNS == 0


func _get_next_seasonal_loyalty_turn(turn_number: int) -> int:
	var safe_turn := maxi(1, turn_number)
	var remainder := safe_turn % WORLD_CALENDAR_SEASON_TURNS
	return safe_turn if remainder == 0 else safe_turn + (WORLD_CALENDAR_SEASON_TURNS - remainder)


func _create_empty_domestic_income_totals() -> Dictionary:
	return {"rice": 0, "barley": 0, "seafood": 0, "gold": 0}


func _calculate_player_domestic_income_delta(turn_number: int, tax_level: int, policy_id: String, national_effects: Dictionary, supply_states: Dictionary = {}) -> Dictionary:
	var calendar := _get_world_calendar_for_turn(turn_number)
	var totals := _create_empty_domestic_income_totals()
	var owned_city_ids: Variant = _player_state.get("owned_city_ids", [])
	if not owned_city_ids is Array:
		return totals
	for city_id in owned_city_ids:
		var city_data := _get_city_hud_entry(str(city_id))
		if city_data.is_empty():
			continue
		var city_effects := _calculate_city_domestic_effects(city_data, policy_id)
		var city_supply_state := _get_supply_city_state(supply_states, city_id)
		_apply_supply_income_effect(city_effects, city_supply_state)
		var city_income := _calculate_city_domestic_income(city_data, calendar, tax_level, city_effects)
		for resource_id in totals.keys():
			totals[resource_id] = int(totals.get(resource_id, 0)) + int(city_income.get(resource_id, 0))
	var policy_totals := _apply_chancellor_policy_to_income_totals(totals, policy_id)
	return _apply_income_multipliers_to_totals(policy_totals, national_effects)


func _calculate_city_domestic_income(city_data: Dictionary, calendar: Dictionary, tax_level: int, city_effects: Dictionary = {}) -> Dictionary:
	var resource_seed: Dictionary = city_data.get("resource_seed", {})
	var income := _create_empty_domestic_income_totals()
	income["seafood"] = _get_rating(resource_seed, "seafood") * int(DOMESTIC_INCOME_RULES.get("seafood_per_rating_per_turn", 2))
	if str(calendar.get("season", "")) == "spring":
		income["barley"] = _get_rating(resource_seed, "barley") * int(DOMESTIC_INCOME_RULES.get("barley_per_rating_in_spring", 5))
	if str(calendar.get("season", "")) == "autumn":
		income["rice"] = _get_rating(resource_seed, "rice") * int(DOMESTIC_INCOME_RULES.get("rice_per_rating_in_autumn", 5))
	income["gold"] = _calculate_city_gold_tax_income(city_data, tax_level)
	return _apply_income_multipliers_to_totals(income, city_effects)


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


func _calculate_city_domestic_effects(city_data: Dictionary, chancellor_policy_id: String) -> Dictionary:
	var effect := {
		"rice_multiplier": 1.0,
		"barley_multiplier": 1.0,
		"seafood_multiplier": 1.0,
		"gold_multiplier": 1.0,
		"hero_upkeep_multiplier": 1.0,
		"soldier_upkeep_preview_multiplier": 1.0,
		"salt_preservation_multiplier": 1.0,
		"national_loyalty_loss_multiplier": 1.0,
		"city_loyalty_loss_multiplier": 1.0,
		"recruitable_troops_bonus": 0,
	}
	var governor_id := str(city_data.get("governor_id", city_data.get("governorHeroId", "")))
	var city_id := str(city_data.get("id", ""))
	var governor_data := _get_hero_entry(governor_id)
	if not governor_data.is_empty() and str(governor_data.get("side", "")) == PLAYER_FACTION_ID and str(governor_data.get("location_city_id", governor_data.get("city_id", ""))) == city_id:
		_apply_governor_type_effect(effect, str(governor_data.get("chancellor_primary_type", "")), float(governor_data.get("chancellor_primary_aptitude", 0)), GOVERNOR_PRIMARY_RATE)
		_apply_governor_type_effect(effect, str(governor_data.get("chancellor_secondary_type", "")), float(governor_data.get("chancellor_secondary_aptitude", 0)), GOVERNOR_SECONDARY_RATE)
	else:
		var chancellor_id := str(_player_state.get("chancellor_id", ""))
		var chancellor_data := _get_hero_entry(chancellor_id)
		if not chancellor_data.is_empty() and str(chancellor_data.get("side", "")) == PLAYER_FACTION_ID:
			var primary_strength := maxf(0.0, float(chancellor_data.get("chancellor_primary_aptitude", 0))) * CHANCELLOR_PRIMARY_RATE
			var secondary_strength := maxf(0.0, float(chancellor_data.get("chancellor_secondary_aptitude", 0))) * CHANCELLOR_SECONDARY_RATE
			if str(chancellor_data.get("chancellor_primary_type", "")) == "political" and primary_strength > 0.0:
				effect["city_loyalty_loss_multiplier"] = clampf(float(effect.get("city_loyalty_loss_multiplier", 1.0)) * (1.0 - (primary_strength * 0.4)), 0.85, 1.0)
			if str(chancellor_data.get("chancellor_secondary_type", "")) == "political" and secondary_strength > 0.0:
				effect["city_loyalty_loss_multiplier"] = clampf(float(effect.get("city_loyalty_loss_multiplier", 1.0)) * (1.0 - (secondary_strength * 0.4)), 0.85, 1.0)
	_apply_governor_policy_effect(effect, _get_city_policy_id(city_id, city_data), chancellor_policy_id)
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


func _apply_governor_type_effect(effect: Dictionary, type_id: String, aptitude: float, rate: float) -> void:
	var strength := maxf(0.0, aptitude) * rate
	if type_id.is_empty() or strength <= 0.0:
		return
	match type_id:
		"political":
			effect["city_loyalty_loss_multiplier"] = clampf(float(effect.get("city_loyalty_loss_multiplier", 1.0)) * (1.0 - strength), 0.72, 1.0)
		"economic":
			effect["gold_multiplier"] = clampf(float(effect.get("gold_multiplier", 1.0)) * (1.0 + strength), 1.0, 1.22)
		"administrative":
			effect["rice_multiplier"] = clampf(float(effect.get("rice_multiplier", 1.0)) * (1.0 + (strength * 0.45)), 1.0, 1.14)
			effect["barley_multiplier"] = clampf(float(effect.get("barley_multiplier", 1.0)) * (1.0 + (strength * 0.45)), 1.0, 1.14)
			effect["seafood_multiplier"] = clampf(float(effect.get("seafood_multiplier", 1.0)) * (1.0 + (strength * 0.3)), 1.0, 1.1)
		"diplomatic":
			effect["gold_multiplier"] = clampf(float(effect.get("gold_multiplier", 1.0)) * (1.0 + (strength * 0.55)), 1.0, 1.12)
		"militaryAdmin":
			effect["recruitable_troops_bonus"] = int(effect.get("recruitable_troops_bonus", 0)) + int(round(maxf(0.0, aptitude) * 12.0))


func _apply_governor_policy_effect(effect: Dictionary, governor_policy_id: String, chancellor_policy_id: String) -> void:
	match governor_policy_id:
		"agriculture":
			effect["rice_multiplier"] = clampf(float(effect.get("rice_multiplier", 1.0)) * 1.08, 0.75, 1.35)
			effect["barley_multiplier"] = clampf(float(effect.get("barley_multiplier", 1.0)) * 1.08, 0.75, 1.35)
			effect["gold_multiplier"] = clampf(float(effect.get("gold_multiplier", 1.0)) * 0.97, 0.75, 1.4)
		"commerce":
			effect["gold_multiplier"] = clampf(float(effect.get("gold_multiplier", 1.0)) * 1.08, 0.75, 1.4)
			effect["rice_multiplier"] = clampf(float(effect.get("rice_multiplier", 1.0)) * 0.97, 0.75, 1.35)
			effect["barley_multiplier"] = clampf(float(effect.get("barley_multiplier", 1.0)) * 0.97, 0.75, 1.35)
		"military":
			effect["gold_multiplier"] = clampf(float(effect.get("gold_multiplier", 1.0)) * 0.97, 0.75, 1.4)
			effect["recruitable_troops_bonus"] = int(effect.get("recruitable_troops_bonus", 0)) + 40
		"follow_chancellor":
			if chancellor_policy_id == "agriculture":
				effect["rice_multiplier"] = clampf(float(effect.get("rice_multiplier", 1.0)) * 1.03, 0.75, 1.35)
				effect["barley_multiplier"] = clampf(float(effect.get("barley_multiplier", 1.0)) * 1.03, 0.75, 1.35)
			elif chancellor_policy_id == "commerce" or chancellor_policy_id == "trade":
				effect["gold_multiplier"] = clampf(float(effect.get("gold_multiplier", 1.0)) * 1.03, 0.75, 1.4)
			elif chancellor_policy_id == "military":
				effect["recruitable_troops_bonus"] = int(effect.get("recruitable_troops_bonus", 0)) + 20


func _apply_income_multipliers_to_totals(totals: Dictionary, effect: Dictionary) -> Dictionary:
	return {
		"rice": maxi(0, int(round(float(totals.get("rice", 0)) * float(effect.get("rice_multiplier", 1.0))))),
		"barley": maxi(0, int(round(float(totals.get("barley", 0)) * float(effect.get("barley_multiplier", 1.0))))),
		"seafood": maxi(0, int(round(float(totals.get("seafood", 0)) * float(effect.get("seafood_multiplier", 1.0))))),
		"gold": maxi(0, int(round(float(totals.get("gold", 0)) * float(effect.get("gold_multiplier", 1.0))))),
	}


func _apply_supply_income_effect(effect: Dictionary, supply_state: Dictionary) -> void:
	var income_multiplier := float(supply_state.get("income_multiplier", 1.0))
	if is_equal_approx(income_multiplier, 1.0):
		return
	effect["rice_multiplier"] = float(effect.get("rice_multiplier", 1.0)) * income_multiplier
	effect["barley_multiplier"] = float(effect.get("barley_multiplier", 1.0)) * income_multiplier
	effect["seafood_multiplier"] = float(effect.get("seafood_multiplier", 1.0)) * income_multiplier
	effect["gold_multiplier"] = float(effect.get("gold_multiplier", 1.0)) * income_multiplier


func _get_supply_city_state(supply_states: Dictionary, city_id: String) -> Dictionary:
	var city_states: Variant = supply_states.get("city_states", {})
	if city_states is Dictionary:
		var state: Variant = (city_states as Dictionary).get(city_id, {})
		if state is Dictionary:
			return state
	return {}


func _create_empty_inter_faction_trade_totals() -> Dictionary:
	return {"gold": 0, "rice": 0, "barley": 0, "seafood": 0, "salt": 0}


func _make_faction_relation_key(faction_a: String, faction_b: String) -> String:
	var ids := [faction_a, faction_b]
	ids.sort()
	return "%s|%s" % [str(ids[0]), str(ids[1])]


func _get_faction_relation_status(faction_a: String, faction_b: String) -> String:
	if faction_a.is_empty() or faction_b.is_empty() or faction_a == faction_b:
		return FACTION_RELATION_STATUS["NEUTRAL"]
	var relations: Dictionary = _player_state.get("faction_relations", {})
	var relation_key := _make_faction_relation_key(faction_a, faction_b)
	var raw_relation: Variant = relations.get(relation_key, FACTION_RELATION_STATUS["NEUTRAL"])
	var status := ""
	if raw_relation is Dictionary:
		status = str((raw_relation as Dictionary).get("status", FACTION_RELATION_STATUS["NEUTRAL"]))
	else:
		status = str(raw_relation)
	match status:
		"allied", "trade":
			return FACTION_RELATION_STATUS["ALLIED"]
		"hostile", "war":
			return FACTION_RELATION_STATUS["HOSTILE"]
		"suspended", "trade_suspended", "trade_paused":
			return FACTION_RELATION_STATUS["SUSPENDED"]
		_:
			return FACTION_RELATION_STATUS["NEUTRAL"]


func _can_trade_between_factions(faction_a: String, faction_b: String) -> bool:
	if faction_a.is_empty() or faction_b.is_empty() or faction_a == faction_b:
		return false
	var status := _get_faction_relation_status(faction_a, faction_b)
	return status == FACTION_RELATION_STATUS["NEUTRAL"] or status == FACTION_RELATION_STATUS["ALLIED"]


func _make_trade_pair_key(city_a_id: String, city_b_id: String) -> String:
	var ids := [city_a_id, city_b_id]
	ids.sort()
	return "%s|%s" % [str(ids[0]), str(ids[1])]


func _calculate_trade_route_value(city_a: Dictionary, city_b: Dictionary) -> Dictionary:
	var city_a_id := str(city_a.get("id", ""))
	var city_b_id := str(city_b.get("id", ""))
	var faction_a := _get_city_owner_faction_id(city_a)
	var faction_b := _get_city_owner_faction_id(city_b)
	var relation_status := _get_faction_relation_status(faction_a, faction_b)
	var resource_seed_a: Dictionary = city_a.get("resource_seed", {})
	var resource_seed_b: Dictionary = city_b.get("resource_seed", {})
	var base_gold := (_get_city_numeric_rating(city_a, "commerce_rating", 0) + _get_city_numeric_rating(city_b, "commerce_rating", 0)) * 3
	var average_loyalty := (float(_get_city_loyalty_value(city_a)) + float(_get_city_loyalty_value(city_b))) / 2.0
	var loyalty_multiplier := 1.0
	if average_loyalty >= 75.0:
		loyalty_multiplier = 1.05
	elif average_loyalty < 50.0:
		loyalty_multiplier = 0.9
	var relation_multiplier := float(RELATION_TRADE_MULTIPLIER.get(relation_status, 1.0))
	var multiplier := loyalty_multiplier * relation_multiplier * TRADE_GLOBAL_DAMPENER
	return {
		"city_a_id": city_a_id,
		"city_b_id": city_b_id,
		"faction_a": faction_a,
		"faction_b": faction_b,
		"relation_status": relation_status,
		"gold": int(floor(clampf(float(base_gold) * multiplier, 0.0, float(TRADE_ROUTE_CAP.get("gold", 90))))),
		"rice": int(floor(clampf(float(_get_rating(resource_seed_a, "rice") + _get_rating(resource_seed_b, "rice")) * TRADE_FOOD_FACTOR * multiplier, 0.0, float(TRADE_ROUTE_CAP.get("rice", 20))))),
		"barley": int(floor(clampf(float(_get_rating(resource_seed_a, "barley") + _get_rating(resource_seed_b, "barley")) * TRADE_FOOD_FACTOR * multiplier, 0.0, float(TRADE_ROUTE_CAP.get("barley", 20))))),
		"seafood": int(floor(clampf(float(_get_rating(resource_seed_a, "seafood") + _get_rating(resource_seed_b, "seafood")) * TRADE_FOOD_FACTOR * multiplier, 0.0, float(TRADE_ROUTE_CAP.get("seafood", 22))))),
		"salt": int(floor(clampf(float(_get_rating(resource_seed_a, "salt") + _get_rating(resource_seed_b, "salt")) * TRADE_FOOD_FACTOR * multiplier, 0.0, float(TRADE_ROUTE_CAP.get("salt", 16))))),
	}


func _calculate_inter_faction_trade_result(turn_number: int) -> Dictionary:
	var routes: Array = []
	var seen_route_keys := {}
	var player_totals := _create_empty_inter_faction_trade_totals()
	var owned_city_ids: Variant = _player_state.get("owned_city_ids", [])
	if not owned_city_ids is Array:
		return {"turn": turn_number, "route_count": 0, "player_totals": player_totals, "routes": routes}
	for city_id_variant in owned_city_ids:
		var city_id := str(city_id_variant)
		var city_a := _get_city_hud_entry(city_id)
		var city_marker := _city_markers_by_id.get(city_id) as WorldMapCityMarker
		if city_a.is_empty() or city_marker == null:
			continue
		var faction_a := _get_city_owner_faction_id(city_a)
		for neighbor_id_variant in city_marker.neighbors:
			var neighbor_id := str(neighbor_id_variant)
			var city_b := _get_city_hud_entry(neighbor_id)
			if city_b.is_empty():
				continue
			var faction_b := _get_city_owner_faction_id(city_b)
			if faction_a == faction_b or not _can_trade_between_factions(faction_a, faction_b):
				continue
			var route_key := _make_trade_pair_key(city_id, neighbor_id)
			if seen_route_keys.has(route_key):
				continue
			seen_route_keys[route_key] = true
			var route := _calculate_trade_route_value(city_a, city_b)
			routes.append(route)
			for resource_id in player_totals.keys():
				player_totals[resource_id] = int(player_totals.get(resource_id, 0)) + int(route.get(resource_id, 0))
	return {
		"turn": turn_number,
		"route_count": routes.size(),
		"player_totals": player_totals,
		"routes": routes,
	}


func _apply_player_inter_faction_trade_income(turn_number: int) -> Dictionary:
	var result := _calculate_inter_faction_trade_result(turn_number)
	var applied_totals := _apply_resource_delta(result.get("player_totals", {}))
	result["applied_player_totals"] = applied_totals
	_player_state["last_inter_faction_trade_result"] = result
	print("[INTER_FACTION_TRADE_INCOME] turn=%d routes=%d applied=%s" % [
		turn_number,
		int(result.get("route_count", 0)),
		str(applied_totals),
	])
	return result


func _get_city_owner_faction_id(city_data: Dictionary) -> String:
	return str(city_data.get("owner_faction_id", city_data.get("owner", city_data.get("nation", ""))))


func _get_player_supply_hub_id() -> String:
	var owned_city_ids: Variant = _player_state.get("owned_city_ids", [])
	if not owned_city_ids is Array:
		return ""
	var selected_hub_id := ""
	var selected_population := -1
	for city_id_variant in owned_city_ids:
		var city_id := str(city_id_variant)
		var city_data := _get_city_hud_entry(city_id)
		if city_data.is_empty() or _get_city_owner_faction_id(city_data) != PLAYER_FACTION_ID:
			continue
		var population := maxi(0, int(city_data.get("population", 0)))
		if population > selected_population:
			selected_population = population
			selected_hub_id = city_id
	return selected_hub_id


func _is_city_supply_connected(city_id: String, hub_id: String) -> bool:
	if city_id.is_empty() or hub_id.is_empty():
		return false
	if city_id == hub_id:
		return true
	var city_data := _get_city_hud_entry(city_id)
	if city_data.is_empty() or _get_city_owner_faction_id(city_data) != PLAYER_FACTION_ID:
		return false
	var visited := {}
	var queue: Array[String] = [city_id]
	while not queue.is_empty():
		var current_city_id := str(queue.pop_front())
		if current_city_id == hub_id:
			return true
		if visited.has(current_city_id):
			continue
		visited[current_city_id] = true
		var city_marker := _city_markers_by_id.get(current_city_id) as WorldMapCityMarker
		if city_marker == null:
			continue
		for neighbor_id_variant in city_marker.neighbors:
			var neighbor_id := str(neighbor_id_variant)
			if visited.has(neighbor_id):
				continue
			var neighbor_data := _get_city_hud_entry(neighbor_id)
			if neighbor_data.is_empty() or _get_city_owner_faction_id(neighbor_data) != PLAYER_FACTION_ID:
				continue
			queue.append(neighbor_id)
	return false


func _calculate_city_supply_state(city_id: String, hub_id: String) -> Dictionary:
	var city_data := _get_city_hud_entry(city_id)
	if city_data.is_empty() or _get_city_owner_faction_id(city_data) != PLAYER_FACTION_ID:
		return {}
	var role := "rear"
	var has_enemy_neighbor := false
	var city_marker := _city_markers_by_id.get(city_id) as WorldMapCityMarker
	if city_marker != null:
		for neighbor_id_variant in city_marker.neighbors:
			var neighbor_data := _get_city_hud_entry(str(neighbor_id_variant))
			if not neighbor_data.is_empty() and _get_city_owner_faction_id(neighbor_data) != PLAYER_FACTION_ID:
				has_enemy_neighbor = true
				break
	if city_id == hub_id:
		role = "hub"
	elif has_enemy_neighbor:
		role = "frontline"
	var supplied := true if role == "hub" else _is_city_supply_connected(city_id, hub_id)
	var isolated := role != "hub" and not supplied
	var income_multiplier := 1.0
	var loyalty_delta := 0
	var security_delta := 0
	if role == "frontline":
		if supplied:
			income_multiplier = SUPPLY_INCOME_BONUS
			loyalty_delta = SUPPLY_LOYALTY_BONUS
			security_delta = SUPPLY_SECURITY_BONUS
		elif isolated:
			income_multiplier = SUPPLY_INCOME_PENALTY
			loyalty_delta = SUPPLY_LOYALTY_PENALTY
			security_delta = SUPPLY_SECURITY_PENALTY
	return {
		"city_id": city_id,
		"hub_id": hub_id,
		"role": role,
		"supplied": supplied,
		"isolated": isolated,
		"income_multiplier": income_multiplier,
		"loyalty_delta": loyalty_delta,
		"security_delta": security_delta,
	}


func _calculate_all_city_supply_states() -> Dictionary:
	var hub_id := _get_player_supply_hub_id()
	var city_states := {}
	var supplied_frontline_count := 0
	var isolated_count := 0
	var owned_city_ids: Variant = _player_state.get("owned_city_ids", [])
	if owned_city_ids is Array:
		for city_id_variant in owned_city_ids:
			var city_id := str(city_id_variant)
			var city_state := _calculate_city_supply_state(city_id, hub_id)
			if city_state.is_empty():
				continue
			city_states[city_id] = city_state
			if str(city_state.get("role", "")) == "frontline" and bool(city_state.get("supplied", false)):
				supplied_frontline_count += 1
			if bool(city_state.get("isolated", false)):
				isolated_count += 1
	var result := {
		"hub_id": hub_id,
		"supplied_frontline_count": supplied_frontline_count,
		"isolated_count": isolated_count,
		"city_states": city_states,
	}
	_player_state["last_supply_state_result"] = result
	return result


func _get_city_loyalty_value(city_data: Dictionary) -> int:
	return clampi(int(city_data.get("cityLoyalty", city_data.get("loyalty", 75))), 0, 100)


func _get_city_public_support(city_id: String) -> int:
	var city_data := _get_city_hud_entry(city_id)
	if city_data.is_empty():
		return CITY_PUBLIC_SUPPORT_DEFAULT
	return clampi(int(city_data.get("publicSupport", CITY_PUBLIC_SUPPORT_DEFAULT)), 0, 100)


func _set_city_public_support(city_id: String, value: int) -> void:
	var city_data := _get_mutable_city_runtime_state(city_id)
	if city_data.is_empty():
		return
	city_data["publicSupport"] = clampi(value, 0, 100)
	_city_runtime_states[city_id] = city_data


func _calculate_city_public_support_delta(city_id: String, tax_level: int, supply_state: Dictionary = {}) -> Dictionary:
	var normalized_tax := _normalize_tax_level(tax_level)
	var tax_delta := 1
	if normalized_tax > 90:
		tax_delta = -3
	elif normalized_tax > 60:
		tax_delta = -2
	elif normalized_tax > 30:
		tax_delta = -1
	var food_delta := 1 if _has_city_public_support_food_surplus(city_id) else -1
	var commerce_delta := 1 if _has_city_public_support_commerce_surplus(city_id) else -1
	var supply_delta := -2 if bool(supply_state.get("isolated", false)) else 0
	var delta := clampi(tax_delta + food_delta + commerce_delta + supply_delta, PUBLIC_SUPPORT_DELTA_MIN, PUBLIC_SUPPORT_DELTA_MAX)
	var reasons: Array[String] = [
		"tax=%s" % _format_signed_int(tax_delta),
		"food=%s" % _format_signed_int(food_delta),
		"commerce=%s" % _format_signed_int(commerce_delta),
		"supply=%s" % _format_signed_int(supply_delta),
	]
	return {
		"city_id": city_id,
		"delta": delta,
		"reasons": reasons,
		"tax_delta": tax_delta,
		"food_delta": food_delta,
		"commerce_delta": commerce_delta,
		"supply_delta": supply_delta,
		"supply_state": supply_state,
	}


func _has_city_public_support_food_surplus(_city_id: String) -> bool:
	var last_domestic: Dictionary = _player_state.get("last_domestic_apply_result", {})
	var income_delta: Variant = last_domestic.get("income_delta", {})
	if income_delta is Dictionary:
		var recent_food := int((income_delta as Dictionary).get("rice", 0)) + int((income_delta as Dictionary).get("barley", 0)) + int((income_delta as Dictionary).get("seafood", 0))
		if recent_food != 0:
			return recent_food > 0
	var resource_stock: Dictionary = _player_state.get("resource_stock", {})
	return int(resource_stock.get("rice", 0)) + int(resource_stock.get("barley", 0)) + int(resource_stock.get("seafood", 0)) > 0


func _has_city_public_support_commerce_surplus(_city_id: String) -> bool:
	var last_domestic: Dictionary = _player_state.get("last_domestic_apply_result", {})
	var income_delta: Variant = last_domestic.get("income_delta", {})
	if income_delta is Dictionary and int((income_delta as Dictionary).get("gold", 0)) != 0:
		return int((income_delta as Dictionary).get("gold", 0)) > 0
	var last_trade: Variant = _player_state.get("last_inter_faction_trade_result", {})
	var applied_trade: Variant = {}
	if last_trade is Dictionary:
		applied_trade = (last_trade as Dictionary).get("applied_player_totals", {})
	if applied_trade is Dictionary and int((applied_trade as Dictionary).get("gold", 0)) != 0:
		return int((applied_trade as Dictionary).get("gold", 0)) > 0
	var resource_stock: Dictionary = _player_state.get("resource_stock", {})
	return int(resource_stock.get("gold", 0)) > 0


func _apply_city_public_support_drift_for_world_turn(tax_level: int, supply_states: Dictionary = {}) -> Dictionary:
	var result := {
		"turn": maxi(1, int(_player_state.get("turn_number", 1))),
		"city_results": {},
	}
	var owned_city_ids: Variant = _player_state.get("owned_city_ids", [])
	if not owned_city_ids is Array:
		_player_state["last_public_support_result"] = result
		return result
	for city_id_variant in owned_city_ids:
		var city_id := str(city_id_variant)
		var city_data := _get_mutable_city_runtime_state(city_id)
		if city_data.is_empty():
			continue
		var before_support := _get_city_public_support(city_id)
		var drift := _calculate_city_public_support_delta(city_id, tax_level, _get_supply_city_state(supply_states, city_id))
		var after_support := clampi(before_support + int(drift.get("delta", 0)), 0, 100)
		city_data["publicSupport"] = after_support
		_city_runtime_states[city_id] = city_data
		var city_result := {
			"before": before_support,
			"after": after_support,
			"delta": after_support - before_support,
			"reasons": drift.get("reasons", []),
			"tax_delta": int(drift.get("tax_delta", 0)),
			"food_delta": int(drift.get("food_delta", 0)),
			"commerce_delta": int(drift.get("commerce_delta", 0)),
			"supply_delta": int(drift.get("supply_delta", 0)),
		}
		(result["city_results"] as Dictionary)[city_id] = city_result
		print("[PUBLIC_SUPPORT_DRIFT] city=%s before=%d delta=%d after=%d reasons=%s" % [
			city_id,
			before_support,
			int(city_result.get("delta", 0)),
			after_support,
			str(city_result.get("reasons", [])),
		])
	_player_state["last_public_support_result"] = result
	_refresh_city_hud_data_bindings()
	return result


func _calculate_loyalty_delta_from_public_support(public_support: int) -> int:
	var value := clampi(public_support, 0, 100)
	if value >= 90:
		return 2
	if value >= 80:
		return 1
	if value >= 60:
		return -1
	if value >= 40:
		return -2
	return -3


func _apply_seasonal_loyalty_from_public_support(turn_number: int, supply_states: Dictionary = {}) -> Dictionary:
	var safe_turn := maxi(1, turn_number)
	var result := {
		"turn": safe_turn,
		"applied": false,
		"city_results": {},
	}
	if not _is_seasonal_loyalty_turn(safe_turn):
		result["next_turn"] = _get_next_seasonal_loyalty_turn(safe_turn)
		result["reason"] = "not_seasonal_turn"
		_player_state["last_seasonal_loyalty_result"] = result
		return result
	var owned_city_ids: Variant = _player_state.get("owned_city_ids", [])
	if not owned_city_ids is Array:
		result["applied"] = true
		_player_state["last_seasonal_loyalty_result"] = result
		return result
	result["applied"] = true
	for city_id_variant in owned_city_ids:
		var city_id := str(city_id_variant)
		var city_data := _get_mutable_city_runtime_state(city_id)
		if city_data.is_empty():
			continue
		var public_support := _get_city_public_support(city_id)
		var before_loyalty := _get_city_loyalty_value(city_data)
		var delta := _calculate_loyalty_delta_from_public_support(public_support)
		var after_loyalty := clampi(before_loyalty + delta, 0, 100)
		city_data["loyalty"] = after_loyalty
		city_data["cityLoyalty"] = after_loyalty
		_city_runtime_states[city_id] = city_data
		var reasons: Array[String] = ["publicSupport=%d" % public_support]
		var city_result := {
			"publicSupport": public_support,
			"before_loyalty": before_loyalty,
			"after_loyalty": after_loyalty,
			"delta": after_loyalty - before_loyalty,
			"raw_delta": delta,
			"reasons": reasons,
		}
		(result["city_results"] as Dictionary)[city_id] = city_result
		print("[SEASONAL_LOYALTY_PUBLIC_SUPPORT] turn=%d city=%s publicSupport=%d before=%d delta=%d after=%d" % [
			safe_turn,
			city_id,
			public_support,
			before_loyalty,
			int(city_result.get("delta", 0)),
			after_loyalty,
		])
	_player_state["last_seasonal_loyalty_result"] = result
	_refresh_city_hud_data_bindings()
	return result


func _apply_city_loyalty_drift_for_world_turn(tax_level: int, policy_id: String, supply_states: Dictionary = {}) -> Dictionary:
	var result := {"tax_level": tax_level, "policy_id": policy_id, "cities": []}
	var owned_city_ids: Variant = _player_state.get("owned_city_ids", [])
	if not owned_city_ids is Array:
		_player_state["last_city_loyalty_drift_result"] = result
		return result
	for city_id_variant in owned_city_ids:
		var city_id := str(city_id_variant)
		var city_data := _get_mutable_city_runtime_state(city_id)
		if city_data.is_empty():
			continue
		var before_loyalty := _get_city_loyalty_value(city_data)
		var drift := _calculate_city_loyalty_drift(city_data, tax_level, policy_id, _get_supply_city_state(supply_states, city_id))
		var after_loyalty := clampi(before_loyalty + int(drift.get("delta", 0)), 0, 100)
		city_data["loyalty"] = after_loyalty
		city_data["cityLoyalty"] = after_loyalty
		_city_runtime_states[city_id] = city_data
		drift["before_loyalty"] = before_loyalty
		drift["after_loyalty"] = after_loyalty
		(result["cities"] as Array).append(drift)
		print("[CITY_LOYALTY_DRIFT] city=%s before=%d delta=%d after=%d reasons=%s" % [
			city_id,
			before_loyalty,
			int(drift.get("delta", 0)),
			after_loyalty,
			str(drift.get("reasons", [])),
		])
	_player_state["last_city_loyalty_drift_result"] = result
	_refresh_city_hud_data_bindings()
	return result


func _calculate_city_loyalty_drift(city_data: Dictionary, tax_level: int, policy_id: String, supply_state: Dictionary = {}) -> Dictionary:
	var city_effects := _calculate_city_domestic_effects(city_data, policy_id)
	var tax_delta := _adjust_loyalty_delta(_get_tax_loyalty_delta(tax_level), float(city_effects.get("city_loyalty_loss_multiplier", 1.0)))
	var garrison_troops := maxi(0, int(city_data.get("troops", 0)))
	var stationed_hero_troops := 0
	for hero_id in _get_stationed_hero_ids_for_city(city_data):
		var hero_data := _get_hero_entry(str(hero_id))
		stationed_hero_troops += maxi(0, int(hero_data.get("troops", hero_data.get("troop_count", 0))))
	var security_troops := int(round(float(garrison_troops) + (float(stationed_hero_troops) * STATIONED_HERO_SECURITY_WEIGHT)))
	var security_required_troops := _get_city_security_required_troops(city_data)
	var security_delta := 0
	if security_troops >= int(ceil(float(security_required_troops) * 1.2)):
		security_delta = 1
	elif security_troops < security_required_troops:
		security_delta = -1
	var supply_security_delta := int(supply_state.get("security_delta", 0))
	security_delta += supply_security_delta
	var commerce_rating := _get_city_numeric_rating(city_data, "commerce_rating", 3)
	var population_rating := _get_city_numeric_rating(city_data, "population_rating", 3)
	var economy_score := clampi((commerce_rating * 10) + (population_rating * 8) + int(round((float(city_effects.get("gold_multiplier", 1.0)) - 1.0) * 80.0)), 0, 100)
	var economy_delta := 0
	if economy_score >= 75:
		economy_delta = 1
	elif economy_score < 50:
		economy_delta = -1
	var population := maxi(1, int(city_data.get("population", 30000)))
	var troop_population_ratio := float(garrison_troops) / float(population)
	var military_burden_delta := 0
	if troop_population_ratio > 0.45:
		military_burden_delta = -2
	elif troop_population_ratio > 0.35:
		military_burden_delta = -1
	var supply_delta := int(supply_state.get("loyalty_delta", 0))
	var preliminary_delta := tax_delta + security_delta + economy_delta + military_burden_delta + supply_delta
	var governor_id := str(city_data.get("governor_id", city_data.get("governorHeroId", "")))
	var governor_data := _get_hero_entry(governor_id)
	var control_delta := 0
	if preliminary_delta < 0 and not governor_data.is_empty() and (_governor_has_aptitude(governor_data, "administrative", 3) or _governor_has_aptitude(governor_data, "political", 3)):
		control_delta = 1
	var delta := clampi(preliminary_delta + control_delta, CITY_LOYALTY_DRIFT_MIN, CITY_LOYALTY_DRIFT_MAX)
	var reasons: Array[String] = []
	if tax_delta != 0:
		reasons.append("tax=%s" % _format_signed_int(tax_delta))
	if security_delta != 0:
		reasons.append("security=%s" % _format_signed_int(security_delta))
	if economy_delta != 0:
		reasons.append("economy=%s" % _format_signed_int(economy_delta))
	if military_burden_delta != 0:
		reasons.append("military=%s" % _format_signed_int(military_burden_delta))
	if supply_delta != 0:
		reasons.append("supply=%s" % _format_signed_int(supply_delta))
	if supply_security_delta != 0:
		reasons.append("supply_security=%s" % _format_signed_int(supply_security_delta))
	if control_delta != 0:
		reasons.append("control=%s" % _format_signed_int(control_delta))
	return {
		"city_id": str(city_data.get("id", "")),
		"delta": delta,
		"tax_delta": tax_delta,
		"security_delta": security_delta,
		"supply_delta": supply_delta,
		"supply_security_delta": supply_security_delta,
		"economy_delta": economy_delta,
		"military_burden_delta": military_burden_delta,
		"control_delta": control_delta,
		"security_troops": security_troops,
		"security_required_troops": security_required_troops,
		"economy_score": economy_score,
		"troop_population_ratio": troop_population_ratio,
		"city_loyalty_loss_multiplier": float(city_effects.get("city_loyalty_loss_multiplier", 1.0)),
		"supply_state": supply_state,
		"reasons": reasons,
	}


func _get_city_security_required_troops(city_data: Dictionary) -> int:
	var military_text := str(city_data.get("military", ""))
	var marker := "치안 기준"
	var marker_index := military_text.find(marker)
	if marker_index >= 0:
		var number_text := ""
		for index in range(marker_index + marker.length(), military_text.length()):
			var character := military_text.substr(index, 1)
			if character >= "0" and character <= "9":
				number_text += character
			elif not number_text.is_empty():
				break
		if not number_text.is_empty():
			return maxi(1, int(number_text))
	return 500


func _governor_has_aptitude(governor_data: Dictionary, type_id: String, threshold: int) -> bool:
	if governor_data.is_empty() or type_id.is_empty():
		return false
	var aptitude := 0.0
	if str(governor_data.get("chancellor_primary_type", "")) == type_id:
		aptitude += float(governor_data.get("chancellor_primary_aptitude", 0))
	if str(governor_data.get("chancellor_secondary_type", "")) == type_id:
		aptitude += float(governor_data.get("chancellor_secondary_aptitude", 0)) * 0.5
	return aptitude >= float(threshold)


func _calculate_player_hero_upkeep_delta(policy_id: String, national_effects: Dictionary, supply_states: Dictionary = {}) -> Dictionary:
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
	var supplied_frontline_count := maxi(0, int(supply_states.get("supplied_frontline_count", 0)))
	var supply_upkeep_multiplier := maxf(SUPPLY_UPKEEP_DISCOUNT_FLOOR, 1.0 - (SUPPLY_UPKEEP_DISCOUNT_PER_CITY * float(supplied_frontline_count)))
	var upkeep_multiplier := float(policy_data.get("hero_upkeep_multiplier", 1.0)) * float(national_effects.get("hero_upkeep_multiplier", 1.0)) * supply_upkeep_multiplier
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


func _format_domestic_apply_summary(resource_delta: Dictionary, loyalty_delta: int, inter_faction_trade_result: Dictionary = {}, supply_state_result: Dictionary = {}, city_loyalty_drift_result: Dictionary = {}, public_support_result: Dictionary = {}, seasonal_loyalty_result: Dictionary = {}, conscription_result: Dictionary = {}, revolt_warning_result: Dictionary = {}) -> String:
	var parts: Array[String] = []
	for resource_id in RESOURCE_DISPLAY_ORDER:
		var delta := int(resource_delta.get(resource_id, 0))
		if delta == 0:
			continue
		parts.append("%s %s" % [str(RESOURCE_LABELS.get(resource_id, resource_id)), _format_signed_int(delta)])
	if loyalty_delta != 0:
		parts.append("충성도 %s" % _format_signed_int(loyalty_delta))
	if not inter_faction_trade_result.is_empty():
		parts.append(_format_inter_faction_trade_summary(inter_faction_trade_result))
	if not supply_state_result.is_empty():
		parts.append(_format_supply_state_summary(supply_state_result))
	if not city_loyalty_drift_result.is_empty():
		parts.append(_format_city_loyalty_drift_summary(city_loyalty_drift_result))
	if not public_support_result.is_empty():
		parts.append(_format_public_support_summary(public_support_result))
	if bool(seasonal_loyalty_result.get("applied", false)):
		parts.append(_format_seasonal_loyalty_summary(seasonal_loyalty_result))
	if bool(conscription_result.get("applied", false)):
		parts.append(_format_conscription_summary(conscription_result))
	if not revolt_warning_result.is_empty():
		parts.append(_format_revolt_warning_summary(revolt_warning_result))
	if parts.is_empty():
		return "변동 없음"
	return " · ".join(parts)


func _format_inter_faction_trade_summary(result: Dictionary) -> String:
	var applied_totals := _get_trade_display_totals(result)
	var trade_parts: Array[String] = []
	for resource_id in ["gold", "rice", "barley", "seafood", "salt"]:
		var delta := int(applied_totals.get(resource_id, 0))
		if delta != 0:
			trade_parts.append("%s %s" % [str(RESOURCE_LABELS.get(resource_id, resource_id)), _format_signed_int(delta)])
	if trade_parts.is_empty():
		return "무역 수입 없음"
	return "무역 수입 %d개: %s" % [int(result.get("route_count", 0)), " / ".join(trade_parts)]


func _format_supply_state_summary(result: Dictionary) -> String:
	if result.is_empty():
		return "보급 상태 없음"
	return "보급 hub %s · supplied frontline %d · isolated %d" % [
		_format_city_name_by_id(str(result.get("hub_id", "")), str(result.get("hub_id", "-"))),
		int(result.get("supplied_frontline_count", 0)),
		int(result.get("isolated_count", 0)),
	]


func _format_conscription_summary(result: Dictionary) -> String:
	var city_results: Variant = result.get("city_results", {})
	if not city_results is Dictionary:
		return "징병 +0"
	var total_added := 0
	var changed_cities := 0
	for city_id_variant in (city_results as Dictionary).keys():
		var city_result: Variant = (city_results as Dictionary).get(city_id_variant, {})
		if not city_result is Dictionary:
			continue
		var added := int((city_result as Dictionary).get("added", 0))
		total_added += added
		if added > 0:
			changed_cities += 1
	return "징병 +%d · %d개 도시" % [total_added, changed_cities]


func _format_revolt_warning_summary(result: Dictionary) -> String:
	var warning_count := int(result.get("warning_count", 0))
	var danger_count := int(result.get("danger_count", 0))
	if danger_count > 0:
		return "반란 위험 도시 %d개 · 경고 %d개" % [danger_count, warning_count]
	if warning_count > 0:
		return "반란 경고 도시 %d개" % warning_count
	return "반란 경고 0개 · 위험 0개"


func _format_city_loyalty_drift_summary(result: Dictionary) -> String:
	var cities: Variant = result.get("cities", [])
	if not cities is Array or (cities as Array).is_empty():
		return "도시 충성도 변동 없음"
	var changed_count := 0
	var large_drop_parts: Array[String] = []
	for city_drift_variant in cities:
		if not city_drift_variant is Dictionary:
			continue
		var city_drift := city_drift_variant as Dictionary
		var delta := int(city_drift.get("delta", 0))
		if delta != 0:
			changed_count += 1
		if delta <= -2:
			var city_id := str(city_drift.get("city_id", ""))
			large_drop_parts.append("%s %s" % [_format_city_name_by_id(city_id, city_id), _format_signed_int(delta)])
	if large_drop_parts.is_empty():
		return "도시 충성도 변동 %d개" % changed_count
	return "도시 충성도 변동 %d개 · 하락 %s" % [changed_count, " / ".join(large_drop_parts)]


func _format_public_support_summary(result: Dictionary) -> String:
	var city_results: Variant = result.get("city_results", {})
	if not city_results is Dictionary or (city_results as Dictionary).is_empty():
		return "민심 변동 없음"
	var changed_count := 0
	var drop_parts: Array[String] = []
	for city_id_variant in (city_results as Dictionary).keys():
		var city_id := str(city_id_variant)
		var city_result: Variant = (city_results as Dictionary).get(city_id, {})
		if not city_result is Dictionary:
			continue
		var delta := int((city_result as Dictionary).get("delta", 0))
		if delta != 0:
			changed_count += 1
		if delta < 0:
			drop_parts.append("%s %s" % [_format_city_name_by_id(city_id, city_id), _format_signed_int(delta)])
	if drop_parts.is_empty():
		return "민심 변동 %d개" % changed_count
	return "민심 변동 %d개 · 하락 %s" % [changed_count, " / ".join(drop_parts)]


func _format_seasonal_loyalty_summary(result: Dictionary) -> String:
	var city_results: Variant = result.get("city_results", {})
	if not city_results is Dictionary or (city_results as Dictionary).is_empty():
		return "계절 충성도 반영 없음"
	var changed_count := 0
	var parts: Array[String] = []
	for city_id_variant in (city_results as Dictionary).keys():
		var city_id := str(city_id_variant)
		var city_result: Variant = (city_results as Dictionary).get(city_id, {})
		if not city_result is Dictionary:
			continue
		var delta := int((city_result as Dictionary).get("delta", 0))
		if delta != 0:
			changed_count += 1
			parts.append("%s %s" % [_format_city_name_by_id(city_id, city_id), _format_signed_int(delta)])
	if parts.is_empty():
		return "계절 충성도 반영 %d개" % changed_count
	return "계절 충성도 반영 %d개: %s" % [changed_count, " / ".join(parts)]


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
	var city_state := _serialize_worldmap_city_runtime_state()
	var hero_state := _serialize_worldmap_hero_runtime_state()
	print("[SAVE_WORLD_STATE] city_overrides=%d hero_overrides=%d pending_invasion_cleared=true" % [
		city_state.size(),
		hero_state.size()
	])
	return {
		"version": "v0.68b-12b-19",
		"title": "WorldMap Battle Result Save Load Persistence MVP",
		"player_state": saved_player_state,
		"worldmap_city_state": city_state,
		"worldmap_hero_state": hero_state,
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
	_city_runtime_states.clear()
	_hero_runtime_states.clear()
	_apply_worldmap_city_runtime_state(data.get("worldmap_city_state", {}))
	_apply_worldmap_hero_runtime_state(data.get("worldmap_hero_state", {}))
	_sync_worldmap_hero_locations_from_city_runtime_states()
	_refresh_city_marker_owner_states_from_runtime()
	_refresh_city_hud_data_bindings()
	_clear_pending_invasion_event_mvp()
	_domestic_turn_apply_pending = bool(_player_state.get("domestic_apply_pending", false))
	if _normalize_turn_phase(str(_player_state.get("turn_phase", TURN_PHASE_PLAYER))) == TURN_PHASE_ENEMY:
		_player_state["turn_phase"] = TURN_PHASE_PLAYER
		_player_state["current_phase_label"] = _get_turn_phase_label(TURN_PHASE_PLAYER)
	_domestic_turn_apply_pending = false
	_player_state["domestic_apply_pending"] = false
	print("[LOAD_WORLD_STATE] city_overrides=%d hero_overrides=%d pending_invasion_cleared=true" % [
		_city_runtime_states.size(),
		_hero_runtime_states.size()
	])
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
	_clear_post_battle_result_summary()
	_refresh_left_world_status_panel()
	_refresh_unified_panel_content()
	_set_save_management_status("불러오기 완료")
	if _normalize_turn_phase(str(_player_state.get("turn_phase", TURN_PHASE_PLAYER))) == TURN_PHASE_ENEMY:
		_run_enemy_turn_mvp()


func _reset_worldmap_state() -> void:
	_cancel_enemy_turn_timer_if_needed()
	_player_state = _get_default_player_state()
	_ensure_worldmap_runtime_state_defaults()
	_city_runtime_states.clear()
	_hero_runtime_states.clear()
	_refresh_city_marker_owner_states_from_runtime()
	_refresh_city_hud_data_bindings()
	_clear_pending_invasion_event_mvp()
	_clear_post_battle_result_summary()
	_refresh_left_world_status_panel()
	_refresh_unified_panel_content()
	_set_save_management_status("초기화 완료")


func _get_city_hud_entry(city_id: String) -> Dictionary:
	if _city_runtime_states.has(city_id):
		var runtime_city_state: Variant = _city_runtime_states.get(city_id, {})
		if runtime_city_state is Dictionary:
			return runtime_city_state
	return CITY_HUD_DATA.get(city_id, {})


func _get_mutable_city_runtime_state(city_id: String) -> Dictionary:
	if city_id.is_empty():
		return {}
	var source_city_state := _get_city_hud_entry(city_id)
	if source_city_state.is_empty():
		return {}
	var mutable_city_state := source_city_state.duplicate(true)
	_city_runtime_states[city_id] = mutable_city_state
	return mutable_city_state


func _get_city_hud_data_for_ui() -> Dictionary:
	var city_hud_data := CITY_HUD_DATA.duplicate(true)
	for city_id_variant in _city_runtime_states.keys():
		var city_id := str(city_id_variant)
		var city_state: Variant = _city_runtime_states.get(city_id, {})
		if city_state is Dictionary:
			city_hud_data[city_id] = (city_state as Dictionary).duplicate(true)
	return city_hud_data


func _get_hero_data_for_ui() -> Dictionary:
	var hero_data := HERO_DATA.duplicate(true)
	for hero_id_variant in _hero_runtime_states.keys():
		var hero_id := str(hero_id_variant)
		var merged_entry := _get_hero_entry(hero_id)
		if not merged_entry.is_empty():
			hero_data[hero_id] = merged_entry
	return hero_data


func _refresh_city_hud_data_bindings() -> void:
	if city_info_panel == null:
		return
	city_info_panel.set_hud_data(_get_hero_data_for_ui(), _get_city_hud_data_for_ui(), GOVERNOR_POLICY_DATA, _city_policy_state)


func _serialize_worldmap_city_runtime_state() -> Dictionary:
	var serialized := {}
	for city_id_variant in _city_runtime_states.keys():
		var city_id := str(city_id_variant)
		var city_state: Variant = _city_runtime_states.get(city_id, {})
		if not city_state is Dictionary:
			continue
		var source := city_state as Dictionary
		var city_payload := {
			"owner": str(source.get("owner", source.get("nation", ""))),
			"nation": str(source.get("nation", source.get("owner", ""))),
			"owner_faction_id": str(source.get("owner_faction_id", source.get("owner", source.get("nation", "")))),
			"faction": str(source.get("faction", source.get("owner", source.get("nation", "")))),
			"troops": maxi(0, int(source.get("troops", 0))),
			"publicSupport": _get_city_public_support(city_id),
			"loyalty": _get_city_loyalty_value(source),
			"cityLoyalty": _get_city_loyalty_value(source),
			"stationed_hero_ids": _normalize_hero_id_array(source.get("stationed_hero_ids", source.get("hero_ids", []))),
		}
		if source.has("resource_stock") and source.get("resource_stock") is Dictionary:
			city_payload["resource_stock"] = (source.get("resource_stock") as Dictionary).duplicate(true)
		if source.has("city_tech") and source.get("city_tech") is Dictionary:
			city_payload["city_tech"] = (source.get("city_tech") as Dictionary).duplicate(true)
		var wounded_queue := _get_city_wounded_queue_mvp(source)
		if not wounded_queue.is_empty():
			city_payload["woundedQueue"] = wounded_queue
			city_payload["wounded_queue"] = wounded_queue.duplicate(true)
		city_payload["hero_ids"] = (city_payload["stationed_hero_ids"] as Array).duplicate()
		serialized[city_id] = city_payload
		print("[SAVE_CITY_STATE] city=%s owner=%s troops=%d heroes=%s" % [
			city_id,
			str(city_payload.get("owner", "")),
			int(city_payload.get("troops", 0)),
			str(city_payload.get("stationed_hero_ids", []))
		])
	return serialized


func _serialize_worldmap_hero_runtime_state() -> Dictionary:
	var serialized := {}
	for hero_id_variant in _hero_runtime_states.keys():
		var hero_id := str(hero_id_variant)
		var hero_state: Variant = _hero_runtime_states.get(hero_id, {})
		if not hero_state is Dictionary:
			continue
		var source := _normalize_hero_runtime_state(hero_id, hero_state as Dictionary)
		var current_city_id := str(source.get("current_city_id", source.get("city_id", "")))
		if current_city_id.is_empty():
			continue
		serialized[hero_id] = {
			"current_city_id": current_city_id,
			"city_id": current_city_id,
			"location_city_id": current_city_id,
			"status": str(source.get("status", HERO_RUNTIME_STATUS_NORMAL)),
			"wounded": bool(source.get("wounded", false)),
			"captured": bool(source.get("captured", false)),
			"dead": bool(source.get("dead", false)),
			"wounded_turns_remaining": maxi(0, int(source.get("wounded_turns_remaining", 0))),
		}
		print("[HERO_STATE_SAVE] hero=%s current_city=%s status=%s wounded=%s captured=%s dead=%s wounded_turns=%d" % [
			hero_id,
			current_city_id,
			str(source.get("status", HERO_RUNTIME_STATUS_NORMAL)),
			str(source.get("wounded", false)),
			str(source.get("captured", false)),
			str(source.get("dead", false)),
			maxi(0, int(source.get("wounded_turns_remaining", 0)))
		])
	return serialized


func _apply_worldmap_city_runtime_state(raw_state: Variant) -> void:
	if raw_state == null:
		return
	if not raw_state is Dictionary:
		print("[LOAD_STATE_SKIP] type=worldmap_city_state reason=not_dictionary")
		return
	for city_id_variant in (raw_state as Dictionary).keys():
		var city_id := str(city_id_variant)
		var city_payload: Variant = (raw_state as Dictionary).get(city_id, {})
		if not city_payload is Dictionary:
			print("[LOAD_STATE_SKIP] type=city city=%s reason=not_dictionary" % city_id)
			continue
		if _get_city_hud_entry(city_id).is_empty() and not CITY_HUD_DATA.has(city_id):
			print("[LOAD_STATE_SKIP] type=city city=%s reason=missing_city" % city_id)
			continue
		var source := city_payload as Dictionary
		var city_state: Dictionary = CITY_HUD_DATA.get(city_id, {}).duplicate(true)
		if city_state.is_empty():
			print("[LOAD_STATE_SKIP] type=city city=%s reason=missing_seed" % city_id)
			continue
		var owner_id := str(source.get("owner", source.get("nation", source.get("owner_faction_id", ""))))
		if not owner_id.is_empty():
			city_state["owner"] = owner_id
			city_state["nation"] = str(source.get("nation", owner_id))
			city_state["owner_faction_id"] = str(source.get("owner_faction_id", owner_id))
			city_state["faction"] = str(source.get("faction", owner_id))
		if source.has("troops"):
			city_state["troops"] = maxi(0, int(source.get("troops", 0)))
		if source.has("loyalty") or source.has("cityLoyalty"):
			var loaded_loyalty := clampi(int(source.get("cityLoyalty", source.get("loyalty", city_state.get("loyalty", 75)))), 0, 100)
			city_state["loyalty"] = loaded_loyalty
			city_state["cityLoyalty"] = loaded_loyalty
		if source.has("publicSupport"):
			city_state["publicSupport"] = clampi(int(source.get("publicSupport", CITY_PUBLIC_SUPPORT_DEFAULT)), 0, 100)
		if source.has("resource_stock") and source.get("resource_stock") is Dictionary:
			var resource_stock := {}
			for resource_id in (source.get("resource_stock") as Dictionary).keys():
				var resource_key := str(resource_id)
				resource_stock[resource_key] = maxi(0, int((source.get("resource_stock") as Dictionary).get(resource_key, 0)))
			city_state["resource_stock"] = resource_stock
		if source.has("city_tech") and source.get("city_tech") is Dictionary:
			var city_tech: Dictionary = (source.get("city_tech") as Dictionary).duplicate(true)
			if not city_tech.has("completed") or not (city_tech["completed"] is Dictionary):
				city_tech["completed"] = {}
			if not city_tech.has("in_progress") or not (city_tech["in_progress"] is Dictionary):
				city_tech["in_progress"] = {}
			if not city_tech.has("available_cache") or not (city_tech["available_cache"] is Dictionary):
				city_tech["available_cache"] = {}
			city_state["city_tech"] = city_tech
		var wounded_queue := _get_city_wounded_queue_mvp(source)
		if not wounded_queue.is_empty():
			city_state["woundedQueue"] = wounded_queue
			city_state["wounded_queue"] = wounded_queue.duplicate(true)
		var stationed_hero_ids := _normalize_hero_id_array(source.get("stationed_hero_ids", source.get("hero_ids", city_state.get("stationed_hero_ids", []))))
		city_state["stationed_hero_ids"] = stationed_hero_ids
		city_state["hero_ids"] = stationed_hero_ids.duplicate()
		_city_runtime_states[city_id] = city_state
		for hero_id in stationed_hero_ids:
			_set_hero_runtime_city(hero_id, city_id)
		print("[LOAD_CITY_STATE] city=%s owner=%s troops=%d heroes=%s" % [
			city_id,
			str(city_state.get("owner", "")),
			int(city_state.get("troops", 0)),
			str(stationed_hero_ids)
		])


func _apply_worldmap_hero_runtime_state(raw_state: Variant) -> void:
	if raw_state == null:
		return
	if not raw_state is Dictionary:
		print("[LOAD_STATE_SKIP] type=worldmap_hero_state reason=not_dictionary")
		return
	for hero_id_variant in (raw_state as Dictionary).keys():
		var hero_id := str(hero_id_variant)
		var hero_payload: Variant = (raw_state as Dictionary).get(hero_id, {})
		if not hero_payload is Dictionary:
			print("[LOAD_STATE_SKIP] type=hero hero=%s reason=not_dictionary" % hero_id)
			continue
		if _get_hero_seed_entry(hero_id).is_empty():
			print("[LOAD_STATE_SKIP] type=hero hero=%s reason=missing_hero" % hero_id)
			continue
		var normalized_state := _normalize_hero_runtime_state(hero_id, hero_payload as Dictionary)
		var current_city_id := str(normalized_state.get("current_city_id", normalized_state.get("city_id", "")))
		if current_city_id.is_empty():
			print("[LOAD_STATE_SKIP] type=hero hero=%s reason=missing_city_id" % hero_id)
			continue
		if not CITY_HUD_DATA.has(current_city_id) and _get_city_hud_entry(current_city_id).is_empty():
			print("[LOAD_STATE_SKIP] type=hero hero=%s city=%s reason=missing_city" % [hero_id, current_city_id])
			continue
		normalized_state["current_city_id"] = current_city_id
		normalized_state["city_id"] = current_city_id
		normalized_state["location_city_id"] = current_city_id
		_hero_runtime_states[hero_id] = normalized_state
		_remove_hero_from_other_city_runtime_rosters(hero_id, current_city_id)
		_ensure_hero_in_city_runtime_roster(hero_id, current_city_id)
		print("[HERO_STATE_LOAD] hero=%s current_city=%s status=%s wounded=%s captured=%s dead=%s wounded_turns=%d" % [
			hero_id,
			current_city_id,
			str(normalized_state.get("status", HERO_RUNTIME_STATUS_NORMAL)),
			str(normalized_state.get("wounded", false)),
			str(normalized_state.get("captured", false)),
			str(normalized_state.get("dead", false)),
			maxi(0, int(normalized_state.get("wounded_turns_remaining", 0)))
		])


func _refresh_city_marker_owner_states_from_runtime() -> void:
	for city_id_variant in _city_markers_by_id.keys():
		var city_id := str(city_id_variant)
		var city_marker := _city_markers_by_id.get(city_id) as WorldMapCityMarker
		if city_marker == null:
			continue
		var city_data := _get_city_hud_entry(city_id)
		var owner_id := str(city_data.get("owner_faction_id", city_data.get("owner", city_data.get("nation", city_marker.owner_faction_id))))
		if not owner_id.is_empty():
			city_marker.owner_faction_id = owner_id
			city_marker._refresh_marker_visuals()


func _get_hero_seed_entry(hero_id: String) -> Dictionary:
	return HERO_DATA.get(hero_id, {})


func _get_hero_entry(hero_id: String) -> Dictionary:
	var hero_data := _get_hero_seed_entry(hero_id)
	if hero_data.is_empty():
		return {}
	var result := hero_data.duplicate(true)
	var runtime_state: Variant = _hero_runtime_states.get(hero_id, {})
	if runtime_state is Dictionary:
		for key in (runtime_state as Dictionary).keys():
			result[key] = (runtime_state as Dictionary).get(key)
	return result


func _normalize_hero_id_array(raw_hero_ids: Variant) -> Array[String]:
	var result: Array[String] = []
	if not raw_hero_ids is Array:
		return result
	for hero_id_variant in raw_hero_ids:
		var hero_id := str(hero_id_variant)
		if hero_id.is_empty() or result.has(hero_id):
			continue
		if _get_hero_seed_entry(hero_id).is_empty():
			print("[LOAD_STATE_SKIP] type=hero_array hero=%s reason=missing_hero" % hero_id)
			continue
		result.append(hero_id)
	return result


func _normalize_hero_runtime_state(hero_id: String, raw_state: Dictionary = {}) -> Dictionary:
	var seed_entry := _get_hero_seed_entry(hero_id)
	var current_city_id := str(raw_state.get("current_city_id", raw_state.get("city_id", raw_state.get("location_city_id", ""))))
	if current_city_id.is_empty() and not seed_entry.is_empty():
		current_city_id = str(seed_entry.get("current_city_id", seed_entry.get("city_id", seed_entry.get("location_city_id", ""))))
	var status := str(raw_state.get("status", HERO_RUNTIME_STATUS_NORMAL)).to_lower()
	if not [HERO_RUNTIME_STATUS_NORMAL, HERO_RUNTIME_STATUS_WOUNDED, HERO_RUNTIME_STATUS_CAPTURED, HERO_RUNTIME_STATUS_DEAD].has(status):
		status = HERO_RUNTIME_STATUS_NORMAL
	var is_dead := bool(raw_state.get("dead", status == HERO_RUNTIME_STATUS_DEAD))
	var is_captured := bool(raw_state.get("captured", status == HERO_RUNTIME_STATUS_CAPTURED))
	var is_wounded := bool(raw_state.get("wounded", status == HERO_RUNTIME_STATUS_WOUNDED))
	var wounded_turns := maxi(0, int(raw_state.get("wounded_turns_remaining", 0)))
	if is_dead:
		status = HERO_RUNTIME_STATUS_DEAD
		is_captured = false
		is_wounded = false
		wounded_turns = 0
	elif is_captured:
		status = HERO_RUNTIME_STATUS_CAPTURED
		is_wounded = false
		wounded_turns = 0
	elif is_wounded or status == HERO_RUNTIME_STATUS_WOUNDED:
		status = HERO_RUNTIME_STATUS_WOUNDED
		is_wounded = true
		if wounded_turns <= 0:
			wounded_turns = DEFAULT_WOUNDED_RECOVERY_TURNS
	else:
		status = HERO_RUNTIME_STATUS_NORMAL
		is_wounded = false
		wounded_turns = 0
	return {
		"current_city_id": current_city_id,
		"city_id": current_city_id,
		"location_city_id": current_city_id,
		"status": status,
		"wounded": is_wounded,
		"captured": is_captured,
		"dead": is_dead,
		"wounded_turns_remaining": wounded_turns,
	}


func _set_hero_runtime_city(hero_id: String, city_id: String) -> void:
	if hero_id.is_empty() or city_id.is_empty():
		return
	if _get_hero_seed_entry(hero_id).is_empty():
		return
	var hero_state: Dictionary = _normalize_hero_runtime_state(hero_id)
	var existing_state: Variant = _hero_runtime_states.get(hero_id, {})
	if existing_state is Dictionary:
		hero_state = _normalize_hero_runtime_state(hero_id, existing_state as Dictionary)
	hero_state["current_city_id"] = city_id
	hero_state["city_id"] = city_id
	hero_state["location_city_id"] = city_id
	_hero_runtime_states[hero_id] = hero_state


func _ensure_hero_in_city_runtime_roster(hero_id: String, city_id: String) -> void:
	if hero_id.is_empty() or city_id.is_empty():
		return
	var city_data := _get_mutable_city_runtime_state(city_id)
	if city_data.is_empty():
		return
	var stationed_hero_ids := _normalize_hero_id_array(city_data.get("stationed_hero_ids", city_data.get("hero_ids", [])))
	if not stationed_hero_ids.has(hero_id):
		stationed_hero_ids.append(hero_id)
	city_data["stationed_hero_ids"] = stationed_hero_ids
	city_data["hero_ids"] = stationed_hero_ids.duplicate()
	_city_runtime_states[city_id] = city_data


func _remove_hero_from_other_city_runtime_rosters(hero_id: String, current_city_id: String) -> void:
	if hero_id.is_empty():
		return
	var city_ids := {}
	for city_id_variant in CITY_HUD_DATA.keys():
		city_ids[str(city_id_variant)] = true
	for city_id_variant in _city_runtime_states.keys():
		city_ids[str(city_id_variant)] = true
	for city_id_variant in city_ids.keys():
		var city_id := str(city_id_variant)
		if city_id == current_city_id:
			continue
		var city_data := _get_city_hud_entry(city_id)
		var stationed_hero_ids := _normalize_hero_id_array(city_data.get("stationed_hero_ids", city_data.get("hero_ids", [])))
		if not stationed_hero_ids.has(hero_id):
			continue
		stationed_hero_ids.erase(hero_id)
		var mutable_city_state := _get_mutable_city_runtime_state(city_id)
		if mutable_city_state.is_empty():
			continue
		mutable_city_state["stationed_hero_ids"] = stationed_hero_ids
		mutable_city_state["hero_ids"] = stationed_hero_ids.duplicate()
		_city_runtime_states[city_id] = mutable_city_state


func _sync_worldmap_hero_locations_from_city_runtime_states() -> void:
	for city_id_variant in _city_runtime_states.keys():
		var city_id := str(city_id_variant)
		var city_state: Variant = _city_runtime_states.get(city_id, {})
		if not city_state is Dictionary:
			continue
		for hero_id in _normalize_hero_id_array((city_state as Dictionary).get("stationed_hero_ids", (city_state as Dictionary).get("hero_ids", []))):
			_set_hero_runtime_city(hero_id, city_id)


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
	if _unified_primary_tab == UNIFIED_PANEL_TAB_CITY_DETAIL and _selected_city_detail_tab == CITY_DETAIL_TAB_INTERNAL_TRADE and selected_city_marker != null:
		var preview := _get_troop_move_preview_for_city(selected_city_marker.city_id)
		if bool(preview.get("ok", false)) and _move_troops(str(preview.get("from", "")), str(preview.get("to", "")), int(preview.get("amount", 0))):
			var move_result: Dictionary = _player_state.get("last_troop_move_result", {})
			_set_save_management_status("%s → %s %d명 이동 명령: %d명 도착, %d명 이탈" % [
				_format_city_name_by_id(str(preview.get("from", "")), "출발 도시"),
				_format_city_name_by_id(str(preview.get("to", "")), "도착 도시"),
				int(move_result.get("commanded_amount", preview.get("amount", 0))),
				int(move_result.get("arrived_amount", 0)),
				int(move_result.get("lost_amount", 0)),
			])
		else:
			_set_save_management_status("병력 이동 불가: %s" % _format_troop_move_reason(preview))
		_refresh_left_world_status_panel()
		_refresh_unified_panel_content()
		return
	print("[WorldMap] City detail domestic placeholder selected. Domestic execution is deferred.")
	city_detail_hint_label.text = "내정 실행은 아직 수치나 턴 처리와 연결되지 않았습니다."
