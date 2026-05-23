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

`v0.67p-3-hotfix3 Active Ally Pulse Pivot Lock QA Stable`

## Core Scene And Scripts
- Core scene: `Battle_Fullscreen_Test.tscn`
- Core scripts:
  - `scripts/battle_web_import_test.gd`
  - `scripts/battle_unit_state.gd`
  - `scripts/unit_visual_slot.gd`

Do not modify casually:
- `Battle_Fullscreen_Test.tscn`

## Current Verified State
- Current MVP battle target is stable `5v5`.
- Round flow is stable:
  - `ROUND 1 = 3v3`
  - `ROUND 2 = 4v4`
  - `ROUND 3 = 5v5`
- Enemy AI multi-target engagement is improved and considered stable.
- Hero identity registry is applied by `hero_id`.
- Reinforcement arrival toast is stable.
- Victory / defeat result toast is stable.
- Reinforcement / round / result toast queue is stable.
- Bottom global command bar exists.
- Bottom command bar art-prep structure now exists under `assets/web_battle/ui/bottom_command/`.
- Floating command panel exists and remains click-to-open.
- Direct move-click UX remains stable.
- Post-move floating panel auto-reopen remains stable.
- Active ally pulse uses the unified root pulse with pivot lock at around `1.5x`.
- `5v5` full auto result path is reachable.
- Headless project / scene launch are expected to remain `0` errors and `GDScript` warnings are expected to remain `0`.
- `AutoBattleButton`, `EndTurnButton`, and `RetreatButton` remain `Button` nodes with existing handlers reused.
- Actual bottom command PNG files are still optional; missing files should keep current behavior without load errors.

## Recommended Next Task
- Current task: `v0.67r Bottom Command Bar Art Asset Structure Prep`
- After completion: bottom command button actual asset integration or `v0.67s Floating Command Panel Art Direction Prep`

## Important Direction
- Keep the current battle screen interaction baseline stable before new UX/art expansion.
- Enemy AI multi-target engagement is completed stable functionality, not an open known-issue track.
- Scene portrait textures are not the final identity source of truth.
- `capacity_slot_id -> assigned_hero_id -> HERO_REGISTRY` remains the intended identity path.
- Worldmap integration should build on the current stable `5v5` roster/battle contract path.

## Do Not Break
- Damage / move / attack formulas.
- Hero identity registry behavior.
- Reinforcement deploy timing.
- Reinforcement / round / result toast queue.
- Direct move-click.
- Right-click rollback / cancel behavior.
- Floating panel click-to-open behavior.
- Post-move panel reopen.
- Active ally pulse pivot lock.
- Current `5v5` actor / target parity.
