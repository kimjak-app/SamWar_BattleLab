extends Control

## Standalone presentation lab only. This never calls battle flow or modifies hero data.
const HERO_ID := "gwanggaeto"
const FALLBACK_SKILL_NAME := "영락대제"

@export_group("Timing (about 2.0 seconds at 1.0x)")
@export var dim_duration := 0.12
@export var enter_duration := 0.30
@export var hold_duration := 1.18
@export var exit_duration := 0.30
@export var loop_delay := 0.35
@export_group("Stage tuning")
@export_range(0.0, 1.0, 0.01) var dim_alpha := 0.78
@export var foreground_rest_position := Vector2(98, -14)
@export var background_rest_position := Vector2.ZERO
@export var foreground_enter_offset := Vector2(-115, 18)
@export var burst_position := Vector2(390, 24)
@export var burst_size := Vector2(580, 580)
@export_group("Presentation strength")
@export var subtle_flash_alpha := 0.26
@export var default_flash_alpha := 0.44
@export var intense_flash_alpha := 0.64
@export var subtle_shake := 2.0
@export var default_shake := 4.0
@export var intense_shake := 7.0

@onready var cutin_stage: Control = $CutinStage
@onready var dim_overlay: ColorRect = $CutinStage/DimOverlay
@onready var background_image: TextureRect = $CutinStage/BackgroundImage
@onready var radial_burst: TextureRect = $CutinStage/RadialBurst
@onready var radial_burst_near: TextureRect = $CutinStage/RadialBurstNear
@onready var radial_burst_far: TextureRect = $CutinStage/RadialBurstFar
@onready var speed_line_root: Control = $CutinStage/SpeedLineRoot
@onready var foreground_hero: TextureRect = $CutinStage/ForegroundHero
@onready var hero_name_panel: Panel = $CutinStage/HeroNamePanel
@onready var skill_name_panel: Panel = $CutinStage/SkillNamePanel
@onready var skill_name: Label = $CutinStage/SkillNamePanel/SkillName
@onready var ember_root: Control = $CutinStage/EmberRoot
@onready var flash_overlay: ColorRect = $CutinStage/FlashOverlay
@onready var control_panel: Panel = $PreviewControlPanel
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
var _playing := false
var _shake_power := 0.0
var _shake_end_msec := 0
var _stage_base_position := Vector2.ZERO
var _particle_nodes: Array[ColorRect] = []
var _speed_lines: Array[ColorRect] = []
var _effect_base_positions: Dictionary = {}

func _ready() -> void:
	_particle_nodes = [$CutinStage/EmberRoot/EmberA, $CutinStage/EmberRoot/EmberB, $CutinStage/EmberRoot/EmberC, $CutinStage/EmberRoot/DustA, $CutinStage/EmberRoot/DustB]
	_speed_lines = [$CutinStage/SpeedLineRoot/SpeedLineTop, $CutinStage/SpeedLineRoot/SpeedLineBottom, $CutinStage/SpeedLineRoot/SpeedLineMid, $CutinStage/SpeedLineRoot/SpeedLineFar]
	for effect_node in _particle_nodes + _speed_lines:
		_effect_base_positions[effect_node.get_path()] = effect_node.position
	_stage_base_position = cutin_stage.position
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

func _process(_delta: float) -> void:
	if _shake_end_msec > Time.get_ticks_msec():
		cutin_stage.position = _stage_base_position + Vector2(randf_range(-_shake_power, _shake_power), randf_range(-_shake_power, _shake_power))
	else:
		cutin_stage.position = _stage_base_position

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_pressed() and event.keycode == KEY_ESCAPE:
		_stop_active_playback()
		_reset_stage()

func _exit_tree() -> void:
	_stop_active_playback()

