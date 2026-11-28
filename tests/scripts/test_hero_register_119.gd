extends SceneTree

# Queue 45: 119 heroes registered as definitions only (no garrison). Baseline = main 6b6bc2f, recorded by
# tools/make_hero_reg119_baseline.gd into tests/fixtures/hero_reg119/ (same capture code: support/hero_reg119_capture.gd).
#  1. 163 registered (44 + 119); new ids unique and not clashing with the 44; display names unique; design data loads
#     and no hero carries a runtime_factory_error
#  2. the 44 definitions are exactly the baseline's (get_hero as sorted-key JSON text)
#  3. new game: city garrisons, the player's owned heroes and every hero runtime state equal the baseline; no new hero
#     is stationed, owned, has a runtime state, or sits in an unclaimed city
#  4. the baseline's manual save and turn checkpoint (written on 6b6bc2f) load to the same world as on 6b6bc2f
#  5. each new hero: get_hero returns it, stats_approved == false, review_status as in the roster (조운 = draft),
#     city and faction fields empty, the 9 new-type skills keep their roster effect_type
#  6. an effect type the battle resolver does not know: no effect (validate / plan fail, no target), no crash, one
#     [SKILL_UNIMPLEMENTED] line per type
#  7. the 119 portraits: 512x512 RGB PNG, load() is not null

const Capture := preload("res://tests/scripts/support/hero_reg119_capture.gd")
const WORLDMAP_SCENE_PATH := "res://WorldMap.tscn"
const FIXTURE_DIR := "res://tests/fixtures/hero_reg119"
const ROSTER_PATH := "res://data/heroes/source/roster_245_20261128.json"
const IDS_CSV := "res://data/heroes/source/hero_portrait_candidates_74_20261128.csv"
const MANUAL_SAVE := "user://worldmap_manual_save.json"
const CHECKPOINT_SAVE := "user://worldmap_left_panel_state.json"
const NEW_TYPE_HEROES := {
	"charge_aoe": ["sanada_yukimura", "shimazu_iehisa", "a_zhu", "xiahou_yuan", "qapaghan_khagan"],
	"mounted_team_buff": ["go_yeon_mu", "anfiyanggu", "bilge_khagan"],
	"command_debuff": ["dae_mun_ye"],
}
const UNKNOWN_TYPE := "hero_reg119_unknown_effect"

var _checks := 0
var _failures: Array[String] = []
var _baseline: Dictionary = {}
var _new_ids: Array[String] = []
var _roster: Dictionary = {}
var _saved_files: Dictionary = {}


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_baseline = JSON.parse_string(FileAccess.get_file_as_string(FIXTURE_DIR + "/baseline.json"))
	_expect(_baseline is Dictionary and _baseline.has("definitions"), "baseline fixture readable (base %s)" % str(_baseline.get("base_commit", "?")))
	for hero in (JSON.parse_string(FileAccess.get_file_as_string(ROSTER_PATH)) as Dictionary).heroes:
		_roster[str(hero.hero_id)] = hero
	var lines := FileAccess.get_file_as_string(IDS_CSV).strip_edges().split("\n")
	var header := lines[0].split(",")
	for i in range(1, lines.size()):
		_new_ids.append(lines[i].split(",")[header.find("hero_id")])
	_check_registry()
	_check_definitions()
	_check_new_heroes()
	_check_unknown_type()
	_check_portraits()
	_backup_saves()
	var main := await _new_game()
	_check_world("3. new game", Capture.world(main), _baseline.new_game)
	_write(MANUAL_SAVE, FileAccess.get_file_as_string(FIXTURE_DIR + "/manual_save.json"))
	_write(CHECKPOINT_SAVE, FileAccess.get_file_as_string(FIXTURE_DIR + "/checkpoint_save.json"))
	main.call("_load_worldmap_state", MANUAL_SAVE)
	await _frames(4)
	_check_world("4. 6b6bc2f manual save loaded", Capture.world(main), _baseline.after_manual_load)
	main.call("_load_worldmap_state", CHECKPOINT_SAVE)
	await _frames(4)
	_check_world("4. 6b6bc2f turn checkpoint loaded", Capture.world(main), _baseline.after_checkpoint_load)
	_restore_saves()
	_finish()


