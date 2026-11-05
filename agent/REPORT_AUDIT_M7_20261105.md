기준 화면: 없음(보이는 화면 변화 0). 읽기 전용 감사이며 코드·테스트·워크플로·씬을 고치지 않았다. 대상은 `feature/wm3d-intake-20261101` HEAD `9160baf`의 "월드맵 → 3D 전장 → 정산 → 월드맵 복귀" 연결 가능성이다.
합격 기준: 김작이 이 보고서만 읽고 "3D 전장 연결(M7)을 어떤 단계로, 몇 개 파일을 어떻게 고쳐야 하는지" 판단할 수 있다(F6 없음). 확인 못 한 것은 [미확인]으로 적었다.

# REPORT — AUDIT-M7: 월드맵 ↔ 3D 전장 연결 (읽기 전용 감사, 2026-11-05)

## 3줄 요약
1. **연결 가능성: 부분 가능 [사실+추정].** 3D 전장은 내부에서 2D 엔진(`Battle_Main.tscn`)을 SubViewport로 그대로 돌린다(`scripts/battle3d/battle3d_engine_host.gd:12-14`). 그래서 월드맵 문맥을 읽는 코드, 결과 딕셔너리를 만드는 코드, 월드맵으로 돌아가는 코드가 **이미 엔진 안에 있다**(`scripts/battle_web_import_test.gd:1491·1504-1523`, `:2961-3063`, `:2935-2959`). 정산(T02)은 바꾸지 않고 재사용할 수 있다.
2. **가장 큰 장애:** ① 월드맵의 전투 장면 경로가 상수 하나로 고정돼 있고, 그 줄이 **핀 검증기 두 개**에 묶여 있다(`worldmap_main.gd:152·6887·6910`, `tools/p1_exact_delta.py` 바이트 비교, `tools/validate_worldmap_to_battle_input_lifecycle.py:31-62` 문자열 비교). main 수정과 재고정이 꼭 필요하다. ② 3D 쪽에서 엔진의 "결과 들고 복귀"와 "후퇴"를 부를 방법이 없다. 엔진의 복귀 버튼은 렌더가 꺼진 SubViewport 안에 있다. 그래서 **새 엔진 쓰기가 1~2개** 필요하다("16번째 없음" 원칙과 충돌).
3. **김작이 정할 것:** (a) 엔진 쓰기 추가(복귀 1, 후퇴 1) 승인 여부 (b) 방어전(T03)도 3D로 보낼지 (c) 2D/3D 전투 설정 항목을 만들지 (d) M6 미충족 항목(해상도 대응, 7절)을 M7 전에 채울지 (e) 2D 후퇴 처리기 두 개를 M7에서 정리할지.

## 택한 해석
- 지시서가 근거로 든 `claude/BASELINE_FINAL_BUILD_20261030.md`와 `claude/DECISION_LOG_20261024.md`는 **레포에 없다**. 원격 35개 가지 전체를 `git log --all`로 찾았고, 김작 PC의 바탕화면·문서·다운로드도 찾았지만 없었다[사실]. 그래서 "최종본"은 문서가 아니라 코드와 테스트로 판단했다. 후퇴 근거는 레포 안의 `agent/HUD_INVENTORY_H1_20261024.md:74·149`를 썼다.
- 설계서 `EASTWAR_3D_BATTLE_MASTER_DESIGN_v1_1`은 레포 밖 `C:\Users\seong\Desktop\삼국워기존\EASTWAR_3D_BATTLE_MASTER_DESIGN_v1_1_20261019.md`에 있어서 그것을 읽었다. 같은 폴더의 v1_2(10-20)와 다른 점은 표 아래에 적었다.
- "엔진 쓰기"는 기존 검증기의 정의를 따랐다. 3D 랩이 `engine.call(...)`로 부르는 이름이 쓰기이고, 지금 15개에 `set_blocked_cells` 1개를 더한 16개다(`tools/validate_t1_blocked_cells.py:8-12`). "16번째 없음"은 **`engine.call` 이름을 새로 늘리지 않는다**는 뜻으로 읽었다.
- 임시 실험(Godot 실행)은 하지 않았다. 실행해야만 확정되는 것은 [미확인] 또는 "실험 필요"로 적었다.
- 조사의 일부(3D 쪽과 월드맵 쪽 목록 작성)는 하위 에이전트 둘에 나눠 맡겼다. 결론에 쓴 줄 번호는 클코드가 직접 열어 다시 확인했다(`worldmap_main.gd:150-152·6516·6887·6910`, `battle3d_engine_host.gd:14`, `battle3d_scenario_shell.gd:14-16·204-213·238`, `battle3d_engine_play.gd:105`, `lab_presentation.gd:44`, `battle_web_import_test.gd:873·1491-1513·6154-6168`, `verify-worldmap3d.yml:23`, `p1_exact_delta.py:19`).

## 1. 조사 결과

