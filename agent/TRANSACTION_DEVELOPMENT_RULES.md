# TRANSACTION DEVELOPMENT RULES

## Definition

A transaction is one player action completed end-to-end: **start, validation, cost handling, state mutation, UI refresh, failure handling or rollback, save, and finish**. It may span multiple files and systems, but it has one user-visible outcome.

## Completion Standard

Internal functions, helpers, or a screen alone do not complete a transaction. Completion means a player can perform the action in the actual game from its start state to its persisted end state, including clear failure behavior.

## Work Size

Appropriate transactions include new-game faction selection, invasion and occupation, defense, and turn resolution. A variable addition, helper extraction, or formatter move is too small; implementing the whole Korea MVP as one task is too large.

## QA

- Run focused automated checks while working.
- Run integrated human F6 QA at transaction completion when runtime behavior changes.
- Do not create a separate Manual QA Complete Lock for every helper.
- Record acceptance tests and QA outcomes in the transaction document; move completed evidence to archive review later.

## Tech-Tree Connection Rule

Every major transaction specification records: related technologies, before-tech state, unlock conditions, after-tech state, numeric effects, AI application, UI indication, and save impact. Unknown implementation evidence is marked `Needs Runtime Audit`; do not invent values.

## Documentation Rule

- Do not make separate Plan, Audit, Handoff, QA, and Complete Lock documents for small work.
- Keep one active document per transaction in `agent/transactions/`.
- After completion, make it an archive candidate instead of leaving it in default session context.
- Update a dedicated contract only when a protected cross-system contract changes.
