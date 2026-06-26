extends Node2D

const HeroPortraitHelper := preload("res://scripts/worldmap_hero_portrait_helper.gd")
const PlayerAttackDeploymentPanelScript := preload("res://scripts/player_attack_deployment_panel.gd")

const WORLD_MAP_CAMERA_SPEED := 900.0
const WORLD_MAP_CAMERA_DRAG_SPEED := 1.0
const WORLD_MAP_MIN_ZOOM := 0.35
const WORLD_MAP_MAX_ZOOM := 1.6
const WORLD_MAP_CLAMP_PADDING := 24.0
const WORLD_MAP_ZOOM_STEP := 0.1
const WORLD_BATTLE_ENTRY_PAN_SEC := 0.55
const WORLD_BATTLE_ENTRY_ZOOM_SEC := 0.45
const WORLD_BATTLE_ENTRY_HOLD_SEC := 0.15
const WORLD_BATTLE_ENTRY_TARGET_ZOOM := Vector2(1.35, 1.35)
const WORLD_UI_TOP_MARGIN := 10.0
const WORLD_UI_LEFT_MARGIN := 10.0
const LEFT_WORLD_STATUS_PANEL_TOP_LEFT := Vector2(WORLD_UI_LEFT_MARGIN, WORLD_UI_TOP_MARGIN)
const LEFT_WORLD_STATUS_PANEL_SIZE := Vector2(320.0, 570.0)
const SELECTED_CITY_INFO_PANEL_SIZE := Vector2(308.0, 542.0)
const PLAYER_FACTION_ID := "player"
const UNIFIED_PANEL_TAB_CITY_DETAIL := "city-detail"
const UNIFIED_PANEL_TAB_DIPLOMACY_SPY := "diplomacy-spy"
const UNIFIED_PANEL_TAB_TRADE := "trade"
const CITY_DETAIL_TAB_RESOURCES := "resources"
const CITY_DETAIL_TAB_INTERNAL_TRADE := "internal-trade"
const CITY_DETAIL_TAB_EXTERNAL_TRADE := "external-trade"
const DOMESTIC_TECH_SCOPE_CITY := "city"
const DOMESTIC_TECH_SCOPE_NATIONAL := "national"
const DOMESTIC_TECH_UI_SURFACE_CITY := "right_city_detail_panel"
const DOMESTIC_TECH_UI_SURFACE_NATIONAL := "left_player_national_panel"
const DOMESTIC_TECH_PROGRESS_CITY := "governor_auto_or_manual"
const DOMESTIC_TECH_PROGRESS_NATIONAL := "chancellor_directed"
const DOMESTIC_TECH_ICON_FALLBACK_LABEL := "?"
const DOMESTIC_TECH_CATEGORY_AGRI := "agri"
const DOMESTIC_TECH_CATEGORY_FISH := "fish"
const DOMESTIC_TECH_CATEGORY_COMMERCE := "commerce"
const DOMESTIC_TECH_CATEGORY_MILITARY := "military"
const DOMESTIC_TECH_CATEGORY_NATION_ADMIN := "nation_admin"
const DOMESTIC_TECH_CATEGORY_NATION_ECONOMY := "nation_economy"
const DOMESTIC_TECH_CATEGORY_NATION_MILITARY := "nation_military"
const DOMESTIC_TECH_CATEGORY_NATION_DIPLOMACY := "nation_diplomacy"
const DOMESTIC_TECH_VIEW_COMPLETED := "completed"
const DOMESTIC_TECH_VIEW_AVAILABLE := "available"
const DOMESTIC_TECH_VIEW_LOCKED := "locked"
const DOMESTIC_TECH_VIEW_SPECIAL_LOCKED := "special_locked"
const DOMESTIC_TECH_TREE_OVERLAY_MARGIN := 22.0
const DOMESTIC_TECH_TREE_NODE_WIDTH := 214.0
const DOMESTIC_TECH_TREE_ICON_SIZE := 42.0
const DOMESTIC_TECH_GRAPH_NODE_SIZE := Vector2(214.0, 150.0)
const DOMESTIC_TECH_GRAPH_TIER_SPACING := 258.0
const DOMESTIC_TECH_GRAPH_BRANCH_SPACING := 188.0
const DOMESTIC_TECH_GRAPH_BRANCH_STACK_SPACING := 162.0
const DOMESTIC_TECH_GRAPH_MARGIN := Vector2(14.0, 34.0)
const DOMESTIC_TECH_GRAPH_LINE_WIDTH := 3.0
const TRADE_CONTROL_MODE_CHANCELLOR := "chancellor"
const TRADE_CONTROL_MODE_MANUAL := "manual"
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
const ENEMY_FACTION_TURN_REINFORCE_BASE := 60
const ENEMY_FACTION_TURN_REINFORCE_FRONTLINE_BONUS := 40
const ENEMY_FACTION_TURN_REINFORCE_CHANCELLOR_BONUS := 20
const ENEMY_FACTION_TURN_REINFORCE_MAX := 120
const ENEMY_STRATEGIC_DIPLOMACY_DRIFT := 3
const ENEMY_STRATEGIC_SPY_PRESSURE_WEIGHT := 2
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
const DIPLOMACY_SCORE_MIN := 0
const DIPLOMACY_SCORE_MAX := 100
const DIPLOMACY_DEFAULT_SCORE := 50
const TRIBUTE_COOLDOWN_TURNS := 5
const TRIBUTE_RELATION_GAIN_MIN := 15
const TRIBUTE_RELATION_GAIN_MAX := 25
const TRIBUTE_BASE_COST := {
	"gold": 300,
	"silk": 100,
}
const ALLIANCE_ACCEPTANCE_THRESHOLD := 70
const MILITARY_SUPPORT_ACCEPTANCE_THRESHOLD := 80
const MILITARY_SUPPORT_REJECT_PENALTY := -20
const MILITARY_SUPPORT_REPEATED_REJECT_PENALTY := -40
const MILITARY_SUPPORT_REPEATED_REJECT_THRESHOLD := 3
const TRADE_AGREEMENT_SCORE_REQUIREMENT := 50
const TRADE_AGREEMENT_TURNS := 20
const TRADE_AGREEMENT_MULTIPLIER_BONUS := 0.15
const TRADE_AGREEMENT_COST := {
	"gold": 200,
	"silk": 50,
}
const DIPLOMACY_ACTION_ENVOY := "envoy"
const DIPLOMACY_ACTION_TRIBUTE := "tribute"
const DIPLOMACY_ACTION_TRADE_AGREEMENT := "trade_agreement"
const DIPLOMACY_ACTION_RESTORE_RELATIONS := "restore_relations"
const DIPLOMACY_ACTION_ALLIANCE_PROPOSAL := "alliance_proposal"
const DIPLOMACY_ACTION_TRADE_AGREEMENT_TURNS := 6
const DIPLOMACY_ACTION_ALLIANCE_TURNS := 8
const DIPLOMACY_ACTION_ALLIANCE_COST := {"gold": 200, "silk": 50}
const SPY_ACTION_GATHER_INFO := "gather_info"
const SPY_ACTION_PUBLIC_SUPPORT_DISRUPT := "public_support_disrupt"
const SPY_ACTION_LOYALTY_DISRUPT := "loyalty_disrupt"
const SPY_ACTION_REVOLT_INSTIGATE := "revolt_instigate"
const SPY_ACTION_WEDGE := "wedge"
const SPY_COOLDOWN_TURNS := 1
const SPY_PUBLIC_SUPPORT_DISRUPT_COST := {"gold": 300}
const SPY_PUBLIC_SUPPORT_DISRUPT_COOLDOWN_TURNS := 2
const SPY_DETECTED_RELATION_PENALTY_GATHER_INFO := -6
const SPY_DETECTED_RELATION_PENALTY_PUBLIC_SUPPORT := -10
const SPY_LOYALTY_DISRUPT_COST := {
	"gold": 500,
	"silk": 50,
}
const SPY_LOYALTY_DISRUPT_COOLDOWN_TURNS := 2
const SPY_DETECTED_RELATION_PENALTY_LOYALTY := -10
const SPY_REVOLT_INSTIGATION_COST := {
	"gold": 800,
	"silk": 100,
}
const SPY_REVOLT_INSTIGATION_COOLDOWN_TURNS := 2
const SPY_REVOLT_INSTIGATION_DURATION_TURNS := 3
const SPY_DETECTED_RELATION_PENALTY_REVOLT := -10
const SPY_WEDGE_COST := {
	"gold": 600,
	"silk": 150,
}
const SPY_WEDGE_COOLDOWN_TURNS := 12
const SPY_DETECTED_RELATION_PENALTY_WEDGE := -20
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
const ENEMY_INVASION_MIN_ATTACKER_CITY_TROOPS := 160
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

const ENEMY_FACTION_PERSONALITY_SEEDS := {
	"default": {
		"profile": "default_balanced",
		"label": "균형",
		"reinforce_weight": 1.0,
		"frontline_weight": 1.0,
		"invasion_weight": 1.0,
		"diplomacy_weight": 1.0,
		"spy_weight": 1.0,
	},
	"goguryeo": {
		"profile": "military_frontline",
		"label": "군사",
		"reinforce_weight": 1.05,
		"frontline_weight": 1.15,
		"invasion_weight": 1.1,
		"diplomacy_weight": 0.9,
		"spy_weight": 0.95,
	},
	"wei": {
		"profile": "military_frontline",
		"label": "군사",
		"reinforce_weight": 1.05,
		"frontline_weight": 1.1,
		"invasion_weight": 1.08,
		"diplomacy_weight": 0.95,
		"spy_weight": 0.95,
	},
	"chu": {
		"profile": "default_balanced",
		"label": "균형",
		"reinforce_weight": 1.0,
		"frontline_weight": 1.0,
		"invasion_weight": 1.0,
		"diplomacy_weight": 1.0,
		"spy_weight": 1.0,
	},
	"mongol_faction": {
		"profile": "aggressive_expansion",
		"label": "공격",
		"reinforce_weight": 1.0,
		"frontline_weight": 1.12,
		"invasion_weight": 1.15,
		"diplomacy_weight": 0.85,
		"spy_weight": 0.95,
	},
	"oda": {
		"profile": "aggressive_expansion",
		"label": "공격",
		"reinforce_weight": 1.0,
		"frontline_weight": 1.08,
		"invasion_weight": 1.12,
		"diplomacy_weight": 0.9,
		"spy_weight": 1.0,
	},
	"toyotomi": {
		"profile": "aggressive_expansion",
		"label": "공격",
		"reinforce_weight": 1.0,
		"frontline_weight": 1.06,
		"invasion_weight": 1.1,
		"diplomacy_weight": 0.95,
		"spy_weight": 1.0,
	},
	"silla": {
		"profile": "diplomatic_balanced",
		"label": "외교",
		"reinforce_weight": 0.95,
		"frontline_weight": 0.95,
		"invasion_weight": 0.9,
		"diplomacy_weight": 1.15,
		"spy_weight": 1.0,
	},
	"shu": {
		"profile": "diplomatic_balanced",
		"label": "외교",
		"reinforce_weight": 0.95,
		"frontline_weight": 0.95,
		"invasion_weight": 0.9,
		"diplomacy_weight": 1.12,
		"spy_weight": 1.0,
	},
	"tokugawa": {
		"profile": "diplomatic_balanced",
		"label": "외교",
		"reinforce_weight": 1.0,
		"frontline_weight": 0.95,
		"invasion_weight": 0.9,
		"diplomacy_weight": 1.12,
		"spy_weight": 1.0,
	},
	"baekje_faction": {
		"profile": "trade_defensive",
		"label": "방어",
		"reinforce_weight": 1.12,
		"frontline_weight": 0.9,
		"invasion_weight": 0.9,
		"diplomacy_weight": 1.05,
		"spy_weight": 1.0,
	},
	"wu": {
		"profile": "trade_defensive",
		"label": "방어",
		"reinforce_weight": 1.1,
		"frontline_weight": 0.9,
		"invasion_weight": 0.9,
		"diplomacy_weight": 1.05,
		"spy_weight": 1.02,
	},
	"kyushu_faction": {
		"profile": "schemer_pressure",
		"label": "계략",
		"reinforce_weight": 1.04,
		"frontline_weight": 0.9,
		"invasion_weight": 0.88,
		"diplomacy_weight": 0.98,
		"spy_weight": 1.12,
	},
}

const ENEMY_FACTION_STRATEGIC_GOAL_SEEDS := {
	"default": {
		"goal_id": "hold_position",
		"label": "전선 유지",
		"target_city_ids": [],
		"target_region_ids": [],
		"pressure": "balanced",
		"weight": 1.0,
	},
	"goguryeo": {
		"goal_id": "pressure_hanseong",
		"label": "한성 압박",
		"target_city_ids": ["hanseong", "pyeongyang"],
		"target_region_ids": ["region.korean_peninsula"],
		"pressure": "military",
		"weight": 1.1,
	},
	"baekje_faction": {
		"goal_id": "restore_southwest",
		"label": "서남 방어",
		"target_city_ids": ["sabi", "hanseong"],
		"target_region_ids": ["region.korean_peninsula"],
		"pressure": "defensive",
		"weight": 1.06,
	},
	"silla": {
		"goal_id": "peninsula_balance",
		"label": "반도 균형",
		"target_city_ids": ["gyeongju", "sabi", "hanseong"],
		"target_region_ids": ["region.korean_peninsula"],
		"pressure": "diplomacy",
		"weight": 1.05,
	},
	"wei": {
		"goal_id": "central_plains_control",
		"label": "중원 장악",
		"target_city_ids": ["luoyang", "yecheng"],
		"target_region_ids": ["region.china_mainland"],
		"pressure": "military",
		"weight": 1.08,
	},
	"shu": {
		"goal_id": "western_resilience",
		"label": "서방 방어",
		"target_city_ids": ["chengdu"],
		"target_region_ids": ["region.china_mainland"],
		"pressure": "defensive",
		"weight": 1.05,
	},
	"wu": {
		"goal_id": "river_trade_hold",
		"label": "강남 방어",
		"target_city_ids": ["jianye"],
		"target_region_ids": ["region.china_mainland"],
		"pressure": "trade_defensive",
		"weight": 1.05,
	},
	"chu": {
		"goal_id": "southern_balance",
		"label": "남방 균형",
		"target_city_ids": ["luoyang", "jianye"],
		"target_region_ids": ["region.china_mainland"],
		"pressure": "balanced",
		"weight": 1.02,
	},
	"oda": {
		"goal_id": "kyoto_expansion",
		"label": "교토 압박",
		"target_city_ids": ["kyoto", "osaka"],
		"target_region_ids": ["region.japanese_archipelago"],
		"pressure": "aggressive",
		"weight": 1.1,
	},
	"toyotomi": {
		"goal_id": "osaka_expansion",
		"label": "오사카 확장",
		"target_city_ids": ["osaka", "kyoto"],
		"target_region_ids": ["region.japanese_archipelago"],
		"pressure": "aggressive",
		"weight": 1.08,
	},
	"kyushu_faction": {
		"goal_id": "western_isles_scheme",
		"label": "서국 교란",
		"target_city_ids": ["kyushu", "osaka"],
		"target_region_ids": ["region.japanese_archipelago"],
		"pressure": "spy",
		"weight": 1.07,
	},
	"tokugawa": {
		"goal_id": "eastern_consolidation",
		"label": "동방 안정",
		"target_city_ids": ["edo", "kyoto"],
		"target_region_ids": ["region.japanese_archipelago"],
		"pressure": "defensive",
		"weight": 1.05,
	},
	"mongol_faction": {
		"goal_id": "northern_breakthrough",
		"label": "북방 돌파",
		"target_city_ids": ["karakorum", "pyeongyang"],
		"target_region_ids": ["region.northern_steppe", "region.korean_peninsula"],
		"pressure": "invasion",
		"weight": 1.12,
	},
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
const INTERNAL_TRADE_TRANSFER_RESOURCE_ORDER := ["gold", "rice", "barley", "seafood", "wood", "iron", "horses", "silk", "salt"]
const MANUAL_TRADE_RESOURCE_ORDER := ["rice", "barley", "seafood", "wood", "iron", "horses", "silk", "salt"]
const MANUAL_TRADE_ACTION_NONE := "none"
const MANUAL_TRADE_ACTION_IMPORT := "import"
const MANUAL_TRADE_ACTION_EXPORT := "export"
const MANUAL_TRADE_PREVIEW_PRICES := {
	"rice": 3,
	"barley": 2,
	"seafood": 4,
	"wood": 5,
	"iron": 8,
	"horses": 12,
	"silk": 10,
	"salt": 6,
}
const TRADE_EFFICIENCY_MIN := 0.25
const TRADE_EFFICIENCY_MAX := 2.0
const CITY_STORAGE_FOOD_RESOURCE_IDS := ["rice", "barley", "seafood"]
const CITY_STORAGE_STRATEGY_RESOURCE_IDS := ["wood", "iron", "horses"]
const CITY_STORAGE_SPECIAL_RESOURCE_IDS := ["silk", "salt"]
const CHANCELLOR_AUTO_TRADE_STORAGE_TARGETS := {
	"gold": 100,
	"rice": 120,
	"barley": 100,
	"seafood": 50,
	"wood": 40,
	"iron": 30,
	"horses": 20,
	"silk": 20,
	"salt": 40,
}
const CHANCELLOR_AUTO_TRADE_INTERNAL_TOTAL_CAP := 200
const CHANCELLOR_AUTO_TRADE_INTERNAL_BASE_CAP := 20
const CHANCELLOR_AUTO_TRADE_INTERNAL_APTITUDE_CAP := 30
const CHANCELLOR_AUTO_TRADE_EXTERNAL_BASE_CAP := 20
const CHANCELLOR_AUTO_TRADE_EXTERNAL_APTITUDE_CAP := 30
const CHANCELLOR_AUTO_TRADE_EXTERNAL_TRADE_POLICY_CAP := 35
const CHANCELLOR_AUTO_TRADE_GOLD_CAP := 100
const CHANCELLOR_AUTO_TRADE_DEFAULT_BUFFER := 20
const CHANCELLOR_AUTO_TRADE_GOLD_BUFFER := 50
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
		"name": "균형 운영",
		"description": "효과: 국가 운영 방향을 따른 도시 보정",
	},
	"agriculture": {
		"name": "농업 중심",
		"description": "효과: 농업 산출 강화",
	},
	"commerce": {
		"name": "상업 중심",
		"description": "효과: 상업 수입 강화",
	},
	"military": {
		"name": "군사 중심",
		"description": "효과: 병력 운영 보정",
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
var _city_resource_potential_card: PanelContainer = null
var _city_storage_card: PanelContainer = null
var _trade_control_card: PanelContainer = null
var _trade_control_title_label: Label = null
var _trade_control_status_label: Label = null
var _trade_auto_button: Button = null
var _trade_manual_button: Button = null
var _trade_control_hint_label: Label = null
var _trade_control_modes := {
	CITY_DETAIL_TAB_INTERNAL_TRADE: TRADE_CONTROL_MODE_CHANCELLOR,
	CITY_DETAIL_TAB_EXTERNAL_TRADE: TRADE_CONTROL_MODE_CHANCELLOR,
}
var _manual_trade_order_panel: PanelContainer = null
var _manual_trade_source_label: Label = null
var _manual_trade_target_option: OptionButton = null
var _manual_trade_relation_label: Label = null
var _manual_trade_preview_label: Label = null
var _manual_trade_status_label: Label = null
var _manual_trade_action_options: Dictionary = {}
var _manual_trade_amount_spinboxes: Dictionary = {}
var _manual_trade_orders: Dictionary = {}
var _manual_trade_current_source_city_id := ""
var _manual_trade_execution_button: Button = null
var _diplomacy_action_card: PanelContainer = null
var _diplomacy_action_title_label: Label = null
var _diplomacy_action_status_label: Label = null
var _diplomacy_action_button_row: HBoxContainer = null
var _diplomacy_envoy_button: Button = null
var _diplomacy_tribute_button: Button = null
var _diplomacy_trade_agreement_button: Button = null
var _diplomacy_restore_button: Button = null
var _diplomacy_alliance_button: Button = null
var _diplomacy_action_hint_label: Label = null
var _spy_action_card: PanelContainer = null
var _spy_action_title_label: Label = null
var _spy_action_status_label: Label = null
var _spy_action_button_row: HBoxContainer = null
var _spy_gather_info_button: Button = null
var _spy_public_support_button: Button = null
var _spy_loyalty_button: Button = null
var _spy_revolt_button: Button = null
var _spy_wedge_button: Button = null
var _spy_action_hint_label: Label = null
var _internal_trade_transfer_panel: PanelContainer = null
var _internal_trade_source_label: Label = null
var _internal_trade_target_option: OptionButton = null
var _internal_trade_preview_label: Label = null
var _internal_trade_status_label: Label = null
var _internal_trade_amount_spinboxes: Dictionary = {}
var _internal_trade_current_source_city_id := ""
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
var _worldmap_help_modal: PanelContainer = null
var _worldmap_help_title_label: Label = null
var _worldmap_help_body_label: Label = null
var _worldmap_help_close_button: Button = null
var _left_national_loyalty_help_button: Button = null
var _domestic_tech_tree_button_mvp: Button = null
var _tech_tree_overlay_mvp: PanelContainer = null
var _tech_tree_content_root_mvp: VBoxContainer = null
var _tech_tree_hidden_ui_state_mvp: Dictionary = {}
var _enemy_turn_mvp_timer: Timer
var _enemy_turn_mvp_pending := false
var _domestic_turn_apply_pending := false
var _default_player_state: Dictionary = {}
var _is_unified_city_panel_collapsed := false
var _unified_city_panel_expanded_size := Vector2.ZERO
var _unified_city_detail_primary_button: Button = null
var _unified_diplomacy_spy_primary_button: Button = null
var _unified_trade_primary_button: Button = null
var _has_warned_missing_unified_panel_chrome := false
var _collapsed_unified_panel_click_candidate := false
var _collapsed_unified_panel_drag_started := false
var _collapsed_unified_panel_click_start_position := Vector2.ZERO
var _city_runtime_states: Dictionary = {}
var _hero_runtime_states: Dictionary = {}
var _worldmap_battle_entry_handoff_in_progress := false
var _worldmap_battle_entry_handoff_completed := false
var _worldmap_battle_entry_handoff_continue_callable := Callable()
var _worldmap_battle_entry_handoff_tween: Tween = null
var _worldmap_battle_entry_handoff_target_position := Vector2.ZERO
var _worldmap_battle_entry_handoff_target_zoom := Vector2.ZERO
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
	"last_enemy_faction_turn_result": {},
	"last_enemy_pressure_plan_result": {},
	"last_enemy_strategic_action_result": {},
	"last_enemy_faction_turn_processed_turn": 0,
	"domestic_apply_pending": false,
	"last_domestic_apply_turn": 0,
	"national_loyalty": 75,
	"tax_level": 30,
	"public_order": 68,
	"chancellor_id": "",
	"chancellor_policy_id": "balanced",
	"faction_chancellors": {},
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
	"last_diplomacy_action_result": {},
	"diplomacy_action_cooldowns": {},
	"trade_agreements": {},
	"alliances": {},
	"last_inter_faction_trade_result": {},
	"last_trade_market_result": {},
	"trade_market_prices": {},
	"trade_market_turn": 0,
	"last_chancellor_auto_trade_result": {},
	"last_chancellor_auto_trade_turn": 0,
	"last_alliance_proposal_result": {},
	"last_military_support_result": {},
	"last_trade_agreement_result": {},
	"revolt_instigation": {},
	"city_intel": {},
	"last_spy_wedge_result": {},
	"last_supply_state_result": {},
	"last_public_support_result": {},
	"last_seasonal_loyalty_result": {},
	"last_conscription_result": {},
	"last_recruitment_result": {},
	"last_revolt_warning_result": {},
	"national_tech": {"completed": {}, "in_progress": {}, "available_cache": {}},
	"city_domestic_tech_completed": {},
	"city_domestic_tech_unlocked": {},
	"national_domestic_tech_completed": {},
	"national_domestic_tech_unlocked": {},
}
var _city_policy_state: Dictionary = {}
var _selected_city_detail_tab := CITY_DETAIL_TAB_RESOURCES


func _ready() -> void:
	_default_player_state = _player_state.duplicate(true)
	_ensure_worldmap_runtime_state_defaults()
	_restore_trade_persistence_from_player_state()
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
	_ensure_worldmap_help_modal()
	_ensure_domestic_tech_tree_button_mvp()
	_ensure_domestic_tech_tree_overlay_mvp()
	_refresh_domestic_tech_tree_overlay_mvp()
	_close_domestic_tech_tree_overlay_mvp()
	_ensure_player_attack_deployment_panel()
	_consume_worldmap_battle_result_if_any()
	_refresh_left_world_status_panel()
	_connect_world_hud_placeholders()
	_setup_unified_city_detail_diplomacy_panel()
	_ensure_city_detail_resource_cards()
	_ensure_trade_control_card()
	_ensure_manual_trade_execution_button()
	_ensure_manual_trade_order_panel()
	_ensure_internal_trade_transfer_panel()
	_setup_independent_hud_panel_drag()
	_lock_worldmap_fixed_panel_top_margin()
	_reset_city_detail_panel()
	_configure_camera()
	_update_camera_debug_label()


func _process(delta: float) -> void:
	if _worldmap_battle_entry_handoff_in_progress:
		_update_camera_debug_label()
		return
	_handle_keyboard_pan(delta)
	_update_camera_debug_label()


func _input(event: InputEvent) -> void:
	if _worldmap_battle_entry_handoff_in_progress:
		if _is_worldmap_battle_entry_handoff_skip_event(event):
			_skip_worldmap_battle_entry_camera_handoff()
		get_viewport().set_input_as_handled()
		return

	if _worldmap_help_modal != null and _worldmap_help_modal.visible and event.is_action_pressed("ui_cancel"):
		_hide_worldmap_help_modal()
		get_viewport().set_input_as_handled()
		return

	if _is_domestic_tech_tree_overlay_open_mvp() and event.is_action_pressed("ui_cancel"):
		_close_domestic_tech_tree_overlay_mvp()
		get_viewport().set_input_as_handled()
		return

	if _manual_trade_order_panel != null and _manual_trade_order_panel.visible and event.is_action_pressed("ui_cancel"):
		_close_manual_trade_order_panel()
		get_viewport().set_input_as_handled()
		return

	if _internal_trade_transfer_panel != null and _internal_trade_transfer_panel.visible and event.is_action_pressed("ui_cancel"):
		_close_internal_trade_transfer_panel()
		get_viewport().set_input_as_handled()
		return

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
	if _worldmap_battle_entry_handoff_in_progress:
		if _is_worldmap_battle_entry_handoff_skip_event(event):
			_skip_worldmap_battle_entry_camera_handoff()
		get_viewport().set_input_as_handled()
		return

	if _is_domestic_tech_tree_overlay_open_mvp():
		if event.is_action_pressed("ui_cancel"):
			_close_domestic_tech_tree_overlay_mvp()
		get_viewport().set_input_as_handled()
		return

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
	var retired_title_label := get_node_or_null("WorldMapUI/TitleLabel") as Control
	if retired_title_label != null:
		retired_title_label.visible = false
	world_title_panel.visible = false
	right_hud_dragbar.visible = false


func _setup_independent_hud_panel_drag() -> void:
	_register_hud_panel_drag(city_detail_panel, [city_detail_header_row, city_detail_eyebrow_label, city_detail_heading_label])
	_register_hud_panel_drag(city_info_panel_control, [city_info_eyebrow_label, city_info_city_name_label])


func _lock_worldmap_fixed_panel_top_margin() -> void:
	_lock_left_world_status_panel_anchor()
	_lock_screen_panel_top_margin(diplomacy_spy_panel)
	_lock_screen_panel_top_margin(city_detail_panel)
	_lock_selected_city_info_panel_anchor()


func _lock_screen_panel_top_margin(panel: Control) -> void:
	if panel == null:
		return

	var current_size := panel.size
	panel.set_anchors_preset(Control.PRESET_TOP_LEFT, true)
	panel.position = Vector2(panel.position.x, WORLD_UI_TOP_MARGIN)
	if current_size != Vector2.ZERO:
		panel.size = current_size


func _lock_selected_city_info_panel_anchor() -> void:
	if city_info_panel_control == null:
		return

	var viewport_size := get_viewport_rect().size
	var panel_size := city_info_panel_control.size
	if panel_size == Vector2.ZERO:
		panel_size = SELECTED_CITY_INFO_PANEL_SIZE
	city_info_panel_control.set_anchors_preset(Control.PRESET_TOP_LEFT, true)
	city_info_panel_control.position = Vector2(
		maxf(WORLD_UI_LEFT_MARGIN, viewport_size.x - WORLD_UI_LEFT_MARGIN - panel_size.x),
		WORLD_UI_TOP_MARGIN
	)
	city_info_panel_control.size = panel_size
	city_info_panel_control.custom_minimum_size = panel_size


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
	if selected_city_marker != city_marker:
		_close_manual_trade_order_panel()
		_close_internal_trade_transfer_panel()

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
	if _tech_tree_overlay_mvp != null and _tech_tree_overlay_mvp.visible:
		_refresh_domestic_tech_tree_overlay_mvp()


func _connect_city_info_panel_actions() -> void:
	if city_info_panel == null:
		return
	var callback := Callable(self, "_on_city_info_attack_requested")
	if city_info_panel.has_signal("attack_requested") and not city_info_panel.is_connected("attack_requested", callback):
		city_info_panel.connect("attack_requested", callback)
	var governor_assignment_callback := Callable(self, "_on_city_info_governor_assignment_requested")
	if city_info_panel.has_signal("governor_assignment_requested") and not city_info_panel.is_connected("governor_assignment_requested", governor_assignment_callback):
		city_info_panel.connect("governor_assignment_requested", governor_assignment_callback)
	var hero_transfer_callback := Callable(self, "_on_city_info_hero_transfer_confirmed")
	if city_info_panel.has_signal("hero_transfer_confirmed") and not city_info_panel.is_connected("hero_transfer_confirmed", hero_transfer_callback):
		city_info_panel.connect("hero_transfer_confirmed", hero_transfer_callback)
	var recruitment_callback := Callable(self, "_on_city_info_recruitment_requested")
	if city_info_panel.has_signal("recruitment_requested") and not city_info_panel.is_connected("recruitment_requested", recruitment_callback):
		city_info_panel.connect("recruitment_requested", recruitment_callback)
	var help_callback := Callable(self, "_show_worldmap_help_modal")
	if city_info_panel.has_signal("help_requested") and not city_info_panel.is_connected("help_requested", help_callback):
		city_info_panel.connect("help_requested", help_callback)


func _on_city_info_attack_requested(city_id: String) -> void:
	_start_player_attack_battle(city_id, "manual")


func _on_city_info_governor_assignment_requested(city_id: String, governor_id: String) -> void:
	if city_id.is_empty():
		return
	var city_state := _get_mutable_city_runtime_state(city_id)
	if city_state.is_empty():
		return
	var normalized_governor_id := governor_id.strip_edges()
	if not normalized_governor_id.is_empty():
		var stationed_hero_ids := _normalize_hero_id_array(city_state.get("stationed_hero_ids", city_state.get("hero_ids", [])))
		if not stationed_hero_ids.has(normalized_governor_id):
			push_warning("[WorldMap] Ignored governor assignment outside stationed heroes: city=%s hero=%s" % [city_id, normalized_governor_id])
			return
	city_state["governor_id"] = normalized_governor_id
	_refresh_city_hud_data_bindings()
	if _city_markers_by_id.has(city_id):
		city_info_panel.show_city(_city_markers_by_id.get(city_id) as WorldMapCityMarker)
	_refresh_unified_panel_content()


func _on_city_info_hero_transfer_confirmed(source_city_id: String, hero_id: String, target_city_id: String) -> void:
	var result := _transfer_stationed_hero_between_player_cities(source_city_id, hero_id, target_city_id)
	if not bool(result.get("ok", false)):
		if city_info_panel.has_method("show_hero_transfer_result"):
			city_info_panel.call("show_hero_transfer_result", str(result.get("message", "무장 이동 실패")))
		return
	_refresh_city_hud_data_bindings()
	if _city_markers_by_id.has(source_city_id):
		city_info_panel.show_city(_city_markers_by_id.get(source_city_id) as WorldMapCityMarker)
	if city_info_panel.has_method("show_hero_transfer_result"):
		city_info_panel.call("show_hero_transfer_result", "무장이 이동했습니다.")
	_refresh_left_world_status_panel()
	_refresh_unified_panel_content()


func _on_city_info_recruitment_requested(city_id: String, amount: int) -> void:
	if city_id.is_empty():
		_show_city_info_recruitment_result("도시를 선택하십시오.")
		return
	var validation := _can_recruit_troops(city_id, amount)
	if not bool(validation.get("ok", false)):
		_refresh_city_hud_data_bindings()
		if _city_markers_by_id.has(city_id):
			city_info_panel.show_city(_city_markers_by_id.get(city_id) as WorldMapCityMarker)
		_show_city_info_recruitment_result(_format_recruitment_failure_hint(str(validation.get("reason", ""))))
		return
	var before_troops := _get_city_troops_for_battle_context(city_id)
	if not _recruit_troops(city_id, amount):
		var failed_result: Dictionary = _player_state.get("last_recruitment_result", {})
		_show_city_info_recruitment_result(_format_recruitment_failure_hint(str(failed_result.get("reason", ""))))
		return
	var after_troops := _get_city_troops_for_battle_context(city_id)
	var city_name := _format_city_name_by_id(city_id, city_id)
	var message := "%s 모병 +%d · 병력 %d → %d" % [city_name, amount, before_troops, after_troops]
	if _city_markers_by_id.has(city_id):
		city_info_panel.show_city(_city_markers_by_id.get(city_id) as WorldMapCityMarker)
	_show_city_info_recruitment_result(message)
	_refresh_left_world_status_panel()
	_refresh_unified_panel_content()
	_set_save_management_status(message)


func _show_city_info_recruitment_result(message: String) -> void:
	if city_info_panel != null and city_info_panel.has_method("show_recruitment_result"):
		city_info_panel.call("show_recruitment_result", message)


func _format_recruitment_failure_hint(reason: String) -> String:
	match reason:
		"loyalty", "loyalty_limit":
			return "충성도 부족 · 모병 불가"
		"resources":
			return "자원 부족 · 금전/식량 확인"
		"not_peacetime":
			return "전투/침공 처리 중에는 모병 불가"
		"ownership":
			return "아군 도시에서만 모병 가능"
		"amount":
			return "모병 단위 오류"
		_:
			return "모병 불가"


func _transfer_stationed_hero_between_player_cities(source_city_id: String, hero_id: String, target_city_id: String) -> Dictionary:
	if source_city_id.is_empty() or hero_id.is_empty() or target_city_id.is_empty():
		return {"ok": false, "message": "무장 이동 정보가 부족합니다."}
	if source_city_id == target_city_id:
		return {"ok": false, "message": "같은 도시로는 이동할 수 없습니다."}
	if not _is_city_owned_by_player_mvp(source_city_id) or not _is_city_owned_by_player_mvp(target_city_id):
		return {"ok": false, "message": "아군 성 사이에서만 이동할 수 있습니다."}
	if not _is_adjacent_city_pair(source_city_id, target_city_id):
		return {"ok": false, "message": "인접한 아군 성으로만 이동할 수 있습니다."}
	var source_state := _get_mutable_city_runtime_state(source_city_id)
	var target_state := _get_mutable_city_runtime_state(target_city_id)
	if source_state.is_empty() or target_state.is_empty():
		return {"ok": false, "message": "도시 정보를 확인할 수 없습니다."}
	var source_hero_ids := _normalize_hero_id_array(source_state.get("stationed_hero_ids", source_state.get("hero_ids", [])))
	if not source_hero_ids.has(hero_id):
		return {"ok": false, "message": "이동 가능한 주둔 무장이 없습니다."}
	var target_hero_ids := _normalize_hero_id_array(target_state.get("stationed_hero_ids", target_state.get("hero_ids", [])))
	source_hero_ids.erase(hero_id)
	if not target_hero_ids.has(hero_id):
		target_hero_ids.append(hero_id)
	source_state["stationed_hero_ids"] = source_hero_ids
	source_state["hero_ids"] = source_hero_ids.duplicate()
	if str(source_state.get("governor_id", "")) == hero_id:
		source_state["governor_id"] = ""
	target_state["stationed_hero_ids"] = target_hero_ids
	target_state["hero_ids"] = target_hero_ids.duplicate()
	_city_runtime_states[source_city_id] = source_state
	_city_runtime_states[target_city_id] = target_state
	_set_hero_runtime_city(hero_id, target_city_id)
	return {"ok": true, "message": "무장이 이동했습니다."}


func _is_adjacent_city_pair(source_city_id: String, target_city_id: String) -> bool:
	var source_marker := _city_markers_by_id.get(source_city_id) as WorldMapCityMarker
	if source_marker == null:
		return false
	for neighbor_id in source_marker.neighbors:
		if str(neighbor_id) == target_city_id:
			return true
	return false


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


func _ensure_domestic_tech_tree_button_mvp() -> void:
	if _domestic_tech_tree_button_mvp != null:
		return
	var world_ui := get_node_or_null("WorldMapUI") as CanvasLayer
	if world_ui == null:
		return
	_domestic_tech_tree_button_mvp = Button.new()
	_domestic_tech_tree_button_mvp.name = "DomesticTechTreeButtonMVP"
	_domestic_tech_tree_button_mvp.text = "테크트리"
	_domestic_tech_tree_button_mvp.custom_minimum_size = Vector2(96.0, 30.0)
	_domestic_tech_tree_button_mvp.focus_mode = Control.FOCUS_NONE
	_domestic_tech_tree_button_mvp.anchor_left = 0.5
	_domestic_tech_tree_button_mvp.anchor_right = 0.5
	_domestic_tech_tree_button_mvp.anchor_top = 0.0
	_domestic_tech_tree_button_mvp.anchor_bottom = 0.0
	_domestic_tech_tree_button_mvp.offset_left = -48.0
	_domestic_tech_tree_button_mvp.offset_right = 48.0
	_domestic_tech_tree_button_mvp.offset_top = 58.0
	_domestic_tech_tree_button_mvp.offset_bottom = 88.0
	_domestic_tech_tree_button_mvp.add_theme_font_size_override("font_size", 13)
	_domestic_tech_tree_button_mvp.pressed.connect(_open_domestic_tech_tree_overlay_mvp)
	world_ui.add_child(_domestic_tech_tree_button_mvp)


func _setup_unified_city_detail_diplomacy_panel() -> void:
	diplomacy_spy_panel.visible = false
	_unified_city_panel_expanded_size = city_detail_panel.size
	city_detail_eyebrow_label.visible = false
	city_detail_eyebrow_label.text = ""
	city_detail_heading_label.visible = false
	city_detail_heading_label.text = ""
	city_detail_collapse_button_placeholder.text = "접기"
	_ensure_unified_primary_tab_buttons()
	_refresh_unified_panel_chrome()
	_queue_unified_city_panel_resize()


func _ensure_unified_primary_tab_buttons() -> void:
	if _unified_city_detail_primary_button != null and _unified_diplomacy_spy_primary_button != null and _unified_trade_primary_button != null:
		return
	if city_detail_header_row == null:
		_warn_missing_unified_panel_chrome("HeaderRow")
		return

	_unified_city_detail_primary_button = _create_unified_primary_tab_button("도시 상세", UNIFIED_PANEL_TAB_CITY_DETAIL)
	_unified_diplomacy_spy_primary_button = _create_unified_primary_tab_button("외교·첩보", UNIFIED_PANEL_TAB_DIPLOMACY_SPY)
	_unified_trade_primary_button = _create_unified_primary_tab_button("무역", UNIFIED_PANEL_TAB_TRADE)
	var collapse_index := city_detail_header_row.get_children().find(city_detail_collapse_button_placeholder)
	if collapse_index < 0:
		collapse_index = city_detail_header_row.get_child_count()
	city_detail_header_row.add_child(_unified_city_detail_primary_button)
	city_detail_header_row.move_child(_unified_city_detail_primary_button, collapse_index)
	city_detail_header_row.add_child(_unified_diplomacy_spy_primary_button)
	city_detail_header_row.move_child(_unified_diplomacy_spy_primary_button, collapse_index + 1)
	city_detail_header_row.add_child(_unified_trade_primary_button)
	city_detail_header_row.move_child(_unified_trade_primary_button, collapse_index + 2)


func _create_unified_primary_tab_button(label_text: String, tab_id: String) -> Button:
	var button := Button.new()
	button.text = label_text
	button.custom_minimum_size = Vector2(64.0, 24.0)
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
	if city_detail_eyebrow_label != null:
		city_detail_eyebrow_label.visible = false
		city_detail_eyebrow_label.text = ""
	if city_detail_heading_label != null:
		city_detail_heading_label.visible = false
	if _unified_city_detail_primary_button != null:
		_unified_city_detail_primary_button.visible = true
		var city_detail_tab_color := Color(0.82, 0.86, 0.92, 1.0)
		if _unified_primary_tab == UNIFIED_PANEL_TAB_CITY_DETAIL:
			city_detail_tab_color = Color(1.0, 0.9, 0.68, 1.0)
		_unified_city_detail_primary_button.modulate = city_detail_tab_color
	else:
		_warn_missing_unified_panel_chrome("CityDetailPrimaryButton")
	if _unified_diplomacy_spy_primary_button != null:
		_unified_diplomacy_spy_primary_button.visible = true
		var diplomacy_spy_tab_color := Color(0.82, 0.86, 0.92, 1.0)
		if _unified_primary_tab == UNIFIED_PANEL_TAB_DIPLOMACY_SPY:
			diplomacy_spy_tab_color = Color(1.0, 0.9, 0.68, 1.0)
		_unified_diplomacy_spy_primary_button.modulate = diplomacy_spy_tab_color
	else:
		_warn_missing_unified_panel_chrome("DiplomacySpyPrimaryButton")
	if _unified_trade_primary_button != null:
		_unified_trade_primary_button.visible = true
		var trade_tab_color := Color(0.82, 0.86, 0.92, 1.0)
		if _unified_primary_tab == UNIFIED_PANEL_TAB_TRADE:
			trade_tab_color = Color(1.0, 0.9, 0.68, 1.0)
		_unified_trade_primary_button.modulate = trade_tab_color
	else:
		_warn_missing_unified_panel_chrome("TradePrimaryButton")
	if city_detail_secondary_tab_row != null:
		city_detail_secondary_tab_row.visible = true
	else:
		_warn_missing_unified_panel_chrome("TabRow")

	if _unified_primary_tab == UNIFIED_PANEL_TAB_DIPLOMACY_SPY:
		if city_detail_resource_tab_button_placeholder != null:
			city_detail_resource_tab_button_placeholder.text = "외교"
			city_detail_resource_tab_button_placeholder.visible = true
			_set_city_detail_tab_active(city_detail_resource_tab_button_placeholder, _selected_diplomacy_spy_tab == DIPLOMACY_SPY_TAB_DIPLOMACY)
		else:
			_warn_missing_unified_panel_chrome("ResourceTabButtonPlaceholder")
		if city_detail_internal_trade_tab_button_placeholder != null:
			city_detail_internal_trade_tab_button_placeholder.text = "첩보"
			city_detail_internal_trade_tab_button_placeholder.visible = true
			_set_city_detail_tab_active(city_detail_internal_trade_tab_button_placeholder, _selected_diplomacy_spy_tab == DIPLOMACY_SPY_TAB_SPY)
		else:
			_warn_missing_unified_panel_chrome("InternalTradeTabButtonPlaceholder")
		if city_detail_external_trade_tab_button_placeholder != null:
			city_detail_external_trade_tab_button_placeholder.visible = false
		else:
			_warn_missing_unified_panel_chrome("ExternalTradeTabButtonPlaceholder")
	elif _unified_primary_tab == UNIFIED_PANEL_TAB_TRADE:
		if not [CITY_DETAIL_TAB_INTERNAL_TRADE, CITY_DETAIL_TAB_EXTERNAL_TRADE].has(_selected_city_detail_tab):
			_selected_city_detail_tab = CITY_DETAIL_TAB_INTERNAL_TRADE
		if city_detail_resource_tab_button_placeholder != null:
			city_detail_resource_tab_button_placeholder.visible = false
		else:
			_warn_missing_unified_panel_chrome("ResourceTabButtonPlaceholder")
		if city_detail_internal_trade_tab_button_placeholder != null:
			city_detail_internal_trade_tab_button_placeholder.text = "자국무역"
			city_detail_internal_trade_tab_button_placeholder.visible = true
			_set_city_detail_tab_active(city_detail_internal_trade_tab_button_placeholder, _selected_city_detail_tab == CITY_DETAIL_TAB_INTERNAL_TRADE)
		else:
			_warn_missing_unified_panel_chrome("InternalTradeTabButtonPlaceholder")
		if city_detail_external_trade_tab_button_placeholder != null:
			city_detail_external_trade_tab_button_placeholder.text = "타국무역"
			city_detail_external_trade_tab_button_placeholder.visible = true
			_set_city_detail_tab_active(city_detail_external_trade_tab_button_placeholder, _selected_city_detail_tab == CITY_DETAIL_TAB_EXTERNAL_TRADE)
		else:
			_warn_missing_unified_panel_chrome("ExternalTradeTabButtonPlaceholder")
	else:
		_selected_city_detail_tab = CITY_DETAIL_TAB_RESOURCES
		if city_detail_resource_tab_button_placeholder != null:
			city_detail_resource_tab_button_placeholder.text = "자원"
			city_detail_resource_tab_button_placeholder.visible = true
			_set_city_detail_tab_active(city_detail_resource_tab_button_placeholder, true)
		else:
			_warn_missing_unified_panel_chrome("ResourceTabButtonPlaceholder")
		if city_detail_internal_trade_tab_button_placeholder != null:
			city_detail_internal_trade_tab_button_placeholder.visible = false
		else:
			_warn_missing_unified_panel_chrome("InternalTradeTabButtonPlaceholder")
		if city_detail_external_trade_tab_button_placeholder != null:
			city_detail_external_trade_tab_button_placeholder.visible = false
		else:
			_warn_missing_unified_panel_chrome("ExternalTradeTabButtonPlaceholder")


func _refresh_unified_panel_content() -> void:
	_refresh_unified_panel_chrome()
	if _is_unified_city_panel_collapsed:
		return
	if _unified_primary_tab == UNIFIED_PANEL_TAB_DIPLOMACY_SPY:
		_show_unified_diplomacy_spy_content()
	elif _unified_primary_tab == UNIFIED_PANEL_TAB_TRADE and selected_city_marker != null:
		if not [CITY_DETAIL_TAB_INTERNAL_TRADE, CITY_DETAIL_TAB_EXTERNAL_TRADE].has(_selected_city_detail_tab):
			_selected_city_detail_tab = CITY_DETAIL_TAB_INTERNAL_TRADE
		_show_city_detail(selected_city_marker)
	elif selected_city_marker != null:
		_selected_city_detail_tab = CITY_DETAIL_TAB_RESOURCES
		_show_city_detail(selected_city_marker)
	else:
		_reset_city_detail_panel()
	_queue_unified_city_panel_resize()


func _reset_city_detail_panel() -> void:
	_close_manual_trade_order_panel()
	_close_internal_trade_transfer_panel()
	_set_manual_trade_execution_button_visible(false)
	if _unified_primary_tab == UNIFIED_PANEL_TAB_DIPLOMACY_SPY:
		_show_unified_diplomacy_spy_content()
		return

	_refresh_city_detail_tab_styles()
	_set_city_detail_resource_cards_enabled(false)
	_set_trade_control_card_visible(false)
	if _diplomacy_action_card != null:
		_diplomacy_action_card.visible = false
	if _spy_action_card != null:
		_spy_action_card.visible = false
	city_detail_name_label.text = "도시를 선택하세요"
	_set_city_detail_body_labels_visible(true)
	city_detail_type_label.text = ""
	city_detail_region_owner_label.text = ""
	city_detail_resource_label.text = "도시를 선택하면 자원과 경제 잠재력이 표시됩니다."
	city_detail_security_label.text = ""
	city_detail_military_label.text = ""
	city_detail_commerce_label.text = ""
	city_detail_rating_label.text = ""
	city_detail_status_label.text = ""
	city_detail_hint_label.text = "도시 선택 시 상세 정보가 갱신됩니다."
	_queue_unified_city_panel_resize()


func _show_city_detail(city_marker: WorldMapCityMarker) -> void:
	if _unified_primary_tab == UNIFIED_PANEL_TAB_DIPLOMACY_SPY:
		_show_unified_diplomacy_spy_content()
		return

	if city_marker == null:
		_reset_city_detail_panel()
		return

	if _diplomacy_action_card != null:
		_diplomacy_action_card.visible = false
	if _spy_action_card != null:
		_spy_action_card.visible = false
	city_detail_name_label.text = city_marker.display_name
	var city_data := _get_city_hud_entry(city_marker.city_id)
	var policy_id := _get_city_policy_id(city_marker.city_id, city_data)
	var policy_data := _get_governor_policy_entry(policy_id)
	var loyalty := int(city_data.get("loyalty", 75))
	_refresh_city_detail_tab_styles()
	_apply_city_detail_tab_content(city_marker, city_data, loyalty, policy_data)
	_queue_unified_city_panel_resize()


func _apply_city_detail_tab_content(city_marker: WorldMapCityMarker, city_data: Dictionary, _loyalty: int, _policy_data: Dictionary) -> void:
	match _selected_city_detail_tab:
		CITY_DETAIL_TAB_INTERNAL_TRADE:
			_set_city_detail_body_labels_visible(true)
			_apply_city_detail_default_text_tone()
			var connected_player_city_ids := _get_internal_trade_connected_player_city_ids(city_marker)
			var supply_state := _get_display_supply_state_for_city(city_marker.city_id)
			var has_manual_targets := not connected_player_city_ids.is_empty()
			city_detail_type_label.text = "무역"
			city_detail_region_owner_label.text = "자국무역"
			city_detail_resource_label.text = _format_internal_trade_route_display(city_marker, connected_player_city_ids)
			city_detail_security_label.text = _format_city_supply_state_display(supply_state)
			city_detail_military_label.text = _format_internal_trade_lead_display(connected_player_city_ids)
			city_detail_commerce_label.text = _format_internal_trade_policy_display(connected_player_city_ids)
			city_detail_rating_label.text = _format_internal_trade_transfer_result_summary(city_marker.city_id, connected_player_city_ids)
			city_detail_domestic_button_placeholder.visible = false
			_set_manual_trade_execution_button_visible(false)
			city_detail_status_label.text = ""
			city_detail_hint_label.text = "자국 성 간 보급과 수동 이송 상태를 확인합니다."
			_refresh_trade_control_ui(CITY_DETAIL_TAB_INTERNAL_TRADE, has_manual_targets)
		CITY_DETAIL_TAB_EXTERNAL_TRADE:
			_set_city_detail_body_labels_visible(true)
			_apply_city_detail_default_text_tone()
			var external_trade_candidate_city_ids := _get_external_trade_candidate_city_ids(city_marker.city_id)
			var has_external_manual_targets := not external_trade_candidate_city_ids.is_empty()
			city_detail_type_label.text = "무역"
			city_detail_region_owner_label.text = "타국무역"
			city_detail_resource_label.text = _format_external_trade_candidate_summary(city_marker.city_id, external_trade_candidate_city_ids)
			city_detail_security_label.text = _format_external_trade_relation_summary(city_marker.city_id, external_trade_candidate_city_ids)
			city_detail_military_label.text = _format_external_trade_lead_display(external_trade_candidate_city_ids)
			city_detail_commerce_label.text = _format_external_trade_policy_display(external_trade_candidate_city_ids)
			city_detail_rating_label.text = _format_external_trade_manual_order_summary(city_marker.city_id, external_trade_candidate_city_ids)
			city_detail_domestic_button_placeholder.visible = false
			_refresh_manual_trade_execution_button(city_marker.city_id, external_trade_candidate_city_ids)
			city_detail_status_label.text = ""
			city_detail_hint_label.text = "인접 외국 성, 관계 효율, 수동 무역 상태를 확인합니다."
			_refresh_trade_control_ui(CITY_DETAIL_TAB_EXTERNAL_TRADE, has_external_manual_targets)
		_:
			_set_manual_trade_execution_button_visible(false)
			_set_trade_control_card_visible(false)
			_apply_city_detail_resource_tab_content(city_marker.city_id, city_data)


func _apply_city_detail_resource_tab_content(city_id: String, city_data: Dictionary) -> void:
	_set_city_detail_body_labels_visible(true)
	_set_city_detail_resource_cards_enabled(true)
	city_detail_type_label.text = "자원 잠재력\n식량 자원"
	city_detail_type_label.add_theme_color_override("font_color", Color(0.96, 0.74, 0.34, 1.0))
	city_detail_region_owner_label.text = _extract_resource_group(str(city_data.get("resources", "")), ["쌀", "보리", "수산물"])
	city_detail_region_owner_label.add_theme_color_override("font_color", Color(0.88, 0.90, 0.86, 1.0))
	city_detail_resource_label.text = "전략 자원"
	city_detail_resource_label.add_theme_color_override("font_color", Color(0.62, 0.76, 0.88, 1.0))
	city_detail_security_label.text = _extract_resource_group(str(city_data.get("resources", "")), ["목재", "철", "말"])
	city_detail_security_label.add_theme_color_override("font_color", Color(0.88, 0.90, 0.86, 1.0))
	city_detail_military_label.text = "특산 자원"
	city_detail_military_label.add_theme_color_override("font_color", Color(0.78, 0.56, 0.88, 1.0))
	city_detail_commerce_label.text = _extract_resource_group(str(city_data.get("resources", "")), ["비단", "소금"])
	city_detail_commerce_label.add_theme_color_override("font_color", Color(0.88, 0.90, 0.86, 1.0))
	city_detail_rating_label.text = "경제 잠재력\n인구 %s / 상업력 %s" % [
		_format_star_rating(_get_city_numeric_rating(city_data, "population_rating", 0)),
		_format_star_rating(_get_city_numeric_rating(city_data, "commerce_rating", 0)),
	]
	city_detail_rating_label.add_theme_color_override("font_color", Color(0.95, 0.92, 0.82, 1.0))
	city_detail_status_label.visible = true
	city_detail_status_label.text = _format_city_storage_summary(_get_city_storage(city_id, city_data))
	city_detail_status_label.add_theme_color_override("font_color", Color(0.86, 0.92, 0.88, 1.0))
	city_detail_hint_label.text = "자원 잠재력은 생산 기반, 성 창고는 현재 보유량입니다."
	city_detail_domestic_button_placeholder.visible = false


func _ensure_city_detail_resource_cards() -> void:
	if _city_resource_potential_card != null and _city_storage_card != null:
		return
	if city_detail_content_container == null:
		return

	_city_resource_potential_card = PanelContainer.new()
	_city_resource_potential_card.name = "ResourcePotentialCard"
	_city_resource_potential_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var potential_box := VBoxContainer.new()
	potential_box.name = "ResourcePotentialCardContent"
	potential_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	potential_box.add_theme_constant_override("separation", 3)
	_city_resource_potential_card.add_child(potential_box)
	var potential_insert_index := city_detail_type_label.get_index()
	city_detail_content_container.add_child(_city_resource_potential_card)
	city_detail_content_container.move_child(_city_resource_potential_card, potential_insert_index)
	for label in [
		city_detail_type_label,
		city_detail_region_owner_label,
		city_detail_resource_label,
		city_detail_security_label,
		city_detail_military_label,
		city_detail_commerce_label,
		city_detail_rating_label,
	]:
		_move_city_detail_label_to_container(label, potential_box)

	_city_storage_card = PanelContainer.new()
	_city_storage_card.name = "CityStorageCard"
	_city_storage_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var storage_box := VBoxContainer.new()
	storage_box.name = "CityStorageCardContent"
	storage_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	storage_box.add_theme_constant_override("separation", 3)
	_city_storage_card.add_child(storage_box)
	var storage_insert_index := city_detail_status_label.get_index()
	city_detail_content_container.add_child(_city_storage_card)
	city_detail_content_container.move_child(_city_storage_card, storage_insert_index)
	_move_city_detail_label_to_container(city_detail_status_label, storage_box)
	_set_city_detail_resource_cards_enabled(false)


func _ensure_trade_control_card() -> void:
	if _trade_control_card != null:
		return
	if city_detail_content_container == null:
		return

	_trade_control_card = PanelContainer.new()
	_trade_control_card.name = "TradeControlCard"
	_trade_control_card.mouse_filter = Control.MOUSE_FILTER_PASS
	_trade_control_card.add_theme_stylebox_override("panel", _make_city_detail_resource_card_style(true))

	var trade_box := VBoxContainer.new()
	trade_box.name = "TradeControlCardContent"
	trade_box.mouse_filter = Control.MOUSE_FILTER_PASS
	trade_box.add_theme_constant_override("separation", 5)
	_trade_control_card.add_child(trade_box)

	_trade_control_title_label = Label.new()
	_trade_control_title_label.name = "TradeControlTitleLabel"
	_trade_control_title_label.text = "무역 주도"
	_trade_control_title_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.68, 1.0))
	trade_box.add_child(_trade_control_title_label)

	_trade_control_status_label = Label.new()
	_trade_control_status_label.name = "TradeControlStatusLabel"
	_trade_control_status_label.add_theme_color_override("font_color", Color(0.92, 0.90, 0.82, 1.0))
	trade_box.add_child(_trade_control_status_label)

	var button_row := HBoxContainer.new()
	button_row.name = "TradeControlButtonRow"
	button_row.mouse_filter = Control.MOUSE_FILTER_PASS
	button_row.add_theme_constant_override("separation", 6)
	trade_box.add_child(button_row)

	_trade_auto_button = Button.new()
	_trade_auto_button.name = "TradeAutoButton"
	_trade_auto_button.text = "재상에게 일임"
	_trade_auto_button.focus_mode = Control.FOCUS_NONE
	_trade_auto_button.pressed.connect(_on_trade_control_mode_button_pressed.bind(TRADE_CONTROL_MODE_CHANCELLOR))
	button_row.add_child(_trade_auto_button)

	_trade_manual_button = Button.new()
	_trade_manual_button.name = "TradeManualButton"
	_trade_manual_button.text = "수동 조정"
	_trade_manual_button.focus_mode = Control.FOCUS_NONE
	_trade_manual_button.pressed.connect(_on_trade_control_mode_button_pressed.bind(TRADE_CONTROL_MODE_MANUAL))
	button_row.add_child(_trade_manual_button)

	_trade_control_hint_label = Label.new()
	_trade_control_hint_label.name = "TradeControlHintLabel"
	_trade_control_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_trade_control_hint_label.add_theme_color_override("font_color", Color(0.72, 0.78, 0.84, 1.0))
	trade_box.add_child(_trade_control_hint_label)

	var insert_index := city_detail_content_container.get_child_count()
	if _city_storage_card != null and _city_storage_card.get_parent() == city_detail_content_container:
		insert_index = _city_storage_card.get_index()
	city_detail_content_container.add_child(_trade_control_card)
	city_detail_content_container.move_child(_trade_control_card, insert_index)
	_set_trade_control_card_visible(false)


func _move_city_detail_label_to_container(label: Label, target_container: Container) -> void:
	if label == null or target_container == null:
		return
	var current_parent := label.get_parent()
	if current_parent == target_container:
		return
	if current_parent != null:
		current_parent.remove_child(label)
	target_container.add_child(label)


func _set_city_detail_resource_cards_enabled(is_enabled: bool) -> void:
	if _city_resource_potential_card == null or _city_storage_card == null:
		return
	_city_resource_potential_card.add_theme_stylebox_override("panel", _make_city_detail_resource_card_style(is_enabled))
	_city_storage_card.add_theme_stylebox_override("panel", _make_city_detail_resource_card_style(is_enabled))


func _make_city_detail_resource_card_style(is_enabled: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	if is_enabled:
		style.bg_color = Color(0.08, 0.075, 0.055, 0.74)
		style.border_color = Color(0.70, 0.54, 0.26, 0.88)
		style.set_border_width_all(1)
		style.set_corner_radius_all(5)
		style.content_margin_left = 8.0
		style.content_margin_top = 7.0
		style.content_margin_right = 8.0
		style.content_margin_bottom = 7.0
	else:
		style.bg_color = Color(0.0, 0.0, 0.0, 0.0)
		style.border_color = Color(0.0, 0.0, 0.0, 0.0)
		style.set_border_width_all(0)
		style.set_corner_radius_all(0)
		style.content_margin_left = 0.0
		style.content_margin_top = 0.0
		style.content_margin_right = 0.0
		style.content_margin_bottom = 0.0
	return style


func _set_city_detail_body_labels_visible(should_show: bool) -> void:
	for label in [
		city_detail_type_label,
		city_detail_region_owner_label,
		city_detail_resource_label,
		city_detail_security_label,
		city_detail_military_label,
		city_detail_commerce_label,
		city_detail_rating_label,
		city_detail_status_label,
		city_detail_hint_label,
	]:
		if label != null:
			label.visible = should_show
	if _city_resource_potential_card != null:
		_city_resource_potential_card.visible = should_show
	if _city_storage_card != null:
		_city_storage_card.visible = should_show
	if _trade_control_card != null and not _is_trade_control_tab_active():
		_trade_control_card.visible = false
	if city_detail_domestic_button_placeholder != null:
		city_detail_domestic_button_placeholder.visible = should_show


func _apply_city_detail_default_text_tone() -> void:
	_set_city_detail_resource_cards_enabled(false)
	_set_trade_control_card_visible(false)
	for label in [
		city_detail_type_label,
		city_detail_region_owner_label,
		city_detail_resource_label,
		city_detail_security_label,
		city_detail_military_label,
		city_detail_commerce_label,
		city_detail_rating_label,
	]:
		if label != null:
			label.add_theme_color_override("font_color", Color(0.82, 0.86, 0.92, 1.0))
	if city_detail_status_label != null:
		city_detail_status_label.add_theme_color_override("font_color", Color(0.95, 0.94, 0.86, 1.0))
	if city_detail_hint_label != null:
		city_detail_hint_label.add_theme_color_override("font_color", Color(0.7, 0.76, 0.84, 1.0))
	if city_detail_domestic_button_placeholder != null:
		city_detail_domestic_button_placeholder.visible = true


func _set_trade_control_card_visible(should_show: bool) -> void:
	if _trade_control_card != null:
		_trade_control_card.visible = should_show


func _ensure_manual_trade_execution_button() -> void:
	if _manual_trade_execution_button != null:
		return
	if city_detail_content_container == null:
		return
	_manual_trade_execution_button = Button.new()
	_manual_trade_execution_button.name = "ManualTradeExecutionButton"
	_manual_trade_execution_button.text = "수동 무역 실행"
	_manual_trade_execution_button.visible = false
	_manual_trade_execution_button.custom_minimum_size = Vector2(180.0, 30.0)
	_manual_trade_execution_button.pressed.connect(_on_manual_trade_execution_button_pressed)
	city_detail_content_container.add_child(_manual_trade_execution_button)
	if city_detail_rating_label != null and city_detail_rating_label.get_parent() == city_detail_content_container:
		city_detail_content_container.move_child(_manual_trade_execution_button, city_detail_rating_label.get_index() + 1)


func _set_manual_trade_execution_button_visible(should_show: bool) -> void:
	if _manual_trade_execution_button != null:
		_manual_trade_execution_button.visible = should_show


func _refresh_manual_trade_execution_button(source_city_id: String, candidate_city_ids: Array[String]) -> void:
	_ensure_manual_trade_execution_button()
	if _manual_trade_execution_button == null:
		return
	var order: Dictionary = _manual_trade_orders.get(source_city_id, {})
	var should_show := (
		_unified_primary_tab == UNIFIED_PANEL_TAB_TRADE
		and _selected_city_detail_tab == CITY_DETAIL_TAB_EXTERNAL_TRADE
		and selected_city_marker != null
		and not candidate_city_ids.is_empty()
		and not order.is_empty()
	)
	_manual_trade_execution_button.visible = should_show
	_manual_trade_execution_button.disabled = not should_show


func _is_trade_control_tab_active() -> bool:
	return _unified_primary_tab == UNIFIED_PANEL_TAB_TRADE and [CITY_DETAIL_TAB_INTERNAL_TRADE, CITY_DETAIL_TAB_EXTERNAL_TRADE].has(_selected_city_detail_tab) and selected_city_marker != null


func _refresh_trade_control_ui(tab_id: String, has_manual_targets: bool) -> void:
	_ensure_trade_control_card()
	if _trade_control_card == null:
		return
	if _unified_primary_tab != UNIFIED_PANEL_TAB_TRADE or not [CITY_DETAIL_TAB_INTERNAL_TRADE, CITY_DETAIL_TAB_EXTERNAL_TRADE].has(tab_id) or selected_city_marker == null:
		_set_trade_control_card_visible(false)
		return
	var mode := str(_trade_control_modes.get(tab_id, TRADE_CONTROL_MODE_CHANCELLOR))
	if mode == TRADE_CONTROL_MODE_MANUAL and not has_manual_targets:
		mode = TRADE_CONTROL_MODE_CHANCELLOR
		_trade_control_modes[tab_id] = mode
	_set_trade_control_card_visible(true)
	if _trade_control_status_label != null:
		_trade_control_status_label.text = "현재: %s" % _get_trade_control_mode_label(mode)
	if _trade_auto_button != null:
		_trade_auto_button.disabled = false
		_apply_trade_control_button_state(_trade_auto_button, mode == TRADE_CONTROL_MODE_CHANCELLOR)
	if _trade_manual_button != null:
		_trade_manual_button.disabled = not has_manual_targets
		_apply_trade_control_button_state(_trade_manual_button, mode == TRADE_CONTROL_MODE_MANUAL and has_manual_targets)
	if _trade_control_hint_label != null:
		_trade_control_hint_label.text = _get_trade_control_hint(tab_id, mode, has_manual_targets)


func _apply_trade_control_button_state(button: Button, is_active: bool) -> void:
	if button == null:
		return
	if button.disabled:
		button.modulate = Color(0.48, 0.48, 0.48, 0.72)
	elif is_active:
		button.modulate = Color(1.0, 0.9, 0.68, 1.0)
	else:
		button.modulate = Color(0.82, 0.86, 0.92, 1.0)


func _get_trade_control_mode_label(mode: String) -> String:
	if mode == TRADE_CONTROL_MODE_MANUAL:
		return "수동 조정"
	return "재상 일임"


func _get_trade_control_hint(tab_id: String, mode: String, has_manual_targets: bool) -> String:
	if not has_manual_targets:
		if tab_id == CITY_DETAIL_TAB_INTERNAL_TRADE:
			return "수동 이송 잠김 · 연결 아군 성 필요"
		return "수동 무역 잠김 · 인접 외국 성 필요"
	if mode == TRADE_CONTROL_MODE_MANUAL:
		if tab_id == CITY_DETAIL_TAB_INTERNAL_TRADE:
			return "수동 이송 · 연결 아군 성으로 창고 자원을 옮깁니다."
		return "수동 무역 · 수입/수출 계획을 저장한 뒤 실행합니다."
	return "재상 일임 · 연결 성, 관계, 창고 상태를 기준으로 자동 조정합니다."


func _ensure_manual_trade_order_panel() -> void:
	if _manual_trade_order_panel != null:
		return
	var worldmap_ui := get_node_or_null("WorldMapUI") as CanvasLayer
	if worldmap_ui == null:
		return

	_manual_trade_order_panel = PanelContainer.new()
	_manual_trade_order_panel.name = "ManualTradeOrderPanel"
	_manual_trade_order_panel.visible = false
	_manual_trade_order_panel.z_index = 130
	_manual_trade_order_panel.anchor_left = 0.5
	_manual_trade_order_panel.anchor_right = 0.5
	_manual_trade_order_panel.anchor_top = 0.5
	_manual_trade_order_panel.anchor_bottom = 0.5
	_manual_trade_order_panel.offset_left = -300.0
	_manual_trade_order_panel.offset_right = 300.0
	_manual_trade_order_panel.offset_top = -260.0
	_manual_trade_order_panel.offset_bottom = 260.0
	_manual_trade_order_panel.custom_minimum_size = Vector2(600.0, 520.0)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.045, 0.05, 0.065, 0.96)
	panel_style.border_color = Color(0.78, 0.58, 0.28, 0.95)
	panel_style.set_border_width_all(1)
	panel_style.set_corner_radius_all(6)
	panel_style.content_margin_left = 12.0
	panel_style.content_margin_top = 10.0
	panel_style.content_margin_right = 12.0
	panel_style.content_margin_bottom = 10.0
	_manual_trade_order_panel.add_theme_stylebox_override("panel", panel_style)
	worldmap_ui.add_child(_manual_trade_order_panel)

	var content := VBoxContainer.new()
	content.name = "ManualTradeOrderPanelContent"
	content.add_theme_constant_override("separation", 6)
	_manual_trade_order_panel.add_child(content)

	var title_label := Label.new()
	title_label.name = "ManualTradeOrderTitleLabel"
	title_label.text = "타국무역 수동 조정"
	title_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.68, 1.0))
	content.add_child(title_label)

	_manual_trade_source_label = Label.new()
	_manual_trade_source_label.name = "ManualTradeSourceLabel"
	_manual_trade_source_label.add_theme_color_override("font_color", Color(0.88, 0.90, 0.86, 1.0))
	content.add_child(_manual_trade_source_label)

	var target_row := HBoxContainer.new()
	target_row.name = "ManualTradeTargetRow"
	target_row.add_theme_constant_override("separation", 8)
	content.add_child(target_row)
	var target_label := Label.new()
	target_label.text = "교역 상대:"
	target_label.custom_minimum_size = Vector2(74.0, 0.0)
	target_row.add_child(target_label)
	_manual_trade_target_option = OptionButton.new()
	_manual_trade_target_option.name = "ManualTradeTargetOption"
	_manual_trade_target_option.custom_minimum_size = Vector2(180.0, 28.0)
	_manual_trade_target_option.item_selected.connect(_on_manual_trade_target_selected)
	target_row.add_child(_manual_trade_target_option)

	_manual_trade_relation_label = Label.new()
	_manual_trade_relation_label.name = "ManualTradeRelationLabel"
	_manual_trade_relation_label.add_theme_color_override("font_color", Color(0.72, 0.78, 0.84, 1.0))
	content.add_child(_manual_trade_relation_label)

	var header_row := GridContainer.new()
	header_row.name = "ManualTradeResourceHeader"
	header_row.columns = 3
	content.add_child(header_row)
	for header_text in ["자원", "행동", "수량"]:
		var header := Label.new()
		header.text = header_text
		header.custom_minimum_size = Vector2(150.0, 0.0)
		header.add_theme_color_override("font_color", Color(0.96, 0.74, 0.34, 1.0))
		header_row.add_child(header)

	var row_grid := GridContainer.new()
	row_grid.name = "ManualTradeResourceRows"
	row_grid.columns = 3
	content.add_child(row_grid)
	for resource_id in MANUAL_TRADE_RESOURCE_ORDER:
		var manual_trade_resource_name_label := Label.new()
		manual_trade_resource_name_label.text = str(RESOURCE_LABELS.get(resource_id, resource_id))
		manual_trade_resource_name_label.custom_minimum_size = Vector2(150.0, 26.0)
		row_grid.add_child(manual_trade_resource_name_label)

		var action_option := OptionButton.new()
		action_option.name = "ManualTradeAction_%s" % resource_id
		action_option.custom_minimum_size = Vector2(120.0, 26.0)
		action_option.add_item("안함")
		action_option.set_item_metadata(0, MANUAL_TRADE_ACTION_NONE)
		action_option.add_item("수입")
		action_option.set_item_metadata(1, MANUAL_TRADE_ACTION_IMPORT)
		action_option.add_item("수출")
		action_option.set_item_metadata(2, MANUAL_TRADE_ACTION_EXPORT)
		action_option.item_selected.connect(_on_manual_trade_order_input_changed.bind(resource_id))
		_manual_trade_action_options[resource_id] = action_option
		row_grid.add_child(action_option)

		var amount_spinbox := SpinBox.new()
		amount_spinbox.name = "ManualTradeAmount_%s" % resource_id
		amount_spinbox.min_value = 0.0
		amount_spinbox.max_value = 999.0
		amount_spinbox.step = 1.0
		amount_spinbox.value = 0.0
		amount_spinbox.custom_minimum_size = Vector2(90.0, 26.0)
		amount_spinbox.value_changed.connect(_on_manual_trade_amount_changed.bind(resource_id))
		_manual_trade_amount_spinboxes[resource_id] = amount_spinbox
		row_grid.add_child(amount_spinbox)

	var preview_title := Label.new()
	preview_title.text = "예상 결과"
	preview_title.add_theme_color_override("font_color", Color(1.0, 0.9, 0.68, 1.0))
	content.add_child(preview_title)

	_manual_trade_preview_label = Label.new()
	_manual_trade_preview_label.name = "ManualTradePreviewLabel"
	_manual_trade_preview_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_manual_trade_preview_label.add_theme_color_override("font_color", Color(0.88, 0.90, 0.86, 1.0))
	content.add_child(_manual_trade_preview_label)

	_manual_trade_status_label = Label.new()
	_manual_trade_status_label.name = "ManualTradeStatusLabel"
	_manual_trade_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_manual_trade_status_label.add_theme_color_override("font_color", Color(0.72, 0.78, 0.84, 1.0))
	content.add_child(_manual_trade_status_label)

	var button_row := HBoxContainer.new()
	button_row.name = "ManualTradeButtonRow"
	button_row.add_theme_constant_override("separation", 8)
	content.add_child(button_row)

	var confirm_button := Button.new()
	confirm_button.name = "ManualTradeConfirmButton"
	confirm_button.text = "명령 저장"
	confirm_button.pressed.connect(_on_manual_trade_order_confirm_pressed)
	button_row.add_child(confirm_button)

	var cancel_button := Button.new()
	cancel_button.name = "ManualTradeCancelButton"
	cancel_button.text = "취소"
	cancel_button.pressed.connect(_on_manual_trade_order_cancel_pressed)
	button_row.add_child(cancel_button)


func _open_manual_trade_order_panel() -> void:
	_ensure_manual_trade_order_panel()
	if _manual_trade_order_panel == null:
		return
	if selected_city_marker == null:
		return
	var source_city_id := selected_city_marker.city_id
	if not _is_city_owned_by_player_mvp(source_city_id):
		return
	var candidate_city_ids := _get_external_trade_candidate_city_ids(source_city_id)
	if candidate_city_ids.is_empty():
		if _trade_control_hint_label != null:
			_trade_control_hint_label.text = "인접 외국 교역 후보가 생기면 수동 조정을 사용할 수 있습니다."
		return
	_manual_trade_current_source_city_id = source_city_id
	_populate_manual_trade_order_panel(source_city_id, candidate_city_ids)
	_manual_trade_order_panel.visible = true
	_manual_trade_order_panel.move_to_front()


func _close_manual_trade_order_panel() -> void:
	if _manual_trade_order_panel != null:
		_manual_trade_order_panel.visible = false


func _populate_manual_trade_order_panel(source_city_id: String, candidate_city_ids: Array[String]) -> void:
	if _manual_trade_source_label != null:
		_manual_trade_source_label.text = "출발 성: %s" % _format_city_name_by_id(source_city_id, source_city_id)
	if _manual_trade_target_option != null:
		_manual_trade_target_option.clear()
		for candidate_city_id in candidate_city_ids:
			var index := _manual_trade_target_option.item_count
			_manual_trade_target_option.add_item(_format_city_name_by_id(candidate_city_id, candidate_city_id))
			_manual_trade_target_option.set_item_metadata(index, candidate_city_id)
	var saved_order: Dictionary = _manual_trade_orders.get(source_city_id, {})
	var saved_target_id := str(saved_order.get("target_city_id", ""))
	if _manual_trade_target_option != null and not saved_target_id.is_empty():
		_select_option_by_metadata(_manual_trade_target_option, saved_target_id)
	_reset_manual_trade_order_inputs()
	if not saved_order.is_empty():
		_apply_saved_manual_trade_order_to_inputs(saved_order)
	if _manual_trade_status_label != null:
		_manual_trade_status_label.text = "명령 저장 후 타국무역 탭의 수동 무역 실행으로 선택 성 창고에 반영합니다."
	_refresh_manual_trade_order_relation()
	_refresh_manual_trade_order_preview()


func _reset_manual_trade_order_inputs() -> void:
	for resource_id in MANUAL_TRADE_RESOURCE_ORDER:
		var action_option := _manual_trade_action_options.get(resource_id) as OptionButton
		if action_option != null:
			action_option.select(0)
		var amount_spinbox := _manual_trade_amount_spinboxes.get(resource_id) as SpinBox
		if amount_spinbox != null:
			amount_spinbox.value = 0.0


func _apply_saved_manual_trade_order_to_inputs(saved_order: Dictionary) -> void:
	var orders: Variant = saved_order.get("orders", {})
	if not orders is Dictionary:
		return
	for resource_id in MANUAL_TRADE_RESOURCE_ORDER:
		if not (orders as Dictionary).has(resource_id):
			continue
		var order_variant: Variant = (orders as Dictionary).get(resource_id, {})
		if not order_variant is Dictionary:
			continue
		var order := order_variant as Dictionary
		var action := str(order.get("action", MANUAL_TRADE_ACTION_NONE))
		var amount := maxi(0, int(order.get("amount", 0)))
		var action_option := _manual_trade_action_options.get(resource_id) as OptionButton
		if action_option != null:
			_select_option_by_metadata(action_option, action)
		var amount_spinbox := _manual_trade_amount_spinboxes.get(resource_id) as SpinBox
		if amount_spinbox != null:
			amount_spinbox.value = float(amount)


func _on_manual_trade_target_selected(_index: int) -> void:
	_refresh_manual_trade_order_relation()
	_refresh_manual_trade_order_preview()


func _on_manual_trade_order_input_changed(_index: int, _resource_id: String) -> void:
	_refresh_manual_trade_order_preview()


func _on_manual_trade_amount_changed(_value: float, _resource_id: String) -> void:
	_refresh_manual_trade_order_preview()


func _refresh_manual_trade_order_relation() -> void:
	if _manual_trade_relation_label == null:
		return
	var source_city_id := _manual_trade_current_source_city_id
	var target_city_id := _get_selected_manual_trade_target_city_id()
	if source_city_id.is_empty() or target_city_id.is_empty():
		_manual_trade_relation_label.text = "관계: 교역 상대를 선택하십시오."
		return
	var source_faction_id := _get_city_owner_faction_id_for_trade_display(source_city_id)
	var target_faction_id := _get_city_owner_faction_id_for_trade_display(target_city_id)
	var market_summary := _format_trade_market_prices_for_external_trade_ui()
	_manual_trade_relation_label.text = "관계: %s / %s / 효율 x%.2f / 시장가 반영%s" % [
		_format_faction_relation_status_for_ui(_get_faction_relation_status(source_faction_id, target_faction_id)),
		_format_trade_availability_for_ui(source_faction_id, target_faction_id),
		_get_trade_relation_multiplier_for_ui(source_faction_id, target_faction_id),
		"\n%s" % market_summary if not market_summary.is_empty() else "",
	]


func _build_manual_trade_order_items_from_panel() -> Dictionary:
	var orders := {}
	for resource_id in MANUAL_TRADE_RESOURCE_ORDER:
		var action := _get_manual_trade_action(resource_id)
		var amount := _get_manual_trade_amount(resource_id)
		if action == MANUAL_TRADE_ACTION_NONE or amount <= 0:
			continue
		orders[resource_id] = {"action": action, "amount": amount}
	return orders


func _refresh_manual_trade_order_preview() -> void:
	if _manual_trade_preview_label == null:
		return
	_manual_trade_preview_label.text = _format_manual_trade_preview_summary(_build_manual_trade_order_preview())


func _build_manual_trade_order_preview() -> Dictionary:
	return _calculate_external_trade_delta({
		"source_city_id": _manual_trade_current_source_city_id,
		"target_city_id": _get_selected_manual_trade_target_city_id(),
		"orders": _build_manual_trade_order_items_from_panel(),
	})


func _format_manual_trade_preview_summary(preview: Dictionary) -> String:
	var parts: Array[String] = ["금전 %s" % _format_signed_int(int(preview.get("gold", 0)))]
	for resource_id in MANUAL_TRADE_RESOURCE_ORDER:
		parts.append("%s %s" % [
			str(RESOURCE_LABELS.get(resource_id, resource_id)),
			_format_signed_int(int(preview.get(resource_id, 0))),
		])
	var summary := " / ".join(parts)
	var market_text := _format_trade_market_prices_for_external_trade_ui()
	if preview.has("efficiency") and float(preview.get("efficiency", 0.0)) > 0.0:
		return "효율 x%.2f 적용 · %s%s" % [float(preview.get("efficiency", 0.0)), summary, "\n%s" % market_text if not market_text.is_empty() else ""]
	if not market_text.is_empty():
		return "%s\n%s" % [summary, market_text]
	return summary


func _get_manual_trade_action(resource_id: String) -> String:
	var action_option := _manual_trade_action_options.get(resource_id) as OptionButton
	if action_option == null:
		return MANUAL_TRADE_ACTION_NONE
	var selected_index := action_option.selected
	if selected_index < 0:
		return MANUAL_TRADE_ACTION_NONE
	return str(action_option.get_item_metadata(selected_index))


func _get_manual_trade_amount(resource_id: String) -> int:
	var amount_spinbox := _manual_trade_amount_spinboxes.get(resource_id) as SpinBox
	if amount_spinbox == null:
		return 0
	return clampi(int(amount_spinbox.value), 0, 999)


func _get_selected_manual_trade_target_city_id() -> String:
	if _manual_trade_target_option == null:
		return ""
	var selected_index := _manual_trade_target_option.selected
	if selected_index < 0:
		return ""
	return str(_manual_trade_target_option.get_item_metadata(selected_index))


func _on_manual_trade_order_confirm_pressed() -> void:
	var source_city_id := _manual_trade_current_source_city_id
	var target_city_id := _get_selected_manual_trade_target_city_id()
	if source_city_id.is_empty() or target_city_id.is_empty():
		if _manual_trade_status_label != null:
			_manual_trade_status_label.text = "교역 상대를 선택하십시오."
		return
	var source_faction_id := _get_city_owner_faction_id_for_trade_display(source_city_id)
	var target_faction_id := _get_city_owner_faction_id_for_trade_display(target_city_id)
	if not _can_trade_between_factions(source_faction_id, target_faction_id):
		if _manual_trade_status_label != null:
			_manual_trade_status_label.text = "현재 관계에서는 교역할 수 없습니다."
		return
	var efficiency := _get_trade_efficiency_for_cities(source_city_id, target_city_id)
	if efficiency <= 0.0:
		if _manual_trade_status_label != null:
			_manual_trade_status_label.text = "교역 효율을 확인할 수 없습니다."
		return
	var orders := _build_manual_trade_order_items_from_panel()
	if orders.is_empty():
		if _manual_trade_status_label != null:
			_manual_trade_status_label.text = "수입/수출 자원과 수량을 하나 이상 입력하십시오."
		return
	var preview := _calculate_external_trade_delta({
		"source_city_id": source_city_id,
		"target_city_id": target_city_id,
		"orders": orders,
	})
	var payload := {
		"source_city_id": source_city_id,
		"target_city_id": target_city_id,
		"trade_type": "external",
		"mode": TRADE_CONTROL_MODE_MANUAL,
		"orders": orders,
		"preview": preview,
		"efficiency": efficiency,
	}
	_manual_trade_orders[source_city_id] = payload
	print("[WorldMap] Manual external trade order stored: %s" % str(payload))
	_close_manual_trade_order_panel()
	_refresh_unified_panel_content()


func _on_manual_trade_order_cancel_pressed() -> void:
	_close_manual_trade_order_panel()


func _on_manual_trade_execution_button_pressed() -> void:
	if selected_city_marker == null:
		return
	var source_city_id := selected_city_marker.city_id
	var order: Dictionary = _manual_trade_orders.get(source_city_id, {})
	var result := _execute_external_manual_trade_order(order)
	_player_state["last_external_manual_trade_execution_result"] = result.duplicate(true)
	if bool(result.get("ok", false)):
		_manual_trade_orders.erase(source_city_id)
		print("[WorldMap] External manual trade executed: %s" % str(result))
	else:
		print("[WorldMap] External manual trade execution failed: %s" % str(result))
	_refresh_city_hud_data_bindings()
	_refresh_left_world_status_panel()
	_refresh_unified_panel_content()
	_queue_unified_city_panel_resize()


func _execute_external_manual_trade_order(order: Dictionary) -> Dictionary:
	var validation := _validate_external_manual_trade_execution(order)
	if not bool(validation.get("ok", false)):
		if not order.is_empty():
			validation["source_city_id"] = str(order.get("source_city_id", ""))
			validation["target_city_id"] = str(order.get("target_city_id", ""))
		return validation
	var source_city_id := str(order.get("source_city_id", ""))
	var target_city_id := str(order.get("target_city_id", ""))
	var target_faction_id := _get_city_owner_faction_id_for_trade_display(target_city_id)
	var applied := _build_external_manual_trade_execution_preview(order)
	var efficiency := float(applied.get("efficiency", _get_trade_efficiency_for_cities(source_city_id, target_city_id)))
	var source_storage := _get_city_storage(source_city_id, _get_city_hud_entry(source_city_id))
	for resource_id in ["gold"] + MANUAL_TRADE_RESOURCE_ORDER:
		var delta := int(applied.get(resource_id, 0))
		if delta == 0:
			continue
		source_storage[resource_id] = maxi(0, int(source_storage.get(resource_id, 0)) + delta)
	_set_city_storage(source_city_id, source_storage)
	return {
		"ok": true,
		"source_city_id": source_city_id,
		"target_city_id": target_city_id,
		"target_faction_id": target_faction_id,
		"applied": applied,
		"efficiency": efficiency,
		"market_turn": int(applied.get("market_turn", _player_state.get("trade_market_turn", 0))),
		"market_prices": _get_trade_market_price_snapshot_for_order(order),
		"message": "수동 무역 실행 완료",
	}


func _validate_external_manual_trade_execution(order: Dictionary) -> Dictionary:
	if order.is_empty():
		return {"ok": false, "reason": "missing_order", "message": "실행할 수동 무역 명령이 없습니다."}
	var source_city_id := str(order.get("source_city_id", ""))
	var target_city_id := str(order.get("target_city_id", ""))
	if source_city_id.is_empty():
		return {"ok": false, "reason": "source", "message": "출발 성을 확인할 수 없습니다."}
	if not _is_city_owned_by_player_mvp(source_city_id):
		return {"ok": false, "reason": "source_owner", "message": "플레이어 소유 성에서만 실행할 수 있습니다."}
	if target_city_id.is_empty():
		return {"ok": false, "reason": "target", "message": "교역 대상을 확인할 수 없습니다."}
	if not _get_external_trade_candidate_city_ids(source_city_id).has(target_city_id):
		return {"ok": false, "reason": "target_invalid", "message": "교역 대상이 더 이상 유효하지 않습니다."}
	var source_faction_id := _get_city_owner_faction_id_for_trade_display(source_city_id)
	var target_faction_id := _get_city_owner_faction_id_for_trade_display(target_city_id)
	if source_faction_id.is_empty() or target_faction_id.is_empty() or source_faction_id == target_faction_id:
		return {"ok": false, "reason": "faction", "message": "교역 대상 세력을 확인할 수 없습니다."}
	if not _can_trade_between_factions(source_faction_id, target_faction_id):
		return {"ok": false, "reason": "relation", "message": "현재 관계에서는 교역할 수 없습니다."}
	var efficiency := _get_trade_efficiency_for_cities(source_city_id, target_city_id)
	if efficiency <= 0.0:
		return {"ok": false, "reason": "efficiency", "message": "교역 효율을 확인할 수 없습니다."}
	var orders_variant: Variant = order.get("orders", {})
	if not orders_variant is Dictionary:
		return {"ok": false, "reason": "orders", "message": "실행할 수동 무역 명령이 없습니다."}
	var orders := orders_variant as Dictionary
	var source_storage := _get_city_storage(source_city_id, _get_city_hud_entry(source_city_id))
	var total_import_gold_cost := 0
	var has_actionable_item := false
	for resource_id_variant in orders.keys():
		var resource_id := str(resource_id_variant)
		if not MANUAL_TRADE_RESOURCE_ORDER.has(resource_id):
			return {"ok": false, "reason": "resource", "message": "허용되지 않은 자원입니다."}
		var order_item_variant: Variant = orders.get(resource_id, {})
		if not order_item_variant is Dictionary:
			return {"ok": false, "reason": "order_item", "message": "수동 무역 명령 형식이 올바르지 않습니다."}
		var order_item := order_item_variant as Dictionary
		var action := str(order_item.get("action", MANUAL_TRADE_ACTION_NONE))
		var amount := int(order_item.get("amount", 0))
		if amount < 0:
			return {"ok": false, "reason": "amount", "message": "수량은 0 이상이어야 합니다."}
		if action == MANUAL_TRADE_ACTION_NONE or amount <= 0:
			continue
		if not [MANUAL_TRADE_ACTION_IMPORT, MANUAL_TRADE_ACTION_EXPORT].has(action):
			return {"ok": false, "reason": "action", "message": "수동 무역 행동이 올바르지 않습니다."}
		has_actionable_item = true
		if action == MANUAL_TRADE_ACTION_IMPORT:
			total_import_gold_cost += _calculate_trade_import_cost(resource_id, amount, efficiency)
		elif action == MANUAL_TRADE_ACTION_EXPORT and amount > _get_city_storage_amount(source_storage, resource_id):
			return {"ok": false, "reason": "resource_shortage", "message": "수출할 자원이 부족합니다."}
	if not has_actionable_item:
		return {"ok": false, "reason": "empty", "message": "실행 가능한 자원 항목이 없습니다."}
	if total_import_gold_cost > _get_city_storage_amount(source_storage, "gold"):
		return {"ok": false, "reason": "gold", "message": "금전이 부족합니다."}
	return {"ok": true}


func _build_external_manual_trade_execution_preview(order: Dictionary) -> Dictionary:
	return _calculate_external_trade_delta(order)


func _build_empty_external_trade_delta() -> Dictionary:
	var delta := {"gold": 0}
	for resource_id in MANUAL_TRADE_RESOURCE_ORDER:
		delta[resource_id] = 0
	return delta


func _get_trade_efficiency_for_cities(source_city_id: String, target_city_id: String) -> float:
	if source_city_id.is_empty() or target_city_id.is_empty():
		return 0.0
	var source_faction_id := _get_city_owner_faction_id_for_trade_display(source_city_id)
	var target_faction_id := _get_city_owner_faction_id_for_trade_display(target_city_id)
	if not _can_trade_between_factions(source_faction_id, target_faction_id):
		return 0.0
	return clampf(_get_trade_relation_multiplier_for_ui(source_faction_id, target_faction_id), TRADE_EFFICIENCY_MIN, TRADE_EFFICIENCY_MAX)


func _calculate_trade_import_cost(resource_id: String, amount: int, efficiency: float) -> int:
	var safe_amount := maxi(0, amount)
	if safe_amount <= 0 or efficiency <= 0.0:
		return 0
	var base_price := _get_trade_market_price(resource_id)
	var safe_efficiency := clampf(efficiency, TRADE_EFFICIENCY_MIN, TRADE_EFFICIENCY_MAX)
	return maxi(0, ceili(float(base_price * safe_amount) / safe_efficiency))


func _calculate_trade_export_gain(resource_id: String, amount: int, efficiency: float) -> int:
	var safe_amount := maxi(0, amount)
	if safe_amount <= 0 or efficiency <= 0.0:
		return 0
	var base_price := _get_trade_market_price(resource_id)
	var safe_efficiency := clampf(efficiency, TRADE_EFFICIENCY_MIN, TRADE_EFFICIENCY_MAX)
	return maxi(0, floori(float(base_price * safe_amount) * safe_efficiency))


func _calculate_external_trade_delta(order: Dictionary) -> Dictionary:
	var delta := _build_empty_external_trade_delta()
	var source_city_id := str(order.get("source_city_id", ""))
	var target_city_id := str(order.get("target_city_id", ""))
	var efficiency := _get_trade_efficiency_for_cities(source_city_id, target_city_id)
	delta["efficiency"] = efficiency
	delta["market_turn"] = maxi(0, int(_player_state.get("trade_market_turn", 0)))
	var orders_variant: Variant = order.get("orders", {})
	if not orders_variant is Dictionary:
		return delta
	if efficiency <= 0.0:
		return delta
	var orders := orders_variant as Dictionary
	for resource_id in MANUAL_TRADE_RESOURCE_ORDER:
		var order_item_variant: Variant = orders.get(resource_id, {})
		if not order_item_variant is Dictionary:
			continue
		var order_item := order_item_variant as Dictionary
		var action := str(order_item.get("action", MANUAL_TRADE_ACTION_NONE))
		var amount := maxi(0, int(order_item.get("amount", 0)))
		if action == MANUAL_TRADE_ACTION_IMPORT and amount > 0:
			delta[resource_id] = int(delta.get(resource_id, 0)) + amount
			delta["gold"] = int(delta.get("gold", 0)) - _calculate_trade_import_cost(resource_id, amount, efficiency)
		elif action == MANUAL_TRADE_ACTION_EXPORT and amount > 0:
			delta[resource_id] = int(delta.get(resource_id, 0)) - amount
			delta["gold"] = int(delta.get("gold", 0)) + _calculate_trade_export_gain(resource_id, amount, efficiency)
	return delta


func _apply_chancellor_auto_trade_for_world_turn(turn_number: int) -> Dictionary:
	var safe_turn := maxi(1, turn_number)
	if int(_player_state.get("last_chancellor_auto_trade_turn", 0)) == safe_turn:
		var previous_result: Variant = _player_state.get("last_chancellor_auto_trade_result", {})
		if previous_result is Dictionary and not (previous_result as Dictionary).is_empty():
			return (previous_result as Dictionary).duplicate(true)
		return {"ok": false, "reason": "already_applied", "turn": safe_turn, "message": "이번 턴 재상 자동무역은 이미 처리되었습니다."}
	var chancellor_id := str(_player_state.get("chancellor_id", ""))
	if chancellor_id.is_empty():
		var no_chancellor_result := {
			"turn": safe_turn,
			"ok": false,
			"reason": "no_chancellor",
			"message": "재상이 없어 자동무역을 실행하지 않았습니다.",
		}
		_record_chancellor_auto_trade_result(no_chancellor_result)
		return no_chancellor_result
	var chancellor_data := _get_hero_entry(chancellor_id)
	if chancellor_data.is_empty() or str(chancellor_data.get("side", "")) != PLAYER_FACTION_ID:
		var invalid_chancellor_result := {
			"turn": safe_turn,
			"ok": false,
			"reason": "invalid_chancellor",
			"chancellor_id": chancellor_id,
			"message": "재상 정보를 확인할 수 없어 자동무역을 실행하지 않았습니다.",
		}
		_record_chancellor_auto_trade_result(invalid_chancellor_result)
		return invalid_chancellor_result
	var owned_city_ids := _get_player_owned_city_ids_for_chancellor_auto_trade()
	if owned_city_ids.is_empty():
		var no_city_result := {
			"turn": safe_turn,
			"ok": false,
			"reason": "no_player_city",
			"chancellor_id": chancellor_id,
			"message": "플레이어 소유 성이 없어 자동무역을 실행하지 않았습니다.",
		}
		_record_chancellor_auto_trade_result(no_city_result)
		return no_city_result
	var policy_id := _normalize_chancellor_policy_id(str(_player_state.get("chancellor_policy_id", "balanced")))
	var internal_enabled := str(_trade_control_modes.get(CITY_DETAIL_TAB_INTERNAL_TRADE, TRADE_CONTROL_MODE_CHANCELLOR)) == TRADE_CONTROL_MODE_CHANCELLOR
	var external_enabled := str(_trade_control_modes.get(CITY_DETAIL_TAB_EXTERNAL_TRADE, TRADE_CONTROL_MODE_CHANCELLOR)) == TRADE_CONTROL_MODE_CHANCELLOR
	if not internal_enabled and not external_enabled:
		var disabled_result := {
			"turn": safe_turn,
			"ok": false,
			"reason": "disabled",
			"chancellor_id": chancellor_id,
			"policy_id": policy_id,
			"message": "재상 일임 무역 모드가 없어 자동무역을 실행하지 않았습니다.",
		}
		_record_chancellor_auto_trade_result(disabled_result)
		return disabled_result
	var internal_result := {"enabled": internal_enabled, "applied": []}
	var external_result := {"enabled": external_enabled, "applied": []}
	if internal_enabled:
		internal_result = _apply_chancellor_internal_auto_trade(owned_city_ids, policy_id, chancellor_data)
	if external_enabled:
		external_result = _apply_chancellor_external_auto_trade(owned_city_ids, policy_id, chancellor_data)
	var applied_count := int((internal_result.get("applied", []) as Array).size()) + int((external_result.get("applied", []) as Array).size())
	var result := {
		"turn": safe_turn,
		"ok": applied_count > 0,
		"chancellor_id": chancellor_id,
		"policy_id": policy_id,
		"internal": internal_result,
		"external": external_result,
		"message": "재상 자동무역 적용" if applied_count > 0 else "이번 턴 적용된 자동무역 없음",
	}
	if applied_count <= 0:
		result["reason"] = "no_actionable_trade"
	_record_chancellor_auto_trade_result(result)
	return result


func _record_chancellor_auto_trade_result(result: Dictionary) -> void:
	var safe_turn := maxi(1, int(result.get("turn", _player_state.get("turn_number", 1))))
	result["turn"] = safe_turn
	_player_state["last_chancellor_auto_trade_result"] = result.duplicate(true)
	_player_state["last_chancellor_auto_trade_turn"] = safe_turn


func _get_player_owned_city_ids_for_chancellor_auto_trade() -> Array[String]:
	var result: Array[String] = []
	var owned_city_ids: Variant = _player_state.get("owned_city_ids", [])
	if not owned_city_ids is Array:
		return result
	for city_id_variant in owned_city_ids:
		var city_id := str(city_id_variant)
		if city_id.is_empty() or result.has(city_id):
			continue
		if _is_city_owned_by_player_mvp(city_id):
			result.append(city_id)
	return result


func _get_chancellor_auto_trade_resource_priority(policy_id: String, trade_type: String) -> Array[String]:
	var priority: Array[String] = []
	match _normalize_chancellor_policy_id(policy_id):
		"agriculture":
			priority = ["rice", "barley", "seafood", "salt", "gold", "wood", "iron", "horses", "silk"]
		"commerce":
			priority = ["gold", "silk", "salt", "seafood", "wood", "rice", "barley", "iron", "horses"]
		"trade":
			priority = ["seafood", "salt", "silk", "gold", "rice", "barley", "wood", "iron", "horses"]
		"military":
			priority = ["iron", "horses", "wood", "rice", "barley", "gold", "salt", "seafood", "silk"]
		_:
			priority = ["gold", "rice", "barley", "seafood", "wood", "iron", "horses", "salt", "silk"]
	if trade_type == "external":
		var external_priority: Array[String] = []
		for resource_id in priority:
			if resource_id != "gold":
				external_priority.append(resource_id)
		return external_priority
	return priority


func _get_chancellor_auto_trade_resource_cap(policy_id: String, trade_type: String, resource_id: String, chancellor_data: Dictionary) -> int:
	var cap := CHANCELLOR_AUTO_TRADE_INTERNAL_BASE_CAP if trade_type == "internal" else CHANCELLOR_AUTO_TRADE_EXTERNAL_BASE_CAP
	if _has_chancellor_auto_trade_cap_aptitude(chancellor_data):
		cap = CHANCELLOR_AUTO_TRADE_INTERNAL_APTITUDE_CAP if trade_type == "internal" else CHANCELLOR_AUTO_TRADE_EXTERNAL_APTITUDE_CAP
	if trade_type == "external" and _normalize_chancellor_policy_id(policy_id) == "trade":
		cap = CHANCELLOR_AUTO_TRADE_EXTERNAL_TRADE_POLICY_CAP
	if resource_id == "gold":
		cap = mini(cap, CHANCELLOR_AUTO_TRADE_GOLD_CAP)
	return cap


func _has_chancellor_auto_trade_cap_aptitude(chancellor_data: Dictionary) -> bool:
	var types := [
		str(chancellor_data.get("chancellor_primary_type", "")),
		str(chancellor_data.get("chancellor_secondary_type", "")),
	]
	for type_id in types:
		if ["diplomatic", "economic", "administrative"].has(type_id):
			return true
	return false


func _get_chancellor_auto_trade_target_min(resource_id: String) -> int:
	return maxi(0, int(CHANCELLOR_AUTO_TRADE_STORAGE_TARGETS.get(resource_id, 0)))


func _get_chancellor_auto_trade_surplus_buffer(resource_id: String) -> int:
	return CHANCELLOR_AUTO_TRADE_GOLD_BUFFER if resource_id == "gold" else CHANCELLOR_AUTO_TRADE_DEFAULT_BUFFER


func _apply_chancellor_internal_auto_trade(owned_city_ids: Array[String], policy_id: String, chancellor_data: Dictionary) -> Dictionary:
	var result := {"enabled": true, "applied": []}
	var applied: Array = []
	var total_moved := 0
	var priority := _get_chancellor_auto_trade_resource_priority(policy_id, "internal")
	for resource_id in priority:
		if total_moved >= CHANCELLOR_AUTO_TRADE_INTERNAL_TOTAL_CAP:
			break
		var target_min := _get_chancellor_auto_trade_target_min(resource_id)
		var buffer := _get_chancellor_auto_trade_surplus_buffer(resource_id)
		var target_demands := _get_chancellor_internal_auto_trade_target_demands(owned_city_ids, resource_id, target_min)
		for demand in target_demands:
			if total_moved >= CHANCELLOR_AUTO_TRADE_INTERNAL_TOTAL_CAP:
				break
			var target_city_id := str(demand.get("city_id", ""))
			var target_marker := _city_markers_by_id.get(target_city_id) as WorldMapCityMarker
			if target_marker == null:
				continue
			var connected_city_ids := _get_internal_trade_connected_player_city_ids(target_marker)
			if connected_city_ids.is_empty():
				continue
			var target_storage := _get_city_storage(target_city_id, _get_city_hud_entry(target_city_id))
			var deficit := target_min - _get_city_storage_amount(target_storage, resource_id)
			if deficit <= 0:
				continue
			var source_city_id := _select_chancellor_internal_auto_trade_source(connected_city_ids, resource_id, target_min, buffer)
			if source_city_id.is_empty():
				continue
			var source_storage := _get_city_storage(source_city_id, _get_city_hud_entry(source_city_id))
			var surplus := _get_city_storage_amount(source_storage, resource_id) - target_min - buffer
			var cap := _get_chancellor_auto_trade_resource_cap(policy_id, "internal", resource_id, chancellor_data)
			var remaining_turn_cap := CHANCELLOR_AUTO_TRADE_INTERNAL_TOTAL_CAP - total_moved
			var move_amount := mini(deficit, mini(surplus, mini(cap, remaining_turn_cap)))
			if move_amount <= 0:
				continue
			source_storage[resource_id] = _get_city_storage_amount(source_storage, resource_id) - move_amount
			target_storage[resource_id] = _get_city_storage_amount(target_storage, resource_id) + move_amount
			_set_city_storage(source_city_id, source_storage)
			_set_city_storage(target_city_id, target_storage)
			applied.append({
				"source_city_id": source_city_id,
				"target_city_id": target_city_id,
				"amounts": {resource_id: move_amount},
			})
			total_moved += move_amount
	result["applied"] = applied
	result["total_moved"] = total_moved
	return result


func _get_chancellor_internal_auto_trade_target_demands(owned_city_ids: Array[String], resource_id: String, target_min: int) -> Array:
	var demands: Array = []
	for city_id in owned_city_ids:
		var storage := _get_city_storage(city_id, _get_city_hud_entry(city_id))
		var deficit := target_min - _get_city_storage_amount(storage, resource_id)
		if deficit <= 0:
			continue
		demands.append({"city_id": city_id, "deficit": deficit})
	demands.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("deficit", 0)) > int(b.get("deficit", 0))
	)
	return demands


func _select_chancellor_internal_auto_trade_source(candidate_city_ids: Array[String], resource_id: String, target_min: int, buffer: int) -> String:
	var selected_source_city_id := ""
	var selected_surplus := 0
	for candidate_city_id in candidate_city_ids:
		var storage := _get_city_storage(candidate_city_id, _get_city_hud_entry(candidate_city_id))
		var surplus := _get_city_storage_amount(storage, resource_id) - target_min - buffer
		if surplus > selected_surplus:
			selected_surplus = surplus
			selected_source_city_id = candidate_city_id
	return selected_source_city_id


func _apply_chancellor_external_auto_trade(owned_city_ids: Array[String], policy_id: String, chancellor_data: Dictionary) -> Dictionary:
	var result := {"enabled": true, "applied": []}
	var applied: Array = []
	var priority := _get_chancellor_auto_trade_resource_priority(policy_id, "external")
	for source_city_id in owned_city_ids:
		var candidate_city_ids := _get_chancellor_external_tradeable_candidate_city_ids(source_city_id)
		if candidate_city_ids.is_empty():
			continue
		var target_city_id := candidate_city_ids[0]
		var efficiency := _get_trade_efficiency_for_cities(source_city_id, target_city_id)
		if efficiency <= 0.0:
			continue
		var source_storage := _get_city_storage(source_city_id, _get_city_hud_entry(source_city_id))
		var gold_amount := _get_city_storage_amount(source_storage, "gold")
		var applied_delta := _build_empty_chancellor_external_delta()
		if gold_amount < _get_chancellor_auto_trade_target_min("gold") or ["commerce", "trade"].has(_normalize_chancellor_policy_id(policy_id)):
			_apply_chancellor_external_export(source_storage, applied_delta, priority, policy_id, chancellor_data, efficiency)
		_apply_chancellor_external_import(source_storage, applied_delta, priority, policy_id, chancellor_data, efficiency)
		if _is_chancellor_external_delta_empty(applied_delta):
			continue
		_set_city_storage(source_city_id, source_storage)
		applied.append({
			"source_city_id": source_city_id,
			"target_city_id": target_city_id,
			"target_faction_id": _get_city_owner_faction_id_for_trade_display(target_city_id),
			"applied": applied_delta,
			"efficiency": efficiency,
			"market_turn": maxi(0, int(_player_state.get("trade_market_turn", 0))),
			"market_prices": _get_trade_market_price_snapshot_for_delta(applied_delta),
		})
	result["applied"] = applied
	return result


func _get_chancellor_external_tradeable_candidate_city_ids(source_city_id: String) -> Array[String]:
	var result: Array[String] = []
	var source_faction_id := _get_city_owner_faction_id_for_trade_display(source_city_id)
	for candidate_city_id in _get_external_trade_candidate_city_ids(source_city_id):
		var target_faction_id := _get_city_owner_faction_id_for_trade_display(candidate_city_id)
		if _can_trade_between_factions(source_faction_id, target_faction_id):
			result.append(candidate_city_id)
	result.sort_custom(func(a: String, b: String) -> bool:
		return _get_trade_efficiency_for_cities(source_city_id, a) > _get_trade_efficiency_for_cities(source_city_id, b)
	)
	return result


func _build_empty_chancellor_external_delta() -> Dictionary:
	var delta := {"gold": 0}
	for resource_id in MANUAL_TRADE_RESOURCE_ORDER:
		delta[resource_id] = 0
	return delta


func _is_chancellor_external_delta_empty(delta: Dictionary) -> bool:
	for resource_id in ["gold"] + MANUAL_TRADE_RESOURCE_ORDER:
		if int(delta.get(resource_id, 0)) != 0:
			return false
	return true


func _apply_chancellor_external_export(source_storage: Dictionary, applied_delta: Dictionary, priority: Array[String], policy_id: String, chancellor_data: Dictionary, efficiency: float) -> void:
	if efficiency <= 0.0:
		return
	for resource_id in priority:
		var target_min := _get_chancellor_auto_trade_target_min(resource_id)
		var surplus := _get_city_storage_amount(source_storage, resource_id) - target_min - _get_chancellor_auto_trade_surplus_buffer(resource_id)
		if surplus <= 0:
			continue
		var cap := _get_chancellor_auto_trade_resource_cap(policy_id, "external", resource_id, chancellor_data)
		var amount := mini(surplus, cap)
		if amount <= 0:
			continue
		var gold_gain := mini(_calculate_trade_export_gain(resource_id, amount, efficiency), CHANCELLOR_AUTO_TRADE_GOLD_CAP)
		if gold_gain <= 0:
			continue
		source_storage[resource_id] = _get_city_storage_amount(source_storage, resource_id) - amount
		source_storage["gold"] = _get_city_storage_amount(source_storage, "gold") + gold_gain
		applied_delta[resource_id] = int(applied_delta.get(resource_id, 0)) - amount
		applied_delta["gold"] = int(applied_delta.get("gold", 0)) + gold_gain
		return


func _apply_chancellor_external_import(source_storage: Dictionary, applied_delta: Dictionary, priority: Array[String], policy_id: String, chancellor_data: Dictionary, efficiency: float) -> void:
	if efficiency <= 0.0:
		return
	for resource_id in priority:
		var target_min := _get_chancellor_auto_trade_target_min(resource_id)
		var deficit := target_min - _get_city_storage_amount(source_storage, resource_id)
		if deficit <= 0:
			continue
		var cap := _get_chancellor_auto_trade_resource_cap(policy_id, "external", resource_id, chancellor_data)
		var amount := mini(deficit, cap)
		while amount > 0 and _calculate_trade_import_cost(resource_id, amount, efficiency) > _get_city_storage_amount(source_storage, "gold"):
			amount -= 1
		if amount <= 0:
			continue
		var gold_cost := _calculate_trade_import_cost(resource_id, amount, efficiency)
		if gold_cost <= 0:
			continue
		source_storage["gold"] = _get_city_storage_amount(source_storage, "gold") - gold_cost
		source_storage[resource_id] = _get_city_storage_amount(source_storage, resource_id) + amount
		applied_delta["gold"] = int(applied_delta.get("gold", 0)) - gold_cost
		applied_delta[resource_id] = int(applied_delta.get(resource_id, 0)) + amount
		return


func _get_default_trade_control_modes() -> Dictionary:
	return {
		CITY_DETAIL_TAB_INTERNAL_TRADE: TRADE_CONTROL_MODE_CHANCELLOR,
		CITY_DETAIL_TAB_EXTERNAL_TRADE: TRADE_CONTROL_MODE_CHANCELLOR,
	}


func _normalize_trade_control_modes(raw_modes: Variant) -> Dictionary:
	var modes := _get_default_trade_control_modes()
	if not raw_modes is Dictionary:
		return modes
	var raw_dictionary := raw_modes as Dictionary
	for tab_id in [CITY_DETAIL_TAB_INTERNAL_TRADE, CITY_DETAIL_TAB_EXTERNAL_TRADE]:
		var mode := str(raw_dictionary.get(tab_id, modes.get(tab_id, TRADE_CONTROL_MODE_CHANCELLOR)))
		if not [TRADE_CONTROL_MODE_CHANCELLOR, TRADE_CONTROL_MODE_MANUAL].has(mode):
			mode = TRADE_CONTROL_MODE_CHANCELLOR
		modes[tab_id] = mode
	return modes


func _normalize_manual_trade_orders(raw_orders: Variant) -> Dictionary:
	var normalized := {}
	if not raw_orders is Dictionary:
		return normalized
	for source_city_id_variant in (raw_orders as Dictionary).keys():
		var source_city_id := str(source_city_id_variant)
		var raw_order: Variant = (raw_orders as Dictionary).get(source_city_id_variant, {})
		var order := _normalize_manual_trade_order_payload(raw_order, source_city_id)
		if order.is_empty():
			print("[TRADE_SAVE_LOAD] dropped invalid manual trade order for source=%s" % source_city_id)
			continue
		normalized[str(order.get("source_city_id", source_city_id))] = order
	return normalized


func _normalize_manual_trade_order_payload(raw_order: Variant, source_city_id: String = "") -> Dictionary:
	if not raw_order is Dictionary:
		return {}
	var raw_dictionary := raw_order as Dictionary
	var resolved_source_city_id := str(raw_dictionary.get("source_city_id", source_city_id))
	var target_city_id := str(raw_dictionary.get("target_city_id", ""))
	if resolved_source_city_id.is_empty() or target_city_id.is_empty():
		return {}
	if not _has_worldmap_city_for_trade_persistence(resolved_source_city_id) or not _has_worldmap_city_for_trade_persistence(target_city_id):
		return {}
	if not _is_city_owned_by_player_mvp(resolved_source_city_id):
		return {}
	var candidate_city_ids := _get_external_trade_candidate_city_ids(resolved_source_city_id)
	if not candidate_city_ids.is_empty() and not candidate_city_ids.has(target_city_id):
		return {}
	var orders := _normalize_manual_trade_order_items(raw_dictionary.get("orders", {}))
	if orders.is_empty():
		return {}
	var preview := _build_external_manual_trade_execution_preview({
		"source_city_id": resolved_source_city_id,
		"target_city_id": target_city_id,
		"orders": orders,
	})
	return {
		"source_city_id": resolved_source_city_id,
		"target_city_id": target_city_id,
		"trade_type": "external",
		"mode": TRADE_CONTROL_MODE_MANUAL,
		"orders": orders,
		"preview": preview,
		"efficiency": float(preview.get("efficiency", 0.0)),
	}


func _normalize_manual_trade_order_items(raw_items: Variant) -> Dictionary:
	var normalized := {}
	if not raw_items is Dictionary:
		return normalized
	for resource_id in MANUAL_TRADE_RESOURCE_ORDER:
		var raw_item: Variant = (raw_items as Dictionary).get(resource_id, {})
		if not raw_item is Dictionary:
			continue
		var action := str((raw_item as Dictionary).get("action", MANUAL_TRADE_ACTION_NONE))
		var amount := maxi(0, int((raw_item as Dictionary).get("amount", 0)))
		if action == MANUAL_TRADE_ACTION_NONE or amount <= 0:
			continue
		if not [MANUAL_TRADE_ACTION_IMPORT, MANUAL_TRADE_ACTION_EXPORT].has(action):
			continue
		normalized[resource_id] = {"action": action, "amount": amount}
	return normalized


func _normalize_trade_result_payload(raw_result: Variant) -> Dictionary:
	if not raw_result is Dictionary:
		return {}
	var normalized := (raw_result as Dictionary).duplicate(true)
	for key in ["applied", "preview", "amounts"]:
		if normalized.has(key):
			if normalized.get(key) is Dictionary:
				normalized[key] = _normalize_trade_delta_payload(normalized.get(key))
			else:
				normalized.erase(key)
	return normalized


func _normalize_trade_delta_payload(raw_delta: Variant) -> Dictionary:
	var normalized := {}
	if not raw_delta is Dictionary:
		return normalized
	for resource_id in RESOURCE_DISPLAY_ORDER:
		var resource_key := str(resource_id)
		if (raw_delta as Dictionary).has(resource_key):
			normalized[resource_key] = int((raw_delta as Dictionary).get(resource_key, 0))
	return normalized


func _normalize_chancellor_auto_trade_result_payload(raw_result: Variant) -> Dictionary:
	if not raw_result is Dictionary:
		return {}
	var normalized := (raw_result as Dictionary).duplicate(true)
	normalized["turn"] = maxi(0, int(normalized.get("turn", 0)))
	if normalized.has("internal") and normalized.get("internal") is Dictionary:
		normalized["internal"] = _normalize_chancellor_auto_trade_section_payload(normalized.get("internal"), true)
	if normalized.has("external") and normalized.get("external") is Dictionary:
		normalized["external"] = _normalize_chancellor_auto_trade_section_payload(normalized.get("external"), false)
	return normalized


func _normalize_chancellor_auto_trade_section_payload(raw_section: Variant, is_internal_section: bool) -> Dictionary:
	var section := {"enabled": false, "applied": []}
	if not raw_section is Dictionary:
		return section
	var raw_dictionary := raw_section as Dictionary
	section["enabled"] = bool(raw_dictionary.get("enabled", false))
	var raw_applied: Variant = raw_dictionary.get("applied", [])
	var applied: Array = []
	if raw_applied is Array:
		for item_variant in raw_applied:
			if not item_variant is Dictionary:
				continue
			var item := (item_variant as Dictionary).duplicate(true)
			if is_internal_section:
				item["amounts"] = _normalize_trade_delta_payload(item.get("amounts", {}))
			else:
				item["applied"] = _normalize_trade_delta_payload(item.get("applied", {}))
				if item.has("efficiency"):
					item["efficiency"] = clampf(float(item.get("efficiency", 0.0)), 0.0, TRADE_EFFICIENCY_MAX)
			applied.append(item)
	section["applied"] = applied
	if raw_dictionary.has("total_moved"):
		section["total_moved"] = maxi(0, int(raw_dictionary.get("total_moved", 0)))
	return section


func _has_worldmap_city_for_trade_persistence(city_id: String) -> bool:
	if city_id.is_empty():
		return false
	return CITY_HUD_DATA.has(city_id) or not _get_city_hud_entry(city_id).is_empty()


func _normalize_city_intel_registry(raw_intel: Variant) -> Dictionary:
	var result := {}
	if not raw_intel is Dictionary:
		return result
	var allowed_fields := ["troops_estimated", "troops", "resources", "publicSupport", "loyalty", "governor", "tech"]
	for city_id_variant in (raw_intel as Dictionary).keys():
		var city_id := str(city_id_variant)
		if not _has_worldmap_city_for_trade_persistence(city_id):
			continue
		var raw_entry: Variant = (raw_intel as Dictionary).get(city_id, {})
		if not raw_entry is Dictionary:
			continue
		var entry := raw_entry as Dictionary
		var fields: Array = []
		var raw_fields: Variant = entry.get("fields", [])
		if raw_fields is Array:
			for field_variant in raw_fields:
				var field := str(field_variant)
				if allowed_fields.has(field) and not fields.has(field):
					fields.append(field)
		var payload: Dictionary = {}
		var raw_payload: Variant = entry.get("payload", entry.get("info", {}))
		if raw_payload is Dictionary:
			payload = (raw_payload as Dictionary).duplicate(true)
		result[city_id] = {
			"turn": maxi(0, int(entry.get("turn", 0))),
			"fields": fields,
			"estimated": bool(entry.get("estimated", fields.has("troops_estimated"))),
			"payload": payload,
		}
	return result


func _record_city_intel_from_spy_result(spy_result: Dictionary) -> void:
	if not bool(spy_result.get("success", false)):
		return
	var target_city_id := str(spy_result.get("target_city_id", ""))
	if not _has_worldmap_city_for_trade_persistence(target_city_id):
		return
	var raw_payload: Variant = spy_result.get("payload", spy_result.get("info", {}))
	if not raw_payload is Dictionary or (raw_payload as Dictionary).is_empty():
		return
	var intel_registry := _normalize_city_intel_registry(_player_state.get("city_intel", {}))
	var fields: Array = []
	var raw_fields: Variant = spy_result.get("fields", [])
	if raw_fields is Array:
		fields = (raw_fields as Array).duplicate()
	intel_registry[target_city_id] = {
		"turn": maxi(1, int(spy_result.get("turn", _player_state.get("turn_number", 1)))),
		"fields": fields,
		"estimated": bool(spy_result.get("estimated", false)),
		"payload": (raw_payload as Dictionary).duplicate(true),
	}
	_player_state["city_intel"] = _normalize_city_intel_registry(intel_registry)


func _sync_trade_persistence_to_player_state() -> void:
	_ensure_trade_market_for_current_turn()
	_trade_control_modes = _normalize_trade_control_modes(_trade_control_modes)
	_manual_trade_orders = _normalize_manual_trade_orders(_manual_trade_orders)
	_player_state["trade_control_modes"] = _trade_control_modes.duplicate(true)
	_player_state["manual_trade_orders"] = _manual_trade_orders.duplicate(true)
	_player_state["last_external_manual_trade_execution_result"] = _normalize_trade_result_payload(_player_state.get("last_external_manual_trade_execution_result", {}))
	_player_state["last_internal_trade_transfer_result"] = _normalize_trade_result_payload(_player_state.get("last_internal_trade_transfer_result", {}))
	_player_state["last_chancellor_auto_trade_result"] = _normalize_chancellor_auto_trade_result_payload(_player_state.get("last_chancellor_auto_trade_result", {}))
	_player_state["last_chancellor_auto_trade_turn"] = maxi(0, int(_player_state.get("last_chancellor_auto_trade_turn", 0)))
	_player_state["city_intel"] = _normalize_city_intel_registry(_player_state.get("city_intel", {}))
	_ensure_faction_chancellors_seeded()


func _restore_trade_persistence_from_player_state() -> void:
	_trade_control_modes = _normalize_trade_control_modes(_player_state.get("trade_control_modes", {}))
	_player_state["last_trade_market_result"] = _normalize_trade_market_result(_player_state.get("last_trade_market_result", {}))
	_sync_trade_market_mirror_from_result(_player_state["last_trade_market_result"])
	_ensure_trade_market_for_current_turn()
	_manual_trade_orders = _normalize_manual_trade_orders(_player_state.get("manual_trade_orders", {}))
	_player_state["trade_control_modes"] = _trade_control_modes.duplicate(true)
	_player_state["manual_trade_orders"] = _manual_trade_orders.duplicate(true)
	_player_state["last_external_manual_trade_execution_result"] = _normalize_trade_result_payload(_player_state.get("last_external_manual_trade_execution_result", {}))
	_player_state["last_internal_trade_transfer_result"] = _normalize_trade_result_payload(_player_state.get("last_internal_trade_transfer_result", {}))
	_player_state["last_chancellor_auto_trade_result"] = _normalize_chancellor_auto_trade_result_payload(_player_state.get("last_chancellor_auto_trade_result", {}))
	_player_state["last_chancellor_auto_trade_turn"] = maxi(0, int(_player_state.get("last_chancellor_auto_trade_turn", 0)))
	_player_state["city_intel"] = _normalize_city_intel_registry(_player_state.get("city_intel", {}))
	_ensure_faction_chancellors_seeded()


func _ensure_internal_trade_transfer_panel() -> void:
	if _internal_trade_transfer_panel != null:
		return
	var worldmap_ui := get_node_or_null("WorldMapUI") as CanvasLayer
	if worldmap_ui == null:
		return

	_internal_trade_transfer_panel = PanelContainer.new()
	_internal_trade_transfer_panel.name = "InternalTradeTransferPanel"
	_internal_trade_transfer_panel.visible = false
	_internal_trade_transfer_panel.z_index = 131
	_internal_trade_transfer_panel.anchor_left = 0.5
	_internal_trade_transfer_panel.anchor_right = 0.5
	_internal_trade_transfer_panel.anchor_top = 0.5
	_internal_trade_transfer_panel.anchor_bottom = 0.5
	_internal_trade_transfer_panel.offset_left = -300.0
	_internal_trade_transfer_panel.offset_right = 300.0
	_internal_trade_transfer_panel.offset_top = -265.0
	_internal_trade_transfer_panel.offset_bottom = 265.0
	_internal_trade_transfer_panel.custom_minimum_size = Vector2(600.0, 530.0)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.045, 0.05, 0.065, 0.96)
	panel_style.border_color = Color(0.78, 0.58, 0.28, 0.95)
	panel_style.set_border_width_all(1)
	panel_style.set_corner_radius_all(6)
	panel_style.content_margin_left = 12.0
	panel_style.content_margin_top = 10.0
	panel_style.content_margin_right = 12.0
	panel_style.content_margin_bottom = 10.0
	_internal_trade_transfer_panel.add_theme_stylebox_override("panel", panel_style)
	worldmap_ui.add_child(_internal_trade_transfer_panel)

	var content := VBoxContainer.new()
	content.name = "InternalTradeTransferPanelContent"
	content.add_theme_constant_override("separation", 6)
	_internal_trade_transfer_panel.add_child(content)

	var title_label := Label.new()
	title_label.name = "InternalTradeTransferTitleLabel"
	title_label.text = "자국무역 수동 이송"
	title_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.68, 1.0))
	content.add_child(title_label)

	_internal_trade_source_label = Label.new()
	_internal_trade_source_label.name = "InternalTradeSourceLabel"
	_internal_trade_source_label.add_theme_color_override("font_color", Color(0.88, 0.90, 0.86, 1.0))
	content.add_child(_internal_trade_source_label)

	var target_row := HBoxContainer.new()
	target_row.name = "InternalTradeTargetRow"
	target_row.add_theme_constant_override("separation", 8)
	content.add_child(target_row)
	var target_label := Label.new()
	target_label.text = "도착 성:"
	target_label.custom_minimum_size = Vector2(74.0, 0.0)
	target_row.add_child(target_label)
	_internal_trade_target_option = OptionButton.new()
	_internal_trade_target_option.name = "InternalTradeTargetOption"
	_internal_trade_target_option.custom_minimum_size = Vector2(180.0, 28.0)
	_internal_trade_target_option.item_selected.connect(_on_internal_trade_transfer_target_selected)
	target_row.add_child(_internal_trade_target_option)

	var header_row := GridContainer.new()
	header_row.name = "InternalTradeResourceHeader"
	header_row.columns = 3
	content.add_child(header_row)
	for header_text in ["자원", "보유량", "이송량"]:
		var header := Label.new()
		header.text = header_text
		header.custom_minimum_size = Vector2(150.0, 0.0)
		header.add_theme_color_override("font_color", Color(0.96, 0.74, 0.34, 1.0))
		header_row.add_child(header)

	var row_grid := GridContainer.new()
	row_grid.name = "InternalTradeResourceRows"
	row_grid.columns = 3
	content.add_child(row_grid)
	for resource_id in INTERNAL_TRADE_TRANSFER_RESOURCE_ORDER:
		var internal_trade_resource_name_label := Label.new()
		internal_trade_resource_name_label.text = str(RESOURCE_LABELS.get(resource_id, resource_id))
		internal_trade_resource_name_label.custom_minimum_size = Vector2(150.0, 26.0)
		row_grid.add_child(internal_trade_resource_name_label)

		var owned_label := Label.new()
		owned_label.name = "InternalTradeOwned_%s" % resource_id
		owned_label.custom_minimum_size = Vector2(120.0, 26.0)
		owned_label.add_theme_color_override("font_color", Color(0.72, 0.78, 0.84, 1.0))
		row_grid.add_child(owned_label)

		var amount_spinbox := SpinBox.new()
		amount_spinbox.name = "InternalTradeAmount_%s" % resource_id
		amount_spinbox.min_value = 0.0
		amount_spinbox.max_value = 0.0
		amount_spinbox.step = 1.0
		amount_spinbox.value = 0.0
		amount_spinbox.custom_minimum_size = Vector2(90.0, 26.0)
		amount_spinbox.value_changed.connect(_on_internal_trade_transfer_amount_changed.bind(resource_id))
		_internal_trade_amount_spinboxes[resource_id] = amount_spinbox
		row_grid.add_child(amount_spinbox)

	var preview_title := Label.new()
	preview_title.text = "예상 결과"
	preview_title.add_theme_color_override("font_color", Color(1.0, 0.9, 0.68, 1.0))
	content.add_child(preview_title)

	_internal_trade_preview_label = Label.new()
	_internal_trade_preview_label.name = "InternalTradePreviewLabel"
	_internal_trade_preview_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_internal_trade_preview_label.add_theme_color_override("font_color", Color(0.88, 0.90, 0.86, 1.0))
	content.add_child(_internal_trade_preview_label)

	_internal_trade_status_label = Label.new()
	_internal_trade_status_label.name = "InternalTradeStatusLabel"
	_internal_trade_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_internal_trade_status_label.add_theme_color_override("font_color", Color(0.72, 0.78, 0.84, 1.0))
	content.add_child(_internal_trade_status_label)

	var button_row := HBoxContainer.new()
	button_row.name = "InternalTradeButtonRow"
	button_row.add_theme_constant_override("separation", 8)
	content.add_child(button_row)

	var confirm_button := Button.new()
	confirm_button.name = "InternalTradeConfirmButton"
	confirm_button.text = "이송 적용"
	confirm_button.pressed.connect(_on_internal_trade_transfer_confirm_pressed)
	button_row.add_child(confirm_button)

	var cancel_button := Button.new()
	cancel_button.name = "InternalTradeCancelButton"
	cancel_button.text = "취소"
	cancel_button.pressed.connect(_on_internal_trade_transfer_cancel_pressed)
	button_row.add_child(cancel_button)


func _open_internal_trade_transfer_panel(source_city_id: String = "") -> void:
	_ensure_internal_trade_transfer_panel()
	if _internal_trade_transfer_panel == null:
		return
	if source_city_id.is_empty() and selected_city_marker != null:
		source_city_id = selected_city_marker.city_id
	if source_city_id.is_empty() or not _is_city_owned_by_player_mvp(source_city_id):
		return
	var source_marker := _city_markers_by_id.get(source_city_id) as WorldMapCityMarker
	var candidate_city_ids := _get_internal_trade_connected_player_city_ids(source_marker)
	if candidate_city_ids.is_empty():
		if _trade_control_hint_label != null:
			_trade_control_hint_label.text = "연결 가능한 아군 성이 없어 수동 이송할 수 없습니다."
		return
	_internal_trade_current_source_city_id = source_city_id
	_populate_internal_trade_transfer_panel(source_city_id, candidate_city_ids)
	_internal_trade_transfer_panel.visible = true
	_internal_trade_transfer_panel.move_to_front()


func _close_internal_trade_transfer_panel() -> void:
	if _internal_trade_transfer_panel != null:
		_internal_trade_transfer_panel.visible = false


func _populate_internal_trade_transfer_panel(source_city_id: String, candidate_city_ids: Array[String]) -> void:
	if _internal_trade_source_label != null:
		_internal_trade_source_label.text = "출발 성: %s" % _format_city_name_by_id(source_city_id, source_city_id)
	if _internal_trade_target_option != null:
		_internal_trade_target_option.clear()
		for candidate_city_id in candidate_city_ids:
			var index := _internal_trade_target_option.item_count
			_internal_trade_target_option.add_item(_format_city_name_by_id(candidate_city_id, candidate_city_id))
			_internal_trade_target_option.set_item_metadata(index, candidate_city_id)
	var source_storage := _get_city_storage(source_city_id, _get_city_hud_entry(source_city_id))
	for resource_id in INTERNAL_TRADE_TRANSFER_RESOURCE_ORDER:
		var amount_spinbox := _internal_trade_amount_spinboxes.get(resource_id) as SpinBox
		if amount_spinbox == null:
			continue
		var owned_amount := _get_city_storage_amount(source_storage, resource_id)
		amount_spinbox.max_value = float(owned_amount)
		amount_spinbox.value = 0.0
		var owned_label := amount_spinbox.get_parent().get_node_or_null("InternalTradeOwned_%s" % resource_id) as Label
		if owned_label != null:
			owned_label.text = "보유 %d" % owned_amount
	if _internal_trade_status_label != null:
		_internal_trade_status_label.text = "연결된 아군 성으로만 이송할 수 있습니다."
	_refresh_internal_trade_transfer_preview()


func _on_internal_trade_transfer_target_selected(_index: int) -> void:
	_refresh_internal_trade_transfer_preview()


func _on_internal_trade_transfer_amount_changed(_value: float, _resource_id: String) -> void:
	_refresh_internal_trade_transfer_preview()


func _refresh_internal_trade_transfer_preview() -> void:
	if _internal_trade_preview_label == null:
		return
	var source_city_id := _internal_trade_current_source_city_id
	var target_city_id := _get_selected_internal_trade_target_city_id()
	var amounts := _build_internal_trade_transfer_amounts()
	if amounts.is_empty() or source_city_id.is_empty() or target_city_id.is_empty():
		_internal_trade_preview_label.text = "이송할 자원이 없습니다."
		return
	_internal_trade_preview_label.text = "%s: %s\n%s: %s" % [
		_format_city_name_by_id(source_city_id, source_city_id),
		_format_internal_trade_signed_transfer_amounts(amounts, -1),
		_format_city_name_by_id(target_city_id, target_city_id),
		_format_internal_trade_signed_transfer_amounts(amounts, 1),
	]


func _build_internal_trade_transfer_amounts() -> Dictionary:
	var amounts := {}
	for resource_id in INTERNAL_TRADE_TRANSFER_RESOURCE_ORDER:
		var amount_spinbox := _internal_trade_amount_spinboxes.get(resource_id) as SpinBox
		if amount_spinbox == null:
			continue
		var amount := maxi(0, int(amount_spinbox.value))
		if amount <= 0:
			continue
		amounts[resource_id] = amount
	return amounts


func _get_selected_internal_trade_target_city_id() -> String:
	if _internal_trade_target_option == null:
		return ""
	var selected_index := _internal_trade_target_option.selected
	if selected_index < 0:
		return ""
	return str(_internal_trade_target_option.get_item_metadata(selected_index))


func _on_internal_trade_transfer_confirm_pressed() -> void:
	var source_city_id := _internal_trade_current_source_city_id
	var target_city_id := _get_selected_internal_trade_target_city_id()
	var amounts := _build_internal_trade_transfer_amounts()
	var validation := _validate_internal_trade_transfer(source_city_id, target_city_id, amounts)
	if not bool(validation.get("ok", false)):
		if _internal_trade_status_label != null:
			_internal_trade_status_label.text = str(validation.get("reason", "이송할 수 없습니다."))
		return
	var payload := _apply_internal_trade_transfer(source_city_id, target_city_id, amounts)
	print("[WorldMap] Internal trade transfer applied: %s" % str(payload))
	_close_internal_trade_transfer_panel()
	_refresh_city_hud_data_bindings()
	_refresh_left_world_status_panel()
	_refresh_unified_panel_content()
	_queue_unified_city_panel_resize()


func _on_internal_trade_transfer_cancel_pressed() -> void:
	_close_internal_trade_transfer_panel()


func _validate_internal_trade_transfer(source_city_id: String, target_city_id: String, amounts: Dictionary) -> Dictionary:
	if source_city_id.is_empty():
		return {"ok": false, "reason": "출발 성을 확인할 수 없습니다."}
	if target_city_id.is_empty():
		return {"ok": false, "reason": "도착 성을 선택하십시오."}
	if source_city_id == target_city_id:
		return {"ok": false, "reason": "출발 성과 도착 성은 달라야 합니다."}
	if not _is_city_owned_by_player_mvp(source_city_id) or not _is_city_owned_by_player_mvp(target_city_id):
		return {"ok": false, "reason": "자국 성끼리만 이송할 수 있습니다."}
	var source_marker := _city_markers_by_id.get(source_city_id) as WorldMapCityMarker
	if not _get_internal_trade_connected_player_city_ids(source_marker).has(target_city_id):
		return {"ok": false, "reason": "연결된 아군 성으로만 이송할 수 있습니다."}
	if amounts.is_empty():
		return {"ok": false, "reason": "이송할 자원을 1개 이상 입력하십시오."}
	var source_storage := _get_city_storage(source_city_id, _get_city_hud_entry(source_city_id))
	for resource_id_variant in amounts.keys():
		var resource_id := str(resource_id_variant)
		if not INTERNAL_TRADE_TRANSFER_RESOURCE_ORDER.has(resource_id):
			return {"ok": false, "reason": "허용되지 않은 자원입니다."}
		var amount := int(amounts.get(resource_id, 0))
		if amount < 0:
			return {"ok": false, "reason": "이송 수량은 0 이상이어야 합니다."}
		if amount > _get_city_storage_amount(source_storage, resource_id):
			return {"ok": false, "reason": "보유량을 초과할 수 없습니다."}
	return {"ok": true}


func _apply_internal_trade_transfer(source_city_id: String, target_city_id: String, amounts: Dictionary) -> Dictionary:
	var source_storage := _get_city_storage(source_city_id, _get_city_hud_entry(source_city_id))
	var target_storage := _get_city_storage(target_city_id, _get_city_hud_entry(target_city_id))
	for resource_id_variant in amounts.keys():
		var resource_id := str(resource_id_variant)
		var amount := maxi(0, int(amounts.get(resource_id, 0)))
		if amount <= 0:
			continue
		source_storage[resource_id] = maxi(0, int(source_storage.get(resource_id, 0)) - amount)
		target_storage[resource_id] = maxi(0, int(target_storage.get(resource_id, 0)) + amount)
	_set_city_storage(source_city_id, source_storage)
	_set_city_storage(target_city_id, target_storage)
	var payload := {
		"source_city_id": source_city_id,
		"target_city_id": target_city_id,
		"trade_type": "internal",
		"mode": "manual_transfer",
		"amounts": amounts.duplicate(true),
		"message": "수동 이송 완료",
	}
	_player_state["last_internal_trade_transfer_result"] = payload.duplicate(true)
	return payload


func _set_city_storage(city_id: String, storage: Dictionary) -> void:
	if city_id.is_empty():
		return
	var mutable_city_state := _get_mutable_city_runtime_state(city_id)
	if mutable_city_state.is_empty():
		return
	mutable_city_state["storage"] = _ensure_city_storage_keys(storage)
	_city_runtime_states[city_id] = mutable_city_state


func _format_internal_trade_signed_transfer_amounts(amounts: Dictionary, transfer_multiplier: int) -> String:
	var parts: Array[String] = []
	for resource_id in INTERNAL_TRADE_TRANSFER_RESOURCE_ORDER:
		var amount := int(amounts.get(resource_id, 0))
		if amount <= 0:
			continue
		parts.append("%s %s" % [
			str(RESOURCE_LABELS.get(resource_id, resource_id)),
			_format_signed_int(amount * transfer_multiplier),
		])
	if parts.is_empty():
		return "변화 없음"
	return " / ".join(parts)


func _format_internal_trade_transfer_amounts(amounts: Dictionary) -> String:
	var parts: Array[String] = []
	for resource_id in INTERNAL_TRADE_TRANSFER_RESOURCE_ORDER:
		var amount := int(amounts.get(resource_id, 0))
		if amount <= 0:
			continue
		parts.append("%s %d" % [str(RESOURCE_LABELS.get(resource_id, resource_id)), amount])
	if parts.is_empty():
		return "없음"
	return " / ".join(parts)


func _format_star_rating(value: int, max_value: int = 5) -> String:
	var safe_max := maxi(1, max_value)
	var filled := clampi(value, 0, safe_max)
	if filled <= 0:
		return "-"
	var stars := ""
	for _index in range(filled):
		stars += "★"
	return stars


func _show_unified_diplomacy_spy_content() -> void:
	_refresh_unified_panel_chrome()
	_set_city_detail_body_labels_visible(true)
	_apply_city_detail_default_text_tone()
	var current_selected_city_id := ""
	if selected_city_marker != null:
		current_selected_city_id = selected_city_marker.city_id
	city_detail_name_label.text = _get_diplomacy_spy_tab_label(_selected_diplomacy_spy_tab)
	city_detail_type_label.text = _format_diplomacy_spy_target_city_display(selected_city_marker)
	if _selected_diplomacy_spy_tab == DIPLOMACY_SPY_TAB_SPY:
		_refresh_diplomacy_action_card(null)
		_refresh_spy_action_card(selected_city_marker)
		city_detail_region_owner_label.text = _format_spy_visibility_summary_for_ui(selected_city_marker)
		city_detail_resource_label.text = _format_spy_known_info_summary_for_ui(selected_city_marker)
		city_detail_security_label.text = _format_spy_action_candidates_for_ui(selected_city_marker)
		city_detail_military_label.text = _format_recent_spy_result_for_ui(current_selected_city_id)
		city_detail_commerce_label.text = _format_spy_action_policy_display_for_ui(selected_city_marker)
		city_detail_rating_label.text = ""
		city_detail_hint_label.text = "선택 도시의 정보 수준, 공개 정보, 첩보 행동을 확인합니다."
	else:
		_refresh_spy_action_card(null)
		city_detail_region_owner_label.text = _format_diplomacy_owner_display(selected_city_marker)
		city_detail_resource_label.text = _format_diplomacy_relation_summary_for_ui(selected_city_marker)
		city_detail_security_label.text = _format_diplomacy_trade_status_for_ui(selected_city_marker)
		city_detail_military_label.text = _format_diplomacy_action_candidates_for_ui(selected_city_marker)
		city_detail_commerce_label.text = _format_diplomacy_policy_display_for_ui(selected_city_marker)
		city_detail_rating_label.text = ""
		city_detail_hint_label.text = "선택 도시 소유 세력과 PLAYER의 관계, 교역, 행동 후보를 확인합니다."
		_refresh_diplomacy_action_card(selected_city_marker)
	city_detail_domestic_button_placeholder.text = ""
	city_detail_domestic_button_placeholder.visible = false
	city_detail_status_label.text = ""
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


func _format_diplomacy_spy_target_city_display(city_marker: WorldMapCityMarker) -> String:
	if city_marker == null:
		return "선택 도시\n미선택"
	var owner_id := _get_city_owner_faction_id_for_trade_display(city_marker.city_id)
	var owner_label := _format_faction_label(owner_id)
	if owner_id.is_empty():
		owner_label = "세력 미확인"
	return "선택 도시\n%s · %s" % [city_marker.display_name, owner_label]


func _format_diplomacy_owner_display(city_marker: WorldMapCityMarker) -> String:
	if city_marker == null:
		return "소유 세력\n세력 미확인"
	var owner_id := _get_city_owner_faction_id_for_trade_display(city_marker.city_id)
	if owner_id.is_empty():
		return "소유 세력\n세력 미확인"
	return "소유 세력\n%s" % _format_faction_label(owner_id)


func _format_diplomacy_relation_summary_for_ui(city_marker: WorldMapCityMarker) -> String:
	if city_marker == null:
		return "관계 상태\n관계 미확인"
	var owner_id := _get_city_owner_faction_id_for_trade_display(city_marker.city_id)
	if owner_id.is_empty():
		return "관계 상태\n관계 미확인"
	if owner_id == PLAYER_FACTION_ID:
		return "관계 상태\n자국 도시"
	var status := _get_faction_relation_status(PLAYER_FACTION_ID, owner_id)
	var score := _get_faction_relation_score(PLAYER_FACTION_ID, owner_id)
	return "관계 상태\n%s · 관계 점수 %d" % [
		_format_diplomacy_relation_status_for_ui(status),
		score,
	]


func _format_diplomacy_relation_status_for_ui(status: String) -> String:
	match status:
		"allied":
			return "동맹"
		"neutral":
			return "중립"
		"hostile":
			return "적대"
		"suspended":
			return "교역 중단"
		_:
			return "관계 미확인"


func _format_diplomacy_trade_status_for_ui(city_marker: WorldMapCityMarker) -> String:
	if city_marker == null:
		return "교역 상태\n관계 미확인"
	var owner_id := _get_city_owner_faction_id_for_trade_display(city_marker.city_id)
	if owner_id.is_empty():
		return "교역 상태\n관계 미확인"
	if owner_id == PLAYER_FACTION_ID:
		return "교역 상태\n자국 관리 대상"
	var trade_status := "교역 제한"
	if _can_trade_between_factions(PLAYER_FACTION_ID, owner_id):
		trade_status = "교역 가능"
	return "교역 상태\n%s" % trade_status


func _format_diplomacy_action_candidates_for_ui(city_marker: WorldMapCityMarker) -> String:
	if city_marker == null:
		return "외교 행동\n도시를 선택하면 외교 후보가 표시됩니다."
	var owner_id := _get_city_owner_faction_id_for_trade_display(city_marker.city_id)
	if owner_id.is_empty():
		return "외교 행동\n소유 세력 확인이 필요합니다."
	if owner_id == PLAYER_FACTION_ID:
		return "외교 행동\n자국 도시는 외교 대상이 아닙니다."
	var status := _get_faction_relation_status(PLAYER_FACTION_ID, owner_id)
	if status == FACTION_RELATION_STATUS["HOSTILE"] or status == FACTION_RELATION_STATUS["SUSPENDED"]:
		return "외교 행동\n관계 회복 / 사절 파견 / 조공"
	return "외교 행동\n사절 파견 / 조공 / 교역 협정"


func _format_diplomacy_policy_display_for_ui(city_marker: WorldMapCityMarker) -> String:
	if city_marker == null:
		return "외교 판단\n도시를 선택하면 외교 판단이 표시됩니다."
	var owner_id := _get_city_owner_faction_id_for_trade_display(city_marker.city_id)
	if owner_id.is_empty():
		return "외교 판단\n소유 세력 확인이 필요합니다."
	if owner_id == PLAYER_FACTION_ID:
		return "외교 판단\n자국 도시는 외교 대상이 아닙니다."
	return _format_last_diplomacy_action_result_for_ui(owner_id)


func _ensure_diplomacy_action_card() -> void:
	if _diplomacy_action_card != null:
		return
	_diplomacy_action_card = PanelContainer.new()
	_diplomacy_action_card.name = "DiplomacyActionCard"
	_diplomacy_action_card.visible = false
	city_detail_content_container.add_child(_diplomacy_action_card)
	var content := VBoxContainer.new()
	content.name = "DiplomacyActionContent"
	content.add_theme_constant_override("separation", 6)
	_diplomacy_action_card.add_child(content)
	_diplomacy_action_title_label = Label.new()
	_diplomacy_action_title_label.name = "DiplomacyActionTitleLabel"
	_diplomacy_action_title_label.text = "외교 실행"
	content.add_child(_diplomacy_action_title_label)
	_diplomacy_action_status_label = Label.new()
	_diplomacy_action_status_label.name = "DiplomacyActionStatusLabel"
	_diplomacy_action_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(_diplomacy_action_status_label)
	_diplomacy_action_button_row = HBoxContainer.new()
	_diplomacy_action_button_row.name = "DiplomacyActionButtonRow"
	_diplomacy_action_button_row.add_theme_constant_override("separation", 4)
	content.add_child(_diplomacy_action_button_row)
	_diplomacy_envoy_button = _make_diplomacy_action_button("DiplomacyEnvoyButton", "사절 파견", DIPLOMACY_ACTION_ENVOY)
	_diplomacy_tribute_button = _make_diplomacy_action_button("DiplomacyTributeButton", "조공", DIPLOMACY_ACTION_TRIBUTE)
	_diplomacy_trade_agreement_button = _make_diplomacy_action_button("DiplomacyTradeAgreementButton", "교역 협정", DIPLOMACY_ACTION_TRADE_AGREEMENT)
	_diplomacy_restore_button = _make_diplomacy_action_button("DiplomacyRestoreButton", "관계 회복", DIPLOMACY_ACTION_RESTORE_RELATIONS)
	_diplomacy_alliance_button = _make_diplomacy_action_button("DiplomacyAllianceButton", "동맹 제안", DIPLOMACY_ACTION_ALLIANCE_PROPOSAL)
	_diplomacy_action_hint_label = Label.new()
	_diplomacy_action_hint_label.name = "DiplomacyActionHintLabel"
	_diplomacy_action_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(_diplomacy_action_hint_label)


func _make_diplomacy_action_button(node_name: String, label_text: String, action_id: String) -> Button:
	var button := Button.new()
	button.name = node_name
	button.text = label_text
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(_on_diplomacy_action_pressed.bind(action_id))
	_diplomacy_action_button_row.add_child(button)
	return button


func _refresh_diplomacy_action_card(city_marker: WorldMapCityMarker) -> void:
	_ensure_diplomacy_action_card()
	if city_marker == null:
		_diplomacy_action_card.visible = false
		return
	var target_city_id := city_marker.city_id
	var target_faction_id := _get_city_owner_faction_id_for_trade_display(target_city_id)
	if target_faction_id.is_empty() or target_faction_id == PLAYER_FACTION_ID:
		_diplomacy_action_card.visible = false
		return
	_diplomacy_action_card.visible = true
	var status := _get_faction_relation_status(PLAYER_FACTION_ID, target_faction_id)
	var score := _get_faction_relation_score(PLAYER_FACTION_ID, target_faction_id)
	var cooldown_turns := _get_diplomacy_action_cooldown(target_faction_id)
	var agreement_turns := _get_active_trade_agreement_turns(target_faction_id)
	var alliance_turns := _get_active_alliance_turns(target_faction_id)
	_diplomacy_action_title_label.text = "외교 실행 · %s" % _format_faction_label(target_faction_id)
	var status_parts := [
		"%s · 관계 %d" % [_format_diplomacy_relation_status_for_ui(status), score],
		"쿨다운 %d턴" % cooldown_turns if cooldown_turns > 0 else "행동 가능",
	]
	if agreement_turns > 0:
		status_parts.append("교역 협정 %d턴" % agreement_turns)
	if alliance_turns > 0:
		status_parts.append("동맹 %d턴" % alliance_turns)
	_diplomacy_action_status_label.text = " / ".join(status_parts)
	var validation_map := {
		DIPLOMACY_ACTION_ENVOY: _validate_diplomacy_action(DIPLOMACY_ACTION_ENVOY, target_city_id),
		DIPLOMACY_ACTION_TRIBUTE: _validate_diplomacy_action(DIPLOMACY_ACTION_TRIBUTE, target_city_id),
		DIPLOMACY_ACTION_TRADE_AGREEMENT: _validate_diplomacy_action(DIPLOMACY_ACTION_TRADE_AGREEMENT, target_city_id),
		DIPLOMACY_ACTION_RESTORE_RELATIONS: _validate_diplomacy_action(DIPLOMACY_ACTION_RESTORE_RELATIONS, target_city_id),
		DIPLOMACY_ACTION_ALLIANCE_PROPOSAL: _validate_diplomacy_action(DIPLOMACY_ACTION_ALLIANCE_PROPOSAL, target_city_id),
	}
	_refresh_diplomacy_action_button(_diplomacy_envoy_button, validation_map[DIPLOMACY_ACTION_ENVOY])
	_refresh_diplomacy_action_button(_diplomacy_tribute_button, validation_map[DIPLOMACY_ACTION_TRIBUTE])
	_refresh_diplomacy_action_button(_diplomacy_trade_agreement_button, validation_map[DIPLOMACY_ACTION_TRADE_AGREEMENT])
	_refresh_diplomacy_action_button(_diplomacy_restore_button, validation_map[DIPLOMACY_ACTION_RESTORE_RELATIONS])
	_refresh_diplomacy_action_button(_diplomacy_alliance_button, validation_map[DIPLOMACY_ACTION_ALLIANCE_PROPOSAL])
	_diplomacy_action_hint_label.text = _format_diplomacy_action_hint(validation_map)


func _refresh_diplomacy_action_button(button: Button, validation: Dictionary) -> void:
	if button == null:
		return
	button.disabled = not bool(validation.get("ok", false))
	var cost: Dictionary = validation.get("cost", {})
	if button.disabled:
		button.tooltip_text = "행동 불가 · %s" % str(validation.get("message", "조건 미충족"))
	elif str(validation.get("action_id", "")) == DIPLOMACY_ACTION_ALLIANCE_PROPOSAL:
		button.tooltip_text = "동맹 제안 · 비용 %s · 수락 %d/%d · 지속 %d턴 · 쿨다운 %d턴" % [
			_format_resource_costs(cost, ["gold", "silk"]),
			int(validation.get("acceptance_score", 0)),
			int(validation.get("required_score", ALLIANCE_ACCEPTANCE_THRESHOLD)),
			int(validation.get("alliance_turns", DIPLOMACY_ACTION_ALLIANCE_TURNS)),
			int(validation.get("cooldown", 0)),
		]
	else:
		button.tooltip_text = "행동 가능 · 비용 %s · 관계 %+d · 쿨다운 %d턴" % [
			_format_resource_costs(cost, ["gold"]),
			int(validation.get("relation_delta", 0)),
			int(validation.get("cooldown", 0)),
		]


func _format_diplomacy_action_hint(validation_map: Dictionary) -> String:
	var enabled_parts: Array[String] = []
	var blocked_parts: Array[String] = []
	for action_id in [DIPLOMACY_ACTION_ENVOY, DIPLOMACY_ACTION_TRIBUTE, DIPLOMACY_ACTION_TRADE_AGREEMENT, DIPLOMACY_ACTION_RESTORE_RELATIONS, DIPLOMACY_ACTION_ALLIANCE_PROPOSAL]:
		var validation: Dictionary = validation_map.get(action_id, {})
		var definition := _get_diplomacy_action_definition(action_id)
		var label_text := str(definition.get("label", action_id))
		if bool(validation.get("ok", false)):
			var cost: Dictionary = validation.get("cost", {})
			if action_id == DIPLOMACY_ACTION_ALLIANCE_PROPOSAL:
				enabled_parts.append("%s: 비용 %s · 수락 %d/%d" % [
					label_text,
					_format_resource_costs(cost, ["gold", "silk"]),
					int(validation.get("acceptance_score", 0)),
					int(validation.get("required_score", ALLIANCE_ACCEPTANCE_THRESHOLD)),
				])
			else:
				enabled_parts.append("%s: 비용 %s" % [label_text, _format_resource_costs(cost, ["gold"])])
		else:
			blocked_parts.append("%s: %s" % [label_text, str(validation.get("message", "불가"))])
	if not enabled_parts.is_empty():
		return "행동 가능\n%s" % "\n".join(enabled_parts)
	if not blocked_parts.is_empty():
		return "행동 불가\n%s" % blocked_parts[0]
	return "외교 행동 조건을 확인합니다."


func _format_last_diplomacy_action_result_for_ui(target_faction_id: String = "") -> String:
	var result_variant: Variant = _player_state.get("last_diplomacy_action_result", {})
	if not result_variant is Dictionary or (result_variant as Dictionary).is_empty():
		return "최근 외교\n기록 없음"
	var result := result_variant as Dictionary
	if not target_faction_id.is_empty() and str(result.get("target_faction_id", "")) != target_faction_id:
		return "최근 외교\n선택 세력 관련 기록 없음"
	var diplomacy_target_label := _format_faction_label(str(result.get("target_faction_id", "")))
	var action_id := str(result.get("action_id", ""))
	if action_id == DIPLOMACY_ACTION_ALLIANCE_PROPOSAL:
		if bool(result.get("accepted", false)):
			return "최근 외교\n동맹 체결 성공 → %s\n%d턴 / 수락 점수 %d / 기준 %d" % [
				diplomacy_target_label,
				int(result.get("alliance_turns_remaining", result.get("duration_turns", 0))),
				int(result.get("acceptance_score", result.get("acceptance_chance", 0))),
				int(result.get("required_score", result.get("acceptance_threshold", ALLIANCE_ACCEPTANCE_THRESHOLD))),
			]
		if str(result.get("reason", "")) == "rejected":
			return "최근 외교\n동맹 제안 거절 → %s\n수락 점수 %d / 기준 %d" % [
				diplomacy_target_label,
				int(result.get("acceptance_score", result.get("acceptance_chance", 0))),
				int(result.get("required_score", result.get("acceptance_threshold", ALLIANCE_ACCEPTANCE_THRESHOLD))),
			]
	if not bool(result.get("success", false)):
		return "최근 외교\n실패: %s" % str(result.get("message", "실행 실패"))
	var action_label := str(result.get("action_label", result.get("action_id", "외교")))
	var relation_line := "관계 %d → %d" % [int(result.get("before_score", 0)), int(result.get("after_score", 0))]
	var result_cost: Dictionary = result.get("cost", {})
	var gold_cost := maxi(0, int(result_cost.get("gold", 0)))
	var cost_text := "%s -%d" % [str(RESOURCE_LABELS.get("gold", "금전")), gold_cost] if gold_cost > 0 else _format_resource_costs(result_cost, ["gold"])
	if str(result.get("action_id", "")) == DIPLOMACY_ACTION_TRADE_AGREEMENT:
		var agreement: Dictionary = result.get("agreement", {})
		return "최근 외교\n%s → %s\n효율 보정 %d턴 / %s" % [
			action_label,
			diplomacy_target_label,
			int(agreement.get("turns_remaining", 0)),
			relation_line,
		]
	if cost_text.is_empty():
		var cost_variant: Variant = result.get("cost", {})
		if cost_variant is Dictionary:
			gold_cost = int((cost_variant as Dictionary).get("gold", 0))
		cost_text = "%s -%d" % [str(RESOURCE_LABELS.get("gold", "금전")), gold_cost]
	return "최근 외교\n%s → %s\n%s / %s" % [action_label, diplomacy_target_label, relation_line, cost_text]


func _has_enemy_intel_payload_for_ui(fields: Array[String], payload: Dictionary, field: String) -> bool:
	match field:
		"troops_estimated":
			return fields.has("troops_estimated") and payload.has("troops_estimated") and not (fields.has("troops") and payload.has("troops"))
		"troops":
			return fields.has("troops") and payload.has("troops")
		"resources":
			return fields.has("resources") and payload.has("resources")
		"publicSupport":
			return fields.has("publicSupport") and payload.has("publicSupport")
		"loyalty":
			return fields.has("loyalty") and payload.has("loyalty")
		"governor":
			return fields.has("governor") and payload.has("governor") and str(payload.get("governor", "")) != "not_available"
		"tech":
			return fields.has("tech") and payload.has("tech")
		_:
			return false


func _get_enemy_intel_revealed_field_ids_for_ui(fields: Array[String], payload: Dictionary) -> Array[String]:
	var revealed: Array[String] = []
	if _has_enemy_intel_payload_for_ui(fields, payload, "troops"):
		revealed.append("troops")
	elif _has_enemy_intel_payload_for_ui(fields, payload, "troops_estimated"):
		revealed.append("troops_estimated")
	for field in ["resources", "publicSupport", "loyalty", "governor", "tech"]:
		if _has_enemy_intel_payload_for_ui(fields, payload, field):
			revealed.append(field)
	return revealed


func _get_enemy_intel_level_id_for_ui(fields: Array[String]) -> String:
	if fields.is_empty():
		return "none"
	if fields.has("governor") and fields.has("tech"):
		return "full"
	if fields.has("publicSupport") or fields.has("loyalty") or fields.has("governor") or fields.has("tech"):
		return "domestic"
	if fields.has("resources"):
		return "resource"
	if fields.has("troops"):
		return "military"
	if fields.has("troops_estimated"):
		return "basic"
	return "none"


func _format_enemy_intel_level_label_for_ui(level_id: String) -> String:
	match level_id:
		"basic":
			return "기초 정탐"
		"military":
			return "군사 정탐"
		"resource":
			return "군사/자원 정탐"
		"domestic":
			return "내정 정탐"
		"full":
			return "상세 정탐"
		_:
			return "미확인"


func _get_enemy_intel_field_label_for_ui(field: String) -> String:
	match field:
		"troops_estimated":
			return "병력 추정"
		"troops":
			return "병력"
		"resources":
			return "자원"
		"publicSupport":
			return "민심"
		"loyalty":
			return "충성도"
		"governor":
			return "태수"
		"tech":
			return "기술"
		_:
			return field


func _get_enemy_intel_revealed_field_labels_for_ui(fields: Array[String]) -> Array[String]:
	var labels: Array[String] = []
	for field in fields:
		var label := _get_enemy_intel_field_label_for_ui(field)
		if not labels.has(label):
			labels.append(label)
	return labels


func _get_enemy_intel_locked_field_labels_for_ui(fields: Array[String]) -> Array[String]:
	var labels: Array[String] = []
	var troop_revealed := fields.has("troops") or fields.has("troops_estimated")
	for field in ["troops", "resources", "publicSupport", "loyalty", "governor", "tech"]:
		if field == "troops" and troop_revealed:
			continue
		if field != "troops" and fields.has(field):
			continue
		var label := _get_enemy_intel_field_label_for_ui(field)
		if not labels.has(label):
			labels.append(label)
	return labels


func _get_city_intel_fields_for_ui(intel_entry: Dictionary) -> Array[String]:
	var fields: Array[String] = []
	var raw_fields: Variant = intel_entry.get("fields", [])
	if raw_fields is Array:
		for field_variant in raw_fields:
			var field := str(field_variant)
			if not field.is_empty() and not fields.has(field):
				fields.append(field)
	return fields


func _get_city_intel_payload_for_ui(intel_entry: Dictionary) -> Dictionary:
	var raw_payload: Variant = intel_entry.get("payload", intel_entry.get("info", {}))
	if raw_payload is Dictionary:
		return (raw_payload as Dictionary).duplicate(true)
	return {}


func _format_spy_visibility_summary_for_ui(city_marker: WorldMapCityMarker) -> String:
	if city_marker == null:
		return "정보 수준\n정보 미확인"
	var owner_id := _get_city_owner_faction_id_for_trade_display(city_marker.city_id)
	if owner_id.is_empty():
		return "정보 수준\n정보 미확인"
	if owner_id == PLAYER_FACTION_ID:
		return "정보 수준\n자국 도시"
	var intel_entry := _get_city_intel_entry_for_ui(city_marker.city_id)
	if intel_entry.is_empty():
		return "정보 수준\n미확인\n공개: 도시명 / 세력 / 유형\n잠김: 병력 / 자원 / 민심 / 충성도 / 태수 / 기술\n다음: 정탐 필요"
	var fields := _get_city_intel_fields_for_ui(intel_entry)
	var payload := _get_city_intel_payload_for_ui(intel_entry)
	var revealed_fields := _get_enemy_intel_revealed_field_ids_for_ui(fields, payload)
	var level_label := _format_enemy_intel_level_label_for_ui(_get_enemy_intel_level_id_for_ui(revealed_fields))
	var revealed_labels := _get_enemy_intel_revealed_field_labels_for_ui(revealed_fields)
	var locked_labels := _get_enemy_intel_locked_field_labels_for_ui(revealed_fields)
	var revealed_text := "도시명 / 세력 / 유형"
	if not revealed_labels.is_empty():
		revealed_text = "%s / %s" % [revealed_text, " / ".join(revealed_labels)]
	var locked_text := "없음" if locked_labels.is_empty() else " / ".join(locked_labels)
	var next_text := "추가 정탐 필요" if not locked_labels.is_empty() else "잠김 정보 없음"
	return "정보 수준\n%s\n공개: %s\n잠김: %s\n다음: %s" % [level_label, revealed_text, locked_text, next_text]


func _format_spy_known_info_summary_for_ui(city_marker: WorldMapCityMarker) -> String:
	if city_marker == null:
		return "확인 정보\n도시를 선택하면 확인 정보가 표시됩니다."
	var owner_id := _get_city_owner_faction_id_for_trade_display(city_marker.city_id)
	if owner_id == PLAYER_FACTION_ID:
		return "확인 정보\n자국 도시는 도시 정보창에서 상세 정보를 확인할 수 있습니다."
	if owner_id.is_empty():
		return "확인 정보\n소유 세력 확인이 필요합니다."
	var intel_entry := _get_city_intel_entry_for_ui(city_marker.city_id)
	if intel_entry.is_empty():
		return "확인 정보\n공개: 도시명 / 세력 / 유형\n잠김: 병력 / 자원 / 민심 / 충성도 / 태수 / 기술\n다음: 정탐 필요"
	var fields := _get_city_intel_fields_for_ui(intel_entry)
	var payload := _get_city_intel_payload_for_ui(intel_entry)
	var revealed_fields := _get_enemy_intel_revealed_field_ids_for_ui(fields, payload)
	var level_label := _format_enemy_intel_level_label_for_ui(_get_enemy_intel_level_id_for_ui(revealed_fields))
	var revealed_labels := _get_enemy_intel_revealed_field_labels_for_ui(revealed_fields)
	var locked_labels := _get_enemy_intel_locked_field_labels_for_ui(revealed_fields)
	var value_parts: Array[String] = []
	if _has_enemy_intel_payload_for_ui(fields, payload, "troops"):
		value_parts.append("병력 %d" % int(payload.get("troops", 0)))
	elif _has_enemy_intel_payload_for_ui(fields, payload, "troops_estimated"):
		value_parts.append("병력 약 %d" % int(payload.get("troops_estimated", 0)))
	if _has_enemy_intel_payload_for_ui(fields, payload, "resources"):
		value_parts.append("자원 개략")
	if _has_enemy_intel_payload_for_ui(fields, payload, "publicSupport"):
		value_parts.append("민심 %s" % str(payload.get("publicSupport", "")))
	if _has_enemy_intel_payload_for_ui(fields, payload, "loyalty"):
		value_parts.append("충성도 %s" % str(payload.get("loyalty", "")))
	if _has_enemy_intel_payload_for_ui(fields, payload, "governor"):
		value_parts.append("태수 확인")
	if _has_enemy_intel_payload_for_ui(fields, payload, "tech"):
		value_parts.append("기술 확인")
	var revealed_text := "도시명 / 세력 / 유형"
	if not revealed_labels.is_empty():
		revealed_text = "%s / %s" % [revealed_text, " / ".join(revealed_labels)]
	var locked_text := "없음" if locked_labels.is_empty() else " / ".join(locked_labels)
	var value_text := "확인값: %s\n" % " / ".join(value_parts) if not value_parts.is_empty() else ""
	var next_text := "\n다음: 추가 정탐 필요" if not locked_labels.is_empty() else "\n다음: 잠김 정보 없음"
	return "확인 정보\n수준: %s\n공개: %s\n잠김: %s\n%s%s" % [level_label, revealed_text, locked_text, value_text, next_text]


func _get_city_intel_entry_for_ui(city_id: String) -> Dictionary:
	var registry := _normalize_city_intel_registry(_player_state.get("city_intel", {}))
	var raw_entry: Variant = registry.get(city_id, {})
	if raw_entry is Dictionary:
		return raw_entry as Dictionary
	return {}


func _format_spy_action_candidates_for_ui(city_marker: WorldMapCityMarker) -> String:
	if city_marker == null:
		return "첩보 행동\n도시를 선택하면 첩보 후보가 표시됩니다."
	var owner_id := _get_city_owner_faction_id_for_trade_display(city_marker.city_id)
	if owner_id == PLAYER_FACTION_ID:
		return "첩보 판단\n자국 도시는 첩보 대상이 아닙니다."
	if owner_id.is_empty():
		return "첩보 행동\n대상 세력 확인이 필요합니다."
	var lines: Array[String] = ["첩보 행동"]
	lines.append("정탐: %s" % _format_spy_check_status_for_ui(_can_gather_spy_info(city_marker.city_id)))
	lines.append("민심 교란: %s" % _format_spy_check_status_for_ui(_can_disrupt_city_public_support(city_marker.city_id)))
	lines.append("성 충성도 교란: %s" % _format_spy_check_status_for_ui(_can_disrupt_city_loyalty(city_marker.city_id)))
	lines.append("반란 조장: %s" % _format_spy_check_status_for_ui(_can_instigate_revolt(city_marker.city_id)))
	var wedge_check := _validate_spy_action(SPY_ACTION_WEDGE, city_marker.city_id)
	lines.append("이간질: %s" % _format_spy_check_status_for_ui(wedge_check))
	if bool(wedge_check.get("ok", false)):
		lines.append("대상 관계: %s ↔ %s / %d" % [
			_format_faction_label(str(wedge_check.get("target_faction_id", ""))),
			_format_faction_label(str(wedge_check.get("counterpart_faction_id", ""))),
			int(wedge_check.get("relation_score", 0)),
		])
	return "\n".join(lines)


func _format_spy_check_status_for_ui(check: Dictionary) -> String:
	if bool(check.get("ok", false)):
		return "행동 가능"
	var reason := str(check.get("reason", "unknown"))
	match reason:
		"own_city":
			return "자국 도시"
		"no_chancellor":
			return "재상 필요"
		"no_political_aptitude":
			return "정치형 재상 필요"
		"cooldown":
			return "쿨다운"
		"resources":
			return "자원 부족"
		"no_counterpart":
			return "상대 세력 없음"
		"already_hostile":
			return "이미 최악"
		"iron_wall":
			return "방첩 경계"
		"prerequisite_public_support", "prerequisite_loyalty":
			return "조건 확인 필요"
		"invalid_target":
			return "대상 확인 필요"
		_:
			return "조건 확인 필요"


func _format_recent_spy_result_for_ui(city_id: String) -> String:
	var recent_text := _format_recent_spy_result_from_key_for_ui("last_spy_result", city_id, "정탐")
	if recent_text.is_empty():
		recent_text = _format_recent_spy_result_from_key_for_ui("last_spy_public_support_disrupt_result", city_id, "민심 교란")
	if recent_text.is_empty():
		recent_text = _format_recent_spy_result_from_key_for_ui("last_spy_loyalty_disrupt_result", city_id, "성 충성도 교란")
	if recent_text.is_empty():
		recent_text = _format_recent_spy_result_from_key_for_ui("last_spy_revolt_instigation_result", city_id, "반란 조장")
	if recent_text.is_empty():
		recent_text = _format_recent_spy_result_from_key_for_ui("last_spy_wedge_result", city_id, "이간질")
	if recent_text.is_empty():
		recent_text = "최근 첩보 기록 없음"
	return "최근 첩보\n%s" % recent_text


func _format_recent_spy_result_from_key_for_ui(result_key: String, city_id: String, action_label: String) -> String:
	if city_id.is_empty():
		return ""
	var raw_result: Variant = _player_state.get(result_key, {})
	if not raw_result is Dictionary:
		return ""
	var result := raw_result as Dictionary
	if str(result.get("target_city_id", "")) != city_id:
		return ""
	if result.has("success_valid") and not bool(result.get("success_valid", true)) and not result.has("message"):
		return ""
	var outcome := "실패"
	if result_key == "last_spy_result" and bool(result.get("success", false)):
		outcome = "성공"
	elif result_key != "last_spy_result" and bool(result.get("effect_applied", false)):
		outcome = "성공"
	var detected_text := "발각 없음"
	if bool(result.get("detected", false)):
		detected_text = "발각 있음"
	if not bool(result.get("success", false)) and not bool(result.get("effect_applied", false)) and not bool(result.get("detected", false)) and result.has("message"):
		return "%s 실패 · %s" % [action_label, str(result.get("message", "실패"))]
	var detail_parts: Array[String] = []
	match result_key:
		"last_spy_result":
			var payload_variant: Variant = result.get("payload", result.get("info", {}))
			if payload_variant is Dictionary:
				var payload := payload_variant as Dictionary
				if payload.has("troops"):
					detail_parts.append("병력 %d" % int(payload.get("troops", 0)))
				elif payload.has("troops_estimated"):
					detail_parts.append("병력 약 %d" % int(payload.get("troops_estimated", 0)))
				if payload.has("loyalty"):
					detail_parts.append("충성도 %s" % str(payload.get("loyalty", "")))
				if payload.has("publicSupport"):
					detail_parts.append("민심 %s" % str(payload.get("publicSupport", "")))
		"last_spy_public_support_disrupt_result":
			if bool(result.get("effect_applied", false)):
				detail_parts.append("민심 -%d" % int(result.get("effect_amount", 0)))
		"last_spy_loyalty_disrupt_result":
			if bool(result.get("effect_applied", false)):
				detail_parts.append("충성도 -%d" % int(result.get("effect_amount", 0)))
		"last_spy_revolt_instigation_result":
			if bool(result.get("effect_applied", false)):
				detail_parts.append("반란 위험 +%d" % int(result.get("probability_boost", 0)))
		"last_spy_wedge_result":
			if bool(result.get("effect_applied", false)):
				detail_parts.append("%s-%s 관계 %d → %d" % [
					_format_faction_label(str(result.get("target_faction_id", result.get("target_faction_a", "")))),
					_format_faction_label(str(result.get("counterpart_faction_id", result.get("target_faction_b", "")))),
					int(result.get("before_score", 0)),
					int(result.get("after_score", 0)),
				])
			if bool(result.get("alliance_broken", false)):
				detail_parts.append("동맹 균열")
	if bool(result.get("detected", false)):
		detail_parts.append("관계 %d" % int(result.get("relation_penalty", 0)))
	if detail_parts.is_empty():
		return "%s %s · %s" % [action_label, outcome, detected_text]
	return "%s %s · %s\n%s" % [action_label, outcome, detected_text, " / ".join(detail_parts)]


func _format_spy_action_policy_display_for_ui(city_marker: WorldMapCityMarker) -> String:
	if city_marker == null:
		return "첩보 대기\n도시를 선택하면 실행 상태가 표시됩니다."
	var owner_id := _get_city_owner_faction_id_for_trade_display(city_marker.city_id)
	if owner_id.is_empty():
		return "첩보 대기\n대상 세력 확인이 필요합니다."
	if owner_id == PLAYER_FACTION_ID:
		return "첩보 대기\n자국 도시는 첩보 대상이 아닙니다."
	var cooldown_turns := maxi(0, int(_player_state.get("spy_cooldown", 0)))
	if cooldown_turns > 0:
		return "첩보 대기 중\n%d턴 후 다시 실행 가능" % cooldown_turns
	var wedge_check := _validate_spy_action(SPY_ACTION_WEDGE, city_marker.city_id)
	if bool(wedge_check.get("ok", false)):
		return "첩보 실행\n이간질 대상 %s ↔ %s / 성공률 %d%%" % [
			_format_faction_label(str(wedge_check.get("target_faction_id", ""))),
			_format_faction_label(str(wedge_check.get("counterpart_faction_id", ""))),
			int(wedge_check.get("success_chance", 0)),
		]
	return "첩보 실행\n이간질: %s" % str(wedge_check.get("message", "조건 확인 필요"))


func _ensure_spy_action_card() -> void:
	if _spy_action_card != null:
		return
	_spy_action_card = PanelContainer.new()
	_spy_action_card.name = "SpyActionCard"
	_spy_action_card.visible = false
	city_detail_content_container.add_child(_spy_action_card)
	var content := VBoxContainer.new()
	content.name = "SpyActionContent"
	content.add_theme_constant_override("separation", 6)
	_spy_action_card.add_child(content)
	_spy_action_title_label = Label.new()
	_spy_action_title_label.name = "SpyActionTitleLabel"
	_spy_action_title_label.text = "첩보 실행"
	content.add_child(_spy_action_title_label)
	_spy_action_status_label = Label.new()
	_spy_action_status_label.name = "SpyActionStatusLabel"
	_spy_action_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(_spy_action_status_label)
	_spy_action_button_row = HBoxContainer.new()
	_spy_action_button_row.name = "SpyActionButtonRow"
	_spy_action_button_row.add_theme_constant_override("separation", 4)
	content.add_child(_spy_action_button_row)
	_spy_gather_info_button = _make_spy_action_button("SpyGatherInfoButton", "정탐", SPY_ACTION_GATHER_INFO)
	_spy_public_support_button = _make_spy_action_button("SpyPublicSupportButton", "민심 교란", SPY_ACTION_PUBLIC_SUPPORT_DISRUPT)
	_spy_loyalty_button = _make_spy_action_button("SpyLoyaltyButton", "충성도 교란", SPY_ACTION_LOYALTY_DISRUPT)
	_spy_revolt_button = _make_spy_action_button("SpyRevoltButton", "반란 조장", SPY_ACTION_REVOLT_INSTIGATE)
	_spy_wedge_button = _make_spy_action_button("SpyWedgeButton", "이간질", SPY_ACTION_WEDGE)
	_spy_action_hint_label = Label.new()
	_spy_action_hint_label.name = "SpyActionHintLabel"
	_spy_action_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(_spy_action_hint_label)


func _make_spy_action_button(node_name: String, label_text: String, action_id: String) -> Button:
	var button := Button.new()
	button.name = node_name
	button.text = label_text
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(_on_spy_action_pressed.bind(action_id))
	_spy_action_button_row.add_child(button)
	return button


func _refresh_spy_action_card(city_marker: WorldMapCityMarker) -> void:
	_ensure_spy_action_card()
	if city_marker == null:
		_spy_action_card.visible = false
		return
	var target_city_id := city_marker.city_id
	var target_faction_id := _get_city_owner_faction_id_for_trade_display(target_city_id)
	if target_faction_id.is_empty() or target_faction_id == PLAYER_FACTION_ID:
		_spy_action_card.visible = false
		return
	_spy_action_card.visible = true
	var cooldown_turns := maxi(0, int(_player_state.get("spy_cooldown", 0)))
	_spy_action_title_label.text = "첩보 실행 · %s" % _format_city_name_by_id(target_city_id, target_city_id)
	var status_parts := [
		"대상 %s" % _format_faction_label(target_faction_id),
		"쿨다운 %d턴" % cooldown_turns if cooldown_turns > 0 else "행동 가능",
	]
	_spy_action_status_label.text = " / ".join(status_parts)
	var validation_map := {
		SPY_ACTION_GATHER_INFO: _validate_spy_action(SPY_ACTION_GATHER_INFO, target_city_id),
		SPY_ACTION_PUBLIC_SUPPORT_DISRUPT: _validate_spy_action(SPY_ACTION_PUBLIC_SUPPORT_DISRUPT, target_city_id),
		SPY_ACTION_LOYALTY_DISRUPT: _validate_spy_action(SPY_ACTION_LOYALTY_DISRUPT, target_city_id),
		SPY_ACTION_REVOLT_INSTIGATE: _validate_spy_action(SPY_ACTION_REVOLT_INSTIGATE, target_city_id),
		SPY_ACTION_WEDGE: _validate_spy_action(SPY_ACTION_WEDGE, target_city_id),
	}
	_refresh_spy_action_button(_spy_gather_info_button, validation_map[SPY_ACTION_GATHER_INFO])
	_refresh_spy_action_button(_spy_public_support_button, validation_map[SPY_ACTION_PUBLIC_SUPPORT_DISRUPT])
	_refresh_spy_action_button(_spy_loyalty_button, validation_map[SPY_ACTION_LOYALTY_DISRUPT])
	_refresh_spy_action_button(_spy_revolt_button, validation_map[SPY_ACTION_REVOLT_INSTIGATE])
	_refresh_spy_action_button(_spy_wedge_button, validation_map[SPY_ACTION_WEDGE])
	_spy_action_hint_label.text = _format_spy_action_hint(validation_map)


func _refresh_spy_action_button(button: Button, validation: Dictionary) -> void:
	if button == null:
		return
	button.disabled = not bool(validation.get("ok", false))
	if button.disabled:
		button.tooltip_text = "행동 불가 · %s" % str(validation.get("message", "조건 미충족"))
	else:
		var tooltip := "행동 가능 · 성공 %d%% · 발각 %d%% · 쿨다운 %d턴" % [
			int(validation.get("success_chance", 0)),
			int(validation.get("detection_chance", 0)),
			int(validation.get("cooldown", 0)),
		]
		if str(validation.get("action_id", "")) == SPY_ACTION_WEDGE:
			tooltip += " · %s ↔ %s · 비용 %s" % [
				_format_faction_label(str(validation.get("target_faction_id", ""))),
				_format_faction_label(str(validation.get("counterpart_faction_id", ""))),
				_format_resource_costs(validation.get("cost", {}), ["gold", "silk"]),
			]
		button.tooltip_text = tooltip


func _format_spy_action_hint(validation_map: Dictionary) -> String:
	var enabled_parts: Array[String] = []
	var blocked_parts: Array[String] = []
	for action_id in [SPY_ACTION_GATHER_INFO, SPY_ACTION_PUBLIC_SUPPORT_DISRUPT, SPY_ACTION_LOYALTY_DISRUPT, SPY_ACTION_REVOLT_INSTIGATE, SPY_ACTION_WEDGE]:
		var validation: Dictionary = validation_map.get(action_id, {})
		var definition := _get_spy_action_definition(action_id)
		var label_text := str(definition.get("label", action_id))
		if bool(validation.get("ok", false)):
			if action_id == SPY_ACTION_WEDGE:
				enabled_parts.append("%s %s-%s 성공 %d%%" % [
					label_text,
					_format_faction_label(str(validation.get("target_faction_id", ""))),
					_format_faction_label(str(validation.get("counterpart_faction_id", ""))),
					int(validation.get("success_chance", 0)),
				])
			else:
				enabled_parts.append("%s 성공 %d%%" % [label_text, int(validation.get("success_chance", 0))])
		else:
			blocked_parts.append("%s: %s" % [label_text, str(validation.get("message", "불가"))])
	if not enabled_parts.is_empty():
		return "행동 가능\n%s" % "\n".join(enabled_parts)
	if not blocked_parts.is_empty():
		return "행동 불가\n%s" % blocked_parts[0]
	return "첩보 행동 조건을 확인합니다."


func _get_diplomacy_spy_tab_label(tab_id: String) -> String:
	if tab_id == DIPLOMACY_SPY_TAB_SPY:
		return "첩보"
	return "외교"


func _refresh_city_detail_tab_styles() -> void:
	if _unified_primary_tab == UNIFIED_PANEL_TAB_DIPLOMACY_SPY:
		_refresh_unified_panel_chrome()
		return
	if _unified_primary_tab == UNIFIED_PANEL_TAB_TRADE:
		_set_city_detail_tab_active(city_detail_internal_trade_tab_button_placeholder, _selected_city_detail_tab == CITY_DETAIL_TAB_INTERNAL_TRADE)
		_set_city_detail_tab_active(city_detail_external_trade_tab_button_placeholder, _selected_city_detail_tab == CITY_DETAIL_TAB_EXTERNAL_TRADE)
		return

	_set_city_detail_tab_active(city_detail_resource_tab_button_placeholder, _selected_city_detail_tab == CITY_DETAIL_TAB_RESOURCES)


func _set_city_detail_tab_active(button: Button, is_active: bool) -> void:
	if button == null:
		_warn_missing_unified_panel_chrome("CityDetailTabButton")
		return
	var tab_color := Color(0.82, 0.86, 0.92, 1.0)
	if is_active:
		tab_color = Color(1.0, 0.9, 0.68, 1.0)
	button.modulate = tab_color


func _extract_resource_group(resource_summary: String, resource_names: Array[String]) -> String:
	if resource_summary.is_empty():
		return "미확인"

	var matches: Array[String] = []
	for chunk in resource_summary.split(" / "):
		for resource_name in resource_names:
			if chunk.begins_with(resource_name):
				matches.append(chunk)
				break

	if not matches.is_empty():
		return " / ".join(matches)
	return "미확인"


func _format_internal_route_summary(city_marker: WorldMapCityMarker) -> String:
	if city_marker.neighbors.is_empty():
		return "비활성"

	var linked_names: Array[String] = []
	for neighbor_id in _get_internal_trade_connected_player_city_ids(city_marker):
		linked_names.append(_format_city_name_by_id(str(neighbor_id), str(neighbor_id)))
	if linked_names.is_empty():
		return "연결 아군 성 없음"
	return " / ".join(linked_names)


func _get_internal_trade_connected_player_city_ids(city_marker: WorldMapCityMarker) -> Array[String]:
	var connected_city_ids: Array[String] = []
	if city_marker == null:
		return connected_city_ids
	if not _is_city_owned_by_player_mvp(city_marker.city_id):
		return connected_city_ids
	for neighbor_id_variant in city_marker.neighbors:
		var neighbor_id := str(neighbor_id_variant)
		if neighbor_id.is_empty():
			continue
		if _is_city_owned_by_player_mvp(neighbor_id) and not connected_city_ids.has(neighbor_id):
			connected_city_ids.append(neighbor_id)
	return connected_city_ids


func _format_internal_trade_route_display(city_marker: WorldMapCityMarker, connected_player_city_ids: Array[String]) -> String:
	var owned_city_count := _get_owned_city_count_for_internal_trade_display()
	if city_marker == null or not _is_city_owned_by_player_mvp(city_marker.city_id) or connected_player_city_ids.is_empty():
		return "연결 아군 성 없음\n보유 성: %d개\n수동 이송은 인접 아군 성이 필요합니다." % owned_city_count
	return "연결 아군 성\n%s\n수동 이송 가능" % _format_internal_trade_city_name_list(connected_player_city_ids)


func _format_internal_trade_lead_display(_connected_player_city_ids: Array[String]) -> String:
	if _connected_player_city_ids.is_empty():
		return ""
	return ""


func _format_internal_trade_policy_display(connected_player_city_ids: Array[String]) -> String:
	if connected_player_city_ids.is_empty():
		return "현재 방침\n아군 성 연결 후 무역 주도를 선택할 수 있습니다."
	return "현재 방침\n무역 주도 방식은 아래 버튼에서 선택합니다."


func _format_internal_trade_transfer_result_summary(source_city_id: String, connected_player_city_ids: Array[String]) -> String:
	var chancellor_auto_trade_text := _format_chancellor_internal_auto_trade_result_summary(source_city_id)
	if str(_trade_control_modes.get(CITY_DETAIL_TAB_INTERNAL_TRADE, TRADE_CONTROL_MODE_CHANCELLOR)) == TRADE_CONTROL_MODE_CHANCELLOR and not chancellor_auto_trade_text.is_empty():
		return chancellor_auto_trade_text
	if connected_player_city_ids.is_empty():
		return chancellor_auto_trade_text
	var result_variant: Variant = _player_state.get("last_internal_trade_transfer_result", {})
	if not result_variant is Dictionary:
		return chancellor_auto_trade_text
	var result := result_variant as Dictionary
	if result.is_empty():
		return chancellor_auto_trade_text
	if str(result.get("source_city_id", "")) != source_city_id:
		return chancellor_auto_trade_text
	var target_city_id := str(result.get("target_city_id", ""))
	var amounts_variant: Variant = result.get("amounts", {})
	var amounts := {}
	if amounts_variant is Dictionary:
		amounts = (amounts_variant as Dictionary).duplicate(true)
	return "최근 수동 이송\n%s → %s\n%s" % [
		_format_city_name_by_id(source_city_id, source_city_id),
		_format_city_name_by_id(target_city_id, target_city_id),
		_format_internal_trade_transfer_amounts(amounts),
	]


func _format_chancellor_internal_auto_trade_result_summary(city_id: String) -> String:
	var result_variant: Variant = _player_state.get("last_chancellor_auto_trade_result", {})
	if not result_variant is Dictionary:
		return ""
	var result := result_variant as Dictionary
	if result.is_empty():
		return ""
	if not bool(result.get("ok", false)):
		return "최근 재상 자동무역\n%s" % str(result.get("message", "이번 턴 적용된 자동무역 없음"))
	var internal_variant: Variant = result.get("internal", {})
	if not internal_variant is Dictionary:
		return ""
	var applied_variant: Variant = (internal_variant as Dictionary).get("applied", [])
	if not applied_variant is Array:
		return ""
	for item_variant in applied_variant:
		if not item_variant is Dictionary:
			continue
		var item := item_variant as Dictionary
		var source_city_id := str(item.get("source_city_id", ""))
		var target_city_id := str(item.get("target_city_id", ""))
		if source_city_id != city_id and target_city_id != city_id:
			continue
		var amounts := {}
		var amounts_variant: Variant = item.get("amounts", {})
		if amounts_variant is Dictionary:
			amounts = (amounts_variant as Dictionary).duplicate(true)
		return "최근 재상 자동무역\n%s → %s\n%s" % [
			_format_city_name_by_id(source_city_id, source_city_id),
			_format_city_name_by_id(target_city_id, target_city_id),
			_format_internal_trade_transfer_amounts(amounts),
		]
	return "최근 재상 자동무역\n이번 턴 적용된 자동무역 없음"


func _format_internal_trade_city_name_list(city_ids: Array[String]) -> String:
	var city_names: Array[String] = []
	for city_id in city_ids:
		city_names.append(_format_city_name_by_id(city_id, city_id))
	if city_names.is_empty():
		return "없음"
	return " / ".join(city_names)


func _get_owned_city_count_for_internal_trade_display() -> int:
	var owned_city_ids: Variant = _player_state.get("owned_city_ids", [])
	if not owned_city_ids is Array:
		return 0
	var count := 0
	for city_id_variant in owned_city_ids:
		var city_id := str(city_id_variant)
		if _is_city_owned_by_player_mvp(city_id):
			count += 1
	return count


func _format_external_trade_target(city_marker: WorldMapCityMarker) -> String:
	if city_marker == null:
		return "인접 대외 교역 없음"
	var candidate_city_ids := _get_external_trade_candidate_city_ids(city_marker.city_id)
	if candidate_city_ids.is_empty():
		return "인접 대외 교역 없음"
	var first_candidate_id := candidate_city_ids[0]
	return _format_external_trade_candidate_line(first_candidate_id)


func _get_external_trade_candidate_city_ids(source_city_id: String) -> Array[String]:
	var candidate_city_ids: Array[String] = []
	if source_city_id.is_empty():
		return candidate_city_ids
	if not _is_city_owned_by_player_mvp(source_city_id):
		return candidate_city_ids
	var source_faction_id := _get_city_owner_faction_id_for_trade_display(source_city_id)
	if source_faction_id.is_empty():
		return candidate_city_ids
	for neighbor_id_variant in _get_city_neighbors_mvp(source_city_id):
		var neighbor_id := str(neighbor_id_variant)
		if neighbor_id.is_empty():
			continue
		if _is_city_owned_by_player_mvp(neighbor_id):
			continue
		var neighbor_faction_id := _get_city_owner_faction_id_for_trade_display(neighbor_id)
		if neighbor_faction_id.is_empty():
			continue
		if neighbor_faction_id == source_faction_id:
			continue
		if not candidate_city_ids.has(neighbor_id):
			candidate_city_ids.append(neighbor_id)
	return candidate_city_ids


func _get_city_owner_faction_id_for_trade_display(city_id: String) -> String:
	var city_marker := _city_markers_by_id.get(city_id) as WorldMapCityMarker
	if city_marker != null and not city_marker.owner_faction_id.is_empty():
		return city_marker.owner_faction_id
	var city_data := _get_city_hud_entry(city_id)
	if city_data.is_empty():
		return ""
	return _get_city_owner_faction_id(city_data)


func _format_external_trade_candidate_summary(_source_city_id: String, candidate_city_ids: Array[String]) -> String:
	if candidate_city_ids.is_empty():
		return "교역 후보 없음\n인접 외국 성이 있는 자국 성에서 타국무역을 확인할 수 있습니다."
	var lines: Array[String] = ["교역 후보"]
	for candidate_city_id in candidate_city_ids:
		lines.append(_format_external_trade_candidate_line(candidate_city_id))
	return "\n".join(lines)


func _format_external_trade_candidate_line(city_id: String) -> String:
	var city_name := _format_city_name_by_id(city_id, city_id)
	var faction_id := _get_city_owner_faction_id_for_trade_display(city_id)
	return "%s · %s" % [city_name, _format_faction_label(faction_id)]


func _format_external_trade_relation_summary(source_city_id: String, candidate_city_ids: Array[String]) -> String:
	if candidate_city_ids.is_empty():
		return ""
	var source_faction_id := _get_city_owner_faction_id_for_trade_display(source_city_id)
	var lines: Array[String] = ["관계 상태"]
	if candidate_city_ids.size() == 1:
		var target_faction_id := _get_city_owner_faction_id_for_trade_display(candidate_city_ids[0])
		lines.append("%s · %s" % [
			_format_faction_relation_status_for_ui(_get_faction_relation_status(source_faction_id, target_faction_id)),
			_format_trade_availability_for_ui(source_faction_id, target_faction_id),
		])
		lines.append("교역 효율 x%.2f" % _get_trade_relation_multiplier_for_ui(source_faction_id, target_faction_id))
		lines.append("가격: 시장가 x 관계 효율")
		return "\n".join(lines)
	for candidate_city_id in candidate_city_ids:
		var candidate_faction_id := _get_city_owner_faction_id_for_trade_display(candidate_city_id)
		lines.append("%s: %s · %s · 효율 x%.2f" % [
			_format_faction_label(candidate_faction_id),
			_format_faction_relation_status_for_ui(_get_faction_relation_status(source_faction_id, candidate_faction_id)),
			_format_trade_availability_for_ui(source_faction_id, candidate_faction_id),
			_get_trade_relation_multiplier_for_ui(source_faction_id, candidate_faction_id),
		])
	lines.append("가격: 시장가 x 관계 효율")
	return "\n".join(lines)


func _format_faction_relation_status_for_ui(status: String) -> String:
	match status:
		"allied":
			return "동맹"
		"neutral":
			return "중립"
		"hostile":
			return "적대"
		"suspended":
			return "교역 중단"
		_:
			return "관계 미확인"


func _format_trade_availability_for_ui(source_faction_id: String, target_faction_id: String) -> String:
	if _can_trade_between_factions(source_faction_id, target_faction_id):
		return "교역 가능"
	return "교역 제한"


func _get_trade_relation_multiplier_for_ui(source_faction_id: String, target_faction_id: String) -> float:
	if source_faction_id.is_empty() or target_faction_id.is_empty() or source_faction_id == target_faction_id:
		return 0.0
	var relation_status := _get_faction_relation_status(source_faction_id, target_faction_id)
	var raw_multiplier: Variant = RELATION_TRADE_MULTIPLIER.get(relation_status, 1.0)
	return float(raw_multiplier) + _get_trade_agreement_bonus_multiplier(source_faction_id, target_faction_id)


func _format_external_trade_lead_display(_candidate_city_ids: Array[String]) -> String:
	if _candidate_city_ids.is_empty():
		return ""
	return ""


func _format_external_trade_policy_display(candidate_city_ids: Array[String]) -> String:
	if candidate_city_ids.is_empty():
		return ""
	return "현재 방침\n무역 주도 방식은 아래 버튼에서 선택합니다."


func _format_external_trade_manual_order_summary(source_city_id: String, candidate_city_ids: Array[String]) -> String:
	var chancellor_auto_trade_text := _format_chancellor_external_auto_trade_result_summary(source_city_id)
	if candidate_city_ids.is_empty():
		return chancellor_auto_trade_text
	var order: Dictionary = _manual_trade_orders.get(source_city_id, {})
	var recent_execution_text := _format_external_manual_trade_execution_result_summary(source_city_id)
	if str(_trade_control_modes.get(CITY_DETAIL_TAB_EXTERNAL_TRADE, TRADE_CONTROL_MODE_CHANCELLOR)) == TRADE_CONTROL_MODE_CHANCELLOR and order.is_empty() and not chancellor_auto_trade_text.is_empty():
		return chancellor_auto_trade_text
	if order.is_empty():
		if not recent_execution_text.is_empty():
			return recent_execution_text
		if not chancellor_auto_trade_text.is_empty():
			return chancellor_auto_trade_text
		return "수동 무역 명령\n저장된 명령 없음\n수동 조정에서 수입/수출 계획을 입력합니다."
	var target_city_id := str(order.get("target_city_id", ""))
	var preview: Variant = order.get("preview", {})
	var preview_text := "예상 없음"
	if preview is Dictionary:
		preview_text = _format_manual_trade_nonzero_preview_summary(preview as Dictionary)
	var lines := [
		"수동 무역 명령",
		"상대: %s" % _format_city_name_by_id(target_city_id, target_city_id),
		"예상: %s" % preview_text,
		"상태: 실행 대기",
	]
	if not recent_execution_text.is_empty():
		lines.append("")
		lines.append(recent_execution_text)
	return "\n".join(lines)


func _format_chancellor_external_auto_trade_result_summary(source_city_id: String) -> String:
	var result_variant: Variant = _player_state.get("last_chancellor_auto_trade_result", {})
	if not result_variant is Dictionary:
		return ""
	var result := result_variant as Dictionary
	if result.is_empty():
		return ""
	if not bool(result.get("ok", false)):
		return "최근 재상 대외무역\n%s" % str(result.get("message", "이번 턴 적용된 자동무역 없음"))
	var external_variant: Variant = result.get("external", {})
	if not external_variant is Dictionary:
		return ""
	var applied_variant: Variant = (external_variant as Dictionary).get("applied", [])
	if not applied_variant is Array:
		return ""
	for item_variant in applied_variant:
		if not item_variant is Dictionary:
			continue
		var item := item_variant as Dictionary
		if str(item.get("source_city_id", "")) != source_city_id:
			continue
		var target_city_id := str(item.get("target_city_id", ""))
		var applied := {}
		var applied_delta_variant: Variant = item.get("applied", {})
		if applied_delta_variant is Dictionary:
			applied = (applied_delta_variant as Dictionary).duplicate(true)
		if item.has("efficiency"):
			applied["efficiency"] = float(item.get("efficiency", 0.0))
		return "최근 재상 대외무역\n%s ↔ %s\n%s" % [
			_format_city_name_by_id(source_city_id, source_city_id),
			_format_city_name_by_id(target_city_id, target_city_id),
			_format_manual_trade_nonzero_preview_summary(applied),
		]
	return "최근 재상 대외무역\n이번 턴 적용된 자동무역 없음"


func _format_external_manual_trade_execution_result_summary(source_city_id: String) -> String:
	var result_variant: Variant = _player_state.get("last_external_manual_trade_execution_result", {})
	if not result_variant is Dictionary:
		return ""
	var result := result_variant as Dictionary
	if result.is_empty() or str(result.get("source_city_id", "")) != source_city_id:
		return ""
	if not bool(result.get("ok", false)):
		return "수동 무역 실행 실패\n%s" % str(result.get("message", "실행할 수 없습니다."))
	var target_city_id := str(result.get("target_city_id", ""))
	var applied_variant: Variant = result.get("applied", {})
	var applied := {}
	if applied_variant is Dictionary:
		applied = (applied_variant as Dictionary).duplicate(true)
	if result.has("efficiency"):
		applied["efficiency"] = float(result.get("efficiency", 0.0))
	return "최근 수동 무역 실행\n%s ↔ %s\n%s\n선택 성 창고에 반영되었습니다." % [
		_format_city_name_by_id(source_city_id, source_city_id),
		_format_city_name_by_id(target_city_id, target_city_id),
		_format_manual_trade_nonzero_preview_summary(applied),
	]


func _format_manual_trade_nonzero_preview_summary(preview: Dictionary) -> String:
	var parts: Array[String] = []
	var gold_delta := int(preview.get("gold", 0))
	if gold_delta != 0:
		parts.append("금전 %s" % _format_signed_int(gold_delta))
	for resource_id in MANUAL_TRADE_RESOURCE_ORDER:
		var delta := int(preview.get(resource_id, 0))
		if delta == 0:
			continue
		parts.append("%s %s" % [
			str(RESOURCE_LABELS.get(resource_id, resource_id)),
			_format_signed_int(delta),
		])
	if parts.is_empty():
		return "금전 0"
	var summary := " / ".join(parts)
	if preview.has("efficiency") and float(preview.get("efficiency", 0.0)) > 0.0:
		return "효율 x%.2f 적용 · %s" % [float(preview.get("efficiency", 0.0)), summary]
	return summary


func _format_external_trade_recent_summary(source_city_id: String, candidate_city_ids: Array[String]) -> String:
	if candidate_city_ids.is_empty():
		return ""
	var last_trade_result: Variant = _player_state.get("last_inter_faction_trade_result", {})
	if not last_trade_result is Dictionary:
		return "최근 교역 기록\n선택 성 관련 기록 없음"
	var related_route_count := _count_recent_external_trade_routes_for_city(source_city_id, candidate_city_ids, last_trade_result as Dictionary)
	if related_route_count <= 0:
		return "최근 교역 기록\n선택 성 관련 기록 없음"
	return "최근 교역 기록\n선택 성 관련 루트 %d개" % related_route_count


func _count_recent_external_trade_routes_for_city(source_city_id: String, candidate_city_ids: Array[String], result: Dictionary) -> int:
	var routes: Variant = result.get("routes", [])
	if not routes is Array:
		return 0
	var count := 0
	for route_variant in routes:
		if not route_variant is Dictionary:
			continue
		var route := route_variant as Dictionary
		var city_a_id := str(route.get("city_a_id", ""))
		var city_b_id := str(route.get("city_b_id", ""))
		if city_a_id == source_city_id and candidate_city_ids.has(city_b_id):
			count += 1
		elif city_b_id == source_city_id and candidate_city_ids.has(city_a_id):
			count += 1
	return count


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
		return "보급 상태\n역할: 일반\n상태: 확인 필요\n수입 배수: x1.00"
	var state_id := "unsupplied"
	if bool(supply_state.get("isolated", false)):
		state_id = "isolated"
	elif bool(supply_state.get("supplied", false)):
		state_id = "supplied"
	return "보급 상태\n역할: %s\n상태: %s\n수입 배수: x%.2f" % [
		_format_supply_role_label(str(supply_state.get("role", ""))),
		_format_supply_status_label(state_id),
		float(supply_state.get("income_multiplier", 1.0)),
	]


func _format_supply_role_label(role_id: String) -> String:
	match role_id:
		"hub":
			return "중심 거점"
		"rear":
			return "후방"
		"frontline":
			return "전방"
		_:
			return "일반"


func _format_supply_status_label(status_id: String) -> String:
	match status_id:
		"supplied":
			return "보급 연결"
		"isolated":
			return "고립"
		"unsupplied":
			return "보급 미연결"
		_:
			return "확인 필요"


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
	var summary := _get_city_recruitment_summary(city_id)
	if summary.is_empty():
		return "■ 병사 충원\n징병: 정보 없음\n모병: 정보 없음"
	return "■ 병사 충원\n%s\n%s" % [
		str(summary.get("conscription_line", "징병: 정보 없음")),
		str(summary.get("recruitment_line", "모병: 정보 없음")),
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
		lines.append("%s-%s\n%s / score %d / band %s\n금전 %s / 쌀 %s / 보리 %s\n수산 %s / 소금 %s" % [
			_format_city_name_by_id(city_a_id, city_a_id),
			_format_city_name_by_id(city_b_id, city_b_id),
			str(route.get("relation_status", FACTION_RELATION_STATUS["NEUTRAL"])),
			int(route.get("relation_score", DIPLOMACY_DEFAULT_SCORE)),
			str(route.get("relation_band", _get_faction_relation_band(int(route.get("relation_score", DIPLOMACY_DEFAULT_SCORE))))),
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
	_lock_left_world_status_panel_anchor()
	_lock_world_turn_header_order()
	_setup_left_world_header_slim_ui()
	_setup_left_world_tax_slim_ui()
	_setup_warehouse_card_ui()
	_setup_pending_invasion_choice_ui()
	_setup_post_battle_result_ui()
	_setup_save_management_ui()
	_ensure_left_world_status_help_buttons()
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


func _ensure_left_world_status_help_buttons() -> void:
	if _left_national_loyalty_help_button != null:
		return
	if power_label == null or power_label.get_parent() == null:
		return
	_left_national_loyalty_help_button = Button.new()
	_left_national_loyalty_help_button.name = "NationalLoyaltyHelpButton"
	_left_national_loyalty_help_button.text = "?"
	_left_national_loyalty_help_button.custom_minimum_size = Vector2(24.0, 18.0)
	_left_national_loyalty_help_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_left_national_loyalty_help_button.focus_mode = Control.FOCUS_NONE
	_left_national_loyalty_help_button.tooltip_text = "국가충성도 도움말"
	_left_national_loyalty_help_button.add_theme_font_size_override("font_size", 10)
	power_label.get_parent().add_child(_left_national_loyalty_help_button)
	if power_label.get_parent() is VBoxContainer:
		(power_label.get_parent() as VBoxContainer).move_child(_left_national_loyalty_help_button, mini(power_label.get_index() + 1, power_label.get_parent().get_child_count() - 1))
	_left_national_loyalty_help_button.pressed.connect(_show_worldmap_help_modal.bind("national_loyalty"))


func _setup_left_world_header_slim_ui() -> void:
	left_world_status_eyebrow_label.visible = false
	left_world_status_eyebrow_label.text = ""
	turn_label.visible = false
	turn_label.text = ""
	nation_label.visible = false
	nation_label.text = ""
	calendar_label.visible = true
	calendar_label.add_theme_font_size_override("font_size", 16)


func _setup_left_world_tax_slim_ui() -> void:
	tax_bar.visible = false
	security_label.visible = false
	security_label.text = ""
	security_bar.visible = false


func _lock_left_world_status_panel_anchor() -> void:
	if left_world_status_panel == null:
		return
	left_world_status_panel.set_anchors_preset(Control.PRESET_TOP_LEFT, false)
	left_world_status_panel.position = LEFT_WORLD_STATUS_PANEL_TOP_LEFT
	left_world_status_panel.size = LEFT_WORLD_STATUS_PANEL_SIZE
	left_world_status_panel.custom_minimum_size = LEFT_WORLD_STATUS_PANEL_SIZE


func _lock_world_turn_header_order() -> void:
	var content := left_world_status_eyebrow_label.get_parent() as VBoxContainer
	if content == null:
		return
	var ordered_nodes: Array[Node] = [
		left_world_status_eyebrow_label,
		turn_label,
		calendar_label,
		nation_label,
	]
	var separator := content.get_node_or_null("WorldTurnSeparator") as HSeparator
	if separator != null:
		ordered_nodes.append(separator)
	for node_index in range(ordered_nodes.size()):
		var child := ordered_nodes[node_index]
		if child != null and child.get_parent() == content:
			content.move_child(child, node_index)


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
	_pending_invasion_title_label.text = "침공 대기"
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
	_pending_invasion_instruction_label.text = "방어 배치를 선택하십시오."
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


func _ensure_worldmap_help_modal() -> void:
	if _worldmap_help_modal != null:
		return
	var worldmap_ui := get_node_or_null("WorldMapUI") as CanvasLayer
	if worldmap_ui == null:
		return
	_worldmap_help_modal = PanelContainer.new()
	_worldmap_help_modal.name = "WorldMapHelpModal"
	_worldmap_help_modal.visible = false
	_worldmap_help_modal.z_index = 120
	_worldmap_help_modal.anchor_left = 0.5
	_worldmap_help_modal.anchor_right = 0.5
	_worldmap_help_modal.anchor_top = 0.0
	_worldmap_help_modal.anchor_bottom = 0.0
	_worldmap_help_modal.offset_left = -190.0
	_worldmap_help_modal.offset_right = 190.0
	_worldmap_help_modal.offset_top = 72.0
	_worldmap_help_modal.offset_bottom = 292.0
	_worldmap_help_modal.custom_minimum_size = Vector2(380.0, 220.0)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.055, 0.065, 0.075, 0.97)
	panel_style.border_color = Color(0.82, 0.72, 0.48, 0.86)
	panel_style.set_border_width_all(1)
	panel_style.set_corner_radius_all(4)
	panel_style.content_margin_left = 12.0
	panel_style.content_margin_top = 10.0
	panel_style.content_margin_right = 12.0
	panel_style.content_margin_bottom = 10.0
	_worldmap_help_modal.add_theme_stylebox_override("panel", panel_style)
	worldmap_ui.add_child(_worldmap_help_modal)

	var content := VBoxContainer.new()
	content.name = "Content"
	content.add_theme_constant_override("separation", 8)
	_worldmap_help_modal.add_child(content)

	_worldmap_help_title_label = Label.new()
	_worldmap_help_title_label.name = "TitleLabel"
	_worldmap_help_title_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.58, 1.0))
	_worldmap_help_title_label.add_theme_font_size_override("font_size", 15)
	content.add_child(_worldmap_help_title_label)

	_worldmap_help_body_label = Label.new()
	_worldmap_help_body_label.name = "BodyLabel"
	_worldmap_help_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_worldmap_help_body_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_worldmap_help_body_label.add_theme_color_override("font_color", Color(0.93, 0.92, 0.84, 1.0))
	_worldmap_help_body_label.add_theme_font_size_override("font_size", 12)
	content.add_child(_worldmap_help_body_label)

	var action_row := HBoxContainer.new()
	action_row.name = "ActionRow"
	action_row.alignment = BoxContainer.ALIGNMENT_END
	content.add_child(action_row)

	_worldmap_help_close_button = Button.new()
	_worldmap_help_close_button.name = "CloseButton"
	_worldmap_help_close_button.text = "닫기"
	_worldmap_help_close_button.custom_minimum_size = Vector2(70.0, 24.0)
	_worldmap_help_close_button.focus_mode = Control.FOCUS_NONE
	_worldmap_help_close_button.add_theme_font_size_override("font_size", 11)
	action_row.add_child(_worldmap_help_close_button)
	_worldmap_help_close_button.pressed.connect(_hide_worldmap_help_modal)


func _show_worldmap_help_modal(topic_id: String) -> void:
	_ensure_worldmap_help_modal()
	if _worldmap_help_modal == null:
		return
	var content := _get_worldmap_help_content(topic_id)
	_worldmap_help_title_label.text = str(content.get("title", "도움말"))
	_worldmap_help_body_label.text = str(content.get("body", "도움말 정보가 없습니다."))
	_worldmap_help_modal.visible = true
	_worldmap_help_modal.move_to_front()


func _hide_worldmap_help_modal() -> void:
	if _worldmap_help_modal != null:
		_worldmap_help_modal.visible = false


func _get_worldmap_help_content(topic_id: String) -> Dictionary:
	match topic_id:
		"national_loyalty":
			return {
				"title": "국가충성도",
				"body": "국가 전체의 안정도를 보여줍니다.\n\n관리 방법:\n· 세금 부담을 낮게 유지하기\n· 정치형 재상으로 충성도 손실 줄이기\n· 안정적인 내정 운영 유지",
			}
		"city_loyalty":
			return {
				"title": "성 충성도",
				"body": "선택 도시의 충성도입니다.\n\n관리 방법:\n· 세금 부담 낮추기\n· 치안 안정시키기\n· 보급 상태 유지하기\n· 정치형 태수 또는 재상 활용하기\n· 민심 안정 유지하기",
			}
		"public_support":
			return {
				"title": "민심",
				"body": "도시 백성들의 여론과 생활 안정도입니다.\n\n관리 방법:\n· 세금 부담 낮추기\n· 식량 사정 안정시키기\n· 상업 기반 키우기\n· 보급 상태 유지하기",
			}
		"security":
			return {
				"title": "치안",
				"body": "도시의 질서와 안정 상태입니다.\n\n관리 방법:\n· 충분한 주둔 병력 유지하기\n· 보급 경로 유지하기\n· 병력 이동 시 최소 주둔군 지키기\n· 침공/전투 상황에 대비하기",
			}
		"garrison":
			return {
				"title": "주둔무장",
				"body": "현재 구현된 활용:\n· 태수 임명 후보\n· 도시 방어와 전투 출전\n· 태수 임명 시 지휘 한계 증가\n· 장수 상태에 따라 전투 참여 제한",
			}
		_:
			return {
				"title": "도움말",
				"body": "도움말 정보가 없습니다.",
			}


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
	left_world_status_eyebrow_label.visible = false
	turn_label.visible = false
	calendar_label.text = "%s · %s · %s" % [
		str(_player_state.get("turn_label", "제 1턴")),
		str(_player_state.get("year_label", "154년 봄 1턴")),
		str(_player_state.get("current_phase_label", "아군 턴")),
	]
	nation_label.visible = false
	var national_loyalty := int(_player_state.get("national_loyalty", 0))
	var tax_level := _normalize_tax_level(_player_state.get("tax_level", 0))
	var public_order := int(_player_state.get("public_order", 0))
	power_label.text = "국가충성도 %d · %s" % [national_loyalty, _get_loyalty_status(national_loyalty)]
	power_bar.value = national_loyalty
	tax_label.text = "세금 수준 %d · %s" % [tax_level, _get_tax_description(tax_level)]
	tax_bar.value = tax_level
	tax_bar.visible = false
	tax_slider.set_value_no_signal(float(tax_level))
	security_label.text = ""
	security_label.visible = false
	security_bar.value = public_order
	security_bar.visible = false

	_sync_chancellor_assignment_for_selected_city({})
	_populate_chancellor_assignment_dropdown()
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
	chancellor_stats_label.visible = not chancellor_data.is_empty()
	chancellor_stats_label.text = _format_chancellor_type_summary(chancellor_data) if not chancellor_data.is_empty() else ""
	chancellor_policy_description_label.text = "효과: %s\n정책: %s" % [
		_get_chancellor_effect_text(chancellor_data),
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
	var world_status_hint := _format_invasion_status_text(pending_invasion_event)
	if world_status_hint.is_empty():
		world_status_hint = _format_enemy_faction_turn_result_hint(_player_state.get("last_enemy_faction_turn_result", {}))
	world_status_hint_label.text = world_status_hint
	world_status_hint_label.visible = not world_status_hint.is_empty()
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
	if not _player_state.has("faction_chancellors") or not (_player_state["faction_chancellors"] is Dictionary):
		_player_state["faction_chancellors"] = {}
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
	_player_state["enemy_invasion_roll_turn"] = maxi(0, int(_player_state.get("enemy_invasion_roll_turn", 0)))
	if not _player_state.has("last_enemy_faction_turn_result") or not (_player_state["last_enemy_faction_turn_result"] is Dictionary):
		_player_state["last_enemy_faction_turn_result"] = {}
	if not _player_state.has("last_enemy_strategic_action_result") or not (_player_state["last_enemy_strategic_action_result"] is Dictionary):
		_player_state["last_enemy_strategic_action_result"] = {}
	_player_state["last_enemy_faction_turn_result"] = _normalize_enemy_faction_turn_result_display(_player_state.get("last_enemy_faction_turn_result", {}))
	if not _player_state.has("last_enemy_pressure_plan_result") or not (_player_state["last_enemy_pressure_plan_result"] is Dictionary):
		_player_state["last_enemy_pressure_plan_result"] = {}
	_player_state["last_enemy_pressure_plan_result"] = _normalize_enemy_pressure_plan_result_mvp((_player_state["last_enemy_faction_turn_result"] as Dictionary).get("pressure_plan", _player_state.get("last_enemy_pressure_plan_result", {})))
	var normalized_enemy_strategic_actions := _normalize_enemy_strategic_actions_for_display((_player_state["last_enemy_faction_turn_result"] as Dictionary).get("strategic_actions", []))
	if normalized_enemy_strategic_actions.is_empty():
		_player_state["last_enemy_strategic_action_result"] = {}
	else:
		_player_state["last_enemy_strategic_action_result"] = normalized_enemy_strategic_actions[0].duplicate(true)
	if not _player_state.has("last_enemy_faction_turn_processed_turn"):
		_player_state["last_enemy_faction_turn_processed_turn"] = 0
	_player_state["last_enemy_faction_turn_processed_turn"] = maxi(0, int(_player_state.get("last_enemy_faction_turn_processed_turn", 0)))
	if not _player_state.has("faction_relations") or not (_player_state["faction_relations"] is Dictionary):
		_player_state["faction_relations"] = {}
	if not _player_state.has("last_inter_faction_trade_result") or not (_player_state["last_inter_faction_trade_result"] is Dictionary):
		_player_state["last_inter_faction_trade_result"] = {}
	if not _player_state.has("last_trade_market_result") or not (_player_state["last_trade_market_result"] is Dictionary):
		_player_state["last_trade_market_result"] = {}
	if not _player_state.has("trade_market_prices") or not (_player_state["trade_market_prices"] is Dictionary):
		_player_state["trade_market_prices"] = {}
	if not _player_state.has("trade_market_turn"):
		_player_state["trade_market_turn"] = 0
	_player_state["trade_market_turn"] = maxi(0, int(_player_state.get("trade_market_turn", 0)))
	if not _player_state.has("last_diplomacy_relation_result") or not (_player_state["last_diplomacy_relation_result"] is Dictionary):
		_player_state["last_diplomacy_relation_result"] = {}
	if not _player_state.has("last_diplomacy_normalize_result") or not (_player_state["last_diplomacy_normalize_result"] is Dictionary):
		_player_state["last_diplomacy_normalize_result"] = {}
	if not _player_state.has("last_diplomacy_cooldown_result") or not (_player_state["last_diplomacy_cooldown_result"] is Dictionary):
		_player_state["last_diplomacy_cooldown_result"] = {}
	if not _player_state.has("last_diplomacy_action_result") or not (_player_state["last_diplomacy_action_result"] is Dictionary):
		_player_state["last_diplomacy_action_result"] = {}
	if not _player_state.has("diplomacy_action_cooldowns") or not (_player_state["diplomacy_action_cooldowns"] is Dictionary):
		_player_state["diplomacy_action_cooldowns"] = {}
	if not _player_state.has("trade_agreements") or not (_player_state["trade_agreements"] is Dictionary):
		_player_state["trade_agreements"] = {}
	if not _player_state.has("alliances") or not (_player_state["alliances"] is Dictionary):
		_player_state["alliances"] = {}
	if not _player_state.has("last_tribute_result") or not (_player_state["last_tribute_result"] is Dictionary):
		_player_state["last_tribute_result"] = {}
	if not _player_state.has("last_alliance_proposal_result") or not (_player_state["last_alliance_proposal_result"] is Dictionary):
		_player_state["last_alliance_proposal_result"] = {}
	if not _player_state.has("last_military_support_result") or not (_player_state["last_military_support_result"] is Dictionary):
		_player_state["last_military_support_result"] = {}
	if not _player_state.has("last_trade_agreement_result") or not (_player_state["last_trade_agreement_result"] is Dictionary):
		_player_state["last_trade_agreement_result"] = {}
	if not _player_state.has("revolt_instigation") or not (_player_state["revolt_instigation"] is Dictionary):
		_player_state["revolt_instigation"] = {}
	if not _player_state.has("city_intel") or not (_player_state["city_intel"] is Dictionary):
		_player_state["city_intel"] = {}
	if not _player_state.has("spy_cooldown"):
		_player_state["spy_cooldown"] = 0
	_player_state["spy_cooldown"] = maxi(0, int(_player_state.get("spy_cooldown", 0)))
	if not _player_state.has("last_spy_result") or not (_player_state["last_spy_result"] is Dictionary):
		_player_state["last_spy_result"] = {}
	if not _player_state.has("last_spy_cooldown_result") or not (_player_state["last_spy_cooldown_result"] is Dictionary):
		_player_state["last_spy_cooldown_result"] = {}
	if not _player_state.has("last_spy_public_support_disrupt_result") or not (_player_state["last_spy_public_support_disrupt_result"] is Dictionary):
		_player_state["last_spy_public_support_disrupt_result"] = {}
	if not _player_state.has("last_spy_loyalty_disrupt_result") or not (_player_state["last_spy_loyalty_disrupt_result"] is Dictionary):
		_player_state["last_spy_loyalty_disrupt_result"] = {}
	if not _player_state.has("last_spy_revolt_instigation_result") or not (_player_state["last_spy_revolt_instigation_result"] is Dictionary):
		_player_state["last_spy_revolt_instigation_result"] = {}
	if not _player_state.has("last_revolt_instigation_tick_result") or not (_player_state["last_revolt_instigation_tick_result"] is Dictionary):
		_player_state["last_revolt_instigation_tick_result"] = {}
	if not _player_state.has("last_spy_wedge_result") or not (_player_state["last_spy_wedge_result"] is Dictionary):
		_player_state["last_spy_wedge_result"] = {}
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
	_normalize_domestic_tech_state_mvp()
	_player_state["last_trade_market_result"] = _normalize_trade_market_result(_player_state.get("last_trade_market_result", {}))
	_sync_trade_market_mirror_from_result(_player_state["last_trade_market_result"])
	_ensure_trade_market_for_current_turn()
	_player_state["trade_control_modes"] = _normalize_trade_control_modes(_player_state.get("trade_control_modes", {}))
	_player_state["manual_trade_orders"] = _normalize_manual_trade_orders(_player_state.get("manual_trade_orders", {}))
	_player_state["last_external_manual_trade_execution_result"] = _normalize_trade_result_payload(_player_state.get("last_external_manual_trade_execution_result", {}))
	_player_state["last_internal_trade_transfer_result"] = _normalize_trade_result_payload(_player_state.get("last_internal_trade_transfer_result", {}))
	_player_state["last_chancellor_auto_trade_result"] = _normalize_chancellor_auto_trade_result_payload(_player_state.get("last_chancellor_auto_trade_result", {}))
	_player_state["last_chancellor_auto_trade_turn"] = maxi(0, int(_player_state.get("last_chancellor_auto_trade_turn", 0)))
	_player_state["city_intel"] = _normalize_city_intel_registry(_player_state.get("city_intel", {}))
	_ensure_faction_chancellors_seeded()
	_normalize_diplomacy_action_state_from_player_state()
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
	if not _get_pending_battle_context_mvp().is_empty():
		_set_save_management_status("진행 중인 전투 데이터를 먼저 처리하십시오.")
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
	print("[WorldMap] Enemy turn MVP hook reached. Enemy faction reinforcement and invasion event roll are running.")
	_enemy_turn_mvp_pending = true
	_set_save_management_status("적군 턴 진행 중...")
	var turn_number := maxi(1, int(_player_state.get("turn_number", 1)))
	var enemy_turn_already_processed := int(_player_state.get("last_enemy_faction_turn_processed_turn", 0)) == turn_number
	var enemy_turn_result := _process_enemy_faction_turn_mvp()
	var invasion_event := {}
	if not enemy_turn_already_processed:
		invasion_event = _roll_enemy_invasion_event_mvp()
		_attach_enemy_invasion_event_to_enemy_turn_result(invasion_event)
	if not invasion_event.is_empty():
		_set_save_management_status(_format_invasion_status_text(invasion_event))
	elif enemy_turn_result is Dictionary and not (enemy_turn_result as Dictionary).is_empty():
		_set_save_management_status(str((enemy_turn_result as Dictionary).get("summary", "이번 턴 적 행동 처리 완료")))
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
	if _has_pending_invasion_event_mvp() or not _get_pending_battle_context_mvp().is_empty():
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


func _process_enemy_faction_turn_mvp() -> Dictionary:
	_ensure_worldmap_runtime_state_defaults()
	var turn_number := maxi(1, int(_player_state.get("turn_number", 1)))
	var previous_result: Variant = _player_state.get("last_enemy_faction_turn_result", {})
	if int(_player_state.get("last_enemy_faction_turn_processed_turn", 0)) == turn_number:
		var normalized_previous_result := _normalize_enemy_faction_turn_result_display(previous_result)
		_player_state["last_enemy_faction_turn_result"] = normalized_previous_result.duplicate(true)
		_player_state["last_enemy_pressure_plan_result"] = _normalize_enemy_pressure_plan_result_mvp(normalized_previous_result.get("pressure_plan", {}))
		return normalized_previous_result
	var result := {
		"turn": turn_number,
		"phase": TURN_PHASE_ENEMY,
		"processed_factions": [],
		"actions": [],
		"pressure_plan": {},
		"strategic_actions": [],
		"pending_invasion_created": false,
		"pending_invasion_already_active": _has_pending_invasion_event_mvp(),
		"pending_battle_already_active": not _get_pending_battle_context_mvp().is_empty(),
		"summary": "",
	}
	if bool(result.get("pending_invasion_already_active", false)) or bool(result.get("pending_battle_already_active", false)):
		_player_state["last_enemy_pressure_plan_result"] = {}
		result["summary"] = _build_enemy_faction_turn_summary(result)
		_player_state["last_enemy_faction_turn_result"] = result.duplicate(true)
		_player_state["last_enemy_faction_turn_processed_turn"] = turn_number
		return result
	var processed_factions: Array[String] = []
	var actions: Array[Dictionary] = []
	var pressure_plan := _pick_enemy_pressure_plan_mvp()
	result["pressure_plan"] = pressure_plan.duplicate(true)
	_player_state["last_enemy_pressure_plan_result"] = pressure_plan.duplicate(true)
	for faction_id in _get_enemy_faction_ids_for_turn_mvp():
		var action_result := _apply_enemy_city_reinforcement_mvp(faction_id, _pick_enemy_city_for_turn_action(faction_id))
		processed_factions.append(faction_id)
		if not action_result.is_empty():
			actions.append(action_result)
	result["processed_factions"] = processed_factions
	result["actions"] = actions
	var strategic_action := _process_enemy_strategic_follow_up_action_mvp(processed_factions)
	if not strategic_action.is_empty():
		result["strategic_actions"] = [strategic_action]
		_player_state["last_enemy_strategic_action_result"] = strategic_action.duplicate(true)
	else:
		result["strategic_actions"] = []
		_player_state["last_enemy_strategic_action_result"] = {}
	result["summary"] = _build_enemy_faction_turn_summary(result)
	_player_state["last_enemy_faction_turn_result"] = result.duplicate(true)
	_player_state["last_enemy_faction_turn_processed_turn"] = turn_number
	print("[ENEMY_FACTION_TURN] turn=%d factions=%s actions=%d summary=%s" % [
		turn_number,
		str(processed_factions),
		actions.size(),
		str(result.get("summary", ""))
	])
	return result


func _get_worldmap_city_ids_for_enemy_turn_mvp() -> Array[String]:
	var seen := {}
	for city_id_variant in CITY_HUD_DATA.keys():
		var city_id := str(city_id_variant)
		if not city_id.is_empty():
			seen[city_id] = true
	for city_id_variant in _city_markers_by_id.keys():
		var city_id := str(city_id_variant)
		if not city_id.is_empty():
			seen[city_id] = true
	var sorted_ids: Array = seen.keys()
	sorted_ids.sort()
	var result: Array[String] = []
	for city_id_variant in sorted_ids:
		result.append(str(city_id_variant))
	return result


func _get_enemy_faction_ids_for_turn_mvp() -> Array[String]:
	var faction_seen := {}
	for city_id in _get_worldmap_city_ids_for_enemy_turn_mvp():
		var faction_id := _get_safe_enemy_owner_faction_id_for_turn_mvp(city_id)
		if faction_id.is_empty():
			continue
		if _get_enemy_owned_city_ids_for_faction(faction_id).is_empty():
			continue
		faction_seen[faction_id] = true
	var sorted_ids: Array = faction_seen.keys()
	sorted_ids.sort()
	var result: Array[String] = []
	for faction_id_variant in sorted_ids:
		var faction_id := str(faction_id_variant)
		if FACTION_LABELS.has(faction_id):
			result.append(faction_id)
	for faction_id_variant in sorted_ids:
		var faction_id := str(faction_id_variant)
		if not FACTION_LABELS.has(faction_id):
			result.append(faction_id)
	return result


func _get_enemy_owned_city_ids_for_faction(faction_id: String) -> Array[String]:
	var city_ids: Array[String] = []
	if faction_id.is_empty() or faction_id == PLAYER_FACTION_ID:
		return city_ids
	for city_id in _get_worldmap_city_ids_for_enemy_turn_mvp():
		if _get_safe_enemy_owner_faction_id_for_turn_mvp(city_id) != faction_id:
			continue
		if not city_ids.has(city_id):
			city_ids.append(city_id)
	city_ids.sort()
	return city_ids


func _get_enemy_faction_personality_seed(faction_id: String) -> Dictionary:
	var raw_default_seed: Variant = ENEMY_FACTION_PERSONALITY_SEEDS.get("default", {})
	var default_seed: Dictionary = {}
	if raw_default_seed is Dictionary:
		default_seed = (raw_default_seed as Dictionary).duplicate(true)
	if faction_id.is_empty() or faction_id == PLAYER_FACTION_ID:
		return default_seed.duplicate(true)
	var raw_seed: Variant = ENEMY_FACTION_PERSONALITY_SEEDS.get(faction_id, default_seed)
	if raw_seed is Dictionary:
		var personality_seed := default_seed.duplicate(true)
		for key in (raw_seed as Dictionary).keys():
			personality_seed[key] = (raw_seed as Dictionary)[key]
		return personality_seed
	return default_seed.duplicate(true)


func _get_enemy_faction_personality_profile_id(faction_id: String) -> String:
	return str(_get_enemy_faction_personality_seed(faction_id).get("profile", "default_balanced"))


func _get_enemy_faction_personality_label(faction_id: String) -> String:
	return str(_get_enemy_faction_personality_seed(faction_id).get("label", "균형"))


func _get_enemy_faction_behavior_weight(faction_id: String, key: String, default_value: float = 1.0) -> float:
	var personality_seed := _get_enemy_faction_personality_seed(faction_id)
	var weight := float(personality_seed.get(key, default_value))
	return clampf(weight, 0.75, 1.25)


func _get_enemy_faction_personality_metadata(faction_id: String) -> Dictionary:
	if faction_id.is_empty() or faction_id == PLAYER_FACTION_ID:
		return {}
	return {
		"personality_profile": _get_enemy_faction_personality_profile_id(faction_id),
		"personality_label": _get_enemy_faction_personality_label(faction_id),
	}


func _get_enemy_faction_strategic_goal_seed(faction_id: String) -> Dictionary:
	var raw_default_seed: Variant = ENEMY_FACTION_STRATEGIC_GOAL_SEEDS.get("default", {})
	var default_seed: Dictionary = {}
	if raw_default_seed is Dictionary:
		default_seed = (raw_default_seed as Dictionary).duplicate(true)
	if faction_id.is_empty() or faction_id == PLAYER_FACTION_ID:
		return default_seed.duplicate(true)
	var raw_seed: Variant = ENEMY_FACTION_STRATEGIC_GOAL_SEEDS.get(faction_id, default_seed)
	if raw_seed is Dictionary:
		var goal_seed := default_seed.duplicate(true)
		for key in (raw_seed as Dictionary).keys():
			goal_seed[key] = (raw_seed as Dictionary)[key]
		return goal_seed
	return default_seed.duplicate(true)


func _get_enemy_faction_goal_id(faction_id: String) -> String:
	return str(_get_enemy_faction_strategic_goal_seed(faction_id).get("goal_id", "hold_position"))


func _get_enemy_faction_goal_label(faction_id: String) -> String:
	return str(_get_enemy_faction_strategic_goal_seed(faction_id).get("label", "전선 유지"))


func _get_enemy_faction_goal_pressure(faction_id: String) -> String:
	return str(_get_enemy_faction_strategic_goal_seed(faction_id).get("pressure", "balanced"))


func _get_enemy_faction_goal_weight(faction_id: String) -> float:
	var goal_seed := _get_enemy_faction_strategic_goal_seed(faction_id)
	return clampf(float(goal_seed.get("weight", 1.0)), 1.0, 1.15)


func _get_enemy_goal_target_city_ids(faction_id: String) -> Array[String]:
	var result: Array[String] = []
	if faction_id.is_empty() or faction_id == PLAYER_FACTION_ID:
		return result
	var goal_seed := _get_enemy_faction_strategic_goal_seed(faction_id)
	var raw_city_ids: Variant = goal_seed.get("target_city_ids", [])
	if not raw_city_ids is Array:
		return result
	for city_id_variant in raw_city_ids:
		var city_id := str(city_id_variant)
		if city_id.is_empty():
			continue
		if not _has_city_for_battle_context(city_id) and not CITY_HUD_DATA.has(city_id):
			continue
		if not result.has(city_id):
			result.append(city_id)
	return result


func _is_city_preferred_by_enemy_goal(faction_id: String, city_id: String) -> bool:
	if faction_id.is_empty() or faction_id == PLAYER_FACTION_ID or city_id.is_empty():
		return false
	return _get_enemy_goal_target_city_ids(faction_id).has(city_id)


func _is_city_adjacent_to_enemy_goal_target(faction_id: String, city_id: String) -> bool:
	if faction_id.is_empty() or faction_id == PLAYER_FACTION_ID or city_id.is_empty():
		return false
	for target_city_id in _get_enemy_goal_target_city_ids(faction_id):
		if target_city_id == city_id:
			continue
		if _get_city_neighbors_mvp(city_id).has(target_city_id) or _get_city_neighbors_mvp(target_city_id).has(city_id):
			return true
	return false


func _get_enemy_faction_goal_metadata(faction_id: String) -> Dictionary:
	if faction_id.is_empty() or faction_id == PLAYER_FACTION_ID:
		return {}
	return {
		"goal_id": _get_enemy_faction_goal_id(faction_id),
		"goal_label": _get_enemy_faction_goal_label(faction_id),
		"goal_pressure": _get_enemy_faction_goal_pressure(faction_id),
	}


func _get_enemy_goal_label_display_part(goal_id: String, goal_label: String) -> String:
	if goal_id.is_empty() or goal_id == "hold_position" or goal_label.is_empty():
		return ""
	return "목표: %s" % goal_label


func _normalize_enemy_pressure_type_mvp(raw_pressure_type: String, faction_id: String = "") -> String:
	var pressure_type := raw_pressure_type.strip_edges()
	match pressure_type:
		"military", "invasion", "diplomacy", "spy", "defensive", "balanced":
			return pressure_type
		"aggressive":
			return "military"
		"trade_defensive":
			return "defensive"
	if not faction_id.is_empty() and faction_id != PLAYER_FACTION_ID:
		var profile_id := _get_enemy_faction_personality_profile_id(faction_id)
		if profile_id.find("spy") >= 0 or profile_id.find("scheme") >= 0:
			return "spy"
		if profile_id.find("diplomacy") >= 0:
			return "diplomacy"
		if profile_id.find("defensive") >= 0:
			return "defensive"
		if profile_id.find("aggressive") >= 0 or profile_id.find("military") >= 0:
			return "military"
	return "balanced"


func _get_enemy_pressure_plan_display_label_mvp(plan: Dictionary) -> String:
	if plan.is_empty():
		return ""
	if str(plan.get("type", "")) != "enemy_pressure_plan":
		return ""
	if str(plan.get("effect", "")) != "display_scoring_only":
		return ""
	var goal_id := str(plan.get("goal_id", ""))
	var goal_label := str(plan.get("goal_label", ""))
	if goal_id.is_empty() or goal_id == "hold_position" or goal_label.is_empty():
		return ""
	return "전략: %s" % goal_label


func _get_enemy_pressure_plan_compact_label_mvp(plan: Dictionary) -> String:
	if plan.is_empty():
		return ""
	if str(plan.get("type", "")) != "enemy_pressure_plan":
		return ""
	if str(plan.get("effect", "")) != "display_scoring_only":
		return ""
	var goal_id := str(plan.get("goal_id", ""))
	var goal_label := str(plan.get("goal_label", ""))
	if goal_id.is_empty() or goal_id == "hold_position" or goal_label.is_empty():
		return ""
	return goal_label


func _is_enemy_hint_label_safe_mvp(label: String, raw_id: String = "") -> bool:
	var safe_label := label.strip_edges()
	var raw_label_id := raw_id.strip_edges()
	if safe_label.is_empty() or safe_label.length() > 18:
		return false
	if not raw_label_id.is_empty() and safe_label == raw_label_id:
		return false
	if safe_label.find("_") >= 0 or safe_label.begins_with("pressure_"):
		return false
	return true


func _clamp_enemy_hint_line_mvp(line: String, max_length: int = 46) -> String:
	var safe_line := line.strip_edges()
	var safe_max := maxi(12, max_length)
	if safe_line.length() <= safe_max:
		return safe_line
	return "%s..." % safe_line.substr(0, safe_max - 3).strip_edges()


func _append_unique_enemy_hint_line_mvp(lines: Array[String], line: String, max_length: int = 46) -> void:
	var safe_line := _clamp_enemy_hint_line_mvp(line, max_length)
	if safe_line.is_empty() or lines.has(safe_line):
		return
	lines.append(safe_line)


func _format_enemy_pressure_plan_hint_mvp(plan: Dictionary, result_turn: int = 0, short_label: bool = false) -> String:
	var normalized_plan := _normalize_enemy_pressure_plan_result_mvp(plan)
	if normalized_plan.is_empty():
		return ""
	if result_turn > 0 and int(normalized_plan.get("turn_number", 0)) != result_turn:
		return ""
	var faction_id := str(normalized_plan.get("faction_id", ""))
	var faction_label := str(normalized_plan.get("faction_label", _format_faction_label(faction_id)))
	var goal_id := str(normalized_plan.get("goal_id", ""))
	var goal_label := _get_enemy_pressure_plan_compact_label_mvp(normalized_plan)
	if not _is_enemy_hint_label_safe_mvp(goal_label, goal_id):
		return ""
	if short_label or not _is_enemy_hint_label_safe_mvp(faction_label, faction_id):
		return "전략: %s" % goal_label
	return "적 전략: %s · %s" % [faction_label, goal_label]


func _should_skip_enemy_pressure_plan_mvp() -> bool:
	if _has_pending_invasion_event_mvp() or not _get_pending_battle_context_mvp().is_empty():
		return true
	var turn_number := maxi(0, int(_player_state.get("turn_number", 0)))
	if turn_number <= 0:
		return true
	var current_plan := _normalize_enemy_pressure_plan_result_mvp(_player_state.get("last_enemy_pressure_plan_result", {}))
	return not current_plan.is_empty() and int(current_plan.get("turn_number", 0)) == turn_number


func _build_enemy_pressure_plan_candidates_mvp() -> Array[Dictionary]:
	var candidates: Array[Dictionary] = []
	for faction_id in _get_enemy_faction_ids_for_turn_mvp():
		var candidate := _build_enemy_pressure_plan_candidate_for_faction_mvp(faction_id)
		if candidate.is_empty():
			continue
		candidates.append(candidate)
	candidates.sort_custom(Callable(self, "_sort_enemy_pressure_plan_candidates_mvp"))
	return candidates


func _build_enemy_pressure_plan_candidate_for_faction_mvp(faction_id: String) -> Dictionary:
	if faction_id.is_empty() or faction_id == PLAYER_FACTION_ID:
		return {}
	var owned_city_ids := _get_enemy_owned_city_ids_for_faction(faction_id)
	if owned_city_ids.is_empty():
		return {}
	var pressure_type := _normalize_enemy_pressure_type_mvp(_get_enemy_faction_goal_pressure(faction_id), faction_id)
	var best_candidate: Dictionary = {}
	var best_score := -INF
	for source_city_id in owned_city_ids:
		if _get_safe_enemy_owner_faction_id_for_turn_mvp(source_city_id) != faction_id:
			continue
		if not _has_city_for_battle_context(source_city_id):
			continue
		var target_city_ids := _get_enemy_pressure_plan_target_city_ids_for_source_mvp(faction_id, source_city_id, pressure_type)
		for plan_target_city_id in target_city_ids:
			var candidate := {
				"faction_id": faction_id,
				"source_city_id": source_city_id,
				"target_city_id": plan_target_city_id,
				"pressure_type": pressure_type,
				"goal_id": _get_enemy_faction_goal_id(faction_id),
				"goal_label": _get_enemy_faction_goal_label(faction_id),
				"personality_profile": _get_enemy_faction_personality_profile_id(faction_id),
			}
			var score := _score_enemy_pressure_plan_candidate_mvp(candidate)
			if best_candidate.is_empty() or score > best_score:
				candidate["score"] = score
				best_candidate = candidate
				best_score = score
	if best_candidate.is_empty():
		return {}
	return best_candidate


func _get_enemy_pressure_plan_target_city_ids_for_source_mvp(faction_id: String, source_city_id: String, pressure_type: String) -> Array[String]:
	var target_city_ids: Array[String] = []
	for neighbor_variant in _get_city_neighbors_mvp(source_city_id):
		var neighbor_id := str(neighbor_variant)
		if neighbor_id.is_empty() or not _has_city_for_battle_context(neighbor_id):
			continue
		if _is_city_owned_by_player_mvp(neighbor_id):
			target_city_ids.append(neighbor_id)
	for goal_target_id in _get_enemy_goal_target_city_ids(faction_id):
		if not _has_city_for_battle_context(goal_target_id) and not CITY_HUD_DATA.has(goal_target_id):
			continue
		if source_city_id == goal_target_id or _get_city_neighbors_mvp(source_city_id).has(goal_target_id) or _get_city_neighbors_mvp(goal_target_id).has(source_city_id):
			if not target_city_ids.has(goal_target_id):
				target_city_ids.append(goal_target_id)
	if target_city_ids.is_empty() and (pressure_type == "defensive" or pressure_type == "balanced"):
		target_city_ids.append(source_city_id)
	return target_city_ids


func _score_enemy_pressure_plan_candidate_mvp(candidate: Dictionary) -> float:
	var faction_id := str(candidate.get("faction_id", ""))
	var source_city_id := str(candidate.get("source_city_id", ""))
	var plan_target_city_id := str(candidate.get("target_city_id", ""))
	if faction_id.is_empty() or faction_id == PLAYER_FACTION_ID or source_city_id.is_empty() or plan_target_city_id.is_empty():
		return -INF
	if _get_safe_enemy_owner_faction_id_for_turn_mvp(source_city_id) != faction_id:
		return -INF
	var pressure_type := _normalize_enemy_pressure_type_mvp(str(candidate.get("pressure_type", "")), faction_id)
	var score := 100.0
	score += float(mini(_get_city_troops_for_enemy_invasion_mvp(source_city_id), 2000)) / 80.0
	if _is_enemy_frontline_city_for_faction(source_city_id, faction_id):
		score += 16.0
	if _is_city_preferred_by_enemy_goal(faction_id, plan_target_city_id):
		score += 18.0 * _get_enemy_faction_goal_weight(faction_id)
	elif _is_city_adjacent_to_enemy_goal_target(faction_id, plan_target_city_id):
		score += 8.0 * _get_enemy_faction_goal_weight(faction_id)
	if pressure_type == "invasion" or pressure_type == "military":
		score *= _get_enemy_faction_behavior_weight(faction_id, "invasion_weight", 1.0)
	elif pressure_type == "spy":
		score *= _get_enemy_faction_behavior_weight(faction_id, "spy_weight", 1.0)
	elif pressure_type == "diplomacy":
		score *= _get_enemy_faction_behavior_weight(faction_id, "diplomacy_weight", 1.0)
	else:
		score *= _get_enemy_faction_behavior_weight(faction_id, "reinforce_weight", 1.0)
	return score


func _sort_enemy_pressure_plan_candidates_mvp(left: Dictionary, right: Dictionary) -> bool:
	var left_score := float(left.get("score", 0.0))
	var right_score := float(right.get("score", 0.0))
	if not is_equal_approx(left_score, right_score):
		return left_score > right_score
	var left_key := "%s:%s:%s" % [str(left.get("faction_id", "")), str(left.get("source_city_id", "")), str(left.get("target_city_id", ""))]
	var right_key := "%s:%s:%s" % [str(right.get("faction_id", "")), str(right.get("source_city_id", "")), str(right.get("target_city_id", ""))]
	return left_key < right_key


func _pick_enemy_pressure_plan_mvp() -> Dictionary:
	if _should_skip_enemy_pressure_plan_mvp():
		return {}
	var candidates := _build_enemy_pressure_plan_candidates_mvp()
	if candidates.is_empty():
		return {}
	var selected_candidate := candidates[0]
	var result := {
		"type": "enemy_pressure_plan",
		"turn_number": maxi(1, int(_player_state.get("turn_number", 1))),
		"faction_id": str(selected_candidate.get("faction_id", "")),
		"faction_label": _format_faction_label(str(selected_candidate.get("faction_id", ""))),
		"personality_profile": str(selected_candidate.get("personality_profile", "")),
		"goal_id": str(selected_candidate.get("goal_id", "")),
		"goal_label": str(selected_candidate.get("goal_label", "")),
		"pressure_type": _normalize_enemy_pressure_type_mvp(str(selected_candidate.get("pressure_type", "")), str(selected_candidate.get("faction_id", ""))),
		"target_city_id": str(selected_candidate.get("target_city_id", "")),
		"target_city_label": _format_city_name_by_id(str(selected_candidate.get("target_city_id", "")), str(selected_candidate.get("target_city_id", ""))),
		"source_city_id": str(selected_candidate.get("source_city_id", "")),
		"source_city_label": _format_city_name_by_id(str(selected_candidate.get("source_city_id", "")), str(selected_candidate.get("source_city_id", ""))),
		"effect": "display_scoring_only",
	}
	return _normalize_enemy_pressure_plan_result_mvp(result)


func _normalize_enemy_pressure_plan_result_mvp(raw_result: Variant) -> Dictionary:
	if not raw_result is Dictionary:
		return {}
	var result := (raw_result as Dictionary).duplicate(true)
	if str(result.get("type", "")) != "enemy_pressure_plan":
		return {}
	var faction_id := str(result.get("faction_id", ""))
	if faction_id.is_empty() or faction_id == PLAYER_FACTION_ID:
		return {}
	var source_city_id := str(result.get("source_city_id", ""))
	var plan_target_city_id := str(result.get("target_city_id", ""))
	if source_city_id.is_empty() or plan_target_city_id.is_empty():
		return {}
	if _get_safe_enemy_owner_faction_id_for_turn_mvp(source_city_id) != faction_id:
		return {}
	result["turn_number"] = maxi(0, int(result.get("turn_number", 0)))
	result["faction_id"] = faction_id
	result["faction_label"] = str(result.get("faction_label", _format_faction_label(faction_id)))
	result["personality_profile"] = str(result.get("personality_profile", _get_enemy_faction_personality_profile_id(faction_id)))
	result["goal_id"] = str(result.get("goal_id", _get_enemy_faction_goal_id(faction_id)))
	result["goal_label"] = str(result.get("goal_label", _get_enemy_faction_goal_label(faction_id)))
	result["pressure_type"] = _normalize_enemy_pressure_type_mvp(str(result.get("pressure_type", _get_enemy_faction_goal_pressure(faction_id))), faction_id)
	result["target_city_id"] = plan_target_city_id
	result["target_city_label"] = str(result.get("target_city_label", _format_city_name_by_id(plan_target_city_id, plan_target_city_id)))
	result["source_city_id"] = source_city_id
	result["source_city_label"] = str(result.get("source_city_label", _format_city_name_by_id(source_city_id, source_city_id)))
	result["effect"] = "display_scoring_only"
	return result


func _get_enemy_pressure_plan_for_scoring_mvp() -> Dictionary:
	var plan := _normalize_enemy_pressure_plan_result_mvp(_player_state.get("last_enemy_pressure_plan_result", {}))
	if plan.is_empty():
		return {}
	var current_turn := maxi(1, int(_player_state.get("turn_number", 1)))
	if int(plan.get("turn_number", 0)) != current_turn:
		return {}
	return plan


func _is_enemy_pressure_plan_target_city_mvp(faction_id: String, city_id: String) -> bool:
	var plan := _get_enemy_pressure_plan_for_scoring_mvp()
	if plan.is_empty() or faction_id.is_empty() or city_id.is_empty():
		return false
	return str(plan.get("faction_id", "")) == faction_id and str(plan.get("target_city_id", "")) == city_id


func _get_enemy_pressure_plan_score_bonus_mvp(faction_id: String, city_id: String, purpose: String) -> float:
	var plan := _get_enemy_pressure_plan_for_scoring_mvp()
	if plan.is_empty() or faction_id.is_empty() or str(plan.get("faction_id", "")) != faction_id:
		return 0.0
	var pressure_type := _normalize_enemy_pressure_type_mvp(str(plan.get("pressure_type", "")), faction_id)
	var plan_target_city_id := str(plan.get("target_city_id", ""))
	var source_city_id := str(plan.get("source_city_id", ""))
	if source_city_id.is_empty() or plan_target_city_id.is_empty():
		return 0.0
	if not _has_city_for_battle_context(source_city_id) or not _has_city_for_battle_context(plan_target_city_id):
		return 0.0
	if not city_id.is_empty() and not _has_city_for_battle_context(city_id):
		return 0.0
	var bonus := 0.0
	if not city_id.is_empty():
		if city_id == plan_target_city_id:
			bonus += 20.0
		elif city_id == source_city_id:
			bonus += 10.0
		elif not plan_target_city_id.is_empty() and (_get_city_neighbors_mvp(city_id).has(plan_target_city_id) or _get_city_neighbors_mvp(plan_target_city_id).has(city_id)):
			bonus += 6.0
	match purpose:
		"reinforcement":
			if pressure_type == "defensive":
				bonus += 8.0
		"strategic_diplomacy":
			if pressure_type == "diplomacy":
				bonus += 6.0
		"strategic_spy":
			if pressure_type == "spy":
				bonus += 6.0
		"invasion":
			if pressure_type == "invasion" or pressure_type == "military":
				bonus += 10.0
	var max_bonus := 20.0
	match purpose:
		"reinforcement":
			max_bonus = 24.0
		"strategic_diplomacy", "strategic_spy":
			max_bonus = 18.0
		"invasion":
			max_bonus = 24.0
	return clampf(bonus, 0.0, max_bonus)


func _get_safe_enemy_owner_faction_id_for_turn_mvp(city_id: String) -> String:
	if city_id.is_empty():
		return ""
	var marker_owner_id := ""
	var city_marker := _city_markers_by_id.get(city_id) as WorldMapCityMarker
	if city_marker != null:
		marker_owner_id = city_marker.owner_faction_id
	var hud_owner_id := ""
	var city_data := _get_city_hud_entry(city_id)
	if not city_data.is_empty():
		hud_owner_id = _get_city_owner_faction_id(city_data)
	if not marker_owner_id.is_empty() and not hud_owner_id.is_empty() and marker_owner_id != hud_owner_id:
		print("[ENEMY_FACTION_TURN_SKIP] city=%s reason=owner_mismatch marker=%s hud=%s" % [
			city_id,
			marker_owner_id,
			hud_owner_id,
		])
		return ""
	var owner_id := marker_owner_id if not marker_owner_id.is_empty() else hud_owner_id
	if owner_id.is_empty() or owner_id == PLAYER_FACTION_ID:
		return ""
	return owner_id


func _is_enemy_frontline_city_for_faction(city_id: String, faction_id: String) -> bool:
	if city_id.is_empty() or faction_id.is_empty():
		return false
	if _get_safe_enemy_owner_faction_id_for_turn_mvp(city_id) != faction_id:
		return false
	for neighbor_id in _get_city_neighbors_mvp(city_id):
		if _is_city_owned_by_player_mvp(str(neighbor_id)):
			return true
	return false


func _find_enemy_frontline_city_for_faction(faction_id: String) -> String:
	var selected_enemy_city_id := ""
	var selected_troops := INF
	for city_id in _get_enemy_owned_city_ids_for_faction(faction_id):
		if not _is_enemy_frontline_city_for_faction(city_id, faction_id):
			continue
		var troops := float(_get_city_troops_for_battle_context(city_id))
		if selected_enemy_city_id.is_empty() or troops < selected_troops:
			selected_enemy_city_id = city_id
			selected_troops = troops
	return selected_enemy_city_id


func _pick_enemy_city_for_turn_action(faction_id: String) -> String:
	var owned_city_ids := _get_enemy_owned_city_ids_for_faction(faction_id)
	if owned_city_ids.is_empty():
		return ""
	var selected_enemy_city_id := str(owned_city_ids[0])
	var selected_score := _score_enemy_reinforcement_city_for_personality(faction_id, selected_enemy_city_id)
	for city_id in owned_city_ids:
		var score := _score_enemy_reinforcement_city_for_personality(faction_id, city_id)
		if score > selected_score:
			selected_enemy_city_id = city_id
			selected_score = score
	return selected_enemy_city_id


func _score_enemy_reinforcement_city_for_personality(faction_id: String, city_id: String) -> int:
	if faction_id.is_empty() or faction_id == PLAYER_FACTION_ID or city_id.is_empty():
		return -1
	if _get_safe_enemy_owner_faction_id_for_turn_mvp(city_id) != faction_id:
		return -1
	var troops := _get_city_troops_for_battle_context(city_id)
	var low_troop_score := clampi(3000 - troops, 0, 3000)
	var reinforce_weight := _get_enemy_faction_behavior_weight(faction_id, "reinforce_weight", 1.0)
	var frontline_weight := _get_enemy_faction_behavior_weight(faction_id, "frontline_weight", 1.0)
	var goal_weight := _get_enemy_faction_goal_weight(faction_id)
	var goal_pressure := _get_enemy_faction_goal_pressure(faction_id)
	var score := int(round(float(low_troop_score) * reinforce_weight))
	if _is_enemy_frontline_city_for_faction(city_id, faction_id):
		score += int(round(450.0 * frontline_weight))
		if goal_pressure == "military" or goal_pressure == "invasion" or goal_pressure == "aggressive":
			score += int(round(80.0 * goal_weight))
	if _is_city_preferred_by_enemy_goal(faction_id, city_id):
		score += int(round(120.0 * goal_weight))
	elif _is_city_adjacent_to_enemy_goal_target(faction_id, city_id):
		score += int(round(55.0 * goal_weight))
	if goal_pressure == "defensive" or goal_pressure == "trade_defensive":
		score += int(round(float(clampi(1800 - troops, 0, 1800)) * 0.03 * goal_weight))
	score += int(round(_get_enemy_pressure_plan_score_bonus_mvp(faction_id, city_id, "reinforcement")))
	return score


func _get_enemy_faction_chancellor_id(faction_id: String) -> String:
	if faction_id.is_empty() or faction_id == PLAYER_FACTION_ID:
		return ""
	_ensure_faction_chancellors_seeded()
	var chancellors: Variant = _player_state.get("faction_chancellors", {})
	if not chancellors is Dictionary:
		return ""
	var hero_id := str((chancellors as Dictionary).get(faction_id, ""))
	if _is_valid_faction_chancellor_candidate(faction_id, hero_id):
		return hero_id
	return ""


func _apply_enemy_city_reinforcement_mvp(faction_id: String, city_id: String) -> Dictionary:
	if faction_id.is_empty() or faction_id == PLAYER_FACTION_ID or city_id.is_empty():
		return {}
	if not _has_city_for_battle_context(city_id):
		return {}
	if _get_safe_enemy_owner_faction_id_for_turn_mvp(city_id) != faction_id:
		return {}
	var before_troops := _get_city_troops_for_battle_context(city_id)
	var is_frontline := _is_enemy_frontline_city_for_faction(city_id, faction_id)
	var chancellor_id := _get_enemy_faction_chancellor_id(faction_id)
	var chancellor_bonus := ENEMY_FACTION_TURN_REINFORCE_CHANCELLOR_BONUS if not chancellor_id.is_empty() else 0
	var delta := ENEMY_FACTION_TURN_REINFORCE_BASE
	if is_frontline:
		delta += ENEMY_FACTION_TURN_REINFORCE_FRONTLINE_BONUS
	delta += chancellor_bonus
	delta = clampi(delta, 0, ENEMY_FACTION_TURN_REINFORCE_MAX)
	var after_troops := _clamp_invasion_troops(before_troops + delta)
	_set_city_runtime_troops(city_id, after_troops)
	var after_actual := _get_city_troops_for_battle_context(city_id)
	return {
		"faction_id": faction_id,
		"faction_label": _format_faction_label(faction_id),
		"personality_profile": _get_enemy_faction_personality_profile_id(faction_id),
		"personality_label": _get_enemy_faction_personality_label(faction_id),
		"goal_id": _get_enemy_faction_goal_id(faction_id),
		"goal_label": _get_enemy_faction_goal_label(faction_id),
		"goal_pressure": _get_enemy_faction_goal_pressure(faction_id),
		"action_id": "reinforce_city",
		"city_id": city_id,
		"city_name": _format_city_name_by_id(city_id, city_id),
		"before_troops": before_troops,
		"after_troops": after_actual,
		"delta": after_actual - before_troops,
		"reason": "frontline_defense" if is_frontline else "garrison_recovery",
		"chancellor_id": chancellor_id,
		"chancellor_bonus": chancellor_bonus,
	}


func _process_enemy_strategic_follow_up_action_mvp(processed_factions: Array[String]) -> Dictionary:
	if _has_pending_invasion_event_mvp() or not _get_pending_battle_context_mvp().is_empty():
		return {}
	var faction_ids := processed_factions.duplicate()
	if faction_ids.is_empty():
		faction_ids = _get_enemy_faction_ids_for_turn_mvp()
	var diplomacy_candidates := _get_enemy_diplomacy_follow_up_candidates_mvp(faction_ids)
	var spy_candidates := _get_enemy_spy_pressure_follow_up_candidates_mvp(faction_ids)
	if diplomacy_candidates.is_empty() and spy_candidates.is_empty():
		return {}
	if diplomacy_candidates.is_empty():
		return _build_enemy_spy_pressure_follow_up_result_mvp(spy_candidates[0])
	if spy_candidates.is_empty():
		return _apply_enemy_diplomacy_follow_up_mvp(diplomacy_candidates[0])
	var best_diplomacy := diplomacy_candidates[0]
	var best_spy := spy_candidates[0]
	if int(best_spy.get("selection_score", 0)) > int(best_diplomacy.get("selection_score", 0)):
		return _build_enemy_spy_pressure_follow_up_result_mvp(best_spy)
	return _apply_enemy_diplomacy_follow_up_mvp(best_diplomacy)


func _get_enemy_diplomacy_follow_up_candidates_mvp(faction_ids: Array[String]) -> Array[Dictionary]:
	var unique_factions: Array[String] = []
	for faction_id_variant in faction_ids:
		var faction_id := str(faction_id_variant)
		if faction_id.is_empty() or faction_id == PLAYER_FACTION_ID:
			continue
		if _get_enemy_owned_city_ids_for_faction(faction_id).is_empty():
			continue
		if not unique_factions.has(faction_id):
			unique_factions.append(faction_id)
	unique_factions.sort()
	var candidates: Array[Dictionary] = []
	for i in range(unique_factions.size()):
		for j in range(i + 1, unique_factions.size()):
			var faction_a := str(unique_factions[i])
			var faction_b := str(unique_factions[j])
			var relation := _ensure_faction_relation_entry(faction_a, faction_b)
			var status := _normalize_faction_relation_status(str(relation.get("status", FACTION_RELATION_STATUS["NEUTRAL"])))
			candidates.append({
				"faction_a": faction_a,
				"faction_b": faction_b,
				"score": clampi(int(relation.get("score", DIPLOMACY_DEFAULT_SCORE)), DIPLOMACY_SCORE_MIN, DIPLOMACY_SCORE_MAX),
				"status": status,
				"selection_score": _score_enemy_diplomacy_follow_up_candidate_mvp(faction_a, faction_b, relation),
			})
	candidates.sort_custom(Callable(self, "_sort_enemy_diplomacy_follow_up_candidates_mvp"))
	return candidates


func _score_enemy_diplomacy_follow_up_candidate_mvp(faction_a: String, faction_b: String, relation: Dictionary) -> int:
	var relation_score: int = clampi(int(relation.get("score", DIPLOMACY_DEFAULT_SCORE)), DIPLOMACY_SCORE_MIN, DIPLOMACY_SCORE_MAX)
	var score_gap: int = abs(relation_score - DIPLOMACY_DEFAULT_SCORE)
	var diplomacy_weight: float = (
		_get_enemy_faction_behavior_weight(faction_a, "diplomacy_weight", 1.0) +
		_get_enemy_faction_behavior_weight(faction_b, "diplomacy_weight", 1.0)
	) * 0.5
	var goal_bonus := 0
	for faction_id in [faction_a, faction_b]:
		var goal_pressure := _get_enemy_faction_goal_pressure(str(faction_id))
		if goal_pressure == "diplomacy" or goal_pressure == "defensive" or goal_pressure == "trade_defensive":
			goal_bonus += int(round(8.0 * _get_enemy_faction_goal_weight(str(faction_id))))
	var pressure_plan_bonus := int(round(
		_get_enemy_pressure_plan_score_bonus_mvp(faction_a, "", "strategic_diplomacy") +
		_get_enemy_pressure_plan_score_bonus_mvp(faction_b, "", "strategic_diplomacy")
	))
	return int(round(100.0 * diplomacy_weight)) + score_gap * 2 + goal_bonus + pressure_plan_bonus


func _sort_enemy_diplomacy_follow_up_candidates_mvp(left: Dictionary, right: Dictionary) -> bool:
	var left_selection_score := int(left.get("selection_score", 0))
	var right_selection_score := int(right.get("selection_score", 0))
	if left_selection_score != right_selection_score:
		return left_selection_score > right_selection_score
	var left_score_gap: int = abs(int(left.get("score", DIPLOMACY_DEFAULT_SCORE)) - DIPLOMACY_DEFAULT_SCORE)
	var right_score_gap: int = abs(int(right.get("score", DIPLOMACY_DEFAULT_SCORE)) - DIPLOMACY_DEFAULT_SCORE)
	if left_score_gap == right_score_gap:
		var left_key := "%s:%s" % [str(left.get("faction_a", "")), str(left.get("faction_b", ""))]
		var right_key := "%s:%s" % [str(right.get("faction_a", "")), str(right.get("faction_b", ""))]
		return left_key < right_key
	return left_score_gap > right_score_gap


func _apply_enemy_diplomacy_follow_up_mvp(candidate: Dictionary) -> Dictionary:
	var faction_a := str(candidate.get("faction_a", ""))
	var faction_b := str(candidate.get("faction_b", ""))
	if faction_a.is_empty() or faction_b.is_empty() or faction_a == PLAYER_FACTION_ID or faction_b == PLAYER_FACTION_ID or faction_a == faction_b:
		return {}
	var before_score := _get_faction_relation_score(faction_a, faction_b)
	var drift := ENEMY_STRATEGIC_DIPLOMACY_DRIFT
	var mood := "contact"
	if before_score <= 40:
		drift = -ENEMY_STRATEGIC_DIPLOMACY_DRIFT
		mood = "tension"
	elif before_score < 60 and maxi(1, int(_player_state.get("turn_number", 1))) % 2 == 0:
		drift = -ENEMY_STRATEGIC_DIPLOMACY_DRIFT
		mood = "tension"
	var relation_result := _adjust_faction_relation_score(faction_a, faction_b, drift, "enemy_strategic_diplomacy")
	return {
		"action_id": "enemy_diplomacy_follow_up",
		"kind": mood,
		"personality_profile": _get_enemy_faction_personality_profile_id(faction_a),
		"personality_label": _get_enemy_faction_personality_label(faction_a),
		"goal_id": _get_enemy_faction_goal_id(faction_a),
		"goal_label": _get_enemy_faction_goal_label(faction_a),
		"goal_pressure": _get_enemy_faction_goal_pressure(faction_a),
		"faction_a": faction_a,
		"faction_b": faction_b,
		"faction_a_label": _format_faction_label(faction_a),
		"faction_b_label": _format_faction_label(faction_b),
		"before_score": before_score,
		"after_score": int(relation_result.get("after_score", before_score)),
		"delta": int(relation_result.get("delta", 0)),
		"status": str(relation_result.get("status", FACTION_RELATION_STATUS["NEUTRAL"])),
		"turn": maxi(1, int(_player_state.get("turn_number", 1))),
	}


func _get_enemy_spy_pressure_follow_up_candidates_mvp(faction_ids: Array[String]) -> Array[Dictionary]:
	var allowed_factions := {}
	for faction_id_variant in faction_ids:
		var faction_id := str(faction_id_variant)
		if not faction_id.is_empty() and faction_id != PLAYER_FACTION_ID:
			allowed_factions[faction_id] = true
	var candidates: Array[Dictionary] = []
	for attacker_city_id in _get_worldmap_city_ids_for_enemy_turn_mvp():
		var attacker_faction_id := _get_safe_enemy_owner_faction_id_for_turn_mvp(attacker_city_id)
		if attacker_faction_id.is_empty() or not allowed_factions.has(attacker_faction_id):
			continue
		if not _has_city_for_battle_context(attacker_city_id) or not _is_city_owner_consistent_for_enemy_invasion_mvp(attacker_city_id):
			continue
		for defender_city_id_variant in _get_city_neighbors_mvp(attacker_city_id):
			var target_city_id := str(defender_city_id_variant)
			if not _has_city_for_battle_context(target_city_id):
				continue
			if not _is_city_owner_consistent_for_enemy_invasion_mvp(target_city_id) or not _is_city_owned_by_player_mvp(target_city_id):
				continue
			candidates.append({
				"faction_id": attacker_faction_id,
				"attacker_city_id": attacker_city_id,
				"target_city_id": target_city_id,
				"attacker_troops": _get_city_troops_for_enemy_invasion_mvp(attacker_city_id),
				"selection_score": _score_enemy_spy_pressure_follow_up_candidate_mvp(attacker_faction_id, attacker_city_id, target_city_id),
			})
	candidates.sort_custom(Callable(self, "_sort_enemy_spy_pressure_follow_up_candidates_mvp"))
	return candidates


func _score_enemy_spy_pressure_follow_up_candidate_mvp(faction_id: String, attacker_city_id: String, target_city_id: String) -> int:
	var spy_weight := _get_enemy_faction_behavior_weight(faction_id, "spy_weight", 1.0)
	var attacker_troops := mini(_get_city_troops_for_enemy_invasion_mvp(attacker_city_id), 2000)
	var frontline_bonus := 6 if _is_player_frontline_city_for_enemy_invasion_mvp(target_city_id) else 0
	var goal_weight := _get_enemy_faction_goal_weight(faction_id)
	var goal_pressure := _get_enemy_faction_goal_pressure(faction_id)
	var goal_bonus := 0
	if goal_pressure == "spy":
		goal_bonus += int(round(10.0 * goal_weight))
	if _is_city_preferred_by_enemy_goal(faction_id, target_city_id):
		goal_bonus += int(round(8.0 * goal_weight))
	elif _is_city_adjacent_to_enemy_goal_target(faction_id, target_city_id):
		goal_bonus += int(round(4.0 * goal_weight))
	var pressure_plan_bonus := int(round(
		_get_enemy_pressure_plan_score_bonus_mvp(faction_id, target_city_id, "strategic_spy") +
		_get_enemy_pressure_plan_score_bonus_mvp(faction_id, attacker_city_id, "strategic_spy") * 0.5
	))
	return int(round(82.0 * spy_weight)) + floori(float(attacker_troops) / 150.0) + frontline_bonus + goal_bonus + pressure_plan_bonus


func _sort_enemy_spy_pressure_follow_up_candidates_mvp(left: Dictionary, right: Dictionary) -> bool:
	var left_selection_score := int(left.get("selection_score", 0))
	var right_selection_score := int(right.get("selection_score", 0))
	if left_selection_score != right_selection_score:
		return left_selection_score > right_selection_score
	var left_troops := int(left.get("attacker_troops", 0))
	var right_troops := int(right.get("attacker_troops", 0))
	if left_troops == right_troops:
		var left_key := "%s:%s" % [str(left.get("attacker_city_id", "")), str(left.get("target_city_id", ""))]
		var right_key := "%s:%s" % [str(right.get("attacker_city_id", "")), str(right.get("target_city_id", ""))]
		return left_key < right_key
	return left_troops > right_troops


func _build_enemy_spy_pressure_follow_up_result_mvp(candidate: Dictionary) -> Dictionary:
	var faction_id := str(candidate.get("faction_id", ""))
	var attacker_city_id := str(candidate.get("attacker_city_id", ""))
	var target_city_id := str(candidate.get("target_city_id", ""))
	if faction_id.is_empty() or attacker_city_id.is_empty() or target_city_id.is_empty():
		return {}
	return {
		"action_id": "enemy_spy_pressure",
		"kind": "recon",
		"personality_profile": _get_enemy_faction_personality_profile_id(faction_id),
		"personality_label": _get_enemy_faction_personality_label(faction_id),
		"goal_id": _get_enemy_faction_goal_id(faction_id),
		"goal_label": _get_enemy_faction_goal_label(faction_id),
		"goal_pressure": _get_enemy_faction_goal_pressure(faction_id),
		"faction_id": faction_id,
		"faction_label": _format_faction_label(faction_id),
		"attacker_city_id": attacker_city_id,
		"attacker_city_name": _format_city_name_by_id(attacker_city_id, attacker_city_id),
		"target_city_id": target_city_id,
		"target_city_name": _format_city_name_by_id(target_city_id, target_city_id),
		"effect": "display_only",
		"turn": maxi(1, int(_player_state.get("turn_number", 1))),
	}


func _format_enemy_strategic_action_summary(action: Dictionary) -> String:
	return _format_enemy_strategic_action_hint_mvp(action)


func _format_enemy_strategic_action_hint_mvp(action: Dictionary) -> String:
	match str(action.get("action_id", "")):
		"enemy_diplomacy_follow_up":
			return "적 전략 행동: 외교 압박"
		"enemy_spy_pressure":
			return "적 전략 행동: 첩보 압박"
		_:
			return "전략 움직임"


func _normalize_enemy_strategic_action_for_display(raw_action: Variant) -> Dictionary:
	if not raw_action is Dictionary:
		return {}
	var action := (raw_action as Dictionary).duplicate(true)
	match str(action.get("action_id", "")):
		"enemy_diplomacy_follow_up":
			var faction_a := str(action.get("faction_a", ""))
			var faction_b := str(action.get("faction_b", ""))
			if faction_a.is_empty() or faction_b.is_empty() or faction_a == PLAYER_FACTION_ID or faction_b == PLAYER_FACTION_ID or faction_a == faction_b:
				return {}
			action["kind"] = "tension" if str(action.get("kind", "")) == "tension" else "contact"
			action["personality_profile"] = str(action.get("personality_profile", _get_enemy_faction_personality_profile_id(faction_a)))
			action["personality_label"] = str(action.get("personality_label", _get_enemy_faction_personality_label(faction_a)))
			action["goal_id"] = str(action.get("goal_id", _get_enemy_faction_goal_id(faction_a)))
			action["goal_label"] = str(action.get("goal_label", _get_enemy_faction_goal_label(faction_a)))
			action["goal_pressure"] = str(action.get("goal_pressure", _get_enemy_faction_goal_pressure(faction_a)))
			action["faction_a_label"] = str(action.get("faction_a_label", _format_faction_label(faction_a)))
			action["faction_b_label"] = str(action.get("faction_b_label", _format_faction_label(faction_b)))
			action["before_score"] = clampi(int(action.get("before_score", DIPLOMACY_DEFAULT_SCORE)), DIPLOMACY_SCORE_MIN, DIPLOMACY_SCORE_MAX)
			action["after_score"] = clampi(int(action.get("after_score", action["before_score"])), DIPLOMACY_SCORE_MIN, DIPLOMACY_SCORE_MAX)
			action["delta"] = int(action.get("delta", int(action["after_score"]) - int(action["before_score"])))
			action["status"] = _normalize_faction_relation_status(str(action.get("status", FACTION_RELATION_STATUS["NEUTRAL"])))
		"enemy_spy_pressure":
			var faction_id := str(action.get("faction_id", ""))
			var attacker_city_id := str(action.get("attacker_city_id", ""))
			var target_city_id := str(action.get("target_city_id", ""))
			if faction_id.is_empty() or faction_id == PLAYER_FACTION_ID or attacker_city_id.is_empty() or target_city_id.is_empty():
				return {}
			action["kind"] = "recon"
			action["personality_profile"] = str(action.get("personality_profile", _get_enemy_faction_personality_profile_id(faction_id)))
			action["personality_label"] = str(action.get("personality_label", _get_enemy_faction_personality_label(faction_id)))
			action["goal_id"] = str(action.get("goal_id", _get_enemy_faction_goal_id(faction_id)))
			action["goal_label"] = str(action.get("goal_label", _get_enemy_faction_goal_label(faction_id)))
			action["goal_pressure"] = str(action.get("goal_pressure", _get_enemy_faction_goal_pressure(faction_id)))
			action["effect"] = "display_only"
			action["faction_label"] = str(action.get("faction_label", _format_faction_label(faction_id)))
			action["attacker_city_name"] = str(action.get("attacker_city_name", _format_city_name_by_id(attacker_city_id, attacker_city_id)))
			action["target_city_name"] = str(action.get("target_city_name", _format_city_name_by_id(target_city_id, target_city_id)))
		_:
			return {}
	action["turn"] = maxi(0, int(action.get("turn", _player_state.get("turn_number", 0))))
	return action


func _normalize_enemy_strategic_actions_for_display(raw_actions: Variant) -> Array[Dictionary]:
	var normalized: Array[Dictionary] = []
	if not raw_actions is Array:
		return normalized
	for action_variant in raw_actions:
		var action := _normalize_enemy_strategic_action_for_display(action_variant)
		if action.is_empty():
			continue
		normalized.append(action)
		break
	return normalized


func _normalize_enemy_faction_turn_result_display(raw_result: Variant) -> Dictionary:
	if not raw_result is Dictionary:
		return {}
	var result := (raw_result as Dictionary).duplicate(true)
	if not result.has("actions") or not (result["actions"] is Array):
		result["actions"] = []
	result["pressure_plan"] = _normalize_enemy_pressure_plan_result_mvp(result.get("pressure_plan", {}))
	result["strategic_actions"] = _normalize_enemy_strategic_actions_for_display(result.get("strategic_actions", []))
	if not result.has("processed_factions") or not (result["processed_factions"] is Array):
		result["processed_factions"] = []
	if not result.has("pending_invasion_event") or not (result["pending_invasion_event"] is Dictionary):
		result["pending_invasion_event"] = {}
	result["turn"] = maxi(0, int(result.get("turn", _player_state.get("turn_number", 0))))
	result["summary"] = _build_enemy_faction_turn_summary(result)
	return result


func _attach_enemy_invasion_event_to_enemy_turn_result(invasion_event: Dictionary) -> void:
	_ensure_worldmap_runtime_state_defaults()
	var result: Variant = _player_state.get("last_enemy_faction_turn_result", {})
	var enemy_turn_result := _normalize_enemy_faction_turn_result_display(result)
	if enemy_turn_result.is_empty():
		enemy_turn_result = {
			"turn": maxi(1, int(_player_state.get("turn_number", 1))),
			"phase": TURN_PHASE_ENEMY,
			"processed_factions": [],
			"actions": [],
			"pressure_plan": {},
			"strategic_actions": [],
		}
	enemy_turn_result["pending_invasion_created"] = not invasion_event.is_empty()
	if not invasion_event.is_empty():
		enemy_turn_result["pending_invasion_event"] = invasion_event.duplicate(true)
		enemy_turn_result["pending_invasion_already_active"] = false
	else:
		enemy_turn_result["pending_invasion_event"] = {}
		enemy_turn_result["pending_invasion_already_active"] = _has_pending_invasion_event_mvp()
	enemy_turn_result["summary"] = _build_enemy_faction_turn_summary(enemy_turn_result)
	_player_state["last_enemy_faction_turn_result"] = enemy_turn_result.duplicate(true)


func _format_enemy_pending_invasion_hint_mvp(raw_event: Variant, prefix: String = "침공 대기") -> String:
	if not raw_event is Dictionary:
		return ""
	var event := raw_event as Dictionary
	if event.is_empty():
		return ""
	var attacker_city_id := str(event.get("attacker_city_id", ""))
	var defender_city_id := str(event.get("defender_city_id", ""))
	if attacker_city_id.is_empty() or defender_city_id.is_empty():
		return ""
	var attacker_label := _format_city_name_by_id(attacker_city_id, "적 도시")
	var defender_label := _format_city_name_by_id(defender_city_id, "아군 도시")
	return "%s: %s → %s" % [prefix, attacker_label, defender_label]


func _build_enemy_faction_turn_summary(result: Dictionary) -> String:
	if bool(result.get("pending_battle_already_active", false)):
		return "이번 턴 적 행동 보류 · 전투 처리 대기"
	if bool(result.get("pending_invasion_already_active", false)) and not bool(result.get("pending_invasion_created", false)):
		return "이번 턴 적 행동 보류 · 침공 이벤트 처리 대기"
	var pressure_plan := _normalize_enemy_pressure_plan_result_mvp(result.get("pressure_plan", {}))
	var result_turn := maxi(0, int(result.get("turn", 0)))
	var pressure_plan_part := _format_enemy_pressure_plan_hint_mvp(pressure_plan, result_turn, false)
	var actions: Variant = result.get("actions", [])
	var reinforce_count := 0
	if actions is Array:
		for action_variant in actions:
			if not action_variant is Dictionary:
				continue
			var action := action_variant as Dictionary
			if str(action.get("action_id", "")) != "reinforce_city" or int(action.get("delta", 0)) <= 0:
				continue
			reinforce_count += 1
	var strategic_actions: Variant = result.get("strategic_actions", [])
	var strategic_count := 0
	if strategic_actions is Array:
		strategic_count = (strategic_actions as Array).size()
	var invasion_summary := "침공 대기 없음"
	var invasion_event: Variant = result.get("pending_invasion_event", {})
	if bool(result.get("pending_invasion_created", false)) and invasion_event is Dictionary:
		var pending_hint := _format_enemy_pending_invasion_hint_mvp(invasion_event)
		if not pending_hint.is_empty():
			invasion_summary = pending_hint
	var total_action_count := reinforce_count + strategic_count
	var count_parts: Array[String] = []
	if reinforce_count > 0:
		count_parts.append("보강 %d건" % reinforce_count)
	if strategic_count > 0:
		count_parts.append("전략 %d건" % strategic_count)
	var combined_parts: Array[String] = []
	if not pressure_plan_part.is_empty():
		combined_parts.append(pressure_plan_part)
	if not count_parts.is_empty():
		combined_parts.append("이번 턴 적 행동: %s" % ", ".join(count_parts))
	combined_parts.append(invasion_summary)
	if total_action_count <= 0:
		if pressure_plan_part.is_empty():
			combined_parts.push_front("이번 턴 적 행동 없음")
	return _clamp_enemy_hint_line_mvp(" · ".join(combined_parts), 72)


func _format_enemy_faction_turn_result_hint(raw_result: Variant) -> String:
	if not raw_result is Dictionary:
		return ""
	var result := raw_result as Dictionary
	if result.is_empty():
		return ""
	var lines: Array[String] = ["이번 턴 적 행동"]
	var actions: Variant = result.get("actions", [])
	var strategic_actions: Variant = result.get("strategic_actions", [])
	var pressure_plan := _normalize_enemy_pressure_plan_result_mvp(result.get("pressure_plan", {}))
	var result_turn := maxi(0, int(result.get("turn", 0)))
	var pressure_plan_text := _format_enemy_pressure_plan_hint_mvp(pressure_plan, result_turn, false)
	if not pressure_plan_text.is_empty():
		_append_unique_enemy_hint_line_mvp(lines, pressure_plan_text)
	var reinforce_count := 0
	if actions is Array and not (actions as Array).is_empty():
		for action_variant in actions:
			if not action_variant is Dictionary:
				continue
			var action := action_variant as Dictionary
			if str(action.get("action_id", "")) != "reinforce_city":
				continue
			if int(action.get("delta", 0)) <= 0:
				continue
			reinforce_count += 1
	var strategic_count := 0
	var strategic_hint_line := ""
	if strategic_actions is Array and not (strategic_actions as Array).is_empty():
		for strategic_variant in strategic_actions:
			if not strategic_variant is Dictionary:
				continue
			var strategic_line := _format_enemy_strategic_action_hint_mvp(strategic_variant as Dictionary)
			if not strategic_line.is_empty():
				strategic_hint_line = strategic_line
				strategic_count += 1
			break
	var count_parts: Array[String] = []
	if reinforce_count > 0:
		count_parts.append("보강 %d건" % reinforce_count)
	if strategic_count > 0:
		count_parts.append("전략 %d건" % strategic_count)
	if not count_parts.is_empty():
		_append_unique_enemy_hint_line_mvp(lines, "이번 턴 적 행동: %s" % ", ".join(count_parts))
	elif pressure_plan_text.is_empty():
		_append_unique_enemy_hint_line_mvp(lines, "행동 없음")
	if not strategic_hint_line.is_empty():
		_append_unique_enemy_hint_line_mvp(lines, strategic_hint_line)
	var invasion_event: Variant = result.get("pending_invasion_event", {})
	if bool(result.get("pending_invasion_created", false)) and invasion_event is Dictionary:
		_append_unique_enemy_hint_line_mvp(lines, _format_enemy_pending_invasion_hint_mvp(invasion_event))
	else:
		_append_unique_enemy_hint_line_mvp(lines, "침공 대기: 없음")
	return "\n".join(lines)


func _get_enemy_invasion_pairs_mvp() -> Array[Dictionary]:
	var pairs: Array[Dictionary] = []
	for attacker_city_id_variant in _city_markers_by_id.keys():
		var attacker_city_id := str(attacker_city_id_variant)
		for defender_city_id_variant in _get_city_neighbors_mvp(attacker_city_id):
			var defender_city_id := str(defender_city_id_variant)
			if _is_enemy_invasion_pair_eligible_mvp(attacker_city_id, defender_city_id):
				pairs.append({
					"attacker_city_id": attacker_city_id,
					"defender_city_id": defender_city_id,
					"score": _score_enemy_invasion_pair_mvp(attacker_city_id, defender_city_id),
				})
	pairs.sort_custom(Callable(self, "_sort_enemy_invasion_pairs_mvp"))
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


func _is_city_owner_consistent_for_enemy_invasion_mvp(city_id: String) -> bool:
	if city_id.is_empty():
		return false
	var city_marker := _city_markers_by_id.get(city_id) as WorldMapCityMarker
	var marker_owner_id := ""
	if city_marker != null:
		marker_owner_id = city_marker.owner_faction_id
	var city_data := _get_city_hud_entry(city_id)
	var hud_owner_id := ""
	if not city_data.is_empty():
		hud_owner_id = _get_city_owner_faction_id(city_data)
	if marker_owner_id.is_empty() or hud_owner_id.is_empty():
		return not marker_owner_id.is_empty() or not hud_owner_id.is_empty()
	if marker_owner_id != hud_owner_id:
		print("[ENEMY_INVASION_SKIP] city=%s reason=owner_mismatch marker=%s hud=%s" % [
			city_id,
			marker_owner_id,
			hud_owner_id,
		])
		return false
	return true


func _is_enemy_invasion_pair_eligible_mvp(attacker_city_id: String, defender_city_id: String) -> bool:
	if attacker_city_id.is_empty() or defender_city_id.is_empty() or attacker_city_id == defender_city_id:
		return false
	if not _has_city_for_battle_context(attacker_city_id) or not _has_city_for_battle_context(defender_city_id):
		return false
	if not _is_city_owner_consistent_for_enemy_invasion_mvp(attacker_city_id) or not _is_city_owner_consistent_for_enemy_invasion_mvp(defender_city_id):
		return false
	if not _is_city_owned_by_enemy_mvp(attacker_city_id) or not _is_city_owned_by_player_mvp(defender_city_id):
		return false
	if not _get_city_neighbors_mvp(attacker_city_id).has(defender_city_id):
		return false
	if _get_city_troops_for_enemy_invasion_mvp(attacker_city_id) < ENEMY_INVASION_MIN_ATTACKER_CITY_TROOPS:
		return false
	var event := {
		"type": "defense",
		"attacker_city_id": attacker_city_id,
		"defender_city_id": defender_city_id,
	}
	return bool(_validate_pending_invasion_event_for_battle_context(event).get("ok", false))


func _score_enemy_invasion_pair_mvp(attacker_city_id: String, defender_city_id: String) -> int:
	var attacker_troops := _get_city_troops_for_enemy_invasion_mvp(attacker_city_id)
	var defender_troops := _get_city_troops_for_battle_context(defender_city_id)
	var troop_edge := attacker_troops - defender_troops
	var score := mini(attacker_troops, 2000)
	score += clampi(troop_edge, -1000, 1000)
	score += 200 if _is_player_frontline_city_for_enemy_invasion_mvp(defender_city_id) else 0
	var attacker_faction_id := _get_safe_enemy_owner_faction_id_for_turn_mvp(attacker_city_id)
	var goal_weight := _get_enemy_faction_goal_weight(attacker_faction_id)
	var goal_pressure := _get_enemy_faction_goal_pressure(attacker_faction_id)
	if _is_city_preferred_by_enemy_goal(attacker_faction_id, defender_city_id):
		score += int(round(140.0 * goal_weight))
	elif _is_city_adjacent_to_enemy_goal_target(attacker_faction_id, defender_city_id):
		score += int(round(65.0 * goal_weight))
	if goal_pressure == "invasion" or goal_pressure == "aggressive" or goal_pressure == "military":
		score += int(round(70.0 * goal_weight))
	if score <= 0:
		return score
	score += int(round(
		_get_enemy_pressure_plan_score_bonus_mvp(attacker_faction_id, defender_city_id, "invasion") +
		_get_enemy_pressure_plan_score_bonus_mvp(attacker_faction_id, attacker_city_id, "invasion") * 0.5
	))
	var invasion_weight := _get_enemy_faction_behavior_weight(attacker_faction_id, "invasion_weight", 1.0)
	if score <= 0:
		return score
	var pressure_multiplier := 1.0 + ((goal_weight - 1.0) * 0.5) if goal_pressure == "invasion" or goal_pressure == "aggressive" or goal_pressure == "military" else 1.0
	return int(round(float(score) * invasion_weight * pressure_multiplier))


func _sort_enemy_invasion_pairs_mvp(left: Dictionary, right: Dictionary) -> bool:
	var left_score := int(left.get("score", 0))
	var right_score := int(right.get("score", 0))
	if left_score == right_score:
		var left_key := "%s:%s" % [str(left.get("attacker_city_id", "")), str(left.get("defender_city_id", ""))]
		var right_key := "%s:%s" % [str(right.get("attacker_city_id", "")), str(right.get("defender_city_id", ""))]
		return left_key < right_key
	return left_score > right_score


func _get_city_troops_for_enemy_invasion_mvp(city_id: String) -> int:
	if city_id.is_empty() or not _has_city_for_battle_context(city_id):
		return 0
	return _clamp_invasion_troops(_get_city_troops_for_battle_context(city_id))


func _is_player_frontline_city_for_enemy_invasion_mvp(city_id: String) -> bool:
	if not _is_city_owned_by_player_mvp(city_id):
		return false
	for neighbor_id in _get_city_neighbors_mvp(city_id):
		if _is_city_owned_by_enemy_mvp(str(neighbor_id)):
			return true
	return false


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
	if _worldmap_battle_entry_handoff_in_progress:
		_set_save_management_status("전투 화면 이동 중입니다.")
		_refresh_left_world_status_panel()
		return
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
	if _worldmap_battle_entry_handoff_in_progress:
		_set_save_management_status("전투 화면 이동 중입니다.")
		_refresh_left_world_status_panel()
		return
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
	if not _is_enemy_invasion_pair_eligible_mvp(attacker_city_id, defender_city_id):
		print("[WorldMap] Enemy invasion MVP event skipped: ineligible pair %s -> %s" % [attacker_city_id, defender_city_id])
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
		_pending_invasion_title_label.text = "침공 대기"
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
	if _worldmap_battle_entry_handoff_in_progress:
		_set_save_management_status("전투 화면 이동 중입니다.")
		_refresh_left_world_status_panel()
		return
	_open_defense_deployment_panel_from_pending_invasion("manual")


func _on_auto_defense_pressed() -> void:
	if _worldmap_battle_entry_handoff_in_progress:
		_set_save_management_status("전투 화면 이동 중입니다.")
		_refresh_left_world_status_panel()
		return
	_open_defense_deployment_panel_from_pending_invasion("auto")


func _start_pending_invasion_battle_scene_handoff(mode: String) -> void:
	if _worldmap_battle_entry_handoff_in_progress:
		_set_save_management_status("전투 화면 이동 중입니다.")
		_refresh_left_world_status_panel()
		return
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
	if _worldmap_battle_entry_handoff_in_progress:
		_set_save_management_status("전투 화면 이동 중입니다.")
		_refresh_left_world_status_panel()
		return
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
	if _worldmap_battle_entry_handoff_in_progress:
		_set_save_management_status("전투 화면 이동 중입니다.")
		_refresh_left_world_status_panel()
		return
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
	if _worldmap_battle_entry_handoff_in_progress:
		_set_save_management_status("전투 화면 이동 중입니다.")
		_refresh_left_world_status_panel()
		return
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
	var source_city_id := str(handoff_context.get("attacker_city_id", handoff_context.get("attacker_source_city_id", "")))
	var target_city_id := str(handoff_context.get("defender_city_id", handoff_context.get("defender_source_city_id", "")))
	_start_worldmap_battle_entry_camera_handoff(source_city_id, target_city_id, Callable(self, "_change_scene_to_battle_with_context").bind(handoff_context))


func _change_scene_to_battle_with_context(handoff_context: Dictionary) -> void:
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


func _get_worldmap_city_visual_position(city_id: String) -> Variant:
	if city_id.is_empty():
		return null
	var city_marker := _city_markers_by_id.get(city_id) as WorldMapCityMarker
	if city_marker != null:
		return city_marker.global_position
	var city_data := _get_city_hud_entry(city_id)
	if city_data.is_empty():
		return null
	var position_value: Variant = city_data.get("position", city_data.get("world_position", city_data.get("map_position", city_data.get("web_seed_position", null))))
	if position_value is Vector2:
		return position_value
	if position_value is Dictionary:
		var position_dict := position_value as Dictionary
		return Vector2(float(position_dict.get("x", 0.0)), float(position_dict.get("y", 0.0)))
	if position_value is Array:
		var position_array := position_value as Array
		if position_array.size() >= 2:
			return Vector2(float(position_array[0]), float(position_array[1]))
	return null


func _build_worldmap_battle_entry_focus(source_city_id: String, target_city_id: String) -> Dictionary:
	var source_position_variant: Variant = _get_worldmap_city_visual_position(source_city_id)
	var target_position_variant: Variant = _get_worldmap_city_visual_position(target_city_id)
	if target_position_variant is Vector2 and source_position_variant is Vector2:
		var source_position: Vector2 = source_position_variant
		var target_position: Vector2 = target_position_variant
		return {"position": source_position.lerp(target_position, 0.72)}
	if target_position_variant is Vector2:
		return {"position": target_position_variant}
	if source_position_variant is Vector2:
		return {"position": source_position_variant}
	return {}


func _start_worldmap_battle_entry_camera_handoff(source_city_id: String, target_city_id: String, continue_callable: Callable) -> void:
	if _worldmap_battle_entry_handoff_in_progress:
		return
	if not continue_callable.is_valid():
		return
	var focus := _build_worldmap_battle_entry_focus(source_city_id, target_city_id)
	if world_map_camera == null or focus.is_empty():
		continue_callable.call()
		return
	var focus_position: Variant = focus.get("position", null)
	if not focus_position is Vector2:
		continue_callable.call()
		return

	_worldmap_battle_entry_handoff_in_progress = true
	_worldmap_battle_entry_handoff_completed = false
	_worldmap_battle_entry_handoff_continue_callable = continue_callable
	var target_zoom_value := clampf(maxf(world_map_camera.zoom.x, WORLD_BATTLE_ENTRY_TARGET_ZOOM.x), WORLD_MAP_MIN_ZOOM, WORLD_MAP_MAX_ZOOM)
	_worldmap_battle_entry_handoff_target_zoom = Vector2(target_zoom_value, target_zoom_value)
	var target_position: Vector2 = focus_position
	_worldmap_battle_entry_handoff_target_position = _get_clamped_worldmap_camera_position_for_zoom(target_position, _worldmap_battle_entry_handoff_target_zoom)
	_set_save_management_status("전투 지역 접근 중 · %s → %s" % [
		_format_city_name_by_id(source_city_id, "출발 도시"),
		_format_city_name_by_id(target_city_id, "대상 도시"),
	])
	_refresh_left_world_status_panel()

	_worldmap_battle_entry_handoff_tween = create_tween()
	_worldmap_battle_entry_handoff_tween.set_parallel(true)
	_worldmap_battle_entry_handoff_tween.tween_property(world_map_camera, "position", _worldmap_battle_entry_handoff_target_position, WORLD_BATTLE_ENTRY_PAN_SEC).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_worldmap_battle_entry_handoff_tween.tween_property(world_map_camera, "zoom", _worldmap_battle_entry_handoff_target_zoom, WORLD_BATTLE_ENTRY_ZOOM_SEC).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_worldmap_battle_entry_handoff_tween.set_parallel(false)
	_worldmap_battle_entry_handoff_tween.tween_interval(WORLD_BATTLE_ENTRY_HOLD_SEC)
	_worldmap_battle_entry_handoff_tween.tween_callback(_complete_worldmap_battle_entry_camera_handoff)


func _complete_worldmap_battle_entry_camera_handoff() -> void:
	if _worldmap_battle_entry_handoff_completed:
		return
	_worldmap_battle_entry_handoff_completed = true
	var continue_callable := _worldmap_battle_entry_handoff_continue_callable
	_worldmap_battle_entry_handoff_in_progress = false
	_worldmap_battle_entry_handoff_continue_callable = Callable()
	_worldmap_battle_entry_handoff_tween = null
	if continue_callable.is_valid():
		continue_callable.call()


func _skip_worldmap_battle_entry_camera_handoff() -> void:
	if not _worldmap_battle_entry_handoff_in_progress:
		return
	if _worldmap_battle_entry_handoff_tween != null:
		_worldmap_battle_entry_handoff_tween.kill()
		_worldmap_battle_entry_handoff_tween = null
	if world_map_camera != null:
		world_map_camera.position = _worldmap_battle_entry_handoff_target_position
		if _worldmap_battle_entry_handoff_target_zoom != Vector2.ZERO:
			world_map_camera.zoom = _worldmap_battle_entry_handoff_target_zoom
		_clamp_camera_to_world()
	_complete_worldmap_battle_entry_camera_handoff()


func _is_worldmap_battle_entry_handoff_skip_event(event: InputEvent) -> bool:
	if event is InputEventKey:
		var key_event := event as InputEventKey
		return key_event.pressed and not key_event.echo and [KEY_SPACE, KEY_ENTER, KEY_KP_ENTER, KEY_ESCAPE].has(key_event.keycode)
	if event is InputEventMouseButton:
		var mouse_button_event := event as InputEventMouseButton
		return mouse_button_event.pressed and mouse_button_event.button_index == MOUSE_BUTTON_LEFT
	return false


func _get_clamped_worldmap_camera_position_for_zoom(target_position: Vector2, zoom: Vector2) -> Vector2:
	if _world_rect.size == Vector2.ZERO:
		return target_position
	var viewport_size := get_viewport_rect().size
	var safe_zoom := Vector2(maxf(zoom.x, 0.001), maxf(zoom.y, 0.001))
	var half_visible_size := viewport_size / (safe_zoom * 2.0)
	var min_center := _world_rect.position + half_visible_size - Vector2.ONE * WORLD_MAP_CLAMP_PADDING
	var max_center := _world_rect.end - half_visible_size + Vector2.ONE * WORLD_MAP_CLAMP_PADDING
	var clamped_x := target_position.x
	var clamped_y := target_position.y
	if min_center.x > max_center.x:
		clamped_x = _world_rect.get_center().x
	else:
		clamped_x = clampf(target_position.x, min_center.x, max_center.x)
	if min_center.y > max_center.y:
		clamped_y = _world_rect.get_center().y
	else:
		clamped_y = clampf(target_position.y, min_center.y, max_center.y)
	return Vector2(clamped_x, clamped_y)


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
	elif attacker_city_id.is_empty() or not _has_city_for_battle_context(attacker_city_id):
		var current_owner := _get_city_owner_id_for_battle_context(defender_city_id)
		result_summary = _build_invasion_result_summary(INVASION_RESULT_UNKNOWN, defender_city_id, attacker_city_id, defender_city_name, attacker_city_name, current_owner, current_owner, {}, "전투 결과 확인 필요", [
			"침공 도시 정보를 찾을 수 없어 소유권 변화는 적용하지 않았습니다.",
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


func _get_conscription_turn_add_multiplier() -> float:
	return 1.10 if _is_national_tech_completed("conscription_system") else 1.0


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
		var reason := ""
		var base_add := mini(available_before, 100)
		var added := mini(available_before, int(floor(float(base_add) * _get_conscription_turn_add_multiplier())))
		if not _is_city_tech_completed(city_id, "barracks"):
			reason = "barracks_required"
			added = 0
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
			"base_add": base_add,
			"multiplier": _get_conscription_turn_add_multiplier(),
			"reason": reason,
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


func _get_city_recruitment_summary(city_id: String) -> Dictionary:
	if city_id.is_empty() or _get_city_hud_entry(city_id).is_empty():
		return {}
	var loyalty := _get_city_loyalty_value(_get_city_hud_entry(city_id))
	var recruitment_limit := _get_recruitment_limit_by_loyalty(city_id)
	var sample_amount := 100
	var sample_cost := _calculate_recruitment_cost(sample_amount)
	var recruitment_check := _can_recruit_troops(city_id, sample_amount)
	var conscription_line := _format_city_conscription_ui_line(city_id)
	var recruitment_line := ""
	if recruitment_limit >= sample_amount:
		recruitment_line = "모병: 충성도 %d · 최대 %d명 / 즉시 +100 · 금전%d 식량%d" % [
			loyalty,
			recruitment_limit,
			int(sample_cost.get("gold", 0)),
			int(sample_cost.get("food", 0)),
		]
	else:
		recruitment_line = "모병: 충성도 %d · 모병 불가" % loyalty
	var reason := str(recruitment_check.get("reason", ""))
	return {
		"city_id": city_id,
		"title": "병사 충원",
		"conscription_line": conscription_line,
		"recruitment_line": recruitment_line,
		"button_text": "모병 100" if bool(recruitment_check.get("ok", false)) else "모병 불가",
		"button_enabled": bool(recruitment_check.get("ok", false)),
		"button_hint": _format_recruitment_failure_hint(reason) if not bool(recruitment_check.get("ok", false)) else "모병 100 · 금전100 식량50",
		"amount": sample_amount,
		"cost": sample_cost,
		"loyalty": loyalty,
		"loyalty_limit": recruitment_limit,
		"publicSupport": _get_city_public_support(city_id),
		"reason": reason,
	}


func _get_recruitment_summaries_for_ui() -> Dictionary:
	var summaries := {}
	for city_id_variant in _get_city_hud_data_for_ui().keys():
		var city_id := str(city_id_variant)
		var summary := _get_city_recruitment_summary(city_id)
		if not summary.is_empty():
			summaries[city_id] = summary
	return summaries


func _get_revolt_risk_summaries_for_ui() -> Dictionary:
	var summaries := {}
	for city_id_variant in _get_city_hud_data_for_ui().keys():
		var city_id := str(city_id_variant)
		var risk_result := _get_last_or_current_city_revolt_risk(city_id)
		var risk_id := str(risk_result.get("risk", REVOLT_RISK_STABLE))
		summaries[city_id] = {
			"city_id": city_id,
			"risk": risk_id,
			"risk_label": _format_selected_city_revolt_risk_label(risk_id),
		}
	return summaries


func _format_selected_city_revolt_risk_label(risk: String) -> String:
	match risk:
		REVOLT_RISK_DANGER:
			return "위험"
		REVOLT_RISK_WARNING:
			return "주의"
		REVOLT_RISK_STABLE:
			return "낮음"
		_:
			return "확인 필요"


func _format_city_conscription_ui_line(city_id: String) -> String:
	if not _is_city_tech_completed_for_display(city_id, "barracks"):
		return "징병: 병영 필요"
	var available := _get_city_conscription_available(city_id)
	if available <= 0:
		return "징병: 충원 한계 도달"
	var base_add := mini(available, 100)
	var expected := mini(available, int(floor(float(base_add) * _get_conscription_turn_add_multiplier())))
	if _is_national_tech_completed("conscription_system"):
		return "징병: 제도 적용 · 다음 턴 +%d" % expected
	return "징병: 다음 턴 +%d" % expected


func _is_city_tech_completed_for_display(city_id: String, tech_id: String) -> bool:
	var city_data := _get_city_hud_entry(city_id)
	var city_tech: Variant = city_data.get("city_tech", {})
	if not city_tech is Dictionary:
		return false
	var completed: Variant = (city_tech as Dictionary).get("completed", {})
	if not completed is Dictionary:
		return false
	var completed_value: Variant = (completed as Dictionary).get(tech_id, false)
	return true if completed_value is Dictionary else bool(completed_value)


func _get_recruitment_limit_by_loyalty(city_id: String) -> int:
	var loyalty := _get_city_loyalty_value(_get_city_hud_entry(city_id))
	if loyalty >= 90:
		return 500
	if loyalty >= 80:
		return 300
	if loyalty >= 60:
		return 200
	if loyalty >= 40:
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


func _can_pay_generic_resource_cost(cost: Dictionary) -> Dictionary:
	var missing := {}
	var resource_stock: Dictionary = _player_state.get("resource_stock", {})
	for resource_id_variant in cost.keys():
		var resource_id := str(resource_id_variant)
		var required_amount := maxi(0, int(cost.get(resource_id_variant, 0)))
		var available_amount := _get_total_recruitment_food_stock() if resource_id == "food" else maxi(0, int(resource_stock.get(resource_id, 0)))
		if available_amount < required_amount:
			missing[resource_id] = required_amount - available_amount
	return {
		"ok": missing.is_empty(),
		"cost": cost.duplicate(true),
		"missing": missing,
	}


func _apply_generic_resource_cost(cost: Dictionary) -> Dictionary:
	var resource_stock: Dictionary = _player_state.get("resource_stock", {}).duplicate(true)
	var before_stock := resource_stock.duplicate(true)
	var paid := {}
	for resource_id_variant in cost.keys():
		var resource_id := str(resource_id_variant)
		var required_amount := maxi(0, int(cost.get(resource_id_variant, 0)))
		if resource_id == "food":
			var remaining_food := required_amount
			var food_paid := {}
			for food_resource_id in ["rice", "barley", "seafood"]:
				var food_before_amount := maxi(0, int(resource_stock.get(food_resource_id, 0)))
				var food_paid_amount := mini(food_before_amount, remaining_food)
				resource_stock[food_resource_id] = food_before_amount - food_paid_amount
				remaining_food -= food_paid_amount
				food_paid[food_resource_id] = food_paid_amount
			paid["food"] = food_paid
			continue
		var before_amount := maxi(0, int(resource_stock.get(resource_id, 0)))
		var paid_amount := mini(before_amount, required_amount)
		resource_stock[resource_id] = before_amount - paid_amount
		paid[resource_id] = paid_amount
	_player_state["resource_stock"] = resource_stock
	return {
		"before": before_stock,
		"after": resource_stock.duplicate(true),
		"cost": cost.duplicate(true),
		"paid": paid,
	}


func _can_pay_recruitment_cost(cost: Dictionary) -> bool:
	return bool(_can_pay_generic_resource_cost(cost).get("ok", false))


func _apply_recruitment_cost(cost: Dictionary) -> Dictionary:
	var result := _apply_generic_resource_cost(cost)
	var paid: Dictionary = result.get("paid", {})
	return {
		"before": result.get("before", {}),
		"after": result.get("after", {}),
		"gold": int(paid.get("gold", 0)),
		"food": maxi(0, int(cost.get("food", 0))),
		"food_breakdown": paid.get("food", {}),
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
	var loyalty := _get_city_loyalty_value(_get_city_hud_entry(city_id))
	var limit := _get_recruitment_limit_by_loyalty(city_id)
	if loyalty < 40:
		return {"ok": false, "reason": "loyalty", "limit": limit, "loyalty_limit": limit, "publicSupport": public_support, "loyalty": loyalty}
	if amount > limit:
		return {"ok": false, "reason": "loyalty_limit", "limit": limit, "loyalty_limit": limit, "publicSupport": public_support, "loyalty": loyalty}
	var cost := _calculate_recruitment_cost(amount)
	if not _can_pay_recruitment_cost(cost):
		return {"ok": false, "reason": "resources", "cost": cost, "limit": limit, "loyalty_limit": limit, "publicSupport": public_support, "loyalty": loyalty}
	return {
		"ok": true,
		"cost": cost,
		"limit": limit,
		"loyalty_limit": limit,
		"publicSupport": public_support,
		"loyalty": loyalty,
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
			"publicSupport": validation.get("publicSupport", _get_city_public_support(city_id)),
			"loyalty": validation.get("loyalty", _get_city_loyalty_value(_get_city_hud_entry(city_id))),
			"loyalty_limit": validation.get("loyalty_limit", validation.get("limit", _get_recruitment_limit_by_loyalty(city_id))),
			"cost": validation.get("cost", _calculate_recruitment_cost(amount)),
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
		"loyalty_limit": int(validation.get("loyalty_limit", validation.get("limit", _get_recruitment_limit_by_loyalty(city_id)))),
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


func _make_national_tech_definition(id: String, tech_name: String, branch: String, tier: String, requires: Array, required_chancellor_type: String, conditions: Dictionary, cost: Dictionary, effect_summary: String) -> Dictionary:
	return {
		"id": id,
		"name": tech_name,
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


func _get_domestic_tech_categories_mvp() -> Dictionary:
	return {
		DOMESTIC_TECH_CATEGORY_AGRI: {"id": DOMESTIC_TECH_CATEGORY_AGRI, "name": "농업", "tree_scope": DOMESTIC_TECH_SCOPE_CITY},
		DOMESTIC_TECH_CATEGORY_FISH: {"id": DOMESTIC_TECH_CATEGORY_FISH, "name": "어업", "tree_scope": DOMESTIC_TECH_SCOPE_CITY},
		DOMESTIC_TECH_CATEGORY_COMMERCE: {"id": DOMESTIC_TECH_CATEGORY_COMMERCE, "name": "상업", "tree_scope": DOMESTIC_TECH_SCOPE_CITY},
		DOMESTIC_TECH_CATEGORY_MILITARY: {"id": DOMESTIC_TECH_CATEGORY_MILITARY, "name": "군사", "tree_scope": DOMESTIC_TECH_SCOPE_CITY},
		DOMESTIC_TECH_CATEGORY_NATION_ADMIN: {"id": DOMESTIC_TECH_CATEGORY_NATION_ADMIN, "name": "국가 행정", "tree_scope": DOMESTIC_TECH_SCOPE_NATIONAL},
		DOMESTIC_TECH_CATEGORY_NATION_ECONOMY: {"id": DOMESTIC_TECH_CATEGORY_NATION_ECONOMY, "name": "국가 경제", "tree_scope": DOMESTIC_TECH_SCOPE_NATIONAL},
		DOMESTIC_TECH_CATEGORY_NATION_MILITARY: {"id": DOMESTIC_TECH_CATEGORY_NATION_MILITARY, "name": "국가 군사", "tree_scope": DOMESTIC_TECH_SCOPE_NATIONAL},
		DOMESTIC_TECH_CATEGORY_NATION_DIPLOMACY: {"id": DOMESTIC_TECH_CATEGORY_NATION_DIPLOMACY, "name": "국가 외교", "tree_scope": DOMESTIC_TECH_SCOPE_NATIONAL},
	}


func _get_domestic_city_tech_definitions_mvp() -> Dictionary:
	return {
		"agri_tool_upgrade": _make_domestic_city_tech_definition_mvp("agri_tool_upgrade", "농기구 개량", DOMESTIC_TECH_CATEGORY_AGRI, "harvest", 1, 0, [], [], {}, ["administrative"], {"wood": 100, "gold": 50}, "food_yield_percent", 10, "식량 수확량 +10%", "res://assets/ui/tech_icons/agri/tech_agri_tool_upgrade.png"),
		"agri_irrigation": _make_domestic_city_tech_definition_mvp("agri_irrigation", "관개수로", DOMESTIC_TECH_CATEGORY_AGRI, "harvest", 2, 0, ["agri_tool_upgrade"], [], {}, ["administrative"], {"wood": 200, "gold": 100}, "grain_yield_percent", 20, "쌀·보리 수확량 +20%", "res://assets/ui/tech_icons/agri/tech_agri_irrigation.png"),
		"agri_double_cropping": _make_domestic_city_tech_definition_mvp("agri_double_cropping", "이모작", DOMESTIC_TECH_CATEGORY_AGRI, "harvest", 3, 0, ["agri_irrigation"], [], {}, ["administrative"], {"wood": 300, "gold": 200}, "food_production_turns", 1, "봄·가을 둘 다 수확, 식량 생산 턴 +1", "res://assets/ui/tech_icons/agri/tech_agri_double_cropping.png"),
		"agri_granary_zone": _make_domestic_city_tech_definition_mvp("agri_granary_zone", "곡창지대", DOMESTIC_TECH_CATEGORY_AGRI, "harvest", 4, 1, ["agri_double_cropping"], [], {}, ["administrative"], {"wood": 500, "gold": 500}, "food_surplus_public_support", 10, "식량 잉여 극대화 + 민심 +10", "res://assets/ui/tech_icons/agri/tech_agri_granary_zon.png"),
		"agri_reservoir": _make_domestic_city_tech_definition_mvp("agri_reservoir", "저수지", DOMESTIC_TECH_CATEGORY_AGRI, "harvest", 3, 0, ["agri_irrigation"], [], {}, ["administrative"], {"wood": 300, "gold": 300}, "drought_immunity_food_yield", 10, "가뭄 피해 면역 + 수확량 +10%", "res://assets/ui/tech_icons/agri/tech_agri_reservoir.png"),
		"agri_pasture": _make_domestic_city_tech_definition_mvp("agri_pasture", "목초지", DOMESTIC_TECH_CATEGORY_AGRI, "livestock", 1, 0, [], [], {}, ["administrative"], {"wood": 150, "gold": 100}, "horse_production_per_turn", 20, "말 생산 가능 +20/턴"),
		"agri_ranch": _make_domestic_city_tech_definition_mvp("agri_ranch", "목장", DOMESTIC_TECH_CATEGORY_AGRI, "livestock", 2, 0, ["agri_pasture"], [], {}, ["administrative"], {"wood": 250, "gold": 200}, "horse_production_per_turn", 40, "말 생산 +40/턴"),
		"agri_warhorse_breeding": _make_domestic_city_tech_definition_mvp("agri_warhorse_breeding", "군마 육성", DOMESTIC_TECH_CATEGORY_AGRI, "livestock", 3, 1, ["agri_ranch"], [], {}, ["administrative", "militaryAdmin"], {"wood": 300, "gold": 400}, "cavalry_power_percent", 15, "기병 전투력 +15% + 말 생산 극대화"),
		"fish_village": _make_domestic_city_tech_definition_mvp("fish_village", "어촌 형성", DOMESTIC_TECH_CATEGORY_FISH, "coastal", 1, 0, [], [], {"city_requirements": {"coastal": true}}, ["maritime"], {"wood": 100, "gold": 50}, "seafood_production_per_turn", 30, "수산물 생산 +30/턴", "res://assets/ui/tech_icons/fish/tech_fish_village.png"),
		"fish_coastal_fishing": _make_domestic_city_tech_definition_mvp("fish_coastal_fishing", "연안 어업", DOMESTIC_TECH_CATEGORY_FISH, "coastal", 2, 0, ["fish_village"], [], {"city_requirements": {"coastal": true}}, ["maritime"], {"wood": 150, "gold": 100}, "seafood_production_per_turn", 60, "수산물 생산 +60/턴", "res://assets/ui/tech_icons/fish/tech_fish_coastal_fishing.png"),
		"fish_fleet": _make_domestic_city_tech_definition_mvp("fish_fleet", "어선단", DOMESTIC_TECH_CATEGORY_FISH, "coastal", 3, 0, ["fish_coastal_fishing"], [], {"city_requirements": {"coastal": true}}, ["maritime"], {"wood": 300, "gold": 200}, "seafood_production_per_turn", 120, "수산물 생산 +120/턴", "res://assets/ui/tech_icons/fish/tech_fish_fleet.png"),
		"fish_deep_sea_fishing": _make_domestic_city_tech_definition_mvp("fish_deep_sea_fishing", "원양 어업", DOMESTIC_TECH_CATEGORY_FISH, "coastal", 4, 1, ["fish_fleet"], [], {"city_requirements": {"coastal": true}}, ["maritime"], {"wood": 500, "gold": 400}, "seafood_winter_immunity", 1, "수산물 생산 극대화 + 겨울 식량 패널티 면역"),
		"fish_dried_supply_base": _make_domestic_city_tech_definition_mvp("fish_dried_supply_base", "건어물 보급기지", DOMESTIC_TECH_CATEGORY_FISH, "coastal", 4, 0, ["fish_fleet"], [], {"city_requirements": {"coastal": true}}, ["maritime", "militaryAdmin"], {"wood": 300, "gold": 300}, "expedition_food_cost_percent", -30, "원정 부대 식량 소모 -30%", "res://assets/ui/tech_icons/fish/tech_fish_dried_supply_base.png", ["nation_logistics_system"]),
		"fish_salt_field": _make_domestic_city_tech_definition_mvp("fish_salt_field", "염전", DOMESTIC_TECH_CATEGORY_FISH, "salt", 1, 0, [], [], {"city_requirements": {"coastal": true}}, ["maritime"], {"gold": 150}, "salt_production_per_turn", 50, "소금 생산 +50/턴"),
		"fish_salt_warehouse": _make_domestic_city_tech_definition_mvp("fish_salt_warehouse", "소금창고", DOMESTIC_TECH_CATEGORY_FISH, "salt", 2, 1, ["fish_salt_field"], [], {"city_requirements": {"coastal": true}}, ["maritime"], {"wood": 200, "gold": 300}, "food_preservation_salt_trade", 25, "식량 보존 최대화 + 무역 소금 수입 +25%"),
		"commerce_street_market": _make_domestic_city_tech_definition_mvp("commerce_street_market", "노점시장", DOMESTIC_TECH_CATEGORY_COMMERCE, "market", 1, 0, [], [], {}, ["economic"], {"gold": 100}, "gold_income_per_turn", 50, "금전 수입 +50/턴", "res://assets/ui/tech_icons/commerce/tech_commerce_street_market.png"),
		"commerce_permanent_market": _make_domestic_city_tech_definition_mvp("commerce_permanent_market", "상설시장", DOMESTIC_TECH_CATEGORY_COMMERCE, "market", 2, 0, ["commerce_street_market"], [], {}, ["economic"], {"gold": 200}, "gold_income_per_turn", 100, "금전 수입 +100/턴", "res://assets/ui/tech_icons/commerce/tech_commerce_permanent_market.png"),
		"commerce_grand_market": _make_domestic_city_tech_definition_mvp("commerce_grand_market", "대형시장", DOMESTIC_TECH_CATEGORY_COMMERCE, "market", 3, 0, ["commerce_permanent_market"], [], {}, ["economic"], {"gold": 400}, "gold_trade_income", 10, "금전 수입 +200/턴 + 무역 수입 +10%", "res://assets/ui/tech_icons/commerce/tech_commerce_grand_market.png"),
		"commerce_merchant_guild": _make_domestic_city_tech_definition_mvp("commerce_merchant_guild", "대상단", DOMESTIC_TECH_CATEGORY_COMMERCE, "market", 4, 0, ["commerce_grand_market"], ["nation_alliance_system"], {}, ["economic", "diplomatic"], {"gold": 500, "silk": 200}, "trade_income_percent", 30, "무역 수입 +30% + 인접 도시 무역 보너스"),
		"commerce_mint": _make_domestic_city_tech_definition_mvp("commerce_mint", "조폐소", DOMESTIC_TECH_CATEGORY_COMMERCE, "market", 4, 1, ["commerce_grand_market"], ["nation_currency_unification"], {}, ["economic"], {"gold": 800, "iron": 300}, "mint_income_fee", 1, "금전 생산 극대화 + 전국 거래 수수료 수입", "res://assets/ui/tech_icons/commerce/tech_commerce_mint.png"),
		"commerce_port": _make_domestic_city_tech_definition_mvp("commerce_port", "항구", DOMESTIC_TECH_CATEGORY_COMMERCE, "sea_trade", 1, 0, [], [], {"city_requirements": {"coastal": true}}, ["economic", "maritime", "diplomatic"], {"wood": 300, "gold": 200}, "sea_trade_gold_income", 100, "해상 무역 가능 + 금전 +100/턴", "res://assets/ui/tech_icons/naval/tech_naval_port.png"),
		"commerce_shipyard": _make_domestic_city_tech_definition_mvp("commerce_shipyard", "조선소", DOMESTIC_TECH_CATEGORY_COMMERCE, "sea_trade", 2, 0, ["commerce_port"], [], {"city_requirements": {"coastal": true}}, ["economic", "maritime"], {"wood": 400, "iron": 200, "gold": 300}, "naval_production_trade_ship", 1, "수군 생산 가능 + 무역선 건조", "res://assets/ui/tech_icons/naval/tech_naval_shipyard.png"),
		"commerce_trade_port": _make_domestic_city_tech_definition_mvp("commerce_trade_port", "무역항", DOMESTIC_TECH_CATEGORY_COMMERCE, "sea_trade", 3, 1, ["commerce_shipyard"], ["nation_alliance_system"], {"city_requirements": {"coastal": true}}, ["economic", "maritime", "diplomatic"], {"wood": 500, "gold": 600}, "sea_trade_route_income_percent", 50, "해상 무역 루트 추가 + 타국 교역 수입 +50%"),
		"commerce_silk_road": _make_domestic_city_tech_definition_mvp("commerce_silk_road", "실크로드", DOMESTIC_TECH_CATEGORY_COMMERCE, "silk_road", 4, 1, [], ["nation_alliance_system"], {"resource_requirements": {"silk_large_stock": true}}, ["economic", "diplomatic"], {"gold": 600, "silk": 500}, "silk_export_diplomacy", 1, "비단 수출 수입 극대화 + 외교 보너스"),
		"mil_barracks": _make_domestic_city_tech_definition_mvp("mil_barracks", "병영 설치", DOMESTIC_TECH_CATEGORY_MILITARY, "infantry", 1, 0, [], [], {}, ["militaryAdmin"], {"wood": 200, "gold": 150}, "recruitment_training", 1, "징병 가능 + 훈련 시작", "res://assets/ui/tech_icons/military/tech_mil_barracks.png"),
		"mil_infantry_training": _make_domestic_city_tech_definition_mvp("mil_infantry_training", "보병 훈련", DOMESTIC_TECH_CATEGORY_MILITARY, "infantry", 2, 0, ["mil_barracks"], [], {}, ["militaryAdmin"], {"gold": 200}, "infantry_power_percent", 10, "보병 전투력 +10%", "res://assets/ui/tech_icons/military/tech_mil_infantry_training.png"),
		"mil_elite_infantry": _make_domestic_city_tech_definition_mvp("mil_elite_infantry", "정예 보병", DOMESTIC_TECH_CATEGORY_MILITARY, "infantry", 3, 0, ["mil_infantry_training"], [], {}, ["militaryAdmin"], {"iron": 200, "gold": 300}, "infantry_power_percent", 20, "보병 전투력 +20%", "res://assets/ui/tech_icons/military/tech_mil_elite_infantry.png"),
		"mil_heavy_infantry": _make_domestic_city_tech_definition_mvp("mil_heavy_infantry", "철갑 보병", DOMESTIC_TECH_CATEGORY_MILITARY, "infantry", 4, 1, ["mil_elite_infantry"], ["nation_military_reform"], {}, ["militaryAdmin"], {"iron": 400, "gold": 500}, "infantry_power_defense_percent", 40, "보병 전투력 +40% + 방어력 대폭 상승"),
		"mil_archer_training": _make_domestic_city_tech_definition_mvp("mil_archer_training", "궁병 훈련", DOMESTIC_TECH_CATEGORY_MILITARY, "archer", 1, 0, [], [], {}, ["militaryAdmin"], {"wood": 150, "gold": 200}, "ranged_attack_unlock", 1, "원거리 공격 가능"),
		"mil_elite_archer": _make_domestic_city_tech_definition_mvp("mil_elite_archer", "정예 궁병", DOMESTIC_TECH_CATEGORY_MILITARY, "archer", 2, 0, ["mil_archer_training"], [], {}, ["militaryAdmin"], {"wood": 200, "gold": 300}, "ranged_power_percent", 25, "원거리 전투력 +25%"),
		"mil_singijeon": _make_domestic_city_tech_definition_mvp("mil_singijeon", "신기전", DOMESTIC_TECH_CATEGORY_MILITARY, "archer", 3, 1, ["mil_elite_archer"], [], {}, ["militaryAdmin"], {"wood": 300, "iron": 200, "gold": 500}, "ranged_fire_attack", 1, "원거리 전투력 극대화 + 화공 가능"),
		"mil_cavalry_training": _make_domestic_city_tech_definition_mvp("mil_cavalry_training", "기병 훈련", DOMESTIC_TECH_CATEGORY_MILITARY, "cavalry", 1, 0, [], [], {}, ["militaryAdmin"], {"horse": 50, "gold": 200}, "cavalry_production", 1, "기병 생산 가능"),
		"mil_light_cavalry": _make_domestic_city_tech_definition_mvp("mil_light_cavalry", "경기병", DOMESTIC_TECH_CATEGORY_MILITARY, "cavalry", 2, 0, ["mil_cavalry_training"], [], {}, ["militaryAdmin"], {"horse": 80, "gold": 300}, "mobility_percent", 20, "기동력 +20%"),
		"mil_heavy_cavalry": _make_domestic_city_tech_definition_mvp("mil_heavy_cavalry", "중기병", DOMESTIC_TECH_CATEGORY_MILITARY, "cavalry", 2, 0, ["mil_cavalry_training"], [], {}, ["militaryAdmin"], {"horse": 100, "iron": 200, "gold": 400}, "cavalry_power_percent", 25, "기병 전투력 +25%", "res://assets/ui/tech_icons/military/tech_mil_heavy_cavalry.png"),
		"mil_iron_cavalry": _make_domestic_city_tech_definition_mvp("mil_iron_cavalry", "철기", DOMESTIC_TECH_CATEGORY_MILITARY, "cavalry", 3, 1, ["mil_heavy_cavalry"], [], {}, ["militaryAdmin"], {"horse": 150, "iron": 400, "gold": 600}, "cavalry_power_max", 1, "기병 전투력 극대화"),
		"mil_cavalry_charge_tactics": _make_domestic_city_tech_definition_mvp("mil_cavalry_charge_tactics", "기병 돌격 전술", DOMESTIC_TECH_CATEGORY_MILITARY, "cavalry", 3, 1, ["mil_heavy_cavalry"], [], {}, ["militaryAdmin"], {"gold": 400}, "charge_formation_break", 1, "돌격 시 적 진형 붕괴 효과"),
		"naval_training": _make_domestic_city_tech_definition_mvp("naval_training", "수군 훈련", DOMESTIC_TECH_CATEGORY_MILITARY, "naval", 1, 0, ["commerce_shipyard"], [], {"city_requirements": {"coastal": true}}, ["maritime", "militaryAdmin"], {"wood": 200, "gold": 200}, "naval_production", 1, "수군 생산 가능"),
		"naval_warship_building": _make_domestic_city_tech_definition_mvp("naval_warship_building", "전선 건조", DOMESTIC_TECH_CATEGORY_MILITARY, "naval", 2, 0, ["naval_training"], [], {"city_requirements": {"coastal": true}}, ["maritime", "militaryAdmin"], {"wood": 400, "iron": 150, "gold": 300}, "naval_power_percent", 15, "수군 전투력 +15%"),
		"naval_panokseon": _make_domestic_city_tech_definition_mvp("naval_panokseon", "판옥선", DOMESTIC_TECH_CATEGORY_MILITARY, "naval", 3, 0, ["naval_warship_building"], [], {"city_requirements": {"coastal": true}}, ["maritime", "militaryAdmin"], {"wood": 600, "iron": 300, "gold": 500}, "naval_power_percent", 30, "수군 전투력 +30%"),
		"naval_turtle_ship": _make_domestic_city_tech_definition_mvp("naval_turtle_ship", "거북선", DOMESTIC_TECH_CATEGORY_MILITARY, "naval", 4, 2, ["naval_panokseon"], ["nation_military_reform"], {"city_requirements": {"coastal": true}, "required_hero_flags": ["has_hero_yi_sunsin"]}, ["maritime", "militaryAdmin"], {"wood": 1000, "iron": 800, "gold": 1500}, "naval_power_max", 1, "수군 전투력 극대화 + 무적 함선", "res://assets/ui/tech_icons/naval/tech_naval_turtle_ship.png"),
		"naval_crane_wing_formation": _make_domestic_city_tech_definition_mvp("naval_crane_wing_formation", "학익진", DOMESTIC_TECH_CATEGORY_MILITARY, "naval", 5, 2, ["naval_turtle_ship"], [], {"city_requirements": {"coastal": true}, "required_hero_flags": ["has_hero_yi_sunsin"]}, ["maritime", "militaryAdmin"], {"gold": 800}, "naval_formation_max", 1, "해전 최강 진형 + 포위 공격 가능"),
		"naval_fire_ship": _make_domestic_city_tech_definition_mvp("naval_fire_ship", "화공선", DOMESTIC_TECH_CATEGORY_MILITARY, "naval", 4, 0, ["naval_panokseon"], [], {"city_requirements": {"coastal": true}}, ["maritime", "militaryAdmin"], {"wood": 400, "gold": 300}, "naval_fire_attack", 1, "화공 공격 가능"),
		"naval_cannon_mount": _make_domestic_city_tech_definition_mvp("naval_cannon_mount", "화포 장착", DOMESTIC_TECH_CATEGORY_MILITARY, "naval", 4, 1, ["naval_panokseon"], [], {"city_requirements": {"coastal": true}}, ["maritime", "militaryAdmin"], {"iron": 400, "gold": 500}, "naval_ranged_attack", 1, "원거리 해상 공격 가능"),
		"mil_wall_upgrade": _make_domestic_city_tech_definition_mvp("mil_wall_upgrade", "성벽 강화", DOMESTIC_TECH_CATEGORY_MILITARY, "defense", 1, 0, [], [], {}, ["militaryAdmin"], {"wood": 400, "iron": 300, "gold": 300}, "defense_percent", 20, "방어력 +20%"),
		"mil_moat": _make_domestic_city_tech_definition_mvp("mil_moat", "해자", DOMESTIC_TECH_CATEGORY_MILITARY, "defense", 2, 0, ["mil_wall_upgrade"], [], {}, ["militaryAdmin"], {"wood": 500, "gold": 400}, "defense_siege_slow", 15, "방어력 +15% + 공성 속도 감소"),
		"mil_double_moat": _make_domestic_city_tech_definition_mvp("mil_double_moat", "이중 해자", DOMESTIC_TECH_CATEGORY_MILITARY, "defense", 3, 0, ["mil_moat"], [], {}, ["militaryAdmin"], {"wood": 600, "iron": 400, "gold": 600}, "defense_percent", 25, "방어력 +25%"),
		"mil_watchtower": _make_domestic_city_tech_definition_mvp("mil_watchtower", "망루", DOMESTIC_TECH_CATEGORY_MILITARY, "defense", 2, 0, ["mil_wall_upgrade"], [], {}, ["militaryAdmin"], {"wood": 300, "iron": 200, "gold": 200}, "invasion_warning_turns", 1, "적 침공 1턴 전 경고"),
		"mil_beacon": _make_domestic_city_tech_definition_mvp("mil_beacon", "봉화대", DOMESTIC_TECH_CATEGORY_MILITARY, "defense", 3, 0, ["mil_watchtower"], [], {}, ["militaryAdmin"], {"wood": 200, "gold": 200}, "adjacent_invasion_warning", 1, "인접 도시 침공 경고"),
		"mil_beacon_network": _make_domestic_city_tech_definition_mvp("mil_beacon_network", "봉화 네트워크", DOMESTIC_TECH_CATEGORY_MILITARY, "defense", 4, 1, ["mil_beacon"], [], {}, ["militaryAdmin"], {"gold": 500}, "national_invasion_warning", 1, "전국 침공 즉시 경고"),
		"mil_iron_gate": _make_domestic_city_tech_definition_mvp("mil_iron_gate", "철문 설치", DOMESTIC_TECH_CATEGORY_MILITARY, "defense", 2, 0, ["mil_wall_upgrade"], [], {}, ["militaryAdmin"], {"iron": 500, "wood": 300, "gold": 400}, "defense_percent", 20, "방어력 +20%"),
		"mil_iron_fortress": _make_domestic_city_tech_definition_mvp("mil_iron_fortress", "철옹성", DOMESTIC_TECH_CATEGORY_MILITARY, "defense", 5, 1, ["mil_double_moat", "mil_beacon_network", "mil_iron_gate"], [], {"min_loyalty": 75}, ["militaryAdmin"], {"iron": 1000, "wood": 800, "gold": 1500}, "defense_max", 1, "방어력 극대화 + 함락 거의 불가"),
		"mil_siege_unit": _make_domestic_city_tech_definition_mvp("mil_siege_unit", "공성 부대", DOMESTIC_TECH_CATEGORY_MILITARY, "siege", 1, 0, [], [], {}, ["militaryAdmin"], {"wood": 300, "gold": 300}, "siege_power_percent", 30, "공성 능력 +30%"),
		"mil_siege_engine": _make_domestic_city_tech_definition_mvp("mil_siege_engine", "공성 병기", DOMESTIC_TECH_CATEGORY_MILITARY, "siege", 2, 1, ["mil_siege_unit"], [], {}, ["militaryAdmin"], {"wood": 500, "iron": 300, "gold": 500}, "siege_power_max", 1, "공성 능력 극대화 + 성벽 돌파 가능"),
	}


func _get_domestic_national_tech_definitions_mvp() -> Dictionary:
	return {
		"nation_foundation": _make_domestic_national_tech_definition_mvp("nation_foundation", "국가 기반 정비", DOMESTIC_TECH_CATEGORY_NATION_ADMIN, "administration", 1, 0, [], {}, {"gold": 200}, "governor_capacity", 0, "태수 임명 가능 도시 수 증가", "res://assets/ui/tech_icons/nation/tech_nation_foundation.png"),
		"nation_law_reform": _make_domestic_national_tech_definition_mvp("nation_law_reform", "법률 정비", DOMESTIC_TECH_CATEGORY_NATION_ADMIN, "administration", 2, 0, ["nation_foundation"], {"chancellor_aptitudes": ["administrative"]}, {"gold": 300, "silk": 100}, "public_support_national", 5, "전국 민심 +5", "res://assets/ui/tech_icons/nation/tech_nation_law_reform.png"),
		"nation_bureaucracy": _make_domestic_national_tech_definition_mvp("nation_bureaucracy", "관료 체계", DOMESTIC_TECH_CATEGORY_NATION_ADMIN, "administration", 3, 0, ["nation_law_reform"], {"owned_city_count": 2}, {"gold": 500, "silk": 200}, "governor_effect_percent", 10, "태수 효과 +10%", "res://assets/ui/tech_icons/nation/tech_nation_bureaucracy.png"),
		"nation_local_administration": _make_domestic_national_tech_definition_mvp("nation_local_administration", "지방 행정", DOMESTIC_TECH_CATEGORY_NATION_ADMIN, "administration", 4, 0, ["nation_bureaucracy"], {"owned_city_count": 3, "governor_assigned_city_count": 2}, {"gold": 600, "silk": 300}, "city_tax_efficiency", 1, "도시별 세금 효율 증가"),
		"nation_centralization": _make_domestic_national_tech_definition_mvp("nation_centralization", "중앙집권", DOMESTIC_TECH_CATEGORY_NATION_ADMIN, "administration", 5, 1, ["nation_local_administration"], {"chancellor_aptitudes": ["administrative"], "national_loyalty": 70, "owned_city_count": 5}, {"gold": 1000, "silk": 500}, "all_city_income_percent", 20, "모든 도시 수입 +20% + 태수 효과 극대화", "res://assets/ui/tech_icons/nation/tech_nation_centralization.png"),
		"nation_inspection_system": _make_domestic_national_tech_definition_mvp("nation_inspection_system", "감찰 제도", DOMESTIC_TECH_CATEGORY_NATION_ADMIN, "inspection", 4, 0, ["nation_bureaucracy"], {"chancellor_aptitudes": ["political"]}, {"gold": 400, "silk": 200}, "gold_loss_reduction", 1, "금전 손실 감소"),
		"nation_anti_corruption": _make_domestic_national_tech_definition_mvp("nation_anti_corruption", "부패 방지", DOMESTIC_TECH_CATEGORY_NATION_ADMIN, "inspection", 5, 1, ["nation_inspection_system"], {"national_loyalty": 65}, {"gold": 600, "silk": 300}, "tax_efficiency_max", 1, "세금 효율 극대화"),
		"nation_household_registry": _make_domestic_national_tech_definition_mvp("nation_household_registry", "호적 제도", DOMESTIC_TECH_CATEGORY_NATION_ADMIN, "population", 2, 0, ["nation_foundation"], {"owned_city_count": 2}, {"gold": 400}, "conscription_capacity_percent", 10, "징병 가능 인원 +10%"),
		"nation_population_census": _make_domestic_national_tech_definition_mvp("nation_population_census", "인구 조사", DOMESTIC_TECH_CATEGORY_NATION_ADMIN, "population", 3, 0, ["nation_household_registry"], {"chancellor_aptitudes": ["administrative"]}, {"gold": 500, "food": 200}, "conscription_efficiency", 1, "징병 효율 증가"),
		"nation_population_policy": _make_domestic_national_tech_definition_mvp("nation_population_policy", "인구 정책", DOMESTIC_TECH_CATEGORY_NATION_ADMIN, "population", 4, 1, ["nation_population_census"], {"owned_city_count": 4, "average_public_support": 70}, {"gold": 800, "food": 500}, "population_growth_conscription_limit", 1, "전국 인구 성장 + 징병 한계 증가"),
		"nation_tax_reform": _make_domestic_national_tech_definition_mvp("nation_tax_reform", "세제 개혁", DOMESTIC_TECH_CATEGORY_NATION_ECONOMY, "tax", 1, 0, [], {"chancellor_aptitudes": ["economic"]}, {"gold": 400}, "national_gold_income_percent", 10, "전국 금전 수입 +10%", "res://assets/ui/tech_icons/nation/tech_nation_tax_reform.png"),
		"nation_equal_tax": _make_domestic_national_tech_definition_mvp("nation_equal_tax", "균등세", DOMESTIC_TECH_CATEGORY_NATION_ECONOMY, "tax", 2, 0, ["nation_tax_reform"], {"owned_city_count": 2}, {"gold": 500, "silk": 100}, "tax_public_support", 1, "민심 상승, 세금 불만 감소"),
		"nation_currency_unification": _make_domestic_national_tech_definition_mvp("nation_currency_unification", "화폐 통일", DOMESTIC_TECH_CATEGORY_NATION_ECONOMY, "tax", 3, 0, ["nation_equal_tax"], {"chancellor_aptitudes": ["economic"], "average_commerce": 50}, {"gold": 800, "iron": 200}, "trade_income_percent", 15, "무역 수입 +15%", "", ["commerce_mint"]),
		"nation_national_economy": _make_domestic_national_tech_definition_mvp("nation_national_economy", "국가 경제", DOMESTIC_TECH_CATEGORY_NATION_ECONOMY, "tax", 4, 1, ["nation_currency_unification"], {"owned_city_count": 4, "required_city_techs": ["commerce_mint"]}, {"gold": 1500, "silk": 500}, "national_gold_income_max", 1, "전국 금전 수입 극대화"),
		"nation_monopoly_system": _make_domestic_national_tech_definition_mvp("nation_monopoly_system", "전매 제도", DOMESTIC_TECH_CATEGORY_NATION_ECONOMY, "monopoly", 2, 0, ["nation_tax_reform"], {"resource_monopoly_candidates": ["salt", "silk"]}, {"gold": 600, "silk": 200}, "strategic_resource_income", 1, "소금·비단 독점 수입 증가"),
		"nation_national_monopoly": _make_domestic_national_tech_definition_mvp("nation_national_monopoly", "국가 전매", DOMESTIC_TECH_CATEGORY_NATION_ECONOMY, "monopoly", 3, 1, ["nation_monopoly_system"], {"chancellor_aptitudes": ["economic"], "resource_surplus": ["salt", "silk"]}, {"gold": 1000, "silk": 400, "salt": 400}, "strategic_resource_income_max", 1, "전략 자원 독점, 금전 대폭 증가"),
		"nation_conscription": _make_domestic_national_tech_definition_mvp("nation_conscription", "징병 제도", DOMESTIC_TECH_CATEGORY_NATION_MILITARY, "military", 1, 0, [], {"chancellor_aptitudes": ["militaryAdmin"]}, {"gold": 300, "food": 200}, "national_conscription_efficiency_percent", 10, "전국 징병 효율 +10%"),
		"nation_military_training_order": _make_domestic_national_tech_definition_mvp("nation_military_training_order", "군사 훈련령", DOMESTIC_TECH_CATEGORY_NATION_MILITARY, "military", 2, 0, ["nation_conscription"], {"average_loyalty": 60}, {"iron": 200, "gold": 400, "food": 300}, "national_combat_power_percent", 10, "전국 전투력 +10%"),
		"nation_military_reform": _make_domestic_national_tech_definition_mvp("nation_military_reform", "군사 개혁", DOMESTIC_TECH_CATEGORY_NATION_MILITARY, "military", 3, 0, ["nation_military_training_order"], {"chancellor_aptitudes": ["militaryAdmin"]}, {"iron": 500, "gold": 600, "food": 400}, "national_combat_power_percent", 20, "전국 전투력 +20%", "", ["naval_turtle_ship", "mil_heavy_infantry"]),
		"nation_standing_army": _make_domestic_national_tech_definition_mvp("nation_standing_army", "상비군", DOMESTIC_TECH_CATEGORY_NATION_MILITARY, "military", 4, 1, ["nation_military_reform"], {"average_loyalty": 75, "owned_city_count": 4}, {"iron": 800, "gold": 1000, "food": 800}, "national_combat_power_max", 1, "전국 전투력 극대화 + 징병 속도 증가"),
		"nation_logistics_system": _make_domestic_national_tech_definition_mvp("nation_logistics_system", "병참 제도", DOMESTIC_TECH_CATEGORY_NATION_MILITARY, "logistics", 2, 0, ["nation_conscription"], {"connected_supply_city_count": 3}, {"food": 500, "salt": 300, "gold": 400}, "expedition_supply_stability", 1, "원정 보급 안정", "", [], ["fish_dried_supply_base"]),
		"nation_expedition_system": _make_domestic_national_tech_definition_mvp("nation_expedition_system", "원정 체계", DOMESTIC_TECH_CATEGORY_NATION_MILITARY, "logistics", 3, 1, ["nation_logistics_system"], {"required_city_techs": ["fish_dried_supply_base", "fish_salt_warehouse"]}, {"food": 800, "salt": 500, "gold": 600}, "long_expedition_supply", 1, "장거리 원정 가능 + 보급 손실 없음"),
		"nation_weapon_standardization": _make_domestic_national_tech_definition_mvp("nation_weapon_standardization", "무기 규격화", DOMESTIC_TECH_CATEGORY_NATION_MILITARY, "weapon", 2, 0, ["nation_conscription"], {"chancellor_aptitudes": ["militaryAdmin"], "resource_requirements": {"iron": true}}, {"iron": 300, "gold": 400}, "national_combat_power", 1, "전국 전투력 증가"),
		"nation_weapon_factory": _make_domestic_national_tech_definition_mvp("nation_weapon_factory", "무기 공장", DOMESTIC_TECH_CATEGORY_NATION_MILITARY, "weapon", 3, 1, ["nation_weapon_standardization"], {"required_city_techs": ["mil_siege_engine"]}, {"iron": 600, "wood": 400, "gold": 800}, "recruitment_cost_reduction", 1, "무기 대량 생산, 징병 비용 감소"),
		"nation_envoy": _make_domestic_national_tech_definition_mvp("nation_envoy", "사신 파견", DOMESTIC_TECH_CATEGORY_NATION_DIPLOMACY, "diplomacy", 1, 0, [], {"chancellor_aptitudes": ["diplomatic"]}, {"gold": 300, "silk": 200}, "diplomacy_action_unlock", 1, "외교 행동 가능"),
		"nation_diplomacy_system": _make_domestic_national_tech_definition_mvp("nation_diplomacy_system", "외교 체계", DOMESTIC_TECH_CATEGORY_NATION_DIPLOMACY, "diplomacy", 2, 0, ["nation_envoy"], {"neutral_faction_count": 2}, {"gold": 400, "silk": 300}, "relation_improvement_speed", 1, "관계 개선 속도 증가"),
		"nation_alliance_system": _make_domestic_national_tech_definition_mvp("nation_alliance_system", "동맹 체계", DOMESTIC_TECH_CATEGORY_NATION_DIPLOMACY, "diplomacy", 3, 0, ["nation_diplomacy_system"], {"chancellor_aptitudes": ["diplomatic"], "allied_faction_count": 1}, {"gold": 600, "silk": 400}, "alliance_trade_income", 1, "동맹 효과 강화, 무역 수입 증가", "", ["commerce_merchant_guild", "commerce_trade_port", "commerce_silk_road"]),
		"nation_world_diplomacy": _make_domestic_national_tech_definition_mvp("nation_world_diplomacy", "천하 외교", DOMESTIC_TECH_CATEGORY_NATION_DIPLOMACY, "diplomacy", 4, 1, ["nation_alliance_system"], {"allied_faction_count": 2, "required_city_tech_any": ["commerce_silk_road", "commerce_trade_port"]}, {"gold": 1000, "silk": 800}, "world_trade_diplomacy_action", 1, "전국 무역 극대화 + 외교 공작 가능", "res://assets/ui/tech_icons/nation/tech_nation_world_diplomacy.png"),
		"nation_intelligence_system": _make_domestic_national_tech_definition_mvp("nation_intelligence_system", "첩보 체계", DOMESTIC_TECH_CATEGORY_NATION_DIPLOMACY, "intelligence", 2, 0, ["nation_envoy"], {"chancellor_aptitudes": ["political"]}, {"gold": 500, "silk": 200}, "enemy_info_collection", 1, "적 정보 수집 가능"),
		"nation_intelligence_org": _make_domestic_national_tech_definition_mvp("nation_intelligence_org", "첩보 조직", DOMESTIC_TECH_CATEGORY_NATION_DIPLOMACY, "intelligence", 3, 1, ["nation_intelligence_system"], {"owned_city_count": 3, "chancellor_aptitudes": ["diplomatic", "political"], "unlocks_flags": ["enemy_city_operation"]}, {"gold": 800, "silk": 400}, "national_spy_activity", 1, "전국 첩보 활동 가능"),
		"nation_tribute_system": _make_domestic_national_tech_definition_mvp("nation_tribute_system", "조공 체계", DOMESTIC_TECH_CATEGORY_NATION_DIPLOMACY, "tribute", 2, 0, ["nation_envoy"], {"neutral_faction_count": 1, "resource_surplus": ["silk"]}, {"gold": 200, "silk": 300}, "tribute_relation_speed", 1, "비단으로 관계 개선 속도 증가"),
		"nation_tribute_network": _make_domestic_national_tech_definition_mvp("nation_tribute_network", "조공 네트워크", DOMESTIC_TECH_CATEGORY_NATION_DIPLOMACY, "tribute", 3, 1, ["nation_tribute_system"], {"required_national_techs": ["nation_alliance_system"], "resource_surplus": ["silk"]}, {"gold": 600, "silk": 600}, "tribute_diplomacy_max", 1, "비단 외교 극대화, 동맹 유지 비용 감소"),
	}


func _make_domestic_city_tech_definition_mvp(id: String, tech_name: String, category: String, branch: String, tier: int, rarity: int, prerequisites: Array, required_national_techs: Array, special_requirements: Dictionary, governor_aptitudes: Array, cost: Dictionary, effect_type: String, effect_value: Variant, effect_description: String, icon_path: String = "", enhanced_by_national_techs: Array = []) -> Dictionary:
	return _make_domestic_tech_definition_mvp(id, tech_name, DOMESTIC_TECH_SCOPE_CITY, DOMESTIC_TECH_UI_SURFACE_CITY, category, branch, tier, rarity, prerequisites, required_national_techs, special_requirements, governor_aptitudes, DOMESTIC_TECH_PROGRESS_CITY, cost, effect_type, effect_value, effect_description, icon_path, [], enhanced_by_national_techs)


func _make_domestic_national_tech_definition_mvp(id: String, tech_name: String, category: String, branch: String, tier: int, rarity: int, prerequisites: Array, special_requirements: Dictionary, cost: Dictionary, effect_type: String, effect_value: Variant, effect_description: String, icon_path: String = "", unlocks_city_techs: Array = [], enhances_city_techs: Array = []) -> Dictionary:
	return _make_domestic_tech_definition_mvp(id, tech_name, DOMESTIC_TECH_SCOPE_NATIONAL, DOMESTIC_TECH_UI_SURFACE_NATIONAL, category, branch, tier, rarity, prerequisites, [], special_requirements, [], DOMESTIC_TECH_PROGRESS_NATIONAL, cost, effect_type, effect_value, effect_description, icon_path, unlocks_city_techs, enhances_city_techs)


func _make_domestic_tech_definition_mvp(id: String, tech_name: String, tree_scope: String, ui_surface: String, category: String, branch: String, tier: int, rarity: int, prerequisites: Array, required_national_techs: Array, special_requirements: Dictionary, governor_aptitudes: Array, progress_mode: String, cost: Dictionary, effect_type: String, effect_value: Variant, effect_description: String, icon_path: String, unlocks_city_techs: Array, enhances_city_techs: Array) -> Dictionary:
	var safe_icon_path := icon_path if not icon_path.is_empty() else ""
	return {
		"id": id,
		"name": tech_name,
		"tree_scope": tree_scope,
		"ui_surface": ui_surface,
		"category": category,
		"branch": branch,
		"tier": tier,
		"rarity": rarity,
		"icon_path": safe_icon_path,
		"icon_missing": safe_icon_path.is_empty(),
		"icon_fallback_label": DOMESTIC_TECH_ICON_FALLBACK_LABEL,
		"prerequisites": prerequisites.duplicate(true),
		"required_national_techs": required_national_techs.duplicate(true),
		"special_requirements": special_requirements.duplicate(true),
		"governor_aptitudes": governor_aptitudes.duplicate(true),
		"progress_mode": progress_mode,
		"cost": cost.duplicate(true),
		"duration_class": _get_domestic_tech_duration_class_mvp(tier, rarity),
		"duration_turns_hint": _get_domestic_tech_duration_turns_hint_mvp(tier, rarity),
		"effect_stub": {"enabled": false, "type": effect_type, "value": effect_value, "description": effect_description},
		"unlocks_city_techs": unlocks_city_techs.duplicate(true),
		"enhances_city_techs": enhances_city_techs.duplicate(true),
	}


func _get_domestic_tech_duration_class_mvp(tier: int, rarity: int) -> String:
	if rarity >= 2:
		return "legendary"
	if rarity >= 1 or tier >= 4:
		return "advanced"
	if tier >= 3:
		return "mid"
	return "basic"


func _get_domestic_tech_duration_turns_hint_mvp(tier: int, rarity: int) -> Dictionary:
	var duration_class := _get_domestic_tech_duration_class_mvp(tier, rarity)
	match duration_class:
		"basic":
			return {"min": 3, "max": 5}
		"mid":
			return {"min": 8, "max": 10}
		"advanced":
			return {"min": 15, "max": 20}
		"legendary":
			return {"min": 25, "max": 30}
		_:
			return {"min": 3, "max": 5}


func _get_domestic_tech_definitions_mvp() -> Dictionary:
	var definitions := _get_domestic_city_tech_definitions_mvp()
	var national_definitions := _get_domestic_national_tech_definitions_mvp()
	for tech_id_variant in national_definitions.keys():
		var tech_id := str(tech_id_variant)
		definitions[tech_id] = national_definitions.get(tech_id_variant)
	return definitions


func _get_domestic_tech_definition_mvp(tech_id: String) -> Dictionary:
	var definitions := _get_domestic_tech_definitions_mvp()
	var definition: Variant = definitions.get(tech_id, {})
	if definition is Dictionary:
		return (definition as Dictionary).duplicate(true)
	return {}


func _get_domestic_techs_by_scope_mvp(scope: String) -> Array:
	var result: Array[String] = []
	for tech_id_variant in _get_domestic_tech_definitions_mvp().keys():
		var tech_id := str(tech_id_variant)
		var definition := _get_domestic_tech_definition_mvp(tech_id)
		if str(definition.get("tree_scope", "")) == scope:
			result.append(tech_id)
	result.sort()
	return result


func _get_domestic_techs_by_category_mvp(category_id: String) -> Array:
	var result: Array[String] = []
	for tech_id_variant in _get_domestic_tech_definitions_mvp().keys():
		var tech_id := str(tech_id_variant)
		var definition := _get_domestic_tech_definition_mvp(tech_id)
		if str(definition.get("category", "")) == category_id:
			result.append(tech_id)
	result.sort()
	return result


func _get_domestic_techs_by_branch_mvp(category_id: String, branch_id: String) -> Array:
	var result: Array[String] = []
	for tech_id_variant in _get_domestic_tech_definitions_mvp().keys():
		var tech_id := str(tech_id_variant)
		var definition := _get_domestic_tech_definition_mvp(tech_id)
		if str(definition.get("category", "")) == category_id and str(definition.get("branch", "")) == branch_id:
			result.append(tech_id)
	result.sort()
	return result


func _is_domestic_city_tech_mvp(tech_id: String) -> bool:
	return _get_domestic_city_tech_definitions_mvp().has(tech_id)


func _is_domestic_national_tech_mvp(tech_id: String) -> bool:
	return _get_domestic_national_tech_definitions_mvp().has(tech_id)


func _is_city_domestic_tech_completed_mvp(city_id: String, tech_id: String) -> bool:
	if city_id.is_empty() or not _is_domestic_city_tech_mvp(tech_id):
		return false
	var completed_by_city: Dictionary = _player_state.get("city_domestic_tech_completed", {})
	var city_completed: Variant = completed_by_city.get(city_id, {})
	if city_completed is Dictionary:
		return bool((city_completed as Dictionary).get(tech_id, false))
	return false


func _is_national_domestic_tech_completed_mvp(tech_id: String) -> bool:
	if not _is_domestic_national_tech_mvp(tech_id):
		return false
	var completed: Dictionary = _player_state.get("national_domestic_tech_completed", {})
	return bool(completed.get(tech_id, false))


func _are_domestic_tech_prerequisites_met_mvp(city_id: String, tech_id: String) -> bool:
	var definition := _get_domestic_tech_definition_mvp(tech_id)
	if definition.is_empty():
		return false
	for required_id_variant in definition.get("prerequisites", []):
		var required_id := str(required_id_variant)
		if _is_domestic_city_tech_mvp(tech_id):
			if not _is_city_domestic_tech_completed_mvp(city_id, required_id):
				return false
		elif not _is_national_domestic_tech_completed_mvp(required_id):
			return false
	return true


func _are_domestic_tech_national_requirements_met_mvp(tech_id: String) -> bool:
	var definition := _get_domestic_tech_definition_mvp(tech_id)
	if definition.is_empty():
		return false
	for required_id_variant in definition.get("required_national_techs", []):
		if not _is_national_domestic_tech_completed_mvp(str(required_id_variant)):
			return false
	return true


func _get_available_city_domestic_tech_ids_mvp(city_id: String) -> Array:
	_normalize_domestic_tech_state_mvp()
	var result: Array[String] = []
	if city_id.is_empty() or _get_city_hud_entry(city_id).is_empty():
		return result
	for tech_id_variant in _get_domestic_city_tech_definitions_mvp().keys():
		var tech_id := str(tech_id_variant)
		if _is_city_domestic_tech_completed_mvp(city_id, tech_id):
			continue
		if not _are_domestic_tech_prerequisites_met_mvp(city_id, tech_id):
			continue
		if not _are_domestic_tech_national_requirements_met_mvp(tech_id):
			continue
		if not _are_domestic_tech_city_requirements_met_mvp(city_id, tech_id):
			continue
		result.append(tech_id)
	result.sort()
	return result


func _get_available_national_domestic_tech_ids_mvp() -> Array:
	_normalize_domestic_tech_state_mvp()
	var result: Array[String] = []
	for tech_id_variant in _get_domestic_national_tech_definitions_mvp().keys():
		var tech_id := str(tech_id_variant)
		if _is_national_domestic_tech_completed_mvp(tech_id):
			continue
		if _are_domestic_tech_prerequisites_met_mvp("", tech_id):
			result.append(tech_id)
	result.sort()
	return result


func _are_domestic_tech_city_requirements_met_mvp(city_id: String, tech_id: String) -> bool:
	var definition := _get_domestic_tech_definition_mvp(tech_id)
	var special_requirements: Dictionary = definition.get("special_requirements", {})
	var city_requirements: Dictionary = special_requirements.get("city_requirements", {})
	if bool(city_requirements.get("coastal", false)) and not _is_city_coastal_for_city_tech(city_id):
		return false
	return true


func _get_domestic_tech_icon_path_mvp(tech_id: String) -> String:
	return str(_get_domestic_tech_definition_mvp(tech_id).get("icon_path", ""))


func _is_domestic_tech_icon_missing_mvp(tech_id: String) -> bool:
	return bool(_get_domestic_tech_definition_mvp(tech_id).get("icon_missing", true))


func _get_domestic_tech_icon_fallback_label_mvp(tech_id: String) -> String:
	return str(_get_domestic_tech_definition_mvp(tech_id).get("icon_fallback_label", DOMESTIC_TECH_ICON_FALLBACK_LABEL))


func _open_domestic_tech_tree_overlay_mvp() -> void:
	_ensure_domestic_tech_tree_overlay_mvp()
	if _tech_tree_overlay_mvp == null:
		return
	_hide_worldmap_panels_for_tech_tree_mvp()
	_refresh_domestic_tech_tree_overlay_mvp()
	_tech_tree_overlay_mvp.visible = true
	_tech_tree_overlay_mvp.mouse_filter = Control.MOUSE_FILTER_STOP
	_tech_tree_overlay_mvp.z_as_relative = false
	_tech_tree_overlay_mvp.z_index = 4096
	_tech_tree_overlay_mvp.move_to_front()


func _close_domestic_tech_tree_overlay_mvp() -> void:
	if _tech_tree_overlay_mvp != null:
		_tech_tree_overlay_mvp.visible = false
	_restore_worldmap_panels_after_tech_tree_mvp()


func _is_domestic_tech_tree_overlay_open_mvp() -> bool:
	return _tech_tree_overlay_mvp != null and _tech_tree_overlay_mvp.visible


func _hide_worldmap_panels_for_tech_tree_mvp() -> void:
	if not _tech_tree_hidden_ui_state_mvp.is_empty():
		return
	_register_tech_tree_hidden_panel_mvp(world_title_panel, "world_title_panel")
	_register_tech_tree_hidden_panel_mvp(right_hud_dragbar, "right_hud_dragbar")
	_register_tech_tree_hidden_panel_mvp(left_world_status_panel, "left_world_status_panel")
	_register_tech_tree_hidden_panel_mvp(city_info_panel_control, "city_info_panel")
	_register_tech_tree_hidden_panel_mvp(city_detail_panel, "city_detail_panel")
	_register_tech_tree_hidden_panel_mvp(diplomacy_spy_panel, "diplomacy_spy_panel")
	_register_tech_tree_hidden_panel_mvp(_manual_trade_order_panel, "manual_trade_order_panel")
	_register_tech_tree_hidden_panel_mvp(_internal_trade_transfer_panel, "internal_trade_transfer_panel")
	_register_tech_tree_hidden_panel_mvp(_worldmap_help_modal, "worldmap_help_modal")
	_register_tech_tree_hidden_panel_mvp(_player_attack_deployment_panel as CanvasItem, "player_attack_deployment_panel")


func _restore_worldmap_panels_after_tech_tree_mvp() -> void:
	for key in _tech_tree_hidden_ui_state_mvp.keys():
		var entry: Dictionary = _tech_tree_hidden_ui_state_mvp.get(key, {})
		var node_variant: Variant = entry.get("node", null)
		if not is_instance_valid(node_variant):
			continue
		var canvas_item := node_variant as CanvasItem
		if canvas_item == null:
			continue
		canvas_item.visible = bool(entry.get("visible", false))
	_tech_tree_hidden_ui_state_mvp.clear()


func _register_tech_tree_hidden_panel_mvp(panel: CanvasItem, key: String) -> void:
	if panel == null or not is_instance_valid(panel):
		return
	if panel == _tech_tree_overlay_mvp:
		return
	_tech_tree_hidden_ui_state_mvp[key] = {
		"node": panel,
		"visible": panel.visible,
	}
	if panel.visible:
		panel.visible = false


func _ensure_domestic_tech_tree_overlay_mvp() -> void:
	if _tech_tree_overlay_mvp != null:
		return
	var world_ui := get_node_or_null("WorldMapUI") as CanvasLayer
	if world_ui == null:
		return

	_tech_tree_overlay_mvp = PanelContainer.new()
	_tech_tree_overlay_mvp.name = "tech_tree_overlay_mvp"
	_tech_tree_overlay_mvp.visible = false
	_tech_tree_overlay_mvp.mouse_filter = Control.MOUSE_FILTER_STOP
	_tech_tree_overlay_mvp.z_as_relative = false
	_tech_tree_overlay_mvp.z_index = 4096
	_tech_tree_overlay_mvp.add_theme_stylebox_override("panel", _make_domestic_tech_overlay_style_mvp())
	_tech_tree_overlay_mvp.set_anchors_preset(Control.PRESET_FULL_RECT)
	_tech_tree_overlay_mvp.offset_left = DOMESTIC_TECH_TREE_OVERLAY_MARGIN
	_tech_tree_overlay_mvp.offset_top = DOMESTIC_TECH_TREE_OVERLAY_MARGIN
	_tech_tree_overlay_mvp.offset_right = -DOMESTIC_TECH_TREE_OVERLAY_MARGIN
	_tech_tree_overlay_mvp.offset_bottom = -DOMESTIC_TECH_TREE_OVERLAY_MARGIN
	world_ui.add_child(_tech_tree_overlay_mvp)
	_tech_tree_overlay_mvp.move_to_front()

	var outer_margin := MarginContainer.new()
	outer_margin.name = "DomesticTechTreeOverlayMargin"
	outer_margin.add_theme_constant_override("margin_left", 14)
	outer_margin.add_theme_constant_override("margin_top", 12)
	outer_margin.add_theme_constant_override("margin_right", 14)
	outer_margin.add_theme_constant_override("margin_bottom", 12)
	_tech_tree_overlay_mvp.add_child(outer_margin)

	_tech_tree_content_root_mvp = VBoxContainer.new()
	_tech_tree_content_root_mvp.name = "DomesticTechTreeOverlayContent"
	_tech_tree_content_root_mvp.add_theme_constant_override("separation", 8)
	outer_margin.add_child(_tech_tree_content_root_mvp)


func _refresh_domestic_tech_tree_overlay_mvp() -> void:
	if _tech_tree_content_root_mvp == null:
		return
	_clear_domestic_tech_tree_children_mvp(_tech_tree_content_root_mvp)

	var header_row := HBoxContainer.new()
	header_row.name = "DomesticTechTreeHeaderRow"
	header_row.add_theme_constant_override("separation", 8)
	_tech_tree_content_root_mvp.add_child(header_row)

	var title_box := VBoxContainer.new()
	title_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_box.add_theme_constant_override("separation", 2)
	header_row.add_child(title_box)

	var title_label := _make_domestic_tech_label_mvp("삼국WAR 테크트리", 24, Color(1.0, 0.84, 0.42, 1.0))
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_box.add_child(title_label)

	var selected_city_name := "도시 미선택"
	if selected_city_marker != null:
		selected_city_name = selected_city_marker.display_name
	var sub_label := _make_domestic_tech_label_mvp("국가 테크: PLAYER 조정 기준 · 도시 테크: 현재 선택 도시(%s) 기준 · 건설 시간/★/잠금 조건은 표시 전용" % selected_city_name, 12, Color(0.82, 0.84, 0.78, 1.0))
	sub_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_box.add_child(sub_label)

	var close_button := Button.new()
	close_button.name = "DomesticTechTreeCloseButton"
	close_button.text = "닫기"
	close_button.custom_minimum_size = Vector2(72.0, 30.0)
	close_button.focus_mode = Control.FOCUS_NONE
	close_button.pressed.connect(_close_domestic_tech_tree_overlay_mvp)
	header_row.add_child(close_button)

	var split := HBoxContainer.new()
	split.name = "DomesticTechTreeSplit"
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split.add_theme_constant_override("separation", 10)
	_tech_tree_content_root_mvp.add_child(split)

	_build_national_tech_tree_panel_mvp(split)
	_build_city_tech_tree_panel_mvp(split, selected_city_id)


func _build_national_tech_tree_panel_mvp(parent: Container) -> void:
	var panel := _make_domestic_tech_section_panel_mvp("NationalTechTreePanelMVP")
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(panel)

	var content := _make_domestic_tech_section_content_mvp(panel)
	content.add_child(_make_domestic_tech_label_mvp("좌측: 국가 테크트리", 17, Color(1.0, 0.86, 0.54, 1.0)))
	content.add_child(_make_domestic_tech_label_mvp("PLAYER 국가 기준 · 적국 국가 정보 미표시", 11, Color(0.70, 0.76, 0.80, 1.0)))

	var scroll := _make_domestic_tech_scroll_mvp()
	content.add_child(scroll)
	var list := VBoxContainer.new()
	list.name = "NationalTechList"
	list.add_theme_constant_override("separation", 8)
	scroll.add_child(list)

	for category_id in [DOMESTIC_TECH_CATEGORY_NATION_ADMIN, DOMESTIC_TECH_CATEGORY_NATION_ECONOMY, DOMESTIC_TECH_CATEGORY_NATION_MILITARY, DOMESTIC_TECH_CATEGORY_NATION_DIPLOMACY]:
		_build_domestic_tech_category_group_mvp(list, category_id, "", DOMESTIC_TECH_SCOPE_NATIONAL)


func _build_city_tech_tree_panel_mvp(parent: Container, city_id: String) -> void:
	var panel := _make_domestic_tech_section_panel_mvp("CityTechTreePanelMVP")
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(panel)

	var content := _make_domestic_tech_section_content_mvp(panel)
	content.add_child(_make_domestic_tech_label_mvp("우측: 도시 테크트리", 17, Color(1.0, 0.86, 0.54, 1.0)))

	if city_id.is_empty() or selected_city_marker == null:
		content.add_child(_make_domestic_tech_label_mvp("도시를 선택하면 도시 테크트리가 표시됩니다.", 13, Color(0.82, 0.84, 0.78, 1.0)))
		return

	content.add_child(_make_domestic_tech_label_mvp("현재 선택 도시: %s" % _format_city_name_by_id(city_id, city_id), 11, Color(0.70, 0.76, 0.80, 1.0)))
	if not _is_city_owned_by_player_mvp(city_id):
		content.add_child(_make_domestic_tech_label_mvp("선택 도시의 내정 테크 정보가 부족합니다.\n첩보 또는 도시 정보 확보 후 확인할 수 있습니다.", 13, Color(0.72, 0.74, 0.76, 1.0)))
		return

	var scroll := _make_domestic_tech_scroll_mvp()
	content.add_child(scroll)
	var list := VBoxContainer.new()
	list.name = "CityTechList"
	list.add_theme_constant_override("separation", 8)
	scroll.add_child(list)

	for category_id in [DOMESTIC_TECH_CATEGORY_AGRI, DOMESTIC_TECH_CATEGORY_FISH, DOMESTIC_TECH_CATEGORY_COMMERCE, DOMESTIC_TECH_CATEGORY_MILITARY]:
		_build_domestic_tech_category_group_mvp(list, category_id, city_id, DOMESTIC_TECH_SCOPE_CITY)


func _build_domestic_tech_category_group_mvp(parent: Container, category_id: String, city_id: String, scope: String) -> void:
	var definitions := _get_sorted_domestic_tech_definitions_for_category_mvp(category_id, scope)
	if definitions.is_empty():
		return
	var category_data: Dictionary = _get_domestic_tech_categories_mvp().get(category_id, {})
	var category_label := str(category_data.get("name", category_id))
	parent.add_child(_make_domestic_tech_label_mvp(category_label, 15, Color(0.95, 0.78, 0.40, 1.0)))
	parent.add_child(_make_domestic_tech_label_mvp("branch graph · 선행 테크 연결선 표시", 10, Color(0.62, 0.66, 0.66, 1.0)))
	_build_domestic_tech_graph_canvas_mvp(parent, definitions, city_id, scope)


func _build_domestic_tech_graph_canvas_mvp(parent: Container, tech_defs: Array[Dictionary], city_id: String, scope: String) -> void:
	if tech_defs.is_empty():
		return
	var graph_canvas := Control.new()
	graph_canvas.name = "DomesticTechGraphCanvas_%s" % str(tech_defs[0].get("category", "unknown"))
	graph_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var positions := _get_domestic_tech_graph_positions_mvp(tech_defs)
	var graph_size := _get_domestic_tech_graph_canvas_size_mvp(positions)
	graph_canvas.custom_minimum_size = graph_size
	graph_canvas.size = graph_size
	parent.add_child(graph_canvas)

	var line_layer := Control.new()
	line_layer.name = "DomesticTechGraphLineLayer"
	line_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	line_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	graph_canvas.add_child(line_layer)

	var node_layer := Control.new()
	node_layer.name = "DomesticTechGraphNodeLayer"
	node_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	graph_canvas.add_child(node_layer)

	_add_domestic_tech_graph_branch_labels_mvp(node_layer, positions, tech_defs)
	_add_domestic_tech_graph_lines_mvp(line_layer, positions, tech_defs, city_id, scope)
	for definition in tech_defs:
		_build_domestic_tech_graph_node_mvp(node_layer, definition, positions, city_id)


func _get_domestic_tech_graph_positions_mvp(tech_defs: Array[Dictionary]) -> Dictionary:
	var positions: Dictionary = {}
	var branch_order: Array[String] = []
	var branch_tier_counts: Dictionary = {}
	for definition in tech_defs:
		var branch_id := str(definition.get("branch", ""))
		if not branch_order.has(branch_id):
			branch_order.append(branch_id)
		var tier := maxi(1, int(definition.get("tier", 1)))
		var key := "%s:%d" % [branch_id, tier]
		branch_tier_counts[key] = int(branch_tier_counts.get(key, 0)) + 1
		var local_index := int(branch_tier_counts.get(key, 0)) - 1
		var branch_index := branch_order.find(branch_id)
		var position := Vector2(
			DOMESTIC_TECH_GRAPH_MARGIN.x + float(tier - 1) * DOMESTIC_TECH_GRAPH_TIER_SPACING,
			DOMESTIC_TECH_GRAPH_MARGIN.y + float(branch_index) * DOMESTIC_TECH_GRAPH_BRANCH_SPACING + float(local_index) * DOMESTIC_TECH_GRAPH_BRANCH_STACK_SPACING
		)
		positions[str(definition.get("id", ""))] = Rect2(position, DOMESTIC_TECH_GRAPH_NODE_SIZE)
	return positions


func _get_domestic_tech_graph_canvas_size_mvp(positions: Dictionary) -> Vector2:
	var max_x := 420.0
	var max_y := 220.0
	for rect_variant in positions.values():
		var rect: Rect2 = rect_variant
		max_x = maxf(max_x, rect.position.x + rect.size.x + DOMESTIC_TECH_GRAPH_MARGIN.x)
		max_y = maxf(max_y, rect.position.y + rect.size.y + 18.0)
	return Vector2(max_x, max_y)


func _add_domestic_tech_graph_branch_labels_mvp(parent: Control, positions: Dictionary, tech_defs: Array[Dictionary]) -> void:
	var branch_label_y: Dictionary = {}
	for definition in tech_defs:
		var tech_id := str(definition.get("id", ""))
		if not positions.has(tech_id):
			continue
		var branch_id := str(definition.get("branch", ""))
		var rect: Rect2 = positions.get(tech_id)
		if not branch_label_y.has(branch_id) or rect.position.y < float(branch_label_y.get(branch_id, 0.0)):
			branch_label_y[branch_id] = rect.position.y
	for branch_id_variant in branch_label_y.keys():
		var branch_id := str(branch_id_variant)
		var label := _make_domestic_tech_label_mvp(_format_domestic_tech_branch_label_mvp(branch_id), 11, Color(0.78, 0.68, 0.42, 1.0))
		label.name = "DomesticTechGraphBranchLabel_%s" % branch_id
		label.position = Vector2(DOMESTIC_TECH_GRAPH_MARGIN.x, maxf(0.0, float(branch_label_y.get(branch_id_variant, 0.0)) - 24.0))
		label.custom_minimum_size = Vector2(180.0, 18.0)
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		parent.add_child(label)


func _add_domestic_tech_graph_lines_mvp(line_parent: Control, positions: Dictionary, tech_defs: Array[Dictionary], city_id: String, _scope: String) -> void:
	for definition in tech_defs:
		var child_id := str(definition.get("id", ""))
		if not positions.has(child_id):
			continue
		for required_id_variant in definition.get("prerequisites", []):
			var parent_id := str(required_id_variant)
			if not positions.has(parent_id):
				continue
			var child_state := _get_domestic_tech_view_state_mvp(child_id, city_id)
			var line_state := str(child_state.get("state", DOMESTIC_TECH_VIEW_LOCKED))
			var parent_rect: Rect2 = positions.get(parent_id)
			var child_rect: Rect2 = positions.get(child_id)
			_add_domestic_tech_graph_line_mvp(line_parent, parent_rect, child_rect, line_state)


func _add_domestic_tech_graph_line_mvp(line_parent: Control, from_rect: Rect2, to_rect: Rect2, state_id: String) -> void:
	var from_pos := Vector2(from_rect.position.x + from_rect.size.x, from_rect.position.y + from_rect.size.y * 0.5)
	var to_pos := Vector2(to_rect.position.x, to_rect.position.y + to_rect.size.y * 0.5)
	var mid_x := from_pos.x + maxf(16.0, (to_pos.x - from_pos.x) * 0.5)
	var color := _get_domestic_tech_graph_line_color_mvp(state_id)
	_add_domestic_tech_graph_hline_mvp(line_parent, from_pos.x, mid_x, from_pos.y, color)
	if absf(from_pos.y - to_pos.y) > 1.0:
		_add_domestic_tech_graph_vline_mvp(line_parent, mid_x, from_pos.y, to_pos.y, color)
	_add_domestic_tech_graph_hline_mvp(line_parent, mid_x, to_pos.x, to_pos.y, color)


func _add_domestic_tech_graph_hline_mvp(parent: Control, x1: float, x2: float, y: float, color: Color) -> void:
	var line := ColorRect.new()
	line.name = "DomesticTechGraphHLine"
	line.color = color
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	line.position = Vector2(minf(x1, x2), y - DOMESTIC_TECH_GRAPH_LINE_WIDTH * 0.5)
	line.size = Vector2(maxf(1.0, absf(x2 - x1)), DOMESTIC_TECH_GRAPH_LINE_WIDTH)
	parent.add_child(line)


func _add_domestic_tech_graph_vline_mvp(parent: Control, x: float, y1: float, y2: float, color: Color) -> void:
	var line := ColorRect.new()
	line.name = "DomesticTechGraphVLine"
	line.color = color
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	line.position = Vector2(x - DOMESTIC_TECH_GRAPH_LINE_WIDTH * 0.5, minf(y1, y2))
	line.size = Vector2(DOMESTIC_TECH_GRAPH_LINE_WIDTH, maxf(1.0, absf(y2 - y1)))
	parent.add_child(line)


func _build_domestic_tech_graph_node_mvp(parent: Control, tech_def: Dictionary, positions: Dictionary, city_id: String) -> Control:
	var tech_id := str(tech_def.get("id", ""))
	var rect: Rect2 = positions.get(tech_id, Rect2(Vector2.ZERO, DOMESTIC_TECH_GRAPH_NODE_SIZE))
	var node_panel := _build_domestic_tech_node_mvp(parent, tech_def, city_id)
	node_panel.position = rect.position
	node_panel.custom_minimum_size = rect.size
	node_panel.size = rect.size
	node_panel.mouse_filter = Control.MOUSE_FILTER_PASS
	return node_panel


func _get_domestic_tech_graph_line_color_mvp(state_id: String) -> Color:
	match state_id:
		DOMESTIC_TECH_VIEW_COMPLETED:
			return Color(0.92, 0.78, 0.36, 0.92)
		DOMESTIC_TECH_VIEW_AVAILABLE:
			return Color(0.68, 0.54, 0.28, 0.78)
		DOMESTIC_TECH_VIEW_SPECIAL_LOCKED:
			return Color(0.34, 0.30, 0.25, 0.68)
		_:
			return Color(0.22, 0.22, 0.22, 0.62)


func _build_domestic_tech_node_mvp(parent: Control, tech_def: Dictionary, city_id: String) -> PanelContainer:
	var tech_id := str(tech_def.get("id", ""))
	var view_state := _get_domestic_tech_view_state_mvp(tech_id, city_id)
	var state_id := str(view_state.get("state", DOMESTIC_TECH_VIEW_LOCKED))

	var node_panel := PanelContainer.new()
	node_panel.name = "DomesticTechNode_%s" % tech_id
	node_panel.custom_minimum_size = Vector2(DOMESTIC_TECH_TREE_NODE_WIDTH, 0.0)
	node_panel.add_theme_stylebox_override("panel", _make_domestic_tech_node_style_mvp(state_id))
	parent.add_child(node_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 7)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 7)
	node_panel.add_child(margin)

	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 4)
	margin.add_child(body)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 7)
	body.add_child(header)
	_add_domestic_tech_icon_mvp(header, tech_id)

	var title_box := VBoxContainer.new()
	title_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title_box)
	var title_text := "%s %s" % [str(tech_def.get("name", tech_id)), _format_domestic_tech_rarity_mvp(int(tech_def.get("rarity", 0)))]
	title_box.add_child(_make_domestic_tech_label_mvp(title_text.strip_edges(), 13, _get_domestic_tech_state_text_color_mvp(state_id)))
	title_box.add_child(_make_domestic_tech_label_mvp("Tier %d · %s" % [int(tech_def.get("tier", 0)), _format_domestic_tech_branch_label_mvp(str(tech_def.get("branch", "")))], 10, Color(0.72, 0.75, 0.72, 1.0)))

	body.add_child(_make_domestic_tech_label_mvp(_format_domestic_tech_cost_mvp(tech_def.get("cost", {})), 10, Color(0.86, 0.82, 0.72, 1.0)))
	var effect_stub: Dictionary = tech_def.get("effect_stub", {})
	body.add_child(_make_domestic_tech_label_mvp(str(effect_stub.get("description", "")), 10, _get_domestic_tech_state_body_color_mvp(state_id)))

	var status_line := str(view_state.get("label", "잠김"))
	if bool(view_state.get("is_locked", false)):
		status_line = "[잠김] %s" % status_line
	body.add_child(_make_domestic_tech_label_mvp(status_line, 11, _get_domestic_tech_state_text_color_mvp(state_id)))

	var lock_reasons: Array = view_state.get("lock_reasons", [])
	if not lock_reasons.is_empty():
		var reason_label := _make_domestic_tech_label_mvp("조건: %s" % " / ".join(lock_reasons.slice(0, 3)), 9, Color(0.68, 0.70, 0.70, 1.0))
		body.add_child(reason_label)
	return node_panel


func _get_domestic_tech_view_state_mvp(tech_id: String, city_id: String = "") -> Dictionary:
	_normalize_domestic_tech_state_mvp()
	var definition := _get_domestic_tech_definition_mvp(tech_id)
	if definition.is_empty():
		return {"state": DOMESTIC_TECH_VIEW_LOCKED, "label": "잠김", "lock_reasons": ["정의 없음"], "is_locked": true, "is_special_locked": false}

	var scope := str(definition.get("tree_scope", ""))
	if scope == DOMESTIC_TECH_SCOPE_NATIONAL and _is_national_domestic_tech_completed_mvp(tech_id):
		return {"state": DOMESTIC_TECH_VIEW_COMPLETED, "label": "완료", "lock_reasons": [], "is_locked": false, "is_special_locked": false}
	if scope == DOMESTIC_TECH_SCOPE_CITY and _is_city_domestic_tech_completed_mvp(city_id, tech_id):
		return {"state": DOMESTIC_TECH_VIEW_COMPLETED, "label": "완료", "lock_reasons": [], "is_locked": false, "is_special_locked": false}

	var lock_reasons: Array[String] = []
	if scope == DOMESTIC_TECH_SCOPE_CITY and (city_id.is_empty() or _get_city_hud_entry(city_id).is_empty()):
		lock_reasons.append("도시 선택 필요")

	for required_id_variant in definition.get("prerequisites", []):
		var required_id := str(required_id_variant)
		if scope == DOMESTIC_TECH_SCOPE_CITY:
			if not _is_city_domestic_tech_completed_mvp(city_id, required_id):
				lock_reasons.append("선행: %s" % _get_domestic_tech_display_name_mvp(required_id))
		elif not _is_national_domestic_tech_completed_mvp(required_id):
			lock_reasons.append("선행: %s" % _get_domestic_tech_display_name_mvp(required_id))

	for required_national_id_variant in definition.get("required_national_techs", []):
		var required_national_id := str(required_national_id_variant)
		if not _is_national_domestic_tech_completed_mvp(required_national_id):
			lock_reasons.append("국가: %s" % _get_domestic_tech_display_name_mvp(required_national_id))

	if scope == DOMESTIC_TECH_SCOPE_CITY and not _are_domestic_tech_city_requirements_met_mvp(city_id, tech_id):
		lock_reasons.append("도시 조건")

	if not lock_reasons.is_empty():
		return {"state": DOMESTIC_TECH_VIEW_LOCKED, "label": "잠김", "lock_reasons": lock_reasons, "is_locked": true, "is_special_locked": false}

	var special_reasons := _format_domestic_tech_special_requirements_mvp(definition)
	if not special_reasons.is_empty():
		return {"state": DOMESTIC_TECH_VIEW_SPECIAL_LOCKED, "label": "특수 잠금", "lock_reasons": special_reasons, "is_locked": true, "is_special_locked": true}

	return {"state": DOMESTIC_TECH_VIEW_AVAILABLE, "label": "가능", "lock_reasons": [], "is_locked": false, "is_special_locked": false}


func _get_sorted_domestic_tech_definitions_for_category_mvp(category_id: String, scope: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var source := _get_domestic_city_tech_definitions_mvp()
	if scope == DOMESTIC_TECH_SCOPE_NATIONAL:
		source = _get_domestic_national_tech_definitions_mvp()
	for tech_id_variant in source.keys():
		var definition: Dictionary = source.get(tech_id_variant, {})
		if str(definition.get("category", "")) == category_id and str(definition.get("tree_scope", "")) == scope:
			result.append(definition.duplicate(true))
	result.sort_custom(Callable(self, "_sort_domestic_tech_definition_mvp"))
	return result


func _sort_domestic_tech_definition_mvp(left_definition: Dictionary, right_definition: Dictionary) -> bool:
	var left_branch := str(left_definition.get("branch", ""))
	var right_branch := str(right_definition.get("branch", ""))
	if left_branch != right_branch:
		return left_branch < right_branch
	var left_tier := int(left_definition.get("tier", 0))
	var right_tier := int(right_definition.get("tier", 0))
	if left_tier != right_tier:
		return left_tier < right_tier
	return str(left_definition.get("id", "")) < str(right_definition.get("id", ""))


func _add_domestic_tech_icon_mvp(parent: Container, tech_id: String) -> void:
	var icon_box := PanelContainer.new()
	icon_box.custom_minimum_size = Vector2(DOMESTIC_TECH_TREE_ICON_SIZE, DOMESTIC_TECH_TREE_ICON_SIZE)
	icon_box.add_theme_stylebox_override("panel", _make_domestic_tech_icon_box_style_mvp())
	parent.add_child(icon_box)

	var icon_path := _get_domestic_tech_icon_path_mvp(tech_id)
	var texture: Texture2D = null
	if not _is_domestic_tech_icon_missing_mvp(tech_id) and not icon_path.is_empty() and ResourceLoader.exists(icon_path):
		var loaded_resource := load(icon_path)
		if loaded_resource is Texture2D:
			texture = loaded_resource as Texture2D

	if texture != null:
		var texture_rect := TextureRect.new()
		texture_rect.texture = texture
		texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon_box.add_child(texture_rect)
		texture_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	else:
		var fallback_label := _make_domestic_tech_label_mvp(_get_domestic_tech_icon_fallback_label_mvp(tech_id), 18, Color(0.86, 0.84, 0.76, 1.0))
		fallback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		fallback_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		icon_box.add_child(fallback_label)
		fallback_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _format_domestic_tech_rarity_mvp(rarity: int) -> String:
	var count := clampi(rarity, 0, 2)
	var stars := ""
	for _index in range(count):
		stars += "★"
	return stars


func _format_domestic_tech_cost_mvp(raw_cost: Variant) -> String:
	if not raw_cost is Dictionary:
		return "비용 없음"
	var parts: Array[String] = []
	var order := ["wood", "iron", "gold", "food", "rice", "barley", "seafood", "horses", "silk", "salt"]
	for resource_id in order:
		if (raw_cost as Dictionary).has(resource_id):
			var amount := int((raw_cost as Dictionary).get(resource_id, 0))
			if amount > 0:
				parts.append("%s%d" % [_format_domestic_tech_resource_label_mvp(resource_id), amount])
	for resource_id_variant in (raw_cost as Dictionary).keys():
		var resource_id := str(resource_id_variant)
		if order.has(resource_id):
			continue
		var amount := int((raw_cost as Dictionary).get(resource_id_variant, 0))
		if amount > 0:
			parts.append("%s%d" % [_format_domestic_tech_resource_label_mvp(resource_id), amount])
	if parts.is_empty():
		return "비용 없음"
	return " ".join(parts)


func _format_domestic_tech_resource_label_mvp(resource_id: String) -> String:
	match resource_id:
		"wood":
			return "목재"
		"iron":
			return "철"
		"gold":
			return "금전"
		"food":
			return "식량"
		"rice":
			return "쌀"
		"barley":
			return "보리"
		"seafood":
			return "수산물"
		"horses":
			return "말"
		"silk":
			return "비단"
		"salt":
			return "소금"
		_:
			return resource_id


func _format_domestic_tech_branch_label_mvp(branch_id: String) -> String:
	var labels := {
		"harvest": "기본 수확",
		"livestock": "목축",
		"coastal": "연안",
		"salt": "염업",
		"market": "시장",
		"sea_trade": "해상무역",
		"silk_road": "실크로드",
		"infantry": "보병",
		"archery": "궁병",
		"cavalry": "기병",
		"naval": "수군",
		"defense": "방어",
		"siege": "공성",
		"administration": "행정",
		"bureaucracy": "관료",
		"tax": "세제",
		"currency": "화폐",
		"military": "군사",
		"logistics": "병참",
		"weapon": "무기",
		"diplomacy": "외교",
		"intelligence": "첩보",
		"tribute": "조공",
	}
	return str(labels.get(branch_id, branch_id))


func _format_domestic_tech_special_requirements_mvp(definition: Dictionary) -> Array[String]:
	var result: Array[String] = []
	var raw_requirements: Variant = definition.get("special_requirements", {})
	if not raw_requirements is Dictionary:
		return result
	var requirements := raw_requirements as Dictionary
	for requirement_key_variant in requirements.keys():
		var requirement_key := str(requirement_key_variant)
		var requirement_value: Variant = requirements.get(requirement_key_variant)
		if requirement_key == "city_requirements":
			continue
		match requirement_key:
			"hero_required":
				result.append("영웅: %s" % _format_domestic_tech_requirement_value_mvp(requirement_value))
			"required_hero":
				result.append("영웅: %s" % _format_domestic_tech_requirement_value_mvp(requirement_value))
			"chancellor_aptitudes":
				result.append("재상: %s" % _format_domestic_tech_requirement_value_mvp(requirement_value))
			"average_loyalty":
				result.append("충성도 %s 필요" % str(requirement_value))
			"owned_city_count":
				result.append("보유 도시 %s 필요" % str(requirement_value))
			"required_city_techs":
				result.append("도시 테크: %s" % _format_domestic_tech_requirement_value_mvp(requirement_value))
			"required_city_tech_any":
				result.append("도시 테크 중 하나: %s" % _format_domestic_tech_requirement_value_mvp(requirement_value))
			"required_national_techs":
				result.append("국가 테크: %s" % _format_domestic_tech_requirement_value_mvp(requirement_value))
			"resource_requirements":
				result.append("자원 조건: %s" % _format_domestic_tech_requirement_value_mvp(requirement_value))
			"resource_surplus":
				result.append("잉여 자원: %s" % _format_domestic_tech_requirement_value_mvp(requirement_value))
			_:
				result.append("%s: %s" % [requirement_key, _format_domestic_tech_requirement_value_mvp(requirement_value)])
	return result


func _format_domestic_tech_requirement_value_mvp(value: Variant) -> String:
	if value is Array:
		var parts: Array[String] = []
		for item in value:
			var item_id := str(item)
			if _is_domestic_city_tech_mvp(item_id) or _is_domestic_national_tech_mvp(item_id):
				parts.append(_get_domestic_tech_display_name_mvp(item_id))
			else:
				parts.append(_format_domestic_tech_resource_label_mvp(item_id))
		return ", ".join(parts)
	if value is Dictionary:
		var parts: Array[String] = []
		for key_variant in (value as Dictionary).keys():
			var key := str(key_variant)
			var display_key := key
			if _is_domestic_city_tech_mvp(key) or _is_domestic_national_tech_mvp(key):
				display_key = _get_domestic_tech_display_name_mvp(key)
			else:
				display_key = _format_domestic_tech_resource_label_mvp(key)
			parts.append("%s=%s" % [display_key, str((value as Dictionary).get(key_variant))])
		return ", ".join(parts)
	return str(value)


func _get_domestic_tech_display_name_mvp(tech_id: String) -> String:
	var definition := _get_domestic_tech_definition_mvp(tech_id)
	if definition.is_empty():
		return tech_id
	return str(definition.get("name", tech_id))


func _make_domestic_tech_label_mvp(text: String, font_size: int, font_color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", font_color)
	return label


func _make_domestic_tech_section_panel_mvp(panel_name: String) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.name = panel_name
	panel.mouse_filter = Control.MOUSE_FILTER_PASS
	panel.add_theme_stylebox_override("panel", _make_domestic_tech_section_style_mvp())
	return panel


func _make_domestic_tech_section_content_mvp(panel: PanelContainer) -> VBoxContainer:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 6)
	margin.add_child(content)
	return content


func _make_domestic_tech_scroll_mvp() -> ScrollContainer:
	var scroll := ScrollContainer.new()
	scroll.name = "DomesticTechScroll"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	return scroll


func _clear_domestic_tech_tree_children_mvp(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()


func _make_domestic_tech_overlay_style_mvp() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.025, 0.025, 0.025, 0.985)
	style.border_color = Color(0.72, 0.54, 0.25, 0.95)
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	return style


func _make_domestic_tech_section_style_mvp() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.055, 0.052, 0.045, 0.92)
	style.border_color = Color(0.52, 0.40, 0.22, 0.90)
	style.set_border_width_all(1)
	style.set_corner_radius_all(5)
	return style


func _make_domestic_tech_icon_box_style_mvp() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.05, 0.05, 0.82)
	style.border_color = Color(0.54, 0.45, 0.26, 0.85)
	style.set_border_width_all(1)
	style.set_corner_radius_all(4)
	return style


func _make_domestic_tech_node_style_mvp(state_id: String) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	match state_id:
		DOMESTIC_TECH_VIEW_COMPLETED:
			style.bg_color = Color(0.10, 0.15, 0.09, 0.92)
			style.border_color = Color(0.66, 0.82, 0.40, 0.95)
		DOMESTIC_TECH_VIEW_AVAILABLE:
			style.bg_color = Color(0.10, 0.085, 0.045, 0.90)
			style.border_color = Color(0.78, 0.58, 0.24, 0.92)
		DOMESTIC_TECH_VIEW_SPECIAL_LOCKED:
			style.bg_color = Color(0.07, 0.065, 0.065, 0.86)
			style.border_color = Color(0.50, 0.36, 0.20, 0.82)
		_:
			style.bg_color = Color(0.055, 0.055, 0.055, 0.82)
			style.border_color = Color(0.28, 0.28, 0.28, 0.86)
	style.set_border_width_all(1)
	style.set_corner_radius_all(5)
	return style


func _get_domestic_tech_state_text_color_mvp(state_id: String) -> Color:
	match state_id:
		DOMESTIC_TECH_VIEW_COMPLETED:
			return Color(0.80, 1.0, 0.58, 1.0)
		DOMESTIC_TECH_VIEW_AVAILABLE:
			return Color(1.0, 0.88, 0.58, 1.0)
		DOMESTIC_TECH_VIEW_SPECIAL_LOCKED:
			return Color(0.72, 0.64, 0.54, 1.0)
		_:
			return Color(0.56, 0.58, 0.58, 1.0)


func _get_domestic_tech_state_body_color_mvp(state_id: String) -> Color:
	if state_id == DOMESTIC_TECH_VIEW_LOCKED or state_id == DOMESTIC_TECH_VIEW_SPECIAL_LOCKED:
		return Color(0.58, 0.60, 0.60, 1.0)
	return Color(0.86, 0.88, 0.82, 1.0)


func _normalize_domestic_tech_state_mvp() -> void:
	_player_state["city_domestic_tech_completed"] = _normalize_city_domestic_tech_state_map_mvp(_player_state.get("city_domestic_tech_completed", {}))
	_player_state["city_domestic_tech_unlocked"] = _normalize_city_domestic_tech_state_map_mvp(_player_state.get("city_domestic_tech_unlocked", {}))
	_player_state["national_domestic_tech_completed"] = _normalize_national_domestic_tech_state_map_mvp(_player_state.get("national_domestic_tech_completed", {}))
	_player_state["national_domestic_tech_unlocked"] = _normalize_national_domestic_tech_state_map_mvp(_player_state.get("national_domestic_tech_unlocked", {}))


func _normalize_city_domestic_tech_state_map_mvp(raw_state: Variant) -> Dictionary:
	var normalized := {}
	if not raw_state is Dictionary:
		return normalized
	var city_definitions := _get_domestic_city_tech_definitions_mvp()
	for city_id_variant in (raw_state as Dictionary).keys():
		var city_id := str(city_id_variant)
		var city_value: Variant = (raw_state as Dictionary).get(city_id_variant, {})
		if city_id.is_empty() or not city_value is Dictionary:
			continue
		var city_completed := {}
		for tech_id_variant in (city_value as Dictionary).keys():
			var tech_id := str(tech_id_variant)
			if city_definitions.has(tech_id) and bool((city_value as Dictionary).get(tech_id_variant, false)):
				city_completed[tech_id] = true
		normalized[city_id] = city_completed
	return normalized


func _normalize_national_domestic_tech_state_map_mvp(raw_state: Variant) -> Dictionary:
	var normalized := {}
	if not raw_state is Dictionary:
		return normalized
	var national_definitions := _get_domestic_national_tech_definitions_mvp()
	for tech_id_variant in (raw_state as Dictionary).keys():
		var tech_id := str(tech_id_variant)
		if national_definitions.has(tech_id) and bool((raw_state as Dictionary).get(tech_id_variant, false)):
			normalized[tech_id] = true
	return normalized


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


func _get_completed_national_tech_effect_ids() -> Array:
	return _get_completed_national_tech_ids()


func _is_national_tech_completed(tech_id: String) -> bool:
	_ensure_national_tech_state()
	var completed: Dictionary = (_player_state["national_tech"] as Dictionary).get("completed", {})
	var completed_value: Variant = completed.get(tech_id, false)
	return true if completed_value is Dictionary else bool(completed_value)


func _is_national_tech_in_progress(tech_id: String) -> bool:
	_ensure_national_tech_state()
	var in_progress: Dictionary = (_player_state["national_tech"] as Dictionary).get("in_progress", {})
	return bool(in_progress.get(tech_id, false))


func _get_national_tech_definition(tech_id: String) -> Dictionary:
	var definitions := _get_national_tech_definitions()
	var definition: Variant = definitions.get(tech_id, {})
	if definition is Dictionary:
		return (definition as Dictionary).duplicate(true)
	return {}


func _get_tech_duration_turns(tier: String) -> int:
	match tier:
		"basic":
			return 4
		"mid":
			return 9
		"advanced":
			return 18
		"capstone":
			return 28
		"rare":
			return 30
		_:
			return 9


func _get_tech_definition_duration(definition: Dictionary) -> int:
	if definition.has("duration_turns"):
		return maxi(1, int(definition.get("duration_turns", 1)))
	return _get_tech_duration_turns(str(definition.get("tier", "mid")))


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
	var cost: Dictionary = {}
	if not definition.is_empty():
		var raw_cost: Variant = definition.get("cost", {})
		if raw_cost is Dictionary:
			cost = raw_cost as Dictionary
	var payment_check := _can_pay_generic_resource_cost(cost)
	return {
		"ok": not definition.is_empty() and bool(payment_check.get("ok", false)),
		"cost": cost.duplicate(true),
		"missing": payment_check.get("missing", {}),
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
	_ensure_national_tech_state()
	var start_check := _can_start_national_tech(tech_id)
	if not bool(start_check.get("ok", false)):
		_player_state["last_tech_start_result"] = {
			"ok": false,
			"type": "national",
			"tech_id": tech_id,
			"reasons": start_check.get("reasons", []),
			"turn": maxi(1, int(_player_state.get("turn_number", 1))),
		}
		_player_state["last_national_tech_start_check"] = _player_state["last_tech_start_result"]
		return false
	var definition := _get_national_tech_definition(tech_id)
	var cost: Dictionary = definition.get("cost", {})
	var paid_cost := _apply_generic_resource_cost(cost)
	var duration := _get_tech_definition_duration(definition)
	var national_tech: Dictionary = _player_state["national_tech"]
	var in_progress: Dictionary = national_tech.get("in_progress", {})
	in_progress[tech_id] = {
		"tech_id": tech_id,
		"started_turn": maxi(1, int(_player_state.get("turn_number", 1))),
		"remaining_turns": duration,
		"duration_turns": duration,
		"type": "national",
	}
	national_tech["in_progress"] = in_progress
	_player_state["national_tech"] = national_tech
	_player_state["last_tech_start_result"] = {
		"ok": true,
		"type": "national",
		"tech_id": tech_id,
		"cost": cost.duplicate(true),
		"paid_cost": paid_cost,
		"remaining_turns": duration,
		"duration_turns": duration,
		"turn": maxi(1, int(_player_state.get("turn_number", 1))),
	}
	_player_state["last_national_tech_start_check"] = _player_state["last_tech_start_result"]
	return true


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


func _make_city_tech_definition(id: String, tech_name: String, branch: String, tier: String, requires: Array, required_governor_type: String, required_national_tech: Array, conditions: Dictionary, cost: Dictionary, effect_summary: String) -> Dictionary:
	return {
		"id": id,
		"name": tech_name,
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
	var city_tech: Dictionary = {}
	var raw_city_tech: Variant = city_state.get("city_tech", {})
	if raw_city_tech is Dictionary:
		city_tech = raw_city_tech as Dictionary
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
	var completed: Dictionary = {}
	var raw_completed: Variant = city_tech.get("completed", {})
	if raw_completed is Dictionary:
		completed = raw_completed as Dictionary
	var result: Array[String] = []
	for tech_id_variant in completed.keys():
		var tech_id := str(tech_id_variant)
		if bool(completed.get(tech_id_variant, false)):
			result.append(tech_id)
	return result


func _get_completed_city_tech_effect_ids(city_id: String) -> Array:
	return _get_completed_city_tech_ids(city_id)


func _is_city_tech_completed(city_id: String, tech_id: String) -> bool:
	var city_tech := _ensure_city_tech_state(city_id)
	var completed: Dictionary = {}
	var raw_completed: Variant = city_tech.get("completed", {})
	if raw_completed is Dictionary:
		completed = raw_completed as Dictionary
	var completed_value: Variant = completed.get(tech_id, false)
	return true if completed_value is Dictionary else bool(completed_value)


func _is_city_tech_in_progress(city_id: String, tech_id: String) -> bool:
	var city_tech := _ensure_city_tech_state(city_id)
	var in_progress: Dictionary = {}
	var raw_in_progress: Variant = city_tech.get("in_progress", {})
	if raw_in_progress is Dictionary:
		in_progress = raw_in_progress as Dictionary
	return bool(in_progress.get(tech_id, false))


func _get_city_tech_definition(tech_id: String) -> Dictionary:
	var definitions := _get_city_tech_definitions()
	var definition: Variant = definitions.get(tech_id, {})
	if definition is Dictionary:
		return (definition as Dictionary).duplicate(true)
	return {}


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
	var domestic_seed: Dictionary = {}
	var raw_domestic_seed: Variant = city_data.get("domestic_seed", {})
	if raw_domestic_seed is Dictionary:
		domestic_seed = raw_domestic_seed as Dictionary
	if domestic_seed.has("agriculture"):
		return maxi(0, int(domestic_seed.get("agriculture", 0)))
	var resource_seed: Dictionary = {}
	var raw_resource_seed: Variant = city_data.get("resource_seed", {})
	if raw_resource_seed is Dictionary:
		resource_seed = raw_resource_seed as Dictionary
	return maxi(0, int(resource_seed.get("rice", 0)) + int(resource_seed.get("barley", 0))) * 10


func _get_city_tech_commerce_value(city_id: String) -> int:
	var city_data := _get_city_hud_entry(city_id)
	if city_data.has("commerce"):
		return maxi(0, int(city_data.get("commerce", 0)))
	var domestic_seed: Dictionary = {}
	var raw_domestic_seed: Variant = city_data.get("domestic_seed", {})
	if raw_domestic_seed is Dictionary:
		domestic_seed = raw_domestic_seed as Dictionary
	if domestic_seed.has("commerce"):
		return maxi(0, int(domestic_seed.get("commerce", 0)))
	return maxi(0, int(city_data.get("commerce_rating", 0))) * 20


func _get_city_tech_fishery_value(city_id: String) -> int:
	var city_data := _get_city_hud_entry(city_id)
	if city_data.has("fishery"):
		return maxi(0, int(city_data.get("fishery", 0)))
	var resource_seed: Dictionary = {}
	var raw_resource_seed: Variant = city_data.get("resource_seed", {})
	if raw_resource_seed is Dictionary:
		resource_seed = raw_resource_seed as Dictionary
	return maxi(0, int(resource_seed.get("seafood", 0))) * 20


func _is_city_coastal_for_city_tech(city_id: String) -> bool:
	var city_data := _get_city_hud_entry(city_id)
	var city_type := str(city_data.get("type", ""))
	return city_type.find("coastal") >= 0 or city_type.find("port") >= 0 or city_type.find("maritime") >= 0


func _can_pay_city_tech_cost(city_id: String, tech_id: String) -> Dictionary:
	var definition := _get_city_tech_definition(tech_id)
	var cost: Dictionary = {}
	if not definition.is_empty() and not _get_city_hud_entry(city_id).is_empty():
		var raw_cost: Variant = definition.get("cost", {})
		if raw_cost is Dictionary:
			cost = raw_cost as Dictionary
	var payment_check := _can_pay_generic_resource_cost(cost)
	return {
		"ok": not definition.is_empty() and not _get_city_hud_entry(city_id).is_empty() and bool(payment_check.get("ok", false)),
		"cost": cost.duplicate(true),
		"missing": payment_check.get("missing", {}),
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
	_ensure_city_tech_state(city_id)
	var start_check := _can_start_city_tech(city_id, tech_id)
	if not bool(start_check.get("ok", false)):
		_player_state["last_tech_start_result"] = {
			"ok": false,
			"type": "city",
			"city_id": city_id,
			"tech_id": tech_id,
			"reasons": start_check.get("reasons", []),
			"turn": maxi(1, int(_player_state.get("turn_number", 1))),
		}
		_player_state["last_city_tech_start_check"] = _player_state["last_tech_start_result"]
		return false
	var definition := _get_city_tech_definition(tech_id)
	var cost: Dictionary = definition.get("cost", {})
	var paid_cost := _apply_generic_resource_cost(cost)
	var duration := _get_tech_definition_duration(definition)
	var city_state := _get_mutable_city_runtime_state(city_id)
	var city_tech: Dictionary = city_state.get("city_tech", {})
	var in_progress: Dictionary = {}
	var raw_in_progress: Variant = city_tech.get("in_progress", {})
	if raw_in_progress is Dictionary:
		in_progress = raw_in_progress as Dictionary
	in_progress[tech_id] = {
		"city_id": city_id,
		"tech_id": tech_id,
		"started_turn": maxi(1, int(_player_state.get("turn_number", 1))),
		"remaining_turns": duration,
		"duration_turns": duration,
		"type": "city",
	}
	city_tech["in_progress"] = in_progress
	city_state["city_tech"] = city_tech
	_city_runtime_states[city_id] = city_state
	_player_state["last_tech_start_result"] = {
		"ok": true,
		"type": "city",
		"city_id": city_id,
		"tech_id": tech_id,
		"cost": cost.duplicate(true),
		"paid_cost": paid_cost,
		"remaining_turns": duration,
		"duration_turns": duration,
		"turn": maxi(1, int(_player_state.get("turn_number", 1))),
	}
	_player_state["last_city_tech_start_check"] = _player_state["last_tech_start_result"]
	return true


func _advance_national_tech_progress_for_world_turn() -> Dictionary:
	_ensure_national_tech_state()
	var turn_number := maxi(1, int(_player_state.get("turn_number", 1)))
	var result := {"turn": turn_number, "advanced": [], "completed": []}
	var national_tech: Dictionary = _player_state["national_tech"]
	var in_progress: Dictionary = national_tech.get("in_progress", {})
	var completed: Dictionary = national_tech.get("completed", {})
	for tech_id_variant in in_progress.keys().duplicate():
		var tech_id := str(tech_id_variant)
		var entry_variant: Variant = in_progress.get(tech_id_variant, {})
		if not entry_variant is Dictionary:
			continue
		var entry := (entry_variant as Dictionary).duplicate(true)
		var before_remaining := maxi(0, int(entry.get("remaining_turns", 0)))
		var after_remaining := before_remaining - 1
		var definition := _get_national_tech_definition(tech_id)
		if after_remaining <= 0:
			var completed_entry := {
				"completed_turn": turn_number,
				"tech_id": tech_id,
				"effect_summary": str(definition.get("effect_summary", "")),
				"effect_applied": false,
			}
			completed[tech_id] = completed_entry
			in_progress.erase(tech_id_variant)
			(result["completed"] as Array).append(completed_entry)
		else:
			entry["remaining_turns"] = after_remaining
			in_progress[tech_id] = entry
			(result["advanced"] as Array).append({
				"tech_id": tech_id,
				"before_remaining": before_remaining,
				"after_remaining": after_remaining,
				"type": "national",
			})
	national_tech["in_progress"] = in_progress
	national_tech["completed"] = completed
	_player_state["national_tech"] = national_tech
	_player_state["last_national_tech_progress_result"] = result
	return result


func _advance_city_tech_progress_for_world_turn() -> Dictionary:
	var turn_number := maxi(1, int(_player_state.get("turn_number", 1)))
	var result := {"turn": turn_number, "advanced": [], "completed": []}
	for city_id_variant in _city_runtime_states.keys():
		var city_id := str(city_id_variant)
		var city_state: Variant = _city_runtime_states.get(city_id, {})
		if not city_state is Dictionary:
			continue
		var source := (city_state as Dictionary).duplicate(true)
		if not source.has("city_tech") or not source.get("city_tech") is Dictionary:
			continue
		var city_tech: Dictionary = source.get("city_tech", {})
		var in_progress: Dictionary = {}
		var raw_in_progress: Variant = city_tech.get("in_progress", {})
		if raw_in_progress is Dictionary:
			in_progress = raw_in_progress as Dictionary
		var completed: Dictionary = {}
		var raw_completed: Variant = city_tech.get("completed", {})
		if raw_completed is Dictionary:
			completed = raw_completed as Dictionary
		for tech_id_variant in in_progress.keys().duplicate():
			var tech_id := str(tech_id_variant)
			var entry_variant: Variant = in_progress.get(tech_id_variant, {})
			if not entry_variant is Dictionary:
				continue
			var entry := (entry_variant as Dictionary).duplicate(true)
			var before_remaining := maxi(0, int(entry.get("remaining_turns", 0)))
			var after_remaining := before_remaining - 1
			var definition := _get_city_tech_definition(tech_id)
			if after_remaining <= 0:
				var completed_entry := {
					"completed_turn": turn_number,
					"city_id": city_id,
					"tech_id": tech_id,
					"effect_summary": str(definition.get("effect_summary", "")),
					"effect_applied": false,
				}
				completed[tech_id] = completed_entry
				in_progress.erase(tech_id_variant)
				(result["completed"] as Array).append(completed_entry)
			else:
				entry["remaining_turns"] = after_remaining
				in_progress[tech_id] = entry
				(result["advanced"] as Array).append({
					"city_id": city_id,
					"tech_id": tech_id,
					"before_remaining": before_remaining,
					"after_remaining": after_remaining,
					"type": "city",
				})
		city_tech["in_progress"] = in_progress
		city_tech["completed"] = completed
		source["city_tech"] = city_tech
		_city_runtime_states[city_id] = source
	_player_state["last_city_tech_progress_result"] = result
	return result


func _ensure_applied_tech_effect_state() -> void:
	if not _player_state.has("applied_tech_effects") or not (_player_state["applied_tech_effects"] is Dictionary):
		_player_state["applied_tech_effects"] = {}
	var applied: Dictionary = _player_state["applied_tech_effects"]
	if not applied.has("national") or not (applied["national"] is Dictionary):
		applied["national"] = {}
	if not applied.has("city") or not (applied["city"] is Dictionary):
		applied["city"] = {}
	_player_state["applied_tech_effects"] = applied


func _is_national_tech_effect_applied(tech_id: String) -> bool:
	_ensure_applied_tech_effect_state()
	var applied: Dictionary = (_player_state["applied_tech_effects"] as Dictionary).get("national", {})
	return bool(applied.get(tech_id, false))


func _mark_national_tech_effect_applied(tech_id: String) -> void:
	_ensure_applied_tech_effect_state()
	var applied: Dictionary = _player_state["applied_tech_effects"]
	var national_applied: Dictionary = applied.get("national", {})
	national_applied[tech_id] = true
	applied["national"] = national_applied
	_player_state["applied_tech_effects"] = applied


func _apply_completed_tech_effects_for_world_turn() -> Dictionary:
	_ensure_applied_tech_effect_state()
	var turn_number := maxi(1, int(_player_state.get("turn_number", 1)))
	var result := {
		"turn": turn_number,
		"applied": [],
		"recognized_no_consumer": [],
	}
	if _is_national_tech_completed("legal_reform") and not _is_national_tech_effect_applied("legal_reform"):
		var city_results := {}
		var owned_city_ids: Variant = _player_state.get("owned_city_ids", [])
		if owned_city_ids is Array:
			for city_id_variant in owned_city_ids:
				var city_id := str(city_id_variant)
				if not _is_city_owned_by_player_mvp(city_id):
					continue
				var before_support := _get_city_public_support(city_id)
				var after_support := clampi(before_support + 5, 0, 100)
				_set_city_public_support(city_id, after_support)
				city_results[city_id] = {
					"before": before_support,
					"after": after_support,
					"delta": after_support - before_support,
				}
		_mark_national_tech_effect_applied("legal_reform")
		(result["applied"] as Array).append({
			"type": "national",
			"tech_id": "legal_reform",
			"effect": "publicSupport +5",
			"city_results": city_results,
		})
	if _is_national_tech_completed("national_foundation"):
		(result["recognized_no_consumer"] as Array).append({"type": "national", "tech_id": "national_foundation", "reason": "no_consumer_yet"})
	for city_id_variant in _city_runtime_states.keys():
		var city_id := str(city_id_variant)
		if _is_city_tech_completed(city_id, "improved_farming_tools"):
			(result["recognized_no_consumer"] as Array).append({"type": "city", "city_id": city_id, "tech_id": "improved_farming_tools", "reason": "no_consumer_yet"})
		if _is_city_tech_completed(city_id, "fishing_village"):
			(result["recognized_no_consumer"] as Array).append({"type": "city", "city_id": city_id, "tech_id": "fishing_village", "reason": "no_consumer_yet"})
	_player_state["last_tech_effect_result"] = result
	return result


func _get_national_tech_domestic_income_multipliers() -> Dictionary:
	return {"gold": 1.10 if _is_national_tech_completed("tax_reform") else 1.0}


func _get_city_tech_domestic_income_multipliers(city_id: String) -> Dictionary:
	return {"gold": 1.05 if _is_city_tech_completed(city_id, "street_market") else 1.0}


func _apply_tech_income_multipliers_to_effects(city_id: String, city_effects: Dictionary) -> Dictionary:
	var result := city_effects.duplicate(true)
	var national_multipliers := _get_national_tech_domestic_income_multipliers()
	var city_multipliers := _get_city_tech_domestic_income_multipliers(city_id)
	result["gold_multiplier"] = float(result.get("gold_multiplier", 1.0)) * float(national_multipliers.get("gold", 1.0)) * float(city_multipliers.get("gold", 1.0))
	return result


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
	var cost: Dictionary = {}
	var raw_cost: Variant = definition.get("cost", {})
	if raw_cost is Dictionary:
		cost = raw_cost as Dictionary
	for cost_key_variant in cost.keys():
		var cost_key := str(cost_key_variant)
		if not allowed_cost_keys.has(cost_key):
			invalid_cost_keys.append({"scope": scope, "tech_id": tech_id, "cost_key": cost_key})


func _validate_tech_definition_image_fields(scope: String, tech_id: String, definition: Dictionary, missing_image_fields: Array) -> void:
	for field_name in ["icon_path", "image_path"]:
		if not definition.has(field_name):
			missing_image_fields.append({"scope": scope, "tech_id": tech_id, "field": field_name})


func _collect_tech_placeholder_conditions(scope: String, tech_id: String, definition: Dictionary, placeholder_condition_keys: Array, placeholder_conditions: Array) -> void:
	var conditions: Dictionary = {}
	var raw_conditions: Variant = definition.get("conditions", {})
	if raw_conditions is Dictionary:
		conditions = raw_conditions as Dictionary
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
	if _tech_tree_overlay_mvp != null and _tech_tree_overlay_mvp.visible:
		_refresh_domestic_tech_tree_overlay_mvp()


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
	if not _is_city_owner_consistent_for_enemy_invasion_mvp(attacker_city_id):
		return {"ok": false, "message": "침공 도시 소유권 정보가 일치하지 않습니다."}
	if not _is_city_owner_consistent_for_enemy_invasion_mvp(defender_city_id):
		return {"ok": false, "message": "방어 도시 소유권 정보가 일치하지 않습니다."}
	if not _is_city_owned_by_enemy_mvp(attacker_city_id):
		return {"ok": false, "message": "침공 도시가 적 소유가 아닙니다."}
	if not _is_city_owned_by_player_mvp(defender_city_id):
		return {"ok": false, "message": "방어 도시가 아군 소유가 아닙니다."}
	if not _get_city_neighbors_mvp(attacker_city_id).has(defender_city_id):
		return {"ok": false, "message": "침공 도시와 방어 도시가 인접하지 않습니다."}
	if _get_city_troops_for_enemy_invasion_mvp(attacker_city_id) < ENEMY_INVASION_MIN_ATTACKER_CITY_TROOPS:
		return {"ok": false, "message": "침공 도시 병력이 부족합니다."}
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
		return "방어 배치를 선택하십시오."
	if str(battle_context.get("source", "")) != "enemy_invasion":
		return "방어 배치를 선택하십시오."
	if str(battle_context.get("attacker_city_id", "")) != str(event.get("attacker_city_id", "")):
		return "방어 배치를 선택하십시오."
	if str(battle_context.get("defender_city_id", "")) != str(event.get("defender_city_id", "")):
		return "방어 배치를 선택하십시오."
	if str(battle_context.get("mode", "")) == "auto":
		return "자동 방어 준비 완료 · 자동 해결은 아직 미구현"
	return "수동 방어 준비 완료 · 전투 화면 이동 대기"


func _clear_pending_invasion_event_mvp() -> void:
	_player_state["pending_invasion_event"] = {}
	_clear_pending_battle_context_mvp()
	_player_state["enemy_invasion_roll_turn"] = 0


func _format_pending_invasion_detail(event: Dictionary) -> String:
	if event.is_empty():
		return ""
	var attacker_city_name := _format_city_name_by_id(str(event.get("attacker_city_id", "")), "알 수 없는 적 도시")
	var defender_city_name := _format_city_name_by_id(str(event.get("defender_city_id", "")), "알 수 없는 아군 도시")
	return "적 출발: %s\n방어 목표: %s\n진로: %s → %s" % [
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
	return "침공 대기: %s → %s · 방어 배치 필요" % [attacker_city_name, defender_city_name]


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
	var diplomacy_normalize_result := _normalize_faction_relations_for_world_state()
	var diplomacy_cooldown_result := _advance_diplomacy_cooldowns_for_world_turn()
	var spy_cooldown_result := _advance_spy_cooldown_for_world_turn()
	var revolt_instigation_tick_result := _advance_revolt_instigation_for_world_turn()
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
	var national_tech_progress_result := _advance_national_tech_progress_for_world_turn()
	var city_tech_progress_result := _advance_city_tech_progress_for_world_turn()
	var tech_effect_result := _apply_completed_tech_effects_for_world_turn()
	var trade_market_result := _update_trade_market_for_world_turn(supply_states)
	var chancellor_auto_trade_result := _apply_chancellor_auto_trade_for_world_turn(turn_number)
	_player_state["last_domestic_apply_turn"] = turn_number
	_player_state["resources"] = _format_player_resource_summary()
	_player_state["income"] = _format_domestic_apply_summary(applied_delta, applied_loyalty_delta, inter_faction_trade_result, supply_states, city_loyalty_drift_result, public_support_result, seasonal_loyalty_result, conscription_result, revolt_warning_result, national_tech_progress_result, city_tech_progress_result, tech_effect_result, trade_market_result, diplomacy_normalize_result, diplomacy_cooldown_result, spy_cooldown_result)
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
		"diplomacy_normalize_result": diplomacy_normalize_result,
		"diplomacy_cooldown_result": diplomacy_cooldown_result,
		"spy_cooldown_result": spy_cooldown_result,
		"revolt_instigation_tick_result": revolt_instigation_tick_result,
		"supply_state_result": supply_states,
		"inter_faction_trade_result": inter_faction_trade_result,
		"public_support_result": public_support_result,
		"city_loyalty_drift_result": city_loyalty_drift_result,
		"seasonal_loyalty_result": seasonal_loyalty_result,
		"conscription_result": conscription_result,
		"revolt_warning_result": revolt_warning_result,
		"national_tech_progress_result": national_tech_progress_result,
		"city_tech_progress_result": city_tech_progress_result,
		"tech_effect_result": tech_effect_result,
		"trade_market_result": trade_market_result,
		"chancellor_auto_trade_result": chancellor_auto_trade_result,
	}
	return _format_domestic_apply_summary(applied_delta, applied_loyalty_delta, inter_faction_trade_result, supply_states, city_loyalty_drift_result, public_support_result, seasonal_loyalty_result, conscription_result, revolt_warning_result, national_tech_progress_result, city_tech_progress_result, tech_effect_result, trade_market_result, diplomacy_normalize_result, diplomacy_cooldown_result, spy_cooldown_result)


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
		city_effects = _apply_tech_income_multipliers_to_effects(str(city_id), city_effects)
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


func _get_trade_market_base_prices() -> Dictionary:
	return MANUAL_TRADE_PREVIEW_PRICES.duplicate(true)


func _get_trade_resource_display_name(resource_id: String) -> String:
	match resource_id:
		"rice":
			return "쌀"
		"barley":
			return "보리"
		"seafood":
			return "수산물"
		"salt":
			return "소금"
		"silk":
			return "비단"
		"iron":
			return "철"
		"wood":
			return "목재"
		"horses":
			return "말"
		_:
			return resource_id


func _get_trade_season_multiplier(resource_id: String, turn_number: int) -> float:
	var calendar := _get_world_calendar_for_turn(turn_number)
	match str(calendar.get("season", "")):
		"spring":
			if resource_id == "barley":
				return 0.85
		"summer":
			if resource_id == "rice" or resource_id == "barley":
				return 1.10
		"autumn":
			if resource_id == "rice":
				return 0.85
		"winter":
			if resource_id == "rice" or resource_id == "barley" or resource_id == "salt":
				return 1.20
			if resource_id == "seafood":
				return 1.10
	return 1.0


func _get_trade_situation_multiplier(resource_id: String, context: Dictionary = {}) -> float:
	var multiplier := 1.0
	if bool(context.get("war_state", false)) and (resource_id == "iron" or resource_id == "horses"):
		multiplier *= 1.30
	if bool(context.get("abundant_harvest", false)) and (resource_id == "rice" or resource_id == "barley"):
		multiplier *= 0.80
	if bool(context.get("famine", false)) and (resource_id == "rice" or resource_id == "barley"):
		multiplier *= 1.40
	if int(context.get("supply_isolated_count", 0)) > 0 and (resource_id == "rice" or resource_id == "barley" or resource_id == "salt"):
		multiplier *= 1.20
	if bool(context.get("alliance_recently_signed", false)) and resource_id == "silk":
		multiplier *= 1.15
	return multiplier


func _get_trade_market_trend(total_multiplier: float) -> String:
	if total_multiplier >= 1.25:
		return "up_strong"
	if total_multiplier > 1.05:
		return "up"
	if total_multiplier <= 0.85:
		return "down_strong"
	if total_multiplier < 0.95:
		return "down"
	return "flat"


func _calculate_trade_market_prices(turn_number: int, context: Dictionary = {}) -> Dictionary:
	var safe_turn := maxi(1, turn_number)
	var calendar := _get_world_calendar_for_turn(safe_turn)
	var prices := {}
	var base_prices := _get_trade_market_base_prices()
	for resource_id_variant in base_prices.keys():
		var resource_id := str(resource_id_variant)
		var base_price := int(base_prices.get(resource_id, 0))
		var season_multiplier := _get_trade_season_multiplier(resource_id, safe_turn)
		var situation_multiplier := _get_trade_situation_multiplier(resource_id, context)
		var total_multiplier := clampf(season_multiplier * situation_multiplier, 0.80, 1.20)
		prices[resource_id] = {
			"name": _get_trade_resource_display_name(resource_id),
			"base": base_price,
			"base_price": base_price,
			"season_multiplier": season_multiplier,
			"situation_multiplier": situation_multiplier,
			"multiplier": total_multiplier,
			"price": maxi(1, int(round(float(base_price) * total_multiplier))),
			"trend": _get_trade_market_trend(total_multiplier),
		}
	return {
		"turn": safe_turn,
		"season": str(calendar.get("season", "")),
		"season_label": str(calendar.get("season_label", "")),
		"context": context.duplicate(true),
		"prices": prices,
	}


func _get_trade_market_context_from_state(supply_state_result: Dictionary = {}) -> Dictionary:
	var supply_source := supply_state_result
	if supply_source.is_empty():
		var last_supply: Variant = _player_state.get("last_supply_state_result", {})
		if last_supply is Dictionary:
			supply_source = last_supply
	return {
		"war_state": false,
		"famine": false,
		"abundant_harvest": false,
		"alliance_recently_signed": false,
		"supply_isolated_count": int(supply_source.get("isolated_count", 0)),
	}


func _update_trade_market_for_world_turn(supply_state_result: Dictionary = {}) -> Dictionary:
	var context := _get_trade_market_context_from_state(supply_state_result)
	return _ensure_trade_market_for_current_turn(context)


func _normalize_trade_market_result(raw_result: Variant) -> Dictionary:
	if not raw_result is Dictionary:
		return {}
	var raw_dictionary := raw_result as Dictionary
	var turn_number := maxi(0, int(raw_dictionary.get("turn", raw_dictionary.get("trade_market_turn", 0))))
	var raw_prices: Variant = raw_dictionary.get("prices", raw_dictionary.get("trade_market_prices", {}))
	var normalized_prices := {}
	if raw_prices is Dictionary:
		for resource_id in MANUAL_TRADE_RESOURCE_ORDER:
			var entry_variant: Variant = (raw_prices as Dictionary).get(resource_id, {})
			var base_price := maxi(1, int(MANUAL_TRADE_PREVIEW_PRICES.get(resource_id, 1)))
			var price := base_price
			var multiplier := 1.0
			var trend := "flat"
			if entry_variant is Dictionary:
				var entry := entry_variant as Dictionary
				price = maxi(1, int(entry.get("price", base_price)))
				multiplier = clampf(float(entry.get("multiplier", float(price) / float(base_price))), 0.80, 1.20)
				price = maxi(1, int(round(float(base_price) * multiplier)))
				trend = _get_trade_market_trend(multiplier)
			normalized_prices[resource_id] = {
				"name": _get_trade_resource_display_name(resource_id),
				"base": base_price,
				"base_price": base_price,
				"multiplier": multiplier,
				"price": price,
				"trend": trend,
			}
	if normalized_prices.is_empty():
		return {}
	var context_payload := {}
	var context_variant: Variant = raw_dictionary.get("context", {})
	if context_variant is Dictionary:
		context_payload = (context_variant as Dictionary).duplicate(true)
	return {
		"turn": turn_number,
		"season": str(raw_dictionary.get("season", "")),
		"season_label": str(raw_dictionary.get("season_label", "")),
		"context": context_payload,
		"prices": normalized_prices,
	}


func _sync_trade_market_mirror_from_result(result: Dictionary) -> void:
	if result.is_empty():
		_player_state["trade_market_prices"] = {}
		_player_state["trade_market_turn"] = 0
		return
	var prices: Variant = result.get("prices", {})
	if prices is Dictionary:
		_player_state["trade_market_prices"] = (prices as Dictionary).duplicate(true)
	else:
		_player_state["trade_market_prices"] = {}
	_player_state["trade_market_turn"] = maxi(0, int(result.get("turn", 0)))


func _ensure_trade_market_for_current_turn(context: Dictionary = {}) -> Dictionary:
	var turn_number := maxi(1, int(_player_state.get("turn_number", 1)))
	var current_result := _normalize_trade_market_result(_player_state.get("last_trade_market_result", {}))
	if not current_result.is_empty() and int(current_result.get("turn", 0)) == turn_number:
		_player_state["last_trade_market_result"] = current_result
		_sync_trade_market_mirror_from_result(current_result)
		return current_result
	var market_context := context if not context.is_empty() else _get_trade_market_context_from_state()
	var result := _normalize_trade_market_result(_calculate_trade_market_prices(turn_number, market_context))
	_player_state["last_trade_market_result"] = result
	_sync_trade_market_mirror_from_result(result)
	return result


func _get_trade_market_price(resource_id: String) -> int:
	var result := _ensure_trade_market_for_current_turn()
	var prices: Variant = result.get("prices", {})
	var base_price := maxi(1, int(MANUAL_TRADE_PREVIEW_PRICES.get(resource_id, 1)))
	if prices is Dictionary:
		var entry_variant: Variant = (prices as Dictionary).get(resource_id, {})
		if entry_variant is Dictionary:
			return maxi(1, int((entry_variant as Dictionary).get("price", base_price)))
	return base_price


func _get_trade_market_price_snapshot_for_delta(delta: Dictionary) -> Dictionary:
	var snapshot := {}
	for resource_id in MANUAL_TRADE_RESOURCE_ORDER:
		if int(delta.get(resource_id, 0)) != 0:
			snapshot[resource_id] = _get_trade_market_price(resource_id)
	return snapshot


func _get_trade_market_price_snapshot_for_order(order: Dictionary) -> Dictionary:
	var snapshot := {}
	var orders_variant: Variant = order.get("orders", {})
	if not orders_variant is Dictionary:
		return snapshot
	for resource_id in MANUAL_TRADE_RESOURCE_ORDER:
		var item_variant: Variant = (orders_variant as Dictionary).get(resource_id, {})
		if not item_variant is Dictionary:
			continue
		if int((item_variant as Dictionary).get("amount", 0)) > 0 and str((item_variant as Dictionary).get("action", MANUAL_TRADE_ACTION_NONE)) != MANUAL_TRADE_ACTION_NONE:
			snapshot[resource_id] = _get_trade_market_price(resource_id)
	return snapshot


func _format_trade_market_prices_for_external_trade_ui() -> String:
	var result := _ensure_trade_market_for_current_turn()
	var prices: Variant = result.get("prices", {})
	if not prices is Dictionary:
		return ""
	var parts: Array[String] = []
	for resource_id in ["rice", "barley", "seafood", "salt", "silk"]:
		var entry_variant: Variant = (prices as Dictionary).get(resource_id, {})
		if not entry_variant is Dictionary:
			continue
		var entry := entry_variant as Dictionary
		var multiplier := float(entry.get("multiplier", 1.0))
		var percent_delta := int(round((multiplier - 1.0) * 100.0))
		var percent_text := ""
		if percent_delta != 0:
			percent_text = " (%s%%)" % _format_signed_int(percent_delta)
		parts.append("%s %d%s" % [
			str(entry.get("name", _get_trade_resource_display_name(resource_id))),
			int(entry.get("price", _get_trade_market_price(resource_id))),
			percent_text,
		])
	return "" if parts.is_empty() else "시장가: %s" % " / ".join(parts)


func _create_empty_inter_faction_trade_totals() -> Dictionary:
	return {"gold": 0, "rice": 0, "barley": 0, "seafood": 0, "salt": 0}


func _make_faction_relation_key(faction_a: String, faction_b: String) -> String:
	var ids := [faction_a, faction_b]
	ids.sort()
	return "%s|%s" % [str(ids[0]), str(ids[1])]


func _normalize_faction_relation_status(status: String) -> String:
	match status:
		"allied", "trade":
			return FACTION_RELATION_STATUS["ALLIED"]
		"hostile", "war":
			return FACTION_RELATION_STATUS["HOSTILE"]
		"suspended", "trade_suspended", "trade_paused":
			return FACTION_RELATION_STATUS["SUSPENDED"]
		_:
			return FACTION_RELATION_STATUS["NEUTRAL"]


func _get_faction_relation_band(score: int) -> String:
	var normalized_score := clampi(score, DIPLOMACY_SCORE_MIN, DIPLOMACY_SCORE_MAX)
	if normalized_score >= 70:
		return "friendly"
	if normalized_score <= 30:
		return "hostile"
	return "neutral"


func _ensure_faction_relation_entry(faction_a: String, faction_b: String) -> Dictionary:
	if faction_a.is_empty() or faction_b.is_empty() or faction_a == faction_b:
		return {
			"status": FACTION_RELATION_STATUS["NEUTRAL"],
			"score": DIPLOMACY_DEFAULT_SCORE,
			"cooldown": 0,
		}
	if not _player_state.has("faction_relations") or not (_player_state["faction_relations"] is Dictionary):
		_player_state["faction_relations"] = {}
	var relations: Dictionary = _player_state["faction_relations"]
	var relation_key := _make_faction_relation_key(faction_a, faction_b)
	var raw_entry: Variant = relations.get(relation_key, {})
	var entry := {}
	if raw_entry is Dictionary:
		entry = (raw_entry as Dictionary).duplicate(true)
		entry["status"] = _normalize_faction_relation_status(str(entry.get("status", FACTION_RELATION_STATUS["NEUTRAL"])))
	else:
		entry["status"] = _normalize_faction_relation_status(str(raw_entry))
	if not entry.has("score"):
		entry["score"] = DIPLOMACY_DEFAULT_SCORE
	entry["score"] = clampi(int(entry.get("score", DIPLOMACY_DEFAULT_SCORE)), DIPLOMACY_SCORE_MIN, DIPLOMACY_SCORE_MAX)
	if not entry.has("cooldown"):
		entry["cooldown"] = 0
	entry["cooldown"] = maxi(0, int(entry.get("cooldown", 0)))
	if not entry.has("tribute_cooldown"):
		entry["tribute_cooldown"] = 0
	entry["tribute_cooldown"] = maxi(0, int(entry.get("tribute_cooldown", 0)))
	if not entry.has("diplomacy_action_cooldown"):
		entry["diplomacy_action_cooldown"] = 0
	entry["diplomacy_action_cooldown"] = maxi(0, int(entry.get("diplomacy_action_cooldown", 0)))
	if not entry.has("alliance_turns_remaining"):
		entry["alliance_turns_remaining"] = 0
	entry["alliance_turns_remaining"] = maxi(0, int(entry.get("alliance_turns_remaining", 0)))
	if entry["status"] == FACTION_RELATION_STATUS["ALLIED"] and int(entry.get("alliance_turns_remaining", 0)) <= 0:
		entry["status"] = FACTION_RELATION_STATUS["NEUTRAL"]
		entry.erase("alliance_created_turn")
		entry.erase("alliance_resource_package")
		entry.erase("alliance_acceptance_score")
	if not entry.has("trade_agreement_turns_remaining"):
		entry["trade_agreement_turns_remaining"] = 0
	entry["trade_agreement_turns_remaining"] = maxi(0, int(entry.get("trade_agreement_turns_remaining", 0)))
	entry["trade_agreement_active"] = bool(entry.get("trade_agreement_active", false)) and int(entry.get("trade_agreement_turns_remaining", 0)) > 0
	entry["trade_agreement_bonus"] = TRADE_AGREEMENT_MULTIPLIER_BONUS if bool(entry.get("trade_agreement_active", false)) else 0.0
	if bool(entry.get("trade_agreement_active", false)):
		entry["trade_agreement_source"] = str(entry.get("trade_agreement_source", "legacy"))
	else:
		entry.erase("trade_agreement_source")
	if not entry.has("military_support_rejection_count"):
		entry["military_support_rejection_count"] = 0
	entry["military_support_rejection_count"] = maxi(0, int(entry.get("military_support_rejection_count", 0)))
	relations[relation_key] = entry
	_player_state["faction_relations"] = relations
	return entry


func _get_faction_relation_entry(faction_a: String, faction_b: String) -> Dictionary:
	return _ensure_faction_relation_entry(faction_a, faction_b)


func _get_faction_relation_score(faction_a: String, faction_b: String) -> int:
	var entry := _get_faction_relation_entry(faction_a, faction_b)
	return clampi(int(entry.get("score", DIPLOMACY_DEFAULT_SCORE)), DIPLOMACY_SCORE_MIN, DIPLOMACY_SCORE_MAX)


func _get_faction_relation_status(faction_a: String, faction_b: String) -> String:
	if faction_a.is_empty() or faction_b.is_empty() or faction_a == faction_b:
		return FACTION_RELATION_STATUS["NEUTRAL"]
	var entry := _get_faction_relation_entry(faction_a, faction_b)
	return _normalize_faction_relation_status(str(entry.get("status", FACTION_RELATION_STATUS["NEUTRAL"])))


func _adjust_faction_relation_score(faction_a: String, faction_b: String, delta: int, reason: String = "") -> Dictionary:
	var entry := _ensure_faction_relation_entry(faction_a, faction_b)
	var before_score := clampi(int(entry.get("score", DIPLOMACY_DEFAULT_SCORE)), DIPLOMACY_SCORE_MIN, DIPLOMACY_SCORE_MAX)
	var after_score := clampi(before_score + delta, DIPLOMACY_SCORE_MIN, DIPLOMACY_SCORE_MAX)
	entry["score"] = after_score
	var relation_key := _make_faction_relation_key(faction_a, faction_b)
	var relations: Dictionary = _player_state.get("faction_relations", {})
	relations[relation_key] = entry
	_player_state["faction_relations"] = relations
	var result := {
		"faction_a": faction_a,
		"faction_b": faction_b,
		"before_score": before_score,
		"after_score": after_score,
		"delta": after_score - before_score,
		"status": str(entry.get("status", FACTION_RELATION_STATUS["NEUTRAL"])),
		"band": _get_faction_relation_band(after_score),
		"reason": reason,
		"turn": maxi(1, int(_player_state.get("turn_number", 1))),
	}
	_player_state["last_diplomacy_relation_result"] = result
	return result


func _get_player_relation_target_faction_from_key(relation_key: String) -> String:
	var parts := relation_key.split("|", false)
	if parts.size() != 2:
		return ""
	if str(parts[0]) == PLAYER_FACTION_ID:
		return str(parts[1])
	if str(parts[1]) == PLAYER_FACTION_ID:
		return str(parts[0])
	return ""


func _normalize_diplomacy_action_state_from_player_state() -> void:
	if not _player_state.has("last_diplomacy_action_result") or not (_player_state["last_diplomacy_action_result"] is Dictionary):
		_player_state["last_diplomacy_action_result"] = {}
	var raw_cooldowns: Variant = _player_state.get("diplomacy_action_cooldowns", {})
	if raw_cooldowns is Dictionary:
		for target_faction_variant in (raw_cooldowns as Dictionary).keys():
			var target_faction_id := str(target_faction_variant)
			if target_faction_id.is_empty() or target_faction_id == PLAYER_FACTION_ID:
				continue
			var turns_remaining := maxi(0, int((raw_cooldowns as Dictionary).get(target_faction_variant, 0)))
			if turns_remaining <= 0:
				continue
			var relation_entry := _ensure_faction_relation_entry(PLAYER_FACTION_ID, target_faction_id)
			relation_entry["diplomacy_action_cooldown"] = maxi(int(relation_entry.get("diplomacy_action_cooldown", 0)), turns_remaining)
			var relation_key := _make_faction_relation_key(PLAYER_FACTION_ID, target_faction_id)
			var relations: Dictionary = _player_state.get("faction_relations", {})
			relations[relation_key] = relation_entry
			_player_state["faction_relations"] = relations
	var raw_agreements: Variant = _player_state.get("trade_agreements", {})
	if raw_agreements is Dictionary:
		for target_faction_variant in (raw_agreements as Dictionary).keys():
			var target_faction_id := str(target_faction_variant)
			if target_faction_id.is_empty() or target_faction_id == PLAYER_FACTION_ID:
				continue
			var raw_agreement: Variant = (raw_agreements as Dictionary).get(target_faction_variant, {})
			var turns_remaining := 0
			var agreement_source := "diplomacy_action"
			var created_turn := maxi(1, int(_player_state.get("turn_number", 1)))
			if raw_agreement is Dictionary:
				turns_remaining = maxi(0, int((raw_agreement as Dictionary).get("turns_remaining", 0)))
				agreement_source = str((raw_agreement as Dictionary).get("source", agreement_source))
				created_turn = maxi(1, int((raw_agreement as Dictionary).get("created_turn", created_turn)))
			else:
				turns_remaining = maxi(0, int(raw_agreement))
			if turns_remaining <= 0:
				continue
			var relation_entry := _ensure_faction_relation_entry(PLAYER_FACTION_ID, target_faction_id)
			relation_entry["trade_agreement_active"] = true
			relation_entry["trade_agreement_turns_remaining"] = maxi(int(relation_entry.get("trade_agreement_turns_remaining", 0)), turns_remaining)
			relation_entry["trade_agreement_bonus"] = TRADE_AGREEMENT_MULTIPLIER_BONUS
			relation_entry["trade_agreement_source"] = agreement_source
			relation_entry["trade_agreement_created_turn"] = created_turn
			var relation_key := _make_faction_relation_key(PLAYER_FACTION_ID, target_faction_id)
			var relations: Dictionary = _player_state.get("faction_relations", {})
			relations[relation_key] = relation_entry
			_player_state["faction_relations"] = relations
	var raw_alliances: Variant = _player_state.get("alliances", {})
	if raw_alliances is Dictionary:
		for target_faction_variant in (raw_alliances as Dictionary).keys():
			var target_faction_id := str(target_faction_variant)
			if target_faction_id.is_empty() or target_faction_id == PLAYER_FACTION_ID:
				continue
			var raw_alliance: Variant = (raw_alliances as Dictionary).get(target_faction_variant, {})
			var turns_remaining := 0
			var created_turn := maxi(1, int(_player_state.get("turn_number", 1)))
			var resource_package := {}
			var acceptance_score := 0
			if raw_alliance is Dictionary:
				turns_remaining = maxi(0, int((raw_alliance as Dictionary).get("turns_remaining", 0)))
				created_turn = maxi(1, int((raw_alliance as Dictionary).get("created_turn", created_turn)))
				var package_variant: Variant = (raw_alliance as Dictionary).get("resource_package", {})
				if package_variant is Dictionary:
					resource_package = _normalize_diplomacy_resource_package(package_variant as Dictionary)
				acceptance_score = maxi(0, int((raw_alliance as Dictionary).get("acceptance_score", 0)))
			else:
				turns_remaining = maxi(0, int(raw_alliance))
			if turns_remaining <= 0:
				continue
			var relation_entry := _ensure_faction_relation_entry(PLAYER_FACTION_ID, target_faction_id)
			relation_entry["status"] = FACTION_RELATION_STATUS["ALLIED"]
			relation_entry["alliance_turns_remaining"] = maxi(int(relation_entry.get("alliance_turns_remaining", 0)), turns_remaining)
			relation_entry["alliance_created_turn"] = created_turn
			relation_entry["alliance_resource_package"] = resource_package
			relation_entry["alliance_acceptance_score"] = acceptance_score
			var relation_key := _make_faction_relation_key(PLAYER_FACTION_ID, target_faction_id)
			var relations: Dictionary = _player_state.get("faction_relations", {})
			relations[relation_key] = relation_entry
			_player_state["faction_relations"] = relations
	_sync_diplomacy_action_mirror_state_from_relations()


func _sync_diplomacy_action_mirror_state_from_relations() -> void:
	var cooldowns := {}
	var agreements := {}
	var alliances := {}
	var relations_variant: Variant = _player_state.get("faction_relations", {})
	if relations_variant is Dictionary:
		for relation_key_variant in (relations_variant as Dictionary).keys():
			var relation_key := str(relation_key_variant)
			var target_faction_id := _get_player_relation_target_faction_from_key(relation_key)
			if target_faction_id.is_empty():
				continue
			var entry_variant: Variant = (relations_variant as Dictionary).get(relation_key_variant, {})
			if not entry_variant is Dictionary:
				continue
			var entry := entry_variant as Dictionary
			var cooldown_turns := maxi(0, int(entry.get("diplomacy_action_cooldown", 0)))
			if cooldown_turns > 0:
				cooldowns[target_faction_id] = cooldown_turns
			var agreement_turns := maxi(0, int(entry.get("trade_agreement_turns_remaining", 0)))
			if bool(entry.get("trade_agreement_active", false)) and agreement_turns > 0:
				agreements[target_faction_id] = {
					"turns_remaining": agreement_turns,
					"source": str(entry.get("trade_agreement_source", "diplomacy_action")),
					"created_turn": maxi(1, int(entry.get("trade_agreement_created_turn", _player_state.get("turn_number", 1)))),
					"bonus": float(entry.get("trade_agreement_bonus", TRADE_AGREEMENT_MULTIPLIER_BONUS)),
				}
			var alliance_turns := maxi(0, int(entry.get("alliance_turns_remaining", 0)))
			if _normalize_faction_relation_status(str(entry.get("status", FACTION_RELATION_STATUS["NEUTRAL"]))) == FACTION_RELATION_STATUS["ALLIED"] and alliance_turns > 0:
				var package_payload := {}
				var package_payload_variant: Variant = entry.get("alliance_resource_package", {})
				if package_payload_variant is Dictionary:
					package_payload = _normalize_diplomacy_resource_package(package_payload_variant as Dictionary)
				alliances[target_faction_id] = {
					"turns_remaining": alliance_turns,
					"created_turn": maxi(1, int(entry.get("alliance_created_turn", _player_state.get("turn_number", 1)))),
					"resource_package": package_payload,
					"acceptance_score": maxi(0, int(entry.get("alliance_acceptance_score", 0))),
				}
	_player_state["diplomacy_action_cooldowns"] = cooldowns
	_player_state["trade_agreements"] = agreements
	_player_state["alliances"] = alliances


func _get_selected_diplomacy_target() -> Dictionary:
	if selected_city_marker == null:
		return {"ok": false, "reason": "no_city", "message": "도시를 선택해야 합니다."}
	var target_city_id := selected_city_marker.city_id
	var target_faction_id := _get_city_owner_faction_id_for_trade_display(target_city_id)
	if target_faction_id.is_empty():
		return {"ok": false, "reason": "missing_faction", "target_city_id": target_city_id, "message": "소유 세력을 확인할 수 없습니다."}
	return {
		"ok": true,
		"target_city_id": target_city_id,
		"target_faction_id": target_faction_id,
	}


func _get_diplomacy_action_definition(action_id: String) -> Dictionary:
	match action_id:
		DIPLOMACY_ACTION_ENVOY:
			return {"action_id": action_id, "label": "사절 파견", "cost": {"gold": 30}, "relation_delta": 5, "cooldown": 1, "message": "사절을 파견했습니다."}
		DIPLOMACY_ACTION_TRIBUTE:
			return {"action_id": action_id, "label": "조공", "cost": {"gold": 100}, "relation_delta": 12, "cooldown": 2, "message": "조공을 보냈습니다."}
		DIPLOMACY_ACTION_TRADE_AGREEMENT:
			return {"action_id": action_id, "label": "교역 협정", "cost": {"gold": 80}, "relation_delta": 4, "cooldown": 2, "agreement_turns": DIPLOMACY_ACTION_TRADE_AGREEMENT_TURNS, "message": "교역 협정을 체결했습니다."}
		DIPLOMACY_ACTION_RESTORE_RELATIONS:
			return {"action_id": action_id, "label": "관계 회복", "cost": {"gold": 120}, "relation_delta": 18, "cooldown": 3, "message": "관계 회복 협의를 진행했습니다."}
		DIPLOMACY_ACTION_ALLIANCE_PROPOSAL:
			return {"action_id": action_id, "label": "동맹 제안", "cost": DIPLOMACY_ACTION_ALLIANCE_COST.duplicate(true), "relation_delta": 0, "cooldown": 4, "alliance_turns": DIPLOMACY_ACTION_ALLIANCE_TURNS, "message": "동맹을 제안했습니다."}
		_:
			return {}


func _get_diplomacy_action_cooldown(target_faction_id: String) -> int:
	if target_faction_id.is_empty() or target_faction_id == PLAYER_FACTION_ID:
		return 0
	var relation_entry := _ensure_faction_relation_entry(PLAYER_FACTION_ID, target_faction_id)
	var relation_cooldown := maxi(0, int(relation_entry.get("diplomacy_action_cooldown", 0)))
	var cooldowns_variant: Variant = _player_state.get("diplomacy_action_cooldowns", {})
	if cooldowns_variant is Dictionary:
		relation_cooldown = maxi(relation_cooldown, maxi(0, int((cooldowns_variant as Dictionary).get(target_faction_id, 0))))
	return relation_cooldown


func _set_diplomacy_action_cooldown(target_faction_id: String, turns: int) -> void:
	if target_faction_id.is_empty() or target_faction_id == PLAYER_FACTION_ID:
		return
	var relation_entry := _ensure_faction_relation_entry(PLAYER_FACTION_ID, target_faction_id)
	relation_entry["diplomacy_action_cooldown"] = maxi(0, turns)
	var relation_key := _make_faction_relation_key(PLAYER_FACTION_ID, target_faction_id)
	var relations: Dictionary = _player_state.get("faction_relations", {})
	relations[relation_key] = relation_entry
	_player_state["faction_relations"] = relations
	_sync_diplomacy_action_mirror_state_from_relations()


func _validate_diplomacy_action(action_id: String, target_city_id: String = "") -> Dictionary:
	var definition := _get_diplomacy_action_definition(action_id)
	if definition.is_empty():
		return {"ok": false, "reason": "invalid_action", "message": "외교 행동을 확인할 수 없습니다."}
	var resolved_city_id := target_city_id
	var target_faction_id := ""
	if resolved_city_id.is_empty():
		var selected_target := _get_selected_diplomacy_target()
		if not bool(selected_target.get("ok", false)):
			return {"ok": false, "reason": str(selected_target.get("reason", "invalid_target")), "message": str(selected_target.get("message", "외교 대상을 선택해야 합니다.")), "action_id": action_id}
		resolved_city_id = str(selected_target.get("target_city_id", ""))
		target_faction_id = str(selected_target.get("target_faction_id", ""))
	else:
		target_faction_id = _get_city_owner_faction_id_for_trade_display(resolved_city_id)
	if resolved_city_id.is_empty() or target_faction_id.is_empty():
		return {"ok": false, "reason": "invalid_target", "message": "외교 대상을 확인할 수 없습니다.", "action_id": action_id, "target_city_id": resolved_city_id}
	if target_faction_id == PLAYER_FACTION_ID:
		return {"ok": false, "reason": "player_faction", "message": "자국 도시는 외교 대상이 아닙니다.", "action_id": action_id, "target_city_id": resolved_city_id, "target_faction_id": target_faction_id}
	var relation_entry := _ensure_faction_relation_entry(PLAYER_FACTION_ID, target_faction_id)
	var status := _normalize_faction_relation_status(str(relation_entry.get("status", FACTION_RELATION_STATUS["NEUTRAL"])))
	var score := clampi(int(relation_entry.get("score", DIPLOMACY_DEFAULT_SCORE)), DIPLOMACY_SCORE_MIN, DIPLOMACY_SCORE_MAX)
	var action_cooldown := _get_diplomacy_action_cooldown(target_faction_id)
	if action_cooldown > 0:
		return {"ok": false, "reason": "cooldown", "message": "외교 사절단이 아직 복귀하지 않았습니다.", "cooldown": action_cooldown, "action_id": action_id, "target_city_id": resolved_city_id, "target_faction_id": target_faction_id}
	if action_id == DIPLOMACY_ACTION_TRADE_AGREEMENT:
		if status == FACTION_RELATION_STATUS["HOSTILE"] or status == FACTION_RELATION_STATUS["SUSPENDED"]:
			return {"ok": false, "reason": "blocked_relation", "message": "적대 또는 교역 중단 상태에서는 교역 협정을 체결할 수 없습니다.", "status": status, "action_id": action_id, "target_city_id": resolved_city_id, "target_faction_id": target_faction_id}
		if score < 45:
			return {"ok": false, "reason": "relation_score", "message": "관계 점수 45 이상이 필요합니다.", "score": score, "required_score": 45, "action_id": action_id, "target_city_id": resolved_city_id, "target_faction_id": target_faction_id}
	if action_id == DIPLOMACY_ACTION_RESTORE_RELATIONS:
		if status != FACTION_RELATION_STATUS["HOSTILE"] and status != FACTION_RELATION_STATUS["SUSPENDED"]:
			return {"ok": false, "reason": "not_needed", "message": "관계 회복은 적대 또는 교역 중단 상태에서만 진행할 수 있습니다.", "status": status, "action_id": action_id, "target_city_id": resolved_city_id, "target_faction_id": target_faction_id}
	if action_id == DIPLOMACY_ACTION_ALLIANCE_PROPOSAL:
		if status == FACTION_RELATION_STATUS["HOSTILE"] or status == FACTION_RELATION_STATUS["SUSPENDED"]:
			return {"ok": false, "reason": "blocked_relation", "message": "적대 또는 교역 중단 상태에서는 동맹을 제안할 수 없습니다.", "status": status, "action_id": action_id, "target_city_id": resolved_city_id, "target_faction_id": target_faction_id}
		var active_alliance_turns := maxi(0, int(relation_entry.get("alliance_turns_remaining", 0)))
		if status == FACTION_RELATION_STATUS["ALLIED"] and active_alliance_turns > 0:
			return {"ok": false, "reason": "already_allied", "message": "이미 동맹 관계입니다.", "status": status, "alliance_turns": active_alliance_turns, "action_id": action_id, "target_city_id": resolved_city_id, "target_faction_id": target_faction_id}
	var cost: Dictionary = definition.get("cost", {})
	var payment_check := _can_pay_generic_resource_cost(cost)
	if not bool(payment_check.get("ok", false)):
		return {"ok": false, "reason": "resources", "message": "자원이 부족합니다.", "cost": cost, "missing": payment_check.get("missing", {}), "action_id": action_id, "target_city_id": resolved_city_id, "target_faction_id": target_faction_id}
	var result := {
		"ok": true,
		"action_id": action_id,
		"action_label": str(definition.get("label", action_id)),
		"definition": definition,
		"target_city_id": resolved_city_id,
		"target_faction_id": target_faction_id,
		"cost": cost,
		"relation_delta": int(definition.get("relation_delta", 0)),
		"cooldown": maxi(0, int(definition.get("cooldown", 0))),
		"before_score": score,
		"before_status": status,
		"message": str(definition.get("message", "")),
	}
	if action_id == DIPLOMACY_ACTION_ALLIANCE_PROPOSAL:
		var alliance_turns := maxi(1, int(definition.get("alliance_turns", DIPLOMACY_ACTION_ALLIANCE_TURNS)))
		result["alliance_turns"] = alliance_turns
		result["acceptance_score"] = _calculate_alliance_acceptance_chance(target_faction_id, cost, alliance_turns)
		result["required_score"] = ALLIANCE_ACCEPTANCE_THRESHOLD
	return result


func _build_diplomacy_action_failure_result(action_id: String, validation: Dictionary) -> Dictionary:
	var result := {
		"turn": maxi(1, int(_player_state.get("turn_number", 1))),
		"action_id": action_id,
		"action_label": str(_get_diplomacy_action_definition(action_id).get("label", action_id)),
		"target_city_id": str(validation.get("target_city_id", "")),
		"target_faction_id": str(validation.get("target_faction_id", "")),
		"success": false,
		"reason": str(validation.get("reason", "unknown")),
		"message": str(validation.get("message", "외교 행동을 실행하지 못했습니다.")),
	}
	if validation.has("cost"):
		result["cost"] = validation.get("cost", {})
	if validation.has("missing"):
		result["missing"] = validation.get("missing", {})
	if validation.has("cooldown"):
		result["cooldown"] = int(validation.get("cooldown", 0))
	return result


func _apply_diplomacy_action(action_id: String, target_city_id: String = "") -> Dictionary:
	var validation := _validate_diplomacy_action(action_id, target_city_id)
	if not bool(validation.get("ok", false)):
		var failure_result := _build_diplomacy_action_failure_result(action_id, validation)
		_player_state["last_diplomacy_action_result"] = failure_result
		return failure_result
	if action_id == DIPLOMACY_ACTION_ALLIANCE_PROPOSAL:
		return _apply_alliance_diplomacy_action(validation)
	var definition: Dictionary = validation.get("definition", {})
	var target_faction_id := str(validation.get("target_faction_id", ""))
	var cost: Dictionary = validation.get("cost", {})
	var payment_result := _apply_generic_resource_cost(cost)
	var before_score := int(validation.get("before_score", DIPLOMACY_DEFAULT_SCORE))
	var before_status := str(validation.get("before_status", FACTION_RELATION_STATUS["NEUTRAL"]))
	var relation_delta := int(validation.get("relation_delta", 0))
	var relation_result := _adjust_faction_relation_score(PLAYER_FACTION_ID, target_faction_id, relation_delta, "diplomacy_action_%s" % action_id)
	var after_score := int(relation_result.get("after_score", before_score))
	var relation_key := _make_faction_relation_key(PLAYER_FACTION_ID, target_faction_id)
	var relations: Dictionary = _player_state.get("faction_relations", {})
	var relation_entry: Dictionary = relations.get(relation_key, _ensure_faction_relation_entry(PLAYER_FACTION_ID, target_faction_id))
	relation_entry["diplomacy_action_cooldown"] = maxi(0, int(validation.get("cooldown", 0)))
	var agreement_payload := {}
	if action_id == DIPLOMACY_ACTION_TRADE_AGREEMENT:
		var agreement_turns := maxi(1, int(definition.get("agreement_turns", DIPLOMACY_ACTION_TRADE_AGREEMENT_TURNS)))
		relation_entry["trade_agreement_active"] = true
		relation_entry["trade_agreement_turns_remaining"] = agreement_turns
		relation_entry["trade_agreement_bonus"] = TRADE_AGREEMENT_MULTIPLIER_BONUS
		relation_entry["trade_agreement_source"] = "diplomacy_action"
		relation_entry["trade_agreement_created_turn"] = maxi(1, int(_player_state.get("turn_number", 1)))
		agreement_payload = {
			"turns_remaining": agreement_turns,
			"source": "diplomacy_action",
			"created_turn": int(relation_entry.get("trade_agreement_created_turn", 1)),
			"bonus": TRADE_AGREEMENT_MULTIPLIER_BONUS,
		}
		_player_state["last_trade_agreement_result"] = {
			"turn": maxi(1, int(_player_state.get("turn_number", 1))),
			"target_faction_id": target_faction_id,
			"success": true,
			"score": after_score,
			"status": _normalize_faction_relation_status(str(relation_entry.get("status", FACTION_RELATION_STATUS["NEUTRAL"]))),
			"cost": cost,
			"payment": payment_result,
			"duration_turns": agreement_turns,
			"trade_multiplier_bonus": TRADE_AGREEMENT_MULTIPLIER_BONUS,
			"source": "diplomacy_action",
		}
	relations[relation_key] = relation_entry
	_player_state["faction_relations"] = relations
	var after_status := _normalize_faction_relation_status(str(relation_entry.get("status", FACTION_RELATION_STATUS["NEUTRAL"])))
	var result := {
		"turn": maxi(1, int(_player_state.get("turn_number", 1))),
		"action_id": action_id,
		"action_label": str(validation.get("action_label", action_id)),
		"target_city_id": str(validation.get("target_city_id", "")),
		"target_faction_id": target_faction_id,
		"cost": cost,
		"payment": payment_result,
		"relation_delta": after_score - before_score,
		"before_score": before_score,
		"after_score": after_score,
		"before_status": before_status,
		"after_status": after_status,
		"cooldown": int(validation.get("cooldown", 0)),
		"success": true,
		"message": str(validation.get("message", "외교 행동을 실행했습니다.")),
	}
	if not agreement_payload.is_empty():
		result["agreement"] = agreement_payload
	_sync_diplomacy_action_mirror_state_from_relations()
	_player_state["last_diplomacy_action_result"] = result
	return result


func _apply_alliance_diplomacy_action(validation: Dictionary) -> Dictionary:
	var target_faction_id := str(validation.get("target_faction_id", ""))
	var package: Dictionary = validation.get("cost", {})
	var alliance_turns := maxi(1, int(validation.get("alliance_turns", DIPLOMACY_ACTION_ALLIANCE_TURNS)))
	_propose_alliance(target_faction_id, package, alliance_turns)
	_set_diplomacy_action_cooldown(target_faction_id, maxi(0, int(validation.get("cooldown", 0))))
	var result_variant: Variant = _player_state.get("last_alliance_proposal_result", {})
	var result := {}
	if result_variant is Dictionary:
		result = (result_variant as Dictionary).duplicate(true)
	if result.is_empty():
		result = _build_diplomacy_action_failure_result(DIPLOMACY_ACTION_ALLIANCE_PROPOSAL, {"reason": "unknown", "message": "동맹 제안 결과를 확인할 수 없습니다.", "target_faction_id": target_faction_id, "cost": package})
	result["action_id"] = DIPLOMACY_ACTION_ALLIANCE_PROPOSAL
	result["action_label"] = str(validation.get("action_label", "동맹 제안"))
	result["target_city_id"] = str(validation.get("target_city_id", ""))
	result["cooldown"] = maxi(0, int(validation.get("cooldown", 0)))
	result["before_score"] = int(validation.get("before_score", result.get("before_score", DIPLOMACY_DEFAULT_SCORE)))
	result["before_status"] = str(validation.get("before_status", result.get("before_status", FACTION_RELATION_STATUS["NEUTRAL"])))
	result["after_score"] = int(result.get("after_score", result.get("before_score", DIPLOMACY_DEFAULT_SCORE)))
	result["after_status"] = str(result.get("after_status", result.get("status", validation.get("before_status", FACTION_RELATION_STATUS["NEUTRAL"]))))
	if bool(result.get("accepted", false)):
		result["message"] = "동맹을 체결했습니다."
	else:
		result["message"] = "동맹 제안이 거절되었습니다." if str(result.get("reason", "")) == "rejected" else str(result.get("message", "동맹 제안을 실행하지 못했습니다."))
	_sync_diplomacy_action_mirror_state_from_relations()
	_player_state["last_diplomacy_action_result"] = result
	return result


func _on_diplomacy_action_pressed(action_id: String) -> void:
	var target := _get_selected_diplomacy_target()
	var target_city_id := str(target.get("target_city_id", ""))
	var result := _apply_diplomacy_action(action_id, target_city_id)
	_save_management_status = str(result.get("message", "외교 행동 처리"))
	print("[DIPLOMACY_ACTION] ", result)
	_refresh_left_world_status_panel()
	_show_unified_diplomacy_spy_content()


func _normalize_diplomacy_resource_package(resource_package: Dictionary) -> Dictionary:
	var normalized := {}
	for resource_id_variant in resource_package.keys():
		var resource_id := str(resource_id_variant)
		var amount := maxi(0, int(resource_package.get(resource_id_variant, 0)))
		if amount > 0:
			normalized[resource_id] = amount
	return normalized


func _calculate_alliance_acceptance_chance(target_faction_id: String, resource_package: Dictionary, duration_turns: int) -> int:
	if target_faction_id.is_empty() or target_faction_id == PLAYER_FACTION_ID:
		return 0
	var score := _get_faction_relation_score(PLAYER_FACTION_ID, target_faction_id)
	var package := _normalize_diplomacy_resource_package(resource_package)
	var package_bonus := int(floor(float(package.get("gold", 0)) / 20.0)) + int(floor(float(package.get("silk", 0)) / 10.0))
	var duration_penalty := maxi(0, duration_turns - TRADE_AGREEMENT_TURNS)
	return clampi(score + package_bonus - duration_penalty, 0, 95)


func _propose_alliance(target_faction_id: String, resource_package: Dictionary, duration_turns: int) -> bool:
	var turn_number := maxi(1, int(_player_state.get("turn_number", 1)))
	var package := _normalize_diplomacy_resource_package(resource_package)
	if target_faction_id.is_empty() or target_faction_id == PLAYER_FACTION_ID:
		_player_state["last_alliance_proposal_result"] = {"turn": turn_number, "target_faction_id": target_faction_id, "success": false, "accepted": false, "reason": "invalid_target", "resource_package": package, "message": "동맹 대상을 확인할 수 없습니다."}
		return false
	var relation := _ensure_faction_relation_entry(PLAYER_FACTION_ID, target_faction_id)
	var status := _normalize_faction_relation_status(str(relation.get("status", FACTION_RELATION_STATUS["NEUTRAL"])))
	var before_score := clampi(int(relation.get("score", DIPLOMACY_DEFAULT_SCORE)), DIPLOMACY_SCORE_MIN, DIPLOMACY_SCORE_MAX)
	if status == FACTION_RELATION_STATUS["HOSTILE"] or status == FACTION_RELATION_STATUS["SUSPENDED"]:
		_player_state["last_alliance_proposal_result"] = {"turn": turn_number, "target_faction_id": target_faction_id, "success": false, "accepted": false, "reason": status, "status": status, "before_status": status, "after_status": status, "before_score": before_score, "after_score": before_score, "resource_package": package, "message": "적대 또는 교역 중단 상태에서는 동맹을 제안할 수 없습니다."}
		return false
	if duration_turns <= 0:
		_player_state["last_alliance_proposal_result"] = {"turn": turn_number, "target_faction_id": target_faction_id, "success": false, "accepted": false, "reason": "duration", "status": status, "before_status": status, "after_status": status, "before_score": before_score, "after_score": before_score, "resource_package": package, "message": "동맹 기간을 확인할 수 없습니다."}
		return false
	var payment_check := _can_pay_generic_resource_cost(package)
	if not bool(payment_check.get("ok", false)):
		_player_state["last_alliance_proposal_result"] = {"turn": turn_number, "target_faction_id": target_faction_id, "success": false, "accepted": false, "reason": "resources", "status": status, "before_status": status, "after_status": status, "before_score": before_score, "after_score": before_score, "resource_package": package, "missing": payment_check.get("missing", {}), "message": "자원이 부족합니다."}
		return false
	var payment_result := _apply_generic_resource_cost(package)
	var acceptance_chance := _calculate_alliance_acceptance_chance(target_faction_id, package, duration_turns)
	var accepted := acceptance_chance >= ALLIANCE_ACCEPTANCE_THRESHOLD
	var relation_key := _make_faction_relation_key(PLAYER_FACTION_ID, target_faction_id)
	var relations: Dictionary = _player_state.get("faction_relations", {})
	var updated_relation: Dictionary = relations.get(relation_key, relation)
	if accepted:
		updated_relation["status"] = FACTION_RELATION_STATUS["ALLIED"]
		updated_relation["alliance_turns_remaining"] = duration_turns
		updated_relation["alliance_created_turn"] = turn_number
		updated_relation["alliance_resource_package"] = package.duplicate(true)
		updated_relation["alliance_acceptance_score"] = acceptance_chance
		updated_relation["military_support_rejection_count"] = 0
		relations[relation_key] = updated_relation
		_player_state["faction_relations"] = relations
	var after_status := FACTION_RELATION_STATUS["ALLIED"] if accepted else status
	_player_state["last_alliance_proposal_result"] = {
		"turn": turn_number,
		"target_faction_id": target_faction_id,
		"resource_package": package,
		"cost": package,
		"payment": payment_result,
		"acceptance_chance": acceptance_chance,
		"acceptance_score": acceptance_chance,
		"acceptance_threshold": ALLIANCE_ACCEPTANCE_THRESHOLD,
		"required_score": ALLIANCE_ACCEPTANCE_THRESHOLD,
		"accepted": accepted,
		"success": accepted,
		"reason": "" if accepted else "rejected",
		"status": after_status,
		"before_status": status,
		"after_status": after_status,
		"before_score": before_score,
		"after_score": before_score,
		"duration_turns": duration_turns if accepted else 0,
		"alliance_turns_remaining": duration_turns if accepted else 0,
		"created_turn": turn_number if accepted else 0,
		"message": "동맹을 체결했습니다." if accepted else "동맹 제안이 거절되었습니다.",
	}
	return accepted


func _calculate_military_support_acceptance_chance(target_faction_id: String) -> int:
	if target_faction_id.is_empty() or target_faction_id == PLAYER_FACTION_ID:
		return 0
	var relation := _ensure_faction_relation_entry(PLAYER_FACTION_ID, target_faction_id)
	var score := clampi(int(relation.get("score", DIPLOMACY_DEFAULT_SCORE)), DIPLOMACY_SCORE_MIN, DIPLOMACY_SCORE_MAX)
	var rejection_count := maxi(0, int(relation.get("military_support_rejection_count", 0)))
	return clampi(score - rejection_count * 10, 0, 95)


func _request_military_support(target_faction_id: String) -> bool:
	var turn_number := maxi(1, int(_player_state.get("turn_number", 1)))
	if target_faction_id.is_empty() or target_faction_id == PLAYER_FACTION_ID:
		_player_state["last_military_support_result"] = {"turn": turn_number, "target_faction_id": target_faction_id, "success": false, "accepted": false, "reason": "invalid_target"}
		return false
	var relation := _ensure_faction_relation_entry(PLAYER_FACTION_ID, target_faction_id)
	var status := _normalize_faction_relation_status(str(relation.get("status", FACTION_RELATION_STATUS["NEUTRAL"])))
	if status != FACTION_RELATION_STATUS["ALLIED"]:
		_player_state["last_military_support_result"] = {"turn": turn_number, "target_faction_id": target_faction_id, "success": false, "accepted": false, "reason": "not_allied", "status": status}
		return false
	var acceptance_chance := _calculate_military_support_acceptance_chance(target_faction_id)
	var accepted := acceptance_chance >= MILITARY_SUPPORT_ACCEPTANCE_THRESHOLD
	var relation_key := _make_faction_relation_key(PLAYER_FACTION_ID, target_faction_id)
	var relations: Dictionary = _player_state.get("faction_relations", {})
	var updated_relation: Dictionary = relations.get(relation_key, relation)
	var before_score := clampi(int(updated_relation.get("score", DIPLOMACY_DEFAULT_SCORE)), DIPLOMACY_SCORE_MIN, DIPLOMACY_SCORE_MAX)
	var rejection_count := maxi(0, int(updated_relation.get("military_support_rejection_count", 0)))
	var relation_penalty := 0
	var after_score := before_score
	if accepted:
		updated_relation["military_support_rejection_count"] = 0
	else:
		rejection_count += 1
		relation_penalty = MILITARY_SUPPORT_REPEATED_REJECT_PENALTY if rejection_count >= MILITARY_SUPPORT_REPEATED_REJECT_THRESHOLD else MILITARY_SUPPORT_REJECT_PENALTY
		var relation_result := _adjust_faction_relation_score(PLAYER_FACTION_ID, target_faction_id, relation_penalty, "military_support_rejected")
		after_score = int(relation_result.get("after_score", before_score))
		relations = _player_state.get("faction_relations", {})
		updated_relation = relations.get(relation_key, updated_relation)
		updated_relation["military_support_rejection_count"] = rejection_count
	relations[relation_key] = updated_relation
	_player_state["faction_relations"] = relations
	_player_state["last_military_support_result"] = {
		"turn": turn_number,
		"target_faction_id": target_faction_id,
		"success": accepted,
		"accepted": accepted,
		"status": status,
		"acceptance_chance": acceptance_chance,
		"acceptance_threshold": MILITARY_SUPPORT_ACCEPTANCE_THRESHOLD,
		"before_score": before_score,
		"after_score": after_score,
		"relation_penalty": relation_penalty,
		"rejection_count": rejection_count,
		"support_recorded": accepted,
		"troops_moved": 0,
	}
	return accepted


func _get_trade_agreement_cost(_target_faction_id: String) -> Dictionary:
	return TRADE_AGREEMENT_COST.duplicate(true)


func _propose_trade_agreement(target_faction_id: String) -> bool:
	var turn_number := maxi(1, int(_player_state.get("turn_number", 1)))
	if target_faction_id.is_empty() or target_faction_id == PLAYER_FACTION_ID:
		_player_state["last_trade_agreement_result"] = {"turn": turn_number, "target_faction_id": target_faction_id, "success": false, "reason": "invalid_target"}
		return false
	var relation := _ensure_faction_relation_entry(PLAYER_FACTION_ID, target_faction_id)
	var status := _normalize_faction_relation_status(str(relation.get("status", FACTION_RELATION_STATUS["NEUTRAL"])))
	if status == FACTION_RELATION_STATUS["HOSTILE"] or status == FACTION_RELATION_STATUS["SUSPENDED"]:
		_player_state["last_trade_agreement_result"] = {"turn": turn_number, "target_faction_id": target_faction_id, "success": false, "reason": status, "status": status}
		return false
	var score := clampi(int(relation.get("score", DIPLOMACY_DEFAULT_SCORE)), DIPLOMACY_SCORE_MIN, DIPLOMACY_SCORE_MAX)
	if score < TRADE_AGREEMENT_SCORE_REQUIREMENT:
		_player_state["last_trade_agreement_result"] = {"turn": turn_number, "target_faction_id": target_faction_id, "success": false, "reason": "relation_score", "score": score, "required_score": TRADE_AGREEMENT_SCORE_REQUIREMENT, "status": status}
		return false
	var cost := _get_trade_agreement_cost(target_faction_id)
	var payment_check := _can_pay_generic_resource_cost(cost)
	if not bool(payment_check.get("ok", false)):
		_player_state["last_trade_agreement_result"] = {"turn": turn_number, "target_faction_id": target_faction_id, "success": false, "reason": "resources", "score": score, "cost": cost, "missing": payment_check.get("missing", {}), "status": status}
		return false
	var payment_result := _apply_generic_resource_cost(cost)
	var relation_key := _make_faction_relation_key(PLAYER_FACTION_ID, target_faction_id)
	var relations: Dictionary = _player_state.get("faction_relations", {})
	var updated_relation: Dictionary = relations.get(relation_key, relation)
	updated_relation["trade_agreement_active"] = true
	updated_relation["trade_agreement_turns_remaining"] = TRADE_AGREEMENT_TURNS
	updated_relation["trade_agreement_bonus"] = TRADE_AGREEMENT_MULTIPLIER_BONUS
	relations[relation_key] = updated_relation
	_player_state["faction_relations"] = relations
	_player_state["last_trade_agreement_result"] = {
		"turn": turn_number,
		"target_faction_id": target_faction_id,
		"success": true,
		"score": score,
		"status": status,
		"cost": cost,
		"payment": payment_result,
		"duration_turns": TRADE_AGREEMENT_TURNS,
		"trade_multiplier_bonus": TRADE_AGREEMENT_MULTIPLIER_BONUS,
	}
	return true


func _get_trade_agreement_bonus_multiplier(faction_a: String, faction_b: String) -> float:
	if faction_a.is_empty() or faction_b.is_empty() or faction_a == faction_b:
		return 0.0
	var relation := _ensure_faction_relation_entry(faction_a, faction_b)
	if bool(relation.get("trade_agreement_active", false)) and int(relation.get("trade_agreement_turns_remaining", 0)) > 0:
		return float(relation.get("trade_agreement_bonus", TRADE_AGREEMENT_MULTIPLIER_BONUS))
	return 0.0


func _get_active_trade_agreement_turns(target_faction_id: String) -> int:
	if target_faction_id.is_empty() or target_faction_id == PLAYER_FACTION_ID:
		return 0
	var relation := _ensure_faction_relation_entry(PLAYER_FACTION_ID, target_faction_id)
	if not bool(relation.get("trade_agreement_active", false)):
		return 0
	return maxi(0, int(relation.get("trade_agreement_turns_remaining", 0)))


func _get_active_alliance_turns(target_faction_id: String) -> int:
	if target_faction_id.is_empty() or target_faction_id == PLAYER_FACTION_ID:
		return 0
	var relation := _ensure_faction_relation_entry(PLAYER_FACTION_ID, target_faction_id)
	if _normalize_faction_relation_status(str(relation.get("status", FACTION_RELATION_STATUS["NEUTRAL"]))) != FACTION_RELATION_STATUS["ALLIED"]:
		return 0
	return maxi(0, int(relation.get("alliance_turns_remaining", 0)))


func _get_tribute_cost(_target_faction: String) -> Dictionary:
	return TRIBUTE_BASE_COST.duplicate(true)


func _can_send_tribute(target_faction: String) -> Dictionary:
	if target_faction.is_empty() or target_faction == PLAYER_FACTION_ID:
		return {"ok": false, "reason": "invalid_target"}
	var relation := _ensure_faction_relation_entry(PLAYER_FACTION_ID, target_faction)
	var status := _normalize_faction_relation_status(str(relation.get("status", FACTION_RELATION_STATUS["NEUTRAL"])))
	if status == FACTION_RELATION_STATUS["HOSTILE"]:
		return {"ok": false, "reason": "hostile", "relation": relation}
	if status == FACTION_RELATION_STATUS["SUSPENDED"]:
		return {"ok": false, "reason": "suspended", "relation": relation}
	var tribute_cooldown := maxi(0, int(relation.get("tribute_cooldown", 0)))
	if tribute_cooldown > 0:
		return {"ok": false, "reason": "cooldown", "cooldown": tribute_cooldown, "relation": relation}
	var cost := _get_tribute_cost(target_faction)
	var payment_check := _can_pay_generic_resource_cost(cost)
	if not bool(payment_check.get("ok", false)):
		return {"ok": false, "reason": "resources", "cost": cost, "missing": payment_check.get("missing", {}), "relation": relation}
	return {
		"ok": true,
		"cost": cost,
		"relation": relation,
	}


func _calculate_tribute_relation_gain(_target_faction: String) -> int:
	return clampi(20, TRIBUTE_RELATION_GAIN_MIN, TRIBUTE_RELATION_GAIN_MAX)


func _send_tribute(target_faction: String) -> bool:
	var check := _can_send_tribute(target_faction)
	if not bool(check.get("ok", false)):
		_player_state["last_tribute_result"] = {
			"turn": maxi(1, int(_player_state.get("turn_number", 1))),
			"target_faction": target_faction,
			"success": false,
			"reason": str(check.get("reason", "unknown")),
			"cost": check.get("cost", _get_tribute_cost(target_faction)),
		}
		return false
	var cost: Dictionary = check.get("cost", {})
	_apply_generic_resource_cost(cost)
	var relation_before: Dictionary = check.get("relation", {})
	var before_score := clampi(int(relation_before.get("score", DIPLOMACY_DEFAULT_SCORE)), DIPLOMACY_SCORE_MIN, DIPLOMACY_SCORE_MAX)
	var gain := _calculate_tribute_relation_gain(target_faction)
	var relation_result := _adjust_faction_relation_score(PLAYER_FACTION_ID, target_faction, gain, "tribute")
	var relation_key := _make_faction_relation_key(PLAYER_FACTION_ID, target_faction)
	var relations: Dictionary = _player_state.get("faction_relations", {})
	var relation_entry: Dictionary = relations.get(relation_key, {})
	relation_entry["tribute_cooldown"] = TRIBUTE_COOLDOWN_TURNS
	relations[relation_key] = relation_entry
	_player_state["faction_relations"] = relations
	_player_state["last_tribute_result"] = {
		"turn": maxi(1, int(_player_state.get("turn_number", 1))),
		"target_faction": target_faction,
		"cost": cost,
		"relation_gain": gain,
		"before_score": before_score,
		"after_score": int(relation_result.get("after_score", before_score)),
		"status": str(relation_result.get("status", FACTION_RELATION_STATUS["NEUTRAL"])),
		"band": str(relation_result.get("band", _get_faction_relation_band(int(relation_result.get("after_score", before_score))))),
		"cooldown": TRIBUTE_COOLDOWN_TURNS,
		"tribute_cooldown": TRIBUTE_COOLDOWN_TURNS,
		"success": true,
	}
	return true


func _advance_diplomacy_cooldowns_for_world_turn() -> Dictionary:
	if not _player_state.has("faction_relations") or not (_player_state["faction_relations"] is Dictionary):
		_player_state["faction_relations"] = {}
	var relations: Dictionary = _player_state["faction_relations"]
	var changed: Array = []
	for relation_key_variant in relations.keys():
		var relation_key := str(relation_key_variant)
		var entry_variant: Variant = relations.get(relation_key, {})
		if not entry_variant is Dictionary:
			continue
		var entry := (entry_variant as Dictionary).duplicate(true)
		var entry_changed := false
		var before_tribute_cooldown := maxi(0, int(entry.get("tribute_cooldown", 0)))
		if before_tribute_cooldown > 0:
			var after_tribute_cooldown := maxi(0, before_tribute_cooldown - 1)
			entry["tribute_cooldown"] = after_tribute_cooldown
			entry_changed = true
			changed.append({
				"relation_key": relation_key,
				"type": "tribute_cooldown",
				"before": before_tribute_cooldown,
				"after": after_tribute_cooldown,
			})
		var before_action_cooldown := maxi(0, int(entry.get("diplomacy_action_cooldown", 0)))
		if before_action_cooldown > 0:
			var after_action_cooldown := maxi(0, before_action_cooldown - 1)
			entry["diplomacy_action_cooldown"] = after_action_cooldown
			entry_changed = true
			changed.append({
				"relation_key": relation_key,
				"type": "diplomacy_action_cooldown",
				"before": before_action_cooldown,
				"after": after_action_cooldown,
			})
		var before_agreement_turns := maxi(0, int(entry.get("trade_agreement_turns_remaining", 0)))
		if bool(entry.get("trade_agreement_active", false)) and before_agreement_turns > 0:
			var after_agreement_turns := maxi(0, before_agreement_turns - 1)
			entry["trade_agreement_turns_remaining"] = after_agreement_turns
			if after_agreement_turns <= 0:
				entry["trade_agreement_active"] = false
				entry["trade_agreement_bonus"] = 0.0
				entry.erase("trade_agreement_source")
				entry.erase("trade_agreement_created_turn")
			entry_changed = true
			changed.append({
				"relation_key": relation_key,
				"type": "trade_agreement",
				"before": before_agreement_turns,
				"after": after_agreement_turns,
			})
		var before_alliance_turns := maxi(0, int(entry.get("alliance_turns_remaining", 0)))
		if _normalize_faction_relation_status(str(entry.get("status", FACTION_RELATION_STATUS["NEUTRAL"]))) == FACTION_RELATION_STATUS["ALLIED"] and before_alliance_turns > 0:
			var after_alliance_turns := maxi(0, before_alliance_turns - 1)
			entry["alliance_turns_remaining"] = after_alliance_turns
			if after_alliance_turns <= 0:
				entry["status"] = FACTION_RELATION_STATUS["NEUTRAL"]
				entry.erase("alliance_created_turn")
				entry.erase("alliance_resource_package")
				entry.erase("alliance_acceptance_score")
			entry_changed = true
			changed.append({
				"relation_key": relation_key,
				"type": "alliance",
				"before": before_alliance_turns,
				"after": after_alliance_turns,
			})
		if entry_changed:
			relations[relation_key] = entry
	_player_state["faction_relations"] = relations
	_sync_diplomacy_action_mirror_state_from_relations()
	var result := {
		"turn": maxi(1, int(_player_state.get("turn_number", 1))),
		"changed_count": changed.size(),
		"changed": changed,
	}
	_player_state["last_diplomacy_cooldown_result"] = result
	return result


func _get_current_chancellor_political_aptitude() -> int:
	var chancellor_id := str(_player_state.get("chancellor_id", ""))
	if chancellor_id.is_empty():
		return 0
	var hero_data := _get_hero_entry(chancellor_id)
	if hero_data.is_empty() or str(hero_data.get("side", "")) != PLAYER_FACTION_ID:
		return 0
	var aptitude := 0
	if str(hero_data.get("chancellor_primary_type", "")) == "political":
		aptitude = maxi(aptitude, int(hero_data.get("chancellor_primary_aptitude", 0)))
	if str(hero_data.get("chancellor_secondary_type", "")) == "political":
		aptitude = maxi(aptitude, int(hero_data.get("chancellor_secondary_aptitude", 0)))
	return clampi(aptitude, 0, 5)


func _is_current_chancellor_political_type() -> bool:
	var chancellor_id := str(_player_state.get("chancellor_id", ""))
	if chancellor_id.is_empty():
		return false
	var hero_data := _get_hero_entry(chancellor_id)
	if hero_data.is_empty() or str(hero_data.get("side", "")) != PLAYER_FACTION_ID:
		return false
	return str(hero_data.get("chancellor_primary_type", "")) == "political"


func _get_selected_spy_target() -> Dictionary:
	var target_city_id := ""
	if selected_city_marker != null:
		target_city_id = selected_city_marker.city_id
	elif not selected_city_id.is_empty():
		target_city_id = selected_city_id
	var city_data := _get_city_hud_entry(target_city_id)
	var target_faction_id := _get_city_owner_faction_id(city_data) if not city_data.is_empty() else ""
	return {
		"target_city_id": target_city_id,
		"target_faction_id": target_faction_id,
		"city_data": city_data,
	}


func _get_spy_action_definition(action_id: String) -> Dictionary:
	match action_id:
		SPY_ACTION_GATHER_INFO:
			return {"action_id": action_id, "label": "정탐", "result_key": "last_spy_result", "cooldown": _get_spy_cooldown_turns(), "message_success": "정탐에 성공했습니다.", "message_failure": "정탐에 실패했습니다."}
		SPY_ACTION_PUBLIC_SUPPORT_DISRUPT:
			return {"action_id": action_id, "label": "민심 교란", "result_key": "last_spy_public_support_disrupt_result", "cooldown": _get_spy_public_support_disrupt_cooldown_turns(), "message_success": "민심 교란에 성공했습니다.", "message_failure": "민심 교란에 실패했습니다."}
		SPY_ACTION_LOYALTY_DISRUPT:
			return {"action_id": action_id, "label": "성 충성도 교란", "result_key": "last_spy_loyalty_disrupt_result", "cooldown": _get_spy_action_cooldown_turns(SPY_LOYALTY_DISRUPT_COOLDOWN_TURNS), "message_success": "성 충성도 교란에 성공했습니다.", "message_failure": "성 충성도 교란에 실패했습니다."}
		SPY_ACTION_REVOLT_INSTIGATE:
			return {"action_id": action_id, "label": "반란 조장", "result_key": "last_spy_revolt_instigation_result", "cooldown": _get_spy_action_cooldown_turns(SPY_REVOLT_INSTIGATION_COOLDOWN_TURNS), "message_success": "반란 조장에 성공했습니다.", "message_failure": "반란 조장에 실패했습니다."}
		SPY_ACTION_WEDGE:
			return {"action_id": action_id, "label": "이간질", "result_key": "last_spy_wedge_result", "cooldown": _get_spy_action_cooldown_turns(SPY_WEDGE_COOLDOWN_TURNS), "message_success": "이간질에 성공했습니다.", "message_failure": "이간질에 실패했습니다.", "cost": SPY_WEDGE_COST.duplicate(true)}
		_:
			return {}


func _format_spy_validation_message(check: Dictionary) -> String:
	if bool(check.get("ok", false)):
		return "실행 가능"
	match str(check.get("reason", "unknown")):
		"invalid_action":
			return "알 수 없는 첩보 행동입니다."
		"invalid_target":
			return "대상 도시 확인이 필요합니다."
		"own_city":
			return "자국 도시는 첩보 대상이 아닙니다."
		"no_chancellor":
			return "재상이 필요합니다."
		"no_political_aptitude":
			return "정치형 재상이 필요합니다."
		"cooldown":
			return "첩보 대기 중입니다."
		"iron_wall":
			return "대상 도시 경계가 너무 높습니다."
		"prerequisite_public_support":
			return "민심 50 이하 대상에서만 가능합니다."
		"prerequisite_loyalty":
			return "충성도 40 이하 대상에서만 가능합니다."
		"no_counterpart":
			return "이간질할 상대 세력을 찾을 수 없습니다."
		"already_hostile":
			return "이미 사이가 최악입니다."
		"resources":
			return "금전/비단이 부족합니다."
		_:
			return "실행 조건을 충족하지 못했습니다."


func _validate_spy_action(action_id: String, target_city_id: String = "") -> Dictionary:
	var definition := _get_spy_action_definition(action_id)
	if definition.is_empty():
		return {"ok": false, "reason": "invalid_action", "message": _format_spy_validation_message({"reason": "invalid_action"})}
	var resolved_city_id := target_city_id
	if resolved_city_id.is_empty():
		resolved_city_id = str(_get_selected_spy_target().get("target_city_id", ""))
	var check := {}
	match action_id:
		SPY_ACTION_GATHER_INFO:
			check = _can_gather_spy_info(resolved_city_id)
		SPY_ACTION_PUBLIC_SUPPORT_DISRUPT:
			check = _can_disrupt_city_public_support(resolved_city_id)
		SPY_ACTION_LOYALTY_DISRUPT:
			check = _can_disrupt_city_loyalty(resolved_city_id)
		SPY_ACTION_REVOLT_INSTIGATE:
			check = _can_instigate_revolt(resolved_city_id)
		SPY_ACTION_WEDGE:
			check = _can_wedge_faction_relation(resolved_city_id)
		_:
			check = {"ok": false, "reason": "invalid_action"}
	var city_data := _get_city_hud_entry(resolved_city_id)
	var target_faction_id := _get_city_owner_faction_id(city_data) if not city_data.is_empty() else ""
	var result := check.duplicate(true)
	result["action_id"] = action_id
	result["action_label"] = str(definition.get("label", action_id))
	result["target_city_id"] = resolved_city_id
	result["target_faction_id"] = target_faction_id
	result["cooldown"] = int(definition.get("cooldown", 0))
	result["message"] = _format_spy_validation_message(result)
	return result


func _get_spy_result_key_for_action(action_id: String) -> String:
	var definition := _get_spy_action_definition(action_id)
	return str(definition.get("result_key", "last_spy_result"))


func _apply_spy_detection_relation_penalty(target_faction_id: String, relation_penalty: int, reason: String) -> Dictionary:
	if target_faction_id.is_empty() or relation_penalty == 0:
		return {"before_score": DIPLOMACY_DEFAULT_SCORE, "after_score": DIPLOMACY_DEFAULT_SCORE, "relation_penalty": 0}
	var relation_result := _adjust_faction_relation_score(PLAYER_FACTION_ID, target_faction_id, relation_penalty, reason)
	return {
		"before_score": int(relation_result.get("before_score", relation_result.get("after_score", DIPLOMACY_DEFAULT_SCORE))),
		"after_score": int(relation_result.get("after_score", DIPLOMACY_DEFAULT_SCORE)),
		"relation_penalty": relation_penalty,
	}


func _store_failed_spy_action_result(action_id: String, validation: Dictionary) -> Dictionary:
	var definition := _get_spy_action_definition(action_id)
	var target_city_id := str(validation.get("target_city_id", ""))
	var city_data := _get_city_hud_entry(target_city_id)
	var target_faction_id := str(validation.get("target_faction_id", _get_city_owner_faction_id(city_data) if not city_data.is_empty() else ""))
	var result := {
		"turn": maxi(1, int(_player_state.get("turn_number", 1))),
		"action_id": action_id,
		"action_label": str(definition.get("label", action_id)),
		"target_city_id": target_city_id,
		"target_faction": target_faction_id,
		"target_faction_id": target_faction_id,
		"counterpart_faction_id": str(validation.get("counterpart_faction_id", "")),
		"success": false,
		"detected": false,
		"effect_applied": false,
		"success_valid": false,
		"reason": str(validation.get("reason", "unknown")),
		"relation_penalty": 0,
		"cost": validation.get("cost", {}),
		"cooldown": 0,
		"message": str(validation.get("message", _format_spy_validation_message(validation))),
	}
	_player_state[_get_spy_result_key_for_action(action_id)] = result
	return result


func _apply_spy_action(action_id: String, target_city_id: String = "") -> Dictionary:
	var validation := _validate_spy_action(action_id, target_city_id)
	if not bool(validation.get("ok", false)):
		return _store_failed_spy_action_result(action_id, validation)
	match action_id:
		SPY_ACTION_GATHER_INFO:
			return _gather_spy_info(str(validation.get("target_city_id", "")))
		SPY_ACTION_PUBLIC_SUPPORT_DISRUPT:
			return _disrupt_city_public_support(str(validation.get("target_city_id", "")))
		SPY_ACTION_LOYALTY_DISRUPT:
			return _disrupt_city_loyalty(str(validation.get("target_city_id", "")))
		SPY_ACTION_REVOLT_INSTIGATE:
			return _instigate_revolt(str(validation.get("target_city_id", "")))
		SPY_ACTION_WEDGE:
			return _apply_spy_wedge_action(validation)
	return _store_failed_spy_action_result(action_id, {"reason": "invalid_action", "message": "알 수 없는 첩보 행동입니다.", "target_city_id": target_city_id})


func _on_spy_action_pressed(action_id: String) -> void:
	_apply_spy_action(action_id)
	_refresh_city_hud_data_bindings()
	if selected_city_marker != null:
		city_info_panel.show_city(selected_city_marker)
	_show_unified_diplomacy_spy_content()


func _get_spy_info_success_chance() -> int:
	match _get_current_chancellor_political_aptitude():
		5:
			return 80
		4:
			return 65
		3:
			return 50
		2:
			return 35
		1:
			return 20
		_:
			return 0


func _get_city_security_score_for_spy(target_city_id: String) -> int:
	var city_data := _get_city_hud_entry(target_city_id)
	if city_data.is_empty():
		return 0
	if city_data.has("security"):
		return clampi(int(city_data.get("security", 0)), 0, 100)
	if city_data.has("public_order"):
		return clampi(int(city_data.get("public_order", 0)), 0, 100)
	var domestic_seed: Dictionary = {}
	var raw_domestic_seed: Variant = city_data.get("domestic_seed", {})
	if raw_domestic_seed is Dictionary:
		domestic_seed = raw_domestic_seed as Dictionary
	if domestic_seed.has("publicOrder"):
		return clampi(int(domestic_seed.get("publicOrder", 0)), 0, 100)
	var required := maxi(1, _get_city_security_required_troops(city_data))
	var troops := _get_city_troops_for_battle_context(target_city_id)
	return clampi(int(round((float(troops) / float(required)) * 100.0)), 0, 100)


func _calculate_spy_detection_chance(target_city_id: String) -> int:
	var city_data := _get_city_hud_entry(target_city_id)
	if city_data.is_empty():
		return 0
	var detection := 20
	var security := _get_city_security_score_for_spy(target_city_id)
	var loyalty := _get_city_loyalty_value(city_data)
	if security >= 90:
		detection += 35
	elif security >= 70:
		detection += 20
	if loyalty >= 90:
		detection += 25
	elif loyalty >= 70:
		detection += 15
	if _is_current_chancellor_political_type():
		detection -= 10
	return clampi(detection, 0, 95)


func _get_spy_info_visibility_level(political_aptitude: int) -> Dictionary:
	var aptitude := clampi(political_aptitude, 0, 5)
	match aptitude:
		5:
			return {"fields": ["troops", "resources", "publicSupport", "loyalty", "governor", "tech"], "estimated": false}
		4:
			return {"fields": ["troops", "resources", "publicSupport", "loyalty"], "estimated": false}
		3:
			return {"fields": ["troops", "resources"], "estimated": false}
		2:
			return {"fields": ["troops"], "estimated": false}
		1:
			return {"fields": ["troops_estimated"], "estimated": true}
		_:
			return {"fields": [], "estimated": false}


func _can_gather_spy_info(target_city_id: String) -> Dictionary:
	var city_data := _get_city_hud_entry(target_city_id)
	if target_city_id.is_empty() or city_data.is_empty():
		return {"ok": false, "reason": "invalid_target"}
	if _is_city_owned_by_player_mvp(target_city_id):
		return {"ok": false, "reason": "own_city"}
	var chancellor_id := str(_player_state.get("chancellor_id", ""))
	if chancellor_id.is_empty() or _get_hero_entry(chancellor_id).is_empty():
		return {"ok": false, "reason": "no_chancellor"}
	var political_aptitude := _get_current_chancellor_political_aptitude()
	if political_aptitude <= 0:
		return {"ok": false, "reason": "no_political_aptitude"}
	var spy_cooldown := maxi(0, int(_player_state.get("spy_cooldown", 0)))
	if spy_cooldown > 0:
		return {"ok": false, "reason": "cooldown", "cooldown": spy_cooldown}
	var security := _get_city_security_score_for_spy(target_city_id)
	var loyalty := _get_city_loyalty_value(city_data)
	if security >= 100 and loyalty >= 100:
		return {"ok": false, "reason": "iron_wall", "security": security, "loyalty": loyalty}
	var visibility := _get_spy_info_visibility_level(political_aptitude)
	return {
		"ok": true,
		"political_aptitude": political_aptitude,
		"success_chance": _get_spy_info_success_chance(),
		"detection_chance": _calculate_spy_detection_chance(target_city_id),
		"fields": visibility.get("fields", []),
		"estimated": bool(visibility.get("estimated", false)),
	}


func _roll_spy_info_result(target_city_id: String, forced_roll: int = -1, forced_detection_roll: int = -1) -> Dictionary:
	var check := _can_gather_spy_info(target_city_id)
	if not bool(check.get("ok", false)):
		return {
			"ok": false,
			"reason": str(check.get("reason", "unknown")),
			"target_city_id": target_city_id,
			"success": false,
			"detected": false,
		}
	var roll := forced_roll if forced_roll >= 0 else (randi() % 100) + 1
	var detection_roll := forced_detection_roll if forced_detection_roll >= 0 else (randi() % 100) + 1
	roll = clampi(roll, 1, 100)
	detection_roll = clampi(detection_roll, 1, 100)
	var success_chance := int(check.get("success_chance", 0))
	var detection_chance := int(check.get("detection_chance", 0))
	return {
		"ok": true,
		"target_city_id": target_city_id,
		"success": roll <= success_chance,
		"detected": detection_roll <= detection_chance,
		"roll": roll,
		"detection_roll": detection_roll,
		"success_chance": success_chance,
		"detection_chance": detection_chance,
		"political_aptitude": int(check.get("political_aptitude", 0)),
		"fields": check.get("fields", []),
		"estimated": bool(check.get("estimated", false)),
	}


func _build_spy_info_payload(target_city_id: String, fields: Array, estimated: bool = false) -> Dictionary:
	var city_data := _get_city_hud_entry(target_city_id)
	if city_data.is_empty():
		return {}
	var payload := {"city_id": target_city_id, "city_name": _format_city_name_by_id(target_city_id, target_city_id)}
	for field_variant in fields:
		var field := str(field_variant)
		match field:
			"troops":
				payload["troops"] = _get_city_troops_for_battle_context(target_city_id)
			"troops_estimated":
				var troops := _get_city_troops_for_battle_context(target_city_id)
				payload["troops_estimated"] = int(round(float(troops) / 500.0)) * 500
			"resources":
				if city_data.has("resource_seed") and city_data.get("resource_seed") is Dictionary:
					payload["resources"] = (city_data.get("resource_seed") as Dictionary).duplicate(true)
				elif city_data.has("resources"):
					payload["resources"] = str(city_data.get("resources", "not_available"))
				else:
					payload["resources"] = "not_available"
			"publicSupport":
				var domestic_seed: Dictionary = {}
				var raw_domestic_seed: Variant = city_data.get("domestic_seed", {})
				if raw_domestic_seed is Dictionary:
					domestic_seed = raw_domestic_seed as Dictionary
				if city_data.has("publicSupport"):
					payload["publicSupport"] = _get_city_public_support(target_city_id)
				elif domestic_seed.has("publicSupport"):
					payload["publicSupport"] = clampi(int(domestic_seed.get("publicSupport", CITY_PUBLIC_SUPPORT_DEFAULT)), 0, 100)
				else:
					payload["publicSupport"] = "not_available"
			"loyalty":
				payload["loyalty"] = _get_city_loyalty_value(city_data)
			"governor":
				var governor_id := str(city_data.get("governor_id", city_data.get("governorHeroId", "")))
				payload["governor"] = governor_id if not governor_id.is_empty() else "not_available"
			"tech":
				var tech_payload := {"city_completed": "not_available", "national_completed": "not_available"}
				if _city_runtime_states.has(target_city_id):
					var runtime_state: Dictionary = {}
					var raw_runtime_state: Variant = _city_runtime_states.get(target_city_id, {})
					if raw_runtime_state is Dictionary:
						runtime_state = raw_runtime_state as Dictionary
					var city_tech: Dictionary = {}
					var raw_city_tech: Variant = runtime_state.get("city_tech", {})
					if raw_city_tech is Dictionary:
						city_tech = raw_city_tech as Dictionary
					var completed: Dictionary = {}
					var raw_completed: Variant = city_tech.get("completed", {})
					if raw_completed is Dictionary:
						completed = raw_completed as Dictionary
					if not completed.is_empty():
						tech_payload["city_completed"] = completed.keys()
					else:
						tech_payload["city_completed"] = "not_available"
				payload["tech"] = tech_payload
	if estimated and not payload.has("troops_estimated") and payload.has("troops"):
		payload["troops_estimated"] = int(round(float(int(payload.get("troops", 0))) / 500.0)) * 500
		payload.erase("troops")
	return payload


func _get_spy_cooldown_turns() -> int:
	return maxi(1, SPY_COOLDOWN_TURNS - (2 if _is_current_chancellor_political_type() else 0))


func _gather_spy_info(target_city_id: String, forced_roll: int = -1, forced_detection_roll: int = -1) -> Dictionary:
	var roll_result := _roll_spy_info_result(target_city_id, forced_roll, forced_detection_roll)
	var cooldown := 0
	var payload := {}
	var city_data := _get_city_hud_entry(target_city_id)
	var target_faction_id := _get_city_owner_faction_id(city_data) if not city_data.is_empty() else ""
	var relation_penalty := 0
	var relation_change := {"before_score": DIPLOMACY_DEFAULT_SCORE, "after_score": DIPLOMACY_DEFAULT_SCORE}
	if not target_faction_id.is_empty():
		var current_score := _get_faction_relation_score(PLAYER_FACTION_ID, target_faction_id)
		relation_change = {"before_score": current_score, "after_score": current_score}
	if bool(roll_result.get("ok", false)):
		cooldown = _get_spy_cooldown_turns()
		_player_state["spy_cooldown"] = cooldown
		if bool(roll_result.get("success", false)):
			payload = _build_spy_info_payload(target_city_id, roll_result.get("fields", []), bool(roll_result.get("estimated", false)))
		if bool(roll_result.get("detected", false)):
			relation_penalty = SPY_DETECTED_RELATION_PENALTY_GATHER_INFO
			relation_change = _apply_spy_detection_relation_penalty(target_faction_id, relation_penalty, "spy_gather_info_detected")
	var result := {
		"turn": maxi(1, int(_player_state.get("turn_number", 1))),
		"action_id": SPY_ACTION_GATHER_INFO,
		"action_label": "정탐",
		"target_city_id": target_city_id,
		"target_faction": target_faction_id,
		"target_faction_id": target_faction_id,
		"success": bool(roll_result.get("success", false)),
		"detected": bool(roll_result.get("detected", false)),
		"roll": int(roll_result.get("roll", -1)),
		"detection_roll": int(roll_result.get("detection_roll", -1)),
		"success_chance": int(roll_result.get("success_chance", 0)),
		"detection_chance": int(roll_result.get("detection_chance", 0)),
		"political_aptitude": int(roll_result.get("political_aptitude", 0)),
		"fields": roll_result.get("fields", []),
		"payload": payload,
		"info": payload,
		"effect_applied": bool(roll_result.get("success", false)),
		"relation_penalty": relation_penalty,
		"before_score": int(relation_change.get("before_score", 0)),
		"after_score": int(relation_change.get("after_score", 0)),
		"cost": {},
		"cooldown": cooldown,
		"success_valid": bool(roll_result.get("ok", false)),
		"message": "정탐에 성공했습니다." if bool(roll_result.get("success", false)) else "정탐에 실패했습니다.",
	}
	if not bool(roll_result.get("ok", false)):
		result["reason"] = str(roll_result.get("reason", "unknown"))
	_player_state["last_spy_result"] = result
	_record_city_intel_from_spy_result(result)
	return result


func _get_spy_public_support_disrupt_amount(political_aptitude: int) -> int:
	match clampi(political_aptitude, 0, 5):
		5:
			return 20
		4:
			return 15
		3:
			return 10
		2:
			return 5
		1:
			return 3
		_:
			return 0


func _get_spy_public_support_disrupt_cost(_target_city_id: String) -> Dictionary:
	return SPY_PUBLIC_SUPPORT_DISRUPT_COST.duplicate(true)


func _can_disrupt_city_public_support(target_city_id: String) -> Dictionary:
	var city_data := _get_city_hud_entry(target_city_id)
	if target_city_id.is_empty() or city_data.is_empty():
		return {"ok": false, "reason": "invalid_target"}
	if _is_city_owned_by_player_mvp(target_city_id):
		return {"ok": false, "reason": "own_city"}
	var chancellor_id := str(_player_state.get("chancellor_id", ""))
	if chancellor_id.is_empty() or _get_hero_entry(chancellor_id).is_empty():
		return {"ok": false, "reason": "no_chancellor"}
	var political_aptitude := _get_current_chancellor_political_aptitude()
	if political_aptitude <= 0:
		return {"ok": false, "reason": "no_political_aptitude"}
	var spy_cooldown := maxi(0, int(_player_state.get("spy_cooldown", 0)))
	if spy_cooldown > 0:
		return {"ok": false, "reason": "cooldown", "cooldown": spy_cooldown}
	var security := _get_city_security_score_for_spy(target_city_id)
	var loyalty := _get_city_loyalty_value(city_data)
	if security >= 100 and loyalty >= 100:
		return {"ok": false, "reason": "iron_wall", "security": security, "loyalty": loyalty}
	return {
		"ok": true,
		"political_aptitude": political_aptitude,
		"effect_amount": _get_spy_public_support_disrupt_amount(political_aptitude),
		"cost": {},
		"success_chance": _get_spy_info_success_chance(),
		"detection_chance": _calculate_spy_detection_chance(target_city_id),
	}


func _roll_spy_public_support_disrupt_result(target_city_id: String, forced_roll: int = -1, forced_detection_roll: int = -1) -> Dictionary:
	var check := _can_disrupt_city_public_support(target_city_id)
	if not bool(check.get("ok", false)):
		return {
			"ok": false,
			"reason": str(check.get("reason", "unknown")),
			"target_city_id": target_city_id,
			"success": false,
			"detected": false,
		}
	var roll := forced_roll if forced_roll >= 0 else (randi() % 100) + 1
	var detection_roll := forced_detection_roll if forced_detection_roll >= 0 else (randi() % 100) + 1
	roll = clampi(roll, 1, 100)
	detection_roll = clampi(detection_roll, 1, 100)
	var success_chance := int(check.get("success_chance", 0))
	var detection_chance := int(check.get("detection_chance", 0))
	var detected := detection_roll <= detection_chance
	var success := roll <= success_chance
	return {
		"ok": true,
		"target_city_id": target_city_id,
		"political_aptitude": int(check.get("political_aptitude", 0)),
		"effect_amount": int(check.get("effect_amount", 0)),
		"cost": check.get("cost", {}),
		"roll": roll,
		"success_chance": success_chance,
		"success": success,
		"detection_roll": detection_roll,
		"detection_chance": detection_chance,
		"detected": detected,
		"effect_applied": success and not detected,
	}


func _get_spy_public_support_disrupt_cooldown_turns() -> int:
	return maxi(1, SPY_PUBLIC_SUPPORT_DISRUPT_COOLDOWN_TURNS - (2 if _is_current_chancellor_political_type() else 0))


func _get_spy_action_cooldown_turns(base_cooldown: int) -> int:
	return maxi(1, base_cooldown - (2 if _is_current_chancellor_political_type() else 0))


func _disrupt_city_public_support(target_city_id: String, forced_roll: int = -1, forced_detection_roll: int = -1) -> Dictionary:
	var check := _can_disrupt_city_public_support(target_city_id)
	var turn_number := maxi(1, int(_player_state.get("turn_number", 1)))
	var city_data := _get_city_hud_entry(target_city_id)
	var target_faction := _get_city_owner_faction_id(city_data) if not city_data.is_empty() else ""
	var before_support := _get_city_public_support(target_city_id) if not city_data.is_empty() else CITY_PUBLIC_SUPPORT_DEFAULT
	if not bool(check.get("ok", false)):
		var failed_result := {
			"turn": turn_number,
			"action_id": SPY_ACTION_PUBLIC_SUPPORT_DISRUPT,
			"action_label": "민심 교란",
			"target_city_id": target_city_id,
			"target_faction": target_faction,
			"target_faction_id": target_faction,
			"success": false,
			"detected": false,
			"effect_applied": false,
			"reason": str(check.get("reason", "unknown")),
			"publicSupport_before": before_support,
			"publicSupport_after": before_support,
			"relation_penalty": 0,
			"cost": {},
			"cooldown": 0,
			"message": _format_spy_validation_message(check),
		}
		_player_state["last_spy_public_support_disrupt_result"] = failed_result
		return failed_result
	var roll_result := _roll_spy_public_support_disrupt_result(target_city_id, forced_roll, forced_detection_roll)
	var cost: Dictionary = check.get("cost", {})
	var cooldown := _get_spy_public_support_disrupt_cooldown_turns()
	_player_state["spy_cooldown"] = cooldown
	var relation_penalty := 0
	var relation_change := {"before_score": DIPLOMACY_DEFAULT_SCORE, "after_score": DIPLOMACY_DEFAULT_SCORE}
	if not target_faction.is_empty():
		var current_score := _get_faction_relation_score(PLAYER_FACTION_ID, target_faction)
		relation_change = {"before_score": current_score, "after_score": current_score}
	var after_support := before_support
	var effect_applied := bool(roll_result.get("effect_applied", false))
	if bool(roll_result.get("detected", false)):
		relation_penalty = SPY_DETECTED_RELATION_PENALTY_PUBLIC_SUPPORT
		if not target_faction.is_empty():
			relation_change = _apply_spy_detection_relation_penalty(target_faction, relation_penalty, "spy_public_support_disrupt_detected")
	elif effect_applied:
		after_support = clampi(before_support - int(roll_result.get("effect_amount", 0)), 0, 100)
		_set_city_public_support(target_city_id, after_support)
	var result := {
		"turn": turn_number,
		"action_id": SPY_ACTION_PUBLIC_SUPPORT_DISRUPT,
		"action_label": "민심 교란",
		"target_city_id": target_city_id,
		"target_faction": target_faction,
		"target_faction_id": target_faction,
		"political_aptitude": int(roll_result.get("political_aptitude", 0)),
		"roll": int(roll_result.get("roll", -1)),
		"success_chance": int(roll_result.get("success_chance", 0)),
		"success": bool(roll_result.get("success", false)),
		"detection_roll": int(roll_result.get("detection_roll", -1)),
		"detection_chance": int(roll_result.get("detection_chance", 0)),
		"detected": bool(roll_result.get("detected", false)),
		"effect_amount": int(roll_result.get("effect_amount", 0)),
		"effect_applied": effect_applied and not bool(roll_result.get("detected", false)),
		"publicSupport_before": before_support,
		"publicSupport_after": after_support,
		"relation_penalty": relation_penalty,
		"before_score": int(relation_change.get("before_score", 0)),
		"after_score": int(relation_change.get("after_score", 0)),
		"cost": cost,
		"cooldown": cooldown,
		"message": "민심 교란에 성공했습니다." if effect_applied and not bool(roll_result.get("detected", false)) else "민심 교란에 실패했습니다.",
	}
	_player_state["last_spy_public_support_disrupt_result"] = result
	return result


func _get_spy_loyalty_disrupt_amount(political_aptitude: int) -> int:
	match clampi(political_aptitude, 0, 5):
		5:
			return 10
		4:
			return 7
		3:
			return 5
		2:
			return 3
		1:
			return 1
		_:
			return 0


func _get_spy_loyalty_disrupt_cost(_target_city_id: String) -> Dictionary:
	return SPY_LOYALTY_DISRUPT_COST.duplicate(true)


func _can_disrupt_city_loyalty(target_city_id: String) -> Dictionary:
	var city_data := _get_city_hud_entry(target_city_id)
	if target_city_id.is_empty() or city_data.is_empty():
		return {"ok": false, "reason": "invalid_target"}
	if _is_city_owned_by_player_mvp(target_city_id):
		return {"ok": false, "reason": "own_city"}
	var chancellor_id := str(_player_state.get("chancellor_id", ""))
	if chancellor_id.is_empty() or _get_hero_entry(chancellor_id).is_empty():
		return {"ok": false, "reason": "no_chancellor"}
	var political_aptitude := _get_current_chancellor_political_aptitude()
	if political_aptitude <= 0:
		return {"ok": false, "reason": "no_political_aptitude"}
	var spy_cooldown := maxi(0, int(_player_state.get("spy_cooldown", 0)))
	if spy_cooldown > 0:
		return {"ok": false, "reason": "cooldown", "cooldown": spy_cooldown}
	var security := _get_city_security_score_for_spy(target_city_id)
	var loyalty := _get_city_loyalty_value(city_data)
	if security >= 100 and loyalty >= 100:
		return {"ok": false, "reason": "iron_wall", "security": security, "loyalty": loyalty}
	return {
		"ok": true,
		"political_aptitude": political_aptitude,
		"effect_amount": _get_spy_loyalty_disrupt_amount(political_aptitude),
		"cost": {},
		"success_chance": _get_spy_info_success_chance(),
		"detection_chance": _calculate_spy_detection_chance(target_city_id),
	}


func _roll_spy_loyalty_disrupt_result(target_city_id: String, forced_roll: int = -1, forced_detection_roll: int = -1) -> Dictionary:
	var check := _can_disrupt_city_loyalty(target_city_id)
	if not bool(check.get("ok", false)):
		return {"ok": false, "reason": str(check.get("reason", "unknown")), "target_city_id": target_city_id, "success": false, "detected": false}
	var roll := forced_roll if forced_roll >= 0 else (randi() % 100) + 1
	var detection_roll := forced_detection_roll if forced_detection_roll >= 0 else (randi() % 100) + 1
	roll = clampi(roll, 1, 100)
	detection_roll = clampi(detection_roll, 1, 100)
	var success_chance := int(check.get("success_chance", 0))
	var detection_chance := int(check.get("detection_chance", 0))
	var detected := detection_roll <= detection_chance
	var success := roll <= success_chance
	return {
		"ok": true,
		"target_city_id": target_city_id,
		"political_aptitude": int(check.get("political_aptitude", 0)),
		"effect_amount": int(check.get("effect_amount", 0)),
		"cost": check.get("cost", {}),
		"roll": roll,
		"success_chance": success_chance,
		"success": success,
		"detection_roll": detection_roll,
		"detection_chance": detection_chance,
		"detected": detected,
		"effect_applied": success and not detected,
	}


func _disrupt_city_loyalty(target_city_id: String, forced_roll: int = -1, forced_detection_roll: int = -1) -> Dictionary:
	var check := _can_disrupt_city_loyalty(target_city_id)
	var turn_number := maxi(1, int(_player_state.get("turn_number", 1)))
	var city_data := _get_city_hud_entry(target_city_id)
	var target_faction := _get_city_owner_faction_id(city_data) if not city_data.is_empty() else ""
	var before_loyalty := _get_city_loyalty_value(city_data) if not city_data.is_empty() else 75
	if not bool(check.get("ok", false)):
		var failed_result := {
			"turn": turn_number,
			"action_id": SPY_ACTION_LOYALTY_DISRUPT,
			"action_label": "성 충성도 교란",
			"target_city_id": target_city_id,
			"target_faction": target_faction,
			"target_faction_id": target_faction,
			"success": false,
			"detected": false,
			"effect_applied": false,
			"reason": str(check.get("reason", "unknown")),
			"loyalty_before": before_loyalty,
			"loyalty_after": before_loyalty,
			"relation_penalty": 0,
			"cost": {},
			"cooldown": 0,
			"message": _format_spy_validation_message(check),
		}
		_player_state["last_spy_loyalty_disrupt_result"] = failed_result
		return failed_result
	var roll_result := _roll_spy_loyalty_disrupt_result(target_city_id, forced_roll, forced_detection_roll)
	var cost: Dictionary = check.get("cost", {})
	var cooldown := _get_spy_action_cooldown_turns(SPY_LOYALTY_DISRUPT_COOLDOWN_TURNS)
	_player_state["spy_cooldown"] = cooldown
	var relation_penalty := 0
	var relation_change := {"before_score": DIPLOMACY_DEFAULT_SCORE, "after_score": DIPLOMACY_DEFAULT_SCORE}
	if not target_faction.is_empty():
		var current_score := _get_faction_relation_score(PLAYER_FACTION_ID, target_faction)
		relation_change = {"before_score": current_score, "after_score": current_score}
	var after_loyalty := before_loyalty
	var effect_applied := bool(roll_result.get("effect_applied", false))
	if bool(roll_result.get("detected", false)):
		relation_penalty = SPY_DETECTED_RELATION_PENALTY_LOYALTY
		if not target_faction.is_empty():
			relation_change = _apply_spy_detection_relation_penalty(target_faction, relation_penalty, "spy_loyalty_disrupt_detected")
	elif effect_applied:
		after_loyalty = clampi(before_loyalty - int(roll_result.get("effect_amount", 0)), 0, 100)
		_set_city_loyalty_value(target_city_id, after_loyalty)
	var result := {
		"turn": turn_number,
		"action_id": SPY_ACTION_LOYALTY_DISRUPT,
		"action_label": "성 충성도 교란",
		"target_city_id": target_city_id,
		"target_faction": target_faction,
		"target_faction_id": target_faction,
		"political_aptitude": int(roll_result.get("political_aptitude", 0)),
		"roll": int(roll_result.get("roll", -1)),
		"success_chance": int(roll_result.get("success_chance", 0)),
		"success": bool(roll_result.get("success", false)),
		"detection_roll": int(roll_result.get("detection_roll", -1)),
		"detection_chance": int(roll_result.get("detection_chance", 0)),
		"detected": bool(roll_result.get("detected", false)),
		"effect_amount": int(roll_result.get("effect_amount", 0)),
		"effect_applied": effect_applied and not bool(roll_result.get("detected", false)),
		"loyalty_before": before_loyalty,
		"loyalty_after": after_loyalty,
		"relation_penalty": relation_penalty,
		"before_score": int(relation_change.get("before_score", 0)),
		"after_score": int(relation_change.get("after_score", 0)),
		"cost": cost,
		"cooldown": cooldown,
		"message": "성 충성도 교란에 성공했습니다." if effect_applied and not bool(roll_result.get("detected", false)) else "성 충성도 교란에 실패했습니다.",
	}
	_player_state["last_spy_loyalty_disrupt_result"] = result
	return result


func _get_spy_revolt_instigation_boost(political_aptitude: int) -> int:
	match clampi(political_aptitude, 0, 5):
		5:
			return 50
		4:
			return 35
		3:
			return 20
		2:
			return 10
		1:
			return 5
		_:
			return 0


func _get_spy_revolt_instigation_cost(_target_city_id: String) -> Dictionary:
	return SPY_REVOLT_INSTIGATION_COST.duplicate(true)


func _can_instigate_revolt(target_city_id: String) -> Dictionary:
	var city_data := _get_city_hud_entry(target_city_id)
	if target_city_id.is_empty() or city_data.is_empty():
		return {"ok": false, "reason": "invalid_target"}
	if _is_city_owned_by_player_mvp(target_city_id):
		return {"ok": false, "reason": "own_city"}
	var chancellor_id := str(_player_state.get("chancellor_id", ""))
	if chancellor_id.is_empty() or _get_hero_entry(chancellor_id).is_empty():
		return {"ok": false, "reason": "no_chancellor"}
	var political_aptitude := _get_current_chancellor_political_aptitude()
	if political_aptitude <= 0:
		return {"ok": false, "reason": "no_political_aptitude"}
	var spy_cooldown := maxi(0, int(_player_state.get("spy_cooldown", 0)))
	if spy_cooldown > 0:
		return {"ok": false, "reason": "cooldown", "cooldown": spy_cooldown}
	var security := _get_city_security_score_for_spy(target_city_id)
	var loyalty := _get_city_loyalty_value(city_data)
	if security >= 100 and loyalty >= 100:
		return {"ok": false, "reason": "iron_wall", "security": security, "loyalty": loyalty}
	var public_support := _get_city_public_support(target_city_id)
	if public_support > 50:
		return {"ok": false, "reason": "prerequisite_public_support", "publicSupport": public_support}
	if loyalty > 40:
		return {"ok": false, "reason": "prerequisite_loyalty", "loyalty": loyalty}
	return {
		"ok": true,
		"political_aptitude": political_aptitude,
		"probability_boost": _get_spy_revolt_instigation_boost(political_aptitude),
		"cost": {},
		"success_chance": _get_spy_info_success_chance(),
		"detection_chance": _calculate_spy_detection_chance(target_city_id),
		"publicSupport": public_support,
		"loyalty": loyalty,
	}


func _roll_spy_revolt_instigation_result(target_city_id: String, forced_roll: int = -1, forced_detection_roll: int = -1) -> Dictionary:
	var check := _can_instigate_revolt(target_city_id)
	if not bool(check.get("ok", false)):
		return {"ok": false, "reason": str(check.get("reason", "unknown")), "target_city_id": target_city_id, "success": false, "detected": false}
	var roll := forced_roll if forced_roll >= 0 else (randi() % 100) + 1
	var detection_roll := forced_detection_roll if forced_detection_roll >= 0 else (randi() % 100) + 1
	roll = clampi(roll, 1, 100)
	detection_roll = clampi(detection_roll, 1, 100)
	var success_chance := int(check.get("success_chance", 0))
	var detection_chance := int(check.get("detection_chance", 0))
	var detected := detection_roll <= detection_chance
	var success := roll <= success_chance
	return {
		"ok": true,
		"target_city_id": target_city_id,
		"political_aptitude": int(check.get("political_aptitude", 0)),
		"probability_boost": int(check.get("probability_boost", 0)),
		"cost": check.get("cost", {}),
		"roll": roll,
		"success_chance": success_chance,
		"success": success,
		"detection_roll": detection_roll,
		"detection_chance": detection_chance,
		"detected": detected,
		"effect_applied": success and not detected,
	}


func _instigate_revolt(target_city_id: String, forced_roll: int = -1, forced_detection_roll: int = -1) -> Dictionary:
	var check := _can_instigate_revolt(target_city_id)
	var turn_number := maxi(1, int(_player_state.get("turn_number", 1)))
	var city_data := _get_city_hud_entry(target_city_id)
	var target_faction := _get_city_owner_faction_id(city_data) if not city_data.is_empty() else ""
	if not bool(check.get("ok", false)):
		var failed_result := {
			"turn": turn_number,
			"action_id": SPY_ACTION_REVOLT_INSTIGATE,
			"action_label": "반란 조장",
			"target_city_id": target_city_id,
			"target_faction": target_faction,
			"target_faction_id": target_faction,
			"success": false,
			"detected": false,
			"effect_applied": false,
			"reason": str(check.get("reason", "unknown")),
			"relation_penalty": 0,
			"cost": {},
			"cooldown": 0,
			"message": _format_spy_validation_message(check),
		}
		_player_state["last_spy_revolt_instigation_result"] = failed_result
		return failed_result
	var roll_result := _roll_spy_revolt_instigation_result(target_city_id, forced_roll, forced_detection_roll)
	var cost: Dictionary = check.get("cost", {})
	var cooldown := _get_spy_action_cooldown_turns(SPY_REVOLT_INSTIGATION_COOLDOWN_TURNS)
	_player_state["spy_cooldown"] = cooldown
	var relation_penalty := 0
	var relation_change := {"before_score": DIPLOMACY_DEFAULT_SCORE, "after_score": DIPLOMACY_DEFAULT_SCORE}
	if not target_faction.is_empty():
		var current_score := _get_faction_relation_score(PLAYER_FACTION_ID, target_faction)
		relation_change = {"before_score": current_score, "after_score": current_score}
	var effect_applied := bool(roll_result.get("effect_applied", false))
	if bool(roll_result.get("detected", false)):
		relation_penalty = SPY_DETECTED_RELATION_PENALTY_REVOLT
		if not target_faction.is_empty():
			relation_change = _apply_spy_detection_relation_penalty(target_faction, relation_penalty, "spy_revolt_instigation_detected")
	elif effect_applied:
		var instigations: Dictionary = {}
		var raw_instigations: Variant = _player_state.get("revolt_instigation", {})
		if raw_instigations is Dictionary:
			instigations = raw_instigations as Dictionary
		instigations[target_city_id] = {
			"turns_remaining": SPY_REVOLT_INSTIGATION_DURATION_TURNS,
			"probability_boost": int(roll_result.get("probability_boost", 0)),
			"source": "spy",
			"started_turn": turn_number,
		}
		_player_state["revolt_instigation"] = instigations
	var result := {
		"turn": turn_number,
		"action_id": SPY_ACTION_REVOLT_INSTIGATE,
		"action_label": "반란 조장",
		"target_city_id": target_city_id,
		"target_faction": target_faction,
		"target_faction_id": target_faction,
		"political_aptitude": int(roll_result.get("political_aptitude", 0)),
		"roll": int(roll_result.get("roll", -1)),
		"success_chance": int(roll_result.get("success_chance", 0)),
		"success": bool(roll_result.get("success", false)),
		"detection_roll": int(roll_result.get("detection_roll", -1)),
		"detection_chance": int(roll_result.get("detection_chance", 0)),
		"detected": bool(roll_result.get("detected", false)),
		"probability_boost": int(roll_result.get("probability_boost", 0)),
		"effect_applied": effect_applied and not bool(roll_result.get("detected", false)),
		"relation_penalty": relation_penalty,
		"before_score": int(relation_change.get("before_score", 0)),
		"after_score": int(relation_change.get("after_score", 0)),
		"cost": cost,
		"cooldown": cooldown,
		"message": "반란 조장에 성공했습니다." if effect_applied and not bool(roll_result.get("detected", false)) else "반란 조장에 실패했습니다.",
	}
	_player_state["last_spy_revolt_instigation_result"] = result
	return result


func _advance_revolt_instigation_for_world_turn() -> Dictionary:
	var instigations: Dictionary = {}
	var raw_instigations: Variant = _player_state.get("revolt_instigation", {})
	if raw_instigations is Dictionary:
		instigations = raw_instigations as Dictionary
	var changed: Array = []
	var expired: Array = []
	for city_id_variant in instigations.keys():
		var city_id := str(city_id_variant)
		var entry_variant: Variant = instigations.get(city_id, {})
		if not entry_variant is Dictionary:
			expired.append(city_id)
			continue
		var entry := (entry_variant as Dictionary).duplicate(true)
		var before_turns := maxi(0, int(entry.get("turns_remaining", 0)))
		var after_turns := maxi(0, before_turns - 1)
		if after_turns <= 0:
			expired.append(city_id)
		else:
			entry["turns_remaining"] = after_turns
			instigations[city_id] = entry
		changed.append({"city_id": city_id, "before": before_turns, "after": after_turns})
	for city_id_variant in expired:
		instigations.erase(str(city_id_variant))
	_player_state["revolt_instigation"] = instigations
	var result := {
		"turn": maxi(1, int(_player_state.get("turn_number", 1))),
		"changed": changed,
		"expired": expired,
		"active_count": instigations.size(),
	}
	_player_state["last_revolt_instigation_tick_result"] = result
	return result


func _get_spy_wedge_relation_delta(political_aptitude: int) -> int:
	match clampi(political_aptitude, 0, 5):
		5:
			return 20
		4:
			return 15
		3:
			return 12
		2:
			return 12
		1:
			return 12
		_:
			return 0


func _get_spy_wedge_cost(_target_faction_a: String, _target_faction_b: String) -> Dictionary:
	return SPY_WEDGE_COST.duplicate(true)


func _calculate_spy_wedge_detection_chance(target_city_id: String = "") -> int:
	return clampi(_calculate_spy_detection_chance(target_city_id) + 10, 0, 95)


func _get_spy_wedge_candidate_faction_ids(target_faction_id: String) -> Array[String]:
	var result: Array[String] = []
	for faction_id_variant in _get_known_faction_ids_for_diplomacy():
		var faction_id := str(faction_id_variant)
		if faction_id.is_empty() or faction_id == PLAYER_FACTION_ID or faction_id == target_faction_id:
			continue
		result.append(faction_id)
	return result


func _get_spy_wedge_counterpart_faction_id(target_faction_id: String) -> String:
	if target_faction_id.is_empty() or target_faction_id == PLAYER_FACTION_ID:
		return ""
	var best_faction_id := ""
	var best_priority := -1
	var best_score := -1
	for candidate_faction_id in _get_spy_wedge_candidate_faction_ids(target_faction_id):
		var relation := _ensure_faction_relation_entry(target_faction_id, candidate_faction_id)
		var status := _normalize_faction_relation_status(str(relation.get("status", FACTION_RELATION_STATUS["NEUTRAL"])))
		var score := clampi(int(relation.get("score", DIPLOMACY_DEFAULT_SCORE)), DIPLOMACY_SCORE_MIN, DIPLOMACY_SCORE_MAX)
		var priority := 0
		if status == FACTION_RELATION_STATUS["ALLIED"]:
			priority = 4
		elif score >= 60:
			priority = 3
		elif int(relation.get("alliance_turns_remaining", 0)) > 0 or bool(relation.get("trade_agreement_active", false)) or int(relation.get("trade_agreement_turns_remaining", 0)) > 0:
			priority = 2
		else:
			priority = 1
		if priority > best_priority or (priority == best_priority and score > best_score):
			best_priority = priority
			best_score = score
			best_faction_id = candidate_faction_id
	return best_faction_id


func _get_spy_wedge_success_chance(target_city_id: String, counterpart_faction_id: String) -> int:
	var political_aptitude := _get_current_chancellor_political_aptitude()
	var city_security := _get_city_security_score_for_spy(target_city_id)
	var target_faction_id := _get_city_owner_faction_id_for_trade_display(target_city_id)
	var status := _get_faction_relation_status(target_faction_id, counterpart_faction_id)
	var chance := 35 + political_aptitude * 8 - int(floor(float(city_security) / 10.0))
	if status == FACTION_RELATION_STATUS["ALLIED"]:
		chance += 5
	return clampi(chance, 15, 80)


func _can_wedge_faction_relation(target_city_id: String) -> Dictionary:
	var city_data := _get_city_hud_entry(target_city_id)
	if target_city_id.is_empty() or city_data.is_empty():
		return {"ok": false, "reason": "invalid_target"}
	if _is_city_owned_by_player_mvp(target_city_id):
		return {"ok": false, "reason": "own_city"}
	var target_faction_id := _get_city_owner_faction_id(city_data)
	if target_faction_id.is_empty() or target_faction_id == PLAYER_FACTION_ID:
		return {"ok": false, "reason": "invalid_target"}
	var chancellor_id := str(_player_state.get("chancellor_id", ""))
	if chancellor_id.is_empty() or _get_hero_entry(chancellor_id).is_empty():
		return {"ok": false, "reason": "no_chancellor"}
	var political_aptitude := _get_current_chancellor_political_aptitude()
	if political_aptitude <= 0:
		return {"ok": false, "reason": "no_political_aptitude"}
	var spy_cooldown := maxi(0, int(_player_state.get("spy_cooldown", 0)))
	if spy_cooldown > 0:
		return {"ok": false, "reason": "cooldown", "cooldown": spy_cooldown}
	var security := _get_city_security_score_for_spy(target_city_id)
	var loyalty := _get_city_loyalty_value(city_data)
	if security >= 100 and loyalty >= 100:
		return {"ok": false, "reason": "iron_wall", "security": security, "loyalty": loyalty}
	var counterpart_faction_id := _get_spy_wedge_counterpart_faction_id(target_faction_id)
	if counterpart_faction_id.is_empty():
		return {"ok": false, "reason": "no_counterpart", "target_faction_id": target_faction_id}
	var relation := _ensure_faction_relation_entry(target_faction_id, counterpart_faction_id)
	var relation_status := _normalize_faction_relation_status(str(relation.get("status", FACTION_RELATION_STATUS["NEUTRAL"])))
	var relation_score := clampi(int(relation.get("score", DIPLOMACY_DEFAULT_SCORE)), DIPLOMACY_SCORE_MIN, DIPLOMACY_SCORE_MAX)
	if relation_status == FACTION_RELATION_STATUS["HOSTILE"] or relation_score <= 20:
		return {
			"ok": false,
			"reason": "already_hostile",
			"target_faction_id": target_faction_id,
			"counterpart_faction_id": counterpart_faction_id,
			"relation_score": relation_score,
			"relation_status": relation_status,
		}
	var cost := _get_spy_wedge_cost(target_faction_id, counterpart_faction_id)
	var payment_check := _can_pay_generic_resource_cost(cost)
	if not bool(payment_check.get("ok", false)):
		return {
			"ok": false,
			"reason": "resources",
			"target_faction_id": target_faction_id,
			"counterpart_faction_id": counterpart_faction_id,
			"cost": cost,
			"missing": payment_check.get("missing", {}),
		}
	return {
		"ok": true,
		"political_aptitude": political_aptitude,
		"target_city_id": target_city_id,
		"target_faction_id": target_faction_id,
		"counterpart_faction_id": counterpart_faction_id,
		"relation_score": relation_score,
		"relation_status": relation_status,
		"relation_delta": -_get_spy_wedge_relation_delta(political_aptitude),
		"cost": cost,
		"success_chance": _get_spy_wedge_success_chance(target_city_id, counterpart_faction_id),
		"detection_chance": _calculate_spy_wedge_detection_chance(target_city_id),
	}


func _can_drive_wedge(target_faction_a: String, target_faction_b: String) -> Dictionary:
	if target_faction_a.is_empty() or target_faction_b.is_empty() or target_faction_a == target_faction_b:
		return {"ok": false, "reason": "invalid_target"}
	if target_faction_a == PLAYER_FACTION_ID or target_faction_b == PLAYER_FACTION_ID:
		return {"ok": false, "reason": "self_target"}
	var status := _get_faction_relation_status(target_faction_a, target_faction_b)
	if status != FACTION_RELATION_STATUS["ALLIED"]:
		return {"ok": false, "reason": "not_allied", "status": status}
	var chancellor_id := str(_player_state.get("chancellor_id", ""))
	if chancellor_id.is_empty() or _get_hero_entry(chancellor_id).is_empty():
		return {"ok": false, "reason": "no_chancellor"}
	var political_aptitude := _get_current_chancellor_political_aptitude()
	if political_aptitude <= 0:
		return {"ok": false, "reason": "no_political_aptitude"}
	var spy_cooldown := maxi(0, int(_player_state.get("spy_cooldown", 0)))
	if spy_cooldown > 0:
		return {"ok": false, "reason": "cooldown", "cooldown": spy_cooldown}
	var cost := _get_spy_wedge_cost(target_faction_a, target_faction_b)
	var payment_check := _can_pay_generic_resource_cost(cost)
	if not bool(payment_check.get("ok", false)):
		return {"ok": false, "reason": "resources", "cost": cost, "missing": payment_check.get("missing", {})}
	return {
		"ok": true,
		"political_aptitude": political_aptitude,
		"relation_delta": _get_spy_wedge_relation_delta(political_aptitude),
		"cost": cost,
		"success_chance": _get_spy_info_success_chance(),
		"detection_chance": _calculate_spy_wedge_detection_chance(),
		"status": status,
	}


func _roll_spy_wedge_result(target_faction_a: String, target_faction_b: String, forced_roll: int = -1, forced_detection_roll: int = -1) -> Dictionary:
	var check := _can_drive_wedge(target_faction_a, target_faction_b)
	if not bool(check.get("ok", false)):
		return {"ok": false, "reason": str(check.get("reason", "unknown")), "success": false, "detected": false}
	var roll := forced_roll if forced_roll >= 0 else (randi() % 100) + 1
	var detection_roll := forced_detection_roll if forced_detection_roll >= 0 else (randi() % 100) + 1
	roll = clampi(roll, 1, 100)
	detection_roll = clampi(detection_roll, 1, 100)
	var success_chance := int(check.get("success_chance", 0))
	var detection_chance := int(check.get("detection_chance", 0))
	var detected := detection_roll <= detection_chance
	var success := roll <= success_chance
	return {
		"ok": true,
		"target_faction_a": target_faction_a,
		"target_faction_b": target_faction_b,
		"political_aptitude": int(check.get("political_aptitude", 0)),
		"relation_delta": int(check.get("relation_delta", 0)),
		"cost": check.get("cost", {}),
		"roll": roll,
		"success_chance": success_chance,
		"success": success,
		"detection_roll": detection_roll,
		"detection_chance": detection_chance,
		"detected": detected,
		"effect_applied": success,
	}


func _drive_wedge(target_faction_a: String, target_faction_b: String, forced_roll: int = -1, forced_detection_roll: int = -1) -> Dictionary:
	var check := _can_drive_wedge(target_faction_a, target_faction_b)
	var turn_number := maxi(1, int(_player_state.get("turn_number", 1)))
	if not bool(check.get("ok", false)):
		var failed_result := {
			"turn": turn_number,
			"target_faction_a": target_faction_a,
			"target_faction_b": target_faction_b,
			"success": false,
			"detected": false,
			"effect_applied": false,
			"reason": str(check.get("reason", "unknown")),
			"relation_delta": 0,
			"player_relation_penalty": 0,
			"cost": check.get("cost", _get_spy_wedge_cost(target_faction_a, target_faction_b)),
			"cooldown": 0,
		}
		_player_state["last_spy_wedge_result"] = failed_result
		return failed_result
	var roll_result := _roll_spy_wedge_result(target_faction_a, target_faction_b, forced_roll, forced_detection_roll)
	var cost: Dictionary = check.get("cost", {})
	_apply_generic_resource_cost(cost)
	var cooldown := _get_spy_action_cooldown_turns(SPY_WEDGE_COOLDOWN_TURNS)
	_player_state["spy_cooldown"] = cooldown
	var effect_applied := bool(roll_result.get("effect_applied", false))
	var player_relation_penalty := 0
	if bool(roll_result.get("detected", false)):
		player_relation_penalty = SPY_DETECTED_RELATION_PENALTY_WEDGE
		_adjust_faction_relation_score(PLAYER_FACTION_ID, target_faction_a, player_relation_penalty, "spy_wedge_detected")
	if effect_applied:
		_adjust_faction_relation_score(target_faction_a, target_faction_b, -int(roll_result.get("relation_delta", 0)), "spy_wedge")
	var result := {
		"turn": turn_number,
		"target_faction_a": target_faction_a,
		"target_faction_b": target_faction_b,
		"political_aptitude": int(roll_result.get("political_aptitude", 0)),
		"roll": int(roll_result.get("roll", -1)),
		"success_chance": int(roll_result.get("success_chance", 0)),
		"success": bool(roll_result.get("success", false)),
		"detection_roll": int(roll_result.get("detection_roll", -1)),
		"detection_chance": int(roll_result.get("detection_chance", 0)),
		"detected": bool(roll_result.get("detected", false)),
		"relation_delta": int(roll_result.get("relation_delta", 0)),
		"effect_applied": effect_applied,
		"player_relation_penalty": player_relation_penalty,
		"cost": cost,
		"cooldown": cooldown,
	}
	_player_state["last_spy_wedge_result"] = result
	return result


func _roll_spy_wedge_city_result(validation: Dictionary, forced_roll: int = -1, forced_detection_roll: int = -1) -> Dictionary:
	if not bool(validation.get("ok", false)):
		return {"ok": false, "reason": str(validation.get("reason", "unknown")), "success": false, "detected": false}
	var roll := forced_roll if forced_roll >= 0 else (randi() % 100) + 1
	var detection_roll := forced_detection_roll if forced_detection_roll >= 0 else (randi() % 100) + 1
	roll = clampi(roll, 1, 100)
	detection_roll = clampi(detection_roll, 1, 100)
	var success_chance := int(validation.get("success_chance", 0))
	var detection_chance := int(validation.get("detection_chance", 0))
	var success := roll <= success_chance
	var detected := detection_roll <= detection_chance
	return {
		"ok": true,
		"roll": roll,
		"success_chance": success_chance,
		"success": success,
		"detection_roll": detection_roll,
		"detection_chance": detection_chance,
		"detected": detected,
		"effect_applied": success,
	}


func _break_spy_wedge_alliance_if_needed(target_faction_id: String, counterpart_faction_id: String, after_score: int) -> bool:
	var relation_key := _make_faction_relation_key(target_faction_id, counterpart_faction_id)
	var relations: Dictionary = _player_state.get("faction_relations", {})
	var relation: Dictionary = relations.get(relation_key, _ensure_faction_relation_entry(target_faction_id, counterpart_faction_id))
	var status := _normalize_faction_relation_status(str(relation.get("status", FACTION_RELATION_STATUS["NEUTRAL"])))
	var active_turns := maxi(0, int(relation.get("alliance_turns_remaining", 0)))
	if status != FACTION_RELATION_STATUS["ALLIED"] and active_turns <= 0:
		return false
	if after_score >= ALLIANCE_ACCEPTANCE_THRESHOLD:
		return false
	relation["status"] = FACTION_RELATION_STATUS["NEUTRAL"]
	relation["alliance_turns_remaining"] = 0
	relation.erase("alliance_created_turn")
	relation.erase("alliance_resource_package")
	relation.erase("alliance_acceptance_score")
	relations[relation_key] = relation
	_player_state["faction_relations"] = relations
	_sync_diplomacy_action_mirror_state_from_relations()
	return true


func _apply_spy_wedge_action(validation: Dictionary, forced_roll: int = -1, forced_detection_roll: int = -1) -> Dictionary:
	var target_city_id := str(validation.get("target_city_id", ""))
	var target_faction_id := str(validation.get("target_faction_id", ""))
	var counterpart_faction_id := str(validation.get("counterpart_faction_id", ""))
	var turn_number := maxi(1, int(_player_state.get("turn_number", 1)))
	var cost: Dictionary = validation.get("cost", _get_spy_wedge_cost(target_faction_id, counterpart_faction_id))
	var payment_result := _apply_generic_resource_cost(cost)
	var cooldown := _get_spy_action_cooldown_turns(SPY_WEDGE_COOLDOWN_TURNS)
	_player_state["spy_cooldown"] = cooldown
	var roll_result := _roll_spy_wedge_city_result(validation, forced_roll, forced_detection_roll)
	var before_score := _get_faction_relation_score(target_faction_id, counterpart_faction_id)
	var after_score := before_score
	var relation_delta := int(validation.get("relation_delta", 0))
	var alliance_broken := false
	if bool(roll_result.get("effect_applied", false)):
		var wedge_relation_result := _adjust_faction_relation_score(target_faction_id, counterpart_faction_id, relation_delta, "spy_wedge")
		before_score = int(wedge_relation_result.get("before_score", before_score))
		after_score = int(wedge_relation_result.get("after_score", after_score))
		alliance_broken = _break_spy_wedge_alliance_if_needed(target_faction_id, counterpart_faction_id, after_score)
	var relation_penalty := 0
	var player_before_score := _get_faction_relation_score(PLAYER_FACTION_ID, target_faction_id)
	var player_after_score := player_before_score
	if bool(roll_result.get("detected", false)):
		relation_penalty = SPY_DETECTED_RELATION_PENALTY_WEDGE
		var detected_relation_result := _apply_spy_detection_relation_penalty(target_faction_id, relation_penalty, "spy_wedge_detected")
		player_before_score = int(detected_relation_result.get("before_score", player_before_score))
		player_after_score = int(detected_relation_result.get("after_score", player_after_score))
	var result := {
		"turn": turn_number,
		"action_id": SPY_ACTION_WEDGE,
		"action_label": "이간질",
		"target_city_id": target_city_id,
		"target_faction": target_faction_id,
		"target_faction_id": target_faction_id,
		"target_faction_a": target_faction_id,
		"counterpart_faction_id": counterpart_faction_id,
		"target_faction_b": counterpart_faction_id,
		"political_aptitude": int(validation.get("political_aptitude", 0)),
		"roll": int(roll_result.get("roll", -1)),
		"success_chance": int(roll_result.get("success_chance", 0)),
		"success": bool(roll_result.get("success", false)),
		"detection_roll": int(roll_result.get("detection_roll", -1)),
		"detection_chance": int(roll_result.get("detection_chance", 0)),
		"detected": bool(roll_result.get("detected", false)),
		"relation_delta": relation_delta if bool(roll_result.get("effect_applied", false)) else 0,
		"effect_applied": bool(roll_result.get("effect_applied", false)),
		"before_score": before_score,
		"after_score": after_score,
		"alliance_broken": alliance_broken,
		"relation_penalty": relation_penalty,
		"player_before_score": player_before_score,
		"player_after_score": player_after_score,
		"cost": cost,
		"payment": payment_result,
		"cooldown": cooldown,
		"message": "이간질에 성공했습니다." if bool(roll_result.get("effect_applied", false)) else "이간질에 실패했습니다.",
	}
	_player_state["last_spy_wedge_result"] = result
	return result


func _advance_spy_cooldown_for_world_turn() -> Dictionary:
	var before_cooldown := maxi(0, int(_player_state.get("spy_cooldown", 0)))
	var after_cooldown := maxi(0, before_cooldown - 1)
	_player_state["spy_cooldown"] = after_cooldown
	var result := {
		"turn": maxi(1, int(_player_state.get("turn_number", 1))),
		"before": before_cooldown,
		"after": after_cooldown,
		"changed": before_cooldown != after_cooldown,
	}
	_player_state["last_spy_cooldown_result"] = result
	return result


func _get_known_faction_ids_for_diplomacy() -> Array:
	var known := {}
	known[PLAYER_FACTION_ID] = true
	for city_id_variant in CITY_HUD_DATA.keys():
		var city_data: Dictionary = CITY_HUD_DATA.get(city_id_variant, {})
		var owner_id := _get_city_owner_faction_id(city_data)
		if not owner_id.is_empty():
			known[owner_id] = true
	var relations: Variant = _player_state.get("faction_relations", {})
	if relations is Dictionary:
		for relation_key_variant in (relations as Dictionary).keys():
			var parts := str(relation_key_variant).split("|")
			for part in parts:
				var faction_id := str(part)
				if not faction_id.is_empty():
					known[faction_id] = true
	var faction_ids: Array = known.keys()
	faction_ids.sort()
	return faction_ids


func _normalize_faction_relations_for_world_state() -> Dictionary:
	var faction_ids := _get_known_faction_ids_for_diplomacy()
	var ensured_count := 0
	var created_count := 0
	var patched_score_count := 0
	var patched_status_count := 0
	var patched_cooldown_count := 0
	var patched_tribute_cooldown_count := 0
	for i in range(faction_ids.size()):
		for j in range(i + 1, faction_ids.size()):
			var faction_a := str(faction_ids[i])
			var faction_b := str(faction_ids[j])
			var relation_key := _make_faction_relation_key(faction_a, faction_b)
			var relations_before: Dictionary = _player_state.get("faction_relations", {})
			var existed := relations_before.has(relation_key)
			var raw_entry: Variant = relations_before.get(relation_key, {})
			var had_score := raw_entry is Dictionary and (raw_entry as Dictionary).has("score")
			var had_status := raw_entry is Dictionary and (raw_entry as Dictionary).has("status")
			var had_cooldown := raw_entry is Dictionary and (raw_entry as Dictionary).has("cooldown")
			var had_tribute_cooldown := raw_entry is Dictionary and (raw_entry as Dictionary).has("tribute_cooldown")
			_ensure_faction_relation_entry(faction_a, faction_b)
			ensured_count += 1
			if not existed:
				created_count += 1
			elif not had_score:
				patched_score_count += 1
			if existed and not had_status:
				patched_status_count += 1
			if existed and not had_cooldown:
				patched_cooldown_count += 1
			if existed and not had_tribute_cooldown:
				patched_tribute_cooldown_count += 1
	var result := {
		"turn": maxi(1, int(_player_state.get("turn_number", 1))),
		"known_faction_count": faction_ids.size(),
		"ensured_count": ensured_count,
		"created_count": created_count,
		"patched_score_count": patched_score_count,
		"patched_status_count": patched_status_count,
		"patched_cooldown_count": patched_cooldown_count,
		"patched_tribute_cooldown_count": patched_tribute_cooldown_count,
	}
	_player_state["last_diplomacy_normalize_result"] = result
	return result


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
	var relation_score := _get_faction_relation_score(faction_a, faction_b)
	var relation_band := _get_faction_relation_band(relation_score)
	var resource_seed_a: Dictionary = city_a.get("resource_seed", {})
	var resource_seed_b: Dictionary = city_b.get("resource_seed", {})
	var base_gold := (_get_city_numeric_rating(city_a, "commerce_rating", 0) + _get_city_numeric_rating(city_b, "commerce_rating", 0)) * 3
	var average_loyalty := (float(_get_city_loyalty_value(city_a)) + float(_get_city_loyalty_value(city_b))) / 2.0
	var loyalty_multiplier := 1.0
	if average_loyalty >= 75.0:
		loyalty_multiplier = 1.05
	elif average_loyalty < 50.0:
		loyalty_multiplier = 0.9
	var trade_agreement_bonus := _get_trade_agreement_bonus_multiplier(faction_a, faction_b)
	var relation_multiplier := float(RELATION_TRADE_MULTIPLIER.get(relation_status, 1.0)) + trade_agreement_bonus
	var multiplier := loyalty_multiplier * relation_multiplier * TRADE_GLOBAL_DAMPENER
	return {
		"city_a_id": city_a_id,
		"city_b_id": city_b_id,
		"faction_a": faction_a,
		"faction_b": faction_b,
		"relation_status": relation_status,
		"relation_score": relation_score,
		"relation_band": relation_band,
		"trade_agreement_bonus": trade_agreement_bonus,
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


func _set_city_loyalty_value(city_id: String, value: int) -> void:
	var city_data := _get_mutable_city_runtime_state(city_id)
	if city_data.is_empty():
		return
	var normalized_value := clampi(value, 0, 100)
	city_data["loyalty"] = normalized_value
	city_data["cityLoyalty"] = normalized_value
	_city_runtime_states[city_id] = city_data


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


func _apply_seasonal_loyalty_from_public_support(turn_number: int, _supply_states: Dictionary = {}) -> Dictionary:
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


func _format_domestic_apply_summary(resource_delta: Dictionary, loyalty_delta: int, inter_faction_trade_result: Dictionary = {}, supply_state_result: Dictionary = {}, city_loyalty_drift_result: Dictionary = {}, public_support_result: Dictionary = {}, seasonal_loyalty_result: Dictionary = {}, conscription_result: Dictionary = {}, revolt_warning_result: Dictionary = {}, national_tech_progress_result: Dictionary = {}, city_tech_progress_result: Dictionary = {}, tech_effect_result: Dictionary = {}, trade_market_result: Dictionary = {}, diplomacy_normalize_result: Dictionary = {}, diplomacy_cooldown_result: Dictionary = {}, spy_cooldown_result: Dictionary = {}) -> String:
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
	if not national_tech_progress_result.is_empty():
		var national_summary := _format_national_tech_progress_summary(national_tech_progress_result)
		if not national_summary.is_empty():
			parts.append(national_summary)
	if not city_tech_progress_result.is_empty():
		var city_summary := _format_city_tech_progress_summary(city_tech_progress_result)
		if not city_summary.is_empty():
			parts.append(city_summary)
	if not tech_effect_result.is_empty():
		var effect_summary := _format_tech_effect_summary(tech_effect_result)
		if not effect_summary.is_empty():
			parts.append(effect_summary)
	if not trade_market_result.is_empty():
		var market_summary := _format_trade_market_summary(trade_market_result)
		if not market_summary.is_empty():
			parts.append(market_summary)
	if not diplomacy_normalize_result.is_empty():
		var diplomacy_summary := _format_diplomacy_normalize_summary(diplomacy_normalize_result)
		if not diplomacy_summary.is_empty():
			parts.append(diplomacy_summary)
	if not diplomacy_cooldown_result.is_empty():
		var cooldown_summary := _format_diplomacy_cooldown_summary(diplomacy_cooldown_result)
		if not cooldown_summary.is_empty():
			parts.append(cooldown_summary)
	var tribute_summary := _format_last_tribute_summary(maxi(1, int(diplomacy_cooldown_result.get("turn", _player_state.get("turn_number", 1)))))
	if not tribute_summary.is_empty():
		parts.append(tribute_summary)
	if not spy_cooldown_result.is_empty():
		var spy_cooldown_summary := _format_spy_cooldown_summary(spy_cooldown_result)
		if not spy_cooldown_summary.is_empty():
			parts.append(spy_cooldown_summary)
	var spy_summary := _format_last_spy_summary(maxi(1, int(spy_cooldown_result.get("turn", _player_state.get("turn_number", 1)))))
	if not spy_summary.is_empty():
		parts.append(spy_summary)
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


func _format_trade_market_summary(result: Dictionary) -> String:
	var prices: Variant = result.get("prices", {})
	if not prices is Dictionary:
		return ""
	var parts: Array[String] = []
	for resource_id in ["rice", "salt", "silk"]:
		var entry: Variant = (prices as Dictionary).get(resource_id, {})
		if not entry is Dictionary:
			continue
		parts.append("%s %dG %s" % [
			str((entry as Dictionary).get("name", _get_trade_resource_display_name(resource_id))),
			int((entry as Dictionary).get("price", 0)),
			_get_trade_market_trend_symbol(str((entry as Dictionary).get("trend", "flat"))),
		])
	return "" if parts.is_empty() else "시세: %s" % " / ".join(parts)


func _format_diplomacy_normalize_summary(result: Dictionary) -> String:
	var created_count := int(result.get("created_count", 0))
	var patched_count := int(result.get("patched_score_count", 0)) + int(result.get("patched_status_count", 0)) + int(result.get("patched_cooldown_count", 0)) + int(result.get("patched_tribute_cooldown_count", 0))
	if created_count <= 0 and patched_count <= 0:
		return ""
	return "외교 관계 정규화 %d건 · 보정 %d건" % [int(result.get("ensured_count", 0)), patched_count]


func _format_diplomacy_cooldown_summary(result: Dictionary) -> String:
	var changed_count := int(result.get("changed_count", 0))
	if changed_count <= 0:
		return ""
	var action_count := 0
	var tribute_count := 0
	var agreement_count := 0
	var changed_variant: Variant = result.get("changed", [])
	if changed_variant is Array:
		for changed_entry_variant in changed_variant:
			if not changed_entry_variant is Dictionary:
				continue
			match str((changed_entry_variant as Dictionary).get("type", "")):
				"diplomacy_action_cooldown":
					action_count += 1
				"trade_agreement":
					agreement_count += 1
				_:
					tribute_count += 1
	var parts: Array[String] = []
	if action_count > 0:
		parts.append("외교 행동 %d건" % action_count)
	if tribute_count > 0:
		parts.append("조공 %d건" % tribute_count)
	if agreement_count > 0:
		parts.append("교역 협정 %d건" % agreement_count)
	return "외교 경과 감소: %s" % " / ".join(parts)


func _format_last_tribute_summary(turn_number: int) -> String:
	var result: Variant = _player_state.get("last_tribute_result", {})
	if not result is Dictionary:
		return ""
	var tribute_result := result as Dictionary
	if not bool(tribute_result.get("success", false)):
		return ""
	if int(tribute_result.get("turn", 0)) != maxi(1, turn_number):
		return ""
	var target_faction := str(tribute_result.get("target_faction", ""))
	return "조공 결과: %s 관계 +%d, 현재 %d" % [
		str(FACTION_LABELS.get(target_faction, target_faction)),
		int(tribute_result.get("relation_gain", 0)),
		int(tribute_result.get("after_score", 0)),
	]


func _format_spy_cooldown_summary(result: Dictionary) -> String:
	if not bool(result.get("changed", false)):
		return ""
	return "첩보 쿨다운 감소: %d→%d" % [int(result.get("before", 0)), int(result.get("after", 0))]


func _format_last_spy_summary(turn_number: int) -> String:
	for result_key in ["last_spy_wedge_result", "last_spy_revolt_instigation_result", "last_spy_loyalty_disrupt_result"]:
		var action_result_variant: Variant = _player_state.get(result_key, {})
		if not action_result_variant is Dictionary:
			continue
		var action_result := action_result_variant as Dictionary
		if int(action_result.get("turn", 0)) != maxi(1, turn_number):
			continue
		if bool(action_result.get("detected", false)):
			if result_key == "last_spy_wedge_result":
				return "첩보 이간질 발각: %s 관계 %d" % [
					str(FACTION_LABELS.get(str(action_result.get("target_faction_id", action_result.get("target_faction_a", ""))), str(action_result.get("target_faction_id", action_result.get("target_faction_a", ""))))),
					int(action_result.get("relation_penalty", action_result.get("player_relation_penalty", 0))),
				]
			return "첩보 발각: %s 관계 %d" % [
				str(FACTION_LABELS.get(str(action_result.get("target_faction", "")), str(action_result.get("target_faction", "")))),
				int(action_result.get("relation_penalty", 0)),
			]
		if bool(action_result.get("effect_applied", false)):
			match result_key:
				"last_spy_loyalty_disrupt_result":
					return "첩보 충성도 교란 성공: %s 충성도 -%d" % [
						_format_city_name_by_id(str(action_result.get("target_city_id", "")), str(action_result.get("target_city_id", ""))),
						int(action_result.get("effect_amount", 0)),
					]
				"last_spy_revolt_instigation_result":
					return "첩보 반란 조장 성공: %s 위험 보정 +%d" % [
						_format_city_name_by_id(str(action_result.get("target_city_id", "")), str(action_result.get("target_city_id", ""))),
						int(action_result.get("probability_boost", 0)),
					]
				"last_spy_wedge_result":
					return "첩보 이간질 성공: %s-%s 관계 -%d" % [
						str(FACTION_LABELS.get(str(action_result.get("target_faction_a", "")), str(action_result.get("target_faction_a", "")))),
						str(FACTION_LABELS.get(str(action_result.get("target_faction_b", "")), str(action_result.get("target_faction_b", "")))),
						absi(int(action_result.get("relation_delta", 0))),
					]
		if action_result.has("success") and action_result.has("roll"):
			return "첩보 실패"
	var disrupt_result: Variant = _player_state.get("last_spy_public_support_disrupt_result", {})
	if disrupt_result is Dictionary:
		var public_support_result := disrupt_result as Dictionary
		if int(public_support_result.get("turn", 0)) == maxi(1, turn_number):
			if bool(public_support_result.get("detected", false)):
				return "첩보 발각: %s 관계 %d" % [
					str(FACTION_LABELS.get(str(public_support_result.get("target_faction", "")), str(public_support_result.get("target_faction", "")))),
					int(public_support_result.get("relation_penalty", 0)),
				]
			if bool(public_support_result.get("effect_applied", false)):
				return "첩보 민심 교란 성공: %s 민심 -%d" % [
					_format_city_name_by_id(str(public_support_result.get("target_city_id", "")), str(public_support_result.get("target_city_id", ""))),
					int(public_support_result.get("effect_amount", 0)),
				]
			if public_support_result.has("success") and public_support_result.has("roll"):
				return "첩보 실패"
	var result: Variant = _player_state.get("last_spy_result", {})
	if not result is Dictionary:
		return ""
	var spy_result := result as Dictionary
	if int(spy_result.get("turn", 0)) != maxi(1, turn_number):
		return ""
	if not bool(spy_result.get("success_valid", true)):
		return ""
	var outcome := "성공" if bool(spy_result.get("success", false)) else "실패"
	var detected_text := " / 발각" if bool(spy_result.get("detected", false)) else ""
	return "첩보 결과: %s%s" % [outcome, detected_text]


func _get_trade_market_trend_symbol(trend: String) -> String:
	match trend:
		"up_strong", "up":
			return "↑"
		"down_strong", "down":
			return "↓"
		_:
			return "→"


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


func _format_national_tech_progress_summary(result: Dictionary) -> String:
	var completed: Variant = result.get("completed", [])
	if not completed is Array or (completed as Array).is_empty():
		return ""
	var parts: Array[String] = []
	for entry_variant in completed:
		if not entry_variant is Dictionary:
			continue
		var tech_id := str((entry_variant as Dictionary).get("tech_id", ""))
		var definition := _get_national_tech_definition(tech_id)
		parts.append(str(definition.get("name", tech_id)))
	return "" if parts.is_empty() else "국가 테크 완료: %s" % " / ".join(parts)


func _format_city_tech_progress_summary(result: Dictionary) -> String:
	var completed: Variant = result.get("completed", [])
	if not completed is Array or (completed as Array).is_empty():
		return ""
	var parts: Array[String] = []
	for entry_variant in completed:
		if not entry_variant is Dictionary:
			continue
		var entry := entry_variant as Dictionary
		var city_id := str(entry.get("city_id", ""))
		var tech_id := str(entry.get("tech_id", ""))
		var definition := _get_city_tech_definition(tech_id)
		parts.append("%s / %s" % [_format_city_name_by_id(city_id, city_id), str(definition.get("name", tech_id))])
	return "" if parts.is_empty() else "도시 테크 완료: %s" % " / ".join(parts)


func _format_tech_effect_summary(result: Dictionary) -> String:
	var parts: Array[String] = []
	var applied: Variant = result.get("applied", [])
	if applied is Array:
		for entry_variant in applied:
			if not entry_variant is Dictionary:
				continue
			var entry := entry_variant as Dictionary
			var tech_id := str(entry.get("tech_id", ""))
			if tech_id == "legal_reform":
				parts.append("테크 효과 적용: 법률 정비 → 전국 민심 +5")
	var recognized: Variant = result.get("recognized_no_consumer", [])
	if recognized is Array and not (recognized as Array).is_empty():
		for entry_variant in recognized:
			if not entry_variant is Dictionary:
				continue
			var entry := entry_variant as Dictionary
			var tech_id := str(entry.get("tech_id", ""))
			if tech_id == "national_foundation":
				parts.append("테크 효과 인식: 국가 기반 정비 효과는 소비처 없음")
				break
	return " · ".join(parts)


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
	_sync_trade_persistence_to_player_state()
	var saved_player_state := _player_state.duplicate(true)
	saved_player_state["pending_invasion_event"] = {}
	saved_player_state["pending_battle_context"] = {}
	saved_player_state["enemy_invasion_roll_turn"] = 0
	var city_state := _serialize_worldmap_city_runtime_state()
	var hero_state := _serialize_worldmap_hero_runtime_state()
	var city_policy_state := _serialize_worldmap_city_policy_state()
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
		"city_policy_state": city_policy_state,
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
	_city_policy_state.clear()
	_apply_worldmap_city_runtime_state(data.get("worldmap_city_state", {}))
	_apply_worldmap_city_policy_state(data.get("city_policy_state", {}))
	_apply_worldmap_hero_runtime_state(data.get("worldmap_hero_state", {}))
	_restore_trade_persistence_from_player_state()
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
	_restore_trade_persistence_from_player_state()
	_city_runtime_states.clear()
	_hero_runtime_states.clear()
	_city_policy_state.clear()
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
	if not mutable_city_state.has("storage") or not (mutable_city_state["storage"] is Dictionary):
		mutable_city_state["storage"] = _build_default_city_storage(city_id, mutable_city_state)
	else:
		mutable_city_state["storage"] = _normalize_city_storage(mutable_city_state.get("storage"))
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
	if city_info_panel.has_method("set_player_faction_id"):
		city_info_panel.call("set_player_faction_id", PLAYER_FACTION_ID)
	if city_info_panel.has_method("set_enemy_city_intel"):
		city_info_panel.call("set_enemy_city_intel", _normalize_city_intel_registry(_player_state.get("city_intel", {})))
	city_info_panel.set_hud_data(_get_hero_data_for_ui(), _get_city_hud_data_for_ui(), GOVERNOR_POLICY_DATA, _city_policy_state)
	if city_info_panel.has_method("set_recruitment_summaries"):
		city_info_panel.call("set_recruitment_summaries", _get_recruitment_summaries_for_ui())
	if city_info_panel.has_method("set_revolt_risk_summaries"):
		city_info_panel.call("set_revolt_risk_summaries", _get_revolt_risk_summaries_for_ui())


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
			"governor_id": str(source.get("governor_id", "")),
			"governor_policy_id": _get_city_policy_id(city_id, source),
			"troops": maxi(0, int(source.get("troops", 0))),
			"publicSupport": _get_city_public_support(city_id),
			"loyalty": _get_city_loyalty_value(source),
			"cityLoyalty": _get_city_loyalty_value(source),
			"stationed_hero_ids": _normalize_hero_id_array(source.get("stationed_hero_ids", source.get("hero_ids", []))),
		}
		if source.has("resource_stock") and source.get("resource_stock") is Dictionary:
			city_payload["resource_stock"] = (source.get("resource_stock") as Dictionary).duplicate(true)
		if source.has("storage") and source.get("storage") is Dictionary:
			city_payload["storage"] = _normalize_city_storage(source.get("storage"))
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


func _serialize_worldmap_city_policy_state() -> Dictionary:
	var serialized := {}
	for city_id_variant in _city_policy_state.keys():
		var city_id := str(city_id_variant)
		if city_id.is_empty() or _get_city_hud_entry(city_id).is_empty():
			continue
		var policy_id := str(_city_policy_state.get(city_id, ""))
		if GOVERNOR_POLICY_DATA.has(policy_id):
			serialized[city_id] = policy_id
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
		if source.has("governor_id") or source.has("governorHeroId"):
			city_state["governor_id"] = str(source.get("governor_id", source.get("governorHeroId", "")))
		if source.has("governor_policy_id"):
			var loaded_policy_id := str(source.get("governor_policy_id", "follow_chancellor"))
			if GOVERNOR_POLICY_DATA.has(loaded_policy_id):
				city_state["governor_policy_id"] = loaded_policy_id
				_city_policy_state[city_id] = loaded_policy_id
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
		if source.has("storage") and source.get("storage") is Dictionary:
			city_state["storage"] = _normalize_city_storage(source.get("storage"))
		else:
			city_state["storage"] = _build_default_city_storage(city_id, city_state)
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


func _apply_worldmap_city_policy_state(raw_state: Variant) -> void:
	if raw_state == null:
		return
	if not raw_state is Dictionary:
		print("[LOAD_STATE_SKIP] type=city_policy_state reason=not_dictionary")
		return
	for city_id_variant in (raw_state as Dictionary).keys():
		var city_id := str(city_id_variant)
		if _get_city_hud_entry(city_id).is_empty() and not CITY_HUD_DATA.has(city_id):
			continue
		var policy_id := str((raw_state as Dictionary).get(city_id, ""))
		if GOVERNOR_POLICY_DATA.has(policy_id):
			_city_policy_state[city_id] = policy_id


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


func _get_city_storage(city_id: String, city_data: Dictionary = {}) -> Dictionary:
	var source_data: Dictionary = city_data
	if source_data.is_empty() and not city_id.is_empty():
		source_data = _get_city_hud_entry(city_id)
	var storage := {}
	if source_data.has("storage") and source_data.get("storage") is Dictionary:
		storage = _normalize_city_storage(source_data.get("storage"))
	else:
		storage = _build_default_city_storage(city_id, source_data)
	storage = _ensure_city_storage_keys(storage)
	if not city_id.is_empty():
		var runtime_state := _get_mutable_city_runtime_state(city_id)
		if not runtime_state.is_empty():
			runtime_state["storage"] = storage.duplicate(true)
			_city_runtime_states[city_id] = runtime_state
	return storage


func _normalize_city_storage(raw_storage: Variant) -> Dictionary:
	var storage := {}
	if not raw_storage is Dictionary:
		return storage
	for resource_id in RESOURCE_DISPLAY_ORDER:
		var resource_key := str(resource_id)
		storage[resource_key] = maxi(0, int((raw_storage as Dictionary).get(resource_key, 0)))
	return storage


func _ensure_city_storage_keys(storage: Dictionary) -> Dictionary:
	var normalized := {}
	for resource_id in RESOURCE_DISPLAY_ORDER:
		var resource_key := str(resource_id)
		normalized[resource_key] = maxi(0, int(storage.get(resource_key, 0)))
	return normalized


func _build_default_city_storage(city_id: String, _city_data: Dictionary) -> Dictionary:
	var storage := {}
	for resource_id in RESOURCE_DISPLAY_ORDER:
		var resource_key := str(resource_id)
		storage[resource_key] = 0
	if city_id == "hanseong":
		var raw_resource_stock: Variant = _player_state.get("resource_stock", {})
		if raw_resource_stock is Dictionary:
			for resource_id in RESOURCE_DISPLAY_ORDER:
				var resource_key := str(resource_id)
				storage[resource_key] = maxi(0, int((raw_resource_stock as Dictionary).get(resource_key, 0)))
	return storage


func _format_city_storage_summary(storage: Dictionary) -> String:
	var food_total := _get_city_storage_group_total(storage, CITY_STORAGE_FOOD_RESOURCE_IDS)
	var strategy_total := _get_city_storage_group_total(storage, CITY_STORAGE_STRATEGY_RESOURCE_IDS)
	var special_total := _get_city_storage_group_total(storage, CITY_STORAGE_SPECIAL_RESOURCE_IDS)
	var lines: Array[String] = ["성 창고"]
	lines.append("금전 %d" % _get_city_storage_amount(storage, "gold"))
	lines.append("식량 %d %s" % [
		food_total,
		_get_city_storage_status_label(food_total),
	])
	lines.append(_format_city_storage_group_details(storage, CITY_STORAGE_FOOD_RESOURCE_IDS))
	lines.append("전략 %d %s" % [
		strategy_total,
		_get_city_storage_status_label(strategy_total),
	])
	lines.append(_format_city_storage_group_details(storage, CITY_STORAGE_STRATEGY_RESOURCE_IDS))
	lines.append("특산 %d %s" % [
		special_total,
		_get_city_storage_status_label(special_total),
	])
	lines.append(_format_city_storage_group_details(storage, CITY_STORAGE_SPECIAL_RESOURCE_IDS))
	return "\n".join(lines)


func _get_city_storage_group_total(storage: Dictionary, resource_ids: Array) -> int:
	var total := 0
	for resource_id in resource_ids:
		total += _get_city_storage_amount(storage, str(resource_id))
	return total


func _format_city_storage_group_details(storage: Dictionary, resource_ids: Array) -> String:
	var parts: Array[String] = []
	for resource_id in resource_ids:
		var resource_key := str(resource_id)
		parts.append("%s %d" % [
			str(RESOURCE_LABELS.get(resource_key, resource_key)),
			_get_city_storage_amount(storage, resource_key),
		])
	return " / ".join(parts)


func _get_city_storage_amount(storage: Dictionary, resource_id: String) -> int:
	return maxi(0, int(storage.get(resource_id, 0)))


func _get_city_storage_status_label(total: int) -> String:
	if total >= 300:
		return "안정"
	if total >= 100:
		return "주의"
	return "부족"


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


func _get_player_chancellor_candidate_city_id() -> String:
	var capital_city_id := str(_player_state.get("capital_city_id", ""))
	if not capital_city_id.is_empty() and _is_city_owned_by_player_mvp(capital_city_id):
		return capital_city_id
	if _is_city_owned_by_player_mvp("hanseong"):
		return "hanseong"
	var owned_city_ids: Variant = _player_state.get("owned_city_ids", [])
	if owned_city_ids is Array:
		for city_id_variant in owned_city_ids:
			var city_id := str(city_id_variant)
			if _is_city_owned_by_player_mvp(city_id):
				return city_id
	return ""


func _is_valid_player_chancellor_candidate(hero_id: String, hero_data: Dictionary) -> bool:
	if hero_id.is_empty() or hero_data.is_empty():
		return false
	if str(hero_data.get("side", "")) != PLAYER_FACTION_ID:
		return false
	var status := str(hero_data.get("status", HERO_RUNTIME_STATUS_NORMAL))
	if bool(hero_data.get("dead", false)) or status == HERO_RUNTIME_STATUS_DEAD:
		return false
	if bool(hero_data.get("captured", false)) or status == HERO_RUNTIME_STATUS_CAPTURED:
		return false
	var primary_aptitude := int(hero_data.get("chancellor_primary_aptitude", 0))
	var secondary_aptitude := int(hero_data.get("chancellor_secondary_aptitude", 0))
	return primary_aptitude > 0 or secondary_aptitude > 0


func _get_player_chancellor_candidate_hero_ids() -> Array[String]:
	var result: Array[String] = []
	var candidate_city_id := _get_player_chancellor_candidate_city_id()
	if candidate_city_id.is_empty():
		return result
	var city_data := _get_city_hud_entry(candidate_city_id)
	if city_data.is_empty():
		return result
	for hero_id_variant in _get_stationed_hero_ids_for_city(city_data):
		var hero_id := str(hero_id_variant)
		var hero_data := _get_hero_entry(hero_id)
		if not _is_valid_player_chancellor_candidate(hero_id, hero_data):
			continue
		result.append(hero_id)
	return result


func _normalize_faction_chancellors(raw_value: Variant) -> Dictionary:
	var normalized := {}
	if raw_value is Dictionary:
		for faction_id_variant in (raw_value as Dictionary).keys():
			var faction_id := str(faction_id_variant)
			if faction_id.is_empty() or faction_id == PLAYER_FACTION_ID:
				continue
			var hero_id := str((raw_value as Dictionary).get(faction_id_variant, ""))
			if _is_valid_faction_chancellor_candidate(faction_id, hero_id):
				normalized[faction_id] = hero_id
	for faction_id in _get_known_non_player_faction_ids():
		var faction_id_string := str(faction_id)
		if normalized.has(faction_id_string):
			continue
		var best_hero_id := _find_best_chancellor_candidate_for_faction(faction_id_string)
		if not best_hero_id.is_empty():
			normalized[faction_id_string] = best_hero_id
	return normalized


func _ensure_faction_chancellors_seeded() -> void:
	_player_state["faction_chancellors"] = _normalize_faction_chancellors(_player_state.get("faction_chancellors", {}))


func _get_known_non_player_faction_ids() -> Array[String]:
	var known := {}
	for city_id_variant in CITY_HUD_DATA.keys():
		var city_id := str(city_id_variant)
		var city_data := _get_city_hud_entry(city_id)
		var faction_id := _get_city_owner_faction_id(city_data)
		if not faction_id.is_empty() and faction_id != PLAYER_FACTION_ID:
			known[faction_id] = true
	for hero_id_variant in HERO_DATA.keys():
		var hero_data := _get_hero_entry(str(hero_id_variant))
		var faction_id := _get_hero_faction_id_for_chancellor_seed(hero_data)
		if not faction_id.is_empty() and faction_id != PLAYER_FACTION_ID:
			known[faction_id] = true
	var sorted_ids: Array = known.keys()
	sorted_ids.sort()
	var result: Array[String] = []
	for faction_id_variant in sorted_ids:
		result.append(str(faction_id_variant))
	return result


func _get_faction_city_ids_for_chancellor_seed(faction_id: String) -> Array[String]:
	var city_ids: Array[String] = []
	if faction_id.is_empty():
		return city_ids
	for city_id_variant in CITY_HUD_DATA.keys():
		var city_id := str(city_id_variant)
		var city_data := _get_city_hud_entry(city_id)
		if city_data.is_empty() or _get_city_owner_faction_id(city_data) != faction_id:
			continue
		if not city_ids.has(city_id):
			city_ids.append(city_id)
	city_ids.sort()
	return city_ids


func _get_hero_faction_id_for_chancellor_seed(hero_data: Dictionary) -> String:
	return str(hero_data.get("side", hero_data.get("nation", hero_data.get("faction_id", hero_data.get("force_id", "")))))


func _is_valid_faction_chancellor_candidate(faction_id: String, hero_id: String) -> bool:
	if faction_id.is_empty() or faction_id == PLAYER_FACTION_ID or hero_id.is_empty():
		return false
	var hero_data := _get_hero_entry(hero_id)
	if hero_data.is_empty():
		return false
	var hero_faction_id := _get_hero_faction_id_for_chancellor_seed(hero_data)
	if hero_faction_id != faction_id and str(hero_data.get("nation", "")) != faction_id and str(hero_data.get("faction_id", "")) != faction_id and str(hero_data.get("force_id", "")) != faction_id:
		return false
	var status := str(hero_data.get("status", HERO_RUNTIME_STATUS_NORMAL))
	if bool(hero_data.get("dead", false)) or status == HERO_RUNTIME_STATUS_DEAD:
		return false
	if bool(hero_data.get("captured", false)) or status == HERO_RUNTIME_STATUS_CAPTURED:
		return false
	return _score_faction_chancellor_candidate(hero_id, hero_data) > 0


func _find_best_chancellor_candidate_for_faction(faction_id: String) -> String:
	var best_hero_id := ""
	var best_score := -1
	for city_id in _get_faction_city_ids_for_chancellor_seed(faction_id):
		var city_data := _get_city_hud_entry(city_id)
		for hero_id_variant in _get_stationed_hero_ids_for_city(city_data):
			var hero_id := str(hero_id_variant)
			var hero_data := _get_hero_entry(hero_id)
			if not _is_valid_faction_chancellor_candidate(faction_id, hero_id):
				continue
			var score := _score_faction_chancellor_candidate(hero_id, hero_data)
			if score > best_score:
				best_score = score
				best_hero_id = hero_id
	if not best_hero_id.is_empty():
		return best_hero_id
	for hero_id_variant in HERO_DATA.keys():
		var hero_id := str(hero_id_variant)
		var hero_data := _get_hero_entry(hero_id)
		if not _is_valid_faction_chancellor_candidate(faction_id, hero_id):
			continue
		var score := _score_faction_chancellor_candidate(hero_id, hero_data)
		if score > best_score:
			best_score = score
			best_hero_id = hero_id
	return best_hero_id


func _score_faction_chancellor_candidate(_hero_id: String, hero_data: Dictionary) -> int:
	var primary_aptitude := maxi(0, int(hero_data.get("chancellor_primary_aptitude", 0)))
	var secondary_aptitude := maxi(0, int(hero_data.get("chancellor_secondary_aptitude", 0)))
	var aptitude_score := (primary_aptitude * 10) + (secondary_aptitude * 5)
	if aptitude_score > 0:
		return aptitude_score
	return maxi(maxi(int(hero_data.get("politics", 0)), int(hero_data.get("intelligence", 0))), maxi(int(hero_data.get("command", 0)), int(hero_data.get("leadership", hero_data.get("war", 0)))))


func _sync_chancellor_assignment_for_selected_city(_city_data: Dictionary) -> void:
	# LeftWorldStatusPanel is player/nation scope. Selecting a foreign city must not clear national chancellor assignment.
	var current_chancellor_id := str(_player_state.get("chancellor_id", ""))
	if current_chancellor_id.is_empty():
		return
	var chancellor_data := _get_hero_entry(current_chancellor_id)
	if chancellor_data.is_empty() or str(chancellor_data.get("side", "")) != PLAYER_FACTION_ID:
		_player_state["chancellor_id"] = ""


func _populate_chancellor_assignment_dropdown(_city_data: Dictionary = {}) -> void:
	chancellor_assignment_option.clear()
	chancellor_assignment_option.add_item("미임명")
	chancellor_assignment_option.set_item_metadata(0, "")
	var candidate_hero_ids := _get_player_chancellor_candidate_hero_ids()
	var current_chancellor_id := str(_player_state.get("chancellor_id", ""))
	var current_chancellor_is_display_only := false
	if not current_chancellor_id.is_empty() and not candidate_hero_ids.has(current_chancellor_id):
		var current_chancellor_data := _get_hero_entry(current_chancellor_id)
		if _is_valid_player_chancellor_candidate(current_chancellor_id, current_chancellor_data):
			candidate_hero_ids.insert(0, current_chancellor_id)
			current_chancellor_is_display_only = true
	for hero_id in candidate_hero_ids:
		var hero_name := _format_hero_name_by_id(str(hero_id), "알 수 없는 장수")
		if current_chancellor_is_display_only and str(hero_id) == current_chancellor_id:
			hero_name = "%s (현재 임명)" % hero_name
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
	var portrait_box_control := portrait_box as Control
	portrait_box_control.custom_minimum_size = Vector2(56.0, 64.0)
	portrait_box_control.clip_contents = true
	_chancellor_portrait_texture_rect = TextureRect.new()
	_chancellor_portrait_texture_rect.name = "ChancellorPortraitTexture"
	_chancellor_portrait_texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_chancellor_portrait_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_chancellor_portrait_texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_chancellor_portrait_texture_rect.visible = false
	portrait_box.add_child(_chancellor_portrait_texture_rect)
	_chancellor_portrait_texture_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _get_chancellor_effect_text(hero_data: Dictionary) -> String:
	if hero_data.is_empty():
		return "없음"
	var tags: Array[String] = []
	_add_chancellor_effect_tag(tags, str(hero_data.get("chancellor_primary_type", "")))
	_add_chancellor_effect_tag(tags, str(hero_data.get("chancellor_secondary_type", "")))
	if tags.is_empty():
		tags.append("균형 운영")
	return ", ".join(tags.slice(0, 3))


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
			tag = "병사 유지비 완화"
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
	if not [UNIFIED_PANEL_TAB_CITY_DETAIL, UNIFIED_PANEL_TAB_DIPLOMACY_SPY, UNIFIED_PANEL_TAB_TRADE].has(tab_id):
		tab_id = UNIFIED_PANEL_TAB_CITY_DETAIL
	if tab_id != UNIFIED_PANEL_TAB_TRADE:
		_close_manual_trade_order_panel()
		_close_internal_trade_transfer_panel()
	_unified_primary_tab = tab_id
	if _unified_primary_tab == UNIFIED_PANEL_TAB_CITY_DETAIL:
		_selected_city_detail_tab = CITY_DETAIL_TAB_RESOURCES
	elif _unified_primary_tab == UNIFIED_PANEL_TAB_TRADE and not [CITY_DETAIL_TAB_INTERNAL_TRADE, CITY_DETAIL_TAB_EXTERNAL_TRADE].has(_selected_city_detail_tab):
		_selected_city_detail_tab = CITY_DETAIL_TAB_INTERNAL_TRADE
	print("[WorldMap] Unified city panel primary tab selected: %s." % tab_id)
	_refresh_unified_panel_content()


func _on_unified_secondary_tab_pressed(tab_index: int) -> void:
	if _unified_primary_tab == UNIFIED_PANEL_TAB_DIPLOMACY_SPY:
		_close_manual_trade_order_panel()
		_close_internal_trade_transfer_panel()
		_selected_diplomacy_spy_tab = DIPLOMACY_SPY_TAB_DIPLOMACY
		if tab_index == 1:
			_selected_diplomacy_spy_tab = DIPLOMACY_SPY_TAB_SPY
		print("[WorldMap] Unified diplomacy/spy tab selected: %s." % _selected_diplomacy_spy_tab)
		_show_unified_diplomacy_spy_content()
		return
	if _unified_primary_tab == UNIFIED_PANEL_TAB_TRADE:
		_selected_city_detail_tab = CITY_DETAIL_TAB_INTERNAL_TRADE
		if tab_index == 2:
			_selected_city_detail_tab = CITY_DETAIL_TAB_EXTERNAL_TRADE
		if _selected_city_detail_tab != CITY_DETAIL_TAB_EXTERNAL_TRADE:
			_close_manual_trade_order_panel()
		if _selected_city_detail_tab != CITY_DETAIL_TAB_INTERNAL_TRADE:
			_close_internal_trade_transfer_panel()
		print("[WorldMap] Unified trade tab selected: %s. Display only." % _selected_city_detail_tab)
		if selected_city_marker != null:
			_show_city_detail(selected_city_marker)
		else:
			_reset_city_detail_panel()
		_queue_unified_city_panel_resize()
		return

	_on_city_detail_tab_pressed(CITY_DETAIL_TAB_RESOURCES)


func _on_trade_control_mode_button_pressed(mode: String) -> void:
	if not [TRADE_CONTROL_MODE_CHANCELLOR, TRADE_CONTROL_MODE_MANUAL].has(mode):
		mode = TRADE_CONTROL_MODE_CHANCELLOR
	if _unified_primary_tab != UNIFIED_PANEL_TAB_TRADE:
		return
	if not [CITY_DETAIL_TAB_INTERNAL_TRADE, CITY_DETAIL_TAB_EXTERNAL_TRADE].has(_selected_city_detail_tab):
		return
	_trade_control_modes[_selected_city_detail_tab] = mode
	print("[WorldMap] Trade control mode selected: %s = %s. Display only; no trade/resource effect applied." % [_selected_city_detail_tab, mode])
	if selected_city_marker != null:
		_show_city_detail(selected_city_marker)
	else:
		_reset_city_detail_panel()
	if mode == TRADE_CONTROL_MODE_MANUAL and _selected_city_detail_tab == CITY_DETAIL_TAB_INTERNAL_TRADE and selected_city_marker != null:
		_close_manual_trade_order_panel()
		_open_internal_trade_transfer_panel(selected_city_marker.city_id)
	elif mode == TRADE_CONTROL_MODE_MANUAL and _selected_city_detail_tab == CITY_DETAIL_TAB_EXTERNAL_TRADE:
		_close_internal_trade_transfer_panel()
		_open_manual_trade_order_panel()
	else:
		_close_manual_trade_order_panel()
		_close_internal_trade_transfer_panel()
	_queue_unified_city_panel_resize()


func _on_city_detail_tab_pressed(tab_id: String) -> void:
	if not [CITY_DETAIL_TAB_RESOURCES, CITY_DETAIL_TAB_INTERNAL_TRADE, CITY_DETAIL_TAB_EXTERNAL_TRADE].has(tab_id):
		tab_id = CITY_DETAIL_TAB_RESOURCES
	if tab_id != CITY_DETAIL_TAB_EXTERNAL_TRADE:
		_close_manual_trade_order_panel()
	if tab_id != CITY_DETAIL_TAB_INTERNAL_TRADE:
		_close_internal_trade_transfer_panel()
	if [CITY_DETAIL_TAB_INTERNAL_TRADE, CITY_DETAIL_TAB_EXTERNAL_TRADE].has(tab_id):
		_unified_primary_tab = UNIFIED_PANEL_TAB_TRADE
	else:
		_unified_primary_tab = UNIFIED_PANEL_TAB_CITY_DETAIL
	_selected_city_detail_tab = tab_id
	print("[WorldMap] City detail tab selected: %s. Display only; no domestic/trade effect applied." % tab_id)
	if selected_city_marker != null:
		_show_city_detail(selected_city_marker)
	else:
		_reset_city_detail_panel()
	if tab_id == CITY_DETAIL_TAB_RESOURCES:
		city_detail_hint_label.text = "자원 잠재력은 생산 기반, 성 창고는 현재 보유량입니다."
	else:
		city_detail_hint_label.text = "%s 흐름을 확인합니다." % _get_city_detail_tab_label(tab_id)
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
	if _unified_trade_primary_button != null:
		_unified_trade_primary_button.visible = not is_collapsed

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
