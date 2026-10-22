# BATTLE3D M4-c2 결과 — 3D 적 고유특기 재생 (2026-10-22)

- 작업 ID: M4-c2 3D Enemy Unique Skill Replay (밤샘 연속 ②)
- 지시문: `NIGHT2_M5A_M4C2_M5B_20261022.md` (클코치)
- 브랜치 `feature/battle3d-m4c2-enemy-skill-20261022` ← `origin/integration/p1-engine-core-20261019`(기준 `8957b27` 확인. M5-a에 쌓지 않음)
- 커밋 1개 `feat(battle3d): replay enemy unique skills in the enemy action order (M4-c2)`. 작성자·커미터 `noreply@anthropic.com`. 푸시 안 함.
- 합격 판정은 하지 않는다(검수: 클코치).
- **멈춤 규칙에 걸리지 않았다**:
  - 엔진·서비스·어댑터 수정 0
  - 쓰기 호출 추가 0(12개 그대로), 읽기 추가 0
  - 기존 테스트·하니스·골든 수정 0(M3 문구 예외도 쓰지 않음)
- **기존 M3 3D 코드 두 줄을 고쳤다(§5)**. 적 특기가 만드는 이벤트 순서에서 드러난 기존 표시 문제다:
  - ① 적 특기로 전투가 끝나면 엔진이 `battle_ended`를 그 슬롯의 `enemy_action_completed`보다 **먼저** 기록한다. 그래서 M3 요약이 빈 슬롯으로 두 번째 요약을 만들었다. → 이미 닫힌 슬롯의 완료는 요약하지 않는다.
  - ② 이동 후 특기 슬롯에서는 이동 이벤트가 있어 상태 차이 요약이 빠졌고, 특기의 병력 변화가 요약에 없었다. → 슬롯에 `enemy_skill_used`가 있으면 상태 차이도 붙인다.

---

## 0. 사전 확인 5개 (엔진 직접 실행, 새로 돌린 것)

스크립트: zip `evidence/m4c2_precheck/_tmp_m4c2_precheck.gd`(커밋 안 함), 원문 `precheck.log`. M4-c1 사전 확인 8(같은 측정)도 재사용했다.

### 1. 두 로그의 순서 — "시도 → (프레임 뒤) 시전·효과 → 종료+완료"

아군 대기 직후 적 슬롯에서 프레임별로 새로 쌓인 것(guan_yu, enemy_line):

| 프레임 | enemy_action_event_log | tactic_event_log |
|---|---|---|
| 0(대기 호출 안) | enemy_turn_started, enemy_actor_selected, **enemy_skill_used** | — |
| 50 | — | skill_cast |
| 114 | — | skill_effect ×N |
| 219 | **enemy_action_completed**, round_started | skill_finished(그다음 틱·증원) |

- **두 로그를 합치는 기준**:
  - 적 로그 재생이 그 시전자의 `enemy_skill_used`에 닿으면 그 시전자의 전술 이벤트를 보인다. 그때 아직 안 온 이벤트는 오는 대로 바로 보인다.
  - 재생이 `enemy_skill_used`보다 뒤처져 있으면(예: 앞선 이동 재생 중) 도착한 이벤트를 보류 큐에 쌓아 둔다.
  - `skill_finished`와 `enemy_action_completed`는 같은 프레임에 쌓인다. 3D는 적 로그를 먼저 읽고 전술 로그를 그다음에 읽는다. 그래서 재생이 완료에 닿기 전에 종료까지 모두 표시된다(테스트로 고정: 완료 재생 시 보류 0).
- 시전자 id 매칭: `enemy_skill_used.unit_id` == `skill_cast/effect/finished.caster_id`
- 한 슬롯에 특기는 1번이다(`_try_auto_unique_skill_for_actor`가 true면 슬롯이 그 특기로 끝남).
- 같은 시전자가 다음 라운드에 다시 쓰는 경우는 열림 표시를 완료 재생 때 지워서 구분한다.

