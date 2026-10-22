# BATTLE3D M4-c1 결과 — 3D 아군 고유특기 수동 사용 (2026-10-22)

- 작업 ID: M4-c1 3D Ally Unique Skill
- 지시문: `M4C1_ALLY_SKILL_20261022.md` (클코치). 사전 감사 `M4_PRE_AUDIT_20261020.md` §3, 엔진 이벤트 `agent/BATTLE_S4_1_RESULT_20261021.md` §6
- 브랜치: `feature/battle3d-m4c1-skill-20261022` ← `origin/integration/p1-engine-core-20261019`(기준 `4e0b034` 확인함)
- 구현 커밋 1개: `feat(battle3d): connect the engine unique skill command (M4-c1)`. 작성자·커미터 `noreply@anthropic.com`. 푸시 안 함.
- 합격 판정은 하지 않는다(검수: 클코치).
- **멈춤 규칙에 걸리지 않았다**:
  - 엔진·서비스·어댑터 수정 0
  - 쓰기 호출은 승인된 2개만 추가(11·12번째)
  - 읽기는 승인 목록 안에서만 추가
  - 기존 테스트·하니스·골든 수정 0(§4 예외도 쓰지 않음)

---

## 0. 사전 확인 8개 (엔진 직접 실행, 새로 돌린 것)

스크립트: zip `evidence/m4c1_precheck/_tmp_m4c1_precheck.gd`(커밋 안 함). 원문 로그: `precheck.log`. 판은 S4-1 오라클 보드다(시전자 units[0] (8,4), 아군 units[1] (7,4), 적 units[5..7] 근접, 아군 기세 10).

### 1. phase와 플래그 전이 — 현재 `_input_locked()`가 모두 덮는다

phase 문자열은 `PHASE_UNIQUE_SKILL_TARGET_SELECT = "unique_skill_target_select"`다. 표의 값은 (phase, `is_demo_animating`, `is_unique_skill_presenting`, `is_manual_unique_skill_preview_pending`)이다.

| 모드 | 버튼 직후 | 대상 확정 직후 | 이후 |
|---|---|---|---|
| 수동 5모드(single_burst, team_buff로 확인) | (target_select, F, F, F) | (resolving, T, T, F) | (enemy_turn, T, F, F) → (ally_turn, F, F, F) |
| 자동 3모드(adjacent_aoe, retreat_counter, fear_aoe) | (target_select, **T**, F, **T**) | (대상 클릭 없음) | 미리보기 0.42초 → (resolving, T, T, F) → (enemy_turn …) → (ally_turn, F, F, F) |

- 매 프레임 추적 결과, **`is_unique_skill_presenting` 또는 미리보기 플래그가 켜져 있는데 `is_demo_animating`이 꺼진 프레임은 0개**였다(5개 스킬 × 전체 구간).
- 그래서 기존 `_input_locked()`의 `is_demo_animating` 검사가 미리보기·특기 연출을 모두 덮는다.
- 승인된 플래그 읽기(`is_unique_skill_presenting`)는 **입력 잠금에 쓰지 않았다**. 미리보기 플래그는 자동 모드 수락 확인에만 읽는다(§3).
- fear_aoe는 적이 모두 행동한 상태라 적 슬롯 없이 바로 ally_turn으로 돌아왔다.

### 2. 읽기 질의의 순수성 — 6개 모두 순수

- 조건: ally_turn과 unique_skill_target_select 두 phase에서 6개 질의를 각 5회 호출했다.
- 비교: 호출 전후 유닛 40필드 + 컨트롤러 12값 + 로그 5개(이동·행동·적·전술 이벤트 로그 + `battle_log_lines`) + 플래그 3개가 **같았다**. 난수 다음 값도 같았다.
- 대상 질의: `_can_use_unique_skill`, `_get_unique_skill_for_unit`, `_get_unique_skill_valid_targets`, `_should_unique_skill_resolve_without_manual_target`, `_is_valid_unique_skill_target`, `_get_unique_skill_remaining_cooldown_turns`
- 3D가 실제로 쓰는 것은 앞의 4개다. 뒤의 2개는 승인됐지만 필요 없어서 쓰지 않았다.
- `_get_unique_skill_for_unit`의 결과에 `display_name`("무쌍난무" 등)이 있다. 그래서 스킬 이름은 이 순수 질의로 얻는다(§3).

### 3. self_area / ally_area의 대상 클릭

- `_get_unique_skill_valid_targets`는 `BattleUnitState` 배열을 돌려준다. 칸이 아니다.
  - self_area(team_buff, guard_aura): 시전자 자신 + 반경 안 아군
  - ally_area(ally_focus_buff, rally_restore): 같은 모양(시전자 포함)
- 빈 칸(null)은 무효였다.
- **3D 규칙**: 클릭한 칸의 그리드 셀과 같은 셀에 있는 **엔진 유효 대상 유닛**을 보낸다. 시전자 자신의 칸도 유효하다(self_area). 유효 대상이 아닌 칸은 엔진 호출 0회로 거절한다.
- 엔진은 self 계열에서 실제 대상을 시전자로 바꾼다. 3D는 이를 계산하지 않고 엔진 결과(`skill_cast.target_id`)를 그대로 둔다.

