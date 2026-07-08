# Domestic Tech Actual Charge Manual QA

## v0.70-94 Defense / Battle Effect Integration F6 QA

### Purpose
- Confirm completed PLAYER Defense / Battle Domestic Tech effects change modifier-backed city defense and PLAYER battle stat preparation.
- Confirm city defense tech remains same-city only.
- Confirm ENEMY baseline is not enemy research and remains masked when intel is insufficient.

### Checks
- Complete a defense city tech, then confirm the selected PLAYER city detail shows the defense/battle modifier summary.
- Confirm that completed city defense tech applies only to the same PLAYER city.
- Select another PLAYER city without that completed city tech and confirm the city defense effect does not leak.
- Complete a national military tech, then confirm PLAYER battle modifier summary changes and battle setup still opens.
- Confirm PLAYER battle roster attack/defense preparation changes only through existing stat fields, not troop count mutation.
- Select an ENEMY city with no intel and confirm defense/battle baseline details are masked.
- Select an ENEMY city after enough intel and confirm only baseline grade appears, not research effects.
- Confirm enemy active research, enemy completed tech, and enemy tech progression remain absent.
- Confirm v0.70-93 economy/city modifier summary and income path still work.
- Confirm cost charge UI and research start/progress/completion flow are unchanged.
- Confirm Godot Output has no new warning/error.

### PASS / NEEDS FIX Record
```text
Version: v0.70-94 Defense / Battle Effect Integration
Commit:
PLAYER city defense modifier appears after completion:
Same-city only:
Other PLAYER city unaffected:
National battle modifier appears after completion:
Battle setup stable:
Troop counts unchanged:
Enemy no-intel baseline masked:
Enemy baseline is not research:
Enemy research absent:
v0.70-93 economy/city effect preserved:
Actual charge preserved:
Godot Output clean:
Result: PASS / NEEDS FIX
Notes:
```

## v0.70-93 Economy / City Effect Integration F6 QA

### Purpose
- Confirm completed PLAYER Economy / City Domestic Tech effects change the modifier-backed city/national economy summary.
- Confirm the existing turn income path remains stable after routing through modifier helpers.
- Confirm ENEMY baseline is not enemy research and remains masked when intel is insufficient.

### Checks
- Complete an economy city tech, then confirm the selected PLAYER city resource tab shows the economy modifier summary.
- Confirm that completed city tech applies only to the same PLAYER city.
- Select another PLAYER city without that completed city tech and confirm the city tech effect does not leak.
- Complete a national economy/admin tech, then confirm national warehouse summary shows the national economy modifier.
- Advance turn and confirm income/resource processing still runs without duplicate Domestic Tech application.
- Select an ENEMY city with no intel and confirm baseline details are masked.
- Select an ENEMY city after enough intel and confirm only baseline grade appears, not research effects.
- Confirm enemy active research, enemy completed tech, and enemy tech progression remain absent.
- Confirm cost charge UI and research start/progress/completion flow are unchanged.
- Confirm Godot Output has no new warning/error.

### PASS / NEEDS FIX Record
```text
Version: v0.70-93 Economy / City Effect Integration
Commit:
PLAYER city modifier appears after completion:
Same-city only:
Other PLAYER city unaffected:
National modifier appears after completion:
Turn income stable:
Enemy no-intel baseline masked:
Enemy baseline is not research:
Enemy research absent:
Actual charge preserved:
Godot Output clean:
Result: PASS / NEEDS FIX
Notes:
```

## v0.70-88 Domestic Tech Balance F6 Result Record

### 1. 기준

* Base QA checklist:
  * `v0.70-87 Domestic Tech Balance F6 QA Record`
* Balance implementation:
  * `v0.70-86 Domestic Tech Balance Integration Pass`
* Current result record:
  * `v0.70-88 Domestic Tech Balance F6 Result Record`

### 2. 결과 요약

* Tier 1 cost feel:
  * PASS-ready
  * 초반 연구 1~2개를 찍는 흐름을 검수할 수 있는 상태.
* Tier 2 cost feel:
  * PASS-ready
  * Tier 2부터 비용 부담과 선택감이 생기는지 확인 항목 준비 완료.
* Tier 3+ cost feel:
  * PASS-ready
  * 중후반 목표감과 선택 부담 검수 항목 준비 완료.
