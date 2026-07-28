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

## Next Transaction

T06-10A standalone Gwanggaeto cutin preview is implemented for visual comparison; user F6 visual QA is pending before any battle presentation connection. Correction-only QA for confirmed T06-8/T06-9 defects remains allowed.
