# SamWar Godot Rules

## Core Philosophy
- Code controls behavior.
- Scene controls layout and visual placement.
- Task scope and verification depth must match task complexity.

---

## Scene Rules
- Never create major visual battlefield nodes at runtime.
- Never create major production HUD roots only at runtime.
- All important gameplay and visual nodes must exist in the .tscn scene file.
- Important nodes must be visible in the Godot 2D editor.
- Important nodes must be draggable/selectable in the editor.
- Runtime code may update values, visibility, animation, textures, temporary effects, and interaction state.

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
- top HUD roots
- ally/enemy roster HUD roots
- actor/target comparison HUD roots
- global command HUD roots

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
- TopHudRoot
- AllyRosterHud
- EnemyRosterHud
- ActorComparisonHud
- InteractionGuideHud

Never allow:
- @Sprite2D@5
- @Node2D@14

---

## Positioning Rules
- Main positions/scales must be editable in the Inspector.
- Avoid hardcoded layout positions in code.
- Use Marker2D nodes for editable gameplay positions.
- Use scene-authored anchors, containers, and explicit safe-zone roots for production UI.

---

## Editor-First Layout Rule
- When a visual problem is about placement, scale, UI attachment, or click area feel, first check whether the user can solve it directly in the Godot 2D editor.
- Prefer scene-authored layout for visual nodes.
- Runtime code should preserve and follow editor-authored offsets when possible.
- Before forcing visual positions from code, first inspect whether the existing scene-authored offset capture structure can preserve the editor layout.
- Do not force visual positions with hardcoded constants unless necessary.
- If code must move visual nodes during gameplay, capture the initial editor-authored offsets and reuse them.
- The user's workflow speed matters: find the easiest editable structure before writing more logic.
- Find the structure that makes it easier for Kimjak to work first.
- Before making a new Codex instruction chain, first check whether there is a simpler structural solution in the scene layout.

---

## UnitVisual Slot Rule
- Runtime unit visuals should use the actual battle token nodes as the single active visual slots:
  - `AllySide/AllyUnitToken`
  - `AllySide/AllySupportUnitToken`
  - `EnemySide/EnemyUnitToken`
  - `EnemySide/EnemySupportUnitToken`
- `visual_key` should swap the texture on those real token nodes.
- Type-specific `UnitVisualTemplate` nodes may remain as slot/layout references, but they should not become a second active visible unit layer at runtime.
- Avoid editor overlap between actual battle nodes and template preview sprites.
- Do not solve token size differences with per-unit or per-type hardcoded runtime scale.

---

## Coordinate Rules
Production battle UI baseline:
- `1920 × 1080`, 16:9.

Legacy test/cutin content may still contain:
- `1152 × 648` assumptions.

Rules:
- T08 production battle UI is authored at 1920×1080 first.
- Legacy 1152×648 cutin or video content must be scaled/contained inside the production presentation hierarchy rather than redefining the battle viewport.
- Important gameplay and UI areas must remain inside the 1920×1080 editor space.
- Supported scaling is tested only after the production baseline is stable.
- Turn, momentum, names, HP/troop values, statuses, logs, and other changing text must be Godot controls, not baked into static PNG assets.

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
  - dynamic UI values and presentation state
- One unit occupies one logical grid cell.
- Occupied cells block normal movement unless a future explicit exception system is added.
- For facing:
  - Facing is state, not always auto-look.
  - Automatic facing should not erase manual facing.
  - Enemy should not instantly face the ally outside its own action timing.
  - Breakthrough or pass-through movement should remain a future skill-only exception.
  - `Troop UnitToken` may use left/right flip when needed.
  - `Hero PortraitBadge` must not flip.
  - `Hero PortraitBadge` may move position based on facing if needed.
  - `HPBar`, `TroopLabel`, `Shadow`, and `ClickArea` should keep scene-authored layout unless there is a clear reason not to.

---

## Production UI Rules
- Major production HUD roots exist in the scene.
- Static art and dynamic values remain separated.
- Use TextureRect, NinePatchRect, StyleBoxTexture, theme resources, and containers where appropriate.
- Do not bake hero names, turn values, momentum values, or battle-state text into images.
- Command IDs and handlers are authoritative; Korean labels must match their actual behavior.
- Disabled commands must expose a readable Korean reason.
- Modal toasts, cutins, and results must restore the correct normalized UI state.
- Persistent ally/enemy HUD identity must not be confused with attacker/defender battlefield role.
- Defender role uses city/fortress deployment; attacker role uses temporary-camp deployment regardless of player/AI identity.

---

## Inspector Editing
The following must be adjustable directly in the editor:
- formation positions
- projectile arc
- impact point
- explosion scale
- camera placement
- production HUD anchors and safe zones
- roster placement
- actor-comparison HUD placement
- floating command offsets and avoidance margins where scene-driven

---

## Workflow
1. Create/edit layout in .tscn
2. Fine-tune visually in 2D editor
3. Use code only for behavior and dynamic state
4. Test with F5
5. Iterate visually
6. If the editor layout feels wrong at runtime, preserve the scene-authored offsets before adding more hardcoded corrections
7. For T08, approve the Hanseong production template before cloning the UI/camera/framing contract to Sabi, Gyeongju, and Pyongyang