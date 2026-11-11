기준 화면: 새 장면 `scenes/battle3d/Battle3D_NavalHansando.tscn` (F6) — 기존 3D 전투 셸을 수전 설정으로 연 것. 육전 `Battle3D_ScenarioShell.tscn`은 그대로.
합격 기준: 지시서(큐 35, 19:40판)와 답신 1 맨 위 그대로. 김작이 F6로 바다 전장에서 배를 육전과 같은 조작으로 이동·공격하고, 얼굴 칩·병력 바가 보이고, 학익진을 쓰고, F9로 캡처가 저장되면 합격. 육전 F6는 이전과 같아야 한다.

# REPORT_NAVAL_HANSANDO — 한산도 수전 시나리오 (클코드, 2026-11-10, 큐 35번 답신 1 A안)

- **됐나**: 됐다(자동 검증 기준). 김작 F6 확인 전이다.
- **가지**: `feature/wm3d-naval-20261110` (`main` `8cc0640`에서). `main` 푸시 없음.
- **한 일**: 엔진 시작 설정에 수전 항목을 더했고(답신 1), 그 위에 바다 판·배 4종 규칙·배 모형·화포 연출·F9 캡처·수전 장면을 얹었다. 새 항목이 없으면 육전은 그대로다.
- **김작이 정할 것 3가지** (5절): 병력 숫자(엔진 피해가 고정값이라 설계값을 1/25로 넘김), 배 모형(지금은 임시 모형), 화면 아래 지형 칸의 "평지" 글자.
- STOP 조사표: `agent/REPORT_NAVAL_HANSANDO_STOP_20261110.md` 1절(`a0e43d5`). 조사 결과는 그대로 유효하다.

## 1. §4 조사표 (STOP 보고서 1절 요약) + 답신 뒤 실제로 쓴 자리
| # | 질문 | 조사 결과 | 실제 구현 |
|---|---|---|---|
| 1 | 수전 규칙을 추가로 읽을 자리 | `UnitTypeContract.is_supported()`·`get_rule()` | 그 두 함수 + 읽기 함수 `naval_rules()`·`is_naval()`. 5종은 수전 파일을 건드리지 않는다 |
| 2 | 시나리오별 병종 지정 | 없었다(멈춤 사유) | 답신 1: 시작 설정 `unit_overrides[*].unit_type` 등 |
| 3 | 막힌 칸을 시나리오별로 | 된다(`forest_cells()`) | `forest_cells()`가 `island`도 모은다 |
| 4 | 학익진 수전/육상 구분 | 구분한다(`battle_type`) | 시작 설정 `battle_type`을 `build_plan`에 넘긴다(월드맵 문맥 우선) |
| 5 | AI와 새 병종 | `ai_behavior_profile`은 어떤 코드도 읽지 않는다 | 그대로. 배도 육전과 같은 적 AI로 움직인다 |
| 6 | 셸·땅 경로 | 고정 경로 | 셸 `naval_scenario_path`, `lab_heightfield.gd` `source_paths` |

## 2. 만든 것
### 2-1. 엔진 시작 설정의 수전 항목 (답신 1)
새 서비스 `scripts/battle/services/battle_setup_naval_service.gd`가 전부 처리한다. 엔진은 부르기만 한다.
- 최상위: `battle_type`("naval"/"land"), `arrival_round_overrides`, `blocked_cells`(아래 3절 ④).
- `unit_overrides[unit_id]`: `unit_type`, `hero_id`, `troops`, `grid_cell`, `facing`. 새 키가 하나라도 있으면 `troops_ratio` 없이 적용한다.
- 잘못된 값은 엔진의 기존 `[BATTLE_SETUP] ignored: …` 줄로 남기고 무시한다. 전투는 정상 시작한다.
- `battle_type`은 엔진 노드의 메타에만 둔다. 월드맵 문맥(`worldmap_battle_context`)에는 쓰지 않는다.

### 2-2. 수전 쪽 새 파일
| 파일 | 내용 |
|---|---|
| `data/battle3d/naval_unit_type_rules.json` | 배 4종 규칙(육전 규칙 파일과 같은 칸 + `weapons`, `ship_length`) |
| `data/battle3d/naval_hansando_scenario.json` | 한산도 대본: 배 10척의 병종·장수·병력·칸·방향, 바다 판 파일 경로 |
| `assets/battle3d/naval/heightfield_hansando.json`, `terrain_types_hansando.json` | 바다 판(20×20, 바다 높이 0, 섬). `tools/build_naval_hansando_terrain.py`로 만든다 |
| `scripts/battle3d/naval/battle3d_naval_scenario.gd` | 대본 읽기, 엔진 시작 설정 만들기 |
| `scripts/battle3d/naval/battle3d_naval_lab_setup.gd` | 수전일 때 랩에 바다·배·캡처 노드를 꽂는다 |
| `scripts/battle3d/naval/naval_sea_builder.gd` | 바다 판 그리기(강 물 셰이더 재사용), 섬, 섬 나무, 먼 섬 실루엣 |
| `scripts/battle3d/naval/battle3d_ship_visuals.gd` | 배 모형·흔들림·무기 발사·피격·침몰 |
| `scripts/battle3d/naval/battle3d_cannon_fx.gd` | 화포: 포구 섬광·연기, 포탄 호, 물기둥/피격 연기, 침몰 연기 |
| `scripts/battle3d/naval/battle3d_naval_overlay.gd` | 제목 "한산도 대첩", F9 / Shift+F9 캡처 |
| `scenes/battle3d/Battle3D_NavalHansando.tscn` | 셸 + `naval_scenario_path` |

