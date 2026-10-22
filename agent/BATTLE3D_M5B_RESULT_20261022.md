# BATTLE3D M5-b 결과 — **멈춤**: 엔진 시나리오 주입점(S4-3)이 필요하다 (2026-10-22)

- 작업 ID: M5-b 3D Scenario / Result Overlay / New Battle (밤샘 연속 ③)
- 지시문: `NIGHT2_M5A_M4C2_M5B_20261022.md` (클코치)
- 브랜치 `feature/battle3d-m5b-scenario-20261022` ← `origin/integration/p1-engine-core-20261019`(기준 `8957b27` 확인. M5-a·M4-c2에 쌓지 않음)
- 커밋 1개(보고서만): `docs(battle3d): M5-b stop report - an engine scenario injection point is needed (S4-3)`. 제품 코드·테스트·validator 변경 없음. 작성자·커미터 `noreply@anthropic.com`. 푸시 안 함.
- 합격 판정은 하지 않는다(검수: 클코치).

## 멈춘 이유 (지시문 §3-2 ① 멈춤 규칙)

**엔진 코드를 바꾸지 않고 시나리오 시작 상태(승리 연습의 적 병력 약 1/4)를 정할 정상 경로가 없다.**

1. 엔진이 `_ready` 전에 읽는 외부 입력은 **월드맵 전투 데이터 전달 경로 하나뿐**이다.
   - `Engine.set_meta("samwar_worldmap_battle_context", {...})`
   - 엔진은 `_ready` → `_read_worldmap_battle_context_handoff()`에서 이것을 읽고 지운 뒤 `_apply_worldmap_battle_context_handoff()`로 적용한다(`battle_web_import_test.gd` L1474, L1486~).
   - 이 경로로 병력은 바꿀 수 있다: 영웅 항목의 `allocated_troops` / `initial_allocated_troops` / `max_troops`(L8683~8691).
2. 그런데 이 경로를 쓰면 엔진이 그 전투를 **월드맵 전투로 취급**한다. 확인한 결과(읽기만, 실행 안 함):

   | 동작 | 내용 | 위치 |
   |---|---|---|
   | **세이브** | 이어하기 스냅샷 ID가 생겨, 페이즈가 바뀔 때마다 `GameSession.save_battle_resume_snapshot(...)`을 부른다 | L6606 `_get_current_battle_resume_id`, L6641 |
   | **월드맵 이동** | 후퇴 명령이 `_return_to_worldmap_with_result()` → `get_tree().change_scene_to_file(WORLDMAP_SCENE_PATH)`로 간다. 결과 후 "월드맵으로 돌아가기" 버튼이 켜진다 | L5924, L2826~2842, L2812~ |
   | **로스터** | 도시·영웅 데이터로 아군·적 편성을 다시 정한다. 기본 배치와 같은 장수·병력이 된다는 보장이 없다 | L1767, L1819~ |

   - 지시문 금지 사항("월드맵·세이브 호출 금지", "월드맵으로 가지 않는다")과 정면으로 부딪친다.
   - 월드맵 계약을 흉내 내는 가짜 데이터를 3D 제품 코드가 만드는 것은 우회·땜질이다.
3. 그 밖의 방법은 모두 지시문이 금지한다.
   - 하니스처럼 생성 후 유닛 필드를 직접 쓰는 방법(`current_troops`, `max_troops`, `allocated_troops`, `initial_allocated_troops`, `current_hp`, `max_hp`): 3D 제품 코드가 엔진 상태를 직접 쓰는 것이다.
   - 엔진에 공개 설정 함수가 없다. 승인되지 않은 엔진 호출도 금지다.

그래서 이 단계는 **코드를 만들지 않았다**. 다음 단계로 넘어갈 것도 없다(마지막 단계).

## 확인한 사실 (사전 확인 5개, 코드 읽기)

1. **시작 상태 경로**: 위 "멈춘 이유"와 같다.
   - 기본 배치 유닛은 엔진 `_ready` 안의 테스트 전투 설정(`enemy_unit_state = BattleUnitState.create({...})` 등, L11680~)에서 만들어진다.
   - 월드맵 데이터가 없으면 그대로 쓰인다("월드맵 전투 데이터 없음 · 테스트 전투" 로그).
2. **병력을 줄일 때 함께 맞춰야 하는 필드**:
   - `current_troops`, `max_troops`, `allocated_troops`, `initial_allocated_troops`(엔진 핸드오프 적용 코드 L8686~8691이 이 넷을 함께 맞춘다)
   - 피해·사망은 `current_hp` 기준이라 `current_hp`·`max_hp`도 맞춰야 한다. S3/S4 하니스의 `_setup_unit`이 여섯 필드를 함께 쓰는 것과 같다.
   - 일부만 바꾸면 3D 병력 표시(`current_troops/max_troops`)와 실제 사망 판정(`current_hp`)이 어긋난다. 생존 병력 계산(`_calculate_unit_surviving_allocated_troops`, `initial_allocated_troops` 기준)도 틀어진다.
