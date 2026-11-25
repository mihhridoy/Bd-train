import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../domain/entities/rail_network.dart';
import '../../domain/repositories/rail_repository.dart';
import '../../domain/usecases/station_name_resolver.dart';
import '../datasources/rail_asset_source.dart';
import '../parsers/parse_support.dart';
import '../parsers/places_parser.dart';
import '../parsers/roads_parser.dart';
import '../parsers/segments_parser.dart';

/// Loads and validates the bundled datasets entirely offline.
class AssetRailRepository implements RailRepository {
  AssetRailRepository(this._source, {this.useIsolate = true});
  final RailAssetSource _source;

  /// Parse off the UI thread. Disabled in some tests.
  final bool useIsolate;

  @override
  Future<RailDataBundle> load() async {
    final raw = RawRailDatasets(
      places: await _source.read(RailAssets.places),
      roads: await _source.read(RailAssets.roads),
      segments: await _source.read(RailAssets.segments),
      curated: await _source.read(RailAssets.curatedNames),
    );
    return useIsolate ? compute(buildBundle, raw) : buildBundle(raw);
  }
}

class RawRailDatasets {
  const RawRailDatasets({
    required this.places,
    required this.roads,
    required this.segments,
    required this.curated,
  });
  final String places, roads, segments, curated;
}

/// Pure function (top-level so it can run in an isolate).
RailDataBundle buildBundle(RawRailDatasets raw) {
  final places = parsePlaces(jsonDecode(raw.places));
  final roads = parseRoads(jsonDecode(raw.roads));
  final segs = parseSegments(jsonDecode(raw.segments));

  final curatedJson = jsonDecode(raw.curated);
  final curated = <String, String>{};
  if (curatedJson is Map && curatedJson['names'] is Map) {
    (curatedJson['names'] as Map).forEach((k, v) {
      if (k is String && v is String) curated[k] = v;
    });
  } else {
    throw DatasetFormatException('station_names_bn.json', 'missing "names" object');
  }

  final stations = StationNameResolver().resolve(
    stationPositions: segs.stationPositions,
    places: places.places,
    curatedBangla: curated,
  );
  final network = RailNetwork(
    stations: {for (final s in stations) s.key: s},
    segments: segs.segments,
    bridges: segs.bridges,
    info: segs.info,
  );
  return RailDataBundle(
    network: network,
    places: places.places,
    roads: roads.roads,
    placesInfo: places.info,
    roadsInfo: roads.info,
    issues: [...places.issues, ...roads.issues, ...segs.issues],
  );
}

/// Exposed for tests that want to bypass the asset bundle.
@visibleForTesting
RailDataBundle buildBundleFromJson({
  required String places,
  required String roads,
  required String segments,
  String curated = '{"names":{}}',
}) =>
    buildBundle(RawRailDatasets(places: places, roads: roads, segments: segments, curated: curated));
