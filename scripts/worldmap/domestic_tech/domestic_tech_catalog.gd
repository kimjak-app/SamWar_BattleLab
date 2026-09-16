class_name WorldMapDomesticTechCatalog
extends RefCounted

const DomesticTechHelperLib := preload("res://scripts/worldmap/domestic_tech/domestic_tech_helpers.gd")

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


func get_categories() -> Dictionary:
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


func get_city_definitions() -> Dictionary:
	return {
		"agri_tool_upgrade": make_city_definition("agri_tool_upgrade", "농기구 개량", DOMESTIC_TECH_CATEGORY_AGRI, "harvest", 1, 0, [], [], {}, ["administrative"], {"wood": 100, "gold": 50}, "food_yield_percent", 10, "식량 수확량 +10%", "res://assets/ui/tech_icons/agri/tech_agri_tool_upgrade.png"),
		"agri_irrigation": make_city_definition("agri_irrigation", "관개수로", DOMESTIC_TECH_CATEGORY_AGRI, "harvest", 2, 0, ["agri_tool_upgrade"], [], {}, ["administrative"], {"wood": 200, "gold": 100}, "grain_yield_percent", 20, "쌀·보리 수확량 +20%", "res://assets/ui/tech_icons/agri/tech_agri_irrigation.png"),
		"agri_double_cropping": make_city_definition("agri_double_cropping", "이모작", DOMESTIC_TECH_CATEGORY_AGRI, "harvest", 3, 0, ["agri_irrigation"], [], {}, ["administrative"], {"wood": 300, "gold": 200}, "food_production_turns", 1, "봄·가을 둘 다 수확, 식량 생산 턴 +1", "res://assets/ui/tech_icons/agri/tech_agri_double_cropping.png"),
		"agri_granary_zone": make_city_definition("agri_granary_zone", "곡창지대", DOMESTIC_TECH_CATEGORY_AGRI, "harvest", 4, 1, ["agri_double_cropping"], [], {}, ["administrative"], {"wood": 500, "gold": 500}, "food_surplus_public_support", 10, "식량 잉여 극대화 + 민심 +10", "res://assets/ui/tech_icons/agri/tech_agri_granary_zon.png"),
		"agri_reservoir": make_city_definition("agri_reservoir", "저수지", DOMESTIC_TECH_CATEGORY_AGRI, "harvest", 3, 0, ["agri_irrigation"], [], {}, ["administrative"], {"wood": 300, "gold": 300}, "drought_immunity_food_yield", 10, "가뭄 피해 면역 + 수확량 +10%", "res://assets/ui/tech_icons/agri/tech_agri_reservoir.png"),
		"agri_pasture": make_city_definition("agri_pasture", "목초지", DOMESTIC_TECH_CATEGORY_AGRI, "livestock", 1, 0, [], [], {}, ["administrative"], {"wood": 150, "gold": 100}, "horse_production_per_turn", 20, "말 생산 가능 +20/턴"),
		"agri_ranch": make_city_definition("agri_ranch", "목장", DOMESTIC_TECH_CATEGORY_AGRI, "livestock", 2, 0, ["agri_pasture"], [], {}, ["administrative"], {"wood": 250, "gold": 200}, "horse_production_per_turn", 40, "말 생산 +40/턴"),
		"agri_warhorse_breeding": make_city_definition("agri_warhorse_breeding", "군마 육성", DOMESTIC_TECH_CATEGORY_AGRI, "livestock", 3, 1, ["agri_ranch"], [], {}, ["administrative", "militaryAdmin"], {"wood": 300, "gold": 400}, "cavalry_power_percent", 15, "기병 전투력 +15% + 말 생산 극대화"),
		"fish_village": make_city_definition("fish_village", "어촌 형성", DOMESTIC_TECH_CATEGORY_FISH, "coastal", 1, 0, [], [], {"city_requirements": {"coastal": true}}, ["maritime"], {"wood": 100, "gold": 50}, "seafood_production_per_turn", 30, "수산물 생산 +30/턴", "res://assets/ui/tech_icons/fish/tech_fish_village.png"),
		"fish_coastal_fishing": make_city_definition("fish_coastal_fishing", "연안 어업", DOMESTIC_TECH_CATEGORY_FISH, "coastal", 2, 0, ["fish_village"], [], {"city_requirements": {"coastal": true}}, ["maritime"], {"wood": 150, "gold": 100}, "seafood_production_per_turn", 60, "수산물 생산 +60/턴", "res://assets/ui/tech_icons/fish/tech_fish_coastal_fishing.png"),
		"fish_fleet": make_city_definition("fish_fleet", "어선단", DOMESTIC_TECH_CATEGORY_FISH, "coastal", 3, 0, ["fish_coastal_fishing"], [], {"city_requirements": {"coastal": true}}, ["maritime"], {"wood": 300, "gold": 200}, "seafood_production_per_turn", 120, "수산물 생산 +120/턴", "res://assets/ui/tech_icons/fish/tech_fish_fleet.png"),
		"fish_deep_sea_fishing": make_city_definition("fish_deep_sea_fishing", "원양 어업", DOMESTIC_TECH_CATEGORY_FISH, "coastal", 4, 1, ["fish_fleet"], [], {"city_requirements": {"coastal": true}}, ["maritime"], {"wood": 500, "gold": 400}, "seafood_winter_immunity", 1, "수산물 생산 극대화 + 겨울 식량 패널티 면역"),
		"fish_dried_supply_base": make_city_definition("fish_dried_supply_base", "건어물 보급기지", DOMESTIC_TECH_CATEGORY_FISH, "coastal", 4, 0, ["fish_fleet"], [], {"city_requirements": {"coastal": true}}, ["maritime", "militaryAdmin"], {"wood": 300, "gold": 300}, "expedition_food_cost_percent", -30, "원정 부대 식량 소모 -30%", "res://assets/ui/tech_icons/fish/tech_fish_dried_supply_base.png", ["nation_logistics_system"]),
		"fish_salt_field": make_city_definition("fish_salt_field", "염전", DOMESTIC_TECH_CATEGORY_FISH, "salt", 1, 0, [], [], {"city_requirements": {"coastal": true}}, ["maritime"], {"gold": 150}, "salt_production_per_turn", 50, "소금 생산 +50/턴"),
		"fish_salt_warehouse": make_city_definition("fish_salt_warehouse", "소금창고", DOMESTIC_TECH_CATEGORY_FISH, "salt", 2, 1, ["fish_salt_field"], [], {"city_requirements": {"coastal": true}}, ["maritime"], {"wood": 200, "gold": 300}, "food_preservation_salt_trade", 25, "식량 보존 최대화 + 무역 소금 수입 +25%"),
		"commerce_street_market": make_city_definition("commerce_street_market", "노점시장", DOMESTIC_TECH_CATEGORY_COMMERCE, "market", 1, 0, [], [], {}, ["economic"], {"gold": 100}, "gold_income_per_turn", 50, "금전 수입 +50/턴", "res://assets/ui/tech_icons/commerce/tech_commerce_street_market.png"),
		"commerce_permanent_market": make_city_definition("commerce_permanent_market", "상설시장", DOMESTIC_TECH_CATEGORY_COMMERCE, "market", 2, 0, ["commerce_street_market"], [], {}, ["economic"], {"gold": 200}, "gold_income_per_turn", 100, "금전 수입 +100/턴", "res://assets/ui/tech_icons/commerce/tech_commerce_permanent_market.png"),
		"commerce_grand_market": make_city_definition("commerce_grand_market", "대형시장", DOMESTIC_TECH_CATEGORY_COMMERCE, "market", 3, 0, ["commerce_permanent_market"], [], {}, ["economic"], {"gold": 400}, "gold_trade_income", 10, "금전 수입 +200/턴 + 무역 수입 +10%", "res://assets/ui/tech_icons/commerce/tech_commerce_grand_market.png"),
		"commerce_merchant_guild": make_city_definition("commerce_merchant_guild", "대상단", DOMESTIC_TECH_CATEGORY_COMMERCE, "market", 4, 0, ["commerce_grand_market"], ["nation_alliance_system"], {}, ["economic", "diplomatic"], {"gold": 500, "silk": 200}, "trade_income_percent", 30, "무역 수입 +30% + 인접 도시 무역 보너스"),
		"commerce_mint": make_city_definition("commerce_mint", "조폐소", DOMESTIC_TECH_CATEGORY_COMMERCE, "market", 4, 1, ["commerce_grand_market"], ["nation_currency_unification"], {}, ["economic"], {"gold": 800, "iron": 300}, "mint_income_fee", 1, "금전 생산 극대화 + 전국 거래 수수료 수입", "res://assets/ui/tech_icons/commerce/tech_commerce_mint.png"),
		"commerce_port": make_city_definition("commerce_port", "항구", DOMESTIC_TECH_CATEGORY_COMMERCE, "sea_trade", 1, 0, [], [], {"city_requirements": {"coastal": true}}, ["economic", "maritime", "diplomatic"], {"wood": 300, "gold": 200}, "sea_trade_gold_income", 100, "해상 무역 가능 + 금전 +100/턴", "res://assets/ui/tech_icons/naval/tech_naval_port.png"),
		"commerce_shipyard": make_city_definition("commerce_shipyard", "조선소", DOMESTIC_TECH_CATEGORY_COMMERCE, "sea_trade", 2, 0, ["commerce_port"], [], {"city_requirements": {"coastal": true}}, ["economic", "maritime"], {"wood": 400, "iron": 200, "gold": 300}, "naval_production_trade_ship", 1, "수군 생산 가능 + 무역선 건조", "res://assets/ui/tech_icons/naval/tech_naval_shipyard.png"),
		"commerce_trade_port": make_city_definition("commerce_trade_port", "무역항", DOMESTIC_TECH_CATEGORY_COMMERCE, "sea_trade", 3, 1, ["commerce_shipyard"], ["nation_alliance_system"], {"city_requirements": {"coastal": true}}, ["economic", "maritime", "diplomatic"], {"wood": 500, "gold": 600}, "sea_trade_route_income_percent", 50, "해상 무역 루트 추가 + 타국 교역 수입 +50%"),
		"commerce_silk_road": make_city_definition("commerce_silk_road", "실크로드", DOMESTIC_TECH_CATEGORY_COMMERCE, "silk_road", 4, 1, [], ["nation_alliance_system"], {"resource_requirements": {"silk_large_stock": true}}, ["economic", "diplomatic"], {"gold": 600, "silk": 500}, "silk_export_diplomacy", 1, "비단 수출 수입 극대화 + 외교 보너스"),
		"mil_barracks": make_city_definition("mil_barracks", "병영 설치", DOMESTIC_TECH_CATEGORY_MILITARY, "infantry", 1, 0, [], [], {}, ["militaryAdmin"], {"wood": 200, "gold": 150}, "recruitment_training", 1, "징병 가능 + 훈련 시작", "res://assets/ui/tech_icons/military/tech_mil_barracks.png"),
		"mil_infantry_training": make_city_definition("mil_infantry_training", "보병 훈련", DOMESTIC_TECH_CATEGORY_MILITARY, "infantry", 2, 0, ["mil_barracks"], [], {}, ["militaryAdmin"], {"gold": 200}, "infantry_power_percent", 10, "보병 전투력 +10%", "res://assets/ui/tech_icons/military/tech_mil_infantry_training.png"),
		"mil_elite_infantry": make_city_definition("mil_elite_infantry", "정예 보병", DOMESTIC_TECH_CATEGORY_MILITARY, "infantry", 3, 0, ["mil_infantry_training"], [], {}, ["militaryAdmin"], {"iron": 200, "gold": 300}, "infantry_power_percent", 20, "보병 전투력 +20%", "res://assets/ui/tech_icons/military/tech_mil_elite_infantry.png"),
		"mil_heavy_infantry": make_city_definition("mil_heavy_infantry", "철갑 보병", DOMESTIC_TECH_CATEGORY_MILITARY, "infantry", 4, 1, ["mil_elite_infantry"], ["nation_military_reform"], {}, ["militaryAdmin"], {"iron": 400, "gold": 500}, "infantry_power_defense_percent", 40, "보병 전투력 +40% + 방어력 대폭 상승"),
		"mil_archer_training": make_city_definition("mil_archer_training", "궁병 훈련", DOMESTIC_TECH_CATEGORY_MILITARY, "archer", 1, 0, [], [], {}, ["militaryAdmin"], {"wood": 150, "gold": 200}, "ranged_attack_unlock", 1, "원거리 공격 가능"),
		"mil_elite_archer": make_city_definition("mil_elite_archer", "정예 궁병", DOMESTIC_TECH_CATEGORY_MILITARY, "archer", 2, 0, ["mil_archer_training"], [], {}, ["militaryAdmin"], {"wood": 200, "gold": 300}, "ranged_power_percent", 25, "원거리 전투력 +25%"),
		"mil_singijeon": make_city_definition("mil_singijeon", "신기전", DOMESTIC_TECH_CATEGORY_MILITARY, "archer", 3, 1, ["mil_elite_archer"], [], {}, ["militaryAdmin"], {"wood": 300, "iron": 200, "gold": 500}, "ranged_fire_attack", 1, "원거리 전투력 극대화 + 화공 가능"),
		"mil_cavalry_training": make_city_definition("mil_cavalry_training", "기병 훈련", DOMESTIC_TECH_CATEGORY_MILITARY, "cavalry", 1, 0, [], [], {}, ["militaryAdmin"], {"horse": 50, "gold": 200}, "cavalry_production", 1, "기병 생산 가능"),
		"mil_light_cavalry": make_city_definition("mil_light_cavalry", "경기병", DOMESTIC_TECH_CATEGORY_MILITARY, "cavalry", 2, 0, ["mil_cavalry_training"], [], {}, ["militaryAdmin"], {"horse": 80, "gold": 300}, "mobility_percent", 20, "기동력 +20%"),
		"mil_heavy_cavalry": make_city_definition("mil_heavy_cavalry", "중기병", DOMESTIC_TECH_CATEGORY_MILITARY, "cavalry", 2, 0, ["mil_cavalry_training"], [], {}, ["militaryAdmin"], {"horse": 100, "iron": 200, "gold": 400}, "cavalry_power_percent", 25, "기병 전투력 +25%", "res://assets/ui/tech_icons/military/tech_mil_heavy_cavalry.png"),
		"mil_iron_cavalry": make_city_definition("mil_iron_cavalry", "철기", DOMESTIC_TECH_CATEGORY_MILITARY, "cavalry", 3, 1, ["mil_heavy_cavalry"], [], {}, ["militaryAdmin"], {"horse": 150, "iron": 400, "gold": 600}, "cavalry_power_max", 1, "기병 전투력 극대화"),
		"mil_cavalry_charge_tactics": make_city_definition("mil_cavalry_charge_tactics", "기병 돌격 전술", DOMESTIC_TECH_CATEGORY_MILITARY, "cavalry", 3, 1, ["mil_heavy_cavalry"], [], {}, ["militaryAdmin"], {"gold": 400}, "charge_formation_break", 1, "돌격 시 적 진형 붕괴 효과"),
		"naval_training": make_city_definition("naval_training", "수군 훈련", DOMESTIC_TECH_CATEGORY_MILITARY, "naval", 1, 0, ["commerce_shipyard"], [], {"city_requirements": {"coastal": true}}, ["maritime", "militaryAdmin"], {"wood": 200, "gold": 200}, "naval_production", 1, "수군 생산 가능"),
		"naval_warship_building": make_city_definition("naval_warship_building", "전선 건조", DOMESTIC_TECH_CATEGORY_MILITARY, "naval", 2, 0, ["naval_training"], [], {"city_requirements": {"coastal": true}}, ["maritime", "militaryAdmin"], {"wood": 400, "iron": 150, "gold": 300}, "naval_power_percent", 15, "수군 전투력 +15%"),
		"naval_panokseon": make_city_definition("naval_panokseon", "판옥선", DOMESTIC_TECH_CATEGORY_MILITARY, "naval", 3, 0, ["naval_warship_building"], [], {"city_requirements": {"coastal": true}}, ["maritime", "militaryAdmin"], {"wood": 600, "iron": 300, "gold": 500}, "naval_power_percent", 30, "수군 전투력 +30%"),
		"naval_turtle_ship": make_city_definition("naval_turtle_ship", "거북선", DOMESTIC_TECH_CATEGORY_MILITARY, "naval", 4, 2, ["naval_panokseon"], ["nation_military_reform"], {"city_requirements": {"coastal": true}, "required_hero_flags": ["has_hero_yi_sunsin"]}, ["maritime", "militaryAdmin"], {"wood": 1000, "iron": 800, "gold": 1500}, "naval_power_max", 1, "수군 전투력 극대화 + 무적 함선", "res://assets/ui/tech_icons/naval/tech_naval_turtle_ship.png"),
		"naval_crane_wing_formation": make_city_definition("naval_crane_wing_formation", "학익진", DOMESTIC_TECH_CATEGORY_MILITARY, "naval", 5, 2, ["naval_turtle_ship"], [], {"city_requirements": {"coastal": true}, "required_hero_flags": ["has_hero_yi_sunsin"]}, ["maritime", "militaryAdmin"], {"gold": 800}, "naval_formation_max", 1, "해전 최강 진형 + 포위 공격 가능"),
		"naval_fire_ship": make_city_definition("naval_fire_ship", "화공선", DOMESTIC_TECH_CATEGORY_MILITARY, "naval", 4, 0, ["naval_panokseon"], [], {"city_requirements": {"coastal": true}}, ["maritime", "militaryAdmin"], {"wood": 400, "gold": 300}, "naval_fire_attack", 1, "화공 공격 가능"),
		"naval_cannon_mount": make_city_definition("naval_cannon_mount", "화포 장착", DOMESTIC_TECH_CATEGORY_MILITARY, "naval", 4, 1, ["naval_panokseon"], [], {"city_requirements": {"coastal": true}}, ["maritime", "militaryAdmin"], {"iron": 400, "gold": 500}, "naval_ranged_attack", 1, "원거리 해상 공격 가능"),
		"mil_wall_upgrade": make_city_definition("mil_wall_upgrade", "성벽 강화", DOMESTIC_TECH_CATEGORY_MILITARY, "defense", 1, 0, [], [], {}, ["militaryAdmin"], {"wood": 400, "iron": 300, "gold": 300}, "defense_percent", 20, "방어력 +20%"),
		"mil_moat": make_city_definition("mil_moat", "해자", DOMESTIC_TECH_CATEGORY_MILITARY, "defense", 2, 0, ["mil_wall_upgrade"], [], {}, ["militaryAdmin"], {"wood": 500, "gold": 400}, "defense_siege_slow", 15, "방어력 +15% + 공성 속도 감소"),
		"mil_double_moat": make_city_definition("mil_double_moat", "이중 해자", DOMESTIC_TECH_CATEGORY_MILITARY, "defense", 3, 0, ["mil_moat"], [], {}, ["militaryAdmin"], {"wood": 600, "iron": 400, "gold": 600}, "defense_percent", 25, "방어력 +25%"),
		"mil_watchtower": make_city_definition("mil_watchtower", "망루", DOMESTIC_TECH_CATEGORY_MILITARY, "defense", 2, 0, ["mil_wall_upgrade"], [], {}, ["militaryAdmin"], {"wood": 300, "iron": 200, "gold": 200}, "invasion_warning_turns", 1, "적 침공 1턴 전 경고"),
		"mil_beacon": make_city_definition("mil_beacon", "봉화대", DOMESTIC_TECH_CATEGORY_MILITARY, "defense", 3, 0, ["mil_watchtower"], [], {}, ["militaryAdmin"], {"wood": 200, "gold": 200}, "adjacent_invasion_warning", 1, "인접 도시 침공 경고"),
		"mil_beacon_network": make_city_definition("mil_beacon_network", "봉화 네트워크", DOMESTIC_TECH_CATEGORY_MILITARY, "defense", 4, 1, ["mil_beacon"], [], {}, ["militaryAdmin"], {"gold": 500}, "national_invasion_warning", 1, "전국 침공 즉시 경고"),
		"mil_iron_gate": make_city_definition("mil_iron_gate", "철문 설치", DOMESTIC_TECH_CATEGORY_MILITARY, "defense", 2, 0, ["mil_wall_upgrade"], [], {}, ["militaryAdmin"], {"iron": 500, "wood": 300, "gold": 400}, "defense_percent", 20, "방어력 +20%"),
		"mil_iron_fortress": make_city_definition("mil_iron_fortress", "철옹성", DOMESTIC_TECH_CATEGORY_MILITARY, "defense", 5, 1, ["mil_double_moat", "mil_beacon_network", "mil_iron_gate"], [], {"min_loyalty": 75}, ["militaryAdmin"], {"iron": 1000, "wood": 800, "gold": 1500}, "defense_max", 1, "방어력 극대화 + 함락 거의 불가"),
		"mil_siege_unit": make_city_definition("mil_siege_unit", "공성 부대", DOMESTIC_TECH_CATEGORY_MILITARY, "siege", 1, 0, [], [], {}, ["militaryAdmin"], {"wood": 300, "gold": 300}, "siege_power_percent", 30, "공성 능력 +30%"),
		"mil_siege_engine": make_city_definition("mil_siege_engine", "공성 병기", DOMESTIC_TECH_CATEGORY_MILITARY, "siege", 2, 1, ["mil_siege_unit"], [], {}, ["militaryAdmin"], {"wood": 500, "iron": 300, "gold": 500}, "siege_power_max", 1, "공성 능력 극대화 + 성벽 돌파 가능"),
	}


