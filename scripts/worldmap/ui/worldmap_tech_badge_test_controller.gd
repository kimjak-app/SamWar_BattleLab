extends Node

const LEFT_CONTENT_PATH := "WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content"
const RIGHT_CONTENT_PATH := "WorldMapUI/CityInfoPanel/MarginContainer/Content"
const TURN_END_BUTTON_NAME := "WildArmyEditButtonPlaceholder"
const GARRISON_CARD_NAME := "GarrisonCard"

const GRID_COLUMNS := 5
const VISIBLE_ROWS := 3
const VISIBLE_SLOT_COUNT := GRID_COLUMNS * VISIBLE_ROWS
const BADGE_SIZE := Vector2(36.0, 36.0)
const BADGE_GAP := 5
const GRID_VIEW_HEIGHT := 118.0
const GOLD_COLOR := Color(0.94, 0.78, 0.46, 1.0)
const TEXT_COLOR := Color(0.95, 0.90, 0.78, 1.0)
const EMPTY_BORDER := Color(0.48, 0.43, 0.32, 0.38)

const LEFT_SAMPLE_BADGES := [
	{"glyph": "농", "name": "농업 기술", "color": Color(0.35, 0.58, 0.28, 1.0)},
	{"glyph": "군", "name": "군사 기술", "color": Color(0.58, 0.30, 0.24, 1.0)},
	{"glyph": "상", "name": "상업 기술", "color": Color(0.32, 0.47, 0.64, 1.0)},
]
const RIGHT_SAMPLE_BADGES := [
	{"glyph": "농", "name": "도시 농업 기술", "color": Color(0.35, 0.58, 0.28, 1.0)},
	{"glyph": "성", "name": "도시 방비 기술", "color": Color(0.62, 0.49, 0.24, 1.0)},
	{"glyph": "병", "name": "도시 병참 기술", "color": Color(0.50, 0.30, 0.56, 1.0)},
]

@onready var production_world_map: Node = get_node_or_null("../ProductionWorldMap")

var _left_section: VBoxContainer = null
var _right_section: VBoxContainer = null
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

	_left_section = _build_section("TechBadgeSection_Left", LEFT_SAMPLE_BADGES)
	_insert_left_section(left_content, _left_section)

	_right_section = _build_section("TechBadgeSection_Right", RIGHT_SAMPLE_BADGES)
	_insert_right_section(right_content, _right_section)

	_request_panel_refit()
	_installed = true


func _insert_left_section(parent: VBoxContainer, section: VBoxContainer) -> void:
	parent.add_child(section)
	var turn_button := parent.get_node_or_null(TURN_END_BUTTON_NAME)
	if turn_button != null:
		parent.move_child(section, turn_button.get_index())


func _insert_right_section(parent: VBoxContainer, section: VBoxContainer) -> void:
	parent.add_child(section)
	var garrison := parent.get_node_or_null(GARRISON_CARD_NAME)
	if garrison != null:
		parent.move_child(section, mini(garrison.get_index() + 1, parent.get_child_count() - 1))


func _build_section(section_name: String, samples: Array) -> VBoxContainer:
	var section := VBoxContainer.new()
	section.name = section_name
	section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	section.add_theme_constant_override("separation", 5)

	var title := Label.new()
	title.name = "CompletedTechTitle"
	title.text = "완성 기술"
	title.add_theme_color_override("font_color", GOLD_COLOR)
	title.add_theme_font_size_override("font_size", 12)
	section.add_child(title)

	var scroll := ScrollContainer.new()
	scroll.name = "CompletedTechScroll"
	scroll.custom_minimum_size = Vector2(0.0, GRID_VIEW_HEIGHT)
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	section.add_child(scroll)

	var grid := GridContainer.new()
	grid.name = "CompletedTechGrid"
	grid.columns = GRID_COLUMNS
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", BADGE_GAP)
	grid.add_theme_constant_override("v_separation", BADGE_GAP)
	scroll.add_child(grid)

	for index in VISIBLE_SLOT_COUNT:
		if index < samples.size():
			grid.add_child(_make_completed_badge(samples[index]))
		else:
			grid.add_child(_make_empty_slot())
	return section


func _make_completed_badge(sample: Dictionary) -> Button:
	var badge := Button.new()
	badge.name = "CompletedTechBadge"
	badge.custom_minimum_size = BADGE_SIZE
	badge.text = str(sample.get("glyph", ""))
	badge.tooltip_text = str(sample.get("name", "완성 기술"))
	badge.focus_mode = Control.FOCUS_NONE
	badge.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	badge.add_theme_font_size_override("font_size", 15)
	badge.add_theme_color_override("font_color", TEXT_COLOR)

	var normal := _badge_style(sample.get("color", Color(0.25, 0.25, 0.25, 1.0)), GOLD_COLOR, 0.88)
	var hover := _badge_style(sample.get("color", Color(0.25, 0.25, 0.25, 1.0)), Color(1.0, 0.88, 0.56, 1.0), 1.0)
	badge.add_theme_stylebox_override("normal", normal)
	badge.add_theme_stylebox_override("hover", hover)
	badge.add_theme_stylebox_override("pressed", hover.duplicate() as StyleBoxFlat)
	return badge


func _make_empty_slot() -> PanelContainer:
	var slot := PanelContainer.new()
	slot.name = "EmptyTechBadgeSlot"
	slot.custom_minimum_size = BADGE_SIZE
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.03, 0.045, 0.055, 0.34)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = EMPTY_BORDER
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_left = 5
	style.corner_radius_bottom_right = 5
	slot.add_theme_stylebox_override("panel", style)
	return slot


func _badge_style(background: Color, border: Color, alpha_scale: float) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	var bg := background
	bg.a *= alpha_scale
	style.bg_color = bg
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = border
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_left = 5
	style.corner_radius_bottom_right = 5
	return style


func _request_panel_refit() -> void:
	var host := get_parent()
	if host != null and host.has_method("_fit_compact_panels"):
		host.call_deferred("_fit_compact_panels")
