extends Node

const GARRISON_CARD_PATH := "WorldMapUI/CityInfoPanel/MarginContainer/Content/GarrisonCard"
const COMPACT_GARRISON_HEIGHT := 96.0

@onready var production_world_map: Node = get_node_or_null("../ProductionWorldMap")

var _compact_scroll: ScrollContainer = null
var _compact_grid: GridContainer = null
var _signature := ""
var _installed := false


func _ready() -> void:
	process_priority = 1210
	set_process(true)
	call_deferred("_install")


func _process(_delta: float) -> void:
	if _installed:
		_refresh_if_needed()


func _install() -> void:
	if production_world_map == null:
		return
	_ensure_view()
	_refresh_if_needed(true)
	_installed = true


func _ensure_view() -> void:
	if _compact_scroll != null and is_instance_valid(_compact_scroll):
		return
	var card := production_world_map.get_node_or_null(GARRISON_CARD_PATH) as PanelContainer
	if card == null:
		return
	var content := card.get_node_or_null("MarginContainer/Content") as VBoxContainer
	if content == null:
		return

	_compact_scroll = ScrollContainer.new()
	_compact_scroll.name = "CompactGarrisonScroll"
	_compact_scroll.custom_minimum_size = Vector2(0.0, COMPACT_GARRISON_HEIGHT)
	_compact_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_compact_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_compact_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	content.add_child(_compact_scroll)

	_compact_grid = GridContainer.new()
	_compact_grid.name = "CompactGarrisonGrid"
	_compact_grid.columns = 3
	_compact_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_compact_grid.add_theme_constant_override("h_separation", 8)
	_compact_grid.add_theme_constant_override("v_separation", 7)
	_compact_scroll.add_child(_compact_grid)


func _refresh_if_needed(force: bool = false) -> void:
	_ensure_view()
	if _compact_grid == null:
		return

	var original_scroll := production_world_map.get_node_or_null(GARRISON_CARD_PATH + "/MarginContainer/Content/GarrisonScroll") as ScrollContainer
	var original_list: Node = null
	if original_scroll != null:
		original_list = original_scroll.get_node_or_null("GarrisonList")
	if original_list == null:
		original_list = production_world_map.get_node_or_null(GARRISON_CARD_PATH + "/MarginContainer/Content/GarrisonList")
	if original_list == null:
		return

	var rows: Array[Node] = []
	var names: Array[String] = []
	for row in original_list.get_children():
		var name_label := row.find_child("NameLabel", true, false) as Label
		if name_label == null:
			continue
		rows.append(row)
		names.append(name_label.text.strip_edges())
	var new_signature := "|".join(names)

	if force or new_signature != _signature:
		_signature = new_signature
		for child in _compact_grid.get_children():
			child.queue_free()
		for row in rows:
			_build_cell(row)

	if original_scroll != null:
		original_scroll.visible = false
	elif original_list is CanvasItem:
		(original_list as CanvasItem).visible = false
	_compact_scroll.visible = true


func _build_cell(source_row: Node) -> void:
	var name_source := source_row.find_child("NameLabel", true, false) as Label
	if name_source == null:
		return
	var cell := VBoxContainer.new()
	cell.custom_minimum_size = Vector2(70.0, 78.0)
	cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cell.alignment = BoxContainer.ALIGNMENT_CENTER
	cell.add_theme_constant_override("separation", 2)

	var portrait_source := _find_first_textured_rect(source_row)
	var portrait := TextureRect.new()
	portrait.custom_minimum_size = Vector2(52.0, 52.0)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait.texture = portrait_source.texture if portrait_source != null else null
	cell.add_child(portrait)

	var name_label := Label.new()
	name_label.text = name_source.text
	name_label.add_theme_font_size_override("font_size", 10)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	cell.add_child(name_label)
	_compact_grid.add_child(cell)


func _find_first_textured_rect(node: Node) -> TextureRect:
	if node is TextureRect and (node as TextureRect).texture != null:
		return node as TextureRect
	for child in node.get_children():
		var found := _find_first_textured_rect(child)
		if found != null:
			return found
	return null
