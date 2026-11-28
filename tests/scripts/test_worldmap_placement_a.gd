extends SceneTree

# Queue 46 [PLACEMENT_A]: 배치 A 수정안 (39 cities, 34 factions, 163 heroes) + gameplay links on the 0.7 roads.
# Real WorldMap.tscn, new game as 조선 ("player").
#  1. new game: owner / governor / garrison of the 39 cities equal the JSON; 163 stationed, no duplicate; the 26
#     unclaimed cities hold no hero; 34 factions each own >= 1 city; legacy city values unchanged, new city values from
#     the JSON with values_status "proposal"; markers carry the runtime owner
#  2. manual slot and turn checkpoint: save -> reset -> load gives the same world as 1
#  3. links: the gameplay graph equals the 0.7 rule data the 3D roads read (100 land + 20 sea, both directions);
#     상도–평양 / 상도–업성 gone both ways
#  4. first sortie table (채비서 48, 72): each of the 34 factions, as the acting faction on turn 1, has >= 1 foreign
#     city that passes the real sortie check (_get_player_attack_block_reason); 경주–고령, 상도–대도, 성도–라싸 both ways
#  5. sea route: without warship research the sortie is refused for the naval reason, with it it passes
#  6. three AI-only turns: no crash; table of the 1-city factions after 3 turns (information only)
#  7. new factions (no capital included): turn end, AI turn list, storage text, victory check without errors
#  8. the 9 new-type skills (채비서 85) in a real battle: charge 72 % splash on the ring around the target, mounted buff
#     inside the radius only (any unit type), command debuff 2 turns + enemy momentum drop; description mismatches listed

const Placement := preload("res://scripts/worldmap/worldmap_placement_a.gd")
const RosterService := preload("res://scripts/worldmap/worldmap_city_roster_service.gd")
const Supply := preload("res://scripts/t02/expedition_supply_calculator.gd")
const HARNESS_PATH := "res://tests/scripts/support/battle_tactic_oracle_harness.gd"  # load() at run time: it needs the autoloads
const WORLDMAP_SCENE_PATH := "res://WorldMap.tscn"
const MAP_CONFIG := "res://worldmap3d/maps/eastasia/map_config.json"
const MANUAL_SAVE := "user://worldmap_manual_save.json"
const CHECKPOINT_SAVE := "user://worldmap_left_panel_state.json"
const OLD_DIRECT := [["karakorum", "pyeongyang"], ["karakorum", "yecheng"]]
const FIRST_ROADS := [["gyeongju", "goryeong"], ["karakorum", "dadu"], ["chengdu", "lhasa"]]
const SEA_PAIR := ["sabi", "gaeseong"]
const CHARGE := ["sanada_yukimura", "shimazu_iehisa", "a_zhu", "xiahou_yuan", "qapaghan_khagan"]
const MOUNTED := ["go_yeon_mu", "anfiyanggu", "bilge_khagan"]
const DEBUFF := ["dae_mun_ye"]
## Words a description must carry for the engine behaviour checked in 8.
const DESCRIPTION_WORDS := {"charge_aoe": ["인접"], "mounted_team_buff": ["이동", "측후방", "기세"], "command_debuff": ["공격", "방어", "기세"]}


class ErrorCounter extends Logger:
	var errors: Array[String] = []
	func _log_error(function: String, file: String, line: int, code: String, rationale: String, _editor_notify: bool, error_type: int, _script_backtraces: Array[ScriptBacktrace]) -> void:
		if error_type == ERROR_TYPE_WARNING or file.contains("worldmap3d") or code.contains("worldmap3d") or code.contains("[PLACEMENT_A]"):
			return
		errors.append("%s:%d %s %s %s" % [file, line, function, code, rationale])
	func _log_message(_message: String, _error: bool) -> void:
		pass