* National cost/duration feel:
  * PASS-ready
  * 국가 연구가 도시 연구보다 장기 체질 개선으로 느껴지는지 확인 항목 준비 완료.
* City cost/duration feel:
  * PASS-ready
  * 도시 연구가 특정 도시 성장/방어/보급 강화로 느껴지는지 확인 항목 준비 완료.
* Economy effect feel:
  * PASS-ready
  * 농업/수산/상업 초반 성장축 체감 확인 항목 준비 완료.
* Military/Defense effect feel:
  * PASS-ready
  * 방어 준비감은 있으나 초반 압도 방지 확인 항목 준비 완료.
* National Policy effect feel:
  * PASS-ready
  * 장기 체질 개선형 보너스 확인 항목 준비 완료.
* Naval/Siege display feel:
  * PASS-ready
  * display/summary 중심 유지 확인 항목 준비 완료.
* Diplomacy/Spy display feel:
  * PASS-ready
  * display/summary 중심 유지 및 formula 미연결 확인 항목 준비 완료.
* Progression early game feel:
  * PASS-ready
  * 초반 “찍는 맛” 확인 항목 준비 완료.
* Progression mid game choice:
  * PASS-ready
  * 중반 “경제 먼저냐 군사 먼저냐” 선택감 확인 항목 준비 완료.
* Actual charge UI preserved:
  * PASS by document/code verification
  * `필요 비용`, `시작 시 차감`, `부족:` 문구 정책 보존.
* Actual charge logic preserved:
  * PASS by code preservation verification
  * v0.70-81 actual charge 모델 유지.
* Active payload schema unchanged:
  * PASS by grep/diff verification
* No formula connection:
  * PASS by grep/diff verification
* Enemy research/effect absent:
  * PASS by grep/diff verification
* Godot Output clean:
  * PASS by headless load verification
* Result:
  * PASS-ready / Manual F6 follow-up required
* Notes:
  * Codex 환경에서는 실제 F6 클릭 기반 체감 QA를 수행하지 않는다.
  * 실제 체감 PASS는 사용자가 F6에서 Tier 1~3 비용, national/city 기간, safe set 표시, progression feel을 직접 확인한 뒤 최종 PASS로 확정한다.

### 3. Manual follow-up

사용자가 F6에서 직접 확인해야 할 항목:

* Tier 1 연구가 너무 비싸거나 느리지 않은지
* Tier 2~3부터 선택 부담이 생기는지
* national tech가 장기 과제로 느껴지는지
* city tech가 특정 도시 성장으로 느껴지는지
* Economy 계열이 초반 성장축으로 느껴지는지
* Military/Defense 계열이 초반부터 압도적이지 않은지
* Naval/Siege/Diplomacy/Spy 계열이 display/summary 중심으로 유지되는지
* actual charge UI 문구가 유지되는지
* 연구 시작/진행/완료 흐름이 정상인지
* Godot Output warning/error가 없는지

### 4. PASS / NEEDS FIX 최종 수기 기록 칸

* QA Date:
* Tester:
* Version: v0.70-88 Domestic Tech Balance F6 Result Record
* Commit:
* Tier 1 cost feel:
* Tier 2 cost feel:
* Tier 3+ cost feel:
* National cost/duration feel:
* City cost/duration feel:
* Economy effect feel:
* Military/Defense effect feel:
* National Policy effect feel:
* Naval/Siege display feel:
* Diplomacy/Spy display feel:
* Progression early game feel:
* Progression mid game choice:
* Actual charge UI preserved:
* Actual charge logic preserved:
* Active payload schema unchanged:
* No formula connection:
* Enemy research/effect absent:
* Godot Output clean:
* Final Result: PASS / NEEDS FIX
* Notes:

## v0.70-87 Domestic Tech Balance F6 QA Record

### 1. QA 목적

* v0.70-86에서 통합 조정된 Domestic Tech 비용/기간/효과/진행감이 실제 F6에서 의도대로 느껴지는지 확인한다.
* 초반 연구가 너무 무겁지 않은지 확인한다.
* 중반부터 선택 부담이 생기는지 확인한다.
* 국가 연구와 도시 연구의 역할 차이가 느껴지는지 확인한다.
* actual charge / UI wording / 연구 시작·진행·완료 흐름이 유지되는지 확인한다.

### 2. Cost Balance QA

체크:

