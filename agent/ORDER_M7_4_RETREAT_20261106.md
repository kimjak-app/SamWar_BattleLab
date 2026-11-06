기준 화면: 가지 `feature/wm3d-m7prep-20261105`(M7-2 끝 위)에서, 월드맵 **공격전** 문맥으로 연 3D 전장의 상단 "후퇴" 버튼이 켜져 있고, 누르면 엔진의 후퇴 처리기가 결과 `retreat`로 월드맵 복귀(결과 메타 → `WorldMap.tscn` → 정산)까지 간다. 방어전 문맥·시나리오 모드·결과가 이미 확정된 뒤에는 후퇴 버튼이 꺼져 있다.
합격 기준: ① 새 테스트가 후퇴 → 결과 `retreat` → 복귀 → 정산 적용을 증명(공격전), 방어전 문맥에서는 버튼이 꺼짐 ② 기존 테스트·검증기 변화 없음(5절 갱신 표만 예외) ③ 변경 경로가 6절 목록 안 ④ C-track 4 shard + `Verify WorldMap3D` success. 최종 합격은 M7-3 뒤 김작 F6.

# ORDER_M7_4 — 3D 후퇴 버튼 (클코치 작성, 2026-11-06)

## 0. 효력과 승인
- 큐 규칙 그대로. **김작 승인 (11-05 21:54)**: 엔진 쓰기 +1 = `_on_retreat_button_pressed`. M7-2 뒤 17 → **18**.
- M7-2가 끝나 있어야 한다(랩 함수 `request_return_to_worldmap`, 17개 목록). 아직이면 시작하지 않고 큐를 기다린다.

## 1. 먼저 읽기 전용으로 확인 (보고서에)
1. 엔진 `_on_retreat_button_pressed`(`battle_web_import_test.gd:6154-6168`)는 ① 문맥이 없거나 공격전이 아니면 로그만 남기고 반환 ② 결과가 이미 확정이면 반환 ③ 전체 자동이면 멈춤 ④ `battle_result_reason="retreat"`, `forced_battle_result_state="retreat"` ⑤ `_return_to_worldmap_with_result()` 호출. [사실, 클코치 확인]
2. **2D 처리기 ①**(`battle_roster_presentation_controller.gd:163-179`)은 같은 엔진 후퇴 버튼의 `pressed`에 붙어 `forced_battle_result_state="defeat"`로 만든다. 3D 경로는 엔진의 `_on_retreat_button_pressed`를 **직접 호출**하고 엔진 버튼을 누르지 않으므로(신호 없음) ①은 돌지 않는다. 이것을 테스트로 확인(후퇴 결과가 `retreat`이지 `defeat`가 아님). 2D 쪽 ①·② 중복은 **이 단계에서 고치지 않는다**(2D 동작 변경 = 범위 밖, 보고서에 [사실]로만 적어 김작 결정 항목으로 넘김).
3. 엔진 후퇴 버튼의 `disabled` 값은 믿지 않는다: 프레젠테이션 컨트롤러가 `retreat_button.disabled = false`로 켜 둔다(`…presentation_controller.gd` 상단 버튼 설정 부분). 그래서 3D 켜짐 판단은 **엔진 규칙 함수**를 읽어서 한다(2절 1항).
4. 상단 후퇴 버튼 현재 상태: `battle3d_top_commands.gd` 상수 `RETREAT_TOOLTIP`, `retreat_button.disabled = true`, 연결 없음. 검증기 `validate_battle3d_top_commands.py:84` 근처가 "disabled·no handler·툴팁 상수"를 고정한다.

