extends SceneTree
const Adapter=preload("res://scripts/battle3d/battle3d_unit_adapter.gd")
const GridProjection=preload("res://scripts/battle3d/battle3d_grid_projection.gd")
const TerrainBuilder=preload("res://scripts/battle3d/terrain_board_builder.gd")
const Queries=preload("res://scripts/battle3d/battle3d_movement_adapter.gd")
const Service=preload("res://scripts/battle/services/battle_movement_query_service.gd")
# Independent contract from B3D-F1 brief, not derived from Adapter.VIEW_FIELDS.
const EXPECTED_VIEW_FIELDS := ["unit_id","side","unit_type","grid_cell","facing","current_troops","max_troops","allocated_troops","footprint","has_moved","has_acted","status_effects","move_range","attack_range"]
var _checks := 0
var _failures := 0
var scenarios := 0
var service=Service.new()
var flat := BattleGridController.new()
var projection=GridProjection.new()
var query=Queries.new()

func _initialize() -> void:
	call_deferred("_run")

func expect(ok: bool,label: String) -> void:
	_checks+=1
	if not ok:
		_failures+=1
		printerr("FAIL: ",label)

func fixture(id: String,cell: Vector2i,kind := "infantry",effects := {}) -> BattleUnitState:
	return Adapter.create_fixture({"unit_id":id,"side":"ally","unit_type":kind,"grid_cell":cell,"facing":"left","current_troops":3200,"max_troops":4000,"allocated_troops":3500,"current_hp":3200,"has_moved":false,"has_acted":false,"status_effects":effects,"move_range":999,"attack_range":999})

func fingerprint(units: Array[BattleUnitState]) -> Array:
	var result := []
	for unit in units:
		var values := {}
		for property in unit.get_property_list():
			if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
				var value: Variant=unit.get(property.name)
				values[property.name]=value.duplicate(true) if value is Dictionary or value is Array else value
		result.append(values)
	return result

func run_scenario(label: String,units: Array[BattleUnitState],breakthrough: bool) -> void:
	scenarios+=1
	query.alive_units=units
	var before := fingerprint(units)
	var mover := units[0]
	var view := Adapter.to_view(mover)
	var keys := view.keys()
	var expected_keys := EXPECTED_VIEW_FIELDS.duplicate()
	keys.sort()
	expected_keys.sort()
	expect(keys==expected_keys,label+" exact view key set")
	for key in EXPECTED_VIEW_FIELDS: expect(view.has(key) and view.get(key)==mover.get(key),label+" field "+key)
	if view.has("status_effects"):
		view.status_effects["unexpected_visual_effect"]=3
	expect(not mover.status_effects.has("unexpected_visual_effect"),label+" isolated dictionary")
	var budget: int=service.get_effective_move_range(mover)
	var expected: Dictionary=service.get_reachable_paths(mover.grid_cell,mover,budget,flat,units,breakthrough)
	for x in range(projection.heightfield.PLAY_SIZE.x): # block 7: the play area (= the flat engine grid, checked in _run)
		for y in range(projection.heightfield.PLAY_SIZE.y):
			var target := Vector2i(x,y)
			var result: Dictionary=query.query(mover.unit_id,target,breakthrough)
			expect(result.budget==budget,label+" budget")
			expect(result.reachable.size()==expected.size(),label+" reachable size")
			for cell in expected: expect(result.reachable.get(cell,[])==expected[cell],label+" ordered path "+str(cell))
			expect(result.path==service.find_move_path(mover.grid_cell,target,mover,budget,flat,units,breakthrough),label+" target path")
			expect(result.destination_valid==service.is_valid_destination_for_unit(target,mover,flat,units,breakthrough),label+" destination")
			expect(result.can_preview==(result.destination_valid and expected.has(target) and not result.path.is_empty()),label+" preview")
	expect(fingerprint(units)==before,label+" ALL state fields unchanged")
	print("SCENARIO PASS ",label," budget=",budget)

