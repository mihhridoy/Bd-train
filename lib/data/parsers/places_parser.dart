import '../../domain/entities/geo.dart';
import '../../domain/entities/rail_entities.dart';
import 'parse_support.dart';

class ParsedPlaces {
  ParsedPlaces(this.info, this.places, this.issues);
  final DatasetInfo info;
  final List<Place> places;
  final List<String> issues;
}

/// `places.json`: `{attribution, places: [[lat, lng, cat, nameBn, nameEn], …]}`.
ParsedPlaces parsePlaces(Object? root) {
  const file = 'places.json';
  if (root is! Map || root['places'] is! List) {
    throw DatasetFormatException(file, 'expected object with a "places" array');
  }
  final log = IssueLog(file);
  final out = <Place>[];
  final list = root['places'] as List;
  for (var i = 0; i < list.length; i++) {
    final r = list[i];
    if (r is! List || r.length < 5) {
      log.add('record $i: expected 5 fields');
      continue;
    }
    final lat = asDouble(r[0]), lng = asDouble(r[1]);
    final cat = r[2] is String ? PlaceCategory.fromCode(r[2] as String) : null;
    if (lat == null || lng == null) {
      log.add('record $i: invalid coordinates');
      continue;
    }
    final p = GeoPoint(lat, lng);
    if (!GeoBounds.bangladesh.contains(p)) {
      log.add('record $i: coordinates outside Bangladesh envelope');
      continue;
    }
    if (cat == null) {
      log.add('record $i: unknown category ${r[2]}');
      continue;
    }
    if (r[3] is! String || r[4] is! String || ((r[3] as String).isEmpty && (r[4] as String).isEmpty)) {
      log.add('record $i: missing name');
      continue;
    }
    out.add(Place(position: p, category: cat, nameBn: r[3] as String, nameEn: r[4] as String));
  }
  return ParsedPlaces(
    DatasetInfo(attribution: root['attribution'] as String? ?? ''),
    out,
    log.toList(),
  );
}
