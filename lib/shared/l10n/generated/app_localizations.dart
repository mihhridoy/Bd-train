import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'BD Train 3D Live Tracking'**
  String get appTitle;

  /// No description provided for @navMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get navMap;

  /// No description provided for @navRoutes.
  ///
  /// In en, this message translates to:
  /// **'Routes'**
  String get navRoutes;

  /// No description provided for @navTrains.
  ///
  /// In en, this message translates to:
  /// **'Trains'**
  String get navTrains;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search station or place'**
  String get searchHint;

  /// No description provided for @searchPrompt.
  ///
  /// In en, this message translates to:
  /// **'Type a station or place name in Bangla or English'**
  String get searchPrompt;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results for “{query}”'**
  String noResults(String query);

  /// No description provided for @kindStation.
  ///
  /// In en, this message translates to:
  /// **'Station'**
  String get kindStation;

  /// No description provided for @kindCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get kindCity;

  /// No description provided for @kindTown.
  ///
  /// In en, this message translates to:
  /// **'Town'**
  String get kindTown;

  /// No description provided for @kindSuburb.
  ///
  /// In en, this message translates to:
  /// **'Suburb'**
  String get kindSuburb;

  /// No description provided for @kindVillage.
  ///
  /// In en, this message translates to:
  /// **'Village'**
  String get kindVillage;

  /// No description provided for @kindOther.
  ///
  /// In en, this message translates to:
  /// **'Place'**
  String get kindOther;

  /// No description provided for @junction.
  ///
  /// In en, this message translates to:
  /// **'Junction'**
  String get junction;

  /// No description provided for @terminus.
  ///
  /// In en, this message translates to:
  /// **'Terminus'**
  String get terminus;

  /// No description provided for @connectedStations.
  ///
  /// In en, this message translates to:
  /// **'Connected stations'**
  String get connectedStations;

  /// No description provided for @coordinates.
  ///
  /// In en, this message translates to:
  /// **'Coordinates'**
  String get coordinates;

  /// No description provided for @nearestStationTo.
  ///
  /// In en, this message translates to:
  /// **'Nearest station: {name} · {distance}'**
  String nearestStationTo(String name, String distance);

  /// No description provided for @banglaNameUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Bangla name not available in the dataset'**
  String get banglaNameUnavailable;

  /// No description provided for @nameFromDataset.
  ///
  /// In en, this message translates to:
  /// **'Name matched from OpenStreetMap place data'**
  String get nameFromDataset;

  /// No description provided for @nameCurated.
  ///
  /// In en, this message translates to:
  /// **'Name from the app\'s curated list'**
  String get nameCurated;

  /// No description provided for @nearbyBridges.
  ///
  /// In en, this message translates to:
  /// **'Bridges nearby'**
  String get nearbyBridges;

  /// No description provided for @routeFromHere.
  ///
  /// In en, this message translates to:
  /// **'Route from here'**
  String get routeFromHere;

  /// No description provided for @routeToHere.
  ///
  /// In en, this message translates to:
  /// **'Route to here'**
  String get routeToHere;

  /// No description provided for @showOnMap.
  ///
  /// In en, this message translates to:
  /// **'Show on map'**
  String get showOnMap;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @shareStationText.
  ///
  /// In en, this message translates to:
  /// **'{name} railway station — {lat}, {lng}'**
  String shareStationText(String name, String lat, String lng);

  /// No description provided for @routeFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get routeFrom;

  /// No description provided for @routeTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get routeTo;

  /// No description provided for @selectStation.
  ///
  /// In en, this message translates to:
  /// **'Select station'**
  String get selectStation;

  /// No description provided for @swap.
  ///
  /// In en, this message translates to:
  /// **'Swap'**
  String get swap;

  /// No description provided for @findRoute.
  ///
  /// In en, this message translates to:
  /// **'Find route'**
  String get findRoute;

  /// No description provided for @clearRoute.
  ///
  /// In en, this message translates to:
  /// **'Clear route'**
  String get clearRoute;

  /// No description provided for @routeDistance.
  ///
  /// In en, this message translates to:
  /// **'Track distance'**
  String get routeDistance;

  /// No description provided for @routeStations.
  ///
  /// In en, this message translates to:
  /// **'Stations on route'**
  String get routeStations;

  /// No description provided for @routeBridges.
  ///
  /// In en, this message translates to:
  /// **'Bridges on route'**
  String get routeBridges;

  /// No description provided for @routeNoPath.
  ///
  /// In en, this message translates to:
  /// **'No connected track path found.'**
  String get routeNoPath;

  /// No description provided for @routeNote.
  ///
  /// In en, this message translates to:
  /// **'Shortest path along the bundled track geometry. This is not a timetable and may differ from the path a particular train takes.'**
  String get routeNote;

  /// No description provided for @routeActive.
  ///
  /// In en, this message translates to:
  /// **'Route: {from} → {to}'**
  String routeActive(String from, String to);

  /// No description provided for @stopsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} stations'**
  String stopsCount(String count);

  /// No description provided for @bridgeLength.
  ///
  /// In en, this message translates to:
  /// **'{length} long'**
  String bridgeLength(String length);

  /// No description provided for @unnamedBridge.
  ///
  /// In en, this message translates to:
  /// **'Unnamed bridge'**
  String get unnamedBridge;

  /// No description provided for @layers.
  ///
  /// In en, this message translates to:
  /// **'Map layers'**
  String get layers;

  /// No description provided for @layerRoads.
  ///
  /// In en, this message translates to:
  /// **'Roads'**
  String get layerRoads;

  /// No description provided for @layerPlaces.
  ///
  /// In en, this message translates to:
  /// **'Places'**
  String get layerPlaces;

  /// No description provided for @layerBridges.
  ///
  /// In en, this message translates to:
  /// **'Bridges'**
  String get layerBridges;

  /// No description provided for @layerLabels.
  ///
  /// In en, this message translates to:
  /// **'Station names'**
  String get layerLabels;

  /// No description provided for @layerTiles.
  ///
  /// In en, this message translates to:
  /// **'Online base map'**
  String get layerTiles;

  /// No description provided for @layerTilesOff.
  ///
  /// In en, this message translates to:
  /// **'Not configured. Offline vector map is used.'**
  String get layerTilesOff;

  /// No description provided for @myLocation.
  ///
  /// In en, this message translates to:
  /// **'My location'**
  String get myLocation;

  /// No description provided for @locationWhyTitle.
  ///
  /// In en, this message translates to:
  /// **'Use your location?'**
  String get locationWhyTitle;

  /// No description provided for @locationWhyBody.
  ///
  /// In en, this message translates to:
  /// **'Your location is used once, on this device, to centre the map and find the nearest railway station. It is not stored or sent anywhere.'**
  String get locationWhyBody;

  /// No description provided for @allow.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get allow;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @locationDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission was denied. You can still search for stations.'**
  String get locationDenied;

  /// No description provided for @locationDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Location is blocked. Enable it in system settings to use this feature.'**
  String get locationDeniedForever;

  /// No description provided for @locationServiceOff.
  ///
  /// In en, this message translates to:
  /// **'Location services are turned off.'**
  String get locationServiceOff;

  /// No description provided for @locationFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not get your location.'**
  String get locationFailed;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @nearestToYou.
  ///
  /// In en, this message translates to:
  /// **'Nearest station to you: {name} ({distance})'**
  String nearestToYou(String name, String distance);

  /// No description provided for @trainsTitle.
  ///
  /// In en, this message translates to:
  /// **'Trains'**
  String get trainsTitle;

  /// No description provided for @tabTracking.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get tabTracking;

  /// No description provided for @tabTimetable.
  ///
  /// In en, this message translates to:
  /// **'Timetable'**
  String get tabTimetable;

  /// No description provided for @trackingNotConfiguredTitle.
  ///
  /// In en, this message translates to:
  /// **'Live tracking is not connected'**
  String get trackingNotConfiguredTitle;

  /// No description provided for @trackingNotConfiguredBody.
  ///
  /// In en, this message translates to:
  /// **'This app has no live train data source yet, so no real train positions are shown. A real feed needs a backend supplied by its owner. You can preview the interface with clearly labelled simulated trains.'**
  String get trackingNotConfiguredBody;

  /// No description provided for @startDemo.
  ///
  /// In en, this message translates to:
  /// **'Start demo mode'**
  String get startDemo;

  /// No description provided for @stopDemo.
  ///
  /// In en, this message translates to:
  /// **'Stop demo mode'**
  String get stopDemo;

  /// No description provided for @demoBadge.
  ///
  /// In en, this message translates to:
  /// **'DEMO'**
  String get demoBadge;

  /// No description provided for @demoBanner.
  ///
  /// In en, this message translates to:
  /// **'DEMO MODE — simulated trains. These are not real train positions.'**
  String get demoBanner;

  /// No description provided for @demoSpeed.
  ///
  /// In en, this message translates to:
  /// **'Simulation runs {scale}× faster than real time.'**
  String demoSpeed(String scale);

  /// No description provided for @updatedAt.
  ///
  /// In en, this message translates to:
  /// **'Updated {time}'**
  String updatedAt(String time);

  /// No description provided for @staleBanner.
  ///
  /// In en, this message translates to:
  /// **'No update for {seconds}s — data may be outdated.'**
  String staleBanner(String seconds);

  /// No description provided for @pauseFeed.
  ///
  /// In en, this message translates to:
  /// **'Pause feed (test stale state)'**
  String get pauseFeed;

  /// No description provided for @resumeFeed.
  ///
  /// In en, this message translates to:
  /// **'Resume feed'**
  String get resumeFeed;

  /// No description provided for @trainsLoading.
  ///
  /// In en, this message translates to:
  /// **'Waiting for first update…'**
  String get trainsLoading;

  /// No description provided for @trainsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No trains reported.'**
  String get trainsEmpty;

  /// No description provided for @trainsError.
  ///
  /// In en, this message translates to:
  /// **'Could not read train data.'**
  String get trainsError;

  /// No description provided for @trainSpeed.
  ///
  /// In en, this message translates to:
  /// **'{speed} km/h (simulated)'**
  String trainSpeed(String speed);

  /// No description provided for @trainProgress.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of trip'**
  String trainProgress(String percent);

  /// No description provided for @hornPlay.
  ///
  /// In en, this message translates to:
  /// **'Sound horn'**
  String get hornPlay;

  /// No description provided for @timetablePartialNotice.
  ///
  /// In en, this message translates to:
  /// **'Partial timetable seed (Timetable No. 54 reference, effective 2025-03-10). Only terminal stations and times were transcribed; it is not a complete or verified schedule. Confirm with Bangladesh Railway before travelling.'**
  String get timetablePartialNotice;

  /// No description provided for @offDay.
  ///
  /// In en, this message translates to:
  /// **'Weekly off-day: {day}'**
  String offDay(String day);

  /// No description provided for @noOffDay.
  ///
  /// In en, this message translates to:
  /// **'No weekly off-day'**
  String get noOffDay;

  /// No description provided for @nextDayArrival.
  ///
  /// In en, this message translates to:
  /// **'next day'**
  String get nextDayArrival;

  /// No description provided for @viewOnMap.
  ///
  /// In en, this message translates to:
  /// **'View track on map'**
  String get viewOnMap;

  /// No description provided for @notOnMap.
  ///
  /// In en, this message translates to:
  /// **'An endpoint is not in the map dataset'**
  String get notOnMap;

  /// No description provided for @svcIntercity.
  ///
  /// In en, this message translates to:
  /// **'Intercity'**
  String get svcIntercity;

  /// No description provided for @svcMail.
  ///
  /// In en, this message translates to:
  /// **'Mail/Express'**
  String get svcMail;

  /// No description provided for @svcInternational.
  ///
  /// In en, this message translates to:
  /// **'International'**
  String get svcInternational;

  /// No description provided for @svcOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get svcOther;

  /// No description provided for @verificationPartial.
  ///
  /// In en, this message translates to:
  /// **'Partial transcription — not verified'**
  String get verificationPartial;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @bangla.
  ///
  /// In en, this message translates to:
  /// **'বাংলা'**
  String get bangla;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @soundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound effects'**
  String get soundEffects;

  /// No description provided for @soundEffectsDesc.
  ///
  /// In en, this message translates to:
  /// **'Train horn in demo mode.'**
  String get soundEffectsDesc;

  /// No description provided for @mapOverlays.
  ///
  /// In en, this message translates to:
  /// **'Map overlays'**
  String get mapOverlays;

  /// No description provided for @networkTitle.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get networkTitle;

  /// No description provided for @offlineNote.
  ///
  /// In en, this message translates to:
  /// **'Rail map, stations, places and roads are bundled and work offline. Only an optional online base map and a future live feed need internet.'**
  String get offlineNote;

  /// No description provided for @openNetworkSettings.
  ///
  /// In en, this message translates to:
  /// **'Open network settings'**
  String get openNetworkSettings;

  /// No description provided for @networkSettingsFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open network settings.'**
  String get networkSettingsFailed;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About & data'**
  String get about;

  /// No description provided for @dataAttribution.
  ///
  /// In en, this message translates to:
  /// **'Map data'**
  String get dataAttribution;

  /// No description provided for @datasetSummary.
  ///
  /// In en, this message translates to:
  /// **'{stations} stations · {segments} segments · {bridges} bridges · {places} places · {roads} roads'**
  String datasetSummary(
    String stations,
    String segments,
    String bridges,
    String places,
    String roads,
  );

  /// No description provided for @datasetGenerated.
  ///
  /// In en, this message translates to:
  /// **'Rail dataset generated {date}'**
  String datasetGenerated(String date);

  /// No description provided for @banglaCoverage.
  ///
  /// In en, this message translates to:
  /// **'Bangla names available for {have} of {total} stations; others show English.'**
  String banglaCoverage(String have, String total);

  /// No description provided for @parseIssues.
  ///
  /// In en, this message translates to:
  /// **'{count} dataset records were skipped'**
  String parseIssues(String count);

  /// No description provided for @disclaimer.
  ///
  /// In en, this message translates to:
  /// **'Independent reconstruction. Not affiliated with Bangladesh Railway. No real-time train data.'**
  String get disclaimer;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading rail data…'**
  String get loading;

  /// No description provided for @loadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load the rail data.'**
  String get loadError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @mapAttribution.
  ///
  /// In en, this message translates to:
  /// **'© OpenStreetMap contributors (ODbL)'**
  String get mapAttribution;

  /// No description provided for @vectorMapNote.
  ///
  /// In en, this message translates to:
  /// **'Offline vector map'**
  String get vectorMapNote;

  /// No description provided for @zoomIn.
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get zoomIn;

  /// No description provided for @zoomOut.
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get zoomOut;

  /// No description provided for @connectionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} connections'**
  String connectionsCount(String count);

  /// No description provided for @routeStationsNote.
  ///
  /// In en, this message translates to:
  /// **'Stations whose position lies within 250 m of the track. Derived from geometry, not from a timetable.'**
  String get routeStationsNote;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
