# T2 2D 로스터 카드 고유특기 아이콘 결함 수정 결과 (2026-10-24)

- 지시: `NIGHT5_QUEUE_20261023.md` T2 (2D 씬 변경 김작 승인)
- 기준 `ba058c8a8e09f955230b5d48dd97e9de09074637`, 브랜치 `feature/roster-icon-fix-20261024`
- 커밋 2개(작성자·커미터 `Claude <noreply@anthropic.com>`):
  1. `0a533b4773a9af5ff11f899b3cda5ccc187635a6` `fix(battle): put ally roster card 1 ready icon back under Slot01`
  2. 이 보고서
- 푸시 여부와 끝 해시는 `agent/NIGHT5_SUMMARY_20261024.md` 맨 위에 적는다.
- 합격 판정은 하지 않는다. 바꾼 씬은 **`scenes/battle/Battle_Production.tscn` 하나**다. 컨트롤러·엔진·서비스 코드 변경 0, 옛 T08 검증기 변경 0, 테스트 장면 3개 변경 0.

## 1. 원인 (고치기 전에 확인)

### (a) 어떻게 생겼나

- `git log -S'UniqueSkillReadyIcon2'` 결과: `2cb0008`(08-14, "current_actor_hud 업로드", 테스트 장면 `tests/scenes/Battle_UI_Production_Test.tscn`)과 `64e8dcf`(09-19, P-1C, 테스트 장면을 `Battle_Production.tscn`으로 복사).
- `git show 2cb0008`의 해당 부분(요약):

```
-[node name="UniqueSkillReadyIcon" ... parent=".../AllyRosterHud/Slot01" unique_id=1168471520]
+[node name="Slot02" ... unique_id=51157357]          (Slot02 카드 머리를 이 노드 위로 올림)
+[node name="UniqueSkillReadyIcon2" ... parent=".../AllyRosterHud/Slot02" unique_id=1168471520]
-offset_top = -8.0          +offset_top = -102.0
-offset_bottom = 48.0       +offset_bottom = -46.0
```

- **같은 노드(unique_id 1168471520)가 1번 카드에서 2번 카드 밑으로 옮겨졌다.** 2번 카드에 이미 `UniqueSkillReadyIcon`이 있어서 Godot가 이름을 `UniqueSkillReadyIcon2`로 바꿨다.
- 위치값 변화(−8 → −102, 48 → −46)는 정확히 −94다. 1번 카드(위 46)와 2번 카드(위 140)의 간격이 94다. 즉 화면 위치는 그대로 두고 부모만 바뀌었다. 에디터에서 노드를 끌어 옮길 때 생기는 모양이다(의도였는지는 커밋 메시지로 알 수 없다. 같은 커밋의 다른 변경은 하단 HUD 두 덩어리의 위치 조정이다).
- 결과:
  - 1번 카드에는 아이콘 노드가 없다. 로스터 다리(`battle_roster_hud_controller.gd:56`)가 `get_node_or_null("UniqueSkillReadyIcon")`로 찾으므로 **1번 카드 아이콘은 한 번도 켜지지 않는다.**
  - 2번 카드의 `UniqueSkillReadyIcon2`는 아무도 찾지 않아 늘 숨겨져 있다(기본 `visible = false`).

### (b) 다른 카드와 적 로스터

`Battle_Production.tscn`(수정 전)의 로스터 아이콘 전부:

| 카드 | 노드 | 위치(왼·위·오른·아래) | 상태 |
|---|---|---|---|
| 아군 Slot01 | 없음 | — | **결함** |
| 아군 Slot02 | `UniqueSkillReadyIcon2`(1168471520) | 206, −102, 262, −46 | **결함(옮겨진 1번 카드 노드)** |
| 아군 Slot02 | `UniqueSkillReadyIcon`(1716791831) | 206, −8, 262, 48 | 정상 |
| 아군 Slot03, Reinforce01, Reinforce02 | `UniqueSkillReadyIcon` | 206, −8, 262, 48 | 정상 |
| 적 Slot01~03, Reinforce01·02 | `UniqueSkillReadyIcon` | 206, −8, 262, 48 | 정상 |

- 텍스처(`35_unique_skill_ready_icon`), `visible = false`, `expand_mode = 1`, `stretch_mode = 5`, `mouse_filter = 2`는 모든 아이콘이 같다. **결함은 아군 1·2번 카드뿐이다.**
- 같은 씬의 `FormationSlotGuideLayer`(옛 편성 안내판) 10칸에도 `UniqueSkillReadyIcon`이 하나씩 있다. 로스터와 무관하며 정상이다.

