# P-1C-1 | ISO Battle Production Promotion Audit

Date: 2026-09-19
Branch: `refactor/production-runtime-unification-20260919`

## Executive finding

The latest accepted battle presentation is layered as:

```text
Battle_UI_Production_Imjin_IsoMovement_Test.tscn
  -> Battle_UI_Production_Imjin_Test.tscn
    -> Battle_UI_Production_Test.tscn
      -> BattleController / shared battle core
```

The newest ISO layer has **zero direct references to Imjin-only roster/portrait variables**, so its grid projection, overlays, facing UI, ready-frame retirement and visual-stability behavior can be promoted generically.

The Imjin controller itself mixes two responsibilities:

### Scenario fixture only — keep under tests
- Imjin roster slot -> hero-id mapping;
- Korea/Japan demo identity maps;
- Imjin-specific regular portrait stem overrides;
- demo-state rebinding to Yi Sun-sin / Toyotomi etc.;
- Imjin nation/visual/portrait resolution overrides.

### Generic runtime behavior — promote
- post-unique-skill manual reposition phase;
- optional reposition skip in full-auto;
- cutin input blocker synchronization;
- camera-bound overlay/status resync;
- safe active-ally camera focus after selection/handoff;
- generic status-display filtering/presentation behavior.

## Production HUD base

`tests/scenes/Battle_UI_Production_Test.tscn` is already the de-facto latest HUD scene:
- production top turn/momentum HUD;
- ally/enemy roster panels;
- roster collapse/portrait mode;
- battle log;
- current actor information HUD;
- top action buttons;
- production battle supply frame;
- command/facing/cutin/result layers.

It is still located under `tests/` and references four test scripts.

### Promote
- roster content bridge;
- current-actor/bottom-HUD binding;
- roster collapse + top action presentation.

### Replace
- `battle_supply_hud_mock.gd` must NOT ship.
- Real `BattleSupplyRuntime` already exists in the shared controller and is fed from WorldMap BattleContext.

## Real WorldMap handoff already exists in battle core

Shared battle controller already owns:
- `samwar_worldmap_battle_context` handoff;
- real WorldMap roster construction;
- battle title from actual attacker/target;
- `BattleSupplyRuntime`;
- food/salt/consumption/sustain/desertion;
- battle result payload;
- return destination;
- resume snapshot.

Therefore P-1C must preserve this authority and only promote presentation.

## P-1C implementation target

```text
scenes/battle/Battle_Main.tscn
  -> scenes/battle/Battle_Production.tscn
       root script: BattleIsoProductionController
```

Production scripts:
- `BattleProductionController`: shared generic behavior promoted out of Imjin test controller;
- `BattleIsoProductionController`: generic ISO presentation;
- production roster HUD controller;
- production current-actor HUD controller;
- production roster presentation controller;
- production camera handoff guard;
- production empty-status legend.

Production scene:
- copy accepted `Battle_UI_Production_Test` visual tree;
- replace test-script paths with production paths;
- remove supply mock;
- bind latest supply HUD to real shared BattleSupplyRuntime;
- use production CurrentActorInfoHud scene.

## Scope lock

P-1C must NOT:
- change combat formulas;
- change logical grid dimensions/path rules;
- change turn order;
- change WorldMap battle/result schema;
- change Imjin test fixture identities;
- switch WorldMap battle entry yet.

P-1D alone will switch:
`WorldMap.tscn -> scenes/battle/Battle_Main.tscn`.