var _checks := 0
var _failures: Array[String] = []
var _main: Node
var _placement: Dictionary
var _session: Node
var _logger := ErrorCounter.new()
var _saved_files := {}


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	OS.add_logger(_logger)
	root.size = Vector2i(1920, 1080)
	_session = root.get_node("/root/GameSession")
	_backup_saves()
	_expect(bool(_session.call("request_new_game", "player")), "new game requested")
	change_scene_to_file(WORLDMAP_SCENE_PATH)
	for i in 10:
		await process_frame
	_main = current_scene
	_placement = Placement.load_placement(HeroDefinitionRegistry.HERO_DATA, _main.get("CITY_HUD_DATA"))
	_expect(bool(_placement.ok) and _placement.city_order.size() == 39 and _placement.faction_ids.size() == 34 and _placement.hero_city.size() == 163,
		"placement data: 39 cities, 34 factions, 163 heroes, no error %s" % str(_placement.errors))
	_check_world("1. new game")
	var snapshot := _snapshot()
	await _check_save_load(snapshot)
	_check_links()
	_check_first_sortie()
	_check_sea_route()
	var errors_before_turns := _logger.errors.size()
	_check_turns()
	_check_new_factions(errors_before_turns)
	_restore_saves()
	await _check_skills()
	OS.remove_logger(_logger)
	_finish()


# ---------------------------------------------------------------- 1
func _check_world(label: String) -> void:
	var hud: Dictionary = _main.get("CITY_HUD_DATA")
	var markers: Dictionary = _main.get("_city_markers_by_id")
	var bad: Array = []
	var seen := {}
	var dup: Array = []
	var faction_cities := {}
	for city_id in hud:
		var entry: Dictionary = _main.call("_get_city_hud_entry", city_id)
		for hero_id in entry.get("stationed_hero_ids", []):
			if seen.has(hero_id):
				dup.append(hero_id)
			seen[hero_id] = city_id
		var owner := str(entry.get("owner", ""))
		if not owner.is_empty():
			faction_cities[owner] = int(faction_cities.get(owner, 0)) + 1
		if markers.has(city_id) and str((markers[city_id] as WorldMapCityMarker).owner_faction_id) != owner:
			bad.append("marker %s %s != %s" % [city_id, (markers[city_id] as WorldMapCityMarker).owner_faction_id, owner])
		if _placement.cities.has(city_id):
			var want: Dictionary = _placement.cities[city_id]
			var have_ids: Array = entry.get("stationed_hero_ids", []).duplicate()
			var want_ids: Array = want.stationed.duplicate()
			have_ids.sort()
			want_ids.sort()
			if owner != str(want.faction_id) or str(entry.get("governor_id", "")) != str(want.governor_id) or have_ids != want_ids:
				bad.append("%s owner %s governor %s heroes %d/%d" % [city_id, owner, entry.get("governor_id"), have_ids.size(), want_ids.size()])
			var base: Dictionary = hud[city_id]
			if bool(want.legacy):
				if int(entry.get("population", -1)) != int(base.population) or (label.begins_with("1.") and int(entry.get("troops", -1)) != int(base.troops)) or entry.has("values_status"):
					bad.append("legacy values %s" % city_id)
			elif int(entry.get("population", -1)) != int(want.population) or int(entry.get("grade", -1)) != int(want.grade) \
					or str(entry.get("values_status", "")) != Placement.VALUES_STATUS_PROPOSAL or int(entry.get("troops", -1)) != int(want.troops):
				bad.append("new values %s pop %s grade %s troops %s" % [city_id, entry.get("population"), entry.get("grade"), entry.get("troops")])
			if bool(entry.get("capital", false)) != bool(want.capital):
				bad.append("capital %s" % city_id)
		elif not owner.is_empty() or not (entry.get("stationed_hero_ids", []) as Array).is_empty():
			bad.append("unclaimed %s owner %s heroes %s" % [city_id, owner, str(entry.get("stationed_hero_ids"))])
	_expect(bad.is_empty(), "%s: 39 cities as the JSON, 26 unclaimed empty, markers = runtime owner %s" % [label, str(bad.slice(0, 6))])
	_expect(seen.size() == 163 and dup.is_empty(), "%s: 163 stationed, duplicates %s" % [label, str(dup)])
	var missing: Array = []
	for faction_id in _placement.faction_ids:
		if int(faction_cities.get(faction_id, 0)) < 1:
			missing.append(faction_id)
	_expect(missing.is_empty() and faction_cities.size() == 34, "%s: 34 factions each own >= 1 city %s" % [label, str(missing)])
	var hero_states: Dictionary = _main.get("_hero_runtime_states")
	var wrong: Array = []
	for hero_id in _placement.hero_city:
		var city_id: String = _placement.hero_city[hero_id]
		var state: Dictionary = hero_states.get(hero_id, {})
		if str(state.get("current_city_id", "")) != city_id or str(state.get("faction_id", "")) != str(_placement.cities[city_id].faction_id):
			wrong.append(hero_id)
	_expect(wrong.is_empty(), "%s: every hero's runtime city and faction follow its garrison %s" % [label, str(wrong.slice(0, 6))])
	var owned: Array = (_main.get("_player_state") as Dictionary).get("owned_hero_ids", []).duplicate()
	var want_owned: Array = []
	for city_id in _placement.city_order:
		if str(_placement.cities[city_id].faction_id) == "player":
			want_owned.append_array(_placement.cities[city_id].stationed)
	owned.sort()
	want_owned.sort()
	_expect(owned == want_owned, "%s: the player owns the heroes of 한성 + 개성 (%d)" % [label, owned.size()])
	_expect(str((_main.get("_player_state") as Dictionary).get("world_placement_id", "")) == Placement.PLACEMENT_ID, "%s: world marker %s" % [label, Placement.PLACEMENT_ID])


