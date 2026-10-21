"""M4-b 3D strategy command: pinned scope, zero engine/service/adapter diff,
exactly ten engine write calls (M4-a eight + `_on_strategy_button_pressed`,
`_try_use_strategy_on_target`), read boundary = M4-a + the approved strategy
queries and `tactic_event_log`, a fourth independent cursor that handles only
strategy_cast/status_tick, no 3D-side strategy numbers, no dice hook and no
random calls in 3D, no world-map/result/skill/reinforcement calls.

M4B_SCOPE_TIP=<commit> audits BASE..commit; HEAD (default until the reviewer
re-pins the merged implementation commit) audits the live worktree.
"""
from pathlib import Path
import argparse, hashlib, os, re, subprocess

BASE = "b3386e9998570d862ddc0a7602f6a04b8badcd6c"  # docs(battle): pin S4-1 validator ...
TIP = os.environ.get("M4B_SCOPE_TIP", "HEAD")
PLAY = "scripts/battle3d/battle3d_engine_play.gd"
WORKFLOW = ".github/workflows/verify-c-track.yml"
VALIDATOR = "tools/validate_battle3d_m4b_strategy.py"
REPORT = "agent/BATTLE3D_M4B_RESULT_20261022.md"
HARNESS = "tests/scripts/support/battle3d_strategy_harness.gd"
CI_TESTS = ["tests/scripts/test_battle3d_strategy_equivalence.gd", "tests/scripts/test_battle3d_strategy_default_round.gd",
            "tests/scripts/test_battle3d_strategy_rejections.gd", "tests/scripts/test_battle3d_strategy_mixed_log.gd"]
NEW = {VALIDATOR, REPORT, HARNESS, *CI_TESTS}
NEW |= {p + ".uid" for p in list(NEW) if p.endswith(".gd")}
MODIFIED = {PLAY, WORKFLOW}
PROTECTED = ["scripts/battle_web_import_test.gd", "scripts/battle_unit_state.gd", "scripts/battle3d/lab_presentation.gd",
             "scripts/battle3d/battle3d_unit_adapter.gd", "scripts/battle3d/battle3d_engine_host.gd", "scripts/battle3d/battle3d_movement_adapter.gd",
             "scripts/battle/services/battle_tactic_event_log_service.gd",
             "tests/scripts/support/battle3d_defend_harness.gd", "tests/scripts/support/battle3d_wait_harness.gd",
             "tests/scripts/support/battle3d_enemy_turn_harness.gd", "tests/scripts/support/battle3d_engine_attack_harness.gd",
             "tests/scripts/support/battle_enemy_turn_oracle_harness.gd", "tests/scripts/support/battle_tactic_oracle_harness.gd",
             "tools/validate_battle3d_m1b_engine_move.py", "tools/validate_battle3d_m2_engine_attack.py", "tools/validate_battle3d_m3_enemy_turn.py",
             "tools/validate_battle3d_m3b_wait.py", "tools/validate_battle3d_m4a_defend.py", "tools/validate_battle_enemy_events_s3_1.py",
             "tools/validate_battle_tactic_events_s4_1.py", "tools/validate_battle3d_contract.py"]
GOLDENS = {"tests/golden/battle_attack_baseline_v0.json": "d018cbe618c06043ea6ac6fd22c8a56faa42f284d4e6613f01bfa98dad3dd91c",
           "tests/golden/battle_move_baseline_v0.json": "b35d3f7987bb2efca5efe1d379b6eddc00cdca1558c17e88733dd1389cf714bd",
           "tests/golden/battle_enemy_turn_baseline_v0.json": "a3795131b8d2c525f7c096683d98b543410c01a130930783961dab671d9887f7",
           "tests/golden/battle3d_m3_start_v0.json": "c1a1291fa0a2f23307b67316db64a3c663c38d43e15fd904f5b4e4e67921926a",
           "tests/golden/battle_tactic_baseline_v0.json": "2693536d50b23799ee3e63e4419912bf08929ea40c516bb86f284f959811db2d"}
