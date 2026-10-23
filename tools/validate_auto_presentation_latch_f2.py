"""F2 auto presentation step latch (engine + 3D).

Pinned scope: the engine adds one member (`auto_presentation_latch := false`),
turns it on only from a hold sent by the 3D (`set_auto_presentation_hold(true)`,
signature unchanged), and re-arms the hold at the start of each auto step only
while it is on (no 3D = latch off = the engine auto unchanged). The 3D compares
its wanted hold with the engine's own hold too (one new read, no new write), so
a latched hold is always released. Nothing else changes.

F2_SCOPE_TIP=<commit> audits BASE..commit; HEAD (default until the reviewer
pins the merged commit) audits the live worktree.
"""
from pathlib import Path
import argparse, os, re, subprocess

BASE = "5763d63bedb55a39c4a76cc86242b53eec7704af"  # docs(battle): restore the night3 fix report text (before the F2 latch)
TIP = os.environ.get("F2_SCOPE_TIP", "HEAD")
ENGINE = "scripts/battle_web_import_test.gd"
PLAY = "scripts/battle3d/battle3d_engine_play.gd"
WORKFLOW = ".github/workflows/verify-c-track.yml"
VALIDATOR = "tools/validate_auto_presentation_latch_f2.py"
TEST = "tests/scripts/test_battle_auto_presentation_latch.gd"
REPORT = "agent/NIGHT3_FIX_RESULT_20261023.md"
NEW = {VALIDATOR, TEST, TEST + ".uid"}
MODIFIED = {ENGINE, PLAY, WORKFLOW, REPORT}
CI_ADDED = [VALIDATOR, TEST]


def functions(code):
    out = {}
    for m in re.finditer(r"^(?:static )?func (\w+)\(.*?(?=^(?:static )?func |\Z)", code, re.M | re.S):
        lines = m.group(0).split("\n")
        out[m.group(1)] = "\n".join([lines[0]] + [x for x in lines[1:] if x.startswith("\t")])
    return out


def strip_comments(source):
    return "\n".join(line.split("#", 1)[0].rstrip() for line in source.splitlines())


def added_removed(new, old):
    n = [x for x in new.splitlines() if x.strip()]
    o = [x for x in old.splitlines() if x.strip()]
    return [x for x in n if x not in o], [x for x in o if x not in n]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    root = parser.parse_args().root.resolve()

    def git(*args):
        return subprocess.check_output(["git", "-C", str(root), *args])

    live = TIP == "HEAD"
    rev = [BASE] if live else [BASE, TIP]

    def text(path, base=False):
        raw = (root / path).read_bytes() if live and not base else git("show", f"{BASE if base else TIP}:{path}")
        return raw.decode("utf-8").replace("\r\n", "\n")

    changes = dict((line.split("\t", 1)[1], line.split("\t", 1)[0]) for line in
                   git("diff", "--no-renames", "--name-status", *rev).decode().splitlines())
    if live:
        for p in git("ls-files", "--others", "--exclude-standard").decode().splitlines():
            changes.setdefault(p, "A")
    for p, status in changes.items():
        assert (p in MODIFIED and status == "M") or (p in NEW and status == "A"), ("out of scope", status, p)
    wf_diff = git("diff", "--unified=0", *rev, "--", WORKFLOW).decode()
    assert not any(x.startswith("-") and not x.startswith("---") for x in wf_diff.splitlines()), "workflow additions only"
    added = [x[1:].strip() for x in wf_diff.splitlines() if x.startswith("+") and not x.startswith("+++")]
    assert sorted(added) == sorted(CI_ADDED) or added == [], added

    # Engine.
    code, old = strip_comments(text(ENGINE)), strip_comments(text(ENGINE, True))
    f, of = functions(code), functions(old)
    assert set(f) == set(of), "no function added or removed"
    changed = {n for n in of if f[n] != of[n]}
    assert changed == {"set_auto_presentation_hold", "_tick_full_auto_battle_if_needed"}, changed
    a, r = added_removed(f["set_auto_presentation_hold"], of["set_auto_presentation_hold"])
    assert a == ["\tif hold:", "\t\tauto_presentation_latch = true"] and r == [], (a, r)
    assert f["set_auto_presentation_hold"].split("\n")[0] == "func set_auto_presentation_hold(hold: bool) -> void:", "signature unchanged"
    a, r = added_removed(f["_tick_full_auto_battle_if_needed"], of["_tick_full_auto_battle_if_needed"])
    assert a == ["\tif auto_presentation_latch:", "\t\tauto_presentation_hold = true"] and r == [], (a, r)
    tick = f["_tick_full_auto_battle_if_needed"]
    assert tick.index("auto_battle_step_count += 1") < tick.index("\tif auto_presentation_latch:") < tick.index("_run_auto_action_for_active_ally_once()"), "re-armed at the step start, before the action"
    top = lambda s: [x.split(" #")[0].rstrip() for x in s.splitlines() if x and not x.startswith(("\t", " ", "func "))]
    assert [x for x in top(code) if x not in top(old)] == ["var auto_presentation_latch := false"] and not [x for x in top(old) if x not in top(code)], "one new member, default off"
    assert len(re.findall(r"auto_presentation_latch = true", code)) == 1 and "auto_presentation_latch = false" not in code, "latch turned on only by a hold from the 3D"

    # 3D.
    play, old_play = strip_comments(text(PLAY)), strip_comments(text(PLAY, True))
    pf, opf = functions(play), functions(old_play)
    assert {n for n in opf if pf.get(n) != opf[n]} == {"_update_auto_hold"} and set(pf) == set(opf), "only _update_auto_hold changes"
    a, r = added_removed(pf["_update_auto_hold"], opf["_update_auto_hold"])
    assert a == ['\tvar engine_hold: bool = engine.get("auto_presentation_hold")', "\tif hold == auto_hold_sent and hold == engine_hold: return"] and r == ["\tif hold == auto_hold_sent: return"], (a, r)
    assert len(re.findall(r'engine\.call\("set_auto_presentation_hold"', play)) == 1, "one call site, unchanged"
    assert re.findall(r'engine\.call\("([^"\n]+)"', play) == re.findall(r'engine\.call\("([^"\n]+)"', old_play), "no new engine call"
    new_reads = set(re.findall(r'engine\.get\("([^"\n]+)"\)', play)) - set(re.findall(r'engine\.get\("([^"\n]+)"\)', old_play))
    assert new_reads == {"auto_presentation_hold"}, new_reads
    git("diff", "--check", *rev)
    print(f"F2_PRESENTATION_LATCH validator PASS: base={BASE} scope={TIP}; {len(changes)} paths; engine: latch member (default off) on by a 3D hold, "
          f"re-arms at the step start; 3D: release compared with the engine hold (one read, no new write)")


if __name__ == "__main__":
    main()
