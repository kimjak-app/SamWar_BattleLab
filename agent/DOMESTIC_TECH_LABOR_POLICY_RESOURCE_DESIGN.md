# Domestic Tech Labor / Policy Resource Design

## v0.70-91 Labor Policy Save Schema Draft

### 1. v0.70-91 Conclusion
- `labor_pool` is drafted as a future city-state accumulated resource.
- `policy_points` is drafted as a future PLAYER national/player-state accumulated resource.
- Both resources are `accumulated resource with cap`.
- v0.70-91 does not add real persistent keys.
- v0.70-91 does not change save/load schema.
- v0.70-91 does not implement migration code.
- v0.70-91 does not implement labor/policy generation, actual charge, or UI behavior.
- v0.70-91 is a Draft lock for later implementation.
- Current actual charge target remains `gold + food group`.
- City tech food group deduction order remains `rice -> barley -> seafood`.

### 2. City Labor Save Schema Draft

#### 2.1 Future Key
Recommended key:

```text
labor_pool
```

Owner:

```text
city state
```

Type:

```text
int
```

Range:

```text
0 <= labor_pool <= labor_cap
```

#### 2.2 Future Storage Location Candidates
Code-read note for v0.70-91:
- WorldMap save currently serializes `player_state` and `worldmap_city_state`.
- City runtime serialization currently preserves selected city fields such as `resource_stock`, `storage`, and `city_tech`.
- City load currently normalizes `resource_stock`, `storage`, and `city_tech` from `worldmap_city_state`.

Candidate locations:

```text
city["labor_pool"]
city["resource_stock"]["labor_pool"]
city["domestic_resource_state"]["labor_pool"]
```

Judgment criteria:
- Must not conflict with existing city gold/rice/barley/seafood storage.
- Must not accidentally join manual trade/storage behavior unless explicitly intended.
- Must be stable under save/load and easy for the city panel to read.
- Must keep labor meaning clear: local work capacity, not warehouse goods.

Draft recommendation:
- Do not blindly put labor into the same bucket as `rice`, `barley`, `seafood`, or trade goods.
- A city root key or a dedicated future city domestic-resource bucket is safer than treating labor as physical storage.
- Final storage must be confirmed in the implementation task after reviewing the exact save/load touchpoints again.

#### 2.3 Initial Value Draft
Preferred initial value:

```text
labor_pool_initial = min(labor_cap, floor(labor_cap * 0.5))
```

Simple MVP fallback:

```text
labor_pool_initial = 20
```

City-size candidates:

```text
small city: 15~25
medium city: 30~50
large city: 60~90
capital/major city: 80~120
```

Principles:
- Old saves should not start at zero unless the design intentionally wants a slow first turn.
- Starting near 30~50% of cap is preferred.
- First F6 testing should allow at least one Tier 1 city research in a reasonable city.

#### 2.4 Cap Draft
Simple future MVP candidate:

```text
labor_cap = 50 + city_tier * 40
```

Fallback when city tier is unavailable:

```text
labor_cap = 80
```

City-size candidates:

```text
small city: 50
medium city: 100
large city: 160
capital/major city: 220
```

Cap principles:
- Prevent infinite accumulation.
- Let large cities and capitals feel better at major projects.
- Facilities, roads, offices, barracks, shipyards, and Domestic Tech may later increase cap.

#### 2.5 Migration Draft
If an old save has no `labor_pool`:

```text
labor_pool = labor_pool_initial
```

If an old save has no valid cap value:

```text
labor_cap = default_labor_cap
```

Migration principles:
- Old saves must not break.
- Missing key means default initialization, not error.
- Migration must be idempotent.
- Values must be clamped after migration.
- v0.70-91 does not implement migration.

#### 2.6 Save/Load Validation Draft
Future implementation checks:

```text
if labor_pool missing:
    initialize
if labor_pool < 0:
    clamp to 0
if labor_pool > labor_cap:
    clamp to labor_cap
if labor_cap missing or invalid:
    use default cap
```

