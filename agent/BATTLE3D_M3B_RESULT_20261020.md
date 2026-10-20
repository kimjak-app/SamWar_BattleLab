# M3-b 3D 대기 명령 연결 결과

- 작업: M3-b (3D 대기 명령 연결, 기본 배치 한 라운드 완주). 기준 지시문은 `M3B_WAIT_COMMAND_20261020.md`.
- 기준(BASE): M3 커밋 `168b887ca598233a57bd39bbf7a13016d0701ec0`.
- 브랜치: `feature/battle3d-m3-enemy-turn-20261020`. 로컬 커밋만 했고 **push·merge는 하지 않았다**.
- 구현: Claude Code (클코). **합격 판정은 하지 않는다.** 검수는 클코치가 독립적으로 한다.
- 엔진 파일 diff: **0줄**(validator가 검사). 쓰기 호출은 **7개**: M2의 6개 + `_end_ally_turn_by_wait`. 방어는 연결하지 않았다.

## 0. 사전 확인 (지시문 §2, 실제 실행으로 확인)

확인 방법: 3D 없는 엔진 호스트에서 엔진 함수를 직접 호출하는 스크립트를 썼다. 원문 출력은 zip `evidence/m3b_precheck/`.

엔진 코드(`_end_ally_turn_by_wait`)는 지시문 §2의 설명과 일치한다.
- 조건: 인트로 카메라 재생 중 아님, `ally_turn`, `!is_demo_animating`, 활성 부대 있음, `_is_active_ally_action_available()`
- 동작: `_clear_pending_move_snapshot` → `has_moved=true` → `ally_has_moved=true` → `_mark_ally_unit_acted` → 로그 "대기" → `enemy_turn` → `_play_enemy_turn_demo()`
- 지시문에 없던 내용 하나: `_is_active_ally_action_available()`는 아래 중 하나라도 해당하면 false를 반환한다.
  - 진영이 아군이 아님
  - 사망
  - **혼란 계열 상태**(confusion, action_lock, fear)
  - 이미 행동함(잠금 서비스 기준)
  - 이 경우 엔진은 "이미 행동한 부대입니다" 로그만 남기고 아무것도 바꾸지 않는다.

**Q1. 대기가 남기는 이벤트 → 없다(예상과 같음).**
- 대기 호출 직후 `ally_move_event_log`와 `battle_action_event_log`에 새 이벤트가 0개다. `action_completed`는 공격 경로에만 있다.
- 대기의 결과는 엔진 상태(`has_acted=true`, `has_moved=true`)와, 대기가 시작하는 적 슬롯의 `enemy_action_event_log` 이벤트로만 드러난다.
- 3D는 대기 직후 **상태로 반영**한다(배지 "행동 완료").
- 적이 즉사 공격을 하면 공용 `unit_defeated`가 `battle_action_event_log`에 남는다. 이것은 대기가 아니라 적 행동이 남기는 이벤트다(W4에서 확인).

**Q2. 이동 직후 대기**
- **방향 선택 단계(`facing_select`)에서는 대기할 수 없다.** 엔진이 phase 조건에서 바로 return하고, 상태는 바뀌지 않는다.
- 3D는 이 단계에서 대기 버튼을 비활성화하고 "행동 불가 · 현재 선택 단계를 완료하거나 취소하세요"로 안내한다.
- 이 단계에서 우클릭 취소를 하면 이동이 되돌려진다(`move_reverted`).
- **방향을 확정하면** `_select_post_move_facing`이 그 시점에 pending 스냅샷을 지운다. 그래서 그 뒤에는 우클릭을 해도 이동이 되돌려지지 않는다(셀 유지, `has_moved=true`). 대기는 가능하다.
- 대기의 `_clear_pending_move_snapshot`은 이 흐름에서는 이미 비어 있는 스냅샷을 다시 지우는 셈이다.
- 대기 후에는 `has_acted=true`이고, 우클릭으로도 셀과 행동 상태가 바뀌지 않는다.
- 이동 → 방향 → 대기 흐름의 아군 로그는 `unit_moved`, `facing_changed`, `move_confirmed`(이동 이벤트)뿐이다.

**Q3. 마지막 아군이 대기하면**
- 대기 → `_play_enemy_turn_demo` → 적 슬롯 1개 → `_return_to_ally_turn` → `_get_next_side_after_enemy_action` 순서로 진행한다.
- 아군이 모두 행동했고 적도 모두 행동했으면 `round_complete` → `_start_new_round` → `round_started`.
- 아군만 모두 행동했으면 `"enemy"` → 남은 적이 한 명씩 이어서 행동한다.
- 기본 배치에서는 아군 3부대가 차례로 대기하면 적 슬롯이 1개씩 끼어든다(아군→적→아군→적→아군→적). 세 번째 적 슬롯 뒤에 **라운드 2**가 된다.
- 기본 배치의 적 3부대는 이 라운드에서 모두 "이동 → 대기"였다.

**Q4. 전투 종료 후 대기**
- **엔진**:
  - 승리 후(phase `ally_turn`)에는 활성 부대가 공격을 끝낸 아군이라 "이미 행동"으로 거부되고, 상태 변화가 0이다.
  - 다른 미행동 아군을 엔진에서 직접 선택한 뒤 대기해도 상태 변화가 0이었다.
  - 패배 후에는 활성 부대가 없어서 거부된다.
- **3D**: 엔진에 닿기 전에 막는다. `battle_ended`를 받으면 `_input_locked()`의 첫 조건(결과)과 대기 안내의 첫 조건이 모두 "전투 종료"가 된다.
- 테스트는 종료 후 fixture로 **미행동 아군을 활성 부대로 바꿔도** 3D가 엔진 호출 0회로 거절하는 것을 확인한다.

## ⚑ 기본 18×10 배치 한 라운드 완주 (M3 보고서의 미충족 항목)

**충족됐다.** fixture 없이 3D 입력만으로 진행했다:
1. 아군 1(yi_sunsin): 이동 (3,8)→(4,8) → 방향 확정 → 대기
2. 적 슬롯 1 재생(guan_yu 이동 → 대기)
3. 아군 2(jeong_dojeon) 대기 → 적 슬롯 2(zhang_fei)
4. 아군 3(gwon_yul) 대기 → 적 슬롯 3(xiahou_dun) → **라운드 2**

근거:
- 같은 명령 순서를 3D 없는 엔진에 직접 보낸 결과와 같다: 유닛 40필드, 컨트롤러 12값, 로그 3개, 쓰기 호출 순서(`test_battle3d_wait_default_round`, 71 checks)
- 실제 창 캡처 12장(§3)
- 시작 상태 == M3 기본 배치 golden

## 1. 기능 상태

