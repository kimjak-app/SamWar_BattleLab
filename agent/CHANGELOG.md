# CHANGELOG

## v0.67k-1-hotfix Reinforcement Toast Sequence Fix

- Updated `scripts/battle_web_import_test.gd` and agent docs only.
- Kept `Battle_Fullscreen_Test.tscn` unchanged.
- Kept `scripts/unit_visual_slot.gd` unchanged.
- Fixed the reinforcement-toast sequencing bug caused by immediate overwrite on the shared `RoundToastRoot` / tween path.
- Added queued battle-toast playback through:
  - `_enqueue_battle_toast()`
  - `_play_next_battle_toast()`
  - `_finish_battle_toast_playback()`
- Added runtime toast playback state:
  - `pending_battle_toasts`
  - `is_battle_toast_playing`
  - `active_battle_toast_tag`
- Cleared stale toast queue/tween state during `reset_demo_state()`.
- Reinforcement arrival toast now plays before the same-round `BATTLE n` toast instead of being overwritten by it.
- Headless smoke confirms:
  - round `2` = `reinforcement_arrival -> BATTLE 2`
  - round `3` = `reinforcement_arrival -> BATTLE 3`
- Kept reinforcement deploy conditions, actor/target logic, auto-battle scoring, enemy AI target policy, and hero identity registry unchanged.

## v0.67k-1 Reinforcement Arrival Toast MVP

- Updated `scripts/battle_web_import_test.gd` and agent docs.
- Reused the existing `RoundToastRoot` / `RoundToastImage` / `RoundToastLabel` / tween flow for reinforcement arrival.
- Added:
  - `REINFORCEMENT_ARRIVAL_TOAST_TEXTURE_PATH`
  - `REINFORCEMENT_ARRIVAL_TOAST_TEXT`
  - `_show_reinforcement_arrival_toast()`
  - `_show_battle_toast()`
- Reinforcement arrival toast now triggers:
  - once after round `2` reinforce01 pair deploy
  - once after round `3` reinforce02 pair deploy
- Kept round-start `BATTLE n` toast on the same base animation path.
- Kept battle logic, auto-battle scoring, enemy AI target policy, reinforce deploy conditions, HP/troop UI, and facing-indicator behavior unchanged.
- Kept `Battle_Fullscreen_Test.tscn` unchanged.
- Kept `scripts/unit_visual_slot.gd` unchanged.
- Confirmed headless project launch exit code `0`.
- Confirmed headless `Battle_Fullscreen_Test.tscn` launch exit code `0`.

## v0.67k Battle Hero Identity Source of Truth Scaffold

- Updated `scripts/battle_web_import_test.gd` and agent docs only.
- Added runtime `HERO_REGISTRY` for the current `10` battle heroes:
  - `yi_sunsin`
  - `jeong_dojeon`
  - `kwon_yul`
  - `gim_yusin`
  - `eulji_mundeok`
  - `guan_yu`
  - `zhang_fei`
  - `xiahou_dun`
  - `liu_bei`
  - `zhuge_liang`
- Added `TEST_BATTLE_ROSTER` as the temporary slot-to-hero contract for the current battle test scene.
- Routed `assigned_hero_id` through `capacity_slot_metadata_registry` for all current battle slots.
- Added runtime helper path to apply hero identity from `hero_id`:
  - `display_name`
  - battlefield portrait badge texture
  - closeup portrait texture lookup
- Added startup validation logging for slot identity parity:
  - capacity slot id
  - hero id
  - display name
  - expected battlefield portrait filename
  - actual portrait filename
  - click area name
- Runtime hero identity now corrects portrait/name drift even if scene-authored portrait texture binding is wrong.
- Kept battle logic, auto-battle scoring, enemy AI target policy, reinforce deploy logic, HP/troop UI, and facing-indicator behavior unchanged.
- Kept `Battle_Fullscreen_Test.tscn` unchanged in this step.
- Kept `scripts/unit_visual_slot.gd` unchanged.
- Confirmed headless project launch exit code `0`.
- Confirmed headless `Battle_Fullscreen_Test.tscn` launch exit code `0`.

## v0.67k Auto Battle Step Limit 5v5 Sustain Fix

- Updated `scripts/battle_web_import_test.gd` and agent docs only.
- Replaced the old fixed auto-battle step cap:
  - `AUTO_BATTLE_MAX_STEPS = 40`
- Added deployed-unit-count-based dynamic step budgeting:
  - `AUTO_BATTLE_MIN_MAX_STEPS = 80`
  - `AUTO_BATTLE_STEP_BUDGET_PER_DEPLOYED_UNIT = 16`
  - `AUTO_BATTLE_ABSOLUTE_MAX_STEPS = 200`
- Added `_get_auto_battle_max_steps()`.
- Changed the step-limit stop reason to a clearer log:
  - `자동전투 안전 제한 도달`
- Verified computed budgets:
  - round `1` alive `6` -> `96`
  - round `2` alive `8` -> `128`
  - round `3` alive `10` -> `160`
- Kept infinite-loop protection through the absolute cap.
- Kept actor/target selection, enemy AI policy, reinforce deploy logic, combat formulas, cleanup logic, and scene files unchanged.
- Confirmed headless project launch exit code `0`.
- Confirmed headless `Battle_Fullscreen_Test.tscn` launch exit code `0`.

## v0.67j-5 MVP 5v5 QA Stable

- This step is documentation and verification only.
- Revalidated the current MVP battle baseline with no code, scene, or asset edits.
- Fixed the active MVP target to `5v5`:
  - `3` main + `2` city-origin reinforce per side
- Confirmed round structure:
  - round `1` = `3v3`
  - round `2` = `4v4`
  - round `3` = `5v5`
- Confirmed deployed alive progression = `6 -> 8 -> 10`.
- Confirmed round `3` actor candidates ally/enemy = `5/5`.
- Confirmed round `3` target candidates ally/enemy = `5/5`.
- Confirmed reinforce01 / reinforce02 visual display restore is stable.
- Confirmed HP bar, troop label, click, target, and auto-battle behavior remain normal on the current prototype.
- Kept current higher slot-capacity constants as future-expansion scaffold only.
- Kept `Battle_Fullscreen_Test.tscn` unchanged.
- Kept `scripts/battle_web_import_test.gd` unchanged.
- Kept `scripts/unit_visual_slot.gd` unchanged.

## v0.67j-4 Reinforce02 City-Origin Entry Prototype

- Updated `Battle_Fullscreen_Test.tscn`, `scripts/battle_web_import_test.gd`, and agent docs only.
- Added reinforce02 scene nodes for both sides:
  - unit visual root
  - marker
  - portrait marker
  - click area
  - ally ready frame
  - ally/enemy facing indicators
- Added:
  - `ally_reinforce_02_unit_state`
  - `enemy_reinforce_02_unit_state`