### 3. National Policy Save Schema Draft

#### 3.1 Future Key
Recommended key:

```text
policy_points
```

Owner:

```text
PLAYER national state
```

Type:

```text
int
```

Range:

```text
0 <= policy_points <= policy_cap
```

#### 3.2 Future Storage Location Candidates
Code-read note for v0.70-91:
- WorldMap save stores `_player_state` under `player_state`.
- Load starts from `_get_default_player_state()` and overlays saved `player_state` keys.
- National resources currently read from `_player_state["resource_stock"]` in several UI/helper paths.

Candidate locations:

```text
player_nation["policy_points"]
national_state["policy_points"]
player_state["policy_points"]
court_state["policy_points"]
player_state["resource_stock"]["policy_points"]
player_state["domestic_resource_state"]["policy_points"]
```

Judgment criteria:
- Must match the national/player-state owner.
- Must not make policy look like a warehouse/trade good unless that is intentionally designed.
- Must be stable under save/load and easy for the left national panel to read.
- Must not require enemy policy state in the first PLAYER-only implementation.

Draft recommendation:
- Store policy in PLAYER national/player state first, either as a root-level key or in a dedicated domestic/court resource bucket.
- Avoid `resource_stock` unless the implementation deliberately wants policy to share resource formatting and storage helper paths.
- Enemy policy state is not part of the first implementation, but naming should remain general enough for later AI nation expansion.

#### 3.3 Initial Value Draft
Preferred initial value:

```text
policy_points_initial = min(policy_cap, floor(policy_cap * 0.4))
```

Simple MVP fallback:

```text
policy_points_initial = 20
```

State candidates:

```text
weak state: 15~25
normal state: 30~50
centralized state: 60~90
advanced bureaucracy: 80~120
```

Principles:
- First F6 testing should allow one Tier 1 national research when the rest of the costs are affordable.
- Policy should be a slower strategic bottleneck than gold.
- Too much initial policy makes national research feel like unlimited clicking.

#### 3.4 Cap Draft
Simple future MVP candidate:

```text
policy_cap = 100 + completed_policy_tech_count * 20
```

Fallback when related values are unavailable:

```text
policy_cap = 100
```

State candidates:

```text
weak state: 60
normal state: 100
centralized state: 160
advanced bureaucracy: 240
```

Cap principles:
- Centralization, bureaucracy, and law reform techs may later increase cap.
- A stronger court should be able to prepare larger reforms.
- Cap should not be so low that mid/late national research feels blocked without planning value.

#### 3.5 Migration Draft
If an old save has no `policy_points`:

```text
policy_points = policy_points_initial
```

If an old save has no valid cap value:

```text
policy_cap = default_policy_cap
```

Migration principles:
- Old saves must not break.
- Missing key means default initialization, not error.
- Support PLAYER national state first.
- Enemy policy state is deferred to later AI/nation expansion.
- Values must be clamped after migration.
- v0.70-91 does not implement migration.

#### 3.6 Save/Load Validation Draft
Future implementation checks:

```text
if policy_points missing:
    initialize
if policy_points < 0:
    clamp to 0
if policy_points > policy_cap:
    clamp to policy_cap
if policy_cap missing or invalid:
    use default cap
```

### 4. Schema Version / Migration Policy Draft
Code-read note for v0.70-91:
- `_serialize_worldmap_state()` writes a `version` string and stores `player_state`, `worldmap_city_state`, `worldmap_hero_state`, and `city_policy_state`.
- `_apply_worldmap_state()` overlays saved `player_state` onto `_get_default_player_state()` and then applies city/hero/city-policy runtime state.
- City save/load has explicit handling for selected known fields; new city root fields are not automatically serialized unless the serializer is extended in a future implementation.
- No labor/policy migration was added in v0.70-91.

