extends Node

const LEFT_PANEL_PATH := "WorldMapUI/LeftWorldStatusPanel"
const RESOURCE_LABEL_PATH := "WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/ResourceLabel"
const TAB_FUNDS_FOOD := "funds_food"
const TAB_SPECIALTIES := "specialties"

const RESOURCE_GROUPS := {
	TAB_FUNDS_FOOD: ["금전", "쌀", "보리", "수산물"],
	TAB_SPECIALTIES: ["비단", "소금", "목재", "철", "말"],
}
const ALL_RESOURCES := ["금전", "쌀", "보리", "수산물", "비단", "소금", "목재", "철", "말"]
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
const ROW_COUNT := 5
const ROW_HEIGHT := 20.0
const ROW_GAP := 4
const RESOURCE_LIST_HEIGHT := ROW_HEIGHT * ROW_COUNT + ROW_GAP * (ROW_COUNT - 1)

@onready var production_world_map: Node = get_node_or_null("../ProductionWorldMap")

var _left_panel: Control = null
var _fallback_source_label: Label = null
var _legacy_warehouse_root: Control = null
var _warehouse_root: VBoxContainer = null
var _resource_list: VBoxContainer = null
var _funds_button: Button = null
var _specialties_button: Button = null
var _row_slots: Array[Dictionary] = []
var _active_tab := TAB_FUNDS_FOOD
var _last_render_signature := ""
var _installed := false


func _ready() -> void:
	# W2-A14: row structure is created once. Runtime refresh only changes text.
	set_process(false)
	call_deferred("_install")


func _install() -> void:
	if production_world_map == null:
		push_warning("WorldMap Warehouse Tabs: ProductionWorldMap is missing.")
		return
	_left_panel = production_world_map.get_node_or_null(LEFT_PANEL_PATH) as Control
	_fallback_source_label = production_world_map.get_node_or_null(RESOURCE_LABEL_PATH) as Label
	_ensure_runtime_binding()
	_refresh_if_needed(true)
	_request_initial_panel_refit()
	_installed = true


func _ensure_runtime_binding() -> void:
	if _left_panel == null or not is_instance_valid(_left_panel):
		return
	if _legacy_warehouse_root == null or not is_instance_valid(_legacy_warehouse_root):
		_legacy_warehouse_root = _find_visible_warehouse_block(_left_panel)
	if _warehouse_root == null or not is_instance_valid(_warehouse_root):
		_build_warehouse_view()


func _find_visible_warehouse_block(root: Node) -> Control:
	var titles: Array[Label] = []
	_collect_warehouse_title_labels(root, titles)
	for title in titles:
		var candidate: Node = title.get_parent()
		while candidate != null and candidate != root:
			if candidate is Control and _count_resource_labels(candidate) >= 5:
				return candidate as Control
			candidate = candidate.get_parent()
	return null


func _collect_warehouse_title_labels(node: Node, output: Array[Label]) -> void:
	if str(node.name) == "WarehouseTabsCard":
		return
	if node is Label and (node as Label).text.strip_edges() == "국가 창고":
		output.append(node as Label)
	for child in node.get_children():
		_collect_warehouse_title_labels(child, output)


func _count_resource_labels(node: Node) -> int:
	var labels: Array[Label] = []
	_collect_labels(node, labels)
	var hits := 0
	for resource_name in ALL_RESOURCES:
		for label in labels:
			var text := label.text.strip_edges()
			if text == resource_name or text.begins_with(resource_name + " "):
				hits += 1
				break
	return hits


func _build_warehouse_view() -> void:
	var anchor: Control = _legacy_warehouse_root
	if anchor == null:
		anchor = _fallback_source_label
	if anchor == null:
		return
	var parent := anchor.get_parent() as Container
	if parent == null:
		return
	var source_index := anchor.get_index()

	_warehouse_root = VBoxContainer.new()
	_warehouse_root.name = "WarehouseTabsCard"
	_warehouse_root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_warehouse_root.add_theme_constant_override("separation", 6)
	parent.add_child(_warehouse_root)
	parent.move_child(_warehouse_root, mini(source_index, parent.get_child_count() - 1))

	var header := HBoxContainer.new()
	header.name = "WarehouseHeaderRow"
	header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_theme_constant_override("separation", 5)
	_warehouse_root.add_child(header)

	var title := Label.new()
	title.name = "WarehouseTitle"
	title.text = "국가 창고"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_color_override("font_color", GOLD_COLOR)
	title.add_theme_font_size_override("font_size", 14)
	header.add_child(title)

	_funds_button = _make_tab_button("자금·식량", TAB_FUNDS_FOOD)
	_specialties_button = _make_tab_button("특산물", TAB_SPECIALTIES)
	header.add_child(_funds_button)
	header.add_child(_specialties_button)

	_resource_list = VBoxContainer.new()
	_resource_list.name = "WarehouseResourceList"
	_resource_list.custom_minimum_size = Vector2(0.0, RESOURCE_LIST_HEIGHT)
	_resource_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_resource_list.add_theme_constant_override("separation", ROW_GAP)
	_warehouse_root.add_child(_resource_list)

	_row_slots.clear()
	for index in range(ROW_COUNT):
		_row_slots.append(_make_resource_slot(index))

	_update_tab_visuals()
	_hide_legacy_source()


