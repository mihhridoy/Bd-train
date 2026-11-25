import 'geo.dart';
import 'rail_entities.dart';

/// A station lying on (or within [RouteFinder.alongToleranceMeters] of) the route.
class AlongStation {
  const AlongStation(this.key, this.atMeters);
  final String key;

  /// Distance from the route origin along the track.
  final double atMeters;
}

/// A path through the rail network between two stations.
///
/// This is pure geometry; it contains no timetable or schedule information.
class RailRoute {
  RailRoute({
    required this.stationKeys,
    required this.legs,
    required this.polyline,
    required this.totalMeters,
    required this.bridges,
    this.along = const [],
  });

  /// Ordered station keys, first = origin, last = destination.
  final List<String> stationKeys;

  /// One segment per hop (`stationKeys.length - 1` entries).
  final List<RailSegment> legs;

  /// Full track geometry from origin to destination.
  final List<GeoPoint> polyline;
  final double totalMeters;

  /// Stations the track passes, in order (includes origin and destination).
  ///
  /// `segments.json` contains long segments that skip intermediate stations, so
  /// [stationKeys] (graph nodes) can be far shorter than the real stop list.
  /// This list is derived from track proximity, not from a timetable.
  final List<AlongStation> along;

  /// Bridges lying on this route (by proximity to the track), in route order.
  final List<RailBridge> bridges;

  String get originKey => stationKeys.first;
  String get destinationKey => stationKeys.last;
  int get stopCount => along.isEmpty ? stationKeys.length : along.length;
  double get totalKm => totalMeters / 1000;
}
