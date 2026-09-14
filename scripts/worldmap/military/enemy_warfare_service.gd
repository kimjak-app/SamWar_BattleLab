class_name WorldMapEnemyWarfareService
extends RefCounted

const ExpeditionSupplyCalculatorScript := preload("res://scripts/t02/expedition_supply_calculator.gd")

var _query: Callable
var _personality_seeds: Dictionary = {}
var _goal_seeds: Dictionary = {}
var _config: Dictionary = {}


func configure(query: Callable, personality_seeds: Dictionary, goal_seeds: Dictionary, config: Dictionary) -> void:
	_query = query
	_personality_seeds = personality_seeds.duplicate(true)
	_goal_seeds = goal_seeds.duplicate(true)
	_config = config.duplicate(true)


func get_personality_seed(faction_id: String) -> Dictionary:
	var default_seed := _dictionary(_personality_seeds.get("default", {})).duplicate(true)
	if faction_id.is_empty() or faction_id == _player_faction():
		return default_seed
	var faction_seed := _dictionary(_personality_seeds.get(faction_id, default_seed))
	for key in faction_seed:
		default_seed[key] = faction_seed[key]
	return default_seed


func get_personality_profile_id(faction_id: String) -> String:
	return str(get_personality_seed(faction_id).get("profile", "default_balanced"))


func get_personality_label(faction_id: String) -> String:
	return str(get_personality_seed(faction_id).get("label", "균형"))


func get_behavior_weight(faction_id: String, key: String, default_value: float = 1.0) -> float:
	return clampf(float(get_personality_seed(faction_id).get(key, default_value)), 0.75, 1.25)


func get_personality_metadata(faction_id: String) -> Dictionary:
	if faction_id.is_empty() or faction_id == _player_faction():
		return {}
	return {"personality_profile": get_personality_profile_id(faction_id), "personality_label": get_personality_label(faction_id)}


func get_goal_seed(faction_id: String) -> Dictionary:
	var default_seed := _dictionary(_goal_seeds.get("default", {})).duplicate(true)
	if faction_id.is_empty() or faction_id == _player_faction():
		return default_seed
	var faction_seed := _dictionary(_goal_seeds.get(faction_id, default_seed))
	for key in faction_seed:
		default_seed[key] = faction_seed[key]
	return default_seed


func get_goal_id(faction_id: String) -> String:
	return str(get_goal_seed(faction_id).get("goal_id", "hold_position"))


func get_goal_label(faction_id: String) -> String:
	return str(get_goal_seed(faction_id).get("label", "전선 유지"))


func get_goal_pressure(faction_id: String) -> String:
	return str(get_goal_seed(faction_id).get("pressure", "balanced"))


func get_goal_weight(faction_id: String) -> float:
	return clampf(float(get_goal_seed(faction_id).get("weight", 1.0)), 1.0, 1.15)


func get_goal_target_city_ids(faction_id: String) -> Array[String]:
	var result: Array[String] = []
	if faction_id.is_empty() or faction_id == _player_faction():
		return result
	var raw_ids: Variant = get_goal_seed(faction_id).get("target_city_ids", [])
	if not raw_ids is Array:
		return result
	for raw_id in raw_ids:
		var city_id := str(raw_id)
		if not city_id.is_empty() and _has_city(city_id) and not result.has(city_id):
			result.append(city_id)
	return result


func is_city_preferred_by_goal(faction_id: String, city_id: String) -> bool:
	return not faction_id.is_empty() and faction_id != _player_faction() and not city_id.is_empty() and get_goal_target_city_ids(faction_id).has(city_id)


func is_city_adjacent_to_goal_target(faction_id: String, city_id: String) -> bool:
	if faction_id.is_empty() or faction_id == _player_faction() or city_id.is_empty():
		return false
	for target_city_id in get_goal_target_city_ids(faction_id):
		if target_city_id != city_id and (_neighbors(city_id).has(target_city_id) or _neighbors(target_city_id).has(city_id)):
			return true
	return false


func get_goal_metadata(faction_id: String) -> Dictionary:
	if faction_id.is_empty() or faction_id == _player_faction():
		return {}
	return {"goal_id": get_goal_id(faction_id), "goal_label": get_goal_label(faction_id), "goal_pressure": get_goal_pressure(faction_id)}


