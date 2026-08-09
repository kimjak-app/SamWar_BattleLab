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


func _ready() -> void:
	_apply_mock_values()


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
