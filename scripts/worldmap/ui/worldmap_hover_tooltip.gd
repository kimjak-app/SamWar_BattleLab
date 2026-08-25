extends PanelContainer

const CURSOR_OFFSET := Vector2(18.0, 18.0)
const VIEWPORT_MARGIN := 16.0
const FADE_IN_SEC := 0.12
const TOOLTIP_WIDTH := 330.0
const SAFE_Z_INDEX := 4090

@onready var title_label: Label = $Margin/VBox/TitleLabel
@onready var body_label: Label = $Margin/VBox/BodyLabel

var _fade_tween: Tween = null


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_as_relative = false
	z_index = SAFE_Z_INDEX
	modulate.a = 0.0


func show_help(title: String, body: String) -> void:
	title_label.text = title
	body_label.text = body
	visible = true
	modulate.a = 0.0
	_fit_to_content()
	call_deferred("_fit_and_place")
	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()
	_fade_tween = create_tween()
	_fade_tween.tween_property(self, "modulate:a", 1.0, FADE_IN_SEC)


func hide_help() -> void:
	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()
	visible = false
	modulate.a = 0.0


func _fit_and_place() -> void:
	if not visible:
		return
	_fit_to_content()
	_place_near_cursor()


func _fit_to_content() -> void:
	# The tooltip is intentionally fixed-width and content-height. Resetting the
	# root prevents a previous viewport-sized Control rect from being reused.
	custom_minimum_size = Vector2(TOOLTIP_WIDTH, 0.0)
	title_label.reset_size()
	body_label.reset_size()
	reset_size()
	var minimum := get_combined_minimum_size()
	size = Vector2(TOOLTIP_WIDTH, minimum.y)


func _place_near_cursor() -> void:
	var viewport := get_viewport()
	if viewport == null:
		return
	var viewport_size := viewport.get_visible_rect().size
	var desired := viewport.get_mouse_position() + CURSOR_OFFSET
	var panel_size := Vector2(TOOLTIP_WIDTH, get_combined_minimum_size().y)
	position = Vector2(
		clampf(desired.x, VIEWPORT_MARGIN, maxf(VIEWPORT_MARGIN, viewport_size.x - panel_size.x - VIEWPORT_MARGIN)),
		clampf(desired.y, VIEWPORT_MARGIN, maxf(VIEWPORT_MARGIN, viewport_size.y - panel_size.y - VIEWPORT_MARGIN))
	)
