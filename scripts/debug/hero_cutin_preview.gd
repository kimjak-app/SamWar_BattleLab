extends Control

## Standalone presentation lab only. This never calls battle flow or modifies hero data.
signal cutin_finished

const HERO_ID := "gwanggaeto"
const FALLBACK_SKILL_NAME := "영락대제"

@export_group("Duel-style Mode A timing (about 1.95 seconds at 1.0x)")
@export var ignite_duration := 0.12
@export var hero_delay := 0.06
@export var hero_enter_duration := 0.30
@export var title_burst_duration := 0.19
@export var standoff_duration := 0.82
@export var flash_duration := 0.16
@export var exit_duration := 0.30
@export var loop_delay := 0.35
@export_group("Mode A scene-authored composition")
@export var hero_rest_position := Vector2(28, -34)
@export var hero_enter_offset := Vector2(185, 16)
@export var hero_rest_scale := 1.055
@export var hero_standoff_scale := 1.085
@export var title_rest_scale := Vector2.ONE
@export var title_burst_scale := Vector2(1.38, 1.38)
@export var title_start_scale := Vector2(0.20, 0.20)
@export var title_rest_position := Vector2(42, 224)
@export var title_exit_offset := Vector2(-72, 0)
@export var flash_alpha := 0.62

@onready var cutin_root: Control = $CutinRoot
@onready var dim_overlay: ColorRect = $CutinRoot/DimOverlay
@onready var background_image: TextureRect = $CutinRoot/BackgroundImage
@onready var back_light_burst: TextureRect = $CutinRoot/BackLightBurst
@onready var back_light_burst_near: TextureRect = $CutinRoot/BackLightBurstNear
@onready var back_light_burst_far: TextureRect = $CutinRoot/BackLightBurstFar
@onready var hero_portrait: TextureRect = $CutinRoot/HeroContainer/HeroPortrait
@onready var title_container: Control = $CutinRoot/TitleContainer
@onready var title_hero_name: Label = $CutinRoot/TitleContainer/HeroNameLabel
@onready var title_skill_name: Label = $CutinRoot/TitleContainer/SkillNameLabel
@onready var accent_line: ColorRect = $CutinRoot/TitleContainer/AccentLine
@onready var flash_overlay: ColorRect = $CutinRoot/FlashOverlay
@onready var control_panel: Panel = $PreviewControlPanel
@onready var foreground_mode_button: Button = $PreviewControlPanel/Rows/ModeRow/ForegroundModeButton
@onready var background_mode_button: Button = $PreviewControlPanel/Rows/ModeRow/BackgroundModeButton
@onready var loop_toggle: CheckButton = $PreviewControlPanel/Rows/SettingsRow/LoopToggle
@onready var strength_label: Label = $PreviewControlPanel/Rows/SettingsRow/StrengthLabel
@onready var subtle_button: Button = $PreviewControlPanel/Rows/SettingsRow/SubtleButton
@onready var default_button: Button = $PreviewControlPanel/Rows/SettingsRow/DefaultButton
@onready var intense_button: Button = $PreviewControlPanel/Rows/SettingsRow/IntenseButton
@onready var speed_075_button: Button = $PreviewControlPanel/Rows/SettingsRow/Speed075Button
@onready var speed_100_button: Button = $PreviewControlPanel/Rows/SettingsRow/Speed100Button
@onready var speed_125_button: Button = $PreviewControlPanel/Rows/SettingsRow/Speed125Button
@onready var play_button: Button = $PreviewControlPanel/Rows/ModeRow/PlayButton
@onready var replay_button: Button = $PreviewControlPanel/Rows/ModeRow/ReplayButton

var _mode_foreground := true
var _playback_speed := 1.0
var _active_tweens: Array[Tween] = []
var _loop_timer: SceneTreeTimer
var _playing := false
var _cutin_root_base_position := Vector2.ZERO
var _effect_nodes: Array[ColorRect] = []
var _effect_base_positions: Dictionary = {}
var _shake_tween: Tween