| 기능 | 상태 | 근거 |
|---|---|---|
| 3D 대기 → 엔진 `_end_ally_turn_by_wait` | 동작 (자동 테스트 + 실제 창 캡처) | 대기 동등성 6케이스, 기본 배치 완주, 캡처 03·06·09 |
| 이동·방향 확정 후 대기 | 동작 | W2, 기본 배치 1단계 |
| 마지막 아군 대기 → 적 슬롯 → 라운드 전환 | 동작 | W1·W2·W3·W5·W6, 기본 배치(라운드 2) |
| 대기 뒤 적 슬롯에 공격 / 이동 / 대기가 포함된 경우 | 동작 | 공격: W1·W2·W4·W5, 이동: W2·W5·기본 배치, 대기: W3·W5·기본 배치(적 3부대 모두 이동 → 대기) |
| 대기 후 적 즉사 공격 → 아군 턴 복귀 | 동작 | W4 (아군 1부대 남김) |
| 엔진이 대기를 거부하면(혼란 아군) 거절로 표시 | 동작 | 거절 테스트: 엔진 호출 1회, 상태 변화 0, "행동 불가 · 엔진이 대기를 수락하지 않았습니다" |
| 거절 시 엔진 호출 0회 | 동작 | 연타 두 번째, 적 턴 중, 재생 큐 중, 이미 행동한 부대, 선택 없음, 방향 선택 단계, 승리 후, 패배 후 |
| **기본 18×10 배치 한 라운드 완주** | **동작** | 위 ⚑ 항목 |
| 방어 | 연결 안 함(M4) | validator와 spy로 호출 0 확인 |

## 2. UI 상태

- **대기 버튼**: 공격 버튼 오른쪽에 "대기" 버튼 1개. 핫키는 없다(M6에서 정리).
- **활성 조건**: 전투 종료 아님 · `enemy_turn` 아님 · `!is_demo_animating` · 적 재생 큐가 빔 · phase가 `ally_turn` · 활성 부대 있음 · 미행동. `_wait_block_reason()`이 엔진 상태를 읽어 이 순서대로 판정하고, 버튼의 `disabled`와 `tooltip_text`(비활성 사유)도 같은 함수에서 정한다.
- **클릭 처리 순서**: `_input_locked()`(M3: 전투 종료 > enemy_turn > 연출 중 > 재생 큐) → `_wait_block_reason()` → 엔진 호출. 거절은 기존 `_reject`로 "거절 / <사유>"를 표시한다.
- **수락 확인**: 호출 뒤 엔진 상태를 다시 읽어 판정한다. 대기한 부대의 `has_acted`가 참이거나, 엔진이 시작한 적 슬롯의 이벤트가 적 로그에 생겼으면 수락이다.
  - 두 번째 조건이 필요한 이유: 적 슬롯이 즉시 끝나 라운드가 넘어가면 `has_acted`가 다시 false가 되고 phase도 `ally_turn`으로 돌아와 있을 수 있다(W3·W6·M8에서 실제로 발생).
  - 3D 쪽에 별도 원장은 없다.
- **수락 후 표시**: 전투 기록에 "대기 · <id>", 상태바에 "대기 · <id> / 이후 적 자동 행동". 이후 적 재생은 M3 코드(세 번째 커서, 재생 큐) 그대로다.
- **부대 배지**: 대기한 부대는 엔진 플래그에 따라 "행동 완료"가 된다. 라운드 2에서는 전원 "미행동"으로 초기화된다(캡처 11).
- 강제 턴 종료, 방어, 책략, 특기 명령은 추가하지 않았다.

## 3. 실제 조작 증거

- **자동 테스트로 확인한 것**: 대기 동등성 6케이스, 기본 배치 완주, 거절. 입력은 `lab._unhandled_input`과 버튼 `pressed.emit()`이다.
- **실제 Godot 창 캡처 — 뷰포트 입력 주입이며 사람 조작이 아니다**:
  - 비헤드리스 `Godot_v4.6.2-stable_win64_console.exe --resolution 1280x800`, 일반 3D 랩 씬과 일반 호스트(spy 없음), **기본 배치에 fixture 없음**.
  - 셀과 버튼 모두 **화면 좌표 클릭**을 `root.push_input(...)`으로 넣었다. 버튼도 GUI 입력 경로를 거친다.
  - 드라이버는 zip `evidence/m3b_capture/capture_driver.gd`이고 커밋에는 넣지 않았다. 원문 로그는 `evidence/m3b_capture/run.log`.
  - 캡처 12장:
    - `00_default_start_round1`
    - `01_moved_facing_select_wait_disabled`: 이동 후 방향 선택 중이라 대기 비활성
    - `02_facing_confirmed_wait_enabled`
    - `03_wait_pressed_yi_sunsin`
    - `04_enemy_path_playback_after_yi_sunsin`: guan_yu (14,2)→(10,2)
    - `05_after_enemy_slot_1`
    - `06_wait_pressed_jeong_dojeon` → `07` 적 경로(zhang_fei) → `08`
    - `09_wait_pressed_gwon_yul` → `10` 적 경로(xiahou_dun)
    - `11_after_enemy_slot_3`: **"라운드 2 · 아군 턴"**, 증원 배치, 전원 "미행동"
- **사람이 직접 마우스로 조작한 증거는 이번에도 없다.**

## 4. 남은 연결

- 방어·책략·특기 명령과 연출: M4(방어는 이번에 의도적으로 제외).
- 대기 핫키, 버튼 배치와 정보 계층 정리: M6.
- 결과 화면 본체와 재시작: M5. 월드맵: M7.
- M3에서 보고한 재생 지연 표시 차이는 그대로 남아 있다. 캡처 04에서는 상단이 "적 턴 · guan_yu"인데 왼쪽 정보 패널은 이미 엔진이 고른 다음 아군(jeong_dojeon)이다.

## 5. 변경 파일 (`168b887..`, `git diff --numstat`)

| 파일 | +/− | 비고 |
|---|---|---|
| `scripts/battle3d/battle3d_engine_play.gd` | +49 / −1 | 대기 버튼, `_wait_block_reason`, `request_wait`, 버튼 상태, 도움말 한 줄. 엔진·서비스는 0줄 |
| `tools/validate_battle3d_m3_enemy_turn.py` | +1 / −1 | 기본 TIP을 `168b887…`로 고정(S3-1 때와 같은 방식). 이렇게 해야 M3 validator가 M3 범위만 계속 검사한다 |
| `.github/workflows/verify-c-track.yml` | +4 | M3-b validator 1개와 테스트 3개 추가 |
| `tools/validate_battle3d_m3b_wait.py` | +143 (신규) | |
| `tests/scripts/support/battle3d_wait_harness.gd` | +113 (신규) | M3 하니스 확장: spy에 `_end_ally_turn_by_wait`·`_on_defend_button_pressed` 추가 |
| `tests/scripts/test_battle3d_wait_equivalence.gd` | +48 (신규) | M3 동등성 테스트를 확장해 M3의 케이스별 검사를 그대로 재사용 |
| `tests/scripts/test_battle3d_wait_default_round.gd` | +84 (신규) | |
| `tests/scripts/test_battle3d_wait_rejections.gd` | +142 (신규) | |
| `.gd.uid` 4개 | +1씩 | CI import 사이드카 |
| `agent/BATTLE3D_M3B_RESULT_20261020.md` | 이 보고서 | |

