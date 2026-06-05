class_name WorldMapCityInfoPanel
extends PanelContainer

const HeroPortraitHelper := preload("res://scripts/worldmap_hero_portrait_helper.gd")
const PLAYER_FACTION_ID := "player"

signal attack_requested(city_id: String)
signal governor_assignment_requested(city_id: String, governor_id: String)
signal hero_transfer_confirmed(source_city_id: String, hero_id: String, target_city_id: String)
signal recruitment_requested(city_id: String, amount: int)
signal help_requested(topic_id: String)

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
@onready var governor_assign_option: OptionButton = $MarginContainer/Content/GovernorCard/MarginContainer/Content/GovernorAssignOption
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
var _recruitment_summaries: Dictionary = {}
var _governor_policy_data: Dictionary = {}
var _city_policy_state: Dictionary = {}
var _pending_invasion_event: Dictionary = {}
var _current_city_id := ""
var _governor_portrait_texture_rect: TextureRect = null
var _garrison_card: PanelContainer = null
var _garrison_list_container: VBoxContainer = null
var _hero_transfer_panel: PanelContainer = null
var _hero_transfer_hero_option: OptionButton = null
var _hero_transfer_target_option: OptionButton = null
var _hero_transfer_confirm_button: Button = null
var _hero_transfer_cancel_button: Button = null
var _hero_transfer_status_label: Label = null
var _recruitment_section: VBoxContainer = null
var _recruitment_title_label: Label = null
var _conscription_summary_label: Label = null
var _recruitment_summary_label: Label = null
var _city_loyalty_help_button: Button = null
var _domestic_help_row: HBoxContainer = null
var _garrison_help_button: Button = null
var _hero_transfer_open := false
var _attack_action_enabled := false
var _attack_action_hint := "공격 준비는 다음 단계에서 BattleContext와 연결됩니다."


func _ready() -> void:
	city_id_label.visible = false
	_apply_selected_city_summary_slim_visibility()
	_ensure_governor_portrait_texture_rect()
	_ensure_garrison_list_container()
	_ensure_hero_transfer_panel()
	_ensure_recruitment_section()
	_ensure_help_buttons()
	_apply_selected_city_layout_order()
	attack_button_placeholder.pressed.connect(_on_attack_placeholder_pressed)
	hero_move_button_placeholder.pressed.connect(_on_hero_move_placeholder_pressed)
	domestic_button_placeholder.pressed.connect(_on_domestic_placeholder_pressed)
	recruit_button_placeholder.pressed.connect(_on_recruit_placeholder_pressed)
	if not governor_assign_option.item_selected.is_connected(_on_governor_assignment_selected):
		governor_assign_option.item_selected.connect(_on_governor_assignment_selected)
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


func set_recruitment_summaries(recruitment_summaries: Dictionary) -> void:
	_recruitment_summaries = recruitment_summaries.duplicate(true)
	if not _current_city_id.is_empty():
		_refresh_recruitment_section()


func set_pending_invasion_event(event: Dictionary) -> void:
	_pending_invasion_event = event.duplicate(true)
	if not _current_city_id.is_empty():
		_refresh_pending_invasion_status_line(_current_city_id)


func set_attack_action_state(enabled: bool, hint_text: String = "") -> void:
	_attack_action_enabled = enabled
	_attack_action_hint = hint_text if not hint_text.is_empty() else ("공격 가능" if enabled else "공격할 수 없는 도시입니다.")
	_refresh_attack_action_state()


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

	_apply_selected_city_summary_slim_visibility()
	eyebrow_label.text = ""
	city_name_label.text = _get_city_display_name(city_marker.city_id, city_marker.display_name)
	description_label.text = "세력: %s" % _get_city_owner_label(city_marker, city_data)
	city_id_label.visible = false
	city_id_label.text = ""
	region_owner_label.text = ""
	city_type_label.text = "유형: %s" % _format_city_type(city_marker.city_id)
	neighbor_label.text = ""
	route_type_label.text = ""
	status_text_label.text = ""
	loyalty_label.text = "성 충성도 %d" % loyalty
	loyalty_bar.value = loyalty
	_setup_governor_assign_option(city_data, governor_id)
	_update_governor_card(governor_id, governor_data, policy_id, policy_data)
	governor_label.text = "태수"
	governor_label.visible = true
	selected_hero_chip_label.text = "주둔 무장"
	selected_hero_chip_label.visible = true
	garrison_label.text = ""
	garrison_label.visible = false
	_refresh_garrison_list(stationed_hero_ids)
	_refresh_hero_transfer_panel(city_data)
	military_info_label.text = _format_city_defense_info(city_data)
	military_state_label.text = _format_city_domestic_info(city_data)
	hint_label.text = ""
	hint_label.visible = false
	_refresh_recruitment_section()
	_refresh_attack_action_state()
	_apply_selected_city_layout_order()
	show()


