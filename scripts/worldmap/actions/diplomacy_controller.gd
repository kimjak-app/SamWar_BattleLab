class_name WorldMapDiplomacyController
extends RefCounted

const DiplomacyActionServiceScript := preload("res://scripts/worldmap/actions/diplomacy_action_service.gd")
const ALLIANCE_ACCEPTANCE_THRESHOLD := DiplomacyActionServiceScript.ALLIANCE_ACCEPTANCE_THRESHOLD

const FACTION_RELATION_STATUS := {
	"ALLIED": "allied",
	"NEUTRAL": "neutral",
	"HOSTILE": "hostile",
	"SUSPENDED": "suspended",
}
const DIPLOMACY_SCORE_MIN := 0
const DIPLOMACY_SCORE_MAX := 100
const DIPLOMACY_DEFAULT_SCORE := 50
const DIPLOMACY_ACTION_ENVOY := "envoy"
const DIPLOMACY_ACTION_TRIBUTE := "tribute"
const DIPLOMACY_ACTION_TRADE_AGREEMENT := "trade_agreement"
const DIPLOMACY_ACTION_RESTORE_RELATIONS := "restore_relations"
const DIPLOMACY_ACTION_ALLIANCE_PROPOSAL := "alliance_proposal"

var _host: Node
var _service = DiplomacyActionServiceScript.new()

# Generic state storage stays with the worldmap. Always read the current dictionary
# so load/replacement cannot leave the controller holding an obsolete snapshot.
var _player_state: Dictionary:
	get:
		return _host.get("_player_state")
	set(value):
		_host.set("_player_state", value)

# Accessed dynamically by DiplomacyActionService through Object.set().
@warning_ignore("unused_private_class_variable")
var _save_management_status: String:
	get:
		return str(_host.get("_save_management_status"))
	set(value):
		_host.set("_save_management_status", value)


var selected_city_marker: WorldMapCityMarker:
	get:
		return _host.get("selected_city_marker")

var CITY_HUD_DATA: Dictionary:
	get:
		return _host.get("CITY_HUD_DATA")


func configure(host: Node) -> void:
	_host = host


func execute(action_id: String, target_city_id: String = "", source_city_id: String = "") -> Dictionary:
	return _service.execute(self, action_id, target_city_id, source_city_id)


# Compatibility names intentionally match the existing Service adapter contract.
# Main keeps only the subset required by UI and other domain boundaries.
func _make_faction_relation_key(faction_a: String, faction_b: String) -> String:
	var ids := [faction_a, faction_b]
	ids.sort()
	return "%s|%s" % [str(ids[0]), str(ids[1])]


func _normalize_faction_relation_status(status: String) -> String:
	match status:
		"allied", "trade":
			return FACTION_RELATION_STATUS["ALLIED"]
		"hostile", "war":
			return FACTION_RELATION_STATUS["HOSTILE"]
		"suspended", "trade_suspended", "trade_paused":
			return FACTION_RELATION_STATUS["SUSPENDED"]
		_:
			return FACTION_RELATION_STATUS["NEUTRAL"]


func _get_faction_relation_band(score: int) -> String:
	var normalized_score := clampi(score, DIPLOMACY_SCORE_MIN, DIPLOMACY_SCORE_MAX)
	if normalized_score >= 70:
		return "friendly"
	if normalized_score <= 30:
		return "hostile"
	return "neutral"


