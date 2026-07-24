# T06-0 Hero Definition Registry Extraction

Status: `COMPLETE`

## Purpose and Scope

Extract the authoritative WorldMap `HERO_DATA` into a dedicated read-only registry without changing data, runtime behavior, persistence, battle handoff, or assets.

## Implementation Baseline

- Implementation commit: `a12ea4ce28948ef4ca7cbe9ad49c02704b1d4867`
- Protected current HEAD, including the generated UID-only follow-up: `5958b593a3c635e722a3bca7152a19dcd6d27868`

## Changed Files

- `scripts/worldmap/hero_definition_registry.gd`
- `scripts/worldmap/worldmap_main.gd`
- The later protected UID follow-up adds `scripts/worldmap/hero_definition_registry.gd.uid` only.

## Implementation and Parity Evidence

- `HERO_DATA` was moved without transformation from `worldmap_main.gd` to `hero_definition_registry.gd`.
- All 39 heroes are retained with identical ID order.
- The full 51-field set is identical.
- Every complete Dictionary, including nested arrays and Dictionary values, was verified equal to the pre-extraction baseline.
- Exactly four direct WorldMap reads were updated to use `HeroDefinitionRegistryScript.HERO_DATA`.
- `_hero_runtime_states` behavior, save/load contracts, BattleContext contract, `UNIQUE_SKILL_REGISTRY`, and Battle code were not changed.
- No scene, video, image, or battlefield asset changed.

## Verification

- `git diff --check`: PASS
- Godot 4.6.2 headless parse: PASS, exit code 0
- User F5 QA: PASS
  - WorldMap entry and hero UI displayed normally.
  - City hero roster and faction determination behaved normally.
  - Attacker and defender heroes were delivered correctly when entering battle.
  - Battle return completed normally.
  - Save/load preserved hero state.
  - No new error or abnormal behavior appeared in final Output.
- The protected UID follow-up did not modify T06-0 code or data.

## Protected Contracts

- The hero-definition source of truth is `scripts/worldmap/hero_definition_registry.gd`.
- T01–T05 save, battle, and turn-processing contracts remain protected.
- Hero field names and meanings are not yet finalized.
- Until T06-1 design is approved, do not delete, consolidate, or rename hero fields.

## Explicit Non-Goals

- Cleaning up `leadership`, `command`, `war`, or `attack`
- Cleaning up `troops` or `troop_count`
- Changing hero stats or adding/removing heroes
- JSON/CSV externalization
- Unique-skill changes or Battle roster unification
- Save-schema changes

## Next Transaction

Only T06-1 Hero Stat Field Contract Design may discuss field contracts after this COMPLETE lock. It remains `DESIGN / NOT IMPLEMENTED`; no runtime implementation is authorized until individual field-contract decisions are approved.
