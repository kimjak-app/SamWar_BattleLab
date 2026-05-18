extends Node2D

const DEMO_DAMAGE := 12.0
const ENEMY_DEMO_DAMAGE := 8.0
const ALLY_DEMO_HP := 94.0
const ENEMY_DEMO_HP := 100.0
const ATTACK_LUNGE_DISTANCE := 42.0
const HP_BAR_OFFSET := Vector2(-48.0, 38.0)
const TROOP_LABEL_OFFSET := Vector2(-48.0, 50.0)
const SHADOW_OFFSET := Vector2(0.0, 30.0)
const ALLY_VISUAL_ANCHOR_OFFSET := Vector2(0.0, 0.0)
const ENEMY_VISUAL_ANCHOR_OFFSET := Vector2(0.0, -8.0)
const IDLE_SCALE_MULTIPLIER := 1.035
const IDLE_DURATION := 1.15
const ENEMY_GUARD_STEP_DISTANCE := 18.0
const MOVE_HIGHLIGHT_SIZE := Vector2(68.0, 56.0)
const MOVE_TARGET_VALID_COLOR := Color(0.45, 1.0, 0.55, 1.0)
const MOVE_TARGET_INVALID_COLOR := Color(1.0, 0.35, 0.35, 1.0)
const MOVE_HIGHLIGHT_VALID_COLOR := Color(0.172549, 0.623529, 1.0, 0.227451)
const MOVE_HIGHLIGHT_INVALID_COLOR := Color(1.0, 0.2, 0.2, 0.28)
const MOVE_RANGE_OVERLAY_COLOR := Color(0.2, 0.55, 1.0, 0.18)
const MOVE_RANGE_OVERLAY_VISUAL_INSET := Vector2(32.0, 0.0)
const SHOW_CELL_SIZE_VISUAL_GUIDE := false
const SHOW_LOGICAL_GRID_14X8_GUIDE := true
const MELEE_ADJACENT_QA_MODE := false
const MELEE_QA_ENEMY_OFFSET := Vector2i(1, 0)
const PHASE_ALLY_TURN := "ally_turn"
const PHASE_ENEMY_TURN := "enemy_turn"
const PHASE_RESOLVING := "resolving"
const PHASE_FACING_SELECT := "facing_select"
const MAX_BATTLE_LOG_LINES := 4
const FACING_LEFT := "left"
const FACING_RIGHT := "right"
const FACING_UP := "up"
const FACING_DOWN := "down"
const FACING_ARROW_BUTTON_SIZE_SCALE := 0.92
const FACING_ARROW_PANEL_ALPHA := 1.0
const FACING_ARROW_BUTTON_ALPHA := 0.96
const VALID_FACINGS := [
	FACING_LEFT,
	FACING_RIGHT,
	FACING_UP,
	FACING_DOWN,
]

var is_demo_animating := false
var ally_has_moved := false
var ally_has_manual_facing := false
var enemy_has_manual_facing := false
var facing_indicators_should_be_visible := true
var current_phase := PHASE_ALLY_TURN
var battle_log_lines: Array[String] = []
var current_ally_unit_position := Vector2.ZERO
var current_ally_portrait_position := Vector2.ZERO
var ally_unit_state: BattleUnitState
var enemy_unit_state: BattleUnitState
var active_unit_state: BattleUnitState
var active_unit_side := "ally"
var has_selected_move_target := false
var selected_move_cell := Vector2i(-1, -1)
var selected_attack_target_state: BattleUnitState = null
var selected_attack_target_side := ""
var move_range_cells: Array[ColorRect] = []
var ally_idle_tween: Tween
var enemy_idle_tween: Tween
var ally_token_base_scale := Vector2.ONE
var enemy_token_base_scale := Vector2.ONE
var ally_token_base_texture: Texture2D
var enemy_token_base_texture: Texture2D
var ally_token_layout_offset := Vector2.ZERO
var ally_shadow_layout_offset := Vector2.ZERO
var ally_portrait_layout_offset := Vector2.ZERO
var ally_hp_bar_layout_offset := Vector2.ZERO
var ally_troop_label_layout_offset := Vector2.ZERO
var ally_click_area_layout_offset := Vector2.ZERO
var enemy_token_layout_offset := Vector2.ZERO
var enemy_shadow_layout_offset := Vector2.ZERO
var enemy_portrait_layout_offset := Vector2.ZERO
var enemy_hp_bar_layout_offset := Vector2.ZERO
var enemy_troop_label_layout_offset := Vector2.ZERO
var enemy_click_area_layout_offset := Vector2.ZERO

@export var ally_unit_token_up_texture: Texture2D
@export var ally_unit_token_down_texture: Texture2D
@export var enemy_unit_token_up_texture: Texture2D
@export var enemy_unit_token_down_texture: Texture2D

@onready var battlefield_texture: Sprite2D = $BattlefieldRoot/BattlefieldTexture
@onready var ally_unit_marker: Marker2D = $AllyUnitMarker
@onready var ally_unit_click_area: Area2D = $AllyUnitClickArea
@onready var ally_unit_click_shape: CollisionShape2D = $AllyUnitClickArea/CollisionShape2D
@onready var enemy_unit_marker: Marker2D = $EnemyUnitMarker
@onready var enemy_unit_click_area: Area2D = get_node_or_null("EnemyUnitClickArea") as Area2D
@onready var enemy_unit_click_shape: CollisionShape2D = get_node_or_null("EnemyUnitClickArea/CollisionShape2D") as CollisionShape2D
@onready var ally_portrait_marker: Marker2D = $AllyPortraitMarker
@onready var enemy_portrait_marker: Marker2D = $EnemyPortraitMarker
@onready var move_target_marker: Marker2D = $MoveTargetMarker
@onready var battle_grid_controller: BattleGridController = $BattleGridController
@onready var damage_spawn_marker: Marker2D = $DamageSpawnMarker
@onready var cutin_center_marker: Marker2D = $CutinCenterMarker
@onready var result_center_marker: Marker2D = $ResultCenterMarker
@onready var move_range_overlay_layer: Node2D = $MoveRangeOverlayLayer
@onready var logical_grid_guide_layer: Node2D = get_node_or_null("LogicalGridGuideLayer") as Node2D
@onready var cell_guide_layer: Node2D = get_node_or_null("CellGuideLayer") as Node2D
@onready var cell_guide_current: ColorRect = get_node_or_null("CellGuideLayer/CellGuide_Current") as ColorRect
@onready var cell_guide_right: ColorRect = get_node_or_null("CellGuideLayer/CellGuide_Right") as ColorRect
@onready var cell_guide_down: ColorRect = get_node_or_null("CellGuideLayer/CellGuide_Down") as ColorRect
@onready var cell_guide_label: Label = get_node_or_null("CellGuideLayer/CellGuide_Label") as Label
@onready var move_highlight: ColorRect = $HighlightLayer/MoveHighlight
@onready var attack_highlight: ColorRect = $HighlightLayer/AttackHighlight
@onready var ally_unit_token: Sprite2D = $AllySide/AllyUnitToken
@onready var enemy_unit_token: Sprite2D = $EnemySide/EnemyUnitToken
@onready var ally_unit_shadow: Polygon2D = $AllySide/AllyUnitShadow
@onready var enemy_unit_shadow: Polygon2D = $EnemySide/EnemyUnitShadow
@onready var ally_portrait_badge: Sprite2D = $AllySide/AllyPortraitBadge
@onready var enemy_portrait_badge: Sprite2D = $EnemySide/EnemyPortraitBadge
@onready var ally_hp_bar: ProgressBar = $AllySide/AllyHPBar
@onready var enemy_hp_bar: ProgressBar = $EnemySide/EnemyHPBar
@onready var ally_troop_label: Label = $AllySide/AllyTroopLabel
@onready var enemy_troop_label: Label = $EnemySide/EnemyTroopLabel
@onready var damage_text_layer: Node2D = $DamageTextLayer
@onready var damage_preview_label: Label = $DamageTextLayer/DamagePreviewLabel
@onready var main_camera: Camera2D = $MainCamera
@onready var battle_ui: CanvasLayer = $BattleUI
@onready var top_bar: Panel = $BattleUI/TopBar
@onready var left_panel: Panel = $BattleUI/LeftPanel
@onready var right_panel: Panel = $BattleUI/RightPanel
@onready var command_bar: Panel = $BattleUI/CommandBar
@onready var basic_attack_button: Button = $BattleUI/CommandBar/BasicAttackButton
@onready var move_button: Button = $BattleUI/CommandBar/MoveButton
@onready var wait_button: Button = get_node_or_null("BattleUI/CommandBar/WaitButton") as Button
@onready var end_turn_button: Button = get_node_or_null("BattleUI/CommandBar/EndTurnButton") as Button
@onready var facing_selection_panel: Panel = get_node_or_null("BattleUI/FacingSelectionPanel") as Panel
@onready var face_left_button: Button = get_node_or_null("BattleUI/FacingSelectionPanel/FaceLeftButton") as Button
@onready var face_right_button: Button = get_node_or_null("BattleUI/FacingSelectionPanel/FaceRightButton") as Button
@onready var face_up_button: Button = get_node_or_null("BattleUI/FacingSelectionPanel/FaceUpButton") as Button
@onready var face_down_button: Button = get_node_or_null("BattleUI/FacingSelectionPanel/FaceDownButton") as Button
@onready var facing_arrow_panel: Control = get_node_or_null("BattleUI/FacingArrowPanel") as Control
@onready var face_left_arrow_button: Button = get_node_or_null("BattleUI/FacingArrowPanel/FaceLeftArrowButton") as Button
@onready var face_right_arrow_button: Button = get_node_or_null("BattleUI/FacingArrowPanel/FaceRightArrowButton") as Button
@onready var face_up_arrow_button: Button = get_node_or_null("BattleUI/FacingArrowPanel/FaceUpArrowButton") as Button
@onready var face_down_arrow_button: Button = get_node_or_null("BattleUI/FacingArrowPanel/FaceDownArrowButton") as Button
@onready var ally_facing_indicator: Label = get_node_or_null("BattleUI/AllyFacingIndicator") as Label
@onready var enemy_facing_indicator: Label = get_node_or_null("BattleUI/EnemyFacingIndicator") as Label
@onready var turn_banner: Label = $BattleUI/TopBar/TurnBanner
@onready var battle_log_preview: Label = $BattleUI/LeftPanel/BattleLogPreview
@onready var cutin_overlay: CanvasLayer = $CutinOverlay
@onready var cutin_image: TextureRect = $CutinOverlay/CutinImage
@onready var cutin_name_label: Label = $CutinOverlay/CutinNameLabel
@onready var cutin_quote_label: Label = $CutinOverlay/CutinQuoteLabel
@onready var result_overlay: CanvasLayer = $ResultOverlay
@onready var result_image: TextureRect = $ResultOverlay/ResultImage
@onready var result_title_label: Label = $ResultOverlay/ResultTitleLabel


