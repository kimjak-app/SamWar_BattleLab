# T09 Battlefield Terrain Handoff Plan

## Purpose

This document defines what T08 must prepare for the later T09 Battlefield Terrain & Tactical Map System without implementing terrain behavior early.

T08 creates the production UI and visible battlefield art. T09 creates the authoritative tactical-map data, passability, movement cost, pathfinding, unit-type terrain interaction, combat modifiers, AI usage, persistence, and validation.

## Locked Separation

### T08 owns

- Production battle UI.
- Terrain-information display location and visual frame.
- 4K battlefield master art and 1080p runtime derivatives.
- Visually readable roads, fields, forest, river, bridge, wall, gate, cliff, rough ground, and choke-point candidates.
- UI safe zones.
- Hanseong master-template approval.
- Terrain authoring references or design masks that do not affect gameplay.

### T09 owns

- Authoritative terrain IDs.
- Per-cell terrain data.
- Traversability and impassability.
- Unit-type passability rules.
- Movement cost.
- Pathfinding.
- Occupancy interaction.
- Terrain combat effects.
- Range/line-of-sight rules where explicitly designed.
- AI route and position evaluation.
- Save/resume state.
- Deterministic validators and F5 QA.

A painted river, wall, forest, or cliff has no gameplay effect until T09 data explicitly assigns one.

## Required Terrain State Model

Every tactical cell must resolve to one authoritative terrain record.

Minimum conceptual fields:

```text
terrain_id
traversal_class
base_move_cost
allowed_unit_types
blocked_unit_types
defense_modifier
attack_modifier
range_modifier
height_or_elevation_class
feature_tags
visual_reference
```

The final schema is designed during T09. Fields that are not required by the MVP may be omitted, but the model must not depend on color sampling from the battlefield PNG.

## Traversal Classes

### Traversable

Normal cells that every valid unit may use under ordinary occupancy rules.

Examples:

- plain;
- road;
- open field;
- bridge;
- gate opening.

### Conditionally traversable

Cells whose use depends on unit type, movement budget, status, technology, future ability, or explicit rule.

Examples:

- dense forest;
- rough mountain path;
- shallow water;
- marsh;
- rubble;
- steep slope.

### Impassable

Cells that normal movement and pathfinding may not enter.

Examples:

- city wall;
- sheer cliff;
- deep river;
- giant rock formation;
- sealed structure;
- hard map boundary.

Special-skill exceptions remain future explicit behavior and must never be inferred implicitly.

## Unit-Type Terrain Contract Direction

The canonical five unit types remain:

- infantry;
- cavalry;
- archer;
- gunner;
- mounted_archer.

T09 must design one shared rule source used by player movement, AI movement, pathfinding previews, action validation, logs, and save/resume.

No provisional balance values are locked in T08. The following are design directions only:

- infantry should be the most generally reliable over rough ground;
- cavalry should prefer open ground and roads and be restricted by severe roughness;
- archer and gunner positioning should care about access, protection, and firing lanes;
- mounted archer should preserve mobility identity without ignoring severe terrain;
- bridges and gates should create meaningful choke points;
- occupied cells continue to block normal movement under the current protected rule.

Exact costs and modifiers are deferred to T09 design and later T11 balance.

## Hanseong Terrain Demonstration Requirement

Hanseong becomes the first production tactical-map demonstration.

It must be capable of showing:

- normal traversable ground;
- at least one costly or conditional terrain family;
- at least one clearly impassable terrain family;
- one major choke point;
- one alternate route;
- attacker deployment near a temporary camp;
- defender deployment near the city/fortress;
- role mapping for player attack and player defense.

T08 prepares the visual composition. T09 assigns and validates the data.

## Authoring Reference Contract

For every approved battlefield, create a human-readable terrain authoring reference.

Recommended forms:

- a transparent grid overlay image;
- a numbered-cell reference image;
- a terrain-color design mask used only by authors;
- a structured JSON/resource file once T09 begins.

The authoring reference must align exactly with the runtime battlefield framing and approved camera.

The design mask is not the runtime source of truth unless T09 explicitly adds and validates an import pipeline. Manual or generated data must be converted into explicit structured terrain records.

## UI Handoff Contract

T08 must reserve a terrain-information location capable of showing:

- terrain display name in Korean;
- traversable, costly, conditional, or impassable state;
- movement cost or inability reason;
- relevant unit-type interaction;
- defense/attack/range effect when implemented;
- bridge, gate, wall, forest, river, mountain, or other feature tag;
- route or target preview feedback.

During T08 this area remains hidden or clearly marked as non-interactive. It must not display invented terrain effects.

## Pathfinding and Preview Contract

T09 must ensure these consume the same authoritative rules:

- reachable-cell overlay;
- selected destination validation;
- actual movement resolution;
- AI route selection;
- retreat/approach route where applicable;
- save/resume restoration.

A cell shown as reachable must be reachable by the actual resolver. A cell shown as blocked must not be chosen by AI or accepted by manual movement.

## Art-to-Data Consistency Gate

Before a map is production-ready:

- every wall or cliff planned as impassable matches blocked cells;
- every visible road or bridge planned as usable matches passable cells;
- river crossings match bridge/ford data;
- forest and rough-ground boundaries match the intended cost regions;
- deployment zones do not overlap impassable cells;
- UI panels do not hide the only usable route;
- pathfinding does not cut through painted structures.

## T09 Proposed Transaction Sequence

### T09-1 Terrain and Grid Current-State Audit

- Audit current battle grid, cell coordinates, occupancy, movement preview, pathfinding, snapshot, and AI route logic.
- Lock the authoritative map dimensions and schema.

### T09-2 Terrain Data Contract and Hanseong Authoring Data

- Add explicit terrain records and validators.
- Author Hanseong data against the approved art.

### T09-3 Traversability and Movement Cost

- Connect player preview, movement resolver, occupancy, and AI to the same rules.

### T09-4 Unit-Type Terrain Interaction

- Apply canonical five-unit-type passability and movement-cost behavior.

### T09-5 Terrain Combat and UI Feedback

- Add only the approved combat modifiers.
- Expose Korean terrain information through the T08 UI location.

### T09-6 Persistence, AI, and Full QA

- Save/resume parity.
- Player/AI route parity.
- Choke-point, bridge, gate, and blocked-cell tests.
- Lock Hanseong and prepare replication to the remaining Korea MVP maps.

## T09 Completion Gate

- Player and AI obey identical terrain and movement rules.
- Reachable overlays match actual movement.
- Normal, costly, conditional, and impassable cells are deterministic.
- At least one production battlefield demonstrates a meaningful choke point and alternate route.
- Terrain information is readable through the T08 UI.
- Save/resume preserves all required tactical-map state.
- No terrain behavior is inferred from artwork alone.

## Non-Goals of This Handoff

This document does not lock:

- exact numerical movement costs;
- exact combat modifiers;
- final line-of-sight rules;
- weather;
- destructible terrain;
- siege destruction;
- swimming, flying, or unrestricted pass-through;
- special-skill terrain exceptions;
- final balance.

Those require explicit T09/T11 design and validation.