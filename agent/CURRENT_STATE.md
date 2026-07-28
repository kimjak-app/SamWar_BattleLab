# CURRENT STATE

## Baseline

- Repository: `kimjak-app/SamWar_BattleLab`
- Branch: `main`
- T01 through T05 Korea Four-City MVP are complete and protected.
- T06 hero stat, loyalty, battle-profile, and runtime-authority integration QA passed.
- Orphan `hero_worldmap_stat_integration.gd` and `hero_battle_design_invocation.gd` paths were removed.
- T06–T07 single-authority architecture is documented in `docs/T06_T07_PRE_IMPLEMENTATION_ARCHITECTURE_AUDIT.md`.

## Latest Completed Correction Transaction

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

Implement one complete playable shared-momentum and unique-skill mechanic transaction from the locked 39-hero data:

- side-shared momentum state and gain/loss rules
- skill availability and per-hero cost display
- valid-target commit and no-charge cancel/failure contract
- archetype normalization and `BattleSkillResolver`
- actual effect application and battle log/UI evidence
- AI skill evaluation under the same resource rules
- save/resume safety where battle state requires it
- validators, automated tests, Godot F5 QA, agent docs, commit/push

Do not split the delivery into helper-only milestones and do not reintroduce flat skill costs or a support unit type.