func _snapshot() -> String:
	var cities := {}
	for city_id in _main.get("CITY_HUD_DATA"):
		var entry: Dictionary = _main.call("_get_city_hud_entry", city_id)
		cities[city_id] = [entry.get("owner", ""), entry.get("governor_id", ""), entry.get("stationed_hero_ids", []), entry.get("troops", 0), entry.get("population", 0), entry.get("grade", 0), entry.get("values_status", ""), entry.get("capital", false)]
	var player_state: Dictionary = _main.get("_player_state")
	return JSON.stringify({"cities": cities, "owned": player_state.get("owned_hero_ids", []), "heroes": _main.call("_serialize_worldmap_hero_runtime_state"), "placement": player_state.get("world_placement_id", "")}, "", true)


# ---------------------------------------------------------------- 2
func _check_save_load(snapshot: String) -> void:
	_expect(bool(_main.call("_save_worldmap_manual_slot_mvp")), "2. manual slot saved")
	_expect(bool(_main.call("_checkpoint_worldmap_state_mvp")), "2. turn checkpoint saved")
	for path in [MANUAL_SAVE, CHECKPOINT_SAVE]:
		_main.call("_reset_worldmap_state")
		_expect(_snapshot() != snapshot, "2. reset changes the world (%s)" % path)
		_main.call("_load_worldmap_state", path)
		await process_frame
		_expect(_snapshot() == snapshot, "2. %s loads the new-game world" % path)
		_check_world("2. %s" % path.get_file())