기존 M3 테스트·하니스·golden은 바꾸지 않았다. validator가 바이트 단위로 검사하고, M3 start golden의 sha도 고정해 두었다.

## 6. 테스트

| 테스트 | 내용 | checks | 초 (CI 실행) |
|---|---|---:|---:|
| `test_battle3d_wait_equivalence` | W1~W6: 3D 입력(버튼·클릭)과 엔진 직접 `_end_ally_turn_by_wait` 비교. M3의 비교 항목 전부 + 쓰기 7개 계약 + 방어 0 + 대기가 아군 로그에 이벤트를 남기지 않음 | 178 | 27.51 |
| `test_battle3d_wait_default_round` | fixture 없는 기본 배치에서 3D 입력만으로 라운드 2 도달, 엔진 직접 경로와 같음 | 71 | 14.04 |
| `test_battle3d_wait_rejections` | 연타, 적 턴 중, 재생 큐 중, 이미 행동, 선택 없음, 방향 선택 단계, 엔진 거부(혼란), 승리 후, 패배 후(종료 후 미행동 활성 fixture 포함), 격리 | 71 | 16.61 |
| `validate_battle3d_m3b_wait.py` | 범위, 엔진 diff 0, 쓰기 7개, 읽기 8개 불변, 방어·월드맵·결과·턴 제어 호출 0, 바뀐 함수 화이트리스트, 잠금 → 안내 → 호출 → 수락 확인 순서, 핫키 없음 | - | 1.66 |

케이스 W1~W6 (fixture는 M3·S3-1 하니스 재사용):
- W1: 미행동 부대 대기 → 적 제자리 공격 → 라운드 2
- W2: 이동·방향 확정 후 대기 → 적 이동 + 공격 → 라운드 2
- W3: 마지막 아군 대기 → 적 대기 → 라운드 2
- W4: 대기(아군 1부대 남김) → 적 즉사 공격 → 아군 턴
- W5: 대기 → 적 슬롯 2개 연속(이동 + 공격, 이동 + 대기) → 라운드 2
- W6: 대기 → 적 혼란 → 라운드 2

spy 기록에는 엔진이 **내부에서** 부르는 `_select_ally_unit`(턴 복귀 때 다음 아군 자동 선택)도 들어간다. 그래서 "대기가 마지막 호출"이 아니라 "대기 정확히 1회 + 직접 경로와 순서 동일"을 검사한다.

## 7. 새로 돌린 것 / 이전 증거 재사용

### 7-1. 새로 돌린 것 (이번 M3-b 세션)

**전체 CI 로컬 재현 1회** (최종 코드 = WIP `70a0ab6`, 보고서만 다른 상태):
- 순서: `.godot` 삭제 → `--headless --editor --import`(1회 만에 exit 0, signal 11 없음) → `verify-c-track.yml` 목록 그대로 실행
- **116단계 모두 exit 0.** 내역:
  - validator 35 = 기존 34 + M3-b 1
  - Godot 테스트 76 = 기존 73 + M3-b 3
  - 씬 로드 3
  - `--editor --quit-after 2` 1
  - `git diff --check` 1
- 실행 후 `git status --short`는 비어 있었고, 단계 시간 합계는 723.4초다. 단계별 전체 표는 §9에 있다.
- M3 테스트(동등성 147 / 136 / 135, 락 59, 기본 배치 68), M2·M1-b·S3-1 테스트도 이 실행에서 다시 통과했다.

그 밖에 새로 돌린 것:
- 사전 확인 스크립트 2개(최종 원문 재실행 포함)
- 변조 프로브 7개와 대조군(§8)
- 실제 창 캡처 1세트
- 개발 중 개별 실행: 대기 동등성, 기본 배치 완주, 거절 테스트

### 7-2. 이전 증거 재사용
- **없다.**
- 원격 GitHub Actions는 push하지 않아 실행되지 않았다. Linux에서는 확인하지 않았다.

### 7-3. 환경 이슈
- 이번 세션의 fresh import 3회(본 작업 트리 2회, 프로브 worktree 1회)는 모두 1회 만에 exit 0이었다. signal 11은 재현되지 않았다.
- 사전 확인 스크립트 1(`_tmp_m3b_probe.gd`)의 Q2 구간은 부대를 선택하지 않고 이동을 요청해서 엔진이 이동을 거부했다(`accepted=false`). 그래서 **그 구간은 무효**다. 선택을 먼저 하는 스크립트 2(`_tmp_m3b_probe2.gd`)의 결과로 Q2에 답했다. 두 원문 모두 zip에 있다.

## 8. 변조 프로브 7개 (원문)

방법:
- 별도 worktree(WIP `70a0ab6`)에서 한 번에 변조 하나만 적용하고 `finally`에서 원래 바이트로 복구했다.
- 러너는 zip `evidence/run_m3b_probes.py`이고, 치환 문자열은 아래에 원문 그대로 있다.

| 지시문 §4-7 항목 | 프로브 | validator | Godot 테스트 |
|---|---|---|---|
| 대기 버튼의 입력 잠금 제거 | R1 (잠금과 안내 검사를 모두 제거) | exit 1 | exit 1 (거절 테스트) |
| 전투 종료 후 대기 허용 | R2 | exit 1 | exit 1 (거절 테스트) |
| `_on_defend_button_pressed` 호출 추가 | R3 | exit 1 | exit 1 (동등성 W1) |
| 대기 호출 두 번 보내기 | R4 | exit 1 | exit 1 (동등성 W1) |
| 3D가 `has_acted`를 직접 쓰기 | R5 | exit 1 | exit 1 (동등성 W1) |
| 대기 수락 확인 제거 | R6 | exit 1 | exit 1 (거절 테스트) |
| (추가) `_input_locked()` 호출 한 줄만 제거 | R7 | **exit 1** | **exit 0 (못 잡음)** |

- 지시문 6개(R1~R6)는 **validator와 Godot 테스트 모두 exit 1이었다.** Godot 쪽은 parse/compile 오류 없이 단언 실패로 잡혔다.
- R1·R2·R7의 validator 실패는 순서 검사의 `str.index`가 낸 `ValueError`다(AssertionError가 아님).
- **R7은 테스트로 잡히지 않는다. 숨기지 않고 적는다.**
  - 대기 버튼은 `_input_locked()`(M3 공용 잠금) 다음에 `_wait_block_reason()`(대기 안내)을 다시 검사한다. 이 안내 검사도 같은 순서(전투 종료 > 적 턴 > 연출 > 재생 큐)를 가진다.
  - 그래서 `_input_locked()` 한 줄만 빼면 두 번째 검사가 같은 조건, 같은 문구로 막아 **실행 동작이 변하지 않는다.** 거절 테스트와 기본 배치 테스트 모두 exit 0이었다.
  - 이 구조 규칙은 validator만 검사한다(`_input_locked()` → `_wait_block_reason()` → 호출 순서).
  - R1은 두 겹을 모두 제거한 경우라 테스트가 잡는다(적 턴 중 대기가 엔진에 전달됨).
  - 지시문의 "입력 잠금 제거"를 R1로 해석했다. 검수 때 R7 형태로 재현하면 테스트는 통과한다는 점을 미리 알린다.
