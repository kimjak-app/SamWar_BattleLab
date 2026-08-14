extends Node

## Test-scene-only bottom HUD bridge.
##
## T13-4A authored the current-actor card as a standalone subscene so its
## position and child offsets remain editable in Godot 2D. T13-4B keeps those
## authored coordinates untouched and binds the card to the authoritative
## current BattleUnitState plus HeroDesignDataRegistry metadata.

const SHOW_WARNING_SAMPLE := false
const CURRENT_ACTOR_INFO_HUD_PREVIEW_SCENE := preload("res://tests/scenes/ui/current_actor_info_hud_placeholder.tscn")
const HeroDesignDataRegistryScript := preload("res://scripts/worldmap/hero_design_data_registry.gd")
const UNIQUE_TRAIT_ICON := preload("res://assets/web_battle/ui/formation_guide/unique_skill_ready_icon.png")
const TEST_BATTLEFIELD_TERRAIN_NAME := "평지"
const HERO_ID_ALIASES := {
	"yi_sunsin": "yi_sun_sin",
	"gwon_yul": "kwon_yul",
	"gim_yusin": "kim_yu_sin",
}


func _ready() -> void:
	_ensure_current_actor_info_hud_preview()
	_apply_preview()


func _process(_delta: float) -> void:
	_apply_preview()


func _ensure_current_actor_info_hud_preview() -> void:
	var controller := get_parent()
	if controller == null:
		return
	var production_root := controller.get_node_or_null("BattleUI/ProductionHudRoot") as Control
	if production_root == null:
		return
	if production_root.get_node_or_null("CurrentActorInfoHud") == null:
		var preview_hud := CURRENT_ACTOR_INFO_HUD_PREVIEW_SCENE.instantiate() as Control
		if preview_hud != null:
			production_root.add_child(preview_hud)
	_hide_legacy_actor_comparison(production_root)


func _apply_preview() -> void:
	var controller := get_parent()
	if controller == null:
		return
	var production_root := controller.get_node_or_null("BattleUI/ProductionHudRoot") as Control
	if production_root != null:
		_hide_legacy_actor_comparison(production_root)
		_sync_current_actor_info(controller, production_root)
	_set_text(controller, "BattleUI/ProductionHudRoot/InteractionGuideHud/PhaseLabel", "아군 턴")
	_set_text(controller, "BattleUI/ProductionHudRoot/InteractionGuideHud/InstructionLabel", "행동할 아군 부대를 선택하거나 명령을 선택하세요.")
	_set_text(controller, "BattleUI/ProductionHudRoot/InteractionGuideHud/DisabledReasonLabel", "")
	_set_text(controller, "BattleUI/ProductionHudRoot/BottomHudRoot/BattleSupplyPreviewPanel/Margin/Content/Header/TurnLabel", "3 / 30 · 잔여 27")
	_sync_supply_column(controller, "AllyColumn", "식량 820", "소금 120", "턴당 소비 34", "유지 24턴", SHOW_WARNING_SAMPLE)
	_sync_supply_column(controller, "EnemyColumn", "식량 740", "소금 80", "턴당 소비 31", "유지 23턴", false)


