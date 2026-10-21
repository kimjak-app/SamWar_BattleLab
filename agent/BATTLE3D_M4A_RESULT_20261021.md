# BATTLE3D M4-a 결과 — 3D 방어 명령 연결 (2026-10-21)

- 작업 ID: M4-a 3D Defend Command
- 지시문: `M4A_DEFEND_COMMAND_20261021.md` (클코치)
- 브랜치: `feature/battle3d-m4a-defend-20261021` ← `origin/integration/p1-engine-core-20261019`
- 기준 커밋 확인: `git log -1` = `ff25fdb docs(battle3d): record independent M3-b review` (지시문과 일치)
- 구현: 클코드 세션. **합격 판정은 하지 않는다. 푸시하지 않았다.** 코덱스 폴더(`C:\dev\SamWar_BattleLab`)는 건드리지 않았다.
- 구현 커밋 해시는 zip의 `commit_hashes.txt`에 적는다(이 보고서가 그 커밋에 들어가므로 여기에는 적을 수 없다).

---

## 0. 사전 확인 5개 (엔진 직접 실행, 새로 돌린 것)

확인 방법: 3D 없는 엔진 호스트(M3-b `battle3d_wait_harness.gd`의 `open_bare`)에서 엔진 함수를 직접 호출하는 임시 스크립트 2개. 커밋에는 넣지 않았다. 원문 스크립트·로그는 zip `evidence/m4a_precheck/`.

### 1. 방어가 남기는 이벤트 — 예상과 일치

- `_on_defend_button_pressed` 직후 `ally_move_event_log`, `battle_action_event_log` 모두 **새 이벤트 0개**(5개 변형 모두).
- 같은 fixture(M6: 적 guan_yu가 아군 yi_sunsin을 정면 공격)에서 엔진 직접 호출:

| 아군 명령 | `enemy_attack_resolved.damage_applied` | `raw_damage` | `target_troops_after` |
|---|---|---|---|
| 방어 (풀 HP) | **5** | 5 | 295 |
| 대기 (풀 HP) | **8** | 8 | 292 |
| 방어 (HP 150) | 5 | 5 | 160 |
| 대기 (HP 150) | 8 | 8 | 142 |

- 방어 때문에 줄어든 값이 `damage_applied`에 그대로 들어온다. **참고: `raw_damage`도 5다.** 즉 이 이벤트의 `raw_damage`는 방어 배율이 적용된 뒤의 값이다(방어 전 원래 값이 아님). 3D는 `damage_applied`만 표시하므로 영향은 없지만, 나중에 "방어로 줄어든 양"을 보여 주려면 이 필드로는 안 된다.

### 2. 방어 상태 수명 — 예상과 일치, 단 "즉시 끝나는 적 슬롯" 확인

- 켜짐: 방어 명령 안에서 `is_defending = true`, `last_action = {"type":"defend"}`, `has_acted = true`, `has_moved = true`(`_mark_ally_unit_acted`가 설정).
- 매 프레임 추적(`is_defending | phase | 마지막 적 이벤트`):
  - M6(마지막 아군 방어): `true|enemy_turn|enemy_actor_selected` → `true|enemy_turn|enemy_attack_resolved` → `false|ally_turn|round_started`. **적 슬롯(공격 판정 포함) 동안 유지되고, 새 라운드 시작에서 꺼진다.**
  - 기본 배치(첫 아군 방어, 마지막 아군 아님): 적 슬롯이 끝난 뒤에도 `true` 유지. 나머지 두 아군이 대기하고 라운드 2가 시작될 때 `false`.
- 꺼짐 위치: `BattleUnitState.reset_action_flags()`(새 라운드에 `_reset_ally_action_locks_for_new_round`가 호출).
- **즉시 끝나는 적 슬롯**: 적이 대기만 하는 fixture(M8)에서는 적 슬롯이 방어 호출 안에서 끝나고 라운드 2까지 시작한다. 그래서 **방어 호출이 돌아온 시점에 이미 `is_defending = false`, `has_acted = false`**다(테스트 D4로 고정). 지시문 경고대로 `is_defending`으로 수락을 판단하면 이 경우를 거절로 오판한다.

