class_name WorldMapBattleContextService
extends RefCounted

const HeroRuntimeFactoryScript := preload("res://scripts/worldmap/hero_runtime_factory.gd")
const GameSessionScript := preload("res://scripts/game_session.gd")
const DefenseBattleHelpers := preload("res://scripts/worldmap/defense_battle/defense_battle_helpers.gd")
const ExpeditionSupplyCalculatorScript := preload("res://scripts/t02/expedition_supply_calculator.gd")

const COMMAND_RANK_GOVERNOR := "governor"
const COMMAND_RANK_LIEUTENANT := "lieutenant"
const COMMAND_RANK_OFFICER := "officer"
const DEFAULT_COMMAND_RANK_LABELS := {
	"governor": "태수",
	"general": "장군",
	"lieutenant": "부장",
	"officer": "군관",
}
const DEFAULT_COMMAND_RANK_LIMITS := {
	"governor": 10000,
	"general": 8000,
	"lieutenant": 6000,
	"officer": 5000,
}
const DEFAULT_ROLE_CONTRACT := {
	"unit_type": "infantry",
	"skill_effect_type": "command_aura",
	"battle_effect_type": "ally_attack_buff",
	"skill_power": 6,
	"skill_range": 3,
	"attack_range": 1,
	"move_range": 3,
}

var _query: Callable
var _config: Dictionary = {}


func configure(query: Callable, config: Dictionary) -> void:
	_query = query
	_config = config.duplicate(true)


func _validate_pending_invasion_event_for_battle_context(event: Dictionary) -> Dictionary:
	if event.is_empty():
		return {"ok": false, "message": "진행 중인 침공 이벤트가 없습니다."}
	if str(event.get("type", "")) != "defense":
		return {"ok": false, "message": "방어전 이벤트가 아닙니다."}
	var attacker_city_id := str(event.get("attacker_city_id", ""))
	var defender_city_id := str(event.get("defender_city_id", ""))
	if not _has_city(attacker_city_id):
		return {"ok": false, "message": "침공 도시 정보를 찾을 수 없습니다."}
	if not _has_city(defender_city_id):
		return {"ok": false, "message": "방어 도시 정보를 찾을 수 없습니다."}
	if not bool(_q("is_city_owner_consistent_for_enemy_invasion", [attacker_city_id], false)):
		return {"ok": false, "message": "침공 도시 소유권 정보가 일치하지 않습니다."}
	if not bool(_q("is_city_owner_consistent_for_enemy_invasion", [defender_city_id], false)):
		return {"ok": false, "message": "방어 도시 소유권 정보가 일치하지 않습니다."}
	if not bool(_q("is_city_owned_by_enemy", [attacker_city_id], false)):
		return {"ok": false, "message": "침공 도시가 적 소유가 아닙니다."}
	if not bool(_q("is_city_owned_by_player", [defender_city_id], false)):
		return {"ok": false, "message": "방어 도시가 아군 소유가 아닙니다."}
	if not _string_array(_q("city_neighbors", [attacker_city_id], [])).has(defender_city_id):
		return {"ok": false, "message": "침공 도시와 방어 도시가 인접하지 않습니다."}
	if int(_q("city_troops_for_enemy_invasion", [attacker_city_id], 0)) < int(_config.get("minimum_invasion_troops", 160)):
		return {"ok": false, "message": "침공 도시 병력이 부족합니다."}
	return {"ok": true, "message": ""}


