class_name WorldMapCityInfoPanel
extends PanelContainer

const HeroPortraitHelper := preload("res://scripts/worldmap_hero_portrait_helper.gd")
const PLAYER_FACTION_ID := "player"

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

# v0.68b-12b-10a WorldMap Right City Info Panel Web Parity Cleanup
# v0.68b-12b-10b WorldMap Hero Portrait Asset Binding MVP

@onready var eyebrow_label: Label = $MarginContainer/Content/EyebrowLabel
@onready var city_name_label: Label = $MarginContainer/Content/CityNameLabel
@onready var description_label: Label = $MarginContainer/Content/DescriptionLabel
@onready var city_id_label: Label = $MarginContainer/Content/CityIdLabel
@onready var region_owner_label: Label = $MarginContainer/Content/RegionOwnerLabel
@onready var city_type_label: Label = $MarginContainer/Content/CityTypeLabel
@onready var neighbor_label: Label = $MarginContainer/Content/NeighborLabel
@onready var route_type_label: Label = $MarginContainer/Content/RouteTypeLabel
@onready var status_text_label: Label = $MarginContainer/Content/StatusTextLabel
@onready var loyalty_label: Label = $MarginContainer/Content/LoyaltyCard/MarginContainer/Content/LoyaltyLabel
@onready var loyalty_bar: ProgressBar = $MarginContainer/Content/LoyaltyCard/MarginContainer/Content/LoyaltyBar
@onready var governor_label: Label = $MarginContainer/Content/GovernorLabel
@onready var governor_portrait_label: Label = $MarginContainer/Content/GovernorCard/MarginContainer/Content/HeaderRow/PortraitBox/PortraitLabel
@onready var governor_name_label: Label = $MarginContainer/Content/GovernorCard/MarginContainer/Content/HeaderRow/Copy/GovernorNameLabel
@onready var governor_stats_label: Label = $MarginContainer/Content/GovernorCard/MarginContainer/Content/HeaderRow/Copy/GovernorStatsLabel
@onready var governor_policy_option: OptionButton = $MarginContainer/Content/GovernorCard/MarginContainer/Content/GovernorPolicyOption
@onready var governor_policy_description_label: Label = $MarginContainer/Content/GovernorCard/MarginContainer/Content/GovernorPolicyDescriptionLabel
@onready var selected_hero_chip_label: Label = $MarginContainer/Content/SelectedHeroChipLabel
@onready var garrison_label: Label = $MarginContainer/Content/GarrisonLabel
@onready var military_info_label: Label = $MarginContainer/Content/MilitaryInfoLabel
@onready var military_state_label: Label = $MarginContainer/Content/MilitaryStateLabel
@onready var hint_label: Label = $MarginContainer/Content/HintLabel
@onready var attack_button_placeholder: Button = $MarginContainer/Content/ButtonRow/AttackButtonPlaceholder
@onready var hero_move_button_placeholder: Button = $MarginContainer/Content/ButtonRow/HeroMoveButtonPlaceholder
@onready var domestic_button_placeholder: Button = $MarginContainer/Content/ButtonRow/DomesticButtonPlaceholder
@onready var recruit_button_placeholder: Button = $MarginContainer/Content/RecruitButtonPlaceholder

var _city_markers_by_id: Dictionary = {}
var _hero_data: Dictionary = {}
var _city_hud_data: Dictionary = {}
var _governor_policy_data: Dictionary = {}
var _city_policy_state: Dictionary = {}
var _pending_invasion_event: Dictionary = {}
var _current_city_id := ""
var _governor_portrait_texture_rect: TextureRect = null


func _ready() -> void:
	city_id_label.visible = false
	_ensure_governor_portrait_texture_rect()
	attack_button_placeholder.pressed.connect(_on_attack_placeholder_pressed)
	hero_move_button_placeholder.pressed.connect(_on_hero_move_placeholder_pressed)
	domestic_button_placeholder.pressed.connect(_on_domestic_placeholder_pressed)
	recruit_button_placeholder.pressed.connect(_on_recruit_placeholder_pressed)
	if not governor_policy_option.item_selected.is_connected(_on_governor_policy_selected):
		governor_policy_option.item_selected.connect(_on_governor_policy_selected)
	_show_empty()


