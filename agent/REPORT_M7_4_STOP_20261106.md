기준 화면: 가지 `feature/wm3d-m7prep-20261105`(끝 `6bd038e`, M7-2 완료) — M7-4 코드는 한 줄도 바꾸지 않았습니다. 3D 상단 "후퇴" 버튼은 지금처럼 꺼져 있고(툴팁 "월드맵 연결 후 사용", 처리기 없음) 아무 일도 하지 않습니다.
합격 기준: (멈춤 보고) 지시서 2절 3항과 기존 테스트 `tests/scripts/test_battle3d_top_commands.gd:107`이 서로 맞지 않아, 6절 경로 밖 수정 없이는 M7-4를 끝낼 수 없습니다. 클코치 답신(`agent/ORDER_M7_4_REPLY_1_*.md`)을 기다립니다.

# REPORT M7-4 STOP — 3D 후퇴 버튼 (2026-11-06)

## 요약
- [사실] 지시서 2절 3항은 상단 줄에 `retreat_button.pressed → on_retreat`를 연결하고, 문맥 밖 꺼짐 툴팁을 "월드맵 공격전에서만 후퇴할 수 있습니다."로 바꾸라고 합니다.
- [사실] 기존 테스트 `tests/scripts/test_battle3d_top_commands.gd:107`은 **시나리오 모드(문맥 밖)**에서 다음 셋을 모두 단언합니다.
  - `cmd.retreat_button.disabled`
  - `tooltip_text == "월드맵 연결 후 사용"`
  - `handlers(cmd.retreat_button).is_empty()`(게임 클릭 소리 연결을 뺀 `pressed` 연결 0개)
  - 머리 주석 12행도 "retreat -> disabled, no handler"입니다.
  - 따라서 지시서대로 하면 툴팁과 처리기 두 조건이 깨집니다.
- 이 테스트 파일은 6절 수정 경로 목록에 없고, 합격 기준 ②는 "기존 테스트 변화 없음(5절 갱신 표만 예외, 5절은 검증기만)"입니다. 큐 4절 3항과 지시서 7절("6절 밖 수정")에 해당하므로 **코드를 고치기 전에 멈췄습니다.** 작업 트리는 깨끗합니다.

## 1. 지시서 1절 확인 결과 (모두 일치)
| # | 지시서 [사실] | 실제 (`6bd038e`) | 일치 |
|---|---|---|---|
| 1 | 엔진 `_on_retreat_button_pressed` 6154~6168행: ① 문맥 없음·공격전 아님 → 로그 후 반환 ② 결과 확정 → 반환 ③ 전체 자동이면 멈춤 ④ `battle_result_reason="retreat"`, `forced_battle_result_state="retreat"` ⑤ `_return_to_worldmap_with_result()` | `scripts/battle_web_import_test.gd:6154-6168` 그대로. 규칙 함수 `_is_worldmap_player_attack_context(context: Dictionary) -> bool`(1922행, `source == "player_attack" or type == "attack"`)도 이름·시그니처가 같습니다. | 예 |
| 2 | 2D 처리기 ①(`battle_roster_presentation_controller.gd:163-179`)은 같은 엔진 후퇴 버튼 `pressed`에 붙어 `forced_battle_result_state="defeat"` | `scripts/battle/presentation/production/battle_roster_presentation_controller.gd:163-179` `_on_top_action_retreat_pressed`: 자동 멈춤 → `battle_result_reason="retreat"`, `forced_battle_result_state="defeat"` → 토스트 → 복귀 버튼 갱신(연결은 86~87행) | 예 |
| 3 | 프레젠테이션 컨트롤러가 엔진 후퇴 버튼을 `disabled=false`로 켬 | 같은 파일 84행 `retreat_button.disabled = false`. 엔진 쪽 갱신은 `_refresh_retreat_button_state()`(6141~6151행, 꺼짐 툴팁 "공격전에서만 후퇴할 수 있습니다.") | 예 |
| 4 | 상단 줄: `RETREAT_TOOLTIP`, `disabled = true`, 연결 없음, 검증기 `validate_battle3d_top_commands.py:84` | `battle3d_top_commands.gd` 19행 `RETREAT_TOOLTIP := "월드맵 연결 후 사용"`, 50~52행 생성·`disabled = true`·툴팁, 연결 없음. 검증기 84행 그대로. | 예 |