### 3. 부상병 회복 — 예상과 일치

- 회복 필드: `current_hp`와 `current_troops` 둘 다(`BattleUnitState.heal()`: 두 값에 같은 양을 더하고 각각 `max_hp`/`max_troops`로 자름).
- 회복량: `max(1, round(빠진 HP × 0.10))`. 빠진 **HP** 기준(병력 기준 아님).

| 방어 전 HP/병력 (최대 300) | 빠진 HP | 회복 HP | 회복 병력 | 어댑터 `current_troops` 변화 |
|---|---|---|---|---|
| 300 / 300 | 0 | 0 | 0 | 0 |
| 150 / 150 | 150 | 15 | 15 | +15 (호출 직후) |
| 297 / 297 | 3 | 1 (최소 1) | 1 | +1 (호출 직후) |

- 어댑터 `to_view().current_troops`에 **호출 직후 즉시 반영**된다. 풀 HP면 회복 0.

### 4. 거절 조건 — 대부분 대기와 같음, **전투 종료 후는 엔진이 막지 않음**

| 상황 | 엔진 결과 | 상태 변화 |
|---|---|---|
| 방향 선택 단계(`facing_select`) | 거부(phase 검사) | 없음 |
| 이동 연출 중(`is_demo_animating`, phase `resolving`) | 거부 | 없음 |
| 이미 행동한 부대 | 거부(행동 레지스트리) | 없음 |
| 혼란 아군 | 거부(`_is_active_ally_action_available`) | 없음 |
| 적 턴 중 | 거부(phase 검사) | 없음 |
| 이동 → 방향 확정 직후 | **수락** | 방어·행동 완료, 적 턴 시작 |
| 패배 후(phase가 `enemy_turn`에 머묾) | 거부(phase 검사) | 없음 |
| 승리 후, 미행동 아군이 행동 레지스트리에 있음 | 거부(레지스트리) | 없음 |
| **승리 후, 미행동 아군이 레지스트리에 없음**(사전 확인 2에서 fixture로 만듦) | **수락** | `is_defending = true`, `has_acted = true`, `last_action = defend`, 적 이벤트 0개(`_is_battle_result_finalized`에서 적 턴 없이 return) |

- `_on_defend_button_pressed` 시작부에는 전투 종료 검사가 없다(대기 `_end_ally_turn_by_wait`도 같음). 그래서 **전투 종료 후 방어를 막는 것은 3D의 결과 잠금뿐**이다. 거절 테스트는 이 "엔진이 받아 주는" 상태(레지스트리에서 지운 미행동 아군)를 일부러 만들어 3D가 엔진 쓰기 0회로 막는지 확인한다.
- 엔진 수정은 범위 밖이라 하지 않았다. 지시문 예상("엔진이 거부하는가")과 다른 점이라 보고한다.

### 5. 3D가 방어 상태를 보는 방법 — 승인된 직접 읽기 확대, 어댑터 변경 없음

- `BattleUnitState.is_defending`을 읽기 전용으로 읽는다. 읽는 곳은 **두 함수뿐**: 기존 `_refresh_target_info`(대상 패널, M2 승인)와 신규 `_unit_defending(unit)`(배지·부대 목록·부대 정보 패널). 쓰기는 0(validator 검사).
- 다른 방법 검토: 엔진의 `battle_hud_state_adapter.gd`도 같은 필드를 그대로 읽어 "방어" 문자열을 만든다. 거치면 의존만 늘고 안전성은 같다. 어댑터 14필드에 넣는 방법은 어댑터 변경이라 금지다. → **어댑터 변경이 필요 없어 멈추지 않고 진행했다.**

---

## 1. 기능 상태

