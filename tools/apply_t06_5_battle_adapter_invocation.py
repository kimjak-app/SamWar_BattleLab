#!/usr/bin/env python3
"""Apply the bounded T06-5 adapter invocation to the Battle_Land entry script.

This tool edits exactly two protected locations and aborts if the expected source
shape has changed. It is intentionally idempotent.
"""

from __future__ import annotations

from pathlib import Path
import sys

TARGET = Path("scripts/battle_web_import_test.gd")
PRELOAD_LINE = 'const HeroBattleDesignInvocationScript := preload("res://scripts/battle/hero_battle_design_invocation.gd")\n'
ANCHOR = 'const BattleFacingArrowTileButtonScript := preload("res://scripts/battle_facing_arrow_tile_button.gd")\n'
OLD_ASSIGNMENT = '\t\t\tvar hero_data := (raw_hero as Dictionary).duplicate(true)\n'
NEW_ASSIGNMENT = (
    '\t\t\tvar legacy_hero_data := (raw_hero as Dictionary).duplicate(true)\n'
    '\t\t\tvar hero_data := HeroBattleDesignInvocationScript.enrich_worldmap_hero_contract(legacy_hero_data)\n'
)


def fail(message: str) -> int:
    print(f"T06-5 PATCH FAILED: {message}", file=sys.stderr)
    return 1


def main() -> int:
    if not TARGET.is_file():
        return fail(f"missing {TARGET}")

    text = TARGET.read_text(encoding="utf-8")
    changed = False

    if PRELOAD_LINE not in text:
        if text.count(ANCHOR) != 1:
            return fail("battle preload anchor missing or duplicated")
        text = text.replace(ANCHOR, ANCHOR + PRELOAD_LINE, 1)
        changed = True

    if NEW_ASSIGNMENT not in text:
        if text.count(OLD_ASSIGNMENT) != 1:
            return fail("hero contract assignment anchor missing or duplicated")
        text = text.replace(OLD_ASSIGNMENT, NEW_ASSIGNMENT, 1)
        changed = True

    if text.count(PRELOAD_LINE) != 1:
        return fail("invocation preload count must be exactly one")
    if text.count(NEW_ASSIGNMENT) != 1:
        return fail("adapter invocation count must be exactly one")

    if changed:
        TARGET.write_text(text, encoding="utf-8")
        print("T06-5 PATCH APPLIED: battle hero contracts now receive design namespaces")
    else:
        print("T06-5 PATCH ALREADY APPLIED")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