func _build_battle_context_from_pending_invasion(event: Dictionary, mode: String, selected_defender_hero_ids: Array[String] = [], defender_troop_allocation_override: Dictionary = {}) -> Dictionary:
	var attacker_city_id := str(event.get("attacker_city_id", ""))
	var defender_city_id := str(event.get("defender_city_id", ""))
	var attacker_owner := _city_owner(attacker_city_id)
	var defender_owner := _city_owner(defender_city_id)
	var used_hero_ids := {}
	var attacker_roster := _build_invasion_side_roster_for_battle_context(attacker_city_id, attacker_owner, used_hero_ids, "attacker")
	var defender_roster := {}
	if selected_defender_hero_ids.is_empty():
		defender_roster = _build_invasion_side_roster_for_battle_context(defender_city_id, defender_owner, used_hero_ids, "defender")
	else:
		defender_roster = _build_selected_side_roster_for_battle_context(defender_city_id, selected_defender_hero_ids, defender_troop_allocation_override, used_hero_ids, "defender")
	var attacker_troop_allocation := _build_command_limit_troop_allocation_for_heroes(attacker_roster.get("hero_ids", []), _city_troops(attacker_city_id), attacker_city_id)
	var defender_troop_allocation := _build_command_limit_troop_allocation_for_heroes(defender_roster.get("hero_ids", []), _city_troops(defender_city_id), defender_city_id)
	if not selected_defender_hero_ids.is_empty():
		defender_troop_allocation = defender_troop_allocation_override.duplicate(true)
	attacker_roster = _apply_troop_allocation_to_roster(attacker_roster, attacker_troop_allocation, attacker_city_id)
	defender_roster = _apply_troop_allocation_to_roster(defender_roster, defender_troop_allocation, defender_city_id)
	var turn_number := maxi(1, int(_q("turn_number", [], 1)))
	return {
		"type": "defense",
		"source": "enemy_invasion",
		"mode": "auto" if mode == "auto" else "manual",
		"attacker_city_id": attacker_city_id,
		"defender_city_id": defender_city_id,
		"attacker_city_name": _city_name(attacker_city_id, "알 수 없는 적 도시"),
		"defender_city_name": _city_name(defender_city_id, "알 수 없는 아군 도시"),
		"turn_number": turn_number,
		"event_turn_number": int(event.get("turn_number", turn_number)),
		"attacker_owner": attacker_owner,
		"defender_owner": defender_owner,
		"attacker_troops": _city_troops(attacker_city_id),
		"defender_troops": _city_troops(defender_city_id),
		"attacker_troop_allocation": attacker_troop_allocation.duplicate(true),
		"defender_troop_allocation": defender_troop_allocation.duplicate(true),
		"attacker_total_allocated_troops": _sum_troop_allocation(attacker_troop_allocation),
		"defender_total_allocated_troops": _sum_troop_allocation(defender_troop_allocation),
		"attacker_source_city_id": attacker_city_id,
		"defender_source_city_id": defender_city_id,
		"selected_defender_hero_ids": _normalize_hero_ids(selected_defender_hero_ids),
		"attacker_hero_ids": attacker_roster.get("hero_ids", []),
		"defender_hero_ids": defender_roster.get("hero_ids", []),
		"attacker_heroes": attacker_roster.get("heroes", []),
		"defender_heroes": defender_roster.get("heroes", []),
		"attacker_main_hero_ids": attacker_roster.get("main_hero_ids", []),
		"defender_main_hero_ids": defender_roster.get("main_hero_ids", []),
		"attacker_support_hero_ids": attacker_roster.get("support_hero_ids", []),
		"defender_support_hero_ids": defender_roster.get("support_hero_ids", []),
		"attacker_support_city_ids": attacker_roster.get("support_city_ids", []),
		"defender_support_city_ids": defender_roster.get("support_city_ids", []),
		"attacker_governor_id": _get_city_governor_id_for_battle_context(attacker_city_id),
		"defender_governor_id": _get_city_governor_id_for_battle_context(defender_city_id),
	}