### 2. 특기 후 다른 행동

- 계획 전 특기면 슬롯은 `선택 → 특기 → 완료`로 끝난다(특기 뒤 다른 행동 없음).
- **이동 후 특기**(`_play_enemy_actor_basic_attack_or_wait_after_move`)도 있다: `선택 → 이동 → 특기 → 완료`. 이때 이동 재생이 끝나기 전에 skill_cast가 도착할 수 있어 보류가 실제로 쓰인다(테스트 C5).

### 3. 효과 대상과 전투 종료

- 적 특기 효과가 아군에게 간다: `damage`(아군 대상, `killed`), `status`, 기세 `momentum`(target_id = 진영). 3D 표시는 이벤트의 target_id 모델 위치를 쓴다. 모델 위치는 매 동기화마다 엔진 셀을 따라간다.
- 시전자가 처치 후 전진하는 경우(`cheok_jun_gyeong_unique`, 테스트 C7)도 위치는 엔진 셀을 따른다.
- **마지막 아군을 특기로 처치**: 순서가 `enemy_skill_used → battle_ended(defeat) → enemy_action_completed`다(전투 종료 기록이 완료보다 먼저). 3D는 `battle_ended`를 받는 순간 결과 잠금을 건다(M3 규칙). 이 순서에서 생긴 두 번째 요약 문제를 고쳤다(§5).
- `move` 효과(후퇴)는 적에서 만들지 못했다. `retreat_counter`(self)를 적에게 주면 점수가 고가치 미만이라 공격을 골랐다(사전 확인 B_retreat_counter). 아군 쪽 `move` 표시는 M4-c1에서 확인했다.

### 4. 기세 HUD

- 보수적으로 c1 규칙 그대로 둔다: 적 재생 큐가 빌 때만 엔진 값으로 갱신한다.
- 적 특기의 `momentum` 효과는 전투 기록 "적 특기 기세 · 아군 기세 −2"로만 보인다. **HUD 옆의 아군 기세 메모(`momentum_note`)는 건드리지 않는다**(아군 특기 전용).

### 5. 요약 문구

- `_get_unique_skill_for_unit`(순수, M4-c1 승인)의 `display_name`으로 바꿀 수는 있다.
- 그러나 기존 M3 테스트가 `"적 특기 사용: " + skill_id` 문구를 단언한다. 그래서 **바꾸지 않았다**(기존 테스트 수정 예외를 쓰지 않음).
- 적 특기 표시 줄 자체("적 특기 · <시전자> · <표시 이름> (기세 −N)")는 c1과 같은 규칙으로 표시 이름을 쓴다.

---

## 1. 기능 상태

| 항목 | 상태 | 근거 |
|---|---|---|
| 적 시전 skill_*를 재생 순서에 맞춰 표시(그 시전자의 `enemy_skill_used` 재생 뒤) | 동작 | 동등성 7케이스, 매 프레임 순서 검사 |
| 보류 큐(재생이 뒤처질 때)와 완료 재생 시 비어 있음 | 동작 | C5(이동 후 특기), 전 케이스 보류 0·남은 것 0 |
| 남은 보류 이벤트는 버리지 않음(`enemy_skill_leftovers`에 기록) | 동작 | 코드·validator(실측 0회) |
| 적 시전 `strategy_cast` 보류(완료 재생 때, 그 적의 상태 틱과 함께 로그 순서로) | 동작 | 혼합 로그: 합성 적 책략 |
| 문구 "적 " 접두, 라벨(별도 메타), 별도 목록. 아군 c1 목록·기세 메모 불변 | 동작 | 동등성 + M4-c1 테스트 그대로 통과 |
| 적 특기로 전투 종료 → 결과 잠금, 요약 1개 | 동작 | C6 |
| 커서 독립(전술 커서는 끝까지 전진, 보류는 표시 시점만) | 동작 | 혼합 로그 |
| 엔진·서비스·어댑터 diff, 쓰기·읽기 추가 | 0 | validator |