### 2-3. 바다 전장
- 판 20×20 전부 바다. 강의 물 셰이더(`eastwar_terrain_20x20_water.gdshader`)를 그대로 써서 잔물결·섬 둘레 거품·경계선·판 밖 안개가 육전과 같은 방식이다.
- 엔진이 움직이는 판(18×10) 안의 섬은 5덩어리 17칸(막힌 칸): 북쪽 물길을 만드는 섬 2개(5칸씩, 물길 폭 3칸), 가운데 작은 섬 2개(1칸·2칸), 남쪽 한산도(4칸). 판 밖에도 섬 6덩어리와 먼 실루엣 8개.
- 섬은 자기 칸 안쪽 0.25 m에서만 솟는다. 옆 칸의 배와 겹치지 않는다. 지명 글자는 없다.

### 2-4. 배
- 배 1척 = 1칸. 길이는 규칙 파일의 `ship_length`(안택선 2.8 / 판옥선 2.6 / 거북선 2.4 / 관선 2.2 m).
- `assets/battle3d/naval/<병종>.glb`가 있으면 그 모형을 쓰고 길이에 맞춰 자동으로 줄이거나 돌린다. **지금은 4종 모두 없어서 임시 모형**(상자 조합)이다.
- 아군 푸른 깃발, 적 붉은 깃발. 롤·피치 ±2° 흔들림(배마다 위상 다름). 이동은 육전처럼 칸을 따라가며 뱃머리를 진행 방향으로 돌린다.
- 무기는 규칙 파일 `weapons` 순서대로 0.45초 간격: 거북선 화포 / 판옥선 화포→화살 / 안택선 조총→화살 / 관선 조총.
- 병력 0이면 그 자리에서 기울며 2.6초 동안 가라앉고 연기가 난다. 로스터 카드는 육전처럼 "퇴각"으로 남는다.

### 2-5. 캡처
- F9: 화면 그대로. Shift+F9: 2D(HUD·얼굴 칩·제목)를 끄고. 디버그·에디터 실행에서만.
- 저장: `C:\eastwar_tmp\naval\captures\hansando_<날짜>_<시각>.png` (HUD 없는 것은 끝에 `_nohud`). 폴더를 못 만들면 `user://captures/`.

## 3. 바꾼 기존 파일 (7개)
| 파일 | 줄(바뀐 뒤) | 무엇을 | 기본값에서 안 바뀌는 근거 |
|---|---|---|---|
| `scripts/battle_web_import_test.gd` | 895 | 서비스 preload 한 줄 | 선언만 |
| 〃 | 1543 | `_read_battle_setup_port()`: 유닛 덮어쓰기 뒤 `finish()` 호출 | 새 최상위 키와 대기 중인 칸이 없으면 `finish()`는 아무것도 쓰지도 찍지도 않는다 |
| 〃 | 1559-1564 | `_apply_battle_setup_unit_override()`: 새 유닛 키가 있으면 적용, 없으면 기존 줄 그대로 | 새 키가 없으면 `has_naval_keys`가 거짓이라 기존 흐름·기존 로그와 같다 |
| 〃 | 4553, 4735 | `build_plan`의 `battle_type` 인자 | 문맥에 값이 있으면 그 값, 없고 설정도 없으면 `"land"` — 이전 식과 같은 결과 |
| `scripts/battle/unit_type_contract.gd` | 13-45 | 수전 규칙 파일을 추가로 읽기 | 5종은 먼저 걸러져 수전 파일을 읽지 않는다. 5종 값은 이전과 같은 함수에서 온다 |
| `scripts/battle3d/lab_heightfield.gd` | 16-28 | 판 파일 경로를 `source_paths`로 바꿀 수 있게 | 기본 `{}`이면 이전 고정 경로 |
| `scripts/battle3d/lab_presentation.gd` | 19-21, 50, 128 | 땅 만드는 스크립트·병사 모형 스크립트를 변수로 | 기본값이 이전 스크립트 |
| `scripts/battle3d/battle3d_engine_play.gd` | 168, 182, 735 | 배는 병종 아이콘 없음 / 배 이름 표시 / `island`도 막힌 칸 | 5종은 `is_naval()`이 거짓. 육전 판에는 `island` 칸이 없다 |
| `scripts/battle3d/battle3d_scenario_shell.gd` | 12-13, 23-29, 215, 228-243, 279, 285-288, 339, 471-472, 478 | `naval_scenario_path`, 수전 시작, 랩에 수전 설정 꽂기, 현재 행동 패널의 배 이름 | `naval_scenario_path` 기본 `""`이면 수전 가지로 들어가지 않는다 |
| `.github/workflows/verify-c-track.yml` | 424-425 | 새 시험 2개를 마지막 목록 끝에 등록 | 끝에 붙여서 기존 시험의 shard 배정이 바뀌지 않는다 |

- `worldmap_main.gd` 0줄. `data/heroes/generated/*.json` 0줄. `battle3d_ranged_fx.gd`·`battle3d_unit_markers.gd`·`terrain_board_builder.gd` 0줄. 기존 시험·검사기 기대값 변경 0.

