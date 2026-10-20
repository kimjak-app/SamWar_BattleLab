# M3 3D 적 턴 재생 결과

- 작업: M3 (3D 적 턴 재생). 기준 지시문은 `M3_ENEMY_TURN_CODEX_20261020.md`(§6-1~6-3 포함), 설계안은 `EASTWAR_3D_BATTLE_MASTER_DESIGN_v1_2` §11.2의 M3 행.
- 기준(BASE): S3-1 커밋 `cbc1e43abfcc59aa40883883b5dcc4182ecf21e1`(클코치 머지본 `1404c6c`/`102713f`와 내용 동일).
- 브랜치: `feature/battle3d-m3-enemy-turn-20261020`. 로컬 커밋만 했고 **push·merge는 하지 않았다**.
- 구현: Claude Code (클코). **합격 판정은 하지 않는다.** 검수는 클코치가 독립적으로 한다.
- 엔진 파일 diff: **0줄**(validator가 검사).

## ⚠ 먼저 보고할 의존성 (설계안 §11.2 주석에 해당)

**기본 18×10 배치에서는, 정해진 쓰기 호출 6개만으로 "이동→공격→적 턴→다음 라운드"를 진행할 수 없다.** 그래서 §2-3과 §11.2 M3 행의 "기본 배치에서 한 라운드 완주" 조건은 **이번 범위에서 충족되지 않았다.**

근거 (자동 테스트 `test_battle3d_enemy_turn_default_layout`, 68 checks, 실제 3D 입력):
- 6개 명령 중 아군 행동을 끝내는 것은 공격 하나뿐이다.
- 이동 후 방향을 확정해도(`_select_post_move_facing`) `has_acted`는 false이고 phase는 `ally_turn`으로 돌아간다.
- 기본 배치에 보이는 아군 3개(yi_sunsin, jeong_dojeon, gwon_yul)는 이동 가능한 모든 칸에서 모든 적까지의 거리가 사거리보다 크다. yi_sunsin(궁, 사거리 3)은 이동 가능한 칸 17개 중 가장 가까운 칸 (6,8)에서도 적까지 거리가 11이다.
- 첫 아군이 이동하면 엔진이 **다른 아군의 선택을 거부**한다(행동 순서 잠금). jeong_dojeon과 gwon_yul은 `selectable=false`였다.
- 결과: 적 로그는 비어 있고 라운드는 1에 머문다. 적 턴이 시작되지 않는다.

엔진에는 행동을 끝내는 기존 경로(`_on_defend_button_pressed`, `_end_ally_turn_by_wait`)가 있다. 하지만 이를 쓰면 7번째 쓰기 호출이 된다. 지시문 §2-1(6개 고정), §6-3-6(강제 턴 종료 신설 금지), 설계안 §3.2(늘리려면 지시서 명시와 검수 승인 필요)에 따라 **추가하지 않았다.** 설계안 §11.2는 방어를 M4 범위로 두고 있다. 방어(또는 대기) 연결을 M3로 당길지는 김작·클코치가 결정할 사항이다.

이번에 대신 한 것:
- 기본 배치 수동 진입과 `--check`(시작 상태 == golden)
- 기본 배치에서 진행이 막히는 것을 증명하는 테스트
- 한 라운드 완주는 **기본 배치의 부대·영웅 구성은 그대로 두고 위치와 행동 잠금만 fixture로 바꾼 근접 배치**에서 실제 3D 입력으로 증명했다(엔진 동등성 18케이스와 실제 창 캡처).

## 1. 기능 상태

| 기능 | 상태 | 근거 |
|---|---|---|
| 아군 공격 후 엔진이 자동으로 진행하는 적 슬롯을 3D가 재생 | 동작 (자동 테스트 + 실제 창 캡처) | 동등성 18케이스, 캡처 03~06 |
| `enemy_moved` 경로 재생(M1-b와 같은 `playback`·`presentation_speed`) | 동작 | 3D 뷰가 `path`의 각 셀을 순서대로 지나고 최종 셀 == 엔진 `grid_cell` (이동 케이스 7개) |
| `enemy_attack_resolved` 피격 표시(`damage_applied`, 각도) | 동작 | 표시 숫자 == `damage_applied`. 즉사 M7은 raw 8 / applied 5에서 5 표시 |
| `enemy_waited` 사유 문구(대기·혼란·경로 없음·경로 막힘·대상 없음) | 동작 | M8, M9, 그리고 seam M15·M16·M17 |
| `enemy_skill_used` 문구 + 상태 diff 폴백 요약 | 동작 | M14 (관우 특기, 병력 300→251이 요약에 표시됨) |
| `round_started` "라운드 N" | 동작 | 라운드 완료 케이스 15개 |
| `battle_ended` 승리/패배 오버레이 + 전체 입력 잠금 | 동작 | M12 패배(phase=`enemy_turn` 유지), M13 승리(phase=`ally_turn`인데도 잠금) |
| 적 슬롯 연속 진행(아군 전원 행동 후) | 동작 | M10: 슬롯 2개 연속 → 라운드 2 |
| 이벤트 기반 적 요약(이벤트가 없으면 상태 diff로 폴백) | 동작 | 슬롯마다 요약 1개. 대기·특기 슬롯은 폴백 |
| 3D 입력 결과 == 엔진 직접 호출 결과 | 동작 | 18케이스: 유닛 40필드, 컨트롤러 12값, 로그 3개, 쓰기 호출 순서가 모두 일치 |
| 기본 배치에서 한 라운드 완주 | **미충족** | 위 의존성 보고 참고 |

## 2. UI 상태 (§6-3 필수 항목)

1. **라운드와 현재 진영·부대**: 화면 상단 중앙 라벨에 "라운드 N · 아군/적 턴 · 행동 중: <id>"를 표시한다. 종료 후에는 "라운드 N · 전투 종료"로 바뀐다.
   - 라운드 값은 이벤트(`enemy_turn_started.round`, `round_started.round`)에서 얻는다.
   - 시작값 1은 "새 Battle_Main은 항상 1라운드에서 시작한다"는 가정이다. 읽기 허용 목록에 `battle_round`가 없기 때문이다(한계 참고).
2. **부대별 행동 상태**: 각 부대 위의 Label3D 배지와 오른쪽 아래 목록에 "미행동 / 이동 완료 / 행동 완료"를 표시한다.
   - 값은 14필드 뷰의 `has_acted`/`has_moved`에서만 읽는다(`action_state_text`). 3D가 따로 계산하지 않는다.
   - 기존 부대 라벨(ID·병종·병력)은 M2 테스트 계약 때문에 바꾸지 않았다. 배지는 별도 노드다.
3. **적 이동 경로 재생, 피격 표시, 사유 문구**: 위 기능 표 참고. 적 행동자는 붉은 링으로 강조한다(선택 링과 같은 `_disc`).
4. **적 처리 중 입력 제한·거절 표시**: M2의 `_input_locked`를 그대로 확장했다. 판정 순서는 다음과 같다.
   1. 결과 확정 → "전투 종료"
   2. `enemy_turn` → "적 턴 중"
   3. `is_demo_animating` → "연출 중"
   4. 재생 큐가 비지 않음 → "적 행동 재생 중"
   - 방향 확정 버튼도 이 잠금을 거친다. 공격 버튼은 같은 조건에서 비활성화된다.
