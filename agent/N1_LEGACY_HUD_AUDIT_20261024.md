# N1 옛 HUD 검증기 정리 조사 (2026-10-24)

- 기준 커밋: `ba058c8a8e09f955230b5d48dd97e9de09074637` (읽기 전용 워크트리 `scratchpad/night4/base`, detached)
- 읽기만, 코드 변경 0. 워크트리 안 파일 생성·수정·삭제 없음. 실행마다 `git status --short` 비어 있음을 확인했다.
- 합격 판정은 하지 않는다. 사실과 분류 후보만 적는다.
- Godot는 실행하지 않았다. 모두 정적 검사와 `git log`로 확인했다.
- 3A 검증기 한 개만, 중단 없이 끝까지 보려고 워크트리 **밖**(`scratchpad/night4/n1/probe/t08_3a_nocrash.py`)에 사본을 만들어 돌렸다. `nodes[...]`를 `.get()`으로만 바꿨다.

## 0. 먼저 알아둘 사실 (이전 조사와 다른 점)

1. **T08 검증기 7개 중 어느 것도 `scenes/battle/Battle_Production.tscn`을 읽지 않는다.** 모두 `tests/scenes/Battle_UI_Production_Test.tscn`(테스트 장면)을 읽는다. 예: `validate_t08_2_production_hud.py:8`, `validate_t08_3b0_roster_content_parity.py:11`.
2. 두 장면의 HUD 노드 트리는 같다. `git diff --no-index --stat`은 `20 +++++++++++++-------`(13줄 추가, 7줄 삭제)이다. 차이는 스크립트 경로·UID, 노드 2개(`ProductionAutoTurnCameraGuard`, `ProductionStatusEmptyLegend`), `48_supply_mock` 제거뿐이다. P-1C `64e8dcf`가 테스트 장면을 그대로 복사해 `Battle_Production.tscn`(6564줄)을 만들었기 때문이다.
3. **"기세 칸 10 → 20"은 사실이 아니다.** 칸은 지금도 편당 10개(`Slot01`~`Slot10`)다. `9badf41`(08-02 "둥근다이아몬드 허드 기세")이 칸마다 `SlotNNWrapper`를 씌웠다. 검증기는 `SlotRow/Slot`로 시작하는 경로를 세서 Wrapper 10개 + Slot 10개 = 20을 센다(`validate_t08_2_production_hud.py:64`). 컨트롤러도 Wrapper 안의 `SlotNN`을 찾아 쓴다(`scripts/battle_web_import_test.gd:15978-15990` `_resolve_momentum_slot_control`).
4. **`ValueLabel`·`ActiveSideLabel`·`BattleTitleLabel`을 없앤 커밋은 `d5e9bfa`(08-02 "style: simplify production top HUD with unified frame")다.** 이전 조사가 든 `2cb0008`~`797c05b`(08-14~15)가 아니다. `git log -S'name="ActiveSideLabel"' -- tests/scenes/Battle_UI_Production_Test.tscn`의 결과는 `d5e9bfa`와 `4edd9c3`(추가)뿐이다.
5. 컨트롤러는 없어진 세 라벨에 아직 값을 쓴다(`scripts/battle_web_import_test.gd:15910-15914`). `_set_production_label`이 null이면 건너뛰므로(`:15938-15941`) 오류는 없다. 쓰기만 남아 있다.
6. **이전 조사의 "지금 HUD는 `validate_p1c_battle_production_promotion`이 지킨다"는 맞지 않다.** P-1C 검증기(68줄)는 장면 UID, 스크립트 경로, `BattleUI/ProductionHudRoot` 문자열, `BattleSupplyHud` 노드, 샘플 문자열 금지, 월드맵 경로만 본다(`tools/validate_p1c_battle_production_promotion.py:24-32, 52-66`). 상단 HUD 노드, 기세 칸 수, 로스터 카드 자식, 숨김 기본값은 보지 않는다. P-1C 검증기는 CI 목록에도 없다(`.github/workflows/verify-c-track.yml:77-79`에는 lifecycle·B0b·B0c만 있다).
7. **실제 장면 결함 1건.** `Battle_Production.tscn`의 `AllyRosterHud/Slot01`에는 `UniqueSkillReadyIcon`이 없다(자식 목록 `:4512-4599`). 그 노드는 `UniqueSkillReadyIcon2`라는 이름으로 `Slot02` 밑에 있다(`:4617`, `offset_top = -102.0`, `unique_id=1168471520`). 이 이동은 `2cb0008`(08-14 "current_actor_hud 업로드")에서 생겼다. 로스터 컨트롤러는 `slot.get_node_or_null("UniqueSkillReadyIcon")`로 찾는다(`scripts/battle/presentation/production/battle_roster_hud_controller.gd:56, 81-82`). 그래서 아군 1번 카드의 고유특기 준비 아이콘은 켜지지 않는다(정적 추론, 실행 확인은 안 함). `Slot02`의 `UniqueSkillReadyIcon2`는 아무도 켜지 않아 계속 숨겨져 있다. 테스트 장면(`:4610`)과 이를 상속하는 Imjin 테스트 장면 2개도 같다. 지금 이 결함을 잡는 검증기는 3B0와 3B1 theme_font뿐이다.

