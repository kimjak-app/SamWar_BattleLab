"""M4-c1 3D unique skill command: pinned scope, zero engine/service/adapter diff,
exactly twelve engine write calls (M4-b ten + `_on_unique_skill_button_pressed`,
`_try_use_unique_skill_on_target`), read boundary = M4-b/M4-d + the approved
unique skill queries, `battle_momentum` (get_value only) and the preview flag,
the fourth cursor handling exactly strategy_cast / status_tick /
reinforcement_arrived / skill_cast / skill_effect / skill_finished with an
allied-caster filter on the skill kinds, every skill number and id displayed
from the event, status names equal to the engine's display names, no dice hook
and no random calls in 3D, no world-map/result calls.

M4C1_SCOPE_TIP=<commit> audits BASE..commit; HEAD (default until the reviewer
re-pins the merged implementation commit) audits the live worktree.
"""
from pathlib import Path
import argparse, ast, hashlib, os, re, subprocess

BASE = "4e0b034f1d180c25bc5bc9198e5a37c3cf6b0871"  # chore(battle3d): re-pin the M4-b and M4-d validators ...
TIP = os.environ.get("M4C1_SCOPE_TIP", "HEAD")
PLAY = "scripts/battle3d/battle3d_engine_play.gd"
WORKFLOW = ".github/workflows/verify-c-track.yml"
VALIDATOR = "tools/validate_battle3d_m4c1_skill.py"
REPORT = "agent/BATTLE3D_M4C1_RESULT_20261022.md"
HARNESS = "tests/scripts/support/battle3d_skill_harness.gd"
EQUIVALENCE = "tests/scripts/test_battle3d_skill_equivalence.gd"
CI_TESTS = ["tests/scripts/test_battle3d_skill_equivalence_shard_1.gd", "tests/scripts/test_battle3d_skill_equivalence_shard_2.gd",
            "tests/scripts/test_battle3d_skill_equivalence_shard_3.gd", "tests/scripts/test_battle3d_skill_equivalence_shard_4.gd",
            "tests/scripts/test_battle3d_skill_default_round.gd", "tests/scripts/test_battle3d_skill_rejections.gd",
            "tests/scripts/test_battle3d_skill_mixed_log.gd"]
NEW = {VALIDATOR, REPORT, HARNESS, EQUIVALENCE, *CI_TESTS}
NEW |= {p + ".uid" for p in list(NEW) if p.endswith(".gd")}
MODIFIED = {PLAY, WORKFLOW}
STATUS_HELPER = "scripts/battle/helpers/battle_ui_text_format_helper.gd"
PROTECTED = ["scripts/battle_web_import_test.gd", "scripts/battle_unit_state.gd", "scripts/battle3d/lab_presentation.gd",
             "scripts/battle3d/battle3d_unit_adapter.gd", "scripts/battle3d/battle3d_engine_host.gd", "scripts/battle3d/battle3d_movement_adapter.gd",
             "scripts/battle/services/battle_tactic_event_log_service.gd", "scripts/battle/battle_skill_resolver.gd", STATUS_HELPER,
             "tests/scripts/support/battle3d_strategy_harness.gd", "tests/scripts/support/battle3d_reinforce_harness.gd",
             "tests/scripts/support/battle3d_defend_harness.gd", "tests/scripts/support/battle3d_wait_harness.gd",
             "tests/scripts/support/battle3d_enemy_turn_harness.gd", "tests/scripts/support/battle3d_engine_attack_harness.gd",
             "tests/scripts/support/battle_enemy_turn_oracle_harness.gd", "tests/scripts/support/battle_tactic_oracle_harness.gd",
             "tests/scripts/test_battle3d_strategy_equivalence.gd", "tests/scripts/test_battle3d_strategy_default_round.gd",
             "tests/scripts/test_battle3d_strategy_rejections.gd", "tests/scripts/test_battle3d_strategy_mixed_log.gd",
             "tests/scripts/test_battle3d_reinforce_default_rounds.gd", "tests/scripts/test_battle3d_reinforce_blocking.gd",
             "tests/scripts/test_battle3d_reinforce_mixed_log.gd", "tests/scripts/test_battle3d_enemy_turn_equivalence.gd",
             "tools/validate_battle3d_m1b_engine_move.py", "tools/validate_battle3d_m2_engine_attack.py", "tools/validate_battle3d_m3_enemy_turn.py",
             "tools/validate_battle3d_m3b_wait.py", "tools/validate_battle3d_m4a_defend.py", "tools/validate_battle3d_m4b_strategy.py",
             "tools/validate_battle3d_m4d_reinforce.py", "tools/validate_battle_enemy_events_s3_1.py",
             "tools/validate_battle_tactic_events_s4_1.py", "tools/validate_battle3d_contract.py"]
