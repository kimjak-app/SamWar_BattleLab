extends SceneTree

const GENERATED_SKILLS_PATH := "res://data/heroes/generated/hero_unique_skills.json"
const Registry := preload("res://scripts/ui/cutin/korea_mvp_hero_cutin_registry.gd")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(GENERATED_SKILLS_PATH))
	if not parsed is Dictionary:
		push_error("CUTIN PARITY FAIL: generated skill data did not parse")
		quit(1)
		return
	var skills: Array = parsed.get("skills", [])
	var registry_count := 0
	var fallback_count := 0
	for raw_skill in skills:
		var skill: Dictionary = raw_skill
		var hero_id := String(skill.get("hero_id", ""))
		var skill_id := String(skill.get("skill_id", ""))
		var entry := Registry.find_entry(hero_id, skill_id)
		if not entry.is_empty():
			var video := ResourceLoader.load(String(entry.get("video_path", ""))) as VideoStream
			var title := ResourceLoader.load(String(entry.get("skill_title_texture_path", ""))) as Texture2D
			if video == null or title == null:
				push_error("CUTIN PARITY FAIL: registry resource_load_failed hero=%s skill=%s" % [hero_id, skill_id])
				quit(1)
				return
			registry_count += 1
			continue
		var fallback_path := Registry.get_static_fallback_image_path(hero_id, skill_id)
		var fallback_texture := ResourceLoader.load(fallback_path) as Texture2D
		if fallback_texture == null:
			push_error("CUTIN PARITY FAIL: fallback missing hero=%s skill=%s path=%s" % [hero_id, skill_id, fallback_path])
			quit(1)
			return
		fallback_count += 1
	print("CUTIN PARITY PASS: generated=%d registry_video=%d static_fallback=%d unresolved=0" % [skills.size(), registry_count, fallback_count])
	quit(0)
