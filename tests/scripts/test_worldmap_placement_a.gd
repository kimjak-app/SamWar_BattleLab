extends SceneTree

# Queue 46 [PLACEMENT_A]: 배치 A 수정안 (39 cities, 34 factions, 163 heroes) + gameplay links on the 0.7 roads.
# Real WorldMap.tscn, new game as 조선 ("player").
#  1. new game: owner / governor / garrison of the 39 cities equal the JSON; 163 stationed, no duplicate; the 26
#     unclaimed cities hold no hero; 34 factions each own >= 1 city; legacy city values unchanged, new city values from
#     the JSON with values_status "proposal"; markers carry the runtime owner
#  2. (addendum 7) loads into a fresh WorldMap through the title and system-menu paths: an A save gives the world of 1
#     (39 / 34 / 163 once each), a moved hero stays moved, old 60fd2a5 saves load exactly as on 60fd2a5
#  3. links: the gameplay graph equals the 0.7 rule data the 3D roads read (100 land + 20 sea, both directions);
#     상도–평양 / 상도–업성 gone both ways
#  4. (addendum 8) first sortie tables, one line per direction: the attack window (route, block reason) and the real
#     sortie (deployment, supply, confirm validation, battle context); per-faction counts; 경주↔고령, 상도↔대도,
#     성도↔라싸 each direction. Factions with no real sortie are listed for 김작, not failed.
#  5. sea route: without warship research the sortie is refused for the naval reason, with it it passes
#  6. three AI-only turns: no crash; table of the 1-city factions after 3 turns (information only)
#  7. new factions (no capital included): turn end, AI turn list, storage text, victory check without errors
#  8. the 9 new-type skills (채비서 85) in a real battle: charge 72 % splash on the ring around the target, mounted buff
#     inside the radius only (any unit type), command debuff 2 turns + enemy momentum drop; description mismatches listed
#  9. (addendum 9) the game reads data/worldmap/placement_a_runtime.json, outside every .gdignore folder and a resource
#     Godot exports; with the file gone a new game stops on a full-screen error (no silent old placement); first-turn
#     stock of every source city; road / research / deployment-and-resources as separate columns
# 10. (addendum 10) a test-owned new city (철원 given to the player): what the victory count and the next turn's income
#     do with it - recorded only (the AI economy, invasions and victory still run on the 4 Korea cities)
# Queue 47 (새 26성 기본값, Drive 104 / 109 / 110):
# 47-1. new game: gold, rice / barley / seafood / salt stock, population / commerce rating and the seeds (rice, barley,
#       seafood, wood, iron, salt, gold) of the 26 cities equal Drive 104 section 6 and order 47 section 2, every key
# 47-2. the 13 legacy cities keep main's values (CITY_HUD_DATA of the unchanged worldmap_main.gd and its stock seeder)
# 47-3. first real sortie table: no direction fails for "금·군량으로 출전 가능한 병력이 0"; siege-blocked ones listed
# 47-4. an A save, loaded, one turn played, a stock changed, saved and loaded again: the saved stock stays (the start
#       values do not overwrite it); old saves load as before (2.)
# 47-5. three AI turns without a crash (6.) and a test-owned new city earns gold on the next turn (10.)

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
const CAPITALS := ["gyeongju", "hanseong", "luoyang", "osaka"]
const OldSave := preload("res://tools/make_placement_a_old_save_baseline.gd")
const WorldCapture := preload("res://tests/scripts/support/placement_a_world_capture.gd")
const OLD_SAVE_DIR := "res://tests/fixtures/placement_a"
const MOVED_HERO := "go_yeon_mu"   # stationed by the seeder (a new hero), moved between the two 고구려 cities in 2
const CHARGE := ["sanada_yukimura", "shimazu_iehisa", "a_zhu", "xiahou_yuan", "qapaghan_khagan"]
const MOUNTED := ["go_yeon_mu", "anfiyanggu", "bilge_khagan"]
const DEBUFF := ["dae_mun_ye"]
## Words a description must carry for the engine behaviour checked in 8.
const DESCRIPTION_WORDS := {"charge_aoe": ["인접"], "mounted_team_buff": ["이동", "측후방", "기세"], "command_debuff": ["공격", "방어", "기세"]}
## Queue 47: Drive 104 section 6 (A + B) and order 47 section 2 (wood / iron), typed from the documents.
## city_id: [gold, food, stock rice, stock barley, stock seafood, stock salt, seed rice, seed barley, seed seafood,
##           seed salt, population rating, commerce rating, seed wood, seed iron]
const CITY_VALUES_104 := {
	"gaeseong": [300, 270, 90, 90, 90, 40, 1, 1, 1, 2, 1, 2, 1, 1],   # 개성 소성 상업 수도형
	"gungnaeseong": [270, 180, 90, 90, 0, 40, 1, 1, 0, 2, 1, 1, 1, 2],   # 국내성 소성 요새형
	"jeonju": [320, 340, 170, 170, 0, 40, 2, 2, 0, 2, 2, 2, 2, 1],   # 전주 중성 생산 도시형
	"cheorwon": [410, 260, 65, 130, 65, 40, 1, 2, 1, 2, 2, 2, 1, 2],   # 철원 중성 요새형
	"goryeong": [320, 340, 170, 170, 0, 40, 2, 2, 0, 2, 2, 2, 2, 1],   # 고령 중성 생산 도시형
	"sanggyeong_yongcheonbu": [450, 240, 120, 60, 60, 40, 2, 1, 1, 2, 2, 3, 1, 1],   # 상경 용천부 중성 상업 수도형
	"kofu": [410, 260, 65, 130, 65, 40, 1, 2, 1, 2, 2, 2, 1, 2],   # 고후 중성 요새형
	"echigo": [410, 260, 65, 130, 65, 40, 1, 2, 1, 2, 2, 2, 1, 2],   # 에치고 중성 요새형
	"hiroshima": [430, 190, 38, 38, 114, 40, 1, 1, 3, 2, 2, 2, 1, 1],   # 히로시마 중성 해안 무역형
	"bungo": [290, 140, 46, 0, 94, 40, 1, 0, 2, 2, 1, 1, 1, 0],   # 분고 후나이 소성 해안 무역형
	"aizu": [320, 340, 170, 170, 0, 40, 2, 2, 0, 2, 2, 2, 2, 1],   # 아이즈 중성 생산 도시형
	"odawara": [410, 260, 65, 130, 65, 40, 1, 2, 1, 2, 2, 2, 1, 2],   # 오다와라 중성 요새형
	"xuchang": [210, 230, 153, 76, 1, 40, 2, 1, 0, 2, 1, 1, 1, 1],   # 허창 소성 생산 도시형
	"longxi": [270, 180, 90, 90, 0, 40, 1, 1, 0, 2, 1, 1, 1, 2],   # 농서 소성 요새형
	"jiangdong": [430, 240, 96, 48, 96, 40, 2, 1, 2, 2, 2, 3, 2, 1],   # 강동 중성 강 무역형
	"jizhou": [320, 340, 170, 170, 0, 40, 2, 2, 0, 2, 2, 2, 2, 1],   # 기주 중성 생산 도시형
	"puyang": [320, 340, 170, 170, 0, 40, 2, 2, 0, 2, 2, 2, 2, 1],   # 복양 중성 생산 도시형
	"kaifeng": [450, 240, 120, 60, 60, 40, 2, 1, 1, 2, 2, 3, 1, 1],   # 개봉 중성 상업 수도형
	"pengcheng": [430, 240, 96, 48, 96, 40, 2, 1, 2, 2, 2, 3, 2, 1],   # 팽성 중성 강 무역형
	"dadu": [450, 240, 120, 60, 60, 40, 2, 1, 1, 2, 2, 3, 1, 1],   # 대도 중성 상업 수도형
	"changan": [450, 240, 120, 60, 60, 40, 2, 1, 1, 2, 2, 3, 1, 1],   # 장안 중성 상업 수도형
	"xiangyang": [410, 260, 65, 130, 65, 40, 1, 2, 1, 2, 2, 2, 1, 2],   # 양양 중성 요새형
	"yangzhou": [430, 240, 96, 48, 96, 40, 2, 1, 2, 2, 2, 3, 2, 1],   # 양주 중성 강 무역형
	"hetuala": [410, 260, 65, 130, 65, 40, 1, 2, 1, 2, 2, 2, 1, 2],   # 허투알라 중성 요새형
	"orkhon": [410, 260, 65, 130, 65, 40, 1, 2, 1, 2, 2, 2, 1, 2],   # 오르혼 중성 요새형
	"lhasa": [410, 260, 65, 130, 65, 40, 1, 2, 1, 2, 2, 2, 1, 2],   # 라싸 중성 요새형
}
const NO_SUPPLY_REASON := "금·군량으로 출전 가능한 병력이 0"
const STOCK_KEYS := ["gold", "rice", "barley", "seafood", "salt"]


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
	_check_city_values()
	var snapshot := _snapshot()
	await _check_save_load(snapshot)
	await _new_game_world()   # 3..7 on a fresh placement-A new game
	_check_links()
	_check_first_sortie()
	_check_sea_route()
	var errors_before_turns := _logger.errors.size()
	_check_turns()
	_check_new_factions(errors_before_turns)
	_check_owned_new_city()
	_check_runtime_file()
	await _check_missing_runtime_file()
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
			# addendum 7-3: an undecided governor (한성 "미정 …") keeps main's value
			var want_governor := str(hud[city_id].get("governor_id", "")) if str(want.governor_source).begins_with(Placement.GOVERNOR_UNDECIDED_PREFIX) else str(want.governor_id)
			if owner != str(want.faction_id) or str(entry.get("governor_id", "")) != want_governor or have_ids != want_ids:
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
	# addendum 7-2: capital is a string in the JSON ("false" must not read as true); A has exactly these four capitals
	var capitals: Array = []
	for city_id in hud:
		if bool((_main.call("_get_city_hud_entry", city_id) as Dictionary).get("capital", false)):
			capitals.append(city_id)
	capitals.sort()
	_expect(capitals == CAPITALS, "%s: capitals are exactly 한성 / 경주 / 오사카 / 낙양 %s" % [label, str(capitals)])
	var hanseong_governor := str((_main.call("_get_city_hud_entry", "hanseong") as Dictionary).get("governor_id", ""))
	_expect(hanseong_governor == str(hud.hanseong.get("governor_id", "")), "%s: 한성 governor kept from main (undecided in the JSON) '%s'" % [label, hanseong_governor])
	var longxi_governor := str((_main.call("_get_city_hud_entry", "longxi") as Dictionary).get("governor_id", ""))
	_expect(longxi_governor == "zhao_yun" and HeroDefinitionRegistry.get_hero("zhao_yun").get("stats_approved") == false,
		"%s: 조운 governs 농서 while his stats stay a draft (%s)" % [label, longxi_governor])


