extends Node
# M5-b: scenario start screen, result overlay and new battle around the M3-M5
# 3D lab. A scenario is only an engine start setup (`samwar_battle_setup`, read
# once by the engine in `_ready`); the shell sets it right before it creates a
# new lab and never writes engine state. The result overlay shows engine values
# only (the lab's `battle_ended` result, its round from the engine events and
# the allied units the engine still has alive). A new battle frees the whole lab
# (engine host included) and creates a fresh one; nothing is carried over.
const LAB_SCENE := "res://scenes/battle3d/Battle3D_EnginePlayLab.tscn"
const TOP_HUD_SCENE := "res://scenes/battle3d/Battle3D_TopHud.tscn"
const Adapter = preload("res://scripts/battle3d/battle3d_unit_adapter.gd")
const SETUP_KEY := "samwar_battle_setup"
const WIN_PRACTICE_RATIO := 0.25
const ENEMY_IDS := ["guan_yu", "zhang_fei", "xiahou_dun", "enemy_reinforce_01_demo", "enemy_reinforce_02_test_unit"]
const SCENARIO_ORDER := ["default", "win_practice"]
const SCENARIO_LABELS := {"default":"기본 배치", "win_practice":"승리 연습 (적 병력 1/4)"}
var lab: Node = null
var scenario := ""
var layer: CanvasLayer
var start_panel: VBoxContainer
var scenario_buttons := {}
var result_panel: VBoxContainer
var result_label: Label
var restart_button: Button
var choose_button: Button
var result_text := ""
var lab_count := 0
# HUD spike: the 2D top HUD as an overlay (layer 5, under the shell's layer 10).
# It shows the lab's momentum_display and current_round only (no engine call).
# The lab's own round/momentum text labels sat in the same screen area; the
# shell moves them (position and size only) to two lines right under the HUD
# frame, each as wide as its text and centred on the HUD. They stay visible.
# The lab's left info panel grows with the selected unit's status list; when it
# reaches under the labels they shift right of it (same gap).
const LAB_LABEL_GAP := 6.0 # below the HUD frame
var top_hud # Battle3D_TopHud.tscn (CanvasLayer with battle3d_top_hud.gd)
# HUD block 1: the 2D top command buttons (option, speed, auto, end turn,
# retreat) in the 2D row (layer 6). They call the lab's own functions only. The
# lab's auto and speed buttons are moved off-screen (kept for the lab tests);
# the lab's option box opens under the option button, closed by default.
# The lab's debug "부대 상태" text (roster_label) is moved off-screen the same way:
# its text keeps updating for the lab tests; the 2D rosters take its place.
const TopCommands = preload("res://scripts/battle3d/battle3d_top_commands.gd")
const LAB_OFFSCREEN_X := 4000.0
const OPTION_BOX_GAP := 6.0 # below the command row
# HUD block 6a: the option box opens clear of the HUD (rosters, current-actor panel, log, top HUD, top commands): under
# the option button, moved left past what it would cover; it is drawn above every HUD layer in any case.
const OPTION_LAYER := 20 # the HUD uses 5-10
var top_commands: CanvasLayer
var commands_lab: Node = null # the lab whose controls were last moved
# HUD block 2: the 2D battle log panel (layer 5). Its lines come from one place,
# `log_lines()`: the lab's read of the engine's 2D log (shown at once, not held
# back for the 3D replay). Shown and hidden with the top HUD, like the 2D.
const LOG_HUD_SCENE := "res://scenes/battle3d/Battle3D_LogHud.tscn"
var log_hud # Battle3D_LogHud.tscn (CanvasLayer with battle3d_log_hud.gd)
# HUD block 3: the 2D enemy roster (layer 5). The cards are built in one place,
# `enemy_cards()`, from the lab's values (views, display_values, enemy_actor_id)
# and the lab's four approved reads (hud_display_name, hud_portrait,
# hud_troop_icon, hud_status_summary). Shown and hidden with the top HUD.
const ENEMY_ROSTER_SCENE := "res://scenes/battle3d/Battle3D_EnemyRosterHud.tscn"
var enemy_roster # Battle3D_EnemyRosterHud.tscn (CanvasLayer with battle3d_enemy_roster_hud.gd)
# HUD block 4-1: the 2D ally roster and current-actor panel (layer 5). The ally
# cards are built in one place, `ally_cards()` (like `enemy_cards()`, plus the
# ready icon from the lab's _can_use_unique_skill read and the gold frame on
# the lab's hud_ally_actor_id), and the actor values in one place,
# `current_actor()`: the engine's active unit, the lab's reads (N1-N3, N5, N6,
# the unique skill) and the hero data reader (registry stats, profile, skill,
# current-actor portrait). Shown and hidden with the top HUD.
const ALLY_ROSTER_SCENE := "res://scenes/battle3d/Battle3D_AllyRosterHud.tscn"
const CURRENT_ACTOR_SCENE := "res://scenes/battle3d/Battle3D_CurrentActorHud.tscn"
const HeroData = preload("res://scripts/battle3d/battle3d_hero_data_reader.gd")
var ally_roster # Battle3D_AllyRosterHud.tscn (CanvasLayer with battle3d_ally_roster_hud.gd)
var actor_hud # Battle3D_CurrentActorHud.tscn (CanvasLayer with battle3d_current_actor_hud.gd)
# HUD block 4-2: the 2D floating command panel and facing arrows (layer 7). Its
# state is built in one place, `command_state()`: the lab's open rule, the
# lab's own (hidden) buttons' disabled/tooltip, the unique skill name and its N7
# cost, and screen points from the lab camera (the unit model, the move-range
# cells, the four neighbour cells). Its buttons call only the lab's request_*
# and confirm_facing. The lab's five buttons and facing row move off-screen and
# its info box is hidden (kept, still updated) in `_place_lab_commands`.
const COMMAND_PANEL_SCENE := "res://scenes/battle3d/Battle3D_CommandPanel.tscn"
const PANEL_ANCHOR_HEIGHT := 1.6 # metres above the unit model's root: the panel follows the model, not the cell
const FACING_ARROW_SCALE := 0.96 # 2D FACING_ARROW_BUTTON_SIZE_SCALE
const FACING_OFFSETS := {"up":Vector2i(0, -1), "down":Vector2i(0, 1), "left":Vector2i(-1, 0), "right":Vector2i(1, 0)} # 2D grid directions
const FACING_TEXT := {"up":"↑", "down":"↓", "left":"←", "right":"→"}
var command_panel # Battle3D_CommandPanel.tscn (CanvasLayer with battle3d_command_panel.gd)

