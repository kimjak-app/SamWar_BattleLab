# Scene Slot Tree Migration Plan

## Scope
- Step: `v0.66d Scene Slot Tree Migration Plan`
- This step is documentation only.
- No scene change.
- No script change.
- No node migration.

## 1. Current Structure Summary

Current verified battle-slot structure:

- `AllySide/AllyUnitVisualRoot`
- `AllySide/AllySupportUnitVisualRoot`
- `EnemySide/EnemyUnitVisualRoot`
- `EnemySide/EnemySupportUnitVisualRoot`

Current non-visual attachments:

- ClickArea 4개 are direct children of scene root:
  - `AllyUnitClickArea`
  - `AllySupportUnitClickArea`
  - `EnemyUnitClickArea`
  - `EnemySupportUnitClickArea`
- READY frame 2개 are under `BattleUI`:
  - `AllyReadyFrame`
  - `AllySupportReadyFrame`
- FacingIndicator 4개 are under `BattleUI`:
  - `AllyFacingIndicator`
  - `AllySupportFacingIndicator`
  - `EnemyFacingIndicator`
  - `EnemySupportFacingIndicator`

Current architecture state:

- `UnitVisualSlot` is currently a reference adapter only.
- `slot_id` based lookup is in place.
- slot-backed helper usage is in place for safe lookup / cleanup / visibility paths.
- visual node parent structure is still the pre-C layout.
- current scene tree is not yet organized under a dedicated `Slots` root.

## 2. Target C Structure Definition

Target direction is a slot-centered scene layout around explicit combat slot owners.

Planned C-style structure:

```text
Slots
  AllyMainSlot
    VisualRoot
    ClickArea or ClickAreaRef
    ReadyFrameRef
    FacingIndicatorRef

  AllySupportSlot
    VisualRoot
    ClickArea or ClickAreaRef
    ReadyFrameRef
    FacingIndicatorRef

  EnemyMainSlot
    VisualRoot
    ClickArea or ClickAreaRef
    FacingIndicatorRef

  EnemySupportSlot
    VisualRoot
    ClickArea or ClickAreaRef
    FacingIndicatorRef
```

Important interpretation:

- `VisualRoot` is the cleanest migration target for real battle visuals.
- `ClickArea` may remain a world-space attachment even if it becomes logically slot-owned.
- `ReadyFrame` and `FacingIndicator` should not be forced into a `Node2D` hierarchy if that harms UI coordinate safety.
- For UI nodes, `Ref` ownership is acceptable:
  - slot-linked
  - logically owned
  - not necessarily physical child nodes

## 3. Migration Principles

Mandatory rules:

1. Do not migrate all 4 slots at once.
2. Run a single-slot migration spike first.
3. `ally_main` is the recommended first target.
4. Pre-migration and post-migration battle behavior must be identical.
5. Parent changes must preserve effective world placement.
6. Do not mix `Control` overlay ownership with `Node2D` world-space parenting carelessly.
7. F6 QA is mandatory after each migration step.
8. Rollback must stay simple and low-risk.

Practical rule:

- If a migration step requires multiple special-case fixes across visual, click, and UI nodes at once, the step is too large and should be split.

## 4. Node Classification Policy

### A. Visual Node

Nodes:

- token
- shadow
- portrait
- hp_bar
- troop_label
- move_dust

Migration fit:

- Best fit for `Slot -> VisualRoot`
- These are already closest to slot-root ownership

Risk:

- Medium
- Parent change can still disturb captured offsets and animation offsets if local transforms shift

Recommendation:

- Migrate visual nodes first, slot by slot

### B. World Interaction Node

Nodes:

- `ClickArea`
- `CollisionShape2D`

Migration fit:

- Logical slot ownership is valid
- Immediate physical reparenting is risky

Risk:

- Medium-High
- `to_local()` click tests and collision-shape local offsets are sensitive to parent change

Recommendation:

- Prefer slot reference ownership first
- Treat physical move as a separate spike

### C. UI Overlay Node

Nodes:

- `ReadyFrame`
- `FacingIndicator`

Migration fit:

- Logical slot ownership is valid
- Physical reparenting under world-space slot nodes is poor

Risk:

