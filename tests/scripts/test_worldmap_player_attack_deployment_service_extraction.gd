extends SceneTree

const ServiceScript := preload("res://scripts/worldmap/military/player_attack_deployment_service.gd")

var _checks := 0
var _failures := 0
var _cities: Dictionary = {}
var _heroes: Dictionary = {}
var _expected_source := "a"
var _attack_block := ""
var _route_block := ""


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var service: RefCounted = _service()
	_reset()
	var payload: Dictionary = service.build_payload("a", "d", "manual")
	_expect(str(payload.source_city_id) == "a" and str(payload.target_city_id) == "d", "deployment payload preserves source and target")
	_expect(int(payload.source_troops) == 100 and int(payload.max_deployable_troops) == 99, "payload preserves minimum source garrison")
	_expect((payload.heroes as Array).size() == 2, "deployable hero list excludes captured or wounded hero")
	_expect(bool(payload.naval_route_required) and bool(payload.siege_required), "payload includes route domain facts")
	_expect(int(payload.rice_available) == 500 and int(payload.gold_available) == 500, "payload includes supply stock")
	var copied_heroes: Array = payload.heroes
	copied_heroes.clear()
	_expect((_cities.a as Dictionary).stationed_hero_ids.size() == 3, "payload snapshot cannot mutate city state")
	_expect(service.build_payload("missing", "d").is_empty(), "missing source payload fails")
	_cities.a.troops = 1
	_expect(service.build_payload("a", "d").is_empty(), "no deployable troops payload fails")

	_reset()
	var normal := _deployment(service, 60, 80, 40, 2)
	var validated: Dictionary = service.validate(normal)
	_expect(bool(validated.ok) and int(validated.total_troops) == 60, "normal deployment validates")
	_expect(int((validated.attacker_troop_allocation as Dictionary).h1) == 60, "allocation is preserved below command limit")
	var clamped := _deployment(service, 90, 80, 40, 2)
	var clamped_result: Dictionary = service.validate(clamped)
	_expect(bool(clamped_result.ok) and int((clamped_result.attacker_troop_allocation as Dictionary).h1) == 80, "allocation clamps to hero command limit")
	_expect(int(clamped_result.total_troops) <= 99, "allocation preserves source garrison")
	_expected_source = "b"
	_expect(str(service.validate(normal).error_code) == "source_mismatch", "non-adjacent or wrong source fails")
	_expected_source = "a"
	_attack_block = "blocked"
	_expect(str(service.validate(normal).error_code) == "attack_blocked", "blocked target fails")
	_attack_block = ""
	_route_block = "naval_locked"
	_expect(str(service.validate(normal).error_code) == "route_locked", "naval or siege lock fails")
	_route_block = ""
	var no_hero := normal.duplicate(true)
	no_hero["selected_hero_ids"] = []
	_expect(str(service.validate(no_hero).error_code) == "no_hero", "no hero fails")
	var excluded := normal.duplicate(true)
	excluded["selected_hero_ids"] = ["h3"]
	excluded["attacker_troop_allocation"] = {"h3": 10}
	_expect(str(service.validate(excluded).error_code) == "hero_unavailable", "captured hero fails")
	var no_command := normal.duplicate(true)
	no_command["selected_hero_ids"] = ["h2"]
	no_command["attacker_troop_allocation"] = {"h2": 10}
	_heroes.h2.excluded = false
	_heroes.h2.command_limit = 0
	_expect(str(service.validate(no_command).error_code) == "missing_command_limit", "missing command limit fails")
	var zero := normal.duplicate(true)
	zero["attacker_troop_allocation"] = {"h1": 0}
	_expect(str(service.validate(zero).error_code) == "zero_hero_troops", "zero troop allocation fails")
	var malformed: Dictionary = service.validate({})
	_expect(str(malformed.error_code) == "malformed_deployment", "malformed deployment fails structurally")

	var invalid_food := normal.duplicate(true)
	invalid_food["attacker_food_type"] = "wood"
	_expect(str(service.validate(invalid_food).error_code) == "invalid_food_type", "invalid food type fails")
	var low_food := normal.duplicate(true)
	low_food["attacker_food_amount"] = 0
	_expect(str(service.validate(low_food).error_code) == "insufficient_minimum_food", "minimum food is enforced")
	var low_gold := normal.duplicate(true)
	low_gold["attacker_carried_gold"] = 0
	_expect(str(service.validate(low_gold).error_code) == "insufficient_minimum_gold", "minimum gold is enforced")
	var excessive := normal.duplicate(true)
	excessive["attacker_food_amount"] = 9999
	_expect(str(service.validate(excessive).error_code) == "insufficient_rice", "city food affordability is enforced")
	var excessive_gold := normal.duplicate(true)
	excessive_gold["attacker_carried_gold"] = 9999
	_expect(str(service.validate(excessive_gold).error_code) == "insufficient_gold", "city gold affordability is enforced")
	var excessive_salt := normal.duplicate(true)
	excessive_salt["attacker_salt_amount"] = 9999
	_expect(str(service.validate(excessive_salt).error_code) == "insufficient_salt", "city salt affordability is enforced")
	var cost: Dictionary = service.calculate_supply_cost(100)
	_expect(int(cost.food) > 0 and int(cost.gold) > 0 and int(cost.salt) == 0, "existing expedition calculator supplies minimum cost")
	var selected: Dictionary = service.select_city_battle_supply("a")
	_expect(str(selected.food_type) == "rice" and int(selected.food_amount) == 500, "largest city food type is selected")

	_reset()
	var cargo := {"food_type": "rice", "food": 20, "gold": 10, "salt": 2}
	var paid: Dictionary = service.pay_supply("a", cargo, "pay-1")
	_expect(bool(paid.ok) and int((_cities.a.resources as Dictionary).rice) == 480, "supply payment deducts selected resources")
	var paid_twice: Dictionary = service.pay_supply("a", cargo, "pay-1")
	_expect(bool(paid_twice.duplicate) and int((_cities.a.resources as Dictionary).rice) == 480, "supply payment is idempotent by transaction")
	var context := {"transaction_id": "depart-1", "attacker_source_city_id": "a", "attacker_total_allocated_troops": 40}
	var pre: Dictionary = service.apply_context_side_pre_decrement(context, "attacker", "troop_deployed_from_city")
	_expect(int(_cities.a.troops) == 60 and bool(pre.troop_deployed_from_city), "troop pre-decrement mutates city and marks context")
	var pre_duplicate: Dictionary = service.apply_context_side_pre_decrement(pre, "attacker", "troop_deployed_from_city")
	_expect(int(_cities.a.troops) == 60 and int(pre_duplicate.attacker_source_city_troops_before) == 100, "troop pre-decrement flag prevents duplicate deduction")

	_reset()
	var hero_ids: Array[String] = ["h1"]
	var moved: Dictionary = service.move_generals_for_expedition("a", hero_ids)
	_expect(bool(moved.ok) and not (_cities.a.stationed_hero_ids as Array).has("h1"), "expedition movement removes stationed hero")
	_expect(str(_heroes.h1.status) == "deployed" and str(_heroes.h1.current_city_id).is_empty(), "expedition movement updates hero lifecycle state")

	_reset()
	var departure_context := {
		"source": "player_attack", "transaction_id": "departure-1",
		"attacker_source_city_id": "a", "attacker_total_allocated_troops": 40,
		"defender_source_city_id": "d", "defender_total_allocated_troops": 20,
		"attacker_food_type": "rice", "attacker_food_amount": 20,
		"attacker_carried_gold": 10, "attacker_salt_amount": 2,
		"attacker_general_ids": ["h1"],
	}
	var departure: Dictionary = service.apply_departure(departure_context, hero_ids, cargo)
	_expect(bool(departure.ok) and int(_cities.a.troops) == 60 and int(_cities.d.troops) == 60, "departure atomically pre-decrements both sides")
	var duplicate_departure: Dictionary = service.apply_departure(departure_context, hero_ids, cargo)
	_expect(bool(duplicate_departure.duplicate) and int(_cities.a.troops) == 60, "duplicate departure does not repeat mutation")
	var rollback: Dictionary = service.rollback_departure(departure.context)
	_expect(bool(rollback.ok) and int(_cities.a.troops) == 100 and int(_cities.d.troops) == 80, "handoff rollback restores troop snapshots")
	_expect(int((_cities.a.resources as Dictionary).rice) == 500 and (_cities.a.stationed_hero_ids as Array).has("h1"), "handoff rollback restores supply and hero location")
	var rollback_twice: Dictionary = service.rollback_departure(departure.context)
	_expect(bool(rollback_twice.duplicate) and int((_cities.a.resources as Dictionary).rice) == 500, "rollback is idempotent")

	_finish()


