# NEXT TASKS

## Immediate QA gate

- T06-10H occupation portrait QA: Gyeongju → Sabi victory → return to WorldMap → select Sabi. Confirm Uija Wang, Gyebaek, Heukchi Sangji, Kim Chun-chu, Kim Yu-sin, and Jang Bo-go have images rather than `?`; reselect Sabi, end a turn, and verify after save/load where available.

- T06-10F-hotfix1 full player and AI battle re-QA: confirm a valid Korea MVP unique skill logs exactly one `[HERO_CUTIN] route=registry_video` before its existing effect, unlocks once, and advances once.
- Specifically confirm Yi Sun-sin (`yi_sun_sin`), Jeong Do-jeon (`jeong_do_jeon`), and Kim Yu-sin (`kim_yu_sin`) no longer reach legacy flag/static presentation. Reconfirm Kwon Yul and Gwanggaeto are registry-video routes, not legacy routes.
- Confirm a deliberate registry/resource failure logs one explicit legacy fallback while the committed resolver, momentum spend, and finalizer still run once.

## Next implementation

- T06-11 AI Multi-Unit Engagement, Surround & Cooperative Attack Correction remains separate. Do not change cutin visual data, timing, or the T06-10F committed-skill contract as part of that work.
