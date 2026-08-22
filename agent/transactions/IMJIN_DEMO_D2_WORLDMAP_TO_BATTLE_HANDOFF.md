# IMJIN DEMO D2 WORLDMAP TO BATTLE HANDOFF

## Status

`EXISTING PRODUCTION CONTRACT REUSED / STATIC AUDIT PASS / USER F5 QA PENDING`

## Goal

Confirm that the five new Imjin hero IDs can travel through the normal production path:

`WorldMap hero list -> invasion formation -> pending battle context -> Battle_Land -> BattleUnitState`

without adding a demo-specific or Imjin-specific handoff schema.

## Audit result

No new D2 handoff implementation is required.

The existing production path already carries stable hero/general IDs through the WorldMap battle context. `Battle_Land` reads the WorldMap context and applies it to runtime battle setup, while `HeroBattleDesignAdapter`/`HeroRuntimeFactory` resolve hero design data generically by `hero_id`.

The newly registered hero IDs therefore use the same production contract as the existing Korea MVP heroes.

## New hero IDs covered

- `gwak_jae_u`
- `go_gyeong_myeong`
- `kim_deok_ryeong`
- `kato_kiyomasa`
- `kuroda_nagamasa`

## Protected contracts

- Do not add an Imjin-only BattleContext schema.
- Do not add hero-name whitelists to Battle_Land.
- Do not change pending invasion schema.
- Do not change Korea MVP attack/defense sequencing.
- Do not add Korea-Japan sea adjacency or naval transition here.
- Do not change Test1 Korea-vs-China data here.

## Static evidence

- `HeroBattleDesignAdapter.build_battle_contract(source_hero)` builds runtime data generically from `source_hero.hero_id` through `HeroRuntimeFactory` and `HeroDesignDataRegistry`.
- `Battle_Land` (`scripts/battle_web_import_test.gd`) reads `samwar_worldmap_battle_context` and applies a non-empty context through `_apply_worldmap_battle_context_handoff()`.
- Battle result payload preserves `attacker_general_ids` / `defender_general_ids`, with legacy fallback keys only for compatibility.
- `BattleUnitState` stores generic `hero_id`/display/unit/skill fields and does not require a five-hero whitelist.

## User F5 QA gate

### Player-side production flow

1. Start from normal F5 entry.
2. Open Hanseong and confirm the new Korea heroes are selectable.
3. Begin a legal Korea MVP invasion using the ordinary attack UI.
4. Put at least one of 곽재우 / 고경명 / 김덕령 into the existing formation slots.
5. Confirm the formation accepts the hero and battle transition reaches `Battle_Land` exactly once.
6. In battle, confirm the same hero name/id, intended portrait, generated troop type, troop values, battle profile and unique-skill data are present.
7. Finish/retreat only through existing battle result flow and confirm WorldMap returns normally.

### Japan-side data path

Osaka registration for 가토 기요마사 / 구로다 나가마사 is production data, but a Korea-Japan sea route is intentionally outside D2. Their immediate 5v5 playable showcase is handled by Demo Test2, not by inventing a temporary WorldMap naval adjacency rule.

## Completion rule

D2 is code-complete if the ordinary handoff accepts the new IDs without special casing. Final runtime completion requires the user F5 gate above.
