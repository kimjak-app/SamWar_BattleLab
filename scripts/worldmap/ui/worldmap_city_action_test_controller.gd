extends Node

signal action_video_test_requested(action_type: String, target_city_id: String)

const CITY_LAYER_PATH := "WorldMapRoot/CityLayer"
const LEGACY_ATTACK_BUTTON_PATH := "WorldMapUI/CityInfoPanel/MarginContainer/Content/ButtonRow/AttackButtonPlaceholder"
const ACTION_BUTTON_SIZE := Vector2(58.0, 30.0)
const MENU_VERTICAL_OFFSET := 54.0
const SCREEN_MARGIN := 8.0

@onready var production_world_map: Node = get_node_or_null("../ProductionWorldMap")

var _canvas_layer: CanvasLayer = null
var _panel: PanelContainer = null
var _spy_button: Button = null
var _diplomacy_button: Button = null
var _trade_button: Button = null
var _battle_button: Button = null
var _selected_marker: Node2D = null


func _ready() -> void:
	set_process(false)
	call_deferred("_install")


func _install() -> void:
	if production_world_map == null:
		push_warning("WorldMap City Action Test: ProductionWorldMap is missing.")
		return

	var city_layer := production_world_map.get_node_or_null(CITY_LAYER_PATH)
	if city_layer == null:
		push_warning("WorldMap City Action Test: CityLayer is missing.")
		return

	_build_action_menu()
	var callback := Callable(self, "_on_city_selected")
	for child in city_layer.get_children():
		if not child.has_signal("city_selected"):
			continue
		if not child.is_connected("city_selected", callback):
			child.connect("city_selected", callback)


func _build_action_menu() -> void:
	_canvas_layer = CanvasLayer.new()
	_canvas_layer.name = "CityActionTestCanvas"
	_canvas_layer.layer = 35
	add_child(_canvas_layer)

	_panel = PanelContainer.new()
	_panel.name = "CityActionTestPanel"
	_panel.visible = false
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_panel.add_theme_stylebox_override("panel", _make_panel_style())
	_canvas_layer.add_child(_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 5)
	margin.add_theme_constant_override("margin_top", 5)
	margin.add_theme_constant_override("margin_right", 5)
	margin.add_theme_constant_override("margin_bottom", 5)
	_panel.add_child(margin)

	var row := HBoxContainer.new()
	row.name = "ActionRow"
	row.add_theme_constant_override("separation", 4)
	margin.add_child(row)

	_spy_button = _make_action_button("첩보", true)
	_spy_button.pressed.connect(_on_contextual_action_pressed.bind("spy"))
	row.add_child(_spy_button)
	_diplomacy_button = _make_action_button("외교", true)
	_diplomacy_button.pressed.connect(_on_contextual_action_pressed.bind("diplomacy"))
	row.add_child(_diplomacy_button)
	_trade_button = _make_action_button("무역", true)
	_trade_button.pressed.connect(_on_contextual_action_pressed.bind("trade"))
	row.add_child(_trade_button)
	_battle_button = _make_action_button("전투", true)
	_battle_button.pressed.connect(_on_battle_pressed)
	row.add_child(_battle_button)


func _make_action_button(label_text: String, enabled: bool) -> Button:
	var button := Button.new()
	button.text = label_text
	button.custom_minimum_size = ACTION_BUTTON_SIZE
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.disabled = not enabled
	button.add_theme_font_size_override("font_size", 13)
	button.add_theme_color_override("font_color", Color(0.97, 0.89, 0.71, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.96, 0.84, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(1.0, 0.96, 0.84, 1.0))
	button.add_theme_color_override("font_disabled_color", Color(0.66, 0.64, 0.60, 0.56))
	button.add_theme_stylebox_override("normal", _make_button_style(Color(0.035, 0.052, 0.070, 0.92), Color(0.68, 0.54, 0.31, 0.72)))
	button.add_theme_stylebox_override("hover", _make_button_style(Color(0.060, 0.080, 0.105, 0.97), Color(0.96, 0.78, 0.42, 0.95)))
	button.add_theme_stylebox_override("pressed", _make_button_style(Color(0.095, 0.070, 0.045, 0.98), Color(1.0, 0.84, 0.48, 1.0)))
	button.add_theme_stylebox_override("disabled", _make_button_style(Color(0.025, 0.035, 0.045, 0.76), Color(0.42, 0.39, 0.34, 0.42)))
	return button


func _make_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.015, 0.025, 0.038, 0.90)
	style.border_color = Color(0.74, 0.60, 0.35, 0.55)
	style.set_border_width_all(1)
	style.set_corner_radius_all(7)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.32)
	style.shadow_size = 6
	style.shadow_offset = Vector2(0.0, 3.0)
	return style