### (c) 테스트 장면 (목록만, 바꾸지 않음)

| 장면 | 상태 |
|---|---|
| `tests/scenes/Battle_UI_Production_Test.tscn` | **같은 결함**(`Slot02/UniqueSkillReadyIcon2` :4610, `Slot02/UniqueSkillReadyIcon` :4719, `Slot01`에 없음) |
| `tests/scenes/Battle_UI_Production_Imjin_Test.tscn` | 노드를 직접 갖지 않고 위 장면을 상속한다(`instance=`) → **같은 결함을 물려받음** |
| `tests/scenes/Battle_UI_Production_Imjin_IsoMovement_Test.tscn` | Imjin_Test를 상속 → **같은 결함을 물려받음** |

## 2. 고친 것

- `Battle_Production.tscn`에서 노드 1168471520을 `AllyRosterHud/Slot01`로 되돌리고 이름을 `UniqueSkillReadyIcon`, 위치를 206/−8/262/48(다른 모든 로스터 아이콘과 같은 값)로 했다. 파일 안 순서도 `2cb0008` 이전처럼 Slot01의 마지막 자식, Slot02 카드 머리 앞이다.
- diff는 `+11 −11`이고 **`2cb0008` 해당 부분의 정확한 역방향**이다. 2번 카드의 원래 아이콘(1716791831)은 그대로다. 이제 아군·적 카드 10장이 아이콘을 하나씩 갖는다.
- 우회(컨트롤러가 `Icon2`도 찾게 하기)는 하지 않았다. 컨트롤러 코드는 바꾸지 않았다.

## 3. 새 테스트 `tests/scripts/test_battle_roster_ready_icon.gd`

- CI 목록에 1줄 추가했다(`verify-c-track.yml`, 추가만).
- 엔진 호스트(`Battle_Main.tscn` → `Battle_Production.tscn`)를 헤드리스로 띄운다.
- 구조: 아군·적 로스터마다 아이콘 계열 노드가 모두 5개, 카드마다 정확히 하나, 이름은 `UniqueSkillReadyIcon`, 형은 `TextureRect`.
- 동작: 엔진은 "현재 행동 중인 아군 + 기세 + 특기 대상 있음"일 때만 준비 상태로 본다(`_can_use_unique_skill`, `battle_web_import_test.gd:3631`). 그래서 배치된 아군 카드마다 차례로 다음을 한다.
  1. 아군 기세 10
  2. 적 하나를 그 아군 옆 칸으로 옮김(테스트 픽스처 쓰기)
  3. 엔진 `_select_ally_unit`으로 그 아군 선택
  4. 그 상태에서 카드 10장의 아이콘 보임 = 엔진 `_is_unique_skill_ready_for_formation_guide`(카드 유닛별)인지, 그리고 선택한 카드가 실제로 준비 상태(아이콘이 켜지는 경우를 꼭 지나감)인지 확인
- 기세 0이면 아이콘이 모두 숨는지.
- 기대값은 엔진 함수에서 만든다. 아이콘에서 거꾸로 만들지 않는다.
- 결과(수정본): **29 checks, 실패 0**. 로그 예(카드 1 선택): `ready=[true, false, false, false, false] shown=[true, false, false, false, false]`. 카드 2·3도 같은 식이고, 증원 2장은 미배치라 준비가 아니고 숨김이다.

### 3-1. 변조를 실제로 넣었을 때 (각각 원래 바이트로 되돌림, 끝에 바이트 같음 확인)

| # | 장면 변조 | 결과 |
|---|---|---|
| M1 | 1번 카드 아이콘 삭제 | **실패** "Ally roster: 4 ready-icon nodes in total …" |
| M2 | 3번 카드에 중복 아이콘 추가 | **실패** "Ally roster: 6 ready-icon nodes in total … Slot03/UniqueSkillReadyIcon2 …" |
| M3 | 1번 카드 아이콘 이름 바꿈 | **실패** "Ally roster: 4 ready-icon nodes …" |
| M4 | 수정 전 장면(`ba058c8` 그대로) | **실패** "Ally Slot01: exactly one TextureRect named UniqueSkillReadyIcon []" |

러너 `evidence/t2/run_t2.py`, 원문 `evidence/t2/out/`.