func _show_empty() -> void:
	_current_city_id = ""
	_apply_selected_city_summary_slim_visibility()
	eyebrow_label.text = ""
	city_name_label.text = "선택 도시 없음"
	description_label.text = "세력: 정보 없음"
	city_id_label.visible = false
	city_id_label.text = ""
	region_owner_label.text = ""
	city_type_label.text = "유형: 정보 없음"
	neighbor_label.text = ""
	route_type_label.text = ""
	status_text_label.text = ""
	loyalty_label.text = "성 충성도 정보 없음"
	loyalty_bar.value = 0
	governor_label.text = ""
	governor_label.visible = false
	HeroPortraitHelper.apply_hero_portrait_or_placeholder(_governor_portrait_texture_rect, governor_portrait_label, {})
	governor_name_label.text = "태수 없음"
	governor_stats_label.text = "능력: -"
	_setup_governor_assign_option({}, "")
	_setup_governor_policy_option()
	governor_policy_description_label.text = "도시 선택 시 태수 정책 설명이 표시됩니다."
	selected_hero_chip_label.text = "주둔 무장"
	selected_hero_chip_label.visible = true
	garrison_label.text = ""
	garrison_label.visible = false
	_refresh_garrison_list([])
	_hero_transfer_open = false
	_refresh_hero_transfer_panel({})
	military_info_label.text = "병력: 정보 없음 · 방어: 정보 없음"
	military_state_label.text = "민심/치안: 정보 없음 · 상업: 정보 없음 · 농업: 정보 없음"
	hint_label.text = ""
	hint_label.visible = false
	_refresh_recruitment_section()
	_attack_action_enabled = false
	_refresh_attack_action_state()
	_apply_selected_city_layout_order()
	show()


func _apply_selected_city_summary_slim_visibility() -> void:
	eyebrow_label.visible = false
	description_label.visible = true
	city_id_label.visible = false
	region_owner_label.visible = false
	neighbor_label.visible = false
	route_type_label.visible = false
	status_text_label.visible = false
	hint_label.visible = false
	domestic_button_placeholder.text = ""
	domestic_button_placeholder.tooltip_text = ""
	domestic_button_placeholder.disabled = true
	domestic_button_placeholder.visible = false


func _setup_governor_policy_option() -> void:
	if governor_policy_option == null:
		return
	governor_policy_option.clear()
	for policy_id in _governor_policy_data.keys():
		var policy_data: Dictionary = _governor_policy_data[policy_id]
		governor_policy_option.add_item(str(policy_data.get("name", policy_id)))
		governor_policy_option.set_item_metadata(governor_policy_option.item_count - 1, policy_id)


func _setup_governor_assign_option(city_data: Dictionary, governor_id: String) -> void:
	if governor_assign_option == null:
		return
	governor_assign_option.clear()
	governor_assign_option.add_item("미임명")
	governor_assign_option.set_item_metadata(0, "")
	for hero_id in _get_city_stationed_hero_ids(city_data):
		var hero_id_string := str(hero_id)
		if hero_id_string.is_empty():
			continue
		var hero_data := _get_hero_entry(hero_id_string)
		var hero_name := _get_hero_display_name(hero_data, hero_id_string)
		governor_assign_option.add_item(hero_name)
		governor_assign_option.set_item_metadata(governor_assign_option.item_count - 1, hero_id_string)
	_select_option_by_metadata(governor_assign_option, governor_id)
	governor_assign_option.disabled = _current_city_id.is_empty()


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
	governor_policy_description_label.text = _format_governor_policy_description(policy_id, policy_data)
	_select_option_by_metadata(governor_policy_option, policy_id)
	governor_policy_option.disabled = governor_id.is_empty()


