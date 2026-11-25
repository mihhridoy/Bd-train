# Phase 0: train master

Goal: a verified list of trains with stop-by-stop times, so crowdsourced locations
can be matched to a train and shown as "between station A and B".

## Status
- `assets/timetable/trains_master.json`: 34 train runs generated from the 32-row seed
  (`tools/build_train_master.py`). Origin/destination and times only; **no stops yet**
  (`stops_status: "missing"`).
- `tools/validate_train_master.py` checks ids, time format and stop-time ordering.

## Blocked on
The official Eastern and Western Timetable No. 54 PDFs (see `assets/timetable/sources.json`).
They could not be downloaded from the build environment. To finish:
1. Provide the two PDFs (or allow `railway.gov.bd`).
2. Extract every run's stops into `stops` as
   `{station_key, name, arrival, departure, day_offset}`; map names to geometry keys
   with the existing station-name resolver; flag unmapped stations.
3. Set `stops_status: "extracted"`, then `"verified"` after a manual spot check.
4. Check whether a timetable newer than No. 54 exists.

## Rules (from the research DB)
Times are local `HH:mm` (Asia/Dhaka); keep one run per direction; train number is a
string; never infer stops from track geometry; keep source and `last_checked_at`.
