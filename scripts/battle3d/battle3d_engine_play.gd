extends "res://scripts/battle3d/lab_presentation.gd"
const Adapter = preload("res://scripts/battle3d/battle3d_unit_adapter.gd")
const GridProjection = preload("res://scripts/battle3d/battle3d_grid_projection.gd")
const Queries = preload("res://scripts/battle3d/battle3d_movement_adapter.gd")
const Host = preload("res://scripts/battle3d/battle3d_engine_host.gd")
const UnitMarkers = preload("res://scripts/battle3d/battle3d_unit_markers.gd")
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
var defend_button: Button # M4-a: the engine's existing 2D defend command, no hotkey (M6).
# M4-b: the engine's strategy command. Fourth independent cursor over tactic_event_log;
# never merged with event_cursor / action_cursor / enemy_cursor. Only strategy_cast and
# status_tick are handled here; M4-d adds reinforcement_arrived on the same cursor; M4-c1 adds
# skill_cast/skill_effect/skill_finished of allied casters; every other kind is skipped (the cursor still advances).
var strategy_button: Button
var tactic_cursor := 0
var strategy_marks := Node3D.new()
var strategy_target_ids: Array[String] = []
var tactic_texts: Array[String] = []
var tactic_presentations: Array = []
var pending_enemy_ticks := {} # enemy unit_id -> status_tick events shown with its replayed action_completed
var held_unit_ids := {} # M4-d: deployed units whose arrival event waits for that round's replayed round_started
var pending_arrivals := {} # M4-d: round -> reinforcement_arrived events shown with that round's replayed round_started
var arrival_presentations: Array = []
var arrival_texts: Array[String] = []
var status_display := {} # unit_id -> engine status_effects shown on badges, refreshed only when no enemy replay is pending
# Display names, same characters as the engine's status display names; unknown ids are shown as-is.
const STATUS_TEXT := {"shake":"동요","confusion":"혼란","burn":"화상",
	"accuracy_down":"명중 저하","action_lock":"행동 봉쇄","attack_defense_down":"공격·방어 저하","attack_defense_up":"공격·방어 상승",
	"counter_up":"반격 강화","damage_reduction":"피해 감소","defense_down":"방어 저하","defense_up":"방어 상승","fear":"공포",
	"flank_damage_taken_up":"측후방 피격 증가","flank_damage_up":"측후방 공격 강화","formation_break":"진형 붕괴",
	"mobility_up":"기동력 상승","momentum_gain_down":"기세 획득 저하","momentum_gain_up":"기세 획득 상승","movement_down":"이동 저하",
	"rout_resist":"패주 저항","siege_attack_up":"공성 공격 상승","skill_cost_up":"기세 비용 증가","status_resist":"상태 저항"}
# M4-c1: the engine's unique skill command (allied casters only; enemy skill replay is M4-c2).
var skill_button: Button
var skill_marks := Node3D.new()
var skill_target_ids: Array[String] = []
var skill_presentations: Array = []
var skill_texts: Array[String] = []
var momentum_label: Label
var momentum_display := {} # side -> engine momentum, refreshed only when no enemy replay is pending
var momentum_note := "" # last momentum skill_effect of an allied skill, shown beside the momentum line
# M4-c2: enemy-cast skill_* events wait for the replay of that caster's enemy_skill_used (the
# tactic log runs ahead of the enemy replay); enemy-cast strategy_cast waits for that enemy's
# replayed enemy_action_completed, like enemy status ticks. Display only; the cursor never waits.
var pending_enemy_skills := {} # caster_id -> skill_* events not shown yet
var enemy_skill_open := {} # caster_id -> true between its replayed enemy_skill_used and enemy_action_completed
var pending_enemy_strategies := {} # caster_id -> strategy_cast events shown with its replayed enemy_action_completed
var enemy_skill_presentations: Array = []
var enemy_skill_texts: Array[String] = []
var enemy_skill_leftovers: Array = [] # events still held when the slot's completion replays (reported, never dropped)
var presenting_enemy_skill := false

# M5-a: the engine's own full auto battle (start/stop) and the presentation speed (Engine.time_scale only).
const AUTO_STATUS := "자동 진행 중 · 엔진이 행동을 선택합니다 / [자동 ■]로 중지"
const SPEED_STEPS := [1.0, 2.0, 4.0]
var auto_button: Button
var speed_button: Button
var speed_index := 0
var auto_was_on := false
var auto_press_pending := false # set by an auto toggle, cleared at the next lab frame: a second press in between is a double press
var auto_texts: Array[String] = []
var auto_marks := {} # ally unit_id -> engine event counts while not acted; a quiet (event-less) auto action is shown when it acts
var auto_hold_sent := false # M5-a2: last value sent with set_auto_presentation_hold (sent only when it changes)
# M5-c: enemy AI level option panel (engine values only; the engine decides which rules a level turns on).
const AI_LEVEL_ORDER := ["low", "mid", "high"]
const AI_LEVEL_TEXT := {"low":"하", "mid":"중", "high":"상"}
var option_toggle: Button
var option_panel: VBoxContainer
var edge_scroll_check: CheckBox # HUD block 4-4: the edge scroll on/off (presentation only)
var ai_level_label: Label
var ai_level_buttons := {}
var ai_level_texts: Array[String] = []
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
var unit_markers := UnitMarkers.new() # HUD block 4-6

func read_battle_log_lines() -> Array:
	# NIGHT7 HUD block 2: the one approved new engine read (2D log text, engine
	# `battle_log_lines`, at most four lines). A copy, so a reader can never change
	# the engine's array; no engine command.
	var lines = engine.get("battle_log_lines")
	return [] if lines == null else (lines as Array).duplicate()
# HUD block 3 (enemy roster): the four approved engine reads N1-N4, by unit_id
# (no BattleUnitState leaves the lab). N2 is read once per unit, N3 again only
# when the unit's facing changes, N4 only while no enemy replay is pending (the
# status_display rule); the HUD gets values or shared textures, never commands.
const HUD_UNIT_TYPE_NAMES := {"infantry":"보병", "cavalry":"기병", "archer":"궁병", "gunner":"총병", "mounted_archer":"기마궁병"} # battle_roster_hud_controller.gd _unit_type_name
var hud_portraits := {} # unit_id -> Texture2D (N2)
var hud_troop_icons := {} # unit_id -> [facing, Texture2D] (N3)
var hud_status_texts := {} # unit_id -> String (N4)

func hud_enemy_unit_ids() -> Array:
	# Enemy units in the engine's slot order (all_battle_unit_states, an existing read).
	var ids := []
	for unit in engine.get("all_battle_unit_states"):
		if unit.side == "enemy": ids.append(unit.unit_id)
	return ids

func _hud_unit(unit_id: String) -> BattleUnitState:
	for unit in engine.get("all_battle_unit_states"):
		if unit.unit_id == unit_id: return unit
	return null

func hud_display_name(unit_id: String) -> String:
	# N1: the unit's display_name field (not added to Adapter.VIEW_FIELDS).
	var unit := _hud_unit(unit_id)
	return "" if unit == null else String(unit.display_name)

func hud_portrait(unit_id: String) -> Texture2D:
	# N2: engine _get_closeup_portrait_texture_for_unit, once per unit (it loads and fills the engine's texture cache).
	if not hud_portraits.has(unit_id):
		var unit := _hud_unit(unit_id)
		hud_portraits[unit_id] = null if unit == null else engine.call("_get_closeup_portrait_texture_for_unit", unit)
	return hud_portraits[unit_id]

func hud_troop_icon(unit_id: String) -> Texture2D:
	# N3: engine _get_troop_icon_texture_for_visual_key("", unit), again only when [unit_id, facing] changes.
	var unit := _hud_unit(unit_id)
	if unit == null: return null
	var cached = hud_troop_icons.get(unit_id)
	if cached == null or cached[0] != unit.facing:
		hud_troop_icons[unit_id] = [unit.facing, engine.call("_get_troop_icon_texture_for_visual_key", "", unit)]
	return hud_troop_icons[unit_id][1]

