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
var attack_button: Button
var wait_button: Button # M3-b: the engine's existing 2D wait command, no hotkey (M6).
var target_info: Label
var combat_log: Label
var action_cursor := 0 # Independent from ally_move_event_log's event_cursor.
var attack_cells: Array[Vector2i] = []
var enemy_candidates: Array = []
var valid_target_ids: Array[String] = []
var target_id := ""
var target_defending := false # Display only; never used to calculate damage.
var damage_presentations: Array = []
var combat_lines: Array[String] = []
var enemy_summaries: Array = []
var enemy_baseline := {}
var awaiting_enemy_result := false
var target_marks := Node3D.new()
var last_phase := ""
# M3: enemy-turn playback. Third independent cursor; never merged with the
# movement (event_cursor) or ally action (action_cursor) sequences.
const WAIT_TEXT := {"wait":"대기","confused":"혼란","no_path":"경로 없음","path_blocked":"경로 막힘","no_target":"대상 없음"}
const RESULT_TEXT := {"victory":"승리","defeat":"패배"}
var enemy_cursor := 0
var enemy_queue: Array = [] # Presentation only; the engine state stays the truth.
var enemy_slot: Array = []
var enemy_played_paths: Array = []
var enemy_damage_presentations: Array = []
var enemy_texts: Array[String] = []
var enemy_actor_id := ""
var enemy_moving_id := ""
var enemy_hold := 0.0
var enemy_hold_seconds := .35
var enemy_status_active := false
var current_round := 1 # A new Battle_Main always starts at round 1; later values come from events.
var battle_result := ""
var turn_label: Label
var roster_label: Label
var result_overlay: Label
var actor_ring: MeshInstance3D
var action_badges := Node3D.new()

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
	add_child(target_marks)
	add_child(action_badges)
	actor_ring = _disc(1.27,Color("e0533f"),.035)
	actor_ring.visible = false
	add_child(actor_ring)
	for unit in engine.get("all_battle_unit_states"):
		queries.alive_units.append(unit)
		var value: Dictionary = Adapter.to_view(unit)
		var model_value := value.duplicate(true)
		if model_value.unit_type not in ["infantry","cavalry"]: model_value.unit_type = "infantry"
		_spawn_unit(model_value)
		var badge := Label3D.new()
		badge.font_size = 40
		badge.pixel_size = .012
		badge.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		badge.no_depth_test = true
		badge.set_meta("unit_id",value.unit_id)
		action_badges.add_child(badge)
	_build_facing_ui()
	_build_attack_ui()
	_build_turn_ui()
	camera.make_current()
	DisplayServer.window_set_title("EASTWAR | M3 3D Enemy Turn 18x10")
	await host.initialized
	ready_for_input = true
	enemy_baseline = _state_for_enemy_summary()
	_sync_views()
	status.text = "아군 선택 → 이동·방향 확정 또는 [공격] → 적 선택"

func _build_ui() -> void:
	super._build_ui()
	for layer in get_children():
		if layer is CanvasLayer:
			for child in layer.get_children():
				if child is Label and child.text.begins_with("LMB"):
					child.text = "LMB 선택·이동 / 공격 대상 | RMB 취소 | 휠 줌 | WASD 이동 | Q/E 회전 | F12 캡처\nM3: 아군 공격 또는 [대기] 후 엔진이 적 행동을 자동 진행 · 3D는 적 경로·피격·사유를 재생. 결과 화면 M5 / 월드맵 M7."
	info.add_theme_font_size_override("font_size",15)
	status.add_theme_font_size_override("font_size",14)
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status.custom_minimum_size.x = 430

func _build_facing_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	facing_ui = HBoxContainer.new()
	facing_ui.position = Vector2(24,300)
	layer.add_child(facing_ui)
	for direction in ["left","up","down","right"]:
		var button := Button.new()
		button.text = "방향 " + direction
		button.pressed.connect(confirm_facing.bind(direction))
		facing_ui.add_child(button)

