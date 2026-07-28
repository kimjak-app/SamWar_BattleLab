extends Node

## Authoritative Korea MVP session role state. Nation IDs remain registry IDs.
const KOREA_MVP_SCENARIO_ID := "korea_mvp_four_cities"
const WORLDMAP_SAVE_PATH := "user://worldmap_left_panel_state.json"
const BATTLE_RESUME_SAVE_PATH := "user://battle_runtime_resume.json"
const HERO_SAVE_MIGRATION_VERSION := 1
const STARTS := {
	"player": {"city_id": "hanseong", "label": "한성", "faction_label": "조선"},
	"goguryeo": {"city_id": "pyeongyang", "label": "평양", "faction_label": "고구려"},
	"silla": {"city_id": "gyeongju", "label": "경주", "faction_label": "신라"},
	"baekje_faction": {"city_id": "sabi", "label": "사비", "faction_label": "백제"},
}

## Canonical Korean display names for player-facing battle context.
const BATTLE_FACTION_DISPLAY_NAMES := {
	"player": "조선",
	"goguryeo": "고구려",
	"silla": "신라",
	"baekje_faction": "백제",
}

var active_scenario_id := ""
var player_faction_id := ""
var player_start_city_id := ""
var ai_faction_ids: Array[String] = []
var _new_game_faction_id := ""
var _load_requested := false
var _last_load_migration_error := ""


func has_valid_save() -> bool:
	return FileAccess.file_exists(WORLDMAP_SAVE_PATH)


func save_battle_resume_snapshot(snapshot: Dictionary) -> bool:
	if snapshot.is_empty():
		return false
	var target_file := FileAccess.open(BATTLE_RESUME_SAVE_PATH, FileAccess.WRITE)
	if target_file == null:
		return false
	target_file.store_string(JSON.stringify(snapshot, "\t"))
	return true


func load_battle_resume_snapshot(expected_battle_id: String) -> Dictionary:
	if expected_battle_id.is_empty() or not FileAccess.file_exists(BATTLE_RESUME_SAVE_PATH):
		return {}
	var source_file := FileAccess.open(BATTLE_RESUME_SAVE_PATH, FileAccess.READ)
	if source_file == null:
		return {}
	var parsed: Variant = JSON.parse_string(source_file.get_as_text())
	if not parsed is Dictionary:
		return {}
	var snapshot: Dictionary = parsed
	if String(snapshot.get("battle_id", "")) != expected_battle_id:
		return {}
	return snapshot.duplicate(true)


func clear_battle_resume_snapshot() -> void:
	if FileAccess.file_exists(BATTLE_RESUME_SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(BATTLE_RESUME_SAVE_PATH))


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
	_last_load_migration_error = ""
	if not _migrate_worldmap_save_before_load():
		push_error("[GAME_SESSION] Hero save migration failed: %s" % _last_load_migration_error)
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


func get_last_load_migration_error() -> String:
	return _last_load_migration_error


func _migrate_worldmap_save_before_load() -> bool:
	if not FileAccess.file_exists(WORLDMAP_SAVE_PATH):
		_last_load_migration_error = "save file does not exist"
		return false
	var source_file := FileAccess.open(WORLDMAP_SAVE_PATH, FileAccess.READ)
	if source_file == null:
		_last_load_migration_error = "cannot open save file for reading"
		return false
	var parsed: Variant = JSON.parse_string(source_file.get_as_text())
	if not parsed is Dictionary:
		_last_load_migration_error = "save root is not a Dictionary"
		return false
	var source_payload: Dictionary = parsed
	var migrated_variant: Variant = HeroRuntimeFactory.migrate_saved_payload(
		source_payload,
		HeroDefinitionRegistry.LEGACY_IDENTITY_DATA
	)
	if not migrated_variant is Dictionary:
		_last_load_migration_error = "migrated save root is not a Dictionary"
		return false
	var migrated_payload: Dictionary = migrated_variant
	migrated_payload["hero_runtime_migration_version"] = HERO_SAVE_MIGRATION_VERSION
	var target_file := FileAccess.open(WORLDMAP_SAVE_PATH, FileAccess.WRITE)
	if target_file == null:
		_last_load_migration_error = "cannot open save file for writing"
		return false
	target_file.store_string(JSON.stringify(migrated_payload, "\t"))
	print("[GAME_SESSION] hero save migration applied before WorldMap load")
	return true


static func get_battle_faction_display_name(faction_id: String) -> String:
	return str(BATTLE_FACTION_DISPLAY_NAMES.get(faction_id, faction_id))
