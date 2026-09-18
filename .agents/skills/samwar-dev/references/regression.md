# Regression & Validation Playbook

## Goal
Prove the changed surface is healthy with the least expensive validation that is sufficient for its risk. Full-repository proof is reserved for checkpoints and cross-system work.

## Level 1 — Fast / targeted
Use for narrow fixes, small edits, docs/config-only changes, and focused extractions with a known boundary.

Checks, when applicable:
1. Confirm target path/file.
2. Confirm the intended patch exists.
3. Run the established focused test/check for the changed behavior.
4. Inspect the scoped diff.

Stop here when these checks sufficiently cover the risk.

## Level 2 — Scoped regression
Use for medium multi-file refactors, changed call paths, scene/resource work, or nearby subsystem impact.

Checks, when applicable:
1. Run Level 1 checks.
2. Run the nearest relevant smoke/regression tests.
3. Run Godot parse/import/headless checks for affected scenes/resources.
4. Re-check affected resource paths and generated sidecars such as `.gd.uid`.
5. Review scoped worktree status for unintended changes.

Do not automatically run unrelated full-project regression or CI.

## Level 3 — Full checkpoint
Use for integration/merge readiness, WorldMap↔Battle boundary changes, persistence/schema changes, milestone closeout, release readiness, or an explicit full-green request.

Checks, when applicable:
1. Record branch and HEAD.
2. Inspect status and diff.
3. Run targeted tests.
4. Run the established broader/full test suite.
5. Run relevant Godot parse/import/headless checks.
6. Re-check status after tests/imports.
7. Investigate newly generated files and resource-reference changes.
8. Confirm no unintended files or edits remain.
9. Verify branch/upstream relationship.
10. Verify the latest relevant CI/GitHub Actions run.

## Duplicate-work guard
- Reuse valid evidence from the same unchanged work unit.
- Do not rerun an identical expensive suite when no relevant code/resource state changed after it passed.
- After a small follow-up fix, rerun the affected targeted check first.
- Escalate only when the follow-up invalidates prior broader evidence.
- Documentation or warning-only cleanup does not by itself require a new full-regression/CI cycle.

## Failure classification
When something fails, classify it:
- code/test failure
- scene/resource/reference failure
- generated-file/worktree cleanliness failure
- CI/environment-only failure
- branch/upstream mismatch

Do not call a non-code failure "just CI" without proving the code path is unaffected.

## Full-green criteria
Use "Full Green" only for Level 3 when all required checkpoint checks pass, the repository state is clean/understood, and the relevant remote CI state is successful.
