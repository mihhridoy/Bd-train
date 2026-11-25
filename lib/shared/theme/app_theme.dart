import 'package:material_ui/material_ui.dart';

/// Colours used by the vector map. Derived from brightness, not from M3 roles,
/// so the rail network stays legible on the plain offline background.
class MapPalette {
  const MapPalette({
    required this.land,
    required this.road,
    required this.railCasing,
    required this.railCore,
    required this.route,
    required this.stationFill,
    required this.stationStroke,
    required this.label,
    required this.labelHalo,
    required this.demo,
    required this.bridge,
  });

  final Color land, road, railCasing, railCore, route, stationFill, stationStroke;
  final Color label, labelHalo, demo, bridge;

  static const light = MapPalette(
    land: Color(0xFFF1EFE7),
    road: Color(0xFFD8D2C0),
    railCasing: Color(0xFF3B4A52),
    railCore: Color(0xFFFFFFFF),
    route: Color(0xFFE65100),
    stationFill: Color(0xFFFFFFFF),
    stationStroke: Color(0xFF0B6E4F),
    label: Color(0xFF1B2A24),
    labelHalo: Color(0xE6FFFFFF),
    demo: Color(0xFF7B1FA2),
    bridge: Color(0xFF1565C0),
  );

  static const dark = MapPalette(
    land: Color(0xFF16201C),
    road: Color(0xFF34423B),
    railCasing: Color(0xFF9FB3BC),
    railCore: Color(0xFF16201C),
    route: Color(0xFFFFA040),
    stationFill: Color(0xFF16201C),
    stationStroke: Color(0xFF5FD3A6),
    label: Color(0xFFE6F0EA),
    labelHalo: Color(0xCC16201C),
    demo: Color(0xFFCE93D8),
    bridge: Color(0xFF64B5F6),
  );

  static MapPalette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

class AppTheme {
  static const _seed = Color(0xFF0B6E4F);

  static ThemeData build(Brightness brightness, {required String language}) {
    final scheme = ColorScheme.fromSeed(seedColor: _seed, brightness: brightness);
    final isBn = language == 'bn';
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
      // Kalpurush carries Bangla glyphs; for English it is only a fallback so
      // Latin text keeps the platform font.
      fontFamily: isBn ? 'Kalpurush' : null,
      fontFamilyFallback: const ['Kalpurush'],
    );
    return base.copyWith(
      // Bangla conjuncts and matras need more vertical room than Latin text.
      textTheme: base.textTheme.apply(heightFactor: isBn ? 1.12 : 1.0),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.primaryContainer,
      ),
    );
  }
}
