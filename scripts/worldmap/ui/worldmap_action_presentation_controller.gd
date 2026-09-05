extends CanvasLayer

const ACTION_VIDEO_DURATION_SEC := 6.08
const VIDEO_PATHS := {
	"spy": "res://assets/ui/worldmap/videos/actions/worldmap_action_spy.ogv",
	"trade": "res://assets/ui/worldmap/videos/actions/worldmap_action_trade.ogv",
	"diplomacy:korean_peninsula": "res://assets/ui/worldmap/videos/actions/worldmap_action_diplomacy_korean_peninsula.ogv",
	"diplomacy:china_mainland": "res://assets/ui/worldmap/videos/actions/worldmap_action_diplomacy_china_mainland.ogv",
	"diplomacy:japan_archipelago": "res://assets/ui/worldmap/videos/actions/worldmap_action_diplomacy_japan_archipelago.ogv",
}
const KOREAN_FACTIONS := ["player", "goguryeo", "silla", "baekje_faction", "goryeo", "joseon", "balhae"]
const CHINA_FACTIONS := ["china", "han", "chu", "wei", "shu", "wu", "qin", "jin", "sui", "tang", "song", "yuan", "ming", "qing"]
const JAPAN_FACTIONS := ["japan", "yamato", "wa", "toyotomi", "tokugawa", "kyushu_faction", "heian", "kamakura", "muromachi", "edo"]
const NORTHERN_FACTIONS := ["mongol", "mongol_faction", "khitan", "qidan", "mohe", "malgal", "jurchen", "yeojin", "xianbei", "turk"]
const RESOURCE_LABELS := {"gold": "금전", "rice": "쌀", "barley": "보리", "seafood": "수산물", "salt": "소금", "silk": "비단", "food": "식량"}

@export var production_world_map_path := NodePath("../ProductionWorldMap")
@export var city_action_controller_path := NodePath("../CityActionTestController")
@export var worldmap_action_video_audio_enabled := true

@onready var production_world_map: Node = get_node_or_null(production_world_map_path)
@onready var city_action_controller: Node = get_node_or_null(city_action_controller_path)
@onready var _video_overlay: Control = $VideoOverlay
@onready var _cutin: Node = $VideoOverlay/HeroCutinViewport/HeroCutinPresentation
@onready var _result_overlay: Control = $ResultOverlay
@onready var _result_title_label: Label = $ResultOverlay/Center/ActionResultScroll/Content/Body/Title
@onready var _result_body_label: Label = $ResultOverlay/Center/ActionResultScroll/Content/Body/ResultBody

var _pending_action_type := ""
var _pending_action_id := ""
var _pending_target_city_id := ""
var _finishing_video := false


func _ready() -> void:
	_video_overlay.visible = false
	_result_overlay.visible = false
	_cutin.full_video_duration = ACTION_VIDEO_DURATION_SEC
	_cutin.cutin_finished.connect(_finish_pending_video)
	_connect_action_sources()


func _connect_action_sources() -> void:
	if production_world_map == null:
		push_warning("WorldMap action presentation: ProductionWorldMap is missing.")
		return
	var request_callback := Callable(self, "_on_action_presentation_requested")
	if production_world_map.has_signal("contextual_worldmap_action_presentation_requested") and not production_world_map.is_connected("contextual_worldmap_action_presentation_requested", request_callback):
		production_world_map.connect("contextual_worldmap_action_presentation_requested", request_callback)
	var resolved_callback := Callable(self, "_on_action_resolved")
	if production_world_map.has_signal("contextual_worldmap_action_resolved") and not production_world_map.is_connected("contextual_worldmap_action_resolved", resolved_callback):
		production_world_map.connect("contextual_worldmap_action_resolved", resolved_callback)
	if city_action_controller != null:
		var open_failed_callback := Callable(self, "_on_action_open_failed")
		if city_action_controller.has_signal("contextual_action_open_failed") and not city_action_controller.is_connected("contextual_action_open_failed", open_failed_callback):
			city_action_controller.connect("contextual_action_open_failed", open_failed_callback)


func set_worldmap_action_video_audio_enabled(enabled: bool) -> void:
	worldmap_action_video_audio_enabled = enabled
	_cutin.video.volume_db = 0.0 if enabled else -80.0


