# T1 — 엔진: 이동 불가 칸(막힌 칸 목록) (2026-10-27~28, 밤샘)

## 해석 선택 (밤샘 규칙: 질문 없이 가장 합리적인 해석)
1. **막힌 칸 목록의 자리**: `BattleGridController`의 `blocked_cells`(Dictionary, 기본 빈 목록)에 `set_blocked_cells(cells)`와 `is_blocked(cell)`을 두었다(지시서 기본안). 판 크기를 정하는 `is_in_bounds`가 있는 곳이고, 이동 서비스가 이미 받는 객체라 서비스의 함수 서명을 바꾸지 않아도 된다.
2. **`is_cell_walkable` 순서**: 판 안 확인 → 출발 칸이면 참(떠나기 허용) → **막힌 칸이면 거짓** → 다른 부대 확인. 기존 구조를 그대로 두었다.
3. **새 쓰기의 이름과 모양**: `set_blocked_cells`이다. 기존 쓰기 이름 규칙(`set_enemy_ai_level`, `set_auto_presentation_hold`)을 따랐다. 랩이 이미 읽는 엔진 격자(`queries.grid = engine.get("battle_grid_controller")`)에 한 번 부르고, `engine.call` 이름은 하나도 늘리지 않았다. 엔진 쓰기는 15 + 1 = 16개다.
4. **이동 탐색을 거치지 않는 길**(조사 2): 지시서 §3대로 **보고만 하고 고치지 않았다**. 이동 탐색에 포함되지 않아 이번 범위 밖이다.
5. **적 AI "여러 시드"**: 엔진 전역 `seed(1|2|3)`로 돌렸다. [사실] 기본 전투에서는 세 시드의 결과가 같다.
   - 처음 시험은 숲만 막았는데, 적이 원래 숲으로 가지 않아서 변이가 살아남았다(아래 4).
   - 그래서 같은 시드로 먼저 자유롭게 돌려 적이 간 칸을 기록하고, 그 칸들과 숲을 함께 막아 다시 돌리도록 바꿨다.

## 결과 요약: **15/17, 2개 T2 대기** (10-28 김작 결정: "Do T2 first", 아래 10)

- 동등성 시험 17개 중 15개는 비교 기준에 같은 목록을 넣어 통과, **2개(`reinforce_default_rounds`, `strategy_rejections`)는 T2 대기**. 두 실패의 원인은 숲 칸과 장면(도착 칸, 고정 장면의 칸)이 겹친 것이고 엔진 문제가 아니다(10). 시험 기대값은 고치지도, 지우지도, 건너뛰지도 않았다.
- 이 기능 가지만 푸시했다. 통합 가지는 건드리지 않았다.
- **추가로 찾은 문제(11)**: 3단계의 비교 기준 줄이 엔진 단독 BASE 골든 시험 `battle_setup_port_base_parity` 1·2에도 상속되어, 이 가지 끝에서 두 시험이 실패한다. 고치지 않았다(결정 필요).

### 처음 보고 (10-27, 첫 실패에서 멈춤)

- 전체 검사에서 **시험 17개가 실패**했다. 모두 **"3D 랩으로 돌린 전투 = 엔진만 돌린 전투"를 비교하는 동등성 시험**이다(아래 5). 규칙대로 시험은 고치지 않았다.
- **T2는 시작하지 않았다.** 시작 조건이 "T1 전체 검사 전부 통과"였다.
- 이 기능 가지는 허락에 따라 CI용으로 푸시했다(통합 가지는 건드리지 않음).

| 상태 | 브랜치 | 기준 | 끝 해시 | 커밋 |
|---|---|---|---|---|
| 첫 실패로 멈춤 | `feature/t1-blocked-cells-20261027` | `0947281`(통합) | 이 보고서를 담은 커밋(zip `commit_info.txt`) | 5(+ 이 수정 1) |

| 커밋 | 내용 |
|---|---|
| `2ccb801` | 엔진: 격자에 막힌 칸 목록, `is_cell_walkable`이 막힌 칸 거부 |
| `faa0f73` | 3D: 숲 칸 24곳을 엔진에 넘김(새 쓰기 `set_blocked_cells`) |
| `6319738` | 시험 3개, 검증기 `tools/validate_t1_blocked_cells.py`, CI 목록 |
| `fc6f785` | 검증기 고정 |
| (이 커밋) | 이 보고서, 새 시험 3개의 `.uid` |

