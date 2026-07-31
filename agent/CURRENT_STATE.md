# CURRENT STATE

## Baseline

- Repository: `kimjak-app/SamWar_BattleLab`
- Branch: `main`
- T01 through T05 Korea Four-City MVP are complete and protected.
- T06 hero stat, loyalty, battle-profile, unique-skill, battle-calculation, and cross-scene data-authority integration are implemented.
- T06–T07 single-authority architecture remains `HeroDesignDataRegistry -> HeroRuntimeFactory -> BattleUnitState -> BattleSkillResolver`.

## Latest Implemented Transaction

### T06-9 Hero Data Parity

Status: `IMPLEMENTED / STATIC VALIDATION PASS / USER GODOT QA DEFERRED`

- WorldMap battle-context hero entries are rebuilt through `HeroRuntimeFactory` before battle handoff.
- Canonical five-stat, unit-type, movement, attack-range, role, and unique-skill fields remain protected through formation and battle setup.
- Battle result payloads now include canonical per-hero outcomes for attacker and defender.
- Each outcome records survival, HP, troops, allocation, unit type, and unique-skill ID.
- T02 return settles every participating attacker; defeated heroes return wounded instead of remaining deployed without a city.
- Generic invasion results consume explicit hero outcomes; old placeholder handling remains only for legacy payloads.
- Last-battle troop values and transaction ID are stored in mutable hero runtime state and preserved by save migration.
- Typed outcome-ID fallback was corrected in T06-9-hotfix1.

Transaction record:

- `agent/transactions/T06_9_HERO_DATA_PARITY.md`

## Previous Implemented Transactions

### T06-8 Unique-Skill Battle Calculation

Status: `IMPLEMENTED / STATIC VALIDATION PASS / KOREA MVP RUNTIME QA DEFERRED`

- Unique-skill descriptions are connected to concrete damage, status, movement, momentum, and special-command calculations.
- Deterministic rules replace Lü Bu and Uija random effects.
- Player and AI share the same Resolver commands.

### T06-7 Hero Unique Skills & Shared Momentum

Status: `IMPLEMENTED / USER KOREA MVP QA PASS WITH LATER FULL-ROSTER QA DEFERRED`

- Shared momentum, 39 unique skills, target selection, range overlays, player/AI parity, logs, and battle snapshot lifecycle are connected.

## Authoritative Data

- `data/heroes/generated/hero_unique_skills.json`
- `data/heroes/generated/hero_battle_profiles.json`
- `data/heroes/generated/hero_base_stats.json`

Final momentum-cost distribution: `1 / 9 / 18 / 11`.
Final unit distribution: `11 / 10 / 11 / 4 / 3`.

## Protected Contracts

- Generated hero JSON remains the design authority.
- Save data may mutate loyalty, troops, status, injury, city, faction, and battle-result bookkeeping only.
- WorldMap and battle scenes must not redefine canonical stats, unit type, or unique skills.
- Existing T01–T05 city ownership, troop settlement, logistics, occupation, and result accounting remain protected.
- Sound remains the final polish stage.

## T06-10F Korea MVP Battle Cutin Integration

Status: `IMPLEMENTED / AUTHORITATIVE HERO ID RESTORED / 13-HERO CUTIN PARITY PASS / USER FULL BATTLE RE-QA PENDING`

- Korea MVP 13-hero F6 visual QA is recorded as passed. Their approved common presentation remains unchanged.
- `Battle_Land.tscn` now hosts the reusable component at `HeroCutinOverlay/HeroCutinViewport/HeroCutinPresentation` above battle UI. Its 1152×648 reference canvas centres the approved CutinStage without changing its internal authored transforms.
- Player and AI converge at the already-committed unique-skill sequence. The new presentation is selected only after resolver-plan validation and one successful momentum spend, then waits for `cutin_finished` before applying the existing resolver plan and existing action completion.
- A registry/resource/parity failure logs `[HERO_CUTIN]`, skips the presentation, and continues the existing unique-skill flow without refunding an already committed cost.
- T06-10F-hotfix1 removes the WorldMap compatibility path that rewrote authoritative runtime IDs to legacy demo IDs. `yi_sun_sin`, `jeong_do_jeon`, and `kim_yu_sin` now remain canonical through the battle context and exact registry lookup; the registry itself remains canonical and exact `hero_id`/`skill_id` parity is preserved.
- The static 13/13 parity validator confirms the generated authoritative skill data, registry IDs, OGV paths, and PNG paths. Direct headless `Battle_Land` launch still uses its no-WorldMap sample roster, so user F5 full battle re-QA must confirm `route=registry_video` for player and AI paths.
- Next: user F5 full battle re-QA, then T06-10G Legacy Battle Demo Registry & Dead Cache Cleanup Audit. T06-11 remains the later AI multi-unit engagement, surround, and cooperative-attack correction.

## Next Transaction

## T06-10H Post-Battle Garrison Hero Portrait Parity Recovery

Status: `IMPLEMENTED / POST-BATTLE GARRISON PORTRAIT PARITY PASS / USER OCCUPATION F5 RE-QA PENDING`

- Sabi's post-victory `?` portraits were traced to missing static portrait-path metadata for canonical Korea MVP records, not to combat result settlement or image files.
- City garrison rows continue to resolve the canonical `stationed_hero_ids` through the authoritative WorldMap hero registry, then overlay only runtime battle state. Portrait lookup now derives the existing production atlas path from canonical `hero_id` and faction metadata before legacy compatibility fallback.
- Automated canonical metadata + mutable-state round-trip and Texture2D validation passes for all 13 Korea MVP heroes; WorldMap/Battle loads and existing turn/occupation/save-load smoke also pass.
- Next: user F5 Gyeongju → Sabi victory/reselect/turn/save-load portrait QA. T06-11 AI multi-unit engagement remains subsequent scope.

T06-10A standalone Gwanggaeto cutin preview visual hotfix is implemented for comparison; user F6 visual QA is pending before any battle presentation connection. Correction-only QA for confirmed T06-8/T06-9 defects remains allowed.
