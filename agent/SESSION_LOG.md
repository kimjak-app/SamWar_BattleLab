# SESSION LOG

## 2026-05-25

### v0.67x-7-hotfix1 Defeat Toast Hold Duration 2s
- Increased ally defeat and enemy retreat toast hold time to `2.0s` for both single and queued sequential exits.
- Preserved the existing snapshot queue so cleanup, result checks, turn progression, and full-auto flow remain non-blocking.

### v0.67x-7 Defeat Retreat Toast Actual Apply
- Confirmed the existing retreat toast implementation was enemy-only and generalized it for ally/enemy battle exits.
- Snapshot portrait / name / side / fallback line before cleanup, then play a visible scene-authored toast with separate ally/enemy dialogue pools.
- Verified enemy single exit, ally single exit, mixed simultaneous queue, immediate untargetable cleanup, scene load, and full-auto victory path.

### v0.67x-7 Enemy Retreat Toast Actual Apply
- Confirmed an enemy retreat toast implementation already existed but was a single immediate toast under `BattleUI`, with no snapshot queue.
- Moved the toast to a dedicated scene-authored layer and switched defeat handling to snapshot queued playback before cleanup.
- Verified single enemy defeat, simultaneous two-enemy defeat queue, immediate untargetable cleanup, and full-auto victory path.

### v0.67x-6 Targeting UX + Buff Preview + Retreat Toast Polish
- Added short manual preview before buff unique skills auto-resolve, covering 정도전 and 권율 flows.
- Hid the floating ally command panel during basic attack / unique-skill target selection and restored it after cancel or resolve.
- Strengthened the separate gold/orange valid-target marker over persistent purple range cells.
- Added enemy retreat portrait toast MVP before dead-unit cleanup without blocking battle result or full-auto flow.
- Verified headless project load, scene load, targeting / buff / retreat smoke, full-auto result path, and `git diff --check`.

### v0.67x-5 Unique Skill Regression Fix Gate
- Restored formation-guide `TroopIconRect` nodes to readable `40 x 40` while keeping `UniqueSkillReadyIcon` at `64 x 64`.
- Unified unique skill readiness and auto/enemy decision gates around range-limited valid targets with no 이순신-only special case.
- Fixed 정도전 / 권율 buff unique skill manual resolve/reuse and kept 김유신 attack targeting on the same validation path.
- Limited 유비-style buff skills to in-range unbuffed allies and kept low-value cases falling back to movement/basic attack/wait.
- Split unique skill range overlay display into persistent purple range cells plus separate gold valid-target markers.
- Added short auto/enemy unique skill range preview before resolve.
- Confirmed no project code controls WASAPI/audio output devices.
- Verified headless project load, scene load, regression smoke, and full-auto result path.

## 2026-05-24

### v0.67x-4 Unique Skill Range + Enemy Skill Priority Rebalance
- Restored formation-guide `TroopIconRect` nodes to readable `32 x 32` display while keeping `UniqueSkillReadyIcon` at `64 x 64`.
- Normalized unique skill range helpers so melee unique skills require close engagement and cannon AOE stays mid-range.
- Added high-value and fallback-value checks for enemy/auto unique skill decisions.
- Restored full-auto movement / approach / basic attack pressure instead of using every ready unique skill.
- Kept manual unique skill range/target UX, unique skill toast, large red damage numbers, camera shake, cooldown, and directional damage bonuses intact.
- Deferred detailed unique skill range balance, `SkillInfoPanel`, and tactics status/explanation UI.

### v0.67x-2 Enemy/Auto Unique Skill + Directional Damage Bonus
- Enlarged formation-guide `UniqueSkillReadyIcon` nodes to `64 x 64`.
- Added front / side / back directional damage helpers with `1.0 / 1.15 / 1.3` multipliers.
- Applied directional bonus to basic attacks, enemy hits, and single-target attack unique skills.
- Changed unique skill readiness from one-use flags to cooldown state.
- Added auto battle ally unique skill selection before normal attack / move / wait fallback.
- Added enemy AI unique skill selection on enemy turns and after movement rechecks.
- Kept manual unique skill range/target flow, backdrop cleanup, tooltip cleanup, damage numbers, and camera shake intact.
- Deferred `SkillInfoPanel` and unique skill range balance.