- Expanded adapter/runtime state arrays to `ally=5`, `enemy=5`, `all=10`.
- Added mock city-origin reinforce metadata for reinforce02:
  - `entry_rule = city_reinforcement`
  - `source_city_id`
  - `dispatch_type`
  - `assigned_hero_id`
  - `assigned_unit_id`
  - `arrival_round = 3`
- Kept reinforce02 hidden and undeployed at battle start.
- Added one-time round `3` city-origin deployment trigger for the reinforce02 pair.
- Verified deployed count moves `6 -> 8 -> 10`.
- Verified actor/target candidate counts move `3/3 -> 4/4 -> 5/5`.
- Kept reinforce01 round `2` test trigger logic unchanged.
- Kept auto-battle scoring unchanged.
- Kept enemy AI target-selection policy unchanged.
- Kept HP bar, troop label, HP alpha `0.8`, layer profile, enemy move facing-indicator hide/show timing, and HP `0` cleanup behavior unchanged.

## v0.67j-3 City Reinforcement Contract Scaffold

- This step is documentation-first and contract-definition only.
- Reframed reinforce-slot purpose as future city/castle-origin deployment rather than fixed round-spawn behavior.
- Confirmed `capacity_slot_metadata_registry` is dictionary-backed and can accept future metadata keys through the existing setter path.
- Confirmed current default metadata scaffold already includes:
  - `entry_rule`
  - `source_city_id`
  - `assigned_unit_id`
- Defined required future city-origin reinforce contract keys:
  - `source_city_id`
  - `dispatch_type`
  - `assigned_hero_id`
  - `assigned_unit_id`
  - `arrival_round`
  - `entry_rule = city_reinforcement`
- Documented current reinforce01 round `2` entry as a temporary test trigger for `deployed=false -> true` validation only.
- Documented reinforce02 as the next city-origin entry prototype and explicitly rejected simple round `3` spawn-copy scope.
- Kept `Battle_Fullscreen_Test.tscn` unchanged.
- Kept `scripts/battle_web_import_test.gd` unchanged.
- Kept `scripts/unit_visual_slot.gd` unchanged.

## v0.67j-2 Reinforce01 QA Stable

- This step is documentation and verification only.
- Revalidated the current reinforce01 round-`2` entry baseline with no runtime code or scene edits.
- Confirmed pre-deploy state:
  - alive deployed count = `6`
  - actor candidates ally/enemy = `3/3`
  - target candidates ally/enemy = `3/3`
  - reinforce01 pair hidden with `deployed=false`
- Confirmed round `2` post-deploy state:
  - alive deployed count = `8`
  - actor candidates ally/enemy = `4/4`
  - target candidates ally/enemy = `4/4`
  - reinforce01 pair visible with `deployed=true`
- Confirmed reinforce01 HP bar / troop label restore correctly after deploy.
- Confirmed auto-target parity OK, enemy AI target parity OK, and enemy actor order parity OK.
- Confirmed reinforce02 remains empty-container scaffold only and undeployed.
- Kept `Battle_Fullscreen_Test.tscn` unchanged.
- Kept `scripts/battle_web_import_test.gd` unchanged.
- Kept `scripts/unit_visual_slot.gd` unchanged.
- Headless project launch exit code `0`.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code `0`.

## v0.67j-1 Reinforce01 Entry Prototype

- Updated `Battle_Fullscreen_Test.tscn`, `scripts/battle_web_import_test.gd`, and agent docs only.
- Added reinforce01 scene nodes for:
  - `AllyReinforce01UnitVisualRoot`
  - `EnemyReinforce01UnitVisualRoot`
  - root-level markers
  - root-level portrait markers
  - root-level click areas
  - `AllyReinforce01ReadyFrame`
  - ally/enemy reinforce01 facing indicators
- Added:
  - `ally_reinforce_01_unit_state`
  - `enemy_reinforce_01_unit_state`
- Expanded adapter/runtime state arrays to `ally=4`, `enemy=4`, `all=8`.
- Kept reinforce01 `active=true` but `deployed=false` at battle start so it stays hidden and excluded from actor/target/occupied paths.
- Added one-time round `2` deployment trigger for the reinforce01 ally/enemy pair.
- Verified post-deploy adapter counts move from:
  - alive deployed `6 -> 8`
  - actor candidates ally/enemy `3/3 -> 4/4`
  - target candidates ally/enemy `3/3 -> 4/4`
- Kept reinforce02 unimplemented and undeployed.
- Kept auto-battle scoring unchanged.
- Kept enemy AI target-selection policy unchanged.
- Kept HP bar, troop label, HP alpha `0.8`, layer profile, enemy portrait vertical offset, and enemy facing-indicator timing unchanged.

## v0.67i-2 MVP 3v3 QA Stable

- This step is documentation and verification only.
- Revalidated the current `3v3` main-slot baseline with no code or scene changes.
- Confirmed:
  - ally count = `3`
  - enemy count = `3`
  - all count = `6`
  - actor candidates ally/enemy = `3/3`
  - target candidates ally/enemy = `3/3`
  - all alive deployed count = `6`
  - auto target parity OK = `true`
  - enemy AI target parity OK = `true`
  - enemy actor order parity OK = `true`
- Confirmed reinforce remains empty-container scaffold only and undeployed.
- Kept `Battle_Fullscreen_Test.tscn` unchanged.
- Kept `scripts/battle_web_import_test.gd` unchanged.
- Kept `scripts/unit_visual_slot.gd` unchanged.

## v0.67i-1 MVP 5-Slot Battle Prototype - Main03 Activation Spike

- Updated `Battle_Fullscreen_Test.tscn`, `scripts/battle_web_import_test.gd`, and agent docs only.
- Activated `ally_main_03` and `enemy_main_03` as the first real MVP battle-participant expansion.
- Added scene nodes for:
  - `AllyMain03UnitVisualRoot`
  - `EnemyMain03UnitVisualRoot`
  - root-level click areas
  - root-level markers / portrait markers
  - ally ready frame
  - ally/enemy facing indicators
- Added:
  - `ally_main_03_unit_state`
  - `enemy_main_03_unit_state`
- Expanded adapter/runtime state arrays to `ally=3`, `enemy=3`, `all=6`.
- Expanded `UnitVisualSlot` cache for:
  - `ally_main_03`
  - `enemy_main_03`
- Kept reinforce slots empty and undeployed.
- Kept auto-battle scoring unchanged.
- Kept enemy AI target-selection policy unchanged.
- Kept HP bar, troop label, HP alpha `0.8`, layer profile, enemy portrait vertical offset, and enemy move facing-indicator timing unchanged.

## v0.67h MVP 5-Slot Scene Scaffold

- Updated `Battle_Fullscreen_Test.tscn`, `scripts/battle_web_import_test.gd`, and agent docs only.
- Added 6 empty scene slot containers under `Slots`:
  - `AllyMain03Slot`
  - `AllyReinforce01Slot`
  - `AllyReinforce02Slot`
  - `EnemyMain03Slot`
  - `EnemyReinforce01Slot`
  - `EnemyReinforce02Slot`
