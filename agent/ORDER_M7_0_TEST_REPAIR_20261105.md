기준 화면: 없음(보이는 화면 변화 0). 월드맵↔전투 왕복 테스트 2개를 다시 돌 수 있게 고친다. 게임 코드는 건드리지 않는다. 작업 가지는 **새 가지 `feature/wm3d-m7prep-20261105`**(시작점 `9160baf`)이고 정본 가지 `feature/wm3d-intake-20261101`에는 push하지 않는다.
합격 기준: ① 고치기 전 두 테스트가 `Nonexistent 'bool' constructor`로 멈추는 것을 재현하고, 고친 뒤 끝까지 돌아 통과한다(타임아웃·오류 0). ② 정적 검증기 72개 전체와 기존 3D 테스트가 변화 없다. ③ 변경 경로가 아래 3절 목록 안이다. ④ 올린 커밋에서 `Verify C-track refactor` 4 shard와 `Verify WorldMap3D` success. 김작은 보고서와 CI만 본다(F6 없음).

# 지시서 — M7-0: 깨진 왕복 테스트 2개 복구 + 레포 밖 쓰기 조사

- 작성: 클코치, 2026-11-05 16:20 / 근거: `agent/REPORT_AUDIT_M7_20261105.md` 1-10, 3절 M7-0. 김작 11-05 15:57 "합류 전에 중간 단계로".
- [사실, 감사 보고서] 두 테스트가 `bool(worldmap.get("_worldmap_battle_entry_handoff_in_progress"))`를 읽는다(`tests/scripts/test_worldmap_battle_main_roundtrip_settlement.gd:82`, `tests/scripts/test_worldmap_to_battle_input_lifecycle.gd:22`). 그 속성은 `c098fb7`(2026-09-18)에서 main에서 지워져 `get()`이 null → `bool(null)` 오류. 06·07·08과 무관, 시작점 `367ad63`부터 이미 깨져 있었다. 이 두 테스트를 Godot로 돌리는 CI는 없고, `tools/validate_worldmap_to_battle_input_lifecycle.py:69-89`가 테스트 **소스에 특정 문자열이 있는지만** 본다.

## 0. 규칙
1. 시작 전 `git status` 깨끗, `git fetch origin`. 가지 만들기: `git switch -c feature/wm3d-m7prep-20261105 9160baf`(원격 `origin/feature/wm3d-intake-20261101`이 `9160baf`인지 확인; 아니면 멈춤). 이 지시서 전체의 push 대상은 이 새 가지뿐(김작 11-01 사전 승인 `feature/wm3d-*` 범위). `feature/wm3d-intake-20261101`·`main`·`integration/*`·`work/*`·열린 PR 가지에는 절대 push하지 않는다. force·삭제 금지, `gh`는 읽기만.
2. 수정 경로는 3절 목록뿐. `scripts/worldmap/worldmap_main.gd` 수정 금지(핀). 목록 밖이 필요하면 멈춤.
3. 코드 커밋 → CI 확인 → 보고서 커밋(`[skip ci]`) 순서, 합치지 않음. 보고서는 `agent/REPORT_M7_0_20261105.md`를 **이 새 가지에** 올린다(정본 가지의 `PROGRESS_WM3D.md`는 건드리지 않는다. 진행 기록은 보고서 맨 위에 쓴다).
4. 지시서의 [사실]과 다르면 추정하지 말고 멈추고 보고(`agent/REPORT_M7_0_STOP_20261105.md`).

## 1. 고칠 것
1. **두 테스트의 속성 읽기 교체**: `bool(worldmap.get("_worldmap_battle_entry_handoff_in_progress"))` 를 `worldmap.call("_ensure_camera_controller").is_battle_entry_handoff_in_progress()` 방식으로 바꾼다(기준: `worldmap_main.gd`의 `_ensure_camera_controller`(≈1173행)가 있고 컨트롤러가 `is_battle_entry_handoff_in_progress()`를 가진다는 것을 먼저 줄 번호로 확인). 두 테스트에서 **같은 속성을 읽는 줄을 전부** 찾아(`rg`) 같은 방식으로 바꾼다.
2. **먼저 검증기 확인(중요)**: `tools/validate_worldmap_to_battle_input_lifecycle.py`가 테스트 소스에서 기대하는 문자열을 읽어 본다. 옛 `_worldmap_battle_entry_handoff_in_progress` 문자열을 **요구**하면, 고치면 이 검증기가 실패한다. 그 경우: 검증기의 기대 문자열만 새 표현으로 갱신(약화·삭제 금지, 무엇을 무엇으로 바꿨는지 표로 보고). 요구하지 않으면 검증기는 건드리지 않는다.
3. 두 테스트가 오류 없이 끝까지 돌아 통과하는지 확인. 다른 **기존 오류**가 더 나오면(타임아웃 포함) 고치지 말고 오류 줄 원문과 원인 후보를 보고서에 적는다(범위 밖이면 새 문제로 분리).

