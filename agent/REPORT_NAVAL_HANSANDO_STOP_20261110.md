기준 화면: 새 장면 `scenes/battle3d/Battle3D_NavalHansando.tscn` (F6) — 기존 3D 전투 셸(`Battle3D_ScenarioShell`)을 수전 설정으로 연 것. 육전 `Battle3D_ScenarioShell.tscn`의 동작은 그대로여야 한다.
합격 기준: 지시서(큐 35, 19:40판) 맨 위 그대로. **이번에는 §4 조사만 하고 코드 변경 0으로 멈춘다.**

# REPORT_NAVAL_HANSANDO_STOP — 엔진에 "시나리오별 병종·장수·시작 칸" 입구가 없다 (클코드, 2026-11-10, 큐 35번)

- **됐나**: 안 됐다. 코드 커밋 0, 이 보고서와 진행 기록만 올렸다.
- **가지**: `feature/wm3d-naval-20261110` = `origin/main` `8cc0640` + 이 보고서 커밋 1개(`[skip ci]`). `main` 푸시 없음.
- **막힌 것**: 지시서 §4 멈춤 조건 "1·2·3 중 하나라도 … §3-1 허용 자리 밖을 고쳐야만 될 때"에 걸린다.
  - §4-2: 엔진(`scripts/battle_web_import_test.gd`, 16,177줄)에는 **유닛 병종을 시나리오에서 바꾸는 입구가 없다.** 시작 설정(`samwar_battle_setup`)은 `troops_ratio`와 `enemy_ai_level`만 받는다.
  - 대본의 **장수 10명·시작 칸·5:5 동시 배치**도 엔진 입구가 없다. 기본 전투는 쪽마다 주력 3 + 증원 2(3라운드 도착)다.
  - 학익진 반경 3은 엔진이 `worldmap_battle_context.battle_type == "naval"`일 때만 준다. 이 값은 월드맵 문맥으로만 들어온다.
  - 위 넷 모두 엔진 파일이나 "랩이 엔진 상태에 직접 쓰는 새 통로"가 필요하다. 둘 다 §3-1 허용 자리 목록에 없다.