func _ensure_faction_relation_entry(faction_a: String, faction_b: String) -> Dictionary:
	if faction_a.is_empty() or faction_b.is_empty() or faction_a == faction_b:
		return {
			"status": FACTION_RELATION_STATUS["NEUTRAL"],
			"score": DIPLOMACY_DEFAULT_SCORE,
			"cooldown": 0,
		}
	if not _player_state.has("faction_relations") or not (_player_state["faction_relations"] is Dictionary):
		_player_state["faction_relations"] = {}
	var relations: Dictionary = _player_state["faction_relations"]
	var relation_key := _make_faction_relation_key(faction_a, faction_b)
	var raw_entry: Variant = relations.get(relation_key, {})
	var entry := {}
	if raw_entry is Dictionary:
		entry = (raw_entry as Dictionary).duplicate(true)
		entry["status"] = _normalize_faction_relation_status(str(entry.get("status", FACTION_RELATION_STATUS["NEUTRAL"])))
	else:
		entry["status"] = _normalize_faction_relation_status(str(raw_entry))
	if not entry.has("score"):
		entry["score"] = DIPLOMACY_DEFAULT_SCORE
	entry["score"] = clampi(int(entry.get("score", DIPLOMACY_DEFAULT_SCORE)), DIPLOMACY_SCORE_MIN, DIPLOMACY_SCORE_MAX)
	if not entry.has("cooldown"):
		entry["cooldown"] = 0
	entry["cooldown"] = maxi(0, int(entry.get("cooldown", 0)))
	entry = DiplomacyActionServiceScript.normalize_diplomacy_relation_entry(entry)
	if not entry.has("military_support_rejection_count"):
		entry["military_support_rejection_count"] = 0
	entry["military_support_rejection_count"] = maxi(0, int(entry.get("military_support_rejection_count", 0)))
	relations[relation_key] = entry
	_player_state["faction_relations"] = relations
	return entry


func _get_faction_relation_entry(faction_a: String, faction_b: String) -> Dictionary:
	return _ensure_faction_relation_entry(faction_a, faction_b)


func _get_faction_relation_score(faction_a: String, faction_b: String) -> int:
	var entry := _get_faction_relation_entry(faction_a, faction_b)
	return clampi(int(entry.get("score", DIPLOMACY_DEFAULT_SCORE)), DIPLOMACY_SCORE_MIN, DIPLOMACY_SCORE_MAX)


func _get_faction_relation_status(faction_a: String, faction_b: String) -> String:
	if faction_a.is_empty() or faction_b.is_empty() or faction_a == faction_b:
		return FACTION_RELATION_STATUS["NEUTRAL"]
	var entry := _get_faction_relation_entry(faction_a, faction_b)
	return _normalize_faction_relation_status(str(entry.get("status", FACTION_RELATION_STATUS["NEUTRAL"])))


func _normalize_diplomacy_action_state_from_player_state() -> void:
	if not _player_state.has("last_diplomacy_action_result") or not (_player_state["last_diplomacy_action_result"] is Dictionary):
		_player_state["last_diplomacy_action_result"] = {}
	_service.restore_diplomacy_state_from_mirrors(self)
	_service.restore_alliance_state_from_mirror(self)
	_sync_diplomacy_action_mirror_state_from_relations()


func _sync_diplomacy_action_mirror_state_from_relations() -> void:
	_service.sync_diplomacy_mirror_state(self)
	_service.sync_alliance_mirror_state(self)


func _get_selected_diplomacy_target() -> Dictionary:
	if selected_city_marker == null:
		return {"ok": false, "reason": "no_city", "message": "도시를 선택해야 합니다."}
	var target_city_id := selected_city_marker.city_id
	var target_faction_id := _get_city_owner_faction_id_for_trade_display(target_city_id)
	if target_faction_id.is_empty():
		return {"ok": false, "reason": "missing_faction", "target_city_id": target_city_id, "message": "소유 세력을 확인할 수 없습니다."}
	return {
		"ok": true,
		"target_city_id": target_city_id,
		"target_faction_id": target_faction_id,
	}


func _get_diplomacy_action_definition(action_id: String) -> Dictionary:
	return DiplomacyActionServiceScript.get_action_definition(action_id)


func _get_diplomacy_action_cooldown(target_faction_id: String) -> int:
	return _service.get_diplomacy_action_cooldown(self, target_faction_id)


