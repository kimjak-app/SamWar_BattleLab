# Domestic Tech Actual Manual QA Pass

Version: `v0.70-78 Domestic Tech Actual Manual QA Pass`
Baseline: `v0.70-76-hotfix1 Manual QA Grace Turns QA Polish` (`39c27de2e1fa074e522facaf5a147759a298ffb6`)

## 1. QA Purpose
이번 QA는 실제 기능 추가가 아니라 Domestic Tech 1차 실적용 상태를 F6에서 수동 검수하기 위한 Actual Manual QA Pass다.

- F6에서 실제 수동 QA를 수행할 수 있도록 확인 항목과 기록 양식을 고정한다.
- 연구 시작/진행/완료, 1~10턴 침입 유예, Safe Set 효과, cost display-only, enemy/unknown no-display, UI64/click/overlay lifecycle을 실제 플레이 순서로 검수한다.
- 이번 버전은 실제 gameplay mutation을 최소화한다. 비용 차감, 비용 부족 gating, 연구 슬롯 추가, enemy research/effect, 전투/외교/첩보/시장/AI 공식 연결, BattleContext/pending invasion schema 변경, asset/import 변경은 금지한다.

## 2. Baseline / Version / Commit
- Version: `v0.70-78 Domestic Tech Actual Manual QA Pass`
- Baseline: `v0.70-76-hotfix1 Manual QA Grace Turns QA Polish`
- Baseline commit: `39c27de2e1fa074e522facaf5a147759a298ffb6`
- Required lock: `MANUAL_QA_NO_INVASION_GRACE_TURNS = 10`
- Required helpers: `_is_manual_qa_invasion_grace_turn_active_mvp()`, `_get_manual_qa_grace_summary_mvp()`, `_format_domestic_tech_research_cost_display_mvp()`, `_get_domestic_tech_research_cost_display_summary_mvp()`, `_get_domestic_tech_research_balance_summary_mvp()`, `_get_domestic_tech_full_effect_integration_summary_mvp()`

## 3. Before F6
Confirm before starting manual QA:
1. Project opens without new warnings.
2. `WorldMap_Test.tscn` can run with F6.
3. Domestic Tech Tree opens from the worldmap UI.
4. 국가 테크 / 도시 테크 tabs are visible.
5. UI64 icons resolve first, existing `icon_path` fallback resolves second, and `?` appears only as final fallback.
6. Cost copy uses `예상 비용` or `계획 비용` plus `표시 전용`.
7. No copy implies payment, shortage, reservation, refund, affordability check, or paid state.

## 4. 1~10 Turn Invasion Grace QA
Procedure:
1. F6 실행.
2. 새 테스트 시작.
3. 현재 턴 확인.
4. 1턴부터 10턴까지 턴 진행.
5. 새 pending invasion 생성 여부 확인.
6. enemy pressure 생성 여부 확인.
7. strategic pressure follow-up 생성 여부 확인.
8. Domestic Tech 연구 진행이 막히지 않는지 확인.
9. income이 정상 처리되는지 확인.
10. 11턴 이후 기존 침입 로직이 복귀 가능한지 확인.

Expected:
- turn 1~10 동안 새 invasion 없음.
- turn 1~10 동안 새 pending invasion 없음.
- turn 1~10 동안 enemy pressure 없음.
- turn 1~10 동안 strategic pressure follow-up 없음.
- 기존 pending invasion 삭제 없음.
- 턴 진행 정상.
- 연구 진행 정상.
- income 정상.
- UI refresh 정상.
- BattleContext no-touch.
- pending invasion schema no-touch.
- enemy AI global disable 없음.

## 5. National Tech QA
### National Tech Start
Confirm:
- 국가 테크트리 열림.
- Tier 1 국가 테크 선택.
- 상태가 연구 가능인지 확인.
- 연구 소요 턴 표시.
- 예상 비용 표시.
- `표시 전용` 문구 확인.
- 연구 시작 클릭.
- 국가 active research 생성 확인.
- 다른 국가 테크는 active slot 때문에 연구 시작 불가 또는 대기.
- 비용 차감 없음.