## 4. 옛 T08 검증기 (읽기만)

- `validate_t08_3b0_roster_content_parity`: 수정 전후 모두 실패. 아이콘 항목도 그대로 실패다. "missing UniqueSkillReadyIcon at …/AllyRosterHud/Slot01", "… is not default hidden".
- `validate_t08_3b1_roster_theme_font`: 수정 전후 모두 실패. 아이콘 항목도 그대로다. "hidden contract broken: …/AllyRosterHud/Slot01/UniqueSkillReadyIcon".
- 이유: 두 검증기는 `Battle_Production.tscn`이 아니라 **`tests/scenes/Battle_UI_Production_Test.tscn`을 읽는다**(N1 조사). 그 장면은 지시대로 바꾸지 않았다. 그 장면도 고치면 아이콘 항목이 통과할 것으로 보이지만 확인하지 않았다.
- 삭제·수정은 하지 않았다(김작 승인 뒤).

## 5. 전체 영향 범위 (이 씬을 읽는 곳)

- **이 씬을 직접 참조**: `scenes/battle/Battle_Main.tscn`(상속, 실제 전투 진입 장면), 검증기 `validate_b0b_battle_production_skeleton.py`, `validate_p1c_battle_production_promotion.py`.
- **`Battle_Main.tscn`을 통해 간접 참조**:
  - 제품 코드: `scripts/worldmap/worldmap_main.gd`(월드맵 → 전투), `scripts/battle3d/battle3d_engine_host.gd`(3D 랩의 엔진)
  - 테스트 14개 파일
  - 검증기 24개(b0b·b0c·b1b~g·battle3d m1b~m4d·contract·p1b*·p1c·worldmap_to_battle_input_lifecycle, `p1_exact_delta.py`)
  - CI의 `CI_BATTLE_MAIN_LOAD` 단계
- 아이콘 이름을 문자열로 찾는 곳: 로스터 다리(`battle_roster_hud_controller.gd:56`), 엔진 편성 안내판(`battle_web_import_test.gd:7467`, 안내판 노드만), 테스트 장면용 `tests/scripts/battle_ui_production_test_roster.gd:56`, 옛 T08 검증기 2개.
- 확인한 것(수정 브랜치):
  - CI 목록 검증기 **51개 전부 exit 0**
  - CI 밖 관련 검증기 17개를 수정 전(`ba058c8`)과 수정 후로 비교한 결과, **결과가 모두 같다**. 통과 12개(`p1_exact_delta`, b1b~b1g 6개, p1b1~p1b4·p1b_16x9 5개), 실패 5개(T08 `2`·`3a`·`3b1_hotfix1`·`3c`·`battle_scene_isolation`). 실패는 수정 전에도 같았다.
  - Godot 테스트: §6 참고.

## 6. 실제 조작 증거 / 남은 것

- 새 테스트와 변조 실행은 위 §3. 헤드리스이고 화면 캡처는 없다(이 결함은 노드 구조 문제라 캡처 대신 노드·표시 상태를 직접 확인했다).
- 영향 테스트 묶음(Godot, 수정 브랜치, Windows 단독, 원문 `evidence/t2/ci/`): 모두 exit 0
  - `Battle_Main.tscn` 불러오기·생성(CI의 `CI_BATTLE_MAIN_LOAD`와 같은 내용) PASS
  - 새 `test_battle_roster_ready_icon` 29 checks
  - `test_battle_move_oracle_baseline` 283 checks
  - `test_battle3d_scenario_start` 24 checks
  - `test_battle3d_wait_default_round` 71 checks
  - `test_battle_setup_port_base_parity_shard_1` 36 checks
  - 전체 CI(테스트 150개 안팎)는 돌리지 않았다. 바뀐 것은 HUD 노드 하나의 부모·이름·위치라서 엔진 상태에는 닿지 않는다고 보고 위 묶음만 골랐다(판단 근거이고, 증명은 아니다).
- **사람이 직접 한 플레이는 없다.** 실제 전투 화면에서 1번 카드 아이콘이 켜지는 것을 눈으로 보지 않았다.
- 남은 것:
  1. 테스트 장면 3개의 같은 결함은 그대로다(지시대로 목록만).
  2. 옛 T08 검증기 2개의 아이콘 항목은 테스트 장면 때문에 계속 실패한다.
  3. `2cb0008`의 이동이 의도였는지는 확인하지 못했다.
