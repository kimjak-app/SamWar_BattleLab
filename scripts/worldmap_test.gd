extends Node2D

const WORLD_MAP_CAMERA_SPEED := 900.0
const WORLD_MAP_CAMERA_DRAG_SPEED := 1.0
const WORLD_MAP_MIN_ZOOM := 0.35
const WORLD_MAP_MAX_ZOOM := 1.6
const WORLD_MAP_CLAMP_PADDING := 24.0
const WORLD_MAP_ZOOM_STEP := 0.1
const PLAYER_FACTION_ID := "player"
const CITY_DETAIL_TAB_RESOURCES := "resources"
const CITY_DETAIL_TAB_INTERNAL_TRADE := "internal-trade"
const CITY_DETAIL_TAB_EXTERNAL_TRADE := "external-trade"

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
	},
	"agriculture": {
		"name": "농업 중심",
		"description": "쌀/보리 수입 증가, 금전 소폭 감소",
	},
	"commerce": {
		"name": "상업 중심",
		"description": "금전 수입 증가, 식량 수입 소폭 감소",
	},
	"trade": {
		"name": "무역 중심",
		"description": "수산물/금전 소폭 증가, 소금 보존 부담 완화",
	},
	"military": {
		"name": "군사 중심",
		"description": "영웅 유지비 감소, 금전 소폭 감소",
	},
}

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

