# IMJIN DEMO D0-D1 WORLD MAP HERO INTEGRATION

## Status

`IMPLEMENTED / STATIC CONTRACT VALIDATION ADDED / USER F5 QA PENDING`

## Purpose

Integrate the five newly added Imjin War heroes into the shared production hero/runtime path used by the Korea MVP WorldMap and Battle_Land flow.

This transaction is **not** the Demo Test2 implementation. Test2 remains a separate demo-only scenario track defined in `agent/IMJIN_DEMO_NAVAL_EXTENSION_PLAN.md`.

## Implemented

### D0 — 44-hero design-data contract

- `HeroDesignDataRegistry.EXPECTED_HERO_COUNT` raised from 39 to 44.
- `hero_initial_loyalty.json` extended with the five new hero IDs.
- New heroes use explicit loyalty `80`, matching the pre-existing `HeroRuntimeFactory` fallback rather than inventing new differentiated balance values.
- Added `tools/validate_imjin_d0_d1_worldmap_hero_integration.py` to verify 44-record parity and identity alignment across generated hero datasets.

### D1 — WorldMap production registration

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

## Protected contracts

- Korea MVP city/faction ownership rules remain unchanged.
- Existing hero IDs and generated combat values remain authoritative and unchanged.
- BattleContext schema and pending invasion schema remain unchanged.
- Korea-Japan sea routes, naval movement, and naval battle are out of this transaction.
- Test1 Korea-vs-China roster remains unchanged.
- Demo Test2 remains a separate transaction.

## Validation

Automated validator added:

```text
python tools/validate_imjin_d0_d1_worldmap_hero_integration.py
```

The current connector-only environment cannot execute the repository locally, so local Python/Godot execution is not claimed here. User F5 remains the visual/runtime gate.

## User F5 QA gate

1. F5 the normal game entry and open Hanseong hero listing.
2. Confirm 곽재우 / 고경명 / 김덕령 are visible with intended portraits.
3. Confirm Osaka contains 가토 기요마사 / 구로다 나가마사 when that faction/city is inspected through the existing WorldMap UI.
4. Confirm pre-existing hero/city assignments are unchanged.

## Acceptance status

1. 44-record runtime contract — implemented.
2. Five production identities — implemented.
3. Generated base stats / unit type / roles / unique skill composition — preserved through `HeroRuntimeFactory`.
4. Korea trio Hanseong / Japan duo Osaka — implemented.
5. Existing identity set retained and expanded rather than replaced.
6. D2 reuses the ordinary WorldMap formation/Battle_Land handoff; no new schema is required.
