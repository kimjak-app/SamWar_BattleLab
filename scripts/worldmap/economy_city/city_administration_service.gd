class_name WorldMapCityAdministrationService
extends RefCounted


const GOVERNOR_PRIMARY_RATE := 0.025
const GOVERNOR_SECONDARY_RATE := 0.0125

const GOVERNOR_POLICY_DATA := {
	"follow_chancellor": {
		"name": "균형 운영",
		"description": "효과: 국가 운영 방향을 따른 도시 보정",
	},
	"agriculture": {
		"name": "농업 중심",
		"description": "효과: 농업 산출 강화",
	},
	"commerce": {
		"name": "상업 중심",
		"description": "효과: 상업 수입 강화",
	},
	"military": {
		"name": "군사 중심",
		"description": "효과: 병력 운영 보정",
	},
}


func get_governor_policy_entry(policy_id: String) -> Dictionary:
	return (GOVERNOR_POLICY_DATA.get(policy_id, GOVERNOR_POLICY_DATA["follow_chancellor"]) as Dictionary).duplicate(true)


func get_city_policy_id(city_id: String, city_data: Dictionary, city_policy_snapshot: Dictionary) -> String:
	return str(city_policy_snapshot.get(city_id, city_data.get("governor_policy_id", "follow_chancellor")))


func validate_governor_assignment(city_id: String, governor_id: String, city_snapshot: Dictionary, hero_snapshot: Dictionary = {}) -> Dictionary:
	var normalized_city_id := city_id.strip_edges()
	var normalized_governor_id := governor_id.strip_edges()
	var result := {
		"ok": false,
		"city_id": normalized_city_id,
		"governor_id": normalized_governor_id,
		"previous_governor_id": str(city_snapshot.get("governor_id", city_snapshot.get("governorHeroId", ""))),
		"error_code": "",
	}
	if normalized_city_id.is_empty() or city_snapshot.is_empty():
		result["error_code"] = "invalid_city"
		return result
	if normalized_governor_id.is_empty():
		result["ok"] = true
		return result
	var stationed_hero_ids := _normalize_id_array(city_snapshot.get("stationed_hero_ids", city_snapshot.get("hero_ids", [])))
	if not stationed_hero_ids.has(normalized_governor_id):
		result["error_code"] = "hero_not_stationed"
		return result
	if hero_snapshot.is_empty():
		result["error_code"] = "invalid_hero"
		return result
	result["ok"] = true
	return result


func apply_governor_assignment(city_snapshot: Dictionary, assignment_result: Dictionary) -> Dictionary:
	var updated := city_snapshot.duplicate(true)
	if bool(assignment_result.get("ok", false)):
		updated["governor_id"] = str(assignment_result.get("governor_id", ""))
	return updated


func calculate_city_domestic_effects(
	city_data: Dictionary,
	governor_data: Dictionary,
	chancellor_data: Dictionary,
	player_faction_id: String,
	governor_policy_id: String,
	chancellor_policy_id: String,
	chancellor_primary_rate: float,
	chancellor_secondary_rate: float
) -> Dictionary:
	var effect := _empty_city_domestic_effect()
	var city_id := str(city_data.get("id", ""))
	var governor_is_valid := (
		not governor_data.is_empty()
		and str(governor_data.get("side", "")) == player_faction_id
		and str(governor_data.get("location_city_id", governor_data.get("city_id", ""))) == city_id
	)
	if governor_is_valid:
		apply_governor_type_effect(effect, str(governor_data.get("chancellor_primary_type", "")), float(governor_data.get("chancellor_primary_aptitude", 0)), GOVERNOR_PRIMARY_RATE)
		apply_governor_type_effect(effect, str(governor_data.get("chancellor_secondary_type", "")), float(governor_data.get("chancellor_secondary_aptitude", 0)), GOVERNOR_SECONDARY_RATE)
	elif not chancellor_data.is_empty() and str(chancellor_data.get("side", "")) == player_faction_id:
		_apply_chancellor_loyalty_fallback(effect, chancellor_data, chancellor_primary_rate, chancellor_secondary_rate)
	apply_governor_policy_effect(effect, governor_policy_id, chancellor_policy_id)
	return effect