func _build_diplomacy_action_validation_context(action_id: String, target_city_id: String = "") -> Dictionary:
	var definition := _get_diplomacy_action_definition(action_id)
	var context := {"definition": definition}
	if definition.is_empty():
		return context
	var resolved_city_id := target_city_id
	var target_faction_id := ""
	if resolved_city_id.is_empty():
		var selected_target := _get_selected_diplomacy_target()
		if not bool(selected_target.get("ok", false)):
			context["target_error"] = selected_target
			return context
		resolved_city_id = str(selected_target.get("target_city_id", ""))
		target_faction_id = str(selected_target.get("target_faction_id", ""))
	else:
		target_faction_id = _get_city_owner_faction_id_for_trade_display(resolved_city_id)
	var player_faction_id := _get_current_player_faction_id()
	context["target_city_id"] = resolved_city_id
	context["target_faction_id"] = target_faction_id
	context["player_faction_id"] = player_faction_id
	if resolved_city_id.is_empty() or target_faction_id.is_empty() or target_faction_id == player_faction_id:
		return context
	var relation_entry := _ensure_faction_relation_entry(player_faction_id, target_faction_id)
	var status := _normalize_faction_relation_status(str(relation_entry.get("status", FACTION_RELATION_STATUS["NEUTRAL"])))
	var score := clampi(int(relation_entry.get("score", DIPLOMACY_DEFAULT_SCORE)), DIPLOMACY_SCORE_MIN, DIPLOMACY_SCORE_MAX)
	var cost: Dictionary = definition.get("cost", {})
	var payment_check := _service.can_pay_diplomacy_resource_cost(self, cost)
	context["status"] = status
	context["score"] = score
	context["cooldown"] = _get_diplomacy_action_cooldown(target_faction_id)
	context["active_alliance_turns"] = maxi(0, int(relation_entry.get("alliance_turns_remaining", 0)))
	context["cost"] = cost
	context["payment_check"] = payment_check
	context["relation_delta"] = _get_modified_diplomacy_relation_delta_mvp(int(definition.get("relation_delta", 0)), action_id, target_faction_id)
	if action_id == DIPLOMACY_ACTION_ALLIANCE_PROPOSAL:
		var alliance_turns := maxi(1, int(definition.get("alliance_turns", DiplomacyActionServiceScript.ACTION_ALLIANCE_TURNS)))
		context["alliance_turns"] = alliance_turns
		context["acceptance_score"] = _calculate_alliance_acceptance_chance(target_faction_id, cost, alliance_turns)
	return context


func _validate_diplomacy_action(action_id: String, target_city_id: String = "") -> Dictionary:
	return DiplomacyActionServiceScript.validate_action(action_id, _build_diplomacy_action_validation_context(action_id, target_city_id))


func _calculate_alliance_acceptance_chance(target_faction_id: String, resource_package: Dictionary, duration_turns: int) -> int:
	return _service.calculate_alliance_acceptance_chance(self, target_faction_id, resource_package, duration_turns)


func _get_trade_agreement_bonus_multiplier(faction_a: String, faction_b: String) -> float:
	return _service.get_trade_agreement_bonus_multiplier(self, faction_a, faction_b)


func _get_active_trade_agreement_turns(target_faction_id: String) -> int:
	return _service.get_active_trade_agreement_turns(self, target_faction_id)


func _get_active_alliance_turns(target_faction_id: String) -> int:
	return _service.get_active_alliance_turns(self, target_faction_id)


