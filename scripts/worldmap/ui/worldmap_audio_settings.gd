extends PopupPanel

@onready var sfx_enabled: CheckButton = $Margin/Content/SfxEnabled
@onready var sfx_volume: HSlider = $Margin/Content/SfxVolume/Slider
@onready var sfx_value: Label = $Margin/Content/SfxVolume/Value
@onready var duplicate_limit: CheckButton = $Margin/Content/DuplicateLimit
@onready var video_enabled: CheckButton = $Margin/Content/VideoEnabled
@onready var video_volume: HSlider = $Margin/Content/VideoVolume/Slider
@onready var video_value: Label = $Margin/Content/VideoVolume/Value
# T-WM3D-08: world-map display (2D / 3D) and 3D camera input scheme, built in code (user settings, WorldMap3DSettings)
var map_3d_enabled: CheckButton = null
var camera_scheme: OptionButton = null
var map_help: Label = null
const CAMERA_SCHEMES := ["A", "B"]   # worldmap3d/scripts/worldmap_camera.gd v2.2 input schemes

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
	_build_worldmap_settings()

func _build_worldmap_settings() -> void:
	var content: VBoxContainer = $Margin/Content
	var at := $Margin/Content/Buttons.get_index()
	var divider := HSeparator.new()
	divider.name = "WorldMapDivider"
	map_3d_enabled = CheckButton.new()
	map_3d_enabled.name = "WorldMap3DEnabled"
	map_3d_enabled.custom_minimum_size = Vector2(0, 44)
	map_3d_enabled.text = "3D 월드맵"
	var row := HBoxContainer.new()
	row.name = "CameraScheme"
	var row_label := Label.new()
	row_label.text = "3D 카메라 입력"
	row_label.custom_minimum_size = Vector2(150, 0)
	camera_scheme = OptionButton.new()
	camera_scheme.name = "Option"
	camera_scheme.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	camera_scheme.add_item("A: 오른쪽 드래그 = 회전", 0)
	camera_scheme.add_item("B: 오른쪽 드래그 = 이동", 1)
	row.add_child(row_label)
	row.add_child(camera_scheme)
	map_help = Label.new()
	map_help.name = "WorldMapHelp"
	map_help.add_theme_font_size_override("font_size", 16)
	map_help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	for n in [divider, map_3d_enabled, row, map_help]:
		content.add_child(n)
		content.move_child(n, at)
		at += 1
	size = Vector2i(size.x, size.y + 190)
	map_3d_enabled.toggled.connect(_on_map_3d_toggled)
	camera_scheme.item_selected.connect(_on_camera_scheme_selected)


func _on_map_3d_toggled(enabled: bool) -> void:
	WorldMap3DSettings.set_wants_3d(enabled)
	get_tree().call_group(WorldMap3DSettings.HOST_GROUP, "apply_settings")
	_refresh()


func _on_camera_scheme_selected(index: int) -> void:
	WorldMap3DSettings.set_camera_scheme(CAMERA_SCHEMES[clampi(index, 0, CAMERA_SCHEMES.size() - 1)])
	get_tree().call_group(WorldMap3DSettings.HOST_GROUP, "apply_settings")
	_refresh()


func _refresh_worldmap_settings() -> void:
	if map_3d_enabled == null:
		return
	var available := WorldMap3DSettings.is_3d_available()
	map_3d_enabled.disabled = not available
	map_3d_enabled.set_pressed_no_signal(available and WorldMap3DSettings.wants_3d())
	var s := WorldMap3DSettings.camera_scheme()
	camera_scheme.select(1 if s == "B" else 0)   # "" = map default (EastAsia map_config input_scheme "A")
	camera_scheme.disabled = not available
	map_help.text = "공통: 왼쪽 클릭 선택 · 휠 확대 · WASD 이동 · Q/E 회전 · 가운데 드래그 이동. 설정은 바로 적용되고 다음 실행에도 유지돼요(게임 저장 파일과는 따로 저장)." if available 		else "3D 지도 파일이 없는 빌드라 2D 월드맵으로 고정돼요."


func _refresh() -> void:
	_refresh_worldmap_settings()
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
