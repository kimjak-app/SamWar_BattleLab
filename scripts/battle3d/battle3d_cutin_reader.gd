extends RefCounted
# HUD block 5: the approved read-only access to the 2D hero cut-in registry
# (KoreaMvpHeroCutinRegistry, a static class outside the engine that reads its
# two JSON files once into its own static cache). Only canonicalize_hero_id,
# find_entry and get_static_fallback_image_path are called; entries come back
# as copies.
const Registry := preload("res://scripts/ui/cutin/korea_mvp_hero_cutin_registry.gd")

static func canonical_hero(hero_id: String) -> String:
	return Registry.canonicalize_hero_id(hero_id)

static func entry_for(hero_id: String, skill_id: String) -> Dictionary:
	# The registry entry (video, title picture, name, dialogue, offsets) or {} for a hero without a cut-in video.
	return Registry.find_entry(hero_id, skill_id).duplicate(true)

static func fallback_image(hero_id: String, skill_id: String) -> String:
	# The 2D still picture for a skill without a cut-in video (the 2D unique-skill toast).
	return Registry.get_static_fallback_image_path(hero_id, skill_id)