func _snapshot() -> String:
	var cities := {}
	for city_id in _main.get("CITY_HUD_DATA"):
		var entry: Dictionary = _main.call("_get_city_hud_entry", city_id)
		cities[city_id] = [entry.get("owner", ""), entry.get("governor_id", ""), entry.get("stationed_hero_ids", []), entry.get("troops", 0), entry.get("population", 0), entry.get("grade", 0), entry.get("values_status", ""), entry.get("capital", false)]
	var player_state: Dictionary = _main.get("_player_state")
	return JSON.stringify({"cities": cities, "owned": player_state.get("owned_hero_ids", []), "heroes": _main.call("_serialize_worldmap_hero_runtime_state"), "placement": player_state.get("world_placement_id", "")}, "", true)


# ---------------------------------------------------------------- 2
## Addendum 7: every load goes through a real path into a FRESH WorldMap scene and waits for the deferred hero seeding
## (OldSave.load_through_title: GameSession.request_load + a new scene, reads the checkpoint slot;
##  OldSave.load_through_system_menu: a new-game scene, then the system menu load, manual slot first).
## The real user:// slots are backed up first and restored at the end (_backup_saves / _restore_saves).
func _check_save_load(snapshot: String) -> void:
	_expect(bool(_main.call("_save_worldmap_manual_slot_mvp")), "2. manual slot saved")
	_expect(bool(_main.call("_checkpoint_worldmap_state_mvp")), "2. turn checkpoint saved")
	var a_manual := FileAccess.get_file_as_string(MANUAL_SAVE)
	var a_checkpoint := FileAccess.get_file_as_string(CHECKPOINT_SAVE)
	await OldSave.load_through_title(self, a_checkpoint)
	_main = current_scene
	_expect(_snapshot() == snapshot, "2. A turn checkpoint, title load in a new WorldMap: the new-game world")
	_check_world("2. A checkpoint / title load")
	await OldSave.load_through_system_menu(self, a_manual)
	_main = current_scene
	_expect(_snapshot() == snapshot, "2. A manual slot, system-menu load in a new WorldMap: the new-game world")
	_check_world("2. A manual / system-menu load")
	# 47-4 (same round trip as the moved hero below): one turn on the loaded A save changes the stock, and a stock no
	# turn touches (an AI new city) is changed by hand as well; after save + load the saved stock must stay.
	_end_turn()
	var stock_cities: Dictionary = _main.get("_city_runtime_states")
	((stock_cities["jeonju"] as Dictionary)["resource_stock"] as Dictionary)["gold"] = 7
	((stock_cities["jeonju"] as Dictionary)["resource_stock"] as Dictionary)["rice"] = 3
	var stock_before := _stock_table()
	var gaeseong_start: Array = CITY_VALUES_104["gaeseong"]
	_expect(int(stock_before.gaeseong.gold) != int(gaeseong_start[0]) or int(stock_before.gaeseong.seafood) != int(gaeseong_start[4]),
		"47-4. one turn on the loaded A save changed 개성's stock (player city: gold %d, seafood %d)" % [int(stock_before.gaeseong.gold), int(stock_before.gaeseong.seafood)])
	# A hero moved to another city, saved and loaded again, is not brought back to his placement-A city.
	var from_city := str(_placement.hero_city[MOVED_HERO])
	var to_city := ""
	for city_id in _placement.city_order:
		if city_id != from_city and str(_placement.cities[city_id].faction_id) == str(_placement.cities[from_city].faction_id):
			to_city = city_id
	var cities: Dictionary = _main.get("_city_runtime_states")
	var from_ids: Array = (cities[from_city] as Dictionary).get("stationed_hero_ids", []).duplicate()
	from_ids.erase(MOVED_HERO)
	cities[from_city]["stationed_hero_ids"] = from_ids
	cities[from_city]["hero_ids"] = from_ids.duplicate()
	var to_ids: Array = (cities[to_city] as Dictionary).get("stationed_hero_ids", []).duplicate()
	to_ids.append(MOVED_HERO)
	cities[to_city]["stationed_hero_ids"] = to_ids
	cities[to_city]["hero_ids"] = to_ids.duplicate()
	var state: Dictionary = (_main.get("_hero_runtime_states") as Dictionary)[MOVED_HERO]
	for key in ["current_city_id", "city_id", "location_city_id"]:
		state[key] = to_city
	_expect(bool(_main.call("_save_worldmap_manual_slot_mvp")), "2. moved %s %s -> %s and saved" % [MOVED_HERO, from_city, to_city])
	var moved: Dictionary = await OldSave.load_through_system_menu(self, FileAccess.get_file_as_string(MANUAL_SAVE))
	_main = current_scene
	var places: Array = []
	for city_id in moved.stationed:
		if (moved.stationed[city_id] as Array).has(MOVED_HERO):
			places.append(city_id)
	_expect(places == [to_city], "2. after the reload %s is only in %s, not back in %s %s" % [MOVED_HERO, to_city, from_city, str(places)])
	_check_stock_reloaded(stock_before)
	# Old (pre-A) saves, written on 60fd2a5: the same paths give the 60fd2a5 world - nothing added or moved.
	var base: Variant = JSON.parse_string(FileAccess.get_file_as_string(OLD_SAVE_DIR + "/old_save_baseline.json"))
	_expect(base is Dictionary and base.has("title_manual"), "2. old-save baseline fixture readable (%s)" % str((base as Dictionary).get("base_commit", "?") if base is Dictionary else "?"))
	for kind in ["manual", "checkpoint"]:
		var text := FileAccess.get_file_as_string(OLD_SAVE_DIR + "/old_%s_save.json" % kind)
		for path in ["title", "system"]:
			var now: Dictionary
			if path == "title":
				now = await OldSave.load_through_title(self, text)
			else:
				now = await OldSave.load_through_system_menu(self, text)
			var want: Dictionary = base["%s_%s" % [path, kind]]
			var diff: Array = []
			for key in ["owners", "stationed", "owned_hero_ids", "hero_runtime_states"]:
				if JSON.stringify(now.get(key), "", true) != JSON.stringify(want.get(key), "", true):
					diff.append(key)
			_expect(diff.is_empty(), "2. old %s save, %s load: owners / garrisons / owned heroes / hero states equal 60fd2a5 (differs: %s)" % [kind, path, str(diff)])
	_main = current_scene
	_expect(not Placement.is_placement_world(_main.get("_player_state")), "2. an old save stays an old-placement world (no world_placement_id)")


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
## Addendum 8 (채비서 89): two tables, one line per DIRECTION (source city -> target city), never merged per target.
##  attack window: land / sea and the _get_player_attack_block_reason of that direction (siege research for a fortress
##    or defense >= 4 target, warship research for a sea route) - "" = open
##  real sortie: the same direction through the real deployment: payload (deployable heroes, the garrison left behind),
##    an allocation inside each hero's command limit, gold and food the source can carry (minimum supply for the
##    troops, food type the source has most of), the confirm path's validation, then the battle context it builds.
## The rules are not relaxed. A faction with no real sortie on turn 1 is NOT a failure here: the factions and their
## reasons are printed for the report (a decision for 김작). Only the table itself and "no state change" are checked.
func _check_first_sortie() -> void:
	var before := _snapshot()
	var window_lines: Array[String] = ["[PLACEMENT_A] attack window (faction | direction | route | road | research | deployment & resources):"]
	var real_lines: Array[String] = ["[PLACEMENT_A] real sortie (faction | direction | result):"]
	var real_count := {}
	var no_real: Array[String] = []
	var no_window: Array[String] = []
	var no_supply: Array[String] = []
	var siege_blocked: Array[String] = []
	for faction_id in _placement.faction_ids:
		var cities: Array = _placement.city_order.filter(func(c): return str(_placement.cities[c].faction_id) == faction_id)
		var directions := 0
		var real_ok := 0
		var reasons: Array[String] = []
		for city_id in cities:
			for neighbor_id in _main.call("_get_city_neighbors_mvp", city_id):
				var owner := str(_main.call("_get_city_owner_id_for_battle_context", neighbor_id))
				if owner.is_empty() or owner == faction_id:
					continue
				directions += 1
				var row := _sortie_direction(faction_id, city_id, neighbor_id)
				window_lines.append("  %s | %s -> %s(%s) | %s | 도로 열림 | %s | %s" % [faction_id, city_id, neighbor_id, owner, row.route,
					("연구 막힘: " + str(row.block)) if not str(row.block).is_empty() else "연구 조건 없음", row.real])
				real_lines.append("  %s | %s -> %s | %s" % [faction_id, city_id, neighbor_id, row.real])
				if bool(row.real_ok):
					real_ok += 1
				else:
					reasons.append("%s->%s: %s" % [city_id, neighbor_id, row.real])
				if str(row.real).contains(NO_SUPPLY_REASON):
					no_supply.append("%s %s->%s" % [faction_id, city_id, neighbor_id])
				if str(row.block).contains("공성"):
					siege_blocked.append("%s %s->%s" % [faction_id, city_id, neighbor_id])
		real_count[faction_id] = real_ok
		if directions == 0:
			no_window.append(faction_id)
		if real_ok == 0:
			no_real.append("%s (%s)" % [faction_id, " / ".join(reasons)])
	var summary: Array[String] = ["[PLACEMENT_A] real sortie directions per faction:"]
	for faction_id in _placement.faction_ids:
		summary.append("  %s %d" % [faction_id, int(real_count[faction_id])])
	summary.append("[PLACEMENT_A] factions with no real sortie on turn 1 (김작 decision, not a test failure): " + ("없음" if no_real.is_empty() else "; ".join(no_real)))
	print("\n".join(window_lines))
	print("\n".join(real_lines))
	print("\n".join(summary))
	var first: Array[String] = ["[PLACEMENT_A] first roads, each direction:"]
	for pair in FIRST_ROADS:
		for dir in [[pair[0], pair[1]], [pair[1], pair[0]]]:
			var faction_id := str(_main.call("_get_city_owner_id_for_battle_context", dir[0]))
			var row := _sortie_direction(faction_id, dir[0], dir[1])
			first.append("  %s(%s) -> %s | window: %s | real: %s" % [dir[0], faction_id, dir[1], row.block if not str(row.block).is_empty() else "열림", row.real])
			_expect((_main.call("_get_city_neighbors_mvp", dir[0]) as Array).has(dir[1]), "4. %s -> %s is a direct link" % [dir[0], dir[1]])
	print("\n".join(first))
	# 채비서 90: which first roads need siege research, direction by direction (the rule itself is not changed)
	for case in [["gyeongju", "goryeong", false], ["goryeong", "gyeongju", false], ["dadu", "karakorum", true], ["karakorum", "dadu", false], ["chengdu", "lhasa", true], ["lhasa", "chengdu", true]]:
		var faction_id := str(_main.call("_get_city_owner_id_for_battle_context", case[0]))
		var row := _sortie_direction(faction_id, case[0], case[1])
		_expect(str(row.block).contains("공성") == bool(case[2]), "4. %s -> %s needs siege research: %s (%s)" % [case[0], case[1], str(case[2]), row.block])
	var stock_lines: Array[String] = ["[PLACEMENT_A] first-turn stock of the source cities (before any turn end or test grant): city | faction | gold | rice | barley | seafood"]
	for city_id in _placement.city_order:
		var stock: Dictionary = (_main.call("_get_city_hud_entry", city_id) as Dictionary).get("resource_stock", {})
		stock_lines.append("  %s | %s | %d | %d | %d | %d" % [city_id, _placement.cities[city_id].faction_id, int(stock.get("gold", 0)), int(stock.get("rice", 0)), int(stock.get("barley", 0)), int(stock.get("seafood", 0))])
	print("\n".join(stock_lines))
	_expect(no_window.is_empty(), "4. every faction has at least one direction to a foreign city (attack window table) %s" % str(no_window))
	print("[PLACEMENT_A] 47-3 siege-research blocked directions (rule unchanged, %d): %s" % [siege_blocked.size(), "; ".join(siege_blocked)])
	_expect(no_supply.is_empty(), "47-3. no first-turn direction fails because gold / food fields 0 troops %s" % str(no_supply))
	_expect(_snapshot() == before, "4. the tables change nothing in the world (no departure, no payment)")