## 2. UI 상태

- 적 특기 표시: 시전자 위 스킬 이름 라벨, 대상 위 "−N"(격파 줄), 상태 "<이름> N턴", 해제
  - 전투 기록·상태줄은 c1 문구 앞에 "적 "을 붙인다. 예: "적 특기 · xiahou_dun · 발검돌파 (기세 −2)", "적 특기 피해 · jeong_dojeon −60 · 격파", "적 특기 종료 · xiahou_dun"
  - 라벨 색은 c1과 같다
- 적 특기 사용 순간(재생이 `enemy_skill_used`에 닿을 때)의 기존 문구 "적 특기 사용: <skill_id>"는 그대로다.
- 알려진 표시 한계:
  - 라벨이 작다(c1과 같음)
  - 적 효과 라벨도 같은 대상 위에 겹친다
  - 처치당한 아군의 "격파 · <부대>"(아군 행동 로그 `unit_defeated`)는 적 재생과 별개로 바로 나온다(기존 M2 동작)

## 3. 실제 조작 증거

- **실제 Godot 창 캡처 1세트(5장). 뷰포트 입력 주입이며 사람 조작이 아니다.**
  - 비헤드리스 1280×800, 일반 랩, 기본 배치, fixture 없음. 아군 전원 대기
  - 드라이버: zip `evidence/m4c2_capture/capture_driver.gd`, 원문 `run/run.log`

| 캡처 | 내용 |
|---|---|
| 00 | 시작 |
| 01 | 라운드 3, xiahou_dun `enemy_skill_used` 재생 → 열림, 시전 라벨 "발검돌파". 이 프레임에는 시전이 이미 도착해 있었다 |
| 02 | 효과: jeong_dojeon 위 "−60 / 격파", 기록 "적 특기 피해 · jeong_dojeon −60 · 격파", "적 특기 기세 · 아군 기세 -2" |
| 03 | 같은 슬롯 진행 중(HUD는 재생 중 고정: 7/7) |
| 04 | 슬롯 끝: 보류 0, 열림 0. 요약에 "xiahou_dun 특기 … / jeong_dojeon 병력 60→0 / xiahou_dun 이동"(§5 ②의 상태 차이 포함). HUD 5/5 |

## 4. 남은 연결

- 적 책략 새 이벤트 `enemy_strategy_used`(S4-2 병합 후): 지금은 M3 소비자가 슬롯에 붙이기만 하고 표시하지 않는다. 효과 `strategy_cast`는 이번에 넣은 보류 규칙으로 완료 시점에 보인다.
- 적 특기 전용 FX·카메라, M3 요약의 표시 이름화(기존 테스트 문구 변경 필요).

## 5. 결정 사항 (질문 대신 보수적으로 정한 것)

| 항목 | 결정 | 이유 |
|---|---|---|
| 표시 시점 | 시전자의 `enemy_skill_used` 재생 이후. 그 전에 온 것은 보류, 그 뒤 온 것은 즉시 | 두 로그의 순번이 별개라 적 재생 순서를 기준으로 합침(지시문 §2-3) |
| 보류가 완료 재생 때 남으면 | 버리지 않고 `enemy_skill_leftovers`에 기록, 보류는 유지 | 지시문 "임의로 버리지 않음" |
| 적 `strategy_cast` | 그 적의 완료가 재생 대기 중이면 보류, 완료 재생 때 그 적의 상태 틱과 합쳐 로그 순번 순서로 표시 | 지시문(틱과 같은 규칙). 합성 로그 테스트에서 틱보다 늦게 기록돼도 로그 순서 유지 |
| 표시기 재사용 | c1 함수에 "적 표시 중" 플래그 1개. 문구 접두, 라벨 메타, 목록 분리, 기세 메모 보호를 그 플래그로 가름 | 지시문 "c1 표시기 재사용". 기존 c1 테스트가 아군 목록만 비교하므로 분리 필요 |
| 기세 HUD | 재생 큐가 빌 때만(즉시 보이지 않음) | 지시문 보수적 선택 |
| M3 요약 "특기 skill_id" | 그대로 | 기존 M3 테스트 문구 단언(예외 사용 안 함) |
| M3 요약 두 줄 수정 | ① 이미 닫힌 슬롯의 완료는 요약 안 함 ② 특기 슬롯은 상태 차이 포함 | 적 특기 순서에서 드러난 표시 오류. 기존 테스트 수정 없이 전체 CI 통과 |
| `move` 효과 | 적에서는 재현 불가로 보고 | 적 AI가 후퇴 특기를 고가치로 고르지 않음(사전 확인 3) |

