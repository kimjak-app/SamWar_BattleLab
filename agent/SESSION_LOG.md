# SESSION LOG

## 2026-05-22

Starting baseline:
- v0.67k Auto Battle Step Limit 5v5 Sustain Fix

Goal:
- v0.67k Battle Hero Identity Source of Truth Scaffold

Completed:
- Added runtime `HERO_REGISTRY` for the current `10` battle heroes.
- Added `TEST_BATTLE_ROSTER` as the temporary slot-to-hero contract scaffold.
- Routed `assigned_hero_id` for all current battle slots through `capacity_slot_metadata_registry`.
- Added hero-identity helpers:
  - `_get_hero_id_for_unit_state()`
  - `_get_hero_registry_entry()`
  - `_apply_hero_identity_to_unit()`
  - `_apply_all_hero_identities()`
  - `_load_texture_or_null()`
- Added runtime identity validation logging through `_validate_hero_identity_bindings()`.
- Applied runtime hero identity from `hero_id` rather than trusting scene portrait texture:
  - `display_name`
  - battlefield portrait badge texture
  - closeup portrait texture lookup
- Confirmed current roster contract:
  - ally `main_01/02/03` = 이순신 / 정도전 / 권율
  - ally `reinforce_01/02` = 김유신 / 을지문덕
  - enemy `main_01/02/03` = 관우 / 장비 / 하후돈
  - enemy `reinforce_01/02` = 유비 / 제갈량
- Kept `Battle_Fullscreen_Test.tscn` unchanged in this step.
- Kept `scripts/unit_visual_slot.gd` unchanged.
- Updated:
  - `agent/CURRENT_STATE.md`
  - `agent/NEXT_TASKS.md`
  - `agent/CHANGELOG.md`
  - `agent/SESSION_LOG.md`

QA:
- Headless project launch exit code `0`.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code `0`.
- Startup validation reports `IDENTITY_OK` for the current `10` battle slots.
- Existing reinforce round structure remains `3v3 -> 4v4 -> 5v5` on the headless path.

Remaining tasks:
- Reinforcement Arrival Toast MVP
- 5v5 Battle Sustain QA

Starting baseline:
- v0.67j-5 MVP 5v5 QA Stable

Goal:
- v0.67k Auto Battle Step Limit 5v5 Sustain Fix

Completed:
- Audited the current full-auto battle safety-cap path.
- Confirmed the previous fixed cap was `AUTO_BATTLE_MAX_STEPS = 40`.
- Replaced the fixed cap with dynamic budgeting based on deployed alive unit count.
- Added:
  - `AUTO_BATTLE_MIN_MAX_STEPS = 80`
  - `AUTO_BATTLE_STEP_BUDGET_PER_DEPLOYED_UNIT = 16`
  - `AUTO_BATTLE_ABSOLUTE_MAX_STEPS = 200`
  - `_get_auto_battle_max_steps()`
- Updated the safety-stop log message to a clearer `자동전투 안전 제한 도달 ...` form.
- Confirmed computed budgets:
  - round `1` alive `6` -> `96`
  - round `2` alive `8` -> `128`
  - round `3` alive `10` -> `160`
- Confirmed round `3` actor candidates ally/enemy remain `5/5`.
- Confirmed round `3` target candidates ally/enemy remain `5/5`.
- Confirmed headless project launch exit code `0`.
- Confirmed headless `Battle_Fullscreen_Test.tscn` launch exit code `0`.
- Did not modify:
  - `Battle_Fullscreen_Test.tscn`
  - `scripts/unit_visual_slot.gd`
- Updated:
  - `agent/CURRENT_STATE.md`
  - `agent/NEXT_TASKS.md`
  - `agent/CHANGELOG.md`
  - `agent/SESSION_LOG.md`

QA:
- Headless project launch passed.
- Headless `Battle_Fullscreen_Test.tscn` launch passed.
- Headless budget verification confirms the dynamic cap scales with `6 / 8 / 10` deployed alive units.
- Editor-side confirmation for uninterrupted end-to-end full-auto completion remains the next manual QA task.

Remaining tasks:
- 5v5 Battle Sustain QA
- Auto battle editor-side stop responsiveness QA

## 2026-05-22

Starting baseline:
- v0.67j-4 Reinforce02 City-Origin Entry Prototype

Goal:
- v0.67j-5 MVP 5v5 QA Stable

Completed:
- Revalidated the current MVP battle shape as documentation/verification only.
- Confirmed no code, scene, or asset changes were made in this step.
- Fixed the active MVP battle target to `5v5`.
- Confirmed side composition:
  - `3` main
  - `2` city-origin reinforce
- Confirmed round progression:
  - round `1` = `3v3`
  - round `2` = `4v4`
  - round `3` = `5v5`
- Confirmed deployed alive count progression:
  - `6 -> 8 -> 10`
- Confirmed round `3` actor candidates ally/enemy = `5/5`.
- Confirmed round `3` target candidates ally/enemy = `5/5`.
- Confirmed reinforce01 / reinforce02 visual display is normal:
  - unit token
  - portrait badge
  - HP bar
  - troop label
- Confirmed click / target behavior remains normal after reinforce deployment.
- Confirmed auto battle remains normal on the current MVP structure.
- Confirmed headless project launch exit code `0`.
- Confirmed headless `Battle_Fullscreen_Test.tscn` launch exit code `0`.
- Updated:
  - `agent/CURRENT_STATE.md`
  - `agent/NEXT_TASKS.md`
  - `agent/CHANGELOG.md`
  - `agent/SESSION_LOG.md`

QA:
- Documentation-only step.
- Headless verification results were adopted from the current validated `5v5` prototype state.
- Manual `F6` sustain QA remains the next editor-side task.

Remaining tasks:
- 5v5 Battle Sustain QA
- Auto battle editor-side stop responsiveness QA

## 2026-05-22

Starting baseline:
- v0.67j-3 City Reinforcement Contract Scaffold Stable

Goal:
- v0.67j-4 Reinforce02 City-Origin Entry Prototype

Completed:
- Verified clean worktree before starting this implementation step.
- Added real reinforce02 scene scaffold under:
  - `Slots/AllyReinforce02Slot`
  - `Slots/EnemyReinforce02Slot`
- Added root-level reinforce02 markers / click areas / portrait markers.
- Added `BattleUI` reinforce02 facing indicators and ally ready frame.
- Added:
  - `ally_reinforce_02_unit_state`
  - `enemy_reinforce_02_unit_state`
- Expanded adapter/runtime state lists to `5v5`.
- Added mock city-origin metadata contract for reinforce02:
  - `entry_rule = city_reinforcement`
  - `source_city_id`
  - `dispatch_type`
  - `assigned_hero_id`
  - `assigned_unit_id`
  - `arrival_round = 3`
- Kept current reinforce01 round `2` trigger unchanged as the earlier technical deployment test path.
- Added reinforce02 round `3` arrival helper path based on metadata `arrival_round`.
- Confirmed headless project launch exit code `0`.
- Confirmed headless `Battle_Fullscreen_Test.tscn` launch exit code `0`.
- Confirmed no `GDScript::reload` warning on the project/scene verification path.
- Confirmed runtime counts:
  - round `1` alive deployed count = `6`
  - round `2` alive deployed count = `8`
  - round `3` alive deployed count = `10`
  - round `3` actor candidates ally/enemy = `5/5`
  - round `3` target candidates ally/enemy = `5/5`
- Confirmed reinforce02 starts hidden with click/target exclusion and becomes visible/clickable on round `3`.
- Confirmed reinforce02 HP bar / troop label visibility restores after deploy.
- Confirmed auto-target parity OK and enemy AI target parity OK on startup verification path.
- Did not modify `scripts/unit_visual_slot.gd`.
- Updated:
  - `agent/CURRENT_STATE.md`
  - `agent/NEXT_TASKS.md`
  - `agent/CHANGELOG.md`
  - `agent/SESSION_LOG.md`