func _ready() -> void:
	ally_token_base_scale = ally_unit_token.scale
	enemy_token_base_scale = enemy_unit_token.scale
	ally_token_base_texture = ally_unit_token.texture
	enemy_token_base_texture = enemy_unit_token.texture
	basic_attack_button.pressed.connect(try_basic_attack)
	move_button.pressed.connect(play_basic_move_demo)
	if wait_button != null:
		wait_button.pressed.connect(_end_ally_turn_by_wait)
	if end_turn_button != null:
		end_turn_button.pressed.connect(_end_ally_turn_by_wait)
	if face_left_button != null:
		face_left_button.pressed.connect(_select_post_move_facing.bind(FACING_LEFT))
	if face_right_button != null:
		face_right_button.pressed.connect(_select_post_move_facing.bind(FACING_RIGHT))
	if face_up_button != null:
		face_up_button.pressed.connect(_select_post_move_facing.bind(FACING_UP))
	if face_down_button != null:
		face_down_button.pressed.connect(_select_post_move_facing.bind(FACING_DOWN))
	if face_left_arrow_button != null:
		face_left_arrow_button.pressed.connect(_select_post_move_facing.bind(FACING_LEFT))
	if face_right_arrow_button != null:
		face_right_arrow_button.pressed.connect(_select_post_move_facing.bind(FACING_RIGHT))
	if face_up_arrow_button != null:
		face_up_arrow_button.pressed.connect(_select_post_move_facing.bind(FACING_UP))
	if face_down_arrow_button != null:
		face_down_arrow_button.pressed.connect(_select_post_move_facing.bind(FACING_DOWN))
	_collect_move_range_cells()
	_capture_scene_authored_unit_layout_offsets()
	_apply_facing_arrow_panel_visual_style()
	reset_demo_state()


func _process(_delta: float) -> void:
	if current_phase == PHASE_ALLY_TURN and not is_demo_animating:
		_refresh_move_target_feedback()


func _input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton):
		return

	var mouse_event := event as InputEventMouseButton
	if mouse_event.button_index != MOUSE_BUTTON_LEFT or not mouse_event.pressed:
		return
	if current_phase != PHASE_ALLY_TURN or is_demo_animating or ally_unit_state == null:
		return
	if _is_mouse_over_battle_ui():
		return

	var mouse_world_pos := get_global_mouse_position()
	var hit_ally := _is_click_inside_ally_click_area(mouse_world_pos)
	print("Ally _input hitbox: mouse=%s hit=%s" % [
		mouse_world_pos,
		str(hit_ally),
	])
	if hit_ally:
		_select_ally_unit()
		get_viewport().set_input_as_handled()
		return

	if _is_click_inside_enemy_click_area(mouse_world_pos):
		_select_enemy_attack_target()
		get_viewport().set_input_as_handled()
		return

	if active_unit_state == null or battle_grid_controller == null:
		return

	var target_cell := battle_grid_controller.world_to_grid(mouse_world_pos)
	if not battle_grid_controller.is_in_bounds(target_cell):
		return

	var origin_cell := get_active_move_origin_cell()
	var distance := battle_grid_controller.get_distance(origin_cell, target_cell)
	var move_range := get_active_move_range()
	var is_occupied := is_cell_occupied(target_cell)
	var is_valid_target := is_valid_move_target(target_cell)
	print("Move target selected: %s occupied=%s VALID=%s distance=%d range=%d" % [
		_format_cell(target_cell),
		str(is_occupied),
		str(is_valid_target),
		distance,
		move_range,
	])
	if not is_valid_target:
		has_selected_move_target = false
		move_highlight.visible = false
		_append_battle_log("이동 불가")
		get_viewport().set_input_as_handled()
		return

	set_move_target_cell(target_cell)
	get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			return


func show_cutin() -> void:
	_sync_overlay_positions()
	cutin_overlay.visible = true
	result_overlay.visible = false


func hide_cutin() -> void:
	cutin_overlay.visible = false


func show_result() -> void:
	_sync_overlay_positions()
	result_overlay.visible = true
	cutin_overlay.visible = false


func hide_result() -> void:
	result_overlay.visible = false


func reset_demo_state() -> void:
	is_demo_animating = false
	ally_has_moved = false
	ally_has_manual_facing = false
	enemy_has_manual_facing = false
	has_selected_move_target = false
	selected_move_cell = Vector2i(-1, -1)
	selected_attack_target_state = null
	selected_attack_target_side = ""
	_stop_idle_breathing()
	battle_log_lines = [
		"아군 준비",
		"관우 방어",
	]
	current_ally_unit_position = ally_unit_marker.position
	current_ally_portrait_position = ally_portrait_marker.position
	_create_demo_unit_states()
	_sync_unit_state_cells_from_markers()
	_refresh_unit_facing_toward_enemy()
	_update_logical_grid_guide()
	_apply_melee_adjacent_qa_preset()
	_update_cell_size_visual_guide(ally_unit_state.grid_cell)
	print("GRID CELL SIZE: ", battle_grid_controller.get_cell_size())
	print("ALLY GRID: ", ally_unit_state.grid_cell, " ENEMY GRID: ", enemy_unit_state.grid_cell)
	active_unit_state = ally_unit_state
	active_unit_side = "ally"
	_set_phase(PHASE_ALLY_TURN)
	_sync_demo_positions()
	_sync_overlay_positions()
	_update_all_unit_visuals_from_state()
	_set_group_modulate(_get_ally_group_nodes(), Color.WHITE)
	_set_group_modulate(_get_enemy_group_nodes(), Color.WHITE)
	cutin_name_label.text = "학익진 포격"
	cutin_quote_label.text = "사정거리 안 모든 적을 포격하라!"
	result_title_label.text = "승리"
	damage_text_layer.position = damage_spawn_marker.position
	damage_preview_label.text = "-%d" % int(DEMO_DAMAGE)
	damage_preview_label.visible = false
	damage_preview_label.modulate = Color(1.0, 0.55, 0.55, 1.0)
	damage_preview_label.position = Vector2.ZERO
	move_highlight.visible = false
	attack_highlight.visible = false
	_hide_facing_selection_panel()
	_refresh_battle_log()
	cutin_overlay.visible = false
	result_overlay.visible = false
	_refresh_move_target_feedback()
	_show_move_range_overlay_for_active_unit()
	_set_facing_indicators_visible(true)
	_update_facing_indicators()
	_start_idle_breathing()