### National Tech Progress
Confirm:
- 턴 진행.
- `remaining_turns` 감소.
- 연구 중 상태 표시.
- 예상 비용이 과하게 표시되지 않음.
- 연구 중 효과는 completed로 취급되지 않음.

### National Tech Completion
Confirm:
- 완료 턴 도달.
- `completed = true` 기록.
- 완료 메시지.
- left national panel 갱신.
- Domestic Tech inspector 갱신.
- national policy / diplomacy-spy 표시 갱신.
- duplicate completion 없음.

## 6. City Tech QA
### City Tech Start
Confirm:
- PLAYER 도시 선택.
- 도시 테크트리 열림.
- Tier 1 city tech 선택.
- 연구 가능 상태.
- 연구 소요 턴 표시.
- 예상 비용 표시.
- `표시 전용` 문구 확인.
- 연구 시작 클릭.
- 해당 PLAYER city에 active research 생성.
- 다른 PLAYER city에는 active research 전파 없음.
- enemy city에는 연구 시작 불가.
- 비용 차감 없음.

### City Tech Progress
Confirm:
- 턴 진행.
- selected city `remaining_turns` 감소.
- 다른 city의 `remaining_turns`와 혼동 없음.
- 연구 중 상태 표시.
- 연구 중 효과는 completed로 취급되지 않음.

### City Tech Completion
Confirm:
- completed city tech 기록.
- city completed mirror 유지.
- city detail 갱신.
- Domestic Tech inspector 갱신.
- 후속 테크 조건 해금.
- same-city only 유지.
- duplicate completion 없음.

## 7. Safe Set Effects QA
### Economy Safe Set
Confirm:
- agriculture / fish / commerce 계열 completed city tech만 적용.
- food/gold/supply 표시 변화 확인.
- turn income과 city detail 표시가 납득 가능한지 확인.
- national tax bonus 중복 적용 없음.
- enemy city income에 PLAYER tech effect 누수 없음.

### Military/Defense Safe Set
Confirm:
- 훈련/방어 준비 표시 확인.
- 실제 troop stat 변경 없음.
- troop count 자동 증가 없음.
- `battle_effects_applied = 0` 유지.
- BattleContext / pending invasion no-touch.

### National Policy Safe Set
Confirm:
- completed national tech만 표시/효과.
- `tax_gold_percent` 한 번만 적용.
- tax 외 정책 효과는 display/prep 중심.
- enemy national effect 없음.

### Naval/Siege Display Safe Set
Confirm:
- 조선/수군/공성 준비 표시 확인.
- ship count 자동 증가 없음.
- siege weapon count 자동 증가 없음.
- naval/siege battle modifier 없음.

### Diplomacy/Spy Display Safe Set
Confirm:
- 외교/첩보 준비 표시 확인.
- diplomacy success 변경 없음.
- spy success 변경 없음.
- relation 변경 없음.
- city_intel 공개 없음.
- AI diplomacy/spy 변경 없음.

## 8. Expected Cost Display-only QA
Confirm:
- 국가 테크 예상 비용 표시.
- 도시 테크 예상 비용 표시.
- 금 / 군량 / 노역 / 정책 표시 순서.
- 0값 resource no-display.
- 완료 상태에서 비용 숨김 또는 최소 표시.
- 연구 중 상태에서 남은 턴 우선.
- 연구 가능 상태에서 예상 비용 표시.
- 조건 부족 상태에서 비용 부족처럼 보이지 않음.
- `예상 비용 · 표시 전용` 문구 확인.

Expected:
- 연구 시작 시 gold/food/labor/policy 차감 없음.
- 턴 진행 시 비용 차감 없음.
- 연구 완료 시 비용 차감 없음.
- 비용 부족으로 start button 막힘 없음.
- affordability check 없음.
- paid state 없음.

## 9. Enemy / Unknown No-display QA
Confirm:
- enemy city 선택.
- unknown city 선택.
- insufficient intel city 선택.
- right city panel이 상세 tech effect를 노출하지 않는지 확인.
- Domestic Tech inspector가 enemy city tech/effect를 노출하지 않는지 확인.
- enemy research start/progress/completion 없음.
- enemy tech effect 없음.
- Fog of War / `city_intel` 정책 유지.