# ---------------------------------------------------------------- 3
func _check_links() -> void:
	# WorldMapConfig resolves rule_data next to map_config.json (worldmap_config.gd _res).
	var rule_path := MAP_CONFIG.get_base_dir().path_join(str((JSON.parse_string(FileAccess.get_file_as_string(MAP_CONFIG)) as Dictionary).get("rule_data", "")))
	_expect(rule_path.simplify_path() == RosterService.RULE_DATA_PATH, "3. the gameplay links and the 3D roads read the same file (%s)" % rule_path)
	var rules: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(RosterService.RULE_DATA_PATH))
	var want := {}
	for pair in rules.roads:
		want[_key(pair[0], pair[1])] = "land"
	for pair in rules.sea_routes:
		want[_key(pair[0], pair[1])] = "sea"
	_expect(rules.roads.size() == 100 and rules.sea_routes.size() == 20 and want.size() == 120, "3. 0.7 data: 100 land + 20 sea, 120 distinct pairs")
	var have := {}
	var one_way: Array = []
	var type_bad: Array = []
	for city_id in _main.get("CITY_HUD_DATA"):
		for neighbor_id in _main.call("_get_city_neighbors_mvp", city_id):
			have[_key(city_id, neighbor_id)] = true
			if not (_main.call("_get_city_neighbors_mvp", neighbor_id) as Array).has(city_id):
				one_way.append("%s>%s" % [city_id, neighbor_id])
			var route_type := str(_main.call("_get_city_route_type_between_mvp", city_id, neighbor_id))
			if route_type != str(want.get(_key(city_id, neighbor_id), "")) or str(_main.call("_get_city_route_type_between_mvp", neighbor_id, city_id)) != route_type:
				type_bad.append("%s-%s %s" % [city_id, neighbor_id, route_type])
	var extra: Array = have.keys().filter(func(k): return not want.has(k))
	var lost: Array = want.keys().filter(func(k): return not have.has(k))
	_expect(extra.is_empty() and lost.is_empty(), "3. gameplay graph == 0.7 data (extra %s, missing %s)" % [str(extra), str(lost)])
	_expect(one_way.is_empty(), "3. every link both ways %s" % str(one_way))
	_expect(type_bad.is_empty(), "3. route types land / sea as the data, same both ways %s" % str(type_bad))
	var land := want.values().filter(func(t): return t == "land").size()
	_expect(land == 100 and want.size() - land == 20, "3. sortie graph: 100 land + 20 sea")
	_expect(RosterService.load_links().size() == 65, "3. the link table covers the 65 cities")
	for pair in OLD_DIRECT:
		_expect(not (_main.call("_get_city_neighbors_mvp", pair[0]) as Array).has(pair[1]) and not (_main.call("_get_city_neighbors_mvp", pair[1]) as Array).has(pair[0]),
			"3. old direct link %s–%s gone both ways" % pair)


# ---------------------------------------------------------------- 4
func _check_first_sortie() -> void:
	var lines: Array[String] = ["[PLACEMENT_A] first sortie table: faction | cities | heroes | open targets | supply 100 (gold / food) at the sources"]
	var no_target: Array = []
	for faction_id in _placement.faction_ids:
		var cities: Array = _placement.city_order.filter(func(c): return str(_placement.cities[c].faction_id) == faction_id)
		var heroes := 0
		var targets: Array[String] = []
		var refused: Array[String] = []
		var supply: Array[String] = []
		_as_faction(faction_id)
		for city_id in cities:
			heroes += (_placement.cities[city_id].stationed as Array).size()
			for neighbor_id in _main.call("_get_city_neighbors_mvp", city_id):
				var owner := str(_main.call("_get_city_owner_id_for_battle_context", neighbor_id))
				if owner.is_empty() or owner == faction_id:
					continue
				_main.get("_player_state")["origin_city_id"] = city_id
				var reason := str(_main.call("_get_player_attack_block_reason", neighbor_id))
				if reason.is_empty() and not targets.has(neighbor_id):
					targets.append(neighbor_id)
				elif not reason.is_empty():
					refused.append("%s>%s: %s" % [city_id, neighbor_id, reason])
			var stock: Dictionary = (_main.call("_get_city_hud_entry", city_id) as Dictionary).get("resource_stock", {})
			var food := int(stock.get("rice", 0)) + int(stock.get("barley", 0)) + int(stock.get("seafood", 0))
			var ok := int(stock.get("gold", 0)) >= Supply.minimum_gold(100) and food >= Supply.minimum_food(100)
			supply.append("%s %s(%d/%d)" % [city_id, "ok" if ok else "부족", int(stock.get("gold", 0)), food])
		_as_faction("player")
		if targets.is_empty():
			no_target.append(faction_id)
		lines.append("  %s | %d | %d | %s | %s" % [faction_id, cities.size(), heroes, ", ".join(targets) if not targets.is_empty() else "없음", "; ".join(supply)])
		if targets.is_empty():
			lines.append("      refused: " + " / ".join(refused))
	print("\n".join(lines))
	_expect(no_target.is_empty(), "4. all 34 factions have a first-turn sortie target %s" % str(no_target))
	for pair in FIRST_ROADS:
		for dir in [[pair[0], pair[1]], [pair[1], pair[0]]]:
			var faction_id := str(_main.call("_get_city_owner_id_for_battle_context", dir[0]))
			_as_faction(faction_id)
			_main.get("_player_state")["origin_city_id"] = dir[0]
			var source := str(_main.call("_find_player_attack_source_city", dir[1]))
			var reason := str(_main.call("_get_player_attack_block_reason", dir[1]))
			_as_faction("player")
			_expect(source == dir[0] and reason.is_empty(), "4. %s (%s) -> %s passes the sortie check (%s)" % [dir[0], faction_id, dir[1], reason])


