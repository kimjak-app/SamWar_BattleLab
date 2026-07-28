# CURRENT STATE

## Baseline

- Repository: `kimjak-app/SamWar_BattleLab`
- Branch: `main`
- T01 through T05 Korea Four-City MVP are complete and protected.
- T06 hero stat, loyalty, battle-profile, and runtime-authority integration QA passed.
- Orphan `hero_worldmap_stat_integration.gd` and `hero_battle_design_invocation.gd` paths were removed.
- T06–T07 single-authority architecture is documented in `docs/T06_T07_PRE_IMPLEMENTATION_ARCHITECTURE_AUDIT.md`.

## Latest Implemented Transaction

### T06-7 Hero Unique Skills & Shared Momentum

Status: `IMPLEMENTED / RUNTIME STATIC VALIDATION PASS / GODOT QA PENDING`

- Side-shared momentum: start `3`, cap `10`, successful basic attack `+1`.
- Valid resolver commit spends canonical per-hero cost; cancel/invalid/rejected execution spends `0`.
- All 39 canonical skill effect types normalize to ten data-driven execution archetypes.
- Player and AI use the same `BattleSkillResolver` and the same shared resource rules.
- Top-bar momentum labels, per-hero cost button/tooltip, effect/spend/gain/failure logs are connected.
- Battle runtime snapshot persists units, statuses, phase, round, momentum, cooldowns, action locks, reinforcement flags, active unit, and log.
- Matching battle IDs auto-restore; completed WorldMap return clears the snapshot.
- Runtime validator and 39-skill/momentum/snapshot GDScript smoke were added.

Transaction record:

- `agent/transactions/T06_7_HERO_UNIQUE_SKILLS_SHARED_MOMENTUM.md`

## Previous Completed Correction Transaction

### T06 Hero Final Balance Data Sync

Status: `IMPLEMENTED / STATIC DATA QA PASS`

Official workbook:

- `삼국WAR_장수39명_기세비용_1-4_5병종_최종확정본.xlsx`

Authoritative generated data:

- `data/heroes/generated/hero_unique_skills.json`
- `data/heroes/generated/hero_battle_profiles.json`

Final momentum-cost contract:

- cost 1: 1 hero
- cost 2: 9 heroes
- cost 3: 18 heroes
- cost 4: 11 heroes
- action cost: 1
- HP activation condition: unused / null
- momentum ownership: side-shared battle resource

Final unit distribution:

- infantry: 11
- cavalry: 10
- archer: 11
- gunner: 4
- mounted_archer: 3

Final corrections:

- `kim_chun_chu`: infantry
- `uija_wang`: infantry
- `toyotomi_hideyoshi`: infantry
- `support` is permitted as a battle role only and forbidden as `unit_type`.

Validator lock:

- `tools/validate_hero_design_registry.py`
- momentum cost must be integer 1..4
- momentum distribution must remain 1/9/18/11
- unit distribution must remain 11/10/11/4/3
- support unit type is rejected
- action cost remains 1 and HP condition remains null

Transaction record:

- `agent/transactions/T06_HERO_FINAL_BALANCE_DATA_SYNC.md`

## Protected Contracts

- `hero_unique_skills.json` is the unique-skill design authority.
- `HeroDesignDataRegistry -> HeroRuntimeFactory -> BattleUnit payload -> BattleSkillResolver` remains the required runtime direction.
- No UI polling, Label scanning, setter-owned design authority, or dual-source fallback.
- Current loyalty remains mutable save-owned runtime state.
- WorldMap city/faction/troop/settlement behavior and BattleContext result accounting remain protected.
- Sound remains the final polish stage.

## Next Transaction

Run Godot headless/F6 QA for T06-7, fix only confirmed runtime/visual defects, then proceed to missing 39-hero cutin asset production and presentation comparison.