### v0.67x-hotfix2 Unique Skill UX Targeting + Backdrop + Ready Icon Fix
- Removed the `is_visible` shadowing warning in the unique skill ready icon helper.
- Hid the unique skill toast black backdrop so transparent cutin edges remain visible.
- Enlarged formation-guide `UniqueSkillReadyIcon` nodes to `36 x 36`.
- Kept unique skill hover tooltip text suppressed while preserving the button label.
- Changed manual ally unique skill flow to button click -> range/target display -> valid target click -> resolve.
- Added purple skill range cells and gold/orange valid target cells via the existing overlay pool.
- Kept `SkillInfoPanel` deferred.

### v0.67x-1 Unique Skill Hover Cleanup + Ready Icon
- Removed duplicate hover tooltip text from `FloatingUniqueSkillButton` and kept the skill name only inside the button.
- Added `UniqueSkillReadyIcon` nodes to the formation guide cards and only light them for the currently usable active ally.
- Kept unique skill toast / damage number / camera shake / range flow unchanged.
- Deferred `SkillInfoPanel` to the next UX candidate instead of implementing it here.

### v0.67x Unique Skill MVP Per Hero Cutin
- Added current-roster unique skill registry entries for:
  - 이순신
  - 정도전
  - 권율
  - 김유신
  - 을지문덕
  - 관우
  - 장비
  - 하후돈
  - 유비
  - 제갈량
- Connected unique skill cutins under `assets/web_battle/skill_cutins/`.
- Added `UniqueSkillToastRoot` scene nodes for a caster-anchored ink toast.
- Kept the presentation timing at `2200ms`.
- Enabled `FloatingUniqueSkillButton` for active living ally units with available unique skill data.
- Added MVP effects, large red skill damage numbers, camera shake, battle mini-log entries, and action consumption.
- Deferred enemy / auto unique skill use.

### v0.67w Battle Screen Basic UX Stable Lock
- Locked the current MVP battle-screen UX baseline without adding new functionality.
- Verified:
  - `FormationSlotGuideLayer`
  - `AllyFormationGuidePanel`
  - `EnemyFormationGuidePanel`
  - lower-left `BattleMiniLogPanel`
  - `CommandBar` with `BottomCommandBarBackground`
  - `AutoBattleButton`
  - `EndTurnButton`
  - disabled `RetreatButton`
- Confirmed legacy `LeftPanel` / `RightPanel` remain hidden and `UnitCloseupPanel` remains hidden.
- Confirmed formation guide cards keep compact name / troop / troop-icon / troop-type display with no status text regression.
- Confirmed floating command panel, direct move-click, right-click rollback, post-move reopen, active ally pulse pivot lock, reinforcement arrival, and result toast path remain stable.

### v0.67v Bottom Command Bar Background Panel Apply
- Applied `bottom_command_bar_bg.png` as the scene-authored `CommandBar` background.
- Added `BottomCommandBarBackground` `TextureRect` behind the 3 bottom command `TextureButton`s.
- Hid the old black `CommandBar` fill with a transparent panel style override.
- Kept `AutoBattleButton`, `EndTurnButton`, and `RetreatButton` paths and handlers unchanged.
- Kept the layout scene-authored with no runtime size/position forcing.

### v0.67u-3 Formation Guide Card Compact Info Polish
- Hid `UnitCloseupPanel` and kept it reserved for future popup reuse.
- Repacked each ally/enemy formation guide slot into portrait / name / troop / troop-icon / troop-type layout.
- Removed `행동중`, `출전`, `지원대기`, and round-wait status text from the cards.
- Added troop icon + troop type binding with hero/default visual-key fallback.
- Reduced guide-card font sizes and kept active/reserve distinction as style-only.
- Intended scope remained UI-only with no battle-logic change.

