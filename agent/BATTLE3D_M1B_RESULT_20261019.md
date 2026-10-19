# M1-b — 3D 실제 엔진 이동 연결 결과

## 착수 점검 및 승인 반영

기준 `integration/p1-engine-core-20261019` @ `22b7ee73f567132ad1b8060adae4a4bb8d2f5e8c`를 fetch 후 확인했다. 작업 브랜치는 `feature/battle3d-m1b-engine-move-20261019`. push/merge 없음.

1. SubViewport에서 UI hover=false, 이동 범위 overlay=true. 기존 이동 호출 수락 후 실제 Tween/타이머로 facing_select 도달.
2. UPDATE_DISABLED에서도 엔진 진행 정상. 2D 카메라/CanvasLayer는 독립 SubViewport에 격리하며, 실제 3D 화면에 2D HUD가 나타나지 않음을 캡처로 확인.
3. 초기에는 전투 씬 삭제 후 전역 round_start 음성이 남았다. 사용자 승인 후 신규 host `_exit_tree`에만 stop/stream 해제를 추가. 전역 설정/기존 오디오 파일은 변경하지 않았다. M7 공유 환경에서는 재검토한다.
4. 기존 3D contract validator의 조회 전용 금지 조건과 호스팅 요구가 충돌했다. 사용자 승인에 따라 **`file != S/'battle3d_engine_host.gd'`라는 정확한 Path 비교 하나**만 예외로 추가. WorldMap 금지 및 다른 검사는 유지.
5. 초기 preflight 진단 스크립트와 UID는 최종 트리에서 제거했다. CI에는 최종 통합 테스트와 M1-b validator **2줄만 추가(+2/-0)**. 초기 진단 원문은 아래 보존.

## 구현 결과

- 독립 진입점: `scenes/battle3d/Battle3D_EnginePlayLab.tscn`.
- 신규 host가 실제 Battle_Main을 SubViewport에 호스팅. intro가 준비된 뒤 skip하고 ally_turn 진입 후 3D 입력 활성화.
- 3D → 엔진 호출은 선택, 직접 이동, 방향 확정, 우클릭 취소의 기존 4개 함수만 사용. 논리 상태를 쓰지 않는다.
- 10개 유닛 표시는 14필드 adapter의 deep copy. 병사 수는 기존 6명 편성을 재사용. archer/gunner는 infantry 임시 모델을 쓰되 병종 라벨/실제 view 값은 보존.
- 기존 terrain/camera/lighting/formation을 상속 재사용. 기존 3D 파일 수정 없음.
- terrain ray → grid cell로 선택/목적지를 전달. 엔진이 이동 가능 여부와 경로를 검증한다. 범위 표시는 기존 query adapter 사용.
- 이동 연출은 ally_move_event_log의 실제 unit_moved.path만 재생. 엔진 phase가 연출보다 먼저 진행해도 입력을 막지 않는다. 연출 완료 후 엔진 셀로 reconcile. 취소는 잔여 연출을 버리고 엔진 상태에 즉시 맞춘다.
- 방향 선택 UI는 facing_select에만 표시. 공격/적 턴/턴 종료는 아직 연결하지 않았다.

## 숨은 2D 의존성

현재 Battle_Main이 이동 Tween, step facing callback, 최종 위치/메타데이터, pending move snapshot, HUD phase/방향 선택 callback, camera guard timer, toast 및 효과음을 구동한다. 렌더만 꺼져 있으며 논리/타이머는 계속 진행한다. 3D는 그 결과를 읽는다. 엔진 분리 후 렌더/HUD 없이 같은 명령·이벤트·취소·phase 의미를 보장할 수 있을 때 이 임시 호스트를 제거한다.

## 검증 결과

- 전체 워크플로: 88명령(29 validator, 55 GDScript 테스트, 3 씬 로드, 1 editor parse), 모두 exit 0, 명령당 timeout 120초.
- 이후 테스트만 보강: 실제 연출 경로 자체, pending move 상태에서 raw 우클릭 격리, 연출 중 종료·재시작. 최종 통합 **143 checks, failures=[]**. 구현 변경 없이 보강된 테스트와 정상 대조군 재검증.
- S1-1 오라클, S1-2 단위/이벤트 parity 및 B3D-F1 테스트는 변경 없이 통과. 골든 SHA-256 `b35d3f7987bb2efca5efe1d379b6eddc00cdca1558c17e88733dd1389cf714bd` 유지.
- 변조 4종 모두 exit 1. 정상/복원 대조군 exit 0. 별도 복사본만 수정했고 종료 후 원상 복구.
- 기존 컨트롤러/서비스/씬/project.godot/기존 3D 파일 diff 없음. 신규 범위 validator는 허용 경로, 정확한 legacy validator diff, command allowlist, 상태 쓰기/setter, 이동 규칙 중복 구현을 검사한다.
- push 금지로 원격 CI 실행은 요청하지 않았다. 로컬 워크플로 명령 실행 결과다.