## 1. 요약 표

| 검증기 | 검사 대상 | 실패 원인 | 현재 2D와 일치? | 분류 |
|---|---|---|---|---|
| `validate_t08_2_production_hud` | 테스트 장면의 HUD 루트 9개, 기세 칸 10, 라벨 8개, 숨김 기본값, 옛 HUD 숨김, 어댑터 필드 | 라벨 3개 삭제(`d5e9bfa`), Wrapper까지 세는 칸 수 버그(`9badf41`) | 실패 6건 모두 현재 장면과 불일치. 나머지 검사는 현재 장면에서 통과 | 기대값 수정 후보 |
| `validate_t08_3a_battle_ui_theme` | 상단 HUD 테마·변형·정렬·기본 텍스트·테마 호스트 집합·자산 추가 금지 | 라벨 삭제로 `KeyError` 중단. 끝까지 돌리면 오류 70건 이상 | 불일치(텍스트 `"1/30"`, `theme_override` 사용, 라벨 없음) | 삭제 후보 |
| `validate_t08_3b0_roster_content_parity` | 로스터 카드 자식·숨김, 테스트 브리지, `4d3a565` 대비 보호 파일·상단 영역 고정, 월드맵→Battle_Land | 보호 파일 변경(`c17a300`, `0ad905c`), 상단 영역 변경, 월드맵 경로(`10068a3`), Ally Slot01 아이콘 없음(`2cb0008`) | 아이콘 항목은 현재 장면이 틀림. 나머지는 옛 기준 | 씬이 잘못된 것 후보 |
| `validate_t08_3b1_hotfix1_status_placement` | StatusLabel 위치, 카드·아이콘·병종 좌표 `4d3a565` 고정, 보호 파일, 상단 영역 | 카드 `offset_top/bottom` 20건(`599d14c`, `f401118`), 보호 파일, 상단 영역 | StatusLabel 위치 검사는 통과. 고정 좌표는 의도된 재배치로 불일치 | 삭제 후보 |
| `validate_t08_3b1_roster_theme_font` | 로스터 테마 변형·글꼴 크기, 내용 좌표 고정, 숨김 계약, 보호 파일, 월드맵 경로 | 보호 파일, 상단 영역, Ally Slot01 아이콘 숨김 계약(`2cb0008`), 월드맵 경로 | 아이콘 항목은 현재 장면이 틀림. 테마·글꼴·내용 좌표는 통과 | 씬이 잘못된 것 후보 |
| `validate_t08_3c_bottom_hud` | 테스트용 하단 미리보기(샘플 문자열 포함), 테마 변형, 영역 경계·겹침, 보호 파일, 상단·로스터 루트 고정 | 어댑터 변경(`0ad905c`), 상단 영역, 로스터 루트 좌표(`599d14c` 등) | 불일치. 샘플 미리보기 요구는 P-1C 규칙(샘플 금지)과 반대 | 삭제 후보 |
| `validate_t08_battle_scene_isolation` | 런타임=Battle_Land, 제품 HUD=격리 테스트 장면, 월드맵→Battle_Land | Wrapper까지 세는 칸 수 버그, 월드맵 경로(`10068a3`) | 불일치. 격리 전제 자체가 P-1C/P-1D로 끝남 | 삭제 후보 |
| `validate_korea_mvp_video_cutin_routing` | 컷인 레지스트리 별칭·OGV·제목 자원, 영상 우선 경로, 깃발·아이콘 비유입 | 정지 대체 이미지 경로 상수에 `unique_skill_ready_icon` 문자열(`a103871`) | 영상 우선 경로는 현재 코드와 일치. 부분 문자열 검사만 걸림 | 기대값 수정 후보 |

