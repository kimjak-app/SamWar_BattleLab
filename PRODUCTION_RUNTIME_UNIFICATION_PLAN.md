# Production Runtime Unification Plan

Status: Active
Repository: `kimjak-app/SamWar_BattleLab`
Branch: `refactor/production-runtime-unification-20260919`
Plan revision: `PRU-20260919-1`

## 1. Goal

End the current split between QA/test composition scenes and the actual game entry scenes.

Target player-facing runtime:

```text
WorldMap.tscn
    ↓
scenes/battle/Battle_Main.tscn
```

The player should not need to know which test scene contains the newest accepted presentation.

## 2. Current duplication

WorldMap:

- `WorldMap.tscn` is the production logic scene.
- `WorldMap_16x9_Test.tscn` instances `WorldMap.tscn` and adds the newer accepted 16:9 presentation stack.
- Recent visual/UI work has therefore been validated mostly through the test host rather than the canonical scene.

Battle:

- WorldMap currently routes to `res://Battle_Land.tscn`.
- `scenes/battle/Battle_Main.tscn` exists as the canonical production boundary.
- The latest accepted isometric presentation still lives in `tests/scenes/Battle_UI_Production_Imjin_IsoMovement_Test.tscn`.

## 3. P-1 sequence

### P-1A | WorldMap 16:9 Production Promotion Audit

Inventory every extra responsibility added by `WorldMap_16x9_Test.tscn`.

Classify each as:

- promote nearly as-is;
- promote behavior but rewrite into a production owner;
- fold into the production scene/theme;
- QA/editor-only;
- temporary compatibility guard to remove.

No gameplay behavior change in P-1A.

### P-1B | WorldMap Canonicalization

Make `WorldMap.tscn` itself render and behave like the accepted 16:9 runtime.

Requirements:

- accepted Design-2 background;
- approved 13-city placement and route geometry;
- 16:9 camera baseline;
- accepted compact side HUD;
- production top navigation;
- turn-end compass;
- contextual city action menu;
- territory overlay;
- action presentation;
- accepted summary/speech/help presentation;
- no dependency on the `WorldMap_16x9_Test` wrapper for player-facing behavior.

Do not switch battle entry during P-1B.

### P-1C | ISO Battle Production Promotion

Promote accepted generic isometric presentation from the current ISO QA hierarchy into production battle ownership.

Requirements:

- `Battle_Main.tscn` is the actual generic battle scene;
- Imjin-specific fixture data stays under tests;
- generic ISO projection, overlays, HUD and interaction are production-owned;
- logical battle behavior remains unchanged.

### P-1D | Canonical Entry Switch

After parity checks:

```text
WorldMap.tscn
    ↓
scenes/battle/Battle_Main.tscn
```

Replace the current WorldMap route to `Battle_Land.tscn`.

## 4. Safety rules

- Do not copy test wrappers wholesale into production.
- Temporary mirror/visibility guard controllers must not become permanent production architecture.
- Keep `worldmap_main.gd` as the strategic/gameplay source of truth while presentation ownership is promoted.
- Do not change battle formulas, AI decisions, turn order, settlement semantics, or persistence schema during P-1.
- Keep `WorldMap_16x9_Test.tscn` and ISO test scenes as QA parity consumers until production promotion is verified.

## 5. Current status

- B-1G manual runtime verification passed on 2026-09-19.
- B-1H is paused.
- P-1A audit completed at `ff8207439fd95dec3ee9eef80d30fad41432b8cd`.
- P-1B-1 visual baseline promotion is implemented on the active branch.
- Repository-state verification confirms the accepted Design-2 background, 2048×1152 geometry, 13 approved city positions, label offsets, route refresh contract, and production camera bounds.
- P-1B-1 persisted-scene hotfix now makes `WorldMap.tscn` itself reference Design-2 AtlasTextures and updated route baselines. It is waiting for a fresh Godot editor/runtime parity check after reloading the scene/project.
- Do not begin P-1B-2 until that direct Production WorldMap visual check is satisfactory.
