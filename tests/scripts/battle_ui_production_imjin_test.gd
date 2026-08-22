extends "res://scripts/battle_web_import_test.gd"

## Demo/Test2 scenario only.
##
## The Production HUD and battle controller remain inherited from
## Battle_UI_Production_Test. Test2 swaps only scenario identity/content while
## reusing the same battle core and Production HUD.

const IMJIN_TEST_BATTLE_ROSTER := {
	"ally_main_01": "yi_sun_sin",
	"ally_main_02": "gwak_jae_u",
	"ally_main_03": "kim_deok_ryeong",
	"ally_reinforce_01": "kwon_yul",
	"ally_reinforce_02": "go_gyeong_myeong",
	"enemy_main_01": "toyotomi_hideyoshi",
	"enemy_main_02": "shimazu_yoshihiro",
	"enemy_main_03": "kato_kiyomasa",
	"enemy_reinforce_01": "konishi_yukinaga",
	"enemy_reinforce_02": "kuroda_nagamasa",
}

const KOREA_DEMO_HERO_IDS := {
	"yi_sun_sin": true,
	"gwak_jae_u": true,
	"kim_deok_ryeong": true,
	"kwon_yul": true,
	"go_gyeong_myeong": true,
}
const JAPAN_DEMO_HERO_IDS := {
	"toyotomi_hideyoshi": true,
	"shimazu_yoshihiro": true,
	"kato_kiyomasa": true,
	"konishi_yukinaga": true,
	"kuroda_nagamasa": true,
}
const REGULAR_PORTRAIT_STEM_OVERRIDES := {
	"kwon_yul": "gwon_yul",
}
const PHASE_POST_SKILL_REPOSITION_SELECT := "post_skill_reposition_select"
const POST_SKILL_REPOSITION_FILL_COLOR := Color(0.26, 0.78, 0.48, 0.30)
const POST_SKILL_REPOSITION_OUTLINE_COLOR := Color(0.60, 1.0, 0.72, 0.92)
const POST_SKILL_REPOSITION_HIGHLIGHT_COLOR := Color(0.78, 1.0, 0.84, 0.34)
const TEST2_OVERLAY_RESYNC_INTERVAL := 0.05
const TEST2_ACTIVE_ACTOR_CAMERA_Y_OFFSET := 120.0
const TEST2_POSITIVE_STATUS_IDS := {
	"attack_defense_up": true,
	"defense_up": true,
	"damage_reduction": true,
	"mobility_up": true,
	"counter_up": true,
	"flank_damage_up": true,
	"incoming_damage_down": true,
	"momentum_gain_up": true,
	"rout_resist": true,
	"siege_attack_up": true,
	"status_resist": true,
}

var post_skill_reposition_caster_state: BattleUnitState = null
var post_skill_reposition_range := 0
var post_skill_reposition_optional := false
var post_skill_reposition_valid_cells: Array[Vector2i] = []
var _test2_overlay_resync_accumulator := 0.0
var _test2_auto_reposition_skip_queued := false

@onready var test2_cutin_input_blocker: Control = get_node_or_null("HeroCutinOverlay/HeroCutinInputBlocker") as Control


func _process(delta: float) -> void:
	super._process(delta)
	_sync_test2_cutin_input_blocker()
	_test2_overlay_resync_accumulator += delta
	if _test2_overlay_resync_accumulator >= TEST2_OVERLAY_RESYNC_INTERVAL:
		_test2_overlay_resync_accumulator = 0.0
		_refresh_camera_bound_world_overlays()
		_refresh_strategy_status_icon_labels()
	if current_phase == PHASE_POST_SKILL_REPOSITION_SELECT \
			and is_full_auto_battle_enabled \
			and not _test2_auto_reposition_skip_queued:
		_test2_auto_reposition_skip_queued = true
		call_deferred("_finish_test2_auto_reposition_skip")


func _sync_test2_cutin_input_blocker() -> void:
	if test2_cutin_input_blocker == null or hero_cutin_overlay == null:
		return
	test2_cutin_input_blocker.mouse_filter = Control.MOUSE_FILTER_STOP if hero_cutin_overlay.visible else Control.MOUSE_FILTER_IGNORE


