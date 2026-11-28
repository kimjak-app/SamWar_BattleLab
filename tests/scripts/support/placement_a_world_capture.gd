extends RefCounted

## Queue 46 (addendum 7): what an old (pre-A) save must still load to - the same code captures it on main 60fd2a5
## (tools/make_placement_a_old_save_baseline.gd) and in test_worldmap_placement_a.gd.
##   owner and garrison of every one of the 65 cities, the player's owned heroes, every hero runtime state


static func world(main: Node) -> Dictionary:
	var owners := {}
	var stationed := {}
	var city_ids: Array = (main.get("CITY_HUD_DATA") as Dictionary).keys()
	city_ids.sort()
	for city_id in city_ids:
		var entry: Dictionary = main.call("_get_city_hud_entry", city_id)
		owners[str(city_id)] = str(entry.get("owner", ""))
		var ids: Array = []
		for hero_id in entry.get("stationed_hero_ids", entry.get("hero_ids", [])):
			ids.append(str(hero_id))
		stationed[str(city_id)] = ids
	var player_state: Dictionary = main.get("_player_state")
	var owned: Array = []
	for hero_id in player_state.get("owned_hero_ids", []):
		owned.append(str(hero_id))
	return {
		"owners": owners,
		"stationed": stationed,
		"owned_hero_ids": owned,
		"hero_runtime_states": JSON.stringify(main.get("_hero_runtime_states"), "", true),
	}
