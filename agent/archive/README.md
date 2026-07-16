# Archive Policy

`agent/archive/` holds completed historical documents so they no longer occupy active session context. Archive is not deletion, and archived documents are not default reading.

The next Documentation Cleanup Transaction may move confirmed completed documents here while retaining Git history. Prefer version- or domain-oriented folders, for example:

```text
agent/archive/
├─ v0_70/
├─ v0_71_refactor/
├─ v0_72_battle_refactor/
├─ qa/
└─ superseded/
```

This transaction performs no bulk move. Evaluate each move for unique contract value first.
