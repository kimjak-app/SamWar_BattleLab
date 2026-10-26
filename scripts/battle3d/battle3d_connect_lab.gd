extends "res://scripts/battle3d/lab_presentation.gd"
const UnitAdapter=preload("res://scripts/battle3d/battle3d_unit_adapter.gd")
const GridProjection=preload("res://scripts/battle3d/battle3d_grid_projection.gd")
const Queries=preload("res://scripts/battle3d/battle3d_movement_adapter.gd")
var projection=GridProjection.new()
var queries=Queries.new()
var query_mode := true
var terrain_rules_enabled := false
var range_view := Node3D.new()
var terrain_view := Node3D.new()
var mode_label: Label

func _ready() -> void:
	super._ready()
	DisplayServer.window_set_title("EASTWAR | Engine Query C0-C3 (18x10)")
	add_child(projection)
	projection.world_3d=get_world_3d()
	queries.grid=projection
	for demo in port.units:
		var payload: Dictionary=demo.duplicate(true)
		payload["max_troops"]=demo.current_troops
		payload["current_hp"]=demo.current_troops
		queries.alive_units.append(UnitAdapter.create_fixture(payload))
	add_child(range_view)
	add_child(terrain_view)
	mode_label=Label.new()
	mode_label.position=Vector2(24,190)
	mode_label.add_theme_font_size_override("font_size",18)
	mode_label.modulate=Color("86dbfa")
	var layer := CanvasLayer.new()
	add_child(layer)
	layer.add_child(mode_label)
	set_query_mode(true)
	if "--capture-connect" in OS.get_cmdline_user_args(): _capture_connect.call_deferred()

func _clear_visuals(parent: Node) -> void:
	for child in parent.get_children():
		parent.remove_child(child)
		child.queue_free()

func set_query_mode(enabled: bool) -> void:
	# Cancel the copied demo's frame-driven motion before rebuilding from engine state.
	moving_id=""
	active_path.clear()
	segment=1
	port.busy=false
	query_mode=enabled
	terrain_rules_enabled=false
	selected=""
	ring.visible=false
	_clear_visuals(route_view)
	_clear_visuals(range_view)
	_clear_visuals(terrain_view)
	for unit in queries.alive_units:
		port.by_id(unit.unit_id).grid_cell=unit.grid_cell
		views[unit.unit_id].position=projection.grid_to_world_3d(unit.grid_cell)
		_ground_soldiers(unit.unit_id)
	_refresh_info()
	_update_mode_text()
	status.text="ENGINE QUERY / Select ally, then preview a destination" if enabled else "DEMO ONLY / Moves visual fixtures, never engine state"

func _update_mode_text() -> void:
	mode_label.text=("ENGINE QUERY  |  NO MOVE EXECUTION" if query_mode else "LAB DEMO  |  ENGINE HIGHLIGHTS OFF")+"\nTab: switch mode   T: terrain annotation (%s)" % ("ON" if terrain_rules_enabled else "OFF")
	for layer in get_children():
		if layer is CanvasLayer:
			for control in layer.get_children():
				if control is Label and control.text.begins_with("LMB"):
					var lines: PackedStringArray=control.text.split("\n")
					lines[0]="LMB  Select / preview ONLY     RMB  Clear     Wheel  Zoom" if query_mode else "LMB  Select / demo move     RMB  Clear     Wheel  Zoom"
					control.text="\n".join(lines)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode==KEY_TAB:
			set_query_mode(not query_mode)
			return
		if event.keycode==KEY_T:
			terrain_rules_enabled=not terrain_rules_enabled
			_update_mode_text()
			_show_terrain_annotations()
			return
	if query_mode and event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_RIGHT:
		_clear_visuals(range_view)
		_clear_visuals(route_view)
	super._unhandled_input(event)

func _show_terrain_annotations() -> void:
	_clear_visuals(terrain_view)
	if not terrain_rules_enabled: return
	for x in range(board.PLAY_SIZE.x): # block 7: annotations over the play area only
		for y in range(board.PLAY_SIZE.y):
			var c := Vector2i(x,y)
			if board.terrain(c)=="river":
				var dot := _disc(.15,Color("d69b74"),.05)
				terrain_view.add_child(dot)
				dot.position=board.world(c)+Vector3(0,.45,0)
	# Decoration only. This flag is never passed to Queries or engine services.

func _click_world(pos: Vector2) -> void:
	if not query_mode:
		super._click_world(pos)
		return
	var pick := _pick(pos,2)
	if not pick.is_empty():
		var id: String=pick.collider.get_meta("unit_id")
		if queries.find_unit(id).side!="ally": return
		select_engine_unit(id)
		return
	if selected.is_empty(): return
	var cell: Vector2i=projection.world_to_grid_from_ray(camera.project_ray_origin(pos),camera.project_ray_normal(pos))
	preview_cell(cell)

func select_engine_unit(id: String) -> void:
	selected=id
	ring.visible=true
	_refresh_info()
	_clear_visuals(range_view)
	_clear_visuals(route_view)
	var result: Dictionary=queries.query(id,queries.find_unit(id).grid_cell)
	for cell in result.reachable:
		var p: Vector3=projection.grid_to_world_3d(cell)
		var dot := _disc(.65,Color("397c8c"),.025)
		range_view.add_child(dot)
		dot.position=p+Vector3(0,.12,0)
	status.text="ENGINE / Move budget %d / %d reachable cells" % [result.budget,result.reachable.size()]

func preview_cell(cell: Vector2i) -> void:
	_clear_visuals(route_view)
	var result: Dictionary=queries.query(selected,cell)
	if result.is_empty() or not result.can_preview:
		status.text="ENGINE / Destination not reachable"
		return
	var points := PackedVector3Array()
	for i in range(result.path.size()-1):
		var a: Vector3=projection.grid_to_world_3d(result.path[i])
		var b: Vector3=projection.grid_to_world_3d(result.path[i+1])
		for sample in range(13):
			var p := a.lerp(b,sample/12.0)
			p.y=board.height(p.x,p.z)+.25
			points.append(p)
	if points.size()<2: return
	_line(points,Color("ffe2a1"),route_view)
	status.text="ENGINE PREVIEW / %d steps / state unchanged" % (result.path.size()-1)

func _capture_connect() -> void:
	await get_tree().create_timer(1).timeout
	select_engine_unit("lab_ally_01")
	preview_cell(Vector2i(3,3))
	await _capture()
	select_engine_unit("lab_ally_02")
	preview_cell(Vector2i(5,2))
	await _capture()
	get_tree().quit()
