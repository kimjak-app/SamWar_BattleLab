# CURRENT STATE

## Project
SamWar_BattleLab

## Current Stable Baseline
`v0.67x-4 Unique Skill Range + Enemy Skill Priority Rebalance`

## Current Implementation Step
- `v0.67x-4 Unique Skill Range + Enemy Skill Priority Rebalance`
- `v0.67x-2 Enemy/Auto Unique Skill + Directional Damage Bonus`
- `v0.67x-hotfix2 Unique Skill UX Targeting + Backdrop + Ready Icon Fix`
- `v0.67x-1 Unique Skill Hover Cleanup + Ready Icon`
- `v0.67x Unique Skill MVP Per Hero Cutin`
- `v0.67w Battle Screen Basic UX Stable Lock`
- `v0.67v Bottom Command Bar Background Panel Apply`
- `v0.67u-3 Formation Guide Card Compact Info Polish`
- `v0.67u Formation Slot Guide Layout MVP`
- Legacy large `LeftPanel` / `RightPanel` info panels are now deprecated/hidden.
- `BattleMiniLogPanel` and left/right formation slot guide panels are added.
- Formation guide is display-only and limited to main `3` + reinforce `2` per side.
- Existing bottom command handlers are reused with no intended behavior change.

## Stable Summary
- Current battle target is stable `5v5`.
- `5v5` battle loop stable.
- Enemy AI multi-target engagement improved and treated as stable.
- Victory / defeat toast stable.
- Reinforcement toast stable.
- Bottom global command bar exists.
- Bottom command bar art-prep folder/README exists.
- Bottom command buttons now render as scene-authored image buttons in the editor and runtime.
- `bottom_command_bar_bg.png` is now applied as the scene-authored `CommandBar` background.
- Old black `CommandBar` panel fill is hidden behind a transparent panel style.
- Bottom command bar background is considered MVP-sufficient and future tuning is polish-only.
- `UnitCloseupPanel` is now hidden/reserved for later popup reuse.
- Formation guide cards now use compact name / troop / troop-icon / troop-type layout.
- Formation guide status text is removed and active/reserve distinction is style-only.
- Current battle-screen MVP UX is locked around formation guides + mini log + bottom command bar + floating command panel.
- Current battle's `10` heroes now have `hero_id`-based unique skill registry entries.
- Ally manual unique skill use is enabled from the floating command panel.
- Floating unique skill button hover no longer shows duplicate tooltip text over the button.
- Formation guide cards now show an enlarged unique-skill-ready icon only for the currently usable active ally.
- Unique skill button now enters range/target selection first; the skill resolves only after a valid target click.
- Unique skill range uses purple cells and valid targets use gold/orange cells.
- Unique skill toast no longer shows the old black rectangular backdrop.
- Unique skill presentation uses a world-anchored ink toast over the caster for `2200ms`, with cutin image and skill name text.
- Unique skill damage uses larger red damage numbers and short camera shake.
- Auto battle can now use available ally unique skills before normal attack/move/wait fallback.
- Enemy AI can now use available unique skills on enemy turns and after movement rechecks.
- Unique skill range overreach is first-normalized so melee skills require close engagement and AOE stays mid-range.
- Enemy/auto unique skill priority now requires high-value or fallback-value conditions instead of using skills just because they are ready.
- Enemy movement / approach / basic attack pressure is restored in full-auto flow.
- Unique skill cooldown state is cooldown-based instead of one-use flag based.
- Directional damage bonus is applied to basic attacks, enemy counter/basic hits, and single-target attack unique skills.
- Directional multipliers follow the web baseline: front `1.0`, side `1.15`, back `1.3`.
- Formation guide unique-skill-ready icon display size is now `64 x 64`.
- Formation guide troop icons are restored to readable `32 x 32` display while the `UniqueSkillReadyIcon` remains `64 x 64`.
- `SkillInfoPanel` is deferred as a later UX candidate.
- Detailed unique skill range / radius balance remains a later pass.
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
  - `고유특기`
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
1. `v0.67y Tactics MVP`
2. `v0.67y-2 Tactics Fire / Defense Expansion`
3. `v0.68 Terrain Block Layer MVP`

## Known / Deferred
- Detailed unique skill range balance can still be revisited after more skill data is final.
- `SkillInfoPanel` remains deferred until unique skill text/effect wording is stable.
- Tactics explanations and status icons belong to the Tactics MVP track.

## Archive
- Full historical copies preserved at:
  - `agent/archive/v0.67-docs_agent_docs_slimdown/CURRENT_STATE_full_before_slimdown.md`
  - `agent/archive/v0.67-docs_agent_docs_slimdown/CHANGELOG_full_before_slimdown.md`
  - `agent/archive/v0.67-docs_agent_docs_slimdown/SESSION_LOG_full_before_slimdown.md`
