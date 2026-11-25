# BD Train 3D Live Tracking — Flutter Reconstruction Brief

## Goal
Rebuild a maintainable Flutter Android application inspired by the supplied decompiled package `com.musoftbd.bd_train_tracker` (version `1.0.0`, versionCode `4`). Use the supplied bundled rail/geographic datasets and assets. Treat this as a clean-room functional reconstruction, not recovery of the original Dart source. Do not claim pixel-perfect parity unless reference screenshots or a running original APK are provided.

## Evidence and confidence

### Confirmed from the supplied archive
- App label: **BD Train 3D Live Tracking**.
- Android package in the supplied build: `com.musoftbd.bd_train_tracker`.
- Flutter embedding v2; native entry activity is `MainActivity`.
- Minimum Android SDK 29; target SDK 36 in this extracted manifest.
- Bundled assets:
  - `assets/rail/places.json`: 961 place records; OpenStreetMap attribution, ODbL.
  - `assets/rail/roads.json`: 3,721 road records; OpenStreetMap attribution, ODbL.
  - `assets/rail/segments.json`: generated `2026-11-10`; 386 station coordinate entries, 638 rail segment geometries, 96 bridge records; OpenStreetMap attribution, ODbL.
  - `assets/fonts/Kalpurush.ttf` (Bangla font).
  - `assets/sounds/horn.wav`, `assets/sounds/rail_loop.wav`.
  - `assets/icon/app_icon.png`.
- Manifest permissions/features indicate internet, fine/coarse location, foreground location service, notifications, vibration, wake lock, microphone/audio-related permission, boot receiver, and app widget support.
- Native `MainActivity` registers a Google Mobile Ads native-ad factory named `largeNative` and exposes a MethodChannel named `bd_train_tracker/settings` with method `openInternet` to open Android internet settings.
- Firebase Auth and Firebase Realtime Database plugin registrars are present in the Android package. This proves SDK integration, not the exact database schema or live tracking protocol.
- Google Mobile Ads application ID is present in the manifest. Do not reuse it in a new release unless the app owner confirms ownership and intends to use that AdMob account.
- A native Android train widget receiver is declared (`TrainWidgetProvider`). Its actual UI/data behavior is not fully recoverable from the current extracted files.

### Not confirmed / do not invent
- Exact original screen layouts, navigation, colors, animations, train cards, search flow, route selection flow, or settings UI.
- Exact Firebase project/database paths, authentication flow, train data schema, train identifiers, update cadence, or whether data is live, simulated, or manually maintained.
- Exact map provider, map style, tile source, API keys, or routing logic.
- Whether microphone permission is used for voice search or another feature.
- The app's original Dart source. The archive contains compiled Flutter native/AOT artifacts, not recoverable original Dart project files.

## Required implementation approach
1. First inspect every supplied asset and data structure before coding. Keep the three JSON files intact in `assets/rail/` and write typed parsers with validation and tests.
2. Build a new Flutter project using current stable Flutter/Dart and null safety. Keep Android package/application ID configurable; do not silently publish under the original package ID.
3. Use a clean architecture with `data`, `domain`, `services`, `features`, and `shared` folders. Separate static map geometry from live train state.
4. Use Bangla-first localization with English support. Load `Kalpurush.ttf` for Bangla rendering and test shaping/line height on real Android devices.
5. Build the map/rail visualization from supplied coordinates. Preserve OSM attribution and comply with ODbL attribution/share-alike requirements for derived database data. Do not bundle or scrape third-party map tiles without permission; select a documented map/tile provider and configure its required attribution/API key.
6. Treat live train tracking as a separate integration. Implement a repository interface and a clearly labeled demo/mock provider until the owner supplies a valid API/Firebase project and schema. Never label simulated positions as live.
7. Add location permission handling only when the user invokes a location-dependent feature. Explain why permission is needed, support denial, and avoid continuous background tracking unless essential and explicitly disclosed.
8. Implement notifications, audio, widget, ads, Firebase, and sharing as optional modules. Do not add unnecessary permissions. Use test AdMob IDs during development and the owner's own IDs only after confirmation.
9. Add offline handling: static rail/place/road data must remain usable without network; live status must show last-updated time and stale/offline state.
10. Add unit tests for JSON parsing, station lookup, segment geometry, nearest-station calculations, and repository states. Add widget tests for core screens and Android integration tests for permissions.

