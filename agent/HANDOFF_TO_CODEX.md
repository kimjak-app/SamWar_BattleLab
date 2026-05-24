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

`v0.67u-3 Formation Guide Card Compact Info Polish`

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
- Bottom command buttons are now scene-authored `TextureButton` nodes with the 6 PNG assets connected directly in `Battle_Fullscreen_Test.tscn`.
- `bottom_command_bar_bg.png` is now applied as the scene-authored `CommandBar` background.
- The old black `CommandBar` panel fill is hidden via transparent panel styling.
- 2D editor visibility for the bottom command buttons is restored.
- Legacy large `LeftPanel` / `RightPanel` info panels are hidden/deprecated.
- `BattleMiniLogPanel` and `FormationSlotGuideLayer` are now part of the battle UI.
- Formation slot guide shows only main `3` + reinforce `2` per side and is display-only.
- `UnitCloseupPanel` is hidden and reserved for future popup reuse.
- Formation guide cards now show portrait + name + troop count + troop icon + troop type.
- Formation guide status text is removed; active/reserve distinction is style-based.
- Floating command panel exists and remains click-to-open.
- Direct move-click UX remains stable.
- Post-move floating panel auto-reopen remains stable.
- Active ally pulse uses the unified root pulse with pivot lock at around `1.5x`.
- `5v5` full auto result path is reachable.
- Headless project / scene launch are expected to remain `0` errors and `GDScript` warnings are expected to remain `0`.
- `AutoBattleButton`, `EndTurnButton`, and `RetreatButton` are now `TextureButton` nodes with existing handlers reused.
- Existing handlers remain reused.
- `RetreatButton` remains a disabled placeholder.

## Recommended Next Task
- Current task: `v0.67v Bottom Command Bar Background Panel Apply`
- After completion: bottom command bar visual F6 QA, Formation Guide visual polish, or `Battle Screen Basic UX Stable` lock

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