- Kept the existing 4-slot visual-root structure unchanged.
- Added `@onready` references for the new empty slot containers.
- Added `CAPACITY_SLOT_ID_TO_SCENE_SLOT_PATH` as future scene-slot metadata scaffold.
- Added one-time startup scaffold snapshot for slot-container existence only.
- Did not add new `BattleUnitState`.
- Did not add new `UnitVisualRoot`, `ClickArea`, `ReadyFrame`, or `FacingIndicator`.
- Did not register the new empty slot containers into the `UnitVisualSlot` runtime cache.
- Kept actor/target helpers, auto battle, enemy AI, active/deployed filtering, HP/troop layout, enemy portrait vertical offset, and enemy facing-indicator timing unchanged.

## v0.67c-hotfix7 Enemy Portrait Facing Offset Restore

- Updated `scripts/battle_web_import_test.gd` and agent docs only.
- Added `_get_enemy_portrait_offset_for_facing()`.
- Restored enemy main/support portrait placement for `FACING_UP` / `FACING_DOWN` to use the stable scene-authored fallback offset instead of the vertical template/fallback path that could place the portrait over the unit center or flag.
- Kept left/right enemy portrait placement on the existing template-aware path.
- Kept ally portrait placement unchanged.
- Kept `Battle_Fullscreen_Test.tscn` unchanged.
- Kept `scripts/unit_visual_slot.gd` unchanged.
- Kept HP bar, troop label, layer profile, facing-indicator timing, auto battle, and enemy AI unchanged.

## v0.67f-hotfix Enemy Facing Indicator Hide During Move

- Updated `scripts/battle_web_import_test.gd` and agent docs only.
- Added `_hide_facing_indicator_for_unit()`.
- Hid the current enemy actor's `FacingIndicator` immediately before enemy movement tween start.
- Kept enemy move completion on the existing `_update_facing_indicators()` path so the indicator is repositioned and shown again at the final location.
- Kept ally move / facing-selection UX unchanged.
- Kept `Battle_Fullscreen_Test.tscn` unchanged.
- Kept `scripts/unit_visual_slot.gd` unchanged.
- Kept auto-battle policy unchanged.
- Kept enemy AI actor/target selection unchanged.

## v0.67g MVP 3 Main + 2 Reinforce Layout Plan

- Added `agent/MVP_3_MAIN_2_REINFORCE_LAYOUT_PLAN.md`.
- This step is documentation only.
- Documented:
  - MVP slot goal of `3` main + `2` reinforce per side
  - current stable `2v2` to MVP mapping
  - main-slot placement concept
  - reinforce placement and entry concept
  - editor-first coordinate policy
  - scene tree expansion options
  - naming migration caution
  - future `UnitVisualSlot` / `BattleUnitState` expansion direction
  - auto battle / ClickArea / READY / Facing considerations
  - guide-layer relation
  - key risks
  - staged roadmap from `v0.67h` through `v0.67l`
- Kept `Battle_Fullscreen_Test.tscn` unchanged.
- Kept `scripts/battle_web_import_test.gd` unchanged.
- Kept `scripts/unit_visual_slot.gd` unchanged.

## v0.67f Deployed/Active Slot Filtering

- Updated `scripts/battle_web_import_test.gd` and agent docs only.
- Hardened slot-state helpers:
  - `_is_capacity_slot_active()`
  - `_is_capacity_slot_deployed()`
  - `_is_unit_state_active_by_capacity_slot()`
  - `_is_unit_state_deployed_by_capacity_slot()`
- Added `_is_unit_state_available_for_battle_slot()` as the shared active/deployed/alive battle filter.
- Routed these helpers through the shared filter:
  - `_get_alive_unit_states_for_side_from_adapter()`
  - `_get_alive_deployed_unit_states_for_side()`
  - `_get_actor_candidates_for_side_from_adapter()`
- Kept target helpers on the same filtered alive/deployed path so future non-deployed reinforce slots stay excluded.
- Added one-time startup deployed/active filter snapshot for:
  - capacity active slots by side
  - capacity deployed slots by side
  - actor candidates by side
  - target candidates by side
  - all alive deployed count
  - parity OK
- Added explicit future reinforce policy comment:
  - active but not deployed units stay excluded from actor/target/occupied paths until deployment
- Kept `Battle_Fullscreen_Test.tscn` unchanged.
- Kept `scripts/unit_visual_slot.gd` unchanged.
- Kept auto-battle scoring and policy unchanged.
- Kept enemy AI actor order unchanged.

## v0.67e Actor/Target List Adapter Migration

- Updated `scripts/battle_web_import_test.gd` and agent docs only.
- Added adapter-backed actor helpers:
  - `_get_actor_candidates_for_side_from_adapter()`
  - `_get_available_actor_candidates_for_side_from_adapter()`
- Added adapter-backed target helpers:
  - `_get_alive_target_candidates_for_side_from_adapter()`
  - `_get_target_candidates_for_actor_from_adapter()`
  - `_get_target_candidates_for_actor()`
  - `_get_fallback_target_candidates_for_actor()`
- Added shared comparison helpers:
  - `_get_enemy_ai_target_state_from_candidates()`
  - `_find_best_auto_attack_target_from_candidates()`
  - `_get_first_candidate_from_list()`
- Switched `_get_available_auto_units_for_side()` to adapter-first actor candidates with fallback.
- Switched `_get_alive_auto_targets_for_side()` to adapter-first target candidates with fallback.
- Switched `_get_enemy_ai_target_state_for_actor()` to adapter-first target candidates with fallback while preserving the existing target-selection rule.
- Added one-time startup actor/target snapshot for:
  - actor candidate ally/enemy count
  - target candidate count for ally/enemy actors
  - auto target parity OK
  - enemy AI target parity OK
  - enemy actor order parity OK
- Kept `Battle_Fullscreen_Test.tscn` unchanged.
- Kept `scripts/unit_visual_slot.gd` unchanged.
- Kept enemy AI actor order unchanged.
- Kept auto-battle scoring and policy unchanged.

## v0.67d 2v2 on Scalable Slot Framework

- Updated `scripts/battle_web_import_test.gd` and agent docs only.
- Added adapter-first alive/deployed helpers:
  - `_get_alive_unit_states_for_side_from_adapter()`
  - `_get_alive_deployed_unit_states_for_side()`
  - `_get_all_alive_unit_states_from_adapter()`
  - `_is_battle_unit_state_adapter_ready()`
- Converted these helpers to adapter-first with fixed-state fallback:
  - `_get_alive_ally_units()`
  - `_get_alive_enemy_units()`
  - `_get_all_alive_unit_states()`
  - `_get_alive_enemy_targets()`
