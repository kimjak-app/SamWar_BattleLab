# T1 — 엔진: 이동 불가 칸(막힌 칸 목록) (2026-10-27~28, 밤샘)

## 해석 선택 (밤샘 규칙: 질문 없이 가장 합리적인 해석)
1. **막힌 칸 목록의 자리**: `BattleGridController`의 `blocked_cells`(Dictionary, 기본 빈 목록)에 `set_blocked_cells(cells)`와 `is_blocked(cell)`을 두었다(지시서 기본안). 판 크기를 정하는 `is_in_bounds`가 있는 곳이고, 이동 서비스가 이미 받는 객체라 서비스의 함수 서명을 바꾸지 않아도 된다.
2. **`is_cell_walkable` 순서**: 판 안 확인 → 출발 칸이면 참(떠나기 허용) → **막힌 칸이면 거짓** → 다른 부대 확인. 기존 구조를 그대로 두었다.
3. **새 쓰기의 이름과 모양**: `set_blocked_cells`이다. 기존 쓰기 이름 규칙(`set_enemy_ai_level`, `set_auto_presentation_hold`)을 따랐다. 랩이 이미 읽는 엔진 격자(`queries.grid = engine.get("battle_grid_controller")`)에 한 번 부르고, `engine.call` 이름은 하나도 늘리지 않았다. 엔진 쓰기는 15 + 1 = 16개다.
4. **이동 탐색을 거치지 않는 길**(조사 2): 지시서 §3대로 **보고만 하고 고치지 않았다**. 이동 탐색에 포함되지 않아 이번 범위 밖이다.
5. **적 AI "여러 시드"**: 엔진 전역 `seed(1|2|3)`로 돌렸다. [사실] 기본 전투에서는 세 시드의 결과가 같다.
   - 처음 시험은 숲만 막았는데, 적이 원래 숲으로 가지 않아서 변이가 살아남았다(아래 4).
   - 그래서 같은 시드로 먼저 자유롭게 돌려 적이 간 칸을 기록하고, 그 칸들과 숲을 함께 막아 다시 돌리도록 바꿨다.

## 결과 요약: **첫 실패에서 멈춤**

- 전체 검사에서 **시험 17개가 실패**했다. 모두 **"3D 랩으로 돌린 전투 = 엔진만 돌린 전투"를 비교하는 동등성 시험**이다(아래 5). 규칙대로 시험은 고치지 않았다.
- **T2는 시작하지 않았다.** 시작 조건이 "T1 전체 검사 전부 통과"였다.
- 이 기능 가지는 허락에 따라 CI용으로 푸시했다(통합 가지는 건드리지 않음).

| 상태 | 브랜치 | 기준 | 끝 해시 | 커밋 |
|---|---|---|---|---|
| 첫 실패로 멈춤 | `feature/t1-blocked-cells-20261027` | `0947281`(통합) | 이 보고서를 담은 커밋(zip `commit_info.txt`) | 6 |

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

- 기능 가지 푸시 뒤 실행 번호는 zip의 `commit_info.txt`와 최종 보고에 적는다. [추정] 위 17개와 같은 실패가 날 것이다.

## 7) 김작이 F6로 볼 것

1. 숲 칸을 누르면 이동이 거부되는지
2. 이동 범위 표시가 숲을 피하는지
3. 적이 숲으로 안 들어가는지
4. 숲 밖 이동은 예전과 같은지

## 8) 정할 것

1. 동등성 시험 17개를 어떻게 맞출지(위 4의 후보 1 또는 2)
2. 이동 탐색을 거치지 않는 길 3곳(전진, 후퇴, 재배치)도 막을지. 엔진 변경 범위가 넓어진다.
3. 숲에서 시작하는 관우와 숲에 도착하는 증원 둘을 어떻게 할지. T2에서 숲 군락을 옮기면 사라질 수 있다.