func normalize_pressure_type(raw_pressure_type: String, faction_id: String = "") -> String:
	var pressure_type := raw_pressure_type.strip_edges()
	match pressure_type:
		"military", "invasion", "diplomacy", "spy", "defensive", "balanced": return pressure_type
		"aggressive": return "military"
		"trade_defensive": return "defensive"
	if not faction_id.is_empty() and faction_id != _player_faction():
		var profile_id := get_personality_profile_id(faction_id)
		if profile_id.find("spy") >= 0 or profile_id.find("scheme") >= 0: return "spy"
		if profile_id.find("diplomacy") >= 0: return "diplomacy"
		if profile_id.find("defensive") >= 0: return "defensive"
		if profile_id.find("aggressive") >= 0 or profile_id.find("military") >= 0: return "military"
	return "balanced"


func should_skip_pressure_plan() -> bool:
	if bool(_q("has_pending_warfare")):
		return true
	var turn := int(_q("turn_number"))
	if turn <= 0:
		return true
	var plan := normalize_pressure_plan(_q("last_pressure_plan"))
	return not plan.is_empty() and int(plan.get("turn_number", 0)) == turn


func build_pressure_plan_candidates() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for faction_id in _string_array(_q("enemy_faction_ids")):
		var candidate := build_pressure_plan_candidate(faction_id)
		if not candidate.is_empty(): result.append(candidate)
	result.sort_custom(Callable(self, "sort_pressure_plan_candidates"))
	return result


func build_pressure_plan_candidate(faction_id: String) -> Dictionary:
	if faction_id.is_empty() or faction_id == _player_faction(): return {}
	var pressure_type := normalize_pressure_type(get_goal_pressure(faction_id), faction_id)
	var best: Dictionary = {}
	var best_score := -INF
	for source_id in _owned_cities(faction_id):
		if _owner(source_id) != faction_id or not _has_city(source_id): continue
		for target_id in get_pressure_targets(faction_id, source_id, pressure_type):
			var candidate := {"faction_id": faction_id, "source_city_id": source_id, "target_city_id": target_id, "pressure_type": pressure_type, "goal_id": get_goal_id(faction_id), "goal_label": get_goal_label(faction_id), "personality_profile": get_personality_profile_id(faction_id)}
			var score := score_pressure_plan_candidate(candidate)
			if best.is_empty() or score > best_score:
				candidate["score"] = score
				best = candidate
				best_score = score
	return best


func get_pressure_targets(faction_id: String, source_id: String, pressure_type: String) -> Array[String]:
	var result: Array[String] = []
	for neighbor_id in _neighbors(source_id):
		if _has_city(neighbor_id) and bool(_q("is_player_owned", [neighbor_id])): result.append(neighbor_id)
	for target_id in get_goal_target_city_ids(faction_id):
		if source_id == target_id or _neighbors(source_id).has(target_id) or _neighbors(target_id).has(source_id):
			if not result.has(target_id): result.append(target_id)
	if result.is_empty() and (pressure_type == "defensive" or pressure_type == "balanced"):
		result.append(source_id)
	return result


func score_pressure_plan_candidate(candidate: Dictionary) -> float:
	var faction_id := str(candidate.get("faction_id", ""))
	var source_id := str(candidate.get("source_city_id", ""))
	var target_id := str(candidate.get("target_city_id", ""))
	if faction_id.is_empty() or faction_id == _player_faction() or source_id.is_empty() or target_id.is_empty() or _owner(source_id) != faction_id: return -INF
	var pressure_type := normalize_pressure_type(str(candidate.get("pressure_type", "")), faction_id)
	var score := 100.0 + float(mini(_troops(source_id), 2000)) / 80.0
	if is_enemy_frontline_city(source_id, faction_id): score += 16.0
	if is_city_preferred_by_goal(faction_id, target_id): score += 18.0 * get_goal_weight(faction_id)
	elif is_city_adjacent_to_goal_target(faction_id, target_id): score += 8.0 * get_goal_weight(faction_id)
	if pressure_type == "invasion" or pressure_type == "military": score *= get_behavior_weight(faction_id, "invasion_weight")
	elif pressure_type == "spy": score *= get_behavior_weight(faction_id, "spy_weight")
	elif pressure_type == "diplomacy": score *= get_behavior_weight(faction_id, "diplomacy_weight")
	else: score *= get_behavior_weight(faction_id, "reinforce_weight")
	return score


