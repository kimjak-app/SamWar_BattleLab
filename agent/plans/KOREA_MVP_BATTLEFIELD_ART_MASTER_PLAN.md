# Korea MVP Battlefield Art Master Plan

## Purpose

This document locks the visual-production plan for the four Korea MVP battlefields while preserving a clean handoff to the later T09 terrain and tactical-map system.

The battlefield image is not a decorative wallpaper. It is the visible layer of a playable tactical space and must be composed around unit readability, UI safe zones, attacker/defender roles, future passability, and choke-point design.

## Locked Battlefield Set

1. Hanseong
2. Sabi
3. Gyeongju
4. Pyongyang

Hanseong is produced and approved first. It becomes the master template for camera, framing, visual scale, UI safe zones, unit readability, castle/camp hierarchy, and later terrain-data authoring.

The remaining three battlefields are not produced until Hanseong passes visual and in-game F5 QA.

## Resolution and File Contract

- Master source: `3840 × 2160`, 16:9.
- Runtime derivative: `1920 × 1080`, 16:9.
- The 4K master remains the long-term source for future 2K/4K display support and promotional capture.
- Runtime images must be optimized for Godot without destroying visible detail.
- Text, turn values, momentum values, unit names, and gameplay markers must not be baked into battlefield art.

Recommended repository direction:

```text
assets/web_battle/battlefield/korea_mvp/
├─ hanseong/
│  ├─ hanseong_battlefield_master_4k.png
│  ├─ hanseong_battlefield_runtime_1080p.png
│  └─ hanseong_battlefield_preview.jpg
├─ sabi/
├─ gyeongju/
└─ pyongyang/
```

The exact binary format and compression are confirmed during asset integration. The repository must not keep unnecessary duplicate exports.

## Attacker and Defender Role Contract

The battlefield is organized by battle role, not by player/AI identity.

- Defender side: city, fortress, gate, wall, defensive earthworks, or city approach appropriate to the battlefield.
- Attacker side: temporary military camp, command tent, banners, supply carts, palisade, fires, and field staging ground.

This remains true regardless of whether the player is attacking or defending.

The scene/runtime must map:

- player attacker → player units near the temporary camp and enemy units near the city/fortress.
- player defender → player units near the city/fortress and enemy units near the temporary camp.

The art and UI must never hardcode `ally = camp` or `enemy = castle`.

## Hanseong Master Battlefield

### Visual identity

- Broad capital approach and open plain.
- Strong city-wall and gate silhouette on the defender edge.
- Clear main road leading toward the gate.
- Agricultural fields, low vegetation, sparse tree groups, and shallow terrain variation.
- Temporary attacker camp on the opposite edge.
- Strong separation between tactical play area and decorative distant scenery.

### Tactical composition goals

- One readable main approach to the gate.
- At least one meaningful alternate approach.
- Natural obstacles that create route choices without making the map visually cramped.
- Potential choke points near bridge, gate, narrow road, wall approach, or field boundary.
- Clear deployment areas for both roles.
- Enough open area for cavalry and ranged-unit readability.
- Obstacle silhouettes must align with later passability cells.

### Approval gate

Hanseong passes only when:

- the 4K master is visually approved;
- the 1080p derivative remains clean;
- units remain readable over the art;
- UI does not hide the castle, camp, active units, or primary route;
- player-attacker and player-defender tests both read correctly;
- future traversable and impassable regions can be mapped without contradicting the painting.

## Sabi Battlefield Direction

- River-influenced capital approach.
- Low hills and riverside defensive structures.
- A visible crossing, bridge, ford, embankment, or constrained route that can later become a tactical choke point.
- Softer terrain and warmer river-basin atmosphere than Hanseong.
- Defender fortress/city remains the visual anchor; attacker camp remains on the opposite role edge.

## Gyeongju Battlefield Direction

- Forest bands, low mountains, rolling ground, and open interior fields.
- Silla-influenced fortress silhouette without relying on text labels.
- Multiple routes with one wider open route and one narrower wooded route.
- Strong visual distinction between forest, rough ground, road, and open field for later terrain mapping.

## Pyongyang Battlefield Direction

