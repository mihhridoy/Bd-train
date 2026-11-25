import '../entities/rail_entities.dart';
import '../entities/rail_network.dart';

/// Everything loaded from the bundled static datasets.
class RailDataBundle {
  const RailDataBundle({
    required this.network,
    required this.places,
    required this.roads,
    required this.placesInfo,
    required this.roadsInfo,
    required this.issues,
  });

  final RailNetwork network;
  final List<Place> places;
  final List<RoadWay> roads;
  final DatasetInfo placesInfo;
  final DatasetInfo roadsInfo;

  /// Non-fatal problems found while parsing (dropped records etc.).
  final List<String> issues;
}

abstract interface class RailRepository {
  Future<RailDataBundle> load();
}
