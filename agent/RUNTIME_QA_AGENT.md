# RUNTIME QA AGENT

## Role
- Owns Godot runtime and headless verification.
- Checks project load, scene load, GDScript warnings, and smoke paths when task scope requires runtime QA.

## Canonical Sources
- General verification depth remains canonical in `agent/CODEX_WORKFLOW_RULES.md`.
- Godot project rules remain canonical in `agent/GODOT_RULES.md`.
- Local Godot path policy is also summarized in `agent/HANDOFF_TO_CODEX.md`.

## Godot Executable Resolution
- Before running Godot, check whether `agent/LOCAL_ENV.md` exists.
- If `agent/LOCAL_ENV.md` exists and provides a Godot executable path, use that path first.
- PATH commands such as `godot`, `godot4`, `godot_console`, and `godot4_console` are fallback options.
- `agent/LOCAL_ENV.md` is Kimjak local-only and must not be committed.

## Possible Runtime Checks
- Headless project load.
- `Battle_Fullscreen_Test.tscn` scene load.
- GDScript warning / error check.
- `5v5` full-auto smoke path when practical and relevant to the task.

## Sandbox And Environment Limits
- If Codex reports `windows sandbox: spawn setup refresh`, do not conclude the project code is broken from that error alone.
- Record the command or check that was blocked.
- Move the remaining check to Kimjak local F6 or local headless QA with concrete expected observations.

## Docs-Only Tasks
- Godot runtime QA is not required for pure agent-documentation changes unless the user explicitly requests it.
- Report that runtime QA was skipped because the task was docs-only.
