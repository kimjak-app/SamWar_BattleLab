extends SceneTree

const SCENE_PATH := "res://WorldMap_16x9_Test.tscn"
var _failures := 0
var _checks := 0
var _resolved := 0
var _presented := 0
var _worldmap: Node
var _presentation: Node
var _baseline: Dictionary
var _target := ""


func _initialize() -> void:
	call_deferred("_run")


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("[DIPLOMACY_ROUTING] FAIL: " + label)


func _prepare(faction: String = "player", score: int = 60, status: String = "neutral", gold: int = 10000, cooldown: int = 0) -> void:
	_worldmap.call("cancel_contextual_worldmap_action")
	var state := _baseline.duplicate(true)
	state["player_faction_id"] = faction
	state["resource_stock"] = {"gold": gold, "silk": 10000, "rice": 10000}
	state["faction_relations"] = {}
	state["diplomacy_action_cooldowns"] = {}
	state["active_trade_agreements"] = {}
	state["active_alliances"] = {}
	_worldmap.set("_player_state", state)
	var markers: Dictionary = _worldmap.get("_city_markers_by_id")
	for city_id in markers:
		var owner := str(_worldmap.call("_get_city_owner_faction_id_for_trade_display", city_id))
		if not owner.is_empty() and owner != faction:
			_target = str(city_id)
			var entry: Dictionary = _worldmap.call("_ensure_faction_relation_entry", faction, owner)
			entry["score"] = score
			entry["status"] = status
			entry["diplomacy_action_cooldown"] = cooldown
			_worldmap.call("_on_city_marker_selected", markers[city_id])
			return
	_expect(false, "foreign target exists")


func _parity(action: String, faction: String, score: int, status: String, gold: int, cooldown: int, expected_success: bool) -> void:
	_prepare(faction, score, status, gold, cooldown)
	var before: Dictionary = _worldmap.get("_player_state").duplicate(true)
	var legacy: Dictionary = _worldmap.call("_apply_diplomacy_action_legacy", action, _target)
	var expected_state: Dictionary = _worldmap.get("_player_state").duplicate(true)
	_worldmap.set("_player_state", before.duplicate(true))
	var actual: Dictionary = _worldmap.call("_apply_diplomacy_action", action, _target)
	var label := "%s/%s/%s/%d/%d/%d" % [action, faction, status, score, gold, cooldown]
	_expect(actual == legacy, "result parity " + label)
	_expect(_worldmap.get("_player_state") == expected_state, "full state parity " + label)
	_expect(bool(actual.get("success", false)) == expected_success, "expected outcome " + label)
	if not expected_success and action != "alliance_proposal":
		_expect(actual.get("payment", {}).is_empty(), "validation failure has no payment " + label)


func _open_and_press() -> void:
	var menu := current_scene.get_node("CityActionTestController")
	menu.set("_selected_marker", _worldmap.get("_city_markers_by_id")[_target])
	(menu.get("_diplomacy_button") as Button).pressed.emit()
	_expect(_worldmap.get("_contextual_worldmap_action_type") == "diplomacy", "city UI opens diplomacy actions")
	var coordinator := _worldmap.get_node("DiplomacyActionCoordinator")
	_expect(bool(coordinator.call("is_active", "diplomacy")), "coordinator begins from city UI")
	(_worldmap.get("_diplomacy_envoy_button") as Button).pressed.emit()


