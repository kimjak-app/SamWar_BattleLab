extends SceneTree

const SCENE_PATH := "res://WorldMap_16x9_Test.tscn"
const Service := preload("res://scripts/worldmap/actions/diplomacy_action_service.gd")
const ACTIONS := ["envoy", "tribute", "trade_agreement", "restore_relations", "alliance_proposal"]

var _failures := 0
var _checks := 0
var _worldmap: Node
var _service: RefCounted
var _baseline: Dictionary
var _foreign_city_id := ""
var _foreign_faction_id := ""


func _initialize() -> void:
	call_deferred("_run")


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("[DIPLOMACY_MUTATION_2B] FAIL: " + label)


func _prepare(score: int = 60, status: String = "neutral", gold: int = 10000, silk: int = 10000) -> void:
	var state := _baseline.duplicate(true)
	state["player_faction_id"] = "player"
	state["resource_stock"] = {"gold": gold, "silk": silk, "rice": 10000, "barley": 10000, "seafood": 10000}
	state["faction_relations"] = {}
	state["diplomacy_action_cooldowns"] = {}
	state["trade_agreements"] = {}
	state["alliances"] = {}
	_worldmap.set("_player_state", state)
	var relation: Dictionary = _worldmap.call("_ensure_faction_relation_entry", "player", _foreign_faction_id)
	relation["score"] = score
	relation["status"] = status
	relation["diplomacy_action_cooldown"] = 0


func _resource_stock() -> Dictionary:
	return (_worldmap.get("_player_state") as Dictionary).get("resource_stock", {})


func _relation_entry() -> Dictionary:
	return _worldmap.call("_get_faction_relation_entry", "player", _foreign_faction_id)


func _check_resource_helper_parity(cost: Dictionary, label: String) -> void:
	_prepare()
	var before: Dictionary = _worldmap.get("_player_state").duplicate(true)
	var legacy: Dictionary = _worldmap.call("_apply_generic_resource_cost", cost)
	var expected_state: Dictionary = _worldmap.get("_player_state").duplicate(true)
	_worldmap.set("_player_state", before.duplicate(true))
	var direct: Dictionary = _service.call("apply_diplomacy_resource_cost", _worldmap, cost)
	_expect(direct == legacy, "resource result parity: " + label)
	_expect(_worldmap.get("_player_state") == expected_state, "resource state parity: " + label)


func _check_relation_helper_parity(score: int, delta: int, label: String) -> void:
	_prepare(score)
	var before: Dictionary = _worldmap.get("_player_state").duplicate(true)
	var reason := "diplomacy_action_" + label
	var legacy: Dictionary = _worldmap.call("_adjust_faction_relation_score", "player", _foreign_faction_id, delta, reason)
	var expected_state: Dictionary = _worldmap.get("_player_state").duplicate(true)
	_worldmap.set("_player_state", before.duplicate(true))
	var direct: Dictionary = _service.call("apply_diplomacy_relation_delta", _worldmap, "player", _foreign_faction_id, delta, reason)
	_expect(direct == legacy, "relation result parity: " + label)
	_expect(_worldmap.get("_player_state") == expected_state, "relation state parity: " + label)


func _check_action(action_id: String, score: int, status: String) -> void:
	_prepare(score, status)
	var validation: Dictionary = _worldmap.call("_validate_diplomacy_action", action_id, _foreign_city_id)
	var definition: Dictionary = Service.get_action_definition(action_id)
	var cost: Dictionary = definition.get("cost", {})
	var before_stock := _resource_stock().duplicate(true)
	var before_relation_score := int(_relation_entry().get("score", 0))
	var result: Dictionary = _service.call("execute", _worldmap, action_id, _foreign_city_id)
	_expect(bool(result.get("success", false)), "service direct action succeeds: " + action_id)
	for resource_id_variant in cost:
		var resource_id := str(resource_id_variant)
		var expected := int(before_stock.get(resource_id, 0)) - int(cost.get(resource_id_variant, 0))
		_expect(int(_resource_stock().get(resource_id, 0)) == expected, "service cost committed: %s/%s" % [action_id, resource_id])
	var expected_score := clampi(before_relation_score + int(validation.get("relation_delta", 0)), 0, 100)
	_expect(int(_relation_entry().get("score", 0)) == expected_score, "service relation committed: " + action_id)
	_expect(int(result.get("before_score", before_relation_score)) == before_relation_score, "result before score: " + action_id)
	_expect(int(result.get("after_score", expected_score)) == expected_score, "result after score: " + action_id)
	_expect(int(result.get("relation_delta", expected_score - before_relation_score)) == expected_score - before_relation_score, "result relation delta: " + action_id)
	_expect(result.get("payment", {}) is Dictionary and not (result.get("payment", {}) as Dictionary).is_empty(), "result payment: " + action_id)