- R2 보강: 처음 작성한 거절 테스트는 종료 후 활성 부대가 "이미 행동함"(승리)이거나 "없음"(패배)이라, 결과 잠금이 빠져도 다른 안내 조건이 막아서 R2를 잡지 못하는 구조였다.
  - 그래서 종료 후 **fixture로 미행동 아군을 활성 부대로 바꾸고** 다시 확인하는 단계를 추가했다(변조 프로브를 돌리기 전에 추가했다).
  - R2는 이 단계에서 잡혔다.
- 대조군(변조 없음)은 모두 exit 0이었다.

### R1_wait_input_lock_removed

변조 파일: `scripts/battle3d/battle3d_engine_play.gd`

치환 1 — 원래:
```gdscript
func request_wait() -> void:
	if not ready_for_input or _input_locked(): return
	var reason := _wait_block_reason()
	if not reason.is_empty():
		_reject(reason)
		return
```
변조:
```gdscript
func request_wait() -> void:
	if not ready_for_input: return
```

`validate_battle3d_m3b_wait.py` → exit=1, 2.07초
```text
ValueError: substring not found
```
`test_battle3d_wait_rejections.gd` → exit=1, 16.86초, parse_error=False
```text
[M3B_WAIT_REJECTIONS] checks=71 failures=["double press sends one wait", "second press refused: 대기 · yi_sunsin / 이후 적 자동 행동", "during engine enemy_turn no engine write call [\"_end_ally_turn_by_wait\"]", "during engine enemy_turn one visible rejection", "during engine enemy_turn reason: 적 자동 행동 중 · 입력 잠금 / 결과는 엔진 상태로 동기화", "during playback queue no engine write call [\"_end_ally_turn_by_wait\"]", "during playback queue one visible rejection", "during playback queue reason: 대기 · yi_sunsin / 이후 적 자동 행동", "acted no engine write call [\"_end_ally_turn_by_wait\"]", "acted one visible rejection", "acted reason: 대기 · yi_sunsin / 이후 적 자동 행동", "acted writes unchanged", "no_selection one visible rejection", "no_selection reason: 아군 선택 → 이동·방향 확정 또는 [공격] → 적 선택", "facing_select no engine write call [\"_end_ally_turn_by_wait\"]", "facing_select reason: 거절 / 행동 불가 · 엔진이 대기를 수락하지 않았습니다", "facing_select writes unchanged", "M13_enemy_wipe_victory after end 0 no engine write call [\"_end_ally_turn_by_wait\"]", "M13_enemy_wipe_victory after end 0 one visible rejection", "M13_enemy_wipe_victory after end 0 reason: 대기 · yi_sunsin / 이후 적 자동 행동", "M13_enemy_wipe_victory after end, clicking another ally 0 no engine write call [\"_end_ally_turn_by_wait\"]", "M13_enemy_wipe_victory after end, clicking another ally 0 one visible rejection", "M13_enemy_wipe_victory after end, clicking another ally 0 reason: 대기 · yi_sunsin / 이후 적 자동 행동", "M13_enemy_wipe_victory after end 1 no engine write call [\"_end_ally_turn_by_wait\"]", "M13_enemy_wipe_victory after end 1 one visible rejection", "M13_enemy_wipe_victory after end 1 reason: 대기 · yi_sunsin / 이후 적 자동 행동", "M13_enemy_wipe_victory after end, clicking another ally 1 no engine write call [\"_end_ally_turn_by_wait\"]", "M13_enemy_wipe_victory after end, clicking another ally 1 one visible rejection", "M13_enemy_wipe_victory after end, clicking another ally 1 reason: 대기 · yi_sunsin / 이후 적 자동 행동", "M13_enemy_wipe_victory after end with an unacted active ally no engine write call [\"_end_ally_turn_by_wait\"]", "M13_enemy_wipe_victory after end with an unacted active ally reason: 거절 / 행동 불가 · 엔진이 대기를 수락하지 않았습니다", "M13_enemy_wipe_victory no wait/defend/world-map call", "M12_ally_wipe_defeat after end 0 one visible rejection", "M12_ally_wipe_defeat after end 0 reason: 전투 종료 · 패배 / 모든 입력 잠금", "M12_ally_wipe_defeat after end 1 one visible rejection", "M12_ally_wipe_defeat after end 1 reason: 전투 종료 · 패배 / 모든 입력 잠금", "M12_ally_wipe_defeat after end with an unacted active ally no engine write call [\"_end_ally_turn_by_wait\"]", "M12_ally_wipe_defeat after end with an unacted active ally reason: 거절 / 행동 불가 · 엔진이 대기를 수락하지 않았습니다", "M12_ally_wipe_defeat no wait/defend/world-map call"]
[M3] FAIL double press sends one wait
[M3] FAIL second press refused: 대기 · yi_sunsin / 이후 적 자동 행동
[M3] FAIL during engine enemy_turn no engine write call ["_end_ally_turn_by_wait"]
[M3] FAIL during engine enemy_turn one visible rejection
[M3] FAIL during engine enemy_turn reason: 적 자동 행동 중 · 입력 잠금 / 결과는 엔진 상태로 동기화
[M3] FAIL during playback queue no engine write call ["_end_ally_turn_by_wait"]
[M3] FAIL during playback queue one visible rejection
[M3] FAIL during playback queue reason: 대기 · yi_sunsin / 이후 적 자동 행동
[M3] FAIL acted no engine write call ["_end_ally_turn_by_wait"]
[M3] FAIL acted one visible rejection
[M3] FAIL acted reason: 대기 · yi_sunsin / 이후 적 자동 행동
```

### R2_wait_allowed_after_battle_end

변조 파일: `scripts/battle3d/battle3d_engine_play.gd`

치환 1 — 원래:
```gdscript
func request_wait() -> void:
	if not ready_for_input or _input_locked(): return
```
변조:
```gdscript
func request_wait() -> void:
	if not ready_for_input or (battle_result.is_empty() and _input_locked()): return
```

치환 2 — 원래:
```gdscript
	if not battle_result.is_empty(): return "전투 종료 · %s / 모든 입력 잠금" % RESULT_TEXT.get(battle_result,battle_result)
```
변조:
```gdscript
(삭제)
```

