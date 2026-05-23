# HANDOFF TO CODEX

Before making changes, read:
1. `agent/CODEX_WORKFLOW_RULES.md`
2. `agent/GODOT_RULES.md`
3. `agent/CURRENT_STATE.md`
4. `agent/NEXT_TASKS.md`
5. `agent/HANDOFF_TO_CODEX.md`

Follow the autonomous execution and commit rules in `agent/CODEX_WORKFLOW_RULES.md`, including autonomous commit when the task provides an explicit commit message.

## Stable Baseline
Current stable baseline is:

`v0.67k-4 Enemy AI Surround Pressure QA Stable with Known Issue`

## Core Scene And Scripts
- Core scene: `Battle_Fullscreen_Test.tscn`
- Core scripts:
  - `scripts/battle_web_import_test.gd`
  - `scripts/battle_unit_state.gd`

Do not modify:
- `Battle_WebImport_Test.tscn`

## Current Verified State
- 1920x1080 fullscreen battle board.
- 18x10 logical grid.
- Current MVP battle target is `5v5`.
- Round flow is stable at:
  - `ROUND 1 = 3v3`
  - `ROUND 2 = 4v4`
  - `ROUND 3 = 5v5`
- Hero identity registry is applied by `hero_id`.
- Reinforcement arrival toast works.
- Victory / defeat result toast works.
- Enemy AI surround pressure is improved for lone-ally endgame states.
- UnitCloseupPanel works.
- HP 0 cleanup works.
- Auto battle can reach battle-end result flow.
- Headless project / scene launch are expected to remain `0` errors.

## Current Battle Direction
- Stable focus is the current `5v5` MVP battle.
- Per side:
  - `3 main`
  - `2 reinforce`
- Reinforce meaning:
  - `reinforce_01` remains test-trigger support
  - `reinforce_02` carries city-origin metadata contract
- Current city-origin mock contract is for battle-engine integration only, not a full worldmap system.

Important:
- UnitVisualRoot nodes are combat slot roots.
- `slot_id` is the preferred UnitVisual slot lookup key.
- `visual_key` still controls token texture lookup.
- Existing direct unit references remain as fallback while the architecture is transitional.

## Current Verified QA Points
- `5v5` actor / target path remains stable.
- Enemy AI should:
  - attack immediately if in range
  - move to attackable cells if possible
  - prefer surround cells when allies are down to `1~2`
  - choose side / rear surround cells if front is blocked
  - wait only when no useful path exists
- Reinforcement / round / result toasts share the same queue without collision.
- Hero portrait / display-name / closeup identity bindings are runtime-corrected by registry.
- Known Issue:
  - in some multi-target states, a subset of enemy actors can still idle instead of redistributing to another reachable target
  - target / destination reservation is the likely next fix area

## Recommended Next Task
v0.67k-5 Enemy AI Multi-Target Engagement Reservation Fix

Goal:
- stop passive-idle enemy actors in multi-target battles
- add target engagement reservation and destination reservation
- allow fallback target switching when the preferred target is blocked but another reachable target exists

Follow-up candidates:
- `v0.67o 5v5 Long-run Auto Battle QA`
- `v0.67l Formation Slot Guide Layer`
- `v0.67m Result Toast Duration / BGM Sync Prep`
- `v0.67n Worldmap Battle Roster Contract Prep`

## Important Direction
- Scene portrait textures are not the final identity source of truth.
- `capacity_slot_id -> assigned_hero_id -> HERO_REGISTRY` is the intended identity path.
- Worldmap later only needs to pass battle roster / hero assignment contracts.
- Keep current `5v5` MVP stable before expanding into formation guides or broader worldmap prep.

## Debug Cleanup Candidates
- `_debug_print_unit_visual_root_slots()`
- `[ATTACK_CLICK]` print
- `_debug_print_ally_portrait_offsets()`

## Do Not Break
- Do not change damage / move / attack formulas.
- Do not change auto-battle step budgeting without explicit reason.
- Do not break hero identity registry behavior.
- Do not break reinforce deploy conditions.
- Do not break reinforcement arrival toast.
- Do not break victory / defeat result toast.
- Do not break HP 0 cleanup.
- Do not break UnitCloseupPanel identity consistency.
- Do not break current `5v5` actor / target parity.
- Preserve right-click rollback / cancel behavior.
- Do not modify `Battle_WebImport_Test.tscn` casually.