### 답신 1과 다르게 된 곳 (클코치 확인 필요)
1. **엔진 수정 자리가 답신의 세 자리보다 2줄 많다.** ① 서비스 preload 한 줄(895). ② `build_plan`에 `battle_type`을 넘기는 줄이 한 곳이 아니라 **두 곳**(4553 점수 계산, 4735 실제 발동)이라 둘 다 바꿨다. 한 곳만 바꾸면 미리보기와 실제 범위가 달라진다.
2. **적용 순서**: 답신은 병종 → 장수 순서였다. 장수를 넣으면 엔진이 그 장수의 병종·이동 거리로 다시 계산하므로, 병종 값은 먼저 검사하고 **장수를 적용한 뒤에** 병종을 적용했다. 결과는 답신이 뜻한 것과 같다(장수 + 덮어쓴 병종).
3. **`arrival_round_overrides`**: `0`(시작부터 배치)은 증원 4슬롯 모두 된다. 0이 아닌 값은 `*_reinforce_02`만 된다. `*_reinforce_01`의 도착 라운드(2)는 엔진 함수 안에 숫자로 박혀 있어서(`_try_deploy_reinforce_01_pair`) 세 자리 밖이다. 이번 대본은 0만 쓴다.
4. **최상위 키 `blocked_cells`를 하나 더 받는다.** 랩은 엔진 `_ready()`가 끝난 뒤에 막힌 칸을 넘기기 때문에, 시작 설정을 읽는 시점의 엔진은 섬을 모른다. "막힌 칸이면 무시"를 지키려고 섬 칸 목록을 설정에 같이 넣었다(검사에만 쓴다).
5. **셸 수정이 "경로 받기"보다 넓다.** 현재 행동 패널이 병종 이름을 장수 데이터에서 읽어서(`current_actor()`), 배일 때는 유닛의 병종을 쓰도록 2줄을 더했다.

## 4. 시험
- 새 시험 2개 (C-track 등록):
  - `tests/scripts/test_battle_setup_naval_keys.gd` — `[BATTLE_SETUP_NAVAL] checks=64 failures=[]` (답신 S1~S5, 엔진만)
  - `tests/scripts/test_battle3d_naval_hansando.gd` — `[NAVAL_HANSANDO] checks=156 failures=[]` (지시서 1~8, 수전 장면)
- 지시서·답신 항목별:
  | 항목 | 결과 |
  |---|---|
  | 1 장면 로드, 배 10척, 장수 10명 존재 | 통과 |
  | 2 / S3 배 4종 이동 거리 = 규칙 파일 | 통과(도달 칸 수를 시험이 따로 센 값과 비교) |
  | 3 섬 진입 불가, 양쪽 도달 가능 | 통과(17칸 모두 경로 없음, 10척 모두 적 5척에 도달) |
  | 4 무기 연출 | 통과(병종마다 규칙 순서대로, 화포·화살·조총 효과 기록) |
  | 5 침몰, 승패 판정 | 통과 |
  | 6 GLB 없을 때 임시 모형 | 통과. 받은 모형을 길이에 맞추는 것도 가짜 모형으로 확인 |
  | 7 끝까지 자동 진행 + 학익진 | 통과. 학익진은 시험이 랩의 특기 명령으로 1회 발동(기세·적 위치만 시험이 배치). 대상에서 3칸 떨어진 배도 맞았다(수전 반경 3) |
  | 8 / S1 수전 설정 없을 때 육전 불변 | 통과. `test_battle_setup_port_s4_3`(58)·`…base_parity_shard_1`(36)·`…shard_2`(36) 기대값 그대로 |
  | S2 `battle_type` 우선순위 | 통과(문맥 > 설정 > land, 6가지 조합) |
  | S4 잘못된 값 | 통과(13가지 모두 무시 + 로그, 전투 정상 시작) |
  | S5 도착 라운드 0 | 통과(1라운드에 10척, 증원 이벤트 0) |
- 전체 로컬 검사: `verify-c-track.yml`의 Godot 시험 210개(새 시험 2개 포함) 전부 통과(4개 동시 실행, 가장 오래 걸린 것 `test_battle3d_command_panel` 173초), 파이썬 검사기 72개 전부 통과. 새 스크립트의 GDScript 경고 0.
- CI: Verify C-track refactor `42832011165`(`57bae9f`) 4 shard 전부 success. 첫 실행 `42828138719`(`1165036`)은 shard 2 실패 — 새 수전 시험이 결과 화면을 프레임 수로 기다린 한 줄 때문이었고, 시간으로 기다리게 고친 시험 커밋 `57bae9f`로 해결했다(제품 코드 변경 없음). Verify WorldMap3D는 경로 조건에 안 걸려 실행되지 않았다.

