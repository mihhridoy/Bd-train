import '../entities/geo.dart';
import '../entities/rail_entities.dart';
import 'text_normalizer.dart';

/// Attaches display names to the bare station coordinates in `segments.json`.
///
/// `segments.json` only carries ASCII slugs, so Bangla names are recovered by
/// (1) a curated override list, (2) an exact normalised name match against a
/// nearby place in `places.json`, (3) a one-edit spelling variant of a very
/// close place. Anything else is left without a Bangla name rather than guessed.
class StationNameResolver {
  StationNameResolver({
    this.exactRadiusMeters = 5000,
    this.fuzzyRadiusMeters = 4000,
    this.minFuzzyLength = 5,
  });

  final double exactRadiusMeters;
  final double fuzzyRadiusMeters;
  final int minFuzzyLength;

  static final _noise = RegExp(
      r'\b(junction|jn|halt|road|bypass|town|cantt|cantonment|bazar|bazaar|railway|station|bridge|flag|st|rd)\b');

  static String matchKey(String s) =>
      normalizeText(s).replaceAll(_noise, '').replaceAll(RegExp(r'[^a-z]'), '');

  List<Station> resolve({
    required Map<String, GeoPoint> stationPositions,
    required List<Place> places,
    Map<String, String> curatedBangla = const {},
  }) {
    final placeKeys = [for (final p in places) matchKey(p.nameEn)];
    final out = <Station>[];
    for (final entry in stationPositions.entries) {
      final key = entry.key;
      final pos = entry.value;
      final nameEn = titleFromKey(key);

      final curated = curatedBangla[key];
      if (curated != null && curated.isNotEmpty) {
        out.add(Station(
            key: key,
            position: pos,
            nameEn: nameEn,
            nameBn: curated,
            nameSource: NameSource.curated));
        continue;
      }

      final mk = matchKey(key);
      Place? exact;
      var exactD = double.infinity;
      Place? fuzzy;
      var fuzzyD = double.infinity;
      if (mk.isNotEmpty) {
        for (var i = 0; i < places.length; i++) {
          final p = places[i];
          // Cheap reject: ~0.06 deg is beyond 6 km everywhere in Bangladesh.
          if ((p.position.lat - pos.lat).abs() > 0.06 ||
              (p.position.lng - pos.lng).abs() > 0.06) {
            continue;
          }
          final d = haversineMeters(pos, p.position);
          final pk = placeKeys[i];
          if (pk == mk) {
            if (d <= exactRadiusMeters && d < exactD) {
              exact = p;
              exactD = d;
            }
          } else if (mk.length >= minFuzzyLength &&
              d <= fuzzyRadiusMeters &&
              d < fuzzyD &&
              boundedLevenshtein(mk, pk, 1) <= 1) {
            fuzzy = p;
            fuzzyD = d;
          }
        }
      }
      if (exact != null && exact.nameBn.isNotEmpty) {
        out.add(Station(
            key: key,
            position: pos,
            nameEn: nameEn,
            nameBn: exact.nameBn,
            nameSource: NameSource.datasetExact));
      } else if (fuzzy != null && fuzzy.nameBn.isNotEmpty) {
        out.add(Station(
            key: key,
            position: pos,
            nameEn: nameEn,
            nameBn: fuzzy.nameBn,
            nameSource: NameSource.datasetFuzzy));
      } else {
        out.add(Station(key: key, position: pos, nameEn: nameEn));
      }
    }
    return out;
  }
}
