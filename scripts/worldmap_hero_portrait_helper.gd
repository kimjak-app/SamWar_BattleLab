class_name WorldMapHeroPortraitHelper
extends RefCounted

# v0.68b-12b-10b WorldMap Hero Portrait Asset Binding MVP

const PORTRAIT_FIELD_ORDER := [
	"portrait_image",
	"portrait_path",
	"portrait",
	"portraitPath",
	"portraitImage",
	"image_path",
	"image",
]

const COMPATIBILITY_PORTRAIT_PATHS := {
	"eulji_mundeok": "res://assets/web_battle/portraits/eulji_mundeok_portrait.png",
	"kim_yu_sin": "res://assets/web_battle/portraits/gim_yusin_portrait.png",
	"kwon_yul": "res://assets/web_battle/portraits/kwon_yul_portrait.png",
	"xiahou_dun": "res://assets/web_battle/portraits/xiahou_dun_portrait.png",
	"liu_bei": "res://assets/web_battle/portraits/liu_bei_portrait.png",
	"zhuge_liang": "res://assets/web_battle/portraits/zhuge_liang_portrait.png",
}


static func get_hero_portrait_path(hero_data: Dictionary) -> String:
	if hero_data.is_empty():
		return ""

	for field_name in PORTRAIT_FIELD_ORDER:
		var raw_path := str(hero_data.get(field_name, "")).strip_edges()
		var resolved_path := _resolve_existing_texture_path(raw_path)
		if not resolved_path.is_empty():
			return resolved_path

	var hero_id := str(hero_data.get("hero_id", hero_data.get("id", ""))).strip_edges()
	if COMPATIBILITY_PORTRAIT_PATHS.has(hero_id):
		return _resolve_existing_texture_path(COMPATIBILITY_PORTRAIT_PATHS[hero_id])

	return ""


static func load_hero_portrait_texture(hero_data: Dictionary) -> Texture2D:
	var portrait_path := get_hero_portrait_path(hero_data)
	if portrait_path.is_empty():
		return null

	var resource := ResourceLoader.load(portrait_path)
	if resource is Texture2D:
		return resource
	return null


static func apply_hero_portrait_or_placeholder(texture_rect: TextureRect, fallback_label: Label, hero_data: Dictionary) -> bool:
	var texture := load_hero_portrait_texture(hero_data)
	if texture != null:
		if texture_rect != null:
			texture_rect.texture = texture
			texture_rect.visible = true
		if fallback_label != null:
			fallback_label.text = ""
			fallback_label.visible = false
		return true

	if texture_rect != null:
		texture_rect.texture = null
		texture_rect.visible = false
	if fallback_label != null:
		fallback_label.text = "?"
		fallback_label.visible = true
	return false


static func _resolve_existing_texture_path(raw_path: String) -> String:
	if raw_path.is_empty():
		return ""

	var candidates: Array[String] = []
	_add_candidate(candidates, raw_path)
	if not raw_path.begins_with("res://"):
		_add_candidate(candidates, "res://" + raw_path)

	var res_path := raw_path
	if res_path.begins_with("res://"):
		res_path = res_path.trim_prefix("res://")
	_add_candidate(candidates, "res://" + res_path.replace("assets/portraits/", "assets/web_battle/portraits/"))
	_add_candidate(candidates, "res://" + res_path.replace("assets/portraits_battlefield/", "assets/web_battle/portraits_battlefield/"))

	for candidate in candidates:
		if ResourceLoader.exists(candidate):
			return candidate
	return ""


static func _add_candidate(candidates: Array[String], candidate: String) -> void:
	if candidate.is_empty() or candidates.has(candidate):
		return
	candidates.append(candidate)
