# BATTLE3D M5-c 결과 — 전투 화면 옵션창(적 AI 하/중/상) (2026-10-23 밤샘 ③ 단계 ④)

- 작업 ID: M5-c. 지시문 `NIGHT3_STACK_20261023.md` §6, 설계서 `DESIGN_S4_AI_LEVEL_AND_BATTLE_SETUP_20261022.md` §0·§1·§3·§5, 공통 3D 규칙 `NIGHT2_M5A_M4C2_M5B_20261022.md` §0
- 브랜치 `feature/night3-stack-20261023`(스택). BASE = 직전 커밋 `63b08fe`(M5-b 뒤 3D validator 수정 커밋. M5-b `f221609` 바로 다음)
- 이 단계 커밋 1개: `feat(battle3d): add the enemy AI level option panel (M5-c)`. 작성자·커미터 `noreply@anthropic.com`. 푸시 안 함.
- 합격 판정은 하지 않는다(검수: 클코치).
- **멈춤 규칙에 걸리지 않았다**:
  - 엔진·서비스·어댑터·셸 diff 0
  - 쓰기는 승인된 15번째 `set_enemy_ai_level` 하나(호출 지점 1곳)
  - 읽기는 승인된 2개(`get_enemy_ai_level`, `get_pending_enemy_ai_level`)
  - 기존 테스트·하니스·골든 수정 0, 새 난수 0
- **최종 상태 동등성 성립**: 3D에서 [중] → [자동](4x)로 끝까지 간 결과가 엔진에 `set_enemy_ai_level("mid")` → 자동을 직접 한 결과와 같다. 적 특기 순서도 S4-2c "상한+돌려쓰기" 측정과 같다(장비·하후돈·장비·관우·하후돈×3, 라운드 8 패배).

## 0. 사전 확인

1. **엔진 함수**(S4-3)
   - `set_enemy_ai_level(level) -> bool`: 잘못된 값이면 false, 맞으면 대기 값
   - `get_enemy_ai_level()`: 기본 `"low"`
   - `get_pending_enemy_ai_level()`: 없으면 `""`
   - 적용은 다음 적 턴(적 슬롯) 시작이다. 적 턴 중·자동 중에도 부를 수 있다.
2. **패널 위치**: 화면 오른쪽 위(x = 화면폭 − 230, y = 16, 폭 210)
   - 기존 명령 줄(y = 254, 자동·속도 y = 300), 가운데 라운드 머리말(폭 520), 왼쪽 정보창, 오른쪽 아래 부대 명단과 겹치지 않는다(캡처 확인).
3. **패널 클릭이 전장으로 새는지**
   - Godot GUI 버튼이 클릭을 받으면 `_unhandled_input`(전장 클릭)으로 가지 않는다.
   - 실제 입력 주입(`push_input`)으로 확인했다: 엔진 쓰기는 `set_enemy_ai_level` 하나뿐이고, 선택 부대는 그대로다.

## 1. 변경 (`scripts/battle3d/battle3d_engine_play.gd`만)

- 멤버: `AI_LEVEL_ORDER`, `AI_LEVEL_TEXT {low:하, mid:중, high:상}`, `option_toggle`, `option_panel`, `ai_level_label`, `ai_level_buttons`, `ai_level_texts`
- 새 함수:
  - `_build_option_ui()`: 별도 `CanvasLayer`에 [옵션 ▾] 접기 버튼 + 패널(현재 등급 라벨 + [하][중][상])
  - `toggle_option_panel()`: 접기/펴기. 표시만 바꾸고 엔진 호출은 없다.
  - `request_ai_level(level)`:
    - `ready_for_input`만 확인한다(`_input_locked` 없음: 적 턴·자동·입력 잠금 중에도 됨).
    - `engine.call("set_enemy_ai_level", level)`을 부른다(**쓰기 15번째, 호출 지점 1곳**).
    - false면 "적 AI 변경 거절 · 엔진이 X 등급을 받지 않았습니다"를 보인다.
  - `_refresh_option_ui()`: 엔진 `get_enemy_ai_level` / `get_pending_enemy_ai_level`을 읽는다.
    - 라벨: "적 AI: 하" 또는 "적 AI: 하 → 중 (다음 적 턴부터 적용)"
    - 버튼 눌림 표시 = 대기 값(없으면 현재 값)
  - `_ai_level_text(line)`: 기록 + 전투 줄 + 상태줄