### 4. 취소

- **대상 선택 중 우클릭**(`_handle_right_click_cancel`): phase가 ally_turn으로 돌아간다. 다음이 모두 그대로였다:
  - `has_acted` false
  - 기세 10 → 10
  - 유닛 40필드
  - 전술 로그 0개
- 엔진 로그는 "고유특기 취소 · 기세 미소비"였다.
- **자동 모드 미리보기 중**: 엔진에 직접 취소를 보내면 취소된다. 미리보기 중에도 phase가 target_select이기 때문이다.
- 그러나 이때 `is_demo_animating`이 켜져 있어서 **3D는 우클릭을 `_input_locked()`로 막고, 취소 호출을 보내지 않는다**. 3D에서 자동 모드 특기는 버튼을 누른 순간 확정된다.

### 5. 기세 읽기

- `engine.get("battle_momentum")`는 `BattleMomentumState` 객체이고, `get_value(side)`는 `clampi`만 하는 순수 읽기다.
- 3D는 `engine.get("battle_momentum").get_value("ally"|"enemy")` 형태로만 읽는다. `spend`, `gain`, `lose`, `reset`, `can_spend` 호출은 0이다(validator 고정).
- 더 안전한 방법은 찾지 못했다. 어댑터 14필드에는 기세가 없다.

### 6. 특기로 전투가 끝나는 경우 — 3D 잠금이 걸린다

- 적 4명을 fixture로 처치했고, 남은 적의 HP는 3이었다. 수동(single_burst)과 자동(adjacent_aoe) 둘 다 다음과 같았다:
  - 결과 `victory`, phase `ally_turn`
  - `enemy_action_event_log`에 `battle_ended(victory)` 1개
  - 이후 `_can_use_unique_skill` false
- 3D는 이 `battle_ended`로 `battle_result`를 정하므로 이 경로에서도 잠금이 걸린다.
- 거절 테스트의 "특기로 전투가 끝난 직후" 케이스에서 확인했다: 결과 오버레이, 버튼·클릭 거절, 쓰기 0, 월드맵 호출 0.
- 수정할 것은 없었다.

### 7. 상태 이름

- **스킬 리졸버의 status 명령 상태 id(21개)**:
  - `accuracy_down`, `action_lock`, `attack_defense_down`, `attack_defense_up`, `burn`, `counter_up`, `damage_reduction`
  - `defense_down`, `defense_up`, `fear`, `flank_damage_taken_up`, `flank_damage_up`, `formation_break`, `mobility_up`
  - `momentum_gain_down`, `momentum_gain_up`, `movement_down`, `rout_resist`, `siege_attack_up`, `skill_cost_up`, `status_resist`
- 출처:
  - `_command("status", …, "<id>")` 리터럴 48곳
  - `_buff_status_for_effect`, `_debuff_status_for_effect`
  - `_append_damage_secondary_commands`의 `status_id = "…"`
- 지시문의 "149개"는 데이터 전체를 펼친 명령 수로 보인다. 정적 추출로 얻은 id 집합은 위 21개다. 36케이스 실행에서 나온 id도 모두 이 안에 있었다.
- 엔진 표시 이름 함수:
  - `BattleUITextFormatHelper.format_unique_skill_status_display_name(id)` = 상수 사전 `UNIQUE_SKILL_STATUS_DISPLAY_NAMES` 조회. static이고 순수하다.
  - 모르는 id에는 "특수 상태"를 돌려준다.
- 3D `STATUS_TEXT`에 21개를 **엔진 사전과 같은 글자로** 넣었다. M4-b의 동요·혼란·화상은 그대로다.
- 모르는 id는 지시문대로 id 그대로 보인다. 엔진처럼 "특수 상태"로 바꾸지 않는다.
- validator가 3D 사전 값과 엔진 사전 값을 글자 단위로 비교하고, 리졸버의 status id가 모두 사전에 있는지도 확인한다.

### 8. 적 슬롯과의 순서

아군 single_debuff 뒤 적 슬롯이 이어질 때, 프레임별로 새로 쌓인 이벤트는 다음과 같았다:

| 프레임 | tactic_event_log | enemy_action_event_log |
|---|---|---|
| 0 | skill_cast(아군) | — |
| 64 | skill_effect ×2 | — |
| 169 | skill_finished(아군) | enemy_turn_started, enemy_actor_selected(+적 특기면 enemy_skill_used) |
| 227 | (적 특기) skill_cast(적) | — |
| 290 | (적 특기) skill_effect ×3 | — |
| 396 | (적 특기) skill_finished, status_tick, reinforcement_arrived ×2 | enemy_action_completed, round_started |

- 아군 `skill_finished`와 적 턴 시작이 **같은 프레임**에 쌓인다. 적 특기는 `enemy_skill_used`가 먼저 적 로그에 쌓이고, 그 뒤 전술 로그에 `skill_*`(side=enemy)가 쌓인다.
- 커서는 kind별 분기에서 시전자 진영이 적이면 아무것도 하지 않고 지나간다.
- 같은 프레임에 섞여 와도 멈추지 않는다(혼합 로그 테스트, 동등성 X 케이스).

