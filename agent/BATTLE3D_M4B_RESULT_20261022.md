# BATTLE3D M4-b 결과 — 3D 책략 명령 연결 (2026-10-22)

- 작업 ID: M4-b 3D Strategy Command
- 지시문: `M4BD_OVERNIGHT_20261022.md` 단계 ① (클코치). 김작 부재 중 실행, 질문 없음(§0-4 결정 사항 표 참고)
- 브랜치: `feature/battle3d-m4b-strategy-20261022` ← `origin/integration/p1-engine-core-20261019`
- 기준 커밋 확인: `git log -1` = `b3386e9 docs(battle): pin S4-1 validator to the merged implementation commit; record independent S4-1 review` (지시문과 일치)
- 커밋 1개(해시는 zip의 `commit_hashes.txt`). 작성자·커미터 이메일 `noreply@anthropic.com`.
- 구현: 클코드 세션. **합격 판정은 하지 않는다. 푸시하지 않았다.** 코덱스 폴더(`C:\dev\SamWar_BattleLab`)는 건드리지 않았다.
- **멈춤 규칙에 걸리지 않았다**: 엔진·서비스·어댑터 수정 0, 승인 범위 밖 읽기/쓰기 추가 0, 기존 테스트·하니스·골든 수정 0(§5 예외도 쓰지 않았다).

---

## 0. 사전 확인 7개 (엔진 직접 실행, 새로 돌린 것)

확인 방법: 3D 없는 엔진 호스트(M4-a 하니스 `open_bare`)에서 엔진 함수를 직접 호출하는 임시 스크립트 2개를 썼다(`_tmp_m4b_precheck.gd`, `_tmp_m4b_q4b.gd`). 커밋에는 넣지 않았다. 원문은 zip `evidence/m4b_precheck/`.

### 1. phase 이름 — S4-1 오라클 단언이 맞다(`"strategy"`), 감사의 `strategy_select`는 틀렸다

- 상수는 `PHASE_STRATEGY_SELECT := "strategy"`다.
- 전이: `ally_turn` → `_on_strategy_button_pressed` → **`strategy`** → `_try_use_strategy_on_target` → `resolving` → (`_mark_ally_unit_acted` 후) `enemy_turn` → 적 슬롯 → `ally_turn`.
- 즉시 끝나는 적 슬롯(예: 대상이 혼란으로 대기)이면 대상 확정 호출이 돌아온 순간 이미 `ally_turn`(새 라운드)이다(M6 fixture로 확인).

### 2. 읽기 질의 4개의 순수성 — 4개 모두 순수

- `_can_use_strategy`, `_get_strategy_range`, `_get_strategy_targets`, `_get_strategy_success_rate`를 `ally_turn`과 `strategy` 두 phase에서 각각 6번씩 호출했다.
- 호출 전후 비교: 유닛 40필드 × 10, 컨트롤러 12값, 로그 4개(기존 3개 + `tactic_event_log`)의 차이 0. `seed(31337)` 뒤 다음 `randf()` 값도 같았다(난수 소비 없음).
- 그래서 읽기 호출로 쓴다. 실제로 쓰는 것은 **3개**(`_can_use_strategy`, `_get_strategy_targets`, `_get_strategy_success_rate`)다. `_get_strategy_range`는 쓰지 않는다(validator가 금지).

### 3. 취소 — 엔진 규칙대로 되돌림

- `strategy` phase에서 `_handle_right_click_cancel`(기존 4번째 쓰기 호출) → `ally_turn`으로 돌아간다. `has_acted`는 false 그대로, `strategy_targeting_caster_state`는 null이다. 새 쓰기 호출은 만들지 않았다.

### 4. 기본 18×10 배치에서 책략이 가능한 상황 — **라운드 1에는 불가능, 라운드 2에는 가능**