func _build_attack_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	attack_button = Button.new()
	attack_button.text = "공격  [F]"
	attack_button.position = Vector2(24,254)
	attack_button.custom_minimum_size = Vector2(160,38)
	attack_button.pressed.connect(request_attack)
	layer.add_child(attack_button)
	wait_button = Button.new()
	wait_button.text = "대기"
	wait_button.position = Vector2(194,254)
	wait_button.custom_minimum_size = Vector2(110,38)
	wait_button.pressed.connect(request_wait)
	layer.add_child(wait_button)
	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	panel.position = Vector2(get_viewport().get_visible_rect().size.x-394,20)
	panel.custom_minimum_size = Vector2(370,0)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color(.035,.065,.09,.92)
	style.content_margin_left=12
	style.content_margin_right=12
	style.content_margin_top=10
	style.content_margin_bottom=10
	panel.add_theme_stylebox_override("panel",style)
	layer.add_child(panel)
	var box := VBoxContainer.new()
	box.mouse_filter=Control.MOUSE_FILTER_IGNORE
	panel.add_child(box)
	target_info=Label.new()
	target_info.text="대상: 공격 선택 후 적 부대에 마우스를 올리세요"
	target_info.custom_minimum_size.x=346
	target_info.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	target_info.mouse_filter=Control.MOUSE_FILTER_IGNORE
	target_info.add_theme_font_size_override("font_size",14)
	box.add_child(target_info)
	combat_log=Label.new()
	combat_log.text="전투 기록 · 엔진 이벤트 / 적 행동 상태 변화"
	combat_log.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	combat_log.mouse_filter=Control.MOUSE_FILTER_IGNORE
	combat_log.add_theme_font_size_override("font_size",14)
	box.add_child(combat_log)

func _build_turn_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var size := get_viewport().get_visible_rect().size
	turn_label = Label.new()
	turn_label.position = Vector2(size.x*.5-260,18)
	turn_label.custom_minimum_size = Vector2(520,0)
	turn_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	turn_label.add_theme_font_size_override("font_size",22)
	turn_label.add_theme_color_override("font_outline_color",Color.BLACK)
	turn_label.add_theme_constant_override("outline_size",6)
	turn_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(turn_label)
	roster_label = Label.new()
	roster_label.position = Vector2(size.x-394,size.y-250)
	roster_label.custom_minimum_size = Vector2(370,0)
	roster_label.add_theme_font_size_override("font_size",13)
	roster_label.add_theme_color_override("font_outline_color",Color.BLACK)
	roster_label.add_theme_constant_override("outline_size",4)
	roster_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(roster_label)
	result_overlay = Label.new()
	result_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	result_overlay.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_overlay.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	result_overlay.add_theme_font_size_override("font_size",96)
	result_overlay.add_theme_color_override("font_outline_color",Color.BLACK)
	result_overlay.add_theme_constant_override("outline_size",14)
	result_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	result_overlay.visible = false
	layer.add_child(result_overlay)

func _process(delta: float) -> void:
	if not ready_for_input: return
	super._process(delta) # moving_id stays empty; no mock movement executes.
	_consume_events()
	_consume_action_events()
	_consume_enemy_events()
	_advance_enemy_presentation(delta)
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
		root.visible = engine.call("_is_unit_state_available_for_battle_slot",unit)
		if not playback.has(value.unit_id):
			root.position = board.world(value.grid_cell)
			_ground_soldiers(value.unit_id)
		for index in range(soldiers[value.unit_id].size()):
			var soldier: Node3D = soldiers[value.unit_id][index]
			soldier.visible = index < visual_soldier_count(value)
			soldier.rotation.y = {"up":0.0,"down":PI,"left":PI/2,"right":-PI/2}.get(value.facing,0.0)
		for child in root.get_children():
			if child is Label3D: child.text = "%s | %s\n%s" % [value.unit_id,value.unit_type,value.current_troops]
	_consume_enemy_events()
	var ended := not battle_result.is_empty()
	facing_ui.visible = engine.get("current_phase") == "facing_select" and not ended
	var active = engine.get("active_unit_state")
	selected = active.unit_id if active != null else ""
	ring.visible = views.has(selected) and views[selected].visible and not ended
	if ring.visible: ring.position=views[selected].position+Vector3(0,.09,0)
	actor_ring.visible = views.has(enemy_actor_id) and views[enemy_actor_id].visible
	if actor_ring.visible: actor_ring.position=views[enemy_actor_id].position+Vector3(0,.1,0)
	var phase: String = engine.get("current_phase")
	attack_button.disabled = phase != "ally_turn" or engine.get("is_demo_animating") or active == null or _enemy_presentation_busy() or ended
	var wait_block := _wait_block_reason()
	wait_button.disabled = not wait_block.is_empty()
	wait_button.tooltip_text = "엔진 대기 (2D 대기 버튼과 같은 명령)" if wait_block.is_empty() else wait_block
	if phase != "attack_select" and not attack_cells.is_empty(): _clear_attack_range()
	if phase == "enemy_turn" and not ended and enemy_queue.is_empty(): status.text="적 자동 행동 중 · 입력 잠금 / 결과는 엔진 상태로 동기화"
	last_phase=phase
	if not target_id.is_empty(): _refresh_target_info(queries.find_unit(target_id))
	_refresh_turn_ui(phase)
	_refresh_info()