5. **전투 종료**: 화면 중앙에 "승리/패배" 오버레이를 띄우고 모든 입력을 잠근다. 결과 화면 본체는 M5, 월드맵 연결은 M7이다(호출 0).
6. "강제 턴 종료" 버튼이나 규칙은 만들지 않았다.

입력 해제 조건은 다음 두 가지를 **모두** 만족할 때다: 엔진이 `ally_turn`이고 `!is_demo_animating`, 그리고 3D 재생 큐가 비었고 hold(0.35초)도 끝났다. 엔진은 이미 입력을 받는 상태인데 3D 재생이 남은 구간에서 입력을 거부하는 것을 테스트로 확인했다(락 테스트의 queue 구간, 캡처 05).

## 3. 실제 조작 증거

- **자동 테스트로만 확인한 것**: 동등성 18케이스, 락·커서·종료·격리, 기본 배치. 테스트는 `lab._unhandled_input`/버튼 `pressed.emit()`으로 입력한다.
- **실제 Godot 창 캡처 (렌더링 창, 사람 조작이 아님)**:
  - 실행: 비헤드리스 `Godot_v4.6.2-stable_win64_console.exe --path . --resolution 1280x800`
  - 일반 3D 랩 씬과 일반 호스트를 썼다(spy 없음).
  - 입력은 테스트 함수 호출이 아니라 `root.push_input(...)`(뷰포트 입력 경로 → `_unhandled_input`)으로 주입했다.
  - 드라이버는 zip `evidence/m3_capture/capture_driver.gd`이고, 커밋에는 넣지 않았다.
  - **사람이 마우스로 직접 조작한 캡처는 이번에 만들지 못했다.** 이 세션에서는 Godot 창을 사람처럼 조작하는 도구를 쓰지 않았다. 원하면 `test_battle3d_enemy_turn_manual.gd`로 같은 배치를 열어 직접 조작할 수 있다.
  - 캡처 9장(zip `evidence/m3_capture/`):
    - `00_default_layout_start`: 기본 배치 시작, 라운드 1 / 아군 턴, 배지 "미행동"
    - `01_round1_start` → `02_attack_select`(F키): 근접 배치 M10
    - `03_enemy_path_playback`: guan_yu (12,4)→(9,4) 경로 재생 중, 붉은 actor 링, 상단 "적 턴 · 행동 중: guan_yu", yi_sunsin 배지 "행동 완료"
    - `05_input_rejected_during_playback`: 엔진은 이미 `ally_turn`인데 재생 중이라 클릭이 "거절 / 적 행동 재생 중"
    - `04_enemy_hit_damage_applied`: "적 공격 · guan_yu → yi_sunsin 피해 8 (front)"와 −8 표시
    - `06_round2_ally_control`: "라운드 2 · 아군 턴", "아군 조작 가능"
    - `07_M13_..._victory`, `07_M12_..._defeat`: 승리/패배 오버레이와 이후 클릭 "거절 / 전투 종료"
  - 실행 원문 로그: `evidence/m3_capture/run.log`

## 4. 남은 연결

- **기본 배치 한 라운드 완주**: 방어/대기 명령 연결이 필요하다(위 의존성). M4 또는 별도 승인으로 결정해야 한다.
- **특기 연출**: M4. 지금은 문구 + 엔진 상태 동기화만 한다.
- **결과 화면 본체·재시작**: M5. **월드맵 왕복**: M7.
- **라운드 표시 시작값**: 엔진 `battle_round`를 읽지 않고 이벤트로만 갱신한다. resume처럼 1라운드가 아닌 시점에서 시작하는 진입이 생기면 읽기 허용이 필요하다.

## 5. 변경 파일 (`cbc1e43..`, `git diff --numstat`)

| 파일 | +/− | 비고 |
|---|---|---|
| `scripts/battle3d/battle3d_engine_play.gd` | +246 / −13 | 유일한 생산 코드 변경(3D). 엔진·서비스 0줄 |
| `tools/validate_battle_enemy_events_s3_1.py` | +1 / −1 | §6-2-3 허용: 기본 TIP을 `cbc1e43…`로 고정. 독스트링의 "HEAD 기본" 문구는 한 줄 제한 때문에 그대로 두었다 |
| `tests/scripts/support/battle3d_engine_attack_harness.gd` | +4 / −1 | **M2 하니스 최소 수정**(아래 설명) |
| `.github/workflows/verify-c-track.yml` | +6 | M3 validator 1개와 테스트 5개(동등성 샤드 3, 락, 기본 배치) 추가 |
| `tools/validate_battle3d_m3_enemy_turn.py` | +164 (신규) | |
| `tests/scripts/support/battle3d_enemy_turn_harness.gd` | +222 (신규) | M2 하니스를 확장하고, S3-1 하니스의 fixture와 `SeamBattle`을 재사용 |
| `tests/scripts/test_battle3d_enemy_turn_equivalence.gd` + `_shard_1/2/3` | +93 / +4×3 (신규) | |
| `tests/scripts/test_battle3d_enemy_turn_locks.gd` | +112 (신규) | |
| `tests/scripts/test_battle3d_enemy_turn_default_layout.gd` | +83 (신규) | |
| `tests/scripts/test_battle3d_enemy_turn_manual.gd` | +67 (신규) | 수동 진입. M2 수동 진입처럼 CI에는 넣지 않았다 |
| `tests/golden/battle3d_m3_start_v0.json` | +1157 (신규) | 기본 배치와 M10 배치의 시작 상태. **3D 없는 엔진 호스트에서 생성** |
| `.gd.uid` 8개 | +1씩 | CI import 사이드카 |
| `agent/BATTLE3D_M3_RESULT_20261020.md` | 이 보고서 | |

**M2 하니스 수정 이유:**
- M2 `sync_check`는 엔진 콜백 시점에 "모든 3D 뷰 위치 == 엔진 셀"을 단언했다.
- M3는 적 이동을 즉시 맞추지 않고 경로를 따라 재생한다. 그래서 적이 실제로 이동하는 M2 A3(궁병 사거리 3)에서 이 단언이 깨졌다(수정 전 실행에서 2 failures 확인).
- 이 단언을 "재생 중인 유닛은 재생 경로의 끝 == 엔진 셀, 재생 중이 아닌 유닛은 위치 == 엔진 셀"로 바꿨다. 다른 단언은 그대로다.
- M3 validator가 이 치환만 허용하는지 정확히 검사한다. M2 validator는 TIP이 `1ee5282`로 고정되어 있어 영향이 없다.

## 6. 구현 요약 (`battle3d_engine_play.gd`)

- **커서 3개, 로그 3개**: `event_cursor`(ally_move), `action_cursor`(battle_action), `enemy_cursor`(enemy_action). 소비 함수 하나가 로그 하나만 읽는다. 시퀀스를 합치지 않는다.
- **받는 즉시 결정하는 것**: 슬롯 요약과 종료 잠금. 슬롯은 `enemy_actor_selected`부터 `enemy_action_completed` 또는 `battle_ended`까지이고, 요약은 슬롯마다 1개다. `battle_ended`를 받는 그 프레임에 `battle_result`가 설정된다. `_input_locked`도 판단 전에 먼저 소비하므로 같은 프레임 안에서도 잠긴다.
- **재생 큐**: 이벤트를 차례로 보여 준다. `enemy_moved`는 경로 재생이 끝날 때까지 큐 맨 앞에 남는다. 공격·대기·특기·라운드 표시 뒤에는 0.35초 hold를 둔다.
- **진실은 엔진 상태**: 위치·병력·가시성·배지는 `_sync_views`가 엔진에서 읽는다. 재생 중인 유닛만 위치 덮어쓰기에서 빠지고, 재생이 끝나면 엔진 셀에 고정된다.
- **엔진 접근**: 쓰기 호출은 M2와 같은 6개다. 읽기 프로퍼티는 M2 7개에 `enemy_action_event_log`를 더한 8개다. 읽기 호출 3개는 그대로다. 월드맵·결과·턴 진행 함수 호출은 0이다.

