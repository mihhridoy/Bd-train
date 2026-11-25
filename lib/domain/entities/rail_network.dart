import 'geo.dart';
import 'rail_entities.dart';

/// One directed view of a [RailSegment] as seen from a station.
class RailEdge {
  const RailEdge(this.segment, this.to);
  final RailSegment segment;
  final String to;
}

/// Static rail geometry: stations, track segments and bridges.
///
/// Holds no live train state. Immutable after construction.
class RailNetwork {
  RailNetwork({
    required Map<String, Station> stations,
    required List<RailSegment> segments,
    required List<RailBridge> bridges,
    this.info = const DatasetInfo(attribution: ''),
  })  : stations = Map.unmodifiable(stations),
        segments = List.unmodifiable(segments),
        bridges = List.unmodifiable(bridges),
        _adjacency = _buildAdjacency(segments) {
    for (final s in this.segments) {
      assert(this.stations.containsKey(s.a) && this.stations.containsKey(s.b),
          'Segment ${s.key} references an unknown station');
    }
  }

  final Map<String, Station> stations;
  final List<RailSegment> segments;
  final List<RailBridge> bridges;
  final DatasetInfo info;
  final Map<String, List<RailEdge>> _adjacency;

  static Map<String, List<RailEdge>> _buildAdjacency(List<RailSegment> segs) {
    final adj = <String, List<RailEdge>>{};
    for (final s in segs) {
      (adj[s.a] ??= []).add(RailEdge(s, s.b));
      (adj[s.b] ??= []).add(RailEdge(s, s.a));
    }
    return adj;
  }

  Station? station(String key) => stations[key];

  List<RailEdge> edgesOf(String key) => _adjacency[key] ?? const [];

  /// Number of track segments touching the station (1 = terminus, 3+ = junction).
  int degree(String key) => edgesOf(key).length;

  bool isJunction(String key) => degree(key) >= 3;

  RailSegment? segmentBetween(String a, String b) {
    for (final e in edgesOf(a)) {
      if (e.to == b) return e.segment;
    }
    return null;
  }

  /// Stations ordered by distance from [point], nearest first.
  List<NearbyStation> nearestStations(GeoPoint point, {int limit = 5, double? maxMeters}) {
    final list = <NearbyStation>[
      for (final s in stations.values)
        NearbyStation(s, haversineMeters(point, s.position)),
    ]..sort((x, y) => x.distanceMeters.compareTo(y.distanceMeters));
    final filtered = maxMeters == null
        ? list
        : list.where((n) => n.distanceMeters <= maxMeters).toList();
    return filtered.take(limit).toList(growable: false);
  }

  /// Bridges whose midpoint lies within [meters] of [point].
  List<RailBridge> bridgesNear(GeoPoint point, double meters) => [
        for (final b in bridges)
          if (haversineMeters(point, b.midpoint) <= meters) b,
      ];

  /// Connected components as sets of station keys (largest first).
  List<Set<String>> connectedComponents() {
    final seen = <String>{};
    final out = <Set<String>>[];
    for (final key in stations.keys) {
      if (seen.contains(key)) continue;
      final comp = <String>{};
      final stack = [key];
      seen.add(key);
      while (stack.isNotEmpty) {
        final cur = stack.removeLast();
        comp.add(cur);
        for (final e in edgesOf(cur)) {
          if (seen.add(e.to)) stack.add(e.to);
        }
      }
      out.add(comp);
    }
    out.sort((a, b) => b.length.compareTo(a.length));
    return out;
  }
}

class NearbyStation {
  const NearbyStation(this.station, this.distanceMeters);
  final Station station;
  final double distanceMeters;
}