func action_state_text(value: Dictionary) -> String:
	# Engine flags only (14-field view); the 3D side never derives action order.
	if value.has_acted: return "행동 완료"
	if value.has_moved: return "이동 완료"
	return "미행동"

func _refresh_turn_ui(phase: String) -> void:
	var side := "적" if phase == "enemy_turn" or _enemy_presentation_busy() else "아군"
	var actor := enemy_actor_id if side == "적" else selected
	turn_label.text = "라운드 %d · %s 턴%s" % [current_round,side," · 행동 중: "+actor if not actor.is_empty() else ""]
	if not battle_result.is_empty(): turn_label.text = "라운드 %d · 전투 종료" % current_round
	var lines: Array[String] = ["부대 상태 (엔진 has_moved / has_acted)"]
	for badge in action_badges.get_children():
		var id: String = badge.get_meta("unit_id")
		var value: Dictionary = display_values.get(id,{})
		badge.visible = views[id].visible and not value.is_empty()
		if not badge.visible: continue
		badge.text = action_state_text(value)
		badge.modulate = Color("9fd3ff") if value.side == "ally" else Color("ffb0a0")
		badge.position = views[id].position+Vector3(0,5.2,0)
		lines.append("%s %s · %s · 병력 %s · %s" % ["아군" if value.side == "ally" else "적군",id,value.unit_type,value.current_troops,badge.text])
	roster_label.text = "\n".join(lines)

func _refresh_info() -> void:
	if not ready_for_input or selected.is_empty(): return
	var value: Dictionary = display_values.get(selected,{})
	if value.is_empty(): return
	info.text = "%s / %s / 병력 %s\n셀 %s / %s\n이동 %s · 행동 %s / 상태 %s" % [selected,value.unit_type,value.current_troops,value.grid_cell,engine.get("current_phase"),value.has_moved,value.has_acted,value.status_effects]

func _clear_range() -> void:
	for child in range_view.get_children():
		range_view.remove_child(child)
		child.queue_free()

func _reject(reason := "행동 불가 · 엔진이 선택 또는 이동을 거절했습니다") -> void:
	rejected += 1
	status.text = "거절 / " + reason

func _click_world(pos: Vector2) -> void:
	if not ready_for_input: return
	if _input_locked():
		return
	var cell: Vector2i = projection.world_to_grid_from_ray(camera.project_ray_origin(pos),camera.project_ray_normal(pos))
	if engine.get("current_phase") == "attack_select":
		_click_attack_cell(cell)
		return
	if engine.get("current_phase") != "ally_turn":
		_reject("방향 확정 또는 취소가 필요합니다")
		return
	var unit = null
	# Ground-cell selection avoids foreground pick boxes stealing adjacent cells.
	for candidate in queries.alive_units:
		if candidate.grid_cell == cell and engine.call("_is_unit_state_available_for_battle_slot",candidate): unit = candidate
	if unit != null:
		if unit.side != "ally":
			_reject("대상 아님 · 아군을 선택한 뒤 [공격]을 누르세요")
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
		status.text = "선택됨 / 이동할 칸 또는 [공격] 선택"
	else:
		if not engine.call("_try_direct_move_to_cell",cell):
			_reject()
			return
		_clear_range()
		status.text = "엔진 이동 중 / 이동 후 방향을 확정하세요"
	_sync_views()

