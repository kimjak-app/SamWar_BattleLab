Warning: truncated output (original token count: 309460)
... 189263 bytes omitted ...

extends Node2D

signal contextual_worldmap_action_presentation_requested(action_type: String, action_id: String, target_city_id: String)
signal contextual_worldmap_action_resolved(action_type: String, result: Dictionary)

const HeroPortraitHelper := preload("res://scripts/worldmap_hero_portrait_helper.gd")
const HeroDefinitionRegistryScript := preload(
	"res://scripts/worldmap/hero_definition_registry.gd"
)
const PlayerAttackDeploymentPanelScript := preload("res://scripts/player_attack_deployment_panel.gd")
const GameSessionScript := preload("res://scripts/game_session.gd")
const DomesticTechHelperLib := preload("res://scripts/worldmap/domestic_tech/domestic_tech_helpers.gd")
const EconomyCityHelpers := preload("res://scripts/worldmap/economy_city/economy_city_helpers.gd")
const DefenseBattleHelpers := preload("res://scripts/worldmap/defense_battle/defense_battle_helpers.gd")
const DiplomacySpyHelpers := preload("res://scripts/worldmap/diplomacy_spy/diplomacy_spy_helpers.gd")
const UIFormatterHelpers := preload("res://scripts/worldmap/ui_formatter/ui_formatter_helpers.gd")
const T03AutoBattleResolverScript := preload("res://scripts/worldmap/t03/auto_battle_resolver.gd")
const TurnOutcomeRulesScript := preload("res://scripts/worldmap/t04_t05/turn_outcome_rules.gd")

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
const DOMESTIC_TECH_RESEARCH_KEY := "research"
const DOMESTIC_TECH_RESEARCH_ACTIVE_KEY := "active"
const DOMESTIC_TECH_COMPLETION_NATIONAL_VIDEO_PATH := "res://assets/ui/research/videos/research_completion_national_theora_q8_1920x1080.ogv"
const DOMESTIC_TECH_COMPLETION_CITY_VIDEO_PATH := "res://assets/ui/research/videos/research_completion_city_theora_q8_1920x1080.ogv"
const DOMESTIC_TECH_COMPLETION_VIDEO_FALLBACK_DURATION_SEC := 6.75
const DOMESTIC_TECH_COMPLETION_VIDEO_PANEL_WIDTH_RATIO := 0.88
const DOMESTIC_TECH_COMPLETION_VIDEO_PANEL_HEIGHT_RATIO := 9.0 / 16.0
const DOMESTIC_TECH_COMPLETION_VIDEO_PANEL_MAX_HEIGHT_RATIO := 0.60
const DOMESTIC_TECH_UI64_ICON_ROOT := "res://assets/ui/tech_icons_ui64/"
const DOMESTIC_TECH_UI64_ICON_FILENAME_MAP := {
	"agri_tool_upgrade": "tech_agri_tool_upgrade.png",
	"agri_irrigation": "tech_agri_irrigation.png",
	"agri_double_cropping": "tech_agri_double_cropping.png",
	"agri_granary_zone": "tech_agri_granary_zone.png",
	"agri_reservoir": "tech_agri_reservoir.png",
	"agri_pasture": "tech_agri_pasture.png",
	"agri_ranch": "tech_agri_ranch.png",
	"agri_warhorse_breeding": "tech_agri_warhorse_breeding.png",
	"fish_village": "tech_fish_village.png",
	"fish_coastal_fishing": "tech_fish_coastal_fishing.png",
	"fish_fleet": "tech_fish_fleet.png",
	"fish_deep_sea_fishing": "tech_fish_deep_sea_fishing.png",
	"fish_dried_supply_base": "tech_fish_dried_supply_base.png",
	"fish_salt_field": "tech_fish_salt_field.png",
	"fish_salt_warehouse": "tech_fish_salt_warehouse.png",
	"commerce_street_market": "tech_commerce_street_market.png",
	"commerce_permanent_market": "tech_commerce_permanent_market.png",
	"commerce_grand_market": "tech_commerce_grand_market.png",
	"commerce_merchant_guild": "tech_commerce_merchant_guild.png",
	"commerce_mint": "tech_commerce_mint.png",
	"commerce_port": "tech_naval_port.png",
	"commerce_shipyard": "tech_naval_shipyard.png",
	"commerce_trade_port": "tech_commerce_trade_port.png",
	"commerce_silk_road": "tech_commerce_silk_road.png",
	"mil_barracks": "tech_mil_barracks.png",
	"mil_infantry_training": "tech_mil_infantry_training.png",
	"mil_elite_infantry": "tech_mil_elite_infantry.png",
	"mil_heavy_infantry": "tech_mil_heavy_infantry.png",
	"mil_archer_training": "tech_mil_archer_training.png",
	"mil_elite_archer": "tech_mil_elite_archer.png",
	"mil_singijeon": "tech_mil_singijeon.png",
	"mil_cavalry_training": "tech_mil_cavalry_training.png",
	"mil_light_cavalry": "tech_mil_light_cavalry.png",
	"mil_heavy_cavalry": "tech_mil_heavy_cavalry.png",
	"mil_iron_cavalry": "tech_mil_iron_cavalry.png",
	"mil_cavalry_charge_tactics": "tech_mil_cavalry_charge_tactics.png",
	"naval_training": "tech_naval_training.png",
	"naval_warship_building": "tech_naval_warship_building.png",
	"naval_panokseon": "tech_naval_panokseon.png",
	"naval_turtle_ship": "tech_naval_turtle_ship.png",
	"naval_crane_wing_formation": "tech_naval_crane_wing_formation.png",
	"naval_fire_ship": "tech_naval_fire_ship.png",
	"naval_cannon_mount": "tech_naval_cannon_mount.png",
	"mil_wall_upgrade": "tech_mil_wall_upgrade.png",
	"mil_moat": "tech_mil_moat.png",
	"mil_double_moat": "tech_mil_double_moat.png",
	"mil_watchtower": "tech_mil_watchtower.png",
	"mil_beacon": "tech_mil_beacon.png",
	"mil_beacon_network": "tech_mil_beacon_network.png",
	"mil_iron_gate": "tech_mil_iron_gate.png",
	"mil_iron_fortress": "tech_mil_iron_fortress.png",
	"mil_siege_unit": "tech_mil_siege_unit.png",
	"mil_siege_engine": "tech_mil_siege_engine.png",
	"nation_foundation": "tech_nation_foundation.png",
	"nation_law_reform": "tech_nation_law_reform.png",
	"nation_bureaucracy": "tech_nation_bureaucracy.png",
	"nation_local_administration": "tech_nation_local_administration.png",
	"nation_centralization": "tech_nation_centralization.png",
	"nation_inspection_system": "tech_nation_inspection_system.png",
	"nation_anti_corruption": "tech_nation_anti_corruption.png",
	"nation_household_registry": "tech_nation_household_registry.png",
	"nation_population_census": "tech_nation_population_census.png",
	"nation_population_policy": "tech_nation_population_policy.png",
	"nation_tax_reform": "tech_nation_tax_reform.png",
	"nation_equal_tax": "tech_nation_equal_tax.png",
	"nation_currency_unification": "tech_nation_currency_unification.png",
	"nation_national_economy": "tech_nation_national_economy.png",
	"nation_monopoly_system": "tech_nation_monopoly_system.png",
	"nation_national_monopoly": "tech_nation_national_monopoly.png",
	"nation_conscription": "tech_nation_conscription.png",
	"nation_military_training_order": "tech_nation_military_training_order.png",
	"nation_military_reform": "tech_nation_military_reform.png",
	"nation_standing_army": "tech_nation_standing_army.png",
	"nation_logistics_system": "tech_nation_logistics_system.png",
	"nation_expedition_system": "tech_nation_expedition_system.png",
	"nation_weapon_standardization": "tech_nation_weapon_standardization.png",
	"nation_weapon_factory": "tech_nation_weapon_factory.png",
	"nation_envoy": "tech_nation_envoy.png",
	"nation_diplomacy_system": "tech_nation_diplomacy_system.png",
	"nation_alliance_system": "tech_nation_alliance_system.png",
	"nation_world_diplomacy": "tech_nation_world_diplomacy.png",
	"nation_intelligence_system": "tech_nation_intelligence_system.png",
	"nation_intelligence_org": "tech_nation_intelligence_org.png",
	"nation_tribute_system": "tech_nation_tribute_system.png",
	"nation_tribute_network": "tech_nation_tribute_network.png",
}
const DOMESTIC_TECH_CATEGORY_AGRI := "agri"
const DOMESTIC_TECH_CATEGORY_FISH := "fish"
const DOMESTIC_TECH_CATEGORY_COMMERCE := "commerce"
const DOMESTIC_TECH_CATEGORY_MILITARY := "military"
const DOMESTIC_TECH_CATEGORY_NATION_ADMIN := "nation_admin"
const DOMESTIC_TECH_CATEGORY_NATION_ECONOMY := "nation_economy"
const DOMESTIC_TECH_CATEGORY_NATION_MILITARY := "nation_military"
const DOMESTIC_TECH_CATEGORY_NATION_DIPLOMACY := "nation_diplomacy"
const DOMESTIC_TECH_ECONOMY_SAFE_CATEGORIES_MVP := [
	DOMESTIC_TECH_CATEGORY_AGRI,
	DOMESTIC_TECH_CATEGORY_FISH,
	DOMESTIC_TECH_CATEGORY_COMMERCE,
]
const DOMESTIC_TECH_VIEW_COMPLETED := "completed"
const DOMESTIC_TECH_VIEW_AVAILABLE := "available"
const DOMESTIC_TECH_VIEW_LOCKED := "locked"
const DOMESTIC_TECH_VIEW_SPECIAL_LOCKED := "special_locked"
const DOMESTIC_TECH_VIEW_RESEARCHING := "researching"
const DOMESTIC_TECH_TREE_OVERLAY_MARGIN := 22.0
const DOMESTIC_TECH_TREE_OVERLAY_LAYER := 60
const DOMESTIC_TECH_TREE_REGION_RATIO := 0.40
const DOMESTIC_TECH_DETAIL_REGION_RATIO := 0.60
const DOMESTIC_TECH_BODY_GAP := 10.0
const DOMESTIC_TECH_DETAIL_WATERMARK := preload("res://assets/ui/worldmap/tech_tree/wm_techtree_detail_watermark.png")
const DOMESTIC_TECH_DETAIL_WATERMARK_ALPHA := 0.25
const DOMESTIC_TECH_DETAIL_WATERMARK_SIZE := Vector2(240.0, 240.0)
const DOMESTIC_TECH_TREE_NODE_WIDTH := 214.0
const DOMESTIC_TECH_TREE_ICON_SIZE := 42.0
const DOMESTIC_TECH_GRAPH_COMPACT_ICON_SIZE := 64.0
const DOMESTIC_TECH_GRAPH_CATEGORY_TOP_MARGIN := 14
const DOMESTIC_TECH_GRAPH_CATEGORY_BOTTOM_MARGIN := 34
const DOMESTIC_TECH_GRAPH_NODE_WIDTH := 192.0
const DOMESTIC_TECH_GRAPH_NODE_HEIGHT := 84.0
const DOMESTIC_TECH_GRAPH_NODE_SIZE := Vector2(DOMESTIC_TECH_GRAPH_NODE_WIDTH, DOMESTIC_TECH_GRAPH_NODE_HEIGHT)
const DOMESTIC_TECH_GRAPH_TIER_SPACING := 238.0
const DOMESTIC_TECH_GRAPH_BRANCH_SPACING := 138.0
const DOMESTIC_TECH_GRAPH_BRANCH_STACK_SPACING := 106.0
const DOMESTIC_TECH_GRAPH_MARGIN := Vector2(110.0, 48.0)
const DOMESTIC_TECH_GRAPH_LINE_WIDTH := 3.0
const DOMESTIC_TECH_ECONOMY_SAFE_SET_MVP := {
	"agri_tool_upgrade": {"food_percent": 0.04},
	"agri_irrigation": {"food_percent": 0.07},
	"agri_reservoir": {"food_percent": 0.10},
	"agri_double_cropping": {"food_percent": 0.14},
	"agri_granary_zone": {"food_flat": 60},
	"fish_village": {"food_flat": 18},
	"fish_coastal_fishing": {"food_percent": 0.05},
	"fish_fleet": {"food_percent": 0.08},
	"fish_deep_sea_fishing": {"food_percent": 0.12},
	"fish_dried_supply_base": {"supply_flat": 40},
	"commerce_street_market": {"gold_flat": 15},
	"commerce_permanent_market": {"gold_percent": 0.06},
	"commerce_merchant_guild": {"gold_percent": 0.08},
	"commerce_mint": {"gold_flat": 80},
	"commerce_grand_market": {"gold_percent": 0.11},
}
const DOMESTIC_TECH_MILITARY_DEFENSE_SAFE_BRANCHES_MVP := ["infantry", "archer", "cavalry", "defense"]
const DOMESTIC_TECH_MILITARY_DEFENSE_SAFE_SET_MVP := {
	"mil_barracks": {"recruit_capacity_flat": 80},
	"mil_infantry_training": {"infantry_training_percent": 0.04},
	"mil_elite_infantry": {"infantry_training_percent": 0.07},
	"mil_heavy_infantry": {"infantry_training_percent": 0.10},
	"mil_archer_training": {"archer_training_percent": 0.04},
	"mil_elite_archer": {"archer_training_percent": 0.07},
	"mil_singijeon": {"archer_training_percent": 0.08},
	"mil_cavalry_training": {"cavalry_training_percent": 0.04},
	"mil_light_cavalry": {"cavalry_training_percent": 0.06},
	"mil_heavy_cavalry": {"cavalry_training_percent": 0.08},
	"mil_iron_cavalry": {"cavalry_training_percent": 0.10},
	"mil_cavalry_charge_tactics": {"cavalry_charge_percent": 0.08},
	"mil_wall_upgrade": {"defense_flat": 35},
	"mil_moat": {"defense_percent": 0.05},
	"mil_double_moat": {"defense_percent": 0.08},
	"mil_watchtower": {"defense_flat": 30},
	"mil_beacon": {"defense_flat": 20},
	"mil_beacon_network": {"defense_percent": 0.06},
	"mil_iron_gate": {"defense_flat": 70},
	"mil_iron_fortress": {"defense_percent": 0.14},
}
const DOMESTIC_TECH_NATIONAL_BATTLE_SAFE_SET_MVP := {
	"nation_military_training_order": {"global_attack_percent": 0.03, "global_defense_percent": 0.03},
	"nation_military_reform": {"global_attack_percent": 0.04, "global_defense_percent": 0.04},
	"nation_standing_army": {"global_attack_percent": 0.03, "global_defense_percent": 0.03},
	"nation_logistics_system": {"logistics_percent": 0.05, "global_defense_percent": 0.02},
	"nation_expedition_system": {"logistics_percent": 0.05, "global_attack_percent": 0.02},
	"nation_weapon_standardization": {"global_attack_percent": 0.03},
	"nation_weapon_factory": {"global_attack_percent": 0.03},
}
const DOMESTIC_TECH_NATIONAL_POLICY_SAFE_SET_MVP := {
	"nation_law_reform": {"law_order_flat": 5},
	"nation_bureaucracy": {"admin_efficiency_percent": 0.06},
	"nation_centralization": {"admin_efficiency_percent": 0.12},
	"nation_tax_reform": {"tax_gold_percent": 0.04},
	"nation_conscription": {"recruit_capacity_percent": 0.04},
	"nation_logistics_system": {"logistics_supply_percent": 0.06},
	"nation_population_policy": {"population_growth_percent": 0.10},
	"nation_foundation": {"storage_flat": 120},
	"nation_national_monopoly": {"tax_gold_percent": 0.08},
}
const DOMESTIC_TECH_NAVAL_SIEGE_SAFE_BRANCHES_MVP := ["sea_trade", "naval", "siege"]
const DOMESTIC_TECH_NAVAL_SIEGE_SAFE_SET_MVP := {
	"commerce_port": {"naval_support_percent": 0.03},
	"commerce_shipyard": {"shipyard_capacity_flat": 1},
	"commerce_trade_port": {"naval_supply_percent": 0.05},
	"fish_fleet": {"naval_supply_percent": 0.03},
	"fish_dried_supply_base": {"naval_supply_percent": 0.05},
	"naval_training": {"naval_training_percent": 0.04},
	"naval_warship_building": {"shipyard_capacity_flat": 1, "ship_maintenance_percent": 0.04},
	"naval_panokseon": {"naval_training_percent": 0.08},
	"naval_turtle_ship": {"naval_training_percent": 0.14},
	"naval_crane_wing_formation": {"naval_training_percent": 0.12},
	"naval_fire_ship": {"naval_supply_percent": 0.08},
	"naval_cannon_mount": {"ship_maintenance_percent": 0.08},
	"mil_siege_unit": {"siege_preparation_flat": 15, "siege_training_percent": 0.04},
	"mil_siege_engine": {"siege_engineering_percent": 0.08},
}
const DOMESTIC_TECH_DIPLOMACY_SPY_SAFE_SET_MVP := {
	"nation_envoy": {"diplomacy_influence_flat": 8},
	"nation_diplomacy_system": {"diplomacy_preparation_percent": 0.05},
	"nation_tribute_system": {"tribute_readiness_percent": 0.05},
	"nation_tribute_network": {"tribute_readiness_percent": 0.08},
	"nation_world_diplomacy": {"world_diplomacy_display_percent": 0.12},
	"nation_centralization": {"diplomacy_preparation_percent": 0.02},
	"nation_bureaucracy": {"diplomacy_preparation_percent": 0.02, "spy_preparation_percent": 0.02},
	"nation_intelligence_system": {"spy_network_flat": 8},
	"nation_intelligence_org": {"spy_preparation_percent": 0.08},
	"nation_inspection_system": {"counter_intel_display_percent": 0.05},
}
const DOMESTIC_TECH_CITY_SPY_INTEL_SAFE_SET_MVP := {}
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
const PLAYER_ATTACK_SUPPLY_GOLD_RESOURCE_ID := "gold"
const PLAYER_ATTACK_SUPPLY_SALT_RESOURCE_ID := "salt"
const PLAYER_ATTACK_WOUNDED_QUEUE_TURNS := 3
const BATTLE_RESULT_HERO_ID_COMPATIBILITY := {
	"yi_sunsin": "yi_sun_sin",
	"jeong_dojeon": "jeong_do_jeon",
	"gim_yusin": "kim_yu_sin",
}
const T02_INITIAL_SALT_PER_RESOURCE_RATING := 20

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
var _contextual_worldmap_action_type := ""
var _contextual_worldmap_action_target_city_id := ""
var _contextual_worldmap_action_source_city_id := ""
var _contextual_worldmap_action_pending := false
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
var _worldmap_help_modal: PanelContainer = null
var _worldmap_help_title_label: Label = null
var _worldmap_help_body_label: Label = null
var _worldmap_help_close_button: Button = null
var _left_national_loyalty_help_button: Button = null
var _domestic_tech_tree_button_mvp: Button = null
var _tech_tree_overlay_canvas_mvp: CanvasLayer = null
var _tech_tree_overlay_mvp: PanelContainer = null
var _tech_tree_content_root_mvp: VBoxContainer = null
var _tech_tree_hidden_ui_state_mvp: Dictionary = {}
var _selected_domestic_tech_id_mvp := ""
var _selected_domestic_tech_city_id_mvp := ""
var _domestic_tech_compact_node_refs_mvp: Dictionary = {}
var _domestic_tech_icon_texture_cache_mvp: Dictionary = {}
var _domestic_tech_detail_inspector_label_mvp: Label = null
var _domestic_tech_research_action_button_mvp: Button = null
var _domestic_tech_research_action_hint_label_mvp: Label = null
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
var _domestic_tech_completion_presentation_queue: Array[Dictionary] = []
var _domestic_tech_completion_presentation_active := false
var _domestic_tech_completion_video_completion_handled := false
var _domestic_tech_completion_current_item: Dictionary = {}
var _domestic_tech_completion_layer: CanvasLayer = null
var _domestic_tech_completion_root: Control = null
var _domestic_tech_completion_backdrop: ColorRect = null
var _domestic_tech_completion_video_player: VideoStreamPlayer = null
var _domestic_tech_completion_card: PanelContainer = null
var _domestic_tech_completion_icon: TextureRect = null
var _domestic_tech_completion_scope_label: Label = null
var _domestic_tech_completion_title_label: Label = null
var _domestic_tech_completion_message_label: Label = null
var _domestic_tech_completion_effect_label: RichTextLabel = null
var _domestic_tech_completion_confirm_button: Button = null
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
var _t03_active_report: Dictionary = {}


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
	_configure_camera()
	_update_camera_debug_label()
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
	if _worldmap_battle_entry_handoff_in_progress:
		_update_camera_debug_label()
		return
	_handle_keyboard_pan(delta)
	_update_camera_debug_label()


