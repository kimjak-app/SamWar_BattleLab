# MVP 3 Main 2 Reinforce Layout Plan

## Scope
- Step: `v0.67g MVP 3 Main + 2 Reinforce Layout Plan`
- This step is documentation only.
- No scene change.
- No script change.
- No slot-node creation.
- No unit creation.

## 1. MVP Battle Slot Goal

MVP target per side:
- ally main `3`
- ally reinforce `2`
- enemy main `3`
- enemy reinforce `2`

Current stable `2v2` mapping:
- `ally_main` -> `ally_main_01`
- `ally_support` -> `ally_main_02`
- `enemy_main` -> `enemy_main_01`
- `enemy_support` -> `enemy_main_02`

MVP additional slot ids to prepare:
- `ally_main_03`
- `ally_reinforce_01`
- `ally_reinforce_02`
- `enemy_main_03`
- `enemy_reinforce_01`
- `enemy_reinforce_02`

Interpretation:
- Current stable `2v2` remains the first `2` main slots per side.
- MVP expands the authored layout concept to `3` main + `2` reinforce without changing runtime battle behavior in this step.

## 2. Main Slot Layout Concept

Main-slot principle:
- `main_01` through `main_03` are deployed at battle start.
- They are the baseline front-line battle participants.

Recommended role concept:
- `main_01`: center main force
- `main_02`: supporting main force
- `main_03`: rear-line or flank support force

Ally-side layout direction:
- lower battle side
- keep `ally_main_01` and `ally_main_02` as close as possible to the current stable `2v2` positions
- place `ally_main_03` as:
  - between them but slightly rearward
  - or on a controlled flank reinforcement lane that still reads as battle-start deployed

Enemy-side layout direction:
- upper battle side
- keep `enemy_main_01` and `enemy_main_02` as close as possible to the current stable `2v2` positions
- place `enemy_main_03` as:
  - between them but slightly rearward
  - or on a controlled flank support lane

Priority rule:
- preserve the current `2v2` authored feel first
- add `main_03` in a way that does not force large positional changes to the current stable slots

## 3. Reinforce Slot Layout Concept

Reinforce-slot principle:
- `reinforce_01` through `reinforce_02` are not deployed at battle start by default
- delayed or triggered entry is the expected use

Baseline policy:
- `is_active=true` is allowed
- `is_deployed=false` at battle start is allowed
- excluded from actor candidates
- excluded from target candidates
- excluded from occupied-cell blocking
- excluded from click-target participation when not deployed

Entry-lane concept:
- ally reinforce:
  - rear approach
  - castle-side approach
  - controlled flank entry
- enemy reinforce:
  - rear approach
  - fortress-side approach
  - controlled flank entry

Recommended MVP entry bias:
- `reinforce_01`: rear-center entry lane
- `reinforce_02`: side-flank entry lane

Design note:
- reinforce positions should read as plausible off-board or edge-entry lanes rather than permanent battle-start crowding points

## 4. Layout Coordinate Policy

Core rule:
- code must not become the final owner of authored battlefield coordinates
- Godot 2D editor remains the primary layout tool
- `Ctrl+S -> F6` iteration flow must stay intact

Layout policy:
- preserve the current stable `2v2` anchors as the reference
- describe position concepts, not fixed pixel commitments
- use scene-authored slot roots and markers later, not hardcoded placement tables

Optional anchor language for later scene work:
- `main_01`: current center/main lane anchor
- `main_02`: current support lane anchor
- `main_03`: rear-middle or outer-side support anchor
- `reinforce_01`: rear-center entry anchor
- `reinforce_02`: flank-entry anchor

## 5. Slot ID Policy

MVP slot ids:

Ally:
- `ally_main_01`
- `ally_main_02`
- `ally_main_03`
- `ally_reinforce_01`
- `ally_reinforce_02`

Enemy:
- `enemy_main_01`
- `enemy_main_02`
- `enemy_main_03`
- `enemy_reinforce_01`
- `enemy_reinforce_02`

Compatibility with final `7 + 3` capacity:
- `main_04` through `main_07` remain later expansion ids
- `reinforce_03` remains later expansion id

Practical interpretation:
- MVP is a readable subset of the final capacity naming plan, not a competing naming scheme

## 6. Scene Tree Expansion Direction

Candidate expansion direction for `v0.67h`:

