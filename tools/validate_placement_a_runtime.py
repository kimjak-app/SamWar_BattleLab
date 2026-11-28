#!/usr/bin/env python3
"""Queue 46 (addendum 9): the runtime placement file is exported and up to date.

- data/worldmap/placement_a_runtime.json is byte-identical to a fresh build from data/heroes/source/
  (tools/make_placement_a_runtime.py --check);
- it sits outside every .gdignore folder (a .gdignore folder is left out of the export), while data/heroes/source/
  keeps its .gdignore;
- the game reads the runtime file, not the working sources.
"""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RUNTIME = ROOT / "data/worldmap/placement_a_runtime.json"
PLACEMENT_SCRIPT = ROOT / "scripts/worldmap/worldmap_placement_a.gd"


def main() -> int:
    result = subprocess.run([sys.executable, str(ROOT / "tools/make_placement_a_runtime.py"), "--check"], capture_output=True, text=True)
    assert result.returncode == 0, result.stderr.strip() or result.stdout.strip()
    folder = RUNTIME.parent
    while folder != ROOT.parent:
        assert not (folder / ".gdignore").exists(), f"runtime file under a .gdignore folder: {folder}"
        folder = folder.parent
    assert (ROOT / "data/heroes/source/.gdignore").exists(), "data/heroes/source/ must stay out of the export"
    script = PLACEMENT_SCRIPT.read_text(encoding="utf-8")
    assert '"res://data/worldmap/placement_a_runtime.json"' in script, "WorldMapPlacementA must read the runtime file"
    assert "res://data/heroes/source/" not in script, "WorldMapPlacementA must not read the working sources at run time"
    print("PLACEMENT A RUNTIME PASS: runtime file up to date, outside .gdignore, read by WorldMapPlacementA")
    return 0


if __name__ == "__main__":
    sys.exit(main())