func _deployment(service: RefCounted, troops: int, command_limit: int, food: int, salt: int) -> Dictionary:
	_heroes.h1.command_limit = command_limit
	var minimum: Dictionary = service.calculate_supply_cost(troops)
	return {"source_city_id": "a", "target_city_id": "d", "selected_hero_ids": ["h1"], "attacker_troop_allocation": {"h1": troops}, "attacker_food_type": "rice", "attacker_food_amount": maxi(food, int(minimum.food)), "attacker_carried_gold": int(minimum.gold), "attacker_salt_amount": salt, "supply_cost": minimum}


func _service() -> RefCounted:
	var service := ServiceScript.new()
	service.configure(Callable(self, "_query"), Callable(self, "_mutation"), {"minimum_source_garrison": 1, "gold_resource_id": "gold", "salt_resource_id": "salt", "default_command_rank": "officer", "default_command_label": "군관"})
	return service


func _reset() -> void:
	_cities = {
		"a": {"owner": "player", "troops": 100, "stationed_hero_ids": ["h1", "h2", "h3"], "resources": {"rice": 500, "barley": 200, "seafood": 100, "gold": 500, "salt": 50}},
		"b": {"owner": "player", "troops": 40, "stationed_hero_ids": [], "resources": {"rice": 50, "barley": 50, "seafood": 50, "gold": 50, "salt": 5}},
		"d": {"owner": "enemy", "troops": 80, "stationed_hero_ids": [], "resources": {"rice": 50, "barley": 50, "seafood": 50, "gold": 50, "salt": 5}},
	}
	_heroes = {
		"h1": {"display_name": "H1", "current_city_id": "a", "status": "normal", "excluded": false, "command_limit": 80, "war": 70},
		"h2": {"display_name": "H2", "current_city_id": "a", "status": "normal", "excluded": false, "command_limit": 50, "war": 50},
		"h3": {"display_name": "H3", "current_city_id": "a", "status": "captured", "excluded": true, "command_limit": 50, "war": 50},
	}
	_expected_source = "a"
	_attack_block = ""
	_route_block = ""


