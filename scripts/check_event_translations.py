#!/usr/bin/env python3
"""Report translation coverage for the source event catalogs.

Draft catalogs are keyed by the complete source text. This checks content
coverage, not translation quality or the separately generated UI text.
"""

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "Sources/RegiereDeutschlandCore/Data"
GERMAN_FIELDS = {
    "title", "headline", "description", "advisoryNote", "summary",
    "historicalReality", "sourceNote", "note",
}
US_FIELDS = {"title", "context", "reality", "choices", "source"}


def strings(value, fields, key=None):
    if isinstance(value, dict):
        for child_key, child in value.items():
            yield from strings(child, fields, child_key)
    elif isinstance(value, list):
        for child in value:
            yield from strings(child, fields, key)
    elif isinstance(value, str) and key in fields and value.strip():
        yield value


def report(label, pattern, fields, catalog_path):
    catalog = json.loads(catalog_path.read_text(encoding="utf-8"))
    if not isinstance(catalog, dict) or any(
        not isinstance(k, str) or not k.strip() or not isinstance(v, str) or not v.strip()
        for k, v in catalog.items()
    ):
        raise ValueError(f"Invalid or empty entry in {catalog_path}")

    all_strings = set()
    complete_events = total_events = 0
    for path in sorted(DATA.glob(pattern)):
        events = json.loads(path.read_text(encoding="utf-8"))
        for event in events:
            required = set(strings(event, fields))
            all_strings.update(required)
            total_events += 1
            complete_events += required.issubset(catalog)

    missing = all_strings - catalog.keys()
    unused = catalog.keys() - all_strings
    print(f"{label}: {total_events - complete_events}/{total_events} events have missing fields; "
          f"{len(all_strings) - len(missing)}/{len(all_strings)} distinct source texts translated; "
          f"{len(unused)} catalog entries do not match an event source")
    return bool(missing or unused)


if __name__ == "__main__":
    missing_german = report(
        "Germany → English", "Events/*.json", GERMAN_FIELDS,
        DATA / "Localization/GermanyEventsEnglish.draft.json",
    )
    missing_us = report(
        "United States → German", "UnitedStates/*.json", US_FIELDS,
        DATA / "Localization/USEventsGerman.draft.json",
    )
    raise SystemExit(1 if missing_german or missing_us else 0)
