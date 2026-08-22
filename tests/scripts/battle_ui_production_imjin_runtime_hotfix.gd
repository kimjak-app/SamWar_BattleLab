extends "res://tests/scripts/battle_ui_production_imjin_test.gd"

## D5-4-hotfix2 / D5-4-hotfix3
## Focused Test2 runtime fixes discovered during live cutin QA:
## - positive resolver statuses must never render as down-triangle badges
## - screen-space facing/status overlays must stay bound to moving world units/camera
## - ally-turn camera focus must account for the large bottom HUD safe area
## - full-auto must not deadlock on Gwak Jae-u's optional manual reposition
## - while manual reposition is active, switching to another ally is blocked

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

var _test2_overlay_resync_accumulator := 0.0
var _test2_auto_reposition_skip_queued := false


func _process(delta: float) -> void:
	super._process(delta)
	_test2_overlay_resync_accumulator += delta
	if _test2_overlay_resync_accumulator >= TEST2_OVERLAY_RESYNC_INTERVAL:
		_test2_overlay_resync_accumulator = 0.0
		_sync_test2_camera_bound_unit_overlays()

	# Recovery guard for a save/live state that already entered the optional
	# manual reposition phase before full-auto was enabled or before this hotfix.
	if current_phase == PHASE_POST_SKILL_REPOSITION_SELECT \
			and is_full_auto_battle_enabled \
			and not _test2_auto_reposition_skip_queued:
		_test2_auto_reposition_skip_queued = true
		call_deferred("_finish_test2_auto_reposition_skip")


func _finalize_unique_skill_action(caster_state: BattleUnitState, skill_data: Dictionary) -> void:
	var reposition_mode := String(skill_data.get("post_skill_reposition_mode", ""))
	if caster_state != null \
			and caster_state.side == "ally" \
			and is_full_auto_battle_enabled \
			and reposition_mode == "manual":
		# The reposition is explicitly optional. Full-auto must never wait for a
		# human click, so feed the same committed skill to the parent finalizer with
		# only the presentation/runtime extension disabled. Effect/cost/cooldown and
		# action consumption stay untouched.
		var auto_skill_data := skill_data.duplicate(true)
		auto_skill_data["post_skill_reposition_mode"] = ""
		_append_battle_log("%s 자동전투 · 선택 재배치 생략" % caster_state.display_name)
		super._finalize_unique_skill_action(caster_state, auto_skill_data)
		return
	super._finalize_unique_skill_action(caster_state, skill_data)


func _select_ally_unit(
	unit_state: BattleUnitState,
	should_log: bool = true,
	should_open_command_panel: bool = true,
	should_pulse_turn_start: bool = false
) -> void:
	# Do not allow roster/UI selection to escape the manual reposition phase and
	# leave its overlay/state attached to a different active actor.
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


func _finish_test2_auto_reposition_skip() -> void:
	_test2_auto_reposition_skip_queued = false
	if current_phase != PHASE_POST_SKILL_REPOSITION_SELECT or not is_full_auto_battle_enabled:
		return
	_append_battle_log("자동전투 · 선택 재배치 생략")
	_finish_post_skill_reposition_turn()


func _apply_test2_active_actor_safe_camera_focus(expected_unit_state: BattleUnitState) -> void:
	if expected_unit_state == null \
			or active_unit_state != expected_unit_state \
			or current_phase != PHASE_ALLY_TURN \
			or not expected_unit_state.is_alive():
		return
	# Move camera center slightly downward in world space so the active actor is
	# rendered higher on screen, clear of the large Current Actor HUD.
	var focus_position := _get_camera_focus_position_for_unit(expected_unit_state)
	focus_position += Vector2(0.0, TEST2_ACTIVE_ACTOR_CAMERA_Y_OFFSET)
	_focus_camera_on_world_position(focus_position, false)
	_sync_test2_camera_bound_unit_overlays()


func _sync_test2_camera_bound_unit_overlays() -> void:
	# Facing arrows live in BattleUI screen space while units live in world space;
	# refresh their world->UI projection first, then place status badges relative
	# to the freshly projected arrows.
	_update_facing_indicators()
	_refresh_strategy_status_icon_labels()
