# BD Train 3D Live Tracking — Flutter reconstruction

A clean-room Flutter rebuild of an app of the same kind as the Play Store
"BD Train 3D Live Tracking", written from the supplied datasets and a functional
brief (`docs/REBUILD_SPEC.md`). It is **not** the original source and makes no claim
of pixel-for-pixel parity.

> **Live tracking is not implemented.** No live-train backend was supplied. The app
> ships a clearly labelled **demo mode** with simulated trains. See
> [`docs/MISSING_BACKEND.md`](docs/MISSING_BACKEND.md) for exactly what is needed.

## What works

| Area | Status |
| --- | --- |
| Offline vector rail map (386 stations, 638 segments, 96 bridges) | ✅ `flutter_map`, no tiles required |
| Station search (Bangla + English, nukta-insensitive) incl. 961 places | ✅ |
| Station details (coordinates, connected stations, nearby bridges, share) | ✅ |
| Route finder (shortest track path, distance, stations along the track, bridges) | ✅ geometry only, **not** a timetable |
| Overlays: roads (3,721), places, bridges, labels | ✅ toggleable |
| Bangla-first UI with Kalpurush font, English option, light/dark | ✅ |
| Nearest station from user location | ✅ one-shot, after in-app rationale; no background tracking |
| Demo trains + stale/offline/empty/error handling | ✅ labelled `DEMO` everywhere |
| Partial timetable (32 rows from research archive) | ✅ labelled unverified |
| Sound (horn, loop), network-settings channel, share | ✅ feature-flagged |
| Live trains, push notifications, home widget, ads, Firebase | ❌ not implemented (need owner inputs) |
| "3D" perspective/tilt map | ❌ not implemented |
| Online base-map tiles | ⚙️ optional, off unless you configure a provider |

## Architecture

```
lib/
  domain/      pure Dart: entities (Station, RailNetwork, RailRoute, Train…),
               repository interfaces, use cases (RouteFinder, SearchIndex, name resolver)
  data/        JSON parsers with validation, asset source, repositories
               (AssetRail, MockTrain = DEMO, UnconfiguredTrain)
  services/    location, audio, share, platform channel, settings store
  features/    map, search, routes, tracking, station, settings, home
  shared/      providers (Riverpod), theme, l10n (ARB), formatters, config
assets/rail/   the three supplied JSON files, untouched
assets/curated/ small curated Bangla station-name supplement
assets/timetable/ partial timetable seed + sources
```

Static geometry (`RailNetwork`) is fully separate from train state (`TrainRepository`).

## Data audit (Phase 1 findings)

* `places.json` 961 places; `roads.json` 3,721 roads (14,511 points); `segments.json`
  386 stations / 638 segments / 96 bridges. **No malformed records**, all coordinates
  inside Bangladesh, all segment endpoints equal their station coordinates, the graph is
  a **single connected component**, no duplicate/self segments.
* Station keys are ASCII slugs only. Bangla names are recovered from `places.json`
  (exact: 140, one-edit spelling variant: 33) plus 17 curated entries; the rest fall back
  to English and say so. Station "category/importance" is not in the data, so
  junctions are derived from graph degree.
* Bridge field `v` is undocumented: preserved in the model, never displayed.
* Place category `r` is undocumented: kept and treated as a generic place.
* Some OSM segments are sparse (up to ~26 km between vertices) and some are long "chords" that skip stations
  (e.g. one 304 km segment from Airport to Chattogram). Routes therefore also list the stations lying within
  250 m of the track, derived from geometry (not from a timetable).
* `timetable_seed.json` only has terminal stations; 3 endpoints (Goalondho, Vatiapara Ghat,
  Kolkata) have no geometry key and are shown without a map route.

## Build & run

Requires Flutter 3.50+ (Dart 3.14), JDK 17+, Android SDK 36.

```bash
flutter pub get
flutter gen-l10n            # also runs automatically on build
flutter analyze
flutter test
flutter run
flutter build apk --release # build/app/outputs/flutter-apk/app-release.apk
```

### Configuration (all optional)

| Define | Purpose |
| --- | --- |
| `--dart-define=TILE_URL_TEMPLATE=https://…/{z}/{x}/{y}.png` | enable online base map (use a provider whose terms allow it) |
| `--dart-define=TILE_ATTRIBUTION="© …"` | attribution required by that provider |
| `--dart-define=FF_AUDIO=false` / `FF_SHARE=false` / `FF_LOCATION=false` | disable optional modules |
| `-PappId=com.yourco.app` (Gradle) | Android application ID (default `dev.bdrail.bd_train_tracker`; the original ID is **not** used) |

Release signing: create `android/key.properties` (git-ignored) with `storeFile`,
`storePassword`, `keyAlias`, `keyPassword`. Without it the release APK is signed with
the **debug key** and Gradle prints a warning — do not upload that to Play.

## Permissions

`INTERNET` (optional tiles / future feed), `ACCESS_COARSE/FINE_LOCATION` (requested only
after tapping *My location*, one-shot, foreground). Nothing else.

## Attribution & licences

Rail/place/road data © OpenStreetMap contributors, **ODbL**. The app shows attribution on
the map and in Settings. Derived databases must be shared under ODbL. The Kalpurush font
and the supplied icon/sounds come from the supplied package — **confirm their licences**
and replace the icon (it carries the original app's branding) before publishing.
This project is independent and not affiliated with Bangladesh Railway. The supplied
AdMob application ID is intentionally not used.

## Tests

`flutter test` (53 tests) — parser validation (real + malformed data), geometry, station lookup,
nearest station, routing, search, name resolution, demo/unconfigured repositories,
staleness, timetable parsing, and widget tests for boot/language/search/station sheet/
routes/trains/timetable/location-permission/settings.
Android integration tests for runtime permissions were **not** run (no device/emulator
available in the build environment); see "Known limitations".

## Known limitations

* No live data; demo only.
* Bangla station names for 213 of 386 stations are unavailable in the data.
* Not tested on a physical device or emulator here: Bangla shaping/line height on real
  hardware, runtime permission dialogs, airplane mode, slow network. Do this before release.
* Routing is shortest track distance; real trains may take other paths.
* Without a tile provider the map is vector-only (no coastline/borders).
