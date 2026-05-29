# HERO DATA CONTRACT

## Role
- Defines the future hero data contract.
- Separates static hero metadata from battle runtime state.
- Prepares for larger hero counts, regional assignment, army membership, and worldmap deployment.

## Core Split
- `HeroData` is static metadata.
- `BattleUnitState` is state during a specific battle.
- Worldmap, city, region, and army placement are not owned by `BattleUnitState`.
- Battle setup copies the needed static and deployment fields into `BattleContext.roster`.
- `hero_id` is the source of truth for hero identity.
- Portrait textures are not the source of truth.
- The hero registry should move toward a global registry, not battle-scene-only hardcoding.
- The contract assumes the hero count will grow substantially beyond the current test roster.

## HeroData Example
```js
HeroData = {
  hero_id,
  display_name,
  force_id,
  unit_type,
  leadership,
  strength,
  intelligence,
  agility,
  portrait_paths,
  unique_skill_ids,
  default_visual_key
}
```

## Required Fields
- `hero_id`: stable unique ID used across worldmap, army, battle, save data, and skill registry.
- `display_name`: localized hero display name.
- `force_id`: owning force or faction ID.
- `unit_type`: default troop or command style.
- `leadership`: command / army efficiency stat.
- `strength`: physical attack and combat pressure stat.
- `intelligence`: strategy and tactic stat.
- `agility`: turn order, movement, or action timing stat.
- `portrait_paths`: available portrait/cutin references.
- `unique_skill_ids`: IDs into skill metadata.
- `default_visual_key`: default visual fallback key for battle rendering.

## Optional Future Fields
- `birth_year`
- `death_year`
- `era_tags`
- `naval_rating`
- `siege_rating`
- `terrain_affinity`
- `loyalty`
- `relationship_tags`
- `home_region_id`
- `preferred_unit_types`

## Runtime State Boundary
- `BattleUnitState` may contain current troops, cooldowns, action state, battle statuses, grid position, facing, and defeat state.
- `BattleUnitState` should not become the canonical hero registry.
- `BattleUnitState` should not own worldmap location, city assignment, or army membership after battle ends.

## Placement Boundary
- Hero placement belongs to worldmap / city / army data.
- A hero may be assigned to:
  - region
  - city
  - army
  - fleet
  - reserve pool
- A hero may move on the worldmap through region, city, army, or fleet movement.
- A hero assigned to the relevant region, city, army, fleet, or reserve pool can become a battle roster candidate.
- Battle startup should receive the selected heroes through `BattleContext.roster`.

## Regression Guard
- Preserve the current hero identity registry behavior until the external contract replaces the demo path.
- Do not use scene portrait textures as the final identity source of truth.
- Keep `hero_id` stable across skill lookup, portrait lookup, battle unit state, and future save data.
- Do not expand battle-scene-only hardcoded roster data as the long-term hero registry design.

## v0.68b-12b-10b Portrait Binding Note
- Current WorldMap portrait display uses `scripts/worldmap_hero_portrait_helper.gd`.
- The helper treats `HERO_DATA` fields such as `portrait_image`, `portrait_path`, `portrait`, `image_path`, and `image` as optional display metadata only.
- Legacy imported paths under `assets/portraits/...` may be resolved to existing repo assets under `assets/web_battle/portraits/...`.
- Missing fields, missing files, and failed texture loads must keep the visible `?` fallback and must not change hero identity or gameplay state.