## 1) 선행 조사 [사실]

1. **목록의 자리**: 위 해석 1. `BattleGridController`(`scripts/battle_grid_controller.gd`)는 칸 데이터 없이 판 크기만 갖고 있었다. 기본값은 빈 목록이다.
2. **`is_cell_walkable`을 쓰는 곳과 그것을 거치지 않는 길**:
   - **거치는 곳(막힘)**: `find_move_path`(도착 칸에도 `is_cell_walkable`)와 `get_reachable_paths`(4방향 탐색)를 다음이 모두 쓴다.
     - 플레이어: `_try_direct_move_to_cell` → `is_valid_move_target` → 경로(`battle_web_import_test.gd:6577`, `:15267`, `:15007-15020`)
     - 아군 자동 이동: `_find_best_auto_move_cell` → `_get_auto_move_path_for_actor`(`:13741`, `:13972`)
     - 적 AI: `:15051-15074`, 행동 계획 `:13211`·`:13253`, 경로 이동 `:8284`
     - 3D 이동 범위: `battle3d_movement_adapter.gd:18-20`
   - **거치지 않는 길**(`is_valid_destination_for_unit`, 즉 판 안 + 빈 칸만 보고 칸을 바로 바꿈): **고치지 않고 보고만 한다.**
     1. 적을 쓰러뜨린 뒤 한 칸 전진: `_apply_resolver_advance_toward_target`(`battle_web_import_test.gd:5628-5635`)
     2. 기술의 후퇴 이동: `_apply_resolver_retreat_move`(`:5638-5658`)
     3. 기술 뒤 재배치 후보: `battle_production_controller.gd:140-152`, 이동은 `:225`
     4. 증원 도착: 장면 표식 자리에서 칸을 정함(`battle_web_import_test.gd:9317`, `:9343`). 이동 탐색과 무관하다.
   - [추정] 1–3은 막힌 칸 안으로 부대를 보낼 수 있다. 막으려면 `is_valid_destination_for_unit`이나 각 함수에 막힌 칸 확인을 더해야 하는데, 이번 승인 범위(목록 + `is_cell_walkable`) 밖이다.
3. **시작 칸·증원 도착 칸과 숲(기본 전투)**:
   - 적 **관우는 숲 칸 (14,2)에서 시작**한다.
   - **아군 증원 2(`ally_reinforce_02_test_unit`)는 (1,7)**, **적 증원 1(`enemy_reinforce_01_demo`)은 (14,1)** 숲 칸에 도착한다.
   - 나머지(이순신 (3,8), 정도전 (5,7), 권율 (4,6), 아군 증원 1 (3,9), 장비 (12,3), 하후돈 (13,4), 적 증원 2 (16,3))는 숲이 아니다.
   - 숲 위의 부대는 떠날 수 있다(아래 4). 관우는 첫 적 턴에 (14,2) → (10,2)로 나왔다(캡처 `_03`).
4. **막힌 칸 위에 이미 선 부대**: `cell == start_cell → true`를 그대로 두었다. 떠나는 것은 허용하고 들어가는 것만 막는다. 시험으로 확인했다(숲 (1,5)에서 (3,5)로 나감, 옆 숲 (1,6)으로는 못 감).
5. **목록이 비었을 때 동작이 같은지**:
   - 검사 방법: 시험이 서비스와 별개로 같은 방향 순서의 너비 우선 탐색을 직접 짜서, 이동 가능 칸과 **모든 경로 배열**을 바이트 단위로 비교한다(5가지 경우 × 기본값과 `set_blocked_cells([])` 두 번).
   - 기존 이동 시험 `test_battle_movement_query_service`, `test_battle3d_movement_parity`도 그대로 통과했다.

## 2) 구현

- **엔진**(커밋 `2ccb801`):
  - `battle_grid_controller.gd`: `blocked_cells`, `set_blocked_cells`, `is_blocked`를 추가만 했다.
  - `battle_movement_query_service.gd`: `is_cell_walkable`에 두 줄만 추가했다(`if grid_controller.is_blocked(cell): return false`).
  - 다른 엔진 변경은 0이다.
