# CURRENT STATE

## Project
SamWar_BattleLab

## Current Stable Baseline
Behavior baseline: `v0.67z-3 Strategy Status Badge Near Facing Arrow Patch`

Docs/contract baseline: `v0.68 Agent Contract Split for WorldMap + Hero Scale Prep`

## Current Implementation Step
- `v0.68 Agent Contract Split for WorldMap + Hero Scale Prep`
- `v0.67z-4 Agent Role Split Foundation`
- `v0.67z-3 Strategy Status Badge Near Facing Arrow Patch`
- `v0.67z-2 Deployment Anchor Source Unification`
- `v0.67z Unit Visual Attachment / Manual Layout Control Patch`
- `v0.67y-3 Web Defend Command + Formation Status Layout Guard`
- `v0.67y-2-hotfix1 Status Icon Readability Fix`
- `v0.67y-2 Web Defend Command Port + Status Icon Tone Polish`
- `v0.67y-1-hotfix1 Unified Status Display + Toast Fade Polish`
- `v0.67y-1 Strategy Status UX + Result Sequence Fix`
- `v0.67y Web Strategy Port MVP`
- `v0.67x-7-hotfix4 Defeat Toast Duration + Size Tune`
- `v0.67x-7-hotfix3 Defeat Toast Actual 3s Hold Fix`
- `v0.67x-7-hotfix2 Defeat Toast 3s + Hakikjin Range Sync`
- `v0.67x-7-hotfix1 Defeat Toast Hold Duration 2s`
- `v0.67x-7 Defeat Retreat Toast Actual Apply`
- `v0.67x-7 Enemy Retreat Toast Actual Apply`
- `v0.67x-6 Targeting UX + Buff Preview + Retreat Toast Polish`
- `v0.67x-5 Unique Skill Regression Fix Gate`
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
- Worldmap / hero / army / BattleContext / battle engine / skill contract docs now define the future system boundaries for larger hero scale and worldmap battle launch.
- The battle engine is documented as a `BattleContext.roster` consumer and must not choose heroes directly.
- Worldmap / army systems are documented as owners of encounter creation, battle type, terrain, region, and `map_variant_id` selection.
- Current implementation remains battle-engine-centric MVP, but future architecture is worldmap -> battle_context -> battle_engine.
- Role-based agent docs are complete.
- Worldmap / hero-scale prep contract docs are complete.
- Role-based agent docs now split architecture, implementation, QA, runtime QA, visual QA, and workflow manager responsibilities without changing code, scenes, or assets.
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
- Floating `책략` command is enabled for eligible ally units with intelligence-based range, success rate, and outcome tiers.
- Manual 책략 uses cyan range cells and cyan valid-target markers, then applies `혼란` or `동요` status on success.
- `혼란` skips the affected unit's action, and status turns now decrease after the affected unit acts or skips.
- `동요` applies a light attack/defense penalty through the shared directional damage helper.
- Unit markers and formation guide status labels now use one shared status display formatter for strategy statuses and unique-skill buffs.
- Confusion unit badges now include a non-numeric icon fallback (`◎N`) instead of showing a bare turn number.
- Defense / defense-buff status uses steel-blue `◆`, while attack-up uses amber `▲` on unit badges and formation status text.
- Unique-skill attack / defense buffs show distinct `▲` / `◆` unit badges and readable formation-guide status text.
- Floating command panel now uses the former move slot as a manual `방어` command; direct move-click remains the movement path.
- Manual defend sets `is_defending`, consumes the unit action, shows `◆ 방어!`, immediately recovers `10%` of missing troops, and reduces incoming directional-helper damage while active.
- Defending units show a short `◆ 방어` reaction when hit.
- Formation guide status text now uses one-line compact summaries with `외 N` overflow guarding.
- Status badge/text alpha is toned down for a less harsh battle-screen read.
- Last-unit defeat/retreat toasts now finish before victory/defeat result toast display.
- Enemy/auto 책략 use is deferred to `v0.67y-2 Strategy AI/Auto Expansion`.
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
- Formation guide troop icons are kept within-card at `46 x 46` display with stronger troop-type text while the `UniqueSkillReadyIcon` remains `64 x 64`.
- Deployment marker anchoring now syncs from scene-authored `Slot` / `UnitVisualRoot` movement before demo state creation and marker-to-grid-cell sync, so moving a slot/root in the Godot 2D editor changes the actual runtime deployment source as well as token, portrait, HP bar, troop label, shadow, move dust, click area, READY frame, facing indicator, and status badges.
- `UnitMarker` and `PortraitMarker` nodes are retained as compatibility runtime sync targets; they are not the manual layout source of truth for the active `5v5` visual slots.
- Click areas remain scene-level `Area2D` nodes for compatibility, but their runtime positions are now applied from the `UnitVisualSlot` registry with root-relative global positioning.
- READY frames, facing indicators, and status badges remain UI/FX layer overlays, but they resolve from the same slot-synced visual anchor instead of independent fixed placement.
- Battlefield status badges now position from the facing indicator line instead of a fixed right-side unit offset, keeping defense/buff/debuff/confusion/shake icons close to the arrow and portrait line.
- Unique skill readiness, target collection, manual resolve, and auto/enemy value gates now share range-limited valid target checks.
- Ally buff unique skills resolve immediately after range preview and only affect valid in-range, unbuffed allies.
- Manual buff unique skills now show a short range / valid target preview before auto-resolving.
- Unique skill range overlay keeps purple range cells visible and adds a separate gold target marker on valid target cells.
- Valid-target markers are enlarged and strengthened for clearer gold/orange read over purple range cells.
- Floating ally command panel hides during attack / unique-skill target selection and restores after cancel / resolve.
- Auto/enemy unique skill use shows a short visual range preview before resolving.
- Defeated ally/enemy units now snapshot portrait / name / side / fallback line before cleanup and show a visible defeat-retreat toast on a dedicated scene-authored layer.
- Ally and enemy battle-exit toasts use separate fallback dialogue pools, with `1.2s` first display and `1.0s` queued follow-up display.
- Defeat-retreat toast fade-out is chained after the configured hold instead of running in parallel with the hold interval.
- Defeat-retreat toast panel, portrait, name, and dialogue text are reduced to a less intrusive mid-size presentation.
- Multiple unit defeats in one cleanup enqueue defeat-retreat toasts sequentially without blocking dead-unit cleanup, targeting exclusion, result toasts, or full-auto flow.
- 이순신 학익진 포격 now uses the same caster-range target helper for valid markers and actual damage targets.
- WASAPI output-device warnings are treated as external Godot/Windows audio warnings because the project does not control audio devices directly.
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

