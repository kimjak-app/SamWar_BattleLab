# SamWar Shared AI Development Protocol

This is the canonical development protocol for **both ChatGPT (채코치)** and **Codex** when working on SamWar.

## Operating model
- The user describes the engineering goal in natural language.
- The assistant/agent infers the correct workflow; the user should not need to remember skill names.
- Use the repository router at `.agents/skills/samwar-dev/SKILL.md` and the referenced playbooks as the execution standard.
- ChatGPT should consult this protocol and the router whenever it performs or directs substantial SamWar engineering work through the repository.
- Codex should follow the same protocol through `AGENTS.md` and the repository skill.

## Shared workflow
1. Analyze the requested work and classify it.
2. Assign or infer a short work ID/title.
3. Preflight branch, HEAD, upstream, worktree, target paths, and recoverability.
4. Execute the relevant refactor/integration/scene-resource workflow.
5. Verify the actual patch in the target files.
6. Run targeted and broader regression checks as applicable.
7. Verify generated Godot artifacts such as `.gd.uid`, resource paths, and worktree cleanliness.
8. Confirm the exact final version being reported.
9. Report branch, HEAD, tests, worktree, CI status, and the single best next step.

## Shared completion rule
Neither ChatGPT nor Codex may claim `done`, `complete`, or `Full Green` unless the required validation corresponds to the exact final state being reported.

## Source of truth
If these instructions conflict with an older chat summary, prompt fragment, or ad-hoc checklist, this repository protocol wins for SamWar engineering work.
