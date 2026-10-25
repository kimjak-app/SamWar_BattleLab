extends CanvasLayer
# HUD block 4-1: the 2D current-actor panel (scenes/battle/ui/CurrentActorInfoHud.tscn,
# instanced unchanged, like the 2D bridge does) as a 2D overlay above the 3D
# battlefield. The layout the 2D bridge applies at run time is ported here
# without engine access: battle_current_actor_hud_controller.gd
# _apply_current_actor_polish (area and label offsets, StatusTitleIcon, the
# Bound* icon TextureRects, typography), the ready badge and the terrain text,
# plus battle_status_empty_legend_controller.gd (ProductionEmptyStatusLegend).
# It shows the actor values handed to it by the scenario shell (show_actor) and
# reads nothing from the engine. Every node ignores the mouse.
const UNIQUE_SKILL_READY_BADGE := preload("res://assets/web_battle/ui/formation_guide/unique_skill_ready_icon.png")
const ICON_STAT_COMMAND := preload("res://assets/ui/battle/current_actor_icons/stat_command.png")
const ICON_STAT_MIGHT := preload("res://assets/ui/battle/current_actor_icons/stat_might.png")
const ICON_STAT_INTELLECT := preload("res://assets/ui/battle/current_actor_icons/stat_intellect.png")
const ICON_UNIQUE_SKILL := preload("res://assets/ui/battle/current_actor_icons/unique_skill.png")
const ICON_STATUS_HEADER := preload("res://assets/ui/battle/current_actor_icons/status_header.png")
const ICON_TERRAIN_PLAIN := preload("res://assets/ui/battle/current_actor_icons/terrain_plain.png")
# The 2D default battlefield terrain text (the lab has no world-map context).
const TERRAIN_NAME := "평지"
const TERRAIN_DEFENSE := "방어 0%"
const TERRAIN_MOVE := "이동 0%"
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
var hud: Control
var badge: TextureRect
var legend: Control
var shown: Dictionary = {"_": true} # last applied actor values; the nodes change only when these change
var apply_count := 0

func _ready() -> void:
	hud = get_node("ProductionHudRoot/CurrentActorInfoHud")
	_apply_polish()
	_ensure_status_title_icon()
	_sync_static_icons()
	_apply_typography()
	_ensure_badge()
	_ensure_legend()
	_set_terrain()
	_ignore_mouse(get_node("ProductionHudRoot"))
	show_actor({})