## 7. 테스트

| 테스트 | 내용 | checks | 초 (CI 실행) |
|---|---|---:|---:|
| `test_battle3d_enemy_turn_equivalence_shard_1` | M1~M6 | 147 | 53.03 |
| `test_battle3d_enemy_turn_equivalence_shard_2` | M7~M12 | 136 | 42.01 |
| `test_battle3d_enemy_turn_equivalence_shard_3` | M13~M18 | 135 | 43.64 |
| `test_battle3d_enemy_turn_locks` | 잠금 구간 3종, 커서 독립, 승리·패배 종료 잠금, 격리 | 59 | 17.04 |
| `test_battle3d_enemy_turn_default_layout` | start == golden, UI 초기 상태, 기본 배치에서 진행이 막힘을 증명 | 68 | 5.24 |
| `validate_battle3d_m3_enemy_turn.py` | 범위·엔진 diff 0·명령/읽기 경계·커서·금지 호출 | - | 1.69 |
| `test_battle3d_enemy_turn_manual -- --layout=default --check` / `--layout=M10_round_two_slots --check` | 수동 진입 시작 상태 == golden | exit 0 / exit 0 | (CI 밖, 개별 실행) |

**엔진 동등성 18케이스 (각 케이스는 3D 입력 경로와 엔진 직접 경로를 따로 실행):**
- 엔진 직접 경로는 3D 없는 엔진 호스트(`Battle3DEngineHost`, SubViewport)에서 같은 6개 명령을 직접 호출한다.
- 3D 경로는 `lab._unhandled_input`, 공격 버튼, 방향 버튼으로만 입력한다.
- 비교 항목:
  - 유닛 10개의 40필드
  - 컨트롤러 12값(결과 상태 포함)
  - 로그 3개 전체
  - 엔진 쓰기 호출 순서. spy가 6개 명령을 모두 기록하며, 3D가 보낸 순서와 직접 호출 순서가 같다.
- fixture는 S3-1 오라클 하니스의 `_setup_unit`, `case_spec`, `_kill_for_fixture`, `SeamBattle`, `controller_state`를 그대로 호출한다.
- 케이스 목록:
  - 병종 5종 접근 후 공격: M1~M5 (총병 M4는 엔진이 낸 순서대로 이동 → 공격)
  - 제자리 공격: M6
  - 적의 즉사 공격: M7
  - 대기: M8
  - 혼란: M9
  - 적 슬롯 2개 연속 후 라운드 2: M10
  - 아군 즉사 공격: M11
  - 패배: M12
  - 승리: M13
  - 적 특기: M14
  - seam 경로 없음·경로 막힘·대상 없음: M15·M16·M17
  - 아군 이동 → 방향 → 공격: M18
- 결과: 15케이스가 라운드 2로 넘어갔고, M7은 아군 턴으로 복귀했다. M12와 M13은 종료됐다.

**재생 정확성:**
- 적 이동이 있는 7케이스에서 프레임마다 3D 뷰가 있는 셀을 기록했다. 그 순서가 `path`와 같고, 마지막 셀이 엔진 `grid_cell`과 같다.
- 피격 라벨 문자열은 `−<damage_applied> · <angle>`과 같다.

**큐·입력 잠금 (M10에서 spy로 측정):** 아래 세 구간마다 입력 6종을 넣었고 엔진 쓰기 호출은 0회였다. 입력 6종은 아군 클릭, 빈 칸 클릭, 공격 버튼, F키, 우클릭, 방향 버튼 4개다.
- 엔진 `enemy_turn` 구간
- 적 경로 재생 중
- 엔진은 이미 `ally_turn`인데 재생 큐가 남은 구간. 이 구간은 잠금 함수가 아니라 큐 자체로 판정한다.

재생이 끝난 뒤에는 첫 클릭이 `_select_ally_unit`으로 수락됐다.

**커서:**
- 세 소비 함수를 3번씩 다시 불러도 커서와 표시 개수가 변하지 않는다.
- 각 커서는 자기 로그의 길이와 같다.
- 적 로그를 소비해도 다른 두 커서는 움직이지 않는다.

**종료:**
- `battle_ended`가 기록된 그 프레임에 `_input_locked()`가 true를 반환한다.
- 이후 입력 6종을 2회 넣어도 쓰기 호출은 0회였다.
- 공격 버튼은 비활성화되고 방향 UI는 숨겨진다.
- 월드맵·결과 handoff 함수 3개(`_on_worldmap_result_return_pressed`, `_return_to_worldmap_with_result`, `_build_worldmap_battle_result_payload`)는 spy 기준 0회 호출됐다.

**격리:**
- `close_lab` 후 새 랩을 열면 커서, 큐, 결과, 오버레이, 요약, 재생 기록, 라운드가 모두 초기화되어 있고 엔진 적 로그는 비어 있다.
- 루트 자식 수가 원래대로이고, GameAudio 보이스는 재생 중이 아니다.

**seam 사용:** M15~M17은 S3-1 오라클의 `SeamBattle`이다. 조회 결과 하나만 바꾸며, 분기 본문·로그·잠금·턴 진행은 실제 코드 그대로 돈다(§6-1).

## 8. 새로 돌린 것 / 이전 증거 재사용

### 8-1. 새로 돌린 것 (이번 M3 세션)

**전체 CI 로컬 재현 1회** (최종 코드 = WIP `dcd66a5`, 보고서만 다른 상태):
- 순서: `.godot` 삭제 → `--headless --editor --import`(1회 만에 exit 0, 이번에는 signal 11 없음) → `verify-c-track.yml` 목록을 그대로 실행
- **112단계 모두 exit 0.** 내역:
  - validator 34 = 기존 33 + M3 1
  - Godot 테스트 73 = 기존 68 + M3 5
  - 씬 로드 3
  - `--editor --quit-after 2` 1
  - `git diff --check` 1
- 실행 후 `git status --short`는 비어 있었고, 단계 시간 합계는 707.8초다. 단계별 전체 표는 §10에 있다.
- 기존 3D 테스트도 이 실행에서 다시 통과했다:
  - M2 공격 샤드 1122 / 1123 / 1115
  - 거절 110, 동기화 364
  - M1-b 통합 144
  - 이동 parity, 모드, 경사 클릭
- S3-1 테스트도 이 실행에서 다시 통과했다: 오라클 64+64, 의미 525, 서비스 37.

그 밖에 새로 돌린 것:
- 변조 프로브 9개와 대조군(§9)
- 실제 창 캡처 실행 1회(§3)
- 수동 진입 `--check` 2회
- 개발 중 개별 실행: 동등성 18케이스 전체(418 checks / 134.8초), 락, 기본 배치, M2와 M1-b 3D 테스트 9종

