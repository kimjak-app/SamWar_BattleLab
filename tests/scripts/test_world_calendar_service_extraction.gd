extends SceneTree

const CalendarScript := preload("res://scripts/worldmap/turn/world_calendar_service.gd")

var _checks := 0
var _failures := 0


func _initialize() -> void:
	var calendar := CalendarScript.new()
	var turn_one := calendar.get_calendar(1)
	_expect(turn_one == {"turn": 1, "year": 154, "season_index": 0, "season": "spring", "season_label": "봄", "season_turn": 1, "year_turn": 1}, "turn 1 snapshot parity")
	_expect(calendar.format_label(1) == "154년 봄 1턴", "turn 1 label parity")
	_expect(calendar.get_calendar(10).get("season_turn") == 10 and calendar.is_season_boundary(10), "season boundary end")
	_expect(calendar.get_calendar(11).get("season") == "summer" and calendar.did_season_change(10, 11), "season boundary transition")
	_expect(calendar.get_calendar(40).get("year") == 154 and calendar.get_calendar(40).get("season") == "winter", "year boundary end")
	_expect(calendar.get_calendar(41).get("year") == 155 and calendar.get_calendar(41).get("season") == "spring", "year boundary transition")
	_expect(calendar.get_calendar(81).get("year") == 156, "multiple-year turn")
	_expect(calendar.get_calendar(0).get("turn") == 1 and calendar.get_calendar(-5).get("turn") == 1, "invalid turn normalization")
	_expect(calendar.get_next_season_boundary(11) == 20 and calendar.get_next_season_boundary(20) == 20, "next season boundary parity")
	_expect(calendar.world_month_serial(1) == 0 and calendar.world_month_serial(40) == 11 and calendar.world_month_serial(41) == 12, "month serial parity")
	print("[WORLD_CALENDAR_SERVICE] %s: %d checks, %d failures" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	quit(0 if _failures == 0 else 1)


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("[WORLD_CALENDAR_SERVICE_FAIL] %s" % label)
