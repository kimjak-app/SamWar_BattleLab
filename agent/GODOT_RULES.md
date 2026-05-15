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
