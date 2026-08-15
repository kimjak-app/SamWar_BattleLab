extends Control

## TEST-ONLY MOCK DATA, 실제 게임 데이터 아님.
## This script is intentionally isolated from BattleSupplyRuntime and WorldMap data.

@export_category("Mock sample values")
@export var ally_food := 820
@export var ally_salt := 120
@export var ally_consumption := 34
@export var ally_sustain_turns := 24
@export var enemy_food := 740
@export var enemy_salt := 80
@export var enemy_consumption := 31
@export var enemy_sustain_turns := 23

@export_category("Layout QA")
@export var use_max_value_test := false

const MAX_FOOD := 99999
const MAX_SALT := 99999
const MAX_CONSUMPTION := 9999
const MAX_SUSTAIN_TURNS := 999
const TEST_BATTLE_CONTEXT_TITLE := "낙양 침공 중"
const SUPPLY_ROW_NAMES := [
	"AllyFoodRow",
	"AllySaltRow",
	"AllyConsumeRow",
	"AllySustainRow",
	"EnemyFoodRow",
	"EnemySaltRow",
	"EnemyConsumeRow",
	"EnemySustainRow",
]


func _ready() -> void:
	_apply_test_battle_context_title()
	_apply_title_font_to_row_labels()
	_apply_mock_values()


func _process(_delta: float) -> void:
	# Production HUD hides the legacy TopBar at runtime. For this test-only
	# presentation keep only the battle-context title visible so the 2D-editor
	# placement of TopBarLabel is preserved in F6 as well.
	_apply_test_battle_context_title()


func _apply_test_battle_context_title() -> void:
	var scene_root := get_tree().current_scene
	if scene_root == null:
		return
	var top_bar := scene_root.get_node_or_null("BattleUI/TopBar") as Control
	if top_bar != null:
		top_bar.visible = true
		top_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var context_label := scene_root.get_node_or_null("BattleUI/TopBar/TopBarLabel") as Label
	if context_label != null:
		context_label.visible = true
		context_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		context_label.text = TEST_BATTLE_CONTEXT_TITLE
	var legacy_turn_banner := scene_root.get_node_or_null("BattleUI/TopBar/TurnBanner") as Label
	if legacy_turn_banner != null:
		legacy_turn_banner.visible = false


func _apply_title_font_to_row_labels() -> void:
	var title_label := get_node_or_null("TitleLabel") as Label
	if title_label == null:
		return
	var title_font := title_label.get_theme_font("font")
	if title_font == null:
		return
	for row_name in SUPPLY_ROW_NAMES:
		var row_label := get_node_or_null("%s/Label" % row_name) as Label
		if row_label != null:
			row_label.add_theme_font_override("font", title_font)


func _apply_mock_values() -> void:
	_set_row_value("AllyFoodRow", _food_value(ally_food))
	_set_row_value("AllySaltRow", _salt_value(ally_salt))
	_set_row_value("AllyConsumeRow", _consumption_value(ally_consumption))
	_set_row_value("AllySustainRow", _sustain_value(ally_sustain_turns))
	_set_row_value("EnemyFoodRow", _food_value(enemy_food))
	_set_row_value("EnemySaltRow", _salt_value(enemy_salt))
	_set_row_value("EnemyConsumeRow", _consumption_value(enemy_consumption))
	_set_row_value("EnemySustainRow", _sustain_value(enemy_sustain_turns))


func _set_row_value(row_name: String, value: String) -> void:
	var value_label := get_node_or_null("%s/Value" % row_name) as Label
	if value_label != null:
		value_label.text = value


func _food_value(sample: int) -> String:
	return str(MAX_FOOD if use_max_value_test else sample)


func _salt_value(sample: int) -> String:
	return str(MAX_SALT if use_max_value_test else sample)


func _consumption_value(sample: int) -> String:
	return str(MAX_CONSUMPTION if use_max_value_test else sample)


func _sustain_value(sample: int) -> String:
	return "%d턴" % (MAX_SUSTAIN_TURNS if use_max_value_test else sample)
