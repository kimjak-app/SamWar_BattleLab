extends SceneTree

const SCENE_PATH := "res://WorldMap_16x9_Test.tscn"
const Service := preload("res://scripts/worldmap/actions/diplomacy_action_service.gd")
const ACTIONS := ["envoy", "tribute", "trade_agreement", "restore_relations", "alliance_proposal"]

var _failures := 0
var _checks := 0
var _worldmap: Node
var _baseline: Dictionary
var _foreign_city_id := ""
var _foreign_faction_id := ""
var _player_city_id := ""


func _initialize() -> void:
	call_deferred("_run")


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("[DIPLOMACY_VALIDATION_2A] FAIL: " + label)


func _prepare(score: int = 60, status: String = "neutral", gold: int = 10000, cooldown: int = 0, alliance_turns: int = 0) -> void:
	var state := _baseline.duplicate(true)
	state["player_faction_id"] = "player"
	state["resource_stock"] = {"gold": gold, "silk": 10000, "rice": 10000}
	state["faction_relations"] = {}
	state["diplomacy_action_cooldowns"] = {}
	_worldmap.set("_player_state", state)
	var relation: Dictionary = _worldmap.call("_ensure_faction_relation_entry", "player", _foreign_faction_id)
	relation["score"] = score
	relation["status"] = status
	relation["diplomacy_action_cooldown"] = cooldown
	relation["alliance_turns_remaining"] = alliance_turns


func _check_wrapper_service_parity(action_id: String, city_id: String, label: String) -> Dictionary:
	var context: Dictionary = _worldmap.call("_build_diplomacy_action_validation_context", action_id, city_id)
	var state_before: Dictionary = _worldmap.get("_player_state").duplicate(true)
	var direct: Dictionary = Service.validate_action(action_id, context)
	_expect(_worldmap.get("_player_state") == state_before, "pure service does not mutate state: " + label)
	var wrapped: Dictionary = _worldmap.call("_validate_diplomacy_action", action_id, city_id)
	_expect(wrapped == direct, "wrapper equals pure service: " + label)
	return direct