`validate_battle3d_m3b_wait.py` → exit=1, 1.55초
```text
ValueError: substring not found
```
`test_battle3d_wait_rejections.gd` → exit=1, 16.38초, parse_error=False
```text
[M3B_WAIT_REJECTIONS] checks=71 failures=["M13_enemy_wipe_victory after end 0 reason: 거절 / 대기 불가 · 이미 행동한 부대입니다", "M13_enemy_wipe_victory after end, clicking another ally 0 reason: 거절 / 대기 불가 · 이미 행동한 부대입니다", "M13_enemy_wipe_victory after end 1 reason: 거절 / 대기 불가 · 이미 행동한 부대입니다", "M13_enemy_wipe_victory after end, clicking another ally 1 reason: 거절 / 대기 불가 · 이미 행동한 부대입니다", "M13_enemy_wipe_victory guidance reports the end first", "M13_enemy_wipe_victory after end with an unacted active ally wait button disabled", "M13_enemy_wipe_victory after end with an unacted active ally no engine write call [\"_end_ally_turn_by_wait\"]", "M13_enemy_wipe_victory after end with an unacted active ally reason: 거절 / 행동 불가 · 엔진이 대기를 수락하지 않았습니다", "M13_enemy_wipe_victory no wait/defend/world-map call", "M12_ally_wipe_defeat after end 0 reason: 거절 / 적 턴 중 · 적 행동이 끝날 때까지 기다리세요", "M12_ally_wipe_defeat after end 1 reason: 거절 / 적 턴 중 · 적 행동이 끝날 때까지 기다리세요", "M12_ally_wipe_defeat guidance reports the end first", "M12_ally_wipe_defeat after end with an unacted active ally reason: 거절 / 적 턴 중 · 적 행동이 끝날 때까지 기다리세요"]
[M3] FAIL M13_enemy_wipe_victory after end 0 reason: 거절 / 대기 불가 · 이미 행동한 부대입니다
[M3] FAIL M13_enemy_wipe_victory after end, clicking another ally 0 reason: 거절 / 대기 불가 · 이미 행동한 부대입니다
[M3] FAIL M13_enemy_wipe_victory after end 1 reason: 거절 / 대기 불가 · 이미 행동한 부대입니다
[M3] FAIL M13_enemy_wipe_victory after end, clicking another ally 1 reason: 거절 / 대기 불가 · 이미 행동한 부대입니다
[M3] FAIL M13_enemy_wipe_victory guidance reports the end first
[M3] FAIL M13_enemy_wipe_victory after end with an unacted active ally wait button disabled
[M3] FAIL M13_enemy_wipe_victory after end with an unacted active ally no engine write call ["_end_ally_turn_by_wait"]
[M3] FAIL M13_enemy_wipe_victory after end with an unacted active ally reason: 거절 / 행동 불가 · 엔진이 대기를 수락하지 않았습니다
[M3] FAIL M13_enemy_wipe_victory no wait/defend/world-map call
[M3] FAIL M12_ally_wipe_defeat after end 0 reason: 거절 / 적 턴 중 · 적 행동이 끝날 때까지 기다리세요
[M3] FAIL M12_ally_wipe_defeat after end 1 reason: 거절 / 적 턴 중 · 적 행동이 끝날 때까지 기다리세요
```

### R3_defend_call_added

변조 파일: `scripts/battle3d/battle3d_engine_play.gd`

치환 1 — 원래:
```gdscript
	_append_combat_line("대기 · " + waiting_id)
```
변조:
```gdscript
	engine.call("_on_defend_button_pressed")
	_append_combat_line("대기 · " + waiting_id)
```

`validate_battle3d_m3b_wait.py` → exit=1, 1.52초
```text
AssertionError: exact seven commands and three read calls: {'_select_post_move_facing', '_select_ally_unit', 'try_basic_attack', '_handle_right_click_cancel', '_end_ally_turn_by_wait', '_get_alive_enemy_units', 'is_unit_in_attack_range', '_is_unit_state_available_for_battle_slot', '_on_defend_button_pressed', '_try_direct_move_to_cell', '_try_attack_enemy_target_from_attack_select'}
```
`test_battle3d_wait_equivalence.gd --case=W1_wait_unmoved_enemy_attacks` → exit=1, 5.44초, parse_error=False
```text
[M3B_WAIT_EQUIVALENCE] checks=29 failures=["W1_wait_unmoved_enemy_attacks same seven-command write sequence [\"_select_ally_unit\", \"_select_ally_unit\", \"_end_ally_turn_by_wait\", \"_on_defend_button_pressed\", \"_select_ally_unit\"]", "W1_wait_unmoved_enemy_attacks write within the seven commands _on_defend_button_pressed", "W1_wait_unmoved_enemy_attacks defend never called", "W1_wait_unmoved_enemy_attacks same engine write sequence [\"_select_ally_unit\", \"_select_ally_unit\", \"_on_defend_button_pressed\", \"_select_ally_unit\"]", "W1_wait_unmoved_enemy_attacks write within the six commands _on_defend_button_pressed"]
[M3] FAIL W1_wait_unmoved_enemy_attacks same seven-command write sequence ["_select_ally_unit", "_select_ally_unit", "_end_ally_turn_by_wait", "_on_defend_button_pressed", "_select_ally_unit"]
[M3] FAIL W1_wait_unmoved_enemy_attacks write within the seven commands _on_defend_button_pressed
[M3] FAIL W1_wait_unmoved_enemy_attacks defend never called
[M3] FAIL W1_wait_unmoved_enemy_attacks same engine write sequence ["_select_ally_unit", "_select_ally_unit", "_on_defend_button_pressed", "_select_ally_unit"]
[M3] FAIL W1_wait_unmoved_enemy_attacks write within the six commands _on_defend_button_pressed
```

### R4_wait_sent_twice

변조 파일: `scripts/battle3d/battle3d_engine_play.gd`

치환 1 — 원래:
```gdscript
	engine.call("_end_ally_turn_by_wait")
```
변조:
```gdscript
	engine.call("_end_ally_turn_by_wait")
	engine.call("_end_ally_turn_by_wait")
```

`validate_battle3d_m3b_wait.py` → exit=1, 1.56초
```text
AssertionError: one wait call site
```
`test_battle3d_wait_equivalence.gd --case=W1_wait_unmoved_enemy_attacks` → exit=1, 5.54초, parse_error=False
```text
[M3B_WAIT_EQUIVALENCE] checks=28 failures=["W1_wait_unmoved_enemy_attacks same seven-command write sequence [\"_select_ally_unit\", \"_select_ally_unit\", \"_end_ally_turn_by_wait\", \"_end_ally_turn_by_wait\", \"_select_ally_unit\"]", "W1_wait_unmoved_enemy_attacks exactly one wait call (engine-internal reselects are recorded too)"]
[M3] FAIL W1_wait_unmoved_enemy_attacks same seven-command write sequence ["_select_ally_unit", "_select_ally_unit", "_end_ally_turn_by_wait", "_end_ally_turn_by_wait", "_select_ally_unit"]
[M3] FAIL W1_wait_unmoved_enemy_attacks exactly one wait call (engine-internal reselects are recorded too)
```

### R5_3d_writes_has_acted

변조 파일: `scripts/battle3d/battle3d_engine_play.gd`

치환 1 — 원래:
```gdscript
	engine.call("_end_ally_turn_by_wait")
```
변조:
```gdscript
	engine.get("active_unit_state").has_acted = true
```