func _input(event: InputEvent) -> void:
	if _worldmap_battle_entry_handoff_in_progress:
		# A skip event can complete the handoff synchronously and replace this scene.
		# Consume it while this WorldMap viewport is still alive, before that transition.
		var handoff_viewport := get_viewport()
		if handoff_viewport != null:
			handoff_viewport.set_input_as_handled()
		if _is_worldmap_battle_entry_handoff_skip_event(event):
			_skip_worldmap_battle_entry_camera_handoff()
		return

	if _worldmap_help_modal != null and _worldmap_help_modal.visible and event.is_action_pressed("ui_cancel"):
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
	_register_hud_panel_drag(left_world_status_panel, [left_world_status_eyebrow_label, calendar_label])


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
	var requested_position := Vector2(
		maxf(WORLD_UI_LEFT_MARGIN, viewport_size.x - WORLD_UI_LEFT_MARGIN - panel_size.x),
		WORLD_UI_TOP_MARGIN
	)
	if not _request_hud_panel_position_mvp(city_info_panel_control, requested_position):
		city_info_panel_control.position = requested_position
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
	if _request_hud_panel_position_mvp(panel, clamped_global_position, true):
		return
	panel.global_position = clamped_global_position


func _request_hud_panel_position_mvp(panel: Control, requested_position: Vector2, is_global: bool = false) -> bool:
	if panel == null:
		return false
	var hud_position_owner := get_node_or_null("HudPositionOwner")
	if hud_position_owner == null:
		return false
	var method_name := "request_hud_panel_global_position" if is_global else "request_hud_panel_position"
	if not hud_position_owner.has_method(method_name):
		return false
	return bool(hud_position_owner.call(method_name, panel, requested_position))


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
	return {
		"ok": true,
		"action_type": normalized_type,
		"target_city_id": target_city_id,
		"source_city_id": _contextual_worldmap_action_source_city_id,
		"message": "행동을 선택한 뒤 실행하면 영상과 결과가 표시됩니다.",
	}


