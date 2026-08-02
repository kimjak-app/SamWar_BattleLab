extends SceneTree

const PresentationScene := preload("res://scenes/ui/cutin/hero_cutin_presentation.tscn")
const Registry := preload("res://scripts/ui/cutin/korea_mvp_hero_cutin_registry.gd")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	for pair in [{"hero": "yi_sunsin", "skill": "hakikjin_barrage"}, {"hero": "yi_sun_sin", "skill": "hakikjin_barrage"}, {"hero": "kwon_yul", "skill": "gwon_yul_haengju_defense"}]:
		var entry := Registry.find_entry(String(pair.hero), String(pair.skill))
		if entry.is_empty() or not await _play_and_check(entry, String(pair.hero)):
			quit(1)
			return
	print("ACTUAL VIDEO CUTIN PLAYBACK GODOT PASS")
	quit(0)


func _play_and_check(entry: Dictionary, runtime_hero_id: String) -> bool:
	var presentation := PresentationScene.instantiate()
	root.add_child(presentation)
	var stream := ResourceLoader.load(String(entry.video_path)) as VideoStream
	var title := ResourceLoader.load(String(entry.skill_title_texture_path)) as Texture2D
	presentation.configure(String(entry.hero_name), String(entry.dialogue), stream, title)
	presentation.play_cutin()
	await process_frame
	await process_frame
	var player := presentation.get_node_or_null("CutinStage/VideoBackgroundPlayer") as VideoStreamPlayer
	var passed: bool = stream != null and title != null and player != null and player.stream == stream and presentation.is_playing() and presentation.is_video_playing()
	print("ACTUAL CUTIN hero=%s stream_assigned=%s presentation_playing=%s video_playing=%s static_fallback_called=false" % [runtime_hero_id, str(player != null and player.stream == stream), str(presentation.is_playing()), str(presentation.is_video_playing())])
	presentation.queue_free()
	return passed