`validate_battle3d_m3b_wait.py` → exit=1, 1.55초
```text
AssertionError: exact seven commands and three read calls: {'_get_alive_enemy_units', '_select_post_move_facing', '_select_ally_unit', 'is_unit_in_attack_range', '_handle_right_click_cancel', '_try_direct_move_to_cell', '_try_attack_enemy_target_from_attack_select', '_is_unit_state_available_for_battle_slot', 'try_basic_attack'}
```
`test_battle3d_wait_equivalence.gd --case=W1_wait_unmoved_enemy_attacks` → exit=1, 4.76초, parse_error=False
```text
[M3B_WAIT_EQUIVALENCE] checks=21 failures=["W1_wait_unmoved_enemy_attacks same seven-command write sequence [\"_select_ally_unit\", \"_select_ally_unit\"]", "W1_wait_unmoved_enemy_attacks exactly one wait call (engine-internal reselects are recorded too)", "W1_wait_unmoved_enemy_attacks 40-field units equal [\"units[0].current_hp\", \"units[0].current_troops\", \"units[0].has_acted\"]", "W1_wait_unmoved_enemy_attacks controller equal [\"units.acted_ally_ids.ally_reinforce_01_demo\", \"units.acted_ally_ids.ally_reinforce_02_test_unit\", \"units.acted_ally_ids.gwon_yul\", \"units.acted_ally_ids.jeong_dojeon\", \"units.acted_enemy_ids.enemy_reinforce_01_demo\", \"units.acted_enemy_ids.enemy_reinforce_02_test_unit\", \"units.acted_enemy_ids.xiahou_dun\", \"units.acted_enemy_ids.zhang_fei\", \"units.ally_momentum\", \"units.battle_round\", \"units.enemy_momentum\"]", "W1_wait_unmoved_enemy_attacks enemy_action_event_log equal", "W1_wait_unmoved_enemy_attacks same engine write sequence [\"_select_ally_unit\", \"_select_ally_unit\"]"]
[M3] FAIL W1_wait_unmoved_enemy_attacks same seven-command write sequence ["_select_ally_unit", "_select_ally_unit"]
[M3] FAIL W1_wait_unmoved_enemy_attacks exactly one wait call (engine-internal reselects are recorded too)
[M3] FAIL W1_wait_unmoved_enemy_attacks 40-field units equal ["units[0].current_hp", "units[0].current_troops", "units[0].has_acted"]
[M3] FAIL W1_wait_unmoved_enemy_attacks controller equal ["units.acted_ally_ids.ally_reinforce_01_demo", "units.acted_ally_ids.ally_reinforce_02_test_unit", "units.acted_ally_ids.gwon_yul", "units.acted_ally_ids.jeong_dojeon", "units.acted_enemy_ids.enemy_reinforce_01_demo", "units.acted_enemy_ids.enemy_reinforce_02_test_unit", "units.acted_enemy_ids.xiahou_dun", "units.acted_enemy_ids.zhang_fei", "units.ally_momentum", "units.battle_round", "units.enemy_momentum"]
[M3] FAIL W1_wait_unmoved_enemy_attacks enemy_action_event_log equal
[M3] FAIL W1_wait_unmoved_enemy_attacks same engine write sequence ["_select_ally_unit", "_select_ally_unit"]
```

### R6_acceptance_check_removed

변조 파일: `scripts/battle3d/battle3d_engine_play.gd`

치환 1 — 원래:
```gdscript
	if not accepted:
```
변조:
```gdscript
	if false:
```

`validate_battle3d_m3b_wait.py` → exit=1, 1.56초
```text
AssertionError: acceptance read back before reporting success
```
`test_battle3d_wait_rejections.gd` → exit=1, 16.48초, parse_error=False
```text
[M3B_WAIT_REJECTIONS] checks=71 failures=["engine refusal shown as refusal: 대기 · yi_sunsin / 이후 적 자동 행동", "refused wait not logged as done"]
[M3] FAIL engine refusal shown as refusal: 대기 · yi_sunsin / 이후 적 자동 행동
[M3] FAIL refused wait not logged as done
```

### R7_extra_only_input_locked_call_removed

변조 파일: `scripts/battle3d/battle3d_engine_play.gd`

치환 1 — 원래:
```gdscript
func request_wait() -> void:
	if not ready_for_input or _input_locked(): return
```
변조:
```gdscript
func request_wait() -> void:
	if not ready_for_input: return
```

`validate_battle3d_m3b_wait.py` → exit=1, 1.56초
```text
ValueError: substring not found
```
`test_battle3d_wait_rejections.gd` → exit=0, 16.38초, parse_error=False
```text
[M3B_WAIT_REJECTIONS] checks=71 failures=[]
```
`test_battle3d_wait_default_round.gd` → exit=0, 14.17초, parse_error=False
```text
[M3B_DEFAULT_ROUND] checks=71 failures=[]
```

### 대조군 (변조 없음, 같은 worktree)

`test_battle3d_wait_equivalence.gd --case=W1_wait_unmoved_enemy_attacks` → exit=0
```text
[M3B_WAIT_EQUIVALENCE] checks=27 failures=[]
```
`test_battle3d_wait_rejections.gd` → exit=0
```text
[M3B_WAIT_REJECTIONS] checks=71 failures=[]
```
`test_battle3d_wait_default_round.gd` → exit=0
```text
[M3B_DEFAULT_ROUND] checks=71 failures=[]
```
`validate_battle3d_m3b_wait.py` → exit=0
```text
M3B_WAIT validator PASS: base=168b887 scope=HEAD; 13 paths; engine diff 0; seven commands (+_end_ally_turn_by_wait); 8 read properties unchanged; no defend/world-map/result calls
```

## 9. 전체 CI 로컬 재현 단계별 결과 (새로 돌린 것, 116단계)

