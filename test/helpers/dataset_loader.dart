import 'dart:io';

import 'package:bd_train_tracker/data/repositories/asset_rail_repository.dart';
import 'package:bd_train_tracker/domain/repositories/rail_repository.dart';

String _read(String p) => File(p).readAsStringSync();

/// Loads the real bundled datasets from disk (no Flutter bindings needed).
RailDataBundle loadRealBundle() => buildBundleFromJson(
      places: _read('assets/rail/places.json'),
      roads: _read('assets/rail/roads.json'),
      segments: _read('assets/rail/segments.json'),
      curated: _read('assets/curated/station_names_bn.json'),
    );

RailDataBundle? _cached;
RailDataBundle realBundle() => _cached ??= loadRealBundle();
