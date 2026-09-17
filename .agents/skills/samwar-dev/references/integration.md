# Integration Playbook

## Goal
Combine known-good work from branches/features without losing working behavior.

## Steps
1. Identify source branch(es), target branch, and exact desired feature set.
2. Confirm each source's latest known-good checkpoint/commit when available.
3. Create or use a dedicated integration branch when conflicts or risk are non-trivial.
4. Prefer selective cherry-pick/file-level integration when full merge would pull unrelated work.
5. Resolve conflicts by preserving behavior, not merely making text merge.
6. Verify binary/resource assets separately from code.
7. Check Godot scene/resource paths after integration.
8. Run targeted tests for each integrated feature.
9. Run full regression.
10. Compare final branch against sources to ensure no required files were omitted.

## Godot-specific checks
- `.tscn`, `.tres`, `.gd`, WAV/OGG, images, imported resources
- `res://` references
- generated UID/import files
- project settings or autoload changes

## Guardrails
- Never destroy the original source branches as part of integration.
- Do not force a merge when a clean integration branch is safer.
- Treat missing binary assets as an incomplete integration even if code tests pass.