## 실제 창 조작 증거

Godot compatibility renderer로 독립 씬 실행. 새 실행에서 이순신 (3,8) 클릭 → (3,5) 이동 → facing_select → 우클릭 취소로 (3,8) 복원 → 재선택 → (3,6) 이동 → Confirm right → ally_turn 확인. Wheel zoom, E 회전, D 이동도 확인. 기존 Godot 편집기는 유지하고 검증 게임 창만 닫았다.

`M1B_Evidence/`의 `manual_selected.png`, `manual_moving.png`, `manual_facing.png`, `manual_cancelled.png`, `manual_removing.png`, `manual_confirmed.png`, `manual_camera_orbit.png`, `manual_camera_pan.png`에 저장했다. 이동 캡처에서는 엔진이 먼저 facing_select에 도달했고 3D 병사가 뒤따라 이동하는 상태가 보인다.

이는 Codex 조작 증거이며 김작 직접 확인/클코치 독립 G0–G4 검수를 대체하지 않는다. 짧은 시연 영상은 제작하지 않았다.

## 환경 오류와 남은 한계

격리 환경의 Python/Start-Process 자식 Godot가 초기화 시 native signal 11로 종료했다. 같은 기존 calendar 테스트는 직접 PowerShell 실행에서 PASS, 격리 밖 동일 Python 호출에서도 PASS. 격리 밖에서 전체 88명령과 GUI가 정상 실행됐다. 엔진 소스/설정은 바꾸지 않았다. OS/샌드박스 내부 원인까지 확정한 것은 아니다.

기존 테스트 및 신규 테스트 종료에 ObjectDB/resource 경고(보통 2개, 일부 실행 4개), editor parse에 기존 duplicate UID 경고가 남는다. exit 0과 경고를 구분하며 경고까지 없는 상태라고 보고하지 않는다. 새 검사에서 엔진 인스턴스가 해제되고 오디오 playing=false/stream=null임은 별도 assert로 확인했다.

M1-b 연결 범위는 이동/방향/취소까지다. 이동 확정 뒤 엔진의 선택 잠금은 유지되므로 공격·행동 완료가 미연결인 이번 Lab에서는 다른 부대 선택이 제한될 수 있다. 이 규칙을 3D에서 우회하지 않는다. 다음은 독립 검수 후 M2 공격 연결이며 M0~M6 전체 한 판 완주가 완료된 것은 아니다. M7 월드맵 왕복은 계속 분리한다.

## 전체 회귀 명령/exit/초