func _apply_selected_city_layout_order() -> void:
	var content := get_node_or_null("MarginContainer/Content") as VBoxContainer
	if content == null:
		return
	var loyalty_card := _get_direct_child_under(content, loyalty_label) as Control
	var governor_card := _get_direct_child_under(content, governor_assign_option) as Control
	var button_row := attack_button_placeholder.get_parent() as Control if attack_button_placeholder != null else null
	_move_child_after(content, military_state_label, loyalty_card)
	_move_child_after(content, _domestic_help_row, military_state_label)
	var governor_label_anchor: Control = military_state_label
	if _domestic_help_row != null:
		governor_label_anchor = _domestic_help_row
	_move_child_after(content, governor_label, governor_label_anchor)
	_move_child_after(content, governor_card, governor_label)
	_move_child_after(content, _garrison_card, governor_card)
	_move_child_after(content, hero_move_button_placeholder, _garrison_card)
	_move_child_after(content, _hero_transfer_panel, hero_move_button_placeholder)
	_move_child_after(content, military_info_label, _hero_transfer_panel if _hero_transfer_panel != null else hero_move_button_placeholder)
	_move_child_after(content, _recruitment_section, military_info_label)
	_move_child_after(content, recruit_button_placeholder, _recruitment_section if _recruitment_section != null else military_info_label)
	if button_row != null:
		_move_child_after(content, button_row, recruit_button_placeholder)
		button_row.visible = attack_button_placeholder.visible
	domestic_button_placeholder.text = ""
	domestic_button_placeholder.tooltip_text = ""
	domestic_button_placeholder.disabled = true
	domestic_button_placeholder.visible = false
	hint_label.visible = false


func _ensure_help_buttons() -> void:
	if _city_loyalty_help_button == null and loyalty_label != null and loyalty_label.get_parent() != null:
		_city_loyalty_help_button = _make_help_button("city_loyalty")
		loyalty_label.get_parent().add_child(_city_loyalty_help_button)
		if loyalty_label.get_parent() is VBoxContainer:
			(loyalty_label.get_parent() as VBoxContainer).move_child(_city_loyalty_help_button, mini(loyalty_label.get_index() + 1, loyalty_label.get_parent().get_child_count() - 1))

	if _domestic_help_row == null:
		var content := get_node_or_null("MarginContainer/Content") as VBoxContainer
		if content != null:
			_domestic_help_row = HBoxContainer.new()
			_domestic_help_row.name = "DomesticHelpRow"
			_domestic_help_row.add_theme_constant_override("separation", 4)
			_domestic_help_row.add_child(_make_help_button("public_support", "민심 ?"))
			_domestic_help_row.add_child(_make_help_button("security", "치안 ?"))
			content.add_child(_domestic_help_row)

	if _garrison_help_button == null and _garrison_card != null:
		var card_content := _garrison_card.get_node_or_null("MarginContainer/Content") as VBoxContainer
		if card_content != null:
			_garrison_help_button = _make_help_button("garrison", "주둔무장 ?")
			card_content.add_child(_garrison_help_button)
			if selected_hero_chip_label != null and selected_hero_chip_label.get_parent() == card_content:
				card_content.move_child(_garrison_help_button, mini(selected_hero_chip_label.get_index() + 1, card_content.get_child_count() - 1))


func _make_help_button(topic_id: String, label_text: String = "?") -> Button:
	var button := Button.new()
	button.name = "HelpButton_%s" % topic_id
	button.text = label_text
	button.custom_minimum_size = Vector2(24.0, 18.0)
	button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	button.focus_mode = Control.FOCUS_NONE
	button.tooltip_text = "도움말"
	button.add_theme_font_size_override("font_size", 10)
	button.pressed.connect(_on_help_button_pressed.bind(topic_id))
	return button


func _on_help_button_pressed(topic_id: String) -> void:
	help_requested.emit(topic_id)


