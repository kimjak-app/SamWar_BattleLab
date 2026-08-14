extends Node

## Test-scene-only bottom HUD preview data.
##
## T13-4A adds the current-actor card as an authored standalone subscene so its
## position and child offsets remain editable in Godot 2D. This bridge only
## instantiates that preview scene and writes sample text to older preview HUDs;
## it does not fabricate authoritative battle actor data.

const SHOW_WARNING_SAMPLE := false
const CURRENT_ACTOR_INFO_HUD_PREVIEW_SCENE := preload("res://tests/scenes/ui/current_actor_info_hud_placeholder.tscn")


func _ready() -> void:
	_ensure_current_actor_info_hud_preview()
	_apply_preview()


func _process(_delta: float) -> void:
	_apply_preview()


func _ensure_current_actor_info_hud_preview() -> void:
	var controller := get_parent()
	if controller == null:
		return
	var production_root := controller.get_node_or_null("BattleUI/ProductionHudRoot") as Control
	if production_root == null:
		return
	if production_root.get_node_or_null("CurrentActorInfoHud") == null:
		var preview_hud := CURRENT_ACTOR_INFO_HUD_PREVIEW_SCENE.instantiate() as Control
		if preview_hud != null:
			production_root.add_child(preview_hud)
	_hide_legacy_actor_comparison(production_root)


func _apply_preview() -> void:
	var controller := get_parent()
	if controller == null:
		return
	var production_root := controller.get_node_or_null("BattleUI/ProductionHudRoot") as Control
	if production_root != null:
		_hide_legacy_actor_comparison(production_root)
	_set_text(controller, "BattleUI/ProductionHudRoot/InteractionGuideHud/PhaseLabel", "아군 턴")
	_set_text(controller, "BattleUI/ProductionHudRoot/InteractionGuideHud/InstructionLabel", "행동할 아군 부대를 선택하거나 명령을 선택하세요.")
	_set_text(controller, "BattleUI/ProductionHudRoot/InteractionGuideHud/DisabledReasonLabel", "")
	_set_text(controller, "BattleUI/ProductionHudRoot/BottomHudRoot/BattleSupplyPreviewPanel/Margin/Content/Header/TurnLabel", "3 / 30 · 잔여 27")
	_sync_supply_column(controller, "AllyColumn", "식량 820", "소금 120", "턴당 소비 34", "유지 24턴", SHOW_WARNING_SAMPLE)
	_sync_supply_column(controller, "EnemyColumn", "식량 740", "소금 80", "턴당 소비 31", "유지 23턴", false)


func _hide_legacy_actor_comparison(production_root: Control) -> void:
	var legacy_hud := production_root.get_node_or_null("ActorComparisonHud") as Control
	if legacy_hud != null:
		legacy_hud.visible = false


func _sync_supply_column(controller: Node, column: String, food: String, salt: String, consumption: String, sustain: String, warning: bool) -> void:
	var root := "BattleUI/ProductionHudRoot/BottomHudRoot/BattleSupplyPreviewPanel/Margin/Content/Columns/%s" % column
	_set_text(controller, root + "/FoodValue", food)
	_set_text(controller, root + "/SaltValue", salt)
	_set_text(controller, root + "/ConsumptionValue", consumption)
	_set_text(controller, root + "/SustainValue", sustain)
	var warning_label := controller.get_node_or_null(root + "/WarningLabel") as Label
	if warning_label != null:
		warning_label.text = "소금 고갈 · 식량 소비 +10%"
		warning_label.visible = warning


func _set_text(controller: Node, path: String, value: String) -> void:
	var label := controller.get_node_or_null(path) as Label
	if label != null:
		label.text = value
