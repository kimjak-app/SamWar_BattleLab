extends Control

const WORLD_MAP_SCENE := "res://WorldMap.tscn"

@onready var continue_button: Button = $Panel/Margin/VBox/ContinueButton
@onready var status_label: Label = $Panel/Margin/VBox/StatusLabel

func _get_game_session() -> Node:
	return get_node_or_null("/root/GameSession")

func _ready() -> void:
	continue_button.disabled = not _get_game_session().has_valid_save()
	if continue_button.disabled:
		status_label.text = "저장 데이터가 없습니다. 새 게임에서 시작 세력을 선택하세요."

func _start(faction_id: String) -> void:
	if _get_game_session().request_new_game(faction_id):
		get_tree().change_scene_to_file(WORLD_MAP_SCENE)

func _on_hanseong_pressed() -> void:
	_start("player")
func _on_pyongyang_pressed() -> void:
	_start("goguryeo")
func _on_gyeongju_pressed() -> void:
	_start("silla")
func _on_sabi_pressed() -> void:
	_start("baekje_faction")
func _on_continue_pressed() -> void:
	_get_game_session().request_load()
	get_tree().change_scene_to_file(WORLD_MAP_SCENE)
