"""Shared helper for .tscn node-header contract checks.

Godot 4.6 re-saves scenes with ``unique_id=<int>`` attributes on node headers. A
validator that matches the whole header as one literal string therefore breaks on a
harmless re-save. ``has_node_header`` keeps the contract exactly as strict as before
(same node name, type, parent, instance, same attribute order) and only tolerates
the optional ``unique_id`` attribute between/after the attributes.
"""

import re
import shlex


def _tokens(header: str) -> list[str]:
    assert header.startswith("[node ") and header.endswith("]"), f"not a node header: {header}"
    # shlex keeps quoted attribute values (including parentheses) intact.
    return shlex.split(header[len("[node "):-1], posix=False)


def node_header_pattern(header: str) -> re.Pattern:
    unique = r"(?:\s+unique_id=\d+)?"
    body = "".join(unique + r"\s+" + re.escape(tok) for tok in _tokens(header))
    return re.compile(r"\[node" + body + unique + r"\]")


def has_node_header(scene_text: str, header: str) -> bool:
    return node_header_pattern(header).search(scene_text) is not None
