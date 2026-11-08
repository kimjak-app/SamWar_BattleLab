기준 화면: 새 가지 `feature/wm3d-warnfix-20261108`(시작: `origin/main` `a9e3b84229f63286bbdc784d78826b0e2cdb792d`)에서 Godot 4.6.2로 프로젝트를 열고 F6로 `WorldMap.tscn`을 돌린 뒤, 하단 디버거 **Errors 탭의 경고 14개(그림자 5 + 정수 나눗셈 9)가 0개**가 된다. 게임 동작·화면은 그대로.
합격 기준: 6절 자동 기준 전부 + **동작 변화 0**(기존 테스트·검증기 변경 없이 통과) + C-track 4 shard·`Verify WorldMap3D` 초록. 최종 합격은 김작 F6(7절).

# 지시서 — WARNFIX: Godot 경고 14개 뿌리 정리 (큐 31번)

- 작성: 클코치, 2026-11-08. 김작 요청 [사실]: 11-08 20:59 디버거 Errors 탭 스크린샷(경고 14개) — "오늘은 이 에러 난 것만 고치자". 대상은 **경고(노란 점)**이며 에러가 아니다. 이전 기록: `claude/SMALL_BUGS_LIST_20261030.md`/CURRENT_STATE의 "UID 경고·`set_fill_preset(name)`·정수 나눗셈 경고" 보류 항목과 같은 계열.
- **순서: 큐 30번(DEBUG-CHEATS, `feature/wm3d-debugcheats-20261108`)이 끝난 뒤** 시작한다(한 번에 한 단계). 30번과 파일이 겹치지 않게 `spy_presentation_helper.gd`·`WorldMap.tscn`·`worldmap_debug_cheats_controller.gd`는 건드리지 않는다.

## 0. 규칙
큐 10절·상시 규칙. **원인 수정**이 원칙: 경고를 끄는 설정(`project.godot` 경고 레벨 변경, 파일 전체 `@warning_ignore`)·경고를 숨기는 우회 금지. 동작이 한 비트도 바뀌면 안 된다. 허용 파일은 **1단계 목록에 오른 `.gd` 파일 중 아래 금지 목록 밖의 것**뿐(새 폴더·새 파일 금지). 막히면 `agent/REPORT_WARNFIX_STOP_20261108.md`로 멈춘다(이 항목만).
**금지(수정 불가, 해당되면 STOP 목록에 올린다)**: `scripts/worldmap/worldmap_main.gd`와 `scripts/worldmap/military/battle_settlement_applier.gd`(`tools/p1_exact_delta.py`가 바이트 고정), `tools/p1_exact_delta.py`, `project.godot`, 보호된 검증기 파일.

## 1. 1단계 — 경고 목록 확정 (코드 변경 0)
- 김작 화면과 같은 방식으로 14개를 **재현**한다: Godot 4.6.2 에디터로 프로젝트를 열었을 때와 F6 `WorldMap.tscn` 실행 때 디버거 Errors 탭(또는 같은 메시지가 나오는 로그). 재현이 안 되면(14개와 다르면) 실제 개수와 이유를 적고 멈춘다.
- 각 경고마다 **파일:줄:종류**를 표로 만든다(보고서 1절). 김작 화면의 14개 내용 [사실]:
  - 그림자(shadowing) 5: `texture`가 기반 클래스 `TextureRect`의 속성을 가림 / `owner`가 `Node` 속성을 가림 / 함수 매개변수 `name`이 `Node` 속성을 가림(2개) / `basis`가 `Node3D` 속성을 가림
  - 정수 나눗셈 9("Integer division. Decimal part will be discarded.")
- 클코치가 코드 읽기로 좁힌 **후보 [추정, 1단계에서 확정할 것]**:
  - `texture`(TextureRect): `scripts/worldmap/worldmap_turn_compass.gd` 147줄 `var texture := load(FRAME_TEXTURE_PATH)` (이 파일이 `TextureRect` 기반인 유일한 후보)
  - `basis`(Node3D): `worldmap3d/scripts/worldmap_region_labels.gd` 97줄 `var basis := Basis(...)`
  - `name` 매개변수(Node): `worldmap3d/scripts/worldmap3d_root.gd` 566줄 `func set_fill_preset(name: String)`; 두 번째는 못 찾음(`tools/acceptance_tests.gd`의 `_grab(name)`·`_grab_next_frame(name)`도 `Node` 기반 후보)
  - `owner`(Node): Node 기반 클래스에서 `var owner`를 직접 못 찾았다(RefCounted 기반 `spy_presentation_helper.gd`의 `var owner`는 이 경고 대상이 아님). 반복문 변수이거나 사용자 정의 Node 기반 클래스일 수 있으니 Godot 목록으로 확정.
  - 정수 나눗셈 9: 클코치가 위치를 못 찾았다(정적 grep으로 정확하지 않음) → Godot 목록이 정본.