Draft principles:
- Save schema changes must happen in a separate implementation version.
- Prefer `v0.70-92 Labor Policy Save Schema MVP` as a separate task instead of bundling schema changes into generation.
- Old saves missing keys must receive defaults.
- Default initialization must live in one clear place: load/migration or state initialization, not both.
- Migration must be idempotent and clamp values.
- Implementation must update serialization/load points deliberately if city root or dedicated city buckets are selected.

### 5. Generation State Storage Decision

#### Option A. Store Current Value Only
Stored:

```text
labor_pool
policy_points
```

Not stored:

```text
last_labor_gain
last_policy_gain
```

Pros:
- Simple save schema.
- Smaller compatibility surface.
- Turn gain can be recalculated when needed.

#### Option B. Store Current Value and Last Gain
Stored:

```text
labor_pool
last_labor_gain
policy_points
last_policy_gain
```

Pros:
- Easier tooltip support for previous-turn gain.

Cons:
- Larger schema.
- More QA surface.

v0.70-91 recommendation:
- MVP stores current value only: `labor_pool` and `policy_points`.
- Last gain should be calculated by helper/UI later, or introduced in a dedicated tooltip task.
- Cap may be calculated rather than stored.
- If cap calculation proves unstable, cap can remain a separate stored-key candidate in the save schema implementation task.

### 6. Actual Charge Connection Policy
v0.70-91 does not connect labor/policy to actual charge.

Future city research cost structure:

```text
gold + food group + labor_pool
```

Future national research cost structure:

```text
gold + policy_points
```

Future hybrid military/logistics national research structure:

```text
gold + food group + policy_points
```

Timing rules:
- Deduct once at research start.
- No per-turn charge.
- No completion charge.
- No cancel/refund.
- No retroactive charge.
- No paid state.
- No active research payload schema change.

Shortage rules:
- Validate before active research creation.
- If resources are insufficient, do not deduct anything.
- If resources are insufficient, do not create active research.
- Future shortage copy may use:

```text
부족: 금 N / 군량 N / 노역 N / 정책 N
```

### 7. UI Display and Save Schema Relationship
v0.70-91 does not change UI behavior.

Future UI direction:
- City detail/right panel may show city `labor_pool`.
- Left national panel may show national `policy_points`.
- Research cost UI should include labor/policy only after they become actual charge resources.
- Before actual charge implementation, any labor/policy display must be clearly marked as planned/reference cost, not `시작 시 차감`.

### 8. Summary Helper Policy
No summary helper was changed in v0.70-91.

If a later documentation-alignment pass needs side-effect-free flags, allowed values are:
- `labor_policy_save_schema_draft = true`
- `labor_future_key = "labor_pool"`
- `policy_future_key = "policy_points"`
- `labor_future_owner = "city_state"`
- `policy_future_owner = "player_national_state"`
- `labor_schema_implemented = false`
- `policy_schema_implemented = false`
- `save_load_schema_changed = false`
- `migration_implemented = false`
- `generation_implemented = false`
- `actual_charge_scope_changed = false`
- `ui_behavior_changed = false`

### 9. Strict Preservation Locks
Do not change under v0.70-91:
- actual charge gameplay logic.
- gold deduction.
- food group deduction.
- food group order `rice -> barley -> seafood`.
- affordability validation logic.
- active research creation logic.
- active research payload schema.
- save/load schema.
- migration code.
- real persistent key addition.
- paid cost state.
- cancel/refund.
- per-turn charge.
- completion charge.
- retroactive charge.
- cost/duration/effect balance values.
- UI behavior.
- BattleContext.
- pending invasion schema.
- battle formula.
- diplomacy formula.
- spy formula.
- market/trade formula.
- city_intel formula.
- enemy research/effect.
- assets/icons/UI64/import files.
- scene files.

## v0.70-90 Labor Policy Resource Loop Design

