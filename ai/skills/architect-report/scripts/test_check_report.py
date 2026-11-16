"""Run: python3 test_check_report.py"""
from check_report import TEMPLATE, check_contract

good = TEMPLATE.read_text(encoding="utf-8")
assert check_contract(good) == []
assert any("no data-case-pick" in e for e in check_contract(good.replace('data-case="happy"', 'data-case="hapy"', 1)))
assert any("matches no id" in e for e in check_contract(good.replace('id="detail-api"', 'id="detail-x"')))
assert any("appears 2 times" in e for e in check_contract(good.replace('id="st-title"', 'id="ctx-title"')))
assert any("verbatim" in e for e in check_contract(good.replace("read();", "read(); fetch('/x');")))
print("ok")

# components.html must carry the same stylesheet and runtime as report.html.
import re
gallery = (TEMPLATE.parent / "components.html").read_text(encoding="utf-8")
for tag in ("style", "script"):
    block = re.compile(rf"<{tag} data-architect-report>.*?</{tag}>", re.DOTALL)
    assert block.search(good).group() == block.search(gallery).group(), f"{tag} blocks differ"
print("ok gallery")
