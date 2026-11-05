기준 화면: 없음(보이는 화면 변화 0). M7-0에서 드러난 `test_worldmap_to_battle_input_lifecycle.gd`의 기존 실패 1건과 "실패해도 종료 코드 0"인 구조를 고친다. 게임 코드는 건드리지 않는다. 작업 가지는 M7-0과 같은 `feature/wm3d-m7prep-20261105`(이미 있음, 그 위에 커밋을 더함)이고 정본 가지에는 push하지 않는다.
합격 기준: ① 입력 수명주기 테스트가 FAIL 줄 0, PASS 줄 모두로 끝나고, **일부러 기대를 틀리게 하면 종료 코드 1이 되는 것**을 확인한다 ② 같은 구조의 다른 테스트가 있는지 조사해 목록을 보고한다(고치지는 않음) ③ 변경 경로가 3절 목록 안이다 ④ 올린 커밋에서 `Verify C-track refactor` 4 shard success. 김작은 보고서와 CI만 본다.

# 지시서 — M7-0b: 입력 수명주기 테스트 복구와 "실패해도 통과" 구조 수정

- 작성: 클코치, 2026-11-05 19:25 / 근거: `agent/REPORT_M7_0_20261105.md` 3-1(m7prep 가지). 김작 위임(루트 원인은 우회하지 않고 고친다).
- [사실, M7-0 보고서] `runtime supply panel visible` 검사가 FAIL이다(`tests/scripts/test_worldmap_to_battle_input_lifecycle.gd:43-44`, 경로 `BattleUI/T02BattleSupplyAnchor/T02BattleSupplyPanel`). 원인: `scripts/battle_web_import_test.gd:1680-1692` `_refresh_battle_supply_visibility()`가 프로덕션 HUD(`BattleUI/ProductionHudRoot/BattleSupplyHud`)가 있으면 그쪽만 켜고 옛 T02 패널은 숨긴다(`eb0b682`, 2026-09-19부터 의도된 동작). 테스트 기대가 `170b2aa`의 옛 패널 기준이다. 또 이 테스트는 `_expect` 실패가 있어도 끝에 `PASS`를 찍고 종료 코드 0으로 끝난다(`[WORLDMAP_INPUT_LIFECYCLE] PASS`, 종료 0).

## 0. 규칙
1. 새 가지를 만들지 않는다. `git switch feature/wm3d-m7prep-20261105`(원격과 같은지 확인, `62abaad`가 끝). push 대상은 이 가지뿐. 정본 가지·`main`·`integration/*`·`work/*` 금지, force·삭제 금지, `gh` 읽기만.
2. 수정 경로는 3절 목록뿐. `worldmap_main.gd`·`battle_web_import_test.gd` 등 게임 코드 수정 금지.
3. 코드 커밋 → CI → 보고서 커밋(`[skip ci]`), 보고서는 `agent/REPORT_M7_0B_20261105.md`(m7prep 가지).
4. [사실]과 다르면 추정하지 말고 멈추고 보고.

## 1. 고칠 것
1. **기대를 실제 동작에 맞춘다**: 옛 T02 패널의 `visible`을 요구하던 검사를, 프로덕션 HUD(`BattleUI/ProductionHudRoot/BattleSupplyHud`)가 **있을 때는 그것이 보이고, 없을 때는 옛 패널이 보이는** 두 경우 중 현재 장면에서 성립하는 쪽을 단언하도록 바꾼다. 먼저 `_refresh_battle_supply_visibility()`(`battle_web_import_test.gd:1680-1692`)를 줄 번호로 읽고, 테스트가 이 장면에서 어느 경우인지 확인한다. 검사 메시지의 `runtime supply panel visible` 문자열은 **그대로 유지**한다(검증기 `validate_worldmap_to_battle_input_lifecycle.py`가 이 문자열을 요구하는지 먼저 확인).
2. **실패 시 종료 코드 1**: `_expect`가 실패를 센 값을 모아, 끝에서 실패가 1건 이상이면 `[WORLDMAP_INPUT_LIFECYCLE] FAIL`을 찍고 `quit(1)`(PASS 줄은 실패가 0일 때만). 테스트의 기존 PASS/FAIL 출력 형식과 검증기가 기대하는 문자열은 유지한다.
3. **같은 구조 조사(읽기 전용)**: `tests/scripts/`에서 `_expect`/`_check`류가 실패를 세지 않고 `PASS`+종료 0으로 끝나는 테스트를 `rg`로 찾아 표로 보고한다(파일·줄·패턴). **이번에는 고치지 않는다**(후속 결정).

## 2. 로컬 검증 (결과 줄 원문)
1. 고치기 전: 지금 상태의 종료 코드(0)와 FAIL 줄 1개를 다시 기록.
2. 고친 뒤: PASS 줄 모두, FAIL 줄 0, 종료 코드 0.
3. **변조 확인**: 임시로 기대를 일부러 틀리게 한 복사본(또는 커밋하지 않는 로컬 편집)에서 종료 코드가 1이 되는 것을 확인하고 되돌린다(커밋 금지).
4. 왕복 정산 테스트 `[BATTLE_MAIN_ROUNDTRIP] PASS: 28 checks`, 정적 검증기 72/72, 3D 테스트 8종 변화 없음.
5. `git status --short`이 3절 목록 안, `git diff --check`.

## 3. 수정 가능 경로 (이 목록이 전부)
1. `tests/scripts/test_worldmap_to_battle_input_lifecycle.gd`
2. `tools/validate_worldmap_to_battle_input_lifecycle.py` (1절 1번이 "요구 문자열이 바뀐다"일 때만, 기대 문자열 갱신만)
3. `agent/REPORT_M7_0B_20261105.md` (보고서 커밋)

## 4. 커밋·push·CI
- 커밋: `test(worldmap): input lifecycle test follows the production supply HUD and exits non-zero on failure`
- push `feature/wm3d-m7prep-20261105`, 원격 해시 = 로컬 HEAD. `gh run watch`로 `Verify C-track refactor` 확인(`Verify WorldMap3D`는 경로 조건에 안 걸리면 "실행 안 됨"). 실패하면 고치지 말고 읽기 전용 조사 후 멈춤.
- 보고서 커밋(`[skip ci]`).

## 5. 하지 않는 것
- 게임 코드 수정, 다른 테스트 수정(조사만), 검증기 약화, `lab_presentation.gd` 수정, 워크플로 수정, 재실행으로 때우기, 정본 가지 push.
