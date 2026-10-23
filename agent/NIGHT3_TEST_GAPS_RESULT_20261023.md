# NIGHT3 테스트 보완 결과 — 변이 검증 구멍 G1~G11 (2026-10-23)

- 지시문 `TEST_GAPS_NIGHT3_20261023.md`(클코치)
- 기준 `origin/integration/p1-engine-core-20261019` 끝 `15f3c2b15202778477b9c11049aca646a2fdc9e9`(김작 푸시 후 확인)
- 새 브랜치 `feature/night3-test-gaps-20261023`. 작성자·커미터 `noreply@anthropic.com`. 푸시 안 함.
- **테스트와 CI 목록만 추가했다.** 엔진·3D·셸·서비스·기존 테스트·골든·하니스는 한 줄도 바꾸지 않았다. 새 하니스도 필요 없었다(기존 하니스 재사용).
- 합격 판정 안 함(검수: 클코치).
- **멈춤 1건(G11 원래 형태)**: 엔진에 "이동한 뒤 책략" 경로가 없다. 그 픽스처는 제품 코드를 바꾸지 않으면 만들 수 없다. 대신 같은 변이(E4, 결과 보류 제거)를 잡는 이동 없는 형태로 테스트했다(§2 G11).

## 1. 새 테스트 (CI 편입 3개)

| 파일 | 항목 | 확인 내용 |
|---|---|---|
| `test_night3_gaps_engine.gd` | G1·G2·G3·G4 | G1: `scale_troop_value(3, 0.25) = 1`, `(1, 0.25) = 1`, `(2, 0.1) = 1`(내림이면 0), `(8, 0.25) = 2`, `(115, 0.25) = 28`. G2: `(0, 0.25) = 0`, `(0, 1.0) = 0`, `(-5, 0.25) = -5`. G3: 자동 on·아군 턴·연출 없음·hold 없음 상태에서 `set_auto_presentation_hold(false)`만 부르면 틱 0·스텝 0. G4: 엔진 hold를 래치가 다시 건 상태(픽스처)이고 3D는 마지막에 false를 보냈으며 한가하다. 이때 3D [자동]을 누르면 3D가 false를 보내고 자동이 이어진다(스텝 ≥ 1) |
| `test_battle3d_scenario_gaps.gd` | G5·G6·G7 | G5: [다시 시작] 신호 직후 **같은 프레임**에 옛 랩·엔진이 해제됐고, 새 엔진이 승리 연습 설정을 읽었다(관우 25), 메타 없음. G7: 약해진 적 3부대를 아군 옆에 둔 픽스처로 **라운드 1 승리**. 아군 증원 2부대는 미배치(병력 있음). 오버레이 "승리 · 라운드 1 · 생존 아군 3부대". G6: 기본 배치를 3D [대기]로 끝까지(라운드 6 패배). 결과가 온 뒤 적 재생이 남아 있는 프레임 동안 오버레이 0프레임 노출, 재생이 끝나고 노출 |
| `test_battle3d_option_strategy_gaps.gd` | G8·G9·G10·G11 | G8: 랩이 준비되기 전(`ready_for_input` false) 등급 요청 → 엔진 쓰기 0, 대기 값 없음. G9: 현재 하, 대기 중일 때 [중]만 눌림. G10: "적 책략 사용" 줄이 나온 프레임에 그 줄이 마지막 적 줄이고 `enemy_hold > 0`. G11(이동 없는 형태): 책략 결과 줄이 책략 사용 줄보다 **나중 프레임**(슬롯 완료와 함께)에 나온다 |

- 실행 결과(Windows, 단독 실행, 새 테스트만):

  | 테스트 | 기본 설정 | `--fixed-fps 60` |
  |---|---|---|
  | `test_night3_gaps_engine` | 7 checks 통과, 5초 | 7 checks 통과, 5초 |
  | `test_battle3d_scenario_gaps` | 7 checks 통과, 22초 | 7 checks 통과, 18초 |
  | `test_battle3d_option_strategy_gaps` | 5 checks 통과, 6초 | 5 checks 통과, 7초 |

- CI 목록(`verify-c-track.yml`)에 3개를 넣었다(테스트 3줄 추가만).
- 새 파일을 추가한 상태에서 CI 목록의 validator 51개를 모두 다시 돌렸고 전부 PASS다(모두 고정 모드라 새 파일의 영향 없음).
- 전체 CI는 돌리지 않았다. 제품 코드·기존 테스트가 그대로이고, 추가한 것은 테스트 3개와 CI 3줄뿐이다.

## 2. 변이 → 실패 확인 (각 테스트가 스스로 잡는지)

