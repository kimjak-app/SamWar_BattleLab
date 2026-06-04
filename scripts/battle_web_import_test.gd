extends Node2D

const BattleRangeOverlayTileScript := preload("res://scripts/battle_range_overlay_tile.gd")
const BattleFacingArrowTileButtonScript := preload("res://scripts/battle_facing_arrow_tile_button.gd")
const DEMO_DAMAGE := 12.0
const ENEMY_DEMO_DAMAGE := 8.0
const ALLY_DEMO_HP := 94.0
const ENEMY_DEMO_HP := 100.0
const ATTACK_LUNGE_DISTANCE := 42.0
const HP_BAR_OFFSET := Vector2(-48.0, 38.0)
const TROOP_LABEL_OFFSET := Vector2(-48.0, 50.0)
const SHADOW_OFFSET := Vector2(0.0, 30.0)
const ALLY_VISUAL_ANCHOR_OFFSET := Vector2(0.0, 0.0)
const ENEMY_VISUAL_ANCHOR_OFFSET := Vector2(0.0, -8.0)
const IDLE_SCALE_MULTIPLIER := 1.035
const IDLE_DURATION := 1.15
const ACTIVE_ALLY_TURN_PULSE_SCALE := 1.5
const ACTIVE_ALLY_TURN_PULSE_UP_DURATION := 0.16
const ACTIVE_ALLY_TURN_PULSE_DOWN_DURATION := 0.26
const ENEMY_GUARD_STEP_DISTANCE := 18.0
const MOVE_HIGHLIGHT_SIZE := Vector2(68.0, 56.0)
const MOVE_TARGET_VALID_COLOR := Color(0.45, 1.0, 0.55, 1.0)
const MOVE_TARGET_INVALID_COLOR := Color(1.0, 0.35, 0.35, 1.0)
const MOVE_HIGHLIGHT_VALID_COLOR := Color(0.172549, 0.623529, 1.0, 0.227451)
const MOVE_HIGHLIGHT_INVALID_COLOR := Color(1.0, 0.2, 0.2, 0.28)
const MOVE_RANGE_OVERLAY_COLOR := Color(0.427, 0.561, 0.769, 0.22)
const MOVE_RANGE_OVERLAY_OUTLINE_COLOR := Color(0.565, 0.694, 0.902, 0.88)
const MOVE_RANGE_OVERLAY_HIGHLIGHT_COLOR := Color(0.720, 0.840, 1.0, 0.28)
const ATTACK_RANGE_OVERLAY_COLOR := Color(0.950, 0.280, 0.350, 0.24)
const ATTACK_RANGE_OVERLAY_OUTLINE_COLOR := Color(1.0, 0.540, 0.380, 0.88)
const ATTACK_RANGE_OVERLAY_HIGHLIGHT_COLOR := Color(1.0, 0.710, 0.640, 0.30)
const UNIQUE_SKILL_RANGE_OVERLAY_COLOR := Color(0.580, 0.340, 0.950, 0.22)
const UNIQUE_SKILL_RANGE_OVERLAY_OUTLINE_COLOR := Color(0.800, 0.620, 1.0, 0.84)
const UNIQUE_SKILL_RANGE_OVERLAY_HIGHLIGHT_COLOR := Color(0.900, 0.780, 1.0, 0.28)
const UNIQUE_SKILL_TARGET_OVERLAY_COLOR := Color(1.0, 0.680, 0.160, 0.38)
const UNIQUE_SKILL_TARGET_OVERLAY_OUTLINE_COLOR := Color(1.0, 0.820, 0.280, 0.90)
const UNIQUE_SKILL_TARGET_OVERLAY_HIGHLIGHT_COLOR := Color(1.0, 0.920, 0.560, 0.30)
const UNIQUE_SKILL_TARGET_MARKER_SCALE := 0.78
const UNIQUE_SKILL_AUTO_PREVIEW_DURATION := 0.42
const UNIQUE_SKILL_MANUAL_PREVIEW_DURATION := 0.42
const MOVE_RANGE_OVERLAY_VISUAL_INSET := Vector2(32.0, 0.0)
const RANGE_OVERLAY_CELL_INSET_RATIO := 0.08
const RANGE_OVERLAY_CELL_APPEAR_DURATION := 0.16
const RANGE_OVERLAY_CELL_SETTLE_DURATION := 0.08
const RANGE_OVERLAY_CELL_STAGGER := 0.06
const RANGE_OVERLAY_CELL_BASE_START_SCALE := 0.74
const RANGE_OVERLAY_CELL_BASE_POP_SCALE := 1.14
const RANGE_OVERLAY_CELL_DISTANCE_SCALE_STEP := 0.02
const FLOATING_COMMAND_PANEL_VIEWPORT_MARGIN := 12.0
const FLOATING_COMMAND_PANEL_ANCHOR_GAP := 22.0
const FLOATING_COMMAND_PANEL_GRID_AVOID_PADDING := 10.0
const FLOATING_COMMAND_PANEL_DISTANCE_SCORE_WEIGHT := 8.0
const FLOATING_COMMAND_PANEL_FAR_FALLBACK_SCORE := 1000000.0
const FLOATING_COMMAND_PANEL_NEAR_CANDIDATE_COUNT := 8
const SHOW_CELL_SIZE_VISUAL_GUIDE := false
const SHOW_LOGICAL_GRID_14X8_GUIDE := false
const MELEE_ADJACENT_QA_MODE := false
const MELEE_QA_ENEMY_OFFSET := Vector2i(1, 0)
const PHASE_ALLY_TURN := "ally_turn"
const PHASE_ENEMY_TURN := "enemy_turn"
const PHASE_RESOLVING := "resolving"
const PHASE_FACING_SELECT := "facing_select"
const PHASE_ATTACK_SELECT := "attack_select"
const PHASE_UNIQUE_SKILL_TARGET_SELECT := "unique_skill_target_select"
const PHASE_STRATEGY_SELECT := "strategy"
const STRATEGY_ID := "strategy"
const STRATEGY_NAME := "책략"
const STRATEGY_BASE_SUCCESS_RATE := 0.55
const STRATEGY_MIN_SUCCESS_RATE := 0.25
const STRATEGY_MAX_SUCCESS_RATE := 0.90
const STRATEGY_BASIC_INTELLIGENCE := 80
const STRATEGY_ADVANCED_INTELLIGENCE := 90
const STRATEGY_MASTER_INTELLIGENCE := 95
const STRATEGY_RANGE_OVERLAY_COLOR := Color(0.100, 0.720, 0.780, 0.22)
const STRATEGY_RANGE_OVERLAY_OUTLINE_COLOR := Color(0.460, 0.920, 0.950, 0.84)
const STRATEGY_RANGE_OVERLAY_HIGHLIGHT_COLOR := Color(0.700, 1.0, 1.0, 0.28)
const STRATEGY_TARGET_OVERLAY_COLOR := Color(0.300, 0.950, 0.960, 0.42)
const STRATEGY_TARGET_OVERLAY_OUTLINE_COLOR := Color(0.680, 1.0, 1.0, 0.88)
const STRATEGY_TARGET_OVERLAY_HIGHLIGHT_COLOR := Color(0.860, 1.0, 1.0, 0.30)
const STRATEGY_TARGET_MARKER_SCALE := 0.74
const STRATEGY_EFFECT_COLOR := Color(0.34, 1.0, 0.78, 1.0)
const STRATEGY_FAIL_COLOR := Color(1.0, 0.24, 0.36, 1.0)
const STRATEGY_CAST_COLOR := Color(1.0, 0.86, 0.26, 1.0)
const STRATEGY_SHAKE_ATTACK_MULTIPLIER := 0.9
const STRATEGY_SHAKE_DEFENSE_DAMAGE_MULTIPLIER := 1.1
const DEFEND_DAMAGE_MULTIPLIER := 0.62
const DEFEND_WOUNDED_RECOVERY_RATE := 0.10
const WOUNDED_ATTACK_DAMAGE_MULTIPLIER := 0.75
const WOUNDED_DEFENSE_INCOMING_DAMAGE_MULTIPLIER := 1.20
const WOUNDED_SKILL_EFFECT_MULTIPLIER := 0.70
const STATUS_BADGE_COLOR := Color(0.62, 0.82, 0.96, 0.8)
const STATUS_BADGE_OUTLINE_COLOR := Color(0.02, 0.03, 0.04, 0.62)
const STATUS_BADGE_DEFENSE_COLOR := Color(0.52, 0.70, 0.90, 0.82)
const STATUS_BADGE_ATTACK_UP_COLOR := Color(1.0, 0.70, 0.28, 0.84)
const STATUS_BADGE_ATTACK_DOWN_COLOR := Color(0.92, 0.36, 0.26, 0.82)
const STATUS_BADGE_DEFENSE_DOWN_COLOR := Color(0.66, 0.58, 0.78, 0.82)
const STATUS_BADGE_CONFUSION_COLOR := Color(0.48, 0.92, 1.0, 0.82)
const STATUS_BADGE_SHAKE_COLOR := Color(1.0, 0.76, 0.28, 0.82)
const STATUS_BADGE_WIDTH := 34.0
const STATUS_BADGE_HEIGHT := 36.0
const STATUS_BADGE_GAP := 2.0
const STATUS_BADGE_ARROW_GAP := 2.0
const STATUS_BADGE_FACING_ARROW_APPROX_WIDTH := 24.0
const STATUS_BADGE_FACING_ARROW_APPROX_HEIGHT := 28.0
const STATUS_BADGE_ARROW_Y_NUDGE := 2.0
const COMBAT_CAMERA_FOCUS_ENABLED := true
const COMBAT_CAMERA_FOCUS_DURATION := 0.24
const COMBAT_CAMERA_CLAMP_PADDING := 180.0
const DEFEND_HEAL_TEXT_COLOR := Color(0.62, 1.0, 0.58, 0.94)
const FORMATION_STATUS_TEXT_COLOR := Color(0.74, 0.86, 0.94, 0.85)
const FORMATION_STATUS_OUTLINE_COLOR := Color(0.02, 0.03, 0.04, 0.62)
const STATUS_CONFUSION := "confusion"
const STATUS_SHAKE := "shake"
const AUTO_BATTLE_MIN_MAX_STEPS := 80
const AUTO_BATTLE_STEP_BUDGET_PER_DEPLOYED_UNIT := 16
const AUTO_BATTLE_ABSOLUTE_MAX_STEPS := 200
const MAX_BATTLE_LOG_LINES := 4
const ALLY_FORMATION_GUIDE_SLOT_IDS := [
	"ally_main_01",
	"ally_main_02",
	"ally_main_03",
	"ally_reinforce_01",
	"ally_reinforce_02",
]
const ENEMY_FORMATION_GUIDE_SLOT_IDS := [
	"enemy_main_01",
	"enemy_main_02",
	"enemy_main_03",
	"enemy_reinforce_01",
	"enemy_reinforce_02",
]
const FORMATION_GUIDE_SLOT_NODE_PATHS := {
	"ally_main_01": "BattleUI/FormationSlotGuideLayer/AllyFormationGuidePanel/AllyMain01GuideSlot",
	"ally_main_02": "BattleUI/FormationSlotGuideLayer/AllyFormationGuidePanel/AllyMain02GuideSlot",
	"ally_main_03": "BattleUI/FormationSlotGuideLayer/AllyFormationGuidePanel/AllyMain03GuideSlot",
	"ally_reinforce_01": "BattleUI/FormationSlotGuideLayer/AllyFormationGuidePanel/AllyReinforce01GuideSlot",
	"ally_reinforce_02": "BattleUI/FormationSlotGuideLayer/AllyFormationGuidePanel/AllyReinforce02GuideSlot",
	"enemy_main_01": "BattleUI/FormationSlotGuideLayer/EnemyFormationGuidePanel/EnemyMain01GuideSlot",
	"enemy_main_02": "BattleUI/FormationSlotGuideLayer/EnemyFormationGuidePanel/EnemyMain02GuideSlot",
	"enemy_main_03": "BattleUI/FormationSlotGuideLayer/EnemyFormationGuidePanel/EnemyMain03GuideSlot",
	"enemy_reinforce_01": "BattleUI/FormationSlotGuideLayer/EnemyFormationGuidePanel/EnemyReinforce01GuideSlot",
	"enemy_reinforce_02": "BattleUI/FormationSlotGuideLayer/EnemyFormationGuidePanel/EnemyReinforce02GuideSlot",
}
const BATTLEFIELD_PORTRAIT_BADGE_SIZE := 41.0
const UNKNOWN_HERO_PORTRAIT_FALLBACK_PATH := "res://assets/web_battle/unit_tokens/unit_blue_battlefield.png"
const GENERIC_SKILL_TOAST_FALLBACK_PATH := "res://assets/web_battle/ui/formation_guide/unique_skill_ready_icon.png"
const REINFORCEMENT_ARRIVAL_TOAST_TEXTURE_PATH := "res://assets/web_battle/ui/reinforcement/reinforcement_arrival_toast_01.png"
const REINFORCEMENT_ARRIVAL_TOAST_TEXTURE := preload("res://assets/web_battle/ui/reinforcement/reinforcement_arrival_toast_01.png")
const REINFORCEMENT_ARRIVAL_TOAST_TEXT := "지원군 도착!"
const UNIQUE_SKILL_CUTIN_TIMING_DEBUG := true
const UNIQUE_SKILL_CUTIN_ENTER_DURATION := 0.14
const UNIQUE_SKILL_CUTIN_HOLD_DURATION := 0.08
const UNIQUE_SKILL_CUTIN_EXIT_DURATION := 0.15
const UNIQUE_SKILL_CUTIN_FLASH_DURATION := 0.08
const UNIQUE_SKILL_CUTIN_FLASH_COLOR := Color(0.02, 0.0, 0.0, 0.66)
const UNIQUE_SKILL_CUTIN_SLIDE_IN_RATIO := 0.42
const UNIQUE_SKILL_CUTIN_SLIDE_OUT_RATIO := 0.24
const UNIQUE_SKILL_CUTIN_START_SCALE := 0.85
const UNIQUE_SKILL_CUTIN_PUNCH_SCALE := 1.12
const UNIQUE_SKILL_CUTIN_EXIT_SCALE := 0.92
const UNIQUE_SKILL_CUTIN_EXIT_UP_OFFSET := Vector2(0.0, -30.0)
const UNIQUE_SKILL_CUTIN_PUNCH_IN_DURATION := 0.08
const UNIQUE_SKILL_CUTIN_PUNCH_SETTLE_DURATION := 0.06
const UNIQUE_SKILL_CUTIN_NAME_DELAY := 0.04
const UNIQUE_SKILL_CUTIN_NAME_POP_SCALE := 1.12
const UNIQUE_SKILL_CUTIN_NAME_START_OFFSET := Vector2(0.0, 18.0)
const UNIQUE_SKILL_EFFECT_APPLY_DELAY := UNIQUE_SKILL_CUTIN_NAME_DELAY + UNIQUE_SKILL_CUTIN_ENTER_DURATION + UNIQUE_SKILL_CUTIN_PUNCH_SETTLE_DURATION + UNIQUE_SKILL_CUTIN_HOLD_DURATION + UNIQUE_SKILL_CUTIN_EXIT_DURATION
const UNIQUE_SKILL_POST_EFFECT_HOLD_DURATION := 0.75
const UNIQUE_SKILL_TOAST_DURATION := UNIQUE_SKILL_EFFECT_APPLY_DELAY + UNIQUE_SKILL_POST_EFFECT_HOLD_DURATION
const SPECIALTY_SKILL_VIDEO_CUTIN_HERO_ID := "yi_sunsin"
const SPECIALTY_SKILL_YI_SUNSIN_CUTIN_PORTRAIT_PATH := "res://assets/ui/cutin/portraits/yi_sun_sin_cutin.png"
const SPECIALTY_SKILL_YI_SUNSIN_HAKIKJIN_TITLE_PATH := "res://assets/ui/cutin/titles/yi_sun_sin_hakikjin_title.png"
const SPECIALTY_SKILL_YI_SUNSIN_THEORA_Q8_1920X_PATH := "res://assets/ui/cutin/videos/yi_sun_sin_cutin_bg_theora_q8_1920x.ogv"
const SPECIALTY_SKILL_YI_SUNSIN_THEORA_540P_PATH := "res://assets/ui/cutin/videos/yi_sun_sin_cutin_bg_theora_540p.ogv"
const SPECIALTY_SKILL_KWON_YUL_CUTIN_PORTRAIT_PATH := "res://assets/ui/cutin/portraits/kwon_yul_cutin.png"
const SPECIALTY_SKILL_KWON_YUL_TITLE_PATH := "res://assets/ui/cutin/titles/kwon_yul_haengjudaecheop_title.png"
const SPECIALTY_SKILL_KWON_YUL_THEORA_Q8_1920X_PATH := "res://assets/ui/cutin/videos/kwon_yul_cutin_bg_theora_q8_1920x.ogv"
const SPECIALTY_SKILL_JEONG_DOJEON_CUTIN_PORTRAIT_PATH := "res://assets/ui/cutin/portraits/jeong_do_jeon_cutin.png"
const SPECIALTY_SKILL_JEONG_DOJEON_TITLE_PATH := "res://assets/ui/cutin/titles/jeong_do_jeon_gaehyeokryeong_title.png"
const SPECIALTY_SKILL_JEONG_DOJEON_THEORA_Q8_1920X_PATH := "res://assets/ui/cutin/videos/jeong_do_jeon_cutin_bg_theora_q8_1920x.ogv"
const SPECIALTY_SKILL_GIM_YUSIN_CUTIN_PORTRAIT_PATH := "res://assets/ui/cutin/portraits/kim_yu_sin_cutin.png"
const SPECIALTY_SKILL_GIM_YUSIN_TITLE_PATH := "res://assets/ui/cutin/titles/kim_yu_sin_samguktongil_title.png"
const SPECIALTY_SKILL_GIM_YUSIN_THEORA_Q8_1920X_PATH := "res://assets/ui/cutin/videos/kim_yu_sin_cutin_bg_theora_q8_1920x.ogv"
const SPECIALTY_SKILL_EULJI_MUNDEOK_CUTIN_PORTRAIT_PATH := "res://assets/ui/cutin/portraits/eulji_mundeok_cutin.png"
const SPECIALTY_SKILL_EULJI_MUNDEOK_TITLE_PATH := "res://assets/ui/cutin/titles/eulji_mundeok_salsudaecheop_title.png"
const SPECIALTY_SKILL_EULJI_MUNDEOK_THEORA_Q8_1920X_PATH := "res://assets/ui/cutin/videos/eulji_mundeok_cutin_bg_theora_q8_1920x.ogv"
const CUTIN_VIDEO_DEBUG_FORCE_TOP := false
const SPECIALTY_SKILL_CUTIN_VIDEO_PATHS := {
	"yi_sunsin": [
		SPECIALTY_SKILL_YI_SUNSIN_THEORA_Q8_1920X_PATH,
		SPECIALTY_SKILL_YI_SUNSIN_THEORA_540P_PATH,
		"res://assets/ui/cutin/videos/yi_sun_sin_cutin_bg_vp8.webm",
		"res://assets/ui/cutin/videos/yi_sun_sin_cutin_bg.ogv",
		"res://assets/ui/cutin/videos/yi_sun_sin_cutin_bg.webm",
		"res://assets/ui/cutin/videos/yi_sun_sin_cutin_bg.mp4",
	],
	"kwon_yul": [
		SPECIALTY_SKILL_KWON_YUL_THEORA_Q8_1920X_PATH,
		"res://assets/ui/cutin/videos/kwon_yul_cutin_bg.webm",
		"res://assets/ui/cutin/videos/Kwon Yul Cutin Bg.webm",
		"res://assets/ui/cutin/videos/kwon_yul_cutin_bg.mp4",
	],
	"jeong_dojeon": [
		SPECIALTY_SKILL_JEONG_DOJEON_THEORA_Q8_1920X_PATH,
		"res://assets/ui/cutin/videos/jeong_do_jeon_cutin_bg.webm",
		"res://assets/ui/cutin/videos/Jeong Do Jeon Cutin Bg.webm",
		"res://assets/ui/cutin/videos/jeong_do_jeon_cutin_bg.mp4",
	],
	"gim_yusin": [
		SPECIALTY_SKILL_GIM_YUSIN_THEORA_Q8_1920X_PATH,
	],
	"eulji_mundeok": [
		SPECIALTY_SKILL_EULJI_MUNDEOK_THEORA_Q8_1920X_PATH,
	],
}
const SPECIALTY_SKILL_CUTIN_CONFIGS := {
	"yi_sunsin": {
		"portrait_path": SPECIALTY_SKILL_YI_SUNSIN_CUTIN_PORTRAIT_PATH,
		"title_path": SPECIALTY_SKILL_YI_SUNSIN_HAKIKJIN_TITLE_PATH,
		"hero_width_ratio": 0.86,
		"hero_height_ratio": 1.42,
		"hero_left_overflow": 0.28,
		"hero_y_anchor": 0.55,
		"hero_y_offset": 28.0,
		"title_x_ratio": 0.53,
		"title_y_ratio": 0.22,
		"title_width_ratio": 0.44,
		"title_height_ratio": 0.32,
	},
	"kwon_yul": {
		"portrait_path": SPECIALTY_SKILL_KWON_YUL_CUTIN_PORTRAIT_PATH,
		"title_path": SPECIALTY_SKILL_KWON_YUL_TITLE_PATH,
		"hero_width_ratio": 0.80,
		"hero_height_ratio": 1.30,
		"hero_left_overflow": 0.23,
		"hero_y_anchor": 0.53,
		"hero_y_offset": 18.0,
		"title_x_ratio": 0.55,
		"title_y_ratio": 0.20,
		"title_width_ratio": 0.42,
		"title_height_ratio": 0.31,
	},
	"jeong_dojeon": {
		"portrait_path": SPECIALTY_SKILL_JEONG_DOJEON_CUTIN_PORTRAIT_PATH,
		"title_path": SPECIALTY_SKILL_JEONG_DOJEON_TITLE_PATH,
		"hero_width_ratio": 0.76,
		"hero_height_ratio": 1.24,
		"hero_left_overflow": 0.19,
		"hero_y_anchor": 0.52,
		"hero_y_offset": 24.0,
		"title_x_ratio": 0.56,
		"title_y_ratio": 0.21,
		"title_width_ratio": 0.42,
		"title_height_ratio": 0.31,
	},
	"gim_yusin": {
		"portrait_path": SPECIALTY_SKILL_GIM_YUSIN_CUTIN_PORTRAIT_PATH,
		"title_path": SPECIALTY_SKILL_GIM_YUSIN_TITLE_PATH,
		"hero_width_ratio": 0.82,
		"hero_height_ratio": 1.34,
		"hero_left_overflow": 0.24,
		"hero_y_anchor": 0.53,
		"hero_y_offset": 18.0,
		"title_x_ratio": 0.55,
		"title_y_ratio": 0.20,
		"title_width_ratio": 0.42,
		"title_height_ratio": 0.31,
	},
	"eulji_mundeok": {
		"portrait_path": SPECIALTY_SKILL_EULJI_MUNDEOK_CUTIN_PORTRAIT_PATH,
		"title_path": SPECIALTY_SKILL_EULJI_MUNDEOK_TITLE_PATH,
		"hero_width_ratio": 0.78,
		"hero_height_ratio": 1.28,
		"hero_left_overflow": 0.21,
		"hero_y_anchor": 0.52,
		"hero_y_offset": 22.0,
		"title_x_ratio": 0.56,
		"title_y_ratio": 0.21,
		"title_width_ratio": 0.42,
		"title_height_ratio": 0.31,
	},
}
const SPECIALTY_SKILL_CUTIN_TOTAL_DURATION := 1.38
const SPECIALTY_SKILL_CUTIN_DARKEN_ALPHA := 0.68
const SPECIALTY_SKILL_CUTIN_ENTER_DURATION := 0.24
const SPECIALTY_SKILL_CUTIN_TEXT_DELAY := 0.32
const SPECIALTY_SKILL_CUTIN_TEXT_POP_DURATION := 0.68
const SPECIALTY_SKILL_CUTIN_EXIT_START := 1.18
const SPECIALTY_SKILL_CUTIN_EXIT_DURATION := 0.14
const SPECIALTY_SKILL_CUTIN_HERO_ENTER_OFFSET := Vector2(-390.0, 16.0)
const SPECIALTY_SKILL_CUTIN_HERO_START_SCALE := 1.08
const SPECIALTY_SKILL_CUTIN_HERO_SETTLE_SCALE := 1.0
const SPECIALTY_SKILL_CUTIN_TEXT_ENTER_OFFSET := Vector2(140.0, -8.0)
const SPECIALTY_SKILL_CUTIN_TEXT_START_SCALE := 1.0
const SPECIALTY_SKILL_CUTIN_TEXT_IMPACT_SCALE := 2.25
const SPECIALTY_SKILL_CUTIN_TEXT_READABLE_HOLD := 0.34
const SPECIALTY_SKILL_CUTIN_TEXT_BURST_DURATION := 0.34
const SPECIALTY_SKILL_CUTIN_ACCENT_ENTER_OFFSET := Vector2(160.0, -8.0)
const SPECIALTY_SKILL_CUTIN_ACCENT_COLOR := Color(0.78, 0.91, 1.0, 0.34)
const SPECIALTY_SKILL_CUTIN_ACCENT_EXIT_COLOR := Color(0.78, 0.91, 1.0, 0.0)
const UNIQUE_SKILL_CUTIN_VIEWPORT_WIDTH_RATIO := 0.96
const UNIQUE_SKILL_CUTIN_VIEWPORT_HEIGHT_RATIO := 0.52
const UNIQUE_SKILL_CUTIN_MAX_HEIGHT_RATIO := 0.58
const UNIQUE_SKILL_CUTIN_MIN_HEIGHT := 320.0
const UNIQUE_SKILL_CUTIN_IMAGE_INSET := 24.0
const UNIQUE_SKILL_CUTIN_NAME_HEIGHT := 96.0
const UNIQUE_SKILL_CUTIN_NAME_BOTTOM_MARGIN := 22.0
const UNIQUE_SKILL_DEFAULT_RANGE := 3
const UNIQUE_SKILL_MELEE_RANGE := 1
const UNIQUE_SKILL_SHORT_RANGE := 2
const UNIQUE_SKILL_AOE_RANGE := 4
const UNIQUE_SKILL_BUFF_RANGE := 4
const UNIQUE_SKILL_HIGH_VALUE_DAMAGE_DELTA := 12
const UNIQUE_SKILL_DAMAGE_FONT_SIZE := 42
const UNIQUE_SKILL_DEFAULT_DAMAGE := 44
const UNIQUE_SKILL_AOE_DAMAGE := 38
const UNIQUE_SKILL_SPLASH_DAMAGE := 18
const UNIQUE_SKILL_ATTACK_BUFF := 6
const UNIQUE_SKILL_DEFENSE_BUFF := 4
const UNIQUE_SKILL_ATTACK_BUFF_TURNS := 3
const DEFEAT_RETREAT_TOAST_FIRST_DURATION := 1.2
const DEFEAT_RETREAT_TOAST_QUEUED_DURATION := 1.0
const DEFEAT_RETREAT_TOAST_DEBUG_LOGS := true
const DEFEAT_RETREAT_TOAST_FADE_IN_DURATION := 0.12
const DEFEAT_RETREAT_TOAST_FADE_OUT_DURATION := 0.18
const DEFEAT_RETREAT_TOAST_MAX_QUEUE_PER_CLEANUP := 3
const DEFEAT_RETREAT_TOAST_SIZE := Vector2(440.0, 104.0)
const ENEMY_RETREAT_TOAST_LINES := [
	"아... 내 능력은 여기까지인가!",
	"후퇴한다! 훗날을 기약하겠다!",
	"이 치욕... 잊지 않겠다!",
	"전열을 물려라!",
	"오늘의 패배를 기억하겠다!",
]
const ALLY_DEFEAT_TOAST_LINES := [
	"송구합니다... 여기까지입니다!",
	"더는 버틸 수 없습니다!",
	"전열에서 물러나겠습니다!",
	"부디... 뒤를 부탁드립니다!",
	"아직 쓰러질 수는 없는데...!",
]
const ATTACK_ANGLE_FRONT := "front"
const ATTACK_ANGLE_SIDE := "side"
const ATTACK_ANGLE_BACK := "back"
const FRONT_ATTACK_DAMAGE_MULTIPLIER := 1.0
const SIDE_ATTACK_DAMAGE_MULTIPLIER := 1.15
const BACK_ATTACK_DAMAGE_MULTIPLIER := 1.3
const VICTORY_TOAST_TEXTURE := preload("res://assets/web_battle/ui/results/battle_result_victory.png")
const DEFEAT_TOAST_TEXTURE := preload("res://assets/web_battle/ui/results/battle_result_defeat.png")
const VICTORY_TOAST_TEXT := "승리!"
const DEFEAT_TOAST_TEXT := "패배"
const RESULT_TOAST_SCALE_MULTIPLIER := 1.18
const RESULT_TOAST_HOLD_EXTRA_SECONDS := 2.0
const FACING_LEFT := "left"
const FACING_RIGHT := "right"
const FACING_UP := "up"
const FACING_DOWN := "down"
const UNIT_TYPE_INFANTRY := "infantry"
const UNIT_TYPE_ARCHER := "archer"
const UNIT_TYPE_GUNNER := "gunner"
const UNIT_TYPE_CAVALRY := "cavalry"
const ALLOW_BREAKTHROUGH_MOVE := false
const FACING_ARROW_BUTTON_SIZE_SCALE := 0.96
const FACING_ARROW_PANEL_ALPHA := 1.0
const FACING_ARROW_BUTTON_ALPHA := 1.0
const VALID_FACINGS := [
	FACING_LEFT,
	FACING_RIGHT,
	FACING_UP,
	FACING_DOWN,
]
const MOVE_DUST_FX_TEXTURE_PATHS: Array[String] = [
	"res://assets/web_battle/fx/move/move_dust_01.png",
	"res://assets/web_battle/fx/move/move_dust_01.png",
	"res://assets/web_battle/fx/move/move_dust_02.png",
]
const BATTLE_DUST_ALPHA_MIN := 0.10
const BATTLE_DUST_ALPHA_MAX := 0.22
const BATTLE_DUST_SCALE_MULTIPLIER_MIN := 0.30
const BATTLE_DUST_SCALE_MULTIPLIER_MAX := 0.48
const BATTLE_DUST_DURATION_MIN := 0.10
const BATTLE_DUST_DURATION_MAX := 0.18
const HP_BAR_RUNTIME_ALPHA := 0.8
const UNIT_VISUAL_LAYER_SHADOW := 5
const UNIT_VISUAL_LAYER_HP_BAR := 8
const UNIT_VISUAL_LAYER_TOKEN := 12
const UNIT_VISUAL_LAYER_PORTRAIT := 13
const UNIT_VISUAL_LAYER_TROOP_LABEL := 20
const HERO_REGISTRY := {
	"yi_sunsin": {
		"display_name": "이순신",
		"battlefield_portrait_path": "res://assets/web_battle/portraits_battlefield/yi_sunsin_battlefield.png",
		"closeup_portrait_path": "res://assets/web_battle/portraits/yi_sunsin_portrait.png",
		"default_visual_key": "korea_archer",
	},
	"jeong_dojeon": {
		"display_name": "정도전",
		"battlefield_portrait_path": "res://assets/web_battle/portraits_battlefield/jeong_dojeon_battlefield.png",
		"closeup_portrait_path": "res://assets/web_battle/portraits/jeong_dojeon_portrait.png",
		"default_visual_key": "korea_gunner",
	},
	"kwon_yul": {
		"display_name": "권율",
		"battlefield_portrait_path": "res://assets/web_battle/portraits_battlefield/kwon_yul_battlefield.png",
		"closeup_portrait_path": "res://assets/web_battle/portraits/kwon_yul_portrait.png",
		"default_visual_key": "korea_infantry",
	},
	"gim_yusin": {
		"display_name": "김유신",
		"battlefield_portrait_path": "res://assets/web_battle/portraits_battlefield/gim_yusin_battlefield.png",
		"closeup_portrait_path": "res://assets/web_battle/portraits/gim_yusin_portrait.png",
		"default_visual_key": "korea_archer",
	},
	"eulji_mundeok": {
		"display_name": "을지문덕",
		"battlefield_portrait_path": "res://assets/web_battle/portraits_battlefield/eulji_mundeok_battlefield.png",
		"closeup_portrait_path": "res://assets/web_battle/portraits/eulji_mundeok_portrait.png",
		"default_visual_key": "korea_gunner",
	},
	"guan_yu": {
		"display_name": "관우",
		"battlefield_portrait_path": "res://assets/web_battle/portraits_battlefield/guan_yu_battlefield.png",
		"closeup_portrait_path": "res://assets/web_battle/portraits/guan_yu_portrait.png",
		"default_visual_key": "china_cavalry",
	},
	"zhang_fei": {
		"display_name": "장비",
		"battlefield_portrait_path": "res://assets/web_battle/portraits_battlefield/zhang_fei_battlefield.png",
		"closeup_portrait_path": "res://assets/web_battle/portraits/zhang_fei_portrait.png",
		"default_visual_key": "china_infantry",
	},
	"xiahou_dun": {
		"display_name": "하후돈",
		"battlefield_portrait_path": "res://assets/web_battle/portraits_battlefield/xiahou_dun_battlefield.png",
		"closeup_portrait_path": "res://assets/web_battle/portraits/xiahou_dun_portrait.png",
		"default_visual_key": "china_infantry",
	},
	"liu_bei": {
		"display_name": "유비",
		"battlefield_portrait_path": "res://assets/web_battle/portraits_battlefield/liu_bei_battlefield.png",
		"closeup_portrait_path": "res://assets/web_battle/portraits/liu_bei_portrait.png",
		"default_visual_key": "china_archer",
	},
	"zhuge_liang": {
		"display_name": "제갈량",
		"battlefield_portrait_path": "res://assets/web_battle/portraits_battlefield/zhuge_liang_battlefield.png",
		"closeup_portrait_path": "res://assets/web_battle/portraits/zhuge_liang_portrait.png",
		"default_visual_key": "china_gunner",
	},
}
const TEST_BATTLE_ROSTER := {
	"ally_main_01": "yi_sunsin",
	"ally_main_02": "jeong_dojeon",
	"ally_main_03": "kwon_yul",
	"ally_reinforce_01": "gim_yusin",
	"ally_reinforce_02": "eulji_mundeok",
	"enemy_main_01": "guan_yu",
	"enemy_main_02": "zhang_fei",
	"enemy_main_03": "xiahou_dun",
	"enemy_reinforce_01": "liu_bei",
	"enemy_reinforce_02": "zhuge_liang",
}
const WORLDMAP_CONTEXT_ALLY_SLOT_IDS := [
	"ally_main_01",
	"ally_main_02",
	"ally_main_03",
	"ally_reinforce_01",
	"ally_reinforce_02",
]
const WORLDMAP_CONTEXT_ENEMY_SLOT_IDS := [
	"enemy_main_01",
	"enemy_main_02",
	"enemy_main_03",
	"enemy_reinforce_01",
	"enemy_reinforce_02",
]
const WORLDMAP_CONTEXT_HERO_ID_COMPATIBILITY := {
	"yi_sun_sin": "yi_sunsin",
	"jeong_do_jeon": "jeong_dojeon",
	"kim_yu_sin": "gim_yusin",
	"gim_yusin": "gim_yusin",
	"yi_sunsin": "yi_sunsin",
	"jeong_dojeon": "jeong_dojeon",
	"kwon_yul": "kwon_yul",
	"eulji_mundeok": "eulji_mundeok",
	"guan_yu": "guan_yu",
	"zhang_fei": "zhang_fei",
	"xiahou_dun": "xiahou_dun",
	"liu_bei": "liu_bei",
	"zhuge_liang": "zhuge_liang",
}
const UNIQUE_SKILL_REGISTRY := {
	"yi_sunsin": {
		"skill_id": "hakikjin_barrage",
		"hero_id": "yi_sunsin",
		"name": "학익진",
		"toast_text": "학익진!",
		"effect_type": "cannon_aoe",
		"power": 44,
		"radius": 2,
		"cutin_image_path": "res://assets/web_battle/skill_cutins/yi_sunsin_hakikjin.png",
		"target_mode": "enemy_auto_aoe",
		"consumes_action": true,
		"cooldown_turns": 0,
		"unique": true,
	},
	"jeong_dojeon": {
		"skill_id": "reform_order",
		"hero_id": "jeong_dojeon",
		"name": "개혁령",
		"toast_text": "개혁령!",
		"effect_type": "ally_attack_buff",
		"power": UNIQUE_SKILL_ATTACK_BUFF,
		"cutin_image_path": "res://assets/web_battle/skill_cutins/jeong_dojeon_reform_order.png",
		"target_mode": "ally_all",
		"consumes_action": true,
		"cooldown_turns": 0,
		"unique": true,
	},
	"kwon_yul": {
		"skill_id": "gwon_yul_haengju_defense",
		"hero_id": "kwon_yul",
		"name": "행주대첩",
		"toast_text": "행주대첩!",
		"effect_type": "ally_attack_buff",
		"power": UNIQUE_SKILL_ATTACK_BUFF,
		"cutin_image_path": "res://assets/web_battle/skill_cutins/gwon_yul_haengju_defense.png",
		"target_mode": "ally_all",
		"consumes_action": true,
		"cooldown_turns": 0,
		"unique": true,
	},
	"gim_yusin": {
		"skill_id": "kim_yu_sin_unification_charge",
		"hero_id": "gim_yusin",
		"name": "삼국통일 돌격",
		"toast_text": "삼국통일 돌격!",
		"effect_type": "self_defense_single",
		"power": 50,
		"defense_bonus": UNIQUE_SKILL_DEFENSE_BUFF,
		"cutin_image_path": "res://assets/web_battle/skill_cutins/kim_yu_sin_unification_charge.png",
		"target_mode": "enemy_auto_single",
		"consumes_action": true,
		"cooldown_turns": 0,
		"unique": true,
	},
	"eulji_mundeok": {
		"skill_id": "eulji_mundeok_salsu_ambush",
		"hero_id": "eulji_mundeok",
		"name": "살수대첩 매복",
		"toast_text": "살수대첩 매복!",
		"effect_type": "single_damage_adjacent_shake",
		"power": 48,
		"splash": UNIQUE_SKILL_SPLASH_DAMAGE,
		"cutin_image_path": "res://assets/web_battle/skill_cutins/eulji_mundeok_salsu_ambush.png",
		"target_mode": "enemy_auto_single",
		"consumes_action": true,
		"cooldown_turns": 0,
		"unique": true,
	},
	"guan_yu": {
		"skill_id": "crescent_blade_slash",
		"hero_id": "guan_yu",
		"name": "언월참",
		"toast_text": "언월참!",
		"effect_type": "self_defense_single",
		"power": 54,
		"defense_bonus": UNIQUE_SKILL_DEFENSE_BUFF,
		"cutin_image_path": "res://assets/web_battle/skill_cutins/guan_yu_crescent_blade_slash.png",
		"target_mode": "enemy_auto_single",
		"consumes_action": true,
		"cooldown_turns": 0,
		"unique": true,
	},
	"zhang_fei": {
		"skill_id": "changban_shatter",
		"hero_id": "zhang_fei",
		"name": "장판파열",
		"toast_text": "장판파열!",
		"effect_type": "single_damage_adjacent_shake",
		"power": 50,
		"splash": UNIQUE_SKILL_SPLASH_DAMAGE,
		"cutin_image_path": "res://assets/web_battle/skill_cutins/zhang_fei_changban_shatter.png",
		"target_mode": "enemy_auto_single",
		"consumes_action": true,
		"cooldown_turns": 0,
		"unique": true,
	},
	"xiahou_dun": {
		"skill_id": "xiahou_dun_fierce_breakthrough",
		"hero_id": "xiahou_dun",
		"name": "맹장돌파",
		"toast_text": "맹장돌파!",
		"effect_type": "self_defense_single",
		"power": 50,
		"defense_bonus": UNIQUE_SKILL_DEFENSE_BUFF,
		"cutin_image_path": "res://assets/web_battle/skill_cutins/xiahou_dun_fierce_breakthrough.png",
		"target_mode": "enemy_auto_single",
		"consumes_action": true,
		"cooldown_turns": 0,
		"unique": true,
	},
	"liu_bei": {
		"skill_id": "liu_bei_banner_of_benevolence",
		"hero_id": "liu_bei",
		"name": "인덕의 깃발",
		"toast_text": "인덕의 깃발!",
		"effect_type": "ally_attack_buff",
		"power": UNIQUE_SKILL_ATTACK_BUFF,
		"cutin_image_path": "res://assets/web_battle/skill_cutins/liu_bei_banner_of_benevolence.png",
		"target_mode": "ally_all",
		"consumes_action": true,
		"cooldown_turns": 0,
		"unique": true,
	},
	"zhuge_liang": {
		"skill_id": "zhuge_liang_eight_trigram_formation",
		"hero_id": "zhuge_liang",
		"name": "팔진도",
		"toast_text": "팔진도!",
		"effect_type": "ally_attack_buff",
		"power": UNIQUE_SKILL_ATTACK_BUFF,
		"cutin_image_path": "res://assets/web_battle/skill_cutins/zhuge_liang_eight_trigram_formation.png",
		"target_mode": "ally_all",
		"consumes_action": true,
		"cooldown_turns": 0,
		"unique": true,
	},
}
const ENEMY_MAIN_01_PORTRAIT_TEXTURE := preload("res://assets/web_battle/portraits_battlefield/guan_yu_battlefield.png")
const ENEMY_MAIN_03_PORTRAIT_TEXTURE := preload("res://assets/web_battle/portraits_battlefield/xiahou_dun_battlefield.png")
const BATTLE_DUST_TINT := Color(0.48, 0.38, 0.24, 1.0)
const BATTLE_DUST_HIT_OFFSET := Vector2(0.0, 32.0)
const BATTLE_DUST_WORLD_Z_INDEX := 2
const SLOT_IDS := [
	"ally_main",
	"ally_support",
	"enemy_main",
	"enemy_support",
]
const VISUAL_SLOT_CACHE_IDS := [
	"ally_main",
	"ally_support",
	"enemy_main",
	"enemy_support",
	"ally_main_03",
	"enemy_main_03",
	"ally_reinforce_01",
	"enemy_reinforce_01",
	"ally_reinforce_02",
	"enemy_reinforce_02",
]
const SLOT_ROLE_MAIN := "main"
const SLOT_ROLE_REINFORCE := "reinforce"
const SLOT_ENTRY_INITIAL := "initial"
const SLOT_ENTRY_DELAYED := "delayed"
const SLOT_ENTRY_TRIGGERED := "triggered"
const SLOT_ENTRY_CITY_REINFORCEMENT := "city_reinforcement"
const MAX_MAIN_SLOTS_PER_SIDE := 7
const MAX_REINFORCE_SLOTS_PER_SIDE := 3
const MVP_MAIN_SLOTS_PER_SIDE := 3
const MVP_REINFORCE_SLOTS_PER_SIDE := 2
const CAPACITY_SLOT_IDS := [
	"ally_main_01",
	"ally_main_02",
	"ally_main_03",
	"ally_main_04",
	"ally_main_05",
	"ally_main_06",
	"ally_main_07",
	"ally_reinforce_01",
	"ally_reinforce_02",
	"ally_reinforce_03",
	"enemy_main_01",
	"enemy_main_02",
	"enemy_main_03",
	"enemy_main_04",
	"enemy_main_05",
	"enemy_main_06",
	"enemy_main_07",
	"enemy_reinforce_01",
	"enemy_reinforce_02",
	"enemy_reinforce_03",
]
const LEGACY_SLOT_TO_CAPACITY_SLOT_ID := {
	"ally_main": "ally_main_01",
	"ally_support": "ally_main_02",
	"enemy_main": "enemy_main_01",
	"enemy_support": "enemy_main_02",
}
const CAPACITY_SLOT_TO_LEGACY_SLOT_ID := {
	"ally_main_01": "ally_main",
	"ally_main_02": "ally_support",
	"enemy_main_01": "enemy_main",
	"enemy_main_02": "enemy_support",
}
const CAPACITY_SLOT_ID_TO_SCENE_SLOT_PATH := {
	"ally_main_01": "Slots/AllyMainSlot",
	"ally_main_02": "Slots/AllySupportSlot",
	"ally_main_03": "Slots/AllyMain03Slot",
	"ally_reinforce_01": "Slots/AllyReinforce01Slot",
	"ally_reinforce_02": "Slots/AllyReinforce02Slot",
	"enemy_main_01": "Slots/EnemyMainSlot",
	"enemy_main_02": "Slots/EnemySupportSlot",
	"enemy_main_03": "Slots/EnemyMain03Slot",
	"enemy_reinforce_01": "Slots/EnemyReinforce01Slot",
	"enemy_reinforce_02": "Slots/EnemyReinforce02Slot",
}
const UNIT_VISUAL_TEMPLATE_NODE_PATHS := {
	"ally_main": {
		UNIT_TYPE_INFANTRY: "AllySide/AllyInfantryUnitVisualTemplate",
		UNIT_TYPE_ARCHER: "AllySide/AllyArcherUnitVisualTemplate",
		UNIT_TYPE_GUNNER: "AllySide/AllyGunnerUnitVisualTemplate",
		UNIT_TYPE_CAVALRY: "AllySide/AllyCavalryUnitVisualTemplate",
	},
	"ally_support": {
		UNIT_TYPE_INFANTRY: "AllySide/AllySupportInfantryVisualTemplate",
		UNIT_TYPE_ARCHER: "AllySide/AllySupportArcherVisualTemplate",
		UNIT_TYPE_GUNNER: "AllySide/AllySupportGunnerVisualTemplate",
		UNIT_TYPE_CAVALRY: "AllySide/AllySupportCavalryVisualTemplate",
	},
	"enemy_main": {
		UNIT_TYPE_INFANTRY: "EnemySide/EnemyInfantryUnitVisualTemplate",
		UNIT_TYPE_ARCHER: "EnemySide/EnemyArcherUnitVisualTemplate",
		UNIT_TYPE_GUNNER: "EnemySide/EnemyGunnerUnitVisualTemplate",
		UNIT_TYPE_CAVALRY: "EnemySide/EnemyCavalryUnitVisualTemplate",
	},
	"enemy_support": {
		UNIT_TYPE_INFANTRY: "EnemySide/EnemySupportInfantryVisualTemplate",
		UNIT_TYPE_ARCHER: "EnemySide/EnemySupportArcherVisualTemplate",
		UNIT_TYPE_GUNNER: "EnemySide/EnemySupportGunnerVisualTemplate",
		UNIT_TYPE_CAVALRY: "EnemySide/EnemySupportCavalryVisualTemplate",
	},
}
const UNIT_VISUAL_TOKEN_PATHS := {
	"ally_infantry": {
		"base": "res://assets/web_battle/unit_tokens/korea/infantry/korea_infantry_01.png",
	},
	"ally_archer": {
		"base": "res://assets/web_battle/unit_tokens/korea/archer/korea_archer_01.png",
	},
	"ally_gunner": {
		"base": "res://assets/web_battle/unit_tokens/korea/gunner/korea_gunner_01.png",
	},
	"ally_cavalry": {
		"base": "res://assets/web_battle/unit_tokens/korea/cavalry/korea_cavalry_01.png",
	},
	"enemy_infantry": {
		"base": "res://assets/web_battle/unit_tokens/china/infantry/china_infantry_01.png",
	},
	"enemy_archer": {
		"base": "res://assets/web_battle/unit_tokens/china/archer/china_archer_01.png",
	},
	"enemy_gunner": {
		"base": "res://assets/web_battle/unit_tokens/china/gunner/china_gunner_01.png",
	},
	"enemy_cavalry": {
		"base": "res://assets/web_battle/unit_tokens/china/cavalry/china_cavalry_01.png",
	},
	"korea_infantry": {
		"base": "res://assets/web_battle/unit_tokens/korea/infantry/korea_infantry_01.png",
	},
	"china_infantry": {
		"base": "res://assets/web_battle/unit_tokens/china/infantry/china_infantry_01.png",
	},
	"japan_infantry": {
		"base": "res://assets/web_battle/unit_tokens/japan/infantry/japan_infantry_01.png",
	},
	"korea_archer": {
		"base": "res://assets/web_battle/unit_tokens/korea/archer/korea_archer_01.png",
	},
	"china_archer": {
		"base": "res://assets/web_battle/unit_tokens/china/archer/china_archer_01.png",
	},
	"japan_archer": {
		"base": "res://assets/web_battle/unit_tokens/japan/archer/japan_archer_01.png",
	},
	"korea_cavalry": {
		"base": "res://assets/web_battle/unit_tokens/korea/cavalry/korea_cavalry_01.png",
	},
	"china_cavalry": {
		"base": "res://assets/web_battle/unit_tokens/china/cavalry/china_cavalry_01.png",
	},
	"japan_cavalry": {
		"base": "res://assets/web_battle/unit_tokens/japan/cavalry/japan_cavalry_01.png",
	},
	"korea_gunner": {
		"base": "res://assets/web_battle/unit_tokens/korea/gunner/korea_gunner_01.png",
	},
	"china_gunner": {
		"base": "res://assets/web_battle/unit_tokens/china/gunner/china_gunner_01.png",
	},
	"japan_gunner": {
		"base": "res://assets/web_battle/unit_tokens/japan/gunner/japan_gunner_01.png",
	},
	"legacy_ally_infantry": {
		"base": "res://assets/web_battle/unit_tokens/unit_blue_battlefield.png",
	},
	"legacy_enemy_infantry": {
		"base": "res://assets/web_battle/unit_tokens/unit_china_infantry_battlefield.png",
	},
	"legacy_red_infantry": {
		"base": "res://assets/web_battle/unit_tokens/unit_red_battlefield.png",
	},
}
const ATTACK_SLASH_FX_TEXTURE_PATHS: Array[String] = [
	"res://assets/web_battle/fx/attack/attack_slash_01.png",
	"res://assets/web_battle/fx/attack/attack_slash_02.png",
	"res://assets/web_battle/fx/attack/attack_slash_03.png",
]
const HIT_SPARK_FX_TEXTURE_PATHS: Array[String] = [
	"res://assets/web_battle/fx/hit/hit_spark_01.png",
	"res://assets/web_battle/fx/hit/hit_spark_02.png",
	"res://assets/web_battle/fx/hit/hit_spark_02.png",
]
# v0.64s Two Unit Deployment Prototype
# v0.64s-hotfix Support Facing Indicator Sync
# v0.64t Ally Unit Selection MVP
# v0.64u Enemy Target Selection MVP
# v0.64u-hotfix Target Tween + Occupied Restore
# v0.64v Occupied Hard Block + Basic Attack Select Mode
# v0.64v-hotfix Action State Lock + Attack Select Phase Fix
# v0.64w Round Banner + Move-Then-Attack + Dead Unit Cleanup
# v0.64w-hotfix Attack Select Cancel + Move Rollback
# v0.64w-hotfix Facing Select Right Click Rollback Fix
# v0.64x Enemy Multi AI Activation MVP
# v0.64y Ally Ready Frame + Unit Selection Close-up Panel
# v0.64y-hotfix Scene-Authored Closeup Panel Position
# v0.68b-12b-12 WorldMap Enemy Invasion Battle Scene Handoff MVP
# v0.68b-12b-13 Battle Roster Context Apply MVP
# v0.68b-12b-14 WorldMap Battle Result Return MVP
# v0.68b-12b-14-hotfix3 Owner Shadow Warning Cleanup
# v0.68b-12b-15 WorldMap Invasion Result Ownership Troop Apply MVP
# v0.68b-12b-16 WorldMap Hero Battle Data Unique Skill Contract MVP

const WORLDMAP_BATTLE_CONTEXT_META_KEY := "samwar_worldmap_battle_context"
const WORLDMAP_BATTLE_RESULT_META_KEY := "samwar_worldmap_battle_result"
const WORLDMAP_SCENE_PATH := "res://WorldMap_Test.tscn"

var is_demo_animating := false
var ally_has_moved := false
var ally_has_manual_facing := false
var enemy_has_manual_facing := false
var facing_indicators_should_be_visible := true
var current_phase := PHASE_ALLY_TURN
var battle_log_lines: Array[String] = []
var worldmap_battle_context: Dictionary = {}
var has_applied_worldmap_context_roster := false
var worldmap_context_roster_summary: Dictionary = {}
var worldmap_context_hero_registry: Dictionary = {}
var worldmap_context_unique_skill_registry: Dictionary = {}
var worldmap_return_button: Button = null
var current_ally_unit_position := Vector2.ZERO
var current_ally_portrait_position := Vector2.ZERO
var ally_unit_state: BattleUnitState
var ally_support_unit_state: BattleUnitState
var ally_main_03_unit_state: BattleUnitState
var ally_reinforce_01_unit_state: BattleUnitState
var ally_reinforce_02_unit_state: BattleUnitState
var enemy_unit_state: BattleUnitState
var enemy_support_unit_state: BattleUnitState
var enemy_main_03_unit_state: BattleUnitState
var enemy_reinforce_01_unit_state: BattleUnitState
var enemy_reinforce_02_unit_state: BattleUnitState
var ally_unit_states: Array[BattleUnitState] = []
var enemy_unit_states: Array[BattleUnitState] = []
var all_battle_unit_states: Array[BattleUnitState] = []
var unit_state_by_legacy_slot_id: Dictionary = {}
var unit_state_by_capacity_slot_id: Dictionary = {}
var hero_identity_texture_cache: Dictionary = {}
var has_logged_hero_identity_validation := false
var active_unit_state: BattleUnitState
var has_printed_adapter_alive_parity_snapshot := false
var has_printed_actor_target_adapter_snapshot := false
var has_printed_deployed_active_filter_snapshot := false
var has_printed_mvp_scene_slot_scaffold_snapshot := false
var active_unit_side := "ally"
var is_floating_ally_command_panel_requested := false
var has_selected_move_target := false
var selected_move_cell := Vector2i(-1, -1)
var selected_attack_target_state: BattleUnitState = null
var selected_attack_target_side := ""
var unique_skill_targeting_caster_state: BattleUnitState = null
var unique_skill_targeting_skill_data: Dictionary = {}
var strategy_targeting_caster_state: BattleUnitState = null
var pending_move_snapshot_unit_state: BattleUnitState = null
var pending_move_snapshot_grid_cell := Vector2i(-1, -1)
var pending_move_snapshot_unit_position := Vector2.ZERO
var pending_move_snapshot_portrait_position := Vector2.ZERO
var pending_move_snapshot_facing := FACING_RIGHT
var pending_move_snapshot_has_moved := false
var pending_move_snapshot_ally_has_moved := false
var has_pending_move_snapshot := false
var is_auto_action_in_progress := false
var should_auto_select_facing_after_move := false
var is_full_auto_battle_enabled := false
var auto_battle_step_count := 0
var current_attack_animation_target_state: BattleUnitState = null
var current_enemy_attack_target_state: BattleUnitState = null
var current_enemy_ai_actor_state: BattleUnitState = null
var move_range_cells: Array[ColorRect] = []
var range_overlay_tweens: Array[Tween] = []
var facing_arrow_button_tweens: Array[Tween] = []
var acted_ally_unit_ids: Dictionary = {}
var acted_enemy_unit_ids: Dictionary = {}
var dead_unit_ids: Dictionary = {}
var unique_skill_cooldowns_by_hero_id: Dictionary = {}
var unique_skill_attack_buff_turns_by_unit_id: Dictionary = {}
var unique_skill_attack_buff_bonus_by_unit_id: Dictionary = {}
var unique_skill_defense_buff_bonus_by_unit_id: Dictionary = {}
var strategy_status_icon_labels_by_unit_id: Dictionary = {}
var is_manual_unique_skill_preview_pending := false
var battle_round := 1
var has_deployed_reinforce_01 := false
var has_deployed_reinforce_02 := false
var round_toast_tween: Tween = null
var round_toast_root_base_scale := Vector2.ONE
var round_toast_label_base_scale := Vector2.ONE
var round_toast_default_texture: Texture2D = null
var pending_battle_toasts: Array = []
var is_battle_toast_playing := false
var active_battle_toast_tag := ""
var has_battle_result_toast_shown := false
var has_logged_battle_end_guard := false
var roster_panel_slot_log_signatures: Dictionary = {}
var unique_skill_toast_tween: Tween = null
var specialty_skill_cutin_tween: Tween = null
var is_specialty_skill_cutin_playing := false
var is_unique_skill_presenting := false
var unique_skill_cutin_timing_start_msec := 0
var unique_skill_texture_cache: Dictionary = {}
var battle_toast_suppresses_facing_indicators := false
var unique_skill_toast_suppresses_facing_indicators := false
var facing_indicators_visible_before_toast := true
var defeat_retreat_toast_tween: Tween = null
var is_defeat_retreat_toast_playing := false
var defeat_retreat_toast_queue: Array[Dictionary] = []
var shown_defeat_retreat_toast_unit_ids: Dictionary = {}
var active_defeat_retreat_toast_started_msec := 0
var active_defeat_retreat_toast_display_name := ""
var active_defeat_retreat_toast_side := ""
var active_defeat_retreat_toast_hold_msec := 0
var camera_shake_tween: Tween = null
var combat_camera_tween: Tween = null
var main_camera_scene_position := Vector2.ZERO
var main_camera_scene_zoom := Vector2.ONE
var main_camera_base_position := Vector2.ZERO
var main_camera_base_zoom := Vector2.ONE
var enemy_ai_last_destination_debug: Dictionary = {}
var enemy_ai_reserved_destination_cells: Dictionary = {}
var enemy_ai_reserved_engagement_cells: Dictionary = {}
var move_dust_tweens: Dictionary = {}
var ally_ready_frame_tween: Tween = null
var ally_support_ready_frame_tween: Tween = null
var ally_main_03_ready_frame_tween: Tween = null
var ally_reinforce_01_ready_frame_tween: Tween = null
var ally_reinforce_02_ready_frame_tween: Tween = null
var unit_closeup_tween: Tween = null
var active_ally_turn_pulse_tween: Tween = null
var active_ally_turn_pulse_root: Node2D = null
var active_ally_turn_pulse_root_base_global_position := Vector2.ZERO
var active_ally_turn_pulse_root_pivot_global := Vector2.ZERO
var active_ally_turn_pulse_token: Sprite2D = null
var active_ally_turn_pulse_portrait: Sprite2D = null
var active_ally_turn_pulse_unit_state: BattleUnitState = null
var capacity_slot_metadata_registry: Dictionary = {}
var ally_idle_tween: Tween
var enemy_idle_tween: Tween
var ally_support_idle_tween: Tween
var enemy_support_idle_tween: Tween
var ally_main_03_idle_tween: Tween
var enemy_main_03_idle_tween: Tween
var ally_reinforce_01_idle_tween: Tween
var enemy_reinforce_01_idle_tween: Tween
var ally_reinforce_02_idle_tween: Tween
var enemy_reinforce_02_idle_tween: Tween
var ally_token_base_scale := Vector2.ONE
var enemy_token_base_scale := Vector2.ONE
var ally_support_token_base_scale := Vector2.ONE
var enemy_support_token_base_scale := Vector2.ONE
var ally_main_03_token_base_scale := Vector2.ONE
var enemy_main_03_token_base_scale := Vector2.ONE
var ally_reinforce_01_token_base_scale := Vector2.ONE
var enemy_reinforce_01_token_base_scale := Vector2.ONE
var ally_reinforce_02_token_base_scale := Vector2.ONE
var enemy_reinforce_02_token_base_scale := Vector2.ONE
var ally_visual_root_base_scale := Vector2.ONE
var enemy_visual_root_base_scale := Vector2.ONE
var ally_support_visual_root_base_scale := Vector2.ONE
var enemy_support_visual_root_base_scale := Vector2.ONE
var ally_main_03_visual_root_base_scale := Vector2.ONE
var enemy_main_03_visual_root_base_scale := Vector2.ONE
var ally_reinforce_01_visual_root_base_scale := Vector2.ONE
var enemy_reinforce_01_visual_root_base_scale := Vector2.ONE
var ally_reinforce_02_visual_root_base_scale := Vector2.ONE
var enemy_reinforce_02_visual_root_base_scale := Vector2.ONE
var ally_portrait_badge_base_scale := Vector2.ONE
var ally_support_portrait_badge_base_scale := Vector2.ONE
var ally_main_03_portrait_badge_base_scale := Vector2.ONE
var ally_reinforce_01_portrait_badge_base_scale := Vector2.ONE
var ally_reinforce_02_portrait_badge_base_scale := Vector2.ONE
var enemy_portrait_badge_base_scale := Vector2.ONE
var enemy_support_portrait_badge_base_scale := Vector2.ONE
var enemy_main_03_portrait_badge_base_scale := Vector2.ONE
var enemy_reinforce_01_portrait_badge_base_scale := Vector2.ONE
var enemy_reinforce_02_portrait_badge_base_scale := Vector2.ONE
var ally_token_base_texture: Texture2D
var enemy_token_base_texture: Texture2D
var ally_token_layout_offset := Vector2.ZERO
var ally_shadow_layout_offset := Vector2.ZERO
var ally_portrait_layout_offset := Vector2.ZERO
var ally_hp_bar_layout_offset := Vector2.ZERO
var ally_troop_label_layout_offset := Vector2.ZERO
var ally_move_dust_layout_offset := Vector2.ZERO
var ally_click_area_layout_offset := Vector2.ZERO
var ally_support_token_layout_offset := Vector2.ZERO
var ally_support_shadow_layout_offset := Vector2.ZERO
var ally_support_portrait_layout_offset := Vector2.ZERO
var ally_support_hp_bar_layout_offset := Vector2.ZERO
var ally_support_troop_label_layout_offset := Vector2.ZERO
var ally_support_move_dust_layout_offset := Vector2.ZERO
var ally_support_click_area_layout_offset := Vector2.ZERO
var enemy_token_layout_offset := Vector2.ZERO
var enemy_shadow_layout_offset := Vector2.ZERO
var enemy_portrait_layout_offset := Vector2.ZERO
var enemy_hp_bar_layout_offset := Vector2.ZERO
var enemy_troop_label_layout_offset := Vector2.ZERO
var enemy_move_dust_layout_offset := Vector2.ZERO
var enemy_click_area_layout_offset := Vector2.ZERO
var enemy_support_token_layout_offset := Vector2.ZERO
var enemy_support_shadow_layout_offset := Vector2.ZERO
var enemy_support_portrait_layout_offset := Vector2.ZERO
var enemy_support_hp_bar_layout_offset := Vector2.ZERO
var enemy_support_troop_label_layout_offset := Vector2.ZERO
var enemy_support_move_dust_layout_offset := Vector2.ZERO
var enemy_support_click_area_layout_offset := Vector2.ZERO
var ally_portrait_layout_offsets_by_facing: Dictionary = {}
var ally_support_portrait_layout_offsets_by_facing: Dictionary = {}
var enemy_portrait_layout_offsets_by_facing: Dictionary = {}
var enemy_support_portrait_layout_offsets_by_facing: Dictionary = {}
var ally_facing_indicator_layout_offset := Vector2(-19.3333, -105.0)
var ally_support_facing_indicator_layout_offset := Vector2(-19.3333, -105.0)
var ally_main_03_facing_indicator_layout_offset := Vector2(-19.3333, -105.0)
var ally_reinforce_01_facing_indicator_layout_offset := Vector2(-19.3333, -105.0)
var ally_reinforce_02_facing_indicator_layout_offset := Vector2(-19.3333, -105.0)
var enemy_facing_indicator_layout_offset := Vector2(-18.0, -96.0)
var enemy_support_facing_indicator_layout_offset := Vector2(-18.0, -96.0)
var enemy_main_03_facing_indicator_layout_offset := Vector2(-18.0, -96.0)
var enemy_reinforce_01_facing_indicator_layout_offset := Vector2(-18.0, -96.0)
var enemy_reinforce_02_facing_indicator_layout_offset := Vector2(-18.0, -96.0)
var unit_visual_slot_refs_by_id: Dictionary = {}
var deployment_marker_base_world_positions_by_slot_id: Dictionary = {}

@export var ally_unit_token_up_texture: Texture2D
@export var ally_unit_token_down_texture: Texture2D
@export var enemy_unit_token_up_texture: Texture2D
@export var enemy_unit_token_down_texture: Texture2D

@onready var battlefield_texture: Sprite2D = $BattlefieldRoot/BattlefieldTexture
@onready var ally_unit_marker: Marker2D = $AllyUnitMarker
@onready var ally_move_dust_sprite: Sprite2D = get_node_or_null("Slots/AllyMainSlot/AllyUnitVisualRoot/AllyMoveDustSprite") as Sprite2D
@onready var ally_unit_click_area: Area2D = $AllyUnitClickArea
@onready var ally_unit_click_shape: CollisionShape2D = $AllyUnitClickArea/CollisionShape2D
@onready var ally_support_unit_marker: Marker2D = $AllySupportUnitMarker
@onready var ally_support_move_dust_sprite: Sprite2D = get_node_or_null("Slots/AllySupportSlot/AllySupportUnitVisualRoot/AllySupportMoveDustSprite") as Sprite2D
@onready var ally_support_unit_click_area: Area2D = get_node_or_null("AllySupportUnitClickArea") as Area2D
@onready var ally_support_unit_click_shape: CollisionShape2D = get_node_or_null("AllySupportUnitClickArea/CollisionShape2D") as CollisionShape2D
@onready var ally_main_03_unit_marker: Marker2D = get_node_or_null("AllyMain03UnitMarker") as Marker2D
@onready var ally_main_03_move_dust_sprite: Sprite2D = get_node_or_null("Slots/AllyMain03Slot/AllyMain03UnitVisualRoot/AllyMain03MoveDustSprite") as Sprite2D
@onready var ally_main_03_unit_click_area: Area2D = get_node_or_null("AllyMain03UnitClickArea") as Area2D
@onready var ally_main_03_unit_click_shape: CollisionShape2D = get_node_or_null("AllyMain03UnitClickArea/CollisionShape2D") as CollisionShape2D
@onready var ally_reinforce_01_unit_marker: Marker2D = get_node_or_null("AllyReinforce01UnitMarker") as Marker2D
@onready var ally_reinforce_01_move_dust_sprite: Sprite2D = get_node_or_null("Slots/AllyReinforce01Slot/AllyReinforce01UnitVisualRoot/AllyReinforce01MoveDustSprite") as Sprite2D
@onready var ally_reinforce_01_unit_click_area: Area2D = get_node_or_null("AllyReinforce01UnitClickArea") as Area2D
@onready var ally_reinforce_01_unit_click_shape: CollisionShape2D = get_node_or_null("AllyReinforce01UnitClickArea/CollisionShape2D") as CollisionShape2D
@onready var ally_reinforce_02_unit_marker: Marker2D = get_node_or_null("AllyReinforce02UnitMarker") as Marker2D
@onready var ally_reinforce_02_move_dust_sprite: Sprite2D = get_node_or_null("Slots/AllyReinforce02Slot/AllyReinforce02UnitVisualRoot/AllyReinforce02MoveDustSprite") as Sprite2D
@onready var ally_reinforce_02_unit_click_area: Area2D = get_node_or_null("AllyReinforce02UnitClickArea") as Area2D
@onready var ally_reinforce_02_unit_click_shape: CollisionShape2D = get_node_or_null("AllyReinforce02UnitClickArea/CollisionShape2D") as CollisionShape2D
@onready var enemy_unit_marker: Marker2D = $EnemyUnitMarker
@onready var enemy_move_dust_sprite: Sprite2D = get_node_or_null("Slots/EnemyMainSlot/EnemyUnitVisualRoot/EnemyMoveDustSprite") as Sprite2D
@onready var enemy_unit_click_area: Area2D = get_node_or_null("EnemyUnitClickArea") as Area2D
@onready var enemy_unit_click_shape: CollisionShape2D = get_node_or_null("EnemyUnitClickArea/CollisionShape2D") as CollisionShape2D
@onready var enemy_support_unit_marker: Marker2D = $EnemySupportUnitMarker
@onready var enemy_support_move_dust_sprite: Sprite2D = get_node_or_null("Slots/EnemySupportSlot/EnemySupportUnitVisualRoot/EnemySupportMoveDustSprite") as Sprite2D
@onready var enemy_support_unit_click_area: Area2D = get_node_or_null("EnemySupportUnitClickArea") as Area2D
@onready var enemy_support_unit_click_shape: CollisionShape2D = get_node_or_null("EnemySupportUnitClickArea/CollisionShape2D") as CollisionShape2D
@onready var enemy_main_03_unit_marker: Marker2D = get_node_or_null("EnemyMain03UnitMarker") as Marker2D
@onready var enemy_main_03_move_dust_sprite: Sprite2D = get_node_or_null("Slots/EnemyMain03Slot/EnemyMain03UnitVisualRoot/EnemyMain03MoveDustSprite") as Sprite2D
@onready var enemy_main_03_unit_click_area: Area2D = get_node_or_null("EnemyMain03UnitClickArea") as Area2D
@onready var enemy_main_03_unit_click_shape: CollisionShape2D = get_node_or_null("EnemyMain03UnitClickArea/CollisionShape2D") as CollisionShape2D
@onready var enemy_reinforce_01_unit_marker: Marker2D = get_node_or_null("EnemyReinforce01UnitMarker") as Marker2D
@onready var enemy_reinforce_01_move_dust_sprite: Sprite2D = get_node_or_null("Slots/EnemyReinforce01Slot/EnemyReinforce01UnitVisualRoot/EnemyReinforce01MoveDustSprite") as Sprite2D
@onready var enemy_reinforce_01_unit_click_area: Area2D = get_node_or_null("EnemyReinforce01UnitClickArea") as Area2D
@onready var enemy_reinforce_01_unit_click_shape: CollisionShape2D = get_node_or_null("EnemyReinforce01UnitClickArea/CollisionShape2D") as CollisionShape2D
@onready var enemy_reinforce_02_unit_marker: Marker2D = get_node_or_null("EnemyReinforce02UnitMarker") as Marker2D
@onready var enemy_reinforce_02_move_dust_sprite: Sprite2D = get_node_or_null("Slots/EnemyReinforce02Slot/EnemyReinforce02UnitVisualRoot/EnemyReinforce02MoveDustSprite") as Sprite2D
@onready var enemy_reinforce_02_unit_click_area: Area2D = get_node_or_null("EnemyReinforce02UnitClickArea") as Area2D
@onready var enemy_reinforce_02_unit_click_shape: CollisionShape2D = get_node_or_null("EnemyReinforce02UnitClickArea/CollisionShape2D") as CollisionShape2D
@onready var ally_portrait_marker: Marker2D = $AllyPortraitMarker
@onready var enemy_portrait_marker: Marker2D = $EnemyPortraitMarker
@onready var ally_support_portrait_marker: Marker2D = $AllySupportPortraitMarker
@onready var enemy_support_portrait_marker: Marker2D = $EnemySupportPortraitMarker
@onready var ally_main_03_portrait_marker: Marker2D = get_node_or_null("AllyMain03PortraitMarker") as Marker2D
@onready var ally_reinforce_01_portrait_marker: Marker2D = get_node_or_null("AllyReinforce01PortraitMarker") as Marker2D
@onready var ally_reinforce_02_portrait_marker: Marker2D = get_node_or_null("AllyReinforce02PortraitMarker") as Marker2D
@onready var enemy_main_03_portrait_marker: Marker2D = get_node_or_null("EnemyMain03PortraitMarker") as Marker2D
@onready var enemy_reinforce_01_portrait_marker: Marker2D = get_node_or_null("EnemyReinforce01PortraitMarker") as Marker2D
@onready var enemy_reinforce_02_portrait_marker: Marker2D = get_node_or_null("EnemyReinforce02PortraitMarker") as Marker2D
@onready var move_target_marker: Marker2D = $MoveTargetMarker
@onready var battle_grid_controller: BattleGridController = $BattleGridController
@onready var damage_spawn_marker: Marker2D = $DamageSpawnMarker
@onready var cutin_center_marker: Marker2D = $CutinCenterMarker
@onready var result_center_marker: Marker2D = $ResultCenterMarker
@onready var move_range_overlay_layer: Node2D = $MoveRangeOverlayLayer
@onready var logical_grid_guide_layer: Node2D = get_node_or_null("LogicalGridGuideLayer") as Node2D
@onready var cell_guide_layer: Node2D = get_node_or_null("CellGuideLayer") as Node2D
@onready var cell_guide_current: ColorRect = get_node_or_null("CellGuideLayer/CellGuide_Current") as ColorRect
@onready var cell_guide_right: ColorRect = get_node_or_null("CellGuideLayer/CellGuide_Right") as ColorRect
@onready var cell_guide_down: ColorRect = get_node_or_null("CellGuideLayer/CellGuide_Down") as ColorRect
@onready var cell_guide_label: Label = get_node_or_null("CellGuideLayer/CellGuide_Label") as Label
@onready var move_highlight: ColorRect = $HighlightLayer/MoveHighlight
@onready var attack_highlight: ColorRect = $HighlightLayer/AttackHighlight
@onready var ally_main_03_slot: Node2D = get_node_or_null("Slots/AllyMain03Slot") as Node2D
@onready var ally_reinforce_01_slot: Node2D = get_node_or_null("Slots/AllyReinforce01Slot") as Node2D
@onready var ally_reinforce_02_slot: Node2D = get_node_or_null("Slots/AllyReinforce02Slot") as Node2D
@onready var enemy_main_03_slot: Node2D = get_node_or_null("Slots/EnemyMain03Slot") as Node2D
@onready var enemy_reinforce_01_slot: Node2D = get_node_or_null("Slots/EnemyReinforce01Slot") as Node2D
@onready var enemy_reinforce_02_slot: Node2D = get_node_or_null("Slots/EnemyReinforce02Slot") as Node2D
@onready var ally_unit_visual_root: Node2D = get_node_or_null("Slots/AllyMainSlot/AllyUnitVisualRoot") as Node2D
@onready var ally_support_unit_visual_root: Node2D = get_node_or_null("Slots/AllySupportSlot/AllySupportUnitVisualRoot") as Node2D
@onready var ally_main_03_unit_visual_root: Node2D = get_node_or_null("Slots/AllyMain03Slot/AllyMain03UnitVisualRoot") as Node2D
@onready var ally_reinforce_01_unit_visual_root: Node2D = get_node_or_null("Slots/AllyReinforce01Slot/AllyReinforce01UnitVisualRoot") as Node2D
@onready var ally_reinforce_02_unit_visual_root: Node2D = get_node_or_null("Slots/AllyReinforce02Slot/AllyReinforce02UnitVisualRoot") as Node2D
@onready var enemy_unit_visual_root: Node2D = get_node_or_null("Slots/EnemyMainSlot/EnemyUnitVisualRoot") as Node2D
@onready var enemy_support_unit_visual_root: Node2D = get_node_or_null("Slots/EnemySupportSlot/EnemySupportUnitVisualRoot") as Node2D
@onready var enemy_main_03_unit_visual_root: Node2D = get_node_or_null("Slots/EnemyMain03Slot/EnemyMain03UnitVisualRoot") as Node2D
@onready var enemy_reinforce_01_unit_visual_root: Node2D = get_node_or_null("Slots/EnemyReinforce01Slot/EnemyReinforce01UnitVisualRoot") as Node2D
@onready var enemy_reinforce_02_unit_visual_root: Node2D = get_node_or_null("Slots/EnemyReinforce02Slot/EnemyReinforce02UnitVisualRoot") as Node2D
@onready var ally_unit_token: Sprite2D = $Slots/AllyMainSlot/AllyUnitVisualRoot/AllyUnitToken
@onready var enemy_unit_token: Sprite2D = $Slots/EnemyMainSlot/EnemyUnitVisualRoot/EnemyUnitToken
@onready var ally_unit_shadow: Polygon2D = $Slots/AllyMainSlot/AllyUnitVisualRoot/AllyUnitShadow
@onready var enemy_unit_shadow: Polygon2D = $Slots/EnemyMainSlot/EnemyUnitVisualRoot/EnemyUnitShadow
@onready var ally_portrait_badge: Sprite2D = $Slots/AllyMainSlot/AllyUnitVisualRoot/AllyPortraitBadge
@onready var enemy_portrait_badge: Sprite2D = $Slots/EnemyMainSlot/EnemyUnitVisualRoot/EnemyPortraitBadge
@onready var ally_hp_bar: ProgressBar = $Slots/AllyMainSlot/AllyUnitVisualRoot/AllyHPBar
@onready var enemy_hp_bar: ProgressBar = $Slots/EnemyMainSlot/EnemyUnitVisualRoot/EnemyHPBar
@onready var ally_troop_label: Label = $Slots/AllyMainSlot/AllyUnitVisualRoot/AllyTroopLabel
@onready var enemy_troop_label: Label = $Slots/EnemyMainSlot/EnemyUnitVisualRoot/EnemyTroopLabel
@onready var ally_main_03_unit_token: Sprite2D = get_node_or_null("Slots/AllyMain03Slot/AllyMain03UnitVisualRoot/AllyMain03UnitToken") as Sprite2D
@onready var ally_main_03_unit_shadow: Polygon2D = get_node_or_null("Slots/AllyMain03Slot/AllyMain03UnitVisualRoot/AllyMain03UnitShadow") as Polygon2D
@onready var ally_main_03_portrait_badge: Sprite2D = get_node_or_null("Slots/AllyMain03Slot/AllyMain03UnitVisualRoot/AllyMain03PortraitBadge") as Sprite2D
@onready var ally_main_03_hp_bar: ProgressBar = get_node_or_null("Slots/AllyMain03Slot/AllyMain03UnitVisualRoot/AllyMain03HPBar") as ProgressBar
@onready var ally_main_03_troop_label: Label = get_node_or_null("Slots/AllyMain03Slot/AllyMain03UnitVisualRoot/AllyMain03TroopLabel") as Label
@onready var ally_reinforce_01_unit_token: Sprite2D = get_node_or_null("Slots/AllyReinforce01Slot/AllyReinforce01UnitVisualRoot/AllyReinforce01UnitToken") as Sprite2D
@onready var ally_reinforce_01_unit_shadow: Polygon2D = get_node_or_null("Slots/AllyReinforce01Slot/AllyReinforce01UnitVisualRoot/AllyReinforce01UnitShadow") as Polygon2D
@onready var ally_reinforce_01_portrait_badge: Sprite2D = get_node_or_null("Slots/AllyReinforce01Slot/AllyReinforce01UnitVisualRoot/AllyReinforce01PortraitBadge") as Sprite2D
@onready var ally_reinforce_01_hp_bar: ProgressBar = get_node_or_null("Slots/AllyReinforce01Slot/AllyReinforce01UnitVisualRoot/AllyReinforce01HPBar") as ProgressBar
@onready var ally_reinforce_01_troop_label: Label = get_node_or_null("Slots/AllyReinforce01Slot/AllyReinforce01UnitVisualRoot/AllyReinforce01TroopLabel") as Label
@onready var ally_reinforce_02_unit_token: Sprite2D = get_node_or_null("Slots/AllyReinforce02Slot/AllyReinforce02UnitVisualRoot/AllyReinforce02UnitToken") as Sprite2D
@onready var ally_reinforce_02_unit_shadow: Polygon2D = get_node_or_null("Slots/AllyReinforce02Slot/AllyReinforce02UnitVisualRoot/AllyReinforce02UnitShadow") as Polygon2D
@onready var ally_reinforce_02_portrait_badge: Sprite2D = get_node_or_null("Slots/AllyReinforce02Slot/AllyReinforce02UnitVisualRoot/AllyReinforce02PortraitBadge") as Sprite2D
@onready var ally_reinforce_02_hp_bar: ProgressBar = get_node_or_null("Slots/AllyReinforce02Slot/AllyReinforce02UnitVisualRoot/AllyReinforce02HPBar") as ProgressBar
@onready var ally_reinforce_02_troop_label: Label = get_node_or_null("Slots/AllyReinforce02Slot/AllyReinforce02UnitVisualRoot/AllyReinforce02TroopLabel") as Label
@onready var enemy_main_03_unit_token: Sprite2D = get_node_or_null("Slots/EnemyMain03Slot/EnemyMain03UnitVisualRoot/EnemyMain03UnitToken") as Sprite2D
@onready var enemy_main_03_unit_shadow: Polygon2D = get_node_or_null("Slots/EnemyMain03Slot/EnemyMain03UnitVisualRoot/EnemyMain03UnitShadow") as Polygon2D
@onready var enemy_main_03_portrait_badge: Sprite2D = get_node_or_null("Slots/EnemyMain03Slot/EnemyMain03UnitVisualRoot/EnemyMain03PortraitBadge") as Sprite2D
@onready var enemy_main_03_hp_bar: ProgressBar = get_node_or_null("Slots/EnemyMain03Slot/EnemyMain03UnitVisualRoot/EnemyMain03HPBar") as ProgressBar
@onready var enemy_main_03_troop_label: Label = get_node_or_null("Slots/EnemyMain03Slot/EnemyMain03UnitVisualRoot/EnemyMain03TroopLabel") as Label
@onready var enemy_reinforce_01_unit_token: Sprite2D = get_node_or_null("Slots/EnemyReinforce01Slot/EnemyReinforce01UnitVisualRoot/EnemyReinforce01UnitToken") as Sprite2D
@onready var enemy_reinforce_01_unit_shadow: Polygon2D = get_node_or_null("Slots/EnemyReinforce01Slot/EnemyReinforce01UnitVisualRoot/EnemyReinforce01UnitShadow") as Polygon2D
@onready var enemy_reinforce_01_portrait_badge: Sprite2D = get_node_or_null("Slots/EnemyReinforce01Slot/EnemyReinforce01UnitVisualRoot/EnemyReinforce01PortraitBadge") as Sprite2D
@onready var enemy_reinforce_01_hp_bar: ProgressBar = get_node_or_null("Slots/EnemyReinforce01Slot/EnemyReinforce01UnitVisualRoot/EnemyReinforce01HPBar") as ProgressBar
@onready var enemy_reinforce_01_troop_label: Label = get_node_or_null("Slots/EnemyReinforce01Slot/EnemyReinforce01UnitVisualRoot/EnemyReinforce01TroopLabel") as Label
@onready var enemy_reinforce_02_unit_token: Sprite2D = get_node_or_null("Slots/EnemyReinforce02Slot/EnemyReinforce02UnitVisualRoot/EnemyReinforce02UnitToken") as Sprite2D
@onready var enemy_reinforce_02_unit_shadow: Polygon2D = get_node_or_null("Slots/EnemyReinforce02Slot/EnemyReinforce02UnitVisualRoot/EnemyReinforce02UnitShadow") as Polygon2D
@onready var enemy_reinforce_02_portrait_badge: Sprite2D = get_node_or_null("Slots/EnemyReinforce02Slot/EnemyReinforce02UnitVisualRoot/EnemyReinforce02PortraitBadge") as Sprite2D
@onready var enemy_reinforce_02_hp_bar: ProgressBar = get_node_or_null("Slots/EnemyReinforce02Slot/EnemyReinforce02UnitVisualRoot/EnemyReinforce02HPBar") as ProgressBar
@onready var enemy_reinforce_02_troop_label: Label = get_node_or_null("Slots/EnemyReinforce02Slot/EnemyReinforce02UnitVisualRoot/EnemyReinforce02TroopLabel") as Label
@onready var ally_infantry_unit_visual_template: Node2D = get_node_or_null("AllySide/AllyInfantryUnitVisualTemplate") as Node2D
@onready var enemy_infantry_unit_visual_template: Node2D = get_node_or_null("EnemySide/EnemyInfantryUnitVisualTemplate") as Node2D
@onready var ally_support_unit_token: Sprite2D = $Slots/AllySupportSlot/AllySupportUnitVisualRoot/AllySupportUnitToken
@onready var enemy_support_unit_token: Sprite2D = $Slots/EnemySupportSlot/EnemySupportUnitVisualRoot/EnemySupportUnitToken
@onready var ally_support_unit_shadow: Polygon2D = $Slots/AllySupportSlot/AllySupportUnitVisualRoot/AllySupportUnitShadow
@onready var enemy_support_unit_shadow: Polygon2D = $Slots/EnemySupportSlot/EnemySupportUnitVisualRoot/EnemySupportUnitShadow
@onready var ally_support_portrait_badge: Sprite2D = $Slots/AllySupportSlot/AllySupportUnitVisualRoot/AllySupportPortraitBadge
@onready var enemy_support_portrait_badge: Sprite2D = $Slots/EnemySupportSlot/EnemySupportUnitVisualRoot/EnemySupportPortraitBadge
@onready var ally_support_hp_bar: ProgressBar = $Slots/AllySupportSlot/AllySupportUnitVisualRoot/AllySupportHPBar
@onready var enemy_support_hp_bar: ProgressBar = $Slots/EnemySupportSlot/EnemySupportUnitVisualRoot/EnemySupportHPBar
@onready var ally_support_troop_label: Label = $Slots/AllySupportSlot/AllySupportUnitVisualRoot/AllySupportTroopLabel
@onready var enemy_support_troop_label: Label = $Slots/EnemySupportSlot/EnemySupportUnitVisualRoot/EnemySupportTroopLabel
@onready var ally_support_infantry_unit_visual_template: Node2D = get_node_or_null("AllySide/AllySupportInfantryVisualTemplate") as Node2D
@onready var enemy_support_infantry_unit_visual_template: Node2D = get_node_or_null("EnemySide/EnemySupportInfantryVisualTemplate") as Node2D
@onready var damage_text_layer: Node2D = $DamageTextLayer
@onready var damage_preview_label: Label = $DamageTextLayer/DamagePreviewLabel
@onready var battle_fx_root: Node2D = get_node_or_null("BattleFXRoot") as Node2D
@onready var move_dust_template: Sprite2D = get_node_or_null("BattleFXRoot/MoveDustTemplate") as Sprite2D
@onready var main_camera: Camera2D = $MainCamera
@onready var battle_ui: CanvasLayer = $BattleUI
@onready var top_bar: Panel = $BattleUI/TopBar
@onready var left_panel: Panel = $BattleUI/LeftPanel
@onready var right_panel: Panel = $BattleUI/RightPanel
@onready var battle_mini_log_panel: Panel = get_node_or_null("BattleUI/BattleMiniLogPanel") as Panel
@onready var battle_mini_log_title_label: Label = get_node_or_null("BattleUI/BattleMiniLogPanel/BattleMiniLogTitleLabel") as Label
@onready var battle_mini_log_label: Label = get_node_or_null("BattleUI/BattleMiniLogPanel/BattleMiniLogLabel") as Label
@onready var formation_slot_guide_layer: Control = get_node_or_null("BattleUI/FormationSlotGuideLayer") as Control
@onready var ally_formation_guide_panel: Panel = get_node_or_null("BattleUI/FormationSlotGuideLayer/AllyFormationGuidePanel") as Panel
@onready var enemy_formation_guide_panel: Panel = get_node_or_null("BattleUI/FormationSlotGuideLayer/EnemyFormationGuidePanel") as Panel
@onready var command_bar: Panel = $BattleUI/CommandBar
@onready var command_bar_label: Label = get_node_or_null("BattleUI/CommandBar/CommandBarLabel") as Label
@onready var basic_attack_button: Button = $BattleUI/CommandBar/BasicAttackButton
@onready var move_button: Button = $BattleUI/CommandBar/MoveButton
@onready var wait_button: Button = get_node_or_null("BattleUI/CommandBar/WaitButton") as Button
@onready var end_turn_button: BaseButton = get_node_or_null("BattleUI/CommandBar/EndTurnButton") as BaseButton
@onready var auto_battle_button: BaseButton = get_node_or_null("BattleUI/CommandBar/AutoBattleButton") as BaseButton
@onready var retreat_button: BaseButton = get_node_or_null("BattleUI/CommandBar/RetreatButton") as BaseButton
@onready var floating_ally_command_panel: Panel = get_node_or_null("BattleUI/FloatingAllyCommandPanel") as Panel
@onready var floating_basic_attack_button: Button = get_node_or_null("BattleUI/FloatingAllyCommandPanel/FloatingBasicAttackButton") as Button
@onready var floating_unique_skill_button: Button = get_node_or_null("BattleUI/FloatingAllyCommandPanel/FloatingUniqueSkillButton") as Button
@onready var floating_tactics_button: Button = get_node_or_null("BattleUI/FloatingAllyCommandPanel/FloatingTacticsButton") as Button
@onready var floating_move_button: Button = get_node_or_null("BattleUI/FloatingAllyCommandPanel/FloatingMoveButton") as Button
@onready var floating_wait_button: Button = get_node_or_null("BattleUI/FloatingAllyCommandPanel/FloatingWaitButton") as Button
@onready var facing_selection_panel: Panel = get_node_or_null("BattleUI/FacingSelectionPanel") as Panel
@onready var face_left_button: Button = get_node_or_null("BattleUI/FacingSelectionPanel/FaceLeftButton") as Button
@onready var face_right_button: Button = get_node_or_null("BattleUI/FacingSelectionPanel/FaceRightButton") as Button
@onready var face_up_button: Button = get_node_or_null("BattleUI/FacingSelectionPanel/FaceUpButton") as Button
@onready var face_down_button: Button = get_node_or_null("BattleUI/FacingSelectionPanel/FaceDownButton") as Button
@onready var facing_arrow_panel: Control = get_node_or_null("BattleUI/FacingArrowPanel") as Control
@onready var face_left_arrow_button: Button = get_node_or_null("BattleUI/FacingArrowPanel/FaceLeftArrowButton") as Button
@onready var face_right_arrow_button: Button = get_node_or_null("BattleUI/FacingArrowPanel/FaceRightArrowButton") as Button
@onready var face_up_arrow_button: Button = get_node_or_null("BattleUI/FacingArrowPanel/FaceUpArrowButton") as Button
@onready var face_down_arrow_button: Button = get_node_or_null("BattleUI/FacingArrowPanel/FaceDownArrowButton") as Button
@onready var ally_facing_indicator: Label = get_node_or_null("BattleUI/AllyFacingIndicator") as Label
@onready var ally_support_facing_indicator: Label = get_node_or_null("BattleUI/AllySupportFacingIndicator") as Label
@onready var enemy_facing_indicator: Label = get_node_or_null("BattleUI/EnemyFacingIndicator") as Label
@onready var enemy_support_facing_indicator: Label = get_node_or_null("BattleUI/EnemySupportFacingIndicator") as Label
@onready var ally_main_03_facing_indicator: Label = get_node_or_null("BattleUI/AllyMain03FacingIndicator") as Label
@onready var enemy_main_03_facing_indicator: Label = get_node_or_null("BattleUI/EnemyMain03FacingIndicator") as Label
@onready var ally_reinforce_01_facing_indicator: Label = get_node_or_null("BattleUI/AllyReinforce01FacingIndicator") as Label
@onready var ally_reinforce_02_facing_indicator: Label = get_node_or_null("BattleUI/AllyReinforce02FacingIndicator") as Label
@onready var enemy_reinforce_01_facing_indicator: Label = get_node_or_null("BattleUI/EnemyReinforce01FacingIndicator") as Label
@onready var enemy_reinforce_02_facing_indicator: Label = get_node_or_null("BattleUI/EnemyReinforce02FacingIndicator") as Label
@onready var ally_ready_frame: Panel = get_node_or_null("BattleUI/AllyReadyFrame") as Panel
@onready var ally_support_ready_frame: Panel = get_node_or_null("BattleUI/AllySupportReadyFrame") as Panel
@onready var ally_main_03_ready_frame: Panel = get_node_or_null("BattleUI/AllyMain03ReadyFrame") as Panel
@onready var ally_reinforce_01_ready_frame: Panel = get_node_or_null("BattleUI/AllyReinforce01ReadyFrame") as Panel
@onready var ally_reinforce_02_ready_frame: Panel = get_node_or_null("BattleUI/AllyReinforce02ReadyFrame") as Panel
@onready var round_toast_root: Control = get_node_or_null("BattleUI/RoundToastRoot") as Control
@onready var round_toast_image: TextureRect = get_node_or_null("BattleUI/RoundToastRoot/RoundToastImage") as TextureRect
@onready var round_toast_label: Label = get_node_or_null("BattleUI/RoundToastRoot/RoundToastLabel") as Label
@onready var unique_skill_toast_root: Control = get_node_or_null("BattleUI/UniqueSkillToastRoot") as Control
@onready var unique_skill_ink_burst: ColorRect = get_node_or_null("BattleUI/UniqueSkillToastRoot/UniqueSkillInkBurst") as ColorRect
@onready var unique_skill_cutin_image: TextureRect = get_node_or_null("BattleUI/UniqueSkillToastRoot/UniqueSkillCutinImage") as TextureRect
@onready var unique_skill_name_label: Label = get_node_or_null("BattleUI/UniqueSkillToastRoot/UniqueSkillNameLabel") as Label
@onready var specialty_skill_cutin_layer: Control = get_node_or_null("BattleUI/SkillCutinLayer") as Control
@onready var specialty_skill_cutin_darken: ColorRect = get_node_or_null("BattleUI/SkillCutinLayer/ColorRect_Darken") as ColorRect
@onready var specialty_skill_cutin_video: VideoStreamPlayer = get_node_or_null("BattleUI/SkillCutinLayer/VideoStreamPlayer_Cutin") as VideoStreamPlayer
@onready var specialty_skill_cutin_slash: ColorRect = get_node_or_null("BattleUI/SkillCutinLayer/TextureRect_Slash") as ColorRect
@onready var specialty_skill_cutin_hero: TextureRect = get_node_or_null("BattleUI/SkillCutinLayer/TextureRect_Hero") as TextureRect
@onready var specialty_skill_cutin_text: Control = get_node_or_null("BattleUI/SkillCutinLayer/Control_Text") as Control
@onready var specialty_skill_cutin_skill_title: TextureRect = get_node_or_null("BattleUI/SkillCutinLayer/Control_Text/TextureRect_SkillTitle") as TextureRect
@onready var specialty_skill_cutin_animation_player: AnimationPlayer = get_node_or_null("BattleUI/SkillCutinLayer/AnimationPlayer_Cutin") as AnimationPlayer
@onready var enemy_retreat_toast_root: Control = get_node_or_null("EnemyRetreatToastLayer/EnemyRetreatToastRoot") as Control
@onready var enemy_retreat_portrait: TextureRect = get_node_or_null("EnemyRetreatToastLayer/EnemyRetreatToastRoot/EnemyRetreatPortrait") as TextureRect
@onready var enemy_retreat_name_label: Label = get_node_or_null("EnemyRetreatToastLayer/EnemyRetreatToastRoot/EnemyRetreatNameLabel") as Label
@onready var enemy_retreat_line_label: Label = get_node_or_null("EnemyRetreatToastLayer/EnemyRetreatToastRoot/EnemyRetreatLineLabel") as Label
@onready var unit_closeup_panel: Panel = get_node_or_null("BattleUI/UnitCloseupPanel") as Panel
@onready var closeup_hero_portrait: TextureRect = get_node_or_null("BattleUI/UnitCloseupPanel/CloseupHeroPortrait") as TextureRect
@onready var closeup_troop_image: TextureRect = get_node_or_null("BattleUI/UnitCloseupPanel/CloseupTroopImage") as TextureRect
@onready var closeup_name_label: Label = get_node_or_null("BattleUI/UnitCloseupPanel/CloseupNameLabel") as Label
@onready var closeup_troop_label: Label = get_node_or_null("BattleUI/UnitCloseupPanel/CloseupTroopLabel") as Label
@onready var closeup_status_label: Label = get_node_or_null("BattleUI/UnitCloseupPanel/CloseupStatusLabel") as Label
@onready var turn_banner: Label = $BattleUI/TopBar/TurnBanner
@onready var battle_log_preview: Label = $BattleUI/LeftPanel/BattleLogPreview
@onready var cutin_overlay: CanvasLayer = $CutinOverlay
@onready var cutin_image: TextureRect = $CutinOverlay/CutinImage
@onready var cutin_name_label: Label = $CutinOverlay/CutinNameLabel
@onready var cutin_quote_label: Label = $CutinOverlay/CutinQuoteLabel
@onready var result_overlay: CanvasLayer = $ResultOverlay
@onready var result_image: TextureRect = $ResultOverlay/ResultImage
@onready var result_title_label: Label = $ResultOverlay/ResultTitleLabel


func _ready() -> void:
	ally_token_base_scale = ally_unit_token.scale
	enemy_token_base_scale = enemy_unit_token.scale
	ally_support_token_base_scale = ally_support_unit_token.scale
	enemy_support_token_base_scale = enemy_support_unit_token.scale
	ally_visual_root_base_scale = ally_unit_visual_root.scale
	enemy_visual_root_base_scale = enemy_unit_visual_root.scale
	ally_support_visual_root_base_scale = ally_support_unit_visual_root.scale
	enemy_support_visual_root_base_scale = enemy_support_unit_visual_root.scale
	ally_portrait_badge_base_scale = ally_portrait_badge.scale
	enemy_portrait_badge_base_scale = enemy_portrait_badge.scale
	ally_support_portrait_badge_base_scale = ally_support_portrait_badge.scale
	enemy_support_portrait_badge_base_scale = enemy_support_portrait_badge.scale
	if ally_main_03_unit_token != null:
		ally_main_03_token_base_scale = ally_main_03_unit_token.scale
	if ally_main_03_unit_visual_root != null:
		ally_main_03_visual_root_base_scale = ally_main_03_unit_visual_root.scale
	if ally_main_03_portrait_badge != null:
		ally_main_03_portrait_badge_base_scale = ally_main_03_portrait_badge.scale
	if ally_reinforce_01_unit_token != null:
		ally_reinforce_01_token_base_scale = ally_reinforce_01_unit_token.scale
	if ally_reinforce_01_unit_visual_root != null:
		ally_reinforce_01_visual_root_base_scale = ally_reinforce_01_unit_visual_root.scale
	if ally_reinforce_01_portrait_badge != null:
		ally_reinforce_01_portrait_badge_base_scale = ally_reinforce_01_portrait_badge.scale
	if ally_reinforce_02_unit_token != null:
		ally_reinforce_02_token_base_scale = ally_reinforce_02_unit_token.scale
	if ally_reinforce_02_unit_visual_root != null:
		ally_reinforce_02_visual_root_base_scale = ally_reinforce_02_unit_visual_root.scale
	if ally_reinforce_02_portrait_badge != null:
		ally_reinforce_02_portrait_badge_base_scale = ally_reinforce_02_portrait_badge.scale
	if enemy_main_03_unit_token != null:
		enemy_main_03_token_base_scale = enemy_main_03_unit_token.scale
	if enemy_main_03_unit_visual_root != null:
		enemy_main_03_visual_root_base_scale = enemy_main_03_unit_visual_root.scale
	if enemy_main_03_portrait_badge != null:
		enemy_main_03_portrait_badge_base_scale = enemy_main_03_portrait_badge.scale
	if enemy_reinforce_01_unit_token != null:
		enemy_reinforce_01_token_base_scale = enemy_reinforce_01_unit_token.scale
	if enemy_reinforce_01_unit_visual_root != null:
		enemy_reinforce_01_visual_root_base_scale = enemy_reinforce_01_unit_visual_root.scale
	if enemy_reinforce_01_portrait_badge != null:
		enemy_reinforce_01_portrait_badge_base_scale = enemy_reinforce_01_portrait_badge.scale
	if enemy_reinforce_02_unit_token != null:
		enemy_reinforce_02_token_base_scale = enemy_reinforce_02_unit_token.scale
	if enemy_reinforce_02_unit_visual_root != null:
		enemy_reinforce_02_visual_root_base_scale = enemy_reinforce_02_unit_visual_root.scale
	if enemy_reinforce_02_portrait_badge != null:
		enemy_reinforce_02_portrait_badge_base_scale = enemy_reinforce_02_portrait_badge.scale
	ally_token_base_texture = ally_unit_token.texture
	enemy_token_base_texture = enemy_unit_token.texture
	_hide_all_move_dust_sprites()
	_set_visual_template_token_sprite_visibility(false)
	basic_attack_button.pressed.connect(try_basic_attack)
	move_button.pressed.connect(play_basic_move_demo)
	if wait_button != null:
		wait_button.pressed.connect(_end_ally_turn_by_wait)
	if end_turn_button != null:
		end_turn_button.pressed.connect(_end_ally_turn_by_wait)
	if auto_battle_button != null:
		auto_battle_button.pressed.connect(_toggle_full_auto_battle)
	_configure_command_bar()
	if floating_basic_attack_button != null:
		floating_basic_attack_button.pressed.connect(try_basic_attack)
	if floating_unique_skill_button != null:
		floating_unique_skill_button.pressed.connect(_on_unique_skill_button_pressed)
	if floating_tactics_button != null:
		floating_tactics_button.pressed.connect(_on_strategy_button_pressed)
	if floating_move_button != null:
		floating_move_button.pressed.connect(_on_defend_button_pressed)
	if floating_wait_button != null:
		floating_wait_button.pressed.connect(_end_ally_turn_by_wait)
	if face_left_button != null:
		face_left_button.pressed.connect(_select_post_move_facing.bind(FACING_LEFT))
	if face_right_button != null:
		face_right_button.pressed.connect(_select_post_move_facing.bind(FACING_RIGHT))
	if face_up_button != null:
		face_up_button.pressed.connect(_select_post_move_facing.bind(FACING_UP))
	if face_down_button != null:
		face_down_button.pressed.connect(_select_post_move_facing.bind(FACING_DOWN))
	if face_left_arrow_button != null:
		face_left_arrow_button.pressed.connect(_select_post_move_facing.bind(FACING_LEFT))
	if face_right_arrow_button != null:
		face_right_arrow_button.pressed.connect(_select_post_move_facing.bind(FACING_RIGHT))
	if face_up_arrow_button != null:
		face_up_arrow_button.pressed.connect(_select_post_move_facing.bind(FACING_UP))
	if face_down_arrow_button != null:
		face_down_arrow_button.pressed.connect(_select_post_move_facing.bind(FACING_DOWN))
	_configure_round_toast()
	_configure_unique_skill_toast()
	_configure_specialty_skill_cutin()
	_configure_enemy_retreat_toast()
	_configure_main_camera()
	_collect_move_range_cells()
	_sync_deployment_markers_from_scene_visual_anchors()
	_capture_scene_authored_unit_layout_offsets()
	_rebuild_unit_visual_slot_refs()
	_build_capacity_slot_metadata_registry()
	_apply_facing_arrow_panel_visual_style()
	_configure_ally_ready_frames()
	_configure_unit_closeup_panel()
	_configure_layout_guides()
	_configure_floating_ally_command_panel()
	_configure_worldmap_result_return_button()
	reset_demo_state()
	_read_worldmap_battle_context_handoff()
	_debug_print_unit_visual_root_slots()
	_debug_print_mvp_scene_slot_scaffold_snapshot_once()
	_debug_print_capacity_slot_registry()
	_debug_print_unit_state_visual_binding_summary()
	_debug_print_adapter_alive_parity_snapshot_once()
	_debug_print_actor_target_adapter_snapshot_once()
	_debug_print_deployed_active_filter_snapshot_once()


func _read_worldmap_battle_context_handoff() -> void:
	worldmap_battle_context = {}
	if not Engine.has_meta(WORLDMAP_BATTLE_CONTEXT_META_KEY):
		print("[Battle] No WorldMap battle context; using test battle setup")
		_append_battle_log("월드맵 전투 데이터 없음 · 테스트 전투")
		return
	var context: Variant = Engine.get_meta(WORLDMAP_BATTLE_CONTEXT_META_KEY)
	Engine.remove_meta(WORLDMAP_BATTLE_CONTEXT_META_KEY)
	if not context is Dictionary:
		print("[Battle] Invalid WorldMap battle context; using test battle setup")
		_append_battle_log("월드맵 전투 데이터 오류 · 테스트 전투")
		return
	var context_dict := context as Dictionary
	if context_dict.is_empty():
		print("[Battle] Empty WorldMap battle context; using test battle setup")
		_append_battle_log("월드맵 전투 데이터 없음 · 테스트 전투")
		return
	worldmap_battle_context = context_dict.duplicate(true)
	_apply_worldmap_battle_context_handoff(worldmap_battle_context)


func _apply_worldmap_battle_context_handoff(context: Dictionary) -> void:
	var mode := str(context.get("mode", "manual"))
	var attacker_city_name := str(context.get("attacker_city_name", "알 수 없는 공격 도시"))
	var defender_city_name := str(context.get("defender_city_name", "알 수 없는 방어 도시"))
	var attacker_city_id := str(context.get("attacker_city_id", ""))
	var defender_city_id := str(context.get("defender_city_id", ""))
	var battle_type := str(context.get("type", "defense"))
	print("[Battle] WorldMap battle context received: type=%s mode=%s attacker=%s(%s) defender=%s(%s)" % [
		battle_type,
		mode,
		attacker_city_name,
		attacker_city_id,
		defender_city_name,
		defender_city_id,
	])
	var battle_label := "공격전" if _is_worldmap_player_attack_context(context) else "방어전"
	_append_battle_log("월드맵 %s 데이터 수신" % battle_label)
	_append_battle_log("%s %s · %s → %s" % [mode, battle_label, attacker_city_name, defender_city_name])
	_setup_worldmap_context_battle_roster(context)
	_refresh_worldmap_result_return_button()


func _setup_worldmap_context_battle_roster(context: Dictionary) -> void:
	if has_applied_worldmap_context_roster:
		return
	if context.is_empty():
		return
	has_applied_worldmap_context_roster = true
	_register_worldmap_context_hero_contracts(context)
	var ally_context_side := "attacker" if _is_worldmap_player_attack_context(context) else "defender"
	var enemy_context_side := "defender" if _is_worldmap_player_attack_context(context) else "attacker"
	var ally_dispatch_type := "player_attack_context" if _is_worldmap_player_attack_context(context) else "defense_context"
	var enemy_dispatch_type := "attack_target_context" if _is_worldmap_player_attack_context(context) else "invasion_context"
	var ally_result := _apply_worldmap_context_side_roster(
		context,
		ally_context_side,
		WORLDMAP_CONTEXT_ALLY_SLOT_IDS,
		ally_dispatch_type
	)
	var enemy_result := _apply_worldmap_context_side_roster(
		context,
		enemy_context_side,
		WORLDMAP_CONTEXT_ENEMY_SLOT_IDS,
		enemy_dispatch_type
	)
	worldmap_context_roster_summary = {
		"ally": ally_result,
		"enemy": enemy_result,
	}
	_apply_all_hero_identities()
	_rebuild_battle_unit_state_list_refs()
	_update_all_unit_visuals_from_state()
	_refresh_formation_slot_guides()
	_append_battle_log("월드맵 %s 편성 적용" % ("공격전" if _is_worldmap_player_attack_context(context) else "방어전"))
	_append_battle_log("아군 %d명 · 적군 %d명" % [
		int(ally_result.get("resolved_count", 0)),
		int(enemy_result.get("resolved_count", 0)),
	])
	print("[Battle] WorldMap roster applied: ally=%s enemy=%s" % [
		str(ally_result.get("assigned_hero_ids", [])),
		str(enemy_result.get("assigned_hero_ids", [])),
	])


func _is_worldmap_player_attack_context(context: Dictionary) -> bool:
	var source := str(context.get("source", "")).to_lower()
	var battle_type := str(context.get("type", "")).to_lower()
	return source == "player_attack" or battle_type == "attack"


func _apply_worldmap_context_side_roster(
	context: Dictionary,
	context_side: String,
	slot_ids: Array,
	dispatch_type: String
) -> Dictionary:
	var requested_hero_ids := _get_context_hero_ids_for_side(context, context_side)
	var city_id := str(context.get("%s_city_id" % context_side, ""))
	var city_name := str(context.get("%s_city_name" % context_side, ""))
	var city_owner_id := str(context.get("%s_owner" % context_side, ""))
	var assigned_hero_ids: Array[String] = []
	var fallback_count := 0
	var blocks_sample_fallback := _is_worldmap_invasion_context_for_roster(context)
	var allows_crash_guard_fallback := _allows_sample_roster_crash_guard(context)
	if allows_crash_guard_fallback:
		blocks_sample_fallback = false
	var allow_sample_fallback := requested_hero_ids.is_empty() and not blocks_sample_fallback
	print("[CONTEXT_SLOT] source=%s side=%s requested=%s sample_fallback=%s" % [
		str(context.get("source", "")),
		context_side,
		str(requested_hero_ids),
		str(allow_sample_fallback),
	])
	for index in range(slot_ids.size()):
		var slot_id := str(slot_ids[index])
		var requested_hero_id := ""
		if index < requested_hero_ids.size():
			requested_hero_id = requested_hero_ids[index]
		if requested_hero_id == "" and not allow_sample_fallback:
			print("[CONTEXT_SLOT_SKIP] slot=%s side=%s reason=empty_context_slot_no_fallback" % [
				slot_id,
				context_side,
			])
			_deactivate_worldmap_context_slot(slot_id, context_side, city_id, city_name, city_owner_id)
			continue
		var resolved_hero_id := _resolve_worldmap_context_hero_id(requested_hero_id)
		if resolved_hero_id == "":
			if allow_sample_fallback:
				resolved_hero_id = _get_test_battle_roster_hero_id(slot_id)
				fallback_count += 1
				print("[CONTEXT_SLOT_FALLBACK] battle_side=%s slot=%s reason=sample_or_crash_guard sample_hero=%s" % [
					context_side,
					slot_id,
					resolved_hero_id,
				])
			else:
				_deactivate_worldmap_context_slot(slot_id, context_side, city_id, city_name, city_owner_id)
				continue
		if resolved_hero_id == "":
			continue
		var resolved_hero_entry := _get_hero_registry_entry(resolved_hero_id)
		if _is_hero_entry_excluded_from_context_battle(resolved_hero_entry):
			var reason := _get_hero_entry_context_exclusion_reason(resolved_hero_entry)
			print("[CONTEXT_HERO_EXCLUDE] source=%s side=%s slot=%s hero=%s display_name=%s status=%s captured=%s reason=%s" % [
				str(context.get("source", "")),
				context_side,
				slot_id,
				resolved_hero_id,
				str(resolved_hero_entry.get("display_name", resolved_hero_id)),
				str(resolved_hero_entry.get("status", "normal")),
				str(bool(resolved_hero_entry.get("captured", false))),
				reason,
			])
			_deactivate_worldmap_context_slot(slot_id, context_side, city_id, city_name, city_owner_id)
			continue
		_set_capacity_slot_metadata_value(slot_id, "is_active", true)
		_set_capacity_slot_metadata_value(slot_id, "is_deployed", not slot_id.contains("_reinforce_"))
		assigned_hero_ids.append(resolved_hero_id)
		_set_capacity_slot_metadata_value(slot_id, "assigned_hero_id", resolved_hero_id)
		_set_capacity_slot_metadata_value(slot_id, "assigned_unit_id", "%s_battle_unit" % resolved_hero_id)
		_set_capacity_slot_metadata_value(slot_id, "source_city_id", city_id)
		_set_capacity_slot_metadata_value(slot_id, "source_city_name", city_name)
		_set_capacity_slot_metadata_value(slot_id, "source_owner", city_owner_id)
		_set_capacity_slot_metadata_value(slot_id, "dispatch_type", dispatch_type)
		_set_capacity_slot_metadata_value(slot_id, "worldmap_context_side", context_side)
		_set_capacity_slot_metadata_value(slot_id, "worldmap_source_hero_id", requested_hero_id)
		_apply_worldmap_context_hero_to_unit_state(slot_id, resolved_hero_id)
	return {
		"requested_hero_ids": requested_hero_ids,
		"assigned_hero_ids": assigned_hero_ids,
		"resolved_count": assigned_hero_ids.size(),
		"fallback_count": fallback_count,
		"city_id": city_id,
		"city_name": city_name,
		"owner": city_owner_id,
	}


func _deactivate_worldmap_context_slot(slot_id: String, context_side: String, city_id: String, city_name: String, city_owner_id: String) -> void:
	_set_capacity_slot_metadata_value(slot_id, "is_active", false)
	_set_capacity_slot_metadata_value(slot_id, "is_deployed", false)
	_set_capacity_slot_metadata_value(slot_id, "entry_rule", "")
	_set_capacity_slot_metadata_value(slot_id, "assigned_hero_id", "")
	_set_capacity_slot_metadata_value(slot_id, "assigned_unit_id", "")
	_set_capacity_slot_metadata_value(slot_id, "source_city_id", city_id)
	_set_capacity_slot_metadata_value(slot_id, "source_city_name", city_name)
	_set_capacity_slot_metadata_value(slot_id, "source_owner", city_owner_id)
	_set_capacity_slot_metadata_value(slot_id, "dispatch_type", "no_reinforcement")
	_set_capacity_slot_metadata_value(slot_id, "worldmap_context_side", context_side)
	_set_capacity_slot_metadata_value(slot_id, "worldmap_context_empty", true)
	var unit_state := _get_unit_state_for_capacity_slot_id(slot_id)
	if unit_state != null:
		_set_unit_visual_group_visible(unit_state, false)
		_set_unit_click_area_enabled(unit_state, false)
	print("[REINFORCE_SKIP] battle_side=%s slot=%s city=%s reason=no_eligible_context_hero" % [
		context_side,
		slot_id,
		city_id,
	])


func _get_context_hero_ids_for_side(context: Dictionary, context_side: String) -> Array[String]:
	var hero_ids: Array[String] = []
	var seen := {}
	var governor_id := str(context.get("%s_governor_id" % context_side, ""))
	_append_unique_context_hero_id(hero_ids, seen, governor_id)
	var raw_heroes: Variant = context.get("%s_heroes" % context_side, [])
	if raw_heroes is Array:
		for raw_hero in raw_heroes:
			if raw_hero is Dictionary:
				_append_unique_context_hero_id(hero_ids, seen, str((raw_hero as Dictionary).get("hero_id", "")))
	var raw_hero_ids: Variant = context.get("%s_hero_ids" % context_side, [])
	if raw_hero_ids is Array:
		for raw_hero_id in raw_hero_ids:
			_append_unique_context_hero_id(hero_ids, seen, str(raw_hero_id))
	return hero_ids


func _is_worldmap_invasion_context_for_roster(context: Dictionary) -> bool:
	var source := str(context.get("source", ""))
	if source == "enemy_invasion" or source == "enemy_invasion_mvp":
		return true
	if source.contains("enemy_invasion"):
		return true
	return str(context.get("attacker_city_id", "")) != "" or str(context.get("defender_city_id", "")) != ""


func _allows_sample_roster_crash_guard(context: Dictionary) -> bool:
	if str(context.get("attacker_city_id", "")) != "" or str(context.get("defender_city_id", "")) != "":
		return false
	return _get_context_hero_ids_for_side(context, "attacker").is_empty() and _get_context_hero_ids_for_side(context, "defender").is_empty()


func _register_worldmap_context_hero_contracts(context: Dictionary) -> void:
	worldmap_context_hero_registry.clear()
	worldmap_context_unique_skill_registry.clear()
	for context_side in ["defender", "attacker"]:
		var raw_heroes: Variant = context.get("%s_heroes" % context_side, [])
		if not raw_heroes is Array:
			continue
		for raw_hero in raw_heroes:
			if not raw_hero is Dictionary:
				continue
			var hero_data := (raw_hero as Dictionary).duplicate(true)
			var source_hero_id := str(hero_data.get("hero_id", ""))
			if source_hero_id.is_empty():
				continue
			var resolved_hero_id := str(WORLDMAP_CONTEXT_HERO_ID_COMPATIBILITY.get(source_hero_id, source_hero_id))
			var registry_entry := _build_worldmap_context_hero_registry_entry(hero_data)
			var skill_entry := _build_worldmap_context_unique_skill_entry(hero_data)
			worldmap_context_hero_registry[source_hero_id] = registry_entry
			worldmap_context_hero_registry[resolved_hero_id] = registry_entry
			worldmap_context_unique_skill_registry[source_hero_id] = skill_entry
			worldmap_context_unique_skill_registry[resolved_hero_id] = skill_entry
			print("[WORLD_CONTEXT_HERO] hero=%s resolved=%s portrait=%s skill=%s" % [
				source_hero_id,
				resolved_hero_id,
				String(registry_entry.get("battlefield_portrait_path", "")).get_file(),
				String(skill_entry.get("name", "")),
			])


func _build_worldmap_context_hero_registry_entry(hero_data: Dictionary) -> Dictionary:
	var portrait_path := str(hero_data.get("portrait_path", ""))
	var safe_portrait_path := _resolve_hero_portrait_path(hero_data)
	return {
		"hero_id": str(hero_data.get("hero_id", "")),
		"display_name": str(hero_data.get("display_name", hero_data.get("name", hero_data.get("hero_id", "")))),
		"portrait_path": portrait_path,
		"battlefield_portrait_path": safe_portrait_path,
		"closeup_portrait_path": safe_portrait_path,
		"default_visual_key": _get_default_visual_key_for_worldmap_hero(hero_data),
		"status": str(hero_data.get("status", "normal")),
		"wounded": bool(hero_data.get("wounded", false)),
		"captured": bool(hero_data.get("captured", false)),
		"dead": bool(hero_data.get("dead", false)),
		"wounded_turns_remaining": maxi(0, int(hero_data.get("wounded_turns_remaining", 0))),
		"troops": maxi(0, int(hero_data.get("troops", hero_data.get("troop_count", 0)))),
		"max_troops": maxi(0, int(hero_data.get("max_troops", hero_data.get("troops", hero_data.get("troop_count", 0))))),
		"allocated_troops": maxi(0, int(hero_data.get("allocated_troops", 0))),
		"initial_allocated_troops": maxi(0, int(hero_data.get("initial_allocated_troops", hero_data.get("allocated_troops", 0)))),
	}


func _build_worldmap_context_unique_skill_entry(hero_data: Dictionary) -> Dictionary:
	var sample_skill_entry := _get_sample_unique_skill_entry_for_worldmap_hero(hero_data)
	var battle_effect_type := str(hero_data.get("battle_effect_type", "ally_attack_buff"))
	if battle_effect_type == "ally_attack_buff" and not sample_skill_entry.is_empty():
		battle_effect_type = str(sample_skill_entry.get("effect_type", battle_effect_type))
	var cutin_path := _get_existing_resource_path(str(hero_data.get("cutin_path", "")))
	if cutin_path == "" and not sample_skill_entry.is_empty():
		cutin_path = _get_existing_resource_path(str(sample_skill_entry.get("cutin_image_path", "")))
	var skill_name := _resolve_worldmap_context_skill_name(hero_data, sample_skill_entry)
	return {
		"skill_id": str(hero_data.get("skill_id", hero_data.get("unique_skill_id", ""))),
		"hero_id": str(hero_data.get("hero_id", "")),
		"name": skill_name,
		"toast_text": "%s!" % skill_name,
		"description": str(hero_data.get("skill_desc", "")),
		"effect_type": battle_effect_type,
		"power": int(hero_data.get("skill_power", hero_data.get("skill_value", sample_skill_entry.get("power", UNIQUE_SKILL_ATTACK_BUFF)))),
		"range": maxi(0, int(hero_data.get("skill_range", UNIQUE_SKILL_DEFAULT_RANGE))),
		"cutin_image_path": cutin_path,
		"target_mode": _get_target_mode_for_worldmap_skill_effect(battle_effect_type),
		"consumes_action": true,
		"cooldown_turns": maxi(0, int(hero_data.get("skill_cooldown", 0))),
		"unique": true,
	}


func _get_sample_unique_skill_entry_for_worldmap_hero(hero_data: Dictionary) -> Dictionary:
	var source_hero_id := str(hero_data.get("hero_id", ""))
	var resolved_hero_id := str(WORLDMAP_CONTEXT_HERO_ID_COMPATIBILITY.get(source_hero_id, source_hero_id))
	if UNIQUE_SKILL_REGISTRY.has(resolved_hero_id):
		return UNIQUE_SKILL_REGISTRY.get(resolved_hero_id, {})
	if UNIQUE_SKILL_REGISTRY.has(source_hero_id):
		return UNIQUE_SKILL_REGISTRY.get(source_hero_id, {})
	return {}


func _resolve_worldmap_context_skill_name(hero_data: Dictionary, sample_skill_entry: Dictionary) -> String:
	var explicit_skill_name := str(hero_data.get("skill_name", ""))
	var display_name := str(hero_data.get("display_name", hero_data.get("name", "장수")))
	if explicit_skill_name != "" and explicit_skill_name != "%s 전법" % display_name:
		return explicit_skill_name
	var sample_skill_name := str(sample_skill_entry.get("name", ""))
	if sample_skill_name != "":
		return sample_skill_name
	if explicit_skill_name != "":
		return explicit_skill_name
	return "%s 전법" % display_name


func _get_existing_resource_path(path: String) -> String:
	if path.is_empty():
		return ""
	return path if ResourceLoader.exists(path) else ""


func _resolve_hero_portrait_path(hero_data: Dictionary) -> String:
	for key in ["portrait_path", "battlefield_portrait_path", "closeup_portrait_path"]:
		var portrait_path := String(hero_data.get(key, ""))
		if portrait_path != "" and ResourceLoader.exists(portrait_path):
			return portrait_path
	if ResourceLoader.exists(UNKNOWN_HERO_PORTRAIT_FALLBACK_PATH):
		return UNKNOWN_HERO_PORTRAIT_FALLBACK_PATH
	return ""


func _resolve_hero_portrait_texture(hero_data: Dictionary) -> Texture2D:
	return _load_texture_or_null(_resolve_hero_portrait_path(hero_data))


func _apply_battle_portrait_texture_to_sprite(sprite: Sprite2D, texture: Texture2D) -> void:
	if sprite == null or texture == null:
		return
	sprite.texture = texture
	var max_dimension := maxf(float(texture.get_width()), float(texture.get_height()))
	if max_dimension > 0.0:
		var scale_ratio := BATTLEFIELD_PORTRAIT_BADGE_SIZE / max_dimension
		sprite.scale = Vector2.ONE * scale_ratio


func _get_default_visual_key_for_worldmap_hero(hero_data: Dictionary) -> String:
	var unit_type := str(hero_data.get("unit_type", "infantry"))
	var faction_id := str(hero_data.get("faction_id", hero_data.get("nation", "")))
	var region_key := "china"
	if faction_id in ["player", "goryeo_joseon", "goguryeo", "silla", "baekje_faction"]:
		region_key = "korea"
	elif faction_id in ["oda", "toyotomi", "kyushu_faction", "tokugawa"]:
		region_key = "japan"
	elif faction_id == "mongol_faction":
		region_key = "china"
	match unit_type:
		"archer":
			return "%s_archer" % region_key
		"cavalry":
			return "%s_cavalry" % region_key
		"support":
			return "%s_gunner" % region_key
		_:
			return "%s_infantry" % region_key


func _get_target_mode_for_worldmap_skill_effect(effect_type: String) -> String:
	match effect_type:
		"ally_attack_buff":
			return "ally_all"
		"cannon_aoe":
			return "enemy_auto_aoe"
		_:
			return "enemy_auto_single"


func _append_unique_context_hero_id(hero_ids: Array[String], seen: Dictionary, hero_id: String) -> void:
	if hero_id == "":
		return
	if seen.has(hero_id):
		return
	seen[hero_id] = true
	hero_ids.append(hero_id)


func _resolve_worldmap_context_hero_id(worldmap_hero_id: String) -> String:
	if worldmap_hero_id == "":
		return ""
	var resolved_hero_id := str(WORLDMAP_CONTEXT_HERO_ID_COMPATIBILITY.get(worldmap_hero_id, worldmap_hero_id))
	if HERO_REGISTRY.has(resolved_hero_id):
		return resolved_hero_id
	if worldmap_context_hero_registry.has(resolved_hero_id):
		return resolved_hero_id
	if worldmap_context_hero_registry.has(worldmap_hero_id):
		return worldmap_hero_id
	return ""


func _apply_worldmap_context_hero_to_unit_state(slot_id: String, hero_id: String) -> void:
	if slot_id == "" or hero_id == "":
		return
	var unit_state := _get_unit_state_for_capacity_slot_id(slot_id)
	if unit_state == null:
		return
	unit_state.unit_id = "%s_battle_unit" % hero_id
	_apply_hero_identity_to_unit(unit_state)


func _process(_delta: float) -> void:
	if current_phase == PHASE_ALLY_TURN and not is_demo_animating:
		_refresh_move_target_feedback()
	if combat_camera_tween != null:
		_refresh_camera_bound_world_overlays()
	_update_ally_ready_frames()
	_refresh_floating_ally_command_panel()
	_refresh_strategy_status_icon_labels()


func _get_main_camera_or_null() -> Camera2D:
	if main_camera != null:
		return main_camera
	return get_node_or_null("MainCamera") as Camera2D


func _configure_main_camera() -> void:
	var camera := _get_main_camera_or_null()
	if camera == null:
		return
	main_camera = camera
	camera.enabled = true
	camera.make_current()
	main_camera_scene_position = camera.position
	main_camera_scene_zoom = camera.zoom
	main_camera_base_position = camera.position
	main_camera_base_zoom = camera.zoom


func _reset_main_camera_to_scene_position() -> void:
	var camera := _get_main_camera_or_null()
	if camera == null:
		return
	if combat_camera_tween != null:
		combat_camera_tween.kill()
		combat_camera_tween = null
	camera.enabled = true
	camera.make_current()
	camera.position = main_camera_scene_position
	camera.zoom = main_camera_scene_zoom
	main_camera_base_position = main_camera_scene_position
	main_camera_base_zoom = main_camera_scene_zoom
	_refresh_camera_bound_world_overlays()


func _focus_camera_on_world_position(world_pos: Vector2, immediate: bool = false) -> void:
	if not COMBAT_CAMERA_FOCUS_ENABLED:
		return
	var camera := _get_main_camera_or_null()
	if camera == null:
		return
	var target_position := _clamp_camera_position_to_battlefield(world_pos)
	if combat_camera_tween != null:
		combat_camera_tween.kill()
		combat_camera_tween = null
	camera.enabled = true
	camera.make_current()
	if immediate or is_zero_approx(COMBAT_CAMERA_FOCUS_DURATION):
		camera.position = target_position
		_set_camera_focus_base_position(target_position)
		_refresh_camera_bound_world_overlays()
		call_deferred("_refresh_camera_bound_world_overlays")
		return
	combat_camera_tween = create_tween()
	combat_camera_tween.tween_method(_set_main_camera_position_for_focus, camera.position, target_position, COMBAT_CAMERA_FOCUS_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	combat_camera_tween.tween_callback(_set_camera_focus_base_position.bind(target_position))


func _focus_camera_on_unit(unit_state: BattleUnitState, immediate: bool = false) -> void:
	if unit_state == null:
		return
	_focus_camera_on_world_position(_get_camera_focus_position_for_unit(unit_state), immediate)


func _focus_camera_on_combat_pair(actor_state: BattleUnitState, target_state: BattleUnitState, immediate: bool = false) -> void:
	if actor_state == null and target_state == null:
		return
	if actor_state == null:
		_focus_camera_on_unit(target_state, immediate)
		return
	if target_state == null:
		_focus_camera_on_unit(actor_state, immediate)
		return
	var actor_position := _get_camera_focus_position_for_unit(actor_state)
	var target_position := _get_camera_focus_position_for_unit(target_state)
	_focus_camera_on_world_position((actor_position + target_position) * 0.5, immediate)


func _get_camera_focus_position_for_unit(unit_state: BattleUnitState) -> Vector2:
	if unit_state == null:
		return main_camera_base_position
	var anchor_position := _get_visual_anchor_position_for_unit(unit_state)
	if anchor_position != Vector2.ZERO:
		return anchor_position
	if battle_grid_controller != null:
		return battle_grid_controller.grid_to_world(unit_state.grid_cell)
	return main_camera_base_position


func _clamp_camera_position_to_battlefield(world_pos: Vector2) -> Vector2:
	var battlefield_rect := _get_battlefield_visual_world_rect()
	if battlefield_rect.size.x > 0.0 and battlefield_rect.size.y > 0.0:
		return _clamp_camera_position_to_world_rect(world_pos, battlefield_rect)
	if battle_grid_controller == null:
		return world_pos
	var board_top_left := battle_grid_controller.get_board_top_left()
	var board_bottom_right := battle_grid_controller.get_board_bottom_right()
	if board_top_left == Vector2.ZERO and board_bottom_right == Vector2.ZERO:
		return world_pos
	var min_x := minf(board_top_left.x, board_bottom_right.x) - COMBAT_CAMERA_CLAMP_PADDING
	var max_x := maxf(board_top_left.x, board_bottom_right.x) + COMBAT_CAMERA_CLAMP_PADDING
	var min_y := minf(board_top_left.y, board_bottom_right.y) - COMBAT_CAMERA_CLAMP_PADDING
	var max_y := maxf(board_top_left.y, board_bottom_right.y) + COMBAT_CAMERA_CLAMP_PADDING
	return Vector2(
		clampf(world_pos.x, min_x, max_x),
		clampf(world_pos.y, min_y, max_y)
	)


func _get_battlefield_visual_world_rect() -> Rect2:
	if battlefield_texture == null or battlefield_texture.texture == null:
		return Rect2()
	var texture_size := battlefield_texture.texture.get_size()
	var battlefield_global_scale := battlefield_texture.global_scale
	var visual_size := Vector2(
		texture_size.x * absf(battlefield_global_scale.x),
		texture_size.y * absf(battlefield_global_scale.y)
	)
	if visual_size.x <= 0.0 or visual_size.y <= 0.0:
		return Rect2()
	var top_left := battlefield_texture.global_position
	if battlefield_texture.centered:
		top_left -= visual_size * 0.5
	return Rect2(top_left, visual_size)


func _clamp_camera_position_to_world_rect(world_pos: Vector2, world_rect: Rect2) -> Vector2:
	var camera := _get_main_camera_or_null()
	var camera_zoom := Vector2.ONE
	if camera != null:
		camera_zoom = camera.zoom
	var viewport_size := get_viewport_rect().size
	var half_view := Vector2(
		viewport_size.x * 0.5 / maxf(0.001, absf(camera_zoom.x)),
		viewport_size.y * 0.5 / maxf(0.001, absf(camera_zoom.y))
	)
	var min_center := world_rect.position + half_view
	var max_center := world_rect.position + world_rect.size - half_view
	var clamped_x := world_pos.x
	var clamped_y := world_pos.y
	if min_center.x > max_center.x:
		clamped_x = world_rect.get_center().x
	else:
		clamped_x = clampf(world_pos.x, min_center.x, max_center.x)
	if min_center.y > max_center.y:
		clamped_y = world_rect.get_center().y
	else:
		clamped_y = clampf(world_pos.y, min_center.y, max_center.y)
	return Vector2(clamped_x, clamped_y)


func _set_camera_focus_base_position(world_pos: Vector2) -> void:
	main_camera_base_position = world_pos
	combat_camera_tween = null
	_refresh_camera_bound_world_overlays()
	call_deferred("_refresh_camera_bound_world_overlays")


func _set_main_camera_position_for_focus(world_pos: Vector2) -> void:
	var camera := _get_main_camera_or_null()
	if camera == null:
		return
	camera.position = world_pos
	_refresh_camera_bound_world_overlays()


func _refresh_camera_bound_world_overlays() -> void:
	_update_facing_indicators()
	if facing_arrow_panel != null and facing_arrow_panel.visible:
		_position_facing_arrow_panel_near_ally()
	_update_ally_ready_frames()
	_refresh_floating_ally_command_panel()
	_refresh_strategy_status_icon_labels()


func _input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton):
		return

	var mouse_event := event as InputEventMouseButton
	if mouse_event.button_index == MOUSE_BUTTON_RIGHT and mouse_event.pressed:
		_handle_right_click_cancel()
		get_viewport().set_input_as_handled()
		return
	if mouse_event.button_index != MOUSE_BUTTON_LEFT or not mouse_event.pressed:
		return
	if _is_mouse_over_battle_ui():
		return
	if is_demo_animating or ally_unit_state == null:
		return

	var mouse_world_pos := get_global_mouse_position()
	if current_phase == PHASE_STRATEGY_SELECT:
		var clicked_strategy_target := _get_strategy_clicked_target_at_position(mouse_world_pos)
		if clicked_strategy_target != null:
			_try_use_strategy_on_target(clicked_strategy_target)
			get_viewport().set_input_as_handled()
			return

		_append_battle_log("책략 대상이 되는 적을 선택하세요")
		get_viewport().set_input_as_handled()
		return

	if current_phase == PHASE_UNIQUE_SKILL_TARGET_SELECT:
		var clicked_unique_target := _get_unique_skill_clicked_target_at_position(mouse_world_pos)
		if clicked_unique_target != null:
			_try_use_unique_skill_on_target(clicked_unique_target)
			get_viewport().set_input_as_handled()
			return

		_append_battle_log("고유특기 대상을 선택하세요")
		get_viewport().set_input_as_handled()
		return

	if current_phase == PHASE_ATTACK_SELECT:
		var clicked_enemy_target := _get_clicked_enemy_unit_at_position(mouse_world_pos)
		if _is_enemy_click_candidate_alive(clicked_enemy_target):
			_try_attack_enemy_target_from_attack_select(clicked_enemy_target)
			get_viewport().set_input_as_handled()
			return

		_append_battle_log("공격 대상을 선택하세요")
		get_viewport().set_input_as_handled()
		return

	if current_phase != PHASE_ALLY_TURN and current_phase != PHASE_UNIQUE_SKILL_TARGET_SELECT:
		return
	if _is_battle_result_finalized():
		return

	if _try_handle_valid_move_cell_click(mouse_world_pos):
		get_viewport().set_input_as_handled()
		return

	var clicked_ally_unit := _get_clicked_ally_unit_at_position(mouse_world_pos)
	if clicked_ally_unit != null:
		_select_ally_unit(clicked_ally_unit, true, true, false)
		get_viewport().set_input_as_handled()
		return

	var clicked_enemy_unit := _get_clicked_enemy_unit_at_position(mouse_world_pos)
	if _is_enemy_click_candidate_alive(clicked_enemy_unit):
		_select_enemy_attack_target(clicked_enemy_unit)
		get_viewport().set_input_as_handled()
		return

	if active_unit_state == null or battle_grid_controller == null:
		return

	var target_cell := battle_grid_controller.world_to_grid(mouse_world_pos)
	if not battle_grid_controller.is_in_bounds(target_cell):
		return

	var origin_cell := get_active_move_origin_cell()
	var distance := battle_grid_controller.get_distance(origin_cell, target_cell)
	var move_range := get_active_move_range()
	var is_occupied := is_cell_occupied(target_cell)
	var is_valid_target := is_valid_move_target(target_cell)
	print("Move target selected: %s occupied=%s VALID=%s distance=%d range=%d" % [
		_format_cell(target_cell),
		str(is_occupied),
		str(is_valid_target),
		distance,
		move_range,
	])
	if not is_valid_target:
		has_selected_move_target = false
		move_highlight.visible = false
		_append_battle_log("이동 불가")
		get_viewport().set_input_as_handled()
		return

	if _try_direct_move_to_cell(target_cell):
		get_viewport().set_input_as_handled()
		return

	set_move_target_cell(target_cell)
	get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT or mouse_event.button_index == MOUSE_BUTTON_RIGHT:
			return


func show_cutin() -> void:
	_sync_overlay_positions()
	cutin_overlay.visible = true
	result_overlay.visible = false


func hide_cutin() -> void:
	cutin_overlay.visible = false


func show_result() -> void:
	_sync_overlay_positions()
	result_overlay.visible = true
	cutin_overlay.visible = false


func hide_result() -> void:
	result_overlay.visible = false


func _configure_worldmap_result_return_button() -> void:
	if battle_ui == null or worldmap_return_button != null:
		return
	worldmap_return_button = Button.new()
	worldmap_return_button.name = "WorldMapResultReturnButton"
	worldmap_return_button.text = "월드맵으로 돌아가기"
	worldmap_return_button.visible = false
	worldmap_return_button.custom_minimum_size = Vector2(220.0, 42.0)
	worldmap_return_button.anchor_left = 0.5
	worldmap_return_button.anchor_right = 0.5
	worldmap_return_button.anchor_top = 1.0
	worldmap_return_button.anchor_bottom = 1.0
	worldmap_return_button.offset_left = -110.0
	worldmap_return_button.offset_right = 110.0
	worldmap_return_button.offset_top = -138.0
	worldmap_return_button.offset_bottom = -96.0
	worldmap_return_button.mouse_filter = Control.MOUSE_FILTER_STOP
	worldmap_return_button.tooltip_text = "전투 결과를 월드맵으로 전달합니다."
	worldmap_return_button.pressed.connect(_on_worldmap_result_return_pressed)
	battle_ui.add_child(worldmap_return_button)


func _refresh_worldmap_result_return_button() -> void:
	if worldmap_return_button == null:
		return
	var can_return := _has_worldmap_battle_context() and _is_battle_result_finalized()
	worldmap_return_button.visible = can_return
	worldmap_return_button.disabled = not can_return
	if can_return:
		var result_label := "승리" if _get_battle_result_state() == "victory" else "패배"
		worldmap_return_button.text = "월드맵으로 돌아가기 · %s" % result_label


func _has_worldmap_battle_context() -> bool:
	return not worldmap_battle_context.is_empty()


func _on_worldmap_result_return_pressed() -> void:
	_return_to_worldmap_with_result()


func _return_to_worldmap_with_result() -> void:
	if not _has_worldmap_battle_context():
		_append_battle_log("월드맵 전투 데이터 없음")
		_refresh_worldmap_result_return_button()
		return
	var battle_result_state := _get_battle_result_state()
	if battle_result_state == "":
		_append_battle_log("전투가 아직 종료되지 않았습니다.")
		_refresh_worldmap_result_return_button()
		return
	var result_payload := _build_worldmap_battle_result_payload(battle_result_state)
	if result_payload.is_empty():
		_append_battle_log("월드맵 결과 데이터 생성 실패")
		return
	Engine.set_meta(WORLDMAP_BATTLE_RESULT_META_KEY, result_payload.duplicate(true))
	print("[Battle] WorldMap battle result prepared: %s" % str(result_payload))
	var transition_result := get_tree().change_scene_to_file(WORLDMAP_SCENE_PATH)
	if transition_result != OK:
		if Engine.has_meta(WORLDMAP_BATTLE_RESULT_META_KEY):
			Engine.remove_meta(WORLDMAP_BATTLE_RESULT_META_KEY)
		_append_battle_log("월드맵 복귀 실패")
		_refresh_worldmap_result_return_button()


func _build_worldmap_battle_result_payload(battle_result_state: String) -> Dictionary:
	if worldmap_battle_context.is_empty():
		return {}
	var result := "victory" if battle_result_state == "victory" else "defeat"
	var is_player_attack := _is_worldmap_player_attack_context(worldmap_battle_context)
	var winner := "attacker" if is_player_attack and result == "victory" else "defender"
	if not is_player_attack:
		winner = "defender" if result == "victory" else "attacker"
	var result_type := "attack_result" if is_player_attack else "defense_result"
	var attacker_battle_side := "ally" if is_player_attack else "enemy"
	var defender_battle_side := "enemy" if is_player_attack else "ally"
	var payload := {
		"source": str(worldmap_battle_context.get("source", "enemy_invasion")),
		"type": result_type,
		"mode": str(worldmap_battle_context.get("mode", "manual")),
		"result": result,
		"winner": winner,
		"attacker_city_id": str(worldmap_battle_context.get("attacker_city_id", "")),
		"defender_city_id": str(worldmap_battle_context.get("defender_city_id", "")),
		"attacker_city_name": str(worldmap_battle_context.get("attacker_city_name", "알 수 없는 적 도시")),
		"defender_city_name": str(worldmap_battle_context.get("defender_city_name", "알 수 없는 아군 도시")),
		"attacker_owner": str(worldmap_battle_context.get("attacker_owner", "")),
		"defender_owner": str(worldmap_battle_context.get("defender_owner", "")),
		"attacker_troops": maxi(0, int(worldmap_battle_context.get("attacker_troops", 0))),
		"defender_troops": maxi(0, int(worldmap_battle_context.get("defender_troops", 0))),
		"attacker_surviving_troops": _sum_alive_deployed_troops_for_side(attacker_battle_side),
		"defender_surviving_troops": _sum_alive_deployed_troops_for_side(defender_battle_side),
		"attacker_total_allocated_troops": maxi(0, int(worldmap_battle_context.get("attacker_total_allocated_troops", worldmap_battle_context.get("attacker_troops", 0)))),
		"defender_total_allocated_troops": maxi(0, int(worldmap_battle_context.get("defender_total_allocated_troops", worldmap_battle_context.get("defender_troops", 0)))),
		"attacker_troop_allocation": worldmap_battle_context.get("attacker_troop_allocation", {}),
		"defender_troop_allocation": worldmap_battle_context.get("defender_troop_allocation", {}),
		"attacker_source_city_id": str(worldmap_battle_context.get("attacker_source_city_id", worldmap_battle_context.get("attacker_city_id", ""))),
		"defender_source_city_id": str(worldmap_battle_context.get("defender_source_city_id", worldmap_battle_context.get("defender_city_id", ""))),
		"attacker_source_city_troops_before": maxi(0, int(worldmap_battle_context.get("attacker_source_city_troops_before", 0))),
		"attacker_source_city_troops_after": maxi(0, int(worldmap_battle_context.get("attacker_source_city_troops_after", 0))),
		"defender_source_city_troops_before": maxi(0, int(worldmap_battle_context.get("defender_source_city_troops_before", 0))),
		"defender_source_city_troops_after": maxi(0, int(worldmap_battle_context.get("defender_source_city_troops_after", 0))),
		"troop_deployed_from_city": bool(worldmap_battle_context.get("troop_deployed_from_city", false)),
		"attacker_troop_deployed_from_city": bool(worldmap_battle_context.get("attacker_troop_deployed_from_city", false)),
		"defender_troop_deployed_from_city": bool(worldmap_battle_context.get("defender_troop_deployed_from_city", false)),
		"turn_number": int(worldmap_battle_context.get("turn_number", 0)),
	}
	if is_player_attack:
		var player_did_win := result == "victory"
		payload["player_troop_outcome"] = _calculate_player_attack_troop_outcome_from_units(attacker_battle_side, worldmap_battle_context.get("attacker_troop_allocation", {}), player_did_win, str(payload.get("attacker_source_city_id", "")))
		payload["enemy_troop_outcome"] = _calculate_player_attack_troop_outcome_from_units(defender_battle_side, worldmap_battle_context.get("defender_troop_allocation", {}), not player_did_win, str(payload.get("defender_source_city_id", "")))
	else:
		var player_defender_did_win := result == "victory"
		payload["player_troop_outcome"] = _calculate_player_attack_troop_outcome_from_units(defender_battle_side, worldmap_battle_context.get("defender_troop_allocation", {}), player_defender_did_win, str(payload.get("defender_source_city_id", "")))
		payload["enemy_troop_outcome"] = _calculate_player_attack_troop_outcome_from_units(attacker_battle_side, worldmap_battle_context.get("attacker_troop_allocation", {}), not player_defender_did_win, str(payload.get("attacker_source_city_id", "")))
	return payload


func _sum_alive_deployed_troops_for_side(side: String) -> int:
	var total := 0
	for unit_state in _get_alive_deployed_unit_states_for_side(side):
		total += maxi(0, int(unit_state.current_troops))
	return total


func _calculate_unit_surviving_allocated_troops(unit_state: BattleUnitState) -> int:
	if unit_state == null:
		return 0
	var initial_troops := maxi(0, int(unit_state.initial_allocated_troops if unit_state.initial_allocated_troops > 0 else unit_state.allocated_troops))
	if initial_troops <= 0:
		return 0
	if unit_state.current_hp <= 0:
		return 0
	var max_hp := maxf(1.0, float(unit_state.max_hp))
	var survival_ratio := clampf(float(unit_state.current_hp) / max_hp, 0.0, 1.0)
	return mini(initial_troops, int(floor(float(initial_troops) * survival_ratio)))


func _calculate_player_attack_troop_outcome_from_units(side: String, allocation_source: Variant, did_side_win: bool, source_city_id: String) -> Dictionary:
	var allocation := {}
	if allocation_source is Dictionary:
		allocation = (allocation_source as Dictionary).duplicate(true)
	var allocated := 0
	for hero_id_variant in allocation.keys():
		allocated += maxi(0, int(allocation.get(hero_id_variant, 0)))
	var raw_survivors := 0
	var survivor_allocations := {}
	for unit_state in _get_deployed_unit_states_for_side(side):
		var hero_id := _get_hero_id_for_unit_state(unit_state)
		if hero_id == "" or not allocation.has(hero_id):
			continue
		var unit_survivors := _calculate_unit_surviving_allocated_troops(unit_state)
		survivor_allocations[hero_id] = unit_survivors
		raw_survivors += unit_survivors
	var survivors := mini(allocated, raw_survivors) if did_side_win else 0
	var losses := maxi(0, allocated - survivors)
	var wounded := int(floor(float(losses) * 0.30)) if did_side_win else int(floor(float(allocated) * 0.50))
	wounded = clampi(wounded, 0, allocated)
	var dead := maxi(0, allocated - survivors - wounded)
	return {
		"source_city_id": source_city_id,
		"allocated": allocated,
		"survivors": survivors,
		"losses": losses,
		"wounded": wounded,
		"dead": dead,
		"allocations": allocation,
		"survivor_allocations": survivor_allocations,
	}


func reset_demo_state() -> void:
	is_demo_animating = false
	ally_has_moved = false
	has_applied_worldmap_context_roster = false
	worldmap_context_roster_summary = {}
	worldmap_context_hero_registry.clear()
	worldmap_context_unique_skill_registry.clear()
	_refresh_worldmap_result_return_button()
	battle_round = 1
	dead_unit_ids.clear()
	unique_skill_cooldowns_by_hero_id.clear()
	unique_skill_attack_buff_turns_by_unit_id.clear()
	unique_skill_attack_buff_bonus_by_unit_id.clear()
	unique_skill_defense_buff_bonus_by_unit_id.clear()
	has_deployed_reinforce_01 = false
	has_deployed_reinforce_02 = false
	_build_capacity_slot_metadata_registry()
	_sync_deployment_markers_from_scene_visual_anchors()
	_hide_all_move_dust_sprites()
	_set_visual_template_token_sprite_visibility(false)
	acted_enemy_unit_ids.clear()
	_clear_enemy_ai_turn_reservations()
	ally_has_manual_facing = false
	enemy_has_manual_facing = false
	has_selected_move_target = false
	selected_move_cell = Vector2i(-1, -1)
	selected_attack_target_state = null
	selected_attack_target_side = ""
	_clear_pending_move_snapshot()
	_stop_idle_breathing()
	if round_toast_tween != null:
		round_toast_tween.kill()
		round_toast_tween = null
	if unique_skill_toast_tween != null:
		unique_skill_toast_tween.kill()
		unique_skill_toast_tween = null
	if specialty_skill_cutin_tween != null:
		specialty_skill_cutin_tween.kill()
		specialty_skill_cutin_tween = null
	_hide_specialty_skill_cutin()
	if defeat_retreat_toast_tween != null:
		defeat_retreat_toast_tween.kill()
		defeat_retreat_toast_tween = null
	if camera_shake_tween != null:
		camera_shake_tween.kill()
		camera_shake_tween = null
	_reset_main_camera_to_scene_position()
	is_unique_skill_presenting = false
	is_manual_unique_skill_preview_pending = false
	battle_toast_suppresses_facing_indicators = false
	unique_skill_toast_suppresses_facing_indicators = false
	facing_indicators_visible_before_toast = true
	_clear_unique_skill_targeting_state()
	_clear_strategy_targeting_state()
	_hide_strategy_range_overlay()
	_clear_strategy_status_icon_labels()
	is_defeat_retreat_toast_playing = false
	defeat_retreat_toast_queue.clear()
	shown_defeat_retreat_toast_unit_ids.clear()
	active_defeat_retreat_toast_started_msec = 0
	active_defeat_retreat_toast_display_name = ""
	active_defeat_retreat_toast_side = ""
	active_defeat_retreat_toast_hold_msec = 0
	pending_battle_toasts.clear()
	is_battle_toast_playing = false
	active_battle_toast_tag = ""
	has_battle_result_toast_shown = false
	has_logged_battle_end_guard = false
	roster_panel_slot_log_signatures.clear()
	enemy_ai_last_destination_debug.clear()
	_hide_round_start_toast()
	_hide_unique_skill_toast()
	_hide_enemy_retreat_toast()
	has_logged_hero_identity_validation = false
	battle_log_lines = [
		"아군 준비",
		"관우 방어",
	]
	current_ally_unit_position = ally_unit_marker.position
	current_ally_portrait_position = ally_portrait_marker.position
	_create_demo_unit_states()
	_rebuild_battle_unit_state_list_refs()
	_apply_all_hero_identities()
	_restore_enemy_main_portrait_bindings()
	_apply_all_hero_identities()
	_reset_ally_action_locks_for_new_round()
	_reset_enemy_action_locks_for_new_round()
	_sync_unit_state_cells_from_markers()
	_refresh_initial_unit_facing()
	_update_logical_grid_guide()
	_apply_melee_adjacent_qa_preset()
	_update_cell_size_visual_guide(ally_unit_state.grid_cell)
	print("GRID CELL SIZE: ", battle_grid_controller.get_cell_size())
	print("ALLY GRID: ", ally_unit_state.grid_cell, " ENEMY GRID: ", enemy_unit_state.grid_cell)
	_select_ally_unit(ally_unit_state, false, false, true)
	_set_phase(PHASE_ALLY_TURN)
	_sync_demo_positions()
	_sync_overlay_positions()
	_update_all_unit_visuals_from_state()
	_set_all_unit_group_modulates(Color.WHITE)
	for unit_state in _get_all_unit_states_in_slot_order():
		_restore_hp_troop_runtime_visibility_for_unit(unit_state)
	cutin_name_label.text = "학익진"
	cutin_quote_label.text = "사정거리 안 모든 적을 포격하라!"
	result_title_label.text = "승리"
	damage_text_layer.position = damage_spawn_marker.position
	damage_preview_label.text = "-%d" % int(DEMO_DAMAGE)
	damage_preview_label.visible = false
	damage_preview_label.modulate = Color(1.0, 0.55, 0.55, 1.0)
	damage_preview_label.position = Vector2.ZERO
	move_highlight.visible = false
	attack_highlight.visible = false
	_hide_attack_range_overlay()
	_hide_facing_selection_panel()
	_refresh_battle_log()
	_refresh_formation_slot_guides()
	cutin_overlay.visible = false
	result_overlay.visible = false
	_refresh_move_target_feedback()
	_show_move_range_overlay_for_active_unit()
	_set_facing_indicators_visible(true)
	_update_facing_indicators()
	_show_unit_closeup_for_ally(active_unit_state)
	_focus_camera_on_unit(active_unit_state, true)
	_update_ally_ready_frames()
	_debug_print_battle_unit_state_list_adapter()
	_debug_print_hp_troop_runtime_visibility_summary()
	_start_idle_breathing()
	_hide_all_move_dust_sprites()
	_show_round_start_toast(battle_round)


func play_basic_move_demo() -> void:
	if is_demo_animating or current_phase != PHASE_ALLY_TURN:
		return
	if active_unit_state == null or active_unit_side != "ally":
		return
	if not _is_active_ally_action_available():
		_append_battle_log("이미 행동한 부대입니다")
		_set_phase(PHASE_ALLY_TURN)
		return
	if active_unit_state.has_moved:
		_append_battle_log("이미 이동한 부대입니다")
		_set_phase(PHASE_ALLY_TURN)
		return
	if not has_selected_move_target:
		move_highlight.visible = false
		_append_battle_log("이동 대상 없음")
		return

	var target_cell: Vector2i = _get_selected_move_target_cell()
	_refresh_move_target_feedback()
	if not _is_valid_destination_for_unit(target_cell, active_unit_state, true):
		_clear_move_target_selection()
		_append_battle_log("다른 부대가 있어 이동할 수 없습니다")
		return
	if not is_valid_move_target(target_cell):
		_clear_move_target_selection()
		_append_battle_log("이동 불가")
		return

	var start_cell := active_unit_state.grid_cell
	var move_path := _find_ally_move_path(start_cell, target_cell)
	if move_path.is_empty() or move_path.size() < 2 or not _is_path_clear_for_unit(move_path, active_unit_state, true):
		is_demo_animating = false
		_set_phase(PHASE_ALLY_TURN)
		_set_facing_indicators_visible(true)
		_refresh_move_target_feedback()
		_show_move_range_overlay_for_active_unit()
		_start_idle_breathing()
		_append_battle_log("이동 경로 없음")
		return

	_hide_move_range_overlay()
	_hide_attack_range_overlay()
	_store_pending_ally_move_snapshot()
	is_demo_animating = true
	ally_has_manual_facing = false
	_set_facing_indicators_visible(false)
	_set_phase(PHASE_RESOLVING)
	_stop_idle_breathing()
	_sync_demo_positions()
	_focus_camera_on_unit(active_unit_state)

	var target_unit_position := battle_grid_controller.grid_to_world(target_cell)
	var portrait_offset := _get_selected_ally_portrait_visual_offset()
	var target_portrait_position := target_unit_position + portrait_offset
	var selected_unit_marker := _get_selected_ally_unit_marker()
	var start_unit_position := Vector2.ZERO
	if selected_unit_marker != null:
		start_unit_position = selected_unit_marker.position
	_clear_move_target_selection()
	_show_move_dust_for_unit(active_unit_state)

	var tween := create_tween()
	var previous_offset := Vector2.ZERO
	var step_duration := 0.14
	for path_index in range(1, move_path.size()):
		var waypoint_world := battle_grid_controller.grid_to_world(move_path[path_index])
		var next_offset := waypoint_world - start_unit_position
		tween.tween_method(_apply_selected_ally_group_offset, previous_offset, next_offset, step_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		previous_offset = next_offset
	if move_path.size() - 1 > battle_grid_controller.get_distance(start_cell, target_cell):
		_append_battle_log("우회 이동")
	tween.tween_callback(_finish_basic_move_demo.bind(target_unit_position, target_portrait_position, target_cell))


func _finish_basic_move_demo(target_unit_position: Vector2, target_portrait_position: Vector2, target_cell: Vector2i) -> void:
	if _handle_battle_end_guard("ally_move_finish"):
		is_demo_animating = false
		print("[TURN_ADVANCE_BLOCKED] source=ally_move_finish reason=result_finalized")
		return
	_sync_selected_ally_markers_to_position(target_unit_position, target_portrait_position)
	active_unit_state.set_grid_cell(target_cell)
	_refresh_ally_facing_toward_enemy_if_not_manual()
	_debug_print_combat_distance("MOVE_FINISH")
	_update_cell_size_visual_guide(active_unit_state.grid_cell)
	print("ALLY MOVED grid_cell: ", active_unit_state.grid_cell, " target_cell: ", target_cell)
	active_unit_state.has_moved = true
	ally_has_moved = true
	_reset_unit_group_positions()
	_hide_move_range_overlay()
	_fade_out_move_dust_for_unit(active_unit_state)
	is_demo_animating = false
	_append_battle_log("%s 이동 완료" % _get_selected_ally_display_name())
	_focus_camera_on_unit(active_unit_state)
	if should_auto_select_facing_after_move and is_auto_action_in_progress:
		_enter_post_move_facing_selection()
		_select_auto_facing_after_move_for_active_ally()
		return
	_enter_post_move_facing_selection()


func try_basic_attack() -> void:
	if current_phase != PHASE_ALLY_TURN and current_phase != PHASE_UNIQUE_SKILL_TARGET_SELECT:
		return
	if is_demo_animating:
		return
	if active_unit_state == null:
		return
	if not _is_active_ally_action_available():
		_append_battle_log("이미 행동한 부대입니다")
		_set_phase(PHASE_ALLY_TURN)
		return

	_enter_attack_select_mode()


func _enter_attack_select_mode() -> void:
	if not _is_active_ally_action_available():
		_append_battle_log("이미 행동한 부대입니다")
		_set_phase(PHASE_ALLY_TURN)
		return
	_hide_facing_selection_panel()
	_clear_move_target_selection()
	_clear_attack_target_selection()
	_hide_move_range_overlay()
	_hide_floating_ally_command_panel_for_tactical_selection()
	_set_phase(PHASE_ATTACK_SELECT)
	_show_attack_range_overlay_for_active_unit()
	_append_battle_log("공격 대상 선택")


func _exit_attack_select_mode() -> void:
	_hide_attack_range_overlay()


func _is_enemy_target_in_active_attack_range(target_state: BattleUnitState) -> bool:
	return is_unit_in_attack_range(active_unit_state, target_state)


func _try_attack_enemy_target_from_attack_select(target_state: BattleUnitState) -> void:
	if current_phase != PHASE_ATTACK_SELECT:
		return
	if is_demo_animating:
		return
	if active_unit_state == null:
		return
	if target_state == null or not target_state.is_alive():
		_append_battle_log("공격 대상 없음")
		return

	var distance := get_unit_grid_distance(active_unit_state, target_state)
	print("ALLY BASIC ATTACK SELECT CHECK")
	print("ally grid: ", active_unit_state.grid_cell)
	print("target grid: ", target_state.grid_cell)
	print("dist: ", distance, " range: ", active_unit_state.attack_range)
	if not _is_enemy_target_in_active_attack_range(target_state):
		_append_battle_log("사거리 밖입니다")
		return

	selected_attack_target_state = target_state
	if target_state.side != "":
		selected_attack_target_side = target_state.side
	else:
		selected_attack_target_side = "enemy"
	_show_attack_target_feedback()
	_debug_print_combat_distance("TRY_BASIC_ATTACK_SELECT")
	_exit_attack_select_mode()
	play_basic_attack_demo()


func play_basic_attack_demo() -> void:
	if is_demo_animating or (current_phase != PHASE_ALLY_TURN and current_phase != PHASE_ATTACK_SELECT):
		return
	if selected_attack_target_state == null:
		return
	current_attack_animation_target_state = selected_attack_target_state

	is_demo_animating = true
	_hide_move_range_overlay()
	_hide_attack_range_overlay()
	_set_phase(PHASE_RESOLVING)
	_stop_idle_breathing()
	_sync_demo_positions()
	_focus_camera_on_combat_pair(active_unit_state, selected_attack_target_state)
	_hide_all_move_dust_sprites()
	move_highlight.visible = false
	damage_text_layer.position = damage_spawn_marker.position
	damage_preview_label.text = "-%d" % int(DEMO_DAMAGE)
	damage_preview_label.position = Vector2.ZERO
	damage_preview_label.modulate = Color(1.0, 0.55, 0.55, 1.0)
	damage_preview_label.visible = false

	var ally_start := Vector2.ZERO
	var selected_ally_unit_marker := _get_selected_ally_unit_marker()
	if selected_ally_unit_marker != null:
		ally_start = selected_ally_unit_marker.position
	var target_marker := _get_enemy_target_unit_marker(selected_attack_target_state)
	var enemy_start := Vector2.ZERO
	if target_marker != null:
		enemy_start = target_marker.position
	var direction := (enemy_start - ally_start).normalized()
	var ally_lunge_offset := direction * ATTACK_LUNGE_DISTANCE
	var enemy_recoil_offset := direction * 12.0

	var tween := create_tween()
	tween.tween_method(_apply_selected_ally_group_offset, Vector2.ZERO, ally_lunge_offset, 0.16).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.chain()
	tween.set_parallel(true)
	tween.tween_method(_apply_enemy_target_group_offset, Vector2.ZERO, enemy_recoil_offset, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_method(_set_enemy_target_group_modulate, Color.WHITE, Color(1.0, 0.45, 0.45, 1.0), 0.08)
	tween.chain()
	tween.tween_method(_apply_selected_ally_group_offset, ally_lunge_offset, Vector2.ZERO, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_method(_apply_enemy_target_group_offset, enemy_recoil_offset, Vector2.ZERO, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_method(_set_enemy_target_group_modulate, Color(1.0, 0.45, 0.45, 1.0), Color.WHITE, 0.18)
	tween.finished.connect(_finish_basic_attack_demo)

	_spawn_attack_slash_fx(ally_start, enemy_start)

	var attack_damage := _get_directional_attack_damage(int(DEMO_DAMAGE), active_unit_state, selected_attack_target_state, true, true)
	var attack_angle_type := _get_attack_angle_type(active_unit_state, selected_attack_target_state)
	selected_attack_target_state.apply_damage(attack_damage)
	_update_enemy_target_visuals_from_state(selected_attack_target_state)
	_spawn_hit_battle_dust_fx(enemy_start)
	_spawn_hit_spark_fx(enemy_start)
	_spawn_damage_number_fx(enemy_start, attack_damage)
	_show_defend_hit_reaction_if_needed(selected_attack_target_state)
	_append_battle_log("%s 공격" % _get_selected_ally_display_name())
	_append_attack_angle_log(attack_angle_type)
	_append_battle_log("%s 피해" % selected_attack_target_state.display_name)


func _sync_demo_positions() -> void:
	_reset_unit_group_positions()


func _reset_unit_group_positions() -> void:
	for unit_state in _get_all_unit_states_in_slot_order():
		_apply_group_offset_for_unit(unit_state, Vector2.ZERO)
	_sync_runtime_portrait_markers_to_visuals()
	_update_facing_indicators()


func _finish_basic_attack_demo() -> void:
	_reset_unit_group_positions()
	_hide_all_move_dust_sprites()
	_set_all_unit_group_modulates(Color.WHITE)
	current_attack_animation_target_state = null
	damage_preview_label.visible = false
	is_demo_animating = false
	_hide_move_range_overlay()
	_hide_attack_range_overlay()
	_hide_strategy_range_overlay()
	_clear_attack_target_selection()
	_clear_strategy_targeting_state()
	_clear_pending_move_snapshot()
	_clear_auto_action_flags()
	_mark_ally_unit_acted(active_unit_state)
	_show_unit_closeup_for_ally(active_unit_state)
	_update_ally_ready_frames()
	_cleanup_dead_units()
	if _handle_battle_end_guard("ally_attack_finish"):
		print("[TURN_ADVANCE_BLOCKED] source=ally_attack_finish reason=result_finalized")
		_set_phase(PHASE_ALLY_TURN)
		return
	_set_phase(PHASE_ENEMY_TURN)
	_append_battle_log("적군 턴")
	_play_enemy_turn_demo()


func _get_unique_skill_for_unit(unit_state: BattleUnitState) -> Dictionary:
	var hero_id := _get_hero_id_for_unit_state(unit_state)
	if hero_id == "":
		return {}
	if worldmap_context_unique_skill_registry.has(hero_id):
		return worldmap_context_unique_skill_registry.get(hero_id, {})
	if UNIQUE_SKILL_REGISTRY.has(hero_id):
		return UNIQUE_SKILL_REGISTRY.get(hero_id, {})
	return {}


func _can_use_unique_skill(unit_state: BattleUnitState) -> bool:
	if unit_state == null:
		return false
	if current_phase != PHASE_ALLY_TURN and current_phase != PHASE_UNIQUE_SKILL_TARGET_SELECT:
		return false
	if is_unique_skill_presenting:
		return false
	if is_demo_animating and not (unit_state.side == "enemy" and current_phase == PHASE_ENEMY_TURN):
		return false
	if active_unit_side != "ally" or unit_state.side != "ally":
		return false
	if unit_state != active_unit_state:
		return false
	if not unit_state.is_alive():
		return false
	if not _is_active_ally_action_available():
		return false
	if _get_unique_skill_remaining_cooldown_turns(unit_state) > 0:
		return false
	var skill_data := _get_unique_skill_for_unit(unit_state)
	if skill_data.is_empty():
		return false
	return _has_valid_unique_skill_action(unit_state, skill_data)


func _can_actor_use_unique_skill(unit_state: BattleUnitState) -> bool:
	if unit_state == null:
		return false
	if is_unique_skill_presenting:
		return false
	if is_demo_animating and not (unit_state.side == "enemy" and current_phase == PHASE_ENEMY_TURN):
		return false
	if not unit_state.is_alive():
		return false
	if unit_state.side == "ally":
		if _has_ally_unit_acted(unit_state):
			return false
	elif unit_state.side == "enemy":
		if _has_enemy_unit_acted(unit_state):
			return false
	else:
		return false
	if _get_unique_skill_remaining_cooldown_turns(unit_state) > 0:
		return false
	var skill_data := _get_unique_skill_for_unit(unit_state)
	if skill_data.is_empty():
		return false
	return _has_valid_unique_skill_action(unit_state, skill_data)


func _on_unique_skill_button_pressed() -> void:
	if not _can_use_unique_skill(active_unit_state):
		_append_battle_log("고유특기 사용 불가")
		_refresh_floating_ally_command_panel()
		return
	var skill_data := _get_unique_skill_for_unit(active_unit_state)
	if skill_data.is_empty():
		return
	_enter_unique_skill_target_select_mode(active_unit_state, skill_data)


func _enter_unique_skill_target_select_mode(caster_state: BattleUnitState, skill_data: Dictionary) -> void:
	if not _can_use_unique_skill(caster_state):
		_append_battle_log("고유특기 사용 불가")
		return
	_hide_facing_selection_panel()
	_clear_move_target_selection()
	_clear_attack_target_selection()
	unique_skill_targeting_caster_state = caster_state
	unique_skill_targeting_skill_data = skill_data.duplicate(true)
	is_manual_unique_skill_preview_pending = false
	_hide_floating_ally_command_panel_for_tactical_selection()
	_set_phase(PHASE_UNIQUE_SKILL_TARGET_SELECT)
	_show_unique_skill_range_overlay(caster_state, skill_data)
	var target_count := _get_unique_skill_valid_targets(caster_state, skill_data).size()
	if target_count <= 0:
		_append_battle_log("고유특기 유효 대상 없음")
	else:
		_append_battle_log("%s 대상 선택" % String(skill_data.get("name", "고유특기")))
		if _should_unique_skill_resolve_without_manual_target(skill_data):
			var target_state := _get_best_unique_skill_target_for_actor(caster_state, skill_data)
			_begin_manual_unique_skill_preview(caster_state, skill_data, target_state)


func _should_unique_skill_resolve_without_manual_target(skill_data: Dictionary) -> bool:
	return String(skill_data.get("effect_type", "")) == "ally_attack_buff"


func _begin_manual_unique_skill_preview(caster_state: BattleUnitState, skill_data: Dictionary, target_state: BattleUnitState) -> void:
	if caster_state == null or skill_data.is_empty() or target_state == null:
		return
	if not _is_valid_unique_skill_target(caster_state, skill_data, target_state):
		return
	is_manual_unique_skill_preview_pending = true
	is_demo_animating = true
	_refresh_floating_ally_command_panel()
	get_tree().create_timer(UNIQUE_SKILL_MANUAL_PREVIEW_DURATION).timeout.connect(
		_finish_manual_unique_skill_preview.bind(caster_state, skill_data, target_state),
		CONNECT_ONE_SHOT
	)


func _finish_manual_unique_skill_preview(caster_state: BattleUnitState, skill_data: Dictionary, target_state: BattleUnitState) -> void:
	if not is_manual_unique_skill_preview_pending:
		return
	if current_phase != PHASE_UNIQUE_SKILL_TARGET_SELECT:
		is_manual_unique_skill_preview_pending = false
		is_demo_animating = false
		return
	if caster_state == null or not caster_state.is_alive() or skill_data.is_empty():
		_cancel_unique_skill_target_select_mode()
		return
	if unique_skill_targeting_caster_state != caster_state:
		is_manual_unique_skill_preview_pending = false
		is_demo_animating = false
		return
	if not _is_valid_unique_skill_target(caster_state, skill_data, target_state):
		_cancel_unique_skill_target_select_mode()
		return
	selected_attack_target_state = target_state
	selected_attack_target_side = target_state.side
	is_manual_unique_skill_preview_pending = false
	is_demo_animating = false
	_hide_unique_skill_range_overlay()
	_clear_unique_skill_targeting_state()
	_begin_unique_skill_sequence(caster_state, skill_data)


func _cancel_unique_skill_target_select_mode() -> void:
	if current_phase != PHASE_UNIQUE_SKILL_TARGET_SELECT:
		return
	is_manual_unique_skill_preview_pending = false
	is_demo_animating = false
	_clear_unique_skill_targeting_state()
	_hide_unique_skill_range_overlay()
	_clear_transient_battle_highlights()
	is_floating_ally_command_panel_requested = true
	_set_phase(PHASE_ALLY_TURN)
	_append_battle_log("고유특기 취소")
	_refresh_move_target_feedback()
	_show_move_range_overlay_for_active_unit()


func _clear_unique_skill_targeting_state() -> void:
	unique_skill_targeting_caster_state = null
	unique_skill_targeting_skill_data = {}


func _on_strategy_button_pressed() -> void:
	if not _can_use_strategy(active_unit_state):
		if active_unit_state != null and active_unit_state.intelligence < STRATEGY_BASIC_INTELLIGENCE:
			_append_battle_log("지력이 부족해 책략을 펼칠 수 없습니다.")
		else:
			_append_battle_log("책략 사용 불가")
		_refresh_floating_ally_command_panel()
		return
	_enter_strategy_target_select_mode(active_unit_state)


func _enter_strategy_target_select_mode(caster_state: BattleUnitState) -> void:
	if not _can_use_strategy(caster_state):
		_append_battle_log("책략 사용 불가")
		return
	if _get_strategy_targets(caster_state).is_empty():
		_append_battle_log("책략 유효 대상 없음")
		return
	_hide_facing_selection_panel()
	_clear_move_target_selection()
	_clear_attack_target_selection()
	_hide_move_range_overlay()
	_hide_attack_range_overlay()
	_hide_unique_skill_range_overlay()
	strategy_targeting_caster_state = caster_state
	_hide_floating_ally_command_panel_for_tactical_selection()
	_set_phase(PHASE_STRATEGY_SELECT)
	_show_strategy_range_overlay(caster_state)
	_append_battle_log("책략 대상이 되는 적을 선택하세요.")
	_append_battle_log("우클릭하면 취소합니다.")


func _cancel_strategy_target_select_mode() -> void:
	if current_phase != PHASE_STRATEGY_SELECT:
		return
	_clear_strategy_targeting_state()
	_hide_strategy_range_overlay()
	_clear_transient_battle_highlights()
	is_floating_ally_command_panel_requested = true
	_set_phase(PHASE_ALLY_TURN)
	_append_battle_log("책략 취소")
	_refresh_move_target_feedback()
	_show_move_range_overlay_for_active_unit()


func _clear_strategy_targeting_state() -> void:
	strategy_targeting_caster_state = null


func _can_use_strategy(unit_state: BattleUnitState) -> bool:
	if unit_state == null:
		return false
	if current_phase != PHASE_ALLY_TURN and current_phase != PHASE_STRATEGY_SELECT:
		return false
	if is_demo_animating or is_full_auto_battle_enabled:
		return false
	if not unit_state.is_alive():
		return false
	if unit_state.side != "ally":
		return false
	if _has_ally_unit_acted(unit_state):
		return false
	if _is_unit_confused(unit_state):
		return false
	if unit_state.intelligence < STRATEGY_BASIC_INTELLIGENCE:
		return false
	return true


func _get_strategy_range(unit_state: BattleUnitState) -> int:
	if unit_state == null:
		return 0
	if unit_state.intelligence >= STRATEGY_MASTER_INTELLIGENCE:
		return 5
	if unit_state.intelligence >= STRATEGY_ADVANCED_INTELLIGENCE:
		return 4
	if unit_state.intelligence >= STRATEGY_BASIC_INTELLIGENCE:
		return 3
	return 0


func _get_strategy_tier(unit_state: BattleUnitState) -> String:
	if unit_state == null:
		return "none"
	if unit_state.intelligence >= STRATEGY_MASTER_INTELLIGENCE:
		return "master"
	if unit_state.intelligence >= STRATEGY_ADVANCED_INTELLIGENCE:
		return "advanced"
	if unit_state.intelligence >= STRATEGY_BASIC_INTELLIGENCE:
		return "basic"
	return "none"


func _get_strategy_outcome_pool(unit_state: BattleUnitState) -> Array[Dictionary]:
	var pool: Array[Dictionary] = []
	match _get_strategy_tier(unit_state):
		"master":
			pool.append({"status": STATUS_CONFUSION, "turns": 2})
			pool.append({"status": STATUS_SHAKE, "turns": 3})
		"advanced":
			pool.append({"status": STATUS_CONFUSION, "turns": 1})
			pool.append({"status": STATUS_SHAKE, "turns": 2})
		"basic":
			pool.append({"status": STATUS_SHAKE, "turns": 1})
	return pool


func _get_strategy_targets(caster_state: BattleUnitState) -> Array[BattleUnitState]:
	var targets: Array[BattleUnitState] = []
	if caster_state == null or not caster_state.is_alive():
		return targets
	var strategy_range := _get_strategy_range(caster_state)
	if strategy_range <= 0:
		return targets
	for unit_state in _get_alive_deployed_unit_states_for_side(_get_opposing_side(caster_state.side)):
		if get_unit_grid_distance(caster_state, unit_state) <= strategy_range:
			targets.append(unit_state)
	return targets


func _get_strategy_success_rate(caster_state: BattleUnitState, target_state: BattleUnitState) -> float:
	if caster_state == null or target_state == null:
		return STRATEGY_MIN_SUCCESS_RATE
	var rate := STRATEGY_BASE_SUCCESS_RATE + float(caster_state.intelligence - target_state.intelligence) * 0.01
	return clampf(rate, STRATEGY_MIN_SUCCESS_RATE, STRATEGY_MAX_SUCCESS_RATE)


func _roll_strategy_outcome(caster_state: BattleUnitState) -> Dictionary:
	var pool := _get_strategy_outcome_pool(caster_state)
	if pool.is_empty():
		return {}
	return pool[randi() % pool.size()].duplicate(true)


func _is_valid_strategy_target(caster_state: BattleUnitState, target_state: BattleUnitState) -> bool:
	if target_state == null or not target_state.is_alive():
		return false
	return _get_strategy_targets(caster_state).has(target_state)


func _get_strategy_clicked_target_at_position(mouse_world_pos: Vector2) -> BattleUnitState:
	if strategy_targeting_caster_state == null:
		return null
	var clicked_target := _get_clicked_enemy_unit_at_position(mouse_world_pos)
	if _is_valid_strategy_target(strategy_targeting_caster_state, clicked_target):
		return clicked_target
	return null


func _try_use_strategy_on_target(target_state: BattleUnitState) -> void:
	if current_phase != PHASE_STRATEGY_SELECT:
		return
	var caster_state := strategy_targeting_caster_state
	if not _can_use_strategy(caster_state):
		_cancel_strategy_target_select_mode()
		return
	if not _is_valid_strategy_target(caster_state, target_state):
		_append_battle_log("책략 대상이 아닙니다")
		return
	_resolve_strategy(caster_state, target_state)


func _resolve_strategy(caster_state: BattleUnitState, target_state: BattleUnitState) -> void:
	_hide_strategy_range_overlay()
	_clear_strategy_targeting_state()
	_clear_move_target_selection()
	_clear_attack_target_selection()
	is_floating_ally_command_panel_requested = false
	if floating_ally_command_panel != null:
		floating_ally_command_panel.visible = false
	_set_phase(PHASE_RESOLVING)
	_focus_camera_on_combat_pair(caster_state, target_state)
	_append_battle_log("%s이 책략을 펼쳤습니다." % caster_state.display_name)
	_spawn_strategy_text_fx(_get_visual_anchor_position_for_unit(caster_state), "책략!", STRATEGY_CAST_COLOR)

	var success_rate := _get_strategy_success_rate(caster_state, target_state)
	if randf() <= success_rate:
		var outcome := _roll_strategy_outcome(caster_state)
		var status_id := String(outcome.get("status", STATUS_SHAKE))
		var turns := maxi(int(outcome.get("turns", 1)), 1)
		target_state.apply_status_effect(status_id, turns)
		var status_name := _get_strategy_status_display_name(status_id)
		_spawn_strategy_text_fx(_get_visual_anchor_position_for_unit(target_state), "%s %d턴" % [status_name, turns], STRATEGY_EFFECT_COLOR)
		_append_battle_log("책략 성공! %s에게 %s %d턴!" % [target_state.display_name, status_name, turns])
	else:
		_spawn_strategy_text_fx(_get_visual_anchor_position_for_unit(target_state), "실패", STRATEGY_FAIL_COLOR)
		_append_battle_log("책략 실패!")

	_mark_ally_unit_acted(caster_state)
	_show_unit_closeup_for_ally(caster_state)
	_update_ally_ready_frames()
	_refresh_formation_slot_guides()
	_refresh_strategy_status_icon_labels()
	_cleanup_dead_units()
	if _is_battle_result_finalized():
		_set_phase(PHASE_ALLY_TURN)
		return
	_set_phase(PHASE_ENEMY_TURN)
	_append_battle_log("적군 턴")
	_play_enemy_turn_demo()


func _get_strategy_status_display_name(status_id: String) -> String:
	match status_id:
		STATUS_CONFUSION:
			return "혼란"
		STATUS_SHAKE:
			return "동요"
		_:
			return "상태"


func _is_unit_confused(unit_state: BattleUnitState) -> bool:
	return unit_state != null and unit_state.has_status_effect(STATUS_CONFUSION)


func _get_unit_status_display_entries(unit_state: BattleUnitState) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	if unit_state == null or not unit_state.is_alive():
		return entries
	if unit_state.has_status_effect(STATUS_CONFUSION):
		var turns := unit_state.get_status_turns(STATUS_CONFUSION)
		entries.append({
			"id": STATUS_CONFUSION,
			"badge": "◎%d" % turns,
			"summary": "혼란 %d턴 · 행동불가" % turns,
		})
	if unit_state.has_status_effect(STATUS_SHAKE):
		var turns := unit_state.get_status_turns(STATUS_SHAKE)
		entries.append({
			"id": STATUS_SHAKE,
			"badge": "⚠%d" % turns,
			"summary": ("⚠ 동요 %d턴 · 공/방 -10" % turns) + "%",
		})
	if unit_state.is_defending:
		entries.append({
			"id": "defend",
			"badge": "◆",
			"summary": "◆ 방어 태세",
		})
	var attack_buff_bonus := _get_unique_skill_attack_buff_bonus(unit_state)
	if attack_buff_bonus > 0:
		entries.append({
			"id": "unique_attack_buff",
			"badge": "▲",
			"summary": "▲ 공격+%d" % attack_buff_bonus,
		})
	var defense_buff_bonus := _get_unique_skill_defense_buff_bonus(unit_state)
	if defense_buff_bonus > 0:
		entries.append({
			"id": "unique_defense_buff",
			"badge": "◆",
			"summary": "◆ 방어+%d" % defense_buff_bonus,
		})
	return entries


func _get_unit_status_badge_text(unit_state: BattleUnitState) -> String:
	var badges := PackedStringArray()
	for entry in _get_unit_status_display_entries(unit_state):
		var badge := String(entry.get("badge", ""))
		if badge != "" and not badges.has(badge):
			badges.append(badge)
	if badges.is_empty():
		return ""
	return " ".join(badges)


func _get_unit_status_summary_text(unit_state: BattleUnitState) -> String:
	var summaries := PackedStringArray()
	for entry in _get_unit_status_display_entries(unit_state):
		var summary := String(entry.get("summary", ""))
		if summary != "":
			summaries.append(summary)
	if summaries.is_empty():
		return ""
	return " / ".join(summaries)


func _get_unit_status_summary_text_compact(unit_state: BattleUnitState) -> String:
	var summaries := PackedStringArray()
	for entry in _get_unit_status_display_entries(unit_state):
		var summary := String(entry.get("summary", ""))
		if summary != "":
			summaries.append(summary)
	if summaries.is_empty():
		return ""
	var overflow_count := summaries.size() - 1
	if overflow_count <= 0:
		return summaries[0]
	return "%s 외 %d" % [summaries[0], overflow_count]


func _get_status_display_color(status_id: String) -> Color:
	match status_id:
		"defend", "unique_defense_buff":
			return STATUS_BADGE_DEFENSE_COLOR
		"unique_attack_buff":
			return STATUS_BADGE_ATTACK_UP_COLOR
		"attack_down":
			return STATUS_BADGE_ATTACK_DOWN_COLOR
		"defense_down":
			return STATUS_BADGE_DEFENSE_DOWN_COLOR
		STATUS_CONFUSION:
			return STATUS_BADGE_CONFUSION_COLOR
		STATUS_SHAKE:
			return STATUS_BADGE_SHAKE_COLOR
		_:
			return STATUS_BADGE_COLOR


func _get_status_display_color_for_entry(entry: Dictionary) -> Color:
	return _get_status_display_color(String(entry.get("id", "")))


func _get_unit_status_summary_color(unit_state: BattleUnitState) -> Color:
	for entry in _get_unit_status_display_entries(unit_state):
		return _get_status_display_color_for_entry(entry)
	return FORMATION_STATUS_TEXT_COLOR


func _get_strategy_status_icon_text(unit_state: BattleUnitState) -> String:
	return _get_unit_status_badge_text(unit_state)


func _get_strategy_status_summary_text(unit_state: BattleUnitState) -> String:
	return _get_unit_status_summary_text(unit_state)


func _get_formation_status_summary_text(unit_state: BattleUnitState) -> String:
	return _get_unit_status_summary_text_compact(unit_state)


func _has_strategy_status_effect(unit_state: BattleUnitState, status_id: String) -> bool:
	return unit_state != null and unit_state.has_status_effect(status_id)


func _consume_strategy_status_after_unit_action(unit_state: BattleUnitState) -> void:
	if unit_state == null:
		return
	if unit_state.status_effects.is_empty():
		return
	unit_state.tick_status_effects()
	_refresh_formation_slot_guides()
	_refresh_strategy_status_icon_labels()


func _refresh_strategy_status_icon_labels() -> void:
	if battle_fx_root == null:
		return
	var alive_unit_ids: Dictionary = {}
	for unit_state in _get_all_alive_unit_states_from_adapter():
		if unit_state == null or unit_state.unit_id == "":
			continue
		alive_unit_ids[unit_state.unit_id] = true
		var status_entries := _get_unit_status_display_entries(unit_state)
		if status_entries.is_empty():
			_remove_strategy_status_icon_label(unit_state.unit_id)
			continue
		var badge_root := strategy_status_icon_labels_by_unit_id.get(unit_state.unit_id, null) as Control
		if badge_root == null or not is_instance_valid(badge_root):
			badge_root = _create_strategy_status_icon_label()
			strategy_status_icon_labels_by_unit_id[unit_state.unit_id] = badge_root
		_sync_strategy_status_icon_label_children(badge_root, status_entries)
		badge_root.position = battle_fx_root.to_local(_get_strategy_status_badge_position_for_unit(unit_state, badge_root.size))
		badge_root.visible = true
	for unit_id_key in strategy_status_icon_labels_by_unit_id.keys():
		var unit_id := String(unit_id_key)
		if not bool(alive_unit_ids.get(unit_id, false)):
			_remove_strategy_status_icon_label(unit_id)


func _create_strategy_status_icon_label() -> Control:
	var root := Control.new()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.size = Vector2(STATUS_BADGE_WIDTH, STATUS_BADGE_HEIGHT)
	root.z_index = 37
	battle_fx_root.add_child(root)
	return root


func _sync_strategy_status_icon_label_children(root: Control, status_entries: Array[Dictionary]) -> void:
	if root == null:
		return
	while root.get_child_count() < status_entries.size():
		var child_label := Label.new()
		child_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		child_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		child_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		child_label.add_theme_font_size_override("font_size", 24)
		child_label.add_theme_color_override("font_outline_color", STATUS_BADGE_OUTLINE_COLOR)
		child_label.add_theme_constant_override("outline_size", 5)
		child_label.size = Vector2(STATUS_BADGE_WIDTH, STATUS_BADGE_HEIGHT)
		root.add_child(child_label)
	var entry_count := status_entries.size()
	var total_width := (STATUS_BADGE_WIDTH * float(entry_count)) + (STATUS_BADGE_GAP * float(maxi(entry_count - 1, 0)))
	root.size = Vector2(maxf(total_width, STATUS_BADGE_WIDTH), STATUS_BADGE_HEIGHT)
	for child_index in range(root.get_child_count()):
		var child_label := root.get_child(child_index) as Label
		if child_label == null:
			continue
		if child_index >= entry_count:
			child_label.visible = false
			continue
		var entry := status_entries[child_index]
		child_label.text = String(entry.get("badge", ""))
		child_label.position = Vector2(float(child_index) * (STATUS_BADGE_WIDTH + STATUS_BADGE_GAP), 0.0)
		child_label.add_theme_color_override("font_color", _get_status_display_color_for_entry(entry))
		child_label.visible = child_label.text != ""


func _get_strategy_status_badge_position_for_unit(unit_state: BattleUnitState, badge_size: Vector2) -> Vector2:
	if unit_state == null:
		return Vector2.ZERO
	var facing_indicator := _get_facing_indicator_for_unit(unit_state)
	var facing_anchor := _get_facing_indicator_world_position_for_unit(unit_state)
	var facing_indicator_size := Vector2.ZERO
	if facing_indicator != null:
		facing_indicator_size = facing_indicator.size
	if facing_anchor == Vector2.ZERO:
		facing_anchor = _get_visual_anchor_position_for_unit(unit_state) + Vector2(-18.0, -100.0)
	var normalized_facing := _get_unit_facing(unit_state)
	var arrow_visual_size := Vector2(STATUS_BADGE_FACING_ARROW_APPROX_WIDTH, STATUS_BADGE_FACING_ARROW_APPROX_HEIGHT)
	var arrow_visual_origin := facing_anchor
	if facing_indicator_size.x > arrow_visual_size.x:
		arrow_visual_origin.x += (facing_indicator_size.x - arrow_visual_size.x) * 0.5
	if facing_indicator_size.y > arrow_visual_size.y:
		arrow_visual_origin.y += (facing_indicator_size.y - arrow_visual_size.y) * 0.5
	var centered_badge_y := (arrow_visual_size.y - badge_size.y) * 0.5 + STATUS_BADGE_ARROW_Y_NUDGE
	match normalized_facing:
		FACING_LEFT:
			return arrow_visual_origin + Vector2(arrow_visual_size.x + STATUS_BADGE_ARROW_GAP, centered_badge_y)
		FACING_RIGHT, FACING_UP, FACING_DOWN:
			return arrow_visual_origin + Vector2(-badge_size.x - STATUS_BADGE_ARROW_GAP, centered_badge_y)
		_:
			return arrow_visual_origin + Vector2(arrow_visual_size.x + STATUS_BADGE_ARROW_GAP, centered_badge_y)


func _get_facing_indicator_world_position_for_unit(unit_state: BattleUnitState) -> Vector2:
	var facing_indicator := _get_facing_indicator_for_unit(unit_state)
	if facing_indicator == null:
		return Vector2.ZERO
	return get_viewport().get_canvas_transform().affine_inverse() * facing_indicator.global_position


func _remove_strategy_status_icon_label(unit_id: String) -> void:
	var label := strategy_status_icon_labels_by_unit_id.get(unit_id, null) as Control
	if label != null and is_instance_valid(label):
		label.queue_free()
	strategy_status_icon_labels_by_unit_id.erase(unit_id)


func _clear_strategy_status_icon_labels() -> void:
	for unit_id_key in strategy_status_icon_labels_by_unit_id.keys():
		_remove_strategy_status_icon_label(String(unit_id_key))
	strategy_status_icon_labels_by_unit_id.clear()


func _consume_confused_ally_turn_if_needed() -> bool:
	if _handle_battle_end_guard("confused_ally_turn"):
		print("[TURN_ADVANCE_BLOCKED] source=confused_ally_turn reason=result_finalized")
		return true
	if current_phase != PHASE_ALLY_TURN:
		return false
	if active_unit_state == null or active_unit_state.side != "ally":
		return false
	if not active_unit_state.is_alive() or _has_ally_unit_acted(active_unit_state):
		return false
	if not _is_unit_confused(active_unit_state):
		return false
	_append_battle_log("%s은 혼란 상태로 행동할 수 없습니다." % active_unit_state.display_name)
	_spawn_strategy_text_fx(_get_visual_anchor_position_for_unit(active_unit_state), "혼란", STRATEGY_EFFECT_COLOR)
	_mark_ally_unit_acted(active_unit_state)
	_update_ally_ready_frames()
	_refresh_formation_slot_guides()
	if _handle_battle_end_guard("confused_ally_turn_after_mark"):
		print("[TURN_ADVANCE_BLOCKED] source=confused_ally_turn_after_mark reason=result_finalized")
		_set_phase(PHASE_ALLY_TURN)
		return true
	_set_phase(PHASE_ENEMY_TURN)
	_append_battle_log("적군 턴")
	_play_enemy_turn_demo()
	return true


func _get_unique_skill_range(caster_state: BattleUnitState, skill_data: Dictionary) -> int:
	if caster_state == null:
		return 0
	var effect_type := String(skill_data.get("effect_type", ""))
	var default_range := UNIQUE_SKILL_DEFAULT_RANGE
	match effect_type:
		"self_defense_single":
			default_range = UNIQUE_SKILL_MELEE_RANGE
		"single_damage_adjacent_shake":
			default_range = UNIQUE_SKILL_SHORT_RANGE
		"cannon_aoe":
			default_range = UNIQUE_SKILL_AOE_RANGE
		"ally_attack_buff":
			default_range = UNIQUE_SKILL_BUFF_RANGE
	var requested_range: int = maxi(int(skill_data.get("range", default_range)), 0)
	match effect_type:
		"self_defense_single":
			return mini(requested_range, UNIQUE_SKILL_MELEE_RANGE)
		"single_damage_adjacent_shake":
			return mini(requested_range, maxi(UNIQUE_SKILL_MELEE_RANGE, mini(UNIQUE_SKILL_SHORT_RANGE, caster_state.attack_range)))
		"cannon_aoe":
			return mini(requested_range, UNIQUE_SKILL_AOE_RANGE)
		"ally_attack_buff":
			return mini(requested_range, UNIQUE_SKILL_BUFF_RANGE)
		_:
			return mini(requested_range, UNIQUE_SKILL_SHORT_RANGE)


func _get_unique_skill_range_cells(caster_state: BattleUnitState, skill_data: Dictionary) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	if caster_state == null or battle_grid_controller == null:
		return cells
	var skill_range := _get_unique_skill_range(caster_state, skill_data)
	for cell in battle_grid_controller.get_tiles_in_range(caster_state.grid_cell, skill_range):
		if battle_grid_controller.is_in_bounds(cell):
			cells.append(cell)
	return cells


func _get_unique_skill_valid_targets(caster_state: BattleUnitState, skill_data: Dictionary) -> Array[BattleUnitState]:
	var targets: Array[BattleUnitState] = []
	if caster_state == null:
		return targets
	var effect_type := String(skill_data.get("effect_type", ""))
	var target_side := _get_opposing_side(caster_state.side)
	if effect_type == "ally_attack_buff":
		target_side = caster_state.side
	var skill_range := _get_unique_skill_range(caster_state, skill_data)
	for unit_state in _get_alive_deployed_unit_states_for_side(target_side):
		if get_unit_grid_distance(caster_state, unit_state) <= skill_range:
			if effect_type == "ally_attack_buff" and _has_active_unique_skill_attack_buff(unit_state):
				continue
			targets.append(unit_state)
	return targets


func _is_valid_unique_skill_target(caster_state: BattleUnitState, skill_data: Dictionary, target_state: BattleUnitState) -> bool:
	if target_state == null or not target_state.is_alive():
		return false
	return _get_unique_skill_valid_targets(caster_state, skill_data).has(target_state)


func _has_valid_unique_skill_action(caster_state: BattleUnitState, skill_data: Dictionary) -> bool:
	if caster_state == null or skill_data.is_empty():
		return false
	return _get_best_unique_skill_target_for_actor(caster_state, skill_data) != null


func _get_best_unique_skill_target_for_actor(caster_state: BattleUnitState, skill_data: Dictionary) -> BattleUnitState:
	if caster_state == null:
		return null
	var effect_type := String(skill_data.get("effect_type", ""))
	var candidates := _get_unique_skill_valid_targets(caster_state, skill_data)
	if candidates.is_empty():
		return null
	if effect_type == "ally_attack_buff":
		for ally_state in candidates:
			if not _has_active_unique_skill_attack_buff(ally_state):
				return ally_state
		return null
	if effect_type == "cannon_aoe":
		return _get_best_unique_skill_aoe_target(caster_state, skill_data, candidates)
	return _get_best_unique_skill_single_target(caster_state, skill_data, candidates)


func _get_best_unique_skill_aoe_target(caster_state: BattleUnitState, skill_data: Dictionary, candidates: Array[BattleUnitState]) -> BattleUnitState:
	var best_target: BattleUnitState = null
	var best_score := -999999
	var hit_count := _get_unique_skill_cannon_aoe_targets(caster_state, skill_data).size()
	for target_state in candidates:
		var score := hit_count * 10000
		score += maxi(0, 200 - get_unit_grid_distance(caster_state, target_state))
		score += maxi(0, int(target_state.max_hp) - int(target_state.current_hp))
		if score > best_score:
			best_score = score
			best_target = target_state
	return best_target


func _get_best_unique_skill_single_target(caster_state: BattleUnitState, skill_data: Dictionary, candidates: Array[BattleUnitState]) -> BattleUnitState:
	var best_target: BattleUnitState = null
	var best_score := -999999
	var damage := _get_unique_skill_effect_amount(caster_state, skill_data, "power", UNIQUE_SKILL_DEFAULT_DAMAGE, false)
	for target_state in candidates:
		var projected_damage := _get_directional_attack_damage(damage, caster_state, target_state, false, false)
		var score := 0
		if projected_damage >= int(target_state.current_hp):
			score += 100000
		score += maxi(0, int(target_state.max_hp) - int(target_state.current_hp)) * 10
		score += maxi(0, 200 - get_unit_grid_distance(caster_state, target_state))
		var angle_type := _get_attack_angle_type(caster_state, target_state)
		if angle_type == ATTACK_ANGLE_BACK:
			score += 300
		elif angle_type == ATTACK_ANGLE_SIDE:
			score += 150
		if String(skill_data.get("effect_type", "")) == "single_damage_adjacent_shake":
			score += _count_adjacent_unique_skill_splash_targets(caster_state, target_state) * 250
		if score > best_score:
			best_score = score
			best_target = target_state
	return best_target


func _count_adjacent_unique_skill_splash_targets(caster_state: BattleUnitState, primary_target: BattleUnitState) -> int:
	if caster_state == null or primary_target == null:
		return 0
	var count := 0
	for target_state in _get_alive_deployed_unit_states_for_side(_get_opposing_side(caster_state.side)):
		if target_state == primary_target:
			continue
		if get_unit_grid_distance(primary_target, target_state) <= 1:
			count += 1
	return count


func _get_unique_skill_aoe_hit_count(caster_state: BattleUnitState, skill_data: Dictionary, primary_target: BattleUnitState) -> int:
	if caster_state == null or primary_target == null:
		return 0
	return _get_unique_skill_cannon_aoe_targets(caster_state, skill_data).size()


func _get_unique_skill_cannon_aoe_targets(caster_state: BattleUnitState, skill_data: Dictionary) -> Array[BattleUnitState]:
	var targets: Array[BattleUnitState] = []
	if String(skill_data.get("effect_type", "")) != "cannon_aoe":
		return targets
	targets = _get_unique_skill_valid_targets(caster_state, skill_data)
	return targets


func _get_unique_skill_buff_candidate_count_for_actor(caster_state: BattleUnitState, skill_data: Dictionary) -> int:
	var count := 0
	for unit_state in _get_unique_skill_valid_targets(caster_state, skill_data):
		if not _has_active_unique_skill_attack_buff(unit_state):
			count += 1
	return count


func _is_unique_skill_high_value_for_actor(caster_state: BattleUnitState, skill_data: Dictionary, target_state: BattleUnitState) -> bool:
	if caster_state == null or skill_data.is_empty():
		return false
	var effect_type := String(skill_data.get("effect_type", ""))
	match effect_type:
		"ally_attack_buff":
			return _get_unique_skill_buff_candidate_count_for_actor(caster_state, skill_data) >= 2
		"cannon_aoe":
			return target_state != null and _get_unique_skill_aoe_hit_count(caster_state, skill_data, target_state) >= 2
		"self_defense_single":
			if target_state == null:
				return false
			var skill_damage := _get_directional_attack_damage(_get_unique_skill_effect_amount(caster_state, skill_data, "power", UNIQUE_SKILL_DEFAULT_DAMAGE, false), caster_state, target_state, false, false)
			var attack_damage := _get_auto_damage_for_actor_against_target(caster_state, target_state)
			var angle_type := _get_attack_angle_type(caster_state, target_state)
			return (
				skill_damage >= int(target_state.current_hp)
				or skill_damage >= attack_damage + UNIQUE_SKILL_HIGH_VALUE_DAMAGE_DELTA
				or (angle_type == ATTACK_ANGLE_BACK and skill_damage >= attack_damage + 6)
			)
		"single_damage_adjacent_shake":
			if target_state == null:
				return false
			var skill_damage := _get_directional_attack_damage(_get_unique_skill_effect_amount(caster_state, skill_data, "power", UNIQUE_SKILL_DEFAULT_DAMAGE, false), caster_state, target_state, false, false)
			var attack_damage := _get_auto_damage_for_actor_against_target(caster_state, target_state)
			return (
				skill_damage >= int(target_state.current_hp)
				or _count_adjacent_unique_skill_splash_targets(caster_state, target_state) >= 1
				or skill_damage >= attack_damage + UNIQUE_SKILL_HIGH_VALUE_DAMAGE_DELTA
			)
	return false


func _is_unique_skill_fallback_value_for_actor(caster_state: BattleUnitState, skill_data: Dictionary, target_state: BattleUnitState) -> bool:
	if caster_state == null or skill_data.is_empty():
		return false
	var effect_type := String(skill_data.get("effect_type", ""))
	match effect_type:
		"ally_attack_buff":
			return _get_unique_skill_buff_candidate_count_for_actor(caster_state, skill_data) >= 3
		"cannon_aoe":
			return target_state != null and _get_unique_skill_aoe_hit_count(caster_state, skill_data, target_state) >= 2
		"self_defense_single", "single_damage_adjacent_shake":
			if target_state == null:
				return false
			var skill_damage := _get_directional_attack_damage(_get_unique_skill_effect_amount(caster_state, skill_data, "power", UNIQUE_SKILL_DEFAULT_DAMAGE, false), caster_state, target_state, false, false)
			return skill_damage >= int(target_state.current_hp)
	return false


func _get_unique_skill_clicked_target_at_position(mouse_world_pos: Vector2) -> BattleUnitState:
	if unique_skill_targeting_caster_state == null or unique_skill_targeting_skill_data.is_empty():
		return null
	var effect_type := String(unique_skill_targeting_skill_data.get("effect_type", ""))
	var clicked_target: BattleUnitState = null
	if effect_type == "ally_attack_buff":
		clicked_target = _get_clicked_ally_unit_at_position(mouse_world_pos)
	else:
		clicked_target = _get_clicked_enemy_unit_at_position(mouse_world_pos)
	if _is_valid_unique_skill_target(unique_skill_targeting_caster_state, unique_skill_targeting_skill_data, clicked_target):
		return clicked_target
	return null


func _try_use_unique_skill_on_target(target_state: BattleUnitState) -> void:
	if current_phase != PHASE_UNIQUE_SKILL_TARGET_SELECT:
		return
	if is_manual_unique_skill_preview_pending:
		return
	var caster_state := unique_skill_targeting_caster_state
	var skill_data := unique_skill_targeting_skill_data.duplicate(true)
	if not _can_use_unique_skill(caster_state):
		_cancel_unique_skill_target_select_mode()
		return
	if not _is_valid_unique_skill_target(caster_state, skill_data, target_state):
		_append_battle_log("고유특기 대상이 아닙니다")
		return
	selected_attack_target_state = target_state
	selected_attack_target_side = target_state.side
	_hide_unique_skill_range_overlay()
	_clear_unique_skill_targeting_state()
	_begin_unique_skill_sequence(caster_state, skill_data)


func _try_auto_unique_skill_for_actor(caster_state: BattleUnitState, require_high_value := true) -> bool:
	if not _can_actor_use_unique_skill(caster_state):
		return false
	var skill_data := _get_unique_skill_for_unit(caster_state)
	if skill_data.is_empty():
		return false
	var target_state := _get_best_unique_skill_target_for_actor(caster_state, skill_data)
	if require_high_value and not _is_unique_skill_high_value_for_actor(caster_state, skill_data, target_state):
		return false
	if not require_high_value and not _is_unique_skill_fallback_value_for_actor(caster_state, skill_data, target_state):
		return false
	if String(skill_data.get("effect_type", "")) != "ally_attack_buff":
		if target_state == null:
			return false
		selected_attack_target_state = target_state
		selected_attack_target_side = target_state.side
	else:
		selected_attack_target_state = target_state
		selected_attack_target_side = caster_state.side
	_append_battle_log("%s 고유특기 선택" % caster_state.display_name)
	is_auto_action_in_progress = caster_state.side == "ally"
	_begin_auto_unique_skill_preview(caster_state, skill_data)
	return true


func _begin_auto_unique_skill_preview(caster_state: BattleUnitState, skill_data: Dictionary) -> void:
	if caster_state == null or skill_data.is_empty():
		return
	is_demo_animating = true
	_hide_facing_selection_panel()
	_hide_move_range_overlay()
	_hide_attack_range_overlay()
	_show_unique_skill_range_overlay(caster_state, skill_data)
	_refresh_floating_ally_command_panel()
	get_tree().create_timer(UNIQUE_SKILL_AUTO_PREVIEW_DURATION).timeout.connect(_finish_auto_unique_skill_preview.bind(caster_state, skill_data), CONNECT_ONE_SHOT)


func _finish_auto_unique_skill_preview(caster_state: BattleUnitState, skill_data: Dictionary) -> void:
	_hide_unique_skill_range_overlay()
	is_demo_animating = false
	_begin_unique_skill_sequence(caster_state, skill_data)


func _begin_unique_skill_sequence(caster_state: BattleUnitState, skill_data: Dictionary) -> void:
	if caster_state == null or skill_data.is_empty():
		return
	is_manual_unique_skill_preview_pending = false
	is_demo_animating = true
	is_unique_skill_presenting = true
	is_floating_ally_command_panel_requested = false
	_hide_facing_selection_panel()
	_hide_move_range_overlay()
	_hide_attack_range_overlay()
	_hide_unique_skill_range_overlay()
	_clear_move_target_selection()
	_set_phase(PHASE_RESOLVING)
	_stop_idle_breathing()
	_sync_demo_positions()
	_focus_camera_for_unique_skill(caster_state, skill_data)
	var effect_apply_delay := UNIQUE_SKILL_EFFECT_APPLY_DELAY
	var presentation_duration := UNIQUE_SKILL_TOAST_DURATION
	if _show_specialty_skill_video_cutin(caster_state, skill_data):
		effect_apply_delay = SPECIALTY_SKILL_CUTIN_TOTAL_DURATION
		presentation_duration = SPECIALTY_SKILL_CUTIN_TOTAL_DURATION + UNIQUE_SKILL_POST_EFFECT_HOLD_DURATION
	else:
		_show_unique_skill_toast_over_unit(caster_state, skill_data)
	_append_battle_log("%s이 %s을 발동!" % [caster_state.display_name, String(skill_data.get("name", "고유특기"))])
	var remaining_duration := maxf(0.0, presentation_duration - effect_apply_delay)
	get_tree().create_timer(effect_apply_delay).timeout.connect(_apply_unique_skill_effect_if_valid.bind(caster_state, skill_data), CONNECT_ONE_SHOT)
	get_tree().create_timer(effect_apply_delay + remaining_duration).timeout.connect(_finalize_unique_skill_action.bind(caster_state, skill_data), CONNECT_ONE_SHOT)


func _show_specialty_skill_video_cutin(caster_state: BattleUnitState, skill_data: Dictionary) -> bool:
	var hero_id := _get_specialty_skill_video_cutin_hero_id(caster_state, skill_data)
	if hero_id == "":
		return false
	if is_specialty_skill_cutin_playing:
		return false
	if specialty_skill_cutin_layer == null or specialty_skill_cutin_hero == null or specialty_skill_cutin_skill_title == null:
		return false

	var cutin_config := _get_specialty_skill_cutin_config(hero_id)
	var portrait_path := String(cutin_config.get("portrait_path", ""))
	var portrait_texture := _load_unique_skill_texture(portrait_path)
	if portrait_texture == null:
		push_warning("[SPECIALTY_CUTIN] Missing portrait image for %s: %s" % [hero_id, portrait_path])
		return false
	var title_path := String(cutin_config.get("title_path", ""))
	var title_texture := _load_unique_skill_texture(title_path)
	if title_texture == null:
		push_warning("[SPECIALTY_CUTIN] Missing title image for %s: %s" % [hero_id, title_path])
		return false

	_hide_unique_skill_toast()
	unique_skill_cutin_timing_start_msec = Time.get_ticks_msec()
	_log_unique_skill_cutin_timing("VIDEO_CUTIN_START", "hero=%s duration=%.2f" % [hero_id, SPECIALTY_SKILL_CUTIN_TOTAL_DURATION])

	var viewport_size := get_viewport_rect().size
	var cutin_rect := _layout_specialty_skill_cutin(viewport_size, hero_id)
	_set_toast_facing_indicator_suppression("unique_skill", true)
	is_specialty_skill_cutin_playing = true

	if specialty_skill_cutin_tween != null:
		specialty_skill_cutin_tween.kill()
		specialty_skill_cutin_tween = null

	var hero_base_position := specialty_skill_cutin_hero.position
	var text_base_position := specialty_skill_cutin_text.position if specialty_skill_cutin_text != null else Vector2.ZERO
	var slash_base_position := specialty_skill_cutin_slash.position if specialty_skill_cutin_slash != null else Vector2.ZERO

	specialty_skill_cutin_layer.visible = true
	specialty_skill_cutin_layer.modulate = Color.WHITE
	specialty_skill_cutin_layer.position = Vector2.ZERO
	specialty_skill_cutin_layer.scale = Vector2.ONE * 0.96
	specialty_skill_cutin_layer.pivot_offset = viewport_size * 0.5
	if specialty_skill_cutin_darken != null:
		specialty_skill_cutin_darken.color = Color(0.0196078, 0.027451, 0.0392157, 0.0)
	if specialty_skill_cutin_video != null:
		specialty_skill_cutin_video.visible = true
		_prepare_specialty_skill_cutin_video_node(cutin_rect)
		specialty_skill_cutin_video.modulate = Color(0.82, 0.9, 1.0, 0.96)
		_log_specialty_skill_cutin_video_player_state("start_before_assign")
		if _assign_specialty_skill_cutin_video_stream_for_hero(hero_id):
			specialty_skill_cutin_video.play()
		_log_specialty_skill_cutin_video_player_state("after_play_call")
		_log_specialty_skill_cutin_video_player_state_later("after_0_3s", 0.3)
	if specialty_skill_cutin_slash != null:
		specialty_skill_cutin_slash.position = slash_base_position + SPECIALTY_SKILL_CUTIN_ACCENT_ENTER_OFFSET
		specialty_skill_cutin_slash.color = SPECIALTY_SKILL_CUTIN_ACCENT_EXIT_COLOR
	if specialty_skill_cutin_hero != null:
		specialty_skill_cutin_hero.texture = portrait_texture
		specialty_skill_cutin_hero.position = hero_base_position + SPECIALTY_SKILL_CUTIN_HERO_ENTER_OFFSET
		specialty_skill_cutin_hero.modulate = Color(1.0, 1.0, 1.0, 0.0)
		specialty_skill_cutin_hero.scale = Vector2.ONE * SPECIALTY_SKILL_CUTIN_HERO_START_SCALE
	if specialty_skill_cutin_text != null:
		specialty_skill_cutin_text.position = text_base_position + SPECIALTY_SKILL_CUTIN_TEXT_ENTER_OFFSET
		specialty_skill_cutin_text.modulate = Color(1.0, 1.0, 1.0, 0.0)
		specialty_skill_cutin_text.scale = Vector2.ONE * SPECIALTY_SKILL_CUTIN_TEXT_START_SCALE
	if specialty_skill_cutin_skill_title != null:
		specialty_skill_cutin_skill_title.texture = title_texture

	specialty_skill_cutin_tween = create_tween()
	if specialty_skill_cutin_darken != null:
		specialty_skill_cutin_tween.tween_property(specialty_skill_cutin_darken, "color", Color(0.0196078, 0.027451, 0.0392157, SPECIALTY_SKILL_CUTIN_DARKEN_ALPHA), 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	specialty_skill_cutin_tween.parallel().tween_property(specialty_skill_cutin_layer, "scale", Vector2.ONE, SPECIALTY_SKILL_CUTIN_ENTER_DURATION).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	if specialty_skill_cutin_slash != null:
		specialty_skill_cutin_tween.parallel().tween_property(specialty_skill_cutin_slash, "position", slash_base_position, 0.28).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT).set_delay(0.16)
		specialty_skill_cutin_tween.parallel().tween_property(specialty_skill_cutin_slash, "color", SPECIALTY_SKILL_CUTIN_ACCENT_COLOR, 0.22).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).set_delay(0.18)
	if specialty_skill_cutin_hero != null:
		specialty_skill_cutin_tween.parallel().tween_property(specialty_skill_cutin_hero, "position", hero_base_position + Vector2(28.0, 0.0), SPECIALTY_SKILL_CUTIN_ENTER_DURATION * 0.72).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT).set_delay(0.08)
		specialty_skill_cutin_tween.parallel().tween_property(specialty_skill_cutin_hero, "modulate:a", 1.0, SPECIALTY_SKILL_CUTIN_ENTER_DURATION * 0.72).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).set_delay(0.08)
		specialty_skill_cutin_tween.parallel().tween_property(specialty_skill_cutin_hero, "scale", Vector2.ONE * 1.035, SPECIALTY_SKILL_CUTIN_ENTER_DURATION * 0.72).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT).set_delay(0.08)
		specialty_skill_cutin_tween.parallel().tween_property(specialty_skill_cutin_hero, "position", hero_base_position, SPECIALTY_SKILL_CUTIN_ENTER_DURATION * 0.42).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).set_delay(0.08 + SPECIALTY_SKILL_CUTIN_ENTER_DURATION * 0.72)
		specialty_skill_cutin_tween.parallel().tween_property(specialty_skill_cutin_hero, "scale", Vector2.ONE * SPECIALTY_SKILL_CUTIN_HERO_SETTLE_SCALE, SPECIALTY_SKILL_CUTIN_ENTER_DURATION * 0.42).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).set_delay(0.08 + SPECIALTY_SKILL_CUTIN_ENTER_DURATION * 0.72)
	if specialty_skill_cutin_text != null:
		var title_burst_delay := SPECIALTY_SKILL_CUTIN_TEXT_DELAY + SPECIALTY_SKILL_CUTIN_TEXT_READABLE_HOLD
		specialty_skill_cutin_tween.parallel().tween_property(specialty_skill_cutin_text, "position", text_base_position, 0.14).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT).set_delay(SPECIALTY_SKILL_CUTIN_TEXT_DELAY)
		specialty_skill_cutin_tween.parallel().tween_property(specialty_skill_cutin_text, "modulate:a", 1.0, 0.08).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).set_delay(SPECIALTY_SKILL_CUTIN_TEXT_DELAY)
		specialty_skill_cutin_tween.parallel().tween_property(specialty_skill_cutin_text, "scale", Vector2.ONE * SPECIALTY_SKILL_CUTIN_TEXT_IMPACT_SCALE, SPECIALTY_SKILL_CUTIN_TEXT_BURST_DURATION).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT).set_delay(title_burst_delay)
		specialty_skill_cutin_tween.parallel().tween_property(specialty_skill_cutin_text, "modulate:a", 0.0, SPECIALTY_SKILL_CUTIN_TEXT_BURST_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN).set_delay(title_burst_delay)
		specialty_skill_cutin_tween.parallel().tween_property(specialty_skill_cutin_text, "position", text_base_position + Vector2(0.0, -22.0), SPECIALTY_SKILL_CUTIN_TEXT_BURST_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).set_delay(title_burst_delay)
	specialty_skill_cutin_tween.chain().tween_interval(maxf(0.0, SPECIALTY_SKILL_CUTIN_EXIT_START - SPECIALTY_SKILL_CUTIN_TEXT_DELAY - SPECIALTY_SKILL_CUTIN_TEXT_POP_DURATION))
	specialty_skill_cutin_tween.tween_callback(_log_unique_skill_cutin_timing.bind("VIDEO_CUTIN_EXIT_START"))
	specialty_skill_cutin_tween.tween_property(specialty_skill_cutin_layer, "modulate:a", 0.0, SPECIALTY_SKILL_CUTIN_EXIT_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	specialty_skill_cutin_tween.parallel().tween_property(specialty_skill_cutin_layer, "scale", Vector2.ONE * 0.98, SPECIALTY_SKILL_CUTIN_EXIT_DURATION).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
	if specialty_skill_cutin_hero != null:
		specialty_skill_cutin_tween.parallel().tween_property(specialty_skill_cutin_hero, "position", hero_base_position + Vector2(-86.0, 14.0), SPECIALTY_SKILL_CUTIN_EXIT_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	if specialty_skill_cutin_slash != null:
		specialty_skill_cutin_tween.parallel().tween_property(specialty_skill_cutin_slash, "color", SPECIALTY_SKILL_CUTIN_ACCENT_EXIT_COLOR, SPECIALTY_SKILL_CUTIN_EXIT_DURATION * 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	specialty_skill_cutin_tween.chain().tween_callback(_hide_specialty_skill_cutin)
	return true


func _get_specialty_skill_video_cutin_hero_id(caster_state: BattleUnitState, _skill_data: Dictionary) -> String:
	if caster_state == null or caster_state.side != "ally":
		return ""
	var hero_id := _get_hero_id_for_unit_state(caster_state)
	if not SPECIALTY_SKILL_CUTIN_CONFIGS.has(hero_id):
		return ""
	return hero_id


func _get_specialty_skill_cutin_config(hero_id: String) -> Dictionary:
	return SPECIALTY_SKILL_CUTIN_CONFIGS.get(hero_id, SPECIALTY_SKILL_CUTIN_CONFIGS.get(SPECIALTY_SKILL_VIDEO_CUTIN_HERO_ID, {}))


func _get_specialty_skill_cutin_config_float(config: Dictionary, key: String, fallback: float) -> float:
	return float(config.get(key, fallback))


func _assign_specialty_skill_cutin_video_stream_for_hero(hero_id: String) -> bool:
	if specialty_skill_cutin_video == null:
		return false
	specialty_skill_cutin_video.stop()
	specialty_skill_cutin_video.stream = null
	var candidate_paths: Array = SPECIALTY_SKILL_CUTIN_VIDEO_PATHS.get(hero_id, [])
	_log_specialty_skill_cutin_video_candidates(hero_id, candidate_paths)
	for path_variant in candidate_paths:
		var path := String(path_variant)
		if path == "" or not FileAccess.file_exists(path):
			continue
		print("[SPECIALTY_CUTIN] selected_video_candidate=%s hero=%s" % [path, hero_id])
		if not _assign_specialty_skill_cutin_video_stream(path):
			print("[SPECIALTY_CUTIN] selected_video_load_failed=%s hero=%s fallback=png_text" % [path, hero_id])
			continue
		print("[SPECIALTY_CUTIN] selected_video=%s hero=%s" % [path, hero_id])
		return true
	print("[SPECIALTY_CUTIN] selected_video=none hero=%s fallback=png_text" % hero_id)
	return false


func _assign_specialty_skill_cutin_video_stream(path: String) -> bool:
	if path == "":
		return false
	var file_exists := FileAccess.file_exists(path)
	var loader_exists := ResourceLoader.exists(path)
	var loaded_resource: Resource = null
	if loader_exists:
		loaded_resource = ResourceLoader.load(path)
	var video_stream := loaded_resource as VideoStream
	print("[SPECIALTY_CUTIN_VIDEO_LOAD] path=%s file_exists=%s resource_loader_exists=%s load_null=%s class=%s is_video_stream=%s failure_guess=%s" % [
		path,
		str(file_exists),
		str(loader_exists),
		str(loaded_resource == null),
		_get_debug_object_class_name(loaded_resource),
		str(video_stream != null),
		_get_specialty_skill_cutin_video_load_failure_guess(path, file_exists, loader_exists, loaded_resource, video_stream),
	])
	if video_stream == null:
		if path.get_extension().to_lower() == "ogv":
			video_stream = _create_specialty_skill_cutin_theora_stream_direct(path)
		if video_stream == null:
			print("[SPECIALTY_CUTIN] video resource is not a VideoStream: %s" % path)
			return false
		print("[SPECIALTY_CUTIN_VIDEO_LOAD] path=%s direct_theora_stream_class=%s" % [
			path,
			_get_debug_object_class_name(video_stream),
		])
	if video_stream == null:
		return false
	specialty_skill_cutin_video.stream = video_stream
	print("[SPECIALTY_CUTIN_VIDEO_LOAD] path=%s stream_set=%s stream_class=%s" % [
		path,
		str(specialty_skill_cutin_video.stream != null),
		_get_debug_object_class_name(specialty_skill_cutin_video.stream),
	])
	return true


func _log_specialty_skill_cutin_video_candidates(hero_id: String, candidate_paths: Array) -> void:
	for path_variant in candidate_paths:
		var path := String(path_variant)
		var file_exists := path != "" and FileAccess.file_exists(path)
		var loader_exists := path != "" and ResourceLoader.exists(path)
		var loaded_resource: Resource = null
		if loader_exists:
			loaded_resource = ResourceLoader.load(path)
		var video_stream := loaded_resource as VideoStream
		print("[SPECIALTY_CUTIN_VIDEO_CANDIDATE] hero=%s path=%s file_exists=%s resource_loader_exists=%s load_null=%s class=%s is_video_stream=%s failure_guess=%s" % [
			hero_id,
			path,
			str(file_exists),
			str(loader_exists),
			str(loaded_resource == null),
			_get_debug_object_class_name(loaded_resource),
			str(video_stream != null),
			_get_specialty_skill_cutin_video_load_failure_guess(path, file_exists, loader_exists, loaded_resource, video_stream),
		])


func _get_specialty_skill_cutin_video_load_failure_guess(path: String, file_exists: bool, loader_exists: bool, loaded_resource: Resource, video_stream: VideoStream) -> String:
	if path == "":
		return "empty_path"
	if not file_exists:
		return "file_missing"
	if not loader_exists:
		return "resource_loader_does_not_recognize_path_or_import"
	if loaded_resource == null:
		return "resource_loader_load_returned_null"
	if video_stream == null:
		return "loaded_resource_is_not_videostream"
	return "none"


func _create_specialty_skill_cutin_theora_stream_direct(path: String) -> VideoStream:
	print("[SPECIALTY_CUTIN_VIDEO_THEORA_DIRECT] path=%s start file_exists=%s" % [path, str(FileAccess.file_exists(path))])
	if path == "" or not FileAccess.file_exists(path):
		print("[SPECIALTY_CUTIN_VIDEO_THEORA_DIRECT] path=%s result=null reason=file_missing" % path)
		return null
	var direct_stream := VideoStreamTheora.new()
	if direct_stream == null:
		print("[SPECIALTY_CUTIN_VIDEO_THEORA_DIRECT] path=%s result=null reason=class_unavailable" % path)
		return null
	if not _debug_object_has_property(direct_stream, "file"):
		print("[SPECIALTY_CUTIN_VIDEO_THEORA_DIRECT] path=%s result=null class=%s reason=file_property_unavailable" % [
			path,
			_get_debug_object_class_name(direct_stream),
		])
		return null
	direct_stream.set("file", path)
	var configured_file := str(direct_stream.get("file"))
	print("[SPECIALTY_CUTIN_VIDEO_THEORA_DIRECT] path=%s class=%s file_property=%s is_video_stream=%s" % [
		path,
		_get_debug_object_class_name(direct_stream),
		configured_file,
		str(direct_stream is VideoStream),
	])
	if configured_file == "":
		print("[SPECIALTY_CUTIN_VIDEO_THEORA_DIRECT] path=%s result=null reason=file_property_not_applied" % path)
		return null
	return direct_stream as VideoStream


func _debug_object_has_property(value: Object, property_name: String) -> bool:
	if value == null:
		return false
	for property_info in value.get_property_list():
		var property_data := property_info as Dictionary
		if String(property_data.get("name", "")) == property_name:
			return true
	return false


func _get_debug_object_class_name(value: Object) -> String:
	if value == null:
		return "null"
	return value.get_class()


func _prepare_specialty_skill_cutin_video_node(cutin_rect: Rect2) -> void:
	if specialty_skill_cutin_video == null:
		return
	specialty_skill_cutin_video.visible = true
	specialty_skill_cutin_video.modulate = Color.WHITE
	specialty_skill_cutin_video.self_modulate = Color.WHITE
	specialty_skill_cutin_video.position = cutin_rect.position
	specialty_skill_cutin_video.size = cutin_rect.size
	if specialty_skill_cutin_video.size.x <= 1.0 or specialty_skill_cutin_video.size.y <= 1.0:
		specialty_skill_cutin_video.size = Vector2(maxf(cutin_rect.size.x, 320.0), maxf(cutin_rect.size.y, 180.0))
	specialty_skill_cutin_video.z_index = 1
	if specialty_skill_cutin_darken != null:
		specialty_skill_cutin_darken.z_index = 0
	if specialty_skill_cutin_slash != null:
		specialty_skill_cutin_slash.z_index = 2
	if specialty_skill_cutin_hero != null:
		specialty_skill_cutin_hero.z_index = 3
	if specialty_skill_cutin_text != null:
		specialty_skill_cutin_text.z_index = 4
	if CUTIN_VIDEO_DEBUG_FORCE_TOP:
		specialty_skill_cutin_video.position = cutin_rect.position - Vector2(24.0, 24.0)
		specialty_skill_cutin_video.size = cutin_rect.size + Vector2(48.0, 48.0)
		specialty_skill_cutin_video.z_index = 100


func _log_specialty_skill_cutin_video_player_state(stage: String) -> void:
	if specialty_skill_cutin_video == null:
		print("[SPECIALTY_CUTIN_VIDEO_STATE] stage=%s video_node=null" % stage)
		return
	var parent_control := specialty_skill_cutin_video.get_parent() as Control
	print("[SPECIALTY_CUTIN_VIDEO_STATE] stage=%s stream_set=%s stream_class=%s is_playing=%s visible=%s modulate=%s self_modulate=%s position=%s global_position=%s size=%s z_index=%d parent=%s parent_visible=%s parent_modulate=%s index=%d debug_force_top=%s" % [
		stage,
		str(specialty_skill_cutin_video.stream != null),
		_get_debug_object_class_name(specialty_skill_cutin_video.stream),
		str(specialty_skill_cutin_video.is_playing()),
		str(specialty_skill_cutin_video.visible),
		str(specialty_skill_cutin_video.modulate),
		str(specialty_skill_cutin_video.self_modulate),
		str(specialty_skill_cutin_video.position),
		str(specialty_skill_cutin_video.global_position),
		str(specialty_skill_cutin_video.size),
		specialty_skill_cutin_video.z_index,
		str(parent_control.name) if parent_control != null else "null",
		str(parent_control.visible) if parent_control != null else "null",
		str(parent_control.modulate) if parent_control != null else "null",
		specialty_skill_cutin_video.get_index(),
		str(CUTIN_VIDEO_DEBUG_FORCE_TOP),
	])
	_log_specialty_skill_cutin_draw_order(stage)


func _log_specialty_skill_cutin_draw_order(stage: String) -> void:
	print("[SPECIALTY_CUTIN_DRAW_ORDER] stage=%s darken_index=%s darken_z=%s video_index=%s video_z=%s slash_index=%s slash_z=%s hero_index=%s hero_z=%s text_index=%s text_z=%s" % [
		stage,
		_get_debug_node_index(specialty_skill_cutin_darken),
		_get_debug_node_z_index(specialty_skill_cutin_darken),
		_get_debug_node_index(specialty_skill_cutin_video),
		_get_debug_node_z_index(specialty_skill_cutin_video),
		_get_debug_node_index(specialty_skill_cutin_slash),
		_get_debug_node_z_index(specialty_skill_cutin_slash),
		_get_debug_node_index(specialty_skill_cutin_hero),
		_get_debug_node_z_index(specialty_skill_cutin_hero),
		_get_debug_node_index(specialty_skill_cutin_text),
		_get_debug_node_z_index(specialty_skill_cutin_text),
	])


func _get_debug_node_index(node: Node) -> String:
	if node == null:
		return "null"
	return str(node.get_index())


func _get_debug_node_z_index(node: CanvasItem) -> String:
	if node == null:
		return "null"
	return str(node.z_index)


func _log_specialty_skill_cutin_video_player_state_later(stage: String, delay: float) -> void:
	_log_specialty_skill_cutin_video_player_state_later_async(stage, delay)


func _log_specialty_skill_cutin_video_player_state_later_async(stage: String, delay: float) -> void:
	await get_tree().create_timer(maxf(0.0, delay)).timeout
	_log_specialty_skill_cutin_video_player_state(stage)


func _debug_play_cutin_video_only() -> void:
	if specialty_skill_cutin_layer == null or specialty_skill_cutin_video == null:
		print("[SPECIALTY_CUTIN_VIDEO_ONLY] unavailable layer_or_video_missing")
		return
	var viewport_size := get_viewport_rect().size
	var cutin_rect := _layout_specialty_skill_cutin(viewport_size)
	if specialty_skill_cutin_tween != null:
		specialty_skill_cutin_tween.kill()
		specialty_skill_cutin_tween = null
	specialty_skill_cutin_layer.visible = true
	specialty_skill_cutin_layer.modulate = Color.WHITE
	specialty_skill_cutin_layer.position = Vector2.ZERO
	specialty_skill_cutin_layer.scale = Vector2.ONE
	if specialty_skill_cutin_darken != null:
		specialty_skill_cutin_darken.color = Color(0.0196078, 0.027451, 0.0392157, 0.35)
	if specialty_skill_cutin_slash != null:
		specialty_skill_cutin_slash.color = SPECIALTY_SKILL_CUTIN_ACCENT_EXIT_COLOR
	if specialty_skill_cutin_hero != null:
		specialty_skill_cutin_hero.modulate = Color(1.0, 1.0, 1.0, 0.0)
	if specialty_skill_cutin_text != null:
		specialty_skill_cutin_text.modulate = Color(1.0, 1.0, 1.0, 0.0)
	_prepare_specialty_skill_cutin_video_node(cutin_rect)
	var assigned := _assign_specialty_skill_cutin_video_stream_for_hero(SPECIALTY_SKILL_VIDEO_CUTIN_HERO_ID)
	if assigned:
		specialty_skill_cutin_video.play()
	_log_specialty_skill_cutin_video_player_state("video_only_after_play")
	await get_tree().create_timer(SPECIALTY_SKILL_CUTIN_TOTAL_DURATION).timeout
	_hide_specialty_skill_cutin()


func _focus_camera_for_unique_skill(caster_state: BattleUnitState, skill_data: Dictionary) -> void:
	if caster_state == null:
		return
	var target_state := _get_best_unique_skill_target_for_actor(caster_state, skill_data)
	if target_state != null:
		_focus_camera_on_combat_pair(caster_state, target_state, true)
		return
	_focus_camera_on_unit(caster_state, true)


func _apply_unique_skill_effect_if_valid(caster_state: BattleUnitState, skill_data: Dictionary) -> void:
	if caster_state == null or not caster_state.is_alive():
		return
	if not is_unique_skill_presenting:
		return
	_log_unique_skill_cutin_timing("EFFECT_APPLY")
	_start_unique_skill_camera_shake(String(skill_data.get("effect_type", "")))
	_apply_unique_skill_effect(caster_state, skill_data)


func _show_unique_skill_toast_over_unit(caster_state: BattleUnitState, skill_data: Dictionary) -> void:
	if unique_skill_toast_root == null:
		return
	if unique_skill_toast_tween != null:
		unique_skill_toast_tween.kill()
		unique_skill_toast_tween = null
	_set_toast_facing_indicator_suppression("unique_skill", true)
	var viewport_size := get_viewport_rect().size
	var cutin_rect := _get_unique_skill_fullscreen_cutin_rect(viewport_size)
	var slide_direction := _get_unique_skill_cutin_slide_direction(caster_state)
	var cutin_position := cutin_rect.position
	var cutin_enter_position := cutin_position - Vector2(viewport_size.x * UNIQUE_SKILL_CUTIN_SLIDE_IN_RATIO * slide_direction, 0.0)
	var cutin_exit_position := cutin_position + Vector2(viewport_size.x * UNIQUE_SKILL_CUTIN_SLIDE_OUT_RATIO * slide_direction, 0.0)
	var name_position := _get_unique_skill_name_position(cutin_rect)
	_layout_unique_skill_fullscreen_cutin(viewport_size, cutin_rect)

	unique_skill_cutin_timing_start_msec = Time.get_ticks_msec()
	_log_unique_skill_cutin_timing("SHOW_START", "hold=%.2f enter=%.2f exit=%.2f flash=%.2f effect_delay=%.2f toast_duration=%.2f" % [
		UNIQUE_SKILL_CUTIN_HOLD_DURATION,
		UNIQUE_SKILL_CUTIN_ENTER_DURATION,
		UNIQUE_SKILL_CUTIN_EXIT_DURATION,
		UNIQUE_SKILL_CUTIN_FLASH_DURATION,
		UNIQUE_SKILL_EFFECT_APPLY_DELAY,
		UNIQUE_SKILL_TOAST_DURATION
	])
	unique_skill_toast_root.visible = true
	unique_skill_toast_root.position = Vector2.ZERO
	unique_skill_toast_root.modulate = Color(1.0, 1.0, 1.0, 0.0)
	unique_skill_toast_root.scale = Vector2.ONE * UNIQUE_SKILL_CUTIN_START_SCALE
	if unique_skill_ink_burst != null:
		unique_skill_ink_burst.visible = true
		unique_skill_ink_burst.color = UNIQUE_SKILL_CUTIN_FLASH_COLOR
		unique_skill_ink_burst.modulate = Color.WHITE
	if unique_skill_cutin_image != null:
		unique_skill_cutin_image.texture = _get_unique_skill_cutin_texture(caster_state, skill_data)
		unique_skill_cutin_image.modulate = Color(1.0, 1.0, 1.0, 0.0)
		unique_skill_cutin_image.position = cutin_enter_position
		unique_skill_cutin_image.scale = Vector2.ONE
		unique_skill_cutin_image.pivot_offset = cutin_rect.size * 0.5
	if unique_skill_name_label != null:
		unique_skill_name_label.text = String(skill_data.get("toast_text", "%s!" % String(skill_data.get("name", "고유특기"))))
		unique_skill_name_label.modulate = Color(1.0, 1.0, 1.0, 0.0)
		unique_skill_name_label.position = name_position + UNIQUE_SKILL_CUTIN_NAME_START_OFFSET
		unique_skill_name_label.scale = Vector2.ONE * UNIQUE_SKILL_CUTIN_NAME_POP_SCALE
		unique_skill_name_label.pivot_offset = unique_skill_name_label.size * 0.5

	unique_skill_toast_tween = create_tween()
	unique_skill_toast_tween.tween_property(unique_skill_toast_root, "modulate:a", 1.0, UNIQUE_SKILL_CUTIN_PUNCH_IN_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	unique_skill_toast_tween.parallel().tween_property(unique_skill_toast_root, "scale", Vector2.ONE * UNIQUE_SKILL_CUTIN_PUNCH_SCALE, UNIQUE_SKILL_CUTIN_PUNCH_IN_DURATION).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	if unique_skill_ink_burst != null:
		unique_skill_toast_tween.parallel().tween_property(unique_skill_ink_burst, "modulate:a", 0.0, UNIQUE_SKILL_CUTIN_FLASH_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if unique_skill_cutin_image != null:
		unique_skill_toast_tween.parallel().tween_property(unique_skill_cutin_image, "position", cutin_position, UNIQUE_SKILL_CUTIN_ENTER_DURATION).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		unique_skill_toast_tween.parallel().tween_property(unique_skill_cutin_image, "modulate:a", 1.0, UNIQUE_SKILL_CUTIN_ENTER_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if unique_skill_name_label != null:
		unique_skill_toast_tween.parallel().tween_property(unique_skill_name_label, "position", name_position, UNIQUE_SKILL_CUTIN_ENTER_DURATION).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(UNIQUE_SKILL_CUTIN_NAME_DELAY)
		unique_skill_toast_tween.parallel().tween_property(unique_skill_name_label, "modulate:a", 1.0, UNIQUE_SKILL_CUTIN_ENTER_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).set_delay(UNIQUE_SKILL_CUTIN_NAME_DELAY)
		unique_skill_toast_tween.parallel().tween_property(unique_skill_name_label, "scale", Vector2.ONE, UNIQUE_SKILL_CUTIN_ENTER_DURATION).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(UNIQUE_SKILL_CUTIN_NAME_DELAY)
	unique_skill_toast_tween.chain().tween_property(unique_skill_toast_root, "scale", Vector2.ONE, UNIQUE_SKILL_CUTIN_PUNCH_SETTLE_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	unique_skill_toast_tween.chain().tween_callback(_log_unique_skill_cutin_timing.bind("ENTER_DONE"))
	unique_skill_toast_tween.tween_callback(_log_unique_skill_cutin_timing.bind("HOLD_START", "hold=%.2f" % UNIQUE_SKILL_CUTIN_HOLD_DURATION))
	unique_skill_toast_tween.tween_interval(UNIQUE_SKILL_CUTIN_HOLD_DURATION)
	unique_skill_toast_tween.tween_callback(_log_unique_skill_cutin_timing.bind("HOLD_DONE"))
	unique_skill_toast_tween.tween_callback(_log_unique_skill_cutin_timing.bind("EXIT_START"))
	unique_skill_toast_tween.tween_property(unique_skill_toast_root, "modulate:a", 0.0, UNIQUE_SKILL_CUTIN_EXIT_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	unique_skill_toast_tween.parallel().tween_property(unique_skill_toast_root, "position", UNIQUE_SKILL_CUTIN_EXIT_UP_OFFSET, UNIQUE_SKILL_CUTIN_EXIT_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	unique_skill_toast_tween.parallel().tween_property(unique_skill_toast_root, "scale", Vector2.ONE * UNIQUE_SKILL_CUTIN_EXIT_SCALE, UNIQUE_SKILL_CUTIN_EXIT_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	if unique_skill_cutin_image != null:
		unique_skill_toast_tween.parallel().tween_property(unique_skill_cutin_image, "position", cutin_exit_position, UNIQUE_SKILL_CUTIN_EXIT_DURATION).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
		unique_skill_toast_tween.parallel().tween_property(unique_skill_cutin_image, "modulate:a", 0.0, UNIQUE_SKILL_CUTIN_EXIT_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	if unique_skill_name_label != null:
		unique_skill_toast_tween.parallel().tween_property(unique_skill_name_label, "modulate:a", 0.0, UNIQUE_SKILL_CUTIN_EXIT_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		unique_skill_toast_tween.parallel().tween_property(unique_skill_name_label, "position", name_position + Vector2(0.0, -16.0), UNIQUE_SKILL_CUTIN_EXIT_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	unique_skill_toast_tween.chain().tween_callback(_hide_unique_skill_toast)


func _get_unique_skill_cutin_slide_direction(caster_state: BattleUnitState) -> float:
	if caster_state != null and caster_state.side == "enemy":
		return -1.0
	return 1.0


func _log_unique_skill_cutin_timing(event_name: String, detail: String = "") -> void:
	if not UNIQUE_SKILL_CUTIN_TIMING_DEBUG:
		return
	if unique_skill_cutin_timing_start_msec <= 0:
		return
	var elapsed := 0.0
	elapsed = float(Time.get_ticks_msec() - unique_skill_cutin_timing_start_msec) / 1000.0
	var message := "[UNIQUE_CUTIN] %s elapsed=%.3f" % [event_name, elapsed]
	if detail != "":
		message = "%s %s" % [message, detail]
	print(message)


func _get_unique_skill_fullscreen_cutin_rect(viewport_size: Vector2) -> Rect2:
	var width := viewport_size.x * UNIQUE_SKILL_CUTIN_VIEWPORT_WIDTH_RATIO
	var height := clampf(
		viewport_size.y * UNIQUE_SKILL_CUTIN_VIEWPORT_HEIGHT_RATIO,
		minf(UNIQUE_SKILL_CUTIN_MIN_HEIGHT, viewport_size.y * UNIQUE_SKILL_CUTIN_MAX_HEIGHT_RATIO),
		viewport_size.y * UNIQUE_SKILL_CUTIN_MAX_HEIGHT_RATIO
	)
	var cutin_position := Vector2((viewport_size.x - width) * 0.5, (viewport_size.y - height) * 0.48)
	return Rect2(cutin_position, Vector2(width, height))


func _layout_unique_skill_fullscreen_cutin(viewport_size: Vector2, cutin_rect: Rect2) -> void:
	unique_skill_toast_root.position = Vector2.ZERO
	unique_skill_toast_root.size = viewport_size
	unique_skill_toast_root.pivot_offset = viewport_size * 0.5
	if unique_skill_ink_burst != null:
		unique_skill_ink_burst.position = Vector2.ZERO
		unique_skill_ink_burst.size = viewport_size
		unique_skill_ink_burst.color = Color(0.0, 0.0, 0.0, 0.42)
	if unique_skill_cutin_image != null:
		unique_skill_cutin_image.size = cutin_rect.size
		unique_skill_cutin_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		unique_skill_cutin_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	if unique_skill_name_label != null:
		unique_skill_name_label.size = Vector2(cutin_rect.size.x - UNIQUE_SKILL_CUTIN_IMAGE_INSET * 2.0, UNIQUE_SKILL_CUTIN_NAME_HEIGHT)


func _get_unique_skill_name_position(cutin_rect: Rect2) -> Vector2:
	return Vector2(
		cutin_rect.position.x + UNIQUE_SKILL_CUTIN_IMAGE_INSET,
		cutin_rect.position.y + cutin_rect.size.y - UNIQUE_SKILL_CUTIN_NAME_HEIGHT - UNIQUE_SKILL_CUTIN_NAME_BOTTOM_MARGIN
	)


func _get_unique_skill_cutin_texture(_caster_state: BattleUnitState, skill_data: Dictionary) -> Texture2D:
	var path := String(skill_data.get("cutin_image_path", ""))
	var texture := _load_unique_skill_texture(path)
	if texture != null:
		return texture
	return _load_unique_skill_texture(GENERIC_SKILL_TOAST_FALLBACK_PATH)


func _load_unique_skill_texture(path: String) -> Texture2D:
	if path == "":
		return null
	if unique_skill_texture_cache.has(path):
		return unique_skill_texture_cache.get(path) as Texture2D
	var texture: Texture2D = null
	if ResourceLoader.exists(path):
		var loaded_resource := load(path)
		texture = loaded_resource as Texture2D
		if texture != null:
			unique_skill_texture_cache[path] = texture
			return texture
	return texture


func _apply_unique_skill_effect(caster_state: BattleUnitState, skill_data: Dictionary) -> void:
	var effect_type := String(skill_data.get("effect_type", ""))
	match effect_type:
		"cannon_aoe":
			_apply_unique_skill_cannon_aoe(caster_state, skill_data)
		"ally_attack_buff":
			_apply_unique_skill_ally_attack_buff(caster_state, skill_data)
		"self_defense_single":
			_apply_unique_skill_self_defense_single(caster_state, skill_data)
		"single_damage_adjacent_shake":
			_apply_unique_skill_single_damage_adjacent_shake(caster_state, skill_data)
		_:
			_apply_unique_skill_self_defense_single(caster_state, skill_data)
	_update_all_unit_visuals_from_state()
	_update_ally_ready_frames()
	_refresh_formation_slot_guides()
	_refresh_strategy_status_icon_labels()
	_cleanup_dead_units()


func _apply_unique_skill_cannon_aoe(caster_state: BattleUnitState, skill_data: Dictionary) -> void:
	var target_states := _get_unique_skill_cannon_aoe_targets(caster_state, skill_data)
	if target_states.is_empty():
		_append_battle_log("고유특기 대상 없음")
		return
	var damage := _get_unique_skill_effect_amount(caster_state, skill_data, "power", UNIQUE_SKILL_AOE_DAMAGE)
	var hit_count := 0
	for target_state in target_states:
		var target_damage := _apply_wounded_incoming_damage_penalty(target_state, damage)
		var applied := target_state.apply_damage(target_damage)
		if applied <= 0:
			continue
		hit_count += 1
		var target_pos := _get_visual_anchor_position_for_unit(target_state)
		_update_unit_visuals_from_state(target_state)
		_spawn_hit_battle_dust_fx(target_pos)
		_spawn_hit_spark_fx(target_pos)
		_spawn_skill_damage_number_fx(target_pos, applied)
	if hit_count > 0:
		_append_battle_log("적군 다수에게 %d 피해" % damage)


func _apply_unique_skill_ally_attack_buff(caster_state: BattleUnitState, skill_data: Dictionary) -> void:
	var buff_amount := _get_unique_skill_effect_amount(caster_state, skill_data, "power", UNIQUE_SKILL_ATTACK_BUFF)
	var affected_count := 0
	for ally_state in _get_unique_skill_valid_targets(caster_state, skill_data):
		if _has_active_unique_skill_attack_buff(ally_state):
			continue
		ally_state.attack += buff_amount
		_set_unique_skill_attack_buff_state(ally_state, buff_amount, UNIQUE_SKILL_ATTACK_BUFF_TURNS)
		affected_count += 1
		_spawn_buff_number_fx(_get_visual_anchor_position_for_unit(ally_state), "+공 %d" % buff_amount)
	if affected_count > 0:
		_append_battle_log("%s 공격력 상승" % _get_side_display_name(caster_state.side))


func _apply_unique_skill_self_defense_single(caster_state: BattleUnitState, skill_data: Dictionary) -> void:
	var target_state := _find_unique_skill_enemy_target(caster_state)
	if target_state == null:
		_append_battle_log("고유특기 대상 없음")
		return
	var damage := _get_directional_attack_damage(_get_unique_skill_effect_amount(caster_state, skill_data, "power", UNIQUE_SKILL_DEFAULT_DAMAGE), caster_state, target_state, false, true)
	var angle_type := _get_attack_angle_type(caster_state, target_state)
	var applied := target_state.apply_damage(damage)
	var defense_bonus := _get_unique_skill_effect_amount(caster_state, skill_data, "defense_bonus", UNIQUE_SKILL_DEFENSE_BUFF)
	caster_state.defense += defense_bonus
	_set_unique_skill_defense_buff_state(caster_state, defense_bonus)
	_update_unit_visuals_from_state(target_state)
	var target_pos := _get_visual_anchor_position_for_unit(target_state)
	_spawn_hit_battle_dust_fx(target_pos)
	_spawn_hit_spark_fx(target_pos)
	_spawn_skill_damage_number_fx(target_pos, applied)
	_show_defend_hit_reaction_if_needed(target_state)
	_spawn_buff_number_fx(_get_visual_anchor_position_for_unit(caster_state), "+방 %d" % defense_bonus)
	_append_attack_angle_log(angle_type)
	_append_battle_log("%s에게 %d 피해" % [target_state.display_name, applied])


func _apply_unique_skill_single_damage_adjacent_shake(caster_state: BattleUnitState, skill_data: Dictionary) -> void:
	var target_state := _find_unique_skill_enemy_target(caster_state)
	if target_state == null:
		_append_battle_log("고유특기 대상 없음")
		return
	var damage := _get_directional_attack_damage(_get_unique_skill_effect_amount(caster_state, skill_data, "power", UNIQUE_SKILL_DEFAULT_DAMAGE), caster_state, target_state, false, true)
	var angle_type := _get_attack_angle_type(caster_state, target_state)
	var splash_damage := _get_unique_skill_effect_amount(caster_state, skill_data, "splash", UNIQUE_SKILL_SPLASH_DAMAGE)
	var applied := target_state.apply_damage(damage)
	var target_pos := _get_visual_anchor_position_for_unit(target_state)
	_update_unit_visuals_from_state(target_state)
	_spawn_hit_battle_dust_fx(target_pos)
	_spawn_hit_spark_fx(target_pos)
	_spawn_skill_damage_number_fx(target_pos, applied)
	_show_defend_hit_reaction_if_needed(target_state)
	for adjacent_state in _get_alive_deployed_unit_states_for_side(_get_opposing_side(caster_state.side)):
		if adjacent_state == target_state:
			continue
		if get_unit_grid_distance(target_state, adjacent_state) > 1:
			continue
		var adjusted_splash_damage := _apply_wounded_incoming_damage_penalty(adjacent_state, splash_damage)
		var splash_applied := adjacent_state.apply_damage(adjusted_splash_damage)
		_update_unit_visuals_from_state(adjacent_state)
		_spawn_skill_damage_number_fx(_get_visual_anchor_position_for_unit(adjacent_state), splash_applied)
	_append_attack_angle_log(angle_type)
	_append_battle_log("%s에게 %d 피해" % [target_state.display_name, applied])


func _find_unique_skill_enemy_target(caster_state: BattleUnitState) -> BattleUnitState:
	if caster_state == null:
		return null
	var skill_data := _get_unique_skill_for_unit(caster_state)
	if skill_data.is_empty():
		return null
	if (
		selected_attack_target_state != null
		and _is_unit_state_available_for_battle_slot(selected_attack_target_state)
		and selected_attack_target_state.side != caster_state.side
		and _is_valid_unique_skill_target(caster_state, skill_data, selected_attack_target_state)
	):
		return selected_attack_target_state
	return _get_best_unique_skill_target_for_actor(caster_state, skill_data)


func _get_opposing_side(side: String) -> String:
	if side == "ally":
		return "enemy"
	return "ally"


func _get_side_display_name(side: String) -> String:
	if side == "enemy":
		return "적군"
	return "아군"


func _get_direction_from_positions(from_cell: Vector2i, to_cell: Vector2i) -> String:
	var delta := to_cell - from_cell
	if absi(delta.x) >= absi(delta.y):
		if delta.x > 0:
			return FACING_RIGHT
		if delta.x < 0:
			return FACING_LEFT
	if delta.y > 0:
		return FACING_DOWN
	if delta.y < 0:
		return FACING_UP
	return FACING_RIGHT


func _get_opposite_facing(facing: String) -> String:
	match _normalize_facing(facing):
		FACING_LEFT:
			return FACING_RIGHT
		FACING_RIGHT:
			return FACING_LEFT
		FACING_UP:
			return FACING_DOWN
		FACING_DOWN:
			return FACING_UP
		_:
			return FACING_LEFT


func _get_attack_angle_type(attacker_state: BattleUnitState, defender_state: BattleUnitState) -> String:
	if attacker_state == null or defender_state == null:
		return ATTACK_ANGLE_FRONT
	var incoming_direction := _get_direction_from_positions(defender_state.grid_cell, attacker_state.grid_cell)
	var defender_facing := _normalize_facing(defender_state.facing)
	if incoming_direction == defender_facing:
		return ATTACK_ANGLE_FRONT
	if incoming_direction == _get_opposite_facing(defender_facing):
		return ATTACK_ANGLE_BACK
	return ATTACK_ANGLE_SIDE


func _get_attack_angle_damage_multiplier(angle_type: String) -> float:
	match angle_type:
		ATTACK_ANGLE_BACK:
			return BACK_ATTACK_DAMAGE_MULTIPLIER
		ATTACK_ANGLE_SIDE:
			return SIDE_ATTACK_DAMAGE_MULTIPLIER
		_:
			return FRONT_ATTACK_DAMAGE_MULTIPLIER


func _get_directional_attack_damage(base_damage: int, attacker_state: BattleUnitState, defender_state: BattleUnitState, apply_attacker_wounded_penalty := true, should_log_wounded_penalty := false) -> int:
	var angle_type := _get_attack_angle_type(attacker_state, defender_state)
	var damage_multiplier := _get_attack_angle_damage_multiplier(angle_type)
	if _has_strategy_status_effect(attacker_state, STATUS_SHAKE):
		damage_multiplier *= STRATEGY_SHAKE_ATTACK_MULTIPLIER
	if _has_strategy_status_effect(defender_state, STATUS_SHAKE):
		damage_multiplier *= STRATEGY_SHAKE_DEFENSE_DAMAGE_MULTIPLIER
	if defender_state != null and defender_state.is_defending:
		damage_multiplier *= DEFEND_DAMAGE_MULTIPLIER
	var damage := maxi(1, int(round(float(base_damage) * damage_multiplier)))
	if apply_attacker_wounded_penalty:
		damage = _apply_wounded_amount_multiplier(attacker_state, "attack", damage, should_log_wounded_penalty)
	return _apply_wounded_incoming_damage_penalty(defender_state, damage, should_log_wounded_penalty)


func _show_defend_hit_reaction_if_needed(defender_state: BattleUnitState) -> void:
	if defender_state == null or not defender_state.is_defending:
		return
	_spawn_strategy_text_fx(_get_visual_anchor_position_for_unit(defender_state), "◆ 방어", _get_status_display_color("defend"))


func _append_attack_angle_log(angle_type: String) -> void:
	if angle_type == ATTACK_ANGLE_BACK:
		_append_battle_log("후방 공격!")
	elif angle_type == ATTACK_ANGLE_SIDE:
		_append_battle_log("측면 공격!")


func _get_unique_skill_cooldown_key(unit_state: BattleUnitState) -> String:
	return _get_hero_id_for_unit_state(unit_state)


func _set_unique_skill_cooldown(unit_state: BattleUnitState, cooldown_turns: int) -> void:
	var cooldown_key := _get_unique_skill_cooldown_key(unit_state)
	if cooldown_key == "":
		return
	unique_skill_cooldowns_by_hero_id[cooldown_key] = maxi(cooldown_turns, 0)


func _tick_unique_skill_cooldowns_for_side(side: String) -> void:
	var seen_keys: Dictionary = {}
	for unit_state in _get_alive_deployed_unit_states_for_side(side):
		var cooldown_key := _get_unique_skill_cooldown_key(unit_state)
		if cooldown_key == "" or seen_keys.has(cooldown_key):
			continue
		seen_keys[cooldown_key] = true
		var remaining := int(unique_skill_cooldowns_by_hero_id.get(cooldown_key, 0))
		if remaining > 0:
			unique_skill_cooldowns_by_hero_id[cooldown_key] = remaining - 1
	_tick_unique_skill_attack_buffs_for_side(side)


func _get_unique_skill_attack_buff_key(unit_state: BattleUnitState) -> String:
	if unit_state == null:
		return ""
	return unit_state.unit_id


func _has_active_unique_skill_attack_buff(unit_state: BattleUnitState) -> bool:
	var buff_key := _get_unique_skill_attack_buff_key(unit_state)
	if buff_key == "":
		return false
	return int(unique_skill_attack_buff_turns_by_unit_id.get(buff_key, 0)) > 0


func _get_unique_skill_attack_buff_bonus(unit_state: BattleUnitState) -> int:
	var buff_key := _get_unique_skill_attack_buff_key(unit_state)
	if buff_key == "":
		return 0
	if int(unique_skill_attack_buff_turns_by_unit_id.get(buff_key, 0)) <= 0:
		return 0
	return maxi(int(unique_skill_attack_buff_bonus_by_unit_id.get(buff_key, 0)), 0)


func _set_unique_skill_attack_buff_state(unit_state: BattleUnitState, bonus: int, turns: int) -> void:
	var buff_key := _get_unique_skill_attack_buff_key(unit_state)
	if buff_key == "":
		return
	unique_skill_attack_buff_bonus_by_unit_id[buff_key] = bonus
	unique_skill_attack_buff_turns_by_unit_id[buff_key] = maxi(turns, 0)


func _get_unique_skill_defense_buff_key(unit_state: BattleUnitState) -> String:
	if unit_state == null or unit_state.unit_id == "":
		return ""
	return unit_state.unit_id


func _get_unique_skill_defense_buff_bonus(unit_state: BattleUnitState) -> int:
	var buff_key := _get_unique_skill_defense_buff_key(unit_state)
	if buff_key == "":
		return 0
	return maxi(int(unique_skill_defense_buff_bonus_by_unit_id.get(buff_key, 0)), 0)


func _set_unique_skill_defense_buff_state(unit_state: BattleUnitState, bonus: int) -> void:
	var buff_key := _get_unique_skill_defense_buff_key(unit_state)
	if buff_key == "":
		return
	var current_bonus := maxi(int(unique_skill_defense_buff_bonus_by_unit_id.get(buff_key, 0)), 0)
	unique_skill_defense_buff_bonus_by_unit_id[buff_key] = maxi(current_bonus, bonus)


func _tick_unique_skill_attack_buffs_for_side(side: String) -> void:
	for unit_state in _get_alive_deployed_unit_states_for_side(side):
		var buff_key := _get_unique_skill_attack_buff_key(unit_state)
		if buff_key == "":
			continue
		var remaining := int(unique_skill_attack_buff_turns_by_unit_id.get(buff_key, 0))
		if remaining <= 0:
			continue
		remaining -= 1
		if remaining <= 0:
			var bonus := int(unique_skill_attack_buff_bonus_by_unit_id.get(buff_key, 0))
			if bonus > 0:
				unit_state.attack = maxi(0, unit_state.attack - bonus)
			unique_skill_attack_buff_turns_by_unit_id.erase(buff_key)
			unique_skill_attack_buff_bonus_by_unit_id.erase(buff_key)
		else:
			unique_skill_attack_buff_turns_by_unit_id[buff_key] = remaining
	_refresh_formation_slot_guides()
	_refresh_strategy_status_icon_labels()


func _finalize_unique_skill_action(caster_state: BattleUnitState, skill_data: Dictionary) -> void:
	_hide_unique_skill_toast()
	_hide_specialty_skill_cutin()
	is_unique_skill_presenting = false
	is_demo_animating = false
	_reset_unit_group_positions()
	_hide_all_move_dust_sprites()
	_set_all_unit_group_modulates(Color.WHITE)
	_clear_attack_target_selection()
	_clear_strategy_targeting_state()
	_hide_strategy_range_overlay()
	_clear_pending_move_snapshot()
	_clear_auto_action_flags()
	_set_unique_skill_cooldown(caster_state, int(skill_data.get("cooldown_turns", 0)))
	if bool(skill_data.get("consumes_action", true)):
		if caster_state != null and caster_state.side == "enemy":
			_mark_enemy_unit_acted(caster_state)
		else:
			_mark_ally_unit_acted(caster_state)
	if caster_state != null and caster_state.side == "ally":
		_show_unit_closeup_for_ally(caster_state)
	_update_ally_ready_frames()
	_cleanup_dead_units()
	if _is_battle_result_finalized():
		_set_phase(PHASE_ALLY_TURN)
		return
	if caster_state != null and caster_state.side == "enemy":
		_return_to_ally_turn()
		return
	_set_phase(PHASE_ENEMY_TURN)
	_append_battle_log("적군 턴")
	_play_enemy_turn_demo()


func _set_phase(new_phase: String) -> void:
	if new_phase != PHASE_ALLY_TURN:
		_stop_active_ally_turn_pulse()
	current_phase = new_phase
	match current_phase:
		PHASE_ALLY_TURN:
			turn_banner.text = "아군 턴 · BATTLE %d" % battle_round
		PHASE_ENEMY_TURN:
			turn_banner.text = "적군 턴 · BATTLE %d" % battle_round
		PHASE_FACING_SELECT:
			turn_banner.text = "방향 선택 · BATTLE %d" % battle_round
		PHASE_ATTACK_SELECT:
			turn_banner.text = "공격 대상 선택 · BATTLE %d" % battle_round
		PHASE_UNIQUE_SKILL_TARGET_SELECT:
			turn_banner.text = "고유특기 대상 선택 · BATTLE %d" % battle_round
		PHASE_STRATEGY_SELECT:
			turn_banner.text = "책략 대상 선택 · BATTLE %d" % battle_round
		_:
			turn_banner.text = "처리 중"

	var battle_finished := _is_battle_result_finalized()
	if battle_finished:
		_handle_battle_end_guard("set_phase")
	var can_issue_ally_command := (
		current_phase == PHASE_ALLY_TURN
		and not is_demo_animating
		and not battle_finished
		and _is_active_ally_action_available()
	)
	var active_unit_has_moved := active_unit_state != null and active_unit_state.has_moved
	basic_attack_button.disabled = not can_issue_ally_command
	move_button.disabled = not can_issue_ally_command or active_unit_has_moved
	if wait_button != null:
		wait_button.disabled = not can_issue_ally_command
	if end_turn_button != null:
		end_turn_button.disabled = not can_issue_ally_command
	_refresh_auto_battle_button_state(can_issue_ally_command)
	if current_phase == PHASE_FACING_SELECT or current_phase == PHASE_ATTACK_SELECT or current_phase == PHASE_UNIQUE_SKILL_TARGET_SELECT or current_phase == PHASE_STRATEGY_SELECT:
		basic_attack_button.disabled = true
		move_button.disabled = true
		if wait_button != null:
			wait_button.disabled = true
		if end_turn_button != null:
			end_turn_button.disabled = true
		_refresh_auto_battle_button_state(false)
	if current_phase == PHASE_FACING_SELECT:
		_show_facing_selection_panel()
	else:
		_hide_facing_selection_panel()
	_update_ally_ready_frames()
	_refresh_floating_ally_command_panel()
	_refresh_formation_slot_guides()
	if current_phase == PHASE_ALLY_TURN and not is_demo_animating and not battle_finished:
		call_deferred("_consume_confused_ally_turn_if_needed")
	if current_phase == PHASE_ALLY_TURN and is_full_auto_battle_enabled and not is_demo_animating and not battle_finished:
		call_deferred("_tick_full_auto_battle_if_needed")


func _configure_floating_ally_command_panel() -> void:
	if floating_ally_command_panel != null:
		floating_ally_command_panel.visible = false
		floating_ally_command_panel.z_index = 200
		floating_ally_command_panel.modulate = Color(1.0, 1.0, 1.0, 1.0)
		floating_ally_command_panel.mouse_filter = Control.MOUSE_FILTER_STOP
		var panel_style := StyleBoxFlat.new()
		panel_style.bg_color = Color(0.09, 0.1, 0.13, 1.0)
		panel_style.border_color = Color(0.84, 0.76, 0.54, 1.0)
		panel_style.set_border_width_all(2)
		panel_style.set_corner_radius_all(8)
		floating_ally_command_panel.add_theme_stylebox_override("panel", panel_style)
	if floating_unique_skill_button != null:
		floating_unique_skill_button.disabled = true
		floating_unique_skill_button.tooltip_text = ""
	if floating_tactics_button != null:
		floating_tactics_button.disabled = true
		floating_tactics_button.text = STRATEGY_NAME
		floating_tactics_button.tooltip_text = "지력 80 이상 필요"
		floating_tactics_button.set_meta("strategy_id", STRATEGY_ID)
	if floating_move_button != null:
		floating_move_button.disabled = true
		floating_move_button.text = "방어"
		floating_move_button.tooltip_text = ""
	for button in [
		floating_basic_attack_button,
		floating_unique_skill_button,
		floating_tactics_button,
		floating_move_button,
		floating_wait_button,
	]:
		_apply_floating_command_button_style(button)


func _configure_command_bar() -> void:
	if command_bar != null:
		command_bar.mouse_filter = Control.MOUSE_FILTER_PASS
		var transparent_style := StyleBoxEmpty.new()
		command_bar.add_theme_stylebox_override("panel", transparent_style)
	if command_bar_label != null:
		command_bar_label.visible = false
	if basic_attack_button != null:
		basic_attack_button.visible = false
		basic_attack_button.disabled = true
	if move_button != null:
		move_button.visible = false
		move_button.disabled = true
	if wait_button != null:
		wait_button.visible = false
		wait_button.disabled = true
	if retreat_button != null:
		retreat_button.disabled = true
		retreat_button.tooltip_text = "후퇴"
	if end_turn_button != null:
		end_turn_button.tooltip_text = "턴 종료"
	if auto_battle_button != null:
		auto_battle_button.tooltip_text = "자동전투"


func _apply_floating_command_button_style(button: Button) -> void:
	if button == null:
		return
	button.z_index = 201
	button.modulate = Color(1.0, 1.0, 1.0, 1.0)
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.add_theme_color_override("font_color", Color(0.97, 0.95, 0.9, 1.0))
	button.add_theme_color_override("font_disabled_color", Color(0.72, 0.71, 0.68, 1.0))
	button.add_theme_color_override("font_focus_color", Color(0.99, 0.97, 0.94, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.98, 0.94, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(1.0, 0.98, 0.94, 1.0))
	var normal_style := StyleBoxFlat.new()
	normal_style.bg_color = Color(0.16, 0.18, 0.23, 1.0)
	normal_style.border_color = Color(0.88, 0.8, 0.58, 1.0)
	normal_style.set_border_width_all(2)
	normal_style.set_corner_radius_all(6)
	var hover_style := normal_style.duplicate()
	hover_style.bg_color = Color(0.24, 0.27, 0.33, 1.0)
	var pressed_style := normal_style.duplicate()
	pressed_style.bg_color = Color(0.11, 0.12, 0.16, 1.0)
	var disabled_style := normal_style.duplicate()
	disabled_style.bg_color = Color(0.2, 0.2, 0.2, 1.0)
	disabled_style.border_color = Color(0.48, 0.48, 0.48, 1.0)
	button.add_theme_stylebox_override("normal", normal_style)
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_stylebox_override("pressed", pressed_style)
	button.add_theme_stylebox_override("disabled", disabled_style)


func _should_show_floating_ally_command_panel() -> bool:
	if floating_ally_command_panel == null:
		return false
	if not is_floating_ally_command_panel_requested:
		return false
	if _is_tactical_target_selection_mode():
		return false
	if _is_battle_result_finalized():
		return false
	if is_demo_animating:
		return false
	if is_full_auto_battle_enabled:
		return false
	if current_phase != PHASE_ALLY_TURN:
		return false
	if active_unit_state == null:
		return false
	if active_unit_side != "ally":
		return false
	if not _is_unit_state_available_for_battle_slot(active_unit_state):
		return false
	return true


func _refresh_floating_ally_command_panel() -> void:
	if floating_ally_command_panel == null:
		return
	if not _should_show_floating_ally_command_panel():
		floating_ally_command_panel.visible = false
		return

	var can_issue_ally_command := (
		current_phase == PHASE_ALLY_TURN
		and not is_demo_animating
		and _is_active_ally_action_available()
	)
	if floating_basic_attack_button != null:
		floating_basic_attack_button.disabled = not can_issue_ally_command
	if floating_move_button != null:
		floating_move_button.disabled = not can_issue_ally_command
		floating_move_button.text = "방어"
		floating_move_button.tooltip_text = ""
	if floating_wait_button != null:
		floating_wait_button.disabled = not can_issue_ally_command
	if floating_unique_skill_button != null:
		var skill_data := _get_unique_skill_for_unit(active_unit_state)
		floating_unique_skill_button.disabled = current_phase != PHASE_ALLY_TURN or not _can_use_unique_skill(active_unit_state)
		if not skill_data.is_empty():
			floating_unique_skill_button.text = String(skill_data.get("name", "고유특기"))
		else:
			floating_unique_skill_button.text = "고유특기"
		floating_unique_skill_button.tooltip_text = ""
	if floating_tactics_button != null:
		floating_tactics_button.disabled = not can_issue_ally_command or not _can_use_strategy(active_unit_state)
		floating_tactics_button.text = STRATEGY_NAME
		if active_unit_state != null and active_unit_state.intelligence < STRATEGY_BASIC_INTELLIGENCE:
			floating_tactics_button.tooltip_text = "지력 80 이상 필요"
		else:
			floating_tactics_button.tooltip_text = ""
	_position_floating_ally_command_panel()
	floating_ally_command_panel.visible = true


func _hide_floating_ally_command_panel_for_tactical_selection() -> void:
	is_floating_ally_command_panel_requested = false
	if floating_ally_command_panel != null:
		floating_ally_command_panel.visible = false
		floating_ally_command_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _restore_floating_ally_command_panel_input() -> void:
	if floating_ally_command_panel != null:
		floating_ally_command_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	for button in [
		floating_basic_attack_button,
		floating_unique_skill_button,
		floating_tactics_button,
		floating_move_button,
		floating_wait_button,
	]:
		if button != null:
			button.mouse_filter = Control.MOUSE_FILTER_STOP


func _position_floating_ally_command_panel() -> void:
	if floating_ally_command_panel == null or active_unit_state == null:
		return
	_restore_floating_ally_command_panel_input()
	var ui_anchor := _world_to_battle_ui_position(_get_visual_anchor_position_for_unit(active_unit_state))
	var panel_size := floating_ally_command_panel.size
	var minimum_size := floating_ally_command_panel.get_combined_minimum_size()
	panel_size.x = maxf(panel_size.x, minimum_size.x)
	panel_size.y = maxf(panel_size.y, minimum_size.y)
	if panel_size.x <= 0.0 or panel_size.y <= 0.0:
		panel_size = Vector2(176.0, 214.0)
	floating_ally_command_panel.size = panel_size
	var desired_position := _choose_floating_ally_command_panel_position(ui_anchor, panel_size)
	floating_ally_command_panel.position = desired_position


func _is_tactical_target_selection_mode() -> bool:
	return (
		current_phase == PHASE_ATTACK_SELECT
		or current_phase == PHASE_STRATEGY_SELECT
		or current_phase == PHASE_UNIQUE_SKILL_TARGET_SELECT
	)


func _choose_floating_ally_command_panel_position(ui_anchor: Vector2, panel_size: Vector2) -> Vector2:
	var viewport_size := get_viewport_rect().size
	var cell_rects := _get_visible_tactical_cell_ui_rects()
	var candidates := _get_floating_ally_command_panel_candidate_positions(ui_anchor, panel_size, viewport_size)
	var best_position := _clamp_floating_ally_command_panel_position(
		ui_anchor + Vector2(52.0, -panel_size.y - FLOATING_COMMAND_PANEL_ANCHOR_GAP),
		panel_size,
		viewport_size
	)
	var best_score := INF
	for index in range(candidates.size()):
		var clamped_position := _clamp_floating_ally_command_panel_position(candidates[index], panel_size, viewport_size)
		var is_far_fallback := index >= FLOATING_COMMAND_PANEL_NEAR_CANDIDATE_COUNT
		var score := _score_floating_ally_command_panel_position(clamped_position, panel_size, cell_rects, ui_anchor, is_far_fallback) + (float(index) * 0.01)
		if score < best_score:
			best_score = score
			best_position = clamped_position
	return best_position


func _get_floating_ally_command_panel_candidate_positions(ui_anchor: Vector2, panel_size: Vector2, viewport_size: Vector2) -> Array[Vector2]:
	var gap := FLOATING_COMMAND_PANEL_ANCHOR_GAP
	return [
		ui_anchor + Vector2(gap, -panel_size.y * 0.5),
		ui_anchor + Vector2(-panel_size.x - gap, -panel_size.y * 0.5),
		ui_anchor + Vector2(-panel_size.x * 0.5, -panel_size.y - gap),
		ui_anchor + Vector2(-panel_size.x * 0.5, gap),
		ui_anchor + Vector2(gap, gap),
		ui_anchor + Vector2(-panel_size.x - gap, gap),
		ui_anchor + Vector2(gap, -panel_size.y - gap),
		ui_anchor + Vector2(-panel_size.x - gap, -panel_size.y - gap),
		Vector2(viewport_size.x - panel_size.x - FLOATING_COMMAND_PANEL_VIEWPORT_MARGIN, viewport_size.y - panel_size.y - FLOATING_COMMAND_PANEL_VIEWPORT_MARGIN),
		Vector2(FLOATING_COMMAND_PANEL_VIEWPORT_MARGIN, viewport_size.y - panel_size.y - FLOATING_COMMAND_PANEL_VIEWPORT_MARGIN),
		Vector2(viewport_size.x - panel_size.x - FLOATING_COMMAND_PANEL_VIEWPORT_MARGIN, FLOATING_COMMAND_PANEL_VIEWPORT_MARGIN),
		Vector2(FLOATING_COMMAND_PANEL_VIEWPORT_MARGIN, FLOATING_COMMAND_PANEL_VIEWPORT_MARGIN),
	]


func _clamp_floating_ally_command_panel_position(panel_position: Vector2, panel_size: Vector2, viewport_size: Vector2) -> Vector2:
	return Vector2(
		clampf(panel_position.x, FLOATING_COMMAND_PANEL_VIEWPORT_MARGIN, maxf(FLOATING_COMMAND_PANEL_VIEWPORT_MARGIN, viewport_size.x - panel_size.x - FLOATING_COMMAND_PANEL_VIEWPORT_MARGIN)),
		clampf(panel_position.y, FLOATING_COMMAND_PANEL_VIEWPORT_MARGIN, maxf(FLOATING_COMMAND_PANEL_VIEWPORT_MARGIN, viewport_size.y - panel_size.y - FLOATING_COMMAND_PANEL_VIEWPORT_MARGIN))
	)


func _score_floating_ally_command_panel_position(panel_position: Vector2, panel_size: Vector2, cell_rects: Array[Rect2], ui_anchor: Vector2, is_far_fallback: bool) -> float:
	var panel_rect := Rect2(panel_position, panel_size)
	panel_rect = panel_rect.grow(FLOATING_COMMAND_PANEL_GRID_AVOID_PADDING)
	var score := 0.0
	for cell_rect in cell_rects:
		score += _get_rect_overlap_area(panel_rect, cell_rect)
	var panel_center := panel_position + (panel_size * 0.5)
	score += panel_center.distance_to(ui_anchor) * FLOATING_COMMAND_PANEL_DISTANCE_SCORE_WEIGHT
	if is_far_fallback:
		score += FLOATING_COMMAND_PANEL_FAR_FALLBACK_SCORE
	return score


func _get_rect_overlap_area(a: Rect2, b: Rect2) -> float:
	var left := maxf(a.position.x, b.position.x)
	var top := maxf(a.position.y, b.position.y)
	var right := minf(a.position.x + a.size.x, b.position.x + b.size.x)
	var bottom := minf(a.position.y + a.size.y, b.position.y + b.size.y)
	if right <= left or bottom <= top:
		return 0.0
	return (right - left) * (bottom - top)


func _get_visible_tactical_cell_ui_rects() -> Array[Rect2]:
	var rects: Array[Rect2] = []
	var camera := _get_main_camera_or_null()
	var zoom := Vector2.ONE
	if camera != null and camera.enabled:
		zoom = camera.zoom
	for cell_rect in move_range_cells:
		if cell_rect == null or not cell_rect.visible:
			continue
		var local_center := cell_rect.position + (cell_rect.size * 0.5)
		var world_center := local_center
		if cell_rect.get_parent() is Node2D:
			world_center = (cell_rect.get_parent() as Node2D).to_global(local_center)
		var ui_center := _world_to_battle_ui_position(world_center)
		var ui_size := Vector2(absf(cell_rect.size.x * zoom.x * cell_rect.scale.x), absf(cell_rect.size.y * zoom.y * cell_rect.scale.y))
		if ui_size.x <= 0.0 or ui_size.y <= 0.0:
			continue
		rects.append(Rect2(ui_center - (ui_size * 0.5), ui_size))
	return rects


func _refresh_auto_battle_button_state(can_issue_ally_command: bool) -> void:
	if auto_battle_button == null:
		return
	if is_full_auto_battle_enabled:
		auto_battle_button.disabled = false
		auto_battle_button.tooltip_text = "자동중지"
		return
	auto_battle_button.disabled = not can_issue_ally_command
	auto_battle_button.tooltip_text = "자동전투"


func _on_defend_button_pressed() -> void:
	if current_phase != PHASE_ALLY_TURN:
		return
	if is_demo_animating:
		return
	if active_unit_state == null:
		return
	if not _is_active_ally_action_available():
		_append_battle_log("이미 행동한 부대입니다")
		_set_phase(PHASE_ALLY_TURN)
		return

	_clear_move_target_selection()
	_clear_attack_target_selection()
	_clear_strategy_targeting_state()
	_hide_move_range_overlay()
	_hide_attack_range_overlay()
	_hide_strategy_range_overlay()
	_hide_unique_skill_range_overlay()
	_hide_facing_selection_panel()
	if move_highlight != null:
		move_highlight.visible = false
	if attack_highlight != null:
		attack_highlight.visible = false
	if floating_ally_command_panel != null:
		floating_ally_command_panel.visible = false
	is_floating_ally_command_panel_requested = false

	active_unit_state.is_defending = true
	active_unit_state.last_action = {"type": "defend"}
	var recovered_troops := _recover_wounded_troops_for_defend(active_unit_state)
	var active_anchor := _get_visual_anchor_position_for_unit(active_unit_state)
	_spawn_strategy_text_fx(active_anchor, "◆ 방어!", _get_status_display_color("defend"))
	if recovered_troops > 0:
		_spawn_defend_heal_text_fx(active_anchor, "+%d" % recovered_troops)
		_update_unit_visuals_from_state(active_unit_state)
		_append_battle_log("%s이 방어 태세를 취하고 부상병 %d명을 수습했습니다." % [active_unit_state.display_name, recovered_troops])
	else:
		_append_battle_log("%s이 방어 태세를 취했습니다." % active_unit_state.display_name)
	_mark_ally_unit_acted(active_unit_state)
	_show_unit_closeup_for_ally(active_unit_state)
	_update_ally_ready_frames()
	_refresh_formation_slot_guides()
	_refresh_strategy_status_icon_labels()
	_cleanup_dead_units()
	if _is_battle_result_finalized():
		_set_phase(PHASE_ALLY_TURN)
		return
	_set_phase(PHASE_ENEMY_TURN)
	_append_battle_log("적군 턴")
	_play_enemy_turn_demo()


func _recover_wounded_troops_for_defend(unit_state: BattleUnitState) -> int:
	if unit_state == null:
		return 0
	var missing_hp := maxi(unit_state.max_hp - unit_state.current_hp, 0)
	if missing_hp <= 0:
		return 0
	var recovery_amount := maxi(1, int(round(float(missing_hp) * DEFEND_WOUNDED_RECOVERY_RATE)))
	return unit_state.heal(recovery_amount)


func _end_ally_turn_by_wait() -> void:
	if current_phase != PHASE_ALLY_TURN:
		return
	if is_demo_animating:
		return
	if active_unit_state == null:
		return
	if not _is_active_ally_action_available():
		_append_battle_log("이미 행동한 부대입니다")
		_set_phase(PHASE_ALLY_TURN)
		return

	_clear_move_target_selection()
	_clear_attack_target_selection()
	_clear_strategy_targeting_state()
	_hide_move_range_overlay()
	_hide_attack_range_overlay()
	_hide_strategy_range_overlay()
	_hide_facing_selection_panel()
	if move_highlight != null:
		move_highlight.visible = false
	if attack_highlight != null:
		attack_highlight.visible = false

	_clear_pending_move_snapshot()
	active_unit_state.has_moved = true
	ally_has_moved = true
	_mark_ally_unit_acted(active_unit_state)
	_show_unit_closeup_for_ally(active_unit_state)
	_update_ally_ready_frames()

	_append_battle_log("%s 대기" % _get_selected_ally_display_name())
	_set_phase(PHASE_ENEMY_TURN)
	_append_battle_log("적군 턴")
	_play_enemy_turn_demo()


func _can_use_direct_move_click() -> bool:
	if current_phase != PHASE_ALLY_TURN:
		return false
	if is_demo_animating:
		return false
	if _is_battle_result_finalized():
		return false
	if _is_mouse_over_battle_ui():
		return false
	if active_unit_state == null or active_unit_side != "ally":
		return false
	if active_unit_state.has_moved:
		return false
	if not _is_active_ally_action_available():
		return false
	return _is_move_range_overlay_visible()


func _is_move_range_overlay_visible() -> bool:
	if move_range_overlay_layer == null:
		return false
	for child in move_range_overlay_layer.get_children():
		var overlay_cell := child as CanvasItem
		if overlay_cell != null and overlay_cell.visible:
			return true
	return false


func _try_handle_valid_move_cell_click(mouse_world_pos: Vector2) -> bool:
	if current_phase != PHASE_ALLY_TURN:
		return false
	if active_unit_state == null or battle_grid_controller == null:
		return false
	var target_cell := battle_grid_controller.world_to_grid(mouse_world_pos)
	if not battle_grid_controller.is_in_bounds(target_cell):
		return false
	if not is_valid_move_target(target_cell):
		return false

	var origin_cell := get_active_move_origin_cell()
	var distance := battle_grid_controller.get_distance(origin_cell, target_cell)
	var move_range := get_active_move_range()
	var is_occupied := is_cell_occupied(target_cell)
	print("Move target selected: %s occupied=%s VALID=true distance=%d range=%d" % [
		_format_cell(target_cell),
		str(is_occupied),
		distance,
		move_range,
	])
	if _try_direct_move_to_cell(target_cell):
		return true

	set_move_target_cell(target_cell)
	return true


func _try_direct_move_to_cell(target_cell: Vector2i) -> bool:
	if not _can_use_direct_move_click():
		return false
	if battle_grid_controller == null or not battle_grid_controller.is_in_bounds(target_cell):
		return false
	if not _is_valid_destination_for_unit(target_cell, active_unit_state, true):
		_append_battle_log("다른 부대가 있어 이동할 수 없습니다")
		return false
	if not is_valid_move_target(target_cell):
		return false
	set_move_target_cell(target_cell)
	play_basic_move_demo()
	return is_demo_animating or current_phase == PHASE_RESOLVING or current_phase == PHASE_FACING_SELECT


func _show_facing_selection_panel() -> void:
	_position_facing_arrow_panel_near_ally()
	if facing_selection_panel != null:
		facing_selection_panel.visible = false
	if facing_arrow_panel != null:
		facing_arrow_panel.visible = true
	_apply_facing_arrow_panel_visual_style()
	var facing_arrow_panel_position := Vector2.ZERO
	var facing_arrow_panel_size := Vector2.ZERO
	if facing_arrow_panel != null:
		facing_arrow_panel_position = facing_arrow_panel.position
		facing_arrow_panel_size = facing_arrow_panel.size
	_play_facing_arrow_button_pop()
	print("SHOW FACING ARROW PANEL visible=%s pos=%s size=%s" % [
		str(facing_arrow_panel != null and facing_arrow_panel.visible),
		str(facing_arrow_panel_position),
		str(facing_arrow_panel_size),
	])


func _hide_facing_selection_panel() -> void:
	_clear_facing_arrow_button_tweens()
	if facing_selection_panel != null:
		facing_selection_panel.visible = false
	if facing_arrow_panel != null:
		facing_arrow_panel.visible = false


func _position_facing_arrow_panel_near_ally() -> void:
	if facing_arrow_panel == null:
		return
	if active_unit_state == null:
		return
	if battle_grid_controller == null:
		return

	facing_arrow_panel.position = Vector2.ZERO
	facing_arrow_panel.size = get_viewport_rect().size

	var center_cell := active_unit_state.grid_cell
	_place_facing_arrow_button_on_cell(face_up_arrow_button, center_cell + Vector2i(0, -1), "↑")
	_place_facing_arrow_button_on_cell(face_down_arrow_button, center_cell + Vector2i(0, 1), "↓")
	_place_facing_arrow_button_on_cell(face_left_arrow_button, center_cell + Vector2i(-1, 0), "←")
	_place_facing_arrow_button_on_cell(face_right_arrow_button, center_cell + Vector2i(1, 0), "→")


func _place_facing_arrow_button_on_cell(button: Button, cell: Vector2i, arrow_text: String) -> void:
	if button == null:
		return
	if battle_grid_controller == null:
		button.visible = false
		button.disabled = true
		return
	if not battle_grid_controller.is_in_bounds(cell):
		button.visible = false
		button.disabled = true
		return

	var cell_size := battle_grid_controller.get_cell_size()
	if cell_size.x <= 0.0 or cell_size.y <= 0.0:
		button.visible = false
		button.disabled = true
		return

	var button_size := cell_size * FACING_ARROW_BUTTON_SIZE_SCALE
	var world_center := battle_grid_controller.grid_to_world(cell)
	var ui_position := _world_to_battle_ui_position(world_center)

	button.text = arrow_text
	button.size = button_size
	button.position = ui_position - (button_size * 0.5)
	button.visible = true
	button.disabled = false


func _apply_facing_arrow_panel_visual_style() -> void:
	if facing_arrow_panel != null:
		facing_arrow_panel.modulate = Color(1.0, 1.0, 1.0, FACING_ARROW_PANEL_ALPHA)
	if face_up_arrow_button != null:
		_apply_facing_arrow_button_style(face_up_arrow_button)
	if face_down_arrow_button != null:
		_apply_facing_arrow_button_style(face_down_arrow_button)
	if face_left_arrow_button != null:
		_apply_facing_arrow_button_style(face_left_arrow_button)
	if face_right_arrow_button != null:
		_apply_facing_arrow_button_style(face_right_arrow_button)


func _apply_facing_arrow_button_style(button: Button) -> void:
	if button == null:
		return

	button.set_script(BattleFacingArrowTileButtonScript)
	button.modulate = Color(1.0, 1.0, 1.0, FACING_ARROW_BUTTON_ALPHA)
	button.flat = true
	if button.has_method("set_tile_style"):
		button.call("set_tile_style", Color(1.0, 0.86, 0.42, 0.22), Color(1.0, 0.92, 0.65, 0.62), Color(1.0, 0.98, 0.82, 0.28))

	var normal := StyleBoxEmpty.new()
	var hover := StyleBoxEmpty.new()
	var pressed := StyleBoxEmpty.new()
	var disabled := StyleBoxEmpty.new()

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_color_override("font_color", Color(1.0, 0.96, 0.78, 0.9))
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.98, 0.82, 0.95))
	button.add_theme_color_override("font_pressed_color", Color(1.0, 0.98, 0.82, 1.0))
	button.add_theme_color_override("font_disabled_color", Color(0.92, 0.82, 0.45, 0.6))
	button.add_theme_color_override("font_outline_color", Color(0.1, 0.07, 0.0, 0.8))
	button.add_theme_constant_override("outline_size", 3)
	button.add_theme_font_size_override("font_size", 36)


func _clear_facing_arrow_button_tweens() -> void:
	for tween in facing_arrow_button_tweens:
		if tween != null:
			tween.kill()
	facing_arrow_button_tweens.clear()


func _play_facing_arrow_button_pop() -> void:
	_clear_facing_arrow_button_tweens()
	var buttons := [face_up_arrow_button, face_right_arrow_button, face_down_arrow_button, face_left_arrow_button]
	for index in range(buttons.size()):
		var button := buttons[index] as Button
		if button == null or not button.visible:
			continue
		button.pivot_offset = button.size * 0.5
		button.modulate = Color(1.0, 1.0, 1.0, 0.0)
		button.scale = Vector2(0.78, 0.78)
		var tween := create_tween()
		facing_arrow_button_tweens.append(tween)
		tween.tween_interval(float(index) * 0.025)
		tween.set_parallel(true)
		tween.tween_property(button, "modulate:a", FACING_ARROW_BUTTON_ALPHA, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(button, "scale", Vector2(1.10, 1.10), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.chain()
		tween.tween_property(button, "scale", Vector2.ONE, 0.06).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _enter_post_move_facing_selection() -> void:
	print("ENTER FACING SELECT")
	_set_facing_indicators_visible(false)
	_set_phase(PHASE_FACING_SELECT)
	_hide_move_range_overlay()
	_clear_move_target_selection()
	_clear_attack_target_selection()
	if move_highlight != null:
		move_highlight.visible = false
	if attack_highlight != null:
		attack_highlight.visible = false
	_append_battle_log("방향 선택")
	_show_facing_selection_panel()


func _clear_auto_action_flags() -> void:
	is_auto_action_in_progress = false
	should_auto_select_facing_after_move = false


func _select_post_move_facing(facing: String) -> void:
	if current_phase != PHASE_FACING_SELECT:
		return
	if active_unit_state == null:
		return

	_set_unit_facing(active_unit_state, facing)
	ally_has_manual_facing = true
	_apply_unit_facing_visuals()
	_reset_unit_group_positions()
	_update_facing_indicators()
	_set_facing_indicators_visible(true)
	_hide_facing_selection_panel()
	_hide_attack_range_overlay()
	_append_battle_log("방향 결정: %s" % facing)
	_clear_attack_target_selection()
	_clear_pending_move_snapshot()
	_clear_auto_action_flags()
	is_floating_ally_command_panel_requested = true
	_set_phase(PHASE_ALLY_TURN)
	_start_idle_breathing()
	_refresh_move_target_feedback()
	_show_move_range_overlay_for_active_unit()
	_refresh_floating_ally_command_panel()


func _append_battle_log(line: String) -> void:
	battle_log_lines.append(line)
	while battle_log_lines.size() > MAX_BATTLE_LOG_LINES:
		battle_log_lines.pop_front()
	_refresh_battle_log()


func _refresh_battle_log() -> void:
	var log_text := "전투 기록"
	for line in battle_log_lines:
		log_text += "\n- %s" % line
	battle_log_preview.text = log_text
	if battle_mini_log_label != null:
		var mini_log_text := ""
		for line in battle_log_lines:
			if mini_log_text != "":
				mini_log_text += "\n"
			mini_log_text += "- %s" % line
		if mini_log_text == "":
			mini_log_text = "- 대기 중"
		battle_mini_log_label.text = mini_log_text


func _configure_layout_guides() -> void:
	if left_panel != null:
		left_panel.visible = false
		left_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if right_panel != null:
		right_panel.visible = false
		right_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if battle_mini_log_panel != null:
		battle_mini_log_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var mini_log_style := StyleBoxFlat.new()
		mini_log_style.bg_color = Color(0.03, 0.04, 0.06, 0.82)
		mini_log_style.border_color = Color(0.88, 0.79, 0.56, 0.28)
		mini_log_style.set_border_width_all(1)
		mini_log_style.set_corner_radius_all(8)
		battle_mini_log_panel.add_theme_stylebox_override("panel", mini_log_style)
	if battle_mini_log_title_label != null:
		battle_mini_log_title_label.add_theme_color_override("font_color", Color(0.96, 0.91, 0.8, 1.0))
		battle_mini_log_title_label.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.04, 0.88))
		battle_mini_log_title_label.add_theme_constant_override("outline_size", 2)
	if battle_mini_log_label != null:
		battle_mini_log_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.88, 1.0))
		battle_mini_log_label.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.04, 0.78))
		battle_mini_log_label.add_theme_constant_override("outline_size", 1)
	if formation_slot_guide_layer != null:
		formation_slot_guide_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for panel in [ally_formation_guide_panel, enemy_formation_guide_panel]:
		if panel == null:
			continue
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var panel_style := StyleBoxFlat.new()
		panel_style.bg_color = Color(0.025, 0.03, 0.04, 0.76)
		panel_style.border_color = Color(0.82, 0.74, 0.54, 0.22)
		panel_style.set_border_width_all(1)
		panel_style.set_corner_radius_all(8)
		panel.add_theme_stylebox_override("panel", panel_style)
	for title_label in [
		get_node_or_null("BattleUI/FormationSlotGuideLayer/AllyFormationGuidePanel/TitleLabel") as Label,
		get_node_or_null("BattleUI/FormationSlotGuideLayer/EnemyFormationGuidePanel/TitleLabel") as Label,
	]:
		if title_label == null:
			continue
		title_label.add_theme_color_override("font_color", Color(0.96, 0.91, 0.8, 1.0))
		title_label.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.04, 0.82))
		title_label.add_theme_constant_override("outline_size", 2)
	for slot_id in ALLY_FORMATION_GUIDE_SLOT_IDS:
		_configure_formation_guide_slot(slot_id)
	for slot_id in ENEMY_FORMATION_GUIDE_SLOT_IDS:
		_configure_formation_guide_slot(slot_id)


func _configure_formation_guide_slot(slot_id: String) -> void:
	var nodes := _get_formation_guide_panel_nodes(slot_id)
	var root := nodes.get("root", null) as Panel
	if root == null:
		return
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child_name in ["Portrait", "NameLabel", "HpLabel", "StatusLabel", "TroopIconRect", "TroopTypeLabel"]:
		var child := root.get_node_or_null(child_name) as Control
		if child != null:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var name_label := root.get_node_or_null("NameLabel") as Label
	var hp_label := root.get_node_or_null("HpLabel") as Label
	var status_label := root.get_node_or_null("StatusLabel") as Label
	var troop_type_label := root.get_node_or_null("TroopTypeLabel") as Label
	for label in [name_label, hp_label, troop_type_label]:
		if label == null:
			continue
		label.add_theme_color_override("font_color", Color(0.93, 0.91, 0.86, 1.0))
		label.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.04, 0.72))
		label.add_theme_constant_override("outline_size", 1)
	if name_label != null:
		name_label.add_theme_font_size_override("font_size", 15)
	if hp_label != null:
		hp_label.add_theme_font_size_override("font_size", 12)
	if troop_type_label != null:
		troop_type_label.add_theme_font_size_override("font_size", 12)
		troop_type_label.add_theme_color_override("font_color", Color(0.98, 0.93, 0.78, 1.0))
		troop_type_label.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.04, 0.84))
		troop_type_label.add_theme_constant_override("outline_size", 2)
	if status_label != null:
		status_label.visible = false
		status_label.text = ""
		status_label.position = Vector2(66.0, 52.0)
		status_label.size = Vector2(94.0, 18.0)
		status_label.clip_text = true
		status_label.autowrap_mode = TextServer.AUTOWRAP_OFF
		status_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		status_label.add_theme_font_size_override("font_size", 9)
		status_label.add_theme_color_override("font_color", FORMATION_STATUS_TEXT_COLOR)
		status_label.add_theme_color_override("font_outline_color", FORMATION_STATUS_OUTLINE_COLOR)
		status_label.add_theme_constant_override("outline_size", 2)
	var troop_icon_rect := root.get_node_or_null("TroopIconRect") as TextureRect
	if troop_icon_rect != null:
		troop_icon_rect.position = Vector2(164.0, 6.0)
		troop_icon_rect.size = Vector2(46.0, 46.0)
		troop_icon_rect.custom_minimum_size = Vector2(46.0, 46.0)
		troop_icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		troop_icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		troop_icon_rect.modulate = Color(1.0, 0.98, 0.9, 1.0)
	if troop_type_label != null:
		troop_type_label.position = Vector2(164.0, 54.0)
		troop_type_label.size = Vector2(46.0, 14.0)


# v0.64p-hotfix Enemy Highlight Cleanup
func _clear_transient_battle_highlights() -> void:
	if move_highlight != null:
		move_highlight.visible = false
	if attack_highlight != null:
		attack_highlight.visible = false


func _configure_ally_ready_frames() -> void:
	_apply_ready_frame_style(ally_ready_frame)
	_apply_ready_frame_style(ally_support_ready_frame)


func _apply_ready_frame_style(frame: Panel) -> void:
	if frame == null:
		return
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1.0, 0.88, 0.42, 0.035)
	style.border_color = Color(1.0, 0.88, 0.48, 0.58)
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	frame.add_theme_stylebox_override("panel", style)
	frame.pivot_offset = frame.size * 0.5


func _configure_unit_closeup_panel() -> void:
	if unit_closeup_panel == null:
		return
	unit_closeup_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	unit_closeup_panel.visible = false
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.02, 0.027, 0.035, 0.82)
	style.border_color = Color(0.92, 0.82, 0.58, 0.38)
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	unit_closeup_panel.add_theme_stylebox_override("panel", style)
	unit_closeup_panel.pivot_offset = unit_closeup_panel.size * 0.5
	for child in unit_closeup_panel.get_children():
		if child is Control:
			(child as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	for label in [closeup_name_label, closeup_troop_label, closeup_status_label]:
		if label is Label:
			(label as Label).add_theme_color_override("font_color", Color(0.95, 0.91, 0.82, 1.0))
			(label as Label).add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.04, 0.85))
			(label as Label).add_theme_constant_override("outline_size", 2)
	if closeup_name_label != null:
		closeup_name_label.add_theme_font_size_override("font_size", 18)
	if closeup_troop_label != null:
		closeup_troop_label.add_theme_font_size_override("font_size", 13)
	if closeup_status_label != null:
		closeup_status_label.add_theme_font_size_override("font_size", 14)


func _update_ally_ready_frames() -> void:
	for unit_state in _get_all_unit_states_in_slot_order():
		if unit_state == null or unit_state.side != "ally":
			continue
		_update_ready_frame_for_unit(_get_ready_frame_for_unit(unit_state), unit_state)


func _update_ready_frame_for_unit(frame: Control, unit_state: BattleUnitState) -> void:
	if frame == null:
		return
	var should_show := _is_ally_unit_ready_for_action(unit_state)
	if not should_show:
		if frame.visible:
			_stop_ready_frame_pulse(frame)
		frame.visible = false
		return

	_position_ready_frame_for_unit(frame, unit_state)
	var is_selected := unit_state == active_unit_state
	if not frame.visible:
		var frame_alpha := 0.68
		if is_selected:
			frame_alpha = 0.9
		frame.modulate = Color(1.0, 0.94, 0.62, frame_alpha)
		frame.visible = true
		_start_ready_frame_pulse(frame)


func _position_ready_frame_for_unit(frame: Control, unit_state: BattleUnitState) -> void:
	if frame == null or unit_state == null:
		return
	var anchor := _get_visual_anchor_position_for_unit(unit_state)
	var ui_center := _world_to_battle_ui_position(anchor + Vector2(0.0, -6.0))
	var frame_size := Vector2(118.0, 112.0)
	if battle_grid_controller != null:
		var cell_size := battle_grid_controller.get_cell_size()
		if cell_size.x > 0.0 and cell_size.y > 0.0:
			frame_size = Vector2(cell_size.x * 0.98, cell_size.y * 0.9)
	frame.size = frame_size
	frame.position = ui_center - (frame_size * 0.5)
	frame.pivot_offset = frame_size * 0.5


func _is_ally_unit_ready_for_action(unit_state: BattleUnitState) -> bool:
	if unit_state == null:
		return false
	if unit_state.side != "ally":
		return false
	if not _is_unit_state_available_for_battle_slot(unit_state):
		return false
	if current_phase != PHASE_ALLY_TURN:
		return false
	if is_demo_animating:
		return false
	if _is_active_ally_locked() and unit_state != active_unit_state:
		return false
	return not _has_ally_unit_acted(unit_state)


func _start_ready_frame_pulse(frame: Control) -> void:
	if frame == null:
		return
	_stop_ready_frame_pulse(frame)
	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(frame, "modulate:a", 0.42, 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(frame, "modulate:a", 0.78, 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	if frame == ally_ready_frame:
		ally_ready_frame_tween = tween
	elif frame == ally_support_ready_frame:
		ally_support_ready_frame_tween = tween
	elif frame == ally_main_03_ready_frame:
		ally_main_03_ready_frame_tween = tween
	elif frame == ally_reinforce_01_ready_frame:
		ally_reinforce_01_ready_frame_tween = tween
	elif frame == ally_reinforce_02_ready_frame:
		ally_reinforce_02_ready_frame_tween = tween


func _stop_ready_frame_pulse(frame: Control) -> void:
	if frame == ally_ready_frame and ally_ready_frame_tween != null:
		ally_ready_frame_tween.kill()
		ally_ready_frame_tween = null
	elif frame == ally_support_ready_frame and ally_support_ready_frame_tween != null:
		ally_support_ready_frame_tween.kill()
		ally_support_ready_frame_tween = null
	elif frame == ally_main_03_ready_frame and ally_main_03_ready_frame_tween != null:
		ally_main_03_ready_frame_tween.kill()
		ally_main_03_ready_frame_tween = null
	elif frame == ally_reinforce_01_ready_frame and ally_reinforce_01_ready_frame_tween != null:
		ally_reinforce_01_ready_frame_tween.kill()
		ally_reinforce_01_ready_frame_tween = null
	elif frame == ally_reinforce_02_ready_frame and ally_reinforce_02_ready_frame_tween != null:
		ally_reinforce_02_ready_frame_tween.kill()
		ally_reinforce_02_ready_frame_tween = null


func _show_unit_closeup_for_ally(unit_state: BattleUnitState) -> void:
	if unit_closeup_panel == null or unit_state == null or unit_state.side != "ally":
		return
	if not unit_state.is_alive():
		_hide_unit_closeup_panel()
		return

	if closeup_hero_portrait != null:
		closeup_hero_portrait.texture = _get_closeup_portrait_texture_for_unit(unit_state)
	if closeup_troop_image != null:
		closeup_troop_image.texture = _get_ally_token_texture_for_unit(unit_state)
	if closeup_name_label != null:
		closeup_name_label.text = unit_state.display_name
	if closeup_troop_label != null:
		closeup_troop_label.text = "병력 %d / %d" % [unit_state.current_troops, unit_state.max_troops]
	if closeup_status_label != null:
		var strategy_status_text := _get_strategy_status_icon_text(unit_state)
		if strategy_status_text == "":
			closeup_status_label.text = _get_unit_action_status_text(unit_state)
		else:
			closeup_status_label.text = "%s · %s" % [_get_unit_action_status_text(unit_state), strategy_status_text]

	if unit_closeup_tween != null:
		unit_closeup_tween.kill()
	unit_closeup_tween = null
	unit_closeup_panel.visible = false
	_refresh_formation_slot_guides()


func _hide_unit_closeup_panel() -> void:
	if unit_closeup_tween != null:
		unit_closeup_tween.kill()
		unit_closeup_tween = null
	if unit_closeup_panel != null:
		unit_closeup_panel.visible = false
	_refresh_formation_slot_guides()


func _refresh_formation_slot_guides() -> void:
	for slot_id in ALLY_FORMATION_GUIDE_SLOT_IDS:
		_refresh_formation_slot_guide_for_entry(slot_id)
	for slot_id in ENEMY_FORMATION_GUIDE_SLOT_IDS:
		_refresh_formation_slot_guide_for_entry(slot_id)


func _refresh_formation_slot_guide_for_entry(slot_id: String) -> void:
	var nodes := _get_formation_guide_panel_nodes(slot_id)
	var root := nodes.get("root", null) as Panel
	if root == null:
		return
	var portrait := nodes.get("portrait", null) as TextureRect
	var name_label := nodes.get("name_label", null) as Label
	var hp_label := nodes.get("hp_label", null) as Label
	var status_label := nodes.get("status_label", null) as Label
	var troop_icon_rect := nodes.get("troop_icon_rect", null) as TextureRect
	var troop_type_label := nodes.get("troop_type_label", null) as Label
	var unique_skill_ready_icon := nodes.get("unique_skill_ready_icon", null) as TextureRect
	var unit_state := _get_formation_guide_unit_state_for_capacity_slot_id(slot_id)
	var slot_metadata := _get_capacity_slot_metadata(slot_id)
	var panel_side := "ally" if slot_id.begins_with("ally_") else "enemy"
	var is_worldmap_context_slot := str(slot_metadata.get("worldmap_context_side", "")) != ""
	var slot_is_active := bool(slot_metadata.get("is_active", false))
	var slot_is_context_empty := bool(slot_metadata.get("worldmap_context_empty", false))
	if is_worldmap_context_slot and (slot_is_context_empty or not slot_is_active):
		root.visible = false
		root.modulate = Color(1.0, 1.0, 1.0, 1.0)
		if portrait != null:
			portrait.texture = null
		if name_label != null:
			name_label.text = "미배치"
		if hp_label != null:
			hp_label.text = "병력 -"
		if status_label != null:
			status_label.text = ""
			status_label.visible = false
		if troop_icon_rect != null:
			troop_icon_rect.texture = null
			troop_icon_rect.visible = false
		if troop_type_label != null:
			troop_type_label.text = ""
		_set_formation_slot_unique_skill_ready_icon(unique_skill_ready_icon, false)
		_log_roster_panel_slot_state(
			slot_id,
			"hidden:%s:%s" % [str(slot_is_active), str(slot_is_context_empty)],
			"[ROSTER_PANEL_SKIP] source=worldmap_context side=%s slot=%s active=%s reason=hidden_empty_slot" % [
				panel_side,
				slot_id,
				str(slot_is_active)
			]
		)
		return
	root.visible = true
	var hero_id := ""
	if is_worldmap_context_slot:
		hero_id = String(slot_metadata.get("assigned_hero_id", ""))
	elif unit_state != null:
		hero_id = _get_hero_id_for_unit_state(unit_state)
	if hero_id == "":
		hero_id = String(slot_metadata.get("assigned_hero_id", ""))
	if hero_id == "" and not is_worldmap_context_slot:
		hero_id = _get_test_battle_roster_hero_id(slot_id)
	if is_worldmap_context_slot and hero_id == "":
		root.visible = false
		if portrait != null:
			portrait.texture = null
		if name_label != null:
			name_label.text = "미배치"
		if hp_label != null:
			hp_label.text = "병력 -"
		if status_label != null:
			status_label.text = ""
			status_label.visible = false
		if troop_icon_rect != null:
			troop_icon_rect.texture = null
			troop_icon_rect.visible = false
		if troop_type_label != null:
			troop_type_label.text = ""
		_set_formation_slot_unique_skill_ready_icon(unique_skill_ready_icon, false)
		_log_roster_panel_slot_state(
			slot_id,
			"hidden:missing_context_hero",
			"[ROSTER_PANEL_SKIP] source=worldmap_context side=%s slot=%s active=%s reason=missing_context_hero" % [
				panel_side,
				slot_id,
				str(slot_is_active)
			]
		)
		return
	var hero_entry := _get_hero_registry_entry(hero_id)
	var display_name := String(hero_entry.get("display_name", "미배치"))
	if unit_state != null and unit_state.display_name != "":
		display_name = unit_state.display_name
	display_name = _get_hero_display_name_with_state(hero_id, display_name, hero_entry)
	var is_deployed := unit_state != null and _is_unit_state_deployed_by_capacity_slot(unit_state)
	var is_alive := unit_state != null and unit_state.is_alive()
	var is_active := unit_state != null and unit_state == active_unit_state and is_deployed and is_alive
	var visual_key := _get_formation_guide_visual_key(slot_id, unit_state, hero_entry)
	if name_label != null:
		name_label.text = display_name
	if hp_label != null:
		if unit_state != null:
			hp_label.text = "병력 %d / %d" % [unit_state.current_troops, unit_state.max_troops]
		else:
			hp_label.text = "병력 -"
	if status_label != null:
		var status_text := _get_formation_status_summary_text(unit_state)
		status_label.text = status_text
		status_label.add_theme_color_override("font_color", _get_unit_status_summary_color(unit_state))
		status_label.visible = status_text != ""
	if portrait != null:
		portrait.custom_minimum_size = Vector2(52.0, 52.0)
		portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		portrait.texture = _resolve_hero_portrait_texture(hero_entry)
	if troop_icon_rect != null:
		troop_icon_rect.texture = _get_troop_icon_texture_for_visual_key(visual_key, unit_state)
		troop_icon_rect.visible = troop_icon_rect.texture != null
	if troop_type_label != null:
		troop_type_label.text = _get_troop_type_label_for_visual_key(visual_key, _get_formation_guide_unit_type(slot_id, unit_state, hero_entry))
	_set_formation_slot_unique_skill_ready_icon(unique_skill_ready_icon, _is_unique_skill_ready_for_formation_guide(unit_state))
	var panel_source := "worldmap_context" if is_worldmap_context_slot else "sample_battle"
	var panel_reason := "context_slot" if is_worldmap_context_slot else "sample_fallback"
	_log_roster_panel_slot_state(
		slot_id,
		"shown:%s:%s:%s" % [panel_source, hero_id, str(slot_is_active)],
		"[ROSTER_PANEL_SLOT] source=%s side=%s slot=%s hero_id=%s display_name=%s active=%s reason=%s" % [
			panel_source,
			panel_side,
			slot_id,
			hero_id,
			display_name,
			str(slot_is_active),
			panel_reason
		]
	)
	var style := StyleBoxFlat.new()
	style.set_corner_radius_all(6)
	style.set_border_width_all(1)
	if is_active:
		style.bg_color = Color(0.26, 0.2, 0.08, 0.96)
		style.border_color = Color(1.0, 0.86, 0.46, 0.98)
		style.set_border_width_all(2)
		root.modulate = Color(1.0, 1.0, 1.0, 1.0)
	elif is_deployed and is_alive:
		style.bg_color = Color(0.12, 0.14, 0.17, 0.92)
		style.border_color = Color(0.82, 0.76, 0.62, 0.42)
		root.modulate = Color(1.0, 1.0, 1.0, 0.98)
	elif is_deployed and not is_alive:
		style.bg_color = Color(0.13, 0.08, 0.08, 0.8)
		style.border_color = Color(0.5, 0.24, 0.24, 0.4)
		root.modulate = Color(0.66, 0.66, 0.66, 0.74)
	else:
		style.bg_color = Color(0.055, 0.065, 0.08, 0.78)
		style.border_color = Color(0.38, 0.38, 0.42, 0.22)
		root.modulate = Color(0.68, 0.68, 0.68, 0.84)
	root.add_theme_stylebox_override("panel", style)


func _log_roster_panel_slot_state(slot_id: String, signature: String, message: String) -> void:
	var log_key := "%s|%s" % [slot_id, signature]
	if bool(roster_panel_slot_log_signatures.get(log_key, false)):
		return
	roster_panel_slot_log_signatures[log_key] = true
	print(message)


func _get_formation_guide_unit_state_for_capacity_slot_id(slot_id: String) -> BattleUnitState:
	return _get_unit_state_for_capacity_slot_id(slot_id)


func _get_formation_guide_panel_nodes(slot_id: String) -> Dictionary:
	var node_path := String(FORMATION_GUIDE_SLOT_NODE_PATHS.get(slot_id, ""))
	if node_path == "":
		return {}
	var root := get_node_or_null(node_path) as Panel
	if root == null:
		return {}
	return {
		"root": root,
		"portrait": root.get_node_or_null("Portrait") as TextureRect,
		"name_label": root.get_node_or_null("NameLabel") as Label,
		"hp_label": root.get_node_or_null("HpLabel") as Label,
		"status_label": root.get_node_or_null("StatusLabel") as Label,
		"troop_icon_rect": root.get_node_or_null("TroopIconRect") as TextureRect,
		"troop_type_label": root.get_node_or_null("TroopTypeLabel") as Label,
		"unique_skill_ready_icon": root.get_node_or_null("UniqueSkillReadyIcon") as TextureRect,
	}


func _get_unique_skill_remaining_cooldown_turns(unit_state: BattleUnitState) -> int:
	if unit_state == null:
		return 0
	var skill_data := _get_unique_skill_for_unit(unit_state)
	if skill_data.is_empty():
		return 0
	var cooldown_key := _get_unique_skill_cooldown_key(unit_state)
	if cooldown_key == "":
		return 0
	return maxi(int(unique_skill_cooldowns_by_hero_id.get(cooldown_key, 0)), 0)


func _is_unique_skill_ready_for_formation_guide(unit_state: BattleUnitState) -> bool:
	if unit_state == null:
		return false
	if _get_unique_skill_remaining_cooldown_turns(unit_state) > 0:
		return false
	return _can_use_unique_skill(unit_state)


func _set_formation_slot_unique_skill_ready_icon(icon_rect: TextureRect, should_show: bool) -> void:
	if icon_rect == null:
		return
	icon_rect.visible = should_show


func _get_formation_guide_visual_key(slot_id: String, unit_state: BattleUnitState, hero_entry: Dictionary) -> String:
	if unit_state != null and unit_state.visual_key != "":
		return unit_state.visual_key
	var slot_metadata := _get_capacity_slot_metadata(slot_id)
	var slot_visual_key := String(slot_metadata.get("visual_key", ""))
	if slot_visual_key != "":
		return slot_visual_key
	if unit_state != null and unit_state.unit_type != "":
		var side_prefix := "ally"
		if unit_state.side == "enemy":
			side_prefix = "enemy"
		return "%s_%s" % [side_prefix, _normalize_unit_type(unit_state.unit_type)]
	var default_visual_key := String(hero_entry.get("default_visual_key", ""))
	if default_visual_key != "":
		return default_visual_key
	if slot_id.begins_with("enemy_"):
		return "enemy_infantry"
	return "ally_infantry"


func _get_formation_guide_unit_type(slot_id: String, unit_state: BattleUnitState, hero_entry: Dictionary) -> String:
	if unit_state != null and unit_state.unit_type != "":
		return unit_state.unit_type
	var visual_key := _get_formation_guide_visual_key(slot_id, unit_state, hero_entry)
	return _infer_unit_type_from_visual_key(visual_key)


func _infer_unit_type_from_visual_key(visual_key: String) -> String:
	var normalized_key := visual_key.to_lower()
	if normalized_key.contains("archer") or normalized_key.contains("bow"):
		return UNIT_TYPE_ARCHER
	if normalized_key.contains("gunner") or normalized_key.contains("firearm") or normalized_key.contains("arquebus"):
		return UNIT_TYPE_GUNNER
	if normalized_key.contains("cavalry") or normalized_key.contains("horse"):
		return UNIT_TYPE_CAVALRY
	if normalized_key.contains("infantry") or normalized_key.contains("spear") or normalized_key.contains("sword"):
		return UNIT_TYPE_INFANTRY
	return UNIT_TYPE_INFANTRY


func _get_troop_type_label_for_visual_key(visual_key: String, fallback_unit_type: String = "") -> String:
	var unit_type := fallback_unit_type
	if unit_type == "":
		unit_type = _infer_unit_type_from_visual_key(visual_key)
	unit_type = _normalize_unit_type(unit_type)
	match unit_type:
		UNIT_TYPE_ARCHER:
			return "궁병"
		UNIT_TYPE_GUNNER:
			return "총병"
		UNIT_TYPE_CAVALRY:
			return "기병"
		_:
			return "보병"


func _get_troop_icon_texture_for_visual_key(visual_key: String, unit_state: BattleUnitState = null) -> Texture2D:
	if unit_state != null:
		var live_texture := _get_visual_token_texture_for_unit(unit_state, _get_unit_facing(unit_state))
		if live_texture != null:
			return live_texture
	var direct_texture := _get_troop_icon_texture_from_token_paths(visual_key)
	if direct_texture != null:
		return direct_texture
	var inferred_type := _infer_unit_type_from_visual_key(visual_key)
	for fallback_key in _get_troop_icon_fallback_keys(visual_key, inferred_type):
		var fallback_texture := _get_troop_icon_texture_from_token_paths(fallback_key)
		if fallback_texture != null:
			return fallback_texture
	return null


func _get_troop_icon_texture_from_token_paths(visual_key: String) -> Texture2D:
	var visual_paths: Dictionary = UNIT_VISUAL_TOKEN_PATHS.get(visual_key, {})
	if visual_paths.is_empty():
		return null
	var texture := _load_optional_texture(String(visual_paths.get("base", "")))
	if texture != null:
		return texture
	return _load_optional_texture(String(visual_paths.get("down", "")))


func _get_troop_icon_fallback_keys(visual_key: String, unit_type: String) -> Array[String]:
	var normalized_type := _normalize_unit_type(unit_type)
	var fallback_keys: Array[String] = []
	if visual_key.begins_with("china_"):
		fallback_keys.append("china_%s" % normalized_type)
	elif visual_key.begins_with("korea_"):
		fallback_keys.append("korea_%s" % normalized_type)
	elif visual_key.begins_with("japan_"):
		fallback_keys.append("japan_%s" % normalized_type)
	elif visual_key.begins_with("enemy_"):
		fallback_keys.append("enemy_%s" % normalized_type)
	else:
		fallback_keys.append("ally_%s" % normalized_type)
	fallback_keys.append("ally_%s" % normalized_type)
	fallback_keys.append("enemy_%s" % normalized_type)
	fallback_keys.append("korea_%s" % normalized_type)
	fallback_keys.append("china_%s" % normalized_type)
	return fallback_keys


func _get_closeup_portrait_texture_for_unit(unit_state: BattleUnitState) -> Texture2D:
	var hero_entry := _get_hero_registry_entry(_get_hero_id_for_unit_state(unit_state))
	return _resolve_hero_portrait_texture(hero_entry)


func _get_ally_portrait_texture_for_unit(unit_state: BattleUnitState) -> Texture2D:
	var hero_entry := _get_hero_registry_entry(_get_hero_id_for_unit_state(unit_state))
	var resolved_texture := _resolve_hero_portrait_texture(hero_entry)
	if resolved_texture != null:
		return resolved_texture
	var slot := _get_unit_visual_slot_for_state(unit_state)
	if slot != null and slot.portrait != null:
		return slot.portrait.texture
	if unit_state == ally_support_unit_state and ally_support_portrait_badge != null:
		return ally_support_portrait_badge.texture
	if unit_state == ally_main_03_unit_state and ally_main_03_portrait_badge != null:
		return ally_main_03_portrait_badge.texture
	if ally_portrait_badge != null:
		return ally_portrait_badge.texture
	return null


func _get_ally_token_texture_for_unit(unit_state: BattleUnitState) -> Texture2D:
	return _get_visual_token_texture_for_unit(unit_state, _get_unit_facing(unit_state))


func _get_visual_token_for_unit(unit_state: BattleUnitState) -> Sprite2D:
	if unit_state == null:
		return null
	var slot := _get_unit_visual_slot_for_state(unit_state)
	if slot != null and slot.token != null:
		return slot.token
	return null


func _get_visual_portrait_badge_for_unit(unit_state: BattleUnitState) -> Sprite2D:
	if unit_state == null:
		return null
	var slot := _get_unit_visual_slot_for_state(unit_state)
	if slot != null and slot.portrait != null:
		return slot.portrait
	return null


func _get_visual_root_for_unit(unit_state: BattleUnitState) -> Node2D:
	if unit_state == null:
		return null
	var slot := _get_unit_visual_slot_for_state(unit_state)
	if slot != null and slot.root != null:
		return slot.root as Node2D
	return null


func _get_visual_token_base_scale_for_unit(unit_state: BattleUnitState) -> Vector2:
	if unit_state == null:
		return Vector2.ONE
	if unit_state.slot_id != "":
		match unit_state.slot_id:
			"ally_main":
				return ally_token_base_scale
			"ally_support":
				return ally_support_token_base_scale
			"ally_main_03":
				return ally_main_03_token_base_scale
			"ally_reinforce_01":
				return ally_reinforce_01_token_base_scale
			"ally_reinforce_02":
				return ally_reinforce_02_token_base_scale
			"enemy_main":
				return enemy_token_base_scale
			"enemy_support":
				return enemy_support_token_base_scale
			"enemy_main_03":
				return enemy_main_03_token_base_scale
			"enemy_reinforce_01":
				return enemy_reinforce_01_token_base_scale
			"enemy_reinforce_02":
				return enemy_reinforce_02_token_base_scale
	if unit_state == ally_unit_state:
		return ally_token_base_scale
	if unit_state == ally_support_unit_state:
		return ally_support_token_base_scale
	if unit_state == ally_main_03_unit_state:
		return ally_main_03_token_base_scale
	if unit_state == ally_reinforce_01_unit_state:
		return ally_reinforce_01_token_base_scale
	if unit_state == ally_reinforce_02_unit_state:
		return ally_reinforce_02_token_base_scale
	if unit_state == enemy_unit_state:
		return enemy_token_base_scale
	if unit_state == enemy_support_unit_state:
		return enemy_support_token_base_scale
	if unit_state == enemy_main_03_unit_state:
		return enemy_main_03_token_base_scale
	if unit_state == enemy_reinforce_01_unit_state:
		return enemy_reinforce_01_token_base_scale
	if unit_state == enemy_reinforce_02_unit_state:
		return enemy_reinforce_02_token_base_scale
	return Vector2.ONE


func _get_visual_portrait_badge_base_scale_for_unit(unit_state: BattleUnitState) -> Vector2:
	if unit_state == null:
		return Vector2.ONE
	if unit_state.slot_id != "":
		match unit_state.slot_id:
			"ally_main":
				return ally_portrait_badge_base_scale
			"ally_support":
				return ally_support_portrait_badge_base_scale
			"ally_main_03":
				return ally_main_03_portrait_badge_base_scale
			"ally_reinforce_01":
				return ally_reinforce_01_portrait_badge_base_scale
			"ally_reinforce_02":
				return ally_reinforce_02_portrait_badge_base_scale
			"enemy_main":
				return enemy_portrait_badge_base_scale
			"enemy_support":
				return enemy_support_portrait_badge_base_scale
			"enemy_main_03":
				return enemy_main_03_portrait_badge_base_scale
			"enemy_reinforce_01":
				return enemy_reinforce_01_portrait_badge_base_scale
			"enemy_reinforce_02":
				return enemy_reinforce_02_portrait_badge_base_scale
	if unit_state == ally_unit_state:
		return ally_portrait_badge_base_scale
	if unit_state == ally_support_unit_state:
		return ally_support_portrait_badge_base_scale
	if unit_state == ally_main_03_unit_state:
		return ally_main_03_portrait_badge_base_scale
	if unit_state == ally_reinforce_01_unit_state:
		return ally_reinforce_01_portrait_badge_base_scale
	if unit_state == ally_reinforce_02_unit_state:
		return ally_reinforce_02_portrait_badge_base_scale
	if unit_state == enemy_unit_state:
		return enemy_portrait_badge_base_scale
	if unit_state == enemy_support_unit_state:
		return enemy_support_portrait_badge_base_scale
	if unit_state == enemy_main_03_unit_state:
		return enemy_main_03_portrait_badge_base_scale
	if unit_state == enemy_reinforce_01_unit_state:
		return enemy_reinforce_01_portrait_badge_base_scale
	if unit_state == enemy_reinforce_02_unit_state:
		return enemy_reinforce_02_portrait_badge_base_scale
	return Vector2.ONE


func _set_visual_portrait_badge_base_scale_for_unit(unit_state: BattleUnitState, scale_value: Vector2) -> void:
	if unit_state == null:
		return
	if unit_state.slot_id != "":
		match unit_state.slot_id:
			"ally_main":
				ally_portrait_badge_base_scale = scale_value
			"ally_support":
				ally_support_portrait_badge_base_scale = scale_value
			"ally_main_03":
				ally_main_03_portrait_badge_base_scale = scale_value
			"ally_reinforce_01":
				ally_reinforce_01_portrait_badge_base_scale = scale_value
			"ally_reinforce_02":
				ally_reinforce_02_portrait_badge_base_scale = scale_value
			"enemy_main":
				enemy_portrait_badge_base_scale = scale_value
			"enemy_support":
				enemy_support_portrait_badge_base_scale = scale_value
			"enemy_main_03":
				enemy_main_03_portrait_badge_base_scale = scale_value
			"enemy_reinforce_01":
				enemy_reinforce_01_portrait_badge_base_scale = scale_value
			"enemy_reinforce_02":
				enemy_reinforce_02_portrait_badge_base_scale = scale_value


func _get_visual_root_base_scale_for_unit(unit_state: BattleUnitState) -> Vector2:
	if unit_state == null:
		return Vector2.ONE
	if unit_state.slot_id != "":
		match unit_state.slot_id:
			"ally_main":
				return ally_visual_root_base_scale
			"ally_support":
				return ally_support_visual_root_base_scale
			"ally_main_03":
				return ally_main_03_visual_root_base_scale
			"ally_reinforce_01":
				return ally_reinforce_01_visual_root_base_scale
			"ally_reinforce_02":
				return ally_reinforce_02_visual_root_base_scale
			"enemy_main":
				return enemy_visual_root_base_scale
			"enemy_support":
				return enemy_support_visual_root_base_scale
			"enemy_main_03":
				return enemy_main_03_visual_root_base_scale
			"enemy_reinforce_01":
				return enemy_reinforce_01_visual_root_base_scale
			"enemy_reinforce_02":
				return enemy_reinforce_02_visual_root_base_scale
	if unit_state == ally_unit_state:
		return ally_visual_root_base_scale
	if unit_state == ally_support_unit_state:
		return ally_support_visual_root_base_scale
	if unit_state == ally_main_03_unit_state:
		return ally_main_03_visual_root_base_scale
	if unit_state == ally_reinforce_01_unit_state:
		return ally_reinforce_01_visual_root_base_scale
	if unit_state == ally_reinforce_02_unit_state:
		return ally_reinforce_02_visual_root_base_scale
	if unit_state == enemy_unit_state:
		return enemy_visual_root_base_scale
	if unit_state == enemy_support_unit_state:
		return enemy_support_visual_root_base_scale
	if unit_state == enemy_main_03_unit_state:
		return enemy_main_03_visual_root_base_scale
	if unit_state == enemy_reinforce_01_unit_state:
		return enemy_reinforce_01_visual_root_base_scale
	if unit_state == enemy_reinforce_02_unit_state:
		return enemy_reinforce_02_visual_root_base_scale
	return Vector2.ONE


func _apply_active_ally_turn_pulse_root_ratio(
	visual_root: Node2D,
	base_position: Vector2,
	base_scale: Vector2,
	pivot_position: Vector2,
	scale_ratio: float
) -> void:
	if visual_root == null:
		return
	var clamped_ratio := maxf(scale_ratio, 0.001)
	var ratio_vector := Vector2(clamped_ratio, clamped_ratio)
	visual_root.scale = base_scale * clamped_ratio
	visual_root.position = pivot_position + ((base_position - pivot_position) * ratio_vector)


func _stop_active_ally_turn_pulse() -> void:
	if active_ally_turn_pulse_tween != null:
		active_ally_turn_pulse_tween.kill()
		active_ally_turn_pulse_tween = null
	if active_ally_turn_pulse_root != null:
		var pulsing_root_unit_state := active_ally_turn_pulse_unit_state
		if pulsing_root_unit_state != null:
			active_ally_turn_pulse_root.scale = _get_visual_root_base_scale_for_unit(pulsing_root_unit_state)
			active_ally_turn_pulse_root.position = active_ally_turn_pulse_root_base_global_position
		active_ally_turn_pulse_root = null
	active_ally_turn_pulse_root_base_global_position = Vector2.ZERO
	active_ally_turn_pulse_root_pivot_global = Vector2.ZERO
	if active_ally_turn_pulse_token != null:
		var pulsing_unit_state := active_ally_turn_pulse_unit_state
		if pulsing_unit_state != null:
			active_ally_turn_pulse_token.scale = _get_visual_token_base_scale_for_unit(pulsing_unit_state)
		active_ally_turn_pulse_token = null
	if active_ally_turn_pulse_portrait != null:
		var pulsing_portrait_unit_state := active_ally_turn_pulse_unit_state
		if pulsing_portrait_unit_state != null:
			active_ally_turn_pulse_portrait.scale = _get_visual_portrait_badge_base_scale_for_unit(pulsing_portrait_unit_state)
		active_ally_turn_pulse_portrait = null
	active_ally_turn_pulse_unit_state = null


func _play_active_ally_turn_pulse(unit_state: BattleUnitState) -> void:
	if unit_state == null:
		return
	if unit_state.side != "ally":
		return
	if not unit_state.is_alive():
		return
	if not _is_unit_state_available_for_battle_slot(unit_state):
		return
	var visual_root := _get_visual_root_for_unit(unit_state)
	var token := _get_visual_token_for_unit(unit_state)
	if visual_root == null and token == null:
		return
	var visual_root_base_scale := _get_visual_root_base_scale_for_unit(unit_state)
	var visual_root_base_position := Vector2.ZERO
	var visual_root_pivot_position := Vector2.ZERO
	if visual_root != null:
		visual_root_base_position = visual_root.position
		var pivot_global := _get_visual_anchor_position_for_unit(unit_state)
		if visual_root.get_parent() is Node2D:
			visual_root_pivot_position = (visual_root.get_parent() as Node2D).to_local(pivot_global)
		else:
			visual_root_pivot_position = pivot_global
	var base_scale := _get_visual_token_base_scale_for_unit(unit_state)
	var portrait := _get_visual_portrait_badge_for_unit(unit_state)
	var portrait_base_scale := _get_visual_portrait_badge_base_scale_for_unit(unit_state)
	_stop_active_ally_turn_pulse()
	_stop_idle_breathing()
	if visual_root != null:
		visual_root.scale = visual_root_base_scale
		visual_root.position = visual_root_base_position
	else:
		token.scale = base_scale
		if portrait != null:
			portrait.scale = portrait_base_scale
	active_ally_turn_pulse_root = visual_root
	active_ally_turn_pulse_root_base_global_position = visual_root_base_position
	active_ally_turn_pulse_root_pivot_global = visual_root_pivot_position
	active_ally_turn_pulse_token = token
	active_ally_turn_pulse_portrait = portrait
	active_ally_turn_pulse_unit_state = unit_state
	active_ally_turn_pulse_tween = create_tween()
	if visual_root != null:
		active_ally_turn_pulse_tween.tween_method(
			func(scale_ratio: float) -> void:
				_apply_active_ally_turn_pulse_root_ratio(
					visual_root,
					visual_root_base_position,
					visual_root_base_scale,
					visual_root_pivot_position,
					scale_ratio
				),
			1.0,
			ACTIVE_ALLY_TURN_PULSE_SCALE,
			ACTIVE_ALLY_TURN_PULSE_UP_DURATION
		).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		active_ally_turn_pulse_tween.tween_method(
			func(scale_ratio: float) -> void:
				_apply_active_ally_turn_pulse_root_ratio(
					visual_root,
					visual_root_base_position,
					visual_root_base_scale,
					visual_root_pivot_position,
					scale_ratio
				),
			ACTIVE_ALLY_TURN_PULSE_SCALE,
			1.0,
			ACTIVE_ALLY_TURN_PULSE_DOWN_DURATION
		).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	else:
		active_ally_turn_pulse_tween.set_parallel(true)
		active_ally_turn_pulse_tween.tween_property(
			token,
			"scale",
			base_scale * ACTIVE_ALLY_TURN_PULSE_SCALE,
			ACTIVE_ALLY_TURN_PULSE_UP_DURATION
		).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		if portrait != null:
			active_ally_turn_pulse_tween.tween_property(
				portrait,
				"scale",
				portrait_base_scale * ACTIVE_ALLY_TURN_PULSE_SCALE,
				ACTIVE_ALLY_TURN_PULSE_UP_DURATION
			).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		active_ally_turn_pulse_tween.chain().tween_property(
			token,
			"scale",
			base_scale,
			ACTIVE_ALLY_TURN_PULSE_DOWN_DURATION
		).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		if portrait != null:
			active_ally_turn_pulse_tween.parallel().tween_property(
				portrait,
				"scale",
				portrait_base_scale,
				ACTIVE_ALLY_TURN_PULSE_DOWN_DURATION
			).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	active_ally_turn_pulse_tween.finished.connect(func() -> void:
		if visual_root != null:
			visual_root.scale = visual_root_base_scale
			visual_root.position = visual_root_base_position
		else:
			token.scale = base_scale
			if portrait != null:
				portrait.scale = portrait_base_scale
		active_ally_turn_pulse_tween = null
		active_ally_turn_pulse_root = null
		active_ally_turn_pulse_root_base_global_position = Vector2.ZERO
		active_ally_turn_pulse_root_pivot_global = Vector2.ZERO
		active_ally_turn_pulse_token = null
		active_ally_turn_pulse_portrait = null
		active_ally_turn_pulse_unit_state = null
		if not is_demo_animating and current_phase == PHASE_ALLY_TURN and not _is_battle_result_finalized():
			_start_idle_breathing()
	)


func _get_unit_action_status_text(unit_state: BattleUnitState) -> String:
	if unit_state == null or not unit_state.is_alive():
		return "DOWN"
	if _is_unit_confused(unit_state):
		return "CONFUSED"
	if _has_ally_unit_acted(unit_state):
		return "DONE"
	if unit_state.has_moved:
		return "MOVED"
	return "READY"


func _handle_right_click_cancel() -> void:
	print("[RIGHT_CLICK_CANCEL] phase=", current_phase)
	if current_phase == PHASE_FACING_SELECT:
		_rollback_pending_ally_move()
		return
	if current_phase == PHASE_ATTACK_SELECT:
		_cancel_attack_select_mode()
		return
	if current_phase == PHASE_UNIQUE_SKILL_TARGET_SELECT:
		_cancel_unique_skill_target_select_mode()
		return
	if current_phase == PHASE_STRATEGY_SELECT:
		_cancel_strategy_target_select_mode()
		return
	if current_phase == PHASE_ALLY_TURN:
		_clear_move_target_selection()
		_clear_attack_target_selection()
		_clear_unique_skill_targeting_state()
		_clear_strategy_targeting_state()
		_hide_strategy_range_overlay()
		_clear_transient_battle_highlights()
		_refresh_move_target_feedback()
		_show_move_range_overlay_for_active_unit()


func _cancel_attack_select_mode() -> void:
	if current_phase != PHASE_ATTACK_SELECT:
		return
	_hide_attack_range_overlay()
	_clear_attack_target_selection()
	_clear_transient_battle_highlights()
	is_floating_ally_command_panel_requested = true
	_set_phase(PHASE_ALLY_TURN)
	_append_battle_log("공격 취소")
	_refresh_move_target_feedback()
	_show_move_range_overlay_for_active_unit()


func _rollback_pending_ally_move() -> void:
	print("[ROLLBACK] phase=", current_phase)
	if current_phase != PHASE_FACING_SELECT:
		print("[ROLLBACK] skipped: not facing select")
		return
	if not has_pending_move_snapshot:
		print("[ROLLBACK] no snapshot")
		_set_phase(PHASE_ALLY_TURN)
		_hide_facing_selection_panel()
		_refresh_move_target_feedback()
		_show_move_range_overlay_for_active_unit()
		return

	var unit_state := pending_move_snapshot_unit_state
	if unit_state == null:
		print("[ROLLBACK] snapshot unit missing")
		_clear_pending_move_snapshot()
		_set_phase(PHASE_ALLY_TURN)
		return

	print("[ROLLBACK] unit=", unit_state.display_name, " cell=", pending_move_snapshot_grid_cell)
	active_unit_state = unit_state
	active_unit_side = "ally"
	ally_has_moved = pending_move_snapshot_ally_has_moved
	unit_state.set_grid_cell(pending_move_snapshot_grid_cell)
	unit_state.has_moved = pending_move_snapshot_has_moved
	_set_unit_facing(unit_state, pending_move_snapshot_facing)

	var unit_marker := _get_unit_marker_for_unit(unit_state)
	if unit_marker != null:
		unit_marker.position = pending_move_snapshot_unit_position
	var portrait_marker := _get_portrait_marker_for_unit(unit_state)
	if portrait_marker != null:
		portrait_marker.position = pending_move_snapshot_portrait_position
	if unit_state == ally_unit_state:
		current_ally_unit_position = pending_move_snapshot_unit_position
		current_ally_portrait_position = pending_move_snapshot_portrait_position

	_hide_facing_selection_panel()
	_hide_attack_range_overlay()
	_clear_move_target_selection()
	_clear_attack_target_selection()
	_clear_transient_battle_highlights()
	_reset_unit_group_positions()
	_set_facing_indicators_visible(true)
	_update_facing_indicators()
	_update_cell_size_visual_guide(unit_state.grid_cell)
	_set_phase(PHASE_ALLY_TURN)
	_show_move_range_overlay_for_active_unit()
	_refresh_move_target_feedback()
	_clear_pending_move_snapshot()
	_clear_auto_action_flags()
	_show_unit_closeup_for_ally(active_unit_state)
	_update_ally_ready_frames()
	_start_idle_breathing()
	print("[ROLLBACK] restored unit=", unit_state.display_name, " grid=", unit_state.grid_cell)
	_append_battle_log("이동 취소")


func _store_pending_ally_move_snapshot() -> void:
	if active_unit_state == null:
		_clear_pending_move_snapshot()
		return
	var unit_marker := _get_selected_ally_unit_marker()
	var portrait_marker := _get_selected_ally_portrait_marker()
	pending_move_snapshot_unit_state = active_unit_state
	pending_move_snapshot_grid_cell = active_unit_state.grid_cell
	pending_move_snapshot_unit_position = Vector2.ZERO
	pending_move_snapshot_portrait_position = Vector2.ZERO
	if unit_marker != null:
		pending_move_snapshot_unit_position = unit_marker.position
	if portrait_marker != null:
		pending_move_snapshot_portrait_position = portrait_marker.position
	pending_move_snapshot_facing = active_unit_state.facing
	pending_move_snapshot_has_moved = active_unit_state.has_moved
	pending_move_snapshot_ally_has_moved = ally_has_moved
	has_pending_move_snapshot = true
	print("[ROLLBACK] snapshot stored unit=", active_unit_state.display_name, " cell=", pending_move_snapshot_grid_cell)


func _clear_pending_move_snapshot() -> void:
	pending_move_snapshot_unit_state = null
	pending_move_snapshot_grid_cell = Vector2i(-1, -1)
	pending_move_snapshot_unit_position = Vector2.ZERO
	pending_move_snapshot_portrait_position = Vector2.ZERO
	pending_move_snapshot_facing = FACING_RIGHT
	pending_move_snapshot_has_moved = false
	pending_move_snapshot_ally_has_moved = false
	has_pending_move_snapshot = false


# v0.64o Enemy Basic Move + Attack AI
func _play_enemy_turn_demo() -> void:
	_play_enemy_ai_turn()


func _play_enemy_ai_turn() -> void:
	if _handle_battle_end_guard("enemy_turn_start"):
		print("[TURN_ADVANCE_BLOCKED] source=enemy_turn_start reason=result_finalized")
		return
	is_demo_animating = true
	_stop_idle_breathing()
	basic_attack_button.disabled = true
	_clear_transient_battle_highlights()
	_cleanup_dead_units()
	if _handle_battle_end_guard("enemy_turn_after_cleanup"):
		is_demo_animating = false
		print("[TURN_ADVANCE_BLOCKED] source=enemy_turn_after_cleanup reason=result_finalized")
		return
	_debug_print_combat_distance("ENEMY_TURN_START")

	var enemy_actor_state := _get_next_available_enemy_ai_actor()
	if enemy_actor_state == null:
		_append_battle_log("행동 가능한 적군 없음")
		_return_to_ally_turn()
		return

	_play_enemy_ai_for_actor(enemy_actor_state)


func _play_enemy_ai_for_actor(enemy_actor_state: BattleUnitState) -> void:
	if _handle_battle_end_guard("enemy_actor_start"):
		print("[TURN_ADVANCE_BLOCKED] source=enemy_actor_start reason=result_finalized")
		return
	if enemy_actor_state == null or not enemy_actor_state.is_alive():
		_return_to_ally_turn()
		return
	current_enemy_ai_actor_state = enemy_actor_state
	if _is_unit_confused(enemy_actor_state):
		_append_battle_log("%s은 혼란 상태로 행동할 수 없습니다." % enemy_actor_state.display_name)
		_spawn_strategy_text_fx(_get_visual_anchor_position_for_unit(enemy_actor_state), "혼란", STRATEGY_EFFECT_COLOR)
		_mark_enemy_unit_acted(enemy_actor_state)
		_return_to_ally_turn()
		return
	var immediate_attack_target := _find_best_auto_attack_target(enemy_actor_state)
	if immediate_attack_target != null and _can_auto_kill_target(enemy_actor_state, immediate_attack_target):
		_play_enemy_actor_basic_attack_from_current_cell(enemy_actor_state, immediate_attack_target)
		return
	if _try_auto_unique_skill_for_actor(enemy_actor_state, true):
		return

	var decision_plan := _get_enemy_ai_decision_plan_for_actor(enemy_actor_state)
	enemy_ai_last_destination_debug = decision_plan.duplicate(true)
	_log_enemy_ai_decision_plan(enemy_actor_state, decision_plan)
	var target_state: BattleUnitState = decision_plan.get("final_target_state", null)
	if target_state == null:
		_append_battle_log("적 행동 대상 없음")
		_mark_enemy_unit_acted(enemy_actor_state)
		_return_to_ally_turn()
		return
		
	var action_reason := str(decision_plan.get("action_reason", "WAIT"))
	if action_reason == "ATTACK":
		_play_enemy_actor_basic_attack_from_current_cell(enemy_actor_state, target_state)
		return

	var destination: Vector2i = decision_plan.get("destination", enemy_actor_state.grid_cell)
	if destination == enemy_actor_state.grid_cell:
		_append_battle_log("%s 대기" % enemy_actor_state.display_name)
		_mark_enemy_unit_acted(enemy_actor_state)
		_return_to_ally_turn()
		return

	_reserve_enemy_ai_decision_plan_for_actor(enemy_actor_state, decision_plan)
	var move_path := _find_enemy_move_path_for_actor(enemy_actor_state, enemy_actor_state.grid_cell, destination)
	if move_path.is_empty() or move_path.size() < 2:
		_append_battle_log("%s 이동 경로 없음" % enemy_actor_state.display_name)
		_mark_enemy_unit_acted(enemy_actor_state)
		_return_to_ally_turn()
		return

	_append_battle_log("%s 접근" % enemy_actor_state.display_name)
	_play_enemy_actor_path_move_then_act(enemy_actor_state, move_path)


func _play_enemy_basic_attack_from_current_cell(target_state: BattleUnitState = null) -> void:
	_play_enemy_actor_basic_attack_from_current_cell(enemy_unit_state, target_state)


func _play_enemy_actor_basic_attack_from_current_cell(enemy_actor_state: BattleUnitState, target_state: BattleUnitState = null) -> void:
	if enemy_actor_state == null:
		_return_to_ally_turn()
		return
	if target_state == null:
		target_state = _get_enemy_ai_target_state_for_actor(enemy_actor_state)
	if target_state == null or not target_state.is_alive():
		_mark_enemy_unit_acted(enemy_actor_state)
		_return_to_ally_turn()
		return
	current_enemy_ai_actor_state = enemy_actor_state
	current_enemy_attack_target_state = target_state
	_hide_all_move_dust_sprites()
	_focus_camera_on_combat_pair(enemy_actor_state, target_state)

	_refresh_enemy_facing_for_actor_action(enemy_actor_state, target_state)
	_reset_unit_group_positions()

	var guard_direction := (_get_ally_target_visual_anchor_position(target_state) - _get_enemy_actor_visual_anchor_position(enemy_actor_state)).normalized()
	var guard_offset := guard_direction * ENEMY_GUARD_STEP_DISTANCE
	var ally_recoil_offset := guard_direction * 16.0
	_spawn_attack_slash_fx(_get_enemy_actor_visual_anchor_position(enemy_actor_state), _get_ally_target_visual_anchor_position(target_state))

	var tween := create_tween()
	tween.tween_interval(0.16)
	tween.tween_callback(_enemy_reaction_hit_on)
	tween.chain()
	tween.set_parallel(true)
	tween.tween_method(_apply_enemy_actor_group_offset.bind(enemy_actor_state), Vector2.ZERO, guard_offset, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_method(_apply_ally_target_group_offset, Vector2.ZERO, ally_recoil_offset, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_method(_set_ally_target_group_modulate, Color.WHITE, Color(1.0, 0.45, 0.45, 1.0), 0.08)
	tween.chain()
	tween.tween_method(_apply_enemy_actor_group_offset.bind(enemy_actor_state), guard_offset, Vector2.ZERO, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_method(_apply_ally_target_group_offset, ally_recoil_offset, Vector2.ZERO, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_method(_set_ally_target_group_modulate, Color(1.0, 0.45, 0.45, 1.0), Color.WHITE, 0.18)
	tween.chain().tween_callback(_finish_enemy_actor_basic_attack.bind(enemy_actor_state))


func _play_enemy_path_move_then_act(move_path: Array[Vector2i]) -> void:
	_play_enemy_actor_path_move_then_act(enemy_unit_state, move_path)


func _play_enemy_actor_path_move_then_act(enemy_actor_state: BattleUnitState, move_path: Array[Vector2i]) -> void:
	if enemy_actor_state == null or battle_grid_controller == null:
		_return_to_ally_turn()
		return
	if not _is_path_clear_for_unit(move_path, enemy_actor_state, true):
		_append_battle_log("%s 이동 경로 막힘" % enemy_actor_state.display_name)
		_mark_enemy_unit_acted(enemy_actor_state)
		_return_to_ally_turn()
		return

	_clear_transient_battle_highlights()
	var actor_marker := _get_enemy_actor_unit_marker(enemy_actor_state)
	var actor_portrait_marker := _get_enemy_actor_portrait_marker(enemy_actor_state)
	if actor_marker == null:
		_mark_enemy_unit_acted(enemy_actor_state)
		_return_to_ally_turn()
		return
	var start_unit_position := actor_marker.position
	var start_portrait_position := start_unit_position
	if actor_portrait_marker != null:
		start_portrait_position = actor_portrait_marker.position
	var portrait_offset := start_portrait_position - start_unit_position
	var target_cell := move_path[move_path.size() - 1]
	var target_position := battle_grid_controller.grid_to_world(target_cell)
	var target_portrait_position := target_position + portrait_offset
	_hide_facing_indicator_for_unit(enemy_actor_state)
	_show_move_dust_for_unit(enemy_actor_state)
	_focus_camera_on_unit(enemy_actor_state)

	var tween := create_tween()
	var previous_offset := Vector2.ZERO
	var step_duration := 0.14
	for path_index in range(1, move_path.size()):
		var waypoint_world := battle_grid_controller.grid_to_world(move_path[path_index])
		var next_offset := waypoint_world - start_unit_position
		tween.tween_method(_apply_enemy_actor_group_offset.bind(enemy_actor_state), previous_offset, next_offset, step_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		previous_offset = next_offset
	tween.tween_callback(_finish_enemy_actor_basic_move.bind(enemy_actor_state, target_position, target_portrait_position, target_cell))


func _finish_enemy_basic_move(target_position: Vector2, target_portrait_position: Vector2, target_cell: Vector2i) -> void:
	_finish_enemy_actor_basic_move(enemy_unit_state, target_position, target_portrait_position, target_cell)


func _finish_enemy_actor_basic_move(enemy_actor_state: BattleUnitState, target_position: Vector2, target_portrait_position: Vector2, target_cell: Vector2i) -> void:
	if _handle_battle_end_guard("enemy_move_finish"):
		is_demo_animating = false
		print("[TURN_ADVANCE_BLOCKED] source=enemy_move_finish reason=result_finalized")
		return
	if enemy_actor_state == null:
		_return_to_ally_turn()
		return

	_sync_enemy_actor_markers_to_position(enemy_actor_state, target_position, target_portrait_position)
	enemy_actor_state.set_grid_cell(target_cell)
	_clear_transient_battle_highlights()
	_reset_unit_group_positions()
	_fade_out_move_dust_for_unit(enemy_actor_state)
	_update_facing_indicators()
	_focus_camera_on_unit(enemy_actor_state)
	_play_enemy_actor_basic_attack_or_wait_after_move(enemy_actor_state)


func _play_enemy_basic_attack_or_wait_after_move() -> void:
	_play_enemy_actor_basic_attack_or_wait_after_move(enemy_unit_state)


func _play_enemy_actor_basic_attack_or_wait_after_move(enemy_actor_state: BattleUnitState) -> void:
	if _handle_battle_end_guard("enemy_after_move_action"):
		is_demo_animating = false
		print("[TURN_ADVANCE_BLOCKED] source=enemy_after_move_action reason=result_finalized")
		return
	if enemy_actor_state == null:
		_return_to_ally_turn()
		return

	var attack_target := _find_best_auto_attack_target(enemy_actor_state)
	if attack_target != null and _can_auto_kill_target(enemy_actor_state, attack_target):
		_play_enemy_actor_basic_attack_from_current_cell(enemy_actor_state, attack_target)
		return
	if _try_auto_unique_skill_for_actor(enemy_actor_state, true):
		return
	if attack_target != null:
		_play_enemy_actor_basic_attack_from_current_cell(enemy_actor_state, attack_target)
		return
	if _try_auto_unique_skill_for_actor(enemy_actor_state, false):
		return

	_append_battle_log("%s 대기" % enemy_actor_state.display_name)
	_mark_enemy_unit_acted(enemy_actor_state)
	_return_to_ally_turn()


func _enemy_reaction_hit_on() -> void:
	if _handle_battle_end_guard("enemy_reaction_hit"):
		print("[TURN_ADVANCE_BLOCKED] source=enemy_reaction_hit reason=result_finalized")
		return
	var target_state := current_enemy_attack_target_state
	if target_state == null:
		target_state = _get_enemy_ai_target_state_for_actor(current_enemy_ai_actor_state)
	if target_state != null and target_state.is_alive():
		var attack_damage := _get_directional_attack_damage(int(ENEMY_DEMO_DAMAGE), current_enemy_ai_actor_state, target_state, true, true)
		var attack_angle_type := _get_attack_angle_type(current_enemy_ai_actor_state, target_state)
		target_state.apply_damage(attack_damage)
		_update_ally_target_visuals_from_state(target_state)
		var target_pos := _get_ally_target_visual_anchor_position(target_state)
		_spawn_hit_battle_dust_fx(target_pos)
		_spawn_hit_spark_fx(target_pos)
		_spawn_damage_number_fx(target_pos, attack_damage)
		_show_defend_hit_reaction_if_needed(target_state)
		_append_attack_angle_log(attack_angle_type)
		_cleanup_dead_units()
	var actor_name := "적군"
	if current_enemy_ai_actor_state != null:
		actor_name = current_enemy_ai_actor_state.display_name
	_append_battle_log("%s 반격" % actor_name)


func _finish_enemy_actor_basic_attack(enemy_actor_state: BattleUnitState) -> void:
	if _handle_battle_end_guard("enemy_attack_finish"):
		is_demo_animating = false
		print("[TURN_ADVANCE_BLOCKED] source=enemy_attack_finish reason=result_finalized")
		return
	_mark_enemy_unit_acted(enemy_actor_state)
	_return_to_ally_turn()


func _return_to_ally_turn() -> void:
	current_enemy_attack_target_state = null
	current_enemy_ai_actor_state = null
	_clear_pending_move_snapshot()
	_clear_transient_battle_highlights()
	_cleanup_dead_units()
	if _is_battle_result_finalized():
		_handle_battle_end_guard("return_to_ally_turn")
		_set_phase(PHASE_ALLY_TURN)
		return
	_reset_unit_group_positions()
	_hide_all_move_dust_sprites()
	_set_all_unit_group_modulates(Color.WHITE)
	is_demo_animating = false
	if _are_all_alive_allies_acted() and _are_all_alive_enemies_acted():
		_start_new_round()
	var next_ally := _get_first_available_ally_unit()
	if next_ally == null:
		_start_new_round()
		next_ally = _get_first_available_ally_unit()
	if next_ally == null:
		_append_battle_log("행동 가능한 아군 없음")
		_set_phase(PHASE_ALLY_TURN)
		return
	_select_ally_unit(next_ally, false, false, true)
	_set_phase(PHASE_ALLY_TURN)
	_append_battle_log("아군 턴 복귀")
	_debug_print_combat_distance("ALLY_TURN_RETURN")
	_refresh_move_target_feedback()
	_show_move_range_overlay_for_active_unit()
	_clear_attack_target_selection()
	_set_facing_indicators_visible(true)
	_update_facing_indicators()
	_hide_all_move_dust_sprites()
	_start_idle_breathing()


func _get_ally_group_nodes() -> Array[CanvasItem]:
	var nodes: Array[CanvasItem] = [
		ally_unit_shadow,
		ally_unit_token,
		ally_move_dust_sprite,
		ally_portrait_badge,
		ally_hp_bar,
		ally_troop_label,
	]
	return nodes


func _get_ally_support_group_nodes() -> Array[CanvasItem]:
	var nodes: Array[CanvasItem] = [
		ally_support_unit_shadow,
		ally_support_unit_token,
		ally_support_move_dust_sprite,
		ally_support_portrait_badge,
		ally_support_hp_bar,
		ally_support_troop_label,
	]
	return nodes


func _get_ally_main_03_group_nodes() -> Array[CanvasItem]:
	var nodes: Array[CanvasItem] = [
		ally_main_03_unit_shadow,
		ally_main_03_unit_token,
		ally_main_03_move_dust_sprite,
		ally_main_03_portrait_badge,
		ally_main_03_hp_bar,
		ally_main_03_troop_label,
	]
	return nodes


func _get_ally_reinforce_01_group_nodes() -> Array[CanvasItem]:
	var nodes: Array[CanvasItem] = [
		ally_reinforce_01_unit_shadow,
		ally_reinforce_01_unit_token,
		ally_reinforce_01_move_dust_sprite,
		ally_reinforce_01_portrait_badge,
		ally_reinforce_01_hp_bar,
		ally_reinforce_01_troop_label,
	]
	return nodes


func _get_ally_reinforce_02_group_nodes() -> Array[CanvasItem]:
	var nodes: Array[CanvasItem] = [
		ally_reinforce_02_unit_shadow,
		ally_reinforce_02_unit_token,
		ally_reinforce_02_move_dust_sprite,
		ally_reinforce_02_portrait_badge,
		ally_reinforce_02_hp_bar,
		ally_reinforce_02_troop_label,
	]
	return nodes


func _get_enemy_group_nodes() -> Array[CanvasItem]:
	var nodes: Array[CanvasItem] = [
		enemy_unit_shadow,
		enemy_unit_token,
		enemy_move_dust_sprite,
		enemy_portrait_badge,
		enemy_hp_bar,
		enemy_troop_label,
	]
	return nodes


func _get_enemy_support_group_nodes() -> Array[CanvasItem]:
	var nodes: Array[CanvasItem] = [
		enemy_support_unit_shadow,
		enemy_support_unit_token,
		enemy_support_move_dust_sprite,
		enemy_support_portrait_badge,
		enemy_support_hp_bar,
		enemy_support_troop_label,
	]
	return nodes


func _get_enemy_main_03_group_nodes() -> Array[CanvasItem]:
	var nodes: Array[CanvasItem] = [
		enemy_main_03_unit_shadow,
		enemy_main_03_unit_token,
		enemy_main_03_move_dust_sprite,
		enemy_main_03_portrait_badge,
		enemy_main_03_hp_bar,
		enemy_main_03_troop_label,
	]
	return nodes


func _get_enemy_reinforce_01_group_nodes() -> Array[CanvasItem]:
	var nodes: Array[CanvasItem] = [
		enemy_reinforce_01_unit_shadow,
		enemy_reinforce_01_unit_token,
		enemy_reinforce_01_move_dust_sprite,
		enemy_reinforce_01_portrait_badge,
		enemy_reinforce_01_hp_bar,
		enemy_reinforce_01_troop_label,
	]
	return nodes


func _get_enemy_reinforce_02_group_nodes() -> Array[CanvasItem]:
	var nodes: Array[CanvasItem] = [
		enemy_reinforce_02_unit_shadow,
		enemy_reinforce_02_unit_token,
		enemy_reinforce_02_move_dust_sprite,
		enemy_reinforce_02_portrait_badge,
		enemy_reinforce_02_hp_bar,
		enemy_reinforce_02_troop_label,
	]
	return nodes


func _get_click_area_layout_offset_for_unit(unit_state: BattleUnitState) -> Vector2:
	if unit_state == null:
		return Vector2.ZERO
	match _get_capacity_slot_id_for_unit_state(unit_state):
		"ally_main_01", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02":
			return ally_click_area_layout_offset
		"ally_main_02":
			return ally_support_click_area_layout_offset
		"enemy_main_01", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02":
			return enemy_click_area_layout_offset
		"enemy_main_02":
			return enemy_support_click_area_layout_offset
		_:
			return Vector2.ZERO


func _get_group_base_positions_for_unit(unit_state: BattleUnitState, visual_anchor: Vector2) -> Array[Vector2]:
	if unit_state == null:
		return []
	match _get_capacity_slot_id_for_unit_state(unit_state):
		"ally_main_01", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02":
			return _get_ally_group_base_positions_for_unit(visual_anchor, unit_state)
		"ally_main_02":
			return _get_ally_support_group_base_positions_for_unit(visual_anchor, unit_state)
		"enemy_main_01", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02":
			return _get_enemy_group_base_positions_for_unit(visual_anchor, unit_state)
		"enemy_main_02":
			return _get_enemy_support_group_base_positions_for_unit(visual_anchor, unit_state)
		_:
			return []


func _apply_group_offset_for_unit(unit_state: BattleUnitState, offset: Vector2) -> void:
	if unit_state == null:
		return
	var visual_anchor := _get_visual_anchor_position_for_unit(unit_state)
	var base_positions := _get_group_base_positions_for_unit(unit_state, visual_anchor)
	var group_nodes := _get_visual_group_nodes_for_unit(unit_state)
	if not group_nodes.is_empty() and not base_positions.is_empty():
		_apply_group_offset(group_nodes, base_positions, offset)
	var click_area := _get_click_area_for_unit(unit_state)
	if click_area != null:
		click_area.global_position = visual_anchor + _get_click_area_layout_offset_for_unit(unit_state) + offset


func _get_unit_visual_slots_for_state(unit_state: BattleUnitState) -> Dictionary:
	if unit_state == null:
		return {}
	var slot := _get_unit_visual_slot_for_state(unit_state)
	if slot != null:
		return slot.to_visual_slots_dictionary()
	if unit_state == ally_unit_state:
		return _get_ally_main_visual_slots()
	if unit_state == ally_support_unit_state:
		return _get_ally_support_visual_slots()
	if unit_state == ally_main_03_unit_state:
		return _get_ally_main_03_visual_slots()
	if unit_state == ally_reinforce_01_unit_state:
		return _get_ally_reinforce_01_visual_slots()
	if unit_state == ally_reinforce_02_unit_state:
		return _get_ally_reinforce_02_visual_slots()
	if unit_state == enemy_unit_state:
		return _get_enemy_main_visual_slots()
	if unit_state == enemy_support_unit_state:
		return _get_enemy_support_visual_slots()
	if unit_state == enemy_main_03_unit_state:
		return _get_enemy_main_03_visual_slots()
	if unit_state == enemy_reinforce_01_unit_state:
		return _get_enemy_reinforce_01_visual_slots()
	if unit_state == enemy_reinforce_02_unit_state:
		return _get_enemy_reinforce_02_visual_slots()
	return {}


func _get_visual_slots_for_slot_id(slot_id: String) -> Dictionary:
	var slot := _get_unit_visual_slot_for_slot_id(slot_id)
	if slot != null:
		return slot.to_visual_slots_dictionary()
	match slot_id:
		"ally_main":
			return _get_ally_main_visual_slots()
		"ally_support":
			return _get_ally_support_visual_slots()
		"enemy_main":
			return _get_enemy_main_visual_slots()
		"enemy_support":
			return _get_enemy_support_visual_slots()
		_:
			return {}


func _rebuild_unit_visual_slot_refs() -> void:
	unit_visual_slot_refs_by_id.clear()
	for slot_id in VISUAL_SLOT_CACHE_IDS:
		var slot := _create_unit_visual_slot_from_dictionary(slot_id, _get_visual_slots_dictionary_fallback_for_slot_id(slot_id))
		if slot != null:
			unit_visual_slot_refs_by_id[slot_id] = slot


func _build_capacity_slot_metadata_registry() -> Dictionary:
	capacity_slot_metadata_registry.clear()
	for slot_id in CAPACITY_SLOT_IDS:
		capacity_slot_metadata_registry[slot_id] = _create_capacity_slot_metadata(slot_id)
	return capacity_slot_metadata_registry


func _create_capacity_slot_metadata(slot_id: String) -> Dictionary:
	var side := "enemy"
	if slot_id.begins_with("ally_"):
		side = "ally"
	var slot_role := SLOT_ROLE_MAIN
	if slot_id.find("_reinforce_") != -1:
		slot_role = SLOT_ROLE_REINFORCE
	var legacy_slot_id := _get_legacy_slot_id_for_capacity_slot_id(slot_id)
	var formation_index := _get_capacity_slot_formation_index(slot_id)
	var assigned_hero_id := _get_test_battle_roster_hero_id(slot_id)
	var is_active := legacy_slot_id != "" or slot_id == "ally_main_03" or slot_id == "enemy_main_03" or slot_id == "ally_reinforce_01" or slot_id == "enemy_reinforce_01"
	if slot_id == "ally_reinforce_02" or slot_id == "enemy_reinforce_02":
		is_active = true
	var is_deployed := is_active and not (slot_id == "ally_reinforce_01" or slot_id == "enemy_reinforce_01" or slot_id == "ally_reinforce_02" or slot_id == "enemy_reinforce_02")
	var entry_rule := ""
	if is_deployed:
		entry_rule = SLOT_ENTRY_INITIAL
	var metadata := {
		"slot_id": slot_id,
		"legacy_slot_id": legacy_slot_id,
		"side": side,
		"slot_role": slot_role,
		"formation_index": formation_index,
		"is_active": is_active,
		"is_deployed": is_deployed,
		"entry_rule": entry_rule,
		"source_city_id": "",
		"dispatch_type": "",
		"assigned_hero_id": assigned_hero_id,
		"assigned_unit_id": _get_test_battle_assigned_unit_id(slot_id),
		"arrival_round": 0,
	}
	if slot_id == "ally_reinforce_02":
		# Mock city-origin reinforcement contract until world-map dispatch exists.
		metadata["entry_rule"] = SLOT_ENTRY_CITY_REINFORCEMENT
		metadata["source_city_id"] = "hanseong_adjacent_test_city"
		metadata["dispatch_type"] = "defense_reinforcement"
		metadata["arrival_round"] = 3
	elif slot_id == "enemy_reinforce_02":
		# Mock city-origin reinforcement contract until world-map dispatch exists.
		metadata["entry_rule"] = SLOT_ENTRY_CITY_REINFORCEMENT
		metadata["source_city_id"] = "enemy_adjacent_test_city"
		metadata["dispatch_type"] = "attack_reinforcement"
		metadata["arrival_round"] = 3
	return metadata


func _get_test_battle_roster_hero_id(slot_id: String) -> String:
	return String(TEST_BATTLE_ROSTER.get(slot_id, ""))


func _get_test_battle_assigned_unit_id(slot_id: String) -> String:
	var hero_id := _get_test_battle_roster_hero_id(slot_id)
	if hero_id == "":
		return ""
	return "%s_battle_unit" % hero_id


func _get_hero_id_for_unit_state(unit_state: BattleUnitState) -> String:
	var capacity_slot_id := _get_capacity_slot_id_for_unit_state(unit_state)
	if capacity_slot_id == "":
		return ""
	var slot_metadata := _get_capacity_slot_metadata(capacity_slot_id)
	var assigned_hero_id := String(slot_metadata.get("assigned_hero_id", ""))
	if assigned_hero_id != "":
		return assigned_hero_id
	return _get_test_battle_roster_hero_id(capacity_slot_id)


func _get_hero_registry_entry(hero_id: String) -> Dictionary:
	if hero_id == "":
		return {}
	if worldmap_context_hero_registry.has(hero_id):
		return worldmap_context_hero_registry.get(hero_id, {})
	return HERO_REGISTRY.get(hero_id, {})


func _get_hero_display_name_with_state(hero_id: String, base_name: String, hero_entry: Dictionary) -> String:
	if hero_id == "" or hero_entry.is_empty():
		return base_name
	return "%s%s" % [base_name, _get_hero_state_badge_text(hero_entry)]


func _get_hero_state_badge_text(hero_entry: Dictionary) -> String:
	if hero_entry.is_empty():
		return ""
	var status := str(hero_entry.get("status", "normal")).to_lower()
	if bool(hero_entry.get("dead", false)) or status == "dead":
		return " [사망]"
	if bool(hero_entry.get("captured", false)) or status == "captured":
		return " [포로]"
	if bool(hero_entry.get("wounded", false)) or status == "wounded":
		var turns_remaining := maxi(0, int(hero_entry.get("wounded_turns_remaining", 0)))
		if turns_remaining > 0:
			return " [부상 %d턴]" % turns_remaining
		return " [부상]"
	return ""


func _is_unit_hero_wounded(unit_state: BattleUnitState) -> bool:
	if unit_state == null:
		return false
	var hero_id := _get_hero_id_for_unit_state(unit_state)
	if hero_id == "":
		return false
	var hero_entry := _get_hero_registry_entry(hero_id)
	if hero_entry.is_empty():
		return false
	var status := str(hero_entry.get("status", "normal")).to_lower()
	return bool(hero_entry.get("wounded", false)) or status == "wounded"


func _get_wounded_penalty_multiplier(unit_state: BattleUnitState, penalty_type: String) -> float:
	if not _is_unit_hero_wounded(unit_state):
		return 1.0
	match penalty_type:
		"attack":
			return WOUNDED_ATTACK_DAMAGE_MULTIPLIER
		"defense":
			return 0.80
		"skill":
			return WOUNDED_SKILL_EFFECT_MULTIPLIER
		_:
			return 1.0


func _get_unique_skill_effect_amount(caster_state: BattleUnitState, skill_data: Dictionary, field_name: String, fallback_amount: int, should_log_wounded_penalty := true) -> int:
	var amount := maxi(0, int(skill_data.get(field_name, fallback_amount)))
	return _apply_wounded_amount_multiplier(caster_state, "skill", amount, should_log_wounded_penalty)


func _apply_wounded_amount_multiplier(unit_state: BattleUnitState, penalty_type: String, amount: int, should_log_wounded_penalty := true) -> int:
	if amount <= 0:
		return 0
	var multiplier := _get_wounded_penalty_multiplier(unit_state, penalty_type)
	if is_equal_approx(multiplier, 1.0):
		return amount
	var adjusted := maxi(1, int(round(float(amount) * multiplier)))
	if should_log_wounded_penalty and adjusted != amount:
		_log_wounded_penalty(unit_state, penalty_type, multiplier, amount, adjusted)
	return adjusted


func _apply_wounded_incoming_damage_penalty(unit_state: BattleUnitState, amount: int, should_log_wounded_penalty := true) -> int:
	if amount <= 0:
		return 0
	if not _is_unit_hero_wounded(unit_state):
		return amount
	var adjusted := maxi(1, int(round(float(amount) * WOUNDED_DEFENSE_INCOMING_DAMAGE_MULTIPLIER)))
	if should_log_wounded_penalty and adjusted != amount:
		_log_wounded_penalty(unit_state, "defense", WOUNDED_DEFENSE_INCOMING_DAMAGE_MULTIPLIER, amount, adjusted)
	return adjusted


func _log_wounded_penalty(unit_state: BattleUnitState, penalty_type: String, multiplier: float, before_amount: int, after_amount: int) -> void:
	if unit_state == null:
		return
	var hero_id := _get_hero_id_for_unit_state(unit_state)
	print("[WOUNDED_PENALTY] hero=%s name=%s type=%s multiplier=%.2f before=%d after=%d" % [
		hero_id,
		unit_state.display_name,
		penalty_type,
		multiplier,
		before_amount,
		after_amount,
	])


func _is_hero_entry_excluded_from_context_battle(hero_entry: Dictionary) -> bool:
	if hero_entry.is_empty():
		return false
	var status := str(hero_entry.get("status", "normal")).to_lower()
	if bool(hero_entry.get("dead", false)) or status == "dead":
		return true
	if bool(hero_entry.get("captured", false)) or status == "captured":
		return true
	return false


func _get_hero_entry_context_exclusion_reason(hero_entry: Dictionary) -> String:
	var status := str(hero_entry.get("status", "normal")).to_lower()
	if bool(hero_entry.get("dead", false)) or status == "dead":
		return "dead"
	if bool(hero_entry.get("captured", false)) or status == "captured":
		return "captured"
	return ""


func _load_texture_or_null(path: String) -> Texture2D:
	if path == "":
		return null
	if hero_identity_texture_cache.has(path):
		return hero_identity_texture_cache.get(path) as Texture2D
	if not ResourceLoader.exists(path):
		return null
	var loaded_resource := load(path)
	var texture := loaded_resource as Texture2D
	if texture != null:
		hero_identity_texture_cache[path] = texture
	return texture


func _apply_hero_identity_to_unit(unit_state: BattleUnitState) -> void:
	if unit_state == null:
		return
	var hero_id := _get_hero_id_for_unit_state(unit_state)
	var hero_entry := _get_hero_registry_entry(hero_id)
	if hero_entry.is_empty():
		return
	var display_name := String(hero_entry.get("display_name", ""))
	if display_name != "":
		unit_state.display_name = display_name
		unit_state.hero_name = display_name
	unit_state.portrait_key = hero_id
	var default_visual_key := String(hero_entry.get("default_visual_key", ""))
	if default_visual_key != "":
		unit_state.visual_key = default_visual_key
	var allocated_troops := maxi(0, int(hero_entry.get("allocated_troops", 0)))
	var initial_allocated_troops := maxi(0, int(hero_entry.get("initial_allocated_troops", allocated_troops)))
	if allocated_troops > 0 or initial_allocated_troops > 0:
		unit_state.allocated_troops = allocated_troops
		unit_state.initial_allocated_troops = initial_allocated_troops if initial_allocated_troops > 0 else allocated_troops
		unit_state.current_troops = allocated_troops
		unit_state.max_troops = maxi(allocated_troops, int(hero_entry.get("max_troops", allocated_troops)))
	var battlefield_portrait_texture := _resolve_hero_portrait_texture(hero_entry)
	var slot := _get_unit_visual_slot_for_state(unit_state)
	if battlefield_portrait_texture != null and slot != null and slot.portrait is Sprite2D:
		_apply_battle_portrait_texture_to_sprite(slot.portrait as Sprite2D, battlefield_portrait_texture)
		_set_visual_portrait_badge_base_scale_for_unit(unit_state, (slot.portrait as Sprite2D).scale)


func _apply_all_hero_identities() -> void:
	for unit_state in _get_all_unit_states_in_slot_order():
		_apply_hero_identity_to_unit(unit_state)
	if not has_logged_hero_identity_validation:
		_validate_hero_identity_bindings()
		has_logged_hero_identity_validation = true


func _validate_hero_identity_bindings() -> void:
	for unit_state in _get_all_unit_states_in_slot_order():
		if unit_state == null:
			continue
		var capacity_slot_id := _get_capacity_slot_id_for_unit_state(unit_state)
		var hero_id := _get_hero_id_for_unit_state(unit_state)
		var hero_entry := _get_hero_registry_entry(hero_id)
		var expected_path := _resolve_hero_portrait_path(hero_entry)
		var expected_filename := expected_path.get_file()
		var slot := _get_unit_visual_slot_for_state(unit_state)
		var actual_path := ""
		if slot != null and slot.portrait is Sprite2D and (slot.portrait as Sprite2D).texture != null:
			actual_path = (slot.portrait as Sprite2D).texture.resource_path
		var actual_filename := actual_path.get_file()
		var click_area := _get_click_area_for_unit(unit_state)
		var click_area_name := ""
		if click_area != null:
			click_area_name = click_area.name
		var identity_ok := (
			hero_id != ""
			and String(hero_entry.get("display_name", "")) == unit_state.display_name
			and expected_filename != ""
			and expected_filename == actual_filename
		)
		if identity_ok:
			print("[IDENTITY_OK] %s hero=%s name=%s portrait=%s click=%s" % [
				capacity_slot_id,
				hero_id,
				unit_state.display_name,
				actual_filename,
				click_area_name,
			])
		else:
			print("[IDENTITY_MISMATCH] slot=%s hero=%s expected=%s actual=%s name=%s click=%s" % [
				capacity_slot_id,
				hero_id,
				expected_filename,
				actual_filename,
				unit_state.display_name,
				click_area_name,
			])


func _get_capacity_slot_formation_index(slot_id: String) -> int:
	var slot_suffix := slot_id.get_slice("_", 2)
	return slot_suffix.to_int()


func _get_capacity_slot_id_for_legacy_slot_id(legacy_slot_id: String) -> String:
	return String(LEGACY_SLOT_TO_CAPACITY_SLOT_ID.get(legacy_slot_id, ""))


func _get_legacy_slot_id_for_capacity_slot_id(capacity_slot_id: String) -> String:
	return String(CAPACITY_SLOT_TO_LEGACY_SLOT_ID.get(capacity_slot_id, ""))


func _get_capacity_slot_metadata(slot_id: String) -> Dictionary:
	if slot_id == "":
		return {}
	return capacity_slot_metadata_registry.get(slot_id, {})


func _set_capacity_slot_metadata_value(slot_id: String, key: String, value: Variant) -> void:
	if slot_id == "":
		return
	var metadata := _get_capacity_slot_metadata(slot_id).duplicate()
	if metadata.is_empty():
		return
	metadata[key] = value
	capacity_slot_metadata_registry[slot_id] = metadata


func _is_capacity_slot_active(slot_id: String) -> bool:
	if slot_id == "":
		return false
	return bool(_get_capacity_slot_metadata(slot_id).get("is_active", false))


func _is_capacity_slot_deployed(slot_id: String) -> bool:
	if slot_id == "":
		return false
	return bool(_get_capacity_slot_metadata(slot_id).get("is_deployed", false))


func _get_active_capacity_slots_for_side(side: String) -> Array[String]:
	var slot_ids: Array[String] = []
	for slot_id in CAPACITY_SLOT_IDS:
		var slot_metadata := _get_capacity_slot_metadata(slot_id)
		if String(slot_metadata.get("side", "")) == side and bool(slot_metadata.get("is_active", false)):
			slot_ids.append(slot_id)
	return slot_ids


func _get_deployed_capacity_slots_for_side(side: String) -> Array[String]:
	var slot_ids: Array[String] = []
	for slot_id in CAPACITY_SLOT_IDS:
		var slot_metadata := _get_capacity_slot_metadata(slot_id)
		if String(slot_metadata.get("side", "")) == side and bool(slot_metadata.get("is_deployed", false)):
			slot_ids.append(slot_id)
	return slot_ids


func _rebuild_battle_unit_state_list_refs() -> void:
	ally_unit_states.clear()
	enemy_unit_states.clear()
	all_battle_unit_states.clear()
	unit_state_by_legacy_slot_id.clear()
	unit_state_by_capacity_slot_id.clear()

	_append_unit_state_to_adapter(ally_unit_states, ally_unit_state)
	_append_unit_state_to_adapter(ally_unit_states, ally_support_unit_state)
	_append_unit_state_to_adapter(ally_unit_states, ally_main_03_unit_state)
	_append_unit_state_to_adapter(ally_unit_states, ally_reinforce_01_unit_state)
	_append_unit_state_to_adapter(ally_unit_states, ally_reinforce_02_unit_state)
	_append_unit_state_to_adapter(enemy_unit_states, enemy_unit_state)
	_append_unit_state_to_adapter(enemy_unit_states, enemy_support_unit_state)
	_append_unit_state_to_adapter(enemy_unit_states, enemy_main_03_unit_state)
	_append_unit_state_to_adapter(enemy_unit_states, enemy_reinforce_01_unit_state)
	_append_unit_state_to_adapter(enemy_unit_states, enemy_reinforce_02_unit_state)

	for unit_state in ally_unit_states:
		all_battle_unit_states.append(unit_state)
	for unit_state in enemy_unit_states:
		all_battle_unit_states.append(unit_state)

	for unit_state in all_battle_unit_states:
		var legacy_slot_id := _get_legacy_slot_id_for_unit_state(unit_state)
		if legacy_slot_id != "":
			unit_state_by_legacy_slot_id[legacy_slot_id] = unit_state
		var capacity_slot_id := _get_capacity_slot_id_for_unit_state(unit_state)
		if capacity_slot_id != "":
			unit_state_by_capacity_slot_id[capacity_slot_id] = unit_state


func _append_unit_state_to_adapter(target_states: Array[BattleUnitState], unit_state: BattleUnitState) -> void:
	if unit_state == null:
		return
	target_states.append(unit_state)


func _get_unit_states_for_side(side: String) -> Array[BattleUnitState]:
	var result: Array[BattleUnitState] = []
	if side == "ally":
		result = ally_unit_states.duplicate()
	elif side == "enemy":
		result = enemy_unit_states.duplicate()
	return result


func _get_all_battle_unit_states_from_adapter() -> Array[BattleUnitState]:
	var result: Array[BattleUnitState] = all_battle_unit_states.duplicate()
	return result


func _is_battle_unit_state_adapter_ready() -> bool:
	return not all_battle_unit_states.is_empty()


func _get_unit_state_for_legacy_slot_id(legacy_slot_id: String) -> BattleUnitState:
	if legacy_slot_id == "":
		return null
	var mapped_unit_state := unit_state_by_legacy_slot_id.get(legacy_slot_id, null) as BattleUnitState
	return mapped_unit_state


func _get_unit_state_for_capacity_slot_id(capacity_slot_id: String) -> BattleUnitState:
	if capacity_slot_id == "":
		return null
	var mapped_unit_state := unit_state_by_capacity_slot_id.get(capacity_slot_id, null) as BattleUnitState
	return mapped_unit_state


func _get_capacity_slot_id_for_unit_state(unit_state: BattleUnitState) -> String:
	if unit_state == null:
		return ""
	if CAPACITY_SLOT_IDS.has(unit_state.slot_id):
		return unit_state.slot_id
	var legacy_slot_id := _get_legacy_slot_id_for_unit_state(unit_state)
	if legacy_slot_id == "":
		return ""
	return _get_capacity_slot_id_for_legacy_slot_id(legacy_slot_id)


func _get_legacy_slot_id_for_unit_state(unit_state: BattleUnitState) -> String:
	if unit_state == null:
		return ""
	if SLOT_IDS.has(unit_state.slot_id):
		return unit_state.slot_id
	if CAPACITY_SLOT_TO_LEGACY_SLOT_ID.has(unit_state.slot_id):
		return String(CAPACITY_SLOT_TO_LEGACY_SLOT_ID.get(unit_state.slot_id, ""))
	if unit_state == ally_unit_state:
		return "ally_main"
	if unit_state == ally_support_unit_state:
		return "ally_support"
	if unit_state == ally_main_03_unit_state:
		return ""
	if unit_state == enemy_unit_state:
		return "enemy_main"
	if unit_state == enemy_support_unit_state:
		return "enemy_support"
	if unit_state == enemy_main_03_unit_state:
		return ""
	return ""


func _get_deployed_unit_states_for_side(side: String) -> Array[BattleUnitState]:
	var filtered_states: Array[BattleUnitState] = []
	for unit_state in _get_unit_states_for_side(side):
		if _is_unit_state_deployed_by_capacity_slot(unit_state):
			filtered_states.append(unit_state)
	return filtered_states


func _get_active_unit_states_for_side(side: String) -> Array[BattleUnitState]:
	var filtered_states: Array[BattleUnitState] = []
	for unit_state in _get_unit_states_for_side(side):
		if _is_unit_state_active_by_capacity_slot(unit_state):
			filtered_states.append(unit_state)
	return filtered_states


func _get_alive_unit_states_for_side_from_adapter(side: String) -> Array[BattleUnitState]:
	var alive_states: Array[BattleUnitState] = []
	for unit_state in _get_unit_states_for_side(side):
		if _is_unit_state_available_for_battle_slot(unit_state):
			alive_states.append(unit_state)
	return alive_states


func _get_alive_deployed_unit_states_for_side(side: String) -> Array[BattleUnitState]:
	var alive_states: Array[BattleUnitState] = []
	for unit_state in _get_unit_states_for_side(side):
		if _is_unit_state_available_for_battle_slot(unit_state):
			alive_states.append(unit_state)
	return alive_states


func _get_all_alive_unit_states_from_adapter() -> Array[BattleUnitState]:
	var alive_states: Array[BattleUnitState] = []
	for unit_state in _get_alive_deployed_unit_states_for_side("ally"):
		alive_states.append(unit_state)
	for unit_state in _get_alive_deployed_unit_states_for_side("enemy"):
		alive_states.append(unit_state)
	return alive_states


func _get_actor_candidates_for_side_from_adapter(side: String) -> Array[BattleUnitState]:
	var candidates: Array[BattleUnitState] = []
	for unit_state in _get_alive_deployed_unit_states_for_side(side):
		if _is_unit_state_available_for_battle_slot(unit_state):
			candidates.append(unit_state)
	return candidates


func _get_available_actor_candidates_for_side_from_adapter(side: String) -> Array[BattleUnitState]:
	var candidates: Array[BattleUnitState] = []
	for unit_state in _get_actor_candidates_for_side_from_adapter(side):
		if unit_state == null:
			continue
		if side == "ally":
			if not _has_ally_unit_acted(unit_state):
				candidates.append(unit_state)
		elif side == "enemy":
			if not _has_enemy_unit_acted(unit_state):
				candidates.append(unit_state)
	return candidates


func _get_alive_target_candidates_for_side_from_adapter(actor_side: String) -> Array[BattleUnitState]:
	var empty_candidates: Array[BattleUnitState] = []
	match actor_side:
		"ally":
			return _get_alive_deployed_unit_states_for_side("enemy")
		"enemy":
			return _get_alive_deployed_unit_states_for_side("ally")
		_:
			return empty_candidates


func _get_target_candidates_for_actor_from_adapter(actor_state: BattleUnitState) -> Array[BattleUnitState]:
	var empty_candidates: Array[BattleUnitState] = []
	if actor_state == null:
		return empty_candidates
	return _get_alive_target_candidates_for_side_from_adapter(actor_state.side)


func _is_unit_state_deployed_by_capacity_slot(unit_state: BattleUnitState) -> bool:
	if unit_state == null:
		return false
	var capacity_slot_id := _get_capacity_slot_id_for_unit_state(unit_state)
	if capacity_slot_id == "":
		return false
	return _is_capacity_slot_deployed(capacity_slot_id)


func _is_unit_state_active_by_capacity_slot(unit_state: BattleUnitState) -> bool:
	if unit_state == null:
		return false
	var capacity_slot_id := _get_capacity_slot_id_for_unit_state(unit_state)
	if capacity_slot_id == "":
		return false
	return _is_capacity_slot_active(capacity_slot_id)


func _is_unit_state_available_for_battle_slot(unit_state: BattleUnitState) -> bool:
	if unit_state == null:
		return false
	if not unit_state.is_alive():
		return false
	if not _is_unit_state_active_by_capacity_slot(unit_state):
		return false
	if not _is_unit_state_deployed_by_capacity_slot(unit_state):
		return false
	# Future reinforce policy:
	# active=true but deployed=false units must stay out of actor/target/occupied paths
	# until they are actually deployed into battle.
	return true


func _set_unit_deployed(unit_state: BattleUnitState, deployed: bool) -> void:
	if unit_state == null:
		return
	var capacity_slot_id := _get_capacity_slot_id_for_unit_state(unit_state)
	if capacity_slot_id == "":
		return
	_set_capacity_slot_metadata_value(capacity_slot_id, "is_deployed", deployed)
	if deployed:
		_set_capacity_slot_metadata_value(capacity_slot_id, "entry_rule", SLOT_ENTRY_TRIGGERED)
	else:
		_set_capacity_slot_metadata_value(capacity_slot_id, "entry_rule", "")


func _get_city_reinforcement_arrival_round(slot_id: String) -> int:
	return int(_get_capacity_slot_metadata(slot_id).get("arrival_round", 0))


func _is_city_reinforcement_ready_to_arrive(slot_id: String) -> bool:
	var slot_metadata := _get_capacity_slot_metadata(slot_id)
	if slot_metadata.is_empty():
		return false
	if not bool(slot_metadata.get("is_active", false)):
		return false
	if String(slot_metadata.get("entry_rule", "")) != SLOT_ENTRY_CITY_REINFORCEMENT:
		return false
	if bool(slot_metadata.get("is_deployed", false)):
		return false
	var arrival_round := int(slot_metadata.get("arrival_round", 0))
	return arrival_round > 0 and battle_round >= arrival_round


func _deploy_city_reinforcement_unit(unit_state: BattleUnitState) -> bool:
	if unit_state == null:
		return false
	if _handle_battle_end_guard("city_reinforcement_deploy"):
		print("[REINFORCEMENT_BLOCKED] source=city_reinforcement_deploy reason=result_finalized")
		return false
	var capacity_slot_id := _get_capacity_slot_id_for_unit_state(unit_state)
	if capacity_slot_id == "":
		return false
	if not _is_city_reinforcement_ready_to_arrive(capacity_slot_id):
		return false
	_set_capacity_slot_metadata_value(capacity_slot_id, "is_deployed", true)
	_set_capacity_slot_metadata_value(capacity_slot_id, "entry_rule", SLOT_ENTRY_CITY_REINFORCEMENT)
	var unit_marker := _get_unit_marker_for_unit(unit_state)
	if unit_marker != null:
		unit_state.set_grid_cell(_get_cell_from_world(unit_marker.position))
	unit_state.has_acted = false
	unit_state.has_moved = false
	_restore_hp_troop_runtime_visibility_for_unit(unit_state)
	_update_unit_visuals_from_state(unit_state)
	_apply_group_offset_for_unit(unit_state, Vector2.ZERO)
	_reset_unit_group_positions()
	_refresh_facing_indicator_for_unit(unit_state)
	_focus_camera_on_unit(unit_state)
	_debug_log_reinforce_visual_state(unit_state)
	return true


func _deploy_reinforce_unit(unit_state: BattleUnitState) -> bool:
	if unit_state == null:
		return false
	if _handle_battle_end_guard("reinforcement_deploy"):
		print("[REINFORCEMENT_BLOCKED] source=reinforcement_deploy reason=result_finalized")
		return false
	if not _is_unit_state_active_by_capacity_slot(unit_state):
		return false
	if _is_unit_state_deployed_by_capacity_slot(unit_state):
		return false
	_set_unit_deployed(unit_state, true)
	var unit_marker := _get_unit_marker_for_unit(unit_state)
	if unit_marker != null:
		unit_state.set_grid_cell(_get_cell_from_world(unit_marker.position))
	unit_state.has_acted = false
	unit_state.has_moved = false
	_restore_hp_troop_runtime_visibility_for_unit(unit_state)
	_update_unit_visuals_from_state(unit_state)
	_apply_group_offset_for_unit(unit_state, Vector2.ZERO)
	_reset_unit_group_positions()
	_refresh_facing_indicator_for_unit(unit_state)
	_refresh_formation_slot_guides()
	_focus_camera_on_unit(unit_state)
	_debug_log_reinforce_visual_state(unit_state)
	return true


func _debug_log_reinforce_visual_state(unit_state: BattleUnitState) -> void:
	if unit_state == null:
		return
	var capacity_slot_id := _get_capacity_slot_id_for_unit_state(unit_state)
	if not capacity_slot_id.contains("reinforce_"):
		return
	var slot := _get_unit_visual_slot_for_state(unit_state)
	var portrait: CanvasItem = null
	if slot != null:
		portrait = slot.portrait as CanvasItem
	var portrait_texture_exists := false
	if portrait is Sprite2D:
		portrait_texture_exists = (portrait as Sprite2D).texture != null
	var hp_bar := _get_hp_bar_for_unit(unit_state)
	var troop_label := _get_troop_label_for_unit(unit_state)
	var facing_indicator := _get_facing_indicator_for_unit(unit_state)
	var root_global_position := Vector2.ZERO
	var root_alpha := -1.0
	if slot != null and slot.root != null:
		root_global_position = slot.root.global_position
		root_alpha = slot.root.modulate.a
	var token_global_position := Vector2.ZERO
	var token_alpha := -1.0
	if slot != null and slot.token != null:
		token_global_position = slot.token.global_position
		token_alpha = slot.token.modulate.a
	var portrait_global_position := Vector2.ZERO
	if portrait != null:
		portrait_global_position = portrait.global_position
	var hp_global_position := Vector2.ZERO
	var hp_alpha := -1.0
	if hp_bar != null:
		hp_global_position = hp_bar.global_position
		hp_alpha = hp_bar.modulate.a
	var troop_text := ""
	var troop_global_position := Vector2.ZERO
	var troop_alpha := -1.0
	if troop_label != null:
		troop_text = troop_label.text
		troop_global_position = troop_label.global_position
		troop_alpha = troop_label.modulate.a
	var facing_position := Vector2.ZERO
	if facing_indicator != null:
		facing_position = facing_indicator.position
	print("[REINFORCE_VISUAL] slot=%s deployed=%s root=%s/%s/%s/%s token=%s/%s/%s/%s/%s portrait=%s/%s/%s/%s hp=%s/%s/%s/%s troop=%s/%s/%s/%s/%s facing=%s/%s" % [
		capacity_slot_id,
		str(_is_unit_state_deployed_by_capacity_slot(unit_state)),
		str(slot != null and slot.root != null),
		str(slot != null and slot.root != null and slot.root.visible),
		str(root_global_position),
		str(root_alpha),
		str(slot != null and slot.token != null),
		str(slot != null and slot.token != null and slot.token.visible),
		str(slot != null and slot.token != null and slot.token.texture != null),
		str(token_global_position),
		str(token_alpha),
		str(portrait != null),
		str(portrait != null and portrait.visible),
		str(portrait_texture_exists),
		str(portrait_global_position),
		str(hp_bar != null),
		str(hp_bar != null and hp_bar.visible),
		str(hp_global_position),
		str(hp_alpha),
		str(troop_label != null),
		str(troop_label != null and troop_label.visible),
		str(troop_text),
		str(troop_global_position),
		str(troop_alpha),
		str(facing_indicator != null and facing_indicator.visible),
		str(facing_position),
	])


func _try_deploy_reinforce_01_pair() -> void:
	if _handle_battle_end_guard("reinforce_01_check"):
		print("[REINFORCEMENT_BLOCKED] source=reinforce_01_check reason=result_finalized")
		return
	if has_deployed_reinforce_01:
		return
	if battle_round < 2:
		return
	var arriving_units: Array[String] = []
	if _deploy_reinforce_unit(ally_reinforce_01_unit_state):
		arriving_units.append(_get_hero_id_for_unit_state(ally_reinforce_01_unit_state))
	if _deploy_reinforce_unit(enemy_reinforce_01_unit_state):
		arriving_units.append(_get_hero_id_for_unit_state(enemy_reinforce_01_unit_state))
	has_deployed_reinforce_01 = true
	if arriving_units.is_empty():
		print("[REINFORCEMENT_TOAST_SKIP] source=reinforce_01 round=%d reason=no_arriving_units" % battle_round)
		return
	_reset_unit_group_positions()
	_update_ally_ready_frames()
	_update_facing_indicators()
	_show_reinforcement_arrival_toast(battle_round, arriving_units)
	_append_battle_log("지원군 선봉 등장")
	print("[REINFORCEMENT_ARRIVAL] source=reinforce_01 round=%d arriving=%s" % [battle_round, str(arriving_units)])
	print("[REINFORCE01] deployed round=%d ally=%s enemy=%s all_alive_deployed=%d" % [
		battle_round,
		str(_is_unit_state_deployed_by_capacity_slot(ally_reinforce_01_unit_state)),
		str(_is_unit_state_deployed_by_capacity_slot(enemy_reinforce_01_unit_state)),
		_get_all_alive_unit_states_from_adapter().size(),
	])


func _try_deploy_city_reinforce_02_pair() -> void:
	if _handle_battle_end_guard("city_reinforce_02_check"):
		print("[REINFORCEMENT_BLOCKED] source=city_reinforce_02_check reason=result_finalized")
		return
	if has_deployed_reinforce_02:
		return
	var ally_slot_id := "ally_reinforce_02"
	var enemy_slot_id := "enemy_reinforce_02"
	if not _is_city_reinforcement_ready_to_arrive(ally_slot_id) and not _is_city_reinforcement_ready_to_arrive(enemy_slot_id):
		return
	var arriving_units: Array[String] = []
	if _deploy_city_reinforcement_unit(ally_reinforce_02_unit_state):
		arriving_units.append(_get_hero_id_for_unit_state(ally_reinforce_02_unit_state))
	if _deploy_city_reinforcement_unit(enemy_reinforce_02_unit_state):
		arriving_units.append(_get_hero_id_for_unit_state(enemy_reinforce_02_unit_state))
	has_deployed_reinforce_02 = true
	if arriving_units.is_empty():
		print("[REINFORCEMENT_TOAST_SKIP] source=city_reinforce_02 round=%d reason=no_arriving_units" % battle_round)
		return
	_reset_unit_group_positions()
	_update_ally_ready_frames()
	_update_facing_indicators()
	_show_reinforcement_arrival_toast(battle_round, arriving_units)
	_append_battle_log("도시 지원군 도착")
	print("[REINFORCEMENT_ARRIVAL] source=city_reinforce_02 round=%d arriving=%s" % [battle_round, str(arriving_units)])
	var ally_metadata := _get_capacity_slot_metadata(ally_slot_id)
	var enemy_metadata := _get_capacity_slot_metadata(enemy_slot_id)
	print("[CITY_REINFORCE02] ally_city=%s ally_dispatch=%s ally_round=%d enemy_city=%s enemy_dispatch=%s enemy_round=%d all_alive_deployed=%d" % [
		String(ally_metadata.get("source_city_id", "")),
		String(ally_metadata.get("dispatch_type", "")),
		int(ally_metadata.get("arrival_round", 0)),
		String(enemy_metadata.get("source_city_id", "")),
		String(enemy_metadata.get("dispatch_type", "")),
		int(enemy_metadata.get("arrival_round", 0)),
		_get_all_alive_unit_states_from_adapter().size(),
	])


func _get_unit_visual_slot_for_state(unit_state: BattleUnitState) -> UnitVisualSlot:
	if unit_state == null:
		return null
	if unit_state.slot_id != "":
		var slot := _get_unit_visual_slot_for_slot_id(unit_state.slot_id)
		if slot != null:
			return slot
	if unit_state == ally_unit_state:
		return _get_unit_visual_slot_for_slot_id("ally_main")
	if unit_state == ally_support_unit_state:
		return _get_unit_visual_slot_for_slot_id("ally_support")
	if unit_state == ally_main_03_unit_state:
		return _get_unit_visual_slot_for_slot_id("ally_main_03")
	if unit_state == ally_reinforce_01_unit_state:
		return _get_unit_visual_slot_for_slot_id("ally_reinforce_01")
	if unit_state == ally_reinforce_02_unit_state:
		return _get_unit_visual_slot_for_slot_id("ally_reinforce_02")
	if unit_state == enemy_unit_state:
		return _get_unit_visual_slot_for_slot_id("enemy_main")
	if unit_state == enemy_support_unit_state:
		return _get_unit_visual_slot_for_slot_id("enemy_support")
	if unit_state == enemy_main_03_unit_state:
		return _get_unit_visual_slot_for_slot_id("enemy_main_03")
	if unit_state == enemy_reinforce_01_unit_state:
		return _get_unit_visual_slot_for_slot_id("enemy_reinforce_01")
	if unit_state == enemy_reinforce_02_unit_state:
		return _get_unit_visual_slot_for_slot_id("enemy_reinforce_02")
	return null


func _get_unit_visual_slot_for_slot_id(slot_id: String) -> UnitVisualSlot:
	if slot_id == "":
		return null
	var cached_slot := unit_visual_slot_refs_by_id.get(slot_id) as UnitVisualSlot
	if cached_slot != null:
		return cached_slot
	return _create_unit_visual_slot_from_dictionary(slot_id, _get_visual_slots_dictionary_fallback_for_slot_id(slot_id))


func _get_unit_visual_slot_for_capacity_slot_id(capacity_slot_id: String) -> UnitVisualSlot:
	if capacity_slot_id != "" and unit_visual_slot_refs_by_id.has(capacity_slot_id):
		return _get_unit_visual_slot_for_slot_id(capacity_slot_id)
	var legacy_slot_id := _get_legacy_slot_id_for_capacity_slot_id(capacity_slot_id)
	if legacy_slot_id == "":
		return null
	return _get_unit_visual_slot_for_slot_id(legacy_slot_id)


func _has_unit_visual_slot_for_state(unit_state: BattleUnitState) -> bool:
	return _get_unit_visual_slot_for_state(unit_state) != null


func _create_unit_visual_slot_from_dictionary(slot_id: String, slot_visuals: Dictionary) -> UnitVisualSlot:
	if slot_visuals.is_empty():
		return null
	return UnitVisualSlot.create_from_dictionary(slot_id, slot_visuals)


func _get_visual_slots_dictionary_fallback_for_slot_id(slot_id: String) -> Dictionary:
	match slot_id:
		"ally_main":
			return _get_ally_main_visual_slots()
		"ally_support":
			return _get_ally_support_visual_slots()
		"ally_main_03":
			return _get_ally_main_03_visual_slots()
		"ally_reinforce_01":
			return _get_ally_reinforce_01_visual_slots()
		"ally_reinforce_02":
			return _get_ally_reinforce_02_visual_slots()
		"enemy_main":
			return _get_enemy_main_visual_slots()
		"enemy_support":
			return _get_enemy_support_visual_slots()
		"enemy_main_03":
			return _get_enemy_main_03_visual_slots()
		"enemy_reinforce_01":
			return _get_enemy_reinforce_01_visual_slots()
		"enemy_reinforce_02":
			return _get_enemy_reinforce_02_visual_slots()
		_:
			return {}


func _get_ally_main_visual_slots() -> Dictionary:
	return {
		"root": ally_unit_visual_root,
		"token": ally_unit_token,
		"shadow": ally_unit_shadow,
		"portrait": ally_portrait_badge,
		"hp_bar": ally_hp_bar,
		"troop_label": ally_troop_label,
		"move_dust": ally_move_dust_sprite,
		"click_area": ally_unit_click_area,
		"click_shape": ally_unit_click_shape,
		"ready_frame": ally_ready_frame,
		"facing_indicator": ally_facing_indicator,
	}


func _get_ally_support_visual_slots() -> Dictionary:
	return {
		"root": ally_support_unit_visual_root,
		"token": ally_support_unit_token,
		"shadow": ally_support_unit_shadow,
		"portrait": ally_support_portrait_badge,
		"hp_bar": ally_support_hp_bar,
		"troop_label": ally_support_troop_label,
		"move_dust": ally_support_move_dust_sprite,
		"click_area": ally_support_unit_click_area,
		"click_shape": ally_support_unit_click_shape,
		"ready_frame": ally_support_ready_frame,
		"facing_indicator": ally_support_facing_indicator,
	}


func _get_enemy_main_visual_slots() -> Dictionary:
	return {
		"root": enemy_unit_visual_root,
		"token": enemy_unit_token,
		"shadow": enemy_unit_shadow,
		"portrait": enemy_portrait_badge,
		"hp_bar": enemy_hp_bar,
		"troop_label": enemy_troop_label,
		"move_dust": enemy_move_dust_sprite,
		"click_area": enemy_unit_click_area,
		"click_shape": enemy_unit_click_shape,
		"ready_frame": null,
		"facing_indicator": enemy_facing_indicator,
	}


func _get_enemy_support_visual_slots() -> Dictionary:
	return {
		"root": enemy_support_unit_visual_root,
		"token": enemy_support_unit_token,
		"shadow": enemy_support_unit_shadow,
		"portrait": enemy_support_portrait_badge,
		"hp_bar": enemy_support_hp_bar,
		"troop_label": enemy_support_troop_label,
		"move_dust": enemy_support_move_dust_sprite,
		"click_area": enemy_support_unit_click_area,
		"click_shape": enemy_support_unit_click_shape,
		"ready_frame": null,
		"facing_indicator": enemy_support_facing_indicator,
	}


func _get_ally_main_03_visual_slots() -> Dictionary:
	return {
		"root": ally_main_03_unit_visual_root,
		"token": ally_main_03_unit_token,
		"shadow": ally_main_03_unit_shadow,
		"portrait": ally_main_03_portrait_badge,
		"hp_bar": ally_main_03_hp_bar,
		"troop_label": ally_main_03_troop_label,
		"move_dust": ally_main_03_move_dust_sprite,
		"click_area": ally_main_03_unit_click_area,
		"click_shape": ally_main_03_unit_click_shape,
		"ready_frame": ally_main_03_ready_frame,
		"facing_indicator": ally_main_03_facing_indicator,
	}


func _get_ally_reinforce_01_visual_slots() -> Dictionary:
	return {
		"root": ally_reinforce_01_unit_visual_root,
		"token": ally_reinforce_01_unit_token,
		"shadow": ally_reinforce_01_unit_shadow,
		"portrait": ally_reinforce_01_portrait_badge,
		"hp_bar": ally_reinforce_01_hp_bar,
		"troop_label": ally_reinforce_01_troop_label,
		"move_dust": ally_reinforce_01_move_dust_sprite,
		"click_area": ally_reinforce_01_unit_click_area,
		"click_shape": ally_reinforce_01_unit_click_shape,
		"ready_frame": ally_reinforce_01_ready_frame,
		"facing_indicator": ally_reinforce_01_facing_indicator,
	}


func _get_ally_reinforce_02_visual_slots() -> Dictionary:
	return {
		"root": ally_reinforce_02_unit_visual_root,
		"token": ally_reinforce_02_unit_token,
		"shadow": ally_reinforce_02_unit_shadow,
		"portrait": ally_reinforce_02_portrait_badge,
		"hp_bar": ally_reinforce_02_hp_bar,
		"troop_label": ally_reinforce_02_troop_label,
		"move_dust": ally_reinforce_02_move_dust_sprite,
		"click_area": ally_reinforce_02_unit_click_area,
		"click_shape": ally_reinforce_02_unit_click_shape,
		"ready_frame": ally_reinforce_02_ready_frame,
		"facing_indicator": ally_reinforce_02_facing_indicator,
	}


func _get_enemy_main_03_visual_slots() -> Dictionary:
	return {
		"root": enemy_main_03_unit_visual_root,
		"token": enemy_main_03_unit_token,
		"shadow": enemy_main_03_unit_shadow,
		"portrait": enemy_main_03_portrait_badge,
		"hp_bar": enemy_main_03_hp_bar,
		"troop_label": enemy_main_03_troop_label,
		"move_dust": enemy_main_03_move_dust_sprite,
		"click_area": enemy_main_03_unit_click_area,
		"click_shape": enemy_main_03_unit_click_shape,
		"ready_frame": null,
		"facing_indicator": enemy_main_03_facing_indicator,
	}


func _get_enemy_reinforce_01_visual_slots() -> Dictionary:
	return {
		"root": enemy_reinforce_01_unit_visual_root,
		"token": enemy_reinforce_01_unit_token,
		"shadow": enemy_reinforce_01_unit_shadow,
		"portrait": enemy_reinforce_01_portrait_badge,
		"hp_bar": enemy_reinforce_01_hp_bar,
		"troop_label": enemy_reinforce_01_troop_label,
		"move_dust": enemy_reinforce_01_move_dust_sprite,
		"click_area": enemy_reinforce_01_unit_click_area,
		"click_shape": enemy_reinforce_01_unit_click_shape,
		"ready_frame": null,
		"facing_indicator": enemy_reinforce_01_facing_indicator,
	}


func _get_enemy_reinforce_02_visual_slots() -> Dictionary:
	return {
		"root": enemy_reinforce_02_unit_visual_root,
		"token": enemy_reinforce_02_unit_token,
		"shadow": enemy_reinforce_02_unit_shadow,
		"portrait": enemy_reinforce_02_portrait_badge,
		"hp_bar": enemy_reinforce_02_hp_bar,
		"troop_label": enemy_reinforce_02_troop_label,
		"move_dust": enemy_reinforce_02_move_dust_sprite,
		"click_area": enemy_reinforce_02_unit_click_area,
		"click_shape": enemy_reinforce_02_unit_click_shape,
		"ready_frame": null,
		"facing_indicator": enemy_reinforce_02_facing_indicator,
	}


func _debug_print_unit_visual_root_slots() -> void:
	print("UNIT VISUAL ROOT SLOTS:")
	for slot_id in VISUAL_SLOT_CACHE_IDS:
		var slot := _get_unit_visual_slot_for_slot_id(slot_id)
		var slot_visuals := _get_visual_slots_dictionary_fallback_for_slot_id(slot_id)
		var slot_summary: Dictionary = {}
		if slot != null:
			slot_summary = slot.get_debug_summary()
		print("%s cache=%s root=%s token=%s click=%s ready=%s facing=%s dict=%s" % [
			slot_id,
			str(slot != null),
			str(bool(slot_summary.get("root", false))),
			str(bool(slot_summary.get("token", false))),
			str(bool(slot_summary.get("click_area", false))),
			str(bool(slot_summary.get("ready_frame", false))),
			str(bool(slot_summary.get("facing_indicator", false))),
			str(not slot_visuals.is_empty()),
		])


func _debug_print_capacity_slot_registry() -> void:
	print("CAPACITY SLOT REGISTRY:")
	print("capacity_slot_count=%s ally_active=%s enemy_active=%s ally_deployed=%s enemy_deployed=%s" % [
		str(CAPACITY_SLOT_IDS.size()),
		str(_get_active_capacity_slots_for_side("ally")),
		str(_get_active_capacity_slots_for_side("enemy")),
		str(_get_deployed_capacity_slots_for_side("ally")),
		str(_get_deployed_capacity_slots_for_side("enemy")),
	])
	for legacy_slot_id in SLOT_IDS:
		var capacity_slot_id := _get_capacity_slot_id_for_legacy_slot_id(legacy_slot_id)
		var visual_slot := _get_unit_visual_slot_for_capacity_slot_id(capacity_slot_id)
		print("%s -> %s visual=%s active=%s deployed=%s" % [
			legacy_slot_id,
			capacity_slot_id,
			str(visual_slot != null),
			str(_is_capacity_slot_active(capacity_slot_id)),
			str(_is_capacity_slot_deployed(capacity_slot_id)),
		])


func _debug_print_mvp_scene_slot_scaffold_snapshot_once() -> void:
	if has_printed_mvp_scene_slot_scaffold_snapshot:
		return
	has_printed_mvp_scene_slot_scaffold_snapshot = true

	var scene_slot_refs := {
		"ally_main_03": ally_main_03_slot,
		"ally_reinforce_01": ally_reinforce_01_slot,
		"ally_reinforce_02": ally_reinforce_02_slot,
		"enemy_main_03": enemy_main_03_slot,
		"enemy_reinforce_01": enemy_reinforce_01_slot,
		"enemy_reinforce_02": enemy_reinforce_02_slot,
	}
	var found_count := 0
	for scene_slot_ref in scene_slot_refs.values():
		if scene_slot_ref != null:
			found_count += 1

	print("MVP SCENE SLOT SCAFFOLD:")
	print("slot_container_found_count=%s capacity_scene_slot_path_count=%s" % [
		str(found_count),
		str(CAPACITY_SLOT_ID_TO_SCENE_SLOT_PATH.size()),
	])
	print("ally_main_03=%s ally_reinforce_01=%s ally_reinforce_02=%s enemy_main_03=%s enemy_reinforce_01=%s enemy_reinforce_02=%s" % [
		str(ally_main_03_slot != null),
		str(ally_reinforce_01_slot != null),
		str(ally_reinforce_02_slot != null),
		str(enemy_main_03_slot != null),
		str(enemy_reinforce_01_slot != null),
		str(enemy_reinforce_02_slot != null),
	])


func _debug_print_battle_unit_state_list_adapter() -> void:
	print("BATTLE UNIT STATE ADAPTER:")
	print("ally_count=%s enemy_count=%s all_count=%s legacy_keys=%s capacity_keys=%s ally_deployed=%s enemy_deployed=%s" % [
		str(ally_unit_states.size()),
		str(enemy_unit_states.size()),
		str(all_battle_unit_states.size()),
		str(unit_state_by_legacy_slot_id.keys()),
		str(unit_state_by_capacity_slot_id.keys()),
		str(_get_deployed_capacity_slots_for_side("ally")),
		str(_get_deployed_capacity_slots_for_side("enemy")),
	])


func _debug_print_adapter_alive_parity_snapshot_once() -> void:
	if has_printed_adapter_alive_parity_snapshot:
		return
	has_printed_adapter_alive_parity_snapshot = true

	var adapter_alive_allies := _get_alive_deployed_unit_states_for_side("ally")
	var adapter_alive_enemies := _get_alive_deployed_unit_states_for_side("enemy")
	var fallback_alive_allies := _get_fallback_alive_ally_units()
	var fallback_alive_enemies := _get_fallback_alive_enemy_units()
	var adapter_all_alive := _get_all_alive_unit_states_from_adapter()
	var parity_ok := (
		adapter_alive_allies.size() == fallback_alive_allies.size()
		and adapter_alive_enemies.size() == fallback_alive_enemies.size()
		and adapter_all_alive.size() == fallback_alive_allies.size() + fallback_alive_enemies.size()
	)

	print("ADAPTER ALIVE PARITY SNAPSHOT:")
	print("adapter_alive_ally_count=%s adapter_alive_enemy_count=%s fallback_alive_ally_count=%s fallback_alive_enemy_count=%s all_alive_count=%s" % [
		str(adapter_alive_allies.size()),
		str(adapter_alive_enemies.size()),
		str(fallback_alive_allies.size()),
		str(fallback_alive_enemies.size()),
		str(adapter_all_alive.size()),
	])
	print("active_capacity_slots ally=%s enemy=%s deployed_capacity_slots ally=%s enemy=%s parity_ok=%s" % [
		str(_get_active_capacity_slots_for_side("ally")),
		str(_get_active_capacity_slots_for_side("enemy")),
		str(_get_deployed_capacity_slots_for_side("ally")),
		str(_get_deployed_capacity_slots_for_side("enemy")),
		str(parity_ok),
	])


func _debug_print_actor_target_adapter_snapshot_once() -> void:
	if has_printed_actor_target_adapter_snapshot:
		return
	has_printed_actor_target_adapter_snapshot = true

	var ally_actor_candidates := _get_actor_candidates_for_side_from_adapter("ally")
	var enemy_actor_candidates := _get_actor_candidates_for_side_from_adapter("enemy")
	var ally_target_candidates := _get_target_candidates_for_actor_from_adapter(ally_unit_state)
	var enemy_target_candidates := _get_target_candidates_for_actor_from_adapter(enemy_unit_state)
	var auto_ally_targets := _get_alive_auto_targets_for_side("ally")
	var auto_enemy_targets := _get_alive_auto_targets_for_side("enemy")
	var fallback_auto_ally_targets := _get_fallback_target_candidates_for_actor(ally_unit_state)
	var fallback_auto_enemy_targets := _get_fallback_target_candidates_for_actor(enemy_unit_state)
	var adapter_auto_ally_best_target := _find_best_auto_attack_target_from_candidates(ally_unit_state, auto_ally_targets)
	var fallback_auto_ally_best_target := _find_best_auto_attack_target_from_candidates(ally_unit_state, fallback_auto_ally_targets)
	var adapter_auto_enemy_best_target := _find_best_auto_attack_target_from_candidates(enemy_unit_state, auto_enemy_targets)
	var fallback_auto_enemy_best_target := _find_best_auto_attack_target_from_candidates(enemy_unit_state, fallback_auto_enemy_targets)
	var auto_target_parity_ok := (
		auto_ally_targets.size() == fallback_auto_ally_targets.size()
		and auto_enemy_targets.size() == fallback_auto_enemy_targets.size()
		and adapter_auto_ally_best_target == fallback_auto_ally_best_target
		and adapter_auto_enemy_best_target == fallback_auto_enemy_best_target
	)
	var adapter_enemy_target := _get_enemy_ai_target_state_from_candidates(enemy_unit_state, enemy_target_candidates)
	var fallback_enemy_target := _get_enemy_ai_target_state_from_candidates(enemy_unit_state, _get_fallback_alive_ally_units())
	var enemy_ai_target_parity_ok := adapter_enemy_target == fallback_enemy_target
	var enemy_actor_order_parity_ok := _get_next_available_enemy_ai_actor() == _get_first_candidate_from_list(_get_available_actor_candidates_for_side_from_adapter("enemy"))

	print("ACTOR TARGET ADAPTER SNAPSHOT:")
	print("actor_candidates_ally_count=%s actor_candidates_enemy_count=%s target_candidates_for_ally_actor_count=%s target_candidates_for_enemy_actor_count=%s" % [
		str(ally_actor_candidates.size()),
		str(enemy_actor_candidates.size()),
		str(ally_target_candidates.size()),
		str(enemy_target_candidates.size()),
	])
	print("auto_target_parity_ok=%s enemy_ai_target_parity_ok=%s enemy_actor_order_parity_ok=%s" % [
		str(auto_target_parity_ok),
		str(enemy_ai_target_parity_ok),
		str(enemy_actor_order_parity_ok),
	])


func _debug_print_deployed_active_filter_snapshot_once() -> void:
	if has_printed_deployed_active_filter_snapshot:
		return
	has_printed_deployed_active_filter_snapshot = true

	var ally_actor_candidates := _get_actor_candidates_for_side_from_adapter("ally")
	var enemy_actor_candidates := _get_actor_candidates_for_side_from_adapter("enemy")
	var ally_target_candidates := _get_alive_target_candidates_for_side_from_adapter("ally")
	var enemy_target_candidates := _get_alive_target_candidates_for_side_from_adapter("enemy")
	var all_alive_deployed := _get_all_alive_unit_states_from_adapter()
	var parity_ok := (
		ally_actor_candidates.size() == 3
		and enemy_actor_candidates.size() == 3
		and ally_target_candidates.size() == 3
		and enemy_target_candidates.size() == 3
		and all_alive_deployed.size() == 6
	)

	print("DEPLOYED ACTIVE FILTER SNAPSHOT:")
	print("capacity_active_slots ally=%s enemy=%s deployed_slots ally=%s enemy=%s" % [
		str(_get_active_capacity_slots_for_side("ally")),
		str(_get_active_capacity_slots_for_side("enemy")),
		str(_get_deployed_capacity_slots_for_side("ally")),
		str(_get_deployed_capacity_slots_for_side("enemy")),
	])
	print("actor_candidates ally=%s enemy=%s target_candidates ally=%s enemy=%s all_alive_deployed_count=%s phase=%s parity_ok=%s" % [
		str(ally_actor_candidates.size()),
		str(enemy_actor_candidates.size()),
		str(ally_target_candidates.size()),
		str(enemy_target_candidates.size()),
		str(all_alive_deployed.size()),
		str(current_phase),
		str(parity_ok),
	])


func _debug_print_unit_state_visual_binding_summary() -> void:
	print("UNIT STATE VISUAL BINDINGS:")
	for slot_id in VISUAL_SLOT_CACHE_IDS:
		var mapped_unit_state := _get_unit_state_for_capacity_slot_id(slot_id)
		if mapped_unit_state == null:
			mapped_unit_state = _get_unit_state_for_legacy_slot_id(slot_id)
		var slot := _get_unit_visual_slot_for_slot_id(slot_id)
		var visual_node_count := 0
		if slot != null:
			visual_node_count = slot.get_visual_group_nodes().size()
		print("%s state=%s alive=%s hp_ref=%s troop_ref=%s visual_nodes=%s" % [
			slot_id,
			str(mapped_unit_state != null),
			str(mapped_unit_state != null and mapped_unit_state.is_alive()),
			str(slot != null and slot.hp_bar != null),
			str(slot != null and slot.troop_label != null),
			str(visual_node_count),
		])


func _debug_print_hp_troop_runtime_visibility_summary() -> void:
	print("HP TROOP RUNTIME VISIBILITY:")
	for slot_id in VISUAL_SLOT_CACHE_IDS:
		var mapped_unit_state := _get_unit_state_for_capacity_slot_id(slot_id)
		if mapped_unit_state == null:
			mapped_unit_state = _get_unit_state_for_legacy_slot_id(slot_id)
		var slot := _get_unit_visual_slot_for_slot_id(slot_id)
		var hp_bar := _get_hp_bar_for_unit(mapped_unit_state)
		var troop_label := _get_troop_label_for_unit(mapped_unit_state)
		var visual_root_visible := false
		var token_visible := false
		var token_global_position := Vector2.ZERO
		var hp_visible := false
		var troop_visible := false
		var hp_alpha := -1.0
		var troop_alpha := -1.0
		var hp_local_position := Vector2.ZERO
		var troop_local_position := Vector2.ZERO
		var hp_global_position := Vector2.ZERO
		var troop_global_position := Vector2.ZERO
		var hp_size := Vector2.ZERO
		var troop_size := Vector2.ZERO
		var hp_z_index := 0
		var troop_z_index := 0
		var troop_text := ""
		var hp_value := -1.0
		var hp_max_value := -1.0
		if slot != null and slot.root != null:
			visual_root_visible = slot.root.visible
		if slot != null and slot.token != null:
			token_visible = slot.token.visible
			token_global_position = slot.token.global_position
		if hp_bar != null:
			hp_visible = hp_bar.visible
			hp_alpha = hp_bar.modulate.a
			hp_local_position = hp_bar.position
			hp_global_position = hp_bar.global_position
			hp_size = hp_bar.size
			hp_value = hp_bar.value
			hp_max_value = hp_bar.max_value
			hp_z_index = hp_bar.z_index
		if troop_label != null:
			troop_visible = troop_label.visible
			troop_alpha = troop_label.modulate.a
			troop_local_position = troop_label.position
			troop_global_position = troop_label.global_position
			troop_size = troop_label.size
			troop_text = troop_label.text
			troop_z_index = troop_label.z_index
		print("%s token_global=%s hp_ref=%s troop_ref=%s hp_local=%s troop_local=%s hp_global=%s troop_global=%s hp_visible=%s troop_visible=%s hp_alpha=%s troop_alpha=%s hp_z=%s troop_z=%s hp_size=%s troop_size=%s troop_text=%s hp_value=%s hp_max=%s root_visible=%s token_visible=%s" % [
			slot_id,
			str(token_global_position),
			str(hp_bar != null),
			str(troop_label != null),
			str(hp_local_position),
			str(troop_local_position),
			str(hp_global_position),
			str(troop_global_position),
			str(hp_visible),
			str(troop_visible),
			str(hp_alpha),
			str(troop_alpha),
			str(hp_z_index),
			str(troop_z_index),
			str(hp_size),
			str(troop_size),
			str(troop_text),
			str(hp_value),
			str(hp_max_value),
			str(visual_root_visible),
			str(token_visible),
		])


func _debug_print_ally_portrait_offsets() -> void:
	print("=== ALLY PORTRAIT OFFSET DEBUG ===")
	var ally_anchor := _get_ally_visual_anchor_position()
	var ally_support_anchor := _get_ally_support_visual_anchor_position()
	var ally_facing := _get_unit_facing(ally_unit_state)
	var ally_support_facing := _get_unit_facing(ally_support_unit_state)
	var ally_badge_local := "null"
	var ally_badge_global := "null"
	var ally_support_badge_local := "null"
	var ally_support_badge_global := "null"
	if ally_portrait_badge != null:
		ally_badge_local = str(ally_portrait_badge.position)
		ally_badge_global = str(ally_portrait_badge.global_position)
	if ally_support_portrait_badge != null:
		ally_support_badge_local = str(ally_support_portrait_badge.position)
		ally_support_badge_global = str(ally_support_portrait_badge.global_position)

	print("[ALLY MAIN]")
	print("anchor=", ally_anchor)
	print("badge local=", ally_badge_local)
	print("badge global=", ally_badge_global)
	print("fallback offset=", ally_portrait_layout_offset)
	print("left offset=", ally_portrait_layout_offsets_by_facing.get(FACING_LEFT))
	print("right offset=", ally_portrait_layout_offsets_by_facing.get(FACING_RIGHT))
	print("up offset=", ally_portrait_layout_offsets_by_facing.get(FACING_UP))
	print("down offset=", ally_portrait_layout_offsets_by_facing.get(FACING_DOWN))
	print("current facing=", ally_facing)
	print("current selected offset=", _get_portrait_template_offset(
		ally_portrait_layout_offsets_by_facing,
		ally_portrait_layout_offset,
		ally_facing
	))

	print("[ALLY SUPPORT]")
	print("anchor=", ally_support_anchor)
	print("badge local=", ally_support_badge_local)
	print("badge global=", ally_support_badge_global)
	print("fallback offset=", ally_support_portrait_layout_offset)
	print("left offset=", ally_support_portrait_layout_offsets_by_facing.get(FACING_LEFT))
	print("right offset=", ally_support_portrait_layout_offsets_by_facing.get(FACING_RIGHT))
	print("up offset=", ally_support_portrait_layout_offsets_by_facing.get(FACING_UP))
	print("down offset=", ally_support_portrait_layout_offsets_by_facing.get(FACING_DOWN))
	print("current facing=", ally_support_facing)
	print("current selected offset=", _get_portrait_template_offset(
		ally_support_portrait_layout_offsets_by_facing,
		ally_support_portrait_layout_offset,
		ally_support_facing
	))
	print("=== END ALLY PORTRAIT OFFSET DEBUG ===")


func _configure_round_toast() -> void:
	pending_battle_toasts.clear()
	is_battle_toast_playing = false
	active_battle_toast_tag = ""
	if round_toast_root != null:
		round_toast_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
		round_toast_root.visible = false
		round_toast_root_base_scale = round_toast_root.scale
	if round_toast_image != null:
		round_toast_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
		round_toast_default_texture = round_toast_image.texture
		_set_round_toast_shader_progress(0.0)
	if round_toast_label != null:
		round_toast_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		round_toast_label_base_scale = round_toast_label.scale
		round_toast_label.modulate = Color(1.0, 1.0, 1.0, 0.0)


func _configure_unique_skill_toast() -> void:
	if unique_skill_toast_root != null:
		unique_skill_toast_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
		unique_skill_toast_root.position = Vector2.ZERO
		unique_skill_toast_root.size = get_viewport_rect().size
		unique_skill_toast_root.pivot_offset = unique_skill_toast_root.size * 0.5
		unique_skill_toast_root.visible = false
	if unique_skill_ink_burst != null:
		unique_skill_ink_burst.mouse_filter = Control.MOUSE_FILTER_IGNORE
		unique_skill_ink_burst.color = Color(0.0, 0.0, 0.0, 0.42)
		unique_skill_ink_burst.size = get_viewport_rect().size
		unique_skill_ink_burst.visible = false
	if unique_skill_cutin_image != null:
		unique_skill_cutin_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
		unique_skill_cutin_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		unique_skill_cutin_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	if unique_skill_name_label != null:
		unique_skill_name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		unique_skill_name_label.add_theme_font_size_override("font_size", 58)
		unique_skill_name_label.add_theme_color_override("font_color", Color(1.0, 0.86, 0.48, 1.0))
		unique_skill_name_label.add_theme_color_override("font_outline_color", Color(0.04, 0.02, 0.0, 0.95))
		unique_skill_name_label.add_theme_constant_override("outline_size", 7)


func _configure_specialty_skill_cutin() -> void:
	if specialty_skill_cutin_layer != null:
		specialty_skill_cutin_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
		specialty_skill_cutin_layer.visible = false
		specialty_skill_cutin_layer.position = Vector2.ZERO
		specialty_skill_cutin_layer.modulate = Color.WHITE
	if specialty_skill_cutin_darken != null:
		specialty_skill_cutin_darken.mouse_filter = Control.MOUSE_FILTER_IGNORE
		specialty_skill_cutin_darken.color = Color(0.0196078, 0.027451, 0.0392157, 0.0)
	if specialty_skill_cutin_video != null:
		specialty_skill_cutin_video.mouse_filter = Control.MOUSE_FILTER_IGNORE
		specialty_skill_cutin_video.visible = true
		specialty_skill_cutin_video.stream = null
	if specialty_skill_cutin_slash != null:
		specialty_skill_cutin_slash.mouse_filter = Control.MOUSE_FILTER_IGNORE
		specialty_skill_cutin_slash.color = SPECIALTY_SKILL_CUTIN_ACCENT_EXIT_COLOR
	if specialty_skill_cutin_hero != null:
		specialty_skill_cutin_hero.mouse_filter = Control.MOUSE_FILTER_IGNORE
		specialty_skill_cutin_hero.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		specialty_skill_cutin_hero.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if specialty_skill_cutin_text != null:
		specialty_skill_cutin_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
		specialty_skill_cutin_text.modulate = Color.WHITE
	if specialty_skill_cutin_skill_title != null:
		specialty_skill_cutin_skill_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
		specialty_skill_cutin_skill_title.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		specialty_skill_cutin_skill_title.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if specialty_skill_cutin_animation_player != null:
		specialty_skill_cutin_animation_player.stop()


func _layout_specialty_skill_cutin(viewport_size: Vector2, hero_id: String = SPECIALTY_SKILL_VIDEO_CUTIN_HERO_ID) -> Rect2:
	var cutin_config := _get_specialty_skill_cutin_config(hero_id)
	var cutin_size := Vector2(viewport_size.x * 0.88, viewport_size.y * 0.64)
	cutin_size.x = clampf(cutin_size.x, 880.0, viewport_size.x * 0.92)
	cutin_size.y = clampf(cutin_size.y, 360.0, viewport_size.y * 0.72)
	var cutin_position := (viewport_size - cutin_size) * 0.5
	var cutin_rect := Rect2(cutin_position, cutin_size)
	if specialty_skill_cutin_darken != null:
		specialty_skill_cutin_darken.position = Vector2.ZERO
	if specialty_skill_cutin_video != null:
		specialty_skill_cutin_video.position = cutin_rect.position
		specialty_skill_cutin_video.size = cutin_rect.size
	if specialty_skill_cutin_slash != null:
		specialty_skill_cutin_slash.position = cutin_rect.position + Vector2(cutin_rect.size.x * 0.47, cutin_rect.size.y * 0.67)
		specialty_skill_cutin_slash.size = Vector2(cutin_rect.size.x * 0.44, 18.0)
	if specialty_skill_cutin_hero != null:
		var hero_width_ratio := _get_specialty_skill_cutin_config_float(cutin_config, "hero_width_ratio", 0.86)
		var hero_height_ratio := _get_specialty_skill_cutin_config_float(cutin_config, "hero_height_ratio", 1.42)
		var hero_left_overflow := _get_specialty_skill_cutin_config_float(cutin_config, "hero_left_overflow", 0.28)
		var hero_y_anchor := _get_specialty_skill_cutin_config_float(cutin_config, "hero_y_anchor", 0.55)
		var hero_y_offset := _get_specialty_skill_cutin_config_float(cutin_config, "hero_y_offset", 28.0)
		specialty_skill_cutin_hero.size = Vector2(viewport_size.x * hero_width_ratio, viewport_size.y * hero_height_ratio)
		specialty_skill_cutin_hero.position = Vector2(
			cutin_rect.position.x - specialty_skill_cutin_hero.size.x * hero_left_overflow,
			viewport_size.y * 0.5 - specialty_skill_cutin_hero.size.y * hero_y_anchor + hero_y_offset
		)
		specialty_skill_cutin_hero.pivot_offset = specialty_skill_cutin_hero.size * 0.5
	if specialty_skill_cutin_text != null:
		var title_width_ratio := _get_specialty_skill_cutin_config_float(cutin_config, "title_width_ratio", 0.44)
		var title_height_ratio := _get_specialty_skill_cutin_config_float(cutin_config, "title_height_ratio", 0.32)
		var title_x_ratio := _get_specialty_skill_cutin_config_float(cutin_config, "title_x_ratio", 0.53)
		var title_y_ratio := _get_specialty_skill_cutin_config_float(cutin_config, "title_y_ratio", 0.22)
		specialty_skill_cutin_text.size = Vector2(cutin_rect.size.x * title_width_ratio, cutin_rect.size.y * title_height_ratio)
		specialty_skill_cutin_text.position = Vector2(
			cutin_rect.position.x + cutin_rect.size.x * title_x_ratio,
			cutin_rect.position.y + cutin_rect.size.y * title_y_ratio
		)
		specialty_skill_cutin_text.pivot_offset = specialty_skill_cutin_text.size * 0.5
	if specialty_skill_cutin_skill_title != null:
		specialty_skill_cutin_skill_title.position = Vector2.ZERO
		specialty_skill_cutin_skill_title.size = specialty_skill_cutin_text.size if specialty_skill_cutin_text != null else Vector2(cutin_rect.size.x * 0.44, cutin_rect.size.y * 0.32)
		specialty_skill_cutin_skill_title.pivot_offset = specialty_skill_cutin_skill_title.size * 0.5
	return cutin_rect


func _hide_specialty_skill_cutin() -> void:
	if specialty_skill_cutin_video != null:
		specialty_skill_cutin_video.stop()
		specialty_skill_cutin_video.stream = null
	if specialty_skill_cutin_layer != null:
		if specialty_skill_cutin_layer.visible:
			_log_unique_skill_cutin_timing("VIDEO_CUTIN_HIDE_DONE")
		specialty_skill_cutin_layer.visible = false
		specialty_skill_cutin_layer.modulate = Color.WHITE
		specialty_skill_cutin_layer.position = Vector2.ZERO
		specialty_skill_cutin_layer.scale = Vector2.ONE
	if specialty_skill_cutin_darken != null:
		specialty_skill_cutin_darken.color = Color(0.0196078, 0.027451, 0.0392157, 0.0)
	if specialty_skill_cutin_slash != null:
		specialty_skill_cutin_slash.color = SPECIALTY_SKILL_CUTIN_ACCENT_EXIT_COLOR
	if specialty_skill_cutin_hero != null:
		specialty_skill_cutin_hero.modulate = Color.WHITE
		specialty_skill_cutin_hero.scale = Vector2.ONE
	if specialty_skill_cutin_text != null:
		specialty_skill_cutin_text.modulate = Color.WHITE
		specialty_skill_cutin_text.scale = Vector2.ONE
	if specialty_skill_cutin_skill_title != null:
		specialty_skill_cutin_skill_title.texture = null
	is_specialty_skill_cutin_playing = false
	_set_toast_facing_indicator_suppression("unique_skill", false)


func _hide_unique_skill_toast() -> void:
	if unique_skill_toast_root != null and unique_skill_toast_root.visible:
		_log_unique_skill_cutin_timing("HIDE_DONE")
	if unique_skill_toast_root != null:
		unique_skill_toast_root.visible = false
		unique_skill_toast_root.modulate = Color.WHITE
		unique_skill_toast_root.scale = Vector2.ONE
		unique_skill_toast_root.position = Vector2.ZERO
	if unique_skill_ink_burst != null:
		unique_skill_ink_burst.visible = false
		unique_skill_ink_burst.modulate = Color.WHITE
		unique_skill_ink_burst.color = UNIQUE_SKILL_CUTIN_FLASH_COLOR
	if unique_skill_cutin_image != null:
		unique_skill_cutin_image.texture = null
		unique_skill_cutin_image.modulate = Color.WHITE
		unique_skill_cutin_image.scale = Vector2.ONE
	if unique_skill_name_label != null:
		unique_skill_name_label.modulate = Color.WHITE
		unique_skill_name_label.scale = Vector2.ONE
	_set_toast_facing_indicator_suppression("unique_skill", false)


func _configure_enemy_retreat_toast() -> void:
	if enemy_retreat_toast_root != null:
		enemy_retreat_toast_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
		enemy_retreat_toast_root.size = DEFEAT_RETREAT_TOAST_SIZE
		enemy_retreat_toast_root.pivot_offset = DEFEAT_RETREAT_TOAST_SIZE * 0.5
		enemy_retreat_toast_root.visible = false
	if enemy_retreat_portrait != null:
		enemy_retreat_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
		enemy_retreat_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		enemy_retreat_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	if enemy_retreat_name_label != null:
		enemy_retreat_name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		enemy_retreat_name_label.add_theme_font_size_override("font_size", 20)
		enemy_retreat_name_label.add_theme_color_override("font_color", Color(1.0, 0.86, 0.5, 1.0))
		enemy_retreat_name_label.add_theme_color_override("font_outline_color", Color(0.04, 0.02, 0.0, 0.98))
		enemy_retreat_name_label.add_theme_constant_override("outline_size", 3)
	if enemy_retreat_line_label != null:
		enemy_retreat_line_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		enemy_retreat_line_label.add_theme_font_size_override("font_size", 22)
		enemy_retreat_line_label.add_theme_color_override("font_color", Color(0.98, 0.96, 0.88, 1.0))
		enemy_retreat_line_label.add_theme_color_override("font_outline_color", Color(0.04, 0.02, 0.0, 0.98))
		enemy_retreat_line_label.add_theme_constant_override("outline_size", 3)


func _hide_enemy_retreat_toast() -> void:
	if enemy_retreat_toast_root != null:
		enemy_retreat_toast_root.visible = false
		enemy_retreat_toast_root.modulate = Color.WHITE
		enemy_retreat_toast_root.scale = Vector2.ONE
	if enemy_retreat_portrait != null:
		enemy_retreat_portrait.texture = null


func _make_defeat_retreat_toast_snapshot(unit_state: BattleUnitState) -> Dictionary:
	if unit_state == null or unit_state.side not in ["ally", "enemy"]:
		return {}
	return {
		"unit_id": unit_state.unit_id,
		"side": unit_state.side,
		"display_name": unit_state.display_name,
		"line": _get_defeat_retreat_line(unit_state),
		"portrait": _get_retreat_toast_portrait_texture(unit_state),
	}


func _queue_defeat_retreat_toast_snapshot(snapshot: Dictionary) -> void:
	if snapshot.is_empty():
		return
	if enemy_retreat_toast_root == null:
		return
	var queued_snapshot := snapshot.duplicate(true)
	var is_followup_toast := is_defeat_retreat_toast_playing or not defeat_retreat_toast_queue.is_empty()
	if is_followup_toast:
		queued_snapshot["hold_duration"] = DEFEAT_RETREAT_TOAST_QUEUED_DURATION
	else:
		queued_snapshot["hold_duration"] = DEFEAT_RETREAT_TOAST_FIRST_DURATION
	defeat_retreat_toast_queue.append(queued_snapshot)
	call_deferred("_play_next_defeat_retreat_toast")


func _play_next_defeat_retreat_toast() -> void:
	if is_defeat_retreat_toast_playing:
		return
	if enemy_retreat_toast_root == null:
		defeat_retreat_toast_queue.clear()
		return
	if defeat_retreat_toast_queue.is_empty():
		_try_show_battle_result_toast_if_needed()
		return
	var snapshot: Dictionary = defeat_retreat_toast_queue.pop_front()
	var hold_duration := float(snapshot.get("hold_duration", DEFEAT_RETREAT_TOAST_FIRST_DURATION))
	_show_defeat_retreat_toast_snapshot(snapshot, hold_duration)


func _show_defeat_retreat_toast_snapshot(snapshot: Dictionary, hold_duration: float) -> void:
	if snapshot.is_empty() or enemy_retreat_toast_root == null:
		return
	if defeat_retreat_toast_tween != null:
		defeat_retreat_toast_tween.kill()
		defeat_retreat_toast_tween = null
	is_defeat_retreat_toast_playing = true
	active_defeat_retreat_toast_display_name = str(snapshot.get("display_name", "장수"))
	active_defeat_retreat_toast_side = str(snapshot.get("side", ""))
	active_defeat_retreat_toast_hold_msec = int(round(hold_duration * 1000.0))
	var viewport_size := get_viewport_rect().size
	var desired_position := Vector2(
		maxf(12.0, (viewport_size.x - DEFEAT_RETREAT_TOAST_SIZE.x) * 0.5),
		maxf(12.0, viewport_size.y - DEFEAT_RETREAT_TOAST_SIZE.y - 156.0)
	)
	enemy_retreat_toast_root.position = desired_position
	enemy_retreat_toast_root.size = DEFEAT_RETREAT_TOAST_SIZE
	enemy_retreat_toast_root.pivot_offset = DEFEAT_RETREAT_TOAST_SIZE * 0.5
	enemy_retreat_toast_root.visible = true
	enemy_retreat_toast_root.modulate = Color(1.0, 1.0, 1.0, 0.0)
	enemy_retreat_toast_root.scale = Vector2.ONE * 0.92
	if enemy_retreat_portrait != null:
		enemy_retreat_portrait.texture = snapshot.get("portrait", null) as Texture2D
		enemy_retreat_portrait.visible = enemy_retreat_portrait.texture != null
	if enemy_retreat_name_label != null:
		enemy_retreat_name_label.text = str(snapshot.get("display_name", "장수"))
		if str(snapshot.get("side", "")) == "ally":
			enemy_retreat_name_label.add_theme_color_override("font_color", Color(0.58, 0.78, 1.0, 1.0))
		else:
			enemy_retreat_name_label.add_theme_color_override("font_color", Color(1.0, 0.86, 0.5, 1.0))
	if enemy_retreat_line_label != null:
		enemy_retreat_line_label.text = str(snapshot.get("line", "전열에서 물러난다!"))
	defeat_retreat_toast_tween = create_tween()
	defeat_retreat_toast_tween.set_parallel(true)
	defeat_retreat_toast_tween.tween_property(enemy_retreat_toast_root, "modulate:a", 1.0, DEFEAT_RETREAT_TOAST_FADE_IN_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	defeat_retreat_toast_tween.tween_property(enemy_retreat_toast_root, "scale", Vector2.ONE, DEFEAT_RETREAT_TOAST_FADE_IN_DURATION).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	defeat_retreat_toast_tween.set_parallel(false)
	defeat_retreat_toast_tween.chain().tween_callback(_begin_defeat_retreat_toast_hold)
	defeat_retreat_toast_tween.tween_interval(hold_duration)
	defeat_retreat_toast_tween.chain().tween_callback(_log_defeat_retreat_toast_hold_elapsed)
	defeat_retreat_toast_tween.chain().set_parallel(true)
	defeat_retreat_toast_tween.tween_property(enemy_retreat_toast_root, "modulate:a", 0.0, DEFEAT_RETREAT_TOAST_FADE_OUT_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	defeat_retreat_toast_tween.tween_property(enemy_retreat_toast_root, "scale", Vector2.ONE * 0.985, DEFEAT_RETREAT_TOAST_FADE_OUT_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	defeat_retreat_toast_tween.tween_property(enemy_retreat_toast_root, "position", desired_position + Vector2(0.0, 6.0), DEFEAT_RETREAT_TOAST_FADE_OUT_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	defeat_retreat_toast_tween.chain().tween_callback(_finish_defeat_retreat_toast)


func _begin_defeat_retreat_toast_hold() -> void:
	active_defeat_retreat_toast_started_msec = Time.get_ticks_msec()
	if DEFEAT_RETREAT_TOAST_DEBUG_LOGS:
		print("[DefeatToast] SHOW unit=%s side=%s t=%d hold_ms=%d queue_remaining=%d" % [
			active_defeat_retreat_toast_display_name,
			active_defeat_retreat_toast_side,
			active_defeat_retreat_toast_started_msec,
			active_defeat_retreat_toast_hold_msec,
			defeat_retreat_toast_queue.size(),
		])


func _log_defeat_retreat_toast_hold_elapsed() -> void:
	if not DEFEAT_RETREAT_TOAST_DEBUG_LOGS:
		return
	var now_msec := Time.get_ticks_msec()
	print("[DefeatToast] HOLD_DONE unit=%s t=%d elapsed=%dms" % [
		active_defeat_retreat_toast_display_name,
		now_msec,
		now_msec - active_defeat_retreat_toast_started_msec,
	])


func _finish_defeat_retreat_toast() -> void:
	if DEFEAT_RETREAT_TOAST_DEBUG_LOGS:
		var now_msec := Time.get_ticks_msec()
		print("[DefeatToast] HIDE unit=%s t=%d elapsed=%dms" % [
			active_defeat_retreat_toast_display_name,
			now_msec,
			now_msec - active_defeat_retreat_toast_started_msec,
		])
	defeat_retreat_toast_tween = null
	is_defeat_retreat_toast_playing = false
	_hide_enemy_retreat_toast()
	active_defeat_retreat_toast_started_msec = 0
	active_defeat_retreat_toast_display_name = ""
	active_defeat_retreat_toast_side = ""
	active_defeat_retreat_toast_hold_msec = 0
	if defeat_retreat_toast_queue.is_empty():
		call_deferred("_try_show_battle_result_toast_if_needed")
	else:
		call_deferred("_play_next_defeat_retreat_toast")


func _get_retreat_toast_portrait_texture(unit_state: BattleUnitState) -> Texture2D:
	var hero_entry := _get_hero_registry_entry(_get_hero_id_for_unit_state(unit_state))
	var texture := _load_unique_skill_texture(String(hero_entry.get("battlefield_portrait_path", "")))
	if texture != null:
		return texture
	texture = _load_unique_skill_texture(String(hero_entry.get("closeup_portrait_path", "")))
	if texture != null:
		return texture
	return _get_troop_icon_texture_for_visual_key(unit_state.visual_key, unit_state)


func _get_defeat_retreat_line(unit_state: BattleUnitState) -> String:
	var lines := ENEMY_RETREAT_TOAST_LINES
	var fallback := "후퇴한다!"
	if unit_state != null and unit_state.side == "ally":
		lines = ALLY_DEFEAT_TOAST_LINES
		fallback = "전열에서 물러나겠습니다!"
	if lines.is_empty():
		return fallback
	var line_index := absi(unit_state.unit_id.hash()) % lines.size()
	return String(lines[line_index])


func _show_round_start_banner() -> void:
	if _handle_battle_end_guard("round_start_banner"):
		print("[TOAST_BLOCKED] source=round_start_banner reason=result_finalized")
		return
	_show_round_start_toast(battle_round)


func _show_round_start_toast(round_num: int) -> void:
	_enqueue_battle_toast(round_toast_default_texture, "BATTLE %d" % round_num, 1.15, 0, "round_start")


func _show_reinforcement_arrival_toast(arrival_round: int, arriving_units: Array[String] = []) -> void:
	if _handle_battle_end_guard("reinforcement_toast"):
		print("[REINFORCEMENT_TOAST_SKIP] round=%d reason=result_finalized" % arrival_round)
		return
	if arriving_units.is_empty():
		print("[REINFORCEMENT_TOAST_SKIP] round=%d reason=no_arriving_units" % arrival_round)
		return
	_enqueue_battle_toast(REINFORCEMENT_ARRIVAL_TOAST_TEXTURE, REINFORCEMENT_ARRIVAL_TOAST_TEXT, 0.82, 100, "reinforcement_arrival")
	print("[REINFORCEMENT_TOAST] queued round=%d arriving=%s text=%s texture=%s" % [
		arrival_round,
		str(arriving_units),
		REINFORCEMENT_ARRIVAL_TOAST_TEXT,
		_get_toast_texture_debug_name(REINFORCEMENT_ARRIVAL_TOAST_TEXTURE)
	])


func _show_battle_result_toast(is_victory: bool) -> void:
	var toast_texture: Texture2D = DEFEAT_TOAST_TEXTURE
	var toast_text := DEFEAT_TOAST_TEXT
	var toast_tag := "result_defeat"
	if is_victory:
		toast_texture = VICTORY_TOAST_TEXTURE
		toast_text = VICTORY_TOAST_TEXT
		toast_tag = "result_victory"
	_enqueue_battle_toast(
		toast_texture,
		toast_text,
		1.1 + RESULT_TOAST_HOLD_EXTRA_SECONDS,
		200,
		toast_tag,
		RESULT_TOAST_SCALE_MULTIPLIER
	)


func _enqueue_battle_toast(
	toast_texture: Texture2D,
	toast_text: String,
	hold_duration: float,
	priority: int = 0,
	toast_tag: String = "generic",
	toast_scale_multiplier: float = 1.0
) -> void:
	if _is_battle_result_finalized() and not _is_result_toast_tag(toast_tag):
		print("[TOAST_BLOCKED] tag=%s reason=result_finalized" % toast_tag)
		return
	var toast_entry := {
		"texture": toast_texture,
		"text": toast_text,
		"hold_duration": hold_duration,
		"priority": priority,
		"tag": toast_tag,
		"scale_multiplier": toast_scale_multiplier,
	}
	var insert_index := pending_battle_toasts.size()
	for queue_index in range(pending_battle_toasts.size()):
		var queued_entry = pending_battle_toasts[queue_index]
		var queued_priority := int(queued_entry.get("priority", 0))
		if priority > queued_priority:
			insert_index = queue_index
			break
	pending_battle_toasts.insert(insert_index, toast_entry)
	call_deferred("_play_next_battle_toast")


func _play_next_battle_toast() -> void:
	if is_battle_toast_playing:
		return
	if round_toast_root == null:
		pending_battle_toasts.clear()
		return
	if pending_battle_toasts.is_empty():
		return

	var toast_entry = pending_battle_toasts.pop_front()
	var toast_texture = toast_entry.get("texture", null) as Texture2D
	var toast_text := str(toast_entry.get("text", ""))
	var hold_duration := float(toast_entry.get("hold_duration", 1.0))
	var toast_scale_multiplier := maxf(float(toast_entry.get("scale_multiplier", 1.0)), 0.01)
	active_battle_toast_tag = str(toast_entry.get("tag", "generic"))
	if _is_battle_result_finalized() and not _is_result_toast_tag(active_battle_toast_tag):
		print("[TOAST_BLOCKED] tag=%s reason=result_finalized_playback" % active_battle_toast_tag)
		active_battle_toast_tag = ""
		call_deferred("_play_next_battle_toast")
		return
	print("[BATTLE_TOAST_PLAY] tag=%s text=%s texture=%s queue_remaining=%d" % [
		active_battle_toast_tag,
		toast_text,
		_get_toast_texture_debug_name(_get_resolved_toast_texture(toast_texture)),
		pending_battle_toasts.size()
	])
	_show_battle_toast(toast_texture, toast_text, hold_duration, toast_scale_multiplier)


func _get_battle_result_state() -> String:
	var ally_alive_count := _get_alive_deployed_unit_states_for_side("ally").size()
	var enemy_alive_count := _get_alive_deployed_unit_states_for_side("enemy").size()
	if enemy_alive_count <= 0 and ally_alive_count > 0:
		return "victory"
	if ally_alive_count <= 0:
		return "defeat"
	return ""


func _is_battle_result_finalized() -> bool:
	return _get_battle_result_state() != ""


func _is_result_toast_tag(toast_tag: String) -> bool:
	return toast_tag.begins_with("result_")


func _clear_non_result_battle_toasts(source: String) -> void:
	var kept_toasts: Array = []
	var removed_count := 0
	for toast_entry in pending_battle_toasts:
		var toast_tag := str(toast_entry.get("tag", "generic"))
		if _is_result_toast_tag(toast_tag):
			kept_toasts.append(toast_entry)
		else:
			removed_count += 1
	pending_battle_toasts = kept_toasts
	if removed_count > 0:
		print("[TOAST_BLOCKED] source=%s reason=result_finalized cleared=%d" % [source, removed_count])
	if is_battle_toast_playing and not _is_result_toast_tag(active_battle_toast_tag):
		if round_toast_tween != null:
			round_toast_tween.kill()
			round_toast_tween = null
		_hide_round_start_toast()
		is_battle_toast_playing = false
		active_battle_toast_tag = ""
		_set_toast_facing_indicator_suppression("battle", false)
		print("[TOAST_BLOCKED] source=%s reason=result_finalized active_toast_cancelled" % source)


func _handle_battle_end_guard(source: String) -> bool:
	var battle_result_state := _get_battle_result_state()
	if battle_result_state == "":
		return false
	_clear_non_result_battle_toasts(source)
	if is_full_auto_battle_enabled:
		_stop_full_auto_battle("battle result finalized")
		print("[AUTO_BATTLE_STOP] source=%s reason=battle_result_finalized state=%s" % [
			source,
			battle_result_state
		])
	if not has_logged_battle_end_guard:
		has_logged_battle_end_guard = true
		print("[BATTLE_END] source=%s state=%s ally_alive=%d enemy_alive=%d" % [
			source,
			battle_result_state,
			_get_alive_deployed_unit_states_for_side("ally").size(),
			_get_alive_deployed_unit_states_for_side("enemy").size()
		])
	return true


func _try_show_battle_result_toast_if_needed() -> bool:
	var battle_result_state := _get_battle_result_state()
	if battle_result_state == "":
		return false
	_handle_battle_end_guard("result_toast")
	if has_battle_result_toast_shown:
		return true
	if is_defeat_retreat_toast_playing or not defeat_retreat_toast_queue.is_empty():
		return false
	has_battle_result_toast_shown = true
	var is_victory := battle_result_state == "victory"
	_show_battle_result_toast(is_victory)
	_refresh_worldmap_result_return_button()
	print("[BATTLE_RESULT] state=%s ally_alive=%d enemy_alive=%d" % [
		battle_result_state,
		_get_alive_deployed_unit_states_for_side("ally").size(),
		_get_alive_deployed_unit_states_for_side("enemy").size()
	])
	return true


func _get_resolved_toast_texture(toast_texture: Texture2D) -> Texture2D:
	var resolved_toast_texture := round_toast_default_texture
	if toast_texture != null:
		resolved_toast_texture = toast_texture
	return resolved_toast_texture


func _show_battle_toast(
	toast_texture: Texture2D,
	toast_text: String,
	hold_duration: float,
	toast_scale_multiplier: float = 1.0
) -> void:
	if round_toast_root == null:
		return
	if round_toast_tween != null:
		round_toast_tween.kill()
		round_toast_tween = null
	_set_toast_facing_indicator_suppression("battle", true)

	var resolved_scale_multiplier := maxf(toast_scale_multiplier, 0.01)

	if round_toast_label != null:
		round_toast_label.text = toast_text
		round_toast_label.visible = true
		round_toast_label.modulate.a = 0.0
		round_toast_label.scale = round_toast_label_base_scale * 0.9 * resolved_scale_multiplier
	if round_toast_image != null:
		round_toast_image.visible = true
		round_toast_image.modulate = Color.WHITE
		round_toast_image.texture = _get_resolved_toast_texture(toast_texture)
	_set_round_toast_shader_progress(0.0)

	round_toast_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	round_toast_root.visible = true
	round_toast_root.modulate = Color(1.0, 1.0, 1.0, 0.0)
	round_toast_root.scale = round_toast_root_base_scale * 0.86 * resolved_scale_multiplier
	is_battle_toast_playing = true

	round_toast_tween = create_tween()
	round_toast_tween.set_parallel(true)
	round_toast_tween.tween_method(_set_round_toast_shader_progress, 0.0, 1.0, 0.42).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	round_toast_tween.tween_property(round_toast_root, "modulate:a", 1.0, 0.42)
	round_toast_tween.tween_property(round_toast_root, "scale", round_toast_root_base_scale * 1.06 * resolved_scale_multiplier, 0.42).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if round_toast_label != null:
		round_toast_tween.tween_property(round_toast_label, "modulate:a", 1.0, 0.28).set_delay(0.05)
		round_toast_tween.tween_property(round_toast_label, "scale", round_toast_label_base_scale * resolved_scale_multiplier, 0.28).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).set_delay(0.05)
	round_toast_tween.set_parallel(false)
	round_toast_tween.chain().tween_property(round_toast_root, "scale", round_toast_root_base_scale * resolved_scale_multiplier, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	round_toast_tween.tween_interval(hold_duration)
	round_toast_tween.set_parallel(true)
	round_toast_tween.tween_property(round_toast_root, "modulate:a", 0.0, 0.32).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	round_toast_tween.tween_property(round_toast_root, "scale", round_toast_root_base_scale * 1.12 * resolved_scale_multiplier, 0.32).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	round_toast_tween.chain().tween_callback(_finish_battle_toast_playback)


func _set_round_toast_shader_progress(progress: float) -> void:
	if round_toast_image == null:
		return
	var shader_material := round_toast_image.material as ShaderMaterial
	if shader_material == null or shader_material.shader == null:
		return
	shader_material.set_shader_parameter("progress", progress)


func _hide_round_start_toast() -> void:
	if round_toast_root != null:
		round_toast_root.visible = false
		round_toast_root.modulate = Color.WHITE
		round_toast_root.scale = round_toast_root_base_scale
	if round_toast_label != null:
		round_toast_label.modulate = Color.WHITE
		round_toast_label.scale = round_toast_label_base_scale
	if round_toast_image != null and round_toast_default_texture != null:
		round_toast_image.texture = round_toast_default_texture
	_set_round_toast_shader_progress(0.0)


func _finish_battle_toast_playback() -> void:
	_hide_round_start_toast()
	round_toast_tween = null
	is_battle_toast_playing = false
	active_battle_toast_tag = ""
	_set_toast_facing_indicator_suppression("battle", false)
	call_deferred("_play_next_battle_toast")


func _get_toast_texture_debug_name(texture: Texture2D) -> String:
	if texture == null:
		return "null"
	var resource_path := texture.resource_path
	if resource_path != "":
		return resource_path.get_file()
	return str(texture)


func _show_move_dust_for_unit(unit_state: BattleUnitState) -> void:
	var sprite := _get_move_dust_sprite_for_unit(unit_state)
	if sprite == null:
		return
	_hide_all_move_dust_sprites()
	var texture := _load_random_fx_texture(MOVE_DUST_FX_TEXTURE_PATHS)
	if texture != null:
		sprite.texture = texture
	_kill_move_dust_tween(sprite)
	_apply_move_dust_template_to_sprite(sprite)
	sprite.visible = true


func _fade_out_move_dust_for_unit(unit_state: BattleUnitState) -> void:
	var sprite := _get_move_dust_sprite_for_unit(unit_state)
	if sprite == null:
		return
	var base_scale := sprite.scale
	var base_modulate := sprite.modulate
	if move_dust_template != null:
		base_scale = move_dust_template.scale
		base_modulate = move_dust_template.modulate
	_kill_move_dust_tween(sprite)
	sprite.visible = true
	var tween := create_tween()
	move_dust_tweens[sprite.get_instance_id()] = tween
	tween.set_parallel(true)
	tween.tween_property(sprite, "modulate:a", 0.0, randf_range(0.18, 0.28)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "scale", base_scale * 1.05, randf_range(0.18, 0.28)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.chain().tween_callback(func() -> void:
		sprite.visible = false
		sprite.scale = base_scale
		sprite.modulate = base_modulate
		sprite.modulate.a = 0.0
		move_dust_tweens.erase(sprite.get_instance_id())
	)


func _hide_all_move_dust_sprites() -> void:
	if move_dust_template != null:
		move_dust_template.visible = false
	for sprite in [
		ally_move_dust_sprite,
		ally_support_move_dust_sprite,
		ally_main_03_move_dust_sprite,
		ally_reinforce_01_move_dust_sprite,
		ally_reinforce_02_move_dust_sprite,
		enemy_move_dust_sprite,
		enemy_support_move_dust_sprite,
		enemy_main_03_move_dust_sprite,
		enemy_reinforce_01_move_dust_sprite,
		enemy_reinforce_02_move_dust_sprite,
	]:
		if sprite == null:
			continue
		_kill_move_dust_tween(sprite)
		sprite.visible = false
		_apply_move_dust_template_to_sprite(sprite)
		sprite.modulate.a = 0.0


func _get_move_dust_sprite_for_unit(unit_state: BattleUnitState) -> Sprite2D:
	var slot := _get_unit_visual_slot_for_state(unit_state)
	if slot != null and slot.move_dust != null:
		return slot.move_dust as Sprite2D
	if unit_state == ally_main_03_unit_state:
		return ally_main_03_move_dust_sprite
	if unit_state == ally_reinforce_01_unit_state:
		return ally_reinforce_01_move_dust_sprite
	if unit_state == ally_reinforce_02_unit_state:
		return ally_reinforce_02_move_dust_sprite
	if unit_state == ally_support_unit_state:
		return ally_support_move_dust_sprite
	if unit_state == enemy_unit_state:
		return enemy_move_dust_sprite
	if unit_state == enemy_support_unit_state:
		return enemy_support_move_dust_sprite
	if unit_state == enemy_main_03_unit_state:
		return enemy_main_03_move_dust_sprite
	if unit_state == enemy_reinforce_01_unit_state:
		return enemy_reinforce_01_move_dust_sprite
	if unit_state == enemy_reinforce_02_unit_state:
		return enemy_reinforce_02_move_dust_sprite
	return ally_move_dust_sprite


func _get_move_dust_base_scale(sprite: Sprite2D) -> Vector2:
	if sprite == null or move_dust_template == null:
		return Vector2.ONE
	return move_dust_template.scale


func _kill_move_dust_tween(sprite: Sprite2D) -> void:
	if sprite == null:
		return
	var key := sprite.get_instance_id()
	var tween := move_dust_tweens.get(key) as Tween
	if tween != null:
		tween.kill()
		move_dust_tweens.erase(key)


func _apply_move_dust_template_to_sprite(sprite: Sprite2D) -> void:
	if sprite == null or move_dust_template == null:
		return
	sprite.position = move_dust_template.position
	sprite.scale = move_dust_template.scale
	sprite.modulate = move_dust_template.modulate
	sprite.z_index = move_dust_template.z_index


func _spawn_attack_battle_dust_fx(_attacker_pos: Vector2, _target_pos: Vector2) -> void:
	return


func _spawn_hit_battle_dust_fx(target_pos: Vector2) -> void:
	_spawn_battle_dust_fx(
		target_pos + BATTLE_DUST_HIT_OFFSET,
		BATTLE_DUST_ALPHA_MIN,
		BATTLE_DUST_ALPHA_MAX,
		BATTLE_DUST_SCALE_MULTIPLIER_MIN,
		BATTLE_DUST_SCALE_MULTIPLIER_MAX
	)


func _spawn_battle_dust_fx(
	world_pos: Vector2,
	alpha_min: float,
	alpha_max: float,
	scale_min: float,
	scale_max: float
) -> void:
	var texture := _load_random_fx_texture(MOVE_DUST_FX_TEXTURE_PATHS)
	if texture == null:
		return
	var sprite := _create_fx_sprite(texture, world_pos)
	if sprite == null:
		return
	sprite.name = "BattleDustFX"
	var alpha := randf_range(alpha_min, alpha_max)
	var duration := randf_range(BATTLE_DUST_DURATION_MIN, BATTLE_DUST_DURATION_MAX)
	var scale_multiplier := randf_range(scale_min, scale_max)
	var end_scale_multiplier := scale_multiplier * 1.03
	sprite.z_as_relative = false
	sprite.z_index = BATTLE_DUST_WORLD_Z_INDEX
	sprite.rotation = randf_range(-0.08, 0.08)
	sprite.modulate = Color(BATTLE_DUST_TINT.r, BATTLE_DUST_TINT.g, BATTLE_DUST_TINT.b, 0.0)
	sprite.scale = Vector2.ONE * scale_multiplier

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "modulate:a", alpha, duration * 0.24).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "scale", Vector2.ONE * end_scale_multiplier, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.chain().tween_property(sprite, "modulate:a", 0.0, duration * 0.76).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(sprite.queue_free)


func _spawn_attack_slash_fx(attacker_pos: Vector2, target_pos: Vector2) -> void:
	var texture := _load_random_fx_texture(ATTACK_SLASH_FX_TEXTURE_PATHS)
	if texture == null:
		return
	var direction := target_pos - attacker_pos
	var spawn_pos := target_pos
	if direction.length() > 0.0:
		spawn_pos = target_pos - direction.normalized() * 18.0
	var sprite := _create_fx_sprite(texture, spawn_pos + Vector2(0.0, -12.0))
	if sprite == null:
		return
	sprite.z_index = 24
	sprite.rotation = 0.0
	if direction.length() > 0.0:
		sprite.rotation = direction.angle()
	sprite.modulate = Color(1.0, 1.0, 1.0, 0.0)
	sprite.scale = Vector2.ONE * 0.75

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "modulate:a", 1.0, 0.05)
	tween.tween_property(sprite, "scale", Vector2.ONE * 1.05, 0.16).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.chain().tween_interval(0.05)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(sprite.queue_free)


func _spawn_hit_spark_fx(target_pos: Vector2) -> void:
	var texture := _load_random_fx_texture(HIT_SPARK_FX_TEXTURE_PATHS)
	if texture == null:
		return
	var sprite := _create_fx_sprite(texture, target_pos + Vector2(0.0, -18.0))
	if sprite == null:
		return
	sprite.z_index = 26
	sprite.rotation = randf_range(-0.25, 0.25)
	sprite.modulate = Color(1.0, 1.0, 1.0, 0.0)
	sprite.scale = Vector2.ONE * 0.45

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "modulate:a", 1.0, 0.04)
	tween.tween_property(sprite, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.chain().tween_property(sprite, "modulate:a", 0.0, 0.14).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(sprite.queue_free)


func _spawn_damage_number_fx(target_pos: Vector2, amount: int) -> void:
	if battle_fx_root == null:
		return
	var label := Label.new()
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.text = "-%d" % amount
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 48)
	label.add_theme_color_override("font_color", Color(1.0, 0.82, 0.42, 1.0))
	label.add_theme_color_override("font_outline_color", Color(0.08, 0.04, 0.0, 0.82))
	label.add_theme_constant_override("outline_size", 3)
	label.size = Vector2(150.0, 70.0)
	label.position = target_pos + Vector2(-75.0, -88.0)
	label.z_index = 30
	label.modulate = Color.WHITE
	label.scale = Vector2.ONE * 0.95
	battle_fx_root.add_child(label)

	var end_position := label.position + Vector2(0.0, -30.0)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position", end_position, 0.75).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "scale", Vector2.ONE * 1.05, 0.75).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.75).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(label.queue_free)


func _spawn_skill_damage_number_fx(target_pos: Vector2, amount: int) -> void:
	if battle_fx_root == null:
		return
	var label := Label.new()
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.text = "-%d" % maxi(0, amount)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", UNIQUE_SKILL_DAMAGE_FONT_SIZE)
	label.add_theme_color_override("font_color", Color(1.0, 0.18, 0.08, 1.0))
	label.add_theme_color_override("font_outline_color", Color(0.02, 0.0, 0.0, 0.95))
	label.add_theme_constant_override("outline_size", 5)
	label.size = Vector2(170.0, 76.0)
	label.position = target_pos + Vector2(-85.0, -116.0)
	label.z_index = 36
	label.modulate = Color.WHITE
	label.scale = Vector2.ONE * 1.08
	battle_fx_root.add_child(label)

	var end_position := label.position + Vector2(0.0, -44.0)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position", end_position, 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "scale", Vector2.ONE * 1.24, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(label.queue_free)


func _spawn_buff_number_fx(target_pos: Vector2, text: String) -> void:
	if battle_fx_root == null:
		return
	var label := Label.new()
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 28)
	label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.42, 1.0))
	label.add_theme_color_override("font_outline_color", Color(0.05, 0.03, 0.0, 0.9))
	label.add_theme_constant_override("outline_size", 4)
	label.size = Vector2(150.0, 56.0)
	label.position = target_pos + Vector2(-75.0, -132.0)
	label.z_index = 35
	battle_fx_root.add_child(label)

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position", label.position + Vector2(0.0, -24.0), 0.72).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.72).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(label.queue_free)


func _spawn_defend_heal_text_fx(target_pos: Vector2, text: String) -> void:
	if battle_fx_root == null:
		return
	var label := Label.new()
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 28)
	label.add_theme_color_override("font_color", DEFEND_HEAL_TEXT_COLOR)
	label.add_theme_color_override("font_outline_color", Color(0.02, 0.05, 0.02, 0.88))
	label.add_theme_constant_override("outline_size", 4)
	label.size = Vector2(120.0, 48.0)
	label.position = target_pos + Vector2(-60.0, -104.0)
	label.z_index = 36
	battle_fx_root.add_child(label)

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position", label.position + Vector2(0.0, -22.0), 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(label.queue_free)


func _spawn_strategy_text_fx(target_pos: Vector2, text: String, color: Color) -> void:
	if battle_fx_root == null:
		return
	var label := Label.new()
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 26)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.04, 0.94))
	label.add_theme_constant_override("outline_size", 4)
	label.size = Vector2(170.0, 58.0)
	label.position = target_pos + Vector2(-85.0, -128.0)
	label.z_index = 36
	battle_fx_root.add_child(label)

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position", label.position + Vector2(0.0, -28.0), 0.78).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.78).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(label.queue_free)


func _start_unique_skill_camera_shake(effect_type: String) -> void:
	var camera := _get_main_camera_or_null()
	if camera == null:
		return
	if combat_camera_tween != null:
		combat_camera_tween.kill()
		combat_camera_tween = null
	if camera_shake_tween != null:
		camera_shake_tween.kill()
	main_camera_base_position = camera.position
	var duration := 0.24
	var strength := 12.0
	if effect_type == "cannon_aoe" or effect_type == "single_damage_adjacent_shake":
		duration = 0.30
		strength = 14.0
	var shake_steps := 8
	camera_shake_tween = create_tween()
	for step in range(shake_steps):
		var offset := Vector2(randf_range(-strength, strength), randf_range(-strength, strength))
		camera_shake_tween.tween_property(camera, "position", main_camera_base_position + offset, duration / float(shake_steps)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	camera_shake_tween.tween_property(camera, "position", main_camera_base_position, 0.04).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _load_random_fx_texture(paths: Array[String]) -> Texture2D:
	if paths.is_empty():
		return null
	var path := paths[randi() % paths.size()]
	if not ResourceLoader.exists(path):
		return null
	return load(path) as Texture2D


func _create_fx_sprite(texture: Texture2D, world_pos: Vector2) -> Sprite2D:
	if battle_fx_root == null or texture == null:
		return null
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.centered = true
	sprite.position = battle_fx_root.to_local(world_pos)
	battle_fx_root.add_child(sprite)
	return sprite


func _start_new_round() -> void:
	if _handle_battle_end_guard("start_new_round"):
		print("[TURN_ADVANCE_BLOCKED] source=start_new_round reason=result_finalized")
		return
	battle_round += 1
	_clear_pending_move_snapshot()
	_hide_all_move_dust_sprites()
	_reset_ally_action_locks_for_new_round()
	_reset_enemy_action_locks_for_new_round()
	_tick_unique_skill_cooldowns_for_side("ally")
	_tick_unique_skill_cooldowns_for_side("enemy")
	_refresh_formation_slot_guides()
	_refresh_strategy_status_icon_labels()
	_append_battle_log("BATTLE %d 시작" % battle_round)
	_try_deploy_reinforce_01_pair()
	_try_deploy_city_reinforce_02_pair()
	_show_round_start_banner()


func _apply_group_offset(nodes: Array[CanvasItem], base_positions: Array[Vector2], offset: Vector2) -> void:
	for index in range(nodes.size()):
		if nodes[index] != null and index < base_positions.size():
			_set_canvas_item_world_position(nodes[index], base_positions[index] + offset)


func _apply_ally_group_offset(offset: Vector2) -> void:
	_apply_group_offset_for_unit(ally_unit_state, offset)


func _apply_enemy_group_offset(offset: Vector2) -> void:
	_apply_group_offset_for_unit(enemy_unit_state, offset)


func _apply_enemy_support_group_offset(offset: Vector2) -> void:
	_apply_group_offset_for_unit(enemy_support_unit_state, offset)


func _apply_enemy_actor_group_offset(offset: Vector2, enemy_actor_state: BattleUnitState) -> void:
	_apply_group_offset_for_unit(enemy_actor_state, offset)


func _set_group_modulate(nodes: Array[CanvasItem], color: Color) -> void:
	for node in nodes:
		if node != null:
			node.modulate = color
	_apply_hp_bar_alpha_to_all_units()


func _set_ally_group_modulate(color: Color) -> void:
	_set_group_modulate(_get_ally_group_nodes(), color)


func _set_enemy_group_modulate(color: Color) -> void:
	_set_group_modulate(_get_enemy_group_nodes(), color)


func _set_enemy_actor_group_modulate(enemy_actor_state: BattleUnitState, color: Color) -> void:
	_set_group_modulate(_get_enemy_actor_group_nodes(enemy_actor_state), color)


func _set_all_unit_group_modulates(color: Color) -> void:
	for unit_state in _get_all_unit_states_in_slot_order():
		_set_group_modulate(_get_visual_group_nodes_for_unit(unit_state), color)


func _show_move_highlight_at_position(world_position: Vector2) -> void:
	var highlight_size := MOVE_HIGHLIGHT_SIZE
	if battle_grid_controller != null:
		var cell_size := battle_grid_controller.get_cell_size()
		if cell_size.x > 0.0 and cell_size.y > 0.0:
			highlight_size = cell_size

	move_highlight.position = world_position - (highlight_size * 0.5)
	move_highlight.size = highlight_size


func _collect_move_range_cells() -> void:
	move_range_cells.clear()
	if move_range_overlay_layer == null:
		return

	for child in move_range_overlay_layer.get_children():
		if child is ColorRect:
			var cell := child as ColorRect
			cell.set_script(BattleRangeOverlayTileScript)
			move_range_cells.append(cell)
			cell.visible = false
			cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
			cell.modulate = Color(1.0, 1.0, 1.0, 0.0)
			cell.scale = Vector2.ONE
			cell.color = Color.TRANSPARENT


func _hide_move_range_overlay() -> void:
	_clear_range_overlay_tweens()
	for cell in move_range_cells:
		cell.modulate = Color(1.0, 1.0, 1.0, 0.0)
		cell.scale = Vector2.ONE
		cell.visible = false


func _hide_attack_range_overlay() -> void:
	_clear_range_overlay_tweens()
	for cell in move_range_cells:
		cell.modulate = Color(1.0, 1.0, 1.0, 0.0)
		cell.scale = Vector2.ONE
		cell.visible = false


func _hide_unique_skill_range_overlay() -> void:
	_clear_range_overlay_tweens()
	for cell in move_range_cells:
		cell.modulate = Color(1.0, 1.0, 1.0, 0.0)
		cell.scale = Vector2.ONE
		cell.visible = false


func _hide_strategy_range_overlay() -> void:
	_clear_range_overlay_tweens()
	for cell in move_range_cells:
		cell.modulate = Color(1.0, 1.0, 1.0, 0.0)
		cell.scale = Vector2.ONE
		cell.visible = false


func _clear_range_overlay_tweens() -> void:
	for tween in range_overlay_tweens:
		if tween != null:
			tween.kill()
	range_overlay_tweens.clear()


func _get_cells_wave_order(cells: Array[Vector2i], origin_cell: Vector2i, max_distance: int) -> Array[Vector2i]:
	var ordered_cells: Array[Vector2i] = []
	for distance in range(maxi(0, max_distance) + 1):
		for cell in cells:
			if battle_grid_controller != null and battle_grid_controller.get_distance(origin_cell, cell) == distance:
				ordered_cells.append(cell)
	return ordered_cells


func _show_range_overlay_cell(rect: ColorRect, cell: Vector2i, cell_size: Vector2, fill_color: Color, origin_cell: Vector2i, should_animate := true, marker_scale := 1.0, outline_color := Color.TRANSPARENT, highlight_color := Color.TRANSPARENT) -> void:
	if rect == null or battle_grid_controller == null:
		return
	var inset := Vector2(
		cell_size.x * RANGE_OVERLAY_CELL_INSET_RATIO,
		cell_size.y * RANGE_OVERLAY_CELL_INSET_RATIO
	)
	var visual_size := (cell_size - (inset * 2.0)) * marker_scale
	var world_pos := battle_grid_controller.grid_to_world(cell)
	rect.position = world_pos - (visual_size * 0.5)
	rect.size = visual_size
	rect.pivot_offset = visual_size * 0.5
	rect.color = Color.TRANSPARENT
	if rect.has_method("set_tile_style"):
		rect.call("set_tile_style", fill_color, outline_color, highlight_color)
	else:
		rect.color = fill_color
	rect.visible = true
	if not should_animate:
		rect.modulate = Color(1.0, 1.0, 1.0, 1.0)
		rect.scale = Vector2.ONE
		return

	var wave_distance := 0
	if battle_grid_controller != null:
		wave_distance = battle_grid_controller.get_distance(origin_cell, cell)
	rect.modulate = Color(1.0, 1.0, 1.0, 0.0)
	rect.scale = _get_range_overlay_start_scale(wave_distance)
	var delay := float(wave_distance) * RANGE_OVERLAY_CELL_STAGGER
	var tween := create_tween()
	range_overlay_tweens.append(tween)
	tween.tween_interval(delay)
	tween.set_parallel(true)
	tween.tween_property(rect, "modulate:a", 1.0, RANGE_OVERLAY_CELL_APPEAR_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(rect, "scale", _get_range_overlay_pop_scale(wave_distance), RANGE_OVERLAY_CELL_APPEAR_DURATION).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.chain()
	tween.tween_property(rect, "scale", Vector2.ONE, RANGE_OVERLAY_CELL_SETTLE_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _get_range_overlay_start_scale(wave_distance: int) -> Vector2:
	var scale_value := clampf(
		RANGE_OVERLAY_CELL_BASE_START_SCALE + (float(maxi(wave_distance - 1, 0)) * RANGE_OVERLAY_CELL_DISTANCE_SCALE_STEP),
		0.74,
		0.82
	)
	return Vector2(scale_value, scale_value)


func _get_range_overlay_pop_scale(wave_distance: int) -> Vector2:
	var scale_value := clampf(
		RANGE_OVERLAY_CELL_BASE_POP_SCALE - (float(maxi(wave_distance - 1, 0)) * RANGE_OVERLAY_CELL_DISTANCE_SCALE_STEP * 1.5),
		1.05,
		1.14
	)
	return Vector2(scale_value, scale_value)


func _show_unique_skill_range_overlay(caster_state: BattleUnitState, skill_data: Dictionary) -> void:
	_hide_unique_skill_range_overlay()
	if caster_state == null or battle_grid_controller == null:
		return
	var cell_size := battle_grid_controller.get_cell_size()
	if cell_size.x <= 0.0 or cell_size.y <= 0.0:
		return
	var target_cells: Array[Vector2i] = []
	for target_state in _get_unique_skill_valid_targets(caster_state, skill_data):
		target_cells.append(target_state.grid_cell)
	var range_cells := _get_unique_skill_range_cells(caster_state, skill_data)
	var display_cells: Array[Vector2i] = []
	for range_cell in _get_unique_skill_range_cells(caster_state, skill_data):
		if not display_cells.has(range_cell):
			display_cells.append(range_cell)
	display_cells = _get_cells_wave_order(display_cells, caster_state.grid_cell, _get_unique_skill_range(caster_state, skill_data))

	var index := 0
	for cell in display_cells:
		if index >= move_range_cells.size():
			break
		var world_pos := battle_grid_controller.grid_to_world(cell)
		if not _is_move_range_overlay_rect_inside_visual_board(world_pos, cell_size):
			continue

		var rect := move_range_cells[index]
		_show_range_overlay_cell(rect, cell, cell_size, UNIQUE_SKILL_RANGE_OVERLAY_COLOR, caster_state.grid_cell, true, 1.0, UNIQUE_SKILL_RANGE_OVERLAY_OUTLINE_COLOR, UNIQUE_SKILL_RANGE_OVERLAY_HIGHLIGHT_COLOR)
		index += 1
	for target_cell in target_cells:
		if index >= move_range_cells.size():
			break
		if not range_cells.has(target_cell):
			continue
		var marker_world_pos := battle_grid_controller.grid_to_world(target_cell)
		if not _is_move_range_overlay_rect_inside_visual_board(marker_world_pos, cell_size):
			continue
		var marker_rect := move_range_cells[index]
		_show_range_overlay_cell(marker_rect, target_cell, cell_size, UNIQUE_SKILL_TARGET_OVERLAY_COLOR, caster_state.grid_cell, true, UNIQUE_SKILL_TARGET_MARKER_SCALE, UNIQUE_SKILL_TARGET_OVERLAY_OUTLINE_COLOR, UNIQUE_SKILL_TARGET_OVERLAY_HIGHLIGHT_COLOR)
		index += 1


func _show_strategy_range_overlay(caster_state: BattleUnitState) -> void:
	_hide_strategy_range_overlay()
	if caster_state == null or battle_grid_controller == null:
		return
	var cell_size := battle_grid_controller.get_cell_size()
	if cell_size.x <= 0.0 or cell_size.y <= 0.0:
		return

	var target_cells: Array[Vector2i] = []
	for target_state in _get_strategy_targets(caster_state):
		target_cells.append(target_state.grid_cell)
	var range_cells: Array[Vector2i] = []
	for range_cell in battle_grid_controller.get_tiles_in_range(caster_state.grid_cell, _get_strategy_range(caster_state)):
		if battle_grid_controller.is_in_bounds(range_cell):
			range_cells.append(range_cell)
	range_cells = _get_cells_wave_order(range_cells, caster_state.grid_cell, _get_strategy_range(caster_state))

	var index := 0
	for cell in range_cells:
		if index >= move_range_cells.size():
			break
		var world_pos := battle_grid_controller.grid_to_world(cell)
		if not _is_move_range_overlay_rect_inside_visual_board(world_pos, cell_size):
			continue

		var rect := move_range_cells[index]
		_show_range_overlay_cell(rect, cell, cell_size, STRATEGY_RANGE_OVERLAY_COLOR, caster_state.grid_cell, true, 1.0, STRATEGY_RANGE_OVERLAY_OUTLINE_COLOR, STRATEGY_RANGE_OVERLAY_HIGHLIGHT_COLOR)
		index += 1

	for target_cell in target_cells:
		if index >= move_range_cells.size():
			break
		if not range_cells.has(target_cell):
			continue
		var marker_world_pos := battle_grid_controller.grid_to_world(target_cell)
		if not _is_move_range_overlay_rect_inside_visual_board(marker_world_pos, cell_size):
			continue
		var marker_rect := move_range_cells[index]
		_show_range_overlay_cell(marker_rect, target_cell, cell_size, STRATEGY_TARGET_OVERLAY_COLOR, caster_state.grid_cell, true, STRATEGY_TARGET_MARKER_SCALE, STRATEGY_TARGET_OVERLAY_OUTLINE_COLOR, STRATEGY_TARGET_OVERLAY_HIGHLIGHT_COLOR)
		index += 1


func _show_attack_range_overlay_for_active_unit() -> void:
	_hide_attack_range_overlay()
	if active_unit_state == null:
		return
	if active_unit_side != "ally":
		return
	if battle_grid_controller == null:
		return

	var origin_cell := active_unit_state.grid_cell
	var attack_range := active_unit_state.attack_range
	var range_cells: Array[Vector2i] = battle_grid_controller.get_tiles_in_range(origin_cell, attack_range)
	range_cells = _get_cells_wave_order(range_cells, origin_cell, attack_range)
	var cell_size := battle_grid_controller.get_cell_size()
	if cell_size.x <= 0.0 or cell_size.y <= 0.0:
		return

	var index := 0
	for cell in range_cells:
		if index >= move_range_cells.size():
			break
		if cell == origin_cell:
			continue
		if not battle_grid_controller.is_in_bounds(cell):
			continue

		var world_pos := battle_grid_controller.grid_to_world(cell)
		if not _is_move_range_overlay_rect_inside_visual_board(world_pos, cell_size):
			continue

		var rect := move_range_cells[index]
		_show_range_overlay_cell(rect, cell, cell_size, ATTACK_RANGE_OVERLAY_COLOR, origin_cell, true, 1.0, ATTACK_RANGE_OVERLAY_OUTLINE_COLOR, ATTACK_RANGE_OVERLAY_HIGHLIGHT_COLOR)
		index += 1


func _show_move_range_overlay_for_active_unit() -> void:
	_hide_move_range_overlay()
	if active_unit_state == null:
		return
	if active_unit_side != "ally":
		return
	if _has_ally_unit_acted(active_unit_state):
		return
	if active_unit_state.has_moved:
		return
	if battle_grid_controller == null:
		return

	var origin_cell := active_unit_state.grid_cell
	var move_range := active_unit_state.move_range
	var valid_cells: Array[Vector2i] = battle_grid_controller.get_tiles_in_range(origin_cell, move_range)
	valid_cells = _get_cells_wave_order(valid_cells, origin_cell, move_range)
	var cell_size := battle_grid_controller.get_cell_size()
	if cell_size.x <= 0.0 or cell_size.y <= 0.0:
		return

	var index := 0
	for cell in valid_cells:
		if index >= move_range_cells.size():
			break
		if not battle_grid_controller.is_in_bounds(cell):
			continue
		if not is_valid_move_target(cell):
			continue

		var world_pos := battle_grid_controller.grid_to_world(cell)
		if not _is_move_range_overlay_rect_inside_visual_board(world_pos, cell_size):
			continue

		var rect := move_range_cells[index]
		_show_range_overlay_cell(rect, cell, cell_size, MOVE_RANGE_OVERLAY_COLOR, origin_cell, true, 1.0, MOVE_RANGE_OVERLAY_OUTLINE_COLOR, MOVE_RANGE_OVERLAY_HIGHLIGHT_COLOR)
		index += 1


func _is_move_range_overlay_rect_inside_visual_board(world_pos: Vector2, cell_size: Vector2) -> bool:
	if battle_grid_controller == null:
		return false

	var visual_top_left := battle_grid_controller.get_board_top_left() + MOVE_RANGE_OVERLAY_VISUAL_INSET
	var visual_bottom_right := battle_grid_controller.get_board_bottom_right() - MOVE_RANGE_OVERLAY_VISUAL_INSET
	var rect_top_left := world_pos - (cell_size * 0.5)
	var rect_bottom_right := world_pos + (cell_size * 0.5)
	return (
		rect_top_left.x >= visual_top_left.x
		and rect_bottom_right.x <= visual_bottom_right.x
		and rect_top_left.y >= visual_top_left.y
		and rect_bottom_right.y <= visual_bottom_right.y
	)


func _format_troop_label(value: int) -> String:
	return "%d / %d" % [value, value]


func _update_troop_labels() -> void:
	_update_all_unit_visuals_from_state()


func _create_demo_unit_states() -> void:
	ally_unit_state = BattleUnitState.create({
		"unit_id": "yi_sunsin",
		"display_name": "이순신",
		"side": "ally",
		"slot_id": "ally_main",
		"unit_type": UNIT_TYPE_ARCHER,
		"visual_key": "korea_archer",
		"hero_name": "이순신",
		"nation": "korea",
		"portrait_key": "yi_sunsin",
		"domain": "land",
		"footprint": "1x1",
		"move_fx_profile": "dust",
		"attack_fx_profile": "arrow",
		"click_area_profile": "standard_1x1",
		"visual_scale_profile": "standard_256",
		"current_hp": int(ALLY_DEMO_HP),
		"max_hp": int(ALLY_DEMO_HP),
		"current_troops": int(ALLY_DEMO_HP),
		"max_troops": int(ALLY_DEMO_HP),
		"attack": 30,
		"defense": 12,
		"intelligence": 92,
		"move_range": 3,
		"attack_range": 3,
		"grid_cell": Vector2i.ZERO,
		"facing": FACING_RIGHT,
	})
	ally_support_unit_state = BattleUnitState.create({
		"unit_id": "jeong_dojeon",
		"display_name": "정도전",
		"side": "ally",
		"slot_id": "ally_support",
		"unit_type": UNIT_TYPE_GUNNER,
		"visual_key": "korea_gunner",
		"hero_name": "정도전",
		"nation": "korea",
		"portrait_key": "jeong_dojeon",
		"domain": "land",
		"footprint": "1x1",
		"move_fx_profile": "dust",
		"attack_fx_profile": "gun",
		"click_area_profile": "standard_1x1",
		"visual_scale_profile": "standard_256",
		"current_hp": 60,
		"max_hp": 60,
		"current_troops": 60,
		"max_troops": 60,
		"attack": 16,
		"defense": 12,
		"intelligence": 96,
		"move_range": 3,
		"attack_range": 1,
		"grid_cell": Vector2i.ZERO,
		"facing": FACING_RIGHT,
	})
	ally_main_03_unit_state = BattleUnitState.create({
		"unit_id": "gwon_yul",
		"display_name": "권율",
		"side": "ally",
		"slot_id": "ally_main_03",
		"unit_type": UNIT_TYPE_INFANTRY,
		"visual_key": "korea_infantry",
		"hero_name": "권율",
		"nation": "korea",
		"portrait_key": "gwon_yul",
		"domain": "land",
		"footprint": "1x1",
		"move_fx_profile": "dust",
		"attack_fx_profile": "slash",
		"click_area_profile": "standard_1x1",
		"visual_scale_profile": "standard_256",
		"current_hp": 72,
		"max_hp": 72,
		"current_troops": 72,
		"max_troops": 72,
		"attack": 22,
		"defense": 13,
		"intelligence": 84,
		"move_range": 3,
		"attack_range": 1,
		"grid_cell": Vector2i.ZERO,
		"facing": FACING_RIGHT,
	})
	ally_reinforce_01_unit_state = BattleUnitState.create({
		"unit_id": "ally_reinforce_01_demo",
		"display_name": "지원군 선봉",
		"side": "ally",
		"slot_id": "ally_reinforce_01",
		"unit_type": UNIT_TYPE_ARCHER,
		"visual_key": "korea_archer",
		"hero_name": "지원군 선봉",
		"nation": "korea",
		"portrait_key": "yi_sunsin",
		"domain": "land",
		"footprint": "1x1",
		"move_fx_profile": "dust",
		"attack_fx_profile": "arrow",
		"click_area_profile": "standard_1x1",
		"visual_scale_profile": "standard_256",
		"current_hp": 64,
		"max_hp": 64,
		"current_troops": 64,
		"max_troops": 64,
		"attack": 19,
		"defense": 11,
		"intelligence": 78,
		"move_range": 3,
		"attack_range": 3,
		"grid_cell": Vector2i.ZERO,
		"facing": FACING_RIGHT,
	})
	ally_reinforce_02_unit_state = BattleUnitState.create({
		"unit_id": "ally_reinforce_02_test_unit",
		"display_name": "도성 지원군",
		"side": "ally",
		"slot_id": "ally_reinforce_02",
		"unit_type": UNIT_TYPE_GUNNER,
		"visual_key": "korea_gunner",
		"hero_name": "지원 파견장",
		"nation": "korea",
		"portrait_key": "jeong_dojeon",
		"domain": "land",
		"footprint": "1x1",
		"move_fx_profile": "dust",
		"attack_fx_profile": "shot",
		"click_area_profile": "standard_1x1",
		"visual_scale_profile": "standard_256",
		"current_hp": 62,
		"max_hp": 62,
		"current_troops": 62,
		"max_troops": 62,
		"attack": 25,
		"defense": 12,
		"intelligence": 88,
		"move_range": 3,
		"attack_range": 2,
		"grid_cell": Vector2i.ZERO,
		"facing": FACING_RIGHT,
	})
	enemy_unit_state = BattleUnitState.create({
		"unit_id": "guan_yu",
		"display_name": "관우",
		"side": "enemy",
		"slot_id": "enemy_main",
		"unit_type": UNIT_TYPE_CAVALRY,
		"visual_key": "china_cavalry",
		"hero_name": "관우",
		"nation": "china",
		"portrait_key": "guan_yu",
		"domain": "land",
		"footprint": "1x1",
		"move_fx_profile": "dust",
		"attack_fx_profile": "slash",
		"click_area_profile": "standard_1x1",
		"visual_scale_profile": "standard_256",
		"current_hp": int(ENEMY_DEMO_HP),
		"max_hp": int(ENEMY_DEMO_HP),
		"current_troops": int(ENEMY_DEMO_HP),
		"max_troops": int(ENEMY_DEMO_HP),
		"attack": 34,
		"defense": 16,
		"intelligence": 76,
		"move_range": 3,
		"attack_range": 1,
		"grid_cell": Vector2i.ZERO,
		"facing": FACING_LEFT,
	})
	enemy_support_unit_state = BattleUnitState.create({
		"unit_id": "zhang_fei",
		"display_name": "장비",
		"side": "enemy",
		"slot_id": "enemy_support",
		"unit_type": UNIT_TYPE_INFANTRY,
		"visual_key": "china_infantry",
		"hero_name": "장비",
		"nation": "china",
		"portrait_key": "zhang_fei",
		"domain": "land",
		"footprint": "1x1",
		"move_fx_profile": "dust",
		"attack_fx_profile": "slash",
		"click_area_profile": "standard_1x1",
		"visual_scale_profile": "standard_256",
		"current_hp": 80,
		"max_hp": 80,
		"current_troops": 80,
		"max_troops": 80,
		"attack": 24,
		"defense": 14,
		"intelligence": 55,
		"move_range": 3,
		"attack_range": 1,
		"grid_cell": Vector2i.ZERO,
		"facing": FACING_LEFT,
	})
	enemy_main_03_unit_state = BattleUnitState.create({
		"unit_id": "xiahou_dun",
		"display_name": "하후돈",
		"side": "enemy",
		"slot_id": "enemy_main_03",
		"unit_type": UNIT_TYPE_INFANTRY,
		"visual_key": "china_infantry",
		"hero_name": "하후돈",
		"nation": "china",
		"portrait_key": "xiahou_dun",
		"domain": "land",
		"footprint": "1x1",
		"move_fx_profile": "dust",
		"attack_fx_profile": "slash",
		"click_area_profile": "standard_1x1",
		"visual_scale_profile": "standard_256",
		"current_hp": 76,
		"max_hp": 76,
		"current_troops": 76,
		"max_troops": 76,
		"attack": 26,
		"defense": 15,
		"intelligence": 72,
		"move_range": 3,
		"attack_range": 1,
		"grid_cell": Vector2i.ZERO,
		"facing": FACING_LEFT,
	})
	enemy_reinforce_01_unit_state = BattleUnitState.create({
		"unit_id": "enemy_reinforce_01_demo",
		"display_name": "지원군 선봉",
		"side": "enemy",
		"slot_id": "enemy_reinforce_01",
		"unit_type": UNIT_TYPE_ARCHER,
		"visual_key": "china_archer",
		"hero_name": "지원군 선봉",
		"nation": "china",
		"portrait_key": "guan_yu",
		"domain": "land",
		"footprint": "1x1",
		"move_fx_profile": "dust",
		"attack_fx_profile": "arrow",
		"click_area_profile": "standard_1x1",
		"visual_scale_profile": "standard_256",
		"current_hp": 68,
		"max_hp": 68,
		"current_troops": 68,
		"max_troops": 68,
		"attack": 20,
		"defense": 12,
		"intelligence": 86,
		"move_range": 3,
		"attack_range": 3,
		"grid_cell": Vector2i.ZERO,
		"facing": FACING_LEFT,
	})
	enemy_reinforce_02_unit_state = BattleUnitState.create({
		"unit_id": "enemy_reinforce_02_test_unit",
		"display_name": "공세 지원군",
		"side": "enemy",
		"slot_id": "enemy_reinforce_02",
		"unit_type": UNIT_TYPE_GUNNER,
		"visual_key": "china_gunner",
		"hero_name": "추가 파병장",
		"nation": "china",
		"portrait_key": "zhang_fei",
		"domain": "land",
		"footprint": "1x1",
		"move_fx_profile": "dust",
		"attack_fx_profile": "shot",
		"click_area_profile": "standard_1x1",
		"visual_scale_profile": "standard_256",
		"current_hp": 66,
		"max_hp": 66,
		"current_troops": 66,
		"max_troops": 66,
		"attack": 25,
		"defense": 13,
		"intelligence": 98,
		"move_range": 3,
		"attack_range": 2,
		"grid_cell": Vector2i.ZERO,
		"facing": FACING_LEFT,
	})


func _sync_unit_state_cells_from_markers() -> void:
	if ally_unit_state != null:
		ally_unit_state.set_grid_cell(_get_cell_from_world(ally_unit_marker.position))
	if ally_support_unit_state != null and ally_support_unit_marker != null:
		ally_support_unit_state.set_grid_cell(_get_cell_from_world(ally_support_unit_marker.position))
	if ally_main_03_unit_state != null and ally_main_03_unit_marker != null:
		ally_main_03_unit_state.set_grid_cell(_get_cell_from_world(ally_main_03_unit_marker.position))
	if ally_reinforce_01_unit_state != null and ally_reinforce_01_unit_marker != null:
		ally_reinforce_01_unit_state.set_grid_cell(_get_cell_from_world(ally_reinforce_01_unit_marker.position))
	if ally_reinforce_02_unit_state != null and ally_reinforce_02_unit_marker != null:
		ally_reinforce_02_unit_state.set_grid_cell(_get_cell_from_world(ally_reinforce_02_unit_marker.position))
	if enemy_unit_state != null:
		enemy_unit_state.set_grid_cell(_get_cell_from_world(enemy_unit_marker.position))
	if enemy_support_unit_state != null and enemy_support_unit_marker != null:
		enemy_support_unit_state.set_grid_cell(_get_cell_from_world(enemy_support_unit_marker.position))
	if enemy_main_03_unit_state != null and enemy_main_03_unit_marker != null:
		enemy_main_03_unit_state.set_grid_cell(_get_cell_from_world(enemy_main_03_unit_marker.position))
	if enemy_reinforce_01_unit_state != null and enemy_reinforce_01_unit_marker != null:
		enemy_reinforce_01_unit_state.set_grid_cell(_get_cell_from_world(enemy_reinforce_01_unit_marker.position))
	if enemy_reinforce_02_unit_state != null and enemy_reinforce_02_unit_marker != null:
		enemy_reinforce_02_unit_state.set_grid_cell(_get_cell_from_world(enemy_reinforce_02_unit_marker.position))


func _apply_melee_adjacent_qa_preset() -> void:
	if not MELEE_ADJACENT_QA_MODE:
		return
	if battle_grid_controller == null:
		return
	if ally_unit_state == null or enemy_unit_state == null:
		return
	if enemy_unit_marker == null or enemy_portrait_marker == null:
		return

	var target_cell := ally_unit_state.grid_cell + MELEE_QA_ENEMY_OFFSET
	if not battle_grid_controller.is_in_bounds(target_cell):
		print("MELEE QA skipped: target out of bounds ", target_cell)
		return

	var portrait_offset := enemy_portrait_marker.position - enemy_unit_marker.position
	enemy_unit_state.set_grid_cell(target_cell)
	enemy_unit_marker.position = battle_grid_controller.grid_to_world(target_cell)
	enemy_portrait_marker.position = enemy_unit_marker.position + portrait_offset
	_refresh_initial_unit_facing()
	_reset_unit_group_positions()

	print("MELEE QA enemy offset: ", MELEE_QA_ENEMY_OFFSET)
	print("ALLY GRID: ", ally_unit_state.grid_cell, " ENEMY GRID: ", enemy_unit_state.grid_cell)
	print("MELEE DIST: ", get_unit_grid_distance(ally_unit_state, enemy_unit_state))


func _get_ally_visual_anchor_from_position(unit_position: Vector2) -> Vector2:
	return unit_position + ALLY_VISUAL_ANCHOR_OFFSET


func _get_enemy_visual_anchor_from_position(unit_position: Vector2) -> Vector2:
	return unit_position + ENEMY_VISUAL_ANCHOR_OFFSET


func _get_ally_visual_anchor_position() -> Vector2:
	return _get_ally_visual_anchor_from_position(current_ally_unit_position)


func _get_enemy_visual_anchor_position() -> Vector2:
	return _get_enemy_visual_anchor_from_position(enemy_unit_marker.position)


func _get_ally_support_visual_anchor_position() -> Vector2:
	if ally_support_unit_marker == null:
		return Vector2.ZERO
	return _get_ally_visual_anchor_from_position(ally_support_unit_marker.position)


func _get_enemy_support_visual_anchor_position() -> Vector2:
	if enemy_support_unit_marker == null:
		return Vector2.ZERO
	return _get_enemy_visual_anchor_from_position(enemy_support_unit_marker.position)


func _capture_template_slot_offset(template_root: Node2D, slot_name: String, fallback_position: Vector2, visual_anchor: Vector2) -> Vector2:
	if template_root != null:
		var slot := template_root.get_node_or_null(slot_name) as Marker2D
		if slot != null:
			return slot.global_position - visual_anchor
	return fallback_position - visual_anchor


func _get_canvas_item_world_position(node: CanvasItem) -> Vector2:
	if node == null:
		return Vector2.ZERO
	if node is Node2D:
		return (node as Node2D).global_position
	if node is Control:
		return (node as Control).global_position
	return node.position


func _set_canvas_item_world_position(node: CanvasItem, world_position: Vector2) -> void:
	if node == null:
		return
	if node is Node2D:
		(node as Node2D).global_position = world_position
	elif node is Control:
		(node as Control).global_position = world_position
	else:
		node.position = world_position


func _set_marker_world_position(marker: Marker2D, world_position: Vector2) -> void:
	if marker != null:
		marker.global_position = world_position


func _get_slot_side_for_scene_visual_slot_id(slot_id: String) -> String:
	if slot_id.begins_with("enemy_"):
		return "enemy"
	return "ally"


func _get_unit_marker_for_scene_visual_slot_id(slot_id: String) -> Marker2D:
	match slot_id:
		"ally_main":
			return ally_unit_marker
		"ally_support":
			return ally_support_unit_marker
		"ally_main_03":
			return ally_main_03_unit_marker
		"ally_reinforce_01":
			return ally_reinforce_01_unit_marker
		"ally_reinforce_02":
			return ally_reinforce_02_unit_marker
		"enemy_main":
			return enemy_unit_marker
		"enemy_support":
			return enemy_support_unit_marker
		"enemy_main_03":
			return enemy_main_03_unit_marker
		"enemy_reinforce_01":
			return enemy_reinforce_01_unit_marker
		"enemy_reinforce_02":
			return enemy_reinforce_02_unit_marker
		_:
			return null


func _get_portrait_marker_for_scene_visual_slot_id(slot_id: String) -> Marker2D:
	match slot_id:
		"ally_main":
			return ally_portrait_marker
		"ally_support":
			return ally_support_portrait_marker
		"ally_main_03":
			return ally_main_03_portrait_marker
		"ally_reinforce_01":
			return ally_reinforce_01_portrait_marker
		"ally_reinforce_02":
			return ally_reinforce_02_portrait_marker
		"enemy_main":
			return enemy_portrait_marker
		"enemy_support":
			return enemy_support_portrait_marker
		"enemy_main_03":
			return enemy_main_03_portrait_marker
		"enemy_reinforce_01":
			return enemy_reinforce_01_portrait_marker
		"enemy_reinforce_02":
			return enemy_reinforce_02_portrait_marker
		_:
			return null


func _get_visual_root_for_scene_visual_slot_id(slot_id: String) -> Node2D:
	var slot_visuals := _get_visual_slots_dictionary_fallback_for_slot_id(slot_id)
	return slot_visuals.get("root") as Node2D


func _get_portrait_for_scene_visual_slot_id(slot_id: String) -> CanvasItem:
	var slot_visuals := _get_visual_slots_dictionary_fallback_for_slot_id(slot_id)
	return slot_visuals.get("portrait") as CanvasItem


func _get_deployment_marker_base_world_position(slot_id: String, unit_marker: Marker2D) -> Vector2:
	if unit_marker == null:
		return Vector2.ZERO
	if not deployment_marker_base_world_positions_by_slot_id.has(slot_id):
		deployment_marker_base_world_positions_by_slot_id[slot_id] = unit_marker.global_position
	var marker_world_position: Vector2 = deployment_marker_base_world_positions_by_slot_id.get(slot_id, unit_marker.global_position)
	return marker_world_position


func _get_fallback_visual_anchor_for_deployment_marker(slot_id: String, unit_marker: Marker2D, side: String) -> Vector2:
	if unit_marker == null:
		return Vector2.ZERO
	var marker_world_position := _get_deployment_marker_base_world_position(slot_id, unit_marker)
	if side == "enemy":
		return _get_enemy_visual_anchor_from_position(marker_world_position)
	return _get_ally_visual_anchor_from_position(marker_world_position)


func _get_scene_authored_visual_anchor(root: Node2D, fallback_anchor: Vector2) -> Vector2:
	if root == null:
		return fallback_anchor
	return fallback_anchor + root.global_position


func _get_scene_visual_anchor_for_slot_id(slot_id: String) -> Vector2:
	var unit_marker := _get_unit_marker_for_scene_visual_slot_id(slot_id)
	if unit_marker == null:
		return Vector2.ZERO
	var side := _get_slot_side_for_scene_visual_slot_id(slot_id)
	var fallback_anchor := _get_fallback_visual_anchor_for_deployment_marker(slot_id, unit_marker, side)
	var root := _get_visual_root_for_scene_visual_slot_id(slot_id)
	return _get_scene_authored_visual_anchor(root, fallback_anchor)


func _sync_deployment_markers_from_scene_visual_anchors() -> void:
	for slot_id in VISUAL_SLOT_CACHE_IDS:
		var unit_marker := _get_unit_marker_for_scene_visual_slot_id(slot_id)
		if unit_marker == null:
			continue
		var side := _get_slot_side_for_scene_visual_slot_id(slot_id)
		var visual_anchor := _get_scene_visual_anchor_for_slot_id(slot_id)
		if side == "enemy":
			_set_marker_world_position(unit_marker, visual_anchor - ENEMY_VISUAL_ANCHOR_OFFSET)
		else:
			_set_marker_world_position(unit_marker, visual_anchor - ALLY_VISUAL_ANCHOR_OFFSET)
		var portrait_marker := _get_portrait_marker_for_scene_visual_slot_id(slot_id)
		var portrait := _get_portrait_for_scene_visual_slot_id(slot_id)
		if portrait_marker != null and portrait != null:
			_set_marker_world_position(portrait_marker, _get_canvas_item_world_position(portrait))
	if ally_unit_marker != null:
		current_ally_unit_position = ally_unit_marker.position


func _capture_portrait_template_offsets(template_root: Node2D, fallback_offset: Vector2, visual_anchor: Vector2) -> Dictionary:
	return {
		FACING_LEFT: _capture_template_slot_offset(
			template_root,
			"PortraitLeftSlot",
			visual_anchor + _get_facing_aware_portrait_offset(fallback_offset, FACING_LEFT),
			visual_anchor
		),
		FACING_RIGHT: _capture_template_slot_offset(
			template_root,
			"PortraitRightSlot",
			visual_anchor + _get_facing_aware_portrait_offset(fallback_offset, FACING_RIGHT),
			visual_anchor
		),
		FACING_UP: _capture_template_slot_offset(
			template_root,
			"PortraitUpSlot",
			visual_anchor + fallback_offset,
			visual_anchor
		),
		FACING_DOWN: _capture_template_slot_offset(
			template_root,
			"PortraitDownSlot",
			visual_anchor + fallback_offset,
			visual_anchor
		),
	}


func _get_portrait_template_offset(layout_offsets_by_facing: Dictionary, fallback_offset: Vector2, facing: String) -> Vector2:
	var normalized_facing := _normalize_facing(facing)
	if layout_offsets_by_facing.has(normalized_facing):
		return layout_offsets_by_facing[normalized_facing]
	return _get_facing_aware_portrait_offset(fallback_offset, normalized_facing)


func _get_ally_portrait_offset_for_facing(layout_offsets_by_facing: Dictionary, fallback_offset: Vector2, facing: String) -> Vector2:
	var normalized_facing := _normalize_facing(facing)
	if normalized_facing == FACING_UP or normalized_facing == FACING_DOWN:
		return fallback_offset
	return _get_portrait_template_offset(layout_offsets_by_facing, fallback_offset, normalized_facing)


func _get_enemy_portrait_offset_for_facing(layout_offsets_by_facing: Dictionary, fallback_offset: Vector2, facing: String) -> Vector2:
	var normalized_facing := _normalize_facing(facing)
	if normalized_facing == FACING_UP or normalized_facing == FACING_DOWN:
		return fallback_offset
	return _get_portrait_template_offset(layout_offsets_by_facing, fallback_offset, normalized_facing)


func _normalize_unit_type(unit_type: String) -> String:
	match unit_type:
		UNIT_TYPE_ARCHER, UNIT_TYPE_GUNNER, UNIT_TYPE_CAVALRY:
			return unit_type
		_:
			return UNIT_TYPE_INFANTRY


func _get_visual_template_for_slot(slot_key: String, unit_type: String = UNIT_TYPE_INFANTRY) -> Node2D:
	var slot_map: Dictionary = UNIT_VISUAL_TEMPLATE_NODE_PATHS.get(slot_key, {})
	var normalized_unit_type := _normalize_unit_type(unit_type)
	var node_path := String(slot_map.get(normalized_unit_type, slot_map.get(UNIT_TYPE_INFANTRY, "")))
	if node_path == "":
		return null
	return get_node_or_null(node_path) as Node2D


func _get_visual_template_for_unit(unit_state: BattleUnitState) -> Node2D:
	if unit_state == null:
		return null
	var unit_type := _normalize_unit_type(unit_state.unit_type)
	if unit_state.slot_id == "ally_support" or unit_state.slot_id == "ally_main_02" or unit_state == ally_support_unit_state:
		return _get_visual_template_for_slot("ally_support", unit_type)
	if unit_state.slot_id == "enemy_main" or unit_state.slot_id == "enemy_main_01" or unit_state.slot_id == "enemy_main_03" or unit_state.slot_id == "enemy_reinforce_01" or unit_state.slot_id == "enemy_reinforce_02" or unit_state == enemy_unit_state or unit_state == enemy_main_03_unit_state or unit_state == enemy_reinforce_01_unit_state or unit_state == enemy_reinforce_02_unit_state:
		return _get_visual_template_for_slot("enemy_main", unit_type)
	if unit_state.slot_id == "enemy_support" or unit_state.slot_id == "enemy_main_02" or unit_state == enemy_support_unit_state:
		return _get_visual_template_for_slot("enemy_support", unit_type)
	return _get_visual_template_for_slot("ally_main", unit_type)


func _get_visual_key_for_unit(unit_state: BattleUnitState) -> String:
	if unit_state == null:
		return ""
	if unit_state.visual_key != "":
		return unit_state.visual_key
	var side_prefix := "ally"
	if unit_state.side == "enemy":
		side_prefix = "enemy"
	return "%s_%s" % [side_prefix, _normalize_unit_type(unit_state.unit_type)]


func _get_visual_fallback_key_for_unit(unit_state: BattleUnitState) -> String:
	if unit_state == null:
		return "ally_infantry"
	var side_prefix := "ally"
	if unit_state.side == "enemy":
		side_prefix = "enemy"
	return "%s_%s" % [side_prefix, _normalize_unit_type(unit_state.unit_type)]


func _get_visual_token_paths_for_unit(unit_state: BattleUnitState) -> Dictionary:
	if unit_state == null:
		return {}
	var primary_paths: Dictionary = UNIT_VISUAL_TOKEN_PATHS.get(_get_visual_key_for_unit(unit_state), {})
	if not primary_paths.is_empty():
		return primary_paths
	var fallback_paths: Dictionary = UNIT_VISUAL_TOKEN_PATHS.get(_get_visual_fallback_key_for_unit(unit_state), {})
	if not fallback_paths.is_empty():
		return fallback_paths
	var result: Dictionary = {}
	if unit_state.side == "enemy":
		result = UNIT_VISUAL_TOKEN_PATHS.get("enemy_infantry", {})
	else:
		result = UNIT_VISUAL_TOKEN_PATHS.get("ally_infantry", {})
	return result


func _try_load_texture_or_null(path: String) -> Texture2D:
	if path == "" or not ResourceLoader.exists(path):
		return null
	return load(path) as Texture2D


func _load_optional_texture(path: String) -> Texture2D:
	return _try_load_texture_or_null(path)


func _get_all_visual_template_roots() -> Array[Node2D]:
	var templates: Array[Node2D] = []
	var seen_paths: Dictionary = {}
	for slot_key in UNIT_VISUAL_TEMPLATE_NODE_PATHS.keys():
		var slot_map: Dictionary = UNIT_VISUAL_TEMPLATE_NODE_PATHS.get(slot_key, {})
		for node_path_variant in slot_map.values():
			var node_path := String(node_path_variant)
			if node_path == "" or seen_paths.has(node_path):
				continue
			seen_paths[node_path] = true
			var template_root := get_node_or_null(node_path) as Node2D
			if template_root != null:
				templates.append(template_root)
	return templates


func _set_visual_template_token_sprite_visibility(should_show: bool) -> void:
	for template_root in _get_all_visual_template_roots():
		var token_sprite := template_root.get_node_or_null("TokenSlot/TokenSprite") as CanvasItem
		if token_sprite != null:
			token_sprite.visible = should_show


func _get_visual_token_texture_for_unit(unit_state: BattleUnitState, facing: String) -> Texture2D:
	var default_side := "ally"
	if unit_state != null and unit_state.side != "":
		default_side = unit_state.side
	var default_texture := _get_default_token_texture_for_facing(facing, default_side)
	if unit_state == null:
		return default_texture
	var visual_paths := _get_visual_token_paths_for_unit(unit_state)
	var normalized_facing := _normalize_facing(facing)
	if normalized_facing == FACING_UP:
		var up_texture := _load_optional_texture(String(visual_paths.get("up", "")))
		if up_texture != null:
			return up_texture
	if normalized_facing == FACING_DOWN:
		var down_texture := _load_optional_texture(String(visual_paths.get("down", "")))
		if down_texture != null:
			return down_texture
	var base_texture := _load_optional_texture(String(visual_paths.get("base", "")))
	if base_texture != null:
		return base_texture
	return default_texture


func _sync_runtime_portrait_markers_to_visuals() -> void:
	if ally_portrait_badge != null:
		current_ally_portrait_position = ally_portrait_badge.position
		if ally_portrait_marker != null:
			ally_portrait_marker.position = current_ally_portrait_position
	if ally_support_portrait_badge != null and ally_support_portrait_marker != null:
		ally_support_portrait_marker.position = ally_support_portrait_badge.position
	if ally_main_03_portrait_badge != null and ally_main_03_portrait_marker != null:
		ally_main_03_portrait_marker.position = ally_main_03_portrait_badge.position
	if ally_reinforce_01_portrait_badge != null and ally_reinforce_01_portrait_marker != null:
		ally_reinforce_01_portrait_marker.position = ally_reinforce_01_portrait_badge.position
	if ally_reinforce_02_portrait_badge != null and ally_reinforce_02_portrait_marker != null:
		ally_reinforce_02_portrait_marker.position = ally_reinforce_02_portrait_badge.position
	if enemy_portrait_badge != null and enemy_portrait_marker != null:
		enemy_portrait_marker.position = enemy_portrait_badge.position
	if enemy_support_portrait_badge != null and enemy_support_portrait_marker != null:
		enemy_support_portrait_marker.position = enemy_support_portrait_badge.position
	if enemy_main_03_portrait_badge != null and enemy_main_03_portrait_marker != null:
		enemy_main_03_portrait_marker.position = enemy_main_03_portrait_badge.position
	if enemy_reinforce_01_portrait_badge != null and enemy_reinforce_01_portrait_marker != null:
		enemy_reinforce_01_portrait_marker.position = enemy_reinforce_01_portrait_badge.position
	if enemy_reinforce_02_portrait_badge != null and enemy_reinforce_02_portrait_marker != null:
		enemy_reinforce_02_portrait_marker.position = enemy_reinforce_02_portrait_badge.position


func _restore_enemy_main_portrait_bindings() -> void:
	if enemy_portrait_badge != null:
		enemy_portrait_badge.texture = ENEMY_MAIN_01_PORTRAIT_TEXTURE
	if enemy_main_03_portrait_badge != null:
		enemy_main_03_portrait_badge.texture = ENEMY_MAIN_03_PORTRAIT_TEXTURE


func _capture_scene_authored_unit_layout_offsets() -> void:
	var ally_main_template := _get_visual_template_for_slot("ally_main", UNIT_TYPE_INFANTRY)
	var ally_support_template := _get_visual_template_for_slot("ally_support", UNIT_TYPE_INFANTRY)
	var enemy_main_template := _get_visual_template_for_slot("enemy_main", UNIT_TYPE_INFANTRY)
	var enemy_support_template := _get_visual_template_for_slot("enemy_support", UNIT_TYPE_INFANTRY)
	if ally_unit_marker != null:
		var ally_anchor := _get_ally_visual_anchor_from_position(ally_unit_marker.position)
		var ally_portrait_fallback := Vector2.ZERO
		if ally_portrait_badge != null:
			ally_portrait_fallback = _get_canvas_item_world_position(ally_portrait_badge) - ally_anchor
		if ally_unit_token != null:
			ally_token_layout_offset = _capture_template_slot_offset(
				ally_main_template,
				"TokenSlot",
				_get_canvas_item_world_position(ally_unit_token),
				ally_anchor
			)
		if move_dust_template != null:
			ally_move_dust_layout_offset = move_dust_template.position
		if ally_unit_shadow != null:
			ally_shadow_layout_offset = _capture_template_slot_offset(
				ally_main_template,
				"ShadowSlot",
				_get_canvas_item_world_position(ally_unit_shadow),
				ally_anchor
			)
		if ally_portrait_badge != null:
			ally_portrait_layout_offset = ally_portrait_fallback
			ally_portrait_layout_offsets_by_facing = _capture_portrait_template_offsets(
				ally_main_template,
				ally_portrait_fallback,
				ally_anchor
			)
		if ally_hp_bar != null:
			ally_hp_bar_layout_offset = _capture_template_slot_offset(
				ally_main_template,
				"HPBarSlot",
				_get_canvas_item_world_position(ally_hp_bar),
				ally_anchor
			)
		if ally_troop_label != null:
			ally_troop_label_layout_offset = _capture_template_slot_offset(
				ally_main_template,
				"TroopLabelSlot",
				_get_canvas_item_world_position(ally_troop_label),
				ally_anchor
			)
		if ally_unit_click_area != null:
			ally_click_area_layout_offset = _capture_template_slot_offset(
				ally_main_template,
				"ClickAreaSlot",
				_get_canvas_item_world_position(ally_unit_click_area),
				ally_anchor
			)
		ally_facing_indicator_layout_offset = _capture_template_slot_offset(
			ally_main_template,
			"FacingIndicatorSlot",
			ally_anchor + ally_facing_indicator_layout_offset,
			ally_anchor
		)

	if enemy_unit_marker != null:
		var enemy_anchor := _get_enemy_visual_anchor_from_position(enemy_unit_marker.position)
		var enemy_portrait_fallback := Vector2.ZERO
		if enemy_portrait_badge != null:
			enemy_portrait_fallback = _get_canvas_item_world_position(enemy_portrait_badge) - enemy_anchor
		if enemy_unit_token != null:
			enemy_token_layout_offset = _capture_template_slot_offset(
				enemy_main_template,
				"TokenSlot",
				_get_canvas_item_world_position(enemy_unit_token),
				enemy_anchor
			)
		if move_dust_template != null:
			enemy_move_dust_layout_offset = move_dust_template.position
		if enemy_unit_shadow != null:
			enemy_shadow_layout_offset = _capture_template_slot_offset(
				enemy_main_template,
				"ShadowSlot",
				_get_canvas_item_world_position(enemy_unit_shadow),
				enemy_anchor
			)
		if enemy_portrait_badge != null:
			enemy_portrait_layout_offset = enemy_portrait_fallback
			enemy_portrait_layout_offsets_by_facing = _capture_portrait_template_offsets(
				enemy_main_template,
				enemy_portrait_fallback,
				enemy_anchor
			)
		if enemy_hp_bar != null:
			enemy_hp_bar_layout_offset = _capture_template_slot_offset(
				enemy_main_template,
				"HPBarSlot",
				_get_canvas_item_world_position(enemy_hp_bar),
				enemy_anchor
			)
		if enemy_troop_label != null:
			enemy_troop_label_layout_offset = _capture_template_slot_offset(
				enemy_main_template,
				"TroopLabelSlot",
				_get_canvas_item_world_position(enemy_troop_label),
				enemy_anchor
			)
		if enemy_unit_click_area != null:
			enemy_click_area_layout_offset = _capture_template_slot_offset(
				enemy_main_template,
				"ClickAreaSlot",
				_get_canvas_item_world_position(enemy_unit_click_area),
				enemy_anchor
			)
		enemy_facing_indicator_layout_offset = _capture_template_slot_offset(
			enemy_main_template,
			"FacingIndicatorSlot",
			enemy_anchor + enemy_facing_indicator_layout_offset,
			enemy_anchor
		)

	if ally_support_unit_marker != null:
		var ally_support_anchor := _get_ally_visual_anchor_from_position(ally_support_unit_marker.position)
		var ally_support_portrait_fallback := Vector2.ZERO
		if ally_support_portrait_badge != null:
			ally_support_portrait_fallback = _get_canvas_item_world_position(ally_support_portrait_badge) - ally_support_anchor
		if ally_support_unit_token != null:
			ally_support_token_layout_offset = _capture_template_slot_offset(
				ally_support_template,
				"TokenSlot",
				_get_canvas_item_world_position(ally_support_unit_token),
				ally_support_anchor
			)
		if move_dust_template != null:
			ally_support_move_dust_layout_offset = move_dust_template.position
		if ally_support_unit_shadow != null:
			ally_support_shadow_layout_offset = _capture_template_slot_offset(
				ally_support_template,
				"ShadowSlot",
				_get_canvas_item_world_position(ally_support_unit_shadow),
				ally_support_anchor
			)
		if ally_support_portrait_badge != null:
			ally_support_portrait_layout_offset = ally_support_portrait_fallback
			ally_support_portrait_layout_offsets_by_facing = _capture_portrait_template_offsets(
				ally_support_template,
				ally_support_portrait_fallback,
				ally_support_anchor
			)
		if ally_support_hp_bar != null:
			ally_support_hp_bar_layout_offset = _capture_template_slot_offset(
				ally_support_template,
				"HPBarSlot",
				_get_canvas_item_world_position(ally_support_hp_bar),
				ally_support_anchor
			)
		if ally_support_troop_label != null:
			ally_support_troop_label_layout_offset = _capture_template_slot_offset(
				ally_support_template,
				"TroopLabelSlot",
				_get_canvas_item_world_position(ally_support_troop_label),
				ally_support_anchor
			)
		if ally_support_unit_click_area != null:
			ally_support_click_area_layout_offset = _capture_template_slot_offset(
				ally_support_template,
				"ClickAreaSlot",
				_get_canvas_item_world_position(ally_support_unit_click_area),
				ally_support_anchor
			)
		ally_support_facing_indicator_layout_offset = _capture_template_slot_offset(
			ally_support_template,
			"FacingIndicatorSlot",
			ally_support_anchor + ally_support_facing_indicator_layout_offset,
			ally_support_anchor
		)

	if enemy_support_unit_marker != null:
		var enemy_support_anchor := _get_enemy_visual_anchor_from_position(enemy_support_unit_marker.position)
		var enemy_support_portrait_fallback := Vector2.ZERO
		if enemy_support_portrait_badge != null:
			enemy_support_portrait_fallback = _get_canvas_item_world_position(enemy_support_portrait_badge) - enemy_support_anchor
		if enemy_support_unit_token != null:
			enemy_support_token_layout_offset = _capture_template_slot_offset(
				enemy_support_template,
				"TokenSlot",
				_get_canvas_item_world_position(enemy_support_unit_token),
				enemy_support_anchor
			)
		if move_dust_template != null:
			enemy_support_move_dust_layout_offset = move_dust_template.position
		if enemy_support_unit_shadow != null:
			enemy_support_shadow_layout_offset = _capture_template_slot_offset(
				enemy_support_template,
				"ShadowSlot",
				_get_canvas_item_world_position(enemy_support_unit_shadow),
				enemy_support_anchor
			)
		if enemy_support_portrait_badge != null:
			enemy_support_portrait_layout_offset = enemy_support_portrait_fallback
			enemy_support_portrait_layout_offsets_by_facing = _capture_portrait_template_offsets(
				enemy_support_template,
				enemy_support_portrait_fallback,
				enemy_support_anchor
			)
		if enemy_support_hp_bar != null:
			enemy_support_hp_bar_layout_offset = _capture_template_slot_offset(
				enemy_support_template,
				"HPBarSlot",
				_get_canvas_item_world_position(enemy_support_hp_bar),
				enemy_support_anchor
			)
		if enemy_support_troop_label != null:
			enemy_support_troop_label_layout_offset = _capture_template_slot_offset(
				enemy_support_template,
				"TroopLabelSlot",
				_get_canvas_item_world_position(enemy_support_troop_label),
				enemy_support_anchor
			)
		if enemy_support_unit_click_area != null:
			enemy_support_click_area_layout_offset = _capture_template_slot_offset(
				enemy_support_template,
				"ClickAreaSlot",
				_get_canvas_item_world_position(enemy_support_unit_click_area),
				enemy_support_anchor
			)
		enemy_support_facing_indicator_layout_offset = _capture_template_slot_offset(
			enemy_support_template,
			"FacingIndicatorSlot",
			enemy_support_anchor + enemy_support_facing_indicator_layout_offset,
			enemy_support_anchor
		)


func _get_ally_group_base_positions(ally_anchor: Vector2) -> Array[Vector2]:
	return _get_ally_group_base_positions_for_unit(ally_anchor, ally_unit_state)


func _get_ally_group_base_positions_for_unit(ally_anchor: Vector2, unit_state: BattleUnitState) -> Array[Vector2]:
	var portrait_offset := _get_ally_portrait_offset_for_facing(
		ally_portrait_layout_offsets_by_facing,
		ally_portrait_layout_offset,
		_get_unit_facing(unit_state)
	)
	return [
		ally_anchor + ally_shadow_layout_offset,
		ally_anchor + ally_token_layout_offset,
		ally_anchor + ally_move_dust_layout_offset,
		ally_anchor + portrait_offset,
		ally_anchor + ally_hp_bar_layout_offset,
		ally_anchor + ally_troop_label_layout_offset,
	]


func _get_enemy_group_base_positions(enemy_anchor: Vector2) -> Array[Vector2]:
	return _get_enemy_group_base_positions_for_unit(enemy_anchor, enemy_unit_state)


func _get_enemy_group_base_positions_for_unit(enemy_anchor: Vector2, unit_state: BattleUnitState) -> Array[Vector2]:
	var portrait_offset := _get_enemy_portrait_offset_for_facing(
		enemy_portrait_layout_offsets_by_facing,
		enemy_portrait_layout_offset,
		_get_unit_facing(unit_state)
	)
	return [
		enemy_anchor + enemy_shadow_layout_offset,
		enemy_anchor + enemy_token_layout_offset,
		enemy_anchor + enemy_move_dust_layout_offset,
		enemy_anchor + portrait_offset,
		enemy_anchor + enemy_hp_bar_layout_offset,
		enemy_anchor + enemy_troop_label_layout_offset,
	]


func _get_ally_support_group_base_positions(ally_support_anchor: Vector2) -> Array[Vector2]:
	return _get_ally_support_group_base_positions_for_unit(ally_support_anchor, ally_support_unit_state)


func _get_ally_support_group_base_positions_for_unit(ally_support_anchor: Vector2, unit_state: BattleUnitState) -> Array[Vector2]:
	var portrait_offset := _get_ally_portrait_offset_for_facing(
		ally_support_portrait_layout_offsets_by_facing,
		ally_support_portrait_layout_offset,
		_get_unit_facing(unit_state)
	)
	return [
		ally_support_anchor + ally_support_shadow_layout_offset,
		ally_support_anchor + ally_support_token_layout_offset,
		ally_support_anchor + ally_support_move_dust_layout_offset,
		ally_support_anchor + portrait_offset,
		ally_support_anchor + ally_support_hp_bar_layout_offset,
		ally_support_anchor + ally_support_troop_label_layout_offset,
	]


func _get_enemy_support_group_base_positions(enemy_support_anchor: Vector2) -> Array[Vector2]:
	return _get_enemy_support_group_base_positions_for_unit(enemy_support_anchor, enemy_support_unit_state)


func _get_enemy_support_group_base_positions_for_unit(enemy_support_anchor: Vector2, unit_state: BattleUnitState) -> Array[Vector2]:
	var portrait_offset := _get_enemy_portrait_offset_for_facing(
		enemy_support_portrait_layout_offsets_by_facing,
		enemy_support_portrait_layout_offset,
		_get_unit_facing(unit_state)
	)
	return [
		enemy_support_anchor + enemy_support_shadow_layout_offset,
		enemy_support_anchor + enemy_support_token_layout_offset,
		enemy_support_anchor + enemy_support_move_dust_layout_offset,
		enemy_support_anchor + portrait_offset,
		enemy_support_anchor + enemy_support_hp_bar_layout_offset,
		enemy_support_anchor + enemy_support_troop_label_layout_offset,
	]


func _apply_group_base_positions(nodes: Array[CanvasItem], base_positions: Array[Vector2]) -> void:
	_apply_group_offset(nodes, base_positions, Vector2.ZERO)


func _get_ally_portrait_visual_offset() -> Vector2:
	return current_ally_portrait_position - current_ally_unit_position


func _get_enemy_portrait_visual_offset() -> Vector2:
	return enemy_portrait_marker.position - enemy_unit_marker.position


func _get_cell_from_world(pos: Vector2) -> Vector2i:
	return battle_grid_controller.world_to_grid(pos)


func _get_raw_move_target_cell() -> Vector2i:
	return _get_cell_from_world(move_target_marker.global_position)


func _get_selected_move_target_cell() -> Vector2i:
	return selected_move_cell


func _get_snapped_move_target_cell() -> Vector2i:
	var raw_cell: Vector2i = _get_selected_move_target_cell()
	if _is_valid_grid_cell(raw_cell):
		return raw_cell

	return Vector2i(
		clampi(raw_cell.x, 0, battle_grid_controller.grid_width - 1),
		clampi(raw_cell.y, 0, battle_grid_controller.grid_height - 1)
	)


func _get_snapped_move_target_world_position() -> Vector2:
	return battle_grid_controller.grid_to_world(_get_snapped_move_target_cell())


func _get_selected_ally_display_name() -> String:
	if active_unit_state == null:
		return ""
	return active_unit_state.display_name


func _get_selected_ally_unit_marker() -> Marker2D:
	return _get_unit_marker_for_unit(active_unit_state)


func _get_selected_ally_portrait_marker() -> Marker2D:
	return _get_portrait_marker_for_unit(active_unit_state)


func _get_unit_marker_for_unit(unit_state: BattleUnitState) -> Marker2D:
	if unit_state == null:
		return null
	if unit_state == ally_main_03_unit_state:
		return ally_main_03_unit_marker
	if unit_state == ally_reinforce_01_unit_state:
		return ally_reinforce_01_unit_marker
	if unit_state == ally_reinforce_02_unit_state:
		return ally_reinforce_02_unit_marker
	if unit_state == ally_support_unit_state:
		return ally_support_unit_marker
	if unit_state == enemy_unit_state:
		return enemy_unit_marker
	if unit_state == enemy_support_unit_state:
		return enemy_support_unit_marker
	if unit_state == enemy_main_03_unit_state:
		return enemy_main_03_unit_marker
	if unit_state == enemy_reinforce_01_unit_state:
		return enemy_reinforce_01_unit_marker
	if unit_state == enemy_reinforce_02_unit_state:
		return enemy_reinforce_02_unit_marker
	return ally_unit_marker


func _get_portrait_marker_for_unit(unit_state: BattleUnitState) -> Marker2D:
	if unit_state == null:
		return null
	if unit_state == ally_main_03_unit_state:
		return ally_main_03_portrait_marker
	if unit_state == ally_reinforce_01_unit_state:
		return ally_reinforce_01_portrait_marker
	if unit_state == ally_reinforce_02_unit_state:
		return ally_reinforce_02_portrait_marker
	if unit_state == ally_support_unit_state:
		return ally_support_portrait_marker
	if unit_state == enemy_unit_state:
		return enemy_portrait_marker
	if unit_state == enemy_support_unit_state:
		return enemy_support_portrait_marker
	if unit_state == enemy_main_03_unit_state:
		return enemy_main_03_portrait_marker
	if unit_state == enemy_reinforce_01_unit_state:
		return enemy_reinforce_01_portrait_marker
	if unit_state == enemy_reinforce_02_unit_state:
		return enemy_reinforce_02_portrait_marker
	return ally_portrait_marker


func _get_selected_ally_click_area() -> Area2D:
	return _get_click_area_for_unit(active_unit_state)


func _get_selected_ally_visual_anchor_position() -> Vector2:
	return _get_visual_anchor_position_for_unit(active_unit_state)


func _get_ally_target_visual_anchor_position(target_state: BattleUnitState) -> Vector2:
	return _get_visual_anchor_position_for_unit(target_state)


func _get_ally_target_group_nodes(target_state: BattleUnitState) -> Array[CanvasItem]:
	return _get_visual_group_nodes_for_unit(target_state)


func _apply_ally_target_group_offset(offset: Vector2) -> void:
	var target_state := current_enemy_attack_target_state
	if target_state == null:
		target_state = _get_enemy_ai_target_state()
	_apply_group_offset_for_unit(target_state, offset)


func _set_ally_target_group_modulate(color: Color) -> void:
	var target_state := current_enemy_attack_target_state
	if target_state == null:
		target_state = _get_enemy_ai_target_state()
	if target_state == null:
		return
	_set_group_modulate(_get_ally_target_group_nodes(target_state), color)


func _update_ally_target_visuals_from_state(target_state: BattleUnitState) -> void:
	_update_unit_visuals_from_state(target_state)


func _apply_selected_ally_group_offset(offset: Vector2) -> void:
	_apply_group_offset_for_unit(active_unit_state, offset)


func _get_selected_ally_portrait_visual_offset() -> Vector2:
	var portrait_marker := _get_selected_ally_portrait_marker()
	var unit_marker := _get_selected_ally_unit_marker()
	if portrait_marker == null or unit_marker == null:
		return Vector2.ZERO
	return portrait_marker.position - unit_marker.position


func _sync_selected_ally_markers_to_position(unit_position: Vector2, portrait_position: Vector2) -> void:
	var unit_marker := _get_selected_ally_unit_marker()
	var portrait_marker := _get_selected_ally_portrait_marker()
	if unit_marker != null:
		unit_marker.position = unit_position
	if portrait_marker != null:
		portrait_marker.position = portrait_position
	if active_unit_state == ally_unit_state:
		current_ally_unit_position = unit_position
		current_ally_portrait_position = portrait_position


func _get_enemy_target_unit_marker(target_state: BattleUnitState) -> Marker2D:
	return _get_unit_marker_for_unit(target_state)


func _get_enemy_target_visual_anchor_position(target_state: BattleUnitState) -> Vector2:
	return _get_visual_anchor_position_for_unit(target_state)


func _get_enemy_target_group_nodes(target_state: BattleUnitState) -> Array[CanvasItem]:
	return _get_visual_group_nodes_for_unit(target_state)


func _get_enemy_actor_unit_marker(enemy_actor_state: BattleUnitState) -> Marker2D:
	return _get_unit_marker_for_unit(enemy_actor_state)


func _get_enemy_actor_portrait_marker(enemy_actor_state: BattleUnitState) -> Marker2D:
	return _get_portrait_marker_for_unit(enemy_actor_state)


func _get_enemy_actor_visual_anchor_position(enemy_actor_state: BattleUnitState) -> Vector2:
	return _get_visual_anchor_position_for_unit(enemy_actor_state)


func _get_enemy_actor_group_nodes(enemy_actor_state: BattleUnitState) -> Array[CanvasItem]:
	return _get_visual_group_nodes_for_unit(enemy_actor_state)


func _update_enemy_actor_visuals_from_state(enemy_actor_state: BattleUnitState) -> void:
	_update_unit_visuals_from_state(enemy_actor_state)


func _sync_enemy_actor_markers_to_position(enemy_actor_state: BattleUnitState, unit_position: Vector2, portrait_position: Vector2) -> void:
	var unit_marker := _get_enemy_actor_unit_marker(enemy_actor_state)
	var portrait_marker := _get_enemy_actor_portrait_marker(enemy_actor_state)
	if unit_marker != null:
		unit_marker.position = unit_position
	if portrait_marker != null:
		portrait_marker.position = portrait_position


func _apply_enemy_target_group_offset(offset: Vector2) -> void:
	var target_state := current_attack_animation_target_state
	if target_state == null:
		target_state = selected_attack_target_state
	_apply_group_offset_for_unit(target_state, offset)


func _set_enemy_target_group_modulate(color: Color) -> void:
	var target_state := current_attack_animation_target_state
	if target_state == null:
		target_state = selected_attack_target_state
	if target_state == null:
		return
	_set_group_modulate(_get_enemy_target_group_nodes(target_state), color)


func _update_enemy_target_visuals_from_state(target_state: BattleUnitState) -> void:
	_update_unit_visuals_from_state(target_state)


func _get_alive_enemy_targets() -> Array[BattleUnitState]:
	var adapter_targets := _get_alive_deployed_unit_states_for_side("enemy")
	if _is_battle_unit_state_adapter_ready() and not adapter_targets.is_empty():
		return adapter_targets
	return _get_fallback_alive_enemy_units()


func _get_enemy_ai_target_state() -> BattleUnitState:
	var actor_state := enemy_unit_state
	if current_enemy_ai_actor_state != null:
		actor_state = current_enemy_ai_actor_state
	return _get_enemy_ai_target_state_for_actor(actor_state)


func _get_enemy_ai_target_state_for_actor(enemy_actor_state: BattleUnitState) -> BattleUnitState:
	if enemy_actor_state == null:
		return null
	var alive_allies := _get_target_candidates_for_actor(enemy_actor_state)
	if alive_allies.is_empty():
		return null

	return _get_enemy_ai_target_state_from_candidates(enemy_actor_state, alive_allies)


func _get_enemy_ai_target_state_from_candidates(enemy_actor_state: BattleUnitState, target_candidates: Array[BattleUnitState]) -> BattleUnitState:
	if enemy_actor_state == null:
		return null
	if target_candidates.is_empty():
		return null

	var best_attackable_target: BattleUnitState = null
	var best_attackable_distance := 9999
	var best_target: BattleUnitState = null
	var best_distance := 9999
	for ally_state in target_candidates:
		var distance := get_unit_grid_distance(enemy_actor_state, ally_state)
		if distance < best_distance:
			best_distance = distance
			best_target = ally_state
		if distance <= enemy_actor_state.attack_range and distance < best_attackable_distance:
			best_attackable_distance = distance
			best_attackable_target = ally_state

	if best_attackable_target != null:
		return best_attackable_target
	return best_target


func _clear_enemy_ai_turn_reservations() -> void:
	enemy_ai_reserved_destination_cells.clear()
	enemy_ai_reserved_engagement_cells.clear()


func _is_enemy_ai_destination_cell_reserved_for_other_actor(cell: Vector2i, enemy_actor_state: BattleUnitState) -> bool:
	if enemy_actor_state == null:
		return false
	if cell == enemy_actor_state.grid_cell:
		return false
	if not enemy_ai_reserved_destination_cells.has(cell):
		return false
	var actor_slot_id := _get_capacity_slot_id_for_unit_state(enemy_actor_state)
	return str(enemy_ai_reserved_destination_cells.get(cell, "")) != actor_slot_id


func _is_enemy_ai_engagement_cell_reserved_for_other_actor(cell: Vector2i, enemy_actor_state: BattleUnitState) -> bool:
	if enemy_actor_state == null:
		return false
	if cell == enemy_actor_state.grid_cell:
		return false
	if not enemy_ai_reserved_engagement_cells.has(cell):
		return false
	var actor_slot_id := _get_capacity_slot_id_for_unit_state(enemy_actor_state)
	return str(enemy_ai_reserved_engagement_cells.get(cell, "")) != actor_slot_id


func _can_enemy_ai_use_destination_cell(cell: Vector2i, enemy_actor_state: BattleUnitState) -> bool:
	if not _is_valid_destination_for_unit(cell, enemy_actor_state):
		return false
	if _is_enemy_ai_destination_cell_reserved_for_other_actor(cell, enemy_actor_state):
		return false
	return true


func _reserve_enemy_ai_decision_plan_for_actor(enemy_actor_state: BattleUnitState, decision_plan: Dictionary) -> void:
	if enemy_actor_state == null or decision_plan.is_empty():
		return
	var actor_slot_id := _get_capacity_slot_id_for_unit_state(enemy_actor_state)
	var destination: Vector2i = decision_plan.get("destination", enemy_actor_state.grid_cell)
	var final_cell: Vector2i = decision_plan.get("final_cell", destination)
	if destination != enemy_actor_state.grid_cell:
		enemy_ai_reserved_destination_cells[destination] = actor_slot_id
	if final_cell != enemy_actor_state.grid_cell:
		enemy_ai_reserved_engagement_cells[final_cell] = actor_slot_id


func _get_enemy_ai_action_priority(action_reason: String) -> int:
	match action_reason:
		"ATTACK":
			return 0
		"MOVE_ATTACK":
			return 1
		"ENGAGE":
			return 2
		"WAIT":
			return 99
		_:
			return 999


func _get_enemy_ai_target_candidates_in_priority_order(enemy_actor_state: BattleUnitState, preferred_target: BattleUnitState) -> Array[BattleUnitState]:
	var ordered_targets: Array[BattleUnitState] = []
	for target_state in _get_target_candidates_for_actor(enemy_actor_state):
		if target_state == null:
			continue
		ordered_targets.append(target_state)
	ordered_targets.sort_custom(func(a: BattleUnitState, b: BattleUnitState) -> bool:
		var a_is_preferred := a == preferred_target
		var b_is_preferred := b == preferred_target
		if a_is_preferred != b_is_preferred:
			return a_is_preferred
		var a_attackable := is_unit_in_attack_range(enemy_actor_state, a)
		var b_attackable := is_unit_in_attack_range(enemy_actor_state, b)
		if a_attackable != b_attackable:
			return a_attackable
		var a_distance := get_unit_grid_distance(enemy_actor_state, a)
		var b_distance := get_unit_grid_distance(enemy_actor_state, b)
		if a_distance != b_distance:
			return a_distance < b_distance
		var a_slot_id := _get_capacity_slot_id_for_unit_state(a)
		var b_slot_id := _get_capacity_slot_id_for_unit_state(b)
		return a_slot_id < b_slot_id
	)
	return ordered_targets


func _should_replace_enemy_ai_decision_plan(candidate_plan: Dictionary, current_plan: Dictionary) -> bool:
	if candidate_plan.is_empty():
		return false
	if current_plan.is_empty():
		return true
	var candidate_priority := int(candidate_plan.get("priority", 999))
	var current_priority := int(current_plan.get("priority", 999))
	if candidate_priority != current_priority:
		return candidate_priority < current_priority
	var candidate_is_preferred := bool(candidate_plan.get("is_preferred_target", false))
	var current_is_preferred := bool(current_plan.get("is_preferred_target", false))
	if candidate_is_preferred != current_is_preferred:
		return candidate_is_preferred
	var candidate_distance := int(candidate_plan.get("score_distance", 9999))
	var current_distance := int(current_plan.get("score_distance", 9999))
	if candidate_distance != current_distance:
		return candidate_distance < current_distance
	var candidate_path_length := int(candidate_plan.get("score_path_length", 9999))
	var current_path_length := int(current_plan.get("score_path_length", 9999))
	if candidate_path_length != current_path_length:
		return candidate_path_length < current_path_length
	var candidate_slot_id := str(candidate_plan.get("final_target_slot", ""))
	var current_slot_id := str(current_plan.get("final_target_slot", ""))
	return candidate_slot_id < current_slot_id


func _build_enemy_ai_target_action_plan_for_actor(enemy_actor_state: BattleUnitState, target_state: BattleUnitState) -> Dictionary:
	var empty_plan: Dictionary = {}
	if enemy_actor_state == null or target_state == null:
		return empty_plan
	var start_cell := enemy_actor_state.grid_cell
	var current_distance := get_unit_grid_distance(enemy_actor_state, target_state)
	if is_unit_in_attack_range(enemy_actor_state, target_state):
		return {
			"action_reason": "ATTACK",
			"wait_reason": "",
			"destination": start_cell,
			"final_cell": start_cell,
			"step_cell": start_cell,
			"mode": "attack_now",
			"plan_reason": "in_range",
			"priority": _get_enemy_ai_action_priority("ATTACK"),
			"score_distance": 0,
			"score_path_length": 0,
		}

	var reachable_paths := _get_enemy_reachable_paths_for_actor(enemy_actor_state, start_cell)
	var best_attack_cell := start_cell
	var best_attack_distance := 9999
	var best_attack_path_length := 9999
	var best_approach_cell := start_cell
	var best_approach_distance := current_distance
	var best_approach_path_length := 9999

	for cell_variant in reachable_paths.keys():
		var candidate_cell: Vector2i = cell_variant
		if candidate_cell == start_cell:
			continue
		if not _can_enemy_ai_use_destination_cell(candidate_cell, enemy_actor_state):
			continue
		var path = reachable_paths[candidate_cell] as Array
		var path_length := path.size() - 1
		if path_length <= 0:
			continue
		var typed_path: Array[Vector2i] = []
		for path_cell_variant in path:
			var path_cell: Vector2i = path_cell_variant
			typed_path.append(path_cell)
		if not _is_path_clear_for_unit(typed_path, enemy_actor_state):
			continue
		var candidate_distance := absi(candidate_cell.x - target_state.grid_cell.x) + absi(candidate_cell.y - target_state.grid_cell.y)
		var can_attack_after_move := candidate_distance <= enemy_actor_state.attack_range
		if can_attack_after_move:
			if candidate_distance < best_attack_distance or (candidate_distance == best_attack_distance and path_length < best_attack_path_length):
				best_attack_cell = candidate_cell
				best_attack_distance = candidate_distance
				best_attack_path_length = path_length
			continue
		if candidate_distance < best_approach_distance or (candidate_distance == best_approach_distance and path_length < best_approach_path_length):
			best_approach_cell = candidate_cell
			best_approach_distance = candidate_distance
			best_approach_path_length = path_length

	if best_attack_cell != start_cell:
		return {
			"action_reason": "MOVE_ATTACK",
			"wait_reason": "",
			"destination": best_attack_cell,
			"final_cell": best_attack_cell,
			"step_cell": best_attack_cell,
			"mode": "attack_after_move",
			"plan_reason": "reachable_attack_cell",
			"priority": _get_enemy_ai_action_priority("MOVE_ATTACK"),
			"score_distance": best_attack_distance,
			"score_path_length": best_attack_path_length,
		}

	var engagement_plan := _get_enemy_engagement_step_plan_for_actor(enemy_actor_state, target_state)
	if not engagement_plan.is_empty():
		var engagement_step: Vector2i = engagement_plan.get("step_cell", start_cell)
		if engagement_step != start_cell:
			engagement_plan["action_reason"] = "ENGAGE"
			engagement_plan["wait_reason"] = ""
			engagement_plan["destination"] = engagement_step
			engagement_plan["priority"] = _get_enemy_ai_action_priority("ENGAGE")
			engagement_plan["score_distance"] = int(engagement_plan.get("step_distance", 9999))
			engagement_plan["score_path_length"] = int(engagement_plan.get("full_path_length", 9999))
			return engagement_plan

	if best_approach_cell != start_cell and best_approach_distance <= current_distance:
		return {
			"action_reason": "ENGAGE",
			"wait_reason": "",
			"destination": best_approach_cell,
			"final_cell": best_approach_cell,
			"step_cell": best_approach_cell,
			"mode": "approach_distance",
			"plan_reason": "closest_reachable_cell",
			"priority": _get_enemy_ai_action_priority("ENGAGE"),
			"score_distance": best_approach_distance,
			"score_path_length": best_approach_path_length,
		}

	return {
		"action_reason": "WAIT",
		"wait_reason": "no_attack_or_engagement_path_for_target",
		"destination": start_cell,
		"final_cell": start_cell,
		"step_cell": start_cell,
		"mode": "wait",
		"plan_reason": "no_reachable_cell",
		"priority": _get_enemy_ai_action_priority("WAIT"),
		"score_distance": 9999,
		"score_path_length": 9999,
	}


func _get_enemy_ai_decision_plan_for_actor(enemy_actor_state: BattleUnitState, preferred_target_override: BattleUnitState = null) -> Dictionary:
	var empty_plan: Dictionary = {}
	if enemy_actor_state == null:
		return empty_plan
	var preferred_target := preferred_target_override
	if preferred_target == null:
		preferred_target = _get_enemy_ai_target_state_for_actor(enemy_actor_state)
	if preferred_target == null:
		return {
			"action_reason": "WAIT",
			"decision_reason": "WAIT",
			"wait_reason": "no_target",
			"preferred_target_state": null,
			"final_target_state": null,
			"destination": enemy_actor_state.grid_cell,
			"final_cell": enemy_actor_state.grid_cell,
			"step_cell": enemy_actor_state.grid_cell,
			"mode": "wait",
			"plan_reason": "no_target",
			"priority": _get_enemy_ai_action_priority("WAIT"),
			"score_distance": 9999,
			"score_path_length": 9999,
		}

	var best_plan: Dictionary = {}
	for target_state in _get_enemy_ai_target_candidates_in_priority_order(enemy_actor_state, preferred_target):
		var target_plan := _build_enemy_ai_target_action_plan_for_actor(enemy_actor_state, target_state)
		if target_plan.is_empty():
			continue
		target_plan["preferred_target_state"] = preferred_target
		target_plan["preferred_target_name"] = preferred_target.display_name
		target_plan["preferred_target_slot"] = _get_capacity_slot_id_for_unit_state(preferred_target)
		target_plan["final_target_state"] = target_state
		target_plan["final_target_name"] = target_state.display_name
		target_plan["final_target_slot"] = _get_capacity_slot_id_for_unit_state(target_state)
		target_plan["is_preferred_target"] = target_state == preferred_target
		if _should_replace_enemy_ai_decision_plan(target_plan, best_plan):
			best_plan = target_plan

	if best_plan.is_empty():
		best_plan = {
			"action_reason": "WAIT",
			"wait_reason": "no_attack_or_engagement_path_any_target",
			"preferred_target_state": preferred_target,
			"preferred_target_name": preferred_target.display_name,
			"preferred_target_slot": _get_capacity_slot_id_for_unit_state(preferred_target),
			"final_target_state": preferred_target,
			"final_target_name": preferred_target.display_name,
			"final_target_slot": _get_capacity_slot_id_for_unit_state(preferred_target),
			"is_preferred_target": true,
			"destination": enemy_actor_state.grid_cell,
			"final_cell": enemy_actor_state.grid_cell,
			"step_cell": enemy_actor_state.grid_cell,
			"mode": "wait",
			"plan_reason": "no_reachable_cell",
			"priority": _get_enemy_ai_action_priority("WAIT"),
			"score_distance": 9999,
			"score_path_length": 9999,
		}

	var action_reason := str(best_plan.get("action_reason", "WAIT"))
	var decision_reason := action_reason
	if action_reason != "WAIT" and not bool(best_plan.get("is_preferred_target", false)):
		decision_reason = "FALLBACK_TARGET"
	best_plan["decision_reason"] = decision_reason
	best_plan["fallback_action_reason"] = action_reason
	best_plan["used_fallback_target"] = decision_reason == "FALLBACK_TARGET"
	return best_plan


func _log_enemy_ai_decision_plan(enemy_actor_state: BattleUnitState, decision_plan: Dictionary) -> void:
	if enemy_actor_state == null or decision_plan.is_empty():
		return
	var actor_slot_id := _get_capacity_slot_id_for_unit_state(enemy_actor_state)
	var preferred_target_slot := str(decision_plan.get("preferred_target_slot", ""))
	var preferred_target_name := str(decision_plan.get("preferred_target_name", ""))
	var final_target_slot := str(decision_plan.get("final_target_slot", ""))
	var final_target_name := str(decision_plan.get("final_target_name", ""))
	var destination: Vector2i = decision_plan.get("destination", enemy_actor_state.grid_cell)
	var decision_reason := str(decision_plan.get("decision_reason", "WAIT"))
	var action_reason := str(decision_plan.get("action_reason", "WAIT"))
	var wait_reason := str(decision_plan.get("wait_reason", ""))
	print("[ENEMY_AI_DECISION] actor_slot=%s actor=%s preferred_target=%s/%s final_target=%s/%s dest=%s reason=%s action=%s wait_reason=%s" % [
		actor_slot_id,
		enemy_actor_state.display_name,
		preferred_target_slot,
		preferred_target_name,
		final_target_slot,
		final_target_name,
		destination,
		decision_reason,
		action_reason,
		wait_reason,
	])


func _get_legacy_enemy_ai_target_state() -> BattleUnitState:
	if ally_unit_state != null and ally_unit_state.is_alive():
		return ally_unit_state
	if ally_support_unit_state != null and ally_support_unit_state.is_alive():
		return ally_support_unit_state
	if ally_main_03_unit_state != null and ally_main_03_unit_state.is_alive():
		return ally_main_03_unit_state
	return null


func _get_target_candidates_for_actor(actor_state: BattleUnitState) -> Array[BattleUnitState]:
	var adapter_targets := _get_target_candidates_for_actor_from_adapter(actor_state)
	if _is_battle_unit_state_adapter_ready() and not adapter_targets.is_empty():
		return adapter_targets
	return _get_fallback_target_candidates_for_actor(actor_state)


func _get_fallback_target_candidates_for_actor(actor_state: BattleUnitState) -> Array[BattleUnitState]:
	var empty_candidates: Array[BattleUnitState] = []
	if actor_state == null:
		return empty_candidates
	if actor_state.side == "ally":
		return _get_fallback_alive_enemy_units()
	if actor_state.side == "enemy":
		return _get_fallback_alive_ally_units()
	return empty_candidates


func _get_first_candidate_from_list(candidates: Array[BattleUnitState]) -> BattleUnitState:
	if candidates.is_empty():
		return null
	return candidates[0]


func _find_best_attack_target_for_active_ally() -> BattleUnitState:
	if active_unit_state == null:
		return null

	var best_target: BattleUnitState = null
	var best_distance := 9999
	for target_state in _get_alive_enemy_targets():
		if not is_unit_in_attack_range(active_unit_state, target_state):
			continue
		var distance := get_unit_grid_distance(active_unit_state, target_state)
		if distance < best_distance:
			best_distance = distance
			best_target = target_state
	return best_target


func _refresh_attack_target_for_active_ally() -> void:
	if active_unit_state == null:
		_clear_attack_target_selection()
		return

	if selected_attack_target_state != null:
		if selected_attack_target_state.is_alive() and is_unit_in_attack_range(active_unit_state, selected_attack_target_state):
			_show_attack_target_feedback()
			return

	var best_target := _find_best_attack_target_for_active_ally()
	if best_target != null:
		selected_attack_target_state = best_target
		selected_attack_target_side = "enemy"
		_show_attack_target_feedback()
		return

	_clear_attack_target_selection()


func _get_alive_ally_units() -> Array[BattleUnitState]:
	var adapter_allies := _get_alive_deployed_unit_states_for_side("ally")
	if _is_battle_unit_state_adapter_ready() and not adapter_allies.is_empty():
		return adapter_allies
	return _get_fallback_alive_ally_units()


func _get_fallback_alive_ally_units() -> Array[BattleUnitState]:
	var allies: Array[BattleUnitState] = []
	var candidates: Array = [ally_unit_state, ally_support_unit_state, ally_main_03_unit_state, ally_reinforce_01_unit_state]
	candidates.append(ally_reinforce_02_unit_state)
	for candidate in candidates:
		var unit_state := candidate as BattleUnitState
		if _is_unit_state_available_for_battle_slot(unit_state):
			allies.append(unit_state)
	return allies


func _get_alive_enemy_units() -> Array[BattleUnitState]:
	var adapter_enemies := _get_alive_deployed_unit_states_for_side("enemy")
	if _is_battle_unit_state_adapter_ready() and not adapter_enemies.is_empty():
		return adapter_enemies
	return _get_fallback_alive_enemy_units()


func _get_fallback_alive_enemy_units() -> Array[BattleUnitState]:
	var enemies: Array[BattleUnitState] = []
	var candidates: Array = [enemy_unit_state, enemy_support_unit_state, enemy_main_03_unit_state, enemy_reinforce_01_unit_state]
	candidates.append(enemy_reinforce_02_unit_state)
	for candidate in candidates:
		var unit_state := candidate as BattleUnitState
		if _is_unit_state_available_for_battle_slot(unit_state):
			enemies.append(unit_state)
	return enemies


func _mark_ally_unit_acted(unit_state: BattleUnitState) -> void:
	if unit_state == null:
		return
	if unit_state.side != "ally":
		return
	if unit_state.unit_id == "":
		return
	var was_already_acted := _has_ally_unit_acted(unit_state)
	acted_ally_unit_ids[unit_state.unit_id] = true
	unit_state.has_acted = true
	unit_state.has_moved = true
	if unit_state == active_unit_state:
		ally_has_moved = true
	if not was_already_acted:
		_consume_strategy_status_after_unit_action(unit_state)


func _has_ally_unit_acted(unit_state: BattleUnitState) -> bool:
	if unit_state == null:
		return true
	if unit_state.side != "ally":
		return false
	if unit_state.unit_id == "":
		return unit_state.has_acted
	return bool(acted_ally_unit_ids.get(unit_state.unit_id, unit_state.has_acted))


func _reset_ally_action_locks_for_new_round() -> void:
	acted_ally_unit_ids.clear()
	for unit_state in _get_alive_ally_units():
		unit_state.reset_action_flags()
	ally_has_moved = false


func _mark_enemy_unit_acted(unit_state: BattleUnitState) -> void:
	if unit_state == null:
		return
	if unit_state.side != "enemy":
		return
	if unit_state.unit_id == "":
		return
	var was_already_acted := _has_enemy_unit_acted(unit_state)
	acted_enemy_unit_ids[unit_state.unit_id] = true
	unit_state.has_acted = true
	unit_state.has_moved = true
	if not was_already_acted:
		_consume_strategy_status_after_unit_action(unit_state)


func _has_enemy_unit_acted(unit_state: BattleUnitState) -> bool:
	if unit_state == null:
		return true
	if unit_state.side != "enemy":
		return false
	if unit_state.unit_id == "":
		return unit_state.has_acted
	return bool(acted_enemy_unit_ids.get(unit_state.unit_id, unit_state.has_acted))


func _reset_enemy_action_locks_for_new_round() -> void:
	acted_enemy_unit_ids.clear()
	_clear_enemy_ai_turn_reservations()
	for unit_state in _get_alive_enemy_units():
		unit_state.reset_action_flags()


func _are_all_alive_enemies_acted() -> bool:
	var alive_enemies := _get_alive_enemy_units()
	if alive_enemies.is_empty():
		return true
	for unit_state in alive_enemies:
		if not _has_enemy_unit_acted(unit_state):
			return false
	return true


func _get_next_available_enemy_ai_actor() -> BattleUnitState:
	var candidates: Array = [enemy_unit_state, enemy_support_unit_state, enemy_main_03_unit_state, enemy_reinforce_01_unit_state]
	candidates.append(enemy_reinforce_02_unit_state)
	for candidate in candidates:
		var unit_state := candidate as BattleUnitState
		if _is_unit_state_available_for_battle_slot(unit_state) and not _has_enemy_unit_acted(unit_state):
			return unit_state
	return null


func _are_all_alive_allies_acted() -> bool:
	var alive_allies := _get_alive_ally_units()
	if alive_allies.is_empty():
		return false
	for unit_state in alive_allies:
		if not _has_ally_unit_acted(unit_state):
			return false
	return true


func _get_first_available_ally_unit() -> BattleUnitState:
	for unit_state in _get_alive_ally_units():
		if not _has_ally_unit_acted(unit_state):
			return unit_state
	return null


func _get_available_auto_units_for_side(side: String) -> Array[BattleUnitState]:
	var adapter_candidates := _get_available_actor_candidates_for_side_from_adapter(side)
	if _is_battle_unit_state_adapter_ready() and not adapter_candidates.is_empty():
		return adapter_candidates

	var available_units: Array[BattleUnitState] = []
	var candidates: Array[BattleUnitState] = []
	match side:
		"ally":
			candidates = _get_alive_ally_units()
		"enemy":
			candidates = _get_alive_enemy_units()
		_:
			return available_units

	for unit_state in candidates:
		if unit_state == null:
			continue
		if side == "ally":
			if not _has_ally_unit_acted(unit_state):
				available_units.append(unit_state)
		elif side == "enemy":
			if not _has_enemy_unit_acted(unit_state):
				available_units.append(unit_state)
	return available_units


func _get_alive_auto_targets_for_side(side: String) -> Array[BattleUnitState]:
	var empty_targets: Array[BattleUnitState] = []
	var adapter_targets := _get_alive_target_candidates_for_side_from_adapter(side)
	if _is_battle_unit_state_adapter_ready() and not adapter_targets.is_empty():
		return adapter_targets
	if side == "ally":
		return _get_fallback_alive_enemy_units()
	if side == "enemy":
		return _get_fallback_alive_ally_units()
	return empty_targets


func _get_auto_damage_for_actor(actor_state: BattleUnitState) -> int:
	if actor_state == null:
		return 0
	if actor_state.side == "enemy":
		return int(ENEMY_DEMO_DAMAGE)
	return int(DEMO_DAMAGE)


func _get_auto_damage_for_actor_against_target(actor_state: BattleUnitState, target_state: BattleUnitState) -> int:
	return _get_directional_attack_damage(_get_auto_damage_for_actor(actor_state), actor_state, target_state)


func _can_auto_kill_target(actor_state: BattleUnitState, target_state: BattleUnitState) -> bool:
	if actor_state == null or target_state == null:
		return false
	if not target_state.is_alive():
		return false
	return _get_auto_damage_for_actor_against_target(actor_state, target_state) >= int(target_state.current_hp)


func _get_auto_slot_priority(slot_id: String) -> int:
	match slot_id:
		"enemy_main", "ally_main":
			return 1
		"enemy_support", "ally_support":
			return 0
		_:
			return 0


func _score_auto_attack_target(actor_state: BattleUnitState, target_state: BattleUnitState) -> int:
	if actor_state == null or target_state == null:
		return -999999
	if not target_state.is_alive():
		return -999999

	var score := 0
	if _can_auto_kill_target(actor_state, target_state):
		score += 100000
	if is_unit_in_attack_range(actor_state, target_state):
		score += 10000

	var max_hp_score := maxi(0, int(target_state.max_hp) - int(target_state.current_hp))
	score += max_hp_score * 10

	var distance := get_unit_grid_distance(actor_state, target_state)
	score += maxi(0, 200 - distance)
	var angle_type := _get_attack_angle_type(actor_state, target_state)
	if angle_type == ATTACK_ANGLE_BACK:
		score += 300
	elif angle_type == ATTACK_ANGLE_SIDE:
		score += 150
	score += _get_auto_slot_priority(target_state.slot_id) * 100
	return score


func _find_best_auto_attack_target_from_candidates(actor_state: BattleUnitState, target_candidates: Array[BattleUnitState]) -> BattleUnitState:
	if actor_state == null:
		return null

	var best_target: BattleUnitState = null
	var best_score := -999999
	for target_state in target_candidates:
		if not is_unit_in_attack_range(actor_state, target_state):
			continue
		var score := _score_auto_attack_target(actor_state, target_state)
		if score > best_score:
			best_score = score
			best_target = target_state
	return best_target


func _find_best_auto_attack_target(actor_state: BattleUnitState) -> BattleUnitState:
	return _find_best_auto_attack_target_from_candidates(actor_state, _get_alive_auto_targets_for_side(actor_state.side))


func _get_auto_move_path_for_actor(actor_state: BattleUnitState, target_cell: Vector2i) -> Array[Vector2i]:
	var empty_path: Array[Vector2i] = []
	if actor_state == null:
		return empty_path
	if actor_state.side == "enemy":
		return _find_enemy_move_path_for_actor(actor_state, actor_state.grid_cell, target_cell)

	var previous_active_unit_state := active_unit_state
	var previous_active_unit_side := active_unit_side
	active_unit_state = actor_state
	active_unit_side = actor_state.side
	var path := _find_ally_move_path(actor_state.grid_cell, target_cell)
	active_unit_state = previous_active_unit_state
	active_unit_side = previous_active_unit_side
	return path


func _find_best_auto_move_cell(actor_state: BattleUnitState) -> Vector2i:
	if actor_state == null:
		return Vector2i.ZERO
	if battle_grid_controller == null:
		return actor_state.grid_cell

	var best_target := _find_best_auto_attack_target(actor_state)
	if best_target != null:
		return actor_state.grid_cell

	var preferred_target: BattleUnitState = null
	var best_target_score := -999999
	for target_state in _get_alive_auto_targets_for_side(actor_state.side):
		var target_score := _score_auto_attack_target(actor_state, target_state)
		if target_score > best_target_score:
			best_target_score = target_score
			preferred_target = target_state

	if preferred_target == null:
		return actor_state.grid_cell
	if actor_state.side == "enemy":
		return _choose_enemy_basic_ai_destination_for_actor(actor_state, preferred_target)

	var best_cell := actor_state.grid_cell
	var best_distance := get_unit_grid_distance(actor_state, preferred_target)
	for x in range(battle_grid_controller.grid_width):
		for y in range(battle_grid_controller.grid_height):
			var candidate_cell := Vector2i(x, y)
			if candidate_cell == actor_state.grid_cell:
				continue
			if not _is_valid_destination_for_unit(candidate_cell, actor_state):
				continue
			var path := _get_auto_move_path_for_actor(actor_state, candidate_cell)
			if path.is_empty():
				continue
			var candidate_distance := absi(candidate_cell.x - preferred_target.grid_cell.x) + absi(candidate_cell.y - preferred_target.grid_cell.y)
			var can_attack_after_move := candidate_distance <= actor_state.attack_range
			if can_attack_after_move:
				return candidate_cell
			if candidate_distance < best_distance:
				best_distance = candidate_distance
				best_cell = candidate_cell
	return best_cell


func _debug_print_auto_battle_policy_snapshot(actor_state: BattleUnitState) -> void:
	if actor_state == null:
		print("[AUTO_POLICY] actor=null")
		return

	var target_summaries: Array[String] = []
	for target_state in _get_alive_auto_targets_for_side(actor_state.side):
		var summary := "%s hp=%d dist=%d in_range=%s score=%d" % [
			target_state.display_name,
			int(target_state.current_hp),
			get_unit_grid_distance(actor_state, target_state),
			str(is_unit_in_attack_range(actor_state, target_state)),
			_score_auto_attack_target(actor_state, target_state),
		]
		target_summaries.append(summary)

	var best_attack_target := _find_best_auto_attack_target(actor_state)
	var best_move_cell := _find_best_auto_move_cell(actor_state)
	var best_attack_target_name := "null"
	if best_attack_target != null:
		best_attack_target_name = best_attack_target.display_name
	print("[AUTO_POLICY] actor=%s side=%s cell=%s targets=%s best_attack=%s best_move=%s" % [
		actor_state.display_name,
		actor_state.side,
		actor_state.grid_cell,
		target_summaries,
		best_attack_target_name,
		best_move_cell,
	])


func _get_best_auto_facing_toward_nearest_enemy(actor_state: BattleUnitState) -> String:
	if actor_state == null:
		return FACING_RIGHT

	var nearest_target: BattleUnitState = null
	var nearest_distance := 999999
	for target_state in _get_alive_auto_targets_for_side(actor_state.side):
		var distance := get_unit_grid_distance(actor_state, target_state)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_target = target_state

	if nearest_target == null:
		return _normalize_facing(actor_state.facing)
	if actor_state.grid_cell.x < nearest_target.grid_cell.x:
		return FACING_RIGHT
	if actor_state.grid_cell.x > nearest_target.grid_cell.x:
		return FACING_LEFT
	if actor_state.grid_cell.y > nearest_target.grid_cell.y:
		return FACING_UP
	if actor_state.grid_cell.y < nearest_target.grid_cell.y:
		return FACING_DOWN
	return _normalize_facing(actor_state.facing)


func _select_auto_facing_after_move_for_active_ally() -> void:
	if active_unit_state == null:
		return
	_select_post_move_facing(_get_best_auto_facing_toward_nearest_enemy(active_unit_state))


func _toggle_full_auto_battle() -> void:
	if is_full_auto_battle_enabled:
		_stop_full_auto_battle("user stop")
		return
	_set_full_auto_battle_enabled(true)


func _set_full_auto_battle_enabled(enabled: bool) -> void:
	if enabled and _handle_battle_end_guard("auto_enable"):
		print("[AUTO_STEP_BLOCKED] source=auto_enable reason=battle_over")
		return
	is_full_auto_battle_enabled = enabled
	auto_battle_step_count = 0
	var can_issue_ally_command := (
		current_phase == PHASE_ALLY_TURN
		and not is_demo_animating
		and _is_active_ally_action_available()
	)
	_refresh_auto_battle_button_state(can_issue_ally_command)
	var auto_battle_state_text := "중지"
	if enabled:
		auto_battle_state_text = "시작"
	_append_battle_log("자동전투 %s" % auto_battle_state_text)
	if enabled:
		call_deferred("_tick_full_auto_battle_if_needed")
	else:
		_clear_auto_action_flags()


func _stop_full_auto_battle(reason: String) -> void:
	if not is_full_auto_battle_enabled:
		return
	is_full_auto_battle_enabled = false
	auto_battle_step_count = 0
	_clear_auto_action_flags()
	var can_issue_ally_command := (
		current_phase == PHASE_ALLY_TURN
		and not is_demo_animating
		and _is_active_ally_action_available()
	)
	_refresh_auto_battle_button_state(can_issue_ally_command)
	if reason != "":
		_append_battle_log("자동전투 중지: %s" % reason)
		print("[AUTO_BATTLE_STOP] reason=%s" % reason)


func _tick_full_auto_battle_if_needed() -> void:
	if not is_full_auto_battle_enabled:
		return
	if _handle_battle_end_guard("auto_tick"):
		print("[AUTO_STEP_BLOCKED] source=auto_tick reason=battle_over")
		return
	if is_demo_animating:
		return
	if current_phase != PHASE_ALLY_TURN:
		return
	var auto_battle_max_steps := _get_auto_battle_max_steps()
	if auto_battle_step_count >= auto_battle_max_steps:
		_stop_full_auto_battle("자동전투 안전 제한 도달 (%d/%d)" % [auto_battle_step_count, auto_battle_max_steps])
		return
	if _get_alive_ally_units().is_empty():
		_stop_full_auto_battle("아군 없음")
		return
	if _get_alive_enemy_units().is_empty():
		_stop_full_auto_battle("적군 없음")
		return
	if active_unit_state == null:
		_stop_full_auto_battle("active unit 없음")
		return
	if active_unit_side != "ally":
		_stop_full_auto_battle("active side mismatch")
		return
	if not _is_active_ally_action_available():
		_stop_full_auto_battle("행동 가능한 아군 없음")
		return
	auto_battle_step_count += 1
	_run_auto_action_for_active_ally_once()


func _get_auto_battle_max_steps() -> int:
	var deployed_alive_count := _get_all_alive_unit_states_from_adapter().size()
	var computed_budget := deployed_alive_count * AUTO_BATTLE_STEP_BUDGET_PER_DEPLOYED_UNIT
	return clampi(maxi(AUTO_BATTLE_MIN_MAX_STEPS, computed_budget), AUTO_BATTLE_MIN_MAX_STEPS, AUTO_BATTLE_ABSOLUTE_MAX_STEPS)


func _try_auto_attack_for_active_ally() -> bool:
	if active_unit_state == null:
		return false
	if active_unit_side != "ally":
		return false
	if not active_unit_state.is_alive():
		return false
	if not _is_active_ally_action_available():
		return false
	if current_phase != PHASE_ALLY_TURN:
		return false
	if is_demo_animating:
		return false

	var target_state := _find_best_auto_attack_target(active_unit_state)
	if target_state == null:
		return false
	if not is_unit_in_attack_range(active_unit_state, target_state):
		return false

	_clear_move_target_selection()
	selected_attack_target_state = target_state
	if target_state.side != "":
		selected_attack_target_side = target_state.side
	else:
		selected_attack_target_side = "enemy"
	_show_attack_target_feedback()
	_append_battle_log("%s 자동 공격 선택" % target_state.display_name)
	is_auto_action_in_progress = true
	play_basic_attack_demo()
	return is_demo_animating


func _try_auto_move_for_active_ally() -> bool:
	if active_unit_state == null:
		return false
	if active_unit_side != "ally":
		return false
	if not active_unit_state.is_alive():
		return false
	if active_unit_state.has_moved:
		return false
	if not _is_active_ally_action_available():
		return false
	if current_phase != PHASE_ALLY_TURN:
		return false
	if is_demo_animating:
		return false

	var move_cell := _find_best_auto_move_cell(active_unit_state)
	if move_cell == active_unit_state.grid_cell:
		return false
	if not _is_valid_destination_for_unit(move_cell, active_unit_state):
		return false

	var previous_move_cell := selected_move_cell
	var previous_has_selected_move_target := has_selected_move_target
	set_move_target_cell(move_cell)
	if not has_selected_move_target or selected_move_cell != move_cell:
		selected_move_cell = previous_move_cell
		has_selected_move_target = previous_has_selected_move_target
		return false

	_append_battle_log("%s 자동 이동 후보 선택" % _format_cell(move_cell))
	is_auto_action_in_progress = true
	should_auto_select_facing_after_move = true
	play_basic_move_demo()
	if not is_demo_animating:
		_clear_auto_action_flags()
	return is_demo_animating


func _auto_wait_active_ally() -> void:
	if active_unit_state == null:
		return
	_clear_auto_action_flags()
	_append_battle_log("%s 자동 대기" % active_unit_state.display_name)
	_end_ally_turn_by_wait()


func _run_auto_action_for_active_ally_once() -> void:
	if _handle_battle_end_guard("auto_action_start"):
		print("[AUTO_STEP_BLOCKED] source=auto_action_start reason=result_finalized")
		return
	if active_unit_state == null:
		return
	if active_unit_side != "ally":
		return
	if current_phase != PHASE_ALLY_TURN:
		return
	if is_demo_animating:
		return
	if not active_unit_state.is_alive():
		return
	if not _is_active_ally_action_available():
		return

	var attack_target := _find_best_auto_attack_target(active_unit_state)
	if attack_target != null and _can_auto_kill_target(active_unit_state, attack_target):
		if _try_auto_attack_for_active_ally():
			return
	if _try_auto_unique_skill_for_actor(active_unit_state, true):
		return
	if _try_auto_attack_for_active_ally():
		return
	if _try_auto_move_for_active_ally():
		return
	if _try_auto_unique_skill_for_actor(active_unit_state, false):
		return
	_auto_wait_active_ally()


func _is_active_ally_action_available() -> bool:
	if active_unit_state == null:
		return false
	if active_unit_side != "ally":
		return false
	if not active_unit_state.is_alive():
		return false
	if _is_unit_confused(active_unit_state):
		return false
	return not _has_ally_unit_acted(active_unit_state)


func _is_active_ally_locked() -> bool:
	if active_unit_state == null:
		return false
	if active_unit_side != "ally":
		return false
	if not active_unit_state.is_alive():
		return false
	if _has_ally_unit_acted(active_unit_state):
		return false
	return (
		active_unit_state.has_moved
		or current_phase == PHASE_FACING_SELECT
		or current_phase == PHASE_ATTACK_SELECT
		or current_phase == PHASE_UNIQUE_SKILL_TARGET_SELECT
		or current_phase == PHASE_STRATEGY_SELECT
	)


func _is_ally_selection_switch_blocked(unit_state: BattleUnitState) -> bool:
	if unit_state == null or unit_state == active_unit_state:
		return false
	return _is_active_ally_locked()


func _is_unit_selectable(unit_state: BattleUnitState) -> bool:
	return _is_unit_state_available_for_battle_slot(unit_state)


func _is_enemy_click_candidate_alive(unit_state: BattleUnitState) -> bool:
	return _is_unit_state_available_for_battle_slot(unit_state)


func _cleanup_dead_units() -> void:
	var defeat_retreat_toast_count := 0
	for unit_state in _get_all_unit_states_in_slot_order():
		if unit_state == null:
			continue
		var is_alive := unit_state.is_alive()
		var is_deployed_alive := _is_unit_state_available_for_battle_slot(unit_state)
		if not is_alive and unit_state.side in ["ally", "enemy"] and not bool(shown_defeat_retreat_toast_unit_ids.get(unit_state.unit_id, false)):
			shown_defeat_retreat_toast_unit_ids[unit_state.unit_id] = true
			if defeat_retreat_toast_count < DEFEAT_RETREAT_TOAST_MAX_QUEUE_PER_CLEANUP:
				_queue_defeat_retreat_toast_snapshot(_make_defeat_retreat_toast_snapshot(unit_state))
				defeat_retreat_toast_count += 1
			else:
				_append_battle_log("%s 전투이탈" % unit_state.display_name)
		_set_unit_visual_group_visible(unit_state, is_deployed_alive)
		_set_unit_click_area_enabled(unit_state, is_deployed_alive)
		if not is_alive and not bool(dead_unit_ids.get(unit_state.unit_id, false)):
			dead_unit_ids[unit_state.unit_id] = true
			acted_ally_unit_ids.erase(unit_state.unit_id)
			acted_enemy_unit_ids.erase(unit_state.unit_id)
			_append_battle_log("%s 전멸" % unit_state.display_name)
			if selected_attack_target_state == unit_state:
				_clear_attack_target_selection()
			if strategy_targeting_caster_state == unit_state:
				_clear_strategy_targeting_state()
				_hide_strategy_range_overlay()
			if pending_move_snapshot_unit_state == unit_state:
				_clear_pending_move_snapshot()
			if active_unit_state == unit_state:
				active_unit_state = null
				_hide_unit_closeup_panel()
	_update_ally_ready_frames()
	_refresh_formation_slot_guides()
	_try_show_battle_result_toast_if_needed()


func _set_unit_visual_group_visible(unit_state: BattleUnitState, should_show: bool) -> void:
	if unit_state == null:
		return
	var slot := _get_unit_visual_slot_for_state(unit_state)
	if slot != null and slot.root != null:
		slot.root.visible = should_show
		var root_color := slot.root.modulate
		if should_show:
			root_color.a = 1.0
		slot.root.modulate = root_color
	if slot != null and slot.has_required_visual_nodes():
		slot.set_visual_group_visible(should_show)
	else:
		for node in _get_visual_group_nodes_for_unit(unit_state):
			if node != null:
				node.visible = should_show
	_restore_unit_visual_group_modulate_for_unit(unit_state, should_show)
	var toast_suppressed := battle_toast_suppresses_facing_indicators or unique_skill_toast_suppresses_facing_indicators
	if slot != null:
		slot.set_facing_indicator_visible(should_show and facing_indicators_should_be_visible and not toast_suppressed and _is_unit_state_deployed_by_capacity_slot(unit_state))
		return
	for node in _get_visual_group_nodes_for_unit(unit_state):
		if node != null:
			node.visible = should_show
	var facing_indicator := _get_facing_indicator_for_unit(unit_state)
	if facing_indicator != null:
		facing_indicator.visible = should_show and facing_indicators_should_be_visible and not toast_suppressed and _is_unit_state_deployed_by_capacity_slot(unit_state)


func _restore_unit_visual_group_modulate_for_unit(unit_state: BattleUnitState, should_show: bool) -> void:
	if unit_state == null:
		return
	var slot := _get_unit_visual_slot_for_state(unit_state)
	if slot == null:
		return
	if slot.shadow != null:
		var shadow_color := slot.shadow.modulate
		if should_show:
			shadow_color.a = 0.28
		slot.shadow.modulate = shadow_color
	if slot.token != null:
		slot.token.modulate = Color.WHITE
	if slot.portrait != null:
		slot.portrait.modulate = Color.WHITE
	if slot.move_dust != null:
		slot.move_dust.visible = false
		var dust_color := slot.move_dust.modulate
		dust_color.a = 0.0
		slot.move_dust.modulate = dust_color


func _set_unit_click_area_enabled(unit_state: BattleUnitState, should_enable: bool) -> void:
	if unit_state == null:
		return
	var slot := _get_unit_visual_slot_for_state(unit_state)
	if slot != null and slot.get_click_area() != null:
		slot.set_click_area_enabled(should_enable)
		return
	var click_area := _get_click_area_for_unit(unit_state)
	if click_area == null:
		return
	click_area.monitoring = should_enable
	click_area.monitorable = should_enable
	click_area.input_pickable = should_enable


func _get_visual_group_nodes_for_unit(unit_state: BattleUnitState) -> Array[CanvasItem]:
	var empty_visual_nodes: Array[CanvasItem] = []
	if unit_state == null:
		return empty_visual_nodes
	var slot := _get_unit_visual_slot_for_state(unit_state)
	if slot != null:
		var slot_nodes := slot.get_visual_group_nodes()
		if not slot_nodes.is_empty():
			return slot_nodes
	if unit_state == ally_unit_state:
		return _get_ally_group_nodes()
	if unit_state == ally_support_unit_state:
		return _get_ally_support_group_nodes()
	if unit_state == ally_main_03_unit_state:
		return _get_ally_main_03_group_nodes()
	if unit_state == ally_reinforce_01_unit_state:
		return _get_ally_reinforce_01_group_nodes()
	if unit_state == ally_reinforce_02_unit_state:
		return _get_ally_reinforce_02_group_nodes()
	if unit_state == enemy_unit_state:
		return _get_enemy_group_nodes()
	if unit_state == enemy_support_unit_state:
		return _get_enemy_support_group_nodes()
	if unit_state == enemy_main_03_unit_state:
		return _get_enemy_main_03_group_nodes()
	if unit_state == enemy_reinforce_01_unit_state:
		return _get_enemy_reinforce_01_group_nodes()
	if unit_state == enemy_reinforce_02_unit_state:
		return _get_enemy_reinforce_02_group_nodes()
	return empty_visual_nodes


func _get_click_area_for_unit(unit_state: BattleUnitState) -> Area2D:
	if unit_state == null:
		return null
	var slot := _get_unit_visual_slot_for_state(unit_state)
	if slot != null and slot.get_click_area() != null:
		return slot.get_click_area()
	if unit_state == ally_unit_state:
		return ally_unit_click_area
	if unit_state == ally_support_unit_state:
		return ally_support_unit_click_area
	if unit_state == ally_main_03_unit_state:
		return ally_main_03_unit_click_area
	if unit_state == ally_reinforce_01_unit_state:
		return ally_reinforce_01_unit_click_area
	if unit_state == ally_reinforce_02_unit_state:
		return ally_reinforce_02_unit_click_area
	if unit_state == enemy_unit_state:
		return enemy_unit_click_area
	if unit_state == enemy_support_unit_state:
		return enemy_support_unit_click_area
	if unit_state == enemy_main_03_unit_state:
		return enemy_main_03_unit_click_area
	if unit_state == enemy_reinforce_01_unit_state:
		return enemy_reinforce_01_unit_click_area
	if unit_state == enemy_reinforce_02_unit_state:
		return enemy_reinforce_02_unit_click_area
	return null


func _get_click_shape_for_unit(unit_state: BattleUnitState) -> CollisionShape2D:
	if unit_state == null:
		return null
	var slot := _get_unit_visual_slot_for_state(unit_state)
	if slot != null and slot.get_click_shape() != null:
		return slot.get_click_shape()
	if unit_state == ally_unit_state:
		return ally_unit_click_shape
	if unit_state == ally_support_unit_state:
		return ally_support_unit_click_shape
	if unit_state == ally_main_03_unit_state:
		return ally_main_03_unit_click_shape
	if unit_state == ally_reinforce_01_unit_state:
		return ally_reinforce_01_unit_click_shape
	if unit_state == ally_reinforce_02_unit_state:
		return ally_reinforce_02_unit_click_shape
	if unit_state == enemy_unit_state:
		return enemy_unit_click_shape
	if unit_state == enemy_support_unit_state:
		return enemy_support_unit_click_shape
	if unit_state == enemy_main_03_unit_state:
		return enemy_main_03_unit_click_shape
	if unit_state == enemy_reinforce_01_unit_state:
		return enemy_reinforce_01_unit_click_shape
	if unit_state == enemy_reinforce_02_unit_state:
		return enemy_reinforce_02_unit_click_shape
	return null


func _get_ready_frame_for_unit(unit_state: BattleUnitState) -> Control:
	if unit_state == null:
		return null
	var slot := _get_unit_visual_slot_for_state(unit_state)
	if slot != null and slot.get_ready_frame() != null:
		return slot.get_ready_frame()
	var slot_visuals := _get_unit_visual_slots_for_state(unit_state)
	return slot_visuals.get("ready_frame", null) as Control


func _get_facing_indicator_for_unit(unit_state: BattleUnitState) -> Label:
	if unit_state == null:
		return null
	var slot := _get_unit_visual_slot_for_state(unit_state)
	if slot != null and slot.get_facing_indicator() != null:
		return slot.get_facing_indicator()
	var slot_visuals := _get_unit_visual_slots_for_state(unit_state)
	return slot_visuals.get("facing_indicator", null) as Label


func _get_all_unit_states_in_slot_order() -> Array[BattleUnitState]:
	return [
		ally_unit_state,
		ally_support_unit_state,
		ally_main_03_unit_state,
		ally_reinforce_01_unit_state,
		ally_reinforce_02_unit_state,
		enemy_unit_state,
		enemy_support_unit_state,
		enemy_main_03_unit_state,
		enemy_reinforce_01_unit_state,
		enemy_reinforce_02_unit_state,
	]


func _get_ally_main_03_visual_anchor_position() -> Vector2:
	if ally_main_03_unit_marker == null:
		return Vector2.ZERO
	return _get_ally_visual_anchor_from_position(ally_main_03_unit_marker.position)


func _get_enemy_main_03_visual_anchor_position() -> Vector2:
	if enemy_main_03_unit_marker == null:
		return Vector2.ZERO
	return _get_enemy_visual_anchor_from_position(enemy_main_03_unit_marker.position)


func _get_ally_reinforce_01_visual_anchor_position() -> Vector2:
	if ally_reinforce_01_unit_marker == null:
		return Vector2.ZERO
	return _get_ally_visual_anchor_from_position(ally_reinforce_01_unit_marker.position)


func _get_enemy_reinforce_01_visual_anchor_position() -> Vector2:
	if enemy_reinforce_01_unit_marker == null:
		return Vector2.ZERO
	return _get_enemy_visual_anchor_from_position(enemy_reinforce_01_unit_marker.position)


func _get_ally_reinforce_02_visual_anchor_position() -> Vector2:
	if ally_reinforce_02_unit_marker == null:
		return Vector2.ZERO
	return _get_ally_visual_anchor_from_position(ally_reinforce_02_unit_marker.position)


func _get_enemy_reinforce_02_visual_anchor_position() -> Vector2:
	if enemy_reinforce_02_unit_marker == null:
		return Vector2.ZERO
	return _get_enemy_visual_anchor_from_position(enemy_reinforce_02_unit_marker.position)


func _get_visual_anchor_position_for_unit(unit_state: BattleUnitState) -> Vector2:
	if unit_state == null:
		return Vector2.ZERO
	if unit_state.slot_id != "":
		match unit_state.slot_id:
			"ally_main":
				return _get_ally_visual_anchor_position()
			"ally_support":
				return _get_ally_support_visual_anchor_position()
			"ally_main_03":
				return _get_ally_main_03_visual_anchor_position()
			"ally_reinforce_01":
				return _get_ally_reinforce_01_visual_anchor_position()
			"ally_reinforce_02":
				return _get_ally_reinforce_02_visual_anchor_position()
			"enemy_main":
				return _get_enemy_visual_anchor_position()
			"enemy_support":
				return _get_enemy_support_visual_anchor_position()
			"enemy_main_03":
				return _get_enemy_main_03_visual_anchor_position()
			"enemy_reinforce_01":
				return _get_enemy_reinforce_01_visual_anchor_position()
			"enemy_reinforce_02":
				return _get_enemy_reinforce_02_visual_anchor_position()
	if unit_state == ally_unit_state:
		return _get_ally_visual_anchor_position()
	if unit_state == ally_support_unit_state:
		return _get_ally_support_visual_anchor_position()
	if unit_state == ally_main_03_unit_state:
		return _get_ally_main_03_visual_anchor_position()
	if unit_state == ally_reinforce_01_unit_state:
		return _get_ally_reinforce_01_visual_anchor_position()
	if unit_state == ally_reinforce_02_unit_state:
		return _get_ally_reinforce_02_visual_anchor_position()
	if unit_state == enemy_unit_state:
		return _get_enemy_visual_anchor_position()
	if unit_state == enemy_support_unit_state:
		return _get_enemy_support_visual_anchor_position()
	if unit_state == enemy_main_03_unit_state:
		return _get_enemy_main_03_visual_anchor_position()
	if unit_state == enemy_reinforce_01_unit_state:
		return _get_enemy_reinforce_01_visual_anchor_position()
	if unit_state == enemy_reinforce_02_unit_state:
		return _get_enemy_reinforce_02_visual_anchor_position()
	return Vector2.ZERO


func _refresh_facing_indicator_for_unit(unit_state: BattleUnitState) -> void:
	var facing_indicator := _get_facing_indicator_for_unit(unit_state)
	if unit_state == null or facing_indicator == null:
		return
	facing_indicator.text = _get_facing_arrow_text(unit_state.facing)
	var toast_suppressed := battle_toast_suppresses_facing_indicators or unique_skill_toast_suppresses_facing_indicators
	facing_indicator.visible = facing_indicators_should_be_visible and not toast_suppressed and _is_unit_state_available_for_battle_slot(unit_state)
	_position_facing_indicator_for_unit(unit_state)


func _hide_facing_indicator_for_unit(unit_state: BattleUnitState) -> void:
	var facing_indicator := _get_facing_indicator_for_unit(unit_state)
	if unit_state == null or facing_indicator == null:
		return
	facing_indicator.visible = false


func _position_facing_indicator_for_unit(unit_state: BattleUnitState) -> void:
	if unit_state == null:
		return
	if unit_state.slot_id != "":
		match unit_state.slot_id:
			"ally_main":
				_position_facing_indicator_for_ally()
				return
			"ally_support":
				_position_facing_indicator_for_ally_support()
				return
			"ally_main_03":
				_position_facing_indicator_for_ally_main_03()
				return
			"ally_reinforce_01":
				_position_facing_indicator_for_ally_reinforce_01()
				return
			"ally_reinforce_02":
				_position_facing_indicator_for_ally_reinforce_02()
				return
			"enemy_main":
				_position_facing_indicator_for_enemy()
				return
			"enemy_support":
				_position_facing_indicator_for_enemy_support()
				return
			"enemy_main_03":
				_position_facing_indicator_for_enemy_main_03()
				return
			"enemy_reinforce_01":
				_position_facing_indicator_for_enemy_reinforce_01()
				return
			"enemy_reinforce_02":
				_position_facing_indicator_for_enemy_reinforce_02()
				return
	if unit_state == ally_unit_state:
		_position_facing_indicator_for_ally()
		return
	if unit_state == ally_support_unit_state:
		_position_facing_indicator_for_ally_support()
		return
	if unit_state == ally_main_03_unit_state:
		_position_facing_indicator_for_ally_main_03()
		return
	if unit_state == ally_reinforce_01_unit_state:
		_position_facing_indicator_for_ally_reinforce_01()
		return
	if unit_state == ally_reinforce_02_unit_state:
		_position_facing_indicator_for_ally_reinforce_02()
		return
	if unit_state == enemy_unit_state:
		_position_facing_indicator_for_enemy()
		return
	if unit_state == enemy_support_unit_state:
		_position_facing_indicator_for_enemy_support()
		return
	if unit_state == enemy_main_03_unit_state:
		_position_facing_indicator_for_enemy_main_03()
		return
	if unit_state == enemy_reinforce_01_unit_state:
		_position_facing_indicator_for_enemy_reinforce_01()
		return
	if unit_state == enemy_reinforce_02_unit_state:
		_position_facing_indicator_for_enemy_reinforce_02()
		return


func set_move_target_cell(cell: Vector2i) -> void:
	if battle_grid_controller == null:
		return
	if move_target_marker == null:
		return
	if not battle_grid_controller.is_in_bounds(cell):
		return
	if not _is_valid_destination_for_unit(cell, active_unit_state, true):
		_append_battle_log("다른 부대가 있어 이동할 수 없습니다")
		return
	if not is_valid_move_target(cell):
		return

	var world_pos := battle_grid_controller.grid_to_world(cell)
	if move_target_marker.get_parent() is Node2D:
		move_target_marker.position = (move_target_marker.get_parent() as Node2D).to_local(world_pos)
	else:
		move_target_marker.global_position = world_pos

	selected_move_cell = cell
	has_selected_move_target = true
	_refresh_move_target_feedback()


func _select_ally_unit(
	unit_state: BattleUnitState,
	should_log: bool = true,
	should_open_command_panel: bool = true,
	should_pulse_turn_start: bool = false
) -> void:
	if not _is_unit_selectable(unit_state):
		return
	if _is_ally_selection_switch_blocked(unit_state):
		return

	active_unit_state = unit_state
	is_floating_ally_command_panel_requested = should_open_command_panel
	_update_cell_size_visual_guide(active_unit_state.grid_cell)
	active_unit_side = "ally"
	ally_has_moved = active_unit_state.has_moved
	_clear_move_target_selection()
	_clear_attack_target_selection()
	_show_unit_closeup_for_ally(active_unit_state)
	_focus_camera_on_unit(active_unit_state)
	_update_ally_ready_frames()
	if should_log:
		_append_battle_log("%s 선택" % _get_selected_ally_display_name())
	if _has_ally_unit_acted(active_unit_state):
		_hide_move_range_overlay()
		_append_battle_log("이미 행동한 부대입니다")
		_set_phase(PHASE_ALLY_TURN)
		_update_ally_ready_frames()
		return
	_refresh_move_target_feedback()
	_show_move_range_overlay_for_active_unit()
	_set_phase(PHASE_ALLY_TURN)
	if should_pulse_turn_start:
		_play_active_ally_turn_pulse(active_unit_state)
	_update_ally_ready_frames()


func _select_enemy_attack_target(target_state: BattleUnitState) -> void:
	if target_state == null:
		return
	if not target_state.is_alive():
		return

	selected_attack_target_state = target_state
	selected_attack_target_side = "enemy"
	_clear_move_target_selection()
	_append_battle_log("%s 공격 대상 선택" % target_state.display_name)
	_show_attack_target_feedback()


func _clear_attack_target_selection() -> void:
	selected_attack_target_state = null
	selected_attack_target_side = ""
	current_attack_animation_target_state = null
	if attack_highlight != null:
		attack_highlight.visible = false


func _show_attack_target_feedback() -> void:
	if attack_highlight == null:
		return
	if selected_attack_target_state == null:
		return

	var highlight_size := MOVE_HIGHLIGHT_SIZE
	var target_marker := _get_enemy_target_unit_marker(selected_attack_target_state)
	var world_pos := Vector2.ZERO
	if target_marker != null:
		world_pos = target_marker.position
	if battle_grid_controller != null:
		var cell_size := battle_grid_controller.get_cell_size()
		if cell_size.x > 0.0 and cell_size.y > 0.0:
			highlight_size = cell_size
		world_pos = battle_grid_controller.grid_to_world(selected_attack_target_state.grid_cell)

	var highlight_pos := world_pos - (highlight_size * 0.5)
	if attack_highlight.get_parent() is Node2D:
		var parent_node := attack_highlight.get_parent() as Node2D
		highlight_pos = parent_node.to_local(world_pos) - (highlight_size * 0.5)

	attack_highlight.position = highlight_pos
	attack_highlight.size = highlight_size
	attack_highlight.visible = true


func _is_click_inside_unit_click_area(unit_state: BattleUnitState, mouse_pos: Vector2) -> bool:
	var click_area := _get_click_area_for_unit(unit_state)
	var click_shape := _get_click_shape_for_unit(unit_state)
	if click_area == null or click_shape == null or click_shape.shape == null:
		return false
	if not click_area.input_pickable:
		return false

	var local_pos := click_area.to_local(mouse_pos) - click_shape.position
	if click_shape.shape is RectangleShape2D:
		var rect_shape := click_shape.shape as RectangleShape2D
		return Rect2(-rect_shape.size * 0.5, rect_shape.size).has_point(local_pos)
	if click_shape.shape is CircleShape2D:
		var circle_shape := click_shape.shape as CircleShape2D
		return local_pos.length() <= circle_shape.radius
	return false


func _get_clicked_ally_unit_at_position(mouse_pos: Vector2) -> BattleUnitState:
	var hit_candidates: Array[BattleUnitState] = []
	for unit_state in _get_alive_ally_units():
		if _is_click_inside_unit_click_area(unit_state, mouse_pos):
			hit_candidates.append(unit_state)
	if hit_candidates.is_empty():
		return null
	return _get_closest_unit_state_to_click_position(hit_candidates, mouse_pos)


func _get_clicked_enemy_unit_at_position(mouse_pos: Vector2) -> BattleUnitState:
	var hit_candidates: Array[BattleUnitState] = []
	for unit_state in _get_alive_enemy_units():
		if _is_click_inside_unit_click_area(unit_state, mouse_pos):
			hit_candidates.append(unit_state)
	if hit_candidates.is_empty():
		return null
	var selected_unit_state := _get_closest_unit_state_to_click_position(hit_candidates, mouse_pos)
	_debug_log_enemy_click_binding(selected_unit_state)
	return selected_unit_state


func _get_closest_unit_state_to_click_position(candidates: Array[BattleUnitState], mouse_pos: Vector2) -> BattleUnitState:
	var selected_unit_state: BattleUnitState = null
	var selected_distance := INF
	for unit_state in candidates:
		if unit_state == null:
			continue
		var marker := _get_unit_marker_for_unit(unit_state)
		var marker_position := _get_visual_anchor_position_for_unit(unit_state)
		if marker != null:
			marker_position = marker.global_position
		var distance_to_click := marker_position.distance_squared_to(mouse_pos)
		if selected_unit_state == null or distance_to_click < selected_distance:
			selected_unit_state = unit_state
			selected_distance = distance_to_click
	return selected_unit_state


func _debug_log_enemy_click_binding(unit_state: BattleUnitState) -> void:
	if unit_state == null:
		return
	var capacity_slot_id := _get_capacity_slot_id_for_unit_state(unit_state)
	var click_area := _get_click_area_for_unit(unit_state)
	var slot := _get_unit_visual_slot_for_state(unit_state)
	var portrait: Sprite2D = null
	if slot != null and slot.portrait is Sprite2D:
		portrait = slot.portrait as Sprite2D
	var portrait_path := ""
	if portrait != null and portrait.texture != null:
		portrait_path = portrait.texture.resource_path
	var marker := _get_unit_marker_for_unit(unit_state)
	var click_area_name := ""
	var click_area_position := Vector2.ZERO
	if click_area != null:
		click_area_name = click_area.name
		click_area_position = click_area.global_position
	var marker_name := ""
	var marker_position_text := Vector2.ZERO
	if marker != null:
		marker_name = marker.name
		marker_position_text = marker.global_position
	print("[ENEMY_CLICK] name=%s slot=%s click_area=%s click_pos=%s portrait=%s marker=%s marker_pos=%s" % [
		unit_state.display_name,
		capacity_slot_id,
		click_area_name,
		str(click_area_position),
		portrait_path,
		marker_name,
		str(marker_position_text),
	])


func _is_click_inside_ally_support_click_area(mouse_pos: Vector2) -> bool:
	if ally_support_unit_click_area == null:
		return false
	if ally_support_unit_click_shape == null:
		return false
	if ally_support_unit_click_shape.shape == null:
		return false

	var local_pos := ally_support_unit_click_area.to_local(mouse_pos)
	local_pos -= ally_support_unit_click_shape.position
	if ally_support_unit_click_shape.shape is RectangleShape2D:
		var rect_shape := ally_support_unit_click_shape.shape as RectangleShape2D
		return Rect2(-rect_shape.size * 0.5, rect_shape.size).has_point(local_pos)
	if ally_support_unit_click_shape.shape is CircleShape2D:
		var circle_shape := ally_support_unit_click_shape.shape as CircleShape2D
		return local_pos.length() <= circle_shape.radius
	return false


func _is_click_inside_enemy_support_click_area(mouse_pos: Vector2) -> bool:
	if enemy_support_unit_click_area == null:
		return false
	if enemy_support_unit_click_shape == null:
		return false
	if enemy_support_unit_click_shape.shape == null:
		return false

	var local_pos := enemy_support_unit_click_area.to_local(mouse_pos)
	local_pos -= enemy_support_unit_click_shape.position
	if enemy_support_unit_click_shape.shape is RectangleShape2D:
		var rect_shape := enemy_support_unit_click_shape.shape as RectangleShape2D
		return Rect2(-rect_shape.size * 0.5, rect_shape.size).has_point(local_pos)
	if enemy_support_unit_click_shape.shape is CircleShape2D:
		var circle_shape := enemy_support_unit_click_shape.shape as CircleShape2D
		return local_pos.length() <= circle_shape.radius
	return false


func _update_cell_size_visual_guide(center_cell: Vector2i) -> void:
	if not SHOW_CELL_SIZE_VISUAL_GUIDE:
		if cell_guide_layer != null:
			cell_guide_layer.visible = false
		return

	if battle_grid_controller == null:
		return
	if cell_guide_current == null:
		return

	if cell_guide_layer != null:
		cell_guide_layer.visible = true

	var cell_size := battle_grid_controller.get_cell_size()
	if cell_size.x <= 0.0 or cell_size.y <= 0.0:
		return

	_place_cell_guide_rect(cell_guide_current, center_cell, cell_size)

	var right_cell := center_cell + Vector2i(1, 0)
	if cell_guide_right != null and battle_grid_controller.is_in_bounds(right_cell):
		_place_cell_guide_rect(cell_guide_right, right_cell, cell_size)
	elif cell_guide_right != null:
		cell_guide_right.visible = false

	var down_cell := center_cell + Vector2i(0, 1)
	if cell_guide_down != null and battle_grid_controller.is_in_bounds(down_cell):
		_place_cell_guide_rect(cell_guide_down, down_cell, cell_size)
	elif cell_guide_down != null:
		cell_guide_down.visible = false

	if cell_guide_label != null:
		var enemy_cell_text := "null"
		var distance_text := "?"
		if enemy_unit_state != null:
			enemy_cell_text = str(enemy_unit_state.grid_cell)
		if ally_unit_state != null and enemy_unit_state != null:
			distance_text = str(get_unit_grid_distance(ally_unit_state, enemy_unit_state))
		cell_guide_label.text = "ally=%s enemy=%s dist=%s size=%s" % [center_cell, enemy_cell_text, distance_text, cell_size]
		var label_world_pos := battle_grid_controller.grid_to_world(center_cell) + Vector2(0, -cell_size.y * 0.75)
		if cell_guide_label.get_parent() is Node2D:
			cell_guide_label.position = (cell_guide_label.get_parent() as Node2D).to_local(label_world_pos)
		else:
			cell_guide_label.global_position = label_world_pos


func _update_logical_grid_guide() -> void:
	if logical_grid_guide_layer == null:
		return

	logical_grid_guide_layer.visible = SHOW_LOGICAL_GRID_14X8_GUIDE
	if not SHOW_LOGICAL_GRID_14X8_GUIDE:
		return
	if battle_grid_controller == null:
		return

	var top_left := battle_grid_controller.get_board_top_left()
	var bottom_right := battle_grid_controller.get_board_bottom_right()
	var cell_size := battle_grid_controller.get_cell_size()

	for x in range(battle_grid_controller.grid_width + 1):
		var line := logical_grid_guide_layer.get_node_or_null("GridVertical_%02d" % x) as Line2D
		if line == null:
			continue
		var wx := top_left.x + cell_size.x * float(x)
		var p1 := Vector2(wx, top_left.y)
		var p2 := Vector2(wx, bottom_right.y)
		line.points = PackedVector2Array([
			logical_grid_guide_layer.to_local(p1),
			logical_grid_guide_layer.to_local(p2)
		])
		line.visible = true

	for y in range(battle_grid_controller.grid_height + 1):
		var line := logical_grid_guide_layer.get_node_or_null("GridHorizontal_%02d" % y) as Line2D
		if line == null:
			continue
		var wy := top_left.y + cell_size.y * float(y)
		var p1 := Vector2(top_left.x, wy)
		var p2 := Vector2(bottom_right.x, wy)
		line.points = PackedVector2Array([
			logical_grid_guide_layer.to_local(p1),
			logical_grid_guide_layer.to_local(p2)
		])
		line.visible = true


func _place_cell_guide_rect(rect: ColorRect, cell: Vector2i, cell_size: Vector2) -> void:
	if rect == null:
		return
	if battle_grid_controller == null:
		rect.visible = false
		return
	if not battle_grid_controller.is_in_bounds(cell):
		rect.visible = false
		return

	var world_pos := battle_grid_controller.grid_to_world(cell)
	if rect.get_parent() is Node2D:
		rect.position = (rect.get_parent() as Node2D).to_local(world_pos) - (cell_size * 0.5)
	else:
		rect.global_position = world_pos - (cell_size * 0.5)

	rect.size = cell_size
	rect.visible = true


func _get_ally_click_area_local_position(mouse_pos: Vector2) -> Vector2:
	if ally_unit_click_area == null:
		return Vector2.ZERO

	var local_pos := ally_unit_click_area.to_local(mouse_pos)
	if ally_unit_click_shape != null:
		local_pos -= ally_unit_click_shape.position
	return local_pos


func _is_click_inside_ally_click_area(mouse_pos: Vector2) -> bool:
	if ally_unit_click_area == null:
		return false
	if ally_unit_click_shape == null:
		return false
	if ally_unit_click_shape.shape == null:
		return false

	var local_pos := _get_ally_click_area_local_position(mouse_pos)
	if ally_unit_click_shape.shape is RectangleShape2D:
		var rect_shape := ally_unit_click_shape.shape as RectangleShape2D
		var half_size := rect_shape.size * 0.5
		return absf(local_pos.x) <= half_size.x and absf(local_pos.y) <= half_size.y

	if ally_unit_click_shape.shape is CircleShape2D:
		var circle_shape := ally_unit_click_shape.shape as CircleShape2D
		return local_pos.length() <= circle_shape.radius

	return false


func _get_enemy_click_area_local_position(mouse_pos: Vector2) -> Vector2:
	if enemy_unit_click_area == null:
		return Vector2.ZERO

	var local_pos := enemy_unit_click_area.to_local(mouse_pos)
	if enemy_unit_click_shape != null:
		local_pos -= enemy_unit_click_shape.position
	return local_pos


func _is_click_inside_enemy_click_area(mouse_pos: Vector2) -> bool:
	if enemy_unit_click_area == null:
		return false
	if enemy_unit_click_shape == null:
		return false
	if enemy_unit_click_shape.shape == null:
		return false

	var local_pos := _get_enemy_click_area_local_position(mouse_pos)
	if enemy_unit_click_shape.shape is RectangleShape2D:
		var rect_shape := enemy_unit_click_shape.shape as RectangleShape2D
		var half_size := rect_shape.size * 0.5
		return absf(local_pos.x) <= half_size.x and absf(local_pos.y) <= half_size.y

	return false


func _is_valid_grid_cell(cell: Vector2i) -> bool:
	return battle_grid_controller.is_in_bounds(cell)


func is_cell_occupied(cell: Vector2i) -> bool:
	for unit_state in _get_all_alive_unit_states():
		if unit_state.grid_cell == cell:
			return true
	return false


func get_active_move_origin_cell() -> Vector2i:
	if active_unit_state == null:
		return Vector2i.ZERO
	return active_unit_state.grid_cell


func get_active_move_range() -> int:
	if active_unit_state == null:
		return 0
	return active_unit_state.move_range


func _get_all_alive_unit_states() -> Array[BattleUnitState]:
	var adapter_alive_units := _get_all_alive_unit_states_from_adapter()
	if _is_battle_unit_state_adapter_ready() and not adapter_alive_units.is_empty():
		return adapter_alive_units
	return _get_fallback_all_alive_unit_states()


func _get_fallback_all_alive_unit_states() -> Array[BattleUnitState]:
	var alive_units: Array[BattleUnitState] = []
	var unit_candidates: Array = [
		ally_unit_state,
		ally_support_unit_state,
		ally_main_03_unit_state,
		ally_reinforce_01_unit_state,
		ally_reinforce_02_unit_state,
		enemy_unit_state,
		enemy_support_unit_state,
		enemy_main_03_unit_state,
		enemy_reinforce_01_unit_state,
		enemy_reinforce_02_unit_state,
	]
	for candidate in unit_candidates:
		var unit_state := candidate as BattleUnitState
		if _is_unit_state_available_for_battle_slot(unit_state):
			alive_units.append(unit_state)
	return alive_units


func _get_occupied_cells_except(unit_state: BattleUnitState) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	if ALLOW_BREAKTHROUGH_MOVE:
		return cells
	for alive_unit_state in _get_all_alive_unit_states():
		if alive_unit_state == unit_state:
			continue
		cells.append(alive_unit_state.grid_cell)
	return cells


func _is_cell_occupied_except(cell: Vector2i, unit_state: BattleUnitState) -> bool:
	for occupied_cell in _get_occupied_cells_except(unit_state):
		if occupied_cell == cell:
			return true
	return false


func _get_occupied_cells_for_move() -> Array[Vector2i]:
	return _get_occupied_cells_except(active_unit_state)


func _is_cell_occupied_for_move(cell: Vector2i) -> bool:
	return _is_cell_occupied_except(cell, active_unit_state)


func _is_valid_destination_for_unit(target_cell: Vector2i, mover_state: BattleUnitState, should_log: bool = false) -> bool:
	if mover_state == null:
		return false
	if battle_grid_controller == null:
		return false
	if not battle_grid_controller.is_in_bounds(target_cell):
		return false
	if _is_cell_occupied_except(target_cell, mover_state):
		if should_log:
			print("[OCCUPIED BLOCK] mover=%s target=%s occupied_by_other=true" % [
				mover_state.display_name,
				target_cell,
			])
		return false
	return true


func _is_path_clear_for_unit(path: Array[Vector2i], mover_state: BattleUnitState, should_log: bool = false) -> bool:
	if mover_state == null:
		return false
	if path.is_empty():
		return false

	for index in range(path.size()):
		if index == 0:
			continue
		var cell := path[index]
		if _is_cell_occupied_except(cell, mover_state):
			if should_log:
				print("[PATH BLOCK] mover=%s blocked_cell=%s" % [
					mover_state.display_name,
					cell,
				])
			return false
	return true


func _is_cell_walkable_for_ally(cell: Vector2i, start_cell: Vector2i) -> bool:
	if battle_grid_controller == null:
		return false
	if not battle_grid_controller.is_in_bounds(cell):
		return false
	if cell == start_cell:
		return true
	if _is_cell_occupied_except(cell, active_unit_state):
		return false
	return true


func _find_ally_move_path(start_cell: Vector2i, target_cell: Vector2i) -> Array[Vector2i]:
	var empty_path: Array[Vector2i] = []
	if battle_grid_controller == null:
		return empty_path
	if start_cell == target_cell:
		return [start_cell]
	if not _is_valid_destination_for_unit(target_cell, active_unit_state):
		return empty_path
	if not _is_cell_walkable_for_ally(target_cell, start_cell):
		return empty_path

	var max_steps := get_active_move_range()
	var frontier: Array[Vector2i] = [start_cell]
	var came_from: Dictionary = {start_cell: start_cell}
	var steps_from_start: Dictionary = {start_cell: 0}
	var directions: Array[Vector2i] = [
		Vector2i(1, 0),
		Vector2i(-1, 0),
		Vector2i(0, 1),
		Vector2i(0, -1),
	]

	while not frontier.is_empty():
		var current: Vector2i = frontier.pop_front()
		if current == target_cell:
			break

		var current_steps: int = steps_from_start.get(current, 0)
		if current_steps >= max_steps:
			continue

		for direction in directions:
			var next: Vector2i = current + direction
			if came_from.has(next):
				continue
			if not _is_cell_walkable_for_ally(next, start_cell):
				continue
			came_from[next] = current
			steps_from_start[next] = current_steps + 1
			frontier.append(next)

	if not came_from.has(target_cell):
		return empty_path

	var path: Array[Vector2i] = []
	var cursor: Vector2i = target_cell
	while cursor != start_cell:
		path.push_front(cursor)
		cursor = came_from[cursor]
	path.push_front(start_cell)

	if path.size() - 1 > max_steps:
		return empty_path
	if not _is_path_clear_for_unit(path, active_unit_state):
		return empty_path
	return path


func _get_occupied_cells_for_enemy_move() -> Array[Vector2i]:
	var actor_state := enemy_unit_state
	if current_enemy_ai_actor_state != null:
		actor_state = current_enemy_ai_actor_state
	return _get_occupied_cells_except(actor_state)


func _is_cell_walkable_for_enemy(cell: Vector2i, start_cell: Vector2i) -> bool:
	return _is_cell_walkable_for_enemy_actor(enemy_unit_state, cell, start_cell)


func _is_cell_walkable_for_enemy_actor(enemy_actor_state: BattleUnitState, cell: Vector2i, start_cell: Vector2i) -> bool:
	if battle_grid_controller == null:
		return false
	if not battle_grid_controller.is_in_bounds(cell):
		return false
	if cell == start_cell:
		return true
	if _is_cell_occupied_except(cell, enemy_actor_state):
		return false
	return true


func _find_enemy_move_path(start_cell: Vector2i, target_cell: Vector2i) -> Array[Vector2i]:
	return _find_enemy_move_path_for_actor(enemy_unit_state, start_cell, target_cell)


func _find_enemy_move_path_for_actor(enemy_actor_state: BattleUnitState, start_cell: Vector2i, target_cell: Vector2i) -> Array[Vector2i]:
	var actor_move_range := 0
	if enemy_actor_state != null:
		actor_move_range = enemy_actor_state.move_range
	return _find_enemy_path_to_destination_for_actor(enemy_actor_state, start_cell, target_cell, actor_move_range)


func _find_enemy_path_to_destination_for_actor(enemy_actor_state: BattleUnitState, start_cell: Vector2i, target_cell: Vector2i, max_steps_override: int = -1) -> Array[Vector2i]:
	var empty_path: Array[Vector2i] = []
	if battle_grid_controller == null:
		return empty_path
	if enemy_actor_state == null:
		return empty_path
	if start_cell == target_cell:
		return [start_cell]
	if not _is_valid_destination_for_unit(target_cell, enemy_actor_state):
		return empty_path
	if not _is_cell_walkable_for_enemy_actor(enemy_actor_state, target_cell, start_cell):
		return empty_path

	var max_steps := enemy_actor_state.move_range
	if max_steps_override >= 0:
		max_steps = max_steps_override
	var frontier: Array[Vector2i] = [start_cell]
	var came_from: Dictionary = {start_cell: start_cell}
	var steps_from_start: Dictionary = {start_cell: 0}
	var directions: Array[Vector2i] = [
		Vector2i(1, 0),
		Vector2i(-1, 0),
		Vector2i(0, 1),
		Vector2i(0, -1),
	]

	while not frontier.is_empty():
		var current: Vector2i = frontier.pop_front()
		if current == target_cell:
			break

		var current_steps: int = steps_from_start.get(current, 0)
		if current_steps >= max_steps:
			continue

		for direction in directions:
			var next: Vector2i = current + direction
			if came_from.has(next):
				continue
			if not _is_cell_walkable_for_enemy_actor(enemy_actor_state, next, start_cell):
				continue
			came_from[next] = current
			steps_from_start[next] = current_steps + 1
			frontier.append(next)

	if not came_from.has(target_cell):
		return empty_path

	var path: Array[Vector2i] = []
	var cursor: Vector2i = target_cell
	while cursor != start_cell:
		path.push_front(cursor)
		cursor = came_from[cursor]
	path.push_front(start_cell)

	if path.size() - 1 > max_steps:
		return empty_path
	if not _is_path_clear_for_unit(path, enemy_actor_state):
		return empty_path
	return path


func _get_enemy_reachable_paths(start_cell: Vector2i) -> Dictionary:
	return _get_enemy_reachable_paths_for_actor(enemy_unit_state, start_cell)


func _get_enemy_reachable_paths_for_actor(enemy_actor_state: BattleUnitState, start_cell: Vector2i) -> Dictionary:
	var reachable_paths: Dictionary = {}
	if battle_grid_controller == null or enemy_actor_state == null:
		return reachable_paths

	var frontier: Array[Vector2i] = [start_cell]
	var came_from: Dictionary = {start_cell: start_cell}
	var steps_from_start: Dictionary = {start_cell: 0}
	var max_steps := enemy_actor_state.move_range
	var directions: Array[Vector2i] = [
		Vector2i(1, 0),
		Vector2i(-1, 0),
		Vector2i(0, 1),
		Vector2i(0, -1),
	]

	while not frontier.is_empty():
		var current: Vector2i = frontier.pop_front()
		var current_steps: int = steps_from_start.get(current, 0)
		if current_steps >= max_steps:
			continue

		for direction in directions:
			var next: Vector2i = current + direction
			if came_from.has(next):
				continue
			if not _is_cell_walkable_for_enemy_actor(enemy_actor_state, next, start_cell):
				continue
			came_from[next] = current
			steps_from_start[next] = current_steps + 1
			frontier.append(next)

	for cell_variant in came_from.keys():
		var cell: Vector2i = cell_variant
		if not _is_valid_destination_for_unit(cell, enemy_actor_state):
			continue
		var path: Array[Vector2i] = []
		var cursor: Vector2i = cell
		while cursor != start_cell:
			path.push_front(cursor)
			cursor = came_from[cursor]
		path.push_front(start_cell)
		if not _is_path_clear_for_unit(path, enemy_actor_state):
			continue
		reachable_paths[cell] = path

	return reachable_paths


func _choose_enemy_basic_ai_destination() -> Vector2i:
	return _choose_enemy_basic_ai_destination_for_actor(enemy_unit_state, _get_enemy_ai_target_state_for_actor(enemy_unit_state))


func _choose_enemy_basic_ai_destination_for_actor(enemy_actor_state: BattleUnitState, target_state: BattleUnitState) -> Vector2i:
	var decision_plan := _get_enemy_ai_decision_plan_for_actor(enemy_actor_state, target_state)
	enemy_ai_last_destination_debug = decision_plan.duplicate(true)
	if enemy_actor_state == null:
		return Vector2i.ZERO
	return decision_plan.get("destination", enemy_actor_state.grid_cell)


func _should_enemy_use_surround_pressure_mode() -> bool:
	var alive_ally_count := _get_alive_deployed_unit_states_for_side("ally").size()
	var alive_enemy_count := _get_alive_deployed_unit_states_for_side("enemy").size()
	return alive_ally_count <= 2 and alive_enemy_count > alive_ally_count


func _get_surround_candidate_cells_around_target(target_state: BattleUnitState) -> Array[Vector2i]:
	return _get_enemy_engagement_candidate_cells(target_state, enemy_unit_state)


func _get_enemy_engagement_candidate_cells(target_state: BattleUnitState, enemy_actor_state: BattleUnitState) -> Array[Vector2i]:
	var candidate_cells: Array[Vector2i] = []
	if target_state == null or battle_grid_controller == null or enemy_actor_state == null:
		return candidate_cells
	var origin := target_state.grid_cell
	var seen: Dictionary = {}
	var max_attack_distance := maxi(1, enemy_actor_state.attack_range)
	for offset_x in range(-max_attack_distance, max_attack_distance + 1):
		for offset_y in range(-max_attack_distance, max_attack_distance + 1):
			if offset_x == 0 and offset_y == 0:
				continue
			var candidate := origin + Vector2i(offset_x, offset_y)
			if seen.has(candidate):
				continue
			seen[candidate] = true
			if not battle_grid_controller.is_in_bounds(candidate):
				continue
			if candidate == target_state.grid_cell:
				continue
			var candidate_distance := absi(candidate.x - origin.x) + absi(candidate.y - origin.y)
			if enemy_actor_state.attack_range <= 1:
				var is_adjacent_ring := absi(offset_x) <= 1 and absi(offset_y) <= 1
				if not is_adjacent_ring:
					continue
			elif candidate_distance <= 0 or candidate_distance > enemy_actor_state.attack_range:
				continue
			if candidate != enemy_actor_state.grid_cell and _is_cell_occupied_except(candidate, enemy_actor_state):
				continue
			if _is_enemy_ai_engagement_cell_reserved_for_other_actor(candidate, enemy_actor_state):
				continue
			candidate_cells.append(candidate)
	candidate_cells.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		var a_distance := absi(a.x - origin.x) + absi(a.y - origin.y)
		var b_distance := absi(b.x - origin.x) + absi(b.y - origin.y)
		var a_actor_distance := absi(a.x - enemy_actor_state.grid_cell.x) + absi(a.y - enemy_actor_state.grid_cell.y)
		var b_actor_distance := absi(b.x - enemy_actor_state.grid_cell.x) + absi(b.y - enemy_actor_state.grid_cell.y)
		if a_distance != b_distance:
			return a_distance < b_distance
		if a_actor_distance != b_actor_distance:
			return a_actor_distance < b_actor_distance
		if a.y != b.y:
			return a.y < b.y
		return a.x < b.x
	)
	return candidate_cells


func _is_surround_candidate_cell_for_target(cell: Vector2i, target_state: BattleUnitState) -> bool:
	var actor_state := enemy_unit_state
	if current_enemy_ai_actor_state != null:
		actor_state = current_enemy_ai_actor_state
	for candidate_cell in _get_enemy_engagement_candidate_cells(target_state, actor_state):
		if candidate_cell == cell:
			return true
	return false


func _get_enemy_engagement_step_plan_for_actor(enemy_actor_state: BattleUnitState, target_state: BattleUnitState) -> Dictionary:
	var empty_plan: Dictionary = {}
	if enemy_actor_state == null or target_state == null or battle_grid_controller == null:
		return empty_plan
	var start_cell := enemy_actor_state.grid_cell
	var engagement_candidates := _get_enemy_engagement_candidate_cells(target_state, enemy_actor_state)
	var best_plan: Dictionary = {}
	var best_can_attack_after_step := false
	var best_candidate_rank := 9999
	var best_step_distance := 9999
	var best_full_path_length := 9999
	for candidate_index in range(engagement_candidates.size()):
		var candidate_cell := engagement_candidates[candidate_index]
		if candidate_cell == start_cell:
			continue
		var full_path := _find_enemy_path_to_destination_for_actor(enemy_actor_state, start_cell, candidate_cell, battle_grid_controller.grid_width * battle_grid_controller.grid_height)
		if full_path.is_empty() or full_path.size() < 2:
			continue
		var full_path_length := full_path.size() - 1
		var step_index := mini(enemy_actor_state.move_range, full_path_length)
		if step_index <= 0 or step_index >= full_path.size():
			continue
		var step_cell: Vector2i = full_path[step_index]
		if step_cell == start_cell:
			continue
		if _is_enemy_ai_destination_cell_reserved_for_other_actor(step_cell, enemy_actor_state):
			continue
		var step_distance := absi(step_cell.x - target_state.grid_cell.x) + absi(step_cell.y - target_state.grid_cell.y)
		var can_attack_after_step := step_distance <= enemy_actor_state.attack_range
		var should_replace := false
		if best_plan.is_empty():
			should_replace = true
		elif can_attack_after_step and not best_can_attack_after_step:
			should_replace = true
		elif can_attack_after_step == best_can_attack_after_step:
			if candidate_index < best_candidate_rank:
				should_replace = true
			elif candidate_index == best_candidate_rank:
				if step_distance < best_step_distance:
					should_replace = true
				elif step_distance == best_step_distance and full_path_length < best_full_path_length:
					should_replace = true
		if not should_replace:
			continue
		best_can_attack_after_step = can_attack_after_step
		best_candidate_rank = candidate_index
		best_step_distance = step_distance
		best_full_path_length = full_path_length
		var engagement_mode := "engagement_approach"
		if step_cell == candidate_cell:
			engagement_mode = "engagement_ring"
		best_plan = {
			"mode": engagement_mode,
			"reason": "engagement_candidate",
			"final_cell": candidate_cell,
			"step_cell": step_cell,
			"can_attack_after_step": can_attack_after_step,
			"step_distance": step_distance,
			"full_path_length": full_path_length,
		}
	return best_plan


func get_unit_grid_distance(attacker: BattleUnitState, target: BattleUnitState) -> int:
	if attacker == null or target == null:
		return 9999
	return absi(attacker.grid_cell.x - target.grid_cell.x) + absi(attacker.grid_cell.y - target.grid_cell.y)


func _debug_print_combat_distance(context: String) -> void:
	if ally_unit_state == null or enemy_unit_state == null:
		return
	var distance := get_unit_grid_distance(ally_unit_state, enemy_unit_state)
	print("[%s] ally=%s enemy=%s dist=%d ally_range=%d enemy_range=%d" % [
		context,
		ally_unit_state.grid_cell,
		enemy_unit_state.grid_cell,
		distance,
		ally_unit_state.attack_range,
		enemy_unit_state.attack_range,
	])


func is_unit_in_attack_range(attacker: BattleUnitState, target: BattleUnitState) -> bool:
	if attacker == null:
		return false
	if target == null:
		return false
	if not target.is_alive():
		return false

	var distance := get_unit_grid_distance(attacker, target)
	return distance <= attacker.attack_range


func is_enemy_in_active_attack_range() -> bool:
	if active_unit_state == null:
		return false
	if enemy_unit_state == null:
		return false
	if battle_grid_controller == null:
		return false
	if not enemy_unit_state.is_alive():
		return false

	var distance := get_unit_grid_distance(active_unit_state, enemy_unit_state)
	print("ALLY RANGE CHECK")
	print("ally grid: ", active_unit_state.grid_cell)
	print("enemy grid: ", enemy_unit_state.grid_cell)
	print("dist: ", distance, " range: ", active_unit_state.attack_range)
	return is_unit_in_attack_range(active_unit_state, enemy_unit_state)


func is_valid_move_target(target_cell: Vector2i) -> bool:
	if active_unit_state == null:
		return false
	if active_unit_side != "ally":
		return false
	if not _is_valid_grid_cell(target_cell):
		return false
	if _has_ally_unit_acted(active_unit_state):
		return false
	if active_unit_state.has_moved:
		return false

	var origin_cell: Vector2i = get_active_move_origin_cell()
	if target_cell == origin_cell:
		return false
	if not _is_valid_destination_for_unit(target_cell, active_unit_state):
		return false
	var path := _find_ally_move_path(origin_cell, target_cell)
	if path.is_empty():
		return false
	return _is_path_clear_for_unit(path, active_unit_state)


func _refresh_move_target_feedback() -> void:
	if move_target_marker == null or move_highlight == null or battle_grid_controller == null:
		return
	if not has_selected_move_target:
		move_highlight.visible = false
		return

	var target_cell: Vector2i = _get_selected_move_target_cell()
	var is_valid_target: bool = is_valid_move_target(target_cell)
	var snapped_position: Vector2 = _get_snapped_move_target_world_position()
	if is_valid_target:
		move_target_marker.modulate = MOVE_TARGET_VALID_COLOR
		move_highlight.color = MOVE_HIGHLIGHT_VALID_COLOR
	else:
		move_target_marker.modulate = MOVE_TARGET_INVALID_COLOR
		move_highlight.color = MOVE_HIGHLIGHT_INVALID_COLOR
	_show_move_highlight_at_position(snapped_position)
	if current_phase == PHASE_ALLY_TURN and not is_demo_animating:
		move_highlight.visible = true


func _clear_move_target_selection() -> void:
	has_selected_move_target = false
	selected_move_cell = Vector2i(-1, -1)
	if move_highlight != null:
		move_highlight.visible = false


func _sync_ally_markers_to_current_position() -> void:
	if ally_unit_marker != null:
		ally_unit_marker.position = current_ally_unit_position
	if ally_portrait_marker != null:
		ally_portrait_marker.position = current_ally_portrait_position


func _is_mouse_over_battle_ui() -> bool:
	var hovered_control := get_viewport().gui_get_hovered_control()
	if hovered_control == null:
		return false
	return (
		_is_node_in_subtree(hovered_control, battle_ui)
		or _is_node_in_subtree(hovered_control, cutin_overlay)
		or _is_node_in_subtree(hovered_control, result_overlay)
	)


func _is_node_in_subtree(node: Node, subtree_root: Node) -> bool:
	var current: Node = node
	while current != null:
		if current == subtree_root:
			return true
		current = current.get_parent()
	return false


func _format_cell(cell: Vector2i) -> String:
	return "(%d,%d)" % [cell.x, cell.y]


func _update_all_unit_visuals_from_state() -> void:
	_apply_unit_facing_visuals()
	for unit_state in _get_all_unit_states_in_slot_order():
		_update_unit_visuals_from_state(unit_state)
	_update_facing_indicators()
	_refresh_formation_slot_guides()
	_cleanup_dead_units()


func _update_unit_visuals_from_state(unit_state: BattleUnitState) -> void:
	if unit_state == null:
		return
	var slot := _get_unit_visual_slot_for_state(unit_state)
	if slot == null:
		return
	if slot.token != null:
		_apply_token_facing_visual(slot.token, unit_state.facing, unit_state.side, unit_state)
	if slot.hp_bar != null:
		slot.hp_bar.max_value = unit_state.max_hp
		slot.hp_bar.value = unit_state.current_hp
	if slot.troop_label != null:
		slot.troop_label.text = unit_state.get_troop_label_text()
	_restore_hp_troop_runtime_visibility_for_unit(unit_state)
	_apply_unit_visual_layer_profile_for_unit(unit_state)
	_apply_hp_bar_alpha_for_unit(unit_state)


func _update_ally_visuals_from_state() -> void:
	_update_unit_visuals_from_state(ally_unit_state)


func _update_ally_support_visuals_from_state() -> void:
	_update_unit_visuals_from_state(ally_support_unit_state)


func _update_ally_main_03_visuals_from_state() -> void:
	_update_unit_visuals_from_state(ally_main_03_unit_state)


func _update_enemy_visuals_from_state() -> void:
	_update_unit_visuals_from_state(enemy_unit_state)


func _update_enemy_support_visuals_from_state() -> void:
	_update_unit_visuals_from_state(enemy_support_unit_state)


func _update_enemy_main_03_visuals_from_state() -> void:
	_update_unit_visuals_from_state(enemy_main_03_unit_state)


func _update_ally_reinforce_01_visuals_from_state() -> void:
	_update_unit_visuals_from_state(ally_reinforce_01_unit_state)


func _update_ally_reinforce_02_visuals_from_state() -> void:
	_update_unit_visuals_from_state(ally_reinforce_02_unit_state)


func _update_enemy_reinforce_01_visuals_from_state() -> void:
	_update_unit_visuals_from_state(enemy_reinforce_01_unit_state)


func _update_enemy_reinforce_02_visuals_from_state() -> void:
	_update_unit_visuals_from_state(enemy_reinforce_02_unit_state)


func _get_hp_bar_for_unit(unit_state: BattleUnitState) -> ProgressBar:
	if unit_state == null:
		return null
	var slot := _get_unit_visual_slot_for_state(unit_state)
	if slot != null and slot.hp_bar != null:
		return slot.hp_bar as ProgressBar
	if unit_state == ally_unit_state:
		return ally_hp_bar
	if unit_state == ally_support_unit_state:
		return ally_support_hp_bar
	if unit_state == enemy_unit_state:
		return enemy_hp_bar
	if unit_state == enemy_support_unit_state:
		return enemy_support_hp_bar
	return null


func _get_troop_label_for_unit(unit_state: BattleUnitState) -> Label:
	if unit_state == null:
		return null
	var slot := _get_unit_visual_slot_for_state(unit_state)
	if slot != null and slot.troop_label != null:
		return slot.troop_label
	if unit_state == ally_unit_state:
		return ally_troop_label
	if unit_state == ally_support_unit_state:
		return ally_support_troop_label
	if unit_state == enemy_unit_state:
		return enemy_troop_label
	if unit_state == enemy_support_unit_state:
		return enemy_support_troop_label
	return null


func _get_hp_bar_layout_offset_for_unit(unit_state: BattleUnitState) -> Vector2:
	if unit_state == ally_unit_state:
		return ally_hp_bar_layout_offset
	if unit_state == ally_support_unit_state:
		return ally_support_hp_bar_layout_offset
	if unit_state == enemy_unit_state:
		return enemy_hp_bar_layout_offset
	if unit_state == enemy_support_unit_state:
		return enemy_support_hp_bar_layout_offset
	return Vector2.ZERO


func _get_troop_label_layout_offset_for_unit(unit_state: BattleUnitState) -> Vector2:
	if unit_state == ally_unit_state:
		return ally_troop_label_layout_offset
	if unit_state == ally_support_unit_state:
		return ally_support_troop_label_layout_offset
	if unit_state == enemy_unit_state:
		return enemy_troop_label_layout_offset
	if unit_state == enemy_support_unit_state:
		return enemy_support_troop_label_layout_offset
	return Vector2.ZERO


func _apply_hp_bar_runtime_alpha(hp_bar: CanvasItem) -> void:
	if hp_bar == null:
		return
	var hp_color := hp_bar.modulate
	hp_color.a = HP_BAR_RUNTIME_ALPHA
	hp_bar.modulate = hp_color


func _apply_hp_bar_alpha_for_unit(unit_state: BattleUnitState) -> void:
	if unit_state == null or not unit_state.is_alive():
		return
	var hp_bar := _get_hp_bar_for_unit(unit_state)
	_apply_hp_bar_runtime_alpha(hp_bar)


func _apply_hp_bar_alpha_to_all_units() -> void:
	for unit_state in _get_all_unit_states_in_slot_order():
		_apply_hp_bar_alpha_for_unit(unit_state)


func _apply_unit_visual_layer_profile_for_unit(unit_state: BattleUnitState) -> void:
	if unit_state == null:
		return
	var slot := _get_unit_visual_slot_for_state(unit_state)
	if slot == null:
		return
	if slot.shadow != null:
		slot.shadow.z_index = UNIT_VISUAL_LAYER_SHADOW
	if slot.hp_bar != null:
		slot.hp_bar.z_index = UNIT_VISUAL_LAYER_HP_BAR
	if slot.token != null:
		slot.token.z_index = UNIT_VISUAL_LAYER_TOKEN
	if slot.portrait != null:
		slot.portrait.z_index = UNIT_VISUAL_LAYER_PORTRAIT
	if slot.troop_label != null:
		slot.troop_label.z_index = UNIT_VISUAL_LAYER_TROOP_LABEL


func _restore_hp_troop_runtime_visibility_for_unit(unit_state: BattleUnitState) -> void:
	if unit_state == null:
		return
	var is_deployed_alive := _is_unit_state_available_for_battle_slot(unit_state)
	_set_unit_visual_group_visible(unit_state, is_deployed_alive)
	_set_unit_click_area_enabled(unit_state, is_deployed_alive)
	var hp_bar := _get_hp_bar_for_unit(unit_state)
	var troop_label := _get_troop_label_for_unit(unit_state)
	if hp_bar != null:
		hp_bar.max_value = max(unit_state.max_hp, 1)
		hp_bar.value = clamp(unit_state.current_hp, 0, unit_state.max_hp)
		hp_bar.visible = is_deployed_alive
		hp_bar.modulate = Color.WHITE
		_apply_hp_bar_runtime_alpha(hp_bar)
	if troop_label != null:
		troop_label.text = unit_state.get_troop_label_text()
		troop_label.visible = is_deployed_alive
		troop_label.modulate = Color.WHITE


func _normalize_facing(facing: String) -> String:
	if facing == FACING_LEFT:
		return FACING_LEFT
	if facing == FACING_RIGHT:
		return FACING_RIGHT
	if facing == FACING_UP:
		return FACING_UP
	if facing == FACING_DOWN:
		return FACING_DOWN
	return FACING_RIGHT


func _is_vertical_facing(facing: String) -> bool:
	var normalized_facing := _normalize_facing(facing)
	return normalized_facing == FACING_UP or normalized_facing == FACING_DOWN


func _is_horizontal_facing(facing: String) -> bool:
	var normalized_facing := _normalize_facing(facing)
	return normalized_facing == FACING_LEFT or normalized_facing == FACING_RIGHT


func _set_unit_facing(unit_state: BattleUnitState, facing: String) -> void:
	if unit_state == null:
		return
	unit_state.facing = _normalize_facing(facing)


func _face_unit_toward_cell(unit_state: BattleUnitState, target_cell: Vector2i) -> void:
	if unit_state == null:
		return

	if unit_state.grid_cell.x < target_cell.x:
		_set_unit_facing(unit_state, FACING_RIGHT)
	elif unit_state.grid_cell.x > target_cell.x:
		_set_unit_facing(unit_state, FACING_LEFT)
	elif unit_state.grid_cell.y > target_cell.y:
		_set_unit_facing(unit_state, FACING_UP)
	elif unit_state.grid_cell.y < target_cell.y:
		_set_unit_facing(unit_state, FACING_DOWN)


func _refresh_initial_unit_facing() -> void:
	if ally_unit_state == null or enemy_unit_state == null:
		return

	if not ally_has_manual_facing:
		_face_unit_toward_cell(ally_unit_state, enemy_unit_state.grid_cell)
	if not enemy_has_manual_facing:
		_face_unit_toward_cell(enemy_unit_state, ally_unit_state.grid_cell)

	_apply_unit_facing_visuals()
	_reset_unit_group_positions()


func _refresh_ally_facing_toward_enemy_if_not_manual() -> void:
	if active_unit_state == null or enemy_unit_state == null:
		return
	if ally_has_manual_facing:
		return

	_face_unit_toward_cell(active_unit_state, enemy_unit_state.grid_cell)
	_apply_unit_facing_visuals()
	_reset_unit_group_positions()


func _refresh_enemy_facing_for_enemy_action() -> void:
	_refresh_enemy_facing_for_actor_action(enemy_unit_state, _get_enemy_ai_target_state_for_actor(enemy_unit_state))


func _refresh_enemy_facing_for_actor_action(enemy_actor_state: BattleUnitState, target_state: BattleUnitState) -> void:
	if enemy_actor_state == null or target_state == null:
		return
	if enemy_has_manual_facing:
		return

	_face_unit_toward_cell(enemy_actor_state, target_state.grid_cell)
	_apply_unit_facing_visuals()
	_reset_unit_group_positions()


func _apply_unit_facing_visuals() -> void:
	for unit_state in _get_all_unit_states_in_slot_order():
		if unit_state == null:
			continue
		var slot := _get_unit_visual_slot_for_state(unit_state)
		if slot != null and slot.token != null:
			_apply_token_facing_visual(slot.token, unit_state.facing, unit_state.side, unit_state)
		if slot != null and slot.portrait != null:
			slot.portrait.flip_h = false
	_update_facing_indicators()


func _apply_token_facing_visual(token: Sprite2D, facing: String, side: String, unit_state: BattleUnitState = null) -> void:
	if token == null:
		return

	var normalized_facing := _normalize_facing(facing)
	var texture_for_facing := _get_visual_token_texture_for_unit(unit_state, normalized_facing)
	if texture_for_facing != null:
		token.texture = texture_for_facing

	if _is_horizontal_facing(normalized_facing):
		token.flip_h = _is_token_flip_h_for_facing(normalized_facing, side)
		return

	if _is_vertical_facing(normalized_facing):
		# Up/down sprite textures are optional for now. Fallback keeps the current stable visual.
		return


func _is_token_flip_h_for_facing(facing: String, side: String) -> bool:
	var normalized_facing := _normalize_facing(facing)
	match side:
		"enemy":
			match normalized_facing:
				FACING_RIGHT:
					return true
				FACING_LEFT:
					return false
		_:
			match normalized_facing:
				FACING_RIGHT:
					return true
				FACING_LEFT:
					return false

	return false


func _get_default_token_texture_for_facing(facing: String, side: String) -> Texture2D:
	var normalized_facing := _normalize_facing(facing)
	match side:
		"enemy":
			if normalized_facing == FACING_UP and enemy_unit_token_up_texture != null:
				return enemy_unit_token_up_texture
			if normalized_facing == FACING_DOWN and enemy_unit_token_down_texture != null:
				return enemy_unit_token_down_texture
			return enemy_token_base_texture
		_:
			if normalized_facing == FACING_UP and ally_unit_token_up_texture != null:
				return ally_unit_token_up_texture
			if normalized_facing == FACING_DOWN and ally_unit_token_down_texture != null:
				return ally_unit_token_down_texture
			return ally_token_base_texture


func _get_facing_aware_portrait_offset(base_offset: Vector2, facing: String) -> Vector2:
	var result := base_offset
	var normalized_facing := _normalize_facing(facing)
	match normalized_facing:
		FACING_LEFT:
			result.x = -absf(base_offset.x)
		FACING_RIGHT:
			result.x = absf(base_offset.x)
	return result


func _get_unit_facing(unit_state: BattleUnitState) -> String:
	if unit_state == null:
		return FACING_RIGHT
	return _normalize_facing(unit_state.facing)


func _get_facing_arrow_text(facing: String) -> String:
	match _normalize_facing(facing):
		FACING_LEFT:
			return "←"
		FACING_RIGHT:
			return "→"
		FACING_UP:
			return "↑"
		FACING_DOWN:
			return "↓"
		_:
			return "→"


func _update_facing_indicators() -> void:
	for unit_state in _get_all_unit_states_in_slot_order():
		_refresh_facing_indicator_for_unit(unit_state)


func _position_facing_indicator_for_ally() -> void:
	if ally_facing_indicator == null or ally_unit_token == null:
		return
	var world_anchor := _get_ally_visual_anchor_position() + ally_facing_indicator_layout_offset
	ally_facing_indicator.position = _world_to_battle_ui_position(world_anchor)


func _position_facing_indicator_for_ally_support() -> void:
	if ally_support_facing_indicator == null or ally_support_unit_token == null:
		return
	var world_anchor := _get_ally_support_visual_anchor_position() + ally_support_facing_indicator_layout_offset
	ally_support_facing_indicator.position = _world_to_battle_ui_position(world_anchor)


func _position_facing_indicator_for_ally_main_03() -> void:
	if ally_main_03_facing_indicator == null or ally_main_03_unit_token == null:
		return
	var world_anchor := _get_ally_main_03_visual_anchor_position() + ally_main_03_facing_indicator_layout_offset
	ally_main_03_facing_indicator.position = _world_to_battle_ui_position(world_anchor)


func _position_facing_indicator_for_ally_reinforce_01() -> void:
	if ally_reinforce_01_facing_indicator == null or ally_reinforce_01_unit_token == null:
		return
	var world_anchor := _get_ally_reinforce_01_visual_anchor_position() + ally_reinforce_01_facing_indicator_layout_offset
	ally_reinforce_01_facing_indicator.position = _world_to_battle_ui_position(world_anchor)


func _position_facing_indicator_for_ally_reinforce_02() -> void:
	if ally_reinforce_02_facing_indicator == null or ally_reinforce_02_unit_token == null:
		return
	var world_anchor := _get_ally_reinforce_02_visual_anchor_position() + ally_reinforce_02_facing_indicator_layout_offset
	ally_reinforce_02_facing_indicator.position = _world_to_battle_ui_position(world_anchor)


func _position_facing_indicator_for_enemy() -> void:
	if enemy_facing_indicator == null or enemy_unit_token == null:
		return
	var world_anchor := _get_enemy_visual_anchor_position() + enemy_facing_indicator_layout_offset
	enemy_facing_indicator.position = _world_to_battle_ui_position(world_anchor)


func _position_facing_indicator_for_enemy_support() -> void:
	if enemy_support_facing_indicator == null or enemy_support_unit_token == null:
		return
	var world_anchor := _get_enemy_support_visual_anchor_position() + enemy_support_facing_indicator_layout_offset
	enemy_support_facing_indicator.position = _world_to_battle_ui_position(world_anchor)


func _position_facing_indicator_for_enemy_main_03() -> void:
	if enemy_main_03_facing_indicator == null or enemy_main_03_unit_token == null:
		return
	var world_anchor := _get_enemy_main_03_visual_anchor_position() + enemy_main_03_facing_indicator_layout_offset
	enemy_main_03_facing_indicator.position = _world_to_battle_ui_position(world_anchor)


func _position_facing_indicator_for_enemy_reinforce_01() -> void:
	if enemy_reinforce_01_facing_indicator == null or enemy_reinforce_01_unit_token == null:
		return
	var world_anchor := _get_enemy_reinforce_01_visual_anchor_position() + enemy_reinforce_01_facing_indicator_layout_offset
	enemy_reinforce_01_facing_indicator.position = _world_to_battle_ui_position(world_anchor)


func _position_facing_indicator_for_enemy_reinforce_02() -> void:
	if enemy_reinforce_02_facing_indicator == null or enemy_reinforce_02_unit_token == null:
		return
	var world_anchor := _get_enemy_reinforce_02_visual_anchor_position() + enemy_reinforce_02_facing_indicator_layout_offset
	enemy_reinforce_02_facing_indicator.position = _world_to_battle_ui_position(world_anchor)


func _set_facing_indicators_visible(should_show: bool) -> void:
	facing_indicators_should_be_visible = should_show
	var effective_should_show := should_show and not (battle_toast_suppresses_facing_indicators or unique_skill_toast_suppresses_facing_indicators)
	for unit_state in _get_all_unit_states_in_slot_order():
		var facing_indicator := _get_facing_indicator_for_unit(unit_state)
		if facing_indicator != null:
			facing_indicator.visible = effective_should_show and _is_unit_state_available_for_battle_slot(unit_state)


func _set_toast_facing_indicator_suppression(toast_kind: String, should_suppress: bool) -> void:
	var was_suppressed := battle_toast_suppresses_facing_indicators or unique_skill_toast_suppresses_facing_indicators
	if should_suppress and not was_suppressed:
		facing_indicators_visible_before_toast = facing_indicators_should_be_visible
	match toast_kind:
		"battle":
			battle_toast_suppresses_facing_indicators = should_suppress
		"unique_skill":
			unique_skill_toast_suppresses_facing_indicators = should_suppress
	var is_suppressed := battle_toast_suppresses_facing_indicators or unique_skill_toast_suppresses_facing_indicators
	if is_suppressed:
		_set_facing_indicators_visible(facing_indicators_should_be_visible)
		return
	_set_facing_indicators_visible(facing_indicators_visible_before_toast)
	if facing_indicators_visible_before_toast:
		_update_facing_indicators()


func _world_to_battle_ui_position(world_pos: Vector2) -> Vector2:
	var camera := _get_main_camera_or_null()
	if camera != null and camera.enabled:
		var viewport_center := get_viewport_rect().size * 0.5
		var relative_position := world_pos - camera.global_position
		if not is_zero_approx(camera.global_rotation):
			relative_position = relative_position.rotated(-camera.global_rotation)
		return viewport_center + (relative_position * camera.zoom)
	return get_viewport().get_canvas_transform() * world_pos


func _start_idle_breathing() -> void:
	if is_demo_animating:
		return

	_stop_idle_breathing()
	ally_idle_tween = _start_token_idle(ally_unit_token, ally_token_base_scale)
	enemy_idle_tween = _start_token_idle(enemy_unit_token, enemy_token_base_scale)
	ally_support_idle_tween = _start_token_idle(ally_support_unit_token, ally_support_token_base_scale)
	enemy_support_idle_tween = _start_token_idle(enemy_support_unit_token, enemy_support_token_base_scale)
	ally_main_03_idle_tween = _start_token_idle(ally_main_03_unit_token, ally_main_03_token_base_scale)
	enemy_main_03_idle_tween = _start_token_idle(enemy_main_03_unit_token, enemy_main_03_token_base_scale)
	ally_reinforce_01_idle_tween = _start_token_idle(ally_reinforce_01_unit_token, ally_reinforce_01_token_base_scale)
	enemy_reinforce_01_idle_tween = _start_token_idle(enemy_reinforce_01_unit_token, enemy_reinforce_01_token_base_scale)
	ally_reinforce_02_idle_tween = _start_token_idle(ally_reinforce_02_unit_token, ally_reinforce_02_token_base_scale)
	enemy_reinforce_02_idle_tween = _start_token_idle(enemy_reinforce_02_unit_token, enemy_reinforce_02_token_base_scale)


func _start_token_idle(token: Sprite2D, base_scale: Vector2) -> Tween:
	if token == null:
		return null
	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(token, "scale", base_scale * IDLE_SCALE_MULTIPLIER, IDLE_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(token, "scale", base_scale, IDLE_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween


func _stop_idle_breathing() -> void:
	if ally_idle_tween:
		ally_idle_tween.kill()
		ally_idle_tween = null
	if enemy_idle_tween:
		enemy_idle_tween.kill()
		enemy_idle_tween = null
	if ally_support_idle_tween:
		ally_support_idle_tween.kill()
		ally_support_idle_tween = null
	if enemy_support_idle_tween:
		enemy_support_idle_tween.kill()
		enemy_support_idle_tween = null
	if ally_main_03_idle_tween:
		ally_main_03_idle_tween.kill()
		ally_main_03_idle_tween = null
	if enemy_main_03_idle_tween:
		enemy_main_03_idle_tween.kill()
		enemy_main_03_idle_tween = null
	if ally_reinforce_01_idle_tween:
		ally_reinforce_01_idle_tween.kill()
		ally_reinforce_01_idle_tween = null
	if enemy_reinforce_01_idle_tween:
		enemy_reinforce_01_idle_tween.kill()
		enemy_reinforce_01_idle_tween = null
	if ally_reinforce_02_idle_tween:
		ally_reinforce_02_idle_tween.kill()
		ally_reinforce_02_idle_tween = null
	if enemy_reinforce_02_idle_tween:
		enemy_reinforce_02_idle_tween.kill()
		enemy_reinforce_02_idle_tween = null

	ally_unit_token.scale = ally_token_base_scale
	enemy_unit_token.scale = enemy_token_base_scale
	ally_support_unit_token.scale = ally_support_token_base_scale
	enemy_support_unit_token.scale = enemy_support_token_base_scale
	if ally_main_03_unit_token != null:
		ally_main_03_unit_token.scale = ally_main_03_token_base_scale
	if enemy_main_03_unit_token != null:
		enemy_main_03_unit_token.scale = enemy_main_03_token_base_scale
	if ally_reinforce_01_unit_token != null:
		ally_reinforce_01_unit_token.scale = ally_reinforce_01_token_base_scale
	if enemy_reinforce_01_unit_token != null:
		enemy_reinforce_01_unit_token.scale = enemy_reinforce_01_token_base_scale
	if ally_reinforce_02_unit_token != null:
		ally_reinforce_02_unit_token.scale = ally_reinforce_02_token_base_scale
	if enemy_reinforce_02_unit_token != null:
		enemy_reinforce_02_unit_token.scale = enemy_reinforce_02_token_base_scale


func _sync_overlay_positions() -> void:
	var cutin_center: Vector2 = cutin_center_marker.global_position
	var result_center: Vector2 = result_center_marker.global_position

	cutin_image.position = cutin_center + Vector2(-220.0, -160.0)
	cutin_name_label.position = cutin_center + Vector2(-150.0, 128.0)
	cutin_quote_label.position = cutin_center + Vector2(-220.0, 200.0)
	result_image.position = result_center + Vector2(-220.0, -170.0)
	result_title_label.position = result_center + Vector2(-108.0, 176.0)