### 1. v0.70-90 Conclusion
- Labor is designed as a city-scoped resource.
- Policy is designed as a nation-scoped resource.
- Labor and policy are not just cost labels; they should become strategic resources generated each turn and accumulated over time.
- Labor resource type: `city-only accumulated resource with cap`.
- Policy resource type: `national-only accumulated resource with cap`.
- Recommended future keys:
  - city labor: `labor_pool`
  - national policy: `policy_points`
- v0.70-90 does not add real persistent keys.
- v0.70-90 does not change save/load schema.
- v0.70-90 does not implement labor/policy generation.
- v0.70-90 does not implement labor/policy actual charge.
- Current actual charge target remains `gold + food group`.
- City tech food group deduction order remains `rice -> barley -> seafood`.
- Labor/policy actual charge must wait for generation loop, save schema, UI, and F6 QA readiness in a separate version.

### 2. Labor Resource Loop Design

#### 2.1 Scope
- owner: selected PLAYER city.
- storage: future city state.
- recommended key: `labor_pool`.
- type: accumulated resource with cap.
- MVP status:
  - design only.
  - no actual generation.
  - no actual charge.
  - no save schema change.

#### 2.2 Labor Gain Model
Labor represents local work capacity, mobilization capacity, and available manpower.

Recommended formula draft:

```text
labor_gain_per_turn =
  base_city_labor
  + population_factor
  + public_order_factor
  + development_factor
  + facility_factor
  + domestic_tech_bonus
  - unrest_penalty
  - war_damage_penalty
```

Factor meaning:
- `base_city_labor`: minimum labor every city can generate.
- `population_factor`: larger population increases labor.
- `public_order_factor`: higher public order, loyalty, or popular support improves mobilization efficiency.
- `development_factor`: agriculture, commerce, ports, roads, and administration can increase labor.
- `facility_factor`: offices, markets, barracks, shipyards, and workshops can increase labor.
- `domestic_tech_bonus`: bureaucracy, local administration, logistics, and irrigation techs can increase labor generation.
- `unrest_penalty`: rebellion, chaos, and low public support reduce labor.
- `war_damage_penalty`: looting, siege damage, and war damage reduce labor.

#### 2.3 Initial Labor Formula Candidates
Future MVP candidate if population and public order are stable:

```text
labor_gain = 5 + floor(population / 10000) + floor(public_order / 20) + development_bonus
```

Fallback candidate if population/public order are not stable:

```text
labor_gain = 8 + city_tier_bonus + domestic_tech_bonus
```

v0.70-90 documents formulas only. Do not apply them in code under this version.

#### 2.4 Labor Cap
Labor accumulates, but it must not accumulate without limit.

Recommended cap formula:

```text
labor_cap =
  base_labor_cap
  + population_cap_bonus
  + development_cap_bonus
  + facility_cap_bonus
  + domestic_tech_cap_bonus
```

Initial cap ranges:
- small city: 30-50.
- medium city: 60-100.
- large city: 120-180.
- capital / major city: 180-250.

Future MVP simplified candidate:

```text
labor_cap = 50 + city_tier * 40
```

#### 2.5 Labor Uses
Use labor mainly for city-scoped actions:
- city research
- construction
- repair
- wall upgrade
- moat / tower / gate reinforcement
- shipyard upgrade
- barracks upgrade
- logistics project
- local production boost
- emergency repair / disaster recovery

Do not use labor as the primary cost for:
- national research
- diplomacy
- national law reform
- court policy
- spy action

#### 2.6 Meaning of Labor Shortage
Labor shortage does not mean "not enough money". It means the city does not currently have enough local work capacity to perform the project.

Gameplay/UI meaning:
- wall reinforcement slows or cannot start.
- shipyard expansion slows or cannot start.
- barracks/workshop/irrigation projects may be blocked.
- city research may be blocked.
- large city projects require saving labor.

### 3. Policy Resource Loop Design

