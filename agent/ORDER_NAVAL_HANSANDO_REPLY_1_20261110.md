기준 화면: 큐 35 지시서(19:40판)와 같음 — `scenes/battle3d/Battle3D_NavalHansando.tscn` (F6), 육전 `Battle3D_ScenarioShell.tscn`은 그대로.
합격 기준: 큐 35 지시서와 같음. 추가로 **시작 설정에 새 항목이 없을 때 육전·S4-3 결과가 바이트 단위로 같다**.

# 큐 35 답신 1 — A안 승인: 엔진 시작 설정에 수전 항목 추가

작성: 클코치 / 2026-11-10 21:30. 김작 승인 21:26 **"A로 가"**. 대상 보고서: `agent/REPORT_NAVAL_HANSANDO_STOP_20261110.md`(`a0e43d5`). 멈춤은 정당했다 — 시나리오별 병종 입구를 확인하지 않은 건 클코치 지시서의 빈틈이었다.

## 1. 허용 범위 추가 (§3-1에 더함)
`scripts/battle_web_import_test.gd`의 아래 세 자리만 추가로 고칠 수 있다. 그 밖의 엔진 자리는 여전히 멈춤.
1. `_read_battle_setup_port()` (1526행 부근) — 새 최상위 키를 **있을 때만** 읽는다.
2. `_apply_battle_setup_unit_override()` (1550행 부근) — 새 유닛 키를 **있을 때만** 적용한다.
3. 학익진 `build_plan`에 넘기는 `battle_type` 한 줄 (4549행 부근).
- 필요하면 위 세 자리에서만 부르는 **새 함수**를 같은 파일 끝이나 새 서비스 파일(`scripts/battle/services/battle_setup_naval_service.gd` 등)에 둬도 된다(새 파일 권장).
- 랩의 HUD 병종 이름(`battle3d_engine_play.gd`의 `hud_unit_type_name`)이 배 4종 이름을 보여 주도록 고치는 것도 허용(5종은 지금 문구 그대로).

## 2. 새 시작 설정 항목 (전부 선택, 없으면 지금과 같음)
### 최상위
- `battle_type`: `"naval"` 또는 `"land"`. 학익진 줄은 **월드맵 문맥에 `battle_type`이 있으면 그 값, 없으면 시작 설정 값, 둘 다 없으면 `"land"`**. 이 값은 월드맵 문맥(`worldmap_battle_context`)에 **넣지 않는다**(보고서 2절의 결과 반환·퇴각 분기 위험 회피).
- `arrival_round_overrides`: `{slot_id 또는 unit_id: 라운드}`. `0` = 시작부터 판 위에 있음.

### `unit_overrides[unit_id]`
- `troops_ratio`(기존), `unit_type`, `hero_id`, `grid_cell`([x, y]), `facing`, `troops`(선택).
- 지금 코드는 `troops_ratio`가 없으면 그 유닛 덮어쓰기를 통째로 무시한다. **새 키가 하나라도 있으면** `troops_ratio` 없이도 적용하도록 고친다. 새 키가 없고 `troops_ratio`도 없으면 지금처럼 무시 + 같은 로그.
- `unit_type` 적용 시: `UnitTypeContract`에 있는 이름만(없으면 무시 + 로그). **`move_range`·`attack_range` 등 생성 때 계산된 값(`battle_unit_state.gd:88-89`)을 같은 계산식으로 다시 계산**한다(값만 바꾸고 파생값을 놔두면 안 됨).
- `hero_id` 적용 시: 이미 있는 `_apply_hero_identity_to_unit`(8915행 부근)과 같은 경로로 이름·초상·능력을 바꾼다. 장수 데이터에 없는 id면 무시 + 로그.
- `grid_cell` 적용 시: 판(18×10) 안, 막히지 않은 칸, 다른 유닛과 안 겹칠 때만. 격자 점유 정보도 같이 갱신. 어기면 무시 + 로그.
- 적용 순서: 병종 → 장수 → 병력 → 칸·방향 → 도착 라운드. 로그는 기존 `[BATTLE_SETUP]` 형식에 맞춘다.

## 3. 수전 장면이 넘길 설정
`Battle3D_NavalHansando.tscn`은 셸이 이미 쓰는 시작 설정 메타(`SETUP_KEY` 방식)로 `data/battle3d/naval_hansando_scenario.json`에서 만든 설정을 넘긴다: `battle_type: "naval"`, 10유닛의 `unit_type`·`hero_id`·`grid_cell`·`facing`·`troops`, 증원 2슬롯씩 `arrival_round_overrides = 0`.

## 4. 보고서가 짚은 판 크기
- 엔진 판은 **18×10**(`lab_heightfield.gd` `PLAY_SIZE`). 바다·섬 그림은 20×20 전체에, 섬 막힌 칸·시작 칸·도달 검사는 18×10 안에서. 클코드 해석 그대로 승인.
- 섬은 `terrain_types`에 `island`로 쓰고 `forest_cells()`가 `island`도 모으게 하거나, 섬을 `forest`로 적어도 된다. 육전 땅 파일은 그대로.

## 5. 시험 추가 (§5에 더함)
- **S1**: 새 키 없는 시작 설정 → `test_battle_setup_port_s4_3`·`test_battle_setup_port_base_parity`(+shard 1·2) 기대값 변경 없이 통과.
- **S2**: `battle_type` 없음 + 월드맵 문맥 없음 → 학익진 반경 2(지금과 같음). `battle_type: "naval"` → 반경 3. 월드맵 문맥 `"land"` + 설정 `"naval"` → 월드맵 문맥 우선(2).
- **S3**: `unit_type` 덮어쓰기 후 이동 가능 칸 수가 수전 규칙 파일의 `move_range`와 같다(배 4종 각 1척).
- **S4**: 잘못된 값(없는 병종·없는 장수·판 밖 칸·막힌 칸·겹치는 칸) → 무시 + 로그, 전투는 정상 시작.
- **S5**: `arrival_round_overrides = 0` → 1라운드 시작부터 10척이 판 위에 있다.
- 엔진 소스 글자를 검사하는 검사기(`tools/validate_*` 다수)가 있으니 **C-track 4 shard 전부 초록**이 합격 조건. 하나라도 깨지면 고치지 말고 멈춤 보고(검사기 기대값 수정 금지).

## 6. 나머지
지시서 19:40판(+19:35 배 1칸·트라이포 수정) 그대로. 이 가지(`feature/wm3d-naval-20261110`)에서 잇는다. 마지막 커밋은 코드 커밋. 보고서는 `agent/REPORT_NAVAL_HANSANDO_20261110.md`(첫 절에 STOP 조사표 링크).