## The acting faction for the real sortie check: the ids a new game as that faction sets (GameSession and the saved
## player_faction_id that _get_current_player_faction_id reads first).
func _as_faction(faction_id: String) -> void:
	_session.set("player_faction_id", faction_id)
	(_main.get("_player_state") as Dictionary)["player_faction_id"] = faction_id


# ---------------------------------------------------------------- 5
func _check_sea_route() -> void:
	var source: String = SEA_PAIR[0]
	var target: String = SEA_PAIR[1]
	_expect(bool(_main.call("_is_naval_attack_route_mvp", source, target)), "5. %s–%s is a sea route" % SEA_PAIR)
	var faction_id := str(_main.call("_get_city_owner_id_for_battle_context", source))
	_as_faction(faction_id)
	_main.get("_player_state")["origin_city_id"] = source
	var without := str(_main.call("_get_player_attack_block_reason", target))
	var completed: Dictionary = _main.get("_player_state").get("city_domestic_tech_completed", {})
	var before: Variant = completed.get(source, null)
	completed[source] = {"naval_warship_building": true}
	_main.get("_player_state")["city_domestic_tech_completed"] = completed
	var with_tech := str(_main.call("_get_player_attack_block_reason", target))
	if before == null:
		completed.erase(source)
	else:
		completed[source] = before
	_as_faction("player")
	_expect(without.contains("전투선"), "5. %s without warship research: sea sortie refused (%s)" % [faction_id, without])
	_expect(with_tech.is_empty(), "5. %s with warship research: sea sortie passes (%s)" % [faction_id, with_tech])
	# Land control on the same faction: 사비–한성 is land, no research needed.
	_as_faction(faction_id)
	_expect(not bool(_main.call("_is_naval_attack_route_mvp", "sabi", "hanseong")) and str(_main.call("_get_player_attack_block_reason", "hanseong")).is_empty(), "5. control: land 사비 -> 한성 passes without research")
	_as_faction("player")


