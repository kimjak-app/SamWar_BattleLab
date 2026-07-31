class_name HeroCutinPresentation
extends Control

signal cutin_finished

@export_group("Relative text-block motion")
@export var hero_name_enter_offset := Vector2(-18, 0)
@export var skill_title_enter_scale := Vector2(0.90, 0.90)
@export var dialogue_enter_offset := Vector2(-14, 0)
@export var dialogue_layout_offset := Vector2(0, -9)
@export_group("Approved readability timeline at 1.0x")
@export var full_video_duration := 4.01
@export var hero_name_enter_start := 0.12
@export var hero_name_enter_duration := 0.20
@export var skill_title_enter_start := 0.32
@export var skill_title_enter_duration := 0.26
@export var dialogue_enter_start := 0.65
@export var dialogue_enter_duration := 0.23
@export var text_block_hold_end := 3.25
@export var text_block_exit_duration := 0.30

@onready var video: VideoStreamPlayer = $CutinStage/VideoBackgroundPlayer
@onready var hero_name_label: Label = $CutinStage/HeroNameLabel
@onready var skill_title_png: TextureRect = $CutinStage/SkillTitlePng
@onready var dialogue_label: Label = $CutinStage/DialogueLabel

var _root_tween: Tween
var _layer_tweens: Array[Tween] = []
var _playback_speed := 1.0
var _playing := false
var _show_text_layers := true
var _hero_name_hero_offset := Vector2.ZERO
var _dialogue_hero_offset := Vector2.ZERO
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
	_capture_authored_state()
	reset_cutin()

func _exit_tree() -> void:
	stop_cutin()

func configure(hero_name: String, dialogue: String, video_stream: VideoStream, skill_title_texture: Texture2D, dialogue_offset: Vector2 = Vector2.ZERO, hero_name_offset: Vector2 = Vector2.ZERO) -> void:
	stop_cutin()
	hero_name_label.text = hero_name
	dialogue_label.text = dialogue
	video.stream = video_stream
	skill_title_png.texture = skill_title_texture
	_dialogue_hero_offset = Vector2(dialogue_offset.x, 0.0)
	_hero_name_hero_offset = Vector2(hero_name_offset.x, 0.0)
	reset_cutin()

func set_playback_speed(value: float) -> void:
	_playback_speed = maxf(value, 0.01)

func play_cutin(show_text_layers: bool = true) -> void:
	stop_cutin()
	reset_cutin()
	_show_text_layers = show_text_layers
	_playing = true
	video.play()
	_root_tween = create_tween()
	if _show_text_layers:
		_schedule_master_layers()
	_root_tween.tween_interval(full_video_duration / _playback_speed)
	_root_tween.tween_callback(_finish_cutin)

func replay_cutin(show_text_layers: bool = true) -> void:
	play_cutin(show_text_layers)

func stop_cutin() -> void:
	if is_instance_valid(_root_tween): _root_tween.kill()
	_root_tween = null
	for layer_tween in _layer_tweens:
		if is_instance_valid(layer_tween): layer_tween.kill()
	_layer_tweens.clear()
	video.stop()
	video.stream_position = 0.0
	_playing = false

func reset_cutin() -> void:
	video.stop()
	video.stream_position = 0.0
	video.modulate = Color.WHITE
	video.self_modulate = Color.WHITE
	hero_name_label.position = _hero_name_enter_position()
	hero_name_label.scale = _hero_name_authored_scale
	hero_name_label.modulate = _hero_name_authored_modulate
	hero_name_label.pivot_offset = _hero_name_authored_pivot_offset
	hero_name_label.modulate.a = 0.0
	skill_title_png.position = _skill_title_authored_position
	skill_title_png.scale = _skill_title_authored_scale * skill_title_enter_scale
	skill_title_png.modulate = _skill_title_authored_modulate
	skill_title_png.pivot_offset = _skill_title_authored_pivot_offset
	skill_title_png.modulate.a = 0.0
	dialogue_label.position = _dialogue_enter_position()
	dialogue_label.scale = _dialogue_authored_scale
	dialogue_label.modulate = _dialogue_authored_modulate
	dialogue_label.pivot_offset = _dialogue_authored_pivot_offset
	dialogue_label.modulate.a = 0.0

func is_playing() -> bool:
	return _playing