GOLDENS = {"tests/golden/battle_attack_baseline_v0.json": "d018cbe618c06043ea6ac6fd22c8a56faa42f284d4e6613f01bfa98dad3dd91c",
           "tests/golden/battle_move_baseline_v0.json": "b35d3f7987bb2efca5efe1d379b6eddc00cdca1558c17e88733dd1389cf714bd",
           "tests/golden/battle_enemy_turn_baseline_v0.json": "a3795131b8d2c525f7c096683d98b543410c01a130930783961dab671d9887f7",
           "tests/golden/battle3d_m3_start_v0.json": "c1a1291fa0a2f23307b67316db64a3c663c38d43e15fd904f5b4e4e67921926a",
           "tests/golden/battle_tactic_baseline_v0.json": "2693536d50b23799ee3e63e4419912bf08929ea40c516bb86f284f959811db2d"}
WAIT, DEFEND = "_end_ally_turn_by_wait", "_on_defend_button_pressed"
STRATEGY_BUTTON, STRATEGY_TARGET = "_on_strategy_button_pressed", "_try_use_strategy_on_target"
BUTTON, TARGET = "_on_unique_skill_button_pressed", "_try_use_unique_skill_on_target"
COMMANDS = {"_select_ally_unit", "_try_direct_move_to_cell", "_select_post_move_facing", "_handle_right_click_cancel", "try_basic_attack",
            "_try_attack_enemy_target_from_attack_select", WAIT, DEFEND, STRATEGY_BUTTON, STRATEGY_TARGET, BUTTON, TARGET}
BASE_READ_CALLS = {"_get_alive_enemy_units", "is_unit_in_attack_range", "_is_unit_state_available_for_battle_slot",
                   "_can_use_strategy", "_get_strategy_targets", "_get_strategy_success_rate"}
# Approved after pre-check 2 (pure: units, controller, four logs, battle log lines, RNG unchanged).
APPROVED_SKILL_READS = {"_can_use_unique_skill", "_get_unique_skill_for_unit", "_get_unique_skill_valid_targets",
                        "_should_unique_skill_resolve_without_manual_target", "_is_valid_unique_skill_target",
                        "_get_unique_skill_remaining_cooldown_turns"}
USED_SKILL_READS = {"_can_use_unique_skill", "_get_unique_skill_for_unit", "_get_unique_skill_valid_targets",
                    "_should_unique_skill_resolve_without_manual_target"}
BASE_READ_PROPERTIES = {"current_phase", "is_demo_animating", "active_unit_state", "all_battle_unit_states", "battle_action_event_log",
                        "ally_move_event_log", "battle_grid_controller", "enemy_action_event_log", "tactic_event_log"}
NEW_READ_PROPERTIES = {"battle_momentum", "is_manual_unique_skill_preview_pending"}
VIEW_FIELDS = {"unit_id", "side", "unit_type", "grid_cell", "facing", "current_troops", "max_troops", "allocated_troops", "footprint",
               "has_moved", "has_acted", "status_effects", "move_range", "attack_range"}
