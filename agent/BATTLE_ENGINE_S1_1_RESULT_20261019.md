# S1-1 Observation baseline — local Level 2 result (2026-10-19)

## Scope and Git

- Branch: `refactor/s1-1-observation-baseline-20261019`
- Verified remote integration base: `62f5b726260aa3e6134225e7e903b1098792f23a`.
- Separate first audit-only commit: `1a43e378e5aaa125be74f3022b5e3d665a98f6cf`.
- Implementation commit is the commit containing this report (resolve with `git log -1 --format=%H -- agent/BATTLE_ENGINE_S1_1_RESULT_20261019.md`). Exact final hash is supplied in the external closeout.
- Independent checkout; Production, existing controllers/services/scenes/tests and 3D code unchanged. No push, merge or S1-2 implementation.
- Godot 4.6.2 stable; Python 3.14. Local checks only. CI has not run; workflow receives four call lines only, no branch-trigger changes.

## Observed results

| Case | Actual controller result | Repetition |
|---|---|---|
| M1 | [2,2] -> [4,2], two steps; manual down facing; pending cleared; moved but not acted | Twice identical |
| M2 | Four-step detour via [2,3],[3,3],[4,3]; moved_distance remains Manhattan 2 | Twice identical |
| M3 | Occupied destination, outside move budget, enclosed/no path: all unit fingerprints and three controller fields unchanged | Each twice identical |
| M4 | [2,2] -> [2,4], vertical steps retain left facing; actual right-click restores cell/facing/has_moved/ally_has_moved, clears pending; last_action stays the movement action | Twice identical |
| M5 | Valid move + confirmation, then retry rejected; unit/controller snapshot unchanged | Twice identical |

All 7 cases / 14 runs use actual Battle_Main, movement Tween and frame progression into FACING_SELECT. No controller completion is faked. Events are test-observed values, not production event wiring. Fixture and exclusion details are in `BATTLE_ENGINE_EVENT_SCHEMA_MIN_v0_20261019.md`.

Default oracle: 283 checks, zero failures. Explicit generation: 282 checks, zero failures. Default run preserved golden SHA-256 `b35d3f7987bb2efca5efe1d379b6eddc00cdca1558c17e88733dd1389cf714bd`.

## Limitations, errors and S1-0 comparison

No behavior discrepancy from S1-0 was found in covered flows: grid-distance movement metadata, vertical-facing retention and cancellation last_action non-restoration were reproduced. This does not prove untested attack/turn/AI behavior.

During development the new fingerprint service needed an explicit Array type and recursive numeric equivalence for JSON int/float round trips; both are fixed and retested. Initial teardown freed the scene while the production camera guard awaited frames/timer; harness-only draining fixed that callback error. The final oracle has no script/camera-resumption errors.

The final oracle and unchanged movement/combat tests each exit 0 but print ObjectDB leak and '2 resources still in use at exit' diagnostics. These are recorded below, not presented as a warning-free run. Production cleanup changes are outside this scope. Other tested commands pass without those diagnostics.

Not executed: interactive mouse/visual verification for S1-1, remote CI, full unrelated worldmap suites, S1-2 wiring. The requested controller flows were exercised headlessly; this is scoped Level 2, not full-project green.

## Raw local test/validator outputs

The following blocks preserve full combined stdout/stderr of final runs. Commands use repository-relative paths; the full local executable path is intentionally omitted.

### test_battle_event_log_service (exit 0)

```text
godot --headless --path . --script tests/scripts/test_battle_event_log_service.gd
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[BATTLE_EVENT_LOG] PASS: 20 checks, 0 failures
```

### test_battle_state_fingerprint_service (exit 0)

```text
godot --headless --path . --script tests/scripts/test_battle_state_fingerprint_service.gd
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[BATTLE_STATE_FINGERPRINT] PASS: 53 checks, 0 failures
```

### test_battle_move_oracle_baseline (exit 0)