- High
- `Control` / `CanvasLayer` / world-space coordinate mixing can break position and layering

Recommendation:

- Keep under `BattleUI`
- Use slot-linked overlay references instead of forcing tree unification

## 5. ClickArea Migration Judgment

Based on the earlier audit:

- Current `ClickArea` nodes are scene-root `Area2D`.
- Current click checks depend on world-space coordinates.
- Current hit tests use:
  - `Area2D.to_local(mouse_pos)`
  - `CollisionShape2D.position`
  - shape-specific geometry checks
- Immediate migration is risky.

Recommended conclusion:

- In C structure, treat `ClickArea` as slot-linked first.
- Do not require physical `ClickArea` reparenting in the first migration wave.
- If physical move is tested later, it must be its own spike with dedicated QA.

## 6. ReadyFrame / FacingIndicator Migration Judgment

Based on the earlier audit:

- `ReadyFrame` and `FacingIndicator` live under `BattleUI`.
- Their placement depends on `_world_to_battle_ui_position()`.
- They are overlay UI, not world-space combat visuals.

Recommended conclusion:

- Do not physically move these nodes under `Node2D` slot roots as the default plan.
- Treat them as:
  - slot-owned references
  - slot-linked overlay UI
  - BattleUI-resident controls

Safe interpretation of C structure:

- `ReadyFrameRef` and `FacingIndicatorRef` are sufficient for slot ownership.
- Physical child placement under `Slots/...` is not required for the architecture to count as slot-based.

## 7. Step-by-Step Migration Plan

### v0.66d-1 Documentation

- Current step
- No scene change
- No script change

### v0.66e AllyMainSlot Migration Spike

- Create or validate `Slots` root strategy
- Migrate only `ally_main`
- Test either:
  - visual-root reparent only
  - or slot-reference ownership first
- Preserve current result exactly
- Run full F6 QA

### v0.66f AllySupportSlot Migration

- Apply the proven ally-main strategy to `ally_support`
- Re-check support click / visibility / cleanup behavior carefully

### v0.66g EnemyMainSlot Migration

- Apply the proven strategy to `enemy_main`
- Re-check dead-main behavior and target-selection overlap regression risk

### v0.66h EnemySupportSlot Migration

- Apply the proven strategy to `enemy_support`
- Re-check support targeting after main death

### v0.66i Slot Tree QA Stable

- Full 2v2 F6 QA
- Full auto battle QA
- HP 0 cleanup QA
- Guan Yu death -> Zhang Fei targeting QA

## 8. Preconditions For 3v3 / 4v4 Expansion

Slot-count expansion should not start until these are true:

1. All 4 current slots resolve reliably through `UnitVisualSlot`.
2. `slot_id` based state-to-visual mapping works without relying on fragile direct comparison for core lookup.
3. Cleanup / visibility / click enable / READY / FacingIndicator flows are stable under slot-based helpers.
4. Auto battle actor and target iteration can scale without assuming only 2 ally + 2 enemy units.
5. Scene-authored layout remains editable even after slot ownership becomes more explicit.

## 9. Risk Summary

Major risks:

- parent change breaks local/global coordinates
- `Control` and `Node2D` coordinate systems get mixed incorrectly
- `ClickArea.to_local()` hit tests drift after reparenting
- `ReadyFrame` and `FacingIndicator` placement drifts
- dead main unit cleanup regresses and blocks support clicking
- auto battle loop references dead or moved slot nodes incorrectly
- runtime code starts overriding scene-authored layout excessively

Risk control:

- migrate one slot only
- prefer reference ownership before physical node movement
- verify exact gameplay behavior after every spike

## 10. Migration QA Checklist

After every migration step, verify:

- manual move
- manual attack / counterattack
- auto battle ON/OFF
- auto battle stop
- READY frame
- FacingIndicator
- post-move facing selection
- right-click move cancel
- HP 0 cleanup
- Guan Yu death then Zhang Fei click / attack
- battle dust
- Round Toast
- UnitCloseupPanel
- no error logs

## 11. Recommended Next Steps

- `v0.66e AllyMainSlot Migration Spike`
- `v0.66e-rollback Plan`
- `v0.67 Slot Count Expansion Plan`
- `v0.68 3v3 Prototype`