## 5. 김작·클코치가 볼 것
1. **병력 숫자.** 엔진의 기본 공격 피해는 고정값(아군 12, 적 8)이다. 지시서 표의 병력(2000~3500)을 그대로 넣으면 전투가 끝나지 않는다. 그래서 대본에 설계값(`troops_design`)을 남기고 **1/25(`troops_scale`)로 줄인 값**(80~140)을 엔진에 넘겼다. 화면에는 "병력 120 / 120"처럼 보인다. 3000으로 보이게 하려면 피해 식을 바꾸는 별도 작업이 필요하다.
2. **배 모형은 임시다.** 록비서 모형 4개를 `assets/battle3d/naval/`에 부록 A 이름으로 넣으면 코드 수정 없이 바뀐다.
3. **화면 아래 지형 칸이 "평지"로 나온다.** 현재 행동 패널의 지형 칸은 원래 고정 글자다(육전도 같다). 이번 범위에서 건드리지 않았다.
4. 배는 한 칸(3 m)보다 작아서 가장 멀리 본 화면에서는 작게 보인다. 캡처는 휠로 당겨서 찍는 편이 낫다(증거 ③④⑥이 당긴 화면).
5. 규칙 값(이동·사거리·피해 배율)은 지시서 표 그대로다. "근접 강함"은 주는 피해 +10%(거북선), +8%(안택선)로 넣었다. `data/battle3d/naval_unit_type_rules.json`에서 바꿀 수 있다.
6. 판옥선은 사거리 2~3이라 **붙어 있는 적은 공격하지 못한다**(지시서 표 그대로).

## 6. 증거 (창 모드 1920×1080 실제 실행, `agent/evidence/naval_hansando/`)
| 파일 | 내용 |
|---|---|
| `01_overview.jpg` | ① 전장 전경(섬 포함), 시작 배치 |
| `02_move_range.jpg` | ② 거북선 이동 범위 표시 |
| `03_cannon_broadside.jpg`, `03b_arrows.jpg` | ③ 판옥선 화포 사격, 이어지는 화살 |
| `04_turtle_ship_attack.jpg` | ④ 거북선 근접 공격 |
| `05a_hakikjin_targets.jpg`, `05_hakikjin_cutin.jpg`, `05b_hakikjin_toast.jpg` | ⑤ 학익진 대상 선택·컷인·토스트 |
| `06_sinking.jpg` | ⑥ 격파 뒤(로스터 "퇴각"). 가라앉는 순간은 화면 오른쪽 밖이라 이 장에는 잘 안 잡혔다 |
| `07_overview_no_hud.jpg` | ⑦ HUD 뺀 전경(Shift+F9 방식) |
| `08_auto_battle.jpg` | 자동 전투 중 |

- 모두 장면의 F9 캡처 코드로 저장한 PNG를 JPG로 바꾼 것이다(PNG는 장당 2 MB 남짓). ③~⑥의 적 위치·병력·기세는 사진을 찍으려고 직접 배치했다.
- 성능: 자동 전투 20초 평균 **44.1 fps** (1920×1080 창, GTX 1660, forward_plus). 측정만 했다.
- 모바일 가로 비율(2400×1080) 캡처는 하지 않았다(선택 항목).