QA:
- Headless project launch passed.
- Headless `Battle_Fullscreen_Test.tscn` launch passed.
- Headless round-transition QA confirmed `6 -> 8 -> 10` deployed count and `3/3 -> 4/4 -> 5/5` actor/target transitions.
- Manual `F6` QA remains pending in editor.

Remaining tasks:
- v0.67j-5 MVP 5v5 QA Stable
- Auto battle editor-side stop responsiveness QA

## 2026-05-22

Starting baseline:
- v0.67j-2 Reinforce01 QA Stable

Goal:
- v0.67j-3 City Reinforcement Contract Scaffold

Completed:
- Reframed reinforcement semantics toward future world-map / city-origin deployment contract.
- Confirmed no world-map implementation was added.
- Confirmed no city-system implementation was added.
- Confirmed no reinforce02 round-spawn copy prototype was added.
- Verified current `capacity_slot_metadata_registry` is dictionary-backed and future keys can be inserted through `_set_capacity_slot_metadata_value()`.
- Verified current default scaffold already initializes:
  - `entry_rule`
  - `source_city_id`
  - `assigned_unit_id`
- Defined required future city-origin reinforce contract fields:
  - `source_city_id`
  - `dispatch_type`
  - `assigned_hero_id`
  - `assigned_unit_id`
  - `arrival_round`
  - `entry_rule = city_reinforcement`
- Documented that current reinforce01 round `2` deployment is a temporary technical test trigger only.
- Documented that reinforce02 must become a city-origin entry prototype, not a simple round `3` copy.
- Did not modify `Battle_Fullscreen_Test.tscn`.
- Did not modify `scripts/battle_web_import_test.gd`.
- Did not modify `scripts/unit_visual_slot.gd`.
- Updated:
  - `agent/CURRENT_STATE.md`
  - `agent/NEXT_TASKS.md`
  - `agent/CHANGELOG.md`
  - `agent/SESSION_LOG.md`

QA:
- Documentation-only step.
- No runtime behavior changed.

Remaining tasks:
- v0.67j-4 Reinforce02 City-Origin Entry Prototype
- Auto battle editor-side stop responsiveness QA

## 2026-05-22

Starting baseline:
- v0.67i-2 MVP 3v3 QA Stable

Goal:
- v0.67j-1 Reinforce01 Entry Prototype

Completed:
- Added reinforce01 actual visual roots under:
  - `Slots/AllyReinforce01Slot`
  - `Slots/EnemyReinforce01Slot`
- Added root-level runtime nodes for reinforce01:
  - unit markers
  - portrait markers
  - click areas
- Added `BattleUI` nodes for reinforce01:
  - `AllyReinforce01ReadyFrame`
  - `AllyReinforce01FacingIndicator`
  - `EnemyReinforce01FacingIndicator`
- Added:
  - `ally_reinforce_01_unit_state`
  - `enemy_reinforce_01_unit_state`
- Expanded adapter/runtime state lists to `ally=4`, `enemy=4`, `all=8`.
- Kept reinforce01 `active=true` and `deployed=false` at battle start.
- Added one-time round `2` reinforce01 pair deployment trigger.
- Confirmed deploy-time transition:
  - hidden / click disabled / excluded before deployment
  - visible / click enabled / actor-target-occupied included after deployment
- Kept reinforce02 scaffold-only and undeployed.
- Kept auto-battle scoring and enemy AI target policy unchanged.

QA:
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.
- No GDScript reload warning during headless launch.
- Headless startup snapshot confirmed:
  - `ally_count=4`
  - `enemy_count=4`
  - `all_count=8`
  - pre-deploy `ally_deployed=["ally_main_01","ally_main_02","ally_main_03"]`
  - pre-deploy `enemy_deployed=["enemy_main_01","enemy_main_02","enemy_main_03"]`
  - pre-deploy `actor_candidates_ally_count=3`
  - pre-deploy `actor_candidates_enemy_count=3`
  - pre-deploy `target_candidates_for_ally_actor_count=3`
  - pre-deploy `target_candidates_for_enemy_actor_count=3`
  - pre-deploy `all_alive_deployed_count=6`
- Headless round-2 smoke verified:
  - `SMOKE_PRE deployed_alive=6`
  - `SMOKE_POST deployed_alive=8`
  - post-deploy actor candidates ally/enemy = `4/4`
  - post-deploy target candidates ally/enemy = `4/4`
  - `ally_reinforce_01` / `enemy_reinforce_01` deployed flag changed `false -> true`
- F6/manual runtime QA not available in this environment.

Starting baseline:
- v0.67i-1 MVP 3v3 Main03 Activation Spike Stable

Goal:
- v0.67i-2 MVP 3v3 QA Stable

Completed:
- Revalidated the current `3v3` baseline without modifying code or scene files.
- Confirmed stable main-slot structure:
  - ally `main_01` 이순신
  - ally `main_02` 정도전
  - ally `main_03` 권율
  - enemy `main_01` 관우
  - enemy `main_02` 장비
  - enemy `main_03` 하후돈
- Confirmed reinforce remains empty-container scaffold only and undeployed.
- Did not modify `Battle_Fullscreen_Test.tscn`.
- Did not modify `scripts/battle_web_import_test.gd`.
- Did not modify `scripts/unit_visual_slot.gd`.

QA:
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.
- Headless startup snapshot confirmed:
  - `ally_count=3`
  - `enemy_count=3`
  - `all_count=6`
  - `actor_candidates_ally_count=3`
  - `actor_candidates_enemy_count=3`
  - `target_candidates_for_ally_actor_count=3`
  - `target_candidates_for_enemy_actor_count=3`
  - `all_alive_deployed_count=6`
  - `auto_target_parity_ok=true`
  - `enemy_ai_target_parity_ok=true`
  - `enemy_actor_order_parity_ok=true`
- Verified no diff in `Battle_Fullscreen_Test.tscn`.
- Verified no diff in `scripts/battle_web_import_test.gd`.
- F6/manual runtime QA not available in this environment.

Starting baseline:
- v0.67h MVP 5-Slot Scene Scaffold Stable

Goal:
- v0.67i-1 MVP 5-Slot Battle Prototype - Main03 Activation Spike

Completed:
- Added actual visual roots under:
  - `Slots/AllyMain03Slot`
  - `Slots/EnemyMain03Slot`
- Added root-level runtime nodes for `main_03`:
  - unit markers
  - portrait markers
  - click areas
- Added `BattleUI` overlay nodes for `main_03`:
  - `AllyMain03ReadyFrame`
  - `AllyMain03FacingIndicator`
  - `EnemyMain03FacingIndicator`
- Added:
  - `ally_main_03_unit_state`
  - `enemy_main_03_unit_state`
- Expanded adapter/runtime state lists, fallback lists, click lookup, move/attack visual routing, ready-frame refresh, facing-indicator refresh, move-dust handling, and visual cache to include `main_03`.
- Kept reinforce slots uninstantiated and undeployed.
- Kept current auto-battle scoring, enemy AI target selection, HP/troop/layer behavior, enemy portrait vertical offset, and enemy move facing-indicator timing unchanged.

QA:
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.
- Headless startup snapshot confirmed:
  - `ally_count=3`
  - `enemy_count=3`
  - `all_count=6`
  - `actor_candidates_ally_count=3`
  - `actor_candidates_enemy_count=3`
  - `target_candidates_for_ally_actor_count=3`
  - `target_candidates_for_enemy_actor_count=3`
  - `all_alive_deployed_count=6`
  - `enemy_actor_order_parity_ok=true`
- Verified reinforce slots remain undeployed in capacity lists.
- F6/manual runtime QA not available in this environment.

Starting baseline:
- v0.67g MVP 3 Main + 2 Reinforce Layout Plan Stable
- v0.67f+ hotfix states already reflected

Goal:
- v0.67h MVP 5-Slot Scene Scaffold