Expected:
- left panel은 항상 PLAYER 국가/조정/테크 정보 only.
- right panel은 현재 선택 PLAYER city 정보 only.
- enemy/unknown city에는 상세 tech effect no-display.
- `enemy_effects_applied = 0`.

## 10. UI64 / Click / Overlay QA
Confirm:
- UI64 icon visibility.
- existing `icon_path` fallback.
- `?` fallback.
- node title/status 표시.
- selected highlight.
- node click 즉시 inspector 갱신.
- node click에서 graph full rebuild 없음.
- click latency 없음.
- overlay close button.
- ESC close.
- reopen.
- panel restore.
- opened/closed state 안정성.
- Godot Output warning cleanliness.

Expected:
- 아이콘 깨짐 없음.
- 선택 지연 없음.
- overlay 닫기/열기 정상.
- 신규 warning 없음.

## 11. Godot Output Warning QA
Forbidden warning regressions:
- exact local `seed` variable.
- `target_label` block shadowing.
- local `resource_label`.
- local `selected_city_id`.
- `sign` parameter shadowing.
- local `loyalty_card` shadowing.

Expected:
- Project headless load, `WorldMap_Test.tscn` headless load, and `Battle_Fullscreen_Test.tscn` headless load do not introduce new project warnings from this pass.

## 12. PASS / NEEDS FIX Result Template
```text
# Domestic Tech Actual Manual QA Result

Version:
Commit:
Tester:
Date:

## 1. Grace Turns
- Turn 1~10 no invasion:
- Turn 1~10 no pending invasion:
- Turn 1~10 no enemy pressure:
- Turn 11 invasion logic returns:
- Notes:

## 2. National Research Flow
- Start:
- Progress:
- Completion:
- Completion refresh:
- Notes:

## 3. City Research Flow
- Start:
- Progress:
- Completion:
- Same-city only:
- Notes:

## 4. Safe Set Effects
- Economy:
- Military/Defense:
- National Policy:
- Naval/Siege:
- Diplomacy/Spy:
- Notes:

## 5. Cost Display
- National cost:
- City cost:
- Display-only wording:
- No deduction:
- No gating:
- Notes:

## 6. Enemy / Unknown No-display
- Enemy city:
- Unknown city:
- Insufficient intel:
- Notes:

## 7. UI / Overlay
- Icon visibility:
- Click latency:
- Close / ESC / reopen:
- Panel restore:
- Warnings:
- Notes:

## Final Verdict
- PASS / NEEDS FIX
- Blocking Issues:
- Polish Issues:
```

---

# Domestic Tech Manual QA Scenario Pack Archive

Version: `v0.70-76-hotfix1 Manual QA Grace Turns QA Polish`
Baseline: `v0.70-76 Domestic Tech Manual QA Grace Turns` (`ab8ed193016e31046dd1d722ccc911a9ddc7a000`)

## Scope Lock
- This pack is manual QA documentation and a QA helper target only.
- Do not implement actual research cost deduction, affordability checks, paid cost state, refund/reservation/cancel flow, extra research slots, enemy research, enemy effects, battle/diplomacy/spy/market/city_intel/AI formulas, troop/ship/siege count mutation, tech definition changes, assets, or `.import` changes.
- Research cost remains display-only: `cost_display_only = true`, `cost_charged = false`, `cost_charged_on_start = false`, `cost_charged_per_turn = false`, `cost_charged_on_completion = false`, `cost_blocks_research_start = false`, `paid_cost_state_persisted = false`, and `cost_affordability_checked = false`.