### 8-2. 이전 증거 재사용
- **없다.** 모든 수치는 이번 세션에서 실행한 것이다.
- 원격 GitHub Actions는 push하지 않아 실행되지 않았다. Linux에서는 확인하지 않았다.

### 8-3. 환경 이슈 기록
- 이번 M3 세션의 fresh import 3회(본 작업 트리 2회, 프로브 worktree 1회)는 모두 1회 만에 exit 0이었다. signal 11은 재현되지 않았다. S3-1 세션에서 기록한 크래시(폰트 import 중)는 간헐적이다.
- 개발 중 기본 배치 테스트에서 `Attempted to free a locked object` 스크립트 오류가 1회 났다.
  - 원인: 테스트 하니스가 호스트의 `initialized` 시그널을 내보내는 도중에 호스트를 해제했다.
  - 하니스 `open_bare`에서 시그널 뒤에 한 프레임을 기다리도록 고쳤고, 이후 재발하지 않았다.
  - 생산 코드 문제는 아니다.
- 기존 테스트의 종료 시 `ObjectDB instances leaked` 경고는 이전과 같은 상태다(건드리지 않음).

## 9. 변조 프로브 9개 (원문)

방법:
- 별도 worktree(WIP `00c217a`와 같은 내용, 이후 락 테스트의 queue 구간 판정 개선본을 복사)에서 한 번에 변조 하나만 적용하고 `finally`에서 원래 바이트로 복구했다.
- 러너는 zip `evidence/run_m3_probes.py`이고, 정확한 치환 문자열은 아래에 원문 그대로 있다.
- **9개 모두 Godot 테스트가 exit 1이었다. parse/compile 오류 없이 단언 실패로 잡혔다.**
- validator 결과:
  - 정적으로 잡은 것 6개: Q3·Q4·Q5·Q6·Q7·Q8. Q7은 순서 검사의 `str.index`가 `ValueError`를 내서 exit 1이 됐다(AssertionError가 아님).
  - 통과시킨 것 3개: Q1(이중 소비), Q2(입력 잠금 제거), Q9(재생 큐 잠금 제거). 이 셋은 실행 중에만 드러나는 결함이라 테스트가 잡는다.
- 대조군(변조 없음)은 모두 exit 0이었다.
- Q9 관련 개선: 첫 실행에서 Q9가 잡히긴 했지만, "재생 큐 구간" 판정에 변조 대상인 `_enemy_presentation_busy()`를 쓰고 있었다. 그래서 판정을 큐와 hold 값을 직접 읽는 방식으로 바꾸고 9개를 모두 다시 돌렸다. 아래가 그 재실행 원문이다. 이제 Q9는 "재생 큐 구간에 엔진 쓰기 호출 발생"으로 직접 잡힌다.

지시문 §2-4 목록과의 대응:

| 지시문 항목 | 프로브 |
|---|---|
| 적 이벤트 이중 소비 | Q1 |
| 입력 잠금 제거 | Q2 |
| 3D가 엔진 필드 직접 쓰기 | Q3 |
| path 무시하고 최종 셀로 순간이동 | Q4 |
| damage_applied 대신 계산값 사용 | Q5 (raw_damage) |
| 월드맵 호출 추가 | Q6 |
| battle_ended 후 입력 허용 | Q7 |
| 커서 합치기 | Q8 |
| 추가 | Q9 (재생 큐 잠금 제거) |

### Q1_enemy_event_double_consumption

변조 파일: `scripts/battle3d/battle3d_engine_play.gd`

원래 문자열:
```gdscript
	var events: Array = engine.get("enemy_action_event_log").export()
	while enemy_cursor < events.size():
		var event: Dictionary = events[enemy_cursor]
		enemy_cursor += 1
```
변조 문자열:
```gdscript
	var events: Array = engine.get("enemy_action_event_log").export()
	enemy_cursor = 0
	while enemy_cursor < events.size():
		var event: Dictionary = events[enemy_cursor]
		enemy_cursor += 1
```

`validate_battle3d_m3_enemy_turn.py` → exit=0, 1.65초
```text
M3_3D validator PASS: base=cbc1e43 scope=HEAD; 23 paths; engine diff 0; six commands; 8 read properties; three cursors; no world-map/result/turn-control calls
```
`test_battle3d_enemy_turn_equivalence.gd --case=M1_infantry_approach` → exit=1, 38.54초, parse_error=False
```text
[M3_EQUIVALENCE] checks=7620 failures=["M1_infantry_approach 3D settled with empty playback queue", "M1_infantry_approach each enemy_moved played once", "M1_infantry_approach hit presentations equal attack events", "M1_infantry_approach one summary per enemy slot", "M1_infantry_approach round text"]
[M3] FAIL M1_infantry_approach 3D settled with empty playback queue
[M3] FAIL M1_infantry_approach each enemy_moved played once
[M3] FAIL M1_infantry_approach hit presentations equal attack events
[M3] FAIL M1_infantry_approach one summary per enemy slot
[M3] FAIL M1_infantry_approach round text
```

### Q2_input_lock_removed

변조 파일: `scripts/battle3d/battle3d_engine_play.gd`

원래 문자열:
```gdscript
func _input_locked() -> bool:
	# Battle end
```
변조 문자열:
```gdscript
func _input_locked() -> bool:
	return false
	# Battle end
```

`validate_battle3d_m3_enemy_turn.py` → exit=0, 1.78초
```text
M3_3D validator PASS: base=cbc1e43 scope=HEAD; 23 paths; engine diff 0; six commands; 8 read properties; three cursors; no world-map/result/turn-control calls
```
`test_battle3d_enemy_turn_locks.gd` → exit=1, 20.69초, parse_error=False
```text
[M3_LOCKS] checks=59 failures=["engine enemy_turn no engine write call [\"_handle_right_click_cancel\"]", "enemy_turn reason text", "enemy path playback no engine write call [\"_handle_right_click_cancel\"]", "playback queue no engine write call [\"_select_ally_unit\", \"_try_direct_move_to_cell\", \"try_basic_attack\", \"_handle_right_click_cancel\"]", "queue reason text", "M13_enemy_wipe_victory locked on the frame battle_ended is logged", "M13_enemy_wipe_victory after end 0 no engine write call [\"_select_ally_unit\", \"_try_direct_move_to_cell\", \"try_basic_attack\", \"try_basic_attack\", \"_handle_right_click_cancel\"]", "M13_enemy_wipe_victory end reason text", "M13_enemy_wipe_victory after end 1 no engine write call [\"_select_ally_unit\", \"_try_direct_move_to_cell\", \"try_basic_attack\", \"try_basic_attack\", \"_handle_right_click_cancel\"]", "M13_enemy_wipe_victory end reason text", "M12_ally_wipe_defeat locked on the frame battle_ended is logged", "M12_ally_wipe_defeat after end 0 no engine write call [\"_handle_right_click_cancel\"]", "M12_ally_wipe_defeat end reason text", "M12_ally_wipe_defeat after end 1 no engine write call [\"_handle_right_click_cancel\"]", "M12_ally_wipe_defeat end reason text"]
[M3] FAIL engine enemy_turn no engine write call ["_handle_right_click_cancel"]
[M3] FAIL enemy_turn reason text
[M3] FAIL enemy path playback no engine write call ["_handle_right_click_cancel"]
[M3] FAIL playback queue no engine write call ["_select_ally_unit", "_try_direct_move_to_cell", "try_basic_attack", "_handle_right_click_cancel"]
[M3] FAIL queue reason text
[M3] FAIL M13_enemy_wipe_victory locked on the frame battle_ended is logged
[M3] FAIL M13_enemy_wipe_victory after end 0 no engine write call ["_select_ally_unit", "_try_direct_move_to_cell", "try_basic_attack", "try_basic_attack", "_handle_right_click_cancel"]
[M3] FAIL M13_enemy_wipe_victory end reason text
[M3] FAIL M13_enemy_wipe_victory after end 1 no engine write call ["_select_ally_unit", "_try_direct_move_to_cell", "try_basic_attack", "try_basic_attack", "_handle_right_click_cancel"]
[M3] FAIL M13_enemy_wipe_victory end reason text
[M3] FAIL M12_ally_wipe_defeat locked on the frame battle_ended is logged
```