func _build_player_attack_battle_context(source_city_id: String, target_city_id: String, mode: String = "manual", selected_attacker_hero_ids: Array[String] = [], attacker_troop_allocation: Dictionary = {}, supply_cost: Dictionary = {}) -> Dictionary:
	if source_city_id.is_empty() or target_city_id.is_empty() or not _has_city(source_city_id) or not _has_city(target_city_id):
		return {}
	var attacker_owner := _city_owner(source_city_id)
	var defender_owner := _city_owner(target_city_id)
	var used_hero_ids := {}
	var attacker_roster := _build_player_attack_selected_roster_for_battle_context(source_city_id, selected_attacker_hero_ids, attacker_troop_allocation, used_hero_ids)
	var defender_roster := _build_invasion_side_roster_for_battle_context(target_city_id, defender_owner, used_hero_ids, "defender")
	var defender_troop_allocation := _build_command_limit_troop_allocation_for_heroes(defender_roster.get("hero_ids", []), _city_troops(target_city_id), target_city_id)
	defender_roster = _apply_troop_allocation_to_roster(defender_roster, defender_troop_allocation, target_city_id)
	var attacker_main_hero_ids: Array = attacker_roster.get("main_hero_ids", [])
	if attacker_main_hero_ids.is_empty():
		return {}
	var total_assigned_troops := 0
	for hero_id in attacker_main_hero_ids:
		total_assigned_troops += maxi(0, int(attacker_troop_allocation.get(str(hero_id), 0)))
	var defender_supply := _dictionary(_q("city_battle_supply", [target_city_id], {}))
	var attacker_food_type := str(supply_cost.get("food_type", "rice"))
	return {
		"type": "attack", "source": str(_config.get("player_attack_context_source", "player_attack")), "battle_mode": "invasion",
		"mode": "auto" if mode == "auto" else "manual",
		"attacker_city_id": source_city_id, "defender_city_id": target_city_id,
		"attacker_city_name": _city_name(source_city_id, "알 수 없는 아군 도시"),
		"defender_city_name": _city_name(target_city_id, "알 수 없는 적 도시"),
		"turn_number": maxi(1, int(_q("turn_number", [], 1))),
		"attacker_owner": attacker_owner, "defender_owner": defender_owner,
		"attacker_faction_id": attacker_owner, "defender_faction_id": defender_owner,
		"attacker_faction_display_name": GameSessionScript.get_battle_faction_display_name(attacker_owner),
		"defender_faction_display_name": GameSessionScript.get_battle_faction_display_name(defender_owner),
		"source_city_id": source_city_id, "target_city_id": target_city_id,
		"source_city_display_name": _city_name(source_city_id, "알 수 없는 도시"),
		"target_city_display_name": _city_name(target_city_id, "알 수 없는 도시"),
		"attacker_troops": total_assigned_troops if total_assigned_troops > 0 else _city_troops(source_city_id),
		"defender_troops": _city_troops(target_city_id),
		"attacker_initial_healthy_troops": total_assigned_troops,
		"defender_initial_healthy_troops": _city_troops(target_city_id),
		"attacker_hero_ids": attacker_roster.get("hero_ids", []), "defender_hero_ids": defender_roster.get("hero_ids", []),
		"attacker_heroes": attacker_roster.get("heroes", []), "defender_heroes": defender_roster.get("heroes", []),
		"selected_attacker_hero_ids": attacker_main_hero_ids.duplicate(), "attacker_general_ids": attacker_main_hero_ids.duplicate(),
		"defender_general_ids": defender_roster.get("main_hero_ids", []).duplicate(),
		"attacker_troop_allocation": attacker_troop_allocation.duplicate(true), "attacker_troop_composition": attacker_troop_allocation.duplicate(true),
		"defender_troop_composition": defender_troop_allocation.duplicate(true), "supply_cost": supply_cost.duplicate(true),
		"attacker_carried_gold": maxi(0, int(supply_cost.get("gold", 0))), "attacker_food_type": attacker_food_type,
		"attacker_food_amount": maxi(0, int(supply_cost.get("food", 0))), "attacker_salt_amount": maxi(0, int(supply_cost.get("salt", 0))),
		"defender_food_type": str(defender_supply.get("food_type", "rice")),
		"defender_food_amount": maxi(0, int(defender_supply.get("food_amount", 0))),
		"defender_salt_amount": maxi(0, int(defender_supply.get("salt_amount", 0))),
		"battle_max_turns": ExpeditionSupplyCalculatorScript.BATTLE_MAX_TURNS, "current_battle_turn": 1,
		"supply_balance_snapshot": {}, "tech_effect_snapshot": {}, "supply_source_city_id": source_city_id,
		"defender_troop_allocation": defender_troop_allocation.duplicate(true),
		"defender_total_allocated_troops": _sum_troop_allocation(defender_troop_allocation), "defender_source_city_id": target_city_id,
		"attacker_main_hero_ids": attacker_roster.get("main_hero_ids", []), "defender_main_hero_ids": defender_roster.get("main_hero_ids", []),
		"attacker_support_hero_ids": attacker_roster.get("support_hero_ids", []), "defender_support_hero_ids": defender_roster.get("support_hero_ids", []),
		"attacker_support_city_ids": attacker_roster.get("support_city_ids", []), "defender_support_city_ids": defender_roster.get("support_city_ids", []),
		"attacker_governor_id": str(attacker_main_hero_ids[0]),
		"defender_governor_id": _get_city_governor_id_for_battle_context(target_city_id),
	}