# HUD block 5: the 2D hero cut-in, battle toasts, still skill toast and ending
# video (layers 8-9). The lab records each presented skill_cast and holds its
# skill events while a cut-in plays (lab.hud_cutin_enabled); the shell plays the
# registry's video for the caster (the cut-in reader; the hero id from the
# lab's unique-skill read, the 2D owner match with N6) and releases the hold
# once the cut-in schedule ended and the cast's next event has arrived. Rounds
# and arrivals come from the lab's own event reads; the ending video plays
# before the result panel.
const CUTIN_TOAST_SCENE := "res://scenes/battle3d/Battle3D_CutinToastHud.tscn"
const CutinReader = preload("res://scripts/battle3d/battle3d_cutin_reader.gd")
const CUTIN_EVENT_WAIT_SEC := 8.0 # after the cut-in schedule, the longest wait for the cast's next event (then released anyway)
var cutin_hud # Battle3D_CutinToastHud.tscn (Node with battle3d_cutin_toast_hud.gd)
var cast_cursor := 0
var toasted_round := 0
var arrival_cursor := 0
var toasted_arrival_rounds := {}
var ending_started := false
var cutin_log: Array = [] # per cast: {caster, skill_id, route ("video"/"still"), owner}
# HUD block 4-3: the camera centres the acting ally in the screen area the HUD leaves free, once per ally turn
# (round + unit), with a short ease. Not during auto, a cut-in, the enemy turn or its replay; the player's own camera
# input (WASD/arrows, Q/E, Home, wheel, middle drag) stops it for that turn. Enemy turns are not followed.
const CameraCenter = preload("res://scripts/battle3d/battle3d_camera_center.gd")
const CAMERA_CENTER_SEC := 0.35
const CAMERA_KEYS := [KEY_W, KEY_A, KEY_S, KEY_D, KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT, KEY_Q, KEY_E, KEY_HOME]
var centred_turn := "" # the ally turn ("round:unit") the camera was last centred for
var manual_camera_turn := "" # the ally turn in which the player moved the camera
var camera_tween: Tween
var camera_target := Vector3.INF # the focus the last centring went to (for tests)

