import 'package:flutter/services.dart';

/// Reads the raw bundled dataset text. Kept tiny so tests can fake it.
abstract interface class RailAssetSource {
  Future<String> read(String assetPath);
}

class BundleRailAssetSource implements RailAssetSource {
  BundleRailAssetSource([AssetBundle? bundle]) : _bundle = bundle ?? rootBundle;
  final AssetBundle _bundle;

  @override
  Future<String> read(String assetPath) => _bundle.loadString(assetPath);
}

class RailAssets {
  static const places = 'assets/rail/places.json';
  static const roads = 'assets/rail/roads.json';
  static const segments = 'assets/rail/segments.json';
  static const curatedNames = 'assets/curated/station_names_bn.json';
}