func hud_status_summary(unit_id: String) -> String:
	# N4: engine _get_formation_status_summary_text, refreshed only while no enemy replay is pending.
	if not _enemy_presentation_busy() or not hud_status_texts.has(unit_id):
		var unit := _hud_unit(unit_id)
		hud_status_texts[unit_id] = "" if unit == null else String(engine.call("_get_formation_status_summary_text", unit))
	return hud_status_texts[unit_id]

func hud_unit_type_name(unit_type: String) -> String:
	return HUD_UNIT_TYPE_NAMES.get(unit_type, "부대")

# HUD block 4-1 (ally roster + current actor): the two approved new engine reads
# N5 (status entries) and N6 (hero id), plus wrappers over reads the lab already
# makes (active_unit_state, current_phase, _can_use_unique_skill,
# _get_unique_skill_for_unit, the N3 troop icon by visual key). Values or copies
# only; no command.
const HUD_ALLY_ACTOR_PHASES := ["ally_turn", "facing_select", "attack_select", "unique_skill_target_select", "strategy"] # 2D _is_production_roster_ally_actor_phase
var hud_status_entry_lists := {} # unit_id -> Array (N5)
var hud_troop_icons_by_key := {} # visual key -> Texture2D (N3 with a visual key, the 2D current-actor rule)

func hud_ally_unit_ids() -> Array:
	var ids := []
	for unit in engine.get("all_battle_unit_states"):
		if unit.side == "ally": ids.append(unit.unit_id)
	return ids

func hud_active_unit_id() -> String:
	# The engine's active_unit_state (the 2D current actor).
	var unit = engine.get("active_unit_state")
	return "" if unit == null else String(unit.unit_id)

func hud_ally_actor_id() -> String:
	# The 2D roster's gold frame on the ally side: active_unit_state during the ally input phases.
	var unit = engine.get("active_unit_state")
	if unit == null or unit.side != "ally" or not HUD_ALLY_ACTOR_PHASES.has(String(engine.get("current_phase"))): return ""
	return String(unit.unit_id)

func hud_status_entries(unit_id: String) -> Array:
	# N5: engine _get_unit_status_display_entries (deep copy), refreshed only while no enemy replay is pending.
	if not _enemy_presentation_busy() or not hud_status_entry_lists.has(unit_id):
		var unit := _hud_unit(unit_id)
		hud_status_entry_lists[unit_id] = [] if unit == null else (engine.call("_get_unit_status_display_entries", unit) as Array).duplicate(true)
	return hud_status_entry_lists[unit_id].duplicate(true)

func hud_hero_id(unit_id: String) -> String:
	# N6: engine _get_hero_id_for_unit_state (a string copy).
	var unit := _hud_unit(unit_id)
	return "" if unit == null else String(engine.call("_get_hero_id_for_unit_state", unit))

func hud_skill_ready(unit_id: String) -> bool:
	# The engine's _can_use_unique_skill (already read by the lab's skill button); true only for the active ally.
	var unit := _hud_unit(unit_id)
	return unit != null and bool(engine.call("_can_use_unique_skill", unit))

func hud_unique_skill(unit_id: String) -> Dictionary:
	# The engine's _get_unique_skill_for_unit (already read by the lab), a copy.
	var unit := _hud_unit(unit_id)
	return {} if unit == null else (engine.call("_get_unique_skill_for_unit", unit) as Dictionary).duplicate(true)

func hud_troop_icon_for_key(visual_key: String) -> Texture2D:
	# N3 by visual key (the 2D current-actor rule: country + unit type), once per key.
	if not hud_troop_icons_by_key.has(visual_key):
		hud_troop_icons_by_key[visual_key] = engine.call("_get_troop_icon_texture_for_visual_key", visual_key, null)
	return hud_troop_icons_by_key[visual_key]

# HUD block 4-2 (command panel + facing arrows): the one approved new engine
# read N7 (the unique skill's effective momentum cost, a value copy) and the
# panel's open rule from values the lab already reads. No command.
func hud_skill_cost(unit_id: String) -> int:
	# N7: engine _get_effective_unique_skill_cost for the unit's unique skill (-1 = no skill).
	var unit := _hud_unit(unit_id)
	if unit == null: return -1
	var skill: Dictionary = engine.call("_get_unique_skill_for_unit", unit)
	return -1 if skill.is_empty() else int(engine.call("_get_effective_unique_skill_cost", unit, skill))

func hud_command_panel_open() -> bool:
	# The lab's command rule: an ally to act in ally_turn, no presentation, auto, enemy replay or result.
	var active = engine.get("active_unit_state")
	return ready_for_input and battle_result.is_empty() and active != null and active.side == "ally" and views.has(active.unit_id) and views[active.unit_id].visible \
		and engine.get("current_phase") == "ally_turn" and not engine.get("is_demo_animating") and not engine.get("is_full_auto_battle_enabled") and not _enemy_presentation_busy() and not hud_cutin_hold # block 4-3: closed while a cut-in holds

func hud_range_cell_positions() -> Array:
	# The move-range cells the lab already shows (range_view discs), as world positions.
	var out := []
	for dot in range_view.get_children(): out.append((dot as Node3D).position)
	return out

# HUD block 5 (cut-in): when the scenario shell turns it on, every presented
# skill_cast is recorded for the shell's cut-in and holds the lab: the skill
# events after it wait here and are presented in order when the shell releases
# the hold (its cut-in ended); input is locked and the auto play waits while
# held. No engine read or command; the lab alone (shell off) never holds.
var hud_cutin_enabled := false
var hud_skill_casts: Array = [] # every presented skill_cast (copies), in order
var hud_cutin_hold := false
var hud_held_skill_events: Array = [] # [event, enemy presentation] waiting for the release