## 2. 해야 할 일
1. **켜짐 판단 = 엔진 규칙 읽기**: 랩(또는 셸)에서 `engine.call("_is_worldmap_player_attack_context", engine.get("worldmap_battle_context"))`로 판단한다(읽기 함수 1개 추가; 규칙을 3D에서 다시 쓰지 않는다 = 단일 출처). 문맥 모드가 아니면 항상 꺼짐. 결과 확정 뒤에는 상단 버튼 줄 자체가 숨는다(기존 `_refresh_top_commands`의 `live` 처리).
2. **랩에 함수 1개** `request_retreat()`: 안에서 `engine.call("_on_retreat_button_pressed")`를 한 번만 부른다(M7-2와 같은 모양).
3. **상단 버튼 줄** `battle3d_top_commands.gd`: `on_retreat` 콜러블 추가(다른 4개와 같은 방식), `retreat_button.pressed → on_retreat`. 켜짐/꺼짐과 툴팁을 `show_state` 계열 함수로 받는다. 꺼짐 툴팁은 기존 `RETREAT_TOOLTIP`("월드맵 연결 후 사용") 대신 문맥 밖에서는 "월드맵 공격전에서만 후퇴할 수 있습니다.", 켜짐일 때 "후퇴 · 생존 병력과 남은 보급을 출발 도시로 복귀". 이 줄은 엔진을 읽지도 쓰지도 않고 콜러블만 부른다(기존 규칙 유지).
4. **셸 연결**: `top_commands.on_retreat = func(): lab.request_retreat()`, `_refresh_top_commands()`에서 켜짐 상태를 넘긴다. 연타 방지: 누른 뒤 한 프레임 비활성(엔진이 반환만 하는 경로 대비).
5. **새 테스트** `tests/scripts/test_battle3d_worldmap_retreat.gd`(+`.uid`): 
   - 공격전 문맥: 버튼 켜짐 → 누름 → 결과 메타 `result == "retreat"`, `transaction_id` 일치, 장면 `WorldMap.tscn`, 재개 파일 없음, 정산 적용 결과가 **2D의 같은 입력(후퇴 결과 메타) 결과와 같음**(M7-2 방식 재사용). `defeat`가 아님을 명시 확인.
   - 방어전 문맥(`_is_worldmap_player_attack_context` 거짓인 문맥, 기존 테스트에서 만드는 방식을 따름): 버튼 꺼짐, 눌러도(`pressed` 방출) 메타 없음.
   - 시나리오 모드: 꺼짐.
   - 전체 자동 중 후퇴: 자동이 멈추고 후퇴로 이어짐.
6. CI 등록 한 줄, `validate_battle3d_contract.py` 기대 갱신(M7-1·M7-2와 같은 방식).

## 3. 하지 말 것
- 엔진·2D 프레젠테이션 컨트롤러·`worldmap_main.gd`·씬·데이터 수정 금지. 엔진 쓰기는 `_on_retreat_button_pressed` 1개만. 후퇴 확인 대화상자·애니메이션 같은 새 기능 금지(필요하면 보고서에 제안만).
- CI 재실행, 허용 오차 조정 금지.

## 4. 로컬 검증
M7-2 4절 전부 + 새 후퇴 테스트 + 상단 버튼 관련 battle3d 테스트·검증기(`validate_battle3d_top_commands.py` 갱신 포함).

## 5. 검증기 갱신 (상한)
- 개수·목록 고정 검증기(M7-2 5절과 같은 파일들): `FIFTEEN` 계열 목록과 "16→17→18" 숫자만. **상한 4개 파일, 파일당 10줄.**
- `validate_battle3d_top_commands.py`: ⓐ `:84` 근처의 "retreat: disabled, no handler" 단언을 "처리기 연결은 `on_retreat` 콜러블만"으로, ⓑ 셸 diff 단언의 `calls == [...]` 목록에 `request_retreat` 추가, ⓒ 엔진 읽기 단언에 `_is_worldmap_player_attack_context` 추가. 이 파일에 한해 **최대 25줄**, 새 검사 추가는 허용하되 **기존 검사를 약화(삭제·완화)하지 않는다**. 약화가 필요하면 멈춤.
- 보고서에 전후 표.

## 6. 수정·추가 경로 목록 (이 밖은 멈춤)
`scripts/battle3d/battle3d_engine_play.gd`, `scripts/battle3d/battle3d_scenario_shell.gd`, `scripts/battle3d/battle3d_top_commands.gd`, `tests/scripts/test_battle3d_worldmap_retreat.gd`(+`.uid`), `tools/validate_battle3d_contract.py`, 5절 검증기, `.github/workflows/verify-c-track.yml`(+1줄), `agent/REPORT_M7_4_20261106.md`.

## 7. 멈춤 조건 (큐 4절 외 추가)
- 후퇴 결과가 `defeat`로 나오거나 정산이 2D와 다를 때(고치지 말고 차이 표를 보고서에).
- 엔진의 규칙 함수 이름·시그니처가 1절과 다를 때.
- 5절 상한 초과, 6절 밖 수정, 기존 검사 약화가 필요할 때.

## 8. 보고서와 마무리
- `agent/REPORT_M7_4_20261106.md`(`[skip ci]`), 맨 위 두 줄. 로컬 결과 원문, 검증기 갱신 표, diff, 택한 해석, **김작 결정 항목**(2D 후퇴 처리기 ①②, 3D 후퇴 확인창 여부).
- 끝나면 큐를 다시 읽는다. **M7-3(월드맵이 3D 전장으로 부르기)은 클코치가 별도 지시서로 쓴다** — 없으면 멈추고 대기.
