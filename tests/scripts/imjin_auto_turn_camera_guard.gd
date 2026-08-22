extends Node

## D5-4-hotfix5
## Test2-only camera handoff parity guard.
##
## Enemy unique-skill/cutin completion can finish the logical ally-turn handoff
## before the final camera callbacks have settled. Detect the actual
## enemy/resolving -> ally_turn transition, wait for the presentation callbacks
## to drain, then invoke the exact same unit-focus function used by a manual
## ally selection. No HUD layout or battle-state authority is changed here.

const ALLY_PHASE := "ally_turn"
const MAX_SETTLE_FRAMES := 8

var battle_host: Node = null
var last_phase := ""
var focus_generation := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	battle_host = get_parent()
	if battle_host != null:
		last_phase = String(battle_host.get("current_phase"))


func _process(_delta: float) -> void:
	if battle_host == null:
		return
	var phase := String(battle_host.get("current_phase"))
	if phase == last_phase:
		return
	last_phase = phase
	if phase == ALLY_PHASE:
		focus_generation += 1
		call_deferred("_focus_active_ally_after_handoff", focus_generation)


func _focus_active_ally_after_handoff(generation: int) -> void:
	if battle_host == null:
		return
	for _frame_index in range(MAX_SETTLE_FRAMES):
		await get_tree().process_frame
		if generation != focus_generation:
			return
		if String(battle_host.get("current_phase")) != ALLY_PHASE:
			return
		if not bool(battle_host.get("is_demo_animating")):
			break

	# Give the cutin/turn-completion callbacks one short final settle window so a
	# late enemy focus tween cannot overwrite the new ally focus.
	await get_tree().create_timer(0.06).timeout
	if generation != focus_generation \
			or String(battle_host.get("current_phase")) != ALLY_PHASE \
			or bool(battle_host.get("is_demo_animating")):
		return
	var active_unit: Variant = battle_host.get("active_unit_state")
	if active_unit == null:
		return

	# Manual ally selection uses this exact focus call. Reuse it verbatim instead
	# of applying a second custom Y-offset contract.
	battle_host.call("_focus_camera_on_unit", active_unit, false)
	battle_host.call("_refresh_camera_bound_world_overlays")
	battle_host.call("_refresh_strategy_status_icon_labels")
	print("[D5_CAMERA_HANDOFF] focused active ally after automatic turn return")
