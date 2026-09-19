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

- Before P-1D, WorldMap routed to legacy `res://Battle_Land.tscn`.
- `scenes/battle/Battle_Main.tscn` is the canonical production battle boundary.
- The accepted isometric presentation has been promoted into production ownership; test scenes remain QA consumers.

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

Status: **IMPLEMENTED — awaiting real WorldMap roundtrip QA.**

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
- P-1B-1 direct Production WorldMap visual check passed after the branch mismatch was corrected.
- P-1B-2 production compact HUD promotion passed user visual QA on 2026-09-19.
- P-1B-3 production interaction/presentation promotion passed user visual QA on 2026-09-19.
- P-1B-4 territory overlay + final compact HUD authority is implemented and awaiting Godot runtime visual QA.
- Do not begin P-1B-5 cleanup until territory colors and compact left/right information surfaces remain correct through city selection and at least one turn transition.


## 6. 16:9 parity lock — 2026-09-19

P-1B now uses a strict functional-parity rule:

**Every player-facing runtime behavior proven in `WorldMap_16x9_Test.tscn` must be reproduced in canonical `WorldMap.tscn` before P-1B closes.**

QA scaffolding may be replaced by cleaner production ownership, but the resulting behavior must remain equivalent.

Intentional exception:

- `worldmap_tech_badge_test_controller.gd` sample badges are NOT promoted.
- Production `WorldMapTechBadgeSummaryController` displays only real completed national/city technologies using real catalog definitions and resolved icon paths.
- Tech badge summaries refresh immediately after completed-tech progression/normalization and on city selection.

Current runtime QA gate before P-1B-5:

1. territory colors render;
2. one full turn shows the turn-summary popup;
3. no legacy left-panel turn log flashes around the tech section;
4. chancellor appointment speech appears;
5. chancellor policy speech appears;
6. governor appointment speech appears;
7. governor policy speech appears;
8. real completed national tech icon appears;
9. real completed selected-city tech icon appears;
10. contextual spy/diplomacy/trade video/result flow remains functional;
11. compact HUD remains stable through the above transitions.

Static parity matrix:
`agent/P1B_16X9_FUNCTIONAL_PARITY_MATRIX_20260919.md`

Static parity validator:
`tools/validate_p1b_16x9_functional_parity.py`


## 7. P-1C ISO Battle Production Promotion — 2026-09-19

P-1C-1 audit completed:
`agent/P1C1_ISO_BATTLE_PRODUCTION_PROMOTION_AUDIT_20260919.md`

P-1C implementation completed:
`agent/P1C_ISO_BATTLE_PRODUCTION_PROMOTION_20260919.md`

Current state:
- `Battle_Main.tscn` now instances `Battle_Production.tscn`.
- latest Production HUD is outside `tests/`;
- ISO projection/presentation is production-owned;
- generic post-skill reposition behavior is production-owned;
- Imjin-specific roster/nation/portrait fixtures remain under tests;
- Production supply HUD is bound to real `BattleSupplyRuntime`, not mock data;
- Direct Godot QA on `scenes/battle/Battle_Main.tscn` passed on 2026-09-19.
- P-1D canonical entry switch is implemented: `WorldMap.tscn -> scenes/battle/Battle_Main.tscn`.
- Legacy `res://Battle_Land.tscn` remains for comparison/recovery only; WorldMap no longer routes to it.

Next action:
**Run real end-to-end Godot QA through `WorldMap -> Battle_Main`, confirm BattleContext-backed roster/troops/supply, then return to WorldMap and verify settlement.**