func _make_button_style(bg: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(5)
	return style


func _on_city_selected(marker: Node) -> void:
	if production_world_map != null and production_world_map.has_method("cancel_contextual_worldmap_action"):
		production_world_map.call("cancel_contextual_worldmap_action")
	if marker == null or not marker is Node2D:
		_hide_menu()
		return

	_selected_marker = marker as Node2D
	var owner_faction_id := str(marker.get("owner_faction_id"))
	if owner_faction_id.is_empty() or owner_faction_id == _get_player_faction_id():
		_hide_menu()
		return

	if _panel == null:
		return
	_panel.visible = true
	_sync_battle_button_state()
	_layout_menu()
	set_process(true)
	call_deferred("_sync_battle_button_state")


func _get_player_faction_id() -> String:
	var session := get_node_or_null("/root/GameSession")
	if session != null:
		var faction_value = session.get("player_faction_id")
		if faction_value != null:
			var faction_id := str(faction_value)
			if not faction_id.is_empty():
				return faction_id
	return "player"


func _process(_delta: float) -> void:
	if _panel == null or not _panel.visible or _selected_marker == null or not is_instance_valid(_selected_marker):
		set_process(false)
		return
	_layout_menu()


func _layout_menu() -> void:
	if _panel == null or _selected_marker == null or not is_instance_valid(_selected_marker):
		return
	var viewport := get_viewport()
	if viewport == null:
		return

	var viewport_size := viewport.get_visible_rect().size
	var screen_position := _selected_marker.get_global_transform_with_canvas().origin
	var minimum := _panel.get_combined_minimum_size()
	if minimum.x <= 0.0 or minimum.y <= 0.0:
		minimum = Vector2(258.0, 40.0)
	_panel.size = minimum

	var x := screen_position.x - minimum.x * 0.5
	var y := screen_position.y - minimum.y - MENU_VERTICAL_OFFSET
	x = clampf(x, SCREEN_MARGIN, maxf(SCREEN_MARGIN, viewport_size.x - minimum.x - SCREEN_MARGIN))
	y = clampf(y, SCREEN_MARGIN, maxf(SCREEN_MARGIN, viewport_size.y - minimum.y - SCREEN_MARGIN))
	_panel.position = Vector2(x, y)


func _sync_battle_button_state() -> void:
	if _battle_button == null or production_world_map == null:
		return
	var legacy_attack_button := production_world_map.get_node_or_null(LEGACY_ATTACK_BUTTON_PATH) as Button
	if legacy_attack_button == null:
		_battle_button.disabled = true
		_battle_button.tooltip_text = "기존 공격 버튼을 찾을 수 없습니다."
		return
	_battle_button.disabled = legacy_attack_button.disabled
	_battle_button.tooltip_text = legacy_attack_button.tooltip_text


func _on_battle_pressed() -> void:
	if production_world_map == null:
		return
	var legacy_attack_button := production_world_map.get_node_or_null(LEGACY_ATTACK_BUTTON_PATH) as Button
	if legacy_attack_button == null:
		return
	_sync_battle_button_state()
	if _battle_button == null or _battle_button.disabled:
		return
	legacy_attack_button.emit_signal("pressed")
	_hide_menu()


func _on_contextual_action_pressed(action_type: String) -> void:
	if production_world_map == null or _selected_marker == null:
		return
	var target_city_id := str(_selected_marker.get("city_id"))
	if target_city_id.is_empty():
		return
	action_video_test_requested.emit(action_type, target_city_id)
	_hide_menu()


func _hide_menu() -> void:
	_selected_marker = null
	if _panel != null:
		_panel.visible = false
	set_process(false)