- 목록에 `worldmap_main.gd`나 금지 파일이 있으면 그 항목은 **수정하지 않고** 보고서의 "금지 파일에 있는 경고" 표에 올린다(김작 결정으로 남김).

## 2. 2단계 — 뿌리 수정 (동작 불변)
- **그림자**: 지역 변수/매개변수의 이름만 바꾼다(예: `frame_texture`, `label_basis`, `preset_name`). 같은 함수 안 모든 사용처를 바꾸고, **외부에서 키워드 인자로 호출하는 곳은 GDScript에 없으므로 안전**하지만 `call("함수명", ...)`·`has_method` 쓰는 곳이 매개변수 이름에 의존하지 않는지만 확인. 그 이름이 **기반 클래스 속성을 의도해서** 쓴 코드라면(예: 진짜 `self.texture`를 쓰려던 것) 이름만 바꾸지 말고 보고서에 "의도 불일치"로 적고 멈춘다.
- **정수 나눗셈**: 사이트마다 의도를 분류해 보고서에 적는다.
  - 소수 버림이 **의도**(칸 수·인원·턴 수 등) → 같은 줄 바로 위에 `@warning_ignore("integer_division")`(그 문장 한 곳만) + 한 줄 주석으로 "의도된 버림". 값이 바뀌면 안 되므로 `int(float(a)/b)` 같은 변환은 **음수·큰 수에서 결과가 달라질 수 있어 금지**(`/`의 기존 의미 유지).
  - 소수 결과가 **필요한데 버려지고 있음**(실제 버그 의심) → 고치지 말고 보고서 "버그 의심" 표에 올린다(이 지시서는 동작 불변).
- 파일 전체 서식 정리·불필요한 변경 금지(diff는 경고 줄 주변만).

## 3. 새 경고 0
수정 후 같은 방법으로 다시 열어 **Errors 탭의 경고 개수 전·후**를 보고서에 적는다(14 → 0, 금지 파일 때문에 남은 것은 숫자와 이유). 새로 생긴 경고가 있으면 0이 될 때까지 고친다.

## 4. 하지 않는 것
`main` 푸시·병합, 새 폴더·새 파일, 금지 파일 수정, 경고 레벨 설정 변경, 동작·규칙·밸런스 변경, 허용 오차·재실행.

## 5. 가지·커밋
새 가지 `feature/wm3d-warnfix-20261108`(시작 `main` `a9e3b84`), 코드 커밋 1개 → CI → 보고서 `agent/REPORT_WARNFIX_20261108.md`(`[skip ci]`). 푸시는 이 가지에만.

## 6. 자동 합격 기준
- 경고 전→후 개수와 항목별 표(파일:줄:종류:조치) 원문.
- 기존 테스트·검증기 **변경 없이** 전부 통과(특히 `validate_worldmap_main_integrity.py`·`validate_worldmap_diplomacy_routing.py`·턴 버튼 테스트·`worldmap3d` 테스트·`test_worldmap3d_host/production`), 변경 파일이 1단계 목록 안, 금지 파일 변경 0(`git diff a9e3b84 -- scripts/worldmap/worldmap_main.gd tools/p1_exact_delta.py`가 비어 있음), C-track 4 shard·`Verify WorldMap3D` 초록(알려진 `[CUTIN]` 흔들림은 큐 4절 규칙대로 기록, 재실행 금지). 새 `.uid` 파일이 생기면 **같이 커밋**(30번 CI 실패 교훈: 미커밋 `.uid`는 "작업 트리 깨끗" 검사에서 실패).

## 7. 김작 F6 체크리스트 (보고서 맨 아래에 그대로 옮길 것)
1. Godot에서 프로젝트를 열고 `WorldMap.tscn` F6 → 하단 디버거 **Errors 탭이 0개**(또는 지시서가 적은 남은 개수와 같음).
2. 턴 나침반(턴 종료 버튼) 모양·하늘 원이 전과 같음.
3. 3D 월드맵의 지역 이름 라벨 위치·방향이 전과 같음, 채움 프리셋 바꾸기가 전과 같이 동작.

## 8. 보고서
`agent/REPORT_WARNFIX_20261108.md`: 맨 위 두 줄 + 3줄 요약 + 1절 목록 표(재현 방법·14개 일치 여부) + 조치 표 + 금지 파일 표 + 버그 의심 표 + 전→후 개수 + 6절 결과 줄 원문 + F6 체크리스트 + 종료 루틴 5줄(OPERATING_RULES §4).

## 큐 행 (30번 바로 뒤에 삽입)
| 31 | `agent/ORDER_WARNFIX_20261108.md` | 준비됨 — **새 가지** `feature/wm3d-warnfix-20261108`(시작 `main` `a9e3b84`). 디버거 경고 14개(그림자 5·정수 나눗셈 9) 뿌리 정리, 동작 불변. **30번이 끝난 뒤 시작.** `worldmap_main.gd`·`p1_exact_delta` 금지(걸리면 STOP 목록으로) |