func sort_pressure_plan_candidates(left: Dictionary, right: Dictionary) -> bool:
	var ls := float(left.get("score", 0.0)); var rs := float(right.get("score", 0.0))
	if not is_equal_approx(ls, rs): return ls > rs
	return "%s:%s:%s" % [left.get("faction_id", ""), left.get("source_city_id", ""), left.get("target_city_id", "")] < "%s:%s:%s" % [right.get("faction_id", ""), right.get("source_city_id", ""), right.get("target_city_id", "")]


func pick_pressure_plan() -> Dictionary:
	if should_skip_pressure_plan() or bool(_q("manual_invasion_grace")): return {}
	var candidates := build_pressure_plan_candidates()
	if candidates.is_empty(): return {}
	var selected := candidates[0]
	return normalize_pressure_plan({"type": "enemy_pressure_plan", "turn_number": maxi(1, int(_q("turn_number"))), "faction_id": str(selected.get("faction_id", "")), "faction_label": str(_q("faction_label", [selected.get("faction_id", "")])), "personality_profile": selected.get("personality_profile", ""), "goal_id": selected.get("goal_id", ""), "goal_label": selected.get("goal_label", ""), "pressure_type": selected.get("pressure_type", ""), "target_city_id": selected.get("target_city_id", ""), "target_city_label": str(_q("city_label", [selected.get("target_city_id", "")])), "source_city_id": selected.get("source_city_id", ""), "source_city_label": str(_q("city_label", [selected.get("source_city_id", "")])), "effect": "display_scoring_only"})


func normalize_pressure_plan(raw: Variant) -> Dictionary:
	if not raw is Dictionary: return {}
	var result := (raw as Dictionary).duplicate(true)
	if str(result.get("type", "")) != "enemy_pressure_plan": return {}
	var faction_id := str(result.get("faction_id", "")); var source_id := str(result.get("source_city_id", "")); var target_id := str(result.get("target_city_id", ""))
	if faction_id.is_empty() or faction_id == _player_faction() or source_id.is_empty() or target_id.is_empty() or _owner(source_id) != faction_id: return {}
	result["turn_number"] = maxi(0, int(result.get("turn_number", 0)))
	result["faction_label"] = str(result.get("faction_label", _q("faction_label", [faction_id])))
	result["personality_profile"] = str(result.get("personality_profile", get_personality_profile_id(faction_id)))
	result["goal_id"] = str(result.get("goal_id", get_goal_id(faction_id)))
	result["goal_label"] = str(result.get("goal_label", get_goal_label(faction_id)))
	result["pressure_type"] = normalize_pressure_type(str(result.get("pressure_type", get_goal_pressure(faction_id))), faction_id)
	result["target_city_label"] = str(result.get("target_city_label", _q("city_label", [target_id])))
	result["source_city_label"] = str(result.get("source_city_label", _q("city_label", [source_id])))
	result["effect"] = "display_scoring_only"
	return result


func get_pressure_plan_for_scoring() -> Dictionary:
	var plan := normalize_pressure_plan(_q("last_pressure_plan"))
	return plan if not plan.is_empty() and int(plan.get("turn_number", 0)) == maxi(1, int(_q("turn_number"))) else {}


func is_pressure_plan_target_city(faction_id: String, city_id: String) -> bool:
	var plan := get_pressure_plan_for_scoring()
	return not plan.is_empty() and not faction_id.is_empty() and not city_id.is_empty() and str(plan.get("faction_id", "")) == faction_id and str(plan.get("target_city_id", "")) == city_id