func _query(query_id: String, args: Array) -> Variant:
	match query_id:
		"has_city": return _cities.has(str(args[0]))
		"city_owned_by_player": return str((_cities.get(str(args[0]), {}) as Dictionary).get("owner", "")) == "player"
		"city_troops": return int((_cities.get(str(args[0]), {}) as Dictionary).get("troops", 0))
		"city_resource_amount": return int(((_cities.get(str(args[0]), {}) as Dictionary).get("resources", {}) as Dictionary).get(str(args[1]), 0))
		"city_resource_stock": return ((_cities.get(str(args[0]), {}) as Dictionary).get("resources", {}) as Dictionary).duplicate(true)
		"city_stationed_hero_ids": return ((_cities.get(str(args[0]), {}) as Dictionary).get("stationed_hero_ids", []) as Array).duplicate()
		"has_hero": return _heroes.has(str(args[0]))
		"hero_data", "hero_state": return (_heroes.get(str(args[0]), {}) as Dictionary).duplicate(true)
		"hero_excluded": return bool((_heroes.get(str(args[0]), {}) as Dictionary).get("excluded", true))
		"hero_state_badge": return ""
		"hero_command_summary": return {"command_rank": "officer", "command_label": "군관", "command_limit": int((_heroes.get(str(args[0]), {}) as Dictionary).get("command_limit", 0))}
		"attack_block_reason": return _attack_block
		"expected_attack_source": return _expected_source
		"naval_siege_unlock_block_reason": return _route_block
		"naval_route_required", "siege_target": return true
		"naval_unlock", "siege_unlock": return {"unlocked": true}
	return null


func _mutation(mutation_id: String, args: Array) -> Variant:
	match mutation_id:
		"set_city_troops": _cities[str(args[0])]["troops"] = int(args[1])
		"set_city_resource_stock": _cities[str(args[0])]["resources"] = (args[1] as Dictionary).duplicate(true)
		"set_city_stationed_hero_ids": _cities[str(args[0])]["stationed_hero_ids"] = (args[1] as Array).duplicate()
		"set_hero_state": _heroes[str(args[0])] = (args[1] as Dictionary).duplicate(true)
		"restore_hero_to_city":
			var hero_id := str(args[0])
			var city_id := str(args[1])
			_heroes[hero_id]["current_city_id"] = city_id
			_heroes[hero_id]["status"] = "normal"
			if not (_cities[city_id].stationed_hero_ids as Array).has(hero_id): _cities[city_id].stationed_hero_ids.append(hero_id)
		_: return null
	return true


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if condition: print("[DEPLOYMENT_PASS] %s" % label)
	else:
		_failures += 1
		push_error("[DEPLOYMENT_FAIL] %s" % label)


func _finish() -> void:
	print("[PLAYER_ATTACK_DEPLOYMENT] %s: %d checks, %d failures" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	quit(0 if _failures == 0 else 1)
