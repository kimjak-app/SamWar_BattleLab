extends SceneTree

const ServiceScript := preload("res://scripts/worldmap/military/wounded_recovery_service.gd")

var _checks := 0
var _failures := 0
var _cities: Dictionary = {}
var _heroes: Dictionary = {}
var _player: Dictionary = {}


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var service: RefCounted = _service()
	_expect(not service.has_method("get_node"), "service is RefCounted without scene-node API")
	_reset()
	var source_city: Dictionary = (_cities["a"] as Dictionary).duplicate(true)
	var empty_queue: Array = service.get_city_wounded_queue(source_city)
	_expect(empty_queue.is_empty(), "empty wounded queue reads as empty")
	source_city["woundedQueue"] = [{"troops": 4, "turnsLeft": 2}]
	var normalized: Array = service.get_city_wounded_queue(source_city)
	normalized[0]["troops"] = 99
	_expect(int(((source_city.woundedQueue as Array)[0] as Dictionary).troops) == 4, "queue read returns a detached snapshot")

	var added: Dictionary = service.add_wounded_to_city("a", 12, 3, "normal", "battle-1")
	_expect(bool(added.ok) and (_queue("a").size() == 1), "wounded troop batch is added")
	_expect(int((_queue("a")[0] as Dictionary).wounded_count) == 12 and int((_queue("a")[0] as Dictionary).recovery_months_remaining) == 3, "queue preserves wounded count and recovery months")
	var duplicate: Dictionary = service.add_wounded_to_city("a", 12, 3, "normal", "battle-1")
	_expect(bool(duplicate.ok) and bool(duplicate.duplicate) and _queue("a").size() == 1, "duplicate transaction batch is idempotent")
	var cleared: Dictionary = service.clear_city_wounded_queue("a")
	_expect(bool(cleared.ok) and _queue("a").is_empty(), "queue clear writes both queue aliases")
	_expect((_cities["a"] as Dictionary).has("woundedQueue") and (_cities["a"] as Dictionary).has("wounded_queue"), "legacy and snake-case queue keys remain compatible")

	_reset()
	var wounded_status: Dictionary = service.apply_battle_hero_status("h1", "wounded", {"current_troops": 7, "max_troops": 20}, "battle-2")
	_expect(bool(wounded_status.ok) and bool((_heroes.h1 as Dictionary).wounded), "battle settlement status registers wounded hero")
	_expect(int((_heroes.h1 as Dictionary).wounded_turns_remaining) == 3, "normal hero recovery remains three months")
	_expect(str((_heroes.h1 as Dictionary).last_battle_transaction_id) == "battle-2", "battle transaction marker is retained")
	var duplicate_status: Dictionary = service.apply_battle_hero_status("h1", "wounded", {}, "battle-2")
	_expect(bool(duplicate_status.duplicate) and int((_heroes.h1 as Dictionary).wounded_turns_remaining) == 3, "duplicate settlement cannot reset recovery")
	_expect(str(service.apply_battle_hero_status("", "wounded", {}, "").error_code) == "missing_hero", "malformed hero id is rejected")
	_expect(str(service.apply_battle_hero_status("missing", "wounded", {}, "").error_code) == "missing_hero", "missing hero is rejected")
	_expect(str(service.apply_battle_hero_status("h1", "unknown", {}, "").error_code) == "invalid_status", "malformed status is rejected")

	var month_one: Dictionary = service.advance_recovery_month(1)
	_expect(bool(month_one.ok) and int((_heroes.h1 as Dictionary).wounded_turns_remaining) == 2, "natural recovery advances once")
	var month_duplicate: Dictionary = service.advance_recovery_month(1)
	_expect(bool(month_duplicate.duplicate) and int((_heroes.h1 as Dictionary).wounded_turns_remaining) == 2, "same month recovery is idempotent")
	service.advance_recovery_month(2)
	var month_three: Dictionary = service.advance_recovery_month(3)
	_expect(not bool((_heroes.h1 as Dictionary).wounded) and str((_heroes.h1 as Dictionary).status) == "normal", "completed recovery clears wounded hero state")
	_expect((month_three.recovered_hero_ids as Array).has("h1"), "completion reports recovered hero id")

	_reset()
	service.add_wounded_to_city("a", 10, 1, "normal", "troops-a")
	service.add_wounded_to_city("b", 6, 2, "normal", "troops-b")
	service.apply_battle_hero_status("h1", "wounded", {}, "heroes")
	service.apply_battle_hero_status("h2", "wounded", {}, "heroes")
	var progressed: Dictionary = service.advance_recovery_month(4)
	_expect(int((_cities.a as Dictionary).troops) == 110 and _queue("a").is_empty(), "recovered troops return to city and completed queue entry is removed")
	_expect(int((_cities.b as Dictionary).troops) == 50 and int((_queue("b")[0] as Dictionary).recovery_months_remaining) == 1, "different city queues progress independently")
	_expect((progressed.hero_changes as Array).size() == 2, "multiple wounded heroes progress together")

	_reset()
	service.add_wounded_to_city("a", 20, 3, "normal", "fast-1")
	service.apply_battle_hero_status("h1", "wounded", {}, "fast-1")
	var treatment := {"city_id": "a", "transaction_id": "fast-1", "wounded_count": 20, "mode": "normal"}
	var eligibility: Dictionary = service.evaluate_fast_treatment(treatment)
	_expect(bool(eligibility.ok) and int(eligibility.required_salt) > 0, "fast treatment domain eligibility reports cost")
	var salt_before := int(((_cities.a as Dictionary).resources as Dictionary).salt)
	var treated: Dictionary = service.apply_fast_treatment(treatment)
	var salt_after := int(((_cities.a as Dictionary).resources as Dictionary).salt)
	_expect(bool(treated.ok) and salt_after == salt_before - int(eligibility.required_salt), "fast treatment deducts exact salt cost")
	_expect(str((_queue("a")[0] as Dictionary).recovery_mode) == "fast" and int((_queue("a")[0] as Dictionary).recovery_months_remaining) == 1, "fast treatment changes matching troop queue to one month")
	_expect(int((_heroes.h1 as Dictionary).wounded_turns_remaining) == 1 and (treated.treated_hero_ids as Array).has("h1"), "fast treatment shortens matching wounded hero recovery")
	_expect(str((_player.last_wounded_treatment as Dictionary).mode) == "fast", "fast treatment updates lifecycle state")

	_reset()
	service.add_wounded_to_city("a", 20, 3, "normal", "no-salt")
	((_cities.a as Dictionary).resources as Dictionary)["salt"] = 0
	var insufficient: Dictionary = service.apply_fast_treatment({"city_id": "a", "transaction_id": "no-salt", "wounded_count": 20, "mode": "normal"})
	_expect(str(insufficient.error_code) == "insufficient_salt" and int(((_cities.a as Dictionary).resources as Dictionary).salt) == 0, "insufficient salt fails without mutation")
	_expect(str(service.apply_fast_treatment({"city_id": "missing", "transaction_id": "x", "wounded_count": 1}).error_code) == "missing_city", "missing city treatment is rejected")
	_expect(str(service.apply_fast_treatment({"city_id": "a", "transaction_id": "x", "wounded_count": 0}).error_code) == "empty_wounded_count", "empty wounded treatment is rejected")
	_expect(str(service.apply_fast_treatment({"city_id": "a", "transaction_id": "x", "wounded_count": 1, "mode": "fast"}).error_code) == "already_fast", "already-fast treatment is rejected")

	_expect(service.world_month_serial(1) == 0 and service.world_month_serial(40) == 11 and service.world_month_serial(41) == 12, "forty world turns preserve twelve-month calendar mapping")
	_finish()


