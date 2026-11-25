# Handoff: BD Train 3D Live Tracking (Flutter)

Upload this zip to a new session/repo, unzip at the repo root, then ask Claude Code:
"Read HANDOFF.md, README.md and docs/*.md, run `flutter pub get && flutter analyze && flutter test`, then continue."

## State
- Phases 1-5 complete: offline vector rail map, Bangla/English search, route finder, station details,
  overlays, labelled DEMO trains behind `TrainRepository`, partial timetable seed, tests (53), Android release build config.
- Live tracking NOT implemented (no backend supplied) - see docs/MISSING_BACKEND.md.
- Toolchain used: Flutter 3.50.1 (Dart 3.14, uses `package:material_ui`), Android SDK 36, JDK 17, Gradle 9.5 / AGP 9.3.1.
- Build: `flutter build apk --release` (debug-signed unless android/key.properties exists).

## Environment gotchas
- Android SDK downloads need dl.google.com reachable.
- If repo.maven.apache.org returns HTTP 429, point Gradle's Maven Central at https://repo1.maven.org/maven2/ (init script in ~/.gradle/init.d).
- `flutter gen-l10n` regenerates lib/shared/l10n/generated (ARB sources in lib/shared/l10n).

## Next steps (priority)
1. Choose live data source (Firebase/API + schema) -> implement a `TrainRepository` and return it from `trainRepositoryProvider`.
2. Replace app icon (original branding), confirm licences for font/sounds.
3. Set final applicationId (`-PappId=`), create release keystore (android/key.properties), build .aab.
4. Test on real devices (Bangla shaping, permissions, offline).
5. Privacy policy + Play Store listing.

## Original source material
- docs/REBUILD_SPEC.md (original brief), docs/RAILWAY_RESEARCH_DB_README.md (research DB notes),
  assets/rail/* (untouched datasets), assets/timetable/* (partial seed + sources), assets/curated/* (project-made Bangla names).
