extends RefCounted
# Queue 35: a naval scenario file (data/battle3d/naval_*_scenario.json) for the 3D battle shell. Plain reads only: the
# scenario, the engine start setup built from it (reply 1 keys) and the island cells of its sea board.
const PLAY_SIZE := Vector2i(18, 10) # lab_heightfield.gd PLAY_SIZE

static func load_scenario(path: String) -> Dictionary:
	if path.is_empty() or not FileAccess.file_exists(path): return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed if parsed is Dictionary else {}

static func board_paths(scenario: Dictionary) -> Dictionary:
	# What lab_heightfield.gd reads in place of the land board.
	return {"heightfield":String(scenario.get("heightfield", "")), "terrain_types":String(scenario.get("terrain_types", ""))}

static func island_cells(scenario: Dictionary) -> Array:
	# The play area's island cells ([x, y]), from the scenario's terrain types file.
	var cells := []
	var path := String(scenario.get("terrain_types", ""))
	if not FileAccess.file_exists(path): return cells
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not parsed is Dictionary: return cells
	var rows: Array = parsed.get("cells", [])
	for y in range(mini(PLAY_SIZE.y, rows.size())):
		for x in range(mini(PLAY_SIZE.x, (rows[y] as Array).size())):
			if String(rows[y][x]) == "island": cells.append([x, y])
	return cells

static func engine_setup(scenario: Dictionary) -> Dictionary:
	# The engine start setup (samwar_battle_setup): battle type, every ship's type / hero / troops / cell / facing by the
	# engine's default unit id, the island cells the start cells must avoid, and the reinforcement slots on the board
	# from round 1.
	var overrides := {}
	for ship in scenario.get("ships", []):
		var entry := {}
		for key in ["unit_type", "hero_id", "grid_cell", "facing"]:
			if ship.has(key): entry[key] = ship[key]
		if ship.has("troops"): entry["troops"] = int(ship.troops)
		overrides[String(ship.engine_unit_id)] = entry
	return {"battle_type":String(scenario.get("battle_type", "naval")), "unit_overrides":overrides, "blocked_cells":island_cells(scenario),
		"arrival_round_overrides":(scenario.get("arrival_round_overrides", {}) as Dictionary).duplicate(true)}