func get_national_definitions() -> Dictionary:
	return {
		"nation_foundation": make_national_definition("nation_foundation", "국가 기반 정비", DOMESTIC_TECH_CATEGORY_NATION_ADMIN, "administration", 1, 0, [], {}, {"gold": 200}, "governor_capacity", 0, "태수 임명 가능 도시 수 증가", "res://assets/ui/tech_icons/nation/tech_nation_foundation.png"),
		"nation_law_reform": make_national_definition("nation_law_reform", "법률 정비", DOMESTIC_TECH_CATEGORY_NATION_ADMIN, "administration", 2, 0, ["nation_foundation"], {"chancellor_aptitudes": ["administrative"]}, {"gold": 300, "silk": 100}, "public_support_national", 5, "전국 민심 +5", "res://assets/ui/tech_icons/nation/tech_nation_law_reform.png"),
		"nation_bureaucracy": make_national_definition("nation_bureaucracy", "관료 체계", DOMESTIC_TECH_CATEGORY_NATION_ADMIN, "administration", 3, 0, ["nation_law_reform"], {"owned_city_count": 2}, {"gold": 500, "silk": 200}, "governor_effect_percent", 10, "태수 효과 +10%", "res://assets/ui/tech_icons/nation/tech_nation_bureaucracy.png"),
		"nation_local_administration": make_national_definition("nation_local_administration", "지방 행정", DOMESTIC_TECH_CATEGORY_NATION_ADMIN, "administration", 4, 0, ["nation_bureaucracy"], {"owned_city_count": 3, "governor_assigned_city_count": 2}, {"gold": 600, "silk": 300}, "city_tax_efficiency", 1, "도시별 세금 효율 증가"),
		"nation_centralization": make_national_definition("nation_centralization", "중앙집권", DOMESTIC_TECH_CATEGORY_NATION_ADMIN, "administration", 5, 1, ["nation_local_administration"], {"chancellor_aptitudes": ["administrative"], "national_loyalty": 70, "owned_city_count": 5}, {"gold": 1000, "silk": 500}, "all_city_income_percent", 20, "모든 도시 수입 +20% + 태수 효과 극대화", "res://assets/ui/tech_icons/nation/tech_nation_centralization.png"),
		"nation_inspection_system": make_national_definition("nation_inspection_system", "감찰 제도", DOMESTIC_TECH_CATEGORY_NATION_ADMIN, "inspection", 4, 0, ["nation_bureaucracy"], {"chancellor_aptitudes": ["political"]}, {"gold": 400, "silk": 200}, "gold_loss_reduction", 1, "금전 손실 감소"),
		"nation_anti_corruption": make_national_definition("nation_anti_corruption", "부패 방지", DOMESTIC_TECH_CATEGORY_NATION_ADMIN, "inspection", 5, 1, ["nation_inspection_system"], {"national_loyalty": 65}, {"gold": 600, "silk": 300}, "tax_efficiency_max", 1, "세금 효율 극대화"),
		"nation_household_registry": make_national_definition("nation_household_registry", "호적 제도", DOMESTIC_TECH_CATEGORY_NATION_ADMIN, "population", 2, 0, ["nation_foundation"], {"owned_city_count": 2}, {"gold": 400}, "conscription_capacity_percent", 10, "징병 가능 인원 +10%"),
		"nation_population_census": make_national_definition("nation_population_census", "인구 조사", DOMESTIC_TECH_CATEGORY_NATION_ADMIN, "population", 3, 0, ["nation_household_registry"], {"chancellor_aptitudes": ["administrative"]}, {"gold": 500, "food": 200}, "conscription_efficiency", 1, "징병 효율 증가"),
		"nation_population_policy": make_national_definition("nation_population_policy", "인구 정책", DOMESTIC_TECH_CATEGORY_NATION_ADMIN, "population", 4, 1, ["nation_population_census"], {"owned_city_count": 4, "average_public_support": 70}, {"gold": 800, "food": 500}, "population_growth_conscription_limit", 1, "전국 인구 성장 + 징병 한계 증가"),
		"nation_tax_reform": make_national_definition("nation_tax_reform", "세제 개혁", DOMESTIC_TECH_CATEGORY_NATION_ECONOMY, "tax", 1, 0, [], {"chancellor_aptitudes": ["economic"]}, {"gold": 400}, "national_gold_income_percent", 10, "전국 금전 수입 +10%", "res://assets/ui/tech_icons/nation/tech_nation_tax_reform.png"),
		"nation_equal_tax": make_national_definition("nation_equal_tax", "균등세", DOMESTIC_TECH_CATEGORY_NATION_ECONOMY, "tax", 2, 0, ["nation_tax_reform"], {"owned_city_count": 2}, {"gold": 500, "silk": 100}, "tax_public_support", 1, "민심 상승, 세금 불만 감소"),
		"nation_currency_unification": make_national_definition("nation_currency_unification", "화폐 통일", DOMESTIC_TECH_CATEGORY_NATION_ECONOMY, "tax", 3, 0, ["nation_equal_tax"], {"chancellor_aptitudes": ["economic"], "average_commerce": 50}, {"gold": 800, "iron": 200}, "trade_income_percent", 15, "무역 수입 +15%", "", ["commerce_mint"]),
		"nation_national_economy": make_national_definition("nation_national_economy", "국가 경제", DOMESTIC_TECH_CATEGORY_NATION_ECONOMY, "tax", 4, 1, ["nation_currency_unification"], {"owned_city_count": 4, "required_city_techs": ["commerce_mint"]}, {"gold": 1500, "silk": 500}, "national_gold_income_max", 1, "전국 금전 수입 극대화"),
		"nation_monopoly_system": make_national_definition("nation_monopoly_system", "전매 제도", DOMESTIC_TECH_CATEGORY_NATION_ECONOMY, "monopoly", 2, 0, ["nation_tax_reform"], {"resource_monopoly_candidates": ["salt", "silk"]}, {"gold": 600, "silk": 200}, "strategic_resource_income", 1, "소금·비단 독점 수입 증가"),
		"nation_national_monopoly": make_national_definition("nation_national_monopoly", "국가 전매", DOMESTIC_TECH_CATEGORY_NATION_ECONOMY, "monopoly", 3, 1, ["nation_monopoly_system"], {"chancellor_aptitudes": ["economic"], "resource_surplus": ["salt", "silk"]}, {"gold": 1000, "silk": 400, "salt": 400}, "strategic_resource_income_max", 1, "전략 자원 독점, 금전 대폭 증가"),
		"nation_conscription": make_national_definition("nation_conscription", "징병 제도", DOMESTIC_TECH_CATEGORY_NATION_MILITARY, "military", 1, 0, [], {"chancellor_aptitudes": ["militaryAdmin"]}, {"gold": 300, "food": 200}, "national_conscription_efficiency_percent", 10, "전국 징병 효율 +10%"),
		"nation_military_training_order": make_national_definition("nation_military_training_order", "군사 훈련령", DOMESTIC_TECH_CATEGORY_NATION_MILITARY, "military", 2, 0, ["nation_conscription"], {"average_loyalty": 60}, {"iron": 200, "gold": 400, "food": 300}, "national_combat_power_percent", 10, "전국 전투력 +10%"),
		"nation_military_reform": make_national_definition("nation_military_reform", "군사 개혁", DOMESTIC_TECH_CATEGORY_NATION_MILITARY, "military", 3, 0, ["nation_military_training_order"], {"chancellor_aptitudes": ["militaryAdmin"]}, {"iron": 500, "gold": 600, "food": 400}, "national_combat_power_percent", 20, "전국 전투력 +20%", "", ["naval_turtle_ship", "mil_heavy_infantry"]),
		"nation_standing_army": make_national_definition("nation_standing_army", "상비군", DOMESTIC_TECH_CATEGORY_NATION_MILITARY, "military", 4, 1, ["nation_military_reform"], {"average_loyalty": 75, "owned_city_count": 4}, {"iron": 800, "gold": 1000, "food": 800}, "national_combat_power_max", 1, "전국 전투력 극대화 + 징병 속도 증가"),
		"nation_logistics_system": make_national_definition("nation_logistics_system", "병참 제도", DOMESTIC_TECH_CATEGORY_NATION_MILITARY, "logistics", 2, 0, ["nation_conscription"], {"connected_supply_city_count": 3}, {"food": 500, "salt": 300, "gold": 400}, "expedition_supply_stability", 1, "원정 보급 안정", "", [], ["fish_dried_supply_base"]),
		"nation_expedition_system": make_national_definition("nation_expedition_system", "원정 체계", DOMESTIC_TECH_CATEGORY_NATION_MILITARY, "logistics", 3, 1, ["nation_logistics_system"], {"required_city_techs": ["fish_dried_supply_base", "fish_salt_warehouse"]}, {"food": 800, "salt": 500, "gold": 600}, "long_expedition_supply", 1, "장거리 원정 가능 + 보급 손실 없음"),
		"nation_weapon_standardization": make_national_definition("nation_weapon_standardization", "무기 규격화", DOMESTIC_TECH_CATEGORY_NATION_MILITARY, "weapon", 2, 0, ["nation_conscription"], {"chancellor_aptitudes": ["militaryAdmin"], "resource_requirements": {"iron": true}}, {"iron": 300, "gold": 400}, "national_combat_power", 1, "전국 전투력 증가"),
		"nation_weapon_factory": make_national_definition("nation_weapon_factory", "무기 공장", DOMESTIC_TECH_CATEGORY_NATION_MILITARY, "weapon", 3, 1, ["nation_weapon_standardization"], {"required_city_techs": ["mil_siege_engine"]}, {"iron": 600, "wood": 400, "gold": 800}, "recruitment_cost_reduction", 1, "무기 대량 생산, 징병 비용 감소"),
		"nation_envoy": make_national_definition("nation_envoy", "사신 파견", DOMESTIC_TECH_CATEGORY_NATION_DIPLOMACY, "diplomacy", 1, 0, [], {"chancellor_aptitudes": ["diplomatic"]}, {"gold": 300, "silk": 200}, "diplomacy_action_unlock", 1, "외교 행동 가능"),
		"nation_diplomacy_system": make_national_definition("nation_diplomacy_system", "외교 체계", DOMESTIC_TECH_CATEGORY_NATION_DIPLOMACY, "diplomacy", 2, 0, ["nation_envoy"], {"neutral_faction_count": 2}, {"gold": 400, "silk": 300}, "relation_improvement_speed", 1, "관계 개선 속도 증가"),
		"nation_alliance_system": make_national_definition("nation_alliance_system", "동맹 체계", DOMESTIC_TECH_CATEGORY_NATION_DIPLOMACY, "diplomacy", 3, 0, ["nation_diplomacy_system"], {"chancellor_aptitudes": ["diplomatic"], "allied_faction_count": 1}, {"gold": 600, "silk": 400}, "alliance_trade_income", 1, "동맹 효과 강화, 무역 수입 증가", "", ["commerce_merchant_guild", "commerce_trade_port", "commerce_silk_road"]),
		"nation_world_diplomacy": make_national_definition("nation_world_diplomacy", "천하 외교", DOMESTIC_TECH_CATEGORY_NATION_DIPLOMACY, "diplomacy", 4, 1, ["nation_alliance_system"], {"allied_faction_count": 2, "required_city_tech_any": ["commerce_silk_road", "commerce_trade_port"]}, {"gold": 1000, "silk": 800}, "world_trade_diplomacy_action", 1, "전국 무역 극대화 + 외교 공작 가능", "res://assets/ui/tech_icons/nation/tech_nation_world_diplomacy.png"),
		"nation_intelligence_system": make_national_definition("nation_intelligence_system", "첩보 체계", DOMESTIC_TECH_CATEGORY_NATION_DIPLOMACY, "intelligence", 2, 0, ["nation_envoy"], {"chancellor_aptitudes": ["political"]}, {"gold": 500, "silk": 200}, "enemy_info_collection", 1, "적 정보 수집 가능"),
		"nation_intelligence_org": make_national_definition("nation_intelligence_org", "첩보 조직", DOMESTIC_TECH_CATEGORY_NATION_DIPLOMACY, "intelligence", 3, 1, ["nation_intelligence_system"], {"owned_city_count": 3, "chancellor_aptitudes": ["diplomatic", "political"], "unlocks_flags": ["enemy_city_operation"]}, {"gold": 800, "silk": 400}, "national_spy_activity", 1, "전국 첩보 활동 가능"),
		"nation_tribute_system": make_national_definition("nation_tribute_system", "조공 체계", DOMESTIC_TECH_CATEGORY_NATION_DIPLOMACY, "tribute", 2, 0, ["nation_envoy"], {"neutral_faction_count": 1, "resource_surplus": ["silk"]}, {"gold": 200, "silk": 300}, "tribute_relation_speed", 1, "비단으로 관계 개선 속도 증가"),
		"nation_tribute_network": make_national_definition("nation_tribute_network", "조공 네트워크", DOMESTIC_TECH_CATEGORY_NATION_DIPLOMACY, "tribute", 3, 1, ["nation_tribute_system"], {"required_national_techs": ["nation_alliance_system"], "resource_surplus": ["silk"]}, {"gold": 600, "silk": 600}, "tribute_diplomacy_max", 1, "비단 외교 극대화, 동맹 유지 비용 감소"),
	}