func hud_release_cutin_hold() -> void:
	# Present what waited, in order, until the next skill_cast holds again.
	hud_cutin_hold = false
	while not hud_held_skill_events.is_empty() and not hud_cutin_hold:
		var item: Array = hud_held_skill_events.pop_front()
		presenting_enemy_skill = item[1]
		_present_skill_event(item[0])
	presenting_enemy_skill = false

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
		views[value.unit_id].add_child(_facing_arrow(value.side)) # HUD block 4-6
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
	_build_auto_ui()
	_build_option_ui()
	_apply_debug_text() # block 4-6: the debug text starts hidden (F3)
	add_child(unit_markers)
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
					child.text = "LMB 선택·이동 / 공격 대상 | RMB 취소 | 휠 줌 | WASD 이동 | Q/E 회전 | F12 캡처\nM3: 아군 공격·[대기]·[방어]·[책략]·[특기] 후 엔진이 적 행동을 자동 진행 · 3D는 적 경로·피격·사유를 재생. 결과 화면 M5 / 월드맵 M7."
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
	defend_button = Button.new()
	defend_button.text = "방어"
	defend_button.position = Vector2(314,254)
	defend_button.custom_minimum_size = Vector2(110,38)
	defend_button.pressed.connect(request_defend)
	layer.add_child(defend_button)
	strategy_button = Button.new()
	strategy_button.text = "책략"
	strategy_button.position = Vector2(434,254)
	strategy_button.custom_minimum_size = Vector2(110,38)
	strategy_button.pressed.connect(request_strategy)
	layer.add_child(strategy_button)
	add_child(strategy_marks)
	skill_button = Button.new()
	skill_button.text = "특기"
	skill_button.position = Vector2(554,254)
	skill_button.custom_minimum_size = Vector2(110,38)
	skill_button.pressed.connect(request_skill)
	layer.add_child(skill_button)
	add_child(skill_marks)
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
	momentum_label = Label.new()
	momentum_label.position = turn_label.position+Vector2(0,34)
	momentum_label.custom_minimum_size = Vector2(520,0)
	momentum_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	momentum_label.add_theme_font_size_override("font_size",17)
	momentum_label.add_theme_color_override("font_outline_color",Color.BLACK)
	momentum_label.add_theme_constant_override("outline_size",5)
	momentum_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(momentum_label)
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
	auto_press_pending = false
	super._process(delta) # moving_id stays empty; no mock movement executes.
	_consume_events()
	_consume_action_events()
	_consume_enemy_events()
	_consume_tactic_events()
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
	_update_auto_hold()

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
	_consume_tactic_events() # holds a fresh arrival before visibility is decided
	for unit in queries.alive_units:
		var value: Dictionary = Adapter.to_view(unit)
		display_values[value.unit_id] = value
		var root: Node3D = views[value.unit_id]
		root.visible = engine.call("_is_unit_state_available_for_battle_slot",unit) and _unit_shown(value.unit_id)
		if not playback.has(value.unit_id):
			root.position = board.world(value.grid_cell)
			_ground_soldiers(value.unit_id)
		for index in range(soldiers[value.unit_id].size()):
			var soldier: Node3D = soldiers[value.unit_id][index]
			soldier.visible = index < visual_soldier_count(value)
			soldier.rotation.y = {"up":0.0,"down":PI,"left":PI/2,"right":-PI/2}.get(value.facing,0.0)
		for child in root.get_children():
			if child is Label3D: child.text = "%s | %s\n%s" % [value.unit_id,value.unit_type,value.current_troops]
			if child.has_meta("facing_arrow"): _place_facing_arrow(child, root, value.facing)
	_consume_enemy_events()
	var ended := not battle_result.is_empty()
	facing_ui.visible = engine.get("current_phase") == "facing_select" and not ended
	var active = engine.get("active_unit_state")
	selected = active.unit_id if active != null else ""
	_refresh_unit_markers()
	ring.visible = views.has(selected) and views[selected].visible and not ended
	if ring.visible: ring.position=views[selected].position+Vector3(0,.09,0)
	actor_ring.visible = views.has(enemy_actor_id) and views[enemy_actor_id].visible
	if actor_ring.visible: actor_ring.position=views[enemy_actor_id].position+Vector3(0,.1,0)
	var phase: String = engine.get("current_phase")
	attack_button.disabled = phase != "ally_turn" or engine.get("is_demo_animating") or active == null or _enemy_presentation_busy() or ended or engine.get("is_full_auto_battle_enabled") or hud_cutin_hold
	var wait_block := _wait_block_reason()
	wait_button.disabled = not wait_block.is_empty()
	wait_button.tooltip_text = "엔진 대기 (2D 대기 버튼과 같은 명령)" if wait_block.is_empty() else wait_block
	var defend_block := _defend_block_reason()
	defend_button.disabled = not defend_block.is_empty()
	defend_button.tooltip_text = "엔진 방어 (2D 방어 버튼과 같은 명령)" if defend_block.is_empty() else defend_block
	var strategy_block := _strategy_block_reason()
	strategy_button.disabled = not strategy_block.is_empty()
	strategy_button.tooltip_text = "엔진 책략 (2D 책략 버튼과 같은 명령)" if strategy_block.is_empty() else strategy_block
	var skill_block := _skill_block_reason()
	skill_button.disabled = not skill_block.is_empty()
	skill_button.tooltip_text = "엔진 고유특기 (2D 특기 버튼과 같은 명령)" if skill_block.is_empty() else skill_block
	if phase != "strategy" and not strategy_target_ids.is_empty(): _clear_strategy_marks()
	if phase != "unique_skill_target_select" and not skill_target_ids.is_empty(): _clear_skill_marks()
	if phase != "attack_select" and not attack_cells.is_empty(): _clear_attack_range()
	if phase == "enemy_turn" and not ended and enemy_queue.is_empty(): status.text="적 자동 행동 중 · 입력 잠금 / 결과는 엔진 상태로 동기화"
	last_phase=phase
	if not target_id.is_empty(): _refresh_target_info(queries.find_unit(target_id))
	_refresh_turn_ui(phase)
	_refresh_info()
	_refresh_auto_ui()
	_refresh_option_ui()

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
		badge.text = action_state_text(value) + (" · 방어 중" if _unit_defending(queries.find_unit(id)) else "") + _status_suffix(id, value)
		badge.modulate = Color("9fd3ff") if value.side == "ally" else Color("ffb0a0")
		badge.position = views[id].position+Vector3(0,5.2,0)
		lines.append("%s %s · %s · 병력 %s · %s" % ["아군" if value.side == "ally" else "적군",id,value.unit_type,value.current_troops,badge.text])
	roster_label.text = "\n".join(lines)
	if not _enemy_presentation_busy(): momentum_display = {"ally":engine.get("battle_momentum").get_value("ally"),"enemy":engine.get("battle_momentum").get_value("enemy")}
	momentum_label.text = "기세 아군 %d / 적 %d%s" % [momentum_display.ally,momentum_display.enemy,"" if momentum_note.is_empty() else " · " + momentum_note]

func _refresh_info() -> void:
	if not ready_for_input or selected.is_empty(): return
	var value: Dictionary = display_values.get(selected,{})
	if value.is_empty(): return
	info.text = "%s / %s / 병력 %s\n셀 %s / %s\n이동 %s · 행동 %s / 상태 %s%s" % [selected,value.unit_type,value.current_troops,value.grid_cell,engine.get("current_phase"),value.has_moved,value.has_acted,_status_text(status_display.get(selected,{}))," / 방어 중" if _unit_defending(queries.find_unit(selected)) else ""]

func _unit_defending(unit: BattleUnitState) -> bool:
	# M4-a approval: the engine's is_defending is read (never written) for badges and the unit panel.
	return unit != null and unit.is_defending

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
	if not board.valid(cell): # block 7: outside the play area (scenery or off the board): no cell, no engine query
		_reject("칸 없음 · 플레이 구역 밖입니다")
		return
	if engine.get("current_phase") == "attack_select":
		_click_attack_cell(cell)
		return
	if engine.get("current_phase") == "strategy":
		_click_strategy_cell(cell)
		return
	if engine.get("current_phase") == "unique_skill_target_select":
		_click_skill_cell(cell)
		return
	if engine.get("current_phase") != "ally_turn":
		_reject("방향 확정 또는 취소가 필요합니다")
		return
	var unit = null
	# Ground-cell selection avoids foreground pick boxes stealing adjacent cells.
	for candidate in queries.alive_units:
		if candidate.grid_cell == cell and engine.call("_is_unit_state_available_for_battle_slot",candidate) and _unit_shown(candidate.unit_id): unit = candidate
	if unit != null:
		if unit.side != "ally":
			_reject("대상 아님 · 아군을 선택한 뒤 [공격]을 누르세요")
			return
		var acting = engine.get("active_unit_state")
		if unit != acting and Adapter.to_view(unit).has_acted:
			# Block 4-3: the engine would make an already-acted ally the active unit (C:14536-14540), leaving
			# no command to give until the right ally is clicked again; the lab keeps the acting ally instead.
			_reject("이미 행동한 부대 · 지금 행동할 부대는 %s입니다" % ("없음" if acting == null else acting.unit_id))
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
		if _waiting_unit_at(cell):
			_reject("행동 불가 · 도착 전 부대가 있는 칸입니다")
			return
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
	if event is InputEventMouseMotion and engine.get("current_phase") == "strategy":
		_hover_strategy_cell(projection.world_to_grid_from_ray(camera.project_ray_origin(event.position),camera.project_ray_normal(event.position)))
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
	if engine.get("is_full_auto_battle_enabled"):
		_reject("자동 진행 중 · [자동 ■]로 중지한 뒤 조작하세요")
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
	if hud_cutin_hold:
		_reject("특기 연출 중 · 컷인이 끝날 때까지 기다리세요")
		return true
	return false

func _edge_scroll_allowed() -> bool:
	# HUD block 4-4: also off while input is locked (battle over, auto, the enemy turn, an engine animation, the enemy
	# replay, a cut-in) and while the shell's option window is open. Reads only, without _input_locked's messages.
	if not super._edge_scroll_allowed() or not ready_for_input or not battle_result.is_empty(): return false
	if engine.get("is_full_auto_battle_enabled") or engine.get("current_phase") == "enemy_turn" or engine.get("is_demo_animating"): return false
	if _enemy_presentation_busy() or hud_cutin_hold: return false
	return not (option_toggle != null and not option_toggle.visible and option_toggle.get_parent().visible) # the shell's option window

