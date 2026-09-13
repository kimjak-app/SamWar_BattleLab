extends SceneTree

const SCENE_PATH := "res://WorldMap_16x9_Test.tscn"
const SpyControllerScript := preload("res://scripts/worldmap/actions/spy_controller.gd")

var _checks := 0
var _failures := 0
var _worldmap: Node
var _controller: RefCounted
var _baseline_state: Dictionary
var _baseline_cities: Dictionary


func _initialize() -> void:
	call_deferred("_run")


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("[SPY_CONTROLLER] FAIL: " + label)


func _reset(gold: int = 10000) -> void:
	var state := _baseline_state.duplicate(true)
	state["resource_stock"] = {"gold": gold, "silk": 10000, "rice": 10000}
	state["chancellor_id"] = "jeong_do_jeon"
	state["spy_cooldown"] = 0
	state["faction_relations"] = {}
	state["city_intel"] = {}
	state["revolt_instigation"] = {}
	_worldmap.set("_player_state", state)
	var cities := _baseline_cities.duplicate(true)
	for city_id in cities:
		var city: Dictionary = cities[city_id]
		city["security"] = 50
		city["public_order"] = 50
		city["loyalty"] = 35
		city["cityLoyalty"] = 35
		city["publicSupport"] = 35
		cities[city_id] = city
	_worldmap.set("_city_runtime_states", cities)


func _valid_target(action: String) -> String:
	for city_id in _worldmap.get("_city_markers_by_id"):
		if bool(_controller.call("validate_spy_action", action, city_id).get("ok", false)):
			return str(city_id)
	return ""


