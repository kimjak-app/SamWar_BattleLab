# Battle event schema v0 — S1-1 observation baseline

## Ownership and API

`BattleEventLogService` is a RefCounted value collector. It does not call the controller, mutate units, schedule work or emit engine signals. S1-1 uses it only in the observation harness. Production integration is deferred to S1-2.

- `clear()` empties the log and resets the next sequence to 0.
- `emit(kind, fields)` validates, stores a deep copy, and returns a separate deep copy.
- `export()` returns a deep copy of the complete log.
- Invalid input returns `{}` without appending or consuming a sequence number.

Every accepted event adds `schema_version: 0`, `sequence: int` (first event 0, then +1), and `kind: String`. Callers supply only the fields below; extra/missing keys, including attempts to supply common fields, are rejected.

## Four supported kinds

| Kind | Required caller fields |
|---|---|
| `unit_moved` | `unit_id`, `from`, `to`, `path`, `movement_kind`, `facing_before`, `facing_after`, `flags_before`, `flags_after`, `last_action_after` |
| `facing_changed` | `unit_id`, `from`, `to`, `reason` |
| `move_confirmed` | `unit_id`, `restored_fields` |
| `move_reverted` | `unit_id`, `restored_fields` |

`unit_id` is a nonempty string. Cells are two-element integer arrays `[x,y]`. A movement path contains the starting cell, at least two cells, and ends at `to`; the service validates representation, not terrain/path legality. `movement_kind` is `normal`. Facings are `left/right/up/down`. Each flags dictionary contains only `has_moved: bool`. `last_action_after` is a deep-copied JSON-compatible dictionary.

For `facing_changed`, `from/to` are facing strings and `reason` is `step` or `manual`. Confirmation uses `restored_fields: []`. Reversion uses exactly `["grid_cell", "facing", "has_moved", "ally_has_moved"]` in that order. **`last_action` is not restored by the current controller and must not be claimed as restored.**

Accepted values recursively comprise null, bool, int, finite float, String, Array and string-keyed Dictionary. Objects, vectors and other Variant types are rejected. The original S1-1 scope introduced no attack/damage/turn kinds or action/event IDs; the additive S2-2 extension is specified below.

## Fingerprint semantics

`BattleStateFingerprintService.fingerprint_units` copies every `PROPERTY_USAGE_SCRIPT_VARIABLE` from the supplied units in their original order; nested arrays/dictionaries are copied and Vector2i becomes `[x,y]`. All 40 current unit script variables are included (the test counts this dynamically). No current unit variable is excluded. A null slot is represented as `{"_null_unit":true}`.

`diff` returns deterministic field paths. Dictionaries are traversed in sorted key order; the outer unit array reports indexed paths, e.g. `units[2].grid_cell`. Nested arrays are compared recursively but differences are reported at the owning field (a cell is one field). JSON's integral floats compare equal to their int originals; booleans remain distinct. This is a snapshot of current unit value fields, not a general serializer for future Object-valued properties.

## Observation harness boundary

Battle_Main is dynamically loaded after the runner's deferred `_run`. Actual selection, destination validation, Tween movement, FACING_SELECT, facing confirmation and right-click cancellation run through existing controller calls. The harness never calls the movement completion callback directly.

Events in the golden are **observations assembled by the test**, not events emitted by production. Facing changes are observed between frames, unit_moved after reaching FACING_SELECT, and confirmation/reversion after their real calls. The test checks authoritative unit state plus `ally_has_moved`, `has_pending_move_snapshot`, `current_phase`. It does not claim sub-frame callback tracing or production event wiring.

The fixture retains real unit IDs, skills, numerical combat data and deployment policy. It arranges the ten slot-ordered units at deterministic cells, resets action flags, sets the mover at `[2,2]` facing left, gives it move_range 6 for a four-step detour, and seeds `last_action` with a sentinel. This preparation precedes every initial snapshot. No authoritative state is written to simulate observed outcomes.

Excluded from comparison: presentation nodes/instance IDs, pixel/camera positions, wall-clock timestamps, frame counts, audio/Tween objects and random-generator internal state. These are not BattleUnitState script variables. All unit cells, facing, flags, last_action and numerical fields remain included. The three listed controller fields are deliberately a scoped projection, not a full controller serialization. No nondeterministic unit field was removed.

Before freeing each scene the harness drains camera handoff frame waits and its 0.06-second timer, then uses the existing audio cleanup pattern. This only affects teardown, after captured checkpoints.

## Reproduction

After headless editor import, run:

```text
godot --headless --path . --script tests/scripts/test_battle_event_log_service.gd
godot --headless --path . --script tests/scripts/test_battle_state_fingerprint_service.gd
godot --headless --path . --script tests/scripts/test_battle_move_oracle_baseline.gd
```

Only intentional regeneration uses `-- --update-golden` on the oracle command. Every run executes seven cases twice, stopping on controller failure or nondeterminism. Default execution never writes the golden. The validator is a stage-specific S1-1 scope guard relative to `62f5b72`, not a permanent allowlist for later refactor stages.

## S2-2 additive attack/action extension

Existing four movement kinds and schema_version 0 remain unchanged.

| Kind | Exact required caller fields | Production source |
|---|---|---|
| `attack_resolved` | `attacker_id`, `target_id`, `angle_type`, `damage_requested`, `damage_applied`, `troops_before`, `troops_after`, `target_defending`, `killed` | Ally request: immediately after existing damage, attack contract, and conditional momentum writes, before target visual refresh |
| `action_completed` | `unit_id` | Ally basic attack finish, after existing `_mark_ally_unit_acted` (including status consumption), before closeup/cleanup |
| `unit_defeated` | `unit_id` | Shared cleanup: first dead-ID registration and action-lock erase, before defeat log; once per ID per registry lifetime |

IDs are nonempty Strings; angle is `front`, `side`, or `back`. Damage/troop values are ints (bools/floats rejected); defending/killed are bools. `damage_requested` preserves the supplied value; the existing unit model clamps applied damage. `damage_applied` is the model's HP-capped return, which may differ from troop loss. `killed` describes post-damage `is_alive()` and does not mean cleanup/turn progression already happened. Payloads contain no unit references.

`BattleAttackStateService` writes the original unit state and returns the attack value payload. `battle_action_event_log` stores copied values only; no synchronous signal or controller callback is emitted. It is separate from `ally_move_event_log`; sequence numbers are local to each log and reset on `clear()`/new instance. Current S2-2 attack/action events cover ally basic attacks only; shared death events can also describe deaths during other actions, including the automatic enemy slot. Enemy attacks/movement/turn events remain M3. Clear/consumption and restart ownership must be wired by subsequent stages; no resume schema is added.
