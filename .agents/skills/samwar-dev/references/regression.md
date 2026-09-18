# Regression & Validation Playbook

## Goal
Prove the current branch is actually healthy and catch repository-state failures, not just code failures.

## Steps
1. Record current branch and HEAD.
2. Inspect status and diff before running tests.
3. Run the repository's established targeted tests.
4. Run the established broader/full test suite.
5. Run Godot parse/import/headless checks used by the project, if available.
6. Re-check status after tests/imports.
7. Investigate newly generated files, especially `.gd.uid` and import sidecars.
8. Confirm no unintended files or edits are left.
9. If CI is part of the task, verify the latest relevant GitHub Actions run.
10. Confirm remote/upstream HEAD relationship when declaring final green.

## Failure classification
When something fails, classify it:
- code/test failure
- scene/resource/reference failure
- generated-file/worktree cleanliness failure
- CI/environment-only failure
- branch/upstream mismatch

Do not call a non-code failure "just CI" without proving the code path is unaffected.

## Full-green criteria
Use "Full Green" only when all required checks for the task pass, the repository state is clean/understood, and the relevant remote CI state is successful.
