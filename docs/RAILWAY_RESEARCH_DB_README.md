# Bangladesh Railway Database — Research Build (2026-11-25)

## Important completeness warning
This is a **starter research database, not a complete operational database**. It contains:
- APK-derived map geometry assets (386 station coordinate keys, 638 rail segments, 96 bridges, 3,721 roads, 961 places).
- A small timetable seed (23 intercity/international rows + 9 mail/express rows) transcribed from text indexed for official Bangladesh Railway timetable PDFs.
- Source register and schema-ready empty files for trains, fares, seat classes and station stops.

It does **not** claim all Bangladesh trains or every station-by-station stop are present. The official site exposes Eastern and Western timetable pages (Timetable No. 54, effective 2025-03-10) and a 2026 updated all-schedules landing page. Full PDF binaries could not be fetched here for complete extraction. Some fare PDFs are scanned or OCR/table-layout ambiguous; fares were intentionally not guessed.

## Verification levels
- `official_source_partial_transcription`: data visible in indexed official PDF text, but not independently checked against the complete PDF pages.
- `unverified_name_mapping`: APK coordinate key has no verified station name mapping.
- `not_available`: do not treat as zero or false; data not obtained.
- Secondary websites are recorded only as cross-check sources, not authority.

## Files
- `timetable_seed.json`: seed departure/arrival endpoints and weekly off-days.
- `stations_seed.json`: station-key coordinate candidates from APK; names blank intentionally.
- `apk_rail_assets/rail_network.json`: original rail geometry data (stations/segments/bridges).
- `apk_rail_assets/roads.json`, `places.json`: original road/place geometry.
- `trains_seed.json`, `train_stops_seed.json`, `fares_seed.json`, `seat_classes_seed.json`: empty schema-ready arrays.
- `sources.json`: provenance, dates, limitations.
- `bangladesh_railway_database.xlsx`: workbook version.

## Production integration rules
1. Keep train service direction as separate train runs (e.g. up/down services).
2. Store times as local Bangladesh time `HH:mm`; store arrival day offset where midnight crossing occurs.
3. Never infer intermediate station times from route geometry.
4. Keep train number as string (some services use combined or non-numeric identifiers).
5. Keep `weekly_off_day` nullable; `No` means no weekly off-day only when explicitly sourced.
6. Seat availability is live inventory and must not be stored as static timetable data. Query official e-ticket source through an authorized integration or link users to the official booking flow.
7. Fares must include source date, zone, class, VAT/charges policy and validity date.
8. Each row must retain `source_id`, `source_url`, `verification_status`, `last_checked_at`.
9. Do not publish this seed as "all trains" until official PDFs have been fully extracted and audited.

## Official sources
See `sources.json`. Primary starting point: https://railway.gov.bd/pages/static-pages/691997d5933eb65569ddf8e2
