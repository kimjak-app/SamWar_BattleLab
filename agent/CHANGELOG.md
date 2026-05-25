# CHANGELOG

## v0.67z-3 Strategy Status Badge Near Facing Arrow Patch
- Changed battlefield status badge placement from a fixed right-side unit offset to a facing-indicator-based position.
- Left-facing units now place status badges to the right of the arrow, while right-facing units place them to the left.
- Up/down facings choose the near side of the arrow/portrait line so badges stay visually attached to the unit.
- Kept status text, colors, strategy effects, defend effects, marker/slot structure, and battlefield size unchanged.

## v0.67z-2 Deployment Anchor Source Unification
- Synced all active `5v5` deployment `UnitMarker` nodes from scene-authored `Slot` / `UnitVisualRoot` anchors before demo state creation and marker-to-grid-cell sync.
- Added slot-id based helpers for resolving unit markers, portrait markers, visual roots, portraits, and visual anchors without hardcoded new coordinates.
- Kept `UnitMarker` and `PortraitMarker` nodes as compatibility runtime sync targets rather than deleting or reparenting them.
- Left 김작 F6 visual QA for `Slots/AllyReinforce01Slot` ROUND 2 김유신 spawn alignment and related HP/troop/portrait/click/facing/status positioning.

## v0.67z Unit Visual Attachment / Manual Layout Control Patch
- Synced unit markers from scene-authored `UnitVisualRoot` global movement at runtime start so Godot 2D editor slot/root movement becomes the shared unit visual anchor.
- Changed unit group offset application to write global positions, preserving root/slot-relative movement for token, portrait, HP bar, troop label, shadow, and move dust nodes.
- Kept click areas as compatibility `Area2D` nodes but positioned them through the `UnitVisualSlot` anchor and captured scene-authored offsets.
- Kept READY frames, facing indicators, and status badges in UI/FX layers while resolving their positions from the same slot-synced visual anchor.

## v0.67y-3 Web Defend Command + Formation Status Layout Guard
- Added manual defend wounded-troop recovery for `10%` of missing troops, with a green floating recovery number and updated mini-log text.
- Added a short `◆ 방어` hit reaction for defending units when they take basic or single-target unique-skill damage.
- Changed formation-guide status summaries to compact one-line text with `외 N` overflow guarding.
- Reduced formation-guide troop icon bounds to `46 x 46` and adjusted troop/status label sizing so status text and troop art do not collide.
- Enlarged the battle mini-log panel slightly and increased its text area for the new defend/recovery log lines.

## v0.67y-2-hotfix1 Status Icon Readability Fix
- Changed confusion unit badges from bare turn numbers to `◎N` so the status meaning remains visible.
- Split status tones so defense `◆` uses steel blue and attack-up `▲` uses amber on battlefield badges and formation status lines.
- Enlarged formation troop icons to `56 x 56` and strengthened troop-type text contrast for faster class reading.

## v0.67y-2 Web Defend Command Port + Status Icon Tone Polish
- Replaced the floating panel move slot with a manual `방어` command while keeping direct move-click unchanged.
- Added `is_defending` / defend last-action state, immediate action consume, defend floating text, and mini-log output.
- Applied defend incoming-damage reduction through the existing directional damage helper and cleared defend on action-lock reset.
- Updated status display tone and icon rules so defend/defense use `◆`, attack buffs use `▲`, and status text/badges are less harsh.

## v0.67y-1-hotfix1 Unified Status Display + Toast Fade Polish
- Unified unit/formation status display through shared formatter entries for strategy statuses and unique-skill buffs.
- Added `◆` unit badges and formation-guide text for active unique-skill attack / defense buffs.
- Changed confusion unit badge from `혼N` style to icon-style `N`, while shake remains `⚠N`.
- Polished defeat-retreat toast hide with a short `0.18s` fade plus subtle scale/position settle after hold.

## v0.67y-1 Strategy Status UX + Result Sequence Fix
- Tuned defeat-retreat toast hold to `1.2s` for the first exit and `1.0s` for queued follow-ups, keeping fade-out after hold.
- Enlarged battlefield strategy status icons, added formation-guide status summaries, and enlarged troop icons to `52 x 52`.
- Applied a light `동요` attack/defense penalty through shared damage calculation.
- Deferred victory/defeat result toast display until defeat-retreat toast playback finishes, and moved strategy status turn decrease to after action/skip resolution.

