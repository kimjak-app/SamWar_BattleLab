# T06-10I Unique Skill Korean Effect Display Full Audit & GDScript Warning Cleanup

## Status

`IMPLEMENTED / UNIQUE SKILL KOREAN DISPLAY PASS / GDSCRIPT WARNING CLEAN / USER F5 RE-QA PENDING`

## QA result and root cause

- T06-10H post-battle garrison portrait F5 QA is recorded as PASS.
- Jang Bo-go (`naval_team_buff`) could emit `momentum_gain_up`; Gwanggaeto (`team_mobility_buff`) could emit `flank_damage_up` and `momentum_gain_up`; Uija Wang (`aoe_debuff`) could emit `accuracy_down` and `momentum_gain_down`. These resolver status IDs were absent from the previous display map, which returned the internal English key directly.
- Production audit source is `data/heroes/generated/hero_unique_skills.json`: 39 unique-skill entries, 36 effect types. Internal IDs remain unchanged.

## Display contract

- `BattleUITextFormatHelper` is now the shared Korean display-name layer for production unique-skill effects, status effects, and user-visible resolver failure reasons.
- Battle resolver status floating text, status summaries/tooltips, and result battle-log summaries use the shared formatting. The battle log now renders skill name plus a Korean effect label before its existing hit/status/heal counts.
- All registered production effects and resolver-produced statuses have Korean strings. Unknown effect/status/failure IDs resolve to safe Korean generic labels (`추가 효과`, `특수 상태`, `실행 조건 미충족`) rather than exposing an internal English ID.
- No internal ID, skill data, calculation, effect plan, momentum value/cost, AI decision, cutin, portrait, or save schema changed.

## Warning cleanup

- `battle_skill_resolver.gd`: restorative healing now explicitly uses `floori(float(intelligence) / 4.0)`, preserving prior positive-integer truncation semantics while removing the integer-division warning.
- `battle_web_import_test.gd`: burn damage now explicitly uses `floori(float(magnitude) / 2.0)`, likewise preserving truncation semantics.
- `_apply_unique_skill_effect(..., _skill_data)` marks the intentionally retained callback parameter unused.
- Local `enemy_portrait_marker` was renamed to `actor_portrait_marker`; local `top_bar` to `top_bar_control`, removing member-shadow warnings.
- Godot editor reload and `Battle_Land` load contain none of the five reported warning texts. The related warning sweep found no new parser/reload warnings in modified unique-skill display files.

## Automated validation

- `tools/validate_unique_skill_korean_display.gd`: resolver-plan and Korean effect/status display validation result `[UNIQUE_SKILL_KO] 39/39 PASS`.
- Existing `[CUTIN_PARITY] 13/13 PASS` and `[GARRISON_HERO_PARITY] 13/13 PASS` were re-run.
- Project/editor parse plus WorldMap and Battle_Land loads passed; `git diff --check` passed.

## Next

- User F5 re-QA for player and AI unique skills, then `T06-11 AI Multi-Unit Engagement, Surround & Cooperative Attack Correction`.
