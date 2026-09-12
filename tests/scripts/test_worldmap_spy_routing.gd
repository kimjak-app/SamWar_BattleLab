extends SceneTree

const SCENE_PATH := "res://WorldMap_16x9_Test.tscn"
const ACTIONS := ["gather_info", "public_support_disrupt", "loyalty_disrupt", "revolt_instigate", "wedge"]
const BUTTON_PROPERTIES := {
	"gather_info": "_spy_gather_info_button",
	"public_support_disrupt": "_spy_public_support_button",
	"loyalty_disrupt": "_spy_loyalty_button",
	"revolt_instigate": "_spy_revolt_button",
	"wedge": "_spy_wedge_button",
}

var _failures := 0
var _checks := 0
var _resolved := 0
var _presented := 0
var _worldmap: Node
var _presentation: Node
var _baseline_state: Dictionary
var _baseline_cities: Dictionary
var _target := ""


func _initialize() -> void:
	call_deferred("_run")


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("[SPY_ROUTING] FAIL: " + label)


func _prepare(gold: int = 10000, cooldown: int = 0) -> void:
	_worldmap.call("cancel_contextual_worldmap_action")
	var state := _baseline_state.duplicate(true)
	state["resource_stock"] = {"gold": gold, "silk": 10000, "rice": 10000}
	state["chancellor_id"] = "jeong_do_jeon"
	state["spy_cooldown"] = cooldown
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
		var domestic: Dictionary = city.get("domestic_seed", {}).duplicate(true)
		domestic["publicOrder"] = 50
		domestic["publicSupport"] = 35
		domestic["loyalty"] = 35
		city["domestic_seed"] = domestic
		cities[city_id] = city
	_worldmap.set("_city_runtime_states", cities)


func _find_valid_target(action: String) -> String:
	var markers: Dictionary = _worldmap.get("_city_markers_by_id")
	for city_id in markers:
		var validation: Dictionary = _worldmap.call("_validate_spy_action", action, city_id)
		if bool(validation.get("ok", false)):
			return str(city_id)
	return ""


func _select_target(city_id: String) -> void:
	_target = city_id
	var markers: Dictionary = _worldmap.get("_city_markers_by_id")
	_worldmap.call("_on_city_marker_selected", markers[city_id])


func _parity(action: String, gold: int = 10000, cooldown: int = 0, require_valid: bool = true) -> void:
	_prepare(10000, 0)
	var city_id := _find_valid_target(action)
	if city_id.is_empty():
		_expect(false, "valid target exists for " + action)
		return
	_select_target(city_id)
	_worldmap.get("_player_state")["resource_stock"]["gold"] = gold
	_worldmap.get("_player_state")["spy_cooldown"] = cooldown
	var before_state: Dictionary = _worldmap.get("_player_state").duplicate(true)
	var before_cities: Dictionary = _worldmap.get("_city_runtime_states").duplicate(true)
	seed(73021)
	var legacy: Dictionary = _worldmap.call("_apply_spy_action_legacy", action, city_id)
	var expected_state: Dictionary = _worldmap.get("_player_state").duplicate(true)
	var expected_cities: Dictionary = _worldmap.get("_city_runtime_states").duplicate(true)
	_worldmap.set("_player_state", before_state.duplicate(true))
	_worldmap.set("_city_runtime_states", before_cities.duplicate(true))
	seed(73021)
	var actual: Dictionary = _worldmap.call("_apply_spy_action", action, city_id)
	var label := "%s/gold=%d/cooldown=%d" % [action, gold, cooldown]
	_expect(actual == legacy, "result parity " + label)
	_expect(_worldmap.get("_player_state") == expected_state, "player state parity " + label)
	_expect(_worldmap.get("_city_runtime_states") == expected_cities, "city state parity " + label)
	_expect(bool(actual.get("success_valid", true)) == require_valid, "validation outcome " + label)


func _open_and_press(action: String, target_city_id: String = "") -> void:
	if target_city_id.is_empty():
		target_city_id = _find_valid_target(action)
	_select_target(target_city_id)
	var menu := current_scene.get_node("CityActionTestController")
	menu.set("_selected_marker", _worldmap.get("_city_markers_by_id")[target_city_id])
	(menu.get("_spy_button") as Button).pressed.emit()
	_expect(_worldmap.get("_contextual_worldmap_action_type") == "spy", "city UI opens spy actions")
	var coordinator := _worldmap.get_node("DiplomacyActionCoordinator")
	_expect(bool(coordinator.call("is_active", "spy")), "shared coordinator begins spy")
	(_worldmap.get(BUTTON_PROPERTIES[action]) as Button).pressed.emit()