## v0.67y Web Strategy Port MVP
- Ported the web single `strategy` command into the floating `책략` button for manual ally use.
- Added intelligence-based strategy range / tier / success-rate / outcome helpers and cyan range + valid-target markers.
- Added `혼란` / `동요` status storage, max-turn refresh, compact unit/formation status icons, floating effects, and mini-log entries.
- `혼란` now skips affected ally/enemy actions; enemy/auto strategy casting is deferred to `v0.67y-2 Strategy AI/Auto Expansion`.

## v0.67x-7-hotfix4 Defeat Toast Duration + Size Tune
- Tuned ally defeat and enemy retreat toast hold time from `3.0s` to `1.5s`, including queued exits.
- Reduced the defeat-retreat toast panel, portrait, name text, and dialogue text for a less intrusive battle-screen footprint.
- Kept SHOW / HOLD_DONE / HIDE elapsed logs and the non-blocking snapshot queue intact.

## v0.67x-7-hotfix3 Defeat Toast Actual 3s Hold Fix
- Fixed defeat-retreat toast tween sequencing so fade-out starts after the `3.0s` hold instead of overlapping it.
- Added DEBUG-gated SHOW / HOLD_DONE / HIDE elapsed logs for actual portrait/name/dialogue toast lifetime checks.
- Kept snapshot queue, cleanup, result checks, turn flow, and full-auto progression non-blocking.

## v0.67x-7-hotfix2 Defeat Toast 3s + Hakikjin Range Sync
- Increased ally defeat and enemy retreat toast hold time to `3.0s`, including queued sequential exits.
- Changed 학익진 포격 damage targets to use the same caster-range valid-target helper as range overlay and target markers.
- Kept snapshot toast queue, unique skill cooldown/action flow, and full-auto progression non-blocking.

## v0.67x-7-hotfix1 Defeat Toast Hold Duration 2s
- Increased ally defeat and enemy retreat toast hold time to `2.0s`, including sequential queued exits.
- Kept the existing snapshot queue non-blocking for cleanup, result checks, full-auto flow, and turn progression.

## v0.67x-7 Defeat Retreat Toast Actual Apply
- Generalized the existing enemy retreat toast into an ally/enemy defeat-retreat toast queue.
- Snapshot portrait / name / side / fallback line before cleanup so battle-exit messages remain visible even after units are removed.
- Added separate ally defeat and enemy retreat dialogue pools with `1.25s` default hold and `1.05s+` queued playback.
- Kept dead-unit cleanup, untargetable state, victory/defeat result checks, and full-auto flow non-blocking.

## v0.67x-7 Enemy Retreat Toast Actual Apply
- Moved the existing enemy retreat toast UI onto a dedicated scene-authored `EnemyRetreatToastLayer` so it is actually visible over battle/result UI.
- Changed enemy defeat handling to snapshot portrait / name / fallback line before visual cleanup.
- Added a sequential enemy retreat toast queue for simultaneous defeats, capped per cleanup to preserve battle tempo.
- Kept dead-unit cleanup, untargetable state, victory/defeat result checks, and full-auto flow non-blocking.

## v0.67x-6 Targeting UX + Buff Preview + Retreat Toast Polish
- Added manual buff unique-skill range / valid-target preview before auto-resolve for 정도전 / 권율 style skills.
- Hid the floating ally command panel during attack and unique-skill targeting, then restored it after cancel / resolve.
- Strengthened gold/orange valid-target markers while keeping purple unique-skill range cells visible.
- Added an enemy retreat toast MVP with portrait, name, and short fallback line before normal dead-unit cleanup continues.
- Verified full-auto result flow still reaches victory/defeat with unique-skill previews and retreat toasts active.

## v0.67x-5 Unique Skill Regression Fix Gate
- Restored formation-guide troop icons to readable `40 x 40` while preserving `UniqueSkillReadyIcon` at `64 x 64`.
- Unified unique skill readiness / valid target / auto-enemy value checks around range-limited targets.
- Fixed 정도전 / 권율 buff unique skill manual resolve and reuse by resolving buff skills immediately and applying only to valid in-range allies.
- Kept 김유신 and other attack unique skills on the same target validation path.
- Limited 유비-style buff use to valuable in-range unbuffed allies and preserved basic attack / move / wait fallback.
- Changed unique skill overlay so purple range cells remain visible with separate gold valid-target markers.
- Added a short auto/enemy unique skill range preview before resolve.
- Documented WASAPI output-device warnings as external Godot/Windows audio-device warnings, not battle logic errors.

