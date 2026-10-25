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
# HUD block 3: the 2D enemy roster (layer 5). The cards are built in one place,
# `enemy_cards()`, from the lab's values (views, display_values, enemy_actor_id)
# and the lab's four approved reads (hud_display_name, hud_portrait,
# hud_troop_icon, hud_status_summary). Shown and hidden with the top HUD.
const ENEMY_ROSTER_SCENE := "res://scenes/battle3d/Battle3D_EnemyRosterHud.tscn"
var enemy_roster # Battle3D_EnemyRosterHud.tscn (CanvasLayer with battle3d_enemy_roster_hud.gd)

func _ready() -> void:
	layer = CanvasLayer.new()
	layer.layer = 10 # above the lab's own UI layers
	add_child(layer)
	top_hud = load(TOP_HUD_SCENE).instantiate()
	top_hud.visible = false
	top_hud.refresh = _refresh_top_hud
	add_child(top_hud)
	enemy_roster = load(ENEMY_ROSTER_SCENE).instantiate()
	enemy_roster.visible = false
	add_child(enemy_roster)
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
	enemy_roster.visible = live
	if live: enemy_roster.show_cards(enemy_cards())
	if lab != null and is_instance_valid(lab) and lab.turn_label != null: _place_lab_top_labels()

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