#### 3.1 Scope
- owner: PLAYER nation.
- storage: future national/player state.
- recommended key: `policy_points`.
- type: accumulated resource with cap.
- MVP status:
  - design only.
  - no actual generation.
  - no actual charge.
  - no save schema change.

#### 3.2 Policy Gain Model
Policy represents national administrative power, coordination capacity, and reform momentum.

Recommended formula draft:

```text
policy_gain_per_turn =
  base_policy
  + capital_admin_factor
  + ruler_politics_factor
  + chancellor_politics_factor
  + bureaucracy_factor
  + stability_factor
  + domestic_tech_bonus
  - corruption_penalty
  - unrest_penalty
  - overextension_penalty
```

Factor meaning:
- `base_policy`: minimum policy every nation can generate.
- `capital_admin_factor`: stronger capital administration increases policy.
- `ruler_politics_factor`: higher ruler politics increases policy.
- `chancellor_politics_factor`: higher chancellor politics increases policy.
- `bureaucracy_factor`: bureaucracy, legal reform, and centralization improve policy generation.
- `stability_factor`: national stability, public support, and court control improve policy generation.
- `domestic_tech_bonus`: centralization, tax reform, bureaucracy, and legal techs can add policy.
- `corruption_penalty`: high corruption reduces policy.
- `unrest_penalty`: rebellion, civil war, or instability reduces policy.
- `overextension_penalty`: many cities without sufficient administration reduce policy efficiency.

#### 3.3 Initial Policy Formula Candidates
Future MVP candidate if capital administration and character politics are stable:

```text
policy_gain = 3 + floor(capital_admin / 20) + floor(ruler_politics / 25) + floor(chancellor_politics / 25) + tech_bonus
```

Fallback candidate if ruler/chancellor/admin values are not stable:

```text
policy_gain = 5 + national_policy_tech_bonus
```

v0.70-90 documents formulas only. Do not apply them in code under this version.

#### 3.4 Policy Cap
Policy accumulates, but it must have a cap.

Recommended cap formula:

```text
policy_cap =
  base_policy_cap
  + capital_admin_cap_bonus
  + bureaucracy_cap_bonus
  + centralization_bonus
  + domestic_tech_cap_bonus
```

Initial cap ranges:
- weak state: 30-50.
- normal state: 60-100.
- centralized state: 120-180.
- advanced bureaucracy: 200-300.

Future MVP simplified candidate:

```text
policy_cap = 60 + national_admin_tier * 50
```

Fallback if admin tier is not stable:

```text
policy_cap = 100 + completed_policy_tech_count * 20
```

#### 3.5 Policy Uses
Use policy for nation-scoped actions:
- national research
- law reform
- tax reform
- centralization
- bureaucracy reform
- conscription reform
- diplomacy system
- tribute system
- spy organization system
- national decree
- emergency national policy

Do not use policy as the primary cost for:
- city construction
- wall repair
- shipyard/barracks local upgrade
- local city research primary labor cost

#### 3.6 Meaning of Policy Shortage
Policy shortage means the court lacks administrative or political capacity to push a reform.

Gameplay/UI meaning:
- legal reform, centralization, and tax reform cannot be clicked indefinitely.
- diplomacy and spy organization reforms may require saving policy.
- national management gains an administrative bottleneck.
- ruler, chancellor, and bureaucracy quality become meaningful.

### 4. Accumulated Resource vs Turn Capacity

#### Option A. Accumulated with cap
- Generated each turn.
- Stored up to a cap.
- Supports saving for larger research.
- Creates resource shortage, choice, and long-term planning.
- Easy for UI to explain.
- Recommended.

#### Option B. Per-turn capacity
- Generated each turn and disappears if unused.
- Behaves like action points.
- Has lower storage burden, but makes large research costs harder to express.
- Can feel confusing if users wonder why unused points disappeared.
- Not recommended for current SamWar Domestic Tech.

Conclusion:
- Labor and policy are both designed as `accumulated resource with cap`.

### 5. Research Cost Connection Principles