| 항목 | 상태 | 근거 |
|---|---|---|
| 3D [방어] → 엔진 `_on_defend_button_pressed` (쓰기 호출 8번째) | 동작 | 동등성 D1~D7, 기본 배치 완주, 캡처 02·08 |
| 입력 잠금 우선순위(전투 종료 > 적 턴 > 연출 > 재생 큐) | 동작 | 거절 테스트: 연타, 적 턴 중, 재생 큐 중, 승리 후, 패배 후 |
| 사전 안내(phase → 선택 → 행동 여부)를 대기와 공유 | 동작 | `_ally_command_block_reason(command)` 하나를 대기·방어가 같이 쓴다. 대기 문구는 그대로("대기 불가 · …") |
| 수락 확인: 엔진 `has_acted` 또는 `enemy_action_event_log` 증가 | 동작 | D4(즉시 새 라운드)에서도 수락으로 판단, 혼란 아군은 거절 표시 |
| 엔진 거부 → "행동 불가 · 엔진이 방어를 수락하지 않았습니다" | 동작 | 거절 테스트(혼란 아군) |
| 방어 피해 감소 | 엔진 값 그대로 표시 | 엔진 직접 호출: 방어 5 < 미방어 8(동등성 테스트 마지막 단계). 3D 피격 숫자 = `damage_applied` |
| 부상병 회복 | 엔진 값 그대로 표시 | D3: 3D와 직접 호출 모두 +15. 3D는 호출 전후 `current_troops`만 읽는다 |
| 라운드 전환 시 방어 해제 | 엔진 규칙 그대로 | D5, 기본 배치 라운드 2 |
| 엔진·서비스 diff | 0줄 | validator |
| 핫키 | 없음 | validator(`_unhandled_input` 불변) |

## 2. UI 상태

- **[방어] 버튼**: [대기] 오른쪽(`Vector2(314,254)`, 110×38). 비활성 사유는 툴팁, 누르면 `_reject` 문구로 상태줄에 나온다.
- **부대 배지**: 방어 중이면 `행동 완료 · 방어 중`(엔진 `is_defending` 그대로). 오른쪽 아래 부대 목록 줄에도 같은 문구.
- **부대 정보 패널**(왼쪽 위): 선택 부대가 방어 중이면 끝에 `/ 방어 중`.
- **대상 정보 패널**(오른쪽 위): 기존 M2 그대로 `방어 중/아님`.
- **전투 기록**: 수락 직후 한 줄 `방어 · 부대ID`.
- **상태줄**: 수락 직후 `방어 · 부대ID / 병력 A→B · 이후 적 자동 행동`(A, B는 호출 전후 엔진 값). 단 다음 프레임에 적 턴이면 기존 M3 문구("적 자동 행동 중 · 입력 잠금 …")로 바로 덮인다(캡처 02). 전투 기록 줄은 남는다.
- 남은 표시 차이(새로 생긴 것 아님): M3에서 보고한 재생 지연. 캡처 09에서 엔진은 이미 라운드 2라 배지가 모두 `미행동`인데, 3D는 아직 xiahou_dun의 경로를 재생 중이다. 배지는 엔진 현재 상태를 읽기 때문이다.
- 고치지 않은 작은 것: 부대 목록 제목이 여전히 `부대 상태 (엔진 has_moved / has_acted)`다(`is_defending`은 제목에 없음).

## 3. 실제 조작 증거

- **실제 Godot 창 캡처 — 뷰포트 입력 주입이며 사람 조작이 아니다.**
  - 비헤드리스 `Godot_v4.6.2-stable_win64_console.exe --resolution 1280x800`, 일반 3D 랩 씬과 일반 호스트(spy 없음), **기본 배치, fixture 없음**.
  - 입력은 모두 `root.push_input`(셀은 화면 좌표, 버튼은 버튼 중심 좌표 클릭).
  - 드라이버: zip `evidence/m4a_capture/capture_driver.gd`(커밋 안 함). 원문 로그: `evidence/m4a_capture/run.log`(각 캡처 시점의 상태줄·배지·엔진 `is_defending`·정보 패널을 같이 출력).
  - 순서: yi_sunsin **방어** → 적 guan_yu 재생 → jeong_dojeon **대기** → 적 zhang_fei 재생 → gwon_yul **방어** → 적 xiahou_dun 재생 → **라운드 2**.

