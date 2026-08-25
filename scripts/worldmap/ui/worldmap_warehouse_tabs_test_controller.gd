extends Node

const RESOURCE_LABEL_PATH := "WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/ResourceLabel"
const TAB_FUNDS_FOOD := "funds_food"
const TAB_SPECIALTIES := "specialties"

const RESOURCE_GROUPS := {
	TAB_FUNDS_FOOD: ["금전", "쌀", "보리", "수산물"],
	TAB_SPECIALTIES: ["비단", "소금", "목재", "철", "말"],
}

const RESOURCE_COLORS := {
	"금전": Color(0.95, 0.73, 0.22, 1.0),
	"쌀": Color(0.86, 0.79, 0.56, 1.0),
	"보리": Color(0.72, 0.53, 0.24, 1.0),
	"수산물": Color(0.26, 0.66, 0.76, 1.0),
	"비단": Color(0.66, 0.38, 0.76, 1.0),
	"소금": Color(0.88, 0.90, 0.88, 1.0),
	"목재": Color(0.48, 0.31, 0.16, 1.0),
	"철": Color(0.49, 0.52, 0.57, 1.0),
	"말": Color(0.62, 0.34, 0.20, 1.0),
}

const GOLD_COLOR := Color(0.97, 0.84, 0.60, 1.0)
const NORMAL_COLOR := Color(0.88, 0.90, 0.94, 1.0)
const SHORTAGE_COLOR := Color(0.93, 0.34, 0.28, 1.0)
const GOOD_COLOR := Color(0.40, 0.76, 0.43, 1.0)

@onready var production_world_map: Node = get_node_or_null("../ProductionWorldMap")

var _source_label: Label = null
var _warehouse_root: VBoxContainer = null
var _tab_row: HBoxContainer = null
var _resource_list: VBoxContainer = null
var _funds_button: Button = null
var _specialties_button: Button = null
var _active_tab := TAB_FUNDS_FOOD
var _last_render_signature := ""
var _installed := false


func _ready() -> void:
	process_priority = 1230
	set_process(true)
	call_deferred("_install")


func _process(_delta: float) -> void:
	if not _installed:
		return
	if _source_label != null:
		_source_label.visible = false
	_refresh_if_needed()


func _install() -> void:
	if production_world_map == null:
		push_warning("WorldMap Warehouse Tabs: ProductionWorldMap is missing.")
		return
	_source_label = production_world_map.get_node_or_null(RESOURCE_LABEL_PATH) as Label
	if _source_label == null:
		push_warning("WorldMap Warehouse Tabs: ResourceLabel is missing.")
		return
	_build_warehouse_view()
	_source_label.visible = false
	_refresh_if_needed(true)
	_installed = true


func _build_warehouse_view() -> void:
	if _warehouse_root != null and is_instance_valid(_warehouse_root):
		return
	var parent := _source_label.get_parent() as Container
	if parent == null:
		return
	var source_index := _source_label.get_index()

	_warehouse_root = VBoxContainer.new()
	_warehouse_root.name = "WarehouseTabsCard"
	_warehouse_root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_warehouse_root.add_theme_constant_override("separation", 5)
	parent.add_child(_warehouse_root)
	parent.move_child(_warehouse_root, mini(source_index, parent.get_child_count() - 1))

	var title := Label.new()
	title.name = "WarehouseTitle"
	title.text = "국가 창고"
	title.add_theme_color_override("font_color", GOLD_COLOR)
	title.add_theme_font_size_override("font_size", 12)
	_warehouse_root.add_child(title)

	_tab_row = HBoxContainer.new()
	_tab_row.name = "WarehouseTabRow"
	_tab_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tab_row.add_theme_constant_override("separation", 5)
	_warehouse_root.add_child(_tab_row)

	_funds_button = _make_tab_button("자금·식량", TAB_FUNDS_FOOD)
	_specialties_button = _make_tab_button("특산물", TAB_SPECIALTIES)
	_tab_row.add_child(_funds_button)
	_tab_row.add_child(_specialties_button)

	_resource_list = VBoxContainer.new()
	_resource_list.name = "WarehouseResourceList"
	_resource_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_resource_list.add_theme_constant_override("separation", 3)
	_warehouse_root.add_child(_resource_list)
	_update_tab_visuals()


func _make_tab_button(text: String, tab_id: String) -> Button:
	var button := Button.new()
	button.text = text
	button.toggle_mode = true
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size", 10)
	button.pressed.connect(_on_tab_pressed.bind(tab_id))
	return button