func _run() -> void:
	change_scene_to_file(SCENE_PATH)
	await process_frame
	await process_frame
	_worldmap = current_scene.get_node("ProductionWorldMap")
	_baseline = _worldmap.get("_player_state").duplicate(true)
	for city_id_variant in _worldmap.get("_city_markers_by_id"):
		var city_id := str(city_id_variant)
		var owner := str(_worldmap.call("_get_city_owner_faction_id_for_trade_display", city_id))
		if owner == "player" and _player_city_id.is_empty():
			_player_city_id = city_id
		elif not owner.is_empty() and owner != "player" and _foreign_city_id.is_empty():
			_foreign_city_id = city_id
			_foreign_faction_id = owner
	_expect(not _player_city_id.is_empty() and not _foreign_city_id.is_empty(), "player and foreign cities exist")

	for action_id in ACTIONS:
		var service_definition: Dictionary = Service.get_action_definition(action_id)
		var wrapper_definition: Dictionary = _worldmap.call("_get_diplomacy_action_definition", action_id)
		_expect(wrapper_definition == service_definition and not service_definition.is_empty(), "definition moved: " + action_id)
	_expect(Service.get_action_definition("unknown").is_empty(), "unknown definition remains empty")

	var raw_package := {"gold": 10, "silk": 0, "rice": -3, 7: 2}
	var raw_copy := raw_package.duplicate(true)
	var normalized: Dictionary = Service.normalize_resource_package(raw_package)
	_expect(normalized == {"gold": 10, "7": 2}, "resource package normalization unchanged")
	_expect(raw_package == raw_copy, "resource package input is not mutated")
	_expect(Service.normalize_resource_package(raw_package) == normalized, "normalization service is deterministic")

	_prepare()
	var invalid_action := _check_wrapper_service_parity("unknown", _foreign_city_id, "invalid action")
	_expect(invalid_action.get("reason") == "invalid_action" and invalid_action.get("message") == "외교 행동을 확인할 수 없습니다.", "invalid action contract unchanged")
	var invalid_target := _check_wrapper_service_parity("envoy", "missing_city", "invalid target")
	_expect(invalid_target.get("reason") == "invalid_target" and invalid_target.get("message") == "외교 대상을 확인할 수 없습니다.", "invalid target contract unchanged")
	var player_target := _check_wrapper_service_parity("envoy", _player_city_id, "player target")
	_expect(player_target.get("reason") == "player_faction" and player_target.get("message") == "자국 도시는 외교 대상이 아닙니다.", "player target contract unchanged")
	_worldmap.set("selected_city_marker", null)
	var no_selection := _check_wrapper_service_parity("envoy", "", "no selected city")
	_expect(no_selection.get("reason") == "no_city" and no_selection.get("message") == "도시를 선택해야 합니다.", "selection failure contract unchanged")
	for action_id in ACTIONS:
		_prepare(60, "hostile" if action_id == "restore_relations" else "neutral")
		_check_wrapper_service_parity(action_id, _foreign_city_id, "valid " + action_id)

	_prepare(60, "neutral", 10000, 2)
	var cooldown := _check_wrapper_service_parity("envoy", _foreign_city_id, "cooldown")
	_expect(cooldown.get("reason") == "cooldown" and cooldown.get("message") == "외교 사절단이 아직 복귀하지 않았습니다.", "cooldown contract unchanged")
	_prepare(60, "hostile")
	var blocked := _check_wrapper_service_parity("trade_agreement", _foreign_city_id, "blocked relation")
	_expect(blocked.get("reason") == "blocked_relation", "blocked relation reason unchanged")
	_prepare(20, "neutral")
	var low_score := _check_wrapper_service_parity("trade_agreement", _foreign_city_id, "low relation score")
	_expect(low_score.get("reason") == "relation_score" and low_score.get("required_score") == 45, "relation score contract unchanged")
	_prepare(60, "neutral")
	var not_needed := _check_wrapper_service_parity("restore_relations", _foreign_city_id, "restore not needed")
	_expect(not_needed.get("reason") == "not_needed", "restore relation reason unchanged")
	_prepare(80, "allied", 10000, 0, 4)
	var already_allied := _check_wrapper_service_parity("alliance_proposal", _foreign_city_id, "already allied")
	_expect(already_allied.get("reason") == "already_allied" and already_allied.get("alliance_turns") == 4, "alliance state contract unchanged")
	_prepare(60, "neutral", 0)
	var resources := _check_wrapper_service_parity("tribute", _foreign_city_id, "resource shortage")
	_expect(resources.get("reason") == "resources" and resources.has("missing"), "resource failure contract unchanged")

	var validation := {"reason": "resources", "message": "자원이 부족합니다.", "cost": {"gold": 100}, "missing": {"gold": 50}, "cooldown": 2}
	var validation_copy := validation.duplicate(true)
	var current_turn := maxi(1, int(_worldmap.get("_player_state").get("turn_number", 1)))
	var direct_failure: Dictionary = Service.build_failure_result(current_turn, "tribute", validation)
	var repeated_failure: Dictionary = Service.build_failure_result(current_turn, "tribute", validation)
	_expect(direct_failure == repeated_failure, "failure result service is deterministic")
	_expect(validation == validation_copy, "failure construction does not mutate validation")
	_expect(direct_failure.get("reason") == "resources" and direct_failure.get("message") == "자원이 부족합니다.", "failure reason and message unchanged")
	_expect(direct_failure.get("cost") == {"gold": 100} and direct_failure.get("missing") == {"gold": 50}, "failure cost details unchanged")

	current_scene.queue_free()
	await process_frame
	await process_frame
	print("[DIPLOMACY_VALIDATION_2A] %s: %d checks, %d failures" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	quit(0 if _failures == 0 else 1)