func _unhandled_input(event: InputEvent) -> void:
	if _video_overlay.visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_finish_pending_video()
	elif _result_overlay.visible and (event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel")):
		get_viewport().set_input_as_handled()
		_hide_result()


func _on_action_presentation_requested(action_type: String, action_id: String, target_city_id: String) -> void:
	_pending_action_type = action_type
	_pending_action_id = action_id
	_pending_target_city_id = target_city_id
	var video_path := _get_action_video_path(action_type)
	if video_path.is_empty() or not ResourceLoader.exists(video_path):
		_finish_pending_video()
		return
	var stream := load(video_path) as VideoStream
	if stream == null:
		_finish_pending_video()
		return
	_result_overlay.visible = false
	_video_overlay.visible = true
	_cutin.configure("", "", stream, null)
	_cutin.video.volume_db = 0.0 if worldmap_action_video_audio_enabled else -80.0
	_cutin.play_cutin(false)


func _finish_pending_video() -> void:
	if _finishing_video or _pending_action_type.is_empty():
		return
	_finishing_video = true
	_cutin.stop_cutin()
	_video_overlay.visible = false
	var action_type := _pending_action_type
	var action_id := _pending_action_id
	var target_city_id := _pending_target_city_id
	_pending_action_type = ""
	_pending_action_id = ""
	_pending_target_city_id = ""
	if production_world_map != null and production_world_map.has_method("complete_contextual_worldmap_action"):
		production_world_map.call("complete_contextual_worldmap_action", action_type, action_id, target_city_id)
	_finishing_video = false


func _on_action_resolved(action_type: String, result: Dictionary) -> void:
	_show_result(action_type, result)


func _on_action_open_failed(action_type: String, result: Dictionary) -> void:
	_show_result(action_type, result)


func _show_result(action_type: String, result: Dictionary) -> void:
	_result_title_label.text = _format_result_title(action_type, result)
	_result_body_label.text = _format_result_body(action_type, result)
	_result_overlay.visible = true


func _hide_result() -> void:
	_result_overlay.visible = false


func _get_action_video_path(action_type: String) -> String:
	if action_type != "diplomacy":
		return str(VIDEO_PATHS.get(action_type, ""))
	return str(VIDEO_PATHS.get("diplomacy:%s" % _get_player_culture_id(), ""))


func _get_player_culture_id() -> String:
	var faction_id := "player"
	var session := get_node_or_null("/root/GameSession")
	if session != null:
		var faction_value: Variant = session.get("player_faction_id")
		if faction_value != null and not str(faction_value).is_empty():
			faction_id = str(faction_value).to_lower()
	if KOREAN_FACTIONS.has(faction_id):
		return "korean_peninsula"
	if CHINA_FACTIONS.has(faction_id):
		return "china_mainland"
	if JAPAN_FACTIONS.has(faction_id):
		return "japan_archipelago"
	if NORTHERN_FACTIONS.has(faction_id):
		return "northern_peoples"
	return "northern_peoples"


func _format_result_title(action_type: String, result: Dictionary) -> String:
	var category_label := str({"diplomacy": "외교", "spy": "첩보", "trade": "무역"}.get(action_type, "도시 행동"))
	var action_label := str(result.get("action_label", ""))
	return "%s 결과%s" % [category_label, " · %s" % action_label if not action_label.is_empty() else ""]


func _format_result_body(action_type: String, result: Dictionary) -> String:
	var succeeded := bool(result.get("ok", result.get("success", false)))
	var lines: Array[String] = ["판정: %s" % ("성공" if succeeded else "실패")]
	var target_city_id := str(result.get("target_city_id", ""))
	if not target_city_id.is_empty():
		lines.append("대상: %s" % target_city_id)
	var message := str(result.get("message", "처리 결과를 확인했습니다."))
	if not message.is_empty():
		lines.append(message)
	if action_type == "diplomacy" and result.has("before_score"):
		lines.append("관계: %d → %d" % [int(result.get("before_score", 0)), int(result.get("after_score", result.get("before_score", 0)))])
	elif action_type == "spy":
		if bool(result.get("detected", false)):
			lines.append("발각됨 · 관계 %d" % int(result.get("relation_penalty", 0)))
		elif result.has("success_chance"):
			lines.append("성공 확률 %d%% · 주사위 %d" % [int(result.get("success_chance", 0)), int(result.get("roll", 0))])
	elif action_type == "trade" and result.get("applied", {}) is Dictionary:
		var trade_changes := _format_resource_changes(result.get("applied", {}))
		if not trade_changes.is_empty():
			lines.append("정산: %s" % trade_changes)
	if result.has("cost") and result.get("cost", {}) is Dictionary:
		var cost_text := _format_resource_cost(result.get("cost", {}))
		if not cost_text.is_empty():
			lines.append("소모: %s" % cost_text)
	if int(result.get("cooldown", 0)) > 0:
		lines.append("재사용 대기: %d턴" % int(result.get("cooldown", 0)))
	return "\n".join(lines.slice(0, 6))


func _format_resource_cost(cost: Dictionary) -> String:
	var parts: Array[String] = []
	for resource_id_variant in cost.keys():
		var resource_id := str(resource_id_variant)
		var amount := int(cost.get(resource_id_variant, 0))
		if amount > 0:
			parts.append("%s %d" % [str(RESOURCE_LABELS.get(resource_id, resource_id)), amount])
	return " / ".join(parts)


func _format_resource_changes(changes: Dictionary) -> String:
	var parts: Array[String] = []
	for resource_id in ["gold", "rice", "barley", "seafood", "salt", "silk"]:
		var amount := int(changes.get(resource_id, 0))
		if amount != 0:
			parts.append("%s %s%d" % [str(RESOURCE_LABELS.get(resource_id, resource_id)), "+" if amount > 0 else "", amount])
	return " / ".join(parts)