### 겹치는 검증기 실행 결과 (기준 커밋, 인자 없음)

| 검증기 | 결과 | 보는 것 |
|---|---|---|
| `validate_p1c_battle_production_promotion` | `P-1C Battle production promotion static validation: PASS` | 장면 UID·스크립트·`ProductionHudRoot` 문자열·`BattleSupplyHud`·샘플 금지·월드맵 경로 |
| `validate_b0b_battle_production_skeleton` (CI) | `B-0B canonical battle production skeleton static validation: PASS` | Battle_Main → Battle_Production, 월드맵 경로 |
| `validate_b0c_battle_iso_promotion` (CI) | `B-0C production ISO promotion static validation: PASS` | ISO 모듈 승격, 테스트 장면 스크립트 경로, 월드맵 경로 |
| `validate_worldmap_to_battle_input_lifecycle` (CI) | `WORLDMAP TO BATTLE INPUT LIFECYCLE PASS: canonical Battle_Main route; ...` | 월드맵 → Battle_Main 전환·입력 |
| `validate_t08_roster_portrait_only_mode` | `T08 ROSTER PORTRAIT-ONLY VALIDATION PASSED` | 테스트 장면 로스터 접기 스크립트 |
| `validate_all_korea_mvp_video_cutins` | `ALL KOREA MVP VIDEO CUTINS VALIDATION PASS: 13 registry/resource contracts ...` | 레지스트리·자원 |
| `validate_korea_mvp_cutin_parity` | `[CUTIN_PARITY] 13/13 PASS` | 장수·특기 짝 |
| `validate_actual_video_cutin_playback` | `ACTUAL VIDEO CUTIN PLAYBACK VALIDATION PASS: ... video-first trace, explicit static fallback trace` | 영상 우선·정지 대체 경로 |

대상 8개는 모두 exit=1이다.

## 2. 검증기별 근거

### 2.1 `validate_t08_2_production_hud.py` (114줄)

- (a) 검사: 테스트 장면(`:8`)의 루트 9개(`:55-58`), 편당 기세 칸 10과 `ValueLabel`(`:60-66`), 라벨·패널 8개(`:73-75`), 높이·화면 경계(`:77-90`), 숨김 기본값 3개(`:92-94`), 옛 HUD 숨김 코드(`:95-98`), 어댑터 필드 18개(`:103-106`), 이동 버튼 문구(`:107-108`).
- (b) 실패 출력:
  ```
  T08-2 HOTFIX1 HUD VALIDATION FAILED
  ERROR: Ally momentum slot count is 20, expected 10
  ERROR: missing Ally momentum value label
  ERROR: Enemy momentum slot count is 20, expected 10
  ERROR: missing Enemy momentum value label
  ERROR: missing ActiveSideLabel
  ERROR: missing BattleTitleLabel
  ```
  - 칸 수 20: `:64`가 `SlotNNWrapper`까지 센다. Wrapper는 `9badf41`이 넣었다. 실제 칸은 10이다(`Battle_Production.tscn:4005-4167`, `:4247-4409`).
  - 라벨 3개: `d5e9bfa`가 지웠다.
- (c) 현재 `Battle_Production.tscn` TopHudRoot(`:3947-4421`)에는 `Frame`, `SlotRow`, `TurnLabel`만 있다. 실패 6건의 기대는 현재와 다르다. 나머지 검사는 현재 장면에서도 통과한다(오류가 6건뿐이다).
- (d) **기대값 수정 후보.** 실패 항목은 의도된 정리(`d5e9bfa`)와 검증기 세기 버그다. 통과하는 나머지 항목(루트 9개, 로스터 카드 5칸, 숨김 기본값, 어댑터 필드)은 P-1C·B0b·B0c 어디에서도 보지 않는다. 대상 장면도 테스트 장면이지 `Battle_Production.tscn`이 아니다.