func _run() -> void:
	change_scene_to_file(SCENE_PATH)
	await process_frame
	await process_frame
	_worldmap = current_scene.get_node("ProductionWorldMap")
	_presentation = current_scene.get_node("ActionPresentationController")
	_baseline_state = _worldmap.get("_player_state").duplicate(true)
	_baseline_cities = _worldmap.get("_city_runtime_states").duplicate(true)
	for city_id in _worldmap.get("_city_markers_by_id"):
		if not _baseline_cities.has(city_id):
			_baseline_cities[city_id] = _worldmap.call("_get_city_hud_entry", city_id).duplicate(true)
	_worldmap.connect("contextual_worldmap_action_resolved", func(type: String, _result: Dictionary) -> void:
		if type == "spy": _resolved += 1
	)
	_worldmap.connect("contextual_worldmap_action_presentation_requested", func(type: String, _id: String, _city: String) -> void:
		if type == "spy": _presented += 1
	)

	for action in ACTIONS:
		_parity(action)
		_parity(action, 10000, 2, false)
	_parity("wedge", 0, 0, false)
	_prepare()
	var unknown_legacy: Dictionary = _worldmap.call("_apply_spy_action_legacy", "unknown", "missing")
	_prepare()
	var unknown_service: Dictionary = _worldmap.call("_apply_spy_action", "unknown", "missing")
	_expect(unknown_service == unknown_legacy, "unknown action result parity")

	_prepare()
	_open_and_press("gather_info")
	_expect(_presented == 1 and _resolved == 0, "presentation precedes execution")
	_expect(_presentation.get_node("VideoOverlay").visible, "real spy video starts")
	_expect(int(_worldmap.get("_player_state").get("spy_cooldown", 0)) == 0, "no mutation before video completion")
	_worldmap.call("_on_spy_action_pressed", "loyalty_disrupt")
	_expect(_presented == 1, "double click does not request second video")
	var wrong_action: Dictionary = _worldmap.call("complete_contextual_worldmap_action", "spy", "loyalty_disrupt", _target)
	_expect(not bool(wrong_action.get("success", false)), "mismatched action rejected")
	var other_target := ""
	for city_id in _worldmap.get("_city_markers_by_id"):
		if str(city_id) != _target:
			other_target = str(city_id)
			break
	var wrong_target: Dictionary = _worldmap.call("complete_contextual_worldmap_action", "spy", "gather_info", other_target)
	_expect(not bool(wrong_target.get("success", false)), "changed target rejected")
	await create_timer(8.0).timeout
	_expect(_resolved == 1, "real video resolves exactly once")
	_expect(_presentation.get_node("ResultOverlay").visible, "result appears after video")
	_expect(int(_worldmap.get("_player_state").get("spy_cooldown", 0)) > 0, "successful execution mutates spy state")
	_worldmap.call("complete_contextual_worldmap_action", "spy", "gather_info", _target)
	_expect(_resolved == 1, "duplicate completion ignored")

	_prepare()
	_open_and_press("gather_info")
	var escape := InputEventKey.new()
	escape.keycode = KEY_ESCAPE
	escape.pressed = true
	_presentation.call("_unhandled_input", escape)
	_expect(_resolved == 2, "Escape resolves spy video")

	_prepare()
	_open_and_press("gather_info")
	_worldmap.call("cancel_contextual_worldmap_action")
	_presentation.call("_finish_pending_video")
	_expect(_resolved == 2, "cancelled context cannot execute")
	_expect(int(_worldmap.get("_player_state").get("spy_cooldown", 0)) == 0, "cancel does not mutate")

	_prepare()
	var costly_target := _find_valid_target("wedge")
	_open_and_press("wedge", costly_target)
	_worldmap.get("_player_state")["resource_stock"]["gold"] = 0
	_presentation.call("_finish_pending_video")
	_expect(_resolved == 3, "resources revalidated after video")
	var failure: Dictionary = _worldmap.get("_player_state")["last_spy_wedge_result"]
	_expect(failure.get("reason") == "resources", "resource failure reaches result")
	_expect(_presentation.get_node("ResultOverlay").visible, "failure result visible")

	_prepare()
	var blocked_target := _find_valid_target("gather_info")
	_worldmap.get("_player_state")["spy_cooldown"] = 2
	_select_target(blocked_target)
	_worldmap.call("open_contextual_worldmap_action", "spy", blocked_target)
	var presentations_before := _presented
	_worldmap.call("_on_spy_action_pressed", "gather_info")
	_expect(_resolved == 4 and _presented == presentations_before, "invalid spy resolves without video")
	_expect(_presentation.get_node("ResultOverlay").visible, "immediate validation result visible")

	await create_timer(2.2).timeout
	current_scene.queue_free()
	await process_frame
	await process_frame
	print("[SPY_ROUTING] %s: %d checks, %d failures" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	quit(0 if _failures == 0 else 1)