* Tier 1 연구 비용이 초반에 1~2개 찍을 수 있을 정도인지
* Tier 2 연구부터 자원 부담이 살짝 생기는지
* Tier 3 이상 연구에서 선택 부담이 생기는지
* National tech gold 비용이 너무 싸거나 과하지 않은지
* City tech gold/food 비용이 selected city storage를 너무 빨리 고갈시키지 않는지
* 군사/방어/해군/공성 계열이 농업/상업보다 약간 무겁게 느껴지는지
* actual charge UI 문구가 유지되는지:
  * `필요 비용`
  * `시작 시 차감`
  * `부족: 금 N / 군량 N`

### 3. Duration Balance QA

체크:

* City Tier 1 연구가 빠르게 완료되어 성장 체감이 있는지
* City Tier 2~3부터 기다림과 선택감이 생기는지
* National tech가 city tech보다 약간 장기 과제로 느껴지는지
* 연구 진행 중 remaining turns 표시가 정상인지
* 완료 시 완료 상태가 정상 반영되는지
* 기존 active research payload schema가 유지되는지

### 4. Effect Balance QA

체크:

* Economy Safe Set:
  * 농업/수산/상업 초반 연구가 도시 성장축으로 체감되는지
  * flat/percent 효과가 과도하지 않은지
* Military/Defense Safe Set:
  * 방어/훈련 효과가 표시상 의미는 있으나 초반부터 압도적이지 않은지
  * troop count mutation이 없는지
* National Policy Safe Set:
  * 세금/행정/병참/인구 계열 효과가 장기 체질 개선처럼 느껴지는지
* Naval/Siege Display Safe Set:
  * 해군/공성 효과가 display/summary 중심으로 유지되는지
  * ship/siege count mutation이 없는지
* Diplomacy/Spy Display Safe Set:
  * 외교/첩보 효과가 display/summary 중심으로 유지되는지
  * diplomacy/spy success formula에 연결되지 않았는지

### 5. Progression Feel QA

체크:

* 초반에 “찍는 맛”이 있는지
* 경제 테크를 먼저 찍으면 성장 안정감이 생기는지
* 군사/방어 테크를 찍으면 방어 준비감이 생기는지
* 국가 연구는 장기적 체질 개선처럼 느껴지는지
* 도시 연구는 특정 도시를 키우는 느낌이 있는지
* 중반부터 “경제 먼저냐, 군사 먼저냐” 선택이 생기는지
* 후반 테크가 중후반 목표로 느껴지는지

### 6. Preservation QA

다음이 유지되는지 확인:

* actual charge logic 유지
* food group deduction order 유지:
  * `rice -> barley -> seafood`
* active research payload schema unchanged
* paid cost state 없음
* cancel/refund 없음
* per-turn charge 없음
* completion charge 없음
* retroactive charge 없음
* enemy research/effect 없음
* BattleContext no-touch
* pending invasion schema no-touch
* battle formula connection 없음
* diplomacy formula connection 없음
* spy formula connection 없음
* market/trade formula connection 없음
* city_intel formula connection 없음
* assets/import no-touch
* scene layout no-touch

### 7. Godot Output QA

체크:

* F6 실행 중 신규 warning/error 없음
* Domestic Tech overlay open/close 중 warning/error 없음
* 연구 시작/진행/완료 중 warning/error 없음
* 부족 자원 상태에서 warning/error 없음

### 8. PASS / NEEDS FIX 기록 템플릿

* QA Date:
* Tester:
* Version: v0.70-87 Domestic Tech Balance F6 QA Record
* Commit:
* Tier 1 cost feel:
* Tier 2 cost feel:
* Tier 3+ cost feel:
* National cost feel:
* City cost feel:
* City food cost feel:
* Duration city early:
* Duration national:
* Economy effect feel:
* Military/Defense effect feel:
* National Policy effect feel:
* Naval/Siege display feel:
* Diplomacy/Spy display feel:
* Progression early game feel:
* Progression mid game choice:
* Actual charge UI wording preserved:
* Actual charge logic preserved:
* Active payload schema unchanged:
* No formula connection:
* Enemy research/effect absent:
* Godot Output clean:
* Result: PASS / NEEDS FIX
* Notes:

## v0.70-86 Domestic Tech Balance Integration Pass F6 QA

Version: `v0.70-86 Domestic Tech Balance Integration Pass`
Baseline: `v0.70-85 Research Cost Affordability F6 UI QA Record` (`d550ed33b914b66fde45dcda09505fcdd5f75e92`)