### 2.2 `validate_t08_3a_battle_ui_theme.py` (141줄)

- (a) 검사: 테마 파일·NotoSerifKR 글꼴·변형 12개(`:61-69`), 상단 패널 테마(`:71-78`), 라벨 8개의 변형·가운데 정렬(`:80-90`), 칸 줄 위치 `offset_left = 33.0`·칸 10(`:92-101`), 상단 HUD에 `theme_override_` 금지(`:103-105`), 테마 호스트 집합 고정(`:106-118`), 기본 텍스트 `"3 / 10"`·`"1 / 30"`(`:121-123`), 월드맵→Battle_Land(`:127`), `origin/main..HEAD` 범위에 이미지·글꼴 추가 금지(`:132-134`).
- (b) 실제 출력은 `:90`에서 중단된다.
  ```
  KeyError: 'BattleUI/ProductionHudRoot/TopHudRoot/AllyMomentumHud/ValueLabel'
  ```
  워크트리 밖 사본으로 끝까지 돌린 결과(일부):
  ```
  ERROR: Ally slot count is 20, expected 10
  ERROR: static theme_override remains in top HUD: BattleUI/ProductionHudRoot/TopHudRoot/TurnHud/Frame
  ERROR: Theme leaked outside the isolated Production HUD hosts
  ERROR: default turn text changed
  ERROR: WorldMap battle route changed
  ERROR: new image/font asset in T08-3A range: assets/worldmap/ui/worldmap_turn_compass.png
  ```
  자산 항목은 `origin/main`(`66b29ba`)과 HEAD 차이를 보므로 실행 환경에 따라 결과가 바뀐다. 상단 영역은 `4d3a565` 뒤 12개 커밋이 바꿨다(`340c067`, `8b4b572`, `d5e9bfa`, `449e05b`, `11bcf6a`, `1680e84`, `9badf41`, `f10a63d`, `6f7d4c2`, `f401118`, `e7201f5`, `6561219`).
- (c) 현재 장면 `TurnLabel` 기본 텍스트는 `text = "1/30"`이다(`Battle_Production.tscn:4209`). 라벨 4개가 없다. 불일치다.
- (d) **삭제 후보.** 08-02 테마 1차 작업의 모양을 고정한 검사다. 그 뒤 상단 HUD는 프레임 이미지·`theme_override`를 쓰는 방식으로 다시 만들어졌다. 남는 검사(테마 파일에 변형 이름 존재, 글꼴 파일 존재)만으로는 현재 HUD를 지키지 못한다. 같은 것을 보는 다른 검증기는 없다.

### 2.3 `validate_t08_3b0_roster_content_parity.py` (113줄)

- (a) 검사: 테스트 브리지 연결(`:60-62`), 보호 파일이 `4d3a565`와 같음(`:64-65`), 상단 영역이 `4d3a565`와 바이트 단위로 같음(`:67-74`), 카드마다 자식 7개와 타입(`:76-90`), 숨김 5개(`:91-93`), 브리지 금지어(`:99-100`), 월드맵→Battle_Land(`:106`).
- (b) 실패 출력:
  ```
  T08-3B0 ROSTER CONTENT PARITY VALIDATION FAILED
  ERROR: protected file changed from baseline: Battle_Land.tscn
  ERROR: protected file changed from baseline: scripts/battle/ui/battle_hud_state_adapter.gd
  ERROR: T08-3A top HUD geometry/theme slice changed
  ERROR: missing UniqueSkillReadyIcon at BattleUI/ProductionHudRoot/AllyRosterHud/Slot01
  ERROR: BattleUI/ProductionHudRoot/AllyRosterHud/Slot01/UniqueSkillReadyIcon is not default hidden
  ERROR: WorldMap battle route changed
  ```
  - `Battle_Land.tscn`: `c17a300`(08-02 Godot 재저장, 45줄 추가·42줄 삭제).
  - 어댑터: `0ad905c`(09-19 P-1D hotfix, 비활성 슬롯 건너뛰기 3줄).
  - 월드맵: `10068a3`(P-1D). 지금 `scripts/worldmap/worldmap_main.gd:152`는 `res://scenes/battle/Battle_Main.tscn`.
  - 아이콘: `2cb0008`이 Slot01의 아이콘을 `Slot02/UniqueSkillReadyIcon2`로 옮겼다.
