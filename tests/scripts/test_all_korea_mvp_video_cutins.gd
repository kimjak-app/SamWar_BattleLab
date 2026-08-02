extends SceneTree

const PresentationScene := preload("res://scenes/ui/cutin/hero_cutin_presentation.tscn")
const Registry := preload("res://scripts/ui/cutin/korea_mvp_hero_cutin_registry.gd")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var entries := Registry.load_entries()
	if entries.size() != 13:
		printerr("KOREA MVP CUTIN FAILED expected=13 actual=%d" % entries.size())
		quit(1)
		return
	for entry in entries:
		if not await _play_and_check(entry):
			quit(1)
			return
	if not _check_chinese_static_fallback():
		quit(1)
		return
	print("ALL KOREA MVP VIDEO CUTINS GODOT PASS")
	quit(0)


func _play_and_check(entry: Dictionary) -> bool:
	var hero_id := Registry.canonicalize_hero_id(String(entry.get("hero_id", "")))
	var skill_id := String(entry.get("skill_id", ""))
	var resolved := Registry.find_entry(hero_id, skill_id)
	var portrait := ResourceLoader.load(Registry.get_portrait_path(hero_id)) as Texture2D
	var title := ResourceLoader.load(String(entry.get("skill_title_texture_path", ""))) as Texture2D
	var stream := ResourceLoader.load(String(entry.get("video_path", ""))) as VideoStream
	if resolved.is_empty() or portrait == null or title == null or stream == null:
		printerr("KOREA MVP CUTIN FAILED hero=%s registry=%s portrait=%s title=%s video=%s" % [hero_id, str(not resolved.is_empty()), str(portrait != null), str(title != null), str(stream != null)])
		return false
	var presentation := PresentationScene.instantiate()
	root.add_child(presentation)
	presentation.configure(String(entry.get("hero_name", "")), String(entry.get("dialogue", "")), stream, title)
	presentation.play_cutin()
	await process_frame
	await process_frame
	var player := presentation.get_node_or_null("CutinStage/VideoBackgroundPlayer") as VideoStreamPlayer
	var passed: bool = player != null and player.stream == stream and presentation.is_playing() and presentation.is_video_playing()
	print("MVP CUTIN hero=%s registry=%s portrait=%s title=%s ogv=%s stream_assigned=%s play_called=true is_playing=%s fallback=false" % [hero_id, str(not resolved.is_empty()), str(portrait != null), str(title != null), str(stream != null), str(player != null and player.stream == stream), str(passed)])
	presentation.queue_free()
	return passed


func _check_chinese_static_fallback() -> bool:
	var entry := Registry.find_entry("guan_yu", "guan_yu_unique")
	var passed: bool = entry.is_empty()
	print("CHINESE STATIC FALLBACK hero=guan_yu registry_miss=%s unrelated_video=false static_fallback=true" % str(passed))
	if not passed:
		printerr("CHINESE STATIC FALLBACK FAILED hero=guan_yu")
	return passed