func _ensure_recruitment_section() -> void:
	if _recruitment_section != null:
		return
	var content := get_node_or_null("MarginContainer/Content") as VBoxContainer
	if content == null:
		return
	_recruitment_section = VBoxContainer.new()
	_recruitment_section.name = "RecruitmentSection"
	_recruitment_section.add_theme_constant_override("separation", 2)
	_recruitment_title_label = Label.new()
	_recruitment_title_label.name = "RecruitmentTitleLabel"
	_recruitment_title_label.text = "병사 충원"
	_recruitment_title_label.add_theme_font_size_override("font_size", 12)
	_recruitment_title_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.58, 1.0))
	_conscription_summary_label = Label.new()
	_conscription_summary_label.name = "ConscriptionSummaryLabel"
	_conscription_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_conscription_summary_label.add_theme_font_size_override("font_size", 11)
	_recruitment_summary_label = Label.new()
	_recruitment_summary_label.name = "RecruitmentSummaryLabel"
	_recruitment_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_recruitment_summary_label.add_theme_font_size_override("font_size", 11)
	_recruitment_section.add_child(_recruitment_title_label)
	_recruitment_section.add_child(_conscription_summary_label)
	_recruitment_section.add_child(_recruitment_summary_label)
	content.add_child(_recruitment_section)


func _refresh_recruitment_section() -> void:
	_ensure_recruitment_section()
	if _recruitment_section == null:
		return
	var summary: Dictionary = _recruitment_summaries.get(_current_city_id, {}) if _recruitment_summaries.get(_current_city_id, {}) is Dictionary else {}
	_recruitment_section.visible = true
	_recruitment_title_label.text = str(summary.get("title", "병사 충원"))
	_conscription_summary_label.text = str(summary.get("conscription_line", "징병: 정보 없음"))
	_recruitment_summary_label.text = str(summary.get("recruitment_line", "모병: 정보 없음"))
	recruit_button_placeholder.text = str(summary.get("button_text", "모병 불가"))
	recruit_button_placeholder.disabled = not bool(summary.get("button_enabled", false))
	recruit_button_placeholder.visible = true
	recruit_button_placeholder.tooltip_text = str(summary.get("button_hint", "도시를 선택하십시오."))


func _get_direct_child_under(parent: Node, node: Node) -> Node:
	var current := node
	while current != null:
		if current.get_parent() == parent:
			return current
		current = current.get_parent()
	return null


func _move_child_after(parent: Node, child: Node, after_child: Node) -> void:
	if parent == null or child == null or after_child == null:
		return
	if child.get_parent() != parent:
		var old_parent := child.get_parent()
		if old_parent != null:
			old_parent.remove_child(child)
		parent.add_child(child)
	parent.move_child(child, mini(after_child.get_index() + 1, parent.get_child_count() - 1))


func _ensure_garrison_list_container() -> void:
	if _garrison_list_container != null:
		return
	var content := get_node_or_null("MarginContainer/Content") as VBoxContainer
	if content == null:
		return
	_garrison_card = PanelContainer.new()
	_garrison_card.name = "GarrisonCard"
	var card_margin := MarginContainer.new()
	card_margin.name = "MarginContainer"
	card_margin.add_theme_constant_override("margin_left", 6)
	card_margin.add_theme_constant_override("margin_top", 6)
	card_margin.add_theme_constant_override("margin_right", 6)
	card_margin.add_theme_constant_override("margin_bottom", 6)
	var card_content := VBoxContainer.new()
	card_content.name = "Content"
	card_content.add_theme_constant_override("separation", 4)
	if selected_hero_chip_label.get_parent() != null:
		selected_hero_chip_label.get_parent().remove_child(selected_hero_chip_label)
	card_content.add_child(selected_hero_chip_label)
	_garrison_list_container = VBoxContainer.new()
	_garrison_list_container.name = "GarrisonList"
	_garrison_list_container.add_theme_constant_override("separation", 4)
	card_content.add_child(_garrison_list_container)
	card_margin.add_child(card_content)
	_garrison_card.add_child(card_margin)
	var insert_index := selected_hero_chip_label.get_index() if selected_hero_chip_label != null and selected_hero_chip_label.get_parent() == content else content.get_child_count()
	content.add_child(_garrison_card)
	content.move_child(_garrison_card, insert_index)


