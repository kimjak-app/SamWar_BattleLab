# Save Load

Purpose:
- v0.71 refactor destination for Save / Load helpers extracted from `scripts/worldmap_test.gd`.

Allowed later:
- Schema-sensitive helpers only after explicit protection exists.
- Normalization helpers if a dedicated task proves the boundary.
- Small, verified extraction steps only.

Not allowed yet:
- Moving save/load functions in early v0.71.
- Changing save/load schema.
- Changing migration/default behavior.
- Changing scene node paths or script paths.

Current status:
- Placeholder only.
- No runtime script moved here in v0.71-03.
