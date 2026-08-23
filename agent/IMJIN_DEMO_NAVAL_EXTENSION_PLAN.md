# IMJIN DEMO + FUTURE NAVAL BATTLE EXTENSION PLAN

Status: DESIGN LOCK / IMPLEMENTATION PENDING
Date locked: 2026-08-22
Base branch at design lock: `main`
Base commit at design lock: `de01a68e6ed9a8e9d1cd604aed3b37d9a42ac926`

> IMPORTANT FUTURE RULE
>
> When SamWar_BattleLab starts any future naval-battle, boarding-battle, Imjin-demo Test2, or Korea-vs-Japan battle expansion work, read this document first before implementation.
> This document records intentional architecture decisions that must not be reconstructed from memory.

---

## 1. Why this work exists

The current project baseline is the Korea MVP / production WorldMap-to-land-battle flow.

The new Imjin-era heroes and Korea-vs-Japan showcase were added later because the `모두의 창업` application/demo video will be more visually effective with Korea-vs-Japan combat than the existing Korea-vs-China test roster.

This creates TWO DIFFERENT work tracks that must remain separate:

1. **Production expansion**
   - New heroes appear in the real WorldMap.
   - Hero click/selection -> battle formation -> battle entry works through the normal production pipeline.
   - This is NOT demo-only work.
   - This work remains part of the real Korea MVP and future production game.

2. **Demo Scenario / Test2**
   - Separate Korea 5 vs Japan 5 production-UI battle test.
   - Created mainly for the `모두의 창업` demo video.
   - Must not replace or overwrite the existing Korea-vs-China production UI test.
   - Should be structured so it can later become useful groundwork for naval-battle scenario switching.

---

## 2. Core architectural split

### 2.1 Production path

The production path is permanent shared game infrastructure:

`WorldMap hero registry`
-> `hero click / selection`
-> `battle formation`
-> `WorldMap battle context`
-> `Battle_Land`
-> `BattleUnitState / real hero data / portrait / troop / skill`

This path must support the new Imjin heroes exactly like all existing Korea MVP heroes.

The goal is NOT to create a special demo-only shortcut from WorldMap to battle.

### 2.2 Test path

The test/showcase path is separate:

`Battle Scenario data`
-> `Production HUD / shared battle presentation`
-> `Test1: Korea vs China`
-> `Test2: Korea vs Japan`

The current Korea-vs-China test is preserved.

Test2 must be a separate scenario/test surface rather than replacing `TEST_BATTLE_ROSTER` globally or permanently swapping China heroes for Japan heroes.

Whenever practical, Test1 and Test2 should share the same battle controller, Production HUD, roster UI, current-actor HUD, momentum/turn HUD, battle log, supply HUD, command controls, and future design upgrades.

Avoid maintaining two independent copies of the full Production test scene if a shared/inherited/instanced scenario-driven structure can do the job safely.

---

## 3. Current added Imjin heroes

Newly added design-data heroes:

### Korea
- `gwak_jae_u` — 곽재우
- `go_gyeong_myeong` — 고경명
- `kim_deok_ryeong` — 김덕령

### Japan
- `kato_kiyomasa` — 가토 기요마사
- `kuroda_nagamasa` — 구로다 나가마사

Existing Japan heroes relevant to the showcase already include:

- `toyotomi_hideyoshi` — 도요토미 히데요시
- `shimazu_yoshihiro` — 시마즈 요시히로
- `konishi_yukinaga` — 고니시 유키나가

---

## 4. Immediate implementation roadmap

### D0 — Complete the 44-hero data contract

Before WorldMap registration, the generated/runtime hero-data contract must be internally consistent.

Required audit/fix:

- `hero_base_stats.json` = 44 heroes
- `hero_initial_loyalty.json` = 44 heroes
- `hero_battle_profiles.json` = 44 heroes
- `hero_unique_skills.json` = 44 heroes
- all four files contain the same 44 `hero_id` values
- update runtime hard-coded expected hero count from 39 -> 44 where still required
- do not blindly replace unrelated historical references to 39; only change live contracts/validators that now represent the 44-hero dataset

Known design-lock finding:

