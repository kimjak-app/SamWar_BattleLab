class_name WorldMapPlacementA
extends RefCounted

## Queue 46 (PLACEMENT_A): 김작 11-28 08:52 "배치는 a 수정안" (Drive 67) as the new-game start data.
## 39 cities get an owner, a governor and a garrison; the other 26 of the 65 stay unclaimed ("", no heroes,
## WorldMapUnclaimedCityRules). Source: data/heroes/source/placement_A_revised_20261128.json, with the name -> id
## tables next to it (placement_A_city_ids_*.csv, placement_A_hero_ids_*.csv).
##
## - The 13 legacy cities keep their city values (troops, population, ...); only owner / governor / garrison are set.
## - The 26 newly filled cities take troops / population / grade from the JSON and carry values_status "proposal"
##   (the source marks them "추가 검토"). Those static values are re-applied when a placement-A save is loaded,
##   because the save keeps owner / troops / garrison but not population / grade.
## - The 44 legacy heroes are moved here (their runtime state); the 119 new heroes carry the city in their definition
##   (placement_id = PLACEMENT_ID) and are stationed by RegisteredHeroCitySeeder, which only seeds them in a world
##   whose _player_state.world_placement_id is PLACEMENT_ID. An old (pre-A) save has no marker: it loads as saved,
##   with the old placement ("옛 저장은 옛 배치 유지").
## - A hero listed in two cities, an unknown hero / city, or a governor not in its garrison is a data error: nothing
##   is applied and the errors are printed as [PLACEMENT_A_ERROR] (no city is picked for the hero).

const PLACEMENT_ID := "placement_A_revised_20261128"
const SOURCE_PATH := "res://data/heroes/source/placement_A_revised_20261128.json"
const CITY_IDS_PATH := "res://data/heroes/source/placement_A_city_ids_20261128.csv"
const HERO_IDS_PATH := "res://data/heroes/source/placement_A_hero_ids_20261128.csv"
const LEGACY_GROUP_PREFIX := "기존 13성"
const VALUES_STATUS_PROPOSAL := "proposal"
const GOVERNOR_UNDECIDED_PREFIX := "미정"


## {ok, errors: [String], cities: {city_id: {...}}, city_order: [city_id], faction_ids: [sorted]}
static func load_placement(hero_data: Dictionary, city_data: Dictionary) -> Dictionary:
	var errors: Array[String] = []
	var source: Variant = JSON.parse_string(FileAccess.get_file_as_string(SOURCE_PATH)) if FileAccess.file_exists(SOURCE_PATH) else null
	if not source is Dictionary:
		return {"ok": false, "errors": ["source missing or unreadable: %s" % SOURCE_PATH], "cities": {}, "city_order": [], "faction_ids": []}
	var city_ids := _read_csv_map(CITY_IDS_PATH, "city_name", "city_id")
	var hero_ids := _read_csv_map(HERO_IDS_PATH, "hero_name", "hero_id")
	var cities := {}
	var city_order: Array[String] = []
	var hero_city := {}
	var factions := {}
	for entry_variant in (source as Dictionary).get("cities", []):
		var entry: Dictionary = entry_variant
		var city_name := str(entry.get("city", ""))
		var city_id := str(city_ids.get(city_name, ""))
		if city_id.is_empty() or not city_data.has(city_id):
			errors.append("unknown city %s" % city_name)
			continue
		if cities.has(city_id):
			errors.append("city listed twice %s" % city_id)
			continue
		var stationed: Array[String] = []
		for hero_variant in entry.get("stationed", []):
			var hero_name := str((hero_variant as Dictionary).get("name", ""))
			var hero_id := str(hero_ids.get(hero_name, ""))
			if hero_id.is_empty() or not hero_data.has(hero_id):
				errors.append("unknown hero %s (%s)" % [hero_name, city_id])
				continue
			if hero_city.has(hero_id):
				errors.append("hero %s in two cities: %s, %s" % [hero_id, hero_city[hero_id], city_id])
				continue
			hero_city[hero_id] = city_id
			stationed.append(hero_id)
		var governor_name := str(entry.get("governor", ""))
		var governor_id := ""
		if not governor_name.begins_with(GOVERNOR_UNDECIDED_PREFIX):
			governor_id = str(hero_ids.get(governor_name, ""))
			if governor_id.is_empty() or not stationed.has(governor_id):
				errors.append("governor %s not in the garrison of %s" % [governor_name, city_id])
		var faction_id := str(entry.get("faction_id", ""))
		if faction_id.is_empty():
			errors.append("no faction for %s" % city_id)
		factions[faction_id] = true
		cities[city_id] = {
			"city_id": city_id,
			"name": city_name,
			"legacy": str(entry.get("group", "")).begins_with(LEGACY_GROUP_PREFIX),
			"faction_id": faction_id,
			"governor_id": governor_id,
			"governor_source": governor_name,
			"stationed": stationed,
			"troops": int(str(entry.get("troops", "0"))),
			"population": int(str(entry.get("population", "0"))),
			"grade": int(str(entry.get("grade", "0"))),
			"capital": str(entry.get("capital", "false")) == "true",
			"home_city": str(entry.get("home_city", "")),
		}
		city_order.append(city_id)
	var faction_ids: Array = factions.keys()
	faction_ids.sort()
	return {"ok": errors.is_empty(), "errors": errors, "cities": cities, "city_order": city_order, "faction_ids": faction_ids, "hero_city": hero_city}