### Q3_3d_writes_engine_field

변조 파일: `scripts/battle3d/battle3d_engine_play.gd`

원래 문자열:
```gdscript
func _show_enemy_hit(event: Dictionary) -> void:
```
변조 문자열:
```gdscript
func _show_enemy_hit(event: Dictionary) -> void:
	queries.find_unit(event.target_id).current_troops = event.target_troops_after - 1
```

`validate_battle3d_m3_enemy_turn.py` → exit=1, 2.46초
```text
AssertionError: state assignment
```
`test_battle3d_enemy_turn_equivalence.gd --case=M1_infantry_approach` → exit=1, 12.56초, parse_error=False
```text
[M3_EQUIVALENCE] checks=25 failures=["M1_infantry_approach 40-field units equal [\"units[0].current_troops\"]"]
[M3] FAIL M1_infantry_approach 40-field units equal ["units[0].current_troops"]
```

### Q4_teleport_ignoring_path

변조 파일: `scripts/battle3d/battle3d_engine_play.gd`

원래 문자열:
```gdscript
	enemy_moving_id = event.unit_id
	playback[event.unit_id] = {"path":path,"index":1}
	views[event.unit_id].position = board.world(path[0])
```
변조 문자열:
```gdscript
	enemy_moving_id = event.unit_id
	views[event.unit_id].position = board.world(path[-1])
```

`validate_battle3d_m3_enemy_turn.py` → exit=1, 1.67초
```text
AssertionError: enemy path playback
```
`test_battle3d_enemy_turn_equivalence.gd --case=M1_infantry_approach` → exit=1, 10.28초, parse_error=False
```text
[M3_EQUIVALENCE] checks=25 failures=["M1_infantry_approach 3D view passes path cells in order [] vs [(12, 4), (11, 4), (10, 4), (9, 4)]"]
[M3] FAIL M1_infantry_approach 3D view passes path cells in order [] vs [(12, 4), (11, 4), (10, 4), (9, 4)]
```

### Q5_computed_damage_instead_of_damage_applied

변조 파일: `scripts/battle3d/battle3d_engine_play.gd`

원래 문자열:
```gdscript
	label.text="−%s · %s" % [event.damage_applied,event.angle_type]
	label.font_size=58
	label.pixel_size=.015
	label.modulate=Color("ff9a8a")
```
변조 문자열:
```gdscript
	label.text="−%s · %s" % [event.raw_damage,event.angle_type]
	label.font_size=58
	label.pixel_size=.015
	label.modulate=Color("ff9a8a")
```

`validate_battle3d_m3_enemy_turn.py` → exit=1, 1.66초
```text
AssertionError: hit shows damage_applied
```
`test_battle3d_enemy_turn_equivalence.gd --case=M7_enemy_lethal_hit` → exit=1, 10.22초, parse_error=False
```text
[M3_EQUIVALENCE] checks=21 failures=["M7_enemy_lethal_hit hit label shows damage_applied 5"]
[M3] FAIL M7_enemy_lethal_hit hit label shows damage_applied 5
```

### Q6_worldmap_call_added

변조 파일: `scripts/battle3d/battle3d_engine_play.gd`

원래 문자열:
```gdscript
		"battle_ended":
			enemy_actor_id = ""
```
변조 문자열:
```gdscript
		"battle_ended":
			engine.call("_return_to_worldmap_with_result")
			enemy_actor_id = ""
```

`validate_battle3d_m3_enemy_turn.py` → exit=1, 1.5초
```text
AssertionError: exact six commands and three read calls: {'_select_ally_unit', '_return_to_worldmap_with_result', 'try_basic_attack', 'is_unit_in_attack_range', '_try_attack_enemy_target_from_attack_select', '_get_alive_enemy_units', '_try_direct_move_to_cell', '_is_unit_state_available_for_battle_slot', '_select_post_move_facing', '_handle_right_click_cancel'}
```
`test_battle3d_enemy_turn_locks.gd` → exit=1, 16.08초, parse_error=False
```text
[M3_LOCKS] checks=59 failures=["M13_enemy_wipe_victory no world-map/result handoff call", "M12_ally_wipe_defeat no world-map/result handoff call"]
[M3] FAIL M13_enemy_wipe_victory no world-map/result handoff call
[M3] FAIL M12_ally_wipe_defeat no world-map/result handoff call
```

### Q7_input_allowed_after_battle_ended

변조 파일: `scripts/battle3d/battle3d_engine_play.gd`

원래 문자열:
```gdscript
	if not battle_result.is_empty():
		_reject("전투 종료
```
변조 문자열:
```gdscript
	if false:
		_reject("전투 종료
```

`validate_battle3d_m3_enemy_turn.py` → exit=1, 1.5초
```text
ValueError: substring not found
```
`test_battle3d_enemy_turn_locks.gd` → exit=1, 17.51초, parse_error=False
```text
[M3_LOCKS] checks=59 failures=["M13_enemy_wipe_victory locked on the frame battle_ended is logged", "M13_enemy_wipe_victory after end 0 no engine write call [\"_select_ally_unit\", \"_try_direct_move_to_cell\", \"try_basic_attack\", \"try_basic_attack\", \"_handle_right_click_cancel\"]", "M13_enemy_wipe_victory end reason text", "M13_enemy_wipe_victory after end 1 no engine write call [\"_select_ally_unit\", \"_try_direct_move_to_cell\", \"try_basic_attack\", \"try_basic_attack\", \"_handle_right_click_cancel\"]", "M13_enemy_wipe_victory end reason text", "M12_ally_wipe_defeat locked on the frame battle_ended is logged", "M12_ally_wipe_defeat end reason text", "M12_ally_wipe_defeat end reason text"]
[M3] FAIL M13_enemy_wipe_victory locked on the frame battle_ended is logged
[M3] FAIL M13_enemy_wipe_victory after end 0 no engine write call ["_select_ally_unit", "_try_direct_move_to_cell", "try_basic_attack", "try_basic_attack", "_handle_right_click_cancel"]
[M3] FAIL M13_enemy_wipe_victory end reason text
[M3] FAIL M13_enemy_wipe_victory after end 1 no engine write call ["_select_ally_unit", "_try_direct_move_to_cell", "try_basic_attack", "try_basic_attack", "_handle_right_click_cancel"]
[M3] FAIL M13_enemy_wipe_victory end reason text
[M3] FAIL M12_ally_wipe_defeat locked on the frame battle_ended is logged
[M3] FAIL M12_ally_wipe_defeat end reason text
[M3] FAIL M12_ally_wipe_defeat end reason text
```