func _sync_current_actor_info(controller: Node, production_root: Control) -> void:
	var hud := production_root.get_node_or_null("CurrentActorInfoHud") as Control
	if hud == null:
		return
	var unit: Variant = controller.get("active_unit_state")
	if unit == null:
		_clear_current_actor_info(hud)
		return

	var hero_id := _resolve_hero_id(unit)
	var base_stats := HeroDesignDataRegistryScript.get_base_stats(hero_id) if not hero_id.is_empty() else {}
	var stats_variant: Variant = base_stats.get("stats", {})
	var stats: Dictionary = stats_variant if stats_variant is Dictionary else {}
	var unique_skill_variant: Variant = unit.get("unique_skill_definition")
	var unique_skill: Dictionary = unique_skill_variant if unique_skill_variant is Dictionary else {}
	if unique_skill.is_empty() and not hero_id.is_empty():
		unique_skill = HeroDesignDataRegistryScript.get_unique_skill_for_hero(hero_id)

	_set_local_text(hud, "InfoArea/NameLabel", str(unit.get("display_name")))
	var unit_type := str(unit.get("unit_type"))
	var unit_type_name := HeroDesignDataRegistryScript.get_unit_type_display_name(unit_type, _unit_type_name(unit_type))
	_set_local_text(hud, "InfoArea/TroopClassLabel", unit_type_name)
	_set_local_text(hud, "InfoArea/TroopRow/TroopsLabel", "병력 %d / %d" % [int(unit.get("current_hp")), int(unit.get("max_hp"))])
	_set_local_visibility(hud, "InfoArea/TroopRow/WoundedLabel", false)

	var leadership := int(stats.get("leadership", 0))
	var martial := int(stats.get("martial", unit.get("martial")))
	var intelligence := int(stats.get("intelligence", unit.get("intelligence")))
	_set_local_text(hud, "InfoArea/StatsRow/CommandStat/Value", "지휘 %d" % leadership)
	_set_local_text(hud, "InfoArea/StatsRow/MightStat/Value", "무력 %d" % martial)
	_set_local_text(hud, "InfoArea/StatsRow/IntellectStat/Value", "지력 %d" % intelligence)

	var skill_name := str(unique_skill.get("display_name", "고유특기"))
	var skill_description := str(unique_skill.get("description", unique_skill.get("concept", "")))
	_set_local_text(hud, "InfoArea/UniqueTraitArea/UniqueTraitLabel", skill_name)
	_set_local_text(hud, "InfoArea/UniqueTraitArea/UniqueTraitSummaryLabel", skill_description)
	var trait_area := hud.get_node_or_null("InfoArea/UniqueTraitArea") as Control
	if trait_area != null:
		trait_area.tooltip_text = "%s · %s" % [skill_name, skill_description] if not skill_description.is_empty() else skill_name
	_sync_bound_texture(hud, "InfoArea/UniqueTraitArea/UniqueTraitIconSlot", UNIQUE_TRAIT_ICON, "BoundUniqueTraitIcon")

	var portrait: Texture2D = null
	if controller.has_method("_get_closeup_portrait_texture_for_unit"):
		portrait = controller.call("_get_closeup_portrait_texture_for_unit", unit) as Texture2D
	_sync_bound_texture(hud, "PortraitSlot", portrait, "BoundPortrait")
	_set_local_visibility(hud, "PortraitSlot/PlaceholderLabel", portrait == null)

	var troop_icon: Texture2D = null
	if controller.has_method("_get_troop_icon_texture_for_visual_key"):
		troop_icon = controller.call("_get_troop_icon_texture_for_visual_key", "", unit) as Texture2D
	_sync_bound_texture(hud, "InfoArea/TroopRow/TroopTypeIconSlot", troop_icon, "BoundTroopTypeIcon")

	_sync_status_rows(controller, hud, unit)
	_sync_terrain(hud)


func _clear_current_actor_info(hud: Control) -> void:
	_set_local_text(hud, "InfoArea/NameLabel", "대기")
	_set_local_text(hud, "InfoArea/TroopClassLabel", "-")
	_set_local_text(hud, "InfoArea/TroopRow/TroopsLabel", "병력 - / -")
	_set_local_visibility(hud, "InfoArea/TroopRow/WoundedLabel", false)
	_set_local_text(hud, "InfoArea/StatsRow/CommandStat/Value", "지휘 -")
	_set_local_text(hud, "InfoArea/StatsRow/MightStat/Value", "무력 -")
	_set_local_text(hud, "InfoArea/StatsRow/IntellectStat/Value", "지력 -")
	_set_local_text(hud, "InfoArea/UniqueTraitArea/UniqueTraitLabel", "고유특기 -")
	_set_local_text(hud, "InfoArea/UniqueTraitArea/UniqueTraitSummaryLabel", "")
	_sync_bound_texture(hud, "PortraitSlot", null, "BoundPortrait")
	_sync_bound_texture(hud, "InfoArea/TroopRow/TroopTypeIconSlot", null, "BoundTroopTypeIcon")
	_set_local_visibility(hud, "PortraitSlot/PlaceholderLabel", true)
	for index in range(1, 6):
		_set_local_visibility(hud, "StatusArea/StatusRow%02d" % index, false)
	_sync_terrain(hud)