- converter tooling has already been updated for 44 heroes
- runtime design registry still needs audit because it previously expected 39
- initial loyalty data must be extended for the five added heroes if still missing at implementation time

Completion gate:

- generated design registry loads successfully with 44 heroes
- no count mismatch / missing hero-id mismatch

### D1 — Register the new heroes in the real WorldMap

Add the five heroes to the authoritative WorldMap identity/runtime registration path so F5 can show them in normal gameplay.

Target outcome:

- F5 WorldMap can display/select the new heroes in their assigned cities/factions
- real portraits resolve
- generated battle profile and unique skill data are enriched through the existing runtime factory

Placement/faction rule:

- do not invent a new parallel demo registry
- use the existing production faction/city/hero infrastructure
- audit any authoritative import/workbook/project document before finalizing placement
- if no stronger source exists, current design intent is:
  - new Korean heroes -> Korea/Joseon production faction and Korean city roster
  - Kato/Kuroda -> Toyotomi-side Japan production faction and Japanese city roster
- existing Toyotomi / Shimazu / Konishi placement should not be rewritten merely to make the demo easier

### D2 — Validate WorldMap -> formation -> battle entry

For the newly registered heroes, verify the normal production pipeline:

1. F5 WorldMap
2. click/select hero
3. battle formation
4. place hero in an allowed slot
5. enter battle
6. correct runtime `hero_id` reaches Battle_Land
7. correct display name
8. correct portrait
9. correct troop type / troop icon
10. correct troops/current HP contract
11. correct generated stats
12. correct unique skill metadata

This is permanent Korea MVP/production work and must remain usable after the demo period.

Out of scope for this phase:

- no new Korea-Japan sea route solely for the demo
- no naval movement system
- no naval battle engine
- no boarding implementation yet

---

## 5. Test2 — Korea vs Japan showcase

### 5.1 Purpose

Create a second battle test specifically for the `모두의 창업` demo video.

It must coexist with the current Korea-vs-China Test1.

### 5.2 Architecture rule

Do NOT turn Test1 into Japan by replacing its roster.

Preferred structure:

`Shared Production Battle Test Presentation`
- shared battle controller
- shared Production HUD
- shared roster UI
- shared actor HUD
- shared battle logic
- shared future UI/theme upgrades

Scenario A:
- Korea vs China
- current Test1 preserved

Scenario B:
- Korea vs Japan
- new Test2

The scenario should provide hero IDs / sides / visual-set choices rather than forcing a copied battle implementation wherever possible.

### 5.3 Current recommended showcase roster

This is the current recommended lineup, but individual slots may be re-locked later before implementation if better demo staging is found.

#### Korea 5
- 이순신
- 곽재우
- 김덕령
- 권율
- 고경명

#### Japan 5
- 도요토미 히데요시
- 시마즈 요시히로
- 가토 기요마사
- 고니시 유키나가
- 구로다 나가마사

The intent is to provide visually recognizable Imjin-era Korea/Japan combat with varied hero roles and troop visuals.

### 5.4 Demo QA target

Test2 should make it easy to record a clean demo containing:

- 5 vs 5 rosters
- current actor selection/highlight
- movement
- normal attack
- unique skill
- momentum change
- enemy AI turn
- battle log
- supply HUD
- current actor info HUD
- battle command controls

Existing approved Korea cutins should continue to work.

New Imjin heroes may use prepared static assets where video cutins are not yet available; Test2 must not force a large video-cutin production task unless separately approved.

---

## 6. Why Test2 should prepare for naval battle

Test2 is demo-only in product purpose, but its architecture can become useful future groundwork.

The reusable lesson is NOT `Korea vs Japan` itself.

The reusable lesson is:

> One shared battle presentation can load different battle scenarios, factions, visual sets, battlefields, and eventually battle modes without duplicating the whole UI/gameplay surface.

Future target family:

- Land scenario: Korea vs China
- Land scenario: Korea vs Japan
- Naval scenario: Korea vs Japan
- Boarding/deck scenario: Korea vs Japan

Do not implement the naval modes during the current Imjin demo work.

Only keep Test2 sufficiently scenario-driven that the future naval work has a clean extension point.

---

## 7. Future naval battle design lock

### 7.1 Naval Battle is not just ship artillery

