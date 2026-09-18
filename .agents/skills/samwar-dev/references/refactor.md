# Refactor Playbook

## Goal
Separate responsibilities without changing observable behavior.

## Steps
1. Map the current call graph and responsibility boundaries.
2. Identify the smallest coherent unit to extract.
3. Define the destination layer:
   - UI: presentation/input only
   - Coordinator: sequencing/orchestration
   - Service: domain/application logic
   - Data/model: state and persistence structures
4. Preserve public behavior and existing failure/cancel paths.
5. Move functions in small groups.
6. Replace callers before deleting old implementations.
7. Search for duplicate or stale call sites.
8. Add/update tests around moved logic.
9. Select the validation level by risk. Default to focused targeted validation; add nearby regression for medium call-path impact; use full regression only for cross-system or checkpoint work.
10. Inspect diff for accidental churn.

## Guardrails
- Do not mix unrelated cleanup into the refactor.
- Do not rename large surfaces unless needed for the extraction.
- Do not silently change return values, signals, state transitions, or error handling.
- Keep a recoverable checkpoint before a large move.
- Do not rerun full preflight or full regression after every extraction slice when the branch/scope and prior evidence remain valid.
