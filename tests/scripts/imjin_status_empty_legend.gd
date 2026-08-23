extends Node

## Test2-only empty-state legend for the Current Actor status panel.
## The inherited Production HUD remains authoritative for real status rows.
## This helper only fills the otherwise-empty panel and disappears as soon as
## at least one displayable runtime status exists.

const LEGEND_NODE_NAME := "Test2EmptyStatusLegend"
const LEGEND_FONT_SIZE := 14
const LEGEND_TEXT_COLOR := Color(0.82, 0.80, 0.73, 0.78)
const LEGEND_ITEMS := [
	{"text": "▲▼ 공격", "position": Vector2(12.0, 44.0), "tooltip": "▲ 공격 상승 / ▼ 공격 저하"},
	{"text": "◆ 방어", "position": Vector2(12.0, 76.0), "tooltip": "방어 상승·피해 감소 계열"},
	{"text": "↑↓ 이동", "position": Vector2(12.0, 108.0), "tooltip": "↑ 이동 상승 / ↓ 이동 저하"},
	{"text": "⊘ 행동불가", "position": Vector2(12.0, 140.0), "tooltip": "행동 봉쇄·행동불가 계열"},
	{"text": "◎ 혼란", "position": Vector2(110.0, 44.0), "tooltip": "혼란 · 행동 제어 이상"},
	{"text": "⚠ 동요", "position": Vector2(110.0, 76.0), "tooltip": "동요 · 전투 능력 저하"},
	{"text": "※ 화상", "position": Vector2(110.0, 108.0), "tooltip": "화상 · 지속 피해"},
]

var _legend_root: Control = null


func _ready() -> void:
	# Run after the inherited bottom-HUD bridge (default priority 0), so its
	# authoritative real-status visibility is settled before this empty overlay.
	process_priority = 100
	_ensure_legend()
	_sync_legend_visibility()


func _process(_delta: float) -> void:
	_ensure_legend()
	_sync_legend_visibility()


func _ensure_legend() -> void:
	if is_instance_valid(_legend_root):
		return
	var status_area := _get_status_area()
	if status_area == null:
		return
	var existing := status_area.get_node_or_null(LEGEND_NODE_NAME) as Control
	if existing != null:
		_legend_root = existing
		return

	var root := Control.new()
	root.name = LEGEND_NODE_NAME
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.position = Vector2.ZERO
	root.size = status_area.size
	root.z_index = 2
	status_area.add_child(root)
	_legend_root = root

	for index in range(LEGEND_ITEMS.size()):
		var item: Dictionary = LEGEND_ITEMS[index]
		var label := Label.new()
		label.name = "LegendItem%02d" % (index + 1)
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.position = item.get("position", Vector2.ZERO)
		label.size = Vector2(96.0, 28.0)
		label.text = String(item.get("text", ""))
		label.tooltip_text = String(item.get("tooltip", label.text))
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.theme_type_variation = &"ProductionCurrentActionDetail"
		label.add_theme_font_size_override("font_size", LEGEND_FONT_SIZE)
		label.add_theme_color_override("font_color", LEGEND_TEXT_COLOR)
		root.add_child(label)


func _sync_legend_visibility() -> void:
	if not is_instance_valid(_legend_root):
		return
	_legend_root.visible = not _has_displayable_runtime_status()


func _has_displayable_runtime_status() -> bool:
	var controller := get_parent()
	if controller == null or not controller.has_method("_get_unit_status_display_entries"):
		return false
	var unit: Variant = controller.get("active_unit_state")
	if unit == null:
		return false
	var raw_entries: Variant = controller.call("_get_unit_status_display_entries", unit)
	if not raw_entries is Array:
		return false
	for raw_entry in raw_entries:
		if not raw_entry is Dictionary:
			continue
		var entry: Dictionary = raw_entry
		var summary := String(entry.get("summary", entry.get("label", "")))
		# Wounded information is intentionally hidden by the inherited Current
		# Actor HUD, so it must not suppress this empty-state legend either.
		if summary.contains("부상"):
			continue
		return true
	return false


func _get_status_area() -> Control:
	var controller := get_parent()
	if controller == null:
		return null
	return controller.get_node_or_null(
		"BattleUI/ProductionHudRoot/CurrentActorInfoHud/StatusArea"
	) as Control
