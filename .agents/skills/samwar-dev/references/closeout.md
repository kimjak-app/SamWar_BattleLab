# Task Closeout Playbook

## Goal
End a work unit with an exact, reproducible state.

## Checklist
1. Confirm the intended patch is present in the target files.
2. Confirm validation results correspond to the current HEAD.
3. Confirm branch name and HEAD SHA.
4. Confirm worktree status.
5. Confirm upstream/remote relationship when applicable.
6. Confirm latest relevant CI run if completion depends on CI.
7. Report any remaining known risk honestly.
8. Recommend only the next highest-value task.

## Final report template
**Work**: <ID/title>  
**Result**: <what changed>  
**Verification**: <targeted + full checks>  
**Git**: <branch>, <HEAD>, <worktree/upstream>  
**CI**: <run/status or not required>  
**Next**: <single best next step>

## Language rule
Never report "done", "complete", or "Full Green" from memory, assumption, or an earlier commit. The verification must match the exact final version being reported.
