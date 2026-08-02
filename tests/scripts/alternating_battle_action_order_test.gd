extends SceneTree


func _init() -> void:
	if not _expect(["ally_1", "enemy_1", "ally_2", "enemy_2", "ally_3", "enemy_3", "round_complete"], _schedule(3, 3)):
		quit(1)
		return
	if not _expect(["ally_1", "enemy_1", "ally_2", "enemy_2", "ally_3", "round_complete"], _schedule(3, 2)):
		quit(1)
		return
	if not _expect(["ally_1", "enemy_1", "ally_2", "enemy_2", "enemy_3", "round_complete"], _schedule(2, 3)):
		quit(1)
		return
	print("ALTERNATING BATTLE ACTION ORDER GODOT PASS")
	quit(0)


func _schedule(ally_count: int, enemy_count: int) -> Array[String]:
	var order: Array[String] = []
	for index in range(maxi(ally_count, enemy_count)):
		if index < ally_count:
			order.append("ally_%d" % (index + 1))
		if index < enemy_count:
			order.append("enemy_%d" % (index + 1))
	order.append("round_complete")
	return order


func _expect(expected: Array[String], actual: Array[String]) -> bool:
	if expected == actual:
		return true
	printerr("ALTERNATING BATTLE ACTION ORDER GODOT FAILED expected=%s actual=%s" % [expected, actual])
	return false