## One direction: {route, block, real, real_ok}. Runs as the acting faction and restores the player afterwards.
func _sortie_direction(faction_id: String, source_id: String, target_id: String) -> Dictionary:
	_as_faction(faction_id)
	var player_state: Dictionary = _main.get("_player_state")
	var origin_before = player_state.get("origin_city_id", "")
	player_state["origin_city_id"] = source_id
	var route := "해로" if bool(_main.call("_is_naval_attack_route_mvp", source_id, target_id)) else "육로"
	var block := str(_main.call("_get_player_attack_block_reason", target_id))
	var real := ""
	var real_ok := false
	var payload: Dictionary = _main.call("_build_player_attack_deployment_payload", source_id, target_id, "manual")
	if payload.is_empty():
		real = "편성 불가 (출전할 장수 또는 남길 병력이 없음)"
	else:
		var deployment := _real_deployment(payload)
		if deployment.is_empty():
			real = "편성 불가 (금·군량으로 출전 가능한 병력이 0)"
		else:
			var validation: Dictionary = _main.call("_validate_player_attack_deployment", deployment)
			if not bool(validation.get("ok", false)):
				real = "거부: %s" % str(validation.get("message", validation.get("error_code", "")))
			else:
				var ids: Array[String] = []
				for hero_id in validation.selected_hero_ids:
					ids.append(str(hero_id))
				var cost: Dictionary = validation.supply_cost
				var context: Dictionary = _main.call("_build_player_attack_battle_context", source_id, target_id, "manual", ids, validation.attacker_troop_allocation, cost)
				real_ok = not context.is_empty()
				if real_ok:
					real = "출전 가능: 장수 %d, 병력 %d, 금 %d, 군량 %d(%s)" % [ids.size(), int(validation.total_troops), int(cost.get("gold", 0)), int(cost.get("food", 0)), str(validation.food_type)]
				else:
					real = "전투 데이터 생성 실패"
	player_state["origin_city_id"] = origin_before
	_as_faction("player")
	return {"route": route, "block": block, "real": real, "real_ok": real_ok}