### 1-1. 3D 전장 진입점
| 씬 | 루트 스크립트 | 역할 | 시작 입력 |
|---|---|---|---|
| `scenes/battle3d/Battle3D_ScenarioShell.tscn` | `battle3d_scenario_shell.gd` | **사실상 최종 진입점**: 시나리오 고르기, HUD 7종(`:122-156`), 결과창, 새 전투 | 고정 시나리오 `default`·`win_practice`(`:15-16`). `start_scenario`(`:204`)가 `Engine` 메타 `samwar_battle_setup`을 세우고(`:209`) 랩을 만든다(`:210-213`). 랩을 만든 뒤 그 메타를 지운다(`:238`) [사실] |
| `Battle3D_EnginePlayLab.tscn` | `battle3d_engine_play.gd`(`lab_presentation.gd` 상속) | 엔진과 연결된 3D 랩(셸이 자식으로 만든다) | `_ready`(`:279`)에서 호스트 엔진의 `all_battle_unit_states`로 부대를 만든다(`:291-309`). 숲으로 막힌 칸은 고정값을 엔진에 넘긴다(`:288`) [사실] |
| `Battle3D_EngineConnectLab.tscn` | `battle3d_connect_lab.gd` | C0-C3 조회 랩(옛 단계) | 데모 픽스처(`lab_demo_port.gd`). 엔진 없음 [사실] |
| `Terrain20x20_Preview.tscn` | `terrain_preview.gd` | 지형 미리보기 | `assets/battle3d/heightfield.json`, `terrain_types.json` [사실] |
| HUD 7종 | `battle3d_*_hud.gd` 등 | 셸이 붙이는 부품 | 혼자서는 진입점이 아님 [사실] |

- 엔진: `battle3d_engine_host.gd:7·12-14`가 `res://scenes/battle/Battle_Main.tscn`을 `UPDATE_DISABLED` SubViewport 안에 만든다. 실제 규칙은 2D와 같은 `scripts/battle_web_import_test.gd`에 있다[사실].
- 지형은 고정이다(`lab_heightfield.gd:17-19` JSON 경로 고정)[사실]. 장수 데이터는 월드맵의 `hero_design_data_registry.gd`를 쓴다(`battle3d_hero_data_reader.gd:8`)[사실].
- 부작용: `lab_presentation.gd:44`가 레포 **밖** `../EASTWAR_C0C3_Evidence/runtime_events.jsonl`을 쓰기 모드로 연다[사실]. 실제 게임 흐름에 들어가기 전에 정리해야 한다[추정].
- `project.godot`의 main_scene은 `NewGameFactionSelect.tscn`이다. 월드맵에서 3D 전장 씬을 참조하는 곳은 0건이다[사실].

### 1-2. 월드맵의 전투 문맥
| 항목 | 위치 | 라벨 |
|---|---|---|
| 메타 키·장면 상수 | `worldmap_main.gd:150-152`. `WORLDMAP_BATTLE_SCENE_PATH := "res://scenes/battle/Battle_Main.tscn"` | [사실] |
| 공격 문맥 만들기 | `_confirm_player_attack_deployment` `:6490` → `_build_player_attack_battle_context` `:10859` → `battle_context_service.gd:124-180` | [사실] |
| main이 덧붙이는 키 | `:6511-6516` `attacker_total_allocated_troops`, `attacker_source_city_id`, `transaction_id`(`팩션-unix-msec`), `scenario_id`, `player_faction_id`, `result_return_destination="res://WorldMap.tscn"`(`:6516`). 그 뒤 `:6534` `worldmap_state_snapshot` | [사실] |
| 방어 문맥(T03) | `_confirm_defense_deployment` `:6784` → 서비스 `:69-121` → `_prepare_t03_battle_transaction` `:6807`·`:11058`(`t03-` 거래 ID). **`result_return_destination` 없음** | [사실] |
| Engine 메타 설정 | `_change_scene_to_battle_with_context` `:6901`(진입 카메라 뒤) | [사실] |
| 장면 전환 | `ResourceLoader.exists` 검사 `:6887`(없으면 롤백), `change_scene_to_file(WORLDMAP_BATTLE_SCENE_PATH)` `:6910`, 실패하면 입력 복구·메타 제거·`_rollback_player_attack_handoff` `:6921` | [사실] |

- 공격 문맥 키(서비스 `:143-179`)[사실]
  - 기본: `type`, `source`, `battle_mode`, `mode`, `turn_number`
  - 도시·세력: 공격·방어 `city_id/name`, `owner`, `faction_id/display_name`
  - 병력·장수: 공격·방어 `troops`, `initial_healthy_troops`, `hero_ids`, `heroes`, `general_ids`, `main/support_hero_ids`, `support_city_ids`, `governor_id`, `troop_allocation/composition`
  - 보급·턴: `supply_cost`, `attacker_carried_gold`, `food_type/amount`, `salt_amount`, `supply_balance_snapshot`, `tech_effect_snapshot`, `battle_max_turns`, `current_battle_turn`
  - **지형·날씨·맵 변형 키는 없다**[사실].