- **3D**(커밋 `faa0f73`): `battle3d_engine_play.gd`가 엔진을 연 뒤 `forest_cells()`를 부른다. 이 함수는 랩이 이미 읽는 지형(`board.terrain`, `terrain_types.json`)에서 놀이 구역 18×10의 숲 칸을 모은다(24칸). 그 목록을 `queries.grid.set_blocked_cells(...)`로 한 번 넘긴다.
  - 3D의 읽기·표시는 바꾸지 않았다.
  - 아군 클릭 거부는 엔진의 경로 확인이 한다. 3D 쪽에 같은 거부를 또 만들지 않았다.

## 3) 시험 (모두 새 파일, 60초 안)

| 파일 | 무엇 | 검사 | 시간 |
|---|---|---|---|
| `test_battle_blocked_cells.gd` | 서비스와 시험의 독립 탐색 비교. ① 목록 빔: 5가지 × 2번, 이동 가능 칸과 모든 경로가 같음 ② 숲 24칸 막힘: 같은 비교, 경로가 숲을 밟지 않음, 숲으로 가는 경로 없음 ③ 대조: 막지 않으면 같은 출발점에서 숲 칸에 닿음 ④ 벽(x=5, y0–7): (3,2)→(7,2) 우회 16걸음 = 독립 계산, 15걸음이면 불가 ⑤ 숲 (1,5) 위의 부대: (3,5)로 떠날 수 있고 (1,6)으로는 못 감 | 8 | 0.6초 |
| `test_battle3d_t1_blocked_cells.gd` | 셸(기본 전투). 엔진 격자가 숲 24칸을 막음. 이순신 (3,8)을 선택하면 그려지는 이동 범위 14칸에 숲 0(대조: 막지 않은 독립 탐색에는 숲 (1,8),(0,8),(1,9),(1,7)). 숲 (1,8) 클릭 → 엔진 거부(랩 거부 수 +1, 칸·`has_moved`·단계 그대로). 대조: 평지 (4,8) 클릭 → 이동 | 5 | 6초 |
| `test_battle_t1_enemy_ai_blocked.gd` | 엔진만. 시드 1·2·3마다 ① 자유 실행에서 적이 간 칸 기록((10,2),(9,3),(9,4),(6,2),(6,3),(5,4),(11,1)) ② 같은 시드로 그 칸 + 숲 31칸을 막고 다시 실행 → 막힌 칸에서 끝난 적 이동 0, 적은 여전히 7번 이동(둘러감). 3라운드 시작까지 | 3 | 28–35초 |

**변이**(`evidence/mutations.txt`와 로그) [사실]:

| 변이 | blocked_cells | 3D | AI |
|---|---|---|---|
| M1 `is_cell_walkable`의 막힘 검사 제거 | 실패 7 | 실패 3 | 실패 3 |
| M2 3D가 목록을 안 넘김 | (엔진 시험은 스스로 넣음) | 실패 4 | — |
| M3 적 AI 경로·이동 가능 칸 계산이 목록을 비우고 계산 | — | — | 실패 3 |

- 처음 AI 시험(숲만 막음)에서는 M1과 M3가 **살아남았다**. 기본 전투의 적은 오른쪽 위에서 왼쪽 아군으로 가므로 숲으로 가지 않는다. 그래서 위 해석 5처럼 바꿨다.

**검증기 `tools/validate_t1_blocked_cells.py`**(새 파일, `6319738`로 고정):
- 범위
- 격자 파일은 추가만, 서비스는 정확히 두 줄 추가, `is_cell_walkable`의 순서
- 랩: 추가만, `engine.call`·`engine.get` 이름 집합이 기준과 같음, 기존 15개 각각 같은 횟수, 새 `set_blocked_cells` 1번 = **16**
- 기존 검증기는 바꾸지 않았다.

## 4) 전체 검사 (한 번, Windows, 워크플로 목록 그대로, Godot 3개 병렬, 원문 `evidence/ci_full/`)