- (c) 아이콘 2건은 **현재 장면 쪽 결함**이다(0절 7번). 같은 카드 구조의 나머지 9칸에는 `UniqueSkillReadyIcon`이 있다(`Battle_Production.tscn:4726, 4843, 4960, 5077, 5246, 5363, 5480, 5597, 5714`). 보호 파일·상단 영역·월드맵 4건은 의도된 변경이라 옛 기준이다.
- (d) **씬이 잘못된 것 후보.** 이 검증기의 실패 중 아이콘 2건은 현재 `Battle_Production.tscn`에도 있는 결함을 가리킨다. 다른 통과 검증기(P-1C, B0b, B0c, lifecycle, portrait_only)는 로스터 카드 자식을 보지 않는다. 나머지 4건은 기준 갱신 없이는 계속 실패한다.

### 2.4 `validate_t08_3b1_hotfix1_status_placement.py` (108줄)

- (a) 검사: 보호 파일(`:62-63`), 상단 영역(`:65-68`), StatusLabel 숨김·좌표 `80/66/188/88`·HpLabel 아래·병종 라벨과 안 겹침·카드 안(`:81-91`), 카드·병종 라벨·병종 아이콘 좌표가 `4d3a565`와 같음(`:92-94`), 브리지 문구(`:96-101`).
- (b) 실패 출력(앞부분과 개수):
  ```
  T08-3B1-HOTFIX1 STATUS PLACEMENT VALIDATION FAILED
  ERROR: protected file changed from baseline: Battle_Land.tscn
  ERROR: protected file changed from baseline: scripts/battle/ui/battle_hud_state_adapter.gd
  ERROR: T08-3A top HUD slice changed
  ERROR: locked geometry changed: BattleUI/ProductionHudRoot/AllyRosterHud/Slot01 offset_top
  ERROR: locked geometry changed: BattleUI/ProductionHudRoot/AllyRosterHud/Slot01 offset_bottom
  ...
  ERROR: locked geometry changed: BattleUI/ProductionHudRoot/EnemyRosterHud/Reinforce02 offset_bottom
  ```
  좌표 오류는 카드 10장 × `offset_top/offset_bottom` = 20건이다. Ally Slot01은 기준에서 `offset_top` 없음·`offset_bottom = 92.0`, 지금 `46.0`·`138.0`이다. 카드 좌표는 `599d14c`(08-03 "T12-1 add production roster headers and offset cards")와 `f401118`(08-03 "로스터 정리 끝")이 바꿨다.
- (c) StatusLabel 위치·숨김·겹침 검사는 오류가 없다. 즉 현재 장면과 맞다. 카드 고정 좌표는 의도된 재배치로 현재와 다르다.
- (d) **삭제 후보.** 실패는 모두 고정 기준값(`4d3a565` 해시·좌표)이다. 통과하는 StatusLabel 위치 규칙을 지키는 다른 검증기는 없다. 이 규칙을 남길지는 따로 정할 일이다.

### 2.5 `validate_t08_3b1_roster_theme_font.py` (146줄)

- (a) 검사: 보호 파일(`:69-70`), 상단 영역(`:72-77`), 로스터 테마 변형 8개·글꼴 크기 19/15/14(`:79-91`), 기존 상단 변형이 기준과 같음(`:92-94`), 카드·라벨 변형(`:96-118`), 내용 노드 좌표가 기준과 같음(`:119-125`), 숨김 5개(`:126-128`), 월드맵→Battle_Land(`:139`).
- (b) 실패 출력:
  ```
  T08-3B1 ROSTER THEME/FONT VALIDATION FAILED
  ERROR: protected file changed from baseline: Battle_Land.tscn
  ERROR: protected file changed from baseline: scripts/battle/ui/battle_hud_state_adapter.gd
  ERROR: T08-3A top HUD geometry/theme slice changed
  ERROR: hidden contract broken: BattleUI/ProductionHudRoot/AllyRosterHud/Slot01/UniqueSkillReadyIcon
  ERROR: WorldMap battle route changed
  ```
  원인 커밋은 2.3과 같다(`c17a300`, `0ad905c`, 상단 영역 커밋들, `2cb0008`, `10068a3`).