func _advance_diplomacy_cooldowns_for_world_turn() -> Dictionary:
	if not _player_state.has("faction_relations") or not (_player_state["faction_relations"] is Dictionary):
		_player_state["faction_relations"] = {}
	var relations: Dictionary = _player_state["faction_relations"]
	var changed: Array = []
	for relation_key_variant in relations.keys():
		var relation_key := str(relation_key_variant)
		var entry_variant: Variant = relations.get(relation_key, {})
		if not entry_variant is Dictionary:
			continue
		var entry := (entry_variant as Dictionary).duplicate(true)
		var entry_changed := false
		var diplomacy_state_result := DiplomacyActionServiceScript.advance_diplomacy_state_entry(relation_key, entry)
		entry = diplomacy_state_result.get("entry", entry)
		var diplomacy_changes: Array = diplomacy_state_result.get("changed", [])
		if not diplomacy_changes.is_empty():
			entry_changed = true
			changed.append_array(diplomacy_changes)
		var alliance_state_result := DiplomacyActionServiceScript.advance_alliance_state_entry(relation_key, entry)
		entry = alliance_state_result.get("entry", entry)
		var alliance_changes: Array = alliance_state_result.get("changed", [])
		if not alliance_changes.is_empty():
			entry_changed = true
			changed.append_array(alliance_changes)
		if entry_changed:
			relations[relation_key] = entry
	_player_state["faction_relations"] = relations
	_sync_diplomacy_action_mirror_state_from_relations()
	var result := {
		"turn": maxi(1, int(_player_state.get("turn_number", 1))),
		"changed_count": changed.size(),
		"changed": changed,
	}
	_player_state["last_diplomacy_cooldown_result"] = result
	return result


func _get_known_faction_ids_for_diplomacy() -> Array:
	var known := {}
	known[_get_current_player_faction_id()] = true
	for city_id_variant in CITY_HUD_DATA.keys():
		var city_data: Dictionary = CITY_HUD_DATA.get(city_id_variant, {})
		var owner_id := _get_city_owner_faction_id(city_data)
		if not owner_id.is_empty():
			known[owner_id] = true
	var relations: Variant = _player_state.get("faction_relations", {})
	if relations is Dictionary:
		for relation_key_variant in (relations as Dictionary).keys():
			var parts := str(relation_key_variant).split("|")
			for part in parts:
				var faction_id := str(part)
				if not faction_id.is_empty():
					known[faction_id] = true
	var faction_ids: Array = known.keys()
	faction_ids.sort()
	return faction_ids


func _normalize_faction_relations_for_world_state() -> Dictionary:
	var faction_ids := _get_known_faction_ids_for_diplomacy()
	var ensured_count := 0
	var created_count := 0
	var patched_score_count := 0
	var patched_status_count := 0
	var patched_cooldown_count := 0
	var patched_tribute_cooldown_count := 0
	for i in range(faction_ids.size()):
		for j in range(i + 1, faction_ids.size()):
			var faction_a := str(faction_ids[i])
			var faction_b := str(faction_ids[j])
			var relation_key := _make_faction_relation_key(faction_a, faction_b)
			var relations_before: Dictionary = _player_state.get("faction_relations", {})
			var existed := relations_before.has(relation_key)
			var raw_entry: Variant = relations_before.get(relation_key, {})
			var had_score := raw_entry is Dictionary and (raw_entry as Dictionary).has("score")
			var had_status := raw_entry is Dictionary and (raw_entry as Dictionary).has("status")
			var had_cooldown := raw_entry is Dictionary and (raw_entry as Dictionary).has("cooldown")
			var had_tribute_cooldown := raw_entry is Dictionary and (raw_entry as Dictionary).has("tribute_cooldown")
			_ensure_faction_relation_entry(faction_a, faction_b)
			ensured_count += 1
			if not existed:
				created_count += 1
			elif not had_score:
				patched_score_count += 1
			if existed and not had_status:
				patched_status_count += 1
			if existed and not had_cooldown:
				patched_cooldown_count += 1
			if existed and not had_tribute_cooldown:
				patched_tribute_cooldown_count += 1
	var result := {
		"turn": maxi(1, int(_player_state.get("turn_number", 1))),
		"known_faction_count": faction_ids.size(),
		"ensured_count": ensured_count,
		"created_count": created_count,
		"patched_score_count": patched_score_count,
		"patched_status_count": patched_status_count,
		"patched_cooldown_count": patched_cooldown_count,
		"patched_tribute_cooldown_count": patched_tribute_cooldown_count,
	}
	_player_state["last_diplomacy_normalize_result"] = result
	return result