func set_city_markers(city_markers_by_id: Dictionary) -> void:
	_city_markers_by_id = city_markers_by_id


func set_hud_data(hero_data: Dictionary, city_hud_data: Dictionary, governor_policy_data: Dictionary, city_policy_state: Dictionary) -> void:
	_hero_data = hero_data
	_city_hud_data = city_hud_data
	_governor_policy_data = governor_policy_data
	_city_policy_state = city_policy_state
	_setup_governor_policy_option()
	if not _current_city_id.is_empty() and _city_markers_by_id.has(_current_city_id):
		show_city(_city_markers_by_id.get(_current_city_id) as WorldMapCityMarker)


func set_pending_invasion_event(event: Dictionary) -> void:
	_pending_invasion_event = event.duplicate(true)
	if not _current_city_id.is_empty():
		_refresh_pending_invasion_status_line(_current_city_id)


func show_city(city_marker: WorldMapCityMarker) -> void:
	if city_marker == null:
		_show_empty()
		return

	_current_city_id = city_marker.city_id
	var city_data := _get_city_hud_entry(city_marker.city_id)
	var loyalty := int(city_data.get("loyalty", 75))
	var governor_id := str(city_data.get("governor_id", ""))
	var governor_data := _get_hero_entry(governor_id)
	var policy_id := _get_city_policy_id(city_marker.city_id, city_data)
	var policy_data := _get_governor_policy_entry(policy_id)
	var stationed_hero_ids := _get_city_stationed_hero_ids(city_data)

	eyebrow_label.text = "SELECTED CITY"
	city_name_label.text = _get_city_display_name(city_marker.city_id, city_marker.display_name)
	description_label.text = "소유: %s · 지역: %s" % [
		_get_city_owner_label(city_marker, city_data),
		_get_city_region_label(city_marker, city_data),
	]
	city_id_label.visible = false
	city_id_label.text = ""
	region_owner_label.text = "세력: %s · 국가: %s" % [
		_get_city_owner_label(city_marker, city_data),
		_get_city_nation_label(city_marker, city_data),
	]
	city_type_label.text = "유형: %s" % _format_city_type(city_marker.city_id)
	neighbor_label.text = _format_city_core_info(city_data)
	route_type_label.text = _format_city_resource_info(city_data)
	status_text_label.text = _format_pending_invasion_city_status(city_marker.city_id)
	loyalty_label.text = "성 충성도 %d · 표시 전용" % loyalty
	loyalty_bar.value = loyalty
	_update_governor_card(governor_id, governor_data, policy_id, policy_data)
	governor_label.text = "태수: %s" % _get_hero_display_name(governor_data, "태수 없음")
	selected_hero_chip_label.text = "주둔 장수"
	garrison_label.text = _format_stationed_hero_list(stationed_hero_ids)
	military_info_label.text = _format_city_defense_info(city_data)
	military_state_label.text = _format_city_domestic_info(city_data)
	hint_label.text = "정책: %s · %s" % [
		str(policy_data.get("name", "정보 없음")),
		str(policy_data.get("description", "정보 없음")),
	]
	show()


