import 'dart:io';

import 'package:bd_train_tracker/app.dart';
import 'package:bd_train_tracker/data/datasources/rail_asset_source.dart';
import 'package:bd_train_tracker/data/repositories/asset_rail_repository.dart';
import 'package:bd_train_tracker/domain/entities/geo.dart';
import 'package:bd_train_tracker/services/audio_service.dart';
import 'package:bd_train_tracker/services/location_service.dart';
import 'package:bd_train_tracker/services/platform_settings_service.dart';
import 'package:bd_train_tracker/services/share_service.dart';
import 'package:bd_train_tracker/shared/providers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reads assets from the project folder synchronously (no isolate, no bundle).
class FileAssetSource implements RailAssetSource {
  @override
  Future<String> read(String assetPath) =>
      Future.value(File(assetPath).readAsStringSync());
}

class FakeLocation implements LocationService {
  FakeLocation(this.outcome);
  LocationOutcome outcome;
  int calls = 0;
  @override
  Future<LocationOutcome> getCurrentLocation() async {
    calls++;
    return outcome;
  }

  @override
  Future<void> openAppSettings() async {}
}

class FakePlatformSettings implements PlatformSettingsService {
  int opened = 0;
  bool result = true;
  @override
  Future<bool> openInternetSettings() async {
    opened++;
    return result;
  }
}

class FakeShare implements ShareService {
  final List<String> shared = [];
  @override
  Future<void> shareText(String text) async => shared.add(text);
}

class TestHarness {
  TestHarness({LocationOutcome? location})
      : location = FakeLocation(location ?? const LocationGranted(GeoPoint(23.73, 90.42)));
  final FakeLocation location;
  final platform = FakePlatformSettings();
  final share = FakeShare();
}

Future<TestHarness> pumpApp(
  WidgetTester tester, {
  Map<String, Object> prefs = const {},
  LocationOutcome? location,
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(() async {
    // Unmount so timers/streams owned by providers are disposed.
    await tester.pumpWidget(const SizedBox());
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  SharedPreferences.setMockInitialValues(prefs);
  final sp = await SharedPreferences.getInstance();
  final h = TestHarness(location: location);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sp),
      railAssetSourceProvider.overrideWithValue(FileAssetSource()),
      railRepositoryProvider.overrideWithValue(
          AssetRailRepository(FileAssetSource(), useIsolate: false)),
      audioServiceProvider.overrideWithValue(const SilentAudioService()),
      locationServiceProvider.overrideWithValue(h.location),
      platformSettingsProvider.overrideWithValue(h.platform),
      shareServiceProvider.overrideWithValue(h.share),
    ],
    child: const BdTrainApp(),
  ));
  // Let the dataset future resolve and the first frames render.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 100));
  return h;
}
