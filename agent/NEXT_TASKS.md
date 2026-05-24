# NEXT TASKS

## Current Stable Baseline
`v0.67x-2 Enemy/Auto Unique Skill + Directional Damage Bonus`

## Priority 1
`v0.67x-3 Unique Skill Range Balance Pass`

Goal:
- rebalance unique skill range / effect radius / target rules after the auto/enemy skill path is stable

## Priority 2
`v0.67y Tactics MVP`

Goal:
- turn the floating `책략` placeholder into the next small battle command surface

## Priority 3
`v0.68 Terrain Block Layer MVP`

Goal:
- add the first terrain/blocking layer contract for battle movement and targeting

## Completed / Archived Context
- `v0.67x-2 Enemy/Auto Unique Skill + Directional Damage Bonus` is complete.
- Auto battle can use ally unique skills before normal attack/move/wait fallback.
- Enemy AI can use unique skills on enemy turns and after movement rechecks.
- Directional damage bonus is applied to basic attacks, enemy hits, and single-target attack unique skills.
- Directional multipliers are front `1.0`, side `1.15`, back `1.3`.
- Unique skill readiness now uses cooldown state instead of a one-use flag.
- Formation-guide `UniqueSkillReadyIcon` is enlarged to `64 x 64`.
- Deferred `SkillInfoPanel` and unique skill range balance to later passes.
- `v0.67x-hotfix2 Unique Skill UX Targeting + Backdrop + Ready Icon Fix` is complete.
- Removed the `is_visible` parameter shadowing warning.
- Removed the black rectangular unique skill toast backdrop.
- Kept unique skill hover tooltip text suppressed while keeping button text visible.
- Enlarged the formation-guide unique skill ready icon to `36 x 36`.
- Changed ally manual unique skill flow to button click -> range/target display -> valid target click -> resolve.
- Kept `SkillInfoPanel` deferred as a later UX pass.
- `v0.67x-1 Unique Skill Hover Cleanup + Ready Icon` is complete.
- Removed duplicate hover tooltip text from `FloatingUniqueSkillButton`.
- Added a small formation-guide unique skill ready icon for the currently usable active ally only.
- Kept `SkillInfoPanel` deferred as the next UX candidate.
- No battle logic change intended.
- `v0.67x Unique Skill MVP Per Hero Cutin` is complete.
- Added `10` hero unique skill registry entries for the current test battle roster.
- Linked the `6` new cutin images and existing Yi Sunsin / Jeong Dojeon / Guan Yu / Zhang Fei cutins.
- Enabled ally manual unique skill use from the floating command panel.
- Added a world-anchored ink unique skill toast with `2200ms` timing, cutin image, and skill name text.
- Added large red unique skill damage numbers and short camera shake.
- Enemy / auto unique skill use is deferred to a future pass.
- `v0.67w Battle Screen Basic UX Stable Lock` is complete.
- Locked the current MVP battle-screen UX around:
  - ally formation guide `5` cards
  - enemy formation guide `5` cards
  - lower-left battle mini log
  - bottom command `TextureButton` bar + background panel
  - floating command panel
- Kept legacy large side panels hidden, kept `UnitCloseupPanel` hidden, and kept direct move-click / rollback / post-move reopen / active ally pulse stable.
- Bottom command bar background is considered good enough for MVP and can remain a later polish candidate.
- `v0.67v Bottom Command Bar Background Panel Apply` is complete.
- Applied `bottom_command_bar_bg.png` as the `CommandBar` scene background.
- Hid the old black `CommandBar` panel fill behind a transparent panel style.
- Preserved bottom command `TextureButton` handlers and scene-authored layout.
- `v0.67u-3 Formation Guide Card Compact Info Polish` is complete.
- Hid `UnitCloseupPanel` while keeping it reusable.
- Simplified formation cards and removed status text.
- Added troop icon + troop type label to each formation guide card.
- Reduced formation card font sizes for a tighter strategy UI read.
- Active/reserve distinction now relies on visual style instead of text.
- `v0.67u Formation Slot Guide Layout MVP` is complete.
- `BattleMiniLogPanel` is added.
- `FormationSlotGuideLayer` is added with ally/enemy guide panels.
- Only main `3` + reinforce `2` per side are shown.
- Guide UI is display-only with no click behavior.
- Battle logic is unchanged.
- `v0.67t-hotfix Bottom Command TextureButton Scene Fix` is complete.
- Converted `AutoBattleButton`, `EndTurnButton`, and `RetreatButton` from `Button` to scene-authored `TextureButton`.
- Connected the 6 bottom command PNG assets directly in `Battle_Fullscreen_Test.tscn`.
- Preserved existing handlers.
- `RetreatButton` remains a disabled placeholder.
- `v0.67t Bottom Command Button PNG Apply QA` is complete.
- Applied all 6 bottom command PNG files to the bottom global command bar.
- `AutoBattleButton`, `EndTurnButton`, and `RetreatButton` nodes were preserved.
- Existing handlers were unchanged.
- `RetreatButton` remains a disabled placeholder.
- Text overlay is removed only when button image style applies successfully.
- `v0.67s Bottom Command Button Actual Asset Integration` is complete.
- Added `_try_load_texture_or_null()`.
- Added `_apply_button_texture_style_if_available()`.
- Kept actual PNG loading optional and fallback-safe.
- Kept `AutoBattleButton`, `EndTurnButton`, and `RetreatButton` handlers unchanged.
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