| 명령 | exit | 초 |
|---|---:|---:|
| `python tools/validate_worldmap_main_integrity.py` | 0 | 0.12 |
| `python tools/validate_worldmap_diplomacy_controller_extraction.py` | 0 | 1.06 |
| `python tools/validate_worldmap_diplomacy_routing.py` | 0 | 2.72 |
| `python tools/validate_worldmap_diplomacy_service_separation.py` | 0 | 0.53 |
| `python tools/validate_worldmap_trade_routing.py` | 0 | 0.48 |
| `python tools/validate_worldmap_trade_controller_extraction.py` | 0 | 0.45 |
| `python tools/validate_worldmap_trade_phase2_extraction.py` | 0 | 0.19 |
| `python tools/validate_worldmap_spy_routing.py` | 0 | 0.65 |
| `python tools/validate_worldmap_spy_controller_extraction.py` | 0 | 0.64 |
| `python tools/validate_worldmap_battle_settlement_applier_extraction.py` | 0 | 0.2 |
| `python tools/validate_worldmap_t03_strategic_battle_transaction_extraction.py` | 0 | 0.21 |
| `python tools/validate_worldmap_t03_battle_presentation_extraction.py` | 0 | 0.56 |
| `python tools/validate_worldmap_player_attack_deployment_service_extraction.py` | 0 | 0.72 |
| `python tools/validate_worldmap_wounded_recovery_service_extraction.py` | 0 | 0.21 |
| `python tools/validate_worldmap_to_battle_input_lifecycle.py` | 0 | 0.11 |
| `python tools/validate_b0b_battle_production_skeleton.py` | 0 | 0.11 |
| `python tools/validate_b0c_battle_iso_promotion.py` | 0 | 0.11 |
| `python tools/validate_b1b_battle_movement_query_service.py` | 0 | 0.24 |
| `python tools/validate_b1c_battle_combat_query_service.py` | 0 | 0.21 |
| `python tools/validate_b1d_battle_damage_formula_service.py` | 0 | 0.19 |
| `python tools/validate_b1e_battle_action_lock_state_service.py` | 0 | 0.3 |
| `python tools/validate_b1f_battle_enemy_ai_reservation_state_service.py` | 0 | 0.21 |
| `python tools/validate_b1g_battle_unique_skill_cooldown_state_service.py` | 0 | 0.19 |
| `python tools/validate_battle_s1_1_observation_baseline.py` | 0 | 0.81 |
| `python tools/validate_battle_s1_2_ally_move_state_service.py` | 0 | 1.57 |
| `python tools/validate_battle3d_m1b_engine_move.py` | 0 | 0.42 |
| `python tools/validate_battle3d_contract.py` | 0 | 0.12 |
| `python tools/validate_alternating_battle_action_order.py` | 0 | 0.14 |
| `python tools/validate_single_side_exhaustion_turn_order.py` | 0 | 0.12 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_city_administration_service_extraction.gd` | 0 | 0.44 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_city_resource_service_extraction.gd` | 0 | 0.43 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_city_detail_presentation_extraction.gd` | 0 | 0.53 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_camera_controller_extraction.gd` | 0 | 0.43 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_hud_controller_extraction.gd` | 0 | 0.53 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_shared_ui_controller_extraction.gd` | 0 | 0.55 |
| `godot --headless --path . --script res://tests/scripts/test_world_calendar_service_extraction.gd` | 0 | 0.56 |
| `godot --headless --path . --script res://tests/scripts/test_world_turn_economy_service_extraction.gd` | 0 | 0.48 |
| `godot --headless --path . --script res://tests/scripts/test_world_turn_state_service_extraction.gd` | 0 | 0.44 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_turn_controller_extraction.gd` | 0 | 0.54 |
| `godot --headless --path . --script res://tests/scripts/test_battle_movement_query_service.gd` | 0 | 3.62 |
| `godot --headless --path . --script res://tests/scripts/test_battle_combat_query_service.gd` | 0 | 3.68 |
| `godot --headless --path . --script res://tests/scripts/test_battle_damage_formula_service.gd` | 0 | 3.59 |
| `godot --headless --path . --script res://tests/scripts/test_battle_action_lock_state_service.gd` | 0 | 3.68 |
| `godot --headless --path . --script res://tests/scripts/test_battle_enemy_ai_reservation_state_service.gd` | 0 | 3.59 |
| `godot --headless --path . --script res://tests/scripts/test_battle_unique_skill_cooldown_state_service.gd` | 0 | 3.59 |
| `godot --headless --path . --script res://tests/scripts/test_battle_event_log_service.gd` | 0 | 0.43 |
| `godot --headless --path . --script res://tests/scripts/test_battle_state_fingerprint_service.gd` | 0 | 0.53 |
| `godot --headless --path . --script res://tests/scripts/test_battle_move_oracle_baseline.gd` | 0 | 20.84 |
| `godot --headless --path . --script res://tests/scripts/test_battle_ally_move_state_service.gd` | 0 | 0.64 |
| `godot --headless --path . --script res://tests/scripts/test_battle_ally_move_event_parity.gd` | 0 | 7.59 |
| `godot --headless --path . --script res://tests/scripts/test_battle3d_engine_move_integration.gd` | 0 | 6.38 |
| `godot --headless --path . --script res://tests/scripts/test_battle3d_movement_parity.gd` | 0 | 1.75 |
| `godot --headless --path . --script res://tests/scripts/test_battle3d_modes.gd` | 0 | 1.0 |
| `godot --headless --path . --script res://tests/scripts/test_battle3d_oblique_click.gd` | 0 | 7.13 |
| `godot --headless --path . --script res://tests/scripts/alternating_battle_action_order_test.gd` | 0 | 0.43 |
| `godot --headless --path . --script res://tests/scripts/test_single_side_exhaustion_turn_order.gd` | 0 | 3.22 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_domestic_tech_catalog_extraction.gd` | 0 | 6.46 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_domestic_tech_research_rules_extraction.gd` | 0 | 0.53 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_domestic_tech_research_service_extraction.gd` | 0 | 0.8 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_domestic_tech_effect_provider_extraction.gd` | 0 | 0.52 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_domestic_tech_tree_presentation_extraction.gd` | 0 | 2.01 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_domestic_tech_completion_presentation_extraction.gd` | 0 | 0.81 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_military_controller_extraction.gd` | 0 | 5.26 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_enemy_warfare_service_extraction.gd` | 0 | 4.99 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_battle_context_service_extraction.gd` | 0 | 5.35 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_battle_result_service_extraction.gd` | 0 | 5.54 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_battle_settlement_applier_extraction.gd` | 0 | 0.53 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_t03_strategic_battle_transaction_extraction.gd` | 0 | 0.53 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_t03_battle_presentation_extraction.gd` | 0 | 0.53 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_player_attack_deployment_service_extraction.gd` | 0 | 0.52 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_troop_rebalance_service_extraction.gd` | 0 | 0.43 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_wounded_recovery_service_extraction.gd` | 0 | 0.52 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_diplomacy_routing.gd` | 0 | 19.68 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_diplomacy_controller_extraction.gd` | 0 | 0.89 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_diplomacy_validation_extraction.gd` | 0 | 5.16 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_diplomacy_mutation_extraction.gd` | 0 | 5.5 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_diplomacy_state_extraction.gd` | 0 | 5.17 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_diplomacy_alliance_extraction.gd` | 0 | 5.35 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_trade_routing.gd` | 0 | 16.98 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_trade_controller_extraction.gd` | 0 | 4.97 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_trade_automation_extraction.gd` | 0 | 4.98 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_internal_trade_transfer_extraction.gd` | 0 | 5.08 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_spy_routing.gd` | 0 | 20.2 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_spy_controller_extraction.gd` | 0 | 6.1 |
| `godot --headless --path . --script _ci_worldmap_scene_load.gd` | 0 | 3.15 |
| `godot --headless --path . --script _ci_battle_main_scene_load.gd` | 0 | 2.48 |
| `godot --headless --path . --script _ci_imjin_iso_scene_load.gd` | 0 | 3.04 |
| `godot --headless --editor --path . --quit` | 0 | 6.04 |

