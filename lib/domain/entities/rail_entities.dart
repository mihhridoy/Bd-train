import 'geo.dart';

/// Where a station's Bangla name came from. Never invented silently.
enum NameSource {
  /// Exact place-name match in the bundled OSM places dataset.
  datasetExact,

  /// Close spelling variant of a nearby place in the dataset.
  datasetFuzzy,

  /// Hand-curated supplement shipped with the app (assets/rail is untouched).
  curated,

  /// No Bangla name is available; the UI falls back to the English name.
  unavailable,
}

class Station {
  const Station({
    required this.key,
    required this.position,
    required this.nameEn,
    this.nameBn,
    this.nameSource = NameSource.unavailable,
  });

  /// Stable dataset key (ASCII slug), e.g. `dhaka`.
  final String key;
  final GeoPoint position;
  final String nameEn;
  final String? nameBn;
  final NameSource nameSource;

  bool get hasBanglaName => nameBn != null && nameBn!.isNotEmpty;

  /// Display name for [languageCode] (`bn` or `en`), falling back to English.
  String displayName(String languageCode) =>
      languageCode == 'bn' && hasBanglaName ? nameBn! : nameEn;

  Station copyWith({String? nameEn, String? nameBn, NameSource? nameSource}) =>
      Station(
        key: key,
        position: position,
        nameEn: nameEn ?? this.nameEn,
        nameBn: nameBn ?? this.nameBn,
        nameSource: nameSource ?? this.nameSource,
      );
}

/// Category codes used in `places.json`.
enum PlaceCategory {
  city('c'),
  town('t'),
  suburb('s'),
  village('v'),
  /// Observed in the data (`r`); meaning is not documented, kept as-is.
  other('r');

  const PlaceCategory(this.code);
  final String code;

  static PlaceCategory? fromCode(String code) {
    for (final c in values) {
      if (c.code == code) return c;
    }
    return null;
  }

  /// Minimum zoom at which this category is drawn on the map.
  double get minZoom => switch (this) {
        PlaceCategory.city => 6,
        PlaceCategory.town => 8.5,
        PlaceCategory.suburb => 11,
        PlaceCategory.other => 11,
        PlaceCategory.village => 12,
      };
}

class Place {
  const Place({
    required this.position,
    required this.category,
    required this.nameBn,
    required this.nameEn,
  });

  final GeoPoint position;
  final PlaceCategory category;
  final String nameBn;
  final String nameEn;

  String displayName(String languageCode) =>
      languageCode == 'bn' && nameBn.isNotEmpty ? nameBn : nameEn;
}

class RoadWay {
  RoadWay({required this.nameBn, required this.nameEn, required this.points})
      : bounds = GeoBounds.of(points)!;

  final String nameBn;
  final String nameEn;
  final List<GeoPoint> points;
  final GeoBounds bounds;

  String displayName(String languageCode) =>
      languageCode == 'bn' && nameBn.isNotEmpty ? nameBn : nameEn;
}

/// Polyline between two adjacent stations. [points] run from [a] to [b].
class RailSegment {
  RailSegment({required this.a, required this.b, required this.points})
      : lengthMeters = polylineLengthMeters(points);

  final String a;
  final String b;
  final List<GeoPoint> points;
  final double lengthMeters;

  String get key => '$a|$b';

  /// The station at the other end from [station].
  String other(String station) => station == a ? b : a;

  /// Points oriented so that they start at [from].
  List<GeoPoint> orientedFrom(String from) =>
      from == a ? points : points.reversed.toList(growable: false);
}

class RailBridge {
  const RailBridge({
    required this.a,
    required this.b,
    required this.lengthMeters,
    this.nameBn,
    this.nameEn,
    this.flag,
  });

  final GeoPoint a;
  final GeoPoint b;
  final int lengthMeters;
  final String? nameBn;
  final String? nameEn;

  /// Raw `v` value from the dataset. Its meaning is not documented, so it is
  /// preserved but never shown to users.
  final int? flag;

  GeoPoint get midpoint => GeoPoint((a.lat + b.lat) / 2, (a.lng + b.lng) / 2);

  bool get hasName => (nameBn ?? nameEn ?? '').isNotEmpty;

  String displayName(String languageCode) {
    if (languageCode == 'bn' && (nameBn ?? '').isNotEmpty) return nameBn!;
    return nameEn ?? nameBn ?? '';
  }
}

/// Metadata carried by each dataset file.
class DatasetInfo {
  const DatasetInfo({required this.attribution, this.generated});
  final String attribution;
  final String? generated;
}