- (c) 테마 변형·글꼴 크기·카드 내용 좌표(Portrait, NameLabel, HpLabel, TroopIconRect, TroopTypeLabel)는 오류가 없다. 현재와 맞다. 아이콘 1건은 현재 장면 결함이다.
- (d) **씬이 잘못된 것 후보.** 2.3과 같은 아이콘 결함을 잡는다. 아이콘 존재는 2.3이 더 직접 본다(`missing UniqueSkillReadyIcon`). 두 검증기가 같은 결함을 겹쳐 본다.

### 2.6 `validate_t08_3c_bottom_hud.py` (126줄)

- (a) 검사: 보호 파일 3개(`:18-21, 76-78`, `Battle_Land`만 `c17a300` 기준), 상단 영역(`:80-82`), 로스터 루트 본문이 기준과 같음(`:83-85`), 하단 영역 4개·보급 칸(`:87-99`), 테스트 미리보기 스크립트 연결과 샘플 경고 문구 `"소금 고갈 · 식량 소비 +10%"`(`:100-102`), 테마 변형 16개(`:103-110`), 경계·겹침(`:112-120`).
- (b) 실패 출력:
  ```
  T08-3C BOTTOM HUD VALIDATION FAILED
  ERROR: protected file changed: scripts/battle/ui/battle_hud_state_adapter.gd
  ERROR: top HUD slice changed
  ERROR: roster root changed: Ally
  ERROR: roster root changed: Enemy
  ```
  어댑터는 `0ad905c`. 로스터 루트는 `599d14c`, `e578756`, `b11c2b5`, `e7201f5`, `6561219`가 바꿨다. 지금 Ally 루트는 `offset_left = 57.0`, `offset_top = 148.0`, `offset_right = 327.0`, `offset_bottom = 672.0`.
- (c) 하단 영역 경계·겹침·테마 변형 검사는 오류가 없다. 다만 이 검증기는 테스트용 샘플 미리보기(`tests/scripts/battle_ui_production_test_bottom_hud.gd:7` `SHOW_WARNING_SAMPLE := false`)를 요구한다. `Battle_Production.tscn`은 대신 `battle_current_actor_hud_controller.gd`를 쓰고, P-1C 검증기는 그 파일에 샘플 문자열이 **없어야** 한다고 본다(`validate_p1c_battle_production_promotion.py:54-55`). 방향이 반대다.
- (d) **삭제 후보.** 실패는 모두 고정 기준값이다. 제품 하단 HUD는 P-1C(PASS)가 일부 본다(샘플 금지, `BattleSupplyHud` 존재). 경계·겹침 검사는 P-1C에 없다.

### 2.7 `validate_t08_battle_scene_isolation.py` (98줄)

- (a) 검사: 런타임 장면=`Battle_Land.tscn`에 `ProductionHudRoot` 없음(`:64`), 테스트 장면에만 제품 HUD(`:65`), 런타임 옛 노드 11개(`:66-70`), 테스트 기세 칸 10(`:71-74`), null 안전 코드(`:76-83`), 기세 상수 3·10, 최대 턴 30(`:84-87`), 월드맵→Battle_Land(`:88-89`), 테스트 장면이 진입 경로에 없음(`:90-91`).
- (b) 실패 출력:
  ```
  T08 BATTLE SCENE ISOLATION VALIDATION FAILED
  ERROR: test Ally momentum must have 10 slots
  ERROR: test Enemy momentum must have 10 slots
  ERROR: WorldMap battle entry no longer targets Battle_Land.tscn
  ```
  칸 수는 2.1과 같은 Wrapper 세기 버그(`9badf41`). 월드맵은 `10068a3`.