- `battle_context_service.gd`(`WorldMapBattleContextService`): 문맥 조립, 로스터·병력 배정, 지휘 한계, 증원 후보, 장수 전투 데이터를 맡는다. main `:1801-1820`에서 구성하고 `:10852-10980`에서 위임한다[사실].
- 2D 전투가 읽는 법: `Battle_Main.tscn` → `Battle_Production.tscn` → … → `battle_web_import_test.gd`. `_ready` `:1491`에서 `_read_worldmap_battle_context_handoff`(`:1504`)를 부른다. 메타를 읽으면 바로 지우고(`:1511-1512`) `_apply_worldmap_battle_context_handoff`(`:1617-1642`)로 고정 슬롯(`ally_main_01…`, `enemy_main_01…`, `:510-520`)에 로스터·보급·후퇴 버튼을 적용한다. 메타가 없으면 "테스트 전투"다(`:1509`)[사실].
- 계약: `agent/BATTLE_WORLDMAP_HANDOFF_CONTRACT.md` 21-116행(키 표), 29-35행(T02), 180-186행 "장면 전환 경로 의미 체계는 전용 계약 작업 없이 바꾸지 말 것"[사실]. **M7은 이 계약 문서의 갱신을 동반해야 한다**[추정]. `agent/BATTLE_CONTEXT_CONTRACT.md`는 미래형 계약(`map_variant_id`, `terrain_tags`, `weather` 등)이고 현재 코드에는 없다[사실].

### 1-3. 3D 전장이 그 문맥으로 시작할 수 있나
| 입력 | 판정 | 근거 |
|---|---|---|
| 문맥 메타 받기 | **부분** | 3D 쪽(`scripts/battle3d`)에는 `samwar_worldmap`·`battle_context`·`change_scene`이 0건이다[사실]. 다만 셸이 지우는 메타는 `samwar_battle_setup`뿐이다(`shell:238`). 그래서 메타가 세워진 채로 랩이 생기면 안쪽 엔진 `_ready`가 그대로 읽는다[추정, 실험 필요] |
| 도시·부대·장수·병력 | **부분** | 엔진이 고정 슬롯에 문맥을 적용하고, 랩은 엔진의 `all_battle_unit_states`를 그린다(`engine_play:291-309`)[사실]. 모델은 보병·기병 둘로 줄인다(`engine_play:304`). 문맥 장수가 3D에 제대로 보이는지는 [미확인, 실험 필요] |
| 시나리오 화면 건너뛰기 | **불가(현재)** | 셸은 언제나 시작 패널에서 출발한다(`shell:157-170`). 문맥으로 바로 시작하는 경로가 없다[사실] |
| 지형·맵 선택 | **불가(현재)** | JSON 경로가 고정이고(`lab_heightfield.gd:17-19`), 문맥에 지형 키가 없다[사실]. M7 1차는 "고정 지형" 유지가 현실적이다[추정] |
| 보급 HUD | **불가(현재)** | 3D HUD에 보급 표시가 없다. H1 인벤토리 `:30`이 M7과 함께 하라고 적었다[사실] |
| `result_return_destination` | **불가 / 영향 없음** | 이 키는 코드 어디에서도 읽지 않는다. 대입은 `worldmap_main.gd:6516` 한 곳뿐이고, 엔진은 자체 상수 `WORLDMAP_SCENE_PATH="res://WorldMap.tscn"`(`battle_web_import_test.gd:873`)로 돌아간다[사실] |

### 1-4. 결과 반환·정산
- 결과 만들기: 엔진 `_build_worldmap_battle_result_payload`(`battle_web_import_test.gd:2961-3063`)[사실]
  - 식별: `transaction_id`, `result_id`(`<tx>-result-<msec>`, `:3093`)
  - 승패: `winner_side`, `winner`, `result`(victory/defeat/retreat), `result_reason`, `completed_turn`
  - 도시·병력: 양측 도시·소유자·병력·생존·배정·출발 도시 병력 전후
  - 결과 요약: 양측 `healthy_survivors`, `wounded`, `dead`, `deserters`, 남은 금·식량·소금, `surviving_general_ids`, `*_hero_outcomes`(`:3061-3062`)
  - 스냅샷: `worldmap_state_snapshot`, `rollback_worldmap_state`
- 3D 쪽은 엔진 `battle_ended` 이벤트의 `result_state` 문자열만 받는다(`engine_play:1073-1074·1146`)[사실]. `RESULT_TEXT`는 승리·패배 둘뿐이다(`engine_play:105`, retreat 없음)[사실]. 셸 결과창은 "결과·라운드·생존 아군 수" 문자열이 전부다(`shell:560-568`)[사실]. 하지만 **결과 딕셔너리를 만드는 엔진이 3D 안에서 같이 돌고 있으므로, 3D가 따로 만들 필요는 없다**[추정]. 사상자·포로·잔존 병력도 엔진 쪽에 있다.
- 월드맵의 소비와 정산[사실]
  - `_consume_worldmap_battle_result_if_any` `:7007`(`_ready` `:965`)에서 메타를 바로 지운다.
  - `_apply_returned_battle_result_mvp` `:7022`
    - 이미 적용된 `result_id`면 중단한다(`:7023-7027`).
    - 스냅샷을 복원하고 pending 거래 ID를 다시 세운다(`:7028-7032`).
    - `t03-` 거래면 `_apply_t03_strategic_battle_result`(`:7033`·`:11095`)로 간다.
    - 그 밖에는 `build_settlement_plan`(`:7036`, `battle_result_service.gd:18-123`) → applier `.apply`(`:7038`) → `_apply_t02_player_attack_result`(`:7113`, 저장 `:7168`)로 간다.