func apply_governor_type_effect(effect: Dictionary, type_id: String, aptitude: float, rate: float) -> void:
	var strength := maxf(0.0, aptitude) * rate
	if type_id.is_empty() or strength <= 0.0:
		return
	match type_id:
		"political":
			effect["city_loyalty_loss_multiplier"] = clampf(float(effect.get("city_loyalty_loss_multiplier", 1.0)) * (1.0 - strength), 0.72, 1.0)
		"economic":
			effect["gold_multiplier"] = clampf(float(effect.get("gold_multiplier", 1.0)) * (1.0 + strength), 1.0, 1.22)
		"administrative":
			effect["rice_multiplier"] = clampf(float(effect.get("rice_multiplier", 1.0)) * (1.0 + (strength * 0.45)), 1.0, 1.14)
			effect["barley_multiplier"] = clampf(float(effect.get("barley_multiplier", 1.0)) * (1.0 + (strength * 0.45)), 1.0, 1.14)
			effect["seafood_multiplier"] = clampf(float(effect.get("seafood_multiplier", 1.0)) * (1.0 + (strength * 0.3)), 1.0, 1.1)
		"diplomatic":
			effect["gold_multiplier"] = clampf(float(effect.get("gold_multiplier", 1.0)) * (1.0 + (strength * 0.55)), 1.0, 1.12)
		"militaryAdmin":
			effect["recruitable_troops_bonus"] = int(effect.get("recruitable_troops_bonus", 0)) + int(round(maxf(0.0, aptitude) * 12.0))


func apply_governor_policy_effect(effect: Dictionary, governor_policy_id: String, chancellor_policy_id: String) -> void:
	match governor_policy_id:
		"agriculture":
			effect["rice_multiplier"] = clampf(float(effect.get("rice_multiplier", 1.0)) * 1.08, 0.75, 1.35)
			effect["barley_multiplier"] = clampf(float(effect.get("barley_multiplier", 1.0)) * 1.08, 0.75, 1.35)
			effect["gold_multiplier"] = clampf(float(effect.get("gold_multiplier", 1.0)) * 0.97, 0.75, 1.4)
		"commerce":
			effect["gold_multiplier"] = clampf(float(effect.get("gold_multiplier", 1.0)) * 1.08, 0.75, 1.4)
			effect["rice_multiplier"] = clampf(float(effect.get("rice_multiplier", 1.0)) * 0.97, 0.75, 1.35)
			effect["barley_multiplier"] = clampf(float(effect.get("barley_multiplier", 1.0)) * 0.97, 0.75, 1.35)
		"military":
			effect["gold_multiplier"] = clampf(float(effect.get("gold_multiplier", 1.0)) * 0.97, 0.75, 1.4)
			effect["recruitable_troops_bonus"] = int(effect.get("recruitable_troops_bonus", 0)) + 40
		"follow_chancellor":
			if chancellor_policy_id == "agriculture":
				effect["rice_multiplier"] = clampf(float(effect.get("rice_multiplier", 1.0)) * 1.03, 0.75, 1.35)
				effect["barley_multiplier"] = clampf(float(effect.get("barley_multiplier", 1.0)) * 1.03, 0.75, 1.35)
			elif chancellor_policy_id == "commerce" or chancellor_policy_id == "trade":
				effect["gold_multiplier"] = clampf(float(effect.get("gold_multiplier", 1.0)) * 1.03, 0.75, 1.4)
			elif chancellor_policy_id == "military":
				effect["recruitable_troops_bonus"] = int(effect.get("recruitable_troops_bonus", 0)) + 20


func _empty_city_domestic_effect() -> Dictionary:
	return {
		"rice_multiplier": 1.0,
		"barley_multiplier": 1.0,
		"seafood_multiplier": 1.0,
		"gold_multiplier": 1.0,
		"hero_upkeep_multiplier": 1.0,
		"soldier_upkeep_preview_multiplier": 1.0,
		"salt_preservation_multiplier": 1.0,
		"national_loyalty_loss_multiplier": 1.0,
		"city_loyalty_loss_multiplier": 1.0,
		"recruitable_troops_bonus": 0,
	}


func _apply_chancellor_loyalty_fallback(effect: Dictionary, chancellor_data: Dictionary, primary_rate: float, secondary_rate: float) -> void:
	var primary_strength := maxf(0.0, float(chancellor_data.get("chancellor_primary_aptitude", 0))) * primary_rate
	var secondary_strength := maxf(0.0, float(chancellor_data.get("chancellor_secondary_aptitude", 0))) * secondary_rate
	if str(chancellor_data.get("chancellor_primary_type", "")) == "political" and primary_strength > 0.0:
		effect["city_loyalty_loss_multiplier"] = clampf(float(effect.get("city_loyalty_loss_multiplier", 1.0)) * (1.0 - (primary_strength * 0.4)), 0.85, 1.0)
	if str(chancellor_data.get("chancellor_secondary_type", "")) == "political" and secondary_strength > 0.0:
		effect["city_loyalty_loss_multiplier"] = clampf(float(effect.get("city_loyalty_loss_multiplier", 1.0)) * (1.0 - (secondary_strength * 0.4)), 0.85, 1.0)


func _normalize_id_array(raw_ids: Variant) -> Array[String]:
	var normalized: Array[String] = []
	if not raw_ids is Array:
		return normalized
	for raw_id in raw_ids:
		var item_id := str(raw_id).strip_edges()
		if not item_id.is_empty() and not normalized.has(item_id):
			normalized.append(item_id)
	return normalized
