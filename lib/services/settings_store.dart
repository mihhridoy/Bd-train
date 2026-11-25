import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { system, light, dark }

/// User preferences persisted locally.
class AppSettings {
  const AppSettings({
    this.language = 'bn', // Bangla-first
    this.themeMode = AppThemeMode.system,
    this.showRoads = false,
    this.showPlaces = true,
    this.showBridges = true,
    this.showStationLabels = true,
    this.showBaseTiles = false,
    this.soundEnabled = true,
    this.demoEnabled = false,
  });

  final String language;
  final AppThemeMode themeMode;
  final bool showRoads;
  final bool showPlaces;
  final bool showBridges;
  final bool showStationLabels;
  final bool showBaseTiles;
  final bool soundEnabled;

  /// Demo mode is opt-in and always visibly labelled.
  final bool demoEnabled;

  AppSettings copyWith({
    String? language,
    AppThemeMode? themeMode,
    bool? showRoads,
    bool? showPlaces,
    bool? showBridges,
    bool? showStationLabels,
    bool? showBaseTiles,
    bool? soundEnabled,
    bool? demoEnabled,
  }) =>
      AppSettings(
        language: language ?? this.language,
        themeMode: themeMode ?? this.themeMode,
        showRoads: showRoads ?? this.showRoads,
        showPlaces: showPlaces ?? this.showPlaces,
        showBridges: showBridges ?? this.showBridges,
        showStationLabels: showStationLabels ?? this.showStationLabels,
        showBaseTiles: showBaseTiles ?? this.showBaseTiles,
        soundEnabled: soundEnabled ?? this.soundEnabled,
        demoEnabled: demoEnabled ?? this.demoEnabled,
      );
}

class SettingsStore {
  SettingsStore(this._prefs);
  final SharedPreferences _prefs;

  AppSettings load() {
    const d = AppSettings();
    final lang = _prefs.getString('language');
    final theme = _prefs.getString('theme');
    return AppSettings(
      language: lang == 'en' || lang == 'bn' ? lang! : d.language,
      themeMode: AppThemeMode.values.firstWhere((m) => m.name == theme,
          orElse: () => d.themeMode),
      showRoads: _prefs.getBool('showRoads') ?? d.showRoads,
      showPlaces: _prefs.getBool('showPlaces') ?? d.showPlaces,
      showBridges: _prefs.getBool('showBridges') ?? d.showBridges,
      showStationLabels: _prefs.getBool('showStationLabels') ?? d.showStationLabels,
      showBaseTiles: _prefs.getBool('showBaseTiles') ?? d.showBaseTiles,
      soundEnabled: _prefs.getBool('soundEnabled') ?? d.soundEnabled,
      demoEnabled: _prefs.getBool('demoEnabled') ?? d.demoEnabled,
    );
  }

  Future<void> save(AppSettings s) async {
    await _prefs.setString('language', s.language);
    await _prefs.setString('theme', s.themeMode.name);
    await _prefs.setBool('showRoads', s.showRoads);
    await _prefs.setBool('showPlaces', s.showPlaces);
    await _prefs.setBool('showBridges', s.showBridges);
    await _prefs.setBool('showStationLabels', s.showStationLabels);
    await _prefs.setBool('showBaseTiles', s.showBaseTiles);
    await _prefs.setBool('soundEnabled', s.soundEnabled);
    await _prefs.setBool('demoEnabled', s.demoEnabled);
  }
}
