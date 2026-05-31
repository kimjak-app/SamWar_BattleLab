# CONFIRMED LOYALTY PUBLIC SUPPORT DESIGN

## Status
- Confirmed design lock for `v0.69-0 EASTWAR Strategic Simulation Foundation Roadmap Lock`.
- This document is design-only. No public support, loyalty, security, recruitment, revolt, troop movement, UI, save/load, battle, invasion, or defense implementation is included in this task.

## Core Separation
- `publicSupport` means livelihood and domestic stability: food, tax pressure, safety, economic confidence, and local administration.
- `loyalty` means voluntary military commitment: willingness to serve, remain mobilized, accept troop movement, and endure campaign burden.
- `security` means public order and coercive stability: it affects both `publicSupport` and `loyalty`.

## Top-Level Principle
- Public support is not a renamed loyalty value.
- Loyalty is not a renamed morale value.
- Security is the bridge pressure variable that can protect stability or reveal unrest.
- v0.69 systems should treat public support and loyalty as separate strategic axes.

## Intended v0.69 Flow
1. Public support MVP establishes city-level livelihood and domestic stability.
2. Seasonal loyalty derives part of its pressure from public support.
3. Troop movement uses loyalty efficiency as a military-operation constraint.
4. Recruitment and conscription consume the public support / loyalty distinction.
5. Revolt warning uses public support, loyalty, and security as the foundation.

## Deferred
- Final UI/UX information architecture is deferred until after the v0.69 core strategic logic exists.
- No formulas are changed by this document.
