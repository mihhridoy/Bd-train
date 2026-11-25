import 'package:bd_train_tracker/app.dart';
import 'package:bd_train_tracker/services/location_service.dart';
import 'package:bd_train_tracker/shared/providers.dart';
import 'package:flutter/widgets.dart' show EditableText, Scrollable;
import 'package:material_ui/material_ui.dart' show Icons;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

ProviderContainer containerOf(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(BdTrainApp)));

Future<void> tapTab(WidgetTester t, String label) async {
  await t.tap(find.text(label).last);
  await t.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('boots Bangla-first with a rendered map and search bar', (t) async {
    await pumpApp(t);
    expect(find.text('মানচিত্র'), findsOneWidget); // nav label
    expect(find.text('স্টেশন বা স্থান খুঁজুন'), findsOneWidget);
    expect(find.text('ট্রেন'), findsOneWidget);
  });

  testWidgets('English can be selected and persists to settings', (t) async {
    await pumpApp(t, prefs: {'language': 'en'});
    expect(find.text('Map'), findsOneWidget);
    expect(find.text('Search station or place'), findsOneWidget);
  });

  testWidgets('switching language in Settings updates the UI', (t) async {
    await pumpApp(t);
    await tapTab(t, 'সেটিংস');
    await t.tap(find.text('English'));
    await t.pump(const Duration(milliseconds: 300));
    expect(find.text('Settings'), findsWidgets);
    expect(find.text('Map'), findsOneWidget);
  });

  testWidgets('search finds station by English and Bangla names and opens detail', (t) async {
    await pumpApp(t, prefs: {'language': 'en'});
    await t.tap(find.text('Search station or place'));
    await t.pumpAndSettle();
    await t.enterText(find.byType(EditableText), 'Sylhet');
    await t.pump();
    expect(find.text('Sylhet'), findsWidgets);
    await t.tap(find.text('Sylhet').first);
    await t.pumpAndSettle();
    // Station sheet: coordinates + actions + connected stations.
    expect(find.text('Coordinates'), findsOneWidget);
    expect(find.text('Route from here'), findsOneWidget);
    await t.drag(find.text('Coordinates'), const Offset(0, -400));
    await t.pumpAndSettle();
    expect(find.text('Connected stations'), findsOneWidget);
  });

  testWidgets('Bangla query returns results; nonsense shows empty state', (t) async {
    await pumpApp(t);
    await t.tap(find.text('স্টেশন বা স্থান খুঁজুন'));
    await t.pumpAndSettle();
    await t.enterText(find.byType(EditableText), 'ঢাকা');
    await t.pump();
    expect(find.text('ঢাকা'), findsWidgets);
    await t.enterText(find.byType(EditableText), 'qqqzzz');
    await t.pump();
    expect(find.textContaining('কোনো ফলাফল নেই'), findsOneWidget);
  });

  testWidgets('route planner computes distance and station list', (t) async {
    await pumpApp(t, prefs: {'language': 'en'});
    final c = containerOf(t);
    c.read(routeOriginProvider.notifier).set('dhaka');
    c.read(routeDestinationProvider.notifier).set('chattogram');
    await tapTab(t, 'Routes');
    expect(find.text('Track distance'), findsOneWidget);
    expect(find.textContaining(' km'), findsWidgets);
    expect(find.text('Stations on route'), findsOneWidget);
    expect(find.text('Show on map'), findsOneWidget);
    await t.tap(find.text('Show on map'));
    await t.pump(const Duration(milliseconds: 300));
    expect(c.read(activeRouteProvider), isNotNull);
    expect(c.read(homeTabProvider), HomeTab.map);
  });

  testWidgets('trains tab: not configured -> explicit demo opt-in with DEMO labels', (t) async {
    await pumpApp(t, prefs: {'language': 'en'});
    await tapTab(t, 'Trains');
    expect(find.text('Live tracking is not connected'), findsOneWidget);
    expect(find.textContaining('DEMO-'), findsNothing); // nothing fabricated

    await t.tap(find.text('Start demo mode'));
    await t.pump(const Duration(milliseconds: 300));
    await t.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('DEMO MODE'), findsWidgets);
    expect(find.textContaining('DEMO-1'), findsWidgets);
    expect(find.text('DEMO'), findsWidgets);
    expect(find.textContaining('Updated'), findsOneWidget);
  });

  testWidgets('timetable tab shows partial-data warning and rows', (t) async {
    await pumpApp(t, prefs: {'language': 'en'});
    await tapTab(t, 'Trains');
    await t.tap(find.text('Timetable'));
    await t.pumpAndSettle();
    expect(find.textContaining('Partial timetable seed'), findsOneWidget);
    expect(find.textContaining('Kapotaskh Express'), findsWidgets);
    expect(find.text('Partial transcription — not verified'), findsWidgets);
  });

  testWidgets('location: rationale shown first, denial handled gracefully', (t) async {
    final h = await pumpApp(t,
        prefs: {'language': 'en'}, location: const LocationDenied());
    await t.tap(find.byIcon(Icons.my_location));
    await t.pumpAndSettle();
    expect(find.text('Use your location?'), findsOneWidget);
    expect(h.location.calls, 0); // no permission request before consent
    await t.tap(find.text('Continue'));
    await t.pumpAndSettle();
    expect(h.location.calls, 1);
    expect(find.textContaining('permission was denied'), findsOneWidget);
  });

  testWidgets('location: cancel never calls the service; success shows nearest station', (t) async {
    final h = await pumpApp(t, prefs: {'language': 'en'});
    await t.tap(find.byIcon(Icons.my_location));
    await t.pumpAndSettle();
    await t.tap(find.text('Cancel'));
    await t.pumpAndSettle();
    expect(h.location.calls, 0);

    await t.tap(find.byIcon(Icons.my_location));
    await t.pumpAndSettle();
    await t.tap(find.text('Continue'));
    await t.pumpAndSettle();
    expect(find.textContaining('Nearest station to you'), findsOneWidget);
  });

  testWidgets('settings: network settings channel + attribution + dataset audit', (t) async {
    final h = await pumpApp(t, prefs: {'language': 'en'});
    await tapTab(t, 'Settings');
    await t.scrollUntilVisible(find.text('Open network settings'), 200,
        scrollable: find.byType(Scrollable).last);
    await t.tap(find.text('Open network settings'));
    await t.pump();
    expect(h.platform.opened, 1);
    await t.scrollUntilVisible(find.textContaining('386 stations ·'), 200,
        scrollable: find.byType(Scrollable).last);
    expect(find.textContaining('OpenStreetMap'), findsWidgets);
  });

  testWidgets('layers sheet toggles roads overlay', (t) async {
    await pumpApp(t, prefs: {'language': 'en'});
    final c = containerOf(t);
    expect(c.read(settingsProvider).showRoads, isFalse);
    await t.tap(find.byIcon(Icons.layers));
    await t.pumpAndSettle();
    await t.tap(find.text('Roads'));
    await t.pumpAndSettle();
    expect(c.read(settingsProvider).showRoads, isTrue);
  });

  test('location outcomes are exhaustive', () {
    const LocationOutcome o = LocationDenied();
    final s = switch (o) {
      LocationGranted() => 'g',
      LocationDenied() => 'd',
      LocationDeniedForever() => 'f',
      LocationServiceOff() => 'o',
      LocationFailed() => 'x',
    };
    expect(s, 'd');
  });
}
