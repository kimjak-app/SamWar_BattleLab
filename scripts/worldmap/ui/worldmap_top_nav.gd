extends Control

signal menu_selected(menu_id: StringName)

const TOP_FONT: Font = preload("res://assets/font/noto_serif_kr/NotoSerifKR-Bold.otf")

const MENU_ITEMS := [
	{
		"id": &"techtree",
		"label": "테크트리",
		"texture": preload("res://assets/ui/worldmap/top_menu/icons/wm_topmenu_techtree.png"),
	},
	{
		"id": &"military",
		"label": "군사",
		"texture": preload("res://assets/ui/worldmap/top_menu/icons/wm_topmenu_military.png"),
	},
	{
		"id": &"personnel",
		"label": "인사",
		"texture": preload("res://assets/ui/worldmap/top_menu/icons/wm_topmenu_personnel.png"),
	},
	{
		"id": &"diplomacy",
		"label": "외교",
		"texture": preload("res://assets/ui/worldmap/top_menu/icons/wm_topmenu_diplomacy.png"),
	},
	{
		"id": &"trade",
		"label": "교역",
		"texture": preload("res://assets/ui/worldmap/top_menu/icons/wm_topmenu_trade.png"),
	},
	{
		"id": &"intel",
		"label": "첩보",
		"texture": preload("res://assets/ui/worldmap/top_menu/icons/wm_topmenu_intel.png"),
	},
	{
		"id": &"info",
		"label": "정보",
		"texture": preload("res://assets/ui/worldmap/top_menu/icons/wm_topmenu_info.png"),
	},
	{
		"id": &"system",
		"label": "시스템",
		"texture": preload("res://assets/ui/worldmap/top_menu/icons/wm_topmenu_system.png"),
	},
]

const BAR_SIZE := Vector2(672.0, 58.0)
const BAR_TOP := 4.0
const BAR_SIDE_MARGIN := 16.0
const SLOT_SIZE := Vector2(72.0, 54.0)
const SLOT_SEPARATION := 4
const ICON_SIZE := 56.0
const HOVER_SCALE := 1.10
const LABEL_SIZE := Vector2(72.0, 24.0)
const ANIM_TIME := 0.14

@export var production_world_map_path: NodePath

var _selected_id: StringName = &"techtree"
var _hovered_id: StringName = &""
var _slot_state: Dictionary = {}
var _slot_tweens: Dictionary = {}


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_top_bar()


func _build_top_bar() -> void:
	var bar := PanelContainer.new()
	bar.name = "TopMenuBar"
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.custom_minimum_size = BAR_SIZE
	bar.anchor_left = 0.5
	bar.anchor_right = 0.5
	bar.anchor_top = 0.0
	bar.anchor_bottom = 0.0
	bar.offset_left = -BAR_SIZE.x * 0.5
	bar.offset_right = BAR_SIZE.x * 0.5
	bar.offset_top = BAR_TOP
	bar.offset_bottom = BAR_TOP + BAR_SIZE.y
	bar.add_theme_stylebox_override("panel", _make_bar_style())
	add_child(bar)

	var margin := MarginContainer.new()
	margin.name = "MenuMargin"
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_left", int(BAR_SIDE_MARGIN))
	margin.add_theme_constant_override("margin_right", int(BAR_SIDE_MARGIN))
	margin.add_theme_constant_override("margin_top", 2)
	margin.add_theme_constant_override("margin_bottom", 2)
	bar.add_child(margin)

	var row := HBoxContainer.new()
	row.name = "MenuRow"
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", SLOT_SEPARATION)
	margin.add_child(row)

	for item in MENU_ITEMS:
		row.add_child(_build_menu_slot(item))


func _build_menu_slot(item: Dictionary) -> Control:
	var menu_id: StringName = item["id"]
	var slot := Control.new()
	slot.name = "%sSlot" % _node_name_for(menu_id)
	slot.custom_minimum_size = SLOT_SIZE
	slot.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var icon := TextureRect.new()
	icon.name = "Icon"
	icon.texture = item["texture"] as Texture2D
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.anchor_left = 0.5
	icon.anchor_right = 0.5
	icon.anchor_top = 0.5
	icon.anchor_bottom = 0.5
	icon.offset_left = -ICON_SIZE * 0.5
	icon.offset_right = ICON_SIZE * 0.5
	icon.offset_top = -ICON_SIZE * 0.5
	icon.offset_bottom = ICON_SIZE * 0.5
	icon.pivot_offset = Vector2.ONE * ICON_SIZE * 0.5
	slot.add_child(icon)

	var label_plate := PanelContainer.new()
	label_plate.name = "LabelPlate"
	label_plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label_plate.anchor_left = 0.5
	label_plate.anchor_right = 0.5
	label_plate.anchor_top = 0.5
	label_plate.anchor_bottom = 0.5
	label_plate.offset_left = -LABEL_SIZE.x * 0.5
	label_plate.offset_right = LABEL_SIZE.x * 0.5
	label_plate.offset_top = -LABEL_SIZE.y * 0.5
	label_plate.offset_bottom = LABEL_SIZE.y * 0.5
	label_plate.add_theme_stylebox_override("panel", _make_label_style())
	label_plate.modulate = Color(1.0, 1.0, 1.0, 0.0)
	slot.add_child(label_plate)

	var label := Label.new()
	label.name = "Label"
	label.text = str(item["label"])
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_override("font", TOP_FONT)
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(0.96, 0.82, 0.52, 1.0))
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.75))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	label_plate.add_child(label)

	var hit_button := Button.new()
	hit_button.name = "HitButton"
	hit_button.flat = true
	hit_button.focus_mode = Control.FOCUS_NONE
	hit_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	hit_button.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hit_button.mouse_entered.connect(_on_menu_hover_started.bind(menu_id))
	hit_button.mouse_exited.connect(_on_menu_hover_ended.bind(menu_id))
	hit_button.pressed.connect(_on_menu_pressed.bind(menu_id))
	slot.add_child(hit_button)

	_slot_state[menu_id] = {
		"icon": icon,
		"label_plate": label_plate,
	}
	return slot