- 방식: 제품 파일에 변이를 1개씩 넣고 해당 새 테스트를 기본 설정으로 돌린 뒤 원래 바이트로 되돌렸다. 되돌림은 4개 파일 모두 `cmp`로 확인했다.
- 러너 `evidence/run_gap_probes.py`, 원문 `evidence/probes_default/`
- 대조군(변이 없음): 세 테스트 모두 exit 0

| # | 변이(지시 §2) | 넣은 곳 | 새 테스트 | 실패 문구 |
|---|---|---|---|---|
| G1 | 최소 1 보장 제거 | `battle_setup_rules_service.gd` `maxi(1, …)` → `int(floor(…))` | `test_night3_gaps_engine` | **잡음** "G1 a positive value never scales to 0" |
| G2 | 0 이하 그대로 제거 | 같은 함수의 `if value <= 0: return value` 삭제 | 같음 | **잡음** "G2 zero and negative values unchanged" |
| G3 | 해제 때 "대기 중이었을 때만" 제거 | 엔진 `set_auto_presentation_hold`의 `was_holding and` 삭제 | 같음 | **잡음** "G3 … no tick (1 -> 2)" |
| G4 | 3D가 엔진 hold와 비교 안 함 | `_update_auto_hold` 조건을 `hold == auto_hold_sent`만 | 같음 | **잡음** "G4 … (0 steps after 600 frames, calls [])" |
| G5 | 랩 즉시 해제 대신 `queue_free` | 셸 `_close_lab` | `test_battle3d_scenario_gaps` | **잡음** "G5 the old lab and engine are gone in the same frame" |
| G6 | 결과창을 적 재생 전에 | 셸 `_process`의 `_enemy_presentation_busy()` 조건 삭제 | 같음 | **잡음** "G6 … (43 frames shown while busy)" |
| G7 | 생존 아군 수에 미배치 증원 포함 | 셸 `_show_result`의 배치 조건 삭제 | 같음 | **잡음** "G7 … 생존 아군 5부대" |
| G8 | 준비 전 등급 요청 가드 제거 | 3D `request_ai_level`의 `ready_for_input` 줄 삭제 | `test_battle3d_option_strategy_gaps` | **잡음** "G8 before ready: no engine write, nothing pending" |
| G9 | 눌림 표시를 현재 값으로 | `_refresh_option_ui` 눌림 식 | 같음 | **잡음** "G9 the pending level's button is the pressed one" |
| G10 | 적 책략 줄 뒤 대기 제거 | `_present_enemy_event`의 `enemy_hold` 줄 삭제 | 같음 | **잡음** "G10 …"(그 프레임에 다음 줄 "라운드 2"까지 나옴), 덩달아 G11도 실패 |
| G11(E4) | 적 책략 결과를 완료까지 보류 안 함 | `_consume_tactic_events`의 보류 조건 `if false` | 같음 | **잡음** "G11 … (frames 0 -> 0)" |

- **11개 모두 잡았다.**

## 3. 지시 §3의 "4개 한꺼번에 제거" 질문 (M5-a2 커서 조건)

- 클코드 M5-a2 프로브 R5가 바로 그 변이였다. `_presentation_busy`의 커서 4개 비교 줄 전체를 `return false and …`로 바꿨다.
- 결과: **validator만 잡았고 테스트는 못 잡았다**(`test_battle3d_auto_hold_seed_1`, `…_1x_seed_1` 모두 exit 0, M5-a2 보고서 §3).
- 이유: "엔진 행동 중"(`is_demo_animating`/`enemy_turn`) 조건이 같은 구간을 덮는다.
- 이번 작업에서는 이 항목에 테스트를 추가하지 않았다(지시 §3 "중복 안전장치").

## 4. G11 — 원래 형태를 만들 수 없는 이유 (멈춤 보고)

- 적 책략은 `_play_enemy_ai_for_actor`에서 계획이 ATTACK이 아닐 때 **이동 전, 지금 칸에서만** 시도한다.
  - `battle_web_import_test.gd:8200` `if _try_enemy_strategy_for_actor(enemy_actor_state, decision_plan): return`
  - 함수 주석 `:4006` "uses strategy from the current cell"
- 호출 지점은 이 한 곳뿐이다(grep). 이동이 끝난 뒤의 흐름에는 책략 판단이 없다.
- 그래서 "적이 이동한 뒤 책략"은 지금 엔진에서 일어나지 않는다. 그런 픽스처를 만들려면 엔진(제품) 코드를 바꿔야 한다. 지시 §0 멈춤 규칙에 따라 만들지 않았다.
- 대신 같은 변이(E4·G11: 적 책략 결과를 슬롯 완료까지 보류하지 않음)를 잡는 테스트를 넣었다.
  - 결과 줄은 슬롯 완료 재생과 함께 나온다. 그래서 "적 책략 사용" 줄(재생 대기 0.35초)보다 나중 프레임이어야 한다.
  - 보류를 없애면 결과가 수신 즉시(같은 프레임) 나와 실패한다(§2 표).