func _check_insufficient_resources(action_id: String) -> void:
	_prepare(60, "neutral", 0, 0)
	var before_stock := _resource_stock().duplicate(true)
	var before_relation := _relation_entry().duplicate(true)
	var result: Dictionary = _service.call("execute", _worldmap, action_id, _foreign_city_id)
	_expect(not bool(result.get("success", false)), "insufficient resources fail: " + action_id)
	_expect(result.get("reason") == "resources" and result.get("message") == "자원이 부족합니다.", "resource failure contract: " + action_id)
	_expect(_resource_stock() == before_stock, "resource failure does not charge: " + action_id)
	_expect(_relation_entry() == before_relation, "resource failure does not change relation: " + action_id)
	_expect(result.get("target_city_id") == _foreign_city_id and result.get("target_faction_id") == _foreign_faction_id, "resource failure target contract: " + action_id)


func _check_production_parity(action_id: String, score: int, status: String) -> void:
	_prepare(score, status)
	var before: Dictionary = _worldmap.get("_player_state").duplicate(true)
	var direct: Dictionary = _service.call("execute", _worldmap, action_id, _foreign_city_id)
	var expected_state: Dictionary = _worldmap.get("_player_state").duplicate(true)
	_worldmap.set("_player_state", before.duplicate(true))
	var production: Dictionary = _worldmap.call("_apply_diplomacy_action", action_id, _foreign_city_id)
	_expect(production == direct, "production result parity: " + action_id)
	_expect(_worldmap.get("_player_state") == expected_state, "production state parity: " + action_id)


func _run() -> void:
	change_scene_to_file(SCENE_PATH)
	await process_frame
	await process_frame
	_worldmap = current_scene.get_node("ProductionWorldMap")
	_service = Service.new()
	_baseline = _worldmap.get("_player_state").duplicate(true)
	for city_id_variant in _worldmap.get("_city_markers_by_id"):
		var city_id := str(city_id_variant)
		var owner := str(_worldmap.call("_get_city_owner_faction_id_for_trade_display", city_id))
		if not owner.is_empty() and owner != "player":
			_foreign_city_id = city_id
			_foreign_faction_id = owner
			break
	_expect(not _foreign_city_id.is_empty(), "foreign diplomacy target exists")

	_check_resource_helper_parity(Service.get_action_definition("envoy").get("cost", {}), "envoy")
	_check_resource_helper_parity(Service.get_action_definition("alliance_proposal").get("cost", {}), "gold and silk")
	_check_relation_helper_parity(60, int(Service.get_action_definition("restore_relations").get("relation_delta", 0)), "increase")
	_check_relation_helper_parity(100, int(Service.get_action_definition("envoy").get("relation_delta", 0)), "upper clamp")
	_check_relation_helper_parity(0, -int(Service.get_action_definition("tribute").get("relation_delta", 0)), "lower clamp")

	for action_id in ACTIONS:
		var action_status := "hostile" if action_id == "restore_relations" else "neutral"
		var action_score := 80 if action_id == "alliance_proposal" else 60
		_check_production_parity(action_id, action_score, action_status)
		_check_action(action_id, action_score, action_status)
	_check_insufficient_resources("tribute")
	_check_insufficient_resources("alliance_proposal")

	current_scene.queue_free()
	await process_frame
	await process_frame
	print("[DIPLOMACY_MUTATION_2B] %s: %d checks, %d failures" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	quit(0 if _failures == 0 else 1)