- T02 검증(`battle_settlement_applier.gd:19-60`): `incomplete_result_identity`(`:37-38`), `duplicate_result`(`:39-41`), `transaction_mismatch`(`:42-43`)를 **모두 먼저 검사한 뒤** 반영한다[사실]. 반영 도중 실패를 되돌리는 코드는 못 봤다[추정]. 3D 전장이 같은 엔진 결과를 같은 메타로 넘기면 **정산 코드는 바꿀 필요가 없다**[추정, 문자열·키가 같으므로].

### 1-5. 복귀 경로
- 엔진 `_return_to_worldmap_with_result`(`:2935-2959`)가 결과 메타를 쓰고(`:2949`) `change_scene_to_file("res://WorldMap.tscn")`(`:2951`)을 부른다. 실패하면 메타를 지운다(`:2953`)[사실]. 3D 셸 안의 엔진이 이것을 부르면 현재 장면(셸 전체)이 바뀌므로 3D 전장도 같이 풀린다[추정, 실험 필요].
- 그런데 엔진의 복귀 버튼(`WorldMapResultReturnButton`, `:2896-2915`)은 렌더가 꺼진 SubViewport 안에 있어서 **사용자가 누를 수 없다**[추정]. 3D 결과창에 "월드맵으로" 버튼을 새로 만들고, 그 버튼이 `engine.call("_return_to_worldmap_with_result")`를 불러야 한다. **새 엔진 쓰기 1개**다(1-6).
- 08 호스트와의 관계[사실, 07·08 보고서]
  - main이 전투 메타를 세우면 호스트가 `main.tree_exiting`에서 `before_battle`을 기록하고, 60프레임 뒤 `battle_ready_plus_60f`를 기록한다(장면 이름 포함).
  - `WorldMap.tscn`으로 돌아오면 호스트가 3D를 다시 만들고 `world_ready_after_return`(빌드 ms 포함)을 기록한다.
  - 이 흐름은 전투 장면이 2D든 3D든 같아서 **호스트는 바꿀 필요가 없다**[추정]. 3D 월드맵은 전투 중에 남지 않는다(장면 교체로 해제, 07 보고서 3절 표 3행).
- 메모리·로딩 시간: 3D 전장 로드 시간과 VRAM은 **[미확인]**(측정 기록 없음). 위 프로브의 `battle_ready_plus_60f` 행에 3D 전장 장면 이름이 찍히므로, 연결 뒤 김작 PC CSV로 바로 비교할 수 있다. 복귀 때 3D 월드맵 재생성은 로컬 기준 약 3.9 s에서 8.4 s다(06 보고서 4절). 따라서 "3D 전장 로드 + 복귀 3D 월드맵 재생성"이 한 판마다 더해진다[추정].

### 1-6. 엔진 쓰기·후퇴
- 15개[사실]: 목록은 `tools/validate_t1_blocked_cells.py:31-34`(`FIFTEEN`)과 `validate_battle3d_command_panel.py:50`에 있다. 모두 `battle3d_engine_play.gd`에서 부른다.

| # | 호출 | `engine_play` 줄 |
|---|---|---|
| 1 | `_select_ally_unit` | 626 |
| 2 | `_try_direct_move_to_cell` | 641 |
| 3 | `_select_post_move_facing` | 653 |
| 4 | `_handle_right_click_cancel` | 674 |
| 5 | `try_basic_attack` | 845 |
| 6 | `_try_attack_enemy_target_from_attack_select` | 896 |
| 7 | `_end_ally_turn_by_wait` | 798 |
| 8 | `_on_defend_button_pressed` | 824 |
| 9 | `_on_strategy_button_pressed` | 1191 |
| 10 | `_try_use_strategy_on_target` | 1250 |
| 11 | `_on_unique_skill_button_pressed` | 1437 |
| 12 | `_try_use_unique_skill_on_target` | 1483 |
| 13 | `_toggle_full_auto_battle` | 1637 |
| 14 | `set_enemy_ai_level` | 1711 |
| 15 | `set_auto_presentation_hold` | 1750 |

  - 여기에 `queries.grid.set_blocked_cells`(`:288`)를 더하면 16이다. T1 검증기가 "15 + 1 = 16"으로 고정한다(`validate_t1_blocked_cells.py:8-12·92-97`). 개수를 함께 잡는 검증기는 `validate_battle3d_command_panel.py:121`, `validate_battle3d_top_commands.py` 등이다.
- 후퇴[사실]
  - 3D 후퇴 버튼은 비활성 그림만 있고 처리기가 없다(`battle3d_top_commands.gd:9-11·50-52`, 검증기 `validate_battle3d_top_commands.py:84`).
  - H1 인벤토리 `:74`는 "엔진 쓰기 16번째가 필요해짐[추정]", `:149`는 "2D 처리기 2개 정리"라고 적었다.
- 2D 후퇴 처리기 2개[사실]

