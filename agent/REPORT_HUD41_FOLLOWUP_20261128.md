# 큐 42 보고 — 큐 41 후속: 시험 보강 + 결과 줄 표기

- 지시서: `agent/ORDER_HUD41_FOLLOWUP_TESTS_20261128.md`
- 가지: `feature/wm3d-hud41-followup-20261128`, 기준 `main` `c9af897`
- 커밋: 코드 `daf3b79`(`[skip ci]` 없음) → 이 보고서(`[skip ci]`). `worldmap_main.gd` 변경 0이라 재고정 없음. 동작·규칙 값 변경 0.

## 1. 바꾼 것 (문구만, `scripts/worldmap/ui/worldmap_hud_connect_presenter.gd`)
| 전 | 후 |
|---|---|
| `· 3턴 결과 성사: 수동 무역 …` (`N` = 내부 `source_turn`) | `· 교역 결과 성사: 수동 무역 … — 받은 것 금 N · 보낸 것 쌀 100` |
| `· 3턴 결과 처리: 사절 파견 → …` | `· 외교 결과 처리: 사절 파견 → …` |
| `무효 · 예약분 반환` (무효면 늘) | 실제로 돌려받은 양이 있을 때만 `무효 · 예약분 반환 (쌀 100)`, 없으면 `무효` |
| `무효 · 돌려줄 도시가 없어 반환 보류` | `무효 · 돌려줄 도시가 없어 반환 보류 (쌀 100)` (장부 `unrefunded`) |
정산 순서·저장값·장부 필드는 그대로. 턴 숫자는 지시서 2절대로 빼고 영역 이름을 붙였다.

## 2. 시험 — `tests/scripts/test_worldmap_hud41_followup.gd` (C-track 등록, HUD-41 시험 뒤)
`[HUD41_FOLLOWUP] checks=33 failures=[]` — 모두 장부(도시 창고·관계 점수·`spy_cooldown`·요청 `reserved_assets`/`result`/`unrefunded`) 값으로 확인.
1. 민심 교란 **시도했지만 실패**(판정 100 고정, 발각 100) / **발각**(판정 100, 발각 1):
   - 둘 다: 금 정확히 300 한 번(`{"gold": 300}`), 쿨다운 = 기존 `_get_spy_public_support_disrupt_cooldown_turns()` 값으로 시작, 민심 그대로.
   - 발각: 관계 점수 −10(기존 `SPY_DETECTED_RELATION_PENALTY_PUBLIC_SUPPORT`), 실패만이면 관계 그대로 ✔
2. 비단만 1 부족: 충성 교란(금 500 + 비단 49), 반란 선동(금 800 + 비단 99) → `resources` 거부, 차감 0·쿨다운 0·민심 변화 0 ✔
3. 무역 표시 = 장부 양 (문자열 + 숫자):
   - 접수 줄 "접수됨 … (예약 쌀 100)" = 장부 `reserved_assets`(쌀 100) ✔
   - 정산 줄 "교역 결과 성사 … 받은 것 금 N · 보낸 것 쌀 100" = 장부 `result.received` / `result.paid` ✔
   - 무효(교역 불가로 바뀜) 줄 "무효 · 예약분 반환 (쌀 100)" = 장부 `result.refunded` ✔ / 돌려받은 것이 없는 무효 결과는 "교역 결과 무효"만, "예약분 반환" 없음 ✔
   - 보류(플레이어 도시 0) 줄 "무효 · 돌려줄 도시가 없어 반환 보류 (쌀 100)" = 장부 `unrefunded`, "예약분 반환" 없음 ✔
4. 외교 결과 줄 "외교 결과 처리", 교역·외교 어느 줄에도 "N턴 결과" 없음 ✔
- 큐 41 시험 `test_worldmap_hud_connect_3d` 다시 `checks=69 failures=[]`(3D 켜짐, 결과 줄 확인은 "결과" 포함이라 그대로).

## 3. CI
- `Verify C-track refactor` 실행 `46071133984` (head `daf3b79`): **초록**, 4개 묶음(shard 0~3) 모두 success, 재실행 없음. 끝난 시각 2026-11-27 21:54 UTC.
- `Verify WorldMap3D`: 경로 조건에 걸리는 파일이 없어 돌지 않음(지시서 "해당 시").

## 4. 로컬 전체
- 작업 트리 `daf3b79`: C-track 시험 217개(CI 목록 그대로, 4개 병렬) **217 실행, 217 종료 코드 0**. 검증 스크립트 72개 **72 통과**.
- WorldMap3D는 경로 조건에 걸리는 파일이 없어 해당 없음(3D·씬·마커 스크립트 변경 0).

## 5. 남은 문제
- 없음(이번 범위). 결과 줄은 그 턴 정산 결과만 보여 준다(이전 턴 결과는 `last_strategy_request_results`가 다음 정산에서 바뀜) — 결과 기록 목록은 HUD 정리 때.