## 1
func _check_registry() -> void:
	var all_ids: Array = HeroDefinitionRegistry.HERO_DATA.keys()
	var old_ids: Array = _baseline.get("hero_ids", [])
	_expect(all_ids.size() == 163 and old_ids.size() == 44 and _new_ids.size() == 119, "1. 163 registered = 44 + 119 (%d, %d, %d)" % [all_ids.size(), old_ids.size(), _new_ids.size()])
	_expect(all_ids.slice(0, 44) == old_ids, "1. the 44 come first, in their old order")
	var unique := {}
	for hero_id in _new_ids:
		unique[hero_id] = true
	_expect(unique.size() == 119, "1. the 119 new ids are unique")
	_expect(_new_ids.filter(func(h): return old_ids.has(h)).is_empty(), "1. no new id clashes with the 44")
	var names := {}
	for hero_id in all_ids:
		names[str(HeroDefinitionRegistry.HERO_DATA[hero_id].get("display_name", ""))] = true
	_expect(names.size() == 163, "1. display names unique (%d)" % names.size())
	_expect(HeroDesignDataRegistry.ensure_loaded() and HeroDesignDataRegistry.get_load_error().is_empty() and HeroDesignDataRegistry.get_all_hero_ids().size() == 163,
		"1. design data loads with 163 heroes (%s)" % HeroDesignDataRegistry.get_load_error())
	var errors: Array = []
	for hero_id in all_ids:
		if (HeroDefinitionRegistry.HERO_DATA[hero_id] as Dictionary).has("runtime_factory_error"):
			errors.append(hero_id)
	_expect(errors.is_empty(), "1. no runtime_factory_error %s" % str(errors))


## 2
func _check_definitions() -> void:
	var now := Capture.definitions(_baseline.get("hero_ids", []))
	var changed: Array = []
	for hero_id in now:
		if now[hero_id] != _baseline.definitions.get(hero_id, ""):
			changed.append(hero_id)
	_expect(now.size() == 44 and changed.is_empty(), "2. the 44 definitions equal 6b6bc2f %s" % str(changed))


## 3 / 4
func _check_world(label: String, now: Dictionary, base: Dictionary) -> void:
	for key in ["stationed", "owned_hero_ids", "unclaimed_with_heroes"]:
		_expect(JSON.stringify(now.get(key), "", true) == JSON.stringify(base.get(key), "", true), "%s: %s equal to 6b6bc2f" % [label, key])
	_expect(now.get("hero_runtime_states") == base.get("hero_runtime_states"), "%s: hero runtime states equal to 6b6bc2f" % label)
	var leaked: Array = []
	var states: Dictionary = JSON.parse_string(str(now.get("hero_runtime_states", "{}")))
	for hero_id in _new_ids:
		var stationed := false
		for city_ids in (now.stationed as Dictionary).values():
			if (city_ids as Array).has(hero_id):
				stationed = true
		if stationed or (now.owned_hero_ids as Array).has(hero_id) or states.has(hero_id):
			leaked.append(hero_id)
	_expect(leaked.is_empty(), "%s: no new hero stationed / owned / with a runtime state %s" % [label, str(leaked)])


## 5
func _check_new_heroes() -> void:
	var bad: Array = []
	for hero_id in _new_ids:
		var hero := HeroDefinitionRegistry.get_hero(hero_id)
		var roster: Dictionary = _roster.get(hero_id, {})
		var ok: bool = not hero.is_empty() and hero.get("stats_approved") == false and str(hero.get("review_status")) == str(roster.get("review_status"))
		for field in ["assigned_city_id", "city_id", "location_city_id", "faction_id", "force_id", "side", "nation"]:
			ok = ok and hero.has(field) and str(hero.get(field)) == ""
		ok = ok and str(hero.get("skill_effect_type")) == str(roster.get("skill_effect_type"))
		ok = ok and str((hero.get("design_unique_skill", {}) as Dictionary).get("effect_type")) == str(roster.get("skill_effect_type"))
		ok = ok and int(hero.get("leadership", -1)) == int(roster.get("leadership")) and int(hero.get("martial", -1)) == int(roster.get("martial"))
		ok = ok and int(hero.get("intelligence", -1)) == int(roster.get("intelligence")) and int(hero.get("politics", -1)) == int(roster.get("politics"))
		ok = ok and str(hero.get("unit_type")) == str(roster.get("unit_type")) and int(hero.get("initial_loyalty", -1)) == int(roster.get("initial_loyalty"))
		if not ok:
			bad.append(hero_id)
	_expect(bad.is_empty(), "5. 119 definitions: stats / unit / loyalty / skill type from the roster, stats_approved false, review_status kept, city and faction empty %s" % str(bad.slice(0, 8)))
	var zhao := HeroDefinitionRegistry.get_hero("zhao_yun")
	_expect(str(zhao.get("review_status")).contains("초안"), "5. 조운 carries the draft mark (%s)" % str(zhao.get("review_status")))
	var drafts := _new_ids.filter(func(h): return str(HeroDefinitionRegistry.get_hero(h).get("review_status")).contains("초안"))
	_expect(drafts == ["zhao_yun"], "5. 조운 is the only draft %s" % str(drafts))
	for effect_type in NEW_TYPE_HEROES:
		for hero_id in NEW_TYPE_HEROES[effect_type]:
			var hero := HeroDefinitionRegistry.get_hero(hero_id)
			_expect(str(hero.get("skill_effect_type")) == effect_type and str((hero.get("design_unique_skill", {}) as Dictionary).get("effect_type")) == effect_type,
				"5. %s keeps the new type %s (not swapped)" % [hero_id, effect_type])
	var new_type_count := 0
	for hero_id in _new_ids:
		if str(_roster[hero_id].get("effect_type_status", "")) == "신규타입":
			new_type_count += 1
	_expect(new_type_count == 9, "5. the roster marks exactly these 9 of the 119 as 신규타입 (%d)" % new_type_count)