Future naval combat should contain at least two major combat layers:

1. **Ship Combat**
2. **Boarding / Deck Combat**

A useful conceptual transition is:

`Naval long/mid range combat`
-> `approach / collision / boarding condition`
-> `ships become attached / boarding succeeds`
-> `Deck Battlefield`
-> `land-combat-like hero/troop combat on deck`
-> `capture / disengage / sink / retreat consequence`

### 7.2 Naval attack FX / attack families

The future naval attack presentation should support these five major attack families:

- **포격** — cannon / artillery fire
- **화공** — fire attack
- **총** — gunfire
- **활** — arrow fire
- **돌격박치기** — ram / collision attack

This replaces the assumption that naval combat is only cannon + fire.

Gun and bow remain valid naval combat attack types.

### 7.3 Boarding / Deck Battle

When two opposing ships attach/contact strongly enough to trigger boarding, the game needs the concept of a land battle played on a ship deck.

This should be treated as a variant of the existing land-combat core wherever possible, not a totally independent battle engine.

Conceptual structure:

`Battle Core`
- `Land Battlefield`
- `Naval Ship Battlefield`
- `Deck Battlefield`

The future `Deck Battlefield` may reuse:

- hero turn/order concepts
- momentum
- unique skills
- actor selection
- HP/troop state
- roster HUD
- current-actor HUD
- battle log
- command controls
- many land attack rules/effects

Deck-specific differences may include:

- narrower battlefield/grid
- ship deck geometry
- mast / rail / cabin / deck-object obstacles
- limited movement lanes
- boarding entry positions
- capture/ship-control result conditions
- retreat back to own ship where valid
- interaction with ship sink/fire state

### 7.4 Future naval UI reuse principle

The existing battle UI should be reused as much as possible.

Expected reusable surfaces:

- top momentum / turn HUD
- ally/enemy 5-hero roster
- current actor info HUD
- battle log
- unique skill UI
- auto battle / end turn / retreat controls

Naval mode should replace/add only the battlefield-specific information that truly differs.

Examples of later naval-specific additions/swaps may include:

- ship class / hull state
- fire state
- boarding state
- naval ammunition / firing state if designed later
- wind/current only if later gameplay design actually requires it

Do not pre-implement speculative naval UI now.

---

## 8. Future implementation guardrails

When this document is used later, preserve these rules:

1. **Production WorldMap hero integration is not demo-only.**
   - It belongs to the real Korea MVP / production game.

2. **Test2 is separate from Test1.**
   - Never destroy Korea-vs-China Test1 just to make the demo.

3. **Test2 may prepare architecture for naval scenarios, but naval battle is not part of the current demo task.**

4. **Do not duplicate the full Production UI if scenario injection/inheritance can safely reuse it.**

5. **Deck battle should reuse land-battle concepts wherever possible.**

6. **Naval ship-combat attack families are locked as:**
   - 포격
   - 화공
   - 총
   - 활
   - 돌격박치기

7. **Boarding is a real combat-mode transition, not only a visual effect.**
   - ship contact can lead to an actual deck battlefield using heroes/troops.

8. **Do not let demo convenience rewrite production faction/city rules.**

9. **Before future naval implementation, re-audit current Battle Core and Production HUD instead of assuming the 2026 structure is unchanged.**

---

## 9. Immediate next-task order after this design lock

1. D0 — 44-hero data contract audit/fix
2. D1 — new five heroes real WorldMap registration
3. D2 — F5 WorldMap -> hero select -> formation -> Battle_Land end-to-end validation
4. D3 — create isolated/scenario-driven Korea-vs-Japan Test2 while preserving Test1
5. D4 — demo-video QA and asset binding
6. Return to the normal Korea MVP roadmap

Future only:

7. Naval battle architecture audit
8. Ship Combat prototype
9. Boarding transition prototype
10. Deck Battlefield prototype using shared land-battle core concepts

---

## 10. One-line project memory

**Production hero integration stays in the real Korea MVP; Test2 is a `모두의 창업` showcase, built scenario-driven so its technical structure can later help Korea-vs-Japan naval combat, where ship combat uses 포격/화공/총/활/돌격박치기 and successful boarding can transition into a land-battle-like fight on the ships' decks.**
