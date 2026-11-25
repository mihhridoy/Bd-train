import '../../domain/entities/geo.dart';
import '../../domain/entities/rail_entities.dart';
import 'parse_support.dart';
import 'roads_parser.dart' show parsePoint;

class ParsedSegments {
  ParsedSegments({
    required this.info,
    required this.stationPositions,
    required this.segments,
    required this.bridges,
    required this.issues,
  });

  final DatasetInfo info;
  final Map<String, GeoPoint> stationPositions;
  final List<RailSegment> segments;
  final List<RailBridge> bridges;
  final List<String> issues;
}

/// `segments.json`: `{attribution, generated, stations, segments, bridges}`.
ParsedSegments parseSegments(Object? root) {
  const file = 'segments.json';
  if (root is! Map || root['stations'] is! Map || root['segments'] is! Map) {
    throw DatasetFormatException(file, 'expected "stations" and "segments" objects');
  }
  final log = IssueLog(file);

  final stations = <String, GeoPoint>{};
  (root['stations'] as Map).forEach((k, v) {
    final p = parsePoint(v);
    if (k is! String || k.isEmpty || p == null) {
      log.add('station $k: invalid');
      return;
    }
    stations[k] = p;
  });

  final segments = <RailSegment>[];
  final seenPairs = <String>{};
  (root['segments'] as Map).forEach((k, v) {
    if (k is! String) return;
    final parts = k.split('|');
    if (parts.length != 2 || parts[0].isEmpty || parts[1].isEmpty || parts[0] == parts[1]) {
      log.add('segment "$k": bad key');
      return;
    }
    final a = parts[0], b = parts[1];
    if (!stations.containsKey(a) || !stations.containsKey(b)) {
      log.add('segment "$k": unknown station');
      return;
    }
    if (v is! List || v.length < 2) {
      log.add('segment "$k": geometry too short');
      return;
    }
    final pts = <GeoPoint>[];
    for (final raw in v) {
      final p = parsePoint(raw);
      if (p == null) {
        log.add('segment "$k": invalid point');
        return;
      }
      pts.add(p);
    }
    final canonical = a.compareTo(b) <= 0 ? '$a|$b' : '$b|$a';
    if (!seenPairs.add(canonical)) {
      log.add('segment "$k": duplicate of an existing pair');
      return;
    }
    segments.add(RailSegment(a: a, b: b, points: pts));
  });

  final bridges = <RailBridge>[];
  final rawBridges = root['bridges'];
  if (rawBridges is List) {
    for (var i = 0; i < rawBridges.length; i++) {
      final r = rawBridges[i];
      if (r is! Map) {
        log.add('bridge $i: malformed');
        continue;
      }
      final a = parsePoint(r['a']), b = parsePoint(r['b']);
      final l = r['l'];
      if (a == null || b == null || l is! num || !l.isFinite || l < 0) {
        log.add('bridge $i: invalid endpoints or length');
        continue;
      }
      bridges.add(RailBridge(
        a: a,
        b: b,
        lengthMeters: l.round(),
        nameBn: r['n'] is String ? r['n'] as String : null,
        nameEn: r['e'] is String ? r['e'] as String : null,
        flag: r['v'] is int ? r['v'] as int : null,
      ));
    }
  } else if (rawBridges != null) {
    log.add('"bridges" is not an array');
  }

  return ParsedSegments(
    info: DatasetInfo(
      attribution: root['attribution'] as String? ?? '',
      generated: root['generated'] as String?,
    ),
    stationPositions: stations,
    segments: segments,
    bridges: bridges,
    issues: log.toList(),
  );
}