## v0.67x-4 Unique Skill Range + Enemy Skill Priority Rebalance
- Restored formation-guide troop icon readability while keeping the `UniqueSkillReadyIcon` at `64 x 64`.
- First-normalized unique skill ranges so melee skills require close engagement and AOE skills remain mid-range.
- Reduced enemy/auto unique skill overuse with high-value and fallback-value checks before skill use.
- Restored enemy movement / approach / basic attack pressure in full-auto battle flow.
- Preserved directional damage bonus behavior with front `1.0`, side `1.15`, back `1.3`.
- Kept `SkillInfoPanel`, detailed unique skill range balance, and tactics status/explanation UI deferred.

## v0.67x-2 Enemy/Auto Unique Skill + Directional Damage Bonus
- Enabled auto battle ally unique skill use before normal attack / move / wait fallback.
- Enabled enemy AI unique skill use on enemy turns and after movement rechecks.
- Replaced one-use unique skill gating with cooldown-state readiness.
- Applied directional damage bonus to basic attacks, enemy hits, and single-target attack unique skills.
- Matched web directional multipliers: front `1.0`, side `1.15`, back `1.3`.
- Enlarged formation-guide `UniqueSkillReadyIcon` display to `64 x 64`.
- Kept unique skill range balance and `SkillInfoPanel` deferred.

## v0.67x-hotfix2 Unique Skill UX Targeting + Backdrop + Ready Icon Fix
- Removed the `is_visible` parameter shadowing warning in the formation guide ready icon helper.
- Hid the unique skill toast black rectangular backdrop while preserving the cutin image and skill name.
- Kept `FloatingUniqueSkillButton` hover tooltip text empty while preserving the button label.
- Enlarged the formation-guide `UniqueSkillReadyIcon` to `36 x 36`.
- Changed ally manual unique skill UX to enter range/target selection first and resolve only after a valid target click.
- Added purple unique skill range cells and gold/orange valid target cells using the existing overlay pool.
- Kept `SkillInfoPanel` deferred to a future pass.

## v0.67x-1 Unique Skill Hover Cleanup + Ready Icon
- Removed duplicate hover tooltip text from `FloatingUniqueSkillButton` while keeping the button label itself visible.
- Added a small `UniqueSkillReadyIcon` to ally/enemy formation guide slots and only show it for the currently usable active ally.
- Kept `SkillInfoPanel` deferred to the next UX pass instead of adding a new panel in this patch.
- No battle logic change intended.

## v0.67x Unique Skill MVP Per Hero Cutin
- Added `10` hero unique skill registry entries for the current battle roster.
- Linked the `6` new cutin images plus existing Yi Sunsin / Jeong Dojeon / Guan Yu / Zhang Fei cutins.
- Enabled ally manual unique skill use through the floating command panel.
- Added a world-anchored ink unique skill toast with cutin image, skill name text, and `2200ms` display timing.
- Added MVP effects for cannon AOE, ally attack buff, self-defense single strike, and single damage with adjacent shake.
- Added larger red unique skill damage numbers and short camera shake for unique skills only.
- Enemy / auto unique skill use remains deferred.

## v0.67w Battle Screen Basic UX Stable Lock
- Locked the current battle-screen MVP UX as the stable baseline.
- Verified the battle UI structure around ally/enemy formation guides, lower-left mini log, bottom command bar, and floating command panel.
- Confirmed legacy large side panels remain hidden and `UnitCloseupPanel` remains hidden.
- Confirmed bottom command `TextureButton` handlers, direct move-click, rollback, post-move reopen, active ally pulse pivot lock, reinforcement flow, and result toast flow remain stable.
- No battle logic change intended.

## v0.67v Bottom Command Bar Background Panel Apply
- Applied `bottom_command_bar_bg.png` as the scene-authored `CommandBar` background.
- Added `BottomCommandBarBackground` under `BattleUI/CommandBar`.
- Hid the old black `Panel` fill by overriding the `CommandBar` panel style to transparent.
- Preserved `AutoBattleButton`, `EndTurnButton`, and `RetreatButton` handlers and layout.
- No battle logic change intended.

