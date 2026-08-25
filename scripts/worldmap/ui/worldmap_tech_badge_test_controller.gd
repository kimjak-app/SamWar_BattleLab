extends Node

const LEFT_CONTENT_PATH := "WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content"
const RIGHT_CONTENT_PATH := "WorldMapUI/CityInfoPanel/MarginContainer/Content"
const TURN_END_BUTTON_NAME := "WildArmyEditButtonPlaceholder"
const GARRISON_CARD_NAME := "GarrisonCard"

const GRID_COLUMNS := 7
const MAX_VISIBLE_ROWS := 3
const BADGE_SIZE := Vector2(34.0, 34.0)
const BADGE_GAP := 4
const CARD_INNER_MARGIN := 7
const GOLD_COLOR := Color(0.94, 0.78, 0.46, 1.0)
const CARD_BORDER_COLOR := Color(0.63, 0.47, 0.19, 0.92)
const CARD_BG_COLOR := Color(0.025, 0.04, 0.052, 0.34)

const LEFT_SAMPLE_BADGES := [
	{
		"icon": "res://assets/ui/tech_icons_ui64/tech_agri_irrigation.png",
		"name": "관개 기술",
	},
	{
		"icon": "res://assets/ui/tech_icons_ui64/tech_commerce_mint.png",
		"name": "화폐 주조",
	},
	{
		"icon": "res://assets/ui/tech_icons_ui64/tech_fish_coastal_fishing.png",
		"name": "연안 어업",
	},
]
const RIGHT_SAMPLE_BADGES := [
	{
		"icon": "res://assets/ui/tech_icons_ui64/tech_agri_double_cropping.png",
		"name": "이모작",
	},
	{
		"icon": "res://assets/ui/tech_icons_ui64/tech_commerce_street_market.png",
		"name": "시전 정비",
	},
	{
		"icon": "res://assets/ui/tech_icons_ui64/tech_fish_salt_field.png",
		"name": "염전 개발",
	},
]

@onready var production_world_map: Node = get_node_or_null("../ProductionWorldMap")

var _left_section: PanelContainer = null
var _right_section: PanelContainer = null
var _installed := false


func _ready() -> void:
	process_priority = 1225
	set_process(true)
	call_deferred("_install")


func _process(_delta: float) -> void:
	if not _installed:
		return
	var restored := false
	for section in [_left_section, _right_section]:
		if section != null and is_instance_valid(section) and not section.visible:
			section.visible = true
			restored = true
	if restored:
		_request_panel_refit()


func _install() -> void:
	if production_world_map == null:
		push_warning("WorldMap Tech Badges: ProductionWorldMap is missing.")
		return
	var left_content := production_world_map.get_node_or_null(LEFT_CONTENT_PATH) as VBoxContainer
	var right_content := production_world_map.get_node_or_null(RIGHT_CONTENT_PATH) as VBoxContainer
	if left_content == null or right_content == null:
		push_warning("WorldMap Tech Badges: HUD content container is missing.")
		return

	_left_section = _build_section("TechBadgeSection_Left", "국가 테크트리", LEFT_SAMPLE_BADGES)
	_insert_left_section(left_content, _left_section)

	_right_section = _build_section("TechBadgeSection_Right", "성 테크트리", RIGHT_SAMPLE_BADGES)
	_insert_right_section(right_content, _right_section)

	_request_panel_refit()
	_installed = true


func _insert_left_section(parent: VBoxContainer, section: Control) -> void:
	parent.add_child(section)
	var turn_button := parent.get_node_or_null(TURN_END_BUTTON_NAME)
	if turn_button != null:
		parent.move_child(section, turn_button.get_index())


func _insert_right_section(parent: VBoxContainer, section: Control) -> void:
	parent.add_child(section)
	var garrison := parent.get_node_or_null(GARRISON_CARD_NAME)
	if garrison != null:
		parent.move_child(section, mini(garrison.get_index() + 1, parent.get_child_count() - 1))


func _build_section(section_name: String, title_text: String, samples: Array) -> PanelContainer:
	var section := PanelContainer.new()
	section.name = section_name
	section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	section.add_theme_stylebox_override("panel", _make_card_style())

	var margin := MarginContainer.new()
	margin.name = "Margin"
	margin.add_theme_constant_override("margin_left", CARD_INNER_MARGIN)
	margin.add_theme_constant_override("margin_top", CARD_INNER_MARGIN)
	margin.add_theme_constant_override("margin_right", CARD_INNER_MARGIN)
	margin.add_theme_constant_override("margin_bottom", CARD_INNER_MARGIN)
	section.add_child(margin)

	var content := VBoxContainer.new()
	content.name = "Content"
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 5)
	margin.add_child(content)

	var title := Label.new()
	title.name = "TechTreeTitle"
	title.text = title_text
	title.add_theme_color_override("font_color", GOLD_COLOR)
	title.add_theme_font_size_override("font_size", 13)
	content.add_child(title)

	var scroll := ScrollContainer.new()
	scroll.name = "TechTreeScroll"
	scroll.custom_minimum_size = Vector2(0.0, _visible_grid_height(samples.size()))
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	content.add_child(scroll)

	var grid := GridContainer.new()
	grid.name = "TechTreeGrid"
	grid.columns = GRID_COLUMNS
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", BADGE_GAP)
	grid.add_theme_constant_override("v_separation", BADGE_GAP)
	scroll.add_child(grid)

	# Only real completed technologies are rendered. Empty capacity remains clean
	# space instead of showing placeholder square outlines.
	for sample in samples:
		grid.add_child(_make_completed_badge(sample))
	return section


func _visible_grid_height(item_count: int) -> float:
	var rows := maxi(1, ceili(float(item_count) / float(GRID_COLUMNS)))
	rows = mini(rows, MAX_VISIBLE_ROWS)
	return float(rows) * BADGE_SIZE.y + float(maxi(0, rows - 1) * BADGE_GAP)


func _make_completed_badge(sample: Dictionary) -> Button:
	var badge := Button.new()
	badge.name = "CompletedTechBadge"
	badge.custom_minimum_size = BADGE_SIZE
	badge.text = ""
	badge.tooltip_text = str(sample.get("name", "테크트리"))
	badge.focus_mode = Control.FOCUS_NONE
	badge.flat = true
	badge.expand_icon = true
	badge.icon_max_width = int(BADGE_SIZE.x)
	badge.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	var icon_path := str(sample.get("icon", ""))
	if not icon_path.is_empty():
		var icon_texture := load(icon_path) as Texture2D
		if icon_texture != null:
			badge.icon = icon_texture

	badge.mouse_entered.connect(_on_badge_hover.bind(badge, true))
	badge.mouse_exited.connect(_on_badge_hover.bind(badge, false))
	return badge


func _on_badge_hover(badge: Button, hovered: bool) -> void:
	if badge == null or not is_instance_valid(badge):
		return
	badge.self_modulate = Color(1.08, 1.08, 1.08, 1.0) if hovered else Color.WHITE


func _make_card_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = CARD_BG_COLOR
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = CARD_BORDER_COLOR
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	return style


func _request_panel_refit() -> void:
	var host := get_parent()
	if host != null and host.has_method("_fit_compact_panels"):
		host.call_deferred("_fit_compact_panels")
