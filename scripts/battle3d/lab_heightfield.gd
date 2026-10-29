extends RefCounted
## Pure presentation mapping. Integer cells match BattleGridController.
var SIZE: Vector2i
var CELL: float
var river_center: float
var ford_row: int
var ford_z: float
var data: Dictionary
var terrain_data: Dictionary
var terrain_cells: Array

func _init() -> void:
	data = JSON.parse_string(FileAccess.get_file_as_string("res://assets/battle3d/heightfield.json"))
	if FileAccess.file_exists("res://assets/battle3d/terrain_types.json"):
		terrain_data = JSON.parse_string(FileAccess.get_file_as_string("res://assets/battle3d/terrain_types.json"))
		terrain_cells = terrain_data.get("cells", [])
	else:
		terrain_data = {}
		terrain_cells = []

	SIZE=Vector2i(int(data.board.width),int(data.board.height))
	CELL=float(data.board.cell_size)
	river_center=float(data.board.river_center)
	ford_row=int(data.board.ford_row)
	ford_z=(ford_row+.5)*CELL

func valid(c: Vector2i) -> bool:
	return c.x >= 0 and c.y >= 0 and c.x < SIZE.x and c.y < SIZE.y

func cell_at(p: Vector3) -> Vector2i:
	return Vector2i(floori(p.x / CELL), floori(p.z / CELL))

func world(c: Vector2i) -> Vector3:
	var x := (c.x + 0.5) * CELL
	var z := (c.y + 0.5) * CELL
	return Vector3(x, height(x,z), z)

func height(x: float, z: float) -> float:
	x = clampf(x,0,SIZE.x*CELL-.0001)
	z = clampf(z,0,SIZE.y*CELL-.0001)
	var i := floori(x / float(data.step))
	var j := floori(z / float(data.step))
	var u := x / float(data.step) - i
	var v := z / float(data.step) - j
	var h: Array = data.heights
	var a: float = h[j][i]
	var b: float = h[j][i+1]
	var c: float = h[j+1][i]
	var d: float = h[j+1][i+1]
	var y: float
	if u+v <= 1.0:
		y = a+(b-a)*u+(c-a)*v
	else:
		y = d+(c-d)*(1-u)+(b-d)*(1-v)
	# Raised ford deck exported by Blender, not a gameplay terrain rule.
	if absf(z-ford_z) <= 1.05 and absf(x-(river_center+1.4*sin(ford_z*.25))) <= 2.2:
		y = maxf(y,.14)
	return y

func terrain(c: Vector2i) -> String:
	if valid(c) and c.y < terrain_cells.size():
		var row: Array = terrain_cells[c.y]
		if c.x < row.size():
			return String(row[c.x])
	var p := world(c)
	if absf(p.x-(river_center+1.4*sin(p.z*.25))) < 2.6:
		return "ford" if c.y == ford_row else "river"
	if (p.x<6 and p.z>11) or (p.x>54.0-12 and p.z<9):
		return "forest"
	return "hill" if p.y>1.5 else "plain"
