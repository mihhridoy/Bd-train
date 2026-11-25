import 'dart:convert';
import 'dart:io';

import 'package:bd_train_tracker/data/parsers/parse_support.dart';
import 'package:bd_train_tracker/data/parsers/places_parser.dart';
import 'package:bd_train_tracker/data/parsers/roads_parser.dart';
import 'package:bd_train_tracker/data/parsers/segments_parser.dart';
import 'package:bd_train_tracker/domain/entities/rail_entities.dart';
import 'package:flutter_test/flutter_test.dart';

Object? _json(String path) => jsonDecode(File(path).readAsStringSync());

void main() {
  group('real datasets', () {
    test('places.json parses with no dropped records', () {
      final r = parsePlaces(_json('assets/rail/places.json'));
      expect(r.places.length, 961);
      expect(r.issues, isEmpty);
      expect(r.info.attribution, contains('OpenStreetMap'));
      final uttara = r.places.firstWhere((p) => p.nameEn == 'Uttara');
      expect(uttara.nameBn, 'উত্তরা');
      expect(uttara.category, PlaceCategory.suburb);
    });

    test('roads.json parses with no dropped records', () {
      final r = parseRoads(_json('assets/rail/roads.json'));
      expect(r.roads.length, 3721);
      expect(r.issues, isEmpty);
      expect(r.roads.every((x) => x.points.length >= 2), isTrue);
    });

    test('segments.json parses and is referentially intact', () {
      final r = parseSegments(_json('assets/rail/segments.json'));
      expect(r.stationPositions.length, 386);
      expect(r.segments.length, 638);
      expect(r.bridges.length, 96);
      expect(r.info.generated, '2026-11-10');
      expect(r.issues, isEmpty);
      for (final s in r.segments) {
        expect(r.stationPositions.containsKey(s.a), isTrue);
        expect(r.stationPositions.containsKey(s.b), isTrue);
        // Segment polylines start and end exactly at their stations.
        expect(s.points.first, r.stationPositions[s.a]);
        expect(s.points.last, r.stationPositions[s.b]);
      }
    });
  });

  group('malformed input', () {
    test('places: drops bad rows, keeps good ones, reports issues', () {
      final r = parsePlaces({
        'attribution': 'x',
        'places': [
          [23.8, 90.4, 's', 'ক', 'A'],
          [23.8, 90.4, 'z', 'ক', 'B'], // unknown category
          [95.0, 90.4, 's', 'ক', 'C'], // out of bounds
          [23.8, 'x', 's', 'ক', 'D'], // bad coordinate
          [23.8, 90.4, 's'], // too short
          [23.8, 90.4, 's', '', ''], // no name
        ],
      });
      expect(r.places.map((p) => p.nameEn), ['A']);
      expect(r.issues.length, 5);
    });

    test('places: wrong root throws DatasetFormatException', () {
      expect(() => parsePlaces([]), throwsA(isA<DatasetFormatException>()));
      expect(() => parsePlaces({'places': 'nope'}), throwsA(isA<DatasetFormatException>()));
    });

    test('roads: rejects single point and bad geometry', () {
      final r = parseRoads({
        'roads': [
          ['রা', 'R1', [[23.1, 90.1], [23.2, 90.2]]],
          ['রা', 'R2', [[23.1, 90.1]]],
          ['রা', 'R3', [[23.1, 90.1], ['a', 'b']]],
          ['রা', 'R4'],
        ],
      });
      expect(r.roads.length, 1);
      expect(r.issues.length, 3);
    });

    test('segments: unknown station, duplicate pair and short geometry dropped', () {
      final r = parseSegments({
        'stations': {
          'a': [23.0, 90.0],
          'b': [23.1, 90.1],
          'c': [23.2, 90.2],
        },
        'segments': {
          'a|b': [[23.0, 90.0], [23.1, 90.1]],
          'b|a': [[23.1, 90.1], [23.0, 90.0]], // duplicate pair
          'a|z': [[23.0, 90.0], [23.1, 90.1]], // unknown station
          'b|c': [[23.1, 90.1]], // too short
          'a|a': [[23.0, 90.0], [23.0, 90.0]], // self loop
          'nokey': [[23.0, 90.0], [23.0, 90.0]],
        },
        'bridges': [
          {'a': [23.0, 90.0], 'b': [23.1, 90.1], 'l': 100, 'e': 'B', 'v': 1},
          {'a': [23.0, 90.0], 'b': [23.1, 90.1], 'l': -5},
          {'a': 'x', 'b': [23.1, 90.1], 'l': 5},
          'junk',
        ],
      });
      expect(r.segments.map((s) => s.key), ['a|b']);
      expect(r.bridges.length, 1);
      expect(r.bridges.single.nameEn, 'B');
      expect(r.bridges.single.nameBn, isNull);
      expect(r.bridges.single.flag, 1);
      expect(r.issues.length, 8);
    });

    test('segments: missing sections throws', () {
      expect(() => parseSegments({'stations': {}}), throwsA(isA<DatasetFormatException>()));
    });

    test('issue log caps stored messages but counts all', () {
      final log = IssueLog('f', maxStored: 2);
      for (var i = 0; i < 5; i++) {
        log.add('m$i');
      }
      expect(log.total, 5);
      expect(log.toList().length, 3);
      expect(log.toList().last, contains('3 more'));
    });
  });
}