func _ignore_mouse(node: Node) -> void:
	if node is Control: (node as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in node.get_children(): _ignore_mouse(child)

func panel_rect() -> Rect2:
	return hud.get_global_rect()

func show_actor(actor: Dictionary) -> void:
	# {} = no active unit (the 2D "대기"/"-" texts). Otherwise: name, type_name,
	# troops_text, stats ([지휘, 무력, 지력] numbers or "-"), skill_name,
	# skill_description, portrait, troop_icon, ready, status_rows ([{summary, tooltip}]).
	if actor == shown: return
	shown = actor.duplicate(true)
	apply_count += 1
	var empty := actor.is_empty()
	var stats: Array = actor.get("stats", ["-", "-", "-"])
	_text("InfoArea/NameLabel", "대기" if empty else str(actor.get("name", "")))
	_text("InfoArea/TroopClassLabel", "-" if empty else str(actor.get("type_name", "")))
	_text("InfoArea/TroopRow/TroopsLabel", "병력 - / -" if empty else str(actor.get("troops_text", "")))
	_visible("InfoArea/TroopRow/WoundedLabel", false)
	_text("InfoArea/StatsRow/CommandStat/Value", "지휘 %s" % str(stats[0]))
	_text("InfoArea/StatsRow/MightStat/Value", "무력 %s" % str(stats[1]))
	_text("InfoArea/StatsRow/IntellectStat/Value", "지력 %s" % str(stats[2]))
	var skill_name := "고유특기 -" if empty else str(actor.get("skill_name", ""))
	var skill_description := "" if empty else str(actor.get("skill_description", ""))
	_text("InfoArea/UniqueTraitArea/UniqueTraitLabel", skill_name)
	_text("InfoArea/UniqueTraitArea/UniqueTraitSummaryLabel", skill_description)
	(hud.get_node("InfoArea/UniqueTraitArea") as Control).tooltip_text = "" if empty else ("%s · %s" % [skill_name, skill_description] if not skill_description.is_empty() else skill_name)
	var portrait: Texture2D = actor.get("portrait")
	_bound("PortraitSlot", portrait, "BoundPortrait", TextureRect.STRETCH_KEEP_ASPECT_COVERED, true)
	_visible("PortraitSlot/PlaceholderLabel", portrait == null)
	_bound("InfoArea/TroopRow/TroopTypeIconSlot", actor.get("troop_icon"), "BoundTroopTypeIcon")
	badge.visible = bool(actor.get("ready", false))
	var rows: Array = actor.get("status_rows", [])
	for index in range(5):
		var row_path := "StatusArea/StatusRow%02d" % (index + 1)
		_visible(row_path, index < rows.size())
		if index >= rows.size(): continue
		_text(row_path + "/Label", str(rows[index].get("summary", "")))
		_visible(row_path + "/Icon", false)
		(hud.get_node(row_path) as Control).tooltip_text = str(rows[index].get("tooltip", ""))
	legend.visible = rows.is_empty() # the 2D legend: shown while no displayable status (부상 excluded)

func _process(_delta: float) -> void:
	# The 2D badge pulse (refreshed every frame while shown).
	if badge.visible: badge.modulate = Color(1.0, 1.0, 1.0, 0.88 + 0.12 * sin(float(Time.get_ticks_msec()) / 220.0))

func _apply_polish() -> void:
	# battle_current_actor_hud_controller.gd _apply_current_actor_polish
	(hud.get_node("PortraitSlot") as Control).clip_contents = true
	(hud.get_node("InfoArea") as Control).offset_right = 638.0
	var status_area := hud.get_node("StatusArea") as Control
	status_area.offset_left = 650.0
	status_area.offset_right = 870.0
	var terrain_area := hud.get_node("TerrainArea") as Control
	terrain_area.offset_left = 882.0
	terrain_area.offset_right = 1000.0
	_offsets("InfoArea/NameLabel", 12.0, 6.0, 198.0, 38.0)
	_offsets("InfoArea/TroopClassLabel", 206.0, 10.0, 300.0, 36.0)
	_offsets("InfoArea/StatsRow", 214.0, 42.0, 432.0, 124.0)
	_offsets("InfoArea/UniqueTraitArea", 12.0, 126.0, 432.0, 190.0)
	_offsets("InfoArea/UniqueTraitArea/UniqueTraitLabel", 50.0, 0.0, 412.0, 24.0)
	_offsets("InfoArea/UniqueTraitArea/UniqueTraitSummaryLabel", 50.0, 24.0, 412.0, 54.0)
	var skill_summary := hud.get_node("InfoArea/UniqueTraitArea/UniqueTraitSummaryLabel") as Label
	skill_summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	skill_summary.add_theme_font_size_override("font_size", 13)
	_offsets("StatusArea/TitleLabel", 42.0, 6.0, 208.0, 34.0)
	for index in range(1, 6):
		var row_path := "StatusArea/StatusRow%02d" % index
		(hud.get_node(row_path) as Control).offset_right = 208.0
		var row_label := hud.get_node(row_path + "/Label") as Label
		row_label.offset_left = 12.0
		row_label.offset_right = 196.0
		_visible(row_path + "/Icon", false)
	_offsets("TerrainArea/TerrainImageSlot", 8.0, 8.0, 110.0, 110.0)
	_offsets("TerrainArea/TerrainNameLabel", 8.0, 116.0, 110.0, 142.0)
	_offsets("TerrainArea/TerrainEffectLabel", 8.0, 144.0, 110.0, 192.0)
	(hud.get_node("TerrainArea/TerrainEffectLabel") as Label).autowrap_mode = TextServer.AUTOWRAP_OFF

func _ensure_status_title_icon() -> void:
	# battle_current_actor_hud_controller.gd _ensure_status_title_icon
	var icon := Panel.new()
	icon.name = "StatusTitleIcon"
	hud.get_node("StatusArea").add_child(icon)
	icon.position = Vector2(12.0, 8.0)
	icon.size = Vector2(24.0, 24.0)
	var sample_style := (hud.get_node("StatusArea/StatusRow01/Icon") as Panel).get_theme_stylebox("panel")
	if sample_style != null: icon.add_theme_stylebox_override("panel", sample_style)

func _sync_static_icons() -> void:
	_bound("InfoArea/StatsRow/CommandStat/Icon", ICON_STAT_COMMAND, "BoundCommandIcon")
	_bound("InfoArea/StatsRow/MightStat/Icon", ICON_STAT_MIGHT, "BoundMightIcon")
	_bound("InfoArea/StatsRow/IntellectStat/Icon", ICON_STAT_INTELLECT, "BoundIntellectIcon")
	_bound("InfoArea/UniqueTraitArea/UniqueTraitIconSlot", ICON_UNIQUE_SKILL, "BoundUniqueTraitIcon")
	_bound("StatusArea/StatusTitleIcon", ICON_STATUS_HEADER, "BoundStatusHeaderIcon")
	_bound("TerrainArea/TerrainImageSlot", ICON_TERRAIN_PLAIN, "BoundTerrainIcon", TextureRect.STRETCH_KEEP_ASPECT_COVERED, true)
	_visible("TerrainArea/TerrainImageSlot/PlaceholderLabel", false)

func _apply_typography() -> void:
	for path in ["InfoArea/NameLabel"]:
		(hud.get_node(path) as Control).theme_type_variation = &"ProductionCurrentActionHero"
	for path in ["InfoArea/TroopClassLabel", "InfoArea/UniqueTraitArea/UniqueTraitLabel", "StatusArea/TitleLabel", "TerrainArea/TerrainNameLabel"]:
		(hud.get_node(path) as Control).theme_type_variation = &"ProductionCurrentActionTitle"
	for path in ["InfoArea/TroopRow/TroopsLabel", "InfoArea/StatsRow/CommandStat/Value", "InfoArea/StatsRow/MightStat/Value", "InfoArea/StatsRow/IntellectStat/Value",
			"InfoArea/UniqueTraitArea/UniqueTraitSummaryLabel", "TerrainArea/TerrainEffectLabel"]:
		(hud.get_node(path) as Control).theme_type_variation = &"ProductionCurrentActionDetail"
	for index in range(1, 6):
		(hud.get_node("StatusArea/StatusRow%02d/Label" % index) as Control).theme_type_variation = &"ProductionCurrentActionDetail"

func _ensure_badge() -> void:
	# battle_current_actor_hud_controller.gd _sync_unique_skill_ready_badge
	badge = TextureRect.new()
	badge.name = "BoundUniqueSkillReadyBadge"
	badge.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	badge.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	badge.z_index = 10
	badge.tooltip_text = "고유특기 사용 가능"
	hud.add_child(badge)
	badge.position = Vector2(122.0, -18.0)
	badge.size = Vector2(84.0, 84.0)
	badge.texture = UNIQUE_SKILL_READY_BADGE
	badge.visible = false

func _ensure_legend() -> void:
	# battle_status_empty_legend_controller.gd _ensure_legend
	var status_area := hud.get_node("StatusArea") as Control
	legend = Control.new()
	legend.name = "ProductionEmptyStatusLegend"
	legend.position = Vector2.ZERO
	legend.size = status_area.size
	legend.z_index = 2
	status_area.add_child(legend)
	for index in range(LEGEND_ITEMS.size()):
		var item: Dictionary = LEGEND_ITEMS[index]
		var label := Label.new()
		label.name = "LegendItem%02d" % (index + 1)
		label.position = item.position
		label.size = Vector2(96.0, 28.0)
		label.text = item.text
		label.tooltip_text = item.tooltip
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.theme_type_variation = &"ProductionCurrentActionDetail"
		label.add_theme_font_size_override("font_size", LEGEND_FONT_SIZE)
		label.add_theme_color_override("font_color", LEGEND_TEXT_COLOR)
		legend.add_child(label)

func _set_terrain() -> void:
	# battle_current_actor_hud_controller.gd _sync_terrain with no world-map context.
	_text("TerrainArea/TerrainNameLabel", TERRAIN_NAME)
	_text("TerrainArea/TerrainImageSlot/PlaceholderLabel", TERRAIN_NAME)
	_text("TerrainArea/TerrainEffectLabel", "%s\n%s" % [TERRAIN_DEFENSE, TERRAIN_MOVE])
	_visible("TerrainArea/TerrainEffectLabel", true)
	_visible("TerrainArea/TerrainImageSlot/PlaceholderLabel", false)

func _bound(slot_path: String, texture: Texture2D, node_name: String, stretch_mode: int = TextureRect.STRETCH_KEEP_ASPECT_CENTERED, clip_to_slot: bool = false) -> void:
	# battle_current_actor_hud_controller.gd _sync_bound_texture
	var slot := hud.get_node(slot_path) as Control
	slot.clip_contents = clip_to_slot
	var rect := slot.get_node_or_null(node_name) as TextureRect
	if rect == null:
		rect = TextureRect.new()
		rect.name = node_name
		rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(rect)
		rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rect.stretch_mode = stretch_mode as TextureRect.StretchMode
	rect.texture = texture
	rect.visible = texture != null

func _offsets(path: String, left: float, top: float, right: float, bottom: float) -> void:
	var control := hud.get_node(path) as Control
	control.offset_left = left
	control.offset_top = top
	control.offset_right = right
	control.offset_bottom = bottom

func _text(path: String, value: String) -> void:
	(hud.get_node(path) as Label).text = value

func _visible(path: String, value: bool) -> void:
	(hud.get_node(path) as Control).visible = value
