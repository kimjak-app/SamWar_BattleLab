extends SceneTree

const Controller := preload("res://scripts/worldmap/actions/diplomacy_controller.gd")
const Coordinator := preload("res://scripts/worldmap/actions/worldmap_action_coordinator.gd")
const Service := preload("res://scripts/worldmap/actions/diplomacy_action_service.gd")
const Presenter := preload("res://scripts/worldmap/actions/diplomacy_presentation_helper.gd")
const Marker := preload("res://scripts/worldmap_city_marker.gd")

# Deliberately has no diplomacy context/relation/mirror methods. Successful
# execution proves that Service receives the Controller, not a giant scene host.
class GenericHost extends Node:
	const CITY_HUD_DATA := {"foreign": {"owner": "enemy"}, "own": {"owner": "player"}}
	const RESOURCE_LABELS := {"gold": "금전", "silk": "비단"}
	const FACTION_LABELS := {"enemy": "상대국", "player": "자국"}
	var _player_state: Dictionary = {}
	var _save_management_status := ""
	var selected_city_marker: WorldMapCityMarker = null

	func _get_current_player_faction_id() -> String:
		return str(_player_state.get("player_faction_id", "player"))
	func _get_city_owner_faction_id_for_trade_display(city_id: String) -> String:
		return str(CITY_HUD_DATA.get(city_id, {}).get("owner", ""))
	func _get_city_owner_faction_id(city_data: Dictionary) -> String:
		return str(city_data.get("owner", ""))
	func _get_enemy_owned_city_count_mvp(_faction: String) -> int:
		return 2
	func _format_enemy_city_baseline_grade_label_mvp(_score: int) -> String:
		return "보통"
	func _get_domestic_tech_diplomacy_spy_bonus_mvp() -> Dictionary:
		return {}
	func _get_unique_domestic_tech_source_ids_mvp(_sources: Variant) -> Array[String]:
		return []
	func _has_completed_national_domestic_tech_mvp(_tech: String) -> bool:
		return false
	func _append_domestic_modifier_source_if_completed_mvp(_modifier: Dictionary, _tech: String) -> void:
		pass
	func _get_total_recruitment_food_stock() -> int:
		var stock: Dictionary = _player_state.get("resource_stock", {})
		return int(stock.get("rice", 0)) + int(stock.get("barley", 0)) + int(stock.get("seafood", 0))
	func _format_faction_label(faction: String) -> String:
		return str(FACTION_LABELS.get(faction, faction))
	func _format_resource_costs(cost: Dictionary, order: Array) -> String:
		var parts: Array[String] = []
		for resource in order:
			if int(cost.get(resource, 0)) > 0:
				parts.append("%s %d" % [RESOURCE_LABELS.get(resource, resource), cost[resource]])
		return " / ".join(parts)
	func _can_trade_between_factions(_a: String, _b: String) -> bool:
		return true
	func _format_domestic_tech_percent_bonus_mvp(value: float) -> String:
		return "%d%%" % int(round(value * 100))

var _checks := 0
var _failures := 0
var _resolved := 0
var _presented := 0
var _host := GenericHost.new()
var _controller := Controller.new()
var _coordinator := Coordinator.new()
var _presenter := Presenter.new()
var _service := Service.new()


func _initialize() -> void:
	call_deferred("_run")


func _expect(ok: bool, label: String) -> void:
	_checks += 1
	if not ok:
		_failures += 1
		push_error("[DIPLOMACY_CONTROLLER_2F] FAIL: " + label)


func _reset(faction: String = "player", status: String = "neutral") -> void:
	_coordinator.cancel()
	_host._player_state = {
		"player_faction_id": faction, "turn_number": 7,
		"resource_stock": {"gold": 1000, "silk": 100, "rice": 30},
		"faction_relations": {}, "diplomacy_action_cooldowns": {},
		"trade_agreements": {}, "alliances": {}, "last_diplomacy_action_result": {},
	}
	var entry := _controller._ensure_faction_relation_entry(faction, "enemy")
	entry["score"] = 80
	entry["status"] = status


