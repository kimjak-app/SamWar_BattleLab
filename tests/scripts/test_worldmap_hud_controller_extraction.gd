extends SceneTree

const ControllerScript := preload("res://scripts/worldmap/hud/worldmap_hud_controller.gd")

class MockCityPanel:
	extends Control
	var player_faction_id := ""
	var city_data := {}
	func set_player_faction_id(value: String) -> void: player_faction_id = value
	func set_enemy_city_intel(_value: Dictionary) -> void: pass
	func set_hud_data(_heroes: Dictionary, cities: Dictionary, _policies: Dictionary, _state: Dictionary) -> void: city_data = cities
	func set_recruitment_summaries(_value: Dictionary) -> void: pass
	func set_revolt_risk_summaries(_value: Dictionary) -> void: pass

var _checks := 0
var _failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var controller := ControllerScript.new()
	root.add_child(controller)
	var panel := MockCityPanel.new()
	root.add_child(panel)
	var nodes := _build_nodes(panel)
	controller.set_ui_nodes(nodes)
	controller.setup_world_status_panel(Callable(), Vector2(10.0, 10.0), Vector2(320.0, 570.0))
	controller.refresh_world_status({
		"eyebrow": "플레이어 국가 · 조선",
		"calendar": "제 2턴 · 154년 봄 2일 · 아군 턴",
		"nation": "수도: 한성",
		"power": "국가충성도 75 · 안정",
		"national_loyalty": 75,
		"tax": "세금 수준 30 · 평소 수준",
		"tax_level": 30,
		"public_order": 68,
		"chancellor_name": "정도전",
		"chancellor_data": {},
		"chancellor_policy_description": "효과: 균형 운영",
		"national_bonus_lines": ["농업 +5%"],
		"external_trade": "교역 없음",
		"world_status_hint": "침공 없음",
		"turn_end_disabled": true,
		"save_status": "저장 완료",
		"warehouse_rows": [{"resource_id": "gold", "amount": "500 / 9999", "status": "안정", "status_color": Color.GREEN}],
	})
	_expect((nodes.calendar as Label).text.contains("제 2턴"), "turn and phase presentation")
	_expect((nodes.power as Label).text == "국가충성도 75 · 안정", "world status presentation")
	_expect((nodes.turn_end as Button).disabled, "HUD enabled state")
	controller.refresh_selected_city_binding({"player_faction_id": "joseon", "city_data": {"hanseong": {"name": "한성"}}})
	_expect(panel.player_faction_id == "joseon" and panel.city_data.has("hanseong"), "selected city HUD binding")
	controller.set_hud_visible(false)
	_expect(not (nodes.left_world_status_panel as Control).visible and not panel.visible, "HUD visibility")
	_finish()


func _build_nodes(panel: Control) -> Dictionary:
	var content := VBoxContainer.new()
	root.add_child(content)
	var result := {
		"left_world_status_panel": content,
		"city_info_panel": panel,
		"resource_order": ["gold"],
		"resource_labels": {"gold": "금전"},
		"tax_slider": HSlider.new(),
		"turn_end": Button.new(), "save": Button.new(), "load": Button.new(), "reset": Button.new(),
		"power_bar": ProgressBar.new(), "tax_bar": ProgressBar.new(), "security_bar": ProgressBar.new(),
	}
	for key in ["tax_slider", "turn_end", "save", "load", "reset", "power_bar", "tax_bar", "security_bar"]:
		content.add_child(result[key])
	for key in ["eyebrow", "turn", "calendar", "nation", "power", "tax", "security", "chancellor", "chancellor_portrait", "chancellor_name", "chancellor_stats", "chancellor_policy_description", "resource", "supply", "military_logistics", "external_trade", "world_status_hint", "save_management_title", "save_management_status"]:
		var label := Label.new()
		content.add_child(label)
		result[key] = label
	return result


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("[WORLDMAP_HUD_CONTROLLER_FAIL] %s" % label)


func _finish() -> void:
	print("[WORLDMAP_HUD_CONTROLLER] %s: %d checks, %d failures" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	for child in root.get_children():
		child.queue_free()
	await process_frame
	quit(0 if _failures == 0 else 1)
