/// Build-time configuration (`--dart-define=KEY=value`). No secrets live in code.
class AppConfig {
  /// Optional raster tile URL, e.g. `https://tiles.example.com/{z}/{x}/{y}.png`.
  /// Leave empty to use the offline vector map. Use only a provider whose terms
  /// permit your usage (the public OSM tile servers do not permit app bundling
  /// or heavy use).
  static const tileUrlTemplate = String.fromEnvironment('TILE_URL_TEMPLATE');

  /// Attribution text required by the configured tile provider.
  static const tileAttribution = String.fromEnvironment('TILE_ATTRIBUTION');

  static bool get tilesConfigured => tileUrlTemplate.isNotEmpty;
}

/// Optional modules. Disabled modules add no UI and no permissions.
class FeatureFlags {
  static const audio = bool.fromEnvironment('FF_AUDIO', defaultValue: true);
  static const share = bool.fromEnvironment('FF_SHARE', defaultValue: true);
  static const location = bool.fromEnvironment('FF_LOCATION', defaultValue: true);

  // Not implemented in this codebase (need backend/credentials); kept false so
  // nothing half-working ships. See docs/MISSING_BACKEND.md.
  static const notifications = false;
  static const homeWidget = false;
  static const ads = false;
}