```text
godot --headless --path . --script tests/scripts/test_battle_move_oracle_baseline.gd
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[ROLLBACK] snapshot stored unit=이순신 cell=(2, 2)
[MOVE_FINISH] ally=(4, 2) enemy=(14, 6) dist=14 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (4, 2) target_cell: (4, 2)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[ROLLBACK] snapshot stored unit=이순신 cell=(2, 2)
[MOVE_FINISH] ally=(4, 2) enemy=(14, 6) dist=14 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (4, 2) target_cell: (4, 2)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
[MOVE_ORACLE_CASE] M1 PASS: runs=2 deterministic=true checkpoints=3
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[ROLLBACK] snapshot stored unit=이순신 cell=(2, 2)
[MOVE_FINISH] ally=(4, 2) enemy=(14, 6) dist=14 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (4, 2) target_cell: (4, 2)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[ROLLBACK] snapshot stored unit=이순신 cell=(2, 2)
[MOVE_FINISH] ally=(4, 2) enemy=(14, 6) dist=14 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (4, 2) target_cell: (4, 2)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
[MOVE_ORACLE_CASE] M2 PASS: runs=2 deterministic=true checkpoints=3
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[OCCUPIED BLOCK] mover=이순신 target=(3, 2) occupied_by_other=true
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[OCCUPIED BLOCK] mover=이순신 target=(3, 2) occupied_by_other=true
[MOVE_ORACLE_CASE] M3_occupied PASS: runs=2 deterministic=true checkpoints=2
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[MOVE_ORACLE_CASE] M3_range PASS: runs=2 deterministic=true checkpoints=2
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[MOVE_ORACLE_CASE] M3_no_path PASS: runs=2 deterministic=true checkpoints=2
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[ROLLBACK] snapshot stored unit=이순신 cell=(2, 2)
[MOVE_FINISH] ally=(2, 4) enemy=(14, 6) dist=14 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (2, 4) target_cell: (2, 4)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
[RIGHT_CLICK_CANCEL] phase=facing_select
[ROLLBACK] phase=facing_select
[ROLLBACK] unit=이순신 cell=(2, 2)
[ROLLBACK] restored unit=이순신 grid=(2, 2)
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[ROLLBACK] snapshot stored unit=이순신 cell=(2, 2)
[MOVE_FINISH] ally=(2, 4) enemy=(14, 6) dist=14 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (2, 4) target_cell: (2, 4)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
[RIGHT_CLICK_CANCEL] phase=facing_select
[ROLLBACK] phase=facing_select
[ROLLBACK] unit=이순신 cell=(2, 2)
[ROLLBACK] restored unit=이순신 grid=(2, 2)
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
[MOVE_ORACLE_CASE] M4 PASS: runs=2 deterministic=true checkpoints=3
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[ROLLBACK] snapshot stored unit=이순신 cell=(2, 2)
[MOVE_FINISH] ally=(4, 2) enemy=(14, 6) dist=14 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (4, 2) target_cell: (4, 2)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[ROLLBACK] snapshot stored unit=이순신 cell=(2, 2)
[MOVE_FINISH] ally=(4, 2) enemy=(14, 6) dist=14 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (4, 2) target_cell: (4, 2)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
[MOVE_ORACLE_CASE] M5 PASS: runs=2 deterministic=true checkpoints=4
[MOVE_ORACLE_GOLDEN] PASS: unchanged baseline
[BATTLE_MOVE_ORACLE] PASS: 283 checks, 0 failures; scenarios=5; cases=7; runs=14
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 2 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)
```

### test_battle_movement_query_service (exit 0)

```text
godot --headless --path . --script tests/scripts/test_battle_movement_query_service.gd
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_MOVEMENT_QUERY_SERVICE] PASS: 30 checks, 0 failures
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 2 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)
```

### test_battle_combat_query_service (exit 0)

```text
godot --headless --path . --script tests/scripts/test_battle_combat_query_service.gd
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_COMBAT_QUERY_SERVICE] PASS: 29 checks, 0 failures
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 2 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)
```

### test_battle3d_movement_parity (exit 0)

```text
godot --headless --path . --script tests/scripts/test_battle3d_movement_parity.gd
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

SCENARIO PASS empty_infantry budget=3
SCENARIO PASS empty_cavalry budget=4
SCENARIO PASS empty_archer budget=3
SCENARIO PASS empty_gunner budget=2
SCENARIO PASS empty_mounted_archer budget=4
SCENARIO PASS blockers_false budget=3
SCENARIO PASS blockers_true budget=3
SCENARIO PASS edge_(0, 0) budget=3
SCENARIO PASS edge_(17, 9) budget=3
SCENARIO PASS edge_(0, 5) budget=3
SCENARIO PASS edge_(17, 0) budget=3
SCENARIO PASS status_{ "mobility_up": 2 } budget=4
SCENARIO PASS status_{ "movement_down": 2 } budget=2
SCENARIO PASS zero_budget budget=0
SCENARIO PASS enclosed budget=3
[BATTLE3D_PARITY] PASS: 66132 checks, 0 failures; scenarios=15; visible_rays=540
```

