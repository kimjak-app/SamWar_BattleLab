extends SceneTree

const ControllerScript := preload("res://scripts/worldmap/t03/t03_battle_presentation_controller.gd")
const VIDEO_PATH := "res://assets/ui/worldmap/videos/ai_faction_battle_theora_q8_1280x720.ogv"

var _checks := 0
var _failures := 0
var _queue: Array = []
var _acknowledged: Array = []
var _completed_calls := 0
var _queue_empty_calls := 0
var _last_completed: Dictionary = {}
var _controller: Node
var _nodes: Dictionary = {}


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_nodes = _make_nodes()
	_controller = ControllerScript.new()
	root.add_child(_controller)
	_controller.presentation_completed.connect(_on_completed)
	_controller.presentation_queue_empty.connect(_on_queue_empty)
	_configure(VIDEO_PATH)
	var setup: Dictionary = _controller.setup()
	_expect(bool(setup.ok) and not (_nodes.root as Control).visible, "setup hides presentation overlay")
	_expect(bool(setup.video_available), "existing T03 video is loaded")

	var built: Dictionary = _controller.build_report(_battle_result("r1", "tx1", true))
	_expect(str(built.report_id) == "r1" and str(built.transaction_id) == "tx1", "report build preserves identities")
	_expect(str(built.title) == "조선군이 사비을 점령했습니다.", "report build preserves victory wording")
	_expect((built.lines as Array).size() == 4 and str((built.lines as Array)[1]).contains("부상병 4"), "report build preserves casualty presentation")
	var defense: Dictionary = _controller.build_report(_battle_result("rd", "txd", false))
	_expect(str(defense.title) == "백제군이 방어에 성공했습니다.", "defender report wording is preserved")
	_expect(_controller.build_report({}).is_empty(), "malformed domain result does not build a report")

	var enqueued: Dictionary = _controller.enqueue_report(built)
	_expect(bool(enqueued.ok) and _queue.size() == 1, "report enqueue writes persistent queue")
	var duplicate: Dictionary = _controller.enqueue_report(built)
	_expect(bool(duplicate.duplicate) and _queue.size() == 1, "duplicate queued report is rejected")
	var second: Dictionary = _controller.build_report(_battle_result("r2", "tx2", false))
	_controller.enqueue_report(second)
	_expect(str((_queue[0] as Dictionary).report_id) == "r1" and str((_queue[1] as Dictionary).report_id) == "r2", "queue preserves FIFO order")
	_expect(str(_controller.enqueue_report({"title": "bad"}).error_code) == "malformed_report", "malformed report enqueue is rejected")

	var presented: Dictionary = _controller.try_present_next()
	_expect(bool(presented.ok) and str(presented.report_id) == "r1", "first queued report becomes current")
	_expect(str((_controller.get_state_snapshot() as Dictionary).phase) == "video", "available video starts playback phase")
	var present_duplicate: Dictionary = _controller.try_present_next()
	_expect(bool(present_duplicate.duplicate), "current report cannot start twice")
	var skipped: Dictionary = _controller.skip_video()
	_expect(bool(skipped.ok) and str((_controller.get_state_snapshot() as Dictionary).phase) == "card", "video skip opens result card")
	_expect((_nodes.card as PanelContainer).visible and str((_nodes.title as Label).text) == str(built.title), "result card displays current report")
	var confirmed: Dictionary = _controller.confirm_report()
	_expect(bool(confirmed.ok) and _completed_calls == 1, "confirm emits completion exactly once")
	_expect(_acknowledged.has("r1") and _queue.size() == 1 and str((_queue[0] as Dictionary).report_id) == "r2", "confirm acknowledges and removes only current report")
	_controller.confirm_report()
	_expect(_completed_calls == 1, "duplicate confirm cannot emit completion again")

	_controller.try_present_next()
	var finished: Dictionary = _controller.finish_video()
	_expect(bool(finished.ok) and str((_controller.get_state_snapshot() as Dictionary).phase) == "card", "video finish opens result card")
	_controller.confirm_report()
	_expect(_completed_calls == 2 and str(_last_completed.report_id) == "r2", "next queued report completes in order")
	var empty: Dictionary = _controller.try_present_next()
	_expect(bool(empty.queue_empty) and _queue_empty_calls == 1, "empty queue emits one completion signal")
	_controller.try_present_next()
	_expect(_queue_empty_calls == 1, "empty queue signal is deduplicated")
	var ack_duplicate: Dictionary = _controller.enqueue_report(second)
	_expect(bool(ack_duplicate.duplicate) and _queue.is_empty(), "acknowledged report cannot be enqueued again")

	var fallback_report: Dictionary = _controller.build_report(_battle_result("r3", "tx3", true))
	_controller.reset_presentation()
	_configure("")
	var fallback_setup: Dictionary = _controller.setup()
	_controller.enqueue_report(fallback_report)
	var fallback_present: Dictionary = _controller.try_present_next()
	_expect(not bool(fallback_setup.video_available) and str(fallback_present.phase) == "card", "missing video falls back directly to result card")
	_controller.reset_presentation()
	var reset_state: Dictionary = _controller.get_state_snapshot()
	_expect(str(reset_state.phase) == "idle" and not bool(reset_state.root_visible) and (reset_state.active_report as Dictionary).is_empty(), "presentation reset clears transient state")

	_finish()