---

## 1. 기능 상태

| 항목 | 상태 | 근거 |
|---|---|---|
| 3D [특기] → 엔진 `_on_unique_skill_button_pressed`(11번째 쓰기) | 동작 | 동등성 37케이스, 기본 배치 라운드, 캡처 2세트 |
| 대상 클릭 → 엔진 `_try_use_unique_skill_on_target`(12번째 쓰기, 수동 5모드만) | 동작 | 동등성: 자동 3모드는 대상 호출 0회, 수동은 1회 |
| 유효 대상 = 엔진 `_get_unique_skill_valid_targets` 그대로. 그 밖 클릭은 엔진 호출 0 | 동작 | 거절: 대상 밖 적·아군·빈 칸 |
| 자동 3모드: 버튼만 → 엔진 미리보기 → 발동. 그동안 입력·우클릭 잠금 | 동작 | 거절: 미리보기 중 버튼·클릭·우클릭 |
| 입력 잠금 + 공용 안내 + 기세 부족(엔진 값) + 유효 대상 없음 + 엔진 조건 | 동작 | 거절 테스트, 기본 배치(yi_sunsin "필요 4 / 현재 3") |
| 수락 확인(버튼: phase target_select, 자동 모드는 미리보기 플래그도 / 대상: `skill_cast` 증가) | 동작 | 엔진 거절(대상 선택 중 혼란이 된 시전자) |
| 표시 = `tactic_event_log` 값(시전·6가지 효과·종료) | 동작 | 동등성: 로그 줄·상태줄·Label3D·기세 HUD가 이벤트로 만든 기대 문자열과 같음 |
| 적 시전 `skill_*` 건너뜀 | 동작 | 동등성 X 케이스, 혼합 로그, 기본 배치 |
| 기세 HUD(재생 중에는 고정) | 동작 | 매 프레임 비교(재생 없을 때 == 엔진, 재생 중 == 재생 시작 시점 값) |
| 엔진·서비스·어댑터 diff | 0줄 | validator |
| 3D 난수·훅 사용 | 0 | validator |

## 2. UI 상태

- **[특기] 버튼**: [책략] 오른쪽 `Vector2(554,254)`에 있다. 핫키는 없다(M6). 비활성 사유는 툴팁에 나오고, 버튼을 눌러 거절되면 같은 문구가 상태줄에 나온다:
  - 공용 사유: 전투 종료 / 적 턴 / 연출 / 재생 / phase / 선택 없음 / 이미 행동함
  - "특기 불가 · 고유특기가 없는 부대입니다"
  - "특기 불가 · 기세가 부족합니다 (필요 N / 현재 M)": N은 엔진이 돌려준 스킬 데이터의 `momentum_cost`, M은 `get_value("ally")`
  - "특기 불가 · 유효 대상이 없습니다"
  - "특기 불가 · 엔진 조건을 충족하지 않습니다"(혼란 등)
- **대상 선택(수동 5모드)**: 엔진 유효 대상마다 보라 원판을 그린다. 범위·반경 표시는 하지 않았다. 엔진 범위 질의(`_get_unique_skill_range`)가 승인 목록에 없기 때문이다.
  - 상태줄: "특기 대상 선택 / 보라: 엔진 유효 대상 / 우클릭 취소"
- **자동 3모드**: 상태줄 "특기 발동 대기 · 엔진이 대상을 정해 발동합니다 / 입력 잠금"
- **표시**(모두 이벤트 값):
  - 시전: 시전자 위 스킬 이름 라벨. 로그·상태줄 "특기 · <시전자> · <이름> (기세 −<momentum_cost>)"
  - 피해: 대상 위 "−N"(처치면 아래 줄 "격파"). 로그 "특기 피해 · <대상> −N[ · 격파][ · <피해 플래그 id>]"
  - 회복: "+N". 상태: "<이름> <turns_after>턴". 해제: "<이름> 해제"
  - 기세: HUD 옆 " · 아군 기세 +1" 형태. 로그 "특기 기세 · …"
  - 이동: 로그 "특기 이동 · <대상> 이동 (x, y) → (x, y)". 모델은 엔진 셀을 따라간다.
  - 종료: "특기 종료 · <시전자>"(쿨다운이 0이 아니면 " · 쿨다운 N턴")
- **기세 HUD**: 위쪽 턴 줄 아래 "기세 아군 N / 적 M". 적 재생 큐가 빌 때만 엔진 값으로 갱신한다(M4-b 배지와 같은 규칙).
- 알려진 표시 한계:
  - 기본 카메라에서 3D 떠오름 라벨이 작다(캡처 03·04). 같은 유닛에 효과가 여러 개면 라벨이 같은 위치에 겹친다. 순서는 로그·상태줄로 읽을 수 있다.
  - 비활성 버튼은 실제 창에서 눌러도 신호가 나가지 않는다. 그래서 캡처의 "거절 버튼 누름"은 상태줄이 바뀌지 않는다. 사유는 툴팁에 있다. 헤드리스 테스트는 `pressed`를 직접 내보내 거절 문구까지 확인한다.