func _ready() -> void:
	_effect_nodes = [$CutinRoot/ImpactLines/SpeedLineTop, $CutinRoot/ImpactLines/SpeedLineBottom, $CutinRoot/ImpactLines/SpeedLineMid, $CutinRoot/ImpactLines/SpeedLineFar, $CutinRoot/BurstParticles/EmberA, $CutinRoot/BurstParticles/EmberB, $CutinRoot/BurstParticles/EmberC, $CutinRoot/BurstParticles/DustA, $CutinRoot/BurstParticles/DustB]
	for effect_node in _effect_nodes:
		_effect_base_positions[effect_node.get_path()] = effect_node.position
	_cutin_root_base_position = cutin_root.position
	foreground_mode_button.pressed.connect(func() -> void: _set_mode(true))
	background_mode_button.pressed.connect(func() -> void: _set_mode(false))
	play_button.pressed.connect(play_cutin)
	replay_button.pressed.connect(play_cutin)
	speed_075_button.pressed.connect(func() -> void: _set_speed(0.75))
	speed_100_button.pressed.connect(func() -> void: _set_speed(1.0))
	speed_125_button.pressed.connect(func() -> void: _set_speed(1.25))
	strength_label.hide()
	subtle_button.hide()
	default_button.hide()
	intense_button.hide()
	_update_skill_name()
	_reset_visual_state()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_pressed() and event.keycode == KEY_ESCAPE:
		_stop_active_playback()
		_reset_visual_state()

func _exit_tree() -> void:
	_stop_active_playback()

func _set_mode(use_foreground: bool) -> void:
	_stop_active_playback()
	_mode_foreground = use_foreground
	foreground_mode_button.button_pressed = use_foreground
	background_mode_button.button_pressed = not use_foreground
	_reset_visual_state()

func _set_speed(value: float) -> void:
	_playback_speed = value
	speed_075_button.button_pressed = is_equal_approx(value, 0.75)
	speed_100_button.button_pressed = is_equal_approx(value, 1.0)
	speed_125_button.button_pressed = is_equal_approx(value, 1.25)

func _update_skill_name() -> void:
	var canonical_skill := HeroDesignDataRegistry.get_unique_skill_for_hero(HERO_ID)
	title_skill_name.text = String(canonical_skill.get("display_name", FALLBACK_SKILL_NAME))

func play_cutin() -> void:
	_stop_active_playback()
	_reset_visual_state()
	_playing = true
	control_panel.hide()
	if _mode_foreground:
		_play_duel_style_foreground()
	else:
		_play_preserved_background()

