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
		push_error("[DIPLOMACY_STATE_2C1] FAIL: " + label)


func _prepare(score: int = 60, status: String = "neutral") -> void:
	var state := _baseline.duplicate(true)
	state["player_faction_id"] = "player"
	state["resource_stock"] = {"gold": 10000, "silk": 10000, "rice": 10000}
	state["faction_relations"] = {}
	state["diplomacy_action_cooldowns"] = {}
	state["trade_agreements"] = {}
	state["alliances"] = {}
	_worldmap.set("_player_state", state)
	for faction_id in _foreign_factions:
		var relation: Dictionary = _worldmap.call("_ensure_faction_relation_entry", "player", faction_id)
		relation["score"] = score
		relation["status"] = status
		relation["diplomacy_action_cooldown"] = 0
		relation["trade_agreement_active"] = false
		relation["trade_agreement_turns_remaining"] = 0
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


func _check_cooldown_state() -> void:
	_prepare()
	var envoy_definition: Dictionary = Service.get_action_definition("envoy")
	var restore_definition: Dictionary = Service.get_action_definition("restore_relations")
	var first := _foreign_factions[0]
	var second := _foreign_factions[1]
	var first_turns := int(restore_definition.get("cooldown", 0))
	var second_turns := int(envoy_definition.get("cooldown", 0))
	_service.call("set_diplomacy_action_cooldown", _worldmap, first, first_turns)
	_service.call("set_diplomacy_action_cooldown", _worldmap, second, second_turns)
	_expect(int(_entry(first).get("diplomacy_action_cooldown", -1)) == first_turns, "first faction cooldown set")
	_expect(int(_entry(second).get("diplomacy_action_cooldown", -1)) == second_turns, "second faction cooldown independent")
	_expect(int(_state().get("diplomacy_action_cooldowns", {}).get(first, -1)) == first_turns, "first cooldown mirror")
	_expect(int(_state().get("diplomacy_action_cooldowns", {}).get(second, -1)) == second_turns, "second cooldown mirror")
	_expect(int(_worldmap.call("_get_diplomacy_action_cooldown", first)) == first_turns, "cooldown wrapper reads service state")
	_worldmap.call("_set_diplomacy_action_cooldown", first, -first_turns)
	_expect(int(_entry(first).get("diplomacy_action_cooldown", -1)) == 0, "cooldown clamps at zero")
	_expect(not (_state().get("diplomacy_action_cooldowns", {}) as Dictionary).has(first), "zero cooldown omitted from mirror")
	_expect(int(_entry(second).get("diplomacy_action_cooldown", -1)) == second_turns, "clamp leaves other faction unchanged")


func _check_action_cooldown_and_rejection() -> void:
	_prepare()
	var faction_id := _foreign_factions[0]
	var city_id := str(_city_by_faction.get(faction_id, ""))
	var definition: Dictionary = Service.get_action_definition("tribute")
	var before_gold := int(_state().get("resource_stock", {}).get("gold", 0))
	var first: Dictionary = _service.call("execute", _worldmap, "tribute", city_id)
	var expected_cooldown := int(definition.get("cooldown", 0))
	_expect(bool(first.get("success", false)), "successful action sets cooldown")
	_expect(int(_entry(faction_id).get("diplomacy_action_cooldown", -1)) == expected_cooldown, "relation cooldown equals action definition")
	_expect(int(_state().get("diplomacy_action_cooldowns", {}).get(faction_id, -1)) == expected_cooldown, "successful cooldown mirrored")
	var stock_before_reject := (_state().get("resource_stock", {}) as Dictionary).duplicate(true)
	var relation_before_reject := _entry(faction_id).duplicate(true)
	var rejected: Dictionary = _service.call("execute", _worldmap, "envoy", city_id)
	_expect(not bool(rejected.get("success", false)) and rejected.get("reason") == "cooldown", "cooldown rejects next action")
	_expect(_state().get("resource_stock", {}) == stock_before_reject, "cooldown rejection has no resource mutation")
	_expect(_entry(faction_id) == relation_before_reject, "cooldown rejection has no relation state mutation")
	_expect(before_gold - int(_state().get("resource_stock", {}).get("gold", 0)) == int(definition.get("cost", {}).get("gold", 0)), "successful action charged once")