## 3. 실제 조작 증거

- **실제 Godot 창 캡처 2세트. 뷰포트 입력 주입(`root.push_input`)이며 사람 조작이 아니다.**
  - 비헤드리스 `--resolution 1280x800`, 일반 랩 씬·호스트(spy 없음)
  - 드라이버: zip `evidence/m4c1_capture/capture_driver.gd`(커밋 안 함). 원문 로그: `manual/run.log`, `auto/run.log`
- **수동 세트(fixture 없음, 기본 배치 라운드 1)**: yi_sunsin 선택(특기 비활성 "필요 4 / 현재 3") → 대기 → jeong_dojeon [특기] → 보라 표식 2개(jeong_dojeon, gwon_yul) → 엔진 최적 대상 칸 클릭 → 개혁령 → 적 재생 → gwon_yul 대기 → 라운드 2
- **자동 세트**: 기본 배치에는 자동 3모드 특기를 가진 아군이 없다(yi_sunsin enemy_area, jeong_dojeon·gwon_yul self_area).
  - 그래서 **증거용 fixture 1개**만 넣었다: gwon_yul의 `unique_skill_definition`을 `shimazu_yoshihiro_unique`(target_mode `self`, 비용 1)로 바꿨다. 나머지는 기본 배치 그대로다.
  - yi_sunsin·jeong_dojeon 대기 → gwon_yul [특기]만 누름 → 엔진 미리보기(입력 잠금) → 귀석만자(이동 (4,6)→(3,6) + 반격 강화 2턴) → 적 재생 → 라운드 2

| 캡처 | 수동 | 자동 |
|---|---|---|
| 00 | yi_sunsin, 특기 비활성(기세 부족) | 같음 |
| 01 | jeong_dojeon 특기 활성 | gwon_yul 특기 활성 |
| 02 | 대상 선택: 보라 표식 | 버튼만 누른 뒤 엔진 미리보기, 입력 잠금 |
| 03 | 시전 라벨 "개혁령", 기세 3→0 | 시전 라벨 "귀석만자", 기세 3→2 |
| 04 | 상태 라벨 2개 + "아군 기세 +1"(적 턴 시작) | 이동·"반격 강화 2턴" 라벨 |
| 05 | 적 재생 중(기세 HUD 고정) | 적 재생 중 |
| 06 | 엔진 라운드 2(3D는 아직 라운드 1 마지막 적 슬롯 재생) | 같음 |

- 캡처 06은 엔진이 라운드 2가 된 직후에 찍혔다. 3D는 아직 라운드 1 마지막 슬롯을 재생 중이었다(M3부터 있는 재생 지연, M4-b 보고서와 같은 현상).

## 4. 남은 연결

- **적 특기 재생(M4-c2)**: 적 시전 `skill_*`는 지금은 건너뛴다. 적 특기의 결과는 기존 M3 상태 차이 요약으로만 보인다.
- 하지 않은 것:
  - 특기별 전용 FX·카메라·컷인(엔진 연출)
  - 핫키(M6)
  - 쿨다운 UI(데이터가 모두 0)
  - 이어하기 버프 유실(B-1H)
- 특기 범위·반경 원판은 엔진 범위 질의 승인이 있으면 붙일 수 있다.

## 5. 결정 사항 (질문 대신 보수적으로 정한 것)

| 항목 | 결정 | 이유 |
|---|---|---|
| 입력 잠금 | `_input_locked()` 수정 없음. 특기 연출 플래그를 잠금에 추가하지 않음 | 사전 확인 1: 연출·미리보기 플래그는 항상 `is_demo_animating`과 함께 켜진다 |
| 스킬 표시 이름 | 시전자의 `_get_unique_skill_for_unit` 결과의 `skill_id`가 이벤트와 같으면 그 `display_name`, 아니면 `skill_id` 그대로 | 승인된 순수 질의로 얻을 수 있는 경우만(지시문 §3) |
| 기세 부족 사유 | 스킬 데이터 `momentum_cost`(엔진이 돌려준 값) < `get_value("ally")` 비교로 안내만. 실제 판정은 엔진 | 3D는 비용을 계산하지 않는다. `skill_cost_up` 상태로 실효 비용이 커진 경우는 "엔진 조건" 사유로 나온다(`_get_effective_unique_skill_cost`는 승인 목록에 없음) |
| 안내 순서 | 공용 → 특기 없음 → 기세 → 유효 대상 → 엔진 조건 | `_can_use_unique_skill`이 기세·대상을 모두 포함하므로, 구체 사유를 먼저 보여 준다 |
| 대상 수락 확인 | `skill_cast` 증가만 | phase 이탈만으로는 엔진 취소(ally_turn 복귀)와 구별되지 않는다. 확정은 대상 호출 안에서 동기적으로 기록된다 |
| 자동 모드 수락 확인 | phase target_select + 미리보기 플래그 | 버튼 뒤 엔진이 바로 미리보기를 시작한다(사전 확인 1). 승인된 플래그 읽기 |
| 해제 표시 | `cleanse`의 `status_id`를 상태 이름으로 표시("화상 해제"), 모르는 id는 id 그대로 | 지시문 "상태 이름" 규칙과 M4-b 만료 표시 방식에 맞춤 |
| 피해 플래그 | 로그 줄 끝에 id 그대로(`advance_on_kill` 등) | 지시문 그대로 |
| 기세 HUD 갱신 | 재생 큐가 빌 때만 엔진 값으로 | 지시문(M4-b 배지 규칙). 아군 특기 중에는 재생이 없어 즉시 갱신된다 |
| 기세 효과 표시 | 마지막 아군 특기의 momentum 효과를 HUD 옆에 두고, 다음 아군 시전 때 지움 | 이벤트 값 그대로. 3D가 HUD 숫자를 더하거나 빼지 않는다 |
| 라벨 위치 | 대상 모델 위 고정 높이. 쌓기 오프셋 없음 | 오프셋 계산에 곱셈이 필요해 지시문 금지(곱셈은 `_rate_text`만)와 충돌 |
| 기세 HUD 위치 | `turn_label.position + Vector2(0,34)` | 같은 이유로 `size.x*.5`를 새로 쓰지 않았다 |
| 자동 모드 캡처 | gwon_yul 스킬을 `self` 모드로 바꾼 증거용 fixture 1개 | 기본 배치에는 자동 3모드 특기를 가진 아군이 없다 |
| 기존 테스트 숫자 단언 예외 | 쓰지 않음 | 기존 spy는 특기 호출을 기록하지 않고, 기존 테스트는 특기 버튼을 누르지 않는다. 기존 테스트 변경 없이 전체 CI 통과 |