## The largest deployment the source can really field: heroes in payload order inside their command limits, the
## garrison left behind (max_deployable_troops), and gold / food (minimum supply) the source can carry.
func _real_deployment(payload: Dictionary) -> Dictionary:
	var food_type := "rice"
	for candidate in ["barley", "seafood"]:
		if int(payload.get("%s_available" % candidate, 0)) > int(payload.get("%s_available" % food_type, 0)):
			food_type = candidate
	var food := int(payload.get("%s_available" % food_type, 0))
	var gold := int(payload.get("gold_available", 0))
	var heroes: Array = payload.get("heroes", [])
	var capacity := 0
	for hero in heroes:
		capacity += maxi(0, int(hero.get("command_limit", 0)))
	var total := mini(capacity, int(payload.get("max_deployable_troops", 0)))
	while total > 0 and (Supply.minimum_gold(total) > gold or Supply.minimum_food(total) > food):
		total -= maxi(1, int(total / 10.0))
	if total <= 0:
		return {}
	var allocation := {}
	var ids: Array[String] = []
	var left := total
	for hero in heroes:
		if left <= 0:
			break
		var troops := mini(maxi(0, int(hero.get("command_limit", 0))), left)
		if troops > 0:
			allocation[str(hero.hero_id)] = troops
			ids.append(str(hero.hero_id))
			left -= troops
	return {
		"source_city_id": payload.source_city_id, "target_city_id": payload.target_city_id, "mode": "manual",
		"selected_hero_ids": ids, "attacker_troop_allocation": allocation,
		"attacker_food_type": food_type, "attacker_food_amount": Supply.minimum_food(total),
		"attacker_carried_gold": Supply.minimum_gold(total), "attacker_salt_amount": 0,
	}


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