Completed:
- Confirmed the existing `Slots` structure still hosts only the 4 live visual roots:
  - `AllyMainSlot`
  - `AllySupportSlot`
  - `EnemyMainSlot`
  - `EnemySupportSlot`
- Added 6 empty `Node2D` slot containers under `Slots` for MVP scaffold only:
  - `AllyMain03Slot`
  - `AllyReinforce01Slot`
  - `AllyReinforce02Slot`
  - `EnemyMain03Slot`
  - `EnemyReinforce01Slot`
  - `EnemyReinforce02Slot`
- Added `@onready` references for the new empty slot containers.
- Added `CAPACITY_SLOT_ID_TO_SCENE_SLOT_PATH` for future scene-slot path metadata only.
- Added a one-time startup scaffold snapshot to confirm the 6 new slot containers exist.
- Did not add new `BattleUnitState`.
- Did not add new `UnitVisualRoot`, `ClickArea`, `ReadyFrame`, or `FacingIndicator`.
- Did not register the new empty slot containers into the current `UnitVisualSlot` cache.
- Did not change actor/target helpers, auto battle, enemy AI, or active/deployed filtering.

QA:
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.
- Startup scaffold snapshot confirmed all 6 new empty slot containers were found.
- Existing adapter/alive/actor/target/deployed parity snapshots still matched current `2v2`.
- Verified the existing 4 live visual roots remained under their legacy slots.
- F6/manual runtime QA not available in this environment.

## 2026-05-22

Starting baseline:
- v0.67c-hotfix6 Unit Visual Layer Above HP Bar Stable

Goal:
- v0.67c-hotfix7 Enemy Portrait Facing Offset Restore

Completed:
- Traced portrait layout handling in `_get_portrait_template_offset()`, `_get_ally_portrait_offset_for_facing()`, `_get_enemy_group_base_positions()`, and `_get_enemy_support_group_base_positions()`.
- Confirmed the enemy path still used the generic template-aware portrait offset selection while ally vertical portrait placement already pinned `FACING_UP` / `FACING_DOWN` to the scene-authored fallback offset.
- Added `_get_enemy_portrait_offset_for_facing()` and routed enemy main/support portrait placement through it.
- Restored enemy vertical portrait placement to the stable scene-authored fallback offset so portraits stay near the top flag area instead of drifting toward the body center.
- Did not modify `Battle_Fullscreen_Test.tscn`.
- Did not modify `scripts/unit_visual_slot.gd`.
- Did not change ally portrait handling, HP/troop placement, layer profile, facing-indicator timing, auto battle, or enemy AI logic.

QA:
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.
- Verified no diff in `Battle_Fullscreen_Test.tscn`.
- F6/manual visual placement QA not available in this environment.

## 2026-05-22

Starting baseline:
- v0.67f Deployed/Active Slot Filtering Stable

Goal:
- v0.67f-hotfix Enemy Facing Indicator Hide During Move

Completed:
- Traced enemy move flow to `_play_enemy_actor_path_move_then_act()` and `_finish_enemy_actor_basic_move()`.
- Added `_hide_facing_indicator_for_unit()` in `scripts/battle_web_import_test.gd`.
- Hid the moving enemy actor's `FacingIndicator` immediately before the enemy movement tween starts.
- Kept move-finish indicator restore on the existing `_update_facing_indicators()` path so the indicator returns at the final location after movement completes.
- Did not modify `Battle_Fullscreen_Test.tscn`.
- Did not modify `scripts/unit_visual_slot.gd`.
- Did not change ally facing-selection UX, auto-battle policy, or enemy AI actor/target selection logic.

QA:
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.
- Verified no diff in `Battle_Fullscreen_Test.tscn`.
- F6/manual visual timing QA not available in this environment.

## 2026-05-22

Starting baseline:
- v0.67f Deployed/Active Slot Filtering Stable

Goal:
- v0.67g MVP 3 Main + 2 Reinforce Layout Plan

Completed:
- Read the current rules, state, handoff, slot-capacity, slot-tree, auto-battle, changelog, and session documents.
- Added `agent/MVP_3_MAIN_2_REINFORCE_LAYOUT_PLAN.md`.
- Documented the MVP `3` main + `2` reinforce structure, current `2v2` bridge mapping, layout concepts, naming options, risk list, and staged roadmap.
- Did not modify `Battle_Fullscreen_Test.tscn`.
- Did not modify `scripts/battle_web_import_test.gd`.
- Did not modify `scripts/unit_visual_slot.gd`.

QA:
- Verified no diff in `Battle_Fullscreen_Test.tscn`.
- Verified no diff in `scripts/battle_web_import_test.gd`.
- Verified no diff in `scripts/unit_visual_slot.gd`.
- Verified `agent/MVP_3_MAIN_2_REINFORCE_LAYOUT_PLAN.md` creation.
- Headless runtime QA not required because this step is documentation only.

## 2026-05-22

Starting baseline:
- v0.67e Actor/Target List Adapter Migration Stable

Goal:
- v0.67f Deployed/Active Slot Filtering

Completed:
- Hardened capacity-slot active/deployed helpers for empty slot-id and null-state cases.
- Added `_is_unit_state_available_for_battle_slot()` as the shared alive + active + deployed filter.
- Routed alive/actor adapter helpers through the shared battle-slot availability filter.
- Kept target helpers on the same active/deployed filtered path.
- Added explicit future reinforce policy comment so non-deployed slots stay out of actor/target/occupied paths.
- Added one-time startup deployed/active filter snapshot.
- Did not modify `Battle_Fullscreen_Test.tscn`.
- Did not modify `scripts/unit_visual_slot.gd`.
- Did not change enemy AI actor order, auto battle policy, or battle formulas.

QA:
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.
- Headless startup snapshot confirmed:
  - active slots ally/enemy remain `2/2`
  - deployed slots ally/enemy remain `2/2`
  - actor candidates ally/enemy remain `2/2`
  - target candidates ally/enemy remain `2/2`
  - `all_alive_deployed_count=4`
  - `parity_ok=true`
- Verified no diff in `Battle_Fullscreen_Test.tscn`.
- F6/manual interaction QA not available in this environment.

## 2026-05-22

Starting baseline:
- v0.67d 2v2 on Scalable Slot Framework Stable

Goal:
- v0.67e Actor/Target List Adapter Migration

Completed:
- Added adapter-backed actor-candidate helpers in `scripts/battle_web_import_test.gd`.
- Added adapter-backed target-candidate helpers and target fallback helpers.
- Switched `_get_available_auto_units_for_side()` to adapter-first actor candidates with fallback.
- Switched `_get_alive_auto_targets_for_side()` to adapter-first target candidates with fallback.
- Switched `_get_enemy_ai_target_state_for_actor()` to adapter-first target candidates with fallback while preserving the same target-selection logic.
- Added one-time startup actor/target adapter snapshot with count and parity output.
- Kept `Battle_Fullscreen_Test.tscn` unchanged.
- Kept `scripts/unit_visual_slot.gd` unchanged.
- Kept enemy AI actor order unchanged.
- Kept auto-battle scoring/policy unchanged.

QA:
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.
- Headless startup snapshot confirmed:
  - `actor_candidates_ally_count=2`
  - `actor_candidates_enemy_count=2`
  - `target_candidates_for_ally_actor_count=2`
  - `target_candidates_for_enemy_actor_count=2`
  - `auto_target_parity_ok=true`
  - `enemy_ai_target_parity_ok=true`
  - `enemy_actor_order_parity_ok=true`
- Verified no diff in `Battle_Fullscreen_Test.tscn`.
- F6/manual interaction QA not available in this environment.

## 2026-05-22

Starting baseline:
- v0.67c-hotfix6 Unit Visual Layer Above HP Bar

Goal:
- v0.67d 2v2 on Scalable Slot Framework

