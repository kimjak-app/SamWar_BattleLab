extends Node

const TECH_DETAIL_WATERMARK := preload("res://assets/ui/worldmap/tech_tree/wm_techtree_detail_watermark.png")
const TECH_TREE_OVERLAY_LAYER := 60
const TECH_DETAIL_WATERMARK_ALPHA := 0.25
const TECH_DETAIL_WATERMARK_SIZE := Vector2(240.0, 240.0)
const TREE_REGION_RATIO := 0.42
const BODY_GAP := 10.0

var _world_map: Node = null
var _overlay_canvas: CanvasLayer = null
var _body_viewport: Control = null
var _tree_viewport: Control = null
var _tree_split: HBoxContainer = null
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

	var overlay: PanelContainer = null
	if is_instance_valid(_overlay_canvas):
		overlay = _overlay_canvas.get_node_or_null("tech_tree_overlay_mvp") as PanelContainer
	if overlay == null:
		overlay = _world_map.get_node_or_null("WorldMapUI/tech_tree_overlay_mvp") as PanelContainer
	if overlay == null:
		return

	_ensure_overlay_canvas(overlay)
	if not overlay.visible:
		return

	_ensure_bounded_body_layout(overlay)
	_sync_detail_side()


func _ensure_overlay_canvas(overlay: Control) -> void:
	if not is_instance_valid(_overlay_canvas):
		_overlay_canvas = CanvasLayer.new()
		_overlay_canvas.name = "TechTreeOverlayCanvasW23D"
		_overlay_canvas.layer = TECH_TREE_OVERLAY_LAYER
		get_parent().add_child(_overlay_canvas)

	if overlay.get_parent() != _overlay_canvas:
		overlay.reparent(_overlay_canvas, true)


func _ensure_bounded_body_layout(overlay: Control) -> void:
	if is_instance_valid(_body_viewport) and not _body_viewport.is_queued_for_deletion():
		return

	_reset_layout_refs()

	var content_root := overlay.find_child("DomesticTechTreeOverlayContent", true, false) as VBoxContainer
	if content_root == null or content_root.is_queued_for_deletion():
		return

	var tree_split := _find_direct_child(content_root, "DomesticTechTreeSplit") as HBoxContainer
	var inspector := _find_direct_child(content_root, "DomesticTechDetailInspectorMVP") as PanelContainer
	if tree_split == null or inspector == null:
		return
	if tree_split.is_queued_for_deletion() or inspector.is_queued_for_deletion():
		return

	var insert_index := mini(tree_split.get_index(), inspector.get_index())
	content_root.remove_child(tree_split)
	content_root.remove_child(inspector)

	var body := Control.new()
	body.name = "DomesticTechBoundedBodyW23E"
	body.custom_minimum_size = Vector2.ZERO
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.clip_contents = true
	body.mouse_filter = Control.MOUSE_FILTER_PASS
	content_root.add_child(body)
	content_root.move_child(body, mini(insert_index, content_root.get_child_count() - 1))

	var tree_viewport := Control.new()
	tree_viewport.name = "DomesticTechTreeViewportW23E"
	tree_viewport.custom_minimum_size = Vector2.ZERO
	tree_viewport.anchor_left = 0.0
	tree_viewport.anchor_top = 0.0
	tree_viewport.anchor_right = 1.0
	tree_viewport.anchor_bottom = TREE_REGION_RATIO
	tree_viewport.offset_left = 0.0
	tree_viewport.offset_top = 0.0
	tree_viewport.offset_right = 0.0
	tree_viewport.offset_bottom = -BODY_GAP * 0.5
	tree_viewport.clip_contents = true
	tree_viewport.mouse_filter = Control.MOUSE_FILTER_PASS
	body.add_child(tree_viewport)

	tree_viewport.add_child(tree_split)
	_configure_tree_split(tree_split)

	var detail_split := HBoxContainer.new()
	detail_split.name = "DomesticTechDetailSplitW23E"
	detail_split.custom_minimum_size = Vector2.ZERO
	detail_split.add_theme_constant_override("separation", 10)
	body.add_child(detail_split)
	_configure_detail_region(detail_split)

	inspector.custom_minimum_size = Vector2.ZERO
	inspector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inspector.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inspector.size_flags_stretch_ratio = 1.0
	detail_split.add_child(inspector)

	var national_placeholder := _make_placeholder_panel(
		"NationalTechDetailPlaceholderW23E",
		"국가 테크 상세 정보",
		inspector
	)
	var city_placeholder := _make_placeholder_panel(
		"CityTechDetailPlaceholderW23E",
		"도시 테크 상세 정보",
		inspector
	)
	detail_split.add_child(national_placeholder)
	detail_split.add_child(city_placeholder)

	_body_viewport = body
	_tree_viewport = tree_viewport
	_tree_split = tree_split
	_refined_inspector = inspector
	_detail_split = detail_split
	_national_placeholder = national_placeholder
	_city_placeholder = city_placeholder
	_inspector_title_label = _find_inspector_title_label(inspector)
	_last_scope = "__unset__"


func _configure_tree_split(tree_split: HBoxContainer) -> void:
	tree_split.custom_minimum_size = Vector2.ZERO
	tree_split.anchor_left = 0.0
	tree_split.anchor_top = 0.0
	tree_split.anchor_right = 1.0
	tree_split.anchor_bottom = 1.0
	tree_split.offset_left = 0.0
	tree_split.offset_top = 0.0
	tree_split.offset_right = 0.0
	tree_split.offset_bottom = 0.0
	tree_split.clip_contents = true

	for child in tree_split.get_children():
		var panel := child as Control
		if panel != null:
			panel.custom_minimum_size = Vector2.ZERO
			panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			panel.size_flags_vertical = Control.SIZE_EXPAND_FILL

	for node in tree_split.find_children("DomesticTechScroll", "ScrollContainer", true, false):
		var scroll := node as ScrollContainer
		if scroll == null:
			continue
		scroll.custom_minimum_size = Vector2.ZERO
		scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
		scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
		scroll.clip_contents = true


func _configure_detail_region(detail_split: HBoxContainer) -> void:
	detail_split.anchor_left = 0.0
	detail_split.anchor_top = TREE_REGION_RATIO
	detail_split.anchor_right = 1.0
	detail_split.anchor_bottom = 1.0
	detail_split.offset_left = 0.0
	detail_split.offset_top = BODY_GAP * 0.5
	detail_split.offset_right = 0.0
	detail_split.offset_bottom = 0.0
	detail_split.clip_contents = true


func _find_direct_child(parent: Node, node_name: String) -> Node:
	for child in parent.get_children():
		if child.name == node_name and not child.is_queued_for_deletion():
			return child
	return null


func _reset_layout_refs() -> void:
	_body_viewport = null
	_tree_viewport = null
	_tree_split = null
	_refined_inspector = null
	_detail_split = null
	_national_placeholder = null
	_city_placeholder = null
	_inspector_title_label = null
	_last_scope = "__unset__"


func _make_placeholder_panel(node_name: String, title_text: String, style_source: PanelContainer) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.name = node_name
	panel.custom_minimum_size = Vector2.ZERO
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
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
	watermark.name = "TechDetailWatermarkW23E"
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
