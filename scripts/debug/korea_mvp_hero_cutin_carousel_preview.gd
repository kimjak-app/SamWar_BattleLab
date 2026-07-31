extends Control

const MISSING_DIALOGUE_STATUS := "대사 자료 미확정 — 확정 대사를 등록하기 전까지 대사 레이어를 표시하지 않습니다."

@onready var presentation: HeroCutinPresentation = $HeroCutinPresentation
@onready var controls: Panel = $PreviewControls
@onready var entry_label: Label = $EntryLabel
@onready var dialogue_status_label: Label = $DialogueStatusLabel
@onready var auto_cycle_toggle: CheckButton = $PreviewControls/Row/AutoCycleToggle
@onready var video_only_toggle: CheckButton = $PreviewControls/Row/VideoOnlyToggle

var _entries: Array[Dictionary] = []
var _current_index := 0
var _speed := 1.0
var _auto_cycle_count := 0

func _ready() -> void:
	_entries = KoreaMvpHeroCutinRegistry.load_entries()
	if _entries.is_empty():
		entry_label.text = "Korea MVP cutin registry load failed"
		return
	presentation.cutin_finished.connect(_on_cutin_finished)
	$PreviewControls/Row/PreviousButton.pressed.connect(previous_hero)
	$PreviewControls/Row/NextButton.pressed.connect(next_hero)
	$PreviewControls/Row/PlayButton.pressed.connect(play_current)
	$PreviewControls/Row/ReplayButton.pressed.connect(play_current)
	$PreviewControls/Row/Speed075Button.pressed.connect(func() -> void: _set_speed(0.75))
	$PreviewControls/Row/Speed100Button.pressed.connect(func() -> void: _set_speed(1.0))
	$PreviewControls/Row/Speed125Button.pressed.connect(func() -> void: _set_speed(1.25))
	video_only_toggle.toggled.connect(func(_enabled: bool) -> void: _stop_and_reset())
	_configure_current()

func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo(): return
	match event.keycode:
		KEY_ESCAPE: _stop_and_reset()
		KEY_LEFT: previous_hero()
		KEY_RIGHT: next_hero()
		KEY_SPACE, KEY_ENTER: play_current()
		KEY_R: play_current()
		KEY_L: auto_cycle_toggle.button_pressed = not auto_cycle_toggle.button_pressed
		KEY_V: video_only_toggle.button_pressed = not video_only_toggle.button_pressed

func previous_hero() -> void:
	if _entries.is_empty(): return
	_current_index = posmod(_current_index - 1, _entries.size())
	_configure_current()

func next_hero() -> void:
	if _entries.is_empty(): return
	_current_index = posmod(_current_index + 1, _entries.size())
	_configure_current()

func play_current() -> void:
	if _entries.is_empty(): return
	controls.hide()
	presentation.set_playback_speed(_speed)
	presentation.play_cutin(not video_only_toggle.button_pressed)

func _configure_current() -> void:
	_stop_and_reset()
	var entry := _entries[_current_index]
	var dialogue := str(entry.get("dialogue", ""))
	presentation.configure(
		str(entry["hero_name"]), dialogue,
		ResourceLoader.load(str(entry["video_path"])) as VideoStream,
		ResourceLoader.load(str(entry["skill_title_texture_path"])) as Texture2D
	)
	entry_label.text = "%d / %d  ·  %s  ·  %s" % [_current_index + 1, _entries.size(), entry["hero_id"], entry["skill_name"]]
	dialogue_status_label.visible = entry.get("dialogue_status", "") != "confirmed"
	dialogue_status_label.text = MISSING_DIALOGUE_STATUS if dialogue_status_label.visible else ""

func _on_cutin_finished() -> void:
	controls.show()
	if auto_cycle_toggle.button_pressed:
		_auto_cycle_count += 1
		next_hero()
		play_current()

func _set_speed(value: float) -> void:
	_speed = value
	$PreviewControls/Row/Speed075Button.button_pressed = is_equal_approx(value, 0.75)
	$PreviewControls/Row/Speed100Button.button_pressed = is_equal_approx(value, 1.0)
	$PreviewControls/Row/Speed125Button.button_pressed = is_equal_approx(value, 1.25)

func _stop_and_reset() -> void:
	presentation.stop_cutin()
	presentation.reset_cutin()
	controls.show()