## 1. §4 조사표 [사실: `main` `8cc0640` 코드 읽기, 수정 0]
| # | 질문 | 답 | 근거(파일:줄) | 멈춤? |
|---|---|---|---|---|
| 1 | `UnitTypeContract`에 수전 규칙 파일을 추가로 읽게 할 가장 작은 자리 / 5종 검사기 영향 | `is_supported()`(13)·`get_rule()`(17) 두 함수. 수전 파일이 있으면 4종을 추가로 인정하고 그 규칙을 돌려주면 된다. 5종 검사기 9개는 `data/heroes/generated/unit_type_rules.json`과 엔진·서비스 문자열만 읽는다. `unit_type_contract.gd` 소스를 읽는 검사기는 `validate_t07_visual_metadata_resources.py` 하나이고, 이 검사기는 토큰(`get_visual_metadata` 등) 존재만 본다 → **영향 0** | `scripts/battle/unit_type_contract.gd:13-20`, `tools/validate_t07_visual_metadata_resources.py:15-19` | 아니오 |
| 2 | 시나리오 단위로 유닛 병종을 지정할 수 있나(장수 데이터 수정 없이) | **없다.** 유닛 병종은 엔진 안 고정 슬롯 표(주력·증원 10칸, `"unit_type": UNIT_TYPE_*`)에서 온다. 시작 설정 `_read_battle_setup_port()`는 `unit_overrides[*].troops_ratio`와 `enemy_ai_level`만 읽는다. 월드맵 문맥 경로(`_apply_hero_identity_to_unit`)도 이름·얼굴·병력만 바꾸고 `unit_type`은 그대로 둔다. `move_range`·`attack_range`는 `BattleUnitState` 생성 때 `UnitTypeContract`에서 한 번 계산된다 | `scripts/battle_web_import_test.gd:1526-1568`(설정), `:8915-8944`(문맥 신원 `_apply_hero_identity_to_unit`), `:11786-12065`(고정 슬롯 표 `_create_demo_unit_states`), `scripts/battle_unit_state.gd:88-89` | **예** |
| 3 | 막힌 칸(`is_blocked`)을 시나리오별로 줄 수 있나 | **된다.** 랩이 `_ready()`에서 `queries.grid.set_blocked_cells(forest_cells())` 한 번 쓴다. `forest_cells()`는 랩이 읽은 `terrain_types` 칸 중 `"forest"`를 모은다 → 수전 땅 파일의 섬 칸을 `forest`로 쓰거나 `forest_cells()`가 `island`도 모으게 하면 된다(랩의 땅 파일 자리, §3-1 안) | `scripts/battle3d/battle3d_engine_play.gd:288`, `:728-735`, `scripts/battle/services/battle_movement_query_service.gd:63` | 아니오 |
| 4 | 학익진이 수전/육상을 실제로 구분하나 | **구분한다.** `aoe_damage_debuff`이고 `battle_type != "naval"`이면 반경을 `mini(radius, 2)`로 줄인다. 엔진은 `battle_type`을 `worldmap_battle_context.get("battle_type", "land")`에서만 넘긴다(월드맵 문맥 없으면 늘 `land` → 반경 2). 참고: 엔진 안의 옛 고정 표에는 `yi_sunsin`(밑줄 1개) "학익진" `cannon_aoe`가 따로 있다(데이터의 `yi_sun_sin_unique`와 다른 항목) | `scripts/battle/battle_skill_resolver.gd:222-223`, `scripts/battle_web_import_test.gd:4541-4548`, `:526-532` | **예**(반경 3을 주려면 엔진 문맥이 필요) |
| 5 | AI가 새 병종 이름을 받으면 어느 프로필로 가나 | `ai_behavior_profile`은 **어떤 `.gd`도 읽지 않는다**(검사기 `validate_five_unit_type_structured_contract.py`만 읽음). AI는 유닛 상태의 `move_range`·`attack_range`와 `UnitTypeContract` 피해 문맥을 쓴다. 새 이름이 계약에 없으면 이동 0·사거리 0이 된다(`get_rule()`이 `{}`). 엔진의 표시용 `_normalize_unit_type()`은 5종 밖을 `infantry`로 바꾼다(아이콘·병종 이름 표시) | `scripts/battle_web_import_test.gd:12343-12348`, `scripts/battle/unit_type_contract.gd:17-28` | 아니오(질문 2가 풀리면 계약 추가로 해결) |
| 6 | 셸이 `LAB_SCENE`·땅 경로를 설정으로 받게 할 최소 자리 | 셸: `create_lab()`(207-209)이 `LAB_SCENE` 상수를 `load`한다 → 내보낸 변수 하나로 충분. 땅: `lab_heightfield.gd` `_init()`(16-29)이 두 경로를 고정으로 읽고, 랩은 `var board = Board.new()`(멤버 초기화, `_ready` 전)로 만든다 → 셸이 랩을 만들기 **전에** 경로를 넘길 통로가 필요(예: `Engine` 메타 1개, 셸의 `SETUP_KEY`와 같은 방식). `terrain_board_builder.gd:200-201`도 `terrain_types.json`을 고정으로 읽는다(보드에서 받은 값이 없을 때) | `scripts/battle3d/battle3d_scenario_shell.gd:9`, `:207-209`, `scripts/battle3d/lab_heightfield.gd:17-19`, `scripts/battle3d/lab_presentation.gd:22`, `scripts/battle3d/terrain_board_builder.gd:200-201` | 아니오 |

### 1-1. 대본 장수 10명 [사실]
`yi_sun_sin`·`kim_deok_ryeong`·`jang_bo_go`·`gwak_jae_u`·`go_gyeong_myeong`·`kato_kiyomasa`·`konishi_yukinaga`·`kuroda_nagamasa`·`shimazu_yoshihiro`·`honda_tadakatsu` — 10명 모두 `data/heroes/generated/hero_battle_profiles.json`에 있다(각 1건).

### 1-2. 지시서 [사실]과 다른 점
- 지시서 §3-2는 "20×20 전 칸"이라고 했다. 땅 그림(`heightfield.json`)은 20×20이 맞지만, **엔진이 움직이는 판은 18×10**(`lab_heightfield.gd:6` `PLAY_SIZE`)이다. 바다·섬은 20×20 그림에 칠하고, 섬 막힌 칸·도달 검사는 18×10 안에서 하는 것으로 읽었다(이건 멈춤 사유가 아님).
- 지시서 §3-5 "기존 44명 안에서만"과 "10척 동시 배치"는 엔진 기본 편성(쪽마다 주력 3 + 증원 2, 증원은 3라운드 도착)과 맞지 않는다. 시작부터 5:5로 두려면 증원 슬롯의 도착 라운드와 시작 칸도 바꿔야 한다.

