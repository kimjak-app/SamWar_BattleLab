# CURRENT STATE

## Baseline

- Branch: `main`
- T01 through T05 Korea Four-City MVP are complete and protected.
- T06-0 legacy hero registry extraction is complete.
- T06-1 39-hero data contract is locked.
- T06-2 generated JSON pipeline is present.
- T06-3 design loader/parity QA passed.
- Hero Battle Profile Integration implementation is present; its final integrated regression remains part of current QA.

## Active Transaction

### T06 Hero Stats, Initial Loyalty & WorldMap UI Integration

Status: `IMPLEMENTED / USER GODOT QA PENDING`

Official workbook:

- `삼국WAR_장수39명_능력치_초기충성도_통합최종본.xlsx`

Authoritative generated data:

- `data/heroes/generated/hero_base_stats.json`
- `data/heroes/generated/hero_initial_loyalty.json`

Runtime integration:

- `scripts/worldmap/hero_design_data_registry.gd`
- `scripts/worldmap/hero_worldmap_stat_integration.gd`
- `project.godot` Autoload: `HeroWorldMapStatIntegration`
- `tools/validate_hero_worldmap_stat_integration.py`
- `agent/transactions/T06_HERO_WORLDMAP_STATS_LOYALTY_INTEGRATION.md`

Implemented behavior:

- 39 fixed stat records regenerated from the final workbook.
- New-game seed registry receives final `leadership`, `martial`, `intelligence`, `politics`, and `initial_loyalty`.
- Compatibility aliases remain populated: `leadership/command`, `martial/war`.
- Runtime fixed stats migrate to the final contract.
- Existing runtime/save `loyalty` remains mutable and is preserved.
- New-game `loyalty` begins from `initial_loyalty`.
- WorldMap hero labels are normalized to:

```text
지휘 99 / 무 88 / 지 96 / 정 78 / 충 100
```

- The formatter applies to generated hero-card labels, including hero list/detail/deployment surfaces that use the existing stat-line pattern.

## QA Gate

Run:

```bash
python tools/validate_hero_design_registry.py
python tools/validate_hero_battle_profile_integration.py
python tools/validate_hero_worldmap_stat_integration.py
```

Then Godot 4.6 F5:

1. Start a new game.
2. Confirm the hero list shows five values and matches the final workbook.
3. Confirm hero detail and invasion/defense deployment screens use the same format.
4. Save/load and confirm current loyalty is preserved.
5. Enter/return from battle and confirm Battle profile movement/range still works.
6. Confirm no new parse error or warning.

Representative expected values:

- 이순신: `지휘 99 / 무 88 / 지 96 / 정 78 / 충 100`
- 정도전: `지휘 65 / 무 38 / 지 97 / 정 99 / 충 96`
- 권율: `지휘 91 / 무 86 / 지 84 / 정 70 / 충 97`
- 척준경: `지휘 82 / 무 100 / 지 52 / 정 35 / 충 82`

## Protected Contracts

- Current loyalty is runtime state and remains save/load-owned.
- Initial loyalty must never reset an already changed saved loyalty.
- WorldMap city/faction/troop/settlement behavior remains unchanged.
- BattleContext and battle return remain unchanged.
- Role passives, momentum, new unique-skill execution, AI skill use, VFX, and sound remain deferred.
- Sound remains the final polish stage.

## Next Gate

After static validation and user Godot QA pass, Complete Lock this entire stats/loyalty/UI integration. The next transaction should be a complete playable mechanic set, not another helper-only step.