func confirm_facing(direction: String) -> void:
	if _input_locked(): return
	if engine.get("current_phase") != "facing_select":
		_reject()
		return
	engine.call("_select_post_move_facing",direction)
	_consume_events()
	_sync_views()
	status.text = "방향 확정 / [공격]으로 적을 선택하세요"

func _unhandled_input(event: InputEvent) -> void:
	if not ready_for_input: return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F:
		request_attack()
		return
	if event is InputEventMouseMotion and engine.get("current_phase") == "attack_select":
		var cell: Vector2i = projection.world_to_grid_from_ray(camera.project_ray_origin(event.position),camera.project_ray_normal(event.position))
		for candidate in engine.call("_get_alive_enemy_units"):
			if candidate.grid_cell == cell:
				target_id=candidate.unit_id
				_refresh_target_info(candidate)
				break
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		if _input_locked(): return
		engine.call("_handle_right_click_cancel")
		_consume_events()
		_sync_views()
		_clear_range()
		_clear_attack_range()
		status.text = "취소 / 엔진이 허용하는 선택·이동 취소 반영"
		return
	super._unhandled_input(event)

func _input_locked() -> bool:
	# Battle end (event-driven) outranks every phase/queue condition.
	_consume_enemy_events()
	if not battle_result.is_empty():
		_reject("전투 종료 · %s / 모든 입력 잠금" % RESULT_TEXT.get(battle_result,battle_result))
		return true
	if engine.get("current_phase") == "enemy_turn":
		_reject("적 턴 중 · 적 행동이 끝날 때까지 기다리세요")
		return true
	if engine.get("is_demo_animating"):
		_reject("연출 중 · 중복 명령을 받지 않습니다")
		return true
	if _enemy_presentation_busy():
		_reject("적 행동 재생 중 · 재생이 끝날 때까지 기다리세요")
		return true
	return false

func _enemy_presentation_busy() -> bool:
	return not enemy_queue.is_empty() or enemy_hold > 0.0

func _wait_block_reason() -> String:
	# Guidance only (engine state reads); the engine re-validates the command.
	if not battle_result.is_empty(): return "전투 종료 · %s / 모든 입력 잠금" % RESULT_TEXT.get(battle_result,battle_result)
	var phase: String = engine.get("current_phase")
	if phase == "enemy_turn": return "적 턴 중 · 적 행동이 끝날 때까지 기다리세요"
	if engine.get("is_demo_animating"): return "연출 중 · 중복 명령을 받지 않습니다"
	if _enemy_presentation_busy(): return "적 행동 재생 중 · 재생이 끝날 때까지 기다리세요"
	if phase != "ally_turn": return "행동 불가 · 현재 선택 단계를 완료하거나 취소하세요"
	var active = engine.get("active_unit_state")
	if active == null: return "대기 불가 · 먼저 아군을 선택하세요"
	if Adapter.to_view(active).has_acted: return "대기 불가 · 이미 행동한 부대입니다"
	return ""

func request_wait() -> void:
	if not ready_for_input or _input_locked(): return
	var reason := _wait_block_reason()
	if not reason.is_empty():
		_reject(reason)
		return
	var waiting_id: String = engine.get("active_unit_state").unit_id
	var enemy_events_before: int = engine.get("enemy_action_event_log").export().size()
	enemy_baseline=_state_for_enemy_summary() # before the call: an instant enemy slot is summarised inside it
	engine.call("_end_ally_turn_by_wait")
	# Acceptance is read back from the engine (no 3D-side ledger): the unit is
	# marked acted, or the engine already ran the enemy slot it starts (an
	# instant enemy slot can finish and even reset flags for a new round).
	var waited = queries.find_unit(waiting_id)
	var accepted: bool = waited != null and (Adapter.to_view(waited).has_acted or engine.get("enemy_action_event_log").export().size() > enemy_events_before)
	if not accepted:
		_reject("행동 불가 · 엔진이 대기를 수락하지 않았습니다")
		return
	_clear_range()
	_clear_attack_range()
	awaiting_enemy_result=true
	_append_combat_line("대기 · " + waiting_id)
	status.text="대기 · %s / 이후 적 자동 행동" % waiting_id
	_sync_views()