func _on_tab_pressed(tab_id: String) -> void:
	if tab_id == _active_tab:
		_update_tab_visuals()
		return
	_active_tab = tab_id
	_last_render_signature = ""
	_update_tab_visuals()
	_refresh_if_needed(true)


func _update_tab_visuals() -> void:
	if _funds_button == null or _specialties_button == null:
		return
	_funds_button.set_pressed_no_signal(_active_tab == TAB_FUNDS_FOOD)
	_specialties_button.set_pressed_no_signal(_active_tab == TAB_SPECIALTIES)
	_style_tab_button(_funds_button, _active_tab == TAB_FUNDS_FOOD)
	_style_tab_button(_specialties_button, _active_tab == TAB_SPECIALTIES)


func _style_tab_button(button: Button, selected: bool) -> void:
	button.add_theme_color_override("font_color", GOLD_COLOR if selected else NORMAL_COLOR)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.09, 0.045, 0.80) if selected else Color(0.035, 0.07, 0.11, 0.70)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.83, 0.67, 0.34, 0.68) if selected else Color(0.55, 0.49, 0.39, 0.32)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", style.duplicate() as StyleBoxFlat)
	button.add_theme_stylebox_override("pressed", style.duplicate() as StyleBoxFlat)


func _refresh_if_needed(force: bool = false) -> void:
	if _source_label == null or _resource_list == null:
		return
	var source_text := _source_label.text
	var signature := "%s|%s" % [_active_tab, source_text]
	if not force and signature == _last_render_signature:
		return
	_last_render_signature = signature
	_rebuild_resource_rows(source_text)
	_request_panel_refit()


func _rebuild_resource_rows(source_text: String) -> void:
	for child in _resource_list.get_children():
		child.queue_free()
	var resources: Array = RESOURCE_GROUPS.get(_active_tab, [])
	for resource_name in resources:
		_resource_list.add_child(_make_resource_row(str(resource_name), source_text))


func _make_resource_row(resource_name: String, source_text: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.name = "WarehouseRow_%s" % resource_name
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 6)

	var placeholder := ColorRect.new()
	placeholder.name = "IconPlaceholder"
	placeholder.custom_minimum_size = Vector2(11.0, 11.0)
	placeholder.color = RESOURCE_COLORS.get(resource_name, Color(0.7, 0.7, 0.7, 1.0))
	placeholder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(placeholder)

	var name_label := Label.new()
	name_label.text = resource_name
	name_label.custom_minimum_size = Vector2(68.0, 0.0)
	name_label.add_theme_color_override("font_color", NORMAL_COLOR)
	name_label.add_theme_font_size_override("font_size", 11)
	row.add_child(name_label)

	var payload := _parse_resource_line(source_text, resource_name)
	var value_label := Label.new()
	value_label.text = str(payload.get("value", "- / -"))
	value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_label.add_theme_color_override("font_color", NORMAL_COLOR)
	value_label.add_theme_font_size_override("font_size", 11)
	row.add_child(value_label)

	var status_text := str(payload.get("status", ""))
	var status_label := Label.new()
	status_label.text = status_text
	status_label.custom_minimum_size = Vector2(38.0, 0.0)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	status_label.add_theme_font_size_override("font_size", 11)
	status_label.add_theme_color_override("font_color", _status_color(status_text))
	row.add_child(status_label)
	return row


func _parse_resource_line(source_text: String, resource_name: String) -> Dictionary:
	var regex := RegEx.new()
	var pattern := "%s\\s*([0-9,]+)\\s*/\\s*([0-9,]+)\\s*(부족|충분|가득|양호)?" % resource_name
	if regex.compile(pattern) != OK:
		return {"value": "- / -", "status": ""}
	var matched := regex.search(source_text)
	if matched == null:
		return {"value": "- / -", "status": ""}
	var current := matched.get_string(1)
	var maximum := matched.get_string(2)
	var status := matched.get_string(3) if matched.get_group_count() >= 3 else ""
	return {
		"value": "%s / %s" % [current, maximum],
		"status": status,
	}


func _status_color(status: String) -> Color:
	if status == "부족":
		return SHORTAGE_COLOR
	if status == "충분" or status == "가득" or status == "양호":
		return GOOD_COLOR
	return NORMAL_COLOR


func _request_panel_refit() -> void:
	var host := get_parent()
	if host != null and host.has_method("_fit_compact_panels"):
		host.call_deferred("_fit_compact_panels")
