extends SceneTree

const SCENE_PATH := "res://WorldMap_16x9_Test.tscn"
const BattleResultServiceScript := preload("res://scripts/worldmap/battle/battle_result_service.gd")
const RESULT_META_KEY := "samwar_worldmap_battle_result"

var _checks := 0
var _failures := 0
var _cities := {
	"hanseong": {"owner": "player", "troops": 1000},
	"pyeongyang": {"owner": "goguryeo", "troops": 800},
}


func _initialize() -> void:
	call_deferred("_run")


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("[BATTLE_RESULT_SERVICE] FAIL: " + label)


func _run() -> void:
	var service := BattleResultServiceScript.new()
	service.configure(Callable(self, "_query"), {
		"player_attack_context_source": "player_attack",
		"hero_id_compatibility": {"yi_sunsin": "yi_sun_sin"},
		"minimum_city_troops": 30,
		"minimum_occupation_troops": 80,
		"maximum_city_troops": 99999,
		"defender_win_defender_loss_rate": 0.15,
		"defender_win_attacker_loss_rate": 0.70,
		"attacker_win_defender_loss_rate": 0.75,
		"attacker_win_attacker_loss_rate": 0.35,
	})
	var state_before := _cities.duplicate(true)
	_expect(service._normalize_player_attack_battle_result_kind({"winner": "attacker"}) == "attacker_win", "Player attack win normalized")
	_expect(service._normalize_player_attack_battle_result_kind({"winner": "defender"}) == "defender_win", "Player attack loss normalized")
	_expect(service._normalize_invasion_battle_result_kind({"winner": "defender"}) == "defender_win", "Enemy invasion defender win normalized")
	_expect(service._normalize_invasion_battle_result_kind({"winner": "attacker"}) == "attacker_win", "Enemy invasion attacker win normalized")
	_expect(service._normalize_invasion_battle_result_kind({"result": "cancelled"}) == "retreat", "Retreat token normalized")
	_expect(service._normalize_invasion_battle_result_kind({}) == "unknown", "Malformed result falls back to unknown")

	var defender_win: Dictionary = service._calculate_invasion_casualty_result("defender_win", "hanseong", "pyeongyang", {})
	_expect(int(defender_win.get("defender_remaining_troops", 0)) == 850, "Defender-win fallback casualty calculated")
	_expect(int(defender_win.get("attacker_remaining_troops", 0)) == 240, "Defender-win attacker casualty calculated")
	var attacker_win: Dictionary = service._calculate_invasion_casualty_result("attacker_win", "hanseong", "pyeongyang", {})
	_expect(int(attacker_win.get("defender_remaining_troops", 0)) == 250, "Attacker-win defender casualty calculated")
	_expect(int(attacker_win.get("attacker_remaining_troops", 0)) == 520, "Attacker-win survivor calculation preserved")
	_expect(int(attacker_win.get("occupied_city_troops", 0)) == 312, "Occupation troops calculated")
	_expect(int(attacker_win.get("attacker_source_remaining_troops", 0)) == 208, "Occupation troops deducted from source survivors")
	_expect(service._resolve_occupation_troops(0, 0, {}) == 80, "Missing occupation data uses safe minimum")
	_expect(service._clamp_invasion_troops(200000) == 99999, "Malformed excessive troops clamped")

	var normalized_ids: Array[String] = service._normalize_battle_result_hero_ids(["yi_sunsin", "yi_sun_sin", "missing", ""])
	_expect(normalized_ids == ["yi_sun_sin"], "Hero IDs normalized and deduplicated")
	var normalized_outcomes: Dictionary = service._normalize_battle_hero_outcomes({"yi_sunsin": {"survived": true}, "bad": "invalid"})
	_expect(normalized_outcomes.has("yi_sun_sin") and normalized_outcomes.size() == 1, "Hero outcomes normalized")

	var player_win_plan: Dictionary = service.build_settlement_plan({
		"source": "player_attack", "winner": "attacker",
		"attacker_city_id": "hanseong", "defender_city_id": "pyeongyang",
		"attacker_troops": 300, "attacker_surviving_troops": 180,
		"defender_troops": 250, "defender_surviving_troops": 0,
		"attacker_hero_outcomes": {"yi_sunsin": {"survived": true}},
		"attacker_remaining_food_type": "barley", "attacker_remaining_food": 12,
		"attacker_remaining_salt": 3, "attacker_remaining_gold": 40,
	})
	_expect(str(player_win_plan.get("battle_kind", "")) == "player_attack", "Settlement plan identifies player attack")
	_expect(str(player_win_plan.get("winner_side", "")) == "attacker", "Settlement plan records winner and loser")
	_expect(bool((player_win_plan.get("faction_transfer", {}) as Dictionary).get("required", false)), "Player win requests faction transfer")
	_expect(str((player_win_plan.get("faction_transfer", {}) as Dictionary).get("new_owner", "")) == "player", "Player win transfer target normalized")
	_expect(int((player_win_plan.get("supply_settlement", {}).attacker_cargo as Dictionary).get("gold", 0)) == 40, "Cargo settlement captured")
	_expect((player_win_plan.get("hero_outcomes", {}).attacker as Dictionary).has("yi_sun_sin"), "Settlement plan carries normalized hero outcomes")
	var player_loss_plan: Dictionary = service.build_settlement_plan({"source": "player_attack", "winner": "defender", "attacker_city_id": "hanseong", "defender_city_id": "pyeongyang"})
	_expect(str(player_loss_plan.get("result_kind", "")) == "defender_win" and not bool((player_loss_plan.get("faction_transfer", {}) as Dictionary).get("required", true)), "Player loss settlement preserves ownership")

	var enemy_win_plan: Dictionary = service.build_settlement_plan({
		"source": "enemy_invasion", "winner": "attacker",
		"attacker_city_id": "pyeongyang", "defender_city_id": "hanseong",
	})
	_expect(str(enemy_win_plan.get("battle_kind", "")) == "enemy_invasion", "Settlement plan identifies enemy invasion")
	_expect(str((enemy_win_plan.get("faction_transfer", {}) as Dictionary).get("new_owner", "")) == "goguryeo", "Enemy occupation faction resolved from source city")
	var enemy_defense_plan: Dictionary = service.build_settlement_plan({"source": "enemy_invasion", "winner": "defender", "attacker_city_id": "pyeongyang", "defender_city_id": "hanseong"})
	_expect(str(enemy_defense_plan.get("result_kind", "")) == "defender_win" and int(enemy_defense_plan.get("occupation_troops", -1)) == 0, "Enemy invasion defender win has no occupation")
	var malformed_plan: Dictionary = service.build_settlement_plan({"unexpected": true})
	_expect(str(malformed_plan.get("battle_kind", "")) == "unknown" and str(malformed_plan.get("result_kind", "")) == "unknown", "Malformed settlement plan remains non-mutating unknown")
	_expect(_cities == state_before, "Settlement planning does not mutate queried world state")

	Engine.set_meta(RESULT_META_KEY, {
		"source": "enemy_invasion", "type": "defense", "winner": "defender",
		"attacker_city_id": "pyeongyang", "defender_city_id": "hanseong",
		"attacker_city_name": "평양", "defender_city_name": "한성",
		"player_troop_outcome": {"allocated": 100, "survivors": 40, "losses": 60, "wounded": 20, "dead": 40},
		"enemy_troop_outcome": {"allocated": 100, "survivors": 0, "losses": 100, "wounded": 30, "dead": 70},
	})
	change_scene_to_file(SCENE_PATH)
	await process_frame
	await process_frame
	var host := current_scene.get_node("ProductionWorldMap")
	var host_service: RefCounted = host.call("_ensure_battle_result_service")
	_expect(host_service != null and host.call("_ensure_battle_result_service") == host_service, "WorldMap owns one result service")
	_expect(not host_service.has_method("get_node"), "Result service has no scene-node API")
	_expect(not Engine.has_meta(RESULT_META_KEY), "Battle result meta consumed once on WorldMap return")

	current_scene.queue_free()
	await process_frame
	await process_frame
	print("[BATTLE_RESULT_SERVICE] %s: %d checks, %d failures" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	quit(0 if _failures == 0 else 1)


func _query(query_id: String, args: Array) -> Variant:
	match query_id:
		"has_city": return _cities.has(str(args[0]))
		"city_troops": return int((_cities.get(str(args[0]), {}) as Dictionary).get("troops", 0))
		"city_owner": return str((_cities.get(str(args[0]), {}) as Dictionary).get("owner", ""))
		"faction_label": return str(args[0])
		"player_faction": return "player"
		"has_hero": return str(args[0]) == "yi_sun_sin"
	return null