| 처리기 | 위치 | 동작 |
|---|---|---|
| ① | `scripts/battle/presentation/production/battle_roster_presentation_controller.gd:163-179` | 월드맵 문맥을 검사하지 않고 `forced_battle_result_state="defeat"`, `battle_result_reason="retreat"`를 세운 뒤 결과 토스트를 띄움 |
| ② | `battle_web_import_test.gd:6154-6168` | 월드맵 공격전일 때만 `"retreat"`로 세우고 바로 `_return_to_worldmap_with_result`. 버튼 연결 `:1443`, 활성 조건 `:6142-6151` |

  - 둘이 같은 버튼에 연결돼 있어서(RP `:86-87`, C `:1443`) 공격전에서 ①이 먼저 돌면 "패배"로 굳을 수 있다[추정, 인벤토리 `:41`].
- **M7에 필요한 새 엔진 쓰기[추정]**
  - (a) 결과 들고 복귀: `_return_to_worldmap_with_result` 1개
  - (b) 후퇴: `_on_retreat_button_pressed`(②) 1개. ②는 마지막에 (a)를 부르므로 (b)만 있으면 후퇴 복귀도 된다.
  - (a)와 (b)를 합친 엔진 쪽 공개 함수 1개를 새로 만드는 방법도 있지만, 그러면 엔진 파일도 고쳐야 한다.
  - 어느 쪽이든 `engine.call` 이름이 1~2개 늘어난다. 그러면 `validate_t1_blocked_cells.py`·`validate_battle3d_command_panel.py`·`validate_battle3d_top_commands.py`의 개수 고정도 함께 고쳐야 한다(검증기 변경 = 김작 승인 대상).

### 1-7. 핀·검증기와 `worldmap_main.gd` 수정 줄
| # | main 줄 | 내용 | M7에서 |
|---|---|---|---|
| 1 | 152 | `WORLDMAP_BATTLE_SCENE_PATH` 상수 | 3D 경로 상수 추가 또는 선택 함수로 바꿈(**필수**) |
| 2 | 6887 | `ResourceLoader.exists(WORLDMAP_BATTLE_SCENE_PATH)` | 고른 경로로 검사(**필수**) |
| 3 | 6910 | `change_scene_to_file(WORLDMAP_BATTLE_SCENE_PATH)` | 고른 경로로 전환(**필수**) |
| 4 | 6516 | `result_return_destination` | 바꿀 필요 없음(아무도 읽지 않음) |
| 5 | 6784-6832 | 방어(T03) 진입 | 같은 함수(`:6878`)를 지나므로 위 1-3을 바꾸면 방어도 같이 3D로 간다. 방어만 2D로 두려면 분기 1-2줄 추가(김작 결정 b) |
| 6 | 965 / 7007 | 결과 소비 | 바꿀 필요 없음(같은 메타 키, 같은 `WorldMap.tscn`) |

- **최소 2~3곳, 약 3~6줄**[추정]. 0줄로 하는 방법은 찾지 못했다. 전환 경로가 main 상수 하나에 묶여 있고, 호스트가 그 사이에 끼어들 지점(신호·콜백)이 없다[사실, `:6900-6921`].
- 핀[사실]
  - `tools/p1_exact_delta.py`는 현재 main이 체크포인트 `9b2cd8e`(`:19`)의 main과 바이트 단위로 같고, `c098fb7→9b2cd8e` 줄 변화가 `EXPECTED_P1_MAIN_DELTA`(`:23-48`)와 같아야 통과한다.
  - `validate_worldmap_diplomacy_routing.py:146`이 이 검사를 부르고, `verify-c-track.yml:86`에서 돈다.
  - 재고정에는 main을 바꾼 커밋 X를 만들고 다음 커밋에서 체크포인트·변화량을 X로 바꾸는 절차가 필요하다. 자기 해시를 자기 안에 넣을 수 없으므로 **최소 2커밋**이다[추정].
- 추가 고정 문자열[사실]
  - `validate_worldmap_to_battle_input_lifecycle.py:31-62`가 `const WORLDMAP_BATTLE_SCENE_PATH := "res://scenes/battle/Battle_Main.tscn"` 문자열과 `_change_scene_to_battle_with_context` 안의 `change_scene_to_file(WORLDMAP_BATTLE_SCENE_PATH)` 순서를 검사한다. **M7 줄 1·3을 바꾸면 이 검증기도 고쳐야 한다.**
  - 그 밖에 `validate_p1c_battle_production_promotion.py:65`, `validate_worldmap_main_integrity.py:25`(main ≥ 14,000줄, 현재 14,108)도 있다.
- 2-E와 묶기: 2-E가 바꿀 줄(`:707` 변수 타입, `:1173` 반환 타입)은 같은 바이트 핀 안에 있다. **재고정 한 번에 M7 줄 1-3과 함께 넣을 수 있다**[추정]. 다만 검토 범위가 섞이므로, 같은 재고정 묶음 안에서 코드 커밋은 둘로 나누는 쪽을 권한다(2-E 커밋 → M7 경로 커밋 → 재고정 커밋).