3. **새 전투 시작 정리**: 랩·엔진 호스트를 해제하고 다시 만드는 것은 기존 테스트가 이미 반복한다. M3~M4-c1 격리 테스트, M5-a 테스트가 한 프로세스에서 10회 이상 연 뒤 노드 누수 0을 확인했다.
   - 정리할 것: ISO 투영 컨트롤러 해제, `GameAudio` 보이스 정지(호스트 `_exit_tree`), `Engine.time_scale`(M5-a `_exit_tree`가 1.0으로), 자동 상태(엔진 노드와 함께 사라짐), 전역 난수(시드는 테스트에서만)
   - 이 부분은 막히지 않는다.
4. **결과 확정 경로**: 월드맵 데이터가 없는 독립 랩에서는 결과 영상·토스트까지만 간다. 월드맵 복귀는 데이터가 없어 "월드맵 전투 데이터 없음"으로 막힌다(L2826~). 기존 테스트의 `worldmap_calls == 0`으로 확인됐다. 3D는 `battle_ended` 이벤트만으로 결과 오버레이를 띄운다(M3부터).
5. **결과 값**: 결과 상태(`battle_ended.result_state`), 라운드(적 로그 `round_started`/3D `current_round`), 생존 아군 수(어댑터 14필드 `current_troops > 0` + 배치 플래그)는 이미 승인된 읽기로 얻을 수 있다. 막히지 않는다.

→ ③~⑤는 가능하다. **① 시나리오 시작 상태만 막혔다.** 결과 오버레이·다시 시작만 먼저 만들 수도 있지만, 지시문의 멈춤 규칙(그 단계는 코드를 더 만들지 않음)에 따라 만들지 않았다.

## 제안: S4-3 엔진 시나리오 주입점 (엔진 단계, 구현자가 아니라 클코치·김작 결정)

- **목적**: 월드맵과 무관한 "시작 상태 덮어쓰기" 입력. 기본 배치의 장수·위치는 그대로 두고, 지정 유닛의 병력 필드만 일관되게 바꾼다.
- **모양(제안)**:
  - 엔진 `_ready`에서 월드맵 데이터 읽기와 **별개인** 메타 키(예: `samwar_battle_scenario_overrides`)를 한 번 읽고 지운다.
  - 내용은 `{"unit_overrides": {unit_id: {"troops_ratio": 0.25}}}` 같은 순수 값이다.
  - 엔진이 6필드(`current_troops`, `max_troops`, `allocated_troops`, `initial_allocated_troops`, `current_hp`, `max_hp`)를 **엔진 자신의 규칙으로** 맞춘다.
  - 월드맵 데이터·이어하기 ID·세이브·월드맵 복귀는 켜지지 않는다.
  - 또는 엔진 공개 함수 `apply_battle_scenario(overrides)`를 첫 아군 턴 전에 한 번만 허용한다.
- **검증**: 없는 키면 BASE와 바이트 동등(골든). 있으면 지정 필드만 바뀜. 세이브·월드맵 호출 0(validator). 3D 쓰기 목록은 늘지 않고, 호스트가 메타를 넣는 것만 승인.
- 그 뒤 M5-b(시나리오 선택, 결과 오버레이, 다시 시작, 승리 연습 자동 완주)를 원래 지시문대로 진행한다.

## 기능 상태 / UI 상태 / 실제 조작 증거 / 남은 연결

- 기능·UI: 없음(코드 미작성).
- 실제 조작 증거: 없음(창 캡처 없음). 근거는 위의 코드 위치뿐이다. 엔진을 실행하지 않았다.
- 남은 연결: S4-3 → M5-b 전체.

## 새로 돌린 것 / 재사용

- 새로 돌린 것: 없음(코드 읽기만). 전체 CI도 돌리지 않았다. 변경이 이 보고서 1개라 기준 커밋과 실행 결과가 같다.
- 재사용: M5-a·M4-c1 격리 테스트 결과(사전 확인 3), 기존 테스트의 `worldmap_calls == 0`(사전 확인 4).

## 결정 사항

| 항목 | 결정 | 이유 |
|---|---|---|
| 월드맵 데이터 경로로 시나리오 흉내 | 하지 않음 | 세이브·월드맵 이동이 켜짐(지시문 금지), 월드맵 계약 위조 |
| 결과 오버레이·다시 시작만 먼저 구현 | 하지 않음 | 멈춤 규칙: 그 단계는 코드를 더 만들지 않음 |
| 브랜치·커밋 | 보고서만 담은 커밋 1개 | 상태 보고(브랜치·커밋·zip)를 단계별로 남기기 위함 |