## 6. 변경 파일

| 파일 | 변경 | 내용 |
|---|---|---|
| `scripts/battle3d/battle3d_engine_play.gd` | +61 −10 | 새 함수 3개 + 멤버 7개 |
| `.github/workflows/verify-c-track.yml` | +4 | validator 1, 테스트 3 |
| `tools/validate_battle3d_m4c2_enemy_skill.py` | 신규 | BASE `8957b27`, TIP 기본 `HEAD`(`M4C2_SCOPE_TIP`) |
| `tests/scripts/support/battle3d_enemy_skill_harness.gd` | 신규 | M4-c1 하니스 확장(적 특기 fixture 7종, 매 프레임 순서·잠금 검사) |
| `tests/scripts/test_battle3d_enemy_skill_{equivalence,default_round,mixed_log}.gd` | 신규 | |
| `.gd.uid` 4개 | 신규 | import |
| `agent/BATTLE3D_M4C2_RESULT_20261022.md` | 신규 | 이 보고서 |

`battle3d_engine_play.gd`에서 바꾼 기존 함수:
- `_consume_tactic_events`: 책략 분기 3줄, 특기 분기 2줄
- `_present_enemy_event`: 열기 1줄, 닫기 1줄
- `_consume_enemy_events`: §5 ① 2줄
- `_finish_enemy_summary`: §5 ② 1줄
- `_skill_line`, `_skill_label`, `_present_skill_event`, `_present_skill_effect`: 적 플래그 분기

## 7. 테스트 (CI 편입, 3개) — 케이스 목록

| 테스트 | 내용 | checks |
|---|---|---|
| `test_battle3d_enemy_skill_equivalence` | 아래 7케이스. 3D(대기 버튼) vs 엔진 직접 비교. 아래 "동등성 비교 항목" 참조 | 248 |
| `test_battle3d_enemy_skill_default_round` | 기본 배치 fixture 없음. 아군 전원 대기로 첫 적 특기가 나올 때까지(라운드 3, xiahou_dun). 3D == 엔진 직접. 적 특기 표시 == 이벤트, 보류 0, 요약 수 == 슬롯 수 | 11 |
| `test_battle3d_enemy_skill_mixed_log` | 아래 "혼합 로그" 참조 | 9 |

**동등성 7케이스**(적 특기 모드 / 나온 효과):

| 케이스 | 모드 | 효과 |
|---|---|---|
| C1 guan_yu | `enemy_line` | damage ×2, momentum |
| C2 | `single_enemy` | damage ×2, momentum |
| C3 | `enemy_area` | damage, status ×4, momentum |
| C4 | `self_area` | status ×3(적 아군에게), momentum |
| C5 이동 후 | `single_enemy` 원거리 | damage, status, momentum. 보류가 실제로 쓰임 |
| C6 마지막 아군 처치 | — | 패배, 결과 잠금 |
| C7 돌격 | — | 처치 후 전진, 시전자 셀 이동 |

