extends Node

## Test-scene-only bottom HUD preview data.
##
## This deliberately writes only to ProductionHudRoot preview labels. It neither
## creates BattleSupplyRuntime nor fabricates WorldMap battle context.

const SHOW_WARNING_SAMPLE := false


func _ready() -> void:
	_apply_preview()


func _process(_delta: float) -> void:
	_apply_preview()


func _apply_preview() -> void:
	var controller := get_parent()
	if controller == null:
		return
	_set_text(controller, "BattleUI/ProductionHudRoot/BattleLogHud/RecentLogLabel", "아군 준비\n권율 방어\n테스트 전투\n최근 행동 대기")
	_set_text(controller, "BattleUI/ProductionHudRoot/ActorComparisonHud/LeftActorPanel/RoleLabel", "현재 행동")
	_set_text(controller, "BattleUI/ProductionHudRoot/ActorComparisonHud/LeftActorPanel/DetailLabel", "이순신\n궁병 · 병력 94 / 94\n행동 가능")
	_set_text(controller, "BattleUI/ProductionHudRoot/ActorComparisonHud/CenterContextPanel/ContextLabel", "명령 상태 · 선택 대기")
	_set_text(controller, "BattleUI/ProductionHudRoot/ActorComparisonHud/RightSubjectPanel/RoleLabel", "대상")
	_set_text(controller, "BattleUI/ProductionHudRoot/ActorComparisonHud/RightSubjectPanel/DetailLabel", "대상 없음")
	_set_text(controller, "BattleUI/ProductionHudRoot/InteractionGuideHud/PhaseLabel", "아군 턴")
	_set_text(controller, "BattleUI/ProductionHudRoot/InteractionGuideHud/InstructionLabel", "행동할 아군 부대를 선택하거나 명령을 선택하세요.")
	_set_text(controller, "BattleUI/ProductionHudRoot/InteractionGuideHud/DisabledReasonLabel", "")
	_set_text(controller, "BattleUI/ProductionHudRoot/BottomHudRoot/BattleSupplyPreviewPanel/Margin/Content/Header/TurnLabel", "3 / 30 · 잔여 27")
	_sync_supply_column(controller, "AllyColumn", "식량 820", "소금 120", "턴당 소비 34", "유지 24턴", SHOW_WARNING_SAMPLE)
	_sync_supply_column(controller, "EnemyColumn", "식량 740", "소금 80", "턴당 소비 31", "유지 23턴", false)


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