## 7. 김작 F6 확인 순서
1. `scenes/battle3d/Battle3D_NavalHansando.tscn`을 F6로 연다 → 시작 화면 없이 바다 전장이 바로 뜬다. 위에 "한산도 대첩".
2. 아군 배를 눌러 이동 범위를 본다(거북선 4칸, 판옥선 3칸). 섬 칸은 범위에 없다.
3. 이동 뒤 [기본공격] → 적 배 선택. 화포 연기·포탄, 판옥선은 이어서 화살.
4. 이순신 차례에 기세 4 이상이면 [학익진].
5. F9, Shift+F9 → `C:\eastwar_tmp\naval\captures\`에 PNG.
6. `scenes/battle3d/Battle3D_ScenarioShell.tscn`을 F6로 열어 육전이 이전과 같은지 본다.

## 8. 종료 루틴
1. 정본 작업 폴더 `C:\dev\SamWar_BattleLab_cc`: 가지 `feature/wm3d-naval-20261110`, 커밋 뒤 `git status` 깨끗.
2. 새로 생긴 것: 새 파일은 2-2절 표 + 시험 2개 + `tools/build_naval_hansando_terrain.py` + 증거 폴더. worktree·태그 0. 임시 파일은 `C:\eastwar_tmp
aval\`(로그·캡처 원본·증거 촬영 스크립트)에만 있다.
3. 푸시: 이 가지에만. 문서 커밋(`[skip ci]`) 뒤 코드 커밋이 마지막. `main`·orders 가지 푸시 없음.
4. CI: Verify C-track refactor `42832011165`(`57bae9f`) 4 shard 전부 success. 첫 실행 `42828138719`(`1165036`)은 shard 2 실패 — 새 수전 시험이 결과 화면을 프레임 수로 기다린 한 줄 때문이었고, 시간으로 기다리게 고친 시험 커밋 `57bae9f`로 해결했다(제품 코드 변경 없음). Verify WorldMap3D는 경로 조건에 안 걸려 실행되지 않았다.
5. 김작/클코치가 결정할 것: 5절 1~3(병력 숫자, 배 모형, 지형 칸 글자), 3절 "답신 1과 다르게 된 곳" 5가지 확인, F6(7절).

---

# 답신 2 — 바다 전용 물 셰이더 + 포탄 물보라 (클코드, 2026-11-11)

- **됐나**: 됐다(자동 검증 기준). 김작 F6 확인 전이다. 기준 화면·합격 기준은 답신 2 맨 위 그대로(바다에 "얼룩·오물처럼 흘러가는 느낌"이 없고, 포탄 물보라가 자연스러우면 합격).
- **한 일**: 바다를 강 셰이더에서 떼어 전용 셰이더로 바꿨고, 빗나간 포탄의 흰 원기둥을 입자 물보라로 바꿨다. 강 셰이더 파일은 0줄(시험이 `main` 해시와 비교).

## 답2-1. 바다
- 새 셰이더 `scripts/battle3d/naval/eastwar_sea_water.gdshader`. 강 셰이더에서 가져온 것은 판 경계선·판 밖 안개·섬 둘레 얕은 물/거품뿐이다.
- 바탕은 짙은 청록 한 색이고, 물결은 그 색을 조금만 밝고 어둡게 한다(기본 세기 0.22). 물결 한 개 폭은 1.3 m로 배(2.2~2.8 m)보다 작다. 노이즈 텍스처는 쓰지 않는다.
- 흐름은 한 방향(북→남)이다. 물결 세 겹이 모두 `flow_direction`을 따라가고 크기·속도만 다르다. 방향과 속도는 uniform `flow_direction`·`flow_speed`이고, 나중에 조류 규칙이 같은 값을 읽을 수 있게 대본에 둔다.
- 반짝임은 해 쪽으로 기운 물결에만 작은 점으로 뜬다. 흰 거품은 섬 둘레에만 있다. 카메라에서 멀수록 살짝 밝은 회청색이 된다.
- 조절값은 대본 `data/battle3d/naval_hansando_scenario.json`의 `sea` 칸에서 읽는다: `flow_direction`, `flow_speed`, `deep_color`, `shallow_color`, `wave_size`, `wave_strength`, `sparkle_strength`, `foam_width`. 숫자만 바꾸고 F6를 다시 누르면 된다.
- **F8**(디버그·에디터 실행): 바다 미리 설정 3개를 돌려 본다. ① 잔잔 (기본) ② 조금 더 물결 ③ 느린 흐름. 셋 다 같은 방향이다. 왼쪽 위에 이름이 2초 뜬다. 미리 설정도 대본 `sea.presets`에 있다.

## 답2-2. 포탄 물보라 (`battle3d_cannon_fx.gd`)
- 원기둥 메시를 없애고 한 발에 다음 네 가지를 낸다. 전체 1.5초.
  1. 물기둥: 흰 물방울 28개가 위로 솟았다가(약 1.2~1.8 m) 중력으로 떨어진다.
  2. 왕관 튀김: 물방울 16개가 바깥·위로 퍼진다.
  3. 물 위 고리 2개: 수면에 붙은 흰 고리가 1초에 걸쳐 커지며 사라진다.
  4. 남은 거품: 옅은 흰 거품이 1.5초 남았다 사라진다.
- 입자는 한 발에 44개다. 명중 쪽(섬광·연기)은 그대로다.

## 답2-3. 바꾼 파일
| 파일 | 무엇을 |
|---|---|
| `scripts/battle3d/naval/eastwar_sea_water.gdshader` (새 파일) | 바다 전용 셰이더 |
| `scripts/battle3d/naval/naval_sea_builder.gd` | 새 셰이더 사용, `apply_sea()`로 대본 값 적용(노이즈 텍스처 제거) |
| `scripts/battle3d/naval/battle3d_naval_lab_setup.gd` | 대본 `sea` 칸을 빌더와 오버레이에 넘김 |
| `scripts/battle3d/naval/battle3d_naval_overlay.gd` | F8 미리 설정 순환, 이름 표시 |
| `scripts/battle3d/naval/battle3d_cannon_fx.gd` | 입자 물보라 |
| `data/battle3d/naval_hansando_scenario.json` | `sea` 칸 추가 |
| `tests/scripts/test_battle3d_naval_hansando.gd` | 확인 항목 11개 추가 |
- 수전 전용 파일만 바꿨다. 육전·엔진·셸·랩 파일 0줄. `eastwar_terrain_20x20_water.gdshader` 0줄.

## 답2-4. 시험
- `[NAVAL_HANSANDO] checks=167 failures=[]` (156 → 167). 추가: 바다 재질이 새 셰이더인지, 강 셰이더 파일 SHA-256이 `main` `8cc0640`과 같은지, 대본 값이 재질에 들어갔는지(한 방향, 물결이 배보다 작음), F8 3개 순환(방향 불변), 물보라 구성(물방울 묶음 2개 + 고리 2개 + 거품, 원기둥 없음).
- `[BATTLE_SETUP_NAVAL] checks=64 failures=[]` 그대로. 파이썬 검사기 72개 통과.
- 육전 시험은 이번에 로컬에서 다시 돌리지 않았다(바꾼 파일이 전부 수전 전용). CI 4 shard가 전체를 돈다.
- CI: Verify C-track refactor `42839927991`(`4dfcfca`) 4 shard 전부 success. 첫 시도에서 shard 0이 실패했는데, 로그가 육전 시험 `test_battle_attack_oracle_shard_2` 도중에 끊겨 원인을 알 수 없었다. 같은 커밋으로 그 shard만 다시 돌려 통과했다(코드 변경 없음, 일시적 실패로 본다). Verify WorldMap3D는 경로 조건에 안 걸려 실행되지 않았다.

## 답2-5. 증거 (`agent/evidence/naval_hansando/`, 1920×1080 창 실행, HUD 포함)
| 파일 | 내용 |
|---|---|
| `sea_before.jpg` / `sea_after.jpg` | 같은 카메라 위치의 바꾸기 전 / 후 |
| `sea_preset_1.jpg`, `sea_preset_2.jpg`, `sea_preset_3.jpg` | F8 미리 설정 ① 잔잔 ② 조금 더 물결 ③ 느린 흐름 |
| `splash_column_top.jpg`, `splash_rings.jpg` | 물기둥이 솟은 순간, 고리가 퍼지는 순간 (당긴 화면, 두 발) |
- 성능: 자동 전투 20초 평균 **56.0 fps**(바꾸기 전 44.1). 측정만 했다.
- 정지 화면에서 ③ 느린 흐름은 ①과 거의 같아 보인다. 차이는 움직임 속도라서 F8로 직접 봐야 한다.

## 답2-6. 종료 루틴
1. 정본 작업 폴더 `C:\dev\SamWar_BattleLab_cc`: 가지 `feature/wm3d-naval-20261110`, 커밋 뒤 `git status` 깨끗.
2. 새로 생긴 것: 셰이더 1개(+`.uid`), 증거 7장. worktree·태그 0. 임시 파일은 `C:\eastwar_tmp\naval\`에만.
3. 푸시: 이 가지에만. 문서 커밋(`[skip ci]`) 뒤 코드 커밋이 마지막. `main`·orders 가지 푸시 없음.
4. CI: Verify C-track refactor `42839927991`(`4dfcfca`) 4 shard 전부 success. 첫 시도에서 shard 0이 실패했는데, 로그가 육전 시험 `test_battle_attack_oracle_shard_2` 도중에 끊겨 원인을 알 수 없었다. 같은 커밋으로 그 shard만 다시 돌려 통과했다(코드 변경 없음, 일시적 실패로 본다). Verify WorldMap3D는 경로 조건에 안 걸려 실행되지 않았다.
5. 김작이 볼 것: F6에서 바다 느낌과 물보라, F8 세 설정 중 고르기. 숫자를 더 바꾸고 싶으면 대본 `sea` 칸.

---

# 답신 3 — 록비서 배 모델 4척 연결 (클코드, 2026-11-11)

- **됐나**: 구현과 로컬 검증은 됐다. **CI는 shard 0이 빨갛다**(육전 컷인 길이 검사, 답3-4). 클코치 답신을 기다린다. 김작 F6 확인 전이다. 기준 화면·합격 기준은 답신 3 맨 위 그대로(임시 상자 배 대신 배 모델 4척이 물선에 맞게 뜨고, 멈추면 돛이 접히고 움직이면 돛이 펴지며 노를 저으면 합격).
- **한 일**: 납품 GLB 6개를 넣고(해시 일치), 배 4종을 규칙 파일의 `model_path`로 연결했다. `Hull` 기준 크기 맞춤, `WaterLine` 물선 맞춤, 돛 접힘/펼침과 노 젓기, 배마다 따로 칠한 돛 색, 거북선 포 소켓을 넣었다.
- **바꾼 범위**: 수전 전용 파일 3개(규칙 파일, 배 연출, 수전 시험)와 새 에셋뿐이다. 엔진·육전·셸·랩·강 셰이더 0줄.

## 답3-1. 넣은 파일 (`assets/battle3d/naval/`)
| 파일 | sha256 앞 12자리 | 쓰임 |
|---|---|---|
| `panokseon_game_v2.glb` | `4144db4aedf5` | 판옥선 |
| `geobukseon_game_v2.glb` | `ae40107222d5` | 거북선 |
| `jp_atakebune_game_v1.glb` | `0a5ea4b13fa2` | 안택선 |
| `jp_sekibune_game_v1.glb` | `47c30e6417cf` | 관선 |
| `cn_mengchong_game_v1.glb` | `63edba268e13` | 넣어만 둠(병종·규칙 없음) |
| `cn_doujian_game_v1.glb` | `7aff0405278f` | 넣어만 둠(병종·규칙 없음) |
- 6개 모두 답신 3 0절 값과 같다(복사 전·후 두 번 계산). 시험도 이 값을 본다.
- Godot 가져오기가 만든 파일도 같이 커밋했다: `.glb.import` 6개, GLB에서 꺼낸 텍스처 `<배>_2048.jpg` 6개와 그 `.import` 6개. 소나무 GLB(`assets/battle3d/pine/`)와 같은 방식이다. CI의 Diff 검사가 가져오기 뒤 작업 폴더가 깨끗한지 보기 때문에 빠뜨릴 수 없다.
- `_lp` 저폴리판, v1 판옥선·거북선, 원본은 넣지 않았다.

## 답3-2. 연결
1. **경로**: `data/battle3d/naval_unit_type_rules.json`의 배 4종에 `model_path`를 넣었다. 연출 코드는 `model_path` → `<unit_type>.glb` → 임시 모형 순서로 찾는다.
2. **크기**: 모델에 `Hull`이 있으면 `Hull` 메시 상자의 Z 길이를 `ship_length`에 맞춘다(노·돛대·돛은 재지 않는다). 옆으로 돌리는 판단도 `Hull`로만 한다. 4척 모두 돌지 않았다.
3. **물선**: `WaterLine` 노드가 수면(높이 0)에 오도록 모델을 내렸다. 랩이 유닛 모형을 칸 위 0.035 m에 올려 두기 때문에 그만큼 더 내린다.
4. **돛·노**: 시작할 때 돛을 접어 둔다. 이동 경로를 따라 움직이는 동안 돛을 펴고 `Oar_Row`를 반복 재생한다. 멈추면 돛을 접고 노를 첫 자세로 세운다. 돛 전환은 0.25초 동안 scale 0.001↔1이다(`visible`은 쓰지 않는다). 가라앉는 배는 멈춘 것으로 본다.
5. **돛 색**: 배마다 `Sail_Mat`만 복제해 그 배의 돛(펼친 돛·접은 돛)에 입힌다. 색은 규칙 파일 `sail_color`에 있다: 판옥선·거북선 `#2F5D8A`, 안택선·관선 `#A3402A`. 중국 녹 `#2E7D32`는 규칙 파일 설명 줄에만 적어 두었다(중국 배 규칙이 아직 없다). 선체·돛대·다른 배는 그대로다. GLB일 때는 깃발 막대를 그리지 않는다.
6. **포 위치**: 거북선은 `CannonSocket_L1~L5`·`R1~R5`·`F1~F3`을 섬광·포탄 출발점으로 쓴다. 다른 배는 이전처럼 만든 점 3개(한쪽)이고, 폭과 높이를 `Hull`로 다시 계산한다.
7. 흔들림·침몰·얼굴 칩·병력 바는 그대로다. 얼굴 칩은 배 오른쪽 위에 떠서 돛대나 선체에 묻히지 않았다. `geometry`는 바꾸지 않았다.