func _ready() -> void:
	layer = CanvasLayer.new()
	layer.layer = 10 # above the lab's own UI layers
	add_child(layer)
	top_hud = load(TOP_HUD_SCENE).instantiate()
	top_hud.visible = false
	top_hud.refresh = _refresh_top_hud
	add_child(top_hud)
	top_commands = TopCommands.new()
	top_commands.layer = 6
	top_commands.visible = false
	top_commands.on_option = toggle_option_box
	top_commands.on_speed = func(): lab.cycle_speed()
	top_commands.on_auto = func(): lab.request_auto()
	top_commands.on_end_turn = func(): lab.request_wait()
	add_child(top_commands)
	log_hud = load(LOG_HUD_SCENE).instantiate()
	log_hud.visible = false
	add_child(log_hud)
	enemy_roster = load(ENEMY_ROSTER_SCENE).instantiate()
	enemy_roster.visible = false
	add_child(enemy_roster)
	ally_roster = load(ALLY_ROSTER_SCENE).instantiate()
	ally_roster.visible = false
	add_child(ally_roster)
	actor_hud = load(CURRENT_ACTOR_SCENE).instantiate()
	actor_hud.visible = false
	add_child(actor_hud)
	command_panel = load(COMMAND_PANEL_SCENE).instantiate()
	command_panel.on_attack = func(): lab.request_attack()
	command_panel.on_skill = func(): lab.request_skill()
	command_panel.on_strategy = func(): lab.request_strategy()
	command_panel.on_defend = func(): lab.request_defend()
	command_panel.on_wait = func(): lab.request_wait()
	command_panel.on_facing = func(direction: String): lab.confirm_facing(direction)
	add_child(command_panel)
	cutin_hud = load(CUTIN_TOAST_SCENE).instantiate()
	cutin_hud.on_ending_done = _on_ending_done
	add_child(cutin_hud)
	start_panel = VBoxContainer.new()
	start_panel.position = Vector2(500,260)
	layer.add_child(start_panel)
	var title := Label.new()
	title.text = "EASTWAR 3D 전투 · 시나리오 선택"
	title.add_theme_font_size_override("font_size",32)
	start_panel.add_child(title)
	for id in SCENARIO_ORDER:
		var button := Button.new()
		button.text = SCENARIO_LABELS[id]
		button.custom_minimum_size = Vector2(320,48)
		button.pressed.connect(start_scenario.bind(id))
		start_panel.add_child(button)
		scenario_buttons[id] = button
	result_panel = VBoxContainer.new()
	result_panel.position = Vector2(470,470)
	result_panel.visible = false
	layer.add_child(result_panel)
	result_label = Label.new()
	result_label.add_theme_font_size_override("font_size",28)
	result_label.add_theme_color_override("font_outline_color",Color.BLACK)
	result_label.add_theme_constant_override("outline_size",8)
	result_panel.add_child(result_label)
	var row := HBoxContainer.new()
	result_panel.add_child(row)
	restart_button = Button.new()
	restart_button.text = "다시 시작"
	restart_button.custom_minimum_size = Vector2(160,44)
	restart_button.pressed.connect(restart)
	row.add_child(restart_button)
	choose_button = Button.new()
	choose_button.text = "시나리오 선택"
	choose_button.custom_minimum_size = Vector2(160,44)
	choose_button.pressed.connect(choose_scenario)
	row.add_child(choose_button)

func create_lab() -> Node:
	# Test shells may swap the lab's engine host for an observing one before it enters the tree.
	return load(LAB_SCENE).instantiate()

static func scenario_setup(id: String) -> Dictionary:
	# The engine start setup of a scenario ({} = the untouched default battle).
	if id != "win_practice": return {}
	var overrides := {}
	for unit_id in ENEMY_IDS: overrides[unit_id] = {"troops_ratio":WIN_PRACTICE_RATIO}
	return {"unit_overrides":overrides}

func start_scenario(id: String) -> void:
	if not SCENARIO_LABELS.has(id): return
	_close_lab()
	scenario = id
	var setup := scenario_setup(id)
	if not setup.is_empty(): Engine.set_meta(SETUP_KEY, setup) # read and removed by the engine in its _ready
	lab = create_lab()
	lab.hud_cutin_enabled = true
	lab.edge_scrolled.connect(_on_edge_scrolled) # block 4-4
	add_child(lab)
	lab_count += 1
	start_panel.visible = false
	result_panel.visible = false
	result_text = ""

func restart() -> void:
	start_scenario(scenario)

func choose_scenario() -> void:
	_close_lab()
	result_panel.visible = false
	start_panel.visible = true

