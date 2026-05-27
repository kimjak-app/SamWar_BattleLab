@tool
extends Node2D
class_name WorldMapCityNameLabel

@export var text: String = "":
	set(value):
		text = value
		queue_redraw()

@export var font_size: int = 16:
	set(value):
		font_size = value
		queue_redraw()

@export var text_color: Color = Color(1.0, 1.0, 1.0, 1.0):
	set(value):
		text_color = value
		queue_redraw()


func set_label_text(value: String) -> void:
	text = value


func _draw() -> void:
	if text.is_empty():
		return

	var font := ThemeDB.fallback_font
	if font == null:
		return

	var text_size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size)
	var baseline := Vector2(-text_size.x * 0.5, text_size.y)
	draw_string(font, baseline, text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size, text_color)
