extends Node

# Presentation only: never use the gameplay random generator.
const STREAMS := {
	"arrow": preload("res://assets/audio/sfx/arrow.wav"),
	"city_select": preload("res://assets/audio/sfx/city_select.wav"),
	"defeat": preload("res://assets/audio/sfx/defeat.wav"),
	"diplomacy": preload("res://assets/audio/sfx/diplomacy.wav"),
	"failure": preload("res://assets/audio/sfx/failure.wav"),
	"guard": preload("res://assets/audio/sfx/guard.wav"),
	"gunshot": preload("res://assets/audio/sfx/gunshot.wav"),
	"impact": preload("res://assets/audio/sfx/impact.wav"),
	"march": preload("res://assets/audio/sfx/march.wav"),
	"reinforcement": preload("res://assets/audio/sfx/reinforcement.wav"),
	"research": preload("res://assets/audio/sfx/research.wav"),
	"round_start": preload("res://assets/audio/sfx/round_start.wav"),
	"scroll": preload("res://assets/audio/sfx/scroll.wav"),
	"skill": preload("res://assets/audio/sfx/skill.wav"),
	"spy": preload("res://assets/audio/sfx/spy.wav"),
	"success": preload("res://assets/audio/sfx/success.wav"),
	"sword": preload("res://assets/audio/sfx/sword.wav"),
	"trade": preload("res://assets/audio/sfx/trade.wav"),
	"turn_end": preload("res://assets/audio/sfx/turn_end.wav"),
	"ui_click": preload("res://assets/audio/sfx/ui_click.wav"),
	"victory": preload("res://assets/audio/sfx/victory.wav"),
}

const SFX_BUS := "SamWarSFX"
const VIDEO_BUS := "SamWarVideo"
const MAX_VOICES := 8
const SETTINGS_PATH := "user://samwar_audio.cfg"
var _voices: Array[AudioStreamPlayer] = []
var _last_played: Dictionary = {}
var _rng := RandomNumberGenerator.new()
var _volume := 0.65
var _enabled := true
var _duplicate_limit_enabled := true
var _video_enabled := false
var _video_volume := 0.65

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_rng.randomize()
	_ensure_bus(SFX_BUS)
	_ensure_bus(VIDEO_BUS)
	var limiter := AudioEffectHardLimiter.new()
	limiter.ceiling_db = -1.0
	AudioServer.add_bus_effect(AudioServer.get_bus_index(SFX_BUS), limiter)
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) == OK:
		_volume = clampf(float(config.get_value("sfx", "volume", 0.65)), 0.0, 1.0)
		_enabled = bool(config.get_value("sfx", "enabled", true))
		_duplicate_limit_enabled = bool(config.get_value("sfx", "duplicate_limit", true))
		_video_enabled = bool(config.get_value("video", "enabled", false))
		_video_volume = clampf(float(config.get_value("video", "volume", 0.65)), 0.0, 1.0)
	_apply_settings()
	for index in range(MAX_VOICES):
		var voice := AudioStreamPlayer.new()
		voice.name = "SFXVoice%d" % index
		voice.bus = SFX_BUS
		add_child(voice)
		_voices.append(voice)
	get_tree().node_added.connect(_on_node_added)
	_scan(get_tree().root)

func _ensure_bus(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) >= 0:
		return
	AudioServer.add_bus()
	AudioServer.set_bus_name(AudioServer.bus_count - 1, bus_name)

func _scan(node: Node) -> void:
	_on_node_added(node)
	for child in node.get_children():
		_scan(child)

func _on_node_added(node: Node) -> void:
	if node is VideoStreamPlayer:
		# All video players share the system-menu volume and mute state.
		node.bus = VIDEO_BUS
		node.volume_db = 0.0
	elif node is BaseButton:
		var callback := Callable(self, "_on_button_pressed").bind(node)
		if not node.pressed.is_connected(callback):
			node.pressed.connect(callback)

func _on_button_pressed(button: BaseButton) -> void:
	if is_instance_valid(button) and not button.disabled and button.is_visible_in_tree():
		if not bool(button.get_meta("sfx_silent", false)):
			play_sfx("ui_click")

func play_sfx(event_id: String) -> void:
	if not _enabled or _volume <= 0.0 or not STREAMS.has(event_id):
		return
	var now := Time.get_ticks_msec()
	var interval := 160 if event_id in ["impact", "sword", "march", "gunshot", "arrow"] else 70
	if _duplicate_limit_enabled and now - int(_last_played.get(event_id, -10000)) < interval:
		return
	var chosen: AudioStreamPlayer = null
	for voice in _voices:
		if not voice.playing:
			chosen = voice
			break
	if chosen == null:
		return
	_last_played[event_id] = now
	chosen.stream = STREAMS[event_id]
	chosen.volume_db = -10.0 if event_id == "ui_click" else -4.0
	chosen.pitch_scale = _rng.randf_range(0.96, 1.04) if event_id in ["ui_click", "impact", "march", "sword"] else 1.0
	chosen.play()

func set_sfx_volume(value: float) -> void:
	_volume = clampf(value, 0.0, 1.0)
	_apply_settings()
	_save_settings()

func set_sfx_enabled(value: bool) -> void:
	_enabled = value
	_apply_settings()
	_save_settings()

func _apply_settings() -> void:
	var video_index := AudioServer.get_bus_index(VIDEO_BUS)
	AudioServer.set_bus_volume_db(video_index, linear_to_db(maxf(_video_volume, 0.0001)))
	AudioServer.set_bus_mute(video_index, not _video_enabled or _video_volume <= 0.0)
	var index := AudioServer.get_bus_index(SFX_BUS)
	AudioServer.set_bus_volume_db(index, linear_to_db(maxf(_volume, 0.0001)))
	AudioServer.set_bus_mute(index, not _enabled or _volume <= 0.0)
	if not _enabled or _volume <= 0.0:
		for voice in _voices:
			voice.stop()

func _save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("sfx", "volume", _volume)
	config.set_value("sfx", "enabled", _enabled)
	config.set_value("sfx", "duplicate_limit", _duplicate_limit_enabled)
	config.set_value("video", "enabled", _video_enabled)
	config.set_value("video", "volume", _video_volume)
	config.save(SETTINGS_PATH)

func is_sfx_enabled() -> bool:
	return _enabled

func get_sfx_volume() -> float:
	return _volume

func set_duplicate_limit_enabled(value: bool) -> void:
	_duplicate_limit_enabled = value
	_last_played.clear()
	_save_settings()

func is_duplicate_limit_enabled() -> bool:
	return _duplicate_limit_enabled

func set_video_enabled(value: bool) -> void:
	_video_enabled = value
	_apply_settings()
	_save_settings()

func is_video_enabled() -> bool:
	return _video_enabled

func set_video_volume(value: float) -> void:
	_video_volume = clampf(value, 0.0, 1.0)
	_apply_settings()
	_save_settings()

func get_video_volume() -> float:
	return _video_volume