func get_pressure_plan_score_bonus(faction_id: String, city_id: String, purpose: String) -> float:
	var plan := get_pressure_plan_for_scoring()
	if plan.is_empty() or faction_id.is_empty() or str(plan.get("faction_id", "")) != faction_id: return 0.0
	var pressure := normalize_pressure_type(str(plan.get("pressure_type", "")), faction_id)
	var target := str(plan.get("target_city_id", "")); var source := str(plan.get("source_city_id", ""))
	if source.is_empty() or target.is_empty() or not _has_city(source) or not _has_city(target) or (not city_id.is_empty() and not _has_city(city_id)): return 0.0
	var bonus := 0.0
	if city_id == target: bonus += 20.0
	elif city_id == source: bonus += 10.0
	elif not city_id.is_empty() and (_neighbors(city_id).has(target) or _neighbors(target).has(city_id)): bonus += 6.0
	if purpose == "reinforcement" and pressure == "defensive": bonus += 8.0
	elif purpose == "strategic_diplomacy" and pressure == "diplomacy": bonus += 6.0
	elif purpose == "strategic_spy" and pressure == "spy": bonus += 6.0
	elif purpose == "invasion" and (pressure == "invasion" or pressure == "military"): bonus += 10.0
	var maximum := 24.0 if purpose == "reinforcement" or purpose == "invasion" else (18.0 if purpose == "strategic_diplomacy" or purpose == "strategic_spy" else 20.0)
	return clampf(bonus, 0.0, maximum)


func is_enemy_frontline_city(city_id: String, faction_id: String) -> bool:
	if city_id.is_empty() or faction_id.is_empty() or _owner(city_id) != faction_id: return false
	for neighbor_id in _neighbors(city_id):
		if bool(_q("is_player_owned", [neighbor_id])): return true
	return false


func find_enemy_frontline_city(faction_id: String) -> String:
	var selected := ""; var selected_troops := INF
	for city_id in _owned_cities(faction_id):
		var count := float(_troops(city_id))
		if is_enemy_frontline_city(city_id, faction_id) and (selected.is_empty() or count < selected_troops): selected = city_id; selected_troops = count
	return selected


func pick_enemy_city_for_turn_action(faction_id: String) -> String:
	var city_ids := _owned_cities(faction_id)
	if city_ids.is_empty(): return ""
	var selected := city_ids[0]; var selected_score := score_reinforcement_city(faction_id, selected)
	for city_id in city_ids:
		var score := score_reinforcement_city(faction_id, city_id)
		if score > selected_score: selected = city_id; selected_score = score
	return selected


func score_reinforcement_city(faction_id: String, city_id: String) -> int:
	if faction_id.is_empty() or faction_id == _player_faction() or city_id.is_empty() or _owner(city_id) != faction_id: return -1
	var troops := _troops(city_id); var goal_weight := get_goal_weight(faction_id); var pressure := get_goal_pressure(faction_id)
	var score := int(round(float(clampi(3000 - troops, 0, 3000)) * get_behavior_weight(faction_id, "reinforce_weight")))
	if is_enemy_frontline_city(city_id, faction_id):
		score += int(round(450.0 * get_behavior_weight(faction_id, "frontline_weight")))
		if pressure == "military" or pressure == "invasion" or pressure == "aggressive": score += int(round(80.0 * goal_weight))
	if is_city_preferred_by_goal(faction_id, city_id): score += int(round(120.0 * goal_weight))
	elif is_city_adjacent_to_goal_target(faction_id, city_id): score += int(round(55.0 * goal_weight))
	if pressure == "defensive" or pressure == "trade_defensive": score += int(round(float(clampi(1800 - troops, 0, 1800)) * 0.03 * goal_weight))
	return score + int(round(get_pressure_plan_score_bonus(faction_id, city_id, "reinforcement")))


func get_invasion_pairs() -> Array[Dictionary]:
	var pairs: Array[Dictionary] = []
	var korea_ids := _string_array(_config.get("korea_city_ids", []))
	for attacker_id in korea_ids:
		for defender_id in _neighbors(attacker_id):
			if korea_ids.has(defender_id) and is_invasion_pair_eligible(attacker_id, defender_id): pairs.append({"attacker_city_id": attacker_id, "defender_city_id": defender_id, "score": score_invasion_pair(attacker_id, defender_id)})
	pairs.sort_custom(Callable(self, "sort_invasion_pairs"))
	return pairs