# ---------------------------------------------------------------- 6
func _check_turns() -> void:
	var start_turn := int((_main.get("_player_state") as Dictionary).get("turn_number", 1))
	for i in 3:
		_end_turn()
	_expect(int((_main.get("_player_state") as Dictionary).get("turn_number", 1)) == start_turn + 3, "6. three AI-only turns advanced without a crash")
	var lines: Array[String] = ["[PLACEMENT_A] 1-city factions after 3 turns: faction | city | owner now | troops | heroes | gold | food"]
	for faction_id in _placement.faction_ids:
		var cities: Array = _placement.city_order.filter(func(c): return str(_placement.cities[c].faction_id) == faction_id)
		if cities.size() != 1:
			continue
		var entry: Dictionary = _main.call("_get_city_hud_entry", cities[0])
		var stock: Dictionary = entry.get("resource_stock", {})
		lines.append("  %s | %s | %s | %d | %d | %d | %d" % [faction_id, cities[0], entry.get("owner", ""), int(entry.get("troops", 0)), (entry.get("stationed_hero_ids", []) as Array).size(),
			int(stock.get("gold", 0)), int(stock.get("rice", 0)) + int(stock.get("barley", 0)) + int(stock.get("seafood", 0))])
	print("\n".join(lines))


# ---------------------------------------------------------------- 7
func _check_new_factions(errors_before_turns: int) -> void:
	var labels: Dictionary = _main.get("FACTION_LABELS")
	var new_factions: Array = _placement.faction_ids.filter(func(f): return not labels.has(f))
	var capitals := {}
	for city_id in _placement.city_order:
		if bool(_placement.cities[city_id].capital):
			capitals[_placement.cities[city_id].faction_id] = true
	var without_capital: Array = _placement.faction_ids.filter(func(f): return not capitals.has(f))
	_expect(new_factions.size() == 21 and without_capital.size() == 30, "7. 21 new factions, 30 factions without a capital (%d, %d)" % [new_factions.size(), without_capital.size()])
	var ai_ids: Array = _main.call("_get_enemy_faction_ids_for_turn_mvp")
	var not_in_ai: Array = new_factions.filter(func(f): return not ai_ids.has(f) and not (_main.call("_get_enemy_owned_city_ids_for_faction", f) as Array).is_empty())
	_expect(not_in_ai.is_empty(), "7. every new faction that holds a city takes its AI turn %s" % str(not_in_ai))
	var storage_bad: Array = []
	for city_id in _placement.city_order:
		if not new_factions.has(_placement.cities[city_id].faction_id):
			continue
		var text := WorldMapHudConnectPresenter.format_city_storage(_main, city_id, "own")
		var baseline: Dictionary = _main.call("_get_enemy_city_economy_baseline_mvp", _main.call("_get_city_hud_entry", city_id))
		if text != WorldMapHudConnectPresenter.NO_INFO or str(baseline.get("reason", "")) == "not_enemy_city":
			storage_bad.append("%s %s %s" % [city_id, text, baseline.get("reason", "")])
	_expect(storage_bad.is_empty(), "7. storage text of new-faction cities: 정보 없음 (정탐 필요), enemy baseline ok %s" % str(storage_bad.slice(0, 4)))
	var outcome: Dictionary = _main.call("_evaluate_korea_mvp_outcome_mvp")
	_expect(str(outcome.get("status", "")) == "active", "7. victory check runs, game active (%s)" % str(outcome.get("status")))
	var turn_errors: Array = _logger.errors.slice(errors_before_turns)
	_expect(turn_errors.is_empty(), "7. no engine / script error during the three turns and the checks %s" % str(turn_errors.slice(0, 4)))
	_expect(_logger.errors.is_empty(), "no engine / script error in the whole world part %s" % str(_logger.errors.slice(0, 4)))


# ---------------------------------------------------------------- 8
func _check_skills() -> void:
	var harness_script: GDScript = load(HARNESS_PATH)
	var harness = harness_script.new()
	harness.tag = "[PLACEMENT_A]"
	var mismatches: Array[String] = []
	for hero_id in CHARGE + MOUNTED + DEBUFF:
		var skill: Dictionary = harness.skill_by_id(hero_id + "_unique")
		_expect(not skill.is_empty(), "8. %s skill found" % hero_id)
		if skill.is_empty():
			continue
		await _run_skill(harness, hero_id, skill)
		for word in DESCRIPTION_WORDS.get(str(skill.effect_type), []):
			if not str(skill.description).contains(word):
				mismatches.append("%s (%s) \"%s\": no \"%s\"" % [hero_id, skill.effect_type, skill.description, word])
	print("[PLACEMENT_A] description mismatches (not fixed in queue 46):\n  " + ("\n  ".join(mismatches) if not mismatches.is_empty() else "없음"))
	for failure in harness.failures:
		_failures.append(failure)
	_checks += harness.checks