## 6. 변경 파일

| 파일 | 변경 | 내용 |
|---|---|---|
| `scripts/battle3d/battle3d_engine_play.gd` | +201 −4 | 새 함수 14개 + 멤버 8개, `STATUS_TEXT` 21개 추가. 바뀐 공용 함수: `_build_ui`(도움말 1줄), `_build_attack_ui`(버튼), `_build_turn_ui`(HUD), `_sync_views`(버튼 상태·표식 정리), `_refresh_turn_ui`(HUD 2줄), `_click_world`(분기 3줄), `_consume_tactic_events`(kind 1줄 + 필터 1줄) |
| `.github/workflows/verify-c-track.yml` | +8 | validator 1개, 테스트 7개 |
| `tools/validate_battle3d_m4c1_skill.py` | 신규 | BASE `4e0b034`, TIP 기본 `HEAD`(`M4C1_SCOPE_TIP`) |
| `tests/scripts/support/battle3d_skill_harness.gd` | 신규 | M4-b 하니스 확장(spy에 특기 2호출, S4-1 보드 fixture, 기대 표시 문자열 생성) |
| `tests/scripts/test_battle3d_skill_equivalence.gd` + `_shard_1~4` | 신규 | 본체는 CI에 넣지 않고 샤드 4개만 넣는다(M3 방식) |
| `tests/scripts/test_battle3d_skill_{default_round,rejections,mixed_log}.gd` | 신규 | |
| `.gd.uid` 9개 | 신규 | import 사이드카 |
| `agent/BATTLE3D_M4C1_RESULT_20261022.md` | 신규 | 이 보고서 |

## 7. 테스트 (CI 편입)

### 7-1. 케이스 목록 — 36종 × target_mode 8종 × effect_kind 6종

effect_type마다 데이터 순서 첫 특기를 쓴다(S4-1 오라클 규칙). 판은 S4-1 K_ 케이스 fixture와 같다(기세 아군 10, 적 6. K_retreat_counter는 후퇴 칸 비움, K_rally_restore는 부상·상태).

| target_mode | 케이스 (effect_type) | 나온 effect_kind |
|---|---|---|
| `self_area` (14) | guard_aura, mounted_team_buff, naval_team_buff, stance_team_buff, team_action_buff, team_buff, team_command, team_guard, team_logistics, team_mobility_buff, team_morale, team_support | status, momentum |
| `single_enemy` (13) | charge_damage, command_debuff, flank_debuff_attack, prediction_debuff, single_burst, single_debuff, single_ranged_damage, skill_cost_debuff, splash_charge (+X_enemy_skill_in_slot) | damage, status, momentum |
| `enemy_area` (8) | aoe_damage_debuff, aoe_debuff, charge_aoe, control_field, encirclement_debuff, fire_aoe, trap_aoe | damage, status, momentum |
| `enemy_line` (4) | charge_line, gunner_volley, line_damage | damage, status, momentum |
| `ally_area` (2) | ally_focus_buff, rally_restore | status, momentum, **heal, cleanse** |
| `enemy_adjacent` (1) | adjacent_aoe | damage, momentum |
| `self_area_enemy` (1) | fear_aoe | status |
| `self` (1) | retreat_counter | **move**, status |

- 괄호 안 숫자는 데이터 44개 기준 개수다. 36케이스 안에 **8개 모드가 모두** 있다.
- **6가지 effect_kind가 모두 실제로 나왔다**:
  - damage: single_burst 등 13케이스
  - heal·cleanse: rally_restore
  - status: 다수
  - momentum: 다수
  - move: retreat_counter