func _get_enemy_diplomacy_baseline_mvp(target_force_id: String = "") -> Dictionary:
	var result := {
		"target_force_id": target_force_id,
		"owner_scope": "enemy",
		"enemy_baseline": true,
		"enemy_research_effect": false,
		"player_completed_tech_lookup": false,
		"masked": true,
		"diplomacy_resistance_pct": 0.0,
		"alliance_resistance_pct": 0.0,
		"tribute_resistance_pct": 0.0,
		"relation_resistance_pct": 0.0,
		"baseline_grade_label": "정보 부족",
		"source": "faction_city_grade_baseline",
	}
	if target_force_id.is_empty() or target_force_id == _get_current_player_faction_id():
		result["reason"] = "invalid_target"
		return result
	result["masked"] = false
	var owned_city_count := _get_enemy_owned_city_count_mvp(target_force_id)
	var resistance_pct := 0.03
	if owned_city_count >= 4:
		resistance_pct += 0.03
	elif owned_city_count >= 2:
		resistance_pct += 0.01
	var relation_score := _get_faction_relation_score(_get_current_player_faction_id(), target_force_id)
	if relation_score >= 70:
		resistance_pct += 0.02
	elif relation_score <= 30:
		resistance_pct = maxf(0.0, resistance_pct - 0.01)
	var trade_turns := _get_active_trade_agreement_turns(target_force_id)
	var alliance_turns := _get_active_alliance_turns(target_force_id)
	var alliance_resistance := resistance_pct + (0.03 if alliance_turns > 0 else 0.0)
	var tribute_resistance := resistance_pct + (0.02 if trade_turns > 0 else 0.0)
	result["diplomacy_resistance_pct"] = minf(0.10, resistance_pct)
	result["alliance_resistance_pct"] = minf(0.12, alliance_resistance)
	result["tribute_resistance_pct"] = minf(0.10, tribute_resistance)
	result["relation_resistance_pct"] = minf(0.08, resistance_pct)
	var grade_score := owned_city_count + (1 if alliance_turns > 0 else 0) + (1 if trade_turns > 0 else 0)
	result["baseline_grade_label"] = _format_enemy_city_baseline_grade_label_mvp(grade_score)
	return result


func _get_empty_domestic_diplomacy_modifier_mvp() -> Dictionary:
	return {
		"diplomacy_success_pct": 0.0,
		"relation_gain_pct": 0.0,
		"relation_loss_reduction_pct": 0.0,
		"alliance_success_pct": 0.0,
		"tribute_success_pct": 0.0,
		"envoy_effect_pct": 0.0,
		"corruption_reduction_pct": 0.0,
		"admin_diplomacy_pct": 0.0,
		"source_techs": [],
	}