- 기본 배치 아군 3부대 모두 `_can_use_strategy`를 통과한다:
  - yi_sunsin: 지력 96, master, 사거리 5
  - jeong_dojeon: 지력 97, master, 사거리 5
  - gwon_yul: 지력 84, basic, 사거리 3
- **라운드 1**: 시작 위치에서도, 이동 가능한 모든 칸(17·22·23칸)에서도 사거리 안에 적이 없다.
- **라운드 2**(라운드 1 전원 대기 후 적이 접근): 첫 아군 대기 후 jeong_dojeon이 (6,7)·(5,6)·(6,6) 등으로 이동하면 guan_yu/xiahou_dun이 사거리 안에 들어온다.
- 그래서 기본 배치 완주 테스트는 **fixture 없이** "라운드 1 전원 대기 → 라운드 2에 이동 후 책략 → 나머지 대기 → 라운드 3"으로 했다(지시문의 "라운드 2 도달" 대신 라운드 3까지). 라운드 1에는 책략 버튼이 비활성이고 "책략 불가 · 사거리 안에 적이 없습니다"가 나오는 것을 확인했다.

### 5. 상태 읽기 — **지시문의 전제와 다름: `status_effects`는 이미 어댑터 14필드에 있다**

- `battle3d_unit_adapter.gd`의 `VIEW_FIELDS`(14개)에 `status_effects`가 들어 있다. 3D 정보 패널은 M1부터 이미 이 값을 보여 왔다.
- 그래서 승인받은 `unit.status_effects` **직접 읽기는 쓰지 않았다**. 어댑터 값(`Adapter.to_view(unit).status_effects`)만 쓴다. 어댑터 파일 수정은 없다. 이쪽이 더 안전하다(새 읽기 경로 0).

### 6. 혼란/동요의 효과 — M3 재생으로 충분, 새 표시는 상태 배지만

- 혼란(confusion): 걸린 적은 자기 슬롯에서 `enemy_waited` reason `confused`를 남긴다. M3가 "적 X · 혼란"으로 이미 재생한다.
- 동요(shake): 이동·공격은 평소대로 한다(이벤트 `enemy_moved`, `enemy_attack_resolved`). 피해 배율 변화는 엔진 값 `damage_applied`에 이미 들어 있다.
- 추가 표시는 `strategy_cast` 결과 문구와 부대 배지의 상태·턴(엔진 `status_effects`)뿐이다.

### 7. 상태 틱이 나오는 시점과 표시 순서 — 결정

- 엔진은 각 유닛이 행동을 끝낼 때 `_mark_*_unit_acted` 안에서 틱(`status_tick`)을 기록한다. 적은 그 직후 `enemy_action_completed`(적 로그)를 남긴다.
- 매 프레임 추적 결과: 비동기 적 슬롯에서는 적 로그 7번째(그 적의 `enemy_action_completed`)와 전술 로그 2번째(그 적의 `status_tick`)가 같은 프레임에 생긴다. 즉시 슬롯에서는 둘 다 호출 안에서 한꺼번에 쌓인다.
- **표시 규칙(결정)**:
  - 적 유닛의 `status_tick`은 3D 재생 큐에 그 적의 `enemy_action_completed`가 남아 있으면 **보류**하고, 재생이 그 이벤트를 보여 주는 순간 표시한다.
  - 아군 틱(시전자)과 이미 재생이 끝난 적의 틱은 바로 표시한다.
  - 그래서 전술 로그를 읽기 전에 적 로그를 먼저 소비한다.
- 부대 배지·정보 패널의 상태는 **적 재생 큐가 빌 때만** 엔진 값으로 갱신한다. 재생 중에는 직전 표시를 유지한다(최종 상태가 미리 보이지 않게).

---

## 1. 기능 상태