- Kept the original fixed-state helper logic available through fallback helpers.
- Added one-time startup parity snapshot for:
  - adapter alive ally/enemy count
  - fallback alive ally/enemy count
  - all alive count
  - active/deployed capacity slot ids
  - parity OK flag
- Kept `Battle_Fullscreen_Test.tscn` unchanged.
- Kept `scripts/unit_visual_slot.gd` unchanged.
- Kept enemy AI actor order unchanged.
- Kept full auto battle policy unchanged.

## v0.67c-hotfix6 Unit Visual Layer Above HP Bar

- Updated `scripts/battle_web_import_test.gd` only.
- Added visual layer constants:
  - shadow `5`
  - hp bar `8`
  - token `12`
  - portrait `13`
  - troop label `20`
- Added `_apply_unit_visual_layer_profile_for_unit()`.
- Applied the runtime layer profile at the end of each per-unit visual refresh path so unit token/portrait render above HP bars.
- Kept positions and scales unchanged.
- Kept HP bar alpha `0.8`.
- Kept troop label alpha `1.0`.
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.

## v0.67c-hotfix5 Keep HP Bar Alpha 80 Percent

- Updated `scripts/battle_web_import_test.gd` only.
- Changed `HP_BAR_RUNTIME_ALPHA` to `0.8`.
- Added:
  - `_apply_hp_bar_runtime_alpha()`
  - `_apply_hp_bar_alpha_for_unit()`
  - `_apply_hp_bar_alpha_to_all_units()`
- Reapplied HP bar alpha after `_set_group_modulate()` and at the end of each per-unit visual refresh path.
- Kept troop label alpha at `1.0`.
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.

## v0.67c-hotfix4 Restore HP Bar Alpha Only

- Updated `scripts/battle_web_import_test.gd` only.
- Added `HP_BAR_RUNTIME_ALPHA := 0.35`.
- Applied runtime alpha reduction to HP bars only inside `_restore_hp_troop_runtime_visibility_for_unit()`.
- Kept troop label alpha at `1.0`.
- Kept `Battle_Fullscreen_Test.tscn` unchanged.
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.

## v0.67c-hotfix3 Restore HP/Troop Scene Layout After Slot Migration

- Updated `Battle_Fullscreen_Test.tscn` only for HP/troop layout scope:
  - `AllyHPBar`
  - `AllyTroopLabel`
  - `AllySupportHPBar`
  - `AllySupportTroopLabel`
  - `EnemyHPBar`
  - `EnemyTroopLabel`
  - `EnemySupportHPBar`
  - `EnemySupportTroopLabel`
- Raised all 8 HP/troop nodes to `z_index = 4` so they draw above the battlefield and unit visuals after slot migration.
- Updated `scripts/battle_web_import_test.gd` to stop overwriting HP/troop positions inside `_restore_hp_troop_runtime_visibility_for_unit()`.
- Kept runtime restore limited to:
  - visible
  - modulate
  - value / max value
  - troop text
  - z-index
- Expanded `_debug_print_hp_troop_runtime_visibility_summary()` with token/hp/troop local-global positions, z-index, and size.
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.

## v0.67c-hotfix2 Remove Remaining GDScript Warnings + Restore Runtime HP/Troop Visibility

- Updated `scripts/battle_web_import_test.gd` only for the requested hotfix2 scope.
- Removed remaining parent-block redeclaration warnings by:
  - reusing single enemy click-hit locals inside `_input()`
  - reusing a single empty visual-node array local inside `_get_visual_group_nodes_for_unit()`
- Replaced remaining mixed / typed ternary warning candidates in helper and debug code with explicit `if/else` branches.
- Added `_debug_print_hp_troop_runtime_visibility_summary()` startup output for all 4 current live slots.
- Added direct live-unit HP/troop restore helpers for:
  - ref lookup
  - visible state
  - modulate reset
  - value / max value
  - troop text
  - overlay position
- Kept `Battle_Fullscreen_Test.tscn` unchanged.
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.

## v0.67c-hotfix State Adapter Warning Fix + HP/TroopLabel Restore

- Updated `scripts/battle_web_import_test.gd` only for the hotfix scope.
- Renamed local `enemy_main_hit` / `enemy_support_hit` variables in `_input()` to avoid parent-block shadowing warnings during GDScript reload.
- Replaced adapter-related typed helper return paths with explicit local typed result branches for:
  - `_get_unit_states_for_side()`
  - `_get_all_battle_unit_states_from_adapter()`
  - `_get_unit_state_for_legacy_slot_id()`
  - `_get_unit_state_for_capacity_slot_id()`
  - `_get_visual_token_paths_for_unit()`
- Hardened lookup helpers so invalid or unmapped `BattleUnitState` values no longer fall through to ally-main visual / click / anchor defaults.
- Reasserted HP bar / troop label visibility for live units from the per-unit visual refresh functions.
- Added one-time startup debug output summarizing:
  - legacy-slot to state binding
  - HP bar ref presence
  - troop label ref presence
  - visual group node count
- Kept `Battle_Fullscreen_Test.tscn` unchanged.
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.

## v0.67c BattleUnitState List Adapter

- Added `BattleUnitState` adapter containers in `scripts/battle_web_import_test.gd`:
  - `ally_unit_states`
  - `enemy_unit_states`
  - `all_battle_unit_states`
  - `unit_state_by_legacy_slot_id`
  - `unit_state_by_capacity_slot_id`
- Added rebuild and lookup helpers for scalable state access without removing the existing fixed `2v2` state variables.
- Rebuild now runs immediately after `_create_demo_unit_states()`.
- Added one-time adapter debug output showing:
  - ally count
  - enemy count
  - all count
  - legacy-slot keys
  - capacity-slot keys
- Kept `Battle_Fullscreen_Test.tscn` unchanged.
- Kept `scripts/unit_visual_slot.gd` unchanged.
- Kept current battle execution and auto-battle flow unchanged.
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.

## v0.67b Slot Registry Array Scaffold

- Added scalable slot scaffold constants in `scripts/battle_web_import_test.gd`:
  - slot-role constants
  - slot-entry constants
  - `7 + 3` final capacity constants
  - `3 + 2` MVP capacity constants
- Added full `20`-slot capacity-id scaffold for:
  - ally main `01` through `07`
  - ally reinforce `01` through `03`
  - enemy main `01` through `07`
  - enemy reinforce `01` through `03`
- Added legacy mapping scaffold for the current stable `2v2` slots:
  - `ally_main` -> `ally_main_01`
  - `ally_support` -> `ally_main_02`
  - `enemy_main` -> `enemy_main_01`
  - `enemy_support` -> `enemy_main_02`
- Added capacity-slot metadata registry helpers and capacity-slot-to-`UnitVisualSlot` bridge helper.
- Added one-time capacity registry debug output at scene launch.
- Kept `Battle_Fullscreen_Test.tscn` unchanged.
- Kept `scripts/unit_visual_slot.gd` unchanged.
- Kept current battle execution and auto-battle flow unchanged.
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.

