extends SceneTree

const SCENE_PATH := "res://tests/scenes/Battle_UI_Production_Test.tscn"
const HUD_PATH := "BattleUI/ProductionHudRoot/BattleSupplyHud"

var _failures := 0


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed_scene := load(SCENE_PATH) as PackedScene
	_expect(packed_scene != null, "production test scene loads")
	if packed_scene == null:
		quit(1)
		return
	var battle := packed_scene.instantiate()
	root.add_child(battle)
	await process_frame
	var hud := battle.get_node_or_null(HUD_PATH) as Control
	_expect(hud != null, "BattleSupplyHud exists")
	if hud != null:
		_expect(hud.size == Vector2(270, 204), "compact HUD rect is 270 x 204")
		_expect(hud.get_node_or_null("TurnLabel") == null, "mock HUD has no duplicate TurnLabel")
		_expect(_layout_contract_is_valid(hud), "24px icons, 28px rows, and readable font contract")
		_expect(_row_value(hud, "AllyFoodRow") == "820", "sample ally food")
		_expect(_row_value(hud, "AllySustainRow") == "24턴", "sample ally sustain")
		_expect(_row_value(hud, "EnemyFoodRow") == "740", "sample enemy food")
		_expect(_row_value(hud, "EnemySustainRow") == "23턴", "sample enemy sustain")
		hud.set("use_max_value_test", true)
		hud.call("_apply_mock_values")
		_expect(_row_value(hud, "AllyFoodRow") == "99999", "max food value")
		_expect(_row_value(hud, "AllySaltRow") == "99999", "max salt value")
		_expect(_row_value(hud, "AllyConsumeRow") == "9999", "max consumption value")
		_expect(_row_value(hud, "AllySustainRow") == "999턴", "max sustain value")
		_expect(_all_max_text_fits(hud), "max values fit the fixed value columns")
	print("[BATTLE_SUPPLY_HUD_MOCK_QA] %s" % ("PASS" if _failures == 0 else "FAIL"))
	quit(0 if _failures == 0 else 1)


func _row_value(hud: Control, row_name: String) -> String:
	var label := hud.get_node_or_null("%s/Value" % row_name) as Label
	return label.text if label != null else ""


func _all_max_text_fits(hud: Control) -> bool:
	for row_name in [
		"AllyFoodRow", "AllySaltRow", "AllyConsumeRow", "AllySustainRow",
		"EnemyFoodRow", "EnemySaltRow", "EnemyConsumeRow", "EnemySustainRow",
	]:
		var label := hud.get_node_or_null("%s/Value" % row_name) as Label
		var row_label := hud.get_node_or_null("%s/Label" % row_name) as Label
		if label == null or row_label == null:
			return false
		var font := label.get_theme_font("font")
		if font == null:
			return false
		if font.get_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, label.get_theme_font_size("font_size")).x > label.size.x:
			return false
		if font.get_string_size(row_label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, row_label.get_theme_font_size("font_size")).x > row_label.size.x:
			return false
	return true


func _layout_contract_is_valid(hud: Control) -> bool:
	var headers := ["AllyHeaderLabel", "EnemyHeaderLabel"]
	for header_name in headers:
		var header := hud.get_node_or_null(header_name) as Label
		if header == null or header.get_theme_font_size("font_size") < 16:
			return false
	for row_name in [
		"AllyFoodRow", "AllySaltRow", "AllyConsumeRow", "AllySustainRow",
		"EnemyFoodRow", "EnemySaltRow", "EnemyConsumeRow", "EnemySustainRow",
	]:
		var row := hud.get_node_or_null(row_name) as Control
		var icon := hud.get_node_or_null("%s/Icon" % row_name) as Control
		var row_label := hud.get_node_or_null("%s/Label" % row_name) as Label
		var value := hud.get_node_or_null("%s/Value" % row_name) as Label
		if row == null or icon == null or row_label == null or value == null:
			return false
		if row.size.y != 28 or icon.size.x < 22 or icon.size.y < 22:
			return false
		if row_label.get_theme_font_size("font_size") < 15 or value.get_theme_font_size("font_size") < 15:
			return false
		if value.size.x != 62:
			return false
	return true


func _expect(condition: bool, label: String) -> void:
	if condition:
		print("[BATTLE_SUPPLY_HUD_MOCK_QA] PASS %s" % label)
		return
	_failures += 1
	push_error("[BATTLE_SUPPLY_HUD_MOCK_QA] FAIL %s" % label)
