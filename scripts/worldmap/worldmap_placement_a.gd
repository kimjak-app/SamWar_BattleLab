class_name WorldMapPlacementA
extends RefCounted

## Queue 46 (PLACEMENT_A): 김작 11-28 08:52 "배치는 a 수정안" (Drive 67) as the new-game start data.
## 39 cities get an owner, a governor and a garrison; the other 26 of the 65 stay unclaimed ("", no heroes,
## WorldMapUnclaimedCityRules). Addendum 9: the game reads ONE runtime file, data/worldmap/placement_a_runtime.json
## (exported; built from the working sources in data/heroes/source/ - which has a .gdignore - by
## tools/make_placement_a_runtime.py, kept byte-identical by tools/validate_placement_a_runtime.py).
## If the placement cannot be applied the new game does NOT go on with the old placement: a full-screen error stops
## the start (title button only).
##
## - The 13 legacy cities keep their city values (troops, population, ...); only owner / governor / garrison are set.
## - The 26 newly filled cities take troops / population / grade from the JSON and carry values_status "proposal"
##   (the source marks them "추가 검토"). Those static values are re-applied when a placement-A save is loaded,
##   because the save keeps owner / troops / garrison but not population / grade.
## - The 44 legacy heroes are moved here (their runtime state); the 119 new heroes carry the city in their definition
##   (placement_id = PLACEMENT_ID) and are stationed by RegisteredHeroCitySeeder, which only seeds them in a world
##   whose _player_state.world_placement_id is PLACEMENT_ID. An old (pre-A) save has no marker: it loads as saved,
##   with the old placement ("옛 저장은 옛 배치 유지").
## - Governors come from the JSON, except an undecided one ("미정 …": 한성, 김작 has not chosen) - that city keeps the
##   governor it has in main. capital is a string in the JSON: only "true" is true.
## - A hero listed in two cities, an unknown hero / city, or a governor not in its garrison is a data error: nothing
##   is applied and the errors are printed as [PLACEMENT_A_ERROR] (no city is picked for the hero).

const PLACEMENT_ID := "placement_A_revised_20261128"
const RUNTIME_PATH := "res://data/worldmap/placement_a_runtime.json"
const START_ERROR_META := "placement_a_start_error"
const START_ERROR_LAYER := 120
const VALUES_STATUS_PROPOSAL := "proposal"
const GOVERNOR_UNDECIDED_PREFIX := "미정"


## Tests point this at a missing file to check the loud failure (addendum 9); "" = RUNTIME_PATH.
static var runtime_path_override := ""


## {ok, errors: [String], cities: {city_id: {...}}, city_order: [city_id], faction_ids: [sorted], hero_city}
static func load_placement(hero_data: Dictionary, city_data: Dictionary) -> Dictionary:
	var errors: Array[String] = []
	var path := runtime_path_override if not runtime_path_override.is_empty() else RUNTIME_PATH
	var source: Variant = JSON.parse_string(FileAccess.get_file_as_string(path)) if FileAccess.file_exists(path) else null
	if not source is Dictionary or str((source as Dictionary).get("placement_id", "")) != PLACEMENT_ID:
		return {"ok": false, "errors": ["runtime placement file missing or unreadable: %s" % path], "cities": {}, "city_order": [], "faction_ids": [], "hero_city": {}}
	var cities := {}
	var city_order: Array[String] = []
	var hero_city := {}
	var factions := {}
	for entry_variant in (source as Dictionary).get("cities", []):
		var entry: Dictionary = entry_variant
		var city_id := str(entry.get("city_id", ""))
		if city_id.is_empty() or not city_data.has(city_id):
			errors.append("unknown city %s" % city_id)
			continue
		if cities.has(city_id):
			errors.append("city listed twice %s" % city_id)
			continue
		var stationed: Array[String] = []
		for hero_variant in entry.get("stationed", []):
			var hero_id := str(hero_variant)
			if not hero_data.has(hero_id):
				errors.append("unknown hero %s (%s)" % [hero_id, city_id])
				continue
			if hero_city.has(hero_id):
				errors.append("hero %s in two cities: %s, %s" % [hero_id, hero_city[hero_id], city_id])
				continue
			hero_city[hero_id] = city_id
			stationed.append(hero_id)
		var governor_source := str(entry.get("governor_source", ""))
		var governor_id := str(entry.get("governor_id", ""))
		if not governor_source.begins_with(GOVERNOR_UNDECIDED_PREFIX) and not stationed.has(governor_id):
			errors.append("governor %s not in the garrison of %s" % [governor_id, city_id])
		var faction_id := str(entry.get("faction_id", ""))
		if faction_id.is_empty():
			errors.append("no faction for %s" % city_id)
		factions[faction_id] = true
		cities[city_id] = {
			"city_id": city_id,
			"name": str(entry.get("name", city_id)),
			"legacy": bool(entry.get("legacy", false)),
			"faction_id": faction_id,
			"governor_id": governor_id,
			"governor_source": governor_source,
			"stationed": stationed,
			"troops": int(entry.get("troops", 0)),
			"population": int(entry.get("population", 0)),
			"grade": int(entry.get("grade", 0)),
			"capital": entry.get("capital", false) == true,   # the runtime file stores a bool; only true is a capital
			"home_city": str(entry.get("home_city", "")),
			"city_values": (entry.get("city_values", {}) as Dictionary).duplicate(true) if entry.get("city_values", {}) is Dictionary else {},
		}
		if not bool(cities[city_id].legacy) and (cities[city_id].city_values as Dictionary).is_empty():
			errors.append("no city_values for new city %s" % city_id)
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
		_stop_start(main, placement.errors)
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
		# Addendum 7-3: an undecided governor ("미정 …", 한성) is not taken from the JSON; the city keeps main's value.
		if not str(entry.governor_source).begins_with(GOVERNOR_UNDECIDED_PREFIX):
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
			_apply_start_stock(city, entry)
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


