# WorldMap Trade Controller Extraction Audit

Phase 1 baseline: `b51f95f868aa7bda891895ac29eb0730d0b15428`

Phase 2 baseline: `6781cd814ffcb3d310b2e72621d8a59db509064b`

## Ownership classification

- Controller: validation context collection, source/target and diplomacy boundary queries, manual-order storage/lifecycle, result mirror, persistence normalization and restore/sync.
- Service: validation rules, preview and price/efficiency arithmetic, storage delta application, execution result.
- Presenter: manual-order, preview, result, market-price, and trade-control text models.
- Main thin bridge: Controller/Presenter construction, Coordinator injection, UI node/signal wiring, generic save/load entry, turn-auto-trade compatibility call, and internal-transfer compatibility calls.
- Cross-domain: trade-agreement and relation state remain Diplomacy-owned; city storage and market generation remain city/economy-owned.
- Frozen: Spy production and Military/battle handoff.

## Production flow

`WorldMapMain -> WorldMapActionCoordinator -> WorldMapTradeController -> WorldMapTradeActionService`

The Coordinator no longer preloads or constructs the Trade service. The Controller is its only owner and is the production host passed to the Service. The Service has no `worldmap_main.gd` helper calls or direct access to `_player_state` / `_manual_trade_orders`.

## Removed from WorldMapMain

- External manual trade legacy executor.
- External manual validation and preview rules.
- Import/export price and delta rules (only thin auto-trade compatibility bridges remain).
- Manual-order payload/item and trade-result normalization implementations.
- Manual preview, order, execution-result, and market-price formatting implementations.

## Phase 2 ownership

- `WorldMapTradeAutomationService`: chancellor eligibility, trade-mode eligibility, city/resource priority, shortage/surplus selection, caps, external candidate ranking, price/efficiency interpretation, storage deltas, and result construction.
- `WorldMapInternalTradeTransferService`: source/target/ownership/connectivity/resource/amount/stock validation, conserved source/target storage mutation, and result construction.
- `WorldMapTradeController`: sole owner of all three Trade services and their production adapter; it bridges generic player, hero, city graph, city storage, market, and Diplomacy-owned trade relation data.
- `worldmap_main.gd`: retains only the generic world-turn entry and compatibility wrappers for automatic and internal trade execution. It does not implement either ruleset.

The two Phase 2 services receive only `WorldMapTradeController` in production. Neither service stores or calls the giant main host directly.

## Deliberate boundaries retained

- Generic inter-faction passive trade income remains the existing economy/turn subsystem; Phase 2 does not move that non-chancellor shared-economy flow.
- Generic city storage read/write and market snapshot generation remain on the WorldMap economy/city host and are exposed through explicit Controller adapters.
- Diplomacy owns agreement creation, duration, expiry, relation state, and multipliers; Trade only queries the existing boundary.
- No Trade UI, warehouse UI, result popup, or gameplay function was restored or added.
