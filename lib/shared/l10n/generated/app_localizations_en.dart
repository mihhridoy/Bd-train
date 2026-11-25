// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'BD Train 3D Live Tracking';

  @override
  String get navMap => 'Map';

  @override
  String get navRoutes => 'Routes';

  @override
  String get navTrains => 'Trains';

  @override
  String get navSettings => 'Settings';

  @override
  String get searchHint => 'Search station or place';

  @override
  String get searchPrompt =>
      'Type a station or place name in Bangla or English';

  @override
  String noResults(String query) {
    return 'No results for “$query”';
  }

  @override
  String get kindStation => 'Station';

  @override
  String get kindCity => 'City';

  @override
  String get kindTown => 'Town';

  @override
  String get kindSuburb => 'Suburb';

  @override
  String get kindVillage => 'Village';

  @override
  String get kindOther => 'Place';

  @override
  String get junction => 'Junction';

  @override
  String get terminus => 'Terminus';

  @override
  String get connectedStations => 'Connected stations';

  @override
  String get coordinates => 'Coordinates';

  @override
  String nearestStationTo(String name, String distance) {
    return 'Nearest station: $name · $distance';
  }

  @override
  String get banglaNameUnavailable =>
      'Bangla name not available in the dataset';

  @override
  String get nameFromDataset => 'Name matched from OpenStreetMap place data';

  @override
  String get nameCurated => 'Name from the app\'s curated list';

  @override
  String get nearbyBridges => 'Bridges nearby';

  @override
  String get routeFromHere => 'Route from here';

  @override
  String get routeToHere => 'Route to here';

  @override
  String get showOnMap => 'Show on map';

  @override
  String get share => 'Share';

  @override
  String shareStationText(String name, String lat, String lng) {
    return '$name railway station — $lat, $lng';
  }

  @override
  String get routeFrom => 'From';

  @override
  String get routeTo => 'To';

  @override
  String get selectStation => 'Select station';

  @override
  String get swap => 'Swap';

  @override
  String get findRoute => 'Find route';

  @override
  String get clearRoute => 'Clear route';

  @override
  String get routeDistance => 'Track distance';

  @override
  String get routeStations => 'Stations on route';

  @override
  String get routeBridges => 'Bridges on route';

  @override
  String get routeNoPath => 'No connected track path found.';

  @override
  String get routeNote =>
      'Shortest path along the bundled track geometry. This is not a timetable and may differ from the path a particular train takes.';

  @override
  String routeActive(String from, String to) {
    return 'Route: $from → $to';
  }

  @override
  String stopsCount(String count) {
    return '$count stations';
  }

  @override
  String bridgeLength(String length) {
    return '$length long';
  }

  @override
  String get unnamedBridge => 'Unnamed bridge';

  @override
  String get layers => 'Map layers';

  @override
  String get layerRoads => 'Roads';

  @override
  String get layerPlaces => 'Places';

  @override
  String get layerBridges => 'Bridges';

  @override
  String get layerLabels => 'Station names';

  @override
  String get layerTiles => 'Online base map';

  @override
  String get layerTilesOff => 'Not configured. Offline vector map is used.';

  @override
  String get myLocation => 'My location';

  @override
  String get locationWhyTitle => 'Use your location?';

  @override
  String get locationWhyBody =>
      'Your location is used once, on this device, to centre the map and find the nearest railway station. It is not stored or sent anywhere.';

  @override
  String get allow => 'Continue';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get locationDenied =>
      'Location permission was denied. You can still search for stations.';

  @override
  String get locationDeniedForever =>
      'Location is blocked. Enable it in system settings to use this feature.';

  @override
  String get locationServiceOff => 'Location services are turned off.';

  @override
  String get locationFailed => 'Could not get your location.';

  @override
  String get openSettings => 'Open settings';

  @override
  String nearestToYou(String name, String distance) {
    return 'Nearest station to you: $name ($distance)';
  }

  @override
  String get trainsTitle => 'Trains';

  @override
  String get tabTracking => 'Tracking';

  @override
  String get tabTimetable => 'Timetable';

  @override
  String get trackingNotConfiguredTitle => 'Live tracking is not connected';

  @override
  String get trackingNotConfiguredBody =>
      'This app has no live train data source yet, so no real train positions are shown. A real feed needs a backend supplied by its owner. You can preview the interface with clearly labelled simulated trains.';

  @override
  String get startDemo => 'Start demo mode';

  @override
  String get stopDemo => 'Stop demo mode';

  @override
  String get demoBadge => 'DEMO';

  @override
  String get demoBanner =>
      'DEMO MODE — simulated trains. These are not real train positions.';

  @override
  String demoSpeed(String scale) {
    return 'Simulation runs $scale× faster than real time.';
  }

  @override
  String updatedAt(String time) {
    return 'Updated $time';
  }

  @override
  String staleBanner(String seconds) {
    return 'No update for ${seconds}s — data may be outdated.';
  }

  @override
  String get pauseFeed => 'Pause feed (test stale state)';

  @override
  String get resumeFeed => 'Resume feed';

  @override
  String get trainsLoading => 'Waiting for first update…';

  @override
  String get trainsEmpty => 'No trains reported.';

  @override
  String get trainsError => 'Could not read train data.';

  @override
  String trainSpeed(String speed) {
    return '$speed km/h (simulated)';
  }

  @override
  String trainProgress(String percent) {
    return '$percent% of trip';
  }

  @override
  String get hornPlay => 'Sound horn';

  @override
  String get timetablePartialNotice =>
      'Partial timetable seed (Timetable No. 54 reference, effective 2025-03-10). Only terminal stations and times were transcribed; it is not a complete or verified schedule. Confirm with Bangladesh Railway before travelling.';

  @override
  String offDay(String day) {
    return 'Weekly off-day: $day';
  }

  @override
  String get noOffDay => 'No weekly off-day';

  @override
  String get nextDayArrival => 'next day';

  @override
  String get viewOnMap => 'View track on map';

  @override
  String get notOnMap => 'An endpoint is not in the map dataset';

  @override
  String get svcIntercity => 'Intercity';

  @override
  String get svcMail => 'Mail/Express';

  @override
  String get svcInternational => 'International';

  @override
  String get svcOther => 'Other';

  @override
  String get verificationPartial => 'Partial transcription — not verified';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get bangla => 'বাংলা';

  @override
  String get english => 'English';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get soundEffects => 'Sound effects';

  @override
  String get soundEffectsDesc => 'Train horn in demo mode.';

  @override
  String get mapOverlays => 'Map overlays';

  @override
  String get networkTitle => 'Network';

  @override
  String get offlineNote =>
      'Rail map, stations, places and roads are bundled and work offline. Only an optional online base map and a future live feed need internet.';

  @override
  String get openNetworkSettings => 'Open network settings';

  @override
  String get networkSettingsFailed => 'Could not open network settings.';

  @override
  String get about => 'About & data';

  @override
  String get dataAttribution => 'Map data';

  @override
  String datasetSummary(
    String stations,
    String segments,
    String bridges,
    String places,
    String roads,
  ) {
    return '$stations stations · $segments segments · $bridges bridges · $places places · $roads roads';
  }

  @override
  String datasetGenerated(String date) {
    return 'Rail dataset generated $date';
  }

  @override
  String banglaCoverage(String have, String total) {
    return 'Bangla names available for $have of $total stations; others show English.';
  }

  @override
  String parseIssues(String count) {
    return '$count dataset records were skipped';
  }

  @override
  String get disclaimer =>
      'Independent reconstruction. Not affiliated with Bangladesh Railway. No real-time train data.';

  @override
  String get loading => 'Loading rail data…';

  @override
  String get loadError => 'Could not load the rail data.';

  @override
  String get retry => 'Retry';

  @override
  String get mapAttribution => '© OpenStreetMap contributors (ODbL)';

  @override
  String get vectorMapNote => 'Offline vector map';

  @override
  String get zoomIn => 'Zoom in';

  @override
  String get zoomOut => 'Zoom out';

  @override
  String connectionsCount(String count) {
    return '$count connections';
  }

  @override
  String get routeStationsNote =>
      'Stations whose position lies within 250 m of the track. Derived from geometry, not from a timetable.';
}