## 2. 레포 밖 쓰기 조사 (읽기 전용, 수정 금지)
- `scripts/battle3d/lab_presentation.gd:44`가 레포 밖 `../EASTWAR_C0C3_Evidence/runtime_events.jsonl`을 쓰기 모드로 연다[사실, 감사]. 다음만 조사해 표로 보고한다: ① 그 파일을 읽는 코드·테스트·검증기·워크플로가 있는지(`rg`) ② 그 쓰기가 켜지는 조건(항상인지, 플래그인지) ③ 파일이 없는 환경(CI·김작 PC·모바일)에서 어떻게 되는지 ④ 안전한 최소 수정안 1개(제안만, 적용 금지). **이번에는 이 줄을 고치지 않는다.**

## 3. 수정 가능 경로 (이 목록이 전부)
1. `tests/scripts/test_worldmap_battle_main_roundtrip_settlement.gd`
2. `tests/scripts/test_worldmap_to_battle_input_lifecycle.gd`
3. `tools/validate_worldmap_to_battle_input_lifecycle.py` (1절 2번이 "요구함"으로 확인될 때만, 기대 문자열 갱신만)
4. `agent/REPORT_M7_0_20261105.md` (새, 보고서 커밋)

## 4. 로컬 검증 (결과 줄 원문을 표로)
1. 고치기 전 두 테스트(`godot --headless --path . --script res://tests/scripts/…`)를 실행해 `bool constructor` 오류와 종료 코드를 기록(timeout 300s).
2. 고친 뒤 같은 두 테스트 결과(통과 줄, 종료 코드).
3. 정적 검증기 72개 전체(커밋 뒤 깨끗한 트리 기준 `validators=72 pass=72 fail=0`; `.tscn` 변경이 없으므로 `validate_worldmap_trade_phase2_extraction.py`도 통과해야 함).
4. 기존 3D 테스트 전부 변화 없음(어댑터 56, 카메라 컨트롤러 61, 외부 입력 20, 호스트 58, 색 57, 길 121, 프로덕션 28, 메모리 프로브 37, 건물 에셋 테스트는 아직 없음).
5. `git status --short`이 3절 목록 안, `git diff --check` 통과, `git diff --stat`에 `worldmap_main.gd` 0.

## 5. 커밋·push·CI
1. 커밋 1: `test(worldmap): restore the battle round-trip tests (battle entry handoff flag now read through the camera controller)`
2. `git push origin feature/wm3d-m7prep-20261105`(새 가지 최초 push), 원격 해시 = 로컬 HEAD 확인.
3. `gh run watch`(읽기)로 두 workflow 결과를 확인(알려진 컷인 관찰 예외는 `agent/ORDER_QUEUE.md` 4절 1번 규칙을 따름). 실패하면 고치지 말고 읽기 전용 조사 후 멈춤 보고.
4. 보고서 커밋(`[skip ci]`)을 같은 새 가지에 push.

## 6. 보고서 (`agent/REPORT_M7_0_20261105.md`)
맨 위 "기준 화면 / 합격 기준" 두 줄, 3줄 요약, "택한 해석", 4절 결과 표, 변경 diff 전체, 2절 조사 표, CI 표, 막힌 것, 종료 루틴 5줄(① 정본 `git status`·가지·HEAD ② 새로 만든 것 ③ push한 것 ④ CI ⑤ 김작이 결정할 것).

## 7. 하지 않는 것
- `worldmap_main.gd`·battle 엔진·3D 셸 수정, 검증기 약화·삭제, `lab_presentation.gd` 수정, M7 구현(문맥 진입·결과 반환), 재실행으로 때우기, 정본 가지 push.