# ---------------------------------------------------------------- 9 / 10
## Addendum 9: the runtime file is the one the game reads, outside .gdignore, and a resource Godot exports.
func _check_runtime_file() -> void:
	var dir := Placement.RUNTIME_PATH.get_base_dir()
	var under_gdignore := ""
	while dir != "res://" and dir != "res:":
		if FileAccess.file_exists(dir.path_join(".gdignore")):
			under_gdignore = dir
		dir = dir.get_base_dir()
	_expect(under_gdignore.is_empty() and FileAccess.file_exists(Placement.RUNTIME_PATH), "9. %s exists outside every .gdignore folder (%s)" % [Placement.RUNTIME_PATH, under_gdignore])
	_expect(FileAccess.file_exists("res://data/heroes/source/.gdignore"), "9. data/heroes/source/ (working sources) keeps its .gdignore")
	var resource := load(Placement.RUNTIME_PATH)
	_expect(resource is JSON, "9. the runtime file is a JSON resource (exported with all resources) - %s" % str(resource))
	print("[PLACEMENT_A] export_presets.cfg in the repository: %s (no preset filter to check; a JSON resource outside .gdignore is exported by default)" % ("yes" if FileAccess.file_exists("res://export_presets.cfg") else "no"))


## Addendum 9: with the runtime file gone, a new game stops on the error screen instead of starting the old placement.
func _check_missing_runtime_file() -> void:
	Placement.runtime_path_override = "res://data/worldmap/placement_a_runtime_missing_for_test.json"
	_session.call("request_new_game", "player")
	change_scene_to_file(WORLDMAP_SCENE_PATH)
	for i in 10:
		await process_frame
	var main := current_scene
	var errors: Array = Placement.start_error(main)
	var overlay := main.get_node_or_null("PlacementAStartError") as CanvasLayer
	_expect(not errors.is_empty() and overlay != null and overlay.visible and overlay.layer >= 100, "9. runtime file missing: the start stops on a full-screen error %s" % str(errors))
	_expect(not Placement.is_placement_world(main.get("_player_state")), "9. runtime file missing: the world is not marked as placement A (it did not start)")
	Placement.runtime_path_override = ""
	await _new_game_world()


