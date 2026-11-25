import '../../domain/entities/rail_network.dart';
import '../../domain/entities/timetable.dart';
import '../../domain/usecases/text_normalizer.dart';
import 'parse_support.dart';

class ParsedTimetable {
  ParsedTimetable(this.entries, this.issues);
  final List<TimetableEntry> entries;
  final List<String> issues;
}

/// Timetable station names that differ from the geometry keys.
const Map<String, String> timetableStationAliases = {
  'dhaka cantt': 'dhaka_cantonment',
  'ishurdi': 'ishwardi',
};

String? resolveTimetableStation(String name, RailNetwork network) {
  final n = normalizeText(name);
  final alias = timetableStationAliases[n];
  if (alias != null && network.stations.containsKey(alias)) return alias;
  final key = n.replaceAll(' ', '_');
  return network.stations.containsKey(key) ? key : null;
}

final _hhmm = RegExp(r'^([01]\d|2[0-3]):[0-5]\d$');

/// Parses `timetable_seed.json` (a JSON array) and maps endpoints to stations.
ParsedTimetable parseTimetable(Object? root, RailNetwork network) {
  const file = 'timetable_seed.json';
  if (root is! List) throw DatasetFormatException(file, 'expected an array');
  final log = IssueLog(file);
  final out = <TimetableEntry>[];
  for (var i = 0; i < root.length; i++) {
    final r = root[i];
    if (r is! Map) {
      log.add('row $i: not an object');
      continue;
    }
    String? s(String k) => r[k] is String && (r[k] as String).trim().isNotEmpty
        ? (r[k] as String).trim()
        : null;
    final number = r['train_number']?.toString().trim();
    final dep = s('departure_time'), arr = s('arrival_time');
    final from = s('origin_station'), to = s('destination_station');
    if (number == null || number.isEmpty || from == null || to == null ||
        dep == null || arr == null || !_hhmm.hasMatch(dep) || !_hhmm.hasMatch(arr)) {
      log.add('row $i: missing/invalid number, stations or HH:mm times');
      continue;
    }
    out.add(TimetableEntry(
      trainNumber: number,
      nameEn: s('train_name_en') ?? number,
      nameBn: s('train_name_bn'),
      serviceType: s('service_type') ?? 'unknown',
      originName: from,
      destinationName: to,
      departureTime: dep,
      arrivalTime: arr,
      weeklyOffDay: s('weekly_off_day'),
      verificationStatus: s('verification_status') ?? 'unknown',
      effectiveNote: s('schedule_effective_date') ?? '',
      originKey: resolveTimetableStation(from, network),
      destinationKey: resolveTimetableStation(to, network),
    ));
  }
  return ParsedTimetable(out, log.toList());
}