func _close_lab() -> void:
	if cutin_hud != null: cutin_hud.reset()
	cast_cursor = 0
	toasted_round = 0
	arrival_cursor = 0
	toasted_arrival_rounds.clear()
	ending_started = false
	cutin_log.clear()
	centred_turn = ""
	manual_camera_turn = ""
	if is_instance_valid(camera_tween): camera_tween.kill()
	if Engine.has_meta(SETUP_KEY): Engine.remove_meta(SETUP_KEY) # never left for the next battle
	if lab == null or not is_instance_valid(lab): return
	var grid = lab.queries.grid # the engine's ISO grid projection lives outside the tree
	remove_child(lab)
	lab.free() # the lab restores Engine.time_scale and releases the auto hold in _exit_tree
	lab = null
	if is_instance_valid(grid) and grid.get_parent() == null: grid.free()

func _process(_delta: float) -> void:
	if lab == null or not is_instance_valid(lab) or not lab.ready_for_input or result_panel.visible: return
	if lab.battle_result.is_empty() or lab._enemy_presentation_busy(): return
	if lab.hud_cutin_hold or not lab.hud_held_skill_events.is_empty(): return # block 5: the last cut-in and its effects first
	_begin_ending()

func _refresh_top_hud() -> void:
	# Like the 2D HUD: shown during the battle, hidden once the battle has a result.
	var live: bool = lab != null and is_instance_valid(lab) and lab.ready_for_input and lab.battle_result.is_empty() and not lab.momentum_display.is_empty()
	top_hud.visible = live
	if live: top_hud.show_values(lab.momentum_display.ally, lab.momentum_display.enemy, lab.current_round)
	if live: top_hud.show_side(lab.hud_turn_side()) # block 4-6
	log_hud.visible = live
	if live: log_hud.show_lines(log_lines())
	enemy_roster.visible = live
	if live: enemy_roster.show_cards(enemy_cards())
	ally_roster.visible = live
	if live: ally_roster.show_cards(ally_cards())
	actor_hud.visible = live
	if live: actor_hud.show_actor(current_actor())
	if lab != null and is_instance_valid(lab) and lab.turn_label != null: _place_lab_top_labels()
	_refresh_top_commands()
	command_panel.visible = live
	if live: command_panel.show_state(command_state())
	_refresh_cutin_toasts()
	_refresh_camera_center()

func _refresh_top_commands() -> void:
	var live: bool = lab != null and is_instance_valid(lab) and lab.ready_for_input
	top_commands.visible = live
	if not live: return
	if commands_lab != lab: _place_lab_commands()
	var wait_tip: String = lab.wait_button.tooltip_text
	top_commands.show_state(lab.engine.get("is_full_auto_battle_enabled"), lab.auto_button.disabled, lab.wait_button.disabled,
		"턴 종료" if not lab.wait_button.disabled else wait_tip, int(lab.SPEED_STEPS[lab.speed_index]))

func _place_lab_commands() -> void:
	# The lab builds these once and never moves them again.
	for button in [lab.auto_button, lab.speed_button]:
		button.position.x = LAB_OFFSCREEN_X
	var box: Control = lab.option_toggle.get_parent()
	box.position = Vector2(top_commands.slot_rect(0).position.x, top_commands.slot_rect(0).end.y + OPTION_BOX_GAP)
	box.visible = false
	(box.get_parent() as CanvasLayer).layer = OPTION_LAYER # block 6a: above the HUD
	lab.option_toggle.visible = false # the option button replaces it
	lab.roster_label.position.x = LAB_OFFSCREEN_X # debug unit list off-screen (kept, still updated)
	for button in [lab.attack_button, lab.wait_button, lab.defend_button, lab.strategy_button, lab.skill_button]:
		button.position.x = LAB_OFFSCREEN_X # the command panel replaces them (kept, still updated)
	lab.facing_ui.position.x = LAB_OFFSCREEN_X # the facing arrows replace it
	_lab_info_box().visible = false # hidden in place, so its rect still places the top labels
	commands_lab = lab

func toggle_option_box() -> void:
	# Presentation only: opens/closes the lab's option box (never an engine command).
	var box: Control = lab.option_toggle.get_parent()
	box.visible = not box.visible
	if box.visible and not lab.option_panel.visible: lab.toggle_option_panel()
	if box.visible: box.position = option_box_position(box.get_combined_minimum_size().max(box.size)) # block 6a (the label wraps: the laid-out size)

