class_name WorldMapDomesticTechTreePresentationController
extends Node

signal research_requested(tech_id: String, city_id: String)
signal closed()

const DomesticTechHelperLib := preload("res://scripts/worldmap/domestic_tech/domestic_tech_helpers.gd")
const DomesticTechCatalogScript := preload("res://scripts/worldmap/domestic_tech/domestic_tech_catalog.gd")

const DOMESTIC_TECH_SCOPE_CITY := DomesticTechCatalogScript.DOMESTIC_TECH_SCOPE_CITY
const DOMESTIC_TECH_SCOPE_NATIONAL := DomesticTechCatalogScript.DOMESTIC_TECH_SCOPE_NATIONAL
const DOMESTIC_TECH_CATEGORY_AGRI := DomesticTechCatalogScript.DOMESTIC_TECH_CATEGORY_AGRI
const DOMESTIC_TECH_CATEGORY_FISH := DomesticTechCatalogScript.DOMESTIC_TECH_CATEGORY_FISH
const DOMESTIC_TECH_CATEGORY_COMMERCE := DomesticTechCatalogScript.DOMESTIC_TECH_CATEGORY_COMMERCE
const DOMESTIC_TECH_CATEGORY_MILITARY := DomesticTechCatalogScript.DOMESTIC_TECH_CATEGORY_MILITARY
const DOMESTIC_TECH_CATEGORY_NATION_ADMIN := DomesticTechCatalogScript.DOMESTIC_TECH_CATEGORY_NATION_ADMIN
const DOMESTIC_TECH_CATEGORY_NATION_ECONOMY := DomesticTechCatalogScript.DOMESTIC_TECH_CATEGORY_NATION_ECONOMY
const DOMESTIC_TECH_CATEGORY_NATION_MILITARY := DomesticTechCatalogScript.DOMESTIC_TECH_CATEGORY_NATION_MILITARY
const DOMESTIC_TECH_CATEGORY_NATION_DIPLOMACY := DomesticTechCatalogScript.DOMESTIC_TECH_CATEGORY_NATION_DIPLOMACY
const DOMESTIC_TECH_ICON_FALLBACK_LABEL := DomesticTechCatalogScript.DOMESTIC_TECH_ICON_FALLBACK_LABEL
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

var _ui_parent: Node
var _callbacks: Dictionary = {}
var _effect_provider: RefCounted
var _tech_tree_overlay_canvas_mvp: CanvasLayer
var _tech_tree_overlay_mvp: PanelContainer
var _tech_tree_content_root_mvp: VBoxContainer
var _selected_domestic_tech_id_mvp := ""
var _selected_domestic_tech_city_id_mvp := ""
var _domestic_tech_compact_node_refs_mvp: Dictionary = {}
var _domestic_tech_icon_texture_cache_mvp: Dictionary = {}
var _domestic_tech_detail_inspector_label_mvp: Label
var _domestic_tech_research_action_button_mvp: Button
var _domestic_tech_research_action_hint_label_mvp: Label


func configure(ui_parent: Node, callbacks: Dictionary, effect_provider: RefCounted) -> void:
	_ui_parent = ui_parent
	_callbacks = callbacks.duplicate()
	_effect_provider = effect_provider


func open() -> void:
	_ensure_domestic_tech_tree_overlay_mvp()
	if _tech_tree_overlay_mvp == null:
		return
	_tech_tree_overlay_mvp.visible = true
	_tech_tree_overlay_mvp.move_to_front()
	_refresh_domestic_tech_tree_overlay_mvp()


func close() -> void:
	if _tech_tree_overlay_mvp != null:
		_tech_tree_overlay_mvp.visible = false
	_selected_domestic_tech_id_mvp = ""
	_selected_domestic_tech_city_id_mvp = ""


func is_open() -> bool:
	return _tech_tree_overlay_mvp != null and _tech_tree_overlay_mvp.visible


func refresh() -> void:
	_refresh_domestic_tech_tree_overlay_mvp()


func ensure_overlay() -> void:
	_ensure_domestic_tech_tree_overlay_mvp()


func get_selection() -> Dictionary:
	return {"tech_id": _selected_domestic_tech_id_mvp, "city_id": _selected_domestic_tech_city_id_mvp}


func get_overlay_canvas() -> CanvasLayer:
	return _tech_tree_overlay_canvas_mvp


func get_overlay() -> PanelContainer:
	return _tech_tree_overlay_mvp


func get_graph_layout_contract() -> Dictionary:
	return {
		"overlay_margin": DOMESTIC_TECH_TREE_OVERLAY_MARGIN,
		"tree_region_ratio": DOMESTIC_TECH_TREE_REGION_RATIO,
		"detail_region_ratio": DOMESTIC_TECH_DETAIL_REGION_RATIO,
		"node_size": DOMESTIC_TECH_GRAPH_NODE_SIZE,
		"tier_spacing": DOMESTIC_TECH_GRAPH_TIER_SPACING,
		"branch_spacing": DOMESTIC_TECH_GRAPH_BRANCH_SPACING,
		"branch_stack_spacing": DOMESTIC_TECH_GRAPH_BRANCH_STACK_SPACING,
		"graph_margin": DOMESTIC_TECH_GRAPH_MARGIN,
		"line_width": DOMESTIC_TECH_GRAPH_LINE_WIDTH,
	}


func _call(callback_id: String, args: Array = [], fallback: Variant = null) -> Variant:
	var callback_variant: Variant = _callbacks.get(callback_id)
	if callback_variant is Callable and (callback_variant as Callable).is_valid():
		return (callback_variant as Callable).callv(args)
	return fallback


func _call_string_array(callback_id: String, args: Array = []) -> Array[String]:
	var result: Array[String] = []
	var raw_result: Variant = _call(callback_id, args, [])
	if raw_result is Array:
		for value in raw_result:
			result.append(str(value))
	return result


func _selected_city_id() -> String:
	return str(_call("selected_city_id", [], ""))


func _has_selected_city() -> bool:
	return bool(_call("has_selected_city", [], false))


func _close_domestic_tech_tree_overlay_mvp() -> void:
	close()
	closed.emit()


func _on_domestic_tech_research_action_pressed_mvp() -> void:
	if _selected_domestic_tech_id_mvp.is_empty():
		return
	research_requested.emit(_selected_domestic_tech_id_mvp, _selected_domestic_tech_city_id_mvp)


func _ensure_domestic_tech_effect_provider() -> RefCounted:
	return _effect_provider

func _get_domestic_tech_ui64_icon_filename_mvp(tech_id: String) -> String:
	return DomesticTechHelperLib.get_ui64_icon_filename_mvp(tech_id, DOMESTIC_TECH_UI64_ICON_FILENAME_MAP)


func _get_domestic_tech_resolved_icon_path_mvp(tech_id: String, definition_icon_path: String = "") -> String:
	return DomesticTechHelperLib.get_resolved_icon_path_mvp(tech_id, definition_icon_path, DOMESTIC_TECH_UI64_ICON_ROOT, DOMESTIC_TECH_UI64_ICON_FILENAME_MAP)


func _ensure_domestic_tech_tree_overlay_mvp() -> void:
	if _tech_tree_overlay_mvp != null:
		return
	if _tech_tree_overlay_canvas_mvp == null:
		_tech_tree_overlay_canvas_mvp = CanvasLayer.new()
		_tech_tree_overlay_canvas_mvp.name = "DomesticTechTreeOverlayCanvasMVP"
		_tech_tree_overlay_canvas_mvp.layer = DOMESTIC_TECH_TREE_OVERLAY_LAYER
		_ui_parent.add_child(_tech_tree_overlay_canvas_mvp)

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
	_tech_tree_overlay_canvas_mvp.add_child(_tech_tree_overlay_mvp)
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
	_domestic_tech_detail_inspector_label_mvp = null
	_domestic_tech_research_action_button_mvp = null
	_domestic_tech_research_action_hint_label_mvp = null
	_domestic_tech_compact_node_refs_mvp.clear()

	var header_row := HBoxContainer.new()
	header_row.name = "DomesticTechTreeHeaderRow"
	header_row.add_theme_constant_override("separation", 8)
	_tech_tree_content_root_mvp.add_child(header_row)

	var title_box := VBoxContainer.new()
	title_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_box.add_theme_constant_override("separation", 2)
	header_row.add_child(title_box)

	var title_label := _make_domestic_tech_label_mvp("EASTWAR 테크트리", 24, Color(1.0, 0.84, 0.42, 1.0))
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_box.add_child(title_label)

	var close_button := Button.new()
	close_button.name = "DomesticTechTreeCloseButton"
	close_button.text = "닫기"
	close_button.custom_minimum_size = Vector2(72.0, 30.0)
	close_button.focus_mode = Control.FOCUS_NONE
	close_button.pressed.connect(_close_domestic_tech_tree_overlay_mvp)
	header_row.add_child(close_button)

	var body := Control.new()
	body.name = "DomesticTechBoundedBody"
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.clip_contents = true
	body.mouse_filter = Control.MOUSE_FILTER_PASS
	_tech_tree_content_root_mvp.add_child(body)

	var tree_region := Control.new()
	tree_region.name = "DomesticTechTreeRegion"
	tree_region.set_anchors_preset(Control.PRESET_FULL_RECT)
	tree_region.anchor_bottom = DOMESTIC_TECH_TREE_REGION_RATIO
	tree_region.offset_bottom = -DOMESTIC_TECH_BODY_GAP * 0.5
	tree_region.clip_contents = true
	tree_region.mouse_filter = Control.MOUSE_FILTER_PASS
	body.add_child(tree_region)

	var split := HBoxContainer.new()
	split.name = "DomesticTechTreeSplit"
	split.set_anchors_preset(Control.PRESET_FULL_RECT)
	split.clip_contents = true
	split.add_theme_constant_override("separation", 10)
	tree_region.add_child(split)
	_build_national_tech_tree_panel_mvp(split)
	_build_city_tech_tree_panel_mvp(split, _selected_city_id())

	var detail_region := HBoxContainer.new()
	detail_region.name = "DomesticTechDetailSplit"
	detail_region.anchor_top = 1.0 - DOMESTIC_TECH_DETAIL_REGION_RATIO
	detail_region.anchor_right = 1.0
	detail_region.anchor_bottom = 1.0
	detail_region.offset_top = DOMESTIC_TECH_BODY_GAP * 0.5
	detail_region.clip_contents = true
	detail_region.add_theme_constant_override("separation", 10)
	body.add_child(detail_region)
	_build_domestic_tech_detail_inspector_mvp(detail_region)
	_build_domestic_tech_detail_placeholders_mvp(detail_region)
	_refresh_domestic_tech_detail_inspector_mvp()