- **검증기 70개 실패 0. Godot 시험 193개 중 실패 17.** 실제 걸린 시간은 1,680초다. [사실]
- **실패 17개**(각 첫 실패 줄, 원문 `evidence/ci_full/*.log`):

| 시험 | 첫 실패 |
|---|---|
| `scenario_victory_seed_1/2/3` | `ally_move_event_log == engine alone` |
| `auto_equivalence_seed_1/2/3` | `final 40-field units equal` |
| `auto_hold_seed_1/2/3` | `4.0x final units equal` |
| `option_ai_level_auto` | `same write sequence (43)` |
| `enemy_turn_equivalence_shard_2` | `M10_round_two_slots 40-field units equal ["units[7].grid_cell"]` |
| `strategy_equivalence` | `G9_shaken_enemy_acts_in_slot … ["units[7].grid_cell"]` |
| `defend_equivalence` | `D5_last_ally_defend_round_reset … ["units[7].grid_cell"]` |
| `wait_equivalence` | `W5_wait_two_enemy_slots … ["units[7].grid_cell"]` |
| `scenario_defeat` | `final units and controller == engine alone` |
| `reinforce_default_rounds` | `timeout phase facing_select`, `40-field units equal ["units[3].grid_cell", "units[4]…"]` |
| `strategy_rejections` | `both lock windows observed ["queue"]` |

- **원인** [사실 + 추정]:
  - 이 시험들은 같은 전투를 ① 3D 랩(이제 숲을 막은 엔진)과 ② **3D 없이 엔진만**(막힌 칸 없음) 돌려, 부대 상태·이동 기록·쓰기 순서가 같은지 본다.
  - 3D 랩만 숲을 막으니, 숲을 지나거나 숲에 들어가던 이동이 달라졌다. 예: `units[7]`은 적 증원 1로, 도착 칸이 숲 (14,1)이다.
  - [추정] `strategy_rejections`의 "잠금 구간을 둘 다 봄"과 `reinforce_default_rounds`의 시간 초과도, 이동이 달라져 시험이 기다리던 상황이 오지 않은 것이다.
- **고치는 방법 후보**(결정 필요, 이번에는 하지 않음):
  1. 시험의 "엔진만" 기준에도 같은 막힌 칸 목록을 넣는다(시험 보조 파일 `tests/scripts/support/*`를 바꿈). 기대값 자체는 그대로다.
  2. 막힌 칸을 전투 설정(엔진 쪽 데이터)으로 옮긴다. 그러면 3D 랩과 엔진만 쪽이 같은 목록을 쓰지만, 엔진 변경 범위가 넓어진다.

## 5) F12 캡처 (`evidence/captures_F12`)

| 파일 | 화면 |
|---|---|
| `_01` | 이순신 (3,8) 선택, 줌 30. **그려진 이동 범위(파란 원)가 왼쪽 숲 칸을 비켜 간다**((1,7),(1,8),(0,8),(1,9) 없음) |
| `_02` | 숲 (1,8) 클릭 뒤. 거부되고 이순신은 (3,8) 그대로 |
| `_03` | 아군이 모두 대기한 뒤 적 턴. 관우가 숲 (14,2)에서 (10,2)로 나왔다(줌 30) |
| `_04` | 같은 장면, 줌 42 |

## 6) CI

- 기능 가지 첫 푸시(`d8490fc`) CI 실행: **번호 70**(run 40523782873). [추정] 위 17개와 같은 실패가 날 것이다.

## 7) 김작이 F6로 볼 것

1. 숲 칸을 누르면 이동이 거부되는지
2. 이동 범위 표시가 숲을 피하는지
3. 적이 숲으로 안 들어가는지
4. 숲 밖 이동은 예전과 같은지

## 8) 정할 것

1. 동등성 시험 17개를 어떻게 맞출지(위 4의 후보 1 또는 2)
2. 이동 탐색을 거치지 않는 길 3곳(전진, 후퇴, 재배치)도 막을지. 엔진 변경 범위가 넓어진다.
3. 숲에서 시작하는 관우와 숲에 도착하는 증원 둘을 어떻게 할지. T2에서 숲 군락을 옮기면 사라질 수 있다.


## 9) 동등성 시험 17개 처리 (김작 지시 10-28, 1~6단계) — **3단계에서 멈춤**

