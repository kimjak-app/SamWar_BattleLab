extends Node

# W2-3H: single runtime position owner for the 16:9 QA HUD.
# Default geometry is requested by the test host/main; only this node applies it.

const LEFT_PANEL_PATH := "WorldMapUI/LeftWorldStatusPanel"
const RIGHT_PANEL_PATH := "WorldMapUI/CityInfoPanel"
const FALLBACK_LEFT_POSITION := Vector2(32.0, 56.0)
const FALLBACK_RIGHT_MARGIN := 32.0
const EDGE_PADDING := 8.0

@onready var production_world_map: Node = get_parent()

var _left_panel: Control = null
var _right_panel: Control = null
var _left_has_user_position := false
var _right_has_user_position := false
var _left_user_position := Vector2.ZERO
var _right_user_position := Vector2.ZERO
var _installed := false


func _ready() -> void:
	# This node is a ProductionWorldMap child in the QA scene, so it is ready
	# before the parent main script requests its initial HUD placement.
	process_priority = 1600
	_install()
	set_process(_installed)


func _process(_delta: float) -> void:
	if not _installed:
		return
	_apply_owned_positions()


func _install() -> void:
	if production_world_map == null:
		push_warning("WorldMap HUD Position Owner: ProductionWorldMap is missing.")
		return
	_left_panel = production_world_map.get_node_or_null(LEFT_PANEL_PATH) as Control
	_right_panel = production_world_map.get_node_or_null(RIGHT_PANEL_PATH) as Control
	if _left_panel == null or _right_panel == null:
		push_warning("WorldMap HUD Position Owner: required HUD panels are missing.")
		return
	_set_top_left_anchors(_left_panel)
	_set_top_left_anchors(_right_panel)
	var viewport := get_viewport()
	if viewport != null and not viewport.size_changed.is_connected(_on_viewport_size_changed):
		viewport.size_changed.connect(_on_viewport_size_changed)
	_installed = true
	_apply_owned_positions()


func request_hud_panel_position(panel: Control, requested_position: Vector2) -> bool:
	if not _installed or panel == null:
		return false
	# Default-layout requests must never overwrite a confirmed user position.
	if panel == _left_panel and not _left_has_user_position:
		_apply_panel_position(panel, requested_position)
	elif panel == _right_panel and not _right_has_user_position:
		_apply_panel_position(panel, requested_position)
	return panel == _left_panel or panel == _right_panel


func request_hud_panel_global_position(panel: Control, requested_global_position: Vector2) -> bool:
	if not _installed or panel == null:
		return false
	if panel == _left_panel:
		_left_has_user_position = true
		_left_user_position = _clamp_position(panel, requested_global_position)
		_apply_panel_position(panel, _left_user_position)
	elif panel == _right_panel:
		_right_has_user_position = true
		_right_user_position = _clamp_position(panel, requested_global_position)
		_apply_panel_position(panel, _right_user_position)
	return panel == _left_panel or panel == _right_panel


func request_default_hud_layout() -> void:
	if not _installed:
		return
	_apply_owned_positions()


func _apply_owned_positions() -> void:
	if _left_panel != null and is_instance_valid(_left_panel):
		_set_top_left_anchors(_left_panel)
		if _left_has_user_position:
			_left_user_position = _clamp_position(_left_panel, _left_user_position)
			_apply_panel_position(_left_panel, _left_user_position)
		else:
			_apply_panel_position(_left_panel, _get_default_position(_left_panel, true))
	if _right_panel != null and is_instance_valid(_right_panel):
		_set_top_left_anchors(_right_panel)
		if _right_has_user_position:
			_right_user_position = _clamp_position(_right_panel, _right_user_position)
			_apply_panel_position(_right_panel, _right_user_position)
		else:
			_apply_panel_position(_right_panel, _get_default_position(_right_panel, false))


func _get_default_position(panel: Control, is_left: bool) -> Vector2:
	var test_host := production_world_map.get_parent()
	if test_host != null and test_host.has_method("get_hud_default_position"):
		return test_host.call("get_hud_default_position", panel, is_left)
	if is_left:
		return FALLBACK_LEFT_POSITION
	var viewport := get_viewport()
	if viewport == null:
		return Vector2(FALLBACK_RIGHT_MARGIN, FALLBACK_LEFT_POSITION.y)
	return Vector2(maxf(EDGE_PADDING, viewport.get_visible_rect().size.x - FALLBACK_RIGHT_MARGIN - panel.size.x), FALLBACK_LEFT_POSITION.y)


func _clamp_position(panel: Control, value: Vector2) -> Vector2:
	var viewport := get_viewport()
	if viewport == null:
		return value
	var viewport_size := viewport.get_visible_rect().size
	return Vector2(
		clampf(value.x, EDGE_PADDING, maxf(EDGE_PADDING, viewport_size.x - panel.size.x - EDGE_PADDING)),
		clampf(value.y, EDGE_PADDING, maxf(EDGE_PADDING, viewport_size.y - panel.size.y - EDGE_PADDING))
	)


func _apply_panel_position(panel: Control, value: Vector2) -> void:
	# The sole direct .position writer for these two QA HUD panels.
	panel.position = value


func _on_viewport_size_changed() -> void:
	_apply_owned_positions()


func _set_top_left_anchors(control: Control) -> void:
	control.anchor_left = 0.0
	control.anchor_top = 0.0
	control.anchor_right = 0.0
	control.anchor_bottom = 0.0
