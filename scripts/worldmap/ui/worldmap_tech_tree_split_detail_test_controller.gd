extends Node

const TECH_DETAIL_WATERMARK := preload("res://assets/ui/worldmap/tech_tree/wm_techtree_detail_watermark.png")
const TECH_TREE_OVERLAY_LAYER := 60
const TECH_DETAIL_WATERMARK_ALPHA := 0.25
const TECH_DETAIL_WATERMARK_SIZE := Vector2(240.0, 240.0)
const DETAIL_PANEL_MIN_HEIGHT := 270.0

var _world_map: Node = null
var _overlay_canvas: CanvasLayer = null
var _refined_inspector: PanelContainer = null
var _detail_split: HBoxContainer = null
var _national_placeholder: PanelContainer = null
var _city_placeholder: PanelContainer = null
var _inspector_title_label: Label = null
var _last_scope := "__unset__"


func _ready() -> void:
	_world_map = get_node_or_null("../ProductionWorldMap")
	set_process(true)


func _process(_delta: float) -> void:
	if not is_instance_valid(_world_map):
		_world_map = get_node_or_null("../ProductionWorldMap")
	if _world_map == null:
		return

	var overlay := _world_map.get_node_or_null("WorldMapUI/tech_tree_overlay_mvp") as PanelContainer
	if overlay == null:
		return

	_ensure_overlay_canvas(overlay)
	if not overlay.visible:
		return

	_ensure_split_detail(overlay)
	_sync_detail_side()


func _ensure_overlay_canvas(overlay: Control) -> void:
	if not is_instance_valid(_overlay_canvas):
		_overlay_canvas = CanvasLayer.new()
		_overlay_canvas.name = "TechTreeOverlayCanvasW23D"
		_overlay_canvas.layer = TECH_TREE_OVERLAY_LAYER
		get_parent().add_child(_overlay_canvas)

	if overlay.get_parent() != _overlay_canvas:
		overlay.reparent(_overlay_canvas, true)


func _ensure_split_detail(overlay: Control) -> void:
	if is_instance_valid(_refined_inspector) and not _refined_inspector.is_queued_for_deletion():
		return

	var inspector := overlay.find_child("DomesticTechDetailInspectorMVP", true, false) as PanelContainer
	if inspector == null or inspector.is_queued_for_deletion():
		return
	var original_parent := inspector.get_parent() as Container
	if original_parent == null:
		return

	var original_index := inspector.get_index()
	var split := HBoxContainer.new()
	split.name = "DomesticTechDetailSplitW23D"
	split.custom_minimum_size = Vector2(0.0, DETAIL_PANEL_MIN_HEIGHT)
	split.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	split.add_theme_constant_override("separation", 10)

	original_parent.remove_child(inspector)
	original_parent.add_child(split)
	original_parent.move_child(split, original_index)

	inspector.custom_minimum_size = Vector2(0.0, DETAIL_PANEL_MIN_HEIGHT)
	inspector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inspector.size_flags_stretch_ratio = 1.0
	split.add_child(inspector)

	var national_placeholder := _make_placeholder_panel("NationalTechDetailPlaceholderW23D", "국가 테크 상세 정보", inspector)
	var city_placeholder := _make_placeholder_panel("CityTechDetailPlaceholderW23D", "도시 테크 상세 정보", inspector)
	split.add_child(national_placeholder)
	split.add_child(city_placeholder)

	_refined_inspector = inspector
	_detail_split = split
	_national_placeholder = national_placeholder
	_city_placeholder = city_placeholder
	_inspector_title_label = _find_inspector_title_label(inspector)
	_last_scope = "__unset__"


func _make_placeholder_panel(node_name: String, title_text: String, style_source: PanelContainer) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.name = node_name
	panel.custom_minimum_size = Vector2(0.0, DETAIL_PANEL_MIN_HEIGHT)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_stretch_ratio = 1.0
	panel.mouse_filter = Control.MOUSE_FILTER_PASS

	var source_style := style_source.get_theme_stylebox("panel")
	if source_style != null:
		panel.add_theme_stylebox_override("panel", source_style.duplicate() as StyleBox)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)

	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 6)
	margin.add_child(content)

	var title := Label.new()
	title.text = title_text
	title.add_theme_font_size_override("font_size", 15)
	title.add_theme_color_override("font_color", Color(1.0, 0.86, 0.54, 1.0))
	content.add_child(title)

	var center := CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(center)

	var watermark := TextureRect.new()
	watermark.name = "TechDetailWatermarkW23D"
	watermark.texture = TECH_DETAIL_WATERMARK
	watermark.custom_minimum_size = TECH_DETAIL_WATERMARK_SIZE
	watermark.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	watermark.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	watermark.modulate = Color(1.0, 1.0, 1.0, TECH_DETAIL_WATERMARK_ALPHA)
	watermark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(watermark)
	return panel


func _find_inspector_title_label(inspector: Node) -> Label:
	for child in inspector.find_children("*", "Label", true, false):
		var label := child as Label
		if label != null and label.text == "선택 테크 상세 정보":
			return label
	return null


func _get_selected_scope() -> String:
	if _world_map == null:
		return ""
	var tech_id := str(_world_map.get("_selected_domestic_tech_id_mvp"))
	if tech_id.is_empty():
		return ""
	var city_id := str(_world_map.get("_selected_domestic_tech_city_id_mvp"))
	return "city" if not city_id.is_empty() else "national"


func _sync_detail_side() -> void:
	if not is_instance_valid(_refined_inspector) or not is_instance_valid(_detail_split):
		return
	if not is_instance_valid(_national_placeholder) or not is_instance_valid(_city_placeholder):
		return

	var scope := _get_selected_scope()
	if scope == _last_scope:
		return
	_last_scope = scope

	match scope:
		"national":
			_refined_inspector.visible = true
			_national_placeholder.visible = false
			_city_placeholder.visible = true
			if is_instance_valid(_inspector_title_label):
				_inspector_title_label.text = "국가 테크 상세 정보"
			_detail_split.move_child(_refined_inspector, 0)
			_detail_split.move_child(_city_placeholder, 1)
		"city":
			_refined_inspector.visible = true
			_national_placeholder.visible = true
			_city_placeholder.visible = false
			if is_instance_valid(_inspector_title_label):
				_inspector_title_label.text = "도시 테크 상세 정보"
			_detail_split.move_child(_national_placeholder, 0)
			_detail_split.move_child(_refined_inspector, 1)
		_:
			_refined_inspector.visible = false
			_national_placeholder.visible = true
			_city_placeholder.visible = true
			_detail_split.move_child(_national_placeholder, 0)
			_detail_split.move_child(_city_placeholder, 1)