func _make_resource_slot(index: int) -> Dictionary:
	var row := HBoxContainer.new()
	row.name = "WarehouseStableRow_%d" % index
	row.custom_minimum_size = Vector2(0.0, ROW_HEIGHT)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 7)
	_resource_list.add_child(row)

	var placeholder := ColorRect.new()
	placeholder.name = "IconPlaceholder"
	placeholder.custom_minimum_size = Vector2(13.0, 13.0)
	placeholder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(placeholder)

	var name_label := Label.new()
	name_label.custom_minimum_size = Vector2(62.0, 0.0)
	name_label.add_theme_color_override("font_color", NORMAL_COLOR)
	name_label.add_theme_font_size_override("font_size", 13)
	row.add_child(name_label)

	var value_label := Label.new()
	value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_label.add_theme_color_override("font_color", NORMAL_COLOR)
	value_label.add_theme_font_size_override("font_size", 13)
	row.add_child(value_label)

	var status_label := Label.new()
	status_label.custom_minimum_size = Vector2(40.0, 0.0)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	status_label.add_theme_font_size_override("font_size", 13)
	row.add_child(status_label)

	return {
		"row": row,
		"icon": placeholder,
		"name": name_label,
		"value": value_label,
		"status": status_label,
	}


func _make_tab_button(text: String, tab_id: String) -> Button:
	var button := Button.new()
	button.text = text
	button.toggle_mode = true
	button.custom_minimum_size = Vector2(72.0, 26.0)
	button.add_theme_font_size_override("font_size", 12)
	button.pressed.connect(_on_tab_pressed.bind(tab_id))
	return button


func _on_tab_pressed(tab_id: String) -> void:
	if tab_id == _active_tab:
		return
	_active_tab = tab_id
	_last_render_signature = ""
	_update_tab_visuals()
	_refresh_if_needed(true)
	# No panel refit here. Both tabs always occupy the exact same five-row height.


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


func _hide_legacy_source() -> void:
	if _legacy_warehouse_root != null and is_instance_valid(_legacy_warehouse_root):
		_legacy_warehouse_root.visible = false
	if _fallback_source_label != null and is_instance_valid(_fallback_source_label):
		_fallback_source_label.visible = false
	if _warehouse_root != null and is_instance_valid(_warehouse_root):
		_warehouse_root.visible = true


func _refresh_if_needed(force: bool = false) -> void:
	if _resource_list == null or _row_slots.size() != ROW_COUNT:
		return
	var source_text := _get_source_text()
	var signature := "%s|%s" % [_active_tab, source_text]
	if not force and signature == _last_render_signature:
		return
	_last_render_signature = signature
	_render_resource_rows(source_text)


func _render_resource_rows(source_text: String) -> void:
	var resources: Array = RESOURCE_GROUPS.get(_active_tab, [])
	for index in range(ROW_COUNT):
		var slot: Dictionary = _row_slots[index]
		var icon := slot.get("icon") as ColorRect
		var name_label := slot.get("name") as Label
		var value_label := slot.get("value") as Label
		var status_label := slot.get("status") as Label
		var has_resource := index < resources.size()

		# Keep every row container alive and visible so its minimum height never
		# changes. Only the child contents are blanked for the unused fifth row.
		if not has_resource:
			icon.visible = false
			name_label.text = ""
			value_label.text = ""
			status_label.text = ""
			continue

		var resource_name := str(resources[index])
		var payload := _parse_resource_line(source_text, resource_name)
		var status_text := str(payload.get("status", ""))
		icon.visible = true
		icon.color = RESOURCE_COLORS.get(resource_name, Color(0.7, 0.7, 0.7, 1.0))
		name_label.text = resource_name
		value_label.text = str(payload.get("value", "- / -"))
		status_label.text = status_text
		status_label.add_theme_color_override("font_color", _status_color(status_text))


func _get_source_text() -> String:
	if _legacy_warehouse_root != null and is_instance_valid(_legacy_warehouse_root):
		var labels: Array[Label] = []
		_collect_labels(_legacy_warehouse_root, labels)
		var parts: Array[String] = []
		for label in labels:
			var text := label.text.strip_edges().replace("\n", " ")
			if not text.is_empty():
				parts.append(text)
		return " ".join(parts)
	if _fallback_source_label != null:
		return _fallback_source_label.text.replace("\n", " ")
	return ""


func _collect_labels(node: Node, output: Array[Label]) -> void:
	if node is Label:
		output.append(node as Label)
	for child in node.get_children():
		_collect_labels(child, output)


func _parse_resource_line(source_text: String, resource_name: String) -> Dictionary:
	var regex := RegEx.new()
	var pattern := "%s\\s*([0-9,]+)\\s*/\\s*([0-9,]+)\\s*(부족|충분|가득|양호)?" % resource_name
	if regex.compile(pattern) != OK:
		return {"value": "- / -", "status": ""}
	var matched := regex.search(source_text)
	if matched == null:
		return {"value": "- / -", "status": ""}
	return {
		"value": "%s / %s" % [matched.get_string(1), matched.get_string(2)],
		"status": matched.get_string(3) if matched.get_group_count() >= 3 else "",
	}


func _status_color(status: String) -> Color:
	if status == "부족":
		return SHORTAGE_COLOR
	if status == "충분" or status == "가득" or status == "양호":
		return GOOD_COLOR
	return NORMAL_COLOR


func _request_initial_panel_refit() -> void:
	var host := get_parent()
	if host != null and host.has_method("_fit_compact_panels"):
		host.call_deferred("_fit_compact_panels")
