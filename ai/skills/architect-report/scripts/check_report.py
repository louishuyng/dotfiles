#!/usr/bin/env python3
"""Check an architect-report HTML file. Standard library only.

    python3 check_report.py my-report.html

Checks the case contract (every data-case names a declared case, every case
is drawn, every data-detail resolves, ids are unique), that the only script is
the runtime shipped in assets/report.html, and then runs Diagram Design's own
self_check.py and verify_geometry.py on the report with that script removed.
"""

from __future__ import annotations

import re
import subprocess
import sys
import tempfile
from collections import Counter
from html.parser import HTMLParser
from pathlib import Path

SKILL_DIR = Path(__file__).resolve().parent.parent
TEMPLATE = SKILL_DIR / "assets" / "report.html"
VENDOR = Path.home() / ".dotfiles/ai/vendor/diagram-design/skills/diagram-design"
SCRIPT_RE = re.compile(r"<script\b([^>]*)>(.*?)</script>", re.DOTALL | re.IGNORECASE)


SVG_RE = re.compile(r"<svg\b.*?</svg>", re.DOTALL | re.IGNORECASE)


def blank(match: re.Match[str]) -> str:
    """Remove a block but keep its line count, so reported line numbers stay true."""
    return "\n" * match.group().count("\n")


def runtime(source: str) -> list[str]:
    """Bodies of every <script>, whitespace-normalised."""
    return [" ".join(body.split()) for _, body in SCRIPT_RE.findall(source)]


class Report(HTMLParser):
    def __init__(self) -> None:
        super().__init__()
        self.declared: list[str] = []
        self.used: list[tuple[str, bool]] = []  # (case id, inside an svg)
        self.details: list[str] = []
        self.ids: list[str] = []
        self.svg_depth = 0

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        values = {name: value or "" for name, value in attrs}
        if tag == "svg":
            self.svg_depth += 1
        if "id" in values:
            self.ids.append(values["id"])
        if values.get("data-case-pick"):
            self.declared.append(values["data-case-pick"])
        if "data-case" in values:
            self.used += [(case, self.svg_depth > 0) for case in values["data-case"].split()]
        if "data-detail" in values:
            self.details.append(values["data-detail"])

    def handle_endtag(self, tag: str) -> None:
        if tag == "svg":
            self.svg_depth -= 1


def check_contract(source: str) -> list[str]:
    errors = []
    report = Report()
    report.feed(source)

    if len(report.declared) < 2:
        errors.append("declare at least two cases with data-case-pick; one case needs no switcher")
    for case, count in Counter(report.declared).items():
        if count > 1:
            errors.append(f'case "{case}" is declared {count} times')
    for case in sorted({case for case, _ in report.used} - set(report.declared)):
        errors.append(f'data-case="{case}" has no data-case-pick button')
    drawn = {case for case, in_svg in report.used if in_svg}
    for case in report.declared:
        if case not in drawn:
            errors.append(f'case "{case}" tags nothing inside a diagram')
    for target in report.details:
        if target not in report.ids:
            errors.append(f'data-detail="{target}" matches no id')
    for name, count in Counter(report.ids).items():
        if count > 1:
            errors.append(f'id "{name}" appears {count} times; prefix ids with the diagram slug')

    scripts = runtime(source)
    canonical = runtime(TEMPLATE.read_text(encoding="utf-8"))
    if scripts != canonical:
        errors.append("the only script must be the runtime copied verbatim from assets/report.html")
    return errors


def check_diagrams(source: str) -> bool:
    """Run the vendored Diagram Design gates, which allow no script of ours."""
    if not VENDOR.is_dir():
        print(f"FAIL Diagram Design is not vendored at {VENDOR}")
        return False
    source = SCRIPT_RE.sub(blank, source)
    diagrams = list(SVG_RE.finditer(source))
    ok = bool(diagrams)
    if not diagrams:
        print("FAIL the report has no diagram")
    with tempfile.TemporaryDirectory() as folder:
        # The gates read a file as one canvas, so each diagram is checked alone.
        for number, diagram in enumerate(diagrams, start=1):
            alone = SVG_RE.sub(lambda other: other.group() if other.start() == diagram.start() else blank(other), source)
            page = Path(folder) / f"diagram-{number}.html"
            page.write_text(alone, encoding="utf-8")
            for gate in ("self_check.py", "verify_geometry.py"):
                result = subprocess.run(
                    [sys.executable, "-I", str(VENDOR / "scripts" / gate), str(page)],
                    capture_output=True, text=True, check=False,
                )
                print(f"--- diagram {number}, {gate}\n{(result.stdout + result.stderr).strip()}")
                ok = ok and result.returncode == 0
    return ok


def main() -> int:
    if len(sys.argv) != 2:
        print(__doc__)
        return 2
    source = Path(sys.argv[1]).read_text(encoding="utf-8")
    errors = check_contract(source)
    for error in errors:
        print(f"FAIL {error}")
    diagrams_ok = check_diagrams(source)
    if errors or not diagrams_ok:
        return 1
    print("OK case contract and diagram gates pass")
    return 0


if __name__ == "__main__":
    sys.exit(main())