func _build_national_tech_tree_panel_mvp(parent: Container) -> void:
	var panel := _make_domestic_tech_section_panel_mvp("NationalTechTreePanelMVP")
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(panel)

	var content := _make_domestic_tech_section_content_mvp(panel)
	content.add_child(_make_domestic_tech_label_mvp("국가 테크트리", 17, Color(1.0, 0.86, 0.54, 1.0)))

	var scroll := _make_domestic_tech_scroll_mvp()
	content.add_child(scroll)
	var list := VBoxContainer.new()
	list.name = "NationalTechList"
	list.add_theme_constant_override("separation", 0)
	scroll.add_child(list)

	for category_id in [DOMESTIC_TECH_CATEGORY_NATION_ADMIN, DOMESTIC_TECH_CATEGORY_NATION_ECONOMY, DOMESTIC_TECH_CATEGORY_NATION_MILITARY, DOMESTIC_TECH_CATEGORY_NATION_DIPLOMACY]:
		_build_domestic_tech_category_group_mvp(list, category_id, "", DOMESTIC_TECH_SCOPE_NATIONAL)


func _build_city_tech_tree_panel_mvp(parent: Container, city_id: String) -> void:
	var panel := _make_domestic_tech_section_panel_mvp("CityTechTreePanelMVP")
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(panel)

	var content := _make_domestic_tech_section_content_mvp(panel)
	content.add_child(_make_domestic_tech_label_mvp("도시 테크트리", 17, Color(1.0, 0.86, 0.54, 1.0)))

	if city_id.is_empty() or not _has_selected_city():
		content.add_child(_make_domestic_tech_label_mvp("도시를 선택하면 도시 테크트리가 표시됩니다.", 13, Color(0.82, 0.84, 0.78, 1.0)))
		return

	content.add_child(_make_domestic_tech_label_mvp("선택 도시: %s" % _format_city_name_by_id(city_id, city_id), 11, Color(0.70, 0.76, 0.80, 1.0)))
	if not _is_city_owned_by_player_mvp(city_id):
		content.add_child(_make_domestic_tech_label_mvp("선택 도시의 내정 테크 정보가 부족합니다.\n첩보 또는 도시 정보 확보 후 확인할 수 있습니다.", 13, Color(0.72, 0.74, 0.76, 1.0)))
		return

	var scroll := _make_domestic_tech_scroll_mvp()
	content.add_child(scroll)
	var list := VBoxContainer.new()
	list.name = "CityTechList"
	list.add_theme_constant_override("separation", 0)
	scroll.add_child(list)

	for category_id in [DOMESTIC_TECH_CATEGORY_AGRI, DOMESTIC_TECH_CATEGORY_FISH, DOMESTIC_TECH_CATEGORY_COMMERCE, DOMESTIC_TECH_CATEGORY_MILITARY]:
		_build_domestic_tech_category_group_mvp(list, category_id, city_id, DOMESTIC_TECH_SCOPE_CITY)


func _build_domestic_tech_detail_inspector_mvp(parent: Container) -> void:
	var panel := _make_domestic_tech_section_panel_mvp("DomesticTechDetailInspectorMVP")
	panel.custom_minimum_size = Vector2.ZERO
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.size_flags_stretch_ratio = 1.0
	parent.add_child(panel)

	var content := _make_domestic_tech_section_content_mvp(panel)
	var title_label := _make_domestic_tech_label_mvp("선택 테크 상세 정보", 15, Color(1.0, 0.86, 0.54, 1.0))
	title_label.name = "DomesticTechDetailTitleMVP"
	content.add_child(title_label)

	var body_scroll := ScrollContainer.new()
	body_scroll.name = "DomesticTechDetailBodyScrollMVP"
	body_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	content.add_child(body_scroll)

	var body_content := VBoxContainer.new()
	body_content.name = "DomesticTechDetailBodyMVP"
	body_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body_scroll.add_child(body_content)

	_domestic_tech_detail_inspector_label_mvp = _make_domestic_tech_label_mvp("테크를 선택하면 상세 정보가 표시됩니다.", 11, Color(0.82, 0.84, 0.78, 1.0))
	_domestic_tech_detail_inspector_label_mvp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body_content.add_child(_domestic_tech_detail_inspector_label_mvp)

	var research_footer := HBoxContainer.new()
	research_footer.name = "DomesticTechResearchFooterMVP"
	research_footer.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	research_footer.add_theme_constant_override("separation", 8)
	content.add_child(research_footer)

	_domestic_tech_research_action_button_mvp = Button.new()
	_domestic_tech_research_action_button_mvp.name = "DomesticTechResearchActionButtonMVP"
	_domestic_tech_research_action_button_mvp.text = "연구 시작"
	_domestic_tech_research_action_button_mvp.disabled = true
	_domestic_tech_research_action_button_mvp.focus_mode = Control.FOCUS_NONE
	_domestic_tech_research_action_button_mvp.custom_minimum_size = Vector2(104.0, 30.0)
	_domestic_tech_research_action_button_mvp.tooltip_text = "조건을 충족한 테크만 연구를 시작할 수 있습니다."
	research_footer.add_child(_domestic_tech_research_action_button_mvp)

	_domestic_tech_research_action_hint_label_mvp = _make_domestic_tech_label_mvp("연구 시작 기능은 다음 단계에서 활성화됩니다.", 11, Color(0.72, 0.74, 0.70, 1.0))
	_domestic_tech_research_action_hint_label_mvp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_domestic_tech_research_action_hint_label_mvp.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	research_footer.add_child(_domestic_tech_research_action_hint_label_mvp)
	_update_domestic_tech_research_action_slot_mvp({})


func _build_domestic_tech_detail_placeholders_mvp(parent: HBoxContainer) -> void:
	var inspector := parent.get_node_or_null("DomesticTechDetailInspectorMVP") as PanelContainer
	if inspector == null:
		return
	parent.add_child(_make_domestic_tech_detail_placeholder_mvp("NationalTechDetailPlaceholderMVP", "국가 테크 상세 정보", inspector))
	parent.add_child(_make_domestic_tech_detail_placeholder_mvp("CityTechDetailPlaceholderMVP", "도시 테크 상세 정보", inspector))


func _make_domestic_tech_detail_placeholder_mvp(node_name: String, title_text: String, style_source: PanelContainer) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.name = node_name
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.size_flags_stretch_ratio = 1.0
	panel.mouse_filter = Control.MOUSE_FILTER_PASS
	var source_style := style_source.get_theme_stylebox("panel")
	if source_style != null:
		panel.add_theme_stylebox_override("panel", source_style.duplicate() as StyleBox)
	var content := _make_domestic_tech_section_content_mvp(panel)
	content.add_child(_make_domestic_tech_label_mvp(title_text, 15, Color(1.0, 0.86, 0.54, 1.0)))
	var center := CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(center)
	var watermark := TextureRect.new()
	watermark.name = "TechDetailWatermarkMVP"
	watermark.texture = DOMESTIC_TECH_DETAIL_WATERMARK
	watermark.custom_minimum_size = DOMESTIC_TECH_DETAIL_WATERMARK_SIZE
	watermark.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	watermark.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	watermark.modulate = Color(1.0, 1.0, 1.0, DOMESTIC_TECH_DETAIL_WATERMARK_ALPHA)
	watermark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(watermark)
	return panel


