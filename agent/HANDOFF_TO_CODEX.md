# HANDOFF TO CODEX

Before making any changes, always read:

1. agent/GODOT_RULES.md
2. agent/CURRENT_STATE.md
3. agent/NEXT_TASKS.md

---

## Important

This project uses an editor-friendly Godot workflow.

Do NOT:
- create major battlefield nodes at runtime
- use unreadable auto-generated node names
- hardcode important layout positions in code

Always:
- use scene nodes
- use @onready references
- keep positions editable in the Godot editor
- preserve draggable Marker2D workflow

---

## Current Workflow
- Layout is adjusted visually in the Godot 2D editor.
- Code controls behavior only.
- Projectile paths are controlled by Marker2D nodes.
- Explosion scale is controlled from Inspector.

---

## After Every Major Task
Update:
- CURRENT_STATE.md
- NEXT_TASKS.md

Include:
- what changed
- important node additions
- important asset additions
- remaining known issues
