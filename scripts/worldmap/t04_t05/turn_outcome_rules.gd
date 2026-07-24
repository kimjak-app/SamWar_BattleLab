class_name TurnOutcomeRules
extends RefCounted

const OUTCOME_ACTIVE := "active"
const OUTCOME_VICTORY := "victory"
const OUTCOME_DEFEAT := "defeat"


static func make_turn_resolution_id(turn_number: int, player_faction_id: String) -> String:
	return "t04-%d-%s" % [maxi(1, turn_number), player_faction_id.strip_edges()]


static func normalize_string_array(raw_values: Variant) -> Array[String]:
	var result: Array[String] = []
	if not raw_values is Array:
		return result
	for raw_value in raw_values:
		var value := str(raw_value).strip_edges()
		if value.is_empty() or result.has(value):
			continue
		result.append(value)
	return result


static func evaluate_outcome(owned_city_count: int, active_city_count: int = 4) -> String:
	var safe_active_count := maxi(1, active_city_count)
	if owned_city_count >= safe_active_count:
		return OUTCOME_VICTORY
	if owned_city_count <= 0:
		return OUTCOME_DEFEAT
	return OUTCOME_ACTIVE


static func make_outcome_state(
	status: String,
	player_faction_id: String,
	turn_number: int,
	owned_city_count: int,
	existing_state: Dictionary = {}
) -> Dictionary:
	var normalized_status := status if [OUTCOME_VICTORY, OUTCOME_DEFEAT].has(status) else OUTCOME_ACTIVE
	if normalized_status == OUTCOME_ACTIVE:
		return {
			"status": OUTCOME_ACTIVE,
			"outcome_id": "",
			"resolved_turn": 0,
			"owned_city_count": clampi(owned_city_count, 0, 4),
			"acknowledged": false,
		}
	var existing_status := str(existing_state.get("status", OUTCOME_ACTIVE))
	if [OUTCOME_VICTORY, OUTCOME_DEFEAT].has(existing_status):
		return existing_state.duplicate(true)
	return {
		"status": normalized_status,
		"outcome_id": "t05-%s-%s-%d" % [normalized_status, player_faction_id.strip_edges(), maxi(1, turn_number)],
		"resolved_turn": maxi(1, turn_number),
		"owned_city_count": clampi(owned_city_count, 0, 4),
		"acknowledged": false,
	}


static func is_terminal_outcome(outcome_state: Variant) -> bool:
	if not outcome_state is Dictionary:
		return false
	return [OUTCOME_VICTORY, OUTCOME_DEFEAT].has(str((outcome_state as Dictionary).get("status", OUTCOME_ACTIVE)))
