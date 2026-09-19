class_name WorldMapHudPresentationController
extends Node

const LEFT_PANEL_PATH := "WorldMapUI/LeftWorldStatusPanel"
const RIGHT_PANEL_PATH := "WorldMapUI/CityInfoPanel"
const LEFT_PANEL_WIDTH := 320.0
const RIGHT_PANEL_WIDTH := 308.0
const HUD_SIDE_MARGIN_RATIO := 0.025
const HUD_TOP_MARGIN_RATIO := 0.144
const HUD_MIN_SIDE_MARGIN := 24.0
const HUD_MIN_TOP_MARGIN := 96.0
const EDGE_PADDING := 8.0

const LEFT_HIDDEN_CHILDREN := [
	"EyebrowLabel",
	"TurnLabel",
	"CalendarLabel",
	"NationLabel",
	"WorldTurnSeparator",
	"SupplyLabel",
	"MilitaryLogisticsLabel",
	"ExternalTradeLabel",
	"SaveButtonRow",
	"WorldStatusHintLabel",
]

const WORLD_UI_ALWAYS_HIDDEN := [
	"WorldTitlePanel",
	"CityDetailPanel",
	"DiplomacySpyPanel",
	"InstructionLabel",
]

@onready var world_map: Node = get_parent()

var _left_panel: PanelContainer = null
var _right_panel: PanelContainer = null
var _left_has_user_position := false
var _right_has_user_position := false
var _left_user_position := Vector2.ZERO
var _right_user_position := Vector2.ZERO
var _installed := false


func _ready() -> void:
	process_priority = 1500
	call_deferred("_install")


func _install() -> void:
	if world_map == null:
		return
	var world_ui := world_map.get_node_or_null("WorldMapUI") as CanvasLayer
	if world_ui == null:
		return
	_left_panel = world_map.get_node_or_null(LEFT_PANEL_PATH) as PanelContainer
	_right_panel = world_map.get_node_or_null(RIGHT_PANEL_PATH) as PanelContainer
	if _left_panel == null or _right_panel == null:
		push_warning("WorldMap HUD Presentation: required HUD panels are missing.")
		return

	var hud_controller := world_map.get_node_or_null("WorldMapHudController")
	if hud_controller == null and world_map.has_method("_ensure_hud_controller"):
		hud_controller = world_map.call("_ensure_hud_controller")
	if hud_controller != null and hud_controller.has_method("set_compact_presentation_enabled"):
		hud_controller.call("set_compact_presentation_enabled", true)
	if _right_panel.has_method("set_compact_presentation_enabled"):
		_right_panel.call("set_compact_presentation_enabled", true)

	world_ui.visible = true
	for node_name in WORLD_UI_ALWAYS_HIDDEN:
		var item := world_ui.get_node_or_null(node_name) as CanvasItem
		if item != null:
			item.visible = false
	var camera_debug := world_ui.get_node_or_null("CameraDebugLabel") as CanvasItem
	if camera_debug != null:
		camera_debug.visible = false
	var legacy_tech_button := world_ui.get_node_or_null("DomesticTechTreeButtonMVP") as CanvasItem
	if legacy_tech_button != null:
		legacy_tech_button.visible = false
	call_deferred("_hide_late_legacy_top_ui")

	_compact_left_panel()
	_compact_right_panel()
	_set_top_left_anchors(_left_panel)
	_set_top_left_anchors(_right_panel)

	var viewport := get_viewport()
	if viewport != null and not viewport.size_changed.is_connected(_on_viewport_size_changed):
		viewport.size_changed.connect(_on_viewport_size_changed)

	var city_layer := world_map.get_node_or_null("WorldMapRoot/CityLayer")
	if city_layer != null:
		var callback := Callable(self, "_on_city_selected")
		for child in city_layer.get_children():
			if child.has_signal("city_selected") and not child.is_connected("city_selected", callback):
				child.connect("city_selected", callback)

	_installed = true
	call_deferred("request_layout_refresh")


func _compact_left_panel() -> void:
	_left_panel.visible = true
	_left_panel.custom_minimum_size = Vector2(LEFT_PANEL_WIDTH, 0.0)
	var content := _left_panel.get_node_or_null("MarginContainer/Content") as VBoxContainer
	if content == null:
		return
	for child_name in LEFT_HIDDEN_CHILDREN:
		var item := content.get_node_or_null(child_name) as CanvasItem
		if item != null:
			item.visible = false
	var turn_end_placeholder := content.get_node_or_null("WildArmyEditButtonPlaceholder") as CanvasItem
	if turn_end_placeholder != null:
		turn_end_placeholder.visible = false


