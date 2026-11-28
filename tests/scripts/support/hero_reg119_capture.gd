extends RefCounted

## Queue 45: what must not change when the 119 heroes are registered - the same code captures it on the base commit
## (tools/make_hero_reg119_baseline.gd, run on 6b6bc2f) and in test_hero_register_119.gd.
##   definitions: HeroDefinitionRegistry.get_hero(id) of each given id, as sorted-key JSON text
##   world: city garrisons (stationed_hero_ids per city), the player's owned heroes, every hero runtime state, and which
##          heroes sit in an unclaimed (owner "") city


static func definitions(hero_ids: Array) -> Dictionary:
	var result := {}
	for hero_id in hero_ids:
		result[str(hero_id)] = JSON.stringify(HeroDefinitionRegistry.get_hero(str(hero_id)), "", true)
	return result


static func world(main: Node) -> Dictionary:
	var cities: Dictionary = main.get("_city_runtime_states")
	var stationed := {}
	var unclaimed := {}
	var city_ids := cities.keys()
	city_ids.sort()
	for city_id in city_ids:
		var city: Dictionary = cities[city_id] if cities[city_id] is Dictionary else {}
		var ids: Array = []
		for hero_id in city.get("stationed_hero_ids", city.get("hero_ids", [])):
			ids.append(str(hero_id))
		stationed[str(city_id)] = ids
		if str(city.get("owner", "")).is_empty() and not ids.is_empty():
			unclaimed[str(city_id)] = ids
	var player_state: Dictionary = main.get("_player_state")
	var owned: Array = []
	for hero_id in player_state.get("owned_hero_ids", []):
		owned.append(str(hero_id))
	var hero_states: Dictionary = main.get("_hero_runtime_states")
	return {
		"stationed": stationed,
		"owned_hero_ids": owned,
		"hero_runtime_states": JSON.stringify(hero_states, "", true),
		"unclaimed_with_heroes": unclaimed,
	}
