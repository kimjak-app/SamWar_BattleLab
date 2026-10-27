extends Node3D

const Board = preload("res://scripts/battle3d/lab_heightfield.gd")
const MockPort = preload("res://scripts/battle3d/lab_demo_port.gd")
const TerrainBuilder = preload("res://scripts/battle3d/terrain_board_builder.gd")
const OUTER_GROUND = preload("res://assets/terrain_textures_pack/outer_ground_B20.png")
const EdgeScroll = preload("res://scripts/battle3d/battle3d_edge_scroll.gd")
# HUD block 4-4: the orthographic zoom range (wheel); beyond 42 the painted ground ends in an oval and the haze shows.
const ZOOM_MIN := 20.0
const ZOOM_MAX := 42.0
signal edge_scrolled # block 4-4: the camera moved by the edge scroll this frame (the shell treats it as manual camera input)
static var edge_scroll_enabled := true # block 4-4: the option (this session only; no option is saved yet)
# HUD block 4-6: the debug text (unit info labels, the control help; the engine lab adds its turn, momentum and unit state
# lines) is hidden by default, F3 shows it again (this session only). Hidden, never removed: nodes and texts stay.
static var debug_text_visible := false
var help_label: Label
var edge_mouse := Vector2(-1, -1) # the last mouse position seen (from motion events; unknown = no edge scroll)
var mouse_in_window := true
var board = Board.new()
var port = MockPort.new()
var camera := Camera3D.new()
var focus := Vector3(board.PLAY_SIZE.x*board.CELL*.5,0,board.PLAY_SIZE.y*board.CELL*.5) # block 7: the play area's centre (camera limits are the play area)
var yaw := 0.32
var zoom := ZOOM_MAX # block 4-4: was 60, now the zoom-out limit
var selected := ""
var views: Dictionary = {}
var soldiers: Dictionary = {}
var ring: MeshInstance3D
var route_view := Node3D.new()
var grid_view := Node3D.new()
var info: Label
var status: Label
var hover: Label
var active_path: Array = []
var moving_id := ""
var segment := 1
var captures := 0
var log_file: FileAccess

func _ready() -> void:
	log_file=FileAccess.open(ProjectSettings.globalize_path("res://").path_join("../EASTWAR_C0C3_Evidence/runtime_events.jsonl").simplify_path(),FileAccess.WRITE)
	port.board=board
	port.move_accepted.connect(_move_accepted)
	var field = TerrainBuilder.new()
	field.outer_ground_texture = OUTER_GROUND # block 8: the painted ground outside the play area (empty = a grey placeholder)
	field.play_cells = board.PLAY_SIZE # block 4-4: the builder's border line and outside fade use the one play area definition
	field.setup_from_board(board)
	add_child(field)
	_add_ground_collision(field)
	var env := WorldEnvironment.new()
	env.environment=Environment.new()
	env.environment.background_mode=Environment.BG_COLOR
	env.environment.background_color=Color("8d897a") # block 8: = the builder's haze_color, so the ground fades into the sky
	env.environment.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color=Color("c7d8e4")
	env.environment.ambient_light_energy=.35
	env.environment.tonemap_mode=Environment.TONE_MAPPER_LINEAR
	add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees=Vector3(-55,-30,0)
	sun.light_energy=.8
	sun.shadow_enabled=true
	sun.shadow_bias=.08
	sun.shadow_normal_bias=1.2
	sun.directional_shadow_max_distance=100
	add_child(sun)
	camera.projection=Camera3D.PROJECTION_ORTHOGONAL
	camera.far=200
	add_child(camera)
	_update_camera()
	add_child(route_view)
	add_child(grid_view)
	for u in port.units: _spawn_unit(u)
	ring=_disc(1.27,Color("ffd575"),.035)
	add_child(ring)
	ring.visible=false
	_build_grid()
	_build_ui()
	_event("ready",{"units":views.size(),"grid":"%dx%d square" % [board.PLAY_SIZE.x,board.PLAY_SIZE.y],"renderer":"gl_compatibility"})

func _event(kind: String, data: Dictionary) -> void:
	data["event"]=kind
	data["milliseconds"]=Time.get_ticks_msec()
	print(JSON.stringify(data))
	if log_file:
		log_file.store_line(JSON.stringify(data))
		log_file.flush()

func _add_ground_collision(n: Node) -> void:
	if n is MeshInstance3D and (n.name=="Terrain" or n.name=="Ford"):
		# Avoid shadow-map acne on the continuous heightfield in Compatibility.
		n.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		n.create_trimesh_collision()
	for child in n.get_children(): _add_ground_collision(child)

