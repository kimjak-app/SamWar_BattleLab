# T-4 | Domestic Tech Presentation Extraction Audit

## Baseline

- Branch: `recovery/worldmap-iso-sfx-services-20260912`
- T-3 production baseline: `850b37095146688ed80c52c330cfbf069216024e`
- T-3 validator baseline: `f0d8f049fa21daf6c14b1f9302c516cb8242451f`
- Start state: local/origin `0/0`, clean working tree
- Start `worldmap_main.gd`: 17,393 lines

## Controller split rationale

The presentation layer is split into two `Node` controllers because the tree and completion surfaces have independent lifecycles. `WorldMapDomesticTechTreePresentationController` owns overlay construction, refresh, graph layout, node rendering, selection, inspector formatting and icon caching. `WorldMapDomesticTechCompletionPresentationController` owns the FIFO queue, video/timer phase, card, confirmation and exactly-once signals. Neither controller receives `worldmap_main` as a generic host; both receive an explicit UI parent plus named narrow Callables and the read-only EffectProvider.

## Moved presentation constants

- tree overlay layer/margins and tree/detail ratios
- graph node dimensions, margins, tier/branch/stack spacing and line width
- detail watermark size/alpha/texture
- tree/compact icon dimensions and UI64 icon filename map/root
- completion national/city video paths, fallback timeout and video-panel ratios

All numeric values, colors, padding, sizes, positions and visibility timing are preserved.

## Moved functions

Tree controller owns overlay ensure/refresh, national/city panels, inspector construction/routing/formatting, research-action rendering, category/graph canvas, graph positions/labels/lines, graph and compact nodes, selected-node styling, icon placement/cache, presentation formatters and style factories. The top-menu button remains in main because it belongs to the WorldMap UI shell.

Completion controller owns overlay/card construction, viewport layout, event-to-presentation item adaptation, effect-line formatting, video path/load/play/fallback, skip/finished convergence, card display, confirmation, finish/hide and input confirmation predicates.

## Data and mutation boundaries

- Catalog/Rules/ResearchService/EffectProvider files are unchanged.
- Tree domain facts arrive through named query Callables; the controller does not read player or city runtime state.
- Selected tech/city is non-persisted transient state owned by the Tree controller and is cleared on close.
- The research button emits `research_requested(tech_id, city_id)`. Main calls the existing T-2 `_start_domestic_tech_research_mvp`, retaining mutation, save and refresh coordination.
- Completion items retain the existing scope/city/tech/name/category/icon/message/effect/video shape. Effect lines query the existing EffectProvider mappings.
- SFX uses the existing narrow `play_sfx("research")` Callable; no compile-time GameAudio reference was introduced.

## Completion queue and exactly-once lifecycle

The Completion controller owns its transient FIFO queue, active item, video-completion guard, finished identity set and queue-empty guard. A `scope|city_id|tech_id` presentation identity blocks queued, active and already-presented duplicates. Video-finished, timeout and skip converge on one guarded transition to the card. Confirmation is guarded and emits `presentation_completed` once. Empty queue emits `presentation_queue_empty` once. Missing/unloadable video falls back directly to the card.

## Main retained coordinators

- WorldMap top-level setup and input routing
- top-menu Tech Tree button
- hiding/restoring WorldMap shell panels around the overlay
- selected WorldMap city query adapter
- research request → ResearchService mutation/save/refresh route
- research completion event → presentation enqueue route
- Catalog/Rules/ResearchService/EffectProvider construction
- save, HUD, turn and scene orchestration

## UI/layout parity

The extracted code preserves the original node names, dimensions, graph coordinates, branch spacing, styles, colors, fonts, icon sizing, overlay layers, video ratio/max height and card size. New structural tests capture the exact core coordinate and dimension contracts; `WorldMap_16x9_Test.tscn` remains the runtime load parity check.

## Validator exact delta

The T-4 production commit is created before validator recognition. Historical checks may accept only exact function bodies or the complete main file at the immutable T-4 checkpoint. Existing short T-3 checkpoint `850b370` is tightened to full SHA `850b37095146688ed80c52c330cfbf069216024e`. Threshold lowering, whole-function skips and broad whitelists remain prohibited.

## Final T-1 through T-4 architecture

- A — Catalog wrappers: definition/category/scope identity delegates only.
- B — Research Rules wrappers: pure eligibility/cost/duration delegates only.
- C — Research Lifecycle wrappers/coordinators: state/start/charge/progress/completion delegates plus save/UI coordination.
- D — Effect Provider wrappers: completed-tech modifier and summary delegates only.
- E — Presentation wrappers/coordinators: Tree/Completion controller delegates plus WorldMap shell and research-request coordination.
- F — Legacy tech: `national_tech`, city `city_tech` progression and compatibility mirror remain unchanged.
- G — Remaining Domestic Tech logic: no catalog, rule, lifecycle, effect aggregation, graph/node/inspector, video/card or active presentation body remains in main; only narrow adapters, presentation wording/domain-summary adapters and top-level orchestration remain.

Legacy `national_tech` / `city_tech` coexistence remains a separate migration track. T-4 does not create a T-5 track.

## Tests

- Tree presentation extraction: overlay/open/close/refresh, national/city sections, graph coordinates, node state formatting, selection, inspector, research signal, icon placement and dependency boundary.
- Completion presentation extraction: FIFO, duplicate identity, video start/fallback, skip/finished guard, exactly-once confirmation, queue-empty signal, effect lines, layout, SFX and dependency boundary.
- T-1 Catalog/Rules, T-2 ResearchService and T-3 EffectProvider regressions remain mandatory.
- All discovered WorldMap runtime tests, applicable validators, Godot parse/load and `git diff --check` remain mandatory before commit/push.
