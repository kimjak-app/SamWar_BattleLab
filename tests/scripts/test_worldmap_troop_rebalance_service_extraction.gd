extends SceneTree

const ServiceScript := preload("res://scripts/worldmap/military/troop_rebalance_service.gd")

var _checks := 0
var _failures := 0
var _troops := {"rear": 80, "front": 10, "other": 25}
var _last: Array = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var service := ServiceScript.new()
	service.configure(Callable(self, "_query"), Callable(self, "_mutation"), {"role_target_garrison_ratio": {"rear": 0.2, "frontline": 0.5}})
	var suggestions: Array = service.calculate_suggestions()
	_expect(suggestions.size() == 1, "rebalance computes one valid transfer")
	_expect(str(suggestions[0].from) == "rear" and str(suggestions[0].to) == "front", "rebalance selects rear supplier and frontline demand")
	_expect(int(suggestions[0].amount) == 40, "rebalance caps transfer at frontline shortage")
	_expect(_last.is_empty() and _troops.rear == 80, "suggestion calculation is pure")
	var applied: Dictionary = service.apply_suggestion(suggestions[0])
	_expect(bool(applied.ok) and _troops.rear == 40 and _troops.front == 50, "rebalance apply reuses troop movement mutation")
	_expect(str(service.apply_suggestion({}).error_code) == "malformed_suggestion", "malformed suggestion is rejected")
	_expect(str(service.apply_suggestion({"from": "rear", "to": "missing", "amount": 1}).error_code) == "move_not_allowed", "invalid move is rejected")
	_finish()


func _query(query_id: String, args: Array) -> Variant:
	match query_id:
		"supply_states": return {"city_states": {"rear": {"role": "rear"}, "front": {"role": "frontline"}, "other": {"role": "rear"}}}
		"owned_city_ids": return ["rear", "front", "other"]
		"has_city": return _troops.has(str(args[0]))
		"city_population": return 100
		"city_troops": return int(_troops.get(str(args[0]), 0))
		"can_move_troops": return {"ok": _troops.has(str(args[0])) and _troops.has(str(args[1])) and int(args[2]) > 0 and int(_troops.get(str(args[0]), 0)) >= int(args[2])}
	return null


func _mutation(mutation_id: String, args: Array) -> Variant:
	match mutation_id:
		"set_last_suggestions": _last = (args[0] as Array).duplicate(true)
		"move_troops":
			_troops[str(args[0])] = int(_troops[str(args[0])]) - int(args[2])
			_troops[str(args[1])] = int(_troops[str(args[1])]) + int(args[2])
		_: return null
	return true


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if condition: print("[REBALANCE_PASS] %s" % label)
	else:
		_failures += 1
		push_error("[REBALANCE_FAIL] %s" % label)


func _finish() -> void:
	print("[TROOP_REBALANCE] %s: %d checks, %d failures" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	quit(0 if _failures == 0 else 1)
