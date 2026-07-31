# HANDOFF TO CODEX

T06-10F-hotfix1 restores authoritative WorldMap hero IDs through the actual battle cutin route. The reverse legacy conversion table was removed from `scripts/battle_web_import_test.gd`; authoritative `yi_sun_sin`, `jeong_do_jeon`, and `kim_yu_sin` now reach exact `KoreaMvpHeroCutinRegistry.find_entry(hero_id, skill_id)` parity unchanged.

- The presentation host remains `Battle_Land.tscn:HeroCutinOverlay/HeroCutinViewport/HeroCutinPresentation`. Player and AI converge at `_begin_unique_skill_sequence`; after resolver-plan validation and one successful momentum spend, `_play_committed_hero_cutin` selects the registered video route, then the existing resolver/finalizer executes once on completion.
- Route logs are authoritative diagnostic evidence: `[HERO_CUTIN] route=registry_video` is required for Korea MVP normal data. `route=legacy_static` and `route=legacy_fallback` are retained only for non-registry/resource/parity failures. The route decision logs once per commit.
- `tools/validate_korea_mvp_cutin_parity.py` reports all 13 canonical hero IDs and generated skill IDs as exact registry/resource parity PASS. Do not loosen `find_entry` to hero-only matching or convert registry IDs to legacy names.
- `BattleUnitState.HERO_ID_ALIASES` stays as inbound legacy-to-canonical compatibility. `HERO_REGISTRY`, `UNIQUE_SKILL_REGISTRY`, and `TEST_BATTLE_ROSTER` are direct Battle_Land demo fallback data; `worldmap_context_unique_skill_registry` has no consumer and should be audited separately in T06-10G, not deleted here.
- Current battle momentum test policy remains start 3 / max 10. Cutin assets, text, transforms, timing, skills, resolver behavior, AI, and save schema are unchanged.

Next gate: user F5 full player+AI re-QA, especially Yi Sun-sin, Jeong Do-jeon, Kim Yu-sin, Kwon Yul, and Gwanggaeto route logs. The full WorldMap-to-battle commit sequence does not terminate under the local headless watchdog, so it is not claimed as automated end-to-end coverage. Next cleanup audit is T06-10G; the later unrelated task is T06-11 AI multi-unit engagement/surround/cooperative attack correction.