Completed:
- Added adapter-first alive/deployed helper reads in `scripts/battle_web_import_test.gd`.
- Added:
  - `_get_alive_unit_states_for_side_from_adapter()`
  - `_get_alive_deployed_unit_states_for_side()`
  - `_get_all_alive_unit_states_from_adapter()`
  - `_is_battle_unit_state_adapter_ready()`
- Converted `_get_alive_ally_units()`, `_get_alive_enemy_units()`, `_get_all_alive_unit_states()`, and `_get_alive_enemy_targets()` to adapter-first with legacy fallback.
- Kept the fixed `2v2` state variables and fallback paths intact.
- Added one-time startup parity snapshot with adapter/fallback alive counts and active/deployed capacity-slot ids.
- Did not modify `Battle_Fullscreen_Test.tscn`.
- Did not modify `scripts/unit_visual_slot.gd`.
- Did not change enemy AI actor order, auto battle policy, battle formulas, or visual layout behavior.

QA:
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.
- Headless startup snapshot confirmed:
  - `adapter_alive_ally_count=2`
  - `adapter_alive_enemy_count=2`
  - `fallback_alive_ally_count=2`
  - `fallback_alive_enemy_count=2`
  - `all_alive_count=4`
  - `parity_ok=true`
- Capacity-slot mapping confirmed:
  - `ally_main` -> `ally_main_01`
  - `ally_support` -> `ally_main_02`
  - `enemy_main` -> `enemy_main_01`
  - `enemy_support` -> `enemy_main_02`
- Verified no diff in `Battle_Fullscreen_Test.tscn`.
- F6/manual interaction QA not available in this environment.

## 2026-05-21

Starting baseline:
- v0.66h EnemySupportSlot Migration Stable

Goal:
- v0.66i Slot Tree QA Stable

Completed:
- Revalidated the 4-slot `Slots` structure in `Battle_Fullscreen_Test.tscn`.
- Confirmed all 4 actual visual roots remain under:
  - `Slots/AllyMainSlot`
  - `Slots/AllySupportSlot`
  - `Slots/EnemyMainSlot`
  - `Slots/EnemySupportSlot`
- Confirmed all 4 ClickAreas remain under scene root.
- Confirmed ally READY frames and all FacingIndicators remain under `BattleUI`.
- Confirmed existing slot dictionary fallback helpers remain present in `scripts/battle_web_import_test.gd`.
- Did not modify `Battle_Fullscreen_Test.tscn`, `scripts/battle_web_import_test.gd`, or `scripts/unit_visual_slot.gd`.

QA:
- `git status --short` checked before doc updates.
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.
- Headless scene log confirmed 4-slot cache summary for:
  - `ally_main`
  - `ally_support`
  - `enemy_main`
  - `enemy_support`

Remaining tasks:
- v0.67 Slot Count Expansion Plan
- Auto Battle QA

## 2026-05-22

Starting baseline:
- v0.67c-hotfix5 Keep HP Bar Alpha 80 Percent

Goal:
- v0.67c-hotfix6 Unit Visual Layer Above HP Bar

Completed:
- Added a runtime visual layer profile so unit token and portrait render above HP bars while troop labels remain on top.
- Applied layer values:
  - shadow `5`
  - hp bar `8`
  - token `12`
  - portrait `13`
  - troop label `20`
- Kept positions and scales unchanged.
- Kept HP bar alpha at `0.8`.
- Kept troop label alpha at `1.0`.
- Did not modify battle flow, enemy AI, auto battle, battle dust, ClickArea, READY, or FacingIndicator behavior.

QA:
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.
- F6/manual interaction QA not available in this environment.

## 2026-05-22

Starting baseline:
- v0.67c-hotfix4 Restore HP Bar Alpha Only

Goal:
- v0.67c-hotfix5 Keep HP Bar Alpha 80 Percent

Completed:
- Changed `HP_BAR_RUNTIME_ALPHA` to `0.8`.
- Added HP bar alpha-only helpers and reapplied HP alpha after group modulate and visual refresh paths.
- Kept troop label alpha at full opacity.
- Did not modify `Battle_Fullscreen_Test.tscn`.
- Did not change HP/troop position logic, battle flow, enemy AI, auto battle, battle dust, ClickArea, READY, or FacingIndicator behavior.

QA:
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.
- Headless runtime summary confirms HP bars report `hp_alpha=0.8` while troop labels remain `troop_alpha=1.0`.
- F6/manual interaction QA not available in this environment.

## 2026-05-22

Starting baseline:
- v0.66i Slot Tree QA Stable

Goal:
- v0.67a Scalable Battle Slot Capacity Plan

Completed:
- Added `agent/SCALABLE_BATTLE_SLOT_CAPACITY_PLAN.md`.
- Defined final slot-capacity direction as `7` main + `3` reinforcement per side.
- Defined MVP direction as `3` main + `2` reinforcement per side.
- Recommended interpreting current `ally_support` and `enemy_support` as `main_02` style start-deployed slots rather than reinforcement slots.
- Documented scalable slot naming, slot metadata, array-registry migration direction, auto-battle expansion considerations, city-to-battle assignment pipeline, formation direction, risks, and QA targets.
- Did not modify `Battle_Fullscreen_Test.tscn`, `scripts/battle_web_import_test.gd`, or `scripts/unit_visual_slot.gd`.

QA:
- Verified no code or scene diff for:
  - `Battle_Fullscreen_Test.tscn`
  - `scripts/battle_web_import_test.gd`
  - `scripts/unit_visual_slot.gd`
- Verified `agent/SCALABLE_BATTLE_SLOT_CAPACITY_PLAN.md` creation.

Remaining tasks:
- v0.67b Slot Registry Array Scaffold
- Auto Battle QA

## 2026-05-22

Starting baseline:
- v0.67a Scalable Battle Slot Capacity Plan Stable

Goal:
- v0.67b Slot Registry Array Scaffold

Completed:
- Added scalable slot-registry constants and capacity-slot id scaffold to `scripts/battle_web_import_test.gd`.
- Added final-capacity and MVP-capacity constants for `7 + 3` and `3 + 2`.
- Added legacy-to-capacity mapping for the current stable `2v2` slots.
- Added capacity-slot metadata registry helpers and a capacity-slot-to-legacy `UnitVisualSlot` bridge helper.
- Added one-time capacity slot registry debug snapshot during `_ready()`.
- Did not modify `Battle_Fullscreen_Test.tscn`.
- Did not modify `scripts/unit_visual_slot.gd`.
- Did not change battle execution, enemy AI, auto battle, cleanup, or scene layout behavior.

QA:
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.
- Headless scene log confirmed:
  - current `4` `UnitVisualSlot` cache entries still resolve
  - capacity slot count is `20`
  - active/deployed slots are only:
    - `ally_main_01`
    - `ally_main_02`
    - `enemy_main_01`
    - `enemy_main_02`
  - legacy mapping resolves:
    - `ally_main` -> `ally_main_01`
    - `ally_support` -> `ally_main_02`
    - `enemy_main` -> `enemy_main_01`
    - `enemy_support` -> `enemy_main_02`
- Verified no diff in `Battle_Fullscreen_Test.tscn`.

Remaining tasks:
- v0.67c BattleUnitState List Adapter
- Auto Battle QA

## 2026-05-22

Starting baseline:
- v0.67b Slot Registry Array Scaffold Stable

Goal:
- v0.67c BattleUnitState List Adapter

Completed:
- Added ally/enemy/all `BattleUnitState` list adapters in `scripts/battle_web_import_test.gd`.
- Added `unit_state_by_legacy_slot_id` and `unit_state_by_capacity_slot_id`.
- Added adapter rebuild and lookup helpers without removing the existing fixed `2v2` state variables.
- Rebuilt adapter references immediately after `_create_demo_unit_states()`.
- Added one-time adapter debug snapshot during demo-state reset.
- Did not modify `Battle_Fullscreen_Test.tscn`.
- Did not modify `scripts/unit_visual_slot.gd`.
- Did not change battle execution, enemy AI, auto battle, cleanup, or scene layout behavior.