func _material(color: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color=color
	m.roughness=.85
	return m

func _disc(radius: float,color: Color,depth: float) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius=radius
	mesh.bottom_radius=radius
	mesh.height=depth
	mesh.radial_segments=48
	n.mesh=mesh
	n.material_override=_material(color)
	return n

func _spawn_unit(u: Dictionary) -> void:
	var root := Node3D.new()
	root.name=u.unit_id
	root.position=board.world(u.grid_cell)
	add_child(root)
	views[u.unit_id]=root
	soldiers[u.unit_id]=[]
	var cavalry: bool = u.unit_type=="cavalry"
	var model: PackedScene=load("res://assets/battle3d/%s_%s.glb" % [u.side,u.unit_type])
	for row in range(2):
		for col in range(3):
			var soldier = model.instantiate()
			root.add_child(soldier)
			soldier.position=Vector3((col-1)*.65,0,(row-.5)*(.95 if cavalry else .7))
			soldiers[u.unit_id].append(soldier)
	var base := _disc(1.05,Color("286496") if u.side=="ally" else Color("a3402a"),.04)
	root.add_child(base)
	base.position.y=.035
	var label := Label3D.new()
	label.text="%s  |  %s\n%s" % [u.unit_id,u.unit_type,u.current_troops]
	label.font_size=48
	label.pixel_size=.009
	label.position=Vector3(0,2.5,0)
	label.billboard=BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test=true
	label.set_meta("unit_info",true) # block 4-6: debug text
	label.visible=debug_text_visible
	root.add_child(label)
	var pick := StaticBody3D.new()
	pick.collision_layer=2
	pick.set_meta("unit_id",u.unit_id)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size=Vector3(2.4,2.4,2.4)
	shape.shape=box
	shape.position.y=1
	pick.add_child(shape)
	root.add_child(pick)
	_ground_soldiers(u.unit_id)

func _ground_soldiers(id: String) -> void:
	for s in soldiers[id]:
		var p: Vector3=s.global_position
		s.global_position.y=board.height(p.x,p.z)+.035

func _line(points: PackedVector3Array, color: Color, parent: Node3D) -> void:
	var mesh := ImmediateMesh.new()
	mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
	for p in points: mesh.surface_add_vertex(p)
	mesh.surface_end()
	var n := MeshInstance3D.new()
	n.mesh=mesh
	var m := _material(color)
	m.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
	n.material_override=m
	parent.add_child(n)

func data_extent(axis: int) -> float:
	return board.PLAY_SIZE.y*board.CELL if axis==0 else board.PLAY_SIZE.x*board.CELL # block 7: grid lines over the play area only

func _build_grid() -> void:
	for axis in range(2):
		for k in range(board.PLAY_SIZE.x+1 if axis==0 else board.PLAY_SIZE.y+1):
			var points := PackedVector3Array()
			for t in range(int(data_extent(axis)/.5)+1):
				var x: float=k*board.CELL if axis==0 else t*.5
				var z: float=t*.5 if axis==0 else k*board.CELL
				points.append(Vector3(x,maxf(board.height(x,z),.03)+.05,z))
			_line(points,Color("718365"),grid_view)

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var panel := PanelContainer.new()
	panel.position=Vector2(22,20)
	panel.custom_minimum_size=Vector2(440,0)
	panel.mouse_filter=Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color=Color(.035,.065,.09,.94)
	style.content_margin_left=20
	style.content_margin_right=20
	style.content_margin_top=14
	style.content_margin_bottom=14
	style.border_width_left=3
	style.border_color=Color("e4b862")
	panel.add_theme_stylebox_override("panel",style)
	layer.add_child(panel)
	var box := VBoxContainer.new()
	box.mouse_filter=Control.MOUSE_FILTER_IGNORE
	panel.add_child(box)
	var title := Label.new()
	title.text="EASTWAR   /   FIELD LAB 01"
	title.add_theme_font_size_override("font_size",24)
	title.modulate=Color("efca80")
	box.add_child(title)
	var sub := Label.new()
	sub.text="3D PRESENTATION PROTOTYPE   ·   %d × %d" % [board.PLAY_SIZE.x,board.PLAY_SIZE.y]
	sub.add_theme_font_size_override("font_size",13)
	box.add_child(sub)
	info=Label.new()
	info.text="Select a blue formation to inspect and move."
	box.add_child(info)
	status=Label.new()
	status.text="READY  /  Mock data · No combat or AI"
	status.modulate=Color("a9c1b0")
	box.add_child(status)
	var help := Label.new()
	help.position=Vector2(24,710)
	help.text="LMB  Select / move     RMB  Clear selection     Wheel  Zoom\nWASD / Arrows  Pan     Q / E  Orbit     Middle drag  Orbit\nG  Grid     Home  Reset camera     F12  Save screenshot\nRiver crossing: stone ford in row 5. Terrain rules are LAB ONLY."
	help.add_theme_font_size_override("font_size",16)
	layer.add_child(help)
	help_label=help
	help.visible=debug_text_visible # block 4-6: debug text
	hover=Label.new()
	hover.position=Vector2(24,680)
	hover.modulate=Color("efca80")
	layer.add_child(hover)

func _update_camera() -> void:
	camera.size=zoom
	camera.position=focus+Vector3(sin(yaw)*43,40,cos(yaw)*43)
	camera.look_at(focus)

func _process(delta: float) -> void:
	var pan := Vector2(float(Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT))-float(Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT)),float(Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN))-float(Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP)))
	var edge := Vector2.ZERO
	if pan.length()==0 and _edge_scroll_allowed(): # block 4-4: the keys win; else the edge scroll, on the same pan path
		edge = EdgeScroll.direction(edge_mouse,get_viewport().get_visible_rect().size)*EdgeScroll.EDGE_SPEED_SCALE
		pan = edge
	if pan.length()>0:
		focus+=Vector3(pan.x*cos(yaw)+pan.y*sin(yaw),0,-pan.x*sin(yaw)+pan.y*cos(yaw))*delta*zoom*.45
		focus.x=clampf(focus.x,0,board.PLAY_SIZE.x*board.CELL)
		focus.z=clampf(focus.z,0,board.PLAY_SIZE.y*board.CELL)
		yaw+=delta*(float(Input.is_physical_key_pressed(KEY_Q))-float(Input.is_physical_key_pressed(KEY_E)))
		if edge.length()>0: edge_scrolled.emit()
	_update_camera()
	if not moving_id.is_empty():
		var root: Node3D=views[moving_id]
		var goal: Vector3=board.world(active_path[segment])
		var flat := Vector3(root.position.x,0,root.position.z)
		var next := flat.move_toward(Vector3(goal.x,0,goal.z),delta*5)
		var direction := Vector3(goal.x,0,goal.z)-flat
		if direction.length()>.01:
			# Keep formation offsets stable; each soldier turns toward travel.
			for s in soldiers[moving_id]: s.rotation.y=atan2(-direction.x,-direction.z)
		root.position=Vector3(next.x,board.height(next.x,next.z),next.z)
		_ground_soldiers(moving_id)
		if next.distance_to(Vector3(goal.x,0,goal.z))<.01:
			segment+=1
			if segment>=active_path.size():
				port.acknowledge_presentation(moving_id,active_path[-1])
				_event("move_completed",{"unit_id":moving_id,"cell":[active_path[-1].x,active_path[-1].y],"height":root.position.y})
				moving_id=""
				status.text="ARRIVED  /  Select another destination"
				_refresh_info()
	if selected!="": ring.position=views[selected].position+Vector3(0,.09,0)

