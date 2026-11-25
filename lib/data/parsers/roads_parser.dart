import '../../domain/entities/geo.dart';
import '../../domain/entities/rail_entities.dart';
import 'parse_support.dart';

class ParsedRoads {
  ParsedRoads(this.info, this.roads, this.issues);
  final DatasetInfo info;
  final List<RoadWay> roads;
  final List<String> issues;
}

/// `roads.json`: `{attribution, roads: [[nameBn, nameEn, [[lat, lng], …]], …]}`.
ParsedRoads parseRoads(Object? root) {
  const file = 'roads.json';
  if (root is! Map || root['roads'] is! List) {
    throw DatasetFormatException(file, 'expected object with a "roads" array');
  }
  final log = IssueLog(file);
  final out = <RoadWay>[];
  final list = root['roads'] as List;
  for (var i = 0; i < list.length; i++) {
    final r = list[i];
    if (r is! List || r.length < 3 || r[0] is! String || r[1] is! String || r[2] is! List) {
      log.add('record $i: malformed');
      continue;
    }
    final pts = <GeoPoint>[];
    var bad = false;
    for (final raw in r[2] as List) {
      final p = parsePoint(raw);
      if (p == null) {
        bad = true;
        break;
      }
      pts.add(p);
    }
    if (bad || pts.length < 2) {
      log.add('record $i: invalid geometry');
      continue;
    }
    out.add(RoadWay(nameBn: r[0] as String, nameEn: r[1] as String, points: pts));
  }
  return ParsedRoads(
    DatasetInfo(attribution: root['attribution'] as String? ?? ''),
    out,
    log.toList(),
  );
}

/// Parses `[lat, lng]`; returns null when invalid or out of range.
GeoPoint? parsePoint(Object? raw) {
  if (raw is! List || raw.length < 2) return null;
  final lat = asDouble(raw[0]), lng = asDouble(raw[1]);
  if (lat == null || lng == null) return null;
  final p = GeoPoint(lat, lng);
  return GeoBounds.bangladesh.contains(p) ? p : null;
}
