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
const ATTACK_RANGE_OVERLAY_COLOR := Color(1.0, 0.32, 0.08, 0.24)
const MOVE_RANGE_OVERLAY_VISUAL_INSET := Vector2(32.0, 0.0)
const SHOW_CELL_SIZE_VISUAL_GUIDE := false
const SHOW_LOGICAL_GRID_14X8_GUIDE := true
const MELEE_ADJACENT_QA_MODE := false
const MELEE_QA_ENEMY_OFFSET := Vector2i(1, 0)
const PHASE_ALLY_TURN := "ally_turn"
const PHASE_ENEMY_TURN := "enemy_turn"
const PHASE_RESOLVING := "resolving"
const PHASE_FACING_SELECT := "facing_select"
const PHASE_ATTACK_SELECT := "attack_select"
const MAX_BATTLE_LOG_LINES := 4
const FACING_LEFT := "left"
const FACING_RIGHT := "right"
const FACING_UP := "up"
const FACING_DOWN := "down"
const ALLOW_BREAKTHROUGH_MOVE := false
const FACING_ARROW_BUTTON_SIZE_SCALE := 0.96
const FACING_ARROW_PANEL_ALPHA := 1.0
const FACING_ARROW_BUTTON_ALPHA := 1.0
const VALID_FACINGS := [
	FACING_LEFT,
	FACING_RIGHT,
	FACING_UP,
	FACING_DOWN,
]
# v0.64s Two Unit Deployment Prototype
# v0.64s-hotfix Support Facing Indicator Sync
# v0.64t Ally Unit Selection MVP
# v0.64u Enemy Target Selection MVP
# v0.64u-hotfix Target Tween + Occupied Restore
# v0.64v Occupied Hard Block + Basic Attack Select Mode
# v0.64v-hotfix Action State Lock + Attack Select Phase Fix
# v0.64w Round Banner + Move-Then-Attack + Dead Unit Cleanup
# v0.64w-hotfix Attack Select Cancel + Move Rollback
# v0.64w-hotfix Facing Select Right Click Rollback Fix
# v0.64x Enemy Multi AI Activation MVP
# v0.64y Ally Ready Frame + Unit Selection Close-up Panel
# v0.64y-hotfix Scene-Authored Closeup Panel Position

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
var ally_support_unit_state: BattleUnitState
var enemy_unit_state: BattleUnitState
var enemy_support_unit_state: BattleUnitState
var active_unit_state: BattleUnitState
var active_unit_side := "ally"
var has_selected_move_target := false
var selected_move_cell := Vector2i(-1, -1)
var selected_attack_target_state: BattleUnitState = null
var selected_attack_target_side := ""
var pending_move_snapshot_unit_state: BattleUnitState = null
var pending_move_snapshot_grid_cell := Vector2i(-1, -1)
var pending_move_snapshot_unit_position := Vector2.ZERO
var pending_move_snapshot_portrait_position := Vector2.ZERO
var pending_move_snapshot_facing := FACING_RIGHT
var pending_move_snapshot_has_moved := false
var pending_move_snapshot_ally_has_moved := false
var has_pending_move_snapshot := false
var current_attack_animation_target_state: BattleUnitState = null
var current_enemy_attack_target_state: BattleUnitState = null
var current_enemy_ai_actor_state: BattleUnitState = null
var move_range_cells: Array[ColorRect] = []
var acted_ally_unit_ids: Dictionary = {}
var acted_enemy_unit_ids: Dictionary = {}
var dead_unit_ids: Dictionary = {}
var battle_round := 1
var round_toast_tween: Tween = null
var round_toast_root_base_scale := Vector2.ONE
var round_toast_label_base_scale := Vector2.ONE
var ally_ready_frame_tween: Tween = null
var ally_support_ready_frame_tween: Tween = null
var unit_closeup_tween: Tween = null
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
var ally_support_token_layout_offset := Vector2.ZERO
var ally_support_shadow_layout_offset := Vector2.ZERO
var ally_support_portrait_layout_offset := Vector2.ZERO
var ally_support_hp_bar_layout_offset := Vector2.ZERO
var ally_support_troop_label_layout_offset := Vector2.ZERO
var ally_support_click_area_layout_offset := Vector2.ZERO
var enemy_token_layout_offset := Vector2.ZERO
var enemy_shadow_layout_offset := Vector2.ZERO
var enemy_portrait_layout_offset := Vector2.ZERO
var enemy_hp_bar_layout_offset := Vector2.ZERO
var enemy_troop_label_layout_offset := Vector2.ZERO
var enemy_click_area_layout_offset := Vector2.ZERO
var enemy_support_token_layout_offset := Vector2.ZERO
var enemy_support_shadow_layout_offset := Vector2.ZERO
var enemy_support_portrait_layout_offset := Vector2.ZERO
var enemy_support_hp_bar_layout_offset := Vector2.ZERO
var enemy_support_troop_label_layout_offset := Vector2.ZERO
var enemy_support_click_area_layout_offset := Vector2.ZERO
var ally_portrait_layout_offsets_by_facing: Dictionary = {}
var ally_support_portrait_layout_offsets_by_facing: Dictionary = {}
var enemy_portrait_layout_offsets_by_facing: Dictionary = {}
var enemy_support_portrait_layout_offsets_by_facing: Dictionary = {}
var ally_facing_indicator_layout_offset := Vector2(-19.3333, -105.0)
var ally_support_facing_indicator_layout_offset := Vector2(-19.3333, -105.0)
var enemy_facing_indicator_layout_offset := Vector2(-18.0, -96.0)
var enemy_support_facing_indicator_layout_offset := Vector2(-18.0, -96.0)

@export var ally_unit_token_up_texture: Texture2D
@export var ally_unit_token_down_texture: Texture2D
@export var enemy_unit_token_up_texture: Texture2D
@export var enemy_unit_token_down_texture: Texture2D

@onready var battlefield_texture: Sprite2D = $BattlefieldRoot/BattlefieldTexture
@onready var ally_unit_marker: Marker2D = $AllyUnitMarker
@onready var ally_unit_click_area: Area2D = $AllyUnitClickArea
@onready var ally_unit_click_shape: CollisionShape2D = $AllyUnitClickArea/CollisionShape2D
@onready var ally_support_unit_marker: Marker2D = $AllySupportUnitMarker
@onready var ally_support_unit_click_area: Area2D = get_node_or_null("AllySupportUnitClickArea") as Area2D
@onready var ally_support_unit_click_shape: CollisionShape2D = get_node_or_null("AllySupportUnitClickArea/CollisionShape2D") as CollisionShape2D
@onready var enemy_unit_marker: Marker2D = $EnemyUnitMarker
@onready var enemy_unit_click_area: Area2D = get_node_or_null("EnemyUnitClickArea") as Area2D
@onready var enemy_unit_click_shape: CollisionShape2D = get_node_or_null("EnemyUnitClickArea/CollisionShape2D") as CollisionShape2D
@onready var enemy_support_unit_marker: Marker2D = $EnemySupportUnitMarker
@onready var enemy_support_unit_click_area: Area2D = get_node_or_null("EnemySupportUnitClickArea") as Area2D
@onready var enemy_support_unit_click_shape: CollisionShape2D = get_node_or_null("EnemySupportUnitClickArea/CollisionShape2D") as CollisionShape2D
@onready var ally_portrait_marker: Marker2D = $AllyPortraitMarker
@onready var enemy_portrait_marker: Marker2D = $EnemyPortraitMarker
@onready var ally_support_portrait_marker: Marker2D = $AllySupportPortraitMarker
@onready var enemy_support_portrait_marker: Marker2D = $EnemySupportPortraitMarker
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
@onready var ally_infantry_unit_visual_template: Node2D = get_node_or_null("AllySide/AllyInfantryUnitVisualTemplate") as Node2D
@onready var enemy_infantry_unit_visual_template: Node2D = get_node_or_null("EnemySide/EnemyInfantryUnitVisualTemplate") as Node2D
@onready var ally_support_unit_token: Sprite2D = $AllySide/AllySupportUnitToken
@onready var enemy_support_unit_token: Sprite2D = $EnemySide/EnemySupportUnitToken
@onready var ally_support_unit_shadow: Polygon2D = $AllySide/AllySupportUnitShadow
@onready var enemy_support_unit_shadow: Polygon2D = $EnemySide/EnemySupportUnitShadow
@onready var ally_support_portrait_badge: Sprite2D = $AllySide/AllySupportPortraitBadge
@onready var enemy_support_portrait_badge: Sprite2D = $EnemySide/EnemySupportPortraitBadge
@onready var ally_support_hp_bar: ProgressBar = $AllySide/AllySupportHPBar
@onready var enemy_support_hp_bar: ProgressBar = $EnemySide/EnemySupportHPBar
@onready var ally_support_troop_label: Label = $AllySide/AllySupportTroopLabel
@onready var enemy_support_troop_label: Label = $EnemySide/EnemySupportTroopLabel
@onready var ally_support_infantry_unit_visual_template: Node2D = get_node_or_null("AllySide/AllySupportInfantryVisualTemplate") as Node2D
@onready var enemy_support_infantry_unit_visual_template: Node2D = get_node_or_null("EnemySide/EnemySupportInfantryVisualTemplate") as Node2D
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
@onready var ally_support_facing_indicator: Label = get_node_or_null("BattleUI/AllySupportFacingIndicator") as Label
@onready var enemy_facing_indicator: Label = get_node_or_null("BattleUI/EnemyFacingIndicator") as Label
@onready var enemy_support_facing_indicator: Label = get_node_or_null("BattleUI/EnemySupportFacingIndicator") as Label
@onready var ally_ready_frame: Panel = get_node_or_null("BattleUI/AllyReadyFrame") as Panel
@onready var ally_support_ready_frame: Panel = get_node_or_null("BattleUI/AllySupportReadyFrame") as Panel
@onready var round_toast_root: Control = get_node_or_null("BattleUI/RoundToastRoot") as Control
@onready var round_toast_image: TextureRect = get_node_or_null("BattleUI/RoundToastRoot/RoundToastImage") as TextureRect
@onready var round_toast_label: Label = get_node_or_null("BattleUI/RoundToastRoot/RoundToastLabel") as Label
@onready var unit_closeup_panel: Panel = get_node_or_null("BattleUI/UnitCloseupPanel") as Panel
@onready var closeup_hero_portrait: TextureRect = get_node_or_null("BattleUI/UnitCloseupPanel/CloseupHeroPortrait") as TextureRect
@onready var closeup_troop_image: TextureRect = get_node_or_null("BattleUI/UnitCloseupPanel/CloseupTroopImage") as TextureRect
@onready var closeup_name_label: Label = get_node_or_null("BattleUI/UnitCloseupPanel/CloseupNameLabel") as Label
@onready var closeup_troop_label: Label = get_node_or_null("BattleUI/UnitCloseupPanel/CloseupTroopLabel") as Label
@onready var closeup_status_label: Label = get_node_or_null("BattleUI/UnitCloseupPanel/CloseupStatusLabel") as Label
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
	_configure_round_toast()
	_collect_move_range_cells()
	_capture_scene_authored_unit_layout_offsets()
	_apply_facing_arrow_panel_visual_style()
	_configure_ally_ready_frames()
	_configure_unit_closeup_panel()
	reset_demo_state()


func _process(_delta: float) -> void:
	if current_phase == PHASE_ALLY_TURN and not is_demo_animating:
		_refresh_move_target_feedback()
	_update_ally_ready_frames()


func _input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton):
		return

	var mouse_event := event as InputEventMouseButton
	if mouse_event.button_index == MOUSE_BUTTON_RIGHT and mouse_event.pressed:
		_handle_right_click_cancel()
		get_viewport().set_input_as_handled()
		return
	if mouse_event.button_index != MOUSE_BUTTON_LEFT or not mouse_event.pressed:
		return
	if is_demo_animating or ally_unit_state == null:
		return
	if _is_mouse_over_battle_ui():
		return

	var mouse_world_pos := get_global_mouse_position()
	if current_phase == PHASE_ATTACK_SELECT:
		if _is_click_inside_enemy_click_area(mouse_world_pos):
			_try_attack_enemy_target_from_attack_select(enemy_unit_state)
			get_viewport().set_input_as_handled()
			return

		if _is_click_inside_enemy_support_click_area(mouse_world_pos):
			_try_attack_enemy_target_from_attack_select(enemy_support_unit_state)
			get_viewport().set_input_as_handled()
			return

		_append_battle_log("공격 대상을 선택하세요")
		get_viewport().set_input_as_handled()
		return

	if current_phase != PHASE_ALLY_TURN:
		return

	var hit_ally := _is_click_inside_ally_click_area(mouse_world_pos)
	var hit_ally_support := _is_click_inside_ally_support_click_area(mouse_world_pos)
	print("Ally _input hitbox: mouse=%s hit=%s" % [
		mouse_world_pos,
		str(hit_ally),
	])
	if hit_ally:
		_select_ally_unit(ally_unit_state)
		get_viewport().set_input_as_handled()
		return

	if hit_ally_support:
		_select_ally_unit(ally_support_unit_state)
		get_viewport().set_input_as_handled()
		return

	if _is_click_inside_enemy_click_area(mouse_world_pos):
		_select_enemy_attack_target(enemy_unit_state)
		get_viewport().set_input_as_handled()
		return

	if _is_click_inside_enemy_support_click_area(mouse_world_pos):
		_select_enemy_attack_target(enemy_support_unit_state)
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
		if mouse_event.button_index == MOUSE_BUTTON_LEFT or mouse_event.button_index == MOUSE_BUTTON_RIGHT:
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
	battle_round = 1
	dead_unit_ids.clear()
	acted_enemy_unit_ids.clear()
	ally_has_manual_facing = false
	enemy_has_manual_facing = false
	has_selected_move_target = false
	selected_move_cell = Vector2i(-1, -1)
	selected_attack_target_state = null
	selected_attack_target_side = ""
	_clear_pending_move_snapshot()
	_stop_idle_breathing()
	battle_log_lines = [
		"아군 준비",
		"관우 방어",
	]
	current_ally_unit_position = ally_unit_marker.position
	current_ally_portrait_position = ally_portrait_marker.position
	_create_demo_unit_states()
	_reset_ally_action_locks_for_new_round()
	_reset_enemy_action_locks_for_new_round()
	_sync_unit_state_cells_from_markers()
	_refresh_initial_unit_facing()
	_update_logical_grid_guide()
	_apply_melee_adjacent_qa_preset()
	_update_cell_size_visual_guide(ally_unit_state.grid_cell)
	print("GRID CELL SIZE: ", battle_grid_controller.get_cell_size())
	print("ALLY GRID: ", ally_unit_state.grid_cell, " ENEMY GRID: ", enemy_unit_state.grid_cell)
	_select_ally_unit(ally_unit_state, false)
	_set_phase(PHASE_ALLY_TURN)
	_sync_demo_positions()
	_sync_overlay_positions()
	_update_all_unit_visuals_from_state()
	_set_group_modulate(_get_ally_group_nodes(), Color.WHITE)
	_set_group_modulate(_get_enemy_group_nodes(), Color.WHITE)
	_set_group_modulate(_get_ally_support_group_nodes(), Color.WHITE)
	_set_group_modulate(_get_enemy_support_group_nodes(), Color.WHITE)
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
	_hide_attack_range_overlay()
	_hide_facing_selection_panel()
	_refresh_battle_log()
	cutin_overlay.visible = false
	result_overlay.visible = false
	_refresh_move_target_feedback()
	_show_move_range_overlay_for_active_unit()
	_set_facing_indicators_visible(true)
	_update_facing_indicators()
	_show_unit_closeup_for_ally(active_unit_state)
	_update_ally_ready_frames()
	_start_idle_breathing()
	_show_round_start_toast(battle_round)