func _refresh_unit_markers() -> void:
	# HUD block 4-6: each shown unit's marker above its head; off-screen, behind the camera, retreated or routed: none.
	# Values: the display value of this sync, the roster's portrait (N2, cached), the selection and the engine's own status
	# badge glyphs (N5, the HUD's status rows; held during an enemy replay like the HUD).
	# Block 4-6b: placed from the unit's projected ground point, body point and ground disc edge, sized by cell_px.
	var view_rect := get_viewport().get_visible_rect()
	for id in views:
		var root: Node3D = views[id]
		var geometry := marker_geometry(root.position)
		var chip_centre: Vector2 = UnitMarkers.layout(geometry.foot, geometry.body, geometry.disc_bottom, geometry.cell_px).chip_centre
		var on: bool = root.visible and not camera.is_position_behind(root.position) and view_rect.has_point(chip_centre)
		var status_badges: Array = hud_status_entries(id).map(func(entry): return str(entry.get("badge", ""))) if on else []
		unit_markers.show_unit(id, display_values.get(id, {}), hud_portrait(id) if on else null, id == selected, status_badges.filter(func(b): return not b.is_empty()), geometry, on)

func marker_geometry(ground: Vector3) -> Dictionary:
	# HUD block 4-6b: the unit's screen points for its marker. cell_px: one cell (board.CELL) along the camera's right on
	# the ground, projected; disc_bottom: DISC_RADIUS toward the camera on the ground (the disc's lower screen edge).
	var right := Vector3(camera.global_basis.x.x, 0, camera.global_basis.x.z).normalized()
	var toward := Vector3(camera.global_basis.z.x, 0, camera.global_basis.z.z).normalized()
	var foot := camera.unproject_position(ground)
	return {"foot":foot, "body":camera.unproject_position(ground + Vector3(0, UnitMarkers.BODY_HEIGHT, 0)),
		"disc_bottom":camera.unproject_position(ground + toward * UnitMarkers.DISC_RADIUS),
		"cell_px":foot.distance_to(camera.unproject_position(ground + right * board.CELL))}

const HIDE_TOP_LINES := true # block 4-6: the top two lines are debug text too (F3); the HUD shows round, side and momentum

func hud_turn_side() -> String:
	# HUD block 4-6: the acting side for the top HUD (the 2D adapter's "아군 턴" / "적군 턴" words), from the phase the lab
	# already reads and its own enemy replay (the replay still shows the enemy turn after the engine moved on).
	return "적군 턴" if engine.get("current_phase") == "enemy_turn" or _enemy_presentation_busy() else "아군 턴"

func _apply_debug_text() -> void:
	# HUD block 4-6: the per-unit state lines (action, defend, status) are debug text too; the markers and the HUD show
	# the same. The badges are hidden through their parent, so each badge's own visible flag still says whether its unit
	# is shown. The top turn / momentum lines too while HIDE_TOP_LINES is true (approved; test_battle3d_top_hud.gd checks
	# them hidden by default and placed clear of the HUD with F3 on).
	super._apply_debug_text()
	if turn_label: turn_label.visible = debug_text_visible or not HIDE_TOP_LINES
	if momentum_label: momentum_label.visible = debug_text_visible or not HIDE_TOP_LINES
	action_badges.visible = debug_text_visible

func _enemy_presentation_busy() -> bool:
	return not enemy_queue.is_empty() or enemy_hold > 0.0

func _wait_block_reason() -> String:
	return _ally_command_block_reason("대기")

func _defend_block_reason() -> String:
	return _ally_command_block_reason("방어")

func _ally_command_block_reason(command: String) -> String:
	# Guidance only (engine state reads); the engine re-validates the command.
	# Wait and defend share the same preconditions in the engine.
	if not battle_result.is_empty(): return "전투 종료 · %s / 모든 입력 잠금" % RESULT_TEXT.get(battle_result,battle_result)
	if engine.get("is_full_auto_battle_enabled"): return "자동 진행 중 · [자동 ■]로 중지한 뒤 조작하세요"
	var phase: String = engine.get("current_phase")
	if phase == "enemy_turn": return "적 턴 중 · 적 행동이 끝날 때까지 기다리세요"
	if engine.get("is_demo_animating"): return "연출 중 · 중복 명령을 받지 않습니다"
	if _enemy_presentation_busy(): return "적 행동 재생 중 · 재생이 끝날 때까지 기다리세요"
	if hud_cutin_hold: return "특기 연출 중 · 컷인이 끝날 때까지 기다리세요"
	if phase != "ally_turn": return "행동 불가 · 현재 선택 단계를 완료하거나 취소하세요"
	var active = engine.get("active_unit_state")
	if active == null: return "%s 불가 · 먼저 아군을 선택하세요" % command
	if Adapter.to_view(active).has_acted: return "%s 불가 · 이미 행동한 부대입니다" % command
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

func request_defend() -> void:
	if not ready_for_input or _input_locked(): return
	var reason := _defend_block_reason()
	if not reason.is_empty():
		_reject(reason)
		return
	var defending_id: String = engine.get("active_unit_state").unit_id
	var troops_before: int = Adapter.to_view(engine.get("active_unit_state")).current_troops
	var enemy_events_before: int = engine.get("enemy_action_event_log").export().size()
	enemy_baseline=_state_for_enemy_summary() # before the call: an instant enemy slot is summarised inside it
	engine.call("_on_defend_button_pressed")
	# Acceptance is read back exactly like wait: is_defending alone is not used,
	# because an instant enemy slot can start a new round and reset it.
	var defended = queries.find_unit(defending_id)
	var accepted: bool = defended != null and (Adapter.to_view(defended).has_acted or engine.get("enemy_action_event_log").export().size() > enemy_events_before)
	if not accepted:
		_reject("행동 불가 · 엔진이 방어를 수락하지 않았습니다")
		return
	_clear_range()
	_clear_attack_range()
	awaiting_enemy_result=true
	_append_combat_line("방어 · " + defending_id)
	# Troops before/after are engine values; the 3D side never computes the recovery.
	status.text="방어 · %s / 병력 %s→%s · 이후 적 자동 행동" % [defending_id,troops_before,Adapter.to_view(defended).current_troops]
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

# HUD block 4-6: the unit's facing as a flat arrow on the ground at the front of its cell (a world object, so it stays
# right when the camera turns), between the soldiers and the selection ring (r 1.27). The engine's facing (14-field view).
const FACING_DIRECTION := {"up":Vector3(0, 0, -1), "down":Vector3(0, 0, 1), "left":Vector3(-1, 0, 0), "right":Vector3(1, 0, 0)}
const FACING_ARROW_DISTANCE := 1.0 # m from the unit's centre to the arrow's centre (block 4-6b; tip at 1.43, the cell edge 1.5)
const FACING_ARROW_LIFT := 0.08 # m above the ground under the arrow (the fill; outlines sit 0.01 m lower)
# HUD block 4-6b: a bigger arrow (1.02 m wide, 0.8 m long, 1.6 x the block 4-6 one) with a dark outline, so it shows on
# the gold selected disc too. ARROW_STYLE picks one of three looks for 김작 to compare in F6:
# 0 cream fill + dark outline (recommended), 1 side colour fill + white outline + outer dark outline, 2 the old cream
# fill at the new size, no outline (for comparison).
const ARROW_STYLE := 0
const ARROW_FILL := Color("f4e7c4")
const ARROW_OUTLINE := Color("241c14")
const ARROW_ALLY := Color("5aa8ff") # style 1 fills
const ARROW_ENEMY := Color("ff6a50")
const ARROW_OUTLINE_SCALE := 1.3 # the outline: the same chevron 1.3 x bigger, just under the fill
# Seen from the battle camera (about 43 degrees down), soldiers about 1.8 m tall hide the ground up to about 1.9 m behind
# them, so an arrow facing away from the camera falls under them. With ARROW_ON_TOP the arrow is drawn after the opaque
# scene without a depth test (on top of soldiers, and also of trees or units standing in front of it).
const ARROW_ON_TOP := true
const ARROW_POINTS := [Vector3(0, 0, -0.43), Vector3(0.51, 0, 0.37), Vector3(0, 0, 0.05), Vector3(0, 0, -0.43), Vector3(0, 0, 0.05), Vector3(-0.51, 0, 0.37)]

