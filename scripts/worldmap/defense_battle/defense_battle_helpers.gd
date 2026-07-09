extends RefCounted


static func format_troop_move_button_text(preview: Dictionary) -> String:
	if bool(preview.get("ok", false)):
		return "병력 %d 이동" % int(preview.get("amount", 0))
	return "병력 이동 불가"


static func format_troop_move_reason(result: Dictionary) -> String:
	var reason := str(result.get("reason", ""))
	match reason:
		"amount":
			return "이동 병력이 1 이상이어야 합니다."
		"ownership":
			return "출발/도착 도시가 모두 플레이어 소유여야 합니다."
		"same_city":
			return "같은 도시로는 이동할 수 없습니다."
		"not_peacetime":
			return "전투/침공 예약 중에는 이동할 수 없습니다."
		"no_supply_path":
			return "두 도시 사이에 아군 보급 경로가 없습니다."
		"min_garrison":
			return "출발 도시 최소 잔류 병력을 유지해야 합니다."
		_:
			var message := str(result.get("message", ""))
			return message if not message.is_empty() else "이동 조건을 만족하지 않습니다."


static func limit_invasion_result_lines(lines: Array, limit: int) -> Array[String]:
	var result: Array[String] = []
	var safe_limit := maxi(1, limit)
	for line_variant in lines:
		if result.size() >= safe_limit:
			break
		var line := str(line_variant)
		if line.is_empty():
			continue
		result.append(line)
	return result


static func normalize_command_rank_mvp(raw_rank: Variant, rank_limits: Dictionary, lieutenant_rank: String, officer_rank: String) -> String:
	var rank := str(raw_rank).strip_edges()
	if rank_limits.has(rank):
		return rank
	if rank == "captain":
		return lieutenant_rank
	return officer_rank
