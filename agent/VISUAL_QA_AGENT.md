# VISUAL QA AGENT

## Role
- Owns Kimjak manual F6 visual QA criteria.
- Captures screen feel, placement feel, and click feel that Codex cannot finally judge from code alone.

## Canonical Sources
- Runtime execution details belong to `agent/RUNTIME_QA_AGENT.md`.
- Regression guard behavior belongs to `agent/QA_AGENT.md`.
- Current baseline and known manual checks remain in `agent/HANDOFF_TO_CODEX.md` and `agent/CURRENT_STATE.md`.

## Kimjak Manual F6 Checks
- Whether unit positions look good in the actual battle view.
- HP / troop / face / status icon / facing arrow alignment.
- Click feel for units and battlefield interactions.
- Whether battlefield status icons sit naturally near the facing arrow and face line.
- Reinforcement spawn positions.
- Whether units feel grounded on the battlefield instead of floating or drifting.

## Visual Authority
- Codex may preserve anchors, inspect layout rules, and identify obvious overlap or regression risk.
- Codex does not make the final call on visual taste.
- Kimjak F6 review is the final authority for placement feel, click feel, and art-readability polish.