| 묶음 후보 | main 줄 | 같은 재고정에 넣을 수 있나 |
|---|---|---|
| 2-E 카메라 분리 | 707, 1173 | 가능[추정] |
| M7 전투 경로 | 152, 6887, 6910 (+방어 분기) | 가능[추정] |
| CITY-HUD(5번 감사) | 5번 감사에서 확인 | [미확인] |

### 1-8. 폴백 설계
- 지금은 전투 장면을 고르는 설정이나 플래그가 없다. 장면 관련 `ResourceLoader.exists`도 `:6887` 한 곳뿐이다[사실].
- 재사용할 틀: `scripts/worldmap/map3d/worldmap_3d_settings.gd`(`user://samwar_worldmap3d.cfg`, `is_3d_available()` = `ResourceLoader.exists`, `use_3d()`)[사실]. 같은 파일에 `[battle] battle_view="3d"/"2d"`와 `is_3d_battle_available()`을 더하는 방식이 가장 작다[추정].
  - 이 파일은 `scripts/` 쪽이라 main이 타입 없이 문자열 경로로 불러야 C-track(3D 월드맵 제외 환경)에서도 안전하다.
  - 3D 전장(`scenes/battle3d/`)은 C-track에서 제외되지 않는다. 모바일 내보내기 제외 여부는 프리셋이 아직 없어 [미확인]이다(`docs/WORLDMAP3D_EXPORT_NOTES.md` 1절).
- 판단 순서 제안[추정]: ① 사용자 설정 2D → `Battle_Main` ② 3D 장면이 없음 → `Battle_Main` ③ 그 밖 → 3D 셸
  - 설정 항목은 **필요**하다고 본다. 이유는 셋이다: 3D 해상도 미대응(1-9), 모바일, 문제가 생겼을 때 김작이 2D로 즉시 되돌릴 수 있게.
  - 설정 화면은 08에서 만든 시스템 팝업(`worldmap_audio_settings.gd`)에 한 줄을 더하면 된다.

### 1-9. 설계서 M0~M6 현황
- 단계 표: v1.1 §4(`:84-99`), §11.2(`:203-213`, M7 행 `:213` "context/result 및 T02 정산 계약을 별도 검증. M0~M6 전투 UI 구현을 M7로 미루지 않음"), §9-1(`:172` "M0~M6는 독립 진입점 한 판 완주, 월드맵 왕복은 M7 별도 승인").
- v1.2와의 차이: 엔진 단계(S)와 3D 단계(M)를 나눴다(§3.3). 3D 쓰기를 "6개 고정, 늘리려면 지시서·검수 승인"으로 적었다(v1.2 `:75`, 이후 실제 코드는 15+1까지 늘어남). M6 행에 "정보 패널 클릭 통과 정리"가 추가됐다. M7 정의와 §11.4는 같다.

| 단계 | 상태 | 근거 |
|---|---|---|
| M1-b ~ M5-c | 구현됨[사실] | `agent/BATTLE3D_M1B…M5C_RESULT_*.md`, battle3d 테스트. 승리 연습 6라운드 승리(`BATTLE3D_M5B_RESULT_20261023.md:15`). 보고서마다 "합격 판정 안 함"이라 적혀 있어 인수 기록은 [미확인] |
| M6 | 전용 지시서·보고서 없음[사실] | HUD 블록 1~8·6a가 사실상 M6 UI 정리 역할[추정] |
| M7 | 미착수[사실] | 위 1-3 |

| M6 기준 (§11.4) | 판정 | 근거 |
|---|---|---|
| 1 독립 진입·UI로 시작 | 충족 | `shell:157-170`, `test_battle3d_scenario_start` |
| 2 선택~라운드 실제 조작 | 충족 | M1b~M3b 동등성·거절 테스트 |
| 3 방어·책략·특기·증원 | 충족 | M4a~M4e 테스트 |
| 4 상태 표시 일치 | 대체로 충족 | 로스터·현재 장수·로그 HUD. 재생 지연에 따른 표시 차이가 남음(`BATTLE3D_M3B_RESULT_20261020.md:572`) |
| 5 승리·패배·새 전투 | 충족 | `scenario_victory_seed_1~3`, `scenario_defeat`, `scenario_new_battle` |
| 6 입력 중복·종료 후 잠금 | 충족 | `*_rejections`, `enemy_turn_locks`, `oblique_click` |
| 7 지원 해상도 캡처 | **미충족** | 1920×1080만 지원. 1280×800에서 셸 상단 버튼과 옵션창이 창 밖(x 1435)에 놓임(`agent/HUD_BLOCK44_EDGE_SCROLL_RESULT_20261027.md:56`, `project.godot:26-27` 1920×1080, 늘이기 없음) |
| 8 자동·수동·2D 회귀 증거 | 부분 / [미확인] | CI가 2D·3D를 함께 돈다. M6 묶음 보고서는 없음 |

- **월드맵 연결 전에 채울 것**[추정]
  - M6 7번(해상도)과 M6 인수 보고서
  - 문맥 진입 경로(시작 패널 건너뛰기)
  - 3D 결과창의 retreat 문구, "월드맵으로" 버튼
  - 레포 밖 증거 파일 쓰기(`lab_presentation.gd:44`) 정리
  - 개발용 시작 패널 정리(M5B 보고서 `:165`)
  - 보급 HUD(H1 `:30`)
  - 지형 선택은 1차 범위 밖으로 둘 것을 권한다.

