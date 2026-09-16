extends SceneTree

const CatalogScript := preload("res://scripts/worldmap/domestic_tech/domestic_tech_catalog.gd")

var _checks := 0
var _failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var catalog := CatalogScript.new()
	_expect(not catalog.has_method("get_node"), "catalog is RefCounted without scene-node API")
	var city_definitions: Dictionary = catalog.get_city_definitions()
	var national_definitions: Dictionary = catalog.get_national_definitions()
	_expect(city_definitions.size() == 53, "all 53 city definitions moved")
	_expect(national_definitions.size() == 32, "all 32 national definitions moved")
	_expect(catalog.get_categories().size() == 8, "all category definitions moved")
	_expect(catalog.get_by_scope("city").size() == 53 and catalog.get_by_scope("national").size() == 32, "scope lookup preserves all ids")
	_expect(catalog.get_by_category("agri").has("agri_irrigation"), "category lookup preserves identity")
	_expect(catalog.get_by_branch("military", "naval").has("naval_turtle_ship"), "branch lookup preserves identity")

	var irrigation: Dictionary = catalog.get_definition("agri_irrigation")
	_expect(irrigation.get("tree_scope") == "city" and irrigation.get("category") == "agri" and irrigation.get("branch") == "harvest", "scope/category/branch metadata preserved")
	_expect(irrigation.get("prerequisites") == ["agri_tool_upgrade"], "prerequisite metadata preserved")
	_expect(irrigation.get("cost") == {"wood": 200, "gold": 100}, "cost metadata preserved")
	_expect(irrigation.get("duration_class") == "basic" and irrigation.get("duration_turns_hint") == {"min": 3, "max": 3, "rule": "scope_tier_balance_v0_70_86", "rarity": 0}, "duration metadata preserved")
	_expect(irrigation.get("effect_stub") == {"enabled": false, "type": "grain_yield_percent", "value": 20, "description": "쌀·보리 수확량 +20%"}, "effect stub metadata preserved")

	var mint: Dictionary = catalog.get_definition("commerce_mint")
	_expect(mint.get("required_national_techs") == ["nation_currency_unification"], "required national tech metadata preserved")
	var alliance: Dictionary = catalog.get_definition("nation_alliance_system")
	_expect(alliance.get("unlocks_city_techs") == ["commerce_merchant_guild", "commerce_trade_port", "commerce_silk_road"], "unlocks metadata preserved")
	var logistics: Dictionary = catalog.get_definition("nation_logistics_system")
	_expect(logistics.get("enhances_city_techs") == ["fish_dried_supply_base"], "enhances metadata preserved")
	_expect(catalog.get_definition("unknown_tech").is_empty(), "unknown tech returns empty dictionary")

	irrigation["tier"] = 99
	(irrigation.get("cost") as Dictionary)["gold"] = 999
	var fresh_irrigation: Dictionary = catalog.get_definition("agri_irrigation")
	_expect(int(fresh_irrigation.get("tier")) == 2 and int((fresh_irrigation.get("cost") as Dictionary).get("gold")) == 100, "definition results are detached snapshots")

	change_scene_to_file("res://WorldMap_16x9_Test.tscn")
	await process_frame
	await process_frame
	var worldmap := current_scene.get_node("ProductionWorldMap")
	_expect(worldmap.call("_get_domestic_tech_definitions_mvp") == catalog.get_definitions(), "main catalog wrappers preserve definition contract")
	worldmap.call("_open_domestic_tech_tree_overlay_mvp")
	await process_frame
	var presentation_controller: Variant = worldmap.call("_ensure_domestic_tech_tree_presentation_controller")
	var overlay: Variant = presentation_controller.call("get_overlay")
	_expect(overlay is PanelContainer and (overlay as PanelContainer).visible, "Tech Tree overlay still opens")
	current_scene.queue_free()
	await process_frame
	_finish()


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("[DOMESTIC_TECH_CATALOG_FAIL] %s" % label)


func _finish() -> void:
	print("[DOMESTIC_TECH_CATALOG] %s: %d checks, %d failures" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	quit(0 if _failures == 0 else 1)
