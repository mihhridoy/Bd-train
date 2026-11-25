import '../entities/geo.dart';
import '../entities/rail_entities.dart';
import '../entities/rail_network.dart';
import 'text_normalizer.dart';

sealed class SearchHit {
  const SearchHit(this.score);
  final double score;
  GeoPoint get position;
}

class StationHit extends SearchHit {
  const StationHit(this.station, super.score);
  final Station station;
  @override
  GeoPoint get position => station.position;
}

class PlaceHit extends SearchHit {
  const PlaceHit(this.place, super.score);
  final Place place;
  @override
  GeoPoint get position => place.position;
}

class _Entry {
  _Entry(this.hit, this.terms, this.tieBreak, {required this.isStation});
  final SearchHit Function(double score) hit;
  final List<String> terms;
  final double tieBreak;
  final bool isStation;
}

/// In-memory search over stations (Bangla + English + dataset key) and places.
class SearchIndex {
  SearchIndex({required RailNetwork network, required List<Place> places}) {
    for (final s in network.stations.values) {
      final terms = <String>{
        normalizeText(s.nameEn),
        normalizeText(s.key),
        if (s.hasBanglaName) normalizeText(s.nameBn!),
      }.where((t) => t.isNotEmpty).toList();
      _entries.add(_Entry((sc) => StationHit(s, sc), terms,
          // Prefer junctions when scores tie.
          network.degree(s.key).toDouble(), isStation: true));
    }
    for (final p in places) {
      final terms = <String>{normalizeText(p.nameEn), normalizeText(p.nameBn)}
          .where((t) => t.isNotEmpty)
          .toList();
      _entries.add(_Entry((sc) => PlaceHit(p, sc), terms,
          _categoryWeight(p.category), isStation: false));
    }
  }

  final List<_Entry> _entries = [];

  static double _categoryWeight(PlaceCategory c) => switch (c) {
        PlaceCategory.city => 0.4,
        PlaceCategory.town => 0.3,
        PlaceCategory.suburb => 0.2,
        PlaceCategory.other => 0.1,
        PlaceCategory.village => 0.0,
      };

  static double _scoreTerm(String term, String q, List<String> qTokens) {
    if (term == q) return 100;
    if (term.startsWith(q)) return 80;
    final words = term.split(' ');
    if (words.any((w) => w.startsWith(q))) return 60;
    if (qTokens.length > 1 &&
        qTokens.every((t) => words.any((w) => w.startsWith(t)))) {
      return 55;
    }
    if (term.contains(q)) return 40;
    return 0;
  }

  /// Returns hits sorted best first. Empty/blank queries return no hits.
  List<SearchHit> search(String query, {int limit = 30}) {
    final q = normalizeText(query);
    if (q.isEmpty) return const [];
    final qTokens = q.split(' ');
    final scored = <(double, SearchHit)>[];
    for (final e in _entries) {
      var best = 0.0;
      for (final t in e.terms) {
        final s = _scoreTerm(t, q, qTokens);
        if (s > best) best = s;
      }
      if (best == 0) continue;
      final total = best + (e.isStation ? 5 : 0) + e.tieBreak;
      scored.add((total, e.hit(total)));
    }
    scored.sort((a, b) => b.$1.compareTo(a.$1));
    return [for (final s in scored.take(limit)) s.$2];
  }
}
