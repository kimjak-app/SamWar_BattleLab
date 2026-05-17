extends Node2D

const DEMO_DAMAGE := 12.0
const ALLY_DEMO_HP := 94.0
const ENEMY_DEMO_HP := 100.0
const ATTACK_LUNGE_DISTANCE := 42.0
const HP_BAR_OFFSET := Vector2(-54.0, 52.0)
const TROOP_LABEL_OFFSET := Vector2(-48.0, 78.0)

var is_demo_animating := false
var ally_demo_troops := int(ALLY_DEMO_HP)
var enemy_demo_troops := int(ENEMY_DEMO_HP)

@onready var battlefield_texture: Sprite2D = $BattlefieldRoot/BattlefieldTexture
@onready var ally_unit_marker: Marker2D = $AllyUnitMarker
@onready var enemy_unit_marker: Marker2D = $EnemyUnitMarker
@onready var ally_portrait_marker: Marker2D = $AllyPortraitMarker
@onready var enemy_portrait_marker: Marker2D = $EnemyPortraitMarker
@onready var damage_spawn_marker: Marker2D = $DamageSpawnMarker
@onready var cutin_center_marker: Marker2D = $CutinCenterMarker
@onready var result_center_marker: Marker2D = $ResultCenterMarker
@onready var ally_unit_token: Sprite2D = $AllySide/AllyUnitToken
@onready var enemy_unit_token: Sprite2D = $EnemySide/EnemyUnitToken
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
@onready var battle_log_preview: Label = $BattleUI/LeftPanel/BattleLogPreview
@onready var cutin_overlay: CanvasLayer = $CutinOverlay
@onready var cutin_image: TextureRect = $CutinOverlay/CutinImage
@onready var cutin_name_label: Label = $CutinOverlay/CutinNameLabel
@onready var cutin_quote_label: Label = $CutinOverlay/CutinQuoteLabel
@onready var result_overlay: CanvasLayer = $ResultOverlay
@onready var result_image: TextureRect = $ResultOverlay/ResultImage
@onready var result_title_label: Label = $ResultOverlay/ResultTitleLabel


func _ready() -> void:
	basic_attack_button.pressed.connect(play_basic_attack_demo)
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
	_sync_demo_positions()
	_sync_overlay_positions()
	ally_hp_bar.value = ALLY_DEMO_HP
	enemy_hp_bar.value = ENEMY_DEMO_HP
	ally_demo_troops = int(ALLY_DEMO_HP)
	enemy_demo_troops = int(ENEMY_DEMO_HP)
	_update_troop_labels()
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
	battle_log_preview.text = "전투 기록\n- 이순신이 전진했습니다.\n- 관우가 방어 태세입니다."
	basic_attack_button.disabled = false
	cutin_overlay.visible = false
	result_overlay.visible = false


func play_basic_attack_demo() -> void:
	if is_demo_animating:
		return

	is_demo_animating = true
	basic_attack_button.disabled = true
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

	enemy_hp_bar.value = maxf(enemy_hp_bar.value - DEMO_DAMAGE, 0.0)
	enemy_demo_troops = maxi(enemy_demo_troops - int(DEMO_DAMAGE), 0)
	_update_troop_labels()
	battle_log_preview.text = "전투 기록\n- 이순신이 관우에게 기본 공격을 가했습니다."


func _sync_demo_positions() -> void:
	_reset_unit_group_positions()


func _reset_unit_group_positions() -> void:
	ally_unit_token.position = ally_unit_marker.position
	enemy_unit_token.position = enemy_unit_marker.position
	ally_portrait_badge.position = ally_portrait_marker.position
	enemy_portrait_badge.position = enemy_portrait_marker.position
	ally_hp_bar.position = ally_unit_marker.position + HP_BAR_OFFSET
	enemy_hp_bar.position = enemy_unit_marker.position + HP_BAR_OFFSET
	ally_troop_label.position = ally_unit_marker.position + TROOP_LABEL_OFFSET
	enemy_troop_label.position = enemy_unit_marker.position + TROOP_LABEL_OFFSET


func _finish_basic_attack_demo() -> void:
	_reset_unit_group_positions()
	_set_group_modulate(_get_ally_group_nodes(), Color.WHITE)
	_set_group_modulate(_get_enemy_group_nodes(), Color.WHITE)
	damage_preview_label.visible = false
	basic_attack_button.disabled = false
	is_demo_animating = false


func _get_ally_group_nodes() -> Array[CanvasItem]:
	return [ally_unit_token, ally_portrait_badge, ally_hp_bar, ally_troop_label]


func _get_enemy_group_nodes() -> Array[CanvasItem]:
	return [enemy_unit_token, enemy_portrait_badge, enemy_hp_bar, enemy_troop_label]


func _apply_group_offset(nodes: Array[CanvasItem], base_positions: Array[Vector2], offset: Vector2) -> void:
	for index in range(nodes.size()):
		nodes[index].position = base_positions[index] + offset


func _apply_ally_group_offset(offset: Vector2) -> void:
	_apply_group_offset(
		_get_ally_group_nodes(),
		[
			ally_unit_marker.position,
			ally_portrait_marker.position,
			ally_unit_marker.position + HP_BAR_OFFSET,
			ally_unit_marker.position + TROOP_LABEL_OFFSET,
		],
		offset
	)


func _apply_enemy_group_offset(offset: Vector2) -> void:
	_apply_group_offset(
		_get_enemy_group_nodes(),
		[
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


func _format_troop_label(value: int) -> String:
	return "%d / %d" % [value, value]


func _update_troop_labels() -> void:
	ally_troop_label.text = _format_troop_label(ally_demo_troops)
	enemy_troop_label.text = _format_troop_label(enemy_demo_troops)


func _sync_overlay_positions() -> void:
	var cutin_center: Vector2 = cutin_center_marker.global_position
	var result_center: Vector2 = result_center_marker.global_position

	cutin_image.position = cutin_center + Vector2(-220.0, -160.0)
	cutin_name_label.position = cutin_center + Vector2(-150.0, 128.0)
	cutin_quote_label.position = cutin_center + Vector2(-220.0, 200.0)
	result_image.position = result_center + Vector2(-220.0, -170.0)
	result_title_label.position = result_center + Vector2(-108.0, 176.0)