func _capture_authored_state() -> void:
	_hero_name_authored_position = hero_name_label.position
	_hero_name_authored_scale = hero_name_label.scale
	_hero_name_authored_modulate = hero_name_label.modulate
	_hero_name_authored_pivot_offset = hero_name_label.pivot_offset
	_skill_title_authored_position = skill_title_png.position
	_skill_title_authored_scale = skill_title_png.scale
	_skill_title_authored_modulate = skill_title_png.modulate
	_skill_title_authored_pivot_offset = skill_title_png.pivot_offset
	_dialogue_authored_position = dialogue_label.position
	_dialogue_authored_scale = dialogue_label.scale
	_dialogue_authored_modulate = dialogue_label.modulate
	_dialogue_authored_pivot_offset = dialogue_label.pivot_offset

func _schedule_master_layers() -> void:
	_schedule_property(hero_name_label, "modulate:a", 0.0, 1.0, hero_name_enter_start, hero_name_enter_duration, text_block_hold_end, text_block_exit_duration)
	_schedule_property(hero_name_label, "position", _hero_name_enter_position(), _hero_name_target_position(), hero_name_enter_start, hero_name_enter_duration, text_block_hold_end, text_block_exit_duration, _hero_name_enter_position())
	_schedule_property(hero_name_label, "scale", _hero_name_authored_scale, _hero_name_authored_scale, hero_name_enter_start, hero_name_enter_duration, text_block_hold_end, text_block_exit_duration)
	_schedule_property(skill_title_png, "modulate:a", 0.0, 1.0, skill_title_enter_start, skill_title_enter_duration, text_block_hold_end, text_block_exit_duration)
	var skill_scale_tween := _new_layer_tween()
	skill_scale_tween.tween_interval(skill_title_enter_start / _playback_speed)
	skill_scale_tween.tween_property(skill_title_png, "scale", _skill_title_authored_scale * 1.04, skill_title_enter_duration * 0.5 / _playback_speed).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	skill_scale_tween.tween_property(skill_title_png, "scale", _skill_title_authored_scale, skill_title_enter_duration * 0.5 / _playback_speed)
	skill_scale_tween.tween_interval(maxf(0.0, text_block_hold_end - skill_title_enter_start - skill_title_enter_duration) / _playback_speed)
	skill_scale_tween.tween_property(skill_title_png, "scale", _skill_title_authored_scale, text_block_exit_duration / _playback_speed)
	_schedule_property(skill_title_png, "position", _skill_title_authored_position, _skill_title_authored_position, skill_title_enter_start, skill_title_enter_duration, text_block_hold_end, text_block_exit_duration, _skill_title_authored_position + hero_name_enter_offset)
	_schedule_property(dialogue_label, "modulate:a", 0.0, 1.0, dialogue_enter_start, dialogue_enter_duration, text_block_hold_end, text_block_exit_duration)
	_schedule_property(dialogue_label, "position", _dialogue_enter_position(), _dialogue_target_position(), dialogue_enter_start, dialogue_enter_duration, text_block_hold_end, text_block_exit_duration, _dialogue_enter_position())
	_schedule_property(dialogue_label, "scale", _dialogue_authored_scale, _dialogue_authored_scale, dialogue_enter_start, dialogue_enter_duration, text_block_hold_end, text_block_exit_duration)

func _schedule_property(node: Node, property: NodePath, start_value: Variant, authored_value: Variant, enter_start: float, enter_duration: float, hold_end: float, exit_duration: float, exit_value: Variant = null) -> void:
	var tween := _new_layer_tween()
	tween.tween_interval(enter_start / _playback_speed)
	tween.tween_property(node, property, authored_value, enter_duration / _playback_speed)
	tween.tween_interval(maxf(0.0, hold_end - enter_start - enter_duration) / _playback_speed)
	tween.tween_property(node, property, exit_value if exit_value != null else start_value, exit_duration / _playback_speed)

func _new_layer_tween() -> Tween:
	var tween := create_tween()
	_layer_tweens.append(tween)
	return tween

func _dialogue_target_position() -> Vector2:
	return _dialogue_authored_position + dialogue_layout_offset + _dialogue_hero_offset

func _dialogue_enter_position() -> Vector2:
	return _dialogue_target_position() + dialogue_enter_offset

func _hero_name_target_position() -> Vector2:
	return _hero_name_authored_position + _hero_name_hero_offset

func _hero_name_enter_position() -> Vector2:
	return _hero_name_target_position() + hero_name_enter_offset

func _finish_cutin() -> void:
	_playing = false
	reset_cutin()
	cutin_finished.emit()