### 1-10. 테스트·CI 영향, 그리고 `bool constructor` 오류의 원인
- **원인 확정[사실]:** 두 테스트가 `bool(worldmap.get("_worldmap_battle_entry_handoff_in_progress"))`를 읽는다(`test_worldmap_battle_main_roundtrip_settlement.gd:82`, `test_worldmap_to_battle_input_lifecycle.gd:22`). 이 속성은 main에서 이미 없어져서 `get()`이 `null`을 돌려주고, `bool(null)`이 "Nonexistent 'bool' constructor"로 멈춘다.
  - 지운 커밋: `c098fb7` "fix: clear WorldMap GDScript warnings"(2026-09-18 21:35). `var _worldmap_battle_entry_handoff_in_progress: bool: get: return _ensure_camera_controller().is_battle_entry_handoff_in_progress()` 3줄을 지웠다(`git log -S` 결과 `a54f015` 추가 → `c098fb7` 제거).
  - 속성 개수: `c098fb7^` 1, `c098fb7` 0, `367ad63`(06 시작) 0, `9160baf` 0.
  - roundtrip 테스트는 그보다 **뒤**인 `54d90ca`(2026-09-19)에 처음부터 이 줄을 담고 들어왔다(`git merge-base --is-ancestor c098fb7 54d90ca` 참).
  - **결론: 06·07·08과 무관하다.** WM3D 작업 시작점 `367ad63`부터 이미 깨져 있었다.
- 왜 CI가 못 잡았나[사실]: 두 테스트는 Godot로 실행하는 CI가 없다. `validate_worldmap_to_battle_input_lifecycle.py:69-89`가 테스트 소스에 특정 문자열이 있는지만 본다.
- M7이 건드릴 기존 테스트·검증기[추정]
  - 위 두 테스트: 3D 경로를 넣으면 다시 살려야 왕복을 증명할 수 있다. 고치는 방법은 `worldmap.call("_ensure_camera_controller").is_battle_entry_handoff_in_progress()`로 바꾸는 1줄씩이다[추정].
  - `validate_worldmap_to_battle_input_lifecycle.py`(경로 문자열), 엔진 쓰기 개수 검증기 3개, `p1_exact_delta.py`
  - CI에서 도는 서비스 추출 테스트(`verify-c-track.yml:377-381`): 정산 코드를 안 바꾸면 영향이 없다.
- 새로 필요한 테스트[추정]
  - (1) 월드맵 문맥 → 3D 셸 → 엔진이 문맥을 소비했는지(슬롯·장수·보급)
  - (2) 3D에서 승리·패배·후퇴 → 결과 메타 → `WorldMap.tscn` 정산(소유권·병력·장수·`result_id` 중복 거부)
  - (3) 설정이 2D이거나 3D 장면이 없으면 `Battle_Main`
  - (4) 3D 월드맵 호스트의 `before_battle` → `battle_ready_plus_60f`(3D 전장 장면 이름) → `world_ready_after_return`
  - (5) 엔진 쓰기 개수 고정 갱신
- 지금 M7 왕복(문맥 → 3D → 결과 → 복귀)을 검사하는 테스트는 0건이다[사실]. `verify-worldmap3d.yml`은 `test_worldmap3d_*`만 돌리고 `continue-on-error: true`(`:23`)다. battle3d 테스트는 `verify-c-track.yml`에서 123개 중 105개가 돈다[사실].

## 2. 판정표
| 질문 | 판정 | 근거 |
|---|---|---|
| 3D 전장이 월드맵 문맥으로 시작할 수 있나 | **부분** | 안쪽 엔진이 문맥을 읽는 코드는 있다(`battle_web_import_test.gd:1491·1504-1642`). 3D 셸은 시작 패널을 건너뛰는 진입 경로가 없고, 지형은 고정이다(`shell:157-170`, `lab_heightfield.gd:17-19`). 실제 소비는 실험 필요 |
| 결과 딕셔너리를 3D 엔진이 만들 수 있나 | **가능(엔진 쪽) / 3D 쪽 호출 경로 없음** | `:2961-3063`이 같은 엔진 안에 있음. 3D에서 복귀를 부르는 쓰기가 없음(`engine_play`에 `_return_to_worldmap_with_result` 0건) |
| 정산(T02) 변경 없이 연결 가능한가 | **가능[추정]** | 같은 메타 키·같은 결과 키·같은 `WorldMap.tscn` 복귀(`:2949-2951`), 정산 `:7007-7168`·applier `:19-60` |
| 새 엔진 쓰기가 필요한가(후퇴 포함) | **예, 1~2개[추정]** | 복귀 `_return_to_worldmap_with_result` 1, 후퇴 `_on_retreat_button_pressed` 1(후퇴만 넣어도 복귀를 거침). 개수 검증기 3개 갱신 |
| `worldmap_main.gd` 수정이 필요한 줄 수 | **2~3곳, 약 3~6줄 + 재고정 2커밋[추정]** | `:152`, `:6887`, `:6910`(+방어를 2D로 남길 경우 분기). `p1_exact_delta.py`, `validate_worldmap_to_battle_input_lifecycle.py` |
| M6 인수 기준 충족 상태 | **8개 중 충족 5, 대체로 1, 부분 1, 미충족 1** | 1-9 표. 미충족은 7번(해상도) |