func play_basic_move_demo() -> void:
	if is_demo_animating or current_phase != PHASE_ALLY_TURN:
		return
	if active_unit_state == null or active_unit_side != "ally":
		return
	if not _is_active_ally_action_available():
		_append_battle_log("이미 행동한 부대입니다")
		_set_phase(PHASE_ALLY_TURN)
		return
	if active_unit_state.has_moved:
		_append_battle_log("이미 이동한 부대입니다")
		_set_phase(PHASE_ALLY_TURN)
		return
	if not has_selected_move_target:
		move_highlight.visible = false
		_append_battle_log("이동 대상 없음")
		return

	var target_cell: Vector2i = _get_selected_move_target_cell()
	_refresh_move_target_feedback()
	if not _is_valid_destination_for_unit(target_cell, active_unit_state, true):
		_clear_move_target_selection()
		_append_battle_log("다른 부대가 있어 이동할 수 없습니다")
		return
	if not is_valid_move_target(target_cell):
		_clear_move_target_selection()
		_append_battle_log("이동 불가")
		return

	var start_cell := active_unit_state.grid_cell
	var move_path := _find_ally_move_path(start_cell, target_cell)
	if move_path.is_empty() or move_path.size() < 2 or not _is_path_clear_for_unit(move_path, active_unit_state, true):
		is_demo_animating = false
		_set_phase(PHASE_ALLY_TURN)
		_set_facing_indicators_visible(true)
		_refresh_move_target_feedback()
		_show_move_range_overlay_for_active_unit()
		_start_idle_breathing()
		_append_battle_log("이동 경로 없음")
		return

	_hide_move_range_overlay()
	_hide_attack_range_overlay()
	_store_pending_ally_move_snapshot()
	is_demo_animating = true
	ally_has_manual_facing = false
	_set_facing_indicators_visible(false)
	_set_phase(PHASE_RESOLVING)
	_stop_idle_breathing()
	_sync_demo_positions()

	var target_unit_position := battle_grid_controller.grid_to_world(target_cell)
	var portrait_offset := _get_selected_ally_portrait_visual_offset()
	var target_portrait_position := target_unit_position + portrait_offset
	var selected_unit_marker := _get_selected_ally_unit_marker()
	var start_unit_position := selected_unit_marker.position if selected_unit_marker != null else Vector2.ZERO
	_clear_move_target_selection()

	var tween := create_tween()
	var previous_offset := Vector2.ZERO
	var step_duration := 0.14
	for path_index in range(1, move_path.size()):
		var waypoint_world := battle_grid_controller.grid_to_world(move_path[path_index])
		var next_offset := waypoint_world - start_unit_position
		tween.tween_method(_apply_selected_ally_group_offset, previous_offset, next_offset, step_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		previous_offset = next_offset
	if move_path.size() - 1 > battle_grid_controller.get_distance(start_cell, target_cell):
		_append_battle_log("우회 이동")
	tween.tween_callback(_finish_basic_move_demo.bind(target_unit_position, target_portrait_position, target_cell))


func _finish_basic_move_demo(target_unit_position: Vector2, target_portrait_position: Vector2, target_cell: Vector2i) -> void:
	_sync_selected_ally_markers_to_position(target_unit_position, target_portrait_position)
	active_unit_state.set_grid_cell(target_cell)
	_refresh_ally_facing_toward_enemy_if_not_manual()
	_debug_print_combat_distance("MOVE_FINISH")
	_update_cell_size_visual_guide(active_unit_state.grid_cell)
	print("ALLY MOVED grid_cell: ", active_unit_state.grid_cell, " target_cell: ", target_cell)
	active_unit_state.has_moved = true
	ally_has_moved = true
	_reset_unit_group_positions()
	_hide_move_range_overlay()
	is_demo_animating = false
	_append_battle_log("%s 이동 완료" % _get_selected_ally_display_name())
	_enter_post_move_facing_selection()


func try_basic_attack() -> void:
	if current_phase != PHASE_ALLY_TURN:
		return
	if is_demo_animating:
		return
	if active_unit_state == null:
		return
	if not _is_active_ally_action_available():
		_append_battle_log("이미 행동한 부대입니다")
		_set_phase(PHASE_ALLY_TURN)
		return

	_enter_attack_select_mode()


func _enter_attack_select_mode() -> void:
	if not _is_active_ally_action_available():
		_append_battle_log("이미 행동한 부대입니다")
		_set_phase(PHASE_ALLY_TURN)
		return
	_hide_facing_selection_panel()
	_clear_move_target_selection()
	_clear_attack_target_selection()
	_hide_move_range_overlay()
	_set_phase(PHASE_ATTACK_SELECT)
	_show_attack_range_overlay_for_active_unit()
	_append_battle_log("공격 대상 선택")


func _exit_attack_select_mode() -> void:
	_hide_attack_range_overlay()


func _is_enemy_target_in_active_attack_range(target_state: BattleUnitState) -> bool:
	return is_unit_in_attack_range(active_unit_state, target_state)


func _try_attack_enemy_target_from_attack_select(target_state: BattleUnitState) -> void:
	if current_phase != PHASE_ATTACK_SELECT:
		return
	if is_demo_animating:
		return
	if active_unit_state == null:
		return
	if target_state == null or not target_state.is_alive():
		_append_battle_log("공격 대상 없음")
		return

	var distance := get_unit_grid_distance(active_unit_state, target_state)
	print("ALLY BASIC ATTACK SELECT CHECK")
	print("ally grid: ", active_unit_state.grid_cell)
	print("target grid: ", target_state.grid_cell)
	print("dist: ", distance, " range: ", active_unit_state.attack_range)
	if not _is_enemy_target_in_active_attack_range(target_state):
		_append_battle_log("사거리 밖입니다")
		return

	selected_attack_target_state = target_state
	selected_attack_target_side = target_state.side if target_state.side != "" else "enemy"
	_show_attack_target_feedback()
	_debug_print_combat_distance("TRY_BASIC_ATTACK_SELECT")
	_exit_attack_select_mode()
	play_basic_attack_demo()


func play_basic_attack_demo() -> void:
	if is_demo_animating or (current_phase != PHASE_ALLY_TURN and current_phase != PHASE_ATTACK_SELECT):
		return
	if selected_attack_target_state == null:
		return
	current_attack_animation_target_state = selected_attack_target_state

	is_demo_animating = true
	_hide_move_range_overlay()
	_hide_attack_range_overlay()
	_set_phase(PHASE_RESOLVING)
	_stop_idle_breathing()
	_sync_demo_positions()
	move_highlight.visible = false
	damage_text_layer.position = damage_spawn_marker.position
	damage_preview_label.text = "-%d" % int(DEMO_DAMAGE)
	damage_preview_label.position = Vector2.ZERO
	damage_preview_label.modulate = Color(1.0, 0.55, 0.55, 1.0)
	damage_preview_label.visible = true

	var ally_start := (_get_selected_ally_unit_marker().position if _get_selected_ally_unit_marker() != null else Vector2.ZERO)
	var target_marker := _get_enemy_target_unit_marker(selected_attack_target_state)
	var enemy_start := target_marker.position if target_marker != null else Vector2.ZERO
	var direction := (enemy_start - ally_start).normalized()
	var ally_lunge_offset := direction * ATTACK_LUNGE_DISTANCE
	var enemy_recoil_offset := direction * 12.0

	var tween := create_tween()
	tween.tween_method(_apply_selected_ally_group_offset, Vector2.ZERO, ally_lunge_offset, 0.16).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.chain()
	tween.set_parallel(true)
	tween.tween_method(_apply_enemy_target_group_offset, Vector2.ZERO, enemy_recoil_offset, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_method(_set_enemy_target_group_modulate, Color.WHITE, Color(1.0, 0.45, 0.45, 1.0), 0.08)
	tween.chain()
	tween.tween_method(_apply_selected_ally_group_offset, ally_lunge_offset, Vector2.ZERO, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_method(_apply_enemy_target_group_offset, enemy_recoil_offset, Vector2.ZERO, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_method(_set_enemy_target_group_modulate, Color(1.0, 0.45, 0.45, 1.0), Color.WHITE, 0.18)
	tween.finished.connect(_finish_basic_attack_demo)

	var damage_tween := create_tween()
	damage_tween.tween_interval(0.16)
	damage_tween.chain()
	damage_tween.set_parallel(true)
	damage_tween.tween_property(damage_preview_label, "position", Vector2(0.0, -36.0), 0.28)
	damage_tween.tween_property(damage_preview_label, "modulate:a", 0.0, 0.28)

	selected_attack_target_state.apply_damage(int(DEMO_DAMAGE))
	_update_enemy_target_visuals_from_state(selected_attack_target_state)
	_append_battle_log("%s 공격" % _get_selected_ally_display_name())
	_append_battle_log("%s 피해" % selected_attack_target_state.display_name)


func _sync_demo_positions() -> void:
	_reset_unit_group_positions()


func _reset_unit_group_positions() -> void:
	var ally_visual_anchor := _get_ally_visual_anchor_position()
	var ally_support_visual_anchor := _get_ally_support_visual_anchor_position()
	var enemy_visual_anchor := _get_enemy_visual_anchor_position()
	var enemy_support_visual_anchor := _get_enemy_support_visual_anchor_position()
	var ally_base_positions := _get_ally_group_base_positions(ally_visual_anchor)
	var ally_support_base_positions := _get_ally_support_group_base_positions(ally_support_visual_anchor)
	var enemy_base_positions := _get_enemy_group_base_positions(enemy_visual_anchor)
	var enemy_support_base_positions := _get_enemy_support_group_base_positions(enemy_support_visual_anchor)

	_apply_group_base_positions(_get_ally_group_nodes(), ally_base_positions)
	_apply_group_base_positions(_get_ally_support_group_nodes(), ally_support_base_positions)
	_apply_group_base_positions(_get_enemy_group_nodes(), enemy_base_positions)
	_apply_group_base_positions(_get_enemy_support_group_nodes(), enemy_support_base_positions)

	if ally_unit_click_area != null:
		ally_unit_click_area.position = ally_visual_anchor + ally_click_area_layout_offset
	if ally_support_unit_click_area != null:
		ally_support_unit_click_area.position = ally_support_visual_anchor + ally_support_click_area_layout_offset
	if enemy_unit_click_area != null:
		enemy_unit_click_area.position = enemy_visual_anchor + enemy_click_area_layout_offset
	if enemy_support_unit_click_area != null:
		enemy_support_unit_click_area.position = enemy_support_visual_anchor + enemy_support_click_area_layout_offset
	_sync_runtime_portrait_markers_to_visuals()
	_update_facing_indicators()


func _finish_basic_attack_demo() -> void:
	_reset_unit_group_positions()
	_set_group_modulate(_get_ally_group_nodes(), Color.WHITE)
	_set_group_modulate(_get_enemy_group_nodes(), Color.WHITE)
	_set_group_modulate(_get_enemy_support_group_nodes(), Color.WHITE)
	current_attack_animation_target_state = null
	damage_preview_label.visible = false
	is_demo_animating = false
	_hide_move_range_overlay()
	_hide_attack_range_overlay()
	_clear_attack_target_selection()
	_clear_pending_move_snapshot()
	_mark_ally_unit_acted(active_unit_state)
	_show_unit_closeup_for_ally(active_unit_state)
	_update_ally_ready_frames()
	_cleanup_dead_units()
	_set_phase(PHASE_ENEMY_TURN)
	_append_battle_log("적군 턴")
	_play_enemy_turn_demo()


func _set_phase(new_phase: String) -> void:
	current_phase = new_phase
	match current_phase:
		PHASE_ALLY_TURN:
			turn_banner.text = "아군 턴 · BATTLE %d" % battle_round
		PHASE_ENEMY_TURN:
			turn_banner.text = "적군 턴 · BATTLE %d" % battle_round
		PHASE_FACING_SELECT:
			turn_banner.text = "방향 선택 · BATTLE %d" % battle_round
		PHASE_ATTACK_SELECT:
			turn_banner.text = "공격 대상 선택 · BATTLE %d" % battle_round
		_:
			turn_banner.text = "처리 중"

	var can_issue_ally_command := (
		current_phase == PHASE_ALLY_TURN
		and not is_demo_animating
		and _is_active_ally_action_available()
	)
	var active_unit_has_moved := active_unit_state != null and active_unit_state.has_moved
	basic_attack_button.disabled = not can_issue_ally_command
	move_button.disabled = not can_issue_ally_command or active_unit_has_moved
	if wait_button != null:
		wait_button.disabled = not can_issue_ally_command
	if end_turn_button != null:
		end_turn_button.disabled = not can_issue_ally_command
	if current_phase == PHASE_FACING_SELECT or current_phase == PHASE_ATTACK_SELECT:
		basic_attack_button.disabled = true
		move_button.disabled = true
		if wait_button != null:
			wait_button.disabled = true
		if end_turn_button != null:
			end_turn_button.disabled = true
	if current_phase == PHASE_FACING_SELECT:
		_show_facing_selection_panel()
	else:
		_hide_facing_selection_panel()
	_update_ally_ready_frames()


func _end_ally_turn_by_wait() -> void:
	if current_phase != PHASE_ALLY_TURN:
		return
	if is_demo_animating:
		return
	if active_unit_state == null:
		return
	if not _is_active_ally_action_available():
		_append_battle_log("이미 행동한 부대입니다")
		_set_phase(PHASE_ALLY_TURN)
		return

	_clear_move_target_selection()
	_clear_attack_target_selection()
	_hide_move_range_overlay()
	_hide_attack_range_overlay()
	_hide_facing_selection_panel()
	if move_highlight != null:
		move_highlight.visible = false
	if attack_highlight != null:
		attack_highlight.visible = false

	_clear_pending_move_snapshot()
	active_unit_state.has_moved = true
	ally_has_moved = true
	_mark_ally_unit_acted(active_unit_state)
	_show_unit_closeup_for_ally(active_unit_state)
	_update_ally_ready_frames()

	_append_battle_log("%s 대기" % _get_selected_ally_display_name())
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
	if active_unit_state == null:
		return
	if battle_grid_controller == null:
		return

	facing_arrow_panel.position = Vector2.ZERO
	facing_arrow_panel.size = get_viewport_rect().size

	var center_cell := active_unit_state.grid_cell
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
		_apply_facing_arrow_button_style(face_up_arrow_button)
	if face_down_arrow_button != null:
		_apply_facing_arrow_button_style(face_down_arrow_button)
	if face_left_arrow_button != null:
		_apply_facing_arrow_button_style(face_left_arrow_button)
	if face_right_arrow_button != null:
		_apply_facing_arrow_button_style(face_right_arrow_button)


func _apply_facing_arrow_button_style(button: Button) -> void:
	if button == null:
		return

	button.modulate = Color(1.0, 1.0, 1.0, FACING_ARROW_BUTTON_ALPHA)
	button.flat = false

	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(1.0, 0.92, 0.55, 0.12)
	normal.border_color = Color(1.0, 0.92, 0.65, 0.4)
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(4)

	var hover := StyleBoxFlat.new()
	hover.bg_color = Color(1.0, 0.94, 0.6, 0.18)
	hover.border_color = Color(1.0, 0.94, 0.7, 0.52)
	hover.set_border_width_all(2)
	hover.set_corner_radius_all(4)

	var pressed := StyleBoxFlat.new()
	pressed.bg_color = Color(1.0, 0.86, 0.42, 0.22)
	pressed.border_color = Color(1.0, 0.92, 0.65, 0.6)
	pressed.set_border_width_all(2)
	pressed.set_corner_radius_all(4)

	var disabled := StyleBoxFlat.new()
	disabled.bg_color = Color(0.65, 0.58, 0.2, 0.12)
	disabled.border_color = Color(0.85, 0.76, 0.3, 0.32)
	disabled.set_border_width_all(2)
	disabled.set_corner_radius_all(4)

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_color_override("font_color", Color(1.0, 0.96, 0.78, 0.9))
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.98, 0.82, 0.95))
	button.add_theme_color_override("font_pressed_color", Color(1.0, 0.98, 0.82, 1.0))
	button.add_theme_color_override("font_disabled_color", Color(0.92, 0.82, 0.45, 0.6))
	button.add_theme_color_override("font_outline_color", Color(0.1, 0.07, 0.0, 0.8))
	button.add_theme_constant_override("outline_size", 3)
	button.add_theme_font_size_override("font_size", 36)


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
	if active_unit_state == null:
		return

	_set_unit_facing(active_unit_state, facing)
	ally_has_manual_facing = true
	_apply_unit_facing_visuals()
	_reset_unit_group_positions()
	_update_facing_indicators()
	_set_facing_indicators_visible(true)
	_hide_facing_selection_panel()
	_hide_attack_range_overlay()
	_append_battle_log("방향 결정: %s" % facing)
	_clear_attack_target_selection()
	_clear_pending_move_snapshot()
	_set_phase(PHASE_ALLY_TURN)
	_start_idle_breathing()
	_refresh_move_target_feedback()
	_show_move_range_overlay_for_active_unit()


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


# v0.64p-hotfix Enemy Highlight Cleanup
func _clear_transient_battle_highlights() -> void:
	if move_highlight != null:
		move_highlight.visible = false
	if attack_highlight != null:
		attack_highlight.visible = false


func _configure_ally_ready_frames() -> void:
	_apply_ready_frame_style(ally_ready_frame)
	_apply_ready_frame_style(ally_support_ready_frame)


func _apply_ready_frame_style(frame: Panel) -> void:
	if frame == null:
		return
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1.0, 0.88, 0.42, 0.035)
	style.border_color = Color(1.0, 0.88, 0.48, 0.58)
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	frame.add_theme_stylebox_override("panel", style)
	frame.pivot_offset = frame.size * 0.5


func _configure_unit_closeup_panel() -> void:
	if unit_closeup_panel == null:
		return
	unit_closeup_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	unit_closeup_panel.visible = false
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.02, 0.027, 0.035, 0.82)
	style.border_color = Color(0.92, 0.82, 0.58, 0.38)
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	unit_closeup_panel.add_theme_stylebox_override("panel", style)
	unit_closeup_panel.pivot_offset = unit_closeup_panel.size * 0.5
	for child in unit_closeup_panel.get_children():
		if child is Control:
			(child as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	for label in [closeup_name_label, closeup_troop_label, closeup_status_label]:
		if label is Label:
			(label as Label).add_theme_color_override("font_color", Color(0.95, 0.91, 0.82, 1.0))
			(label as Label).add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.04, 0.85))
			(label as Label).add_theme_constant_override("outline_size", 2)
	if closeup_name_label != null:
		closeup_name_label.add_theme_font_size_override("font_size", 18)
	if closeup_troop_label != null:
		closeup_troop_label.add_theme_font_size_override("font_size", 13)
	if closeup_status_label != null:
		closeup_status_label.add_theme_font_size_override("font_size", 14)