func _ensure_hero_transfer_panel() -> void:
	if _hero_transfer_panel != null:
		return
	var content := get_node_or_null("MarginContainer/Content") as VBoxContainer
	if content == null:
		return
	_hero_transfer_panel = PanelContainer.new()
	_hero_transfer_panel.name = "HeroTransferPanel"
	_hero_transfer_panel.visible = false
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_bottom", 6)
	var box := VBoxContainer.new()
	box.name = "Content"
	box.add_theme_constant_override("separation", 4)
	_hero_transfer_status_label = Label.new()
	_hero_transfer_status_label.name = "HeroTransferStatusLabel"
	_hero_transfer_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hero_transfer_hero_option = OptionButton.new()
	_hero_transfer_hero_option.name = "HeroTransferHeroOption"
	_hero_transfer_target_option = OptionButton.new()
	_hero_transfer_target_option.name = "HeroTransferTargetOption"
	var action_row := HBoxContainer.new()
	action_row.name = "HeroTransferActionRow"
	action_row.add_theme_constant_override("separation", 6)
	_hero_transfer_confirm_button = Button.new()
	_hero_transfer_confirm_button.name = "HeroTransferConfirmButton"
	_hero_transfer_confirm_button.text = "이동 확정"
	_hero_transfer_cancel_button = Button.new()
	_hero_transfer_cancel_button.name = "HeroTransferCancelButton"
	_hero_transfer_cancel_button.text = "취소"
	action_row.add_child(_hero_transfer_confirm_button)
	action_row.add_child(_hero_transfer_cancel_button)
	box.add_child(_hero_transfer_status_label)
	box.add_child(_make_transfer_field_label("이동할 무장"))
	box.add_child(_hero_transfer_hero_option)
	box.add_child(_make_transfer_field_label("이동 대상"))
	box.add_child(_hero_transfer_target_option)
	box.add_child(action_row)
	margin.add_child(box)
	_hero_transfer_panel.add_child(margin)
	var insert_index := hero_move_button_placeholder.get_parent().get_index() + 1 if hero_move_button_placeholder != null and hero_move_button_placeholder.get_parent() != null else content.get_child_count()
	content.add_child(_hero_transfer_panel)
	content.move_child(_hero_transfer_panel, insert_index)
	_hero_transfer_hero_option.item_selected.connect(_on_hero_transfer_option_selected)
	_hero_transfer_target_option.item_selected.connect(_on_hero_transfer_option_selected)
	_hero_transfer_confirm_button.pressed.connect(_on_hero_transfer_confirm_pressed)
	_hero_transfer_cancel_button.pressed.connect(_on_hero_transfer_cancel_pressed)


func _make_transfer_field_label(text_value: String) -> Label:
	var label := Label.new()
	label.text = text_value
	label.add_theme_font_size_override("font_size", 11)
	return label


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


func _refresh_garrison_list(hero_ids: Array) -> void:
	_ensure_garrison_list_container()
	if _garrison_list_container == null:
		return
	_clear_children(_garrison_list_container)
	if hero_ids.is_empty():
		var empty_label := Label.new()
		empty_label.text = "이동 가능한 주둔 무장이 없습니다."
		empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_garrison_list_container.add_child(empty_label)
		return
	for hero_id in hero_ids:
		var hero_data := _get_hero_entry(str(hero_id))
		_garrison_list_container.add_child(_make_garrison_hero_row(str(hero_id), hero_data))


