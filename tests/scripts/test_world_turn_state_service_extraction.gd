extends SceneTree

const StateScript := preload("res://scripts/worldmap/turn/world_turn_state_service.gd")

var _checks := 0
var _failures := 0
var _results := {}


func _initialize() -> void:
	var service := StateScript.new()
	_expect(StateScript.CITY_PUBLIC_SUPPORT_DEFAULT == 70, "default public support parity")
	var minimum := service.calculate_public_support_delta("hanseong", 100, false, false, {"isolated": true})
	_expect(int(minimum.get("delta", 0)) == StateScript.PUBLIC_SUPPORT_DELTA_MIN, "public support minimum clamp")
	var maximum := service.calculate_public_support_delta("hanseong", 0, true, true)
	_expect(int(maximum.get("delta", 0)) == StateScript.PUBLIC_SUPPORT_DELTA_MAX, "public support maximum clamp")
	_expect(service.calculate_loyalty_delta_from_public_support(100) == 2 and service.calculate_loyalty_delta_from_public_support(0) == -3, "public support loyalty thresholds")
	var hero_security := service.calculate_city_loyalty_drift(
		{"id": "hanseong", "troops": 400, "population": 1000, "commerce_rating": 3, "population_rating": 3},
		{"tax_delta": -2, "stationed_hero_troops": 200, "security_required_troops": 500, "governor_controls_loss": true, "city_effects": {}},
		{}
	)
	_expect(int(hero_security.get("security_troops", 0)) == 600 and int(hero_security.get("security_delta", 0)) == 1, "stationed hero security modifier")
	_expect(int(hero_security.get("delta", 0)) == -1 and int(hero_security.get("control_delta", 0)) == 1, "loyalty drift component parity")
	var minimum_loyalty := service.calculate_city_loyalty_drift(
		{"id": "sabi", "troops": 600, "population": 1000, "commerce_rating": 1, "population_rating": 1},
		{"tax_delta": -3, "stationed_hero_troops": 0, "security_required_troops": 1000, "governor_controls_loss": false, "city_effects": {}},
		{"loyalty_delta": -2, "security_delta": -1}
	)
	_expect(int(minimum_loyalty.get("delta", 0)) == StateScript.CITY_LOYALTY_DRIFT_MIN, "loyalty minimum clamp")
	var maximum_loyalty := service.calculate_city_loyalty_drift(
		{"id": "gyeongju", "troops": 1200, "population": 10000, "commerce_rating": 5, "population_rating": 5},
		{"tax_delta": 1, "stationed_hero_troops": 0, "security_required_troops": 500, "governor_controls_loss": false, "city_effects": {}},
		{"loyalty_delta": 1}
	)
	_expect(int(maximum_loyalty.get("delta", 0)) == StateScript.CITY_LOYALTY_DRIFT_MAX, "loyalty maximum clamp")
	service.configure(Callable(self, "_query_invalid_city"), Callable(self, "_mutation_capture"))
	var invalid_result := service.apply_public_support_tick(30)
	_expect((invalid_result.get("city_results", {}) as Dictionary).is_empty(), "missing city ignored safely")
	_expect(_results.has("last_public_support_result"), "invalid tick still stores schema-compatible result")
	print("[WORLD_TURN_STATE_SERVICE] %s: %d checks, %d failures" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	quit(0 if _failures == 0 else 1)


func _query_invalid_city(query_id: String, _args: Array) -> Variant:
	match query_id:
		"turn_number": return 3
		"owned_city_ids": return ["missing"]
		"city_data": return {}
	return null


func _mutation_capture(mutation_id: String, args: Array) -> Variant:
	if mutation_id == "set_player_result":
		_results[str(args[0])] = args[1]
	return null


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("[WORLD_TURN_STATE_SERVICE_FAIL] %s" % label)