#### City Research
Recommended future city research cost structure:

```text
gold + food group + labor
```

- `gold`: general economic cost.
- `food group`: supply/food cost.
- `labor`: selected city's work capacity.
- `policy`: normally not used for city research; can be an exception only for special city administration/office research.

#### National Research
Recommended future national research cost structure:

```text
gold + policy
```

- `gold`: general national cost.
- `policy`: institutional, administrative, diplomatic, and military reform momentum.
- `food group`: optional for military/logistics/conscription national research.
- `labor`: do not use for national research.

#### Military / Logistics Hybrid
Allowed future hybrid structure:

```text
gold + food group + policy
```

Possible uses:
- conscription system
- logistics system
- expedition system
- military reform
- standing army

#### City Defense / Construction Hybrid
Allowed future hybrid structure:

```text
gold + food group + labor
```

Possible uses:
- wall reinforcement
- moat
- double moat
- watchtower
- iron gate
- iron fortress
- shipyard
- barracks
- siege-equipment city projects

### 6. UI Direction
Current MVP:
- Actual charge:
  - `금`
  - `군량`
- Labor/policy:
  - display-only planned cost or design candidate.
- v0.70-90 does not change UI behavior.

After future implementation, labor/policy may be included in the official cost line.

Recommended future copy:

```text
필요 비용: 금 120 / 군량 20 / 노역 8 · 시작 시 차감
```

```text
필요 비용: 금 300 / 정책 12 · 시작 시 차감
```

```text
필요 비용: 금 450 / 군량 80 / 정책 18 · 시작 시 차감
```

Shortage copy candidate:

```text
부족: 금 N / 군량 N / 노역 N / 정책 N
```

Do not change UI in v0.70-90.

### 7. Save/Load Follow-up Requirements
v0.70-90 does not change save/load schema.

Future `Labor Policy Save Schema Draft` must decide:

#### city labor
- key: `labor_pool`.
- location: city state.
- initial value: based on city size/tier.
- cap: based on city size/tier/development.
- turn gain: based on city population/order/development.
- migration: create default when old saves do not have the key.

#### national policy
- key: `policy_points`.
- location: national/player state.
- initial value: based on government baseline.
- cap: based on admin tech/centralization.
- turn gain: based on capital admin/ruler/chancellor/bureaucracy.
- migration: create default when old saves do not have the key.

### 8. Follow-up Roadmap
1. `v0.70-91 Labor Policy Save Schema Draft`
   - design persistent keys, initial values, caps, migration, and old-save compatibility.
2. `v0.70-92 Labor Policy Generation MVP`
   - implement only per-turn generation for labor/policy.
   - do not connect them to research charge yet.
3. `v0.70-93 Labor Policy UI Display MVP`
   - show labor in the city panel.
   - show policy in the national panel.
4. `v0.70-94 Labor Policy Actual Charge MVP`
   - connect labor/policy to start-time research actual charge.
5. `v0.70-95 Labor Policy F6 QA Record`
   - record generation, charge, shortage, and preservation QA.

### 9. Summary Helper Policy
If a later task updates a Domestic Tech design summary helper, the only allowed v0.70-90 style flags are side-effect-free dictionary fields such as:
- `labor_policy_resource_loop_design = true`
- `labor_resource_type = "city_accumulated_with_cap"`
- `policy_resource_type = "national_accumulated_with_cap"`
- `labor_generation_implemented = false`
- `policy_generation_implemented = false`
- `labor_actual_charge_implemented = false`
- `policy_actual_charge_implemented = false`
- `labor_recommended_key = "labor_pool"`
- `policy_recommended_key = "policy_points"`
- `labor_loop_owner = "city"`
- `policy_loop_owner = "nation"`
- `save_schema_changed = false`
- `ui_behavior_changed = false`
- `actual_charge_scope_changed = false`

v0.70-90 does not require a runtime helper update.

### 10. Strict Preservation Locks
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