func request_attack() -> void:
	if not ready_for_input or _input_locked(): return
	if engine.get("current_phase") != "ally_turn":
		_reject("행동 불가 · 현재 선택 단계를 완료하거나 취소하세요")
		return
	engine.call("try_basic_attack")
	if engine.get("current_phase") != "attack_select":
		_reject("행동 불가 · 이미 행동했거나 이동 후 공격이 허용되지 않습니다")
		return
	_show_attack_range()
	status.text="공격 대상 선택 / 주황: 사거리 · 빨강: 유효 적 / 우클릭 취소"
	_sync_views()

func _show_attack_range() -> void:
	_clear_range()
	_clear_attack_range()
	var active = engine.get("active_unit_state")
	if active == null: return
	var value: Dictionary = Adapter.to_view(active)
	attack_cells = engine.get("battle_grid_controller").get_tiles_in_range(value.grid_cell,value.attack_range)
	for cell in attack_cells:
		if cell == value.grid_cell: continue
		var dot := _disc(.6,Color("c58b36"),.025)
		range_view.add_child(dot)
		dot.position=board.world(cell)+Vector3(0,.13,0)
	enemy_candidates=engine.call("_get_alive_enemy_units")
	for candidate in enemy_candidates:
		if engine.call("is_unit_in_attack_range",active,candidate):
			valid_target_ids.append(candidate.unit_id)
			var mark := _disc(1.25,Color("dd4d36"),.03)
			target_marks.add_child(mark)
			mark.position=board.world(candidate.grid_cell)+Vector3(0,.1,0)

func _clear_attack_range() -> void:
	if not attack_cells.is_empty(): _clear_range()
	attack_cells.clear()
	enemy_candidates.clear()
	valid_target_ids.clear()
	for child in target_marks.get_children():
		target_marks.remove_child(child)
		child.queue_free()

func _click_attack_cell(cell: Vector2i) -> void:
	# Same input boundary as 2D: only deployed, live enemy candidates can call attack.
	var candidates: Array = engine.call("_get_alive_enemy_units")
	var target = null
	for candidate in candidates:
		if candidate.grid_cell == cell: target=candidate
	if target == null:
		_reject("대상 아님 · 아군·빈 칸·미배치·사망 부대는 공격 대상이 아닙니다")
		return # Keep attack_select, exactly as the 2D input handler does.
	target_id=target.unit_id
	_refresh_target_info(target)
	if not engine.call("is_unit_in_attack_range",engine.get("active_unit_state"),target):
		_reject("범위 밖 · 공격 사거리 안의 적을 선택하세요")
		return
	engine.call("_try_attack_enemy_target_from_attack_select",target)
	if not engine.get("is_demo_animating"):
		_reject("행동 불가 · 엔진이 공격을 수락하지 않았습니다")
		return
	# Catch up any old move presentation without delaying an accepted engine attack.
	playback.erase(engine.get("active_unit_state").unit_id)
	_consume_action_events()
	enemy_baseline=_state_for_enemy_summary()
	awaiting_enemy_result=true
	_clear_attack_range()
	_sync_views()
	status.text="공격 처리 중 · 피해는 엔진 이벤트 값 / 이후 적 자동 행동"

func _refresh_target_info(target: BattleUnitState) -> void:
	if target == null: return
	var value: Dictionary = Adapter.to_view(target)
	# Additional approval: this field is read ONLY for the target information panel.
	target_defending=target.is_defending
	target_info.text="대상 %s / %s\n병력 %s · 방어 %s · 셀 %s" % [value.unit_id,value.unit_type,value.current_troops,"중" if target_defending else "아님",value.grid_cell]

func visual_soldier_count(value: Dictionary) -> int:
	# Visual density only, unrelated to battle rules or damage computation.
	return clampi(ceili(6.0*float(value.current_troops)/maxf(1.0,float(value.max_troops))),0,6)