누적 실행 시간: 240.31초.

## 변조 요약

```json
[
  {
    "name": "control",
    "exit": 0,
    "seconds": 7.98,
    "failures": []
  },
  {
    "name": "direct_state_write",
    "exit": 1,
    "seconds": 6.18,
    "failures": [
      "M1B FAIL no direct state write before completion",
      "M1B FAIL grid distance",
      "M1B FAIL presentation uses executed path",
      "M1B FAIL animation consumes exact executed cells",
      "M1B FAIL engine phase advances before presentation"
    ]
  },
  {
    "name": "remove_isolation",
    "exit": 1,
    "seconds": 7.48,
    "failures": [
      "M1B FAIL subviewport isolated",
      "M1B FAIL raw right click cannot revert pending move",
      "M1B FAIL facing duplicate visible rejection",
      "M1B FAIL already moved visible rejection"
    ]
  },
  {
    "name": "animate_rejection",
    "exit": 1,
    "seconds": 7.39,
    "failures": [
      "M1B FAIL enemy no new presentation",
      "M1B FAIL range no new presentation",
      "M1B FAIL during engine animation no new presentation",
      "M1B FAIL facing duplicate no new presentation",
      "M1B FAIL already moved no new presentation"
    ]
  },
  {
    "name": "wrong_path",
    "exit": 1,
    "seconds": 7.31,
    "failures": [
      "M1B FAIL animation consumes exact executed cells"
    ]
  },
  {
    "name": "restored",
    "exit": 0,
    "seconds": 7.41,
    "failures": []
  }
]
```

## 초기 실패 진단 원문