func _update_ally_ready_frames() -> void:
	_update_ready_frame_for_unit(ally_ready_frame, ally_unit_state)
	_update_ready_frame_for_unit(ally_support_ready_frame, ally_support_unit_state)


func _update_ready_frame_for_unit(frame: Control, unit_state: BattleUnitState) -> void:
	if frame == null:
		return
	var should_show := _is_ally_unit_ready_for_action(unit_state)
	if not should_show:
		if frame.visible:
			_stop_ready_frame_pulse(frame)
		frame.visible = false
		return

	_position_ready_frame_for_unit(frame, unit_state)
	var is_selected := unit_state == active_unit_state
	if not frame.visible:
		frame.modulate = Color(1.0, 0.94, 0.62, 0.9 if is_selected else 0.68)
		frame.visible = true
		_start_ready_frame_pulse(frame)


func _position_ready_frame_for_unit(frame: Control, unit_state: BattleUnitState) -> void:
	if frame == null or unit_state == null:
		return
	var anchor := _get_ally_visual_anchor_position()
	if unit_state == ally_support_unit_state:
		anchor = _get_ally_support_visual_anchor_position()
	var ui_center := _world_to_battle_ui_position(anchor + Vector2(0.0, -6.0))
	var frame_size := Vector2(118.0, 112.0)
	if battle_grid_controller != null:
		var cell_size := battle_grid_controller.get_cell_size()
		if cell_size.x > 0.0 and cell_size.y > 0.0:
			frame_size = Vector2(cell_size.x * 0.98, cell_size.y * 0.9)
	frame.size = frame_size
	frame.position = ui_center - (frame_size * 0.5)
	frame.pivot_offset = frame_size * 0.5


func _is_ally_unit_ready_for_action(unit_state: BattleUnitState) -> bool:
	if unit_state == null:
		return false
	if unit_state.side != "ally":
		return false
	if not unit_state.is_alive():
		return false
	if current_phase != PHASE_ALLY_TURN:
		return false
	if is_demo_animating:
		return false
	if _is_active_ally_locked() and unit_state != active_unit_state:
		return false
	return not _has_ally_unit_acted(unit_state)