FORBIDDEN = r"worldmap|world_map|WorldMap|payload|result_toast|result_video|_try_show_battle_result|change_scene|samwar_worldmap|" \
            r"_recover_wounded_troops_for_defend|_auto_wait_active_ally|_play_enemy|_start_new_round|full_auto|" \
            r"_mark_enemy_unit_acted|_mark_ally_unit_acted|_return_to_ally_turn|_finish_enemy_actor|_finish_enemy_basic|_enemy_reaction_hit_on|" \
            r"_begin_unique_skill|_try_auto_unique_skill|_run_auto_action|_apply_resolver_skill_plan|_finalize_unique_skill|_apply_unique_skill|" \
            r"_begin_manual_unique_skill_preview|_finish_manual_unique_skill_preview|_enter_unique_skill|_cancel_unique_skill|" \
            r"_get_best_unique_skill|_get_effective_unique_skill_cost|_get_unique_skill_range|_set_unique_skill_cooldown|" \
            r"_handle_unique_skill_commit_failure|unique_skill_targeting|pending_unique_skill_plan|BattleSkillResolver|build_plan|" \
            r"\.spend\(|\.gain\(|\.lose\(|\.reset\(|record_basic_attack|can_spend|" \
            r"_deploy_reinforce|_deploy_city_reinforcement|_try_deploy|" \
            r"_resolve_strategy|_roll_strategy_outcome|_strategy_roll_|_enter_strategy_target_select_mode|_consume_strategy_status|" \
            r"strategy_roll_override|_get_strategy_range|_get_strategy_outcome_pool"
RULE_TOKENS = r"\brandf\b|\brandi\b|randf_range|randi_range|RandomNumberGenerator|\bseed\s*\(|intelligence|STRATEGY_|get_status_magnitude|" \
              r"apply_status_effect|tick_status_effects|apply_damage|max_hp|current_hp|0\.55|magnitude|power|radius|skill_cost_up|MAX_MOMENTUM"
CHANGED_FUNCTIONS = {"_build_ui", "_build_attack_ui", "_build_turn_ui", "_sync_views", "_refresh_turn_ui", "_click_world", "_consume_tactic_events"}
NEW_FUNCTIONS = {"_skill_block_reason", "request_skill", "_show_skill_targets", "_clear_skill_marks", "_skill_target_at", "_click_skill_cell",
                 "_skill_cast_count", "_skill_caster_side", "_skill_name", "_present_skill_event", "_present_skill_effect", "_cell_text",
                 "_skill_line", "_skill_label"}
NEW_MEMBERS = {"skill_button", "skill_marks", "skill_target_ids", "skill_presentations", "skill_texts", "momentum_label",
               "momentum_display", "momentum_note"}
KINDS = ["strategy_cast", "status_tick", "reinforcement_arrived", "skill_cast", "skill_effect", "skill_finished"]
EFFECT_KINDS = ["damage", "heal", "status", "cleanse", "momentum", "move"]


def check_state_writes(code):
    fields = r"(?:grid_cell|has_moved|has_acted|current_phase|ally_has_moved|last_action|current_troops|current_hp|is_defending|" \
             r"facing|status_effects|battle_round|is_demo_animating|active_unit_state|move_range|attack_range|side|intelligence|" \
             r"max_troops|allocated_troops|dead_unit_ids|battle_momentum|strategy_targeting_caster_state|is_unique_skill_presenting|" \
             r"is_manual_unique_skill_preview_pending|unique_skill_definition|attack|defense)"
    assignment = r"\s*(?:[+*/%&|^\-]|<<|>>|\*\*)?=(?!=)"
    assert not re.search(r"\b(?:unit|candidate|target|active|caster|waited|defended|engine)\." + fields + assignment, code), "state assignment"
    assert not re.search(r"\[\s*['\"]" + fields + r"['\"]\s*\]" + assignment, code), "indexed state assignment"
    assert not re.search(r"\.(?:set|set_deferred)\(\s*['\"]" + fields + r"['\"]", code), "state property setter"


def functions(code):
    return {m.group(1): m.group(0).rstrip() for m in re.finditer(r"^func (\w+)\([^\n]*\).*?(?=^func |\Z)", code, re.M | re.S)}


def strip_comments(source):
    return "\n".join(line.split("#", 1)[0] for line in source.splitlines())