func _facing_arrow(side: String, style: int = ARROW_STYLE) -> Node3D:
	# A flat chevron pointing -z (the "up" facing) and its outline layers, under one node turned by _place_facing_arrow.
	var arrow := Node3D.new()
	arrow.name = "FacingArrow"
	arrow.set_meta("facing_arrow", true)
	var layers := [] # [name, scale, colour, height offset, draw order]
	match style:
		0: layers = [["Outline", ARROW_OUTLINE_SCALE, ARROW_OUTLINE, -0.01, 1], ["Fill", 1.0, ARROW_FILL, 0.0, 3]]
		1: layers = [["OuterOutline", ARROW_OUTLINE_SCALE * 1.12, ARROW_OUTLINE, -0.02, 1], ["Outline", ARROW_OUTLINE_SCALE, Color.WHITE, -0.01, 2], ["Fill", 1.0, ARROW_ALLY if side == "ally" else ARROW_ENEMY, 0.0, 3]]
		_: layers = [["Fill", 1.0, ARROW_FILL, 0.0, 3]]
	for layer in layers:
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		for p in ARROW_POINTS:
			st.set_normal(Vector3.UP)
			st.add_vertex(p * float(layer[1]) + Vector3(0, float(layer[3]), 0))
		var mesh := MeshInstance3D.new()
		mesh.name = layer[0]
		mesh.mesh = st.commit()
		var material := StandardMaterial3D.new()
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
		material.albedo_color = layer[2]
		if ARROW_ON_TOP:
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA # drawn after the opaque scene
			material.no_depth_test = true
			material.render_priority = layer[4] # outline under fill
		mesh.material_override = material
		mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		arrow.add_child(mesh)
	return arrow

func _place_facing_arrow(arrow: Node3D, root: Node3D, facing: String) -> void:
	var direction: Vector3 = FACING_DIRECTION.get(facing, Vector3(0, 0, -1))
	arrow.rotation = Vector3(0, atan2(-direction.x, -direction.z), 0) # -z turned toward the facing
	var at := root.position + direction * FACING_ARROW_DISTANCE
	arrow.position = direction * FACING_ARROW_DISTANCE + Vector3(0, board.height(at.x, at.z) - root.position.y + FACING_ARROW_LIFT, 0)

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
	if not has_action_event or slot.any(func(e): return e.kind == "enemy_skill_used"): phrases.append(_state_diff_text(after)) # a skill's troop changes have no move/attack event
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
				if not enemy_slot.is_empty(): # empty when battle_ended already closed this slot (enemy skill kill)
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
		"enemy_strategy_used":
			# M4-e: the enemy's strategy choice; its outcome (strategy_cast) is shown with the slot's completion.
			_enemy_text("적 책략 사용: %s → %s" % [event.unit_id,event.target_id])
			enemy_hold = enemy_hold_seconds
		"enemy_skill_used":
			_enemy_text("적 특기 사용: " + event.skill_id)
			_open_enemy_skill(event.unit_id)
			enemy_hold = enemy_hold_seconds
		"enemy_action_completed":
			enemy_actor_id = ""
			_close_enemy_skill(event.unit_id)
			_flush_enemy_ticks(event.unit_id)
		"round_started":
			current_round = event.round
			_flush_arrivals(event.round)
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

func _strategy_block_reason() -> String:
	# Guidance only: the wait/defend preconditions plus the engine's own strategy rule.
	var reason := _ally_command_block_reason("책략")
	if not reason.is_empty(): return reason
	if not engine.call("_can_use_strategy",engine.get("active_unit_state")): return "책략 불가 · 엔진 조건(지력·혼란·행동 여부)을 충족하지 않습니다"
	if engine.call("_get_strategy_targets",engine.get("active_unit_state")).is_empty(): return "책략 불가 · 사거리 안에 적이 없습니다"
	return ""

func request_strategy() -> void:
	if not ready_for_input or _input_locked(): return
	var reason := _strategy_block_reason()
	if not reason.is_empty():
		_reject(reason)
		return
	engine.call("_on_strategy_button_pressed")
	if engine.get("current_phase") != "strategy":
		_reject("행동 불가 · 엔진이 책략을 수락하지 않았습니다")
		return
	_clear_range()
	_clear_attack_range()
	_show_strategy_targets()
	status.text = "책략 대상 선택 / 표시된 적의 성공률은 엔진 값 / 우클릭 취소"
	_sync_views()

func _show_strategy_targets() -> void:
	_clear_strategy_marks()
	var caster = engine.get("active_unit_state")
	for candidate in engine.call("_get_strategy_targets",caster):
		strategy_target_ids.append(candidate.unit_id)
		var mark := _disc(1.25,Color("3fb8c4"),.03)
		strategy_marks.add_child(mark)
		mark.position = board.world(Adapter.to_view(candidate).grid_cell)+Vector3(0,.1,0)
		var preview := Label3D.new()
		preview.text = _rate_text(engine.call("_get_strategy_success_rate",caster,candidate))
		preview.font_size = 40
		preview.pixel_size = .012
		preview.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		preview.no_depth_test = true
		preview.set_meta("strategy_preview",candidate.unit_id)
		strategy_marks.add_child(preview)
		preview.position = views[candidate.unit_id].position+Vector3(0,4.4,0)

func _rate_text(rate: float) -> String:
	# Formatting of the engine value only.
	return "성공률 %d%%" % roundi(rate*100.0)

func _clear_strategy_marks() -> void:
	strategy_target_ids.clear()
	for child in strategy_marks.get_children():
		strategy_marks.remove_child(child)
		child.queue_free()

func _strategy_target_at(cell: Vector2i):
	for candidate in engine.call("_get_strategy_targets",engine.get("active_unit_state")):
		if Adapter.to_view(candidate).grid_cell == cell: return candidate
	return null

func _hover_strategy_cell(cell: Vector2i) -> void:
	var target = _strategy_target_at(cell)
	if target == null: return
	target_id = target.unit_id
	_refresh_target_info(target)
	target_info.text += "\n책략 " + _rate_text(engine.call("_get_strategy_success_rate",engine.get("active_unit_state"),target))

func _click_strategy_cell(cell: Vector2i) -> void:
	# Only the engine's own strategy targets can be sent; anything else is refused with no engine call.
	var target = _strategy_target_at(cell)
	if target == null:
		_reject("대상 아님 · 사거리 안의 적만 책략 대상입니다")
		return
	var caster_id: String = engine.get("active_unit_state").unit_id
	var casts_before := _strategy_cast_count()
	enemy_baseline=_state_for_enemy_summary() # before the call: an instant enemy slot is summarised inside it
	engine.call("_try_use_strategy_on_target",target)
	# Acceptance is read back from the engine: a new strategy_cast exists, or the caster
	# is marked acted (an instant enemy slot can already have reset has_acted).
	var caster = queries.find_unit(caster_id)
	var accepted: bool = _strategy_cast_count() > casts_before or (caster != null and Adapter.to_view(caster).has_acted)
	if not accepted:
		_reject("행동 불가 · 엔진이 책략을 수락하지 않았습니다")
		return
	_clear_strategy_marks()
	awaiting_enemy_result=true
	_consume_tactic_events()
	_sync_views()

func _strategy_cast_count() -> int:
	return engine.get("tactic_event_log").export().filter(func(e): return e.kind == "strategy_cast").size()

func _consume_tactic_events() -> void:
	_consume_enemy_events() # enemy events first, so a tick can wait for its replayed action
	var events: Array = engine.get("tactic_event_log").export()
	while tactic_cursor < events.size():
		var event: Dictionary = events[tactic_cursor]
		tactic_cursor += 1
		match event.kind:
			"strategy_cast":
				if _skill_caster_side(event) == "enemy" and _enemy_completion_pending(event.caster_id):
					pending_enemy_strategies[event.caster_id] = pending_enemy_strategies.get(event.caster_id,[]) + [event]
				else:
					_present_strategy_cast(event)
			"status_tick":
				if _enemy_completion_pending(event.unit_id):
					pending_enemy_ticks[event.unit_id] = pending_enemy_ticks.get(event.unit_id,[]) + [event]
				else:
					_present_status_tick(event)
			"reinforcement_arrived":
				if _round_start_pending(event.round):
					pending_arrivals[event.round] = pending_arrivals.get(event.round,[]) + [event]
					held_unit_ids[event.unit_id] = true
				else:
					_present_arrival(event)
			"skill_cast", "skill_effect", "skill_finished":
				if _skill_caster_side(event) == "ally": _present_skill_event(event)
				elif enemy_skill_open.has(event.caster_id): _present_enemy_skill_event(event)
				else: pending_enemy_skills[event.caster_id] = pending_enemy_skills.get(event.caster_id,[]) + [event]
			_:
				pass # other kinds are skipped