func option_box_position(size: Vector2) -> Vector2:
	# Block 6a: the clear place nearest to under the option button: x under the button or just left of a HUD rect, y under
	# the button row or just under a HUD rect, kept on screen; none clear: under the button (still drawn above the HUD).
	var slot: Rect2 = top_commands.slot_rect(0)
	var under := Vector2(slot.position.x, slot.end.y + OPTION_BOX_GAP)
	var view := get_viewport().get_visible_rect()
	var rects := hud_rects()
	var xs := [under.x, slot.end.x - size.x]
	var ys := [under.y]
	for r in rects:
		xs.append(r.position.x - size.x - OPTION_BOX_GAP)
		ys.append(r.end.y + OPTION_BOX_GAP)
	var best := under
	var best_distance := INF
	for x in xs:
		for y in ys:
			var place := Rect2(Vector2(clampf(x, view.position.x, view.end.x - size.x), clampf(y, view.position.y, view.end.y - size.y)), size)
			if rects.any(func(r): return place.intersects(r)): continue
			if place.position.distance_to(under) < best_distance:
				best_distance = place.position.distance_to(under)
				best = place.position
	return best

func log_lines() -> Array:
	# The single source of the log panel's text.
	return lab.read_battle_log_lines()

func enemy_cards() -> Array:
	# Card order = the engine's enemy slot order; shown = the lab's own unit view is shown, or the unit retreated (block 6a).
	var cards := []
	for id in lab.hud_enemy_unit_ids():
		var value: Dictionary = lab.display_values.get(id, {})
		var retreated: bool = not value.is_empty() and int(value.current_troops) <= 0 # block 6a: the card stays, dimmed, "퇴각"
		cards.append({"unit_id":id, "visible":(lab.views.has(id) and lab.views[id].visible) or retreated, "retreated":retreated, "name":lab.hud_display_name(id),
			"troops_text":"" if value.is_empty() else "병력 %d / %d" % [value.current_troops, value.max_troops],
			"portrait":lab.hud_portrait(id), "troop_icon":lab.hud_troop_icon(id), "type_name":lab.hud_unit_type_name(str(value.get("unit_type", ""))),
			"status":lab.hud_status_summary(id), "actor":id == lab.enemy_actor_id})
	return cards

func ally_cards() -> Array:
	# Card order = the engine's ally slot order; shown = the lab's own unit view is shown, or the unit retreated (block 6a).
	var cards := []
	var actor: String = lab.hud_ally_actor_id()
	for id in lab.hud_ally_unit_ids():
		var value: Dictionary = lab.display_values.get(id, {})
		var retreated: bool = not value.is_empty() and int(value.current_troops) <= 0 # block 6a: the card stays, dimmed, "퇴각"
		cards.append({"unit_id":id, "visible":(lab.views.has(id) and lab.views[id].visible) or retreated, "retreated":retreated, "name":lab.hud_display_name(id),
			"troops_text":"" if value.is_empty() else "병력 %d / %d" % [value.current_troops, value.max_troops],
			"portrait":lab.hud_portrait(id), "troop_icon":lab.hud_troop_icon(id), "type_name":lab.hud_unit_type_name(str(value.get("unit_type", ""))),
			"status":lab.hud_status_summary(id), "ready":lab.hud_skill_ready(id), "actor":id == actor})
	return cards

func current_actor() -> Dictionary:
	# The 2D current-actor values (battle_current_actor_hud_controller.gd _sync_current_actor_info)
	# for the engine's active unit; {} = none. The registry comes first, as in the 2D.
	var id: String = lab.hud_active_unit_id()
	if id.is_empty(): return {}
	var value: Dictionary = lab.display_values.get(id, {})
	var hero_id := HeroData.resolve_hero_id(lab.hud_hero_id(id), id)
	var stats: Dictionary = HeroData.base_stats(hero_id).get("stats", {})
	var unit_type := str(HeroData.battle_profile(hero_id).get("unit_type", value.get("unit_type", "")))
	var skill := HeroData.unique_skill_for_hero(hero_id)
	if skill.is_empty(): skill = lab.hud_unique_skill(id)
	var portrait: Texture2D = HeroData.current_actor_portrait(hero_id)
	if portrait == null: portrait = lab.hud_portrait(id)
	var country := HeroData.portrait_country(hero_id)
	var troop_icon: Texture2D = null if country.is_empty() else lab.hud_troop_icon_for_key("%s_%s" % [country, unit_type])
	if troop_icon == null: troop_icon = lab.hud_troop_icon(id)
	var rows := []
	for entry in lab.hud_status_entries(id):
		var summary := str(entry.get("summary", entry.get("label", "")))
		if summary.contains("부상"): continue # hidden in the 2D panel
		if rows.size() < 5: rows.append({"summary":str(entry.get("summary", entry.get("label", "상태"))), "tooltip":str(entry.get("tooltip", entry.get("description", summary)))})
	return {"unit_id":id, "name":lab.hud_display_name(id), "type_name":lab.hud_unit_type_name(unit_type),
		"troops_text":"" if value.is_empty() else "병력 %d / %d" % [value.current_troops, value.max_troops],
		"stats":[_stat(stats, "leadership"), _stat(stats, "martial"), _stat(stats, "intelligence")],
		"skill_name":str(skill.get("display_name", skill.get("name", "고유특기"))), "skill_description":str(skill.get("description", skill.get("concept", ""))),
		"portrait":portrait, "troop_icon":troop_icon, "ready":lab.hud_skill_ready(id), "status_rows":rows}