## 답3-3. 답신 3과 다르거나 내가 정한 곳 (클코치 확인 필요)
1. **`Oar_Row`가 반복 재생으로 들어오지 않는다.** Godot가 가져온 애니메이션은 길이 1.042초, 반복 꺼짐이다. 코드가 재생 전에 반복을 켠다(GLB는 고치지 않았다).
2. **텍스처 압축은 Godot 기본값 그대로다.** 커밋한 `.jpg.import`는 `compress/mode=0`(무손실) + `detect_3d/compress_to=1`이다. 에디터가 이 텍스처를 3D에서 쓰는 것을 감지하면 VRAM 압축으로 바꾸며 `.import`를 고쳐 쓴다(작업 폴더에 수정 파일이 생길 수 있다). 소나무 텍스처도 같은 상태로 커밋돼 있어 그대로 두었다. 처음부터 VRAM 압축으로 고정하려면 `.import` 6개를 바꾸면 된다(지시가 있으면 한다).
3. **거북선이 어느 쪽 포를 쏘는가(택한 해석)**: 표적이 배 옆보다 앞쪽에 더 가까우면 뱃머리 포 3문(`F`), 아니면 표적 쪽 측면 5문(`L` 또는 `R`)이다. 답신에는 소켓을 쓰라는 것만 있었다.
4. **돛 색을 둔 자리**: 대본이 아니라 규칙 파일에 병종별로 두었다(배 종류가 나라를 정한다). 진영(아군/적)과는 무관하다.
5. **시험의 "이동 중" 확인 방법**: 랩의 이동 재생 경로를 시험이 직접 넣어(엔진에는 이동을 시키지 않는다) 돛·노를 확인했고, 그와 별도로 자동 전투에서 엔진이 실제로 옮긴 배가 노를 젓는 프레임을 셌다.

