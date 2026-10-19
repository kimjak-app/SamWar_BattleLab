extends RefCounted
## LAB ONLY: no AI, damage, turns, or production state imports.
signal move_accepted(unit_id: String, path: Array)
var board
var units: Array[Dictionary] = [
	{"unit_id":"lab_ally_01","hero_id":"lab_commander_a","side":"ally","unit_type":"infantry","current_troops":3200,"grid_cell":Vector2i(3,5)},
	{"unit_id":"lab_ally_02","hero_id":"lab_commander_b","side":"ally","unit_type":"cavalry","current_troops":1800,"grid_cell":Vector2i(4,2)},
	{"unit_id":"lab_enemy_01","hero_id":"lab_commander_c","side":"enemy","unit_type":"infantry","current_troops":2800,"grid_cell":Vector2i(14,6)},
	{"unit_id":"lab_enemy_02","hero_id":"lab_commander_d","side":"enemy","unit_type":"cavalry","current_troops":1600,"grid_cell":Vector2i(15,2)}
]
var busy := false

func at(c: Vector2i) -> Dictionary:
	for u in units:
		if u.grid_cell == c: return u
	return {}

func by_id(id: String) -> Dictionary:
	for u in units:
		if u.unit_id == id: return u
	return {}

func path_to(id: String, target: Vector2i) -> Array:
	var u := by_id(id)
	if u.is_empty() or not board.valid(target) or not at(target).is_empty() or board.terrain(target)=="river": return []
	var start: Vector2i = u.grid_cell
	var queue: Array = [start]
	var parents: Dictionary = {start:start}
	while not queue.is_empty():
		var c: Vector2i = queue.pop_front()
		if c==target: break
		for d in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
			var n: Vector2i = c+d
			if not board.valid(n) or parents.has(n) or not at(n).is_empty() or board.terrain(n)=="river": continue
			parents[n]=c
			queue.append(n)
	if not parents.has(target): return []
	var route: Array = [target]
	while route[0]!=start: route.push_front(parents[route[0]])
	return route

func request_move(id: String, target: Vector2i) -> bool:
	if busy or by_id(id).is_empty() or by_id(id).side!="ally": return false
	var route := path_to(id,target)
	if route.is_empty(): return false
	busy=true
	move_accepted.emit(id,route)
	return true

func acknowledge_presentation(id: String, destination: Vector2i) -> void:
	by_id(id).grid_cell=destination
	busy=false