func _apply_debug_text() -> void:
	# Block 4-6: show or hide the debug text (visibility only; the texts keep updating).
	if help_label: help_label.visible=debug_text_visible
	for id in views:
		for child in views[id].get_children():
			if child is Label3D and child.has_meta("unit_info"): child.visible=debug_text_visible

func _edge_scroll_allowed() -> bool:
	# Block 4-4: not over a HUD control, not with the window unfocused or the mouse outside it, not when switched off.
	# The engine lab adds its input locks.
	return edge_scroll_enabled and mouse_in_window and get_window().has_focus() and get_viewport().gui_get_hovered_control()==null

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion: edge_mouse=event.position # block 4-4: seen before any HUD control takes it

func _notification(what: int) -> void:
	if what==NOTIFICATION_WM_MOUSE_EXIT: mouse_in_window=false
	elif what==NOTIFICATION_WM_MOUSE_ENTER: mouse_in_window=true

func _pick(pos: Vector2,mask: int) -> Dictionary:
	var origin := camera.project_ray_origin(pos)
	var query := PhysicsRayQueryParameters3D.create(origin,origin+camera.project_ray_normal(pos)*200,mask)
	return get_world_3d().direct_space_state.intersect_ray(query)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index==MOUSE_BUTTON_WHEEL_UP or event.button_index==MOUSE_BUTTON_WHEEL_DOWN:
			zoom=clampf(zoom+(-3 if event.button_index==MOUSE_BUTTON_WHEEL_UP else 3),ZOOM_MIN,ZOOM_MAX)
			_update_camera()
			_event("camera_zoom",{"size":zoom})
		elif event.button_index==MOUSE_BUTTON_RIGHT and not port.busy:
			selected=""
			ring.visible=false
			_refresh_info()
		elif event.button_index==MOUSE_BUTTON_LEFT: _click_world(event.position)
	if event is InputEventMouseMotion:
		if event.button_mask & MOUSE_BUTTON_MASK_MIDDLE:
			yaw-=event.relative.x*.008
		var hit := _pick(event.position,1)
		if not hit.is_empty():
			var c: Vector2i=board.cell_at(hit.position)
			if board.valid(c): hover.text="CELL (%d, %d)   /   %s   /   elevation %.2f m" % [c.x,c.y,board.terrain(c).to_upper(),board.world(c).y]
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode==KEY_G: grid_view.visible=not grid_view.visible
		if event.keycode==KEY_F3: # block 4-6: the debug text on/off
			debug_text_visible=not debug_text_visible
			_apply_debug_text()
		if event.keycode==KEY_HOME:
			focus=Vector3(board.PLAY_SIZE.x*board.CELL*.5,0,board.PLAY_SIZE.y*board.CELL*.5)
			yaw=.32
			zoom=ZOOM_MAX # block 4-4: was 60
		if event.keycode==KEY_F12: _capture()
		if event.keycode in [KEY_Q,KEY_E]:
			yaw+=.12 if event.keycode==KEY_Q else -.12
		if event.keycode in [KEY_W,KEY_A,KEY_S,KEY_D,KEY_UP,KEY_LEFT,KEY_DOWN,KEY_RIGHT]:
			var dx := -1.0 if event.keycode in [KEY_A,KEY_LEFT] else (1.0 if event.keycode in [KEY_D,KEY_RIGHT] else 0.0)
			var dz := -1.0 if event.keycode in [KEY_W,KEY_UP] else (1.0 if event.keycode in [KEY_S,KEY_DOWN] else 0.0)
			focus+=Vector3(dx*cos(yaw)+dz*sin(yaw),0,-dx*sin(yaw)+dz*cos(yaw))*.5
			focus.x=clampf(focus.x,0,board.PLAY_SIZE.x*board.CELL)
			focus.z=clampf(focus.z,0,board.PLAY_SIZE.y*board.CELL)
		_update_camera()
		if event.keycode in [KEY_Q,KEY_E,KEY_W,KEY_A,KEY_S,KEY_D]: _event("camera_key",{"key":event.as_text(),"yaw":yaw,"focus":[focus.x,focus.z]})