## Addendum 10: a new city owned by the player in a test state - the victory count and next turn's income, recorded.
func _check_owned_new_city() -> void:
	var city_id := "cheorwon"
	var before_owner := str(_main.call("_get_city_owner_id_for_battle_context", city_id))
	_main.call("_set_city_runtime_owner", city_id, "player")
	var outcome: Dictionary = _main.call("_evaluate_korea_mvp_outcome_mvp")
	var owned_korea := int(_main.call("_get_player_owned_korea_mvp_city_count"))
	var stock_before: Dictionary = ((_main.call("_get_city_hud_entry", city_id) as Dictionary).get("resource_stock", {}) as Dictionary).duplicate()
	var national_before: Dictionary = (_main.call("_get_player_national_resource_stock_mvp") as Dictionary).duplicate()
	_end_turn()
	var stock_after: Dictionary = (_main.call("_get_city_hud_entry", city_id) as Dictionary).get("resource_stock", {})
	var national_after: Dictionary = _main.call("_get_player_national_resource_stock_mvp")
	print("[PLACEMENT_A] test-owned new city %s (was %s): victory count of player Korea cities %d, outcome %s; %s stock gold %d -> %d, rice %d -> %d; player national gold %d -> %d" % [
		city_id, before_owner, owned_korea, str(outcome.get("status", "")), city_id,
		int(stock_before.get("gold", 0)), int(stock_after.get("gold", 0)), int(stock_before.get("rice", 0)), int(stock_after.get("rice", 0)),
		int(national_before.get("gold", 0)), int(national_after.get("gold", 0))])
	_expect(str(_main.call("_get_city_owner_id_for_battle_context", city_id)) == "player", "10. the test-owned new city stays the player's through a turn (recorded, no crash)")
	_expect(int(stock_after.get("gold", 0)) > int(stock_before.get("gold", 0)), "47-5. the test-owned new city %s earns gold on the next turn (%d -> %d)" % [city_id, int(stock_before.get("gold", 0)), int(stock_after.get("gold", 0))])