func _show_empty() -> void:
	_current_city_id = ""
	eyebrow_label.text = "SELECTED CITY"
	city_name_label.text = "선택 도시 없음"
	description_label.text = "월드맵에서 도시를 선택하십시오."
	city_id_label.visible = false
	city_id_label.text = ""
	region_owner_label.text = "소유: 정보 없음 · 지역: 정보 없음"
	city_type_label.text = "유형: 정보 없음"
	neighbor_label.text = "인구: 정보 없음 · 금전: 정보 없음 · 식량: 정보 없음"
	route_type_label.text = "자원: 정보 없음"
	status_text_label.text = "선택 도시 없음"
	loyalty_label.text = "성 충성도 정보 없음"
	loyalty_bar.value = 0
	governor_label.text = "태수 없음"
	HeroPortraitHelper.apply_hero_portrait_or_placeholder(_governor_portrait_texture_rect, governor_portrait_label, {})
	governor_name_label.text = "태수 없음"
	governor_stats_label.text = "능력: -"
	_setup_governor_policy_option()
	governor_policy_description_label.text = "도시 선택 시 태수 정책 설명이 표시됩니다."
	selected_hero_chip_label.text = "주둔 장수"
	garrison_label.text = "주둔 장수 없음"
	military_info_label.text = "병력: 정보 없음 · 방어: 정보 없음"
	military_state_label.text = "민심/치안: 정보 없음 · 상업: 정보 없음 · 농업: 정보 없음"
	hint_label.text = "정보 없음"
	show()


func _setup_governor_policy_option() -> void:
	if governor_policy_option == null:
		return
	governor_policy_option.clear()
	for policy_id in _governor_policy_data.keys():
		var policy_data: Dictionary = _governor_policy_data[policy_id]
		governor_policy_option.add_item(str(policy_data.get("name", policy_id)))
		governor_policy_option.set_item_metadata(governor_policy_option.item_count - 1, policy_id)


func _format_region_label(region_id: String) -> String:
	return str(REGION_LABELS.get(region_id, region_id))


func _format_faction_label(owner_faction_id: String) -> String:
	if owner_faction_id.is_empty():
		return "정보 없음"
	return str(FACTION_LABELS.get(owner_faction_id, owner_faction_id))


func _format_city_type(city_id: String) -> String:
	return str(CITY_TYPE_LABELS.get(city_id, "거점"))


func _format_neighbors(neighbor_ids: Array[String]) -> String:
	if neighbor_ids.is_empty():
		return "없음"

	var neighbor_names: Array[String] = []
	for neighbor_id in neighbor_ids:
		var neighbor_marker := _city_markers_by_id.get(neighbor_id) as WorldMapCityMarker
		if neighbor_marker != null and not neighbor_marker.display_name.is_empty():
			neighbor_names.append(neighbor_marker.display_name)
		else:
			neighbor_names.append(neighbor_id)

	return ", ".join(neighbor_names)


func _format_route_types(city_marker: WorldMapCityMarker) -> String:
	if city_marker.neighbors.is_empty():
		return "없음"

	var summaries: Array[String] = []
	for neighbor_id in city_marker.neighbors:
		var route_type := str(city_marker.route_types.get(neighbor_id, "land"))
		var neighbor_marker := _city_markers_by_id.get(neighbor_id) as WorldMapCityMarker
		var neighbor_name := neighbor_id
		if neighbor_marker != null and not neighbor_marker.display_name.is_empty():
			neighbor_name = neighbor_marker.display_name
		summaries.append("%s %s" % [neighbor_name, route_type])

	return " / ".join(summaries)


func _get_city_hud_entry(city_id: String) -> Dictionary:
	return _city_hud_data.get(city_id, {})


func _get_city_display_name(city_id: String, fallback: String = "알 수 없는 도시") -> String:
	var city_data := _get_city_hud_entry(city_id)
	if not city_data.is_empty():
		return str(city_data.get("name", fallback))
	if not fallback.is_empty():
		return fallback
	return "알 수 없는 도시"


func _get_city_owner_label(city_marker: WorldMapCityMarker, city_data: Dictionary) -> String:
	var owner_id := str(city_data.get("owner", ""))
	if owner_id.is_empty() and city_marker != null:
		owner_id = city_marker.owner_faction_id
	return _format_faction_label(owner_id)


func _get_city_nation_label(city_marker: WorldMapCityMarker, city_data: Dictionary) -> String:
	var nation_id := str(city_data.get("nation", ""))
	if nation_id.is_empty() and city_marker != null:
		nation_id = city_marker.owner_faction_id
	return _format_faction_label(nation_id)


