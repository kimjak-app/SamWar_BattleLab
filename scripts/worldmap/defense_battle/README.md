# Defense Battle

Purpose:
- v0.71 refactor destination for Defense / Battle helpers extracted from the active worldmap script.

Allowed later:
- Battle modifier helpers.
- Defense summary helpers.
- Read-only deployment labels or command-limit helpers.
- Small, verified extraction steps only.

Not allowed yet:
- Moving BattleContext creation functions early.
- Changing battle formulas.
- Changing BattleContext schema or pending invasion payloads.
- Changing scene node paths or script paths.

Current status:
- Contains `defense_battle_helpers.gd` as of v0.71-07.
- First batch only includes pure formatter / lookup helpers.
- No existing runtime script was moved here in v0.71-07.
