extends SceneTree

const SCENE_PATH := "res://WorldMap_16x9_Test.tscn"
const Service := preload("res://scripts/worldmap/actions/diplomacy_action_service.gd")

var _checks := 0
var _failures := 0
var _worldmap: Node
var _service: RefCounted
var _baseline: Dictionary
var _foreign_factions: Array[String] = []
var _city_by_faction := {}


func _initialize() -> void:
	call_deferred("_run")


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("[DIPLOMACY_ALLIANCE_2C2] FAIL: " + label)


func _prepare(score: int = 80, gold: int = 10000, silk: int = 10000) -> void:
	var state := _baseline.duplicate(true)
	state["player_faction_id"] = "player"
	state["resource_stock"] = {"gold": gold, "silk": silk, "rice": 10000}
	state["faction_relations"] = {}
	state["diplomacy_action_cooldowns"] = {}
	state["trade_agreements"] = {}
	state["alliances"] = {}
	state["last_alliance_proposal_result"] = {}
	state["last_diplomacy_action_result"] = {}
	_worldmap.set("_player_state", state)
	for faction_id in _foreign_factions:
		var relation: Dictionary = _worldmap.call("_ensure_faction_relation_entry", "player", faction_id)
		relation["score"] = score
		relation["status"] = "neutral"
		relation["diplomacy_action_cooldown"] = 0
		relation["alliance_turns_remaining"] = 0
	_worldmap.call("_sync_diplomacy_action_mirror_state_from_relations")


func _state() -> Dictionary:
	return _worldmap.get("_player_state")


func _entry(faction_id: String) -> Dictionary:
	return _worldmap.call("_get_faction_relation_entry", "player", faction_id)


func _store_entry(faction_id: String, entry: Dictionary) -> void:
	var state := _state()
	var relations: Dictionary = state.get("faction_relations", {})
	var key := str(_worldmap.call("_make_faction_relation_key", "player", faction_id))
	relations[key] = entry
	state["faction_relations"] = relations
	_worldmap.set("_player_state", state)


func _check_success_and_payment() -> void:
	_prepare()
	var faction_id := _foreign_factions[0]
	var city_id := str(_city_by_faction.get(faction_id, ""))
	var definition: Dictionary = Service.get_action_definition("alliance_proposal")
	var cost: Dictionary = definition.get("cost", {})
	var before_stock := (_state().get("resource_stock", {}) as Dictionary).duplicate(true)
	var before_score := int(_entry(faction_id).get("score", 0))
	var result: Dictionary = _service.call("execute", _worldmap, "alliance_proposal", city_id)
	var relation := _entry(faction_id)
	var duration := int(definition.get("alliance_turns", 0))
	_expect(bool(result.get("success", false)) and bool(result.get("accepted", false)), "alliance proposal accepted")
	_expect(int(before_stock.get("gold", 0)) - int(_state().get("resource_stock", {}).get("gold", 0)) == int(cost.get("gold", 0)), "gold charged exactly once")
	_expect(int(before_stock.get("silk", 0)) - int(_state().get("resource_stock", {}).get("silk", 0)) == int(cost.get("silk", 0)), "silk charged exactly once")
	_expect(int(result.get("payment", {}).get("paid", {}).get("gold", 0)) == int(cost.get("gold", 0)), "payment result records gold")
	_expect(str(relation.get("status", "")) == "allied", "relation status becomes allied")
	_expect(int(relation.get("alliance_turns_remaining", 0)) == duration, "alliance duration matches definition")
	_expect(int(relation.get("alliance_created_turn", 0)) == int(_state().get("turn_number", 1)), "created turn stored")
	_expect(relation.get("alliance_resource_package", {}) == cost, "resource package metadata stored")
	_expect(int(relation.get("alliance_acceptance_score", -1)) == int(result.get("acceptance_score", -2)), "acceptance metadata matches result")
	_expect(int(relation.get("score", 0)) == before_score and int(result.get("before_score", -1)) == before_score and int(result.get("after_score", -1)) == before_score, "alliance does not alter relation score")
	_expect(int(result.get("acceptance_threshold", 0)) == Service.ALLIANCE_ACCEPTANCE_THRESHOLD and int(result.get("required_score", 0)) == Service.ALLIANCE_ACCEPTANCE_THRESHOLD, "acceptance threshold contract")
	_expect(int(result.get("duration_turns", 0)) == duration and int(result.get("alliance_turns_remaining", 0)) == duration, "result duration contract")
	_expect(result.get("target_faction_id") == faction_id and result.get("target_city_id") == city_id, "result target contract")
	_expect(int(_state().get("alliances", {}).get(faction_id, {}).get("turns_remaining", 0)) == duration, "alliance mirror created")
	_expect(_state().get("last_alliance_proposal_result", {}).get("accepted", false) and _state().get("last_diplomacy_action_result", {}) == result, "last-result contracts stored")
	_expect(int(_worldmap.call("_get_active_alliance_turns", faction_id)) == duration, "legacy active-alliance API reads service state")
	_expect(_worldmap.has_method("_request_military_support") and _worldmap.has_method("_calculate_military_support_acceptance_chance"), "military support boundary remains available")