| # | 단계 | exit | 초 | checks |
|---:|---|---:|---:|---:|
| 1 | `tools/validate_worldmap_main_integrity.py` | 0 | 0.13 | - |
| 2 | `tools/validate_worldmap_diplomacy_controller_extraction.py` | 0 | 1.23 | - |
| 3 | `tools/validate_worldmap_diplomacy_routing.py` | 0 | 3.2 | - |
| 4 | `tools/validate_worldmap_diplomacy_service_separation.py` | 0 | 0.59 | - |
| 5 | `tools/validate_worldmap_trade_routing.py` | 0 | 0.52 | - |
| 6 | `tools/validate_worldmap_trade_controller_extraction.py` | 0 | 0.52 | - |
| 7 | `tools/validate_worldmap_trade_phase2_extraction.py` | 0 | 0.21 | - |
| 8 | `tools/validate_worldmap_spy_routing.py` | 0 | 0.73 | - |
| 9 | `tools/validate_worldmap_spy_controller_extraction.py` | 0 | 0.73 | - |
| 10 | `tools/validate_worldmap_battle_settlement_applier_extraction.py` | 0 | 0.23 | - |
| 11 | `tools/validate_worldmap_t03_strategic_battle_transaction_extraction.py` | 0 | 0.24 | - |
| 12 | `tools/validate_worldmap_t03_battle_presentation_extraction.py` | 0 | 0.68 | - |
| 13 | `tools/validate_worldmap_player_attack_deployment_service_extraction.py` | 0 | 0.83 | - |
| 14 | `tools/validate_worldmap_wounded_recovery_service_extraction.py` | 0 | 0.23 | - |
| 15 | `tools/validate_worldmap_to_battle_input_lifecycle.py` | 0 | 0.11 | - |
| 16 | `tools/validate_b0b_battle_production_skeleton.py` | 0 | 0.12 | - |
| 17 | `tools/validate_b0c_battle_iso_promotion.py` | 0 | 0.12 | - |
| 18 | `tools/validate_b1b_battle_movement_query_service.py` | 0 | 0.27 | - |
| 19 | `tools/validate_b1c_battle_combat_query_service.py` | 0 | 0.22 | - |
| 20 | `tools/validate_b1d_battle_damage_formula_service.py` | 0 | 0.21 | - |
| 21 | `tools/validate_b1e_battle_action_lock_state_service.py` | 0 | 0.33 | - |
| 22 | `tools/validate_b1f_battle_enemy_ai_reservation_state_service.py` | 0 | 0.25 | - |
| 23 | `tools/validate_b1g_battle_unique_skill_cooldown_state_service.py` | 0 | 0.23 | - |
| 24 | `tools/validate_battle_s1_1_observation_baseline.py` | 0 | 1.01 | - |
| 25 | `tools/validate_battle_s2_1_attack_baseline.py` | 0 | 0.67 | - |
| 26 | `tools/validate_battle_s2_2_attack_state_service.py` | 0 | 2.85 | - |
| 27 | `tools/validate_battle_enemy_events_s3_1.py` | 0 | 2.86 | - |
| 28 | `tools/validate_battle_s1_2_ally_move_state_service.py` | 0 | 1.73 | - |
| 29 | `tools/validate_battle3d_m1b_engine_move.py` | 0 | 0.74 | - |
| 30 | `tools/validate_battle3d_m2_engine_attack.py` | 0 | 3.75 | - |
| 31 | `tools/validate_battle3d_m3_enemy_turn.py` | 0 | 5.44 | - |
| 32 | `tools/validate_battle3d_m3b_wait.py` | 0 | 1.66 | - |
| 33 | `tools/validate_battle3d_contract.py` | 0 | 0.13 | - |
| 34 | `tools/validate_alternating_battle_action_order.py` | 0 | 0.14 | - |
| 35 | `tools/validate_single_side_exhaustion_turn_order.py` | 0 | 0.13 | - |
| 36 | `tests/scripts/test_worldmap_city_administration_service_extraction.gd` | 0 | 0.45 | - |
| 37 | `tests/scripts/test_worldmap_city_resource_service_extraction.gd` | 0 | 0.45 | - |
| 38 | `tests/scripts/test_worldmap_city_detail_presentation_extraction.gd` | 0 | 0.45 | - |
| 39 | `tests/scripts/test_worldmap_camera_controller_extraction.gd` | 0 | 0.46 | - |
| 40 | `tests/scripts/test_worldmap_hud_controller_extraction.gd` | 0 | 0.55 | - |
| 41 | `tests/scripts/test_worldmap_shared_ui_controller_extraction.gd` | 0 | 0.45 | - |
| 42 | `tests/scripts/test_world_calendar_service_extraction.gd` | 0 | 0.45 | - |
| 43 | `tests/scripts/test_world_turn_economy_service_extraction.gd` | 0 | 0.45 | - |
| 44 | `tests/scripts/test_world_turn_state_service_extraction.gd` | 0 | 0.45 | - |
| 45 | `tests/scripts/test_worldmap_turn_controller_extraction.gd` | 0 | 0.45 | - |
| 46 | `tests/scripts/test_battle_movement_query_service.gd` | 0 | 3.68 | - |
| 47 | `tests/scripts/test_battle_combat_query_service.gd` | 0 | 3.74 | - |
| 48 | `tests/scripts/test_battle_damage_formula_service.gd` | 0 | 3.61 | - |
| 49 | `tests/scripts/test_battle_action_lock_state_service.gd` | 0 | 3.74 | - |
| 50 | `tests/scripts/test_battle_enemy_ai_reservation_state_service.gd` | 0 | 3.62 | - |
| 51 | `tests/scripts/test_battle_unique_skill_cooldown_state_service.gd` | 0 | 3.61 | - |
| 52 | `tests/scripts/test_battle_event_log_service.gd` | 0 | 0.45 | - |
| 53 | `tests/scripts/test_battle_state_fingerprint_service.gd` | 0 | 0.55 | - |
| 54 | `tests/scripts/test_battle_attack_oracle_shard_1.gd` | 0 | 40.73 | 128 |
| 55 | `tests/scripts/test_battle_attack_oracle_shard_2.gd` | 0 | 32.35 | 106 |
| 56 | `tests/scripts/test_battle_attack_state_service.gd` | 0 | 0.54 | 70 |
| 57 | `tests/scripts/test_battle_attack_event_parity.gd` | 0 | 36.16 | 213 |
| 58 | `tests/scripts/test_battle_enemy_event_log_service.gd` | 0 | 0.45 | 37 |
| 59 | `tests/scripts/test_battle_enemy_turn_oracle_shard_1.gd` | 0 | 35.19 | 64 |
| 60 | `tests/scripts/test_battle_enemy_turn_oracle_shard_2.gd` | 0 | 27.84 | 64 |
| 61 | `tests/scripts/test_battle_enemy_turn_event_semantics.gd` | 0 | 31.29 | 525 |
| 62 | `tests/scripts/test_battle_move_oracle_baseline.gd` | 0 | 20.92 | - |
| 63 | `tests/scripts/test_battle_ally_move_state_service.gd` | 0 | 0.57 | - |
| 64 | `tests/scripts/test_battle_ally_move_event_parity.gd` | 0 | 7.79 | - |
| 65 | `tests/scripts/test_battle3d_engine_move_integration.gd` | 0 | 7.67 | 144 |
| 66 | `tests/scripts/test_battle3d_engine_attack_shard_1.gd` | 0 | 10.72 | 1122 |
| 67 | `tests/scripts/test_battle3d_engine_attack_shard_2.gd` | 0 | 11.43 | 1123 |
| 68 | `tests/scripts/test_battle3d_engine_attack_shard_3.gd` | 0 | 11.0 | 1115 |
| 69 | `tests/scripts/test_battle3d_engine_attack_rejections.gd` | 0 | 13.95 | 110 |
| 70 | `tests/scripts/test_battle3d_engine_attack_sync.gd` | 0 | 11.7 | 364 |
| 71 | `tests/scripts/test_battle3d_enemy_turn_equivalence_shard_1.gd` | 0 | 50.3 | 147 |
| 72 | `tests/scripts/test_battle3d_enemy_turn_equivalence_shard_2.gd` | 0 | 41.57 | 136 |
| 73 | `tests/scripts/test_battle3d_enemy_turn_equivalence_shard_3.gd` | 0 | 41.39 | 135 |
| 74 | `tests/scripts/test_battle3d_enemy_turn_locks.gd` | 0 | 14.55 | 59 |
| 75 | `tests/scripts/test_battle3d_enemy_turn_default_layout.gd` | 0 | 4.09 | 68 |
| 76 | `tests/scripts/test_battle3d_wait_equivalence.gd` | 0 | 27.51 | 178 |
| 77 | `tests/scripts/test_battle3d_wait_default_round.gd` | 0 | 14.04 | 71 |
| 78 | `tests/scripts/test_battle3d_wait_rejections.gd` | 0 | 16.61 | 71 |
| 79 | `tests/scripts/test_battle3d_movement_parity.gd` | 0 | 1.66 | - |
| 80 | `tests/scripts/test_battle3d_modes.gd` | 0 | 0.92 | - |
| 81 | `tests/scripts/test_battle3d_oblique_click.gd` | 0 | 6.56 | - |
| 82 | `tests/scripts/alternating_battle_action_order_test.gd` | 0 | 0.45 | - |
| 83 | `tests/scripts/test_single_side_exhaustion_turn_order.gd` | 0 | 3.05 | - |
| 84 | `tests/scripts/test_worldmap_domestic_tech_catalog_extraction.gd` | 0 | 5.9 | - |
| 85 | `tests/scripts/test_worldmap_domestic_tech_research_rules_extraction.gd` | 0 | 0.56 | - |
| 86 | `tests/scripts/test_worldmap_domestic_tech_research_service_extraction.gd` | 0 | 0.82 | - |
| 87 | `tests/scripts/test_worldmap_domestic_tech_effect_provider_extraction.gd` | 0 | 0.54 | - |
| 88 | `tests/scripts/test_worldmap_domestic_tech_tree_presentation_extraction.gd` | 0 | 1.84 | - |
| 89 | `tests/scripts/test_worldmap_domestic_tech_completion_presentation_extraction.gd` | 0 | 0.87 | - |
| 90 | `tests/scripts/test_worldmap_military_controller_extraction.gd` | 0 | 4.79 | - |
| 91 | `tests/scripts/test_worldmap_enemy_warfare_service_extraction.gd` | 0 | 4.67 | - |
| 92 | `tests/scripts/test_worldmap_battle_context_service_extraction.gd` | 0 | 4.93 | - |
| 93 | `tests/scripts/test_worldmap_battle_result_service_extraction.gd` | 0 | 4.87 | - |
| 94 | `tests/scripts/test_worldmap_battle_settlement_applier_extraction.gd` | 0 | 0.57 | - |
| 95 | `tests/scripts/test_worldmap_t03_strategic_battle_transaction_extraction.gd` | 0 | 0.54 | - |
| 96 | `tests/scripts/test_worldmap_t03_battle_presentation_extraction.gd` | 0 | 0.54 | - |
| 97 | `tests/scripts/test_worldmap_player_attack_deployment_service_extraction.gd` | 0 | 0.44 | - |
| 98 | `tests/scripts/test_worldmap_troop_rebalance_service_extraction.gd` | 0 | 0.45 | - |
| 99 | `tests/scripts/test_worldmap_wounded_recovery_service_extraction.gd` | 0 | 0.44 | - |
| 100 | `tests/scripts/test_worldmap_diplomacy_routing.gd` | 0 | 19.05 | - |
| 101 | `tests/scripts/test_worldmap_diplomacy_controller_extraction.gd` | 0 | 0.91 | - |
| 102 | `tests/scripts/test_worldmap_diplomacy_validation_extraction.gd` | 0 | 4.73 | - |
| 103 | `tests/scripts/test_worldmap_diplomacy_mutation_extraction.gd` | 0 | 4.73 | - |
| 104 | `tests/scripts/test_worldmap_diplomacy_state_extraction.gd` | 0 | 4.74 | - |
| 105 | `tests/scripts/test_worldmap_diplomacy_alliance_extraction.gd` | 0 | 4.93 | - |
| 106 | `tests/scripts/test_worldmap_trade_routing.gd` | 0 | 16.56 | - |
| 107 | `tests/scripts/test_worldmap_trade_controller_extraction.gd` | 0 | 4.66 | - |
| 108 | `tests/scripts/test_worldmap_trade_automation_extraction.gd` | 0 | 4.63 | - |
| 109 | `tests/scripts/test_worldmap_internal_trade_transfer_extraction.gd` | 0 | 4.75 | - |
| 110 | `tests/scripts/test_worldmap_spy_routing.gd` | 0 | 19.51 | - |
| 111 | `tests/scripts/test_worldmap_spy_controller_extraction.gd` | 0 | 5.21 | - |
| 112 | `CI_WORLDMAP_LOAD` | 0 | 2.88 | - |
| 113 | `CI_BATTLE_MAIN_LOAD` | 0 | 2.11 | - |
| 114 | `CI_IMJIN_ISO_LOAD` | 0 | 2.67 | - |
| 115 | `editor_quit_after_2` | 0 | 4.87 | - |
| 116 | `git diff --check` | 0 | 0 | - |