func _create_demo_unit_states() -> void:
	# The inherited Test1 builder owns positions, troop allocation, turn flags and
	# battle wiring. Immediately after it builds the ten state objects, rebind
	# each object to Test2's canonical hero id. BattleUnitState.unit_id is an
	# authority setter: assigning a registered hero id refreshes the authoritative
	# unit type, stats and unique-skill definition from HERO_DATA/design JSON.
	super._create_demo_unit_states()
	_rebind_imjin_demo_state(ally_unit_state, "ally_main_01")
	_rebind_imjin_demo_state(ally_support_unit_state, "ally_main_02")
	_rebind_imjin_demo_state(ally_main_03_unit_state, "ally_main_03")
	_rebind_imjin_demo_state(ally_reinforce_01_unit_state, "ally_reinforce_01")
	_rebind_imjin_demo_state(ally_reinforce_02_unit_state, "ally_reinforce_02")
	_rebind_imjin_demo_state(enemy_unit_state, "enemy_main_01")
	_rebind_imjin_demo_state(enemy_support_unit_state, "enemy_main_02")
	_rebind_imjin_demo_state(enemy_main_03_unit_state, "enemy_main_03")
	_rebind_imjin_demo_state(enemy_reinforce_01_unit_state, "enemy_reinforce_01")
	_rebind_imjin_demo_state(enemy_reinforce_02_unit_state, "enemy_reinforce_02")


func _rebind_imjin_demo_state(unit_state: BattleUnitState, slot_id: String) -> void:
	if unit_state == null:
		return
	var hero_id := _get_test_battle_roster_hero_id(slot_id)
	if hero_id.is_empty():
		return
	# Set capacity slot first so the authority rebuild sees the final slot id.
	unit_state.slot_id = slot_id
	unit_state.unit_id = hero_id
	# HERO_DATA owns combat authority. These two fields are presentation-only and
	# select the correct nation-specific troop visuals for this scenario.
	unit_state.nation = _get_imjin_nation_key(hero_id)
	unit_state.visual_key = _get_imjin_visual_key(hero_id, unit_state.unit_type)
	unit_state.portrait_key = hero_id


func _get_test_battle_roster_hero_id(slot_id: String) -> String:
	return String(IMJIN_TEST_BATTLE_ROSTER.get(slot_id, ""))


func _get_hero_registry_entry(hero_id: String) -> Dictionary:
	var entry := super._get_hero_registry_entry(hero_id)
	var hero_data := HeroDefinitionRegistry.get_hero(hero_id)
	if entry.is_empty() and not hero_data.is_empty():
		entry = _build_worldmap_context_hero_registry_entry(hero_data)
	if entry.is_empty():
		return {}
	# Parent registries may return const/read-only dictionaries. Test2 only needs
	# presentation overrides, so always detach into a writable deep copy before
	# mutating visual/portrait fields.
	entry = entry.duplicate(true)
	entry["default_visual_key"] = _get_imjin_visual_key(
		hero_id,
		String(hero_data.get("unit_type", entry.get("unit_type", "infantry")))
	)
	# Roster/close-up surfaces use the normal portrait. The large cinematic
	# current_actor image is intentionally NOT placed in closeup_portrait_path;
	# battle_ui_production_test_bottom_hud.gd owns that separate contract.
	var regular_portrait := _get_imjin_regular_portrait_path(hero_id)
	if not regular_portrait.is_empty():
		entry["closeup_portrait_path"] = regular_portrait
		entry["battlefield_portrait_path"] = regular_portrait
	return entry


func _get_sample_unique_skill_entry_for_worldmap_hero(hero_data: Dictionary) -> Dictionary:
	var existing := super._get_sample_unique_skill_entry_for_worldmap_hero(hero_data)
	if not existing.is_empty():
		return existing
	return _build_worldmap_context_unique_skill_entry(hero_data)


