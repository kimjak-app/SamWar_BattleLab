# Domestic Tech Labor / Policy Resource Design

## v0.70-89 Labor Policy Resource State Design

### 1. v0.70-89 Conclusion
- `labor` / `policy` are not actual charge targets in the current MVP.
- `labor` / `policy` remain display-only planned cost resources.
- First-choice follow-up direction:
  - `labor = city-only labor_pool`.
  - `policy = national-only policy_points`.
- Actual implementation must wait for a separate version that defines save/load schema, turn recovery or production loops, UI policy, manual QA, and old-save compatibility.
- Current actual charge target remains `gold + food group`.
- City tech food group deduction order remains `rice -> barley -> seafood`.
- National tech keeps the currently confirmed gold-charge-centered model.

### 2. Option Comparison

#### Option A. MVP display-only
- Decision: keep for v0.70-89.
- Pros:
  - No save/load schema change.
  - No city/national resource ownership ambiguity.
  - Current actual charge stability is preserved.
  - The existing `gold + food group` charge axis is not disturbed.
- Cons:
  - `labor` / `policy` can still appear as planned cost without being deducted.
  - Mid/late-game cost pressure has fewer real resource levers.

#### Option B. national-only policy point
- Policy would be a nation-level resource.
- It would be charged only by national research, not city research.
- Pros:
  - Fits long-term national strategy costs.
- Risks:
  - Requires a persistent national state key.
  - Requires acquisition and recovery loop design.
  - Requires save/load schema extension and migration policy.

#### Option C. city labor pool
- Labor would be a city-level resource.
- It could be used by city research, construction, recruitment support, repairs, and logistics projects.
- Pros:
  - Makes city research feel tied to local production and manpower.
- Risks:
  - Must decide whether labor is separate from city storage.
  - Can conflict with population, security, agriculture, and recruitment systems.
  - Requires save/load schema extension and migration policy.

#### Option D. labor city-only + policy national-only
- Labor would be a city resource and policy would be a national resource.
- Pros:
  - Clear role separation between city research and national research.
  - Stronger identity difference between city and national tech.
- Risks:
  - Adds two resource families at once.
  - Expands QA, UI, save/load, and balance scope.
- Decision:
  - This is the preferred future direction, but it is deferred. v0.70-89 documents the direction only.

### 3. Scope

#### labor
- Nature: city-level manpower, mobilization capacity, and work capacity.
- Recommended scope: city-only.
- Future owner: selected PLAYER city.
- Future uses:
  - city research
  - construction
  - repair
  - recruitment support
  - logistics project
- MVP status:
  - display-only.
  - no actual charge.

#### policy
- Nature: national administrative power, policy momentum, and coordination capacity.
- Recommended scope: national-only.
- Future owner: PLAYER nation.
- Future uses:
  - national research
  - law reform
  - diplomacy
  - tax/admin reform
  - decree
- MVP status:
  - display-only.
  - no actual charge.

### 4. Charge Timing If Implemented Later
- Charge once upfront when research starts.
- No per-turn charge.
- No completion charge.
- Cancel/refund remains outside MVP.
- No retroactive charge.
- Do not store paid state in the active research payload.
- Run affordability validation before active research creation.
- If resources are insufficient: no deduction and no active research creation.

### 5. Save/Load Policy
- v0.70-89 does not change save/load schema.
- Before implementation, decide:
  - national policy point key name
  - city labor point key name
  - initial values
  - turn production/recovery rules
  - storage location
  - save/load migration method
  - old save compatibility
  - UI display location
- Candidate city labor keys:
  - `labor`
  - `labor_pool`
  - `workforce`
- Candidate national policy keys:
  - `policy`
  - `policy_points`
  - `administrative_power`
- Recommended naming:
  - city: `labor_pool`
  - national: `policy_points`
- No persistent key is added in v0.70-89.

### 6. UI Policy
- Current actual charge targets:
  - `금`
  - `군량`
- Current display-only planned costs:
  - `노역`
  - `정책`
- Do not mix `노역` / `정책` into the current actual charge line.
- If later UI must expose them before implementation, use comment-style copy:
  - `계획 비용: 노역 N / 정책 N`
  - `참고 비용: 노역 N / 정책 N`
- v0.70-89 does not change UI behavior.
- UI wording polish is deferred to a later `Labor Policy Cost UI Label Polish` task.

### 7. Follow-up Implementation Conditions
Labor/policy actual charge may be implemented only after all of these are decided:
1. persistent state key
2. national/city owner
3. initial value
4. turn production/recovery loop
5. save/load migration
6. UI display location
7. F6 manual QA checklist
8. old save compatibility
9. actual charge validation extension design
10. shortage message policy

### 8. Strict Preservation Locks
- Do not change actual charge gameplay logic.
- Do not change gold deduction.
- Do not change food group deduction.
- Do not change food group order: `rice -> barley -> seafood`.
- Do not change affordability validation logic.
- Do not change active research creation logic.
- Do not change active research payload schema.
- Do not change save/load schema.
- Do not add paid cost state.
- Do not add cancel/refund.
- Do not add per-turn charge.
- Do not add completion charge.
- Do not add retroactive charge.
- Do not change cost/duration/effect balance values.
- Do not change UI behavior.
- Do not change BattleContext.
- Do not change pending invasion schema.
- Do not connect battle, diplomacy, spy, market/trade, or city_intel formulas.
- Do not add enemy research/effect.
- Do not change assets, icons, UI64 files, imports, or scene files.