func _refresh_domestic_tech_detail_inspector_mvp() -> void:
	if _domestic_tech_detail_inspector_label_mvp == null:
		return
	if _selected_domestic_tech_id_mvp.is_empty():
		_domestic_tech_detail_inspector_label_mvp.text = "테크를 선택하면 상세 정보가 표시됩니다."
		_update_domestic_tech_research_action_slot_mvp({})
		_route_domestic_tech_detail_region_mvp()
		return
	var definition := _get_domestic_tech_definition_mvp(_selected_domestic_tech_id_mvp)
	if definition.is_empty():
		_selected_domestic_tech_id_mvp = ""
		_selected_domestic_tech_city_id_mvp = ""
		_domestic_tech_detail_inspector_label_mvp.text = "테크를 선택하면 상세 정보가 표시됩니다."
		_update_domestic_tech_research_action_slot_mvp({})
		_route_domestic_tech_detail_region_mvp()
		return
	var scope := str(definition.get("tree_scope", ""))
	if scope == DOMESTIC_TECH_SCOPE_CITY:
		var current_city_for_detail := _selected_city_id()
		if _selected_domestic_tech_city_id_mvp.is_empty() or _selected_domestic_tech_city_id_mvp != current_city_for_detail or not _is_city_owned_by_player_mvp(_selected_domestic_tech_city_id_mvp):
			_selected_domestic_tech_id_mvp = ""
			_selected_domestic_tech_city_id_mvp = ""
			_domestic_tech_detail_inspector_label_mvp.text = "테크를 선택하면 상세 정보가 표시됩니다."
			_update_domestic_tech_research_action_slot_mvp({})
			_route_domestic_tech_detail_region_mvp()
			return
	var view_state := _get_domestic_tech_view_state_mvp(_selected_domestic_tech_id_mvp, _selected_domestic_tech_city_id_mvp)
	_domestic_tech_detail_inspector_label_mvp.text = _format_domestic_tech_detail_text_mvp(definition, view_state, _selected_domestic_tech_city_id_mvp)
	_update_domestic_tech_research_action_slot_mvp(view_state)
	_route_domestic_tech_detail_region_mvp()


func _route_domestic_tech_detail_region_mvp() -> void:
	if _tech_tree_content_root_mvp == null:
		return
	var detail_region := _tech_tree_content_root_mvp.find_child("DomesticTechDetailSplit", true, false) as HBoxContainer
	var inspector := _tech_tree_content_root_mvp.find_child("DomesticTechDetailInspectorMVP", true, false) as PanelContainer
	var national_placeholder := _tech_tree_content_root_mvp.find_child("NationalTechDetailPlaceholderMVP", true, false) as PanelContainer
	var city_placeholder := _tech_tree_content_root_mvp.find_child("CityTechDetailPlaceholderMVP", true, false) as PanelContainer
	if detail_region == null or inspector == null or national_placeholder == null or city_placeholder == null:
		return
	var title_label := inspector.get_node_or_null("MarginContainer/Content/DomesticTechDetailTitleMVP") as Label
	var scope := ""
	if not _selected_domestic_tech_id_mvp.is_empty():
		scope = "city" if not _selected_domestic_tech_city_id_mvp.is_empty() else "national"
	match scope:
		"national":
			inspector.visible = true
			national_placeholder.visible = false
			city_placeholder.visible = true
			detail_region.move_child(inspector, 0)
			detail_region.move_child(city_placeholder, 1)
			if title_label != null:
				title_label.text = "국가 테크 상세 정보"
		"city":
			inspector.visible = true
			national_placeholder.visible = true
			city_placeholder.visible = false
			detail_region.move_child(national_placeholder, 0)
			detail_region.move_child(inspector, 1)
			if title_label != null:
				title_label.text = "도시 테크 상세 정보"
		_:
			inspector.visible = false
			national_placeholder.visible = true
			city_placeholder.visible = true
			detail_region.move_child(national_placeholder, 0)
			detail_region.move_child(city_placeholder, 1)
			if title_label != null:
				title_label.text = "선택 테크 상세 정보"


func _format_domestic_tech_detail_text_mvp(tech_def: Dictionary, view_state: Dictionary, city_id: String = "") -> String:
	var tech_id := str(tech_def.get("id", ""))
	var scope := str(tech_def.get("tree_scope", ""))
	var scope_label := "국가 테크" if scope == DOMESTIC_TECH_SCOPE_NATIONAL else "도시 테크"
	var category_id := str(tech_def.get("category", ""))
	var category_data: Dictionary = _get_domestic_tech_categories_mvp().get(category_id, {})
	var category_label := str(category_data.get("name", category_id))
	var branch_label := _format_domestic_tech_branch_label_mvp(str(tech_def.get("branch", "")))
	var rarity_label := _format_domestic_tech_rarity_mvp(int(tech_def.get("rarity", 0)))
	var title := "%s %s" % [str(tech_def.get("name", tech_id)), rarity_label]
	var effect_stub: Dictionary = tech_def.get("effect_stub", {})
	var lines: Array[String] = []
	lines.append("테크: %s" % title.strip_edges())
	lines.append("분류: %s / %s / %s / Tier %d" % [scope_label, category_label, branch_label, int(tech_def.get("tier", 0))])
	lines.append("현재 상태: %s" % _format_domestic_tech_readiness_state_label_mvp(str(view_state.get("state", DOMESTIC_TECH_VIEW_LOCKED))))
	lines.append("효과 설명: %s" % str(effect_stub.get("description", "")))
	var effect_display := _get_domestic_tech_effect_phase1_display_mvp(tech_def, scope, city_id)
	if not effect_display.is_empty():
		lines.append("적용 상태:\n- %s" % "\n- ".join(effect_display))
	var economy_bonus_city_id := city_id
	if economy_bonus_city_id.is_empty() and _has_selected_city():
		economy_bonus_city_id = _selected_city_id()
	var economy_bonus_display := _format_domestic_tech_city_economy_bonus_lines_mvp(economy_bonus_city_id)
	if not economy_bonus_display.is_empty():
		lines.append("선택 도시 적용 경제 보너스:\n- %s" % "\n- ".join(economy_bonus_display))
	var military_defense_bonus_city_id := city_id
	if military_defense_bonus_city_id.is_empty() and _has_selected_city():
		military_defense_bonus_city_id = _selected_city_id()
	var military_defense_bonus_display := _format_domestic_tech_city_military_defense_bonus_lines_mvp(military_defense_bonus_city_id, _get_city_hud_entry(military_defense_bonus_city_id))
	if not military_defense_bonus_display.is_empty():
		lines.append("선택 도시 적용 군사/방어 보너스:\n- %s" % "\n- ".join(military_defense_bonus_display))
	var naval_siege_bonus_city_id := city_id
	if naval_siege_bonus_city_id.is_empty() and _has_selected_city():
		naval_siege_bonus_city_id = _selected_city_id()
	var naval_siege_bonus_display := _format_domestic_tech_city_naval_siege_bonus_lines_mvp(naval_siege_bonus_city_id)
	if not naval_siege_bonus_display.is_empty():
		lines.append("선택 도시 적용 해군/공성 보너스:\n- %s" % "\n- ".join(naval_siege_bonus_display))
	var city_spy_intel_bonus_city_id := city_id
	if city_spy_intel_bonus_city_id.is_empty() and _has_selected_city():
		city_spy_intel_bonus_city_id = _selected_city_id()
	var city_spy_intel_bonus_display := _format_domestic_tech_city_spy_intel_bonus_lines_mvp(city_spy_intel_bonus_city_id)
	if not city_spy_intel_bonus_display.is_empty():
		lines.append("선택 도시 적용 첩보/정보망 준비:\n- %s" % "\n- ".join(city_spy_intel_bonus_display))
	if scope == DOMESTIC_TECH_SCOPE_NATIONAL:
		var national_policy_bonus_display := _format_domestic_tech_national_policy_bonus_lines_mvp()
		if not national_policy_bonus_display.is_empty():
			lines.append("적용 중인 국가 정책 보너스:\n- %s" % "\n- ".join(national_policy_bonus_display))
		var diplomacy_spy_bonus_display := _format_domestic_tech_diplomacy_spy_bonus_lines_mvp()
		if not diplomacy_spy_bonus_display.is_empty():
			lines.append("적용 중인 외교/첩보 준비:\n- %s" % "\n- ".join(diplomacy_spy_bonus_display))
	for plan_line in _format_domestic_tech_research_plan_lines_mvp(tech_def, view_state, scope):
		lines.append(plan_line)
	var conditions := _get_domestic_tech_readiness_condition_lines_mvp(tech_def, view_state, city_id)
	if not conditions.is_empty():
		lines.append("조건 충족 여부:\n- %s" % "\n- ".join(conditions))
	var relations := _get_domestic_tech_relation_lines_mvp(tech_def, city_id)
	if not relations.is_empty():
		lines.append("국가/도시 연결 관계:\n- %s" % "\n- ".join(relations))
	var readiness_text := _format_domestic_tech_research_readiness_text_mvp(view_state)
	if not readiness_text.is_empty():
		lines.append(readiness_text)
	return "\n\n".join(lines)


func _format_domestic_tech_research_plan_lines_mvp(tech_def: Dictionary, view_state: Dictionary, scope: String = "") -> Array[String]:
	var state_id := str(view_state.get("state", DOMESTIC_TECH_VIEW_LOCKED))
	var duration_text := _format_domestic_tech_duration_hint_mvp(tech_def)
	match state_id:
		DOMESTIC_TECH_VIEW_COMPLETED:
			return ["상태: 완료됨"]
		DOMESTIC_TECH_VIEW_RESEARCHING:
			var active_research: Dictionary = view_state.get("active_research", {}) if view_state.get("active_research", {}) is Dictionary else {}
			var remaining_turns := maxi(1, int(active_research.get("remaining_turns", active_research.get("duration_turns", 1))))
			var duration_turns := maxi(remaining_turns, int(active_research.get("duration_turns", remaining_turns)))
			return ["상태: 연구 중", "남은 턴: %d / 총 %d턴" % [remaining_turns, duration_turns]]
		DOMESTIC_TECH_VIEW_AVAILABLE:
			return [
				"상태: 연구 가능",
				"연구 소요: %s" % duration_text,
				_format_domestic_tech_research_cost_plan_mvp(tech_def, scope),
			]
		_:
			return ["상태: 조건 부족", "연구 소요: %s" % duration_text]