| 캡처 | 내용 |
|---|---|
| 00 | 기본 배치 시작, 라운드 1 |
| 01 | yi_sunsin 선택, [방어] 활성 |
| 02 | 방어 누름 → 적 턴, yi_sunsin 배지 `행동 완료 · 방어 중`, 정보 패널 `/ 방어 중`, 버튼 3개 비활성 |
| 03 | 적 guan_yu 경로 재생. 이 중 [방어] 클릭 → 거절("적 행동 재생 중", 로그) |
| 04 | 적 슬롯 1 종료, 라운드 1, yi_sunsin 여전히 `방어 중`(엔진 `true`) |
| 05 | jeong_dojeon 대기 |
| 06 | 적 zhang_fei 재생(재생 중 [방어] 거절) |
| 07 | 적 슬롯 2 종료 |
| 08 | gwon_yul 방어 → 배지 2개 `방어 중` |
| 09 | 적 xiahou_dun 재생(엔진은 이미 라운드 2, 배지 초기화) |
| 10 | 라운드 2, 모든 배지 `미행동`, `방어 중` 없음 |

- 최종 로그: `round=2 lab_round=2`, 전투 기록 `["방어 · yi_sunsin", …, "대기 · jeong_dojeon", …, "방어 · gwon_yul", …]`.
- 기본 배치에서 적은 세 번 모두 이동 후 대기했다(공격 없음). **방어한 부대가 실제로 맞는 장면은 캡처에 없다.** 그 장면은 자동 테스트(D1·D2·D3·D5, fixture)에서 `damage_applied`와 피격 라벨로 확인했다.
- 사람이 직접 마우스로 조작한 캡처는 없다.

## 4. 남은 연결

- 책략·고유특기·증원(M4-b 이후), 핫키(M6), 결과 화면(M5), 월드맵(M7)은 연결하지 않았다.
- 전투 종료 후 엔진이 방어(와 대기)를 직접 막지 않는 점(사전 확인 4)은 엔진 쪽 결정 사항이다. 지금은 3D 결과 잠금이 막는다.
- `enemy_attack_resolved.raw_damage`가 방어 적용 후 값이라는 점(사전 확인 1)은 향후 "감소량" 표시가 필요하면 엔진 이벤트 쪽 결정이 필요하다.

---

## 5. 변경 파일

| 파일 | 변경 | 내용 |
|---|---|---|
| `scripts/battle3d/battle3d_engine_play.gd` | +52 −5 | 방어 버튼, `request_defend`, 대기·방어 공유 안내 `_ally_command_block_reason`, `_unit_defending`(승인된 `is_defending` 읽기), 배지·정보 패널 표시, 도움말 한 줄 |
| `.github/workflows/verify-c-track.yml` | +4 | M4-a validator 1개, 테스트 3개 |
| `tools/validate_battle3d_m4a_defend.py` | +182 (신규) | BASE `ff25fdb`, TIP 기본 `HEAD`(`M4A_SCOPE_TIP`로 고정) |
| `tests/scripts/support/battle3d_defend_harness.gd` | +105 (신규) | M3-b 하니스 확장 |
| `tests/scripts/test_battle3d_defend_equivalence.gd` | +96 (신규) | |
| `tests/scripts/test_battle3d_defend_default_round.gd` | +105 (신규) | |
| `tests/scripts/test_battle3d_defend_rejections.gd` | +146 (신규) | |
| `.gd.uid` 4개 | +1씩 | Godot import 사이드카 |
| `agent/BATTLE3D_M4A_RESULT_20261021.md` | 신규 | 이 보고서 |

