extends SceneTree

const ServiceScript := preload("res://scripts/worldmap/t03/strategic_battle_transaction_service.gd")

var _checks := 0
var _failures := 0
var _cities: Dictionary = {}
var _player_state: Dictionary = {}
var _heroes: Dictionary = {}
var _wounded: Dictionary = {}
var _resolver_calls := 0
var _resolver_mode := "attacker"
var _pair_eligible := true
var _allow_hero_move := true
var _resource_write_count := 0
var _fail_resource_write_after := -1


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var service := _service()
	_expect(not service.has_method("get_node"), "service is RefCounted without scene-node API")
	_reset()
	_expect(service.make_transaction_id("a", "d") == "t03-7-a-d", "transaction id uses stable turn and city pair")
	_expect(service.select_food_type({"rice": 4, "barley": 9, "seafood": 2}) == "barley", "food type selects largest stock")
	_expect(service.select_food_type({"rice": 1, "barley": 1, "seafood": 1}) == "rice", "food type tie is stable")
	_expect(service.sum_food_stock({"rice": 2, "barley": -4, "seafood": 3}) == 5, "food stock sum clamps malformed negatives")
	var selected_ids: Array[String] = ["ha"]
	var filtered: Array = service.filter_context_heroes([{"hero_id": "ha"}, {"hero_id": "skip"}, "bad"], selected_ids, {"ha": 44})
	_expect(filtered.size() == 1 and int(filtered[0].get("allocated_troops", 0)) == 44, "hero filtering applies allocation")

	var cargo: Dictionary = service.build_expedition_cargo_plan("a", 99)
	_expect(bool(cargo.get("ok", false)) and int(cargo.get("gold", 0)) > 0, "cargo plan meets expedition minimum")
	_expect(int(cargo.get("food_total", 0)) == service.sum_food_stock(cargo.get("food_stock", {})), "cargo plan preserves food breakdown total")
	var before_gold := int((_cities["a"].resources as Dictionary).get("gold", 0))
	var paid: Dictionary = service.pay_expedition_cargo("a", cargo)
	_expect(bool(paid.get("ok", false)) and int((_cities["a"].resources as Dictionary).get("gold", 0)) < before_gold, "cargo payment mutates source stock")

	_reset()
	var prepared: Dictionary = service.prepare(_event(), _context(), "direct")
	_expect(bool(prepared.get("ok", false)) and not (prepared.get("context", {}) as Dictionary).is_empty(), "normal transaction preparation succeeds")
	var prepared_context: Dictionary = prepared.get("context", {})
	_expect(int(prepared_context.get("attacker_total_allocated_troops", 0)) == 99 and int(_cities["a"].troops) == 1, "preparation reserves attacker troops and leaves garrison")
	_expect(int(_cities["d"].troops) == 0 and bool(prepared_context.get("defender_troop_deployed_from_city", false)), "preparation reserves defender troops")
	_expect(str((_player_state.get("pending_invasion_event", {}) as Dictionary).get("stage", "")) == "battle_handoff", "direct preparation advances pending event stage")
	var rolled: Dictionary = service.rollback(prepared_context)
	_expect(bool(rolled.get("ok", false)) and int(_cities["a"].troops) == 100 and int(_cities["d"].troops) == 80, "rollback restores pre-payment troop state")
	_expect(int((_cities["a"].resources as Dictionary).get("gold", 0)) == 5000, "rollback restores paid cargo")

	_reset()
	_cities["a"]["resources"] = {"rice": 0, "barley": 0, "seafood": 0, "gold": 0, "salt": 0}
	var insufficient: Dictionary = service.prepare(_event(), _context(), "automatic")
	_expect(not bool(insufficient.get("ok", true)) and str(insufficient.get("error_code", "")) == "insufficient_cargo", "insufficient cargo rejects before mutation")

	_reset()
	_resolver_mode = "attacker"
	var attacker_tx: Dictionary = service.execute(_event(), _context())
	_expect(bool(attacker_tx.get("ok", false)) and _resolver_calls == 1, "automatic transaction invokes injected resolver once")
	_expect(str(_cities["d"].owner) == "red" and int(_cities["d"].troops) == 30, "attacker victory applies ownership and occupation troops")
	_expect(int((_cities["d"].resources as Dictionary).get("gold", 0)) == 17, "attacker remaining cargo settles into occupied city")
	_expect((_player_state.applied as Array).has("t03-7-a-d-result"), "successful settlement marks result applied")
	_expect((_player_state.get("pending_invasion_event", {}) as Dictionary).is_empty(), "successful settlement clears pending event")
	var calls_after_success := _resolver_calls
	var duplicate: Dictionary = service.execute(_event(), _context())
	_expect(not bool(duplicate.get("ok", true)) and bool(duplicate.get("duplicate", false)) and _resolver_calls == calls_after_success, "duplicate transaction is rejected before resolver")

	_reset()
	_resolver_mode = "defender"
	var defender_tx: Dictionary = service.execute(_event(), _context())
	_expect(bool(defender_tx.get("ok", false)) and str(_cities["d"].owner) == "blue", "defender victory preserves ownership")
	_expect(int(_cities["a"].troops) == 26 and int(_cities["d"].troops) == 40, "defender victory returns healthy survivors to both cities")
	_expect((_wounded.get("a", []) as Array).size() == 1 and (_wounded.get("d", []) as Array).size() == 1, "defender victory records wounded settlement")

	_reset()
	_resolver_mode = "malformed"
	var malformed: Dictionary = service.execute(_event(), _context())
	_expect(not bool(malformed.get("ok", true)) and bool(malformed.get("cargo_rolled_back", false)), "malformed resolver result rolls transaction back")
	_expect(int(_cities["a"].troops) == 100 and int((_cities["a"].resources as Dictionary).get("gold", 0)) == 5000, "resolver rollback restores troops and resources")

	_reset()
	_resolver_mode = "attacker"
	_fail_resource_write_after = 1
	var settlement_failure: Dictionary = service.execute(_event(), _context())
	_expect(not bool(settlement_failure.get("ok", true)) and bool(settlement_failure.get("cargo_rolled_back", false)), "settlement mutation failure rolls transaction back")
	_expect(int(_cities["a"].troops) == 100 and str(_cities["d"].owner) == "blue", "settlement rollback restores pre-transaction domain state")

	_reset()
	_pair_eligible = false
	var invalid: Dictionary = service.prepare(_event(), _context(), "automatic")
	_expect(str(invalid.get("error_code", "")) == "ineligible_invasion_pair", "partial or invalid request fails structurally")

	_finish()