## v0.67a Scalable Battle Slot Capacity Plan

- Added `agent/SCALABLE_BATTLE_SLOT_CAPACITY_PLAN.md`.
- Documented final per-side capacity target:
  - `7` main slots
  - `3` reinforcement slots
  - `10` total slots per side
- Documented MVP per-side target:
  - `3` main slots
  - `2` reinforcement slots
  - `5` total slots per side
- Documented recommended legacy mapping of the current `2v2` support units into `main_02` semantics.
- Documented future slot metadata, scalable slot naming, state-array direction, auto-battle filtering needs, city-to-battle assignment pipeline, formation direction, roadmap, risks, and QA.
- Kept `Battle_Fullscreen_Test.tscn`, `scripts/battle_web_import_test.gd`, and `scripts/unit_visual_slot.gd` unchanged in this step.

## v0.66i Slot Tree QA Stable

- Revalidated the `Slots` scene structure in `Battle_Fullscreen_Test.tscn`:
  - `AllyMainSlot`
  - `AllySupportSlot`
  - `EnemyMainSlot`
  - `EnemySupportSlot`
- Reconfirmed all 4 actual visual roots remain under their slot nodes.
- Reconfirmed all 4 ClickAreas remain under scene root.
- Reconfirmed ally READY frames and all FacingIndicators remain under `BattleUI`.
- Reconfirmed existing dictionary fallback helpers remain present in `scripts/battle_web_import_test.gd`.
- Reconfirmed `UnitVisualSlot` cache summary at headless scene launch for:
  - `ally_main`
  - `ally_support`
  - `enemy_main`
  - `enemy_support`
- Kept `Battle_Fullscreen_Test.tscn`, `scripts/battle_web_import_test.gd`, and `scripts/unit_visual_slot.gd` unchanged in this step.
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.

## v0.66h EnemySupportSlot Migration

- Added `EnemySupportSlot` under `Slots` in `Battle_Fullscreen_Test.tscn`.
- Reparented only the enemy-support actual visual subtree from:
  - `EnemySide/EnemySupportUnitVisualRoot`
  to:
  - `Slots/EnemySupportSlot/EnemySupportUnitVisualRoot`
- Updated enemy-support visual node references in `scripts/battle_web_import_test.gd`:
  - `enemy_support_unit_visual_root`
  - `enemy_support_move_dust_sprite`
  - `enemy_support_unit_token`
  - `enemy_support_unit_shadow`
  - `enemy_support_portrait_badge`
  - `enemy_support_hp_bar`
  - `enemy_support_troop_label`
- Preserved unmoved attachment nodes:
  - `EnemySupportUnitClickArea`
  - `EnemySupportFacingIndicator`
- Preserved scene structure for:
  - `AllyMainSlot`
  - `AllySupportSlot`
  - `EnemyMainSlot`
- Preserved:
  - slot dictionary fallback helpers
  - `UnitVisualSlot` cache usage
  - enemy AI flow
  - auto battle logic
  - battle-dust logic
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.

## v0.66g EnemyMainSlot Migration

- Added `EnemyMainSlot` under `Slots` in `Battle_Fullscreen_Test.tscn`.
- Reparented only the enemy-main actual visual subtree from:
  - `EnemySide/EnemyUnitVisualRoot`
  to:
  - `Slots/EnemyMainSlot/EnemyUnitVisualRoot`
- Updated enemy-main visual node references in `scripts/battle_web_import_test.gd`:
  - `enemy_unit_visual_root`
  - `enemy_move_dust_sprite`
  - `enemy_unit_token`
  - `enemy_unit_shadow`
  - `enemy_portrait_badge`
  - `enemy_hp_bar`
  - `enemy_troop_label`
- Preserved unmoved attachment nodes:
  - `EnemyUnitClickArea`
  - `EnemyFacingIndicator`
- Preserved scene structure for:
  - `AllyMainSlot`
  - `AllySupportSlot`
  - `EnemySupportUnitVisualRoot`
- Preserved:
  - slot dictionary fallback helpers
  - `UnitVisualSlot` cache usage
  - enemy AI flow
  - auto battle logic
  - battle-dust logic
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.

## v0.66f AllySupportSlot Migration

- Added `AllySupportSlot` under `Slots` in `Battle_Fullscreen_Test.tscn`.
- Reparented only the ally-support actual visual subtree from:
  - `AllySide/AllySupportUnitVisualRoot`
  to:
  - `Slots/AllySupportSlot/AllySupportUnitVisualRoot`
- Updated ally-support visual node references in `scripts/battle_web_import_test.gd`:
  - `ally_support_unit_visual_root`
  - `ally_support_move_dust_sprite`
  - `ally_support_unit_token`
  - `ally_support_unit_shadow`
  - `ally_support_portrait_badge`
  - `ally_support_hp_bar`
  - `ally_support_troop_label`
- Preserved unmoved attachment nodes:
  - `AllySupportUnitClickArea`
  - `AllySupportReadyFrame`
  - `AllySupportFacingIndicator`
- Preserved scene structure for:
  - `AllyMainSlot`
  - `EnemyUnitVisualRoot`
  - `EnemySupportUnitVisualRoot`
- Preserved:
  - slot dictionary fallback helpers
  - `UnitVisualSlot` cache usage
  - enemy AI flow
  - auto battle logic
  - battle-dust logic
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.

## v0.66e AllyMainSlot Migration Spike

- Added `Slots` root and `AllyMainSlot` to `Battle_Fullscreen_Test.tscn`.
- Reparented only the ally-main actual visual subtree from:
  - `AllySide/AllyUnitVisualRoot`
  to:
  - `Slots/AllyMainSlot/AllyUnitVisualRoot`
- Updated ally-main visual node references in `scripts/battle_web_import_test.gd`:
  - `ally_unit_visual_root`
  - `ally_move_dust_sprite`
  - `ally_unit_token`
  - `ally_unit_shadow`
  - `ally_portrait_badge`
  - `ally_hp_bar`
  - `ally_troop_label`
- Preserved unmoved attachment nodes:
  - `AllyUnitClickArea`
  - `AllyReadyFrame`
  - `AllyFacingIndicator`
- Preserved scene structure for:
  - `AllySupportUnitVisualRoot`
  - `EnemyUnitVisualRoot`
  - `EnemySupportUnitVisualRoot`
- Preserved:
  - slot dictionary fallback helpers
  - `UnitVisualSlot` cache usage
  - enemy AI flow
  - auto battle logic
  - battle-dust logic
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.

## v0.66d Scene Slot Tree Migration Plan

