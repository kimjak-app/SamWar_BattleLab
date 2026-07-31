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

# Authoritative WorldMap hero records retain their canonical `hero_id` and
# faction metadata through battle settlement.  The production portrait atlas
# follows the same canonical naming contract, so resolve it before considering
# an old demo-only compatibility filename.  This is intentionally keyed by
# runtime faction metadata, never by display name.
const AUTHORITATIVE_PORTRAIT_REGION_BY_FACTION := {
	"goryeo_joseon": "korea",
	"goguryeo": "korea",
	"silla": "korea",
	"baekje_faction": "korea",
	"chu": "china",
	"wei": "china",
	"shu": "china",
	"wu": "china",
	"oda": "japan",
	"toyotomi": "japan",
	"kyushu_faction": "japan",
	"tokugawa": "japan",
	"mongol_faction": "mongol",
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
	var authoritative_path := _get_authoritative_portrait_path(hero_id, hero_data)
	if not authoritative_path.is_empty():
		return authoritative_path
	if COMPATIBILITY_PORTRAIT_PATHS.has(hero_id):
		return _resolve_existing_texture_path(COMPATIBILITY_PORTRAIT_PATHS[hero_id])

	return ""


static func _get_authoritative_portrait_path(hero_id: String, hero_data: Dictionary) -> String:
	if hero_id.is_empty():
		return ""
	var faction_id := str(hero_data.get("faction_id", hero_data.get("force_id", hero_data.get("nation", hero_data.get("side", ""))))).strip_edges()
	var region := str(AUTHORITATIVE_PORTRAIT_REGION_BY_FACTION.get(faction_id, ""))
	if region.is_empty():
		return ""
	return _resolve_existing_texture_path("res://assets/heroes/portraits/%s/%s_%s.png" % [region, region, hero_id])


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