func _set_mode(use_foreground: bool) -> void:
	_stop_active_playback()
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
	_playing = true
	control_panel.hide()
	var speed := maxf(_playback_speed, 0.01)
	var enter_time := enter_duration / speed
	var hold_time := hold_duration / speed
	var exit_time := exit_duration / speed
	_active_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_active_tween.tween_property(dim_overlay, "color:a", dim_alpha, dim_duration / speed)
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
	foreground_hero.scale = Vector2(0.96, 0.96)
	_active_tween.parallel().tween_property(foreground_hero, "position", foreground_rest_position, enter_time)
	_active_tween.parallel().tween_property(foreground_hero, "modulate:a", 1.0, enter_time * 0.65)
	_active_tween.parallel().tween_property(foreground_hero, "scale", Vector2(1.03, 1.03), enter_time)
	_play_effects(enter_time, hold_time, 1.0)
	_active_tween.tween_property(foreground_hero, "scale", Vector2(1.055, 1.055), hold_time)
	_play_flash()
	_active_tween.parallel().tween_property(foreground_hero, "modulate:a", 0.0, exit_time)
	_active_tween.parallel().tween_property(foreground_hero, "position", foreground_rest_position + Vector2(74, -18), exit_time)
	_play_exit_effects(exit_time)

func _play_background_sequence(enter_time: float, hold_time: float, exit_time: float) -> void:
	foreground_hero.visible = false
	background_image.visible = true
	background_image.position = background_rest_position + Vector2(-28, 8)
	background_image.scale = Vector2(1.085, 1.085)
	background_image.modulate.a = 0.0
	_active_tween.parallel().tween_property(background_image, "modulate:a", 1.0, enter_time * 0.8)
	_active_tween.parallel().tween_property(background_image, "position", background_rest_position, enter_time + hold_time)
	_active_tween.parallel().tween_property(background_image, "scale", Vector2(1.015, 1.015), enter_time + hold_time)
	_play_effects(enter_time, hold_time, 0.38)
	_active_tween.tween_interval(hold_time)
	_play_flash()
	_active_tween.parallel().tween_property(background_image, "modulate:a", 0.0, exit_time)
	_active_tween.parallel().tween_property(background_image, "position", Vector2(24, -6), exit_time)
	_play_exit_effects(exit_time)

func _play_effects(enter_time: float, hold_time: float, effect_multiplier: float) -> void:
	var burst_alpha := minf(0.82, 0.48 * _strength * effect_multiplier)
	radial_burst.position = burst_position
	radial_burst.size = burst_size * (0.86 + 0.14 * _strength)
	_active_tween.parallel().tween_property(radial_burst, "modulate:a", burst_alpha, enter_time * 0.42)
	_active_tween.parallel().tween_property(radial_burst_near, "modulate:a", burst_alpha * 0.64, enter_time * 0.55)
	_active_tween.parallel().tween_property(radial_burst_far, "modulate:a", burst_alpha * 0.34, enter_time * 0.5)
	_active_tween.parallel().tween_property(radial_burst, "scale", Vector2.ONE * (1.08 + 0.16 * _strength), enter_time + hold_time)
	_active_tween.parallel().tween_property(radial_burst_near, "scale", Vector2.ONE * (1.14 + 0.18 * _strength), enter_time + hold_time)
	_active_tween.parallel().tween_property(hero_name_panel, "modulate:a", 1.0, enter_time * 0.72)
	_active_tween.parallel().tween_property(skill_name_panel, "modulate:a", 1.0, enter_time * 0.78)
	for line in _speed_lines:
		_active_tween.parallel().tween_property(line, "color:a", minf(0.72, 0.45 * _strength * effect_multiplier), enter_time * 0.35)
		_active_tween.parallel().tween_property(line, "position:x", float(_effect_base_positions[line.get_path()].x) + 170.0 * _strength, enter_time + hold_time * 0.3)
	for particle in _particle_nodes:
		_active_tween.parallel().tween_property(particle, "color:a", minf(0.9, 0.54 * _strength * effect_multiplier), enter_time * 0.55)
		_active_tween.parallel().tween_property(particle, "position", _effect_base_positions[particle.get_path()] + Vector2(randf_range(-100.0, 110.0), randf_range(-170.0, -45.0)) * _strength, enter_time + hold_time * 0.72)
	_shake_power = _shake_for_strength()
	_shake_end_msec = Time.get_ticks_msec() + int((enter_time * 0.72) * 1000.0)