func _build_player_attack_selected_roster_for_battle_context(source_city_id: String, selected_hero_ids: Array[String], troop_allocation: Dictionary, used_hero_ids: Dictionary) -> Dictionary:
	return _build_selected_side_roster_for_battle_context(source_city_id, selected_hero_ids, troop_allocation, used_hero_ids, "attacker")


func _build_selected_side_roster_for_battle_context(source_city_id: String, selected_hero_ids: Array[String], troop_allocation: Dictionary, used_hero_ids: Dictionary, side_label: String) -> Dictionary:
	var hero_ids: Array[String] = []
	var main_hero_ids: Array[String] = []
	var source_heroes: Array = selected_hero_ids.duplicate()
	if source_heroes.is_empty():
		source_heroes = _array(_q("available_player_attack_hero_ids", [source_city_id], []))
	for raw_hero_id in source_heroes:
		var hero_id := str(raw_hero_id)
		if not selected_hero_ids.is_empty() and maxi(0, int(troop_allocation.get(hero_id, 0))) <= 0:
			continue
		if _append_invasion_roster_hero_id(hero_ids, main_hero_ids, hero_id, used_hero_ids, side_label, source_city_id, "selected_main") and hero_ids.size() >= _max_heroes():
			break
	var heroes: Array[Dictionary] = []
	for hero_id in hero_ids:
		var hero_battle_data := _get_hero_battle_data_for_battle_context(hero_id, source_city_id)
		if hero_battle_data.is_empty():
			continue
		var command_summary := _get_hero_command_summary_for_city_mvp(hero_battle_data, source_city_id)
		hero_battle_data.merge(command_summary, true)
		var assigned_troops := mini(maxi(0, int(troop_allocation.get(hero_id, hero_battle_data.get("troops", 0)))), int(hero_battle_data.get("command_limit", 0)))
		if assigned_troops > 0:
			_set_hero_troops(hero_battle_data, assigned_troops)
		heroes.append(hero_battle_data)
	return {"hero_ids": hero_ids, "heroes": heroes, "main_hero_ids": main_hero_ids, "support_hero_ids": [], "support_city_ids": []}


func _build_even_troop_allocation_for_heroes(hero_ids_source: Array, total_troops: int) -> Dictionary:
	var allocation := {}
	var hero_ids := _normalize_hero_ids(hero_ids_source)
	var remaining := maxi(0, total_troops)
	if hero_ids.is_empty() or remaining <= 0:
		return allocation
	var base := int(floor(float(remaining) / float(hero_ids.size())))
	var extra := remaining % hero_ids.size()
	for index in range(hero_ids.size()):
		var amount := base + (1 if index < extra else 0)
		if amount > 0:
			allocation[hero_ids[index]] = amount
	return allocation


func _build_command_limit_troop_allocation_for_heroes(hero_ids_source: Array, total_troops: int, source_city_id: String) -> Dictionary:
	var allocation := {}
	var active_heroes: Array[Dictionary] = []
	var total_command_limit := 0
	for hero_id in _normalize_hero_ids(hero_ids_source):
		allocation[hero_id] = 0
		var hero_data := _hero_entry(hero_id)
		if hero_data.is_empty():
			continue
		var command_limit := _get_hero_command_limit_for_city_mvp(hero_data, source_city_id)
		if command_limit > 0:
			active_heroes.append({"hero_id": hero_id, "limit": command_limit})
			total_command_limit += command_limit
	var remaining := mini(maxi(0, total_troops), total_command_limit)
	while remaining > 0:
		var open_heroes: Array[Dictionary] = []
		for entry in active_heroes:
			if int(allocation.get(str(entry.hero_id), 0)) < int(entry.limit):
				open_heroes.append(entry)
		if open_heroes.is_empty():
			break
		var share := maxi(1, int(ceil(float(remaining) / float(open_heroes.size()))))
		var assigned_this_pass := 0
		for entry in open_heroes:
			var hero_id := str(entry.hero_id)
			var room := maxi(0, int(entry.limit) - int(allocation.get(hero_id, 0)))
			var amount := mini(mini(room, share), remaining)
			if amount > 0:
				allocation[hero_id] = int(allocation.get(hero_id, 0)) + amount
				assigned_this_pass += amount
				remaining -= amount
			if remaining <= 0:
				break
		if assigned_this_pass <= 0:
			break
	return allocation