**1단계 (증거)** [사실, `evidence/step1_no_list/`]: 3D 랩이 목록을 넘기지 않게 잠깐 바꾸고(`set_blocked_cells` 줄을 뺌) 17개를 다시 돌렸다. **17개 모두 통과**(0/17 실패)했다. 이 17개의 실패 원인은 막힌 칸 목록 하나뿐이다. 확인 뒤 랩 코드는 되돌렸다.

**2단계 (17개와 실패 내용)** [사실, 전체 검사 원문 `evidence/ci_full/*.log`]:
- 부대 번호는 엔진 목록 순서다: 0 이순신, 1 정도전, 2 권율, 3 아군 증원 1, 4 아군 증원 2, 5 관우, 6 장비, 7 하후돈, 8 적 증원 1, 9 적 증원 2. 고정 장면(fixture) 시험에서는 같은 번호의 부대 상태를 시험이 바꾸어 둔다.
- 로그에는 다른 필드 이름만 남고, 칸 값은 남지 않는다.

| 시험 | 달랐던 것 |
|---|---|
| `scenario_victory_seed_1/2/3` | 아군 이동 기록(`ally_move_event_log`)이 엔진만과 다름 |
| `auto_equivalence_seed_1/2/3`, `auto_hold_seed_1/2/3` | 최종 부대 상태, 아군 이동 기록, `acted_enemy_ids.enemy_reinforce_01_demo`(적 증원 1은 숲 (14,1)에 도착), `ally_momentum` |
| `option_ai_level_auto` | 쓰기 순서(43), 최종 부대, 아군 이동 기록 |
| `enemy_turn_equivalence_shard_2`(M10) | `units[7].grid_cell`(하후돈의 도착 칸), 적 행동 기록 |
| `strategy_equivalence`(G9) | 같음: `units[7].grid_cell` |
| `defend_equivalence`(D5) | 같음: `units[7].grid_cell` |
| `wait_equivalence`(W5) | 같음: `units[7].grid_cell` |
| `scenario_defeat` | 최종 부대와 컨트롤러, 적 행동 기록, 책략 기록과 쓰기 순서(40) |
| `reinforce_default_rounds` | `facing_select` 시간 초과, 쓰기 순서, `units[3].grid_cell`, `units[4].grid_cell / facing / last_action`(아군 증원 1·2) |
| `strategy_rejections` | "잠금 구간 둘 다 봄"에서 `queue`만 못 봄 |

**3단계 (비교 기준에도 같은 목록)** [사실, `evidence/step3_with_ref/`]:
- 새 보조 파일 `tests/scripts/support/battle3d_blocked_reference.gd`를 만들었다. 랩의 `forest_cells()`와 같은 출처(랩 보드의 지형, 놀이 구역 숲)로 목록을 만들어, 같은 API(`battle_grid_controller.set_blocked_cells`)로 넣는다.
- "엔진만" 전투를 여는 보조 파일 7곳(`auto`, `enemy_turn`, `option`, `reinforce`, `skill`, `strategy`, `wait` 하네스의 `open_bare` 등)에 `await host.initialized` 바로 뒤 한 줄씩 넣었다. 기대값·허용 오차·시험 내용은 그대로다. `battle_setup_s43_harness`는 3D와 비교하지 않으므로 넣지 않았다.
- **결과: 17개 중 15개 통과, 2개 실패.**
  1. `test_battle3d_reinforce_default_rounds.gd`: `timeout phase facing_select`.
     - [사실] 시험의 칸 고르기 `first_free_cell`(17–24줄)은 "이동 가능 칸 중 x·y 순 첫 칸"이고, 이동 가능 목록에는 출발 칸도 들어 있다.
     - 아군 증원 2는 숲 (1,7)에 도착한다. 숲을 막으면 (0,7),(1,6),(1,8)이 빠지고 첫 칸이 **자기 자리 (1,7)**이 된다.
     - [추정] 제자리 이동이라 방향 선택 단계가 오지 않는다.
     - 고치려면 시험의 칸 고르는 규칙(출발 칸 제외 등)을 바꿔야 한다. 비교 조건이 아니라 시험 내용 변경이라 하지 않았다.
  2. `test_battle3d_strategy_rejections.gd`: `both lock windows observed ["queue"]`.
     - [사실] 이 시험은 "흔들린 적이 움직여 공격하는 재생 대기열" 동안 버튼이 거부되는지 본다(52–72줄).
     - [추정] 숲이 막히자 그 적의 이동·공격이 바뀌어 대기열 구간이 생기지 않는다. 비교 기준과 무관하게 장면에 기댄 시험이다.