# ---------------------------------------------------------------- 47
## 47-1 / 47-2: the 26 new cities against the 104 table (typed in this test), the 13 legacy ones against main.
func _check_city_values() -> void:
	var hud: Dictionary = _main.get("CITY_HUD_DATA")
	var new_ids: Array = _placement.city_order.filter(func(c): return not bool(_placement.cities[c].legacy))
	var table_ids: Array = CITY_VALUES_104.keys()
	new_ids.sort()
	table_ids.sort()
	_expect(new_ids == table_ids, "47-1. the 104 table covers exactly the 26 new cities (%d / %d)" % [table_ids.size(), new_ids.size()])
	var bad: Array = []
	var lines: Array[String] = ["[PLACEMENT_A] 47-1 new-game values: city | gold | food | stock rice / barley / seafood / salt / gold | seed rice / barley / seafood / wood / iron / salt / gold | population / commerce rating"]
	var compared := 0
	for city_id in CITY_VALUES_104:
		var want: Array = CITY_VALUES_104[city_id]
		var entry: Dictionary = _main.call("_get_city_hud_entry", city_id)
		var stock: Dictionary = entry.get("resource_stock", {})
		var seed: Dictionary = entry.get("resource_seed", {})
		var have: Array = [int(entry.get("gold", -1)), int(entry.get("food", -1)), int(stock.get("rice", -1)), int(stock.get("barley", -1)), int(stock.get("seafood", -1)),
			int(stock.get("salt", -1)), int(seed.get("rice", -1)), int(seed.get("barley", -1)), int(seed.get("seafood", -1)), int(seed.get("salt", -1)),
			int(entry.get("population_rating", -1)), int(entry.get("commerce_rating", -1)), int(seed.get("wood", -1)), int(seed.get("iron", -1))]
		compared += have.size() + 2
		if have != want or int(stock.get("gold", -1)) != int(want[0]) or int(seed.get("gold", -1)) != int(want[0]) or str(entry.get("values_status", "")) != Placement.VALUES_STATUS_PROPOSAL:
			bad.append("%s have %s stock gold %s seed gold %s want %s" % [city_id, str(have), stock.get("gold"), seed.get("gold"), str(want)])
		lines.append("  %s | %d | %d | %d / %d / %d / %d / %d | %d / %d / %d / %d / %d / %d / %d | %d / %d" % [city_id, have[0], have[1], have[2], have[3], have[4], have[5], int(stock.get("gold", 0)),
			have[6], have[7], have[8], have[13 - 1], have[13], have[9], int(seed.get("gold", 0)), have[10], have[11]])
	print("\n".join(lines))
	_expect(bad.is_empty() and compared == 26 * 16, "47-1. 26 cities x 16 values (gold, food, 5 stocks, 7 seeds, 2 ratings) = 104 / order 47 (%d compared) %s" % [compared, str(bad.slice(0, 4))])
	var resources := WorldMapCityResourceService.new()
	var legacy_bad: Array = []
	for city_id in _placement.city_order:
		if not bool(_placement.cities[city_id].legacy):
			continue
		var entry: Dictionary = _main.call("_get_city_hud_entry", city_id)
		var base: Dictionary = hud[city_id]
		var want_stock: Dictionary = resources.build_supply_resource_defaults(base).resource_stock
		for key in STOCK_KEYS:
			if int((entry.get("resource_stock", {}) as Dictionary).get(key, -1)) != int(want_stock.get(key, -2)):
				legacy_bad.append("%s stock %s" % [city_id, key])
		for key in ["gold", "food", "population_rating", "commerce_rating"]:
			if int(entry.get(key, -1)) != int(base.get(key, -2)):
				legacy_bad.append("%s %s" % [city_id, key])
		if JSON.stringify(entry.get("resource_seed", {}), "", true) != JSON.stringify(base.get("resource_seed", {}), "", true) or str(entry.get("resources", "")) != str(base.get("resources", "")):
			legacy_bad.append("%s seed / resources text" % city_id)
	_expect(legacy_bad.is_empty(), "47-2. the 13 legacy cities: stock, gold, food, ratings, seeds as main (unchanged worldmap_main.gd) %s" % str(legacy_bad.slice(0, 6)))