추가로 찾은 [사실]:
- 같은 단언이 **검증기 2개**에도 있습니다. 둘 다 고정 커밋 감사라 HEAD를 보지 않습니다(그래서 HEAD를 바꿔도 깨지지 않고, 고치면 오히려 고정 커밋 감사가 깨집니다).
  - `tools/validate_battle3d_top_commands.py:84`(`TIP` 기본 `923c149`)
  - `tools/validate_battle3d_top_buttons_plain.py:78`·`:95`(`TIP` 기본 `9bce8c5`)
  - 지시서 5절의 `validate_battle3d_top_commands.py` 갱신(ⓐⓑⓒ)은 같은 이유로 **필요 없거나 오히려 해롭습니다**. M7-2 보고서 택한 해석 2와 같은 상황입니다.
- **HEAD를 실제로 검사하는 것은 테스트 `test_battle3d_top_commands.gd`뿐입니다.**
- 엔진에서 공격전 결과를 `defeat`로 만드는 곳이 하나 더 있습니다: 30턴 제한(`battle_web_import_test.gd:11395-11397`, `battle_result_reason="turn_limit"`). 후퇴와는 다른 경로입니다(참고).

## 2. 클코치 결정이 필요한 것 (택1, 클코드 추천은 A)
| 안 | 내용 | 바뀌는 기존 파일 | 장단점 |
|---|---|---|---|
| **A (추천)** | 지시서 그대로. 그리고 `test_battle3d_top_commands.gd`의 후퇴 검사(12행 주석, 106~109행)를 새 규칙으로 **교체**: 시나리오 모드에서 "꺼짐 + 툴팁 '월드맵 공격전에서만 후퇴할 수 있습니다.' + `pressed` 연결은 `on_retreat` 1개 + 눌러도 엔진 변화 없음". 기존 "클릭해도 엔진 그대로·결과 없음"(109~110행)은 유지. | 테스트 1개, 약 4줄 | 지시서 2절 3항 그대로. 기존 검사를 지우지 않고 규칙이 바뀐 부분만 교체(CH-2b와 같은 방식). 6절에 이 테스트 경로 추가 승인이 필요. |
| B | 기존 테스트 그대로 통과하게: 시나리오 모드에서는 툴팁 "월드맵 연결 후 사용" 유지 + `pressed` 연결 없음. 셸이 **문맥 모드일 때만** `on_retreat` 연결 + 새 툴팁. | 없음 | 기존 테스트 0줄. 대신 지시서 2절 3항(문맥 밖 툴팁 문구, "다른 4개와 같은 방식")과 다름. |
| C | 다른 지시 | — | — |

## 3. 그대로 남은 계획 (답신이 오면 바로 진행)
- 랩 `request_retreat()`(엔진 `_on_retreat_button_pressed` 1회, 엔진 쓰기 18)와 읽기 함수 `hud_retreat_available()`(`engine.call("_is_worldmap_player_attack_context", engine.get("worldmap_battle_context"))`, 문맥 없으면 거짓).
- 상단 줄 `on_retreat`와 켜짐·툴팁 함수, 셸 연결과 연타 방지.
- 새 테스트 `test_battle3d_worldmap_retreat.gd`: 공격전 후퇴 → `retreat` 메타 → 월드맵 → 정산 == 2D(같은 후퇴 메타), `defeat` 아님. 방어전 문맥은 꺼짐. 시나리오 모드는 꺼짐. 전체 자동 중 후퇴.
- M7-2와 같은 방식(실제 빌더 + 출정 확인 본문의 출발·대기·스냅샷 단계)으로 문맥을 만듭니다.

## 4. 김작 결정 항목 (지시서 8절, 바꾸지 않고 [사실]만)
- 2D 후퇴 처리기 ①②의 중복: 엔진 후퇴 버튼 `pressed`에 2D 프레젠테이션 처리기(`defeat`)가 붙어 있고, 엔진 자신의 `_on_retreat_button_pressed`(`retreat`)도 같은 버튼에 연결되어 있는지는 [미확인]입니다(이번에 연결 목록을 실행해 보지 않았음). 2D에서 후퇴 결과가 `defeat`/`retreat` 중 무엇으로 정산되는지는 김작 F6 또는 별도 조사가 필요합니다.
- 3D 후퇴 확인창 여부(지시서 3절: 만들지 않음, 제안만).

## 5. 상태
- M7-4 코드 변경 0, 커밋은 이 보고서 1개(`[skip ci]`).
- 큐 18·19번(턴 버튼 리스킨, PERF2)은 큐 1절 "건너뛰지 않는다"에 따라 시작하지 않았습니다.
- 오늘 끝낸 큐 항목: 13(CH-2b), 14(CH-2c), 15(PERF CSV), 16(M7-2), 20(HUD 캡처).
