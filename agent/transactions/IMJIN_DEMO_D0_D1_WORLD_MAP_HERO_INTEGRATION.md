# IMJIN DEMO D0-D1 WORLD MAP HERO INTEGRATION

## Status

`PLANNED / IMPLEMENTATION PENDING`

## Purpose

Integrate the five newly added Imjin War heroes into the shared production hero/runtime path used by the Korea MVP WorldMap and Battle_Land flow.

This transaction is **not** the Demo Test2 implementation. Test2 remains a separate demo-only scenario track defined in `agent/IMJIN_DEMO_NAVAL_EXTENSION_PLAN.md`.

## Scope

### D0 — 44-hero design-data contract

- Raise `HeroDesignDataRegistry.EXPECTED_HERO_COUNT` from 39 to 44.
- Extend `hero_initial_loyalty.json` with the five new hero IDs so all four generated hero datasets share the same 44-hero identity set.
- Validate base stats / initial loyalty / battle profiles / unique skills parity for all 44 heroes.

### D1 — WorldMap production registration

Register these heroes in `HeroDefinitionRegistry.LEGACY_IDENTITY_DATA` so `HeroRuntimeFactory.build_runtime_registry()` can compose their generated design data into production `HERO_DATA`:

- `gwak_jae_u` — 곽재우
- `go_gyeong_myeong` — 고경명
- `kim_deok_ryeong` — 김덕령
- `kato_kiyomasa` — 가토 기요마사
- `kuroda_nagamasa` — 구로다 나가마사

Initial placement contract for this integration:

- Korea trio: `goryeo_joseon` / `hanseong`
- Japan duo: `toyotomi` / `osaka`

Existing Toyotomi Hideyoshi, Shimazu Yoshihiro, and Konishi Yukinaga placement is unchanged.

## Protected contracts

- Do not alter Korea MVP city/faction ownership rules.
- Do not alter existing hero IDs or generated combat values.
- Do not change BattleContext schema or pending invasion schema.
- Do not implement Korea-Japan sea routes, naval movement, or naval battle here.
- Do not modify Test1 Korea-vs-China roster in this transaction.
- Do not implement Demo Test2 here.

## Acceptance

1. `HeroDesignDataRegistry.ensure_loaded()` accepts all four 44-record hero datasets.
2. The five new hero IDs exist in production `HeroDefinitionRegistry.HERO_DATA`.
3. Their generated base stats, unit type, battle role, unique skill, and initial loyalty are composed through `HeroRuntimeFactory`, not duplicated as new authoritative combat values in identity data.
4. Korea trio resolves to Hanseong and Japan duo resolves to Osaka without changing existing hero placement.
5. Existing 39 hero IDs remain intact.
6. D2 can subsequently use the ordinary WorldMap hero-selection / formation / Battle_Land handoff path with these IDs.