func cancel_contextual_worldmap_action() -> void:
	_contextual_worldmap_action_type = ""
	_contextual_worldmap_action_target_city_id = ""
	_contextual_worldmap_action_source_city_id = ""
	_contextual_worldmap_action_pending = false


func complete_contextual_worldmap_action(action_type: String, action_id: String, target_city_id: String) -> Dictionary:
	if not _contextual_worldmap_action_pending:
		return {"success": false, "message": "실행 대기 중인 도시 행동이 없습니다."}
	if action_type != _contextual_worldmap_action_type or target_city_id != _contextual_worldmap_action_target_city_id:
		return {"success": false, "message": "도시 행동 대상이 변경되었습니다."}

	var result: Dictionary = {}
	match action_type:
		"diplomacy":
			result = _apply_diplomacy_action(action_id, target_city_id)
			_save_management_status = str(result.get("message", "외교 행동 처리"))
		"spy":
			result = _apply_spy_action(action_id, target_city_id)
		"trade":
			var order: Dictionary = _manual_trade_orders.get(_contextual_worldmap_action_source_city_id, {})
			result = _execute_external_manual_trade_order(order)
			_player_state["last_external_manual_trade_execution_result"] = result.duplicate(true)
			if bool(result.get("ok", false)):
				_manual_trade_orders.erase(_contextual_worldmap_action_source_city_id)
		_:
			result = {"success": false, "message": "지원하지 않는 도시 행동입니다."}

	cancel_contextual_worldmap_action()
	_refresh_city_hud_data_bindings()
	_refresh_left_world_status_panel()
	_refresh_unified_panel_content()
	_queue_unified_city_panel_resize()
	contextual_worldmap_action_resolved.emit(action_type, result)
	return result


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
	city_state["governor_id"] = normaliz…212153 tokens truncated…tax_delta": int(drift.get("tax_delta", 0)),
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
	var result: Array[String] = []
	var capital_city_id := str(_player_state.get("capital_city_id", _player_state.get("origin_city_id", "")))
	if not capital_city_id.is_empty() and _get_city_owner_id_for_battle_context(capital_city_id) == _get_current_player_faction_id():
		result.append(capital_city_id)
	var raw_owned_city_ids: Variant = _player_state.get("owned_city_ids", [])
	var remaining: Array[String] = []
	if raw_owned_city_ids is Array:
		for city_id_variant in raw_owned_city_ids:
			var city_id := str(city_id_variant)
			if city_id.is_empty() or city_id == capital_city_id or _get_city_owner_id_for_battle_context(city_id) != _get_current_player_faction_id():
				continue
			if not remaining.has(city_id):
				remaining.append(city_id)
	remaining.sort()
	result.append_array(remaining)
	return result


