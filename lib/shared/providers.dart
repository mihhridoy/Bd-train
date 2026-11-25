import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/datasources/rail_asset_source.dart';
import '../data/parsers/timetable_parser.dart';
import '../data/repositories/asset_rail_repository.dart';
import '../data/repositories/mock_train_repository.dart';
import '../data/repositories/unconfigured_train_repository.dart';
import '../domain/entities/geo.dart';
import '../domain/entities/rail_network.dart';
import '../domain/entities/rail_route.dart';
import '../domain/entities/timetable.dart';
import '../domain/entities/train.dart';
import '../domain/repositories/rail_repository.dart';
import '../domain/repositories/train_repository.dart';
import '../domain/usecases/route_finder.dart';
import '../domain/usecases/search_index.dart';
import '../services/audio_service.dart';
import '../services/location_service.dart';
import '../services/platform_settings_service.dart';
import '../services/settings_store.dart';
import '../services/share_service.dart';
import 'config.dart';

// ---------------------------------------------------------------- services

final sharedPreferencesProvider = Provider<SharedPreferences>(
    (ref) => throw UnimplementedError('Override in main()'));

final railAssetSourceProvider =
    Provider<RailAssetSource>((ref) => BundleRailAssetSource());

final locationServiceProvider =
    Provider<LocationService>((ref) => const GeolocatorLocationService());

final audioServiceProvider = Provider<AudioService>((ref) {
  final AudioService s =
      FeatureFlags.audio ? AudioplayersAudioService() : const SilentAudioService();
  ref.onDispose(s.dispose);
  return s;
});

final platformSettingsProvider = Provider<PlatformSettingsService>(
    (ref) => const ChannelPlatformSettingsService());

final shareServiceProvider =
    Provider<ShareService>((ref) => const SharePlusShareService());

// ---------------------------------------------------------------- settings

class SettingsNotifier extends Notifier<AppSettings> {
  late SettingsStore _store;

  @override
  AppSettings build() {
    _store = SettingsStore(ref.watch(sharedPreferencesProvider));
    return _store.load();
  }

  void update(AppSettings Function(AppSettings) change) {
    state = change(state);
    unawaited(_store.save(state));
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

final languageProvider =
    Provider<String>((ref) => ref.watch(settingsProvider.select((s) => s.language)));

// -------------------------------------------------------------- static data

final railRepositoryProvider = Provider<RailRepository>(
    (ref) => AssetRailRepository(ref.watch(railAssetSourceProvider)));

final railDataProvider = FutureProvider<RailDataBundle>(
    (ref) => ref.watch(railRepositoryProvider).load());

/// Synchronous access for widgets that only exist after data has loaded.
final railBundleProvider = Provider<RailDataBundle>((ref) {
  final v = ref.watch(railDataProvider).value;
  if (v == null) throw StateError('Rail data accessed before it was loaded');
  return v;
});

final networkProvider =
    Provider<RailNetwork>((ref) => ref.watch(railBundleProvider).network);

final searchIndexProvider = Provider<SearchIndex>((ref) {
  final b = ref.watch(railBundleProvider);
  return SearchIndex(network: b.network, places: b.places);
});

final routeFinderProvider =
    Provider<RouteFinder>((ref) => RouteFinder(ref.watch(networkProvider)));

final timetableProvider = FutureProvider<List<TimetableEntry>>((ref) async {
  final network = ref.watch(networkProvider);
  final raw = await ref.watch(railAssetSourceProvider).read('assets/timetable/timetable_seed.json');
  return parseTimetable(jsonDecode(raw), network).entries;
});

/// Precomputed `LatLng` geometry so the map never re-converts on each frame.
class MapGeometry {
  MapGeometry(RailDataBundle b)
      : rail = [
          for (final s in b.network.segments)
            [for (final p in s.points) LatLng(p.lat, p.lng)]
        ],
        roads = [
          for (final r in b.roads) [for (final p in r.points) LatLng(p.lat, p.lng)]
        ];
  final List<List<LatLng>> rail;
  final List<List<LatLng>> roads;
}

final mapGeometryProvider =
    Provider<MapGeometry>((ref) => MapGeometry(ref.watch(railBundleProvider)));

// ------------------------------------------------------------- UI coordination

enum HomeTab { map, routes, trains, settings }

class HomeTabNotifier extends Notifier<HomeTab> {
  @override
  HomeTab build() => HomeTab.map;
  void go(HomeTab tab) => state = tab;
}

final homeTabProvider =
    NotifierProvider<HomeTabNotifier, HomeTab>(HomeTabNotifier.new);

/// A one-shot instruction for the map to move its camera.
class MapCommand {
  const MapCommand.focus(this.point, {this.zoom = 12}) : route = null;
  const MapCommand.fitRoute(this.route)
      : point = null,
        zoom = 0;
  final GeoPoint? point;
  final double zoom;
  final RailRoute? route;
}

class MapCommandNotifier extends Notifier<MapCommand?> {
  @override
  MapCommand? build() => null;
  void send(MapCommand c) => state = c;
  void consume() => state = null;
}

final mapCommandProvider =
    NotifierProvider<MapCommandNotifier, MapCommand?>(MapCommandNotifier.new);

class ActiveRouteNotifier extends Notifier<RailRoute?> {
  @override
  RailRoute? build() => null;
  void set(RailRoute? r) => state = r;
}

final activeRouteProvider =
    NotifierProvider<ActiveRouteNotifier, RailRoute?>(ActiveRouteNotifier.new);

class StationSelectionNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? key) => state = key;
}

/// Key of the station currently highlighted on the map.
final selectedStationProvider =
    NotifierProvider<StationSelectionNotifier, String?>(StationSelectionNotifier.new);

final routeOriginProvider =
    NotifierProvider<StationSelectionNotifier, String?>(StationSelectionNotifier.new);
final routeDestinationProvider =
    NotifierProvider<StationSelectionNotifier, String?>(StationSelectionNotifier.new);

class UserLocationNotifier extends Notifier<GeoPoint?> {
  @override
  GeoPoint? build() => null;
  void set(GeoPoint? p) => state = p;
}

/// Last location the user explicitly asked for (kept in memory only).
final userLocationProvider =
    NotifierProvider<UserLocationNotifier, GeoPoint?>(UserLocationNotifier.new);

// ------------------------------------------------------------------ trains

final demoEnabledProvider =
    Provider<bool>((ref) => ref.watch(settingsProvider.select((s) => s.demoEnabled)));

/// Chooses the repository. Real live data would be wired here once supplied.
final trainRepositoryProvider = Provider<TrainRepository>((ref) {
  final demo = ref.watch(demoEnabledProvider);
  final TrainRepository repo = demo
      ? MockTrainRepository(ref.watch(networkProvider))
      : const UnconfiguredTrainRepository();
  ref.onDispose(repo.dispose);
  return repo;
});

final trainSnapshotProvider = StreamProvider<TrainSnapshot>(
    (ref) => ref.watch(trainRepositoryProvider).watchTrainPositions());

final serviceStatusProvider = FutureProvider<ServiceStatus>(
    (ref) => ref.watch(trainRepositoryProvider).getServiceStatus());

final stalenessPolicyProvider =
    Provider<StalenessPolicy>((ref) => const StalenessPolicy());

/// Ticks every second so staleness is re-evaluated even without new data.
final clockProvider = StreamProvider<DateTime>(
    (ref) => Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()));
