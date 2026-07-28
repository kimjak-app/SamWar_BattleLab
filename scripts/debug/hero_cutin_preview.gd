extends Control

## Standalone presentation lab only. This never calls battle flow or modifies hero data.
const HERO_ID := "gwanggaeto"
const FALLBACK_SKILL_NAME := "영락대제"

@export_group("Timing (1.8-2.2 seconds at 1.0x)")
@export var dim_duration := 0.16
@export var enter_duration := 0.30
@export var hold_duration := 1.18
@export var exit_duration := 0.30
@export var loop_delay := 0.35
@export_group("Stage tuning")
@export_range(0.0, 1.0, 0.01) var dim_alpha := 0.84
@export_range(0.0, 1.0, 0.01) var flash_alpha := 0.58
@export var foreground_rest_position := Vector2(70, -38)
@export var background_rest_position := Vector2.ZERO
@export var foreground_enter_offset := Vector2(-130, 20)
@export var burst_position := Vector2(390, 24)
@export var burst_size := Vector2(580, 580)

@onready var dim_overlay: ColorRect = $CutinStage/DimOverlay
@onready var background_image: TextureRect = $CutinStage/BackgroundImage
@onready var radial_burst: TextureRect = $CutinStage/RadialBurst
@onready var speed_line_root: Control = $CutinStage/SpeedLineRoot
@onready var speed_line_top: ColorRect = $CutinStage/SpeedLineRoot/SpeedLineTop
@onready var speed_line_bottom: ColorRect = $CutinStage/SpeedLineRoot/SpeedLineBottom
@onready var foreground_hero: TextureRect = $CutinStage/ForegroundHero
@onready var hero_name_panel: Panel = $CutinStage/HeroNamePanel
@onready var skill_name_panel: Panel = $CutinStage/SkillNamePanel
@onready var skill_name: Label = $CutinStage/SkillNamePanel/SkillName
@onready var flash_overlay: ColorRect = $CutinStage/FlashOverlay
@onready var foreground_mode_button: Button = $PreviewControlPanel/Rows/ModeRow/ForegroundModeButton
@onready var background_mode_button: Button = $PreviewControlPanel/Rows/ModeRow/BackgroundModeButton
@onready var loop_toggle: CheckButton = $PreviewControlPanel/Rows/SettingsRow/LoopToggle
@onready var subtle_button: Button = $PreviewControlPanel/Rows/SettingsRow/SubtleButton
@onready var default_button: Button = $PreviewControlPanel/Rows/SettingsRow/DefaultButton
@onready var intense_button: Button = $PreviewControlPanel/Rows/SettingsRow/IntenseButton
@onready var speed_075_button: Button = $PreviewControlPanel/Rows/SettingsRow/Speed075Button
@onready var speed_100_button: Button = $PreviewControlPanel/Rows/SettingsRow/Speed100Button
@onready var speed_125_button: Button = $PreviewControlPanel/Rows/SettingsRow/Speed125Button
@onready var play_button: Button = $PreviewControlPanel/Rows/ModeRow/PlayButton
@onready var replay_button: Button = $PreviewControlPanel/Rows/ModeRow/ReplayButton

var _mode_foreground := true
var _strength := 1.0
var _playback_speed := 1.0
var _active_tween: Tween
var _loop_timer: SceneTreeTimer

func _ready() -> void:
	foreground_mode_button.pressed.connect(func() -> void: _set_mode(true))
	background_mode_button.pressed.connect(func() -> void: _set_mode(false))
	play_button.pressed.connect(play_cutin)
	replay_button.pressed.connect(play_cutin)
	subtle_button.pressed.connect(func() -> void: _set_strength(0.62))
	default_button.pressed.connect(func() -> void: _set_strength(1.0))
	intense_button.pressed.connect(func() -> void: _set_strength(1.42))
	speed_075_button.pressed.connect(func() -> void: _set_speed(0.75))
	speed_100_button.pressed.connect(func() -> void: _set_speed(1.0))
	speed_125_button.pressed.connect(func() -> void: _set_speed(1.25))
	_update_skill_name()
	_reset_stage()

func _exit_tree() -> void:
	_stop_active_playback()

func _set_mode(use_foreground: bool) -> void:
	_mode_foreground = use_foreground
	foreground_mode_button.button_pressed = use_foreground
	background_mode_button.button_pressed = not use_foreground
	_reset_stage()

func _set_strength(value: float) -> void:
	_strength = value
	subtle_button.button_pressed = is_equal_approx(value, 0.62)
	default_button.button_pressed = is_equal_approx(value, 1.0)
	intense_button.button_pressed = is_equal_approx(value, 1.42)

func _set_speed(value: float) -> void:
	_playback_speed = value
	speed_075_button.button_pressed = is_equal_approx(value, 0.75)
	speed_100_button.button_pressed = is_equal_approx(value, 1.0)
	speed_125_button.button_pressed = is_equal_approx(value, 1.25)

func _update_skill_name() -> void:
	var canonical_skill := HeroDesignDataRegistry.get_unique_skill_for_hero(HERO_ID)
	skill_name.text = String(canonical_skill.get("display_name", FALLBACK_SKILL_NAME))

func play_cutin() -> void:
	_stop_active_playback()
	_reset_stage()
	var speed := maxf(_playback_speed, 0.01)
	var dim_time := dim_duration / speed
	var enter_time := enter_duration / speed
	var hold_time := hold_duration / speed
	var exit_time := exit_duration / speed
	_active_tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	_active_tween.tween_property(dim_overlay, "color:a", dim_alpha, dim_time)
	if _mode_foreground:
		_play_foreground_sequence(enter_time, hold_time, exit_time)
	else:
		_play_background_sequence(enter_time, hold_time, exit_time)
	_active_tween.tween_callback(_finish_playback)