QA:
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.
- Headless scene log confirmed:
  - `ally_count=2`
  - `enemy_count=2`
  - `all_count=4`
  - legacy keys:
    - `ally_main`
    - `ally_support`
    - `enemy_main`
    - `enemy_support`
  - capacity keys:
    - `ally_main_01`
    - `ally_main_02`
    - `enemy_main_01`
    - `enemy_main_02`
- Verified no diff in `Battle_Fullscreen_Test.tscn`.

Remaining tasks:
- v0.67d 2v2 on Scalable Slot Framework
- Auto Battle QA

## 2026-05-22

Starting baseline:
- v0.67c-hotfix3 Restore HP/Troop Scene Layout After Slot Migration

Goal:
- v0.67c-hotfix4 Restore HP Bar Alpha Only

Completed:
- Added `HP_BAR_RUNTIME_ALPHA := 0.35`.
- Applied reduced alpha to HP bars only in `_restore_hp_troop_runtime_visibility_for_unit()`.
- Kept troop label alpha at full opacity.
- Did not modify `Battle_Fullscreen_Test.tscn`.
- Did not change HP/troop position logic, battle flow, enemy AI, auto battle, battle dust, ClickArea, READY, or FacingIndicator behavior.

QA:
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.
- F6/manual interaction QA not available in this environment.

## 2026-05-22

Starting baseline:
- v0.67c-hotfix2 Remove Remaining GDScript Warnings + Restore Runtime HP/Troop Visibility

Goal:
- v0.67c-hotfix3 Restore HP/Troop Scene Layout After Slot Migration

Completed:
- Inspected all 8 HP/troop scene nodes and confirmed the remaining issue was layout / draw order rather than missing refs or empty values.
- Confirmed `Slots` is declared before `BattlefieldRoot`, while tokens/portraits already had raised `z_index` values and HP/troop nodes did not.
- Raised all 8 HP/troop scene nodes to `z_index = 4`.
- Removed runtime HP/troop position overwrites from `_restore_hp_troop_runtime_visibility_for_unit()`.
- Expanded runtime summary to print token/hp/troop local-global position, z-index, size, visible state, alpha, and text.
- Did not change slot structure, ClickArea, READY/Facing nodes, battle dust, enemy AI, auto battle, or `UnitCloseupPanel`.

QA:
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.
- Headless runtime summary confirms for all 4 current slots:
  - token/hp/troop positions remain near each other
  - `hp_z=4`
  - `troop_z=4`
  - `hp_visible=true`
  - `troop_visible=true`
  - non-zero sizes
  - non-empty troop text
- `Battle_Fullscreen_Test.tscn` diff limited to the 8 HP/troop nodes.
- F6/manual interaction QA not available in this environment.

## 2026-05-22

Starting baseline:
- v0.67c-hotfix State Adapter Warning Fix + HP/TroopLabel Restore

Goal:
- v0.67c-hotfix2 Remove Remaining GDScript Warnings + Restore Runtime HP/Troop Visibility

Completed:
- Removed remaining parent-block local redeclarations in `_input()` and `_get_visual_group_nodes_for_unit()`.
- Replaced remaining mixed / typed ternary warning candidates in helper and debug paths with explicit branches.
- Added startup HP/troop runtime visibility summary for the current 4 slots.
- Added direct live-unit HP/troop restore helper to enforce visible state, modulate, value, text, and position during visual refresh.
- Did not modify `Battle_Fullscreen_Test.tscn`.
- Did not modify `scripts/unit_visual_slot.gd`.
- Did not change manual battle flow, auto battle flow, enemy AI, battle dust, click-area logic, or `UnitCloseupPanel`.

QA:
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.
- Headless scene log confirmed all 4 current slots report:
  - `hp_ref=true`
  - `troop_ref=true`
  - runtime `visible=true`
  - runtime `modulate.a=1`
  - non-empty troop text
  - non-zero HP max value
- Verified no diff in `Battle_Fullscreen_Test.tscn`.
- F6/manual interaction QA not available in this environment.

## 2026-05-22

Starting baseline:
- v0.67c BattleUnitState List Adapter

Goal:
- v0.67c-hotfix State Adapter Warning Fix + HP/TroopLabel Restore

Completed:
- Updated `scripts/battle_web_import_test.gd` only within the requested hotfix scope.
- Renamed local enemy click-hit variables to remove parent-block shadowing around `enemy_main_hit` / `enemy_support_hit`.
- Replaced adapter-related typed helper fallback returns with explicit local typed result branches.
- Hardened unit visual / click / anchor lookup helpers so missing mappings no longer fall through to ally-main defaults.
- Reasserted HP bar and troop label visibility for live unit states during visual refresh.
- Added one-time startup visual-binding debug summary for the current 4 slot/state pairs.
- Did not modify `Battle_Fullscreen_Test.tscn`.
- Did not modify `scripts/unit_visual_slot.gd`.
- Did not change manual battle flow, auto battle flow, enemy AI, battle dust, or `UnitCloseupPanel`.

QA:
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.
- Headless scene log confirmed:
  - adapter counts remain `ally=2`, `enemy=2`, `all=4`
  - legacy mapping still resolves all `4` live slots
  - capacity mapping still resolves:
    - `ally_main_01`
    - `ally_main_02`
    - `enemy_main_01`
    - `enemy_main_02`
  - startup visual-binding summary reports `hp_ref=true` and `troop_ref=true` for all `4` live slots
- Verified no diff in `Battle_Fullscreen_Test.tscn`.
- F6/manual interaction QA not available in this environment.

## 2026-05-21

Starting baseline:
- v0.66g EnemyMainSlot Migration Stable

Goal:
- v0.66h EnemySupportSlot Migration

Completed:
- Added `Slots/EnemySupportSlot` to `Battle_Fullscreen_Test.tscn`.
- Moved only the enemy-support actual visual root subtree under `EnemySupportSlot`.
- Updated enemy-support visual node paths in `scripts/battle_web_import_test.gd`.
- Kept `EnemySupportUnitClickArea` and `EnemySupportFacingIndicator` in their original parents.
- Kept `AllyMainSlot`, `AllySupportSlot`, and `EnemyMainSlot` structures intact.
- Did not modify movement, attack, enemy AI, auto battle, or battle-dust logic.

QA:
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.
- `Slots/EnemySupportSlot` presence confirmed in scene diff.
- Enemy-support slot cache path wiring confirmed in code.

Remaining tasks:
- v0.66i Slot Tree QA Stable
- v0.67 Slot Count Expansion Plan
- Auto Battle QA

## 2026-05-21

Starting baseline:
- v0.66f AllySupportSlot Migration Stable

Goal:
- v0.66g EnemyMainSlot Migration

Completed:
- Added `Slots/EnemyMainSlot` to `Battle_Fullscreen_Test.tscn`.
- Moved only the enemy-main actual visual root subtree under `EnemyMainSlot`.
- Updated enemy-main visual node paths in `scripts/battle_web_import_test.gd`.
- Kept `EnemyUnitClickArea` and `EnemyFacingIndicator` in their original parents.
- Kept `AllyMainSlot` and `AllySupportSlot` structures intact.
- Kept `enemy_support` visual root unchanged.
- Did not modify movement, attack, enemy AI, auto battle, or battle-dust logic.

QA:
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.
- `Slots/EnemyMainSlot` presence confirmed in scene diff.
- Enemy-main slot cache path wiring confirmed in code.

Remaining tasks:
- v0.66h EnemySupportSlot Migration
- v0.67 Slot Count Expansion Plan
- Auto Battle QA

## 2026-05-21

Starting baseline:
- v0.66e AllyMainSlot Migration Spike Stable

Goal:
- v0.66f AllySupportSlot Migration