func _apply_troop_allocation_to_roster(roster: Dictionary, allocation: Dictionary, fallback_city_id: String) -> Dictionary:
	var next_roster := roster.duplicate(true)
	var heroes: Array[Dictionary] = []
	for hero_id in _normalize_hero_ids(next_roster.get("hero_ids", [])):
		var hero_battle_data := _get_hero_battle_data_for_battle_context(hero_id, fallback_city_id)
		if hero_battle_data.is_empty():
			continue
		hero_battle_data.merge(_get_hero_command_summary_for_city_mvp(hero_battle_data, fallback_city_id), true)
		var allocated := maxi(0, int(allocation.get(hero_id, hero_battle_data.get("troops", 0))))
		if allocated > 0:
			_set_hero_troops(hero_battle_data, allocated)
		heroes.append(hero_battle_data)
	next_roster["heroes"] = heroes
	return next_roster


func _sum_troop_allocation(allocation: Dictionary) -> int:
	var total := 0
	for key in allocation:
		total += maxi(0, int(allocation.get(key, 0)))
	return total


func _build_invasion_side_roster_for_battle_context(source_city_id: String, faction_id: String, used_hero_ids: Dictionary, context_side: String) -> Dictionary:
	var hero_ids: Array[String] = []
	var main_hero_ids: Array[String] = []
	var support_hero_ids: Array[String] = []
	var support_city_ids: Array[String] = []
	if not _has_city(source_city_id):
		return _build_invasion_roster_result(hero_ids, main_hero_ids, support_hero_ids, support_city_ids)
	for hero_id in _get_city_stationed_hero_ids_for_battle_context(source_city_id):
		if _append_invasion_roster_hero_id(hero_ids, main_hero_ids, str(hero_id), used_hero_ids, context_side, source_city_id, "main") and hero_ids.size() >= _max_heroes():
			return _build_invasion_roster_result(hero_ids, main_hero_ids, support_hero_ids, support_city_ids)
	for candidate_city_id in _get_reinforcement_candidate_city_ids_for_battle_context(source_city_id):
		if hero_ids.size() >= _max_heroes():
			break
		if not _has_city(candidate_city_id) or not _are_factions_reinforcement_compatible(faction_id, _city_owner(candidate_city_id)):
			continue
		var city_added_hero := false
		for hero_id in _get_city_stationed_hero_ids_for_battle_context(candidate_city_id):
			if hero_ids.size() >= _max_heroes():
				break
			if _append_invasion_roster_hero_id(hero_ids, support_hero_ids, str(hero_id), used_hero_ids, context_side, candidate_city_id, "support"):
				city_added_hero = true
		if city_added_hero and not support_city_ids.has(candidate_city_id):
			support_city_ids.append(candidate_city_id)
	return _build_invasion_roster_result(hero_ids, main_hero_ids, support_hero_ids, support_city_ids)


func _append_invasion_roster_hero_id(target_hero_ids: Array[String], source_bucket: Array[String], hero_id: String, used_hero_ids: Dictionary, _context_side: String, _city_id: String, _pick_type: String) -> bool:
	if hero_id.is_empty() or used_hero_ids.has(hero_id) or target_hero_ids.has(hero_id) or _hero_entry(hero_id).is_empty():
		return false
	if bool(_q("is_hero_captured_for_battle", [hero_id], false)):
		return false
	used_hero_ids[hero_id] = true
	target_hero_ids.append(hero_id)
	source_bucket.append(hero_id)
	return true


func _build_invasion_roster_result(hero_ids: Array[String], main_hero_ids: Array[String], support_hero_ids: Array[String], support_city_ids: Array[String]) -> Dictionary:
	var heroes: Array[Dictionary] = []
	for hero_id in hero_ids:
		var hero_battle_data := _get_hero_battle_data_for_battle_context(hero_id, _get_hero_city_id_for_battle_context(hero_id))
		if not hero_battle_data.is_empty():
			heroes.append(hero_battle_data)
	return {"hero_ids": hero_ids, "heroes": heroes, "main_hero_ids": main_hero_ids, "support_hero_ids": support_hero_ids, "support_city_ids": support_city_ids}


func _get_reinforcement_candidate_city_ids_for_battle_context(source_city_id: String) -> Array[String]:
	var result: Array[String] = []
	var seen := {source_city_id: true}
	var frontier: Array[String] = [source_city_id]
	for _hop in range(1, int(_config.get("reinforcement_max_hops", 2)) + 1):
		var next_frontier: Array[String] = []
		for city_id in frontier:
			for neighbor_id in _string_array(_q("city_neighbors", [city_id], [])):
				if seen.has(neighbor_id):
					continue
				seen[neighbor_id] = true
				result.append(neighbor_id)
				next_frontier.append(neighbor_id)
		frontier = next_frontier
	return result