| 항목 | 상태 | 근거 |
|---|---|---|
| 3D [책략] → 엔진 `_on_strategy_button_pressed`(9번째 쓰기) | 동작 | 동등성 10케이스, 기본 배치 완주, 캡처 |
| 대상 클릭 → 엔진 `_try_use_strategy_on_target`(10번째 쓰기) | 동작 | 동등성 10케이스 |
| 유효 대상 = 엔진 `_get_strategy_targets` 그대로, 그 밖 클릭은 엔진 호출 0 | 동작 | 거절: 사거리 밖 적·아군·빈 칸 |
| 성공률 미리보기 = 엔진 `_get_strategy_success_rate` | 동작 | 동등성: 대상마다 미리보기 == 엔진 값 |
| 입력 잠금(전투 종료 > 적 턴 > 연출 > 재생 큐) + 대기·방어와 같은 안내 + 엔진 책략 조건 + 사거리 내 대상 존재 | 동작 | 거절 테스트 |
| 수락 확인(버튼: phase `strategy` / 대상: `strategy_cast` 증가 또는 `has_acted`) | 동작 | 엔진 거절(대상 선택 중 혼란이 된 시전자) 표시 |
| 결과·틱 표시 = `tactic_event_log` 값 | 동작 | 동등성: 문구가 이벤트 값으로 만든 문구와 같음 |
| 네 번째 커서 `tactic_cursor`(독립, 다른 kind는 건너뜀) | 동작 | 혼합 로그 테스트(특기·증원 이벤트 섞임) |
| 엔진·서비스·어댑터 diff | 0줄 | validator |
| 3D 난수·훅 사용 | 0 | validator |

## 2. UI 상태

- **[책략] 버튼**: [방어] 오른쪽 `Vector2(434,254)`. 비활성 사유는 툴팁에 나오고, 누르면 상태줄에 거절 문구가 나온다:
  - 공용 사유(전투 종료/적 턴/연출/재생/phase/선택/행동함)
  - "책략 불가 · 엔진 조건(지력·혼란·행동 여부)을 충족하지 않습니다"
  - "책략 불가 · 사거리 안에 적이 없습니다"
- **대상 선택 모드**: 엔진 대상마다 청록 원판과 "성공률 NN%" 라벨이 뜬다. 마우스를 대상에 올리면 대상 패널에 "책략 성공률 NN%"가 붙는다. 우클릭은 기존 취소이고 표식을 지운다.
- **결과**: 대상 위에 떠오르는 라벨("동요 3턴"/"혼란 1턴"/"실패")이 나온다. 전투 기록에는 "책략 · 시전자 → 대상 · 성공/실패 · 결과 (성공률 NN%)"가 남고, 상태줄에도 같은 결과가 나온다.
- **틱**: 화상이면 "화상 −N" 라벨과 전투 기록 한 줄이 나오고, 만료된 상태마다 "<상태> 해제" 라벨이 나온다.
- **배지·로스터·정보 패널**: 기존 문구 뒤에 " · 동요 3턴" 형태로 엔진 상태가 붙는다. 이름 매핑은 동요·혼란·화상 3개이고, 모르는 id는 id 그대로 나온다.
- 알려진 표시 한계:
  - 기본 카메라 거리에서는 3D 떠오름 라벨이 작게 보인다(캡처 02·03).
  - 결과 상태줄 문구는 적 턴이 시작되면 바로 기존 M3 문구로 덮인다. 전투 기록과 배지에는 남는다.
  - 캡처 05(라운드 3)는 엔진이 라운드 3이 된 직후, 3D가 아직 라운드 2 적 슬롯을 재생하는 중에 찍혔다(M3부터 있는 재생 지연).

## 3. 실제 조작 증거

- **실제 Godot 창 캡처 2세트 — 뷰포트 입력 주입(`root.push_input`)이며 사람 조작이 아니다. 주사위는 S4-1 테스트 훅으로 강제했다**(성공 세트: 성공·후보 1, 실패 세트: 실패).
  - 비헤드리스 `--resolution 1280x800`, 일반 랩 씬·호스트(spy 없음), **기본 배치, fixture 없음**.
  - 드라이버: zip `evidence/m4b_capture/capture_driver.gd`(커밋 안 함). 원문 로그: `success/run.log`, `fail/run.log`.
  - 순서: 라운드 1 전원 대기 → 라운드 2 yi_sunsin 대기 → jeong_dojeon 이동·방향 확정 → [책략] → 대상(엔진 첫 대상) 클릭 → 적 재생 → 나머지 대기 → 라운드 3.