func _click_world(pos: Vector2) -> void:
	if port.busy: return
	var hit := _pick(pos,2)
	if not hit.is_empty():
		var id: String=hit.collider.get_meta("unit_id")
		if port.by_id(id).side!="ally":
			status.text="ENEMY  /  Inspection only · Combat disabled"
			return
		selected=id
		ring.visible=true
		_refresh_info()
		_event("unit_selected",{"unit_id":id,"source":"mouse_ray"})
		return
	hit=_pick(pos,1)
	if selected=="" or hit.is_empty(): return
	var c: Vector2i=board.cell_at(hit.position)
	if not port.request_move(selected,c):
		status.text="BLOCKED  /  River, occupied cell or map boundary"
		_event("move_rejected",{"cell":[c.x,c.y]})

func _refresh_info() -> void:
	if selected=="":
		info.text="Select a blue formation to inspect and move."
		return
	var u: Dictionary=port.by_id(selected)
	info.text="%s   /   %s\nTroops %s   ·   6 visual soldiers   ·   Cell %s" % [u.unit_id,u.unit_type,u.current_troops,u.grid_cell]

func _move_accepted(id: String,path: Array) -> void:
	active_path=path
	moving_id=id
	segment=1
	for child in route_view.get_children(): child.queue_free()
	var points := PackedVector3Array()
	for c in path:
		var p: Vector3=board.world(c)
		points.append(p+Vector3(0,.16,0))
		var dot := _disc(.14,Color("ffd575"),.06)
		route_view.add_child(dot)
		dot.position=p+Vector3(0,.15,0)
	_line(points,Color("ffe2a1"),route_view)
	status.text="MOVING  /  %d orthogonal steps" % (path.size()-1)
	_event("move_accepted",{"unit_id":id,"steps":path.size()-1})

func _capture() -> void:
	await RenderingServer.frame_post_draw
	captures+=1
	var path := ProjectSettings.globalize_path("res://").path_join("../EASTWAR_C0C3_Evidence/godot_%d_%02d.png" % [OS.get_process_id(),captures]).simplify_path()
	get_viewport().get_texture().get_image().save_png(path)
	_event("screenshot",{"path":path})