- Rugged northern terrain, steep slopes, cliffs, rocky ridges, and fortified approaches.
- Mountain-fortress or strong gate silhouette.
- Narrow passages and height contrast create a naturally defensive visual identity.
- Impassable cliffs and passable mountain routes must be visibly distinct.
- Open deployment pockets remain large enough for readable unit placement.

## Art and Gameplay Layer Separation

Every battlefield has at least two conceptual layers.

### Visible art layer

- Painted or rendered 4K battlefield.
- Castle/city, attacker camp, roads, rivers, vegetation, cliffs, walls, fields, and atmosphere.
- Visual depth and regional identity.

### Tactical metadata layer

Implemented during T09:

- terrain ID;
- traversable state;
- conditional traversability;
- impassable state;
- movement cost;
- unit-type restrictions;
- defense/attack/range modifiers;
- bridge, gate, wall, cliff, and choke-point semantics;
- deployment zones;
- pathfinding data;
- save/resume representation where required.

The visible painting never becomes the authoritative gameplay rule by pixel sampling.

## Visual Passability Language

Even before T09 mechanics are implemented, the art must communicate likely movement rules.

### Clearly traversable visual forms

- road;
- open plain;
- field path;
- bridge deck;
- gate opening;
- sparse forest path;
- broad shallow terrain.

### Clearly costly or conditional visual forms

- dense forest;
- rocky slope;
- marsh edge;
- shallow ford;
- steep but usable mountain path;
- damaged ground or rubble.

### Clearly impassable visual forms

- city wall;
- sheer cliff;
- deep river section;
- giant rock formation;
- sealed structure;
- map boundary masked by natural scenery.

Art must avoid ambiguous obstacles that look passable but are planned as blocked, or look blocked but are planned as normal ground.

## UI Safe-Zone Contract

The battlefield master must be composed with the T08 production UI overlay in mind.

- Top-center: turn and ally/enemy momentum HUD.
- Left edge: ally roster.
- Right edge: enemy roster.
- Bottom: current actor / next AI or selected target HUD and global commands.
- Lower corner: compact battle log or auxiliary panel.

Key landmarks and primary tactical routes must remain visible after these overlays are applied.

The safe zones are guides, not empty black margins. Background scenery may continue behind UI, but critical gameplay silhouettes may not be hidden there.

## Camera and Grid Compatibility

- All four battlefields use one production camera and one approved battlefield framing system.
- The battlefield art must not require a different UI layout per city.
- Grid and passability data are separate from the raster image.
- T08 does not change the authoritative battle grid or pathfinding rules merely to fit an image.
- T09 may revise grid metadata after audit, but the Hanseong art should support the existing 1920×1080 battle framing without forcing a scene rewrite.

## Asset Production Workflow

1. Audit the current battlefield texture, camera, unit deployment areas, and UI coverage.
2. Produce a Hanseong low-detail composition draft.
3. Verify castle/camp role positions, tactical routes, safe zones, and unit scale.
4. Produce the 4K Hanseong master.
5. Export the 1080p runtime derivative.
6. Integrate into Godot without terrain mechanics.
7. Run player-attacker and player-defender F5 QA.
8. Lock Hanseong as the reusable battlefield template.
9. Produce Sabi, Gyeongju, and Pyongyang using the same framing and technical contract.

## Quality Risks and Controls

### Risk: beautiful but unplayable painting

Control: approve composition and passability language before final detail work.

### Risk: UI hides landmarks or units

Control: use the final T08 HUD safe-zone overlay during composition review.

### Risk: castle/camp tied to ally/enemy instead of role

Control: test both player attack and player defense contexts before approval.

### Risk: T09 terrain cells contradict visible art

Control: create a terrain design mask/authoring reference from the approved master before T09 implementation.

### Risk: 4K asset causes runtime or repository bloat

Control: retain one true master and one optimized runtime derivative; do not commit redundant near-identical exports.

## Completion Definition

The battlefield-art stage is complete when:

- all four 4K masters are approved;
- all four 1080p runtime derivatives are integrated;
- the same UI template works over every battlefield;
- castle/camp role mapping works for player attack and defense;
- units and overlays remain readable;
- each battlefield has a clear T09 terrain-authoring reference;
- no terrain gameplay is faked or inferred directly from the image.