- **멈춘 지점**: 3단계("17개가 목록을 넣은 상태에서 통과해야 함")를 채우지 못했다. 4단계(목록 빔 = T1 이전 비교 새 시험), 5단계(변이), 6단계(전체 검사, 푸시, T2)는 하지 않았다.
- 3단계의 보조 파일 변경 8개는 커밋했지만 **푸시하지 않았다**(6단계 조건 미충족). 원격 T1 가지는 그대로 `a143b5e`다.

**정할 것**:
1. `reinforce_default_rounds`의 칸 고르기에서 출발 칸을 뺄지(시험 내용 변경), 아니면 증원 도착 칸을 숲 밖으로 옮길지(T2의 숲 군락 이동으로 풀릴 수 있음)
2. `strategy_rejections`의 장면을 숲과 무관하게 바꿀지, 아니면 숲 군락 이동(T2) 뒤 다시 볼지

## 10) 남은 2개의 원인 증거와 결정 (김작 지시 10-28: "Do T2 first") — **15/17, 2개 T2 대기**

김작 결정: T2를 먼저 한다. 단, 두 시험의 실패 원인을 증거로 먼저 확인한다. 원인이 도착 칸/장면과 숲의 겹침이면 T2로 진행하고, 엔진 쪽 문제면 멈춘다. 시험 기대값 수정·삭제·건너뜀은 하지 않는다.

증거: `evidence/step3_causes/`(조사 스크립트 2개와 원문 로그). 같은 스크립트를 숲 목록 그대로 한 번, 목록을 비운 뒤(`set_blocked_cells([])`) 한 번 돌렸다.

**1. `test_battle3d_reinforce_default_rounds.gd`** — 실패 메시지 `timeout phase facing_select`, `same write sequence [...]` [사실, `probe_reinforce.log`]
- 걸린 부대: 아군 증원 2 `ally_reinforce_02_test_unit`(을지문덕), 3라운드 도착 칸 **(1,7) = 숲 칸**(막힘).
- 이웃: (0,7) 숲·막힘, (1,6) 숲·막힘, (1,8) 숲·막힘, (2,7) 평지지만 2라운드에 아군 증원 1이 와 있음(아군 증원 1은 숲 목록일 때 첫 칸 (2,7)로 이동; 목록 없으면 (0,9)로 이동).
- 그래서 이동 가능 칸이 **(1,7) 자기 자리 하나**뿐이고, 시험의 첫 칸 고르기가 제자리를 고른다. 제자리 클릭은 이동이 아니라 다시 선택이 되어(3D 쓰기 마지막이 `_select_ally_unit`) 방향 선택 단계가 오지 않는다.
- 목록을 비우면 첫 칸은 (0,6)이고 시험이 지나간다.
- 판정: **도착 칸 (1,7)과 숲의 겹침.** 엔진은 막힌 칸을 거부한 것이고(맞는 동작), 도착은 이동 탐색을 거치지 않아 숲 위에 내린다(조사 2에서 보고한 길, 범위 밖).