- `killed`(격파 표시)는 거절 테스트의 "특기 승리" 케이스에서 나왔다.
- 샤드 나누기: 1 = 0–9(10케이스), 2 = 10–18, 3 = 19–27, 4 = 28–36(X 포함). 개발 실행 시간은 72·60·61·63초다.

### 7-2. 테스트 표

| 테스트 | 내용 | checks |
|---|---|---|
| `test_battle3d_skill_equivalence_shard_1~4` | 위 37케이스. **3D 입력**(시전자 클릭 → [특기] → 엔진 최적 대상 칸 클릭, 자동 모드는 버튼만)과 **엔진 직접 호출**을 비교. 아래 "동등성 비교 항목" 참조 | 428/385/388/390 (+표시 비교 약 44,000, 기세 비교 약 7,000) |
| `test_battle3d_skill_default_round` | 기본 배치, fixture 없음(골든 시작). 라운드 1: yi_sunsin 기세 부족 거절(쓰기 0) 후 대기 → jeong_dojeon 특기(self_area, 대상 클릭) → gwon_yul 대기 → 적 재생 → 라운드 2. 직접 경로와 같음(유닛·컨트롤러·로그 4개·쓰기·재생 경로·요약 수·표시·HUD) | 36 |
| `test_battle3d_skill_rejections` | 아래 "거절 케이스" 참조 | 104 |
| `test_battle3d_skill_mixed_log` | 라운드 1에 엔진 직접 책략, 적 특기, 상태 틱, 증원 이벤트가 쌓인 뒤 라운드 2에 3D 특기(라운드 2에도 적 특기). 확인: 아군 skill_*만 특기로 표시, 다른 kind는 각자 표시 유지, 네 커서 독립 | 14 |

**동등성 비교 항목**:
- 유닛 40필드×10, 컨트롤러 12값, 기존 로그 3개(M3 `check_case`: 재생 경로·피격·요약·라운드·결과 포함)
- `tactic_event_log`, 쓰기 순서, 12개 명령 안
- 대상 표식 == 엔진 유효 대상
- 아군 skill_* 이벤트가 정확히 한 번씩 순서대로 표시됨(적 시전 제외)
- 상태줄·로그 줄 == 이벤트로 만든 기대 문자열(테스트가 따로 만들고, 상태 이름은 엔진 헬퍼에서 얻음)
- **Label3D 떠오름 텍스트**: 매 프레임 실제 노드 텍스트를 수집해 기대 집합과 비교
- 기세 HUD: 최종값 + 매 프레임(재생 없을 때 == 엔진, 재생 중 == 재생 시작 값)
- 배지 상태 == 엔진(M4-b 프로브 재사용)

**거절 케이스**(모두 엔진 쓰기 0 확인):
- 연타(두 번째 대상 클릭), 특기 연출 중 버튼·우클릭, 미리보기 중 버튼·클릭·우클릭(취소 호출 없음), 적 턴 중, 재생 큐 중
- 이미 행동, 선택 없음, 기세 부족("필요 3 / 현재 1"), 유효 대상 없음, 혼란 아군(엔진 조건)
- 대상 밖 적·아군·빈 칸 클릭
- 대상 선택 중 우클릭 취소: 취소 호출만 보내고 기세·행동·로그가 그대로
- 엔진 거절: 대상 선택 중 혼란이 된 시전자
- 승리 후, 패배 후
- **특기로 전투가 끝난 직후**: 오버레이, 버튼·클릭 거절, 월드맵 0
- 격리: 새 랩에 잔여물 없음, HUD "기세 아군 3 / 적 3", 노드 누수 없음

- 이번 테스트에는 주사위 훅이 필요 없다. 특기는 난수를 쓰지 않는다. 혼합 로그의 책략만 테스트 코드에서 훅으로 강제했다.
- 지시문 §4-7의 격리("연속 실행 오염 없음")는 다음으로 확인했다:
  - 거절 테스트의 격리 단계
  - 샤드 안에서 케이스 10개를 연속 실행하며, 매 케이스 새 랩·새 엔진에서 같은 직접 경로 결과와 같음

## 8. validator `tools/validate_battle3d_m4c1_skill.py`

**범위·보호**:
- 변경 파일 화이트리스트, 엔진·서비스·어댑터 diff 0
- 보호 파일 바이트: 엔진·어댑터·호스트·S4-1 서비스·**스킬 리졸버·상태 이름 헬퍼**·기존 하니스 8개·기존 M4-b/M4-d/M3 테스트·기존 validator 11개
- 골든 5개 SHA-256, 워크플로 추가만(정확히 8줄)