func _enemy_completion_pending(unit_id: String) -> bool:
	for queued in enemy_queue:
		if queued.kind == "enemy_action_completed" and queued.unit_id == unit_id: return true
	return false

func _flush_enemy_ticks(unit_id: String) -> void:
	for event in pending_enemy_ticks.get(unit_id,[]): _present_status_tick(event)
	pending_enemy_ticks.erase(unit_id)

func _present_strategy_cast(event: Dictionary) -> void:
	# Every number and outcome comes from the event.
	var outcome: String = ("%s %d턴" % [STATUS_TEXT.get(event.status_id,event.status_id),event.turns_after]) if event.success else "실패"
	var prefix := "적 " if _skill_caster_side(event) == "enemy" else "" # M4-e: enemy casts read like the M4-c2 enemy skill lines
	tactic_presentations.append(event.duplicate(true))
	_tactic_label(event.target_id,outcome,Color("7ff2c8") if event.success else Color("ff5f78"))
	_append_combat_line(prefix + "책략 · %s → %s · %s · %s (%s)" % [event.caster_id,event.target_id,"성공" if event.success else "실패",outcome,_rate_text(event.success_rate)])
	_tactic_text(prefix + "책략 %s · %s" % ["성공" if event.success else "실패",outcome])

func _present_status_tick(event: Dictionary) -> void:
	tactic_presentations.append(event.duplicate(true))
	if event.burn_damage > 0:
		_tactic_label(event.unit_id,"화상 −%d" % event.burn_damage,Color("ff9a4a"))
		_append_combat_line("화상 · %s −%d" % [event.unit_id,event.burn_damage])
		_tactic_text("화상 · %s −%d" % [event.unit_id,event.burn_damage])
	for status_id in event.expired:
		_tactic_label(event.unit_id,"%s 해제" % STATUS_TEXT.get(status_id,status_id),Color("c8d6e0"))
		_tactic_text("%s 해제 · %s" % [STATUS_TEXT.get(status_id,status_id),event.unit_id])

func _tactic_text(line: String) -> void:
	tactic_texts.append(line)
	status.text = line

func _tactic_label(unit_id: String, text: String, color: Color) -> void:
	if not views.has(unit_id): return
	var label := Label3D.new()
	label.text = text
	label.font_size = 52
	label.pixel_size = .014
	label.modulate = color
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.set_meta("tactic_label",true)
	add_child(label)
	label.position = views[unit_id].position+Vector3(0,4.8,0)
	var tween := create_tween()
	tween.tween_property(label,"position:y",label.position.y+1.2,1.6)
	tween.parallel().tween_property(label,"modulate:a",0.0,1.6)
	tween.tween_callback(label.queue_free)

func _status_suffix(unit_id: String, value: Dictionary) -> String:
	# Engine status_effects (adapter field), refreshed only while no enemy replay is
	# pending, so a replay never shows the end state early.
	if not _enemy_presentation_busy(): status_display[unit_id] = value.status_effects.duplicate(true)
	var text := _status_text(status_display.get(unit_id,{}))
	return "" if text.is_empty() else " · " + text

func _status_text(effects: Dictionary) -> String:
	var parts: Array[String] = []
	var ids: Array = effects.keys()
	ids.sort()
	for status_id in ids:
		var raw = effects[status_id]
		parts.append("%s %d턴" % [STATUS_TEXT.get(status_id,status_id),int(raw.get("turns",0)) if raw is Dictionary else int(raw)])
	return " ".join(parts)

func _unit_shown(unit_id: String) -> bool:
	# The engine's deployed flag decides visibility; a unit whose arrival event is
	# held for the enemy replay stays hidden until that round's round_started is shown.
	return not held_unit_ids.has(unit_id)

func _waiting_unit_at(cell: Vector2i) -> bool:
	# A cell holding a live unit that is not deployed yet (or whose arrival is held)
	# is never sent to the engine.
	for candidate in queries.alive_units:
		var value: Dictionary = Adapter.to_view(candidate)
		if value.grid_cell == cell and value.current_troops > 0 and (not engine.call("_is_unit_state_available_for_battle_slot",candidate) or not _unit_shown(value.unit_id)): return true
	return false

func _round_start_pending(round_number: int) -> bool:
	for queued in enemy_queue:
		if queued.kind == "round_started" and queued.round == round_number: return true
	return false

func _flush_arrivals(round_number: int) -> void:
	for event in pending_arrivals.get(round_number,[]): _present_arrival(event)
	pending_arrivals.erase(round_number)

func _present_arrival(event: Dictionary) -> void:
	# Unit, side and cell come from the event; the engine cell wins if they ever differ.
	var unit = queries.find_unit(event.unit_id)
	if unit == null: return
	var cell: Vector2i = Adapter.to_view(unit).grid_cell
	var event_cell := Vector2i(event.cell[0],event.cell[1])
	held_unit_ids.erase(event.unit_id)
	arrival_presentations.append(event.duplicate(true))
	var side_text: String = "아군" if event.side == "ally" else "적군"
	var line := "지원군 도착 · %s · %s" % [side_text,event.unit_id]
	if cell != event_cell: line += " (엔진 셀 %s 우선, 이벤트 셀 %s)" % [cell,event_cell]
	arrival_texts.append(line)
	_append_combat_line(line)
	status.text = line
	if not views.has(event.unit_id): return
	views[event.unit_id].position = board.world(cell)
	var label := Label3D.new()
	label.text = "지원군 도착"
	label.font_size = 52
	label.pixel_size = .014
	label.modulate = Color("9fd3ff") if event.side == "ally" else Color("ffb0a0")
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.set_meta("arrival_label",event.unit_id)
	add_child(label)
	label.position = board.world(cell)+Vector3(0,4.8,0)
	var tween := create_tween()
	tween.tween_property(label,"position:y",label.position.y+1.2,2.0)
	tween.parallel().tween_property(label,"modulate:a",0.0,2.0)
	tween.tween_callback(label.queue_free)

func _skill_block_reason() -> String:
	# Guidance only (engine reads); the engine re-validates the command. The cost is the
	# skill data's momentum_cost as the engine returns it, never computed here.
	var reason := _ally_command_block_reason("특기")
	if not reason.is_empty(): return reason
	var caster = engine.get("active_unit_state")
	var skill: Dictionary = engine.call("_get_unique_skill_for_unit",caster)
	if skill.is_empty(): return "특기 불가 · 고유특기가 없는 부대입니다"
	var momentum: int = engine.get("battle_momentum").get_value("ally")
	if momentum < int(skill.get("momentum_cost",0)): return "특기 불가 · 기세가 부족합니다 (필요 %d / 현재 %d)" % [skill.get("momentum_cost",0),momentum]
	if engine.call("_get_unique_skill_valid_targets",caster,skill).is_empty(): return "특기 불가 · 유효 대상이 없습니다"
	if not engine.call("_can_use_unique_skill",caster): return "특기 불가 · 엔진 조건을 충족하지 않습니다"
	return ""

func request_skill() -> void:
	if not ready_for_input or _input_locked(): return
	var reason := _skill_block_reason()
	if not reason.is_empty():
		_reject(reason)
		return
	var caster = engine.get("active_unit_state")
	var auto: bool = engine.call("_should_unique_skill_resolve_without_manual_target",engine.call("_get_unique_skill_for_unit",caster))
	enemy_baseline=_state_for_enemy_summary()
	engine.call("_on_unique_skill_button_pressed")
	# Acceptance is read back from the engine: target select opened, and for the three
	# self-resolving modes the engine's own preview started (it then fires by itself).
	var accepted: bool = engine.get("current_phase") == "unique_skill_target_select" and (engine.get("is_manual_unique_skill_preview_pending") or not auto)
	if not accepted:
		_reject("행동 불가 · 엔진이 특기를 수락하지 않았습니다")
		return
	_clear_range()
	_clear_attack_range()
	if auto:
		awaiting_enemy_result=true
		status.text = "특기 발동 대기 · 엔진이 대상을 정해 발동합니다 / 입력 잠금"
	else:
		_show_skill_targets()
		status.text = "특기 대상 선택 / 보라: 엔진 유효 대상 / 우클릭 취소"
	_sync_views()

