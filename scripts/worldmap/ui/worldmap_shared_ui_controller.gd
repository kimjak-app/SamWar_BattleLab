class_name WorldMapSharedUiController
extends Node


signal draggable_panel_clicked(panel: Control)

const DRAG_THRESHOLD := 6.0

var _owner: Node = null
var _ui_root: CanvasLayer = null
var _dragging_panel: Control = null
var _dragging_pointer_offset := Vector2.ZERO
var _click_candidate := false
var _drag_started := false
var _click_start_position := Vector2.ZERO
var _click_enabled_panels := {}
var _help_modal: PanelContainer = null
var _help_title_label: Label = null
var _help_body_label: Label = null


func configure(owner_node: Node, ui_root: CanvasLayer) -> void:
	_owner = owner_node
	_ui_root = ui_root


func register_draggable_panel(panel: Control, handles: Array) -> void:
	if panel == null:
		return
	for handle in handles:
		var handle_control := handle as Control
		if handle_control == null:
			continue
		handle_control.mouse_filter = Control.MOUSE_FILTER_STOP
		var callback := Callable(self, "_on_drag_handle_gui_input").bind(panel, handle_control)
		if not handle_control.gui_input.is_connected(callback):
			handle_control.gui_input.connect(callback)


func set_panel_click_enabled(panel: Control, enabled: bool) -> void:
	if panel == null:
		return
	if enabled:
		_click_enabled_panels[panel.get_instance_id()] = true
	else:
		_click_enabled_panels.erase(panel.get_instance_id())


func handle_input(event: InputEvent) -> bool:
	if _dragging_panel == null:
		return false
	if event is InputEventMouseMotion:
		var mouse_motion_event := event as InputEventMouseMotion
		if _click_candidate and not _drag_started:
			if mouse_motion_event.global_position.distance_to(_click_start_position) < DRAG_THRESHOLD:
				return true
			_drag_started = true
		move_panel_to_screen_position(_dragging_panel, mouse_motion_event.global_position - _dragging_pointer_offset)
		return true
	if event is InputEventMouseButton:
		var mouse_button_event := event as InputEventMouseButton
		if mouse_button_event.button_index == MOUSE_BUTTON_LEFT and not mouse_button_event.pressed:
			var clicked_panel := _dragging_panel
			var should_emit_click := _click_candidate and not _drag_started
			_dragging_panel = null
			_click_candidate = false
			_drag_started = false
			if should_emit_click:
				draggable_panel_clicked.emit(clicked_panel)
			return true
	return false


func lock_screen_panel_top_margin(panel: Control, top_margin: float) -> void:
	if panel == null:
		return
	var current_size := panel.size
	panel.set_anchors_preset(Control.PRESET_TOP_LEFT, true)
	panel.position = Vector2(panel.position.x, top_margin)
	if current_size != Vector2.ZERO:
		panel.size = current_size


func lock_right_panel_anchor(panel: Control, panel_size: Vector2, left_margin: float, top_margin: float) -> void:
	if panel == null:
		return
	var viewport_size := _get_viewport_size()
	var resolved_size := panel.size if panel.size != Vector2.ZERO else panel_size
	panel.set_anchors_preset(Control.PRESET_TOP_LEFT, true)
	var requested_position := Vector2(maxf(left_margin, viewport_size.x - left_margin - resolved_size.x), top_margin)
	if not request_panel_position(panel, requested_position):
		panel.position = requested_position
	panel.size = resolved_size
	panel.custom_minimum_size = resolved_size


func move_panel_to_screen_position(panel: Control, next_global_position: Vector2) -> void:
	if panel == null:
		return
	var viewport_size := _get_viewport_size()
	var min_visible_size := Vector2(72.0, 42.0)
	var panel_size := panel.size if panel.size.x > 0.0 and panel.size.y > 0.0 else panel.get_rect().size
	var clamped_position := Vector2(
		clampf(next_global_position.x, -panel_size.x + min_visible_size.x, viewport_size.x - min_visible_size.x),
		clampf(next_global_position.y, 0.0, viewport_size.y - min_visible_size.y)
	)
	if not request_panel_position(panel, clamped_position, true):
		panel.global_position = clamped_position