func _check_routes() -> void:
	for faction in ["player", "silla"]:
		for action in ["envoy", "tribute", "trade_agreement", "restore_relations", "alliance_proposal", "unknown"]:
			_reset(faction, "hostile" if action == "restore_relations" else "neutral")
			var initial := _host._player_state.duplicate(true)
			var context := _controller._build_diplomacy_action_validation_context(action, "foreign")
			_expect(_controller._validate_diplomacy_action(action, "foreign") == Service.validate_action(action, context), "validation parity " + action)
			_host._player_state = initial.duplicate(true)
			var expected := _service.execute(_controller, action, "foreign")
			var expected_state := _host._player_state.duplicate(true)
			_host._player_state = initial.duplicate(true)
			var immediate := _coordinator.execute_now("diplomacy", action, "foreign")
			_expect(immediate == expected, "execute_now dictionary parity " + action)
			_expect(_host._player_state == expected_state, "execute_now full state parity " + action)
			_expect(_host._save_management_status == str(expected["message"]), "status storage bridge " + action)
			_host._player_state = initial.duplicate(true)
			_coordinator.begin("diplomacy", "foreign")
			var resolved_before := _resolved
			var presented_before := _presented
			_coordinator.request_presentation("diplomacy", action, "foreign")
			_expect(_host._player_state == initial, "presentation is not mutation " + action)
			var completed := _coordinator.complete("diplomacy", action, "foreign")
			_expect(completed == expected and _host._player_state == expected_state, "video completion parity " + action)
			_expect(_resolved == resolved_before + 1 and _presented == presented_before + 1, "one presentation and resolution " + action)
			_expect(_coordinator.complete("diplomacy", action, "foreign").get("reason") == "not_pending", "repeat complete is inert " + action)


func _check_cancel_and_targets() -> void:
	_reset()
	var initial := _host._player_state.duplicate(true)
	_coordinator.begin("diplomacy", "foreign")
	_coordinator.request_presentation("diplomacy", "envoy", "foreign")
	_coordinator.cancel()
	_expect(_coordinator.complete("diplomacy", "envoy", "foreign").get("reason") == "not_pending", "cancel rejects completion")
	_expect(_host._player_state == initial, "cancel preserves state")
	_coordinator.begin("diplomacy", "foreign")
	_coordinator.request_presentation("diplomacy", "envoy", "foreign")
	_expect(_coordinator.complete("diplomacy", "envoy", "own").get("reason") == "context_changed", "changed target rejected")
	_expect(_host._player_state == initial, "changed target preserves state")
	_expect(_controller._validate_diplomacy_action("envoy").get("reason") == "no_city", "missing selected target")
	_expect(_controller._validate_diplomacy_action("envoy", "own").get("reason") == "player_faction", "own target rejected")
	_expect(_controller._validate_diplomacy_action("envoy", "missing").get("reason") == "invalid_target", "unknown target rejected")
	_host._player_state["resource_stock"] = {}
	_expect(_controller._validate_diplomacy_action("envoy", "foreign").get("reason") == "resources", "resource failure")


