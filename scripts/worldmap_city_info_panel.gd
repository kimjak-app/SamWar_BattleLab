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
@onready var governor_label: Label = $MarginContainer/Content/GovernorLabel
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


func _ready() -> void:
	attack_button_placeholder.pressed.connect(_on_attack_placeholder_pressed)
	hero_move_button_placeholder.pressed.connect(_on_hero_move_placeholder_pressed)
	domestic_button_placeholder.pressed.connect(_on_domestic_placeholder_pressed)
	recruit_button_placeholder.pressed.connect(_on_recruit_placeholder_pressed)
	_show_empty()


func set_city_markers(city_markers_by_id: Dictionary) -> void:
	_city_markers_by_id = city_markers_by_id


func show_city(city_marker: WorldMapCityMarker) -> void:
	if city_marker == null:
		_show_empty()
		return

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
	loyalty_label.text = "성 충성도 75 · placeholder 안정"
	governor_label.text = "태수: placeholder"
	selected_hero_chip_label.text = "선택 중인 무장: [준비 중] [미배정]"
	garrison_label.text = "주둔 무장: placeholder"
	military_info_label.text = "군사 정보: 병력 / 방어 / 보급 데이터 연결 예정"
	military_state_label.text = "군비 상태: 징병 / 보급 / 방어도 placeholder"
	hint_label.text = "도시 행동은 placeholder입니다."
	show()


func _show_empty() -> void:
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
	governor_label.text = "태수: -"
	selected_hero_chip_label.text = "선택 중인 무장: -"
	garrison_label.text = "주둔 무장: placeholder"
	military_info_label.text = "군사 정보: placeholder"
	military_state_label.text = "군비 상태: placeholder"
	hint_label.text = "공격 / 무장 이동 / 내정은 아직 실행되지 않습니다."
	show()


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