func _play_foreground_sequence(enter_time: float, hold_time: float, exit_time: float) -> void:
	foreground_hero.visible = true
	background_image.visible = false
	foreground_hero.position = foreground_rest_position + foreground_enter_offset
	foreground_hero.modulate.a = 0.0
	foreground_hero.scale = Vector2(0.92, 0.92)
	_active_tween.parallel().tween_property(foreground_hero, "position", foreground_rest_position, enter_time)
	_active_tween.parallel().tween_property(foreground_hero, "modulate:a", 1.0, enter_time * 0.72)
	_active_tween.parallel().tween_property(foreground_hero, "scale", Vector2.ONE, enter_time)
	_play_effects(enter_time, hold_time)
	_active_tween.tween_interval(hold_time)
	_play_flash()
	_active_tween.parallel().tween_property(foreground_hero, "modulate:a", 0.0, exit_time)
	_active_tween.parallel().tween_property(foreground_hero, "position", foreground_rest_position + Vector2(70, -15), exit_time)
	_play_exit_effects(exit_time)

func _play_background_sequence(enter_time: float, hold_time: float, exit_time: float) -> void:
	foreground_hero.visible = false
	background_image.visible = true
	background_image.position = background_rest_position + Vector2(-18, 0)
	background_image.scale = Vector2(1.06, 1.06)
	background_image.modulate.a = 0.0
	_active_tween.parallel().tween_property(background_image, "modulate:a", 1.0, enter_time)
	_active_tween.parallel().tween_property(background_image, "position", background_rest_position, enter_time + hold_time)
	_active_tween.parallel().tween_property(background_image, "scale", Vector2.ONE, enter_time + hold_time)
	_play_effects(enter_time, hold_time, 0.42)
	_active_tween.tween_interval(hold_time)
	_play_flash()
	_active_tween.parallel().tween_property(background_image, "modulate:a", 0.0, exit_time)
	_play_exit_effects(exit_time)

func _play_effects(enter_time: float, hold_time: float, effect_multiplier: float = 1.0) -> void:
	var burst_alpha := minf(0.74, 0.48 * _strength * effect_multiplier)
	radial_burst.position = burst_position
	radial_burst.size = burst_size * (0.82 + 0.18 * _strength)
	_active_tween.parallel().tween_property(radial_burst, "modulate:a", burst_alpha, enter_time * 0.45)
	_active_tween.parallel().tween_property(radial_burst, "scale", Vector2.ONE * (1.0 + 0.18 * _strength), enter_time + hold_time)
	_active_tween.parallel().tween_property(hero_name_panel, "modulate:a", 1.0, enter_time * 0.7)
	_active_tween.parallel().tween_property(skill_name_panel, "modulate:a", 1.0, enter_time * 0.7)
	_active_tween.parallel().tween_property(speed_line_top, "color:a", 0.58 * _strength * effect_multiplier, enter_time * 0.4)
	_active_tween.parallel().tween_property(speed_line_bottom, "color:a", 0.44 * _strength * effect_multiplier, enter_time * 0.4)

func _play_flash() -> void:
	_active_tween.parallel().tween_property(flash_overlay, "color:a", minf(0.78, flash_alpha * _strength), 0.06 / _playback_speed)
	_active_tween.parallel().tween_property(radial_burst, "modulate:a", radial_burst.modulate.a * 0.42, 0.10 / _playback_speed)
	_active_tween.tween_property(flash_overlay, "color:a", 0.0, 0.12 / _playback_speed)

func _play_exit_effects(exit_time: float) -> void:
	_active_tween.parallel().tween_property(radial_burst, "modulate:a", 0.0, exit_time)
	_active_tween.parallel().tween_property(speed_line_top, "color:a", 0.0, exit_time)
	_active_tween.parallel().tween_property(speed_line_bottom, "color:a", 0.0, exit_time)
	_active_tween.parallel().tween_property(hero_name_panel, "modulate:a", 0.0, exit_time)
	_active_tween.parallel().tween_property(skill_name_panel, "modulate:a", 0.0, exit_time)

func _finish_playback() -> void:
	_reset_stage()
	if loop_toggle.button_pressed:
		_loop_timer = get_tree().create_timer(loop_delay / maxf(_playback_speed, 0.01))
		_loop_timer.timeout.connect(func() -> void:
			if is_inside_tree() and loop_toggle.button_pressed:
				play_cutin()
		)

func _stop_active_playback() -> void:
	if is_instance_valid(_active_tween):
		_active_tween.kill()
	_active_tween = null
	_loop_timer = null

func _reset_stage() -> void:
	dim_overlay.color.a = 0.0
	foreground_hero.position = foreground_rest_position
	foreground_hero.scale = Vector2.ONE
	foreground_hero.modulate.a = 0.0
	background_image.position = background_rest_position
	background_image.scale = Vector2.ONE
	background_image.modulate.a = 0.0
	background_image.visible = not _mode_foreground
	foreground_hero.visible = _mode_foreground
	radial_burst.position = burst_position
	radial_burst.size = burst_size
	radial_burst.scale = Vector2.ONE
	radial_burst.modulate.a = 0.0
	speed_line_top.color.a = 0.0
	speed_line_bottom.color.a = 0.0
	hero_name_panel.modulate.a = 0.0
	skill_name_panel.modulate.a = 0.0
	flash_overlay.color.a = 0.0