func _sync_status_rows(controller: Node, hud: Control, unit: Variant) -> void:
	var entries: Array = []
	if controller.has_method("_get_unit_status_display_entries"):
		var raw_entries: Variant = controller.call("_get_unit_status_display_entries", unit)
		if raw_entries is Array:
			for raw_entry in raw_entries:
				if not raw_entry is Dictionary:
					continue
				var entry: Dictionary = raw_entry
				var summary := str(entry.get("summary", entry.get("label", "")))
				if summary.contains("부상"):
					continue
				entries.append(entry)
	for index in range(5):
		var row_path := "StatusArea/StatusRow%02d" % (index + 1)
		var has_entry := index < entries.size()
		_set_local_visibility(hud, row_path, has_entry)
		if not has_entry:
			continue
		var entry: Dictionary = entries[index]
		var summary := str(entry.get("summary", entry.get("label", "상태")))
		var tooltip := str(entry.get("tooltip", entry.get("description", summary)))
		_set_local_text(hud, row_path + "/Label", summary)
		var row := hud.get_node_or_null(row_path) as Control
		if row != null:
			row.tooltip_text = tooltip


func _sync_terrain(hud: Control) -> void:
	# The current Production Test battlefield has no per-cell terrain contract yet.
	# Use the fixed test-battlefield terrain fixture rather than inventing actor data.
	_set_local_text(hud, "TerrainArea/TerrainNameLabel", TEST_BATTLEFIELD_TERRAIN_NAME)
	_set_local_text(hud, "TerrainArea/TerrainImageSlot/PlaceholderLabel", TEST_BATTLEFIELD_TERRAIN_NAME)
	_set_local_visibility(hud, "TerrainArea/TerrainEffectLabel", false)


func _resolve_hero_id(unit: Variant) -> String:
	var unit_id := str(unit.get("unit_id"))
	var hero_id := unit_id.trim_suffix("_battle_unit") if unit_id.ends_with("_battle_unit") else unit_id
	return str(HERO_ID_ALIASES.get(hero_id, hero_id))


func _sync_bound_texture(hud: Control, slot_path: String, texture: Texture2D, node_name: String) -> void:
	var slot := hud.get_node_or_null(slot_path) as Control
	if slot == null:
		return
	var rect := slot.get_node_or_null(node_name) as TextureRect
	if rect == null:
		rect = TextureRect.new()
		rect.name = node_name
		rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(rect)
		rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rect.texture = texture
	rect.visible = texture != null


func _unit_type_name(unit_type: String) -> String:
	match unit_type:
		"infantry": return "보병"
		"cavalry": return "기병"
		"archer": return "궁병"
		"gunner": return "총병"
		"mounted_archer": return "기마궁병"
	return "부대"


func _hide_legacy_actor_comparison(production_root: Control) -> void:
	var legacy_hud := production_root.get_node_or_null("ActorComparisonHud") as Control
	if legacy_hud != null:
		legacy_hud.visible = false


func _sync_supply_column(controller: Node, column: String, food: String, salt: String, consumption: String, sustain: String, warning: bool) -> void:
	var root := "BattleUI/ProductionHudRoot/BottomHudRoot/BattleSupplyPreviewPanel/Margin/Content/Columns/%s" % column
	_set_text(controller, root + "/FoodValue", food)
	_set_text(controller, root + "/SaltValue", salt)
	_set_text(controller, root + "/ConsumptionValue", consumption)
	_set_text(controller, root + "/SustainValue", sustain)
	var warning_label := controller.get_node_or_null(root + "/WarningLabel") as Label
	if warning_label != null:
		warning_label.text = "소금 고갈 · 식량 소비 +10%"
		warning_label.visible = warning


func _set_local_text(root: Node, path: String, value: String) -> void:
	var label := root.get_node_or_null(path) as Label
	if label != null:
		label.text = value


func _set_local_visibility(root: Node, path: String, value: bool) -> void:
	var control := root.get_node_or_null(path) as Control
	if control != null:
		control.visible = value


func _set_text(controller: Node, path: String, value: String) -> void:
	var label := controller.get_node_or_null(path) as Label
	if label != null:
		label.text = value
