#!/usr/bin/env python3
"""Build assets/timetable/trains_master.json from timetable_seed.json.

Each row is one train *run* (direction-specific). Stops are empty until the
official Timetable No. 54 PDFs are extracted; never infer stops from geometry.
Usage: python3 -I tools/build_train_master.py
"""
import json, pathlib, re

root = pathlib.Path(__file__).resolve().parent.parent
seed = json.loads((root / "assets/timetable/timetable_seed.json").read_text())

def parse_numbers(n):
    # "3107/3110" -> two runs share a service; keep as separate ids.
    return [p.strip() for p in str(n).split("/") if p.strip()]

runs = []
for r in seed:
    ids = parse_numbers(r["train_number"])
    for tid in ids:
        runs.append({
            "train_id": tid,
            "train_number": tid,
            "name_en": r["train_name_en"],
            "name_bn": r.get("train_name_bn"),
            "service_type": r["service_type"],
            "weekly_off_day": r.get("weekly_off_day"),
            "origin": {"name": r["origin_station"], "departure": r["departure_time"]},
            "destination": {"name": r["destination_station"], "arrival": r["arrival_time"]},
            "stops": [],  # [{station_key, name, arrival, departure, day_offset}]
            "stops_status": "missing",
            "verification_status": r["verification_status"],
            "source_url": r["source_url"],
            "last_checked_at": None,
        })

out = {"schema_version": 1, "timezone": "Asia/Dhaka", "runs": runs}
(root / "assets/timetable/trains_master.json").write_text(
    json.dumps(out, ensure_ascii=False, indent=2) + "\n")
print(f"wrote {len(runs)} runs")