| 캡처 | 내용 |
|---|---|
| 00 | 라운드 1 시작, 책략 버튼 비활성(사거리 안 적 없음) |
| 01 | 라운드 2 jeong_dojeon 이동·방향 확정 후 책략 활성 |
| 02 | 대상 선택: 청록 표식 + 엔진 성공률 라벨 |
| 03 | 결과 직후(성공: guan_yu 배지 "동요 3턴" / 실패: 상태 없음) |
| 04 | 적 슬롯 재생 중 |
| 05 | 엔진 라운드 3 도달 시점 |

- 개발 중 드라이버를 두 번 고쳤다(재현 기록):
  - ① 단계 번호로 행동을 정해 실제 창 시간에서 어긋났다 → 엔진 상태(라운드 2의 jeong_dojeon)로 정하게 바꿨다.
  - ② 방향 버튼을 lab 동기화 전에 눌러 무시됐다 → 5프레임 기다리게 바꿨다.
  - 제품 코드 문제는 아니다(헤드리스 테스트의 같은 흐름은 통과).

## 4. 남은 연결

- 고유특기(M4-c), 증원 표시(M4-d), 핫키(M6), 책략 FX(엔진 연출) 재현은 하지 않았다.
- 적 책략은 엔진에 없다(사전 확인은 S4-1). 3D도 아군 수동만 한다.

## 5. 결정 사항 (질문 대신 보수적으로 정한 것)

| 항목 | 결정 | 이유 |
|---|---|---|
| 상태 읽기 경로 | 어댑터 `status_effects`(기존 14필드) | 승인된 직접 읽기보다 새 경로가 없어 안전(사전 확인 5) |
| 사거리 질의 | `_get_strategy_range` 미사용 | 대상 목록만으로 충분, 읽기 면적 최소 |
| 대상 없음일 때 버튼 | 3D 안내로 비활성(엔진 호출 0) | 엔진은 버튼을 받고 "유효 대상 없음"만 남겨 phase가 그대로라, 호출하면 쓰기 1회가 낭비되고 거절로 보인다. 엔진 대상 질의 값을 그대로 쓴다 |
| 적 틱 표시 시점 | 그 적의 `enemy_action_completed` 재생 때 | 엔진 순서(틱 → 완료)와 재생 순서를 맞춤 |
| 배지 상태 갱신 | 재생 큐가 빌 때만 | 재생 중 최종값 노출 방지 |
| 기본 배치 완주 | 라운드 3까지(라운드 2에 책략) | 라운드 1에는 사거리 안 적이 없음(사전 확인 4) |
| 상태 이름 사전 | {shake:동요, confusion:혼란, burn:화상}, 나머지 id 그대로 | 엔진 표시 사전과 같은 글자, 지시문 규칙 |

## 6. 변경 파일

| 파일 | 변경 | 내용 |
|---|---|---|
| `scripts/battle3d/battle3d_engine_play.gd` | +204 −3 | 새 함수 18개 + 멤버 9개. 공용 함수는 `_build_ui`(도움말 1줄), `_build_attack_ui`(버튼), `_process`(커서 1줄), `_sync_views`(버튼 상태 4줄), `_refresh_turn_ui`(배지 1줄), `_refresh_info`(상태 표시 1줄), `_click_world`(분기 3줄), `_unhandled_input`(호버 2줄), `_present_enemy_event`(틱 1줄)만 |
| `.github/workflows/verify-c-track.yml` | +5 | validator 1개, 테스트 4개 |
| `tools/validate_battle3d_m4b_strategy.py` | 신규 | BASE `b3386e9`, TIP 기본 `HEAD`(`M4B_SCOPE_TIP`) |
| `tests/scripts/support/battle3d_strategy_harness.gd` | 신규 | M4-a 하니스 확장(spy에 책략 2호출) |
| `tests/scripts/test_battle3d_strategy_{equivalence,default_round,rejections,mixed_log}.gd` | 신규 | |
| `.gd.uid` 5개 | 신규 | import 사이드카 |
| `agent/BATTLE3D_M4B_RESULT_20261022.md` | 신규 | 이 보고서 |