## 답3-4. 시험
- `[NAVAL_HANSANDO] checks=249 failures=[]` (167 → 249). 추가한 확인:
  - 규칙의 `model_path` 4개, GLB 6개의 해시(0절 값)
  - 배 10척 모두 `model_sources == "glb"`, `Hull`·`WaterLine`·`Oar_Row` 있음, 깃발 막대 없음
  - `Hull` 길이 = `ship_length` ±1%, 뱃머리 Z 방향, 가운데 정렬. 노·돛대까지 합쳐도 한 칸(3 m) 안
  - `WaterLine` 높이 = 수면 ±1 cm(흔들림의 위아래 움직임은 뺀 값)
  - 시작 때 돛 접힘·노 정지. 이동 중 돛 펼침 + `Oar_Row` 반복 재생. 멈추면 다시 접힘·정지(판옥선, 안택선)
  - 돛 색: 배마다 자기 복제본(10척 10개), 색 = 규칙 값, 원래 재질·돛대·선체는 그대로
  - 거북선 포 소켓 13개(좌 5·우 5·앞 3), 판옥선은 만든 점 3개
  - 자동 전투 중 엔진이 옮긴 배가 노를 저은 프레임 > 0
  - 임시 모형: 다시 시작할 때 규칙의 `model_path`를 비운 상태로 열어 10척 모두 임시 모형(길이, 깃발, 만든 포 자리)인지 본다. 끝나면 되돌린다.