func _format_domestic_tech_research_cost_display_mvp(cost_plan: Dictionary) -> String:
	var parts: Array[String] = []
	var planned_gold_cost := maxi(0, int(cost_plan.get("planned_gold_cost", 0)))
	var planned_food_cost := maxi(0, int(cost_plan.get("planned_food_cost", 0)))
	var planned_labor_cost := maxi(0, int(cost_plan.get("planned_labor_cost", 0)))
	var planned_policy_cost := maxi(0, int(cost_plan.get("planned_policy_cost", 0)))
	if planned_gold_cost > 0:
		parts.append("금 %d" % planned_gold_cost)
	if planned_food_cost > 0:
		parts.append("군량 %d" % planned_food_cost)
	if planned_labor_cost > 0:
		parts.append("노역 %d" % planned_labor_cost)
	if planned_policy_cost > 0:
		parts.append("정책 %d" % planned_policy_cost)
	if parts.is_empty():
		return "필요 비용 없음"
	return "필요 비용: %s · 시작 시 차감" % " / ".join(parts)


func _format_domestic_tech_research_cost_plan_mvp(tech_def: Dictionary, scope: String = "") -> String:
	return _format_domestic_tech_research_cost_display_mvp(_get_domestic_tech_research_cost_plan_mvp(tech_def, scope))


func _format_domestic_tech_actual_charge_shortage_mvp(validation: Dictionary) -> String:
	var missing: Dictionary = validation.get("missing", {}) if validation.get("missing", {}) is Dictionary else {}
	var parts: Array[String] = []
	if missing.has("gold"):
		parts.append("금 %d" % maxi(0, int(missing.get("gold", 0))))
	if missing.has("food_group"):
		parts.append("군량 %d" % maxi(0, int(missing.get("food_group", 0))))
	if parts.is_empty():
		return ""
	return "부족: %s" % " / ".join(parts)


func _get_domestic_tech_requirement_summary_mvp(tech_def: Dictionary, view_state: Dictionary, _city_id: String = "") -> Array[String]:
	var result: Array[String] = []
	for required_id_variant in tech_def.get("prerequisites", []):
		result.append("선행: %s" % _get_domestic_tech_display_name_mvp(str(required_id_variant)))
	for required_national_id_variant in tech_def.get("required_national_techs", []):
		result.append("국가 테크: %s" % _get_domestic_tech_display_name_mvp(str(required_national_id_variant)))
	for special_reason in _format_domestic_tech_special_requirements_mvp(tech_def):
		result.append(str(special_reason))
	for lock_reason in view_state.get("lock_reasons", []):
		var reason_text := str(lock_reason)
		if not result.has(reason_text):
			result.append(reason_text)
	if result.is_empty():
		result.append("추가 조건 없음")
	return result


func _update_domestic_tech_research_action_slot_mvp(view_state: Dictionary) -> void:
	if _domestic_tech_research_action_button_mvp != null:
		var validation := _can_start_domestic_tech_research_mvp(_selected_domestic_tech_id_mvp, _selected_domestic_tech_city_id_mvp) if not _selected_domestic_tech_id_mvp.is_empty() else {"ok": false, "message": "테크를 선택하면 연구 준비 상태가 표시됩니다."}
		_domestic_tech_research_action_button_mvp.disabled = not bool(validation.get("ok", false))
		_domestic_tech_research_action_button_mvp.text = _format_domestic_tech_research_action_button_text_mvp(view_state, validation)
		_domestic_tech_research_action_button_mvp.tooltip_text = str(validation.get("message", _format_domestic_tech_research_action_hint_mvp(view_state)))
		var pressed_callable := Callable(self, "_on_domestic_tech_research_action_pressed_mvp")
		if bool(validation.get("ok", false)):
			if not _domestic_tech_research_action_button_mvp.pressed.is_connected(pressed_callable):
				_domestic_tech_research_action_button_mvp.pressed.connect(pressed_callable)
		elif _domestic_tech_research_action_button_mvp.pressed.is_connected(pressed_callable):
			_domestic_tech_research_action_button_mvp.pressed.disconnect(pressed_callable)
	if _domestic_tech_research_action_hint_label_mvp == null:
		return
	_domestic_tech_research_action_hint_label_mvp.text = _format_domestic_tech_research_action_hint_mvp(view_state)


func _format_domestic_tech_research_action_button_text_mvp(view_state: Dictionary, validation: Dictionary) -> String:
	var state_id := str(view_state.get("state", ""))
	if bool(validation.get("ok", false)):
		return "연구 시작"
	match state_id:
		DOMESTIC_TECH_VIEW_RESEARCHING:
			return "연구 중"
		DOMESTIC_TECH_VIEW_COMPLETED:
			return "완료"
		DOMESTIC_TECH_VIEW_SPECIAL_LOCKED:
			return "조건 부족"
		DOMESTIC_TECH_VIEW_LOCKED:
			return "조건 부족"
		_:
			if str(validation.get("reason", "")) == "insufficient_cost":
				return "자원 부족"
			if str(validation.get("reason", "")) in ["national_active", "city_active", "already_researching"]:
				return "연구 중"
			return "연구 시작"


func _format_domestic_tech_readiness_state_label_mvp(state_id: String) -> String:
	match state_id:
		DOMESTIC_TECH_VIEW_COMPLETED:
			return "완료"
		DOMESTIC_TECH_VIEW_RESEARCHING:
			return "진행 중"
		DOMESTIC_TECH_VIEW_AVAILABLE:
			return "가능"
		DOMESTIC_TECH_VIEW_SPECIAL_LOCKED:
			return "특수잠금"
		_:
			return "잠김"


func _format_domestic_tech_research_readiness_text_mvp(view_state: Dictionary) -> String:
	var state_id := str(view_state.get("state", DOMESTIC_TECH_VIEW_LOCKED))
	match state_id:
		DOMESTIC_TECH_VIEW_COMPLETED:
			return "연구 상태: 완료됨\n이미 완료된 테크입니다."
		DOMESTIC_TECH_VIEW_RESEARCHING:
			var active_research: Dictionary = view_state.get("active_research", {})
			return "연구 상태: 진행 중\n남은 기간: %d턴 / 총 %d턴" % [
				maxi(1, int(active_research.get("remaining_turns", active_research.get("duration_turns", 1)))),
				maxi(1, int(active_research.get("duration_turns", active_research.get("remaining_turns", 1)))),
			]
		DOMESTIC_TECH_VIEW_AVAILABLE:
			var validation := _can_start_domestic_tech_research_mvp(_selected_domestic_tech_id_mvp, _selected_domestic_tech_city_id_mvp) if not _selected_domestic_tech_id_mvp.is_empty() else {"ok": false}
			if not bool(validation.get("ok", false)) and str(validation.get("reason", "")) in ["national_active", "city_active"]:
				var active: Dictionary = validation.get("active_research", {})
				return "연구 상태: 다른 연구 진행 중\n현재 진행: %s" % _format_domestic_tech_active_research_summary_mvp(active)
			if not bool(validation.get("ok", false)) and str(validation.get("reason", "")) == "insufficient_cost":
				var shortage_text := str(validation.get("message", ""))
				if shortage_text.is_empty():
					return "연구 상태: 자원 부족\n자원이 부족해 연구를 시작할 수 없습니다."
				return "연구 상태: 자원 부족\n자원이 부족해 연구를 시작할 수 없습니다. %s" % shortage_text
			return "연구 상태: 준비 가능\n조건을 충족했습니다."
		DOMESTIC_TECH_VIEW_SPECIAL_LOCKED:
			return "연구 상태: 특수 조건 필요\n해당 테크는 특정 국가 테크, 도시 조건, 영웅 조건 또는 자원 조건이 필요합니다."
		_:
			return ""


func _format_domestic_tech_research_action_slot_text_mvp(view_state: Dictionary) -> String:
	var validation := _can_start_domestic_tech_research_mvp(_selected_domestic_tech_id_mvp, _selected_domestic_tech_city_id_mvp) if not _selected_domestic_tech_id_mvp.is_empty() else {"ok": false}
	return "%s\n%s" % [_format_domestic_tech_research_action_button_text_mvp(view_state, validation), _format_domestic_tech_research_action_hint_mvp(view_state)]


func _format_domestic_tech_research_action_hint_mvp(view_state: Dictionary) -> String:
	var state_id := str(view_state.get("state", ""))
	match state_id:
		DOMESTIC_TECH_VIEW_COMPLETED:
			return "완료된 테크라 연구를 시작할 수 없습니다."
		DOMESTIC_TECH_VIEW_RESEARCHING:
			var active_research: Dictionary = view_state.get("active_research", {})
			return "연구 진행 중: %s" % _format_domestic_tech_active_research_summary_mvp(active_research)
		DOMESTIC_TECH_VIEW_AVAILABLE:
			var validation := _can_start_domestic_tech_research_mvp(_selected_domestic_tech_id_mvp, _selected_domestic_tech_city_id_mvp) if not _selected_domestic_tech_id_mvp.is_empty() else {"ok": false}
			if bool(validation.get("ok", false)):
				return "조건을 충족했습니다. 연구 시작 시 비용을 차감합니다."
			if str(validation.get("reason", "")) == "insufficient_cost":
				var shortage_text := str(validation.get("message", ""))
				if shortage_text.is_empty():
					return "자원이 부족해 연구를 시작할 수 없습니다."
				return "자원이 부족해 연구를 시작할 수 없습니다. %s" % shortage_text
			return str(validation.get("message", "연구 시작 조건을 확인하십시오."))
		DOMESTIC_TECH_VIEW_SPECIAL_LOCKED:
			return "특수 조건 충족 후 다음 단계에서 연구할 수 있습니다."
		DOMESTIC_TECH_VIEW_LOCKED:
			return "부족 조건을 먼저 충족해야 합니다."
		_:
			return "테크를 선택하면 연구 준비 상태가 표시됩니다."


