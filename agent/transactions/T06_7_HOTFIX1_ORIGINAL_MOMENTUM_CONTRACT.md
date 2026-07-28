# T06-7-hotfix1 Original Momentum Contract Restoration & Final Hero Data Parity

## Status

`IMPLEMENTED / STATIC VALIDATION TARGET / USER GODOT F5 QA PENDING`

## Final Momentum Contract

- side-shared momentum
- start `3`, cap `10`
- completed round: both sides `+1`
- successful basic attack: attacker side `+1`, defending side `-1`
- cooperative hit: defending side total `-2` per attack transaction
- damaging unique skill: defending side total `-2` per resolver execution, regardless of target count
- zero floor and ten cap
- selection/cancel/invalid/rejected execution costs `0`
- valid committed unique skill spends exactly once; no post-commit refund

## Final Data Locks

- momentum cost distribution: `1 / 9 / 18 / 11`
- unit distribution: `11 / 10 / 11 / 4 / 3`
- Kim Chun-chu, Uija Wang, Toyotomi Hideyoshi: `infantry`
- `support`: role-only, forbidden as `unit_type`

## QA

Run all Python validators and the T06-7 Godot smoke, then F5 verify visible 3/10 momentum, round gain, attack gain/loss, special-hit total loss, skill costs, AI parity, and save/resume.