```text
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
M1B PREFLIGHT roster=10 phase=ally_turn
ROSTER yi_sunsin ally archer (3, 8)
ROSTER jeong_dojeon ally archer (5, 7)
ROSTER gwon_yul ally infantry (4, 6)
ROSTER ally_reinforce_01_demo ally archer (3, 9)
ROSTER ally_reinforce_02_test_unit ally gunner (1, 7)
ROSTER guan_yu enemy cavalry (14, 2)
ROSTER zhang_fei enemy infantry (12, 3)
ROSTER xiahou_dun enemy cavalry (13, 4)
ROSTER enemy_reinforce_01_demo enemy archer (14, 1)
ROSTER enemy_reinforce_02_test_unit enemy gunner (16, 3)
M1B PREFLIGHT ui_hover=false overlay=true
[ROLLBACK] snapshot stored unit=이순신 cell=(3, 8)
M1B PREFLIGHT accepted=true
[MOVE_FINISH] ally=(3, 7) enemy=(14, 2) dist=16 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (3, 7) target_cell: (3, 7)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
M1B PREFLIGHT final phase=facing_select cell=(3, 7) events=[{ "unit_id": "yi_sunsin", "from": [3, 8], "to": [3, 7], "path": [[3, 8], [3, 7]], "movement_kind": "normal", "facing_before": "right", "facing_after": "right", "flags_before": { "has_moved": false }, "flags_after": { "has_moved": true }, "last_action_after": { "type": "move", "origin_cell": [3, 8], "destination_cell": [3, 7], "moved_distance": 1 }, "schema_version": 0, "sequence": 0, "kind": "unit_moved" }]
M1B AUDIO AFTER FREE SFXVoice0 playing=true stream=(res://assets/audio/sfx/round_start.wav):<AudioStreamWAV#-9223372008098626115>
M1B AUDIO AFTER FREE SFXVoice1 playing=false stream=(res://assets/audio/sfx/march.wav):<AudioStreamWAV#-9223372008752937542>
M1B AUDIO AFTER FREE SFXVoice2 playing=false stream=<Object#null>
M1B AUDIO AFTER FREE SFXVoice3 playing=false stream=<Object#null>
M1B AUDIO AFTER FREE SFXVoice4 playing=false stream=<Object#null>
M1B AUDIO AFTER FREE SFXVoice5 playing=false stream=<Object#null>
M1B AUDIO AFTER FREE SFXVoice6 playing=false stream=<Object#null>
M1B AUDIO AFTER FREE SFXVoice7 playing=false stream=<Object#null>
M1B MOVE PREFLIGHT PASS
M1B EXIT AUDIO FAIL: global voice still playing after scene free
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 3 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)

```

## 신규 통합 테스트 최종 원문

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

{"event":"ready","grid":"18x10 square","milliseconds":531,"renderer":"gl_compatibility","units":0}
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
[ROLLBACK] snapshot stored unit=이순신 cell=(3, 8)
[MOVE_FINISH] ally=(3, 7) enemy=(14, 2) dist=16 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (3, 7) target_cell: (3, 7)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
[RIGHT_CLICK_CANCEL] phase=facing_select
[ROLLBACK] phase=facing_select
[ROLLBACK] unit=이순신 cell=(3, 8)
[ROLLBACK] restored unit=이순신 grid=(3, 8)
[ROLLBACK] snapshot stored unit=이순신 cell=(3, 8)
[MOVE_FINISH] ally=(3, 7) enemy=(14, 2) dist=16 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (3, 7) target_cell: (3, 7)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
{"event":"ready","grid":"18x10 square","milliseconds":4327,"renderer":"gl_compatibility","units":0}
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
[ROLLBACK] snapshot stored unit=이순신 cell=(3, 8)
[MOVE_FINISH] ally=(5, 8) enemy=(14, 2) dist=15 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (5, 8) target_cell: (5, 8)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
{"event":"ready","grid":"18x10 square","milliseconds":6028,"renderer":"gl_compatibility","units":0}
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
M1B integration checks=143 failures=[]
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 2 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)

```

## 신규 validator 원문

```text
warning: in the working copy of 'tools/validate_battle3d_contract.py', CRLF will be replaced by LF the next time Git touches it
M1B validator PASS: scope, immutable originals, four commands, read-only state, executed events

```

## 기존 contract validator 원문

```text
BATTLE3D_CONTRACT PASS: 14-field ordered view contract, projection inheritance, engine query ownership, resources, 18x10 metadata

