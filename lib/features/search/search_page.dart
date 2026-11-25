import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/usecases/search_index.dart';
import '../../shared/l10n/generated/app_localizations.dart';
import '../../shared/providers.dart';
import '../../shared/utils/formatters.dart';
import '../station/station_sheet.dart';

/// Full-screen search over stations and places (Bangla + English).
/// Pops with the chosen [SearchHit].
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key, this.stationsOnly = false});

  /// Restrict results to stations (used by the route planner pickers).
  final bool stationsOnly;

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _controller = TextEditingController();
  List<SearchHit> _hits = const [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String q) {
    final all = ref.read(searchIndexProvider).search(q, limit: 60);
    setState(() => _hits = widget.stationsOnly
        ? all.whereType<StationHit>().take(30).toList()
        : all.take(40).toList());
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = ref.watch(languageProvider);
    final fmt = Fmt(lang);
    final net = ref.watch(networkProvider);
    final query = _controller.text.trim();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: l.searchHint,
            border: InputBorder.none,
          ),
          onChanged: _onChanged,
        ),
        actions: [
          if (query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                _onChanged('');
              },
            ),
        ],
      ),
      body: query.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(l.searchPrompt, textAlign: TextAlign.center),
              ),
            )
          : _hits.isEmpty
              ? Center(child: Text(l.noResults(query)))
              : ListView.separated(
                  itemCount: _hits.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final hit = _hits[i];
                    switch (hit) {
                      case StationHit(:final station):
                        final other = lang == 'bn' ? station.nameEn : (station.nameBn ?? '');
                        return ListTile(
                          leading: const Icon(Icons.train),
                          title: Text(station.displayName(lang)),
                          subtitle: Text([
                            l.kindStation,
                            if (other.isNotEmpty && other != station.displayName(lang)) other,
                          ].join(' · ')),
                          trailing: net.isJunction(station.key)
                              ? Chip(label: Text(l.junction), visualDensity: VisualDensity.compact)
                              : null,
                          onTap: () => Navigator.of(context).pop(hit),
                        );
                      case PlaceHit(:final place):
                        final nearest = net.nearestStations(place.position, limit: 1).first;
                        return ListTile(
                          leading: const Icon(Icons.place_outlined),
                          title: Text(place.displayName(lang)),
                          subtitle: Text(
                              '${placeKindLabel(l, place.category)} · ${l.nearestStationTo(nearest.station.displayName(lang), fmt.distance(nearest.distanceMeters))}'),
                          onTap: () => Navigator.of(context).pop(hit),
                        );
                    }
                  },
                ),
    );
  }
}