## Manual QA Grace Turns
- `v0.70-76-hotfix1 Manual QA Grace Turns QA Polish` confirms the QA-only early-turn guard for F6 Domestic Tech QA.
- Turn counting is treated as 1-based for manual QA: turns 1 through 10 block new enemy pending invasion creation, enemy pressure plan creation, and enemy strategic pressure follow-up creation.
- Turn 11 and later should return to the existing invasion/pressure logic.
- The grace blocks new creation/scheduling only. It is not an existing pending invasion cleanup path and must not delete, clear, or rewrite an already existing pending invasion.
- The grace must not block turn progress, Domestic Tech research progress/completion, income, UI refresh, existing pending invasion handling, BattleContext structure, pending invasion schema, or enemy AI outside the scoped creation guards.

### Grace Turns QA Procedure
1. Run F6 and start a fresh WorldMap test.
2. Open Domestic Tech Tree.
3. Start one national or city Domestic Tech research.
4. Advance turns 1 through 10.
5. Confirm no new pending invasion is created.
6. Confirm no enemy pressure plan is created.
7. Confirm no strategic pressure follow-up is created.
8. Confirm research `remaining_turns` decreases during the grace.
9. Confirm research completion, completion message, and UI refresh still occur when the research duration ends.
10. Confirm income still processes during the grace.
11. On turn 11 or later, confirm the existing invasion/pressure logic can resume.

Expected:
- New pending invasion, enemy pressure, and strategic pressure follow-up creation are blocked only during turns 1-10.
- Existing pending invasion data is not deleted by the grace.
- Turn progress, Domestic Tech research progress, income, and UI refresh continue normally.
- BattleContext structure and pending invasion schema are untouched.
- Enemy AI is not globally disabled.

## 1. National Research Flow
### National Research Start
1. Run F6 and open Domestic Tech Tree.
2. Confirm the national tech tree tab is visible.
3. Select a Tier 1 national tech.
4. Confirm the state is researchable.
5. Confirm research duration is displayed.
6. Confirm expected cost is displayed with `예상 비용` and `표시 전용`.
7. Click research start.
8. Confirm the left national panel and Domestic Tech inspector refresh to researching state.

Expected:
- One PLAYER national active research is created.
- Only one national active slot is used.
- No gold, food, labor, or policy is deducted.
- Expected cost remains display-only.
- Other national techs are blocked or waiting because the active slot is occupied, not because of cost shortage.
- No enemy research is created.

### National Research Progress / Completion
1. Advance turns.
2. Confirm `remaining_turns` decreases.
3. Reach the completion turn.
4. Confirm completed state is recorded.
5. Confirm one completion message appears.
6. Confirm left national panel and Domestic Tech inspector effect display refresh immediately after completion.

Expected:
- No duplicate completion.
- Completed national tech counts as prerequisite.
- Researching national tech does not count as prerequisite or effect.
- National policy and diplomacy/spy display lines refresh from completed tech only.
- No research cost is charged at start, per turn, or completion.

## 2. City Research Flow
### City Research Start
1. Select a PLAYER city.
2. Open Domestic Tech Tree.
3. Confirm the city tech tree tab is visible.
4. Select a Tier 1 city tech.
5. Confirm the state is researchable.
6. Confirm research duration is displayed.
7. Confirm expected cost is displayed with display-only wording.
8. Click research start.
9. Confirm selected city detail and Domestic Tech inspector refresh to researching state.

Expected:
- Active city research is created only for the selected PLAYER city.
- One active research per PLAYER city is maintained.
- Active research does not propagate to other PLAYER cities.
- No resource cost is deducted.
- Enemy city research cannot be started.

### City Research Progress / Completion
1. Advance turns.
2. Confirm selected city `remaining_turns` decreases.
3. Complete the research.
4. Confirm completed city tech is recorded.
5. Confirm selected city detail effect display refreshes.
6. Confirm follow-up tech unlocks only when same-city prerequisites are completed.

Expected:
- Completed city tech applies only to that city.
- Same-city only is preserved.
- Other cities do not receive the completed effect.
- City completed mirror remains stable.
- No duplicate completion and no cost deduction.

## 3. Safe Set Effects
### Economy Safe Set
- Confirm only completed PLAYER city agricultural, fishery, and commerce tech affects display/income.
- Confirm food, gold, and supply display changes are understandable in turn income and city detail.
- Confirm national tax bonus is not double-applied.
- Confirm PLAYER tech effects do not leak into enemy city income.