func make_city_definition(id: String, tech_name: String, category: String, branch: String, tier: int, rarity: int, prerequisites: Array, required_national_techs: Array, special_requirements: Dictionary, governor_aptitudes: Array, cost: Dictionary, effect_type: String, effect_value: Variant, effect_description: String, icon_path: String = "", enhanced_by_national_techs: Array = []) -> Dictionary:
	return make_definition(id, tech_name, DOMESTIC_TECH_SCOPE_CITY, DOMESTIC_TECH_UI_SURFACE_CITY, category, branch, tier, rarity, prerequisites, required_national_techs, special_requirements, governor_aptitudes, DOMESTIC_TECH_PROGRESS_CITY, cost, effect_type, effect_value, effect_description, icon_path, [], enhanced_by_national_techs)


func make_national_definition(id: String, tech_name: String, category: String, branch: String, tier: int, rarity: int, prerequisites: Array, special_requirements: Dictionary, cost: Dictionary, effect_type: String, effect_value: Variant, effect_description: String, icon_path: String = "", unlocks_city_techs: Array = [], enhances_city_techs: Array = []) -> Dictionary:
	return make_definition(id, tech_name, DOMESTIC_TECH_SCOPE_NATIONAL, DOMESTIC_TECH_UI_SURFACE_NATIONAL, category, branch, tier, rarity, prerequisites, [], special_requirements, [], DOMESTIC_TECH_PROGRESS_NATIONAL, cost, effect_type, effect_value, effect_description, icon_path, unlocks_city_techs, enhances_city_techs)