Completed:
- Added `Slots/AllySupportSlot` to `Battle_Fullscreen_Test.tscn`.
- Moved only the ally-support actual visual root subtree under `AllySupportSlot`.
- Updated ally-support visual node paths in `scripts/battle_web_import_test.gd`.
- Kept `AllySupportUnitClickArea`, `AllySupportReadyFrame`, and `AllySupportFacingIndicator` in their original parents.
- Kept `AllyMainSlot` structure intact.
- Kept `enemy_main` and `enemy_support` visual roots unchanged.
- Did not modify movement, attack, enemy AI, auto battle, or battle-dust logic.

QA:
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.
- `Slots/AllySupportSlot` presence confirmed in scene diff.
- Ally-support slot cache path wiring confirmed in code.

Remaining tasks:
- v0.66g EnemyMainSlot Migration
- v0.67 Slot Count Expansion Plan
- Auto Battle QA

## 2026-05-21

Starting baseline:
- v0.66d Scene Slot Tree Migration Plan Stable

Goal:
- v0.66e AllyMainSlot Migration Spike

Completed:
- Added `Slots/AllyMainSlot` to `Battle_Fullscreen_Test.tscn`.
- Moved only the ally-main actual visual root subtree under `AllyMainSlot`.
- Updated ally-main visual node paths in `scripts/battle_web_import_test.gd`.
- Kept `AllyUnitClickArea`, `AllyReadyFrame`, and `AllyFacingIndicator` in their original parents.
- Kept `ally_support`, `enemy_main`, and `enemy_support` visual roots unchanged.
- Did not modify movement, attack, enemy AI, auto battle, or battle-dust logic.

QA:
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.
- `Slots/AllyMainSlot` presence confirmed in scene diff.
- Ally-main slot cache path wiring confirmed in code.

Remaining tasks:
- v0.66f AllySupportSlot Migration
- v0.67 Slot Count Expansion Plan
- Auto Battle QA

## 2026-05-21

Starting baseline:
- v0.66c-3 Slot-Based Cleanup / Visibility QA Stable

Goal:
- v0.66d Scene Slot Tree Migration Plan

Completed:
- Added `agent/SCENE_SLOT_TREE_MIGRATION_PLAN.md`.
- Documented the current slot-related scene structure and the target C-style slot tree direction.
- Documented separate migration policy for:
  - Visual nodes
  - World interaction nodes
  - UI overlay nodes
- Recommended `ally_main` as the first migration spike target.
- Kept code and scene files unchanged.

QA:
- Verified no diff in `Battle_Fullscreen_Test.tscn`.
- Verified no diff in `scripts/battle_web_import_test.gd`.
- Verified no diff in `scripts/unit_visual_slot.gd`.
- Verified `agent/SCENE_SLOT_TREE_MIGRATION_PLAN.md` creation.

Remaining tasks:
- v0.66e AllyMainSlot Migration Spike
- v0.67 Slot Count Expansion Plan
- Auto Battle QA

## 2026-05-21

Starting baseline:
- v0.66c-2 Ready/Facing/Click Slot Helper Expansion Stable

Goal:
- v0.66c-3 Slot-Based Cleanup / Visibility QA

Completed:
- Rechecked slot-based cleanup / visibility helper paths for dead-unit handling and overlay visibility.
- Added narrow slot-backed visibility helpers to `scripts/unit_visual_slot.gd`.
- Hardened null guards in slot-based getter helpers so missing references fail safely.
- Switched `_cleanup_dead_units()` to the existing slot-order helper for consistent 2v2 iteration.
- Kept ClickArea / READY frame / FacingIndicator parent structure unchanged.
- Did not modify movement, attack, enemy AI, auto battle, or battle-dust logic.
- Kept `Battle_Fullscreen_Test.tscn` unmodified.

QA:
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.
- 4-slot cache state confirmed in scene launch log.
- No scene diff introduced.

Remaining tasks:
- v0.66d Scene Slot Tree Migration Plan
- v0.67 Slot Count Expansion Plan
- Auto Battle QA

## 2026-05-21

Starting baseline:
- v0.66c-1 UnitVisualSlot Usage Expansion - Safe Helpers Stable

Goal:
- v0.66c-2 Ready/Facing/Click Slot Helper Expansion

Completed:
- Added slot-first UI / click getter helpers to `scripts/unit_visual_slot.gd`.
- Added `_get_click_shape_for_unit()` and `_get_all_unit_states_in_slot_order()` to `scripts/battle_web_import_test.gd`.
- Expanded slot-first usage across READY / Facing / Click helper lookups only.
- Kept existing per-slot facing indicator position functions and world-to-UI conversion flow unchanged.
- Kept ClickArea under scene root and READY / Facing nodes under `BattleUI`.
- Did not modify movement, attack, enemy AI, auto battle, or battle-dust logic.
- Kept `Battle_Fullscreen_Test.tscn` unmodified.

QA:
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.
- 4-slot cache state confirmed in scene launch log.
- No scene diff introduced.

Remaining tasks:
- v0.66c-3 Slot-Based Cleanup/Visibility QA
- v0.66d Scene Slot Tree Migration Plan
- Auto Battle QA

## 2026-05-21

Starting baseline:
- v0.66b UnitVisualSlot Lookup Integration Stable

Goal:
- v0.66c-1 UnitVisualSlot Usage Expansion - Safe Helpers

Completed:
- Added safe read-only helper methods to `scripts/unit_visual_slot.gd`.
- Expanded slot-first usage into safe helper paths for:
  - debug summary output
  - visual group node lookup
  - click area lookup
  - facing indicator lookup
- Preserved existing direct fallback behavior for the same helpers.
- Kept cleanup and visibility flow using the same public helper entry points.
- Kept `Battle_Fullscreen_Test.tscn` unmodified.
- Kept ClickArea / READY frame / FacingIndicator parent structure unchanged.
- Did not modify movement, attack, enemy AI, or auto battle execution flow.

QA:
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.
- 4-slot cache state confirmed in scene launch log.
- No scene diff introduced.

Remaining tasks:
- v0.66c-2 Ready/Facing/Click Slot Helper Expansion
- v0.66d Scene Slot Tree Migration Plan
- Auto Battle QA

## 2026-05-21

Starting baseline:
- v0.66a UnitVisualSlot Scaffold Stable

Goal:
- v0.66b UnitVisualSlot Lookup Integration

Completed:
- Added cache-first `UnitVisualSlot` lookup helpers to `scripts/battle_web_import_test.gd`.
- Preserved existing slot dictionary functions and routed them through a safe adapter bridge when available.
- Added `to_visual_slots_dictionary()` to `scripts/unit_visual_slot.gd` and kept legacy dictionary key names unchanged.
- Kept fallback order stable:
  - `unit_state.slot_id` first
  - direct state-to-slot mapping second
  - dictionary-backed adapter fallback when cache is empty
- Kept `Battle_Fullscreen_Test.tscn` unmodified.
- Kept ClickArea / READY frame / FacingIndicator parent structure unchanged.
- Kept 2v2 manual battle loop and auto battle logic unchanged.

QA:
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.
- 4-slot cache rebuild path confirmed in code.
- Dictionary fallback path confirmed in code.
- No scene diff introduced.

Remaining tasks:
- v0.66c UnitVisualSlot Usage Expansion
- v0.66d Scene Slot Tree Migration Plan
- Auto Battle QA

## 2026-05-21

Starting baseline:
- v0.65k-1 Battle Dust Layer + Density Hotfix complete

Goal:
- v0.65k-2 Dust Source Isolation + Stale Dust Cleanup Hotfix

Completed:
- Rechecked all dust call paths in `scripts/battle_web_import_test.gd`.
- Identified two likely white-dust recurrence paths:
  - stale move dust surviving into attack timing
  - battle dust density still being too strong over repeated turns