## v0.67u-3 Formation Guide Card Compact Info Polish
- Hid `UnitCloseupPanel` while preserving its node structure for later reuse.
- Reworked ally/enemy formation guide cards into compact portrait / name / troop / troop-icon / troop-type layout.
- Removed card status text and kept active/reserve distinction through visual styling only.
- Reduced guide-card text sizes for a tighter strategy UI read.
- Reused existing token textures and hero visual fallback data for troop icon rendering.
- No battle logic change intended.

## v0.67u Formation Slot Guide Layout MVP
- Hid/deprecated the large legacy `LeftPanel` and `RightPanel` info panels.
- Added `BattleMiniLogPanel`.
- Added ally/enemy formation slot guide panels for main `3` + reinforce `2` per side.
- Kept the guide display-only with no click behavior and no battle logic changes.

## v0.67t-hotfix Bottom Command TextureButton Scene Fix
- Converted the 3 bottom command buttons from `Button` to scene-authored `TextureButton`.
- Connected the 6 PNG assets directly in `Battle_Fullscreen_Test.tscn`.
- Restored bottom command button visibility in the Godot 2D editor.
- Kept existing handlers unchanged and kept `RetreatButton` as a disabled placeholder.

## v0.67t Bottom Command Button PNG Apply QA
- Applied the 6 real bottom-command PNG files to the bottom global command bar.
- Kept `AutoBattleButton`, `EndTurnButton`, and `RetreatButton` as existing `Button` nodes with existing handlers unchanged.
- `RetreatButton` remains a disabled placeholder.
- Button text is cleared only when image style apply succeeds, so text overlap is avoided without breaking fallback behavior.

## v0.67s Bottom Command Button Actual Asset Integration
- Added safe bottom-command art helpers for real optional PNG loading.
- Kept `Button` nodes and existing handlers unchanged.
- Missing PNG files remain a safe fallback path with no intended behavior change.

## v0.67r Bottom Command Bar Art Asset Structure Prep
- Prepared `assets/web_battle/ui/bottom_command/README.md` and the planned button PNG naming structure.
- Kept `AutoBattleButton`, `EndTurnButton`, and `RetreatButton` as existing `Button` nodes.
- Reused existing handlers with no intended behavior change.
- Added optional bottom-command art mapping in runtime code.
- If the PNG files are absent, the project keeps current button behavior and avoids load errors.

## v0.67-docs Agent Docs Slimdown
- Slimmed top-level `agent` docs for faster Codex session startup and wrap-up.
- Preserved full pre-slimdown history in:
  - `agent/archive/v0.67-docs_agent_docs_slimdown/CURRENT_STATE_full_before_slimdown.md`
  - `agent/archive/v0.67-docs_agent_docs_slimdown/CHANGELOG_full_before_slimdown.md`
  - `agent/archive/v0.67-docs_agent_docs_slimdown/SESSION_LOG_full_before_slimdown.md`
- Rebased top-level operational docs on the current stable baseline `v0.67p-3-hotfix3 Active Ally Pulse Pivot Lock QA Stable`.

## v0.67p-3-hotfix3 Active Ally Pulse Pivot Lock QA Stable
- Stable baseline locked around unified root active-ally pulse with pivot lock and clean restore.
- Floating command panel remains hidden at ally turn start, opens on active ally click, and auto-reopens after movement + facing completion.
- Direct move-click UX, floating panel behavior, bottom command bar, reinforcement toast, result toast, and `5v5` result path remain stable.
- `GDScript` warning count expected `0`.

## v0.67p-1 to v0.67p-3 UX Summary
- Bottom command bar simplified to global commands.
- Floating command panel added and stabilized as the active ally command surface.
- Direct move-click was restored and stabilized.
- Floating panel opacity/layer priority were stabilized.
- Active ally pulse replaced ally-turn-start auto-open as the primary active-unit emphasis.
- Post-move floating panel auto-reopen was stabilized.

## v0.67m-1 Result Toast Tuning Summary
- Victory / defeat result toast scale and hold duration were increased on the shared battle toast queue.
- Reinforcement toast and round-start toast behavior remained stable.

## v0.67k-5 Enemy AI Multi-Target Engagement Fix Summary
- Enemy AI reservation and fallback-target planning were improved for multi-target battles.
- Rear / distant enemies can now continue engagement planning instead of passively idling in the validated smoke path.
- This is completed stable history, not the current active task.

## Older History
- Older detailed history is archived at `agent/archive/v0.67-docs_agent_docs_slimdown/CHANGELOG_full_before_slimdown.md`.
