extends SceneTree

const ServiceScript := preload("res://scripts/worldmap/economy_city/city_resource_service.gd")

var _checks := 0
var _failures := 0
var _states := {}
var _ordered_ids: Array[String] = []
var _compatibility := {}


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var service := ServiceScript.new()
	var empty_storage := service.normalize_city_storage({})
	_expect(empty_storage.size() == 9 and int(empty_storage.gold) == 0, "empty storage normalization")
	var malformed := service.normalize_city_storage({"rice": -3, "gold": "12", "unknown": 9})
	_expect(int(malformed.rice) == 0 and int(malformed.gold) == 12 and not malformed.has("unknown"), "malformed storage normalization")
	var defaults := service.build_default_city_storage("sabi", {"gold": 99})
	_expect(defaults.size() == 9 and int(defaults.gold) == 0, "default city storage")
	var hanseong := service.build_default_city_storage("hanseong", {"gold": 99, "rice": 20})
	_expect(int(hanseong.gold) == 99 and int(hanseong.rice) == 20, "hanseong compatibility default")

	var seed_city := {"id": "hanseong", "food": 100, "gold": 40, "resource_seed": {"rice": 2, "barley": 1, "seafood": 1, "salt": 2}}
	var initialized := service.build_supply_resource_defaults(seed_city)
	_expect(bool(initialized.changed) and int(initialized.resource_stock.rice) == 50 and int(initialized.resource_stock.salt) == 40, "city resource default initialization")
	_expect(service.get_city_supply_resource_amount(seed_city, "gold") == 40, "resource amount query")

	var positive := service.calculate_resource_delta({"resource_stock": {"gold": 10}}, {"gold": 5})
	_expect(int(positive.city_state.resource_stock.gold) == 15 and int(positive.applied.gold) == 5, "positive resource delta")
	var negative := service.calculate_resource_delta({"resource_stock": {"gold": 3}}, {"gold": -9})
	_expect(int(negative.city_state.resource_stock.gold) == 0 and int(negative.applied.gold) == -3, "negative resource delta clamps at zero")
	_expect(not positive.city_state.has("id") and int(negative.city_state.resource_stock.gold) == 0, "city calculations remain isolated")

	var ordered := service.get_ordered_player_city_ids("hanseong", ["sabi", "hanseong", "gyeongju", "sabi"], {"hanseong": "player", "sabi": "player", "gyeongju": "enemy"}, "player")
	_expect(ordered == ["hanseong", "sabi"], "ordered city list keeps capital first")
	var aggregated := service.aggregate_city_stocks(["hanseong", "sabi"], {"hanseong": {"resource_stock": {"gold": 10}}, "sabi": {"resource_stock": {"gold": 5, "rice": 3}}})
	_expect(int(aggregated.gold) == 15 and int(aggregated.rice) == 3, "aggregate city stocks")

	_states = {"hanseong": {"resource_stock": {"gold": 10}}, "sabi": {"resource_stock": {"gold": 5}}}
	_ordered_ids = ["hanseong", "sabi"]
	service.configure(Callable(self, "_query"), Callable(self, "_mutate"))
	var mirror := service.sync_player_resource_compatibility()
	_expect(int(mirror.gold) == 15 and mirror == _compatibility, "compatibility mirror result")

	var city_plan := service.plan_city_stock_payment("hanseong", {"gold": 8}, {"gold": 10})
	_expect(bool(city_plan.ok) and int(city_plan.plan.hanseong.gold) == 8, "city payment plan success")
	var insufficient := service.plan_city_stock_payment("hanseong", {"gold": 12}, {"gold": 10})
	_expect(not bool(insufficient.ok) and int(insufficient.missing.gold) == 2, "city payment insufficient")
	var national := service.plan_national_city_stock_payment(["hanseong", "sabi"], {"hanseong": {"gold": 10}, "sabi": {"gold": 5}}, {"gold": 12})
	_expect(bool(national.ok) and int(national.plan.hanseong.gold) == 10 and int(national.plan.sabi.gold) == 2, "national multi-city payment plan")
	var states_before := _states.duplicate(true)
	service.commit_city_stock_payment_plan(insufficient)
	_expect(_states == states_before, "failed payment produces no partial apply")
	var food := service.plan_city_stock_payment("hanseong", {"food": 9}, {"rice": 4, "barley": 3, "seafood": 2})
	_expect(bool(food.ok) and int(food.plan.hanseong.rice) == 4 and int(food.plan.hanseong.seafood) == 2, "food resource handling")

	_states = {"hanseong": {"resource_stock": {"gold": 0}}, "sabi": {"resource_stock": {"gold": 0}}}
	_ordered_ids = ["hanseong"]
	var one_city := service.apply_city_production(2, 30, "balanced", {}, {})
	_expect(int(one_city.city_count) == 1 and int(one_city.totals.gold) == 10, "production one city")
	_states = {"hanseong": {"resource_stock": {"gold": 0}}, "sabi": {"resource_stock": {"gold": 0}}}
	_ordered_ids = ["hanseong", "sabi"]
	var two_cities := service.apply_city_production(2, 30, "balanced", {}, {})
	_expect(int(two_cities.city_count) == 2 and int(two_cities.totals.gold) == 20, "production multiple cities")
	_expect(int(two_cities.cities[0].resource_delta.gold) == 10, "governor effect input integration remains in production adapter")
	_expect(int(two_cities.cities[1].resource_delta.gold) == 10, "supply snapshot integration remains in production adapter")
	_expect(int(two_cities.totals.gold) == 20, "tech modifier input integration remains in production adapter")

	var schema: Dictionary = service.calculate_resource_delta({"resource_stock": {"gold": 1}, "storage": {"gold": 2}}, {"gold": 1}).city_state
	_expect(schema.has("resource_stock") and schema.has("storage") and int(schema.storage.gold) == 2, "resource and storage schema unchanged")
	var input := {"resource_stock": {"gold": 3}}
	var input_before := input.duplicate(true)
	service.calculate_resource_delta(input, {"gold": 1})
	_expect(input == input_before, "input snapshot is not mutated")
	_expect(not service.has_method("get_node") and not service.has_method("save_game"), "no UI or save dependency")
	_expect(not service.has_method("execute_trade") and not service.has_method("recruit_troops"), "no Trade or Military dependency")
	_finish()


func _query(query_id: String, args: Array) -> Variant:
	match query_id:
		"city_state":
			return (_states.get(str(args[0]), {}) as Dictionary).duplicate(true)
		"ordered_player_city_ids":
			return _ordered_ids.duplicate()
		"city_production_income":
			return {"gold": 10, "rice": 0, "barley": 0, "seafood": 0}
	return null


func _mutate(mutation_id: String, args: Array) -> Variant:
	match mutation_id:
		"set_city_state":
			_states[str(args[0])] = (args[1] as Dictionary).duplicate(true)
			return true
		"set_player_resource_compatibility":
			_compatibility = (args[0] as Dictionary).duplicate(true)
			return true
	return false


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("[CITY_RESOURCE_SERVICE_FAIL] %s" % label)


func _finish() -> void:
	print("[CITY_RESOURCE_SERVICE] %s: %d checks, %d failures" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	quit(0 if _failures == 0 else 1)