## 7. 테스트 (CI 편입)

| 테스트 | 내용 | checks | 초(CI 재현) |
|---|---|---|---|
| `test_battle3d_strategy_equivalence` | G1~G10: basic/advanced/master × 성공·실패, 후보 0·1, 걸린 적이 슬롯에서 행동(G9, 동요 → 이동·공격), 화상 시전자 틱(G10). 비교: 유닛 40필드, 컨트롤러 12값, 기존 로그 3개(M3 `check_case`), `tactic_event_log`, 쓰기 순서, 미리보기 == 엔진 성공률, 결과·틱 문구 == 이벤트 값, 네 번째 커서, 보류 틱 0, 매 프레임 "틱이 그 적의 완료 재생보다 먼저 나오지 않음"과 "재생 큐가 빌 때 배지 == 엔진 상태" | 391 (+표시 비교) | CI 표 참조 |
| `test_battle3d_strategy_default_round` | 기본 배치(fixture 없음, 골든 시작) 3D 입력만: 라운드 1 대기 3(책략 비활성 확인) → 라운드 2 대기·이동+책략·대기·대기(증원 포함) → 라운드 3. 엔진 직접 경로와 같음(유닛·컨트롤러·로그 4개·쓰기·재생 경로·피격·요약 수) | 47 | |
| `test_battle3d_strategy_rejections` | 연타, 적 턴 중, 재생 큐 중, 이미 행동, 선택 없음, 지력 부족, 혼란 아군(엔진 조건), 사거리 밖 적·아군·빈 칸 클릭, 대상 선택 중 우클릭 취소, 엔진 거절(대상 선택 중 혼란), 승리 후·패배 후(레지스트리에서 지운 미행동 아군 fixture), 격리 | 61 | |
| `test_battle3d_strategy_mixed_log` | 엔진에 직접 보낸 고유특기 + 라운드 2 증원 이벤트가 쌓인 로그에서 3D 책략: 다른 kind 건너뜀, 네 커서 독립 | 9 | |

- 주사위는 테스트 코드에서만 S4-1 훅으로 강제했다(3D 쪽 엔진과 직접 호출 쪽 엔진에 같은 값).
- 기본 배치 테스트는 M3 `check_case`를 그대로 쓰지 않았다. `check_case`의 "마지막 요약에 병력" 특기 검사는 적 슬롯이 하나라는 전제인데, 이 라운드에는 적 특기가 있는 슬롯이 여러 개다. 같은 비교(유닛·컨트롤러·로그·커서·재생 경로·피격·요약 수)는 테스트 안에서 직접 한다. 기존 테스트는 수정하지 않았다.

## 8. validator `tools/validate_battle3d_m4b_strategy.py`