func _make_garrison_hero_row(hero_id: String, hero_data: Dictionary) -> Control:
	var card := PanelContainer.new()
	card.name = "GarrisonHero_%s" % hero_id
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 4)
	margin.add_theme_constant_override("margin_top", 3)
	margin.add_theme_constant_override("margin_right", 4)
	margin.add_theme_constant_override("margin_bottom", 3)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	var portrait_box := PanelContainer.new()
	portrait_box.custom_minimum_size = Vector2(34, 38)
	portrait_box.clip_contents = true
	var portrait_label := Label.new()
	portrait_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	portrait_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var portrait_texture := TextureRect.new()
	portrait_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	portrait_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait_box.add_child(portrait_texture)
	portrait_texture.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	portrait_box.add_child(portrait_label)
	portrait_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	HeroPortraitHelper.apply_hero_portrait_or_placeholder(portrait_texture, portrait_label, hero_data)
	var copy := VBoxContainer.new()
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var name_label := Label.new()
	name_label.text = _get_hero_display_name(hero_data, "알 수 없는 장수")
	name_label.add_theme_font_size_override("font_size", 12)
	var stats_label := Label.new()
	stats_label.text = _format_hero_stats(hero_data)
	stats_label.add_theme_font_size_override("font_size", 10)
	stats_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	copy.add_child(name_label)
	copy.add_child(stats_label)
	row.add_child(portrait_box)
	row.add_child(copy)
	margin.add_child(row)
	card.add_child(margin)
	return card


func _clear_children(parent: Node) -> void:
	for child in parent.get_children():
		parent.remove_child(child)
		child.queue_free()


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
		var turns_remaining := maxi(0, int(hero_data.get("wounded_turns_remaining", 0)))
		if turns_remaining > 0:
			return " [부상 %d턴]" % turns_remaining
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
	if option_button == null:
		return
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
	status_text_label.visible = false


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
	governor_policy_description_label.text = _format_governor_policy_description(policy_id, policy_data)
	governor_label.text = "태수"
	governor_label.visible = true
	print("[WorldMap] Governor policy selected: %s for %s" % [policy_id, _current_city_id])
	hint_label.text = ""
	hint_label.visible = false


func _on_governor_assignment_selected(index: int) -> void:
	if _current_city_id.is_empty() or governor_assign_option == null:
		return
	var governor_id := str(governor_assign_option.get_item_metadata(index))
	governor_assignment_requested.emit(_current_city_id, governor_id)


func _refresh_hero_transfer_panel(city_data: Dictionary) -> void:
	_ensure_hero_transfer_panel()
	if _hero_transfer_panel == null:
		return
	hero_move_button_placeholder.text = "무장 이동"
	var hero_ids := _get_city_stationed_hero_ids(city_data)
	var target_city_ids := _get_adjacent_player_city_ids(_current_city_id)
	_hero_transfer_panel.visible = _hero_transfer_open and not _current_city_id.is_empty()
	_populate_transfer_option(_hero_transfer_hero_option, hero_ids, "이동 가능한 주둔 무장이 없습니다.", true)
	_populate_transfer_option(_hero_transfer_target_option, target_city_ids, "이동 가능한 아군 성이 없습니다.", false)
	var message := ""
	if hero_ids.is_empty():
		message = "이동 가능한 주둔 무장이 없습니다."
	elif target_city_ids.is_empty():
		message = "이동 가능한 아군 성이 없습니다."
	else:
		message = "이동할 무장과 이동 대상을 선택하십시오."
	_hero_transfer_status_label.text = message
	_refresh_hero_transfer_confirm_state()


func _populate_transfer_option(option_button: OptionButton, ids: Array, empty_text: String, is_hero: bool) -> void:
	if option_button == null:
		return
	option_button.clear()
	if ids.is_empty():
		option_button.add_item(empty_text)
		option_button.set_item_metadata(0, "")
		option_button.disabled = true
		return
	option_button.disabled = false
	for id_value in ids:
		var id_string := str(id_value)
		var label := _get_hero_display_name(_get_hero_entry(id_string), id_string) if is_hero else _get_city_display_name(id_string, id_string)
		option_button.add_item(label)
		option_button.set_item_metadata(option_button.item_count - 1, id_string)


func _get_adjacent_player_city_ids(source_city_id: String) -> Array[String]:
	var result: Array[String] = []
	var source_marker := _city_markers_by_id.get(source_city_id) as WorldMapCityMarker
	if source_marker == null:
		return result
	for neighbor_id in source_marker.neighbors:
		var neighbor_id_string := str(neighbor_id)
		if neighbor_id_string == source_city_id or result.has(neighbor_id_string):
			continue
		var neighbor_data := _get_city_hud_entry(neighbor_id_string)
		var neighbor_marker := _city_markers_by_id.get(neighbor_id_string) as WorldMapCityMarker
		var owner_id := str(neighbor_data.get("owner", neighbor_data.get("owner_faction_id", "")))
		if owner_id.is_empty() and neighbor_marker != null:
			owner_id = neighbor_marker.owner_faction_id
		if owner_id == PLAYER_FACTION_ID:
			result.append(neighbor_id_string)
	return result