func is_city_owner_consistent(city_id: String) -> bool:
	var owners := _dictionary(_q("city_owner_sources", [city_id])); var marker := str(owners.get("marker", "")); var runtime := str(owners.get("runtime", ""))
	if marker.is_empty() or runtime.is_empty(): return not marker.is_empty() or not runtime.is_empty()
	return marker == runtime


func is_invasion_pair_eligible(attacker_id: String, defender_id: String) -> bool:
	var korea_ids := _string_array(_config.get("korea_city_ids", []))
	if attacker_id.is_empty() or defender_id.is_empty() or attacker_id == defender_id or not korea_ids.has(attacker_id) or not korea_ids.has(defender_id): return false
	if not _has_city(attacker_id) or not _has_city(defender_id) or not is_city_owner_consistent(attacker_id) or not is_city_owner_consistent(defender_id): return false
	var attacker_owner := str(_q("city_owner", [attacker_id])); var defender_owner := str(_q("city_owner", [defender_id]))
	if attacker_owner.is_empty() or defender_owner.is_empty() or attacker_owner == defender_owner or attacker_owner == _player_faction(): return false
	if bool(_q("faction_defeated", [attacker_owner])) or bool(_q("faction_defeated", [defender_owner])) or not _neighbors(attacker_id).has(defender_id): return false
	var attacker_troops := get_city_troops_for_invasion(attacker_id)
	if attacker_troops < int(_config.get("minimum_attacker_troops", 160)): return false
	var attacker_heroes := _string_array(_q("eligible_hero_ids", [attacker_id])); var defender_heroes := _string_array(_q("eligible_hero_ids", [defender_id]))
	if attacker_heroes.is_empty() or defender_heroes.is_empty(): return false
	var maximum := maxi(0, attacker_troops - int(_config.get("minimum_source_troops", 1)))
	var deployable := int(_q("deployable_troops", [attacker_id, attacker_heroes, maximum]))
	if deployable <= 0: return false
	return int(_q("city_resource", [attacker_id, "gold"])) >= ExpeditionSupplyCalculatorScript.minimum_gold(deployable) and int(_q("city_food_total", [attacker_id])) >= ExpeditionSupplyCalculatorScript.minimum_food(deployable)


func score_invasion_pair(attacker_id: String, defender_id: String) -> int:
	return 0 if not attacker_id.is_empty() and not defender_id.is_empty() else -1


func sort_invasion_pairs(left: Dictionary, right: Dictionary) -> bool:
	var ls := int(left.get("score", 0)); var rs := int(right.get("score", 0))
	return "%s:%s" % [left.get("attacker_city_id", ""), left.get("defender_city_id", "")] < "%s:%s" % [right.get("attacker_city_id", ""), right.get("defender_city_id", "")] if ls == rs else ls > rs


func get_city_troops_for_invasion(city_id: String) -> int:
	return clampi(_troops(city_id), 0, int(_config.get("maximum_city_troops", 99999))) if _has_city(city_id) else 0


func is_player_frontline_city_for_invasion(city_id: String) -> bool:
	if not bool(_q("is_player_owned", [city_id])): return false
	for neighbor_id in _neighbors(city_id):
		if bool(_q("is_enemy_owned", [neighbor_id])): return true
	return false


func _q(name: String, args: Array = []) -> Variant: return _query.call(name, args)
func _player_faction() -> String: return str(_q("player_faction"))
func _has_city(city_id: String) -> bool: return bool(_q("has_city", [city_id]))
func _owner(city_id: String) -> String: return str(_q("safe_enemy_owner", [city_id]))
func _neighbors(city_id: String) -> Array[String]: return _string_array(_q("neighbors", [city_id]))
func _owned_cities(faction_id: String) -> Array[String]: return _string_array(_q("enemy_owned_city_ids", [faction_id]))
func _troops(city_id: String) -> int: return int(_q("city_troops", [city_id]))
func _dictionary(value: Variant) -> Dictionary: return value as Dictionary if value is Dictionary else {}
func _string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if value is Array:
		for item in value: result.append(str(item))
	return result
