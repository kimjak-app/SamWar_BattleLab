extends Control

const HERO_ID := "cheok_jun_gyeong"
const FALLBACK_HERO_NAME := "척준경"
const FALLBACK_SKILL_NAME := "검왕돌파"
@export var full_video_duration := 4.01
@export var loop_delay := 0.35

@onready var video: VideoStreamPlayer = $CutinStage/VideoBackgroundPlayer
@onready var title_root: Control = $CutinStage/TitleRoot
@onready var hero_name: Label = $CutinStage/TitleRoot/HeroNameLabel
@onready var skill_name: Label = $CutinStage/TitleRoot/SkillNameLabel
@onready var accent_line: ColorRect = $CutinStage/TitleRoot/AccentLine
@onready var controls: Panel = $PreviewControls
@onready var loop_toggle: CheckButton = $PreviewControls/Row/LoopToggle
@onready var play_button: Button = $PreviewControls/Row/PlayButton
@onready var replay_button: Button = $PreviewControls/Row/ReplayButton
@onready var speed_075: Button = $PreviewControls/Row/Speed075Button
@onready var speed_100: Button = $PreviewControls/Row/Speed100Button
@onready var speed_125: Button = $PreviewControls/Row/Speed125Button

var _tween: Tween
var _loop_timer: SceneTreeTimer
var _speed := 1.0
var _playing := false
var _title_base_position := Vector2(32, 240)

func _ready() -> void:
	var base := HeroDesignDataRegistry.get_base_stats(HERO_ID)
	hero_name.text = String(base.get("display_name", FALLBACK_HERO_NAME))
	var skill := HeroDesignDataRegistry.get_unique_skill_for_hero(HERO_ID)
	skill_name.text = String(skill.get("display_name", FALLBACK_SKILL_NAME))
	play_button.pressed.connect(play_cutin)
	replay_button.pressed.connect(play_cutin)
	speed_075.pressed.connect(func() -> void: _set_speed(0.75))
	speed_100.pressed.connect(func() -> void: _set_speed(1.0))
	speed_125.pressed.connect(func() -> void: _set_speed(1.25))
	_reset()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_pressed() and event.keycode == KEY_ESCAPE:
		_stop()
		_reset()

func _exit_tree() -> void:
	_stop()

func _set_speed(value: float) -> void:
	_speed = value
	speed_075.button_pressed = is_equal_approx(value, 0.75)
	speed_100.button_pressed = is_equal_approx(value, 1.0)
	speed_125.button_pressed = is_equal_approx(value, 1.25)

func play_cutin() -> void:
	_stop()
	_reset()
	_playing = true
	controls.hide()
	video.play()
	_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.tween_interval(0.40 / _speed)
	title_root.position = _title_base_position + Vector2(-42, 0)
	_tween.parallel().tween_property(title_root, "modulate:a", 1.0, 0.12 / _speed)
	_tween.parallel().tween_property(title_root, "position", _title_base_position, 0.12 / _speed)
	_tween.tween_interval(0.12 / _speed)
	title_root.scale = Vector2(0.20, 0.20)
	title_root.rotation = deg_to_rad(-3.0)
	_tween.parallel().tween_property(title_root, "scale", Vector2(1.22, 1.22), 0.11 / _speed).set_trans(Tween.TRANS_BACK)
	_tween.parallel().tween_property(title_root, "rotation", 0.0, 0.11 / _speed)
	_tween.parallel().tween_property(accent_line, "color:a", 1.0, 0.10 / _speed)
	_tween.tween_property(title_root, "scale", Vector2.ONE, 0.09 / _speed)
	_tween.tween_interval(0.78 / _speed)
	_tween.parallel().tween_property(title_root, "position", _title_base_position + Vector2(-46, 0), 0.14 / _speed)
	_tween.parallel().tween_property(title_root, "scale", Vector2(1.06, 1.06), 0.14 / _speed)
	_tween.parallel().tween_property(title_root, "modulate:a", 0.0, 0.14 / _speed)
	_tween.tween_interval(maxf(0.0, full_video_duration / _speed - 1.76 / _speed))
	_tween.tween_callback(_finish)

func _finish() -> void:
	_playing = false
	_reset()
	if loop_toggle.button_pressed:
		_loop_timer = get_tree().create_timer(loop_delay)
		_loop_timer.timeout.connect(func() -> void:
			if is_inside_tree() and loop_toggle.button_pressed and not _playing: play_cutin())

func _stop() -> void:
	if is_instance_valid(_tween): _tween.kill()
	_tween = null
	_loop_timer = null
	video.stop()
	video.stream_position = 0.0
	_playing = false

func _reset() -> void:
	video.stop()
	video.stream_position = 0.0
	video.modulate = Color.WHITE
	video.self_modulate = Color.WHITE
	title_root.position = _title_base_position
	title_root.scale = Vector2.ONE
	title_root.rotation = 0.0
	title_root.modulate.a = 0.0
	accent_line.color.a = 0.0
	controls.show()
