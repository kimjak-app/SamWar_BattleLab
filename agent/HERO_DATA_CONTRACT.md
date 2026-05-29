# HERO DATA CONTRACT

## v0.68b-12b-18a Battle Context Slot Fallback Guard
- WorldMap `enemy_invasion` rosters must keep `hero_id` identity from BattleContext data; missing slots are inactive instead of sample-filled.
- `TEST_BATTLE_ROSTER` remains a direct sample battle fallback and must not become a hidden source of WorldMap support heroes.
- This preserves the existing `portrait_path` / `skill_name` binding contract and does not add new portrait fields or hero placement data.

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

## v0.68b-12b-16 Battle Data + Unique Skill Contract
- Every actual WorldMap hero that enters BattleContext must have a battle-data copy with combat fields and unique-skill fields.
- Required battle copy fields include `hero_id`, `display_name` / `name`, `faction_id` / `nation` / `owner`, `city_id` / `current_city_id`, `unit_type`, `troop_count` / `troops`, `leadership` / `command`, `war` / `attack`, `defense`, `intelligence`, `move_range` / `mobility`, `attack_range`, `portrait_path`, `cutin_path`, `skill_id`, `skill_name`, `skill_desc`, `skill_effect_type`, `skill_power` / `skill_value`, `skill_range`, `skill_cooldown`, and `skill_toast_icon`.
- `portrait_path` is the single canonical portrait field and represents a 512x512 source image. Do not add `portrait_128_path` or `portrait_512_path`.
- Battle UI slots that need 128px portraits should load the same `portrait_path` safely and downscale in UI.
- Unique-skill cutin/effect images are separate from portraits and use `cutin_path`.
- Recommended path contracts are `res://assets/heroes/portraits/{nation}/{nation}_{hero_id}.png` and `res://assets/heroes/cutins/{nation}/{nation}_{hero_id}_cutin.png`.
- Existing 128 image folders are retained for now and must not be deleted as part of this contract step.
- `v0.68b-12b-16` does not add bulk image assets or complete image binding. Safe resolver/binding work is deferred to `v0.68b-12b-17` or `16a`.
- Save/load persistence for hero battle data remains unimplemented; BattleContext copies are runtime handoff data.

## v0.68b-12b-16b Hero Placement Data Patch
- The five placement-patch heroes now have full WorldMap hero battle data and unique-skill data: `liu_bei`, `kwon_yul`, `cheok_jun_gyeong`, `lu_bu`, and `xiahou_dun`.
- Confirmed skill names are part of the data contract for these records: 유비 `인의의 깃발`, 권율 `행주대첩 항전`, 척준경 `검왕돌파`, 여포 `무쌍난무`, 하후돈 `발검돌파`.
- City placement contract: 유비 -> 성도, 권율 -> 한성, 척준경 -> 평양, 여포 -> 낙양, 하후돈 -> 업성. The same `hero_id` must not appear in two city rosters.
- `portrait_path` remains the single 512-source portrait field, and `cutin_path` remains separate for future cutin/effect presentation.
- Hero IDs do not need to match asset filenames exactly; explicit `portrait_path` / `cutin_path` fields are authoritative for the asset contract.
- Save/load placement persistence, capture/wound/death, full hero movement, precise skill balance, and cutin presentation are still deferred.

## v0.68b-12b-17 Actual Battle Portrait Binding
- Battle UI now resolves actual WorldMap context `portrait_path` data before sample battle registry portrait data, so overlapping sample ids do not override the real WorldMap hero portrait.
- The single `portrait_path` remains the 512-source portrait field. Battle portrait Sprite2D slots display that texture by scaling it to the existing 128 target size; no `portrait_128_path` or `portrait_512_path` split is allowed.
- Missing portraits must use a named common unknown portrait fallback, not a specific hero portrait.
- Unique-skill toast text should prefer the WorldMap context `skill_name`; `skill_desc` is copied into the runtime skill entry for UI reuse.
- Dedicated skill toast/cutin images remain optional. Missing assets use a common skill fallback icon, and full cutin presentation remains deferred.
- Save/load persistence, hero capture/wounds/death, hero movement, and resource looting remain outside this contract step.

## v0.68b-12b-17a Battlefield Portrait Scale + Skill Name Hotfix
- Battlefield portrait badges must preserve the old engine display scale: previous `128x128` battlefield portrait assets used scene scale `0.32`, so 512-source `portrait_path` images should display at roughly `41px` in battlefield Sprite2D badges.
- The 512 `portrait_path` remains the single source. Do not add split portrait fields or generate 128 portrait files.
- Skill UI should prefer actual `skill_name`. `장수명 전법` is allowed only when no explicit or registry-backed skill name exists.
- Existing sample unique-skill registry names and cutin paths may be reused as fallback for known compatible heroes when WorldMap context data only supplies generated fallback skill names or missing cutin paths.
- Existing unique-skill toast frame/animation path should remain intact; common `skill_unknown`/fallback icon is used only when no dedicated skill/cutin asset exists.
- Full cutin presentation, save/load, capture/wounds/death, hero movement, and resource looting remain out of scope.

## v0.68b-12b-18 Invasion Reinforcement Source Rule
- Invasion BattleContext hero lists are roster decisions, not global hero registry scans.
- Main attacker/defender heroes come from each source city's `stationed_hero_ids` / `hero_ids` first.
- Support heroes may be added only from same-faction or explicit-ally nearby cities within 1-hop/2-hop MVP adjacency.
- If nearby support is unavailable, the roster stays short; distant heroes must not be inserted just to fill battle capacity.
- Duplicate `hero_id` values across attacker, defender, and support lists are skipped.
- Sample battle roster fallback remains only a crash guard for direct sample battles or fully empty/broken context sides.
- Save/Load placement persistence, hero wounds/capture/death, hero movement, and precise strategic AI remain deferred.