static func _stat(stats: Dictionary, key: String) -> Variant:
	# A registry stat as the 2D int; "-" when the registry has none (the unit-field fallback, N10, is not approved).
	if stats.has(key): return int(stats[key])
	return "-" # block 4-3: no int/String ternary (the "not mutually compatible" warning)

func command_state() -> Dictionary:
	# The command panel's state in one place (see the block 4-2 comment above).
	var state := {"open":false, "facing_open":false}
	var id: String = lab.hud_active_unit_id()
	if id.is_empty() or not lab.views.has(id): return state
	var screen := get_viewport().get_visible_rect()
	if lab.hud_command_panel_open():
		var anchor: Vector2 = lab.camera.unproject_position(lab.views[id].position + Vector3(0, PANEL_ANCHOR_HEIGHT, 0))
		if screen.has_point(anchor): # a unit off screen hides the panel
			var skill: Dictionary = lab.hud_unique_skill(id)
			var skill_text := "고유특기" if skill.is_empty() else "%s · 기세 %d" % [str(skill.get("name", "고유특기")), lab.hud_skill_cost(id)]
			var buttons := []
			for pair in [["기본공격", lab.attack_button], [skill_text, lab.skill_button], ["책략", lab.strategy_button], ["방어", lab.defend_button], ["대기", lab.wait_button]]:
				buttons.append({"text":pair[0], "disabled":pair[1].disabled, "tooltip":pair[1].tooltip_text})
			var range_rects := []
			for world in lab.hud_range_cell_positions(): range_rects.append(cell_screen_rect(world))
			range_rects.append(cell_screen_rect(lab.board.world(lab.display_values.get(id, {}).get("grid_cell", Vector2i.ZERO)))) # block 4-3: never over the unit's own cell
			var avoid_rects: Array = lab.unit_markers.rects_of(id) # block 4-6b: the selected unit's marker parts
			state.merge({"open":true, "anchor":anchor, "buttons":buttons, "range_rects":range_rects, "avoid_rects":avoid_rects, "hud_rects":hud_rects(), "turn_key":"%d:%s" % [lab.current_round, id],
				"reach_rect":lab.unit_markers.reach_rect(id)}, true) # block 4-6c: hud_rects; block 4-6d: reach_rect
	if lab.facing_ui.visible:
		var cell: Vector2i = lab.display_values.get(id, {}).get("grid_cell", Vector2i(-1, -1))
		var arrows := {}
		for direction in FACING_OFFSETS:
			var target: Vector2i = cell + FACING_OFFSETS[direction]
			var valid: bool = lab.board.valid(target)
			var rect := cell_screen_rect(lab.board.world(target)) if valid else Rect2()
			arrows[direction] = {"valid":valid, "text":FACING_TEXT[direction], "center":rect.get_center(), "size":rect.size * FACING_ARROW_SCALE}
			if valid: # block 4-3: the projected diamond (x0.96 about its centre) and the screen direction unit cell -> neighbour
				var corners := cell_screen_corners(target)
				var middle := (corners[0] + corners[1] + corners[2] + corners[3]) * 0.25
				var shrunk := PackedVector2Array()
				for corner in corners: shrunk.append(middle + (corner - middle) * FACING_ARROW_SCALE)
				arrows[direction].merge({"corners":shrunk, "center":middle, "direction":(lab.camera.unproject_position(lab.board.world(target)) - lab.camera.unproject_position(lab.board.world(cell))).normalized()}, true)
		state.merge({"facing_open":true, "arrows":arrows}, true)
	return state

