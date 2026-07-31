# NEXT TASKS

## Immediate QA gate

- T06-10F player and AI actual-battle cutin QA: confirm a valid Korea MVP unique skill plays exactly one approved cutin before its existing battle effect, then unlocks and advances once.
- Verify the fallback log prefix `[HERO_CUTIN]` only when a registry/parity/resource problem is deliberately introduced; normal Korea MVP data should not fall back.

## Next implementation

- T06-11 AI Multi-Unit Engagement, Surround & Cooperative Attack Correction. Do not change cutin visual data, timing, or the T06-10F committed-skill contract as part of that work.