```

## 변조/대조 control 원문

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

{"event":"ready","grid":"18x10 square","milliseconds":686,"renderer":"gl_compatibility","units":0}
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
[ROLLBACK] snapshot stored unit=이순신 cell=(3, 8)
[MOVE_FINISH] ally=(3, 7) enemy=(14, 2) dist=16 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (3, 7) target_cell: (3, 7)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
[RIGHT_CLICK_CANCEL] phase=facing_select
[ROLLBACK] phase=facing_select
[ROLLBACK] unit=이순신 cell=(3, 8)
[ROLLBACK] restored unit=이순신 grid=(3, 8)
[ROLLBACK] snapshot stored unit=이순신 cell=(3, 8)
[MOVE_FINISH] ally=(3, 7) enemy=(14, 2) dist=16 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (3, 7) target_cell: (3, 7)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
{"event":"ready","grid":"18x10 square","milliseconds":4969,"renderer":"gl_compatibility","units":0}
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
[ROLLBACK] snapshot stored unit=이순신 cell=(3, 8)
[MOVE_FINISH] ally=(5, 8) enemy=(14, 2) dist=15 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (5, 8) target_cell: (5, 8)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
{"event":"ready","grid":"18x10 square","milliseconds":6681,"renderer":"gl_compatibility","units":0}
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
M1B integration checks=143 failures=[]
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 2 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)

```

## 변조/대조 direct_state_write 원문

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

{"event":"ready","grid":"18x10 square","milliseconds":497,"renderer":"gl_compatibility","units":0}
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
[ROLLBACK] snapshot stored unit=이순신 cell=(3, 8)
M1B FAIL no direct state write before completion
[MOVE_FINISH] ally=(3, 7) enemy=(14, 2) dist=16 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (3, 7) target_cell: (3, 7)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
M1B FAIL grid distance
M1B FAIL presentation uses executed path
M1B FAIL animation consumes exact executed cells
[RIGHT_CLICK_CANCEL] phase=facing_select
[ROLLBACK] phase=facing_select
[ROLLBACK] unit=이순신 cell=(3, 8)
[ROLLBACK] restored unit=이순신 grid=(3, 8)
[ROLLBACK] snapshot stored unit=이순신 cell=(3, 8)
[MOVE_FINISH] ally=(3, 7) enemy=(14, 2) dist=16 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (3, 7) target_cell: (3, 7)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
M1B FAIL engine phase advances before presentation
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
{"event":"ready","grid":"18x10 square","milliseconds":4327,"renderer":"gl_compatibility","units":0}
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
[ROLLBACK] snapshot stored unit=이순신 cell=(3, 8)
[MOVE_FINISH] ally=(5, 8) enemy=(14, 2) dist=15 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (5, 8) target_cell: (5, 8)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 2 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)

```

## 변조/대조 remove_isolation 원문

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

{"event":"ready","grid":"18x10 square","milliseconds":495,"renderer":"gl_compatibility","units":0}
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
M1B FAIL subviewport isolated
[RIGHT_CLICK_CANCEL] phase=ally_turn
[ROLLBACK] snapshot stored unit=이순신 cell=(3, 8)
[MOVE_FINISH] ally=(3, 7) enemy=(14, 2) dist=16 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (3, 7) target_cell: (3, 7)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
[RIGHT_CLICK_CANCEL] phase=facing_select
[ROLLBACK] phase=facing_select
[ROLLBACK] unit=이순신 cell=(3, 8)
[ROLLBACK] restored unit=이순신 grid=(3, 8)
M1B FAIL raw right click cannot revert pending move
[ROLLBACK] snapshot stored unit=이순신 cell=(3, 8)
M1B FAIL facing duplicate visible rejection
[RIGHT_CLICK_CANCEL] phase=resolving
[MOVE_FINISH] ally=(3, 6) enemy=(14, 2) dist=15 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (3, 6) target_cell: (3, 6)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
M1B FAIL already moved visible rejection
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
{"event":"ready","grid":"18x10 square","milliseconds":4457,"renderer":"gl_compatibility","units":0}
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
[ROLLBACK] snapshot stored unit=이순신 cell=(3, 8)
[MOVE_FINISH] ally=(5, 8) enemy=(14, 2) dist=15 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (5, 8) target_cell: (5, 8)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
{"event":"ready","grid":"18x10 square","milliseconds":6200,"renderer":"gl_compatibility","units":0}
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
M1B integration checks=143 failures=["subviewport isolated", "raw right click cannot revert pending move", "facing duplicate visible rejection", "already moved visible rejection"]
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 3 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)

```

## 변조/대조 animate_rejection 원문

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