func _service() -> RefCounted:
	var service := ServiceScript.new()
	service.configure(Callable(self, "_query"), Callable(self, "_mutation"), Callable(self, "_resolve"), {"minimum_source_troops": 1, "normal_wounded_turns": 3})
	return service


func _reset() -> void:
	_cities = {
		"a": {"owner": "red", "troops": 100, "defense": 2, "resources": {"rice": 500, "barley": 300, "seafood": 200, "gold": 5000, "salt": 500}},
		"d": {"owner": "blue", "troops": 80, "defense": 3, "resources": {"rice": 400, "barley": 200, "seafood": 100, "gold": 1000, "salt": 300}},
		"r": {"owner": "blue", "troops": 10, "defense": 1, "resources": {"rice": 10, "barley": 10, "seafood": 10, "gold": 10, "salt": 10}},
	}
	_player_state = {"turn": 7, "scenario": "test", "pending_invasion_event": _event(), "pending_battle_context": {}, "applied": []}
	_heroes = {"ha": "a", "hd": "d"}
	_wounded = {}
	_resolver_calls = 0
	_pair_eligible = true
	_allow_hero_move = true
	_resource_write_count = 0
	_fail_resource_write_after = -1


func _event() -> Dictionary:
	return {"attacker_city_id": "a", "defender_city_id": "d", "transaction_id": "t03-7-a-d", "stage": "automatic_resolution"}


func _context() -> Dictionary:
	return {
		"attacker_city_id": "a", "defender_city_id": "d",
		"attacker_main_hero_ids": ["ha"], "defender_main_hero_ids": ["hd"],
		"attacker_heroes": [{"hero_id": "ha", "command_limit": 200}],
		"defender_heroes": [{"hero_id": "hd", "command_limit": 200}],
	}


