extends PopupPanel

@onready var sfx_enabled: CheckButton = $Margin/Content/SfxEnabled
@onready var sfx_volume: HSlider = $Margin/Content/SfxVolume/Slider
@onready var sfx_value: Label = $Margin/Content/SfxVolume/Value
@onready var duplicate_limit: CheckButton = $Margin/Content/DuplicateLimit
@onready var video_enabled: CheckButton = $Margin/Content/VideoEnabled
@onready var video_volume: HSlider = $Margin/Content/VideoVolume/Slider
@onready var video_value: Label = $Margin/Content/VideoVolume/Value

func _ready() -> void:
	about_to_popup.connect(_refresh)
	close_requested.connect(hide)
	sfx_enabled.toggled.connect(_on_sfx_enabled)
	sfx_volume.value_changed.connect(_on_sfx_volume)
	duplicate_limit.toggled.connect(GameAudio.set_duplicate_limit_enabled)
	video_enabled.toggled.connect(_on_video_enabled)
	video_volume.value_changed.connect(_on_video_volume)
	$Margin/Content/Buttons/Preview.pressed.connect(GameAudio.play_sfx.bind("success"))
	$Margin/Content/Buttons/Close.pressed.connect(hide)

func _refresh() -> void:
	sfx_enabled.set_pressed_no_signal(GameAudio.is_sfx_enabled())
	sfx_volume.set_value_no_signal(GameAudio.get_sfx_volume() * 100.0)
	duplicate_limit.set_pressed_no_signal(GameAudio.is_duplicate_limit_enabled())
	video_enabled.set_pressed_no_signal(GameAudio.is_video_enabled())
	video_volume.set_value_no_signal(GameAudio.get_video_volume() * 100.0)
	sfx_value.text = "%d%%" % int(sfx_volume.value)
	video_value.text = "%d%%" % int(video_volume.value)
	$Margin/Content/Buttons/Preview.disabled = not GameAudio.is_sfx_enabled() or GameAudio.get_sfx_volume() <= 0.0

func _on_sfx_enabled(enabled: bool) -> void:
	GameAudio.set_sfx_enabled(enabled)
	_refresh()

func _on_sfx_volume(value: float) -> void:
	GameAudio.set_sfx_volume(value / 100.0)
	_refresh()

func _on_video_enabled(enabled: bool) -> void:
	GameAudio.set_video_enabled(enabled)
	_refresh()

func _on_video_volume(value: float) -> void:
	GameAudio.set_video_volume(value / 100.0)
	_refresh()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		set_input_as_handled()
		hide()