func _consume_action_events() -> void:
	var events: Array = engine.get("battle_action_event_log").export()
	while action_cursor < events.size():
		var event: Dictionary = events[action_cursor]
		action_cursor+=1
		if event.kind == "attack_resolved":
			_show_attack_damage(event)
		elif event.kind == "unit_defeated":
			_append_combat_line("격파 · "+event.unit_id)
		elif event.kind == "action_completed":
			_append_combat_line("행동 완료 · "+event.unit_id)

func _show_attack_damage(event: Dictionary) -> void:
	damage_presentations.append(event.duplicate(true))
	_append_combat_line("%s → %s / 피해 %s · %s / 병력 %s" % [event.attacker_id,event.target_id,event.damage_applied,event.angle_type,event.troops_after])
	var label := Label3D.new()
	label.text="−%s · %s" % [event.damage_applied,event.angle_type]
	label.font_size=58
	label.pixel_size=.015
	label.modulate=Color("ffe49b")
	label.billboard=BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test=true
	add_child(label)
	label.position=views[event.target_id].position+Vector3(0,3.8,0)
	var tween := create_tween()
	tween.tween_property(label,"position:y",label.position.y+1.5,1.8)
	tween.parallel().tween_property(label,"modulate:a",0.0,1.8)
	tween.tween_callback(label.queue_free)

func _append_combat_line(line: String) -> void:
	combat_lines.append(line)
	var first := maxi(0,combat_lines.size()-5)
	combat_log.text="전투 기록\n"+"\n".join(combat_lines.slice(first))

func _state_for_enemy_summary() -> Dictionary:
	var result := {}
	for unit in engine.get("all_battle_unit_states"):
		var value: Dictionary = Adapter.to_view(unit)
		result[value.unit_id]={"cell":value.grid_cell,"troops":value.current_troops}
	return result

func _state_diff_text(after: Dictionary) -> String:
	# Fallback when the slot carries no move/attack events (e.g. unique skill).
	var changes: Array = []
	for id in enemy_baseline:
		var before: Dictionary=enemy_baseline[id]
		var current: Dictionary=after[id]
		if before.cell != current.cell:
			changes.append("%s 이동 %s→%s" % [id,before.cell,current.cell])
		if before.troops != current.troops:
			changes.append("%s 병력 %s→%s" % [id,before.troops,current.troops])
	return "이동·병력 변화 없음" if changes.is_empty() else " / ".join(changes)

func _finish_enemy_summary(slot: Array) -> void:
	var after := _state_for_enemy_summary()
	var phrases: Array = []
	var has_action_event := false
	for event in slot:
		match event.kind:
			"enemy_moved":
				has_action_event = true
				phrases.append("%s 이동 %s→%s (%d칸)" % [event.unit_id,event.from,event.to,event.path.size()-1])
			"enemy_attack_resolved":
				has_action_event = true
				phrases.append("%s → %s 피해 %s · %s%s" % [event.attacker_id,event.target_id,event.damage_applied,event.angle_type," · 격파" if event.killed else ""])
			"enemy_waited":
				phrases.append("%s %s" % [event.unit_id,WAIT_TEXT.get(event.reason,event.reason)])
			"enemy_skill_used":
				phrases.append("%s 특기 %s" % [event.unit_id,event.skill_id])
	if not has_action_event: phrases.append(_state_diff_text(after))
	var summary := "적 행동 결과 · "+" / ".join(phrases)
	enemy_summaries.append({"before":enemy_baseline.duplicate(true),"after":after.duplicate(true),"text":summary,"events":slot.duplicate(true)})
	_append_combat_line(summary)
	enemy_baseline = after
	awaiting_enemy_result=false

func _consume_enemy_events() -> void:
	var events: Array = engine.get("enemy_action_event_log").export()
	while enemy_cursor < events.size():
		var event: Dictionary = events[enemy_cursor]
		enemy_cursor += 1
		enemy_queue.append(event)
		# Summary and end lock are decided on receipt; playback may lag behind.
		match event.kind:
			"enemy_actor_selected":
				enemy_slot = [event]
			"enemy_action_completed":
				enemy_slot.append(event)
				_finish_enemy_summary(enemy_slot)
				enemy_slot = []
			"battle_ended":
				battle_result = event.result_state
				if not enemy_slot.is_empty(): _finish_enemy_summary(enemy_slot)
				enemy_slot = []
			_:
				if not enemy_slot.is_empty(): enemy_slot.append(event)