func _run() -> void:
	change_scene_to_file(SCENE_PATH)
	await process_frame
	await process_frame
	_worldmap = current_scene.get_node("ProductionWorldMap")
	_controller = _worldmap.call("_ensure_spy_controller")
	_baseline_state = _worldmap.get("_player_state").duplicate(true)
	_baseline_cities = _worldmap.get("_city_runtime_states").duplicate(true)
	for city_id in _worldmap.get("_city_markers_by_id"):
		if not _baseline_cities.has(city_id):
			_baseline_cities[city_id] = _worldmap.call("_get_city_hud_entry", city_id).duplicate(true)

	_expect(_controller != null, "main owns SpyController")
	var coordinator: Node = _worldmap.call("_ensure_diplomacy_action_coordinator")
	_expect(coordinator.get("_spy_controller") == _controller, "Coordinator receives same controller")
	_expect(_controller.get("_service") != null, "Controller owns service")
	_expect(not "SpyActionService" in str(coordinator.get_script().resource_path), "Coordinator is generic")

	var minimal := Node.new()
	var minimal_controller := SpyControllerScript.new()
	minimal_controller.configure(minimal)
	var minimal_failure: Dictionary = minimal_controller.validate_spy_action("unknown", "missing")
	_expect(minimal_failure.get("reason") == "invalid_action", "minimal host invalid action")
	minimal.free()

	_reset()
	var invalid: Dictionary = _controller.call("validate_spy_action", "unknown", "missing")
	_expect(not bool(invalid.get("ok", true)), "invalid action rejected")
	_expect(invalid.get("reason") == "invalid_action", "invalid action reason")
	var missing: Dictionary = _controller.call("validate_spy_action", "gather_info", "missing")
	_expect(not bool(missing.get("ok", true)), "missing target rejected")
	_expect(missing.get("reason") == "invalid_target", "missing target reason")

	var actions := ["gather_info", "public_support_disrupt", "loyalty_disrupt", "revolt_instigate", "wedge"]
	for action in actions:
		_reset()
		var target := _valid_target(action)
		_expect(not target.is_empty(), "valid target for " + action)
		var check: Dictionary = _controller.call("validate_spy_action", action, target)
		_expect(bool(check.get("ok", false)), "validation succeeds for " + action)
		seed(73021)
		var direct: Dictionary = _controller.call("execute", action, target)
		_reset()
		seed(73021)
		var routed: Dictionary = coordinator.call("execute_now", "spy", action, target)
		_expect(routed == direct, "Coordinator result parity for " + action)
		_expect(str(routed.get("action_id", "")) == action, "result action id for " + action)

	_reset()
	var wedge_target := _valid_target("wedge")
	_worldmap.get("_player_state")["resource_stock"]["gold"] = 0
	var no_resource: Dictionary = _controller.call("execute", "wedge", wedge_target)
	_expect(no_resource.get("reason") == "resources", "insufficient resource result")
	_expect(int(_worldmap.get("_player_state").get("spy_cooldown", 0)) == 0, "failure retains cooldown")

	_reset()
	var gather_target := _valid_target("gather_info")
	var service: RefCounted = _controller.get("_service")
	_controller.call("validate_spy_action", "gather_info", gather_target)
	var intel_result: Dictionary = service.call("_gather_spy_info", gather_target, 1, 100)
	_expect(bool(intel_result.get("success", false)), "gather info forced success")
	_expect(not (_worldmap.get("_player_state").get("city_intel", {}) as Dictionary).is_empty(), "intel registry mutation")

	_reset()
	var support_target := _valid_target("public_support_disrupt")
	var support_before := int(_worldmap.call("_get_city_public_support", support_target))
	_controller.call("validate_spy_action", "public_support_disrupt", support_target)
	var support_result: Dictionary = service.call("_disrupt_city_public_support", support_target, 1, 100)
	_expect(bool(support_result.get("effect_applied", false)), "public support forced success")
	_expect(int(_worldmap.call("_get_city_public_support", support_target)) < support_before, "public support mutation")

	_reset()
	var loyalty_target := _valid_target("loyalty_disrupt")
	var loyalty_before := int(_worldmap.call("_get_city_loyalty_value", _worldmap.call("_get_city_hud_entry", loyalty_target)))
	_controller.call("validate_spy_action", "loyalty_disrupt", loyalty_target)
	var loyalty_result: Dictionary = service.call("_disrupt_city_loyalty", loyalty_target, 1, 100)
	_expect(bool(loyalty_result.get("effect_applied", false)), "loyalty forced success")
	_expect(int(loyalty_result.get("loyalty_after", loyalty_before)) < loyalty_before, "loyalty mutation")

	_reset()
	var revolt_target := _valid_target("revolt_instigate")
	_controller.call("validate_spy_action", "revolt_instigate", revolt_target)
	var revolt_result: Dictionary = service.call("_instigate_revolt", revolt_target, 1, 100)
	_expect(bool(revolt_result.get("effect_applied", false)), "revolt forced success")
	_expect((_worldmap.get("_player_state").get("revolt_instigation", {}) as Dictionary).has(revolt_target), "revolt state mutation")
	var tick: Dictionary = _controller.call("advance_revolt_instigation_for_world_turn")
	_expect(tick.has("active_count"), "revolt lifecycle tick")

	_worldmap.get("_player_state")["spy_cooldown"] = 2
	var cooldown: Dictionary = _controller.call("advance_spy_cooldown_for_world_turn")
	_expect(cooldown.get("before") == 2 and cooldown.get("after") == 1, "cooldown lifecycle")

	var normalized: Dictionary = _controller.call("normalize_city_intel_registry", {gather_target: {"turn": -1, "fields": ["troops", "bad"], "payload": {"troops": 10}}, "missing": {"fields": ["troops"]}})
	_expect(normalized.has(gather_target), "save/load keeps valid intel")
	_expect(not normalized.has("missing"), "save/load drops invalid city")
	_expect((normalized[gather_target].get("fields", []) as Array) == ["troops"], "save/load normalizes fields")

	var replacement: Dictionary = _worldmap.get("_player_state").duplicate(true)
	replacement["spy_cooldown"] = 7
	_worldmap.set("_player_state", replacement)
	var replacement_tick: Dictionary = _controller.call("advance_spy_cooldown_for_world_turn")
	_expect(replacement_tick.get("before") == 7, "controller observes state replacement")

	var presenter: RefCounted = _worldmap.call("_ensure_spy_presenter")
	var hint_map: Dictionary = {}
	for action in actions: hint_map[action] = _controller.call("validate_spy_action", action, gather_target)
	_expect(_worldmap.call("_format_spy_action_hint", hint_map) == presenter.call("format_action_hint", hint_map), "presentation hint parity")
	_expect(_worldmap.call("_format_spy_cooldown_summary", {"changed": true, "before": 2, "after": 1}) == presenter.call("format_cooldown_summary", {"changed": true, "before": 2, "after": 1}), "presentation cooldown parity")

	coordinator.call("begin", "spy", gather_target)
	_expect(bool(coordinator.call("is_active", "spy")), "coordinator begins Spy context")
	coordinator.call("cancel")
	_expect(not bool(coordinator.call("is_active", "spy")), "coordinator cancellation")

	current_scene.queue_free()
	await process_frame
	await process_frame
	print("[SPY_CONTROLLER] %s: %d checks, %d failures" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	quit(0 if _failures == 0 else 1)