func _start_ready_frame_pulse(frame: Control) -> void:
	if frame == null:
		return
	_stop_ready_frame_pulse(frame)
	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(frame, "modulate:a", 0.42, 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(frame, "modulate:a", 0.78, 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	if frame == ally_ready_frame:
		ally_ready_frame_tween = tween
	elif frame == ally_support_ready_frame:
		ally_support_ready_frame_tween = tween


func _stop_ready_frame_pulse(frame: Control) -> void:
	if frame == ally_ready_frame and ally_ready_frame_tween != null:
		ally_ready_frame_tween.kill()
		ally_ready_frame_tween = null
	elif frame == ally_support_ready_frame and ally_support_ready_frame_tween != null:
		ally_support_ready_frame_tween.kill()
		ally_support_ready_frame_tween = null


func _show_unit_closeup_for_ally(unit_state: BattleUnitState) -> void:
	if unit_closeup_panel == null or unit_state == null or unit_state.side != "ally":
		return
	if not unit_state.is_alive():
		_hide_unit_closeup_panel()
		return

	if closeup_hero_portrait != null:
		closeup_hero_portrait.texture = _get_ally_portrait_texture_for_unit(unit_state)
	if closeup_troop_image != null:
		closeup_troop_image.texture = _get_ally_token_texture_for_unit(unit_state)
	if closeup_name_label != null:
		closeup_name_label.text = unit_state.display_name
	if closeup_troop_label != null:
		closeup_troop_label.text = "병력 %d / %d" % [unit_state.current_troops, unit_state.max_troops]
	if closeup_status_label != null:
		closeup_status_label.text = _get_unit_action_status_text(unit_state)

	unit_closeup_panel.visible = true
	unit_closeup_panel.scale = Vector2(0.97, 0.97)
	unit_closeup_panel.modulate = Color(1.0, 1.0, 1.0, 0.92)
	if unit_closeup_tween != null:
		unit_closeup_tween.kill()
	unit_closeup_tween = create_tween()
	unit_closeup_tween.set_parallel(true)
	unit_closeup_tween.tween_property(unit_closeup_panel, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	unit_closeup_tween.tween_property(unit_closeup_panel, "modulate:a", 1.0, 0.14)


func _hide_unit_closeup_panel() -> void:
	if unit_closeup_tween != null:
		unit_closeup_tween.kill()
		unit_closeup_tween = null
	if unit_closeup_panel != null:
		unit_closeup_panel.visible = false


func _get_ally_portrait_texture_for_unit(unit_state: BattleUnitState) -> Texture2D:
	if unit_state == ally_support_unit_state and ally_support_portrait_badge != null:
		return ally_support_portrait_badge.texture
	if ally_portrait_badge != null:
		return ally_portrait_badge.texture
	return null


func _get_ally_token_texture_for_unit(unit_state: BattleUnitState) -> Texture2D:
	if unit_state == ally_support_unit_state and ally_support_unit_token != null:
		return ally_support_unit_token.texture
	if ally_unit_token != null:
		return ally_unit_token.texture
	return null


func _get_unit_action_status_text(unit_state: BattleUnitState) -> String:
	if unit_state == null or not unit_state.is_alive():
		return "DOWN"
	if _has_ally_unit_acted(unit_state):
		return "DONE"
	if unit_state.has_moved:
		return "MOVED"
	return "READY"


func _handle_right_click_cancel() -> void:
	print("[RIGHT_CLICK_CANCEL] phase=", current_phase)
	if current_phase == PHASE_FACING_SELECT:
		_rollback_pending_ally_move()
		return
	if current_phase == PHASE_ATTACK_SELECT:
		_cancel_attack_select_mode()
		return
	if current_phase == PHASE_ALLY_TURN:
		_clear_move_target_selection()
		_clear_attack_target_selection()
		_clear_transient_battle_highlights()
		_refresh_move_target_feedback()
		_show_move_range_overlay_for_active_unit()


func _cancel_attack_select_mode() -> void:
	if current_phase != PHASE_ATTACK_SELECT:
		return
	_hide_attack_range_overlay()
	_clear_attack_target_selection()
	_clear_transient_battle_highlights()
	_set_phase(PHASE_ALLY_TURN)
	_append_battle_log("공격 취소")
	_refresh_move_target_feedback()
	_show_move_range_overlay_for_active_unit()


func _rollback_pending_ally_move() -> void:
	print("[ROLLBACK] phase=", current_phase)
	if current_phase != PHASE_FACING_SELECT:
		print("[ROLLBACK] skipped: not facing select")
		return
	if not has_pending_move_snapshot:
		print("[ROLLBACK] no snapshot")
		_set_phase(PHASE_ALLY_TURN)
		_hide_facing_selection_panel()
		_refresh_move_target_feedback()
		_show_move_range_overlay_for_active_unit()
		return

	var unit_state := pending_move_snapshot_unit_state
	if unit_state == null:
		print("[ROLLBACK] snapshot unit missing")
		_clear_pending_move_snapshot()
		_set_phase(PHASE_ALLY_TURN)
		return

	print("[ROLLBACK] unit=", unit_state.display_name, " cell=", pending_move_snapshot_grid_cell)
	active_unit_state = unit_state
	active_unit_side = "ally"
	ally_has_moved = pending_move_snapshot_ally_has_moved
	unit_state.set_grid_cell(pending_move_snapshot_grid_cell)
	unit_state.has_moved = pending_move_snapshot_has_moved
	_set_unit_facing(unit_state, pending_move_snapshot_facing)

	var unit_marker := _get_unit_marker_for_unit(unit_state)
	if unit_marker != null:
		unit_marker.position = pending_move_snapshot_unit_position
	var portrait_marker := _get_portrait_marker_for_unit(unit_state)
	if portrait_marker != null:
		portrait_marker.position = pending_move_snapshot_portrait_position
	if unit_state == ally_unit_state:
		current_ally_unit_position = pending_move_snapshot_unit_position
		current_ally_portrait_position = pending_move_snapshot_portrait_position

	_hide_facing_selection_panel()
	_hide_attack_range_overlay()
	_clear_move_target_selection()
	_clear_attack_target_selection()
	_clear_transient_battle_highlights()
	_reset_unit_group_positions()
	_set_facing_indicators_visible(true)
	_update_facing_indicators()
	_update_cell_size_visual_guide(unit_state.grid_cell)
	_set_phase(PHASE_ALLY_TURN)
	_show_move_range_overlay_for_active_unit()
	_refresh_move_target_feedback()
	_clear_pending_move_snapshot()
	_show_unit_closeup_for_ally(active_unit_state)
	_update_ally_ready_frames()
	_start_idle_breathing()
	print("[ROLLBACK] restored unit=", unit_state.display_name, " grid=", unit_state.grid_cell)
	_append_battle_log("이동 취소")


func _store_pending_ally_move_snapshot() -> void:
	if active_unit_state == null:
		_clear_pending_move_snapshot()
		return
	var unit_marker := _get_selected_ally_unit_marker()
	var portrait_marker := _get_selected_ally_portrait_marker()
	pending_move_snapshot_unit_state = active_unit_state
	pending_move_snapshot_grid_cell = active_unit_state.grid_cell
	pending_move_snapshot_unit_position = unit_marker.position if unit_marker != null else Vector2.ZERO
	pending_move_snapshot_portrait_position = portrait_marker.position if portrait_marker != null else Vector2.ZERO
	pending_move_snapshot_facing = active_unit_state.facing
	pending_move_snapshot_has_moved = active_unit_state.has_moved
	pending_move_snapshot_ally_has_moved = ally_has_moved
	has_pending_move_snapshot = true
	print("[ROLLBACK] snapshot stored unit=", active_unit_state.display_name, " cell=", pending_move_snapshot_grid_cell)


func _clear_pending_move_snapshot() -> void:
	pending_move_snapshot_unit_state = null
	pending_move_snapshot_grid_cell = Vector2i(-1, -1)
	pending_move_snapshot_unit_position = Vector2.ZERO
	pending_move_snapshot_portrait_position = Vector2.ZERO
	pending_move_snapshot_facing = FACING_RIGHT
	pending_move_snapshot_has_moved = false
	pending_move_snapshot_ally_has_moved = false
	has_pending_move_snapshot = false


# v0.64o Enemy Basic Move + Attack AI
func _play_enemy_turn_demo() -> void:
	_play_enemy_ai_turn()


func _play_enemy_ai_turn() -> void:
	is_demo_animating = true
	_stop_idle_breathing()
	basic_attack_button.disabled = true
	_clear_transient_battle_highlights()
	_cleanup_dead_units()
	_debug_print_combat_distance("ENEMY_TURN_START")

	var enemy_actor_state := _get_next_available_enemy_ai_actor()
	if enemy_actor_state == null:
		_append_battle_log("행동 가능한 적군 없음")
		_return_to_ally_turn()
		return

	_play_enemy_ai_for_actor(enemy_actor_state)


func _play_enemy_ai_for_actor(enemy_actor_state: BattleUnitState) -> void:
	if enemy_actor_state == null or not enemy_actor_state.is_alive():
		_return_to_ally_turn()
		return
	current_enemy_ai_actor_state = enemy_actor_state

	var target_state := _get_enemy_ai_target_state_for_actor(enemy_actor_state)
	if target_state == null:
		_append_battle_log("적 행동 대상 없음")
		_mark_enemy_unit_acted(enemy_actor_state)
		_return_to_ally_turn()
		return

	if is_unit_in_attack_range(enemy_actor_state, target_state):
		_play_enemy_actor_basic_attack_from_current_cell(enemy_actor_state, target_state)
		return

	var destination := _choose_enemy_basic_ai_destination_for_actor(enemy_actor_state, target_state)
	if destination == enemy_actor_state.grid_cell:
		_append_battle_log("%s 대기" % enemy_actor_state.display_name)
		_mark_enemy_unit_acted(enemy_actor_state)
		_return_to_ally_turn()
		return

	var move_path := _find_enemy_move_path_for_actor(enemy_actor_state, enemy_actor_state.grid_cell, destination)
	if move_path.is_empty() or move_path.size() < 2:
		_append_battle_log("%s 이동 경로 없음" % enemy_actor_state.display_name)
		_mark_enemy_unit_acted(enemy_actor_state)
		_return_to_ally_turn()
		return

	_append_battle_log("%s 접근" % enemy_actor_state.display_name)
	_play_enemy_actor_path_move_then_act(enemy_actor_state, move_path)


func _play_enemy_basic_attack_from_current_cell(target_state: BattleUnitState = null) -> void:
	_play_enemy_actor_basic_attack_from_current_cell(enemy_unit_state, target_state)


func _play_enemy_actor_basic_attack_from_current_cell(enemy_actor_state: BattleUnitState, target_state: BattleUnitState = null) -> void:
	if enemy_actor_state == null:
		_return_to_ally_turn()
		return
	if target_state == null:
		target_state = _get_enemy_ai_target_state_for_actor(enemy_actor_state)
	if target_state == null or not target_state.is_alive():
		_mark_enemy_unit_acted(enemy_actor_state)
		_return_to_ally_turn()
		return
	current_enemy_ai_actor_state = enemy_actor_state
	current_enemy_attack_target_state = target_state

	_refresh_enemy_facing_for_actor_action(enemy_actor_state, target_state)
	_reset_unit_group_positions()

	var guard_direction := (_get_ally_target_visual_anchor_position(target_state) - _get_enemy_actor_visual_anchor_position(enemy_actor_state)).normalized()
	var guard_offset := guard_direction * ENEMY_GUARD_STEP_DISTANCE
	var ally_recoil_offset := guard_direction * 16.0

	var tween := create_tween()
	tween.tween_interval(0.16)
	tween.tween_callback(_enemy_reaction_hit_on)
	tween.chain()
	tween.set_parallel(true)
	tween.tween_method(_apply_enemy_actor_group_offset.bind(enemy_actor_state), Vector2.ZERO, guard_offset, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_method(_apply_ally_target_group_offset, Vector2.ZERO, ally_recoil_offset, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_method(_set_ally_target_group_modulate, Color.WHITE, Color(1.0, 0.45, 0.45, 1.0), 0.08)
	tween.chain()
	tween.tween_method(_apply_enemy_actor_group_offset.bind(enemy_actor_state), guard_offset, Vector2.ZERO, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_method(_apply_ally_target_group_offset, ally_recoil_offset, Vector2.ZERO, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_method(_set_ally_target_group_modulate, Color(1.0, 0.45, 0.45, 1.0), Color.WHITE, 0.18)
	tween.chain().tween_callback(_finish_enemy_actor_basic_attack.bind(enemy_actor_state))


func _play_enemy_path_move_then_act(move_path: Array[Vector2i]) -> void:
	_play_enemy_actor_path_move_then_act(enemy_unit_state, move_path)


func _play_enemy_actor_path_move_then_act(enemy_actor_state: BattleUnitState, move_path: Array[Vector2i]) -> void:
	if enemy_actor_state == null or battle_grid_controller == null:
		_return_to_ally_turn()
		return
	if not _is_path_clear_for_unit(move_path, enemy_actor_state, true):
		_append_battle_log("%s 이동 경로 막힘" % enemy_actor_state.display_name)
		_mark_enemy_unit_acted(enemy_actor_state)
		_return_to_ally_turn()
		return

	_clear_transient_battle_highlights()
	var actor_marker := _get_enemy_actor_unit_marker(enemy_actor_state)
	var actor_portrait_marker := _get_enemy_actor_portrait_marker(enemy_actor_state)
	if actor_marker == null:
		_mark_enemy_unit_acted(enemy_actor_state)
		_return_to_ally_turn()
		return
	var start_unit_position := actor_marker.position
	var start_portrait_position := actor_portrait_marker.position if actor_portrait_marker != null else start_unit_position
	var portrait_offset := start_portrait_position - start_unit_position
	var target_cell := move_path[move_path.size() - 1]
	var target_position := battle_grid_controller.grid_to_world(target_cell)
	var target_portrait_position := target_position + portrait_offset

	var tween := create_tween()
	var previous_offset := Vector2.ZERO
	var step_duration := 0.14
	for path_index in range(1, move_path.size()):
		var waypoint_world := battle_grid_controller.grid_to_world(move_path[path_index])
		var next_offset := waypoint_world - start_unit_position
		tween.tween_method(_apply_enemy_actor_group_offset.bind(enemy_actor_state), previous_offset, next_offset, step_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		previous_offset = next_offset
	tween.tween_callback(_finish_enemy_actor_basic_move.bind(enemy_actor_state, target_position, target_portrait_position, target_cell))


func _finish_enemy_basic_move(target_position: Vector2, target_portrait_position: Vector2, target_cell: Vector2i) -> void:
	_finish_enemy_actor_basic_move(enemy_unit_state, target_position, target_portrait_position, target_cell)


func _finish_enemy_actor_basic_move(enemy_actor_state: BattleUnitState, target_position: Vector2, target_portrait_position: Vector2, target_cell: Vector2i) -> void:
	if enemy_actor_state == null:
		_return_to_ally_turn()
		return

	_sync_enemy_actor_markers_to_position(enemy_actor_state, target_position, target_portrait_position)
	enemy_actor_state.set_grid_cell(target_cell)
	_clear_transient_battle_highlights()
	_reset_unit_group_positions()
	_update_facing_indicators()
	_play_enemy_actor_basic_attack_or_wait_after_move(enemy_actor_state)


func _play_enemy_basic_attack_or_wait_after_move() -> void:
	_play_enemy_actor_basic_attack_or_wait_after_move(enemy_unit_state)


func _play_enemy_actor_basic_attack_or_wait_after_move(enemy_actor_state: BattleUnitState) -> void:
	if enemy_actor_state == null:
		_return_to_ally_turn()
		return

	var target_state := _get_enemy_ai_target_state_for_actor(enemy_actor_state)
	if target_state != null and is_unit_in_attack_range(enemy_actor_state, target_state):
		_play_enemy_actor_basic_attack_from_current_cell(enemy_actor_state, target_state)
		return

	_append_battle_log("%s 대기" % enemy_actor_state.display_name)
	_mark_enemy_unit_acted(enemy_actor_state)
	_return_to_ally_turn()


func _enemy_reaction_hit_on() -> void:
	var target_state := current_enemy_attack_target_state
	if target_state == null:
		target_state = _get_enemy_ai_target_state_for_actor(current_enemy_ai_actor_state)
	if target_state != null and target_state.is_alive():
		target_state.apply_damage(int(ENEMY_DEMO_DAMAGE))
		_update_ally_target_visuals_from_state(target_state)
		_cleanup_dead_units()
	var actor_name := current_enemy_ai_actor_state.display_name if current_enemy_ai_actor_state != null else "적군"
	_append_battle_log("%s 반격" % actor_name)


func _finish_enemy_actor_basic_attack(enemy_actor_state: BattleUnitState) -> void:
	_mark_enemy_unit_acted(enemy_actor_state)
	_return_to_ally_turn()


func _return_to_ally_turn() -> void:
	current_enemy_attack_target_state = null
	current_enemy_ai_actor_state = null
	_clear_pending_move_snapshot()
	_clear_transient_battle_highlights()
	_cleanup_dead_units()
	_reset_unit_group_positions()
	_set_group_modulate(_get_ally_group_nodes(), Color.WHITE)
	_set_group_modulate(_get_ally_support_group_nodes(), Color.WHITE)
	_set_enemy_group_modulate(Color.WHITE)
	_set_group_modulate(_get_enemy_support_group_nodes(), Color.WHITE)
	is_demo_animating = false
	if _are_all_alive_allies_acted() and _are_all_alive_enemies_acted():
		_start_new_round()
	var next_ally := _get_first_available_ally_unit()
	if next_ally == null:
		_start_new_round()
		next_ally = _get_first_available_ally_unit()
	if next_ally == null:
		_append_battle_log("행동 가능한 아군 없음")
		_set_phase(PHASE_ALLY_TURN)
		return
	_select_ally_unit(next_ally, false)
	_set_phase(PHASE_ALLY_TURN)
	_append_battle_log("아군 턴 복귀")
	_debug_print_combat_distance("ALLY_TURN_RETURN")
	_refresh_move_target_feedback()
	_show_move_range_overlay_for_active_unit()
	_clear_attack_target_selection()
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


func _get_ally_support_group_nodes() -> Array[CanvasItem]:
	var nodes: Array[CanvasItem] = [
		ally_support_unit_shadow,
		ally_support_unit_token,
		ally_support_portrait_badge,
		ally_support_hp_bar,
		ally_support_troop_label,
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


func _get_enemy_support_group_nodes() -> Array[CanvasItem]:
	var nodes: Array[CanvasItem] = [
		enemy_support_unit_shadow,
		enemy_support_unit_token,
		enemy_support_portrait_badge,
		enemy_support_hp_bar,
		enemy_support_troop_label,
	]
	return nodes


func _configure_round_toast() -> void:
	if round_toast_root != null:
		round_toast_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
		round_toast_root.visible = false
		round_toast_root_base_scale = round_toast_root.scale
	if round_toast_image != null:
		round_toast_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_set_round_toast_shader_progress(0.0)
	if round_toast_label != null:
		round_toast_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		round_toast_label_base_scale = round_toast_label.scale
		round_toast_label.modulate = Color(1.0, 1.0, 1.0, 0.0)


func _show_round_start_banner() -> void:
	_show_round_start_toast(battle_round)


func _show_round_start_toast(round_num: int) -> void:
	if round_toast_root == null:
		return
	if round_toast_tween != null:
		round_toast_tween.kill()

	if round_toast_label != null:
		round_toast_label.text = "BATTLE %d" % round_num
		round_toast_label.visible = true
		round_toast_label.modulate.a = 0.0
		round_toast_label.scale = round_toast_label_base_scale * 0.9
	if round_toast_image != null:
		round_toast_image.visible = true
		round_toast_image.modulate = Color.WHITE
	_set_round_toast_shader_progress(0.0)

	round_toast_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	round_toast_root.visible = true
	round_toast_root.modulate = Color(1.0, 1.0, 1.0, 0.0)
	round_toast_root.scale = round_toast_root_base_scale * 0.86

	round_toast_tween = create_tween()
	round_toast_tween.set_parallel(true)
	round_toast_tween.tween_method(_set_round_toast_shader_progress, 0.0, 1.0, 0.42).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	round_toast_tween.tween_property(round_toast_root, "modulate:a", 1.0, 0.42)
	round_toast_tween.tween_property(round_toast_root, "scale", round_toast_root_base_scale * 1.06, 0.42).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if round_toast_label != null:
		round_toast_tween.tween_property(round_toast_label, "modulate:a", 1.0, 0.28).set_delay(0.05)
		round_toast_tween.tween_property(round_toast_label, "scale", round_toast_label_base_scale, 0.28).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).set_delay(0.05)
	round_toast_tween.set_parallel(false)
	round_toast_tween.chain().tween_property(round_toast_root, "scale", round_toast_root_base_scale, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	round_toast_tween.tween_interval(1.15)
	round_toast_tween.set_parallel(true)
	round_toast_tween.tween_property(round_toast_root, "modulate:a", 0.0, 0.32).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	round_toast_tween.tween_property(round_toast_root, "scale", round_toast_root_base_scale * 1.12, 0.32).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	round_toast_tween.chain().tween_callback(_hide_round_start_toast)


func _set_round_toast_shader_progress(progress: float) -> void:
	if round_toast_image == null:
		return
	var shader_material := round_toast_image.material as ShaderMaterial
	if shader_material == null or shader_material.shader == null:
		return
	shader_material.set_shader_parameter("progress", progress)


func _hide_round_start_toast() -> void:
	if round_toast_root != null:
		round_toast_root.visible = false
		round_toast_root.modulate = Color.WHITE
		round_toast_root.scale = round_toast_root_base_scale
	if round_toast_label != null:
		round_toast_label.modulate = Color.WHITE
		round_toast_label.scale = round_toast_label_base_scale
	_set_round_toast_shader_progress(0.0)


func _start_new_round() -> void:
	battle_round += 1
	_clear_pending_move_snapshot()
	_reset_ally_action_locks_for_new_round()
	_reset_enemy_action_locks_for_new_round()
	_append_battle_log("BATTLE %d 시작" % battle_round)
	_show_round_start_banner()


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


func _apply_enemy_support_group_offset(offset: Vector2) -> void:
	var enemy_support_visual_anchor := _get_enemy_support_visual_anchor_position()
	var enemy_support_base_positions := _get_enemy_support_group_base_positions(enemy_support_visual_anchor)
	_apply_group_offset(_get_enemy_support_group_nodes(), enemy_support_base_positions, offset)
	if enemy_support_unit_click_area != null:
		enemy_support_unit_click_area.position = enemy_support_visual_anchor + enemy_support_click_area_layout_offset + offset


func _apply_enemy_actor_group_offset(offset: Vector2, enemy_actor_state: BattleUnitState) -> void:
	if enemy_actor_state == enemy_support_unit_state:
		_apply_enemy_support_group_offset(offset)
		return
	_apply_enemy_group_offset(offset)


func _set_group_modulate(nodes: Array[CanvasItem], color: Color) -> void:
	for node in nodes:
		node.modulate = color


func _set_ally_group_modulate(color: Color) -> void:
	_set_group_modulate(_get_ally_group_nodes(), color)


func _set_enemy_group_modulate(color: Color) -> void:
	_set_group_modulate(_get_enemy_group_nodes(), color)


func _set_enemy_actor_group_modulate(enemy_actor_state: BattleUnitState, color: Color) -> void:
	_set_group_modulate(_get_enemy_actor_group_nodes(enemy_actor_state), color)


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


func _hide_attack_range_overlay() -> void:
	for cell in move_range_cells:
		cell.visible = false


func _show_attack_range_overlay_for_active_unit() -> void:
	_hide_attack_range_overlay()
	if active_unit_state == null:
		return
	if active_unit_side != "ally":
		return
	if battle_grid_controller == null:
		return

	var origin_cell := active_unit_state.grid_cell
	var attack_range := active_unit_state.attack_range
	var range_cells: Array[Vector2i] = battle_grid_controller.get_tiles_in_range(origin_cell, attack_range)
	var cell_size := battle_grid_controller.get_cell_size()
	if cell_size.x <= 0.0 or cell_size.y <= 0.0:
		return

	var index := 0
	for cell in range_cells:
		if index >= move_range_cells.size():
			break
		if cell == origin_cell:
			continue
		if not battle_grid_controller.is_in_bounds(cell):
			continue

		var world_pos := battle_grid_controller.grid_to_world(cell)
		if not _is_move_range_overlay_rect_inside_visual_board(world_pos, cell_size):
			continue

		var rect := move_range_cells[index]
		rect.position = world_pos - (cell_size * 0.5)
		rect.size = cell_size
		rect.color = ATTACK_RANGE_OVERLAY_COLOR
		rect.visible = true
		index += 1


func _show_move_range_overlay_for_active_unit() -> void:
	_hide_move_range_overlay()
	if active_unit_state == null:
		return
	if active_unit_side != "ally":
		return
	if _has_ally_unit_acted(active_unit_state):
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
	ally_support_unit_state = BattleUnitState.create({
		"unit_id": "jeong_dojeon",
		"display_name": "정도전",
		"side": "ally",
		"hero_name": "정도전",
		"current_hp": 60,
		"max_hp": 60,
		"current_troops": 60,
		"max_troops": 60,
		"attack": 16,
		"defense": 12,
		"move_range": 3,
		"attack_range": 1,
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
	enemy_support_unit_state = BattleUnitState.create({
		"unit_id": "zhang_fei",
		"display_name": "장비",
		"side": "enemy",
		"hero_name": "장비",
		"current_hp": 80,
		"max_hp": 80,
		"current_troops": 80,
		"max_troops": 80,
		"attack": 24,
		"defense": 14,
		"move_range": 3,
		"attack_range": 1,
		"grid_cell": Vector2i.ZERO,
		"facing": FACING_LEFT,
	})


func _sync_unit_state_cells_from_markers() -> void:
	if ally_unit_state != null:
		ally_unit_state.set_grid_cell(_get_cell_from_world(ally_unit_marker.position))
	if ally_support_unit_state != null and ally_support_unit_marker != null:
		ally_support_unit_state.set_grid_cell(_get_cell_from_world(ally_support_unit_marker.position))
	if enemy_unit_state != null:
		enemy_unit_state.set_grid_cell(_get_cell_from_world(enemy_unit_marker.position))
	if enemy_support_unit_state != null and enemy_support_unit_marker != null:
		enemy_support_unit_state.set_grid_cell(_get_cell_from_world(enemy_support_unit_marker.position))


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
	_refresh_initial_unit_facing()
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


func _get_ally_support_visual_anchor_position() -> Vector2:
	if ally_support_unit_marker == null:
		return Vector2.ZERO
	return _get_ally_visual_anchor_from_position(ally_support_unit_marker.position)


func _get_enemy_support_visual_anchor_position() -> Vector2:
	if enemy_support_unit_marker == null:
		return Vector2.ZERO
	return _get_enemy_visual_anchor_from_position(enemy_support_unit_marker.position)


func _capture_template_slot_offset(template_root: Node2D, slot_name: String, fallback_position: Vector2, visual_anchor: Vector2) -> Vector2:
	if template_root != null:
		var slot := template_root.get_node_or_null(slot_name) as Marker2D
		if slot != null:
			return slot.global_position - visual_anchor
	return fallback_position - visual_anchor


func _capture_portrait_template_offsets(template_root: Node2D, fallback_offset: Vector2, visual_anchor: Vector2) -> Dictionary:
	return {
		FACING_LEFT: _capture_template_slot_offset(
			template_root,
			"PortraitLeftSlot",
			visual_anchor + _get_facing_aware_portrait_offset(fallback_offset, FACING_LEFT),
			visual_anchor
		),
		FACING_RIGHT: _capture_template_slot_offset(
			template_root,
			"PortraitRightSlot",
			visual_anchor + _get_facing_aware_portrait_offset(fallback_offset, FACING_RIGHT),
			visual_anchor
		),
		FACING_UP: _capture_template_slot_offset(
			template_root,
			"PortraitUpSlot",
			visual_anchor + fallback_offset,
			visual_anchor
		),
		FACING_DOWN: _capture_template_slot_offset(
			template_root,
			"PortraitDownSlot",
			visual_anchor + fallback_offset,
			visual_anchor
		),
	}


func _get_portrait_template_offset(layout_offsets_by_facing: Dictionary, fallback_offset: Vector2, facing: String) -> Vector2:
	var normalized_facing := _normalize_facing(facing)
	if layout_offsets_by_facing.has(normalized_facing):
		return layout_offsets_by_facing[normalized_facing]
	return _get_facing_aware_portrait_offset(fallback_offset, normalized_facing)


func _sync_runtime_portrait_markers_to_visuals() -> void:
	if ally_portrait_badge != null:
		current_ally_portrait_position = ally_portrait_badge.position
		if ally_portrait_marker != null:
			ally_portrait_marker.position = current_ally_portrait_position
	if ally_support_portrait_badge != null and ally_support_portrait_marker != null:
		ally_support_portrait_marker.position = ally_support_portrait_badge.position
	if enemy_portrait_badge != null and enemy_portrait_marker != null:
		enemy_portrait_marker.position = enemy_portrait_badge.position
	if enemy_support_portrait_badge != null and enemy_support_portrait_marker != null:
		enemy_support_portrait_marker.position = enemy_support_portrait_badge.position


func _capture_scene_authored_unit_layout_offsets() -> void:
	if ally_unit_marker != null:
		var ally_anchor := _get_ally_visual_anchor_from_position(ally_unit_marker.position)
		var ally_portrait_fallback := ally_portrait_badge.position - ally_anchor if ally_portrait_badge != null else Vector2.ZERO
		if ally_unit_token != null:
			ally_token_layout_offset = _capture_template_slot_offset(
				ally_infantry_unit_visual_template,
				"TokenSlot",
				ally_unit_token.position,
				ally_anchor
			)
		if ally_unit_shadow != null:
			ally_shadow_layout_offset = _capture_template_slot_offset(
				ally_infantry_unit_visual_template,
				"ShadowSlot",
				ally_unit_shadow.position,
				ally_anchor
			)
		if ally_portrait_badge != null:
			ally_portrait_layout_offset = ally_portrait_fallback
			ally_portrait_layout_offsets_by_facing = _capture_portrait_template_offsets(
				ally_infantry_unit_visual_template,
				ally_portrait_fallback,
				ally_anchor
			)
		if ally_hp_bar != null:
			ally_hp_bar_layout_offset = _capture_template_slot_offset(
				ally_infantry_unit_visual_template,
				"HPBarSlot",
				ally_hp_bar.position,
				ally_anchor
			)
		if ally_troop_label != null:
			ally_troop_label_layout_offset = _capture_template_slot_offset(
				ally_infantry_unit_visual_template,
				"TroopLabelSlot",
				ally_troop_label.position,
				ally_anchor
			)
		if ally_unit_click_area != null:
			ally_click_area_layout_offset = _capture_template_slot_offset(
				ally_infantry_unit_visual_template,
				"ClickAreaSlot",
				ally_unit_click_area.position,
				ally_anchor
			)
		ally_facing_indicator_layout_offset = _capture_template_slot_offset(
			ally_infantry_unit_visual_template,
			"FacingIndicatorSlot",
			ally_anchor + ally_facing_indicator_layout_offset,
			ally_anchor
		)

	if enemy_unit_marker != null:
		var enemy_anchor := _get_enemy_visual_anchor_from_position(enemy_unit_marker.position)
		var enemy_portrait_fallback := enemy_portrait_badge.position - enemy_anchor if enemy_portrait_badge != null else Vector2.ZERO
		if enemy_unit_token != null:
			enemy_token_layout_offset = _capture_template_slot_offset(
				enemy_infantry_unit_visual_template,
				"TokenSlot",
				enemy_unit_token.position,
				enemy_anchor
			)
		if enemy_unit_shadow != null:
			enemy_shadow_layout_offset = _capture_template_slot_offset(
				enemy_infantry_unit_visual_template,
				"ShadowSlot",
				enemy_unit_shadow.position,
				enemy_anchor
			)
		if enemy_portrait_badge != null:
			enemy_portrait_layout_offset = enemy_portrait_fallback
			enemy_portrait_layout_offsets_by_facing = _capture_portrait_template_offsets(
				enemy_infantry_unit_visual_template,
				enemy_portrait_fallback,
				enemy_anchor
			)
		if enemy_hp_bar != null:
			enemy_hp_bar_layout_offset = _capture_template_slot_offset(
				enemy_infantry_unit_visual_template,
				"HPBarSlot",
				enemy_hp_bar.position,
				enemy_anchor
			)
		if enemy_troop_label != null:
			enemy_troop_label_layout_offset = _capture_template_slot_offset(
				enemy_infantry_unit_visual_template,
				"TroopLabelSlot",
				enemy_troop_label.position,
				enemy_anchor
			)
		if enemy_unit_click_area != null:
			enemy_click_area_layout_offset = _capture_template_slot_offset(
				enemy_infantry_unit_visual_template,
				"ClickAreaSlot",
				enemy_unit_click_area.position,
				enemy_anchor
			)
		enemy_facing_indicator_layout_offset = _capture_template_slot_offset(
			enemy_infantry_unit_visual_template,
			"FacingIndicatorSlot",
			enemy_anchor + enemy_facing_indicator_layout_offset,
			enemy_anchor
		)

	if ally_support_unit_marker != null:
		var ally_support_anchor := _get_ally_visual_anchor_from_position(ally_support_unit_marker.position)
		var ally_support_portrait_fallback := ally_support_portrait_badge.position - ally_support_anchor if ally_support_portrait_badge != null else Vector2.ZERO
		if ally_support_unit_token != null:
			ally_support_token_layout_offset = _capture_template_slot_offset(
				ally_support_infantry_unit_visual_template,
				"TokenSlot",
				ally_support_unit_token.position,
				ally_support_anchor
			)
		if ally_support_unit_shadow != null:
			ally_support_shadow_layout_offset = _capture_template_slot_offset(
				ally_support_infantry_unit_visual_template,
				"ShadowSlot",
				ally_support_unit_shadow.position,
				ally_support_anchor
			)
		if ally_support_portrait_badge != null:
			ally_support_portrait_layout_offset = ally_support_portrait_fallback
			ally_support_portrait_layout_offsets_by_facing = _capture_portrait_template_offsets(
				ally_support_infantry_unit_visual_template,
				ally_support_portrait_fallback,
				ally_support_anchor
			)
		if ally_support_hp_bar != null:
			ally_support_hp_bar_layout_offset = _capture_template_slot_offset(
				ally_support_infantry_unit_visual_template,
				"HPBarSlot",
				ally_support_hp_bar.position,
				ally_support_anchor
			)
		if ally_support_troop_label != null:
			ally_support_troop_label_layout_offset = _capture_template_slot_offset(
				ally_support_infantry_unit_visual_template,
				"TroopLabelSlot",
				ally_support_troop_label.position,
				ally_support_anchor
			)
		if ally_support_unit_click_area != null:
			ally_support_click_area_layout_offset = _capture_template_slot_offset(
				ally_support_infantry_unit_visual_template,
				"ClickAreaSlot",
				ally_support_unit_click_area.position,
				ally_support_anchor
			)
		ally_support_facing_indicator_layout_offset = _capture_template_slot_offset(
			ally_support_infantry_unit_visual_template,
			"FacingIndicatorSlot",
			ally_support_anchor + ally_support_facing_indicator_layout_offset,
			ally_support_anchor
		)

	if enemy_support_unit_marker != null:
		var enemy_support_anchor := _get_enemy_visual_anchor_from_position(enemy_support_unit_marker.position)
		var enemy_support_portrait_fallback := enemy_support_portrait_badge.position - enemy_support_anchor if enemy_support_portrait_badge != null else Vector2.ZERO
		if enemy_support_unit_token != null:
			enemy_support_token_layout_offset = _capture_template_slot_offset(
				enemy_support_infantry_unit_visual_template,
				"TokenSlot",
				enemy_support_unit_token.position,
				enemy_support_anchor
			)
		if enemy_support_unit_shadow != null:
			enemy_support_shadow_layout_offset = _capture_template_slot_offset(
				enemy_support_infantry_unit_visual_template,
				"ShadowSlot",
				enemy_support_unit_shadow.position,
				enemy_support_anchor
			)
		if enemy_support_portrait_badge != null:
			enemy_support_portrait_layout_offset = enemy_support_portrait_fallback
			enemy_support_portrait_layout_offsets_by_facing = _capture_portrait_template_offsets(
				enemy_support_infantry_unit_visual_template,
				enemy_support_portrait_fallback,
				enemy_support_anchor
			)
		if enemy_support_hp_bar != null:
			enemy_support_hp_bar_layout_offset = _capture_template_slot_offset(
				enemy_support_infantry_unit_visual_template,
				"HPBarSlot",
				enemy_support_hp_bar.position,
				enemy_support_anchor
			)
		if enemy_support_troop_label != null:
			enemy_support_troop_label_layout_offset = _capture_template_slot_offset(
				enemy_support_infantry_unit_visual_template,
				"TroopLabelSlot",
				enemy_support_troop_label.position,
				enemy_support_anchor
			)
		if enemy_support_unit_click_area != null:
			enemy_support_click_area_layout_offset = _capture_template_slot_offset(
				enemy_support_infantry_unit_visual_template,
				"ClickAreaSlot",
				enemy_support_unit_click_area.position,
				enemy_support_anchor
			)
		enemy_support_facing_indicator_layout_offset = _capture_template_slot_offset(
			enemy_support_infantry_unit_visual_template,
			"FacingIndicatorSlot",
			enemy_support_anchor + enemy_support_facing_indicator_layout_offset,
			enemy_support_anchor
		)


func _get_ally_group_base_positions(ally_anchor: Vector2) -> Array[Vector2]:
	var portrait_offset := _get_portrait_template_offset(
		ally_portrait_layout_offsets_by_facing,
		ally_portrait_layout_offset,
		_get_unit_facing(ally_unit_state)
	)
	return [
		ally_anchor + ally_shadow_layout_offset,
		ally_anchor + ally_token_layout_offset,
		ally_anchor + portrait_offset,
		ally_anchor + ally_hp_bar_layout_offset,
		ally_anchor + ally_troop_label_layout_offset,
	]


func _get_enemy_group_base_positions(enemy_anchor: Vector2) -> Array[Vector2]:
	var portrait_offset := _get_portrait_template_offset(
		enemy_portrait_layout_offsets_by_facing,
		enemy_portrait_layout_offset,
		_get_unit_facing(enemy_unit_state)
	)
	return [
		enemy_anchor + enemy_shadow_layout_offset,
		enemy_anchor + enemy_token_layout_offset,
		enemy_anchor + portrait_offset,
		enemy_anchor + enemy_hp_bar_layout_offset,
		enemy_anchor + enemy_troop_label_layout_offset,
	]


func _get_ally_support_group_base_positions(ally_support_anchor: Vector2) -> Array[Vector2]:
	var portrait_offset := _get_portrait_template_offset(
		ally_support_portrait_layout_offsets_by_facing,
		ally_support_portrait_layout_offset,
		_get_unit_facing(ally_support_unit_state)
	)
	return [
		ally_support_anchor + ally_support_shadow_layout_offset,
		ally_support_anchor + ally_support_token_layout_offset,
		ally_support_anchor + portrait_offset,
		ally_support_anchor + ally_support_hp_bar_layout_offset,
		ally_support_anchor + ally_support_troop_label_layout_offset,
	]


func _get_enemy_support_group_base_positions(enemy_support_anchor: Vector2) -> Array[Vector2]:
	var portrait_offset := _get_portrait_template_offset(
		enemy_support_portrait_layout_offsets_by_facing,
		enemy_support_portrait_layout_offset,
		_get_unit_facing(enemy_support_unit_state)
	)
	return [
		enemy_support_anchor + enemy_support_shadow_layout_offset,
		enemy_support_anchor + enemy_support_token_layout_offset,
		enemy_support_anchor + portrait_offset,
		enemy_support_anchor + enemy_support_hp_bar_layout_offset,
		enemy_support_anchor + enemy_support_troop_label_layout_offset,
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


func _get_selected_ally_display_name() -> String:
	if active_unit_state == ally_support_unit_state:
		return "정도전"
	return "이순신"


func _get_selected_ally_unit_marker() -> Marker2D:
	if active_unit_state == ally_support_unit_state:
		return ally_support_unit_marker
	return ally_unit_marker


func _get_selected_ally_portrait_marker() -> Marker2D:
	if active_unit_state == ally_support_unit_state:
		return ally_support_portrait_marker
	return ally_portrait_marker


func _get_unit_marker_for_unit(unit_state: BattleUnitState) -> Marker2D:
	if unit_state == ally_support_unit_state:
		return ally_support_unit_marker
	if unit_state == enemy_unit_state:
		return enemy_unit_marker
	if unit_state == enemy_support_unit_state:
		return enemy_support_unit_marker
	return ally_unit_marker


func _get_portrait_marker_for_unit(unit_state: BattleUnitState) -> Marker2D:
	if unit_state == ally_support_unit_state:
		return ally_support_portrait_marker
	if unit_state == enemy_unit_state:
		return enemy_portrait_marker
	if unit_state == enemy_support_unit_state:
		return enemy_support_portrait_marker
	return ally_portrait_marker


func _get_selected_ally_click_area() -> Area2D:
	if active_unit_state == ally_support_unit_state:
		return ally_support_unit_click_area
	return ally_unit_click_area


func _get_selected_ally_visual_anchor_position() -> Vector2:
	if active_unit_state == ally_support_unit_state:
		return _get_ally_support_visual_anchor_position()
	return _get_ally_visual_anchor_position()


func _get_ally_target_visual_anchor_position(target_state: BattleUnitState) -> Vector2:
	if target_state == ally_support_unit_state:
		return _get_ally_support_visual_anchor_position()
	return _get_ally_visual_anchor_position()


func _get_ally_target_group_nodes(target_state: BattleUnitState) -> Array[CanvasItem]:
	if target_state == ally_support_unit_state:
		return _get_ally_support_group_nodes()
	return _get_ally_group_nodes()


func _apply_ally_target_group_offset(offset: Vector2) -> void:
	var target_state := current_enemy_attack_target_state
	if target_state == null:
		target_state = _get_enemy_ai_target_state()
	if target_state == ally_support_unit_state:
		var ally_support_visual_anchor := _get_ally_support_visual_anchor_position()
		var ally_support_base_positions := _get_ally_support_group_base_positions(ally_support_visual_anchor)
		_apply_group_offset(_get_ally_support_group_nodes(), ally_support_base_positions, offset)
		if ally_support_unit_click_area != null:
			ally_support_unit_click_area.position = ally_support_visual_anchor + ally_support_click_area_layout_offset + offset
		return

	_apply_ally_group_offset(offset)


func _set_ally_target_group_modulate(color: Color) -> void:
	var target_state := current_enemy_attack_target_state
	if target_state == null:
		target_state = _get_enemy_ai_target_state()
	if target_state == null:
		return
	_set_group_modulate(_get_ally_target_group_nodes(target_state), color)


func _update_ally_target_visuals_from_state(target_state: BattleUnitState) -> void:
	if target_state == ally_support_unit_state:
		_update_ally_support_visuals_from_state()
		return
	_update_ally_visuals_from_state()


func _apply_selected_ally_group_offset(offset: Vector2) -> void:
	if active_unit_state == ally_support_unit_state:
		var ally_support_visual_anchor := _get_ally_support_visual_anchor_position()
		var ally_support_base_positions := _get_ally_support_group_base_positions(ally_support_visual_anchor)
		_apply_group_offset(_get_ally_support_group_nodes(), ally_support_base_positions, offset)
		if ally_support_unit_click_area != null:
			ally_support_unit_click_area.position = ally_support_visual_anchor + ally_support_click_area_layout_offset + offset
		return

	_apply_ally_group_offset(offset)


func _get_selected_ally_portrait_visual_offset() -> Vector2:
	var portrait_marker := _get_selected_ally_portrait_marker()
	var unit_marker := _get_selected_ally_unit_marker()
	if portrait_marker == null or unit_marker == null:
		return Vector2.ZERO
	return portrait_marker.position - unit_marker.position


func _sync_selected_ally_markers_to_position(unit_position: Vector2, portrait_position: Vector2) -> void:
	var unit_marker := _get_selected_ally_unit_marker()
	var portrait_marker := _get_selected_ally_portrait_marker()
	if unit_marker != null:
		unit_marker.position = unit_position
	if portrait_marker != null:
		portrait_marker.position = portrait_position
	if active_unit_state == ally_unit_state:
		current_ally_unit_position = unit_position
		current_ally_portrait_position = portrait_position


func _get_enemy_target_unit_marker(target_state: BattleUnitState) -> Marker2D:
	if target_state == enemy_support_unit_state:
		return enemy_support_unit_marker
	return enemy_unit_marker


func _get_enemy_target_visual_anchor_position(target_state: BattleUnitState) -> Vector2:
	if target_state == enemy_support_unit_state:
		return _get_enemy_support_visual_anchor_position()
	return _get_enemy_visual_anchor_position()


func _get_enemy_target_group_nodes(target_state: BattleUnitState) -> Array[CanvasItem]:
	if target_state == enemy_support_unit_state:
		return _get_enemy_support_group_nodes()
	return _get_enemy_group_nodes()


func _get_enemy_actor_unit_marker(enemy_actor_state: BattleUnitState) -> Marker2D:
	if enemy_actor_state == enemy_support_unit_state:
		return enemy_support_unit_marker
	return enemy_unit_marker


func _get_enemy_actor_portrait_marker(enemy_actor_state: BattleUnitState) -> Marker2D:
	if enemy_actor_state == enemy_support_unit_state:
		return enemy_support_portrait_marker
	return enemy_portrait_marker


func _get_enemy_actor_visual_anchor_position(enemy_actor_state: BattleUnitState) -> Vector2:
	if enemy_actor_state == enemy_support_unit_state:
		return _get_enemy_support_visual_anchor_position()
	return _get_enemy_visual_anchor_position()


func _get_enemy_actor_group_nodes(enemy_actor_state: BattleUnitState) -> Array[CanvasItem]:
	if enemy_actor_state == enemy_support_unit_state:
		return _get_enemy_support_group_nodes()
	return _get_enemy_group_nodes()


func _update_enemy_actor_visuals_from_state(enemy_actor_state: BattleUnitState) -> void:
	if enemy_actor_state == enemy_support_unit_state:
		_update_enemy_support_visuals_from_state()
		return
	_update_enemy_visuals_from_state()


func _sync_enemy_actor_markers_to_position(enemy_actor_state: BattleUnitState, unit_position: Vector2, portrait_position: Vector2) -> void:
	var unit_marker := _get_enemy_actor_unit_marker(enemy_actor_state)
	var portrait_marker := _get_enemy_actor_portrait_marker(enemy_actor_state)
	if unit_marker != null:
		unit_marker.position = unit_position
	if portrait_marker != null:
		portrait_marker.position = portrait_position


func _apply_enemy_target_group_offset(offset: Vector2) -> void:
	var target_state := current_attack_animation_target_state
	if target_state == null:
		target_state = selected_attack_target_state
	if target_state == null:
		return
	if target_state == enemy_support_unit_state:
		var enemy_support_visual_anchor := _get_enemy_support_visual_anchor_position()
		var enemy_support_base_positions := _get_enemy_support_group_base_positions(enemy_support_visual_anchor)
		_apply_group_offset(_get_enemy_support_group_nodes(), enemy_support_base_positions, offset)
		if enemy_support_unit_click_area != null:
			enemy_support_unit_click_area.position = enemy_support_visual_anchor + enemy_support_click_area_layout_offset + offset
		return

	_apply_enemy_group_offset(offset)


func _set_enemy_target_group_modulate(color: Color) -> void:
	var target_state := current_attack_animation_target_state
	if target_state == null:
		target_state = selected_attack_target_state
	if target_state == null:
		return
	_set_group_modulate(_get_enemy_target_group_nodes(target_state), color)


func _update_enemy_target_visuals_from_state(target_state: BattleUnitState) -> void:
	if target_state == enemy_support_unit_state:
		_update_enemy_support_visuals_from_state()
		return
	_update_enemy_visuals_from_state()


func _get_alive_enemy_targets() -> Array[BattleUnitState]:
	var targets: Array[BattleUnitState] = []
	var candidates: Array = [enemy_unit_state, enemy_support_unit_state]
	for candidate in candidates:
		var target_state := candidate as BattleUnitState
		if target_state != null and target_state.is_alive():
			targets.append(target_state)
	return targets


func _get_enemy_ai_target_state() -> BattleUnitState:
	return _get_enemy_ai_target_state_for_actor(current_enemy_ai_actor_state if current_enemy_ai_actor_state != null else enemy_unit_state)


func _get_enemy_ai_target_state_for_actor(enemy_actor_state: BattleUnitState) -> BattleUnitState:
	if enemy_actor_state == null:
		return null
	var alive_allies := _get_alive_ally_units()
	if alive_allies.is_empty():
		return null

	var best_attackable_target: BattleUnitState = null
	var best_attackable_distance := 9999
	var best_target: BattleUnitState = null
	var best_distance := 9999
	for ally_state in alive_allies:
		var distance := get_unit_grid_distance(enemy_actor_state, ally_state)
		if distance < best_distance:
			best_distance = distance
			best_target = ally_state
		if distance <= enemy_actor_state.attack_range and distance < best_attackable_distance:
			best_attackable_distance = distance
			best_attackable_target = ally_state

	if best_attackable_target != null:
		return best_attackable_target
	return best_target


func _get_legacy_enemy_ai_target_state() -> BattleUnitState:
	if ally_unit_state != null and ally_unit_state.is_alive():
		return ally_unit_state
	if ally_support_unit_state != null and ally_support_unit_state.is_alive():
		return ally_support_unit_state
	return null


func _find_best_attack_target_for_active_ally() -> BattleUnitState:
	if active_unit_state == null:
		return null

	var best_target: BattleUnitState = null
	var best_distance := 9999
	for target_state in _get_alive_enemy_targets():
		if not is_unit_in_attack_range(active_unit_state, target_state):
			continue
		var distance := get_unit_grid_distance(active_unit_state, target_state)
		if distance < best_distance:
			best_distance = distance
			best_target = target_state
	return best_target


func _refresh_attack_target_for_active_ally() -> void:
	if active_unit_state == null:
		_clear_attack_target_selection()
		return

	if selected_attack_target_state != null:
		if selected_attack_target_state.is_alive() and is_unit_in_attack_range(active_unit_state, selected_attack_target_state):
			_show_attack_target_feedback()
			return

	var best_target := _find_best_attack_target_for_active_ally()
	if best_target != null:
		selected_attack_target_state = best_target
		selected_attack_target_side = "enemy"
		_show_attack_target_feedback()
		return

	_clear_attack_target_selection()


func _get_alive_ally_units() -> Array[BattleUnitState]:
	var allies: Array[BattleUnitState] = []
	var candidates: Array = [ally_unit_state, ally_support_unit_state]
	for candidate in candidates:
		var unit_state := candidate as BattleUnitState
		if unit_state != null and unit_state.is_alive():
			allies.append(unit_state)
	return allies


func _get_alive_enemy_units() -> Array[BattleUnitState]:
	var enemies: Array[BattleUnitState] = []
	var candidates: Array = [enemy_unit_state, enemy_support_unit_state]
	for candidate in candidates:
		var unit_state := candidate as BattleUnitState
		if unit_state != null and unit_state.is_alive():
			enemies.append(unit_state)
	return enemies


func _mark_ally_unit_acted(unit_state: BattleUnitState) -> void:
	if unit_state == null:
		return
	if unit_state.side != "ally":
		return
	if unit_state.unit_id == "":
		return
	acted_ally_unit_ids[unit_state.unit_id] = true
	unit_state.has_acted = true
	unit_state.has_moved = true
	if unit_state == active_unit_state:
		ally_has_moved = true


func _has_ally_unit_acted(unit_state: BattleUnitState) -> bool:
	if unit_state == null:
		return true
	if unit_state.side != "ally":
		return false
	if unit_state.unit_id == "":
		return unit_state.has_acted
	return bool(acted_ally_unit_ids.get(unit_state.unit_id, unit_state.has_acted))


func _reset_ally_action_locks_for_new_round() -> void:
	acted_ally_unit_ids.clear()
	for unit_state in _get_alive_ally_units():
		unit_state.reset_action_flags()
	ally_has_moved = false


func _mark_enemy_unit_acted(unit_state: BattleUnitState) -> void:
	if unit_state == null:
		return
	if unit_state.side != "enemy":
		return
	if unit_state.unit_id == "":
		return
	acted_enemy_unit_ids[unit_state.unit_id] = true
	unit_state.has_acted = true
	unit_state.has_moved = true


func _has_enemy_unit_acted(unit_state: BattleUnitState) -> bool:
	if unit_state == null:
		return true
	if unit_state.side != "enemy":
		return false
	if unit_state.unit_id == "":
		return unit_state.has_acted
	return bool(acted_enemy_unit_ids.get(unit_state.unit_id, unit_state.has_acted))


func _reset_enemy_action_locks_for_new_round() -> void:
	acted_enemy_unit_ids.clear()
	for unit_state in _get_alive_enemy_units():
		unit_state.reset_action_flags()


func _are_all_alive_enemies_acted() -> bool:
	var alive_enemies := _get_alive_enemy_units()
	if alive_enemies.is_empty():
		return true
	for unit_state in alive_enemies:
		if not _has_enemy_unit_acted(unit_state):
			return false
	return true


func _get_next_available_enemy_ai_actor() -> BattleUnitState:
	var candidates: Array = [enemy_unit_state, enemy_support_unit_state]
	for candidate in candidates:
		var unit_state := candidate as BattleUnitState
		if unit_state != null and unit_state.is_alive() and not _has_enemy_unit_acted(unit_state):
			return unit_state
	return null


func _are_all_alive_allies_acted() -> bool:
	var alive_allies := _get_alive_ally_units()
	if alive_allies.is_empty():
		return false
	for unit_state in alive_allies:
		if not _has_ally_unit_acted(unit_state):
			return false
	return true


func _get_first_available_ally_unit() -> BattleUnitState:
	for unit_state in _get_alive_ally_units():
		if not _has_ally_unit_acted(unit_state):
			return unit_state
	return null


func _is_active_ally_action_available() -> bool:
	if active_unit_state == null:
		return false
	if active_unit_side != "ally":
		return false
	if not active_unit_state.is_alive():
		return false
	return not _has_ally_unit_acted(active_unit_state)


func _is_active_ally_locked() -> bool:
	if active_unit_state == null:
		return false
	if active_unit_side != "ally":
		return false
	if not active_unit_state.is_alive():
		return false
	if _has_ally_unit_acted(active_unit_state):
		return false
	return active_unit_state.has_moved or current_phase == PHASE_FACING_SELECT or current_phase == PHASE_ATTACK_SELECT


func _is_ally_selection_switch_blocked(unit_state: BattleUnitState) -> bool:
	if unit_state == null or unit_state == active_unit_state:
		return false
	return _is_active_ally_locked()


func _is_unit_selectable(unit_state: BattleUnitState) -> bool:
	return unit_state != null and unit_state.is_alive()


func _cleanup_dead_units() -> void:
	var unit_candidates: Array = [
		ally_unit_state,
		ally_support_unit_state,
		enemy_unit_state,
		enemy_support_unit_state,
	]
	for candidate in unit_candidates:
		var unit_state := candidate as BattleUnitState
		if unit_state == null:
			continue
		var is_alive := unit_state.is_alive()
		_set_unit_visual_group_visible(unit_state, is_alive)
		_set_unit_click_area_enabled(unit_state, is_alive)
		if not is_alive and not bool(dead_unit_ids.get(unit_state.unit_id, false)):
			dead_unit_ids[unit_state.unit_id] = true
			acted_ally_unit_ids.erase(unit_state.unit_id)
			acted_enemy_unit_ids.erase(unit_state.unit_id)
			_append_battle_log("%s 전멸" % unit_state.display_name)
			if selected_attack_target_state == unit_state:
				_clear_attack_target_selection()
			if pending_move_snapshot_unit_state == unit_state:
				_clear_pending_move_snapshot()
			if active_unit_state == unit_state:
				active_unit_state = null
				_hide_unit_closeup_panel()
	_update_ally_ready_frames()


func _set_unit_visual_group_visible(unit_state: BattleUnitState, should_show: bool) -> void:
	for node in _get_visual_group_nodes_for_unit(unit_state):
		if node != null:
			node.visible = should_show
	var facing_indicator := _get_facing_indicator_for_unit(unit_state)
	if facing_indicator != null:
		facing_indicator.visible = should_show and facing_indicators_should_be_visible


func _set_unit_click_area_enabled(unit_state: BattleUnitState, should_enable: bool) -> void:
	var click_area := _get_click_area_for_unit(unit_state)
	if click_area == null:
		return
	click_area.monitoring = should_enable
	click_area.monitorable = should_enable
	click_area.input_pickable = should_enable


func _get_visual_group_nodes_for_unit(unit_state: BattleUnitState) -> Array[CanvasItem]:
	if unit_state == ally_support_unit_state:
		return _get_ally_support_group_nodes()
	if unit_state == enemy_unit_state:
		return _get_enemy_group_nodes()
	if unit_state == enemy_support_unit_state:
		return _get_enemy_support_group_nodes()
	return _get_ally_group_nodes()


func _get_click_area_for_unit(unit_state: BattleUnitState) -> Area2D:
	if unit_state == ally_support_unit_state:
		return ally_support_unit_click_area
	if unit_state == enemy_unit_state:
		return enemy_unit_click_area
	if unit_state == enemy_support_unit_state:
		return enemy_support_unit_click_area
	return ally_unit_click_area


func _get_facing_indicator_for_unit(unit_state: BattleUnitState) -> Label:
	if unit_state == ally_support_unit_state:
		return ally_support_facing_indicator
	if unit_state == enemy_unit_state:
		return enemy_facing_indicator
	if unit_state == enemy_support_unit_state:
		return enemy_support_facing_indicator
	return ally_facing_indicator


func set_move_target_cell(cell: Vector2i) -> void:
	if battle_grid_controller == null:
		return
	if move_target_marker == null:
		return
	if not battle_grid_controller.is_in_bounds(cell):
		return
	if not _is_valid_destination_for_unit(cell, active_unit_state, true):
		_append_battle_log("다른 부대가 있어 이동할 수 없습니다")
		return
	if not is_valid_move_target(cell):
		return

	var world_pos := battle_grid_controller.grid_to_world(cell)
	if move_target_marker.get_parent() is Node2D:
		move_target_marker.position = (move_target_marker.get_parent() as Node2D).to_local(world_pos)
	else:
		move_target_marker.global_position = world_pos

	selected_move_cell = cell
	has_selected_move_target = true
	_refresh_move_target_feedback()


func _select_ally_unit(unit_state: BattleUnitState, should_log: bool = true) -> void:
	if not _is_unit_selectable(unit_state):
		return
	if _is_ally_selection_switch_blocked(unit_state):
		return

	active_unit_state = unit_state
	_update_cell_size_visual_guide(active_unit_state.grid_cell)
	active_unit_side = "ally"
	ally_has_moved = active_unit_state.has_moved
	_clear_move_target_selection()
	_clear_attack_target_selection()
	_show_unit_closeup_for_ally(active_unit_state)
	_update_ally_ready_frames()
	if should_log:
		_append_battle_log("%s 선택" % _get_selected_ally_display_name())
	if _has_ally_unit_acted(active_unit_state):
		_hide_move_range_overlay()
		_append_battle_log("이미 행동한 부대입니다")
		_set_phase(PHASE_ALLY_TURN)
		_update_ally_ready_frames()
		return
	_refresh_move_target_feedback()
	_show_move_range_overlay_for_active_unit()
	_set_phase(PHASE_ALLY_TURN)
	_update_ally_ready_frames()


func _select_enemy_attack_target(target_state: BattleUnitState) -> void:
	if target_state == null:
		return
	if not target_state.is_alive():
		return

	selected_attack_target_state = target_state
	selected_attack_target_side = "enemy"
	_clear_move_target_selection()
	_append_battle_log("%s 공격 대상 선택" % target_state.display_name)
	_show_attack_target_feedback()


func _clear_attack_target_selection() -> void:
	selected_attack_target_state = null
	selected_attack_target_side = ""
	current_attack_animation_target_state = null
	if attack_highlight != null:
		attack_highlight.visible = false


func _show_attack_target_feedback() -> void:
	if attack_highlight == null:
		return
	if selected_attack_target_state == null:
		return

	var highlight_size := MOVE_HIGHLIGHT_SIZE
	var target_marker := _get_enemy_target_unit_marker(selected_attack_target_state)
	var world_pos := target_marker.position if target_marker != null else Vector2.ZERO
	if battle_grid_controller != null:
		var cell_size := battle_grid_controller.get_cell_size()
		if cell_size.x > 0.0 and cell_size.y > 0.0:
			highlight_size = cell_size
		world_pos = battle_grid_controller.grid_to_world(selected_attack_target_state.grid_cell)

	var highlight_pos := world_pos - (highlight_size * 0.5)
	if attack_highlight.get_parent() is Node2D:
		var parent_node := attack_highlight.get_parent() as Node2D
		highlight_pos = parent_node.to_local(world_pos) - (highlight_size * 0.5)

	attack_highlight.position = highlight_pos
	attack_highlight.size = highlight_size
	attack_highlight.visible = true


func _is_click_inside_ally_support_click_area(mouse_pos: Vector2) -> bool:
	if ally_support_unit_click_area == null:
		return false
	if ally_support_unit_click_shape == null:
		return false
	if ally_support_unit_click_shape.shape == null:
		return false

	var local_pos := ally_support_unit_click_area.to_local(mouse_pos)
	local_pos -= ally_support_unit_click_shape.position
	if ally_support_unit_click_shape.shape is RectangleShape2D:
		var rect_shape := ally_support_unit_click_shape.shape as RectangleShape2D
		return Rect2(-rect_shape.size * 0.5, rect_shape.size).has_point(local_pos)
	if ally_support_unit_click_shape.shape is CircleShape2D:
		var circle_shape := ally_support_unit_click_shape.shape as CircleShape2D
		return local_pos.length() <= circle_shape.radius
	return false


func _is_click_inside_enemy_support_click_area(mouse_pos: Vector2) -> bool:
	if enemy_support_unit_click_area == null:
		return false
	if enemy_support_unit_click_shape == null:
		return false
	if enemy_support_unit_click_shape.shape == null:
		return false

	var local_pos := enemy_support_unit_click_area.to_local(mouse_pos)
	local_pos -= enemy_support_unit_click_shape.position
	if enemy_support_unit_click_shape.shape is RectangleShape2D:
		var rect_shape := enemy_support_unit_click_shape.shape as RectangleShape2D
		return Rect2(-rect_shape.size * 0.5, rect_shape.size).has_point(local_pos)
	if enemy_support_unit_click_shape.shape is CircleShape2D:
		var circle_shape := enemy_support_unit_click_shape.shape as CircleShape2D
		return local_pos.length() <= circle_shape.radius
	return false


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
	for unit_state in _get_all_alive_unit_states():
		if unit_state.grid_cell == cell:
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


func _get_all_alive_unit_states() -> Array[BattleUnitState]:
	var alive_units: Array[BattleUnitState] = []
	var unit_candidates: Array = [
		ally_unit_state,
		ally_support_unit_state,
		enemy_unit_state,
		enemy_support_unit_state,
	]
	for candidate in unit_candidates:
		var unit_state := candidate as BattleUnitState
		if unit_state != null and unit_state.is_alive():
			alive_units.append(unit_state)
	return alive_units


func _get_occupied_cells_except(unit_state: BattleUnitState) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	if ALLOW_BREAKTHROUGH_MOVE:
		return cells
	for alive_unit_state in _get_all_alive_unit_states():
		if alive_unit_state == unit_state:
			continue
		cells.append(alive_unit_state.grid_cell)
	return cells


func _is_cell_occupied_except(cell: Vector2i, unit_state: BattleUnitState) -> bool:
	for occupied_cell in _get_occupied_cells_except(unit_state):
		if occupied_cell == cell:
			return true
	return false


func _get_occupied_cells_for_move() -> Array[Vector2i]:
	return _get_occupied_cells_except(active_unit_state)


func _is_cell_occupied_for_move(cell: Vector2i) -> bool:
	return _is_cell_occupied_except(cell, active_unit_state)


func _is_valid_destination_for_unit(target_cell: Vector2i, mover_state: BattleUnitState, should_log: bool = false) -> bool:
	if mover_state == null:
		return false
	if battle_grid_controller == null:
		return false
	if not battle_grid_controller.is_in_bounds(target_cell):
		return false
	if _is_cell_occupied_except(target_cell, mover_state):
		if should_log:
			print("[OCCUPIED BLOCK] mover=%s target=%s occupied_by_other=true" % [
				mover_state.display_name,
				target_cell,
			])
		return false
	return true


func _is_path_clear_for_unit(path: Array[Vector2i], mover_state: BattleUnitState, should_log: bool = false) -> bool:
	if mover_state == null:
		return false
	if path.is_empty():
		return false

	for index in range(path.size()):
		if index == 0:
			continue
		var cell := path[index]
		if _is_cell_occupied_except(cell, mover_state):
			if should_log:
				print("[PATH BLOCK] mover=%s blocked_cell=%s" % [
					mover_state.display_name,
					cell,
				])
			return false
	return true


func _is_cell_walkable_for_ally(cell: Vector2i, start_cell: Vector2i) -> bool:
	if battle_grid_controller == null:
		return false
	if not battle_grid_controller.is_in_bounds(cell):
		return false
	if cell == start_cell:
		return true
	if _is_cell_occupied_except(cell, active_unit_state):
		return false
	return true


func _find_ally_move_path(start_cell: Vector2i, target_cell: Vector2i) -> Array[Vector2i]:
	var empty_path: Array[Vector2i] = []
	if battle_grid_controller == null:
		return empty_path
	if start_cell == target_cell:
		return [start_cell]
	if not _is_valid_destination_for_unit(target_cell, active_unit_state):
		return empty_path
	if not _is_cell_walkable_for_ally(target_cell, start_cell):
		return empty_path

	var max_steps := get_active_move_range()
	var frontier: Array[Vector2i] = [start_cell]
	var came_from: Dictionary = {start_cell: start_cell}
	var steps_from_start: Dictionary = {start_cell: 0}
	var directions: Array[Vector2i] = [
		Vector2i(1, 0),
		Vector2i(-1, 0),
		Vector2i(0, 1),
		Vector2i(0, -1),
	]

	while not frontier.is_empty():
		var current: Vector2i = frontier.pop_front()
		if current == target_cell:
			break

		var current_steps: int = steps_from_start.get(current, 0)
		if current_steps >= max_steps:
			continue

		for direction in directions:
			var next: Vector2i = current + direction
			if came_from.has(next):
				continue
			if not _is_cell_walkable_for_ally(next, start_cell):
				continue
			came_from[next] = current
			steps_from_start[next] = current_steps + 1
			frontier.append(next)

	if not came_from.has(target_cell):
		return empty_path

	var path: Array[Vector2i] = []
	var cursor: Vector2i = target_cell
	while cursor != start_cell:
		path.push_front(cursor)
		cursor = came_from[cursor]
	path.push_front(start_cell)

	if path.size() - 1 > max_steps:
		return empty_path
	if not _is_path_clear_for_unit(path, active_unit_state):
		return empty_path
	return path


func _get_occupied_cells_for_enemy_move() -> Array[Vector2i]:
	return _get_occupied_cells_except(current_enemy_ai_actor_state if current_enemy_ai_actor_state != null else enemy_unit_state)


func _is_cell_walkable_for_enemy(cell: Vector2i, start_cell: Vector2i) -> bool:
	return _is_cell_walkable_for_enemy_actor(enemy_unit_state, cell, start_cell)


func _is_cell_walkable_for_enemy_actor(enemy_actor_state: BattleUnitState, cell: Vector2i, start_cell: Vector2i) -> bool:
	if battle_grid_controller == null:
		return false
	if not battle_grid_controller.is_in_bounds(cell):
		return false
	if cell == start_cell:
		return true
	if _is_cell_occupied_except(cell, enemy_actor_state):
		return false
	return true


func _find_enemy_move_path(start_cell: Vector2i, target_cell: Vector2i) -> Array[Vector2i]:
	return _find_enemy_move_path_for_actor(enemy_unit_state, start_cell, target_cell)


func _find_enemy_move_path_for_actor(enemy_actor_state: BattleUnitState, start_cell: Vector2i, target_cell: Vector2i) -> Array[Vector2i]:
	var empty_path: Array[Vector2i] = []
	if battle_grid_controller == null:
		return empty_path
	if enemy_actor_state == null:
		return empty_path
	if start_cell == target_cell:
		return [start_cell]
	if not _is_valid_destination_for_unit(target_cell, enemy_actor_state):
		return empty_path
	if not _is_cell_walkable_for_enemy_actor(enemy_actor_state, target_cell, start_cell):
		return empty_path

	var max_steps := enemy_actor_state.move_range
	var frontier: Array[Vector2i] = [start_cell]
	var came_from: Dictionary = {start_cell: start_cell}
	var steps_from_start: Dictionary = {start_cell: 0}
	var directions: Array[Vector2i] = [
		Vector2i(1, 0),
		Vector2i(-1, 0),
		Vector2i(0, 1),
		Vector2i(0, -1),
	]

	while not frontier.is_empty():
		var current: Vector2i = frontier.pop_front()
		if current == target_cell:
			break

		var current_steps: int = steps_from_start.get(current, 0)
		if current_steps >= max_steps:
			continue

		for direction in directions:
			var next: Vector2i = current + direction
			if came_from.has(next):
				continue
			if not _is_cell_walkable_for_enemy_actor(enemy_actor_state, next, start_cell):
				continue
			came_from[next] = current
			steps_from_start[next] = current_steps + 1
			frontier.append(next)

	if not came_from.has(target_cell):
		return empty_path

	var path: Array[Vector2i] = []
	var cursor: Vector2i = target_cell
	while cursor != start_cell:
		path.push_front(cursor)
		cursor = came_from[cursor]
	path.push_front(start_cell)

	if path.size() - 1 > max_steps:
		return empty_path
	if not _is_path_clear_for_unit(path, enemy_actor_state):
		return empty_path
	return path


func _get_enemy_reachable_paths(start_cell: Vector2i) -> Dictionary:
	return _get_enemy_reachable_paths_for_actor(enemy_unit_state, start_cell)


func _get_enemy_reachable_paths_for_actor(enemy_actor_state: BattleUnitState, start_cell: Vector2i) -> Dictionary:
	var reachable_paths: Dictionary = {}
	if battle_grid_controller == null or enemy_actor_state == null:
		return reachable_paths

	var frontier: Array[Vector2i] = [start_cell]
	var came_from: Dictionary = {start_cell: start_cell}
	var steps_from_start: Dictionary = {start_cell: 0}
	var max_steps := enemy_actor_state.move_range
	var directions: Array[Vector2i] = [
		Vector2i(1, 0),
		Vector2i(-1, 0),
		Vector2i(0, 1),
		Vector2i(0, -1),
	]

	while not frontier.is_empty():
		var current: Vector2i = frontier.pop_front()
		var current_steps: int = steps_from_start.get(current, 0)
		if current_steps >= max_steps:
			continue

		for direction in directions:
			var next: Vector2i = current + direction
			if came_from.has(next):
				continue
			if not _is_cell_walkable_for_enemy_actor(enemy_actor_state, next, start_cell):
				continue
			came_from[next] = current
			steps_from_start[next] = current_steps + 1
			frontier.append(next)

	for cell_variant in came_from.keys():
		var cell: Vector2i = cell_variant
		if not _is_valid_destination_for_unit(cell, enemy_actor_state):
			continue
		var path: Array[Vector2i] = []
		var cursor: Vector2i = cell
		while cursor != start_cell:
			path.push_front(cursor)
			cursor = came_from[cursor]
		path.push_front(start_cell)
		if not _is_path_clear_for_unit(path, enemy_actor_state):
			continue
		reachable_paths[cell] = path

	return reachable_paths


func _choose_enemy_basic_ai_destination() -> Vector2i:
	return _choose_enemy_basic_ai_destination_for_actor(enemy_unit_state, _get_enemy_ai_target_state_for_actor(enemy_unit_state))


func _choose_enemy_basic_ai_destination_for_actor(enemy_actor_state: BattleUnitState, target_state: BattleUnitState) -> Vector2i:
	if enemy_actor_state == null:
		return Vector2i.ZERO
	if target_state == null:
		return enemy_actor_state.grid_cell

	var start_cell := enemy_actor_state.grid_cell
	var reachable_paths := _get_enemy_reachable_paths_for_actor(enemy_actor_state, start_cell)
	var current_distance := get_unit_grid_distance(enemy_actor_state, target_state)
	var best_attack_cell := start_cell
	var best_attack_distance := 9999
	var best_attack_path_length := 9999
	var best_approach_cell := start_cell
	var best_approach_distance := current_distance
	var best_approach_path_length := 9999

	for cell_variant in reachable_paths.keys():
		var candidate_cell: Vector2i = cell_variant
		if candidate_cell == start_cell:
			continue
		if not _is_valid_destination_for_unit(candidate_cell, enemy_actor_state):
			continue

		var path = reachable_paths[candidate_cell] as Array
		var path_length := path.size() - 1
		if path_length <= 0:
			continue
		var typed_path: Array[Vector2i] = []
		for path_cell_variant in path:
			var path_cell: Vector2i = path_cell_variant
			typed_path.append(path_cell)
		if not _is_path_clear_for_unit(typed_path, enemy_actor_state):
			continue

		var candidate_distance := absi(candidate_cell.x - target_state.grid_cell.x) + absi(candidate_cell.y - target_state.grid_cell.y)
		var can_attack_after_move := candidate_distance <= enemy_actor_state.attack_range

		if can_attack_after_move:
			if candidate_distance < best_attack_distance or (candidate_distance == best_attack_distance and path_length < best_attack_path_length):
				best_attack_cell = candidate_cell
				best_attack_distance = candidate_distance
				best_attack_path_length = path_length
			continue

		if candidate_distance < best_approach_distance or (candidate_distance == best_approach_distance and path_length < best_approach_path_length):
			best_approach_cell = candidate_cell
			best_approach_distance = candidate_distance
			best_approach_path_length = path_length

	if best_attack_cell != start_cell:
		return best_attack_cell
	if best_approach_cell != start_cell and best_approach_distance < current_distance:
		return best_approach_cell
	return start_cell


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
	if active_unit_state == null:
		return false
	if enemy_unit_state == null:
		return false
	if battle_grid_controller == null:
		return false
	if not enemy_unit_state.is_alive():
		return false

	var distance := get_unit_grid_distance(active_unit_state, enemy_unit_state)
	print("ALLY RANGE CHECK")
	print("ally grid: ", active_unit_state.grid_cell)
	print("enemy grid: ", enemy_unit_state.grid_cell)
	print("dist: ", distance, " range: ", active_unit_state.attack_range)
	return is_unit_in_attack_range(active_unit_state, enemy_unit_state)


func is_valid_move_target(target_cell: Vector2i) -> bool:
	if active_unit_state == null:
		return false
	if active_unit_side != "ally":
		return false
	if not _is_valid_grid_cell(target_cell):
		return false
	if _has_ally_unit_acted(active_unit_state):
		return false
	if active_unit_state.has_moved:
		return false

	var origin_cell: Vector2i = get_active_move_origin_cell()
	if target_cell == origin_cell:
		return false
	if not _is_valid_destination_for_unit(target_cell, active_unit_state):
		return false
	var path := _find_ally_move_path(origin_cell, target_cell)
	if path.is_empty():
		return false
	return _is_path_clear_for_unit(path, active_unit_state)


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
	_update_ally_support_visuals_from_state()
	_update_enemy_visuals_from_state()
	_update_enemy_support_visuals_from_state()
	_update_facing_indicators()
	_cleanup_dead_units()


func _update_ally_visuals_from_state() -> void:
	if ally_unit_state == null:
		return
	_apply_token_facing_visual(ally_unit_token, ally_unit_state.facing, "ally")
	ally_hp_bar.max_value = ally_unit_state.max_hp
	ally_hp_bar.value = ally_unit_state.current_hp
	ally_troop_label.text = ally_unit_state.get_troop_label_text()


func _update_ally_support_visuals_from_state() -> void:
	if ally_support_unit_state == null:
		return
	_apply_token_facing_visual(ally_support_unit_token, ally_support_unit_state.facing, "ally")
	ally_support_hp_bar.max_value = ally_support_unit_state.max_hp
	ally_support_hp_bar.value = ally_support_unit_state.current_hp
	ally_support_troop_label.text = ally_support_unit_state.get_troop_label_text()


func _update_enemy_visuals_from_state() -> void:
	if enemy_unit_state == null:
		return
	_apply_token_facing_visual(enemy_unit_token, enemy_unit_state.facing, "enemy")
	enemy_hp_bar.max_value = enemy_unit_state.max_hp
	enemy_hp_bar.value = enemy_unit_state.current_hp
	enemy_troop_label.text = enemy_unit_state.get_troop_label_text()


func _update_enemy_support_visuals_from_state() -> void:
	if enemy_support_unit_state == null:
		return
	_apply_token_facing_visual(enemy_support_unit_token, enemy_support_unit_state.facing, "enemy")
	enemy_support_hp_bar.max_value = enemy_support_unit_state.max_hp
	enemy_support_hp_bar.value = enemy_support_unit_state.current_hp
	enemy_support_troop_label.text = enemy_support_unit_state.get_troop_label_text()


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


func _face_unit_toward_cell(unit_state: BattleUnitState, target_cell: Vector2i) -> void:
	if unit_state == null:
		return

	if unit_state.grid_cell.x < target_cell.x:
		_set_unit_facing(unit_state, FACING_RIGHT)
	elif unit_state.grid_cell.x > target_cell.x:
		_set_unit_facing(unit_state, FACING_LEFT)
	elif unit_state.grid_cell.y > target_cell.y:
		_set_unit_facing(unit_state, FACING_UP)
	elif unit_state.grid_cell.y < target_cell.y:
		_set_unit_facing(unit_state, FACING_DOWN)


func _refresh_initial_unit_facing() -> void:
	if ally_unit_state == null or enemy_unit_state == null:
		return

	if not ally_has_manual_facing:
		_face_unit_toward_cell(ally_unit_state, enemy_unit_state.grid_cell)
	if not enemy_has_manual_facing:
		_face_unit_toward_cell(enemy_unit_state, ally_unit_state.grid_cell)

	_apply_unit_facing_visuals()
	_reset_unit_group_positions()


func _refresh_ally_facing_toward_enemy_if_not_manual() -> void:
	if active_unit_state == null or enemy_unit_state == null:
		return
	if ally_has_manual_facing:
		return

	_face_unit_toward_cell(active_unit_state, enemy_unit_state.grid_cell)
	_apply_unit_facing_visuals()
	_reset_unit_group_positions()


func _refresh_enemy_facing_for_enemy_action() -> void:
	_refresh_enemy_facing_for_actor_action(enemy_unit_state, _get_enemy_ai_target_state_for_actor(enemy_unit_state))


func _refresh_enemy_facing_for_actor_action(enemy_actor_state: BattleUnitState, target_state: BattleUnitState) -> void:
	if enemy_actor_state == null or target_state == null:
		return
	if enemy_has_manual_facing:
		return

	_face_unit_toward_cell(enemy_actor_state, target_state.grid_cell)
	_apply_unit_facing_visuals()
	_reset_unit_group_positions()


func _apply_unit_facing_visuals() -> void:
	if ally_unit_token != null and ally_unit_state != null:
		_apply_token_facing_visual(ally_unit_token, ally_unit_state.facing, "ally")
	if ally_support_unit_token != null and ally_support_unit_state != null:
		_apply_token_facing_visual(ally_support_unit_token, ally_support_unit_state.facing, "ally")
	if enemy_unit_token != null and enemy_unit_state != null:
		_apply_token_facing_visual(enemy_unit_token, enemy_unit_state.facing, "enemy")
	if enemy_support_unit_token != null and enemy_support_unit_state != null:
		_apply_token_facing_visual(enemy_support_unit_token, enemy_support_unit_state.facing, "enemy")
	if ally_portrait_badge != null:
		ally_portrait_badge.flip_h = false
	if ally_support_portrait_badge != null:
		ally_support_portrait_badge.flip_h = false
	if enemy_portrait_badge != null:
		enemy_portrait_badge.flip_h = false
	if enemy_support_portrait_badge != null:
		enemy_support_portrait_badge.flip_h = false
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
		ally_facing_indicator.visible = facing_indicators_should_be_visible and ally_unit_state.is_alive()
		_position_facing_indicator_for_ally()

	if ally_support_unit_state != null and ally_support_facing_indicator != null:
		ally_support_facing_indicator.text = _get_facing_arrow_text(ally_support_unit_state.facing)
		ally_support_facing_indicator.visible = facing_indicators_should_be_visible and ally_support_unit_state.is_alive()
		_position_facing_indicator_for_ally_support()

	if enemy_unit_state != null and enemy_facing_indicator != null:
		enemy_facing_indicator.text = _get_facing_arrow_text(enemy_unit_state.facing)
		enemy_facing_indicator.visible = facing_indicators_should_be_visible and enemy_unit_state.is_alive()
		_position_facing_indicator_for_enemy()

	if enemy_support_unit_state != null and enemy_support_facing_indicator != null:
		enemy_support_facing_indicator.text = _get_facing_arrow_text(enemy_support_unit_state.facing)
		enemy_support_facing_indicator.visible = facing_indicators_should_be_visible and enemy_support_unit_state.is_alive()
		_position_facing_indicator_for_enemy_support()


func _position_facing_indicator_for_ally() -> void:
	if ally_facing_indicator == null or ally_unit_token == null:
		return
	var world_anchor := _get_ally_visual_anchor_position() + ally_facing_indicator_layout_offset
	ally_facing_indicator.position = _world_to_battle_ui_position(world_anchor)


func _position_facing_indicator_for_ally_support() -> void:
	if ally_support_facing_indicator == null or ally_support_unit_token == null:
		return
	var world_anchor := _get_ally_support_visual_anchor_position() + ally_support_facing_indicator_layout_offset
	ally_support_facing_indicator.position = _world_to_battle_ui_position(world_anchor)


func _position_facing_indicator_for_enemy() -> void:
	if enemy_facing_indicator == null or enemy_unit_token == null:
		return
	var world_anchor := _get_enemy_visual_anchor_position() + enemy_facing_indicator_layout_offset
	enemy_facing_indicator.position = _world_to_battle_ui_position(world_anchor)


func _position_facing_indicator_for_enemy_support() -> void:
	if enemy_support_facing_indicator == null or enemy_support_unit_token == null:
		return
	var world_anchor := _get_enemy_support_visual_anchor_position() + enemy_support_facing_indicator_layout_offset
	enemy_support_facing_indicator.position = _world_to_battle_ui_position(world_anchor)


func _set_facing_indicators_visible(should_show: bool) -> void:
	facing_indicators_should_be_visible = should_show
	if ally_facing_indicator != null:
		ally_facing_indicator.visible = should_show and ally_unit_state != null and ally_unit_state.is_alive()
	if ally_support_facing_indicator != null:
		ally_support_facing_indicator.visible = should_show and ally_support_unit_state != null and ally_support_unit_state.is_alive()
	if enemy_facing_indicator != null:
		enemy_facing_indicator.visible = should_show and enemy_unit_state != null and enemy_unit_state.is_alive()
	if enemy_support_facing_indicator != null:
		enemy_support_facing_indicator.visible = should_show and enemy_support_unit_state != null and enemy_support_unit_state.is_alive()


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
