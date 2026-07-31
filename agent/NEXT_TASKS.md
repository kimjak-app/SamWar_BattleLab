# NEXT TASKS

## Immediate QA gate

- T06-11B surround-pressure F5 QA: invade Sabi with one Yi Sun-sin unit against three-to-four defenders. Confirm each enemy continues to approach without selecting the same cell, available enemies spread across at least two useful approach directions, blocked actors seek an alternate valid approach, and existing 측면 공격!/후방 공격! logs occur when the established directional conditions are met. Narrow terrain may naturally produce sequential approach rather than forced encirclement.

- T06-10I player/AI unique-skill display QA: verify Korean effect/status strings in floating text, status summaries/tooltips, and battle log for Jang Bo-go, Gwanggaeto, Uija Wang, and representative damage/buff/debuff/heal/guard skills. Confirm no internal underscore IDs appear.

- T06-10H occupation portrait QA: Gyeongju → Sabi victory → return to WorldMap → select Sabi. Confirm Uija Wang, Gyebaek, Heukchi Sangji, Kim Chun-chu, Kim Yu-sin, and Jang Bo-go have images rather than `?`; reselect Sabi, end a turn, and verify after save/load where available.

- T06-10F-hotfix1 full player and AI battle re-QA: confirm a valid Korea MVP unique skill logs exactly one `[HERO_CUTIN] route=registry_video` before its existing effect, unlocks once, and advances once.
- Specifically confirm Yi Sun-sin (`yi_sun_sin`), Jeong Do-jeon (`jeong_do_jeon`), and Kim Yu-sin (`kim_yu_sin`) no longer reach legacy flag/static presentation. Reconfirm Kwon Yul and Gwanggaeto are registry-video routes, not legacy routes.
- Confirm a deliberate registry/resource failure logs one explicit legacy fallback while the committed resolver, momentum spend, and finalizer still run once.

## Next implementation

- Follow-up only if the T06-11B F5 gate reveals a reproducible reservation or directional-pressure defect. Do not change cutin visual data, timing, or the T06-10F committed-skill contract as part of that work.
