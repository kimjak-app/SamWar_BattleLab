# Domestic Tech Manual QA Scenario Pack

Version: `v0.70-76 Domestic Tech Manual QA Scenario Pack`
Baseline: `v0.70-75-hotfix1 Cost Display QA Polish` (`8a50087de9d1b4f720cb91d32255960e5a6df585`)

## Scope Lock
- This pack is manual QA documentation and a QA helper target only.
- Do not implement actual research cost deduction, affordability checks, paid cost state, refund/reservation/cancel flow, extra research slots, enemy research, enemy effects, battle/diplomacy/spy/market/city_intel/AI formulas, troop/ship/siege count mutation, tech definition changes, assets, or `.import` changes.
- Research cost remains display-only: `cost_display_only = true`, `cost_charged = false`, `cost_charged_on_start = false`, `cost_charged_per_turn = false`, `cost_charged_on_completion = false`, `cost_blocks_research_start = false`, `paid_cost_state_persisted = false`, and `cost_affordability_checked = false`.

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