- Added `agent/SCENE_SLOT_TREE_MIGRATION_PLAN.md`.
- Documented:
  - current battle-slot tree summary
  - target C-style `Slots/...` direction
  - migration principles
  - Visual / World Interaction / UI Overlay classification
  - ClickArea migration judgment
  - READY frame / FacingIndicator migration judgment
  - staged migration roadmap
  - slot-count expansion preconditions
  - risk summary
  - migration QA checklist
- This step made no changes to:
  - `Battle_Fullscreen_Test.tscn`
  - `scripts/battle_web_import_test.gd`
  - `scripts/unit_visual_slot.gd`

## v0.66c-3 Slot-Based Cleanup / Visibility QA

- Stabilized slot-based cleanup / visibility helpers in `scripts/battle_web_import_test.gd`.
- Updated `_cleanup_dead_units()` to iterate via `_get_all_unit_states_in_slot_order()`.
- Added stronger null guards to:
  - `_get_visual_group_nodes_for_unit()`
  - `_get_click_area_for_unit()`
  - `_get_click_shape_for_unit()`
  - `_get_ready_frame_for_unit()`
  - `_get_facing_indicator_for_unit()`
- Updated `_set_unit_visual_group_visible()` to prefer slot-backed visibility control when a valid `UnitVisualSlot` is available and to preserve existing fallback behavior otherwise.
- Updated `_set_unit_click_area_enabled()` to prefer slot-backed click-area enable/disable control when a valid `UnitVisualSlot` is available and to preserve existing fallback behavior otherwise.
- Added narrow visibility helpers to `scripts/unit_visual_slot.gd`:
  - `set_visual_group_visible()`
  - `set_click_area_enabled()`
  - `set_facing_indicator_visible()`
- Expanded slot debug summary to include `click_shape` presence.
- Preserved:
  - `Battle_Fullscreen_Test.tscn`
  - ClickArea parent structure
  - READY frame parent structure
  - FacingIndicator parent structure
  - auto battle logic
  - enemy AI flow
  - battle-dust logic
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.

## v0.66c-2 Ready/Facing/Click Slot Helper Expansion

- Expanded `UnitVisualSlot` UI / click getter helpers in `scripts/unit_visual_slot.gd`.
- Added:
  - `get_click_area()`
  - `get_click_shape()`
  - `get_ready_frame()`
  - `get_facing_indicator()`
  - `has_click_nodes()`
  - `has_ui_overlay_nodes()`
- Added `_get_click_shape_for_unit()` to `scripts/battle_web_import_test.gd`.
- Updated slot-first helper usage for:
  - `_get_ready_frame_for_unit()`
  - `_update_ally_ready_frames()`
  - `_get_facing_indicator_for_unit()`
  - `_update_facing_indicators()`
  - `_set_facing_indicators_visible()`
  - `_get_click_area_for_unit()`
- Added `_get_all_unit_states_in_slot_order()` for helper-only iteration.
- Preserved:
  - `Battle_Fullscreen_Test.tscn`
  - ClickArea parent structure
  - READY frame parent structure
  - FacingIndicator parent structure
  - existing per-slot facing-indicator position functions
  - auto battle logic
  - enemy AI flow
  - battle-dust logic
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.

## v0.66c-1 UnitVisualSlot Usage Expansion - Safe Helpers

- Expanded `UnitVisualSlot` safe read-only helpers in `scripts/unit_visual_slot.gd`.
- Added:
  - `get_visual_group_nodes()`
  - `has_required_visual_nodes()`
  - `get_debug_summary()`
- Updated safe helper paths in `scripts/battle_web_import_test.gd`:
  - `_debug_print_unit_visual_root_slots()`
  - `_get_visual_group_nodes_for_unit()`
  - `_get_click_area_for_unit()`
  - `_get_facing_indicator_for_unit()`
- Kept these functions slot-first with existing direct-comparison fallback still present.
- Preserved:
  - `_get_ally_group_nodes()`
  - `_get_ally_support_group_nodes()`
  - `_get_enemy_group_nodes()`
  - `_get_enemy_support_group_nodes()`
  - `Battle_Fullscreen_Test.tscn`
  - ClickArea parent structure
  - READY frame parent structure
  - FacingIndicator parent structure
  - auto battle logic
  - enemy AI flow
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.

## v0.66b UnitVisualSlot Lookup Integration

- Integrated cache-first `UnitVisualSlot` lookup helpers into `scripts/battle_web_import_test.gd`.
- Added:
  - `_get_unit_visual_slot_for_slot_id()`
  - `_get_unit_visual_slot_for_state()`
  - `_has_unit_visual_slot_for_state()`
  - `_create_unit_visual_slot_from_dictionary()`
  - `_get_visual_slots_dictionary_fallback_for_slot_id()`
- Updated `_get_unit_visual_slots_for_state()` so it first bridges through `UnitVisualSlot` and then preserves existing direct dictionary fallback behavior.
- Updated `_get_visual_slots_for_slot_id()` so it first resolves a `UnitVisualSlot` and returns a legacy-compatible dictionary view when available.
- Updated `_rebuild_unit_visual_slot_refs()` so cache rebuild uses explicit dictionary fallback instead of recursively going through the public lookup wrapper.
- Added `to_visual_slots_dictionary()` to `scripts/unit_visual_slot.gd` and kept `to_dictionary()` as a compatibility alias.
- Expanded `_debug_print_unit_visual_root_slots()` to include minimal cache-state output:
  - cache presence
  - root
  - token
  - click area
  - ready frame
  - facing indicator
  - dictionary fallback presence
- Preserved:
  - `Battle_Fullscreen_Test.tscn`
  - ClickArea parent structure
  - READY frame parent structure
  - FacingIndicator parent structure
  - existing `_get_*_visual_slots()` dictionary functions
  - 2v2 manual battle loop
  - auto battle logic
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.

## v0.65k-2 Dust Source Isolation + Stale Dust Cleanup Hotfix

- Isolated battle dust further and reduced stale move-dust carryover in `scripts/battle_web_import_test.gd`.
- Large white dust recurrence was traced to:
  - stale `MoveDustSprite` visibility surviving into attack timing
  - battle dust density still being strong enough to resemble white cloud buildup across repeated turns
- Updated battle dust constants:
  - `BATTLE_DUST_ALPHA_MIN := 0.10`
  - `BATTLE_DUST_ALPHA_MAX := 0.22`
  - `BATTLE_DUST_SCALE_MULTIPLIER_MIN := 0.30`
  - `BATTLE_DUST_SCALE_MULTIPLIER_MAX := 0.48`
  - `BATTLE_DUST_DURATION_MIN := 0.10`
  - `BATTLE_DUST_DURATION_MAX := 0.18`
  - `BATTLE_DUST_TINT := Color(0.48, 0.38, 0.24, 1.0)`
  - `BATTLE_DUST_WORLD_Z_INDEX := 2`