func cell_screen_corners(cell: Vector2i) -> PackedVector2Array:
	# The four ground corners of a cell as the lab camera sees them (in order around the cell).
	var c: float = lab.board.CELL
	var out := PackedVector2Array()
	for corner in [Vector2(cell.x, cell.y), Vector2(cell.x + 1, cell.y), Vector2(cell.x + 1, cell.y + 1), Vector2(cell.x, cell.y + 1)]:
		var x: float = corner.x * c
		var z: float = corner.y * c
		out.append(lab.camera.unproject_position(Vector3(x, lab.board.height(x, z), z)))
	return out

func cell_screen_rect(world: Vector3) -> Rect2:
	# The screen box of one grid cell around a world point: the four edge midpoints projected by the lab camera.
	var half: float = lab.board.CELL * 0.5
	var rect := Rect2(lab.camera.unproject_position(world), Vector2.ZERO)
	for offset in [Vector3(half, 0, 0), Vector3(-half, 0, 0), Vector3(0, 0, half), Vector3(0, 0, -half)]:
		rect = rect.expand(lab.camera.unproject_position(world + offset))
	return rect

func _lab_info_box() -> Control:
	var info_panel: Control = lab.info
	while not info_panel.get_parent() is CanvasLayer: info_panel = info_panel.get_parent()
	return info_panel

func _refresh_cutin_toasts() -> void:
	# Toasts from the lab's rounds and arrivals; one cut-in at a time for the lab's recorded casts.
	if lab == null or not is_instance_valid(lab) or not lab.ready_for_input: return
	if not lab.battle_result.is_empty(): cutin_hud.result_finalized = true
	if lab.current_round != toasted_round:
		toasted_round = lab.current_round
		cutin_hud.toast_round(toasted_round)
	while arrival_cursor < lab.arrival_presentations.size():
		var arrival: Dictionary = lab.arrival_presentations[arrival_cursor]
		arrival_cursor += 1
		if not toasted_arrival_rounds.has(arrival.round): # one toast per arriving round, as the 2D deploys a pair at once
			toasted_arrival_rounds[arrival.round] = true
			cutin_hud.toast_reinforcement()
	if cutin_hud.cutin_playing:
		var next_event_arrived: bool = not lab.hud_held_skill_events.is_empty()
		if cutin_hud.cutin_tween_done and (next_event_arrived or cutin_hud.cutin_seconds() > CUTIN_EVENT_WAIT_SEC):
			cutin_hud.end_cutin()
			lab.hud_release_cutin_hold()
		return
	if cast_cursor < lab.hud_skill_casts.size():
		var cast: Dictionary = lab.hud_skill_casts[cast_cursor]
		cast_cursor += 1
		_start_cutin(cast)

func _start_cutin(cast: Dictionary) -> void:
	# The 2D _play_committed_hero_cutin route: caster and skill owner must be the same hero; the registry entry's
	# video when there is one, else the still toast (released at once, like the 2D toast that does not block).
	var skill: Dictionary = lab.hud_unique_skill(cast.caster_id)
	var caster_hero: String = CutinReader.canonical_hero(lab.hud_hero_id(cast.caster_id))
	var skill_owner: String = CutinReader.canonical_hero(str(skill.get("hero_id", lab.hud_hero_id(cast.caster_id))))
	var entry: Dictionary = CutinReader.entry_for(skill_owner, cast.skill_id) if skill_owner == caster_hero else {}
	var route := "video" if not entry.is_empty() and cutin_hud.play_cutin(entry, 1.0 / Engine.time_scale) else "still"
	cutin_log.append({"caster":cast.caster_id, "skill_id":cast.skill_id, "route":route, "owner":skill_owner, "caster_hero":caster_hero})
	if route == "video": return
	var image := CutinReader.fallback_image(skill_owner, cast.skill_id)
	cutin_hud.show_still_toast(load(image) if image != "" else null, str(skill.get("toast_text", "%s!" % str(skill.get("name", "고유특기")))), cast.get("side", "") == "enemy")
	lab.hud_release_cutin_hold()

func _begin_ending() -> void:
	# The 2D order: the ending video, then the result toast; here also the shell's result panel.
	if ending_started: return
	ending_started = true
	cutin_hud.result_finalized = true
	if not cutin_hud.play_ending(lab.battle_result): _on_ending_done(lab.battle_result)