func _get_domestic_tech_readiness_condition_lines_mvp(tech_def: Dictionary, view_state: Dictionary, city_id: String = "") -> Array[String]:
	var result: Array[String] = []
	var scope := str(tech_def.get("tree_scope", ""))
	for required_id_variant in tech_def.get("prerequisites", []):
		var required_id := str(required_id_variant)
		var required_scope := DOMESTIC_TECH_SCOPE_CITY if scope == DOMESTIC_TECH_SCOPE_CITY else DOMESTIC_TECH_SCOPE_NATIONAL
		result.append("선행 조건: %s - %s" % [_get_domestic_tech_display_name_mvp(required_id), _format_domestic_tech_completion_gate_status_mvp(required_id, required_scope, city_id)])
	for required_national_id_variant in tech_def.get("required_national_techs", []):
		var required_national_id := str(required_national_id_variant)
		result.append("국가 테크 필요 조건: %s - %s" % [_get_domestic_tech_display_name_mvp(required_national_id), _format_domestic_tech_completion_gate_status_mvp(required_national_id, DOMESTIC_TECH_SCOPE_NATIONAL)])
	for aptitude_line in _format_domestic_tech_governor_aptitudes_mvp(tech_def):
		result.append("태수 적성: %s - 확인 필요" % aptitude_line)
	for city_requirement_line in _format_domestic_tech_city_requirement_lines_mvp(tech_def, city_id):
		result.append(city_requirement_line)
	for special_line in _format_domestic_tech_special_requirements_mvp(tech_def):
		result.append("특수 조건: %s - 확인 필요" % special_line)
	for lock_reason in view_state.get("lock_reasons", []):
		var reason_text := str(lock_reason)
		var readable_reason := _format_domestic_tech_lock_reason_mvp(reason_text)
		var duplicate_found := false
		for existing_line in result:
			if existing_line.find(readable_reason) >= 0:
				duplicate_found = true
				break
		if not duplicate_found:
			result.append("부족 조건: %s - 미충족" % readable_reason)
	if result.is_empty():
		result.append("추가 조건 없음 - 충족")
	return result


func _format_domestic_tech_condition_met_label_mvp(is_met: bool) -> String:
	return "충족" if is_met else "미충족"


func _format_domestic_tech_completion_gate_status_mvp(tech_id: String, scope: String, city_id: String = "") -> String:
	if scope == DOMESTIC_TECH_SCOPE_NATIONAL:
		if _is_national_domestic_tech_completed_mvp(tech_id):
			return "충족"
		if _is_domestic_tech_researching_mvp(tech_id):
			return "연구 중 - 완료 필요"
		return "미충족"
	if scope == DOMESTIC_TECH_SCOPE_CITY:
		if _is_city_domestic_tech_completed_mvp(city_id, tech_id):
			return "충족"
		if _is_domestic_tech_researching_mvp(tech_id, city_id):
			return "연구 중 - 완료 필요"
		return "미충족"
	return "미충족"


func _format_domestic_tech_lock_reason_mvp(reason_text: String) -> String:
	if reason_text.begins_with("선행: "):
		return "선행 조건 " + reason_text.substr("선행: ".length())
	if reason_text.begins_with("국가: "):
		return "국가 테크 " + reason_text.substr("국가: ".length())
	if reason_text == "도시 조건":
		return "도시 조건"
	return reason_text


func _get_domestic_tech_relation_lines_mvp(tech_def: Dictionary, city_id: String = "") -> Array[String]:
	var result: Array[String] = []
	var scope := str(tech_def.get("tree_scope", ""))
	var relation_status := _get_domestic_tech_unlock_relation_status_mvp(tech_def, scope, city_id)
	if not relation_status.is_empty():
		result.append_array(relation_status)
	return result


func _get_domestic_tech_unlock_relation_status_mvp(tech_def: Dictionary, scope: String, city_id: String = "") -> Array[String]:
	var result: Array[String] = []
	var tech_id := str(tech_def.get("id", ""))
	if scope == DOMESTIC_TECH_SCOPE_NATIONAL:
		var national_completed := _is_national_domestic_tech_completed_mvp(tech_id)
		var national_researching := _is_domestic_tech_researching_mvp(tech_id)
		for target_id_variant in tech_def.get("unlocks_city_techs", []):
			var unlock_target_id := str(target_id_variant)
			var unlock_status := "연구 필요"
			if national_completed:
				unlock_status = "해금됨"
				if not city_id.is_empty() and _is_city_owned_by_player_mvp(city_id) and _is_domestic_city_tech_mvp(unlock_target_id):
					var target_state := _get_domestic_tech_view_state_mvp(unlock_target_id, city_id)
					if str(target_state.get("state", DOMESTIC_TECH_VIEW_LOCKED)) == DOMESTIC_TECH_VIEW_AVAILABLE:
						unlock_status = "해금됨"
					elif str(target_state.get("state", DOMESTIC_TECH_VIEW_LOCKED)) in [DOMESTIC_TECH_VIEW_LOCKED, DOMESTIC_TECH_VIEW_SPECIAL_LOCKED]:
						unlock_status = "국가 조건 충족"
			elif national_researching:
				unlock_status = "연구 완료 후 해금"
			result.append("연결 도시 테크: %s - %s" % [_get_domestic_tech_display_name_mvp(unlock_target_id), unlock_status])
		for target_id_variant in tech_def.get("enhances_city_techs", []):
			var enhance_target_id := str(target_id_variant)
			var enhance_status := "강화 연구 필요"
			if national_completed:
				enhance_status = "강화 조건 충족"
			elif national_researching:
				enhance_status = "연구 완료 후 강화"
			result.append("연결 도시 테크: %s - %s" % [_get_domestic_tech_display_name_mvp(enhance_target_id), enhance_status])
	elif scope == DOMESTIC_TECH_SCOPE_CITY:
		for required_national_id_variant in tech_def.get("required_national_techs", []):
			var required_national_id := str(required_national_id_variant)
			var required_status := _format_domestic_tech_completion_gate_status_mvp(required_national_id, DOMESTIC_TECH_SCOPE_NATIONAL)
			result.append("필요 국가 테크: %s - %s" % [_get_domestic_tech_display_name_mvp(required_national_id), required_status])
		for enhanced_by_id_variant in tech_def.get("enhanced_by_national_techs", []):
			var enhanced_by_id := str(enhanced_by_id_variant)
			var enhanced_status := "강화 조건 충족" if _is_national_domestic_tech_completed_mvp(enhanced_by_id) else "강화 연구 필요"
			if _is_domestic_tech_researching_mvp(enhanced_by_id):
				enhanced_status = "연구 완료 후 강화"
			result.append("강화 제공 국가 테크: %s - %s" % [_get_domestic_tech_display_name_mvp(enhanced_by_id), enhanced_status])
	return result