- `[BATTLE_SETUP_NAVAL] checks=64 failures=[]` 그대로.
- 로컬에서 가져오기를 두 번 돌린 뒤 `git status`에 고쳐진 파일이 없다(CI Diff 검사와 같은 조건). 에디터 파싱에서 수전 파일 경고 0.
- 육전 시험과 파이썬 검사기는 이번에 로컬에서 다시 돌리지 않았다(바꾼 파일이 전부 수전 전용). CI 4 shard가 전체를 돈다.
- CI: Verify C-track refactor `43028220617`(`c727472`): shard 1·2·3 success, **shard 0 failure**. 실패한 것은 육전 시험 `test_battle3d_cutin_result_toast.gd`의 `[CUTIN]` 길이 검사 하나다(컷인 5개가 3.943~3.972초, 기준 3.95초 이상). 큐 4절 1의 알려진 컷인 관찰이고 수전 시험 2개는 shard 1·2에서 통과했다(`checks=64`, `checks=249`). CI가 빨개서 문 조건 3을 못 채우므로 멈췄다. 재실행은 하지 않았다(큐 6절). 멈춤 보고 `agent/REPORT_NAVAL_HANSANDO_REPLY3_STOP_20261111.md`. Verify WorldMap3D는 경로 조건에 안 걸려 실행되지 않았다.

## 답3-5. 증거 (`agent/evidence/naval_hansando/`, 1920×1080 창 실행, HUD 포함)
| 파일 | 내용 |
|---|---|
| `ships_01_overview.jpg` | ① 전경, 배 10척(가장 멀리 본 화면) |
| `ships_02_joseon_rest.jpg`, `ships_02b_joseon_rest_closer.jpg` | ② 판옥선·거북선, 멈춤(돛 접힘) |
| `ships_03_moving.jpg`, `ships_03b_moving_closer.jpg` | ③ 판옥선 이동 중(청색 돛 펼침, 노 젓기) |
| `ships_03d_arrived_furled.jpg` | ③ 도착 뒤 돛 접힘 |
| `ships_04_turtle_cannon.jpg` | ④ 거북선 화포(우현 소켓에서 섬광·포탄) |
| `ships_05_japan_rest.jpg`, `ships_05b_japan_rest_closer.jpg` | ⑤ 안택선·관선(적색 돛, 접힘) |
| `ships_06_sinking.jpg` | ⑥ 침몰(돛대 끝과 연기만 남은 순간) |
- 이름에 `closer`가 붙은 장은 게임에서 휠로 갈 수 있는 것보다 더 당긴 화면이다(모델 확인용). ③은 사진을 찍으려고 이동 재생 속도를 늦췄다. ④⑥의 적 위치·병력은 직접 배치했다.
- 성능: 자동 전투 20초 평균 **50.3 fps**(1920×1080 창, GTX 1660, forward_plus). 답신 2는 56.0, 답신 1은 44.1이었다. 측정만 했다.

## 답3-6. 화면에서 본 것 (가이드 §9의 남은 문제 포함)
- 새 4척의 노 구멍 위치(추정값): 게임 화면 거리에서는 어긋남이 눈에 띄지 않았다.
- 거북선 지붕 판자 비뚤어짐, 뱃머리 아래 찢어진 삼각형: 게임 화면 거리에서는 눈에 띄지 않았다.
- 안택선: 더 당긴 화면(`ships_05b`)에서 지붕이 검고 고르지 않게 보인다. 깨진 것인지 텍스처인지 나는 판단하지 못했다. 김작·클코치가 봐야 한다.
- 관선: 속이 보이는 열린 배로 나온다(가이드의 "속이 빈 껍데기"와 같은 내용).
- 접은 돛은 돛대 위의 가는 막대라서, 멈춘 배는 나라 색이 조금만 보인다. 가장 멀리 본 화면에서는 거의 안 보인다.
- 배 밑의 진영 색 원판(기존 표시)이 물선 둘레를 덮는다. 그래서 배가 물이 아니라 원판 위에 놓인 것처럼 보인다. 원판은 이번 범위가 아니라 그대로 두었다.
- 이동 재생이 끝나기 전에 방향 선택 화살표가 먼저 뜬다(기존 동작, 육전과 같다).

## 답3-7. 종료 루틴
1. 정본 작업 폴더 `C:\dev\SamWar_BattleLab_cc`: 가지 `feature/wm3d-naval-20261110`, 커밋 뒤 `git status` 깨끗.
2. 새로 생긴 것: GLB 6개와 가져오기 파일 18개, 증거 10장. 새 스크립트·worktree·태그 0. 임시 파일은 `C:\eastwar_tmp\naval\`에만.
3. 푸시: 이 가지에만. 문서 커밋(`[skip ci]`) 뒤 코드 커밋이 마지막. `main`·orders 가지 푸시 없음.
4. CI: Verify C-track refactor `43028220617`(`c727472`): shard 1·2·3 success, **shard 0 failure**. 실패한 것은 육전 시험 `test_battle3d_cutin_result_toast.gd`의 `[CUTIN]` 길이 검사 하나다(컷인 5개가 3.943~3.972초, 기준 3.95초 이상). 큐 4절 1의 알려진 컷인 관찰이고 수전 시험 2개는 shard 1·2에서 통과했다(`checks=64`, `checks=249`). CI가 빨개서 문 조건 3을 못 채우므로 멈췄다. 재실행은 하지 않았다(큐 6절). 멈춤 보고 `agent/REPORT_NAVAL_HANSANDO_REPLY3_STOP_20261111.md`. Verify WorldMap3D는 경로 조건에 안 걸려 실행되지 않았다.
5. 김작이 볼 것: F6에서 배 4종 모습과 물선, 돛 접힘/펼침, 노 젓기, 돛 색 두 가지. 클코치가 볼 것: 답3-3의 5가지, 답3-6의 안택선 지붕.