## Data structures discovered
- `places.json`: object with `attribution` string and `places` array. Each observed record is `[latitude, longitude, categoryCode, banglaName, englishName]`.
- `roads.json`: object with `attribution` string and `roads` array. Each observed record is `[banglaName, englishName, [[latitude, longitude], ...]]`.
- `segments.json`: object with `attribution`, `generated`, `stations`, `segments`, `bridges`.
  - `stations`: map from station key to `[latitude, longitude]`.
  - `segments`: map from `stationA|stationB` key to a polyline array of `[latitude, longitude]` points.
  - `bridges`: array of objects; observed keys include `a`, `b`, `l`, `n`, `e`, `v`. Validate all fields before relying on them.
- Coordinate order in these data files is latitude then longitude. Convert carefully if a map SDK expects longitude then latitude.

## Suggested product scope for the first working version
These are reconstruction recommendations, not verified original screens:
- Home/map screen with Bangladesh rail geometry and station markers.
- Station search in Bangla and English.
- Station detail sheet with coordinates and connected segment information.
- Route/rail-line visualization using `segments.json`.
- Nearby places/roads overlay using `places.json` and `roads.json`, toggleable to avoid clutter.
- Train status/tracking screen backed by an injectable `TrainRepository`; demo mode must be visibly marked until a real data source is configured.
- Settings: language, map overlays, notification preference, audio preference, and network troubleshooting.
- Optional widget and notifications only after core functionality is stable.

## Suggested Flutter packages (verify current compatibility before adding)
Choose packages deliberately and pin compatible versions in `pubspec.yaml`:
- State management: Riverpod or Bloc (choose one).
- Maps: evaluate `flutter_map` with a permitted tile source, or an approved native map SDK. Do not assume the original app used either.
- Location: `geolocator` only for user-initiated location features.
- Firebase: `firebase_core`, `firebase_auth`, `firebase_database` only after real project configuration is supplied.
- Notifications: `flutter_local_notifications` only if required.
- Audio: `audioplayers` or `just_audio` only if sound behavior is included.
- Local persistence: `shared_preferences` for simple settings; a local database only if needed.

## Build order
### Phase 1 — audit and foundation
- Print a tree of the supplied asset folder.
- Inspect JSON schemas, malformed records, coordinate bounds, duplicate station names, and graph connectivity.
- Create project structure, theme, localization, asset loading, typed models, and parser tests.

### Phase 2 — map and rail network
- Render station markers and segment polylines.
- Add station search and station detail.
- Add roads/places as optional overlays with attribution.
- Ensure map remains usable offline to the extent supported by the chosen map provider; static vector geometry itself must load offline.

### Phase 3 — train data integration
- Define `TrainRepository` with `watchTrainPositions`, `getTrainDetails`, and `getServiceStatus` abstractions (adjust once actual API is known).
- Implement `MockTrainRepository` with obvious demo labels.
- Add Firebase/API adapter only after credentials, database rules, and schema are supplied.
- Include timestamps, stale-data detection, loading/error/empty states.

### Phase 4 — optional Android features
- Notifications, audio, widget, share actions, and ads individually behind feature flags.
- Implement native method channel for opening network settings only if the UX needs it.
- Request only permissions required by enabled features.

### Phase 5 — quality and release
- Run `flutter analyze`, all tests, and Android release build.
- Test Android 10+ and current Android versions, different densities, Bangla text, denied permissions, airplane mode, and slow network.
- Verify 16 KB page-size compatibility for native dependencies before Play upload.
- Provide a README documenting setup, environment variables, API/Firebase configuration, attribution, build commands, and known limitations.

## Deliverables expected from Claude Code
1. A compiling Flutter project with the supplied assets integrated.
2. Typed models and robust parsers for all three JSON datasets.
3. Working map/rail network and station search using static data.
4. Demo tracking mode clearly distinguished from real tracking.
5. Automated tests and a setup README.
6. A list of missing external inputs needed for true live tracking (API/Firebase config/schema, map provider/key, original-app screenshots or screen recording).

## Important instruction to Claude Code
Do not start by guessing the original UI or fabricating train locations. First inspect the extracted files and produce an evidence-based inventory. Then implement Phase 1 and Phase 2. Ask for missing backend credentials/schema before claiming live tracking works. Keep the code modular so a real data provider can be plugged in later.