const HERO_DATA := {
	"jeong_do_jeon": {"display_name": "정도전", "role": "재상", "politics": 94, "war": 42, "intelligence": 92, "loyalty": 90, "assigned_city_id": "hanseong"},
	"yi_sun_sin": {"display_name": "이순신", "role": "수군 지휘", "politics": 76, "war": 96, "intelligence": 88, "loyalty": 98, "assigned_city_id": "hanseong"},
	"cheok_jun_gyeong": {"display_name": "척준경", "role": "돌격", "politics": 48, "war": 98, "intelligence": 52, "loyalty": 86, "assigned_city_id": "hanseong"},
	"gwanggaeto": {"display_name": "광개토대왕", "role": "북방 원정", "politics": 84, "war": 97, "intelligence": 82, "loyalty": 92, "assigned_city_id": "pyeongyang"},
	"eulji_mundeok": {"display_name": "을지문덕", "role": "책략", "politics": 82, "war": 78, "intelligence": 92, "loyalty": 90, "assigned_city_id": "pyeongyang"},
	"dorim": {"display_name": "도림", "role": "지원", "politics": 72, "war": 32, "intelligence": 88, "loyalty": 70, "assigned_city_id": "pyeongyang"},
	"kim_chun_chu": {"display_name": "김춘추", "role": "외교", "politics": 91, "war": 58, "intelligence": 87, "loyalty": 84, "assigned_city_id": "gyeongju"},
	"kim_yu_sin": {"display_name": "김유신", "role": "정예 지휘", "politics": 72, "war": 94, "intelligence": 79, "loyalty": 91, "assigned_city_id": "gyeongju"},
	"jang_bo_go": {"display_name": "장보고", "role": "해상 교역", "politics": 78, "war": 74, "intelligence": 82, "loyalty": 84, "assigned_city_id": "gyeongju"},
	"uija_wang": {"display_name": "의자왕", "role": "왕도 운영", "politics": 82, "war": 76, "intelligence": 78, "loyalty": 78, "assigned_city_id": "sabi"},
	"gyebaek": {"display_name": "계백", "role": "결사 방위", "politics": 62, "war": 92, "intelligence": 74, "loyalty": 89, "assigned_city_id": "sabi"},
	"heukchi_sangji": {"display_name": "흑치상지", "role": "복국 지휘", "politics": 70, "war": 82, "intelligence": 86, "loyalty": 88, "assigned_city_id": "sabi"},
	"xiang_yu": {"display_name": "항우", "role": "패왕", "politics": 58, "war": 99, "intelligence": 70, "loyalty": 75, "assigned_city_id": "luoyang"},
	"fan_zeng": {"display_name": "범증", "role": "책사", "politics": 94, "war": 35, "intelligence": 97, "loyalty": 78, "assigned_city_id": "luoyang"},
	"cao_cao": {"display_name": "조조", "role": "위왕", "politics": 96, "war": 91, "intelligence": 94, "loyalty": 81, "assigned_city_id": "yecheng"},
	"xun_yu": {"display_name": "순욱", "role": "행정", "politics": 96, "war": 30, "intelligence": 98, "loyalty": 86, "assigned_city_id": "yecheng"},
	"guo_jia": {"display_name": "곽가", "role": "책략", "politics": 82, "war": 34, "intelligence": 97, "loyalty": 82, "assigned_city_id": "yecheng"},
	"zhuge_liang": {"display_name": "제갈량", "role": "책사", "politics": 98, "war": 62, "intelligence": 100, "loyalty": 95, "assigned_city_id": "chengdu"},
	"guan_yu": {"display_name": "관우", "role": "장군", "politics": 70, "war": 96, "intelligence": 78, "loyalty": 95, "assigned_city_id": "chengdu"},
	"zhang_fei": {"display_name": "장비", "role": "돌격", "politics": 52, "war": 94, "intelligence": 58, "loyalty": 92, "assigned_city_id": "chengdu"},
	"sun_ce": {"display_name": "손책", "role": "강동 돌파", "politics": 78, "war": 93, "intelligence": 80, "loyalty": 82, "assigned_city_id": "jianye"},
	"zhou_yu": {"display_name": "주유", "role": "수군 책략", "politics": 88, "war": 84, "intelligence": 96, "loyalty": 88, "assigned_city_id": "jianye"},
	"lu_meng": {"display_name": "여몽", "role": "장군", "politics": 78, "war": 82, "intelligence": 88, "loyalty": 84, "assigned_city_id": "jianye"},
	"genghis_khan": {"display_name": "징기스칸", "role": "초원 군주", "politics": 86, "war": 100, "intelligence": 88, "loyalty": 86, "assigned_city_id": "karakorum"},
	"subutai": {"display_name": "수부타이", "role": "기병 지휘", "politics": 72, "war": 94, "intelligence": 88, "loyalty": 86, "assigned_city_id": "karakorum"},
	"jebe": {"display_name": "제베", "role": "기병", "politics": 58, "war": 90, "intelligence": 76, "loyalty": 82, "assigned_city_id": "karakorum"},
	"nobunaga": {"display_name": "노부나가", "role": "개혁 군주", "politics": 92, "war": 90, "intelligence": 88, "loyalty": 80, "assigned_city_id": "kyoto"},
	"takeda_shingen": {"display_name": "다케다 신겐", "role": "기병", "politics": 86, "war": 92, "intelligence": 84, "loyalty": 82, "assigned_city_id": "kyoto"},
	"toyotomi_hideyoshi": {"display_name": "도요토미 히데요시", "role": "상업 통치", "politics": 95, "war": 84, "intelligence": 90, "loyalty": 82, "assigned_city_id": "osaka"},
	"kenshin": {"display_name": "우에스기 겐신", "role": "장군", "politics": 80, "war": 94, "intelligence": 84, "loyalty": 82, "assigned_city_id": "osaka"},
	"shimazu_yoshihiro": {"display_name": "시마즈 요시히로", "role": "해상 방위", "politics": 70, "war": 92, "intelligence": 78, "loyalty": 83, "assigned_city_id": "kyushu"},
	"konishi_yukinaga": {"display_name": "고니시 유키나가", "role": "교역", "politics": 78, "war": 72, "intelligence": 82, "loyalty": 76, "assigned_city_id": "kyushu"},
	"tokugawa_ieyasu": {"display_name": "도쿠가와 이에야스", "role": "동방 행정", "politics": 97, "war": 82, "intelligence": 92, "loyalty": 88, "assigned_city_id": "edo"},
	"honda_masanobu": {"display_name": "혼다 마사노부", "role": "행정", "politics": 90, "war": 52, "intelligence": 92, "loyalty": 84, "assigned_city_id": "edo"},
	"honda_tadakatsu": {"display_name": "혼다 다다카쓰", "role": "장군", "politics": 72, "war": 95, "intelligence": 76, "loyalty": 88, "assigned_city_id": "edo"},
}