func _play_duel_style_foreground() -> void:
	var speed := maxf(_playback_speed, 0.01)
	var timeline := _new_tween()
	# Phase 1: immediate black-red ignition and backlight pressure.
	timeline.parallel().tween_property(dim_overlay, "color:a", 0.72, ignite_duration / speed)
	timeline.parallel().tween_property(back_light_burst, "modulate:a", 0.78, ignite_duration / speed)
	timeline.parallel().tween_property(back_light_burst_near, "modulate:a", 0.52, ignite_duration / speed)
	timeline.parallel().tween_property(back_light_burst_far, "modulate:a", 0.30, ignite_duration / speed)
	timeline.parallel().tween_property(back_light_burst, "scale", Vector2(1.22, 1.22), ignite_duration / speed)
	timeline.tween_interval(maxf(0.0, hero_delay - ignite_duration) / speed)
	# Phase 2: the portrait drives in hard from the right and settles with a back ease.
	timeline.parallel().tween_property(hero_portrait, "position", hero_rest_position, hero_enter_duration / speed).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	timeline.parallel().tween_property(hero_portrait, "scale", Vector2.ONE * hero_rest_scale, hero_enter_duration / speed).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	timeline.parallel().tween_property(hero_portrait, "modulate:a", 1.0, hero_enter_duration * 0.72 / speed)
	timeline.parallel().tween_property(back_light_burst_near, "scale", Vector2(1.34, 1.34), hero_enter_duration / speed)
	timeline.parallel().tween_callback(func() -> void: _impact_shake(7.5 / speed, 0.18 / speed))
	# Phase 3: title explosion. The title is intentionally the focal impact, not a subtitle.
	timeline.parallel().tween_property(title_container, "modulate:a", 1.0, 0.045 / speed)
	timeline.parallel().tween_property(title_container, "scale", title_burst_scale, title_burst_duration * 0.55 / speed).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	timeline.parallel().tween_property(accent_line, "color:a", 1.0, 0.10 / speed)
	_emit_title_burst(timeline, speed)
	timeline.tween_property(title_container, "scale", title_rest_scale, title_burst_duration * 0.45 / speed).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	timeline.parallel().tween_callback(func() -> void: _impact_shake(9.0 / speed, 0.22 / speed))
	# Phase 4: readable standoff with a restrained push-in.
	timeline.parallel().tween_property(hero_portrait, "scale", Vector2.ONE * hero_standoff_scale, standoff_duration / speed)
	timeline.parallel().tween_property(back_light_burst_far, "scale", Vector2(1.18, 1.18), standoff_duration / speed)
	timeline.parallel().tween_property(back_light_burst, "rotation", 0.06, standoff_duration / speed)
	_emit_standoff_embers(timeline, speed)
	timeline.tween_interval(standoff_duration / speed)
	# Phase 5: short white-gold decision flash, never an opaque yellow plate.
	timeline.parallel().tween_property(flash_overlay, "color:a", flash_alpha, 0.045 / speed)
	timeline.parallel().tween_property(back_light_burst_near, "modulate:a", 0.82, 0.045 / speed)
	timeline.tween_callback(func() -> void: _impact_shake(5.0 / speed, 0.12 / speed))
	timeline.tween_property(flash_overlay, "color:a", 0.0, (flash_duration - 0.045) / speed)
	# Phase 6: title exits left, portrait exits forward/right, then fully reset.
	timeline.parallel().tween_property(title_container, "position", title_rest_position + title_exit_offset, exit_duration / speed).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	timeline.parallel().tween_property(title_container, "modulate:a", 0.0, exit_duration * 0.82 / speed)
	timeline.parallel().tween_property(hero_portrait, "position", hero_rest_position + Vector2(96, -10), exit_duration / speed)
	timeline.parallel().tween_property(hero_portrait, "scale", Vector2.ONE * 1.14, exit_duration / speed)
	timeline.parallel().tween_property(hero_portrait, "modulate:a", 0.0, exit_duration / speed)
	_fade_environment(timeline, exit_duration / speed)
	timeline.tween_callback(_finish_playback)

func _play_preserved_background() -> void:
	var speed := maxf(_playback_speed, 0.01)
	background_image.visible = true
	var timeline := _new_tween()
	timeline.parallel().tween_property(dim_overlay, "color:a", 0.68, 0.12 / speed)
	timeline.parallel().tween_property(background_image, "modulate:a", 1.0, 0.25 / speed)
	timeline.parallel().tween_property(background_image, "position", Vector2.ZERO, 1.35 / speed)
	timeline.parallel().tween_property(background_image, "scale", Vector2(1.015, 1.015), 1.35 / speed)
	timeline.tween_interval(1.35 / speed)
	timeline.parallel().tween_property(flash_overlay, "color:a", 0.38, 0.05 / speed)
	timeline.tween_property(flash_overlay, "color:a", 0.0, 0.10 / speed)
	timeline.parallel().tween_property(background_image, "modulate:a", 0.0, exit_duration / speed)
	timeline.parallel().tween_property(dim_overlay, "color:a", 0.0, exit_duration / speed)
	timeline.tween_callback(_finish_playback)

