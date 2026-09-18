# SamWar Shared AI Development Protocol

This is the canonical development protocol for **both ChatGPT (채코치)** and **Codex** when working on SamWar.

## Operating model
- The user describes the engineering goal in natural language.
- The assistant/agent infers the correct workflow; the user should not need to remember skill names.
- Use the repository router at `.agents/skills/samwar-dev/SKILL.md` and the referenced playbooks as the execution standard.
- ChatGPT should consult this protocol and the router whenever it performs or directs substantial SamWar engineering work through the repository.
- Codex should follow the same protocol through `AGENTS.md` and the repository skill.
- Validation is risk-proportional: choose the lowest sufficient level and escalate only when the changed surface requires it.

## Shared workflow
1. Analyze the requested work and classify it.
2. Assign or infer a short work ID/title.
3. Run full preflight once for the coherent work unit: branch, HEAD, upstream, worktree, target paths, validation commands, and recoverability as applicable.
4. Execute the relevant refactor/integration/scene-resource workflow.
5. Verify the actual patch in the target files.
6. Select validation level:
   - Level 1: targeted verification for narrow changes.
   - Level 2: targeted + nearest relevant regression for medium/local subsystem changes.
   - Level 3: full regression + repository/CI checkpoint checks for integration, cross-system, milestone, release, or explicit full-green work.
7. Do not rerun identical expensive checks unless relevant code/resource/repository state changed after the prior pass.
8. Confirm the exact final version being reported at the level required by the task.
9. Report only the branch/HEAD/worktree/CI details relevant to the selected validation level and the single best next step.

## Shared completion rule
Neither ChatGPT nor Codex may claim `done`, `complete`, or `Full Green` beyond the evidence actually gathered.

- Level 1/2 may be reported as scoped verification complete.
- `Full Green` is reserved for Level 3 when all required checkpoint validation corresponds to the exact final state being reported.

## Source of truth
If these instructions conflict with an older chat summary, prompt fragment, or ad-hoc checklist, this repository protocol wins for SamWar engineering work.