### Q8_cursors_merged

변조 파일: `scripts/battle3d/battle3d_engine_play.gd`

원래 문자열:
```gdscript
	var events: Array = engine.get("enemy_action_event_log").export()
	while enemy_cursor < events.size():
		var event: Dictionary = events[enemy_cursor]
		enemy_cursor += 1
```
변조 문자열:
```gdscript
	var events: Array = engine.get("enemy_action_event_log").export()
	while action_cursor < events.size():
		var event: Dictionary = events[action_cursor]
		action_cursor += 1
```

`validate_battle3d_m3_enemy_turn.py` → exit=1, 1.81초
```text
AssertionError: _consume_enemy_events
```
`test_battle3d_enemy_turn_locks.gd` → exit=1, 17.39초, parse_error=False
```text
[M3_LOCKS] checks=59 failures=["cursor i reads log i", "M13_enemy_wipe_victory locked on the frame battle_ended is logged", "M13_enemy_wipe_victory engine and lab result", "M13_enemy_wipe_victory overlay", "M13_enemy_wipe_victory after end 0 no engine write call [\"_select_ally_unit\", \"_try_direct_move_to_cell\", \"try_basic_attack\", \"try_basic_attack\", \"_handle_right_click_cancel\"]", "M13_enemy_wipe_victory end reason text", "M13_enemy_wipe_victory after end 1 no engine write call [\"_select_ally_unit\", \"_try_direct_move_to_cell\", \"try_basic_attack\", \"try_basic_attack\", \"_handle_right_click_cancel\"]", "M13_enemy_wipe_victory end reason text", "M13_enemy_wipe_victory controls disabled", "M12_ally_wipe_defeat locked on the frame battle_ended is logged", "M12_ally_wipe_defeat engine and lab result", "M12_ally_wipe_defeat overlay", "M12_ally_wipe_defeat end reason text", "M12_ally_wipe_defeat end reason text"]
[M3] FAIL cursor i reads log i
[M3] FAIL M13_enemy_wipe_victory locked on the frame battle_ended is logged
[M3] FAIL M13_enemy_wipe_victory engine and lab result
[M3] FAIL M13_enemy_wipe_victory overlay
[M3] FAIL M13_enemy_wipe_victory after end 0 no engine write call ["_select_ally_unit", "_try_direct_move_to_cell", "try_basic_attack", "try_basic_attack", "_handle_right_click_cancel"]
[M3] FAIL M13_enemy_wipe_victory end reason text
[M3] FAIL M13_enemy_wipe_victory after end 1 no engine write call ["_select_ally_unit", "_try_direct_move_to_cell", "try_basic_attack", "try_basic_attack", "_handle_right_click_cancel"]
[M3] FAIL M13_enemy_wipe_victory end reason text
[M3] FAIL M13_enemy_wipe_victory controls disabled
[M3] FAIL M12_ally_wipe_defeat locked on the frame battle_ended is logged
[M3] FAIL M12_ally_wipe_defeat engine and lab result
```

### Q9_playback_queue_lock_removed

변조 파일: `scripts/battle3d/battle3d_engine_play.gd`

원래 문자열:
```gdscript
func _enemy_presentation_busy() -> bool:
```
변조 문자열:
```gdscript
func _enemy_presentation_busy() -> bool:
	return false
```

`validate_battle3d_m3_enemy_turn.py` → exit=0, 1.82초
```text
M3_3D validator PASS: base=cbc1e43 scope=HEAD; 23 paths; engine diff 0; six commands; 8 read properties; three cursors; no world-map/result/turn-control calls
```
`test_battle3d_enemy_turn_locks.gd` → exit=1, 15.87초, parse_error=False
```text
[M3_LOCKS] checks=59 failures=["playback queue no engine write call [\"_select_ally_unit\", \"_try_direct_move_to_cell\", \"try_basic_attack\", \"_handle_right_click_cancel\"]", "queue reason text", "status returns to ally control after playback", "no duplicate consumption"]
[M3] FAIL playback queue no engine write call ["_select_ally_unit", "_try_direct_move_to_cell", "try_basic_attack", "_handle_right_click_cancel"]
[M3] FAIL queue reason text
[M3] FAIL status returns to ally control after playback
[M3] FAIL no duplicate consumption
```

### 대조군 (변조 없음, 같은 worktree)

`test_battle3d_enemy_turn_equivalence.gd --case=M1_infantry_approach` → exit=0
```text
[M3_EQUIVALENCE] checks=25 failures=[]
```
`test_battle3d_enemy_turn_equivalence.gd --case=M7_enemy_lethal_hit` → exit=0
```text
[M3_EQUIVALENCE] checks=21 failures=[]
```
`test_battle3d_enemy_turn_locks.gd` → exit=0
```text
[M3_LOCKS] checks=59 failures=[]
```
`validate_battle3d_m3_enemy_turn.py` → exit=0
```text
M3_3D validator PASS: base=cbc1e43 scope=HEAD; 23 paths; engine diff 0; six commands; 8 read properties; three cursors; no world-map/result/turn-control calls
```

## 10. 전체 CI 로컬 재현 단계별 결과 (새로 돌린 것, 112단계)