func _finalize_unique_skill_action(caster_state: BattleUnitState, skill_data: Dictionary) -> void:
	var reposition_mode := String(skill_data.get("post_skill_reposition_mode", ""))
	var reposition_range := maxi(int(skill_data.get("post_skill_reposition_range", 0)), 0)
	if caster_state != null \
			and caster_state.side == "ally" \
			and is_full_auto_battle_enabled \
			and reposition_mode == "manual":
		# Manual reposition is optional. Full-auto must never wait for a human
		# click, so keep the committed effect/cost/cooldown/action contract and
		# only skip the optional presentation branch.
		var auto_skill_data := skill_data.duplicate(true)
		auto_skill_data["post_skill_reposition_mode"] = ""
		_append_battle_log("%s 자동전투 · 선택 재배치 생략" % caster_state.display_name)
		super._finalize_unique_skill_action(caster_state, auto_skill_data)
		return
	if caster_state == null \
			or caster_state.side != "ally" \
			or reposition_mode != "manual" \
			or reposition_range <= 0:
		super._finalize_unique_skill_action(caster_state, skill_data)
		return

	# The skill is already committed and its effect has resolved. Prepare the same
	# post-commit state as the base finalizer, but delay enemy-turn handoff until
	# the optional manual reposition is chosen or skipped.
	_hide_unique_skill_toast()
	_hide_specialty_skill_cutin()
	is_unique_skill_presenting = false
	is_demo_animating = false
	_reset_unit_group_positions()
	_hide_all_move_dust_sprites()
	_set_all_unit_group_modulates(Color.WHITE)
	_clear_attack_target_selection()
	_clear_strategy_targeting_state()
	_hide_strategy_range_overlay()
	_hide_unique_skill_range_overlay()
	_clear_pending_move_snapshot()
	_clear_auto_action_flags()
	pending_unique_skill_plan.clear()
	_set_unique_skill_cooldown(caster_state, int(skill_data.get("cooldown_turns", 0)))
	if bool(skill_data.get("consumes_action", true)):
		_mark_ally_unit_acted(caster_state)
	_show_unit_closeup_for_ally(caster_state)
	_update_ally_ready_frames()
	_cleanup_dead_units()
	if _is_battle_result_finalized() or not caster_state.is_alive():
		_clear_post_skill_reposition_state()
		_set_phase(PHASE_ALLY_TURN)
		return

	_begin_post_skill_reposition(
		caster_state,
		reposition_range,
		bool(skill_data.get("post_skill_reposition_optional", false))
	)


func _begin_post_skill_reposition(caster_state: BattleUnitState, reposition_range: int, is_optional: bool) -> void:
	post_skill_reposition_caster_state = caster_state
	post_skill_reposition_range = maxi(reposition_range, 1)
	post_skill_reposition_optional = is_optional
	post_skill_reposition_valid_cells = _get_post_skill_reposition_valid_cells(caster_state, post_skill_reposition_range)
	if post_skill_reposition_valid_cells.is_empty():
		_append_battle_log("%s 재배치 가능한 칸 없음" % caster_state.display_name)
		_finish_post_skill_reposition_turn()
		return

	active_unit_state = caster_state
	active_unit_side = "ally"
	is_demo_animating = false
	_set_phase(PHASE_POST_SKILL_REPOSITION_SELECT)
	if turn_banner != null:
		turn_banner.text = "재배치 선택 · BATTLE %d" % battle_round
	_show_post_skill_reposition_overlay()
	if post_skill_reposition_optional:
		_append_battle_log("%s 재배치 · 3칸 내 빈 칸 선택 / 우클릭 제자리" % caster_state.display_name)
	else:
		_append_battle_log("%s 재배치 · 3칸 내 빈 칸을 선택하세요" % caster_state.display_name)
	_refresh_production_battle_hud("post-skill-reposition")


func _get_post_skill_reposition_valid_cells(caster_state: BattleUnitState, reposition_range: int) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	if caster_state == null or battle_grid_controller == null:
		return result
	var origin_cell := caster_state.grid_cell
	for candidate in battle_grid_controller.get_tiles_in_range(origin_cell, reposition_range):
		if candidate == origin_cell:
			continue
		if battle_grid_controller.get_distance(origin_cell, candidate) > reposition_range:
			continue
		if not _is_valid_destination_for_unit(candidate, caster_state, false):
			continue
		result.append(candidate)
	return result