func _check_turn_advance_and_expiry() -> void:
	_prepare()
	var faction_id := _foreign_factions[0]
	var entry := _entry(faction_id)
	var cooldown := int(Service.get_action_definition("trade_agreement").get("cooldown", 0))
	entry["diplomacy_action_cooldown"] = cooldown
	entry["trade_agreement_active"] = true
	entry["trade_agreement_turns_remaining"] = cooldown
	entry["trade_agreement_bonus"] = Service.TRADE_AGREEMENT_MULTIPLIER_BONUS
	entry["trade_agreement_source"] = "diplomacy_action"
	entry["trade_agreement_created_turn"] = int(_state().get("turn_number", 1))
	_store_entry(faction_id, entry)
	_worldmap.call("_sync_diplomacy_action_mirror_state_from_relations")
	var first: Dictionary = _worldmap.call("_advance_diplomacy_cooldowns_for_world_turn")
	_expect(int(_entry(faction_id).get("diplomacy_action_cooldown", -1)) == cooldown - 1, "turn advance decrements action cooldown")
	_expect(int(_entry(faction_id).get("trade_agreement_turns_remaining", -1)) == cooldown - 1, "turn advance decrements agreement")
	_expect(int(first.get("changed_count", 0)) == 2, "turn result records cooldown and agreement")
	var first_changes: Array = first.get("changed", [])
	_expect(first_changes.size() == 2 and first_changes[0].get("type") == "diplomacy_action_cooldown" and first_changes[1].get("type") == "trade_agreement", "turn result order unchanged")
	var second: Dictionary = _worldmap.call("_advance_diplomacy_cooldowns_for_world_turn")
	var expired := _entry(faction_id)
	_expect(int(expired.get("diplomacy_action_cooldown", -1)) == 0, "cooldown reaches zero")
	_expect(int(expired.get("trade_agreement_turns_remaining", -1)) == 0 and not bool(expired.get("trade_agreement_active", true)), "agreement expires at zero")
	_expect(not expired.has("trade_agreement_source") and not expired.has("trade_agreement_created_turn"), "agreement expiry clears metadata")
	_expect((_state().get("diplomacy_action_cooldowns", {}) as Dictionary).is_empty(), "expired cooldown removed from mirror")
	_expect((_state().get("trade_agreements", {}) as Dictionary).is_empty(), "expired agreement removed from mirror")
	_expect(int(second.get("changed_count", 0)) == 2, "expiry changes recorded")
	var third: Dictionary = _worldmap.call("_advance_diplomacy_cooldowns_for_world_turn")
	_expect(int(third.get("changed_count", -1)) == 0, "zero state does not decrement below zero")


func _check_trade_agreement_creation_and_renewal() -> void:
	_prepare()
	var faction_id := _foreign_factions[0]
	var city_id := str(_city_by_faction.get(faction_id, ""))
	var definition: Dictionary = Service.get_action_definition("trade_agreement")
	var duration := int(definition.get("agreement_turns", 0))
	var created: Dictionary = _service.call("execute", _worldmap, "trade_agreement", city_id)
	var relation := _entry(faction_id)
	_expect(bool(created.get("success", false)), "trade agreement action succeeds")
	_expect(int(relation.get("trade_agreement_turns_remaining", 0)) == duration, "agreement duration matches definition")
	_expect(bool(relation.get("trade_agreement_active", false)), "agreement active in relation")
	_expect(str(relation.get("status", "")) == "neutral", "agreement does not change relation status")
	_expect(created.get("target_faction_id") == faction_id and created.get("agreement", {}).get("turns_remaining") == duration, "agreement result target and duration")
	_expect(int(_state().get("trade_agreements", {}).get(faction_id, {}).get("turns_remaining", 0)) == duration, "agreement mirror created")
	_expect(_state().get("last_trade_agreement_result", {}).get("target_faction_id") == faction_id, "last agreement result target")
	_worldmap.call("_set_diplomacy_action_cooldown", faction_id, 0)
	relation = _entry(faction_id)
	relation["trade_agreement_turns_remaining"] = maxi(1, duration - 1)
	_store_entry(faction_id, relation)
	var renewed: Dictionary = _service.call("execute", _worldmap, "trade_agreement", city_id)
	_expect(bool(renewed.get("success", false)), "agreement renewal succeeds")
	_expect(int(_entry(faction_id).get("trade_agreement_turns_remaining", 0)) == duration, "renewal resets full duration")


