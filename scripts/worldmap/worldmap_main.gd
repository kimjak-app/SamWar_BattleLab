extends Node2D

signal contextual_worldmap_action_presentation_requested(action_type: String, action_id: String, target_city_id: String)
signal contextual_worldmap_action_resolved(action_type: String, result: Dictionary)

const HeroDefinitionRegistryScript := preload(
	"res://scripts/worldmap/hero_definition_registry.gd"
)
const PlayerAttackDeploymentPanelScript := preload("res://scripts/player_attack_deployment_panel.gd")
const GameSessionScript := preload("res://scripts/game_session.gd")
const DomesticTechHelperLib := preload("res://scripts/worldmap/domestic_tech/domestic_tech_helpers.gd")
const DomesticTechCatalogScript := preload("res://scripts/worldmap/domestic_tech/domestic_tech_catalog.gd")
const DomesticTechResearchRulesScript := preload("res://scripts/worldmap/domestic_tech/domestic_tech_research_rules.gd")
const DomesticTechResearchServiceScript := preload("res://scripts/worldmap/domestic_tech/domestic_tech_research_service.gd")
const DomesticTechEffectProviderScript := preload("res://scripts/worldmap/domestic_tech/domestic_tech_effect_provider.gd")
const DomesticTechTreePresentationControllerScript := preload("res://scripts/worldmap/domestic_tech/domestic_tech_tree_presentation_controller.gd")
const DomesticTechCompletionPresentationControllerScript := preload("res://scripts/worldmap/domestic_tech/domestic_tech_completion_presentation_controller.gd")
const EconomyCityHelpers := preload("res://scripts/worldmap/economy_city/economy_city_helpers.gd")
const CityAdministrationServiceScript := preload("res://scripts/worldmap/economy_city/city_administration_service.gd")
const CityResourceServiceScript := preload("res://scripts/worldmap/economy_city/city_resource_service.gd")
const CityDetailPresentationControllerScript := preload("res://scripts/worldmap/economy_city/city_detail_presentation_controller.gd")
const DefenseBattleHelpers := preload("res://scripts/worldmap/defense_battle/defense_battle_helpers.gd")
const DiplomacySpyHelpers := preload("res://scripts/worldmap/diplomacy_spy/diplomacy_spy_helpers.gd")
const WorldMapActionCoordinatorScript := preload("res://scripts/worldmap/actions/worldmap_action_coordinator.gd")
const DiplomacyControllerScript := preload("res://scripts/worldmap/actions/diplomacy_controller.gd")
const DiplomacyPresentationHelperScript := preload("res://scripts/worldmap/actions/diplomacy_presentation_helper.gd")
const TradeControllerScript := preload("res://scripts/worldmap/actions/trade_controller.gd")
const TradePresentationHelperScript := preload("res://scripts/worldmap/actions/trade_presentation_helper.gd")
const SpyControllerScript := preload("res://scripts/worldmap/actions/spy_controller.gd")
const SpyPresentationHelperScript := preload("res://scripts/worldmap/actions/spy_presentation_helper.gd")
const MilitaryControllerScript := preload("res://scripts/worldmap/military/military_controller.gd")
const EnemyWarfareServiceScript := preload("res://scripts/worldmap/military/enemy_warfare_service.gd")
const WoundedRecoveryServiceScript := preload("res://scripts/worldmap/military/wounded_recovery_service.gd")
const PlayerAttackDeploymentServiceScript := preload("res://scripts/worldmap/military/player_attack_deployment_service.gd")
const TroopRebalanceServiceScript := preload("res://scripts/worldmap/military/troop_rebalance_service.gd")
const T03BattlePresentationControllerScript := preload("res://scripts/worldmap/t03/t03_battle_presentation_controller.gd")
const BattleContextServiceScript := preload("res://scripts/worldmap/battle/battle_context_service.gd")
const BattleResultServiceScript := preload("res://scripts/worldmap/battle/battle_result_service.gd")
const BattleSettlementApplierScript := preload("res://scripts/worldmap/battle/battle_settlement_applier.gd")
const UIFormatterHelpers := preload("res://scripts/worldmap/ui_formatter/ui_formatter_helpers.gd")
const T03AutoBattleResolverScript := preload("res://scripts/worldmap/t03/auto_battle_resolver.gd")
const StrategicBattleTransactionServiceScript := preload("res://scripts/worldmap/t03/strategic_battle_transaction_service.gd")
const TurnOutcomeRulesScript := preload("res://scripts/worldmap/t04_t05/turn_outcome_rules.gd")
const WorldMapCameraControllerScript := preload("res://scripts/worldmap/camera/worldmap_camera_controller.gd")
const WorldMapHudControllerScript := preload("res://scripts/worldmap/hud/worldmap_hud_controller.gd")
const WorldMapSharedUiControllerScript := preload("res://scripts/worldmap/ui/worldmap_shared_ui_controller.gd")
const WorldCalendarServiceScript := preload("res://scripts/worldmap/turn/world_calendar_service.gd")

const WORLD_UI_TOP_MARGIN := 10.0
const WORLD_UI_LEFT_MARGIN := 10.0
const LEFT_WORLD_STATUS_PANEL_TOP_LEFT := Vector2(WORLD_UI_LEFT_MARGIN, WORLD_UI_TOP_MARGIN)
const LEFT_WORLD_STATUS_PANEL_SIZE := Vector2(320.0, 570.0)
const SELECTED_CITY_INFO_PANEL_SIZE := Vector2(308.0, 542.0)
const UNIFIED_PANEL_TAB_CITY_DETAIL := "city-detail"
const UNIFIED_PANEL_TAB_DIPLOMACY_SPY := "diplomacy-spy"
const UNIFIED_PANEL_TAB_TRADE := "trade"
const CITY_DETAIL_TAB_RESOURCES := "resources"
const CITY_DETAIL_TAB_INTERNAL_TRADE := "internal-trade"
const CITY_DETAIL_TAB_EXTERNAL_TRADE := "external-trade"
const DOMESTIC_TECH_SCOPE_CITY := DomesticTechCatalogScript.DOMESTIC_TECH_SCOPE_CITY
const DOMESTIC_TECH_SCOPE_NATIONAL := DomesticTechCatalogScript.DOMESTIC_TECH_SCOPE_NATIONAL
const DOMESTIC_TECH_UI_SURFACE_CITY := DomesticTechCatalogScript.DOMESTIC_TECH_UI_SURFACE_CITY
const DOMESTIC_TECH_UI_SURFACE_NATIONAL := DomesticTechCatalogScript.DOMESTIC_TECH_UI_SURFACE_NATIONAL
const DOMESTIC_TECH_PROGRESS_CITY := DomesticTechCatalogScript.DOMESTIC_TECH_PROGRESS_CITY
const DOMESTIC_TECH_PROGRESS_NATIONAL := DomesticTechCatalogScript.DOMESTIC_TECH_PROGRESS_NATIONAL
const DOMESTIC_TECH_ICON_FALLBACK_LABEL := DomesticTechCatalogScript.DOMESTIC_TECH_ICON_FALLBACK_LABEL
const DOMESTIC_TECH_RESEARCH_KEY := "research"
const DOMESTIC_TECH_RESEARCH_ACTIVE_KEY := "active"
const DOMESTIC_TECH_CATEGORY_AGRI := DomesticTechCatalogScript.DOMESTIC_TECH_CATEGORY_AGRI
const DOMESTIC_TECH_CATEGORY_FISH := DomesticTechCatalogScript.DOMESTIC_TECH_CATEGORY_FISH
const DOMESTIC_TECH_CATEGORY_COMMERCE := DomesticTechCatalogScript.DOMESTIC_TECH_CATEGORY_COMMERCE
const DOMESTIC_TECH_CATEGORY_MILITARY := DomesticTechCatalogScript.DOMESTIC_TECH_CATEGORY_MILITARY
const DOMESTIC_TECH_CATEGORY_NATION_ADMIN := DomesticTechCatalogScript.DOMESTIC_TECH_CATEGORY_NATION_ADMIN
const DOMESTIC_TECH_CATEGORY_NATION_ECONOMY := DomesticTechCatalogScript.DOMESTIC_TECH_CATEGORY_NATION_ECONOMY
const DOMESTIC_TECH_CATEGORY_NATION_MILITARY := DomesticTechCatalogScript.DOMESTIC_TECH_CATEGORY_NATION_MILITARY
const DOMESTIC_TECH_CATEGORY_NATION_DIPLOMACY := DomesticTechCatalogScript.DOMESTIC_TECH_CATEGORY_NATION_DIPLOMACY
const DOMESTIC_TECH_VIEW_COMPLETED := "completed"
const DOMESTIC_TECH_VIEW_AVAILABLE := "available"
const DOMESTIC_TECH_VIEW_LOCKED := "locked"
const DOMESTIC_TECH_VIEW_SPECIAL_LOCKED := "special_locked"
const DOMESTIC_TECH_VIEW_RESEARCHING := "researching"
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
const WORLDMAP_SAVE_PATH := "user://worldmap_left_panel_state.json"
const TURN_PHASE_PLAYER := "player"
const TURN_PHASE_ENEMY := "enemy"
const ENEMY_TURN_MVP_DELAY := 0.75
const MANUAL_QA_NO_INVASION_GRACE_TURNS := 0
const ENEMY_INVASION_CHANCE := 0.20
const T03_PEACE_GRACE_TURNS := 3
const T03_GLOBAL_WAR_COOLDOWN_TURNS := 2
const T03_KOREA_CITY_IDS: Array[String] = ["hanseong", "pyeongyang", "gyeongju", "sabi"]
const T03_AI_BATTLE_VIDEO_PATH := "res://assets/ui/worldmap/videos/ai_faction_battle_theora_q8_1280x720.ogv"
const ENEMY_FACTION_TURN_REINFORCE_BASE := 60
const ENEMY_FACTION_TURN_REINFORCE_FRONTLINE_BONUS := 40
const ENEMY_FACTION_TURN_REINFORCE_CHANCELLOR_BONUS := 20
const ENEMY_FACTION_TURN_REINFORCE_MAX := 120
const ENEMY_STRATEGIC_DIPLOMACY_DRIFT := 3
const ENEMY_STRATEGIC_SPY_PRESSURE_WEIGHT := 2
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
const ALLIANCE_ACCEPTANCE_THRESHOLD := DiplomacyControllerScript.ALLIANCE_ACCEPTANCE_THRESHOLD
const MILITARY_SUPPORT_ACCEPTANCE_THRESHOLD := 80
const MILITARY_SUPPORT_REJECT_PENALTY := -20
const MILITARY_SUPPORT_REPEATED_REJECT_PENALTY := -40
const MILITARY_SUPPORT_REPEATED_REJECT_THRESHOLD := 3
const DIPLOMACY_ACTION_ENVOY := "envoy"
const DIPLOMACY_ACTION_TRIBUTE := "tribute"
const DIPLOMACY_ACTION_TRADE_AGREEMENT := "trade_agreement"
const DIPLOMACY_ACTION_RESTORE_RELATIONS := "restore_relations"
const DIPLOMACY_ACTION_ALLIANCE_PROPOSAL := "alliance_proposal"
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
const WORLDMAP_BATTLE_SCENE_PATH := "res://Battle_Land.tscn"
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

const RESOURCE_DISPLAY_ORDER := CityResourceServiceScript.RESOURCE_DISPLAY_ORDER
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
const PLAYER_ATTACK_SUPPLY_GOLD_RESOURCE_ID := "gold"
const PLAYER_ATTACK_SUPPLY_SALT_RESOURCE_ID := "salt"
const PLAYER_ATTACK_WOUNDED_QUEUE_TURNS := 3
const BATTLE_RESULT_HERO_ID_COMPATIBILITY := {
	"yi_sunsin": "yi_sun_sin",
	"jeong_dojeon": "jeong_do_jeon",
	"gim_yusin": "kim_yu_sin",
}

const GOVERNOR_POLICY_DATA := CityAdministrationServiceScript.GOVERNOR_POLICY_DATA

# v0.68b-12b-1 WorldMap Hero City Seed Data Import
# v0.68b-12b-2 WorldMap Left Panel Seed Binding QA
# v0.68b-12b-2 WorldMap Left Panel Web Parity Controls MVP
# v0.68b-12b-3 WorldMap Chancellor Policy + National Warehouse Web Parity MVP
# v0.68b-12b-3a WorldMap National Warehouse Card UI Cleanup
# v0.68b-12b-4 WorldMap Turn End + Save Management Web Parity MVP
# v0.68b-12b-5 WorldMap Enemy Turn Return / Turn Cycle MVP
# v0.68b-12b-6 WorldMap Turn Domestic Apply Web Parity MVP
# v0.68b-12b-7 WorldMap Domestic Apply Visual QA + Balance Check
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

var _camera_controller: WorldMapCameraController = null
var _hud_controller: WorldMapHudControllerScript = null
var _shared_ui_controller: WorldMapSharedUiControllerScript = null
var _world_calendar_service: WorldCalendarServiceScript = null
var _worldmap_battle_entry_handoff_in_progress: bool:
	get:
		return _ensure_camera_controller().is_battle_entry_handoff_in_progress()
var _chancellor_portrait_texture_rect: TextureRect = null
var selected_city_id: String = ""
var selected_city_marker: WorldMapCityMarker = null
var _city_markers_by_id: Dictionary = {}
var _contextual_worldmap_action_type := ""
var _contextual_worldmap_action_target_city_id := ""
var _contextual_worldmap_action_source_city_id := ""
var _contextual_worldmap_action_pending := false
var _diplomacy_action_coordinator: WorldMapActionCoordinator = null
var _diplomacy_controller: DiplomacyControllerScript = null
var _diplomacy_presenter: DiplomacyPresentationHelperScript = null
var _trade_controller: TradeControllerScript = null
var _trade_presenter: TradePresentationHelperScript = null
var _spy_controller: SpyControllerScript = null
var _spy_presenter: SpyPresentationHelperScript = null
var _military_controller: MilitaryControllerScript = null
var _enemy_warfare_service: EnemyWarfareServiceScript = null
var _battle_context_service: BattleContextServiceScript = null
var _battle_result_service: BattleResultServiceScript = null
var _battle_settlement_applier: BattleSettlementApplierScript = null
var _t03_transaction_service: StrategicBattleTransactionServiceScript = null
var _wounded_recovery_service: WoundedRecoveryServiceScript = null
var _player_attack_deployment_service: PlayerAttackDeploymentServiceScript = null
var _troop_rebalance_service: TroopRebalanceServiceScript = null
var _domestic_tech_catalog: DomesticTechCatalogScript = null
var _domestic_tech_research_rules: DomesticTechResearchRulesScript = null
var _domestic_tech_research_service: DomesticTechResearchServiceScript = null
var _domestic_tech_effect_provider: DomesticTechEffectProviderScript = null
var _domestic_tech_tree_presentation_controller: DomesticTechTreePresentationControllerScript = null
var _domestic_tech_completion_presentation_controller: DomesticTechCompletionPresentationControllerScript = null
var _city_administration_service: CityAdministrationServiceScript = null
var _city_resource_service: CityResourceServiceScript = null
var _city_detail_presentation_controller: CityDetailPresentationControllerScript = null
var _t03_battle_presentation: T03BattlePresentationControllerScript = null
var _pending_diplomacy_action_id := ""
var _pending_spy_action_id := ""
var _pending_trade_action_id := ""
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
var _pending_invasion_choice_card: PanelContainer
var _pending_invasion_title_label: Label
var _pending_invasion_detail_label: Label
var _pending_invasion_instruction_label: Label
var _manual_defense_button: Button
var _auto_defense_button: Button
var _post_battle_result_card: PanelContainer
var _wounded_normal_treatment_button: Button
var _wounded_fast_treatment_button: Button
var _wounded_treatment_hint_label: Label
var _post_battle_result_title_label: Label
var _post_battle_result_detail_label: Label
var _last_invasion_result_summary: Dictionary = {}
var _save_management_title_label: Label
var _save_management_status_label: Label
var _save_management_status := ""
var _player_attack_deployment_panel: Node = null
var _left_national_loyalty_help_button: Button = null
var _domestic_tech_tree_button_mvp: Button = null
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
	"last_wounded_recovery_month_serial": -1,
	"turn_phase": TURN_PHASE_PLAYER,
	"turn_label": "제 1턴",
	"year_label": "154년 봄 1일",
	"current_phase_label": "아군 턴",
	"pending_invasion_event": {},
	"pending_battle_context": {},
	"applied_battle_result_ids": [],
	"korea_unification_victory": false,
	"korea_player_defeat": false,
	"turn_resolution_state": {},
	"completed_turn_resolution_ids": [],
	"last_turn_resolution_result": {},
	"last_ai_domestic_apply_turn": 0,
	"last_ai_domestic_apply_result": {},
	"game_outcome": {},
	"enemy_invasion_roll_turn": 0,
	"t03_global_war_cooldown_until_turn": 0,
	"t03_automatic_battle_reports": [],
	"t03_acknowledged_report_ids": [],
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
	"national_tech_research": {"active": {}},
}
var _city_policy_state: Dictionary = {}
var _selected_city_detail_tab := CITY_DETAIL_TAB_RESOURCES
@onready var _t03_battle_presentation_root: Control = $WorldMapUI/T03BattlePresentation
@onready var _t03_battle_video_player: VideoStreamPlayer = $WorldMapUI/T03BattlePresentation/Frame/VideoPlayer
@onready var _t03_battle_video_labels: Label = $WorldMapUI/T03BattlePresentation/Frame/VideoLabels
@onready var _t03_battle_skip_button: Button = $WorldMapUI/T03BattlePresentation/Frame/SkipButton
@onready var _t03_battle_result_card: PanelContainer = $WorldMapUI/T03BattlePresentation/Frame/ResultCard
@onready var _t03_battle_result_title: Label = $WorldMapUI/T03BattlePresentation/Frame/ResultCard/Margin/Content/Title
@onready var _t03_battle_result_body: Label = $WorldMapUI/T03BattlePresentation/Frame/ResultCard/Margin/Content/Body
@onready var _t03_battle_result_confirm_button: Button = $WorldMapUI/T03BattlePresentation/Frame/ResultCard/Margin/Content/ConfirmButton
@onready var _t05_outcome_presentation_root: Control = $WorldMapUI/T05OutcomePresentation
@onready var _t05_outcome_title: Label = $WorldMapUI/T05OutcomePresentation/Card/Margin/Content/Title
@onready var _t05_outcome_body: Label = $WorldMapUI/T05OutcomePresentation/Card/Margin/Content/Body
@onready var _t05_outcome_save_button: Button = $WorldMapUI/T05OutcomePresentation/Card/Margin/Content/ButtonRow/SaveButton
@onready var _t05_outcome_new_game_button: Button = $WorldMapUI/T05OutcomePresentation/Card/Margin/Content/ButtonRow/NewGameButton
func _ready() -> void:
	_default_player_state = _player_state.duplicate(true)
	var new_game_faction_id: String = str(_get_game_session().consume_new_game_faction_id())
	if not new_game_faction_id.is_empty():
		_initialize_korea_mvp_new_game(new_game_faction_id)
	elif _get_game_session().consume_load_request():
		_load_worldmap_state()
	_ensure_worldmap_runtime_state_defaults()
	_restore_trade_persistence_from_player_state()
	_hide_retired_top_worldmap_hud()
	_ensure_camera_controller()
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
	_ensure_domestic_tech_completion_presentation_overlay()
	_setup_t03_battle_presentation()
	_setup_t05_outcome_presentation()
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
	if not new_game_faction_id.is_empty():
		_select_korea_mvp_start_city()
	call_deferred("_resume_t04_t05_presentation_after_ready")


func _get_current_player_faction_id() -> String:
	var faction_id := str(_player_state.get("player_faction_id", ""))
	if faction_id.is_empty():
		faction_id = _get_game_session().player_faction_id
	return faction_id if not faction_id.is_empty() else "player"


func _get_game_session() -> Node:
	return get_node_or_null("/root/GameSession")


func _play_worldmap_sfx(sfx_id: String) -> void:
	var game_audio := get_node_or_null("/root/GameAudio")
	if game_audio != null:
		game_audio.call("play_sfx", sfx_id)


func _initialize_korea_mvp_new_game(faction_id: String) -> void:
	if not _get_game_session().configure_korea_mvp(faction_id):
		push_error("[KoreaMVP] Invalid start faction: %s" % faction_id)
		return
	_player_state = _get_default_player_state()
	var start_data: Dictionary = _get_game_session().STARTS.get(faction_id, {})
	var start_city_id := str(start_data.get("city_id", ""))
	_player_state["active_scenario_id"] = _get_game_session().KOREA_MVP_SCENARIO_ID
	_player_state["player_faction_id"] = faction_id
	_player_state["ai_faction_ids"] = _get_game_session().ai_faction_ids.duplicate()
	_player_state["ruler_current_city_id"] = start_city_id
	_player_state["selected_city_id"] = start_city_id
	_player_state["origin_city_id"] = start_city_id
	_player_state["capital_city_id"] = start_city_id
	_player_state["owned_city_ids"] = [start_city_id]
	_player_state["turn_number"] = 1
	_player_state["turn_phase"] = TURN_PHASE_PLAYER
	_player_state["current_phase_label"] = _get_turn_phase_label(TURN_PHASE_PLAYER)
	_city_runtime_states.clear()
	_hero_runtime_states.clear()
	for city_id_variant in _get_game_session().STARTS.values():
		var city_id := str((city_id_variant as Dictionary).get("city_id", ""))
		var city_state: Dictionary = (CITY_HUD_DATA.get(city_id, {}) as Dictionary).duplicate(true)
		if city_state.is_empty():
			push_error("[KoreaMVP] Missing city registry entry: %s" % city_id)
			continue
		var owner_faction_id := ""
		for candidate_id_variant in _get_game_session().STARTS.keys():
			var candidate_id := str(candidate_id_variant)
			if str((_get_game_session().STARTS[candidate_id] as Dictionary).get("city_id", "")) == city_id:
				owner_faction_id = candidate_id
				break
		city_state["owner"] = owner_faction_id
		city_state["nation"] = owner_faction_id
		city_state["owner_faction_id"] = owner_faction_id
		city_state["faction"] = owner_faction_id
		_city_runtime_states[city_id] = city_state
		for hero_id_variant in _get_stationed_hero_ids_for_city(city_state):
			var hero_id := str(hero_id_variant)
			_hero_runtime_states[hero_id] = {
				"current_city_id": city_id,
				"city_id": city_id,
				"location_city_id": city_id,
				"side": owner_faction_id,
				"nation": owner_faction_id,
				"faction_id": owner_faction_id,
			}
	var player_city: Dictionary = _city_runtime_states.get(start_city_id, {})
	_player_state["owned_hero_ids"] = _get_stationed_hero_ids_for_city(player_city)
	_ensure_worldmap_runtime_state_defaults()
	# Seed persistent city stock before the first national-panel render.  The
	# seeder only fills missing keys and never overwrites a saved/runtime value.
	for city_id_variant in _city_runtime_states.keys():
		_ensure_city_supply_resource_defaults(str(city_id_variant))
	_rebuild_occupation_runtime_indexes_mvp()


func _select_korea_mvp_start_city() -> void:
	var city_id := str(_player_state.get("selected_city_id", ""))
	var marker := _city_markers_by_id.get(city_id) as WorldMapCityMarker
	if marker != null:
		_on_city_marker_selected(marker)


func _process(delta: float) -> void:
	_ensure_camera_controller().process_camera(delta)


func _input(event: InputEvent) -> void:
	if _ensure_camera_controller().is_battle_entry_handoff_in_progress():
		# A skip event can complete the handoff synchronously and replace this scene.
		# Consume it while this WorldMap viewport is still alive, before that transition.
		var handoff_viewport := get_viewport()
		if handoff_viewport != null:
			handoff_viewport.set_input_as_handled()
		if _is_worldmap_battle_entry_handoff_skip_event(event):
			_skip_worldmap_battle_entry_camera_handoff()
		return

	if _ensure_shared_ui_controller().is_help_modal_visible() and event.is_action_pressed("ui_cancel"):
		_hide_worldmap_help_modal()
		get_viewport().set_input_as_handled()
		return

	if _is_domestic_tech_completion_card_visible():
		if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel") or _is_domestic_tech_completion_space_confirm_event(event):
			_on_domestic_tech_completion_confirm_pressed()
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

	if _ensure_shared_ui_controller().handle_input(event):
		get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if _ensure_camera_controller().is_battle_entry_handoff_in_progress():
		# Keep the same ordering as _input(): skip may synchronously change scenes.
		var handoff_viewport := get_viewport()
		if handoff_viewport != null:
			handoff_viewport.set_input_as_handled()
		if _is_worldmap_battle_entry_handoff_skip_event(event):
			_skip_worldmap_battle_entry_camera_handoff()
		return

	if _is_domestic_tech_tree_overlay_open_mvp():
		if event.is_action_pressed("ui_cancel"):
			_close_domestic_tech_tree_overlay_mvp()
		get_viewport().set_input_as_handled()
		return

	if _ensure_camera_controller().handle_unhandled_input(event):
		get_viewport().set_input_as_handled()


func _hide_retired_top_worldmap_hud() -> void:
	var retired_title_label := get_node_or_null("WorldMapUI/TitleLabel") as Control
	if retired_title_label != null:
		retired_title_label.visible = false
	world_title_panel.visible = false
	right_hud_dragbar.visible = false


func _setup_independent_hud_panel_drag() -> void:
	var shared_ui := _ensure_shared_ui_controller()
	shared_ui.register_draggable_panel(city_detail_panel, [city_detail_header_row, city_detail_eyebrow_label, city_detail_heading_label])
	shared_ui.register_draggable_panel(city_info_panel_control, [city_info_eyebrow_label, city_info_city_name_label])
	shared_ui.register_draggable_panel(left_world_status_panel, [left_world_status_eyebrow_label, calendar_label])
	if not shared_ui.draggable_panel_clicked.is_connected(_on_shared_ui_draggable_panel_clicked):
		shared_ui.draggable_panel_clicked.connect(_on_shared_ui_draggable_panel_clicked)


func _lock_worldmap_fixed_panel_top_margin() -> void:
	_lock_left_world_status_panel_anchor()
	_lock_screen_panel_top_margin(diplomacy_spy_panel)
	_lock_screen_panel_top_margin(city_detail_panel)
	_lock_selected_city_info_panel_anchor()


func _lock_screen_panel_top_margin(panel: Control) -> void:
	_ensure_shared_ui_controller().lock_screen_panel_top_margin(panel, WORLD_UI_TOP_MARGIN)


func _lock_selected_city_info_panel_anchor() -> void:
	_ensure_shared_ui_controller().lock_right_panel_anchor(city_info_panel_control, SELECTED_CITY_INFO_PANEL_SIZE, WORLD_UI_LEFT_MARGIN, WORLD_UI_TOP_MARGIN)


func _register_hud_panel_drag(panel: Control, handles: Array) -> void:
	_ensure_shared_ui_controller().register_draggable_panel(panel, handles)


func _on_hud_drag_handle_gui_input(event: InputEvent, panel: Control, handle: Control) -> void:
	_ensure_shared_ui_controller().call("_on_drag_handle_gui_input", event, panel, handle)


func _move_hud_panel_to_screen_position(panel: Control, next_global_position: Vector2) -> void:
	_ensure_shared_ui_controller().move_panel_to_screen_position(panel, next_global_position)


func _request_hud_panel_position_mvp(panel: Control, requested_position: Vector2, is_global: bool = false) -> bool:
	return _ensure_shared_ui_controller().request_panel_position(panel, requested_position, is_global)


func _on_shared_ui_draggable_panel_clicked(panel: Control) -> void:
	if panel == city_detail_panel and _is_unified_city_panel_collapsed:
		_set_unified_city_panel_collapsed(false)


func _ensure_camera_controller() -> WorldMapCameraController:
	if _camera_controller == null:
		_camera_controller = WorldMapCameraControllerScript.new()
		_camera_controller.name = "WorldMapCameraController"
		add_child(_camera_controller)
		_camera_controller.configure(
			world_map_camera,
			camera_debug_label,
			self,
			[tile_a1_top_left, tile_a2_top_right, tile_b1_bottom_left, tile_b2_bottom_right]
		)
	return _camera_controller


func _ensure_hud_controller() -> WorldMapHudControllerScript:
	if _hud_controller == null:
		_hud_controller = WorldMapHudControllerScript.new()
		_hud_controller.name = "WorldMapHudController"
		add_child(_hud_controller)
	_hud_controller.set_ui_nodes({
		"left_world_status_panel": left_world_status_panel,
		"city_info_panel": city_info_panel_control,
		"eyebrow": left_world_status_eyebrow_label,
		"turn": turn_label,
		"calendar": calendar_label,
		"nation": nation_label,
		"power": power_label,
		"power_bar": power_bar,
		"tax": tax_label,
		"tax_bar": tax_bar,
		"tax_slider": tax_slider,
		"security": security_label,
		"security_bar": security_bar,
		"chancellor": chancellor_label,
		"chancellor_portrait": chancellor_portrait_label,
		"chancellor_portrait_texture": _chancellor_portrait_texture_rect,
		"chancellor_name": chancellor_name_label,
		"chancellor_stats": chancellor_stats_label,
		"chancellor_assignment": chancellor_assignment_option,
		"chancellor_policy": chancellor_policy_option,
		"chancellor_policy_description": chancellor_policy_description_label,
		"resource": resource_label,
		"supply": supply_label,
		"military_logistics": military_logistics_label,
		"external_trade": external_trade_label,
		"world_status_hint": world_status_hint_label,
		"turn_end": wild_army_edit_button_placeholder,
		"save": save_button_placeholder,
		"load": load_button_placeholder,
		"reset": reset_button_placeholder,
		"save_management_title": _save_management_title_label,
		"save_management_status": _save_management_status_label,
		"resource_order": RESOURCE_DISPLAY_ORDER,
		"resource_labels": RESOURCE_LABELS,
	})
	return _hud_controller


func _ensure_shared_ui_controller() -> WorldMapSharedUiControllerScript:
	if _shared_ui_controller == null:
		_shared_ui_controller = WorldMapSharedUiControllerScript.new()
		_shared_ui_controller.name = "WorldMapSharedUiController"
		add_child(_shared_ui_controller)
		_shared_ui_controller.configure(self, get_node_or_null("WorldMapUI") as CanvasLayer)
	return _shared_ui_controller


func _ensure_world_calendar_service() -> WorldCalendarServiceScript:
	if _world_calendar_service == null:
		_world_calendar_service = WorldCalendarServiceScript.new()
	return _world_calendar_service


func _update_camera_debug_label() -> void:
	_ensure_camera_controller().update_debug_label()


func _apply_zoom(zoom_delta: float) -> void:
	_ensure_camera_controller().apply_zoom(zoom_delta)


func _clamp_camera_to_world() -> void:
	_ensure_camera_controller().clamp_to_world()


func _format_vector2(value: Vector2) -> String:
	return UIFormatterHelpers.format_vector2(value)


func _connect_city_markers() -> void:
	for child in city_layer.get_children():
		var city_marker := child as WorldMapCityMarker
		if city_marker == null:
			continue
		_city_markers_by_id[city_marker.city_id] = city_marker
		if not city_marker.city_selected.is_connected(_on_city_marker_selected):
			city_marker.city_selected.connect(_on_city_marker_selected)


func _on_city_marker_selected(city_marker: WorldMapCityMarker) -> void:
	_play_worldmap_sfx("city_select")
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
	if _is_domestic_tech_tree_overlay_open_mvp():
		_refresh_domestic_tech_tree_overlay_mvp()


func _ensure_city_administration_service() -> CityAdministrationServiceScript:
	if _city_administration_service == null:
		_city_administration_service = CityAdministrationServiceScript.new()
	return _city_administration_service


func _ensure_city_resource_service() -> CityResourceServiceScript:
	if _city_resource_service == null:
		_city_resource_service = CityResourceServiceScript.new()
		_city_resource_service.configure(
			Callable(self, "_query_city_resource_service"),
			Callable(self, "_mutate_city_resource_service")
		)
	return _city_resource_service


func _query_city_resource_service(query_id: String, args: Array) -> Variant:
	match query_id:
		"city_state":
			return _get_mutable_city_runtime_state(str(args[0])).duplicate(true)
		"ordered_player_city_ids":
			return _get_ordered_player_resource_city_ids_mvp()
		"city_production_income":
			return _calculate_player_city_production_income_mvp(
				str(args[0]), int(args[1]), int(args[2]), str(args[3]),
				args[4] as Dictionary, args[5] as Dictionary
			)
	return null


func _mutate_city_resource_service(mutation_id: String, args: Array) -> Variant:
	match mutation_id:
		"set_city_state":
			_city_runtime_states[str(args[0])] = (args[1] as Dictionary).duplicate(true)
			return true
		"set_player_resource_compatibility":
			_player_state["resource_stock"] = (args[0] as Dictionary).duplicate(true)
			return true
	return false


func _ensure_city_detail_presentation_controller() -> CityDetailPresentationControllerScript:
	if _city_detail_presentation_controller == null:
		_city_detail_presentation_controller = CityDetailPresentationControllerScript.new()
		_city_detail_presentation_controller.name = "CityDetailPresentationController"
		add_child(_city_detail_presentation_controller)
		_city_detail_presentation_controller.attack_requested.connect(_on_city_info_attack_requested)
		_city_detail_presentation_controller.governor_assignment_requested.connect(_on_city_info_governor_assignment_requested)
		_city_detail_presentation_controller.hero_transfer_confirmed.connect(_on_city_info_hero_transfer_confirmed)
		_city_detail_presentation_controller.recruitment_requested.connect(_on_city_info_recruitment_requested)
	_city_detail_presentation_controller.set_ui_nodes({
		"city_info_panel": city_info_panel,
		"resource_tab": city_detail_resource_tab_button_placeholder,
		"internal_trade_tab": city_detail_internal_trade_tab_button_placeholder,
		"external_trade_tab": city_detail_external_trade_tab_button_placeholder,
		"type": city_detail_type_label,
		"region_owner": city_detail_region_owner_label,
		"resource": city_detail_resource_label,
		"security": city_detail_security_label,
		"military": city_detail_military_label,
		"commerce": city_detail_commerce_label,
		"rating": city_detail_rating_label,
		"status": city_detail_status_label,
		"hint": city_detail_hint_label,
		"domestic_button": city_detail_domestic_button_placeholder,
		"resource_card": _city_resource_potential_card,
		"storage_card": _city_storage_card,
		"trade_card": _trade_control_card,
	})
	return _city_detail_presentation_controller


func _ensure_domestic_tech_catalog() -> DomesticTechCatalogScript:
	if _domestic_tech_catalog == null:
		_domestic_tech_catalog = DomesticTechCatalogScript.new()
	return _domestic_tech_catalog


func _ensure_domestic_tech_effect_provider() -> DomesticTechEffectProviderScript:
	if _domestic_tech_effect_provider == null:
		_domestic_tech_effect_provider = DomesticTechEffectProviderScript.new()
		_domestic_tech_effect_provider.configure(_ensure_domestic_tech_catalog())
	return _domestic_tech_effect_provider


func _ensure_domestic_tech_tree_presentation_controller() -> DomesticTechTreePresentationControllerScript:
	if _domestic_tech_tree_presentation_controller == null:
		_domestic_tech_tree_presentation_controller = DomesticTechTreePresentationControllerScript.new()
		_domestic_tech_tree_presentation_controller.name = "DomesticTechTreePresentationController"
		add_child(_domestic_tech_tree_presentation_controller)
		_domestic_tech_tree_presentation_controller.configure(self, {
			"selected_city_id": Callable(self, "_get_selected_city_id_for_domestic_tech_presentation"),
			"has_selected_city": Callable(self, "_has_selected_city_for_domestic_tech_presentation"),
			"can_start": Callable(self, "_can_start_domestic_tech_research_mvp"),
			"format_city_name": Callable(self, "_format_city_name_by_id"),
			"format_active_research": Callable(self, "_format_domestic_tech_active_research_summary_mvp"),
			"format_city_economy": Callable(self, "_format_domestic_tech_city_economy_bonus_lines_mvp"),
			"format_city_military": Callable(self, "_format_domestic_tech_city_military_defense_bonus_lines_mvp"),
			"format_city_naval": Callable(self, "_format_domestic_tech_city_naval_siege_bonus_lines_mvp"),
			"format_city_spy": Callable(self, "_format_domestic_tech_city_spy_intel_bonus_lines_mvp"),
			"format_diplomacy_spy": Callable(self, "_format_domestic_tech_diplomacy_spy_bonus_lines_mvp"),
			"format_national_policy": Callable(self, "_format_domestic_tech_national_policy_bonus_lines_mvp"),
			"city_hud_entry": Callable(self, "_get_city_hud_entry"),
			"city_definitions": Callable(self, "_get_domestic_city_tech_definitions_mvp"),
			"national_definitions": Callable(self, "_get_domestic_national_tech_definitions_mvp"),
			"categories": Callable(self, "_get_domestic_tech_categories_mvp"),
			"definition": Callable(self, "_get_domestic_tech_definition_mvp"),
			"research_cost_plan": Callable(self, "_get_domestic_tech_research_cost_plan_mvp"),
			"view_state": Callable(self, "_get_domestic_tech_view_state_mvp"),
			"city_coastal": Callable(self, "_is_city_coastal_for_city_tech"),
			"city_completed": Callable(self, "_is_city_domestic_tech_completed_mvp"),
			"city_owned": Callable(self, "_is_city_owned_by_player_mvp"),
			"is_city_tech": Callable(self, "_is_domestic_city_tech_mvp"),
			"is_national_tech": Callable(self, "_is_domestic_national_tech_mvp"),
			"researching": Callable(self, "_is_domestic_tech_researching_mvp"),
			"national_completed": Callable(self, "_is_national_domestic_tech_completed_mvp"),
		}, _ensure_domestic_tech_effect_provider())
		_domestic_tech_tree_presentation_controller.research_requested.connect(_on_domestic_tech_presentation_research_requested)
		_domestic_tech_tree_presentation_controller.closed.connect(_on_domestic_tech_tree_presentation_closed)
	return _domestic_tech_tree_presentation_controller


func _ensure_domestic_tech_completion_presentation_controller() -> DomesticTechCompletionPresentationControllerScript:
	if _domestic_tech_completion_presentation_controller == null:
		_domestic_tech_completion_presentation_controller = DomesticTechCompletionPresentationControllerScript.new()
		_domestic_tech_completion_presentation_controller.name = "DomesticTechCompletionPresentationController"
		add_child(_domestic_tech_completion_presentation_controller)
		_domestic_tech_completion_presentation_controller.configure(self, {
			"categories": Callable(self, "_get_domestic_tech_categories_mvp"),
			"definition": Callable(self, "_get_domestic_tech_definition_mvp"),
			"resolved_icon_path": Callable(self, "_get_domestic_tech_resolved_icon_path_mvp"),
			"format_city_name": Callable(self, "_format_city_name_by_id"),
			"city_owned": Callable(self, "_is_city_owned_by_player_mvp"),
			"format_percent": Callable(self, "_format_domestic_tech_percent_bonus_mvp"),
			"format_signed_int": Callable(self, "_format_signed_int"),
			"play_sfx": Callable(self, "_play_worldmap_sfx"),
		}, _ensure_domestic_tech_effect_provider())
	return _domestic_tech_completion_presentation_controller


func _get_selected_city_id_for_domestic_tech_presentation() -> String:
	return selected_city_id


func _has_selected_city_for_domestic_tech_presentation() -> bool:
	return selected_city_marker != null


func _on_domestic_tech_presentation_research_requested(tech_id: String, city_id: String) -> void:
	_start_domestic_tech_research_mvp(tech_id, city_id)


func _on_domestic_tech_tree_presentation_closed() -> void:
	_restore_worldmap_panels_after_tech_tree_mvp()


func _ensure_domestic_tech_research_rules() -> DomesticTechResearchRulesScript:
	if _domestic_tech_research_rules == null:
		_domestic_tech_research_rules = DomesticTechResearchRulesScript.new()
	return _domestic_tech_research_rules


func _ensure_domestic_tech_research_service() -> DomesticTechResearchServiceScript:
	if _domestic_tech_research_service == null:
		_domestic_tech_research_service = DomesticTechResearchServiceScript.new()
		_domestic_tech_research_service.configure(
			_ensure_domestic_tech_catalog(),
			_ensure_domestic_tech_research_rules(),
			Callable(self, "_query_domestic_tech_research_service"),
			Callable(self, "_mutate_domestic_tech_research_service")
		)
	return _domestic_tech_research_service


func _query_domestic_tech_research_service(query_id: String, args: Array) -> Variant:
	match query_id:
		"player_value":
			return _player_state.get(str(args[0]), args[1] if args.size() > 1 else null)
		"city_state":
			return _get_city_hud_entry(str(args[0])).duplicate(true)
		"city_ids":
			return _city_runtime_states.keys()
		"city_exists":
			return not _get_city_hud_entry(str(args[0])).is_empty()
		"is_city_owned":
			return _is_city_owned_by_player_mvp(str(args[0]))
		"current_turn":
			return maxi(1, int(_player_state.get("turn_number", 1)))
		"city_storage":
			var city_id := str(args[0])
			return _get_city_storage(city_id, _get_city_hud_entry(city_id)).duplicate(true)
		"is_city_coastal":
			return _is_city_coastal_for_city_tech(str(args[0]))
	return null


func _mutate_domestic_tech_research_service(mutation_id: String, args: Array) -> Variant:
	match mutation_id:
		"set_player_value":
			_player_state[str(args[0])] = (args[1] as Dictionary).duplicate(true) if args[1] is Dictionary else args[1]
			return true
		"set_city_state":
			_city_runtime_states[str(args[0])] = (args[1] as Dictionary).duplicate(true)
			return true
		"set_city_storage":
			_set_city_storage(str(args[0]), (args[1] as Dictionary).duplicate(true))
			return true
	return false


func _ensure_diplomacy_controller() -> DiplomacyControllerScript:
	if _diplomacy_controller == null:
		_diplomacy_controller = DiplomacyControllerScript.new()
		_diplomacy_controller.configure(self)
	return _diplomacy_controller


func _ensure_diplomacy_presenter() -> DiplomacyPresentationHelperScript:
	if _diplomacy_presenter == null:
		_diplomacy_presenter = DiplomacyPresentationHelperScript.new()
		_diplomacy_presenter.configure(self, _ensure_diplomacy_controller())
	return _diplomacy_presenter


func _ensure_trade_controller() -> TradeControllerScript:
	if _trade_controller == null:
		_trade_controller = TradeControllerScript.new()
		_trade_controller.configure(self)
	return _trade_controller


func _ensure_trade_presenter() -> TradePresentationHelperScript:
	if _trade_presenter == null:
		_trade_presenter = TradePresentationHelperScript.new()
		_trade_presenter.configure(self, _ensure_trade_controller())
	return _trade_presenter


func _ensure_spy_controller() -> SpyControllerScript:
	if _spy_controller == null:
		_spy_controller = SpyControllerScript.new()
		_spy_controller.configure(self)
	return _spy_controller


func _ensure_spy_presenter() -> SpyPresentationHelperScript:
	if _spy_presenter == null:
		_spy_presenter = SpyPresentationHelperScript.new()
		_spy_presenter.configure(self, _ensure_spy_controller())
	return _spy_presenter


func _ensure_military_controller() -> MilitaryControllerScript:
	if _military_controller == null:
		_military_controller = MilitaryControllerScript.new()
		_military_controller.configure(self)
	return _military_controller


func _ensure_player_attack_deployment_service() -> PlayerAttackDeploymentServiceScript:
	if _player_attack_deployment_service == null:
		_player_attack_deployment_service = PlayerAttackDeploymentServiceScript.new()
		_player_attack_deployment_service.configure(
			Callable(self, "_player_attack_deployment_query"),
			Callable(self, "_player_attack_deployment_mutation"),
			{
				"minimum_source_garrison": PLAYER_ATTACK_MIN_SOURCE_CITY_TROOPS,
				"gold_resource_id": PLAYER_ATTACK_SUPPLY_GOLD_RESOURCE_ID,
				"salt_resource_id": PLAYER_ATTACK_SUPPLY_SALT_RESOURCE_ID,
				"default_command_rank": COMMAND_RANK_OFFICER,
				"default_command_label": str(COMMAND_RANK_LABELS.get(COMMAND_RANK_OFFICER, "군관")),
			}
		)
	return _player_attack_deployment_service


func _ensure_troop_rebalance_service() -> TroopRebalanceServiceScript:
	if _troop_rebalance_service == null:
		_troop_rebalance_service = TroopRebalanceServiceScript.new()
		_troop_rebalance_service.configure(
			Callable(self, "_troop_rebalance_query"),
			Callable(self, "_troop_rebalance_mutation"),
			{"role_target_garrison_ratio": ROLE_TARGET_GARRISON_RATIO}
		)
	return _troop_rebalance_service


func _player_attack_deployment_query(query_id: String, args: Array) -> Variant:
	match query_id:
		"has_city": return _has_city_for_battle_context(str(args[0]))
		"city_owned_by_player": return _is_city_owned_by_player_mvp(str(args[0]))
		"city_troops": return _get_city_troops_for_battle_context(str(args[0]))
		"city_resource_amount": return _get_city_supply_resource_amount(str(args[0]), str(args[1]))
		"city_resource_stock":
			var city_id := str(args[0])
			_ensure_city_supply_resource_defaults(city_id)
			return (_get_city_hud_entry(city_id).get("resource_stock", {}) as Dictionary).duplicate(true)
		"city_stationed_hero_ids": return _get_city_stationed_hero_ids_for_battle_context(str(args[0]))
		"has_hero": return not _get_hero_seed_entry(str(args[0])).is_empty()
		"hero_data": return _get_hero_entry(str(args[0])).duplicate(true)
		"hero_state": return _normalize_hero_runtime_state(str(args[0]), _get_existing_hero_runtime_state(str(args[0])))
		"hero_excluded": return _is_hero_captured_for_battle(str(args[0]))
		"hero_state_badge": return _get_hero_state_badge_text(str(args[0]))
		"hero_command_summary": return _get_hero_command_summary_for_city_mvp(_get_hero_entry(str(args[0])), str(args[1]))
		"attack_block_reason": return _get_player_attack_block_reason(str(args[0]))
		"expected_attack_source": return _find_player_attack_source_city(str(args[0]))
		"naval_siege_unlock_block_reason": return _get_player_naval_siege_attack_unlock_block_reason_mvp(str(args[0]), str(args[1]))
		"naval_route_required": return _is_naval_attack_route_mvp(str(args[0]), str(args[1]))
		"siege_target": return _is_siege_attack_target_mvp(str(args[0]))
		"naval_unlock": return _get_player_naval_unlock_modifier_mvp(str(args[0])).duplicate(true)
		"siege_unlock": return _get_player_siege_unlock_modifier_mvp(str(args[0])).duplicate(true)
	return null


func _player_attack_deployment_mutation(mutation_id: String, args: Array) -> Variant:
	match mutation_id:
		"set_city_troops":
			_set_city_runtime_troops(str(args[0]), maxi(0, int(args[1])))
			return true
		"set_city_resource_stock":
			var city_id := str(args[0])
			var city_data := _get_mutable_city_runtime_state(city_id)
			if city_data.is_empty() or not args[1] is Dictionary:
				return false
			city_data["resource_stock"] = (args[1] as Dictionary).duplicate(true)
			_city_runtime_states[city_id] = city_data
			return true
		"set_city_stationed_hero_ids":
			_set_city_runtime_stationed_hero_ids(str(args[0]), args[1] as Array)
			return true
		"set_hero_state":
			_hero_runtime_states[str(args[0])] = (args[1] as Dictionary).duplicate(true)
			return true
		"restore_hero_to_city":
			_move_hero_to_city_t02(str(args[0]), str(args[1]))
			return true
	return null


func _troop_rebalance_query(query_id: String, args: Array) -> Variant:
	match query_id:
		"supply_states": return _calculate_all_city_supply_states()
		"owned_city_ids": return (_player_state.get("owned_city_ids", []) as Array).duplicate()
		"has_city": return not _get_city_hud_entry(str(args[0])).is_empty()
		"city_population": return maxi(0, int(_get_city_hud_entry(str(args[0])).get("population", 0)))
		"city_troops": return _get_city_troops_for_battle_context(str(args[0]))
		"can_move_troops": return _can_move_troops(str(args[0]), str(args[1]), int(args[2]))
	return null


func _troop_rebalance_mutation(mutation_id: String, args: Array) -> Variant:
	match mutation_id:
		"move_troops": return _move_troops(str(args[0]), str(args[1]), int(args[2]))
	return null


func _ensure_enemy_warfare_service() -> EnemyWarfareServiceScript:
	if _enemy_warfare_service == null:
		_enemy_warfare_service = EnemyWarfareServiceScript.new()
		_enemy_warfare_service.configure(
			Callable(self, "_enemy_warfare_query"),
			ENEMY_FACTION_PERSONALITY_SEEDS,
			ENEMY_FACTION_STRATEGIC_GOAL_SEEDS,
			{
				"korea_city_ids": T03_KOREA_CITY_IDS,
				"minimum_attacker_troops": ENEMY_INVASION_MIN_ATTACKER_CITY_TROOPS,
				"minimum_source_troops": PLAYER_ATTACK_MIN_SOURCE_CITY_TROOPS,
				"maximum_city_troops": INVASION_MAX_REASONABLE_CITY_TROOPS,
			}
		)
	return _enemy_warfare_service


func _ensure_battle_context_service() -> BattleContextServiceScript:
	if _battle_context_service == null:
		_battle_context_service = BattleContextServiceScript.new()
		_battle_context_service.configure(
			Callable(self, "_battle_context_query"),
			{
				"minimum_invasion_troops": ENEMY_INVASION_MIN_ATTACKER_CITY_TROOPS,
				"max_heroes_per_side": INVASION_BATTLE_MAX_HEROES_PER_SIDE,
				"reinforcement_max_hops": INVASION_REINFORCEMENT_MAX_HOPS,
				"reinforcement_ally_factions": INVASION_REINFORCEMENT_ALLY_FACTIONS,
				"player_attack_context_source": PLAYER_ATTACK_CONTEXT_SOURCE,
				"command_rank_labels": COMMAND_RANK_LABELS,
				"command_rank_limits": COMMAND_RANK_LIMITS,
				"hero_role_contracts": HERO_BATTLE_ROLE_CONTRACTS,
				"hero_default_role_contract": HERO_BATTLE_DEFAULT_ROLE_CONTRACT,
				"hero_portrait_nation_by_faction": HERO_PORTRAIT_NATION_BY_FACTION,
				"hero_toast_icon_fallback": HERO_BATTLE_TOAST_ICON_FALLBACK,
			}
		)
	return _battle_context_service


func _ensure_battle_result_service() -> BattleResultServiceScript:
	if _battle_result_service == null:
		_battle_result_service = BattleResultServiceScript.new()
		_battle_result_service.configure(
			Callable(self, "_battle_result_query"),
			{
				"player_attack_context_source": PLAYER_ATTACK_CONTEXT_SOURCE,
				"hero_id_compatibility": BATTLE_RESULT_HERO_ID_COMPATIBILITY,
				"minimum_city_troops": INVASION_MIN_CITY_TROOPS,
				"minimum_occupation_troops": INVASION_MIN_OCCUPATION_TROOPS,
				"maximum_city_troops": INVASION_MAX_REASONABLE_CITY_TROOPS,
				"defender_win_defender_loss_rate": INVASION_DEFENDER_WIN_DEFENDER_LOSS_RATE,
				"defender_win_attacker_loss_rate": INVASION_DEFENDER_WIN_ATTACKER_LOSS_RATE,
				"attacker_win_defender_loss_rate": INVASION_ATTACKER_WIN_DEFENDER_LOSS_RATE,
				"attacker_win_attacker_loss_rate": INVASION_ATTACKER_WIN_ATTACKER_LOSS_RATE,
			}
		)
	return _battle_result_service


func _ensure_battle_settlement_applier() -> BattleSettlementApplierScript:
	if _battle_settlement_applier == null:
		_battle_settlement_applier = BattleSettlementApplierScript.new()
		_battle_settlement_applier.configure(
			Callable(self, "_battle_settlement_query"),
			Callable(self, "_battle_settlement_mutation"),
			{
				"legacy_wounded_turns": PLAYER_ATTACK_WOUNDED_QUEUE_TURNS,
				"normal_wounded_turns": ExpeditionSupplyCalculator.NORMAL_WOUNDED_RECOVERY_MONTHS,
				"default_wounded_recovery_turns": DEFAULT_WOUNDED_RECOVERY_TURNS,
			}
		)
	return _battle_settlement_applier


func _ensure_t03_transaction_service() -> StrategicBattleTransactionServiceScript:
	if _t03_transaction_service == null:
		_t03_transaction_service = StrategicBattleTransactionServiceScript.new()
		_t03_transaction_service.configure(
			Callable(self, "_t03_transaction_query"),
			Callable(self, "_t03_transaction_mutation"),
			Callable(T03AutoBattleResolverScript, "resolve"),
			{
				"minimum_source_troops": PLAYER_ATTACK_MIN_SOURCE_CITY_TROOPS,
				"normal_wounded_turns": ExpeditionSupplyCalculator.NORMAL_WOUNDED_RECOVERY_MONTHS,
			}
		)
	return _t03_transaction_service


func _t03_transaction_query(query_id: String, args: Array) -> Variant:
	match query_id:
		"turn_number": return maxi(1, int(_player_state.get("turn_number", 1)))
		"scenario_id": return str(_player_state.get("active_scenario_id", "korea_mvp_four_cities"))
		"invasion_pair_eligible": return _is_enemy_invasion_pair_eligible_mvp(str(args[0]), str(args[1]))
		"has_city": return _has_city_for_battle_context(str(args[0]))
		"city_troops": return _get_city_troops_for_battle_context(str(args[0]))
		"city_owner": return _get_city_owner_id_for_battle_context(str(args[0]))
		"player_faction": return _get_current_player_faction_id()
		"city_owned_by_player": return _is_city_owned_by_player_mvp(str(args[0]))
		"build_troop_allocation": return _build_command_limit_troop_allocation_for_heroes(_normalize_hero_id_array(args[0]), maxi(0, int(args[1])), str(args[2]))
		"city_resource_amount": return _get_city_supply_resource_amount(str(args[0]), str(args[1]))
		"city_resource_stock":
			_ensure_city_supply_resource_defaults(str(args[0]))
			return (_get_city_hud_entry(str(args[0])).get("resource_stock", {}) as Dictionary).duplicate(true)
		"city_defense": return float(_get_city_hud_entry(str(args[0])).get("defense", 0))
		"player_defense_bonus": return float(_get_player_battle_tech_modifier_mvp("combined", str(args[0])).get("global_defense_pct", 0.0))
		"serialize_state": return _serialize_worldmap_state()
		"result_applied":
			var applied_result_ids: Variant = _player_state.get("applied_battle_result_ids", [])
			return applied_result_ids is Array and (applied_result_ids as Array).has(str(args[0]))
		"pending_invasion_transaction_id": return str(_get_pending_invasion_event_mvp().get("transaction_id", ""))
	return null


func _t03_transaction_mutation(mutation_id: String, args: Array) -> Variant:
	match mutation_id:
		"set_resource_stock":
			var city_id := str(args[0])
			var city_data := _get_mutable_city_runtime_state(city_id)
			if city_data.is_empty() or not args[1] is Dictionary:
				return false
			city_data["resource_stock"] = (args[1] as Dictionary).duplicate(true)
			_city_runtime_states[city_id] = city_data
			return true
		"set_city_troops":
			_set_city_runtime_troops(str(args[0]), maxi(0, int(args[1])))
			return true
		"set_city_owner":
			_set_city_runtime_owner(str(args[0]), str(args[1]))
			return true
		"move_pending_generals":
			_move_generals_for_pending_expedition(str(args[0]), _normalize_hero_id_array(args[1]))
			return true
		"move_hero":
			_move_hero_to_city_t02(str(args[0]), str(args[1]))
			return true
		"add_wounded":
			_add_wounded_to_city_mvp(str(args[0]), maxi(0, int(args[1])), maxi(1, int(args[2])), str(args[3]), str(args[4]))
			return true
		"clear_wounded":
			_clear_city_wounded_queue_mvp(str(args[0]))
			return true
		"settle_defender_generals":
			return _settle_defender_generals_after_occupation(
				str(args[0]), str(args[1]), str(args[2]),
				_normalize_battle_result_hero_ids(args[3]), _normalize_battle_result_hero_ids(args[4]),
				str(args[5]), str(args[6])
			)
		"set_pending_invasion_event":
			_player_state["pending_invasion_event"] = (args[0] as Dictionary).duplicate(true)
			return true
		"set_pending_battle_context":
			_set_pending_battle_context_mvp(args[0] as Dictionary)
			return true
		"mark_result_applied":
			var applied_ids: Array = _player_state.get("applied_battle_result_ids", []) if _player_state.get("applied_battle_result_ids", []) is Array else []
			if not applied_ids.has(str(args[0])):
				applied_ids.append(str(args[0]))
			_player_state["applied_battle_result_ids"] = applied_ids
			return true
		"clear_transaction_state":
			_player_state["pending_battle_context"] = {}
			_player_state["pending_invasion_event"] = {}
			return true
		"apply_state": return _apply_worldmap_state(args[0] as Dictionary)
	return null


func _ensure_wounded_recovery_service() -> WoundedRecoveryServiceScript:
	if _wounded_recovery_service == null:
		_wounded_recovery_service = WoundedRecoveryServiceScript.new()
		_wounded_recovery_service.configure(
			Callable(self, "_wounded_recovery_query"),
			Callable(self, "_wounded_recovery_mutation"),
			{
				"normal_status": HERO_RUNTIME_STATUS_NORMAL,
				"wounded_status": HERO_RUNTIME_STATUS_WOUNDED,
				"captured_status": HERO_RUNTIME_STATUS_CAPTURED,
				"dead_status": HERO_RUNTIME_STATUS_DEAD,
				"allowed_statuses": [HERO_RUNTIME_STATUS_NORMAL, HERO_RUNTIME_STATUS_WOUNDED, HERO_RUNTIME_STATUS_CAPTURED, HERO_RUNTIME_STATUS_DEAD],
				"normal_recovery_months": DEFAULT_WOUNDED_RECOVERY_TURNS,
				"fast_recovery_months": ExpeditionSupplyCalculator.FAST_WOUNDED_RECOVERY_MONTHS,
				"world_calendar_year_turns": WorldCalendarServiceScript.YEAR_TURNS,
			}
		)
	return _wounded_recovery_service


func _wounded_recovery_query(query_id: String, args: Array) -> Variant:
	match query_id:
		"has_hero": return not _get_hero_seed_entry(str(args[0])).is_empty()
		"hero_state":
			var hero_id := str(args[0])
			var raw_state := _get_existing_hero_runtime_state(hero_id)
			var normalized := _normalize_hero_runtime_state(hero_id, raw_state)
			for key in ["last_battle_current_troops", "last_battle_max_troops", "last_battle_transaction_id"]:
				if raw_state.has(key):
					normalized[key] = raw_state.get(key)
			return normalized
		"hero_ids": return _hero_runtime_states.keys()
		"has_city": return _has_city_for_battle_context(str(args[0]))
		"city_ids": return _city_runtime_states.keys()
		"city_state": return _get_mutable_city_runtime_state(str(args[0])).duplicate(true)
		"city_troops": return _get_city_troops_for_battle_context(str(args[0]))
		"city_resource_amount": return _get_city_supply_resource_amount(str(args[0]), str(args[1]))
		"last_recovery_month_serial": return int(_player_state.get("last_wounded_recovery_month_serial", -1))
	return null


func _wounded_recovery_mutation(mutation_id: String, args: Array) -> Variant:
	match mutation_id:
		"set_hero_state":
			var hero_id := str(args[0])
			if hero_id.is_empty() or not args[1] is Dictionary:
				return false
			_hero_runtime_states[hero_id] = (args[1] as Dictionary).duplicate(true)
			return true
		"set_city_wounded_queue":
			var city_id := str(args[0])
			var city_data := _get_mutable_city_runtime_state(city_id)
			if city_data.is_empty() or not args[1] is Array:
				return false
			city_data["woundedQueue"] = (args[1] as Array).duplicate(true)
			city_data["wounded_queue"] = (args[1] as Array).duplicate(true)
			_city_runtime_states[city_id] = city_data
			return true
		"set_city_troops":
			_set_city_runtime_troops(str(args[0]), maxi(0, int(args[1])))
			return true
		"set_city_resource_amount":
			var city_id := str(args[0])
			var city_data := _get_mutable_city_runtime_state(city_id)
			if city_data.is_empty():
				return false
			var stock: Dictionary = city_data.get("resource_stock", {}).duplicate(true)
			stock[str(args[1])] = maxi(0, int(args[2]))
			city_data["resource_stock"] = stock
			_city_runtime_states[city_id] = city_data
			return true
		"set_last_recovery_month_serial":
			_player_state["last_wounded_recovery_month_serial"] = int(args[0])
			return true
		"set_last_wounded_treatment":
			_player_state["last_wounded_treatment"] = (args[0] as Dictionary).duplicate(true)
			return true
	return null


func _ensure_t03_battle_presentation() -> T03BattlePresentationControllerScript:
	if _t03_battle_presentation == null:
		_t03_battle_presentation = T03BattlePresentationControllerScript.new()
		_t03_battle_presentation.name = "T03BattlePresentationController"
		add_child(_t03_battle_presentation)
		_t03_battle_presentation.configure(
			{
				"root": _t03_battle_presentation_root,
				"video_player": _t03_battle_video_player,
				"video_labels": _t03_battle_video_labels,
				"skip_button": _t03_battle_skip_button,
				"result_card": _t03_battle_result_card,
				"result_title": _t03_battle_result_title,
				"result_body": _t03_battle_result_body,
				"confirm_button": _t03_battle_result_confirm_button,
			},
			Callable(self, "_t03_battle_presentation_query"),
			Callable(self, "_t03_battle_presentation_mutation"),
			Callable(self, "_format_faction_label"),
			Callable(self, "_format_city_name_by_id"),
			T03_AI_BATTLE_VIDEO_PATH
		)
		_t03_battle_presentation.presentation_completed.connect(_on_t03_battle_presentation_completed)
	return _t03_battle_presentation


func _t03_battle_presentation_query(query_id: String, _args: Array) -> Variant:
	match query_id:
		"report_queue": return (_player_state.get("t03_automatic_battle_reports", []) as Array).duplicate(true)
		"acknowledged_report_ids": return (_player_state.get("t03_acknowledged_report_ids", []) as Array).duplicate()
	return null


func _t03_battle_presentation_mutation(mutation_id: String, args: Array) -> Variant:
	match mutation_id:
		"set_report_queue":
			_player_state["t03_automatic_battle_reports"] = (args[0] as Array).duplicate(true)
			return true
		"set_acknowledged_report_ids":
			_player_state["t03_acknowledged_report_ids"] = (args[0] as Array).duplicate()
			return true
	return null


func _battle_result_query(query_id: String, args: Array) -> Variant:
	match query_id:
		"has_city": return _has_city_for_battle_context(str(args[0]))
		"city_troops": return _get_city_troops_for_battle_context(str(args[0]))
		"city_owner": return _get_city_owner_id_for_battle_context(str(args[0]))
		"faction_label": return _format_faction_label(str(args[0]))
		"player_faction": return _get_current_player_faction_id()
		"has_hero": return not _get_hero_seed_entry(str(args[0])).is_empty()
		"city_hero_ids": return _get_stationed_hero_ids_for_city(_get_city_hud_entry(str(args[0])))
		"hero_status_mutable": return _is_hero_eligible_for_placeholder_state(str(args[0]))
		"city_neighbors": return _get_city_neighbors_mvp(str(args[0]))
		"faction_city_count": return _get_enemy_owned_city_count_mvp(str(args[0]))
	return null


func _battle_settlement_query(query_id: String, args: Array) -> Variant:
	match query_id:
		"has_city": return _has_city_for_battle_context(str(args[0]))
		"city_troops": return _get_city_troops_for_battle_context(str(args[0]))
		"is_result_applied":
			var raw_ids: Variant = _player_state.get("applied_battle_result_ids", [])
			return raw_ids is Array and (raw_ids as Array).has(str(args[0]))
		"pending_transaction_id":
			var pending: Variant = _player_state.get("pending_battle_context", {})
			return str((pending as Dictionary).get("transaction_id", "")) if pending is Dictionary else ""
		"nearest_player_retreat_city": return _find_nearest_player_owned_neighbor_city_mvp(str(args[0]))
	return null


func _battle_settlement_mutation(mutation_id: String, args: Array) -> Variant:
	match mutation_id:
		"set_city_troops":
			return _apply_battle_settlement_city_troops(str(args[0]), maxi(0, int(args[1])))
		"set_city_owner":
			return _apply_battle_settlement_city_owner(str(args[0]), str(args[1]))
		"add_wounded":
			_add_wounded_to_city_mvp(str(args[0]), maxi(0, int(args[1])), maxi(1, int(args[2])), str(args[3]), str(args[4]))
			return true
		"clear_wounded":
			_clear_city_wounded_queue_mvp(str(args[0]))
			return true
		"move_hero": return _apply_battle_settlement_move_hero(str(args[0]), str(args[1]))
		"set_hero_faction": return _apply_battle_settlement_hero_faction(str(args[0]), str(args[1]), str(args[2]), str(args[3]), str(args[4]))
		"set_hero_status": return _apply_battle_settlement_hero_status(str(args[0]), str(args[1]), args[2] if args[2] is Dictionary else {}, str(args[3]))
		"unstation_hero":
			_remove_hero_from_other_city_runtime_rosters(str(args[0]), "")
			return true
		"clear_city_governor":
			var city_id := str(args[0])
			var city := _get_mutable_city_runtime_state(city_id)
			city["governor_id"] = ""
			city["governorHeroId"] = ""
			_city_runtime_states[city_id] = city
			return true
		"record_defender_disposition":
			_record_battle_defender_disposition(args[0] if args[0] is Dictionary else {})
			return true
		"set_defender_supply": return _apply_battle_settlement_defender_supply(str(args[0]), args[1] if args[1] is Dictionary else {})
		"add_attacker_cargo": return _apply_battle_settlement_attacker_cargo(str(args[0]), args[1] if args[1] is Dictionary else {})
		"mark_result_applied":
			var applied: Array = _player_state.get("applied_battle_result_ids", []) if _player_state.get("applied_battle_result_ids", []) is Array else []
			var result_id := str(args[0])
			if not result_id.is_empty() and not applied.has(result_id):
				applied.append(result_id)
			_player_state["applied_battle_result_ids"] = applied
			return true
	return null


func _apply_battle_settlement_city_troops(city_id: String, troops: int) -> bool:
	var city := _get_mutable_city_runtime_state(city_id)
	if city.is_empty():
		return false
	city["troops"] = maxi(0, troops)
	_city_runtime_states[city_id] = city
	return true


func _apply_battle_settlement_city_owner(city_id: String, owner_id: String) -> bool:
	if owner_id.is_empty():
		return false
	var city := _get_mutable_city_runtime_state(city_id)
	if city.is_empty():
		return false
	city["owner"] = owner_id
	city["nation"] = owner_id
	city["owner_faction_id"] = owner_id
	city["faction"] = owner_id
	_city_runtime_states[city_id] = city
	return true


func _battle_context_query(query_id: String, args: Array) -> Variant:
	match query_id:
		"turn_number": return int(_player_state.get("turn_number", 1))
		"has_city": return _has_city_for_battle_context(str(args[0]))
		"city_owner": return _get_city_owner_id_for_battle_context(str(args[0]))
		"city_troops": return _get_city_troops_for_battle_context(str(args[0]))
		"city_name": return _format_city_name_by_id(str(args[0]), str(args[1]))
		"city_neighbors": return _get_city_neighbors_mvp(str(args[0]))
		"city_stationed_hero_ids": return _battle_context_get_city_stationed_hero_ids(str(args[0]))
		"city_governor_id": return _battle_context_get_city_governor_id(str(args[0]))
		"city_battle_supply": return _select_city_battle_supply(str(args[0]))
		"is_city_owner_consistent_for_enemy_invasion": return _is_city_owner_consistent_for_enemy_invasion_mvp(str(args[0]))
		"is_city_owned_by_enemy": return _is_city_owned_by_enemy_mvp(str(args[0]))
		"is_city_owned_by_player": return _is_city_owned_by_player_mvp(str(args[0]))
		"city_troops_for_enemy_invasion": return _get_city_troops_for_enemy_invasion_mvp(str(args[0]))
		"available_player_attack_hero_ids": return _get_available_player_attack_main_hero_ids(str(args[0]))
		"hero_entry": return _get_hero_entry(str(args[0])).duplicate(true)
		"is_hero_captured_for_battle": return _is_hero_captured_for_battle(str(args[0]))
		"player_battle_tech_modifier": return _get_player_battle_tech_modifier_mvp(str(args[0]), str(args[1])).duplicate(true)
		"has_domestic_battle_modifier_data": return _has_domestic_battle_modifier_data_mvp(args[0] as Dictionary)
	return null


func _enemy_warfare_query(query_id: String, args: Array) -> Variant:
	match query_id:
		"player_faction": return _get_current_player_faction_id()
		"turn_number": return int(_player_state.get("turn_number", 0))
		"last_pressure_plan": return _player_state.get("last_enemy_pressure_plan_result", {})
		"has_pending_warfare": return _has_pending_invasion_event_mvp() or not _get_pending_battle_context_mvp().is_empty()
		"manual_invasion_grace": return _is_manual_qa_invasion_grace_turn_active_mvp()
		"enemy_faction_ids": return _get_enemy_faction_ids_for_turn_mvp()
		"enemy_owned_city_ids": return _get_enemy_owned_city_ids_for_faction(str(args[0]))
		"safe_enemy_owner": return _get_safe_enemy_owner_faction_id_for_turn_mvp(str(args[0]))
		"has_city": return _has_city_for_battle_context(str(args[0])) or CITY_HUD_DATA.has(str(args[0]))
		"neighbors": return _get_city_neighbors_mvp(str(args[0]))
		"city_troops": return _get_city_troops_for_battle_context(str(args[0]))
		"is_player_owned": return _is_city_owned_by_player_mvp(str(args[0]))
		"is_enemy_owned": return _is_city_owned_by_enemy_mvp(str(args[0]))
		"faction_label": return _format_faction_label(str(args[0]))
		"city_label": return _format_city_name_by_id(str(args[0]), str(args[0]))
		"city_owner": return _get_city_owner_id_for_battle_context(str(args[0]))
		"city_owner_sources":
			var city_id := str(args[0])
			var marker := _city_markers_by_id.get(city_id) as WorldMapCityMarker
			var city_data := _get_city_hud_entry(city_id)
			return {"marker": marker.owner_faction_id if marker != null else "", "runtime": _get_city_owner_faction_id(city_data) if not city_data.is_empty() else ""}
		"faction_defeated": return _is_t03_faction_defeated(str(args[0]))
		"eligible_hero_ids": return _get_t03_eligible_city_hero_ids(str(args[0]))
		"deployable_troops":
			var allocation := _build_command_limit_troop_allocation_for_heroes(args[1] as Array, int(args[2]), str(args[0]))
			return _sum_troop_allocation(allocation)
		"city_resource":
			_ensure_city_supply_resource_defaults(str(args[0]))
			return _get_city_supply_resource_amount(str(args[0]), str(args[1]))
		"city_food_total":
			_ensure_city_supply_resource_defaults(str(args[0]))
			return _get_t03_city_food_total(str(args[0]))
	return null


func _ensure_diplomacy_action_coordinator() -> WorldMapActionCoordinator:
	if not is_instance_valid(_diplomacy_action_coordinator):
		_diplomacy_action_coordinator = WorldMapActionCoordinatorScript.new()
		_diplomacy_action_coordinator.name = "DiplomacyActionCoordinator"
		_diplomacy_action_coordinator.configure_diplomacy(_ensure_diplomacy_controller())
		_diplomacy_action_coordinator.configure_trade(_ensure_trade_controller())
		_diplomacy_action_coordinator.configure_spy(_ensure_spy_controller())
		add_child(_diplomacy_action_coordinator)
		_diplomacy_action_coordinator.presentation_requested.connect(_on_diplomacy_presentation_requested)
		_diplomacy_action_coordinator.action_resolved.connect(_on_diplomacy_action_resolved)
	return _diplomacy_action_coordinator


func _on_diplomacy_presentation_requested(action_type: String, action_id: String, target_city_id: String) -> void:
	contextual_worldmap_action_presentation_requested.emit(action_type, action_id, target_city_id)


func _on_diplomacy_action_resolved(action_type: String, result: Dictionary) -> void:
	_resolve_contextual_worldmap_action_without_video(action_type, result)


func open_contextual_worldmap_action(action_type: String, target_city_id: String) -> Dictionary:
	cancel_contextual_worldmap_action()
	var normalized_type := action_type.strip_edges().to_lower()
	if not ["diplomacy", "spy", "trade"].has(normalized_type):
		return {"ok": false, "message": "지원하지 않는 도시 행동입니다."}
	var target_marker := _city_markers_by_id.get(target_city_id) as WorldMapCityMarker
	if target_marker == null:
		return {"ok": false, "message": "대상 도시를 확인할 수 없습니다."}
	if _is_city_owned_by_player_mvp(target_city_id):
		return {"ok": false, "message": "타국 도시에서만 실행할 수 있습니다."}

	_set_unified_city_panel_collapsed(false)
	if normalized_type == "trade":
		var source_city_id := _find_contextual_trade_source_city_id(target_city_id)
		if source_city_id.is_empty():
			return {"ok": false, "message": "이 도시와 연결된 자국 교역 도시가 없습니다."}
		var source_marker := _city_markers_by_id.get(source_city_id) as WorldMapCityMarker
		if source_marker == null:
			return {"ok": false, "message": "교역 출발 도시를 확인할 수 없습니다."}
		_on_city_marker_selected(source_marker)
		_unified_primary_tab = UNIFIED_PANEL_TAB_TRADE
		_selected_city_detail_tab = CITY_DETAIL_TAB_EXTERNAL_TRADE
		_trade_control_modes[CITY_DETAIL_TAB_EXTERNAL_TRADE] = TRADE_CONTROL_MODE_MANUAL
		_refresh_unified_panel_content()
		_open_manual_trade_order_panel()
		if _manual_trade_target_option != null:
			_select_option_by_metadata(_manual_trade_target_option, target_city_id)
			_refresh_manual_trade_order_relation()
			_refresh_manual_trade_order_preview()
		_contextual_worldmap_action_source_city_id = source_city_id
	else:
		_on_city_marker_selected(target_marker)
		_unified_primary_tab = UNIFIED_PANEL_TAB_DIPLOMACY_SPY
		_selected_diplomacy_spy_tab = DIPLOMACY_SPY_TAB_SPY if normalized_type == "spy" else DIPLOMACY_SPY_TAB_DIPLOMACY
		_refresh_unified_panel_content()

	_contextual_worldmap_action_type = normalized_type
	_contextual_worldmap_action_target_city_id = target_city_id
	if normalized_type == "diplomacy":
		return _ensure_diplomacy_action_coordinator().begin("diplomacy", target_city_id)
	if normalized_type == "spy":
		return _ensure_diplomacy_action_coordinator().begin("spy", target_city_id)
	if normalized_type == "trade":
		return _ensure_diplomacy_action_coordinator().begin("trade", target_city_id, _contextual_worldmap_action_source_city_id)
	return {
		"ok": true,
		"action_type": normalized_type,
		"target_city_id": target_city_id,
		"source_city_id": _contextual_worldmap_action_source_city_id,
		"message": "행동을 선택한 뒤 실행하면 영상과 결과가 표시됩니다.",
	}


func cancel_contextual_worldmap_action() -> void:
	if is_instance_valid(_diplomacy_action_coordinator):
		_diplomacy_action_coordinator.cancel()
	_pending_diplomacy_action_id = ""
	_pending_spy_action_id = ""
	_pending_trade_action_id = ""
	_contextual_worldmap_action_type = ""
	_contextual_worldmap_action_target_city_id = ""
	_contextual_worldmap_action_source_city_id = ""
	_contextual_worldmap_action_pending = false


func complete_contextual_worldmap_action(action_type: String, action_id: String, target_city_id: String) -> Dictionary:
	if not _contextual_worldmap_action_pending:
		return {"success": false, "message": "실행 대기 중인 도시 행동이 없습니다."}
	if action_type != _contextual_worldmap_action_type or target_city_id != _contextual_worldmap_action_target_city_id:
		return {"success": false, "message": "도시 행동 대상이 변경되었습니다."}
	if action_type == "diplomacy":
		if action_id != _pending_diplomacy_action_id:
			return {"success": false, "message": "외교 행동이 변경되었습니다."}
		return _ensure_diplomacy_action_coordinator().complete(action_type, action_id, target_city_id)
	if action_type == "spy":
		if action_id != _pending_spy_action_id:
			return {"success": false, "message": "첩보 행동이 변경되었습니다."}
		return _ensure_diplomacy_action_coordinator().complete(action_type, action_id, target_city_id)
	if action_type == "trade":
		if action_id != _pending_trade_action_id:
			return {"success": false, "message": "무역 행동이 변경되었습니다."}
		return _ensure_diplomacy_action_coordinator().complete(action_type, action_id, target_city_id)
	return {"success": false, "message": "지원하지 않는 도시 행동입니다."}


func _find_contextual_trade_source_city_id(target_city_id: String) -> String:
	var candidate_source_ids: Array[String] = []
	for city_id_variant in _city_markers_by_id.keys():
		var city_id := str(city_id_variant)
		if not _is_city_owned_by_player_mvp(city_id):
			continue
		if _get_external_trade_candidate_city_ids(city_id).has(target_city_id):
			candidate_source_ids.append(city_id)
	candidate_source_ids.sort()
	return candidate_source_ids[0] if not candidate_source_ids.is_empty() else ""


func _request_contextual_worldmap_action_presentation(action_type: String, action_id: String, target_city_id: String) -> void:
	if _contextual_worldmap_action_pending:
		return
	_contextual_worldmap_action_pending = true
	if action_type == "diplomacy":
		_pending_diplomacy_action_id = action_id
		var request := _ensure_diplomacy_action_coordinator().request_presentation(action_type, action_id, target_city_id)
		if not bool(request.get("ok", false)):
			_resolve_contextual_worldmap_action_without_video(action_type, request)
		return
	if action_type == "spy":
		_pending_spy_action_id = action_id
		var request := _ensure_diplomacy_action_coordinator().request_presentation(action_type, action_id, target_city_id)
		if not bool(request.get("ok", false)):
			_resolve_contextual_worldmap_action_without_video(action_type, request)
		return
	if action_type == "trade":
		_pending_trade_action_id = action_id
		var request := _ensure_diplomacy_action_coordinator().request_presentation(action_type, action_id, target_city_id)
		if not bool(request.get("ok", false)):
			_resolve_contextual_worldmap_action_without_video(action_type, request)
		return
	contextual_worldmap_action_presentation_requested.emit(action_type, action_id, target_city_id)


func _resolve_contextual_worldmap_action_without_video(action_type: String, result: Dictionary) -> void:
	cancel_contextual_worldmap_action()
	_refresh_city_hud_data_bindings()
	_refresh_left_world_status_panel()
	_refresh_unified_panel_content()
	_queue_unified_city_panel_resize()
	contextual_worldmap_action_resolved.emit(action_type, result)


func _connect_city_info_panel_actions() -> void:
	if city_info_panel == null:
		return
	var presentation := _ensure_city_detail_presentation_controller()
	var callback := Callable(presentation, "relay_attack_requested")
	if city_info_panel.has_signal("attack_requested") and not city_info_panel.is_connected("attack_requested", callback):
		city_info_panel.connect("attack_requested", callback)
	var governor_assignment_callback := Callable(presentation, "relay_governor_assignment_requested")
	if city_info_panel.has_signal("governor_assignment_requested") and not city_info_panel.is_connected("governor_assignment_requested", governor_assignment_callback):
		city_info_panel.connect("governor_assignment_requested", governor_assignment_callback)
	var hero_transfer_callback := Callable(presentation, "relay_hero_transfer_confirmed")
	if city_info_panel.has_signal("hero_transfer_confirmed") and not city_info_panel.is_connected("hero_transfer_confirmed", hero_transfer_callback):
		city_info_panel.connect("hero_transfer_confirmed", hero_transfer_callback)
	var recruitment_callback := Callable(presentation, "relay_recruitment_requested")
	if city_info_panel.has_signal("recruitment_requested") and not city_info_panel.is_connected("recruitment_requested", recruitment_callback):
		city_info_panel.connect("recruitment_requested", recruitment_callback)
	var help_callback := Callable(self, "_show_worldmap_help_modal")
	if city_info_panel.has_signal("help_requested") and not city_info_panel.is_connected("help_requested", help_callback):
		city_info_panel.connect("help_requested", help_callback)


func _on_city_info_attack_requested(city_id: String) -> void:
	_start_player_attack_battle(city_id, "manual")


func _on_city_info_governor_assignment_requested(city_id: String, governor_id: String) -> void:
	var city_state := _get_mutable_city_runtime_state(city_id)
	var normalized_governor_id := governor_id.strip_edges()
	var hero_snapshot := _get_hero_entry(normalized_governor_id) if not normalized_governor_id.is_empty() else {}
	var result := _ensure_city_administration_service().validate_governor_assignment(city_id, normalized_governor_id, city_state, hero_snapshot)
	if not bool(result.get("ok", false)):
		if str(result.get("error_code", "")) == "hero_not_stationed":
			push_warning("[WorldMap] Ignored governor assignment outside stationed heroes: city=%s hero=%s" % [city_id, normalized_governor_id])
		return
	city_state["governor_id"] = str(result.get("governor_id", ""))
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
	_ensure_city_detail_presentation_controller().show_recruitment_result(message)


func _format_recruitment_failure_hint(reason: String) -> String:
	return _ensure_city_detail_presentation_controller().format_recruitment_failure_hint(reason)


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
			city_detail_rating_label.text = _ensure_trade_presenter().format_external_trade_manual_order_summary(city_marker.city_id, external_trade_candidate_city_ids)
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
	_ensure_city_detail_presentation_controller().apply_resource_tab({
		"food_resources": _extract_resource_group(str(city_data.get("resources", "")), ["쌀", "보리", "수산물"]),
		"strategy_resources": _extract_resource_group(str(city_data.get("resources", "")), ["목재", "철", "말"]),
		"special_resources": _extract_resource_group(str(city_data.get("resources", "")), ["비단", "소금"]),
		"population_rating": _format_star_rating(_get_city_numeric_rating(city_data, "population_rating", 0)),
		"commerce_rating": _format_star_rating(_get_city_numeric_rating(city_data, "commerce_rating", 0)),
		"economy_bonus_lines": _format_domestic_tech_city_economy_bonus_lines_mvp(city_id),
		"military_bonus_lines": _format_domestic_tech_city_military_defense_bonus_lines_mvp(city_id, city_data),
		"naval_bonus_lines": _format_domestic_tech_city_naval_siege_bonus_lines_mvp(city_id),
		"spy_bonus_lines": _format_domestic_tech_city_spy_intel_bonus_lines_mvp(city_id),
		"storage_summary": _format_city_storage_summary(_get_city_storage(city_id, city_data)),
		"economy_modifier_summary": _format_city_economy_tech_modifier_summary_mvp(city_id),
	})


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
	_ensure_city_detail_presentation_controller().set_resource_cards_enabled(is_enabled)


func _make_city_detail_resource_card_style(is_enabled: bool) -> StyleBoxFlat:
	return _ensure_city_detail_presentation_controller().make_resource_card_style(is_enabled)


func _set_city_detail_body_labels_visible(should_show: bool) -> void:
	_ensure_city_detail_presentation_controller().set_body_labels_visible(should_show, _is_trade_control_tab_active())


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
		_trade_control_status_label.text = "현재: %s" % _ensure_trade_presenter().get_trade_control_mode_label(mode)
	if _trade_auto_button != null:
		_trade_auto_button.disabled = false
		_apply_trade_control_button_state(_trade_auto_button, mode == TRADE_CONTROL_MODE_CHANCELLOR)
	if _trade_manual_button != null:
		_trade_manual_button.disabled = not has_manual_targets
		_apply_trade_control_button_state(_trade_manual_button, mode == TRADE_CONTROL_MODE_MANUAL and has_manual_targets)
	if _trade_control_hint_label != null:
		_trade_control_hint_label.text = _ensure_trade_presenter().get_trade_control_hint(tab_id, mode, has_manual_targets)


func _apply_trade_control_button_state(button: Button, is_active: bool) -> void:
	if button == null:
		return
	if button.disabled:
		button.modulate = Color(0.48, 0.48, 0.48, 0.72)
	elif is_active:
		button.modulate = Color(1.0, 0.9, 0.68, 1.0)
	else:
		button.modulate = Color(0.82, 0.86, 0.92, 1.0)






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
	var market_summary := _ensure_trade_presenter().format_trade_market_prices_for_external_trade_ui()
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
	_manual_trade_preview_label.text = _ensure_trade_presenter().format_manual_trade_preview_summary(_build_manual_trade_order_preview())


func _build_manual_trade_order_preview() -> Dictionary:
	return _ensure_trade_controller().build_external_manual_trade_execution_preview({
		"source_city_id": _manual_trade_current_source_city_id,
		"target_city_id": _get_selected_manual_trade_target_city_id(),
		"orders": _build_manual_trade_order_items_from_panel(),
	})




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
	var efficiency := _ensure_trade_controller().get_trade_efficiency_for_cities(source_city_id, target_city_id)
	if efficiency <= 0.0:
		if _manual_trade_status_label != null:
			_manual_trade_status_label.text = "교역 효율을 확인할 수 없습니다."
		return
	var orders := _build_manual_trade_order_items_from_panel()
	if orders.is_empty():
		if _manual_trade_status_label != null:
			_manual_trade_status_label.text = "수입/수출 자원과 수량을 하나 이상 입력하십시오."
		return
	var preview := _ensure_trade_controller().build_external_manual_trade_execution_preview({
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
	_ensure_trade_controller().store_manual_trade_order(payload)
	print("[WorldMap] Manual external trade order stored: %s" % str(payload))
	_close_manual_trade_order_panel()
	_refresh_unified_panel_content()


func _on_manual_trade_order_cancel_pressed() -> void:
	_close_manual_trade_order_panel()
	if _contextual_worldmap_action_type == "trade":
		cancel_contextual_worldmap_action()


func _on_manual_trade_execution_button_pressed() -> void:
	if selected_city_marker == null:
		return
	if _contextual_worldmap_action_type == "trade" and _contextual_worldmap_action_pending:
		return
	var source_city_id := selected_city_marker.city_id
	var order := _ensure_trade_controller().get_manual_trade_order(source_city_id)
	if _contextual_worldmap_action_type == "trade":
		var contextual_validation := _ensure_trade_controller().validate_external_manual_trade_execution(order)
		if bool(contextual_validation.get("ok", false)) and str(order.get("target_city_id", "")) == _contextual_worldmap_action_target_city_id:
			_request_contextual_worldmap_action_presentation("trade", "external_manual_trade", _contextual_worldmap_action_target_city_id)
		else:
			if bool(contextual_validation.get("ok", false)):
				contextual_validation = {"ok": false, "success": false, "reason": "target_changed", "message": "처음 선택한 도시가 교역 대상에서 변경되었습니다."}
			_resolve_contextual_worldmap_action_without_video("trade", contextual_validation)
		return
	var result := _execute_external_manual_trade_order(order)
	if bool(result.get("ok", false)):
		print("[WorldMap] External manual trade executed: %s" % str(result))
	else:
		print("[WorldMap] External manual trade execution failed: %s" % str(result))
	_refresh_city_hud_data_bindings()
	_refresh_left_world_status_panel()
	_refresh_unified_panel_content()
	_queue_unified_city_panel_resize()


func _execute_external_manual_trade_order(order: Dictionary) -> Dictionary:
	return _ensure_diplomacy_action_coordinator().execute_trade_order(order)


func _get_trade_efficiency_for_cities(source_city_id: String, target_city_id: String) -> float:
	return _ensure_trade_controller().get_trade_efficiency_for_cities(source_city_id, target_city_id)


func _calculate_trade_import_cost(resource_id: String, amount: int, efficiency: float) -> int:
	return _ensure_trade_controller().calculate_trade_import_cost(resource_id, amount, efficiency)


func _calculate_trade_export_gain(resource_id: String, amount: int, efficiency: float) -> int:
	return _ensure_trade_controller().calculate_trade_export_gain(resource_id, amount, efficiency)


func _apply_chancellor_auto_trade_for_world_turn(turn_number: int) -> Dictionary:
	return _ensure_trade_controller().run_chancellor_auto_trade(turn_number)


func _normalize_trade_control_modes(raw_modes: Variant) -> Dictionary:
	return _ensure_trade_controller().normalize_trade_control_modes(raw_modes)


func _normalize_manual_trade_orders(raw_orders: Variant) -> Dictionary:
	return _ensure_trade_controller().normalize_manual_trade_orders(raw_orders)






func _normalize_trade_result_payload(raw_result: Variant) -> Dictionary:
	return _ensure_trade_controller().normalize_trade_result_payload(raw_result)




func _normalize_chancellor_auto_trade_result_payload(raw_result: Variant) -> Dictionary:
	return _ensure_trade_controller().normalize_chancellor_auto_trade_result_payload(raw_result)




func _has_worldmap_city_for_trade_persistence(city_id: String) -> bool:
	if city_id.is_empty():
		return false
	return CITY_HUD_DATA.has(city_id) or not _get_city_hud_entry(city_id).is_empty()


func _normalize_city_intel_registry(raw_intel: Variant) -> Dictionary:
	return _ensure_spy_controller().normalize_city_intel_registry(raw_intel)


func _sync_trade_persistence_to_player_state() -> void:
	_ensure_trade_controller().sync_persistence_to_player_state()
	_player_state["city_intel"] = _normalize_city_intel_registry(_player_state.get("city_intel", {}))
	_ensure_faction_chancellors_seeded()


func _restore_trade_persistence_from_player_state() -> void:
	_ensure_trade_controller().restore_persistence_from_player_state()
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
	return _ensure_trade_controller().validate_internal_transfer(source_city_id, target_city_id, amounts)


func _apply_internal_trade_transfer(source_city_id: String, target_city_id: String, amounts: Dictionary) -> Dictionary:
	return _ensure_trade_controller().execute_internal_transfer(source_city_id, target_city_id, amounts)


func _set_city_storage(city_id: String, storage: Dictionary) -> void:
	if city_id.is_empty():
		return
	var mutable_city_state := _get_mutable_city_runtime_state(city_id)
	if mutable_city_state.is_empty():
		return
	mutable_city_state["storage"] = _ensure_city_resource_service().ensure_city_storage_keys(storage)
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
	return UIFormatterHelpers.format_internal_trade_transfer_amounts(amounts, INTERNAL_TRADE_TRANSFER_RESOURCE_ORDER, RESOURCE_LABELS)


func _format_star_rating(value: int, max_value: int = 5) -> String:
	return UIFormatterHelpers.format_star_rating(value, max_value)


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
		city_detail_region_owner_label.text = _ensure_diplomacy_presenter()._format_diplomacy_owner_display(selected_city_marker)
		city_detail_resource_label.text = _ensure_diplomacy_presenter()._format_diplomacy_relation_summary_for_ui(selected_city_marker)
		city_detail_security_label.text = _ensure_diplomacy_presenter()._format_diplomacy_trade_status_for_ui(selected_city_marker)
		city_detail_military_label.text = _ensure_diplomacy_presenter()._format_diplomacy_action_candidates_for_ui(selected_city_marker)
		city_detail_commerce_label.text = _ensure_diplomacy_presenter()._format_diplomacy_policy_display_for_ui(selected_city_marker)
		city_detail_rating_label.text = ""
		city_detail_hint_label.text = "선택 도시 소유 세력과 PLAYER의 관계, 교역, 행동 후보를 확인합니다."
		_refresh_diplomacy_action_card(selected_city_marker)
	city_detail_domestic_button_placeholder.text = ""
	city_detail_domestic_button_placeholder.visible = false
	city_detail_status_label.text = ""
	_queue_unified_city_panel_resize()


func _format_diplomacy_spy_target_city_display(city_marker: WorldMapCityMarker) -> String:
	if city_marker == null:
		return "선택 도시\n미선택"
	var owner_id := _get_city_owner_faction_id_for_trade_display(city_marker.city_id)
	var owner_label := _format_faction_label(owner_id)
	if owner_id.is_empty():
		owner_label = "세력 미확인"
	return "선택 도시\n%s · %s" % [city_marker.display_name, owner_label]


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
	var model := _ensure_diplomacy_presenter().build_action_card_model(city_marker)
	_diplomacy_action_card.visible = bool(model.get("visible", false))
	if not _diplomacy_action_card.visible:
		return
	_diplomacy_action_title_label.text = str(model["title"])
	_diplomacy_action_status_label.text = str(model["status"])
	var validation_map: Dictionary = model["validation_map"]
	_refresh_diplomacy_action_button(_diplomacy_envoy_button, validation_map[DIPLOMACY_ACTION_ENVOY])
	_refresh_diplomacy_action_button(_diplomacy_tribute_button, validation_map[DIPLOMACY_ACTION_TRIBUTE])
	_refresh_diplomacy_action_button(_diplomacy_trade_agreement_button, validation_map[DIPLOMACY_ACTION_TRADE_AGREEMENT])
	_refresh_diplomacy_action_button(_diplomacy_restore_button, validation_map[DIPLOMACY_ACTION_RESTORE_RELATIONS])
	_refresh_diplomacy_action_button(_diplomacy_alliance_button, validation_map[DIPLOMACY_ACTION_ALLIANCE_PROPOSAL])
	_diplomacy_action_hint_label.text = str(model["hint"])


func _refresh_diplomacy_action_button(button: Button, validation: Dictionary) -> void:
	if button == null:
		return
	var model := _ensure_diplomacy_presenter().build_action_button_model(validation)
	button.disabled = bool(model["disabled"])
	button.tooltip_text = str(model["tooltip"])


func _get_enemy_intel_revealed_field_ids_for_ui(fields: Array[String], payload: Dictionary) -> Array[String]:
	return _ensure_spy_presenter().get_revealed_field_ids(fields, payload)


func _has_enemy_intel_payload_for_ui(fields: Array[String], payload: Dictionary, field: String) -> bool:
	return _ensure_spy_presenter().has_enemy_intel_payload(fields, payload, field)


func _get_city_intel_fields_for_ui(intel_entry: Dictionary) -> Array[String]:
	return _ensure_spy_presenter().get_city_intel_fields(intel_entry)


func _get_city_intel_payload_for_ui(intel_entry: Dictionary) -> Dictionary:
	return _ensure_spy_presenter().get_city_intel_payload(intel_entry)


func _get_city_intel_entry_for_ui(city_id: String) -> Dictionary:
	return _ensure_spy_presenter().get_city_intel_entry(city_id)


func _format_spy_visibility_summary_for_ui(city_marker: WorldMapCityMarker) -> String:
	return _ensure_spy_presenter().format_visibility_summary(city_marker)


func _format_spy_known_info_summary_for_ui(city_marker: WorldMapCityMarker) -> String:
	return _ensure_spy_presenter().format_known_info_summary(city_marker)


func _format_enemy_city_baseline_grade_label_mvp(score: int) -> String:
	if score >= 8:
		return "높음"
	if score >= 5:
		return "보통"
	return "낮음"


func _get_enemy_city_economy_baseline_mvp(city: Dictionary) -> Dictionary:
	var result := {
		"city_id": str(city.get("id", "")),
		"owner_scope": "enemy",
		"enemy_baseline": true,
		"enemy_research_effect": false,
		"player_completed_tech_lookup": false,
		"masked": true,
		"economy_grade_label": "정보 부족",
		"supply_grade_label": "정보 부족",
		"defense_grade_label": "정보 부족",
		"source": "city_grade_faction_baseline",
	}
	var city_id := str(result.get("city_id", ""))
	if city_id.is_empty() or not _is_city_owned_by_enemy_mvp(city_id):
		result["reason"] = "not_enemy_city"
		return result
	var intel_entry := _get_city_intel_entry_for_ui(city_id)
	if intel_entry.is_empty():
		result["reason"] = "insufficient_intel"
		return result
	var fields := _get_city_intel_fields_for_ui(intel_entry)
	var payload := _get_city_intel_payload_for_ui(intel_entry)
	var revealed_fields := _get_enemy_intel_revealed_field_ids_for_ui(fields, payload)
	if not revealed_fields.has("resources") and not revealed_fields.has("troops") and not revealed_fields.has("troops_estimated"):
		result["reason"] = "insufficient_intel"
		return result
	result["masked"] = false
	var resource_seed: Dictionary = {}
	var raw_resource_seed: Variant = city.get("resource_seed", {})
	if raw_resource_seed is Dictionary:
		resource_seed = raw_resource_seed as Dictionary
	var food_score := int(resource_seed.get("rice", 0)) + int(resource_seed.get("barley", 0)) + int(resource_seed.get("seafood", 0))
	var economy_score := _get_city_numeric_rating(city, "population_rating", 3) + _get_city_numeric_rating(city, "commerce_rating", 3)
	var defense_score := _get_city_numeric_rating(city, "defense", 3)
	if _has_enemy_intel_payload_for_ui(fields, payload, "troops") or _has_enemy_intel_payload_for_ui(fields, payload, "troops_estimated"):
		var troops_value := int(payload.get("troops", payload.get("troops_estimated", city.get("troops", 0))))
		defense_score += clampi(int(floor(float(maxi(0, troops_value)) / 250.0)), 0, 3)
	result["economy_grade_score"] = economy_score
	result["supply_grade_score"] = food_score
	result["defense_grade_score"] = defense_score
	result["economy_grade_label"] = _format_enemy_city_baseline_grade_label_mvp(economy_score)
	result["supply_grade_label"] = _format_enemy_city_baseline_grade_label_mvp(food_score)
	result["defense_grade_label"] = _format_enemy_city_baseline_grade_label_mvp(defense_score)
	result["revealed_fields"] = revealed_fields
	return result


func _get_enemy_city_defense_baseline_mvp(city: Dictionary) -> Dictionary:
	var result := {
		"city_id": str(city.get("id", "")),
		"owner_scope": "enemy",
		"enemy_baseline": true,
		"enemy_research_effect": false,
		"player_completed_tech_lookup": false,
		"masked": true,
		"defense_grade_label": "정보 부족",
		"garrison_grade_label": "정보 부족",
		"battle_grade_label": "정보 부족",
		"source": "city_grade_faction_baseline",
	}
	var city_id := str(result.get("city_id", ""))
	if city_id.is_empty() or not _is_city_owned_by_enemy_mvp(city_id):
		result["reason"] = "not_enemy_city"
		return result
	var intel_entry := _get_city_intel_entry_for_ui(city_id)
	if intel_entry.is_empty():
		result["reason"] = "insufficient_intel"
		return result
	var fields := _get_city_intel_fields_for_ui(intel_entry)
	var payload := _get_city_intel_payload_for_ui(intel_entry)
	var revealed_fields := _get_enemy_intel_revealed_field_ids_for_ui(fields, payload)
	if not revealed_fields.has("troops") and not revealed_fields.has("troops_estimated") and not revealed_fields.has("resources"):
		result["reason"] = "insufficient_intel"
		return result
	result["masked"] = false
	var defense_score := _get_city_numeric_rating(city, "defense", 3)
	var troops_value := int(city.get("troops", 0))
	if _has_enemy_intel_payload_for_ui(fields, payload, "troops") or _has_enemy_intel_payload_for_ui(fields, payload, "troops_estimated"):
		troops_value = int(payload.get("troops", payload.get("troops_estimated", troops_value)))
	var garrison_score := clampi(int(floor(float(maxi(0, troops_value)) / 250.0)), 0, 5)
	var battle_score := defense_score + garrison_score
	result["defense_grade_score"] = defense_score
	result["garrison_grade_score"] = garrison_score
	result["battle_grade_score"] = battle_score
	result["defense_grade_label"] = _format_enemy_city_baseline_grade_label_mvp(defense_score)
	result["garrison_grade_label"] = _format_enemy_city_baseline_grade_label_mvp(garrison_score)
	result["battle_grade_label"] = _format_enemy_city_baseline_grade_label_mvp(battle_score)
	result["revealed_fields"] = revealed_fields
	return result


func _get_enemy_battle_baseline_modifier_mvp(city: Dictionary, role: String = "defender") -> Dictionary:
	var modifier := _get_empty_domestic_battle_modifier_mvp()
	modifier["owner_scope"] = "enemy"
	modifier["role"] = role
	modifier["enemy_baseline"] = true
	modifier["enemy_research_effect"] = false
	modifier["player_completed_tech_lookup"] = false
	modifier["masked"] = true
	var baseline := _get_enemy_city_defense_baseline_mvp(city)
	if bool(baseline.get("masked", true)):
		modifier["reason"] = baseline.get("reason", "insufficient_intel")
		return modifier
	modifier["masked"] = false
	var defense_score := int(baseline.get("defense_grade_score", 0))
	var battle_score := int(baseline.get("battle_grade_score", 0))
	if role == "attacker":
		modifier["global_attack_pct"] = minf(0.08, float(battle_score) * 0.01)
	else:
		modifier["global_defense_pct"] = minf(0.08, float(defense_score) * 0.01)
	modifier["source"] = "enemy_city_grade_baseline"
	return modifier


func _get_enemy_naval_baseline_mvp(city: Dictionary) -> Dictionary:
	var result := {
		"city_id": str(city.get("id", "")),
		"owner_scope": "enemy",
		"enemy_baseline": true,
		"enemy_research_effect": false,
		"player_completed_tech_lookup": false,
		"masked": true,
		"naval_grade_label": "정보 부족",
		"shipyard_basis_label": "불명",
		"source": "city_coastal_faction_baseline",
	}
	var city_id := str(result.get("city_id", ""))
	if city_id.is_empty() or not _is_city_owned_by_enemy_mvp(city_id):
		result["reason"] = "not_enemy_city"
		return result
	var intel_entry := _get_city_intel_entry_for_ui(city_id)
	if intel_entry.is_empty():
		result["reason"] = "insufficient_intel"
		return result
	var fields := _get_city_intel_fields_for_ui(intel_entry)
	var payload := _get_city_intel_payload_for_ui(intel_entry)
	var revealed_fields := _get_enemy_intel_revealed_field_ids_for_ui(fields, payload)
	if not revealed_fields.has("resources") and not revealed_fields.has("troops") and not revealed_fields.has("troops_estimated"):
		result["reason"] = "insufficient_intel"
		return result
	result["masked"] = false
	var naval_score := 1
	if _is_city_coastal_for_city_tech(city_id):
		naval_score += 3
	var resource_seed: Dictionary = city.get("resource_seed", {}) if city.get("resource_seed", {}) is Dictionary else {}
	naval_score += clampi(int(resource_seed.get("seafood", 0)), 0, 3)
	var commerce_score := _get_city_numeric_rating(city, "commerce_rating", 3)
	if commerce_score >= 4:
		naval_score += 1
	var city_type := str(city.get("type", "")).to_lower()
	if city_type.find("port") >= 0 or city_type.find("coastal") >= 0:
		result["shipyard_basis_label"] = "확인됨"
	result["naval_grade_score"] = naval_score
	result["naval_grade_label"] = _format_enemy_city_baseline_grade_label_mvp(naval_score)
	result["revealed_fields"] = revealed_fields
	return result


func _get_enemy_siege_baseline_mvp(city: Dictionary) -> Dictionary:
	var result := {
		"city_id": str(city.get("id", "")),
		"owner_scope": "enemy",
		"enemy_baseline": true,
		"enemy_research_effect": false,
		"player_completed_tech_lookup": false,
		"masked": true,
		"siege_grade_label": "정보 부족",
		"source": "city_defense_garrison_baseline",
	}
	var city_id := str(result.get("city_id", ""))
	if city_id.is_empty() or not _is_city_owned_by_enemy_mvp(city_id):
		result["reason"] = "not_enemy_city"
		return result
	var defense_baseline := _get_enemy_city_defense_baseline_mvp(city)
	if bool(defense_baseline.get("masked", true)):
		result["reason"] = defense_baseline.get("reason", "insufficient_intel")
		return result
	result["masked"] = false
	var siege_score := int(defense_baseline.get("battle_grade_score", 0))
	if str(city.get("type", "")).to_lower().find("fortress") >= 0:
		siege_score += 2
	result["siege_grade_score"] = siege_score
	result["siege_grade_label"] = _format_enemy_city_baseline_grade_label_mvp(siege_score)
	result["revealed_fields"] = defense_baseline.get("revealed_fields", [])
	return result


func _get_enemy_owned_city_count_mvp(faction_id: String) -> int:
	if faction_id.is_empty() or faction_id == _get_current_player_faction_id():
		return 0
	var count := 0
	for city_id_variant in CITY_HUD_DATA.keys():
		var city_id := str(city_id_variant)
		var city_data := _get_city_hud_entry(city_id)
		if city_data.is_empty():
			continue
		if _get_city_owner_faction_id(city_data) == faction_id:
			count += 1
	return count


func _get_enemy_spy_resistance_baseline_mvp(city: Dictionary) -> Dictionary:
	var result := {
		"city_id": str(city.get("id", "")),
		"owner_scope": "enemy",
		"enemy_baseline": true,
		"enemy_research_effect": false,
		"player_completed_tech_lookup": false,
		"masked": true,
		"spy_resistance_pct": 0.0,
		"detection_bonus_pct": 0.0,
		"counter_spy_pct": 0.0,
		"baseline_grade_label": "정보 부족",
		"source": "city_security_loyalty_baseline",
	}
	var city_id := str(result.get("city_id", ""))
	if city_id.is_empty() or not _is_city_owned_by_enemy_mvp(city_id):
		result["reason"] = "not_enemy_city"
		return result
	var intel_entry := _get_city_intel_entry_for_ui(city_id)
	if intel_entry.is_empty():
		result["reason"] = "insufficient_intel"
		return result
	var fields := _get_city_intel_fields_for_ui(intel_entry)
	var payload := _get_city_intel_payload_for_ui(intel_entry)
	var revealed_fields := _get_enemy_intel_revealed_field_ids_for_ui(fields, payload)
	if not revealed_fields.has("troops") and not revealed_fields.has("troops_estimated") and not revealed_fields.has("loyalty"):
		result["reason"] = "insufficient_intel"
		return result
	result["masked"] = false
	var security_score := _ensure_spy_controller().get_city_security_score(city_id)
	var loyalty_score := _get_city_loyalty_value(city)
	var baseline_score := 2
	if security_score >= 90:
		baseline_score += 3
	elif security_score >= 70:
		baseline_score += 2
	elif security_score >= 50:
		baseline_score += 1
	if loyalty_score >= 90:
		baseline_score += 2
	elif loyalty_score >= 70:
		baseline_score += 1
	result["spy_resistance_pct"] = minf(0.12, float(baseline_score) * 0.01)
	result["detection_bonus_pct"] = minf(0.10, float(baseline_score) * 0.01)
	result["counter_spy_pct"] = minf(0.08, maxf(0.0, float(baseline_score - 1)) * 0.01)
	result["baseline_grade_label"] = _format_enemy_city_baseline_grade_label_mvp(baseline_score)
	result["revealed_fields"] = revealed_fields
	return result


func _get_enemy_city_intel_resistance_baseline_mvp(city: Dictionary) -> Dictionary:
	var result := _get_enemy_spy_resistance_baseline_mvp(city)
	result["intel_visibility_resistance_pct"] = 0.0
	if bool(result.get("masked", true)):
		return result
	var security_score := _ensure_spy_controller().get_city_security_score(str(result.get("city_id", "")))
	if security_score >= 90:
		result["intel_visibility_resistance_pct"] = 0.08
	elif security_score >= 70:
		result["intel_visibility_resistance_pct"] = 0.05
	else:
		result["intel_visibility_resistance_pct"] = 0.02
	return result


func _format_spy_action_candidates_for_ui(city_marker: WorldMapCityMarker) -> String:
	return _ensure_spy_presenter().format_action_candidates(city_marker)


func _format_spy_check_status_for_ui(check: Dictionary) -> String:
	return DiplomacySpyHelpers.format_spy_check_status_for_ui(check)


func _format_recent_spy_result_for_ui(city_id: String) -> String:
	return _ensure_spy_presenter().format_recent_result(city_id)


func _format_spy_action_policy_display_for_ui(city_marker: WorldMapCityMarker) -> String:
	return _ensure_spy_presenter().format_action_policy(city_marker)


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
	if target_faction_id.is_empty() or target_faction_id == _get_current_player_faction_id():
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
	return _ensure_spy_presenter().format_action_hint(validation_map)


func _get_diplomacy_spy_tab_label(tab_id: String) -> String:
	return DiplomacySpyHelpers.get_diplomacy_spy_tab_label(tab_id, DIPLOMACY_SPY_TAB_SPY)


func _refresh_city_detail_tab_styles() -> void:
	var route := _ensure_city_detail_presentation_controller().refresh_tab_styles(
		_unified_primary_tab,
		_selected_city_detail_tab,
		UNIFIED_PANEL_TAB_DIPLOMACY_SPY,
		UNIFIED_PANEL_TAB_TRADE
	)
	if route == "refresh_chrome":
		_refresh_unified_panel_chrome()


func _set_city_detail_tab_active(button: Button, is_active: bool) -> void:
	if button == null:
		_warn_missing_unified_panel_chrome("CityDetailTabButton")
		return
	_ensure_city_detail_presentation_controller().set_tab_active(button, is_active)


func _extract_resource_group(resource_summary: String, resource_names: Array[String]) -> String:
	return EconomyCityHelpers.extract_resource_group(resource_summary, resource_names)


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
	return EconomyCityHelpers.format_internal_trade_lead_display(_connected_player_city_ids)


func _format_internal_trade_policy_display(connected_player_city_ids: Array[String]) -> String:
	return EconomyCityHelpers.format_internal_trade_policy_display(connected_player_city_ids)


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
	return DiplomacySpyHelpers.format_faction_relation_status_for_ui(status)


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
	return EconomyCityHelpers.format_external_trade_lead_display(_candidate_city_ids)


func _format_external_trade_policy_display(candidate_city_ids: Array[String]) -> String:
	return EconomyCityHelpers.format_external_trade_policy_display(candidate_city_ids)




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
			_ensure_trade_presenter().format_manual_trade_nonzero_preview_summary(applied),
		]
	return "최근 재상 대외무역\n이번 턴 적용된 자동무역 없음"






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
	return EconomyCityHelpers.format_supply_role_label(role_id)


func _format_supply_status_label(status_id: String) -> String:
	return EconomyCityHelpers.format_supply_status_label(status_id)


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
	return UIFormatterHelpers.format_revolt_risk_label(risk, REVOLT_RISK_DANGER, REVOLT_RISK_WARNING)


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
	return EconomyCityHelpers.get_trade_display_totals(result)


func _format_trade_result_summary(result: Dictionary) -> String:
	if result.is_empty():
		return "■ 무역\n최근 무역 결과 없음"
	return "■ 무역\n최근 세력간 무역: 루트 %d개\n%s" % [
		int(result.get("route_count", 0)),
		_format_trade_resource_totals_display(_get_trade_display_totals(result)),
	]


func _format_trade_resource_totals_display(totals: Dictionary) -> String:
	return EconomyCityHelpers.format_trade_resource_totals_display(totals, RESOURCE_LABELS)


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
	return DefenseBattleHelpers.format_troop_move_button_text(preview)


func _format_troop_move_reason(result: Dictionary) -> String:
	return DefenseBattleHelpers.format_troop_move_reason(result)


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
	_ensure_hud_controller().setup_world_status_panel(
		Callable(self, "_request_hud_panel_position_mvp"),
		LEFT_WORLD_STATUS_PANEL_TOP_LEFT,
		LEFT_WORLD_STATUS_PANEL_SIZE
	)
	_setup_pending_invasion_choice_ui()
	_setup_post_battle_result_ui()
	_setup_save_management_ui()
	_ensure_left_world_status_help_buttons()


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


func _lock_left_world_status_panel_anchor() -> void:
	_ensure_hud_controller().setup_world_status_panel(
		Callable(self, "_request_hud_panel_position_mvp"),
		LEFT_WORLD_STATUS_PANEL_TOP_LEFT,
		LEFT_WORLD_STATUS_PANEL_SIZE
	)


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
	var treatment_row := HBoxContainer.new()
	treatment_row.add_theme_constant_override("separation", 6)
	content.add_child(treatment_row)
	_wounded_normal_treatment_button = Button.new()
	_wounded_normal_treatment_button.text = "일반 치료 (3개월)"
	_wounded_normal_treatment_button.disabled = true
	treatment_row.add_child(_wounded_normal_treatment_button)
	_wounded_fast_treatment_button = Button.new()
	_wounded_fast_treatment_button.text = "집중 치료"
	_wounded_fast_treatment_button.pressed.connect(_on_fast_wounded_treatment_pressed)
	treatment_row.add_child(_wounded_fast_treatment_button)
	_wounded_treatment_hint_label = Label.new()
	_wounded_treatment_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_wounded_treatment_hint_label.add_theme_font_size_override("font_size", 10)
	content.add_child(_wounded_treatment_hint_label)
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
	_ensure_shared_ui_controller().ensure_help_modal()


func _show_worldmap_help_modal(topic_id: String) -> void:
	_ensure_shared_ui_controller().show_help_modal(_get_worldmap_help_content(topic_id))


func _hide_worldmap_help_modal() -> void:
	_ensure_shared_ui_controller().hide_help_modal()


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


func _refresh_left_world_status_panel() -> void:
	_ensure_worldmap_runtime_state_defaults()
	var national_loyalty := int(_player_state.get("national_loyalty", 0))
	var tax_level := _normalize_tax_level(_player_state.get("tax_level", 0))
	var public_order := int(_player_state.get("public_order", 0))
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
	var national_bonus_display := _format_domestic_tech_national_policy_bonus_lines_mvp()
	national_bonus_display.append_array(_format_domestic_tech_diplomacy_spy_bonus_lines_mvp())
	var last_trade_result: Dictionary = _player_state.get("last_inter_faction_trade_result", {})
	var pending_invasion_event := _get_pending_invasion_event_mvp()
	city_info_panel.set_pending_invasion_event(pending_invasion_event)
	_refresh_city_info_attack_action_state(selected_city_id)
	var world_status_hint := _format_invasion_status_text(pending_invasion_event)
	if world_status_hint.is_empty():
		world_status_hint = _format_enemy_faction_turn_result_hint(_player_state.get("last_enemy_faction_turn_result", {}))
	if world_status_hint.is_empty():
		world_status_hint = _format_last_turn_resolution_hint_mvp()
	_refresh_pending_invasion_choice_ui(pending_invasion_event)
	_ensure_hud_controller().refresh_world_status({
		"eyebrow": "플레이어 국가 · %s" % _format_faction_label(_get_current_player_faction_id()),
		"calendar": "%s · %s · %s" % [str(_player_state.get("turn_label", "제 1턴")), str(_player_state.get("year_label", "154년 봄 1턴")), str(_player_state.get("current_phase_label", "아군 턴"))],
		"nation": "수도: %s" % _format_city_name_by_id(str(_player_state.get("capital_city_id", _player_state.get("origin_city_id", ""))), "미설정"),
		"power": "국가충성도 %d · %s" % [national_loyalty, _get_loyalty_status(national_loyalty)],
		"national_loyalty": national_loyalty,
		"tax": "세금 수준 %d · %s" % [tax_level, _get_tax_description(tax_level)],
		"tax_level": tax_level,
		"public_order": public_order,
		"chancellor_id": chancellor_id,
		"chancellor_data": chancellor_data,
		"chancellor_name": chancellor_name,
		"chancellor_stats": _format_chancellor_type_summary(chancellor_data) if not chancellor_data.is_empty() else "",
		"policy_id": policy_id,
		"chancellor_policy_description": "효과: %s\n정책: %s" % [_get_chancellor_effect_text(chancellor_data), str(policy_data.get("description", "재상 정책 설명 준비 중"))],
		"national_bonus_lines": national_bonus_display,
		"external_trade": _format_inter_faction_trade_summary(last_trade_result) if not last_trade_result.is_empty() else "",
		"world_status_hint": world_status_hint,
		"turn_end_disabled": _enemy_turn_mvp_pending or not pending_invasion_event.is_empty() or _has_terminal_korea_outcome_mvp(),
		"save_status": _save_management_status,
		"warehouse_rows": _build_warehouse_hud_rows(),
	})
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
	if not _player_state.has("turn_resolution_state") or not (_player_state["turn_resolution_state"] is Dictionary):
		_player_state["turn_resolution_state"] = {}
	_player_state["completed_turn_resolution_ids"] = TurnOutcomeRulesScript.normalize_string_array(_player_state.get("completed_turn_resolution_ids", []))
	if not _player_state.has("last_turn_resolution_result") or not (_player_state["last_turn_resolution_result"] is Dictionary):
		_player_state["last_turn_resolution_result"] = {}
	if not _player_state.has("last_ai_domestic_apply_turn"):
		_player_state["last_ai_domestic_apply_turn"] = 0
	_player_state["last_ai_domestic_apply_turn"] = maxi(0, int(_player_state.get("last_ai_domestic_apply_turn", 0)))
	if not _player_state.has("last_ai_domestic_apply_result") or not (_player_state["last_ai_domestic_apply_result"] is Dictionary):
		_player_state["last_ai_domestic_apply_result"] = {}
	if not _player_state.has("game_outcome") or not (_player_state["game_outcome"] is Dictionary):
		_player_state["game_outcome"] = {}
	if not _player_state.has("korea_unification_victory"):
		_player_state["korea_unification_victory"] = false
	if not _player_state.has("korea_player_defeat"):
		_player_state["korea_player_defeat"] = false
	_normalize_domestic_tech_state_mvp()
	if not _player_state.has("pending_invasion_event") or not (_player_state["pending_invasion_event"] is Dictionary):
		_player_state["pending_invasion_event"] = {}
	if not _player_state.has("pending_battle_context") or not (_player_state["pending_battle_context"] is Dictionary):
		_player_state["pending_battle_context"] = {}
	if not _player_state.has("enemy_invasion_roll_turn"):
		_player_state["enemy_invasion_roll_turn"] = 0
	_player_state["enemy_invasion_roll_turn"] = maxi(0, int(_player_state.get("enemy_invasion_roll_turn", 0)))
	if not _player_state.has("t03_global_war_cooldown_until_turn"):
		_player_state["t03_global_war_cooldown_until_turn"] = 0
	_player_state["t03_global_war_cooldown_until_turn"] = maxi(0, int(_player_state.get("t03_global_war_cooldown_until_turn", 0)))
	if not _player_state.has("t03_automatic_battle_reports") or not (_player_state["t03_automatic_battle_reports"] is Array):
		_player_state["t03_automatic_battle_reports"] = []
	if not _player_state.has("t03_acknowledged_report_ids") or not (_player_state["t03_acknowledged_report_ids"] is Array):
		_player_state["t03_acknowledged_report_ids"] = []
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
	_ensure_diplomacy_controller()._normalize_diplomacy_action_state_from_player_state()
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
	return _ensure_world_calendar_service().format_label(turn_number)


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
	return DefenseBattleHelpers.limit_invasion_result_lines(lines, limit)


func _on_ally_turn_end_pressed() -> void:
	if _has_terminal_korea_outcome_mvp():
		_set_save_management_status("게임이 종료되었습니다. 결과 화면에서 새 게임을 선택하십시오.")
		_present_t05_outcome_if_needed()
		return
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
	var turn_number := maxi(1, int(_player_state.get("turn_number", 1)))
	var transaction_id := TurnOutcomeRulesScript.make_turn_resolution_id(turn_number, _get_current_player_faction_id())
	if TurnOutcomeRulesScript.normalize_string_array(_player_state.get("completed_turn_resolution_ids", [])).has(transaction_id):
		_set_save_management_status("이미 완료된 턴입니다.")
		return
	_player_state["turn_resolution_state"] = {
		"transaction_id": transaction_id,
		"source_turn": turn_number,
		"stage": "enemy_actions",
		"started": true,
	}
	_play_worldmap_sfx("turn_end")
	_domestic_turn_apply_pending = true
	_player_state["domestic_apply_pending"] = true
	_set_turn_phase(TURN_PHASE_ENEMY)
	_checkpoint_worldmap_state_mvp()
	_run_enemy_turn_mvp()


func _run_enemy_turn_mvp() -> void:
	if _has_terminal_korea_outcome_mvp():
		_enemy_turn_mvp_pending = false
		_domestic_turn_apply_pending = false
		_player_state["domestic_apply_pending"] = false
		_present_t05_outcome_if_needed()
		return
	if _enemy_turn_mvp_pending:
		_set_save_management_status("적군 턴 진행 중...")
		return
	print("[WorldMap] Enemy turn MVP hook reached. Enemy faction reinforcement and invasion event roll are running.")
	_enemy_turn_mvp_pending = true
	_set_save_management_status("적군 턴 진행 중...")
	var turn_number := maxi(1, int(_player_state.get("turn_number", 1)))
	var turn_resolution_state := _get_or_restore_turn_resolution_state_mvp(turn_number)
	turn_resolution_state["stage"] = "enemy_actions"
	_player_state["turn_resolution_state"] = turn_resolution_state
	var ai_domestic_result := _apply_ai_city_production_for_world_turn_mvp()
	var enemy_turn_already_processed := int(_player_state.get("last_enemy_faction_turn_processed_turn", 0)) == turn_number
	var enemy_turn_result := _process_enemy_faction_turn_mvp()
	var invasion_event := {}
	if not enemy_turn_already_processed:
		invasion_event = _roll_enemy_invasion_event_mvp()
		_attach_enemy_invasion_event_to_enemy_turn_result(invasion_event)
	if bool(invasion_event.get("resolved_automatically", false)):
		_set_save_management_status("AI 세력전 정산 완료 · 다음 아군 턴에 결과 보고")
	elif not invasion_event.is_empty():
		_set_save_management_status(_format_invasion_status_text(invasion_event))
	elif not enemy_turn_result.is_empty():
		_set_save_management_status(str(enemy_turn_result.get("summary", "이번 턴 적 행동 처리 완료")))
	turn_resolution_state = _get_or_restore_turn_resolution_state_mvp(turn_number)
	turn_resolution_state["stage"] = "enemy_actions_complete"
	turn_resolution_state["ai_domestic_result"] = ai_domestic_result.duplicate(true)
	turn_resolution_state["enemy_turn_result"] = enemy_turn_result.duplicate(true)
	_player_state["turn_resolution_state"] = turn_resolution_state
	_checkpoint_worldmap_state_mvp()
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
	var source_turn := maxi(1, int(_player_state.get("turn_number", 1)))
	var turn_resolution_state := _get_or_restore_turn_resolution_state_mvp(source_turn)
	var transaction_id := str(turn_resolution_state.get("transaction_id", TurnOutcomeRulesScript.make_turn_resolution_id(source_turn, _get_current_player_faction_id())))
	var completed_ids := TurnOutcomeRulesScript.normalize_string_array(_player_state.get("completed_turn_resolution_ids", []))
	if completed_ids.has(transaction_id):
		_domestic_turn_apply_pending = false
		_player_state["domestic_apply_pending"] = false
		_set_turn_phase(TURN_PHASE_PLAYER)
		_checkpoint_worldmap_state_mvp()
		return
	turn_resolution_state["stage"] = "domestic_resolution"
	_player_state["turn_resolution_state"] = turn_resolution_state
	var domestic_summary := ""
	if _domestic_turn_apply_pending:
		domestic_summary = _apply_domestic_turn_mvp()
		_domestic_turn_apply_pending = false
		_player_state["domestic_apply_pending"] = false
	_advance_world_turn_mvp()
	_set_turn_phase(TURN_PHASE_PLAYER)
	_evaluate_korea_mvp_outcome_mvp()
	var next_turn := maxi(1, int(_player_state.get("turn_number", source_turn + 1)))
	var enemy_result: Dictionary = _player_state.get("last_enemy_faction_turn_result", {}) if _player_state.get("last_enemy_faction_turn_result", {}) is Dictionary else {}
	var ai_domestic_result: Dictionary = _player_state.get("last_ai_domestic_apply_result", {}) if _player_state.get("last_ai_domestic_apply_result", {}) is Dictionary else {}
	var turn_result := {
		"transaction_id": transaction_id,
		"source_turn": source_turn,
		"next_turn": next_turn,
		"domestic_summary": domestic_summary,
		"enemy_summary": str(enemy_result.get("summary", "")),
		"ai_city_production_count": int(ai_domestic_result.get("city_count", 0)),
		"outcome": str((_player_state.get("game_outcome", {}) as Dictionary).get("status", TurnOutcomeRulesScript.OUTCOME_ACTIVE)),
	}
	_player_state["last_turn_resolution_result"] = turn_result
	completed_ids.append(transaction_id)
	_player_state["completed_turn_resolution_ids"] = completed_ids
	_player_state["turn_resolution_state"] = {
		"transaction_id": transaction_id,
		"source_turn": source_turn,
		"stage": "complete",
		"completed": true,
		"next_turn": next_turn,
	}
	var pending_invasion_event := _get_pending_invasion_event_mvp()
	if not pending_invasion_event.is_empty():
		_set_save_management_status(_format_invasion_status_text(pending_invasion_event))
	elif domestic_summary.is_empty():
		_set_save_management_status("다음 아군 턴 시작")
	else:
		_set_save_management_status("내정 적용 완료 · %s" % domestic_summary)
	_refresh_left_world_status_panel()
	_checkpoint_worldmap_state_mvp()
	if _has_terminal_korea_outcome_mvp():
		call_deferred("_present_t05_outcome_if_needed")
		return
	call_deferred("_try_present_next_t03_battle_report")


func _get_or_restore_turn_resolution_state_mvp(turn_number: int) -> Dictionary:
	var state: Dictionary = _player_state.get("turn_resolution_state", {}) if _player_state.get("turn_resolution_state", {}) is Dictionary else {}
	var expected_id := TurnOutcomeRulesScript.make_turn_resolution_id(turn_number, _get_current_player_faction_id())
	if str(state.get("transaction_id", "")) != expected_id:
		state = {
			"transaction_id": expected_id,
			"source_turn": maxi(1, turn_number),
			"stage": "enemy_actions",
			"started": true,
		}
	return state


func _roll_enemy_invasion_event_mvp(roll_value: float = -1.0, candidate_index: int = -1) -> Dictionary:
	_ensure_worldmap_runtime_state_defaults()
	if _has_pending_invasion_event_mvp() or not _get_pending_battle_context_mvp().is_empty():
		return {}
	var turn_number := maxi(1, int(_player_state.get("turn_number", 1)))
	if turn_number <= T03_PEACE_GRACE_TURNS:
		_player_state["enemy_invasion_roll_turn"] = turn_number
		return {}
	if turn_number <= int(_player_state.get("t03_global_war_cooldown_until_turn", 0)):
		_player_state["enemy_invasion_roll_turn"] = turn_number
		return {}
	if _is_manual_qa_invasion_grace_turn_active_mvp():
		_player_state["enemy_invasion_roll_turn"] = turn_number
		return {}
	if int(_player_state.get("enemy_invasion_roll_turn", 0)) == turn_number:
		return {}
	_player_state["enemy_invasion_roll_turn"] = turn_number
	var candidate_pairs := _get_enemy_invasion_pairs_mvp()
	if candidate_pairs.is_empty():
		print("[WorldMap] T03: no eligible Korea invasion pairs.")
		return {}
	var roll := roll_value if roll_value >= 0.0 else randf()
	if roll >= ENEMY_INVASION_CHANCE:
		print("[WorldMap] Enemy invasion MVP: no invasion this turn. roll=%.3f" % roll)
		return {}
	var pair_index := candidate_index if candidate_index >= 0 else randi() % candidate_pairs.size()
	pair_index = clampi(pair_index, 0, candidate_pairs.size() - 1)
	var selected_pair := candidate_pairs[pair_index] as Dictionary
	var event := _create_pending_invasion_event_mvp(
		str(selected_pair.get("attacker_city_id", "")),
		str(selected_pair.get("defender_city_id", ""))
	)
	if event.is_empty():
		return {}
	_player_state["t03_global_war_cooldown_until_turn"] = turn_number + T03_GLOBAL_WAR_COOLDOWN_TURNS
	if str(event.get("defender_owner", "")) != _get_current_player_faction_id():
		var result := _resolve_t03_automatic_invasion(event)
		if not result.is_empty():
			event["resolved_automatically"] = true
			event["result_id"] = str(result.get("result_id", ""))
	return event


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
	if faction_id.is_empty() or faction_id == _get_current_player_faction_id():
		return city_ids
	for city_id in _get_worldmap_city_ids_for_enemy_turn_mvp():
		if _get_safe_enemy_owner_faction_id_for_turn_mvp(city_id) != faction_id:
			continue
		if not city_ids.has(city_id):
			city_ids.append(city_id)
	city_ids.sort()
	return city_ids


func _get_enemy_faction_personality_seed(faction_id: String) -> Dictionary:
	return _ensure_enemy_warfare_service().get_personality_seed(faction_id)


func _get_enemy_faction_personality_profile_id(faction_id: String) -> String:
	return _ensure_enemy_warfare_service().get_personality_profile_id(faction_id)


func _get_enemy_faction_personality_label(faction_id: String) -> String:
	return _ensure_enemy_warfare_service().get_personality_label(faction_id)


func _get_enemy_faction_behavior_weight(faction_id: String, key: String, default_value: float = 1.0) -> float:
	return _ensure_enemy_warfare_service().get_behavior_weight(faction_id, key, default_value)


func _get_enemy_faction_personality_metadata(faction_id: String) -> Dictionary:
	return _ensure_enemy_warfare_service().get_personality_metadata(faction_id)


func _get_enemy_faction_strategic_goal_seed(faction_id: String) -> Dictionary:
	return _ensure_enemy_warfare_service().get_goal_seed(faction_id)


func _get_enemy_faction_goal_id(faction_id: String) -> String:
	return _ensure_enemy_warfare_service().get_goal_id(faction_id)


func _get_enemy_faction_goal_label(faction_id: String) -> String:
	return _ensure_enemy_warfare_service().get_goal_label(faction_id)


func _get_enemy_faction_goal_pressure(faction_id: String) -> String:
	return _ensure_enemy_warfare_service().get_goal_pressure(faction_id)


func _get_enemy_faction_goal_weight(faction_id: String) -> float:
	return _ensure_enemy_warfare_service().get_goal_weight(faction_id)


func _get_enemy_goal_target_city_ids(faction_id: String) -> Array[String]:
	return _ensure_enemy_warfare_service().get_goal_target_city_ids(faction_id)


func _is_city_preferred_by_enemy_goal(faction_id: String, city_id: String) -> bool:
	return _ensure_enemy_warfare_service().is_city_preferred_by_goal(faction_id, city_id)


func _is_city_adjacent_to_enemy_goal_target(faction_id: String, city_id: String) -> bool:
	return _ensure_enemy_warfare_service().is_city_adjacent_to_goal_target(faction_id, city_id)


func _get_enemy_faction_goal_metadata(faction_id: String) -> Dictionary:
	return _ensure_enemy_warfare_service().get_goal_metadata(faction_id)


func _get_enemy_goal_label_display_part(goal_id: String, goal_label: String) -> String:
	if goal_id.is_empty() or goal_id == "hold_position" or goal_label.is_empty():
		return ""
	return "목표: %s" % goal_label


func _normalize_enemy_pressure_type_mvp(raw_pressure_type: String, faction_id: String = "") -> String:
	return _ensure_enemy_warfare_service().normalize_pressure_type(raw_pressure_type, faction_id)


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
	return _ensure_enemy_warfare_service().should_skip_pressure_plan()


func _build_enemy_pressure_plan_candidates_mvp() -> Array[Dictionary]:
	return _ensure_enemy_warfare_service().build_pressure_plan_candidates()


func _build_enemy_pressure_plan_candidate_for_faction_mvp(faction_id: String) -> Dictionary:
	return _ensure_enemy_warfare_service().build_pressure_plan_candidate(faction_id)


func _get_enemy_pressure_plan_target_city_ids_for_source_mvp(faction_id: String, source_city_id: String, pressure_type: String) -> Array[String]:
	return _ensure_enemy_warfare_service().get_pressure_targets(faction_id, source_city_id, pressure_type)


func _score_enemy_pressure_plan_candidate_mvp(candidate: Dictionary) -> float:
	return _ensure_enemy_warfare_service().score_pressure_plan_candidate(candidate)


func _sort_enemy_pressure_plan_candidates_mvp(left: Dictionary, right: Dictionary) -> bool:
	return _ensure_enemy_warfare_service().sort_pressure_plan_candidates(left, right)


func _pick_enemy_pressure_plan_mvp() -> Dictionary:
	return _ensure_enemy_warfare_service().pick_pressure_plan()


func _normalize_enemy_pressure_plan_result_mvp(raw_result: Variant) -> Dictionary:
	return _ensure_enemy_warfare_service().normalize_pressure_plan(raw_result)


func _get_enemy_pressure_plan_for_scoring_mvp() -> Dictionary:
	return _ensure_enemy_warfare_service().get_pressure_plan_for_scoring()


func _is_enemy_pressure_plan_target_city_mvp(faction_id: String, city_id: String) -> bool:
	return _ensure_enemy_warfare_service().is_pressure_plan_target_city(faction_id, city_id)


func _get_enemy_pressure_plan_score_bonus_mvp(faction_id: String, city_id: String, purpose: String) -> float:
	return _ensure_enemy_warfare_service().get_pressure_plan_score_bonus(faction_id, city_id, purpose)


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
	if owner_id.is_empty() or owner_id == _get_current_player_faction_id():
		return ""
	return owner_id


func _is_enemy_frontline_city_for_faction(city_id: String, faction_id: String) -> bool:
	return _ensure_enemy_warfare_service().is_enemy_frontline_city(city_id, faction_id)


func _find_enemy_frontline_city_for_faction(faction_id: String) -> String:
	return _ensure_enemy_warfare_service().find_enemy_frontline_city(faction_id)


func _pick_enemy_city_for_turn_action(faction_id: String) -> String:
	return _ensure_enemy_warfare_service().pick_enemy_city_for_turn_action(faction_id)


func _score_enemy_reinforcement_city_for_personality(faction_id: String, city_id: String) -> int:
	return _ensure_enemy_warfare_service().score_reinforcement_city(faction_id, city_id)


func _get_enemy_faction_chancellor_id(faction_id: String) -> String:
	if faction_id.is_empty() or faction_id == _get_current_player_faction_id():
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
	if faction_id.is_empty() or faction_id == _get_current_player_faction_id() or city_id.is_empty():
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
	if _is_manual_qa_invasion_grace_turn_active_mvp():
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
		if faction_id.is_empty() or faction_id == _get_current_player_faction_id():
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
	if faction_a.is_empty() or faction_b.is_empty() or faction_a == _get_current_player_faction_id() or faction_b == _get_current_player_faction_id() or faction_a == faction_b:
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
		if not faction_id.is_empty() and faction_id != _get_current_player_faction_id():
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
			if faction_a.is_empty() or faction_b.is_empty() or faction_a == _get_current_player_faction_id() or faction_b == _get_current_player_faction_id() or faction_a == faction_b:
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
			if faction_id.is_empty() or faction_id == _get_current_player_faction_id() or attacker_city_id.is_empty() or target_city_id.is_empty():
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
	var resolved_automatically := bool(invasion_event.get("resolved_automatically", false))
	enemy_turn_result["pending_invasion_created"] = not invasion_event.is_empty() and not resolved_automatically
	enemy_turn_result["automatic_battle_resolved"] = resolved_automatically
	if not invasion_event.is_empty() and not resolved_automatically:
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
	if bool(result.get("automatic_battle_resolved", false)):
		invasion_summary = "AI 세력전 결과 보고 대기"
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
	return _ensure_enemy_warfare_service().get_invasion_pairs()


func _is_city_owned_by_player_mvp(city_id: String) -> bool:
	var city_marker := _city_markers_by_id.get(city_id) as WorldMapCityMarker
	if city_marker != null:
		return city_marker.owner_faction_id == _get_current_player_faction_id()
	var city_data := _get_city_hud_entry(city_id)
	return str(city_data.get("owner", city_data.get("nation", ""))) == _get_current_player_faction_id()


func _is_city_owned_by_enemy_mvp(city_id: String) -> bool:
	var city_marker := _city_markers_by_id.get(city_id) as WorldMapCityMarker
	if city_marker != null:
		return not city_marker.owner_faction_id.is_empty() and city_marker.owner_faction_id != _get_current_player_faction_id()
	var city_data := _get_city_hud_entry(city_id)
	var owner_id := str(city_data.get("owner", city_data.get("nation", "")))
	return not owner_id.is_empty() and owner_id != _get_current_player_faction_id()


func _is_city_owner_consistent_for_enemy_invasion_mvp(city_id: String) -> bool:
	return _ensure_enemy_warfare_service().is_city_owner_consistent(city_id)


func _is_enemy_invasion_pair_eligible_mvp(attacker_city_id: String, defender_city_id: String) -> bool:
	return _ensure_enemy_warfare_service().is_invasion_pair_eligible(attacker_city_id, defender_city_id)


func _score_enemy_invasion_pair_mvp(attacker_city_id: String, defender_city_id: String) -> int:
	return _ensure_enemy_warfare_service().score_invasion_pair(attacker_city_id, defender_city_id)


func _sort_enemy_invasion_pairs_mvp(left: Dictionary, right: Dictionary) -> bool:
	return _ensure_enemy_warfare_service().sort_invasion_pairs(left, right)


func _get_city_troops_for_enemy_invasion_mvp(city_id: String) -> int:
	return _ensure_enemy_warfare_service().get_city_troops_for_invasion(city_id)


func _is_player_frontline_city_for_enemy_invasion_mvp(city_id: String) -> bool:
	return _ensure_enemy_warfare_service().is_player_frontline_city_for_invasion(city_id)


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


func _get_city_route_type_between_mvp(from_city_id: String, to_city_id: String) -> String:
	if from_city_id.is_empty() or to_city_id.is_empty():
		return ""
	var from_marker := _city_markers_by_id.get(from_city_id) as WorldMapCityMarker
	if from_marker != null and from_marker.route_types.has(to_city_id):
		return str(from_marker.route_types.get(to_city_id, ""))
	var to_marker := _city_markers_by_id.get(to_city_id) as WorldMapCityMarker
	if to_marker != null and to_marker.route_types.has(from_city_id):
		return str(to_marker.route_types.get(from_city_id, ""))
	if _is_city_coastal_for_city_tech(from_city_id) and _is_city_coastal_for_city_tech(to_city_id):
		return "sea"
	return "land"


func _is_naval_attack_route_mvp(source_city_id: String, target_city_id: String) -> bool:
	var route_type := _get_city_route_type_between_mvp(source_city_id, target_city_id).to_lower()
	return route_type == "sea" or route_type == "naval" or route_type == "coastal"


func _is_siege_attack_target_mvp(target_city_id: String) -> bool:
	if target_city_id.is_empty():
		return false
	var city_data := _get_city_hud_entry(target_city_id)
	if city_data.is_empty():
		return false
	if str(city_data.get("type", "")).to_lower().find("fortress") >= 0:
		return true
	return _get_city_numeric_rating(city_data, "defense", 0) >= 4


func _get_player_naval_siege_attack_unlock_block_reason_mvp(source_city_id: String, target_city_id: String) -> String:
	if source_city_id.is_empty() or target_city_id.is_empty():
		return ""
	if _is_naval_attack_route_mvp(source_city_id, target_city_id) and not _is_player_ship_unlocked_by_domestic_tech_mvp("warship", source_city_id):
		return "해상/연안 공격에는 출발 도시의 전투선 건조 연구가 필요합니다."
	if _is_siege_attack_target_mvp(target_city_id) and not _is_player_siege_unlocked_by_domestic_tech_mvp("siege_unit", source_city_id):
		return "요새/고방어 도시 공격에는 출발 도시의 공성 부대 연구가 필요합니다."
	return ""


func _get_player_attack_block_reason(target_city_id: String) -> String:
	if _has_terminal_korea_outcome_mvp():
		return "게임이 종료되어 공격할 수 없습니다."
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
	var unlock_block_reason := _get_player_naval_siege_attack_unlock_block_reason_mvp(source_city_id, target_city_id)
	if not unlock_block_reason.is_empty():
		return unlock_block_reason
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
	if _has_terminal_korea_outcome_mvp():
		_set_save_management_status("게임 종료 후에는 새 침공을 시작할 수 없습니다.")
		_present_t05_outcome_if_needed()
		return
	if _ensure_camera_controller().is_battle_entry_handoff_in_progress():
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
	var payload := _ensure_player_attack_deployment_service().build_payload(source_city_id, target_city_id, mode)
	if not payload.is_empty():
		payload["source_city_name"] = _format_city_name_by_id(source_city_id, "아군 도시")
		payload["target_city_name"] = _format_city_name_by_id(target_city_id, "적 도시")
	return payload


func _get_deployable_player_heroes_for_city(city_id: String) -> Array[Dictionary]:
	return _ensure_player_attack_deployment_service().get_deployable_heroes(city_id)


func _confirm_player_attack_deployment(deployment: Dictionary) -> void:
	if _ensure_camera_controller().is_battle_entry_handoff_in_progress():
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
	var battle_context := _build_player_attack_battle_context(source_city_id, target_city_id, str(deployment.get("mode", "manual")), selected_hero_ids, troop_allocation, supply_cost)
	if battle_context.is_empty():
		_set_save_management_status("공격 전투 데이터 생성 실패")
		_refresh_left_world_status_panel()
		return
	battle_context["attacker_total_allocated_troops"] = total_allocated_troops
	battle_context["attacker_source_city_id"] = source_city_id
	battle_context["transaction_id"] = "%s-%d-%d" % [_get_current_player_faction_id(), Time.get_unix_time_from_system(), Time.get_ticks_msec()]
	battle_context["scenario_id"] = str(_player_state.get("active_scenario_id", "korea_mvp"))
	battle_context["player_faction_id"] = _get_current_player_faction_id()
	battle_context["result_return_destination"] = "res://WorldMap.tscn"
	var departure := _ensure_player_attack_deployment_service().apply_departure(battle_context, selected_hero_ids, supply_cost)
	if not bool(departure.get("ok", false)):
		_set_save_management_status(_format_player_attack_deployment_error(departure))
		_refresh_left_world_status_panel()
		return
	battle_context = (departure.get("context", {}) as Dictionary).duplicate(true)
	_rebuild_occupation_runtime_indexes_mvp()
	_refresh_city_hud_data_bindings()
	_refresh_left_world_status_panel()
	if _player_attack_deployment_panel != null:
		if _player_attack_deployment_panel.has_method("close"):
			_player_attack_deployment_panel.call("close")
	_set_pending_battle_context_mvp(battle_context)
	var state_snapshot := _serialize_worldmap_state()
	var snapshot_player_state: Dictionary = state_snapshot.get("player_state", {}).duplicate(true)
	snapshot_player_state["pending_battle_context"] = {"transaction_id": str(battle_context.get("transaction_id", ""))}
	state_snapshot["player_state"] = snapshot_player_state
	battle_context["worldmap_state_snapshot"] = state_snapshot
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
		int(battle_context.get("attacker_source_city_troops_before", 0)),
		total_allocated_troops,
		int(battle_context.get("attacker_source_city_troops_after", 0)),
	])
	print("[PLAYER_ATTACK] start source=%s target=%s attacker_heroes=%s defender_heroes=%s" % [
		source_city_id,
		target_city_id,
		str(battle_context.get("attacker_hero_ids", [])),
		str(battle_context.get("defender_hero_ids", []))
	])
	_handoff_battle_context_to_battle_scene(battle_context)


func _validate_player_attack_deployment(deployment: Dictionary) -> Dictionary:
	var result := _ensure_player_attack_deployment_service().validate(deployment)
	result["message"] = "출정 가능" if bool(result.get("ok", false)) else _format_player_attack_deployment_error(result)
	return result


func _format_player_attack_deployment_error(result: Dictionary) -> String:
	var detail := str(result.get("detail", ""))
	if not detail.is_empty():
		return detail
	var hero_id := str(result.get("hero_id", ""))
	match str(result.get("error_code", "")):
		"source_mismatch": return "출정 도시가 현재 공격 조건과 일치하지 않습니다."
		"no_hero": return "장수를 1명 이상 선택하십시오."
		"hero_unavailable": return "출전 불가 장수가 포함되어 있습니다: %s" % hero_id
		"missing_command_limit": return "지휘 한계가 없는 장수가 포함되어 있습니다: %s" % hero_id
		"zero_hero_troops": return "선택 장수마다 병력 1 이상을 배정하십시오."
		"invalid_total_troops": return "출정 병력은 1 이상, 도시 병력-1 이하이어야 합니다."
		"invalid_food_type": return "식량은 쌀·보리·수산물 중 하나만 선택하십시오."
		"insufficient_minimum_gold": return "선택 병력의 최소 군자금이 부족합니다."
		"insufficient_minimum_food": return "최소 1턴분 식량이 필요합니다."
		"insufficient_rice", "insufficient_barley", "insufficient_seafood", "insufficient_gold", "insufficient_salt": return "선택한 적재량이 도시 보유량을 초과합니다."
	return "출정 조건을 확인하십시오."


func _calculate_player_attack_supply_cost(total_troops: int) -> Dictionary:
	return _ensure_player_attack_deployment_service().calculate_supply_cost(total_troops)


func _can_pay_player_attack_supply_cost(source_city_id: String, supply_cost: Dictionary) -> bool:
	return _ensure_player_attack_deployment_service().can_pay_supply(source_city_id, supply_cost)


func _pay_player_attack_supply_cost(source_city_id: String, supply_cost: Dictionary) -> void:
	_ensure_player_attack_deployment_service().pay_supply(source_city_id, supply_cost)
	_rebuild_occupation_runtime_indexes_mvp()
	_refresh_city_hud_data_bindings()
	_refresh_left_world_status_panel()


func _move_generals_for_pending_expedition(source_city_id: String, hero_ids: Array[String]) -> void:
	_ensure_player_attack_deployment_service().move_generals_for_expedition(source_city_id, hero_ids)


func _select_city_battle_supply(city_id: String) -> Dictionary:
	return _ensure_player_attack_deployment_service().select_city_battle_supply(city_id)


func _ensure_city_supply_resource_defaults(city_id: String) -> void:
	if city_id.is_empty():
		return
	var city_data := _get_mutable_city_runtime_state(city_id)
	if city_data.is_empty():
		return
	var result := _ensure_city_resource_service().build_supply_resource_defaults(city_data)
	if bool(result.get("changed", false)):
		_city_runtime_states[city_id] = (result.get("city_state", {}) as Dictionary).duplicate(true)
		_refresh_city_hud_data_bindings()
		print("[PLAYER_ATTACK_SUPPLY_DEFAULT] city=%s resources=%s" % [city_id, str(result.get("resource_stock", {}))])


func _get_city_supply_resource_amount(city_id: String, resource_id: String) -> int:
	_ensure_city_supply_resource_defaults(city_id)
	return _ensure_city_resource_service().get_city_supply_resource_amount(_get_city_hud_entry(city_id), resource_id)


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
		"attacker_owner": _get_city_owner_id_for_battle_context(attacker_city_id),
		"defender_owner": _get_city_owner_id_for_battle_context(defender_city_id),
		"source": "enemy_invasion_mvp",
		"turn_number": maxi(1, int(_player_state.get("turn_number", 1))),
		"transaction_id": _make_t03_transaction_id(attacker_city_id, defender_city_id),
		"stage": "awaiting_player_choice" if _is_city_owned_by_player_mvp(defender_city_id) else "automatic_resolution",
	}
	if _is_city_owned_by_player_mvp(defender_city_id):
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
	if _ensure_camera_controller().is_battle_entry_handoff_in_progress():
		_set_save_management_status("전투 화면 이동 중입니다.")
		_refresh_left_world_status_panel()
		return
	_open_defense_deployment_panel_from_pending_invasion("manual")


func _on_auto_defense_pressed() -> void:
	if _ensure_camera_controller().is_battle_entry_handoff_in_progress():
		_set_save_management_status("전투 화면 이동 중입니다.")
		_refresh_left_world_status_panel()
		return
	var result := _resolve_t03_automatic_invasion(_get_pending_invasion_event_mvp())
	if result.is_empty():
		_set_save_management_status("자동 방어 해결 실패 · 침공 상태를 확인하십시오.")
	else:
		_set_save_management_status("자동 방어 결과가 정산되었습니다.")
	_refresh_left_world_status_panel()


func _open_defense_deployment_panel_from_pending_invasion(mode: String = "manual") -> void:
	if _ensure_camera_controller().is_battle_entry_handoff_in_progress():
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
	var max_deployable := maxi(0, defender_troops)
	var heroes := _get_deployable_player_heroes_for_city(defender_city_id)
	if heroes.is_empty() or max_deployable <= 0:
		return {}
	var naval_unlock := _get_player_naval_unlock_modifier_mvp(defender_city_id)
	var siege_unlock := _get_player_siege_unlock_modifier_mvp(defender_city_id)
	return {
		"deployment_type": "defense",
		"mode": "auto" if mode == "auto" else "manual",
		"source_city_id": defender_city_id,
		"target_city_id": attacker_city_id,
		"source_city_name": _format_city_name_by_id(defender_city_id, "방어 도시"),
		"target_city_name": _format_city_name_by_id(attacker_city_id, "침공 도시"),
		"source_troops": defender_troops,
		"max_deployable_troops": max_deployable,
		"food_available": _get_t03_city_food_total(defender_city_id),
		"gold_available": _get_city_supply_resource_amount(defender_city_id, "gold"),
		"salt_available": _get_city_supply_resource_amount(defender_city_id, "salt"),
		"naval_route_required": _is_naval_attack_route_mvp(attacker_city_id, defender_city_id),
		"siege_required": _is_siege_attack_target_mvp(defender_city_id),
		"domestic_tech_naval_unlock": naval_unlock,
		"domestic_tech_siege_unlock": siege_unlock,
		"heroes": heroes,
	}


func _confirm_defense_deployment(deployment: Dictionary) -> void:
	if _ensure_camera_controller().is_battle_entry_handoff_in_progress():
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
	battle_context = _prepare_t03_battle_transaction(event, battle_context, "direct")
	if battle_context.is_empty():
		_set_save_management_status("방어 전투 병참 준비 실패")
		_refresh_left_world_status_panel()
		return
	if _player_attack_deployment_panel != null and _player_attack_deployment_panel.has_method("close"):
		_player_attack_deployment_panel.call("close")
	_set_pending_battle_context_mvp(battle_context)
	var state_snapshot := _serialize_worldmap_state()
	var snapshot_player_state: Dictionary = state_snapshot.get("player_state", {}).duplicate(true)
	snapshot_player_state["pending_invasion_event"] = event.duplicate(true)
	snapshot_player_state["pending_battle_context"] = {"transaction_id": str(battle_context.get("transaction_id", "")), "stage": "battle_handoff"}
	state_snapshot["player_state"] = snapshot_player_state
	battle_context["worldmap_state_snapshot"] = state_snapshot
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
	var remaining_garrison := maxi(0, _get_city_troops_for_battle_context(defender_city_id))
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
	var max_deployable := maxi(0, _get_city_troops_for_battle_context(defender_city_id))
	if total_troops <= 0 or total_troops > max_deployable:
		return {"ok": false, "message": "방어 병력은 1 이상, 도시 병력 이하이어야 합니다."}
	return {
		"ok": true,
		"message": "방어 가능",
		"total_troops": total_troops,
		"selected_hero_ids": selected_hero_ids,
		"defender_troop_allocation": clamped_allocation,
	}


func _handoff_battle_context_to_battle_scene(battle_context: Dictionary) -> void:
	if _ensure_camera_controller().is_battle_entry_handoff_in_progress():
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
		_rollback_player_attack_handoff(battle_context)
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
	# The old WorldMap scene can receive the remainder of the triggering input
	# until the scene replacement is committed. Disable its input paths first.
	set_process_input(false)
	set_process_unhandled_input(false)
	var transition_result := get_tree().change_scene_to_file(WORLDMAP_BATTLE_SCENE_PATH)
	if transition_result != OK:
		set_process_input(true)
		set_process_unhandled_input(true)
		if Engine.has_meta(WORLDMAP_BATTLE_CONTEXT_META_KEY):
			Engine.remove_meta(WORLDMAP_BATTLE_CONTEXT_META_KEY)
		_rollback_player_attack_handoff(handoff_context)
		_set_save_management_status("전투 화면 이동 실패")
		_refresh_left_world_status_panel()


func _rollback_player_attack_handoff(context: Dictionary) -> void:
	if str(context.get("transaction_id", "")).begins_with("t03-"):
		_rollback_t03_battle_transaction(context)
		return
	if str(context.get("source", "")) != PLAYER_ATTACK_CONTEXT_SOURCE:
		return
	_ensure_player_attack_deployment_service().rollback_departure(context)
	_player_state["pending_battle_context"] = {}
	_refresh_city_hud_data_bindings()


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
	if _ensure_camera_controller().is_battle_entry_handoff_in_progress():
		return
	if not continue_callable.is_valid():
		return
	var focus := _build_worldmap_battle_entry_focus(source_city_id, target_city_id)
	if focus.is_empty():
		continue_callable.call()
		return
	var focus_position: Variant = focus.get("position", null)
	if not focus_position is Vector2:
		continue_callable.call()
		return

	_set_save_management_status("전투 지역 접근 중 · %s → %s" % [
		_format_city_name_by_id(source_city_id, "출발 도시"),
		_format_city_name_by_id(target_city_id, "대상 도시"),
	])
	_refresh_left_world_status_panel()

	_ensure_camera_controller().start_battle_entry_handoff(focus_position, continue_callable)


func _complete_worldmap_battle_entry_camera_handoff() -> void:
	_ensure_camera_controller().skip_battle_entry_handoff()


func _skip_worldmap_battle_entry_camera_handoff() -> void:
	_ensure_camera_controller().skip_battle_entry_handoff()


func _is_worldmap_battle_entry_handoff_skip_event(event: InputEvent) -> bool:
	return _ensure_camera_controller().is_battle_entry_handoff_skip_event(event)


func _get_clamped_worldmap_camera_position_for_zoom(target_position: Vector2, zoom: Vector2) -> Vector2:
	return _ensure_camera_controller().get_clamped_position_for_zoom(target_position, zoom)


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
	var incoming_result_id := str(result.get("result_id", ""))
	var current_applied: Variant = _player_state.get("applied_battle_result_ids", [])
	if not incoming_result_id.is_empty() and current_applied is Array and (current_applied as Array).has(incoming_result_id):
		_set_save_management_status("이미 적용된 전투 결과입니다.")
		return
	var snapshot: Variant = result.get("worldmap_state_snapshot", {})
	if snapshot is Dictionary and not (snapshot as Dictionary).is_empty():
		_apply_worldmap_state(snapshot as Dictionary)
		if not str(result.get("transaction_id", "")).is_empty():
			_player_state["pending_battle_context"] = {"transaction_id": str(result.get("transaction_id", ""))}
	if str(result.get("transaction_id", "")).begins_with("t03-"):
		_apply_t03_strategic_battle_result(result, true)
		return
	var settlement_plan := _ensure_battle_result_service().build_settlement_plan(result)
	result["_settlement_plan"] = settlement_plan
	result["_settlement_report"] = _ensure_battle_settlement_applier().apply(settlement_plan)
	if not bool((result["_settlement_report"] as Dictionary).get("ok", false)) and str(settlement_plan.get("result_kind", "")) != INVASION_RESULT_UNKNOWN:
		_set_save_management_status(_format_battle_settlement_rejection(result["_settlement_report"] as Dictionary))
		return
	if str(settlement_plan.get("settlement_profile", "standard")) == "standard" and bool((result["_settlement_report"] as Dictionary).get("ok", false)):
		_rebuild_occupation_runtime_indexes_mvp()
		(result["_settlement_report"] as Dictionary)["indexes_rebuilt"] = true
		_sync_worldmap_hero_locations_from_city_runtime_states()
		_refresh_city_marker_owner_states_from_runtime()
		_refresh_city_hud_data_bindings()
	if _is_player_attack_battle_result(result):
		_apply_player_attack_battle_result(result)
		return
	_apply_invasion_battle_result(result)


func _is_player_attack_battle_result(result_payload: Dictionary) -> bool:
	return _ensure_battle_result_service()._is_player_attack_battle_result(result_payload)

func _apply_player_attack_battle_result(result_payload: Dictionary) -> void:
	if not str(result_payload.get("transaction_id", "")).is_empty():
		_apply_t02_player_attack_result(result_payload)
		return
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


func _apply_t02_player_attack_result(result: Dictionary) -> void:
	var plan: Dictionary = result.get("_settlement_plan", {}) if result.get("_settlement_plan", {}) is Dictionary else {}
	if plan.is_empty():
		plan = _ensure_battle_result_service().build_settlement_plan(result)
	var report: Dictionary = result.get("_settlement_report", {}) if result.get("_settlement_report", {}) is Dictionary else {}
	if report.is_empty():
		report = _ensure_battle_settlement_applier().apply(plan)
	if not bool(report.get("ok", false)):
		_set_save_management_status(_format_battle_settlement_rejection(report))
		return
	var target_city_id := str(plan.get("target_city_id", ""))
	var troop_settlement: Dictionary = plan.get("troop_settlement", {}) if plan.get("troop_settlement", {}) is Dictionary else {}
	var healthy := maxi(0, int(troop_settlement.get("attacker_healthy", plan.get("attacker_remaining_troops", 0))))
	var wounded := maxi(0, int(troop_settlement.get("attacker_wounded", 0)))
	_player_state["last_wounded_treatment"] = {
		"city_id": target_city_id if str(plan.get("result_kind", "")) == INVASION_RESULT_ATTACKER_WIN else str(plan.get("attacker_city_id", "")),
		"transaction_id": str(plan.get("transaction_id", "")),
		"wounded_count": wounded,
		"mode": "normal",
	}
	_player_state["pending_battle_context"] = {}
	_player_state["pending_invasion_event"] = {}
	_player_state["korea_unification_victory"] = _get_player_owned_korea_mvp_city_count() >= 4
	_rebuild_occupation_runtime_indexes_mvp()
	report["indexes_rebuilt"] = true
	result["_settlement_report"] = report
	_sync_worldmap_hero_locations_from_city_runtime_states()
	_refresh_city_marker_owner_states_from_runtime()
	_refresh_city_hud_data_bindings()
	_select_city_after_invasion_result(target_city_id)
	_refresh_city_info_attack_action_state(target_city_id)
	var attacker_won := str(plan.get("result_kind", "")) == INVASION_RESULT_ATTACKER_WIN
	var outcome_label := "점령 성공" if attacker_won else ("30턴 제한 패배" if str(result.get("result_reason", "")) == "turn_limit" else "공격 패배")
	_set_save_management_status("%s · 정상병 %d / 부상병 %d / 전사 %d / 이탈 %d" % [outcome_label, healthy, wounded, int(result.get("attacker_dead", 0)), int(result.get("attacker_deserters", 0))])
	var result_lines: Array[String] = [
		"정상병 %d · 부상병 %d · 전사 %d · 이탈 %d" % [healthy, wounded, int(result.get("attacker_dead", 0)), int(result.get("attacker_deserters", 0))],
		"부상병은 기본 일반 치료(3개월)로 등록되었습니다.",
	]
	if attacker_won:
		result_lines.append("%s을 점령했습니다." % _format_city_name_by_id(target_city_id, target_city_id))
		result_lines.append("출전 장수와 생존 병력이 %s에 주둔합니다." % _format_city_name_by_id(target_city_id, target_city_id))
		var disposition: Dictionary = report.get("defender_disposition", {}) if report.get("defender_disposition", {}) is Dictionary else {}
		if int(disposition.get("aligned_count", 0)) > 0:
			result_lines.append("적 장수 %d명이 아군에 귀속되었습니다." % int(disposition.get("aligned_count", 0)))
		if int(disposition.get("escaped_count", 0)) > 0:
			result_lines.append("적 장수 %d명이 인접한 적 도시로 피신했습니다." % int(disposition.get("escaped_count", 0)))
		if bool(disposition.get("faction_defeated", false)):
			result_lines.append("%s가 멸망했습니다." % _format_faction_label(str(disposition.get("defeated_faction_id", ""))))
	if bool(_player_state.get("korea_unification_victory", false)):
		result_lines.append("한반도 네 도시를 모두 장악했습니다. T05 승리 화면 연결 대기 중입니다.")
	_show_post_battle_result_summary({"message_title": outcome_label, "message_lines": result_lines})
	_refresh_wounded_treatment_controls()
	_refresh_left_world_status_panel()
	_refresh_unified_panel_content()
	_save_worldmap_state()


func _format_battle_settlement_rejection(report: Dictionary) -> String:
	var warnings: Array = report.get("warnings", []) if report.get("warnings", []) is Array else []
	if bool(report.get("duplicate", false)):
		return "이미 적용된 전투 결과입니다."
	if warnings.has("transaction_mismatch") or warnings.has("incomplete_result_identity"):
		return "전투 결과 거부 · 트랜잭션 ID 불일치"
	if warnings.has("missing_target_city") or warnings.has("missing_attacker_city"):
		return "전투 결과 거부 · 도시 ID 없음"
	return "전투 결과 정산을 적용하지 못했습니다."


func _settle_defender_generals_after_occupation(target_city_id: String, defeated_owner: String, attacker_owner: String, all_hero_ids: Array[String], surviving_hero_ids: Array[String], transaction_id: String, result_id: String) -> Dictionary:
	var disposition := _ensure_battle_result_service()._build_defender_disposition_plan(target_city_id, defeated_owner, attacker_owner, all_hero_ids, surviving_hero_ids, transaction_id, result_id)
	return _ensure_battle_settlement_applier().apply_defender_disposition(target_city_id, disposition)


func _set_hero_faction_after_conquest_mvp(hero_id: String, faction_id: String, city_id: String, acquisition_transaction_id: String, acquired_from_faction_id: String) -> void:
	_ensure_battle_settlement_applier().set_hero_faction(hero_id, faction_id, city_id, acquisition_transaction_id, acquired_from_faction_id)


func _rebuild_occupation_runtime_indexes_mvp() -> void:
	# Global aggregation, AI cache generation and victory evaluation remain coordinator-owned.
	var player_cities: Array[String] = []
	for city_id_variant in CITY_HUD_DATA.keys():
		var city_id := str(city_id_variant)
		if _get_city_owner_id_for_battle_context(city_id) == _get_current_player_faction_id():
			player_cities.append(city_id)
	player_cities.sort()
	_player_state["owned_city_ids"] = player_cities
	var resources := {}
	var troops := 0
	var population := 0
	for city_id in player_cities:
		var city := _get_city_hud_entry(city_id)
		troops += maxi(0, int(city.get("troops", 0)))
		population += maxi(0, int(city.get("population", 0)))
		var stock: Variant = city.get("resource_stock", {})
		if stock is Dictionary:
			for resource_id in (stock as Dictionary).keys():
				resources[str(resource_id)] = int(resources.get(str(resource_id), 0)) + maxi(0, int((stock as Dictionary).get(resource_id, 0)))
	_player_state["national_aggregation"] = {"resources": resources, "available_troops": troops, "population": population, "owner_source": "city.owner_faction_id"}
	_player_state["resource_stock"] = resources.duplicate(true)
	_player_state["ai_ownership_cache_generation"] = int(_player_state.get("ai_ownership_cache_generation", 0)) + 1
	_evaluate_korea_mvp_outcome_mvp()


func _move_hero_to_city_t02(hero_id: String, city_id: String) -> void:
	_ensure_battle_settlement_applier().move_hero(hero_id, city_id)


func _normalize_battle_result_hero_ids(raw_hero_ids: Variant) -> Array[String]:
	return _ensure_battle_result_service()._normalize_battle_result_hero_ids(raw_hero_ids)


func _apply_battle_settlement_move_hero(hero_id: String, city_id: String) -> bool:
	if hero_id.is_empty() or city_id.is_empty() or _get_hero_seed_entry(hero_id).is_empty():
		return false
	_remove_hero_from_other_city_runtime_rosters(hero_id, city_id)
	_ensure_hero_in_city_runtime_roster(hero_id, city_id)
	_set_hero_runtime_city(hero_id, city_id)
	return true


func _apply_battle_settlement_hero_faction(hero_id: String, faction_id: String, city_id: String, acquisition_transaction_id: String, acquired_from_faction_id: String) -> bool:
	if not _apply_battle_settlement_move_hero(hero_id, city_id):
		return false
	var hero_state := _normalize_hero_runtime_state(hero_id, _get_existing_hero_runtime_state(hero_id))
	hero_state["side"] = faction_id
	hero_state["nation"] = faction_id
	hero_state["faction_id"] = faction_id
	hero_state["force_id"] = faction_id
	hero_state["appointment"] = ""
	hero_state["office"] = ""
	hero_state["command_rank"] = "unappointed"
	if not acquisition_transaction_id.is_empty():
		hero_state["acquisition_type"] = "conquest_mvp"
		hero_state["acquired_from_faction_id"] = acquired_from_faction_id
		hero_state["acquired_transaction_id"] = acquisition_transaction_id
	_hero_runtime_states[hero_id] = hero_state
	return true


func _apply_battle_settlement_hero_status(hero_id: String, status: String, outcome: Dictionary, transaction_id: String) -> bool:
	var result := _ensure_wounded_recovery_service().apply_battle_hero_status(hero_id, status, outcome, transaction_id)
	return bool(result.get("ok", false))


func _record_battle_defender_disposition(disposition: Dictionary) -> void:
	if bool(disposition.get("faction_defeated", false)):
		var defeated_owner := str(disposition.get("defeated_faction_id", ""))
		var defeated: Dictionary = _player_state.get("defeated_factions", {}) if _player_state.get("defeated_factions", {}) is Dictionary else {}
		defeated[defeated_owner] = {"defeated": true, "transaction_id": str(disposition.get("transaction_id", "")), "result_id": str(disposition.get("result_id", ""))}
		_player_state["defeated_factions"] = defeated
		var announced: Dictionary = _player_state.get("defeated_faction_notifications", {}) if _player_state.get("defeated_faction_notifications", {}) is Dictionary else {}
		if not announced.has(defeated_owner):
			announced[defeated_owner] = true
		_player_state["defeated_faction_notifications"] = announced
	_player_state["last_defender_disposition"] = disposition.duplicate(true)


func _apply_battle_settlement_defender_supply(city_id: String, settlement: Dictionary) -> Dictionary:
	var city_data := _get_mutable_city_runtime_state(city_id)
	if city_data.is_empty():
		return {"ok": false, "city_id": city_id}
	var stock: Dictionary = city_data.get("resource_stock", {}).duplicate(true)
	var food_type := str(settlement.get("food_type", "rice"))
	var before := stock.duplicate(true)
	stock[food_type] = maxi(0, int(settlement.get("remaining_food", stock.get(food_type, 0))))
	stock["salt"] = maxi(0, int(settlement.get("remaining_salt", stock.get("salt", 0))))
	city_data["resource_stock"] = stock
	_city_runtime_states[city_id] = city_data
	return {"ok": true, "city_id": city_id, "before": before, "after": stock.duplicate(true)}


func _apply_battle_settlement_attacker_cargo(city_id: String, settlement: Dictionary) -> Dictionary:
	var city_data := _get_mutable_city_runtime_state(city_id)
	if city_data.is_empty():
		return {"ok": false, "city_id": city_id}
	var stock: Dictionary = city_data.get("resource_stock", {}).duplicate(true)
	var before := stock.duplicate(true)
	var food_type := str(settlement.get("food_type", "rice"))
	stock[food_type] = maxi(0, int(stock.get(food_type, 0))) + maxi(0, int(settlement.get("food", 0)))
	stock["salt"] = maxi(0, int(stock.get("salt", 0))) + maxi(0, int(settlement.get("salt", 0)))
	stock["gold"] = maxi(0, int(stock.get("gold", 0))) + maxi(0, int(settlement.get("gold", 0)))
	city_data["resource_stock"] = stock
	_city_runtime_states[city_id] = city_data
	return {"ok": true, "city_id": city_id, "before": before, "after": stock.duplicate(true)}
func _refresh_wounded_treatment_controls() -> void:
	if _wounded_fast_treatment_button == null or _wounded_treatment_hint_label == null:
		return
	var treatment: Dictionary = _player_state.get("last_wounded_treatment", {}) if _player_state.get("last_wounded_treatment", {}) is Dictionary else {}
	var eligibility := _ensure_wounded_recovery_service().evaluate_fast_treatment(treatment)
	var required_salt := maxi(0, int(eligibility.get("required_salt", 0)))
	var available_salt := maxi(0, int(eligibility.get("available_salt", 0)))
	var is_fast := str(treatment.get("mode", "normal")) == "fast"
	_wounded_fast_treatment_button.text = "집중 치료 (소금 %d · 1개월)" % required_salt
	_wounded_fast_treatment_button.disabled = not bool(eligibility.get("ok", false))
	_wounded_treatment_hint_label.text = "집중 치료 필요 소금 %d / 도시 보유 %d%s" % [required_salt, available_salt, " · 적용 완료" if is_fast else ""]


func _on_fast_wounded_treatment_pressed() -> void:
	var treatment: Dictionary = _player_state.get("last_wounded_treatment", {}) if _player_state.get("last_wounded_treatment", {}) is Dictionary else {}
	var result := _ensure_wounded_recovery_service().apply_fast_treatment(treatment)
	if not bool(result.get("ok", false)):
		_refresh_wounded_treatment_controls()
		return
	_refresh_wounded_treatment_controls()
	_refresh_city_hud_data_bindings()
	_save_worldmap_state()


func _apply_t02_defender_supply_result(city_id: String, result: Dictionary) -> void:
	_ensure_battle_settlement_applier().apply_defender_supply(city_id, {
		"food_type": str(result.get("defender_remaining_food_type", "rice")),
		"remaining_food": maxi(0, int(result.get("defender_remaining_food", 0))),
		"remaining_salt": maxi(0, int(result.get("defender_remaining_salt", 0))),
	})


func _add_t02_attacker_cargo_to_city(city_id: String, result: Dictionary) -> void:
	_ensure_battle_settlement_applier().apply_attacker_cargo(city_id, {
		"food_type": str(result.get("attacker_remaining_food_type", "rice")),
		"food": maxi(0, int(result.get("attacker_remaining_food", 0))),
		"salt": maxi(0, int(result.get("attacker_remaining_salt", 0))),
		"gold": maxi(0, int(result.get("attacker_remaining_gold", 0))),
	})

func _get_player_owned_korea_mvp_city_count() -> int:
	var count := 0
	for city_id in ["hanseong", "pyeongyang", "gyeongju", "sabi"]:
		if _get_city_owner_id_for_battle_context(city_id) == _get_current_player_faction_id():
			count += 1
	return count


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
	return _ensure_battle_result_service()._is_enemy_invasion_battle_result(result_payload)

func _normalize_invasion_battle_result_kind(result_payload: Dictionary) -> String:
	return _ensure_battle_result_service()._normalize_invasion_battle_result_kind(result_payload)

func _normalize_player_attack_battle_result_kind(result_payload: Dictionary) -> String:
	return _ensure_battle_result_service()._normalize_player_attack_battle_result_kind(result_payload)

func _get_invasion_result_city_id(result_payload: Dictionary, keys: Array[String]) -> String:
	return _ensure_battle_result_service()._get_invasion_result_city_id(result_payload, keys)

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
	return _ensure_battle_result_service()._build_invasion_result_summary(result_kind, defender_city_id, attacker_city_id, defender_city_name, attacker_city_name, old_owner, new_owner, casualty_result, message_title, leading_lines)

func _format_invasion_result_status_from_summary(summary: Dictionary) -> String:
	var title := str(summary.get("message_title", "전투 결과"))
	var lines: Array = summary.get("message_lines", [])
	if lines.is_empty():
		return title
	return "%s: %s" % [title, str(lines[0])]


func _normalize_battle_hero_outcomes(raw_outcomes: Variant) -> Dictionary:
	return _ensure_battle_result_service()._normalize_battle_hero_outcomes(raw_outcomes)

func _apply_explicit_battle_hero_outcomes(result_payload: Dictionary) -> Dictionary:
	var plan: Dictionary = result_payload.get("_settlement_plan", {}) if result_payload.get("_settlement_plan", {}) is Dictionary else {}
	if plan.is_empty():
		plan = _ensure_battle_result_service().build_settlement_plan(result_payload)
	var status_plan: Array = plan.get("hero_status_plan", []) if plan.get("hero_status_plan", []) is Array else []
	var changes := _ensure_battle_settlement_applier().apply_hero_statuses(status_plan, str(plan.get("transaction_id", "")))
	return _summarize_battle_hero_changes(changes, not status_plan.is_empty())

func _apply_invasion_hero_state_placeholder(result_payload: Dictionary, result_summary: Dictionary) -> Dictionary:
	var updated_summary := result_summary.duplicate(true)
	var report: Dictionary = result_payload.get("_settlement_report", {}) if result_payload.get("_settlement_report", {}) is Dictionary else {}
	var changes: Array = report.get("hero_changes", []) if report.get("hero_changes", []) is Array else []
	updated_summary["hero_state_result"] = _summarize_battle_hero_changes(changes, not changes.is_empty())
	_append_hero_state_result_lines(updated_summary)
	return updated_summary


func _summarize_battle_hero_changes(changes: Array, has_explicit_data: bool) -> Dictionary:
	var wounded: Array[String] = []
	var normal: Array[String] = []
	var captured: Array[String] = []
	var dead: Array[String] = []
	for change_variant in changes:
		if not change_variant is Dictionary:
			continue
		var change := change_variant as Dictionary
		if str(change.get("kind", "")) != "status":
			continue
		var hero_id := str(change.get("hero_id", ""))
		match str(change.get("status", "")):
			HERO_RUNTIME_STATUS_WOUNDED: wounded.append(hero_id)
			HERO_RUNTIME_STATUS_CAPTURED: captured.append(hero_id)
			HERO_RUNTIME_STATUS_DEAD: dead.append(hero_id)
			_: normal.append(hero_id)
	return {
		"has_explicit_data": has_explicit_data,
		"wounded_hero_ids": wounded,
		"normal_hero_ids": normal,
		"captured_hero_ids": captured,
		"dead_hero_ids": dead,
		"skipped_hero_ids": [],
	}

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
	return _ensure_battle_settlement_applier().set_hero_status(hero_id, status)

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
	if bool(hero_state.get("wounded", false)) or status == HERO_RUNTIME_STATUS_WOUNDED:
		return true
	return false


func _get_hero_battle_exclusion_reason(hero_id: String) -> String:
	var hero_state := _normalize_hero_runtime_state(hero_id, _get_existing_hero_runtime_state(hero_id))
	var status := str(hero_state.get("status", HERO_RUNTIME_STATUS_NORMAL))
	if bool(hero_state.get("dead", false)) or status == HERO_RUNTIME_STATUS_DEAD:
		return "dead"
	if bool(hero_state.get("captured", false)) or status == HERO_RUNTIME_STATUS_CAPTURED:
		return "captured"
	if bool(hero_state.get("wounded", false)) or status == HERO_RUNTIME_STATUS_WOUNDED:
		return "wounded_recovery"
	return ""


func _apply_defender_win_invasion_result(defender_city_id: String, attacker_city_id: String, defender_city_name: String, attacker_city_name: String, result_payload: Dictionary) -> Dictionary:
	return _build_applied_battle_result_summary(result_payload, defender_city_id, attacker_city_id, defender_city_name, attacker_city_name, "방어 성공", ["%s을 지켜냈습니다." % defender_city_name])


func _apply_attacker_win_invasion_result(defender_city_id: String, attacker_city_id: String, defender_city_name: String, attacker_city_name: String, result_payload: Dictionary) -> Dictionary:
	return _build_applied_battle_result_summary(result_payload, defender_city_id, attacker_city_id, defender_city_name, attacker_city_name, "도시 함락", ["%s이 함락되었습니다." % defender_city_name])


func _apply_player_attack_win_result(defender_city_id: String, attacker_city_id: String, defender_city_name: String, attacker_city_name: String, result_payload: Dictionary) -> Dictionary:
	return _build_applied_battle_result_summary(result_payload, defender_city_id, attacker_city_id, defender_city_name, attacker_city_name, "도시 점령", ["%s 점령 성공!" % defender_city_name])


func _apply_player_attack_loss_result(defender_city_id: String, attacker_city_id: String, defender_city_name: String, attacker_city_name: String, result_payload: Dictionary) -> Dictionary:
	return _build_applied_battle_result_summary(result_payload, defender_city_id, attacker_city_id, defender_city_name, attacker_city_name, "공격 실패", ["%s 공격 실패" % defender_city_name])


func _build_applied_battle_result_summary(result_payload: Dictionary, defender_city_id: String, attacker_city_id: String, defender_city_name: String, attacker_city_name: String, title: String, leading_lines: Array) -> Dictionary:
	var plan: Dictionary = result_payload.get("_settlement_plan", {}) if result_payload.get("_settlement_plan", {}) is Dictionary else {}
	if plan.is_empty():
		plan = _ensure_battle_result_service().build_settlement_plan(result_payload)
		result_payload["_settlement_plan"] = plan
	var report: Dictionary = result_payload.get("_settlement_report", {}) if result_payload.get("_settlement_report", {}) is Dictionary else {}
	if report.is_empty():
		report = _ensure_battle_settlement_applier().apply(plan)
		result_payload["_settlement_report"] = report
	var transfer: Dictionary = plan.get("faction_transfer", {}) if plan.get("faction_transfer", {}) is Dictionary else {}
	var old_owner := str(transfer.get("old_owner", _get_city_owner_id_for_battle_context(defender_city_id)))
	var new_owner := str(transfer.get("new_owner", old_owner))
	return _build_invasion_result_summary(
		str(plan.get("result_kind", INVASION_RESULT_UNKNOWN)),
		defender_city_id,
		attacker_city_id,
		defender_city_name,
		attacker_city_name,
		old_owner,
		new_owner,
		plan.get("casualty_plan", {}) if plan.get("casualty_plan", {}) is Dictionary else {},
		title,
		leading_lines
	)

func _get_player_troop_outcome_from_result(result_payload: Dictionary) -> Dictionary:
	return _ensure_battle_result_service()._get_player_troop_outcome_from_result(result_payload)

func _get_enemy_troop_outcome_from_result(result_payload: Dictionary) -> Dictionary:
	return _ensure_battle_result_service()._get_enemy_troop_outcome_from_result(result_payload)

func _calculate_player_attack_troop_outcome_fallback(allocated: int, raw_survivors: int, did_win: bool) -> Dictionary:
	return _ensure_battle_result_service()._calculate_player_attack_troop_outcome_fallback(allocated, raw_survivors, did_win)

func _calculate_invasion_casualty_result(result_kind: String, defender_city_id: String, attacker_city_id: String, result_payload: Dictionary) -> Dictionary:
	return _ensure_battle_result_service()._calculate_invasion_casualty_result(result_kind, defender_city_id, attacker_city_id, result_payload)

func _resolve_invasion_remaining_troops(before_troops: int, payload_survivors: int, loss_rate: float, minimum_when_present: int) -> int:
	return _ensure_battle_result_service()._resolve_invasion_remaining_troops(before_troops, payload_survivors, loss_rate, minimum_when_present)

func _resolve_occupation_troops(attacker_remaining: int, attacker_before: int, result_payload: Dictionary) -> int:
	return _ensure_battle_result_service()._resolve_occupation_troops(attacker_remaining, attacker_before, result_payload)

func _clamp_invasion_troops(troops: int) -> int:
	return _ensure_battle_result_service()._clamp_invasion_troops(troops)

func _get_result_troop_value(result_payload: Dictionary, keys: Array[String], fallback: int) -> int:
	return _ensure_battle_result_service()._get_result_troop_value(result_payload, keys, fallback)

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
	return _ensure_military_controller().is_supply_path_between(from_id, to_id)


func _get_city_min_garrison(city_id: String) -> int:
	return _ensure_military_controller().get_city_min_garrison(city_id)


func _is_peacetime_for_troop_move() -> bool:
	return _ensure_military_controller().is_peacetime_for_troop_move()


func _can_move_troops(from_id: String, to_id: String, amount: int) -> Dictionary:
	return _ensure_military_controller().can_move_troops(from_id, to_id, amount)


func _move_troops(from_id: String, to_id: String, amount: int) -> bool:
	return _ensure_military_controller().move_troops(from_id, to_id, amount)


func _calculate_troop_move_arrived_amount(commanded_amount: int, from_loyalty: int) -> int:
	return _ensure_military_controller().calculate_troop_move_arrived_amount(commanded_amount, from_loyalty)


func _get_conscription_capacity_by_loyalty(city_id: String) -> int:
	return _ensure_military_controller().get_conscription_capacity_by_loyalty(city_id)


func _get_city_conscription_available(city_id: String) -> int:
	return _ensure_military_controller().get_city_conscription_available(city_id)


func _get_conscription_turn_add_multiplier() -> float:
	return _ensure_military_controller().get_conscription_turn_add_multiplier()


func _apply_city_conscription_for_world_turn() -> Dictionary:
	return _ensure_military_controller().apply_city_conscription_for_world_turn()


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
	return UIFormatterHelpers.format_selected_city_revolt_risk_label(risk, REVOLT_RISK_DANGER, REVOLT_RISK_WARNING, REVOLT_RISK_STABLE)


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
	return _ensure_military_controller().get_recruitment_limit_by_loyalty(city_id)


func _calculate_recruitment_cost(amount: int) -> Dictionary:
	return _ensure_military_controller().calculate_recruitment_cost(amount)


func _get_total_recruitment_food_stock() -> int:
	var resource_stock: Dictionary = _player_state.get("resource_stock", {})
	return maxi(0, int(resource_stock.get("rice", 0))) + maxi(0, int(resource_stock.get("barley", 0))) + maxi(0, int(resource_stock.get("seafood", 0)))


func _get_national_payment_city_ids_mvp() -> Array[String]:
	var city_ids: Array[String] = []
	for city_id_variant in _city_runtime_states.keys():
		var city_id := str(city_id_variant)
		if _get_city_owner_id_for_battle_context(city_id) == _get_current_player_faction_id():
			city_ids.append(city_id)
	city_ids.sort()
	var capital_id := str(_player_state.get("capital_city_id", ""))
	if city_ids.has(capital_id):
		city_ids.erase(capital_id)
		city_ids.push_front(capital_id)
	return city_ids


func _payment_resource_ids_mvp(resource_id: String) -> Array[String]:
	return _ensure_city_resource_service().payment_resource_ids(resource_id)


func _plan_city_stock_payment_mvp(city_id: String, cost: Dictionary) -> Dictionary:
	if city_id.is_empty() or _get_city_hud_entry(city_id).is_empty():
		return {"ok": false, "cost": cost.duplicate(true), "missing": {"city": 1}, "plan": {}}
	_ensure_city_supply_resource_defaults(city_id)
	var stock: Dictionary = _get_city_hud_entry(city_id).get("resource_stock", {})
	return _ensure_city_resource_service().plan_city_stock_payment(city_id, cost, stock)


func _plan_national_city_stock_payment_mvp(cost: Dictionary) -> Dictionary:
	var city_ids := _get_national_payment_city_ids_mvp()
	var stocks := {}
	for city_id in city_ids:
		_ensure_city_supply_resource_defaults(city_id)
		stocks[city_id] = (_get_city_hud_entry(city_id).get("resource_stock", {}) as Dictionary).duplicate(true)
	return _ensure_city_resource_service().plan_national_city_stock_payment(city_ids, stocks, cost)


func _commit_city_stock_payment_mvp(city_id: String, cost: Dictionary) -> Dictionary:
	return _commit_city_stock_payment_plan_mvp(_plan_city_stock_payment_mvp(city_id, cost))


func _commit_national_city_stock_payment_mvp(cost: Dictionary) -> Dictionary:
	return _commit_city_stock_payment_plan_mvp(_plan_national_city_stock_payment_mvp(cost))


func _commit_city_stock_payment_plan_mvp(payment: Dictionary) -> Dictionary:
	payment = _ensure_city_resource_service().commit_city_stock_payment_plan(payment)
	if not bool(payment.get("ok", false)):
		return payment
	_rebuild_occupation_runtime_indexes_mvp()
	return payment


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
	return _ensure_military_controller().can_recruit_troops(city_id, amount)


func _recruit_troops(city_id: String, amount: int) -> bool:
	return _ensure_military_controller().recruit_troops(city_id, amount)


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
	return _ensure_domestic_tech_catalog().get_categories()


func _get_domestic_city_tech_definitions_mvp() -> Dictionary:
	return _ensure_domestic_tech_catalog().get_city_definitions()


func _get_domestic_national_tech_definitions_mvp() -> Dictionary:
	return _ensure_domestic_tech_catalog().get_national_definitions()


func _make_domestic_city_tech_definition_mvp(id: String, tech_name: String, category: String, branch: String, tier: int, rarity: int, prerequisites: Array, required_national_techs: Array, special_requirements: Dictionary, governor_aptitudes: Array, cost: Dictionary, effect_type: String, effect_value: Variant, effect_description: String, icon_path: String = "", enhanced_by_national_techs: Array = []) -> Dictionary:
	return _ensure_domestic_tech_catalog().make_city_definition(id, tech_name, category, branch, tier, rarity, prerequisites, required_national_techs, special_requirements, governor_aptitudes, cost, effect_type, effect_value, effect_description, icon_path, enhanced_by_national_techs)


func _make_domestic_national_tech_definition_mvp(id: String, tech_name: String, category: String, branch: String, tier: int, rarity: int, prerequisites: Array, special_requirements: Dictionary, cost: Dictionary, effect_type: String, effect_value: Variant, effect_description: String, icon_path: String = "", unlocks_city_techs: Array = [], enhances_city_techs: Array = []) -> Dictionary:
	return _ensure_domestic_tech_catalog().make_national_definition(id, tech_name, category, branch, tier, rarity, prerequisites, special_requirements, cost, effect_type, effect_value, effect_description, icon_path, unlocks_city_techs, enhances_city_techs)


func _make_domestic_tech_definition_mvp(id: String, tech_name: String, tree_scope: String, ui_surface: String, category: String, branch: String, tier: int, rarity: int, prerequisites: Array, required_national_techs: Array, special_requirements: Dictionary, governor_aptitudes: Array, progress_mode: String, cost: Dictionary, effect_type: String, effect_value: Variant, effect_description: String, icon_path: String, unlocks_city_techs: Array, enhances_city_techs: Array) -> Dictionary:
	return _ensure_domestic_tech_catalog().make_definition(id, tech_name, tree_scope, ui_surface, category, branch, tier, rarity, prerequisites, required_national_techs, special_requirements, governor_aptitudes, progress_mode, cost, effect_type, effect_value, effect_description, icon_path, unlocks_city_techs, enhances_city_techs)


func _get_domestic_tech_duration_class_mvp(tier: int, rarity: int) -> String:
	return _ensure_domestic_tech_catalog().get_duration_class(tier, rarity)


func _get_domestic_tech_duration_turns_hint_mvp(tier: int, rarity: int) -> Dictionary:
	return _ensure_domestic_tech_catalog().get_duration_turns_hint(tier, rarity)


func _get_domestic_tech_tier_duration_turns_mvp(tier: int) -> int:
	return _ensure_domestic_tech_catalog().get_tier_duration_turns(tier)


func _get_domestic_tech_scope_duration_turns_mvp(scope: String, tier: int, rarity: int = 0) -> int:
	return _ensure_domestic_tech_catalog().get_scope_duration_turns(scope, tier, rarity)


func _get_domestic_tech_definitions_mvp() -> Dictionary:
	return _ensure_domestic_tech_catalog().get_definitions()


func _get_domestic_tech_definition_mvp(tech_id: String) -> Dictionary:
	return _ensure_domestic_tech_catalog().get_definition(tech_id)


func _get_domestic_techs_by_scope_mvp(scope: String) -> Array:
	return _ensure_domestic_tech_catalog().get_by_scope(scope)


func _get_domestic_techs_by_category_mvp(category_id: String) -> Array:
	return _ensure_domestic_tech_catalog().get_by_category(category_id)


func _get_domestic_techs_by_branch_mvp(category_id: String, branch_id: String) -> Array:
	return _ensure_domestic_tech_catalog().get_by_branch(category_id, branch_id)


func _is_domestic_city_tech_mvp(tech_id: String) -> bool:
	return _ensure_domestic_tech_catalog().is_city_tech(tech_id)


func _is_domestic_national_tech_mvp(tech_id: String) -> bool:
	return _ensure_domestic_tech_catalog().is_national_tech(tech_id)


func _is_city_domestic_tech_completed_mvp(city_id: String, tech_id: String) -> bool:
	return _ensure_domestic_tech_research_service().is_city_completed(city_id, tech_id)


func _is_national_domestic_tech_completed_mvp(tech_id: String) -> bool:
	return _ensure_domestic_tech_research_service().is_national_completed(tech_id)


func _has_completed_national_domestic_tech_mvp(tech_id: String) -> bool:
	return _is_national_domestic_tech_completed_mvp(tech_id)


func _has_completed_city_domestic_tech_mvp(city_id: String, tech_id: String) -> bool:
	return _is_city_domestic_tech_completed_mvp(city_id, tech_id)


func _get_empty_domestic_tech_city_economy_bonus_mvp() -> Dictionary:
	return _ensure_domestic_tech_effect_provider().get_empty_effect("economy_bonus")


func _get_empty_domestic_economy_modifier_mvp() -> Dictionary:
	return _ensure_domestic_tech_effect_provider().get_empty_effect("economy_modifier")


func _get_domestic_tech_city_economy_bonus_mvp(city_id: String) -> Dictionary:
	return _ensure_domestic_tech_effect_provider().get_city_economy_bonus(city_id, _is_city_owned_by_player_mvp(city_id), _get_completed_city_domestic_tech_snapshot_mvp(city_id))


func _get_player_city_domestic_economy_modifier_mvp(city_id: String) -> Dictionary:
	return _ensure_domestic_tech_effect_provider().get_city_economy_modifier(city_id, _is_city_owned_by_player_mvp(city_id), _get_completed_city_domestic_tech_snapshot_mvp(city_id))


func _get_empty_domestic_tech_city_military_defense_bonus_mvp() -> Dictionary:
	return _ensure_domestic_tech_effect_provider().get_empty_effect("military_bonus")


func _get_empty_domestic_defense_modifier_mvp() -> Dictionary:
	return _ensure_domestic_tech_effect_provider().get_empty_effect("defense_modifier")


func _get_empty_domestic_battle_modifier_mvp() -> Dictionary:
	return _ensure_domestic_tech_effect_provider().get_empty_effect("battle_modifier")


func _get_empty_domestic_tech_national_policy_bonus_mvp() -> Dictionary:
	return _ensure_domestic_tech_effect_provider().get_empty_effect("policy_bonus")


func _get_empty_domestic_tech_city_naval_siege_bonus_mvp() -> Dictionary:
	return _ensure_domestic_tech_effect_provider().get_empty_effect("naval_siege_bonus")


func _get_empty_domestic_tech_diplomacy_spy_bonus_mvp() -> Dictionary:
	return _ensure_domestic_tech_effect_provider().get_empty_effect("diplomacy_spy_bonus")


func _get_empty_domestic_tech_city_spy_intel_bonus_mvp() -> Dictionary:
	return _ensure_domestic_tech_effect_provider().get_empty_effect("city_spy_bonus")


func _get_domestic_tech_city_military_defense_bonus_mvp(city_id: String) -> Dictionary:
	return _ensure_domestic_tech_effect_provider().get_city_military_defense_bonus(city_id, _is_city_owned_by_player_mvp(city_id), _get_completed_city_domestic_tech_snapshot_mvp(city_id))


func _get_player_city_defense_modifier_mvp(city_id: String) -> Dictionary:
	return _ensure_domestic_tech_effect_provider().get_city_defense_modifier(city_id, _is_city_owned_by_player_mvp(city_id), _get_completed_city_domestic_tech_snapshot_mvp(city_id))


func _merge_domestic_battle_source_techs_mvp(first: Variant, second: Variant) -> Array[String]:
	return _ensure_domestic_tech_effect_provider().merge_source_ids(first, second)


func _add_domestic_battle_modifier_values_mvp(base: Dictionary, addition: Dictionary) -> Dictionary:
	return _ensure_domestic_tech_effect_provider().add_battle_modifier_values(base, addition)


func _get_player_national_battle_modifier_mvp() -> Dictionary:
	return _ensure_domestic_tech_effect_provider().get_national_battle_modifier(_get_completed_national_domestic_tech_snapshot_mvp())


func _get_player_city_battle_modifier_mvp(city_id: String) -> Dictionary:
	return _ensure_domestic_tech_effect_provider().get_city_battle_modifier(city_id, _is_city_owned_by_player_mvp(city_id), _get_completed_city_domestic_tech_snapshot_mvp(city_id))


func _get_player_battle_tech_modifier_mvp(scope: String, city_id: String = "") -> Dictionary:
	return _ensure_domestic_tech_effect_provider().get_battle_modifier(scope, city_id, _is_city_owned_by_player_mvp(city_id), _get_completed_city_domestic_tech_snapshot_mvp(city_id), _get_completed_national_domestic_tech_snapshot_mvp())


func _get_domestic_tech_city_naval_siege_bonus_mvp(city_id: String) -> Dictionary:
	return _ensure_domestic_tech_effect_provider().get_city_naval_siege_bonus(city_id, _is_city_owned_by_player_mvp(city_id), _get_completed_city_domestic_tech_snapshot_mvp(city_id))


func _get_player_naval_unlock_modifier_mvp(city_id: String = "") -> Dictionary:
	return _ensure_domestic_tech_effect_provider().get_naval_unlock_modifier(city_id, _is_city_owned_by_player_mvp(city_id), _get_completed_city_domestic_tech_snapshot_mvp(city_id))


func _get_player_siege_unlock_modifier_mvp(city_id: String = "") -> Dictionary:
	return _ensure_domestic_tech_effect_provider().get_siege_unlock_modifier(city_id, _is_city_owned_by_player_mvp(city_id), _get_completed_city_domestic_tech_snapshot_mvp(city_id), _get_completed_national_domestic_tech_snapshot_mvp())


func _has_player_naval_unlock_modifier_data_mvp(unlock: Dictionary) -> bool:
	return _ensure_domestic_tech_effect_provider().has_naval_unlock_data(unlock)


func _has_player_siege_unlock_modifier_data_mvp(unlock: Dictionary) -> bool:
	return _ensure_domestic_tech_effect_provider().has_siege_unlock_data(unlock)


func _is_player_ship_unlocked_by_domestic_tech_mvp(ship_id: String, city_id: String = "") -> bool:
	return _ensure_domestic_tech_effect_provider().is_ship_unlocked(ship_id, _get_player_naval_unlock_modifier_mvp(city_id))


func _is_player_siege_unlocked_by_domestic_tech_mvp(siege_id: String, city_id: String = "") -> bool:
	return _ensure_domestic_tech_effect_provider().is_siege_unlocked(siege_id, _get_player_siege_unlock_modifier_mvp(city_id))


func _get_domestic_tech_national_policy_bonus_mvp() -> Dictionary:
	return _ensure_domestic_tech_effect_provider().get_national_policy_bonus(_get_completed_national_domestic_tech_snapshot_mvp())


func _get_national_domestic_economy_modifier_mvp() -> Dictionary:
	return _ensure_domestic_tech_effect_provider().get_national_economy_modifier(_get_completed_national_domestic_tech_snapshot_mvp())


func _merge_domestic_economy_source_techs_mvp(first: Variant, second: Variant) -> Array[String]:
	return _ensure_domestic_tech_effect_provider().merge_source_ids(first, second)


func _get_city_economy_tech_modifier_summary_mvp(city_id: String) -> Dictionary:
	var result := _get_empty_domestic_economy_modifier_mvp()
	result["city_id"] = city_id
	result["owner_scope"] = "unknown"
	result["same_city_only"] = true
	result["player_completed_tech_lookup"] = false
	result["enemy_research_effect"] = false
	if city_id.is_empty():
		result["masked"] = true
		result["reason"] = "empty_city"
		return result
	var city_data := _get_city_hud_entry(city_id)
	if _is_city_owned_by_player_mvp(city_id):
		var city_modifier := _get_player_city_domestic_economy_modifier_mvp(city_id)
		var national_modifier := _get_national_domestic_economy_modifier_mvp()
		result = city_modifier.duplicate(true)
		result["owner_scope"] = _get_current_player_faction_id()
		result["player_completed_tech_lookup"] = true
		result["national_gold_income_pct"] = float(national_modifier.get("gold_income_pct", 0.0))
		result["gold_income_pct"] = float(city_modifier.get("gold_income_pct", 0.0)) + float(national_modifier.get("gold_income_pct", 0.0))
		result["tax_pct"] = float(national_modifier.get("tax_pct", 0.0))
		result["admin_pct"] = float(national_modifier.get("admin_pct", 0.0))
		result["population_growth_pct"] = float(national_modifier.get("population_growth_pct", 0.0))
		result["storage_flat"] = int(national_modifier.get("storage_flat", 0))
		result["source_techs"] = _merge_domestic_economy_source_techs_mvp(city_modifier.get("source_techs", []), national_modifier.get("source_techs", []))
		return result
	if _is_city_owned_by_enemy_mvp(city_id):
		return _get_enemy_city_economy_baseline_mvp(city_data)
	result["masked"] = true
	result["reason"] = "non_player_unknown"
	return result


func _get_domestic_tech_diplomacy_spy_bonus_mvp() -> Dictionary:
	return _ensure_domestic_tech_effect_provider().get_diplomacy_spy_bonus(_get_completed_national_domestic_tech_snapshot_mvp())


func _get_domestic_tech_city_spy_intel_bonus_mvp(city_id: String) -> Dictionary:
	return _ensure_domestic_tech_effect_provider().get_city_spy_intel_bonus(city_id, _is_city_owned_by_player_mvp(city_id), _get_completed_city_domestic_tech_snapshot_mvp(city_id))


func _append_domestic_modifier_source_if_completed_mvp(modifier: Dictionary, tech_id: String) -> void:
	_ensure_domestic_tech_effect_provider().append_source_if_completed(
		modifier,
		tech_id,
		_get_completed_national_domestic_tech_snapshot_mvp()
	)


func _get_player_spy_tech_modifier_mvp(city_id: String = "") -> Dictionary:
	return _ensure_spy_controller().get_player_spy_tech_modifier(city_id)


func _get_modified_diplomacy_success_chance_mvp(base_chance: int, action_id: String, target_faction_id: String = "") -> int:
	return _ensure_diplomacy_controller()._get_modified_diplomacy_success_chance_mvp(base_chance, action_id, target_faction_id)


func _has_domestic_tech_national_policy_bonus_data_mvp(bonus: Dictionary) -> bool:
	return _ensure_domestic_tech_effect_provider().has_bonus_data("policy", bonus)


func _has_domestic_tech_diplomacy_spy_bonus_data_mvp(bonus: Dictionary) -> bool:
	return _ensure_domestic_tech_effect_provider().has_bonus_data("diplomacy_spy", bonus)


func _has_domestic_tech_city_spy_intel_bonus_data_mvp(bonus: Dictionary) -> bool:
	return _ensure_domestic_tech_effect_provider().has_bonus_data("city_spy", bonus)


func _has_domestic_tech_city_economy_bonus_mvp(city_id: String) -> bool:
	return _ensure_domestic_tech_effect_provider().has_bonus_data("economy", _get_domestic_tech_city_economy_bonus_mvp(city_id))


func _has_domestic_tech_city_military_defense_bonus_mvp(city_id: String) -> bool:
	return _ensure_domestic_tech_effect_provider().has_bonus_data("military", _get_domestic_tech_city_military_defense_bonus_mvp(city_id))


func _has_domestic_defense_modifier_data_mvp(modifier: Dictionary) -> bool:
	return _ensure_domestic_tech_effect_provider().has_bonus_data("defense", modifier)


func _has_domestic_battle_modifier_data_mvp(modifier: Dictionary) -> bool:
	return _ensure_domestic_tech_effect_provider().has_bonus_data("battle", modifier)


func _has_domestic_tech_city_naval_siege_bonus_mvp(city_id: String) -> bool:
	return _has_domestic_tech_city_naval_siege_bonus_data_mvp(_get_domestic_tech_city_naval_siege_bonus_mvp(city_id))


func _has_domestic_tech_city_naval_siege_bonus_data_mvp(bonus: Dictionary) -> bool:
	return _ensure_domestic_tech_effect_provider().has_bonus_data("naval_siege", bonus)


func _has_domestic_tech_national_policy_bonus_mvp() -> bool:
	return _has_domestic_tech_national_policy_bonus_data_mvp(_get_domestic_tech_national_policy_bonus_mvp())


func _has_domestic_tech_diplomacy_spy_bonus_mvp() -> bool:
	return _has_domestic_tech_diplomacy_spy_bonus_data_mvp(_get_domestic_tech_diplomacy_spy_bonus_mvp())


func _has_domestic_tech_city_spy_intel_bonus_mvp(city_id: String) -> bool:
	return _has_domestic_tech_city_spy_intel_bonus_data_mvp(_get_domestic_tech_city_spy_intel_bonus_mvp(city_id))


func _format_domestic_tech_percent_bonus_mvp(value: float) -> String:
	return DomesticTechHelperLib.format_percent_bonus_mvp(value)


func _get_unique_domestic_tech_source_ids_mvp(source_techs: Variant) -> Array[String]:
	return DomesticTechHelperLib.get_unique_source_ids_mvp(source_techs)


func _format_domestic_tech_source_display_mvp(source_techs: Variant, max_visible: int = 3) -> String:
	var unique_source_techs := _get_unique_domestic_tech_source_ids_mvp(source_techs)
	if unique_source_techs.is_empty():
		return ""
	var source_names: Array[String] = []
	var visible_count := clampi(max_visible, 1, 5)
	for index in range(mini(unique_source_techs.size(), visible_count)):
		source_names.append(_get_domestic_tech_display_name_mvp(str(unique_source_techs[index])))
	var suffix := ""
	if unique_source_techs.size() > source_names.size():
		suffix = " 외 %d개" % (unique_source_techs.size() - source_names.size())
	return "적용 테크: %s%s" % [", ".join(source_names), suffix]


func _format_domestic_tech_city_economy_bonus_lines_mvp(city_id: String, include_sources: bool = true) -> Array[String]:
	var result: Array[String] = []
	if city_id.is_empty() or not _is_city_owned_by_player_mvp(city_id):
		return result
	var modifier := _get_player_city_domestic_economy_modifier_mvp(city_id)
	if not _has_domestic_tech_city_economy_modifier_data_mvp(modifier):
		return result
	var resource_parts: Array[String] = []
	var food_percent := float(modifier.get("food_income_pct", 0.0))
	var gold_percent := float(modifier.get("gold_income_pct", 0.0))
	var supply_percent := float(modifier.get("storage_cap_pct", 0.0))
	if not is_equal_approx(food_percent, 0.0):
		resource_parts.append("식량 %s" % _format_domestic_tech_percent_bonus_mvp(food_percent))
	if int(modifier.get("food_flat", 0)) != 0:
		resource_parts.append("식량 %s" % _format_signed_int(int(modifier.get("food_flat", 0))))
	if not is_equal_approx(gold_percent, 0.0):
		resource_parts.append("금전 %s" % _format_domestic_tech_percent_bonus_mvp(gold_percent))
	if int(modifier.get("gold_flat", 0)) != 0:
		resource_parts.append("금전 %s" % _format_signed_int(int(modifier.get("gold_flat", 0))))
	if not is_equal_approx(supply_percent, 0.0):
		resource_parts.append("보급 %s" % _format_domestic_tech_percent_bonus_mvp(supply_percent))
	if int(modifier.get("supply_flat", 0)) != 0:
		resource_parts.append("보급 %s" % _format_signed_int(int(modifier.get("supply_flat", 0))))
	if not resource_parts.is_empty():
		result.append("테크 경제: %s" % ", ".join(resource_parts.slice(0, 5)))
	if include_sources:
		var source_display := _format_domestic_tech_source_display_mvp(modifier.get("source_techs", []))
		if not source_display.is_empty():
			result.append(source_display)
	return result


func _has_domestic_tech_city_economy_modifier_data_mvp(modifier: Dictionary) -> bool:
	return int(modifier.get("food_flat", 0)) != 0 \
		or not is_equal_approx(float(modifier.get("food_income_pct", 0.0)), 0.0) \
		or int(modifier.get("gold_flat", 0)) != 0 \
		or not is_equal_approx(float(modifier.get("gold_income_pct", 0.0)), 0.0) \
		or int(modifier.get("supply_flat", 0)) != 0 \
		or int(modifier.get("storage_flat", 0)) != 0 \
		or not is_equal_approx(float(modifier.get("storage_cap_pct", 0.0)), 0.0) \
		or not is_equal_approx(float(modifier.get("tax_pct", 0.0)), 0.0) \
		or not is_equal_approx(float(modifier.get("admin_pct", 0.0)), 0.0) \
		or not is_equal_approx(float(modifier.get("population_growth_pct", 0.0)), 0.0)


func _format_city_economy_tech_modifier_summary_mvp(city_id: String) -> String:
	var summary := _get_city_economy_tech_modifier_summary_mvp(city_id)
	if bool(summary.get("enemy_baseline", false)):
		if bool(summary.get("masked", false)):
			return "상대 도시 기본 체급\n정보 부족: 정탐 후 확인"
		return "상대 도시 기본 체급\n경제 %s / 보급 %s / 방어 준비도 %s" % [
			str(summary.get("economy_grade_label", "보통")),
			str(summary.get("supply_grade_label", "보통")),
			str(summary.get("defense_grade_label", "보통")),
		]
	if not _is_city_owned_by_player_mvp(city_id) or not _has_domestic_tech_city_economy_modifier_data_mvp(summary):
		return ""
	var parts: Array[String] = []
	if not is_equal_approx(float(summary.get("gold_income_pct", 0.0)), 0.0):
		parts.append("금 수입 %s" % _format_domestic_tech_percent_bonus_mvp(float(summary.get("gold_income_pct", 0.0))))
	if int(summary.get("gold_flat", 0)) != 0:
		parts.append("금 수입 %s" % _format_signed_int(int(summary.get("gold_flat", 0))))
	if not is_equal_approx(float(summary.get("food_income_pct", 0.0)), 0.0):
		parts.append("군량 생산 %s" % _format_domestic_tech_percent_bonus_mvp(float(summary.get("food_income_pct", 0.0))))
	if int(summary.get("food_flat", 0)) != 0:
		parts.append("군량 생산 %s" % _format_signed_int(int(summary.get("food_flat", 0))))
	if int(summary.get("supply_flat", 0)) != 0:
		parts.append("보급 %s" % _format_signed_int(int(summary.get("supply_flat", 0))))
	if int(summary.get("storage_flat", 0)) != 0:
		parts.append("국가 비축 %s" % _format_signed_int(int(summary.get("storage_flat", 0))))
	if not is_equal_approx(float(summary.get("admin_pct", 0.0)), 0.0):
		parts.append("행정 %s" % _format_domestic_tech_percent_bonus_mvp(float(summary.get("admin_pct", 0.0))))
	if not is_equal_approx(float(summary.get("population_growth_pct", 0.0)), 0.0):
		parts.append("인구 기반 %s" % _format_domestic_tech_percent_bonus_mvp(float(summary.get("population_growth_pct", 0.0))))
	if parts.is_empty():
		return ""
	var source_display := _format_domestic_tech_source_display_mvp(summary.get("source_techs", []), 2)
	var suffix := "" if source_display.is_empty() else "\n%s" % source_display
	return "내정 연구 경제 보정\n%s%s" % [", ".join(parts.slice(0, 5)), suffix]


func _format_national_domestic_economy_modifier_summary_mvp() -> String:
	var modifier := _get_national_domestic_economy_modifier_mvp()
	if not _has_domestic_tech_city_economy_modifier_data_mvp(modifier):
		return ""
	var parts: Array[String] = []
	if not is_equal_approx(float(modifier.get("tax_pct", 0.0)), 0.0):
		parts.append("세금 %s" % _format_domestic_tech_percent_bonus_mvp(float(modifier.get("tax_pct", 0.0))))
	if not is_equal_approx(float(modifier.get("admin_pct", 0.0)), 0.0):
		parts.append("행정 %s" % _format_domestic_tech_percent_bonus_mvp(float(modifier.get("admin_pct", 0.0))))
	if not is_equal_approx(float(modifier.get("population_growth_pct", 0.0)), 0.0):
		parts.append("인구 기반 %s" % _format_domestic_tech_percent_bonus_mvp(float(modifier.get("population_growth_pct", 0.0))))
	if int(modifier.get("storage_flat", 0)) != 0:
		parts.append("비축 기반 %s" % _format_signed_int(int(modifier.get("storage_flat", 0))))
	if parts.is_empty():
		return ""
	return "내정 연구 국가경제 보정: %s" % ", ".join(parts.slice(0, 5))


func _format_domestic_tech_national_policy_bonus_lines_mvp(include_sources: bool = true) -> Array[String]:
	var result: Array[String] = []
	var bonus := _get_domestic_tech_national_policy_bonus_mvp()
	if not _has_domestic_tech_national_policy_bonus_data_mvp(bonus):
		return result
	var policy_parts: Array[String] = []
	var tax_gold_percent := float(bonus.get("tax_gold_percent", 0.0))
	var admin_efficiency_percent := float(bonus.get("admin_efficiency_percent", 0.0))
	var recruit_capacity_percent := float(bonus.get("recruit_capacity_percent", 0.0))
	var logistics_supply_percent := float(bonus.get("logistics_supply_percent", 0.0))
	var population_growth_percent := float(bonus.get("population_growth_percent", 0.0))
	if not is_equal_approx(tax_gold_percent, 0.0):
		policy_parts.append("세금 수입 %s" % _format_domestic_tech_percent_bonus_mvp(tax_gold_percent))
	if not is_equal_approx(admin_efficiency_percent, 0.0):
		policy_parts.append("행정 준비 %s" % _format_domestic_tech_percent_bonus_mvp(admin_efficiency_percent))
	if not is_equal_approx(recruit_capacity_percent, 0.0):
		policy_parts.append("징병 기반 %s" % _format_domestic_tech_percent_bonus_mvp(recruit_capacity_percent))
	if not is_equal_approx(logistics_supply_percent, 0.0):
		policy_parts.append("병참 준비 %s" % _format_domestic_tech_percent_bonus_mvp(logistics_supply_percent))
	if not is_equal_approx(population_growth_percent, 0.0):
		policy_parts.append("인구 기반 %s" % _format_domestic_tech_percent_bonus_mvp(population_growth_percent))
	if int(bonus.get("storage_flat", 0)) != 0:
		policy_parts.append("비축 기반 %s" % _format_signed_int(int(bonus.get("storage_flat", 0))))
	if int(bonus.get("law_order_flat", 0)) != 0:
		policy_parts.append("질서 기반 %s" % _format_signed_int(int(bonus.get("law_order_flat", 0))))
	if not policy_parts.is_empty():
		result.append("테크 국가정책: %s" % ", ".join(policy_parts.slice(0, 5)))
	if include_sources:
		var source_display := _format_domestic_tech_source_display_mvp(bonus.get("source_techs", []))
		if not source_display.is_empty():
			result.append(source_display)
	return result


func _format_domestic_tech_diplomacy_spy_bonus_lines_mvp(include_sources: bool = true) -> Array[String]:
	var result: Array[String] = []
	var bonus := _get_domestic_tech_diplomacy_spy_bonus_mvp()
	if not _has_domestic_tech_diplomacy_spy_bonus_data_mvp(bonus):
		return result
	var diplomacy_parts: Array[String] = []
	if int(bonus.get("diplomacy_influence_flat", 0)) != 0:
		diplomacy_parts.append("외교 기반 %s" % _format_signed_int(int(bonus.get("diplomacy_influence_flat", 0))))
	if not is_equal_approx(float(bonus.get("diplomacy_preparation_percent", 0.0)), 0.0):
		diplomacy_parts.append("외교 준비 %s" % _format_domestic_tech_percent_bonus_mvp(float(bonus.get("diplomacy_preparation_percent", 0.0))))
	if not is_equal_approx(float(bonus.get("tribute_readiness_percent", 0.0)), 0.0):
		diplomacy_parts.append("조공 준비 %s" % _format_domestic_tech_percent_bonus_mvp(float(bonus.get("tribute_readiness_percent", 0.0))))
	if not is_equal_approx(float(bonus.get("world_diplomacy_display_percent", 0.0)), 0.0):
		diplomacy_parts.append("대외 기반 %s" % _format_domestic_tech_percent_bonus_mvp(float(bonus.get("world_diplomacy_display_percent", 0.0))))
	var spy_parts: Array[String] = []
	if int(bonus.get("spy_network_flat", 0)) != 0:
		spy_parts.append("정보망 %s" % _format_signed_int(int(bonus.get("spy_network_flat", 0))))
	if not is_equal_approx(float(bonus.get("spy_preparation_percent", 0.0)), 0.0):
		spy_parts.append("첩보 준비 %s" % _format_domestic_tech_percent_bonus_mvp(float(bonus.get("spy_preparation_percent", 0.0))))
	if not is_equal_approx(float(bonus.get("counter_intel_display_percent", 0.0)), 0.0):
		spy_parts.append("방첩 준비 %s" % _format_domestic_tech_percent_bonus_mvp(float(bonus.get("counter_intel_display_percent", 0.0))))
	var display_parts: Array[String] = []
	display_parts.append_array(diplomacy_parts)
	display_parts.append_array(spy_parts)
	if not display_parts.is_empty():
		result.append("테크 외교/첩보: %s" % ", ".join(display_parts.slice(0, 5)))
	if include_sources:
		var source_display := _format_domestic_tech_source_display_mvp(bonus.get("source_techs", []))
		if not source_display.is_empty():
			result.append(source_display)
	return result


func _format_player_spy_tech_modifier_summary_mvp(target_city_id: String = "") -> String:
	return _ensure_spy_presenter().format_player_tech_modifier_summary(target_city_id)


func _get_domestic_tech_city_defense_display_value_mvp(city_id: String, city_data: Dictionary) -> int:
	var base_defense := maxi(0, int(city_data.get("defense", 0)))
	if city_id.is_empty() or not _is_city_owned_by_player_mvp(city_id):
		return base_defense
	var modifier := _get_player_city_defense_modifier_mvp(city_id)
	var defense_percent := maxf(0.0, float(modifier.get("city_defense_pct", 0.0)))
	var defense_flat := maxi(0, int(modifier.get("city_defense_flat", 0)))
	var percent_value := int(round(float(base_defense) * (1.0 + defense_percent)))
	return maxi(0, percent_value + defense_flat)


func _format_city_defense_battle_modifier_summary_mvp(city_id: String, city_data: Dictionary = {}) -> String:
	if city_id.is_empty():
		return ""
	if _is_city_owned_by_enemy_mvp(city_id):
		var baseline := _get_enemy_city_defense_baseline_mvp(city_data)
		if bool(baseline.get("masked", true)):
			return "상대 도시 기본 방어 체급\n정보 부족: 정탐 후 확인"
		return "상대 도시 기본 방어 체급\n방어 %s / 주둔 %s / 전투 %s" % [
			str(baseline.get("defense_grade_label", "보통")),
			str(baseline.get("garrison_grade_label", "보통")),
			str(baseline.get("battle_grade_label", "보통")),
		]
	if not _is_city_owned_by_player_mvp(city_id):
		return ""
	var defense_modifier := _get_player_city_defense_modifier_mvp(city_id)
	var battle_modifier := _get_player_battle_tech_modifier_mvp("combined", city_id)
	if not _has_domestic_defense_modifier_data_mvp(defense_modifier) and not _has_domestic_battle_modifier_data_mvp(battle_modifier):
		return ""
	var parts: Array[String] = []
	if int(defense_modifier.get("city_defense_flat", 0)) != 0:
		parts.append("도시 방어 %s" % _format_signed_int(int(defense_modifier.get("city_defense_flat", 0))))
	if not is_equal_approx(float(defense_modifier.get("city_defense_pct", 0.0)), 0.0):
		parts.append("도시 방어 %s" % _format_domestic_tech_percent_bonus_mvp(float(defense_modifier.get("city_defense_pct", 0.0))))
	if not is_equal_approx(float(defense_modifier.get("siege_resistance_pct", 0.0)), 0.0):
		parts.append("공성 저항 %s" % _format_domestic_tech_percent_bonus_mvp(float(defense_modifier.get("siege_resistance_pct", 0.0))))
	if not is_equal_approx(float(battle_modifier.get("global_attack_pct", 0.0)), 0.0):
		parts.append("전군 공격 %s" % _format_domestic_tech_percent_bonus_mvp(float(battle_modifier.get("global_attack_pct", 0.0))))
	if not is_equal_approx(float(battle_modifier.get("global_defense_pct", 0.0)), 0.0):
		parts.append("전군 방어 %s" % _format_domestic_tech_percent_bonus_mvp(float(battle_modifier.get("global_defense_pct", 0.0))))
	if not is_equal_approx(float(battle_modifier.get("infantry_attack_pct", 0.0)), 0.0):
		parts.append("보병 공격 %s" % _format_domestic_tech_percent_bonus_mvp(float(battle_modifier.get("infantry_attack_pct", 0.0))))
	if not is_equal_approx(float(battle_modifier.get("archer_attack_pct", 0.0)), 0.0):
		parts.append("궁병 공격 %s" % _format_domestic_tech_percent_bonus_mvp(float(battle_modifier.get("archer_attack_pct", 0.0))))
	if not is_equal_approx(float(battle_modifier.get("cavalry_attack_pct", 0.0)), 0.0):
		parts.append("기병 공격 %s" % _format_domestic_tech_percent_bonus_mvp(float(battle_modifier.get("cavalry_attack_pct", 0.0))))
	if not is_equal_approx(float(battle_modifier.get("cavalry_charge_pct", 0.0)), 0.0):
		parts.append("기병 돌격 %s" % _format_domestic_tech_percent_bonus_mvp(float(battle_modifier.get("cavalry_charge_pct", 0.0))))
	if parts.is_empty():
		return ""
	var source_display := _format_domestic_tech_source_display_mvp(battle_modifier.get("source_techs", []), 2)
	var suffix := "" if source_display.is_empty() else "\n%s" % source_display
	return "내정 연구 방어/전투 보정\n%s%s" % [", ".join(parts.slice(0, 6)), suffix]


func _format_domestic_tech_city_military_defense_bonus_lines_mvp(city_id: String, city_data: Dictionary = {}, include_sources: bool = true) -> Array[String]:
	var result: Array[String] = []
	if city_id.is_empty():
		return result
	if _is_city_owned_by_enemy_mvp(city_id):
		var enemy_summary := _format_city_defense_battle_modifier_summary_mvp(city_id, city_data)
		if not enemy_summary.is_empty():
			result.append(enemy_summary)
		return result
	if not _is_city_owned_by_player_mvp(city_id):
		return result
	var bonus := _get_domestic_tech_city_military_defense_bonus_mvp(city_id)
	var modifier_summary := _format_city_defense_battle_modifier_summary_mvp(city_id, city_data)
	if not _has_domestic_tech_city_military_defense_bonus_mvp(city_id) and modifier_summary.is_empty():
		return result
	var resource_parts: Array[String] = []
	var defense_percent := float(bonus.get("defense_percent", 0.0))
	if int(bonus.get("defense_flat", 0)) != 0:
		resource_parts.append("방어 준비 %s" % _format_signed_int(int(bonus.get("defense_flat", 0))))
	if not is_equal_approx(defense_percent, 0.0):
		resource_parts.append("방어 준비 %s" % _format_domestic_tech_percent_bonus_mvp(defense_percent))
	if int(bonus.get("recruit_capacity_flat", 0)) != 0:
		resource_parts.append("모집 기반 %s" % _format_signed_int(int(bonus.get("recruit_capacity_flat", 0))))
	if not is_equal_approx(float(bonus.get("training_percent", 0.0)), 0.0):
		resource_parts.append("훈련 기반 %s" % _format_domestic_tech_percent_bonus_mvp(float(bonus.get("training_percent", 0.0))))
	if not is_equal_approx(float(bonus.get("infantry_training_percent", 0.0)), 0.0):
		resource_parts.append("보병 기반 %s" % _format_domestic_tech_percent_bonus_mvp(float(bonus.get("infantry_training_percent", 0.0))))
	if not is_equal_approx(float(bonus.get("archer_training_percent", 0.0)), 0.0):
		resource_parts.append("궁병 기반 %s" % _format_domestic_tech_percent_bonus_mvp(float(bonus.get("archer_training_percent", 0.0))))
	if not is_equal_approx(float(bonus.get("cavalry_training_percent", 0.0)), 0.0):
		resource_parts.append("기병 기반 %s" % _format_domestic_tech_percent_bonus_mvp(float(bonus.get("cavalry_training_percent", 0.0))))
	if not is_equal_approx(float(bonus.get("cavalry_charge_percent", 0.0)), 0.0):
		resource_parts.append("기병 돌격 %s" % _format_domestic_tech_percent_bonus_mvp(float(bonus.get("cavalry_charge_percent", 0.0))))
	if not city_data.is_empty() and (int(bonus.get("defense_flat", 0)) != 0 or not is_equal_approx(defense_percent, 0.0)):
		resource_parts.append("방어 표시 %d→%d" % [
			maxi(0, int(city_data.get("defense", 0))),
			_get_domestic_tech_city_defense_display_value_mvp(city_id, city_data),
		])
	if not resource_parts.is_empty():
		result.append("테크 군사/방어: %s" % ", ".join(resource_parts.slice(0, 5)))
	if not modifier_summary.is_empty():
		result.append(modifier_summary)
	if include_sources:
		var source_display := _format_domestic_tech_source_display_mvp(bonus.get("source_techs", []))
		if not source_display.is_empty():
			result.append(source_display)
	return result


func _format_domestic_tech_city_naval_siege_bonus_lines_mvp(city_id: String, include_sources: bool = true) -> Array[String]:
	var result: Array[String] = []
	if city_id.is_empty():
		return result
	var city_data := _get_city_hud_entry(city_id)
	if _is_city_owned_by_enemy_mvp(city_id):
		var naval_baseline := _get_enemy_naval_baseline_mvp(city_data)
		var siege_baseline := _get_enemy_siege_baseline_mvp(city_data)
		if bool(naval_baseline.get("masked", true)) and bool(siege_baseline.get("masked", true)):
			result.append("상대 해군/공성 기본 체급\n정보 부족: 정탐 후 확인")
			return result
		var enemy_parts: Array[String] = []
		if not bool(naval_baseline.get("masked", true)):
			enemy_parts.append("해군 %s" % str(naval_baseline.get("naval_grade_label", "보통")))
			enemy_parts.append("항구/조선 기반 %s" % str(naval_baseline.get("shipyard_basis_label", "불명")))
		if not bool(siege_baseline.get("masked", true)):
			enemy_parts.append("공성 %s" % str(siege_baseline.get("siege_grade_label", "보통")))
		if not enemy_parts.is_empty():
			result.append("상대 해군/공성 기본 체급: %s" % ", ".join(enemy_parts.slice(0, 4)))
		return result
	if not _is_city_owned_by_player_mvp(city_id):
		return result
	var bonus := _get_domestic_tech_city_naval_siege_bonus_mvp(city_id)
	var naval_unlock := _get_player_naval_unlock_modifier_mvp(city_id)
	var siege_unlock := _get_player_siege_unlock_modifier_mvp(city_id)
	if not _has_domestic_tech_city_naval_siege_bonus_data_mvp(bonus) \
			and not _has_player_naval_unlock_modifier_data_mvp(naval_unlock) \
			and not _has_player_siege_unlock_modifier_data_mvp(siege_unlock):
		return result
	var naval_parts: Array[String] = []
	if bool(naval_unlock.get("port_enabled", false)):
		naval_parts.append("항구 사용 가능")
	if bool(naval_unlock.get("shipyard_enabled", false)):
		naval_parts.append("조선소 사용 가능")
	if bool(naval_unlock.get("warship_enabled", false)):
		naval_parts.append("전투선 생산 가능")
	if bool(naval_unlock.get("panokseon_enabled", false)):
		naval_parts.append("판옥선 생산 가능")
	if bool(naval_unlock.get("turtle_ship_enabled", false)):
		naval_parts.append("거북선 생산 가능")
	if bool(naval_unlock.get("fire_ship_enabled", false)):
		naval_parts.append("화공선 사용 가능")
	if int(bonus.get("shipyard_capacity_flat", 0)) != 0:
		naval_parts.append("조선 준비 %s" % _format_signed_int(int(bonus.get("shipyard_capacity_flat", 0))))
	if not is_equal_approx(float(bonus.get("naval_training_percent", 0.0)), 0.0):
		naval_parts.append("수군 기반 %s" % _format_domestic_tech_percent_bonus_mvp(float(bonus.get("naval_training_percent", 0.0))))
	if not is_equal_approx(float(naval_unlock.get("naval_formation_pct", 0.0)), 0.0):
		naval_parts.append("수군 진형 %s" % _format_domestic_tech_percent_bonus_mvp(float(naval_unlock.get("naval_formation_pct", 0.0))))
	if not is_equal_approx(float(bonus.get("naval_supply_percent", 0.0)), 0.0):
		naval_parts.append("해상 보급 준비 %s" % _format_domestic_tech_percent_bonus_mvp(float(bonus.get("naval_supply_percent", 0.0))))
	if not is_equal_approx(float(bonus.get("ship_maintenance_percent", 0.0)), 0.0):
		naval_parts.append("함선 정비 준비 %s" % _format_domestic_tech_percent_bonus_mvp(float(bonus.get("ship_maintenance_percent", 0.0))))
	var siege_parts: Array[String] = []
	if bool(siege_unlock.get("siege_unit_enabled", false)):
		siege_parts.append("공성부대 편성 가능")
	if bool(siege_unlock.get("siege_engine_enabled", false)):
		siege_parts.append("공성병기 사용 가능")
	if bool(siege_unlock.get("artillery_enabled", false)):
		siege_parts.append("화포 사용 가능")
	if int(bonus.get("siege_preparation_flat", 0)) != 0:
		siege_parts.append("공성 준비 %s" % _format_signed_int(int(bonus.get("siege_preparation_flat", 0))))
	if not is_equal_approx(float(bonus.get("siege_training_percent", 0.0)), 0.0):
		siege_parts.append("공성 훈련 %s" % _format_domestic_tech_percent_bonus_mvp(float(bonus.get("siege_training_percent", 0.0))))
	if not is_equal_approx(float(bonus.get("siege_engineering_percent", 0.0)), 0.0):
		siege_parts.append("공성 공학 %s" % _format_domestic_tech_percent_bonus_mvp(float(bonus.get("siege_engineering_percent", 0.0))))
	if not is_equal_approx(float(siege_unlock.get("logistics_pct", 0.0)), 0.0):
		siege_parts.append("병참 준비 %s" % _format_domestic_tech_percent_bonus_mvp(float(siege_unlock.get("logistics_pct", 0.0))))
	if not is_equal_approx(float(siege_unlock.get("expedition_pct", 0.0)), 0.0):
		siege_parts.append("원정 준비 %s" % _format_domestic_tech_percent_bonus_mvp(float(siege_unlock.get("expedition_pct", 0.0))))
	var naval_siege_parts: Array[String] = []
	naval_siege_parts.append_array(naval_parts)
	naval_siege_parts.append_array(siege_parts)
	if not naval_siege_parts.is_empty():
		result.append("테크 해군/공성: %s" % ", ".join(naval_siege_parts.slice(0, 5)))
	if include_sources:
		var source_techs: Array = []
		var bonus_sources: Variant = bonus.get("source_techs", [])
		var naval_sources: Variant = naval_unlock.get("source_techs", [])
		var siege_sources: Variant = siege_unlock.get("source_techs", [])
		if bonus_sources is Array:
			source_techs.append_array(bonus_sources as Array)
		if naval_sources is Array:
			source_techs.append_array(naval_sources as Array)
		if siege_sources is Array:
			source_techs.append_array(siege_sources as Array)
		var source_display := _format_domestic_tech_source_display_mvp(source_techs)
		if not source_display.is_empty():
			result.append(source_display)
	return result


func _format_domestic_tech_city_spy_intel_bonus_lines_mvp(city_id: String, include_sources: bool = true) -> Array[String]:
	var result: Array[String] = []
	if city_id.is_empty() or not _is_city_owned_by_player_mvp(city_id):
		return result
	if _ensure_domestic_tech_effect_provider().is_effect_group_empty("city_spy_intel"):
		return result
	var bonus := _get_domestic_tech_city_spy_intel_bonus_mvp(city_id)
	if not _has_domestic_tech_city_spy_intel_bonus_data_mvp(bonus):
		return result
	var spy_parts: Array[String] = []
	if int(bonus.get("local_spy_network_flat", 0)) != 0:
		spy_parts.append("지역 정보망 %s" % _format_signed_int(int(bonus.get("local_spy_network_flat", 0))))
	if not is_equal_approx(float(bonus.get("local_counter_intel_display_percent", 0.0)), 0.0):
		spy_parts.append("지역 방첩 준비 %s" % _format_domestic_tech_percent_bonus_mvp(float(bonus.get("local_counter_intel_display_percent", 0.0))))
	if not is_equal_approx(float(bonus.get("local_intel_readiness_percent", 0.0)), 0.0):
		spy_parts.append("지역 정보 준비 %s" % _format_domestic_tech_percent_bonus_mvp(float(bonus.get("local_intel_readiness_percent", 0.0))))
	if not spy_parts.is_empty():
		result.append("도시 첩보 준비: %s" % ", ".join(spy_parts.slice(0, 5)))
	if include_sources:
		var source_display := _format_domestic_tech_source_display_mvp(bonus.get("source_techs", []))
		if not source_display.is_empty():
			result.append(source_display)
	return result


func _get_domestic_tech_economy_turn_summary_mvp() -> Dictionary:
	return _ensure_domestic_tech_effect_provider().get_economy_turn_summary(_player_state.get("owned_city_ids", []), _normalize_city_domestic_tech_state_map_mvp(_player_state.get("city_domestic_tech_completed", {})))


func _format_domestic_tech_economy_turn_summary_mvp(summary: Dictionary) -> String:
	var cities: Variant = summary.get("cities", [])
	if not cities is Array or (cities as Array).is_empty():
		return ""
	var parts: Array[String] = []
	for index in range(mini((cities as Array).size(), 3)):
		var city_entry_variant: Variant = (cities as Array)[index]
		if not city_entry_variant is Dictionary:
			continue
		var city_entry := city_entry_variant as Dictionary
		var city_id := str(city_entry.get("city_id", ""))
		var resource_parts: Array[String] = []
		var food_percent := float(city_entry.get("food_percent", 0.0))
		var gold_percent := float(city_entry.get("gold_percent", 0.0))
		if not is_equal_approx(food_percent, 0.0):
			resource_parts.append("식량 %s" % _format_domestic_tech_percent_bonus_mvp(food_percent))
		if int(city_entry.get("food_flat", 0)) != 0:
			resource_parts.append("식량 %s" % _format_signed_int(int(city_entry.get("food_flat", 0))))
		if not is_equal_approx(gold_percent, 0.0):
			resource_parts.append("금전 %s" % _format_domestic_tech_percent_bonus_mvp(gold_percent))
		if int(city_entry.get("gold_flat", 0)) != 0:
			resource_parts.append("금전 %s" % _format_signed_int(int(city_entry.get("gold_flat", 0))))
		if int(city_entry.get("supply_flat", 0)) != 0:
			resource_parts.append("보급 %s" % _format_signed_int(int(city_entry.get("supply_flat", 0))))
		if resource_parts.is_empty():
			continue
		var source_text := _format_domestic_tech_source_display_mvp(city_entry.get("source_techs", []), 2)
		parts.append("%s %s (%s)" % [_format_city_name_by_id(city_id, city_id), ", ".join(resource_parts), source_text])
	var city_suffix := ""
	var city_count := int(summary.get("city_count", (cities as Array).size()))
	if city_count > parts.size():
		city_suffix = " 외 %d개 도시" % (city_count - parts.size())
	return "" if parts.is_empty() else "내정 테크 경제 보너스: %s%s" % [" / ".join(parts), city_suffix]


func _are_domestic_tech_prerequisites_met_mvp(city_id: String, tech_id: String) -> bool:
	var definition := _get_domestic_tech_definition_mvp(tech_id)
	return _ensure_domestic_tech_research_rules().are_prerequisites_met(
		definition,
		_get_completed_city_domestic_tech_snapshot_mvp(city_id),
		_get_completed_national_domestic_tech_snapshot_mvp()
	)


func _are_domestic_tech_national_requirements_met_mvp(tech_id: String) -> bool:
	var definition := _get_domestic_tech_definition_mvp(tech_id)
	return _ensure_domestic_tech_research_rules().are_national_requirements_met(
		definition,
		_get_completed_national_domestic_tech_snapshot_mvp()
	)


func _are_required_national_techs_completed_mvp(required_ids: Array) -> bool:
	return _ensure_domestic_tech_research_rules().are_national_requirements_met(
		{"required_national_techs": required_ids.duplicate(true)},
		_get_completed_national_domestic_tech_snapshot_mvp()
	)


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
	return _ensure_domestic_tech_research_rules().are_city_requirements_met(
		definition,
		city_id,
		Callable(self, "_query_domestic_tech_world_fact_mvp")
	)


func _get_completed_city_domestic_tech_snapshot_mvp(city_id: String) -> Dictionary:
	return _ensure_domestic_tech_research_service().get_city_completed_snapshot(city_id)


func _get_completed_national_domestic_tech_snapshot_mvp() -> Dictionary:
	return _ensure_domestic_tech_research_service().get_national_completed_snapshot()


func _query_domestic_tech_world_fact_mvp(query_id: String, args: Array) -> Variant:
	match query_id:
		"is_city_coastal":
			var city_id := str(args[0]) if not args.is_empty() else ""
			return _is_city_coastal_for_city_tech(city_id)
	return null


func _get_domestic_tech_icon_path_mvp(tech_id: String) -> String:
	return str(_get_domestic_tech_definition_mvp(tech_id).get("icon_path", ""))


func _get_domestic_tech_ui64_icon_filename_mvp(tech_id: String) -> String:
	return _ensure_domestic_tech_tree_presentation_controller()._get_domestic_tech_ui64_icon_filename_mvp(tech_id)


func _get_domestic_tech_resolved_icon_path_mvp(tech_id: String, definition_icon_path: String = "") -> String:
	return _ensure_domestic_tech_tree_presentation_controller()._get_domestic_tech_resolved_icon_path_mvp(tech_id, definition_icon_path)


func _is_domestic_tech_icon_missing_mvp(tech_id: String) -> bool:
	return bool(_get_domestic_tech_definition_mvp(tech_id).get("icon_missing", true))


func _get_domestic_tech_icon_fallback_label_mvp(tech_id: String) -> String:
	return str(_get_domestic_tech_definition_mvp(tech_id).get("icon_fallback_label", DOMESTIC_TECH_ICON_FALLBACK_LABEL))


func _open_domestic_tech_tree_overlay_mvp() -> void:
	_hide_worldmap_panels_for_tech_tree_mvp()
	_ensure_domestic_tech_tree_presentation_controller().open()


func _close_domestic_tech_tree_overlay_mvp() -> void:
	_ensure_domestic_tech_tree_presentation_controller().close()
	_restore_worldmap_panels_after_tech_tree_mvp()


func _is_domestic_tech_tree_overlay_open_mvp() -> bool:
	return _domestic_tech_tree_presentation_controller != null and _domestic_tech_tree_presentation_controller.is_open()


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
	_register_tech_tree_hidden_panel_mvp(_ensure_shared_ui_controller().get_help_modal(), "worldmap_help_modal")
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
	if _domestic_tech_tree_presentation_controller != null and panel == _domestic_tech_tree_presentation_controller.get_overlay():
		return
	_tech_tree_hidden_ui_state_mvp[key] = {
		"node": panel,
		"visible": panel.visible,
	}
	if panel.visible:
		panel.visible = false


func _ensure_domestic_tech_tree_overlay_mvp() -> void:
	_ensure_domestic_tech_tree_presentation_controller()._ensure_domestic_tech_tree_overlay_mvp()


func _refresh_domestic_tech_tree_overlay_mvp() -> void:
	_ensure_domestic_tech_tree_presentation_controller()._refresh_domestic_tech_tree_overlay_mvp()


func _build_national_tech_tree_panel_mvp(parent: Container) -> void:
	_ensure_domestic_tech_tree_presentation_controller()._build_national_tech_tree_panel_mvp(parent)


func _build_city_tech_tree_panel_mvp(parent: Container, city_id: String) -> void:
	_ensure_domestic_tech_tree_presentation_controller()._build_city_tech_tree_panel_mvp(parent, city_id)


func _build_domestic_tech_detail_inspector_mvp(parent: Container) -> void:
	_ensure_domestic_tech_tree_presentation_controller()._build_domestic_tech_detail_inspector_mvp(parent)


func _build_domestic_tech_detail_placeholders_mvp(parent: HBoxContainer) -> void:
	_ensure_domestic_tech_tree_presentation_controller()._build_domestic_tech_detail_placeholders_mvp(parent)


func _make_domestic_tech_detail_placeholder_mvp(node_name: String, title_text: String, style_source: PanelContainer) -> PanelContainer:
	return _ensure_domestic_tech_tree_presentation_controller()._make_domestic_tech_detail_placeholder_mvp(node_name, title_text, style_source)


func _refresh_domestic_tech_detail_inspector_mvp() -> void:
	_ensure_domestic_tech_tree_presentation_controller()._refresh_domestic_tech_detail_inspector_mvp()


func _route_domestic_tech_detail_region_mvp() -> void:
	_ensure_domestic_tech_tree_presentation_controller()._route_domestic_tech_detail_region_mvp()


func _format_domestic_tech_detail_text_mvp(tech_def: Dictionary, view_state: Dictionary, city_id: String = "") -> String:
	return _ensure_domestic_tech_tree_presentation_controller()._format_domestic_tech_detail_text_mvp(tech_def, view_state, city_id)


func _get_domestic_tech_cost_summary_mvp(tech_def: Dictionary) -> String:
	return _format_domestic_tech_cost_mvp(tech_def.get("cost", {}))


func _get_domestic_tech_research_cost_balance_adjustment_mvp(tech_def: Dictionary, base_gold_cost: int, base_food_cost: int) -> Dictionary:
	return _ensure_domestic_tech_research_rules().get_research_cost_balance_adjustment(tech_def, base_gold_cost, base_food_cost)


func _get_domestic_tech_research_cost_plan_mvp(tech_def: Dictionary, scope: String = "") -> Dictionary:
	return _ensure_domestic_tech_research_rules().get_research_cost_plan(tech_def, scope)


func _format_domestic_tech_research_plan_lines_mvp(tech_def: Dictionary, view_state: Dictionary, scope: String = "") -> Array[String]:
	return _ensure_domestic_tech_tree_presentation_controller()._format_domestic_tech_research_plan_lines_mvp(tech_def, view_state, scope)


func _format_domestic_tech_research_cost_display_mvp(cost_plan: Dictionary) -> String:
	return _ensure_domestic_tech_tree_presentation_controller()._format_domestic_tech_research_cost_display_mvp(cost_plan)


func _format_domestic_tech_research_cost_plan_mvp(tech_def: Dictionary, scope: String = "") -> String:
	return _ensure_domestic_tech_tree_presentation_controller()._format_domestic_tech_research_cost_plan_mvp(tech_def, scope)


func _build_domestic_tech_actual_charge_plan_mvp(tech_id: String, scope: String, city_id: String = "") -> Dictionary:
	return _ensure_domestic_tech_research_service().build_actual_charge_plan(tech_id, scope, city_id)


func _has_domestic_tech_national_food_group_scope_mvp() -> bool:
	return _ensure_domestic_tech_research_service().has_national_food_group_scope()


func _validate_domestic_tech_actual_charge_mvp(charge_plan: Dictionary) -> Dictionary:
	var result := _ensure_domestic_tech_research_service().validate_actual_charge(charge_plan)
	if not bool(result.get("ok", false)):
		result["message"] = _format_domestic_tech_actual_charge_shortage_mvp(result)
	return result


func _apply_domestic_tech_actual_charge_mvp(charge_plan: Dictionary) -> Dictionary:
	return _ensure_domestic_tech_research_service().apply_actual_charge(charge_plan)


func _format_domestic_tech_actual_charge_shortage_mvp(validation: Dictionary) -> String:
	return _ensure_domestic_tech_tree_presentation_controller()._format_domestic_tech_actual_charge_shortage_mvp(validation)


func _get_domestic_tech_research_actual_charge_summary_mvp() -> Dictionary:
	return _ensure_domestic_tech_research_service().get_actual_charge_summary()


func _get_domestic_tech_requirement_summary_mvp(tech_def: Dictionary, view_state: Dictionary, _city_id: String = "") -> Array[String]:
	return _ensure_domestic_tech_tree_presentation_controller()._get_domestic_tech_requirement_summary_mvp(tech_def, view_state, _city_id)


func _update_domestic_tech_research_action_slot_mvp(view_state: Dictionary) -> void:
	_ensure_domestic_tech_tree_presentation_controller()._update_domestic_tech_research_action_slot_mvp(view_state)


func _on_domestic_tech_research_action_pressed_mvp() -> void:
	var selection := _ensure_domestic_tech_tree_presentation_controller().get_selection()
	_start_domestic_tech_research_mvp(str(selection.get("tech_id", "")), str(selection.get("city_id", "")))


func _format_domestic_tech_research_action_button_text_mvp(view_state: Dictionary, validation: Dictionary) -> String:
	return _ensure_domestic_tech_tree_presentation_controller()._format_domestic_tech_research_action_button_text_mvp(view_state, validation)


func _format_domestic_tech_readiness_state_label_mvp(state_id: String) -> String:
	return _ensure_domestic_tech_tree_presentation_controller()._format_domestic_tech_readiness_state_label_mvp(state_id)


func _format_domestic_tech_research_readiness_text_mvp(view_state: Dictionary) -> String:
	return _ensure_domestic_tech_tree_presentation_controller()._format_domestic_tech_research_readiness_text_mvp(view_state)


func _format_domestic_tech_research_action_slot_text_mvp(view_state: Dictionary) -> String:
	return _ensure_domestic_tech_tree_presentation_controller()._format_domestic_tech_research_action_slot_text_mvp(view_state)


func _format_domestic_tech_research_action_hint_mvp(view_state: Dictionary) -> String:
	return _ensure_domestic_tech_tree_presentation_controller()._format_domestic_tech_research_action_hint_mvp(view_state)


func _get_domestic_tech_readiness_condition_lines_mvp(tech_def: Dictionary, view_state: Dictionary, city_id: String = "") -> Array[String]:
	return _ensure_domestic_tech_tree_presentation_controller()._get_domestic_tech_readiness_condition_lines_mvp(tech_def, view_state, city_id)


func _format_domestic_tech_condition_met_label_mvp(is_met: bool) -> String:
	return _ensure_domestic_tech_tree_presentation_controller()._format_domestic_tech_condition_met_label_mvp(is_met)


func _format_domestic_tech_completion_gate_status_mvp(tech_id: String, scope: String, city_id: String = "") -> String:
	return _ensure_domestic_tech_tree_presentation_controller()._format_domestic_tech_completion_gate_status_mvp(tech_id, scope, city_id)


func _format_domestic_tech_lock_reason_mvp(reason_text: String) -> String:
	return _ensure_domestic_tech_tree_presentation_controller()._format_domestic_tech_lock_reason_mvp(reason_text)


func _get_domestic_tech_relation_lines_mvp(tech_def: Dictionary, city_id: String = "") -> Array[String]:
	return _ensure_domestic_tech_tree_presentation_controller()._get_domestic_tech_relation_lines_mvp(tech_def, city_id)


func _get_domestic_tech_unlock_relation_status_mvp(tech_def: Dictionary, scope: String, city_id: String = "") -> Array[String]:
	return _ensure_domestic_tech_tree_presentation_controller()._get_domestic_tech_unlock_relation_status_mvp(tech_def, scope, city_id)


func _get_domestic_tech_effect_phase1_display_mvp(tech_def: Dictionary, scope: String, city_id: String = "") -> Array[String]:
	return _ensure_domestic_tech_tree_presentation_controller()._get_domestic_tech_effect_phase1_display_mvp(tech_def, scope, city_id)


func _get_domestic_tech_effect_phase1_summary_mvp() -> Dictionary:
	_normalize_domestic_tech_state_mvp()
	return _ensure_domestic_tech_effect_provider().get_effect_summary(
		_get_completed_national_domestic_tech_snapshot_mvp(),
		_normalize_city_domestic_tech_state_map_mvp(_player_state.get("city_domestic_tech_completed", {})),
		_get_player_city_ids_for_domestic_tech_research_mvp()
	)


func _get_domestic_tech_national_policy_effect_summary_mvp() -> Dictionary:
	return _ensure_domestic_tech_effect_provider().get_summary_slice("national_policy", _get_domestic_tech_effect_phase1_summary_mvp())


func _get_domestic_tech_numeric_effect_phase1_summary_mvp() -> Dictionary:
	return _ensure_domestic_tech_effect_provider().get_summary_slice("numeric", _get_domestic_tech_effect_phase1_summary_mvp())


func _get_domestic_tech_military_defense_effect_summary_mvp() -> Dictionary:
	return _ensure_domestic_tech_effect_provider().get_summary_slice("military", _get_domestic_tech_effect_phase1_summary_mvp())


func _get_domestic_tech_naval_siege_effect_summary_mvp() -> Dictionary:
	return _ensure_domestic_tech_effect_provider().get_summary_slice("naval_siege", _get_domestic_tech_effect_phase1_summary_mvp())


func _get_domestic_tech_diplomacy_spy_effect_summary_mvp() -> Dictionary:
	return _ensure_domestic_tech_effect_provider().get_summary_slice("diplomacy_spy", _get_domestic_tech_effect_phase1_summary_mvp())


func _get_domestic_tech_full_effect_integration_summary_mvp() -> Dictionary:
	return _ensure_domestic_tech_effect_provider().get_full_integration_summary(_get_domestic_tech_effect_phase1_summary_mvp())


func _get_domestic_tech_gameplay_effect_integration_map_summary_mvp() -> Dictionary:
	return _ensure_domestic_tech_effect_provider().get_gameplay_integration_map_summary()


func _get_domestic_tech_research_balance_summary_mvp() -> Dictionary:
	return {
		"balance_integration_pass": true,
		"balance_f6_qa_record_ready": true,
		"cost_balance_qa_items": true,
		"duration_balance_qa_items": true,
		"safe_set_effect_qa_items": true,
		"progression_feel_qa_items": true,
		"actual_charge_preservation_qa_items": true,
		"formula_connection_forbidden": true,
		"cost_balance_updated": true,
		"duration_balance_updated": true,
		"safe_set_effect_balance_updated": true,
		"research_balance_planning_enabled": true,
		"cost_display_only": false,
		"cost_charged": true,
		"cost_charged_on_start": true,
		"cost_charged_per_turn": false,
		"cost_charged_on_completion": false,
		"cost_blocks_research_start": true,
		"paid_cost_state_persisted": false,
		"cost_affordability_checked": true,
		"duration_fallback_enabled": true,
		"duration_fallback_applies_to_new_research": true,
		"national_duration_tier_rule": "tier_based",
		"city_duration_tier_rule": "tier_based",
		"active_research_duration_force_rewritten": false,
		"active_research_flow_changed": false,
		"completion_flow_changed": false,
		"enemy_research_enabled": false,
		"battle_formula_connected": false,
		"diplomacy_formula_connected": false,
		"spy_formula_connected": false,
		"market_formula_connected": false,
		"city_intel_formula_connected": false,
		"national_cost_gold_bands": {"tier_1": 140, "tier_2": 320, "tier_3": 560, "tier_4": 900, "tier_5": 1200},
		"city_cost_base_gold_bands": {"tier_1": 90, "tier_2": 230, "tier_3": 430, "tier_4": 760, "tier_5": 980},
		"city_cost_base_food_bands": {"tier_1": 20, "tier_2": 45, "tier_3": 90, "tier_4": 150, "tier_5": 210},
		"tier_1_duration": _get_domestic_tech_tier_duration_turns_mvp(1),
		"tier_2_duration": _get_domestic_tech_tier_duration_turns_mvp(2),
		"tier_3_duration": _get_domestic_tech_tier_duration_turns_mvp(3),
		"tier_4_duration": _get_domestic_tech_tier_duration_turns_mvp(4),
		"tier_5_duration": _get_domestic_tech_tier_duration_turns_mvp(5),
		"national_tier_1_duration": _get_domestic_tech_scope_duration_turns_mvp(DOMESTIC_TECH_SCOPE_NATIONAL, 1),
		"national_tier_2_duration": _get_domestic_tech_scope_duration_turns_mvp(DOMESTIC_TECH_SCOPE_NATIONAL, 2),
		"national_tier_3_duration": _get_domestic_tech_scope_duration_turns_mvp(DOMESTIC_TECH_SCOPE_NATIONAL, 3),
		"national_tier_4_duration": _get_domestic_tech_scope_duration_turns_mvp(DOMESTIC_TECH_SCOPE_NATIONAL, 4),
		"city_tier_1_duration": _get_domestic_tech_scope_duration_turns_mvp(DOMESTIC_TECH_SCOPE_CITY, 1),
		"city_tier_2_duration": _get_domestic_tech_scope_duration_turns_mvp(DOMESTIC_TECH_SCOPE_CITY, 2),
		"city_tier_3_duration": _get_domestic_tech_scope_duration_turns_mvp(DOMESTIC_TECH_SCOPE_CITY, 3),
		"city_tier_4_duration": _get_domestic_tech_scope_duration_turns_mvp(DOMESTIC_TECH_SCOPE_CITY, 4),
		"national_tier_counts": _get_domestic_tech_tier_count_summary_mvp(DOMESTIC_TECH_SCOPE_NATIONAL),
		"city_tier_counts": _get_domestic_tech_tier_count_summary_mvp(DOMESTIC_TECH_SCOPE_CITY),
	}


func _get_domestic_tech_research_cost_display_summary_mvp() -> Dictionary:
	return {
		"research_cost_display_enabled": true,
		"national_cost_display_enabled": true,
		"city_cost_display_enabled": true,
		"cost_display_only": false,
		"cost_formatter_enabled": true,
		"state_specific_cost_display": true,
		"zero_cost_hidden": true,
		"cost_charged": true,
		"cost_charged_on_start": true,
		"cost_charged_per_turn": false,
		"cost_charged_on_completion": false,
		"cost_blocks_research_start": true,
		"paid_cost_state_persisted": false,
		"cost_affordability_checked": true,
		"enemy_research_cost_enabled": false,
		"active_research_flow_changed": false,
		"completion_flow_changed": false,
	}


func _get_domestic_tech_manual_qa_scenario_pack_mvp() -> Dictionary:
	return {
		"manual_qa_scenario_pack_enabled": true,
		"version": "v0.70-76",
		"national_research_flow": true,
		"city_research_flow": true,
		"completion_refresh": true,
		"same_city_only": true,
		"enemy_no_display": true,
		"expected_cost_display_only": true,
		"no_cost_charge": true,
		"no_cost_gating": true,
		"safe_sets_to_check": [
			"economy",
			"military_defense",
			"national_policy",
			"naval_siege",
			"diplomacy_spy",
		],
		"ui_checks": [
			"ui64_icon_visibility",
			"node_click_latency",
			"overlay_close_reopen",
			"esc_close",
			"panel_restore",
		],
		"forbidden_mutations": {
			"battle": 0,
			"diplomacy_success": 0,
			"spy_success": 0,
			"market": 0,
			"city_intel": 0,
			"enemy_effect": 0,
			"troop_count": 0,
			"ship_count": 0,
			"siege_weapon_count": 0,
		},
	}


func _get_domestic_tech_actual_manual_qa_pass_mvp() -> Dictionary:
	return {
		"actual_manual_qa_pass_enabled": true,
		"version": "v0.70-78",
		"grace_turns_required": true,
		"national_research_flow_required": true,
		"city_research_flow_required": true,
		"safe_set_effects_required": true,
		"cost_display_only_required": true,
		"enemy_no_display_required": true,
		"ui_overlay_required": true,
		"gameplay_mutation": false,
		"print_spam": false,
		"save_data_changed": false,
	}


func _get_domestic_tech_research_actual_charge_design_mvp() -> Dictionary:
	return {
		"version": "v0.70-81",
		"design_draft_only": false,
		"actual_charge_implemented": true,
		"recommended_charge_timing": "on_research_start_once",
		"start_time_charge": true,
		"per_turn_charge": false,
		"charge_on_completion": false,
		"completion_charge": false,
		"retroactive_charge_existing_active": false,
		"cancel_refund_in_scope": false,
		"cancel_refund_implemented": false,
		"paid_cost_state_required": false,
		"paid_cost_state": false,
		"active_payload_schema_changed": false,
		"affordability_check_planned": false,
		"affordability_check_implemented": true,
		"insufficient_cost_blocks_start_planned": false,
		"insufficient_cost_blocks_start_implemented": true,
		"implemented_resource_keys": ["gold", "food_group"],
		"skipped_resource_keys": ["labor", "policy"],
		"food_group_keys": ["rice", "barley", "seafood"],
		"food_group_deduction_order": ["rice", "barley", "seafood"],
		"food_group_policy": "city_required_when_city_cost_has_food; national_required_only_when national scope has stable rice/barley/seafood keys",
		"national_cost_scope": "player_national_resources",
		"city_cost_scope": "selected_player_city_storage",
		"enemy_cost_scope": "none",
		"battle_context_changed": false,
		"pending_invasion_schema_changed": false,
		"gameplay_mutation": true,
		"print_spam": false,
		"save_data_changed": false,
	}


func _is_manual_qa_invasion_grace_turn_active_mvp() -> bool:
	var current_turn := _get_current_world_turn_number_mvp()
	return current_turn <= MANUAL_QA_NO_INVASION_GRACE_TURNS


func _get_manual_qa_grace_summary_mvp() -> Dictionary:
	return {
		"manual_qa_invasion_grace_enabled": true,
		"manual_qa_invasion_grace_turns": MANUAL_QA_NO_INVASION_GRACE_TURNS,
		"turn_counter_basis": "one_based",
		"grace_turn_start": 1,
		"grace_turn_end": MANUAL_QA_NO_INVASION_GRACE_TURNS,
		"logic_returns_from_turn": MANUAL_QA_NO_INVASION_GRACE_TURNS + 1,
		"current_turn": _get_current_world_turn_number_mvp(),
		"invasion_grace_active": _is_manual_qa_invasion_grace_turn_active_mvp(),
		"invasion_creation_blocked_during_grace": true,
		"pending_invasion_creation_blocked_during_grace": true,
		"enemy_pressure_blocked_during_grace": true,
		"enemy_pressure_plan_blocked_during_grace": true,
		"strategic_pressure_followup_blocked_during_grace": true,
		"existing_pending_invasions_deleted": false,
		"turn_progress_blocked": false,
		"domestic_research_progress_blocked": false,
		"income_blocked": false,
		"ui_refresh_blocked": false,
		"battle_context_changed": false,
		"pending_invasion_schema_changed": false,
		"enemy_ai_disabled_globally": false,
	}


func _get_domestic_tech_tier_count_summary_mvp(scope: String) -> Dictionary:
	var definitions := _get_domestic_national_tech_definitions_mvp() if scope == DOMESTIC_TECH_SCOPE_NATIONAL else _get_domestic_city_tech_definitions_mvp()
	var counts := {}
	for tech_def_variant in definitions.values():
		if not tech_def_variant is Dictionary:
			continue
		var tier := clampi(int((tech_def_variant as Dictionary).get("tier", 1)), 1, 5)
		var key := "tier_%d" % tier
		counts[key] = int(counts.get(key, 0)) + 1
	return counts


func _format_domestic_tech_city_requirement_lines_mvp(tech_def: Dictionary, city_id: String = "") -> Array[String]:
	return _ensure_domestic_tech_tree_presentation_controller()._format_domestic_tech_city_requirement_lines_mvp(tech_def, city_id)


func _format_domestic_tech_duration_hint_mvp(tech_def: Dictionary) -> String:
	return _ensure_domestic_tech_tree_presentation_controller()._format_domestic_tech_duration_hint_mvp(tech_def)


func _build_domestic_tech_category_group_mvp(parent: Container, category_id: String, city_id: String, scope: String) -> void:
	_ensure_domestic_tech_tree_presentation_controller()._build_domestic_tech_category_group_mvp(parent, category_id, city_id, scope)


func _build_domestic_tech_graph_canvas_mvp(parent: Container, tech_defs: Array[Dictionary], city_id: String, scope: String) -> void:
	_ensure_domestic_tech_tree_presentation_controller()._build_domestic_tech_graph_canvas_mvp(parent, tech_defs, city_id, scope)


func _get_domestic_tech_graph_positions_mvp(tech_defs: Array[Dictionary]) -> Dictionary:
	return _ensure_domestic_tech_tree_presentation_controller()._get_domestic_tech_graph_positions_mvp(tech_defs)


func _get_domestic_tech_graph_canvas_size_mvp(positions: Dictionary) -> Vector2:
	return _ensure_domestic_tech_tree_presentation_controller()._get_domestic_tech_graph_canvas_size_mvp(positions)


func _add_domestic_tech_graph_branch_labels_mvp(parent: Control, positions: Dictionary, tech_defs: Array[Dictionary]) -> void:
	_ensure_domestic_tech_tree_presentation_controller()._add_domestic_tech_graph_branch_labels_mvp(parent, positions, tech_defs)


func _add_domestic_tech_graph_lines_mvp(line_parent: Control, positions: Dictionary, tech_defs: Array[Dictionary], city_id: String, _scope: String) -> void:
	_ensure_domestic_tech_tree_presentation_controller()._add_domestic_tech_graph_lines_mvp(line_parent, positions, tech_defs, city_id, _scope)


func _add_domestic_tech_graph_line_mvp(line_parent: Control, from_rect: Rect2, to_rect: Rect2, state_id: String) -> void:
	_ensure_domestic_tech_tree_presentation_controller()._add_domestic_tech_graph_line_mvp(line_parent, from_rect, to_rect, state_id)


func _add_domestic_tech_graph_hline_mvp(parent: Control, x1: float, x2: float, y: float, color: Color) -> void:
	_ensure_domestic_tech_tree_presentation_controller()._add_domestic_tech_graph_hline_mvp(parent, x1, x2, y, color)


func _add_domestic_tech_graph_vline_mvp(parent: Control, x: float, y1: float, y2: float, color: Color) -> void:
	_ensure_domestic_tech_tree_presentation_controller()._add_domestic_tech_graph_vline_mvp(parent, x, y1, y2, color)


func _build_domestic_tech_graph_node_mvp(parent: Control, tech_def: Dictionary, positions: Dictionary, city_id: String) -> Control:
	return _ensure_domestic_tech_tree_presentation_controller()._build_domestic_tech_graph_node_mvp(parent, tech_def, positions, city_id)


func _get_domestic_tech_graph_line_color_mvp(state_id: String) -> Color:
	return _ensure_domestic_tech_tree_presentation_controller()._get_domestic_tech_graph_line_color_mvp(state_id)


func _build_domestic_tech_compact_node_mvp(parent: Control, tech_def: Dictionary, graph_position: Vector2, city_id: String) -> PanelContainer:
	return _ensure_domestic_tech_tree_presentation_controller()._build_domestic_tech_compact_node_mvp(parent, tech_def, graph_position, city_id)


func _on_domestic_tech_compact_node_gui_input_mvp(event: InputEvent, tech_id: String, city_id: String) -> void:
	_ensure_domestic_tech_tree_presentation_controller()._on_domestic_tech_compact_node_gui_input_mvp(event, tech_id, city_id)


func _set_selected_domestic_tech_for_inspector_mvp(tech_id: String, city_id: String = "") -> void:
	_ensure_domestic_tech_tree_presentation_controller()._set_selected_domestic_tech_for_inspector_mvp(tech_id, city_id)


func _is_selected_domestic_tech_for_inspector_mvp(tech_id: String, city_id: String = "") -> bool:
	return _ensure_domestic_tech_tree_presentation_controller()._is_selected_domestic_tech_for_inspector_mvp(tech_id, city_id)


func _get_domestic_tech_selection_key_mvp(tech_id: String, city_id: String = "") -> String:
	return _ensure_domestic_tech_tree_presentation_controller()._get_domestic_tech_selection_key_mvp(tech_id, city_id)


func _get_current_domestic_tech_selection_key_mvp() -> String:
	return _ensure_domestic_tech_tree_presentation_controller()._get_current_domestic_tech_selection_key_mvp()


func _update_domestic_tech_selected_node_styles_mvp(previous_selection_key: String, current_selection_key: String) -> void:
	_ensure_domestic_tech_tree_presentation_controller()._update_domestic_tech_selected_node_styles_mvp(previous_selection_key, current_selection_key)


func _apply_domestic_tech_compact_node_selection_style_mvp(selection_key: String, is_selected: bool) -> void:
	_ensure_domestic_tech_tree_presentation_controller()._apply_domestic_tech_compact_node_selection_style_mvp(selection_key, is_selected)


func _format_domestic_tech_compact_status_mvp(view_state: Dictionary) -> String:
	return _ensure_domestic_tech_tree_presentation_controller()._format_domestic_tech_compact_status_mvp(view_state)


func _build_domestic_tech_node_mvp(parent: Control, tech_def: Dictionary, city_id: String) -> PanelContainer:
	return _ensure_domestic_tech_tree_presentation_controller()._build_domestic_tech_node_mvp(parent, tech_def, city_id)


func _get_domestic_tech_view_state_mvp(tech_id: String, city_id: String = "") -> Dictionary:
	_normalize_domestic_tech_state_mvp()
	var definition := _get_domestic_tech_definition_mvp(tech_id)
	if definition.is_empty():
		return {"state": DOMESTIC_TECH_VIEW_LOCKED, "label": "잠김", "lock_reasons": ["정의 없음"], "is_locked": true, "is_special_locked": false}

	var scope := str(definition.get("tree_scope", ""))
	var is_completed := _is_national_domestic_tech_completed_mvp(tech_id) if scope == DOMESTIC_TECH_SCOPE_NATIONAL else _is_city_domestic_tech_completed_mvp(city_id, tech_id)
	var active_research := _get_national_domestic_tech_active_research_mvp() if scope == DOMESTIC_TECH_SCOPE_NATIONAL else _get_city_domestic_tech_active_research_mvp(city_id)
	var is_researching := str(active_research.get("tech_id", "")) == tech_id
	var special_reasons := _format_domestic_tech_special_requirements_mvp(definition)
	var eligibility := _ensure_domestic_tech_research_rules().evaluate_eligibility(
		definition,
		city_id,
		_get_completed_city_domestic_tech_snapshot_mvp(city_id),
		_get_completed_national_domestic_tech_snapshot_mvp(),
		is_completed,
		is_researching,
		not city_id.is_empty() and not _get_city_hud_entry(city_id).is_empty(),
		special_reasons.is_empty(),
		Callable(self, "_query_domestic_tech_world_fact_mvp")
	)
	var state_id := str(eligibility.get("state", DOMESTIC_TECH_VIEW_LOCKED))
	if state_id == DOMESTIC_TECH_VIEW_COMPLETED:
		return {"state": DOMESTIC_TECH_VIEW_COMPLETED, "label": "완료", "lock_reasons": [], "is_locked": false, "is_special_locked": false}
	if state_id == DOMESTIC_TECH_VIEW_RESEARCHING:
		return {"state": DOMESTIC_TECH_VIEW_RESEARCHING, "label": "진행 중", "lock_reasons": [], "is_locked": true, "is_special_locked": false, "active_research": active_research}
	if state_id == DOMESTIC_TECH_VIEW_SPECIAL_LOCKED:
		return {"state": DOMESTIC_TECH_VIEW_SPECIAL_LOCKED, "label": "특수 잠금", "lock_reasons": special_reasons, "is_locked": true, "is_special_locked": true}
	if state_id == DOMESTIC_TECH_VIEW_LOCKED:
		var lock_reasons: Array[String] = []
		var reason_codes: Array = eligibility.get("reason_codes", []) if eligibility.get("reason_codes", []) is Array else []
		if reason_codes.has("missing_city_context"):
			lock_reasons.append("도시 선택 필요")
		for required_id_variant in eligibility.get("missing_tech_ids", []):
			lock_reasons.append("선행: %s" % _get_domestic_tech_display_name_mvp(str(required_id_variant)))
		for required_id_variant in eligibility.get("missing_national_tech_ids", []):
			lock_reasons.append("국가: %s" % _get_domestic_tech_display_name_mvp(str(required_id_variant)))
		if reason_codes.has("missing_city_requirement"):
			lock_reasons.append("도시 조건")
		return {"state": DOMESTIC_TECH_VIEW_LOCKED, "label": "잠김", "lock_reasons": lock_reasons, "is_locked": true, "is_special_locked": false}
	return {"state": DOMESTIC_TECH_VIEW_AVAILABLE, "label": "가능", "lock_reasons": [], "is_locked": false, "is_special_locked": false}


func _get_sorted_domestic_tech_definitions_for_category_mvp(category_id: String, scope: String) -> Array[Dictionary]:
	return _ensure_domestic_tech_tree_presentation_controller()._get_sorted_domestic_tech_definitions_for_category_mvp(category_id, scope)


func _sort_domestic_tech_definition_mvp(left_definition: Dictionary, right_definition: Dictionary) -> bool:
	return _ensure_domestic_tech_tree_presentation_controller()._sort_domestic_tech_definition_mvp(left_definition, right_definition)


func _add_domestic_tech_icon_mvp(parent: Container, tech_id: String, icon_size: float = DomesticTechTreePresentationControllerScript.DOMESTIC_TECH_TREE_ICON_SIZE, fallback_font_size: int = 18) -> void:
	_ensure_domestic_tech_tree_presentation_controller()._add_domestic_tech_icon_mvp(parent, tech_id, icon_size, fallback_font_size)


func _format_domestic_tech_rarity_mvp(rarity: int) -> String:
	return _ensure_domestic_tech_tree_presentation_controller()._format_domestic_tech_rarity_mvp(rarity)


func _format_domestic_tech_cost_mvp(raw_cost: Variant) -> String:
	return _ensure_domestic_tech_tree_presentation_controller()._format_domestic_tech_cost_mvp(raw_cost)


func _format_domestic_tech_resource_label_mvp(resource_id: String) -> String:
	return _ensure_domestic_tech_tree_presentation_controller()._format_domestic_tech_resource_label_mvp(resource_id)


func _format_domestic_tech_branch_label_mvp(branch_id: String) -> String:
	return _ensure_domestic_tech_tree_presentation_controller()._format_domestic_tech_branch_label_mvp(branch_id)


func _format_domestic_tech_special_requirements_mvp(definition: Dictionary) -> Array[String]:
	return _ensure_domestic_tech_tree_presentation_controller()._format_domestic_tech_special_requirements_mvp(definition)


func _format_domestic_tech_requirement_value_mvp(value: Variant) -> String:
	return _ensure_domestic_tech_tree_presentation_controller()._format_domestic_tech_requirement_value_mvp(value)


func _format_domestic_tech_governor_aptitudes_mvp(definition: Dictionary) -> Array[String]:
	return _ensure_domestic_tech_tree_presentation_controller()._format_domestic_tech_governor_aptitudes_mvp(definition)


func _format_domestic_tech_requirement_atom_mvp(value_text: String) -> String:
	return _ensure_domestic_tech_tree_presentation_controller()._format_domestic_tech_requirement_atom_mvp(value_text)


func _format_domestic_tech_requirement_key_label_mvp(requirement_key: String) -> String:
	return _ensure_domestic_tech_tree_presentation_controller()._format_domestic_tech_requirement_key_label_mvp(requirement_key)


func _format_domestic_tech_aptitude_label_mvp(aptitude_id: String) -> String:
	return _ensure_domestic_tech_tree_presentation_controller()._format_domestic_tech_aptitude_label_mvp(aptitude_id)


func _get_domestic_tech_display_name_mvp(tech_id: String) -> String:
	return _ensure_domestic_tech_tree_presentation_controller()._get_domestic_tech_display_name_mvp(tech_id)


func _ensure_domestic_tech_completion_presentation_overlay() -> void:
	_ensure_domestic_tech_completion_presentation_controller()._ensure_domestic_tech_completion_presentation_overlay()


func _make_domestic_tech_completion_card_style_mvp() -> StyleBoxFlat:
	return _ensure_domestic_tech_completion_presentation_controller()._make_domestic_tech_completion_card_style_mvp()


func _layout_domestic_tech_completion_presentation_overlay() -> void:
	_ensure_domestic_tech_completion_presentation_controller()._layout_domestic_tech_completion_presentation_overlay()


func _get_domestic_tech_completion_video_panel_rect_mvp(viewport_size: Vector2) -> Rect2:
	return _ensure_domestic_tech_completion_presentation_controller()._get_domestic_tech_completion_video_panel_rect_mvp(viewport_size)


func _enqueue_domestic_tech_completion_presentations_mvp(completed_events: Variant) -> void:
	_ensure_domestic_tech_completion_presentation_controller()._enqueue_domestic_tech_completion_presentations_mvp(completed_events)


func _make_domestic_tech_completion_presentation_item_mvp(event: Dictionary) -> Dictionary:
	return _ensure_domestic_tech_completion_presentation_controller()._make_domestic_tech_completion_presentation_item_mvp(event)


func _get_domestic_tech_completion_effect_summary_mvp(tech_id: String, scope: String, city_id: String = "") -> String:
	return _ensure_domestic_tech_completion_presentation_controller()._get_domestic_tech_completion_effect_summary_mvp(tech_id, scope, city_id)


func _get_domestic_tech_completion_direct_effect_lines_mvp(tech_id: String, definition: Dictionary, scope: String, city_name: String) -> Array[String]:
	return _ensure_domestic_tech_completion_presentation_controller()._get_domestic_tech_completion_direct_effect_lines_mvp(tech_id, definition, scope, city_name)


func _append_domestic_tech_completion_value_line_mvp(lines: Array[String], label: String, percent_value: float, flat_value: int) -> void:
	_ensure_domestic_tech_completion_presentation_controller()._append_domestic_tech_completion_value_line_mvp(lines, label, percent_value, flat_value)


func _append_domestic_tech_completion_city_unlock_lines_mvp(lines: Array[String], tech_id: String) -> void:
	_ensure_domestic_tech_completion_presentation_controller()._append_domestic_tech_completion_city_unlock_lines_mvp(lines, tech_id)


func _append_domestic_tech_completion_national_unlock_lines_mvp(lines: Array[String], tech_id: String, category_id: String, branch_id: String) -> void:
	_ensure_domestic_tech_completion_presentation_controller()._append_domestic_tech_completion_national_unlock_lines_mvp(lines, tech_id, category_id, branch_id)


func _get_domestic_tech_completion_category_fallback_lines_mvp(definition: Dictionary, scope: String, city_name: String) -> Array[String]:
	return _ensure_domestic_tech_completion_presentation_controller()._get_domestic_tech_completion_category_fallback_lines_mvp(definition, scope, city_name)


func _get_unique_domestic_tech_completion_lines_mvp(lines: Array[String]) -> Array[String]:
	return _ensure_domestic_tech_completion_presentation_controller()._get_unique_domestic_tech_completion_lines_mvp(lines)


func _get_domestic_tech_completion_video_path_mvp(scope: String) -> String:
	return _ensure_domestic_tech_completion_presentation_controller()._get_domestic_tech_completion_video_path_mvp(scope)


func _play_next_domestic_tech_completion_presentation() -> void:
	_ensure_domestic_tech_completion_presentation_controller()._play_next_domestic_tech_completion_presentation()


func _play_domestic_tech_completion_video_mvp(item: Dictionary) -> bool:
	return _ensure_domestic_tech_completion_presentation_controller()._play_domestic_tech_completion_video_mvp(item)


func _assign_domestic_tech_completion_video_stream_mvp(path: String) -> bool:
	return _ensure_domestic_tech_completion_presentation_controller()._assign_domestic_tech_completion_video_stream_mvp(path)


func _create_domestic_tech_completion_theora_stream_direct_mvp(path: String) -> VideoStream:
	return _ensure_domestic_tech_completion_presentation_controller()._create_domestic_tech_completion_theora_stream_direct_mvp(path)


func _on_domestic_tech_completion_video_finished() -> void:
	_ensure_domestic_tech_completion_presentation_controller()._on_domestic_tech_completion_video_finished()


func _on_domestic_tech_completion_video_fallback_timeout(tech_id: String) -> void:
	_ensure_domestic_tech_completion_presentation_controller()._on_domestic_tech_completion_video_fallback_timeout(tech_id)


func _complete_domestic_tech_completion_video_mvp(source: String) -> void:
	_ensure_domestic_tech_completion_presentation_controller()._complete_domestic_tech_completion_video_mvp(source)


func _show_domestic_tech_completion_card_mvp(item: Dictionary) -> void:
	_ensure_domestic_tech_completion_presentation_controller()._show_domestic_tech_completion_card_mvp(item)


func _on_domestic_tech_completion_confirm_pressed() -> void:
	_ensure_domestic_tech_completion_presentation_controller()._on_domestic_tech_completion_confirm_pressed()


func _finish_domestic_tech_completion_presentation_item_mvp() -> void:
	_ensure_domestic_tech_completion_presentation_controller()._finish_domestic_tech_completion_presentation_item_mvp()


func _hide_domestic_tech_completion_presentation_overlay() -> void:
	_ensure_domestic_tech_completion_presentation_controller()._hide_domestic_tech_completion_presentation_overlay()


func _is_domestic_tech_completion_card_visible() -> bool:
	return _ensure_domestic_tech_completion_presentation_controller()._is_domestic_tech_completion_card_visible()


func _is_domestic_tech_completion_space_confirm_event(event: InputEvent) -> bool:
	return _ensure_domestic_tech_completion_presentation_controller()._is_domestic_tech_completion_space_confirm_event(event)


func _domestic_tech_completion_object_has_property_mvp(value: Object, property_name: String) -> bool:
	return _ensure_domestic_tech_completion_presentation_controller()._domestic_tech_completion_object_has_property_mvp(value, property_name)


func _get_domestic_tech_completion_debug_object_class_name_mvp(value: Object) -> String:
	return _ensure_domestic_tech_completion_presentation_controller()._get_domestic_tech_completion_debug_object_class_name_mvp(value)


func _make_domestic_tech_label_mvp(text: String, font_size: int, font_color: Color) -> Label:
	return _ensure_domestic_tech_tree_presentation_controller()._make_domestic_tech_label_mvp(text, font_size, font_color)


func _make_domestic_tech_section_panel_mvp(panel_name: String) -> PanelContainer:
	return _ensure_domestic_tech_tree_presentation_controller()._make_domestic_tech_section_panel_mvp(panel_name)


func _make_domestic_tech_section_content_mvp(panel: PanelContainer) -> VBoxContainer:
	return _ensure_domestic_tech_tree_presentation_controller()._make_domestic_tech_section_content_mvp(panel)


func _make_domestic_tech_scroll_mvp() -> ScrollContainer:
	return _ensure_domestic_tech_tree_presentation_controller()._make_domestic_tech_scroll_mvp()


func _clear_domestic_tech_tree_children_mvp(node: Node) -> void:
	_ensure_domestic_tech_tree_presentation_controller()._clear_domestic_tech_tree_children_mvp(node)


func _make_domestic_tech_overlay_style_mvp() -> StyleBoxFlat:
	return _ensure_domestic_tech_tree_presentation_controller()._make_domestic_tech_overlay_style_mvp()


func _make_domestic_tech_section_style_mvp() -> StyleBoxFlat:
	return _ensure_domestic_tech_tree_presentation_controller()._make_domestic_tech_section_style_mvp()


func _make_domestic_tech_icon_box_style_mvp() -> StyleBoxFlat:
	return _ensure_domestic_tech_tree_presentation_controller()._make_domestic_tech_icon_box_style_mvp()


func _make_domestic_tech_node_style_mvp(state_id: String) -> StyleBoxFlat:
	return _ensure_domestic_tech_tree_presentation_controller()._make_domestic_tech_node_style_mvp(state_id)


func _make_domestic_tech_compact_node_style_mvp(state_id: String, is_selected: bool) -> StyleBoxFlat:
	return _ensure_domestic_tech_tree_presentation_controller()._make_domestic_tech_compact_node_style_mvp(state_id, is_selected)


func _get_domestic_tech_state_text_color_mvp(state_id: String) -> Color:
	return _ensure_domestic_tech_tree_presentation_controller()._get_domestic_tech_state_text_color_mvp(state_id)


func _get_domestic_tech_state_body_color_mvp(state_id: String) -> Color:
	return _ensure_domestic_tech_tree_presentation_controller()._get_domestic_tech_state_body_color_mvp(state_id)


func _normalize_domestic_tech_state_mvp() -> void:
	_ensure_domestic_tech_research_service().normalize_state()


func _normalize_city_domestic_tech_state_map_mvp(raw_state: Variant) -> Dictionary:
	return _ensure_domestic_tech_research_service().normalize_city_state_map(raw_state, str(_player_state.get("selected_city_id", "")))


func _normalize_national_domestic_tech_state_map_mvp(raw_state: Variant) -> Dictionary:
	return _ensure_domestic_tech_research_service().normalize_national_state_map(raw_state)


func _normalize_national_domestic_tech_research_state_mvp() -> void:
	_ensure_domestic_tech_research_service().normalize_state()


func _normalize_city_domestic_tech_research_state_mvp() -> void:
	_ensure_domestic_tech_research_service().normalize_state()


func _normalize_domestic_tech_research_container_mvp(raw_state: Variant, scope: String, city_id: String = "") -> Dictionary:
	return _ensure_domestic_tech_research_service().normalize_research_container(raw_state, scope, city_id)


func _normalize_domestic_tech_research_turn_value_mvp(raw_value: Variant, fallback_value: int, minimum_value: int) -> int:
	return _ensure_domestic_tech_research_service().normalize_research_turn_value(raw_value, fallback_value, minimum_value)


func _normalize_domestic_tech_research_duration_value_mvp(raw_value: Variant, fallback_value: int, raw_remaining_value: Variant = 0) -> int:
	return _ensure_domestic_tech_research_service().normalize_research_duration_value(raw_value, fallback_value, raw_remaining_value)


func _parse_positive_domestic_tech_research_turn_value_mvp(raw_value: Variant) -> int:
	return _ensure_domestic_tech_research_service().parse_positive_research_turn_value(raw_value)


func _mark_domestic_tech_completed_from_normalize_mvp(scope: String, city_id: String, tech_id: String) -> void:
	_ensure_domestic_tech_research_service().mark_completed_from_normalize(scope, city_id, tech_id)


func _sync_city_domestic_tech_completed_mirror_mvp(city_id: String) -> void:
	_ensure_domestic_tech_research_service().sync_city_completed_mirror(city_id)


func _get_current_world_turn_number_mvp() -> int:
	return maxi(1, int(_player_state.get("turn_number", 1)))


func _get_domestic_tech_research_duration_turns_mvp(tech_def: Dictionary) -> int:
	return _ensure_domestic_tech_research_rules().get_research_duration_turns(tech_def)


func _get_national_domestic_tech_active_research_mvp() -> Dictionary:
	return _ensure_domestic_tech_research_service().get_national_active_research()


func _get_city_domestic_tech_active_research_mvp(city_id: String) -> Dictionary:
	return _ensure_domestic_tech_research_service().get_city_active_research(city_id)


func _is_domestic_tech_researching_mvp(tech_id: String, city_id: String = "") -> bool:
	return _ensure_domestic_tech_research_service().is_researching(tech_id, city_id)


func _format_domestic_tech_active_research_summary_mvp(active_research: Dictionary) -> String:
	if active_research.is_empty():
		return "진행 중인 연구 없음"
	var active_tech_id := str(active_research.get("tech_id", ""))
	return "%s (남은 %d턴)" % [
		_get_domestic_tech_display_name_mvp(active_tech_id),
		maxi(1, int(active_research.get("remaining_turns", active_research.get("duration_turns", 1)))),
	]


func _can_start_domestic_tech_research_mvp(tech_id: String, city_id: String = "") -> Dictionary:
	return _adapt_domestic_tech_start_result_mvp(
		_ensure_domestic_tech_research_service().validate_start(tech_id, city_id),
		tech_id,
		city_id
	)


func _adapt_domestic_tech_start_result_mvp(raw_result: Dictionary, tech_id: String, city_id: String) -> Dictionary:
	var result := raw_result.duplicate(true)
	var reason := str(result.get("reason", ""))
	var view_state := _get_domestic_tech_view_state_mvp(tech_id, city_id) if not tech_id.is_empty() else {}
	if not view_state.is_empty():
		result["view_state"] = view_state
	match reason:
		"no_selection":
			result["message"] = "선택한 테크가 없습니다."
		"missing_definition":
			result["message"] = "테크 정의를 찾을 수 없습니다."
		"city_scope":
			result["message"] = "플레이어 도시에서만 도시 테크 연구를 시작할 수 있습니다."
		"already_researching":
			result["message"] = "이미 진행 중인 연구입니다."
		"national_active":
			result["message"] = "국가 연구가 이미 진행 중입니다."
		"city_active":
			result["message"] = "이 도시에서 이미 연구가 진행 중입니다."
		"invalid_scope":
			result["message"] = "테크 범위를 확인할 수 없습니다."
		"insufficient_cost", "insufficient_resources":
			var validation: Dictionary = result.get("charge_validation", {}) if result.get("charge_validation", {}) is Dictionary else {}
			if validation.is_empty() and result.get("charge_result", {}) is Dictionary:
				validation = (result.get("charge_result", {}) as Dictionary).get("validation", {})
			result["message"] = _format_domestic_tech_actual_charge_shortage_mvp(validation)
		"ready":
			result["message"] = "연구를 시작할 수 있습니다."
		"completed", "locked", "special_locked":
			result["message"] = _format_domestic_tech_research_action_hint_mvp(view_state)
		_:
			if not bool(result.get("ok", false)):
				result["message"] = str(result.get("message", "연구 시작 조건을 확인하십시오."))
	return result


func _start_domestic_tech_research_mvp(tech_id: String, city_id: String = "") -> bool:
	var result := _adapt_domestic_tech_start_result_mvp(
		_ensure_domestic_tech_research_service().start_research(tech_id, city_id),
		tech_id,
		city_id
	)
	if not bool(result.get("ok", false)):
		_set_save_management_status(str(result.get("message", "연구 시작 조건을 확인하십시오.")))
		_refresh_domestic_tech_detail_inspector_mvp()
		return false
	var active: Dictionary = result.get("active_research", {}) if result.get("active_research", {}) is Dictionary else {}
	_set_save_management_status("연구 시작: %s · 남은 %d턴" % [_get_domestic_tech_display_name_mvp(tech_id), int(active.get("remaining_turns", 1))])
	_refresh_domestic_tech_tree_overlay_mvp()
	return true


func _advance_domestic_tech_research_for_world_turn_mvp() -> Dictionary:
	var result := _decorate_domestic_tech_progress_result_mvp(_ensure_domestic_tech_research_service().advance_world_turn())
	_player_state["last_domestic_tech_progress_result"] = result.duplicate(true)
	_enqueue_domestic_tech_completion_presentations_mvp(result.get("completed", []))
	if not (result.get("completed", []) as Array).is_empty() and _is_domestic_tech_tree_overlay_open_mvp():
		_refresh_domestic_tech_tree_overlay_mvp()
	_refresh_domestic_tech_effect_display_surfaces_mvp(result)
	return result


func _decorate_domestic_tech_progress_result_mvp(raw_result: Dictionary) -> Dictionary:
	var result := raw_result.duplicate(true)
	for bucket_key in ["national", "city", "advanced", "completed"]:
		var events: Variant = result.get(bucket_key, [])
		if not events is Array:
			continue
		var decorated: Array = []
		for event_variant in events:
			var event: Dictionary = (event_variant as Dictionary).duplicate(true) if event_variant is Dictionary else {}
			if bool(event.get("completed", false)):
				var tech_id := str(event.get("tech_id", ""))
				if str(event.get("type", "")) == DOMESTIC_TECH_SCOPE_CITY:
					var city_id := str(event.get("city_id", ""))
					event["message"] = "%s 연구 완료: %s" % [_format_city_name_by_id(city_id, city_id), _get_domestic_tech_display_name_mvp(tech_id)]
				else:
					event["message"] = "연구 완료: %s" % _get_domestic_tech_display_name_mvp(tech_id)
			decorated.append(event)
		result[bucket_key] = decorated
	return result


func _refresh_domestic_tech_effect_display_surfaces_mvp(progress_result: Dictionary) -> void:
	var completed_events: Variant = progress_result.get("completed", [])
	if not completed_events is Array or (completed_events as Array).is_empty():
		if _is_domestic_tech_tree_overlay_open_mvp():
			_refresh_domestic_tech_detail_inspector_mvp()
		return
	_refresh_left_world_status_panel()
	if selected_city_marker != null and _is_city_owned_by_player_mvp(selected_city_marker.city_id):
		_refresh_unified_panel_content()
	if _is_domestic_tech_tree_overlay_open_mvp():
		_refresh_domestic_tech_detail_inspector_mvp()


func _advance_national_tech_research_for_world_turn_mvp() -> Array[Dictionary]:
	return _decorate_domestic_tech_event_list_mvp(_ensure_domestic_tech_research_service().advance_national_research())


func _advance_city_tech_research_for_world_turn_mvp() -> Array[Dictionary]:
	return _decorate_domestic_tech_event_list_mvp(_ensure_domestic_tech_research_service().advance_city_research())


func _complete_national_tech_research_mvp(active: Dictionary) -> Dictionary:
	return _decorate_domestic_tech_event_list_mvp([_ensure_domestic_tech_research_service().complete_national_research(active)])[0]


func _complete_city_tech_research_mvp(city_id: String, active: Dictionary) -> Dictionary:
	return _decorate_domestic_tech_event_list_mvp([_ensure_domestic_tech_research_service().complete_city_research(city_id, active)])[0]


func _decorate_domestic_tech_event_list_mvp(raw_events: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for event_variant in raw_events:
		var event: Dictionary = (event_variant as Dictionary).duplicate(true) if event_variant is Dictionary else {}
		if bool(event.get("completed", false)):
			var tech_id := str(event.get("tech_id", ""))
			if str(event.get("type", "")) == DOMESTIC_TECH_SCOPE_CITY:
				var city_id := str(event.get("city_id", ""))
				event["message"] = "%s 연구 완료: %s" % [_format_city_name_by_id(city_id, city_id), _get_domestic_tech_display_name_mvp(tech_id)]
			else:
				event["message"] = "연구 완료: %s" % _get_domestic_tech_display_name_mvp(tech_id)
		result.append(event)
	return result


func _get_player_city_ids_for_domestic_tech_research_mvp() -> Array[String]:
	return _ensure_domestic_tech_research_service().get_player_city_ids()


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
	if hero_data.is_empty() or str(hero_data.get("side", "")) != _get_current_player_faction_id():
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
	var payment_check := _plan_national_city_stock_payment_mvp(cost)
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
	var paid_cost := _commit_national_city_stock_payment_mvp(cost)
	if not bool(paid_cost.get("ok", false)):
		return false
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
	_rebuild_occupation_runtime_indexes_mvp()
	_refresh_left_world_status_panel()
	_save_worldmap_state()
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
	var payment_check := _plan_city_stock_payment_mvp(city_id, cost)
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
	var paid_cost := _commit_city_stock_payment_mvp(city_id, cost)
	if not bool(paid_cost.get("ok", false)):
		return false
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
	_rebuild_occupation_runtime_indexes_mvp()
	_refresh_left_world_status_panel()
	_save_worldmap_state()
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
	var suggestions: Array = _ensure_troop_rebalance_service().calculate_suggestions()
	for suggestion_variant in suggestions:
		if suggestion_variant is Dictionary:
			var suggestion := suggestion_variant as Dictionary
			suggestion["reason"] = "후방 %s 잉여 병력 %d명 → 전선 %s 보강" % [str(suggestion.get("from", "")), int(suggestion.get("amount", 0)), str(suggestion.get("to", ""))]
	_player_state["last_troop_rebalance_suggestions"] = suggestions
	return suggestions


func _apply_troop_rebalance_suggestion(suggestion: Dictionary) -> bool:
	return bool(_ensure_troop_rebalance_service().apply_suggestion(suggestion).get("ok", false))


func _get_world_city_troop_total() -> int:
	var total := 0
	for city_id_variant in CITY_HUD_DATA.keys():
		total += _get_city_troops_for_battle_context(str(city_id_variant))
	return total


func _apply_context_side_troop_pre_decrement_mvp(battle_context: Dictionary, side_prefix: String, deployed_key: String) -> Dictionary:
	return _ensure_player_attack_deployment_service().apply_context_side_pre_decrement(battle_context, side_prefix, deployed_key)


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
	if owner_id == _get_current_player_faction_id() and not owned_city_ids.has(city_id):
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
	if _is_domestic_tech_tree_overlay_open_mvp():
		_refresh_domestic_tech_tree_overlay_mvp()


func _validate_pending_invasion_event_for_battle_context(event: Dictionary) -> Dictionary:
	return _ensure_battle_context_service()._validate_pending_invasion_event_for_battle_context(event)


func _build_battle_context_from_pending_invasion(event: Dictionary, mode: String, selected_defender_hero_ids: Array[String] = [], defender_troop_allocation_override: Dictionary = {}) -> Dictionary:
	return _ensure_battle_context_service()._build_battle_context_from_pending_invasion(event, mode, selected_defender_hero_ids, defender_troop_allocation_override)


func _build_player_attack_battle_context(source_city_id: String, target_city_id: String, mode: String = "manual", selected_attacker_hero_ids: Array[String] = [], attacker_troop_allocation: Dictionary = {}, supply_cost: Dictionary = {}) -> Dictionary:
	return _ensure_battle_context_service()._build_player_attack_battle_context(source_city_id, target_city_id, mode, selected_attacker_hero_ids, attacker_troop_allocation, supply_cost)


func _build_player_attack_selected_roster_for_battle_context(source_city_id: String, selected_hero_ids: Array[String], troop_allocation: Dictionary, used_hero_ids: Dictionary) -> Dictionary:
	return _ensure_battle_context_service()._build_player_attack_selected_roster_for_battle_context(source_city_id, selected_hero_ids, troop_allocation, used_hero_ids)


func _build_selected_side_roster_for_battle_context(source_city_id: String, selected_hero_ids: Array[String], troop_allocation: Dictionary, used_hero_ids: Dictionary, side_label: String) -> Dictionary:
	return _ensure_battle_context_service()._build_selected_side_roster_for_battle_context(source_city_id, selected_hero_ids, troop_allocation, used_hero_ids, side_label)


func _build_even_troop_allocation_for_heroes(hero_ids_source: Array, total_troops: int) -> Dictionary:
	return _ensure_battle_context_service()._build_even_troop_allocation_for_heroes(hero_ids_source, total_troops)


func _build_command_limit_troop_allocation_for_heroes(hero_ids_source: Array, total_troops: int, source_city_id: String) -> Dictionary:
	return _ensure_battle_context_service()._build_command_limit_troop_allocation_for_heroes(hero_ids_source, total_troops, source_city_id)


func _apply_troop_allocation_to_roster(roster: Dictionary, allocation: Dictionary, fallback_city_id: String) -> Dictionary:
	return _ensure_battle_context_service()._apply_troop_allocation_to_roster(roster, allocation, fallback_city_id)


func _sum_troop_allocation(allocation: Dictionary) -> int:
	return _ensure_battle_context_service()._sum_troop_allocation(allocation)


func _build_invasion_side_roster_for_battle_context(source_city_id: String, faction_id: String, used_hero_ids: Dictionary, context_side: String) -> Dictionary:
	return _ensure_battle_context_service()._build_invasion_side_roster_for_battle_context(source_city_id, faction_id, used_hero_ids, context_side)


func _append_invasion_roster_hero_id(target_hero_ids: Array[String], source_bucket: Array[String], hero_id: String, used_hero_ids: Dictionary, context_side: String, city_id: String, pick_type: String) -> bool:
	return _ensure_battle_context_service()._append_invasion_roster_hero_id(target_hero_ids, source_bucket, hero_id, used_hero_ids, context_side, city_id, pick_type)


func _build_invasion_roster_result(hero_ids: Array[String], main_hero_ids: Array[String], support_hero_ids: Array[String], support_city_ids: Array[String]) -> Dictionary:
	return _ensure_battle_context_service()._build_invasion_roster_result(hero_ids, main_hero_ids, support_hero_ids, support_city_ids)


func _get_reinforcement_candidate_city_ids_for_battle_context(source_city_id: String) -> Array[String]:
	return _ensure_battle_context_service()._get_reinforcement_candidate_city_ids_for_battle_context(source_city_id)


func _are_factions_reinforcement_compatible(source_faction_id: String, candidate_faction_id: String) -> bool:
	return _ensure_battle_context_service()._are_factions_reinforcement_compatible(source_faction_id, candidate_faction_id)


func _get_hero_city_id_for_battle_context(hero_id: String) -> String:
	return _ensure_battle_context_service()._get_hero_city_id_for_battle_context(hero_id)


func _has_city_for_battle_context(city_id: String) -> bool:
	if city_id.is_empty():
		return false
	return _city_markers_by_id.has(city_id) or not _get_city_hud_entry(city_id).is_empty()


func _get_city_owner_id_for_battle_context(city_id: String) -> String:
	if _city_runtime_states.has(city_id):
		var runtime_city: Variant = _city_runtime_states.get(city_id, {})
		if runtime_city is Dictionary:
			var runtime_owner := str((runtime_city as Dictionary).get("owner", (runtime_city as Dictionary).get("nation", "")))
			if not runtime_owner.is_empty():
				return runtime_owner
	var city_marker := _city_markers_by_id.get(city_id) as WorldMapCityMarker
	if city_marker != null and not city_marker.owner_faction_id.is_empty():
		return city_marker.owner_faction_id
	var city_data := _get_city_hud_entry(city_id)
	return str(city_data.get("owner", city_data.get("nation", "")))


func _get_city_troops_for_battle_context(city_id: String) -> int:
	return maxi(0, int(_get_city_hud_entry(city_id).get("troops", 0)))


func _battle_context_get_city_stationed_hero_ids(city_id: String) -> Array:
	var hero_ids: Array = []
	for hero_id in _get_stationed_hero_ids_for_city(_get_city_hud_entry(city_id)):
		hero_ids.append(str(hero_id))
	return hero_ids


func _get_city_stationed_hero_ids_for_battle_context(city_id: String) -> Array:
	return _ensure_battle_context_service()._get_city_stationed_hero_ids_for_battle_context(city_id)


func _get_city_battle_heroes_for_battle_context(city_id: String) -> Array[Dictionary]:
	return _ensure_battle_context_service()._get_city_battle_heroes_for_battle_context(city_id)


func _apply_domestic_battle_tech_modifier_to_hero_data_mvp(battle_data: Dictionary, city_id: String) -> Dictionary:
	return _ensure_battle_context_service()._apply_domestic_battle_tech_modifier_to_hero_data_mvp(battle_data, city_id)


func _get_hero_battle_data_for_battle_context(hero_id: String, fallback_city_id: String) -> Dictionary:
	return _ensure_battle_context_service()._get_hero_battle_data_for_battle_context(hero_id, fallback_city_id)


func _battle_context_get_city_governor_id(city_id: String) -> String:
	var city_entry := _get_city_hud_entry(city_id)
	return str(city_entry.get("governor_id", city_entry.get("governorHeroId", "")))


func _get_city_governor_id_for_battle_context(city_id: String) -> String:
	return _ensure_battle_context_service()._get_city_governor_id_for_battle_context(city_id)


func _normalize_command_rank_mvp(raw_rank: Variant) -> String:
	return _ensure_battle_context_service()._normalize_command_rank_mvp(raw_rank)


func _get_hero_command_rank_for_city_mvp(hero_data: Dictionary, city_id: String) -> String:
	return _ensure_battle_context_service()._get_hero_command_rank_for_city_mvp(hero_data, city_id)


func _get_hero_command_limit_for_city_mvp(hero_data: Dictionary, city_id: String) -> int:
	return _ensure_battle_context_service()._get_hero_command_limit_for_city_mvp(hero_data, city_id)


func _get_hero_command_summary_for_city_mvp(hero_data: Dictionary, city_id: String) -> Dictionary:
	return _ensure_battle_context_service()._get_hero_command_summary_for_city_mvp(hero_data, city_id)


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
		return "자동 방어 계산 및 정산 준비 완료"
	return "수동 방어 준비 완료 · 전투 화면 이동 대기"


func _clear_pending_invasion_event_mvp() -> void:
	_player_state["pending_invasion_event"] = {}
	_clear_pending_battle_context_mvp()


func _is_t03_faction_defeated(faction_id: String) -> bool:
	var defeated: Variant = _player_state.get("defeated_factions", {})
	if not defeated is Dictionary:
		return false
	var entry: Variant = (defeated as Dictionary).get(faction_id, {})
	return entry is Dictionary and bool((entry as Dictionary).get("defeated", false))


func _get_t03_eligible_city_hero_ids(city_id: String) -> Array[String]:
	var result: Array[String] = []
	for hero_id_variant in _get_city_stationed_hero_ids_for_battle_context(city_id):
		var hero_id := str(hero_id_variant)
		if hero_id.is_empty() or _get_hero_entry(hero_id).is_empty() or _is_hero_captured_for_battle(hero_id):
			continue
		result.append(hero_id)
		if result.size() >= INVASION_BATTLE_MAX_HEROES_PER_SIDE:
			break
	return result


func _get_t03_city_food_stock(city_id: String) -> Dictionary:
	return _ensure_t03_transaction_service().get_city_food_stock(city_id)


func _get_t03_city_food_total(city_id: String) -> int:
	return _ensure_t03_transaction_service().sum_food_stock(_get_t03_city_food_stock(city_id))


func _make_t03_transaction_id(attacker_city_id: String, defender_city_id: String) -> String:
	return _ensure_t03_transaction_service().make_transaction_id(attacker_city_id, defender_city_id)


func _build_t03_expedition_cargo_plan(city_id: String, troops: int) -> Dictionary:
	return _ensure_t03_transaction_service().build_expedition_cargo_plan(city_id, troops)


func _filter_t03_context_heroes(raw_heroes: Variant, hero_ids: Array[String], allocation: Dictionary) -> Array[Dictionary]:
	return _ensure_t03_transaction_service().filter_context_heroes(raw_heroes, hero_ids, allocation)


func _prepare_t03_battle_transaction(event: Dictionary, base_context: Dictionary, resolution_mode: String) -> Dictionary:
	var prepared := _ensure_t03_transaction_service().prepare(event, base_context, resolution_mode)
	return (prepared.get("context", {}) as Dictionary).duplicate(true) if bool(prepared.get("ok", false)) else {}


func _select_t03_food_type(food_stock: Dictionary) -> String:
	return _ensure_t03_transaction_service().select_food_type(food_stock)


func _sum_t03_food_stock(food_stock: Dictionary) -> int:
	return _ensure_t03_transaction_service().sum_food_stock(food_stock)


func _pay_t03_expedition_cargo(city_id: String, cargo: Dictionary) -> void:
	_ensure_t03_transaction_service().pay_expedition_cargo(city_id, cargo)


func _rollback_t03_battle_transaction(context: Dictionary) -> void:
	var rollback := _ensure_t03_transaction_service().rollback(context)
	if bool(rollback.get("ok", false)):
		_refresh_left_world_status_panel()


func _resolve_t03_automatic_invasion(event: Dictionary) -> Dictionary:
	if event.is_empty():
		return {}
	var context := _build_battle_context_from_pending_invasion(event, "auto")
	if context.is_empty():
		return {}
	var transaction := _ensure_t03_transaction_service().execute(event, context)
	if not bool(transaction.get("ok", false)):
		return {}
	var result: Dictionary = transaction.get("battle_result", {})
	_finalize_t03_strategic_battle_result(result, transaction.get("settlement", {}), false)
	return result


func _apply_t03_strategic_battle_result(result: Dictionary, from_direct_battle: bool) -> void:
	var settlement := _ensure_t03_transaction_service().apply_result(result, from_direct_battle)
	if not bool(settlement.get("ok", false)):
		_set_save_management_status("T03 전투 결과 정산 실패 · %s" % str(settlement.get("error_code", "unknown")))
		_refresh_left_world_status_panel()
		return
	_finalize_t03_strategic_battle_result(result, settlement, from_direct_battle)


func _finalize_t03_strategic_battle_result(result: Dictionary, settlement: Dictionary, from_direct_battle: bool) -> void:
	result["_t03_transaction_settlement"] = settlement.duplicate(true)
	_player_state["korea_unification_victory"] = _get_player_owned_korea_mvp_city_count() >= 4
	_player_state["korea_player_defeat"] = _get_player_owned_korea_mvp_city_count() <= 0
	_rebuild_occupation_runtime_indexes_mvp()
	_sync_worldmap_hero_locations_from_city_runtime_states()
	_refresh_city_marker_owner_states_from_runtime()
	_refresh_city_hud_data_bindings()
	var report := _build_t03_battle_report(result)
	if str(result.get("player_side", "")).is_empty() and not from_direct_battle:
		_queue_t03_automatic_battle_report(report)
	else:
		_show_post_battle_result_summary({"message_title": str(report.get("title", "전투 결과")), "message_lines": report.get("lines", [])})
	_save_worldmap_state()
	_refresh_left_world_status_panel()


func _apply_t03_defender_supply_result(city_id: String, result: Dictionary) -> void:
	_ensure_t03_transaction_service().apply_defender_supply(city_id, result)


func _add_t03_attacker_cargo_to_city(city_id: String, result: Dictionary) -> void:
	_ensure_t03_transaction_service().add_attacker_cargo(city_id, result)


func _build_t03_battle_report(result: Dictionary) -> Dictionary:
	return _ensure_t03_battle_presentation().build_report(result)


func _queue_t03_automatic_battle_report(report: Dictionary) -> void:
	_ensure_t03_battle_presentation().enqueue_report(report)



func _setup_t03_battle_presentation() -> void:
	_ensure_t03_battle_presentation().setup()
	call_deferred("_try_present_next_t03_battle_report")


func _try_present_next_t03_battle_report() -> void:
	if _has_terminal_korea_outcome_mvp():
		_present_t05_outcome_if_needed()
		return
	if _normalize_turn_phase(str(_player_state.get("turn_phase", TURN_PHASE_PLAYER))) != TURN_PHASE_PLAYER:
		return
	_ensure_t03_battle_presentation().try_present_next()


func _on_t03_battle_video_skipped() -> void:
	_ensure_t03_battle_presentation().skip_video()


func _on_t03_battle_video_finished() -> void:
	_ensure_t03_battle_presentation().finish_video()


func _show_t03_battle_report_card() -> void:
	_ensure_t03_battle_presentation().show_result_card()


func _on_t03_battle_report_confirmed() -> void:
	_ensure_t03_battle_presentation().confirm_report()


func _on_t03_battle_presentation_completed(_result: Dictionary) -> void:
	_save_worldmap_state()
	if _has_terminal_korea_outcome_mvp():
		call_deferred("_present_t05_outcome_if_needed")
		return
	call_deferred("_try_present_next_t03_battle_report")


func _setup_t05_outcome_presentation() -> void:
	_t05_outcome_presentation_root.visible = false
	if not _t05_outcome_save_button.pressed.is_connected(_on_t05_outcome_save_pressed):
		_t05_outcome_save_button.pressed.connect(_on_t05_outcome_save_pressed)
	if not _t05_outcome_new_game_button.pressed.is_connected(_on_t05_outcome_new_game_pressed):
		_t05_outcome_new_game_button.pressed.connect(_on_t05_outcome_new_game_pressed)


func _resume_t04_t05_presentation_after_ready() -> void:
	if _has_terminal_korea_outcome_mvp():
		_present_t05_outcome_if_needed()
		return
	if _normalize_turn_phase(str(_player_state.get("turn_phase", TURN_PHASE_PLAYER))) == TURN_PHASE_ENEMY:
		_run_enemy_turn_mvp()
		return
	_try_present_next_t03_battle_report()


func _evaluate_korea_mvp_outcome_mvp() -> Dictionary:
	var owned_city_count := _get_player_owned_korea_mvp_city_count()
	var existing: Dictionary = _player_state.get("game_outcome", {}) if _player_state.get("game_outcome", {}) is Dictionary else {}
	var status := TurnOutcomeRulesScript.evaluate_outcome(owned_city_count, T03_KOREA_CITY_IDS.size())
	var outcome := TurnOutcomeRulesScript.make_outcome_state(
		status,
		_get_current_player_faction_id(),
		maxi(1, int(_player_state.get("turn_number", 1))),
		owned_city_count,
		existing
	)
	_player_state["game_outcome"] = outcome
	_player_state["korea_unification_victory"] = str(outcome.get("status", "")) == TurnOutcomeRulesScript.OUTCOME_VICTORY
	_player_state["korea_player_defeat"] = str(outcome.get("status", "")) == TurnOutcomeRulesScript.OUTCOME_DEFEAT
	if TurnOutcomeRulesScript.is_terminal_outcome(outcome) and is_inside_tree():
		call_deferred("_present_t05_outcome_if_needed")
	return outcome


func _has_terminal_korea_outcome_mvp() -> bool:
	return TurnOutcomeRulesScript.is_terminal_outcome(_player_state.get("game_outcome", {}))


func _present_t05_outcome_if_needed() -> void:
	if not _has_terminal_korea_outcome_mvp() or _t05_outcome_presentation_root == null:
		return
	_ensure_t03_battle_presentation().reset_presentation()
	_t05_outcome_presentation_root.visible = true
	var outcome: Dictionary = _player_state.get("game_outcome", {})
	var status := str(outcome.get("status", TurnOutcomeRulesScript.OUTCOME_ACTIVE))
	var faction_label := _format_faction_label(_get_current_player_faction_id())
	var resolved_turn := maxi(1, int(outcome.get("resolved_turn", _player_state.get("turn_number", 1))))
	if status == TurnOutcomeRulesScript.OUTCOME_VICTORY:
		_t05_outcome_title.text = "한반도 통일"
		_t05_outcome_title.modulate = Color(1.0, 0.88, 0.58, 1.0)
		_t05_outcome_body.text = "%s 세력이 한성·평양·경주·사비를 모두 장악했습니다.\n제 %d턴, 한반도의 패권이 하나로 모였습니다." % [faction_label, resolved_turn]
	else:
		_t05_outcome_title.text = "세력 멸망"
		_t05_outcome_title.modulate = Color(0.9, 0.44, 0.42, 1.0)
		_t05_outcome_body.text = "%s 세력이 지배하던 마지막 도시를 잃었습니다.\n제 %d턴, 한반도 쟁패에서 패배했습니다." % [faction_label, resolved_turn]


func _on_t05_outcome_save_pressed() -> void:
	var outcome: Dictionary = _player_state.get("game_outcome", {}) if _player_state.get("game_outcome", {}) is Dictionary else {}
	outcome["acknowledged"] = true
	_player_state["game_outcome"] = outcome
	_save_worldmap_state()
	_t05_outcome_save_button.text = "저장 완료"


func _on_t05_outcome_new_game_pressed() -> void:
	get_tree().change_scene_to_file("res://NewGameFactionSelect.tscn")


func _format_last_turn_resolution_hint_mvp() -> String:
	var result: Dictionary = _player_state.get("last_turn_resolution_result", {}) if _player_state.get("last_turn_resolution_result", {}) is Dictionary else {}
	if result.is_empty():
		return ""
	var next_turn := maxi(1, int(result.get("next_turn", _player_state.get("turn_number", 1))))
	var enemy_summary := str(result.get("enemy_summary", "")).strip_edges()
	if enemy_summary.is_empty():
		return "제 %d턴 시작 · 이전 턴 정산 완료" % next_turn
	return "제 %d턴 시작 · %s" % [next_turn, enemy_summary]


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
	var current_turn := maxi(1, int(_player_state.get("turn_number", 1)))
	var previous_month_serial := _get_world_month_serial(current_turn)
	var next_turn := current_turn + 1
	_player_state["turn_number"] = next_turn
	var next_month_serial := _get_world_month_serial(next_turn)
	if next_month_serial != previous_month_serial:
		_ensure_wounded_recovery_service().advance_recovery_month(next_month_serial)
	_update_world_turn_labels()
	_refresh_city_hud_data_bindings()


func _get_city_wounded_queue_mvp(city_data: Dictionary) -> Array[Dictionary]:
	return _ensure_wounded_recovery_service().get_city_wounded_queue(city_data)


func _add_wounded_to_city_mvp(city_id: String, wounded_troops: int, turns_left: int = PLAYER_ATTACK_WOUNDED_QUEUE_TURNS, recovery_mode: String = "normal", transaction_id: String = "legacy") -> void:
	_ensure_wounded_recovery_service().add_wounded_to_city(city_id, wounded_troops, turns_left, recovery_mode, transaction_id)


func _clear_city_wounded_queue_mvp(city_id: String) -> void:
	_ensure_wounded_recovery_service().clear_city_wounded_queue(city_id)


func _apply_wounded_recovery_for_world_turn_mvp() -> void:
	var turn_number := maxi(1, int(_player_state.get("turn_number", 1)))
	_ensure_wounded_recovery_service().advance_recovery_month(_get_world_month_serial(turn_number))


func _get_world_month_serial(turn_number: int) -> int:
	return _ensure_world_calendar_service().world_month_serial(turn_number)


func _advance_wounded_hero_recovery_turns() -> void:
	var turn_number := maxi(1, int(_player_state.get("turn_number", 1)))
	_ensure_wounded_recovery_service().advance_recovery_month(_get_world_month_serial(turn_number))


func _apply_domestic_turn_mvp() -> String:
	# v0.68b-12b-6: port the web domestic income/tax/policy MVP once per completed player turn.
	var turn_number := maxi(1, int(_player_state.get("turn_number", 1)))
	if int(_player_state.get("last_domestic_apply_turn", 0)) == turn_number:
		return "내정 이미 적용됨"
	var tax_level := _normalize_tax_level(_player_state.get("tax_level", 30))
	var policy_id := _normalize_chancellor_policy_id(str(_player_state.get("chancellor_policy_id", "balanced")))
	var national_effects := _calculate_active_chancellor_national_effects()
	var diplomacy_normalize_result := _ensure_diplomacy_controller()._normalize_faction_relations_for_world_state()
	var diplomacy_cooldown_result := _ensure_diplomacy_controller()._advance_diplomacy_cooldowns_for_world_turn()
	var spy_cooldown_result := _advance_spy_cooldown_for_world_turn()
	var revolt_instigation_tick_result := _advance_revolt_instigation_for_world_turn()
	var supply_states := _calculate_all_city_supply_states()
	var city_production_result := _apply_player_city_production_for_world_turn_mvp(turn_number, tax_level, policy_id, national_effects, supply_states)
	var income_delta: Dictionary = city_production_result.get("totals", {})
	var domestic_tech_economy_summary := _get_domestic_tech_economy_turn_summary_mvp()
	var upkeep_delta := _calculate_player_hero_upkeep_delta(policy_id, national_effects, supply_states)
	var applied_upkeep_delta := _apply_resource_delta(upkeep_delta)
	var applied_delta := _combine_resource_deltas(income_delta, applied_upkeep_delta)
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
	var domestic_tech_progress_result := _advance_domestic_tech_research_for_world_turn_mvp()
	var tech_effect_result := _apply_completed_tech_effects_for_world_turn()
	var trade_market_result := _update_trade_market_for_world_turn(supply_states)
	var chancellor_auto_trade_result := _apply_chancellor_auto_trade_for_world_turn(turn_number)
	_player_state["last_domestic_apply_turn"] = turn_number
	_player_state["resources"] = _format_player_resource_summary()
	_player_state["income"] = _format_domestic_apply_summary(applied_delta, applied_loyalty_delta, inter_faction_trade_result, supply_states, city_loyalty_drift_result, public_support_result, seasonal_loyalty_result, conscription_result, revolt_warning_result, national_tech_progress_result, city_tech_progress_result, domestic_tech_progress_result, tech_effect_result, trade_market_result, diplomacy_normalize_result, diplomacy_cooldown_result, spy_cooldown_result, domestic_tech_economy_summary)
	_player_state["tax_effect"] = _format_tax_effect_text(tax_level)
	_player_state["last_domestic_apply_result"] = {
		"version": "v0.69-4",
		"turn_number": turn_number,
		"tax_level": tax_level,
		"chancellor_policy_id": policy_id,
		"income_delta": income_delta,
		"city_production_result": city_production_result,
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
		"domestic_tech_progress_result": domestic_tech_progress_result,
		"tech_effect_result": tech_effect_result,
		"trade_market_result": trade_market_result,
		"chancellor_auto_trade_result": chancellor_auto_trade_result,
	}
	return _format_domestic_apply_summary(applied_delta, applied_loyalty_delta, inter_faction_trade_result, supply_states, city_loyalty_drift_result, public_support_result, seasonal_loyalty_result, conscription_result, revolt_warning_result, national_tech_progress_result, city_tech_progress_result, domestic_tech_progress_result, tech_effect_result, trade_market_result, diplomacy_normalize_result, diplomacy_cooldown_result, spy_cooldown_result, domestic_tech_economy_summary)


func _apply_player_city_production_for_world_turn_mvp(turn_number: int, tax_level: int, policy_id: String, national_effects: Dictionary, supply_states: Dictionary = {}) -> Dictionary:
	return _ensure_city_resource_service().apply_city_production(turn_number, tax_level, policy_id, national_effects, supply_states)


func _calculate_player_city_production_income_mvp(city_id: String, turn_number: int, tax_level: int, policy_id: String, national_effects: Dictionary, supply_states: Dictionary) -> Dictionary:
	var city_data := _get_city_hud_entry(city_id)
	if city_data.is_empty():
		return {}
	var calendar := _get_world_calendar_for_turn(turn_number)
	var city_effects := _calculate_city_domestic_effects(city_data, policy_id)
	var city_supply_state := _get_supply_city_state(supply_states, city_id)
	_apply_supply_income_effect(city_effects, city_supply_state)
	city_effects = _apply_tech_income_multipliers_to_effects(city_id, city_effects)
	var city_income := _calculate_city_domestic_income(city_data, calendar, tax_level, city_effects)
	city_income = _apply_domestic_tech_city_economy_bonus_to_income_mvp(city_id, city_income)
	city_income = _apply_chancellor_policy_to_income_totals(city_income, policy_id)
	return _apply_income_multipliers_to_totals(city_income, national_effects)


func _apply_ai_city_production_for_world_turn_mvp() -> Dictionary:
	var turn_number := maxi(1, int(_player_state.get("turn_number", 1)))
	var previous: Dictionary = _player_state.get("last_ai_domestic_apply_result", {}) if _player_state.get("last_ai_domestic_apply_result", {}) is Dictionary else {}
	if int(_player_state.get("last_ai_domestic_apply_turn", 0)) == turn_number:
		return previous
	var calendar := _get_world_calendar_for_turn(turn_number)
	var city_results: Array[Dictionary] = []
	var totals := _create_empty_domestic_income_totals()
	for city_id in T03_KOREA_CITY_IDS:
		var owner_id := _get_city_owner_id_for_battle_context(city_id)
		if owner_id.is_empty() or owner_id == _get_current_player_faction_id() or _is_t03_faction_defeated(owner_id):
			continue
		var city_data := _get_city_hud_entry(city_id)
		if city_data.is_empty():
			continue
		var income := _calculate_city_domestic_income(city_data, calendar, 30, {})
		var applied := _apply_resource_delta_to_city_stock_mvp(city_id, income)
		for resource_id in totals.keys():
			totals[resource_id] = int(totals.get(resource_id, 0)) + int(applied.get(resource_id, 0))
		city_results.append({"city_id": city_id, "owner_id": owner_id, "resource_delta": applied})
	var result := {
		"turn": turn_number,
		"city_count": city_results.size(),
		"cities": city_results,
		"totals": totals,
		"enemy_research_advanced": false,
	}
	_player_state["last_ai_domestic_apply_turn"] = turn_number
	_player_state["last_ai_domestic_apply_result"] = result.duplicate(true)
	return result


func _get_world_calendar_for_turn(turn_number: int) -> Dictionary:
	return _ensure_world_calendar_service().get_calendar(turn_number)


func _is_seasonal_loyalty_turn(turn_number: int) -> bool:
	return _ensure_world_calendar_service().is_season_boundary(turn_number)


func _get_next_seasonal_loyalty_turn(turn_number: int) -> int:
	return _ensure_world_calendar_service().get_next_season_boundary(turn_number)


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
		city_income = _apply_domestic_tech_city_economy_bonus_to_income_mvp(str(city_id), city_income)
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


func _apply_domestic_tech_economy_numeric_bonus_value_mvp(base_value: Variant, percent_bonus: float, flat_bonus: int = 0) -> int:
	var scaled_value := int(round(float(base_value) * (1.0 + percent_bonus)))
	return maxi(0, scaled_value + flat_bonus)


func _apply_domestic_tech_city_economy_bonus_to_income_mvp(city_id: String, income: Dictionary) -> Dictionary:
	var result := income.duplicate(true)
	if city_id.is_empty() or not _is_city_owned_by_player_mvp(city_id):
		return result
	var city_modifier := _get_player_city_domestic_economy_modifier_mvp(city_id)
	var food_percent := float(city_modifier.get("food_income_pct", 0.0))
	var food_flat := int(city_modifier.get("food_flat", 0))
	for food_resource_id in CITY_STORAGE_FOOD_RESOURCE_IDS:
		result[food_resource_id] = _apply_domestic_tech_economy_numeric_bonus_value_mvp(result.get(food_resource_id, 0), food_percent)
	if food_flat != 0:
		var target_food_id := "rice"
		for food_resource_id in CITY_STORAGE_FOOD_RESOURCE_IDS:
			if int(result.get(food_resource_id, 0)) > 0:
				target_food_id = food_resource_id
				break
		result[target_food_id] = _apply_domestic_tech_economy_numeric_bonus_value_mvp(result.get(target_food_id, 0), 0.0, food_flat)
	var gold_percent := float(city_modifier.get("gold_income_pct", 0.0))
	var national_modifier := _get_national_domestic_economy_modifier_mvp()
	var national_tax_gold_percent := maxf(0.0, float(national_modifier.get("tax_pct", 0.0)))
	gold_percent += national_tax_gold_percent
	var gold_flat := int(city_modifier.get("gold_flat", 0))
	result["gold"] = _apply_domestic_tech_economy_numeric_bonus_value_mvp(result.get("gold", 0), gold_percent, gold_flat)
	return result


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
	if hero_data.is_empty() or str(hero_data.get("side", "")) != _get_current_player_faction_id():
		return effect
	_apply_chancellor_type_effect(effect, str(hero_data.get("chancellor_primary_type", "")), float(hero_data.get("chancellor_primary_aptitude", 0)), CHANCELLOR_PRIMARY_RATE)
	_apply_chancellor_type_effect(effect, str(hero_data.get("chancellor_secondary_type", "")), float(hero_data.get("chancellor_secondary_aptitude", 0)), CHANCELLOR_SECONDARY_RATE)
	return effect


func _calculate_city_domestic_effects(city_data: Dictionary, chancellor_policy_id: String) -> Dictionary:
	var governor_id := str(city_data.get("governor_id", city_data.get("governorHeroId", "")))
	var city_id := str(city_data.get("id", ""))
	var governor_data := _get_hero_entry(governor_id)
	var chancellor_data := _get_hero_entry(str(_player_state.get("chancellor_id", "")))
	return _ensure_city_administration_service().calculate_city_domestic_effects(
		city_data,
		governor_data,
		chancellor_data,
		_get_current_player_faction_id(),
		_get_city_policy_id(city_id, city_data),
		chancellor_policy_id,
		CHANCELLOR_PRIMARY_RATE,
		CHANCELLOR_SECONDARY_RATE
	)


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
	_ensure_city_administration_service().apply_governor_type_effect(effect, type_id, aptitude, rate)


func _apply_governor_policy_effect(effect: Dictionary, governor_policy_id: String, chancellor_policy_id: String) -> void:
	_ensure_city_administration_service().apply_governor_policy_effect(effect, governor_policy_id, chancellor_policy_id)


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




func _create_empty_inter_faction_trade_totals() -> Dictionary:
	return {"gold": 0, "rice": 0, "barley": 0, "seafood": 0, "salt": 0}


func _make_faction_relation_key(faction_a: String, faction_b: String) -> String:
	return _ensure_diplomacy_controller()._make_faction_relation_key(faction_a, faction_b)


func _normalize_faction_relation_status(status: String) -> String:
	return _ensure_diplomacy_controller()._normalize_faction_relation_status(status)


func _get_faction_relation_band(score: int) -> String:
	return _ensure_diplomacy_controller()._get_faction_relation_band(score)


func _ensure_faction_relation_entry(faction_a: String, faction_b: String) -> Dictionary:
	return _ensure_diplomacy_controller()._ensure_faction_relation_entry(faction_a, faction_b)


func _get_faction_relation_score(faction_a: String, faction_b: String) -> int:
	return _ensure_diplomacy_controller()._get_faction_relation_score(faction_a, faction_b)


func _get_faction_relation_status(faction_a: String, faction_b: String) -> String:
	return _ensure_diplomacy_controller()._get_faction_relation_status(faction_a, faction_b)


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


func _sync_diplomacy_action_mirror_state_from_relations() -> void:
	_ensure_diplomacy_controller()._sync_diplomacy_action_mirror_state_from_relations()


func _validate_diplomacy_action(action_id: String, target_city_id: String = "") -> Dictionary:
	return _ensure_diplomacy_controller()._validate_diplomacy_action(action_id, target_city_id)


func _apply_diplomacy_action(action_id: String, target_city_id: String = "") -> Dictionary:
	return _ensure_diplomacy_action_coordinator().execute_now("diplomacy", action_id, target_city_id)


func _on_diplomacy_action_pressed(action_id: String) -> void:
	if _contextual_worldmap_action_type == "diplomacy" and _contextual_worldmap_action_pending:
		return
	var target := _ensure_diplomacy_controller()._get_selected_diplomacy_target()
	var target_city_id := str(target.get("target_city_id", ""))
	if _contextual_worldmap_action_type == "diplomacy":
		target_city_id = _contextual_worldmap_action_target_city_id
		var contextual_validation := _validate_diplomacy_action(action_id, target_city_id)
		if bool(contextual_validation.get("ok", false)):
			_request_contextual_worldmap_action_presentation("diplomacy", action_id, target_city_id)
		else:
			var failure_result := _apply_diplomacy_action(action_id, target_city_id)
			_resolve_contextual_worldmap_action_without_video("diplomacy", failure_result)
		return
	var result := _apply_diplomacy_action(action_id, target_city_id)
	_save_management_status = str(result.get("message", "외교 행동 처리"))
	print("[DIPLOMACY_ACTION] ", result)
	_refresh_left_world_status_panel()
	_show_unified_diplomacy_spy_content()


func _calculate_military_support_acceptance_chance(target_faction_id: String) -> int:
	if target_faction_id.is_empty() or target_faction_id == _get_current_player_faction_id():
		return 0
	var relation := _ensure_faction_relation_entry(_get_current_player_faction_id(), target_faction_id)
	var score := clampi(int(relation.get("score", DIPLOMACY_DEFAULT_SCORE)), DIPLOMACY_SCORE_MIN, DIPLOMACY_SCORE_MAX)
	var rejection_count := maxi(0, int(relation.get("military_support_rejection_count", 0)))
	return _get_modified_diplomacy_success_chance_mvp(score - rejection_count * 10, "military_support", target_faction_id)


func _request_military_support(target_faction_id: String) -> bool:
	var turn_number := maxi(1, int(_player_state.get("turn_number", 1)))
	if target_faction_id.is_empty() or target_faction_id == _get_current_player_faction_id():
		_player_state["last_military_support_result"] = {"turn": turn_number, "target_faction_id": target_faction_id, "success": false, "accepted": false, "reason": "invalid_target"}
		return false
	var relation := _ensure_faction_relation_entry(_get_current_player_faction_id(), target_faction_id)
	var status := _normalize_faction_relation_status(str(relation.get("status", FACTION_RELATION_STATUS["NEUTRAL"])))
	if status != FACTION_RELATION_STATUS["ALLIED"]:
		_player_state["last_military_support_result"] = {"turn": turn_number, "target_faction_id": target_faction_id, "success": false, "accepted": false, "reason": "not_allied", "status": status}
		return false
	var acceptance_chance := _calculate_military_support_acceptance_chance(target_faction_id)
	var accepted := acceptance_chance >= MILITARY_SUPPORT_ACCEPTANCE_THRESHOLD
	var relation_key := _make_faction_relation_key(_get_current_player_faction_id(), target_faction_id)
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
		var relation_result := _adjust_faction_relation_score(_get_current_player_faction_id(), target_faction_id, relation_penalty, "military_support_rejected")
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


func _get_trade_agreement_bonus_multiplier(faction_a: String, faction_b: String) -> float:
	return _ensure_diplomacy_controller()._get_trade_agreement_bonus_multiplier(faction_a, faction_b)


func _get_current_chancellor_political_aptitude() -> int:
	var chancellor_id := str(_player_state.get("chancellor_id", ""))
	if chancellor_id.is_empty():
		return 0
	var hero_data := _get_hero_entry(chancellor_id)
	if hero_data.is_empty() or str(hero_data.get("side", "")) != _get_current_player_faction_id():
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
	if hero_data.is_empty() or str(hero_data.get("side", "")) != _get_current_player_faction_id():
		return false
	return str(hero_data.get("chancellor_primary_type", "")) == "political"


func _get_spy_action_definition(action_id: String) -> Dictionary:
	return _ensure_spy_controller().get_spy_action_definition(action_id)


func _format_spy_validation_message(check: Dictionary) -> String:
	return _ensure_spy_controller().format_spy_validation_message(check)


func _validate_spy_action(action_id: String, target_city_id: String = "") -> Dictionary:
	return _ensure_spy_controller().validate_spy_action(action_id, target_city_id)


func _apply_spy_action(action_id: String, target_city_id: String = "") -> Dictionary:
	return _ensure_diplomacy_action_coordinator().execute_now("spy", action_id, target_city_id)


func _on_spy_action_pressed(action_id: String) -> void:
	if _contextual_worldmap_action_type == "spy" and _contextual_worldmap_action_pending:
		return
	if _contextual_worldmap_action_type == "spy":
		var target_city_id := _contextual_worldmap_action_target_city_id
		var contextual_validation := _validate_spy_action(action_id, target_city_id)
		if bool(contextual_validation.get("ok", false)):
			_request_contextual_worldmap_action_presentation("spy", action_id, target_city_id)
		else:
			var failure_result := _apply_spy_action(action_id, target_city_id)
			_resolve_contextual_worldmap_action_without_video("spy", failure_result)
		return
	_apply_spy_action(action_id)
	_refresh_city_hud_data_bindings()
	if selected_city_marker != null:
		city_info_panel.show_city(selected_city_marker)
	_show_unified_diplomacy_spy_content()


func _advance_revolt_instigation_for_world_turn() -> Dictionary:
	return _ensure_spy_controller().advance_revolt_instigation_for_world_turn()


func _advance_spy_cooldown_for_world_turn() -> Dictionary:
	return _ensure_spy_controller().advance_spy_cooldown_for_world_turn()


func _get_known_faction_ids_for_diplomacy() -> Array:
	return _ensure_diplomacy_controller()._get_known_faction_ids_for_diplomacy()


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
		if city_data.is_empty() or _get_city_owner_faction_id(city_data) != _get_current_player_faction_id():
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
	if city_data.is_empty() or _get_city_owner_faction_id(city_data) != _get_current_player_faction_id():
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
			if neighbor_data.is_empty() or _get_city_owner_faction_id(neighbor_data) != _get_current_player_faction_id():
				continue
			queue.append(neighbor_id)
	return false


func _calculate_city_supply_state(city_id: String, hub_id: String) -> Dictionary:
	var city_data := _get_city_hud_entry(city_id)
	if city_data.is_empty() or _get_city_owner_faction_id(city_data) != _get_current_player_faction_id():
		return {}
	var role := "rear"
	var has_enemy_neighbor := false
	var city_marker := _city_markers_by_id.get(city_id) as WorldMapCityMarker
	if city_marker != null:
		for neighbor_id_variant in city_marker.neighbors:
			var neighbor_data := _get_city_hud_entry(str(neighbor_id_variant))
			if not neighbor_data.is_empty() and _get_city_owner_faction_id(neighbor_data) != _get_current_player_faction_id():
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
		if hero_data.is_empty() or str(hero_data.get("side", "")) != _get_current_player_faction_id():
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
	var applied_delta := {}
	for resource_id in RESOURCE_DISPLAY_ORDER:
		var resource_key := str(resource_id)
		var requested_delta := int(delta.get(resource_key, 0))
		applied_delta[resource_key] = _apply_player_resource_delta_capital_first_mvp(resource_key, requested_delta)
	_sync_player_resource_compatibility_from_city_stock_mvp()
	return applied_delta


func _get_ordered_player_resource_city_ids_mvp() -> Array[String]:
	var capital_city_id := str(_player_state.get("capital_city_id", _player_state.get("origin_city_id", "")))
	var raw_owned_city_ids: Variant = _player_state.get("owned_city_ids", [])
	var owned_city_ids: Array = raw_owned_city_ids if raw_owned_city_ids is Array else []
	var ownership := {}
	if not capital_city_id.is_empty():
		ownership[capital_city_id] = _get_city_owner_id_for_battle_context(capital_city_id)
	if raw_owned_city_ids is Array:
		for city_id_variant in raw_owned_city_ids:
			var city_id := str(city_id_variant)
			ownership[city_id] = _get_city_owner_id_for_battle_context(city_id)
	return _ensure_city_resource_service().get_ordered_player_city_ids(capital_city_id, owned_city_ids, ownership, _get_current_player_faction_id())


func _apply_resource_delta_to_city_stock_mvp(city_id: String, delta: Dictionary) -> Dictionary:
	return _ensure_city_resource_service().apply_resource_delta_to_city_stock(city_id, delta)


func _apply_player_resource_delta_capital_first_mvp(resource_id: String, requested_delta: int) -> int:
	return _ensure_city_resource_service().apply_player_resource_delta_capital_first(resource_id, requested_delta)


func _sync_player_resource_compatibility_from_city_stock_mvp() -> Dictionary:
	return _ensure_city_resource_service().sync_player_resource_compatibility()


func _adjust_loyalty_delta(base_delta: int, loss_multiplier: float) -> int:
	if base_delta >= 0:
		return base_delta
	return mini(-1, int(ceil(float(base_delta) * loss_multiplier)))


func _format_domestic_apply_summary(resource_delta: Dictionary, loyalty_delta: int, inter_faction_trade_result: Dictionary = {}, supply_state_result: Dictionary = {}, city_loyalty_drift_result: Dictionary = {}, public_support_result: Dictionary = {}, seasonal_loyalty_result: Dictionary = {}, conscription_result: Dictionary = {}, revolt_warning_result: Dictionary = {}, national_tech_progress_result: Dictionary = {}, city_tech_progress_result: Dictionary = {}, domestic_tech_progress_result: Dictionary = {}, tech_effect_result: Dictionary = {}, trade_market_result: Dictionary = {}, diplomacy_normalize_result: Dictionary = {}, diplomacy_cooldown_result: Dictionary = {}, spy_cooldown_result: Dictionary = {}, domestic_tech_economy_summary: Dictionary = {}) -> String:
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
	if not domestic_tech_progress_result.is_empty():
		var domestic_tech_summary := _format_domestic_tech_progress_summary_mvp(domestic_tech_progress_result)
		if not domestic_tech_summary.is_empty():
			parts.append(domestic_tech_summary)
	if not domestic_tech_economy_summary.is_empty():
		var domestic_tech_economy_text := _format_domestic_tech_economy_turn_summary_mvp(domestic_tech_economy_summary)
		if not domestic_tech_economy_text.is_empty():
			parts.append(domestic_tech_economy_text)
	if not tech_effect_result.is_empty():
		var effect_summary := _format_tech_effect_summary(tech_effect_result)
		if not effect_summary.is_empty():
			parts.append(effect_summary)
	if not trade_market_result.is_empty():
		var market_summary := _format_trade_market_summary(trade_market_result)
		if not market_summary.is_empty():
			parts.append(market_summary)
	if not diplomacy_normalize_result.is_empty():
		var diplomacy_summary := _ensure_diplomacy_presenter()._format_diplomacy_normalize_summary(diplomacy_normalize_result)
		if not diplomacy_summary.is_empty():
			parts.append(diplomacy_summary)
	if not diplomacy_cooldown_result.is_empty():
		var cooldown_summary := _ensure_diplomacy_presenter()._format_diplomacy_cooldown_summary(diplomacy_cooldown_result)
		if not cooldown_summary.is_empty():
			parts.append(cooldown_summary)
	var tribute_summary := _ensure_diplomacy_presenter()._format_last_tribute_summary(maxi(1, int(diplomacy_cooldown_result.get("turn", _player_state.get("turn_number", 1)))))
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


func _format_spy_cooldown_summary(result: Dictionary) -> String:
	return _ensure_spy_presenter().format_cooldown_summary(result)


func _format_last_spy_summary(turn_number: int) -> String:
	return _ensure_spy_presenter().format_last_summary(turn_number)


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


func _format_domestic_tech_progress_summary_mvp(result: Dictionary) -> String:
	var completed: Variant = result.get("completed", [])
	if not completed is Array or (completed as Array).is_empty():
		return ""
	var parts: Array[String] = []
	for entry_variant in completed:
		if not entry_variant is Dictionary:
			continue
		var entry := entry_variant as Dictionary
		var message := str(entry.get("message", ""))
		if message.is_empty():
			var tech_id := str(entry.get("tech_id", ""))
			if str(entry.get("type", "")) == DOMESTIC_TECH_SCOPE_CITY:
				message = "%s 연구 완료: %s" % [_format_city_name_by_id(str(entry.get("city_id", "")), str(entry.get("city_id", ""))), _get_domestic_tech_display_name_mvp(tech_id)]
			else:
				message = "연구 완료: %s" % _get_domestic_tech_display_name_mvp(tech_id)
		parts.append(message)
	return "" if parts.is_empty() else "내정 연구 완료: %s" % " / ".join(parts)


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
	var city_state := _serialize_worldmap_city_runtime_state()
	var hero_state := _serialize_worldmap_hero_runtime_state()
	var city_policy_state := _serialize_worldmap_city_policy_state()
	print("[SAVE_WORLD_STATE] city_overrides=%d hero_overrides=%d pending_invasion_persisted=%s" % [
		city_state.size(),
		hero_state.size(),
		str(not (saved_player_state.get("pending_invasion_event", {}) as Dictionary).is_empty()),
	])
	return {
		"version": "v0.76",
		"title": "T04-T05 Korea MVP Turn Loop and Unification Completion",
		"game_session": _get_game_session().serialize(),
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
	var session_data: Variant = data.get("game_session", {})
	if session_data is Dictionary:
		_get_game_session().apply_saved_session(session_data as Dictionary)
	else:
		# Legacy saves represented Hanseong with the old player registry ID.
		_get_game_session().configure_korea_mvp(str(_player_state.get("player_faction_id", "player")))
	_player_state["active_scenario_id"] = _get_game_session().active_scenario_id
	_player_state["player_faction_id"] = _get_game_session().player_faction_id
	_player_state["ai_faction_ids"] = _get_game_session().ai_faction_ids.duplicate()
	_ensure_worldmap_runtime_state_defaults()
	_city_runtime_states.clear()
	_hero_runtime_states.clear()
	_city_policy_state.clear()
	_apply_worldmap_city_runtime_state(data.get("worldmap_city_state", {}))
	_apply_worldmap_city_policy_state(data.get("city_policy_state", {}))
	_apply_worldmap_hero_runtime_state(data.get("worldmap_hero_state", {}))
	_restore_trade_persistence_from_player_state()
	_sync_worldmap_hero_locations_from_city_runtime_states()
	_rebuild_occupation_runtime_indexes_mvp()
	_refresh_city_marker_owner_states_from_runtime()
	_refresh_city_hud_data_bindings()
	_domestic_turn_apply_pending = bool(_player_state.get("domestic_apply_pending", false))
	_evaluate_korea_mvp_outcome_mvp()
	print("[LOAD_WORLD_STATE] city_overrides=%d hero_overrides=%d pending_invasion_restored=%s" % [
		_city_runtime_states.size(),
		_hero_runtime_states.size(),
		str(not _get_pending_invasion_event_mvp().is_empty()),
	])
	return true


func _save_worldmap_state() -> void:
	_write_worldmap_state_mvp(true)


func _checkpoint_worldmap_state_mvp() -> bool:
	return _write_worldmap_state_mvp(false)


func _write_worldmap_state_mvp(show_status: bool) -> bool:
	var save_data := _serialize_worldmap_state()
	var file := FileAccess.open(WORLDMAP_SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("[WorldMap] Failed to open worldmap save path: %s" % WORLDMAP_SAVE_PATH)
		if show_status:
			_set_save_management_status("저장 실패")
		return false
	file.store_string(JSON.stringify(save_data, "\t"))
	if show_status:
		_set_save_management_status("저장 완료")
	return true


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
	call_deferred("_resume_t04_t05_presentation_after_ready")


func _reset_worldmap_state() -> void:
	_cancel_enemy_turn_timer_if_needed()
	if _t05_outcome_presentation_root != null:
		_t05_outcome_presentation_root.visible = false
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
	var hero_data := HeroDefinitionRegistryScript.HERO_DATA.duplicate(true)
	for hero_id_variant in _hero_runtime_states.keys():
		var hero_id := str(hero_id_variant)
		var merged_entry := _get_hero_entry(hero_id)
		if not merged_entry.is_empty():
			hero_data[hero_id] = merged_entry
	return hero_data


func _refresh_city_hud_data_bindings() -> void:
	if city_info_panel == null:
		return
	_ensure_hud_controller().refresh_selected_city_binding({
		"player_faction_id": _get_current_player_faction_id(),
		"enemy_city_intel": _normalize_city_intel_registry(_player_state.get("city_intel", {})),
		"hero_data": _get_hero_data_for_ui(),
		"city_data": _get_city_hud_data_for_ui(),
		"governor_policy_data": GOVERNOR_POLICY_DATA,
		"city_policy_state": _city_policy_state,
		"recruitment_summaries": _get_recruitment_summaries_for_ui(),
		"revolt_risk_summaries": _get_revolt_risk_summaries_for_ui(),
	})


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
			"last_battle_current_troops": maxi(0, int(source.get("last_battle_current_troops", 0))),
			"last_battle_max_troops": maxi(0, int(source.get("last_battle_max_troops", 0))),
			"last_battle_transaction_id": str(source.get("last_battle_transaction_id", "")),
			"side": str(source.get("side", source.get("nation", ""))),
			"nation": str(source.get("nation", source.get("side", ""))),
			"faction_id": str(source.get("faction_id", source.get("side", ""))),
			"force_id": str(source.get("force_id", source.get("faction_id", source.get("side", "")))),
			"appointment": str(source.get("appointment", "")),
			"office": str(source.get("office", "")),
			"command_rank": str(source.get("command_rank", "")),
			"acquisition_type": str(source.get("acquisition_type", "")),
			"acquired_from_faction_id": str(source.get("acquired_from_faction_id", "")),
			"acquired_transaction_id": str(source.get("acquired_transaction_id", "")),
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
			city_tech[DOMESTIC_TECH_RESEARCH_KEY] = _normalize_domestic_tech_research_container_mvp(city_tech.get(DOMESTIC_TECH_RESEARCH_KEY, {}), DOMESTIC_TECH_SCOPE_CITY, city_id)
			city_state["city_tech"] = city_tech
		var wounded_queue := _get_city_wounded_queue_mvp(source)
		if not wounded_queue.is_empty():
			city_state["woundedQueue"] = wounded_queue
			city_state["wounded_queue"] = wounded_queue.duplicate(true)
		var stationed_hero_ids := _normalize_hero_id_array(source.get("stationed_hero_ids", source.get("hero_ids", city_state.get("stationed_hero_ids", []))))
		city_state["stationed_hero_ids"] = stationed_hero_ids
		city_state["hero_ids"] = stationed_hero_ids.duplicate()
		_city_runtime_states[city_id] = city_state
		_sync_city_domestic_tech_completed_mirror_mvp(city_id)
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
	return HeroDefinitionRegistryScript.HERO_DATA.get(hero_id, {})


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
		"last_battle_current_troops": maxi(0, int(raw_state.get("last_battle_current_troops", 0))),
		"last_battle_max_troops": maxi(0, int(raw_state.get("last_battle_max_troops", 0))),
		"last_battle_transaction_id": str(raw_state.get("last_battle_transaction_id", "")),
		"side": str(raw_state.get("side", seed_entry.get("side", ""))),
		"nation": str(raw_state.get("nation", seed_entry.get("nation", ""))),
		"faction_id": str(raw_state.get("faction_id", seed_entry.get("faction_id", ""))),
		"force_id": str(raw_state.get("force_id", seed_entry.get("force_id", ""))),
		"appointment": str(raw_state.get("appointment", "")),
		"office": str(raw_state.get("office", "")),
		"command_rank": str(raw_state.get("command_rank", seed_entry.get("command_rank", ""))),
		"acquisition_type": str(raw_state.get("acquisition_type", "")),
		"acquired_from_faction_id": str(raw_state.get("acquired_from_faction_id", "")),
		"acquired_transaction_id": str(raw_state.get("acquired_transaction_id", "")),
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
	var resource_stock := _get_player_national_resource_stock_mvp()
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
	var resource_stock := _get_player_national_resource_stock_mvp()
	return int(resource_stock.get(resource_id, 0))


func _get_player_national_resource_stock_mvp() -> Dictionary:
	var aggregation: Variant = _player_state.get("national_aggregation", {})
	if aggregation is Dictionary and (aggregation as Dictionary).get("resources", {}) is Dictionary:
		return ((aggregation as Dictionary).get("resources", {}) as Dictionary)
	return _player_state.get("resource_stock", {})


func _get_city_storage(city_id: String, city_data: Dictionary = {}) -> Dictionary:
	var source_data: Dictionary = city_data
	if source_data.is_empty() and not city_id.is_empty():
		source_data = _get_city_hud_entry(city_id)
	var player_resource_stock: Dictionary = _player_state.get("resource_stock", {}) if _player_state.get("resource_stock", {}) is Dictionary else {}
	var storage := _ensure_city_resource_service().get_city_storage(city_id, source_data, player_resource_stock)
	if not city_id.is_empty():
		var runtime_state := _get_mutable_city_runtime_state(city_id)
		if not runtime_state.is_empty():
			runtime_state["storage"] = storage.duplicate(true)
			_city_runtime_states[city_id] = runtime_state
	return storage


func _normalize_city_storage(raw_storage: Variant) -> Dictionary:
	return _ensure_city_resource_service().normalize_city_storage(raw_storage)


func _ensure_city_storage_keys(storage: Dictionary) -> Dictionary:
	return _ensure_city_resource_service().ensure_city_storage_keys(storage)


func _build_default_city_storage(city_id: String, _city_data: Dictionary) -> Dictionary:
	var player_resource_stock: Dictionary = _player_state.get("resource_stock", {}) if _player_state.get("resource_stock", {}) is Dictionary else {}
	return _ensure_city_resource_service().build_default_city_storage(city_id, player_resource_stock)


func _format_city_storage_summary(storage: Dictionary) -> String:
	return _ensure_city_detail_presentation_controller().format_city_storage_summary(
		storage, RESOURCE_LABELS,
		CITY_STORAGE_FOOD_RESOURCE_IDS,
		CITY_STORAGE_STRATEGY_RESOURCE_IDS,
		CITY_STORAGE_SPECIAL_RESOURCE_IDS
	)


func _get_city_storage_group_total(storage: Dictionary, resource_ids: Array) -> int:
	return _ensure_city_resource_service().get_city_storage_group_total(storage, resource_ids)


func _format_city_storage_group_details(storage: Dictionary, resource_ids: Array) -> String:
	return _ensure_city_detail_presentation_controller().format_city_storage_group_details(storage, resource_ids, RESOURCE_LABELS)


func _get_city_storage_amount(storage: Dictionary, resource_id: String) -> int:
	return _ensure_city_resource_service().get_city_storage_amount(storage, resource_id)


func _get_city_storage_status_label(total: int) -> String:
	return _ensure_city_detail_presentation_controller().get_city_storage_status_label(total)


func _refresh_warehouse_card() -> void:
	_ensure_hud_controller().refresh_warehouse(_build_warehouse_hud_rows())


func _build_warehouse_hud_rows() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var resource_stock := _get_player_national_resource_stock_mvp()
	for resource_id in RESOURCE_DISPLAY_ORDER:
		var resource_id_string := str(resource_id)
		var value := int(resource_stock.get(resource_id_string, 0))
		var capacity := int(WAREHOUSE_CAPACITY.get(resource_id_string, 0))
		var status := _get_resource_status_label(resource_id_string, value, capacity)
		rows.append({
			"resource_id": resource_id_string,
			"amount": "%d / %d" % [value, capacity],
			"status": status,
			"status_color": _get_resource_status_color(status),
		})
	return rows


func _format_warehouse_summary(_policy_id: String) -> String:
	var resource_stock := _get_player_national_resource_stock_mvp()
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
	var national_modifier_summary := _format_national_domestic_economy_modifier_summary_mvp()
	if not national_modifier_summary.is_empty():
		lines.append(national_modifier_summary)
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
	return EconomyCityHelpers.get_resource_status_label(value, max_value, WAREHOUSE_LOW_RATIO, WAREHOUSE_STABLE_RATIO)


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
	return EconomyCityHelpers.format_resource_costs(costs, resource_order, RESOURCE_LABELS)


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
	return UIFormatterHelpers.format_signed_int(value)


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
	if str(hero_data.get("side", "")) != _get_current_player_faction_id():
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
			if faction_id.is_empty() or faction_id == _get_current_player_faction_id():
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
		if not faction_id.is_empty() and faction_id != _get_current_player_faction_id():
			known[faction_id] = true
	for hero_id_variant in HeroDefinitionRegistryScript.HERO_DATA.keys():
		var hero_data := _get_hero_entry(str(hero_id_variant))
		var faction_id := _get_hero_faction_id_for_chancellor_seed(hero_data)
		if not faction_id.is_empty() and faction_id != _get_current_player_faction_id():
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
	if faction_id.is_empty() or faction_id == _get_current_player_faction_id() or hero_id.is_empty():
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
	for hero_id_variant in HeroDefinitionRegistryScript.HERO_DATA.keys():
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
	if chancellor_data.is_empty() or str(chancellor_data.get("side", "")) != _get_current_player_faction_id():
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
	return _ensure_city_administration_service().get_governor_policy_entry(policy_id)


func _get_city_policy_id(city_id: String, city_data: Dictionary) -> String:
	return _ensure_city_administration_service().get_city_policy_id(city_id, city_data, _city_policy_state)


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
	return UIFormatterHelpers.format_region_label(region_id, REGION_LABELS)


func _format_faction_label(owner_faction_id: String) -> String:
	return UIFormatterHelpers.format_faction_label(owner_faction_id, FACTION_LABELS)


func _format_city_type(city_id: String) -> String:
	return UIFormatterHelpers.format_city_type(city_id, CITY_TYPE_LABELS)


func _get_city_detail_status(city_marker: WorldMapCityMarker) -> String:
	if city_marker.owner_faction_id == _get_current_player_faction_id():
		return "아군 도시"
	if _has_player_neighbor(city_marker):
		return "아군 인접 적 도시"
	if not city_marker.owner_faction_id.is_empty():
		return "적 도시"
	return "월드맵 이식 중"


func _has_player_neighbor(city_marker: WorldMapCityMarker) -> bool:
	for neighbor_id in city_marker.neighbors:
		var neighbor_marker := _city_markers_by_id.get(neighbor_id) as WorldMapCityMarker
		if neighbor_marker != null and neighbor_marker.owner_faction_id == _get_current_player_faction_id():
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
	if not _contextual_worldmap_action_type.is_empty():
		var contextual_tab := UNIFIED_PANEL_TAB_TRADE if _contextual_worldmap_action_type == "trade" else UNIFIED_PANEL_TAB_DIPLOMACY_SPY
		if tab_id != contextual_tab:
			cancel_contextual_worldmap_action()
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
		if _contextual_worldmap_action_type == "diplomacy" and _selected_diplomacy_spy_tab != DIPLOMACY_SPY_TAB_DIPLOMACY:
			cancel_contextual_worldmap_action()
		elif _contextual_worldmap_action_type == "spy" and _selected_diplomacy_spy_tab != DIPLOMACY_SPY_TAB_SPY:
			cancel_contextual_worldmap_action()
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
	if _contextual_worldmap_action_type == "trade" and mode != TRADE_CONTROL_MODE_MANUAL:
		cancel_contextual_worldmap_action()
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
	return UIFormatterHelpers.get_city_detail_tab_label(tab_id, CITY_DETAIL_TAB_INTERNAL_TRADE, CITY_DETAIL_TAB_EXTERNAL_TRADE)


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
	_ensure_shared_ui_controller().set_panel_click_enabled(city_detail_panel, is_collapsed)
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