{"event":"ready","grid":"18x10 square","milliseconds":526,"renderer":"gl_compatibility","units":0}
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
M1B FAIL enemy no new presentation
M1B FAIL range no new presentation
[ROLLBACK] snapshot stored unit=이순신 cell=(3, 8)
M1B FAIL during engine animation no new presentation
[MOVE_FINISH] ally=(3, 7) enemy=(14, 2) dist=16 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (3, 7) target_cell: (3, 7)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
M1B FAIL facing duplicate no new presentation
[RIGHT_CLICK_CANCEL] phase=facing_select
[ROLLBACK] phase=facing_select
[ROLLBACK] unit=이순신 cell=(3, 8)
[ROLLBACK] restored unit=이순신 grid=(3, 8)
[ROLLBACK] snapshot stored unit=이순신 cell=(3, 8)
[MOVE_FINISH] ally=(3, 7) enemy=(14, 2) dist=16 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (3, 7) target_cell: (3, 7)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
M1B FAIL already moved no new presentation
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
{"event":"ready","grid":"18x10 square","milliseconds":4385,"renderer":"gl_compatibility","units":0}
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
[ROLLBACK] snapshot stored unit=이순신 cell=(3, 8)
[MOVE_FINISH] ally=(5, 8) enemy=(14, 2) dist=15 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (5, 8) target_cell: (5, 8)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
{"event":"ready","grid":"18x10 square","milliseconds":6098,"renderer":"gl_compatibility","units":0}
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
M1B integration checks=143 failures=["enemy no new presentation", "range no new presentation", "during engine animation no new presentation", "facing duplicate no new presentation", "already moved no new presentation"]
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 2 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)

```

## 변조/대조 wrong_path 원문

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

{"event":"ready","grid":"18x10 square","milliseconds":511,"renderer":"gl_compatibility","units":0}
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
[ROLLBACK] snapshot stored unit=이순신 cell=(3, 8)
[MOVE_FINISH] ally=(3, 7) enemy=(14, 2) dist=16 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (3, 7) target_cell: (3, 7)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
M1B FAIL animation consumes exact executed cells
[RIGHT_CLICK_CANCEL] phase=facing_select
[ROLLBACK] phase=facing_select
[ROLLBACK] unit=이순신 cell=(3, 8)
[ROLLBACK] restored unit=이순신 grid=(3, 8)
[ROLLBACK] snapshot stored unit=이순신 cell=(3, 8)
[MOVE_FINISH] ally=(3, 7) enemy=(14, 2) dist=16 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (3, 7) target_cell: (3, 7)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
{"event":"ready","grid":"18x10 square","milliseconds":4367,"renderer":"gl_compatibility","units":0}
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
[ROLLBACK] snapshot stored unit=이순신 cell=(3, 8)
[MOVE_FINISH] ally=(5, 8) enemy=(14, 2) dist=15 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (5, 8) target_cell: (5, 8)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
{"event":"ready","grid":"18x10 square","milliseconds":6060,"renderer":"gl_compatibility","units":0}
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
M1B integration checks=143 failures=["animation consumes exact executed cells"]
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 3 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)

```

## 변조/대조 restored 원문

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

{"event":"ready","grid":"18x10 square","milliseconds":498,"renderer":"gl_compatibility","units":0}
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
[ROLLBACK] snapshot stored unit=이순신 cell=(3, 8)
[MOVE_FINISH] ally=(3, 7) enemy=(14, 2) dist=16 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (3, 7) target_cell: (3, 7)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
[RIGHT_CLICK_CANCEL] phase=facing_select
[ROLLBACK] phase=facing_select
[ROLLBACK] unit=이순신 cell=(3, 8)
[ROLLBACK] restored unit=이순신 grid=(3, 8)
[ROLLBACK] snapshot stored unit=이순신 cell=(3, 8)
[MOVE_FINISH] ally=(3, 7) enemy=(14, 2) dist=16 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (3, 7) target_cell: (3, 7)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
{"event":"ready","grid":"18x10 square","milliseconds":4419,"renderer":"gl_compatibility","units":0}
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
[ROLLBACK] snapshot stored unit=이순신 cell=(3, 8)
[MOVE_FINISH] ally=(5, 8) enemy=(14, 2) dist=15 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (5, 8) target_cell: (5, 8)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
{"event":"ready","grid":"18x10 square","milliseconds":6137,"renderer":"gl_compatibility","units":0}
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
M1B integration checks=143 failures=[]
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 3 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)

```