func _check_restore_and_turn() -> void:
	_reset()
	var identity: int = _controller.get("_service").get_instance_id()
	_host._player_state["faction_relations"] = {}
	_host._player_state["diplomacy_action_cooldowns"] = {"enemy": 2}
	_host._player_state["trade_agreements"] = {"enemy": {"turns_remaining": 2, "bonus": 0.15}}
	_host._player_state["alliances"] = {"enemy": {"turns_remaining": 2}}
	_controller._normalize_diplomacy_action_state_from_player_state()
	_expect(_controller._get_diplomacy_action_cooldown("enemy") == 2, "restore cooldown")
	_expect(_controller._get_active_trade_agreement_turns("enemy") == 2, "restore agreement")
	_expect(_controller._get_active_alliance_turns("enemy") == 2, "restore alliance query")
	var snapshot := _host._player_state.duplicate(true)
	# Serialization and dictionary replacement emulate the generic load boundary.
	_host._player_state = str_to_var(var_to_str(snapshot))
	_controller._normalize_diplomacy_action_state_from_player_state()
	_expect(_host._player_state == snapshot, "save/load restore idempotent")
	_expect(_controller.get("_service").get_instance_id() == identity, "load keeps single Service instance")
	var first := _controller._advance_diplomacy_cooldowns_for_world_turn()
	_expect(first["changed_count"] == 3, "turn advances all three state families")
	_expect(_controller._get_diplomacy_action_cooldown("enemy") == 1, "turn cooldown")
	_expect(_controller._get_active_trade_agreement_turns("enemy") == 1, "turn agreement")
	_expect(_controller._get_active_alliance_turns("enemy") == 1, "turn alliance")
	_controller._advance_diplomacy_cooldowns_for_world_turn()
	_expect(_controller._get_faction_relation_status("player", "enemy") == "neutral", "alliance expiry boundary")
	_expect(_controller._get_trade_agreement_bonus_multiplier("player", "enemy") == 0.0, "agreement expiry boundary")
	_expect(_host._player_state["alliances"].is_empty() and _host._player_state["trade_agreements"].is_empty(), "expired mirrors removed")
	_expect(_controller._advance_diplomacy_cooldowns_for_world_turn()["changed_count"] == 0, "expired state remains stable")
	var normalize := _controller._normalize_faction_relations_for_world_state()
	_expect(normalize["known_faction_count"] == 2 and normalize["ensured_count"] == 1, "generic city storage normalization")


func _check_presentation() -> void:
	_reset()
	_expect(_presenter.build_action_card_model(null) == {"visible": false}, "no selection card hidden")
	_expect(_presenter._format_last_diplomacy_action_result_for_ui() == "최근 외교\n기록 없음", "empty result text")
	var marker := Marker.new()
	marker.city_id = "foreign"
	_host.selected_city_marker = marker
	_expect(_controller._get_selected_diplomacy_target()["target_faction_id"] == "enemy", "selected target adapter")
	var card := _presenter.build_action_card_model(marker)
	_expect(card["title"] == "외교 실행 · 상대국", "card title")
	_expect(card["status"] == "중립 · 관계 80 / 행동 가능", "card status")
	var validation: Dictionary = card["validation_map"]["envoy"]
	var button := _presenter.build_action_button_model(validation)
	_expect(not button["disabled"] and button["tooltip"] == "행동 가능 · 비용 금전 30 · 관계 +5 · 쿨다운 1턴", "envoy tooltip")
	var blocked := _presenter.build_action_button_model({"ok": false, "message": "자원이 부족합니다."})
	_expect(blocked == {"disabled": true, "tooltip": "행동 불가 · 자원이 부족합니다."}, "blocked tooltip")
	var result := _coordinator.execute_now("diplomacy", "envoy", "foreign")
	_expect(result["success"], "presented action succeeds")
	_expect(_presenter._format_last_diplomacy_action_result_for_ui("enemy") == "최근 외교\n사절 파견 → 상대국\n관계 80 → 85 / 금전 -30", "success result text")
	card = _presenter.build_action_card_model(marker)
	_expect(card["status"] == "중립 · 관계 85 / 쿨다운 1턴", "cooldown card text")
	_expect(str(card["hint"]).begins_with("행동 불가\n사절 파견:"), "blocked hint")
	_expect(_presenter._format_last_diplomacy_action_result_for_ui("other") == "최근 외교\n선택 세력 관련 기록 없음", "result target filter")
	_host.selected_city_marker = null
	marker.free()


func _run() -> void:
	root.add_child(_host)
	_host.add_child(_coordinator)
	_controller.configure(_host)
	_presenter.configure(_host, _controller)
	_coordinator.configure_diplomacy(_controller)
	_coordinator.action_resolved.connect(func(_kind: String, _result: Dictionary) -> void: _resolved += 1)
	_coordinator.presentation_requested.connect(func(_kind: String, _action: String, _target: String) -> void: _presented += 1)
	_expect(not _host.has_method("_build_diplomacy_action_validation_context"), "minimal host has no diplomacy implementation")
	_check_routes()
	_check_cancel_and_targets()
	_check_restore_and_turn()
	_check_presentation()
	_host.free()
	print("[DIPLOMACY_CONTROLLER_2F] %s: %d checks, %d failures" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	quit(0 if _failures == 0 else 1)
