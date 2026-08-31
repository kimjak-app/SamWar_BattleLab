extends Node

const BUTTON_SIZE := Vector2(112.0, 34.0)
const BUTTON_TOP := 14.0

@onready var production_world_map: Node = get_node_or_null("../ProductionWorldMap")

var _canvas_layer: CanvasLayer = null
var _button: Button = null


func _ready() -> void:
	call_deferred("_install")


func _install() -> void:
	if production_world_map == null:
		push_warning("WorldMap TechTree Test Button: ProductionWorldMap is missing.")
		return

	_canvas_layer = CanvasLayer.new()
	_canvas_layer.name = "TechTreeTestCanvas"
	_canvas_layer.layer = 40
	add_child(_canvas_layer)

	_button = Button.new()
	_button.name = "TechTreeTestButton"
	_button.text = "테크트리"
	_button.focus_mode = Control.FOCUS_NONE
	_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_button.custom_minimum_size = BUTTON_SIZE
	_button.anchor_left = 0.5
	_button.anchor_right = 0.5
	_button.anchor_top = 0.0
	_button.anchor_bottom = 0.0
	_button.offset_left = -BUTTON_SIZE.x * 0.5
	_button.offset_right = BUTTON_SIZE.x * 0.5
	_button.offset_top = BUTTON_TOP
	_button.offset_bottom = BUTTON_TOP + BUTTON_SIZE.y
	_button.add_theme_font_size_override("font_size", 14)
	_button.add_theme_color_override("font_color", Color(0.98, 0.90, 0.70, 1.0))
	_button.add_theme_color_override("font_hover_color", Color(1.0, 0.96, 0.82, 1.0))
	_button.add_theme_color_override("font_pressed_color", Color(1.0, 0.96, 0.82, 1.0))
	_button.add_theme_stylebox_override("normal", _make_style(Color(0.025, 0.045, 0.070, 0.88), Color(0.78, 0.60, 0.30, 0.78)))
	_button.add_theme_stylebox_override("hover", _make_style(Color(0.045, 0.070, 0.105, 0.94), Color(0.96, 0.78, 0.42, 0.95)))
	_button.add_theme_stylebox_override("pressed", _make_style(Color(0.070, 0.085, 0.105, 0.96), Color(1.0, 0.84, 0.48, 1.0)))
	_button.pressed.connect(_on_button_pressed)
	_canvas_layer.add_child(_button)


func _make_style(bg: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	style.content_margin_left = 12.0
	style.content_margin_right = 12.0
	style.content_margin_top = 6.0
	style.content_margin_bottom = 6.0
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.28)
	style.shadow_size = 5
	style.shadow_offset = Vector2(0.0, 2.0)
	return style


func _on_button_pressed() -> void:
	if production_world_map == null or not is_instance_valid(production_world_map):
		return
	if not production_world_map.has_method("_open_domestic_tech_tree_overlay_mvp"):
		push_warning("WorldMap TechTree Test Button: production tech tree opener is missing.")
		return
	production_world_map.call("_open_domestic_tech_tree_overlay_mvp")