func _check_rejection_and_resource_failure() -> void:
	_prepare(0)
	var faction_id := _foreign_factions[0]
	var city_id := str(_city_by_faction.get(faction_id, ""))
	var cost: Dictionary = Service.get_action_definition("alliance_proposal").get("cost", {})
	var before_stock := (_state().get("resource_stock", {}) as Dictionary).duplicate(true)
	var result: Dictionary = _service.call("execute", _worldmap, "alliance_proposal", city_id)
	var relation := _entry(faction_id)
	_expect(not bool(result.get("success", true)) and not bool(result.get("accepted", true)) and result.get("reason") == "rejected", "alliance proposal rejection contract")
	_expect(int(before_stock.get("gold", 0)) - int(_state().get("resource_stock", {}).get("gold", 0)) == int(cost.get("gold", 0)), "rejected proposal charges gold once")
	_expect(int(before_stock.get("silk", 0)) - int(_state().get("resource_stock", {}).get("silk", 0)) == int(cost.get("silk", 0)), "rejected proposal charges silk once")
	_expect(str(relation.get("status", "")) == "neutral" and int(relation.get("alliance_turns_remaining", 0)) == 0, "rejection creates no alliance")
	_expect(not (_state().get("alliances", {}) as Dictionary).has(faction_id), "rejection creates no alliance mirror")
	_expect(int(result.get("acceptance_score", 100)) < int(result.get("required_score", 0)), "rejection score remains below threshold")

	_prepare(80, 0, 0)
	var stock_before_failure := (_state().get("resource_stock", {}) as Dictionary).duplicate(true)
	var relation_before_failure := _entry(faction_id).duplicate(true)
	var failed: Dictionary = _service.call("execute", _worldmap, "alliance_proposal", city_id)
	_expect(not bool(failed.get("success", true)) and failed.get("reason") == "resources", "insufficient resources rejected before execution")
	_expect(_state().get("resource_stock", {}) == stock_before_failure, "resource failure has no payment mutation")
	_expect(_entry(faction_id) == relation_before_failure, "resource failure has no relation or alliance mutation")
	_expect((_state().get("alliances", {}) as Dictionary).is_empty(), "resource failure has no mirror mutation")
	_expect((failed.get("payment", {}) as Dictionary).is_empty(), "resource failure has no payment result")


