extends Node

## Authoritative Korea MVP session role state.  Nation IDs remain registry IDs.
const KOREA_MVP_SCENARIO_ID := "korea_mvp_four_cities"
const STARTS := {
	"player": {"city_id": "hanseong", "label": "한성", "faction_label": "한성 세력"},
	"goguryeo": {"city_id": "pyeongyang", "label": "평양", "faction_label": "고구려"},
	"silla": {"city_id": "gyeongju", "label": "경주", "faction_label": "신라"},
	"baekje_faction": {"city_id": "sabi", "label": "사비", "faction_label": "백제"},
}

var active_scenario_id := ""
var player_faction_id := ""
var player_start_city_id := ""
var ai_faction_ids: Array[String] = []
var _new_game_faction_id := ""
var _load_requested := false

func has_valid_save() -> bool:
	return FileAccess.file_exists("user://samwar_worldmap_state.json")

func request_new_game(faction_id: String) -> bool:
	if not STARTS.has(faction_id):
		return false
	_new_game_faction_id = faction_id
	_load_requested = false
	return true

func consume_new_game_faction_id() -> String:
	var faction_id := _new_game_faction_id
	_new_game_faction_id = ""
	return faction_id

func request_load() -> void:
	_load_requested = true
	_new_game_faction_id = ""

func consume_load_request() -> bool:
	var requested := _load_requested
	_load_requested = false
	return requested

func configure_korea_mvp(faction_id: String) -> bool:
	if not STARTS.has(faction_id):
		return false
	active_scenario_id = KOREA_MVP_SCENARIO_ID
	player_faction_id = faction_id
	player_start_city_id = str((STARTS[faction_id] as Dictionary).get("city_id", ""))
	ai_faction_ids.clear()
	for candidate in STARTS.keys():
		var candidate_id := str(candidate)
		if candidate_id != faction_id:
			ai_faction_ids.append(candidate_id)
	return true

func apply_saved_session(session_data: Dictionary) -> bool:
	var faction_id := str(session_data.get("player_faction_id", "player"))
	if not STARTS.has(faction_id):
		faction_id = "player"
	return configure_korea_mvp(faction_id)

func serialize() -> Dictionary:
	return {
		"active_scenario_id": active_scenario_id if not active_scenario_id.is_empty() else KOREA_MVP_SCENARIO_ID,
		"player_faction_id": player_faction_id if not player_faction_id.is_empty() else "player",
		"player_start_city_id": player_start_city_id,
		"ai_faction_ids": ai_faction_ids.duplicate(),
	}