func _get_domestic_tech_effect_phase1_display_mvp(tech_def: Dictionary, scope: String, city_id: String = "") -> Array[String]:
	var result: Array[String] = []
	var tech_id := str(tech_def.get("id", ""))
	var is_completed := false
	if scope == DOMESTIC_TECH_SCOPE_NATIONAL:
		is_completed = _is_national_domestic_tech_completed_mvp(tech_id)
	elif scope == DOMESTIC_TECH_SCOPE_CITY:
		is_completed = _is_city_domestic_tech_completed_mvp(city_id, tech_id)
	var is_researching := _is_domestic_tech_researching_mvp(tech_id, city_id)
	if is_completed:
		result.append("효과 상태: 연구 완료됨")
	elif is_researching:
		result.append("효과 상태: 연구 중 - 완료 후 적용 준비")
	else:
		result.append("효과 상태: 연구 후 적용 준비")
	var unlocks: Array = tech_def.get("unlocks_city_techs", []) if tech_def.get("unlocks_city_techs", []) is Array else []
	var enhances: Array = tech_def.get("enhances_city_techs", []) if tech_def.get("enhances_city_techs", []) is Array else []
	var required_national_techs: Array = tech_def.get("required_national_techs", []) if tech_def.get("required_national_techs", []) is Array else []
	var enhanced_by_national_techs: Array = tech_def.get("enhanced_by_national_techs", []) if tech_def.get("enhanced_by_national_techs", []) is Array else []
	if scope == DOMESTIC_TECH_SCOPE_NATIONAL and (not unlocks.is_empty() or not enhances.is_empty()):
		result.append("해금 상태: 조건 충족 시 관련 테크 연구 가능")
	elif scope == DOMESTIC_TECH_SCOPE_CITY and (not required_national_techs.is_empty() or not enhanced_by_national_techs.is_empty()):
		result.append("국가 테크 조건은 완료 상태만 인정")
	var provider := _ensure_domestic_tech_effect_provider()
	var has_economy_safe_effect: bool = scope == DOMESTIC_TECH_SCOPE_CITY and provider.has_effect_mapping("economy", tech_id)
	var has_military_defense_safe_effect: bool = scope == DOMESTIC_TECH_SCOPE_CITY and provider.has_effect_mapping("military_defense", tech_id)
	var has_naval_siege_safe_effect: bool = scope == DOMESTIC_TECH_SCOPE_CITY and provider.has_effect_mapping("naval_siege", tech_id)
	var has_national_policy_safe_effect: bool = scope == DOMESTIC_TECH_SCOPE_NATIONAL and provider.has_effect_mapping("national_policy", tech_id)
	var has_diplomacy_spy_safe_effect: bool = scope == DOMESTIC_TECH_SCOPE_NATIONAL and provider.has_effect_mapping("diplomacy_spy", tech_id)
	var has_city_spy_intel_safe_effect: bool = scope == DOMESTIC_TECH_SCOPE_CITY and provider.has_effect_mapping("city_spy_intel", tech_id)
	if has_economy_safe_effect and is_completed:
		result.append("경제 효과: 선택 도시 수입에 적용 중")
	elif has_economy_safe_effect:
		result.append("경제 효과: 완료 후 선택 도시 수입에 적용")
	if has_military_defense_safe_effect and is_completed:
		result.append("군사/방어 효과: 선택 도시 표시 보너스에 적용 중")
	elif has_military_defense_safe_effect:
		result.append("군사/방어 효과: 완료 후 선택 도시 표시 보너스에 적용")
	if has_naval_siege_safe_effect and is_completed:
		result.append("해군/공성 효과: 선택 도시 해금/출정 조건에 적용 중")
	elif has_naval_siege_safe_effect:
		result.append("해군/공성 효과: 완료 후 선택 도시 해금/출정 조건에 적용")
	if has_national_policy_safe_effect and is_completed:
		result.append("국가 정책 효과: PLAYER 국가 보너스에 적용 중")
	elif has_national_policy_safe_effect:
		result.append("국가 정책 효과: 완료 후 PLAYER 국가 보너스에 적용")
	if has_diplomacy_spy_safe_effect and is_completed:
		result.append("외교/첩보 효과: PLAYER 준비 표시 보너스에 적용 중")
	elif has_diplomacy_spy_safe_effect:
		result.append("외교/첩보 효과: 완료 후 PLAYER 준비 표시 보너스에 적용")
	if has_city_spy_intel_safe_effect and is_completed:
		result.append("도시 첩보 효과: 선택 도시 준비 표시 보너스에 적용 중")
	elif has_city_spy_intel_safe_effect:
		result.append("도시 첩보 효과: 완료 후 선택 도시 준비 표시 보너스에 적용")
	if has_economy_safe_effect or has_military_defense_safe_effect or has_naval_siege_safe_effect or has_national_policy_safe_effect or has_diplomacy_spy_safe_effect or has_city_spy_intel_safe_effect:
		return result
	result.append("전투/외교/첩보/시장 효과는 후속 버전에서 적용됩니다")
	return result


func _format_domestic_tech_city_requirement_lines_mvp(tech_def: Dictionary, city_id: String = "") -> Array[String]:
	var result: Array[String] = []
	var raw_requirements: Variant = tech_def.get("special_requirements", {})
	if not raw_requirements is Dictionary:
		return result
	var city_requirements: Variant = (raw_requirements as Dictionary).get("city_requirements", {})
	if not city_requirements is Dictionary:
		return result
	for requirement_key_variant in (city_requirements as Dictionary).keys():
		var requirement_key := str(requirement_key_variant)
		var requirement_value: Variant = (city_requirements as Dictionary).get(requirement_key_variant)
		var is_met := true
		if requirement_key == "coastal":
			is_met = _is_city_coastal_for_city_tech(city_id) == bool(requirement_value)
		result.append("도시 조건: %s - %s" % [_format_domestic_tech_requirement_key_label_mvp(requirement_key), _format_domestic_tech_condition_met_label_mvp(is_met)])
	return result


func _format_domestic_tech_duration_hint_mvp(tech_def: Dictionary) -> String:
	var duration_hint: Variant = tech_def.get("duration_turns_hint", {})
	if duration_hint is Dictionary:
		var min_turns := int((duration_hint as Dictionary).get("min", 0))
		var max_turns := int((duration_hint as Dictionary).get("max", 0))
		if min_turns > 0 and max_turns > 0:
			if min_turns == max_turns:
				return "%d턴" % min_turns
			return "%d~%d턴" % [min_turns, max_turns]
	return str(tech_def.get("duration_class", "표시 전용"))


func _build_domestic_tech_category_group_mvp(parent: Container, category_id: String, city_id: String, scope: String) -> void:
	var definitions := _get_sorted_domestic_tech_definitions_for_category_mvp(category_id, scope)
	if definitions.is_empty():
		return
	var category_data: Dictionary = _get_domestic_tech_categories_mvp().get(category_id, {})
	var category_label := str(category_data.get("name", category_id))
	var section_margin := MarginContainer.new()
	section_margin.name = "DomesticTechCategorySection_%s" % category_id
	section_margin.add_theme_constant_override("margin_top", DOMESTIC_TECH_GRAPH_CATEGORY_TOP_MARGIN)
	section_margin.add_theme_constant_override("margin_bottom", DOMESTIC_TECH_GRAPH_CATEGORY_BOTTOM_MARGIN)
	parent.add_child(section_margin)

	var section := VBoxContainer.new()
	section.add_theme_constant_override("separation", 7)
	section_margin.add_child(section)

	var title_label := _make_domestic_tech_label_mvp(category_label, 15, Color(0.95, 0.78, 0.40, 1.0))
	title_label.custom_minimum_size = Vector2(0.0, 22.0)
	section.add_child(title_label)
	_build_domestic_tech_graph_canvas_mvp(section, definitions, city_id, scope)


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
	var branch_max_stack_counts: Dictionary = {}
	for definition in tech_defs:
		var branch_id := str(definition.get("branch", ""))
		if not branch_order.has(branch_id):
			branch_order.append(branch_id)
		var tier := maxi(1, int(definition.get("tier", 1)))
		var key := "%s:%d" % [branch_id, tier]
		branch_tier_counts[key] = int(branch_tier_counts.get(key, 0)) + 1
		branch_max_stack_counts[branch_id] = maxi(int(branch_max_stack_counts.get(branch_id, 0)), int(branch_tier_counts.get(key, 0)))
	var branch_y_offsets: Dictionary = {}
	var current_y := DOMESTIC_TECH_GRAPH_MARGIN.y
	for ordered_branch_id in branch_order:
		branch_y_offsets[ordered_branch_id] = current_y
		var max_stack_count := maxi(1, int(branch_max_stack_counts.get(ordered_branch_id, 1)))
		current_y += DOMESTIC_TECH_GRAPH_BRANCH_SPACING + float(max_stack_count - 1) * DOMESTIC_TECH_GRAPH_BRANCH_STACK_SPACING
	branch_tier_counts.clear()
	for definition in tech_defs:
		var positioned_branch_id := str(definition.get("branch", ""))
		var positioned_tier := maxi(1, int(definition.get("tier", 1)))
		var positioned_key := "%s:%d" % [positioned_branch_id, positioned_tier]
		branch_tier_counts[positioned_key] = int(branch_tier_counts.get(positioned_key, 0)) + 1
		var local_index := int(branch_tier_counts.get(positioned_key, 0)) - 1
		var graph_position := Vector2(
			DOMESTIC_TECH_GRAPH_MARGIN.x + float(positioned_tier - 1) * DOMESTIC_TECH_GRAPH_TIER_SPACING,
			float(branch_y_offsets.get(positioned_branch_id, DOMESTIC_TECH_GRAPH_MARGIN.y)) + float(local_index) * DOMESTIC_TECH_GRAPH_BRANCH_STACK_SPACING
		)
		positions[str(definition.get("id", ""))] = Rect2(graph_position, DOMESTIC_TECH_GRAPH_NODE_SIZE)
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
		label.position = Vector2(8.0, maxf(0.0, float(branch_label_y.get(branch_id_variant, 0.0)) + 26.0))
		label.custom_minimum_size = Vector2(82.0, 34.0)
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
	var node_panel := _build_domestic_tech_compact_node_mvp(parent, tech_def, rect.position, city_id)
	node_panel.position = rect.position
	node_panel.custom_minimum_size = rect.size
	node_panel.size = rect.size
	node_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	return node_panel


func _get_domestic_tech_graph_line_color_mvp(state_id: String) -> Color:
	match state_id:
		DOMESTIC_TECH_VIEW_COMPLETED:
			return Color(0.92, 0.78, 0.36, 0.92)
		DOMESTIC_TECH_VIEW_RESEARCHING:
			return Color(0.42, 0.68, 1.0, 0.84)
		DOMESTIC_TECH_VIEW_AVAILABLE:
			return Color(0.68, 0.54, 0.28, 0.78)
		DOMESTIC_TECH_VIEW_SPECIAL_LOCKED:
			return Color(0.34, 0.30, 0.25, 0.68)
		_:
			return Color(0.22, 0.22, 0.22, 0.62)


