extends Node2D

const DEMO_DAMAGE := 12.0
const ALLY_DEMO_HP := 94.0
const ENEMY_DEMO_HP := 100.0
const ATTACK_LUNGE_DISTANCE := 42.0
const HP_BAR_OFFSET := Vector2(-54.0, 52.0)
const TROOP_LABEL_OFFSET := Vector2(-48.0, 64.0)
const SHADOW_OFFSET := Vector2(0.0, 42.0)
const IDLE_SCALE_MULTIPLIER := 1.035
const IDLE_DURATION := 1.15
const ENEMY_GUARD_STEP_DISTANCE := 18.0
const MOVE_HIGHLIGHT_SIZE := Vector2(68.0, 56.0)
const PHASE_ALLY_TURN := "ally_turn"
const PHASE_ENEMY_TURN := "enemy_turn"
const PHASE_RESOLVING := "resolving"
const MAX_BATTLE_LOG_LINES := 4

var is_demo_animating := false
var ally_has_moved := false
var current_phase := PHASE_ALLY_TURN
var battle_log_lines: Array[String] = []
var current_ally_unit_position := Vector2.ZERO
var current_ally_portrait_position := Vector2.ZERO
var ally_unit_state: BattleUnitState
var enemy_unit_state: BattleUnitState
var ally_idle_tween: Tween
var enemy_idle_tween: Tween
var ally_token_base_scale := Vector2.ONE
var enemy_token_base_scale := Vector2.ONE

@onready var battlefield_texture: Sprite2D = $BattlefieldRoot/BattlefieldTexture
@onready var ally_unit_marker: Marker2D = $AllyUnitMarker
@onready var enemy_unit_marker: Marker2D = $EnemyUnitMarker
@onready var ally_portrait_marker: Marker2D = $AllyPortraitMarker
@onready var enemy_portrait_marker: Marker2D = $EnemyPortraitMarker
@onready var move_target_marker: Marker2D = $MoveTargetMarker
@onready var battle_grid_controller: BattleGridController = $BattleGridController
@onready var damage_spawn_marker: Marker2D = $DamageSpawnMarker
@onready var cutin_center_marker: Marker2D = $CutinCenterMarker
@onready var result_center_marker: Marker2D = $ResultCenterMarker
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
@onready var top_bar: Panel = $BattleUI/TopBar
@onready var left_panel: Panel = $BattleUI/LeftPanel
@onready var right_panel: Panel = $BattleUI/RightPanel
@onready var command_bar: Panel = $BattleUI/CommandBar
@onready var basic_attack_button: Button = $BattleUI/CommandBar/BasicAttackButton
@onready var move_button: Button = $BattleUI/CommandBar/MoveButton
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
	basic_attack_button.pressed.connect(play_basic_attack_demo)
	move_button.pressed.connect(play_basic_move_demo)
	reset_demo_state()


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
	_stop_idle_breathing()
	battle_log_lines = [
		"아군 준비",
		"관우 방어",
	]
	current_ally_unit_position = ally_unit_marker.position
	current_ally_portrait_position = ally_portrait_marker.position
	_create_demo_unit_states()
	_sync_unit_state_cells_from_markers()
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
	_refresh_battle_log()
	cutin_overlay.visible = false
	result_overlay.visible = false
	_start_idle_breathing()


func play_basic_move_demo() -> void:
	if is_demo_animating or current_phase != PHASE_ALLY_TURN or ally_has_moved:
		return

	is_demo_animating = true
	_set_phase(PHASE_RESOLVING)
	_stop_idle_breathing()
	_sync_demo_positions()
	_show_move_highlight_at_target()
	move_highlight.visible = true

	var target_unit_position := move_target_marker.position
	var portrait_offset := ally_portrait_marker.position - ally_unit_marker.position
	var target_portrait_position := target_unit_position + portrait_offset
	var move_offset := target_unit_position - current_ally_unit_position

	var tween := create_tween()
	tween.tween_method(_apply_ally_group_offset, Vector2.ZERO, move_offset, 0.42).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(_finish_basic_move_demo.bind(target_unit_position, target_portrait_position))


