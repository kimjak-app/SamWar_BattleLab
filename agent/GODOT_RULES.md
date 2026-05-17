# SamWar Godot Rules

## Core Philosophy
- Code controls behavior.
- Scene controls layout and visual placement.

---

## Scene Rules
- Never create major visual battlefield nodes at runtime.
- All important gameplay and visual nodes must exist in the .tscn scene file.
- Important nodes must be visible in the Godot 2D editor.
- Important nodes must be draggable/selectable in the editor.

---

## Allowed Runtime Nodes
Allowed:
- particles
- smoke
- floating damage text
- temporary fire
- temporary effects

Not allowed:
- ally formations
- enemy formations
- battlefield textures
- main cameras
- projectile markers
- core battlefield layout nodes

---

## Node Naming Rules
Always use explicit readable names:
- AllyFormation
- EnemyFormation
- ProjectileStartMarker
- ProjectileControlMarker
- ProjectileEndMarker
- SingijeonProjectile
- SingijeonExplosion
- MainCamera
- BattlefieldTexture

Never allow:
- @Sprite2D@5
- @Node2D@14

---

## Positioning Rules
- Main positions/scales must be editable in the Inspector.
- Avoid hardcoded layout positions in code.
- Use Marker2D nodes for editable gameplay positions.

---

## Editor-First Layout Rule
- When a visual problem is about placement, scale, UI attachment, or click area feel, first check whether the user can solve it directly in the Godot 2D editor.
- Prefer scene-authored layout for visual nodes.
- Runtime code should preserve and follow editor-authored offsets when possible.
- Do not force visual positions with hardcoded constants unless necessary.
- If code must move visual nodes during gameplay, capture the initial editor-authored offsets and reuse them.
- The user's workflow speed matters: find the easiest editable structure before writing more logic.
- Find the structure that makes it easier for Kimjak to work first.
- Before making a new Codex instruction chain, first check whether there is a simpler structural solution in the scene layout.

---

## Coordinate Rules
Standard battle viewport:
- 1152 x 648

Keep important gameplay areas inside visible editor space.

---

## Script Rules
- Use @onready references.
- Do not instantiate main layout nodes in _ready().
- Scripts should control:
  - movement
  - animation
  - HP
  - camera shake
  - signals
  - temporary effects

---

## Inspector Editing
The following must be adjustable directly in the editor:
- formation positions
- projectile arc
- impact point
- explosion scale
- camera placement

---

## Workflow
1. Create/edit layout in .tscn
2. Fine-tune visually in 2D editor
3. Use code only for behavior
4. Test with F5
5. Iterate visually
6. If the editor layout feels wrong at runtime, preserve the scene-authored offsets before adding more hardcoded corrections
