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
		_expect(_title_typography_matches(battle, hud), "supply title typography matches BattleLog title")
		_expect(_title_fits(hud), "supply title fits its authored rect")
		_expect(_icon_contract_is_valid(hud), "eight real supply icons replace every placeholder")
		_expect(hud.size == Vector2(290, 220), "framed HUD rect is 290 x 220")
		_expect(_frame_contract_is_valid(hud), "SupplyFrameBg fills HUD and renders behind content")
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


func _frame_contract_is_valid(hud: Control) -> bool:
	var frame := hud.get_node_or_null("SupplyFrameBg") as TextureRect
	if frame == null or frame.texture == null:
		return false
	if frame.position != Vector2.ZERO or frame.size != Vector2(290, 220):
		return false
	if frame.z_index >= 0 or frame.get_index() != 0:
		return false
	return true


func _title_typography_matches(battle: Node, hud: Control) -> bool:
	var log_title := battle.get_node_or_null("BattleUI/ProductionHudRoot/BattleLogHud/TitleLabel") as Label
	var supply_title := hud.get_node_or_null("TitleLabel") as Label
	if log_title == null or supply_title == null:
		return false
	if log_title.get_theme_font("font") != supply_title.get_theme_font("font"):
		return false
	if log_title.get_theme_font_size("font_size") != supply_title.get_theme_font_size("font_size"):
		return false
	for color_name in ["font_color", "font_outline_color", "font_shadow_color"]:
		if log_title.get_theme_color(color_name) != supply_title.get_theme_color(color_name):
			return false
	for constant_name in ["outline_size", "shadow_outline_size", "shadow_offset_x", "shadow_offset_y"]:
		if log_title.get_theme_constant(constant_name) != supply_title.get_theme_constant(constant_name):
			return false
	return log_title.horizontal_alignment == supply_title.horizontal_alignment and log_title.vertical_alignment == supply_title.vertical_alignment


func _title_fits(hud: Control) -> bool:
	var title := hud.get_node_or_null("TitleLabel") as Label
	if title == null:
		return false
	var font := title.get_theme_font("font")
	if font == null:
		return false
	var font_size := title.get_theme_font_size("font_size")
	return font.get_string_size(title.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x <= title.size.x and font.get_height(font_size) <= title.size.y


func _icon_contract_is_valid(hud: Control) -> bool:
	var expected_paths := {
		"AllyFoodRow": "res://assets/ui/battle/production_hud/battle_supply/icons/supply_icon_food.png",
		"EnemyFoodRow": "res://assets/ui/battle/production_hud/battle_supply/icons/supply_icon_food.png",
		"AllySaltRow": "res://assets/ui/battle/production_hud/battle_supply/icons/supply_icon_salt.png",
		"EnemySaltRow": "res://assets/ui/battle/production_hud/battle_supply/icons/supply_icon_salt.png",
		"AllyConsumeRow": "res://assets/ui/battle/production_hud/battle_supply/icons/supply_icon_consume.png",
		"EnemyConsumeRow": "res://assets/ui/battle/production_hud/battle_supply/icons/supply_icon_consume.png",
		"AllySustainRow": "res://assets/ui/battle/production_hud/battle_supply/icons/supply_icon_sustain.png",
		"EnemySustainRow": "res://assets/ui/battle/production_hud/battle_supply/icons/supply_icon_sustain.png",
	}
	for row_name in expected_paths:
		var icon := hud.get_node_or_null("%s/Icon" % row_name) as TextureRect
		if icon == null or icon.texture == null:
			return false
		if icon.texture.resource_path != expected_paths[row_name]:
			return false
		if icon.position != Vector2(0, 2) or icon.size != Vector2(24, 24):
			return false
		if icon.mouse_filter != Control.MOUSE_FILTER_IGNORE or icon.expand_mode != TextureRect.EXPAND_IGNORE_SIZE:
			return false
		if icon.stretch_mode != TextureRect.STRETCH_KEEP_ASPECT_CENTERED:
			return false
	return true


func _expect(condition: bool, label: String) -> void:
	if condition:
		print("[BATTLE_SUPPLY_HUD_MOCK_QA] PASS %s" % label)
		return
	_failures += 1
	push_error("[BATTLE_SUPPLY_HUD_MOCK_QA] FAIL %s" % label)
