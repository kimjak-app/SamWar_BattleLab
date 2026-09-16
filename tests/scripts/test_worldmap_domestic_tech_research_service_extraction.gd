extends SceneTree

const CatalogScript := preload("res://scripts/worldmap/domestic_tech/domestic_tech_catalog.gd")
const RulesScript := preload("res://scripts/worldmap/domestic_tech/domestic_tech_research_rules.gd")
const ServiceScript := preload("res://scripts/worldmap/domestic_tech/domestic_tech_research_service.gd")

var _checks := 0
var _failures := 0
var _player: Dictionary
var _cities: Dictionary


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var service := _service()
	_expect(not service.has_method("get_node"), "service is RefCounted without scene-node API")
	_reset()
	_expect(service.normalize_research_container({}, "national") == {"active": {}}, "empty national research normalization")
	var malformed := {"active": {"tech_id": "nation_foundation", "started_turn": "bad", "remaining_turns": "2", "duration_turns": -1}}
	var malformed_before := malformed.duplicate(true)
	var normalized: Dictionary = service.normalize_research_container(malformed, "national")
	_expect((normalized.active as Dictionary).remaining_turns == 2 and (normalized.active as Dictionary).duration_turns == 3 and (normalized.active as Dictionary).started_turn == 1, "malformed national research normalization")
	_expect(malformed == malformed_before, "normalization does not mutate input snapshot")
	var city_normalized: Dictionary = service.normalize_research_container({"active": {"tech_id": "agri_tool_upgrade", "remaining_turns": 1}}, "city", "a")
	_expect((city_normalized.active as Dictionary).tech_id == "agri_tool_upgrade" and (city_normalized.active as Dictionary).duration_turns == 2, "city research normalization")
	_expect(service.normalize_national_state_map(["nation_foundation", "unknown"]) == {"nation_foundation": true}, "national completed normalization")
	_expect(service.normalize_city_state_map({"a": ["agri_tool_upgrade", "unknown"]}) == {"a": {"agri_tool_upgrade": true}}, "city completed normalization")

	_reset()
	_player.national_tech_research = {"active": {"tech_id": "nation_foundation", "started_turn": 1, "remaining_turns": 2, "duration_turns": 3}}
	_expect(service.get_national_active_research().get("tech_id") == "nation_foundation", "active national lookup")
	_cities.a.city_tech.research = {"active": {"tech_id": "agri_tool_upgrade", "started_turn": 1, "remaining_turns": 2, "duration_turns": 2}}
	_expect(service.get_city_active_research("a").get("tech_id") == "agri_tool_upgrade", "active city lookup")
	_expect(service.is_researching("nation_foundation") and service.is_researching("agri_tool_upgrade", "a"), "researching query")

	_reset()
	var national_gold_before := int(_player.resource_stock.gold)
	var national_start: Dictionary = service.start_research("nation_foundation")
	_expect(bool(national_start.ok), "start national research")
	_expect(national_gold_before - int(_player.resource_stock.gold) == 140, "national charge success")
	var national_active: Dictionary = _player.national_tech_research.active
	_expect(national_active.keys().size() == 4 and national_active.has("tech_id") and national_active.has("started_turn") and national_active.has("duration_turns") and national_active.has("remaining_turns"), "active payload field preservation")
	var gold_after_first := int(_player.resource_stock.gold)
	var duplicate_start: Dictionary = service.start_research("nation_foundation")
	_expect(not bool(duplicate_start.ok) and duplicate_start.reason == "already_researching" and int(_player.resource_stock.gold) == gold_after_first, "duplicate start cannot charge twice")
	_player.national_tech_research = {"active": {"tech_id": "nation_tax_reform", "started_turn": 1, "remaining_turns": 2, "duration_turns": 3}}
	var national_conflict: Dictionary = service.start_research("nation_foundation")
	_expect(not bool(national_conflict.ok) and national_conflict.reason == "national_active", "conflicting national active research rejection")

	_reset()
	var city_before := (_cities.a.storage as Dictionary).duplicate(true)
	var city_start: Dictionary = service.start_research("agri_tool_upgrade", "a")
	_expect(bool(city_start.ok), "start city research")
	_expect(int(_cities.a.storage.gold) == int(city_before.gold) - 70 and _food_total(_cities.a.storage) == _food_total(city_before) - 15, "city charge success")
	var city_gold_after_first := int(_cities.a.storage.gold)
	var city_duplicate: Dictionary = service.start_research("agri_tool_upgrade", "a")
	_expect(not bool(city_duplicate.ok) and int(_cities.a.storage.gold) == city_gold_after_first, "city charge occurs once")

	_reset()
	_player.national_domestic_tech_completed = {"nation_foundation": true}
	_expect(service.start_research("nation_foundation").reason == "completed", "already completed rejection")
	_reset()
	_player.resource_stock.gold = 10
	var stock_before := (_player.resource_stock as Dictionary).duplicate(true)
	var insufficient: Dictionary = service.start_research("nation_foundation")
	_expect(insufficient.reason == "insufficient_cost" and _player.resource_stock == stock_before and (_player.national_tech_research.active as Dictionary).is_empty(), "insufficient resource rejection without partial charge")
	_reset()
	_cities.a.storage = {"gold": 70, "rice": 5, "barley": 0, "seafood": 0}
	var city_stock_before := (_cities.a.storage as Dictionary).duplicate(true)
	var city_insufficient: Dictionary = service.start_research("agri_tool_upgrade", "a")
	_expect(city_insufficient.reason == "insufficient_cost" and _cities.a.storage == city_stock_before, "failed city start causes no partial charge")
	_expect(service.start_research("missing_tech").reason == "missing_definition", "malformed tech rejected safely")

	_reset()
	service.start_research("nation_foundation")
	var progress_one: Dictionary = service.advance_world_turn()
	_expect(int((_player.national_tech_research.active as Dictionary).remaining_turns) == 2 and (progress_one.national as Array).size() == 1, "turn progress decrements national research")
	service.advance_world_turn()
	var national_complete: Dictionary = service.advance_world_turn()
	_expect(bool(_player.national_domestic_tech_completed.nation_foundation), "national completion recorded")
	_expect((_player.national_tech_research.active as Dictionary).is_empty(), "national completion clears active")
	var national_event: Dictionary = (national_complete.completed as Array)[0]
	_expect(national_event == {"type": "national", "tech_id": "nation_foundation", "before_remaining": 1, "after_remaining": 0, "completed": true, "completed_turn": 1}, "national completion event shape preserved")
	var duplicate_event: Dictionary = service.complete_national_research({"tech_id": "nation_foundation", "remaining_turns": 1, "duration_turns": 3})
	_expect(not bool(duplicate_event.completed) and bool(duplicate_event.already_completed), "same national tech does not complete twice")

	_reset()
	service.start_research("agri_tool_upgrade", "a")
	service.start_research("agri_tool_upgrade", "b")
	var multi_progress: Dictionary = service.advance_world_turn()
	_expect((multi_progress.city as Array).size() == 2 and int(_cities.a.city_tech.research.active.remaining_turns) == 1 and int(_cities.b.city_tech.research.active.remaining_turns) == 1, "multiple cities progress independently")
	var city_complete: Dictionary = service.advance_world_turn()
	_expect(bool(_player.city_domestic_tech_completed.a.agri_tool_upgrade) and bool(_player.city_domestic_tech_completed.b.agri_tool_upgrade), "city completion recorded independently")
	_expect((_cities.a.city_tech.research.active as Dictionary).is_empty() and (_cities.b.city_tech.research.active as Dictionary).is_empty(), "city completion clears active")
	_expect(bool(_cities.a.city_tech.completed.agri_tool_upgrade) and bool(_cities.b.city_tech.completed.agri_tool_upgrade), "city completed mirror updated")
	var city_event: Dictionary = (city_complete.completed as Array)[0]
	_expect(city_event.has("city_id") and city_event.type == "city" and city_event.completed_turn == 1, "city completion event shape preserved")
	var duplicate_city_event: Dictionary = service.complete_city_research("a", {"tech_id": "agri_tool_upgrade", "remaining_turns": 1, "duration_turns": 2})
	_expect(not bool(duplicate_city_event.completed) and bool(duplicate_city_event.already_completed), "same city tech does not complete twice")

	_reset()
	var plan: Dictionary = service.build_actual_charge_plan("agri_tool_upgrade", "city", "a")
	_expect(int(plan.cost_plan.planned_gold_cost) == 70 and int(plan.cost_plan.planned_food_cost) == 15 and plan.charge_timing == "on_research_start_once", "Catalog and Rules cost plan reused")
	_expect(service.get_actual_charge_summary().per_turn_charge == false, "research charge remains start-only")
	_finish()