func request_panel_position(panel: Control, requested_position: Vector2, is_global: bool = false) -> bool:
	if panel == null or _owner == null:
		return false
	var position_owner := _owner.get_node_or_null("HudPositionOwner")
	if position_owner == null:
		return false
	var method_name := "request_hud_panel_global_position" if is_global else "request_hud_panel_position"
	if not position_owner.has_method(method_name):
		return false
	return bool(position_owner.call(method_name, panel, requested_position))


func ensure_help_modal() -> PanelContainer:
	if _help_modal != null:
		return _help_modal
	if _ui_root == null:
		return null
	_help_modal = PanelContainer.new()
	_help_modal.name = "WorldMapHelpModal"
	_help_modal.visible = false
	_help_modal.z_index = 120
	_help_modal.anchor_left = 0.5
	_help_modal.anchor_right = 0.5
	_help_modal.offset_left = -190.0
	_help_modal.offset_right = 190.0
	_help_modal.offset_top = 72.0
	_help_modal.offset_bottom = 292.0
	_help_modal.custom_minimum_size = Vector2(380.0, 220.0)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.055, 0.065, 0.075, 0.97)
	panel_style.border_color = Color(0.82, 0.72, 0.48, 0.86)
	panel_style.set_border_width_all(1)
	panel_style.set_corner_radius_all(4)
	panel_style.content_margin_left = 12.0
	panel_style.content_margin_top = 10.0
	panel_style.content_margin_right = 12.0
	panel_style.content_margin_bottom = 10.0
	_help_modal.add_theme_stylebox_override("panel", panel_style)
	_ui_root.add_child(_help_modal)
	var content := VBoxContainer.new()
	content.name = "Content"
	content.add_theme_constant_override("separation", 8)
	_help_modal.add_child(content)
	_help_title_label = Label.new()
	_help_title_label.name = "TitleLabel"
	_help_title_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.58, 1.0))
	_help_title_label.add_theme_font_size_override("font_size", 15)
	content.add_child(_help_title_label)
	_help_body_label = Label.new()
	_help_body_label.name = "BodyLabel"
	_help_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_help_body_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_help_body_label.add_theme_color_override("font_color", Color(0.93, 0.92, 0.84, 1.0))
	_help_body_label.add_theme_font_size_override("font_size", 12)
	content.add_child(_help_body_label)
	var action_row := HBoxContainer.new()
	action_row.alignment = BoxContainer.ALIGNMENT_END
	content.add_child(action_row)
	var close_button := Button.new()
	close_button.name = "CloseButton"
	close_button.text = "닫기"
	close_button.custom_minimum_size = Vector2(70.0, 24.0)
	close_button.focus_mode = Control.FOCUS_NONE
	close_button.add_theme_font_size_override("font_size", 11)
	action_row.add_child(close_button)
	close_button.pressed.connect(hide_help_modal)
	return _help_modal


func show_help_modal(content: Dictionary) -> void:
	var modal := ensure_help_modal()
	if modal == null:
		return
	_help_title_label.text = str(content.get("title", "도움말"))
	_help_body_label.text = str(content.get("body", "도움말 정보가 없습니다."))
	modal.visible = true
	modal.move_to_front()


func hide_help_modal() -> void:
	if _help_modal != null:
		_help_modal.visible = false


func is_help_modal_visible() -> bool:
	return _help_modal != null and _help_modal.visible


func get_help_modal() -> PanelContainer:
	return _help_modal


func _on_drag_handle_gui_input(event: InputEvent, panel: Control, handle: Control) -> void:
	if not event is InputEventMouseButton:
		return
	var mouse_button_event := event as InputEventMouseButton
	if mouse_button_event.button_index != MOUSE_BUTTON_LEFT or not mouse_button_event.pressed:
		return
	_dragging_panel = panel
	_dragging_pointer_offset = mouse_button_event.global_position - panel.global_position
	_click_candidate = bool(_click_enabled_panels.get(panel.get_instance_id(), false))
	_drag_started = false
	_click_start_position = mouse_button_event.global_position
	panel.move_to_front()
	handle.accept_event()


func _get_viewport_size() -> Vector2:
	if _owner != null:
		return _owner.get_viewport().get_visible_rect().size
	return get_viewport().get_visible_rect().size