func play_basic_move_demo() -> void:
	if is_demo_animating or current_phase != PHASE_ALLY_TURN or ally_has_moved:
		return
	if active_unit_state == null or active_unit_side != "ally":
		return
	if not has_selected_move_target:
		move_highlight.visible = false
		_append_battle_log("이동 대상 없음")
		return

	var target_cell: Vector2i = _get_selected_move_target_cell()
	_refresh_move_target_feedback()
	if not is_valid_move_target(target_cell):
		_clear_move_target_selection()
		_append_battle_log("이동 불가")
		return
	_hide_move_range_overlay()
	is_demo_animating = true
	ally_has_manual_facing = false
	_set_facing_indicators_visible(false)
	_set_phase(PHASE_RESOLVING)
	_stop_idle_breathing()
	_sync_demo_positions()

	var target_unit_position := battle_grid_controller.grid_to_world(target_cell)
	var portrait_offset := _get_ally_portrait_visual_offset()
	var target_portrait_position := target_unit_position + portrait_offset
	var move_offset := target_unit_position - current_ally_unit_position
	_clear_move_target_selection()

	var tween := create_tween()
	tween.tween_method(_apply_ally_group_offset, Vector2.ZERO, move_offset, 0.42).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(_finish_basic_move_demo.bind(target_unit_position, target_portrait_position, target_cell))


func _finish_basic_move_demo(target_unit_position: Vector2, target_portrait_position: Vector2, target_cell: Vector2i) -> void:
	current_ally_unit_position = target_unit_position
	current_ally_portrait_position = target_portrait_position
	_sync_ally_markers_to_current_position()
	active_unit_state.set_grid_cell(target_cell)
	_refresh_unit_facing_toward_enemy()
	_debug_print_combat_distance("MOVE_FINISH")
	_update_cell_size_visual_guide(ally_unit_state.grid_cell)
	print("ALLY MOVED grid_cell: ", active_unit_state.grid_cell, " target_cell: ", target_cell)
	active_unit_state.has_moved = true
	ally_has_moved = true
	_reset_unit_group_positions()
	_hide_move_range_overlay()
	is_demo_animating = false
	_append_battle_log("이순신 이동 완료")
	_enter_post_move_facing_selection()


func try_basic_attack() -> void:
	if current_phase != PHASE_ALLY_TURN:
		return
	if is_demo_animating:
		return
	if ally_unit_state == null or enemy_unit_state == null:
		return

	var target_state := selected_attack_target_state
	if target_state == null:
		target_state = enemy_unit_state
	if target_state == null or not target_state.is_alive():
		_append_battle_log("공격 대상 없음")
		return

	var distance := get_unit_grid_distance(ally_unit_state, target_state)
	print("ALLY BASIC ATTACK CHECK")
	print("ally grid: ", ally_unit_state.grid_cell)
	print("target grid: ", target_state.grid_cell)
	print("dist: ", distance, " range: ", ally_unit_state.attack_range)
	if not is_unit_in_attack_range(ally_unit_state, target_state):
		_append_battle_log("사거리 밖입니다")
		return

	selected_attack_target_state = target_state
	selected_attack_target_side = target_state.side if target_state.side != "" else "enemy"
	_show_attack_target_feedback()
	_debug_print_combat_distance("TRY_BASIC_ATTACK")
	play_basic_attack_demo()