func _get_player_diplomacy_tech_modifier_mvp() -> Dictionary:
	var modifier := _get_empty_domestic_diplomacy_modifier_mvp()
	var bonus := _get_domestic_tech_diplomacy_spy_bonus_mvp()
	modifier["diplomacy_success_pct"] = float(modifier.get("diplomacy_success_pct", 0.0)) + float(bonus.get("diplomacy_preparation_percent", 0.0))
	modifier["tribute_success_pct"] = float(modifier.get("tribute_success_pct", 0.0)) + float(bonus.get("tribute_readiness_percent", 0.0))
	modifier["envoy_effect_pct"] = float(modifier.get("envoy_effect_pct", 0.0)) + minf(0.08, float(int(bonus.get("diplomacy_influence_flat", 0))) * 0.005)
	modifier["relation_gain_pct"] = float(modifier.get("relation_gain_pct", 0.0)) + minf(0.06, float(int(bonus.get("diplomacy_influence_flat", 0))) * 0.004)
	modifier["alliance_success_pct"] = float(modifier.get("alliance_success_pct", 0.0)) + minf(0.10, float(bonus.get("world_diplomacy_display_percent", 0.0)))
	modifier["diplomacy_success_pct"] = float(modifier.get("diplomacy_success_pct", 0.0)) + minf(0.04, float(bonus.get("world_diplomacy_display_percent", 0.0)) * 0.5)
	modifier["admin_diplomacy_pct"] = float(modifier.get("admin_diplomacy_pct", 0.0)) + minf(0.05, float(bonus.get("diplomacy_preparation_percent", 0.0)))
	modifier["source_techs"] = _get_unique_domestic_tech_source_ids_mvp(bonus.get("source_techs", []))
	if _has_completed_national_domestic_tech_mvp("nation_alliance_system"):
		modifier["alliance_success_pct"] = float(modifier.get("alliance_success_pct", 0.0)) + 0.08
		_append_domestic_modifier_source_if_completed_mvp(modifier, "nation_alliance_system")
	if _has_completed_national_domestic_tech_mvp("nation_law_reform"):
		modifier["relation_loss_reduction_pct"] = float(modifier.get("relation_loss_reduction_pct", 0.0)) + 0.03
		_append_domestic_modifier_source_if_completed_mvp(modifier, "nation_law_reform")
	if _has_completed_national_domestic_tech_mvp("nation_bureaucracy"):
		modifier["admin_diplomacy_pct"] = float(modifier.get("admin_diplomacy_pct", 0.0)) + 0.03
		_append_domestic_modifier_source_if_completed_mvp(modifier, "nation_bureaucracy")
	if _has_completed_national_domestic_tech_mvp("nation_centralization"):
		modifier["admin_diplomacy_pct"] = float(modifier.get("admin_diplomacy_pct", 0.0)) + 0.05
		modifier["diplomacy_success_pct"] = float(modifier.get("diplomacy_success_pct", 0.0)) + 0.02
		_append_domestic_modifier_source_if_completed_mvp(modifier, "nation_centralization")
	if _has_completed_national_domestic_tech_mvp("nation_anti_corruption"):
		modifier["corruption_reduction_pct"] = float(modifier.get("corruption_reduction_pct", 0.0)) + 0.05
		modifier["relation_loss_reduction_pct"] = float(modifier.get("relation_loss_reduction_pct", 0.0)) + 0.03
		_append_domestic_modifier_source_if_completed_mvp(modifier, "nation_anti_corruption")
	modifier["source_techs"] = _get_unique_domestic_tech_source_ids_mvp(modifier.get("source_techs", []))
	return modifier


func _has_domestic_diplomacy_modifier_data_mvp(modifier: Dictionary) -> bool:
	return not is_equal_approx(float(modifier.get("diplomacy_success_pct", 0.0)), 0.0) \
		or not is_equal_approx(float(modifier.get("relation_gain_pct", 0.0)), 0.0) \
		or not is_equal_approx(float(modifier.get("relation_loss_reduction_pct", 0.0)), 0.0) \
		or not is_equal_approx(float(modifier.get("alliance_success_pct", 0.0)), 0.0) \
		or not is_equal_approx(float(modifier.get("tribute_success_pct", 0.0)), 0.0) \
		or not is_equal_approx(float(modifier.get("envoy_effect_pct", 0.0)), 0.0) \
		or not is_equal_approx(float(modifier.get("corruption_reduction_pct", 0.0)), 0.0) \
		or not is_equal_approx(float(modifier.get("admin_diplomacy_pct", 0.0)), 0.0)