func _are_factions_reinforcement_compatible(source_faction_id: String, candidate_faction_id: String) -> bool:
	if source_faction_id.is_empty() or candidate_faction_id.is_empty():
		return false
	if source_faction_id == candidate_faction_id:
		return true
	var allies: Variant = _dictionary(_config.get("reinforcement_ally_factions", {})).get(source_faction_id, [])
	return allies is Array and (allies as Array).has(candidate_faction_id)


func _get_hero_city_id_for_battle_context(hero_id: String) -> String:
	var hero_data := _hero_entry(hero_id)
	return str(hero_data.get("current_city_id", hero_data.get("city_id", hero_data.get("location_city_id", ""))))


func _get_city_stationed_hero_ids_for_battle_context(city_id: String) -> Array:
	return _array(_q("city_stationed_hero_ids", [city_id], [])).duplicate()


func _get_city_battle_heroes_for_battle_context(city_id: String) -> Array[Dictionary]:
	var battle_heroes: Array[Dictionary] = []
	for hero_id in _get_city_stationed_hero_ids_for_battle_context(city_id):
		var hero_battle_data := _get_hero_battle_data_for_battle_context(str(hero_id), city_id)
		if not hero_battle_data.is_empty():
			battle_heroes.append(hero_battle_data)
	return battle_heroes


func _apply_domestic_battle_tech_modifier_to_hero_data_mvp(battle_data: Dictionary, city_id: String) -> Dictionary:
	if city_id.is_empty() or not bool(_q("is_city_owned_by_player", [city_id], false)):
		return battle_data
	var modifier := _dictionary(_q("player_battle_tech_modifier", ["combined", city_id], {}))
	if not bool(_q("has_domestic_battle_modifier_data", [modifier], false)):
		return battle_data
	var unit_type := str(battle_data.get("unit_type", "infantry")).to_lower()
	var attack_pct := float(modifier.get("global_attack_pct", 0.0))
	var defense_pct := float(modifier.get("global_defense_pct", 0.0))
	match unit_type:
		"infantry", "melee":
			attack_pct += float(modifier.get("infantry_attack_pct", 0.0)); defense_pct += float(modifier.get("infantry_defense_pct", 0.0))
		"archer", "ranged":
			attack_pct += float(modifier.get("archer_attack_pct", 0.0)); defense_pct += float(modifier.get("archer_defense_pct", 0.0))
		"cavalry": attack_pct += float(modifier.get("cavalry_attack_pct", 0.0)) + float(modifier.get("cavalry_charge_pct", 0.0))
		"gunpowder": attack_pct += float(modifier.get("gunpowder_attack_pct", 0.0))
		"crossbow": attack_pct += float(modifier.get("crossbow_attack_pct", 0.0))
		"siege": attack_pct += float(modifier.get("siege_attack_pct", 0.0))
	attack_pct = clampf(attack_pct, 0.0, 0.25)
	defense_pct = clampf(defense_pct, 0.0, 0.25)
	if not is_equal_approx(attack_pct, 0.0):
		battle_data["attack"] = maxi(1, int(round(float(int(battle_data.get("attack", 1))) * (1.0 + attack_pct))))
	if not is_equal_approx(defense_pct, 0.0):
		battle_data["defense"] = maxi(1, int(round(float(int(battle_data.get("defense", 1))) * (1.0 + defense_pct))))
	return battle_data