func _show_post_skill_reposition_overlay() -> void:
	_hide_move_range_overlay()
	if battle_grid_controller == null or post_skill_reposition_caster_state == null:
		return
	var cell_size := battle_grid_controller.get_cell_size()
	if cell_size.x <= 0.0 or cell_size.y <= 0.0:
		return
	var origin_cell := post_skill_reposition_caster_state.grid_cell
	var ordered_cells := _get_cells_wave_order(
		post_skill_reposition_valid_cells,
		origin_cell,
		post_skill_reposition_range
	)
	var visible_count := mini(ordered_cells.size(), move_range_cells.size())
	for index in range(visible_count):
		var cell := ordered_cells[index]
		var rect := move_range_cells[index]
		_show_range_overlay_cell(
			rect,
			cell,
			cell_size,
			POST_SKILL_REPOSITION_FILL_COLOR,
			origin_cell,
			true,
			1.0,
			POST_SKILL_REPOSITION_OUTLINE_COLOR,
			POST_SKILL_REPOSITION_HIGHLIGHT_COLOR
		)


func _unhandled_input(event: InputEvent) -> void:
	if current_phase != PHASE_POST_SKILL_REPOSITION_SELECT:
		super._unhandled_input(event)
		return
	if not (event is InputEventMouseButton):
		return
	var mouse_event := event as InputEventMouseButton
	if not mouse_event.pressed:
		return
	if mouse_event.button_index == MOUSE_BUTTON_RIGHT:
		if post_skill_reposition_optional:
			_append_battle_log("재배치 생략 · 제자리 유지")
			_finish_post_skill_reposition_turn()
		else:
			_append_battle_log("재배치 칸을 선택하세요")
		get_viewport().set_input_as_handled()
		return
	if mouse_event.button_index != MOUSE_BUTTON_LEFT:
		return
	if _is_mouse_over_battle_ui():
		return
	if battle_grid_controller == null:
		return
	var target_cell := battle_grid_controller.world_to_grid(get_global_mouse_position())
	if not post_skill_reposition_valid_cells.has(target_cell):
		_append_battle_log("재배치 가능한 3칸 내 빈 칸을 선택하세요")
		get_viewport().set_input_as_handled()
		return
	_apply_post_skill_reposition(target_cell)
	get_viewport().set_input_as_handled()


func _apply_post_skill_reposition(target_cell: Vector2i) -> void:
	var caster_state := post_skill_reposition_caster_state
	if caster_state == null or battle_grid_controller == null:
		_finish_post_skill_reposition_turn()
		return
	var origin_cell := caster_state.grid_cell
	if not post_skill_reposition_valid_cells.has(target_cell):
		return
	caster_state.set_grid_cell(target_cell)
	_sync_resumed_unit_markers_to_grid(caster_state)
	_sync_demo_positions()
	_update_all_unit_visuals_from_state()
	_update_facing_indicators()
	_update_cell_size_visual_guide(target_cell)
	_show_unit_closeup_for_ally(caster_state)
	_refresh_formation_slot_guides()
	_refresh_strategy_status_icon_labels()
	_append_battle_log("%s 재배치 %s → %s" % [
		caster_state.display_name,
		_format_cell(origin_cell),
		_format_cell(target_cell),
	])
	_finish_post_skill_reposition_turn()


func _finish_post_skill_reposition_turn() -> void:
	_hide_move_range_overlay()
	_clear_post_skill_reposition_state()
	_update_ally_ready_frames()
	_refresh_formation_slot_guides()
	if _is_battle_result_finalized():
		_set_phase(PHASE_ALLY_TURN)
		return
	_set_phase(PHASE_ENEMY_TURN)
	_append_battle_log("적군 턴")
	_play_enemy_turn_demo()