func _get_city_region_label(city_marker: WorldMapCityMarker, city_data: Dictionary) -> String:
	var region_label := str(city_data.get("region", ""))
	if not region_label.is_empty():
		return region_label
	if city_marker != null:
		return _format_region_label(city_marker.region_id)
	return "정보 없음"


func _get_city_stationed_hero_ids(city_data: Dictionary) -> Array:
	var hero_ids: Variant = city_data.get("stationed_hero_ids", city_data.get("hero_ids", []))
	if hero_ids is Array:
		return hero_ids
	return []


func _format_city_core_info(city_data: Dictionary) -> String:
	return "인구: %s · 금전: %s · 식량: %s" % [
		_format_number_field(city_data, "population"),
		_format_number_field(city_data, "gold"),
		_format_number_field(city_data, "food"),
	]


func _format_city_resource_info(city_data: Dictionary) -> String:
	var resource_seed: Dictionary = city_data.get("resource_seed", {})
	var resource_parts: Array[String] = []
	for resource_id in ["rice", "barley", "seafood", "wood", "iron", "horses", "silk", "salt"]:
		if resource_seed.has(resource_id):
			resource_parts.append("%s %d" % [_get_resource_label(resource_id), int(resource_seed.get(resource_id, 0))])
	if resource_parts.is_empty():
		return "자원: 정보 없음"
	return "자원: %s" % " / ".join(resource_parts)


func _format_city_defense_info(city_data: Dictionary) -> String:
	return "병력: %s · 방어: %s · 치안 기준: %s" % [
		_format_number_field(city_data, "troops"),
		_format_number_field(city_data, "defense"),
		_format_military_summary_value(city_data, "securityRequiredTroops"),
	]


func _format_city_domestic_info(city_data: Dictionary) -> String:
	return "민심: %s · 치안: %s · 상업: %s · 농업: %s" % [
		_format_domestic_summary_value(city_data, "publicSupport", "정보 없음"),
		_format_number_field(city_data, "public_order"),
		_format_number_field(city_data, "commerce"),
		_format_number_field(city_data, "agriculture"),
	]


func _format_number_field(data: Dictionary, key: String, fallback: String = "정보 없음") -> String:
	if not data.has(key):
		return fallback
	return "%d" % int(data.get(key, 0))


func _format_domestic_summary_value(city_data: Dictionary, key: String, fallback: String = "정보 없음") -> String:
	var domestic_seed: Dictionary = city_data.get("domestic_seed", {})
	if not domestic_seed.has(key):
		return fallback
	return "%d" % int(domestic_seed.get(key, 0))


func _format_military_summary_value(city_data: Dictionary, key: String, fallback: String = "정보 없음") -> String:
	var military_text := str(city_data.get("military", ""))
	if key == "securityRequiredTroops" and not military_text.is_empty():
		var parts := military_text.split("/")
		for part in parts:
			var trimmed := str(part).strip_edges()
			if trimmed.begins_with("치안 기준"):
				return trimmed.trim_prefix("치안 기준").strip_edges()
	return fallback


func _get_resource_label(resource_id: String) -> String:
	match resource_id:
		"rice":
			return "쌀"
		"barley":
			return "보리"
		"seafood":
			return "수산물"
		"wood":
			return "목재"
		"iron":
			return "철"
		"horses":
			return "말"
		"silk":
			return "비단"
		"salt":
			return "소금"
		_:
			return resource_id


func _get_hero_entry(hero_id: String) -> Dictionary:
	return _hero_data.get(hero_id, {})


func _get_governor_policy_entry(policy_id: String) -> Dictionary:
	if _governor_policy_data.has(policy_id):
		return _governor_policy_data[policy_id]
	if not _governor_policy_data.is_empty():
		return _governor_policy_data[_governor_policy_data.keys()[0]]
	return {}


