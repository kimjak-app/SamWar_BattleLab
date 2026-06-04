extends Control

const STREAMS := [
	{
		"label": "q7 1280x",
		"path": "res://assets/video_test/theora_safe/test_safe_q7_1280x.ogv"
	},
	{
		"label": "q8 1920x",
		"path": "res://assets/video_test/theora_safe/test_safe_q8_1920x.ogv"
	},
	{
		"label": "q7 1280x noaudio",
		"path": "res://assets/video_test/theora_safe/test_safe_q7_1280x_noaudio.ogv"
	}
]

@onready var video_player: VideoStreamPlayer = $VideoFrame/VideoPlayer
@onready var stream_selector: OptionButton = $Controls/HBox/StreamSelector
@onready var path_label: Label = $Controls/HBox/StatusBox/PathLabel
@onready var state_label: Label = $Controls/HBox/StatusBox/StateLabel
@onready var play_button: Button = $Controls/HBox/PlayButton
@onready var reload_button: Button = $Controls/HBox/ReloadButton

var _current_index := 0


func _ready() -> void:
	_apply_command_line_stream_selection()
	for stream_info in STREAMS:
		stream_selector.add_item(stream_info["label"])
	stream_selector.select(_current_index)
	stream_selector.item_selected.connect(_on_stream_selected)
	play_button.pressed.connect(_play_current_stream)
	reload_button.pressed.connect(_reload_current_stream)
	video_player.finished.connect(_on_video_finished)
	_load_current_stream(true)


func _apply_command_line_stream_selection() -> void:
	var args := OS.get_cmdline_user_args()
	for arg in args:
		if arg == "--video-test-q7":
			_current_index = 0
		elif arg == "--video-test-q8":
			_current_index = 1
		elif arg == "--video-test-q7-noaudio":
			_current_index = 2


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_left"):
		_select_relative_stream(-1)
	elif Input.is_action_just_pressed("ui_right"):
		_select_relative_stream(1)
	elif Input.is_action_just_pressed("ui_accept"):
		_play_current_stream()


func _select_relative_stream(delta: int) -> void:
	var stream_count := STREAMS.size()
	if stream_count <= 0:
		return
	_current_index = wrapi(_current_index + delta, 0, stream_count)
	stream_selector.select(_current_index)
	_load_current_stream(true)


func _on_stream_selected(index: int) -> void:
	_current_index = index
	_load_current_stream(true)


func _reload_current_stream() -> void:
	_load_current_stream(true)


func _play_current_stream() -> void:
	if video_player.stream == null:
		_log_state("play skipped: stream is null")
		return
	video_player.stop()
	video_player.play()
	await get_tree().process_frame
	_log_state("play requested")


func _load_current_stream(autoplay: bool) -> void:
	if _current_index < 0 or _current_index >= STREAMS.size():
		_log_state("invalid stream index")
		return

	var stream_path: String = STREAMS[_current_index]["path"]
	path_label.text = stream_path
	video_player.stop()
	video_player.stream = null

	print("[VIDEO_THEORA_TEST] stream_path=", stream_path)
	var file_exists := FileAccess.file_exists(stream_path)
	print("[VIDEO_THEORA_TEST] file_exists=", file_exists)
	print("[VIDEO_THEORA_TEST] resource_exists=", ResourceLoader.exists(stream_path))
	if not file_exists:
		_log_state("missing file")
		return

	var loaded := ResourceLoader.load(stream_path)
	print("[VIDEO_THEORA_TEST] load_null=", loaded == null)
	if loaded != null:
		print("[VIDEO_THEORA_TEST] loaded_class=", loaded.get_class())
		print("[VIDEO_THEORA_TEST] is_video_stream=", loaded is VideoStream)

	if loaded is VideoStream:
		video_player.stream = loaded
	else:
		var direct_stream := VideoStreamTheora.new()
		if "file" in direct_stream:
			direct_stream.set("file", stream_path)
			video_player.stream = direct_stream
			print("[VIDEO_THEORA_TEST] direct_theora_stream_created=true")
		else:
			print("[VIDEO_THEORA_TEST] direct_theora_stream_created=false")

	_log_state("loaded")
	if autoplay and video_player.stream != null:
		_play_current_stream()


func _on_video_finished() -> void:
	_log_state("finished signal")


func _log_state(reason: String) -> void:
	var stream_path := ""
	if _current_index >= 0 and _current_index < STREAMS.size():
		stream_path = STREAMS[_current_index]["path"]
	var stream_class := "null"
	if video_player.stream != null:
		stream_class = video_player.stream.get_class()
	var message := "reason=%s | path=%s | stream=%s | is_playing=%s" % [
		reason,
		stream_path,
		stream_class,
		str(video_player.is_playing())
	]
	state_label.text = message
	print("[VIDEO_THEORA_TEST] ", message)
