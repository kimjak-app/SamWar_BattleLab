class_name WorldMapHeroAdminRoleResolver
extends RefCounted

const HeroDefinitionRegistryScript := preload("res://scripts/worldmap/hero_definition_registry.gd")

const ROLE_LABELS := {
	"political": "정치형",
	"administrative": "행정형",
	"economic": "경제형",
	"militaryAdmin": "군정형",
}


static func resolve(hero_id: String) -> Dictionary:
	var normalized_id := hero_id.strip_edges()
	if normalized_id.is_empty():
		return {}
	var identity_variant: Variant = HeroDefinitionRegistryScript.LEGACY_IDENTITY_DATA.get(normalized_id, {})
	if identity_variant is Dictionary:
		var identity: Dictionary = identity_variant
		var primary_type := String(identity.get("chancellor_primary_type", ""))
		var secondary_type := String(identity.get("chancellor_secondary_type", ""))
		if not primary_type.is_empty() and not secondary_type.is_empty():
			return {
				"primary_label": String(ROLE_LABELS.get(primary_type, primary_type)),
				"primary_grade": maxi(1, int(identity.get("chancellor_primary_aptitude", 1))),
				"secondary_label": String(ROLE_LABELS.get(secondary_type, secondary_type)),
				"secondary_grade": maxi(1, int(identity.get("chancellor_secondary_aptitude", 1))),
			}

	# Defensive fallback: every authored WorldMap hero is expected to carry the
	# administrative role metadata above. Keep the UI non-empty if a future hero
	# is temporarily missing it, without touching gameplay state.
	return {
		"primary_label": "행정형",
		"primary_grade": 1,
		"secondary_label": "군정형",
		"secondary_grade": 1,
	}


static func format_summary(hero_id: String) -> String:
	var roles := resolve(hero_id)
	if roles.is_empty():
		return ""
	return "주: %s %d\n보조: %s %d" % [
		String(roles.get("primary_label", "행정형")),
		int(roles.get("primary_grade", 1)),
		String(roles.get("secondary_label", "군정형")),
		int(roles.get("secondary_grade", 1)),
	]