- 엔진·서비스·어댑터·기존 테스트·하니스·골든·기존 pinned validator: **수정 없음**.
- `_wait_block_reason()`은 이름과 반환 문구를 그대로 두고 공유 함수에 위임한다. 기존 M3-b 테스트는 수정 없이 통과(아래 CI).

## 6. 테스트 (CI 편입, 새로 돌린 것)

| 테스트 | 내용 | checks | 초(CI 재현) |
|---|---|---|---|
| `test_battle3d_defend_equivalence` | D1~D7: 3D 입력과 엔진 직접 `_on_defend_button_pressed` 비교. M3 비교 항목 전부(유닛 40필드, 컨트롤러 12값, 로그 3개, 쓰기 순서, 재생 경로, 피격 숫자 = `damage_applied`, 요약) + 쓰기 8개 계약 + 대기로 바꿔 보내지 않음 + 아군 로그에 방어 이벤트 없음 + 회복량 = 직접 호출 + 매 프레임 "방어 중" 표시 = 엔진. 마지막에 엔진 직접 호출로 방어 5 < 미방어 8 | 248 (+표시 비교 12,209) | 33.83 |
| `test_battle3d_defend_default_round` | fixture 없는 기본 배치, 3D 입력만: 1번 이동·방향 확정·대기, 2·3번 방어 → 적 슬롯 3개 재생 → 라운드 2. 엔진 직접 경로와 같음. 방어 직후/적 슬롯 중/라운드 전환 후 매 프레임 표시 = 엔진 | 77 (+표시 비교 7,438) | 14.06 |
| `test_battle3d_defend_rejections` | spy로 엔진 쓰기 0회 확인: 연타, 적 턴 중, 재생 큐 중, 이미 행동, 선택 없음, 방향 선택 단계, 엔진 거부(혼란), 승리 후, 패배 후(종료 후 미행동·레지스트리 제거 아군 fixture 포함). 격리(새 랩 잔여물 없음, 노드 누수 없음) | 75 | 16.29 |

- 케이스 구성(D1~D7):
  - D1 미행동 방어, 적이 방어 부대를 공격(감소된 피해가 이벤트·병력과 일치)
  - D2 이동·방향 확정 후 방어(방향 선택 중엔 버튼 비활성)
  - D3 부상 부대(HP 150 / 병력 140) 방어 → 회복 +15, 직접 호출과 같음. HP와 병력을 일부러 다르게 둬서 3D가 병력으로 공식을 흉내 내면 숫자가 달라지게 했다
  - D4 풀 HP 방어(회복 0), 적이 즉시 대기 → 호출 안에서 새 라운드 → `is_defending`이 이미 꺼졌어도 수락
  - D5 마지막 아군 방어, 적 슬롯 2개 → 라운드 2에서 엔진이 방어 해제
  - D6 방어하지 않은 다른 아군이 공격받음(방어 부대는 공격 0회)
  - D7 기본 배치, 적이 이동·대기, 라운드 1 동안 방어 유지
- 격리: 동등성 테스트가 7케이스를 한 프로세스에서 연속 실행(직접 호출 호스트 + 랩을 매번 열고 닫음). 거절 테스트 끝에서 새 랩 잔여물·노드 누수를 확인.
- 재사용: M3 fixture(M6/M7/M8/M10/M12/M13/M18), M3 `check_case`, M3-b 하니스의 열기·정착·클릭 함수.

## 7. validator `tools/validate_battle3d_m4a_defend.py`

