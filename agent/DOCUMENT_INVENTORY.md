# DOCUMENT INVENTORY

This inventory covers Markdown documents present at the T00 baseline plus documents created by T00. `Archive candidate` and `delete review` are classifications only; no document is moved or deleted in this transaction.

| File | Category | Status | Default Read | Action | Reason |
| --- | --- | --- | --- | --- | --- |
| `agent/WORKFLOW_MANAGER.md` | workflow | active | yes | keep | permission and session entry rules |
| `agent/MVP_MASTER_PLAN.md` | product | active | yes | keep | product-direction single source |
| `agent/TRANSACTION_DEVELOPMENT_RULES.md` | workflow | active | yes | keep | canonical transaction rules |
| `agent/CURRENT_STATE.md` | state | active | yes | rewrite | current-only state summary |
| `agent/TRANSACTION_ROADMAP.md` | roadmap | active | yes | keep | active transaction sequence |
| `agent/transactions/T01_NEW_GAME_FACTION_SELECTION.md` | transaction | active | yes | keep | next runtime specification |
| `agent/DOCUMENT_INVENTORY.md` | documentation | active | no | keep | cleanup decision record |
| `agent/CODEX_WORKFLOW_RULES.md` | workflow | conditional | no | keep | execution classification detail |
| `agent/GODOT_RULES.md` | domain | conditional | no | keep | scene/resource work rules |
| `agent/WORLDMAP_RULES.md` | domain | conditional | no | keep | WorldMap contracts and constraints |
| `agent/BATTLE_WORLDMAP_HANDOFF_CONTRACT.md` | contract | conditional | no | keep | protected battle handoff |
| `agent/contracts/TECH_TREE_GAMEPLAY_CONTRACT.md` | contract | conditional | no | keep | tech gameplay boundary |
| `agent/contracts/SYSTEM_SOURCE_OF_TRUTH.md` | contract | conditional | no | keep | target state ownership |
| `agent/scenarios/KOREA_MVP_SCENARIO.md` | scenario | conditional | no | keep | Korea scenario boundary |
| `agent/ARCHITECT_AGENT.md` | role | conditional | no | keep | architecture-role guidance |
| `agent/IMPLEMENTATION_AGENT.md` | role | conditional | no | keep | implementation-role guidance |
| `agent/QA_AGENT.md` | role | conditional | no | keep | regression-role guidance |
| `agent/RUNTIME_QA_AGENT.md` | role | conditional | no | keep | runtime QA guidance |
| `agent/VISUAL_QA_AGENT.md` | role | conditional | no | keep | manual visual QA guidance |
| `agent/ARMY_DEPLOYMENT_RULES.md` | domain | conditional | no | keep | deployment constraints |
| `agent/AUTO_BATTLE_ACTION_POLICY.md` | domain | conditional | no | keep | auto-battle policy |
| `agent/BATTLE_CONTEXT_CONTRACT.md` | contract | conditional | no | keep | battle input contract |
| `agent/BATTLE_ENGINE_RULES.md` | domain | conditional | no | keep | tactical engine rules |
| `agent/HERO_DATA_CONTRACT.md` | contract | conditional | no | keep | hero data boundary |
| `agent/SKILL_SYSTEM_RULES.md` | domain | conditional | no | keep | skill rules |
| `agent/CONFIRMED_CITY_TECHTREE_DESIGN.md` | design | conditional | no | keep | city-tech reference pending audit |
| `agent/CONFIRMED_NATIONAL_TECHTREE_DESIGN.md` | design | conditional | no | keep | national-tech reference pending audit |
| `agent/CONFIRMED_techtree_design.md` | design | delete review | no | delete review | likely duplicate/case-variant tech design |
| `agent/CONFIRMED_DIPLOMACY_ESPIONAGE_REVOLT.md` | design | conditional | no | keep | future domain reference |
| `agent/CONFIRMED_LOYALTY_PUBLICSUPPORT_DESIGN.md` | design | conditional | no | keep | future domain reference |
| `agent/CONFIRMED_TRADE_SYSTEM_DESIGN.md` | design | conditional | no | keep | future domain reference |
| `agent/DOMESTIC_TECH_GAMEPLAY_EFFECT_INTEGRATION_MAP.md` | audit | archive candidate | no | archive later | completed integration history |
| `agent/DOMESTIC_TECH_LABOR_POLICY_RESOURCE_DESIGN.md` | design | conditional | no | keep | specific future domain design |
| `agent/DOMESTIC_TECH_MANUAL_QA.md` | qa | archive candidate | no | archive later | completed QA evidence |
| `agent/DOMESTIC_TECH_RESEARCH_COST_DESIGN.md` | design | conditional | no | keep | cost design reference |
| `agent/ENEMY_INVASION_AUDIT.md` | audit | archive candidate | no | archive later | prior audit; T03 will supersede actively |
| `agent/INVASION_ATTACK_WEB_PARITY_GAP_AUDIT.md` | audit | archive candidate | no | archive later | historical gap audit |
| `agent/LAND_BATTLE_MVP_COMPLETION_PLAN.md` | plan | archive candidate | no | archive later | previous battle-focused plan |
| `agent/LAND_BATTLE_MVP_GAP_AUDIT.md` | audit | archive candidate | no | archive later | previous battle-focused audit |
| `agent/CHANGELOG.md` | history | archive candidate | no | archive later | version history, not active context |
| `agent/SESSION_LOG.md` | history | archive candidate | no | archive later | session history, not active context |
| `agent/HANDOFF_TO_CODEX.md` | handoff | superseded | no | rewrite | compatibility pointer only |
| `agent/NEXT_TASKS.md` | roadmap | superseded | no | rewrite | compatibility pointer only |
| `agent/BATTLE_ENGINE_FIRST_SAFE_EXTRACTION.md` | refactor | archive candidate | no | archive later | completed extraction record |
| `agent/BATTLE_ENGINE_REFACTOR_FUNCTION_MAP.md` | refactor | archive candidate | no | archive later | completed refactor map |
| `agent/BATTLE_FORMATION_FACING_REVIEW.md` | audit | archive candidate | no | archive later | completed review |
| `agent/BATTLE_HELPER_DEPENDENCY_DEDUP_REVIEW.md` | audit | archive candidate | no | archive later | completed review |
| `agent/BATTLE_REINFORCEMENT_REVIEW.md` | audit | archive candidate | no | archive later | completed review |
| `agent/BATTLE_SKILL_METADATA_EXTRACTION.md` | refactor | archive candidate | no | archive later | completed extraction |
| `agent/BATTLE_STAGE_B_COMPLETE_LOCK.md` | complete lock | archive candidate | no | archive later | completed milestone |
| `agent/BATTLE_STAGE_B_REMAINING_PURE_HELPER_AUDIT.md` | audit | archive candidate | no | archive later | completed audit |
| `agent/BATTLE_UI_TEXT_FORMATTER_EXTRACTION.md` | refactor | archive candidate | no | archive later | completed extraction |
| `agent/BATTLE_UNIT_VISUAL_ANIMATION_REVIEW.md` | audit | archive candidate | no | archive later | completed review |
| `agent/MVP_3_MAIN_2_REINFORCE_LAYOUT_PLAN.md` | plan | archive candidate | no | archive later | historical battle layout plan |
| `agent/SCALABLE_BATTLE_SLOT_CAPACITY_PLAN.md` | plan | archive candidate | no | archive later | historical capacity plan |
| `agent/SCENE_ENTRYPOINT_MAP.md` | refactor | archive candidate | no | archive later | completed rename map |
| `agent/SCENE_SLOT_TREE_MIGRATION_PLAN.md` | plan | archive candidate | no | archive later | historical migration plan |
| `agent/SCRIPTS_FOLDER_STRUCTURE_MAP.md` | refactor | archive candidate | no | archive later | completed folder refactor map |
| `agent/SLOT_UI_ATTACHMENT_AUDIT.md` | audit | archive candidate | no | archive later | completed UI audit |
| `agent/V0_71_FULL_REGRESSION_F6_QA.md` | qa | archive candidate | no | archive later | completed QA record |
| `agent/V0_71_REFACTOR_COMPLETE_LOCK.md` | complete lock | archive candidate | no | archive later | completed milestone |
| `agent/V0_72_SCENE_ENTRYPOINT_RENAME_COMPLETE_LOCK.md` | complete lock | archive candidate | no | archive later | completed milestone |
| `agent/V0_72_SCENE_ENTRYPOINT_RENAME_PLAN.md` | plan | archive candidate | no | archive later | completed plan |
| `agent/V0_72_SCENE_RENAME_F6_ROUNDTRIP_QA.md` | qa | archive candidate | no | archive later | completed QA record |
| `agent/WORLDMAP_REFACTOR_FUNCTION_MAP.md` | refactor | archive candidate | no | archive later | completed refactor map |
| `agent/LOCAL_ENV.md` | local environment | local-only | no | keep untracked | machine-specific, never commit |
| `agent/archive/README.md` | archive policy | conditional | no | keep | archive operation rules |
| `agent/archive/v0.67-docs_agent_docs_slimdown/CHANGELOG_full_before_slimdown.md` | history | archived | no | keep | preserved historical source |
| `agent/archive/v0.67-docs_agent_docs_slimdown/CURRENT_STATE_full_before_slimdown.md` | history | archived | no | keep | preserved historical source |
| `agent/archive/v0.67-docs_agent_docs_slimdown/SESSION_LOG_full_before_slimdown.md` | history | archived | no | keep | preserved historical source |
| `_incoming_confirmed_designs/CONFIRMED_diplomacy_espionage_revolt.md` | incoming design | delete review | no | delete review | duplicate import of tracked design |
| `_incoming_confirmed_designs/CONFIRMED_loyalty_publicsupport_design.md` | incoming design | delete review | no | delete review | duplicate import of tracked design |
| `_incoming_confirmed_designs/CONFIRMED_national_techtree_design.md` | incoming design | archive candidate | no | archive later | imported source; compare before cleanup |
| `_incoming_confirmed_designs/CONFIRMED_techtree_design.md` | incoming design | archive candidate | no | archive later | imported source; compare before cleanup |
| `_incoming_confirmed_designs/CONFIRMED_trade_system_design.md` | incoming design | archive candidate | no | archive later | imported source; compare before cleanup |
| `assets/video_test/theora_safe/README.md` | asset-local | conditional | no | keep | local asset test instructions |
| `assets/web_battle/ui/bottom_command/README.md` | asset-local | conditional | no | keep | local UI asset instructions |
| `scripts/worldmap/README.md` | code-local | conditional | no | keep | WorldMap module entry |
| `scripts/worldmap/debug_qa/README.md` | code-local | conditional | no | keep | debug QA module notes |
| `scripts/worldmap/defense_battle/README.md` | code-local | conditional | no | keep | defense module notes |
| `scripts/worldmap/diplomacy_spy/README.md` | code-local | conditional | no | keep | diplomacy module notes |
| `scripts/worldmap/domestic_tech/README.md` | code-local | conditional | no | keep | tech module notes |
| `scripts/worldmap/economy_city/README.md` | code-local | conditional | no | keep | economy module notes |
| `scripts/worldmap/enemy_baseline/README.md` | code-local | conditional | no | keep | enemy module notes |
| `scripts/worldmap/naval_siege/README.md` | code-local | conditional | no | keep | naval module notes |
| `scripts/worldmap/orchestration/README.md` | code-local | conditional | no | keep | orchestration module notes |
| `scripts/worldmap/save_load/README.md` | code-local | conditional | no | keep | save/load module notes |
| `scripts/worldmap/selection_panel/README.md` | code-local | conditional | no | keep | selection UI module notes |
| `scripts/worldmap/shared/README.md` | code-local | conditional | no | keep | shared module notes |
| `scripts/worldmap/ui_formatter/README.md` | code-local | conditional | no | keep | UI formatter module notes |

## Summary

- KEEP ACTIVE: 7
- KEEP CONDITIONAL: 28
- REWRITE: 3
- ARCHIVE CANDIDATE: 33
- DELETE REVIEW: 3

Counts classify action/status, so compatibility and archived/local-only rows are listed separately rather than treated as active reading.