func _get_modified_diplomacy_relation_delta_mvp(base_delta: int, action_id: String, target_faction_id: String = "") -> int:
	if base_delta == 0:
		return 0
	var modifier := _get_player_diplomacy_tech_modifier_mvp()
	var multiplier := 1.0 + float(modifier.get("relation_gain_pct", 0.0))
	if action_id == DIPLOMACY_ACTION_ENVOY:
		multiplier += float(modifier.get("envoy_effect_pct", 0.0))
	elif action_id == DIPLOMACY_ACTION_TRIBUTE:
		multiplier += float(modifier.get("tribute_success_pct", 0.0))
	var enemy_baseline := _get_enemy_diplomacy_baseline_mvp(target_faction_id)
	if not bool(enemy_baseline.get("masked", true)):
		multiplier -= float(enemy_baseline.get("relation_resistance_pct", 0.0))
	var modified_delta := int(round(float(base_delta) * maxf(0.5, multiplier)))
	if modified_delta == 0:
		return base_delta
	return modified_delta


func _get_modified_diplomacy_success_chance_mvp(base_chance: int, action_id: String, target_faction_id: String = "") -> int:
	var modifier := _get_player_diplomacy_tech_modifier_mvp()
	var bonus_pct := float(modifier.get("diplomacy_success_pct", 0.0))
	if action_id == DIPLOMACY_ACTION_ALLIANCE_PROPOSAL:
		bonus_pct += float(modifier.get("alliance_success_pct", 0.0))
	elif action_id == DIPLOMACY_ACTION_TRIBUTE:
		bonus_pct += float(modifier.get("tribute_success_pct", 0.0))
	var enemy_baseline := _get_enemy_diplomacy_baseline_mvp(target_faction_id)
	if not bool(enemy_baseline.get("masked", true)):
		if action_id == DIPLOMACY_ACTION_ALLIANCE_PROPOSAL:
			bonus_pct -= float(enemy_baseline.get("alliance_resistance_pct", 0.0))
		elif action_id == DIPLOMACY_ACTION_TRIBUTE:
			bonus_pct -= float(enemy_baseline.get("tribute_resistance_pct", 0.0))
		else:
			bonus_pct -= float(enemy_baseline.get("diplomacy_resistance_pct", 0.0))
	return clampi(base_chance + int(round(bonus_pct * 100.0)), 0, 95)


# Explicit bridges into generic worldmap/city/technology storage.
func _get_city_owner_faction_id_for_trade_display(city_id: String) -> String:
	return _host.call("_get_city_owner_faction_id_for_trade_display", city_id)


func _get_current_player_faction_id() -> String:
	return _host.call("_get_current_player_faction_id")


func _get_city_owner_faction_id(city_data: Dictionary) -> String:
	return _host.call("_get_city_owner_faction_id", city_data)


func _get_enemy_owned_city_count_mvp(faction_id: String) -> int:
	return _host.call("_get_enemy_owned_city_count_mvp", faction_id)


func _format_enemy_city_baseline_grade_label_mvp(score: int) -> String:
	return _host.call("_format_enemy_city_baseline_grade_label_mvp", score)


func _get_domestic_tech_diplomacy_spy_bonus_mvp() -> Dictionary:
	return _host.call("_get_domestic_tech_diplomacy_spy_bonus_mvp")


func _get_unique_domestic_tech_source_ids_mvp(source_techs: Variant) -> Array[String]:
	return _host.call("_get_unique_domestic_tech_source_ids_mvp", source_techs)


func _has_completed_national_domestic_tech_mvp(tech_id: String) -> bool:
	return _host.call("_has_completed_national_domestic_tech_mvp", tech_id)


func _append_domestic_modifier_source_if_completed_mvp(modifier: Dictionary, tech_id: String) -> void:
	_host.call("_append_domestic_modifier_source_if_completed_mvp", modifier, tech_id)


func _get_total_recruitment_food_stock() -> int:
	return _host.call("_get_total_recruitment_food_stock")