### Military/Defense Safe Set
- Confirm training and defense preparation display appears only from completed tech.
- Confirm actual troop stats do not change.
- Confirm troop count does not auto-increase.
- Confirm `battle_effects_applied = 0`.
- Confirm BattleContext and pending invasion flows are untouched.

### National Policy Safe Set
- Confirm only completed PLAYER national tech affects policy display/effects.
- Confirm `tax_gold_percent` is applied once.
- Confirm non-tax policy effects remain display/preparation oriented.
- Confirm enemy national effects remain absent.

### Naval/Siege Display Safe Set
- Confirm shipbuilding, navy, and siege preparation display appears only from completed same-city tech.
- Confirm ship count and siege weapon count do not auto-increase.
- Confirm no naval/siege battle modifier is applied.

### Diplomacy/Spy Display Safe Set
- Confirm diplomacy and spy preparation display appears only from completed PLAYER national tech.
- Confirm diplomacy success, spy success, relation, and city_intel do not change.
- Confirm no AI diplomacy/spy behavior changes.

## 4. Cost Display
Confirm:
- National tech expected cost display.
- City tech expected cost display.
- Resource order is gold, food, labor, policy: `금`, `군량`, `노역`, `정책`.
- Zero-value resources are hidden.
- Completed tech hides or minimizes expected cost.
- Researching tech prioritizes remaining turns.
- Available tech shows expected cost.
- Locked or prerequisite-missing tech does not look cost-blocked.
- Copy uses `예상 비용 · 표시 전용` or equivalent display-only wording.

Forbidden result:
- No cost deduction when research starts.
- No cost deduction during turn progress.
- No cost deduction on completion.
- No start button blocking because of insufficient cost.
- No affordability check and no paid state.

## 5. Enemy / Unknown / Insufficient Intel No-display
Confirm:
- Select an enemy city.
- Select an unknown or insufficient-intel city.
- Right city panel does not expose detailed tech effects.
- Domestic Tech inspector does not expose enemy city tech or effects.
- Enemy research start/progress/completion does not exist.
- Enemy tech effects do not exist.
- Fog of War and `city_intel` policy remain unchanged.

Expected:
- Left panel is PLAYER national/court/tech information only.
- Right panel is current selected PLAYER city information only.
- Enemy, unknown, and insufficient-intel city detail tech effects are no-display.
- `enemy_effects_applied = 0`.

## 6. UI / Overlay
Confirm:
- UI64 icon visibility for mapped tech icons.
- Existing `icon_path` fallback still works.
- `?` fallback appears only when no icon exists.
- Node title and status labels are visible.
- Selected node highlight updates.
- Node click immediately updates inspector.
- Node click does not trigger full graph rebuild.
- No noticeable click latency.
- Overlay close button works.
- ESC closes overlay.
- Reopen works.
- Panel restore is stable.
- Opened/closed state is stable.
- Godot Output has no new warnings.

Expected:
- No broken icons.
- No delayed selection.
- Overlay close/reopen lifecycle is stable.
- No warning cleanup regression.

## Manual QA Result Template
```text
# Domestic Tech Manual QA Result

Version:
Commit:
Tester:
Date:

## 1. National Research Flow
- Start:
- Progress:
- Completion:
- Notes:

## 2. City Research Flow
- Start:
- Progress:
- Completion:
- Same-city only:
- Notes:

## 3. Safe Set Effects
- Economy:
- Military/Defense:
- National Policy:
- Naval/Siege:
- Diplomacy/Spy:
- Notes:

## 4. Cost Display
- National cost:
- City cost:
- Display-only wording:
- No deduction:
- No gating:
- Notes:

## 5. Enemy / Unknown No-display
- Enemy city:
- Unknown city:
- Insufficient intel:
- Notes:

## 6. UI / Overlay
- Icon visibility:
- Click latency:
- Close / ESC / reopen:
- Panel restore:
- Warnings:
- Notes:

## Final Verdict
- PASS / NEEDS FIX
- Blocking Issues:
- Polish Issues:
```
