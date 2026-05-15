# CURRENT STATE

## Project
SamWar_Godot_Test

## Current Goal
Prototype a 2.5D-style battlefield with singijeon projectile effects in Godot 4.

---

## Completed
- Godot project created
- 2.5D battlefield perspective prototype implemented
- Grass battlefield texture applied
- Blue/red spearman formations applied
- Singijeon projectile animation applied
- Explosion animation applied
- Projectile arc implemented
- Camera shake implemented
- Enemy HP reduction implemented
- Projectile markers implemented:
  - ProjectileStartMarker
  - ProjectileControlMarker
  - ProjectileEndMarker
- Explosion scale editable from Inspector
- Battlefield layout editable in Godot 2D editor

---

## Important Assets
- assets/battlefield_grass_tile.png
- assets/blue_spearman.png
- assets/red_spearman.png
- assets/singijeon_fly_sheet.png
- assets/singijeon_explosion_sheet.png

---

## Current Key Scene
- Battle_Singijeon_Test.tscn

---

## Current Key Script
- scripts/battle_singijeon_test.gd

---

## Current Editor Workflow
- Move ProjectileEndMarker to adjust impact point
- Move ProjectileControlMarker to adjust arc height
- Adjust SingijeonExplosion scale in Inspector
- Adjust formation positions directly in 2D editor
