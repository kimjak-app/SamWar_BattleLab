extends SceneTree
# Block 7 test 2: the play area keeps its old terrain and heights. The expectations are the fixture
# tests/data/block7_old_play_area_0dd9239.json, computed from 0dd9239's heightfield.json with 0dd9239's height()/terrain()
# (not from the code under test): the 180 play cells' types, the 180 cell-centre heights and 400 seeded random points
# over the play area, all within 1e-5 m.
# T2 (2026-10-28, 김작's grove decision) changes the forest on purpose: the old play area's forest cells become plain and
# the two groves below become forest. That change is written here (not read from the code under test); every other
# cell keeps its old type.
const Board = preload("res://scripts/battle3d/lab_heightfield.gd")
const FIXTURE := "res://tests/data/block7_old_play_area_0dd9239.json"
const TOLERANCE := 0.00001
const T2_GROVES := [Rect2i(0, 3, 2, 3), Rect2i(16, 6, 2, 3)] # x0-1 y3-5 and x16-17 y6-8
var checks := 0
var failures := 0

func _initialize() -> void:
	run.call_deferred()

func expect(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", label)

func run() -> void:
	var old: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(FIXTURE))
	var board = Board.new()
	var play := Vector2i(int(old.play_size[0]), int(old.play_size[1]))
	expect(play == Vector2i(18, 10) and board.PLAY_SIZE == play, "the old play area is 18x10 and PLAY_SIZE is %s" % board.PLAY_SIZE)
	var type_differences := []
	for y in range(play.y):
		for x in range(play.x):
			var got: String = board.terrain(Vector2i(x, y))
			var want: String = "plain" if String(old.types[y][x]) == "forest" else String(old.types[y][x])
			if T2_GROVES.any(func(r): return r.has_point(Vector2i(x, y))): want = "forest"
			if got != want: type_differences.append([Vector2i(x, y), old.types[y][x], want, got])
	expect(type_differences.is_empty(), "the 180 old play cells keep their terrain type, the T2 forest change apart (differences %s)" % str(type_differences))
	var worst := 0.0
	for set_name in ["centre_heights", "random_heights"]:
		var differences := []
		for p in old[set_name]:
			var got: float = board.height(float(p[0]), float(p[1])) # [x, z, height]
			var d := absf(got - float(p[2]))
			worst = maxf(worst, d)
			if d > TOLERANCE: differences.append([p, got])
		expect(not old[set_name].is_empty() and differences.is_empty(), "%s: %d points within %s m (differences %s)" % [set_name, old[set_name].size(), TOLERANCE, str(differences.slice(0, 8))])
	expect(old.centre_heights.size() == 180 and old.random_heights.size() == 400, "fixture sizes 180 + 400")
	# The centres are also the unit foot heights board.world() gives.
	var foot_differences := []
	for p in old.centre_heights:
		var c := Vector2i(floori(float(p[0]) / float(old.cell_size)), floori(float(p[1]) / float(old.cell_size)))
		if absf(board.world(c).y - float(p[2])) > TOLERANCE: foot_differences.append([c, board.world(c).y, p[2]])
	expect(foot_differences.is_empty(), "board.world() of the 180 play cells keeps the old foot height (differences %s)" % str(foot_differences))
	print("[BLOCK7_OLD_PLAY_AREA] %s: %d checks, %d failures; types 180, heights 180 + 400, worst %.8f m" % ["PASS" if failures == 0 else "FAIL", checks, failures, worst])
	quit(0 if failures == 0 else 1)