- 공용 함수 변경(각 한 줄): `_ready`에 `_build_option_ui()`, `_sync_views`에 `_refresh_option_ui()`
- 3D는 등급 규칙(어느 플래그가 켜지는지)을 계산하지 않는다. 플래그 이름을 읽거나 쓰지 않고, validator가 금지한다.
- "상"은 엔진 값 그대로 "상"으로 표시한다("준비 중" 같은 문구를 붙이지 않음, 지시대로).

## 2. 테스트 (CI 편입 2개 + 하니스 1)

| 파일 | 내용 | checks |
|---|---|---|
| `support/battle3d_option_harness.gd` | M5-a2 관찰 호스트 확장. `set_enemy_ai_level`을 쓰기 목록에 기록, 강제 거절 스위치, 적 턴 시작 전/후 플래그와 적 행동 끝 플래그 기록, 실제 GUI 클릭(`push_input`) | |
| `test_battle3d_option_ai_level` | 아래 목록 | 29 |
| `test_battle3d_option_ai_level_auto` | 3D [중](실제 클릭) → [자동] 4x 끝까지 == 엔진 `set_enemy_ai_level("mid")` → 자동(3D 없음). 최종 유닛·컨트롤러·로그 4개·라운드 2/3 스냅샷·쓰기 순서 | 9 |

`test_battle3d_option_ai_level` 확인 항목:
- 기본 표시 "적 AI: 하", 버튼 하/중/상, [하] 눌림
- [중] 클릭 → 엔진 대기 값 mid, 라벨 "적 AI: 하 → 중 (다음 적 턴부터 적용)", 선택 문구
- 그 클릭으로 늘어난 엔진 쓰기는 `set_enemy_ai_level` 하나뿐이고 선택 부대는 그대로(전장으로 새지 않음)
- [옵션 ▾] 접기/펴기: 엔진 쓰기 0
- 3D [대기] → 적 턴 시작에서 반영(전 플래그 F,F,F → 후 T,T,T), 라벨 "적 AI: 중", [중] 눌림
- 적 행동 중 [하] → 대기 값 low. 그 적 행동은 끝까지 중 플래그(T,T,T), 다음 적 턴에 하(F,F,T = 상한만)
- 강제 거절 → 거절 문구, 대기 값 그대로
- 자동 중(입력 잠금) [상] → 받아들여짐, 라벨 "적 AI: 하 → 상 (다음 적 턴부터 적용)"
- 모든 쓰기가 15개 안
- 라벨 기대 문자열은 하니스가 엔진 값으로 따로 만든다.

## 3. 변조 프로브 (12개)

- 방식: `battle3d_engine_play.gd`에 변조를 1개씩 적용하고 M5-c validator와 패널 테스트를 돌린 뒤 원래 바이트로 복원했다(`cmp` 확인 `RESTORED_OK`).
- 러너 `evidence/run_m5c_probes.py`, 결과 `evidence/m5c_probes_run1/`
- 대조군: 둘 다 exit 0.

| # | 변조 | validator | 테스트 |
|---|---|---|---|
| P1 | 등급 명령을 보내지 않음 | 잡음 | 잡음 |
| P2 | 두 번째 호출 지점(`_sync_views`에서 적 턴 중 상으로 설정) | 잡음 | 잡음 |
| P3 | 대기 값을 엔진에서 읽지 않음 | 잡음 | 잡음 |
| P4 | 입력 잠금 중 거절(`_input_locked`) | 잡음 | 잡음 |
| P5 | 거절 문구 없음 | 잡음 | 잡음 |
| P6 | 등급 이름 틀림(중 → 상) | 잡음 | 잡음 |
| P7 | 패널 갱신 안 함(`_sync_views` 줄 제거) | 잡음 | 잡음 |
| P8 | 접기 버튼이 엔진 쓰기 | 잡음 | 잡음 |
| P9 | 패널 클릭이 전장 클릭으로 샘(`_click_world` 호출) | **못 잡음** | 잡음 |
| P10 | 등급 명령 두 번 | 잡음 | 잡음 |
| P11 | 패널을 명령 줄 위치(600,300)로 | 잡음 | **못 잡음** |
| P12 | 버튼 눌림 표시를 엔진 값에서 안 함 | **못 잡음** | 잡음 |

- validator 10/12, 테스트 11/12. 둘 다 못 잡은 것은 없다.
- 못 잡는 이유:
  - P9: `_click_world`는 기존 함수라 validator가 호출 목록을 보지 않는다.
  - P11: 테스트는 위치를 보지 않는다(validator가 위치 줄을 고정).
  - P12: 표시 줄을 지워도 validator의 고정 문구 검사 대상이 아니다.