func _get_hero_battle_data_for_battle_context(hero_id: String, fallback_city_id: String) -> Dictionary:
	var hero_data := _hero_entry(hero_id)
	if hero_data.is_empty():
		return {}
	var battle_data := HeroRuntimeFactoryScript.build_runtime_hero(hero_data, hero_data)
	if not HeroRuntimeFactoryScript.is_valid_runtime_hero(battle_data):
		return {}
	var normalized_hero_id := str(battle_data.get("hero_id", battle_data.get("id", hero_id)))
	var role := str(battle_data.get("web_role", battle_data.get("role", ""))).to_lower()
	var role_contracts := _dictionary(_config.get("hero_role_contracts", {}))
	var role_contract := _dictionary(role_contracts.get(role, _config.get("hero_default_role_contract", DEFAULT_ROLE_CONTRACT))).duplicate(true)
	var faction_id := str(battle_data.get("faction_id", battle_data.get("force_id", battle_data.get("nation", ""))))
	var current_city_id := str(battle_data.get("current_city_id", battle_data.get("city_id", battle_data.get("location_city_id", fallback_city_id))))
	var skill_id := str(battle_data.get("skill_id", battle_data.get("unique_skill_id", "%s_skill" % normalized_hero_id)))
	battle_data["hero_id"] = normalized_hero_id
	battle_data["display_name"] = str(battle_data.get("display_name", battle_data.get("name", normalized_hero_id)))
	battle_data["faction_id"] = faction_id
	battle_data["force_id"] = str(battle_data.get("force_id", faction_id))
	battle_data["nation"] = str(battle_data.get("nation", faction_id))
	battle_data["owner"] = str(battle_data.get("owner", battle_data.get("nation", faction_id)))
	battle_data["current_city_id"] = current_city_id
	battle_data["city_id"] = current_city_id
	battle_data["unit_type"] = str(battle_data.get("unit_type", role_contract.get("unit_type", "infantry")))
	battle_data["troop_count"] = maxi(0, int(battle_data.get("troop_count", battle_data.get("troops", 0))))
	battle_data["troops"] = int(battle_data["troop_count"])
	battle_data["leadership"] = int(battle_data.get("leadership", battle_data.get("command", battle_data.get("war", 70))))
	battle_data["command"] = int(battle_data["leadership"])
	battle_data["war"] = int(battle_data.get("war", battle_data.get("attack", 60)))
	battle_data["attack"] = int(battle_data.get("attack", maxi(10, floori(float(int(battle_data["war"])) / 3.0))))
	battle_data["defense"] = int(battle_data.get("defense", 12))
	battle_data["intelligence"] = int(battle_data.get("intelligence", 60))
	battle_data["move_range"] = maxi(1, int(battle_data.get("move_range", role_contract.get("move_range", 3))))
	battle_data["mobility"] = int(battle_data["move_range"])
	battle_data["attack_range"] = maxi(1, int(battle_data.get("attack_range", role_contract.get("attack_range", 1))))
	battle_data["portrait_path"] = str(battle_data.get("portrait_path", _get_hero_contract_portrait_path(normalized_hero_id, faction_id)))
	battle_data["cutin_path"] = str(battle_data.get("cutin_path", _get_hero_contract_cutin_path(normalized_hero_id, faction_id)))
	battle_data["skill_id"] = skill_id
	battle_data["skill_name"] = _format_hero_contract_skill_name(battle_data)
	battle_data["skill_desc"] = _format_hero_contract_skill_desc(battle_data, role_contract)
	battle_data["skill_effect_type"] = str(battle_data.get("skill_effect_type", role_contract.get("skill_effect_type", "command_aura")))
	battle_data["battle_effect_type"] = str(battle_data.get("battle_effect_type", role_contract.get("battle_effect_type", "ally_attack_buff")))
	battle_data["skill_power"] = int(battle_data.get("skill_power", role_contract.get("skill_power", 6)))
	battle_data["skill_value"] = int(battle_data["skill_power"])
	battle_data["skill_range"] = maxi(0, int(battle_data.get("skill_range", role_contract.get("skill_range", 3))))
	battle_data["skill_cooldown"] = maxi(0, int(battle_data.get("skill_cooldown", 0)))
	battle_data["skill_toast_icon"] = str(battle_data.get("skill_toast_icon", _config.get("hero_toast_icon_fallback", "skill_unknown")))
	return _apply_domestic_battle_tech_modifier_to_hero_data_mvp(battle_data, current_city_id)


func _get_city_governor_id_for_battle_context(city_id: String) -> String:
	return str(_q("city_governor_id", [city_id], ""))


func _normalize_command_rank_mvp(raw_rank: Variant) -> String:
	return DefenseBattleHelpers.normalize_command_rank_mvp(raw_rank, _command_rank_limits(), COMMAND_RANK_LIEUTENANT, COMMAND_RANK_OFFICER)


