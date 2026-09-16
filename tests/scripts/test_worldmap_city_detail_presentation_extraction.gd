extends SceneTree

const ControllerScript := preload("res://scripts/worldmap/economy_city/city_detail_presentation_controller.gd")

class MockCityInfoPanel:
	extends Node
	var last_recruitment_message := ""
	func show_recruitment_result(message: String) -> void:
		last_recruitment_message = message

var _checks := 0
var _failures := 0
var _governor_request := []
var _recruitment_request := []
var _hero_transfer_request := []
var _attack_request := []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var controller := ControllerScript.new()
	root.add_child(controller)
	var panel := MockCityInfoPanel.new()
	root.add_child(panel)
	var nodes := _build_nodes(panel)
	controller.set_ui_nodes(nodes)
	controller.governor_assignment_requested.connect(_on_governor_requested)
	controller.recruitment_requested.connect(_on_recruitment_requested)
	controller.hero_transfer_confirmed.connect(_on_hero_transfer_confirmed)
	controller.attack_requested.connect(_on_attack_requested)

	var model := {
		"food_resources": "쌀 ★★★ / 보리 ★★",
		"strategy_resources": "목재 ★★ / 철 ★",
		"special_resources": "비단 ★ / 소금 ★★",
		"population_rating": "★★★★",
		"commerce_rating": "★★★",
		"economy_bonus_lines": ["경제 +4%"],
		"military_bonus_lines": ["방어 +5%"],
		"naval_bonus_lines": [],
		"spy_bonus_lines": [],
		"storage_summary": "성 창고\n금전 300",
		"economy_modifier_summary": "생산 보정 +4%",
	}
	controller.apply_resource_tab(model)
	_expect((nodes.type as Label).text == "자원 잠재력\n식량 자원", "resource/default tab renders")
	var summary := controller.format_city_storage_summary({"gold": 12, "rice": 100, "barley": 50, "seafood": 0, "wood": 3, "iron": 2, "horses": 1, "silk": 4, "salt": 5}, {"rice": "쌀", "barley": "보리", "seafood": "수산물", "wood": "목재", "iron": "철", "horses": "말", "silk": "비단", "salt": "소금"}, ["rice", "barley", "seafood"], ["wood", "iron", "horses"], ["silk", "salt"])
	_expect(summary == "성 창고\n금전 12\n식량 150 주의\n쌀 100 / 보리 50 / 수산물 0\n전략 6 부족\n목재 3 / 철 2 / 말 1\n특산 9 부족\n비단 4 / 소금 5", "city storage summary parity")
	_expect(controller.get_city_storage_status_label(99) == "부족" and controller.get_city_storage_status_label(100) == "주의" and controller.get_city_storage_status_label(300) == "안정", "resource status label parity")
	_expect((nodes.rating as Label).text.contains("인구 ★★★★ / 상업력 ★★★") and (nodes.rating as Label).text.contains("경제 +4%"), "governor and economy display model parity")
	controller.show_recruitment_result("한성 모병 +100")
	_expect(panel.last_recruitment_message == "한성 모병 +100", "recruitment success message")
	_expect(controller.format_recruitment_failure_hint("loyalty") == "충성도 부족 · 모병 불가", "recruitment loyalty failure")
	_expect(controller.format_recruitment_failure_hint("resources") == "자원 부족 · 금전/식량 확인", "recruitment resources failure")
	_expect(controller.format_recruitment_failure_hint("amount") == "모병 단위 오류", "recruitment invalid amount")

	controller.relay_governor_assignment_requested("hanseong", "hero_a")
	_expect(_governor_request == ["hanseong", "hero_a"], "governor assignment request emitted")
	controller.relay_recruitment_requested("hanseong", 100)
	_expect(_recruitment_request == ["hanseong", 100], "recruitment request emitted")
	controller.relay_hero_transfer_confirmed("hanseong", "hero_a", "sabi")
	_expect(_hero_transfer_request == ["hanseong", "hero_a", "sabi"], "hero transfer callback remains external")
	controller.relay_attack_requested("sabi")
	_expect(_attack_request == ["sabi"], "attack callback remains external")
	_expect(controller.refresh_tab_styles("trade", "internal-trade", "diplomacy-spy", "trade") == "trade" and (nodes.internal_trade_tab as Button).modulate == Color(1.0, 0.9, 0.68, 1.0), "internal trade delegates existing Trade path")
	_expect(controller.refresh_tab_styles("trade", "external-trade", "diplomacy-spy", "trade") == "trade" and (nodes.external_trade_tab as Button).modulate == Color(1.0, 0.9, 0.68, 1.0), "external trade delegates existing Trade path")
	_expect(not controller.has_method("recruit_troops"), "no recruitment mutation")
	_expect(not controller.has_method("assign_governor"), "no governor mutation")
	_expect(not controller.has_method("get_player_state"), "no player-state direct access")
	_expect(not controller.has_method("save_game"), "no save dependency")
	_expect((nodes.status as Label).text == "성 창고\n금전 300\n생산 보정 +4%" and (nodes.hint as Label).text == "자원 잠재력은 생산 기반, 성 창고는 현재 보유량입니다.", "visual node and text contract parity")
	var empty_controller := ControllerScript.new()
	root.add_child(empty_controller)
	empty_controller.set_ui_nodes({})
	empty_controller.apply_resource_tab({})
	_expect(empty_controller.refresh_tab_styles("city-detail", "unknown", "diplomacy-spy", "trade") == "resources", "unknown or missing city presentation is safe")
	_finish()


func _build_nodes(panel: Node) -> Dictionary:
	return {
		"city_info_panel": panel,
		"resource_tab": Button.new(),
		"internal_trade_tab": Button.new(),
		"external_trade_tab": Button.new(),
		"type": Label.new(),
		"region_owner": Label.new(),
		"resource": Label.new(),
		"security": Label.new(),
		"military": Label.new(),
		"commerce": Label.new(),
		"rating": Label.new(),
		"status": Label.new(),
		"hint": Label.new(),
		"domestic_button": Button.new(),
		"resource_card": PanelContainer.new(),
		"storage_card": PanelContainer.new(),
		"trade_card": PanelContainer.new(),
	}


func _on_governor_requested(city_id: String, governor_id: String) -> void:
	_governor_request = [city_id, governor_id]


func _on_recruitment_requested(city_id: String, amount: int) -> void:
	_recruitment_request = [city_id, amount]


func _on_hero_transfer_confirmed(source_city_id: String, hero_id: String, target_city_id: String) -> void:
	_hero_transfer_request = [source_city_id, hero_id, target_city_id]


func _on_attack_requested(city_id: String) -> void:
	_attack_request = [city_id]


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("[CITY_DETAIL_PRESENTATION_FAIL] %s" % label)


func _finish() -> void:
	print("[CITY_DETAIL_PRESENTATION] %s: %d checks, %d failures" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	quit(0 if _failures == 0 else 1)
