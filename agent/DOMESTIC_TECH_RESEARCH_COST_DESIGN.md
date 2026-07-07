# Domestic Tech Research Cost Actual Charge Design Draft

Version: `v0.70-80 Domestic Tech Research Cost Actual Charge Design Draft`
Baseline: `v0.70-79 Domestic Tech Actual F6 QA Result Record` (`4a939a49b33aedb6c0e309dba47cdcdd2f42d02e`)

## 1. Current State
- Domestic Tech 1차 구현은 F6 Actual Manual QA에서 PASS 확인됨.
- 연구 시작/진행/완료, completion refresh, one national active, one city active per PLAYER city, same-city only, completed prerequisite, and researching no-effect are active.
- 연구 비용은 현재 `예상 비용 ... · 표시 전용`이다.
- Actual charge is not implemented.
- Cost gating is not implemented.
- Affordability check is not implemented.
- Paid cost state is not implemented.
- Enemy research/effect is absent.
- Safe Set effects remain locked.

## 2. Design Goals
- Define how actual research cost charging should work before implementation.
- Keep v0.70-80 as design draft only.
- Preserve the v0.70-79 F6 PASS state.
- Minimize save/load schema risk.
- Avoid changing active research payloads unless a later task explicitly approves it.
- Keep implementation scope small enough for `v0.70-81` MVP.

## 3. Actual Charge Timing
- 연구 시작 시 1회 선차감한다.
- 연구 진행 중 매턴 차감하지 않는다.
- 연구 완료 시 추가 차감하지 않는다.
- 연구 완료 실패/중단 시스템이 없으므로 완료 시 정산 없음.

Reason:
- This is the simplest implementation boundary.
- Resource availability and payment are clear at research start.
- It avoids per-turn charge UI, save, and interruption complexity.
- It has low conflict risk with existing active research.

Out-of-scope timing:
- 매턴 분할 차감.
- 완료 시 후불 차감.
- 완료 실패 시 환불.
- 진행 중 유지비.

## 4. Affordability
- 연구 시작 버튼 클릭 시 비용 보유 여부를 확인한다.
- 부족하면 연구를 시작하지 않는다.
- 부족한 자원을 메시지로 알려준다.
- 기존 active research에는 영향을 주지 않는다.
- 연구 가능 상태 표시에는 `예상 비용`과 `부족` 상태를 구분한다.

Draft only:
- v0.70-80 does not run an actual affordability check.
- v0.70-80 does not block research start.
- v0.70-80 only records planned flags through docs/helper.

## 5. Start Button UX
- prerequisite 부족: 시작 버튼 비활성 또는 조건 부족 표시.
- active slot 사용 중: 시작 버튼 비활성 또는 연구 중 표시.
- 자원 부족: 시작 버튼 비활성 또는 클릭 시 부족 메시지.
- 연구 가능 + 자원 충분: 시작 가능.
- 완료됨: 시작 버튼 숨김 또는 완료 표시.

Draft only:
- v0.70-80 makes no UI behavior change.
- v0.70-81 may choose disabled-button gating or click-to-message gating after implementation scope is fixed.

## 6. Deducted Resource Targets
Base display resources:
- 금 / gold.
- 군량 / food display group.
- 노역 / labor.
- 정책 / policy.

Resource Cost Scope:
- 금/gold: 국가 또는 도시 공통 비용으로 사용 가능.
- 군량/food: 주로 도시/군사/해군/공성 계열에 사용 가능.
- 노역/labor: 도시 건설/방어/조선/공성 계열에 사용 가능.
- 정책/policy: 국가 정책/외교/첩보 계열에 사용 가능.

Current implementation evidence:
- Current cost plan uses `planned_gold_cost`, `planned_food_cost`, `planned_labor_cost`, and `planned_policy_cost`.
- Current player resource stock uses keys such as `gold`, `rice`, `barley`, and `seafood`.
- Current city persistence can carry city-level `resource_stock`.
- The display label `군량` must not be treated as a literal state key.

Mapping requirement for v0.70-81:
- `금` -> `gold`.
- `군량` -> define a concrete food-group policy, likely `rice` first or aggregate `rice/barley/seafood`.
- `노역` -> no confirmed persistent state key yet; keep display-only or introduce only after a separate state-key decision.
- `정책` -> no confirmed persistent state key yet; keep display-only unless national policy resource state is explicitly added.

## 7. National Tech Cost Scope
- PLAYER 국가 자원에서 차감한다.
- 국가 테크는 city resource를 직접 차감하지 않는다.
- Recommended v0.70-81 source: `_player_state.resource_stock` for implemented resource keys.
- 정책/policy 비용은 national state에 존재할 경우에만 실제 적용한다.
- If policy resource does not exist, v0.70-81 may charge only implemented keys and keep policy display-only.