검사 항목:
- 변경 파일 화이트리스트, 엔진·서비스·어댑터 diff 0, 보호 파일(엔진·어댑터·호스트·S4-1 서비스·기존 하니스 6개·기존 validator 8개) 바이트, 골든 5개 SHA-256, 워크플로 추가만(정확히 5줄)
- **쓰기 호출 정확히 10개**(대기·방어·책략 버튼·대상 각 1곳), 동적 호출 없음
- 읽기 프로퍼티 = M4-a 8개 + `tactic_event_log`, 읽기 호출 = M4-a 3개 + 책략 질의 3개
- `scripts/battle3d/**`에 `strategy_roll_override` 언급 0, `randf`/`randi`/`seed`/`RandomNumberGenerator` 0
- 금지 호출: 월드맵·결과·특기·증원·`_resolve_strategy`·`_roll_strategy_outcome`·`_get_strategy_range` 등
- 규칙 토큰 0: `intelligence`, `STRATEGY_`, `0.55`, `magnitude`, `apply_status_effect` 등
- 유닛 상태 쓰기 0
- 함수: 새 함수 18개 정확, 바뀐 공용 함수 9개 이내, 새 멤버 9개 정확, `is_defending` 읽는 곳 불변
- `request_strategy`: 무조건 잠금 → 무조건 안내 → 버튼 호출 → phase 확인
- `_click_strategy_cell`: 엔진 대상 질의 → 대상 없으면 호출 전 거절 → 호출 → `strategy_cast` 증가/`has_acted` 수락 확인이 표식 정리보다 먼저
- `_click_world`의 책략 분기는 `_input_locked()` 뒤에 있고, 버튼만 쓴다(핫키 없음)
- **네 번째 커서**: 두 kind만 처리하고 나머지는 `_: pass`. return/break/push_error가 없고, 커서는 증가만 하며, 다른 커서를 참조하지 않음
- 결과 문구는 `event.success`/`event.turns_after`/`event.status_id`/`event.success_rate`에서 나오고, 성공·실패 문구 방향이 고정. 틱 문구는 `event.burn_damage`/`event.expired`에서 나오고, 표시 인자에 숫자 상수가 없음. 곱셈은 `_rate_text`의 ×100 하나만
- 배지 상태는 어댑터 `value.status_effects`에서만 쓰고, 재생 큐가 빌 때만 갱신

## 9. 변조 프로브 (새로 돌린 것, 14개)

- 방식: 3D 파일에 변조를 1개씩 적용하고 validator와 Godot 테스트를 돌린 뒤, 원래 바이트로 복원했다(`cmp` 확인).
- 러너는 zip `evidence/run_m4b_probes.py`, 결과는 `evidence/m4b_probes_final/`. Godot 실패는 모두 parse 오류 없는 단언 실패였다.

| 지시문 §5-8 예 | 프로브 | validator | Godot 테스트 |
|---|---|---|---|
| 책략 버튼 입력 잠금 제거 | P1(잠금+안내 제거) | exit 1 | exit 1 (거절) |
| 전투 종료 후 책략 허용 | P2 | exit 1 | exit 1 (거절: 승리 후 쓰기) |
| 대상 확정 두 번 전송 | P3 | exit 1 | exit 1 (동등성 G1) |
| 3D가 성공률을 직접 계산해 표시 | P4(미리보기 0.55 고정) | exit 1 | exit 1 (동등성 G1: 미리보기 ≠ 엔진) |
| 3D가 상태·턴을 직접 계산 | P5(`turns + 1`) | exit 1 | exit 1 (동등성 G1: 문구) |
| 수락 확인 제거 | P6 | exit 1 | exit 1 (거절: 엔진 거절이 성공으로 보임) |
| burn_damage를 3D가 계산 | P7(4 고정) | exit 1 * | exit 1 (동등성 G10) |
| 성공·실패 표시 반대 | P8 | exit 1 * | exit 1 (동등성 G1) |
| 다른 kind에서 멈춤 | P9(`_: break`) | exit 1 | **exit 0(못 잡음)** |
| 〃 (커서가 멈춰 버림) | P9b(`tactic_cursor -= 1; break`) | exit 1 | exit 1 (혼합 로그) |
| 3D가 훅 설정 | P10 | exit 1 | exit 1 (동등성 G2: 실패가 성공으로) |
| 3D가 `randf` 호출 | P11 | exit 1 | **exit 0(못 잡음)** — 동등성 G1, 거절 |
| 상태 배지를 로컬 플래그로 | P12 | exit 1 | exit 1 (동등성 G9: 배지 ≠ 엔진) |
| (추가) `_input_locked()` 한 줄만 제거 | P13 | exit 1 | **exit 0(못 잡음)** |