## Load of a placement-A save: population / grade / capital / values_status / ratings / resource seeds (static values)
## are put back. Owner, troops, garrison and the stock (resource_stock, queue 47: the saved stock wins over the start
## values) come from the save and are not touched. Does nothing for an old (pre-A) save.
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
	# Queue 47: ratings and resource seeds (static; the seeds not in city_values - horses, silk, specialty - stay).
	var values: Dictionary = entry.get("city_values", {})
	if values.is_empty():
		return
	city["population_rating"] = int(values.population_rating)
	city["commerce_rating"] = int(values.commerce_rating)
	var seed: Dictionary = (city.get("resource_seed", {}) as Dictionary).duplicate(true) if city.get("resource_seed", {}) is Dictionary else {}
	for key in (values.resource_seed as Dictionary):
		seed[key] = int(values.resource_seed[key])
	city["resource_seed"] = seed
	city["resources"] = resource_seed_text(seed)


## Queue 47, new game only: the start gold and food of a new city (Drive 104 A). The stock is rebuilt right after
## apply_new_game by the city stock seeder (WorldMapCityResourceService.build_supply_resource_defaults: food split by
## the rice / barley / seafood seeds, salt = seed x 20), so an older empty stock is dropped here.
static func _apply_start_stock(city: Dictionary, entry: Dictionary) -> void:
	var values: Dictionary = entry.get("city_values", {})
	if values.is_empty():
		return
	city["gold"] = int(values.gold)
	city["food"] = int(values.food)
	city.erase("resource_stock")


## The legacy cities' "resources" line: 쌀 ★★ / 보리 ★ / … ("-" for 0).
static func resource_seed_text(seed: Dictionary) -> String:
	var parts: Array[String] = []
	for pair in [["rice", "쌀"], ["barley", "보리"], ["seafood", "수산물"], ["wood", "목재"], ["iron", "철"], ["horses", "말"], ["silk", "비단"], ["salt", "소금"]]:
		var count := int(seed.get(pair[0], 0))
		parts.append("%s %s" % [pair[1], "★".repeat(count) if count > 0 else "-"])
	return " / ".join(parts)


## The 119 new heroes carry the placement in their definition and are stationed by RegisteredHeroCitySeeder.
static func _is_seeded_by_definition(hero: Dictionary) -> bool:
	return str(hero.get("placement_id", "")) == PLACEMENT_ID


## Addendum 9: the start stops loudly - a full-screen error over the world map (it takes every click), the reasons,
## and a button back to the first screen. The world is not marked as a placement-A world.
static func _stop_start(main: Node, errors: Array) -> void:
	main.set_meta(START_ERROR_META, errors.duplicate())
	var layer := CanvasLayer.new()
	layer.name = "PlacementAStartError"
	layer.layer = START_ERROR_LAYER
	var blocker := ColorRect.new()
	blocker.color = Color(0.02, 0.02, 0.03, 0.92)
	blocker.set_anchors_preset(Control.PRESET_FULL_RECT)
	blocker.mouse_filter = Control.MOUSE_FILTER_STOP
	layer.add_child(blocker)
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.add_theme_constant_override("separation", 12)
	blocker.add_child(box)
	var label := Label.new()
	label.name = "Message"
	label.text = "새 게임을 시작할 수 없습니다: 배치 A 자료를 적용하지 못했습니다.\n" + "\n".join(errors.slice(0, 8))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(label)
	var button := Button.new()
	button.name = "BackToTitle"
	button.text = "처음 화면으로"
	button.pressed.connect(func(): main.get_tree().change_scene_to_file(str(ProjectSettings.get_setting("application/run/main_scene", ""))))
	box.add_child(button)
	main.add_child(layer)


static func start_error(main: Node) -> Array:
	return main.get_meta(START_ERROR_META, []) as Array