func _finish_basic_move_demo(target_unit_position: Vector2, target_portrait_position: Vector2) -> void:
	current_ally_unit_position = target_unit_position
	current_ally_portrait_position = target_portrait_position
	ally_unit_state.set_grid_cell(_get_cell_from_world(target_unit_position))
	ally_has_moved = true
	_reset_unit_group_positions()
	move_highlight.visible = false
	is_demo_animating = false
	_append_battle_log("이순신 이동")
	_set_phase(PHASE_ALLY_TURN)
	_start_idle_breathing()


func play_basic_attack_demo() -> void:
	if is_demo_animating or current_phase != PHASE_ALLY_TURN:
		return

	is_demo_animating = true
	_set_phase(PHASE_RESOLVING)
	_stop_idle_breathing()
	_sync_demo_positions()
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
	tween.set_parallel(true)
	tween.tween_method(_apply_ally_group_offset, Vector2.ZERO, ally_lunge_offset, 0.16).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_method(_apply_enemy_group_offset, Vector2.ZERO, enemy_recoil_offset, 0.08).set_delay(0.14)
	tween.tween_method(_set_enemy_group_modulate, Color.WHITE, Color(1.0, 0.45, 0.45, 1.0), 0.08).set_delay(0.14)
	tween.tween_property(damage_preview_label, "position", Vector2(0.0, -36.0), 0.42).set_delay(0.14)
	tween.tween_property(damage_preview_label, "modulate:a", 0.0, 0.42).set_delay(0.14)
	tween.set_parallel(false)
	tween.tween_method(_apply_ally_group_offset, ally_lunge_offset, Vector2.ZERO, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_method(_apply_enemy_group_offset, enemy_recoil_offset, Vector2.ZERO, 0.10)
	tween.tween_method(_set_enemy_group_modulate, Color(1.0, 0.45, 0.45, 1.0), Color.WHITE, 0.10)
	tween.finished.connect(_finish_basic_attack_demo)

	enemy_unit_state.apply_damage(int(DEMO_DAMAGE))
	_update_enemy_visuals_from_state()
	_append_battle_log("이순신 공격")
	_append_battle_log("관우 피해")


func _sync_demo_positions() -> void:
	_reset_unit_group_positions()


func _reset_unit_group_positions() -> void:
	ally_unit_shadow.position = current_ally_unit_position + SHADOW_OFFSET
	enemy_unit_shadow.position = enemy_unit_marker.position + SHADOW_OFFSET
	ally_unit_token.position = current_ally_unit_position
	enemy_unit_token.position = enemy_unit_marker.position
	ally_portrait_badge.position = current_ally_portrait_position
	enemy_portrait_badge.position = enemy_portrait_marker.position
	ally_hp_bar.position = current_ally_unit_position + HP_BAR_OFFSET
	enemy_hp_bar.position = enemy_unit_marker.position + HP_BAR_OFFSET
	ally_troop_label.position = current_ally_unit_position + TROOP_LABEL_OFFSET
	enemy_troop_label.position = enemy_unit_marker.position + TROOP_LABEL_OFFSET


func _finish_basic_attack_demo() -> void:
	_reset_unit_group_positions()
	_set_group_modulate(_get_ally_group_nodes(), Color.WHITE)
	_set_group_modulate(_get_enemy_group_nodes(), Color.WHITE)
	damage_preview_label.visible = false
	is_demo_animating = false
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
		_:
			turn_banner.text = "처리 중"

	basic_attack_button.disabled = current_phase != PHASE_ALLY_TURN or is_demo_animating
	move_button.disabled = current_phase != PHASE_ALLY_TURN or is_demo_animating or ally_has_moved


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

	var guard_direction := (current_ally_unit_position - enemy_unit_marker.position).normalized()
	var guard_offset := guard_direction * ENEMY_GUARD_STEP_DISTANCE
	var settle_offset := -guard_offset * 0.35

	var tween := create_tween()
	tween.tween_interval(0.28)
	tween.tween_callback(_enemy_guard_pulse_on)
	tween.tween_method(_apply_enemy_group_offset, Vector2.ZERO, guard_offset, 0.16).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_method(_apply_enemy_group_offset, guard_offset, settle_offset, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_method(_apply_enemy_group_offset, settle_offset, Vector2.ZERO, 0.16).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(_enemy_guard_pulse_off)
	tween.tween_interval(0.18)
	tween.tween_callback(_return_to_ally_turn)


func _enemy_guard_pulse_on() -> void:
	_append_battle_log("관우 방어")
	_set_enemy_group_modulate(Color(0.82, 0.92, 1.0, 1.0))


func _enemy_guard_pulse_off() -> void:
	_set_enemy_group_modulate(Color.WHITE)


func _return_to_ally_turn() -> void:
	_reset_unit_group_positions()
	_set_enemy_group_modulate(Color.WHITE)
	is_demo_animating = false
	ally_has_moved = false
	_set_phase(PHASE_ALLY_TURN)
	_append_battle_log("아군 턴 복귀")
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
	_apply_group_offset(
		_get_ally_group_nodes(),
		[
			current_ally_unit_position + SHADOW_OFFSET,
			current_ally_unit_position,
			current_ally_portrait_position,
			current_ally_unit_position + HP_BAR_OFFSET,
			current_ally_unit_position + TROOP_LABEL_OFFSET,
		],
		offset
	)


func _apply_enemy_group_offset(offset: Vector2) -> void:
	_apply_group_offset(
		_get_enemy_group_nodes(),
		[
			enemy_unit_marker.position + SHADOW_OFFSET,
			enemy_unit_marker.position,
			enemy_portrait_marker.position,
			enemy_unit_marker.position + HP_BAR_OFFSET,
			enemy_unit_marker.position + TROOP_LABEL_OFFSET,
		],
		offset
	)


func _set_group_modulate(nodes: Array[CanvasItem], color: Color) -> void:
	for node in nodes:
		node.modulate = color


func _set_enemy_group_modulate(color: Color) -> void:
	_set_group_modulate(_get_enemy_group_nodes(), color)


func _show_move_highlight_at_target() -> void:
	move_highlight.position = move_target_marker.position - (MOVE_HIGHLIGHT_SIZE * 0.5)
	move_highlight.size = MOVE_HIGHLIGHT_SIZE


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
		"attack_range": 1,
		"grid_cell": Vector2i.ZERO,
		"facing": "right",
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
		"facing": "left",
	})