func _refresh_hero_transfer_confirm_state() -> void:
	if _hero_transfer_confirm_button == null:
		return
	var hero_id := _get_selected_option_metadata(_hero_transfer_hero_option)
	var target_city_id := _get_selected_option_metadata(_hero_transfer_target_option)
	_hero_transfer_confirm_button.disabled = hero_id.is_empty() or target_city_id.is_empty()


func _get_selected_option_metadata(option_button: OptionButton) -> String:
	if option_button == null or option_button.item_count <= 0:
		return ""
	if option_button.selected < 0 or option_button.selected >= option_button.item_count:
		return ""
	return str(option_button.get_item_metadata(option_button.selected))


func _on_hero_transfer_option_selected(_index: int) -> void:
	_refresh_hero_transfer_confirm_state()


func _on_hero_transfer_confirm_pressed() -> void:
	if _current_city_id.is_empty():
		return
	var hero_id := _get_selected_option_metadata(_hero_transfer_hero_option)
	var target_city_id := _get_selected_option_metadata(_hero_transfer_target_option)
	if hero_id.is_empty():
		_hero_transfer_status_label.text = "이동 가능한 주둔 무장이 없습니다."
		return
	if target_city_id.is_empty():
		_hero_transfer_status_label.text = "이동 가능한 아군 성이 없습니다."
		return
	hero_transfer_confirmed.emit(_current_city_id, hero_id, target_city_id)


func _on_hero_transfer_cancel_pressed() -> void:
	_hero_transfer_open = false
	_refresh_hero_transfer_panel(_get_city_hud_entry(_current_city_id))


func show_hero_transfer_result(message: String) -> void:
	_hero_transfer_open = false
	if _hero_transfer_panel != null:
		_hero_transfer_panel.visible = false
	if not message.is_empty():
		hint_label.text = message
		hint_label.visible = true


func show_recruitment_result(message: String) -> void:
	if not message.is_empty():
		hint_label.text = message
		hint_label.visible = true


func _format_governor_policy_description(policy_id: String, policy_data: Dictionary) -> String:
	var description := str(policy_data.get("description", "태수 정책 설명 준비 중")).strip_edges()
	var policy_name := str(policy_data.get("name", policy_id)).strip_edges()
	if description.is_empty():
		description = "보정 없음"
	if policy_name.is_empty():
		policy_name = "보정 없음"
	return "효과: %s\n정책: %s" % [description, policy_name]


func _on_attack_placeholder_pressed() -> void:
	if _current_city_id.is_empty():
		hint_label.text = "공격할 도시를 선택하십시오."
		return
	if not _attack_action_enabled:
		hint_label.text = _attack_action_hint
		return
	attack_requested.emit(_current_city_id)


func _on_hero_move_placeholder_pressed() -> void:
	if _current_city_id.is_empty():
		hint_label.text = "도시를 선택하십시오."
		return
	_hero_transfer_open = not _hero_transfer_open
	_refresh_hero_transfer_panel(_get_city_hud_entry(_current_city_id))


func _refresh_attack_action_state() -> void:
	if attack_button_placeholder == null:
		return
	attack_button_placeholder.text = "공격"
	attack_button_placeholder.disabled = not _attack_action_enabled
	attack_button_placeholder.visible = _attack_action_enabled
	attack_button_placeholder.tooltip_text = _attack_action_hint
	var button_row := attack_button_placeholder.get_parent() as Control
	if button_row != null:
		button_row.visible = _attack_action_enabled


func _on_domestic_placeholder_pressed() -> void:
	print("[WorldMap] Domestic placeholder selected. Domestic execution is deferred.")
	hint_label.text = ""
	hint_label.visible = false


func _on_recruit_placeholder_pressed() -> void:
	if _current_city_id.is_empty():
		hint_label.text = "도시를 선택하십시오."
		hint_label.visible = true
		return
	recruitment_requested.emit(_current_city_id, 100)