func _get_city_policy_id(city_id: String, city_data: Dictionary) -> String:
	return str(_city_policy_state.get(city_id, city_data.get("governor_policy_id", "follow_chancellor")))


func _update_governor_card(governor_id: String, governor_data: Dictionary, policy_id: String, policy_data: Dictionary) -> void:
	var governor_name := _get_hero_display_name(governor_data, "태수 없음")
	HeroPortraitHelper.apply_hero_portrait_or_placeholder(_governor_portrait_texture_rect, governor_portrait_label, governor_data)
	governor_name_label.text = governor_name
	governor_stats_label.text = _format_hero_stats(governor_data)
	governor_policy_description_label.text = str(policy_data.get("description", "태수 정책 설명 준비 중"))
	_select_option_by_metadata(governor_policy_option, policy_id)
	governor_policy_option.disabled = governor_id.is_empty()


func _ensure_governor_portrait_texture_rect() -> void:
	if _governor_portrait_texture_rect != null:
		return
	var portrait_box := governor_portrait_label.get_parent()
	if not portrait_box is Control:
		return
	_governor_portrait_texture_rect = TextureRect.new()
	_governor_portrait_texture_rect.name = "GovernorPortraitTexture"
	_governor_portrait_texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_governor_portrait_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_governor_portrait_texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_governor_portrait_texture_rect.visible = false
	portrait_box.add_child(_governor_portrait_texture_rect)
	_governor_portrait_texture_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _format_stationed_hero_chips(hero_ids: Array) -> String:
	if hero_ids.is_empty():
		return "주둔 장수 없음"

	var chip_texts: Array[String] = []
	for hero_id in hero_ids:
		var hero_data := _get_hero_entry(str(hero_id))
		var hero_name := _get_hero_display_name(hero_data, "알 수 없는 장수")
		var role := str(hero_data.get("role", "무장"))
		chip_texts.append("[%s · %s · %s]" % [hero_name, role, _format_hero_stats(hero_data)])
	return " ".join(chip_texts)


func _format_stationed_hero_list(hero_ids: Array) -> String:
	if hero_ids.is_empty():
		return "주둔 장수 없음"
	var lines: Array[String] = []
	for hero_id in hero_ids:
		var hero_data := _get_hero_entry(str(hero_id))
		lines.append("· %s" % _get_hero_display_name(hero_data, "알 수 없는 장수"))
	return "\n".join(lines)


func _get_hero_display_name(hero_data: Dictionary, fallback: String) -> String:
	if hero_data.is_empty():
		return fallback
	var hero_id := str(hero_data.get("hero_id", hero_data.get("id", "")))
	var base_name := str(hero_data.get("display_name", fallback))
	return _get_hero_display_name_with_state(hero_id, base_name, hero_data)


func _get_hero_display_name_with_state(hero_id: String, base_name: String, hero_data: Dictionary) -> String:
	if hero_id.is_empty() or hero_data.is_empty():
		return base_name
	return "%s%s" % [base_name, _get_hero_state_badge_text(hero_data)]


func _get_hero_state_badge_text(hero_data: Dictionary) -> String:
	if hero_data.is_empty():
		return ""
	var status := str(hero_data.get("status", "normal")).to_lower()
	if bool(hero_data.get("dead", false)) or status == "dead":
		return " [사망]"
	if bool(hero_data.get("captured", false)) or status == "captured":
		return " [포로]"
	if bool(hero_data.get("wounded", false)) or status == "wounded":
		return " [부상]"
	return ""


func _format_hero_stats(hero_data: Dictionary) -> String:
	if hero_data.is_empty():
		return "능력: -"
	return "정 %d / 무 %d / 지 %d / 충 %d" % [
		int(hero_data.get("politics", 0)),
		int(hero_data.get("war", 0)),
		int(hero_data.get("intelligence", 0)),
		int(hero_data.get("loyalty", 0)),
	]


