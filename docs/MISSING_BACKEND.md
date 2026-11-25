# Missing inputs for true live train tracking

The supplied archives contain **static** data only. Nothing in them proves how the
original app obtained live positions, so this project does **not** fake it:

* With no backend configured, the Trains tab says *"Live tracking is not connected"*
  and shows no trains.
* **Demo mode** (opt-in) animates placeholder trains (`DEMO-1…`) along real track
  geometry. Every demo surface carries a purple `DEMO` badge / banner. They are not
  real trains, positions or schedules.

## What the original package proves (and does not)

| Evidence | Meaning |
| --- | --- |
| Firebase Auth + Realtime Database plugin registrars | An SDK was linked. **Not** the project, paths, rules or schema. |
| Google Mobile Ads native factory `largeNative` | Ads existed. The ad-unit/app IDs belong to the original owner. |
| `TrainWidgetProvider` receiver | A home-screen widget existed; its data source is unknown. |
| Microphone-related permission | Purpose unknown (voice search? audio?). |

## Inputs the owner must supply

1. **Live data source** – one of: Firebase project config (`google-services.json`,
   database URL) *or* a REST/WebSocket endpoint, plus **read credentials/rules**.
2. **Schema** – example JSON of a train node: id/number, name, lat/lng,
   speed, heading, timestamp (and timezone/epoch unit), status, current/next
   station, delay. Whether coordinates are WGS84 (`lat,lng` order).
3. **Cadence & semantics** – update interval, what "stale" means, how finished/not-
   yet-started trains are represented, behaviour at midnight.
4. **Train identity master** – train numbers/names and their stop lists (see below),
   so live ids can be joined to station keys in `segments.json`.
5. **Authorisation to use it** – the data publisher's terms for an app that is
   not theirs. (Bangladesh Railway has no public live-position API known to this
   project; do not scrape the official e-ticket site.)
6. **Map provider** (optional but recommended) – a tile provider whose terms allow
   a mobile app, plus its key/attribution, passed with
   `--dart-define=TILE_URL_TEMPLATE=… --dart-define=TILE_ATTRIBUTION=…`.
   The public `tile.openstreetmap.org` servers are not appropriate for an app.
7. **Original screenshots / screen recording** – needed for any claim of UI parity.
8. **Own AdMob IDs / FCM project** if ads or push notifications are wanted.
   Never reuse the original app's IDs.

## How a real source plugs in

`lib/domain/repositories/train_repository.dart` defines:

```dart
Stream<TrainSnapshot> watchTrainPositions();
Future<TrainDetails?> getTrainDetails(String trainId);
Future<ServiceStatus> getServiceStatus();
```

1. Add `FirebaseTrainRepository` (or `HttpTrainRepository`) in `lib/data/repositories/`
   implementing `TrainRepository` with `sourceKind == TrainDataSourceKind.live`.
2. Return it from `trainRepositoryProvider` in `lib/shared/providers.dart`
   when configured (keep `UnconfiguredTrainRepository` as the fallback).
3. Map transport errors to stream errors; the UI already handles loading, empty,
   error and **stale** states using `TrainSnapshot.fetchedAt` + `StalenessPolicy`.
4. Add Firebase packages only then (`firebase_core`, `firebase_database`), with
   security rules that allow read-only access.

## Timetable data (second archive)

`assets/timetable/timetable_seed.json` (32 rows) is a **partial seed** from the
research archive: only origin/destination, their times, service type and weekly
off-day. It is shown in the *Timetable* tab with a "not verified" label. Still missing
for a real timetable feature:

* station-by-station stops and times for every train (full Eastern/Western Timetable
  No. 54 PDFs, extracted and audited; check for a newer timetable),
* fares (scanned/OCR-noisy sources; intentionally not imported),
* seat classes, and live seat availability (must come from an authorised
  e-ticket integration, never static data),
* a verified station master (names + IDs). `segments.json` keys are geometry keys,
  not a verified list of passenger stations.
* Bangla station names: only 173 of 386 stations could be resolved from the data (plus
  17 curated); the rest display in English.
