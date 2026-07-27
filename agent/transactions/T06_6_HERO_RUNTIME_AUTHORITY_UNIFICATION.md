# T06-6 Hero Runtime Authority Unification

Status: `T06-6B IMPLEMENTED / USER GODOT QA PENDING`

## Goal

Replace duplicated legacy/runtime/post-processing hero authority with one deterministic construction path shared by new game, save migration, WorldMap UI, invasion/defense deployment, BattleContext, and BattleUnitState creation.

## Required Architecture

```text
HeroIdentityRegistry
+ HeroDesignDataRegistry
-> HeroRuntimeFactory
-> New Game / Save Load / WorldMap / Deployment / Battle
```

## Authority Split

### HeroIdentityRegistry

Keeps identity and presentation/location metadata only:

- hero_id / id
- display_name / name
- faction/force/nation ownership seed
- assigned/location city seed
- portrait, battlefield portrait, cutin paths
- command rank and non-combat presentation metadata

It must not own final fixed stats, initial loyalty, unit type, movement/range, or battle role authority.

### HeroDesignDataRegistry

Authoritative for:

- leadership
- martial
- intelligence
- politics
- initial_loyalty
- unit_type
- primary_role
- secondary_role
- unique_skill_id
- unit type movement/range rules

### HeroRuntimeFactory

Creates or migrates every runtime hero Dictionary.

Rules:

- New game copies initial_loyalty into mutable loyalty.
- Save migration preserves existing mutable loyalty.
- Final fixed stats and battle profile always come from design JSON.
- Compatibility aliases command/war may be emitted only at the factory boundary while legacy readers remain.
- support is a role only and is invalid as unit_type.
- Factory output is a deep writable copy.

## T06-6B Battle Initial Spawn Authority Unification

Implemented authority boundary:

```text
legacy/test/worldmap battle dictionary
-> BattleUnitState.create/setup
-> hero_id or display-name resolution
-> HeroDefinitionRegistry.HERO_DATA
-> HeroRuntimeFactory.build_battle_unit_payload
-> authoritative BattleUnitState fields
-> first visual render
```

The BattleUnitState creation boundary now guarantees:

- known heroes are rebuilt from the factory-owned runtime registry before setup
- fixed stats and battle profile fields cannot be restored from legacy fixture literals
- unit_type and visual_key are equal before the first render
- current battle values such as slot, position, facing, HP and troop allocation remain overrides
- future BattleUnitState.create callers automatically use the same authority path

Removed:

- `scripts/battle/hero_battle_profile_integration.gd`
- scene polling and post-entry unit profile mutation code contained in that file

Validation now requires:

- BattleUnitState setup consumes `_build_authoritative_payload(data)`
- BattleUnitState calls `HeroRuntimeFactory.build_battle_unit_payload`
- visual_key is locked to unit_type at creation
- runtime hero resolution supports hero_id and display name
- the dead postprocess integration file remains deleted

## Complete Transaction Scope

- Add HeroRuntimeFactory.
- Route new-game roster creation through it.
- Route save-load hero migration through it.
- Route invasion and defense deployment payloads through it.
- Route BattleContext hero registry through it.
- Route BattleUnitState setup from the same runtime contract.
- Remove HeroWorldMapStatIntegration UI/tree post-processing Autoload.
- Remove HeroBattleProfileIntegration post-entry correction responsibility.
- Remove recurring tree/Label scanning.
- Remove web_role/support fallback as unit-type authority.
- Keep current loyalty persistence and protected battle/settlement behavior.

## Forbidden End State

The transaction is not complete if any of these remain necessary:

- Label text scanning to correct stats or unit type
- scene polling to mutate already-created hero data
- Battle entry correction of wrong WorldMap unit type
- final stats/initial loyalty/unit type duplicated as active authority in legacy registry
- support accepted as a unit type
- unit_type and visual_key being updated from different sources or at different times

## Validation Gates

Static validation must fail on:

- any support unit_type in generated profiles or runtime factory fixtures
- missing design record for any of 39 hero IDs
- WorldMap/Battle unit type mismatch
- initial loyalty replacing existing saved current loyalty
- old four-value stat UI formatter used for hero surfaces
- post-processing Autoload registrations remaining in project.godot
- dead postprocess integration file returning
- BattleUnitState setup bypassing HeroRuntimeFactory
- BattleUnitState allowing visual_key and unit_type to diverge at creation

## User Godot QA

- F5 starts with no parser/runtime error.
- Normal WorldMap performance remains restored.
- Degree Jeong is an archer on the first battle frame.
- Dorim is an archer on the first battle frame.
- Moving a unit does not change its unit type or battlefield visual.
- Cheok Jun-gyeong is infantry everywhere.
- Konishi Yukinaga and Honda Masanobu are gunners everywhere.
- Multiple eligible heroes can be selected and deployed.
- Other-city invasion and defender deployment use the same profile.
- Save/load preserves changed current loyalty.
- Battle entry/return and settlement remain normal.

WorldMap first-render old-data flash remains a separate T06-6C audit target if it persists after this battle QA.

## Completion Rule

Do not Complete Lock from static validators alone. User Godot F5 and integrated invasion/battle/save QA are required.