## 47-4: the saved stock wins over the start values on a placement-A load (checked in 2.'s second round trip:
## the loaded A save played one turn, a hand-changed AI city stock, save, load).
func _check_stock_reloaded(before: Dictionary) -> void:
	var after := _stock_table()
	var diff: Array = before.keys().filter(func(c): return JSON.stringify(before[c], "", true) != JSON.stringify(after.get(c), "", true))
	_expect(diff.is_empty() and int(after.jeonju.gold) == 7 and int(after.jeonju.rice) == 3, "47-4. reloaded: the saved stock of the 39 cities stays, not the start values (전주 gold %d rice %d) %s" % [int(after.jeonju.gold), int(after.jeonju.rice), str(diff.slice(0, 4))])
	var rating_bad: Array = CITY_VALUES_104.keys().filter(func(c): return int((_main.call("_get_city_hud_entry", c) as Dictionary).get("commerce_rating", -1)) != int(CITY_VALUES_104[c][11]) or int(((_main.call("_get_city_hud_entry", c) as Dictionary).get("resource_seed", {}) as Dictionary).get("iron", -1)) != int(CITY_VALUES_104[c][13]))
	_expect(rating_bad.is_empty(), "47-4. reloaded: ratings and seeds of the 26 cities put back %s" % str(rating_bad))


func _stock_table() -> Dictionary:
	var table := {}
	for city_id in _placement.city_order:
		var stock: Dictionary = (_main.call("_get_city_hud_entry", city_id) as Dictionary).get("resource_stock", {})
		var row := {}
		for key in STOCK_KEYS:
			row[key] = int(stock.get(key, 0))
		table[city_id] = row
	return table


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
func _new_game_world() -> void:
	_session.call("request_new_game", "player")
	change_scene_to_file(WORLDMAP_SCENE_PATH)
	for i in 20:
		await process_frame
	_main = current_scene


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
