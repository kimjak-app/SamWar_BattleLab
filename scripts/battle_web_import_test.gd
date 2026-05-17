extends Node2D

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
@onready var damage_text_layer: Node2D = $DamageTextLayer
@onready var main_camera: Camera2D = $MainCamera
@onready var top_bar: Panel = $BattleUI/TopBar
@onready var left_panel: Panel = $BattleUI/LeftPanel
@onready var right_panel: Panel = $BattleUI/RightPanel
@onready var command_bar: Panel = $BattleUI/CommandBar
@onready var cutin_overlay: CanvasLayer = $CutinOverlay
@onready var cutin_image: TextureRect = $CutinOverlay/CutinImage
@onready var cutin_name_label: Label = $CutinOverlay/CutinNameLabel
@onready var cutin_quote_label: Label = $CutinOverlay/CutinQuoteLabel
@onready var result_overlay: CanvasLayer = $ResultOverlay
@onready var result_image: TextureRect = $ResultOverlay/ResultImage
@onready var result_title_label: Label = $ResultOverlay/ResultTitleLabel


func _ready() -> void:
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
	_sync_demo_positions()
	_sync_overlay_positions()
	ally_hp_bar.value = 84.0
	enemy_hp_bar.value = 62.0
	cutin_name_label.text = "학익진 포격"
	cutin_quote_label.text = "사정거리 안 모든 적을 포격하라!"
	result_title_label.text = "승리"
	damage_text_layer.position = damage_spawn_marker.position
	cutin_overlay.visible = false
	result_overlay.visible = false


func _sync_demo_positions() -> void:
	ally_unit_token.position = ally_unit_marker.position
	enemy_unit_token.position = enemy_unit_marker.position
	ally_portrait_badge.position = ally_portrait_marker.position
	enemy_portrait_badge.position = enemy_portrait_marker.position
	ally_hp_bar.position = ally_unit_marker.position + Vector2(-54.0, 52.0)
	enemy_hp_bar.position = enemy_unit_marker.position + Vector2(-54.0, 52.0)


func _sync_overlay_positions() -> void:
	var cutin_center: Vector2 = cutin_center_marker.global_position
	var result_center: Vector2 = result_center_marker.global_position

	cutin_image.position = cutin_center + Vector2(-220.0, -160.0)
	cutin_name_label.position = cutin_center + Vector2(-150.0, 128.0)
	cutin_quote_label.position = cutin_center + Vector2(-220.0, 200.0)
	result_image.position = result_center + Vector2(-220.0, -170.0)
	result_title_label.position = result_center + Vector2(-108.0, 176.0)