### test_battle3d_modes (exit 0)

```text
godot --headless --path . --script tests/scripts/test_battle3d_modes.gd
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

{"event":"ready","grid":"18x10 square","milliseconds":545,"renderer":"gl_compatibility","units":4}
{"event":"move_accepted","milliseconds":566,"steps":2,"unit_id":"lab_ally_01"}
[BATTLE3D_MODES] PASS: 20 checks, 0 failures
```

### validate_b1b_battle_movement_query_service (exit 0)

```text
python tools/validate_b1b_battle_movement_query_service.py
B-1B BattleMovementQueryService static validation: PASS
```

### validate_b1c_battle_combat_query_service (exit 0)

```text
python tools/validate_b1c_battle_combat_query_service.py
B-1C BattleCombatQueryService static validation: PASS
```

### validate_b1d_battle_damage_formula_service (exit 0)

```text
python tools/validate_b1d_battle_damage_formula_service.py
B-1D BattleDamageFormulaService static validation: PASS
```

### validate_b1e_battle_action_lock_state_service (exit 0)

```text
python tools/validate_b1e_battle_action_lock_state_service.py
B-1E BattleActionLockStateService static validation: PASS
```

### validate_alternating_battle_action_order (exit 0)

```text
python tools/validate_alternating_battle_action_order.py
ALTERNATING BATTLE ACTION ORDER PASS: 3v3/3v2/2v3/1v5/5v1/1v1/skip contract, one-enemy completion, exhaustion and supply boundary
```

### validate_single_side_exhaustion_turn_order (exit 0)

```text
python tools/validate_single_side_exhaustion_turn_order.py
ONE-SIDE EXHAUSTION TURN ORDER PASS: 1v5/5v1/1v1/skip contracts; no acted-ally input deadlock; one round and supply settlement
```

## Scope guard and negative probes

Separate local clone; original branch never received injected faults. Both deliberate faults exit 1; restored copy and original exit 0.

```text
S1_1_OBSERVATION_BASELINE PASS: 18 paths; controllers byte-identical; workflow +4/-0; golden 5 scenarios / 7 cases
```

```text
PROBE control exit=0
S1_1_OBSERVATION_BASELINE PASS: 18 paths; controllers byte-identical; workflow +4/-0; golden 5 scenarios / 7 cases


PROBE forbidden await exit=1
S1_1_OBSERVATION_BASELINE FAIL: forbidden token in battle_event_log_service: await


PROBE controller one-byte change exit=1
S1_1_OBSERVATION_BASELINE FAIL: non-addition forbidden: M scripts/battle_web_import_test.gd


PROBE restored control exit=0
S1_1_OBSERVATION_BASELINE PASS: 18 paths; controllers byte-identical; workflow +4/-0; golden 5 scenarios / 7 cases
```

## Raw final path diff

Staged tree against base (identical path diff after commit):

```text
M	.github/workflows/verify-c-track.yml
A	agent/BATTLE_ENGINE_EVENT_SCHEMA_MIN_v0_20261019.md
A	agent/BATTLE_ENGINE_S1_0_ACTION_EVENT_AUDIT_20261019.md
A	agent/BATTLE_ENGINE_S1_1_RESULT_20261019.md
A	scripts/battle/services/battle_event_log_service.gd
A	scripts/battle/services/battle_event_log_service.gd.uid
A	scripts/battle/services/battle_state_fingerprint_service.gd
A	scripts/battle/services/battle_state_fingerprint_service.gd.uid
A	tests/golden/battle_move_baseline_v0.json
A	tests/scripts/support/battle_move_oracle_harness.gd
A	tests/scripts/support/battle_move_oracle_harness.gd.uid
A	tests/scripts/test_battle_event_log_service.gd
A	tests/scripts/test_battle_event_log_service.gd.uid
A	tests/scripts/test_battle_move_oracle_baseline.gd
A	tests/scripts/test_battle_move_oracle_baseline.gd.uid
A	tests/scripts/test_battle_state_fingerprint_service.gd
A	tests/scripts/test_battle_state_fingerprint_service.gd.uid
A	tools/validate_battle_s1_1_observation_baseline.py
```

Workflow numstat (added / deleted):

```text
4	0	.github/workflows/verify-c-track.yml
```