## Contract Docs
- `agent/WORLDMAP_RULES.md`
- `agent/HERO_DATA_CONTRACT.md`
- `agent/ARMY_DEPLOYMENT_RULES.md`
- `agent/BATTLE_CONTEXT_CONTRACT.md`
- `agent/BATTLE_ENGINE_RULES.md`
- `agent/SKILL_SYSTEM_RULES.md`

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
  - `방어`
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
1. `v0.68b WorldMap Region Graph MVP`
2. `v0.68c BattleContext Runtime Injection MVP`
3. `v0.68d Hero/Army Deployment MVP`
4. `v0.69 Battlefield Variant Loader`
5. `v0.69b Naval Battle Entry MVP`

## Known / Deferred
- 김작 F6 visual QA should confirm left-facing and right-facing units keep status badges near the facing arrow, with up/down facings still close to the portrait/arrow line and not fully overlapping the face.
- Codex Godot headless verification for `v0.67z-3` was blocked by the tool sandbox `windows sandbox: spawn setup refresh` error; 김작 local F6/headless QA should confirm the scene load path.
- 김작 F6 visual QA still needs to confirm that moving `Slots/AllyReinforce01Slot` or its `AllyReinforce01UnitVisualRoot` changes 김유신's ROUND 2 spawn position and keeps HP/troop/portrait/click/facing/status alignment natural.
- Detailed unique skill range balance can still be revisited after more skill data is final.
- `SkillInfoPanel` remains deferred until unique skill text/effect wording is stable.
- Tactics explanations and status icons belong to the Web Strategy Port MVP track.

## Archive
- Full historical copies preserved at:
  - `agent/archive/v0.67-docs_agent_docs_slimdown/CURRENT_STATE_full_before_slimdown.md`
  - `agent/archive/v0.67-docs_agent_docs_slimdown/CHANGELOG_full_before_slimdown.md`
  - `agent/archive/v0.67-docs_agent_docs_slimdown/SESSION_LOG_full_before_slimdown.md`
