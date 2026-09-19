extends SceneTree

const ApplierScript := preload("res://scripts/worldmap/battle/battle_settlement_applier.gd")

var _checks := 0
var _failures := 0
var _cities: Dictionary = {}
var _heroes: Dictionary = {}
var _applied_ids: Array[String] = []
var _pending_transaction_id := ""
var _wounded: Dictionary = {}


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var applier := ApplierScript.new()
	applier.configure(Callable(self, "_query"), Callable(self, "_mutation"), {"legacy_wounded_turns": 3, "normal_wounded_turns": 3})
	_expect(not applier.has_method("get_node"), "RefCounted applier has no scene-node API")

	_reset_state()
	var report := applier.apply(_standard_plan("player_attack", "attacker_win", 40, 0, 60, "enemy", "player"))
	_expect(bool(report.get("ok", false)), "player attack win applied")
	_expect(_troops("source") == 40 and _troops("target") == 60, "player win trusts source remaining and occupation troops")
	_expect(_owner("target") == "player" and bool(report.get("ownership_changed", false)), "player win transfers ownership")
	_expect(str((_heroes.get("hero_a", {}) as Dictionary).get("status", "")) == "normal", "player win applies explicit hero outcome")

	_reset_state()
	report = applier.apply(_standard_plan("player_attack", "defender_win", 25, 135, 0, "enemy", "enemy"))
	_expect(_troops("source") == 25 and _troops("target") == 135, "player loss applies canonical remaining troops")
	_expect(_owner("target") == "enemy", "player loss preserves owner")

	_reset_state()
	_cities["source"]["owner"] = "enemy"
	_cities["target"]["owner"] = "player"
	report = applier.apply(_standard_plan("enemy_invasion", "attacker_win", 30, 0, 70, "player", "enemy"))
	_expect(_troops("source") == 30 and _troops("target") == 70, "enemy attacker win applies plan troops")
	_expect(_owner("target") == "enemy", "enemy attacker win occupies target")

	_reset_state()
	_cities["source"]["owner"] = "enemy"
	_cities["target"]["owner"] = "player"
	report = applier.apply(_standard_plan("enemy_invasion", "defender_win", 15, 160, 0, "player", "player"))
	_expect(_troops("source") == 15 and _troops("target") == 160, "enemy invasion defender win applies plan troops")
	_expect(_owner("target") == "player", "enemy invasion defender win preserves owner")

	_reset_state()
	_pending_transaction_id = "tx-1"
	var t02 := _standard_plan("player_attack", "attacker_win", 55, 0, 55, "enemy", "player")
	t02["settlement_profile"] = "t02_return"
	t02["transaction_id"] = "tx-1"
	t02["result_id"] = "result-1"
	t02["troop_settlement"] = {"attacker_healthy": 55, "attacker_wounded": 12, "defender_healthy": 0, "defender_wounded": 4}
	t02["apply_supply_settlement"] = true
	t02["supply_settlement"] = {
		"defender": {"city_id": "target", "food_type": "barley", "remaining_food": 7, "remaining_salt": 2},
		"attacker_cargo": {"destination_city_id": "target", "food_type": "rice", "food": 8, "salt": 3, "gold": 9},
	}
	t02["hero_movements"] = [{"hero_id": "hero_a", "city_id": "target"}]
	t02["defender_disposition"] = {
		"assignments": [{"hero_id": "hero_b", "faction_id": "player", "city_id": "target", "acquired": true}],
		"unstationed_hero_ids": [], "aligned_count": 1, "escaped_count": 0,
		"faction_defeated": true, "defeated_faction_id": "enemy", "defeated_owner": "enemy",
		"transaction_id": "tx-1", "result_id": "result-1",
	}
	report = applier.apply(t02)
	_expect(bool(report.get("ok", false)) and _applied_ids == ["result-1"], "transaction result marked exactly once")
	_expect(int((_cities["target"].stock as Dictionary).get("barley", 0)) == 7, "defender supply applied")
	_expect(int((_cities["target"].stock as Dictionary).get("gold", 0)) == 9, "attacker cargo applied")
	_expect(str((_heroes["hero_a"] as Dictionary).get("city_id", "")) == "target", "attacker hero moved")
	_expect(str((_heroes["hero_b"] as Dictionary).get("faction_id", "")) == "player", "defender hero faction transferred")
	var state_after_once := _cities.duplicate(true)
	var duplicate_report := applier.apply(t02)
	_expect(not bool(duplicate_report.get("ok", true)) and bool(duplicate_report.get("duplicate", false)), "duplicate result rejected")
	_expect(_cities == state_after_once and _applied_ids == ["result-1"], "duplicate result performs no mutations")

	_reset_state()
	_cities["source"]["troops"] = 80
	_pending_transaction_id = "tx-retreat"
	var retreat_plan := _standard_plan("player_attack", "retreat", 80, 150, 0, "enemy", "enemy")
	retreat_plan["settlement_profile"] = "t02_return"
	retreat_plan["transaction_id"] = "tx-retreat"
	retreat_plan["result_id"] = "result-retreat"
	retreat_plan["troop_settlement"] = {"attacker_healthy": 12, "attacker_wounded": 3, "defender_healthy": 150, "defender_wounded": 2}
	retreat_plan["apply_supply_settlement"] = true
	retreat_plan["supply_settlement"] = {
		"defender": {"city_id": "target", "food_type": "barley", "remaining_food": 11, "remaining_salt": 4},
		"attacker_cargo": {"destination_city_id": "source", "food_type": "rice", "food": 5, "salt": 2, "gold": 7},
	}
	retreat_plan["hero_movements"] = [{"hero_id": "hero_a", "city_id": "source"}]
	report = applier.apply(retreat_plan)
	_expect(bool(report.get("ok", false)), "T02 retreat settlement applied")
	_expect(_troops("source") == 92, "retreat returns surviving attacker troops to source garrison")
	_expect(_troops("target") == 150 and _owner("target") == "enemy", "retreat preserves target ownership and defender survivors")
	_expect(int((_cities["source"].stock as Dictionary).get("rice", 0)) == 5 and int((_cities["source"].stock as Dictionary).get("gold", 0)) == 7, "retreat returns remaining expedition cargo to source")
	_expect(str((_heroes["hero_a"] as Dictionary).get("city_id", "")) == "source", "retreat returns attacker hero to source")
	_expect(int(_wounded.get("source", 0)) == 3, "retreat registers attacker wounded at source")
	_expect(_applied_ids == ["result-retreat"], "retreat result marked exactly once")

	var malformed := applier.apply({"battle_kind": "player_attack", "result_kind": "attacker_win"})
	_expect(not bool(malformed.get("ok", true)) and (malformed.get("warnings", []) as Array).has("missing_target_city"), "partial plan rejected safely")
	var unknown := applier.apply({"battle_kind": "unknown", "result_kind": "unknown"})
	_expect(not bool(unknown.get("ok", true)), "unknown plan is non-mutating")

	print("[BATTLE_SETTLEMENT_APPLIER] %s: %d checks, %d failures" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	quit(0 if _failures == 0 else 1)


func _standard_plan(battle_kind: String, result_kind: String, attacker_after: int, defender_after: int, occupation: int, old_owner: String, new_owner: String) -> Dictionary:
	return {
		"battle_kind": battle_kind, "result_kind": result_kind,
		"attacker_city_id": "source", "defender_city_id": "target", "target_city_id": "target",
		"casualty_plan": {"attacker_source_remaining_troops": attacker_after, "defender_remaining_troops": defender_after, "occupied_city_troops": occupation},
		"occupation_troops": occupation,
		"player_troop_outcome": {"wounded": 3}, "enemy_troop_outcome": {"wounded": 4},
		"faction_transfer": {"required": result_kind == "attacker_win" and old_owner != new_owner, "city_id": "target", "old_owner": old_owner, "new_owner": new_owner},
		"hero_status_plan": [{"hero_id": "hero_a", "status": "normal", "outcome": {"current_troops": 10, "max_troops": 20}}],
		"settlement_profile": "standard", "apply_supply_settlement": false,
	}


func _reset_state() -> void:
	_cities = {
		"source": {"owner": "player", "troops": 100, "stock": {"rice": 0, "barley": 0, "salt": 0, "gold": 0}},
		"target": {"owner": "enemy", "troops": 200, "stock": {"rice": 0, "barley": 0, "salt": 0, "gold": 0}},
		"retreat": {"owner": "player", "troops": 50, "stock": {}},
	}
	_heroes = {"hero_a": {"status": "normal", "city_id": "source"}, "hero_b": {"status": "normal", "city_id": "target", "faction_id": "enemy"}}
	_applied_ids.clear()
	_pending_transaction_id = ""
	_wounded.clear()


func _query(query_id: String, args: Array) -> Variant:
	match query_id:
		"has_city": return _cities.has(str(args[0]))
		"city_troops": return _troops(str(args[0]))
		"is_result_applied": return _applied_ids.has(str(args[0]))
		"pending_transaction_id": return _pending_transaction_id
		"nearest_player_retreat_city": return "retreat"
	return null


func _mutation(mutation_id: String, args: Array) -> Variant:
	match mutation_id:
		"set_city_troops": _cities[str(args[0])]["troops"] = int(args[1]); return true
		"set_city_owner": _cities[str(args[0])]["owner"] = str(args[1]); return true
		"add_wounded": _wounded[str(args[0])] = int(_wounded.get(str(args[0]), 0)) + int(args[1]); return true
		"clear_wounded": _wounded[str(args[0])] = 0; return true
		"move_hero": _heroes[str(args[0])]["city_id"] = str(args[1]); return true
		"set_hero_status": _heroes[str(args[0])]["status"] = str(args[1]); return true
		"set_hero_faction":
			_heroes[str(args[0])]["faction_id"] = str(args[1])
			_heroes[str(args[0])]["city_id"] = str(args[2])
			return true
		"unstation_hero": _heroes[str(args[0])]["city_id"] = ""; return true
		"clear_city_governor": return true
		"record_defender_disposition": return true
		"set_defender_supply":
			var supply_city := str(args[0])
			var supply: Dictionary = args[1]
			_cities[supply_city].stock[str(supply.get("food_type", "rice"))] = int(supply.get("remaining_food", 0))
			_cities[supply_city].stock["salt"] = int(supply.get("remaining_salt", 0))
			return {"ok": true, "city_id": supply_city}
		"add_attacker_cargo":
			var cargo_city := str(args[0])
			var cargo: Dictionary = args[1]
			for key in ["food", "salt", "gold"]:
				var resource_id: String = str(cargo.get("food_type", "rice")) if key == "food" else str(key)
				_cities[cargo_city].stock[resource_id] = int(_cities[cargo_city].stock.get(resource_id, 0)) + int(cargo.get(key, 0))
			return {"ok": true, "city_id": cargo_city}
		"mark_result_applied": _applied_ids.append(str(args[0])); return true
	return null


func _troops(city_id: String) -> int:
	return int((_cities.get(city_id, {}) as Dictionary).get("troops", 0))


func _owner(city_id: String) -> String:
	return str((_cities.get(city_id, {}) as Dictionary).get("owner", ""))


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("[BATTLE_SETTLEMENT_APPLIER] FAIL: " + label)
