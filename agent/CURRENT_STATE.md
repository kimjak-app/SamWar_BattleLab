# CURRENT STATE

## Project
SamWar_BattleLab

## Current Stable Baseline
`v0.67p-3-hotfix3 Active Ally Pulse Pivot Lock QA Stable`

## Stable Summary
- Current battle target is stable `5v5`.
- `5v5` battle loop stable.
- Enemy AI multi-target engagement improved and treated as stable.
- Victory / defeat toast stable.
- Reinforcement toast stable.
- Bottom global command bar exists.
- Floating command panel exists.
- Direct move-click UX stable.
- Floating panel stays hidden at ally turn start and opens on active ally click.
- Movement + facing complete 후 floating panel auto-reopen.
- Active ally pulse = unified root pulse, pivot locked, around `1.5x`.
- Hero identity registry path remains stable.
- Reinforcement / round / result toast queue remains stable.
- `GDScript` warning count expected `0`.
- `5v5` full auto result path reachable.

## Current Battle Shape
- Per side:
  - `3 main`
  - `2 reinforce`
- Round flow:
  - `ROUND 1 = 3v3`
  - `ROUND 2 = 4v4`
  - `ROUND 3 = 5v5`
- Actor / target parity is expected to remain stable through the full `5v5` path.

## Core Files
- `Battle_Fullscreen_Test.tscn`
- `scripts/battle_web_import_test.gd`
- `scripts/battle_unit_state.gd`
- `scripts/unit_visual_slot.gd`

## Verified Stable Areas
- Enemy AI can advance and re-route in multi-target states instead of defaulting to passive idle.
- Victory / defeat result path is reachable in accelerated full auto.
- Reinforcement arrival toast triggers on rounds `2` and `3`.
- Bottom command bar currently centers on:
  - `자동전투`
  - `턴 종료`
  - `후퇴` placeholder
- Floating command panel currently provides:
  - `기본 공격`
  - `고유특기` placeholder
  - `책략` placeholder
  - `이동`
  - `대기`
- Right-click rollback remains part of the movement/facing flow.

## Do Not Break
- Damage / move / attack formulas.
- Hero identity registry.
- Reinforcement deploy timing.
- Reinforcement / round / result toast queue.
- Direct move-click.
- Right-click rollback.
- Floating panel click-to-open behavior.
- Post-move panel reopen.
- Active ally pulse pivot lock.
- Current `5v5` actor / target parity.

## Current Next Direction
1. `v0.67-docs Agent Docs Slimdown`
2. Bottom command bar button art asset structure
3. `Battle Screen Basic UX Stable` lock
4. Worldmap battle roster integration prep

## Archive
- Full historical copies preserved at:
  - `agent/archive/v0.67-docs_agent_docs_slimdown/CURRENT_STATE_full_before_slimdown.md`
  - `agent/archive/v0.67-docs_agent_docs_slimdown/CHANGELOG_full_before_slimdown.md`
  - `agent/archive/v0.67-docs_agent_docs_slimdown/SESSION_LOG_full_before_slimdown.md`