func _select_option_by_metadata(option_button: OptionButton, metadata_value: String) -> void:
	for index in range(option_button.item_count):
		if str(option_button.get_item_metadata(index)) == metadata_value:
			option_button.select(index)
			return


func _get_status_text(city_marker: WorldMapCityMarker) -> String:
	if city_marker == null:
		return "정보 없음"
	if _has_player_neighbor(city_marker) and city_marker.owner_faction_id != PLAYER_FACTION_ID:
		return "공격을 누르면 출전 무장 선택 후 Phaser 전투 화면으로 진입합니다."

	if city_marker.owner_faction_id == PLAYER_FACTION_ID:
		return "아군 거점입니다. 인접한 적 도시가 있으면 전투 방식 선택 뒤 공격을 시작할 수 있습니다."

	if not city_marker.owner_faction_id.is_empty():
		return "적 도시입니다. 아군 인접 거점이 없으면 아직 공격할 수 없습니다."

	return "전투 시스템은 다음 버전에서 구현 예정입니다."


func _format_pending_invasion_city_status(city_id: String) -> String:
	if _pending_invasion_event.is_empty():
		return "도시 상태: %s" % _get_status_text(_city_markers_by_id.get(city_id) as WorldMapCityMarker)
	if str(_pending_invasion_event.get("defender_city_id", "")) == city_id:
		return "침공 대상 도시 · 방어전 준비 중"
	if str(_pending_invasion_event.get("attacker_city_id", "")) == city_id:
		return "침공 출발 도시"
	return "도시 상태: %s" % _get_status_text(_city_markers_by_id.get(city_id) as WorldMapCityMarker)


func _refresh_pending_invasion_status_line(city_id: String) -> void:
	status_text_label.text = _format_pending_invasion_city_status(city_id)


func _has_player_neighbor(city_marker: WorldMapCityMarker) -> bool:
	for neighbor_id in city_marker.neighbors:
		var neighbor_marker := _city_markers_by_id.get(neighbor_id) as WorldMapCityMarker
		if neighbor_marker != null and neighbor_marker.owner_faction_id == PLAYER_FACTION_ID:
			return true
	return false


func _on_governor_policy_selected(index: int) -> void:
	if _current_city_id.is_empty():
		return
	var policy_id := str(governor_policy_option.get_item_metadata(index))
	_city_policy_state[_current_city_id] = policy_id
	var policy_data := _get_governor_policy_entry(policy_id)
	var city_data := _get_city_hud_entry(_current_city_id)
	var governor_data := _get_hero_entry(str(city_data.get("governor_id", "")))
	governor_policy_description_label.text = str(policy_data.get("description", "태수 정책 설명 준비 중"))
	governor_label.text = "태수: %s" % _get_hero_display_name(governor_data, "태수 없음")
	print("[WorldMap] Governor policy placeholder selected: %s for %s. No city stat or turn effect applied." % [policy_id, _current_city_id])
	hint_label.text = "정책: %s · %s" % [
		str(policy_data.get("name", policy_id)),
		str(policy_data.get("description", "정보 없음")),
	]


func _on_attack_placeholder_pressed() -> void:
	print("[WorldMap] Attack placeholder selected. BattleContext connection is deferred.")
	hint_label.text = "공격 준비는 다음 단계에서 BattleContext와 연결됩니다."


func _on_hero_move_placeholder_pressed() -> void:
	print("[WorldMap] Hero move placeholder selected. Hero transfer is deferred.")
	hint_label.text = "무장 이동은 다음 단계에서 Hero/Army 배치와 연결됩니다."


func _on_domestic_placeholder_pressed() -> void:
	print("[WorldMap] Domestic placeholder selected. Domestic execution is deferred.")
	hint_label.text = "내정 실행은 후속 Domestic Affairs 패널에서 연결됩니다."


func _on_recruit_placeholder_pressed() -> void:
	print("[WorldMap] Recruit placeholder selected. Soldier recruitment is deferred.")
	hint_label.text = "병사 모집은 실제 자원/병력 처리와 연결되지 않았습니다."