### 1. QA Purpose
- Confirm the first integrated Domestic Tech balance pass feels correct in F6.
- Confirm research cost, duration, and Safe Set effect tuning preserve actual charge and UI wording.
- Confirm no battle/diplomacy/spy/market/city_intel/AI formula connection was added.

### 2. Cost / Duration Feel
Check:
- Tier 1 city tech remains affordable enough to start one or two early researches.
- Tier 2 and Tier 3 techs create a clear resource choice.
- Tier 4+ techs feel like mid/late goals.
- National tech generally feels longer and more expensive than same-tier city tech.
- City tech feels focused on selected city growth, defense, or supply.

### 3. Safe Set Effect Feel
Check:
- Agriculture, fishery, and commerce techs give early city growth feedback.
- Military, defense, naval, and siege display bonuses do not feel overpowering too early.
- National policy bonuses feel like gradual national improvement.
- Diplomacy/Spy/Naval/Siege display values remain display-safe and do not mutate formulas or counts.

### 4. Preservation Checks
Check:
- Actual charge still occurs once on research start only.
- Food group deduction order remains `rice -> barley -> seafood`.
- Active research payload schema remains unchanged.
- UI wording still shows `필요 비용: ... · 시작 시 차감` and `부족: ...`.
- Research start/progress/completion still works.
- Godot Output has no new warning/error.

### 5. PASS / NEEDS FIX Record Template
- QA Date:
- Tester:
- Version: v0.70-86 Domestic Tech Balance Integration Pass
- Commit:
- Tier 1 cost feels light:
- Tier 2-3 choice pressure:
- Tier 4+ long-term goal:
- National duration/cost feel:
- City growth feel:
- Economy safe effects:
- Military/Defense safe effects:
- Naval/Siege display effects:
- Diplomacy/Spy display effects:
- Actual charge preserved:
- UI wording preserved:
- No forbidden formula connection:
- Godot Output clean:
- Result: PASS / NEEDS FIX
- Notes:

## v0.70-85 Research Cost Affordability F6 UI QA Record

Version: `v0.70-85 Research Cost Affordability F6 UI QA Record`
Baseline: `v0.70-84 Research Cost Affordability UI Polish` (`0af15b94c0a18cb781aa563856552c343977fa0e`)

### 1. QA Purpose
- Confirm the actual charge UI wording from v0.70-84 appears as intended in F6.
- Confirm cost wording priority for available, insufficient, researching, completed, and locked/prerequisite states.
- Confirm actual charge gameplay logic remains preserved after the UI polish.

### 2. Available + Affordable
Check:
- `필요 비용: ... · 시작 시 차감` appears for available affordable research.
- `표시 전용` does not remain in the available actual charge cost display.
- The action button says `연구 시작`.
- Starting research still deducts actual resources exactly as in v0.70-81.

### 3. Available + Insufficient Resources
Check:
- The action button says `자원 부족`.
- Shortage copy appears as `부족: 금 N`, `부족: 군량 N`, or `부족: 금 N / 군량 N`.
- Guidance appears in the `자원이 부족해 연구를 시작할 수 없습니다.` family.
- Research start is blocked.
- No partial deduction occurs.

### 4. Researching State
Check:
- `연구 중` or remaining-turn/progress state takes priority over cost wording.
- Cost wording does not cover or replace the researching state.
- No extra per-turn charge occurs.

### 5. Completed State
Check:
- `완료` state takes priority over cost wording.
- Cost wording is hidden or not confusing in completed state.
- No extra completion charge occurs.

### 6. Locked / Prerequisite State
Check:
- Locked/prerequisite status takes priority over resource shortage wording.
- The action button says `조건 부족`.
- Prerequisite shortage does not misleadingly surface resource shortage first.

### 7. National / City Common Checks
Check:
- National tech UI and city tech UI follow the same wording policy.
- City tech still uses selected PLAYER city scope only.
- Enemy, unknown, or insufficient-intel cities do not expose research cost UI.

### 8. Godot Output
Check:
- No new warning/error appears during F6 launch.
- No warning/error appears while opening or closing the Domestic Tech overlay.
- No warning/error appears while moving through insufficient, start, researching, and completed states.