func _check_acceptance_and_wrapper_parity() -> void:
	_prepare(55)
	var faction_id := _foreign_factions[0]
	var definition: Dictionary = Service.get_action_definition("alliance_proposal")
	var package: Dictionary = definition.get("cost", {})
	var duration := int(definition.get("alliance_turns", 0))
	var base_chance := 55 + int(floor(float(package.get("gold", 0)) / 20.0)) + int(floor(float(package.get("silk", 0)) / 10.0)) - maxi(0, duration - Service.LEGACY_TRADE_AGREEMENT_TURNS)
	var expected := int(_worldmap.call("_get_modified_diplomacy_success_chance_mvp", base_chance, "alliance_proposal", faction_id))
	var wrapped_chance := int(_worldmap.call("_calculate_alliance_acceptance_chance", faction_id, package, duration))
	var direct_chance := int(_service.call("calculate_alliance_acceptance_chance", _worldmap, faction_id, package, duration))
	_expect(wrapped_chance == direct_chance and direct_chance == expected, "acceptance formula and modifier parity")
	_expect(int(_service.call("calculate_alliance_acceptance_chance", _worldmap, "player", package, duration)) == 0, "invalid self target acceptance is zero")

	_prepare(80)
	var before := _state().duplicate(true)
	var wrapped: bool = _worldmap.call("_propose_alliance", faction_id, package, duration)
	var wrapped_state := _state().duplicate(true)
	_worldmap.set("_player_state", before.duplicate(true))
	var direct: bool = _service.call("propose_alliance", _worldmap, faction_id, package, duration)
	_expect(wrapped == direct, "proposal wrapper return parity")
	_expect(_state() == wrapped_state, "proposal wrapper full-state parity")

	_prepare(80)
	var city_id := str(_city_by_faction.get(faction_id, ""))
	var validation: Dictionary = _worldmap.call("_validate_diplomacy_action", "alliance_proposal", city_id)
	before = _state().duplicate(true)
	var payment: Dictionary = _service.call("apply_diplomacy_resource_cost", _worldmap, package)
	validation["payment"] = payment
	var wrapped_result: Dictionary = _worldmap.call("_apply_alliance_diplomacy_action", validation)
	wrapped_state = _state().duplicate(true)
	_worldmap.set("_player_state", before.duplicate(true))
	payment = _service.call("apply_diplomacy_resource_cost", _worldmap, package)
	validation["payment"] = payment
	var direct_result: Dictionary = _service.call("apply_alliance_action", _worldmap, validation)
	_expect(direct_result == wrapped_result, "alliance action wrapper result parity")
	_expect(_state() == wrapped_state, "alliance action wrapper full-state parity")
	_expect(int(before.get("resource_stock", {}).get("gold", 0)) - int(_state().get("resource_stock", {}).get("gold", 0)) == int(package.get("gold", 0)), "prepaid action is not charged twice")