func _emit_title_burst(timeline: Tween, speed: float) -> void:
	for index in range(7):
		var node := _effect_nodes[index]
		var base: Vector2 = _effect_base_positions[node.get_path()]
		node.position = Vector2(360 + index * 22, 302 + (index % 3) * 18)
		timeline.parallel().tween_property(node, "color:a", 0.9 if index >= 4 else 0.68, 0.04 / speed)
		timeline.parallel().tween_property(node, "position", base + Vector2((index - 3) * 115, -95 - (index % 3) * 52), 0.28 / speed)
		timeline.parallel().tween_property(node, "color:a", 0.0, 0.30 / speed).set_delay(0.13 / speed)

func _emit_standoff_embers(timeline: Tween, speed: float) -> void:
	for index in range(7, _effect_nodes.size()):
		var node := _effect_nodes[index]
		var base: Vector2 = _effect_base_positions[node.get_path()]
		timeline.parallel().tween_property(node, "color:a", 0.42, 0.16 / speed)
		timeline.parallel().tween_property(node, "position", base + Vector2(-24 + index * 12, -76), 0.62 / speed)
		timeline.parallel().tween_property(node, "color:a", 0.0, 0.24 / speed).set_delay(0.52 / speed)

func _fade_environment(timeline: Tween, duration: float) -> void:
	for burst in [back_light_burst, back_light_burst_near, back_light_burst_far]:
		timeline.parallel().tween_property(burst, "modulate:a", 0.0, duration)
	for effect_node in _effect_nodes:
		timeline.parallel().tween_property(effect_node, "color:a", 0.0, duration * 0.65)
	timeline.parallel().tween_property(dim_overlay, "color:a", 0.0, duration)

func _impact_shake(strength: float, duration: float) -> void:
	if is_instance_valid(_shake_tween):
		_shake_tween.kill()
	cutin_root.position = _cutin_root_base_position
	_shake_tween = create_tween()
	var half_duration := duration * 0.5
	_shake_tween.tween_property(cutin_root, "position", _cutin_root_base_position + Vector2(strength, -strength * 0.45), half_duration * 0.25)
	_shake_tween.tween_property(cutin_root, "position", _cutin_root_base_position + Vector2(-strength * 0.7, strength * 0.35), half_duration * 0.35)
	_shake_tween.tween_property(cutin_root, "position", _cutin_root_base_position, half_duration * 1.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _new_tween() -> Tween:
	var timeline := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_active_tweens.append(timeline)
	return timeline

func _finish_playback() -> void:
	_playing = false
	_reset_visual_state()
	cutin_finished.emit()
	if loop_toggle.button_pressed:
		_loop_timer = get_tree().create_timer(loop_delay / maxf(_playback_speed, 0.01))
		_loop_timer.timeout.connect(func() -> void:
			if is_inside_tree() and loop_toggle.button_pressed and not _playing:
				play_cutin())

func _stop_active_playback() -> void:
	for timeline in _active_tweens:
		if is_instance_valid(timeline):
			timeline.kill()
	_active_tweens.clear()
	if is_instance_valid(_shake_tween):
		_shake_tween.kill()
	_shake_tween = null
	_loop_timer = null
	_playing = false

func _reset_visual_state() -> void:
	cutin_root.position = _cutin_root_base_position
	dim_overlay.color.a = 0.0
	hero_portrait.position = hero_rest_position
	hero_portrait.scale = Vector2.ONE
	hero_portrait.modulate.a = 0.0
	background_image.position = Vector2(-28, 8)
	background_image.scale = Vector2(1.085, 1.085)
	background_image.modulate.a = 0.0
	background_image.visible = not _mode_foreground
	for burst in [back_light_burst, back_light_burst_near, back_light_burst_far]:
		burst.scale = Vector2.ONE
		burst.rotation = 0.0
		burst.modulate.a = 0.0
	title_container.position = title_rest_position
	title_container.scale = title_start_scale if _mode_foreground else title_rest_scale
	title_container.modulate.a = 0.0
	accent_line.color.a = 0.0
	for effect_node in _effect_nodes:
		effect_node.position = _effect_base_positions.get(effect_node.get_path(), Vector2.ZERO)
		effect_node.color.a = 0.0
	flash_overlay.color.a = 0.0
	control_panel.show()