func _service() -> RefCounted:
	var service := ServiceScript.new()
	service.configure(CatalogScript.new(), RulesScript.new(), Callable(self, "_query"), Callable(self, "_mutation"))
	return service


func _reset() -> void:
	_player = {"selected_city_id": "a", "owned_city_ids": ["a", "b"], "turn_number": 1, "resource_stock": {"gold": 2000, "rice": 500, "barley": 500, "seafood": 500}, "city_domestic_tech_completed": {}, "city_domestic_tech_unlocked": {}, "national_domestic_tech_completed": {}, "national_domestic_tech_unlocked": {}, "national_tech_research": {"active": {}}}
	_cities = {
		"a": {"owner": "player", "type": "inland", "storage": {"gold": 1000, "rice": 200, "barley": 100, "seafood": 50}, "city_tech": {"completed": {}, "in_progress": {}, "available_cache": {}, "research": {"active": {}}}},
		"b": {"owner": "player", "type": "coastal", "storage": {"gold": 1000, "rice": 200, "barley": 100, "seafood": 50}, "city_tech": {"completed": {}, "in_progress": {}, "available_cache": {}, "research": {"active": {}}}},
	}


func _query(query_id: String, args: Array) -> Variant:
	match query_id:
		"player_value": return _player.get(str(args[0]), args[1] if args.size() > 1 else null)
		"city_state": return (_cities.get(str(args[0]), {}) as Dictionary).duplicate(true)
		"city_ids": return _cities.keys()
		"city_exists": return _cities.has(str(args[0]))
		"is_city_owned": return str((_cities.get(str(args[0]), {}) as Dictionary).get("owner", "")) == "player"
		"current_turn": return int(_player.get("turn_number", 1))
		"city_storage": return ((_cities.get(str(args[0]), {}) as Dictionary).get("storage", {}) as Dictionary).duplicate(true)
		"is_city_coastal": return str((_cities.get(str(args[0]), {}) as Dictionary).get("type", "")).contains("coastal")
	return null


func _mutation(mutation_id: String, args: Array) -> Variant:
	match mutation_id:
		"set_player_value":
			_player[str(args[0])] = (args[1] as Dictionary).duplicate(true) if args[1] is Dictionary else args[1]
			return true
		"set_city_state":
			_cities[str(args[0])] = (args[1] as Dictionary).duplicate(true)
			return true
		"set_city_storage":
			_cities[str(args[0])]["storage"] = (args[1] as Dictionary).duplicate(true)
			return true
	return false


func _food_total(stock: Dictionary) -> int:
	return int(stock.get("rice", 0)) + int(stock.get("barley", 0)) + int(stock.get("seafood", 0))


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("[DOMESTIC_TECH_RESEARCH_SERVICE_FAIL] %s" % label)


func _finish() -> void:
	print("[DOMESTIC_TECH_RESEARCH_SERVICE] %s: %d checks, %d failures" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	quit(0 if _failures == 0 else 1)
