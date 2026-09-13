# WorldMap Trade Controller Extraction Audit

Baseline: `b51f95f868aa7bda891895ac29eb0730d0b15428`

## Ownership classification

- Controller: validation context collection, source/target and diplomacy boundary queries, manual-order storage/lifecycle, result mirror, persistence normalization and restore/sync.
- Service: validation rules, preview and price/efficiency arithmetic, storage delta application, execution result.
- Presenter: manual-order, preview, result, market-price, and trade-control text models.
- Main thin bridge: Controller/Presenter construction, Coordinator injection, UI node/signal wiring, generic save/load entry, auto-trade compatibility calls.
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

## Deliberate boundaries retained

- Internal/chancellor/inter-faction auto-trade remains the existing economy/turn subsystem; it consumes Controller efficiency/cost queries.
- Generic city storage read/write and market snapshot generation remain on the WorldMap economy/city host and are exposed through explicit Controller adapters.
- Diplomacy owns agreement creation, duration, expiry, relation state, and multipliers; Trade only queries the existing boundary.
