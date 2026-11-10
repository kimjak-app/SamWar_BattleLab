#!/usr/bin/env python3
"""Queue 35: writes the Hansando sea board (heightfield + terrain types) for the naval 3D battle scenario.

The board has the land board's shape (20x20 cells of 3 m, heights every 0.5 m, play area = the top-left 18x10).
Sea is height 0; an island rises only inside its own cells (0.3 m inside their edge), so a ship in the next cell
never touches it. Island cells inside the play area are the cells no ship may enter.
Run: python tools/build_naval_hansando_terrain.py   (deterministic; rewrites the two files under assets/battle3d/naval/)
"""
import json, math, os

W = H = 20
CELL = 3.0
STEP = 0.5
N = int(W * CELL / STEP) + 1
PLAY = (18, 10)
# name: (peak height m, cells)
ISLANDS = {
    "strait_west": (2.2, [(5, 1), (6, 1), (5, 2), (6, 2), (6, 3)]),
    "strait_east": (2.4, [(10, 1), (11, 1), (10, 2), (11, 2), (11, 3)]),
    "islet_west": (0.9, [(3, 5)]),
    "islet_east": (1.3, [(14, 5), (15, 5)]),
    "hansan": (2.8, [(8, 9), (9, 9), (10, 9), (9, 8)]),
    # scenery (outside the 18x10 play area)
    "hansan_south": (4.2, [(7, 10), (8, 10), (9, 10), (10, 10), (11, 10), (8, 11), (9, 11), (10, 11), (9, 12)]),
    "south_west": (3.2, [(1, 12), (2, 12), (1, 13), (2, 13), (3, 13), (2, 14)]),
    "south_east": (3.6, [(14, 13), (15, 13), (16, 13), (15, 14), (16, 14), (16, 15)]),
    "far_south": (5.0, [(5, 17), (6, 17), (7, 17), (8, 17), (5, 18), (6, 18), (7, 18), (8, 18), (9, 18), (6, 19), (7, 19), (8, 19)]),
    "far_south_east": (4.4, [(12, 17), (13, 17), (12, 18), (13, 18), (14, 18), (13, 19), (14, 19)]),
    "east_coast": (3.0, [(18, 3), (19, 3), (18, 4), (19, 4), (19, 5), (18, 8), (19, 8), (19, 9)]),
}
MARGIN = 0.25  # m: the shore stays this far inside the island's cells
SPREAD = 1.1   # m: how far a cell's ground spreads from its centre (rounds the coast)


def noise(x, z):
    return (math.sin(x * 1.7 + z * 0.9) * 0.5 + math.sin(x * 0.6 - z * 2.3 + 1.3) * 0.3 + math.sin((x + z) * 3.1) * 0.2)


def inside_distance(x, z, cells):
    """Distance (m) from (x, z) to the nearest point outside the island's cells; 0 when outside."""
    cx, cz = int(math.floor(x / CELL)), int(math.floor(z / CELL))
    if (cx, cz) not in cells and (cx - (1 if x % CELL == 0 else 0), cz) not in cells and (cx, cz - (1 if z % CELL == 0 else 0)) not in cells:
        return 0.0
    best = 9.0
    for dx in range(-3, 4):
        for dz in range(-3, 4):
            c = (cx + dx, cz + dz)
            if c in cells:
                continue
            nx = min(max(x, c[0] * CELL), (c[0] + 1) * CELL)
            nz = min(max(z, c[1] * CELL), (c[1] + 1) * CELL)
            best = min(best, math.hypot(x - nx, z - nz))
    return best


def smooth(t):
    t = min(1.0, max(0.0, t))
    return t * t * (3 - 2 * t)


def main():
    heights = [[0.0] * N for _ in range(N)]
    types = [["sea"] * W for _ in range(H)]
    for name, (peak, cells) in ISLANDS.items():
        cell_set = set(cells)
        for (cx, cz) in cells:
            assert 0 <= cx < W and 0 <= cz < H, (name, cx, cz)
            assert types[cz][cx] == "sea", (name, cx, cz)
            types[cz][cx] = "island"
        for j in range(N):
            for i in range(N):
                x, z = i * STEP, j * STEP
                d = inside_distance(x, z, cell_set) - MARGIN
                if d <= 0:
                    continue
                # rounded ground: each cell spreads from its centre, the cells of one island merge
                f = sum(math.exp(-((x - (cx + 0.5) * CELL) ** 2 + (z - (cz + 0.5) * CELL) ** 2) / (2 * SPREAD * SPREAD)) for (cx, cz) in cells)
                f += 0.08 * noise(x * 1.4, z * 1.4)
                body = smooth((f - 0.40) / 0.55) * smooth(d / 0.45)
                if body <= 0:
                    continue
                h = peak * body * (0.82 + 0.18 * noise(x, z)) + 0.1 * smooth(body / 0.15)
                heights[j][i] = max(heights[j][i], round(h, 3))
    play_islands = sum(1 for z in range(PLAY[1]) for x in range(PLAY[0]) if types[z][x] == "island")
    assert 10 <= play_islands <= 18, play_islands
    out = os.path.join(os.path.dirname(__file__), "..", "assets", "battle3d", "naval")
    os.makedirs(out, exist_ok=True)
    board = {"width": W, "height": H, "cell_size": CELL, "sample_step": STEP, "river_center": -300.0, "ford_row": -100}
    with open(os.path.join(out, "heightfield_hansando.json"), "w", encoding="utf-8", newline="\n") as f:
        json.dump({"step": STEP, "nx": N, "nz": N, "heights": heights, "board": board}, f, separators=(",", ":"))
        f.write("\n")
    with open(os.path.join(out, "terrain_types_hansando.json"), "w", encoding="utf-8", newline="\n") as f:
        json.dump({"width": W, "height": H, "cell_size": CELL, "river_center": -300.0, "ford_row": -100, "sea_level": 0.0,
                   "islands": {k: [list(c) for c in v[1]] for k, v in ISLANDS.items()}, "cells": types}, f, separators=(",", ":"))
        f.write("\n")
    print("islands in play area: %d cells; max height %.2f" % (play_islands, max(max(r) for r in heights)))
    for row in types[:PLAY[1]]:
        print("".join("#" if c == "island" else "." for c in row[:PLAY[0]]))


if __name__ == "__main__":
    main()