func _on_menu_hover_started(menu_id: StringName) -> void:
	_hovered_id = menu_id
	_animate_menu(menu_id, true)


func _on_menu_hover_ended(menu_id: StringName) -> void:
	if _hovered_id == menu_id:
		_hovered_id = &""
	_animate_menu(menu_id, false)


func _on_menu_pressed(menu_id: StringName) -> void:
	var previous_id := _selected_id
	_selected_id = menu_id

	if previous_id != _selected_id:
		_refresh_label_state(previous_id)
		_refresh_label_state(_selected_id)

	menu_selected.emit(menu_id)

	if menu_id == &"techtree":
		_open_techtree_if_available()


func _animate_menu(menu_id: StringName, hovered: bool) -> void:
	if not _slot_state.has(menu_id):
		return

	var state: Dictionary = _slot_state[menu_id]
	var icon := state["icon"] as TextureRect
	var label_plate := state["label_plate"] as PanelContainer
	if icon == null or label_plate == null:
		return

	if _slot_tweens.has(menu_id):
		var old_tween := _slot_tweens[menu_id] as Tween
		if old_tween != null and old_tween.is_valid():
			old_tween.kill()

	var target_scale := Vector2.ONE * (HOVER_SCALE if hovered else 1.0)
	var target_modulate := Color(1.0, 1.0, 1.0, 1.0 if hovered else 0.0)

	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(icon, "scale", target_scale, ANIM_TIME)
	tween.tween_property(label_plate, "modulate", target_modulate, ANIM_TIME * 0.75)
	_slot_tweens[menu_id] = tween


func _refresh_label_state(menu_id: StringName) -> void:
	if not _slot_state.has(menu_id):
		return
	var state: Dictionary = _slot_state[menu_id]
	var label_plate := state["label_plate"] as PanelContainer
	if label_plate == null:
		return

	var show_label := menu_id == _hovered_id
	var target_modulate := Color(1.0, 1.0, 1.0, 1.0 if show_label else 0.0)

	if _slot_tweens.has(menu_id):
		var old_tween := _slot_tweens[menu_id] as Tween
		if old_tween != null and old_tween.is_valid():
			old_tween.kill()

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(label_plate, "modulate", target_modulate, ANIM_TIME * 0.75)
	_slot_tweens[menu_id] = tween


func _open_techtree_if_available() -> void:
	if production_world_map_path.is_empty():
		return

	var production_world_map := get_node_or_null(production_world_map_path)
	if production_world_map == null:
		push_warning("WorldMap TopNav: ProductionWorldMap is missing.")
		return
	if not production_world_map.has_method("_open_domestic_tech_tree_overlay_mvp"):
		push_warning("WorldMap TopNav: production tech tree opener is missing.")
		return
	production_world_map.call("_open_domestic_tech_tree_overlay_mvp")


func _make_bar_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.018, 0.017, 0.014, 0.72)
	style.border_color = Color(0.58, 0.40, 0.16, 0.62)
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_left = 2
	style.corner_radius_bottom_right = 2
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.42)
	style.shadow_size = 8
	style.shadow_offset = Vector2(0.0, 3.0)
	return style


func _make_label_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.025, 0.030, 0.026, 0.96)
	style.border_color = Color(0.78, 0.60, 0.28, 0.82)
	style.set_border_width_all(1)
	style.set_corner_radius_all(5)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.38)
	style.shadow_size = 4
	style.shadow_offset = Vector2(0.0, 2.0)
	return style


func _node_name_for(menu_id: StringName) -> String:
	match menu_id:
		&"techtree":
			return "TechTree"
		&"military":
			return "Military"
		&"personnel":
			return "Personnel"
		&"diplomacy":
			return "Diplomacy"
		&"trade":
			return "Trade"
		&"intel":
			return "Intel"
		&"info":
			return "Info"
		&"system":
			return "System"
		_:
			return str(menu_id).capitalize()
