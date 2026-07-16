extends SceneTree

const SESSION_SCRIPT := preload("res://scripts/game_session.gd")
const EXPECTED := {
	"player": "hanseong",
	"goguryeo": "pyeongyang",
	"silla": "gyeongju",
	"baekje_faction": "sabi",
}

func _init() -> void:
	_run()

func _run() -> void:
	var failures: Array[String] = []
	var session := SESSION_SCRIPT.new()
	session.name = "GameSession"
	root.add_child(session)
	for faction_id_variant in EXPECTED.keys():
		var faction_id := str(faction_id_variant)
		_get_game_session().request_new_game(faction_id)
		var expected_city_id := str(EXPECTED[faction_id])
		if _get_game_session().consume_new_game_faction_id() != faction_id:
			failures.append("%s player_faction" % faction_id)
		if not _get_game_session().configure_korea_mvp(faction_id):
			failures.append("%s configure" % faction_id)
		if _get_game_session().player_start_city_id != expected_city_id:
			failures.append("%s selected_city" % faction_id)
		if _get_game_session().ai_faction_ids.size() != 3:
			failures.append("%s ai_split" % faction_id)
		var saved_session: Dictionary = _get_game_session().serialize()
		_get_game_session().apply_saved_session(saved_session)
		if _get_game_session().player_faction_id != faction_id or _get_game_session().player_start_city_id != expected_city_id:
			failures.append("%s session_restore" % faction_id)
	if failures.is_empty():
		print("[T01_SMOKE_PASS] four factions + session save payload")
		quit(0)
	else:
		push_error("[T01_SMOKE_FAIL] %s" % ", ".join(failures))
		quit(1)

func _get_game_session() -> Node:
	return root.get_node_or_null("GameSession")
