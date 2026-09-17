class_name WorldCalendarService
extends RefCounted


const START_YEAR := 154
const SEASON_TURNS := 10
const YEAR_TURNS := 40
const SEASON_ORDER := ["spring", "summer", "autumn", "winter"]
const SEASON_LABELS := {
	"spring": "봄",
	"summer": "여름",
	"autumn": "가을",
	"winter": "겨울",
}


func get_calendar(turn_number: int) -> Dictionary:
	var safe_turn := maxi(1, turn_number)
	var zero_based_turn := safe_turn - 1
	var year_index := floori(float(zero_based_turn) / float(YEAR_TURNS))
	var year_turn := zero_based_turn % YEAR_TURNS
	var season_index := floori(float(year_turn) / float(SEASON_TURNS))
	var season_turn := (zero_based_turn % SEASON_TURNS) + 1
	var season_id := str(SEASON_ORDER[season_index])
	return {
		"turn": safe_turn,
		"year": START_YEAR + year_index,
		"season_index": season_index,
		"season": season_id,
		"season_label": str(SEASON_LABELS.get(season_id, season_id)),
		"season_turn": season_turn,
		"year_turn": year_turn + 1,
	}


func format_label(turn_number: int) -> String:
	var calendar := get_calendar(turn_number)
	return "%d년 %s %d턴" % [
		int(calendar.get("year", START_YEAR)),
		str(calendar.get("season_label", "")),
		int(calendar.get("season_turn", 1)),
	]


func is_season_boundary(turn_number: int) -> bool:
	return maxi(1, turn_number) % SEASON_TURNS == 0


func get_next_season_boundary(turn_number: int) -> int:
	var safe_turn := maxi(1, turn_number)
	var remainder := safe_turn % SEASON_TURNS
	return safe_turn if remainder == 0 else safe_turn + (SEASON_TURNS - remainder)


func did_season_change(previous_turn: int, next_turn: int) -> bool:
	return str(get_calendar(previous_turn).get("season", "")) != str(get_calendar(next_turn).get("season", ""))


func world_month_serial(turn_number: int) -> int:
	var zero_based := maxi(0, turn_number - 1)
	return int(floor(float(zero_based) * 12.0 / float(YEAR_TURNS)))