- \* P7·P8은 **1차 실행에서 validator가 못 잡았다**(exit 0). 그래서 validator에 "표시 인자에 숫자 상수 금지"와 "성공·실패 문구 방향 고정"을 넣었고, 최종 실행에서 둘 다 잡혔다. 1차 결과 원문은 `evidence/m4b_probes_run1/`(P5 치환 문자열 오타로 1차 러너는 P5에서 중단, 수정 후 전체 재실행). 최종 표는 보강된 validator로 14개 전부를 다시 돌린 결과다.
- P9(`break`): 다음 프레임에 이어서 읽으므로 한 프레임 늦어질 뿐 기능은 같다. 테스트가 못 잡고 validator만 잡는다. 실제로 멈추는 변조(P9b)는 테스트도 잡는다.
- P11: 테스트는 주사위를 훅으로 강제하므로 3D의 난수 소비가 결과에 닿지 않는다. validator만 잡는다.
- P13: 공용 안내가 같은 조건·같은 문구로 막아서(M3-b R7·M4-a P9과 같은 구조) validator만 잡는다.
- 대조군: validator와 동등성 G1·G2·G9·G10, 거절, 혼합 로그 모두 exit 0.

## 10. 전체 CI 로컬 재현 (새로 돌린 것, 1회)

- 최종 코드(커밋 직전 작업 트리, 보고서만 자리표시) 기준. 순서: `.godot` 삭제 → `--headless --editor --import`(**1회 만에 exit 0, 37초, signal 11 없음**) → `verify-c-track.yml` 목록 그대로 실행(러너 `run_ci.py`, zip `evidence/run_ci.py`).
- **135단계 모두 exit 0**(합계 약 1,198초):
  - validator **38** = 기준 37 + M4-b 1(지시문의 "38"과 같음)
  - Godot 테스트 **92** = 88 + M4-b 4
  - 씬 로드 3개, `--editor --quit-after 2`, `git diff --check`
- M4-b 테스트 시간: 동등성 37.8초, 기본 배치 29.5초, 거절 16.3초, 혼합 로그 6.1초. 기존 M3~M4-a 3D 테스트는 수정 없이 통과했다.
- 실행 후 `git status`에는 이번 변경 파일만 있었다. 로그는 zip `evidence/m4b_ci_full_run/`.
- 참고: CI 러너 `checks` 열은 마지막 `checks=` 숫자를 잡아서, 동등성 칸에는 표시 비교 수(2874)가 들어 있다. 실제 단언 수는 391이다.

## 11. 새로 돌린 것 / 재사용

- **새로 돌린 것**: 사전 확인 2개 스크립트, 신규 테스트 개발 실행, 변조 프로브 2회(1차, 최종), 실제 창 캡처 2세트(+드라이버 디버그 2회), fresh import 1회, 전체 CI 1회, 커밋 후 validator 고정 모드 1회.
- **재사용(코드)**: M4-a 하니스(WaitSpyBattle·fixture·열기/정착), M3 `check_case`(동등성), M4-a 캡처·프로브 러너 구조, CI 러너 `run_ci.py`(변경 없음).

## 12. 남은 위험

- P9·P11·P13은 테스트로 못 잡는다(validator만).
- 사람이 직접 조작한 캡처가 없다. 캡처는 훅으로 결과를 강제했다.
- 3D 라벨이 기본 카메라에서 작다(가독성은 M6 UI 정리 때).
- `_get_strategy_targets`가 비어 있으면 3D가 버튼을 막는다. 엔진은 버튼을 받아 "유효 대상 없음" 로그만 남기므로 동작 차이는 없지만, 2D와 달리 3D에서는 그 로그 줄이 생기지 않는다.