- Disabled attack battle dust and kept only hit battle dust.
- Added stale move-dust cleanup before ally attack, before enemy attack, and after ally attack finish.
- Lowered hit battle dust alpha, scale, duration, tint brightness, and world layer again.
- Kept movement dust helper functions unchanged.
- Did not modify `Battle_Fullscreen_Test.tscn`.
- Did not modify ClickArea code.

QA:
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.
- Battle dust still queues free at tween end in code.
- Movement dust helper path remained unchanged in code.

Remaining tasks:
- Auto Battle QA
- Debug cleanup
- v0.65i-2 ClickArea Root Migration Spike

## 2026-05-21

Starting baseline:
- v0.65k Battle Dust FX Profile Tuning complete

Goal:
- v0.65k-1 Battle Dust Layer + Density Hotfix

Completed:
- Lowered battle dust opacity, scale, duration, and render layer.
- Reduced attack-dust density separately from hit-dust density.
- Moved attack and hit dust farther down toward unit foot-level.
- Kept movement dust helper functions unchanged.
- Did not modify `Battle_Fullscreen_Test.tscn`.
- Did not modify ClickArea code.

QA:
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.
- Battle dust now forces lower world-layer behavior in code.
- Movement dust helper path remained unchanged in code.

Remaining tasks:
- Auto Battle QA
- Debug cleanup
- v0.65i-2 ClickArea Root Migration Spike

## 2026-05-21

Starting baseline:
- v0.65j-5a Auto Battle Stop UX Hotfix complete

Goal:
- v0.65k Battle Dust FX Profile Tuning

Completed:
- Added battle-dust-only FX tuning for attack and hit moments.
- Reused existing dust textures without changing movement dust template behavior.
- Kept battle dust opacity below full white exposure and applied beige / dirt tint.
- Lowered battle dust placement toward foot-level and kept it behind slash / hit spark FX.
- Preserved movement dust flow, auto battle flow, and ClickArea code.
- Did not modify `Battle_Fullscreen_Test.tscn`.

QA:
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.
- Movement dust helper path remained unchanged in code.
- Battle dust helper path confirmed on ally attack and enemy hit reaction paths.

Remaining tasks:
- Auto Battle QA
- Debug cleanup
- v0.65i-2 ClickArea Root Migration Spike

## 2026-05-21

Starting baseline:
- v0.65j-5 Full Auto Battle Loop Prototype complete

Goal:
- v0.65j-5a Auto Battle Stop UX Hotfix

Completed:
- Updated auto-battle button state refresh so the stop button stays clickable while full auto is ON.
- Updated auto-battle toggle handling so an ON-state button press routes through `_stop_full_auto_battle("user stop")`.
- Preserved soft stop behavior so the current action finishes and the next deferred auto step does not run.
- Kept runtime button handling limited to text and disabled state only.
- Did not modify `Battle_Fullscreen_Test.tscn`.
- Did not modify ClickArea code.
- Did not modify `_play_enemy_ai_for_actor()`.
- Did not modify `_get_enemy_ai_target_state_for_actor()`.
- Did not add a direct `while` loop for auto battle flow.

QA:
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.
- `AutoBattleButton` ON-state stop availability confirmed in code.
- Deferred tick early-return guard confirmed in code.

Remaining tasks:
- Auto Battle QA
- Debug cleanup
- v0.65i-2 ClickArea Root Migration Spike

## 2026-05-21

Starting baseline:
- v0.65j-4 Auto Battle Button Hook Stable

Goal:
- v0.65j-5 Full Auto Battle Loop Prototype

Completed:
- Added full auto battle ON/OFF state and step counter.
- Switched `AutoBattleButton` from one-shot action trigger to auto battle toggle trigger.
- Added deferred single-step loop tick helper.
- Added stop helper and step-limit safety guard.
- Reused existing ally auto one-action flow and existing enemy AI turn flow.
- Kept runtime button changes limited to text and disabled state only.
- Did not add a direct `while` loop for auto battle flow.
- Did not modify ClickArea code.
- Did not modify `_play_enemy_ai_for_actor()`.
- Did not modify `_get_enemy_ai_target_state_for_actor()`.

QA:
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.
- `AUTO_BATTLE_MAX_STEPS` guard confirmed in code.
- Deferred tick path confirmed in code.

Remaining tasks:
- v0.65i-2 ClickArea Root Migration Spike
- Debug cleanup

## 2026-05-21

Starting baseline:
- v0.65j-3a Auto Move + Auto Facing Completion complete

Goal:
- v0.65j-4 Auto Battle Button Hook

Completed:
- Added `AutoBattleButton` to `BattleUI/CommandBar`.
- Added `auto_battle_button` onready lookup.
- Connected button press to `_run_auto_action_for_active_ally_once()`.
- Added button enabled/disabled control in `_set_phase()`.
- Kept the button limited to one active ally auto action only.
- Kept full auto battle loop unimplemented.
- Preserved existing manual command buttons.
- Did not modify ClickArea code.
- Did not modify `_play_enemy_ai_for_actor()`.
- Did not modify `_get_enemy_ai_target_state_for_actor()`.

QA:
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.
- `AutoBattleButton` node presence confirmed.
- Auto battle button script reference confirmed.

Remaining tasks:
- v0.65j-5 Full Auto Battle Loop Prototype
- v0.65i-2 ClickArea Root Migration Spike

## 2026-05-21

Starting baseline:
- v0.65j-3 Ally Auto Battle One-Action MVP complete

Goal:
- v0.65j-3a Auto Move + Auto Facing Completion

Completed:
- Extended `_try_auto_move_for_active_ally()` to start actual movement through `play_basic_move_demo()`.
- Added auto-action flow flags for separating auto move/facing from manual move/facing.
- Added nearest-enemy auto facing selection after move.
- Updated `_finish_basic_move_demo()` so auto move no longer waits at `PHASE_FACING_SELECT`.
- Preserved manual move + facing selection flow for non-auto movement.
- Kept auto battle button disconnected.
- Kept full auto battle loop unimplemented.
- Did not modify `Battle_Fullscreen_Test.tscn`.
- Did not modify ClickArea code.
- Did not modify `_play_enemy_ai_for_actor()`.
- Did not modify `_get_enemy_ai_target_state_for_actor()`.

QA:
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.
- Auto move + auto facing completion confirmed by function flow wiring.
- No enemy AI flow rewiring introduced.

Remaining tasks:
- v0.65j-4 Auto Battle Button Hook
- v0.65j-5 Full Auto Battle Loop Prototype
- v0.65i-2 ClickArea Root Migration Spike

## 2026-05-21

Starting baseline:
- v0.65j-2 Auto Battle Helper Functions Scaffold complete

Goal:
- v0.65j-3 Ally Auto Battle One-Action MVP

Completed:
- Added `_run_auto_action_for_active_ally_once()`.
- Added `_try_auto_attack_for_active_ally()`.
- Added `_try_auto_move_for_active_ally()`.
- Added `_auto_wait_active_ally()`.
- Connected auto attack MVP to the existing ally basic attack execution path.
- Kept auto move at move-candidate-selection-only level for safety.
- Deferred move execution and automatic facing completion.
- Kept the MVP disconnected from any auto battle button.
- Kept the MVP disconnected from any full auto battle loop.
- Did not modify `Battle_Fullscreen_Test.tscn`.
- Did not modify ClickArea code.
- Did not modify `_play_enemy_ai_for_actor()`.
- Did not modify `_get_enemy_ai_target_state_for_actor()`.

QA:
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.
- No enemy AI flow rewiring introduced.
- No manual battle entry-point rewiring introduced.

Remaining tasks:
- v0.65j-3a Auto Move + Auto Facing Completion
- v0.65j-4 Auto Battle Button Hook
- v0.65j-5 Full Auto Battle Loop Prototype
- v0.65i-2 ClickArea Root Migration Spike

## 2026-05-21

Starting baseline:
- v0.65j-1 Auto Battle Action Policy Design complete

Goal:
- v0.65j-2 Auto Battle Helper Functions Scaffold