func _advance_enemy_presentation(delta: float) -> void:
	if enemy_hold > 0.0:
		enemy_hold = maxf(0.0,enemy_hold-delta)
		if enemy_hold > 0.0: return
	while not enemy_queue.is_empty():
		var event: Dictionary = enemy_queue[0]
		if event.kind == "enemy_moved":
			if enemy_moving_id.is_empty():
				_start_enemy_move(event)
				return
			if playback.has(enemy_moving_id): return
			enemy_moving_id = ""
			enemy_queue.pop_front()
			continue
		enemy_queue.pop_front()
		_present_enemy_event(event)
		if enemy_hold > 0.0: return
	if enemy_status_active and battle_result.is_empty() and engine.get("current_phase") == "ally_turn" and not engine.get("is_demo_animating"):
		enemy_status_active = false
		status.text="아군 조작 가능 / 엔진이 선택한 부대: "+selected

func _start_enemy_move(event: Dictionary) -> void:
	# Same path playback and speed as the M1-b ally movement presentation.
	var path: Array = []
	for cell in event.path: path.append(Vector2i(cell[0],cell[1]))
	enemy_played_paths.append(event.path.duplicate(true))
	enemy_moving_id = event.unit_id
	playback[event.unit_id] = {"path":path,"index":1}
	views[event.unit_id].position = board.world(path[0])
	animation_starts += 1
	_enemy_text("적 이동 · %s %s→%s" % [event.unit_id,event.from,event.to])

func _present_enemy_event(event: Dictionary) -> void:
	match event.kind:
		"enemy_turn_started":
			current_round = event.round
			_enemy_text("적 턴 · 라운드 %d" % event.round)
		"enemy_actor_selected":
			enemy_actor_id = event.unit_id
			_enemy_text("적 행동 중 · " + event.unit_id)
		"enemy_attack_resolved":
			_show_enemy_hit(event)
			enemy_hold = enemy_hold_seconds
		"enemy_waited":
			_enemy_text("적 %s · %s" % [event.unit_id,WAIT_TEXT.get(event.reason,event.reason)])
			enemy_hold = enemy_hold_seconds
		"enemy_skill_used":
			_enemy_text("적 특기 사용: " + event.skill_id)
			enemy_hold = enemy_hold_seconds
		"enemy_action_completed":
			enemy_actor_id = ""
		"round_started":
			current_round = event.round
			_enemy_text("라운드 %d" % event.round)
			enemy_hold = enemy_hold_seconds
		"battle_ended":
			enemy_actor_id = ""
			result_overlay.text = RESULT_TEXT.get(event.result_state,event.result_state)
			result_overlay.visible = true
			_enemy_text("전투 종료 · %s / 모든 입력 잠금" % result_overlay.text)

func _enemy_text(line: String) -> void:
	enemy_texts.append(line)
	enemy_status_active = true
	status.text = line

func _show_enemy_hit(event: Dictionary) -> void:
	# Same display path as the ally attack; the number is the engine's damage_applied.
	enemy_damage_presentations.append(event.duplicate(true))
	_append_combat_line("%s → %s / 피해 %s · %s / 병력 %s" % [event.attacker_id,event.target_id,event.damage_applied,event.angle_type,event.target_troops_after])
	var label := Label3D.new()
	label.text="−%s · %s" % [event.damage_applied,event.angle_type]
	label.font_size=58
	label.pixel_size=.015
	label.modulate=Color("ff9a8a")
	label.billboard=BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test=true
	label.set_meta("enemy_hit",true)
	add_child(label)
	label.position=views[event.target_id].position+Vector3(0,3.8,0)
	var tween := create_tween()
	tween.tween_property(label,"position:y",label.position.y+1.5,1.8)
	tween.parallel().tween_property(label,"modulate:a",0.0,1.8)
	tween.tween_callback(label.queue_free)
	_enemy_text("적 공격 · %s → %s 피해 %s (%s)" % [event.attacker_id,event.target_id,event.damage_applied,event.angle_type])