- BASE `ff25fdb54ef52ad876c3ce60551e51348bc3693d`, TIP 기본 `HEAD`(병합 후 `M4A_SCOPE_TIP`로 고정). 기존 pinned validator는 수정하지 않았다(바이트 비교로 검사).
- 검사: 변경 파일 화이트리스트 / 엔진·서비스 diff 0 / 보호 파일·골든 바이트 / 워크플로 추가만(정확히 4줄) / 쓰기 호출 **정확히 8개**(방어·대기 호출 위치 각 1개, 서로 섞이지 않음) / 읽기 프로퍼티 8개·읽기 호출 3개 불변 / 동적 호출 없음 / 엔진·유닛 상태 쓰기 없음(`is_defending`, `current_troops` 포함) / 월드맵·결과·턴 제어·책략·고유특기·증원 호출 0 / `is_defending` 읽기는 `_refresh_target_info`와 `_unit_defending` 두 곳뿐, `_unit_defending` 본문 고정 / 새 멤버는 `defend_button`뿐 / 추가된 3D 코드에 소수 상수 없음, `max_hp`·`current_hp`·`heal(`·`DEFEND_`·`0.62` 없음 / `request_defend`: 무조건 입력 잠금 → 무조건 안내 → 명령, 그 안에 `battle_result` 예외 없음, 수락 확인(`has_acted`·`enemy_action_event_log`)이 기록보다 먼저, `is_defending`으로 수락 판단 안 함 / 버튼만(핫키 없음, `_unhandled_input` 불변) / "방어 중" 문구는 배지·정보 패널 두 곳뿐이고 `_unit_defending`에서 나옴.
- `M4A_SCOPE_TIP=<구현 커밋>`으로 커밋 고정 모드도 실행해 PASS 확인(zip `evidence/m4a_validator_pinned.txt`).

## 8. 변조 프로브 (새로 돌린 것)

- 방식: 3D 파일에 변조 1개씩 적용 → validator와 Godot 테스트 실행 → 원래 바이트로 복원(`finally`, 복원 후 `cmp`로 원본과 같음 확인). 러너 zip `evidence/run_m4a_probes.py`(치환 문자열 원문 포함), 결과 `evidence/m4a_probes_final/probes.json`과 각 로그.
- Godot 실패는 모두 parse/compile 오류 없이 단언 실패였다(`parse_error=False`).

| 지시문 §4-7 항목 | 프로브 | validator | Godot 테스트 |
|---|---|---|---|
| 방어 버튼 입력 잠금 제거 | P1(잠금+안내 모두 제거) | exit 1 | exit 1 (거절: 연타·적 턴·큐) |
| 전투 종료 후 방어 허용 | P2 | **1차 exit 0(못 잡음)** → 보강 후 exit 1 | exit 1 (거절: 승리 후 엔진 쓰기 발생) |
| 방어 호출 두 번 보내기 | P3 | exit 1 | exit 1 (동등성 D1: 쓰기 순서) |
| 3D가 `is_defending` 직접 쓰기 | P4a(명령 대신 대입) | exit 1 | exit 1 (동등성 D1) |
| 3D가 `current_troops` 직접 쓰기 | P4b(`defended.current_troops += 1`) | exit 1 | exit 1 (동등성 D1: 회복량·유닛 필드) |
| 수락 확인 제거 | P5 | exit 1 | exit 1 (거절: 혼란 아군이 성공으로 표시) |
| 방어 대신 대기 명령 보내기 | P6 | exit 1 | exit 1 (동등성 D1: 쓰기 순서) |
| 방어 표시를 3D 로컬 플래그로 | P7 | exit 1 | exit 1 (동등성 D1·기본 배치: 라운드 2 후에도 "방어 중") |
| 3D가 회복량을 계산해 표시 | P8(`maxi(1, round((max−before)×0.1))`) | exit 1 | exit 1 (D1: 300→301, D3: 140→156) |
| (추가) `_input_locked()` 호출 한 줄만 제거 | P9 | exit 1 | **exit 0 (못 잡음)** |
| (추가) 방어 핫키(G) 추가 | P10 | exit 1 | **exit 0 (못 잡음)** |

