extends Node

## Production WorldMap registry -> city roster bridge.
##
## HeroDefinitionRegistry is the identity authority, while the current WorldMap
## still owns mutable city rosters in runtime dictionaries. This bridge closes
## that gap for newly added heroes without hard-coding every future addition in
## CITY_HUD_DATA.
##
## Safety contract:
## - seed only a registered hero with a valid assigned_city_id;
## - never seed a hero already stationed in any city;
## - never seed a hero that already has a runtime state (moved/deployed/captured
##   heroes therefore cannot be teleported back to their original city);
## - mirror both stationed_hero_ids and hero_ids for legacy/current callers.

const HeroDefinitionRegistryScript := preload("res://scripts/worldmap/hero_definition_registry.gd")

var _seed_attempts := 0
const MAX_DEFERRED_SEED_ATTEMPTS := 3


func _ready() -> void:
	call_deferred("_seed_missing_registered_heroes")


func _seed_missing_registered_heroes() -> void:
	var worldmap := get_parent()
	if worldmap == null:
		return
	var city_states_variant: Variant = worldmap.get("_city_runtime_states")
	var hero_states_variant: Variant = worldmap.get("_hero_runtime_states")
	if not city_states_variant is Dictionary or not hero_states_variant is Dictionary:
		_retry_seed_if_needed()
		return
	var city_states: Dictionary = city_states_variant
	var hero_states: Dictionary = hero_states_variant
	if city_states.is_empty():
		_retry_seed_if_needed()
		return

	var stationed_ids := {}
	for city_id_variant in city_states.keys():
		var city_id := String(city_id_variant)
		var city_variant: Variant = city_states.get(city_id, {})
		if not city_variant is Dictionary:
			continue
		var city: Dictionary = city_variant
		for hero_id_variant in city.get("stationed_hero_ids", city.get("hero_ids", [])):
			stationed_ids[String(hero_id_variant)] = true

	var seeded_by_city := {}
	var player_owned_additions: Array[String] = []
	for hero_id_variant in HeroDefinitionRegistryScript.HERO_DATA.keys():
		var hero_id := String(hero_id_variant)
		if hero_id.is_empty() or stationed_ids.has(hero_id) or hero_states.has(hero_id):
			continue
		var hero_variant: Variant = HeroDefinitionRegistryScript.HERO_DATA.get(hero_id, {})
		if not hero_variant is Dictionary:
			continue
		var hero: Dictionary = hero_variant
		var city_id := String(hero.get("assigned_city_id", hero.get("city_id", hero.get("location_city_id", ""))))
		if city_id.is_empty() or not city_states.has(city_id):
			continue
		var city_variant: Variant = city_states.get(city_id, {})
		if not city_variant is Dictionary:
			continue
		var city: Dictionary = city_variant
		var roster := _normalized_string_array(city.get("stationed_hero_ids", city.get("hero_ids", [])))
		if not roster.has(hero_id):
			roster.append(hero_id)
		city["stationed_hero_ids"] = roster
		city["hero_ids"] = roster.duplicate()
		city_states[city_id] = city

		var owner_id := String(city.get("owner", city.get("nation", hero.get("faction_id", ""))))
		hero_states[hero_id] = {
			"current_city_id": city_id,
			"city_id": city_id,
			"location_city_id": city_id,
			"status": "normal",
			"side": owner_id,
			"nation": owner_id,
			"faction_id": owner_id,
		}
		stationed_ids[hero_id] = true
		if not seeded_by_city.has(city_id):
			seeded_by_city[city_id] = []
		(seeded_by_city[city_id] as Array).append(hero_id)
		if String(hero.get("side", "")) == "player" or owner_id == "player":
			player_owned_additions.append(hero_id)

	worldmap.set("_city_runtime_states", city_states)
	worldmap.set("_hero_runtime_states", hero_states)
	_sync_player_owned_heroes(worldmap, player_owned_additions)
	if worldmap.has_method("_refresh_city_hud_data_bindings"):
		worldmap.call("_refresh_city_hud_data_bindings")
	if not seeded_by_city.is_empty():
		print("[REGISTERED_HERO_CITY_SEED] seeded=%s" % str(seeded_by_city))


func _sync_player_owned_heroes(worldmap: Node, additions: Array[String]) -> void:
	if additions.is_empty():
		return
	var player_state_variant: Variant = worldmap.get("_player_state")
	if not player_state_variant is Dictionary:
		return
	var player_state: Dictionary = player_state_variant
	var owned := _normalized_string_array(player_state.get("owned_hero_ids", []))
	for hero_id in additions:
		if not owned.has(hero_id):
			owned.append(hero_id)
	player_state["owned_hero_ids"] = owned
	worldmap.set("_player_state", player_state)


func _normalized_string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if not value is Array:
		return result
	for item in value:
		var text := String(item)
		if not text.is_empty() and not result.has(text):
			result.append(text)
	return result


func _retry_seed_if_needed() -> void:
	_seed_attempts += 1
	if _seed_attempts < MAX_DEFERRED_SEED_ATTEMPTS:
		call_deferred("_seed_missing_registered_heroes")
