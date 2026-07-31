# T06-10H Post-Battle Garrison Hero Portrait Parity Recovery

## Status

`IMPLEMENTED / POST-BATTLE GARRISON PORTRAIT PARITY PASS / USER OCCUPATION F5 RE-QA PENDING`

## User reproduction and audit

- Reproduction: Gyeongju attacks Sabi, wins, returns to WorldMap, then opens Sabi's stationed-hero list. Uija Wang, Gyebaek, Heukchi Sangji, Kim Chun-chu, and Jang Bo-go displayed `?`; Kim Yu-sin remained visible.
- The city panel reads `stationed_hero_ids`, resolves each exact canonical ID through WorldMap's `_get_hero_entry`, then calls `WorldMapHeroPortraitHelper.apply_hero_portrait_or_placeholder`. Placeholder is selected only when every declared portrait field and fallback path fails to load.
- Battle settlement does not replace the authoritative hero record. `_get_hero_entry` starts with `HeroDefinitionRegistry.HERO_DATA[hero_id]` and overlays `_hero_runtime_states[hero_id]`; city garrison state stores ID arrays only. The battle result/occupation path keeps mutable city, status, wound, faction, and troop state separately.
- Root cause: five affected Korea MVP records have canonical IDs and available portrait assets, but no populated portrait field in legacy identity metadata. Kim Yu-sin was the sole normal control because an old `gim_yusin` compatibility path existed. This was metadata-path parity failure, not a display-name match, missing image asset, or result-settlement rule failure.

## Recovery contract

- `WorldMapHeroPortraitHelper` now resolves declared explicit portrait fields first, then derives a canonical asset path from authoritative `hero_id` plus faction metadata (`korea`, `china`, `japan`, or `mongol`), and only then considers legacy compatibility filenames.
- The lookup never uses display names. Runtime battle/occupation state cannot overwrite the static `hero_id`/faction metadata supplied by `_get_hero_entry`, so city garrison rows retain an authoritative path after occupation, city reselection, turn progression, and save/load.
- No portrait asset, hero stat, skill, troop, loyalty, combat result, occupation, capture, injury, death, AI, or save schema was changed.

## Automated validation

- `tools/validate_korea_mvp_garrison_portrait_parity.gd` simulates authoritative metadata plus post-battle mutable-state overlay and requires a valid `Texture2D` for all 13 Korea MVP heroes. Result: `[GARRISON_HERO_PARITY] 13/13 PASS`.
- Godot project parse plus WorldMap and Battle_Land loads passed. Existing T04/T05 WorldMap turn, occupation-index, and save/load smoke passed.
- The full interactive Gyeongju-to-Sabi battle completion does not terminate as a deterministic headless test, so the user occupation F5 path remains required.

## Next

- User F5 occupation re-QA, then `T06-11 AI Multi-Unit Engagement, Surround & Cooperative Attack Correction`.
