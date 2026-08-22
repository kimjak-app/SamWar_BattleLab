# IMJIN DEMO D0-D1 WORLD MAP HERO INTEGRATION

## Status

`IMPLEMENTED + F5 MANUAL GAP FOUND + REGISTRY-TO-CITY SEED HOTFIX APPLIED / LOCAL VALIDATOR RE-RUN + USER F5 QA REQUIRED`

## Purpose

Integrate the five newly added Imjin War heroes into the shared production hero/runtime path used by the Korea MVP WorldMap and Battle_Land flow.

This transaction is **not** the Demo Test2 implementation. Test2 remains a separate demo-only scenario track defined in `agent/IMJIN_DEMO_NAVAL_EXTENSION_PLAN.md`.

## Implemented

### D0 — 44-hero design-data contract

- `HeroDesignDataRegistry.EXPECTED_HERO_COUNT` raised from 39 to 44.
- `hero_initial_loyalty.json` extended with the five new hero IDs.
- New heroes use explicit loyalty `80`, matching the pre-existing `HeroRuntimeFactory` fallback rather than inventing new differentiated balance values.
- Added `tools/validate_imjin_d0_d1_worldmap_hero_integration.py` to verify 44-record parity and identity alignment across generated hero datasets.

### D1 — WorldMap production identity registration

Registered these heroes in `HeroDefinitionRegistry.LEGACY_IDENTITY_DATA` so `HeroRuntimeFactory.build_runtime_registry()` composes their generated design data into production `HERO_DATA`:

- `gwak_jae_u` — 곽재우
- `go_gyeong_myeong` — 고경명
- `kim_deok_ryeong` — 김덕령
- `kato_kiyomasa` — 가토 기요마사
- `kuroda_nagamasa` — 구로다 나가마사

Placement contract:

- Korea trio: `goryeo_joseon` / `hanseong`
- Japan duo: `toyotomi` / `osaka`

Existing Toyotomi Hideyoshi, Shimazu Yoshihiro, and Konishi Yukinaga placement is unchanged.

### D1 manual-QA correction — identity registration was not sufficient

The first F5 manual check found an important production gap: the five identities existed in `HeroDefinitionRegistry.HERO_DATA`, but the current WorldMap keeps mutable city rosters separately in `_city_runtime_states`, seeded historically from `CITY_HUD_DATA.stationed_hero_ids` / `hero_ids`.

Therefore the initial D1 claim that the heroes were already visible in Hanseong/Osaka was too strong. Registry placement metadata alone did **not** make them appear in the WorldMap city UI.

The hotfix adds the reusable production bridge:

- `scripts/worldmap/worldmap_registered_hero_seeder.gd`
- autoload: `RegisteredHeroCitySeeder`

Its contract is:

1. read every registered production hero from `HeroDefinitionRegistry.HERO_DATA`;
2. use each hero's `assigned_city_id` as initial placement authority;
3. add a hero only when it is absent from all current city rosters **and** absent from `_hero_runtime_states`;
4. mirror both `stationed_hero_ids` and legacy `hero_ids`;
5. add newly seeded PLAYER heroes to `owned_hero_ids`;
6. refresh the WorldMap city HUD after seeding.

The `_hero_runtime_states` guard is essential: a hero that has already moved, deployed, been captured, or otherwise acquired runtime state must never be teleported back to its original registry city just because the WorldMap scene reloads.

This bridge is intentionally generic. Future hero additions with a valid `assigned_city_id` should not require another hard-coded edit to `CITY_HUD_DATA` merely to become visible in the production WorldMap.

## Protected contracts

- Korea MVP city/faction ownership rules remain unchanged.
- Existing hero IDs and generated combat values remain authoritative and unchanged.
- BattleContext schema and pending invasion schema remain unchanged.
- Korea-Japan sea routes, naval movement, and naval battle are out of this transaction.
- Test1 Korea-vs-China roster remains unchanged.
- Demo Test2 remains a separate transaction.
- The city seeder must never reinsert a hero that already has mutable runtime state.

## Validation

Automated validator:

```text
python tools/validate_imjin_d0_d1_worldmap_hero_integration.py
```

It now verifies not only 44-record/identity parity but also the production registry-to-city seeding bridge and its anti-teleport runtime guard.

The connector-only environment cannot execute the repository locally, so no post-hotfix Python/Godot PASS is claimed here. The validator must be re-run locally after pulling the hotfix, and user F5 remains the visual/runtime gate.

## User F5 QA gate

Because `project.godot` autoload configuration changed, restart Godot once after pulling the branch before this check.

1. F5 the normal game entry and open Hanseong hero listing.
2. Confirm existing 이순신 / 정도전 / 권율 remain present.
3. Confirm 곽재우 / 고경명 / 김덕령 are now present and clickable with intended portraits.
4. Inspect Osaka through the existing WorldMap UI and confirm 가토 기요마사 / 구로다 나가마사 are present in addition to the existing city roster.
5. Confirm no duplicate hero appears after reopening the WorldMap.
6. Confirm moving/deploying an already known hero does not cause the seeder to snap that hero back to the registry city on a later WorldMap load.

## Acceptance status

1. 44-record runtime contract — implemented; local re-validation required after current hotfix series.
2. Five production identities — implemented.
3. Generated base stats / unit type / roles / unique skill composition — preserved through `HeroRuntimeFactory`.
4. Registry placement metadata — implemented.
5. Registry -> mutable WorldMap city roster bridge — implemented by hotfix; F5 QA pending.
6. Existing identity set retained and expanded rather than replaced.
7. D2 reuses the ordinary WorldMap formation/Battle_Land handoff; no new schema is required.