func _play_flash() -> void:
	var flash_time := 0.055 / _playback_speed
	_active_tween.parallel().tween_property(flash_overlay, "color:a", _flash_for_strength(), flash_time)
	_active_tween.parallel().tween_property(radial_burst_near, "modulate:a", radial_burst_near.modulate.a * 0.55, 0.09 / _playback_speed)
	_active_tween.tween_property(flash_overlay, "color:a", 0.0, 0.10 / _playback_speed)
	_shake_power = _shake_for_strength() * 0.7
	_shake_end_msec = Time.get_ticks_msec() + int(0.13 / _playback_speed * 1000.0)

func _play_exit_effects(exit_time: float) -> void:
	for burst in [radial_burst, radial_burst_near, radial_burst_far]:
		_active_tween.parallel().tween_property(burst, "modulate:a", 0.0, exit_time)
	for line in _speed_lines:
		_active_tween.parallel().tween_property(line, "color:a", 0.0, exit_time)
	for particle in _particle_nodes:
		_active_tween.parallel().tween_property(particle, "color:a", 0.0, exit_time * 0.72)
	_active_tween.parallel().tween_property(hero_name_panel, "modulate:a", 0.0, exit_time)
	_active_tween.parallel().tween_property(skill_name_panel, "modulate:a", 0.0, exit_time)
	_active_tween.parallel().tween_property(dim_overlay, "color:a", 0.0, exit_time)

func _flash_for_strength() -> float:
	if _strength < 0.8:
		return subtle_flash_alpha
	if _strength > 1.2:
		return intense_flash_alpha
	return default_flash_alpha

func _shake_for_strength() -> float:
	if _strength < 0.8:
		return subtle_shake
	if _strength > 1.2:
		return intense_shake
	return default_shake

func _finish_playback() -> void:
	_playing = false
	_reset_stage()
	if loop_toggle.button_pressed:
		_loop_timer = get_tree().create_timer(loop_delay / maxf(_playback_speed, 0.01))
		_loop_timer.timeout.connect(func() -> void:
			if is_inside_tree() and loop_toggle.button_pressed and not _playing:
				play_cutin())

func _stop_active_playback() -> void:
	if is_instance_valid(_active_tween):
		_active_tween.kill()
	_active_tween = null
	_loop_timer = null
	_playing = false
	_shake_end_msec = 0

func _reset_stage() -> void:
	cutin_stage_reset()
	control_panel.show()

func cutin_stage_reset() -> void:
	cutin_stage.position = _stage_base_position
	dim_overlay.color.a = 0.0
	foreground_hero.position = foreground_rest_position
	foreground_hero.scale = Vector2.ONE
	foreground_hero.modulate.a = 0.0
	background_image.position = background_rest_position
	background_image.scale = Vector2.ONE
	background_image.modulate.a = 0.0
	background_image.visible = not _mode_foreground
	foreground_hero.visible = _mode_foreground
	for burst in [radial_burst, radial_burst_near, radial_burst_far]:
		burst.scale = Vector2.ONE
		burst.modulate.a = 0.0
	for line in _speed_lines:
		line.color.a = 0.0
		line.position = _effect_base_positions.get(line.get_path(), Vector2.ZERO)
	for particle in _particle_nodes:
		particle.color.a = 0.0
		particle.position = _effect_base_positions.get(particle.get_path(), Vector2.ZERO)
	hero_name_panel.modulate.a = 0.0
	skill_name_panel.modulate.a = 0.0
	flash_overlay.color.a = 0.0