func _service() -> RefCounted:
	var service := ServiceScript.new()
	service.configure(Callable(self, "_query"), Callable(self, "_mutation"), {
		"normal_status": "normal", "wounded_status": "wounded", "captured_status": "captured", "dead_status": "dead",
		"allowed_statuses": ["normal", "wounded", "captured", "dead"], "normal_recovery_months": 3,
		"fast_recovery_months": 1, "world_calendar_year_turns": 40,
	})
	return service


func _reset() -> void:
	_cities = {
		"a": {"troops": 100, "resources": {"salt": 500}, "woundedQueue": [], "wounded_queue": []},
		"b": {"troops": 50, "resources": {"salt": 500}, "woundedQueue": [], "wounded_queue": []},
	}
	_heroes = {
		"h1": {"current_city_id": "a", "status": "normal", "wounded": false, "captured": false, "dead": false, "wounded_turns_remaining": 0},
		"h2": {"current_city_id": "b", "status": "normal", "wounded": false, "captured": false, "dead": false, "wounded_turns_remaining": 0},
	}
	_player = {"last_wounded_recovery_month_serial": -1, "last_wounded_treatment": {}}


func _queue(city_id: String) -> Array:
	return ((_cities.get(city_id, {}) as Dictionary).get("woundedQueue", []) as Array)


func _query(query_id: String, args: Array) -> Variant:
	match query_id:
		"has_hero": return _heroes.has(str(args[0]))
		"hero_state": return (_heroes.get(str(args[0]), {}) as Dictionary).duplicate(true)
		"hero_ids": return _heroes.keys()
		"has_city": return _cities.has(str(args[0]))
		"city_ids": return _cities.keys()
		"city_state": return (_cities.get(str(args[0]), {}) as Dictionary).duplicate(true)
		"city_troops": return int((_cities.get(str(args[0]), {}) as Dictionary).get("troops", 0))
		"city_resource_amount": return int(((_cities.get(str(args[0]), {}) as Dictionary).get("resources", {}) as Dictionary).get(str(args[1]), 0))
		"last_recovery_month_serial": return int(_player.get("last_wounded_recovery_month_serial", -1))
	return null


func _mutation(mutation_id: String, args: Array) -> Variant:
	match mutation_id:
		"set_hero_state":
			_heroes[str(args[0])] = (args[1] as Dictionary).duplicate(true)
			return true
		"set_city_wounded_queue":
			var queue := (args[1] as Array).duplicate(true)
			_cities[str(args[0])]["woundedQueue"] = queue
			_cities[str(args[0])]["wounded_queue"] = queue.duplicate(true)
			return true
		"set_city_troops":
			_cities[str(args[0])]["troops"] = int(args[1])
			return true
		"set_city_resource_amount":
			(_cities[str(args[0])]["resources"] as Dictionary)[str(args[1])] = int(args[2])
			return true
		"set_last_recovery_month_serial":
			_player["last_wounded_recovery_month_serial"] = int(args[0])
			return true
		"set_last_wounded_treatment":
			_player["last_wounded_treatment"] = (args[0] as Dictionary).duplicate(true)
			return true
	return null


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if condition:
		print("[WOUNDED_RECOVERY_PASS] %s" % label)
	else:
		_failures += 1
		push_error("[WOUNDED_RECOVERY_FAIL] %s" % label)


func _finish() -> void:
	print("[WOUNDED_RECOVERY_SERVICE] %s: %d checks, %d failures" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	quit(0 if _failures == 0 else 1)