WAIT, DEFEND = "_end_ally_turn_by_wait", "_on_defend_button_pressed"
BUTTON, TARGET = "_on_strategy_button_pressed", "_try_use_strategy_on_target"
COMMANDS = {"_select_ally_unit", "_try_direct_move_to_cell", "_select_post_move_facing", "_handle_right_click_cancel", "try_basic_attack",
            "_try_attack_enemy_target_from_attack_select", WAIT, DEFEND, BUTTON, TARGET}
# M4-a read calls + the strategy queries confirmed pure in pre-check 2 (`_get_strategy_range` is not used).
READ_CALLS = {"_get_alive_enemy_units", "is_unit_in_attack_range", "_is_unit_state_available_for_battle_slot",
              "_can_use_strategy", "_get_strategy_targets", "_get_strategy_success_rate"}
READ_PROPERTIES = {"current_phase", "is_demo_animating", "active_unit_state", "all_battle_unit_states", "battle_action_event_log",
                   "ally_move_event_log", "battle_grid_controller", "enemy_action_event_log", "tactic_event_log"}
VIEW_FIELDS = {"unit_id", "side", "unit_type", "grid_cell", "facing", "current_troops", "max_troops", "allocated_troops", "footprint",
               "has_moved", "has_acted", "status_effects", "move_range", "attack_range"}
FORBIDDEN = r"worldmap|world_map|WorldMap|payload|result_toast|result_video|_try_show_battle_result|change_scene|samwar_worldmap|" \
            r"_recover_wounded_troops_for_defend|_auto_wait_active_ally|_play_enemy|_start_new_round|full_auto|" \
            r"_mark_enemy_unit_acted|_mark_ally_unit_acted|_return_to_ally_turn|_finish_enemy_actor|_finish_enemy_basic|_enemy_reaction_hit_on|" \
            r"_on_unique_skill_button_pressed|_try_use_unique_skill|_begin_unique_skill|_try_auto_unique_skill|_deploy_reinforce|_deploy_city_reinforcement|_try_deploy|" \
            r"_resolve_strategy|_roll_strategy_outcome|_strategy_roll_|_enter_strategy_target_select_mode|_consume_strategy_status|" \
            r"strategy_roll_override|_get_strategy_range|_get_strategy_outcome_pool"
RULE_TOKENS = r"\brandf\b|\brandi\b|randf_range|randi_range|RandomNumberGenerator|\bseed\s*\(|intelligence|STRATEGY_|get_status_magnitude|" \
              r"apply_status_effect|tick_status_effects|apply_damage|max_hp|current_hp|0\.55|magnitude"
CHANGED_FUNCTIONS = {"_build_ui", "_build_attack_ui", "_process", "_sync_views", "_refresh_turn_ui", "_refresh_info", "_click_world",
                     "_unhandled_input", "_present_enemy_event"}
NEW_FUNCTIONS = {"_clear_strategy_marks", "_click_strategy_cell", "_consume_tactic_events", "_enemy_completion_pending", "_flush_enemy_ticks",
                 "_hover_strategy_cell", "_present_status_tick", "_present_strategy_cast", "_rate_text", "_show_strategy_targets",
                 "_status_suffix", "_status_text", "_strategy_block_reason", "_strategy_cast_count", "_strategy_target_at",
                 "_tactic_label", "_tactic_text", "request_strategy"}
NEW_MEMBERS = {"STATUS_TEXT", "pending_enemy_ticks", "status_display", "strategy_button", "strategy_marks", "strategy_target_ids",
               "tactic_cursor", "tactic_presentations", "tactic_texts"}


def check_state_writes(code):
    fields = r"(?:grid_cell|has_moved|has_acted|current_phase|ally_has_moved|last_action|current_troops|current_hp|is_defending|" \
             r"facing|status_effects|battle_round|is_demo_animating|active_unit_state|move_range|attack_range|side|intelligence|" \
             r"max_troops|allocated_troops|dead_unit_ids|battle_momentum|strategy_targeting_caster_state)"
    assignment = r"\s*(?:[+*/%&|^\-]|<<|>>|\*\*)?=(?!=)"
    assert not re.search(r"\b(?:unit|candidate|target|active|caster|waited|defended|engine)\." + fields + assignment, code), "state assignment"
    assert not re.search(r"\[\s*['\"]" + fields + r"['\"]\s*\]" + assignment, code), "indexed state assignment"
    assert not re.search(r"\.(?:set|set_deferred)\(\s*['\"]" + fields + r"['\"]", code), "state property setter"