func _run() -> void:
	expect(Adapter.VIEW_FIELDS==EXPECTED_VIEW_FIELDS,"VIEW_FIELDS exact size/order/elements")
	flat.grid_width=18
	flat.grid_height=10
	expect(projection.heightfield.PLAY_SIZE==Vector2i(flat.grid_width,flat.grid_height) and projection.is_in_bounds(Vector2i(17,9)) and not projection.is_in_bounds(Vector2i(18,9)) and not projection.is_in_bounds(Vector2i(17,10)),"block 7: the play area is the 18x10 engine grid")
	query.grid=projection
	for kind in ["infantry","cavalry","archer","gunner","mounted_archer"]:
		var mover := fixture("fixture_"+kind,Vector2i(4,4),kind)
		expect(mover.move_range!=999 and mover.attack_range!=999,"setup owns ranges")
		run_scenario("empty_"+kind,[mover],false)
	for breakthrough in [false,true]:
		var mover := fixture("fixture_mover",Vector2i(4,4))
		var ally := fixture("fixture_ally",Vector2i(5,4))
		var enemy := fixture("fixture_enemy",Vector2i(4,5))
		enemy.side="enemy"
		run_scenario("blockers_"+str(breakthrough),[mover,ally,enemy],breakthrough)
	for cell in [Vector2i(0,0),Vector2i(17,9),Vector2i(0,5),Vector2i(17,0)]:
		run_scenario("edge_"+str(cell),[fixture("edge",cell)],false)
	for effects in [{"mobility_up":2},{"movement_down":2}]:
		run_scenario("status_"+str(effects),[fixture("status",Vector2i(5,5),"infantry",effects)],false)
	# An unsupported fixture type legitimately gets zero from UnitTypeContract;
	# movement_down tests clamping without assigning move_range after setup.
	var immobile := fixture("immobile",Vector2i(5,5),"fixture_zero_move",{"movement_down":1})
	expect(service.get_effective_move_range(immobile)==0,"zero clamp")
	run_scenario("zero_budget",[immobile],false)
	var boxed: Array[BattleUnitState]=[fixture("boxed",Vector2i(4,4))]
	for d in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]: boxed.append(fixture("wall_"+str(d),Vector2i(4,4)+d))
	run_scenario("enclosed",boxed,false)
	await ray_tests()
	flat.free()
	projection.free()
	print("[BATTLE3D_PARITY] %s: %d checks, %d failures; scenarios=%d; visible_rays=540" % ["PASS" if _failures==0 else "FAIL",_checks,_failures,scenarios])
	quit(0 if _failures==0 else 1)

func ray_tests() -> void:
	var stage := Node3D.new()
	root.add_child(stage)
	var terrain=TerrainBuilder.new() # block 7: the 20x20 board the lab builds (battlefield.glb is the old 18x10 ground)
	terrain.setup_from_board(projection.heightfield)
	stage.add_child(terrain)
	GridProjection.attach_surface_collisions(terrain)
	projection.world_3d=stage.get_world_3d()
	var camera := Camera3D.new()
	stage.add_child(camera)
	camera.projection=Camera3D.PROJECTION_ORTHOGONAL
	camera.position=Vector3(27,70,15)
	camera.look_at(Vector3(27,0,15),Vector3.FORWARD)
	await physics_frame
	await physics_frame
	for size in [64.0,80.0,100.0]:
		camera.size=size
		for x in range(projection.heightfield.PLAY_SIZE.x):
			for y in range(projection.heightfield.PLAY_SIZE.y):
				var cell := Vector2i(x,y)
				var point: Vector3=projection.grid_to_world_3d(cell)
				var screen := camera.unproject_position(point)
				expect(projection.world_to_grid_from_ray(camera.project_ray_origin(screen),camera.project_ray_normal(screen))==cell,"surface ray "+str(cell)+" zoom "+str(size))
	for origin in [Vector3(-10,30,-10),Vector3(65,30,40)]:
		expect(projection.world_to_grid_from_ray(origin,Vector3.DOWN)==Vector2i(-1,-1),"ray miss")
	expect(projection.world_to_grid_from_ray(Vector3.ZERO,Vector3.ZERO)==Vector2i(-1,-1),"zero ray")
	# Independent dense heightfield sampling supplies the expected first visible
	# cell; physics triangles, not a flat plane, must hit the foreground hill.
	var occlusion_cases := 0
	for origin in [Vector3(0,1.3,4.5),Vector3(10.5,1.3,24)]:
		var found := false
		for x in range(projection.heightfield.PLAY_SIZE.x):
			if found: break
			for y in range(projection.heightfield.PLAY_SIZE.y):
				var target := Vector2i(x,y)
				var point: Vector3=projection.grid_to_world_3d(target)
				var distance: float = origin.distance_to(point)
				if distance<6: continue
				var dir: Vector3 = origin.direction_to(point)
				var first := Vector2i(-1,-1)
				for sample in range(1,int(distance/.02)):
					var p: Vector3 = origin+dir*sample*.02
					var c: Vector2i=projection.heightfield.cell_at(p)
					if projection.is_in_bounds(c) and p.y<=projection.heightfield.height(p.x,p.z):
						first=c
						break
				if first==Vector2i(-1,-1) or first==target: continue
				var got: Vector2i=projection.world_to_grid_from_ray(origin,dir)
				expect(got==first and got!=target,"occluded first hit target=%s expected=%s got=%s" % [target,first,got])
				occlusion_cases+=1
				found=true
				break
	expect(occlusion_cases==2,"two distinct occluded viewpoints")
	stage.queue_free()
	await process_frame
