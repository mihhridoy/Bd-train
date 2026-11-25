import 'dart:math' as math;

/// Immutable WGS84 coordinate. Dataset order is latitude, then longitude.
class GeoPoint {
  const GeoPoint(this.lat, this.lng);

  final double lat;
  final double lng;

  @override
  bool operator ==(Object other) =>
      other is GeoPoint && other.lat == lat && other.lng == lng;

  @override
  int get hashCode => Object.hash(lat, lng);

  @override
  String toString() => 'GeoPoint($lat, $lng)';
}

/// Axis aligned bounding box in degrees.
class GeoBounds {
  const GeoBounds(this.south, this.west, this.north, this.east);

  final double south;
  final double west;
  final double north;
  final double east;

  /// Rough envelope of Bangladesh (with margin) used to validate records.
  static const bangladesh = GeoBounds(20.4, 87.8, 26.9, 92.9);

  bool contains(GeoPoint p) =>
      p.lat >= south && p.lat <= north && p.lng >= west && p.lng <= east;

  static GeoBounds? of(Iterable<GeoPoint> points) {
    double? s, w, n, e;
    for (final p in points) {
      s = s == null ? p.lat : math.min(s, p.lat);
      n = n == null ? p.lat : math.max(n, p.lat);
      w = w == null ? p.lng : math.min(w, p.lng);
      e = e == null ? p.lng : math.max(e, p.lng);
    }
    if (s == null) return null;
    return GeoBounds(s, w!, n!, e!);
  }

  bool intersects(GeoBounds o) =>
      !(o.west > east || o.east < west || o.south > north || o.north < south);
}

const double _earthRadiusM = 6371008.8;

double _rad(double deg) => deg * math.pi / 180.0;

/// Great-circle distance in meters.
double haversineMeters(GeoPoint a, GeoPoint b) {
  final dLat = _rad(b.lat - a.lat);
  final dLng = _rad(b.lng - a.lng);
  final h = math.pow(math.sin(dLat / 2), 2) +
      math.cos(_rad(a.lat)) * math.cos(_rad(b.lat)) * math.pow(math.sin(dLng / 2), 2);
  return 2 * _earthRadiusM * math.asin(math.min(1.0, math.sqrt(h)));
}

/// Total length of a polyline in meters.
double polylineLengthMeters(List<GeoPoint> points) {
  var total = 0.0;
  for (var i = 1; i < points.length; i++) {
    total += haversineMeters(points[i - 1], points[i]);
  }
  return total;
}

/// Initial bearing from [a] to [b] in degrees (0 = north, clockwise).
double bearingDegrees(GeoPoint a, GeoPoint b) {
  final y = math.sin(_rad(b.lng - a.lng)) * math.cos(_rad(b.lat));
  final x = math.cos(_rad(a.lat)) * math.sin(_rad(b.lat)) -
      math.sin(_rad(a.lat)) * math.cos(_rad(b.lat)) * math.cos(_rad(b.lng - a.lng));
  return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
}

/// Distance in meters from [p] to the segment [a]-[b] (local planar approx,
/// accurate to well under 1% at Bangladesh scale for short segments).
double distanceToSegmentMeters(GeoPoint p, GeoPoint a, GeoPoint b) {
  final cosLat = math.cos(_rad(p.lat));
  double x(GeoPoint q) => _rad(q.lng) * cosLat * _earthRadiusM;
  double y(GeoPoint q) => _rad(q.lat) * _earthRadiusM;
  final px = x(p), py = y(p), ax = x(a), ay = y(a), bx = x(b), by = y(b);
  final dx = bx - ax, dy = by - ay;
  final len2 = dx * dx + dy * dy;
  var t = len2 == 0 ? 0.0 : ((px - ax) * dx + (py - ay) * dy) / len2;
  t = t.clamp(0.0, 1.0);
  final cx = ax + t * dx, cy = ay + t * dy;
  return math.sqrt(math.pow(px - cx, 2) + math.pow(py - cy, 2));
}

/// Minimum distance in meters from [p] to a polyline.
double distanceToPolylineMeters(GeoPoint p, List<GeoPoint> line) {
  if (line.isEmpty) return double.infinity;
  if (line.length == 1) return haversineMeters(p, line.first);
  var best = double.infinity;
  for (var i = 1; i < line.length; i++) {
    best = math.min(best, distanceToSegmentMeters(p, line[i - 1], line[i]));
  }
  return best;
}

/// Point located [distanceM] meters along [line] (clamped to its ends).
/// [cumulative] may be supplied to avoid recomputation.
GeoPoint pointAlong(List<GeoPoint> line, double distanceM, {List<double>? cumulative}) {
  assert(line.isNotEmpty);
  if (line.length == 1 || distanceM <= 0) return line.first;
  final cum = cumulative ?? cumulativeLengths(line);
  if (distanceM >= cum.last) return line.last;
  var lo = 1, hi = cum.length - 1;
  while (lo < hi) {
    final mid = (lo + hi) >> 1;
    if (cum[mid] < distanceM) {
      lo = mid + 1;
    } else {
      hi = mid;
    }
  }
  final segLen = cum[lo] - cum[lo - 1];
  final t = segLen == 0 ? 0.0 : (distanceM - cum[lo - 1]) / segLen;
  final a = line[lo - 1], b = line[lo];
  return GeoPoint(a.lat + (b.lat - a.lat) * t, a.lng + (b.lng - a.lng) * t);
}

/// Cumulative distance (m) at each vertex of [line]; first entry is 0.
List<double> cumulativeLengths(List<GeoPoint> line) {
  final out = List<double>.filled(line.length, 0);
  for (var i = 1; i < line.length; i++) {
    out[i] = out[i - 1] + haversineMeters(line[i - 1], line[i]);
  }
  return out;
}
