# HERO DATA CONTRACT

## v0.68b-12b-25 Wounded Battle Penalty
- Wounded state remains runtime/save state and must not mutate seed `HERO_DATA`.
- `wounded == true` or `status == "wounded"` does not exclude a hero from battle.
- Battle MVP penalties are attack damage `75%`, defense as incoming damage `120%`, and unique-skill numeric effects `70%`.
- Captured/dead state remains battle-ineligible; wounded state is a performance penalty only.
- Save/load continues through existing `worldmap_hero_state` fields; no new save schema is introduced for the penalty.

## v0.68b-12b-24 Captured Battle Exclusion
- Captured state is a runtime/save state, not a seed `HERO_DATA` mutation.
- `captured == true` or `status == "captured"` makes a hero ineligible for invasion BattleContext roster construction.
- `dead == true` or `status == "dead"` is also battle-ineligible as a defensive guard, but dead remains unused by current result logic.
- Wounded heroes remain battle-eligible until a dedicated wounded penalty/exclusion patch exists.
- Captured heroes are not removed from city rosters in this MVP; city UI can still show `[포로]` while battle rosters omit the hero.

## v0.68b-12b-23 Hero State Display Marker
- Hero status display markers are derived from runtime hero state, not seed `HERO_DATA` mutation.
- Display priority is `dead` -> `captured` -> `wounded` -> normal, mapping to `[사망]`, `[포로]`, `[부상]`, or no badge.
- BattleContext hero copies may carry `status`, `wounded`, `captured`, and `dead` so battle formation panels can display the same markers.
- Captured heroes are not excluded from battle or removed from `stationed_hero_ids` in this MVP.
- `dead` is display-safe but still not applied by the current battle result placeholder.

## v0.68b-12b-22 Wound/Capture Placeholder
- Post-battle wound/capture placeholder state is runtime-only and must not mutate `HERO_DATA`.
- The temporary MVP rule marks the first eligible losing-side hero as `wounded` and the second eligible losing-side hero as `captured`.
- `dead` is not used in this MVP and should remain false.
- Captured heroes are not removed from city rosters yet; `stationed_hero_ids` and `hero_ids` remain intact until a dedicated prisoner movement system is implemented.
- Save/load persists these status flags through `worldmap_hero_state`; older saves still default missing fields to `normal` / `false`.

## v0.68b-12b-20 Hero Runtime Status Fields
- `HERO_DATA` remains seed/static metadata; post-battle status fields belong to `_hero_runtime_states` and save/load overrides.
- `worldmap_hero_state` now persists `status`, `wounded`, `captured`, and `dead` in addition to current city identity fields.
- Missing status fields in older save data default to `status: "normal"`, `wounded: false`, `captured: false`, and `dead: false`.
- This patch only prepares the storage contract; it does not remove heroes from cities, move prisoners, roll wounds, roll capture, or mark deaths from battle results.

## v0.68b-12b-19 Hero Location Persistence
- `HERO_DATA` remains seed/static metadata; save/load location changes use runtime hero overrides.
- `worldmap_hero_state` persists only current city identity fields for this MVP: `current_city_id`, `city_id`, and `location_city_id`.
- City rosters are persisted through `worldmap_city_state.stationed_hero_ids` / `hero_ids`; load merges these into mutable city runtime state and synchronizes hero current-city overrides.
- Missing hero ids or city ids in save data are skipped with logs instead of mutating seed data or crashing.
- Capture, wounds, death, prisoner state, and detailed post-battle hero status remain unimplemented.

## v0.68b-12b-18b Formation Panel Identity Guard
- Formation/roster panels in WorldMap context battles must display only context-assigned `hero_id` identities.
- A stale or sample `BattleUnitState` must not override an empty/inactive context slot in the side panels.
- Missing context heroes keep the panel slot hidden/disabled; `TEST_BATTLE_ROSTER` remains a direct sample battle fallback only.
- No new `portrait_128_path` / `portrait_512_path` fields are introduced; the existing `portrait_path` and `skill_name` contracts remain unchanged.

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
