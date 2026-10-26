extends SceneTree
const GridProjection = preload("res://scripts/battle3d/battle3d_grid_projection.gd")
const TerrainBuilder = preload("res://scripts/battle3d/terrain_board_builder.gd")
var checks := 0
var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func expect(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", label)

# Independent visibility oracle, matching the existing occlusion test's 0.02
# world-unit heightfield sampling. Never ask the method under test if visible.
# Block 7: the whole 20x20 board's ground occludes (scenery included), not only the play area.
func occluded(projection: Node, origin: Vector3, point: Vector3, cell: Vector2i) -> bool:
	var distance := origin.distance_to(point)
	var direction := origin.direction_to(point)
	for sample in range(1, int(distance / 0.02)):
		var p := origin + direction * sample * 0.02
		var c: Vector2i = projection.heightfield.cell_at(p)
		if projection.heightfield.on_board(c) and p.y <= projection.heightfield.height(p.x, p.z):
			return c != cell
	return false

func flat_cell(projection: Node, origin: Vector3, direction: Vector3) -> Vector2i:
	if absf(direction.y) < 0.000001:
		return Vector2i(-1,-1)
	var t := -origin.y / direction.y
	if t < 0:
		return Vector2i(-1,-1)
	var cell: Vector2i = projection.heightfield.cell_at(origin + direction * t)
	return cell if projection.is_in_bounds(cell) else Vector2i(-1,-1)

func _run() -> void:
	# Fix the viewport explicitly: headless root window sizes vary by platform.
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1920,1080)
	viewport.own_world_3d = true
	root.add_child(viewport)
	var stage := Node3D.new()
	viewport.add_child(stage)
	var projection := GridProjection.new()
	stage.add_child(projection)
	var terrain = TerrainBuilder.new() # block 7: the 20x20 board the lab builds (battlefield.glb is the old 18x10 ground)
	terrain.setup_from_board(projection.heightfield)
	stage.add_child(terrain)
	GridProjection.attach_surface_collisions(terrain)
	projection.world_3d = stage.get_world_3d()
	var camera := Camera3D.new()
	stage.add_child(camera)
	# lab_presentation.gd:8-10,50-51,210-213,252. No top-down substitute.
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.far = 200
	camera.current = true
	var play: Vector2i = projection.heightfield.PLAY_SIZE # block 7: the lab's focus is the play area's centre
	var focus := Vector3(play.x * projection.heightfield.CELL * 0.5, 0,
		play.y * projection.heightfield.CELL * 0.5)
	await physics_frame
	await physics_frame
	var total_visible := 0
	var total_flat_differences := 0
	for yaw in [0.32, 0.0, 0.8]:
		for zoom in [24.0, 40.0, 60.0]:
			camera.size = zoom
			camera.position = focus + Vector3(sin(yaw)*43,40,cos(yaw)*43)
			camera.look_at(focus)
			var visible := 0
			var passed := 0
			var flat_differences := 0
			var outside := 0
			var hidden := 0
			for x in range(play.x):
				for y in range(play.y):
					var cell := Vector2i(x,y)
					var point: Vector3 = projection.grid_to_world_3d(cell)
					var screen := camera.unproject_position(point)
					if camera.is_position_behind(point) or not Rect2(Vector2.ZERO,Vector2(viewport.size)).has_point(screen):
						outside += 1
						continue
					var origin := camera.project_ray_origin(screen)
					var direction := camera.project_ray_normal(screen)
					if occluded(projection,origin,point,cell):
						hidden += 1
						continue
					visible += 1
					var got: Vector2i = projection.world_to_grid_from_ray(origin,direction)
					expect(got==cell,"oblique yaw=%.2f zoom=%.0f cell=%s got=%s" % [yaw,zoom,cell,got])
					if got==cell: passed += 1
					if flat_cell(projection,origin,direction)!=cell: flat_differences += 1
			# Reject vacuous coverage and ensure every camera setup catches flat rays.
			expect(visible>0,"nonempty visible coverage")
			expect(flat_differences>0,"terrain-sensitive coverage per camera")
			expect(visible+outside+hidden==play.x*play.y,"all cells classified")
			total_visible += visible
			total_flat_differences += flat_differences
			print("[OBLIQUE_CAMERA] yaw=%.2f zoom=%.0f visible=%d passed=%d flat_different=%d outside=%d occluded=%d" % [yaw,zoom,visible,passed,flat_differences,outside,hidden])
	expect(total_flat_differences>0,"flat plane mutation detectable")
	viewport.queue_free()
	await process_frame
	print("[BATTLE3D_OBLIQUE] %s: %d checks, %d failures; cameras=9; visible=%d; flat_different=%d" % ["PASS" if failures==0 else "FAIL",checks,failures,total_visible,total_flat_differences])
	quit(0 if failures==0 else 1)