func _run_skill(harness, hero_id: String, skill: Dictionary) -> void:
	var battle = load("res://scenes/battle/Battle_Main.tscn").instantiate()
	battle.set_script(harness.SeamBattle)
	root.add_child(battle)
	await process_frame
	battle.call("_skip_battle_intro_camera_zoom")
	var units: Array[BattleUnitState] = battle.get("all_battle_unit_states")
	harness._board(battle, units)
	var effect_type := str(skill.effect_type)
	var momentum = battle.get("battle_momentum")
	momentum.gain("ally", 10, "fixture")
	momentum.gain("enemy", 5, "fixture")
	var radius := int(skill.get("radius", 0))
	if effect_type == "mounted_team_buff":
		# Units 3 / 4 are round-3 reinforcements (not on the field): the deployed allies are 0..2. Inside the radius the
		# caster (infantry) and an archer at the radius edge; outside, a gunner one cell past the radius; enemies far.
		harness._setup_unit(units[1], "archer", Vector2i(8 - radius, 4))
		harness._setup_unit(units[2], "gunner", Vector2i(8, 4 + radius + 1))
		for i in [5, 6, 7]:
			harness._setup_unit(units[i], "infantry", Vector2i(17, 2 + i))
	elif effect_type == "charge_aoe":
		# Primary at distance 3; enemies on the ring around it (distance 1) and one at distance 2 from it.
		harness._setup_unit(units[5], "infantry", Vector2i(11, 4))
		harness._setup_unit(units[6], "infantry", Vector2i(12, 4))
		harness._setup_unit(units[7], "infantry", Vector2i(11, 5))
		harness._setup_unit(units[8], "infantry", Vector2i(13, 4))
		harness._setup_unit(units[9], "infantry", Vector2i(11, 7))
	units[0].unique_skill_definition = skill
	harness._sync(battle, units)
	battle.call("_select_ally_unit", units[0], false, false, false)
	await process_frame
	var primary: BattleUnitState = units[0] if str(skill.target_mode).begins_with("self") else units[5]
	var plan: Dictionary = (load("res://scripts/battle/battle_skill_resolver.gd") as GDScript).build_plan(units[0], skill, units, primary, momentum.get_value("ally"), "land")
	_expect(bool(plan.get("ok", false)), "8. %s engine plan ok (%s)" % [hero_id, plan.get("reason", "")])
	var enemy_momentum_before: int = momentum.get_value("enemy")
	battle.call("_on_unique_skill_button_pressed")
	if not battle.call("_should_unique_skill_resolve_without_manual_target", battle.call("_get_unique_skill_for_unit", units[0])):
		battle.call("_try_use_unique_skill_on_target", primary)
	# Watch every frame from the cast until the ally turn is back: the effects are checked when they land, before the
	# enemy turn that follows (its momentum gain and status ticks are not this skill's effect).
	var seen_status := {}
	var enemy_momentum_min := enemy_momentum_before
	var deadline := Time.get_ticks_msec() + 30000
	var stable := 0
	while Time.get_ticks_msec() < deadline and stable < 30:
		await process_frame
		if str(battle.get("current_phase")) != "enemy_turn":
			enemy_momentum_min = mini(enemy_momentum_min, momentum.get_value("enemy"))
			for i in units.size():
				for status_id in units[i].status_effects:
					seen_status["%d:%s" % [i, status_id]] = true
		if str(battle.get("current_phase")) == "enemy_turn":
			break
		stable = stable + 1 if harness.settled_now(battle) else 0
	await harness.settle(self, battle, "8. " + hero_id)
	match effect_type:
		"charge_aoe":
			var main_damage := 0
			var splash := {}
			for command in plan.get("commands", []):
				if command.type == "damage":
					if command.target_unit_id == units[5].unit_id:
						main_damage = int(command.amount)
					else:
						splash[command.target_unit_id] = int(command.amount)
			var want := maxi(1, int(round(float(main_damage) * 0.72)))
			_expect(splash.size() == 2 and splash.get(units[6].unit_id, -1) == want and splash.get(units[7].unit_id, -1) == want,
				"8. %s: splash on the 2 ring enemies = 72%% of %d (%s)" % [hero_id, main_damage, str(splash)])
			_expect(not splash.has(units[8].unit_id) and not splash.has(units[9].unit_id), "8. %s: no splash at distance 2+" % hero_id)
			_expect(units[5].current_hp < 300 and units[6].current_hp < 300 and units[7].current_hp < 300 and units[8].current_hp == 300, "8. %s: the real cast hit the target and the ring only" % hero_id)
		"mounted_team_buff":
			var inside_ok := true
			for i in [0, 1]:
				for status_id in ["mobility_up", "flank_damage_up", "momentum_gain_up"]:
					inside_ok = inside_ok and seen_status.has("%d:%s" % [i, status_id])
			var outside_clean := true
			for status_id in ["mobility_up", "flank_damage_up", "momentum_gain_up"]:
				outside_clean = outside_clean and not seen_status.has("2:" + status_id)
			_expect(inside_ok, "8. %s: mobility / flank damage / momentum gain on the allies in radius %d (infantry caster, archer at the edge) %s" % [hero_id, radius, str(seen_status.keys())])
			_expect(outside_clean, "8. %s: no buff on the gunner one cell outside the radius" % hero_id)
		"command_debuff":
			var turns_ok := true
			for command in plan.get("commands", []):
				if command.type == "status":
					turns_ok = turns_ok and int(command.turns) == 2
			_expect(seen_status.has("5:attack_defense_down") and seen_status.has("5:momentum_gain_down") and turns_ok,
				"8. %s: attack / defense and momentum gain down for 2 turns %s" % [hero_id, str(seen_status.keys())])
			_expect(enemy_momentum_min < enemy_momentum_before, "8. %s: enemy momentum drops at once (%d -> %d)" % [hero_id, enemy_momentum_before, enemy_momentum_min])
	await harness._teardown(self, battle)


