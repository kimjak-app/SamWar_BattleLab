extends SceneTree
# Block 7 test 3: a unit's foot height (board.world / board.height, what the lab places units at) equals the ground mesh
# the player sees, measured by a physics ray straight down onto the game lab's own Terrain + Ford collision (mask 1). Points:
# all 400 board cell centres, 600 seeded random points over the board, and every engine unit's view position.
const TOLERANCE := 0.001
var h

func _initialize() -> void:
	run.call_deferred()

func ground(space: PhysicsDirectSpaceState3D, x: float, z: float) -> Variant:
	var hit := space.intersect_ray(PhysicsRayQueryParameters3D.create(Vector3(x, 60.0, z), Vector3(x, -10.0, z), 1))
	return null if hit.is_empty() else hit.position.y

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_scenario_harness.gd").new()
	await h.open_shell(self)
	await h.press_scenario(self, "default")
	var lab = h.lab
	var board = lab.board
	await physics_frame
	await physics_frame
	var space: PhysicsDirectSpaceState3D = lab.get_world_3d().direct_space_state
	var points := []
	for y in range(board.SIZE.y):
		for x in range(board.SIZE.x): points.append(Vector2((x + .5) * board.CELL, (y + .5) * board.CELL))
	var rng := RandomNumberGenerator.new()
	rng.seed = 20261026
	for i in range(600): points.append(Vector2(rng.randf_range(0.01, board.SIZE.x * board.CELL - .01), rng.randf_range(0.01, board.SIZE.y * board.CELL - .01)))
	var worst := 0.0
	var misses := []
	var bad := []
	for p in points:
		var y = ground(space, p.x, p.y)
		if y == null:
			misses.append(p)
			continue
		var d := absf(float(y) - board.height(p.x, p.y))
		worst = maxf(worst, d)
		if d > TOLERANCE: bad.append([p, y, board.height(p.x, p.y)])
	h.expect(misses.is_empty(), "every point hits the ground mesh (misses %s)" % str(misses.slice(0, 5)))
	h.expect(bad.is_empty(), "%d points: mesh height = board.height within %s m (worst %.8f; differences %s)" % [points.size(), TOLERANCE, worst, str(bad.slice(0, 5))])
	var feet := []
	for id in lab.views:
		var at: Vector3 = lab.views[id].position
		var y = ground(space, at.x, at.z)
		if y == null or absf(float(y) - at.y) > TOLERANCE: feet.append([id, at, y])
	h.expect(lab.views.size() > 0 and feet.is_empty(), "%d engine units stand on the mesh (differences %s)" % [lab.views.size(), str(feet)])
	await h.close_shell(self)
	print("[BLOCK7_FOOT_HEIGHT] checks=", h.checks, " failures=", h.failures, " points=", points.size(), " worst=", worst)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
