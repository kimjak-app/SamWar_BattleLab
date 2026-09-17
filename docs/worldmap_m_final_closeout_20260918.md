# WorldMap M-FINAL Closeout — 2026-09-18

## Status

The large WorldMap refactor is closed after M-FINAL-A domain ownership cleanup and M-FINAL-B final hub audit.

The architectural target is now:

- `scripts/worldmap/worldmap_main.gd`: scene-level WorldMap coordinator / wiring hub / cross-domain orchestration.
- Domain Controller / Service / Presentation files: concrete domain behavior, rules, tuning constants, and presentation ownership.
- New features must not accumulate concrete domain logic back into `worldmap_main.gd`; add them to the existing owning Controller/Service or create a dedicated `.gd` when the responsibility is genuinely new.

## M-FINAL-A — Domain ownership

Approved production checkpoint:

`751b6a07d3e66449f8b2cd27f9685d3e9ed1b98e`

Key results:

- Trade control/constants use TradeController as canonical owner where applicable.
- Trade relation multiplier calculation is centralized through `TradeController.get_relation_multiplier_for_factions()` rather than independently reimplemented in UI and route calculation.
- Diplomacy action/relation constants use DiplomacyController ownership.
- Spy action/rule constants use SpyController/SpyActionService ownership.
- Battle result literals use BattleResultService ownership.
- Turn phase literals use WorldMapTurnController ownership.
- Scene-boundary constants and genuine WorldMap-wide coordinator responsibility remain in main deliberately.

The historical diplomacy guard was explicitly re-pinned rather than relaxed.

## M-FINAL-B — Final hub audit

Approved production cleanup checkpoint:

`9a8617e2f4b1bd8dce7f04c2a4e0fd9f0ef05d30`

Audit method:

- Repository-wide text scan across Godot/code/config/docs sources.
- Godot lifecycle methods excluded from dead-private-function candidates.
- Only private functions whose symbol occurred exactly once repo-wide (their definition) were eligible.
- Dead constant aliases were verified to have no reference outside their declaration line; alias self-reference on the declaration line was not mistaken for a live call site.
- Exact-file scope guard required the cleanup to change only `scripts/worldmap/worldmap_main.gd`.
- `git diff --check` was required before commit.

Cleanup result:

- 52 dead private functions removed.
- 23 dead constants / aliases removed.
- `worldmap_main.gd`: 14,529 lines -> 14,094 lines.
- Diff: 1 production file, 0 additions, 435 deletions.

Representative removed residue:

- obsolete HUD drag wrappers after HUD/shared-UI extraction,
- unused trade formatting helpers,
- unused turn helpers after WorldMapTurnController extraction,
- unused Domestic Tech compatibility/helper tails proven unreferenced,
- unused economy/warehouse formatting tails,
- disconnected placeholder handlers,
- unused Spy rule aliases already canonically owned by Spy services,
- unused Trade relation/suspension aliases.

Representative responsibilities intentionally retained in main:

- Controller/Service construction and dependency wiring,
- signal/callback wiring,
- high-level turn/world/battle orchestration boundaries,
- WorldMap <-> Battle scene handoff/meta keys,
- live compatibility bridges still used by UI/tests/runtime,
- Hero/Occupation global indexing/cache/victory coordination where WorldMap-wide knowledge is required,
- UI aliases and constants that still have real call sites,
- Trade route cap/dampener/food-factor usage still required by current route calculation,
- Spy action IDs still consumed directly by WorldMap UI.

## Validator closeout

`tools/validate_worldmap_diplomacy_routing.py` is re-pinned to the immutable M-FINAL-B production checkpoint and preserves the historical T-4 guard.

It additionally verifies:

- M-FINAL-A -> M-FINAL-B changed-file scope is exactly `worldmap_main.gd`,
- approved canonical ownership/delegation remains present,
- representative audited dead residue remains absent,
- future unreviewed `worldmap_main.gd` changes fail the exact-checkpoint guard.

## Ongoing rule

Do not optimize for further line-count reduction.

For future WorldMap work:

1. Put behavior in the existing domain owner when one exists.
2. Create a dedicated Controller/Service/Helper only for a genuinely new responsibility.
3. Keep `worldmap_main.gd` to wiring, scene boundary coordination, and cross-domain orchestration.
4. Do not move a WorldMap-wide responsibility out merely to reduce main line count.
5. Any intentional main change must update the exact validator checkpoint only after review and regression testing.

After the final full CI is green, the next development phase should prioritize MVP gameplay completion and repeated WorldMap -> Battle -> Result -> Next Turn playtesting rather than further structural refactoring.