func _check_renewal_expiration_and_independence() -> void:
	_prepare(80)
	var first := _foreign_factions[0]
	var second := _foreign_factions[1]
	var package: Dictionary = Service.get_action_definition("alliance_proposal").get("cost", {})
	var duration := int(Service.get_action_definition("alliance_proposal").get("alliance_turns", 0))
	_expect(bool(_service.call("propose_alliance", _worldmap, first, package, duration)), "initial direct alliance succeeds")
	var state := _state()
	state["turn_number"] = int(state.get("turn_number", 1)) + 1
	_worldmap.set("_player_state", state)
	var first_entry := _entry(first)
	first_entry["alliance_turns_remaining"] = 1
	_store_entry(first, first_entry)
	_expect(bool(_service.call("propose_alliance", _worldmap, first, package, duration)), "alliance renewal succeeds")
	_expect(int(_entry(first).get("alliance_turns_remaining", 0)) == duration, "renewal resets duration")
	_expect(int(_entry(first).get("alliance_created_turn", 0)) == int(_state().get("turn_number", 0)), "renewal updates created turn")

	_expect(bool(_service.call("propose_alliance", _worldmap, second, package, duration)), "second faction alliance succeeds independently")
	first_entry = _entry(first)
	first_entry["alliance_turns_remaining"] = 2
	_store_entry(first, first_entry)
	var second_entry := _entry(second)
	second_entry["alliance_turns_remaining"] = 3
	_store_entry(second, second_entry)
	_worldmap.call("_sync_alliance_mirror_state_from_relations")
	var first_advance: Dictionary = _worldmap.call("_advance_diplomacy_cooldowns_for_world_turn")
	_expect(int(_entry(first).get("alliance_turns_remaining", 0)) == 1 and int(_entry(second).get("alliance_turns_remaining", 0)) == 2, "faction alliance durations decrement independently")
	_expect(int(first_advance.get("changed_count", 0)) == 2, "turn result records both alliance changes")
	_worldmap.call("_advance_diplomacy_cooldowns_for_world_turn")
	var expired := _entry(first)
	_expect(str(expired.get("status", "")) == "neutral" and int(expired.get("alliance_turns_remaining", -1)) == 0, "alliance expires at zero")
	_expect(not expired.has("alliance_created_turn") and not expired.has("alliance_resource_package") and not expired.has("alliance_acceptance_score"), "expiration clears alliance metadata")
	_expect(not (_state().get("alliances", {}) as Dictionary).has(first) and int(_state().get("alliances", {}).get(second, {}).get("turns_remaining", 0)) == 1, "mirror removes only expired faction")
	_worldmap.call("_advance_diplomacy_cooldowns_for_world_turn")
	_expect(str(_entry(second).get("status", "")) == "neutral" and (_state().get("alliances", {}) as Dictionary).is_empty(), "second alliance expires independently")
	var zero_state: Dictionary = Service.advance_alliance_state_entry("player|zero", {"status": "neutral", "alliance_turns_remaining": 0})
	_expect(int(zero_state.get("entry", {}).get("alliance_turns_remaining", -1)) == 0 and (zero_state.get("changed", []) as Array).is_empty(), "alliance duration clamps at zero")


func _check_mirror_restore() -> void:
	_prepare()
	var faction_id := _foreign_factions[0]
	var package: Dictionary = Service.get_action_definition("alliance_proposal").get("cost", {})
	var state := _state()
	state["alliances"] = {faction_id: {"turns_remaining": 3, "created_turn": int(state.get("turn_number", 1)), "resource_package": package, "acceptance_score": 75}}
	_worldmap.set("_player_state", state)
	_worldmap.call("_normalize_diplomacy_action_state_from_player_state")
	var relation := _entry(faction_id)
	_expect(str(relation.get("status", "")) == "allied" and int(relation.get("alliance_turns_remaining", 0)) == 3, "alliance mirror restores relation state")
	_expect(relation.get("alliance_resource_package", {}) == package and int(relation.get("alliance_acceptance_score", 0)) == 75, "alliance mirror restores metadata")
	var before_sync := _state().duplicate(true)
	_worldmap.call("_sync_alliance_mirror_state_from_relations")
	var wrapped_state := _state().duplicate(true)
	_worldmap.set("_player_state", before_sync.duplicate(true))
	_service.call("sync_alliance_mirror_state", _worldmap)
	_expect(_state() == wrapped_state, "alliance mirror wrapper and service parity")
	_expect(int(_state().get("alliances", {}).get(faction_id, {}).get("turns_remaining", 0)) == int(_entry(faction_id).get("alliance_turns_remaining", 0)), "relation and alliance mirror stay synchronized")


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
		if not owner.is_empty() and owner != "player" and not _city_by_faction.has(owner):
			_city_by_faction[owner] = city_id
			_foreign_factions.append(owner)
	_expect(_foreign_factions.size() >= 2, "two foreign factions exist")
	if _foreign_factions.size() >= 2:
		_check_success_and_payment()
		_check_rejection_and_resource_failure()
		_check_acceptance_and_wrapper_parity()
		_check_renewal_expiration_and_independence()
		_check_mirror_restore()

	current_scene.queue_free()
	await process_frame
	await process_frame
	print("[DIPLOMACY_ALLIANCE_2C2] %s: %d checks, %d failures" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	quit(0 if _failures == 0 else 1)
