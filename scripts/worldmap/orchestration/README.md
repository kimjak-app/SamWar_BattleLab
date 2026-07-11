# Orchestration

Purpose:
- v0.71 refactor destination for Scene / Runtime Orchestration helpers extracted from the active worldmap script.

Allowed later:
- Late-stage orchestration wrappers only after lower-risk helpers are extracted.
- Small, verified extraction steps only.

Not allowed yet:
- Moving `_ready`, turn advance, signal wiring, or input orchestration early.
- Changing scene/runtime flow.
- Changing gameplay formulas or schemas.
- Changing scene node paths or script paths.

Current status:
- Placeholder only.
- No runtime script moved here in v0.71-03.
