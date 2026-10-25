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
	_show_result()

func _refresh_top_hud() -> void:
	# Like the 2D HUD: shown during the battle, hidden once the battle has a result.
	var live: bool = lab != null and is_instance_valid(lab) and lab.ready_for_input and lab.battle_result.is_empty() and not lab.momentum_display.is_empty()
	top_hud.visible = live
	if live: top_hud.show_values(lab.momentum_display.ally, lab.momentum_display.enemy, lab.current_round)
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

func log_lines() -> Array:
	# The single source of the log panel's text.
	return lab.read_battle_log_lines()

func enemy_cards() -> Array:
	# Card order = the engine's enemy slot order; shown = the lab's own unit view is shown.
	var cards := []
	for id in lab.hud_enemy_unit_ids():
		var value: Dictionary = lab.display_values.get(id, {})
		cards.append({"unit_id":id, "visible":lab.views.has(id) and lab.views[id].visible, "name":lab.hud_display_name(id),
			"troops_text":"" if value.is_empty() else "병력 %d / %d" % [value.current_troops, value.max_troops],
			"portrait":lab.hud_portrait(id), "troop_icon":lab.hud_troop_icon(id), "type_name":lab.hud_unit_type_name(str(value.get("unit_type", ""))),
			"status":lab.hud_status_summary(id), "actor":id == lab.enemy_actor_id})
	return cards

func ally_cards() -> Array:
	# Card order = the engine's ally slot order; shown = the lab's own unit view is shown.
	var cards := []
	var actor: String = lab.hud_ally_actor_id()
	for id in lab.hud_ally_unit_ids():
		var value: Dictionary = lab.display_values.get(id, {})
		cards.append({"unit_id":id, "visible":lab.views.has(id) and lab.views[id].visible, "name":lab.hud_display_name(id),
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
	return int(stats[key]) if stats.has(key) else "-"

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
			state.merge({"open":true, "anchor":anchor, "buttons":buttons, "range_rects":range_rects}, true)
	if lab.facing_ui.visible:
		var cell: Vector2i = lab.display_values.get(id, {}).get("grid_cell", Vector2i(-1, -1))
		var arrows := {}
		for direction in FACING_OFFSETS:
			var target: Vector2i = cell + FACING_OFFSETS[direction]
			var valid: bool = lab.board.valid(target)
			var rect := cell_screen_rect(lab.board.world(target)) if valid else Rect2()
			arrows[direction] = {"valid":valid, "text":FACING_TEXT[direction], "center":rect.get_center(), "size":rect.size * FACING_ARROW_SCALE}
		state.merge({"facing_open":true, "arrows":arrows}, true)
	return state

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
