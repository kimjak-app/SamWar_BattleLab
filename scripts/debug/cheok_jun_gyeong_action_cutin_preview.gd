extends Control

const HERO_ID := "cheok_jun_gyeong"
const HERO_NAME := "척준경"
const SKILL_TITLE_PNG_PATH := "res://assets/ui/cutin/titles/cheok_jun_gyeong__geomwang_dolpa__title.png"
const VIDEO_STREAM_PATH := "res://assets/ui/cutin/videos/cheok_jun_gyeong_cutin_bg_theora_q8_1280x720_verified.ogv"
const DIALOGUE := "내 앞을 막는 자, 목을 내놔라!"

@export_group("Master cutin timing at 1.0x")
@export var full_video_duration := 4.01
@export var hero_name_enter_at := 0.12
@export var skill_title_enter_at := 0.52
@export var dialogue_enter_at := 1.05
@export var hero_name_exit_at := 3.28
@export var skill_title_exit_at := 3.38
@export var dialogue_exit_at := 3.48
@export var loop_delay := 0.35

@onready var video: VideoStreamPlayer = $CutinStage/VideoBackgroundPlayer
@onready var hero_name: Label = $CutinStage/HeroNameLabel
@onready var skill_title_png: TextureRect = $CutinStage/SkillTitlePng
@onready var dialogue_label: Label = $CutinStage/DialogueLabel
@onready var controls: Panel = $PreviewControls
@onready var loop_toggle: CheckButton = $PreviewControls/Row/LoopToggle
@onready var video_only_toggle: CheckButton = $PreviewControls/Row/VideoOnlyToggle
@onready var play_button: Button = $PreviewControls/Row/PlayButton
@onready var replay_button: Button = $PreviewControls/Row/ReplayButton
@onready var speed_075: Button = $PreviewControls/Row/Speed075Button
@onready var speed_100: Button = $PreviewControls/Row/Speed100Button
@onready var speed_125: Button = $PreviewControls/Row/Speed125Button

var _tween: Tween
var _layer_tweens: Array[Tween] = []
var _loop_timer: SceneTreeTimer
var _speed := 1.0
var _playing := false
var _hero_name_base_position := Vector2(36, 60)
var _skill_title_base_position := Vector2(34, 125)
var _dialogue_base_position := Vector2(42, 358)

func _ready() -> void:
	hero_name.text = HERO_NAME
	dialogue_label.text = DIALOGUE
	play_button.pressed.connect(play_cutin)
	replay_button.pressed.connect(play_cutin)
	speed_075.pressed.connect(func() -> void: _set_speed(0.75))
	speed_100.pressed.connect(func() -> void: _set_speed(1.0))
	speed_125.pressed.connect(func() -> void: _set_speed(1.25))
	video_only_toggle.toggled.connect(func(_enabled: bool) -> void: _reset())
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
	if video_only_toggle.button_pressed:
		_tween.tween_interval(full_video_duration / _speed)
		_tween.tween_callback(_finish)
		return
	_schedule_master_layers()
	_tween.tween_interval(full_video_duration / _speed)
	_tween.tween_callback(_finish)

func _schedule_master_layers() -> void:
	# Independent sub-tweens keep every authored layer adjustable for future heroes.
	var hero_tween := create_tween()
	_layer_tweens.append(hero_tween)
	hero_tween.tween_interval(hero_name_enter_at / _speed)
	hero_tween.parallel().tween_property(hero_name, "modulate:a", 1.0, 0.12 / _speed)
	hero_tween.parallel().tween_property(hero_name, "position", _hero_name_base_position, 0.12 / _speed)
	hero_tween.parallel().tween_property(hero_name, "scale", Vector2(1.06, 1.06), 0.12 / _speed).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	hero_tween.tween_property(hero_name, "scale", Vector2.ONE, 0.06 / _speed)
	hero_tween.tween_interval(maxf(0.0, hero_name_exit_at - hero_name_enter_at - 0.18) / _speed)
	hero_tween.parallel().tween_property(hero_name, "modulate:a", 0.0, 0.12 / _speed)
	hero_tween.parallel().tween_property(hero_name, "position", _hero_name_base_position + Vector2(-34, 0), 0.12 / _speed)

	var skill_tween := create_tween()
	_layer_tweens.append(skill_tween)
	skill_tween.tween_interval(skill_title_enter_at / _speed)
	skill_tween.parallel().tween_property(skill_title_png, "modulate:a", 1.0, 0.08 / _speed)
	skill_tween.parallel().tween_property(skill_title_png, "scale", Vector2(1.12, 1.12), 0.11 / _speed).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	skill_tween.tween_property(skill_title_png, "scale", Vector2.ONE, 0.08 / _speed)
	skill_tween.tween_interval(maxf(0.0, skill_title_exit_at - skill_title_enter_at - 0.27) / _speed)
	skill_tween.parallel().tween_property(skill_title_png, "modulate:a", 0.0, 0.13 / _speed)
	skill_tween.parallel().tween_property(skill_title_png, "position", _skill_title_base_position + Vector2(-28, 0), 0.13 / _speed)

	var dialogue_tween := create_tween()
	_layer_tweens.append(dialogue_tween)
	dialogue_tween.tween_interval(dialogue_enter_at / _speed)
	dialogue_tween.parallel().tween_property(dialogue_label, "modulate:a", 1.0, 0.15 / _speed)
	dialogue_tween.parallel().tween_property(dialogue_label, "position", _dialogue_base_position, 0.15 / _speed)
	dialogue_tween.tween_interval(maxf(0.0, dialogue_exit_at - dialogue_enter_at - 0.15) / _speed)
	dialogue_tween.parallel().tween_property(dialogue_label, "modulate:a", 0.0, 0.12 / _speed)
	dialogue_tween.parallel().tween_property(dialogue_label, "position", _dialogue_base_position + Vector2(-20, 0), 0.12 / _speed)

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
	for layer_tween in _layer_tweens:
		if is_instance_valid(layer_tween): layer_tween.kill()
	_layer_tweens.clear()
	_loop_timer = null
	video.stop()
	video.stream_position = 0.0
	_playing = false

func _reset() -> void:
	video.stop()
	video.stream_position = 0.0
	video.modulate = Color.WHITE
	video.self_modulate = Color.WHITE
	hero_name.position = _hero_name_base_position + Vector2(-34, 0)
	hero_name.scale = Vector2.ONE
	hero_name.modulate.a = 0.0
	skill_title_png.position = _skill_title_base_position
	skill_title_png.scale = Vector2(0.72, 0.72)
	skill_title_png.modulate.a = 0.0
	dialogue_label.position = _dialogue_base_position + Vector2(-20, 0)
	dialogue_label.modulate.a = 0.0
	controls.show()