- **P2 1차 미검출**: 첫 validator는 `request_defend`의 잠금·안내 "순서"만 봐서, 순서는 그대로 두고 `battle_result`가 있을 때만 건너뛰는 변조를 놓쳤다. 그래서 `request_defend` 앞 4줄을 정확히 고정하고 `battle_result` 언급을 금지하도록 보강했고, P1·P2·P9를 다시 돌렸다(`evidence/m4a_probes_run2/`). 최종 validator로 전체 11개를 처음부터 다시 돌린 결과가 위 표다(`evidence/m4a_probes_final/`). 1차 결과 원문은 `evidence/m4a_probes_run1/`.
- **P9 테스트 미검출(M3-b R7과 같은 구조)**: 잠금 호출만 빼도 바로 다음 공유 안내가 같은 조건(종료 > 적 턴 > 연출 > 큐)을 같은 문구로 막아서 실행 동작이 변하지 않는다. validator만 잡는다.
- **P10 테스트 미검출**: 테스트는 키 입력을 넣지 않는다. validator(`_unhandled_input` 불변)만 잡는다.
- 대조군(변조 없음): validator, 동등성 D1·D3, 거절, 기본 배치 모두 exit 0.

## 9. 전체 CI 로컬 재현 (새로 돌린 것, 1회)

- 최종 코드(커밋 직전 작업 트리, 보고서만 자리표시 상태) 기준.
- 순서: `.godot` 삭제 → `--headless --editor --import` **1회 만에 exit 0, 45초, signal 11 없음** → `verify-c-track.yml` 목록 그대로 실행(러너는 M3-b와 같은 `run_ci.py`, zip `evidence/run_ci.py`).
- **120단계 모두 exit 0** (합계 약 766초):
  - validator **36** = 기존 35 + M4-a 1 (기대치 36과 같음)
  - Godot 테스트 **79** = 기존 76 + M4-a 3 (기대치 79와 같음)
  - 씬 로드 3개(WorldMap, Battle_Main, Imjin Iso), `--editor --quit-after 2`, `git diff --check`
- 기존 M3-b 테스트도 수정 없이 통과: 대기 동등성 178 checks, 기본 라운드 71, 거절 71.
- 실행 후 `git status`: 이번 변경 파일만(트리 오염 없음). 단계별 로그·`results.json`·`status_after.txt`는 zip `evidence/m4a_ci_full_run/`.
- 주의: CI 러너의 `checks` 열은 마지막 `checks=` 숫자를 잡아서 M4-a 동등성/기본 라운드에는 `display_checks` 값(12209/7438)이 들어가 있다. 실제 단언 수는 위 §6 표(248/77).

## 10. 새로 돌린 것 / 재사용

- **새로 돌린 것(이 세션)**: 사전 확인 2개, 신규 테스트 3개 개발 실행, 실제 창 캡처 1세트(11장), 변조 프로브 3회(1차 11개, 보강 후 3개, 최종 11개), fresh import 1회, 전체 CI 재현 1회(120단계), 커밋 후 validator 고정 모드 1회.
- **재사용(코드)**: M3 fixture·`check_case`, M3-b 하니스, M3-b CI 러너 `run_ci.py`(변경 없음), M3-b 캡처 드라이버 구조.
- 이전 보고서의 결과 수치는 재사용하지 않았다.

## 11. 남은 위험

- 전투 종료 후 엔진이 방어를 받아 줄 수 있는 상태가 있다(사전 확인 4). 3D 잠금이 막지만, 다른 입력 경로(2D 등)는 이번 범위가 아니다.
- 사람 조작 캡처가 없다. 방어한 부대가 맞는 장면의 실제 창 캡처도 없다(기본 배치에서 적이 공격하지 않음).
- P9·P10은 테스트로 못 잡고 validator만 잡는다.
- 상태줄의 "방어 · … / 병력 A→B" 문구는 적 턴이면 다음 프레임에 덮인다(전투 기록에는 남음).