```text
Slots
  AllyMainSlot
  AllySupportSlot
  EnemyMainSlot
  EnemySupportSlot
  AllyMain03Slot
  AllyReinforce01Slot
  AllyReinforce02Slot
  EnemyMain03Slot
  EnemyReinforce01Slot
  EnemyReinforce02Slot
```

Alternative full-index naming direction:

```text
Slots
  AllyMain01Slot
  AllyMain02Slot
  AllyMain03Slot
  AllyReinforce01Slot
  AllyReinforce02Slot
  EnemyMain01Slot
  EnemyMain02Slot
  EnemyMain03Slot
  EnemyReinforce01Slot
  EnemyReinforce02Slot
```

Naming recommendation:
- keep current legacy scene names for the existing `2v2` slots in the next scaffold step
- add new slot nodes without renaming the current verified nodes first

Reason:
- immediate renaming of `AllyMainSlot` / `AllySupportSlot` / `EnemyMainSlot` / `EnemySupportSlot` raises node-path risk
- path stability is more important than naming perfection in the first MVP scaffold

Recommended safer direction:
- `v0.67h`:
  - keep existing names
  - add new slot nodes
- separate naming migration later if still needed

## 7. UnitVisualSlot / BattleUnitState Expansion Plan

MVP `5`-slot prototype will later need:
- `UnitVisualSlot` registry entries for the new slot ids
- `BattleUnitState` additions for `main_03` and later reinforce states
- `unit_state_by_capacity_slot_id` expansion
- continued active/deployed filter enforcement
- support for non-deployed reinforce state tracking

Implementation rule for this step:
- do not implement any of the above here
- reserve them for staged implementation in `v0.67h` and `v0.67i`

## 8. Auto Battle Expansion Considerations

MVP `5`-slot auto-battle requirements:
- only `deployed=true` units can be actors
- only `deployed=true` units can be targets
- reinforce units remain excluded before deployment
- post-entry behavior needs a rule for whether the unit may act immediately or from the next valid turn cycle
- current auto battle step limit should be reviewed for larger battle counts

TODO:
- define reinforcement entry turn timing
- define acted-state behavior on entry
- review step-limit sufficiency for `5`-slot participation
- verify deterministic target ordering when more than `2` visible targets exist

## 9. Click / READY / Facing Expansion Considerations

If `main_03` and reinforce slots are added later, the following must be reviewed:
- ClickArea additions
- ReadyFrame additions where needed
- FacingIndicator additions
- `BattleUI` overlay strategy remains preferred for READY / Facing
- ClickArea may remain root-level or slot-linked reference based
- physical parenting unification should be treated cautiously

Practical direction:
- world interaction and UI overlay expansion should follow the same safety-first pattern already used for the stable `2v2`

## 10. Relation To Formation Slot Guide Layer

Formation Slot Guide Layer is reserved for `v0.67l`.

This step must not:
- implement the guide layer
- add guide nodes
- add runtime guide drawing

Allowed planning note:
- main `7` + reinforce `3` later need readable authored anchors
- this MVP document should preserve enough slot-position intent to support that future guide work

## 11. Risks

Key risks:
- `5` visible units per side can visually overlap
- HP bar and troop label overlap can increase sharply
- ClickArea overlap can make selection ambiguous
- auto battle may accidentally treat non-deployed reinforce units as valid actors if filtering regresses
- enemy AI may accidentally target non-deployed reinforce units if filtering regresses
- reinforcement entry can collide with occupied-cell rules on arrival
- legacy scene names and capacity slot ids can be confused during transition
- code may start overriding scene-authored coordinates and break editor-first tuning
- scene readability may degrade if `main_03` is placed too close to the current `2v2`
- version-scope drift must be avoided; no `0.68` naming or roadmap should be introduced here

## 12. Recommended Roadmap

Next planned steps:
- `v0.67h MVP 5-Slot Scene Scaffold`
- `v0.67i MVP 5-Slot Battle Prototype`
- `v0.67j Reinforcement Entry Prototype`
- `v0.67k Seven+Three Capacity QA Stable`
- `v0.67l Formation Slot Guide Layer`

## Recommendation

Recommended immediate next step:
- `v0.67h MVP 5-Slot Scene Scaffold`

Reason:
- the current architecture already has slot registry, adapter, and active/deployed filtering groundwork
- the next safe move is scene scaffolding for new slots without enabling new battle participants yet
- this preserves the current stable `2v2` while opening a controlled path to the MVP `3 + 2` layout
