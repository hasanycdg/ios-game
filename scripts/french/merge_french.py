"""Merge translator outputs (English → French) into Localization/French.json.

Usage: python3 scripts/french/merge_french.py <dir with in_*.json/out_*.json>
Validates that every input string is translated and that placeholders match.
"""
import glob
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
TARGET = ROOT / "Sources/RegiereDeutschlandCore/Data/Localization/French.json"
TOKENS = re.compile(r"\{\d+\}|%[.0-9]*[a-z@%]")

work = Path(sys.argv[1])
catalog = json.loads(TARGET.read_text(encoding="utf-8")) if TARGET.exists() else {}
problems = []
for source in sorted(glob.glob(str(work / "in_*.json"))):
    name = Path(source).stem[3:]
    out = work / f"out_{name}.json"
    wanted = json.load(open(source, encoding="utf-8"))
    if not out.exists():
        problems.append(f"{name}: output missing")
        continue
    got = json.load(open(out, encoding="utf-8"))
    for text in wanted:
        fr = got.get(text)
        if not fr or not fr.strip():
            problems.append(f"{name}: missing {text[:60]!r}")
            continue
        if sorted(TOKENS.findall(text)) != sorted(TOKENS.findall(fr)):
            problems.append(f"{name}: placeholder mismatch {text[:60]!r}")
            continue
        catalog[text] = fr
catalog.update(json.load(open(ROOT / "scripts/french/extra_french.json", encoding="utf-8")))
TARGET.write_text(json.dumps(dict(sorted(catalog.items())), ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
print(f"{len(catalog)} French entries")
for p in problems[:40]:
    print("PROBLEM", p)
print(f"{len(problems)} problems")