func _configure(video_path: String) -> void:
	_controller.configure(_nodes, Callable(self, "_query"), Callable(self, "_mutation"), Callable(self, "_format_faction"), Callable(self, "_format_city"), video_path)


func _make_nodes() -> Dictionary:
	var overlay := Control.new()
	var video := VideoStreamPlayer.new()
	var labels := Label.new()
	var skip := Button.new()
	var card := PanelContainer.new()
	var title := Label.new()
	var body := Label.new()
	var confirm := Button.new()
	root.add_child(overlay)
	overlay.add_child(video)
	overlay.add_child(labels)
	overlay.add_child(skip)
	overlay.add_child(card)
	card.add_child(title)
	card.add_child(body)
	card.add_child(confirm)
	return {"root": overlay, "video_player": video, "video_labels": labels, "skip_button": skip, "result_card": card, "result_title": title, "result_body": body, "confirm_button": confirm, "card": card, "title": title}


func _battle_result(report_id: String, transaction_id: String, attacker_won: bool) -> Dictionary:
	return {
		"result_id": report_id, "transaction_id": transaction_id,
		"attacker_city_id": "hanseong", "defender_city_id": "sabi",
		"attacker_owner": "player", "defender_owner": "baekje",
		"winner_side": "attacker" if attacker_won else "defender",
		"attacker_healthy_survivors": 30, "attacker_wounded": 4, "attacker_dead": 5, "attacker_deserters": 1,
		"defender_healthy_survivors": 20, "defender_wounded": 6, "defender_dead": 7, "defender_deserters": 2,
		"completed_turn": 9, "result_reason": "resolved",
	}


func _query(query_id: String, _args: Array) -> Variant:
	match query_id:
		"report_queue": return _queue.duplicate(true)
		"acknowledged_report_ids": return _acknowledged.duplicate()
	return null


func _mutation(mutation_id: String, args: Array) -> Variant:
	match mutation_id:
		"set_report_queue":
			_queue = (args[0] as Array).duplicate(true)
			return true
		"set_acknowledged_report_ids":
			_acknowledged = (args[0] as Array).duplicate()
			return true
	return null


func _format_faction(faction_id: String) -> String:
	return {"player": "조선", "baekje": "백제"}.get(faction_id, faction_id)


func _format_city(city_id: String, fallback: String) -> String:
	return {"hanseong": "한성", "sabi": "사비"}.get(city_id, fallback)


func _on_completed(result: Dictionary) -> void:
	_completed_calls += 1
	_last_completed = result.duplicate(true)


func _on_queue_empty(_result: Dictionary) -> void:
	_queue_empty_calls += 1


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if condition:
		print("[T03_PRESENTATION_PASS] %s" % label)
	else:
		_failures += 1
		push_error("[T03_PRESENTATION_FAIL] %s" % label)


func _finish() -> void:
	print("[T03_PRESENTATION] %s: %d checks, %d failures" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	quit(0 if _failures == 0 else 1)