**동등성 비교 항목**:
- M3 `check_case`: 유닛 40필드, 컨트롤러, 로그 3개, 쓰기, 재생 경로, 피격, 요약, 라운드, 결과
- 전술 로그, 12개 명령 안
- 적 skill_* 이벤트 표시가 로그 순서로 한 번씩, "적 " 줄 == 이벤트로 만든 기대 문자열, 적 Label3D 텍스트 == 기대
- 보류·열림·남은 것 0, 아군 c1 목록·기세 메모 불변
- 매 프레임: 적 시전 표시는 그 스킬의 "적 특기 사용" 재생 뒤에만. 열림 중에는 재생 큐 또는 엔진(적 턴·연출)이 입력을 잠금

**혼합 로그**:
- 아군 특기(3D), 적 특기(자기 슬롯), 시전자 화상 틱, 증원
- 그 적의 완료가 재생 대기 중일 때 전술 로그에 직접 쓴 **합성 적 `strategy_cast`**: 보류 확인, 완료 재생 뒤 정확히 1번
- strategy_cast/status_tick이 로그 순서로 1번씩
- 아군·적 특기 각각 1번씩, 증원 1번씩, 커서 4개 독립

- 적 특기 모드 8종 중 6종은 데이터에서 적이 고르는 경우가 드물어 만들지 않았다. 대신 지시문이 요구한 최소 집합(`single_enemy`·`enemy_line`·`enemy_area`·`self_area`)을 덮었다. `move`는 §0-3 사유로 빠졌다.
- 특기 표시 중 아군 입력 잠금은 매 프레임 검사로 확인했다.

## 8. validator `tools/validate_battle3d_m4c2_enemy_skill.py`

- 변경 파일 화이트리스트, 엔진·서비스·어댑터·골든·기존 하니스·기존 M3/M4-b/M4-c1 테스트·기존 validator diff 0, 워크플로 추가만(정확히 4줄)
- 엔진 호출·읽기 목록이 BASE와 같다(쓰기 12개 그대로). 3D 난수·훅 0
- 새 함수 3개·멤버 7개 정확, 바뀐 함수 8개 이내
- 커서 처리 kind 6개 그대로, `_: pass`, 커서가 멈추지 않음
- 특기 분기 3줄 고정(아군 즉시 / 열렸으면 즉시 / 아니면 보류), 적 책략 보류 줄 고정
- `enemy_skill_used` 재생에서 열기, `enemy_action_completed` 재생에서 닫기가 틱 표시보다 먼저
- 열기는 도착 순서대로 보이고 나서 보류를 비움. 닫기는 보류를 비우지 않고 남은 것을 기록. 책략·틱은 순번 정렬
- 적 표시 플래그 3줄 고정, "적 " 접두·적 목록, 적 라벨 메타, 기세 메모는 적 표시에서 안 바뀜
- M3 요약 수정 2줄 고정

## 9. 변조 프로브 (새로 돌린 것, 13개)

- 러너: zip `evidence/run_m4c2_probes.py`. 결과: 1차 `evidence/m4c2_probes_run1/`, 최종 `evidence/m4c2_probes_final/`

| 지시문 예 / 추가 | 프로브 | validator | Godot 테스트 |
|---|---|---|---|
| 적 이벤트를 즉시 표시 | P1 | exit 1 | exit 1 (C5; C1은 exit 0 *) |
| 보류를 버림 | P2 | exit 1 | exit 1 (C5; C1은 exit 0 *) |
| 아군처럼 표시 | P3 | exit 1 | exit 1 (C1, M4-c1 X) |
| 순서 반전(보류 역순) | P4 | exit 1 ** | exit 1 (C5) |
| 열기 호출 누락 | P5 | exit 1 | exit 1 (C1) |
| 적 책략 보류 안 함 | P6 | exit 1 | exit 1 (혼합 로그) |
| "적 " 접두 누락 | P7 | exit 1 | exit 1 (C1) |
| 적 라벨을 아군 메타로 | P8 | exit 1 | exit 1 (C1, M4-c1 X) |
| 적 기세가 아군 메모를 바꿈 | P9 | exit 1 | exit 1 (C1, M4-c1 X) |
| 남은 보류 기록 누락 | P10 | exit 1 | **exit 0(못 잡음)** |
| 전투 종료 후 두 번째 요약 | P11 | exit 1 ** | exit 1 (C6) |
| 책략·틱 로그 순서 깨짐 | P12 | exit 1 | exit 1 (혼합 로그) |
| 3D 난수 | P13 | exit 1 | **exit 0(못 잡음)** |