func _finish_test2_auto_reposition_skip() -> void:
	_test2_auto_reposition_skip_queued = false
	if current_phase != PHASE_POST_SKILL_REPOSITION_SELECT or not is_full_auto_battle_enabled:
		return
	_append_battle_log("자동전투 · 선택 재배치 생략")
	_finish_post_skill_reposition_turn()


func _clear_post_skill_reposition_state() -> void:
	post_skill_reposition_caster_state = null
	post_skill_reposition_range = 0
	post_skill_reposition_optional = false
	post_skill_reposition_valid_cells.clear()
	_test2_auto_reposition_skip_queued = false


func _select_ally_unit(
	unit_state: BattleUnitState,
	should_log: bool = true,
	should_open_command_panel: bool = true,
	should_pulse_turn_start: bool = false
) -> void:
	if current_phase == PHASE_POST_SKILL_REPOSITION_SELECT \
			and post_skill_reposition_caster_state != null \
			and unit_state != post_skill_reposition_caster_state:
		if should_log:
			_append_battle_log("%s 재배치를 먼저 완료하세요" % post_skill_reposition_caster_state.display_name)
		return
	super._select_ally_unit(unit_state, should_log, should_open_command_panel, should_pulse_turn_start)


func _return_to_ally_turn() -> void:
	super._return_to_ally_turn()
	if current_phase == PHASE_ALLY_TURN \
			and active_unit_state != null \
			and active_unit_side == "ally" \
			and active_unit_state.is_alive():
		call_deferred("_apply_test2_active_actor_safe_camera_focus", active_unit_state)


func _apply_test2_active_actor_safe_camera_focus(expected_unit_state: BattleUnitState) -> void:
	if expected_unit_state == null \
			or active_unit_state != expected_unit_state \
			or current_phase != PHASE_ALLY_TURN \
			or not expected_unit_state.is_alive():
		return
	# Positive Y moves the camera center downward in world space, which renders
	# the active actor higher on screen and clear of the Current Actor HUD.
	var focus_position := _get_camera_focus_position_for_unit(expected_unit_state)
	focus_position += Vector2(0.0, TEST2_ACTIVE_ACTOR_CAMERA_Y_OFFSET)
	_focus_camera_on_world_position(focus_position, false)
	_refresh_camera_bound_world_overlays()
	_refresh_strategy_status_icon_labels()


func _get_unit_status_display_entries(unit_state: BattleUnitState) -> Array[Dictionary]:
	var inherited_entries: Array[Dictionary] = super._get_unit_status_display_entries(unit_state)
	var corrected_entries: Array[Dictionary] = []
	for inherited_entry in inherited_entries:
		var entry := inherited_entry.duplicate(true)
		var status_id := String(entry.get("id", ""))
		if TEST2_POSITIVE_STATUS_IDS.has(status_id):
			var badge := String(entry.get("badge", ""))
			if badge.begins_with("▼"):
				entry["badge"] = "▲%s" % badge.substr(1)
			var summary := String(entry.get("summary", ""))
			if summary.begins_with("▼"):
				entry["summary"] = "▲%s" % summary.substr(1)
		corrected_entries.append(entry)
	return corrected_entries


func _get_imjin_visual_key(hero_id: String, unit_type: String) -> String:
	if KOREA_DEMO_HERO_IDS.has(hero_id):
		return "korea_%s" % unit_type
	if JAPAN_DEMO_HERO_IDS.has(hero_id):
		return "japan_%s" % unit_type
	return unit_type


func _get_imjin_nation_key(hero_id: String) -> String:
	if KOREA_DEMO_HERO_IDS.has(hero_id):
		return "korea"
	if JAPAN_DEMO_HERO_IDS.has(hero_id):
		return "japan"
	return ""


func _get_imjin_regular_portrait_path(hero_id: String) -> String:
	var nation_dir := _get_imjin_nation_key(hero_id)
	if nation_dir.is_empty():
		return ""
	var stem := String(REGULAR_PORTRAIT_STEM_OVERRIDES.get(hero_id, hero_id))
	var path := "res://assets/heroes/portraits/%s/%s_%s.png" % [nation_dir, nation_dir, stem]
	return path if FileAccess.file_exists(path) else ""