func _apply_resource_delta_to_city_stock_mvp(city_id: String, delta: Dictionary) -> Dictionary:
	var applied := {}
	var city_data := _get_mutable_city_runtime_state(city_id)
	if city_data.is_empty():
		return applied
	var stock: Dictionary = city_data.get("resource_stock", {}).duplicate(true)
	for resource_id in RESOURCE_DISPLAY_ORDER:
		var resource_key := str(resource_id)
		var before := maxi(0, int(stock.get(resource_key, 0)))
		var after := maxi(0, before + int(delta.get(resource_key, 0)))
		stock[resource_key] = after
		applied[resource_key] = after - before
	city_data["resource_stock"] = stock
	_city_runtime_states[city_id] = city_data
	return applied


func _apply_player_resource_delta_capital_first_mvp(resource_id: String, requested_delta: int) -> int:
	if requested_delta == 0:
		return 0
	var city_ids := _get_ordered_player_resource_city_ids_mvp()
	if city_ids.is_empty():
		return 0
	if requested_delta > 0:
		var target_city_id := city_ids[0]
		var positive_delta := {}
		positive_delta[resource_id] = requested_delta
		var applied := _apply_resource_delta_to_city_stock_mvp(target_city_id, positive_delta)
		return int(applied.get(resource_id, 0))
	var remaining_cost := absi(requested_delta)
	var paid := 0
	for city_id in city_ids:
		if remaining_cost <= 0:
			break
		var city_data := _get_mutable_city_runtime_state(city_id)
		var stock: Dictionary = city_data.get("resource_stock", {}).duplicate(true)
		var available := maxi(0, int(stock.get(resource_id, 0)))
		var deduction := mini(available, remaining_cost)
		if deduction <= 0:
			continue
		stock[resource_id] = available - deduction
		city_data["resource_stock"] = stock
		_city_runtime_states[city_id] = city_data
		remaining_cost -= deduction
		paid += deduction
	return -paid