- \* C1류(계획 전 특기)에서는 재생이 `enemy_skill_used`에 먼저 닿고 시전이 나중에 와서 보류가 생기지 않는다. 그래서 1차에서는 P1·P2·P4를 테스트가 못 잡았다. 보류가 실제로 생기는 C5(이동 후 특기)를 프로브 실행에 더한 최종 실행에서 잡혔다.
- \*\* P4·P11은 **1차에서 validator가 못 잡았다**. P4는 순서 줄 미고정이었고, P11은 고정 문자열이 `battle_ended` 분기와도 겹쳤다. 두 줄을 정확히 고정한 뒤 최종 실행에서 잡혔다.
- P10: 정상 흐름에서는 남은 보류가 생기지 않아(실측 0회) 테스트로 만들 수 없다. validator만 잡는다.
- P13: 3D 표시에 난수가 쓰여도 엔진 상태·로그에 닿지 않는다. validator만 잡는다.
- 대조군: validator, C1, C6, 혼합 로그, M4-c1 X 모두 exit 0.

## 10. 전체 CI 로컬 재현 (새로 돌린 것, 1회)

- 최종 코드(커밋 직전 작업 트리, 보고서만 자리표시) 기준.
- 순서: `.godot` 삭제 → `--headless --editor --import`(**1회 만에 exit 0, 45초, signal 11 없음**) → `verify-c-track.yml` 목록 그대로 실행(러너 `run_ci.py`).
- **151단계 모두 exit 0**(합계 약 1,750초):
  - validator **41** = 기준 40 + M4-c2 1
  - Godot 테스트 **105** = 기준 102 + M4-c2 3
  - 씬 로드 3개, `--editor --quit-after 2`, `git diff --check`
- M4-c2 테스트 시간: 동등성 44.6초, 기본 배치 38.8초, 혼합 로그 6.9초. 가장 긴 파일은 기존 `test_battle3d_skill_equivalence_shard_1`(69.4초)이다.
- 기존 테스트는 수정 없이 통과했다.
  - M3 18케이스와 기본 배치·잠금: §5 요약 두 줄 수정 후에도 통과
  - M4-b 책략(적 틱 보류를 책략과 합친 뒤에도 통과)
  - M4-c1 특기: 적 특기 표시가 별도 목록·라벨 메타라 그대로 통과
- 실행 후 `git status`에는 이번 변경 파일만 있었다. 원문: zip `evidence/m4c2_ci_full_run/`.

## 11. 새로 돌린 것 / 재사용

- **새로 돌린 것**: 사전 확인 스크립트(프레임별 두 로그), 개발 실행, 변조 프로브 2회(1차, 최종), 창 캡처 1세트, fresh import + 전체 CI 1회, 커밋 후 validator 고정 모드.
- **재사용**: M4-c1 하니스·기대 문구 함수·S4-1 보드, M3 `check_case`, M4-c1 사전 확인 8(로그 순서), CI 러너.
- 환경: 혼합·기본 배치 첫 판 테스트가 필드 이름 오타(`summaries` → `enemy_summaries`)로 스크립트 오류가 나서 `quit`에 닿지 못하고 600초 타임아웃이 났다. 고친 뒤 두 파일로 나눴다(제품 코드와 무관).

## 12. 남은 위험

- P10·P13은 테스트로 못 잡는다(validator만).
- 적 `move` 효과 표시는 적 AI가 그 특기를 고르지 않아 실측이 없다(표시 함수는 c1과 같음).
- 적 특기 8모드 전부를 적 시전으로 만들지는 않았다(4모드 + 이동 후·처치·전진).
