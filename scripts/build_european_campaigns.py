"""Build the United Kingdom and France campaign catalogs (2000–2026).

Inputs (bilingual editorial sources, English with German translations):
  scripts/european/uk_events.json, scripts/european/fr_events.json
  scripts/european/terminology.py, scripts/european/parties_german.py
Outputs:
  Sources/RegiereDeutschlandCore/Data/Europe/{UK,FR}History.json
  Sources/RegiereDeutschlandCore/Data/Localization/{UK,FR}German.json,
  {UK,FR}GermanOverrides.json, {UK,FR}English.json,
  EuropeanCommonGerman.json, EuropeanCommonEnglish.json

Event identifiers must stay stable when texts change, so saves remain valid.
"""
import json
import re
import sys
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "scripts/european"
sys.path.insert(0, str(SRC))
import future  # noqa: E402
import parties_german  # noqa: E402
import terminology  # noqa: E402

DATA = ROOT / "Sources/RegiereDeutschlandCore/Data"
CATEGORIES = {"economy", "budget", "society", "security", "energy", "foreignPolicy", "digitalization", "welfare"}
SHOCKS = {None, "financial", "pandemic", "terror", "disaster", "energy"}


def write(path, value):
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def validate(code, events):
    errors = []
    ids = [e["id"] for e in events]
    if len(events) != 108:
        errors.append(f"{code}: {len(events)} events, expected 108")
    years = Counter(e["year"] for e in events)
    if sorted(years) != list(range(2000, 2027)) or set(years.values()) != {4}:
        errors.append(f"{code}: expected four events for each year 2000–2026: {sorted(years.items())}")
    if len(set(ids)) != len(ids):
        errors.append(f"{code}: duplicate ids")
    for e in events:
        tag = e["id"]
        if not re.fullmatch(rf"{code}-{e['year']}-[a-z0-9-]+", tag):
            errors.append(f"{tag}: invalid id")
        if e["category"] not in CATEGORIES:
            errors.append(f"{tag}: invalid category")
        if e.get("shock") not in SHOCKS:
            errors.append(f"{tag}: invalid shock")
        if len(e["choices"]) != 3 or len(e["de"]["choices"]) != 3:
            errors.append(f"{tag}: needs three choices in both languages")
        hc = e.get("historicalChoice")
        if hc is not None and hc not in (0, 1, 2):
            errors.append(f"{tag}: invalid historicalChoice")
        for field in ("title", "context", "reality"):
            if not e.get(field, "").strip() or not e["de"].get(field, "").strip():
                errors.append(f"{tag}: empty {field}")
        texts = [e["title"], e["context"], e["reality"], *e["choices"],
                 e["de"]["title"], e["de"]["context"], e["de"]["reality"], *e["de"]["choices"]]
        if any("{" in t or "}" in t for t in texts):
            errors.append(f"{tag}: braces would break template matching")
    return errors


def build(code, prefix, party_german, german_terms, english_terms):
    events = json.loads((SRC / f"{code}_events.json").read_text(encoding="utf-8"))
    errors = validate(code, events)
    history, german = [], {}

    def add(en, de):
        if en in german and german[en] != de:
            errors.append(f"{code}: conflicting translations for {en!r}")
        german[en] = de

    for e in sorted(events, key=lambda x: x["year"]):
        history.append({
            "id": e["id"], "year": e["year"], "category": e["category"], "shock": e.get("shock"),
            "title": e["title"], "context": e["context"], "reality": e["reality"],
            "source": e.get("source"), "historicalChoice": e.get("historicalChoice"),
            "choices": e["choices"],
        })
        add(e["title"], e["de"]["title"])
        add(e["context"], e["de"]["context"])
        add(e["reality"], e["de"]["reality"])
        for en, de in zip(e["choices"], e["de"]["choices"]):
            add(en, de)
    for en, de in party_german.items():
        add(en, de)
    # Fictional Future 2050 scenarios (templates, titles and choices).
    table, portfolios, extras = {
        "uk": (future.UK_FUTURE, future.UK_PORTFOLIOS, future.UK_EXTRAS),
        "fr": (future.FR_FUTURE, future.FR_PORTFOLIOS, future.FR_EXTRAS),
    }[code]
    future_events = future.build(code, table, portfolios, extras)
    write(DATA / f"Europe/{prefix}Future.json", future_events)
    needed = set(future.translatable(table, portfolios, extras)) | set(FUTURE_ENGINE_TEXTS)
    for en in sorted(needed):
        entry = FUTURE_TRANSLATIONS.get(en)
        if not entry:
            errors.append(f"{code}: no future translation for {en[:60]!r}")
            continue
        add(en, entry["de"])
        FRENCH_FUTURE[en] = entry["fr"]
    write(DATA / f"Europe/{prefix}History.json", history)
    write(DATA / f"Localization/{prefix}German.json", german)
    write(DATA / f"Localization/{prefix}GermanOverrides.json", german_terms)
    write(DATA / f"Localization/{prefix}English.json", english_terms)
    print(f"{prefix}: {len(history)} events, {len(german)} German texts, "
          f"categories {dict(Counter(e['category'] for e in events))}")
    return errors


FUTURE_ENGINE_TEXTS = [
    "Deploy forces to a major NATO combat operation", "Pursue allied deterrence and urgent mediation",
    "Limit France's role to evacuations and humanitarian relief", "Limit Britain's role to evacuations and humanitarian relief",
    "The deployment escalates into a wider fictional European war. Military readiness improves, but international trust and social cohesion suffer. Later reconstruction will cost more.",
    "Allied deterrence and emergency mediation contain the immediate crisis. The avoided escalation leaves more resources for long-term renewal.",
    "The government limits its exposure and supports civilian evacuation. The immediate escalation is avoided, but allies question the limits of French commitments.",
    "The government limits its exposure and supports civilian evacuation. The immediate escalation is avoided, but allies question the limits of British commitments.",
    "Build a lasting democratic alliance system", "Support a plural international order with shared rules",
    "Prioritize national autonomy and domestic renewal",
    "Fictional scenario. These events are invented for the campaign and are not predictions or claims about real events.",
    "The earlier military escalation increases the cost of reconstruction.",
    "Preventing escalation preserved resources and public cohesion for renewal.", "Scenario desk · fiction",
]
FUTURE_TRANSLATIONS = json.loads((SRC / "future_translations.json").read_text(encoding="utf-8"))
FRENCH_FUTURE = {}

if __name__ == "__main__":
    write(DATA / "Localization/EuropeanCommonGerman.json", terminology.COMMON_GERMAN)
    write(DATA / "Localization/EuropeanCommonEnglish.json", terminology.COMMON_ENGLISH)
    problems = []
    targets = [("uk", "UK", parties_german.UK, terminology.UK_GERMAN, terminology.UK_ENGLISH),
               ("fr", "FR", parties_german.FR, terminology.FR_GERMAN, terminology.FR_ENGLISH)]
    for target in targets:
        if (SRC / f"{target[0]}_events.json").exists():
            problems += build(*target)
        else:
            print(f"skipping {target[1]}: source missing")
    write(DATA / "Localization/FrenchFuture.json", dict(sorted(FRENCH_FUTURE.items())))
    for p in problems:
        print("ERROR", p)
    raise SystemExit(1 if problems else 0)