### 9. PASS / NEEDS FIX Record Template
- QA Date:
- Tester:
- Version: v0.70-85 Research Cost Affordability F6 UI QA Record
- Commit:
- Available affordable wording:
- Display-only wording removed:
- Available affordable button:
- Insufficient wording:
- Insufficient button:
- Insufficient start blocked:
- No partial deduction:
- Researching state priority:
- Completed state priority:
- Locked/prerequisite state priority:
- National UI consistency:
- City UI consistency:
- Enemy/unknown no cost UI:
- Godot Output clean:
- Result: PASS / NEEDS FIX
- Notes:

Version: `v0.70-82 Domestic Tech Actual Charge Manual QA`
Baseline: `v0.70-81 Domestic Tech Research Cost Actual Charge MVP` (`b5c8bee932caaa538202ff28a226da5cb45c71c3`)

# Domestic Tech Actual Charge F6 QA Result

QA Date: 2026-07-07
Tester: 김작
Version: v0.70-82 Domestic Tech Actual Charge Manual QA
Commit: 34baf66a48caf8725556ee618c681e3b58f60355

## Confirmed
- National sufficient gold: PASS
- National insufficient gold: PASS
- National no per-turn charge: PASS
- National no completion charge: PASS
- City sufficient gold/food: PASS
- City insufficient gold: PASS
- City insufficient food: PASS
- City food deduction order: PASS
- Other city unchanged: PASS
- Existing active no retroactive charge: PASS
- Active payload schema unchanged: PASS
- Enemy/unknown no research/effect: PASS
- Godot Output clean: PASS

## Final Verdict
PASS

Notes: User reported `pass` for the v0.70-82 actual charge manual QA checklist.

## 1. QA Purpose
- Confirm Domestic Tech research cost is deducted exactly once when research starts.
- Confirm insufficient resources block research start and do not deduct any resource.
- Confirm no extra charge occurs on turn progress or completion.
- Confirm active research payload schema remains unchanged.
- Confirm the existing v0.70-79 F6 PASS flow and v0.70-81 actual charge implementation remain preserved.

## 2. National Tech QA
### Sufficient Gold Start
1. Run `WorldMap_Test.tscn` with F6.
2. Record PLAYER national gold before starting a national tech.
3. Open Domestic Tech Tree and select an available national tech.
4. Confirm copy shows `필요 비용 ... · 시작 시 차감`.
5. Start research.
6. Confirm PLAYER national gold decreases immediately by the planned gold cost.
7. Confirm one active national research is created.
8. Advance one turn and confirm gold does not decrease again from the same research.

Expected:
- Gold is charged once on start.
- Active national research exists.
- No city storage is changed by national tech start.

### Insufficient Gold
1. Prepare or find a state where PLAYER national gold is below the national tech cost.
2. Attempt to start an available national tech.
3. Confirm start is blocked.
4. Confirm no active national research is created.
5. Confirm gold is unchanged.
6. Confirm shortage copy appears, such as `부족: 금 N`.

Expected:
- No deduction.
- No active research creation.
- Clear shortage message.

### Progress / Completion
1. With a paid active national research, advance turns.
2. Confirm `remaining_turns` decreases.
3. Confirm no additional gold is charged on progress turns.
4. Reach completion.
5. Confirm completion is normal and no extra gold is charged on completion.

Expected:
- Progress and completion behavior remains normal.
- Charge timing remains start-only.

## 3. City Tech QA
### Sufficient Gold/Food Start
1. Select a PLAYER city.
2. Record selected city storage values for `gold`, `rice`, `barley`, and `seafood`.
3. Open Domestic Tech Tree and select an available city tech.
4. Start research.
5. Confirm selected city storage `gold` decreases by the planned gold cost.
6. If the city tech has planned food cost, confirm food is deducted in `rice -> barley -> seafood` order.
7. Confirm active city research is created only for the selected city.

Expected:
- Selected PLAYER city storage is charged once.
- Other PLAYER city storage remains unchanged.
- One active city research exists for the selected city only.

### Insufficient Gold
1. Prepare or find a selected PLAYER city with gold below the city tech cost.
2. Attempt to start an available city tech.
3. Confirm start is blocked.
4. Confirm no selected city storage deduction.
5. Confirm no active city research is created.

Expected:
- No deduction.
- No active research.
- Shortage copy includes gold.

### Insufficient Food Group
1. Prepare or find a selected PLAYER city where `rice + barley + seafood` is below the planned food cost.
2. Attempt to start an available city tech with food cost.
3. Confirm start is blocked.
4. Confirm `rice`, `barley`, and `seafood` are unchanged.
5. Confirm no active city research is created.

