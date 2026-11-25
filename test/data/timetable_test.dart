import 'dart:convert';
import 'dart:io';

import 'package:bd_train_tracker/data/parsers/timetable_parser.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/dataset_loader.dart';

void main() {
  final net = realBundle().network;
  final json = jsonDecode(File('assets/timetable/timetable_seed.json').readAsStringSync());

  test('seed parses fully and keeps train numbers as strings', () {
    final r = parseTimetable(json, net);
    expect(r.entries.length, 32);
    expect(r.issues, isEmpty);
    expect(r.entries.every((e) => e.verificationStatus == 'official_source_partial_transcription'), isTrue);
  });

  test('endpoints map to geometry keys incl. aliases; unknowns stay null', () {
    final r = parseTimetable(json, net);
    String? key(String name) => resolveTimetableStation(name, net);
    expect(key('Dhaka'), 'dhaka');
    expect(key('Dhaka Cantt'), 'dhaka_cantonment');
    expect(key('Ishurdi'), 'ishwardi');
    expect(key('Kolkata'), isNull);
    final mapped = r.entries.where((e) => e.canShowOnMap).length;
    expect(mapped, greaterThan(15));
    expect(r.entries.where((e) => !e.canShowOnMap), isNotEmpty);
  });

  test('overnight arrival detected', () {
    final r = parseTimetable(json, net);
    final chittra = r.entries.firstWhere((e) => e.trainNumber == '764');
    expect(chittra.departureTime, '19:00');
    expect(chittra.arrivesNextDay, isTrue);
    final kapotaksha = r.entries.firstWhere((e) => e.trainNumber == '715');
    expect(kapotaksha.arrivesNextDay, isFalse);
  });

  test('invalid rows are dropped with issues', () {
    final r = parseTimetable([
      {'train_number': '1', 'origin_station': 'Dhaka', 'destination_station': 'Sylhet', 'departure_time': '25:00', 'arrival_time': '10:00'},
      'x',
    ], net);
    expect(r.entries, isEmpty);
    expect(r.issues.length, 2);
  });
}