## 4. CI

- 범위: **영향받는 것만**. `verify-c-track.yml`의 validator 49개 전부 + 테스트 11개를 돌렸다. 3D 전체는 마지막 단계의 전체 CI가 덮는다.
  - 테스트 11개: 새 2개 + M5-a 자동 동등성 seed 1·중지, M5-a2 hold seed 1·release, M5-b start·defeat, 대기·책략·특기 거절
- 순서: 러너 `run_ci_subset.py`(테스트 이름 필터)
- **60단계 모두 exit 0**:

  | 항목 | 시간 |
  |---|---|
  | 옵션 패널 | 10.4초 |
  | 중 등급 자동 동등성 | 45.2초 |
  | 기존 자동 동등성 seed 1 | 52.2초 |
  | hold seed 1 | 52.2초 |
  | 패배 완주 | 39.6초 |

- 실행 전후 `git status`가 같다.
- 커밋 뒤 validator 50개(새 1개 포함)를 다시 돌렸다. 결과는 아래 줄에 있다.
- 원문: zip `evidence/m5c_ci_subset/`

## 5. 결정 사항

| 항목 | 결정 | 이유 |
|---|---|---|
| 읽기 수 "M5-a 12 + 2" | 읽기 **속성** 12개 그대로 + 새 읽기 **호출** 2개 | 두 함수는 `engine.call`로 읽는 함수다. 속성 목록은 늘리지 않았다 |
| 입력 잠금 | 패널은 `_input_locked`를 쓰지 않음 | 지시 "입력 잠금 중에도 이 패널은 눌러도 된다(엔진이 받음)" |
| 버튼 표시 | `toggle_mode` 버튼, 눌림 = 엔진 대기 값(없으면 현재 값), 매 갱신마다 엔진 값으로 다시 맞춤 | 사용자가 누른 것과 엔진 값이 다를 수 없게 |
| 같은 등급 다시 누름 | 엔진에 그대로 보냄(엔진이 대기 값을 비움) | 규칙은 엔진 몫 |
| 자동·속도 버튼 위치 | 그대로(M5-a 위치) | 지시 "자동·속도 버튼(M5-a)은 그대로" |
| 접기 버튼 문구 | "옵션 ▾"(펼침) / "옵션 ▸"(접힘) | 표시만 |
| CI 범위 | 영향받는 것만(모든 validator + 새 테스트 + 3D 자동·잠금·거절 대표 테스트). 3D 전체는 마지막 단계 전체 CI가 덮음 | 지시 §0 |

## 6. 실제 조작 증거 (Godot 창 캡처, 뷰포트 입력 주입)

- 드라이버 `evidence/m5c_capture/capture_driver.gd`(커밋 안 함): 렌더링 창, 제품 랩, 픽스처 없음, `push_input` 클릭만 썼다.
- 로그 `evidence/m5c_capture/run.log`:
  1. `00_default_low`: 엔진 low, 대기 없음, 플래그 F,F,F(미설정), 라벨 "적 AI: 하"
  2. `01_mid_pending`: [중] → 대기 mid, 라벨 "적 AI: 하 → 중 (다음 적 턴부터 적용)"
  3. `02_mid_applied_after_enemy_turn`: [대기] → 적 턴 → level mid, 플래그 T,T,T, 라벨 "적 AI: 중"
  4. `03_panel_folded`: [옵션 ▾] → 패널 숨김
  5. `04_high_pending_during_auto`: 펼침 → [자동 ▶] → 자동 중 [상] → 대기 high, 라벨 "적 AI: 중 → 상 (다음 적 턴부터 적용)"
  6. `05_auto_stopped`: [자동 ■] → 대기 high 그대로(다음 적 턴 전)
- 그림 `evidence/m5c_capture/out/*.png`

## 7. 남은 것

- 시작 화면에서 등급 고르기(같은 입구의 `enemy_ai_level`)는 이후 단계다.
- 기본 게임은 등급이 한 번도 설정되지 않아 상한 플래그가 꺼져 있다(S4-3 결정, 기본값 켜기는 김작 결정).
  - 패널은 그때 "적 AI: 하"로 보인다(엔진 `get_enemy_ai_level()` 값).
  - 하를 직접 누르면 상한이 켜진다.
- 사람이 직접 한 플레이는 없다.