func _build_domestic_tech_compact_node_mvp(parent: Control, tech_def: Dictionary, graph_position: Vector2, city_id: String) -> PanelContainer:
	var tech_id := str(tech_def.get("id", ""))
	var view_state := _get_domestic_tech_view_state_mvp(tech_id, city_id)
	var state_id := str(view_state.get("state", DOMESTIC_TECH_VIEW_LOCKED))
	var is_selected := _is_selected_domestic_tech_for_inspector_mvp(tech_id, city_id)

	var node_panel := PanelContainer.new()
	node_panel.name = "DomesticTechCompactNode_%s" % tech_id
	node_panel.position = graph_position
	node_panel.custom_minimum_size = DOMESTIC_TECH_GRAPH_NODE_SIZE
	node_panel.size = DOMESTIC_TECH_GRAPH_NODE_SIZE
	node_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	node_panel.set_meta("domestic_tech_id", tech_id)
	node_panel.set_meta("domestic_tech_city_id", city_id)
	node_panel.set_meta("domestic_tech_state", state_id)
	node_panel.add_theme_stylebox_override("panel", _make_domestic_tech_compact_node_style_mvp(state_id, is_selected))
	node_panel.gui_input.connect(_on_domestic_tech_compact_node_gui_input_mvp.bind(tech_id, city_id))
	parent.add_child(node_panel)
	_domestic_tech_compact_node_refs_mvp[_get_domestic_tech_selection_key_mvp(tech_id, city_id)] = node_panel

	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_left", 5)
	margin.add_theme_constant_override("margin_top", 5)
	margin.add_theme_constant_override("margin_right", 5)
	margin.add_theme_constant_override("margin_bottom", 5)
	node_panel.add_child(margin)

	var body := VBoxContainer.new()
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.add_theme_constant_override("separation", 0)
	margin.add_child(body)

	var header := HBoxContainer.new()
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_theme_constant_override("separation", 6)
	body.add_child(header)
	_add_domestic_tech_icon_mvp(header, tech_id, DOMESTIC_TECH_GRAPH_COMPACT_ICON_SIZE, 24)

	var text_box := VBoxContainer.new()
	text_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text_box.add_theme_constant_override("separation", 1)
	header.add_child(text_box)

	var title_text := "%s %s" % [str(tech_def.get("name", tech_id)), _format_domestic_tech_rarity_mvp(int(tech_def.get("rarity", 0)))]
	var title_label := _make_domestic_tech_label_mvp(title_text.strip_edges(), 12, _get_domestic_tech_state_text_color_mvp(state_id))
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	title_label.max_lines_visible = 1
	title_label.clip_text = true
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	text_box.add_child(title_label)

	var status_label := _make_domestic_tech_label_mvp(_format_domestic_tech_compact_status_mvp(view_state), 11, _get_domestic_tech_state_text_color_mvp(state_id))
	status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	status_label.clip_text = true
	status_label.custom_minimum_size = Vector2(0.0, 20.0)
	text_box.add_child(status_label)
	return node_panel


func _on_domestic_tech_compact_node_gui_input_mvp(event: InputEvent, tech_id: String, city_id: String) -> void:
	if not event is InputEventMouseButton:
		return
	var mouse_button_event := event as InputEventMouseButton
	if mouse_button_event.button_index != MOUSE_BUTTON_LEFT or not mouse_button_event.pressed:
		return
	_set_selected_domestic_tech_for_inspector_mvp(tech_id, city_id)
	get_viewport().set_input_as_handled()


func _set_selected_domestic_tech_for_inspector_mvp(tech_id: String, city_id: String = "") -> void:
	var previous_selection_key := _get_current_domestic_tech_selection_key_mvp()
	_selected_domestic_tech_id_mvp = tech_id
	_selected_domestic_tech_city_id_mvp = city_id
	_refresh_domestic_tech_detail_inspector_mvp()
	_update_domestic_tech_selected_node_styles_mvp(previous_selection_key, _get_current_domestic_tech_selection_key_mvp())


func _is_selected_domestic_tech_for_inspector_mvp(tech_id: String, city_id: String = "") -> bool:
	if _selected_domestic_tech_id_mvp != tech_id:
		return false
	return _selected_domestic_tech_city_id_mvp == city_id


func _get_domestic_tech_selection_key_mvp(tech_id: String, city_id: String = "") -> String:
	return "%s|%s" % [city_id, tech_id]


func _get_current_domestic_tech_selection_key_mvp() -> String:
	if _selected_domestic_tech_id_mvp.is_empty():
		return ""
	return _get_domestic_tech_selection_key_mvp(_selected_domestic_tech_id_mvp, _selected_domestic_tech_city_id_mvp)


func _update_domestic_tech_selected_node_styles_mvp(previous_selection_key: String, current_selection_key: String) -> void:
	_apply_domestic_tech_compact_node_selection_style_mvp(previous_selection_key, false)
	_apply_domestic_tech_compact_node_selection_style_mvp(current_selection_key, true)


func _apply_domestic_tech_compact_node_selection_style_mvp(selection_key: String, is_selected: bool) -> void:
	if selection_key.is_empty() or not _domestic_tech_compact_node_refs_mvp.has(selection_key):
		return
	var node_panel := _domestic_tech_compact_node_refs_mvp.get(selection_key) as PanelContainer
	if node_panel == null or not is_instance_valid(node_panel):
		_domestic_tech_compact_node_refs_mvp.erase(selection_key)
		return
	var state_id := str(node_panel.get_meta("domestic_tech_state", DOMESTIC_TECH_VIEW_LOCKED))
	node_panel.add_theme_stylebox_override("panel", _make_domestic_tech_compact_node_style_mvp(state_id, is_selected))


func _format_domestic_tech_compact_status_mvp(view_state: Dictionary) -> String:
	var state_id := str(view_state.get("state", DOMESTIC_TECH_VIEW_LOCKED))
	match state_id:
		DOMESTIC_TECH_VIEW_COMPLETED:
			return "[완료]"
		DOMESTIC_TECH_VIEW_RESEARCHING:
			return "진행 중"
		DOMESTIC_TECH_VIEW_AVAILABLE:
			return "가능"
		DOMESTIC_TECH_VIEW_SPECIAL_LOCKED:
			return "[특수]"
		_:
			return "[잠김]"


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


func _add_domestic_tech_icon_mvp(parent: Container, tech_id: String, icon_size: float = DOMESTIC_TECH_TREE_ICON_SIZE, fallback_font_size: int = 18) -> void:
	var icon_box := PanelContainer.new()
	var fixed_icon_size := float(roundi(icon_size))
	icon_box.custom_minimum_size = Vector2(fixed_icon_size, fixed_icon_size)
	icon_box.size = Vector2(fixed_icon_size, fixed_icon_size)
	icon_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_box.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	icon_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icon_box.add_theme_stylebox_override("panel", _make_domestic_tech_icon_box_style_mvp())
	parent.add_child(icon_box)

	var icon_path := _get_domestic_tech_resolved_icon_path_mvp(tech_id, _get_domestic_tech_icon_path_mvp(tech_id))
	var texture: Texture2D = null
	if not icon_path.is_empty():
		if _domestic_tech_icon_texture_cache_mvp.has(icon_path):
			texture = _domestic_tech_icon_texture_cache_mvp.get(icon_path) as Texture2D
		else:
			var loaded_resource := load(icon_path)
			if loaded_resource is Texture2D:
				texture = loaded_resource as Texture2D
				_domestic_tech_icon_texture_cache_mvp[icon_path] = texture

	if texture != null:
		var texture_rect := TextureRect.new()
		texture_rect.texture = texture
		texture_rect.custom_minimum_size = Vector2(fixed_icon_size, fixed_icon_size)
		texture_rect.size = Vector2(fixed_icon_size, fixed_icon_size)
		texture_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		texture_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		texture_rect.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		icon_box.add_child(texture_rect)
		texture_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	else:
		var fallback_label := _make_domestic_tech_label_mvp(_get_domestic_tech_icon_fallback_label_mvp(tech_id), fallback_font_size, Color(0.86, 0.84, 0.76, 1.0))
		fallback_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
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
		"archer": "궁병",
		"archery": "궁병",
		"cavalry": "기병",
		"naval": "수군",
		"defense": "방어",
		"siege": "공성",
		"administration": "행정",
		"bureaucracy": "관료",
		"inspection": "감찰",
		"population": "인구",
		"tax": "세제",
		"currency": "화폐",
		"monopoly": "전매",
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
		match requirement_key:
			"city_requirements":
				continue
			"hero_required":
				result.append("영웅: %s" % _format_domestic_tech_requirement_value_mvp(requirement_value))
			"required_hero":
				result.append("영웅: %s" % _format_domestic_tech_requirement_value_mvp(requirement_value))
			"required_hero_flags":
				result.append("영웅 조건: %s" % _format_domestic_tech_requirement_value_mvp(requirement_value))
			"chancellor_aptitudes":
				result.append("재상: %s" % _format_domestic_tech_requirement_value_mvp(requirement_value))
			"average_loyalty":
				result.append("충성도 %s 필요" % str(requirement_value))
			"average_public_support":
				result.append("평균 민심 %s 필요" % str(requirement_value))
			"owned_city_count":
				result.append("보유 도시 %s 필요" % str(requirement_value))
			"governor_assigned_city_count":
				result.append("태수 임명 도시 %s 필요" % str(requirement_value))
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
			"resource_monopoly_candidates":
				result.append("전매 후보 자원: %s" % _format_domestic_tech_requirement_value_mvp(requirement_value))
			"connected_supply_city_count":
				result.append("연결 보급 도시 %s 필요" % str(requirement_value))
			"average_commerce":
				result.append("평균 상업 %s 필요" % str(requirement_value))
			"national_loyalty":
				result.append("전국 충성도 %s 필요" % str(requirement_value))
			"allied_faction_count":
				result.append("동맹 세력 %s 필요" % str(requirement_value))
			"neutral_faction_count":
				result.append("중립 세력 %s 필요" % str(requirement_value))
			"unlocks_flags":
				result.append("해금 조건: %s" % _format_domestic_tech_requirement_value_mvp(requirement_value))
			"min_loyalty":
				result.append("도시 충성도 %s 필요" % str(requirement_value))
			_:
				result.append("%s: %s" % [_format_domestic_tech_requirement_key_label_mvp(requirement_key), _format_domestic_tech_requirement_value_mvp(requirement_value)])
	return result