def gd_dict(source, name):
    # A GDScript const dictionary of string literals -> Python dict.
    m = re.search(r"^const " + name + r" := (\{.*?\})", source, re.M | re.S)
    assert m, "missing const " + name
    return ast.literal_eval(re.sub(r"\s+", " ", m.group(1)))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    root = parser.parse_args().root.resolve()

    def git(*args):
        return subprocess.check_output(["git", "-C", str(root), *args])

    live = TIP == "HEAD"
    rev = [BASE] if live else [BASE, TIP]

    def raw(path, base=False):
        return (root / path).read_bytes() if live and not base else git("show", f"{BASE if base else TIP}:{path}")

    def text(path, base=False):
        return raw(path, base).decode("utf-8").replace("\r\n", "\n")

    changes = dict((line.split("\t", 1)[1], line.split("\t", 1)[0]) for line in
                   git("diff", "--no-renames", "--name-status", *rev).decode().splitlines())
    if live:
        for p in git("ls-files", "--others", "--exclude-standard").decode().splitlines():
            changes.setdefault(p, "A")
    for p, status in changes.items():
        assert (p in MODIFIED and status == "M") or (p in NEW and status == "A"), ("out of scope", status, p)
    for p in NEW:
        assert raw(p).strip(), "missing " + p
    assert not [p for p in changes if p.startswith("scripts/") and p != PLAY], "engine/service/adapter diff must be 0 lines"
    for p in PROTECTED:
        assert text(p) == text(p, True), "protected bytes: " + p
    for p, digest in GOLDENS.items():
        assert hashlib.sha256(raw(p).replace(b"\r\n", b"\n")).hexdigest() == digest, "golden changed " + p
    wf_diff = git("diff", "--unified=0", *rev, "--", WORKFLOW).decode()
    assert not any(x.startswith("-") and not x.startswith("---") for x in wf_diff.splitlines()), "workflow additions only"
    added = [x[1:].strip() for x in wf_diff.splitlines() if x.startswith("+") and not x.startswith("+++")]
    assert sorted(added) == sorted([VALIDATOR, *CI_TESTS]), added

    # No 3D file mentions the dice hook or rolls random numbers.
    tracked = git("ls-files", "scripts/battle3d").decode().splitlines() + ([p for p in changes if p.startswith("scripts/battle3d/")] if live else [])
    for p in set(tracked):
        if not p.endswith(".gd"):
            continue
        body = strip_comments(text(p))
        assert "strategy_roll_override" not in text(p), "3D mentions the dice hook: " + p
        assert not re.search(r"\b(randf|randi|randf_range|randi_range|randfn|RandomNumberGenerator)\b|\bseed\s*\(|\bshuffle\s*\(|pick_random", body), "3D random call: " + p

    play = text(PLAY)
    code = strip_comments(play)
    old_code = strip_comments(text(PLAY, True))
    calls = re.findall(r'engine\.call\("([^"\n]+)"', code)
    assert USED_SKILL_READS <= APPROVED_SKILL_READS
    assert set(calls) == COMMANDS | BASE_READ_CALLS | USED_SKILL_READS, "exact twelve commands and approved read calls: " + str(set(calls) ^ (COMMANDS | BASE_READ_CALLS | USED_SKILL_READS))
    assert len(COMMANDS) == 12 and all(calls.count(c) == 1 for c in [WAIT, DEFEND, STRATEGY_BUTTON, STRATEGY_TARGET, BUTTON, TARGET]), "one call site per end command"
    assert len(re.findall(r"engine\.call\(", code)) == len(calls), "no dynamic method names"
    props = re.findall(r'engine\.get\("([^"\n]+)"\)', code)
    assert set(props) == BASE_READ_PROPERTIES | NEW_READ_PROPERTIES, "read properties: " + str(set(props) ^ (BASE_READ_PROPERTIES | NEW_READ_PROPERTIES))
    assert len(re.findall(r"engine\.get\(", code)) == len(props), "no dynamic property names"
    assert not re.search(r"engine\.(?!get\(|call\()\w+", code), "no alternate engine access"
    momentum_uses = re.findall(r'engine\.get\("battle_momentum"\)(\.\w+\()?', code)
    assert momentum_uses and all(u == ".get_value(" for u in momentum_uses), "battle_momentum is read through get_value only"
    check_state_writes(code)
    assert not re.search(FORBIDDEN, code), "forbidden call/rule: " + str(re.findall(FORBIDDEN, code))
    # The STATUS_TEXT name table holds status ids as keys; it is checked against the engine names below.
    rule_code = re.sub(r"^const STATUS_TEXT := \{.*?\}", "", code, flags=re.M | re.S)
    assert not re.search(RULE_TOKENS, rule_code), "3D skill/status rule or random: " + str(re.findall(RULE_TOKENS, rule_code))
    reads = set(re.findall(r"\b(?:unit|candidate|target|active|waited|defended|caster)\.(\w+)", code))
    assert reads <= VIEW_FIELDS | {"is_defending"}, reads
    f, old_f = functions(code), functions(old_code)
    assert set(f) - set(old_f) == NEW_FUNCTIONS, "new functions: " + str((set(f) - set(old_f)) ^ NEW_FUNCTIONS)
    assert set(old_f) <= set(f), "no function removed"
    changed = {n for n in old_f if f.get(n) != old_f[n]}
    assert changed <= CHANGED_FUNCTIONS, "only listed shared functions change: " + str(changed - CHANGED_FUNCTIONS)
    members = lambda s: set(re.findall(r"^(?:var|const) (\w+)", s, re.M))
    assert members(code) - members(old_code) == NEW_MEMBERS, "new members: " + str(members(code) - members(old_code))
    assert len(re.findall(r"\*", code)) == len(re.findall(r"\*", old_code)), "no new multiplication (only _rate_text formats a rate)"
    readers = {n for n, body in f.items() if re.search(r"\.is_defending\b", body)}
    assert readers == {"_refresh_target_info", "_unit_defending"}, "is_defending readers unchanged: " + str(readers)

    # Status names: the engine's display names, character for character; M4-b names kept.
    names = gd_dict(play, "STATUS_TEXT")
    engine_names = gd_dict(text(STATUS_HELPER), "UNIQUE_SKILL_STATUS_DISPLAY_NAMES")
    assert {k: names[k] for k in ["shake", "confusion", "burn"]} == {"shake": "동요", "confusion": "혼란", "burn": "화상"}, "M4-b names kept"
    for k, v in names.items():
        assert engine_names.get(k) == v, "status name differs from the engine: %s %s vs %s" % (k, v, engine_names.get(k))
    resolver = text("scripts/battle/battle_skill_resolver.gd")
    skill_status_ids = set(re.findall(r'_command\("status"[^)\n]*"(\w+)"\)', resolver)) | set(re.findall(r'^\s*(?:status_id = |return )"(\w+)"', resolver, re.M))
    skill_status_ids &= set(engine_names)
    assert skill_status_ids <= set(names), "every skill status id has a display name: " + str(skill_status_ids - set(names))

    # Button: input lock, then guidance, then the button command; acceptance read back.
    req = f["request_skill"]
    steps = [x.strip() for x in req.splitlines() if x.strip()]
    assert steps[1:5] == ["if not ready_for_input or _input_locked(): return", "var reason := _skill_block_reason()",
                          "if not reason.is_empty():", "_reject(reason)"], "unconditional lock, then guidance: " + str(steps[1:5])
    assert "battle_result" not in req
    after = req[req.index(f'engine.call("{BUTTON}")'):]
    assert 'engine.get("current_phase") == "unique_skill_target_select"' in after and 'engine.get("is_manual_unique_skill_preview_pending")' in after
    assert after.index("if not accepted:") < after.index('"행동 불가 · 엔진이 특기를 수락하지 않았습니다"') < after.index("_show_skill_targets()"), "button acceptance read back before marks"
    block = f["_skill_block_reason"]
    order = ['_ally_command_block_reason("특기")', 'engine.call("_get_unique_skill_for_unit"', 'engine.get("battle_momentum").get_value("ally")',
             'engine.call("_get_unique_skill_valid_targets"', 'engine.call("_can_use_unique_skill"']
    assert [block.index(x) for x in order] == sorted(block.index(x) for x in order), "shared guidance first, then the engine values and rule"
    assert '"특기 불가 · 기세가 부족합니다 (필요 %d / 현재 %d)" % [skill.get("momentum_cost",0),momentum]' in block, "cost shown from the skill data as the engine returns it"
    block_code = re.sub(r'"[^"\n]*"', '""', block).replace("-> String", "")
    assert not re.search(r"momentum_cost[^\n]*[-+*/]\s*\w|[-+*/]\s*momentum|[-+*/]\s*int\(|\)\s*[-+*/]\s*\d", block_code), "no 3D-side cost arithmetic"
    # Target: only engine valid targets are sent; acceptance (a new skill_cast) read back before reporting.
    click = f["_click_skill_cell"]
    assert click.index("_skill_target_at(cell)") < click.index("if target == null:") < click.index(f'engine.call("{TARGET}"'), "target from the engine query, refusal before the call"
    tail = click[click.index(f'engine.call("{TARGET}"'):]
    assert "if _skill_cast_count() == casts_before:" in tail and tail.index("if _skill_cast_count() == casts_before:") < tail.index("_clear_skill_marks()"), "acceptance from the tactic log"
    assert '"행동 불가 · 엔진이 특기를 수락하지 않았습니다"' in tail and "has_acted" not in click
    assert '_get_unique_skill_valid_targets",caster,engine.call("_get_unique_skill_for_unit",caster))' in f["_skill_target_at"], "valid targets are the engine's"
    world = f["_click_world"]
    assert world.index("_input_locked()") < world.index('== "unique_skill_target_select"') and "_click_skill_cell(cell)" in world, "skill clicks pass the input lock"
    assert code.count("request_skill") == 2 and "skill_button.pressed.connect(request_skill)" in f["_build_attack_ui"], "button only, no hotkey"
    assert "request_skill" not in f["_unhandled_input"], "no new hotkey"
    assert "skill_button.disabled = not skill_block.is_empty()" in f["_sync_views"], "button state from the same guidance"
    lock = f["_input_locked"]
    assert 'engine.get("is_demo_animating")' in lock and "battle_result.is_empty()" in lock, "input lock covers the preview/presentation (demo flag) and the end"

    # Fourth cursor: the exact kinds, the allied-caster filter, everything else skipped.
    consume = f["_consume_tactic_events"]
    assert 'engine.get("tactic_event_log").export()' in consume and "tactic_cursor += 1" in consume
    pattern_lines = re.findall(r'^\t\t\t("[^\n]*"):', consume, re.M)
    kinds = [k for line in pattern_lines for k in re.findall(r'"(\w+)"', line)]
    assert kinds == KINDS and re.search(r"^\t\t\t_:\n\t\t\t\tpass", consume, re.M), "handled kinds exactly: " + str(kinds)
    assert '"skill_cast", "skill_effect", "skill_finished":\n\t\t\t\tif _skill_caster_side(event) == "ally": _present_skill_event(event)' in consume, "allied-caster filter on the skill kinds"
    assert consume.count("_present_skill_event") == 1 and code.count("_present_skill_event(") == 2, "skill events presented only through the filter"
    assert not re.search(r"push_error|assert|\bbreak\b|\breturn\b|quit\(", consume), "other kinds never stop the cursor"
    assert "tactic_cursor = " not in code.replace("var tactic_cursor := 0", ""), "cursor only advances"
    side = f["_skill_caster_side"]
    assert "queries.find_unit(event.caster_id)" in side and "Adapter.to_view(unit).side" in side, "caster side from the adapter view"
    for name in ["_present_skill_event", "_present_skill_effect", "_skill_caster_side", "_skill_line", "_skill_label"]:
        assert not re.search(r"\b(event_cursor|action_cursor|enemy_cursor|tactic_cursor)\b", f[name]), "cursors stay independent: " + name

    # Display values come from the event, never computed.
    present, effect = f["_present_skill_event"], f["_present_skill_effect"]
    assert re.findall(r'^\t\t"(\w+)":', present, re.M) == ["skill_cast", "skill_effect", "skill_finished"]
    assert re.findall(r'^\t\t"(\w+)":', effect, re.M) == EFFECT_KINDS, "six effect indicators"
    for token in ["event.caster_id", "event.momentum_cost", "event.cooldown_turns"]:
        assert token in present, "cast/finish display from the event: " + token
    for token in ["event.target_id", "event.amount", "event.killed", "event.status_id", "event.turns_after", "event.from_cell", "event.to_cell"]:
        assert token in effect, "effect display from the event: " + token
    for name in ["_present_skill_event", "_present_skill_effect", "_skill_name"]:
        body = f[name]
        assert not re.search(r"current_|status_effects|troops|event\.turns\b|get_value|[*/]|[-+]\s*\d|\d\s*[-+]", body.replace("−", "")), "no derived skill numbers: " + name
        args = re.findall(r"%\s*\[([^\]]*)\]", re.sub(r'"[^"\n]*"', '""', body).replace("cooldown_turns == 0", "cooldown_turns"))
        assert not any(re.search(r"(?<![\w.])\d", a) for a in args), "no literal numbers in displayed values: " + name
    assert '"%s 기세 %+d" % ["아군" if target == "ally" else "적",event.amount]' in effect, "momentum effect sign from the event amount"
    labels = re.findall(r"^\t+_skill_label\((.*)\)$", present + "\n" + effect, re.M)
    assert labels == ['event.caster_id,skill_name,Color("e8b8ff")',
                      'target,"−%d%s" % [event.amount,"\\n격파" if event.killed else ""],Color("ffe49b")',
                      'target,"+%d" % event.amount,Color("8fe39a")',
                      'target,"%s %d턴" % [status_name,event.turns_after],Color("7ff2c8")',
                      'target,"%s 해제" % status_name,Color("c8d6e0")'], "floating label texts pinned to the event fields: " + str(labels)
    assert code.count("momentum_note = ") == 2 and 'momentum_note = ""' in present, "momentum note only from the event"
    turn = f["_refresh_turn_ui"]
    assert 'if not _enemy_presentation_busy(): momentum_display = {"ally":engine.get("battle_momentum").get_value("ally"),"enemy":engine.get("battle_momentum").get_value("enemy")}' in turn, "momentum HUD from the engine, refreshed when no replay is pending"
    assert code.count("momentum_display = ") == 1 and "momentum_display[" not in code, "momentum HUD written only from the engine"
    name_body = f["_skill_name"]
    assert '_get_unique_skill_for_unit",unit)' in name_body and 'skill.get("skill_id","") == event.skill_id else event.skill_id' in name_body, "skill name from the caster's engine skill data or the raw id"
    label_body = f["_skill_label"]
    assert "label.text = text" in label_body and 'label.set_meta("skill_label",unit_id)' in label_body
    assert "STATUS_TEXT.get(event.status_id,event.status_id)" in effect, "status names through the shared table, unknown ids as-is"

    for p in CI_TESTS + [HARNESS, EQUIVALENCE]:
        assert "WorldMap.tscn" not in text(p), p
    git("diff", "--check", *rev)
    print(f"M4C1_SKILL validator PASS: base={BASE[:7]} scope={TIP}; {len(changes)} paths; engine/service/adapter diff 0; twelve commands "
          f"(+{BUTTON}, +{TARGET}); {len(props and set(props))} read properties (+battle_momentum.get_value, +preview flag); "
          f"{len(BASE_READ_CALLS | USED_SKILL_READS)} read calls (+{len(USED_SKILL_READS)} skill queries); {len(names)} status names == engine; "
          f"no dice hook / random in 3D; fourth cursor kinds {KINDS} with the allied-caster filter")


if __name__ == "__main__":
    main()