func _show_skill_targets() -> void:
	_clear_skill_marks()
	var caster = engine.get("active_unit_state")
	for candidate in engine.call("_get_unique_skill_valid_targets",caster,engine.call("_get_unique_skill_for_unit",caster)):
		skill_target_ids.append(candidate.unit_id)
		var mark := _disc(1.25,Color("b46ee0"),.03)
		skill_marks.add_child(mark)
		mark.position = board.world(Adapter.to_view(candidate).grid_cell)+Vector3(0,.1,0)

func _clear_skill_marks() -> void:
	skill_target_ids.clear()
	for child in skill_marks.get_children():
		skill_marks.remove_child(child)
		child.queue_free()

func _skill_target_at(cell: Vector2i):
	var caster = engine.get("active_unit_state")
	for candidate in engine.call("_get_unique_skill_valid_targets",caster,engine.call("_get_unique_skill_for_unit",caster)):
		if Adapter.to_view(candidate).grid_cell == cell: return candidate
	return null

func _click_skill_cell(cell: Vector2i) -> void:
	# Only the engine's own valid targets can be sent; anything else is refused with no engine call.
	var target = _skill_target_at(cell)
	if target == null:
		_reject("대상 아님 · 표시된 부대만 특기 대상입니다")
		return
	var casts_before := _skill_cast_count()
	enemy_baseline=_state_for_enemy_summary()
	engine.call("_try_use_unique_skill_on_target",target)
	# Acceptance is a new skill_cast (the commit); has_acted is set only after the presentation.
	if _skill_cast_count() == casts_before:
		_reject("행동 불가 · 엔진이 특기를 수락하지 않았습니다")
		return
	_clear_skill_marks()
	awaiting_enemy_result=true
	_consume_tactic_events()
	_sync_views()

func _skill_cast_count() -> int:
	return engine.get("tactic_event_log").export().filter(func(e): return e.kind == "skill_cast").size()

func _skill_caster_side(event: Dictionary) -> String:
	# skill_effect / skill_finished carry no side: the caster's adapter side decides.
	var unit = queries.find_unit(event.caster_id)
	return "" if unit == null else Adapter.to_view(unit).side

func _skill_name(event: Dictionary) -> String:
	# The caster's engine skill data (pure read) when it is the cast skill; the raw skill_id otherwise.
	var unit = queries.find_unit(event.caster_id)
	var skill: Dictionary = {} if unit == null else engine.call("_get_unique_skill_for_unit",unit)
	return String(skill.get("display_name",event.skill_id)) if skill.get("skill_id","") == event.skill_id else event.skill_id

func _present_skill_event(event: Dictionary) -> void:
	# Every number, id and outcome comes from the event; 3D computes nothing.
	if hud_cutin_hold: # HUD block 5: a cut-in is playing; shown when it ends
		hud_held_skill_events.append([event.duplicate(true), presenting_enemy_skill])
		return
	if hud_cutin_enabled and event.kind == "skill_cast":
		hud_skill_casts.append(event.duplicate(true))
		hud_cutin_hold = true
	if presenting_enemy_skill: enemy_skill_presentations.append(event.duplicate(true))
	else: skill_presentations.append(event.duplicate(true))
	match event.kind:
		"skill_cast":
			if not presenting_enemy_skill: momentum_note = ""
			var skill_name := _skill_name(event)
			_skill_label(event.caster_id,skill_name,Color("e8b8ff"))
			_skill_line("특기 · %s · %s (기세 −%d)" % [event.caster_id,skill_name,event.momentum_cost])
		"skill_effect":
			_present_skill_effect(event)
		"skill_finished":
			_skill_line("특기 종료 · %s%s" % [event.caster_id,"" if event.cooldown_turns == 0 else " · 쿨다운 %d턴" % event.cooldown_turns])

func _present_skill_effect(event: Dictionary) -> void:
	var target: String = event.target_id
	var status_name: String = STATUS_TEXT.get(event.status_id,event.status_id)
	match event.effect_kind:
		"damage":
			_skill_label(target,"−%d%s" % [event.amount,"\n격파" if event.killed else ""],Color("ffe49b"))
			_skill_line("특기 피해 · %s −%d%s%s" % [target,event.amount," · 격파" if event.killed else "","" if event.status_id.is_empty() else " · " + event.status_id])
		"heal":
			_skill_label(target,"+%d" % event.amount,Color("8fe39a"))
			_skill_line("특기 회복 · %s +%d" % [target,event.amount])
		"status":
			_skill_label(target,"%s %d턴" % [status_name,event.turns_after],Color("7ff2c8"))
			_skill_line("특기 상태 · %s · %s %d턴" % [target,status_name,event.turns_after])
		"cleanse":
			_skill_label(target,"%s 해제" % status_name,Color("c8d6e0"))
			_skill_line("특기 해제 · %s · %s 해제" % [target,status_name])
		"momentum":
			var note := "%s 기세 %+d" % ["아군" if target == "ally" else "적",event.amount]
			if not presenting_enemy_skill: momentum_note = note
			_skill_line("특기 기세 · " + note)
		"move":
			_skill_line("특기 이동 · %s 이동 %s → %s" % [target,_cell_text(event.from_cell),_cell_text(event.to_cell)])

func _cell_text(cell: Array) -> String:
	return "(%d, %d)" % [cell[0],cell[1]]

func _skill_line(line: String) -> void:
	if presenting_enemy_skill:
		line = "적 " + line
		enemy_skill_texts.append(line)
		_append_combat_line(line)
		status.text = line
		return
	skill_texts.append(line)
	_append_combat_line(line)
	status.text = line

func _skill_label(unit_id: String, text: String, color: Color) -> void:
	if not views.has(unit_id): return
	var label := Label3D.new()
	label.text = text
	label.font_size = 52
	label.pixel_size = .014
	label.modulate = color
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.set_meta("enemy_skill_label" if presenting_enemy_skill else "skill_label",unit_id)
	add_child(label)
	label.position = views[unit_id].position+Vector3(0,4.8,0)
	var tween := create_tween()
	tween.tween_property(label,"position:y",label.position.y+1.2,1.6)
	tween.parallel().tween_property(label,"modulate:a",0.0,1.6)
	tween.tween_callback(label.queue_free)

func _present_enemy_skill_event(event: Dictionary) -> void:
	# The M4-c1 indicators with the "적 " prefix, their own lists and label meta.
	presenting_enemy_skill = true
	_present_skill_event(event)
	presenting_enemy_skill = false

func _open_enemy_skill(caster_id: String) -> void:
	# Replay reached the caster's enemy_skill_used: show what arrived, the rest as it arrives.
	enemy_skill_open[caster_id] = true
	for event in pending_enemy_skills.get(caster_id,[]): _present_enemy_skill_event(event)
	pending_enemy_skills.erase(caster_id)

func _close_enemy_skill(caster_id: String) -> void:
	enemy_skill_open.erase(caster_id)
	if pending_enemy_skills.has(caster_id):
		enemy_skill_leftovers.append({"caster_id":caster_id, "events":pending_enemy_skills[caster_id].duplicate(true)})
	# Held strategy casts and status ticks of this enemy, together in log order.
	var held: Array = pending_enemy_strategies.get(caster_id,[]) + pending_enemy_ticks.get(caster_id,[])
	held.sort_custom(func(a, b): return a.sequence < b.sequence)
	pending_enemy_strategies.erase(caster_id)
	pending_enemy_ticks.erase(caster_id)
	for event in held:
		if event.kind == "strategy_cast": _present_strategy_cast(event)
		else: _present_status_tick(event)

func _build_auto_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	auto_button = Button.new()
	auto_button.text = "자동 ▶"
	auto_button.position = Vector2(600,300)
	auto_button.custom_minimum_size = Vector2(150,38)
	auto_button.pressed.connect(request_auto)
	layer.add_child(auto_button)
	speed_button = Button.new()
	speed_button.position = Vector2(760,300)
	speed_button.custom_minimum_size = Vector2(110,38)
	speed_button.pressed.connect(cycle_speed)
	layer.add_child(speed_button)
	_apply_speed()