func _on_ending_done(state: String) -> void:
	if lab == null or not is_instance_valid(lab) or result_panel.visible: return
	_show_result()
	if state in ["victory", "defeat"]: cutin_hud.toast_end(state == "victory")

func camera_turn_key() -> String:
	var id: String = lab.hud_ally_actor_id()
	return "" if id.is_empty() else "%d:%s" % [lab.current_round, id]

func hud_rects() -> Array:
	# The HUD's live rectangles: the rosters, the current-actor panel, the log, the top HUD frame and the top command row.
	# Block 4-6c: shared by the camera centring and the command panel's placement.
	var rects := [ally_roster.roster_rect(), enemy_roster.roster_rect(), actor_hud.panel_rect(),
		log_hud.get_node("ProductionHudRoot/BattleLogHud").get_global_rect(), top_hud.frame_rect()]
	for i in range(5): rects.append(top_commands.slot_rect(i))
	return rects

func camera_free_rect() -> Rect2:
	# The screen area the HUD leaves free: the view minus the HUD's rectangles (live, so a resolution change follows).
	return CameraCenter.free_rect(get_viewport().get_visible_rect(), hud_rects())

func _refresh_camera_center() -> void:
	if lab == null or not is_instance_valid(lab) or not lab.ready_for_input or not lab.battle_result.is_empty(): return
	if lab.engine.get("is_full_auto_battle_enabled") or lab.hud_cutin_hold or lab._enemy_presentation_busy(): return
	var key := camera_turn_key()
	if key.is_empty() or key == centred_turn or key == manual_camera_turn: return
	centred_turn = key
	var id: String = lab.hud_ally_actor_id()
	var target := camera_free_rect().get_center()
	var board_size := Vector2(lab.board.PLAY_SIZE.x * lab.board.CELL, lab.board.PLAY_SIZE.y * lab.board.CELL) # block 7: the play area's focus limits
	camera_target = CameraCenter.focus_for(lab.camera, lab.focus, lab.views[id].position, target, board_size)
	if is_instance_valid(camera_tween): camera_tween.kill()
	camera_tween = create_tween()
	camera_tween.tween_property(lab, "focus", camera_target, CAMERA_CENTER_SEC).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _input(event: InputEvent) -> void:
	# The player's own camera input stops the centring for the current ally turn (the lab still handles the event).
	if lab == null or not is_instance_valid(lab) or not lab.ready_for_input: return
	var manual: bool = (event is InputEventKey and event.pressed and event.keycode in CAMERA_KEYS) \
		or (event is InputEventMouseButton and event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN, MOUSE_BUTTON_MIDDLE])
	if not manual: return
	manual_camera_turn = camera_turn_key()
	if is_instance_valid(camera_tween): camera_tween.kill()

func _on_edge_scrolled() -> void:
	# Block 4-4: the edge scroll is the player's own camera input too (stops this turn's centring, like WASD).
	manual_camera_turn = camera_turn_key()
	if is_instance_valid(camera_tween): camera_tween.kill()

func _place_lab_top_labels() -> void:
	# Runs after the lab's _process (HUD process_priority), so this frame's text is set.
	var frame: Rect2 = top_hud.frame_rect()
	var info_panel: Control = lab.info
	while not info_panel.get_parent() is CanvasLayer: info_panel = info_panel.get_parent()
	var left_limit: float = info_panel.get_global_rect().end.x + LAB_LABEL_GAP
	var y := frame.end.y + LAB_LABEL_GAP
	for label in [lab.turn_label, lab.momentum_label]:
		label.custom_minimum_size.x = 0.0 # the lab gave both a fixed 520 width
		var text_size: Vector2 = label.get_minimum_size()
		label.size = text_size
		label.position = Vector2(maxf(frame.get_center().x - text_size.x * 0.5, left_limit), y)
		y += text_size.y + 2.0

func _show_result() -> void:
	# Engine values only: the result from the battle_ended event, the round from the engine events, alive allied units.
	var allies := 0
	for unit in lab.queries.alive_units:
		var value: Dictionary = Adapter.to_view(unit)
		if value.side == "ally" and value.current_troops > 0 and lab.engine.call("_is_unit_state_available_for_battle_slot", unit): allies += 1
	result_text = "%s · 라운드 %d · 생존 아군 %d부대" % [lab.RESULT_TEXT.get(lab.battle_result, lab.battle_result), lab.current_round, allies]
	result_label.text = result_text
	result_panel.visible = true