## 2. 왜 랩에서 몰래 쓰면 안 되나 [추정 아님, 범위 판단]
- 랩은 이미 엔진에 한 번 쓴다(`set_blocked_cells`). 같은 방식으로 랩이 엔진 `BattleUnitState`의 `unit_type`·`move_range`·`attack_range`·`grid_cell`·장수 신원·`battle_type`까지 바꾸면 동작은 할 수 있다.
- 하지만 그건 **엔진 상태를 바깥에서 다시 쓰는 새 통로**다. 지시서 §3-1의 허용 자리("장면·땅 경로를 설정에서 받는 곳 / heightfield·terrain 경로 / 병사 연출 선택 / UnitTypeContract 추가 읽기")에 없다. 지시서가 "그 밖의 기존 파일을 바꿔야 하면 멈추고 보고"라고 했으므로 멈췄다.
- 특히 `battle_type`은 `worldmap_battle_context`에 들어 있다. 이 값을 채우면 엔진의 월드맵 문맥 분기(결과 반환·퇴각·보급 표시·결과 메타 `samwar_worldmap_battle_result`)가 같이 켜질 수 있다 [미확인, 분기 전부를 읽지 않음]. 그래서 이 방법은 따로 확인해야 한다.

## 3. 클코치에게 필요한 판단
- **A (클코드 권장) — 엔진 시작 설정에 수전 항목을 더한다.**
  - `scripts/battle_web_import_test.gd`의 `_read_battle_setup_port()`·`_apply_battle_setup_unit_override()`(S4-3 시작 설정) 안에서만, 새 키를 **있을 때만** 읽는다:
    - `unit_overrides[unit_id]`에 `unit_type`·`hero_id`·`grid_cell`·`facing`·`troops`(선택)
    - 최상위 `battle_type: "naval"`(학익진 반경용, 월드맵 문맥과 분리된 값), `arrival_round_overrides`(증원 0라운드 = 시작 배치)
  - 키가 없으면 지금과 바이트 단위로 같다. 육전 골든·S4-3 시험은 그대로 통과하는지 시험 8로 확인한다.
  - 엔진 쓰기 +1. `worldmap_main.gd` 0줄, 장수 데이터 0줄은 그대로.
  - 필요한 허용: §3-1에 위 두 함수(+ 학익진 `battle_type`을 읽는 4547행 한 줄)를 더하는 답신.
- **B — 랩이 엔진 상태에 직접 쓴다.**
  - 엔진 파일 0줄. 새 `scripts/battle3d/naval/naval_scenario_applier.gd`가 랩 `_ready()`에서 `set_blocked_cells`처럼 한 번 쓴다(병종·사거리·칸·신원).
  - 학익진 반경 3은 안 된다(문맥 분기 위험, 2절) → 반경 2로 두거나 따로 정한다.
  - 엔진이 이미 만든 2D 슬롯 그림·초상과 3D 표시가 어긋날 수 있어, 확인 시험이 더 많다.
- **C — 범위를 줄인다.** 엔진 기본 편성(주력 3 + 증원 2, 기본 병종)을 그대로 두고 땅·배 모양·연출만 바다용으로 바꾼다. 배 종류별 이동 거리 차이와 학익진 반경 3은 이번에 빠진다. 사업계획서 캡처만 목적이면 가장 빠르다.

## 종료 루틴
1. 정본 작업 폴더 `C:\dev\SamWar_BattleLab_cc`: 가지 `feature/wm3d-naval-20261110`(코드는 `main` `8cc0640`과 같음), 이 보고서 커밋 뒤 `git status` 깨끗.
2. 새로 생긴 것: 가지 `feature/wm3d-naval-20261110`. worktree·태그·새 폴더 0, 삭제 예정 0. `C:\eastwar_tmp\naval\`은 아직 만들지 않았다.
3. 푸시: 이 가지에 보고서·진행 기록 커밋 1개(`[skip ci]`)만. `main`·다른 가지 푸시 없음.
4. CI: 실행 0(코드 커밋 없음).
5. 김작/클코치가 결정할 것: 3절 A/B/C. 답신(`agent/ORDER_NAVAL_HANSANDO_REPLY_1_20261110.md` 등)이 오면 이 가지에서 잇는다. 34번과는 독립.
