extends Control

const FADE_IN_SEC := 0.18
const HOLD_SEC := 3.4
const FADE_OUT_SEC := 0.18
const SAFE_Z_INDEX := 4080

@onready var popup_panel: PanelContainer = $PopupPanel
@onready var portrait: TextureRect = $PopupPanel/Margin/Row/PortraitFrame/Portrait
@onready var portrait_fallback: Label = $PopupPanel/Margin/Row/PortraitFrame/PortraitFallback
@onready var role_label: Label = $PopupPanel/Margin/Row/TextColumn/RoleLabel
@onready var name_label: Label = $PopupPanel/Margin/Row/TextColumn/NameLabel
@onready var speech_label: Label = $PopupPanel/Margin/Row/TextColumn/SpeechLabel

var _serial := 0
var _tween: Tween = null


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	popup_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_as_relative = false
	z_index = SAFE_Z_INDEX
	modulate.a = 0.0


func show_character(texture: Texture2D, fallback_text: String, role_text: String, character_name: String, speech: String) -> void:
	_serial += 1
	var current_serial := _serial
	if _tween != null and _tween.is_valid():
		_tween.kill()

	portrait.texture = texture
	portrait.visible = texture != null
	portrait_fallback.text = fallback_text if not fallback_text.is_empty() else "?"
	portrait_fallback.visible = texture == null
	role_label.text = role_text
	name_label.text = character_name
	speech_label.text = speech
	visible = true
	modulate.a = 0.0

	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 1.0, FADE_IN_SEC)
	_tween.tween_interval(HOLD_SEC)
	_tween.tween_property(self, "modulate:a", 0.0, FADE_OUT_SEC)
	_tween.finished.connect(func():
		if current_serial == _serial:
			visible = false
	)


func hide_character() -> void:
	_serial += 1
	if _tween != null and _tween.is_valid():
		_tween.kill()
	visible = false
	modulate.a = 0.0