## 6
func _check_unknown_type() -> void:
	var skill := {"skill_id": "hero_reg119_probe_unique", "hero_id": "hero_reg119_probe", "display_name": "시험", "effect_type": UNKNOWN_TYPE,
		"target_mode": "single_enemy", "range": 3, "radius": 0, "power": 40, "momentum_cost": 2, "action_cost": 1, "duration_turns": 1}
	var first := BattleSkillResolver.validate_skill(skill)
	var second := BattleSkillResolver.validate_skill(skill)
	_expect(not bool(first.get("ok", true)) and str(first.get("error", first.get("reason", ""))).contains("unsupported_effect_type"),
		"6. unknown type: validate fails with unsupported_effect_type (%s)" % str(first))
	_expect(not bool(second.get("ok", true)) and BattleSkillResolver.get_unimplemented_log_count(UNKNOWN_TYPE) == 1, "6. one [SKILL_UNIMPLEMENTED] line for the type, not one per call")
	var caster := BattleUnitState.new()
	caster.unit_id = "probe_ally"
	caster.side = "ally"
	caster.current_troops = 1000
	caster.max_troops = 1000
	var enemy := BattleUnitState.new()
	enemy.unit_id = "probe_enemy"
	enemy.side = "enemy"
	enemy.current_troops = 1000
	enemy.max_troops = 1000
	var units: Array[BattleUnitState] = [caster, enemy]
	var targets := BattleSkillResolver.get_valid_primary_targets(caster, skill, units)
	var plan := BattleSkillResolver.build_plan(caster, skill, units, enemy, 4)
	_expect(targets.is_empty() and not bool(plan.get("ok", true)) and enemy.current_troops == 1000, "6. unknown type: no target, no plan, the enemy is untouched (no crash)")
	# the three types the 9 new heroes use are already in the resolver (also used by 겐신 / 혼다 마사노부 / 징기스칸)
	for effect_type in NEW_TYPE_HEROES:
		var skill_def := HeroDesignDataRegistry.get_unique_skill("%s_unique" % NEW_TYPE_HEROES[effect_type][0])
		_expect(bool(BattleSkillResolver.validate_skill(skill_def).get("ok", false)) and BattleSkillResolver.get_unimplemented_log_count(effect_type) == 0,
			"6. %s is a type the resolver already maps (%s): it is not logged as unimplemented" % [effect_type, str(BattleSkillResolver.ARCHETYPE_BY_EFFECT_TYPE.get(effect_type, ""))])


## 7
func _check_portraits() -> void:
	var bad: Array = []
	for hero_id in _new_ids:
		var path := str(HeroDefinitionRegistry.get_hero(hero_id).get("portrait_path", ""))
		var texture := load(path) as Texture2D if not path.is_empty() and ResourceLoader.exists(path) else null
		var image := Image.load_from_file(ProjectSettings.globalize_path(path)) if not path.is_empty() else null
		if texture == null or image == null or image.get_size() != Vector2i(512, 512) or image.get_format() != Image.FORMAT_RGB8:
			bad.append(hero_id)
	_expect(bad.is_empty(), "7. 119 portraits 512x512 RGB, load() not null %s" % str(bad.slice(0, 8)))


func _new_game() -> Node:
	root.get_node("/root/GameSession").call("request_new_game", "player")
	change_scene_to_file(WORLDMAP_SCENE_PATH)
	await _frames(8)
	return current_scene


func _frames(count: int) -> void:
	for i in count:
		await process_frame


func _backup_saves() -> void:
	for path in [MANUAL_SAVE, CHECKPOINT_SAVE]:
		_saved_files[path] = FileAccess.get_file_as_string(path) if FileAccess.file_exists(path) else null


func _restore_saves() -> void:
	for path in _saved_files:
		if _saved_files[path] == null:
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
		else:
			_write(path, _saved_files[path])


func _write(path: String, text: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(text)
	file.close()


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(label)
		push_error("[HERO_REG119_FAIL] %s" % label)


func _finish() -> void:
	print("[HERO_REG119] checks=%d failures=%s" % [_checks, str(_failures)])
	quit(0 if _failures.is_empty() else 1)