def functions(code):
    return {m.group(1): m.group(0).rstrip() for m in re.finditer(r"^func (\w+)\([^\n]*\).*?(?=^func |\Z)", code, re.M | re.S)}


def strip_comments(source):
    return "\n".join(line.split("#", 1)[0] for line in source.splitlines())


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
    assert set(calls) == COMMANDS | READ_CALLS, "exact ten commands and approved read calls: " + str(set(calls) ^ (COMMANDS | READ_CALLS))
    assert len(COMMANDS) == 10 and all(calls.count(c) == 1 for c in [WAIT, DEFEND, BUTTON, TARGET]), "one call site per end command"
    assert len(re.findall(r"engine\.call\(", code)) == len(calls), "no dynamic method names"
    props = re.findall(r'engine\.get\("([^"\n]+)"\)', code)
    assert set(props) == READ_PROPERTIES, "read properties: " + str(set(props) ^ READ_PROPERTIES)
    assert len(re.findall(r"engine\.get\(", code)) == len(props), "no dynamic property names"
    assert not re.search(r"engine\.(?!get\(|call\()\w+", code), "no alternate engine access"
    check_state_writes(code)
    assert not re.search(FORBIDDEN, code), "forbidden call/rule: " + str(re.findall(FORBIDDEN, code))
    assert not re.search(RULE_TOKENS, code), "3D strategy/status rule or random: " + str(re.findall(RULE_TOKENS, code))
    reads = set(re.findall(r"\b(?:unit|candidate|target|active|waited|defended|caster)\.(\w+)", code))
    assert reads <= VIEW_FIELDS | {"is_defending"}, reads
    f, old_f = functions(code), functions(old_code)
    assert set(f) - set(old_f) == NEW_FUNCTIONS, "new functions: " + str((set(f) - set(old_f)) ^ NEW_FUNCTIONS)
    changed = {n for n in old_f if f.get(n) != old_f[n]}
    assert changed <= CHANGED_FUNCTIONS, "only listed shared functions change: " + str(changed - CHANGED_FUNCTIONS)
    members = lambda s: set(re.findall(r"^(?:var|const) (\w+)", s, re.M))
    assert members(code) - members(old_code) == NEW_MEMBERS, "new members: " + str(members(code) - members(old_code))
    readers = {n for n, body in f.items() if re.search(r"\.is_defending\b", body)}
    assert readers == {"_refresh_target_info", "_unit_defending"}, "is_defending readers unchanged: " + str(readers)

    # Button: input lock, then guidance, then the button command; acceptance read back.
    req = f["request_strategy"]
    steps = [x.strip() for x in req.splitlines() if x.strip()]
    assert steps[1:5] == ["if not ready_for_input or _input_locked(): return", "var reason := _strategy_block_reason()",
                          "if not reason.is_empty():", "_reject(reason)"], "unconditional lock, then guidance: " + str(steps[1:5])
    assert "battle_result" not in req
    after = req[req.index(f'engine.call("{BUTTON}")'):]
    assert 'if engine.get("current_phase") != "strategy":' in after and '"행동 불가 · 엔진이 책략을 수락하지 않았습니다"' in after, "button acceptance read back"
    block = f["_strategy_block_reason"]
    assert block.index('_ally_command_block_reason("책략")') < block.index('engine.call("_can_use_strategy"') < block.index('engine.call("_get_strategy_targets"'), "shared guidance first, then the engine rule"
    # Target: only engine strategy targets are sent; acceptance read back before reporting.
    click = f["_click_strategy_cell"]
    assert click.index("_strategy_target_at(cell)") < click.index("if target == null:") < click.index(f'engine.call("{TARGET}"'), "target from the engine query, refusal before the call"
    tail = click[click.index(f'engine.call("{TARGET}"'):]
    assert "_strategy_cast_count() > casts_before" in tail and "has_acted" in tail and "if not accepted:" in tail, "acceptance from the tactic log / has_acted"
    assert tail.index("if not accepted:") < tail.index("_clear_strategy_marks()") and '"행동 불가 · 엔진이 책략을 수락하지 않았습니다"' in tail
    assert "is_defending" not in click and "status_effects" not in click
    assert '_get_strategy_targets",engine.get("active_unit_state"))' in f["_strategy_target_at"], "valid targets are the engine's"
    world = f["_click_world"]
    assert world.index("_input_locked()") < world.index('== "strategy"') and "_click_strategy_cell(cell)" in world, "strategy clicks pass the input lock"
    assert code.count("request_strategy") == 2 and "strategy_button.pressed.connect(request_strategy)" in f["_build_attack_ui"], "button only, no hotkey"
    assert "request_strategy" not in f["_unhandled_input"] and "KEY_" not in f["_unhandled_input"].replace("KEY_F", ""), "no new hotkey"
    assert "strategy_button.disabled = not strategy_block.is_empty()" in f["_sync_views"], "button state from the same guidance"

    # Fourth cursor: reads the whole log, handles two kinds, skips the rest.
    consume = f["_consume_tactic_events"]
    assert 'engine.get("tactic_event_log").export()' in consume and "tactic_cursor += 1" in consume
    assert re.findall(r'^\t\t\t"(\w+)":', consume, re.M) == ["strategy_cast", "status_tick"] and re.search(r"^\t\t\t_:\n\t\t\t\tpass", consume, re.M), "two kinds handled, others skipped"
    assert not re.search(r"push_error|assert|\bbreak\b|\breturn\b|quit\(", consume), "other kinds never stop the cursor"
    assert re.findall(r"\btactic_cursor\b", code).count("tactic_cursor") == 4 and "tactic_cursor = " not in code.replace("var tactic_cursor := 0", ""), "cursor only advances"
    for name in ["_consume_tactic_events", "_present_strategy_cast", "_present_status_tick"]:
        assert not re.search(r"\b(event_cursor|action_cursor|enemy_cursor)\b", f[name]), "cursors stay independent: " + name
    assert "_consume_tactic_events()" in f["_process"] and "_flush_enemy_ticks(event.unit_id)" in f["_present_enemy_event"]
    # Display values come from the event / engine state, never computed.
    cast = f["_present_strategy_cast"]
    for token in ["event.success", "event.turns_after", "event.status_id", "event.success_rate"]:
        assert token in cast, "strategy display from the event: " + token
    assert not re.search(r"current_|status_effects|event\.turns\b|[-+*/]\s*\d", cast), "no derived strategy numbers"
    assert cast.count('"성공" if event.success else "실패"') == 2 and "else \"성공\"" not in cast and 'Color("7ff2c8") if event.success else Color("ff5f78")' in cast, "outcome text follows event.success"
    for name in ["_present_strategy_cast", "_present_status_tick"]:
        args = re.findall(r"%\s*\[([^\]]*)\]", f[name])
        assert not any(re.search(r"(?<![\w.])\d", a) for a in args), "no literal numbers in displayed values: " + name
    tick = f["_present_status_tick"]
    assert "event.burn_damage" in tick and "event.expired" in tick and not re.search(r"current_|troops|status_effects|[*/]", tick), "tick display from the event"
    assert "rate*100.0" in f["_rate_text"] and len(re.findall(r"\*", code)) == len(re.findall(r"\*", old_code)) + 1, "only formatting multiplies (rate * 100)"
    suffix = f["_status_suffix"]
    assert "value.status_effects" in suffix and "if not _enemy_presentation_busy(): status_display[unit_id]" in suffix, "status from the adapter view, refreshed when no replay is pending"
    assert "status_display[" not in code.replace("status_display[unit_id] = value.status_effects", ""), "status_display written only from the engine view"

    for p in CI_TESTS + [HARNESS]:
        assert "WorldMap.tscn" not in text(p) and "Battle_Main.tscn" not in text(p), p
    git("diff", "--check", *rev)
    print(f"M4B_STRATEGY validator PASS: base={BASE[:7]} scope={TIP}; {len(changes)} paths; engine/service/adapter diff 0; ten commands "
          f"(+{BUTTON}, +{TARGET}); {len(READ_PROPERTIES)} read properties (+tactic_event_log); {len(READ_CALLS)} read calls (+3 strategy queries); "
          f"no dice hook / random in 3D; fourth cursor handles strategy_cast/status_tick only")


if __name__ == "__main__":
    main()