Completed:
- Added auto battle helper scaffold functions to `scripts/battle_web_import_test.gd`.
- Added side-based available-unit helper.
- Added side-based living-target helper.
- Added demo-damage-based auto kill helper.
- Added score-based auto attack target helper.
- Added best auto attack target helper.
- Added best auto move cell scaffold helper.
- Added optional auto policy debug snapshot helper.
- Kept all new helpers disconnected from existing battle execution flow.
- Did not modify `_play_enemy_ai_for_actor()`.
- Did not modify `_get_enemy_ai_target_state_for_actor()`.
- Did not modify `Battle_Fullscreen_Test.tscn`.
- Did not modify ClickArea code paths.

QA:
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.
- No current 2v2 flow rewiring was introduced.

Remaining tasks:
- v0.65j-3 Ally Auto Battle One-Action MVP
- v0.65j-4 Auto Battle Button Hook
- v0.65j-5 Full Auto Battle Loop Prototype
- v0.65i-2 ClickArea Root Migration Spike

## 2026-05-21

Starting baseline:
- v0.65i-3 READY/Facing UI Slot Registry Cleanup Stable

Goal:
- v0.65j-1 Auto Battle Action Policy Design

Completed:
- Added `agent/AUTO_BATTLE_ACTION_POLICY.md`.
- Defined a side-agnostic auto action design direction based on battle data, not click input.
- Documented one-action auto battle flow from actor selection to action completion.
- Documented draft target priority policy.
- Documented draft movement destination priority policy.
- Audited reusable function candidates in `scripts/battle_web_import_test.gd`.
- Defined next implementation sequence:
  - helper scaffold
  - ally one-action MVP
  - button hook
  - full auto battle loop
- Did not modify `Battle_Fullscreen_Test.tscn`.
- Did not modify `scripts/battle_web_import_test.gd`.

QA:
- Documentation-only step.
- No runtime behavior changed.

Remaining tasks:
- v0.65j-2 Auto Battle Helper Functions Scaffold
- v0.65j-3 Ally Auto Battle One-Action MVP
- v0.65j-4 Auto Battle Button Hook
- v0.65j-5 Full Auto Battle Loop Prototype
- v0.65i-2 ClickArea Root Migration Spike

## 2026-05-21

Starting baseline:
- v0.65i-1 Slot UI Attachment Audit complete

Goal:
- v0.65i-3 READY/Facing UI Slot Registry Cleanup

Completed:
- Kept `AllyReadyFrame` / `AllySupportReadyFrame` under `BattleUI`.
- Kept `AllyFacingIndicator` / `AllySupportFacingIndicator` / `EnemyFacingIndicator` / `EnemySupportFacingIndicator` under `BattleUI`.
- Preserved `ready_frame` / `facing_indicator` entries in the slot visual dictionaries.
- Added `_get_ready_frame_for_unit()`.
- Converted `_update_ally_ready_frames()` to resolve READY frame through slot-based lookup.
- Added `_get_visual_anchor_position_for_unit()` with `slot_id` first dispatch and direct comparison fallback.
- Converted `_position_ready_frame_for_unit()` to use shared per-unit anchor lookup.
- Converted `_get_facing_indicator_for_unit()` to resolve through slot-based visual slot lookup.
- Added `_refresh_facing_indicator_for_unit()` and `_position_facing_indicator_for_unit()` as slot-aware dispatch helpers.
- Converted `_update_facing_indicators()` to use slot-aware refresh.
- Preserved existing `_position_facing_indicator_for_*()` functions.
- Did not modify ClickArea code path.
- Did not move any scene nodes.

QA:
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.
- Startup slot debug print still shows all 4 slot roots active.
- F6/manual interaction QA not available in this environment.

Remaining tasks:
- v0.65i-2 ClickArea Root Migration Spike
- Target selection policy for overlapping living units
- Debug cleanup for root slot and attack click logs

## 2026-05-20

Starting baseline:
- v0.65e Unit Token Asset Normalize Apply Verified

Goal:
- UnitVisual Single Slot / Root Refactor.

Completed:
- v0.65g-2 UnitVisualRoot Adapter Layer.
- v0.65g-3 Ally Main Visual Nodes Root Migration.
- v0.65g-4 Ally Support Visual Nodes Root Migration.
- v0.65g-5 Enemy Main Visual Nodes Root Migration.
- v0.65g-5a-0 Ally Portrait Offset Diagnosis.
- v0.65g-5a-1 Ally Portrait Up/Down Offset Fix.
- v0.65g-6 Enemy Support Visual Nodes Root Migration.
- v0.65g-6a Dead Enemy Main Click Priority Fix.
- v0.65h-1 Extend BattleUnitState slot metadata.
- v0.65h-2 Inject demo unit slot metadata.
- v0.65h-3 Add slot_id visual slot lookup.
- v0.65h-4 QA and docs update.

Kimjak F6 confirmation:
- Ally Root migration normal.
- Ally portrait up/down fix normal.
- Guan Yu death no longer blocks Zhang Fei target selection.
- Yi Sun-sin and Jeong Do-jeon can both attack Zhang Fei after Guan Yu dies.

Current stable candidate:
- v0.65h Slot-Based UnitVisual Architecture Design Stable

QA:
- `Battle_Fullscreen_Test.tscn` headless launch exit code 0.
- UnitVisualRoot debug slot all true.
- `visual_key` values preserved.
- Existing direct comparison fallback preserved.
- No scene/node migration in v0.65h.
- F6 not available in this environment.

Remaining tasks:
- v0.65i ClickArea / READY / FacingIndicator Integration Review.
- Target selection policy for overlapping living units.
- Debug cleanup for root slot and attack click logs.
## 2026-05-22

Starting baseline:
- v0.67j-1 Reinforce01 Entry Prototype Stable

Goal:
- v0.67j-2 Reinforce01 QA Stable

Completed:
- Revalidated the reinforce01 round-`2` entry prototype without modifying battle code or scene files.
- Confirmed headless project launch exit code `0`.
- Confirmed headless `Battle_Fullscreen_Test.tscn` launch exit code `0`.
- Confirmed no `GDScript::reload` warning on the project/scene verification path.
- Confirmed battle-start deployed roster remains `3v3`:
  - ally = 이순신 / 정도전 / 권율
  - enemy = 관우 / 장비 / 하후돈
- Confirmed battle-start reinforce state:
  - `ally_reinforce_01` / `enemy_reinforce_01` hidden
  - `deployed=false`
  - alive deployed count = `6`
  - actor candidates ally/enemy = `3/3`
  - target candidates ally/enemy = `3/3`
- Confirmed round `2` post-deploy reinforce state:
  - `ally_reinforce_01` / `enemy_reinforce_01` visible
  - `deployed=true`
  - alive deployed count = `8`
  - actor candidates ally/enemy = `4/4`
  - target candidates ally/enemy = `4/4`
- Confirmed reinforce01 HP bar / troop label visibility restores after deploy.
- Confirmed reinforce01 facing indicator references remain present after deploy.
- Confirmed reinforce02 remains empty slot container only and `deployed=false`.
- Confirmed auto-target parity OK, enemy AI target parity OK, and enemy actor order parity OK.
- Did not modify `Battle_Fullscreen_Test.tscn`.
- Did not modify `scripts/battle_web_import_test.gd`.
- Did not modify `scripts/unit_visual_slot.gd`.
- Updated:
  - `agent/CURRENT_STATE.md`
  - `agent/NEXT_TASKS.md`
  - `agent/CHANGELOG.md`
  - `agent/SESSION_LOG.md`

QA:
- Headless project launch passed.
- Headless `Battle_Fullscreen_Test.tscn` launch passed.
- Manual `F6` QA remains pending in editor; this environment cannot execute interactive editor checks.

Remaining tasks:
- v0.67j-3 Reinforce02 Entry Prototype
- Auto battle editor-side stop responsiveness QA