func make_definition(id: String, tech_name: String, tree_scope: String, ui_surface: String, category: String, branch: String, tier: int, rarity: int, prerequisites: Array, required_national_techs: Array, special_requirements: Dictionary, governor_aptitudes: Array, progress_mode: String, cost: Dictionary, effect_type: String, effect_value: Variant, effect_description: String, icon_path: String, unlocks_city_techs: Array, enhances_city_techs: Array) -> Dictionary:
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
		"duration_class": get_duration_class(tier, rarity),
		"duration_turns_hint": {"min": get_scope_duration_turns(tree_scope, tier, rarity), "max": get_scope_duration_turns(tree_scope, tier, rarity), "rule": "scope_tier_balance_v0_70_86", "rarity": rarity},
		"effect_stub": {"enabled": false, "type": effect_type, "value": effect_value, "description": effect_description},
		"unlocks_city_techs": unlocks_city_techs.duplicate(true),
		"enhances_city_techs": enhances_city_techs.duplicate(true),
	}


func get_duration_class(tier: int, rarity: int) -> String:
	return DomesticTechHelperLib.get_duration_class_mvp(tier, rarity)


func get_duration_turns_hint(tier: int, rarity: int) -> Dictionary:
	return DomesticTechHelperLib.get_duration_turns_hint_mvp(tier, rarity)