func _run() -> void:
	# Load after autoload registration; preloading from --script predates GameAudio.
	change_scene_to_file(SCENE_PATH)
	await process_frame
	await process_frame
	_worldmap = current_scene.get_node("ProductionWorldMap")
	_presentation = current_scene.get_node("ActionPresentationController")
	_baseline = _worldmap.get("_player_state").duplicate(true)
	_worldmap.connect("contextual_worldmap_action_resolved", func(_type: String, _result: Dictionary) -> void: _resolved += 1)
	_worldmap.connect("contextual_worldmap_action_presentation_requested", func(_type: String, _id: String, _city: String) -> void: _presented += 1)
	for faction in ["player", "silla"]:
		for action in ["envoy", "tribute", "trade_agreement", "alliance_proposal"]:
			_parity(action, faction, 80, "neutral", 10000, 0, true)
		_parity("restore_relations", faction, 20, "hostile", 10000, 0, true)
		_parity("alliance_proposal", faction, 0, "neutral", 10000, 0, false)
		for action in ["envoy", "tribute", "trade_agreement", "restore_relations", "alliance_proposal"]:
			_parity(action, faction, 60, "neutral", 10000, 2, false)
			_parity(action, faction, 60, "hostile" if action == "restore_relations" else "neutral", 0, 0, false)
		_parity("trade_agreement", faction, 60, "hostile", 10000, 0, false)
		_parity("trade_agreement", faction, 20, "neutral", 10000, 0, false)
		_parity("restore_relations", faction, 60, "neutral", 10000, 0, false)
		_parity("unknown", faction, 60, "neutral", 10000, 0, false)

	_prepare()
	_open_and_press()
	_expect(_presented == 1 and _resolved == 0, "presentation precedes execution")
	_expect(_presentation.get_node("VideoOverlay").visible, "real video overlay starts")
	_expect(int(_worldmap.get("_player_state")["resource_stock"]["gold"]) == 10000, "no cost before video completion")
	_worldmap.call("_on_diplomacy_action_pressed", "tribute")
	_expect(_presented == 1, "double click does not request a second video")
	var wrong: Dictionary = _worldmap.call("complete_contextual_worldmap_action", "diplomacy", "tribute", _target)
	_expect(not bool(wrong.get("success", false)), "mismatched action rejected")
	# Exercise the actual cutin finished signal, not a simulated completion.
	await create_timer(8.0).timeout
	_expect(_resolved == 1, "real video resolves exactly once")
	_expect(_presentation.get_node("ResultOverlay").visible, "result appears after real video")
	_expect(int(_worldmap.get("_player_state")["resource_stock"]["gold"]) == 9970, "envoy charged once")
	_worldmap.call("complete_contextual_worldmap_action", "diplomacy", "envoy", _target)
	_expect(_resolved == 1, "duplicate completion ignored")

	_prepare()
	_open_and_press()
	var escape := InputEventKey.new()
	escape.keycode = KEY_ESCAPE
	escape.pressed = true
	_presentation.call("_unhandled_input", escape)
	_expect(_resolved == 2, "Escape finishes video and resolves")

	_prepare()
	_open_and_press()
	_worldmap.call("cancel_contextual_worldmap_action")
	_presentation.call("_finish_pending_video")
	_expect(_resolved == 2, "cancelled context cannot execute")
	_expect(int(_worldmap.get("_player_state")["resource_stock"]["gold"]) == 10000, "cancel does not charge")

	_prepare()
	_open_and_press()
	_worldmap.get("_player_state")["resource_stock"]["gold"] = 0
	_presentation.call("_finish_pending_video")
	_expect(_resolved == 3, "resources revalidated after video")
	_expect(_worldmap.get("_player_state")["last_diplomacy_action_result"].get("reason") == "resources", "resource failure displayed")

	_prepare()
	root.get_node("GameSession").set("player_faction_id", "mongol")
	_open_and_press()
	_expect(_resolved == 4, "missing culture video completes synchronously")
	_expect(not bool(_worldmap.get("_contextual_worldmap_action_pending")), "synchronous completion clears pending state")
	root.get_node("GameSession").set("player_faction_id", "player")

	_prepare("player", 60, "neutral", 0)
	_worldmap.call("open_contextual_worldmap_action", "diplomacy", _target)
	var presentations_before := _presented
	_worldmap.call("_on_diplomacy_action_pressed", "envoy")
	_expect(_resolved == 5 and _presented == presentations_before, "invalid action resolves without video")
	_expect(_presentation.get_node("ResultOverlay").visible, "failure result visible immediately")

	# Let the result SFX finish before tearing down the audio autoload.
	await create_timer(2.2).timeout
	current_scene.queue_free()
	await process_frame
	await process_frame
	print("[DIPLOMACY_ROUTING] %s: %d checks, %d failures" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	quit(0 if _failures == 0 else 1)
