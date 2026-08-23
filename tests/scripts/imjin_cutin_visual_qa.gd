extends Control

const Registry := preload("res://scripts/ui/cutin/korea_mvp_hero_cutin_registry.gd")

@onready var presentation: HeroCutinPresentation = $HeroCutinPresentation
@onready var status_label: Label = $StatusLabel

var _entries: Array[Dictionary] = []
var _index := 0
var _failed := false


func _ready() -> void:
	_entries = Registry.load_additional_entries()
	if _entries.size() != 8:
		_fail("expected 8 Imjin cutins, found %d" % _entries.size())
		return
	presentation.cutin_finished.connect(_on_cutin_finished)
	call_deferred("_play_current")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_R:
		if _failed or _entries.is_empty():
			return
		_index = 0
		_play_current()


func _play_current() -> void:
	if _failed:
		return
	if _index >= _entries.size():
		status_label.text = "D5-3 PREVIEW COMPLETE — 8/8   |   R: replay   ESC: close"
		return

	var entry := _entries[_index]
	var hero_name := String(entry.get("hero_name", ""))
	var skill_name := String(entry.get("skill_name", ""))
	var video_path := String(entry.get("video_path", ""))
	var title_path := String(entry.get("skill_title_texture_path", ""))
	var video_stream := ResourceLoader.load(video_path) as VideoStream
	var title_texture := ResourceLoader.load(title_path) as Texture2D

	if video_stream == null:
		_fail("video load failed: %s -> %s" % [hero_name, video_path])
		return
	if title_texture == null:
		_fail("title load failed: %s -> %s" % [hero_name, title_path])
		return

	status_label.text = "D5-3  %d/8   %s — %s" % [_index + 1, hero_name, skill_name]
	presentation.configure(
		hero_name,
		String(entry.get("dialogue", "")),
		video_stream,
		title_texture,
		Vector2(float(entry.get("dialogue_offset_x", 0.0)), 0.0),
		Vector2(float(entry.get("hero_name_offset_x", 0.0)), 0.0)
	)
	presentation.set_playback_speed(1.0)
	presentation.play_cutin()


func _on_cutin_finished() -> void:
	if _failed:
		return
	_index += 1
	if _index >= _entries.size():
		status_label.text = "D5-3 PREVIEW COMPLETE — 8/8   |   R: replay   ESC: close"
		return
	await get_tree().create_timer(0.35).timeout
	_play_current()


func _fail(message: String) -> void:
	_failed = true
	status_label.text = "D5-3 PREVIEW FAILED — %s" % message
	push_error(status_label.text)