Expected:
- No partial food deduction.
- No active research.
- Shortage copy includes `군량`.

### Food Deduction Order
1. Use a selected PLAYER city with enough total food but not enough `rice` alone.
2. Start city tech research with food cost.
3. Confirm `rice` is reduced first.
4. Confirm any remaining cost is taken from `barley`.
5. Confirm any remaining cost after barley is taken from `seafood`.

Expected:
- Deduction order is exactly `rice -> barley -> seafood`.

### Scope Preservation
- Confirm other PLAYER city storage is unchanged.
- Confirm enemy, unknown, or insufficient-intel city still has no research start, no cost charge, and no effect.

## 4. Existing Active Research Compatibility QA
Confirm:
- Existing active research from before v0.70-81 is not retroactively charged.
- Active research payload does not receive paid/cost/charge fields.
- Active payload keys remain:
  - `tech_id`
  - `started_turn`
  - `remaining_turns`
  - `duration_turns`

Expected:
- No `paid`, `paid_cost`, `charged_cost`, `cost_state`, or equivalent active research field.

## 5. No Extra Charge QA
Confirm:
- No extra charge after the start turn.
- No extra charge on completion.
- No research cancel UI, refund UI, cancel behavior, or refund behavior exists.

Expected:
- Start-time charge only.
- No per-turn charge.
- No completion charge.
- No cancel/refund system.

## 6. Preservation QA
Confirm unchanged:
1. Grace Turns.
2. Research start/progress/completion.
3. One national active research.
4. One city active research per PLAYER city.
5. Completed prerequisite recognition.
6. Researching no-effect.
7. Duplicate completion guard.
8. Same-city only.
9. Safe Sets:
   - Economy.
   - Military/Defense.
   - National Policy.
   - Naval/Siege Display.
   - Diplomacy/Spy Display.
   - Full Effect Integration Summary.
10. PLAYER-only left panel.
11. Selected PLAYER city-only right panel.
12. Enemy/unknown/insufficient-intel no-display.
13. UI64 icon priority.
14. Node click latency behavior.
15. Overlay lifecycle.

## 7. Godot Output QA
Confirm:
- F6 launch has no new GDScript warning/error.
- Domestic Tech overlay open/close has no new warning/error.
- Research start, resource shortage, progress, and completion have no error.

## 8. PASS / NEEDS FIX Record Template
```text
QA Date:
Tester:
Version:
Commit:
National sufficient gold:
National insufficient gold:
National no per-turn charge:
National no completion charge:
City sufficient gold/food:
City insufficient gold:
City insufficient food:
City food deduction order:
Other city unchanged:
Existing active no retroactive charge:
Active payload schema unchanged:
Enemy/unknown no research/effect:
Godot Output clean:
Result: PASS / NEEDS FIX
Notes:
```

---

# Domestic Tech Actual Manual QA Pass

Version: `v0.70-78 Domestic Tech Actual Manual QA Pass`
Baseline: `v0.70-76-hotfix1 Manual QA Grace Turns QA Polish` (`39c27de2e1fa074e522facaf5a147759a298ffb6`)

# Domestic Tech Actual F6 QA Result

Version: v0.70-79
Base Commit: 702d6054f3ebab8f9754fa9283663c6ffb0de4cf
Result: PASS
Tester: 김작
Date: 2026-07-07

## Summary

F6에서 Domestic Tech 실제 수동 QA를 수행했다.
초반 침입 유예가 적용되어 최소 테스트 턴 확보가 가능했고,
Domestic Tech 연구 흐름과 UI 흐름이 정상 동작함을 확인했다.

이번 기록은 Domestic Tech 1차 F6 QA PASS 결과 기록이다. 최종 밸런스 완료 기록이 아니며, 실제 비용 차감과 비용 gating은 아직 별도 설계 전 상태다.

## Confirmed

- 1~10턴 침입 유예로 테스트 가능
- Domestic Tech Tree 진입 가능
- 국가/도시 연구 흐름 확인 가능
- 연구 진행/완료 흐름 정상
- 예상 비용 display-only 유지
- 비용 차감 없음
- 비용 gating 없음
- UI64 icon / click / overlay 흐름 정상
- enemy tech effect / enemy research 없음
- 신규 blocking issue 없음

## Final Verdict

PASS

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