func _check_trade_agreement_failure_and_compatibility() -> void:
	_prepare(60, "hostile")
	var faction_id := _foreign_factions[0]
	var city_id := str(_city_by_faction.get(faction_id, ""))
	var relation_before := _entry(faction_id).duplicate(true)
	var mirror_before := (_state().get("trade_agreements", {}) as Dictionary).duplicate(true)
	var failed: Dictionary = _service.call("execute", _worldmap, "trade_agreement", city_id)
	_expect(not bool(failed.get("success", false)) and failed.get("reason") == "blocked_relation", "blocked agreement fails")
	_expect(_entry(faction_id) == relation_before, "failed agreement leaves relation state unchanged")
	_expect(_state().get("trade_agreements", {}) == mirror_before, "failed agreement leaves mirror unchanged")

	_prepare()
	var before := _state().duplicate(true)
	var wrapped: bool = _worldmap.call("_propose_trade_agreement", faction_id)
	var wrapped_state := _state().duplicate(true)
	_worldmap.set("_player_state", before.duplicate(true))
	var direct: bool = _service.call("propose_trade_agreement", _worldmap, faction_id)
	_expect(direct == wrapped, "legacy agreement wrapper return parity")
	_expect(_state() == wrapped_state, "legacy agreement wrapper state parity")
	_expect(int(_entry(faction_id).get("trade_agreement_turns_remaining", 0)) == Service.LEGACY_TRADE_AGREEMENT_TURNS, "legacy agreement duration unchanged")


func _check_mirror_restore_and_alliance_preservation() -> void:
	_prepare()
	var faction_id := _foreign_factions[0]
	var action_cooldown := int(Service.get_action_definition("restore_relations").get("cooldown", 0))
	var agreement_turns := int(Service.get_action_definition("trade_agreement").get("agreement_turns", 0))
	var state := _state()
	state["diplomacy_action_cooldowns"] = {faction_id: action_cooldown}
	state["trade_agreements"] = {faction_id: {"turns_remaining": agreement_turns, "source": "diplomacy_action", "created_turn": int(state.get("turn_number", 1)), "bonus": Service.TRADE_AGREEMENT_MULTIPLIER_BONUS}}
	state["alliances"] = {faction_id: {"turns_remaining": 2, "created_turn": int(state.get("turn_number", 1)), "resource_package": {}, "acceptance_score": 80}}
	_worldmap.set("_player_state", state)
	_worldmap.call("_normalize_diplomacy_action_state_from_player_state")
	var restored := _entry(faction_id)
	_expect(int(restored.get("diplomacy_action_cooldown", 0)) == action_cooldown, "cooldown mirror restores relation")
	_expect(bool(restored.get("trade_agreement_active", false)) and int(restored.get("trade_agreement_turns_remaining", 0)) == agreement_turns, "agreement mirror restores relation")
	_expect(str(restored.get("status", "")) == "allied" and int(restored.get("alliance_turns_remaining", 0)) == 2, "alliance restore remains in main")
	_worldmap.call("_sync_diplomacy_action_mirror_state_from_relations")
	_expect(int(_state().get("diplomacy_action_cooldowns", {}).get(faction_id, 0)) == action_cooldown, "cooldown relation and mirror consistent")
	_expect(int(_state().get("trade_agreements", {}).get(faction_id, {}).get("turns_remaining", 0)) == agreement_turns, "agreement relation and mirror consistent")
	_expect(int(_state().get("alliances", {}).get(faction_id, {}).get("turns_remaining", 0)) == 2, "alliance mirror preserved by main adapter")


func _check_legacy_action_parity() -> void:
	_prepare()
	var faction_id := _foreign_factions[0]
	var city_id := str(_city_by_faction.get(faction_id, ""))
	var before := _state().duplicate(true)
	var legacy: Dictionary = _worldmap.call("_apply_diplomacy_action_legacy", "trade_agreement", city_id)
	var expected_state := _state().duplicate(true)
	_worldmap.set("_player_state", before.duplicate(true))
	var direct: Dictionary = _service.call("execute", _worldmap, "trade_agreement", city_id)
	_expect(direct == legacy, "trade agreement action result parity")
	_expect(_state() == expected_state, "trade agreement action state parity")


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
		_check_cooldown_state()
		_check_action_cooldown_and_rejection()
		_check_turn_advance_and_expiry()
		_check_trade_agreement_creation_and_renewal()
		_check_trade_agreement_failure_and_compatibility()
		_check_mirror_restore_and_alliance_preservation()
		_check_legacy_action_parity()

	current_scene.queue_free()
	await process_frame
	await process_frame
	print("[DIPLOMACY_STATE_2C1] %s: %d checks, %d failures" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	quit(0 if _failures == 0 else 1)