const CITY_HUD_DATA := {
	"hanseong": {"governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": ["yi_sun_sin", "jeong_do_jeon", "cheok_jun_gyeong"], "loyalty": 78, "resources": "쌀 ★★★ / 보리 ★★★ / 수산물 ★ / 목재 ★ / 철 ★ / 말 - / 비단 ★★★ / 소금 ★★", "military": "도시 주둔군 300 / 치안 기준 500 / 방어력 3", "trade": "내부 교역로: 평양-경주-사비 연결 후보", "rating": "인구 ★★★★ · 상업력 ★★★★★ · 금전 650"},
	"pyeongyang": {"governor_id": "gwanggaeto", "governor_policy_id": "military", "stationed_hero_ids": ["gwanggaeto", "eulji_mundeok", "dorim"], "loyalty": 72, "resources": "쌀 ★★★ / 보리 ★★★ / 수산물 ★ / 목재 ★★★ / 철 ★★ / 말 ★★★ / 비단 ★ / 소금 ★", "military": "도시 주둔군 280 / 치안 기준 500 / 방어력 3", "trade": "내부 교역로: 한성-카라코룸 연결 후보", "rating": "인구 ★★★ · 상업력 ★★★ · 금전 420"},
	"gyeongju": {"governor_id": "kim_chun_chu", "governor_policy_id": "commerce", "stationed_hero_ids": ["kim_chun_chu", "kim_yu_sin", "jang_bo_go"], "loyalty": 76, "resources": "쌀 ★★★ / 보리 ★★ / 수산물 ★★★ / 목재 ★★ / 철 ★ / 말 ★ / 비단 ★★★★ / 소금 ★★", "military": "도시 주둔군 280 / 치안 기준 500 / 방어력 3", "trade": "대외 무역: 경주 ↔ 교토 / 경주 ↔ 오사카 후보", "rating": "인구 ★★★★ · 상업력 ★★★★ · 금전 580"},
	"sabi": {"governor_id": "uija_wang", "governor_policy_id": "agriculture", "stationed_hero_ids": ["uija_wang", "gyebaek", "heukchi_sangji"], "loyalty": 73, "resources": "쌀 ★★★ / 보리 ★★ / 수산물 ★★★ / 목재 ★★ / 철 ★ / 말 ★ / 비단 ★★★ / 소금 ★★★", "military": "도시 주둔군 300 / 치안 기준 600 / 방어력 3", "trade": "대외 무역: 사비 ↔ 큐슈 / 사비 ↔ 건업 후보", "rating": "인구 ★★★★ · 상업력 ★★★★ · 금전 620"},
	"luoyang": {"governor_id": "xiang_yu", "governor_policy_id": "military", "stationed_hero_ids": ["xiang_yu", "fan_zeng"], "loyalty": 74, "resources": "쌀 ★★★ / 보리 ★★★ / 수산물 - / 목재 ★ / 철 ★★★ / 말 ★★ / 비단 ★★★★★ / 소금 ★", "military": "도시 주둔군 420 / 치안 기준 1000 / 방어력 4", "trade": "내부 교역로: 업성-성도-건업 내륙 연결", "rating": "인구 ★★★★★ · 상업력 ★★★★★ · 금전 880"},
	"yecheng": {"governor_id": "cao_cao", "governor_policy_id": "military", "stationed_hero_ids": ["cao_cao", "xun_yu", "guo_jia"], "loyalty": 70, "resources": "쌀 ★★★ / 보리 ★★★★ / 수산물 - / 목재 ★★ / 철 ★★★★★ / 말 ★★★★ / 비단 ★★ / 소금 ★", "military": "도시 주둔군 450 / 치안 기준 1000 / 방어력 5", "trade": "내부 교역로: 낙양-건업-카라코룸 연결", "rating": "인구 ★★★★ · 상업력 ★★★ · 금전 720"},
	"chengdu": {"governor_id": "zhuge_liang", "governor_policy_id": "agriculture", "stationed_hero_ids": ["zhuge_liang", "guan_yu", "zhang_fei"], "loyalty": 72, "resources": "쌀 ★★★★★ / 보리 ★★★ / 수산물 - / 목재 ★★★★ / 철 ★★ / 말 ★ / 비단 ★★★ / 소금 ★★", "military": "도시 주둔군 350 / 치안 기준 800 / 방어력 4", "trade": "내부 교역로: 낙양/건업 장거리 내륙 교역", "rating": "인구 ★★★★ · 상업력 ★★★ · 금전 640"},
	"jianye": {"governor_id": "sun_ce", "governor_policy_id": "commerce", "stationed_hero_ids": ["sun_ce", "zhou_yu", "lu_meng"], "loyalty": 74, "resources": "쌀 ★★★ / 보리 ★★ / 수산물 ★★★ / 목재 ★★★★ / 철 ★ / 말 - / 비단 ★★★★ / 소금 ★★★", "military": "도시 주둔군 300 / 치안 기준 600 / 방어력 3", "trade": "대외 무역: 건업 ↔ 사비 후보", "rating": "인구 ★★★★ · 상업력 ★★★★★ · 금전 820"},
	"karakorum": {"governor_id": "genghis_khan", "governor_policy_id": "military", "stationed_hero_ids": ["genghis_khan", "subutai", "jebe"], "loyalty": 78, "resources": "쌀 ★ / 보리 ★★★★ / 수산물 - / 목재 ★★ / 철 ★★★★ / 말 ★★★★★ / 비단 ★★ / 소금 ★", "military": "도시 주둔군 460 / 치안 기준 900 / 방어력 4", "trade": "내부 교역로: 평양-업성 북방 연결", "rating": "인구 ★★★ · 상업력 ★★ · 금전 620"},
	"kyoto": {"governor_id": "nobunaga", "governor_policy_id": "commerce", "stationed_hero_ids": ["nobunaga", "takeda_shingen"], "loyalty": 76, "resources": "쌀 ★ / 보리 ★ / 수산물 ★★★★★ / 목재 ★★ / 철 ★ / 말 - / 비단 ★★ / 소금 ★★★★", "military": "도시 주둔군 240 / 치안 기준 500 / 방어력 3", "trade": "대외 무역: 교토 ↔ 경주 후보", "rating": "인구 ★★★ · 상업력 ★★★ · 금전 760"},
	"osaka": {"governor_id": "toyotomi_hideyoshi", "governor_policy_id": "commerce", "stationed_hero_ids": ["toyotomi_hideyoshi", "kenshin"], "loyalty": 72, "resources": "쌀 ★★ / 보리 ★ / 수산물 ★★★★ / 목재 ★★ / 철 ★ / 말 - / 비단 ★★★ / 소금 ★★★★", "military": "도시 주둔군 260 / 치안 기준 500 / 방어력 3", "trade": "대외 무역: 오사카 ↔ 경주 / 큐슈 후보", "rating": "인구 ★★★★ · 상업력 ★★★★★ · 금전 900"},
	"kyushu": {"governor_id": "shimazu_yoshihiro", "governor_policy_id": "military", "stationed_hero_ids": ["shimazu_yoshihiro", "konishi_yukinaga"], "loyalty": 72, "resources": "쌀 ★★ / 보리 ★ / 수산물 ★★★★★ / 목재 ★★ / 철 ★ / 말 - / 비단 ★★ / 소금 ★★★★", "military": "도시 주둔군 270 / 치안 기준 500 / 방어력 3", "trade": "대외 무역: 큐슈 ↔ 사비 / 오사카 후보", "rating": "인구 ★★★ · 상업력 ★★★★ · 금전 680"},
	"edo": {"governor_id": "tokugawa_ieyasu", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": ["tokugawa_ieyasu", "honda_masanobu", "honda_tadakatsu"], "loyalty": 78, "resources": "쌀 ★★ / 보리 ★★ / 수산물 ★★★ / 목재 ★★★ / 철 ★★★ / 말 ★★ / 비단 ★ / 소금 ★★★", "military": "도시 주둔군 380 / 치안 기준 800 / 방어력 4", "trade": "내부 교역로: 교토 동방 내륙 연결", "rating": "인구 ★★★ · 상업력 ★★★ · 금전 700"},
}

@onready var tile_a1_top_left: Sprite2D = $WorldMapRoot/WorldMapTileLayer/Tile_A1_TopLeft
@onready var tile_a2_top_right: Sprite2D = $WorldMapRoot/WorldMapTileLayer/Tile_A2_TopRight
@onready var tile_b1_bottom_left: Sprite2D = $WorldMapRoot/WorldMapTileLayer/Tile_B1_BottomLeft
@onready var tile_b2_bottom_right: Sprite2D = $WorldMapRoot/WorldMapTileLayer/Tile_B2_BottomRight
@onready var city_layer: Node2D = $WorldMapRoot/CityLayer
@onready var world_map_camera: Camera2D = $WorldMapCamera
@onready var camera_debug_label: Label = $WorldMapUI/CameraDebugLabel
@onready var city_info_panel: Node = $WorldMapUI/CityInfoPanel
@onready var turn_label: Label = $WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/TurnLabel
@onready var calendar_label: Label = $WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/CalendarLabel
@onready var nation_label: Label = $WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/NationLabel
@onready var power_label: Label = $WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/NationalGaugeCard/MarginContainer/GaugeList/PowerLabel
@onready var power_bar: ProgressBar = $WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/NationalGaugeCard/MarginContainer/GaugeList/PowerBar
@onready var tax_label: Label = $WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/NationalGaugeCard/MarginContainer/GaugeList/TaxLabel
@onready var tax_bar: ProgressBar = $WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/NationalGaugeCard/MarginContainer/GaugeList/TaxBar
@onready var security_label: Label = $WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/NationalGaugeCard/MarginContainer/GaugeList/SecurityLabel
@onready var security_bar: ProgressBar = $WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/NationalGaugeCard/MarginContainer/GaugeList/SecurityBar
@onready var chancellor_label: Label = $WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/ChancellorLabel
@onready var chancellor_portrait_label: Label = $WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/ChancellorCard/MarginContainer/Content/HeaderRow/PortraitBox/PortraitLabel
@onready var chancellor_name_label: Label = $WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/ChancellorCard/MarginContainer/Content/HeaderRow/Copy/ChancellorNameLabel
@onready var chancellor_stats_label: Label = $WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/ChancellorCard/MarginContainer/Content/HeaderRow/Copy/ChancellorStatsLabel
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
@onready var diplomacy_hint_label: Label = $WorldMapUI/DiplomacySpyPanel/MarginContainer/Content/DiplomacyHintLabel
@onready var diplomacy_mode_button_placeholder: Button = $WorldMapUI/DiplomacySpyPanel/MarginContainer/Content/TabRow/DiplomacyModeButtonPlaceholder
@onready var spy_mode_button_placeholder: Button = $WorldMapUI/DiplomacySpyPanel/MarginContainer/Content/TabRow/SpyModeButtonPlaceholder
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
var selected_city_id: String = ""
var selected_city_marker: WorldMapCityMarker = null
var _city_markers_by_id: Dictionary = {}
var _player_state := {
	"turn_label": "제 1턴",
	"year_label": "154년 봄 1일",
	"current_phase_label": "아군 턴",
	"national_power": 72,
	"tax_level": 30,
	"public_order": 68,
	"chancellor_id": "jeong_do_jeon",
	"chancellor_policy_id": "balanced",
	"resources": "쌀 300 / 보리 250 / 수산물 80 / 목재 100 / 철 50 / 말 30 / 비단 30 / 소금 50 / 금전 500",
	"supply": "활성 보급로 3개 · 군사 지원 필요 도시: 한성",
	"logistics": "영웅 병력 + 주둔군 기준, 유지비 preview만 표시",
	"trade": "대외 무역: 한반도 해상 교역 후보 준비 중",
}
var _city_policy_state: Dictionary = {}
var _selected_city_detail_tab := CITY_DETAIL_TAB_RESOURCES


func _ready() -> void:
	_refresh_world_rect_from_scene_tiles()
	_connect_city_markers()
	city_info_panel.set_city_markers(_city_markers_by_id)
	city_info_panel.set_hud_data(HERO_DATA, CITY_HUD_DATA, GOVERNOR_POLICY_DATA, _city_policy_state)
	_setup_chancellor_policy_option()
	_refresh_left_world_status_panel()
	_connect_world_hud_placeholders()
	_reset_city_detail_panel()
	_configure_camera()
	_update_camera_debug_label()


func _process(delta: float) -> void:
	_handle_keyboard_pan(delta)
	_update_camera_debug_label()


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
	city_info_panel.show_city(city_marker)
	_show_city_detail(city_marker)


func _connect_world_hud_placeholders() -> void:
	wild_army_edit_button_placeholder.pressed.connect(_on_wild_army_edit_placeholder_pressed)
	save_button_placeholder.pressed.connect(_on_save_placeholder_pressed)
	load_button_placeholder.pressed.connect(_on_load_placeholder_pressed)
	reset_button_placeholder.pressed.connect(_on_reset_placeholder_pressed)
	diplomacy_mode_button_placeholder.pressed.connect(_on_diplomacy_mode_placeholder_pressed)
	spy_mode_button_placeholder.pressed.connect(_on_spy_mode_placeholder_pressed)
	city_detail_resource_tab_button_placeholder.pressed.connect(_on_city_detail_tab_pressed.bind(CITY_DETAIL_TAB_RESOURCES))
	city_detail_internal_trade_tab_button_placeholder.pressed.connect(_on_city_detail_tab_pressed.bind(CITY_DETAIL_TAB_INTERNAL_TRADE))
	city_detail_external_trade_tab_button_placeholder.pressed.connect(_on_city_detail_tab_pressed.bind(CITY_DETAIL_TAB_EXTERNAL_TRADE))
	city_detail_collapse_button_placeholder.pressed.connect(_on_city_detail_collapse_placeholder_pressed)
	city_detail_domestic_button_placeholder.pressed.connect(_on_city_detail_domestic_placeholder_pressed)


func _reset_city_detail_panel() -> void:
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


func _show_city_detail(city_marker: WorldMapCityMarker) -> void:
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


func _refresh_city_detail_tab_styles() -> void:
	_set_city_detail_tab_active(city_detail_resource_tab_button_placeholder, _selected_city_detail_tab == CITY_DETAIL_TAB_RESOURCES)
	_set_city_detail_tab_active(city_detail_internal_trade_tab_button_placeholder, _selected_city_detail_tab == CITY_DETAIL_TAB_INTERNAL_TRADE)
	_set_city_detail_tab_active(city_detail_external_trade_tab_button_placeholder, _selected_city_detail_tab == CITY_DETAIL_TAB_EXTERNAL_TRADE)


func _set_city_detail_tab_active(button: Button, is_active: bool) -> void:
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


func _setup_chancellor_policy_option() -> void:
	chancellor_policy_option.clear()
	for policy_id in CHANCELLOR_POLICY_DATA.keys():
		var policy_data: Dictionary = CHANCELLOR_POLICY_DATA[policy_id]
		chancellor_policy_option.add_item(str(policy_data.get("name", policy_id)))
		chancellor_policy_option.set_item_metadata(chancellor_policy_option.item_count - 1, policy_id)

	if not chancellor_policy_option.item_selected.is_connected(_on_chancellor_policy_selected):
		chancellor_policy_option.item_selected.connect(_on_chancellor_policy_selected)


func _refresh_left_world_status_panel() -> void:
	turn_label.text = str(_player_state.get("turn_label", "제 1턴"))
	calendar_label.text = str(_player_state.get("year_label", "154년 봄 1일"))
	nation_label.text = str(_player_state.get("current_phase_label", "아군 턴"))
	var national_power := int(_player_state.get("national_power", 0))
	var tax_level := int(_player_state.get("tax_level", 0))
	var public_order := int(_player_state.get("public_order", 0))
	power_label.text = "국력 %d" % national_power
	power_bar.value = national_power
	tax_label.text = "세금 %d" % tax_level
	tax_bar.value = tax_level
	security_label.text = "치안 %d" % public_order
	security_bar.value = public_order

	var chancellor_id := str(_player_state.get("chancellor_id", ""))
	var chancellor_data := _get_hero_entry(chancellor_id)
	var chancellor_name := str(chancellor_data.get("display_name", "재상 미임명"))
	var policy_id := str(_player_state.get("chancellor_policy_id", "balanced"))
	var policy_data := _get_chancellor_policy_entry(policy_id)
	chancellor_label.text = "재상: %s · %s" % [chancellor_name, str(policy_data.get("name", policy_id))]
	chancellor_portrait_label.text = _get_portrait_initial(chancellor_name)
	chancellor_name_label.text = chancellor_name
	chancellor_stats_label.text = _format_hero_stats(chancellor_data)
	chancellor_policy_description_label.text = str(policy_data.get("description", "재상 정책 설명 준비 중"))
	_select_option_by_metadata(chancellor_policy_option, policy_id)
	resource_label.text = "보유 자원: %s" % str(_player_state.get("resources", "placeholder"))
	supply_label.text = "내부 보급망: %s" % str(_player_state.get("supply", "placeholder"))
	military_logistics_label.text = "내부 병참 계획서: %s" % str(_player_state.get("logistics", "placeholder"))
	external_trade_label.text = "대외 무역: %s" % str(_player_state.get("trade", "placeholder"))


func _get_city_hud_entry(city_id: String) -> Dictionary:
	return CITY_HUD_DATA.get(city_id, {})


func _get_hero_entry(hero_id: String) -> Dictionary:
	return HERO_DATA.get(hero_id, {})


func _get_chancellor_policy_entry(policy_id: String) -> Dictionary:
	return CHANCELLOR_POLICY_DATA.get(policy_id, CHANCELLOR_POLICY_DATA["balanced"])


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


func _get_portrait_initial(display_name: String) -> String:
	if display_name.is_empty():
		return "?"
	return display_name.left(1)


func _select_option_by_metadata(option_button: OptionButton, metadata_value: String) -> void:
	for index in range(option_button.item_count):
		if str(option_button.get_item_metadata(index)) == metadata_value:
			option_button.select(index)
			return


func _on_chancellor_policy_selected(index: int) -> void:
	var policy_id := str(chancellor_policy_option.get_item_metadata(index))
	_player_state["chancellor_policy_id"] = policy_id
	print("[WorldMap] Chancellor policy placeholder selected: %s. No resource or turn effect applied." % policy_id)
	_refresh_left_world_status_panel()
	world_status_hint_label.text = "재상 정책 '%s' 선택됨. 실제 효과는 적용하지 않습니다." % str(_get_chancellor_policy_entry(policy_id).get("name", policy_id))


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
	print("[WorldMap] Wild army edit placeholder selected. Army editing is deferred.")
	world_status_hint_label.text = "야군 편집은 후속 Army 단계에서 연결됩니다."


func _on_save_placeholder_pressed() -> void:
	print("[WorldMap] Save placeholder selected. Save/load integration is deferred.")
	world_status_hint_label.text = "저장 기능은 이 HUD 외형 단계에서 실행되지 않습니다."


func _on_load_placeholder_pressed() -> void:
	print("[WorldMap] Load placeholder selected. Save/load integration is deferred.")
	world_status_hint_label.text = "불러오기 기능은 이 HUD 외형 단계에서 실행되지 않습니다."


func _on_reset_placeholder_pressed() -> void:
	print("[WorldMap] Reset placeholder selected. Reset integration is deferred.")
	world_status_hint_label.text = "초기화 기능은 이 HUD 외형 단계에서 실행되지 않습니다."


func _on_diplomacy_mode_placeholder_pressed() -> void:
	print("[WorldMap] Diplomacy tab placeholder selected. Diplomacy logic is deferred.")
	diplomacy_hint_label.text = "외교 행동은 준비 중입니다."


func _on_spy_mode_placeholder_pressed() -> void:
	print("[WorldMap] Spy tab placeholder selected. Spy logic is deferred.")
	diplomacy_hint_label.text = "첩보 판정은 준비 중입니다."


func _on_city_detail_tab_pressed(tab_id: String) -> void:
	if not [CITY_DETAIL_TAB_RESOURCES, CITY_DETAIL_TAB_INTERNAL_TRADE, CITY_DETAIL_TAB_EXTERNAL_TRADE].has(tab_id):
		tab_id = CITY_DETAIL_TAB_RESOURCES
	_selected_city_detail_tab = tab_id
	print("[WorldMap] City detail tab selected: %s. Display only; no domestic/trade effect applied." % tab_id)
	if selected_city_marker != null:
		_show_city_detail(selected_city_marker)
	else:
		_reset_city_detail_panel()
	city_detail_hint_label.text = "%s 탭 표시 전환됨. 실제 내정/무역 처리는 실행하지 않습니다." % _get_city_detail_tab_label(tab_id)


func _get_city_detail_tab_label(tab_id: String) -> String:
	match tab_id:
		CITY_DETAIL_TAB_INTERNAL_TRADE:
			return "자국무역"
		CITY_DETAIL_TAB_EXTERNAL_TRADE:
			return "타국무역"
		_:
			return "자원"


func _on_city_detail_collapse_placeholder_pressed() -> void:
	print("[WorldMap] City detail collapse placeholder selected. Collapse behavior is deferred.")
	city_detail_hint_label.text = "접기 동작은 placeholder입니다."


func _on_city_detail_domestic_placeholder_pressed() -> void:
	print("[WorldMap] City detail domestic placeholder selected. Domestic execution is deferred.")
	city_detail_hint_label.text = "내정 실행은 아직 수치나 턴 처리와 연결되지 않았습니다."