func _sync_player_resource_compatibility_from_city_stock_mvp() -> Dictionary:
	var aggregate := {}
	for resource_id in RESOURCE_DISPLAY_ORDER:
		aggregate[str(resource_id)] = 0
	for city_id in _get_ordered_player_resource_city_ids_mvp():
		var city_data := _get_city_hud_entry(city_id)
		var stock: Variant = city_data.get("resource_stock", {})
		if not stock is Dictionary:
			continue
		for resource_id in RESOURCE_DISPLAY_ORDER:
			var resource_key := str(resource_id)
			aggregate[resource_key] = int(aggregate.get(resource_key, 0)) + maxi(0, int((stock as Dictionary).get(resource_key, 0)))
	_player_state["resource_stock"] = aggregate.duplicate(true)
	return aggregate


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
	if city_info_panel.has_method("set_player_faction_id"):
		city_info_panel.call("set_player_faction_id", _get_current_player_faction_id())
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
	return EconomyCityHelpers.get_city_storage_amount(storage, resource_id)


func _get_city_storage_status_label(total: int) -> String:
	return EconomyCityHelpers.get_city_storage_status_label(total)


func _refresh_warehouse_card() -> void:
	if _warehouse_card == null:
		return
	_warehouse_card.visible = true
	var resource_stock := _get_player_national_resource_stock_mvp()
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