### v0.67u Formation Slot Guide Layout MVP
- Hid the large legacy `LeftPanel` / `RightPanel` battle info panels.
- Added `BattleMiniLogPanel` at the lower-left.
- Added `FormationSlotGuideLayer` with:
  - `AllyFormationGuidePanel`
  - `EnemyFormationGuidePanel`
- Added display-only guide slots for main `3` + reinforce `2` per side.
- Reused existing hero/slot/deployed state data without changing battle logic.

### v0.67t-hotfix Bottom Command TextureButton Scene Fix
- Converted `AutoBattleButton`, `EndTurnButton`, and `RetreatButton` from `Button` to scene-authored `TextureButton`.
- Connected the 6 bottom command PNG assets directly in `Battle_Fullscreen_Test.tscn`.
- Removed the bottom-command runtime `StyleBoxTexture` apply path from the active bottom-bar flow.
- Preserved existing handlers.
- Preserved `RetreatButton` as a disabled placeholder.
- Restored bottom command image visibility in the Godot 2D editor.

### v0.67t Bottom Command Button PNG Apply QA
- Confirmed all 6 bottom command PNG files exist.
- Confirmed all 6 PNG files are `512x256` with `Format32bppArgb`.
- Applied bottom command PNG styles to `AutoBattleButton`, `EndTurnButton`, and `RetreatButton`.
- Preserved existing `Button` nodes and existing handlers.
- Preserved `RetreatButton` as a disabled placeholder.
- Cleared button text only when image style apply succeeded, so visual text overlap is removed while missing-file fallback remains safe.
- Expanded the scene-authored bottom `CommandBar` layout for `256x128` display buttons.

### v0.67s Bottom Command Button Actual Asset Integration
- Added `_try_load_texture_or_null()` for safe optional bottom-command PNG loading.
- Added `_apply_button_texture_style_if_available()` and kept `_try_apply_bottom_command_button_art()` as the button-key entry point.
- Kept `AutoBattleButton`, `EndTurnButton`, and `RetreatButton` as existing `Button` nodes with existing handlers unchanged.
- Missing PNG files remain a safe fallback path with no load error and no intended behavior change.

### v0.67r Bottom Command Bar Art Asset Structure Prep
- Confirmed the bottom global command bar currently uses `Button` nodes:
  - `AutoBattleButton`
  - `EndTurnButton`
  - `RetreatButton`
- Confirmed existing pressed handlers are reused:
  - `AutoBattleButton` -> `_toggle_full_auto_battle`
  - `EndTurnButton` -> `_end_ally_turn_by_wait`
  - `RetreatButton` remains a disabled placeholder
- Added `assets/web_battle/ui/bottom_command/README.md`.
- Added optional runtime bottom-command art path mapping and safe apply helper.
- Missing PNG files now remain a safe no-op instead of a load dependency.
- No behavior change intended for direct move-click, floating panel flow, active ally pulse, or `5v5` battle flow.

### v0.67-docs Agent Docs Slimdown
- Created `agent/archive/v0.67-docs_agent_docs_slimdown/`.
- Preserved full pre-slimdown copies of:
  - `CURRENT_STATE.md`
  - `CHANGELOG.md`
  - `SESSION_LOG.md`
- Rewrote top-level `agent` docs into shorter operational documents centered on the current stable baseline `v0.67p-3-hotfix3 Active Ally Pulse Pivot Lock QA Stable`.
- Removed top-level priority confusion from older `v0.67k` baseline references while leaving archived history intact.

### Current stable reference
- `v0.67x-4 Unique Skill Range + Enemy Skill Priority Rebalance`
- Stable `5v5` battle loop
- Stable formation guide + mini log + bottom command bar + floating command panel MVP screen composition
- Stable ally manual / auto / enemy unique skill MVP with caster-anchored cutin toast
- Stable directional damage bonus for front / side / back attacks
- Stable reinforcement / round / result toast flow
- Stable floating command panel, bottom command bar, direct move-click UX, rollback, post-move reopen, and active ally pivot-locked root pulse

## Archive
- Full older session history moved to:
  - `agent/archive/v0.67-docs_agent_docs_slimdown/SESSION_LOG_full_before_slimdown.md`
