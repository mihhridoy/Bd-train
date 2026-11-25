import 'dart:async';

import '../../domain/entities/geo.dart';
import '../../domain/entities/rail_network.dart';
import '../../domain/entities/rail_route.dart';
import '../../domain/entities/train.dart';
import '../../domain/repositories/train_repository.dart';
import '../../domain/usecases/route_finder.dart';

/// DEMO ONLY. Moves labelled placeholder trains back and forth along real track
/// geometry. These are NOT real trains and NOT real schedules; every snapshot
/// carries [TrainDataSourceKind.demo] and the UI must say so.
class MockTrainRepository implements TrainRepository {
  MockTrainRepository(
    this.network, {
    DateTime Function()? clock,
    this.tick = const Duration(seconds: 1),
    this.timeScale = defaultTimeScale,
    List<(String, String)>? trips,
  })  : _clock = clock ?? DateTime.now,
        _start = (clock ?? DateTime.now)() {
    final finder = RouteFinder(network);
    final wanted = trips ?? defaultTrips;
    var n = 1;
    for (final (from, to) in wanted) {
      final route = finder.find(from, to);
      if (route == null || route.polyline.length < 2) continue;
      _trips.add(_Trip(
        id: 'demo-$n',
        label: 'DEMO-$n',
        route: route,
        cumulative: cumulativeLengths(route.polyline),
        speedMps: (50.0 + (n * 7) % 40) / 3.6,
        phaseMeters: route.totalMeters * ((n * 0.37) % 1.0),
      ));
      n++;
    }
  }

  static const defaultTimeScale = 30.0;

  /// Origin/destination pairs for the placeholder trips. Pairs whose stations
  /// are missing from the dataset are skipped.
  static const defaultTrips = <(String, String)>[
    ('dhaka', 'chattogram'),
    ('dhaka', 'sylhet'),
    ('dhaka', 'khulna'),
    ('dhaka', 'rajshahi'),
    ('dhaka', 'mymensingh'),
    ('dhaka', 'rangpur'),
  ];

  final RailNetwork network;
  final Duration tick;

  /// Simulation speed-up so motion is visible on screen. Shown to the user.
  final double timeScale;
  final DateTime Function() _clock;
  final DateTime _start;
  final List<_Trip> _trips = [];
  final StreamController<TrainSnapshot> _controller =
      StreamController<TrainSnapshot>.broadcast();
  Timer? _timer;
  bool _paused = false;

  @override
  TrainDataSourceKind get sourceKind => TrainDataSourceKind.demo;

  bool get paused => _paused;

  /// Stops emitting so the UI's stale-data handling can be demonstrated.
  void setPaused(bool value) => _paused = value;

  int get tripCount => _trips.length;

  @override
  Stream<TrainSnapshot> watchTrainPositions() {
    // Late subscribers get the current state immediately.
    final controller = StreamController<TrainSnapshot>();
    controller.add(snapshotAt(_clock()));
    final sub = _controller.stream.listen(controller.add);
    controller.onCancel = () async {
      await sub.cancel();
      _maybeStopTimer();
    };
    _timer ??= Timer.periodic(tick, (_) {
      if (_paused || !_controller.hasListener) return;
      _controller.add(snapshotAt(_clock()));
    });
    return controller.stream;
  }

  void _maybeStopTimer() {
    if (!_controller.hasListener) {
      _timer?.cancel();
      _timer = null;
    }
  }

  /// Deterministic snapshot for [now]. Public for tests.
  TrainSnapshot snapshotAt(DateTime now) => TrainSnapshot(
        source: TrainDataSourceKind.demo,
        fetchedAt: now,
        trains: [for (final t in _trips) _positionOf(t, now)],
      );

  TrainPosition _positionOf(_Trip t, DateTime now) {
    final elapsed = now.difference(_start).inMilliseconds / 1000.0;
    final total = t.route.totalMeters;
    final travelled = t.phaseMeters + elapsed * t.speedMps * timeScale;
    var s = travelled % (2 * total);
    final forward = s <= total;
    if (!forward) s = 2 * total - s;
    final pos = pointAlong(t.route.polyline, s, cumulative: t.cumulative);
    final ahead = pointAlong(t.route.polyline, forward ? s + 50 : s - 50, cumulative: t.cumulative);
    return TrainPosition(
      id: t.id,
      label: t.label,
      position: pos,
      headingDegrees: pos == ahead ? 0 : bearingDegrees(pos, ahead),
      speedKmh: t.speedMps * 3.6,
      timestamp: now,
      originKey: forward ? t.route.originKey : t.route.destinationKey,
      destinationKey: forward ? t.route.destinationKey : t.route.originKey,
      progress: (s / total).clamp(0.0, 1.0),
    );
  }

  @override
  Future<TrainDetails?> getTrainDetails(String trainId) async {
    for (final t in _trips) {
      if (t.id == trainId) {
        return TrainDetails(
          id: t.id,
          label: t.label,
          source: TrainDataSourceKind.demo,
          stationKeys: t.route.stationKeys,
          lastPosition: _positionOf(t, _clock()),
        );
      }
    }
    return null;
  }

  @override
  Future<ServiceStatus> getServiceStatus() async => ServiceStatus(
        source: TrainDataSourceKind.demo,
        state: ServiceState.demo,
        lastUpdated: _clock(),
        message: 'Simulated trains on real track geometry. Not live data.',
      );

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _controller.close();
  }
}

class _Trip {
  _Trip({
    required this.id,
    required this.label,
    required this.route,
    required this.cumulative,
    required this.speedMps,
    required this.phaseMeters,
  });
  final String id;
  final String label;
  final RailRoute route;
  final List<double> cumulative;
  final double speedMps;
  final double phaseMeters;
}