func _sync_unit_state_cells_from_markers() -> void:
	if ally_unit_state != null:
		ally_unit_state.set_grid_cell(_get_cell_from_world(ally_unit_marker.position))
	if enemy_unit_state != null:
		enemy_unit_state.set_grid_cell(_get_cell_from_world(enemy_unit_marker.position))


func _get_cell_from_world(pos: Vector2) -> Vector2i:
	return battle_grid_controller.world_to_grid(pos)


func _format_cell(cell: Vector2i) -> String:
	return "(%d,%d)" % [cell.x, cell.y]


func _update_all_unit_visuals_from_state() -> void:
	_update_ally_visuals_from_state()
	_update_enemy_visuals_from_state()


func _update_ally_visuals_from_state() -> void:
	if ally_unit_state == null:
		return
	ally_hp_bar.max_value = ally_unit_state.max_hp
	ally_hp_bar.value = ally_unit_state.current_hp
	ally_troop_label.text = ally_unit_state.get_troop_label_text()


func _update_enemy_visuals_from_state() -> void:
	if enemy_unit_state == null:
		return
	enemy_hp_bar.max_value = enemy_unit_state.max_hp
	enemy_hp_bar.value = enemy_unit_state.current_hp
	enemy_troop_label.text = enemy_unit_state.get_troop_label_text()


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
