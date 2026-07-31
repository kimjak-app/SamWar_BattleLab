extends Control

const HERO_NAME := "척준경"
const SKILL_TITLE_PNG_PATH := "res://assets/ui/cutin/titles/cheok_jun_gyeong__geomwang_dolpa__title.png"
const VIDEO_STREAM_PATH := "res://assets/ui/cutin/videos/cheok_jun_gyeong_cutin_bg_theora_q8_1280x720_verified.ogv"
const DIALOGUE := "내 앞을 막는 자, 목을 내놔라!"

@export var loop_delay := 0.35

@onready var presentation: HeroCutinPresentation = $HeroCutinPresentation
@onready var controls: Panel = $PreviewControls
@onready var loop_toggle: CheckButton = $PreviewControls/Row/LoopToggle
@onready var video_only_toggle: CheckButton = $PreviewControls/Row/VideoOnlyToggle
@onready var play_button: Button = $PreviewControls/Row/PlayButton
@onready var replay_button: Button = $PreviewControls/Row/ReplayButton
@onready var speed_075: Button = $PreviewControls/Row/Speed075Button
@onready var speed_100: Button = $PreviewControls/Row/Speed100Button
@onready var speed_125: Button = $PreviewControls/Row/Speed125Button

var _loop_timer: SceneTreeTimer
var _speed := 1.0

func _ready() -> void:
	presentation.configure(HERO_NAME, DIALOGUE, _load_video_stream(), _load_skill_title_texture())
	presentation.cutin_finished.connect(_finish)
	play_button.pressed.connect(play_cutin)
	replay_button.pressed.connect(play_cutin)
	speed_075.pressed.connect(func() -> void: _set_speed(0.75))
	speed_100.pressed.connect(func() -> void: _set_speed(1.0))
	speed_125.pressed.connect(func() -> void: _set_speed(1.25))
	video_only_toggle.toggled.connect(func(_enabled: bool) -> void: _stop_and_reset())
	_stop_and_reset()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_pressed() and event.keycode == KEY_ESCAPE:
		_stop_and_reset()

func _exit_tree() -> void:
	presentation.stop_cutin()

func _set_speed(value: float) -> void:
	_speed = value
	speed_075.button_pressed = is_equal_approx(value, 0.75)
	speed_100.button_pressed = is_equal_approx(value, 1.0)
	speed_125.button_pressed = is_equal_approx(value, 1.25)

func play_cutin() -> void:
	_stop_and_reset()
	controls.hide()
	presentation.set_playback_speed(_speed)
	presentation.play_cutin(not video_only_toggle.button_pressed)

func _finish() -> void:
	controls.show()
	if loop_toggle.button_pressed:
		_loop_timer = get_tree().create_timer(loop_delay)
		_loop_timer.timeout.connect(func() -> void:
			if is_inside_tree() and loop_toggle.button_pressed and not presentation.is_playing(): play_cutin())

func _stop_and_reset() -> void:
	_loop_timer = null
	presentation.stop_cutin()
	presentation.reset_cutin()

func _load_video_stream() -> VideoStream:
	return ResourceLoader.load(VIDEO_STREAM_PATH) as VideoStream

func _load_skill_title_texture() -> Texture2D:
	return ResourceLoader.load(SKILL_TITLE_PNG_PATH) as Texture2D
