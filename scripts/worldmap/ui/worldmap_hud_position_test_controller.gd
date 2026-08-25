extends Node

const LEFT_PANEL_PATH := "WorldMapUI/LeftWorldStatusPanel"
const RIGHT_PANEL_PATH := "WorldMapUI/CityInfoPanel"
const LEFT_MARGIN := 32.0
const RIGHT_MARGIN := 32.0
const TOP_MARGIN := 56.0
const POSITION_EPSILON := 0.75
const EDGE_PADDING := 8.0

@onready var production_world_map: Node = get_node_or_null("../ProductionWorldMap")

var _left_panel: Control = null
var _right_panel: Control = null
var _right_user_moved := false
var _right_user_position := Vector2.ZERO
var _right_pointer_down := false
var _right_press_position := Vector2.ZERO
var _installed := false


func _ready() -> void:
	# Run after the presentation/refinement controllers so the fixed-left contract
	# wins in the same frame without modifying production WorldMap code.
	process_priority = 1600
	set_process(true)
	set_process_input(true)
	call_deferred("_install")


func _process(_delta: float) -> void:
	if not _installed:
		return
	_enforce_left_position()
	_preserve_right_position()


func _input(event: InputEvent) -> void:
	if not _installed or _right_panel == null or not is_instance_valid(_right_panel):
		return
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index != MOUSE_BUTTON_LEFT:
			return
		if mouse_event.pressed:
			_right_pointer_down = _right_panel.get_global_rect().has_point(mouse_event.position)
			if _right_pointer_down:
				_right_press_position = _right_panel.position
		else:
			_right_pointer_down = false


func _install() -> void:
	if production_world_map == null:
		push_warning("WorldMap HUD Position: ProductionWorldMap is missing.")
		return
	_left_panel = production_world_map.get_node_or_null(LEFT_PANEL_PATH) as Control
	_right_panel = production_world_map.get_node_or_null(RIGHT_PANEL_PATH) as Control
	if _left_panel == null or _right_panel == null:
		push_warning("WorldMap HUD Position: left/right panel is missing.")
		return

	_set_top_left_anchors(_left_panel)
	_set_top_left_anchors(_right_panel)
	_enforce_left_position()
	_right_panel.position = _get_right_default_position()
	_right_press_position = _right_panel.position

	var viewport := get_viewport()
	if viewport != null and not viewport.size_changed.is_connected(_on_viewport_size_changed):
		viewport.size_changed.connect(_on_viewport_size_changed)
	_installed = true


func _enforce_left_position() -> void:
	if _left_panel == null or not is_instance_valid(_left_panel):
		return
	_set_top_left_anchors(_left_panel)
	_left_panel.position = Vector2(LEFT_MARGIN, TOP_MARGIN)


func _preserve_right_position() -> void:
	if _right_panel == null or not is_instance_valid(_right_panel):
		return
	_set_top_left_anchors(_right_panel)
	var current := _right_panel.position

	if _right_pointer_down:
		# Only a position change that happens while the pointer is actually held on
		# the right HUD counts as a user drag. Deferred host layouts are ignored.
		if current.distance_to(_right_press_position) > POSITION_EPSILON:
			_right_user_moved = true
			_right_user_position = _clamp_right_position(current)
		return

	if _right_user_moved:
		# Outside a verified drag, any position change is a production refresh/layout
		# pass. Restore the user's last dragged position instead of learning that reset.
		_right_panel.position = _clamp_right_position(_right_user_position)
	else:
		_right_panel.position = _get_right_default_position()


func _get_right_default_position() -> Vector2:
	var viewport := get_viewport()
	if viewport == null or _right_panel == null:
		return Vector2(RIGHT_MARGIN, TOP_MARGIN)
	var viewport_size := viewport.get_visible_rect().size
	return Vector2(
		maxf(EDGE_PADDING, viewport_size.x - RIGHT_MARGIN - _right_panel.size.x),
		TOP_MARGIN
	)


func _clamp_right_position(value: Vector2) -> Vector2:
	var viewport := get_viewport()
	if viewport == null or _right_panel == null:
		return value
	var viewport_size := viewport.get_visible_rect().size
	return Vector2(
		clampf(value.x, EDGE_PADDING, maxf(EDGE_PADDING, viewport_size.x - _right_panel.size.x - EDGE_PADDING)),
		clampf(value.y, EDGE_PADDING, maxf(EDGE_PADDING, viewport_size.y - _right_panel.size.y - EDGE_PADDING))
	)


func _on_viewport_size_changed() -> void:
	_enforce_left_position()
	if _right_user_moved:
		_right_user_position = _clamp_right_position(_right_user_position)
		_right_panel.position = _right_user_position
	else:
		_right_panel.position = _get_right_default_position()


func _set_top_left_anchors(control: Control) -> void:
	control.anchor_left = 0.0
	control.anchor_top = 0.0
	control.anchor_right = 0.0
	control.anchor_bottom = 0.0