**2. `test_battle3d_strategy_rejections.gd`** — 실패 메시지 `both lock windows observed ["queue"]` [사실, `probe_strategy.log`]
- 9절의 설명을 바로잡는다: 본 것은 `queue`이고 **못 본 것은 `enemy_turn`**(엔진 적 턴 중 버튼 거부)이다.
- 장면은 `M10_round_two_slots` 고정 장면이다. 하네스가 먼 적을 (17,0),(16,0),(15,0),(14,0)에 둔다. 걸린 부대: `units[7]` 하후돈, **(16,0) = 숲 칸**(막힘). 이 장면에서 아직 행동하지 않은 적은 하후돈 하나다.
- 이웃: (17,0) 숲·막힘, (15,0) 숲·막힘, (16,1) 숲·막힘, (16,-1) 판 밖 → 움직일 수 없다.
- 숲 목록: 하후돈은 `enemy_waited reason=wait`만 하고 이동이 없다. 적 턴이 한 프레임 안에 끝나 `enemy_turn` 단계를 보는 프레임이 없다(시간선 4개 모두 `ally_turn`).
- 목록 비움: 하후돈이 (16,0)→(15,0)→(14,0)→(13,0)으로 움직이고 `enemy_turn` 단계가 167~201프레임 동안 보인다.
- 판정: **고정 장면의 칸 (16,0)과 숲의 겹침.** 같은 이유로 M10/G9/D5/W5의 `units[7].grid_cell` 차이도 설명된다(3단계 비교 기준으로 해결됨).

**결정**: 두 원인 모두 숲과 장면의 겹침이고 엔진 문제가 아니므로 T2로 진행한다. 이 가지(`898ca6f` + 이 보고서 커밋)를 기능 가지에만 푸시한다. T2는 군락을 시작 칸, 증원 도착 칸, 고정 장면의 칸에서 떨어뜨려 놓고 끝에 17/17을 확인한다.

- T1 검증기 고정 판정(`T1_SCOPE_TIP=6319738`)은 그대로 통과한다. HEAD 판정은 3단계 보조 파일 8개를 범위 밖으로 잡는다(이 방식이 승인되면 범위를 넓혀야 함).

## 11) T2 전체 검사에서 찾은 T1 쪽 문제 — `battle_setup_port_base_parity` 1·2 (고치지 않음)

- T2 전체 검사(Godot 194개)에서 `test_battle_setup_port_base_parity_shard_1/2.gd` 2개만 실패했다. 실패 메시지는 `seed_N ally_move_event_log / controller / enemy_action_event_log / round_snaps / units equals BASE ...`(골든 값과 다름)이다.
- 이 시험은 "설정 키가 없으면 엔진만 돌린 자동 전투 = BASE(e835800)의 골든 값"을 본다. 하네스 `battle_setup_s43_harness.gd`는 `battle3d_auto_harness.gd`를 상속하고, 3단계에서 그 `open_bare`에 넣은 막힌 칸 한 줄(비교 기준에 숲 목록 넣기)을 그대로 물려받는다. 3단계 설명의 "s43은 3D와 비교하지 않으므로 넣지 않았다"는 틀렸다. 직접 넣지는 않았지만 상속으로 들어간다.
- 증거 [사실, `evidence/step3_causes/`]:
  - 이 가지 끝 `1050ff7`(숲 24칸)에서 1번 묶음 실패(`t1_tip_1050ff7_shard_1.log`). T2 끝과 같은 값으로 실패한다.
  - T2에서 auto 하네스의 그 한 줄만 뺀 상태: 통과, 36 checks, 실패 0(`t2_without_reference_in_auto_harness_shard_1.log`).
- 이 가지의 앞선 전체 검사(`a143b5e`)는 3단계 전이라 드러나지 않았다. 3단계 뒤에는 17개만 다시 돌렸다.
- 정할 것: s43 하네스(BASE 골든 비교)에서 목록을 빼는 쪽(상속받은 `open_bare`를 BASE 비교에서는 목록 없이)으로 고칠지. 시험 내용 변경이라 지시 없이 하지 않았다.

## 12) 11의 처리 (김작 결정 10-28: "Fix the s43 harness")
- `64bbd44`: `battle_setup_s43_harness.gd`에 자체 `open_bare`를 두었다. auto 하네스의 `open_bare`에서 T1 비교 기준 줄만 뺀 것이다. 시험과 기대값은 그대로다. s43을 쓰는 시험 7개(BASE 비교 1·2 묶음 포함 8개 실행)는 모두 엔진 단독이고 3D와 비교하지 않는다.
- 이 가지 끝에서 그 8개: 실패 0(`evidence/s43_fix_on_t1/`).
- 이 가지의 남은 실패는 동등성 2개(`reinforce_default_rounds`, `strategy_rejections`)로, T2에서 풀린다. T2 가지(이 고침을 cherry-pick)의 전체 검사는 검증기 71, Godot 194, 실패 0이다.