func _query(query_id: String, args: Array) -> Variant:
	match query_id:
		"turn_number": return _player_state.get("turn", 1)
		"scenario_id": return _player_state.get("scenario", "")
		"invasion_pair_eligible": return _pair_eligible
		"has_city": return _cities.has(str(args[0]))
		"city_troops": return int((_cities.get(str(args[0]), {}) as Dictionary).get("troops", 0))
		"city_owner": return str((_cities.get(str(args[0]), {}) as Dictionary).get("owner", ""))
		"player_faction": return "blue"
		"city_owned_by_player": return str((_cities.get(str(args[0]), {}) as Dictionary).get("owner", "")) == "blue"
		"build_troop_allocation": return {str((args[0] as Array)[0]): int(args[1])}
		"city_resource_amount": return int(((_cities.get(str(args[0]), {}) as Dictionary).get("resources", {}) as Dictionary).get(str(args[1]), 0))
		"city_resource_stock": return ((_cities.get(str(args[0]), {}) as Dictionary).get("resources", {}) as Dictionary).duplicate(true)
		"city_defense": return float((_cities.get(str(args[0]), {}) as Dictionary).get("defense", 0))
		"player_defense_bonus": return 0.02
		"serialize_state": return {"player_state": _player_state.duplicate(true), "cities": _cities.duplicate(true), "heroes": _heroes.duplicate(true), "wounded": _wounded.duplicate(true)}
		"result_applied": return (_player_state.applied as Array).has(str(args[0]))
		"pending_invasion_transaction_id": return str((_player_state.get("pending_invasion_event", {}) as Dictionary).get("transaction_id", ""))
	return null


func _mutation(mutation_id: String, args: Array) -> Variant:
	match mutation_id:
		"set_resource_stock":
			_resource_write_count += 1
			if _fail_resource_write_after >= 0 and _resource_write_count > _fail_resource_write_after:
				return false
			_cities[str(args[0])]["resources"] = (args[1] as Dictionary).duplicate(true)
			return true
		"set_city_troops":
			_cities[str(args[0])]["troops"] = int(args[1])
			return true
		"set_city_owner":
			_cities[str(args[0])]["owner"] = str(args[1])
			return true
		"move_pending_generals": return _allow_hero_move
		"move_hero":
			_heroes[str(args[0])] = str(args[1])
			return true
		"add_wounded":
			var entries: Array = _wounded.get(str(args[0]), [])
			entries.append({"troops": int(args[1]), "turns": int(args[2])})
			_wounded[str(args[0])] = entries
			return true
		"clear_wounded":
			_wounded[str(args[0])] = []
			return true
		"settle_defender_generals": return {"primary_escape_city_id": "r", "aligned_count": 0, "escaped_count": 1}
		"set_pending_invasion_event":
			_player_state["pending_invasion_event"] = (args[0] as Dictionary).duplicate(true)
			return true
		"set_pending_battle_context":
			_player_state["pending_battle_context"] = (args[0] as Dictionary).duplicate(true)
			return true
		"mark_result_applied":
			(_player_state.applied as Array).append(str(args[0]))
			return true
		"clear_transaction_state":
			_player_state["pending_invasion_event"] = {}
			_player_state["pending_battle_context"] = {}
			return true
		"apply_state":
			var snapshot := args[0] as Dictionary
			_player_state = (snapshot.get("player_state", {}) as Dictionary).duplicate(true)
			_cities = (snapshot.get("cities", {}) as Dictionary).duplicate(true)
			_heroes = (snapshot.get("heroes", {}) as Dictionary).duplicate(true)
			_wounded = (snapshot.get("wounded", {}) as Dictionary).duplicate(true)
			return true
	return null


func _resolve(context: Dictionary) -> Dictionary:
	_resolver_calls += 1
	if _resolver_mode == "malformed":
		return {"transaction_id": str(context.get("transaction_id", ""))}
	var attacker_won := _resolver_mode == "attacker"
	return {
		"transaction_id": str(context.get("transaction_id", "")), "result_id": "%s-result" % str(context.get("transaction_id", "")),
		"attacker_city_id": "a", "attacker_source_city_id": "a", "defender_city_id": "d",
		"attacker_owner": "red", "defender_owner": "blue", "winner_side": "attacker" if attacker_won else "defender",
		"attacker_healthy_survivors": 30 if attacker_won else 25, "defender_healthy_survivors": 0 if attacker_won else 40,
		"attacker_wounded": 4, "defender_wounded": 5,
		"attacker_general_ids": ["ha"], "defender_general_ids": ["hd"],
		"attacker_surviving_general_ids": ["ha"], "defender_surviving_general_ids": ["hd"],
		"attacker_remaining_food_stock": {"rice": 3, "barley": 2, "seafood": 1}, "attacker_remaining_gold": 7, "attacker_remaining_salt": 2,
		"defender_remaining_food_stock": {"rice": 9, "barley": 8, "seafood": 7}, "defender_remaining_gold": 10, "defender_remaining_salt": 6,
	}


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if condition:
		print("[T03_TRANSACTION_PASS] %s" % label)
	else:
		_failures += 1
		push_error("[T03_TRANSACTION_FAIL] %s" % label)


func _finish() -> void:
	print("[T03_TRANSACTION_SERVICE] %s: %d checks, %d failures" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	quit(0 if _failures == 0 else 1)