## 5. 결정 사항

| 항목 | 결정 | 이유 |
|---|---|---|
| G4 상태 만들기 | 엔진 `auto_presentation_hold`·`auto_presentation_latch`를 테스트가 직접 씀(픽스처), 그 뒤 3D [자동] | "래치가 걸었는데 3D가 바쁘다고 보기 전에 끝난" 상황을 결정적으로 만드는 가장 작은 방법. 3D는 픽스처를 모르고 자기 판단으로 푼다 |
| G6 시나리오 | 기본 배치 전원 대기 패배(라운드 6) | 적이 마지막 아군을 잡는 결과라 적 재생이 남는다. 측정 결과 결과 뒤 바쁜 프레임이 실제로 있다(§1 결과) |
| G7 픽스처 | 승리 연습에서 적 3부대 병력 1, 보병 권율 주변 3칸에 배치 | 엔진 결과는 배치·생존 부대로만 정해진다(`_get_battle_result_state`, `:10571-10580`). 처음 배치(적 하나가 권율 사거리 밖)로는 라운드 1에 끝나지 않아 바꿨다 |
| G11 | 이동 없는 형태로 대체 | §4 |
| 파일 수 | 단계별로 3개 | 지시 "G5~G7 scenario 계열, G8·G9 M5-c 하니스, G10·G11 M4-e 하니스". G8~G11은 한 파일에 두 하니스를 같이 썼다 |

## 6. 확인 못 한 것

- Linux에서 돌리지 않았다.
- 사람이 직접 한 플레이는 없다(테스트·로그만).


## 7. G0 — 이름 겹침 경고 한 줄 (김작 승인 후, 별도 커밋)

- 승인: 김작 "G0 고쳐. 별도 커밋으로 const 한 줄만 지우고 검증기·영향 테스트 결과 보고해줘."
- 커밋 `15cbc80` `fix(battle): drop the UnitTypeContract const that shadows its global class (G0)`
- 변경: `scripts/battle/services/battle_attack_state_service.gd` 4번째 줄 `const UnitTypeContract = preload("res://scripts/battle/unit_type_contract.gd")` **1줄 삭제**(diff `1 deletion(-)`). 그 밖의 엔진·서비스 코드는 바꾸지 않았다.
  - 이 파일의 `UnitTypeContract.can_move_after_attack`(32줄)·`get_post_attack_move_limit`(34줄)은 이제 전역 클래스(`unit_type_contract.gd`의 `class_name UnitTypeContract`)를 그대로 쓴다.
- 사실 확인: 같은 이름의 const는 저장소 `scripts`·`tests`·`tools` 전체에서 이 한 줄뿐이었다(grep).

### 7-1. 결과 (Windows)

| 확인 | 결과 |
|---|---|
| `tools/validate_*.py` 전체 90개, 수정 전(`6835dcc` 분리 워크트리) vs 수정 후 | **결과 동일**(diff 0). 실패 9개는 수정 전과 같은 옛 검증기다(`hero_design_registry`, 컷인 오탐, T08 7개, ⑦에서 건드리지 않기로 한 것). 5병종 계열 `validate_five_unit_type_*` 4개, `validate_gunner_runtime_and_ai`, `validate_hero_five_unit_assignment`는 전후 모두 통과 |
| CI 목록 validator 51개 | 모두 PASS |
| 공격 상태 서비스 계열 | `test_battle_attack_state_service` 70 checks 통과(수정 전과 같은 70). `test_battle_attack_oracle_shard_1/2`, `test_battle_attack_event_parity` 통과 |
| 공격을 쓰는 다른 테스트 | `test_battle3d_engine_attack_shard_1/2/3`·`_rejections`·`_sync`, `test_battle_enemy_turn_oracle_shard_1/2`, `test_battle_tactic_oracle_shard_1`, `test_battle_move_oracle_baseline`, `test_battle3d_skill_equivalence_shard_1` 모두 통과 |

- 합계: 테스트 14개, validator 51개, 실패 0, 실행 전후 `git status`는 이 한 줄 변경만.
- 원문 zip `evidence/g0/`

### 7-2. 미확인

- **Godot 경고가 사라지는지는 확인하지 못했다.** 수정 전에도 헤드리스 실행(`--editor --quit-after 2`, 공격 상태 테스트)의 출력에 그 경고가 나오지 않았다. 그래서 전후 비교가 안 된다. 에디터 화면(오류창)에서 직접 봐야 한다.
- 사람이 직접 한 플레이는 없다.