## 10. 알려진 한계·미커버 영역

- **R7(공용 잠금 한 줄 제거)은 테스트로 잡히지 않는다**(§8). 동작은 변하지 않으며 validator만 잡는다.
- **3D 재생 지연에 따른 표시 차이**(M3에서 보고한 것과 같음): 엔진은 다음 아군을 이미 골랐는데 3D는 적 재생 중일 수 있다. 입력은 재생 큐가 빌 때까지 잠겨 있다. M6 UI 정리 항목이다.
- **방어 미연결(M4)**: 기본 배치 완주는 대기로만 진행했다. 아군이 적과 붙는 여러 라운드 흐름(공격·방어 혼합)은 이번 범위에서 다루지 않았다.
- **기본 배치는 라운드 2 시작까지만 확인했다.** 이후 라운드(증원·쿨다운·적 특기 R2+)의 3D 재생은 M3 케이스(적 특기 M14 등) 수준까지만 확인했다.
- **엔진의 대기 거부 조건 중 3D가 재현하는 것은 "미행동"뿐이다.** 혼란 등은 3D가 계산하지 않는다. 그래서 대기 버튼이 활성인데 엔진이 거부할 수 있고(혼란 아군), 그때는 호출 1회 뒤 상태를 읽어 거절로 표시한다(테스트로 확인).
- **"선택 없음" 거절은 fixture로만 확인했다**(엔진 `active_unit_state = null`). 기본 흐름에서는 엔진이 항상 다음 아군을 고르므로 패배 후가 아니면 나오지 않는다.
- **사람이 직접 조작한 캡처가 없다**(뷰포트 입력 주입 캡처만 있음).
- **원격 CI와 Linux는 확인하지 않았다.**

## 11. 커밋

- 작업 중 WIP 커밋 `5dfef02`, `70a0ab6`로 보존했고, 마지막에 M3 커밋 `168b887` 위 **커밋 1개로 squash**했다. 메시지는 `feat(battle3d): connect the engine wait command (M3-b)`.
- 최종 해시는 zip의 `commit_hashes.txt`에 적는다. push하지 않았다.
