# SKILL SYSTEM RULES

## Role
- Defines future skill metadata and runtime skill boundary rules.
- Keeps hero skill identity stable as hero count and battle types expand.

## Core Direction
- Skill identity is `skill_id` based.
- `HeroData.unique_skill_ids` points to skill metadata.
- `hero_id` connects heroes to one or more `skill_id` values.
- Skill metadata is static.
- Battle runtime stores cooldowns, readiness, temporary buffs, and active statuses.
- Battle engine executes skills against current battle targets after roster and hero data have resolved.
- The battle engine consumes the skill registry.
- The worldmap does not directly process skill logic.

## SkillData Example
```js
SkillData = {
  skill_id,
  display_name,
  owner_tags,
  battle_type_tags,
  effect_type,
  range_rule,
  target_rule,
  cooldown,
  value_rule,
  visual_cutin_key,
  status_tags
}
```

## Required Fields
- `skill_id`: stable unique skill ID.
- `display_name`: localized skill name.
- `effect_type`: execution family such as damage, buff, defense, strategy, or movement.
- `range_rule`: range and shape rule.
- `target_rule`: valid target rule.
- `cooldown`: base cooldown rule.

## Optional Future Fields
- `battle_type_tags`: restricts or modifies skills for land, naval, coastal, siege, or mountain battles.
- `terrain_tags`: terrain-specific modifiers.
- `owner_tags`: faction, hero, culture, or scenario tags.
- `visual_cutin_key`: presentation lookup key.
- `status_tags`: statuses applied or required by the skill.
- `ai_value_rule`: optional AI priority hint.

## Skill Families
- `active`
- `passive`
- `aoe`
- `buff`
- `debuff`
- `damage`
- `strategy`

## Runtime Boundary
- Cooldown state belongs to battle runtime state.
- One battle's cooldowns and temporary statuses should not mutate static skill metadata.
- Unique skill readiness should remain derived from battle runtime state plus skill metadata.
- Skill execution should not query worldmap state directly.

## Current MVP Compatibility
- Current unique skill registry is `hero_id` based.
- Current MVP effect families include:
  - `cannon_aoe`
  - `ally_attack_buff`
  - `self_defense_single`
  - `single_damage_adjacent_shake`
- Current manual unique skill use requires range / target selection before resolution.
- Current auto/enemy skill use checks value conditions before falling back to basic attack, movement, or wait.
- Current unique skill presentation uses a screen-fixed wide cut-in first, then applies the existing battle effect logic; presentation scale must not change effect values, targets, cooldowns, or AI value gates.

## Future Battle-Type Expansion
- `naval_only` skills.
- `siege_only` skills.
- Naval skills may use fleet, route, wind, or sea-region tags.
- Siege skills may use wall, gate, engine, or city-defense tags.
- Mountain skills may use elevation, pass, ambush, or movement-penalty tags.
- Coastal skills may bridge land and sea target rules.
- Terrain bonus skills may read battle terrain tags from `BattleContext`.
- Weather interaction skills may read battle weather fields from `BattleContext`.

## Regression Guard
- Do not break current unique skill cooldown behavior.
- Do not restore one-use gating unless explicitly requested.
- Do not bypass current range-limited valid target checks.
- Do not make skill metadata depend on scene node names.
- Do not let cut-in presentation timing or scale alter unique skill formulas, target validity, cooldown state, or registry ownership.
