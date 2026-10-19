extends "res://scripts/battle3d/lab_presentation.gd"
const Adapter = preload("res://scripts/battle3d/battle3d_unit_adapter.gd")
const GridProjection = preload("res://scripts/battle3d/battle3d_grid_projection.gd")
const Queries = preload("res://scripts/battle3d/battle3d_movement_adapter.gd")
const Host = preload("res://scripts/battle3d/battle3d_engine_host.gd")
var host = Host.new()
var engine: Node
var projection = GridProjection.new()
var queries = Queries.new()
var display_values := {}
var range_view := Node3D.new()
var facing_ui: HBoxContainer
var ready_for_input := false
var event_cursor := 0
var playback := {}
var played_paths: Array = []
var animation_starts := 0
var rejected := 0
var presentation_speed := 8.0

func _ready() -> void:
	# Reuse original terrain, models, formation, camera and lighting without fixtures.
	port.units.clear()
	super._ready()
	add_child(host)
	engine = host.battle
	add_child(projection)
	projection.world_3d = get_world_3d()
	queries.grid = engine.get("battle_grid_controller")
	add_child(range_view)
	for unit in engine.get("all_battle_unit_states"):
		queries.alive_units.append(unit)
		var value: Dictionary = Adapter.to_view(unit)
		var model_value := value.duplicate(true)
		if model_value.unit_type not in ["infantry","cavalry"]: model_value.unit_type = "infantry"
		_spawn_unit(model_value)
	_build_facing_ui()
	camera.make_current()
	DisplayServer.window_set_title("EASTWAR | M1-b Engine Move 18x10")
	await host.initialized
	ready_for_input = true
	_sync_views()
	status.text = "Select ally / click destination / choose facing / RMB cancel"

func _build_ui() -> void:
	super._build_ui()
	for layer in get_children():
		if layer is CanvasLayer:
			for child in layer.get_children():
				if child is Label and child.text.begins_with("LMB"):
					child.text = "LMB Select / move | RMB Cancel | Wheel Zoom | WASD Pan | Q/E Orbit\nM1-b: movement only. Attack / enemy turn not connected."

func _build_facing_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	facing_ui = HBoxContainer.new()
	facing_ui.position = Vector2(24,210)
	layer.add_child(facing_ui)
	for direction in ["left","up","down","right"]:
		var button := Button.new()
		button.text = "Confirm " + direction
		button.pressed.connect(confirm_facing.bind(direction))
		facing_ui.add_child(button)

func _process(delta: float) -> void:
	if not ready_for_input: return
	super._process(delta) # moving_id stays empty; no mock movement executes.
	_consume_events()
	for id in playback.keys():
		var motion: Dictionary = playback[id]
		var goal: Vector3 = board.world(motion.path[motion.index])
		var root: Node3D = views[id]
		var next := Vector3(root.position.x,0,root.position.z).move_toward(Vector3(goal.x,0,goal.z),delta*presentation_speed)
		root.position = Vector3(next.x,board.height(next.x,next.z),next.z)
		_ground_soldiers(id)
		if next.distance_to(Vector3(goal.x,0,goal.z)) < .01:
			motion.index += 1
			if motion.index >= motion.path.size(): playback.erase(id)
	_sync_views()

func _consume_events() -> void:
	var events: Array = engine.get("ally_move_event_log").export()
	while event_cursor < events.size():
		var event: Dictionary = events[event_cursor]
		event_cursor += 1
		if event.kind == "unit_moved":
			var path: Array = []
			for cell in event.path: path.append(Vector2i(cell[0],cell[1]))
			played_paths.append(event.path.duplicate(true))
			playback[event.unit_id] = {"path":path,"index":1}
			views[event.unit_id].position = board.world(path[0])
			animation_starts += 1
		elif event.kind == "move_reverted":
			playback.erase(event.unit_id)

func _sync_views() -> void:
	for unit in queries.alive_units:
		var value: Dictionary = Adapter.to_view(unit)
		display_values[value.unit_id] = value
		var root: Node3D = views[value.unit_id]
		if not playback.has(value.unit_id):
			root.position = board.world(value.grid_cell)
			_ground_soldiers(value.unit_id)
		for soldier in soldiers[value.unit_id]:
			soldier.rotation.y = {"up":0.0,"down":PI,"left":PI/2,"right":-PI/2}.get(value.facing,0.0)
		for child in root.get_children():
			if child is Label3D: child.text = "%s | %s\n%s" % [value.unit_id,value.unit_type,value.current_troops]
	facing_ui.visible = engine.get("current_phase") == "facing_select"
	var active = engine.get("active_unit_state")
	selected = active.unit_id if active != null else ""
	ring.visible = not selected.is_empty()
	_refresh_info()

func _refresh_info() -> void:
	if not ready_for_input or selected.is_empty(): return
	var value: Dictionary = display_values.get(selected,{})
	if value.is_empty(): return
	info.text = "%s / %s / Troops %s\nCell %s / Phase %s" % [selected,value.unit_type,value.current_troops,value.grid_cell,engine.get("current_phase")]

func _clear_range() -> void:
	for child in range_view.get_children():
		range_view.remove_child(child)
		child.queue_free()

func _reject() -> void:
	rejected += 1
	status.text = "REJECTED / Engine phase, unit or destination unavailable"

func _click_world(pos: Vector2) -> void:
	if not ready_for_input: return
	if engine.get("current_phase") != "ally_turn" or engine.get("is_demo_animating"):
		_reject()
		return
	var cell: Vector2i = projection.world_to_grid_from_ray(camera.project_ray_origin(pos),camera.project_ray_normal(pos))
	var unit = null
	# Ground-cell selection avoids foreground pick boxes stealing adjacent cells.
	for candidate in queries.alive_units:
		if candidate.grid_cell == cell: unit = candidate
	if unit != null:
		if unit.side != "ally":
			_reject()
			return
		engine.call("_select_ally_unit",unit,false,false,false)
		if engine.get("active_unit_state") != unit:
			_reject()
			return
		_clear_range()
		var result: Dictionary = queries.query(unit.unit_id,unit.grid_cell)
		for reachable in result.get("reachable",{}):
			var dot := _disc(.6,Color("397c8c"),.025)
			range_view.add_child(dot)
			dot.position = board.world(reachable)+Vector3(0,.12,0)
		status.text = "SELECTED / Click destination"
	else:
		if not engine.call("_try_direct_move_to_cell",cell):
			_reject()
			return
		_clear_range()
		status.text = "ENGINE MOVING / Awaiting executed path"
	_sync_views()

func confirm_facing(direction: String) -> void:
	if engine.get("current_phase") != "facing_select":
		_reject()
		return
	engine.call("_select_post_move_facing",direction)
	_consume_events()
	_sync_views()
	status.text = "CONFIRMED / Attack and turn commands not connected"

func _unhandled_input(event: InputEvent) -> void:
	if not ready_for_input: return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		engine.call("_handle_right_click_cancel")
		_consume_events()
		_sync_views()
		_clear_range()
		status.text = "CANCEL / Engine state restored where allowed"
		return
	super._unhandled_input(event)