**호출·읽기 경계**:
- **쓰기 호출 정확히 12개**. 대기·방어·책략 2·특기 2는 각 1곳. 동적 호출 없음
- 읽기 호출 = M4-b 6개 + 특기 질의 4개(승인 6개 중 사용분)
- 읽기 프로퍼티 = M4-b 9개 + `battle_momentum`·`is_manual_unique_skill_preview_pending`. `battle_momentum`은 반드시 `.get_value(`로만 쓴다
- `scripts/battle3d/**`: 훅 언급 0, 난수 0
- 금지 호출: 시퀀스·자동·리졸버·확정·비용·범위·쿨다운 설정·기세 변경(`spend/gain/lose/reset`)·월드맵·결과·증원·책략 내부
- 규칙 토큰 0(`power`, `radius`, `skill_cost_up`, `MAX_MOMENTUM` 등. 상태 이름표의 키는 제외)
- 유닛·엔진 상태 쓰기 0, 새 곱셈 0

**함수·이름표**:
- 새 함수 14개 정확, 바뀐 공용 함수 7개 이내, 새 멤버 8개 정확
- **상태 이름표**: 3D 값 == 엔진 사전 값(글자 단위), M4-b 3개 유지, 리졸버 status id가 모두 이름표에 있음

**버튼·대상 클릭**:
- `request_skill`: 무조건 잠금 → 안내 → 버튼 호출 → phase/미리보기 수락 확인이 표식보다 먼저
- 안내 순서 고정, 기세 문구 인자 고정, 비용 산술 없음
- `_click_skill_cell`: 엔진 대상 질의 → 호출 전 거절 → `skill_cast` 증가 확인이 표식 정리보다 먼저
- 클릭 분기는 `_input_locked()` 뒤에 있고, 버튼만 쓴다(핫키 없음)

**네 번째 커서**:
- 처리 kind 목록이 정확히 6개(strategy_cast, status_tick, reinforcement_arrived, skill_cast, skill_effect, skill_finished)이고 나머지는 `_: pass`
- 특기 3 kind 분기에 시전자 진영 필터 줄이 고정. `_present_skill_event` 호출은 그 한 곳뿐
- 진영은 어댑터 `side`로 판별. 커서는 증가만 하고, 다른 커서를 참조하지 않음

**표시**:
- 시전·종료·효과 6개 분기
- 표시 값은 `event.*`에서만. 산술·상태 읽기·숫자 상수 인자 없음
- 떠오름 라벨 5줄 고정(텍스트·인자)
- 기세 효과 부호는 `%+d` + `event.amount`
- 기세 HUD는 엔진 `get_value`에서만, 재생 큐가 빌 때만 대입

## 9. 변조 프로브 (새로 돌린 것, 19개)

- 방식: 3D 파일에 변조를 1개씩 적용하고 validator와 Godot 테스트를 돌린 뒤 원래 바이트로 복원했다(`cmp` 확인).
- 러너: zip `evidence/run_m4c1_probes.py`. 결과: `evidence/m4c1_probes_final/`. Godot 실패는 모두 parse 오류 없는 단언 실패였다.

| 지시문 §4-9 예 | 프로브 | validator | Godot 테스트 |
|---|---|---|---|
| 특기 버튼 입력 잠금 제거 | P1(`_input_locked()`만 제거) | exit 1 | **exit 0(못 잡음)** |
| 전투 종료 후 특기 허용 | P2(종료 시 잠금·공용 안내 우회) | exit 1 | exit 1 (거절) |
| 대상 확정 두 번 전송 | P3 | exit 1 | exit 1 (동등성: 쓰기 순서) |
| 기세 비용을 3D가 계산해 표시 | P4(`cost+1`) | exit 1 | exit 1 (기본 배치, 거절) |
| 수락 확인 제거 | P5(대상 수락 확인 삭제) | exit 1 | exit 1 (거절: 엔진 거절이 성공처럼 보임) |
| 피해 라벨 숫자 변조 | P6(`amount+1`) | exit 1 | exit 1 (동등성: **Label3D 텍스트**) |
| 회복 라벨 변조 | P7a(부호 −) | exit 1 * | exit 1 (동등성 rally_restore) |
| 상태 라벨 변조 | P7b(`turns_after` → `turns`) | exit 1 | **exit 0(못 잡음)** |
| 해제 라벨 변조 | P7c(이름 대신 raw id) | exit 1 * | exit 1 (동등성 rally_restore) |
| 기세 HUD를 3D가 직접 증감 | P8(초기화 후 효과로 가감) | exit 1 | exit 1 (동등성: HUD ≠ 엔진) |
| 〃 재생 중 최종값 노출 | P8b(재생 큐 조건 제거) | exit 1 | exit 1 ** (동등성 single_burst). 기본 배치는 exit 0 |
| 적 시전자 이벤트를 아군처럼 표시 | P9(`event.side` 기본값 ally) | exit 1 | exit 1 (동등성 X, 혼합 로그) |
| 시전자 진영 필터 제거 | P10 | exit 1 | exit 1 (동등성 X, 혼합 로그) |
| 다른 kind에서 멈춤 | P11(`_: break`) | exit 1 | **exit 0(못 잡음)** |
| 〃 커서가 멈춤 | P11b(`tactic_cursor -= 1; break`) | exit 1 | **exit 0(못 잡음)** |
| 상태 이름 사전 변조 | P12(`movement_down` 이름) | exit 1 | exit 1 (동등성 trap_aoe: 엔진 헬퍼 이름과 다름) |
| 연출 중 입력 잠금 제거 | P13(`is_demo_animating` 잠금 삭제) | exit 1 | exit 1 (거절: 연출 중 클릭 사유) |
| (추가) 버튼 수락 확인 제거 | P14 | exit 1 | **exit 0(못 잡음)** |
| (추가) 3D가 `randf` 호출 | P15 | exit 1 | **exit 0(못 잡음)** |

