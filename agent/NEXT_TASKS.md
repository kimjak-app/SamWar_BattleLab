# NEXT TASKS

## Current Stable Baseline
`v0.67p-3-hotfix3 Active Ally Pulse Pivot Lock QA Stable`

## Priority 1
Bottom command button actual asset integration

Goal:
- add actual PNG art into the prepared bottom command structure
- keep existing handlers reused
- preserve current button behavior and fallback safety when assets are missing during integration work

## Priority 2
`v0.67s Floating Command Panel Art Direction Prep`

Requirements:
- `기본공격` / `고유특기` / `책략` / `이동` / `대기`
- normal / pressed states
- current functional panel must remain stable

## Priority 3
`v0.68a Battle Screen Basic UX Stable`

Goal:
- keep the current battle interaction flow stable while visual UX is tightened
- preserve direct move-click, rollback, post-move reopen, and active ally pulse behavior

## Priority 4
Worldmap battle roster integration prep

Goal:
- prepare worldmap-to-battle roster contract work on top of the current stable `5v5` battle baseline

## Completed / Archived Context
- `v0.67r Bottom Command Bar Art Asset Structure Prep` is complete.
- Prepared `assets/web_battle/ui/bottom_command/README.md`.
- Prepared optional button-art runtime mapping for `AutoBattleButton`, `EndTurnButton`, and `RetreatButton`.
- Actual PNG files are not required yet; missing files keep existing button behavior with no load error.
- `v0.67k-5 Enemy AI Multi-Target Engagement Reservation Fix` is completed history, not the current active priority.
- Enemy AI multi-target engagement improvement is part of the current stable battle baseline.
- Older detailed history is preserved in:
  - `agent/archive/v0.67-docs_agent_docs_slimdown/CURRENT_STATE_full_before_slimdown.md`
  - `agent/archive/v0.67-docs_agent_docs_slimdown/CHANGELOG_full_before_slimdown.md`
  - `agent/archive/v0.67-docs_agent_docs_slimdown/SESSION_LOG_full_before_slimdown.md`
