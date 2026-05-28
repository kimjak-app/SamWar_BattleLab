class_name WorldMapCityInfoPanel
extends PanelContainer

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
var _current_city_id := ""


func _ready() -> void:
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
	var stationed_hero_ids: Array = city_data.get("stationed_hero_ids", [])

	eyebrow_label.text = "SELECTED CITY"
	city_name_label.text = city_marker.display_name
	description_label.text = "%s 권역의 %s 거점입니다." % [
		_format_region_label(city_marker.region_id),
		_format_faction_label(city_marker.owner_faction_id),
	]
	city_id_label.text = "id: %s" % city_marker.city_id
	region_owner_label.text = "%s · %s" % [
		_format_region_label(city_marker.region_id),
		_format_faction_label(city_marker.owner_faction_id),
	]
	city_type_label.text = "유형: %s" % _format_city_type(city_marker.city_id)
	neighbor_label.text = "인접: %s" % _format_neighbors(city_marker.neighbors)
	route_type_label.text = "루트: %s" % _format_route_types(city_marker)
	status_text_label.text = _get_status_text(city_marker)
	loyalty_label.text = "성 충성도 %d · 표시 전용" % loyalty
	loyalty_bar.value = loyalty
	_update_governor_card(governor_id, governor_data, policy_id, policy_data)
	governor_label.text = "태수: %s · 정책: %s" % [
		_get_hero_display_name(governor_data, "태수 미임명"),
		str(policy_data.get("name", "정책 미정")),
	]
	selected_hero_chip_label.text = "선택 중인 무장: %s" % _format_stationed_hero_chips(stationed_hero_ids)
	garrison_label.text = "주둔 무장: %d명 · 이동 기능은 준비 중" % stationed_hero_ids.size()
	military_info_label.text = "군사 정보: %s" % str(city_data.get("military", "병력 / 방어 / 보급 데이터 연결 예정"))
	military_state_label.text = "군비 상태: %s" % str(city_data.get("trade", "징병 / 보급 / 방어도 placeholder"))
	hint_label.text = "도시 행동은 placeholder입니다."
	show()


func _show_empty() -> void:
	_current_city_id = ""
	eyebrow_label.text = "SELECTED CITY"
	city_name_label.text = "도시를 선택하세요"
	description_label.text = "도시 성 아이콘이 아닌 기능형 마커를 클릭하면 선택 정보가 표시됩니다."
	city_id_label.text = "id: -"
	region_owner_label.text = "지역 · 세력: -"
	city_type_label.text = "유형: -"
	neighbor_label.text = "인접: -"
	route_type_label.text = "루트: -"
	status_text_label.text = "월드맵 HUD 기능은 Godot 이식 중입니다."
	loyalty_label.text = "성 충성도 - · placeholder"
	loyalty_bar.value = 0
	governor_label.text = "태수: -"
	governor_portrait_label.text = "?"
	governor_name_label.text = "태수 미임명"
	governor_stats_label.text = "능력: -"
	_setup_governor_policy_option()
	governor_policy_description_label.text = "도시 선택 시 태수 정책 설명이 표시됩니다."
	selected_hero_chip_label.text = "선택 중인 무장: -"
	garrison_label.text = "주둔 무장: placeholder"
	military_info_label.text = "군사 정보: placeholder"
	military_state_label.text = "군비 상태: placeholder"
	hint_label.text = "공격 / 무장 이동 / 내정은 아직 실행되지 않습니다."
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


func _get_hero_entry(hero_id: String) -> Dictionary:
	return _hero_data.get(hero_id, {})


func _get_governor_policy_entry(policy_id: String) -> Dictionary:
	if _governor_policy_data.has(policy_id):
		return _governor_policy_data[policy_id]
	if not _governor_policy_data.is_empty():
		return _governor_policy_data[_governor_policy_data.keys()[0]]
	return {}


func _get_city_policy_id(city_id: String, city_data: Dictionary) -> String:
	return str(_city_policy_state.get(city_id, city_data.get("governor_policy_id", "finance")))


func _update_governor_card(governor_id: String, governor_data: Dictionary, policy_id: String, policy_data: Dictionary) -> void:
	var governor_name := _get_hero_display_name(governor_data, "태수 미임명")
	governor_portrait_label.text = _get_portrait_initial(governor_name)
	governor_name_label.text = governor_name
	governor_stats_label.text = _format_hero_stats(governor_data)
	governor_policy_description_label.text = str(policy_data.get("description", "태수 정책 설명 준비 중"))
	_select_option_by_metadata(governor_policy_option, policy_id)
	governor_policy_option.disabled = governor_id.is_empty()


func _format_stationed_hero_chips(hero_ids: Array) -> String:
	if hero_ids.is_empty():
		return "배치 무장 없음"

	var chip_texts: Array[String] = []
	for hero_id in hero_ids:
		var hero_data := _get_hero_entry(str(hero_id))
		var hero_name := _get_hero_display_name(hero_data, str(hero_id))
		var role := str(hero_data.get("role", "무장"))
		chip_texts.append("[%s · %s · %s]" % [hero_name, role, _format_hero_stats(hero_data)])
	return " ".join(chip_texts)


func _get_hero_display_name(hero_data: Dictionary, fallback: String) -> String:
	if hero_data.is_empty():
		return fallback
	return str(hero_data.get("display_name", fallback))


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


func _get_status_text(city_marker: WorldMapCityMarker) -> String:
	if city_marker.owner_faction_id == PLAYER_FACTION_ID:
		return "아군 거점입니다. 인접한 적 도시가 있으면 전투를 준비할 수 있습니다."

	if _has_player_neighbor(city_marker):
		return "공격 준비는 다음 단계에서 BattleContext와 연결됩니다."

	if not city_marker.owner_faction_id.is_empty():
		return "적 도시입니다. 아군 인접 거점이 있어야 공격할 수 있습니다."

	return "월드맵 기능은 Godot 이식 중입니다."


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
	governor_label.text = "태수: %s · 정책: %s" % [
		_get_hero_display_name(governor_data, "태수 미임명"),
		str(policy_data.get("name", policy_id)),
	]
	print("[WorldMap] Governor policy placeholder selected: %s for %s. No city stat or turn effect applied." % [policy_id, _current_city_id])
	hint_label.text = "태수 정책 '%s' 선택됨. 실제 도시 수치는 변경하지 않습니다." % str(policy_data.get("name", policy_id))


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