| # | 단계 | exit | 초 | checks |
|---:|---|---:|---:|---:|
| 1 | `tools/validate_worldmap_main_integrity.py` | 0 | 0.15 | - |
| 2 | `tools/validate_worldmap_diplomacy_controller_extraction.py` | 0 | 1.28 | - |
| 3 | `tools/validate_worldmap_diplomacy_routing.py` | 0 | 3.53 | - |
| 4 | `tools/validate_worldmap_diplomacy_service_separation.py` | 0 | 0.71 | - |
| 5 | `tools/validate_worldmap_trade_routing.py` | 0 | 0.58 | - |
| 6 | `tools/validate_worldmap_trade_controller_extraction.py` | 0 | 0.67 | - |
| 7 | `tools/validate_worldmap_trade_phase2_extraction.py` | 0 | 0.22 | - |
| 8 | `tools/validate_worldmap_spy_routing.py` | 0 | 0.77 | - |
| 9 | `tools/validate_worldmap_spy_controller_extraction.py` | 0 | 0.8 | - |
| 10 | `tools/validate_worldmap_battle_settlement_applier_extraction.py` | 0 | 0.24 | - |
| 11 | `tools/validate_worldmap_t03_strategic_battle_transaction_extraction.py` | 0 | 0.24 | - |
| 12 | `tools/validate_worldmap_t03_battle_presentation_extraction.py` | 0 | 0.68 | - |
| 13 | `tools/validate_worldmap_player_attack_deployment_service_extraction.py` | 0 | 0.81 | - |
| 14 | `tools/validate_worldmap_wounded_recovery_service_extraction.py` | 0 | 0.24 | - |
| 15 | `tools/validate_worldmap_to_battle_input_lifecycle.py` | 0 | 0.12 | - |
| 16 | `tools/validate_b0b_battle_production_skeleton.py` | 0 | 0.12 | - |
| 17 | `tools/validate_b0c_battle_iso_promotion.py` | 0 | 0.12 | - |
| 18 | `tools/validate_b1b_battle_movement_query_service.py` | 0 | 0.33 | - |
| 19 | `tools/validate_b1c_battle_combat_query_service.py` | 0 | 0.22 | - |
| 20 | `tools/validate_b1d_battle_damage_formula_service.py` | 0 | 0.23 | - |
| 21 | `tools/validate_b1e_battle_action_lock_state_service.py` | 0 | 0.38 | - |
| 22 | `tools/validate_b1f_battle_enemy_ai_reservation_state_service.py` | 0 | 0.27 | - |
| 23 | `tools/validate_b1g_battle_unique_skill_cooldown_state_service.py` | 0 | 0.23 | - |
| 24 | `tools/validate_battle_s1_1_observation_baseline.py` | 0 | 0.95 | - |
| 25 | `tools/validate_battle_s2_1_attack_baseline.py` | 0 | 0.67 | - |
| 26 | `tools/validate_battle_s2_2_attack_state_service.py` | 0 | 2.67 | - |
| 27 | `tools/validate_battle_enemy_events_s3_1.py` | 0 | 2.77 | - |
| 28 | `tools/validate_battle_s1_2_ally_move_state_service.py` | 0 | 1.88 | - |
| 29 | `tools/validate_battle3d_m1b_engine_move.py` | 0 | 0.76 | - |
| 30 | `tools/validate_battle3d_m2_engine_attack.py` | 0 | 4.46 | - |
| 31 | `tools/validate_battle3d_m3_enemy_turn.py` | 0 | 1.69 | - |
| 32 | `tools/validate_battle3d_contract.py` | 0 | 0.14 | - |
| 33 | `tools/validate_alternating_battle_action_order.py` | 0 | 0.15 | - |
| 34 | `tools/validate_single_side_exhaustion_turn_order.py` | 0 | 0.13 | - |
| 35 | `tests/scripts/test_worldmap_city_administration_service_extraction.gd` | 0 | 0.55 | - |
| 36 | `tests/scripts/test_worldmap_city_resource_service_extraction.gd` | 0 | 0.54 | - |
| 37 | `tests/scripts/test_worldmap_city_detail_presentation_extraction.gd` | 0 | 0.55 | - |
| 38 | `tests/scripts/test_worldmap_camera_controller_extraction.gd` | 0 | 0.55 | - |
| 39 | `tests/scripts/test_worldmap_hud_controller_extraction.gd` | 0 | 0.64 | - |
| 40 | `tests/scripts/test_worldmap_shared_ui_controller_extraction.gd` | 0 | 0.55 | - |
| 41 | `tests/scripts/test_world_calendar_service_extraction.gd` | 0 | 0.55 | - |
| 42 | `tests/scripts/test_world_turn_economy_service_extraction.gd` | 0 | 0.54 | - |
| 43 | `tests/scripts/test_world_turn_state_service_extraction.gd` | 0 | 0.54 | - |
| 44 | `tests/scripts/test_worldmap_turn_controller_extraction.gd` | 0 | 0.55 | - |
| 45 | `tests/scripts/test_battle_movement_query_service.gd` | 0 | 4.1 | - |
| 46 | `tests/scripts/test_battle_combat_query_service.gd` | 0 | 4.19 | - |
| 47 | `tests/scripts/test_battle_damage_formula_service.gd` | 0 | 4.29 | - |
| 48 | `tests/scripts/test_battle_action_lock_state_service.gd` | 0 | 4.19 | - |
| 49 | `tests/scripts/test_battle_enemy_ai_reservation_state_service.gd` | 0 | 4.37 | - |
| 50 | `tests/scripts/test_battle_unique_skill_cooldown_state_service.gd` | 0 | 4.51 | - |
| 51 | `tests/scripts/test_battle_event_log_service.gd` | 0 | 0.55 | - |
| 52 | `tests/scripts/test_battle_state_fingerprint_service.gd` | 0 | 0.68 | - |
| 53 | `tests/scripts/test_battle_attack_oracle_shard_1.gd` | 0 | 42.17 | 128 |
| 54 | `tests/scripts/test_battle_attack_oracle_shard_2.gd` | 0 | 31.9 | 106 |
| 55 | `tests/scripts/test_battle_attack_state_service.gd` | 0 | 0.54 | 70 |
| 56 | `tests/scripts/test_battle_attack_event_parity.gd` | 0 | 36.16 | 213 |
| 57 | `tests/scripts/test_battle_enemy_event_log_service.gd` | 0 | 0.64 | 37 |
| 58 | `tests/scripts/test_battle_enemy_turn_oracle_shard_1.gd` | 0 | 38.2 | 64 |
| 59 | `tests/scripts/test_battle_enemy_turn_oracle_shard_2.gd` | 0 | 29.15 | 64 |
| 60 | `tests/scripts/test_battle_enemy_turn_event_semantics.gd` | 0 | 33.66 | 525 |
| 61 | `tests/scripts/test_battle_move_oracle_baseline.gd` | 0 | 20.93 | - |
| 62 | `tests/scripts/test_battle_ally_move_state_service.gd` | 0 | 0.63 | - |
| 63 | `tests/scripts/test_battle_ally_move_event_parity.gd` | 0 | 7.9 | - |
| 64 | `tests/scripts/test_battle3d_engine_move_integration.gd` | 0 | 9.17 | 144 |
| 65 | `tests/scripts/test_battle3d_engine_attack_shard_1.gd` | 0 | 12.3 | 1122 |
| 66 | `tests/scripts/test_battle3d_engine_attack_shard_2.gd` | 0 | 11.27 | 1123 |
| 67 | `tests/scripts/test_battle3d_engine_attack_shard_3.gd` | 0 | 10.76 | 1115 |
| 68 | `tests/scripts/test_battle3d_engine_attack_rejections.gd` | 0 | 10.54 | 110 |
| 69 | `tests/scripts/test_battle3d_engine_attack_sync.gd` | 0 | 10.46 | 364 |
| 70 | `tests/scripts/test_battle3d_enemy_turn_equivalence_shard_1.gd` | 0 | 53.03 | 147 |
| 71 | `tests/scripts/test_battle3d_enemy_turn_equivalence_shard_2.gd` | 0 | 42.01 | 136 |
| 72 | `tests/scripts/test_battle3d_enemy_turn_equivalence_shard_3.gd` | 0 | 43.64 | 135 |
| 73 | `tests/scripts/test_battle3d_enemy_turn_locks.gd` | 0 | 17.04 | 59 |
| 74 | `tests/scripts/test_battle3d_enemy_turn_default_layout.gd` | 0 | 5.24 | 68 |
| 75 | `tests/scripts/test_battle3d_movement_parity.gd` | 0 | 2.03 | - |
| 76 | `tests/scripts/test_battle3d_modes.gd` | 0 | 1.01 | - |
| 77 | `tests/scripts/test_battle3d_oblique_click.gd` | 0 | 8.78 | - |
| 78 | `tests/scripts/alternating_battle_action_order_test.gd` | 0 | 0.55 | - |
| 79 | `tests/scripts/test_single_side_exhaustion_turn_order.gd` | 0 | 3.83 | - |
| 80 | `tests/scripts/test_worldmap_domestic_tech_catalog_extraction.gd` | 0 | 7.43 | - |
| 81 | `tests/scripts/test_worldmap_domestic_tech_research_rules_extraction.gd` | 0 | 0.53 | - |
| 82 | `tests/scripts/test_worldmap_domestic_tech_research_service_extraction.gd` | 0 | 0.91 | - |
| 83 | `tests/scripts/test_worldmap_domestic_tech_effect_provider_extraction.gd` | 0 | 0.64 | - |
| 84 | `tests/scripts/test_worldmap_domestic_tech_tree_presentation_extraction.gd` | 0 | 2.42 | - |
| 85 | `tests/scripts/test_worldmap_domestic_tech_completion_presentation_extraction.gd` | 0 | 0.93 | - |
| 86 | `tests/scripts/test_worldmap_military_controller_extraction.gd` | 0 | 5.85 | - |
| 87 | `tests/scripts/test_worldmap_enemy_warfare_service_extraction.gd` | 0 | 5.88 | - |
| 88 | `tests/scripts/test_worldmap_battle_context_service_extraction.gd` | 0 | 5.92 | - |
| 89 | `tests/scripts/test_worldmap_battle_result_service_extraction.gd` | 0 | 5.73 | - |
| 90 | `tests/scripts/test_worldmap_battle_settlement_applier_extraction.gd` | 0 | 0.54 | - |
| 91 | `tests/scripts/test_worldmap_t03_strategic_battle_transaction_extraction.gd` | 0 | 0.53 | - |
| 92 | `tests/scripts/test_worldmap_t03_battle_presentation_extraction.gd` | 0 | 0.63 | - |
| 93 | `tests/scripts/test_worldmap_player_attack_deployment_service_extraction.gd` | 0 | 0.54 | - |
| 94 | `tests/scripts/test_worldmap_troop_rebalance_service_extraction.gd` | 0 | 0.53 | - |
| 95 | `tests/scripts/test_worldmap_wounded_recovery_service_extraction.gd` | 0 | 0.67 | - |
| 96 | `tests/scripts/test_worldmap_diplomacy_routing.gd` | 0 | 20.77 | - |
| 97 | `tests/scripts/test_worldmap_diplomacy_controller_extraction.gd` | 0 | 1.1 | - |
| 98 | `tests/scripts/test_worldmap_diplomacy_validation_extraction.gd` | 0 | 5.74 | - |
| 99 | `tests/scripts/test_worldmap_diplomacy_mutation_extraction.gd` | 0 | 5.83 | - |
| 100 | `tests/scripts/test_worldmap_diplomacy_state_extraction.gd` | 0 | 5.74 | - |
| 101 | `tests/scripts/test_worldmap_diplomacy_alliance_extraction.gd` | 0 | 6.14 | - |
| 102 | `tests/scripts/test_worldmap_trade_routing.gd` | 0 | 17.82 | - |
| 103 | `tests/scripts/test_worldmap_trade_controller_extraction.gd` | 0 | 5.65 | - |
| 104 | `tests/scripts/test_worldmap_trade_automation_extraction.gd` | 0 | 5.67 | - |
| 105 | `tests/scripts/test_worldmap_internal_trade_transfer_extraction.gd` | 0 | 5.56 | - |
| 106 | `tests/scripts/test_worldmap_spy_routing.gd` | 0 | 21.37 | - |
| 107 | `tests/scripts/test_worldmap_spy_controller_extraction.gd` | 0 | 6.58 | - |
| 108 | `CI_WORLDMAP_LOAD` | 0 | 3.45 | - |
| 109 | `CI_BATTLE_MAIN_LOAD` | 0 | 2.58 | - |
| 110 | `CI_IMJIN_ISO_LOAD` | 0 | 3.23 | - |
| 111 | `editor_quit_after_2` | 0 | 5.67 | - |
| 112 | `git diff --check` | 0 | 0 | - |