**1차 실행에서 보강한 것**:
- \* P7a·P7c는 **1차 실행에서 validator가 못 잡았다**(exit 0). validator에 "떠오름 라벨 5줄 정확 고정"을 넣었고 최종 실행에서 잡혔다.
- \*\* P8b는 **1차 실행에서 테스트가 못 잡았다**. 하니스 매 프레임 검사에 "재생 중 HUD == 재생 시작 시점 값"을 넣었고 최종 실행에서 동등성이 잡았다.
- 1차 원문은 `evidence/m4c1_probes_run1/`이다. 최종 표는 보강 후 19개 전부를 다시 돌린 결과다.

**테스트가 못 잡는 것(숨기지 않음)**:
- P1: 공용 안내(`_ally_command_block_reason`)가 같은 조건·같은 문구("연출 중 …")로 막는다. M4-b P13과 같은 구조다.
- P7b: 이번 케이스들에서는 `turns`와 `turns_after`가 항상 같았다. 기존 상태보다 짧은 턴을 다시 거는 fixture가 없다.
- P11·P11b: **이제 전술 로그 서비스가 낼 수 있는 kind 6개를 모두 처리하므로 `_:` 분기에 닿는 이벤트가 없다.** 서비스는 모르는 kind를 거부하므로, 테스트로 만들 수도 없다. validator만 잡는다.
- P14: 버튼 전 안내가 엔진 조건을 먼저 확인해서, 엔진이 버튼을 거부하는 상황을 만들 수 없다.
- P15: 특기 경로에는 난수 판정이 없어 결과에 닿지 않는다.
- P8b 기본 배치: 적 슬롯이 대기·이동만 해서 재생 중 기세가 바뀌지 않는다.

**대조군**: validator와 동등성 single_burst, 기본 배치, 거절, 혼합 로그 모두 exit 0.

## 10. 전체 CI 로컬 재현 (새로 돌린 것, 1회)

- 기준: 최종 코드(커밋 직전 작업 트리, 보고서만 자리표시)
- 순서:
  1. `.godot` 삭제
  2. `--headless --editor --import`: **1회 만에 exit 0, 52초, signal 11 없음**
  3. `verify-c-track.yml` 목록 그대로 실행. 러너 `run_ci.py`, zip `evidence/run_ci.py`
- **147단계 모두 exit 0**(합계 약 1,616초):
  - validator **40** = 기준 39 + M4-c1 1
  - Godot 테스트 **102** = 기준 95 + M4-c1 7
  - 씬 로드 3개, `--editor --quit-after 2`, `git diff --check`
- M4-c1 테스트 시간:
  - 동등성 샤드 1~4: 69.9 / 58.1 / 59.2 / 61.4초(CI 파일당 120초 제한 안)
  - 기본 배치 22.8초, 거절 23.8초, 혼합 로그 8.9초
- 기존 테스트는 수정 없이 통과했다:
  - M1~M4-d 3D 테스트(M4-b 혼합 로그·기본 배치의 "다른 kind 건너뜀" 단언 포함)
  - S4-1 오라클·의미 테스트
- 실행 후 `git status`에는 이번 변경 파일만 있었다. 로그는 zip `evidence/m4c1_ci_full_run/`.
- 참고: CI 러너 `checks` 열은 마지막 `checks=` 숫자를 잡는다. 그래서 동등성 칸에는 단언 수(428 등)가 들어 있다. 표시 비교 수는 로그 본문에 있다.

## 11. 새로 돌린 것 / 재사용

- **새로 돌린 것**:
  - 사전 확인 스크립트 1개
  - 신규 테스트 개발 실행, 샤드 4개 시간 측정
  - 변조 프로브 2회(1차, 최종)
  - 실제 창 캡처 2세트
  - fresh import, 전체 CI 1회
  - 커밋 후 validator 고정 모드 1회
- **재사용(코드)**:
  - M4-b 하니스(StrategySpyBattle·열기/정착·배지 프로브)
  - S4-1 오라클 보드·스킬 선택 규칙
  - M3 `check_case`
  - M4-b/M4-d 캡처·프로브 러너 구조
  - CI 러너 `run_ci.py`(변경 없음)

## 12. 남은 위험

- P1·P7b·P11·P11b·P14·P15는 테스트로 못 잡는다(validator만 잡는다).
- 사람이 직접 조작한 캡처가 없다. 자동 모드 캡처는 증거용 fixture 1개를 썼다.
- 실효 비용(`skill_cost_up`)이 데이터 비용보다 클 때 3D 안내는 "엔진 조건" 사유로 나온다. 실제 판정은 엔진이 한다.
- 라벨이 작고, 같은 대상의 효과 라벨이 겹친다(M6 UI 정리 때).
- 적 특기 결과의 이벤트 기반 표시는 M4-c2 범위다.