func play_basic_attack_demo() -> void:
	if is_demo_animating or current_phase != PHASE_ALLY_TURN:
		return

	is_demo_animating = true
	_hide_move_range_overlay()
	_set_phase(PHASE_RESOLVING)
	_stop_idle_breathing()
	_sync_demo_positions()
	move_highlight.visible = false
	damage_text_layer.position = damage_spawn_marker.position
	damage_preview_label.text = "-%d" % int(DEMO_DAMAGE)
	damage_preview_label.position = Vector2.ZERO
	damage_preview_label.modulate = Color(1.0, 0.55, 0.55, 1.0)
	damage_preview_label.visible = true

	var ally_start := ally_unit_token.position
	var enemy_start := enemy_unit_token.position
	var direction := (enemy_start - ally_start).normalized()
	var ally_lunge_offset := direction * ATTACK_LUNGE_DISTANCE
	var enemy_recoil_offset := direction * 12.0

	var tween := create_tween()
	tween.tween_method(_apply_ally_group_offset, Vector2.ZERO, ally_lunge_offset, 0.16).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.chain()
	tween.set_parallel(true)
	tween.tween_method(_apply_enemy_group_offset, Vector2.ZERO, enemy_recoil_offset, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_method(_set_enemy_group_modulate, Color.WHITE, Color(1.0, 0.45, 0.45, 1.0), 0.08)
	tween.chain()
	tween.tween_method(_apply_ally_group_offset, ally_lunge_offset, Vector2.ZERO, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_method(_apply_enemy_group_offset, enemy_recoil_offset, Vector2.ZERO, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_method(_set_enemy_group_modulate, Color(1.0, 0.45, 0.45, 1.0), Color.WHITE, 0.18)
	tween.finished.connect(_finish_basic_attack_demo)

	var damage_tween := create_tween()
	damage_tween.tween_interval(0.16)
	damage_tween.chain()
	damage_tween.set_parallel(true)
	damage_tween.tween_property(damage_preview_label, "position", Vector2(0.0, -36.0), 0.28)
	damage_tween.tween_property(damage_preview_label, "modulate:a", 0.0, 0.28)

	enemy_unit_state.apply_damage(int(DEMO_DAMAGE))
	_update_enemy_visuals_from_state()
	_append_battle_log("이순신 공격")
	_append_battle_log("관우 피해")


func _sync_demo_positions() -> void:
	_reset_unit_group_positions()


func _reset_unit_group_positions() -> void:
	var ally_visual_anchor := _get_ally_visual_anchor_position()
	var enemy_visual_anchor := _get_enemy_visual_anchor_position()
	var ally_base_positions := _get_ally_group_base_positions(ally_visual_anchor)
	var enemy_base_positions := _get_enemy_group_base_positions(enemy_visual_anchor)

	_apply_group_base_positions(_get_ally_group_nodes(), ally_base_positions)
	_apply_group_base_positions(_get_enemy_group_nodes(), enemy_base_positions)

	if ally_unit_click_area != null:
		ally_unit_click_area.position = ally_visual_anchor + ally_click_area_layout_offset
	if enemy_unit_click_area != null:
		enemy_unit_click_area.position = enemy_visual_anchor + enemy_click_area_layout_offset
	_update_facing_indicators()


func _finish_basic_attack_demo() -> void:
	_reset_unit_group_positions()
	_set_group_modulate(_get_ally_group_nodes(), Color.WHITE)
	_set_group_modulate(_get_enemy_group_nodes(), Color.WHITE)
	damage_preview_label.visible = false
	is_demo_animating = false
	_hide_move_range_overlay()
	_set_phase(PHASE_ENEMY_TURN)
	_append_battle_log("적군 턴")
	_play_enemy_turn_demo()


func _set_phase(new_phase: String) -> void:
	current_phase = new_phase
	match current_phase:
		PHASE_ALLY_TURN:
			turn_banner.text = "아군 턴"
		PHASE_ENEMY_TURN:
			turn_banner.text = "적군 턴"
		PHASE_FACING_SELECT:
			turn_banner.text = "방향 선택"
		_:
			turn_banner.text = "처리 중"

	basic_attack_button.disabled = current_phase != PHASE_ALLY_TURN or is_demo_animating
	move_button.disabled = current_phase != PHASE_ALLY_TURN or is_demo_animating or ally_has_moved
	if wait_button != null:
		wait_button.disabled = current_phase != PHASE_ALLY_TURN or is_demo_animating
	if end_turn_button != null:
		end_turn_button.disabled = current_phase != PHASE_ALLY_TURN or is_demo_animating
	if current_phase == PHASE_FACING_SELECT:
		basic_attack_button.disabled = true
		move_button.disabled = true
		if wait_button != null:
			wait_button.disabled = true
		if end_turn_button != null:
			end_turn_button.disabled = true
		_show_facing_selection_panel()
	else:
		_hide_facing_selection_panel()


func _end_ally_turn_by_wait() -> void:
	if current_phase != PHASE_ALLY_TURN:
		return
	if is_demo_animating:
		return
	if ally_unit_state == null:
		return

	_clear_move_target_selection()
	_clear_attack_target_selection()
	_hide_move_range_overlay()
	if move_highlight != null:
		move_highlight.visible = false
	if attack_highlight != null:
		attack_highlight.visible = false

	ally_unit_state.has_moved = true
	ally_has_moved = true

	_append_battle_log("이순신 대기")
	_set_phase(PHASE_ENEMY_TURN)
	_append_battle_log("적군 턴")
	_play_enemy_turn_demo()


func _show_facing_selection_panel() -> void:
	_position_facing_arrow_panel_near_ally()
	if facing_selection_panel != null:
		facing_selection_panel.visible = false
	if facing_arrow_panel != null:
		facing_arrow_panel.visible = true
	_apply_facing_arrow_panel_visual_style()
	print("SHOW FACING ARROW PANEL visible=%s pos=%s size=%s" % [
		str(facing_arrow_panel != null and facing_arrow_panel.visible),
		str(facing_arrow_panel.position if facing_arrow_panel != null else Vector2.ZERO),
		str(facing_arrow_panel.size if facing_arrow_panel != null else Vector2.ZERO),
	])


func _hide_facing_selection_panel() -> void:
	if facing_selection_panel != null:
		facing_selection_panel.visible = false
	if facing_arrow_panel != null:
		facing_arrow_panel.visible = false


func _position_facing_arrow_panel_near_ally() -> void:
	if facing_arrow_panel == null:
		return
	if ally_unit_state == null:
		return
	if battle_grid_controller == null:
		return

	facing_arrow_panel.position = Vector2.ZERO
	facing_arrow_panel.size = get_viewport_rect().size

	var center_cell := ally_unit_state.grid_cell
	_place_facing_arrow_button_on_cell(face_up_arrow_button, center_cell + Vector2i(0, -1), "↑")
	_place_facing_arrow_button_on_cell(face_down_arrow_button, center_cell + Vector2i(0, 1), "↓")
	_place_facing_arrow_button_on_cell(face_left_arrow_button, center_cell + Vector2i(-1, 0), "←")
	_place_facing_arrow_button_on_cell(face_right_arrow_button, center_cell + Vector2i(1, 0), "→")


func _place_facing_arrow_button_on_cell(button: Button, cell: Vector2i, arrow_text: String) -> void:
	if button == null:
		return
	if battle_grid_controller == null:
		button.visible = false
		button.disabled = true
		return
	if not battle_grid_controller.is_in_bounds(cell):
		button.visible = false
		button.disabled = true
		return

	var cell_size := battle_grid_controller.get_cell_size()
	if cell_size.x <= 0.0 or cell_size.y <= 0.0:
		button.visible = false
		button.disabled = true
		return

	var button_size := cell_size * FACING_ARROW_BUTTON_SIZE_SCALE
	var world_center := battle_grid_controller.grid_to_world(cell)
	var ui_position := _world_to_battle_ui_position(world_center)

	button.text = arrow_text
	button.size = button_size
	button.position = ui_position - (button_size * 0.5)
	button.visible = true
	button.disabled = false


func _apply_facing_arrow_panel_visual_style() -> void:
	if facing_arrow_panel != null:
		facing_arrow_panel.modulate = Color(1.0, 1.0, 1.0, FACING_ARROW_PANEL_ALPHA)
	if face_up_arrow_button != null:
		face_up_arrow_button.modulate = Color(1.0, 1.0, 1.0, FACING_ARROW_BUTTON_ALPHA)
	if face_down_arrow_button != null:
		face_down_arrow_button.modulate = Color(1.0, 1.0, 1.0, FACING_ARROW_BUTTON_ALPHA)
	if face_left_arrow_button != null:
		face_left_arrow_button.modulate = Color(1.0, 1.0, 1.0, FACING_ARROW_BUTTON_ALPHA)
	if face_right_arrow_button != null:
		face_right_arrow_button.modulate = Color(1.0, 1.0, 1.0, FACING_ARROW_BUTTON_ALPHA)


func _enter_post_move_facing_selection() -> void:
	print("ENTER FACING SELECT")
	_set_facing_indicators_visible(false)
	_set_phase(PHASE_FACING_SELECT)
	_hide_move_range_overlay()
	_clear_move_target_selection()
	_clear_attack_target_selection()
	if move_highlight != null:
		move_highlight.visible = false
	if attack_highlight != null:
		attack_highlight.visible = false
	_append_battle_log("방향 선택")
	_show_facing_selection_panel()


func _select_post_move_facing(facing: String) -> void:
	if current_phase != PHASE_FACING_SELECT:
		return
	if ally_unit_state == null:
		return

	_set_unit_facing(ally_unit_state, facing)
	ally_has_manual_facing = true
	_apply_unit_facing_visuals()
	_reset_unit_group_positions()
	_update_facing_indicators()
	_set_facing_indicators_visible(true)
	_hide_facing_selection_panel()
	_set_phase(PHASE_ALLY_TURN)
	_append_battle_log("방향 결정: %s" % facing)
	_start_idle_breathing()

	if is_enemy_in_active_attack_range():
		_append_battle_log("공격 가능")
		if enemy_unit_state != null:
			selected_attack_target_state = enemy_unit_state
			selected_attack_target_side = "enemy"
			_show_attack_target_feedback()
	else:
		_clear_attack_target_selection()
		_append_battle_log("공격 사거리 밖")


func _append_battle_log(line: String) -> void:
	battle_log_lines.append(line)
	while battle_log_lines.size() > MAX_BATTLE_LOG_LINES:
		battle_log_lines.pop_front()
	_refresh_battle_log()


func _refresh_battle_log() -> void:
	var log_text := "전투 기록"
	for line in battle_log_lines:
		log_text += "\n- %s" % line
	battle_log_preview.text = log_text


func _play_enemy_turn_demo() -> void:
	is_demo_animating = true
	_stop_idle_breathing()
	basic_attack_button.disabled = true
	_reset_unit_group_positions()
	_debug_print_combat_distance("ENEMY_TURN_START")

	var enemy_distance := get_unit_grid_distance(enemy_unit_state, ally_unit_state)
	print("ENEMY RANGE CHECK")
	if enemy_unit_state != null:
		print("enemy grid: ", enemy_unit_state.grid_cell)
	if ally_unit_state != null:
		print("ally grid: ", ally_unit_state.grid_cell)
	if enemy_unit_state != null:
		print("dist: ", enemy_distance, " range: ", enemy_unit_state.attack_range)
	if not is_unit_in_attack_range(enemy_unit_state, ally_unit_state):
		_append_battle_log("관우 사거리 밖")
		_return_to_ally_turn()
		return

	var guard_direction := (_get_ally_visual_anchor_position() - _get_enemy_visual_anchor_position()).normalized()
	var guard_offset := guard_direction * ENEMY_GUARD_STEP_DISTANCE
	var ally_recoil_offset := guard_direction * 16.0

	var tween := create_tween()
	tween.tween_interval(0.16)
	tween.tween_callback(_enemy_reaction_hit_on)
	tween.chain()
	tween.set_parallel(true)
	tween.tween_method(_apply_enemy_group_offset, Vector2.ZERO, guard_offset, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_method(_apply_ally_group_offset, Vector2.ZERO, ally_recoil_offset, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_method(_set_ally_group_modulate, Color.WHITE, Color(1.0, 0.45, 0.45, 1.0), 0.08)
	tween.chain()
	tween.tween_method(_apply_enemy_group_offset, guard_offset, Vector2.ZERO, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_method(_apply_ally_group_offset, ally_recoil_offset, Vector2.ZERO, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_method(_set_ally_group_modulate, Color(1.0, 0.45, 0.45, 1.0), Color.WHITE, 0.18)
	tween.chain().tween_callback(_return_to_ally_turn)


func _enemy_reaction_hit_on() -> void:
	if ally_unit_state != null and ally_unit_state.is_alive():
		ally_unit_state.apply_damage(int(ENEMY_DEMO_DAMAGE))
		_update_ally_visuals_from_state()
	_append_battle_log("관우 반격")


func _return_to_ally_turn() -> void:
	_refresh_unit_facing_toward_enemy()
	_reset_unit_group_positions()
	_set_group_modulate(_get_ally_group_nodes(), Color.WHITE)
	_set_enemy_group_modulate(Color.WHITE)
	is_demo_animating = false
	ally_has_moved = false
	if ally_unit_state != null:
		ally_unit_state.reset_action_flags()
	_set_phase(PHASE_ALLY_TURN)
	_append_battle_log("아군 턴 복귀")
	_debug_print_combat_distance("ALLY_TURN_RETURN")
	_refresh_move_target_feedback()
	_show_move_range_overlay_for_active_unit()
	_set_facing_indicators_visible(true)
	_update_facing_indicators()
	_start_idle_breathing()


func _get_ally_group_nodes() -> Array[CanvasItem]:
	var nodes: Array[CanvasItem] = [
		ally_unit_shadow,
		ally_unit_token,
		ally_portrait_badge,
		ally_hp_bar,
		ally_troop_label,
	]
	return nodes


func _get_enemy_group_nodes() -> Array[CanvasItem]:
	var nodes: Array[CanvasItem] = [
		enemy_unit_shadow,
		enemy_unit_token,
		enemy_portrait_badge,
		enemy_hp_bar,
		enemy_troop_label,
	]
	return nodes


func _apply_group_offset(nodes: Array[CanvasItem], base_positions: Array[Vector2], offset: Vector2) -> void:
	for index in range(nodes.size()):
		nodes[index].position = base_positions[index] + offset


func _apply_ally_group_offset(offset: Vector2) -> void:
	var ally_visual_anchor := _get_ally_visual_anchor_position()
	var ally_base_positions := _get_ally_group_base_positions(ally_visual_anchor)
	_apply_group_offset(_get_ally_group_nodes(), ally_base_positions, offset)
	if ally_unit_click_area != null:
		ally_unit_click_area.position = ally_visual_anchor + ally_click_area_layout_offset + offset


func _apply_enemy_group_offset(offset: Vector2) -> void:
	var enemy_visual_anchor := _get_enemy_visual_anchor_position()
	var enemy_base_positions := _get_enemy_group_base_positions(enemy_visual_anchor)
	_apply_group_offset(_get_enemy_group_nodes(), enemy_base_positions, offset)
	if enemy_unit_click_area != null:
		enemy_unit_click_area.position = enemy_visual_anchor + enemy_click_area_layout_offset + offset


func _set_group_modulate(nodes: Array[CanvasItem], color: Color) -> void:
	for node in nodes:
		node.modulate = color


func _set_ally_group_modulate(color: Color) -> void:
	_set_group_modulate(_get_ally_group_nodes(), color)


func _set_enemy_group_modulate(color: Color) -> void:
	_set_group_modulate(_get_enemy_group_nodes(), color)


func _show_move_highlight_at_position(world_position: Vector2) -> void:
	var highlight_size := MOVE_HIGHLIGHT_SIZE
	if battle_grid_controller != null:
		var cell_size := battle_grid_controller.get_cell_size()
		if cell_size.x > 0.0 and cell_size.y > 0.0:
			highlight_size = cell_size

	move_highlight.position = world_position - (highlight_size * 0.5)
	move_highlight.size = highlight_size


func _collect_move_range_cells() -> void:
	move_range_cells.clear()
	if move_range_overlay_layer == null:
		return

	for child in move_range_overlay_layer.get_children():
		if child is ColorRect:
			var cell := child as ColorRect
			move_range_cells.append(cell)
			cell.visible = false


func _hide_move_range_overlay() -> void:
	for cell in move_range_cells:
		cell.visible = false


func _show_move_range_overlay_for_active_unit() -> void:
	_hide_move_range_overlay()
	if active_unit_state == null:
		return
	if active_unit_side != "ally":
		return
	if active_unit_state.has_moved:
		return
	if battle_grid_controller == null:
		return

	var origin_cell := active_unit_state.grid_cell
	var move_range := active_unit_state.move_range
	var valid_cells: Array[Vector2i] = battle_grid_controller.get_tiles_in_range(origin_cell, move_range)
	var cell_size := battle_grid_controller.get_cell_size()
	if cell_size.x <= 0.0 or cell_size.y <= 0.0:
		return

	var index := 0
	for cell in valid_cells:
		if index >= move_range_cells.size():
			break
		if not battle_grid_controller.is_in_bounds(cell):
			continue
		if not is_valid_move_target(cell):
			continue

		var world_pos := battle_grid_controller.grid_to_world(cell)
		if not _is_move_range_overlay_rect_inside_visual_board(world_pos, cell_size):
			continue

		var rect := move_range_cells[index]
		rect.position = world_pos - (cell_size * 0.5)
		rect.size = cell_size
		rect.color = MOVE_RANGE_OVERLAY_COLOR
		rect.visible = true
		index += 1


func _is_move_range_overlay_rect_inside_visual_board(world_pos: Vector2, cell_size: Vector2) -> bool:
	if battle_grid_controller == null:
		return false

	var visual_top_left := battle_grid_controller.get_board_top_left() + MOVE_RANGE_OVERLAY_VISUAL_INSET
	var visual_bottom_right := battle_grid_controller.get_board_bottom_right() - MOVE_RANGE_OVERLAY_VISUAL_INSET
	var rect_top_left := world_pos - (cell_size * 0.5)
	var rect_bottom_right := world_pos + (cell_size * 0.5)
	return (
		rect_top_left.x >= visual_top_left.x
		and rect_bottom_right.x <= visual_bottom_right.x
		and rect_top_left.y >= visual_top_left.y
		and rect_bottom_right.y <= visual_bottom_right.y
	)


func _format_troop_label(value: int) -> String:
	return "%d / %d" % [value, value]


func _update_troop_labels() -> void:
	_update_all_unit_visuals_from_state()


func _create_demo_unit_states() -> void:
	ally_unit_state = BattleUnitState.create({
		"unit_id": "yi_sunsin",
		"display_name": "이순신",
		"side": "ally",
		"hero_name": "이순신",
		"current_hp": int(ALLY_DEMO_HP),
		"max_hp": int(ALLY_DEMO_HP),
		"current_troops": int(ALLY_DEMO_HP),
		"max_troops": int(ALLY_DEMO_HP),
		"attack": 30,
		"defense": 12,
		"move_range": 3,
		"attack_range": 3,
		"grid_cell": Vector2i.ZERO,
		"facing": FACING_RIGHT,
	})
	enemy_unit_state = BattleUnitState.create({
		"unit_id": "guan_yu",
		"display_name": "관우",
		"side": "enemy",
		"hero_name": "관우",
		"current_hp": int(ENEMY_DEMO_HP),
		"max_hp": int(ENEMY_DEMO_HP),
		"current_troops": int(ENEMY_DEMO_HP),
		"max_troops": int(ENEMY_DEMO_HP),
		"attack": 34,
		"defense": 16,
		"move_range": 3,
		"attack_range": 1,
		"grid_cell": Vector2i.ZERO,
		"facing": FACING_LEFT,
	})


func _sync_unit_state_cells_from_markers() -> void:
	if ally_unit_state != null:
		ally_unit_state.set_grid_cell(_get_cell_from_world(ally_unit_marker.position))
	if enemy_unit_state != null:
		enemy_unit_state.set_grid_cell(_get_cell_from_world(enemy_unit_marker.position))


func _apply_melee_adjacent_qa_preset() -> void:
	if not MELEE_ADJACENT_QA_MODE:
		return
	if battle_grid_controller == null:
		return
	if ally_unit_state == null or enemy_unit_state == null:
		return
	if enemy_unit_marker == null or enemy_portrait_marker == null:
		return

	var target_cell := ally_unit_state.grid_cell + MELEE_QA_ENEMY_OFFSET
	if not battle_grid_controller.is_in_bounds(target_cell):
		print("MELEE QA skipped: target out of bounds ", target_cell)
		return

	var portrait_offset := enemy_portrait_marker.position - enemy_unit_marker.position
	enemy_unit_state.set_grid_cell(target_cell)
	enemy_unit_marker.position = battle_grid_controller.grid_to_world(target_cell)
	enemy_portrait_marker.position = enemy_unit_marker.position + portrait_offset
	_refresh_unit_facing_toward_enemy()
	_reset_unit_group_positions()

	print("MELEE QA enemy offset: ", MELEE_QA_ENEMY_OFFSET)
	print("ALLY GRID: ", ally_unit_state.grid_cell, " ENEMY GRID: ", enemy_unit_state.grid_cell)
	print("MELEE DIST: ", get_unit_grid_distance(ally_unit_state, enemy_unit_state))


func _get_ally_visual_anchor_from_position(unit_position: Vector2) -> Vector2:
	return unit_position + ALLY_VISUAL_ANCHOR_OFFSET


func _get_enemy_visual_anchor_from_position(unit_position: Vector2) -> Vector2:
	return unit_position + ENEMY_VISUAL_ANCHOR_OFFSET


func _get_ally_visual_anchor_position() -> Vector2:
	return _get_ally_visual_anchor_from_position(current_ally_unit_position)


func _get_enemy_visual_anchor_position() -> Vector2:
	return _get_enemy_visual_anchor_from_position(enemy_unit_marker.position)


func _capture_scene_authored_unit_layout_offsets() -> void:
	if ally_unit_marker != null:
		var ally_anchor := _get_ally_visual_anchor_from_position(ally_unit_marker.position)
		if ally_unit_token != null:
			ally_token_layout_offset = ally_unit_token.position - ally_anchor
		if ally_unit_shadow != null:
			ally_shadow_layout_offset = ally_unit_shadow.position - ally_anchor
		if ally_portrait_badge != null:
			ally_portrait_layout_offset = ally_portrait_badge.position - ally_anchor
		if ally_hp_bar != null:
			ally_hp_bar_layout_offset = ally_hp_bar.position - ally_anchor
		if ally_troop_label != null:
			ally_troop_label_layout_offset = ally_troop_label.position - ally_anchor
		if ally_unit_click_area != null:
			ally_click_area_layout_offset = ally_unit_click_area.position - ally_anchor

	if enemy_unit_marker != null:
		var enemy_anchor := _get_enemy_visual_anchor_from_position(enemy_unit_marker.position)
		if enemy_unit_token != null:
			enemy_token_layout_offset = enemy_unit_token.position - enemy_anchor
		if enemy_unit_shadow != null:
			enemy_shadow_layout_offset = enemy_unit_shadow.position - enemy_anchor
		if enemy_portrait_badge != null:
			enemy_portrait_layout_offset = enemy_portrait_badge.position - enemy_anchor
		if enemy_hp_bar != null:
			enemy_hp_bar_layout_offset = enemy_hp_bar.position - enemy_anchor
		if enemy_troop_label != null:
			enemy_troop_label_layout_offset = enemy_troop_label.position - enemy_anchor
		if enemy_unit_click_area != null:
			enemy_click_area_layout_offset = enemy_unit_click_area.position - enemy_anchor


func _get_ally_group_base_positions(ally_anchor: Vector2) -> Array[Vector2]:
	var portrait_offset := _get_facing_aware_portrait_offset(ally_portrait_layout_offset, _get_unit_facing(ally_unit_state))
	return [
		ally_anchor + ally_shadow_layout_offset,
		ally_anchor + ally_token_layout_offset,
		ally_anchor + portrait_offset,
		ally_anchor + ally_hp_bar_layout_offset,
		ally_anchor + ally_troop_label_layout_offset,
	]


func _get_enemy_group_base_positions(enemy_anchor: Vector2) -> Array[Vector2]:
	var portrait_offset := _get_facing_aware_portrait_offset(enemy_portrait_layout_offset, _get_unit_facing(enemy_unit_state))
	return [
		enemy_anchor + enemy_shadow_layout_offset,
		enemy_anchor + enemy_token_layout_offset,
		enemy_anchor + portrait_offset,
		enemy_anchor + enemy_hp_bar_layout_offset,
		enemy_anchor + enemy_troop_label_layout_offset,
	]


func _apply_group_base_positions(nodes: Array[CanvasItem], base_positions: Array[Vector2]) -> void:
	_apply_group_offset(nodes, base_positions, Vector2.ZERO)


func _get_ally_portrait_visual_offset() -> Vector2:
	return current_ally_portrait_position - current_ally_unit_position


func _get_enemy_portrait_visual_offset() -> Vector2:
	return enemy_portrait_marker.position - enemy_unit_marker.position


func _get_cell_from_world(pos: Vector2) -> Vector2i:
	return battle_grid_controller.world_to_grid(pos)


func _get_raw_move_target_cell() -> Vector2i:
	return _get_cell_from_world(move_target_marker.global_position)


func _get_selected_move_target_cell() -> Vector2i:
	return selected_move_cell


func _get_snapped_move_target_cell() -> Vector2i:
	var raw_cell: Vector2i = _get_selected_move_target_cell()
	if _is_valid_grid_cell(raw_cell):
		return raw_cell

	return Vector2i(
		clampi(raw_cell.x, 0, battle_grid_controller.grid_width - 1),
		clampi(raw_cell.y, 0, battle_grid_controller.grid_height - 1)
	)


func _get_snapped_move_target_world_position() -> Vector2:
	return battle_grid_controller.grid_to_world(_get_snapped_move_target_cell())


func set_move_target_cell(cell: Vector2i) -> void:
	if battle_grid_controller == null:
		return
	if move_target_marker == null:
		return
	if not battle_grid_controller.is_in_bounds(cell):
		return

	var world_pos := battle_grid_controller.grid_to_world(cell)
	if move_target_marker.get_parent() is Node2D:
		move_target_marker.position = (move_target_marker.get_parent() as Node2D).to_local(world_pos)
	else:
		move_target_marker.global_position = world_pos

	selected_move_cell = cell
	has_selected_move_target = true
	_refresh_move_target_feedback()


func _select_ally_unit() -> void:
	if ally_unit_state == null:
		return

	active_unit_state = ally_unit_state
	_update_cell_size_visual_guide(ally_unit_state.grid_cell)
	active_unit_side = "ally"
	_clear_move_target_selection()
	_clear_attack_target_selection()
	_append_battle_log("이순신 선택")
	_refresh_move_target_feedback()
	_show_move_range_overlay_for_active_unit()


func _select_enemy_attack_target() -> void:
	if enemy_unit_state == null:
		return
	if not enemy_unit_state.is_alive():
		return

	selected_attack_target_state = enemy_unit_state
	selected_attack_target_side = "enemy"
	_refresh_unit_facing_toward_enemy()
	_clear_move_target_selection()
	_append_battle_log("관우 공격 대상 선택")
	_show_attack_target_feedback()


func _clear_attack_target_selection() -> void:
	selected_attack_target_state = null
	selected_attack_target_side = ""
	if attack_highlight != null:
		attack_highlight.visible = false


func _show_attack_target_feedback() -> void:
	if attack_highlight == null:
		return
	if enemy_unit_state == null:
		return

	var highlight_size := MOVE_HIGHLIGHT_SIZE
	var world_pos := enemy_unit_marker.position
	if battle_grid_controller != null:
		var cell_size := battle_grid_controller.get_cell_size()
		if cell_size.x > 0.0 and cell_size.y > 0.0:
			highlight_size = cell_size
		world_pos = battle_grid_controller.grid_to_world(enemy_unit_state.grid_cell)

	var highlight_pos := world_pos - (highlight_size * 0.5)
	if attack_highlight.get_parent() is Node2D:
		var parent_node := attack_highlight.get_parent() as Node2D
		highlight_pos = parent_node.to_local(world_pos) - (highlight_size * 0.5)

	attack_highlight.position = highlight_pos
	attack_highlight.size = highlight_size
	attack_highlight.visible = true


func _update_cell_size_visual_guide(center_cell: Vector2i) -> void:
	if not SHOW_CELL_SIZE_VISUAL_GUIDE:
		if cell_guide_layer != null:
			cell_guide_layer.visible = false
		return

	if battle_grid_controller == null:
		return
	if cell_guide_current == null:
		return

	if cell_guide_layer != null:
		cell_guide_layer.visible = true

	var cell_size := battle_grid_controller.get_cell_size()
	if cell_size.x <= 0.0 or cell_size.y <= 0.0:
		return

	_place_cell_guide_rect(cell_guide_current, center_cell, cell_size)

	var right_cell := center_cell + Vector2i(1, 0)
	if cell_guide_right != null and battle_grid_controller.is_in_bounds(right_cell):
		_place_cell_guide_rect(cell_guide_right, right_cell, cell_size)
	elif cell_guide_right != null:
		cell_guide_right.visible = false

	var down_cell := center_cell + Vector2i(0, 1)
	if cell_guide_down != null and battle_grid_controller.is_in_bounds(down_cell):
		_place_cell_guide_rect(cell_guide_down, down_cell, cell_size)
	elif cell_guide_down != null:
		cell_guide_down.visible = false

	if cell_guide_label != null:
		var enemy_cell_text := "null"
		var distance_text := "?"
		if enemy_unit_state != null:
			enemy_cell_text = str(enemy_unit_state.grid_cell)
		if ally_unit_state != null and enemy_unit_state != null:
			distance_text = str(get_unit_grid_distance(ally_unit_state, enemy_unit_state))
		cell_guide_label.text = "ally=%s enemy=%s dist=%s size=%s" % [center_cell, enemy_cell_text, distance_text, cell_size]
		var label_world_pos := battle_grid_controller.grid_to_world(center_cell) + Vector2(0, -cell_size.y * 0.75)
		if cell_guide_label.get_parent() is Node2D:
			cell_guide_label.position = (cell_guide_label.get_parent() as Node2D).to_local(label_world_pos)
		else:
			cell_guide_label.global_position = label_world_pos


func _update_logical_grid_guide() -> void:
	if logical_grid_guide_layer == null:
		return

	logical_grid_guide_layer.visible = SHOW_LOGICAL_GRID_14X8_GUIDE
	if not SHOW_LOGICAL_GRID_14X8_GUIDE:
		return
	if battle_grid_controller == null:
		return

	var top_left := battle_grid_controller.get_board_top_left()
	var bottom_right := battle_grid_controller.get_board_bottom_right()
	var cell_size := battle_grid_controller.get_cell_size()

	for x in range(battle_grid_controller.grid_width + 1):
		var line := logical_grid_guide_layer.get_node_or_null("GridVertical_%02d" % x) as Line2D
		if line == null:
			continue
		var wx := top_left.x + cell_size.x * float(x)
		var p1 := Vector2(wx, top_left.y)
		var p2 := Vector2(wx, bottom_right.y)
		line.points = PackedVector2Array([
			logical_grid_guide_layer.to_local(p1),
			logical_grid_guide_layer.to_local(p2)
		])
		line.visible = true

	for y in range(battle_grid_controller.grid_height + 1):
		var line := logical_grid_guide_layer.get_node_or_null("GridHorizontal_%02d" % y) as Line2D
		if line == null:
			continue
		var wy := top_left.y + cell_size.y * float(y)
		var p1 := Vector2(top_left.x, wy)
		var p2 := Vector2(bottom_right.x, wy)
		line.points = PackedVector2Array([
			logical_grid_guide_layer.to_local(p1),
			logical_grid_guide_layer.to_local(p2)
		])
		line.visible = true


func _place_cell_guide_rect(rect: ColorRect, cell: Vector2i, cell_size: Vector2) -> void:
	if rect == null:
		return
	if battle_grid_controller == null:
		rect.visible = false
		return
	if not battle_grid_controller.is_in_bounds(cell):
		rect.visible = false
		return

	var world_pos := battle_grid_controller.grid_to_world(cell)
	if rect.get_parent() is Node2D:
		rect.position = (rect.get_parent() as Node2D).to_local(world_pos) - (cell_size * 0.5)
	else:
		rect.global_position = world_pos - (cell_size * 0.5)

	rect.size = cell_size
	rect.visible = true


func _get_ally_click_area_local_position(mouse_pos: Vector2) -> Vector2:
	if ally_unit_click_area == null:
		return Vector2.ZERO

	var local_pos := ally_unit_click_area.to_local(mouse_pos)
	if ally_unit_click_shape != null:
		local_pos -= ally_unit_click_shape.position
	return local_pos


func _is_click_inside_ally_click_area(mouse_pos: Vector2) -> bool:
	if ally_unit_click_area == null:
		return false
	if ally_unit_click_shape == null:
		return false
	if ally_unit_click_shape.shape == null:
		return false

	var local_pos := _get_ally_click_area_local_position(mouse_pos)
	if ally_unit_click_shape.shape is RectangleShape2D:
		var rect_shape := ally_unit_click_shape.shape as RectangleShape2D
		var half_size := rect_shape.size * 0.5
		return absf(local_pos.x) <= half_size.x and absf(local_pos.y) <= half_size.y

	if ally_unit_click_shape.shape is CircleShape2D:
		var circle_shape := ally_unit_click_shape.shape as CircleShape2D
		return local_pos.length() <= circle_shape.radius

	return false


func _get_enemy_click_area_local_position(mouse_pos: Vector2) -> Vector2:
	if enemy_unit_click_area == null:
		return Vector2.ZERO

	var local_pos := enemy_unit_click_area.to_local(mouse_pos)
	if enemy_unit_click_shape != null:
		local_pos -= enemy_unit_click_shape.position
	return local_pos


func _is_click_inside_enemy_click_area(mouse_pos: Vector2) -> bool:
	if enemy_unit_click_area == null:
		return false
	if enemy_unit_click_shape == null:
		return false
	if enemy_unit_click_shape.shape == null:
		return false

	var local_pos := _get_enemy_click_area_local_position(mouse_pos)
	if enemy_unit_click_shape.shape is RectangleShape2D:
		var rect_shape := enemy_unit_click_shape.shape as RectangleShape2D
		var half_size := rect_shape.size * 0.5
		return absf(local_pos.x) <= half_size.x and absf(local_pos.y) <= half_size.y

	return false


func _is_valid_grid_cell(cell: Vector2i) -> bool:
	return battle_grid_controller.is_in_bounds(cell)


func is_cell_occupied(cell: Vector2i) -> bool:
	if ally_unit_state != null and ally_unit_state.grid_cell == cell:
		return true
	if enemy_unit_state != null and enemy_unit_state.grid_cell == cell:
		return true
	return false


func get_active_move_origin_cell() -> Vector2i:
	if active_unit_state == null:
		return Vector2i.ZERO
	return active_unit_state.grid_cell


func get_active_move_range() -> int:
	if active_unit_state == null:
		return 0
	return active_unit_state.move_range


func get_unit_grid_distance(attacker: BattleUnitState, target: BattleUnitState) -> int:
	if attacker == null or target == null:
		return 9999
	return absi(attacker.grid_cell.x - target.grid_cell.x) + absi(attacker.grid_cell.y - target.grid_cell.y)


func _debug_print_combat_distance(context: String) -> void:
	if ally_unit_state == null or enemy_unit_state == null:
		return
	var distance := get_unit_grid_distance(ally_unit_state, enemy_unit_state)
	print("[%s] ally=%s enemy=%s dist=%d ally_range=%d enemy_range=%d" % [
		context,
		ally_unit_state.grid_cell,
		enemy_unit_state.grid_cell,
		distance,
		ally_unit_state.attack_range,
		enemy_unit_state.attack_range,
	])


func is_unit_in_attack_range(attacker: BattleUnitState, target: BattleUnitState) -> bool:
	if attacker == null:
		return false
	if target == null:
		return false
	if not target.is_alive():
		return false

	var distance := get_unit_grid_distance(attacker, target)
	return distance <= attacker.attack_range


func is_enemy_in_active_attack_range() -> bool:
	if ally_unit_state == null:
		return false
	if enemy_unit_state == null:
		return false
	if battle_grid_controller == null:
		return false
	if not enemy_unit_state.is_alive():
		return false

	var distance := get_unit_grid_distance(ally_unit_state, enemy_unit_state)
	print("ALLY RANGE CHECK")
	print("ally grid: ", ally_unit_state.grid_cell)
	print("enemy grid: ", enemy_unit_state.grid_cell)
	print("dist: ", distance, " range: ", ally_unit_state.attack_range)
	return is_unit_in_attack_range(ally_unit_state, enemy_unit_state)


func is_valid_move_target(target_cell: Vector2i) -> bool:
	if active_unit_state == null:
		return false
	if active_unit_side != "ally":
		return false
	if not _is_valid_grid_cell(target_cell):
		return false
	if active_unit_state.has_moved:
		return false

	var origin_cell: Vector2i = get_active_move_origin_cell()
	if target_cell == origin_cell:
		return false
	if is_cell_occupied(target_cell):
		return false

	return battle_grid_controller.get_distance(origin_cell, target_cell) <= get_active_move_range()


func _refresh_move_target_feedback() -> void:
	if move_target_marker == null or move_highlight == null or battle_grid_controller == null:
		return
	if not has_selected_move_target:
		move_highlight.visible = false
		return

	var target_cell: Vector2i = _get_selected_move_target_cell()
	var is_valid_target: bool = is_valid_move_target(target_cell)
	var snapped_position: Vector2 = _get_snapped_move_target_world_position()
	move_target_marker.modulate = MOVE_TARGET_VALID_COLOR if is_valid_target else MOVE_TARGET_INVALID_COLOR
	move_highlight.color = MOVE_HIGHLIGHT_VALID_COLOR if is_valid_target else MOVE_HIGHLIGHT_INVALID_COLOR
	_show_move_highlight_at_position(snapped_position)
	if current_phase == PHASE_ALLY_TURN and not is_demo_animating:
		move_highlight.visible = true


func _clear_move_target_selection() -> void:
	has_selected_move_target = false
	selected_move_cell = Vector2i(-1, -1)
	if move_highlight != null:
		move_highlight.visible = false


func _sync_ally_markers_to_current_position() -> void:
	if ally_unit_marker != null:
		ally_unit_marker.position = current_ally_unit_position
	if ally_portrait_marker != null:
		ally_portrait_marker.position = current_ally_portrait_position


func _is_mouse_over_battle_ui() -> bool:
	var hovered_control := get_viewport().gui_get_hovered_control()
	if hovered_control == null:
		return false
	return (
		_is_node_in_subtree(hovered_control, battle_ui)
		or _is_node_in_subtree(hovered_control, cutin_overlay)
		or _is_node_in_subtree(hovered_control, result_overlay)
	)


func _is_node_in_subtree(node: Node, subtree_root: Node) -> bool:
	var current: Node = node
	while current != null:
		if current == subtree_root:
			return true
		current = current.get_parent()
	return false


func _format_cell(cell: Vector2i) -> String:
	return "(%d,%d)" % [cell.x, cell.y]


func _update_all_unit_visuals_from_state() -> void:
	_apply_unit_facing_visuals()
	_update_ally_visuals_from_state()
	_update_enemy_visuals_from_state()
	_update_facing_indicators()


func _update_ally_visuals_from_state() -> void:
	if ally_unit_state == null:
		return
	_apply_token_facing_visual(ally_unit_token, ally_unit_state.facing, "ally")
	ally_hp_bar.max_value = ally_unit_state.max_hp
	ally_hp_bar.value = ally_unit_state.current_hp
	ally_troop_label.text = ally_unit_state.get_troop_label_text()


func _update_enemy_visuals_from_state() -> void:
	if enemy_unit_state == null:
		return
	_apply_token_facing_visual(enemy_unit_token, enemy_unit_state.facing, "enemy")
	enemy_hp_bar.max_value = enemy_unit_state.max_hp
	enemy_hp_bar.value = enemy_unit_state.current_hp
	enemy_troop_label.text = enemy_unit_state.get_troop_label_text()


func _normalize_facing(facing: String) -> String:
	if facing == FACING_LEFT:
		return FACING_LEFT
	if facing == FACING_RIGHT:
		return FACING_RIGHT
	if facing == FACING_UP:
		return FACING_UP
	if facing == FACING_DOWN:
		return FACING_DOWN
	return FACING_RIGHT


func _is_vertical_facing(facing: String) -> bool:
	var normalized_facing := _normalize_facing(facing)
	return normalized_facing == FACING_UP or normalized_facing == FACING_DOWN


func _is_horizontal_facing(facing: String) -> bool:
	var normalized_facing := _normalize_facing(facing)
	return normalized_facing == FACING_LEFT or normalized_facing == FACING_RIGHT


func _set_unit_facing(unit_state: BattleUnitState, facing: String) -> void:
	if unit_state == null:
		return
	unit_state.facing = _normalize_facing(facing)


func _refresh_unit_facing_toward_enemy() -> void:
	if ally_unit_state == null or enemy_unit_state == null:
		return

	if not ally_has_manual_facing:
		if ally_unit_state.grid_cell.x < enemy_unit_state.grid_cell.x:
			_set_unit_facing(ally_unit_state, FACING_RIGHT)
		elif ally_unit_state.grid_cell.x > enemy_unit_state.grid_cell.x:
			_set_unit_facing(ally_unit_state, FACING_LEFT)

	if not enemy_has_manual_facing:
		if enemy_unit_state.grid_cell.x < ally_unit_state.grid_cell.x:
			_set_unit_facing(enemy_unit_state, FACING_RIGHT)
		elif enemy_unit_state.grid_cell.x > ally_unit_state.grid_cell.x:
			_set_unit_facing(enemy_unit_state, FACING_LEFT)

	_apply_unit_facing_visuals()
	_reset_unit_group_positions()


func _apply_unit_facing_visuals() -> void:
	if ally_unit_token != null and ally_unit_state != null:
		_apply_token_facing_visual(ally_unit_token, ally_unit_state.facing, "ally")
	if enemy_unit_token != null and enemy_unit_state != null:
		_apply_token_facing_visual(enemy_unit_token, enemy_unit_state.facing, "enemy")
	if ally_portrait_badge != null:
		ally_portrait_badge.flip_h = false
	if enemy_portrait_badge != null:
		enemy_portrait_badge.flip_h = false
	_update_facing_indicators()


func _apply_token_facing_visual(token: Sprite2D, facing: String, side: String) -> void:
	if token == null:
		return

	var normalized_facing := _normalize_facing(facing)
	var texture_for_facing := _get_token_texture_for_facing(normalized_facing, side)
	if texture_for_facing != null:
		token.texture = texture_for_facing

	if _is_horizontal_facing(normalized_facing):
		token.flip_h = _is_token_flip_h_for_facing(normalized_facing, side)
		return

	if _is_vertical_facing(normalized_facing):
		# Up/down sprite textures are optional for now. Fallback keeps the current stable visual.
		return


func _is_token_flip_h_for_facing(facing: String, side: String) -> bool:
	var normalized_facing := _normalize_facing(facing)
	match side:
		"enemy":
			match normalized_facing:
				FACING_RIGHT:
					return true
				FACING_LEFT:
					return false
		_:
			match normalized_facing:
				FACING_RIGHT:
					return true
				FACING_LEFT:
					return false

	return false


func _get_token_texture_for_facing(facing: String, side: String) -> Texture2D:
	var normalized_facing := _normalize_facing(facing)
	match side:
		"enemy":
			if normalized_facing == FACING_UP and enemy_unit_token_up_texture != null:
				return enemy_unit_token_up_texture
			if normalized_facing == FACING_DOWN and enemy_unit_token_down_texture != null:
				return enemy_unit_token_down_texture
			return enemy_token_base_texture
		_:
			if normalized_facing == FACING_UP and ally_unit_token_up_texture != null:
				return ally_unit_token_up_texture
			if normalized_facing == FACING_DOWN and ally_unit_token_down_texture != null:
				return ally_unit_token_down_texture
			return ally_token_base_texture


func _get_facing_aware_portrait_offset(base_offset: Vector2, facing: String) -> Vector2:
	var result := base_offset
	var normalized_facing := _normalize_facing(facing)
	match normalized_facing:
		FACING_LEFT:
			result.x = -absf(base_offset.x)
		FACING_RIGHT:
			result.x = absf(base_offset.x)
	return result


func _get_unit_facing(unit_state: BattleUnitState) -> String:
	if unit_state == null:
		return FACING_RIGHT
	return _normalize_facing(unit_state.facing)


func _get_facing_arrow_text(facing: String) -> String:
	match _normalize_facing(facing):
		FACING_LEFT:
			return "←"
		FACING_RIGHT:
			return "→"
		FACING_UP:
			return "↑"
		FACING_DOWN:
			return "↓"
		_:
			return "→"


func _update_facing_indicators() -> void:
	if ally_unit_state != null and ally_facing_indicator != null:
		ally_facing_indicator.text = _get_facing_arrow_text(ally_unit_state.facing)
		ally_facing_indicator.visible = facing_indicators_should_be_visible
		_position_facing_indicator_for_ally()

	if enemy_unit_state != null and enemy_facing_indicator != null:
		enemy_facing_indicator.text = _get_facing_arrow_text(enemy_unit_state.facing)
		enemy_facing_indicator.visible = facing_indicators_should_be_visible
		_position_facing_indicator_for_enemy()


func _position_facing_indicator_for_ally() -> void:
	if ally_facing_indicator == null or ally_unit_token == null:
		return
	var anchor := _world_to_battle_ui_position(ally_unit_token.global_position)
	ally_facing_indicator.position = anchor + Vector2(-18.0, -96.0)


func _position_facing_indicator_for_enemy() -> void:
	if enemy_facing_indicator == null or enemy_unit_token == null:
		return
	var anchor := _world_to_battle_ui_position(enemy_unit_token.global_position)
	enemy_facing_indicator.position = anchor + Vector2(-18.0, -96.0)


func _set_facing_indicators_visible(is_visible: bool) -> void:
	facing_indicators_should_be_visible = is_visible
	if ally_facing_indicator != null:
		ally_facing_indicator.visible = is_visible
	if enemy_facing_indicator != null:
		enemy_facing_indicator.visible = is_visible


func _world_to_battle_ui_position(world_pos: Vector2) -> Vector2:
	return get_viewport().get_canvas_transform() * world_pos


func _start_idle_breathing() -> void:
	if is_demo_animating:
		return

	_stop_idle_breathing()
	ally_idle_tween = _start_token_idle(ally_unit_token, ally_token_base_scale)
	enemy_idle_tween = _start_token_idle(enemy_unit_token, enemy_token_base_scale)


func _start_token_idle(token: Sprite2D, base_scale: Vector2) -> Tween:
	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(token, "scale", base_scale * IDLE_SCALE_MULTIPLIER, IDLE_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(token, "scale", base_scale, IDLE_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween


func _stop_idle_breathing() -> void:
	if ally_idle_tween:
		ally_idle_tween.kill()
		ally_idle_tween = null
	if enemy_idle_tween:
		enemy_idle_tween.kill()
		enemy_idle_tween = null

	ally_unit_token.scale = ally_token_base_scale
	enemy_unit_token.scale = enemy_token_base_scale


func _sync_overlay_positions() -> void:
	var cutin_center: Vector2 = cutin_center_marker.global_position
	var result_center: Vector2 = result_center_marker.global_position

	cutin_image.position = cutin_center + Vector2(-220.0, -160.0)
	cutin_name_label.position = cutin_center + Vector2(-150.0, 128.0)
	cutin_quote_label.position = cutin_center + Vector2(-220.0, 200.0)
	result_image.position = result_center + Vector2(-220.0, -170.0)
	result_title_label.position = result_center + Vector2(-108.0, 176.0)