func _compact_right_panel() -> void:
	_right_panel.visible = true
	_right_panel.custom_minimum_size = Vector2(RIGHT_PANEL_WIDTH, 0.0)
	var content := _right_panel.get_node_or_null("MarginContainer/Content") as VBoxContainer
	if content == null:
		return
	var garrison := content.get_node_or_null("GarrisonCard")
	if garrison == null:
		return
	var keep_names := {
		"TechBadgeSection_Right": true,
	}
	var garrison_index := garrison.get_index()
	for child in content.get_children():
		if not child is CanvasItem:
			continue
		if child.get_index() <= garrison_index:
			continue
		if keep_names.has(str(child.name)):
			continue
		(child as CanvasItem).visible = false


func request_hud_panel_global_position(panel: Control, requested_global_position: Vector2) -> bool:
	if not _installed or panel == null:
		return false
	if panel == _left_panel:
		_left_has_user_position = true
		_left_user_position = _clamp_position(panel, requested_global_position)
		panel.position = _left_user_position
		return true
	if panel == _right_panel:
		_right_has_user_position = true
		_right_user_position = _clamp_position(panel, requested_global_position)
		panel.position = _right_user_position
		return true
	return false


func request_hud_panel_position(panel: Control, _requested_position: Vector2) -> bool:
	if not _installed or panel == null:
		return false
	# Production default-layout requests from worldmap_main still carry the legacy
	# 10px-top geometry. This owner intentionally resolves those requests to the
	# accepted 16:9 HUD baseline. Only explicit global drag requests become user positions.
	if panel == _left_panel:
		if not _left_has_user_position:
			panel.position = _clamp_position(panel, _get_default_position(panel, true))
		return true
	if panel == _right_panel:
		if not _right_has_user_position:
			panel.position = _clamp_position(panel, _get_default_position(panel, false))
		return true
	return false


func request_layout_refresh() -> void:
	if not _installed:
		return
	_compact_left_panel()
	_compact_right_panel()
	_fit_panel(_left_panel, LEFT_PANEL_WIDTH)
	_fit_panel(_right_panel, RIGHT_PANEL_WIDTH)
	_apply_positions()


func request_default_hud_layout() -> void:
	request_layout_refresh()


func _fit_panel(panel: PanelContainer, width: float) -> void:
	if panel == null:
		return
	panel.custom_minimum_size = Vector2(width, 0.0)
	var minimum := panel.get_combined_minimum_size()
	panel.size = Vector2(width, minimum.y)


func _apply_positions() -> void:
	if _left_panel != null:
		_set_top_left_anchors(_left_panel)
		var left_position := _left_user_position if _left_has_user_position else _get_default_position(_left_panel, true)
		_left_panel.position = _clamp_position(_left_panel, left_position)
	if _right_panel != null:
		_set_top_left_anchors(_right_panel)
		var right_position := _right_user_position if _right_has_user_position else _get_default_position(_right_panel, false)
		_right_panel.position = _clamp_position(_right_panel, right_position)


func _get_default_position(panel: Control, is_left: bool) -> Vector2:
	var viewport := get_viewport()
	if viewport == null:
		return Vector2(32.0, 96.0)
	var viewport_size := viewport.get_visible_rect().size
	var side_margin := maxf(HUD_MIN_SIDE_MARGIN, viewport_size.x * HUD_SIDE_MARGIN_RATIO)
	var top_margin := maxf(HUD_MIN_TOP_MARGIN, viewport_size.y * HUD_TOP_MARGIN_RATIO)
	if is_left:
		return Vector2(side_margin, top_margin)
	return Vector2(maxf(side_margin, viewport_size.x - side_margin - panel.size.x), top_margin)


func _clamp_position(panel: Control, value: Vector2) -> Vector2:
	var viewport := get_viewport()
	if viewport == null:
		return value
	var viewport_size := viewport.get_visible_rect().size
	return Vector2(
		clampf(value.x, EDGE_PADDING, maxf(EDGE_PADDING, viewport_size.x - panel.size.x - EDGE_PADDING)),
		clampf(value.y, EDGE_PADDING, maxf(EDGE_PADDING, viewport_size.y - panel.size.y - EDGE_PADDING))
	)


func _set_top_left_anchors(control: Control) -> void:
	control.anchor_left = 0.0
	control.anchor_top = 0.0
	control.anchor_right = 0.0
	control.anchor_bottom = 0.0


func _on_city_selected(_marker: Node) -> void:
	call_deferred("request_layout_refresh")


func _on_viewport_size_changed() -> void:
	call_deferred("request_layout_refresh")


func _hide_late_legacy_top_ui() -> void:
	if world_map == null:
		return
	var world_ui := world_map.get_node_or_null("WorldMapUI") as CanvasLayer
	if world_ui == null:
		return
	var camera_debug := world_ui.get_node_or_null("CameraDebugLabel") as CanvasItem
	if camera_debug != null:
		camera_debug.visible = false
	var legacy_tech_button := world_ui.get_node_or_null("DomesticTechTreeButtonMVP") as CanvasItem
	if legacy_tech_button != null:
		legacy_tech_button.visible = false
