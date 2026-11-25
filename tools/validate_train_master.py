#!/usr/bin/env python3
"""Validate assets/timetable/trains_master.json. Exit 1 on errors."""
import json, pathlib, re, sys

root = pathlib.Path(__file__).resolve().parent.parent
d = json.loads((root / "assets/timetable/trains_master.json").read_text())
hhmm = re.compile(r"^([01]\d|2[0-3]):[0-5]\d$")
errs, seen = [], set()
for r in d["runs"]:
    i = r["train_id"]
    if i in seen: errs.append(f"{i}: duplicate train_id")
    seen.add(i)
    for k in ("name_en", "service_type"):
        if not r.get(k): errs.append(f"{i}: missing {k}")
    for t in (r["origin"]["departure"], r["destination"]["arrival"]):
        if not hhmm.match(t): errs.append(f"{i}: bad time {t!r}")
    last = None
    for s in r["stops"]:
        for k in ("arrival", "departure"):
            if s.get(k) and not hhmm.match(s[k]): errs.append(f"{i}: bad stop time {s[k]!r}")
        key = (s.get("day_offset", 0), s.get("departure") or s.get("arrival") or "")
        if last and key < last: errs.append(f"{i}: stop times not increasing at {s.get('name')}")
        last = key
missing = sum(1 for r in d["runs"] if r["stops_status"] == "missing")
print(f"{len(d['runs'])} runs, {missing} without stops, {len(errs)} errors")
for e in errs: print(" -", e)
sys.exit(1 if errs else 0)