## 8. City Tech Cost Scope
- 선택된 PLAYER city의 자원 또는 PLAYER 국가 공용 자원 중 현재 시스템에 맞는 쪽에서 차감한다.
- same-city only 원칙 유지.
- 다른 city 자원에 영향을 주지 않는다.
- enemy city에는 비용 차감/연구 시작 없음.

Implementation candidate:
- Prefer selected PLAYER city `resource_stock` when present and stable.
- If selected city lacks usable resource stock, fallback to `_player_state.resource_stock` must be a conscious v0.70-81 decision, not an implicit behavior.
- The exact food-group deduction order must be defined before implementation.

## 9. Existing Active Research Compatibility
- v0.70-81 도입 이전에 이미 active인 연구는 비용을 소급 차감하지 않는다.
- 기존 active research에는 paid-cost state를 강제로 추가하지 않는다.
- 새로 시작하는 연구부터 actual charge를 적용한다.
- active research의 `remaining_turns` / `duration_turns`는 변경하지 않는다.

Reason:
- Retroactive charge can destabilize save data and QA state.
- The existing F6 PASS state should remain valid.
- Active payload schema should remain compatible.

## 10. Cancel / Refund Policy
- v0.70-81 Actual Charge MVP에서는 연구 취소 기능을 구현하지 않는다.
- 환불 기능도 구현하지 않는다.
- 연구 시작 시 선차감 후 연구는 계속 진행된다.
- 취소/환불은 별도 버전에서 설계한다.

Reason:
- Cancel/refund touches save state, UI, returned resource calculation, active slot release, and edge cases.
- It is larger than the first Actual Charge MVP.

## 11. UI Wording Policy
Current wording:
- `예상 비용 · 표시 전용`

Actual charge wording candidates:
- `필요 비용`
- `연구 시작 시 차감`
- `부족: 금 N / 군량 N`

Recommended v0.70-81 rules:
- 연구 가능 + 충분: show `필요 비용`.
- 연구 가능 + 부족: show `부족`.
- 연구 중: prioritize remaining turns over cost.
- 완료: hide cost.
- 조건 부족: show prerequisite/condition shortage first, not cost shortage.

Draft only:
- v0.70-80 keeps the current display-only wording in gameplay.

## 12. Save Data Policy
- Actual Charge MVP에서는 별도 paid-cost state 저장을 만들지 않는다.
- 비용은 연구 시작 순간 즉시 차감되므로 paid flag가 필요 없다.
- active research payload에 cost-paid fields를 추가하지 않는다.
- 기존 active payload schema를 흔들지 않는다.
- Existing active research remains compatible and unmodified.

Reason:
- Minimize save schema churn.
- Preserve backward compatibility.
- Avoid mixing display-only-era active research with paid-state assumptions.

## 13. Failure Handling
- 비용 계산 결과가 비어 있거나 0이면 비용 없는 연구로 처리 가능.
- 음수 비용은 0으로 clamp.
- 알 수 없는 resource key는 실제 차감하지 않고 debug/QA summary에 기록.
- 자원 state가 없는 경우 actual charge 구현에서 해당 resource를 skipped로 처리하거나 구현 대상에서 제외.
- 연구 시작 실패 시 active research를 생성하지 않는다.
- Partial deduction must not occur; if any required implemented resource is insufficient, no resource is deducted and no active research is created.

Draft only:
- v0.70-80 does not implement these checks.

## 14. v0.70-81 Implementation Candidates
Option A: `v0.70-81 Domestic Tech Research Cost Actual Charge MVP`
- Charge implemented resource keys once on research start.
- Add start-time affordability validation.
- Block start when implemented resource cost is insufficient.
- Keep no cancel/refund.
- Keep no paid-cost state.
- Keep existing active research compatibility.

Option B: `v0.70-81 Research Cost Affordability UI Polish`
- If the implementation risk is high, first add clearer UI affordance and QA summaries without actual charge.
- Keep display-only behavior until actual charge MVP is separately approved.

Recommended order:
1. Implement Actual Charge MVP only for confirmed state keys (`gold` and a defined food group).
2. Add Affordability UI Polish after basic charge correctness is stable.
3. Revisit labor/policy as a later state-design task.

## 15. Not In This Draft
- No actual cost deduction.
- No actual cost gating.
- No actual affordability check.
- No paid cost state.
- No research cancel.
- No refund.
- No active research payload schema change.
- No research slot change.
- No enemy research/effect.
- No BattleContext change.
- No pending invasion schema change.
- No tech definition id/name/category/branch/prerequisite change.
- No asset/import change.