func request_auto() -> void:
	# Start and stop are the same engine command; acceptance is read back from the engine flag.
	if not ready_for_input: return
	if auto_press_pending:
		_reject("연타 · 같은 순간의 두 번째 입력은 보내지 않습니다")
		return
	var was_on: bool = engine.get("is_full_auto_battle_enabled")
	if not was_on:
		if _input_locked(): return
		var reason := _ally_command_block_reason("자동")
		if not reason.is_empty():
			_reject(reason)
			return
	auto_press_pending = true
	engine.call("_toggle_full_auto_battle")
	if engine.get("is_full_auto_battle_enabled") == was_on:
		_reject("행동 불가 · 엔진이 자동전투를 %s 않았습니다" % ("끄지" if was_on else "시작하지"))
		return
	auto_was_on = not was_on
	_update_auto_hold()
	if was_on:
		_auto_text("자동 중지 · 진행 중인 행동이 끝나면 수동 조작")
	else:
		_clear_range()
		_clear_attack_range()
		_auto_text(AUTO_STATUS)
	_sync_views()

func cycle_speed() -> void:
	# Presentation speed only (3D state); never an engine command.
	speed_index = (speed_index + 1) % SPEED_STEPS.size()
	_apply_speed()

func _apply_speed() -> void:
	Engine.time_scale = SPEED_STEPS[speed_index]
	speed_button.text = "속도 %dx" % int(SPEED_STEPS[speed_index])

func _exit_tree() -> void:
	Engine.time_scale = 1.0 # never leak a lab speed into the next scene or test
	_update_auto_hold(true) # never leave the engine auto held

func _build_option_ui() -> void:
	# A separate top-right area, clear of the command rows (y=254 / y=300) and the turn header.
	var layer := CanvasLayer.new()
	add_child(layer)
	var size := get_viewport().get_visible_rect().size
	var box := VBoxContainer.new()
	box.position = Vector2(size.x-230,16)
	box.custom_minimum_size = Vector2(210,0)
	layer.add_child(box)
	option_toggle = Button.new()
	option_toggle.text = "옵션 ▾"
	option_toggle.pressed.connect(toggle_option_panel)
	box.add_child(option_toggle)
	option_panel = VBoxContainer.new()
	box.add_child(option_panel)
	ai_level_label = Label.new()
	ai_level_label.add_theme_font_size_override("font_size",15)
	ai_level_label.add_theme_color_override("font_outline_color",Color.BLACK)
	ai_level_label.add_theme_constant_override("outline_size",5)
	ai_level_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ai_level_label.custom_minimum_size = Vector2(210,0)
	option_panel.add_child(ai_level_label)
	var row := HBoxContainer.new()
	option_panel.add_child(row)
	for level in AI_LEVEL_ORDER:
		var button := Button.new()
		button.text = AI_LEVEL_TEXT[level]
		button.custom_minimum_size = Vector2(64,34)
		button.toggle_mode = true # shows the engine's level; reset from the engine on every refresh
		button.pressed.connect(request_ai_level.bind(level))
		row.add_child(button)
		ai_level_buttons[level] = button
	edge_scroll_check = CheckBox.new()
	edge_scroll_check.text = "화면 가장자리 스크롤"
	edge_scroll_check.button_pressed = edge_scroll_enabled
	edge_scroll_check.toggled.connect(func(on: bool): edge_scroll_enabled = on)
	option_panel.add_child(edge_scroll_check)

func toggle_option_panel() -> void:
	# Presentation only (folds the panel); never an engine command.
	option_panel.visible = not option_panel.visible
	option_toggle.text = "옵션 ▾" if option_panel.visible else "옵션 ▸"

func request_ai_level(level: String) -> void:
	# The engine accepts a level at any time and applies it from the next enemy turn; the
	# panel is usable during auto, the enemy turn and input locks (no _input_locked here).
	if not ready_for_input: return
	if not engine.call("set_enemy_ai_level", level):
		_ai_level_text("적 AI 변경 거절 · 엔진이 %s 등급을 받지 않았습니다" % AI_LEVEL_TEXT.get(level, level))
		return
	_refresh_option_ui()
	_ai_level_text("적 AI 선택 · " + ai_level_label.text)

func _refresh_option_ui() -> void:
	var current: String = engine.call("get_enemy_ai_level")
	var pending: String = engine.call("get_pending_enemy_ai_level")
	ai_level_label.text = "적 AI: %s" % AI_LEVEL_TEXT.get(current, current)
	if not pending.is_empty(): ai_level_label.text += " → %s (다음 적 턴부터 적용)" % AI_LEVEL_TEXT.get(pending, pending)
	for level in ai_level_buttons:
		ai_level_buttons[level].button_pressed = level == (current if pending.is_empty() else pending)

func _ai_level_text(line: String) -> void:
	ai_level_texts.append(line)
	_append_combat_line(line)
	status.text = line

func _presentation_busy() -> bool:
	# M5-a2: what the auto play waits for: the engine still acting (animating or in an enemy slot),
	# a move playback (ally or enemy), the enemy replay queue and hold, or engine events not consumed
	# yet (cursor behind the log). Floating labels (damage, skill, strategy) are not waited for.
	if engine.get("is_demo_animating") or engine.get("current_phase") == "enemy_turn": return true
	if not playback.is_empty() or _enemy_presentation_busy(): return true
	if hud_cutin_hold or not hud_held_skill_events.is_empty(): return true # HUD block 5: a cut-in is playing
	return event_cursor < engine.get("ally_move_event_log").export().size() or action_cursor < engine.get("battle_action_event_log").export().size() \
		or enemy_cursor < engine.get("enemy_action_event_log").export().size() or tactic_cursor < engine.get("tactic_event_log").export().size()

func _update_auto_hold(closing := false) -> void:
	# M5-a2: hold the engine auto tick while the 3D presentation runs. Sent on a change only; always
	# false when auto is off, the battle has a result, or the lab leaves the tree.
	# F2: the engine re-arms the hold at every auto step (latch), so the value is also compared with
	# the engine's own hold: a latched hold is released even when the last value sent was false.
	if not is_instance_valid(engine): return
	var hold: bool = not closing and engine.get("is_full_auto_battle_enabled") and battle_result.is_empty() and _presentation_busy()
	var engine_hold: bool = engine.get("auto_presentation_hold")
	if hold == auto_hold_sent and hold == engine_hold: return
	auto_hold_sent = hold
	engine.call("set_auto_presentation_hold", hold)

func _refresh_auto_ui() -> void:
	var on: bool = engine.get("is_full_auto_battle_enabled")
	auto_button.text = "자동 ■ (중지)" if on else "자동 ▶"
	auto_button.disabled = not on and not _ally_command_block_reason("자동").is_empty()
	if on or auto_was_on: _note_quiet_auto_actions()
	if auto_was_on and not on:
		# The engine turned auto off by itself (battle end, safety limit, no ally that can act).
		auto_was_on = false
		_auto_text("자동 종료 · 엔진이 자동전투를 껐습니다" + ("" if battle_result.is_empty() else " · " + RESULT_TEXT.get(battle_result,battle_result)))

func _note_quiet_auto_actions() -> void:
	# Auto waits and confused turns leave no ally event: shown when the engine marks the ally acted
	# without a new action_completed / skill_cast / strategy_cast for it.
	var completed: Array = engine.get("battle_action_event_log").export().filter(func(e): return e.kind == "action_completed")
	var casts: Array = engine.get("tactic_event_log").export().filter(func(e): return e.kind in ["skill_cast", "strategy_cast"])
	for unit in queries.alive_units:
		var value: Dictionary = Adapter.to_view(unit)
		if value.side != "ally" or not engine.call("_is_unit_state_available_for_battle_slot",unit): continue
		var counts := [completed.filter(func(e): return e.unit_id == value.unit_id).size(), casts.filter(func(e): return e.caster_id == value.unit_id).size()]
		if not value.has_acted:
			auto_marks[value.unit_id] = counts
		elif auto_marks.has(value.unit_id):
			if auto_marks[value.unit_id] == counts: _auto_text("자동 · %s 행동 완료 (대기 또는 혼란: 엔진 이벤트 없음)" % value.unit_id)
			auto_marks.erase(value.unit_id)

func _auto_text(line: String) -> void:
	auto_texts.append(line)
	_append_combat_line(line)
	status.text = line