func get_tier_duration_turns(tier: int) -> int:
	return DomesticTechHelperLib.get_tier_duration_turns_mvp(tier)


func get_scope_duration_turns(scope: String, tier: int, rarity: int = 0) -> int:
	return DomesticTechHelperLib.get_scope_duration_turns_mvp(scope, tier, rarity, DOMESTIC_TECH_SCOPE_NATIONAL)


func get_definitions() -> Dictionary:
	var definitions := get_city_definitions()
	var national_definitions := get_national_definitions()
	for tech_id_variant in national_definitions.keys():
		var tech_id := str(tech_id_variant)
		definitions[tech_id] = national_definitions.get(tech_id_variant)
	return definitions


func get_definition(tech_id: String) -> Dictionary:
	var definitions := get_definitions()
	var definition: Variant = definitions.get(tech_id, {})
	if definition is Dictionary:
		return (definition as Dictionary).duplicate(true)
	return {}


func get_by_scope(scope: String) -> Array:
	var result: Array[String] = []
	for tech_id_variant in get_definitions().keys():
		var tech_id := str(tech_id_variant)
		var definition := get_definition(tech_id)
		if str(definition.get("tree_scope", "")) == scope:
			result.append(tech_id)
	result.sort()
	return result


func get_by_category(category_id: String) -> Array:
	var result: Array[String] = []
	for tech_id_variant in get_definitions().keys():
		var tech_id := str(tech_id_variant)
		var definition := get_definition(tech_id)
		if str(definition.get("category", "")) == category_id:
			result.append(tech_id)
	result.sort()
	return result


func get_by_branch(category_id: String, branch_id: String) -> Array:
	var result: Array[String] = []
	for tech_id_variant in get_definitions().keys():
		var tech_id := str(tech_id_variant)
		var definition := get_definition(tech_id)
		if str(definition.get("category", "")) == category_id and str(definition.get("branch", "")) == branch_id:
			result.append(tech_id)
	result.sort()
	return result


func is_city_tech(tech_id: String) -> bool:
	return get_city_definitions().has(tech_id)


func is_national_tech(tech_id: String) -> bool:
	return get_national_definitions().has(tech_id)