func _format_domestic_tech_requirement_value_mvp(value: Variant) -> String:
	if value is Array:
		var parts: Array[String] = []
		for item in value:
			var item_id := str(item)
			if _is_domestic_city_tech_mvp(item_id) or _is_domestic_national_tech_mvp(item_id):
				parts.append(_get_domestic_tech_display_name_mvp(item_id))
			else:
				parts.append(_format_domestic_tech_requirement_atom_mvp(item_id))
		return ", ".join(parts)
	if value is Dictionary:
		var parts: Array[String] = []
		for key_variant in (value as Dictionary).keys():
			var key := str(key_variant)
			var display_key := key
			if _is_domestic_city_tech_mvp(key) or _is_domestic_national_tech_mvp(key):
				display_key = _get_domestic_tech_display_name_mvp(key)
			else:
				display_key = _format_domestic_tech_requirement_key_label_mvp(key)
			parts.append("%s=%s" % [display_key, _format_domestic_tech_requirement_atom_mvp(str((value as Dictionary).get(key_variant)))])
		return ", ".join(parts)
	return _format_domestic_tech_requirement_atom_mvp(str(value))


func _format_domestic_tech_governor_aptitudes_mvp(definition: Dictionary) -> Array[String]:
	var result: Array[String] = []
	for aptitude_variant in definition.get("governor_aptitudes", []):
		result.append(_format_domestic_tech_aptitude_label_mvp(str(aptitude_variant)))
	return result


func _format_domestic_tech_requirement_atom_mvp(value_text: String) -> String:
	if value_text == "true":
		return "필요"
	if value_text == "false":
		return "불필요"
	if _is_domestic_city_tech_mvp(value_text) or _is_domestic_national_tech_mvp(value_text):
		return _get_domestic_tech_display_name_mvp(value_text)
	match value_text:
		"has_hero_yi_sunsin":
			return "이순신 필요"
		"enemy_city_operation":
			return "적 도시 공작"
		"administrative", "economic", "militaryAdmin", "maritime", "diplomatic", "political":
			return _format_domestic_tech_aptitude_label_mvp(value_text)
		_:
			return _format_domestic_tech_resource_label_mvp(value_text)


func _format_domestic_tech_requirement_key_label_mvp(requirement_key: String) -> String:
	match requirement_key:
		"coastal":
			return "연안 도시"
		"owned_city_count":
			return "보유 도시 수"
		"governor_assigned_city_count":
			return "태수 임명 도시 수"
		"average_public_support":
			return "평균 민심"
		"average_loyalty":
			return "평균 충성도"
		"average_commerce":
			return "평균 상업"
		"resource_surplus":
			return "자원 잉여"
		"resource_requirements":
			return "자원 필요 조건"
		"chancellor_aptitudes":
			return "재상 적성"
		"governor_aptitudes":
			return "태수 적성"
		"required_hero_flags":
			return "영웅 조건"
		"connected_supply_city_count":
			return "연결 보급 도시 수"
		"national_loyalty":
			return "전국 충성도"
		"min_loyalty":
			return "도시 충성도"
		"allied_faction_count":
			return "동맹 세력 수"
		"neutral_faction_count":
			return "중립 세력 수"
		"resource_monopoly_candidates":
			return "전매 후보 자원"
		"unlocks_flags":
			return "해금 조건"
		_:
			return _format_domestic_tech_resource_label_mvp(requirement_key)


func _format_domestic_tech_aptitude_label_mvp(aptitude_id: String) -> String:
	match aptitude_id:
		"administrative":
			return "행정"
		"economic":
			return "경제"
		"militaryAdmin":
			return "군정"
		"maritime":
			return "해양"
		"diplomatic":
			return "외교"
		"political":
			return "정치"
		_:
			return aptitude_id


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
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	return scroll


func _clear_domestic_tech_tree_children_mvp(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
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
		DOMESTIC_TECH_VIEW_RESEARCHING:
			style.bg_color = Color(0.10, 0.12, 0.16, 0.94)
			style.border_color = Color(0.42, 0.68, 1.0, 0.96)
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


func _make_domestic_tech_compact_node_style_mvp(state_id: String, is_selected: bool) -> StyleBoxFlat:
	var style := _make_domestic_tech_node_style_mvp(state_id)
	if is_selected:
		style.border_color = Color(1.0, 0.84, 0.38, 1.0)
		style.set_border_width_all(2)
	return style


func _get_domestic_tech_state_text_color_mvp(state_id: String) -> Color:
	match state_id:
		DOMESTIC_TECH_VIEW_COMPLETED:
			return Color(0.80, 1.0, 0.58, 1.0)
		DOMESTIC_TECH_VIEW_RESEARCHING:
			return Color(0.62, 0.82, 1.0, 1.0)
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


func _can_start_domestic_tech_research_mvp(tech_id: String, city_id: String = "") -> Dictionary:
	return _call("can_start", [tech_id, city_id], {}) as Dictionary
func _format_city_name_by_id(city_id: String, fallback: String = "") -> String:
	return str(_call("format_city_name", [city_id, fallback], fallback))
func _format_domestic_tech_active_research_summary_mvp(active: Dictionary) -> String:
	return str(_call("format_active_research", [active], ""))
func _format_domestic_tech_city_economy_bonus_lines_mvp(city_id: String) -> Array[String]:
	return _call_string_array("format_city_economy", [city_id])
func _format_domestic_tech_city_military_defense_bonus_lines_mvp(city_id: String, city_entry: Variant = null) -> Array[String]:
	return _call_string_array("format_city_military", [city_id, city_entry])
func _format_domestic_tech_city_naval_siege_bonus_lines_mvp(city_id: String) -> Array[String]:
	return _call_string_array("format_city_naval", [city_id])
func _format_domestic_tech_city_spy_intel_bonus_lines_mvp(city_id: String) -> Array[String]:
	return _call_string_array("format_city_spy", [city_id])
func _format_domestic_tech_diplomacy_spy_bonus_lines_mvp() -> Array[String]:
	return _call_string_array("format_diplomacy_spy")
func _format_domestic_tech_national_policy_bonus_lines_mvp() -> Array[String]:
	return _call_string_array("format_national_policy")
func _get_city_hud_entry(city_id: String) -> Variant:
	return _call("city_hud_entry", [city_id])
func _get_domestic_city_tech_definitions_mvp() -> Dictionary:
	return _call("city_definitions", [], {}) as Dictionary
func _get_domestic_national_tech_definitions_mvp() -> Dictionary:
	return _call("national_definitions", [], {}) as Dictionary
func _get_domestic_tech_categories_mvp() -> Dictionary:
	return _call("categories", [], {}) as Dictionary
func _get_domestic_tech_definition_mvp(tech_id: String) -> Dictionary:
	return _call("definition", [tech_id], {}) as Dictionary
func _get_domestic_tech_icon_path_mvp(tech_id: String) -> String:
	return str(_get_domestic_tech_definition_mvp(tech_id).get("icon_path", ""))
func _get_domestic_tech_icon_fallback_label_mvp(tech_id: String) -> String:
	return str(_get_domestic_tech_definition_mvp(tech_id).get("icon_fallback_label", DOMESTIC_TECH_ICON_FALLBACK_LABEL))
func _get_domestic_tech_research_cost_plan_mvp(tech_def: Dictionary, scope: String = "") -> Dictionary:
	return _call("research_cost_plan", [tech_def, scope], {}) as Dictionary
func _get_domestic_tech_view_state_mvp(tech_id: String, city_id: String = "") -> Dictionary:
	return _call("view_state", [tech_id, city_id], {}) as Dictionary
func _is_city_coastal_for_city_tech(city_id: String) -> bool:
	return bool(_call("city_coastal", [city_id], false))
func _is_city_domestic_tech_completed_mvp(city_id: String, tech_id: String) -> bool:
	return bool(_call("city_completed", [city_id, tech_id], false))
func _is_city_owned_by_player_mvp(city_id: String) -> bool:
	return bool(_call("city_owned", [city_id], false))
func _is_domestic_city_tech_mvp(tech_id: String) -> bool:
	return bool(_call("is_city_tech", [tech_id], false))
func _is_domestic_national_tech_mvp(tech_id: String) -> bool:
	return bool(_call("is_national_tech", [tech_id], false))
func _is_domestic_tech_researching_mvp(tech_id: String, city_id: String = "") -> bool:
	return bool(_call("researching", [tech_id, city_id], false))
func _is_national_domestic_tech_completed_mvp(tech_id: String) -> bool:
	return bool(_call("national_completed", [tech_id], false))