- Disabled attack battle dust by turning `_spawn_attack_battle_dust_fx()` into a no-op.
- Kept only hit battle dust as the remaining battle-dust cue.
- Added `_hide_all_move_dust_sprites()` cleanup:
  - before ally attack demo start
  - before enemy basic attack start
  - after ally basic attack finish
- Battle dust still uses only battle-dust-specific constants and still `queue_free()`s at tween end.
- Existing movement dust helper functions were not modified.
- Did not modify:
  - `Battle_Fullscreen_Test.tscn`
  - ClickArea code
  - auto battle logic
  - `AutoBattleButton` runtime geometry
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.

## v0.65k-1 Battle Dust Layer + Density Hotfix

- Reduced battle dust density and lowered its render layer in `scripts/battle_web_import_test.gd`.
- Updated battle dust constants:
  - `BATTLE_DUST_ALPHA_MIN := 0.18`
  - `BATTLE_DUST_ALPHA_MAX := 0.32`
  - `BATTLE_DUST_ATTACK_ALPHA_MIN := 0.12`
  - `BATTLE_DUST_ATTACK_ALPHA_MAX := 0.22`
  - `BATTLE_DUST_SCALE_MULTIPLIER_MIN := 0.45`
  - `BATTLE_DUST_SCALE_MULTIPLIER_MAX := 0.65`
  - `BATTLE_DUST_ATTACK_SCALE_MULTIPLIER_MIN := 0.35`
  - `BATTLE_DUST_ATTACK_SCALE_MULTIPLIER_MAX := 0.5`
  - `BATTLE_DUST_DURATION_MIN := 0.14`
  - `BATTLE_DUST_DURATION_MAX := 0.26`
  - `BATTLE_DUST_TINT := Color(0.62, 0.50, 0.34, 1.0)`
- Battle dust now forces `z_as_relative = false` and uses lower world `z_index`.
- Attack dust now spawns weaker and lower near the attacker foot area.
- Hit dust now spawns lower near the target foot area and remains the main visible dust cue.
- Existing movement dust helper functions were not modified.
- Did not modify:
  - `Battle_Fullscreen_Test.tscn`
  - ClickArea code
  - auto battle logic
  - `AutoBattleButton` runtime geometry
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.

## v0.65k Battle Dust FX Profile Tuning

- Added battle-dust-only tuning to `scripts/battle_web_import_test.gd`.
- Added:
  - `BATTLE_DUST_ALPHA_MIN`
  - `BATTLE_DUST_ALPHA_MAX`
  - `BATTLE_DUST_SCALE_MULTIPLIER_MIN`
  - `BATTLE_DUST_SCALE_MULTIPLIER_MAX`
  - `BATTLE_DUST_DURATION_MIN`
  - `BATTLE_DUST_DURATION_MAX`
  - `BATTLE_DUST_TINT`
  - `_spawn_attack_battle_dust_fx()`
  - `_spawn_hit_battle_dust_fx()`
  - `_spawn_battle_dust_fx()`
- Attack and hit dust now use a beige / dirt-tinted lower-opacity profile instead of bright white-looking dust.
- Battle dust now spawns lower on the unit footprint and behind slash / hit spark FX.
- Existing movement dust path was preserved.
- Existing attack slash / hit spark / damage number flow was preserved.
- Did not modify:
  - `Battle_Fullscreen_Test.tscn`
  - ClickArea code
  - auto battle loop logic
  - `AutoBattleButton` runtime geometry
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.

## v0.65j-5a Auto Battle Stop UX Hotfix

- Updated `_refresh_auto_battle_button_state()` so `AutoBattleButton` stays enabled while full auto battle is ON.
- Full auto ON state now forces button text to `자동중지` and leaves the button clickable during enemy/resolving phases.
- Updated `_toggle_full_auto_battle()` so a user button press during auto battle routes through `_stop_full_auto_battle("user stop")`.
- Kept stop behavior soft:
  - current action tween is not force-killed
  - current enemy AI action is not force-killed
  - deferred auto ticks return immediately once auto battle is OFF
- Did not modify:
  - `Battle_Fullscreen_Test.tscn`
  - `AutoBattleButton` position/offset/size at runtime
  - ClickArea code
  - `_play_enemy_ai_for_actor()`
  - `_get_enemy_ai_target_state_for_actor()`
- Did not add a direct `while` loop for auto battle flow.
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.

## v0.65j-5 Full Auto Battle Loop Prototype

- Added full auto battle prototype state to `scripts/battle_web_import_test.gd`.
- Added:
  - `AUTO_BATTLE_MAX_STEPS`
  - `is_full_auto_battle_enabled`
  - `auto_battle_step_count`
  - `_toggle_full_auto_battle()`
  - `_set_full_auto_battle_enabled()`
  - `_tick_full_auto_battle_if_needed()`
  - `_stop_full_auto_battle()`
  - `_refresh_auto_battle_button_state()`
- `AutoBattleButton` now toggles full auto battle ON/OFF instead of firing a single one-action step directly.
- Full auto loop uses `call_deferred()` for step progression.
- Direct `while` loop was not added for auto battle flow.
- Added step-limit safety guard with `AUTO_BATTLE_MAX_STEPS`.
- Reused existing ally auto action path and existing enemy AI turn flow.
- Kept `AutoBattleButton` runtime behavior limited to text/disabled state updates only.
- Did not modify:
  - `AutoBattleButton` position/offset/size at runtime
  - ClickArea code
  - `_play_enemy_ai_for_actor()`
  - `_get_enemy_ai_target_state_for_actor()`
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.

## v0.65j-4 Auto Battle Button Hook

- Added `AutoBattleButton` under `BattleUI/CommandBar`.
- Adjusted `CommandBarLabel` text so the new button does not conflict with the static label text.
- Added `@onready` lookup for `AutoBattleButton` in `scripts/battle_web_import_test.gd`.
- Connected `auto_battle_button.pressed` to `_run_auto_action_for_active_ally_once()`.
- Added `AutoBattleButton` enable/disable handling in `_set_phase()`.
- Button scope is limited to one active ally auto action.
- Full auto battle loop is still not implemented.
- Preserved existing manual command buttons and their behavior.
- Did not modify ClickArea code.
- Did not modify:
  - `_play_enemy_ai_for_actor()`
  - `_get_enemy_ai_target_state_for_actor()`
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.

## v0.65j-3a Auto Move + Auto Facing Completion

- Extended ally auto action MVP to complete movement execution and post-move facing automatically.
- `_try_auto_move_for_active_ally()` now starts real ally movement through the existing `play_basic_move_demo()` path when a valid auto move cell exists.
- Added auto-action flow flags:
  - `is_auto_action_in_progress`
  - `should_auto_select_facing_after_move`
- Added:
  - `_clear_auto_action_flags()`
  - `_get_best_auto_facing_toward_nearest_enemy()`
  - `_select_auto_facing_after_move_for_active_ally()`
