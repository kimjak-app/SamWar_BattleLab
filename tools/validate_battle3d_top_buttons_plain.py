"""HUD polish 1-B: the five top command buttons in one plain text-button style (Kim, 10-25).

Pinned scope (on top of integration 150d179): the command-row script, the block 1
test (its texture checks replaced), this validator, its report and the CI list.
Everything else unchanged (the shell, the lab, the engine, scenes, assets).

The row script no longer uses the 2D top-action textures: all five buttons come
from the same `_temp_button` style with the texts 옵션 / 속도\\n×1 / 자동\\n전투 /
턴 종료 / 후퇴; a disabled button has its own dimmed style; auto is lit (a brighter
gold border and text) while on; geometry, hover/press scales, retreat
(disabled, no handler, tooltip) and the callables are as before; no engine access.

In the block 1 test only the texture check is removed; every other removed check
must be kept inside its replacement (its conditions still present), so no
position, behaviour or retreat check is weakened. The block 1 validator
(validate_battle3d_top_commands.py) is unchanged: it audits its own pinned range
(2b08270..923c149), where the textures are still used.

TOP_BUTTONS_PLAIN_SCOPE_TIP=<commit> audits BASE..commit and reads every file and
file list from that commit's tree; HEAD audits the live worktree.
"""
from pathlib import Path
import argparse, os, re, subprocess

BASE = "150d179928a4b0d56d49d4ea9f1c9f6788427f1d"  # Merge feature/hud-read-proposals-20261024 (docs)
TIP = os.environ.get("TOP_BUTTONS_PLAIN_SCOPE_TIP", "HEAD")
ROW = "scripts/battle3d/battle3d_top_commands.gd"
TEST = "tests/scripts/test_battle3d_top_commands.gd"
WORKFLOW = ".github/workflows/verify-c-track.yml"
VALIDATOR = "tools/validate_battle3d_top_buttons_plain.py"
REPORT = "agent/HUD_POLISH1_B_TOP_BUTTONS_RESULT_20261025.md"
NEW = {VALIDATOR, REPORT}
MODIFIED = {ROW, TEST, WORKFLOW}
RANDOM = r"\b(randf|randi|randf_range|randi_range|randfn|RandomNumberGenerator)\b|\bseed\s*\(|pick_random|shuffle"


def strip_comments(source):
    return "\n".join(line.split("#", 1)[0].rstrip() for line in source.splitlines())


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    root = parser.parse_args().root.resolve()

    def git(*args):
        return subprocess.check_output(["git", "-C", str(root), *args])

    live = TIP == "HEAD"
    rev = [BASE] if live else [BASE, TIP]

    def text(path):
        data = (root / path).read_bytes() if live else git("show", f"{TIP}:{path}")
        return data.decode("utf-8").replace("\r\n", "\n")

    changes = dict((line.split("\t", 1)[1], line.split("\t", 1)[0]) for line in
                   git("diff", "--no-renames", "--name-status", *rev).decode().splitlines())
    if live:
        for p in git("ls-files", "--others", "--exclude-standard").decode().splitlines():
            changes.setdefault(p, "A")
        tree = set(git("ls-files").decode().splitlines()) | {p for p, s in changes.items() if s == "A"}
    else:
        tree = set(git("ls-tree", "-r", "--name-only", TIP).decode().splitlines())
    for p, status in changes.items():
        assert (p in MODIFIED and status == "M") or (p in NEW and status == "A"), ("out of scope", status, p)
    assert VALIDATOR in tree and ROW in tree and TEST in tree
    wf_diff = git("diff", "--unified=0", *rev, "--", WORKFLOW).decode()
    assert not any(x.startswith("-") and not x.startswith("---") for x in wf_diff.splitlines()), "workflow additions only"
    assert [x[1:].strip() for x in wf_diff.splitlines() if x.startswith("+") and not x.startswith("+++")] == [VALIDATOR], "workflow: this validator only"

    row = strip_comments(text(ROW))
    assert "top_actions" not in row and "TextureButton" not in row and "texture" not in row.lower(), "no 2D top-action picture in the row"
    assert "engine" not in row and not re.search(RANDOM, row), "row: no engine access, no random"
    calls = re.findall(r'_temp_button\("([^"]*)", (\d)\)', row)
    assert calls == [("옵션", "0"), ("속도\\n×1", "1"), ("자동\\n전투", "2"), ("턴 종료", "3"), ("후퇴", "4")], ("five buttons, one style", calls)
    assert 'add_theme_stylebox_override("disabled", _style(DIM_FILL, DIM_BORDER, 2))' in row and 'add_theme_color_override("font_disabled_color", DIM_TEXT)' in row, "disabled style dimmed"
    assert "_set_lit(auto_button, auto_on)" in row and "LIT_BORDER if lit else TEMP_BORDER" in row, "auto lit while on (border/text), its text unchanged"
    assert "retreat_button.disabled = true" in row and "retreat_button.pressed.connect" not in row and 'const RETREAT_TOOLTIP := "월드맵 연결 후 사용"' in text(ROW), "retreat unchanged"
    for const in ['const BUTTON_SIZE := Vector2(68.0, 68.0)', 'const BUTTON_GAP := 18.0', 'const ROW_Y := 27.0', 'const FIRST_X := 1435.0',
                  'const HOVER_SCALE := Vector2(1.07, 1.07)', 'const PRESS_SCALE := Vector2(0.94, 0.94)', 'const TWEEN_DURATION := 0.11']:
        assert const in row, "geometry/scales unchanged: " + const
    assert row.count("if on_") == 4, "the four callables as before"

    # The block 1 test: only the texture check removed; other removed checks kept inside their replacements.
    t_diff = git("diff", "--unified=0", *rev, "--", TEST).decode().splitlines()
    removed = [x[1:] for x in t_diff if x.startswith("-") and not x.startswith("---")]
    added = "\n".join(x[1:] for x in t_diff if x.startswith("+") and not x.startswith("+++"))
    for line in removed:
        code = line.split("#", 1)[0].strip()
        if not code or "texture" in code: continue
        cond = code.split('h.expect(', 1)[-1].rsplit(', "', 1)[0]
        pieces = [p.strip() for p in re.split(r"\band\b", cond) if p.strip()]
        assert all(p in added for p in pieces), ("a removed test check is not kept in its replacement", line)
    for needle in ['x is Button and not x is TextureButton and x.icon == null', 'need.x <= 68.0 and need.y <= 68.0', 'dis.border_color.a < border0.a',
                   'handlers(cmd.retreat_button).is_empty()', 'Rect2(xs[i], 27, 68, 68)']:
        assert needle in text(TEST), "test check present: " + needle
    git("diff", "--check", *rev)
    print(f"TOP_BUTTONS_PLAIN validator PASS: base={BASE[:7]} scope={TIP}; {len(changes)} paths; five text buttons in one style, no 2D picture; "
          f"disabled dimmed, auto lit; geometry/behaviour/retreat unchanged; test checks only the texture one replaced")


if __name__ == "__main__":
    main()