## New game: owner / governor / garrison of the 39 cities, the 44 legacy heroes' runtime states, the world marker.
## The 119 new heroes are left to the seeder (their definitions hold the city). Returns false (nothing applied) on
## a data error.
static func apply_new_game(main: Node) -> bool:
	var hero_data: Dictionary = HeroDefinitionRegistry.HERO_DATA
	var city_hud_data: Dictionary = main.get("CITY_HUD_DATA")
	var placement := load_placement(hero_data, city_hud_data)
	if not bool(placement.ok):
		for error in placement.errors:
			push_error("[PLACEMENT_A_ERROR] %s" % error)
			print("[PLACEMENT_A_ERROR] %s" % error)
		return false
	var city_states: Dictionary = main.get("_city_runtime_states")
	var hero_states: Dictionary = main.get("_hero_runtime_states")
	# No hero keeps an old garrison: every one of the 163 is placed by this data (44 here, 119 by the seeder).
	for city_id in city_states.keys():
		var old_city: Dictionary = city_states[city_id]
		old_city["stationed_hero_ids"] = []
		old_city["hero_ids"] = []
	hero_states.clear()
	for city_id in placement.city_order:
		var entry: Dictionary = placement.cities[city_id]
		var city: Dictionary = (city_states.get(city_id, city_hud_data.get(city_id, {})) as Dictionary).duplicate(true)
		var owner_id := str(entry.faction_id)
		city["owner"] = owner_id
		city["nation"] = owner_id
		city["owner_faction_id"] = owner_id
		city["faction"] = owner_id
		city["governor_id"] = str(entry.governor_id)
		var legacy_ids: Array[String] = []
		for hero_id in entry.stationed:
			if not _is_seeded_by_definition(hero_data.get(hero_id, {})):
				legacy_ids.append(hero_id)
				hero_states[hero_id] = {
					"current_city_id": city_id,
					"city_id": city_id,
					"location_city_id": city_id,
					"status": "normal",
					"side": owner_id,
					"nation": owner_id,
					"faction_id": owner_id,
				}
		city["stationed_hero_ids"] = legacy_ids
		city["hero_ids"] = legacy_ids.duplicate()
		if not bool(entry.legacy):
			city["troops"] = int(entry.troops)
		_apply_static_values(city, entry)
		city_states[city_id] = city
	var player_state: Dictionary = main.get("_player_state")
	player_state["world_placement_id"] = PLACEMENT_ID
	var player_faction_id := str(main.call("_get_current_player_faction_id"))
	var owned: Array = []
	for city_id in placement.city_order:
		if str(placement.cities[city_id].faction_id) == player_faction_id:
			for hero_id in (city_states[city_id] as Dictionary).stationed_hero_ids:
				owned.append(hero_id)
	player_state["owned_hero_ids"] = owned
	main.set("_city_runtime_states", city_states)
	main.set("_hero_runtime_states", hero_states)
	main.set("_player_state", player_state)
	print("[PLACEMENT_A] cities=%d factions=%d legacy_heroes=%d" % [placement.city_order.size(), placement.faction_ids.size(), hero_states.size()])
	return true


## Load of a placement-A save: population / grade / capital / values_status are not in the save; put them back.
## Owner, troops and garrison come from the save and are not touched. Does nothing for an old (pre-A) save.
static func restore_static_values(main: Node) -> void:
	var player_state: Dictionary = main.get("_player_state")
	if str(player_state.get("world_placement_id", "")) != PLACEMENT_ID:
		return
	var city_hud_data: Dictionary = main.get("CITY_HUD_DATA")
	var placement := load_placement(HeroDefinitionRegistry.HERO_DATA, city_hud_data)
	var city_states: Dictionary = main.get("_city_runtime_states")
	for city_id in placement.city_order:
		var city: Dictionary = (city_states.get(city_id, city_hud_data.get(city_id, {})) as Dictionary).duplicate(true)
		_apply_static_values(city, placement.cities[city_id])
		city_states[city_id] = city
	main.set("_city_runtime_states", city_states)


static func is_placement_world(player_state: Dictionary) -> bool:
	return str(player_state.get("world_placement_id", "")) == PLACEMENT_ID


static func _apply_static_values(city: Dictionary, entry: Dictionary) -> void:
	city["capital"] = bool(entry.capital)
	if bool(entry.legacy):
		return
	city["population"] = int(entry.population)
	city["grade"] = int(entry.grade)
	city["values_status"] = VALUES_STATUS_PROPOSAL
	city["military"] = "도시 주둔군 %d / 방어력 %d (제안 값)" % [int(city.get("troops", entry.troops)), int(city.get("defense", 1))]
	city["rating"] = "배치 A 제안 값(추가 검토)"


## The 119 new heroes carry the placement in their definition and are stationed by RegisteredHeroCitySeeder.
static func _is_seeded_by_definition(hero: Dictionary) -> bool:
	return str(hero.get("placement_id", "")) == PLACEMENT_ID


static func _read_csv_map(path: String, key_column: String, value_column: String) -> Dictionary:
	var result := {}
	if not FileAccess.file_exists(path):
		return result
	var lines := FileAccess.get_file_as_string(path).strip_edges().split("\n")
	var header := lines[0].strip_edges().split(",")
	var key_index := header.find(key_column)
	var value_index := header.find(value_column)
	for i in range(1, lines.size()):
		var cells := lines[i].strip_edges().split(",")
		if cells.size() > maxi(key_index, value_index):
			result[cells[key_index]] = cells[value_index]
	return result