- `_finish_basic_move_demo()` now auto-completes facing only for auto-move flow.
- Manual post-move facing selection flow was preserved for non-auto movement.
- Auto facing points toward the nearest living enemy and preserves current facing if no enemy exists.
- Auto battle button still not connected.
- Full auto battle loop still not implemented.
- Did not modify:
  - `Battle_Fullscreen_Test.tscn`
  - ClickArea code
  - `_play_enemy_ai_for_actor()`
  - `_get_enemy_ai_target_state_for_actor()`
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.

## v0.65j-3 Ally Auto Battle One-Action MVP

- Added ally auto one-action MVP functions to `scripts/battle_web_import_test.gd`.
- Added:
  - `_run_auto_action_for_active_ally_once()`
  - `_try_auto_attack_for_active_ally()`
  - `_try_auto_move_for_active_ally()`
  - `_auto_wait_active_ally()`
- Auto attack MVP now resolves the best attackable target for the current active ally and starts the existing ally attack flow.
- Auto move MVP is intentionally limited to move target selection and validation only.
- Auto move execution and automatic facing completion were deferred to a follow-up step.
- Auto wait remains scaffold-level and is not connected to ally turn completion yet.
- Did not add an auto battle button.
- Did not add a full auto battle loop.
- Did not modify:
  - `Battle_Fullscreen_Test.tscn`
  - ClickArea code
  - `_play_enemy_ai_for_actor()`
  - `_get_enemy_ai_target_state_for_actor()`
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.

## v0.65j-2 Auto Battle Helper Functions Scaffold

- Added auto battle helper scaffold functions to `scripts/battle_web_import_test.gd`.
- Added:
  - `_get_available_auto_units_for_side()`
  - `_get_alive_auto_targets_for_side()`
  - `_can_auto_kill_target()`
  - `_score_auto_attack_target()`
  - `_find_best_auto_attack_target()`
  - `_find_best_auto_move_cell()`
  - `_debug_print_auto_battle_policy_snapshot()`
- Added internal auto helper support functions:
  - `_get_auto_damage_for_actor()`
  - `_get_auto_slot_priority()`
  - `_get_auto_move_path_for_actor()`
- Kept the new helpers disconnected from current battle execution flow.
- Did not modify:
  - `_play_enemy_ai_for_actor()`
  - `_get_enemy_ai_target_state_for_actor()`
  - current manual ally control flow
- Did not modify ClickArea code.
- Did not modify scene files.
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.

## v0.65j-1 Auto Battle Action Policy Design

- Added `agent/AUTO_BATTLE_ACTION_POLICY.md`.
- Defined auto battle as a data-based action policy using:
  - `BattleUnitState`
  - `grid_cell`
  - `attack_range`
  - `hp`
  - `side`
  - `has_acted`
- Explicitly separated auto battle policy from click overlap and `ClickArea` logic.
- Documented the expected one-action auto battle flow:
  - actor selection
  - living enemy list
  - immediate attack check
  - target priority selection
  - movement destination selection
  - post-move attack or wait
  - action completion
- Documented draft target priority order:
  - killable target
  - currently attackable target
  - lower HP target
  - closer target
  - main slot priority
  - stable array order fallback
- Documented draft movement priority order:
  - move to attackable cell
  - reduce distance
  - avoid occupied cells
  - keep path clear
  - prefer better follow-up attack potential
  - wait if no useful move exists
- Documented reusable current implementation candidates from `battle_web_import_test.gd`.
- Did not modify code or scene files.

## v0.65i-3 READY/Facing UI Slot Registry Cleanup

- Kept `READY frame` nodes under `BattleUI`.
- Kept `FacingIndicator` nodes under `BattleUI`.
- Kept `ready_frame` / `facing_indicator` entries in:
  - `_get_ally_main_visual_slots()`
  - `_get_ally_support_visual_slots()`
  - `_get_enemy_main_visual_slots()`
  - `_get_enemy_support_visual_slots()`
- Added slot-based helper lookup for READY frame resolution.
- Switched READY frame refresh to resolve slot UI through slot lookup instead of direct node pairing.
- Added slot-based helper lookup for FacingIndicator resolution.
- Switched FacingIndicator refresh to resolve slot UI through slot lookup while preserving the existing per-slot position functions.
- Added shared visual-anchor helper with `slot_id` first dispatch and existing direct comparison fallback.
- Preserved:
  - `_position_ready_frame_for_unit()`
  - `_position_facing_indicator_for_ally()`
  - `_position_facing_indicator_for_ally_support()`
  - `_position_facing_indicator_for_enemy()`
  - `_position_facing_indicator_for_enemy_support()`
  - `_world_to_battle_ui_position()`
- Did not move any scene nodes.
- Did not modify ClickArea code.
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.

## v0.65h Slot-Based UnitVisual Architecture Design Stable

- Extended BattleUnitState with slot-based metadata.
- Added fields:
  - slot_id
  - nation
  - portrait_key
  - domain
  - footprint
  - move_fx_profile
  - attack_fx_profile
  - click_area_profile
  - visual_scale_profile
- Injected slot metadata into the four current demo units.
- Added slot_id-first UnitVisual slot lookup.
- Preserved direct unit_state comparison fallback.
- Confirmed visual_key values remain unchanged:
  - korea_archer
  - korea_gunner
  - china_cavalry
  - china_infantry
- Preserved current 2v2 battle loop, FX, UnitCloseupPanel, READY frame, HP 0 cleanup, active ally lock.
- Did not migrate ClickArea / READY frame / FacingIndicator.

## v0.65g Root Migration Stable QA Verified

- Added UnitVisualRoot Adapter Layer.
- Migrated Ally main visual nodes under AllyUnitVisualRoot.
- Migrated Ally support visual nodes under AllySupportUnitVisualRoot.
- Migrated Enemy main visual nodes under EnemyUnitVisualRoot.
- Migrated Enemy support visual nodes under EnemySupportUnitVisualRoot.
- Kept ClickArea / READY frame / FacingIndicator outside Root for safety.
- Kept UnitVisualTemplate nodes as layout offset references.
- Fixed ally portrait FACING_UP / FACING_DOWN offset issue.
- Fixed dead enemy main click priority blocking enemy support target selection.
- Verified 2v2 battle loop, FX, UnitCloseupPanel, HP 0 cleanup, active ally lock.
- Prepared direction for future slot-based UnitVisual architecture.

## v0.65e Unit Token Asset Normalize Apply Verified

- Normalized Korea/China/Japan infantry/archer/gunner/cavalry tokens to 256 baseline.
- Added country/type based visual_key mapping.
- Updated test units:
  - Yi Sun-sin = korea_archer
  - Jeong Do-jeon = korea_gunner
  - Guan Yu = china_cavalry
  - Zhang Fei = china_infantry
- Removed dependency on legacy 1024 China infantry for current test units.
- Preserved FX Pack 1, Round Toast, idle breathing, turn flow, active ally lock, and cleanup.
