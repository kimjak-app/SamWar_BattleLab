# WorldMap Helper Destinations

Purpose:
- v0.71 refactor destination root for helpers extracted from the active worldmap script.

Allowed later:
- Domain-specific helper modules under the subfolders in this directory.
- Small, verified extraction steps only.
- README updates that clarify extraction boundaries.

Not allowed yet:
- Moving existing runtime `.gd` scripts in v0.71-03.
- Changing scene node paths or script paths.
- Introducing Autoloads or broad `class_name` changes.

Current status:
- Active worldmap orchestrator script: `scripts/worldmap/worldmap_main.gd`.
- The legacy root script path was retired in v0.71-13.