## 3. 단계 분해안 (제안만, 적용 금지)
| 단계 | 내용 | 예상 수정 경로 | 위험 | 김작 F6 |
|---|---|---|---|---|
| **M7-0 정리** | 왕복 테스트 2개의 `bool` 오류 1줄씩 수정, `lab_presentation.gd:44` 레포 밖 쓰기 정리, (선택) M6 해상도 | `tests/scripts/test_worldmap_battle_main_roundtrip_settlement.gd`, `test_worldmap_to_battle_input_lifecycle.gd`, `scripts/battle3d/lab_presentation.gd` | 낮음. main 0줄 | 2D 전투 왕복 1판 |
| **M7-1 문맥 진입** | 3D 셸에 "월드맵 문맥 진입" 경로 추가(메타가 있으면 시작 패널을 건너뛰고 바로 랩 생성), 결과창 retreat 문구 | `battle3d_scenario_shell.gd`, `battle3d_engine_play.gd`(`RESULT_TEXT`), 새 테스트 1개 | 중간. 셸이 메타를 지우는 시점과 엔진 `_ready`의 순서(실험 필요) | 셸을 문맥과 함께 열었을 때 장수·병력이 맞는지(테스트 장면) |
| **M7-2 결과 반환** | 3D 결과창 "월드맵으로" → `engine.call("_return_to_worldmap_with_result")`(엔진 쓰기 +1) | `battle3d_scenario_shell.gd`/`battle3d_engine_play.gd`, 쓰기 개수 검증기 3개 | 중간. 쓰기 원칙 변경(김작 승인), 정산 무변경 확인 | 승리·패배 각 1판 뒤 월드맵 소유권·병력 |
| **M7-3 경로 분기·설정·폴백** | main 3곳 + 설정 `[battle] battle_view` + 팝업 한 줄, 재고정 2커밋(2-E와 묶을 수 있음) | `worldmap_main.gd`, `worldmap_3d_settings.gd`, `worldmap_audio_settings.gd`, `tools/p1_exact_delta.py`, `tools/validate_worldmap_diplomacy_routing.py`, `tools/validate_worldmap_to_battle_input_lifecycle.py`, `agent/BATTLE_WORLDMAP_HANDOFF_CONTRACT.md` | 높음. main 핀·계약 문서·방어전 경로 | 월드맵에서 공격 → 3D 전장 → 복귀, 설정 2D면 2D 전장 |
| **M7-4 후퇴** | 3D 후퇴 버튼 → `engine.call("_on_retreat_button_pressed")`(쓰기 +1), 2D 처리기 ① 정리 여부 | `battle3d_top_commands.gd`, `battle3d_engine_play.gd`, 검증기 2개, (정리 시) `battle_roster_presentation_controller.gd` | 중간. 처리기 ①이 먼저 돌아 "패배"로 굳는 문제 | 후퇴 → 병력·화물이 출발 도시로 |
| **M7-5 메모리·시간** | 김작 PC CSV로 3D 전장 로드와 복귀 측정, 필요하면 로딩 화면 | 코드 0(측정) 또는 로딩 표시 | 낮음 | CSV 3판 |

**추천 순서: M7-0 → M7-1 → M7-2 → M7-4 → M7-3 → M7-5.**
- 이유: main을 건드리는 M7-3을 3D 쪽이 다 준비된 뒤 **한 번에 한 번만** 재고정하기 위해서다(2-E도 같이). 그 전 단계들은 3D 셸을 문맥과 함께 직접 여는 테스트로 증명할 수 있다.
- M7-0을 맨 앞에 두는 이유: 깨진 왕복 테스트 둘을 먼저 살려야 이후 단계가 2D 왕복을 망가뜨리지 않았다는 증거를 낼 수 있다.

## 4. 막힌 것
- 없음. 다만 아래는 확인하지 못했다.
  - `claude/BASELINE_FINAL_BUILD_20261030.md`·`claude/DECISION_LOG_20261024.md`가 레포에 없음 [미확인]
  - 셸 안 엔진의 문맥 소비 순서와 문맥 장수의 3D 표시 [미확인, 실험 필요]
  - 3D 전장 로드 시간·VRAM [미확인]

## 5. 종료 루틴
1. 정본 `C:\dev\SamWar_BattleLab_cc`, 가지 `feature/wm3d-intake-20261101`. 시작 HEAD `9160baf`, 작업 트리 깨끗. 코드 변경 0.
2. 새로 만든 것: 이 보고서 1개(+`agent/PROGRESS_WM3D.md` 한 줄).
3. push한 것: 보고서 커밋 1개(`[skip ci]`)만 `feature/wm3d-intake-20261101`에, force 없음.
4. CI: `[skip ci]`라 없음.
5. 김작이 결정할 것: 3줄 요약의 (a)~(e). 그리고 단계 분해안의 순서, M7-3과 2-E를 한 재고정에 묶을지.