## 11. 알려진 한계·미커버 영역

- **기본 배치 한 라운드 완주는 충족되지 않았다**(맨 위 의존성 보고). 엔진에 방어/대기 연결이 필요하다.
- **3D 재생이 엔진보다 늦다**: 엔진은 2D Tween 시간으로 진행하고, 3D는 이벤트를 받은 뒤에 재생한다. 연속 슬롯이나 라운드 전환에서는 재생이 끝나기 전에 엔진이 이미 다음 슬롯이나 다음 라운드에 가 있을 수 있다. 그동안 표시는 이렇게 된다.
  - 상단 라운드·행동자 라벨은 **재생 중인 이벤트** 기준이다.
  - 병력·가시성·배지·목록은 **현재 엔진 상태** 기준이다. 캡처 04에서는 상단이 "라운드 1 · 적 턴"인데, 목록에는 라운드 2에 배치된 증원과 초기화된 "미행동"이 보인다.
  - 이 어긋남 때문에 입력이 허용되지는 않는다(큐가 빌 때까지 잠금). 표시가 혼동될 수 있는 점은 M6 UI 정리 항목으로 남긴다.
- **병력 숫자 변화가 피격 표시보다 먼저 보일 수 있다**: 병력 라벨은 엔진 상태로 즉시 갱신된다. 적이 이동한 뒤 공격하면, 3D 경로 재생이 끝나야 피격 숫자가 뜨므로 숫자보다 병력 변화가 먼저 보일 수 있다.
- **라운드 시작값**: 엔진 `battle_round`를 읽지 않으므로 "새 Battle_Main = 1라운드" 가정에 의존한다(읽기 허용 목록 제약).
- **`_get_battle_result_state()`를 3D가 직접 읽지 않는다**: §6-1은 "`battle_ended` 수신 **또는** 결과 상태"를 허용했지만, 읽기 허용 목록을 넓히지 않으려고 `battle_ended` 이벤트만 쓴다. S3-1 계약상 `battle_ended`는 결과가 처음 확정될 때 1회 기록되므로 같은 판정이다. 다만 `reset_demo_state`로 같은 씬을 재시작하는 흐름은 다루지 않았다(M5·M6).
- **seam 분기**: 경로 없음·경로 막힘·대상 없음은 테스트 전용 seam으로만 재생을 확인했다. 실제 플레이에서는 나오지 않는다.
- **적 총병의 이동 후 공격**(기존 동작)을 그대로 재생한다. 결정 대기 항목이다.
- **특기 연출 없음**(M4). 특기 결과는 상태 diff 폴백 요약과 엔진 동기화로만 보인다. 특기 커밋이 실패하는 경로와 `consumes_action=false` 특기는 테스트하지 않았다.
- **행동할 적이 없는 슬롯**(`enemy_turn_started` 뒤에 actor 없음)은 3D 케이스로 만들지 않았다.
- **사람이 직접 조작한 캡처가 없다**: 실제 렌더링 창과 뷰포트 입력 주입으로 캡처했지만, 사람이 마우스로 조작한 증거는 아니다(§3).
- **원격 CI와 Linux는 확인하지 않았다.**

## 12. 커밋

- 작업 중 WIP 커밋 `c7743d0`, `00c217a`, `dcd66a5`로 보존했고, 마지막에 S3-1 커밋 위 **M3 커밋 1개로 squash**했다(S3-1 커밋 `cbc1e43`은 그대로 둠).
- 최종 해시는 자기 자신을 이 문서에 넣을 수 없어서 zip의 `commit_hashes.txt`에 적는다.
- push하지 않았다.
