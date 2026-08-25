extends PanelContainer

const CURSOR_OFFSET := Vector2(18.0, 18.0)
const VIEWPORT_MARGIN := 16.0
const FADE_IN_SEC := 0.12

@onready var title_label: Label = $Margin/VBox/TitleLabel
@onready var body_label: Label = $Margin/VBox/BodyLabel

var _fade_tween: Tween = null


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 9000
	modulate.a = 0.0


func show_help(title: String, body: String) -> void:
	title_label.text = title
	body_label.text = body
	visible = true
	modulate.a = 0.0
	call_deferred("_place_near_cursor")
	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()
	_fade_tween = create_tween()
	_fade_tween.tween_property(self, "modulate:a", 1.0, FADE_IN_SEC)


func hide_help() -> void:
	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()
	visible = false
	modulate.a = 0.0


func _place_near_cursor() -> void:
	var viewport := get_viewport()
	if viewport == null:
		return
	var viewport_size := viewport.get_visible_rect().size
	var desired := viewport.get_mouse_position() + CURSOR_OFFSET
	var panel_size := get_combined_minimum_size()
	if size.x > 0.0 and size.y > 0.0:
		panel_size = size
	position = Vector2(
		clampf(desired.x, VIEWPORT_MARGIN, maxf(VIEWPORT_MARGIN, viewport_size.x - panel_size.x - VIEWPORT_MARGIN)),
		clampf(desired.y, VIEWPORT_MARGIN, maxf(VIEWPORT_MARGIN, viewport_size.y - panel_size.y - VIEWPORT_MARGIN))
	)