# ---------------------------------------------------------------- helpers
func _end_turn() -> void:
	var turn_controller = _main.call("_ensure_turn_controller")
	(_main.get("_player_state") as Dictionary)["pending_invasion_event"] = {}
	turn_controller.call("request_end_turn")
	turn_controller.call("finish_enemy_turn")
	(_main.get("_player_state") as Dictionary)["pending_invasion_event"] = {}
	_main.call("_clear_pending_invasion_event_mvp")


func _key(a: String, b: String) -> String:
	return a + "|" + b if a < b else b + "|" + a


func _backup_saves() -> void:
	for path in [MANUAL_SAVE, CHECKPOINT_SAVE]:
		_saved_files[path] = FileAccess.get_file_as_string(path) if FileAccess.file_exists(path) else null


func _restore_saves() -> void:
	for path in _saved_files:
		if _saved_files[path] == null:
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
		else:
			var file := FileAccess.open(path, FileAccess.WRITE)
			file.store_string(_saved_files[path])


func _expect(ok: bool, label: String) -> void:
	_checks += 1
	if not ok:
		_failures.append(label)
		push_error("[PLACEMENT_A] FAIL: " + label)


func _finish() -> void:
	print("[PLACEMENT_A] checks=%d failures=%s" % [_checks, str(_failures)])
	quit(0 if _failures.is_empty() else 1)
