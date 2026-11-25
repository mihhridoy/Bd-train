import '../entities/geo.dart';
import '../entities/rail_entities.dart';
import '../entities/rail_network.dart';
import '../entities/rail_route.dart';

/// Shortest-track-distance routing (Dijkstra) across the static rail graph.
class RouteFinder {
  RouteFinder(this.network);
  final RailNetwork network;

  /// Max distance between a bridge midpoint and the track to count it as on-route.
  static const double bridgeToleranceMeters = 150;

  /// Max distance between a station and the track for it to count as on-route.
  static const double alongToleranceMeters = 250;

  /// Returns null when either station is unknown or no path exists.
  RailRoute? find(String from, String to) {
    if (!network.stations.containsKey(from) || !network.stations.containsKey(to)) {
      return null;
    }
    final dist = <String, double>{from: 0};
    final prev = <String, RailEdge>{};
    final prevNode = <String, String>{};
    final queue = _MinHeap<String>();
    queue.push(from, 0);
    final done = <String>{};
    while (queue.isNotEmpty) {
      final cur = queue.pop();
      if (!done.add(cur)) continue;
      if (cur == to) break;
      final d = dist[cur]!;
      for (final e in network.edgesOf(cur)) {
        if (done.contains(e.to)) continue;
        final nd = d + e.segment.lengthMeters;
        if (nd < (dist[e.to] ?? double.infinity)) {
          dist[e.to] = nd;
          prev[e.to] = e;
          prevNode[e.to] = cur;
          queue.push(e.to, nd);
        }
      }
    }
    if (!dist.containsKey(to)) return null;

    final keys = <String>[to];
    final legs = <RailSegment>[];
    var cur = to;
    while (cur != from) {
      legs.add(prev[cur]!.segment);
      cur = prevNode[cur]!;
      keys.add(cur);
    }
    final orderedKeys = keys.reversed.toList(growable: false);
    final orderedLegs = legs.reversed.toList(growable: false);

    final polyline = <GeoPoint>[];
    for (var i = 0; i < orderedLegs.length; i++) {
      final pts = orderedLegs[i].orientedFrom(orderedKeys[i]);
      polyline.addAll(i == 0 ? pts : pts.skip(1));
    }
    if (orderedLegs.isEmpty) polyline.add(network.stations[from]!.position);

    final total = orderedLegs.fold<double>(0, (s, l) => s + l.lengthMeters);
    return RailRoute(
      stationKeys: orderedKeys,
      legs: orderedLegs,
      polyline: polyline,
      totalMeters: total,
      bridges: _bridgesOn(polyline),
      along: _stationsAlong(polyline, orderedKeys.first, orderedKeys.last, total),
    );
  }

  List<AlongStation> _stationsAlong(
      List<GeoPoint> polyline, String from, String to, double total) {
    if (polyline.length < 2) return [AlongStation(from, 0)];
    final bounds = GeoBounds.of(polyline)!;
    final cum = cumulativeLengths(polyline);
    const slack = 0.004; // ~450 m in degrees, cheap bbox reject
    final found = <AlongStation>[];
    for (final s in network.stations.values) {
      if (s.key == from || s.key == to) continue;
      final p = s.position;
      if (p.lat < bounds.south - slack || p.lat > bounds.north + slack ||
          p.lng < bounds.west - slack || p.lng > bounds.east + slack) {
        continue;
      }
      var best = double.infinity;
      var bestIdx = 1;
      for (var i = 1; i < polyline.length; i++) {
        final d = distanceToSegmentMeters(p, polyline[i - 1], polyline[i]);
        if (d < best) {
          best = d;
          bestIdx = i;
        }
      }
      if (best <= alongToleranceMeters) found.add(AlongStation(s.key, cum[bestIdx]));
    }
    found.sort((a, b) => a.atMeters.compareTo(b.atMeters));
    return [AlongStation(from, 0), ...found, AlongStation(to, total)];
  }

  List<RailBridge> _bridgesOn(List<GeoPoint> polyline) {
    if (polyline.length < 2) return const [];
    final bounds = GeoBounds.of(polyline)!;
    final result = <(double, RailBridge)>[];
    final cum = cumulativeLengths(polyline);
    for (final b in network.bridges) {
      final m = b.midpoint;
      // Cheap reject using bounding box with ~0.01 deg (~1 km) slack.
      if (m.lat < bounds.south - 0.01 || m.lat > bounds.north + 0.01 ||
          m.lng < bounds.west - 0.01 || m.lng > bounds.east + 0.01) {
        continue;
      }
      var best = double.infinity;
      var bestIdx = 0;
      for (var i = 1; i < polyline.length; i++) {
        final d = distanceToSegmentMeters(m, polyline[i - 1], polyline[i]);
        if (d < best) {
          best = d;
          bestIdx = i;
        }
      }
      if (best <= bridgeToleranceMeters) result.add((cum[bestIdx], b));
    }
    result.sort((x, y) => x.$1.compareTo(y.$1));
    return result.map((e) => e.$2).toList(growable: false);
  }
}

/// Minimal binary min-heap keyed by priority.
class _MinHeap<T> {
  final List<(double, T)> _data = [];

  bool get isNotEmpty => _data.isNotEmpty;

  void push(T value, double priority) {
    _data.add((priority, value));
    var i = _data.length - 1;
    while (i > 0) {
      final parent = (i - 1) >> 1;
      if (_data[parent].$1 <= _data[i].$1) break;
      final t = _data[parent];
      _data[parent] = _data[i];
      _data[i] = t;
      i = parent;
    }
  }

  T pop() {
    final top = _data.first;
    final last = _data.removeLast();
    if (_data.isNotEmpty) {
      _data[0] = last;
      var i = 0;
      while (true) {
        final l = 2 * i + 1, r = l + 1;
        var m = i;
        if (l < _data.length && _data[l].$1 < _data[m].$1) m = l;
        if (r < _data.length && _data[r].$1 < _data[m].$1) m = r;
        if (m == i) break;
        final t = _data[m];
        _data[m] = _data[i];
        _data[i] = t;
        i = m;
      }
    }
    return top.$2;
  }
}
