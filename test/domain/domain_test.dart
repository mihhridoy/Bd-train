import 'package:bd_train_tracker/data/repositories/mock_train_repository.dart';
import 'package:bd_train_tracker/data/repositories/unconfigured_train_repository.dart';
import 'package:bd_train_tracker/domain/entities/geo.dart';
import 'package:bd_train_tracker/domain/entities/rail_entities.dart';
import 'package:bd_train_tracker/domain/entities/train.dart';
import 'package:bd_train_tracker/domain/usecases/route_finder.dart';
import 'package:bd_train_tracker/domain/usecases/search_index.dart';
import 'package:bd_train_tracker/domain/usecases/text_normalizer.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/dataset_loader.dart';

void main() {
  final bundle = realBundle();
  final net = bundle.network;

  group('geometry', () {
    test('haversine Dhaka-Chattogram is about 215 km', () {
      final d = haversineMeters(net.station('dhaka')!.position, net.station('chattogram')!.position);
      expect(d / 1000, inInclusiveRange(200, 230));
    });
    test('pointAlong clamps and interpolates', () {
      const line = [GeoPoint(23, 90), GeoPoint(23, 91)];
      final total = polylineLengthMeters(line);
      expect(pointAlong(line, -5), line.first);
      expect(pointAlong(line, total * 2), line.last);
      expect(pointAlong(line, total / 2).lng, closeTo(90.5, 1e-6));
    });
    test('distanceToSegment is zero on the segment', () {
      expect(distanceToSegmentMeters(const GeoPoint(23, 90.5), const GeoPoint(23, 90), const GeoPoint(23, 91)), lessThan(1));
    });
  });

  group('network', () {
    test('is a single connected component with 386 stations', () {
      final comps = net.connectedComponents();
      expect(comps.length, 1);
      expect(comps.first.length, 386);
    });
    test('station lookup, degree and junctions', () {
      expect(net.station('dhaka'), isNotNull);
      expect(net.station('nope'), isNull);
      expect(net.degree('dhaka'), greaterThan(0));
      expect(net.stations.keys.where(net.isJunction), isNotEmpty);
    });
    test('nearest stations from Dhaka center returns Dhaka first, sorted', () {
      final n = net.nearestStations(const GeoPoint(23.7320, 90.4260), limit: 3);
      expect(n.first.station.key, 'dhaka');
      expect(n.first.distanceMeters, lessThan(100));
      expect(n[0].distanceMeters <= n[1].distanceMeters && n[1].distanceMeters <= n[2].distanceMeters, isTrue);
    });
    test('maxMeters filters', () {
      expect(net.nearestStations(const GeoPoint(21.5, 92.8), maxMeters: 1000), isEmpty);
    });
    test('bridgesNear finds Padma bridge', () {
      final b = net.bridgesNear(const GeoPoint(23.4403, 90.2631), 3000);
      expect(b.any((x) => x.nameEn == 'Padma Bridge'), isTrue);
    });
  });

  group('names', () {
    test('coverage is reported honestly and exact matches carry Bangla', () {
      final withBn = net.stations.values.where((s) => s.hasBanglaName).length;
      expect(withBn, greaterThan(150));
      expect(withBn, lessThan(386)); // not every station is recoverable
      expect(net.station('joydebpur')!.nameBn, isNotEmpty);
    });
    test('curated names are tagged as curated', () {
      expect(net.station('dhaka')!.nameBn, 'ঢাকা');
      expect(net.station('dhaka')!.nameSource, NameSource.curated);
    });
    test('unavailable names fall back to English', () {
      final s = net.stations.values.firstWhere((s) => !s.hasBanglaName);
      expect(s.displayName('bn'), s.nameEn);
    });
    test('titleFromKey', () => expect(titleFromKey('gouripur_myn'), 'Gouripur Myn'));
  });

  group('routing', () {
    final finder = RouteFinder(net);
    test('Dhaka to Chattogram is continuous and plausibly long', () {
      final r = finder.find('dhaka', 'chattogram')!;
      expect(r.originKey, 'dhaka');
      expect(r.destinationKey, 'chattogram');
      expect(r.totalKm, inInclusiveRange(215, 400));
      expect(r.legs.length, r.stationKeys.length - 1);
      expect(r.polyline.first, net.station('dhaka')!.position);
      expect(r.polyline.last, net.station('chattogram')!.position);
      for (var i = 1; i < r.polyline.length; i++) {
        // Some OSM segments are sparse (~26 km between vertices); only gaps larger than that would indicate a broken join.
        expect(haversineMeters(r.polyline[i - 1], r.polyline[i]), lessThan(60000));
      }
    });
    test('route lists stations along the track, not just graph nodes', () {
      final r = finder.find('dhaka', 'chattogram')!;
      final keys = r.along.map((a) => a.key).toList();
      expect(keys.first, 'dhaka');
      expect(keys.last, 'chattogram');
      expect(keys.length, greaterThan(r.stationKeys.length));
      expect(keys, contains('cumilla'));
      // strictly ordered along the track
      for (var i = 1; i < r.along.length; i++) {
        expect(r.along[i].atMeters, greaterThanOrEqualTo(r.along[i - 1].atMeters));
      }
      expect(r.stopCount, r.along.length);
    });
    test('symmetric distance and same-station route', () {
      final ab = finder.find('dhaka', 'sylhet')!;
      final ba = finder.find('sylhet', 'dhaka')!;
      expect(ab.totalMeters, closeTo(ba.totalMeters, 1));
      expect(finder.find('dhaka', 'dhaka')!.totalMeters, 0);
    });
    test('unknown station returns null', () => expect(finder.find('dhaka', 'zzz'), isNull));
    test('Khulna route crosses the Padma bridge', () {
      final r = finder.find('dhaka', 'khulna')!;
      expect(r.bridges.any((b) => (b.nameEn ?? '').contains('Padma')), isTrue);
    });
  });

  group('search', () {
    final idx = SearchIndex(network: net, places: bundle.places);
    test('English prefix and exact', () {
      final hits = idx.search('Sylhet');
      expect(hits.first, isA<StationHit>());
      expect((hits.first as StationHit).station.key, 'sylhet');
    });
    test('Bangla query finds stations', () {
      final hits = idx.search('ঢাকা');
      expect(hits.whereType<StationHit>().any((h) => h.station.key == 'dhaka'), isTrue);
    });
    test('nukta encodings match (precomposed vs decomposed)', () {
      expect(normalizeText('য়'), normalizeText('য়'));
    });
    test('blank returns nothing; gibberish returns nothing', () {
      expect(idx.search('   '), isEmpty);
      expect(idx.search('qqqzzzxxx'), isEmpty);
    });
    test('places are searchable', () => expect(idx.search('Uttara').whereType<PlaceHit>(), isNotEmpty));
  });

  group('train repositories', () {
    test('unconfigured never produces data', () async {
      const r = UnconfiguredTrainRepository();
      expect(await r.watchTrainPositions().toList(), isEmpty);
      final s = await r.getServiceStatus();
      expect(s.state, ServiceState.notConfigured);
      expect(await r.getTrainDetails('x'), isNull);
    });

    test('demo is always labelled demo and moves along track', () {
      var now = DateTime(2026, 1, 1, 10);
      final r = MockTrainRepository(net, clock: () => now);
      expect(r.tripCount, greaterThan(3));
      final a = r.snapshotAt(now);
      now = now.add(const Duration(minutes: 1));
      final b = r.snapshotAt(now);
      expect(a.source, TrainDataSourceKind.demo);
      expect(a.trains.every((t) => t.label.startsWith('DEMO-')), isTrue);
      var moved = 0;
      for (var i = 0; i < a.trains.length; i++) {
        if (haversineMeters(a.trains[i].position, b.trains[i].position) > 100) moved++;
        expect(GeoBounds.bangladesh.contains(b.trains[i].position), isTrue);
      }
      expect(moved, a.trains.length);
      r.dispose();
    });

    test('demo stream emits, details resolve, status says demo', () async {
      final r = MockTrainRepository(net, tick: const Duration(milliseconds: 20));
      final first = await r.watchTrainPositions().first;
      expect(first.source, TrainDataSourceKind.demo);
      final d = await r.getTrainDetails('demo-1');
      expect(d!.stationKeys.first, 'dhaka');
      expect(await r.getTrainDetails('nope'), isNull);
      expect((await r.getServiceStatus()).state, ServiceState.demo);
      r.dispose();
    });

    test('paused demo stops emitting (stale handling can be shown)', () async {
      final r = MockTrainRepository(net, tick: const Duration(milliseconds: 10));
      final got = <TrainSnapshot>[];
      final sub = r.watchTrainPositions().listen(got.add);
      await Future<void>.delayed(const Duration(milliseconds: 60));
      r.setPaused(true);
      final n = got.length;
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(got.length, n);
      await sub.cancel();
      r.dispose();
    });
  });

  group('staleness', () {
    const p = StalenessPolicy(staleAfter: Duration(seconds: 10));
    final t = DateTime(2026, 1, 1, 12);
    test('unknown / fresh / stale', () {
      expect(p.evaluate(null, t), Freshness.unknown);
      expect(p.evaluate(t, t.add(const Duration(seconds: 5))), Freshness.fresh);
      expect(p.evaluate(t, t.add(const Duration(seconds: 11))), Freshness.stale);
    });
  });
}