func _get_hero_command_rank_for_city_mvp(hero_data: Dictionary, city_id: String) -> String:
	var hero_id := str(hero_data.get("hero_id", hero_data.get("id", "")))
	if not hero_id.is_empty() and hero_id == _get_city_governor_id_for_battle_context(city_id):
		return COMMAND_RANK_GOVERNOR
	return _normalize_command_rank_mvp(hero_data.get("command_rank", hero_data.get("commandRank", COMMAND_RANK_OFFICER)))


func _get_hero_command_limit_for_city_mvp(hero_data: Dictionary, city_id: String) -> int:
	var limits := _command_rank_limits()
	return maxi(0, int(limits.get(_get_hero_command_rank_for_city_mvp(hero_data, city_id), limits.get(COMMAND_RANK_OFFICER, 5000))))


func _get_hero_command_summary_for_city_mvp(hero_data: Dictionary, city_id: String) -> Dictionary:
	var rank := _get_hero_command_rank_for_city_mvp(hero_data, city_id)
	var labels := _dictionary(_config.get("command_rank_labels", DEFAULT_COMMAND_RANK_LABELS))
	return {"command_rank": rank, "command_label": str(labels.get(rank, labels.get(COMMAND_RANK_OFFICER, "군관"))), "command_limit": _get_hero_command_limit_for_city_mvp(hero_data, city_id)}


func _get_hero_contract_nation_key(faction_id: String) -> String:
	return str(_dictionary(_config.get("hero_portrait_nation_by_faction", {})).get(faction_id, "unknown"))


func _get_hero_contract_portrait_path(hero_id: String, faction_id: String) -> String:
	var nation_key := _get_hero_contract_nation_key(faction_id)
	return "res://assets/heroes/portraits/%s/%s_%s.png" % [nation_key, nation_key, hero_id]


func _get_hero_contract_cutin_path(hero_id: String, faction_id: String) -> String:
	var nation_key := _get_hero_contract_nation_key(faction_id)
	return "res://assets/heroes/cutins/%s/%s_%s_cutin.png" % [nation_key, nation_key, hero_id]


func _format_hero_contract_skill_name(hero_data: Dictionary) -> String:
	return str(hero_data.get("skill_name", "%s 전법" % str(hero_data.get("display_name", "장수"))))


func _format_hero_contract_skill_desc(hero_data: Dictionary, role_contract: Dictionary) -> String:
	if not str(hero_data.get("skill_desc", "")).is_empty():
		return str(hero_data.get("skill_desc"))
	return "%s의 %s 계열 임시 고유특기입니다." % [str(hero_data.get("display_name", "장수")), str(role_contract.get("skill_effect_type", "command_aura"))]


func _q(query_id: String, args: Array = [], fallback: Variant = null) -> Variant:
	if not _query.is_valid():
		return fallback
	var value: Variant = _query.call(query_id, args)
	return fallback if value == null else value


func _has_city(city_id: String) -> bool:
	return not city_id.is_empty() and bool(_q("has_city", [city_id], false))


func _city_owner(city_id: String) -> String:
	return str(_q("city_owner", [city_id], ""))


func _city_troops(city_id: String) -> int:
	return maxi(0, int(_q("city_troops", [city_id], 0)))


func _city_name(city_id: String, fallback: String) -> String:
	return str(_q("city_name", [city_id, fallback], fallback))


func _hero_entry(hero_id: String) -> Dictionary:
	return _dictionary(_q("hero_entry", [hero_id], {})).duplicate(true)


func _normalize_hero_ids(source: Array) -> Array[String]:
	var result: Array[String] = []
	for raw_id in source:
		var hero_id := str(raw_id)
		if not hero_id.is_empty() and not result.has(hero_id):
			result.append(hero_id)
	return result


func _set_hero_troops(hero_data: Dictionary, amount: int) -> void:
	hero_data["troops"] = amount
	hero_data["troop_count"] = amount
	hero_data["max_troops"] = amount
	hero_data["allocated_troops"] = amount
	hero_data["initial_allocated_troops"] = amount


func _max_heroes() -> int:
	return maxi(1, int(_config.get("max_heroes_per_side", 5)))


func _command_rank_limits() -> Dictionary:
	return _dictionary(_config.get("command_rank_limits", DEFAULT_COMMAND_RANK_LIMITS))


func _dictionary(value: Variant) -> Dictionary:
	return value if value is Dictionary else {}


func _array(value: Variant) -> Array:
	return value if value is Array else []


func _string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if value is Array:
		for entry in value:
			result.append(str(entry))
	return result