- (c) 지금 진입 장면은 Battle_Main → Battle_Production이다. "제품 HUD는 테스트 장면에만 있다"는 전제가 P-1C/P-1D로 끝났다. 불일치다.
- (d) **삭제 후보.** 진입 경로는 lifecycle·B0b·B0c(CI, 모두 PASS)와 P-1C(PASS)가 새 기준으로 본다. 기세 상수 3·10 검사는 `validate_t06_t07_playable_transaction.py`에도 있다(`grep` 결과). 최대 턴 30은 이 검증기와 3A에만 있다.

### 2.8 `validate_korea_mvp_video_cutin_routing.py` (59줄)

- (a) 검사: 런타임 별칭 5개(`:28-36`), 활성 항목의 영상·제목 자원과 OGV(`:37-47`), 레지스트리 소스·JSON에 `reinforcement_arrival_toast`·`unique_skill_ready_icon` 문자열 금지(`:48-50`), 영상 우선 경로 문구 3개(`:51-53`).
- (b) 실패 출력:
  ```
  KOREA MVP VIDEO CUTIN ROUTING VALIDATION FAILED
  ERROR: unrelated flag/icon leaked into cutin registry: unique_skill_ready_icon
  ```
  걸린 줄은 `scripts/ui/cutin/korea_mvp_hero_cutin_registry.gd:36`
  `const GENERIC_STATIC_FALLBACK_IMAGE_PATH := "res://assets/web_battle/ui/formation_guide/unique_skill_ready_icon.png"`.
  `a103871`(08-08)이 넣었다. JSON에는 없다.
- (c) 그 상수는 `get_static_fallback_image_path`의 마지막 대체로만 쓰인다(`:157-167`). 컨트롤러는 레지스트리 영상을 먼저 찾고(`scripts/battle_web_import_test.gd:4754`, `:4801`), 항목이 없을 때만 정지 대체를 고른다(`:4802-4808`). 영상 우선 규칙은 현재 코드와 맞다. 별칭·자원·경로 문구 검사도 통과했다(오류가 1건뿐).
- (d) **기대값 수정 후보.** 부분 문자열 검사가 경로 상수의 파일 이름까지 잡은 오탐이다. 영상 우선·정지 대체 순서는 `validate_actual_video_cutin_playback`(PASS: "video-first trace, explicit static fallback trace")과 `validate_korea_mvp_cutin_parity`(13/13 PASS)도 본다. 그 아이콘을 기본 컷인 이미지로 쓰는 것이 의도인지는 정해지지 않았다(이전 조사·갱신 결과 문서 모두 "김작 확인 대기").

## 3. 확인 못 한 것

- Godot를 실행하지 않았다. 아군 1번 카드 고유특기 아이콘이 실제로 안 켜지는지는 정적 추론이다. 화면에서 확인하지 않았다.
- `2cb0008`의 아이콘 이동이 실수인지 의도인지는 커밋 메시지("current_actor_hud 업로드")만으로 알 수 없다. 이름이 `UniqueSkillReadyIcon2`로 바뀌었고, 위치를 `offset_top = -102.0`으로 맞춰 화면상 Slot01 자리에 두려 한 흔적이 있다.
- 컨트롤러가 없는 라벨 3개에 값을 쓰는 코드(`battle_web_import_test.gd:15910-15914`)가 다른 장면(Battle_Land 등)에서 아직 쓰이는지는 확인하지 않았다.
- 3A의 `origin/main..HEAD` 자산 검사는 로컬 `origin/main` 참조(`66b29ba`)에 따라 결과가 달라진다. 다른 환경 결과는 보지 않았다.
- 3A 끝까지 돌린 오류 수는 사본 출력 기준이다. 원본은 `KeyError`로 중단된다.
- 이전 조사 문서(`LEGACY_VALIDATORS_TRIAGE_20261022.md`)의 기준 커밋은 `8957b27`이다. 이번 기준 `ba058c8`과 결과가 같은지는 실패 메시지로만 비교했다.
- 테스트 장면(`tests/scenes/Battle_UI_Production_Test.tscn`)을 앞으로 계속 쓸지는 이 조사 범위 밖이다. 지금 B0c 검증기, Imjin 테스트 장면 2개, `verify_battle_supply_hud_mock.gd`, `validate_imjin_demo_test2.py`, `validate_worldmap_supply_and_production_log_contract.py`가 이 장면을 참조한다.
