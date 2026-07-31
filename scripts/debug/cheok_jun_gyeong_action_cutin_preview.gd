extends Control

const HERO_ID := "cheok_jun_gyeong"
const HERO_NAME := "척준경"
const SKILL_TITLE_PNG_PATH := "res://assets/ui/cutin/titles/cheok_jun_gyeong__geomwang_dolpa__title.png"
const VIDEO_STREAM_PATH := "res://assets/ui/cutin/videos/cheok_jun_gyeong_cutin_bg_theora_q8_1280x720_verified.ogv"
const DIALOGUE := "내 앞을 막는 자, 목을 내놔라!"

@export_group("Relative text-block motion")
@export var hero_name_enter_offset := Vector2(-18, 0)
@export var skill_title_enter_scale := Vector2(0.90, 0.90)
@export var dialogue_enter_offset := Vector2(-14, 0)
@export_group("Authored readability timeline at 1.0x")
@export var full_video_duration := 4.01
@export var hero_name_enter_start := 0.12
@export var hero_name_enter_duration := 0.20
@export var skill_title_enter_start := 0.32
@export var skill_title_enter_duration := 0.26
@export var dialogue_enter_start := 0.65
@export var dialogue_enter_duration := 0.23
@export var text_block_hold_end := 3.25
@export var text_block_exit_duration := 0.30
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
var _hero_name_authored_position: Vector2
var _hero_name_authored_scale: Vector2
var _hero_name_authored_modulate: Color
var _hero_name_authored_pivot_offset: Vector2
var _skill_title_authored_position: Vector2
var _skill_title_authored_scale: Vector2
var _skill_title_authored_modulate: Color
var _skill_title_authored_pivot_offset: Vector2
var _dialogue_authored_position: Vector2
var _dialogue_authored_scale: Vector2
var _dialogue_authored_modulate: Color
var _dialogue_authored_pivot_offset: Vector2

func _ready() -> void:
	hero_name.text = HERO_NAME
	dialogue_label.text = DIALOGUE
	_capture_authored_state()
	play_button.pressed.connect(play_cutin)
	replay_button.pressed.connect(play_cutin)
	speed_075.pressed.connect(func() -> void: _set_speed(0.75))
	speed_100.pressed.connect(func() -> void: _set_speed(1.0))
	speed_125.pressed.connect(func() -> void: _set_speed(1.25))
	video_only_toggle.toggled.connect(func(_enabled: bool) -> void: _reset())
	_reset()

func _capture_authored_state() -> void:
	# Scene-authored transforms are the layout source of truth. Capture once,
	# before reset or tween playback changes any of the three text layers.
	_hero_name_authored_position = hero_name.position
	_hero_name_authored_scale = hero_name.scale
	_hero_name_authored_modulate = hero_name.modulate
	_hero_name_authored_pivot_offset = hero_name.pivot_offset
	_skill_title_authored_position = skill_title_png.position
	_skill_title_authored_scale = skill_title_png.scale
	_skill_title_authored_modulate = skill_title_png.modulate
	_skill_title_authored_pivot_offset = skill_title_png.pivot_offset
	_dialogue_authored_position = dialogue_label.position
	_dialogue_authored_scale = dialogue_label.scale
	_dialogue_authored_modulate = dialogue_label.modulate
	_dialogue_authored_pivot_offset = dialogue_label.pivot_offset

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
	_schedule_property(hero_name, "modulate:a", 0.0, 1.0, hero_name_enter_start, hero_name_enter_duration, text_block_hold_end, text_block_exit_duration)
	_schedule_property(hero_name, "position", _hero_name_authored_position + hero_name_enter_offset, _hero_name_authored_position, hero_name_enter_start, hero_name_enter_duration, text_block_hold_end, text_block_exit_duration, _hero_name_authored_position + hero_name_enter_offset)
	_schedule_property(hero_name, "scale", _hero_name_authored_scale, _hero_name_authored_scale, hero_name_enter_start, hero_name_enter_duration, text_block_hold_end, text_block_exit_duration)

	_schedule_property(skill_title_png, "modulate:a", 0.0, 1.0, skill_title_enter_start, skill_title_enter_duration, text_block_hold_end, text_block_exit_duration)
	var skill_scale_tween := _new_layer_tween()
	skill_scale_tween.tween_interval(skill_title_enter_start / _speed)
	skill_scale_tween.tween_property(skill_title_png, "scale", _skill_title_authored_scale * 1.04, skill_title_enter_duration * 0.5 / _speed).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	skill_scale_tween.tween_property(skill_title_png, "scale", _skill_title_authored_scale, skill_title_enter_duration * 0.5 / _speed)
	skill_scale_tween.tween_interval(maxf(0.0, text_block_hold_end - skill_title_enter_start - skill_title_enter_duration) / _speed)
	skill_scale_tween.tween_property(skill_title_png, "scale", _skill_title_authored_scale, text_block_exit_duration / _speed)
	_schedule_property(skill_title_png, "position", _skill_title_authored_position, _skill_title_authored_position, skill_title_enter_start, skill_title_enter_duration, text_block_hold_end, text_block_exit_duration, _skill_title_authored_position + hero_name_enter_offset)

	_schedule_property(dialogue_label, "modulate:a", 0.0, 1.0, dialogue_enter_start, dialogue_enter_duration, text_block_hold_end, text_block_exit_duration)
	_schedule_property(dialogue_label, "position", _dialogue_authored_position + dialogue_enter_offset, _dialogue_authored_position, dialogue_enter_start, dialogue_enter_duration, text_block_hold_end, text_block_exit_duration, _dialogue_authored_position + dialogue_enter_offset)
	_schedule_property(dialogue_label, "scale", _dialogue_authored_scale, _dialogue_authored_scale, dialogue_enter_start, dialogue_enter_duration, text_block_hold_end, text_block_exit_duration)

func _schedule_property(node: Node, property: NodePath, start_value: Variant, authored_value: Variant, enter_start: float, enter_duration: float, hold_end: float, exit_duration: float, exit_value: Variant = null) -> void:
	var tween := _new_layer_tween()
	tween.tween_interval(enter_start / _speed)
	tween.tween_property(node, property, authored_value, enter_duration / _speed)
	tween.tween_interval(maxf(0.0, hold_end - enter_start - enter_duration) / _speed)
	tween.tween_property(node, property, exit_value if exit_value != null else start_value, exit_duration / _speed)

func _new_layer_tween() -> Tween:
	var tween := create_tween()
	_layer_tweens.append(tween)
	return tween

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
	hero_name.position = _hero_name_authored_position + hero_name_enter_offset
	hero_name.scale = _hero_name_authored_scale
	hero_name.modulate = _hero_name_authored_modulate
	hero_name.pivot_offset = _hero_name_authored_pivot_offset
	hero_name.modulate.a = 0.0
	skill_title_png.position = _skill_title_authored_position
	skill_title_png.scale = _skill_title_authored_scale * skill_title_enter_scale
	skill_title_png.modulate = _skill_title_authored_modulate
	skill_title_png.pivot_offset = _skill_title_authored_pivot_offset
	skill_title_png.modulate.a = 0.0
	dialogue_label.position = _dialogue_authored_position + dialogue_enter_offset
	dialogue_label.scale = _dialogue_authored_scale
	dialogue_label.modulate = _dialogue_authored_modulate
	dialogue_label.pivot_offset = _dialogue_authored_pivot_offset
	dialogue_label.modulate.a = 0.0
	controls.show()
