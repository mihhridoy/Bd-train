import 'geo.dart';

/// Where train data comes from. The UI must always show this to the user.
enum TrainDataSourceKind {
  /// Real feed (requires owner-supplied backend; not available in this repo).
  live,

  /// Simulated positions produced locally. NEVER present as live.
  demo,

  /// No backend configured.
  notConfigured,
}

enum ServiceState { notConfigured, demo, operational, degraded, offline }

/// One train's position at a point in time.
class TrainPosition {
  const TrainPosition({
    required this.id,
    required this.label,
    required this.position,
    required this.headingDegrees,
    required this.speedKmh,
    required this.timestamp,
    this.originKey,
    this.destinationKey,
    this.progress,
  });

  final String id;

  /// Human label. Demo trains are labelled `DEMO-n`, never real train names.
  final String label;
  final GeoPoint position;
  final double headingDegrees;
  final double speedKmh;
  final DateTime timestamp;
  final String? originKey;
  final String? destinationKey;

  /// 0..1 along the trip when known.
  final double? progress;
}

class TrainSnapshot {
  const TrainSnapshot({
    required this.source,
    required this.fetchedAt,
    required this.trains,
  });

  final TrainDataSourceKind source;
  final DateTime fetchedAt;
  final List<TrainPosition> trains;

  bool get isEmpty => trains.isEmpty;
}

class TrainDetails {
  const TrainDetails({
    required this.id,
    required this.label,
    required this.source,
    required this.stationKeys,
    this.lastPosition,
  });

  final String id;
  final String label;
  final TrainDataSourceKind source;

  /// Ordered stations on the train's path.
  final List<String> stationKeys;
  final TrainPosition? lastPosition;
}

class ServiceStatus {
  const ServiceStatus({
    required this.source,
    required this.state,
    this.lastUpdated,
    this.message,
  });

  final TrainDataSourceKind source;
  final ServiceState state;
  final DateTime? lastUpdated;
  final String? message;
}

enum Freshness { fresh, stale, unknown }

/// Staleness policy for incoming data.
class StalenessPolicy {
  const StalenessPolicy({this.staleAfter = const Duration(seconds: 15)});
  final Duration staleAfter;

  Freshness evaluate(DateTime? lastUpdate, DateTime now) {
    if (lastUpdate == null) return Freshness.unknown;
    return now.difference(lastUpdate) > staleAfter
        ? Freshness.stale
        : Freshness.fresh;
  }
}
