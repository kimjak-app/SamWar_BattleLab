extends SceneTree

const PresentationScene := preload("res://scenes/ui/cutin/hero_cutin_presentation.tscn")
const Registry := preload("res://scripts/ui/cutin/korea_mvp_hero_cutin_registry.gd")

const CASES := [
	{"state": "ally_main_unit_state", "runtime": "yi_sunsin", "name": "이순신", "canonical": "yi_sun_sin", "skill": "hakikjin_barrage"},
	{"state": "ally_support_unit_state", "runtime": "jeong_dojeon", "name": "정도전", "canonical": "jeong_do_jeon", "skill": "reform_order"},
	{"state": "ally_reinforce_01_unit_state", "runtime": "gim_yusin", "name": "김유신", "canonical": "kim_yu_sin", "skill": "kim_yu_sin_unification_charge"},
	{"state": "ally_main_03_unit_state", "runtime": "kwon_yul", "name": "권율", "canonical": "kwon_yul", "skill": "gwon_yul_haengju_defense"},
]


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	for item in CASES:
		if not await _check_case(item):
			quit(1)
			return
	print("RUNTIME HERO ID / CUTIN BOUNDARY GODOT PASS")
	quit(0)


func _check_case(item: Dictionary) -> bool:
	var runtime_id := String(item.runtime)
	var display_name := String(item.name)
	var canonical_id := Registry.canonicalize_hero_id(runtime_id)
	var expected_runtime := String(item.runtime)
	var expected_name := String(item.name)
	var expected_canonical := String(item.canonical)
	var runtime_pass := runtime_id == expected_runtime and display_name == expected_name and display_name != "지원군 선봉"
	var entry := Registry.find_entry(canonical_id, String(item.skill))
	var playback_pass := not entry.is_empty() and await _play_video(entry)
	print("RUNTIME BOUNDARY hero=%s runtime_id=%s registry_fixture=true display=%s fallback_name=false canonical=%s cutin=%s" % [expected_name, runtime_id, display_name, canonical_id, str(playback_pass)])
	return runtime_pass and canonical_id == expected_canonical and playback_pass


func _play_video(entry: Dictionary) -> bool:
	var presentation := PresentationScene.instantiate()
	root.add_child(presentation)
	var stream := ResourceLoader.load(String(entry.get("video_path", ""))) as VideoStream
	var title := ResourceLoader.load(String(entry.get("skill_title_texture_path", ""))) as Texture2D
	if stream == null or title == null:
		presentation.queue_free()
		return false
	presentation.configure(String(entry.get("hero_name", "")), String(entry.get("dialogue", "")), stream, title)
	presentation.play_cutin()
	await process_frame
	await process_frame
	var player := presentation.get_node_or_null("CutinStage/VideoBackgroundPlayer") as VideoStreamPlayer
	var passed: bool = player != null and player.stream == stream and presentation.is_video_playing()
	presentation.queue_free()
	return passed
