extends SceneTree

const CatalogScript := preload("res://scripts/worldmap/domestic_tech/domestic_tech_catalog.gd")
const ProviderScript := preload("res://scripts/worldmap/domestic_tech/domestic_tech_effect_provider.gd")
const ControllerScript := preload("res://scripts/worldmap/domestic_tech/domestic_tech_tree_presentation_controller.gd")

var _checks := 0
var _failures := 0
var _research_requests := 0
var _last_request: Dictionary = {}
var _catalog := CatalogScript.new()
var _provider := ProviderScript.new()


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_provider.configure(_catalog)
	var controller := ControllerScript.new()
	root.add_child(controller)
	controller.configure(root, _callbacks(), _provider)
	controller.research_requested.connect(_on_research_requested)
	controller.ensure_overlay()
	_expect(controller.get_overlay() != null, "overlay create")
	controller.open()
	_expect(controller.is_open(), "overlay open")
	var overlay := controller.get_overlay()
	_expect(overlay.find_child("NationalTechTreePanelMVP", true, false) != null, "national section rendered")
	_expect(overlay.find_child("CityTechTreePanelMVP", true, false) != null, "city section rendered")
	_expect(overlay.find_child("NationalTechList", true, false) != null and overlay.find_child("CityTechList", true, false) != null, "refresh builds both lists")
	_expect(overlay.find_child("DomesticTechDetailInspectorMVP", true, false) != null, "detail inspector rendered")
	_expect(overlay.find_child("DomesticTechResearchActionButtonMVP", true, false) != null, "research action slot rendered")

	var layout := controller.get_graph_layout_contract()
	_expect(layout.node_size == Vector2(192.0, 84.0), "graph node size preserved")
	_expect(is_equal_approx(float(layout.tier_spacing), 238.0) and is_equal_approx(float(layout.branch_spacing), 138.0), "graph spacing preserved")
	_expect(is_equal_approx(float(layout.overlay_margin), 22.0) and is_equal_approx(float(layout.line_width), 3.0), "overlay and line layout preserved")
	var defs: Array[Dictionary] = [_catalog.get_definition("agri_tool_upgrade"), _catalog.get_definition("agri_irrigation")]
	var positions: Dictionary = controller._get_domestic_tech_graph_positions_mvp(defs)
	_expect((positions.agri_tool_upgrade as Rect2).position == Vector2(110.0, 48.0), "tier-one graph position preserved")
	_expect((positions.agri_irrigation as Rect2).position.x == 348.0, "tier spacing position preserved")
	var canvas_size: Vector2 = controller._get_domestic_tech_graph_canvas_size_mvp(positions)
	_expect(canvas_size.x >= 650.0 and canvas_size.y >= 220.0, "graph canvas bounds preserved")

	controller._set_selected_domestic_tech_for_inspector_mvp("agri_irrigation", "hanseong")
	_expect(str(controller.get_selection().tech_id) == "agri_irrigation", "selected tech is transient controller state")
	_expect(controller._is_selected_domestic_tech_for_inspector_mvp("agri_irrigation", "hanseong"), "selected-node query")
	_expect(controller._domestic_tech_detail_inspector_label_mvp != null and not controller._domestic_tech_detail_inspector_label_mvp.text.is_empty(), "inspector refresh keeps content node")
	_expect(controller._format_domestic_tech_compact_status_mvp(_view_state("completed")) == "[완료]", "completed visual state")
	_expect(controller._format_domestic_tech_compact_status_mvp(_view_state("researching")) == "진행 중", "researching visual state")
	_expect(controller._format_domestic_tech_compact_status_mvp(_view_state("locked")) == "[잠김]", "locked visual state")
	controller._on_domestic_tech_research_action_pressed_mvp()
	_expect(_research_requests == 1 and str(_last_request.tech_id) == "agri_irrigation", "research button emits request without mutation")

	var icon_parent := HBoxContainer.new()
	root.add_child(icon_parent)
	controller._add_domestic_tech_icon_mvp(icon_parent, "agri_irrigation", 42.0, 18)
	_expect(icon_parent.get_child_count() == 1 and (icon_parent.get_child(0) as Control).custom_minimum_size == Vector2(42.0, 42.0), "icon placement preserved")
	controller._set_selected_domestic_tech_for_inspector_mvp("unknown", "hanseong")
	_expect(str(controller.get_selection().tech_id).is_empty(), "unknown tech handled safely")
	_expect(not controller.has_method("start_research") and not controller.has_method("save_game"), "no research mutation or save dependency")
	controller.close()
	_expect(not controller.is_open() and str(controller.get_selection().tech_id).is_empty(), "overlay close resets transient selection")
	controller.open()
	controller.refresh()
	_expect(controller.is_open(), "refresh preserves open overlay")
	_finish()


func _callbacks() -> Dictionary:
	return {
		"selected_city_id": func(): return "hanseong",
		"has_selected_city": func(): return true,
		"can_start": func(_tech_id: String, _city_id: String): return {"ok": true, "message": ""},
		"format_city_name": func(_city_id: String, _fallback: String): return "한성",
		"format_active_research": func(_active: Dictionary): return "",
		"format_city_economy": func(_city_id: String): return [],
		"format_city_military": func(_city_id: String, _entry: Variant): return [],
		"format_city_naval": func(_city_id: String): return [],
		"format_city_spy": func(_city_id: String): return [],
		"format_diplomacy_spy": func(): return [],
		"format_national_policy": func(): return [],
		"city_hud_entry": func(_city_id: String): return {},
		"city_definitions": func(): return _catalog.get_city_definitions(),
		"national_definitions": func(): return _catalog.get_national_definitions(),
		"categories": func(): return _catalog.get_categories(),
		"definition": func(tech_id: String): return _catalog.get_definition(tech_id),
		"research_cost_plan": func(tech_def: Dictionary, _scope: String): return {"cost": tech_def.get("cost", {}), "duration_turns": 2},
		"view_state": func(tech_id: String, _city_id: String): return _view_state("completed" if tech_id == "agri_tool_upgrade" else "researching" if tech_id == "agri_irrigation" else "available"),
		"city_coastal": func(_city_id: String): return true,
		"city_completed": func(_city_id: String, tech_id: String): return tech_id == "agri_tool_upgrade",
		"city_owned": func(_city_id: String): return true,
		"is_city_tech": func(tech_id: String): return _catalog.is_city_tech(tech_id),
		"is_national_tech": func(tech_id: String): return _catalog.is_national_tech(tech_id),
		"researching": func(tech_id: String, _city_id: String): return tech_id == "agri_irrigation",
		"national_completed": func(_tech_id: String): return false,
	}


func _view_state(state: String) -> Dictionary:
	return {"state": state, "label": state, "is_locked": state == "locked", "lock_reasons": [], "active_research": {}}


func _on_research_requested(tech_id: String, city_id: String) -> void:
	_research_requests += 1
	_last_request = {"tech_id": tech_id, "city_id": city_id}


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("[DOMESTIC_TECH_TREE_PRESENTATION_FAIL] %s" % label)


func _finish() -> void:
	print("[DOMESTIC_TECH_TREE_PRESENTATION] %s: %d checks, %d failures" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	quit(0 if _failures == 0 else 1)
